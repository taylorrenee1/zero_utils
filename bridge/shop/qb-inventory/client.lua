local shop = {}

function shop.openShop(id, _)
    TriggerServerEvent("zero_utils:server:qb-inventory:OpenShop", id)
end

return shop