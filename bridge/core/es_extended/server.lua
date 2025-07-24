local core = {}


function core.setThirst(src, thirst)
    TriggerClientEvent('esx_status:add', src, 'thirst', thirst)
    return true
end

function core.setHunger(src, hunger)
   TriggerClientEvent('esx_status:add', src, 'hunger', hunger)
    return true
end

return core
