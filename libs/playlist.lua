local discordia = require('discordia')
local class = discordia.class

local Playlist = class('Playlist')

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

return Playlist
