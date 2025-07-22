local function notify(src, notify_type, message, options)
    TriggerClientEvent('infinity-notify:sendNotify', src, message, notify_type)
end

return notify