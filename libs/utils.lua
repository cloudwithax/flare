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

function random_value(tb)
    local values = {}
    for k, v in pairs(tb) do table.insert(values, v) end
    print(values.index)
    return tb[values[math.random(#values)]]
end

function random_key(tb)
    local keys = {}
    for k in pairs(tb) do table.insert(keys, k) end
    return tb[keys[math.random(#keys)]]
end

return {
    dump = dump,
    interp = interp,
    split = split,
    random_value = random_value,
    random_key = random_key
}
