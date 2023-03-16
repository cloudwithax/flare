local discordia = require('discordia')
local Emitter = discordia.Emitter
local class = discordia.class

local Player, get = class('FlarePlayer', Emitter)
local format = string.format

local function bind(t, k)
    return function(...) return t[k](t, ...) end
end

function Player:__init(pool, node, guild, channel)
    Emitter.__init(self)
    self._pool = pool
    self._node = node
    self._client = node._client

    self._guild = guild
    self._channel = channel

    self._playing = false
    self._paused = false
    self._volume = 100
    self._track = nil
    self._trackPosition = nil
    self._lastChecked = nil
    self._startedAt = nil

    self._node:on('event', bind(self, '_onEvent'))
    self._node:on('killed', bind(self, '_onNodeKilled'))
end

return Player
