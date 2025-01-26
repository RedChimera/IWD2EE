
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

function IEex_AccessSpriteLuaStats(sprite)
	local bAllowEffectListCall = IEex_ReadDword(sprite + 0x72A4) == 1
	return bAllowEffectListCall
		and IEex_Helper_GetBridge("IEex_DerivedStatsData", sprite + 0x920)
		or  IEex_Helper_GetBridge("IEex_DerivedStatsData", sprite + 0x1778)
end

function IEex_AccessActorLuaStats(actorID)
	return IEex_AccessSpriteLuaStats(IEex_GetActorShare(actorID))
end

function IEex_EnsureActorEffectListProcessed(objectID)
	-- Force the creature's effects list to be evaluated if it hasn't already.
	local sprite = IEex_GetActorShare(objectID)
	if not IEex_IsObjectSprite(sprite, true) then return end
	if not IEex_Helper_GetBridge("IEex_GameObjectData", objectID, "bEffectsHandled") then
		-- m_newEffect = 1, to force an effects list process
		IEex_WriteDword(sprite + 0x562C, 1)
		-- CGameSprite_ProcessEffectList()
		IEex_Call(0x72DE60, {}, sprite, 0x0)
	end
end

function IEex_EnsureSpriteEffectListProcessed(sprite)
	-- Force the creature's effects list to be evaluated if it hasn't already.
	if not IEex_IsObjectSprite(sprite, true) then return end
	local objectID = IEex_ReadDword(sprite + 0x5C)
	if not IEex_Helper_GetBridge("IEex_GameObjectData", objectID, "bEffectsHandled") then
		-- m_newEffect = 1, to force an effects list process
		IEex_WriteDword(sprite + 0x562C, 1)
		-- CGameSprite_ProcessEffectList()
		IEex_Call(0x72DE60, {}, sprite, 0x0)
	end
end

-------------------
-- Thread: Async --
-------------------

ex_cre_initializing = {}
ex_cre_effects_initializing = {}

function IEex_Extern_OnGameObjectAdded(actorID)

	IEex_AssertThread(IEex_Thread.Async, true)

	local share = IEex_GetActorShare(actorID)
	if share == 0x0 then
		print("[IEex_OnGameObjectAdded] Engine attempted to add invalid object?")
		return
	end
	if IEex_ReadByte(share + 0x4) ~= 0x31 then return end

	ex_cre_initializing[actorID] = true
	ex_cre_effects_initializing[actorID] = true
	
end

function IEex_Extern_OnGameObjectBeingDeleted(actorID)

	IEex_AssertThread(IEex_Thread.Async, true)

	local share = IEex_GetActorShare(actorID)
	if share == 0x0 then
		-- Just in case the object was (somehow?) already deleted without me clearing this table
		IEex_Helper_EraseBridgeKey("IEex_GameObjectData", actorID)
		return
	end
	if ex_record_projectile_position[share] ~= nil then
		ex_record_projectile_position[share] = nil
	end
	if ex_record_temporal_position[share] ~= nil then
		ex_record_temporal_position[share] = nil
	end
	if IEex_ReadByte(share + 0x4) ~= 0x31 then return end

	ex_cre_initializing[actorID] = nil
	ex_cre_effects_initializing[actorID] = nil

	local constantID = IEex_ReadDword(share + 0x700)
	if constantID ~= -1 then
		IEex_Helper_EraseBridgeKey("IEex_ConstantID", constantID)
	end
	IEex_Helper_EraseBridgeKey("IEex_EnlargedAnimation", actorID)
	IEex_Helper_EraseBridgeKey("IEex_GameObjectData", actorID)
end

function IEex_Extern_OnUpdateTempStats(share)
	IEex_AssertThread(IEex_Thread.Async, true)
	if share == 0x0 then return end
	if IEex_ReadByte(share + 0x4) ~= 0x31 then return end
end

function IEex_Extern_OnPostCreatureHandleEffects(creatureData)
	IEex_AssertThread(IEex_Thread.Async, true)
	IEex_Helper_SetBridge("IEex_GameObjectData", IEex_GetActorIDShare(creatureData), "bEffectsHandled", true)
end

