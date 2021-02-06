
function IEex_RegisterLuaStat(attributes)

	-- ["init"] = function(stats)
	-- ["reload"] = function(stats)
	-- ["copy"] = function(sourceStats, destStats)
	-- ["cleanup"] = function(stats)

	IEex_Helper_SynchronizedBridgeOperation("IEex_RegisteredLuaStats", function()
		local group = IEex_AppendBridgeTableNL("IEex_RegisteredLuaStats")
		IEex_Helper_SetBridgeNL(group, "init",    attributes["init"])
		IEex_Helper_SetBridgeNL(group, "reload",  attributes["reload"])
		IEex_Helper_SetBridgeNL(group, "copy",    attributes["copy"])
		IEex_Helper_SetBridgeNL(group, "cleanup", attributes["cleanup"])
	end)
end

function IEex_AccessLuaStats(actorID)
	local share = IEex_GetActorShare(actorID)
	local bAllowEffectListCall = IEex_ReadDword(share + 0x72A4) == 1
	return bAllowEffectListCall
		and IEex_Helper_GetBridge("IEex_GameObjectData", actorID, "luaDerivedStats")
		or  IEex_Helper_GetBridge("IEex_GameObjectData", actorID, "luaTempStats")
end

-------------------
-- Thread: Async --
-------------------

function IEex_Extern_OnGameObjectAdded(actorID)

	IEex_AssertThread(IEex_Thread.Async, true)

	local share = IEex_GetActorShare(actorID)
	if share == 0x0 then
		print("[IEex_OnGameObjectAdded] Engine attempted to add invalid object?")
		return
	end

	if IEex_ReadByte(share + 0x4, 0) ~= 0x31 then return end

	IEex_Helper_SynchronizedBridgeOperation("IEex_GameObjectData", function()
		local luaDerivedStats = IEex_Helper_GetBridgeCreateNL("IEex_GameObjectData", actorID, "luaDerivedStats")
		local luaTempStats = IEex_Helper_GetBridgeCreateNL("IEex_GameObjectData", actorID, "luaTempStats")
		local numStats = IEex_Helper_GetBridgeNumIntsNL("IEex_RegisteredLuaStats")
		for i = 1, numStats, 1 do
			local entry = IEex_Helper_GetBridgeNL("IEex_RegisteredLuaStats", i)
			local initFunc = _G[IEex_Helper_GetBridgeNL(entry, "init")]
			if initFunc then
				initFunc(luaDerivedStats)
				initFunc(luaTempStats)
			end
			local reloadFunc = _G[IEex_Helper_GetBridgeNL(entry, "reload")]
			if reloadFunc then
				reloadFunc(luaDerivedStats)
			end
		end
	end)
end

function IEex_Extern_OnGameObjectBeingDeleted(actorID)

	IEex_AssertThread(IEex_Thread.Async, true)

	local share = IEex_GetActorShare(actorID)
	if share == 0x0 then
		-- Just in case the object was (somehow?) already deleted without me clearing this table
		IEex_Helper_EraseBridgeKey("IEex_GameObjectData", actorID)
		return
	end

	if IEex_ReadByte(share + 0x4, 0) ~= 0x31 then return end

	IEex_Helper_SynchronizedBridgeOperation("IEex_GameObjectData", function()
		local luaDerivedStats = IEex_Helper_GetBridgeNL("IEex_GameObjectData", actorID, "luaDerivedStats")
		local luaTempStats = IEex_Helper_GetBridgeNL("IEex_GameObjectData", actorID, "luaTempStats")
		local numStats = IEex_Helper_GetBridgeNumIntsNL("IEex_RegisteredLuaStats")
		for i = 1, numStats, 1 do
			local cleanupFunc = _G[IEex_Helper_GetBridgeNL("IEex_RegisteredLuaStats", i, "cleanup")]
			if cleanupFunc then
				cleanupFunc(luaDerivedStats)
				cleanupFunc(luaTempStats)
			end
		end
		IEex_Helper_EraseBridgeKeyNL("IEex_GameObjectData", actorID)
	end)
end

