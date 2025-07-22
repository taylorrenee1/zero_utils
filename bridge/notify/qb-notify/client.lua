local function notify(notify_type, message, options)
    TriggerEvent("QBCORE:Notify", message, notify_type)
end

return notify
