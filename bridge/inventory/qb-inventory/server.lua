local qb_inventory = exports['qb-inventory']
local inventory = {}
local stashes = {}

function inventory.CreateUseableItem(item, func)
    return QBCore.Functions.CreateUseableItem(item, func)
end

function inventory.getItemInfo(item)
    local qb_item = QBCore.Shared.Items[item]
    if not qb_item then
        return false, "Item does not exist: " .. item
    end
    return {
        name = qb_item.name,
        label = qb_item.label,
        image = qb_item.image,
        description = qb_item.description,
        weight = qb_item.weight,
        stackable = qb_item.stackable,
        metadata = qb_item.metadata or {},
    }
end

function inventory.registerStash(id, label, slots, max_weight, owner, groups, coords)
    stashes[id] = {
        label = label,
        slots = slots,
        max_weight = max_weight,
        owner = owner,
        groups = groups,
        coords = coords
    }
end

RegisterNetEvent('zero_utils:server:qb-inventory:OpenInventory', function(inv_type, id)
    local src = source
    if inv_type == 'stash' and stashes[id] then
        local stash = stashes[id]
        if not stash then
            printerr("Stash not found: " .. id)
        end

        local player_job = zutils.player.getJob(src).name or nil
        local player_gang = zutils.player.getGang(src).name or nil

        if type(stash.groups) == "string" then
            stash.groups = { stash.groups }
        end

        if not (table.contains(stash.groups, player_job) or table.contains(stash.groups, player_gang) )then
            return
        end

        if stash.coords then
            local player_coords = GetEntityCoords(GetPlayerPed(src))
            if #(player_coords - stash.coords) > 5.0 then
                return
            end
        end

        qb_inventory:OpenInventory(src, id, {
            label = stash.label,
            slots = stash.slots,
            max_weight = stash.max_weight,
        })
    end
end)

function shops.registerShop(id, coords, label, items, society)
    local storeData = {
        name = id,
        coords = coords,
        label = label,
        items = items,
        society = society,
    }
    return exports['qb-inventory']:CreateShop(storeData)
end

function shops.openShop(id)
    return exports['qb-inventory']:OpenShop(source, id)
end

function inventory.getInv(src)
    local PlayerInv = QBCore.Functions.GetPlayer(src).PlayerData.items
    if not PlayerInv then
        return {}
    end
    return PlayerInv
end

function inventory.hasItem(src, item, count, metadata)
    local PlayerInv = inventory.getInv(src)
    if not PlayerInv then
        return false, "You do not have enough: " .. item
    end

    local result = 0
    for _, v in pairs(PlayerInv) do
        if v.name == item and (not metadata or v.info.metadata == metadata) then
            result = result + v.amount
        end
    end

    if result >= (count or 1) then return true end
    return false, "You do not have enough: " .. item
end

return inventory