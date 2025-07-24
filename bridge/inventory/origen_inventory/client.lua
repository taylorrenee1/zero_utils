local inventory = {}

function inventory.getInv()
    local PlayerInv = exports["origen_inventory"]:getInventory()
    if not PlayerInv then
        return {}
    end
    return PlayerInv
end

return inventory