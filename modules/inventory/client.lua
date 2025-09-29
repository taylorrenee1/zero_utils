local inventory = zutils.bridge_loader("inventory")
if not inventory then return end

zutils.inventory = {}

function zutils.inventory.openInventory(inv_type, id)
    assert(inv_type, "Inventory must be specified")
    assert(id, "Inventory ID must be specified")
    if inv_type == "personal_stash" then
        local allowed = zutils.callback.await("zutils:inventory:registerPersonalStash:"..zutils.name, nil, id)
        if not allowed then
            return
        end
        id = id .. zutils.player.getPlayerId()
        inv_type = "stash"
    end
    inventory.openInventory(inv_type, id)
end

zutils.inventory.OpenInventory = zutils.inventory.openInventory -- Alias for compatibility

function zutils.inventory.hasItem(item, count, metadata)
    return inventory.hasItem(item, count, metadata)
end
zutils.inventory.HasItem = zutils.inventory.hasItem -- Alias for compatibility

function zutils.inventory.getItemInfo(item)
    return inventory.getItemInfo(item)
end


return zutils.inventory