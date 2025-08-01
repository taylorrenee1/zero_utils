local menu = {}

local openMenus = {}

function menu.registerMenu(id, data)
    local options = {}

    for _, opt in ipairs(data.options or {}) do
        table.insert(options, {
            title = opt.title or opt.label or "Option",
            description = opt.description or "",
            icon = opt.icon,
            iconColor = opt.iconColor,
            image = opt.image,
            readOnly = opt.readOnly or opt.isMenuHeader,
            disabled = opt.disabled,
            progress = opt.progress,
            metadata = opt.metadata,
            keybind = opt.keybind,
            menu = opt.menu, -- submenu id
            onSelect = opt.onSelect,
            event = opt.event,
            args = opt.args,
        })
    end

    exports.lation_ui:registerMenu({
        id = id,
        title = data.title or "Menu",
        subtitle = data.subtitle or data.headertxt or "",
        onExit = data.onExit,
        menu = data.backTo, -- for submenu back button
        options = options,
    })

    openMenus[id] = true
end

function menu.openMenu(id)
    if openMenus[id] then
        exports.lation_ui:showMenu(id)
    else
        printwarn("[lation-ui] Tried to open unregistered menu: %s ", id)
    end
end

function menu.inputDialog(header, inputs)
    local inputConfig = {
        title = header or "Input",
        subtitle = "",
        submitText = "Submit",
        options = {},
    }

    for _, field in ipairs(inputs) do
        local entry = {
            type = field.type or "input",
            label = field.label or field.name or "Input",
            description = field.description or "",
            placeholder = field.placeholder,
            icon = field.icon,
            required = field.required or false,
            default = field.default,
        }

        if field.type == "select" then
            entry.options = field.options or {}
        elseif field.type == "toggle" or field.type == "slider" then
            entry.min = field.min
            entry.max = field.max
            entry.unit = field.unit
        end

        table.insert(inputConfig.options, entry)
    end

    local result = exports.lation_ui:input(inputConfig)
    return result
end

return menu
