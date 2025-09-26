if not Config.Bridge then Config.Bridge = {} end

local default_bridges = {
    core = {
        "qb-core",
        "ox_core",
        "qbx_core",
        "es_extended"
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
    },
    job = {
        "qb-core",
        "qbx-core",
        "es_extended",
        "ox_core",
    },
    notify = {
        'qb-notify',
        'jixel-notify',
        'ox_lib',
        'okokNotify',
        'esx_notify'
    },
    callback = {
        "ox_lib",
        "qb-core",
        "qbx-core",
        "es_extended"
    },
    progressbar = {
        "progressbar",
        "ox_lib",
        "esx_progressbar"
    },
    target = {
        "ox_target",
        "qb-target"
    },
    menu = {
        "ox_lib",
        "qb-menu",
        "jim-menu",
        "esx_menu"
    },
    shop = {
        "ox_inventory",
        "qb-inventory",
    },
    bossmenu = {
        "qb_management",
        "qbx_management",
    },
    keys = {
        "dusa_vehiclekeys"
    },
    emote = {
        "rpemotes",
        "rpemotes-reborn",
        "dpemotes",
        "emotes"
    },
}

local bridge_aliases  = {
    inventory = {
        ox = "ox_inventory",
        qb = "qb-inventory",
        qs = "qs-inventory",
    },
    core = {
        qb = "qb-core",
        qbx = "qbx_core",
        esx = "es_extended",
        ox = "ox_core",
    },
    banking = {
        fd = "fd_banking",
    },
    notify = {
        ox = "ox_lib",
        jixel = "jixel-notify",
        qb = "qb-notify",
        okok = "okokNotify",
        esx = "esx_notify",
    },
    callback = {
        ox = "ox_lib",
        qb = "qb-core",
        qbx = "qbx-core",
        esx = "es_extended"
    },
    target = {
        ox = "ox_target",
        qb = "qb-target",
    },
    shop = {
        ox = "ox_inventory",
        qb = "qb-inventory",
    },
    keys = {
        dusa = "dusa_vehiclekeys"
    },
    emotes = {
        rpe = "rpemotes",
        rpe_reborn = "rpemotes-reborn",
        dpe = "dpemotes",
        emotes = "emotes"
    },
    menu = {
        ox = "ox_lib",
        qb = "qb-menu",
        jim = "jim-menu",
        esx = "esx_menu"
    },
    progressbar = {
        ox = "ox_lib",
        qb = "progressbar",
        ps = "ps-ui",
        esx = "esx_progressbar"
    },
    bossmenu = {
        qb = "qb-management",
        qbx = "qbx_management",
    }
}

local virtual_bridges = {
    esx_menu = { 'esx_menu_default', 'esx_menu_dialog', 'esx_menu_list' }
}

local function resolve_bridge_alias(module_name, bridge_resource)
    local aliases = bridge_aliases[module_name]
    if aliases and aliases[bridge_resource] then
        return aliases[bridge_resource]
    end
    return bridge_resource
end

local function is_bridge_started(bridge_key)
    local deps = virtual_bridges[bridge_key]
    if deps then
        for _, r in ipairs(deps) do
            if zutils.isResourceStarted(r) then
                return true
            end
        end
        return false
    end
    return zutils.isResourceStarted(bridge_key)
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
        if is_bridge_started(resolved_bridge) then
            printdb("Found active bridge: %s for module: %s in context: %s", resolved, module_name, context)
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
    printdb("Attempting to load bridge for module: %s in context: %s", module_name, context or zutils.context)
    context = context or zutils.context
    module_name = module_name:gsub("^%l", string.lower)

    local bridge_resource = find_active_bridge(module_name, context)
    if not bridge_resource then
        printerr("No active bridge found for module: %s in context: %s", module_name, context)
        return nil
    end

    if not virtual_bridges[bridge_resource] and not zutils.isResourceStarted(bridge_resource) then
        if zutils.isResourceMissing(bridge_resource) then
            printerr("Bridge[%s]: resource(%s) missing. Please rename bridge file to resource name or change config to correct bridge",
                module_name, bridge_resource)
            return nil
        end
        printerr("Bridge[%s]: resource(%s) is not started yet. you may be trying to call this too early", module_name, bridge_resource)
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