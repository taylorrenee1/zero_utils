local inventory = {}

function inventory.getInv(src)
    local PlayerInv = exports["origen_inventory"]:getInventory(src)
    if not PlayerInv then
        return {}
    end
    return PlayerInv
end


return inventory