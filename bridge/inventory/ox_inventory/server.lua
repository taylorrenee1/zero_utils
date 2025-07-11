local ox_inventory = exports.ox_inventory
local inventory = {}

function inventory.getItemInfo(item)
    local ox_item = ox_inventory:Items(item)
    if not ox_item then
        return false, "Item does not exist: " .. item
    end
    return {
        name = ox_item.name,
        label = ox_item.label,
        description = ox_item.description,
        weight = ox_item.weight,
        stackable = ox_item.stackable,
        metadata = ox_item.metadata or {},
    }
end

function inventory.addItem(inv, item, count, metadata, slot, cb)
    return ox_inventory:AddItem(inv, item, count, metadata, slot, cb)
end

function inventory.removeItem(inv, item, count, metadata, slot, cb)
    return ox_inventory:RemoveItem(inv, item, count, metadata, slot, cb)
end

function inventory.canCarryItem(inv, item, count, metadata)
    if not ox_inventory:CanCarryItem(inv, item, count, metadata) then
        return false, "Inventory Cannot carry: " .. item
    end
    return true
end

function inventory.hasItem(inv, item, count, metadata)
    local result = exports.ox_inventory:Search(inv, 'count', item, metadata)
    if result >= (count or 1) then return true end
    return false, "You do not have enough: " .. item
end

function inventory.registerStash(id, label, slots, max_weight, owner, groups, coords)
    return ox_inventory:RegisterStash(id, label, slots, max_weight, owner, groups, coords)
end

function inventory.forceOpenInventory(source, inv, id)
    return ox_inventory:forceOpenInventory(source, inv, id)
end

function inventory.getAvailableWeight(inv, owner)
    local check_inv = ox_inventory:GetInventory(inv, owner)
    return check_inv and (check_inv.maxWeight -check_inv.weight) or 0
end

function inventory.getAvailableSlots(inv, owner)
    local check_inv = ox_inventory:GetInventory(inv, owner)
    return check_inv and (check_inv.slots - #check_inv.items) or 0
end

function inventory.registerShop(id, coords, label, items, society)
    return ox_inventory:RegisterShop(id, {
        name = label,
        inventory = items,
        locations = coords or nil,
        groups = society or nil,
    })
end


return inventory
