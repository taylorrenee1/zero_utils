local progress = function(name, label, duration, options)
    local data = {
        duration = duration,
        label = label,
        useWhileDead = options.useWhileDead,
        canCancel = options.canCancel,
        disable = {
            move = options.controlDisables.move or false,
            combat = options.controlDisables.combat or false,
            car = options.controlDisables.car or false,
            mouse = options.controlDisables.mouse or false,
            sprint = options.controlDisables.sprint or false,
        },
        anim = {
            dict = options.animation.animDict,
            clip = options.animation.anim,
            flag = options.animation.flags or 15,
            blendIn = options.animation.blendIn or nil,
            blendOut = options.animation.blendOut or nil,
            duration = options.animation.duration or nil,
            playbackRate = options.animation.playbackRate or nil,
            lockX = options.animation.lockX or false,
            lockY = options.animation.lockY or false,
            lockZ = options.animation.lockZ or false,
            scenario = options.animation.task,
            playEnter = options.animation.playEnter or false,
        },
        prop = options.prop or options.propTwo,
    }

    if options.style == "circle" then
        data.position = options.position or "middle"
    end

    local result
    if options.style == "circle" then
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
