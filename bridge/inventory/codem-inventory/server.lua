local inventory = {}

function inventory.getInv(src)
    local plyrinv = exports["codem-inventory"]:GetInventory(core.getPlayer(src).citizenId, src)
    return plyrinv or {}
end

function inventory.hasItem(src, item, count, metadata)
    local playerInv = inventory.getInv(src)
    local required = count or 1
    local found = 0

    for _, v in pairs(playerInv) do
        if v.name == item and (not metadata or v.metadata == metadata) then
            found = found + (v.count or v.amount or 1)
        end
    end

    if found >= required then
        return true
    else
        return false, ("You do not have enough: %s"):format(item)
    end
end


return inventory