function IEex_Extern_OnReloadStats(share)

	IEex_AssertThread(IEex_Thread.Async, true)
	if share == 0x0 then return end
	if IEex_ReadByte(share + 0x4, 0) ~= 0x31 then return end

	local actorID = IEex_GetActorIDShare(share)

	local monkLevel = IEex_GetActorStat(actorID, 101)
	local fistSlot = IEex_ReadDword(share + 0x4B00)
	if not IEex_GetActorSpellState(actorID, 182) and not IEex_GetActorSpellState(actorID, 189) then
		if fistSlot > 0 and IEex_ReadLString(fistSlot + 0xC, 8) ~= ex_monk_fist_progression[monkLevel] and ex_monk_fist_progression[monkLevel] ~= nil then
			local extraFlags = IEex_ReadDword(share + 0x740)
			IEex_WriteDword(share + 0x740, bit.bor(extraFlags, 0x1000000))
		end
	else
		if fistSlot > 0 and IEex_ReadLString(fistSlot + 0xC, 8) ~= ex_incorporeal_monk_fist_progression[monkLevel] and ex_incorporeal_monk_fist_progression[monkLevel] ~= nil then
			local extraFlags = IEex_ReadDword(share + 0x740)
			IEex_WriteDword(share + 0x740, bit.bor(extraFlags, 0x2000000))
		end
	end

	IEex_Helper_SynchronizedBridgeOperation("IEex_GameObjectData", function()
		local luaDerivedStats = IEex_Helper_GetBridgeNL("IEex_GameObjectData", actorID, "luaDerivedStats")
		local numStats = IEex_Helper_GetBridgeNumIntsNL("IEex_RegisteredLuaStats")
		for i = 1, numStats, 1 do
			local reloadFunc = _G[IEex_Helper_GetBridgeNL("IEex_RegisteredLuaStats", i, "reload")]
			if reloadFunc then
				reloadFunc(luaDerivedStats)
			end
		end
	end)
end

function IEex_Extern_OnUpdateTempStats(share)

	IEex_AssertThread(IEex_Thread.Async, true)
	if share == 0x0 then return end
	if IEex_ReadByte(share + 0x4, 0) ~= 0x31 then return end

	local actorID = IEex_GetActorIDShare(share)
	IEex_Helper_SynchronizedBridgeOperation("IEex_GameObjectData", function()
		local luaDerivedStats = IEex_Helper_GetBridgeNL("IEex_GameObjectData", actorID, "luaDerivedStats")
		local luaTempStats = IEex_Helper_GetBridgeNL("IEex_GameObjectData", actorID, "luaTempStats")
		local numStats = IEex_Helper_GetBridgeNumIntsNL("IEex_RegisteredLuaStats")
		for i = 1, numStats, 1 do
			local copyFunc = _G[IEex_Helper_GetBridgeNL("IEex_RegisteredLuaStats", i, "copy")]
			if copyFunc then
				copyFunc(luaDerivedStats, luaTempStats)
			end
		end
	end)
end

function IEex_Extern_OnPostCreatureProcessEffectList(CGameSprite)
	IEex_AssertThread(IEex_Thread.Async, true)
end

------------------
-- Thread: Both --
------------------

function IEex_Extern_OnGameObjectsBeingCleaned()

	IEex_AssertThread(IEex_Thread.Both, true)

	IEex_Helper_SynchronizedBridgeOperation("IEex_GameObjectData", function()

		IEex_Helper_IterateBridgeNL("IEex_GameObjectData", function(actorID, data)

			local share = IEex_GetActorShare(actorID)
			if share == 0x0 or IEex_ReadByte(share + 0x4, 0) ~= 0x31 then return end

			local luaDerivedStats = IEex_Helper_GetBridgeNL("IEex_GameObjectData", actorID, "luaDerivedStats")
			local luaTempStats = IEex_Helper_GetBridgeNL("IEex_GameObjectData", actorID, "luaTempStats")

			local numStats = IEex_Helper_GetBridgeNumIntsNL("IEex_RegisteredLuaStats")
			for i = 1, numStats, 1 do
				local cleanupFunc = _G[IEex_Helper_GetBridgeNL("IEex_RegisteredLuaStats", i, "cleanup")]
				if cleanupFunc then
					cleanupFunc(luaDerivedStats)
					cleanupFunc(luaTempStats)
				end
			end
		end)
		IEex_Helper_ClearBridgeNL("IEex_GameObjectData")
	end)
end
