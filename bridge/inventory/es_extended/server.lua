local inventory = {}

function inventory.getInv(src)
    local Player  = ESX.GetPlayerFromId(src)
    return Player.inventory
end

function inventory.CreateUseableItem(item, func)
    ESX.RegisterUsableItem(item, func)
end

return inventory