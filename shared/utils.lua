zutils.require('/shared/table.lua')

function zutils.isResourceStarted(resource)
    local started = GetResourceState(resource):find("started")
    if not started then
        printdb("Resource [%s] is not started", resource)
        return false
    end

    printdb("Resource [%s] is started", resource)
    return true
end

function zutils.isResourceMissing(resource)
    local state = GetResourceState(resource)
    if state == "missing" then
        printdb("Resource [%s] is missing", resource)
        return true
    end

    printdb("Resource [%s] is present", resource)
    return false
end

function zutils.getGroundAt(coords, include_water, include_objects)
    local current_coords = GetEntityCoords(PlayerPedId())
    local dist = zutils.vecdist(current_coords, coords)
    if dist > 100 then
        SetFocusPosAndVel(coords.x, coords.y, coords.z)
    end
    local _, ground_z
    if include_objects then
        _, ground_z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, include_water or false)
    else
        _, ground_z = GetGroundZExcludingObjectsFor_3dCoord(coords.x, coords.y, coords.z, include_water or false)
    end

    ClearFocus()
    return vector3(coords.x, coords.y, ground_z or coords.z)
end

function zutils.vecdist(a, b)
    local aType = type(a)
    local bType = type(b)

    if aType == "vector4" then
        a = vector3(a.x, a.y, a.z)
        aType = 'vector3'
    end
    if bType == "vector4" then
        b = vector3(b.x, b.y, b.z)
        bType = 'vector3'
    end

    if aType == bType then
        return #(a - b)
    elseif aType == 'vector3' and bType == 'vector2' then
        return #(a - vec3(b.x, b.y, a.z))
    elseif aType == 'vector2' and bType == 'vector3' then
        return #(vec3(a.x, a.y, b.z) - b)
    else
        printerr('cannot calculate distance between %s and %s', aType, bType)
    end
end

function zutils.joaat(str)
    if not str then return false, "nil found" end
    if tonumber(str) then return str end
    return joaat(str)
end

function zutils.uuid()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

function zutils.await(fn, errmsg, timeout)
    timeout = timeout or 10000
    local start = GetGameTimer()
    while not fn() do
        if GetGameTimer() - start > timeout then
            printerr(errmsg[1] or errmsg or "Await timed out", errmsg[2])
        end
        Wait(0)
    end
    return true
end



--TODO DEPRECATED COMPAT FUNCTIONS REMOVE LATER

function AwaitNetOwnership(netid)
    local timeout = 0
    while not NetworkDoesNetworkIdExist(netid) do
        timeout = timeout + 1
        if timeout > 100 then
            local errmsg = "Net id does not exist:"..(netid or "nil")
            printdb(errmsg)
            return false, errmsg
            -- printerr("Failed to get entity from net id")
        end
        Wait(100)
    end
    while not NetworkHasControlOfNetworkId(netid) do
        NetworkRequestControlOfNetworkId(netid)
        timeout = timeout + 1
        if timeout > 100 then
            local errmsg = "Failed to get control of net id:"..(netid or "nil")
            printdb(errmsg)
            return false, errmsg
            -- printerr("Failed to get control of net id")
        end
        Wait(100)
    end
end
function Assert(item, checkType)
    if type(checkType) == "table" then
        for _, check in ipairs(checkType) do
            if type(item) == check then return end
        end
        PrintUtils.PrintError("Expected %s, got %s", table.concat(checkType, " or "), type(item))
    else
        if type(item) ~= checkType then PrintUtils.PrintError("Expected %s, got %s", checkType, type(item)) end
    end
end

function Await(fn, errmsg, timeout)
    timeout = timeout or 10000
    local start = GetGameTimer()
    while not fn() do
        if GetGameTimer() - start > timeout then
            printerr(errmsg[1] or errmsg or "Await timed out", errmsg[2])
        end
        Wait(0)
    end
    return true
end

function IsResourceStarted(resource)
    local started = GetResourceState(resource):find("start")
    return started
end

function AssertBridgeResource(config, check, resource)
    if config then
        printdb("AssertBridgeResource(%s, %s, %s)", config, check, resource)
        if not string.lower(config) == string.lower(check) then printerr("failed?") return false end
    end
    if not GetResourceState(resource):find("start") then
        printerr("Resource [%s] is not started: Config = %s", resource, config)
        return false
    end
    printdb("Resource found and started")
    return true
end


function FailedSetup(import) printerr("Failed Setup. Please check config for Config.Bridge.%s", import) end

