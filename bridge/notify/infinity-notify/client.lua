local function notify(notify_type, message, options)
    TriggerEvent('infinity-notify:sendNotify', message, notify_type)
end

return notify
