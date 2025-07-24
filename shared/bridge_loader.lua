if not Config.Bridge then Config.Bridge = {} end

local default_bridges = {
    core = {
        "qb-core",
        "ox_core",
    },
    banking = {
        "fd_banking",
    },
    inventory = {
        "ox_inventory",
        "qb-inventory",
        "codem-inventory",
        "core_inventory",
        "origen_inventory",
        "qs-inventory",
        "es_extended"
    },
    notify = {
        'jixel-notify',
        'ox_lib',
    },
    callback = {
        "ox_lib",
        "qb-core",
    },
    progressbar = {
        "progressbar",
        "ox_lib",
    },
    target = {
        "ox_target",
    },
    menu = {
        "ox_lib",
    },
}

local bridge_aliases  = {
    inventory = {
        ox = "ox_inventory",
        qb = "qb-inventory",
    },
    banking = {
        fd = "fd_banking",
    },
    notify = {
        ox = "ox_lib",
        jixel = "jixel-notify",
    },
    callback = {
        ox = "ox_lib",
        qb = "qb-core",
    },
    target = {
        ox = "ox_target",
    },
}

local function resolve_bridge_alias(module_name, bridge_resource)
    local aliases = bridge_aliases[module_name]
    if aliases and aliases[bridge_resource] then
        return aliases[bridge_resource]
    end
    return bridge_resource
end

local function find_active_bridge(module_name, context)
    if Config.Bridge[module_name] then return resolve_bridge_alias(module_name, Config.Bridge[module_name]) end
    local bridges = default_bridges[module_name]
    if not bridges then
        printerr("No default bridges found for module: %s", module_name)
        return nil
    end

    for _, bridge_resource in ipairs(bridges) do
        local resolved_bridge = resolve_bridge_alias(module_name, bridge_resource)
        if zutils.isResourceStarted(resolved_bridge) then
            printdb("Found active bridge: %s for module: %s in context: %s", resolved_bridge, module_name, context)
            return resolved_bridge
        end
    end

    printerr("No active bridge found for module: %s in context: %s", module_name, context)
    return nil
end

local function bridge_loader(module_name, context)
    while not zutils.initialized do
        Wait(100)
    end
    context = context or zutils.context
    module_name = module_name:gsub("^%l", string.lower) -- Ensure module name is lowercase

    local bridge_resource = find_active_bridge(module_name, context)
    if not bridge_resource then
        printerr("No active bridge found for module: %s in context: %s", module_name, context)
        return nil
    end

    if not zutils.isResourceStarted(bridge_resource) then
        if zutils.isResourceMissing(bridge_resource) then
            printerr(
                "Bridge[%s]: resource(%s) missing. Please rename bridge file to resource name or change config to correct bridge",
                module_name, bridge_resource)
            return nil
        end
        printerr("Bridge[%s]: resource(%s) is not started yet. you may be trying to call this to early", module_name, bridge_resource)
        return nil
    end

    local bridge_path = ("bridge/%s/%s/%s.lua"):format(module_name, bridge_resource, zutils.context)

    printdb("Loading bridge: %s for module: %s", bridge_path, module_name)

    local bridge = zutils.require(bridge_path)
    if not bridge then
        printerr("Bridge '%s' not found at path: '%s'", module_name, bridge_path)
        return nil
    end

    printdb("Successfully loaded bridge: %s", bridge_path)
    return bridge
end

zutils.bridge_loader = bridge_loader

return zutils.bridge_loader
