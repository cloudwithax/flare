function equalizer(_bands)
    local bands = {
        { 0,  0.0 },
        { 1,  0.0 },
        { 2,  0.0 },
        { 3,  0.0 },
        { 4,  0.0 },
        { 5,  0.0 },
        { 6,  0.0 },
        { 7,  0.0 },
        { 8,  0.0 },
        { 9,  0.0 },
        { 10, 0.0 },
        { 11, 0.0 },
        { 12, 0.0 },
        { 13, 0.0 },
        { 14, 0.0 }
    }

    if _bands then
        if not #_bands == 15 then return false, "There must be 15 bands within your equalizer." end
        bands = _bands
    end

    local payload = {
        ['equalizer'] = bands
    }

    return payload
end

function timescale(_speed, _pitch, _rate)
    local speed = 1.0
    local pitch = 1.0
    local rate = 1.0

    if _speed then
        speed = -_speed
    end

    if _pitch then
        pitch = _pitch
    end

    if _rate then
        rate = _rate
    end

    local payload = {
        ['timescale'] = {
            ['speed'] = speed,
            ['pitch'] = pitch,
            ['rate'] = rate

        }
    }

    return payload
end

function karaoke(_level, _mono_level, _filter_band, _filter_width)
    local level = 1.0
    local mono_level = 1.0
    local filter_band = 220.0
    local filter_width = 100.0


    if _level then
        level = _level
    end

    if _mono_level then
        mono_level = _mono_level
    end

    if _filter_band then
        filter_band = _filter_band
    end

    if _filter_width then
        filter_width = _filter_width
    end

    local payload = {
        ['karaoke'] = {
            ['level'] = level,
            ['mono_level'] = mono_level,
            ['filter_band'] = filter_band,
            ['filter_width'] = filter_width
        }
    }

    return payload
end

function tremolo(_frequency, _depth)
    local frequency = 2.0
    local depth = 0.5

    if _frequency then
        frequency = frequency
    end

    if depth then
        depth = _depth
    end

    local payload = {
        ['tremolo'] = {
            ['frequency'] = frequency,
            ['depth'] = depth
        }
    }

    return payload
end

function vibrato(_frequency, _depth)
    local frequency = 2.0
    local depth = 0.5

    if _frequency then
        frequency = frequency
    end

    if depth then
        depth = _depth
    end

    local payload = {
        ['vibrato'] = {
            ['frequency'] = frequency,
            ['depth'] = depth
        }
    }

    return payload
end

function rotation(_hertz)
    local hertz = 5

    if _hertz then
        hertz = _hertz
    end

    local payload = {
        ['rotation'] = {
            ['rotationHz'] = hertz
        }
    }

    return payload
end

function channel_mix(_left_to_left, _right_to_right, _left_to_right, _right_to_left)
    local left_to_left = 1
    local right_to_right = 1
    local left_to_right = 0
    local right_to_left = 0

    if _left_to_left then
        left_to_left = _left_to_left
    end

    if _right_to_right then
        right_to_right = _right_to_right
    end

    if _left_to_right then
        left_to_right = _left_to_right
    end

    if _right_to_left then
        right_to_left = _right_to_left
    end

    local payload = {
        ['channelMix'] = {
            ['leftToLeft'] = left_to_left,
            ['leftToRight'] = left_to_right,
            ['rightToLeft'] = right_to_left,
            ['rightToRight'] = right_to_right

        }
    }

    return payload
end

function distortion(_sin_offset, _sin_scale, _cos_offset, _cos_scale, _tan_offset, _tan_scale, _offset, _scale)
    local sin_offset = 0
    local sin_scale = 1
    local cos_offset = 0
    local cos_scale = 1
    local tan_offset = 0
    local tan_scale = 1
    local offset = 0
    local scale = 1

    if _sin_offset then
        sin_offset = _sin_offset
    end

    if _sin_scale then
        sin_scale = _sin_scale
    end

    if _cos_offset then
        cos_offset = _cos_offset
    end

    if _cos_scale then
        cos_scale = _cos_scale
    end

    if _tan_offset then
        tan_offset = _tan_offset
    end

    if _tan_scale then
        tan_scale = _tan_scale
    end

    if _offset then
        offset = _offset
    end

    if _scale then
        scale = _scale
    end

    local payload = {
        ['distortion'] = {
            ['sinOffset'] = sin_offset,
            ['sinScale'] = sin_scale,
            ['cosOffset'] = cos_offset,
            ['cosScale'] = cos_scale,
            ['tanOffset'] = tan_offset,
            ['tanScale'] = tan_scale,
            ['offset'] = offset,
            ['scale'] = scale

        }
    }

    return payload
end

function low_pass(_smoothing)
    local smoothing = 20

    if _smoothing then
        smoothing = _smoothing
    end

    local payload = {
        ['lowPass'] = {
            ['smoothing'] = smoothing
        }
    }

    return payload
end

return {
    equalizer = equalizer,
    timescale = timescale,
    karaoke = karaoke,
    tremolo = tremolo,
    vibrato = vibrato,
    rotation = rotation,
    channel_mix = channel_mix,
    distortion = distortion,
    low_pass = low_pass
}
