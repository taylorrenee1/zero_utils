local inventory = {}



function inventory.getInv(src)
    local PlayerInv = exports['qs-inventory']:getUserInventory(src)
    if not PlayerInv then
        return {}
    end
    return PlayerInv
end

return inventory