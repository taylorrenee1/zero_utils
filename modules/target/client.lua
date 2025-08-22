local target = zutils.bridge_loader("target", "client")
if not target then return end

local targets = {}

zutils.target = {}

function zutils.target.addBoxZoneTarget(id, coords, size, options)
    targets[#targets+1] = target.addBoxZoneTarget(id, coords, size, options)
end

zutils.target.AddBoxZoneTarget = zutils.target.addBoxZoneTarget -- Alias for compatibility

function zutils.target.addEntityTarget(entities, options)
    targets[#targets+1] = target.addEntityTarget(entities, options)
end
zutils.target.AddEntityTargets = zutils.target.addEntityTarget -- Alias for compatibility

function zutils.target.addNetIDTarget(netID, options)
    targets[#targets+1] = target.addNetIDTarget(netID, options)
end
zutils.target.AddNetIDTarget = zutils.target.addNetIDTarget -- Alias for compatibility

function zutils.target.removeNetIDTarget(netId, options)
    targets[#targets+1] = target.removeNetIDTarget(netId, options)
end
zutils.target.RemoveEntityTarget = zutils.target.removeNetIDTarget -- Alias for compatibility

function zutils.target.addModelTarget(mode, options)
    targets[#targets+1] = target.addModelTarget(mode, options)
end
zutils.target.AddModelTarget = zutils.target.addModelTarget -- Alias for compatibility

function zutils.target.removeModelTarget(model, options)
    targets[#targets+1] = target.removeModelTarget(model, options)
end
zutils.target.RemoveModelTarget = zutils.target.removeModelTarget -- Alias for compatibility


AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, t in ipairs(targets) do
        if t and t.remove then
            t:remove()
        end
    end
end)

return zutils.target