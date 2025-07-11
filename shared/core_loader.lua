local debug_print = false

local Core = {}

local loaded_cores = {}
local loading_cores = {}
local core_definitions = {
    QBCore = {
        resource = "qb-core",
        loader = function()
            if not next(Core) then
                Core = exports['qb-core']:GetCoreObject()
            end
            return Core
        end
    },
    qbx_core = {
        resource = "qbx-core",
        loader = function()
            if not next(Core) then
                Core = exports['qbx-core']:GetCoreObject()
            end
            return Core
        end
    },
    ESX = {
        resource = "es_extended",
        loader = function()
            if not next(Core) then
                Core = exports.es_extended:getSharedObject()
            end
            return Core
        end
    },
    ox_lib = {
        resource = "ox_lib",
        ignore_source = '@@ox_lib/init.lua',
        loader = function()
            if lib then return lib end
            local chunk = LoadResourceFile("ox_lib", "init.lua")
            if not chunk then
                printerr("Failed to load ox_lib: Resource file not found")
                return nil
            end

            local fn, err = load(chunk, '@ox_lib/init.lua')
            if not fn then
                printerr("Failed to load ox_lib: %s", err)
                return nil
            end

            fn()
            return lib
        end
    },
}

function zutils.core_loader(core_name)
    if loaded_cores[core_name] then
        return loaded_cores[core_name]
    end

    if loading_cores[core_name] then
        printdb(debug_print, "Core %s is already being loaded, preventing infinite loop", core_name)
        return nil
    end

    local core_def = core_definitions[core_name]
    if not core_def then
        printdb(debug_print, "No core definition found for: %s", core_name)
        return nil
    end
    printdb(debug_print, "Loading core: %s %s", core_name, core_def.resource)
    if not zutils.isResourceStarted(core_def.resource) then
        printdb(debug_print, "Core resource %s is not started", core_def.resource)
        return nil
    end

    local sources = debug.getinfo(3, 'S')
    printdb(debug_print, "[%s] Loading Core from %s...", core_name, sources.source or "unknown")
    loading_cores[core_name] = true
    if core_def.ignore_source then
        if sources.source == core_def.ignore_source then
            -- printdb(true, "Ignoring load request from %s", sources.source)
            loading_cores[core_name] = nil
            return nil
        end
    end
    
    local success, core = pcall(core_def.loader)

    loading_cores[core_name] = nil

    if not success then
        printerr("[%s] Failed to load core: %s", core_name, core)
        return nil
    end

    if not core then
        printerr("[%s] Core loaded but returned nil", core_name)
        return nil
    end
    loaded_cores[core_name] = core
    printdb(debug_print, "[%s] Successfully loaded core", core_name)
    return core
end

if not zutils.isResourceMissing("qb-core") then
    if not zutils.isResourceStarted("qb-core") then
        printerr("QBCore is not started, please ensure that qb-core is ensure before this script is.")
    end
    if QBCore then return end
    QBCore = {}
    setmetatable(QBCore, {
        __index = function(self, key)
            return Core[key] or zutils.core_loader("QBCore")[key]
        end,
        __call = function(self, ...)
            return Core(...)
        end
    })
end

return zutils.core_loader