
IEex_Debug_DisableOpcodes = false
IEex_Debug_DisableScreenEffects = false

IEex_ScreenEffectsGlobalFunctions = {}

function IEex_AddScreenEffectsGlobal(func_name, func)
	IEex_ScreenEffectsGlobalFunctions[func_name] = func
end

function IEex_Extern_ScreenEffectsFunc(pEffect, pSprite)

	IEex_AssertThread(IEex_Thread.Async, true)
	if IEex_Debug_DisableScreenEffects then return end

	local actorID = IEex_GetActorIDShare(pSprite)
	local effectResource = IEex_ReadLString(pEffect + 0x2C, 8)

	IEex_Helper_SynchronizedBridgeOperation("IEex_GameObjectData", function()
		local screenEffects = IEex_Helper_GetBridgeNL("IEex_GameObjectData", actorID, "luaDerivedStats", "screenEffects")
		local newEntry = IEex_AppendBridgeTableNL(screenEffects)
		IEex_Helper_SetBridgeNL(newEntry, "pOriginatingEffect", pEffect)
		IEex_Helper_SetBridgeNL(newEntry, "functionName", effectResource)
	end)
end

function IEex_Extern_OnCheckAddScreenEffectsHook(pEffect, pSprite)

	IEex_AssertThread(IEex_Thread.Async, true)
	if IEex_Debug_DisableScreenEffects then return end

	IEex_WriteDword(pEffect + 0x68, IEex_GetGameTick())
	for func_name, func in pairs(IEex_ScreenEffectsGlobalFunctions) do
		if func(pEffect, pSprite) then
			return true
		end
	end

	local actorID = IEex_GetActorIDShare(pSprite)
	local screenList = IEex_Helper_GetBridge(IEex_AccessLuaStats(actorID), "screenEffects")
	local numEntries = IEex_Helper_GetBridgeNumInts(screenList)

	for i = 1, numEntries, 1 do
		local immunityFunction = _G[IEex_Helper_GetBridge(screenList, i, "functionName")]
		if immunityFunction and immunityFunction(IEex_Helper_GetBridge(screenList, i, "pOriginatingEffect"), pEffect, pSprite) then
			return true
		end
	end

	return false
end

-- return:
--   nil   -> to fallback to hardcoded engine implementation
--   false -> to force summon limit
--   true  -> to bypass summon limit

function IEex_Extern_OnCheckSummonLimitHook(effectData, summonerData)
	IEex_AssertThread(IEex_Thread.Async, true)
	if ex_no_summoning_limit or bit32.band(IEex_ReadDword(effectData + 0x3C), 0x10000) > 0 then return true end
	return nil
end

-- return:
--   false -> to prevent summon from counting towards hardcoded limit
--   true  -> to make summon count towards hardcoded limit
function IEex_Extern_OnAddSummonToLimitHook(effectData, summonerData, summonedData)
	IEex_AssertThread(IEex_Thread.Async, true)
	IEex_WriteDword(summonedData + 0x72C, IEex_GetActorIDShare(summonerData))
	if ex_no_summoning_limit or bit32.band(IEex_ReadDword(effectData + 0x3C), 0x10000) > 0 then return false end
	return true
end

