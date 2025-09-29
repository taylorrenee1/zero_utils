
local isOx = (GetResourceState and GetResourceState('ox_inventory') == 'started')
if not isOx then
    exports('ox_registerUseable', function(...) return false end)
    exports('ox_useable', function(...) end)
    return
end
local handlers = {} 

exports('ox_registerUseable', function(item, cb, opts)
    if type(item) ~= 'string' or type(cb) ~= 'function' then return false end
    local owner = GetInvokingResource() or GetCurrentResourceName()
    handlers[item] = handlers[item] or {}
    handlers[item][#handlers[item]+1] = { owner = owner, cb = cb, prio = (opts and opts.priority) or 0 }
    return true
end)

exports('ox_useable', function(event, oxItem, oxInv, slot, data)
    if event ~= 'usingItem' then return end
    local name = type(oxItem) == 'table' and oxItem.name or oxItem
    local list = handlers[name]; if not list or #list == 0 then return end
    table.sort(list, function(a,b) return (a.prio or 0) > (b.prio or 0) end)

    local src     = (oxInv and oxInv.id) or 0
    local itemTbl = (type(oxItem) == 'table') and oxItem or { name = name, slot = slot }

    for _, h in ipairs(list) do
        local ok, handled = pcall(h.cb, src, itemTbl, oxInv, slot, data)
        if not ok then
            print(('[zero_utils] handler error %s (%s): %s'):format(name, h.owner, handled))
        elseif handled == true then
            break
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    for k, list in pairs(handlers) do
        for i = #list, 1, -1 do
            if list[i].owner == res then table.remove(list, i) end
        end
        if not handlers[k] or #handlers[k] == 0 then handlers[k] = nil end
    end
end)
