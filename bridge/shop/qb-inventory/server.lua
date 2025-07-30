local inventory = exports['qb-inventory']

local shop = {}

local function formatItems(items)
    for _, item in pairs(items) do
        if item.count then
            item.amount = item.count
            item.count = nil
        end
    end
    return items
end

function shop.registerShop(id, options)
    inventory:CreateShop({
        name = id,
        label = options.label or "Shop",
        coords = options.coords,
        items = formatItems(options.inventory),
        slots = #options.inventory,
        society = options.society,
    })
end

RegisterNetEvent("zero_utils:server:qb-inventory:OpenShop", function(id)
    local src = source
    if id then
        inventory:OpenShop(src, id)
    end
end)

--[[ function shop.registerShop(id, coords, label, items, society)
    local storeData = {
        name = id,
        coords = coords,
        label = label,
        slots = #items,
        items = items,
        society = society,
    }
    return exports['qb-inventory']:CreateShop(storeData)
end ]]

function shop.openShop(id)
    return exports['qb-inventory']:OpenShop(source, id)
end

return shop