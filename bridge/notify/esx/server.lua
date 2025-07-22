local function notify(notify_type, message, options)
    options = options or {}
    TriggerClientEvent("esx:showNotification", source, message, notify_type, options.duration, options.title or notify_type)
end

return notify
