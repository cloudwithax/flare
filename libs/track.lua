local discordia = require('discordia')
local class = discordia.class

local Track = class('Track')

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

return Track
