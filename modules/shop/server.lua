local shop = zutils.bridge_loader("shop", "server")
if not shop then return end

zutils.shop = {}

function zutils.shop.registerShop(id, shopData)
    printdb("Registering shop with ID: %s", id)
    shop.registerShop(id, shopData)
end

return zutils.shop