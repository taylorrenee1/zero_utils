local inventory = {}

function inventory.getInv()
    local Inventory = exports["codem-inventory"]:getUserInventory()
    return Inventory or {}
end

return inventory