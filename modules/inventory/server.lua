local inventory = zutils.bridge_loader("inventory", "server")
if not inventory then return end

zutils.inventory = {}

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
        return false, "Item does not exist: " .. item
    end

    if not zutils.inventory.hasItem(inv, item, count, metadata) then
        return false, "Inventory does not have item: " .. item
    end

    local result = inventory.removeItem(inv, item, count, metadata, slot, cb)
    if not result then
        return false, "Inventory RemoveItem failed: " .. item
    end
    return true
end
zutils.inventory.RemoveItem = zutils.inventory.removeItem -- Alias for compatibility

function zutils.inventory.canCarryItem(inv, item, count, metadata)
    return inventory.canCarryItem(inv, item, count, metadata)
end

function zutils.inventory.hasItem(inv, item, count, metadata)
    return inventory.hasItem(inv, item, count, metadata)
end

zutils.inventory.HasItem = zutils.inventory.hasItem -- Alias for compatibility

function zutils.inventory.registerStash(id, label, slots, max_weight, owner, groups, coords)
    assert(id, "ID must be specified")
    assert(label, "Label must be specified")
    slots = slots or 50
    max_weight = max_weight or 1000000
    inventory.registerStash(id, label, slots, max_weight, owner, groups, coords)
end

zutils.inventory.RegisterStash = zutils.inventory.registerStash -- Alias for compatibility

function zutils.inventory.forceOpenInventory(source, inv, id)
    assert(source, "Source must be specified")
    assert(inv, "Inventory must be specified")
    return inventory.forceOpenInventory(source, inv, id)
end

function zutils.inventory.craftItem(src, items, ingredients)
    if type(items) ~= "table" then
        items = {
            { items, 1 }
        }
    end

    if type(ingredients) ~= "table" then
        ingredients = {
            { ingredients, 1 }
        }
    end

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
    local total_weight_needed = 0
    local total_slots_needed = 0
    for _, item in ipairs(items) do
        local item_info = zutils.inventory.getItemInfo(item[1])
        if not item_info then
            printwarn("Item does not exist: " .. item[1])
            return false, "Item does not exist: " .. item[1]
        end
        total_weight_needed = total_weight_needed + (item_info.weight * item[2])
        total_slots_needed = total_slots_needed + 1
    end

    for _, ingredient in ipairs(ingredients) do
        local ingredient_info = zutils.inventory.getItemInfo(ingredient[1])
        if not ingredient_info then
            return false, "Ingredient does not exist: " .. ingredient[1]
        end
        total_weight_needed = total_weight_needed - (ingredient_info.weight * ingredient[2])
        total_slots_needed = total_slots_needed - 1
    end

    local available_weight = inventory.getAvailableWeight(src)
    local available_slots = inventory.getAvailableSlots(src)

    if available_weight < total_weight_needed then
        return false, "Not enough weight capacity to craft items"
    end
    if available_slots < total_slots_needed then
        return false, "Not enough slots to craft items"
    end

    for _, ingredient in ipairs(ingredients) do
        local success, err = zutils.inventory.removeItem(src, ingredient[1], ingredient[2])
        if not success then
            return false, err
        end
    end

    for _, item in ipairs(items) do
        local success, err = zutils.inventory.addItem(src, item[1], item[2])
        if not success then
            return false, err
        end
    end

    return true
end

return zutils.inventory
