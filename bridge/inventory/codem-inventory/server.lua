local inventory = {}

function inventory.getInv(src)
    local plyrinv = exports["codem-inventory"]:GetInventory(core.getPlayer(src).citizenId, src)
    return plyrinv or {}
end


return inventory