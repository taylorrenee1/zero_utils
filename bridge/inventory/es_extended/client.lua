local inventory = {}

function inventory.getInv()
    local Player  = ESX.GetPlayerData() 
    return Player.inventory
end

function inventory.hasItem(items, amount, metadata)
    local amount, count = amount or 1, 0
    for _, itemData in pairs(QBCore.getPlayerData().items) do
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

return inventory