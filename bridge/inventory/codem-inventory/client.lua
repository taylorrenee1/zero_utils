local inventory = {}

function inventory.getInv()
    local Inventory = exports["codem-inventory"]:getUserInventory()
    return Inventory or {}
end

function inventory.hasItem(item, count, metadata)
    local playerInv = inventory.getInv()
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

function inventory.getItemImage(item)
    return 'https://cfx-nui-codem-inventory/html/images/'..item..'.png'
end

return inventory