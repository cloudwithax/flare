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

return {
    dump = dump,
    interp = interp,
    split = split
}
