local inventory = {}

function inventory.getInv()
    local PlayerInv = exports["core_inventory"]:getInventory()
    if not PlayerInv then
        return {}
    end
    return PlayerInv
end


return inventory