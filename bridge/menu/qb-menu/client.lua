local menu = {}

function menu.registerMenu(id, data)
    local Menu = {}

    if data.options then
        for _, opt in pairs(data.options) do
            table.insert(Menu, {
                header = opt.title or opt.label or opt.header or " ",
                txt = opt.description or opt.txt or "",
                icon = opt.icon,
                isMenuHeader = opt.readOnly,
                disabled = opt.disabled,
                hidden = opt.hidden or false,
                params = {
                    event = opt.event,
                    args = opt.args
                }
            })
        end
    end

    if data.title then
        table.insert(Menu, 1, {
            header = data.title,
            txt = data.subtitle or "",
            isMenuHeader = true
        })
    end

    exports['qb-menu']:openMenu(Menu)
end

function menu.openMenu(id)
    -- Not needed for qb-menu
end

function menu.inputDialog(header, inputs)
    return exports['qb-input']:ShowInput({
        header = header,
        submitText = "Submit",
        inputs = inputs
    })
end

function menu.closeMenu()
    exports['qb-menu']:closeMenu()
end

return menu
