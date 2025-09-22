local function contains(t, search)
    if type(search) == "table" then
        for _, v in ipairs(search) do
            if not contains(t, v) then
                return false
            end
        end
        return true
    end

    if t[search] then
        return true
    end

    for _, v in ipairs(t) do
        if v == search then
            return true
        end
    end
    return false
end

local function count(table)
    local i = 0
    for _ in pairs(table) do
        i = i + 1
    end
    return i
end

local function isArray(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

local function combine(t1, t2)
    local combined = {}
    if isArray(t1) and isArray(t2) then
        for _, v in ipairs(t1) do
            table.insert(combined, v)
        end
        for _, v in ipairs(t2) do
            table.insert(combined, v)
        end
    else
        for k, v in pairs(t1) do
            combined[k] = v
        end
        for k, v in pairs(t2) do
            combined[k] = v
        end
    end
    return combined
end


table.isArray = isArray
table.contains = contains
table.count = count
table.combine = combine