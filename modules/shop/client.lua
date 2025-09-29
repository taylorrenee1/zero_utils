local shop = zutils.bridge_loader("shop")
if not shop then return end

zutils.shop = {}

function zutils.shop.openShop(id, loc_id)
    printdb("Opening shop with ID: %s at location ID: %s", id, loc_id)
    shop.openShop(id, loc_id)
end

return zutils.shop