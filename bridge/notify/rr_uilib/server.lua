local function notify(src, notify_type, message, options)
    TriggerEvent("rr_uilib:Notify", src
        {
            msg = message,
            type = notify_type,
            style = "dark",
            duration = 6000,
            position = "top-right",
        }
    )
end

return notify
