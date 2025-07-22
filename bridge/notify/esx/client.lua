local function notify(notify_type, message, options)
    options = options or {}
    TriggerEvent("esx:showNotification", message, notify_type, options.duration or 5000, options.title or notify_type)
end

return notify
