local function progressBar(name, label, duration, options)
    local promise = promise:new()
        exports['esx_progressbar']:Progressbar(label, duration, {
        FreezePlayer = options.controlDisables.move or false,
        animation = {
            type = options.animation.type or 'anim',
            dict = options.animation.animDict or nil,
            lib = options.animation.anim or nil,
        },
        onFinish = function()
            if options.onFinish then
                options.onFinish()
            end
            promise:resolve(true)
        end, onCancel = function()
            if options.onCancel then
                options.onCancel()
            end
            promise:resolve(false)
        end
    })
end

return progressBar
