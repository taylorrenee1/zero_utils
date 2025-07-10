if not QBCore then QBCore = zutils.core_loader("QBCore") end

local core = {}

local inventory = {}

function inventory.getItemImage(item)
    return 'https://cfx-nui-qb-inventory/html/images/'..item..'.png'
end
