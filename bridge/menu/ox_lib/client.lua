local menu = {}
local lib = lib or exports.ox_lib

function menu.registerMenu(id, menuData)
    menuData.id = id
    menuData.title = menuData.title or "Menu"
    lib:registerContext(menuData)
end

function menu.openMenu(id)
    lib:showContext(id)
end

function menu.inputDialog(header, inputs)
    return lib:inputDialog(header, inputs)
end

function menu.closeMenu()
    lib:hideContext()
end

return menu
