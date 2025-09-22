local inventory = {}


function inventory.getInv(src)
    local PlayerInv = QBCore.Functions.GetPlayer(src).PlayerData.items
    if not PlayerInv then
        return {}
    end
    return PlayerInv
end

function inventory.createUseableItem(item, func)
    return QBCore.Functions.CreateUseableItem(item, func)
end

return inventory