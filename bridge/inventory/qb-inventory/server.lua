local inventory = {}

function inventory.CreateUseableItem(item, func)
    return QBCore.Functions.CreateUseableItem(item, func)
end

function shops.registerShop(id, coords, label, items, society)
    local storeData = {
        name = id,
        coords = coords,
        label = label,
        items = items,
        society = society,
    }
    return exports['qb-inventory']:CreateShop(storeData)
end

function shops.openShop(id)
    return exports['qb-inventory']:OpenShop(source, id)
end

function inventory.getInv(src)
    local PlayerInv = QBCore.Functions.GetPlayer(src).PlayerData.items
    if not PlayerInv then
        return {}
    end
    return PlayerInv
end

return inventory