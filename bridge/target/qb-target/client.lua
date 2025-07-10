local target = {}

local activeTargets = {}

local function formatOptions(options)
    local distance
    if options.distance then
        distance = options.distance
        options = options.options or options[1]
    end
    for _, option in pairs(options) do
        option.distance = option.distance or distance
        option.onSelect = option.onSelect or option.action
        option.items = option.items or option.item
        option.name = option.name or option.label

        if option.job or option.gang then
            local group = {}
            for _, val in pairs(option.job or {}) do group[#group+1] = val end
            for _, val in pairs(option.gang or {}) do group[#group+1] = val end
            option.groups = group
        end
    end
    return options
end
