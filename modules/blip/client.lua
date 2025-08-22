zutils.blip = {}

local blips = {}

function zutils.blip.createBlip(name, coords, options)
    local blip = AddBlipForCoord(coords)
    SetBlipAsShortRange(blip, true)
    SetBlipSprite(blip, options.sprite or 106)
    SetBlipColour(blip, options.col or 5)
    SetBlipScale(blip, options.scale or 0.7)
    SetBlipDisplay(blip, (options.disp or 6))
    if options.category then SetBlipCategory(blip, options.category) end
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(tostring(name))
    EndTextCommandSetBlipName(blip)

    if not blips[name] then blips[name] = {} end
    table.insert(blips[name], blip)

    return blip
end

function zutils.blip.getBlips(name)
    return blips[name] or {}
end


function zutils.blip.removeBlip(blip)
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end

AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, blip in ipairs(blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}
end)

return zutils.blip