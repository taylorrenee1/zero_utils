local inventory = {}


function inventory.getInv(src)
    local PlayerInv = exports['qs-inventory']:GetInventory(src)
    if not PlayerInv then
        return {}
    end
    return PlayerInv
end

return inventory