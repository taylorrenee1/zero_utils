local qb_inventory = exports['qb-inventory']
local inventory = {}
local stashes = {}

function inventory.createUseableItem(item, func)
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

        if not (table.contains(stash.groups, player_job) or table.contains(stash.groups, player_gang)) then
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

function inventory.getInv(inv)
    local inven = qb_inventory:GetInventory(inv)
    if not inven then return false end

    return inven.items
end

function inventory.getAvailableWeight(inv)
    if tonumber(inv) then
        return qb_inventory:GetFreeWeight(inv)
    end

    local check_inv = qb_inventory:GetInventory(inv)
    if check_inv then
        return check_inv.maxWeight - qb_inventory:GetTotalWeight(inv)
    else
        return 0
    end
end

function inventory.getAvailableSlots(inv)
    local _, abailable_slots = qb_inventory:GetSlots(inv)
    return abailable_slots
end

function inventory.canCarryItem(src, item, count, metadata)
    if metadata then
        printwarn("Metadata search is not supported in qb-inventory bridge at this time")
    end
    local available_weight = inventory.getAvailableWeight(src)
    local item_info = inventory.getItemInfo(item)

    if not item_info then
        return false, "Item does not exist: " .. item
    end

    local total_weight_needed = item_info.weight * (count or 1)
    if available_weight < total_weight_needed then
        return false, "Inventory Cannot carry: " .. item
    end

    return true
end

function inventory.addItem(inv, item, count, metadata, slot, cb)
    if cb then printwarn("Callback is not supported in qb-inventory bridge") end

    local result = qb_inventory:AddItem(inv, item, count, slot, metadata or false, zutils.name .. " add item")

    if not result then
        return false, "Inventory AddItem failed: " .. item
    end

    if tonumber(inv) then
        TriggerClientEvent('qb-inventory:client:ItemBox', inv, QBCore.Shared.Items[item], "add", count)
        Wait(100)
    end

    return result
end

function inventory.removeItem(inv, item, count, metadata, slot)
    if metadata then
        printwarn("Metadata search is not supported in qb-inventory bridge at this time")
    end
    local result = qb_inventory:RemoveItem(inv, item, count, slot, zutils.name .. " remove item")

    if not result then
        return false, "Inventory RemoveItem failed: " .. tostring(item)
    end

    if tonumber(inv) then
        TriggerClientEvent('qb-inventory:client:ItemBox', inv, QBCore.Shared.Items[item], "remove", count)
    end

    return true
end

function inventory.hasItem(inv, item, count, metadata)
    if metadata then
        printwarn("Metadata search is not supported in qb-inventory bridge at this time")
    end
    if tonumber(inv) then
        local result = qb_inventory:HasItem(inv, item, count)
        if result then
            return true
        end
        return false, "You do not have enough: " .. item
    end
    local inven = inventory.getInv(inv)
    if not inven then
        return false, "You do not have enough: " .. item
    end

    local total_found = 0
    for _, v in pairs(inven) do
        if v.name == item then
            total_found = total_found + v.amount
        end
        if total_found >= count then
            return true
        end
    end

    return false, "You do not have enough: " .. item
end

return inventory