local function GetForwardVectorFromRot(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

function clamp(min, value, max)
    return math.max(min, math.min(value, max))
end

function RayCastFromPlayCam(distance, ignoreObj, rayIgnoreWorld, raycastWater)
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(0)
    local forwardVector = GetForwardVectorFromRot(camRot)
    local targetCoords = camCoords + forwardVector * distance
    local _, hit, endCoords, _, entityHit
    if raycastWater then
        hit, endCoords = TestProbeAgainstWater(camCoords.x,camCoords.y,camCoords.z, targetCoords.x,targetCoords.y,targetCoords.z)
    else
        local traceFlag = rayIgnoreWorld and 1 or 4294967295
        local rayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, targetCoords.x, targetCoords.y, targetCoords.z, traceFlag, ignoreObj, 0)
        _, hit, endCoords, _, entityHit = GetShapeTestResult(rayHandle)
    end
    return hit, endCoords, entityHit
end

function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    EndTextCommandDisplayText(x, y)
end

function AwaitSetPlate(veh, plate)
    local timeout = 0
    local current = zutils.GetPlate(veh)
    while current ~= plate do
        current = zutils.GetPlate(veh)
        timeout = timeout + 1
        if timeout > 100 then
            local errmsg = "Failed to set plate: %s"
            printwarn(errmsg, plate)
            return false, errmsg:format(plate)
        end
        Wait(100)
    end
    return true
end

function zutils.AwaitNetId(entity)
    if not entity then return false, "entity was nil" end
    if type(entity) ~= "number" then return false, "entity was not a number:"..(entity or "nil") end
    local timeout = 0
    local netId = NetworkGetNetworkIdFromEntity(entity)
    while not netId do
        netId = NetworkGetNetworkIdFromEntity(entity)
        timeout = timeout + 1
        if timeout > 100 then
            local errmsg = "Failed to get net id from entity:"..(entity or "nil")
            printdb(errmsg)
            return false, errmsg
        end
        Wait(100)
    end

    return netId
end

function zutils.AwaitEntityFromNetId(netID)
    if not netID then return false, "netID was nil" end
    if type(netID) ~= "number" then return false, "netID was not a number:"..(netID or "nil") end
    local timeout = 0
    local entity = NetworkGetEntityFromNetworkId(netID)
    while not entity or entity <= 0 do
        entity = NetworkGetEntityFromNetworkId(netID)
        timeout = timeout + 1
        if timeout > 100 then
            local errmsg = "Failed to get entity from net id:"..(netID or "nil")
            printdb(errmsg)
            return false, errmsg
        end
        Wait(100)
    end
    return entity
end

function AwaitSetPlate(veh, plate)
    local timeout = 0
    local current = zutils.GetPlate(veh)
    while current ~= plate do
        current = zutils.GetPlate(veh)
        timeout = timeout + 1
        if timeout > 100 then
            local errmsg = "Failed to set plate: %s"
            printwarn(errmsg, plate)
            return false, errmsg:format(plate)
        end
        Wait(100)
    end
    return true
end

function zutils.GetPlate(veh)
    local plate = GetVehicleNumberPlateText(veh)
    plate = plate:gsub( '^%s*(.-)%s*$', '%1')
    return plate
end

function Assert(item, checkType)
    if type(checkType) == "table" then
        for _, check in ipairs(checkType) do
            if type(item) == check then return end
        end
        PrintUtils.PrintError("Expected %s, got %s", table.concat(checkType, " or "), type(item))
    else
        if type(item) ~= checkType then PrintUtils.PrintError("Expected %s, got %s", checkType, type(item)) end
    end
end

function Await(fn, errmsg, timeout)
    timeout = timeout or 10000
    local start = GetGameTimer()
    while not fn() do
        if GetGameTimer() - start > timeout then
            printerr(errmsg[1] or errmsg or "Await timed out", errmsg[2])
        end
        Wait(0)
    end
    return true
end

function IsResourceStarted(resource)
    local started = GetResourceState(resource):find("start")
    return started
end

function AssertBridgeResource(config, check, resource)
    if config then
        printdb("AssertBridgeResource(%s, %s, %s)", config, check, resource)
        if not string.lower(config) == string.lower(check) then printerr("failed?") return false end
    end
    if not GetResourceState(resource):find("start") then
        printerr("Resource [%s] is not started: Config = %s", resource, config)
        return false
    end
    printdb("Resource found and started")
    return true
