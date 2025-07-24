local inventory = {}

function inventory.getInv()
    local PlayerInv = QBCore.Functions.GetPlayerData().items
    if not PlayerInv then
        return {}
    end
    return PlayerInv
end

return inventory