function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function interp(s, tab)
    return (s:gsub('%%%((%a%w*)%)([-0-9%.]*[cdeEfgGiouxXsq])',
        function(k, fmt)
            return tab[k] and ("%" .. fmt):format(tab[k]) or
                '%(' .. k .. ')' .. fmt
        end))
end

function split(str, character)
    local result = {}

    local index = 1
    for s in string.gmatch(str, "[^" .. character .. "]+") do
        result[index] = s
        index = index + 1
    end

    return result
end

function valueintb(tb, value)
    local found = nil
    for _, v in pairs(tb) do
        if v == value then
            found = v
        end
    end
    if found then
        return true
    else
        return false
    end
end

function escape(s)
    return (string.gsub(s, "([^A-Za-z0-9_])", function(c)
        return string.format("%%%02x", string.byte(c))
    end))
end

function starts_with(str, start)
    return str:sub(1, #start) == start
end

function shift(tb)
    local shifted = table.remove(tb, 1)
    for i = 1, #tb do
        tb[i] = tb[i + 1]
    end
    tb[#tb] = nil
    return shifted
end

function randval(tb)
    return tb[math.random(1, #tb)]
end

function trim(str)
    return string.match(str, '^%s*(.-)%s*$')
end

return {
    dump = dump,
    interp = interp,
    split = split,
    valueintb = valueintb,
    escape = escape,
    starts_with = starts_with,
    shift = shift,
    trim = trim
}
