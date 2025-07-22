local function notify(src, notify_type, message, options)
    TriggerClientEvent('okokNotify:Alert', src, options.title, message, options?.length or 5000, notify_type)
end

return notify