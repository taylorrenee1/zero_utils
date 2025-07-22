local function notify(src, notify_type, message, options)
    TriggerClientEvent('t-notify:client:Custom', src,
    {
        style = notify_type,
        duration = 6000,
        title = options.title,
        message = message,
        sound = true,
        custom = true
    })
end

return notify