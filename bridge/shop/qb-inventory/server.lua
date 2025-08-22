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
    })
end

RegisterNetEvent("zero_utils:server:qb-inventory:OpenShop", function(id)
    local src = source
    if id then
        inventory:OpenShop(src, id)
    end
end)

return shop