local ox_inventory = exports.ox_inventory
local inventory = {}

local _useables = {}
local _exportName = ("%s.ox_useable"):format(GetCurrentResourceName())


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
function inventory.getInv(src)
    local PlayerInv = ox_inventory:GetInventoryItems(src)
    if not PlayerInv then
        return {}
    end
    return PlayerInv
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

exports('ox_useable', function(source, item, slot)
    local name = type(item) == 'table' and (item.name or item?.name) or item
    local cb = name and _useables[name]
    if not cb then return false end

    -- normalize item table for callback parity with QB/ESX
    local itemTbl = type(item) == 'table' and item or { name = name, slot = slot }
    local ok, err = pcall(cb, source, itemTbl)
    if not ok then
        print(('[zutils:ox] useable "%s" errored: %s'):format(name, err))
        return false
    end
    return true
end)

local function _attachExport(name)
    local Items = exports.ox_inventory:Items()
    local def = (type(Items) == 'table' and Items[name]) or exports.ox_inventory:Items(name)
    if not def then
        print(('[zutils:ox] warn: item not found in ox items: %s'):format(name))
        return false
    end
    def.server = def.server or {}
    def.server.export = _exportName
    return true
end

function inventory.createUseableItem(itemName, cb)
    if type(itemName) ~= 'string' or type(cb) ~= 'function' then
        printerr('[zutils:ox] createUseableItem requires (string, function)')
        return false
    end
    if not _attachExport(itemName) then return false end
    _useables[itemName] = cb
    return true
end



return inventory