(function()

	IEex_AddScreenEffectsGlobal("EXEFFMOD", function(effectData, creatureData)
		local targetID = IEex_GetActorIDShare(creatureData)
		local sourceID = IEex_ReadDword(effectData + 0x10C)
		local opcode = IEex_ReadDword(effectData + 0xC)
		if not IEex_IsSprite(sourceID, true) then return false end
		print("Opcode " .. opcode .. " on " .. IEex_GetActorName(targetID))
		if opcode == 500 then
			print(IEex_ReadLString(effectData + 0x2C, 8))
		end
		local internal_flags = IEex_ReadDword(effectData + 0xC8)

		local parameter1 = IEex_ReadDword(effectData + 0x18)
		local parameter2 = IEex_ReadDword(effectData + 0x1C)
		local timing = IEex_ReadDword(effectData + 0x20)
		local duration = IEex_ReadDword(effectData + 0x24)
		local time_applied = IEex_ReadDword(effectData + 0x68)
		if bit32.band(internal_flags, 0x2000000) > 0 then return false end
		local savingthrow = IEex_ReadDword(effectData + 0x3C)
		local savebonus = IEex_ReadDword(effectData + 0x40)
		local school = IEex_ReadDword(effectData + 0x48)
		local restype = IEex_ReadDword(effectData + 0x8C)
		local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
		local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
		local sourceSpell = ex_damage_source_spell[parent_resource]
		if sourceSpell == nil then
			sourceSpell = string.sub(parent_resource, 1, 7)
		end
		if opcode == 98 and restype == 1 and IEex_GetActorSpellState(sourceID, 191) then
			local healingMultiplier = 100
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 191 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if thespecial == 2 then
						healingMultiplier = healingMultiplier + theparameter1
					end
				end
			end)
			if healingMultiplier ~= 100 then
				if parameter2 ~= 3 then
					parameter1 = math.ceil(parameter1 * healingMultiplier / 100)
				else
					parameter1 = math.floor(parameter1 * 100 / healingMultiplier)
				end
				if parameter1 <= 0 then
					parameter1 = 1
				end
				IEex_WriteDword(effectData + 0x18, parameter1)
			end
		elseif opcode == 25 then
			local poisonMultiplier = 100
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 73 and theparameter2 == 6 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					poisonMultiplier = poisonMultiplier + theparameter1
				end
			end)
			if poisonMultiplier ~= 100 then
				if parameter2 ~= 3 then
					parameter1 = math.ceil(parameter1 * poisonMultiplier / 100)
				else
					parameter1 = math.floor(parameter1 * 100 / poisonMultiplier)
				end
				if parameter1 <= 0 then
					parameter1 = 1
				end
				IEex_WriteDword(effectData + 0x18, parameter1)
			end
		end
		--[[
		if IEex_GetActorSpellState(sourceID, 195) and timing ~= 1 and timing ~= 2 and timing ~= 9 and (ex_listspll[sourceSpell] ~= nil or ex_listdomn[sourceSpell] ~= nil) and (opcode ~= 500 or math.abs(duration - time_applied) > 16) then
			local durationMultiplier = 100
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 195 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if (thespecial == 0 and casterClass > 0) or (thespecial == 1 and (casterClass == 2 or casterClass == 10 or casterClass == 11)) or (thespecial == 2 and (casterClass == 3 or casterClass == 4 or casterClass == 7 or casterClass == 8)) then
						durationMultiplier = durationMultiplier + theparameter1 - 100
					end
				end
			end)
			if durationMultiplier ~= 100 then
				IEex_WriteDword(effectData + 0x24, math.ceil((duration - time_applied) * durationMultiplier / 100) + time_applied)
			end
		end
		--]]
		return false
	end)

	IEex_ScreenEffectsStats_Reload = function(stats)
		local screenEffects = IEex_Helper_GetBridgeCreateNL(stats, "screenEffects")
		IEex_Helper_ClearBridgeNL(screenEffects)
	end

	IEex_ScreenEffectsStats_Copy = function(sourceStats, destStats)

		IEex_Helper_ClearBridgeNL(destStats, "screenEffects")

		local sourceScreenEffects = IEex_Helper_GetBridgeNL(sourceStats, "screenEffects")
		local destScreenEffects = IEex_Helper_GetBridgeNL(destStats, "screenEffects")

		local numEntries = IEex_Helper_GetBridgeNumIntsNL(sourceStats)
		for i = 1, numEntries, 1 do
			IEex_Helper_SetBridgeNL(destScreenEffects, i, "pOriginatingEffect", IEex_Helper_GetBridgeNL(sourceScreenEffects, i, "pOriginatingEffect"))
			IEex_Helper_SetBridgeNL(destScreenEffects, i, "functionName", IEex_Helper_GetBridgeNL(sourceScreenEffects, i, "functionName"))
		end
	end

end)()
