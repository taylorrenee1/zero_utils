local ox_inventory = exports.ox_inventory
local inventory = {}

function inventory.getItemInfo(item)
    local ox_item = ox_inventory:Items(item)
    if not ox_item then
        return false, "Item does not exist: " .. item
    end
    return {
        name = item,
        label = ox_item.label,
        image = ox_item.client and ox_item.client.image or ox_item.name .. ".png",
        description = ox_item.description,
        weight = ox_item.weight,
        stackable = ox_item.stack,
        metadata = ox_item.metadata or {},
    }
end

function inventory.getInv()
    local PlayerInv = ox_inventory:GetPlayerItems()
    if not PlayerInv then
        return {}
    end
    return PlayerInv
end

function inventory.hasItem(item, count, metadata)
    local result = ox_inventory:Search("count", item, metadata)
    local amount = count or 1
    if result >= amount then
        return true
    end

    return false, "You do not have enough: " .. item
end

function inventory.openInventory(inv_type, id)
    ox_inventory:openInventory(inv_type, id)
end

function inventory.Image(item)
    return 'https://cfx-nui-ox_inventory/web/images/'..item..'.png'
end

return inventory