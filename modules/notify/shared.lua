local notify = zutils.bridge_loader("notify")
if not notify then return end

zutils.notify = notify

return zutils.notify