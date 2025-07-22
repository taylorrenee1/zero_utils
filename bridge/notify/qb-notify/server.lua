local function notify(src, notify_type, message, options)
    TriggerClientEvent("QBCore:Notify", src, message, notify_type)
end

return notify