local discordia = require('discordia')
local class = discordia.class

local Playlist, get = class('Playlist')

function Playlist:__init(data, tracks)
    local info = data.playlistInfo
    self._selected_track = info.selectedTrack
    self._name = info.name
    self._tracks = tracks

    if self._selected_track ~= -1 then
        self._selected_track = self._tracks[self._selected_track]
    end

    self._track_count = #self._tracks
end

function get.name(self)
    return self._name
end

function get.tracks(self)
    return self._tracks
end

function get.track_count(self)
    return self._track_count
end

return Playlist
