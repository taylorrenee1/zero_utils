local ox_inventory = exports.ox_inventory
local shop = {}

function shop.registerShop(id, options)
    ox_inventory:RegisterShop(id, {
        name =  options.label or "Shop",
        inventory = options.inventory,
        groups = options.groups,
    })
end

return shop