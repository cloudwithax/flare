local discordia = require('discordia')
local Emitter = discordia.Emitter
local class = discordia.class
local json = require('json')

local Player, get = class('FlarePlayer', Emitter)
local format = string.format

local function bind(t, k)
  return function(...) return t[k](t, ...) end
end

function Player:__init(node, channel)
  Emitter.__init(self)
  self._node = node
  self._client = node._client

  self._channel = channel
  self._guild = channel.guild


  self._playing = false
  self._paused = false
  self._volume = 100
  self._current = nil
  self._track_pos = nil
  self._last_update = nil
  self._session_id = nil
  self._filter = nil

  self._player_endpoint_url = string.format("sessions/%s/players", self._node._session_id)

  self._node:on('event', bind(self, '_onEvent'))
  -- self._node:on('killed', bind(self, '_onNodeKilled'))
end

function Player:_onEvent(data)
  if data.guildId ~= self._guild.id then return end
  if data.op == 'playerUpdate' then
    if not self._playing then return false end
    self._track_pos = data.state.position
    self._last_update = data.state.time
  elseif data.type == 'TrackEndEvent' then
    self:_clearTrack()
    self:emit('end', data.reason:lower())
  elseif data.type == 'TrackExceptionEvent' then
    self:_clearTrack()
    self:emit('end', 'error', data.error)
  elseif data.type == 'TrackStuckEvent' then
    self:stop()
    self:emit('end', data)
  else
    self:emit('warn', format('Unknown Event %s', data.type))
  end
end

function Player:_clearTrack()
  self._playing = false
  self._current = nil
  self._last_update = nil
  self._track_pos = nil
end

function Player:play(track, start_time, end_time, _ignore_if_playing)
  assert(type(track) == "table", "Invalid track provided")

  local data = {
    ["encodedTrack"] = track._track_id,
    ["position"] = start_time or 0,
    ["endTime"] = json.null
  }

  if end_time and end_time > 0 then
    data["endTime"] = tostring(end_time)
  end

  local ignore_if_playing = _ignore_if_playing or false

  self._node:_send("PATCH", self._player_endpoint_url, self._guild.id, data,
    string.format("noReplace=%s", ignore_if_playing), true)

  self._current = track
end

function Player:stop()
  local data = {
    ['encodedTrack'] = json.null

  }

  self._node:_send('PATCH', self._player_endpoint_url, self._guild.id, data, nil, true)

  self._current = nil
end

function Player:destroy()
  self._node:_send('DELETE', self._player_endpoint_url, self._guild.id, nil, nil, true)
  local success, err = self._client._shards[self._guild.shardId]:updateVoice(self._guild.id, nil)
  if not success then return nil, err end
  self:removeAllListeners('end')
  self:removeAllListeners('warn')
  self._node._players[self._guild.id] = nil
end

function Player:set_pause(paused)
  local data = {
    ['paused'] = paused
  }

  self._node:_send('PATCH', self._player_endpoint_url, self._guild.id, data, nil, true)

  self._paused = paused
end

function Player:seek(ms)
  local data = {
    ['position'] = ms
  }

  self._node:_send('PATCH', self._player_endpoint_url, self._guild.id, data, nil, true)
end

function Player:set_volume(volume)
  local data = {
    ['volume'] = volume
  }

  self._node:_send('PATCH', self._player_endpoint_url, self._guild.id, data, nil, true)

  self._volume = volume
end

function Player:get_tracks(query, search_type)
  return self._node:get_tracks(query, search_type)
end

function Player:set_filter(filter)
  assert(type(filter) == "table", "Invalid filter provided")

  local data = {
    ['filters'] = filter
  }

  self._node:_send('PATCH', self._player_endpoint_url, self._guild.id, data, nil, true)

  self._filter = filter
end

function Player:remove_filter()
  if not self._filter then return false, "No filter is applied." end

  -- this is the kind of bullshit i have to do to get "{}"
  -- in the payload. yes i know, lua is garbage.
  local empty = {}

  local meta = {
    __jsontype = "object"
  }

  setmetatable(empty, meta)

  local data = {
    ['filters'] = empty
  }

  self._node:_send('PATCH', self._player_endpoint_url, self._guild.id, data, nil, true)

  self._filter = nil
end

function get.playing(self)
  return self._playing
end

function get.paused(self)
  return self._paused
end

function get.volume(self)
  return self._volume
end

function get.current(self)
  return self._current
end

function get.filter(self)
  return self._filter
end

return Player
