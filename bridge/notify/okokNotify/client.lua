local function notify(notify_type, message, options)
    TriggerEvent('okokNotify:Alert', options.title, message, options?.length or 5000, notify_type)
end

return notify
