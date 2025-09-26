zutils.core_loader("ox_lib")

local progress = function(name, label, duration, options)
    options = options or {}

    local data = {
            duration = duration or 0,
            label = label or "",
            useWhileDead = options.useWhileDead,
            canCancel = options.canCancel,
            disable = {
                move = (options.controlDisables.move and options.controlDisables.move) or false,
                combat = (options.controlDisables.combat and options.controlDisables.combat) or false,
                car = (options.controlDisables.car and options.controlDisables.car) or false,
                mouse = (options.controlDisables.mouse and options.controlDisables.mouse) or false,
                sprint = (options.controlDisables.sprint and options.controlDisables.sprint) or false,
            },
        }

        local anim = options.animation
        if anim and (anim.animDict or anim.dict or anim.task) then
            data.anim = {
                dict = anim.animDict or anim.dict,
                clip = anim.anim or anim.clip,
                flag = anim.flags or anim.flag or 15,
                blendIn = anim.blendIn,
                blendOut = anim.blendOut,
                duration = anim.duration,
                playbackRate = anim.playbackRate,
                lockX = anim.lockX or false,
                lockY = anim.lockY or false,
                lockZ = anim.lockZ or false,
                scenario = anim.task,
                playEnter = (anim.playEnter ~= nil) and anim.playEnter or true,
            }
        end

        if options.prop or options.propTwo then
            if options.prop and options.propTwo then
                data.prop = { options.prop, options.propTwo }
            else
                data.prop = options.prop or options.propTwo
            end
        elseif type(options.props) == "table" then
            data.prop = options.props
        end
        local result
    if options.style == "circle" then
        data.position = options.position or "middle"
        result = lib.progressCircle(data)
    else
        result = lib.progressBar(data)
    end

    if result and options.onFinish then options.onFinish() end
    if not result and options.onCancel then options.onCancel() end
    if options.onEnd then options.onEnd() end

    return result
end

return progress
