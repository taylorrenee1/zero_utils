local inventory = zutils.bridge_loader("inventory", "server")
if not inventory then return end

zutils.inventory = {}

local personal_stashes = {}

function zutils.inventory.getItemInfo(item)
    return inventory.getItemInfo(item)
end

function zutils.inventory.doesItemExist(item)
    local exists, err = inventory.getItemInfo(item)
    if not exists then
        printwarn("Item does not exist: %s", err)
        return false, err
    end
    return true
end

function zutils.inventory.getAvailableWeight(inv)
    return inventory.getAvailableWeight(inv)
end

function zutils.inventory.createUseableItem(itemName, cb)
    return inventory.createUseableItem(itemName, cb)
end

function zutils.inventory.addItem(inv, item, count, metadata, slot, cb)
    assert(item, "Item must be specified")
    count = count or 1

    if not zutils.inventory.doesItemExist(item) then
        return false, "Item does not exist: " .. item
    end

    if not zutils.inventory.canCarryItem(inv, item, count, metadata) then
        return false, "Inventory Cannot carry: " .. item
    end

    local result = inventory.addItem(inv, item, count, metadata, slot, cb)
    if not result then
        return false, "Inventory AddItem failed: " .. item
    end
    return true
end

zutils.inventory.AddItem = zutils.inventory.addItem -- Alias for compatibility

function zutils.inventory.removeItem(inv, item, count, metadata, slot, cb)
    assert(item, "Item must be specified")
    count = count or 1

    if not zutils.inventory.doesItemExist(item) then
        return false, "Item does not exist: " .. tostring(item)
    end

    if not zutils.inventory.hasItem(inv, item, count, metadata) then
        return false, "Inventory does not have item: " .. tostring(item)
    end

    local result = inventory.removeItem(inv, item, count, metadata, slot, cb)
    if not result then
        return false, "Inventory RemoveItem failed: " .. tostring(item)
    end
    return true
end

zutils.inventory.RemoveItem = zutils.inventory.removeItem -- Alias for compatibility

function zutils.inventory.canCarryItem(inv, item, count, metadata)
    return inventory.canCarryItem(inv, item, count, metadata)
end

function zutils.inventory.hasItem(inv, item, count, metadata)
    count = count or 1
    return inventory.hasItem(inv, item, count, metadata)
end

zutils.inventory.HasItem = zutils.inventory.hasItem -- Alias for compatibility

function zutils.inventory.registerStash(id, label, slots, max_weight, owner, groups, coords, is_personal)
    assert(id, "ID must be specified")
    assert(label, "Label must be specified")

    if is_personal then
        printdb( "Registering personal stash: %s", id)
        personal_stashes[id] = {
            label = label,
            slots = slots or 50,
            max_weight = max_weight or 1000000,
            owner = owner or nil,
            groups = groups or nil,
            coords = coords or nil
        }
        return
    end
    slots = slots or 50
    max_weight = max_weight or 1000000
    printdb( "Registering stash: %s with label: %s, slots: %s, max_weight: %s, owner: %s", id, label, slots, max_weight, owner)
    inventory.registerStash(id, label, slots, max_weight, owner, groups, coords)
end

zutils.inventory.RegisterStash = zutils.inventory.registerStash -- Alias for compatibility

function zutils.inventory.forceOpenInventory(source, inv, id)
    assert(source, "Source must be specified")
    assert(inv, "Inventory must be specified")
    return inventory.forceOpenInventory(source, inv, id)
end

function zutils.inventory.craftItem(src, items, ingredients, multicraft)
    printdb( "These are the items")
    printdb( "These are the ingredients")
    if type(items) == "string" then
        items = { { items, 1 } }
    elseif items[1] and type(items[1]) == "string" then
        items = { items }
    end

    if type(ingredients) == "table" and not ingredients[1] then
        local temp = {}
        for k, v in pairs(ingredients) do
            temp[#temp + 1] = { k, v }
        end
        ingredients = temp
    end

    local amt = (multicraft and items[1] and items[1][2]) or 1

    printdb( "CRAFTING: Received items table: %s", json.encode(items))
    printdb( "CRAFTING: Received ingredients table: %s", json.encode(ingredients))

    for _, item in ipairs(items) do
        if not zutils.inventory.doesItemExist(item[1]) then
            return false, "Item does not exist: " .. item[1]
        end
    end
    for _, ingredient in ipairs(ingredients) do
        if not zutils.inventory.doesItemExist(ingredient[1]) then
            return false, "Ingredient does not exist: " .. ingredient[1]
        end
    end

    local total_weight_needed, total_slots_needed = 0, 0
    for _, item in ipairs(items) do
        local info = zutils.inventory.getItemInfo(item[1])
        if not info then
            printwarn("Item does not exist: %s", item[1])
            return false, "Item does not exist: " .. item[1]
        end
        total_weight_needed += (info.weight * item[2]) * amt
        total_slots_needed += 1 * amt
    end
    for _, ingredient in ipairs(ingredients) do
        local info = zutils.inventory.getItemInfo(ingredient[1])
        if not info then
            printwarn("Ingredient does not exist: %s", ingredient[1])
            return false, "Ingredient does not exist: " .. ingredient[1]
        end
        total_weight_needed -= (info.weight * ingredient[2]) * amt
        total_slots_needed -= 1 * amt
    end

    local available_weight = inventory.getAvailableWeight(src)
    local available_slots = inventory.getAvailableSlots(src)

    printdb( "CRAFTING: Available weight: %s / Required: %s", available_weight, total_weight_needed)
    printdb( "CRAFTING: Available slots: %s / Required: %s", available_slots, total_slots_needed)

    if available_weight < total_weight_needed then
        return false, "Not enough weight capacity to craft items"
    end
    if available_slots < total_slots_needed then
        return false, "Not enough slots to craft items"
    end

    for i = 1, amt do
        for _, ing in ipairs(ingredients) do
            printdb( "CRAFTING: Removing ingredient %s x %s", ing[1], ing[2])
            local success, err = zutils.inventory.removeItem(src, ing[1], ing[2])
            print(success, err)
            if not success then return false, err or "Failed to remove ingredients" end
        end
    end

    for i = 1, amt do
        for _, it in ipairs(items) do
            printdb( "CRAFTING: Adding item %s x %s", it[1], it[2])
            local success, err = zutils.inventory.addItem(src, it[1], it[2])
            if not success then return false, err or "Failed to add crafted item" end
        end
    end

    return true
end

zutils.callback.register("zutils:inventory:registerPersonalStash", function(source, id)
    local allowed_stash = personal_stashes[id]
    if not allowed_stash then
        printwarn("(src:%s, name:%s) tried to register a personal stash that does not exist: %s", source,
            GetPlayerName(source), id)
        return false
    end

    if allowed_stash.coords then
        local coords = allowed_stash.coords
        local player_coords = GetEntityCoords(GetPlayerPed(source))
        if #(coords - player_coords) > 5.0 then
            printwarn("(src:%s, name:%s) tried to register a personal stash at an invalid location: %s", source, GetPlayerName(source), id)
            return false
        end
    end

    local playerId = zutils.player.getPlayerId(source)
    local new_id = id .. playerId
    zutils.inventory.registerStash(new_id, personal_stashes[id].label, personal_stashes[id].slots,
        personal_stashes[id].max_weight, playerId, personal_stashes[id].groups, personal_stashes[id].coords)
    return true
end)

return zutils.inventory
