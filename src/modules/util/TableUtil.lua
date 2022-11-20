local TableUtil = {}

function TableUtil:map(tbl, fn, ...)
    local t = {}
    for _, element in ipairs(tbl) do
        local _, result = pcall(fn, element, ...)
        table.insert(t, result)
    end
    return t
end

-- // http://lua-users.org/wiki/CopyTable
function TableUtil:deepCopy(orig)
    local origType = type(orig)
    local copy
    if origType == 'table' then
        copy = {}
        for origKey, origValue in next, orig, nil do
            copy[self:deepCopy(origKey)] = self:deepCopy(origValue)
        end
        setmetatable(copy, self:deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

return TableUtil