-- Return:
--	 true  - To restrict actionbar
--	 false - To allow actionbar customization
function IEex_Extern_RestrictCreatureActionbar(creatureData, buttonType)
	IEex_AssertThread(IEex_Thread.Async, true)
	-- Restrict customization if not PC
	return (IEex_ReadByte(creatureData + 0x24) ~= 2 and bit.band(IEex_ReadDword(creatureData + 0x740), 0x400000) == 0)
end

-- Return:
--	 true  - To force default actionbar buttons on global creature unmarshal
--	 false - To keep existing actionbar buttons
function IEex_Extern_ShouldForceDefaultButtons(creatureData)
	IEex_AssertThread(IEex_Thread.Async, true)
	local actorID = IEex_GetActorIDShare(creatureData)
	if IEex_GetActorLocal(actorID, "IEex_Actionbar_Initialized") == 0 then
		IEex_SetActorLocal(actorID, "IEex_Actionbar_Initialized", 1)
		return true
	else
		return false
	end
end

function IEex_Extern_OnConstructDerivedStats(stats)
	IEex_AssertThread(IEex_Thread.Both, true)
	IEex_Helper_SynchronizedBridgeOperation("IEex_DerivedStatsData", function()
		local statsData = IEex_Helper_GetBridgeCreateNL("IEex_DerivedStatsData", stats)
		local numStats = IEex_Helper_GetBridgeNumIntsNL("IEex_RegisteredLuaStats")
		for i = 1, numStats do
			local entry = IEex_Helper_GetBridgeNL("IEex_RegisteredLuaStats", i)
			local initFunc = _G[IEex_Helper_GetBridgeNL(entry, "init")]
			if initFunc then
				initFunc(statsData)
			end
		end
	end)
end

-- This is only called on m_derivedStats
function IEex_Extern_OnReloadDerivedStats(stats, sprite)
	IEex_AssertThread(IEex_Thread.Async, true)
	IEex_Helper_SynchronizedBridgeOperation("IEex_DerivedStatsData", function()
		local statsData = IEex_Helper_GetBridgeNL("IEex_DerivedStatsData", stats)
		local numStats = IEex_Helper_GetBridgeNumIntsNL("IEex_RegisteredLuaStats")
		for i = 1, numStats do
			local reloadFunc = _G[IEex_Helper_GetBridgeNL("IEex_RegisteredLuaStats", i, "reload")]
			if reloadFunc then
				reloadFunc(statsData)
			end
		end
	end)
end

function IEex_Extern_OnDerivedStatsOperatorEqu(this, that)
	IEex_AssertThread(IEex_Thread.Both, true)
	IEex_Helper_SynchronizedBridgeOperation("IEex_DerivedStatsData", function()
		local destData = IEex_Helper_GetBridgeNL("IEex_DerivedStatsData", this)
		local sourceData = IEex_Helper_GetBridgeNL("IEex_DerivedStatsData", that)
		local numStats = IEex_Helper_GetBridgeNumIntsNL("IEex_RegisteredLuaStats")
		for i = 1, numStats do
			local copyFunc = _G[IEex_Helper_GetBridgeNL("IEex_RegisteredLuaStats", i, "copy")]
			if copyFunc then
				copyFunc(sourceData, destData)
			end
		end
	end)
end

function IEex_Extern_OnDestructDerivedStats(stats)
	IEex_AssertThread(IEex_Thread.Async, true)
	local statsData = IEex_Helper_GetBridgeNL("IEex_DerivedStatsData", stats)
	local numStats = IEex_Helper_GetBridgeNumIntsNL("IEex_RegisteredLuaStats")
	for i = 1, numStats do
		local cleanupFunc = _G[IEex_Helper_GetBridgeNL("IEex_RegisteredLuaStats", i, "cleanup")]
		if cleanupFunc then
			cleanupFunc(statsData)
		end
	end
end

function IEex_Extern_OnPostCreatureProcessEffectList(creatureData)
	IEex_AssertThread(IEex_Thread.Async, true)
	local targetID = IEex_GetActorIDShare(creatureData)
--[[
	if not IEex_IsPartyMember(targetID) and IEex_GetActorState(targetID, 0x800) then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 32,
["target"] = 2,
["timing"] = 9,
["source_target"] = targetID,
["source_id"] = targetID
})
	end
