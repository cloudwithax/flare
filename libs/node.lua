local discordia = require('discordia')
local websocket = require('coro-websocket')
local http = require('coro-http')
local json = require('json')
local querystring = require('querystring')
local utils = require('utils')
local enums = require('enums')
local interp = utils.interp
local split = utils.split
local dump = utils.dump
local SearchType = enums.SearchType

local Emitter = discordia.Emitter
local class = discordia.class
local Node, get = class('FlareNode', Emitter)

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
        { 'Client-Name',   "Flare/1.0.0" }
    }

    self._res = nil
    self._read = nil

    self._players = {}

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
                print(self._session_id)
            elseif payload.op == 'event' then
                self:emit('event', payload)
            end
        elseif data.opcode == 8 then
            self:disconnect()
        end
    end
    self:close()
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
    if not forced then self:_reconnect() end
end

function Node:_send(method, path, _guild_id, _query, _data, include_version)
    if include_version and not self._connected then return end

    local guild_id = ""
    local query = _query or ""
    local data = _data or ""
    local version = ""

    if include_version then
        version = "/v" .. self._version .. "/"
    end

    if _guild_id then
        guild_id = "/" .. _guild_id
    end

    if _query then
        query = querystring.stringify({
            identifier = _query
        })
    end

    local uri = format('%s%s%s%s%s', self._rest_uri, version, path, guild_id, query)


    local res, body = http.request(method, uri, self._headers, data)

    if res.code == 200 then
        if type(body) == "string" then
            return body
        else
            return json.decode(body)
        end
    elseif res.code == 204 or method == "DELETE" then
        return nil
    else
        return nil, body
    end
end

function Node:get_tracks(_query, search_type)
    if not self._connected then return end
    assert(type(search_type) == type(SearchType), "Search type is not valid")

    local query = search_type .. ":" .. _query

    print(query)

    -- local tracks = self:_send('GET', 'loadtracks', nil, '')
end

return Node
