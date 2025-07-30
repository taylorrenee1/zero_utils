local ox_inventory = exports.ox_inventory
local shop = {}

function shop.openShop(id, loc_id)
    ox_inventory:openInventory("shop", {type = id})
end

return shop