--]]
	if not IEex_IsSprite(targetID, true) and not IEex_IsPartyMember(targetID) then return end
	if ex_full_ability_score_cap > 40 then
		for i = 0, 5, 1 do
			local statID = 37 + i
			if statID == 37 then
				statID = 36
			end
			if IEex_ReadSignedWord(creatureData + 0x974 + i * 0x2) == 40 then
				IEex_WriteWord(creatureData + 0x974 + i * 0x2, IEex_GetActorFullStat(targetID, statID))
			end
		end
	end
	local tempFlags = IEex_ReadWord(creatureData + 0x9FA)
	if bit.band(tempFlags, 0x4) > 0 then
		IEex_WriteWord(creatureData + 0x9FA, bit.band(tempFlags, 0xFFFB))
		IEex_WriteWord(creatureData + 0x97E, IEex_ReadSignedWord(creatureData + 0x97E) - ex_courteous_magocracy_charisma_bonus)
	end
	local onTickFunctionsCalled = {}
	local extraFlags = IEex_ReadDword(creatureData + 0x740)
	if ex_cre_initializing[targetID] then
		ex_cre_initializing[targetID] = nil
		if targetID == IEex_GetActorIDCharacter(0) then
			ex_dead_pc_equipment_record = {}
			ex_reform_party_button_added = 0
			for bt = 0, 30, 1 do
				ex_global_effect_timers[bt + 1] = IEex_GetGlobal("EX_GLOBEF" .. bt)
			end
		end
		if extraFlags == -1 or extraFlags == -65536 or extraFlags == -50393088 then
			extraFlags = 0
			IEex_WriteDword(creatureData + 0x740, extraFlags)
		elseif extraFlags < 0 then
			extraFlags = bit.band(extraFlags, 0x31000)
			IEex_WriteDword(creatureData + 0x740, extraFlags)
		end
		if bit.band(extraFlags, 0x3000000) > 0 then
			extraFlags = bit.band(extraFlags, 0xFCFFFFFF)
			IEex_WriteDword(creatureData + 0x740, extraFlags)
		end
		local constantID = IEex_ReadDword(creatureData + 0x700)
		if constantID == -1 then
			constantID = IEex_GetGlobal("EX_CONSTANT_ID") + 1
			IEex_WriteDword(creatureData + 0x700, constantID)
			IEex_SetGlobal("EX_CONSTANT_ID", constantID)
		end
		IEex_Helper_SetBridge("IEex_ConstantID", constantID, targetID)
	end
	if ex_cre_effects_initializing[targetID] then
		local unknownSourceEffectsRemaining = false
		IEex_IterateActorTimedEffects(targetID, function(eData)
			local theconstantID = IEex_ReadDword(eData + 0x68)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local thesourceID = IEex_ReadDword(eData + 0x110)
			if theconstantID > 0 and thesourceID <= 0 then
				local realSourceID = IEex_Helper_GetBridge("IEex_ConstantID", theconstantID)
				if realSourceID ~= nil then
					IEex_WriteDword(eData + 0x110, realSourceID)
				else
					unknownSourceEffectsRemaining = true
				end
			end
		end)
		if not unknownSourceEffectsRemaining then
			ex_cre_effects_initializing[targetID] = nil
		end
	end
	local usedFunction = false
	local foundOpcodeFunction = true
	while foundOpcodeFunction do
		foundOpcodeFunction = false
		IEex_IterateActorEffects(targetID, function(eData, list, node)
			if not foundOpcodeFunction then
				local theopcode = IEex_ReadDword(eData + 0x10)
				local thetiming = IEex_ReadDword(eData + 0x24)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				local theinternal_flags = IEex_ReadDword(eData + 0xD8)
				local funcCondition = ex_on_tick_functions[theresource]
				if theopcode == 500 and ((funcCondition == 1 and onTickFunctionsCalled[theresource] == nil) or funcCondition == 2 or funcCondition == -1) and (thetiming == 1 or thetiming == 2 or thetiming == 9 or thetiming == 4096) then
					usedFunction = true
					if bit.band(theinternal_flags, 0x80) == 0 and funcCondition ~= -1 then
						foundOpcodeFunction = true
						onTickFunctionsCalled[theresource] = true
						IEex_WriteDword(eData + 0xD8, bit.bor(theinternal_flags, 0x80))
						_G[theresource](eData + 0x4, creatureData, true)
						-- Uncomment the following to properly remove the effect if the listener set m_done
						--if IEex_ReadDword(eData + 0x114) ~= 0 then
						--	IEex_Call(0x7FB3E3, {node}, list, 0x0) -- CPtrList_RemoveAt
						--	IEex_Call(IEex_ReadDword(IEex_ReadDword(eData + 0x4)), {1}, eData + 0x4, 0x0) -- Destruct + Free
						--end
					end
				end
			end
		end)
	end
	for funcName, funcCondition in pairs(ex_on_tick_functions) do
		if funcCondition ~= 0 and not onTickFunctionsCalled[funcName] and ex_on_tick_default_functions[funcName] then
			_G[ex_on_tick_default_functions[funcName]](creatureData)
		end
	end

	if usedFunction and not foundOpcodeFunction then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local theinternal_flags = IEex_ReadDword(eData + 0xD8)
			if theopcode == 500 and bit.band(theinternal_flags, 0x80) > 0 then
				IEex_WriteDword(eData + 0xD8, bit.band(theinternal_flags, 0xFFFFFF7F))
			end
		end)
	end
	local tick = IEex_GetGameTick()
	if IEex_GetActorState(targetID, 0x1) and tick % 3 == 0 then
