local core = exports.qbx_core

local inventory = {}

function inventory.CreateUseableItem(item, func)
    core:CreateUseableItem(item, func)
end

return inventory