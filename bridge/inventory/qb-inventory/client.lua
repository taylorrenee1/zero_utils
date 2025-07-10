if not QBCore then QBCore = zutils.core_loader("QBCore") end

local core = {}

local inventory = {}

function inventory.hasItem(items, amount, metadata)
    local amount, count = amount or 1, 0
    for _, itemData in pairs(core.getPlayerData().items) do
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