--[[
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "MEINCAPA",
["parent_resource"] = "MEINCAPA",
["source_id"] = targetID,
})
--]]
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = 1,
["parameter2"] = 216,
["special"] = 4,
["parent_resource"] = "MEINCAPA",
["source_id"] = targetID,
})
--[[
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 1,
["resource"] = "MEINCAPA",
["parent_resource"] = "MEINCAPA",
["source_id"] = targetID,
})
--]]
	end
	if IEex_GetActorState(targetID, 0x10) and bit.band(IEex_ReadByte(creatureData + 0x8A0), 0x1) == 0 and tick % 3 == 0 then
		if IEex_GetActorStat(targetID, 104) > 0 or IEex_GetActorSpellState(targetID, 192) then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USINVSNA",
["parent_resource"] = "USINVSNA",
["source_id"] = targetID,
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter2"] = 216,
["special"] = 2,
["parent_resource"] = "USINVSNA",
["source_id"] = targetID,
})
--[[
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 1,
["resource"] = "USINVSNA",
["parent_resource"] = "USINVSNA",
["source_id"] = targetID,
})
--]]
		end
	end
	extraFlags = IEex_ReadDword(creatureData + 0x740)
	local visualHeight = IEex_ReadDword(creatureData + 0xE)
	local speed = IEex_ReadSignedWord(creatureData + 0x722)
	if bit.band(extraFlags, 0x6100) == 0x4000 and visualHeight == 0 and speed == 0 and IEex_ReadSignedByte(creatureData + 0x5622) < 0 and not usedFunction and not IEex_IsPartyMember(targetID) and IEex_CheckGlobalEffect(0xFFFFFFFF) == false and not IEex_GetActorSpellState(targetID, 218) then return end

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
				local visualRange = IEex_ReadSignedWord(areaData + 0x86E)

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
			if _G[funcName](creatureData) == true then
				usedFunction = true
			end
		end
	end
	if not usedFunction then
		extraFlags = IEex_ReadDword(creatureData + 0x740)
		IEex_WriteDword(creatureData + 0x740, bit.bor(extraFlags, 0x4000))
	end
end

------------------
-- Thread: Both --
------------------

function IEex_Extern_OnGameObjectsBeingCleaned()
	IEex_AssertThread(IEex_Thread.Both, true)
	IEex_Helper_ClearBridge("IEex_GameObjectData")
end

function IEex_Extern_OnAfterConstructSprite(sprite)
	IEex_AssertThread(IEex_Thread.Both, true)
	-- Import single pip feats into the new stats system
	IEex_EnsureSpriteEffectListProcessed(sprite)
--[[
	local baseStats = IEex_GetSpriteBaseStats(sprite)
	for featID = 0, 74 do
		if not IEex_Feats_DefaultMaxPips[featID] and IEex_IsFeatTakenInBaseStats(baseStats, featID) then
			IEex_SetSpriteFeatCountStat(sprite, featID, 1, true)
		end
	end
--]]
end
