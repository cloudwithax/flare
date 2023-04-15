---@diagnostic disable: need-check-nil
local discordia = require('discordia')
local websocket = require('coro-websocket')
local http = require('coro-http')
local json = require('json')
local utils = require('utils')
local enums = require('enums')
local interp = utils.interp
local split = utils.split
local url = require('url')
local SearchType = enums.SearchType
local Track = require('track')
local Playlist = require('playlist')
local package = require('../../package')
local Player = require('player')

local Emitter = discordia.Emitter
local class = discordia.class
local Node = class('Node', Emitter)

local format = string.format



getmetatable("").__mod = interp


function Node:__init(client, options)
    Emitter.__init(self)
    assert(options, 'No options were provided.')

    self._client = assert(client, 'Discordia Client was not provided.')
    self._host = assert(options.host, 'Host was not provided.')
    self._port = options.port or 2333
    self._password = options.password or 'youshallnotpass'
    self._identifier = assert(options.identifier, "Node identifier was not provided.")
    self._heartbeat = options.heartbeat or 30
    self._secure = options.secure or false

    if self._secure then
        self._websocket_uri = format('wss://%s:%s/', self._host, self._port)
        self._rest_uri = format('https://%s:%s/', self._host, self._port)
    else
        self._websocket_uri = format('ws://%s:%s/', self._host, self._port)
        self._rest_uri = format('http://%s:%s/', self._host, self._port)
    end

    self._session_id = nil
    self._available = false
    self._connected = false
    self._version = nil
    self._pool = options.pool


    self._headers = {
        { 'Authorization', self._password },
        { 'Num-Shards',    self._client.shardCount },
        { 'User-Id',       self._client.user.id },
        { 'Client-Name',   format("Flare/%s", package.version) }
    }

    self._res = nil
    self._read = nil

    self._players = {}

    self._client:on('raw', function(data)
        data = json.decode(data)

        if data.t == 'VOICE_SERVER_UPDATE' then
            data = data.d
            local guild = self._client:getGuild(data.guild_id)
            if not guild then return end

            local user = guild.me or guild:getMember(self._client.user.id)
            if not user then return end

            local state = guild._voice_states[user.id]
            if not state then return end

            local voice_data = {
                ['voice'] = {
                    ['token'] = data.token,
                    ['endpoint'] = data.endpoint,
                    ['sessionId'] = state.session_id
                }
            }

            local player_endpoint = string.format("sessions/%s/players", self._session_id)

            self:_send('PATCH', player_endpoint, guild.id, voice_data, nil, true)
        end
    end)

    self:connect()
end

function Node:_listen()
    for data in self._read do
        if data.opcode == 1 then
            local payload = json.decode(data.payload)
            -- print(dump(payload))
            if payload.op == 'playerUpdate' then
                self:emit('event', payload)
            elseif payload.op == 'stats' then
                payload.op = nil
                self._stats = payload
                self:emit('stats', self._stats)
            elseif payload.op == 'ready' then
                self._session_id = payload.sessionId
            elseif payload.op == 'event' then
                self:emit('event', payload)
            end
        elseif data.opcode == 8 then
            self:disconnect()
        end
    end
end

function Node:connect()
    if self._connected then return false, 'Already connected' end

    local options = websocket.parseUrl(self._websocket_uri)
    options.headers = self._headers

    local res, read = websocket.connect(options)

    local version = self:_send('GET', 'version', nil, nil, nil, false)
    version = split(version, ".")
    self._version = version[1]

    if res and res.code == 101 then
        self._connected = true
        self._res, self._read = res, read
        coroutine.wrap(self._listen)(self)
        print(format("Node with identifier %s has connected successfully.", self._identifier))
        return true
    end
    return false, read
end

function Node:disconnect(forced)
    if not self._connected then return end
    self._connected = false
    self._res, self._read = nil, nil
    self:emit('killed')
    self:removeAllListeners('event')
    if not forced then self:_reconnect() end
end

function Node:_send(method, path, _guild_id, _data, _query, include_version)
    if include_version and not self._connected then return end

    local guild_id = _guild_id or ""
    local query = _query or ""
    local data = ""
    local version = ""

    if include_version then
        version = "v" .. self._version .. "/"
    end

    if _guild_id then
        guild_id = "/" .. _guild_id
    end

    if _query then
        query = "?" .. _query
    end

    if _data then
        data = json.encode(_data)
        table.insert(self._headers, { "Content-Type", "application/json" })
    end

    local uri = format('%s%s%s%s%s', self._rest_uri, version, path, guild_id, query)

    local res, body = http.request(method, uri, self._headers, data)

    if res.code == 200 then
        return json.decode(body)
    elseif res.code == 204 or method == "DELETE" then
        return nil
    else
        return nil, body
    end
end

function Node:get_tracks(_query, search_type)
    if not self._connected then return end
    assert(_query, "Query must be provided.")

    local query = nil

    if not search_type then
        local parsed = url.parse(_query)
        if parsed.host then
            query = "identifier=" .. utils.escape(_query)
        else
            query = "identifier=" .. SearchType.YOUTUBE .. ":" .. utils.escape(_query)
        end
    else
        assert(utils.valueintb(SearchType, search_type), "Search type not valid.")
        query = "identifier=" .. search_type .. ":" .. utils.escape(_query)
    end


    local data = self:_send('GET', 'loadtracks', nil, nil, query)
    local load_type = data.loadType

    if not load_type then
        return print("There was an error while trying to load this track.")
    end

    if load_type == "NO_MATCHES" then
        return nil
    elseif load_type == "LOAD_FAILED" then
        local exception = data.exception
        return print(format("Error loading track: %s [%s]", exception.message, exception.severity))
    elseif load_type == "SEARCH_RESULT" or load_type == "TRACK_LOADED" then
        local tracks = {}
        for _, v in pairs(data.tracks) do
            table.insert(tracks, Track(v))
        end
        return tracks
    elseif load_type == "PLAYLIST_LOADED" then
        local tracks = {}
        for _, v in pairs(data.tracks) do
            table.insert(tracks, Track(v))
        end

        return Playlist(data, tracks)
    else
        return print("There was an error while trying to load this track.")
    end
end

function Node:create_player(vc)
    assert(type(vc) ~= "GuildVoiceChannel", "Not a voice channel")
    local guild = vc.guild
    if not guild then return false, 'Could not find guild' end
    if self._players[guild.id] then return self._players[guild.id] end



    local success, err = self._client._shards[vc.guild.shardId]:updateVoice(vc.guild.id, vc.id)
    if not success then return nil, err end

    local player = Player(self, vc)
    self._players[guild.id] = player
    return player
end

function Node:get_player(guild_id)
    if self._players[guild_id] then
        return self._players[guild_id]
    else
        return false, "Player not found"
    end
end

return Node
