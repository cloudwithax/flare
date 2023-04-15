local discordia = require('discordia')
local class = discordia.class

local Track, get = class('Track')

function Track:__init(data)
    local info = data.info
    self._track_id = data.encoded
    self._author = info.author
    self._identifier = info.identifier
    self._uri = info.uri
    self._source_name = info.sourceName
    self._title = info.title
    self._position = info.position
    self._length = info.length
    self._is_stream = info.isStream
    self._is_seekable = info.isSeekable
end

function get.title(self)
    return self._track
end

function get.uri(self)
    return self._uri
end

function get.length(self)
    return self._length
end

function get.track_id(self)
    return self._track_id
end

function get.author(self)
    return self._author
end

return Track
