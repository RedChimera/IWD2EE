
IEex_ScreenEffectsGlobalFunctions = {}

function IEex_AddScreenEffectsGlobal(func_name, func)
	IEex_ScreenEffectsGlobalFunctions[func_name] = func
end

function IEex_ScreenEffectsFunc(pEffect, pSprite)

	local actorID = IEex_GetActorIDShare(pSprite)
	local effectResource = IEex_ReadLString(pEffect + 0x2C, 8)

	local stats = IEex_AccessLuaStats(actorID)
	table.insert(IEex_GameObjectData[actorID].luaDerivedStats.screenEffects, {
		["pOriginatingEffect"] = pEffect,
		["functionName"] = effectResource,
	})

end

function IEex_OnCheckAddScreenEffectsHook(pEffect, pSprite)
	IEex_WriteDword(pEffect + 0x68, IEex_GetGameTick())
	for func_name, func in pairs(IEex_ScreenEffectsGlobalFunctions) do
		if func(pEffect, pSprite) then
			return true
		end
	end

	local actorID = IEex_GetActorIDShare(pSprite)
	local screenList = IEex_AccessLuaStats(actorID).screenEffects

	for _, entry in ipairs(screenList) do

		local immunityFunction = _G[entry.functionName]

		if immunityFunction and immunityFunction(entry.pOriginatingEffect, pEffect, pSprite) then
			return true
		end
	end

	return false
end

(function()

	IEex_AddScreenEffectsGlobal("EXEFFMOD", function(effectData, creatureData)
		local targetID = IEex_ReadDword(creatureData + 0x34)
		local sourceID = IEex_ReadDword(effectData + 0x10C)
		if not IEex_IsSprite(sourceID, true) then return false end
		local internal_flags = IEex_ReadDword(effectData + 0xC8)
		local opcode = IEex_ReadDword(effectData + 0xC)
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

	IEex_RegisterLuaStat({
		["reload"] = function(stats)
			stats.screenEffects = {}
		end,
		["copy"] = function(sourceStats, destStats)
			destStats.screenEffects = {}
			for _, entry in ipairs(sourceStats.screenEffects) do
				table.insert(destStats.screenEffects, entry)
			end
		end,
	})

end)()
