local callback = zutils.bridge_loader("callback")
if not callback then return end
if zutils.context == "client" then
    zutils.callback = setmetatable({}, {
        __call = function (_, name, delay, cb, ...)
            callback.trigger(name, delay, cb, ...)
        end
    })
else
    zutils.callback = setmetatable({}, {
        __call = function (_, name, source, cb, ...)
            callback.trigger(name, source, cb, ...)
        end
    })
end
zutils.callback.trigger = callback.trigger
zutils.callback.register = callback.register
zutils.callback.await = callback.await

return zutils.callback