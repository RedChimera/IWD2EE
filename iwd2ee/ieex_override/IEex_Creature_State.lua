
IEex_GameObjectData = {}
IEex_RegisteredLuaStats = {}

function IEex_RegisterLuaStat(attributes)

	-- ["init"] = function(stats)
	-- ["reload"] = function(stats)
	-- ["copy"] = function(sourceStats, destStats)
	-- ["cleanup"] = function(stats)

	table.insert(IEex_RegisteredLuaStats, attributes)
end

function IEex_AccessLuaStats(actorID)
	local share = IEex_GetActorShare(actorID)
	local bAllowEffectListCall = IEex_ReadDword(share + 0x72A4) == 1
	local actorData = IEex_GameObjectData[actorID]
	return bAllowEffectListCall and actorData.luaDerivedStats or actorData.luaTempStats
end

function IEex_OnGameObjectAdded(actorID)

	local share = IEex_GetActorShare(actorID)
	if share == 0x0 then
		print("[IEex_OnGameObjectAdded] Engine attempted to add invalid object?")
		return
	end

	local myData = {}

	-- Sprite
	if IEex_ReadByte(share + 0x4, 0) == 0x31 then

		local luaDerivedStats = {}
		local luaTempStats = {}

		for _, luaStat in ipairs(IEex_RegisteredLuaStats) do
			local initFunc = luaStat.init
			if initFunc then
				initFunc(luaDerivedStats)
				initFunc(luaTempStats)
			end
			local reloadFunc = luaStat.reload
			if reloadFunc then
				reloadFunc(luaDerivedStats)
			end
		end

		myData.luaDerivedStats = luaDerivedStats
		myData.luaTempStats = luaTempStats

	end

	IEex_GameObjectData[actorID] = myData

end

function IEex_OnGameObjectBeingDeleted(actorID)

	local share = IEex_GetActorShare(actorID)
	if share == 0x0 then
		-- Just in case the object was (somehow?) already deleted without me clearing this table
		IEex_GameObjectData[actorID] = nil
		return
	end

	if IEex_ReadByte(share + 0x4, 0) == 0x31 then

		local myData = IEex_GameObjectData[actorID]
		local luaDerivedStats = myData.luaDerivedStats
		local luaTempStats = myData.luaTempStats

		for _, luaStat in ipairs(IEex_RegisteredLuaStats) do
			local cleanupFunc = luaStat.cleanup
			if cleanupFunc then
				local myData = IEex_GameObjectData[actorID]
				cleanupFunc(luaDerivedStats)
				cleanupFunc(luaTempStats)
			end
		end
	end

	IEex_GameObjectData[actorID] = nil
end

function IEex_OnGameObjectsBeingCleaned()

	for actorID, myData in pairs(IEex_GameObjectData) do

		local share = IEex_GetActorShare(actorID)
		if share ~= 0x0 and IEex_ReadByte(share + 0x4, 0) == 0x31 then

			for _, luaStat in ipairs(IEex_RegisteredLuaStats) do
				local cleanupFunc = luaStat.cleanup
				if cleanupFunc then
					cleanupFunc(myData.luaDerivedStats)
					cleanupFunc(myData.luaTempStats)
				end
			end
		end
	end

	IEex_GameObjectData = {}
end

function IEex_OnReloadStats(share)

	if share == 0x0 then return end
	if IEex_ReadByte(share + 0x4, 0) == 0x31 then

		local actorID = IEex_GetActorIDShare(share)
		local luaDerivedStats = IEex_GameObjectData[actorID].luaDerivedStats

		for _, luaStat in ipairs(IEex_RegisteredLuaStats) do
			local reloadFunc = luaStat.reload
			if reloadFunc then
				reloadFunc(luaDerivedStats)
			end
		end
	end
end

function IEex_OnUpdateTempStats(share)

	if share == 0x0 then return end
	if IEex_ReadByte(share + 0x4, 0) == 0x31 then

		local actorID = IEex_GetActorIDShare(share)
		local myData = IEex_GameObjectData[actorID]
		local luaDerivedStats = myData.luaDerivedStats
		local luaTempStats = myData.luaTempStats

		for _, luaStat in ipairs(IEex_RegisteredLuaStats) do
			local copyFunc = luaStat.copy
			if copyFunc then
				copyFunc(luaDerivedStats, luaTempStats)
			end
		end
	end
end
