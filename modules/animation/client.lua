local emotes = zutils.bridge_loader("emote")
if not emotes then return end
zutils.animation = {}

function zutils.animation.loadAnimDict(dict)
    if not dict then
        return false, "Missing animation dictionary"
    end

    RequestAnimDict(dict)
    zutils.await(function()
        return HasAnimDictLoaded(dict)
    end, "Dict: " .. dict .. " failed to load", 10000)
    printdb("Dict: " .. dict .. " loaded successfully")
    return true
end

function zutils.animation.playAnim(ped, dict, anim, options)
    options = options or {}
    if not ped or ped == -1 then
        ped = PlayerPedId()
    end

    if not ped or not dict or not anim then
        return false, "Missing animation dictionary or animation name"
    end

    if not IsEntityPlayingAnim(ped, dict, anim, 3) then
        if not zutils.animation.loadAnimDict(dict) then
            return false, "Failed to load animation dictionary"
        end
        printdb("(%s)Playing animation: %s %s", ped, dict, anim)
        TaskPlayAnim(ped, dict, anim, options.blend_in_speed or 8.0, options.blend_out_speed or -8.0,
            options.duration or -1, options.flags or 1, options.playback_rate or 0.0, options.lock_x or false,
            options.lock_y or false, options.lock_z or false)
        RemoveAnimDict(dict)
        if options.prop then
            Wait(100)
            local prop_id = zutils.prop.createEntityProp(ped, options.prop.model, options.prop.bone, options.prop.pos,
                options.prop.rot)
            CreateThread(function()
                while IsEntityPlayingAnim(ped, dict, anim, 3) do
                    Wait(0)
                end
                zutils.prop.deleteProp(prop_id)
            end)
        end
    end

    return true
end

function zutils.animation.stopAnim(ped, dict, anim)
    if not ped or ped == -1 then
        ped = PlayerPedId()
    end

    if not dict or not anim then
        ClearPedTasks(ped)
        return
    end

    if IsEntityPlayingAnim(ped, dict, anim, 3) then
        StopAnimTask(ped, dict, anim, 3.0)
    end

    return true
end

function zutils.animation.playEmote(name, variation)
    if not name then return printwarn("No emote name provided") end
    emotes.start(name, variation)
end

function zutils.animation.cancelEmote()
    emotes.cancel()
end


return zutils.animation
