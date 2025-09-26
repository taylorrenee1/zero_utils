-- bridge/menu/esx_menu/client.lua
local ESX = zutils.core_loader('ESX')
local resourceName = GetCurrentResourceName()

local function has(res) return zutils.isResourceStarted(res) end
local menu = {}
local openMenus = {}

function menu.registerMenu(id, data)
    if not has('esx_menu_default') then
        printerr("[ESX Menu] esx_menu_default not started; cannot open default menu '%s'", tostring(id))
        return
    end

    local elements = {}
    for _, opt in ipairs(data.options or {}) do
        elements[#elements+1] = {
            label = opt.title or opt.label or opt.header or "Option",
            value = opt.event,
            args  = opt.args
        }
    end

    ESX.UI.Menu.Open('default', resourceName, id, {
        title   = data.title or "Menu",
        align   = data.align or 'top-right',
        elements= elements
    }, function(data2, menu2)
        local sel = data2.current
        if sel and sel.value then
            TriggerEvent(sel.value, sel.args)
        end
    end, function(_, m) m.close() end)

    openMenus[id] = true
end

function menu.openMenu(id)
    -- kept for parity
end

function menu.inputDialog(title, placeholder)
    if not has('esx_menu_dialog') then
        printerr("[ESX Menu] esx_menu_dialog not started; inputDialog unavailable (%s)", tostring(title))
        return nil
    end

    local p = promise.new()
    ESX.UI.Menu.Open('dialog', resourceName, ('dialog_%s'):format(title or 'input'), {
        title = title or "Input"
    }, function(data, menu2)
        local val = data.value
        menu2.close()
        p:resolve(val)
    end, function(_, m) m.close(); p:resolve(nil) end)

    return Citizen.Await(p)
end

function menu.openList(id, title, items, startIndex)
    local labels, values = {}, {}
    if type(items[1]) == 'table' then
        for i, it in ipairs(items) do labels[i] = it.label or tostring(it.value or it); values[i] = it.value or it.label end
    else
        for i, it in ipairs(items) do labels[i] = tostring(it); values[i] = it end
    end
    local defaultIndex = startIndex or 1

    local p = promise.new()

    if has('esx_menu_list') then
        ESX.UI.Menu.Open('list', resourceName, id, {
            title   = title or "Select",
            align   = 'top-right',
            elements= labels,
            default = defaultIndex
        }, function(data, menu2) -- onSelect
            local idx = data.current
            local val = values[idx] or labels[idx]
            menu2.close()
            p:resolve({ idx, val })
        end, function(_, m) m.close() end, function(data, _menu, newIndex)
        end)
    else
        local elements = {}
        for i, lab in ipairs(labels) do
            elements[#elements+1] = { label = lab, value = i }
        end

        ESX.UI.Menu.Open('default', resourceName, id, {
            title   = title or "Select",
            align   = 'top-right',
            elements= elements
        }, function(data2, menu2)
            local idx = data2.current and data2.current.value or defaultIndex
            local val = values[idx] or labels[idx]
            menu2.close()
            p:resolve({ idx, val })
        end, function(_, m) m.close() end)
    end

    openMenus[id] = true
    local result = Citizen.Await(p)
    return table.unpack(result or {})
end

function menu.close(id)
    ESX.UI.Menu.Close(resourceName, id)
    openMenus[id] = nil
end

function menu.closeAll()
    ESX.UI.Menu.CloseAll()
    openMenus = {}
end

return menu
