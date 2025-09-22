zutils.ptfx = {}

function zutils.ptfx.ptfxRequest(ptFxName, timeout)
    if HasNamedPtfxAssetLoaded(ptFxName) then return true end
    RequestNamedPtfxAsset(ptFxName)
    return Await(function()
        return HasNamedPtfxAssetLoaded(ptFxName)
    end, {"Ptfx Asset Failed to Load %s", ptFxName}, timeout or 10000)
end

function zutils.ptfx.ptfxUnload(ptFxName, timeout)
    if not HasNamedPtfxAssetLoaded(ptFxName) then return true end
    RemoveNamedPtfxAsset(ptFxName)
    return Await(function()
        return not HasNamedPtfxAssetLoaded(ptFxName)
    end, {"Ptfx Asset Failed to Unload %s", ptFxName}, timeout or 10000)
end

function zutils.ptfx.startParticleFx(particle)
	local ped = PlayerPedId()
	local pedcoords = GetEntityCoords(ped)
	UseParticleFxAsset("core")
	particlefx = StartParticleFxLoopedAtCoord(particle, pedcoords, 0.0, 0.0, 0.0, 1.0, false, false,
		false, false)
end

function zutils.ptfx.stopParticleFx()
	if particlefx ~= nil then
		StopParticleFxLooped(particlefx, 0)
		particlefx = nil
	end
end



return zutils.ptfx
