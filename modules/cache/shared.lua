local cache = {}
local events = {}
local localCache = {}
local isMainResource = zutils.name == 'zero_utils'

if isMainResource then
    function cache.set(key, value)
        local oldValue = localCache[key]
        if oldValue ~= value then
            localCache[key] = value
            TriggerEvent(('zutils:cache:%s'):format(key), value, oldValue)
        end
    end

    exports('setCacheValue', cache.set)

    function cache.get(key)
        return localCache[key]
    end

    exports('getCacheValue', cache.get)

    function cache.getAll()
        return localCache
    end

    exports('getAllCache', cache.getAll)

    if zutils.context == "client" then
        local _PlayerPedID = PlayerPedId
        local _GetSelectedPedWeapon = GetSelectedPedWeapon
        local _GetVehiclePedIsIn = GetVehiclePedIsIn
        local _GetPedInVehicleSeat = GetPedInVehicleSeat
        local _GetVehicleMaxNumberOfPassengers = GetVehicleMaxNumberOfPassengers
        CreateThread(function()
            while true do
                local ped = _PlayerPedID()
                cache.set('ped', ped)

                local weapon = _GetSelectedPedWeapon(ped)
                cache.set('weapon', weapon)

                local vehicle = _GetVehiclePedIsIn(ped, false)
                if vehicle > 0 then
                    if vehicle ~= cache.vehicle then
                        cache.set("seat", false)
                    end

                    if not cache.seat or _GetPedInVehicleSeat(vehicle, cache.seat) ~= ped then
                        for i = -1, _GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
                            if _GetPedInVehicleSeat(vehicle, i) == ped then
                                cache.set('seat', i)
                                break
                            end
                        end
                    end

                    cache.set("vehicle", vehicle)
                else
                    cache.set("seat", false)
                    cache.set("vehicle", false)
                end

                Wait(100)
            end
        end)
    end
else
    function cache.set(key, value)
        if type(value) == 'function' then
            value = value()
        end
        exports.zero_utils:setCacheValue(key, value)
    end

    function cache.get(key)
        if localCache[key] ~= nil then
            return localCache[key]
        end

        local value = exports.zero_utils:getCacheValue(key)
        if value ~= nil then
            localCache[key] = value
        end

        if not events[key] then
            events[key] = {}
            events[key][1] = function (new, old)
                localCache[key] = new
            end
            AddEventHandler(('zutils:cache:%s'):format(key), function(new, old)
                for _, event in ipairs(events[key]) do
                    event(new, old)
                end
            end)
        end

        return value
    end

    function cache.getAll()
        return exports.zero_utils:getAllCache()
    end
end

function cache.onSet(key, callback)
    if type(callback) ~= 'function' then
        return printerr('Cache listener callback must be a function')
    end

    if not events[key] then
        cache.get(key)
    end

    events[key][#events[key]+1] = function (new, old)
        callback(new, old)
    end
end

setmetatable(cache, {
    __index = function(self, key)
        local func = rawget(self, key)
        if func then return func end

        return localCache[key] or self.get(key)
    end,

    __newindex = function(self, key, value)
        if type(value) == 'function' then
            rawset(self, key, value)
        else
            self.set(key, value)
        end
    end
})

return cache