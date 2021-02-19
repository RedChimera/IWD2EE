
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
	local vfptr = IEex_ReadDword(share)
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
function IEex_Extern_OnPostCreatureProcessEffectList(creatureData)
	IEex_AssertThread(IEex_Thread.Async, true)
	local targetID = IEex_GetActorIDShare(creatureData)
	if not IEex_IsSprite(targetID, false) then return end
	local onTickFunctionsCalled = {}
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theresource = IEex_ReadLString(eData + 0x30, 8)
		if theopcode == 500 and ((ex_on_tick_functions[theresource] == 1 and onTickFunctionsCalled[theresource] == nil) or ex_on_tick_functions[theresource] == 2) then
			onTickFunctionsCalled[theresource] = true
			_G[theresource](eData + 0x4, creatureData, true)
		end
	end)
--[[
	local areaData = IEex_ReadDword(creatureData + 0x12)
	if areaData > 0 then

		local isPC = false
		for i = 0, 5, 1 do
			if targetID == IEex_GetActorIDCharacter(i) then
				isPC = true
				IEex_WriteByte(areaData + 0x864, -51)
				IEex_WriteWord(areaData + 0x86E, 255)
				IEex_WriteByte(areaData + 0x870, -65)
				IEex_WriteByte(areaData + 0x87A, 115)
				IEex_WriteByte(areaData + 0xB16, 1)
				local visualRange = IEex_ReadSignedWord(areaData + 0x86E, 0x0)
				
				if IEex_GetActorSpellState(targetID, 215) then
					IEex_DS(visualRange)
					if visualRange == 0 or visualRange == 14 then
						
						IEex_WriteWord(areaData + 0x86E, 255)
					end
				else
					if visualRange == 255 then
						IEex_WriteWord(areaData + 0x86E, 0)
					end
				end
				
			end
		end
		if not isPC then
--			IEex_WriteByte(areaData + 0x864, 12)
			IEex_WriteWord(areaData + 0x86E, 14)
--			IEex_WriteByte(areaData + 0x870, 10)
--			IEex_WriteByte(areaData + 0x87A, 6)
--			IEex_WriteByte(areaData + 0xB16, 0)
		end
	end
--]]
	for funcName, funcCondition in pairs(ex_on_tick_functions) do
		if funcCondition == 0 then
			_G[funcName](creatureData)
		end
	end
end

-- Return:
--	 true  - To restrict actionbar
--	 false - To allow actionbar customization
function IEex_Extern_RestrictCreatureActionbar(creatureData, buttonType)
	IEex_AssertThread(IEex_Thread.Async, true)
	-- Restrict customization if not PC
	return IEex_ReadByte(creatureData + 0x24, 0x0) ~= 2
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