end


function FailedSetup(import) printerr("Failed Setup. Please check config for Config.Bridge.%s", import) end

local function GetForwardVectorFromRot(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

function clamp(min, value, max)
    return math.max(min, math.min(value, max))
end

function RayCastFromPlayCam(distance, ignoreObj, rayIgnoreWorld, raycastWater)
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(0)
    local forwardVector = GetForwardVectorFromRot(camRot)
    local targetCoords = camCoords + forwardVector * distance
    local _, hit, endCoords, _, entityHit
    if raycastWater then
        hit, endCoords = TestProbeAgainstWater(camCoords.x,camCoords.y,camCoords.z, targetCoords.x,targetCoords.y,targetCoords.z)
    else
        local traceFlag = rayIgnoreWorld and 1 or 4294967295
        local rayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, targetCoords.x, targetCoords.y, targetCoords.z, traceFlag, ignoreObj, 0)
        _, hit, endCoords, _, entityHit = GetShapeTestResult(rayHandle)
    end
    return hit, endCoords, entityHit
end

function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    EndTextCommandDisplayText(x, y)
end

function zutils.GetClosestPlayers(src, maxDistance)
    src = src or -1
    maxDistance = maxDistance or 99999999
    local players = {}
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    --TODO MAKE AVAILABLE FOR SERVER
    for _, player in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(player)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(playerCoords - targetCoords)
        if distance <= maxDistance and player ~= src then
            players[#players + 1] = player
        end
    end
    return players
end

function zutils.GetClosestVehicle(maxDist)
	local ped = PlayerPedId()
    local vehicles = GetGamePool('CVehicle')
	local closestDistance = math.huge
	local closestVehicle = nil
	for i = 1, #vehicles do
		local veh = vehicles[i]
		local vehCoords = GetEntityCoords(veh)
		local distance = #(GetEntityCoords(ped) - vehCoords)
		if distance < closestDistance and distance < maxDist then
			closestDistance = distance
			closestVehicle = veh
		end
	end

	return closestVehicle
end

function zutils.GetPlate(veh)
    local plate = GetVehicleNumberPlateText(veh)
    plate = plate:gsub( '^%s*(.-)%s*$', '%1')
    return plate
end

function zutils.GetPlayerData(src)
    if src and zutils.context == "server" then
        local player = QBCore.Functions.GetPlayer(src)
        if not player then return false, "Player not found" end
        local player_data = player.PlayerData
        if not player_data then return false, "Player Data not found" end
        return player_data
    elseif src then
        printwarn("GetPlayerData called with src but not in server context")
    end

    local player_data = QBCore.Functions.GetPlayerData()
    if not player_data then return false, "Player Data not found" end
    return player_data
end

function zutils.GetPlayerJob(src)
    local player_data, err = zutils.GetPlayerData(src)
    if not player_data then return false, err end
    local job = player_data.job
    if not job then return false, "Job not found" end
    return job
end

function zutils.GetJobInfo(job)
    local job = QBCore.Shared.Jobs[job]
    if not job then return false, "Job not found" end
    return job
end

function zutils.joaat(str)
    if not str then return false, "nil found" end
    if tonumber(str) then return str end
    return joaat(str)
end

function zutils.uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

function zutils.getPedForwardVector(ped)
    local heading = GetEntityHeading(ped)
    local rad = math.rad(heading)
    return vector3(-math.sin(rad), math.cos(rad), 0)
end
function math.sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

function TurnPedToCoords(ped, coords)
    TaskTurnPedToFaceCoord(ped, coords.x, coords.y, coords.z, -1)
    while not IsPedHeadingTowardsPosition(ped, coords.x, coords.y, coords.z, 20.0) do
        Wait(100)
    end
    Wait(100)
    ClearPedTasks(ped)
end

function GetGroundAt(coords, waterAsGround)
    SetFocusPosAndVel(coords.x, coords.y, coords.z)
    local _, z = GetGroundZExcludingObjectsFor_3dCoord(coords.x, coords.y, coords.z, waterAsGround or false)
    ClearFocus()
    return vector3(coords.x, coords.y, z or coords.z)
end

function LoadAnim(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        Await(function()
            return HasAnimDictLoaded(dict)
        end, {"Anim Dict Failed to Load %s", dict}, 10000)
    end
end

function WaitForAnim(entity, dict, anim)
    while not IsEntityPlayingAnim(entity, dict, anim, 3) do
        Wait(0)
    end
end
