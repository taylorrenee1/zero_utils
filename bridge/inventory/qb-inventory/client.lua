local qb_inventory = exports['qb-inventory']
local inventory = {}

function inventory.hasItem(items, amount, metadata)
    local amount, count = amount or 1, 0
    for _, itemData in pairs(QBCore.Functions.GetPlayerData().items) do
        if itemData and (itemData.name == items) then
            printdb("HasItem: Item: %s Slot: %s x(%s)", tostring(items), itemData.slot, tostring(itemData.amount))
            count += (itemData.amount or 1)
        end
    end
    if count >= amount then
        printdb("HasItem: FOUND %s / %s %s", count, amount, tostring(items))
        return true
    else
        printwarn("HasItem: Items %s NOT FOUND", tostring(items))
        return false
    end
end

function inventory.getItemImage(item)
    return 'https://cfx-nui-qb-inventory/html/images/'..item..'.png'
end
function inventory.getInv()
    local PlayerInv = QBCore.Functions.GetPlayerData().items
    if not PlayerInv then
        return {}
    end
    return PlayerInv
end

function inventory.getItemInfo(item)
    local qb_item = QBCore.Shared.Items[item]
    if not qb_item then
        return false, "Item does not exist: " .. item
    end
    return {
        name = qb_item.name,
        label = qb_item.label,
        image = qb_item.image,
        description = qb_item.description,
        weight = qb_item.weight,
        stackable = qb_item.stackable,
        metadata = qb_item.metadata or {},
    }
end

function inventory.openInventory(inv_type, id)
    TriggerServerEvent("zero_utils:server:qb-inventory:OpenInventory", inv_type, id)
end

return inventory