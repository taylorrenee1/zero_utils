-- bridge/callback/es_extended/server.lua
local ESX = zutils.core_loader('ESX')

local callback = {}


callback.trigger = function(name, src, cb, ...)
    printdb("Triggering Client Callback %s -> %s", name, tostring(src))
    ESX.TriggerClientCallback(src, name, function(...)
        cb(...)
    end, ...)
end

callback.register = function(name, fn)
    printdb("Registering Callback %s", name)
    ESX.RegisterServerCallback(name, function(src, cb, ...)
        local results = { fn(src, ...) }
        cb(table.unpack(results))
    end)
end

callback.await = function(name, src, ...)
    printdb("Awaiting Client Callback %s -> %s", name, tostring(src))
    local result = { ESX.AwaitClientCallback(src, name, ...) }
    return table.unpack(result)
end

return callback
