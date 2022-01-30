
IEex_Debug_DisableOpcodes = false
IEex_Debug_DisableScreenEffects = false

IEex_ScreenEffectsGlobalFunctions = {}

function IEex_AddScreenEffectsGlobal(func_name, func)
	IEex_ScreenEffectsGlobalFunctions[func_name] = func
end

function IEex_Extern_OnWeaponDamageCRE(sourceShare, CGameEffect, esp)
	IEex_AssertThread(IEex_Thread.Async, true)

	local curWeaponIn = IEex_ReadDword(esp + 0x4)
	local pLauncher = IEex_ReadDword(esp + 0x8)
	local bCriticalDamage = IEex_ReadDword(esp + 0x10) ~= 0
	local bLastSwing = IEex_ReadDword(esp + 0x24) ~= 0
	-- curWeaponIn.helper.cResRef
	local weaponRes = IEex_ReadLString(curWeaponIn + 0xC, 8)
	local launcherRes = pLauncher ~= 0x0
		-- pLauncher.helper.cResRef
		and IEex_ReadLString(pLauncher + 0xC, 8)
		or ""

	-- CGameSprite_GetSelectedOffhandWeaponIndex
	local offhandIndex = IEex_Call(0x726800, {}, sourceShare, 0x0)
	-- m_equipment[offhandIndex]
	local offhandItem = IEex_ReadDword(sourceShare + 0x4AD8 + offhandIndex * 4)
	local m_curItemSlotNum = IEex_ReadByte(sourceShare + 0x4BA4, 0)

	local bIsOffhand = false

	if bLastSwing and m_curItemSlotNum ~= 0x2A and offhandItem ~= 0 then
		-- CItem_GetItemType
		local offhandItemType = bit.band(IEex_Call(0x4E97E0, {}, offhandItem, 0x0), 0xFFFF)
		bIsOffhand = offhandItemType ~= 41 -- Bucklers
				 and offhandItemType ~= 47 -- Large shields
				 and offhandItemType ~= 49 -- Medium shields
				 and offhandItemType ~= 53 -- Small shields
	end
--[[
	local sourceID = IEex_GetActorIDShare(sourceShare)
	if bCriticalDamage and IEex_GetActorSpellState(sourceID, 195) then
		local baseCriticalMultiplier = 2
		local criticalMultiplier = baseCriticalMultiplier
		local itemType = 0
		local weaponWrapper = IEex_DemandRes(weaponRes, "ITM")
		if weaponWrapper:isValid() then
			local weaponData = weaponWrapper:getData()
			itemType = IEex_ReadWord(weaponData + 0x1C, 0x0)
			if ex_item_type_critical[itemType] ~= nil then
				baseCriticalMultiplier = ex_item_type_critical[itemType][2]
				criticalMultiplier = baseCriticalMultiplier
			end
			local effectOffset = IEex_ReadDword(weaponData + 0x6A)
			local numGlobalEffects = IEex_ReadWord(weaponData + 0x70, 0x0)
			for i = 0, numGlobalEffects - 1, 1 do
				local offset = weaponData + effectOffset + i * 0x30
				local theopcode = IEex_ReadWord(offset, 0x0)
				local theparameter2 = IEex_ReadDword(offset + 0x8)
				local thesavingthrow = IEex_ReadDword(offset + 0x24)
				if theopcode == 288 and theparameter2 == 195 and bit.band(thesavingthrow, 0x10000) > 0 then
					local theparameter1 = IEex_ReadDword(offset + 0x4)
					criticalMultiplier = criticalMultiplier + theparameter1
				end
			end
		end
		if launcherRes ~= "" then
			local launcherWrapper = IEex_DemandRes(launcherRes, "ITM")
			if launcherWrapper:isValid() then
				local launcherData = launcherWrapper:getData()
				local effectOffset = IEex_ReadDword(launcherData + 0x6A)
				local numGlobalEffects = IEex_ReadWord(launcherData + 0x70, 0x0)
				for i = 0, numGlobalEffects - 1, 1 do
					local offset = launcherData + effectOffset + i * 0x30
					local theopcode = IEex_ReadWord(offset, 0x0)
					local theparameter2 = IEex_ReadDword(offset + 0x8)
					local thesavingthrow = IEex_ReadDword(offset + 0x24)
					if theopcode == 288 and theparameter2 == 195 and bit.band(thesavingthrow, 0x10000) > 0 then
						local theparameter1 = IEex_ReadDword(offset + 0x4)
						criticalMultiplier = criticalMultiplier + theparameter1
					end
				end
			end
		end
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			local thespecial = IEex_ReadDword(eData + 0x48)
			if theopcode == 288 and theparameter2 == 195 and bit.band(thesavingthrow, 0x10000) == 0 and (thespecial == -1 or thespecial == itemType) then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				criticalMultiplier = criticalMultiplier + theparameter1
			end
		end)
		local damage = IEex_ReadDword(CGameEffect + 0x18)
		IEex_WriteDword(CGameEffect + 0x18, math.floor(damage / baseCriticalMultiplier) * criticalMultiplier)
		weaponWrapper:free()
		launcherWrapper:free()
	end
--]]

	-- m_sourceRes = "IEEX_DAM"
	IEex_WriteLString(CGameEffect + 0x90, "IEEX_DAM", 8)
	-- m_res2 = weaponRes
	IEex_WriteLString(CGameEffect + 0x6C, weaponRes, 8)
	-- m_res3 = launcherRes
	IEex_WriteLString(CGameEffect + 0x74, launcherRes, 8)
	-- m_savingThrow: bit16 = bCriticalDamage, bit17 = bIsOffhand

	local parameter3 = IEex_ReadDword(CGameEffect + 0x5C)
	if bCriticalDamage then
		parameter3 = bit.bor(parameter3, 0x10000)
	end
	if bIsOffhand then
		parameter3 = bit.bor(parameter3, 0x20000)
	end
	IEex_WriteDword(CGameEffect + 0x5C, parameter3)
--[[
	IEex_WriteDword(CGameEffect + 0x3C, IEex_Flags({
		bit.lshift(bCriticalDamage and 1 or 0, 16),
		bit.lshift(bIsOffhand and 1 or 0, 17),
	}))
--]]
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
	local actorID = IEex_GetActorIDShare(pSprite)
	local sourceID = IEex_ReadDword(pEffect + 0x10C)
	if pSprite > 0 and bit.band(IEex_ReadDword(pSprite + 0x740), 0x1000000) > 0 and IEex_ReadDword(pSprite + 0x740) > 0 then
		local opcode = IEex_ReadDword(pEffect + 0xC)
		local parameter1 = IEex_ReadDword(pEffect + 0x18)
		local parameter2 = IEex_ReadDword(pEffect + 0x1C)
		local parameter3 = IEex_ReadDword(pEffect + 0x5C)
		local timing = IEex_ReadDword(pEffect + 0x20)
		local duration = IEex_ReadDword(pEffect + 0x24)
		local resource = IEex_ReadLString(pEffect + 0x2C, 8)
		local savingthrow = IEex_ReadDword(pEffect + 0x3C)
		local special = IEex_ReadDword(pEffect + 0x44)
		local parent_resource = IEex_ReadLString(pEffect + 0x90, 8)
		IEex_DisplayString(IEex_GetActorName(actorID) .. " - Opcode: " .. opcode .. ", Parameter1: " .. parameter1 .. ", Parameter2: " .. parameter2 .. ", Parameter3: " .. parameter3 .. ", Special: " .. special .. ", Timing: " .. timing .. ", Duration: " .. duration .. ", Resource: \"" .. resource .. "\", Flags: " .. IEex_ToHex(savingthrow, 0, false) .. ", Parent resource: \"" .. parent_resource .. "\", Source: " .. IEex_GetActorName(sourceID))
	end
	if IEex_IsSprite(sourceID, true) then
		local sourceData = IEex_GetActorShare(sourceID)
		local constantID = IEex_ReadDword(sourceData + 0x700)
		if constantID ~= -1 then
			IEex_WriteDword(pEffect + 0x64, constantID)
		end
	end
	IEex_WriteDword(pEffect + 0x68, IEex_GetGameTick())
	IEex_WriteDword(pEffect + 0xD0, math.random(0x7FFFFFFF))
	for func_name, func in pairs(IEex_ScreenEffectsGlobalFunctions) do
		if func(pEffect, pSprite) then
			return true
		end
	end

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
	if ex_no_summoning_limit or bit.band(IEex_ReadDword(effectData + 0x3C), 0x10000) > 0 then return true end
	return nil
end

-- return:
--   false -> to make summon count towards hardcoded limit
--   true  -> to prevent summon from counting towards hardcoded limit
function IEex_Extern_OnAddSummonToLimitHook(effectData, summonerData, summonedData)
	IEex_AssertThread(IEex_Thread.Async, true)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	if IEex_ReadByte(summonerData + 0x4, 0x0) == 0x31 then
		IEex_WriteDword(summonedData + 0x72C, IEex_ReadDword(summonerData + 0x700))
		if bit.band(savingthrow, 0x100000) > 0 then
			IEex_WriteDword(summonedData + 0x740, bit.bor(IEex_ReadDword(summonedData + 0x740), 0x100000))
		end
	end
	IEex_WriteByte(summonedData + 0x730, IEex_ReadByte(effectData + 0xC4, 0x0))
	IEex_WriteByte(summonedData + 0x731, IEex_ReadByte(effectData + 0xC5, 0x0))
	IEex_WriteByte(summonedData + 0x732, IEex_ReadByte(effectData + 0xC6, 0x0))
	local summonedID = IEex_GetActorIDShare(summonedData)
	local summonerID = IEex_GetActorIDShare(summonerData)
	IEex_ApplyEffectToActor(summonedID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 9,
["resource"] = "MESUCREA",
["parent_resource"] = "USSUCREA",
["savingthrow"] = savingthrow,
["casterlvl"] = IEex_ReadDword(effectData + 0xC4),
["source_id"] = summonerID
})
	if ex_no_summoning_limit or bit.band(IEex_ReadDword(effectData + 0x3C), 0x10000) > 0 then return true end
	return false
end
ex_apply_effects_flags = {}
ex_empowerable_opcodes = {[0] = true, [1] = true, [6] = true, [10] = true, [12] = true, [15] = true, [17] = true, [18] = true,
[19] = true, [21] = true, [22] = true, [25] = true, [27] = true, [28] = true, [29] = true, [30] = true, [31] = true, 
[33] = true, [34] = true, [35] = true, [36] = true, [37] = true, [44] = true, [49] = true, [54] = true, [59] = true, 
[60] = true, [67] = true, [73] = true, [78] = true, [84] = true, [85] = true, [86] = true, [87] = true, [88] = true, [89] = true,
[90] = true, [91] = true, [92] = true, [93] = true, [94] = true, [95] = true, [97] = true, [98] = true, [111] = true, 
[126] = true, [127] = true, [129] = true, [130] = true, [131] = true, [132] = true, [137] = true, [166] = true, [167] = true, 
[173] = true, [176] = true, [189] = true, [190] = true, [191] = true, [218] = true, 
[238] = true, [239] = true, [247] = true, [255] = true, [266] = true, 
[281] = true, [297] = true, [298] = true, [410] = true, [411] = true, [416] = true, [431] = true, [432] = true, [436] = true,}
(function()

	IEex_AddScreenEffectsGlobal("EXEFFMOD", function(effectData, creatureData)
		local targetID = IEex_GetActorIDShare(creatureData)
		local sourceID = IEex_ReadDword(effectData + 0x10C)
		local opcode = IEex_ReadDword(effectData + 0xC)
--[[
		if targetID == IEex_GetActorIDCharacter(0) then

			IEex_DS(opcode)
			if opcode == 20 then
				IEex_PrintData(effectData, 0xD0)
			end

			if opcode == 17 then
				IEex_DS("parameter1: " .. IEex_ReadDword(effectData + 0x18) .. ", parameter2: " .. IEex_ReadDword(effectData + 0x1C) .. ", sourceID: " .. sourceID)
			elseif opcode == 276 then
				IEex_DS("parameter2: " .. IEex_ReadDword(effectData + 0x1C))
			end

		end
--]]

--[[
		print("Opcode " .. opcode .. " on " .. IEex_GetActorName(targetID))
		if opcode == 500 then
			print(IEex_ReadLString(effectData + 0x2C, 8))
		end
--]]
--		if not IEex_IsSprite(sourceID, true) then return false end
		local sourceData = IEex_GetActorShare(sourceID)
		if opcode == 288 or opcode >= 500 then
			IEex_WriteDword(creatureData + 0x740, bit.band(IEex_ReadDword(creatureData + 0x740), 0xFFFFBFFF))
		end
		local internalFlags = bit.bor(IEex_ReadDword(effectData + 0xCC), IEex_ReadDword(effectData + 0xD4))

		local parameter1 = IEex_ReadDword(effectData + 0x18)
		local parameter2 = IEex_ReadDword(effectData + 0x1C)
		local parameter3 = IEex_ReadDword(effectData + 0x5C)
		local dicenumber = IEex_ReadDword(effectData + 0x34)
		local dicesize = IEex_ReadDword(effectData + 0x38)
		local special = IEex_ReadDword(effectData + 0x44)
		local timing = IEex_ReadDword(effectData + 0x20)
		local duration = IEex_ReadDword(effectData + 0x24)
		local time_applied = IEex_ReadDword(effectData + 0x68)
		if bit.band(internalFlags, 0x2000000) > 0 then return false end
		local savingthrow = IEex_ReadDword(effectData + 0x3C)
		local savebonus = IEex_ReadDword(effectData + 0x40)
		local school = IEex_ReadDword(effectData + 0x48)
		local restype = IEex_ReadDword(effectData + 0x8C)
		local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
		local resource = IEex_ReadLString(effectData + 0x2C, 8)
		local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
		local sourceSpell = ex_damage_source_spell[parent_resource]
		if sourceSpell == nil then
			sourceSpell = string.sub(parent_resource, 1, 7)
		end
		local damageType = bit.band(parameter2, 0xFFFF0000)
		if opcode == 12 and parent_resource == "IEEX_DAM" and IEex_IsSprite(sourceID, true) then
--			if (bit.band(savingthrow, 0x10000) > 0 and (IEex_GetActorSpellState(sourceID, 195) or IEex_GetActorSpellState(sourceID, 225))) or bit.band(savingthrow, 0x40000) == 0 then
				local weaponRES = IEex_ReadLString(effectData + 0x6C, 8)
				local launcherRES = IEex_ReadLString(effectData + 0x74, 8)
				local baseCriticalMultiplier = 2
				local criticalMultiplier = baseCriticalMultiplier
				local itemType = 0
				local headerType = 0
				local currentHeader = IEex_ReadByte(sourceData + 0x4BA6, 0x0)
				local exhitIndexList = {}
				local onCriticalHitEffectList = {}
				local weaponWrapper = IEex_DemandRes(weaponRES, "ITM")
				if weaponWrapper:isValid() then
					local weaponData = weaponWrapper:getData()
					itemType = IEex_ReadWord(weaponData + 0x1C, 0x0)
					if ex_item_type_critical[itemType] ~= nil then
						baseCriticalMultiplier = ex_item_type_critical[itemType][2]
						criticalMultiplier = baseCriticalMultiplier
					end
					if currentHeader >= IEex_ReadSignedWord(weaponData + 0x68, 0x0) then
						currentHeader = 0
					end
					headerType = IEex_ReadByte(weaponData + 0x82 + currentHeader * 0x38, 0x0)
					local effectOffset = IEex_ReadDword(weaponData + 0x6A)
					local numGlobalEffects = IEex_ReadWord(weaponData + 0x70, 0x0)
					local numHeaderEffects = IEex_ReadWord(weaponData + 0x82 + currentHeader * 0x38 + 0x1E, 0x0)
					local headerFirstEffectIndex = IEex_ReadWord(weaponData + 0x82 + currentHeader * 0x38 + 0x20, 0x0)
					for i = 0, numHeaderEffects - 1, 1 do
						local offset = weaponData + effectOffset + (headerFirstEffectIndex + i) * 0x30
						local theopcode = IEex_ReadWord(offset, 0x0)
						local theparameter2 = IEex_ReadDword(offset + 0x8)
						local theresource = IEex_ReadLString(offset + 0x14, 8)
						if theopcode == 500 and theresource == "MEEXHIT" then
							exhitIndexList[theparameter2] = true
						end
					end
					for i = 0, numGlobalEffects - 1, 1 do
						local offset = weaponData + effectOffset + i * 0x30
						local theopcode = IEex_ReadWord(offset, 0x0)
						local theparameter2 = IEex_ReadDword(offset + 0x8)
						local thesavingthrow = IEex_ReadDword(offset + 0x24)
						if theopcode == 288 and theparameter2 == 195 and bit.band(thesavingthrow, 0x10000) > 0 then
							local theparameter1 = IEex_ReadDword(offset + 0x4)
							criticalMultiplier = criticalMultiplier + theparameter1
						elseif theopcode == 288 and theparameter2 == 213 and bit.band(thesavingthrow, 0x10000) > 0 then
							IEex_WriteWord(effectData + 0x1E, IEex_ReadWord(offset + 0x4, 0x0))
							parameter2 = IEex_ReadDword(effectData + 0x1C)
							damageType = bit.band(parameter2, 0xFFFF0000)
						elseif theopcode == 288 and theparameter2 == 225 and bit.band(thesavingthrow, 0x10000) > 0 and bit.band(thesavingthrow, 0x100000) == 0 and bit.band(thesavingthrow, 0x800000) > 0 then
							local spellRES = IEex_ReadLString(offset + 0x14, 8)
							if spellRES ~= "" and (bit.band(thesavingthrow, 0x4000000) == 0 or bit.band(IEex_ReadDword(effectData + 0xD4), 0x40) == 0) then
								local thecasterlvl = 10
								local newEffectTarget = targetID
								local newEffectTargetX = IEex_ReadDword(effectData + 0x84)
								local newEffectTargetY = IEex_ReadDword(effectData + 0x88)
								if (bit.band(thesavingthrow, 0x200000) > 0) then
									newEffectTarget = sourceID
									newEffectTargetX = IEex_ReadDword(effectData + 0x7C)
									newEffectTargetY = IEex_ReadDword(effectData + 0x80)
								end
								local newEffectSource = sourceID
								local newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
								local newEffectSourceY = IEex_ReadDword(effectData + 0x80)
								if (bit.band(thesavingthrow, 0x400000) > 0) then
									newEffectSource = targetID
									newEffectSourceX = IEex_ReadDword(effectData + 0x84)
									newEffectSourceY = IEex_ReadDword(effectData + 0x88)
								end
								table.insert(onCriticalHitEffectList, {spellRES, thecasterlvl, newEffectTarget, newEffectSource, newEffectTargetX, newEffectTargetY, newEffectSourceX, newEffectSourceY})
							end
						end
					end
				end
				local launcherWrapper = IEex_DemandRes(launcherRES, "ITM")
				if launcherWrapper:isValid() then
					local launcherData = launcherWrapper:getData()
					local effectOffset = IEex_ReadDword(launcherData + 0x6A)
					local numGlobalEffects = IEex_ReadWord(launcherData + 0x70, 0x0)
					for i = 0, numGlobalEffects - 1, 1 do
						local offset = launcherData + effectOffset + i * 0x30
						local theopcode = IEex_ReadWord(offset, 0x0)
						local theparameter2 = IEex_ReadDword(offset + 0x8)
						local thesavingthrow = IEex_ReadDword(offset + 0x24)
						if theopcode == 288 and theparameter2 == 195 and bit.band(thesavingthrow, 0x10000) > 0 then
							local theparameter1 = IEex_ReadDword(offset + 0x4)
							criticalMultiplier = criticalMultiplier + theparameter1
						elseif theopcode == 288 and theparameter2 == 213 and bit.band(thesavingthrow, 0x10000) > 0 then
							IEex_WriteWord(effectData + 0x1E, IEex_ReadWord(offset + 0x4, 0x0))
							parameter2 = IEex_ReadDword(effectData + 0x1C)
							damageType = bit.band(parameter2, 0xFFFF0000)
						elseif theopcode == 288 and theparameter2 == 225 and bit.band(thesavingthrow, 0x10000) > 0 and bit.band(thesavingthrow, 0x100000) == 0 and bit.band(thesavingthrow, 0x800000) > 0 then
							local spellRES = IEex_ReadLString(offset + 0x14, 8)
							if spellRES ~= "" and (bit.band(thesavingthrow, 0x4000000) == 0 or bit.band(IEex_ReadDword(effectData + 0xD4), 0x40) == 0) then
								local thecasterlvl = 10
								local newEffectTarget = targetID
								local newEffectTargetX = IEex_ReadDword(effectData + 0x84)
								local newEffectTargetY = IEex_ReadDword(effectData + 0x88)
								if (bit.band(thesavingthrow, 0x200000) > 0) then
									newEffectTarget = sourceID
									newEffectTargetX = IEex_ReadDword(effectData + 0x7C)
									newEffectTargetY = IEex_ReadDword(effectData + 0x80)
								end
								local newEffectSource = sourceID
								local newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
								local newEffectSourceY = IEex_ReadDword(effectData + 0x80)
								if (bit.band(thesavingthrow, 0x400000) > 0) then
									newEffectSource = targetID
									newEffectSourceX = IEex_ReadDword(effectData + 0x84)
									newEffectSourceY = IEex_ReadDword(effectData + 0x88)
								end
								table.insert(onCriticalHitEffectList, {spellRES, thecasterlvl, newEffectTarget, newEffectSource, newEffectTargetX, newEffectTargetY, newEffectSourceX, newEffectSourceY})
							end
						end
					end
				end
				IEex_IterateActorEffects(sourceID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if theopcode == 288 and theparameter2 == 195 and bit.band(thesavingthrow, 0x10000) == 0 and (thespecial == -1 or thespecial == itemType) then
						criticalMultiplier = criticalMultiplier + theparameter1
					elseif theopcode == 288 and theparameter2 == 213 and bit.band(thesavingthrow, 0x10000) == 0 then
						IEex_WriteWord(effectData + 0x1E, theparameter1)
						parameter2 = IEex_ReadDword(effectData + 0x1C)
						damageType = bit.band(parameter2, 0xFFFF0000)
					elseif theopcode == 288 and theparameter2 == 225 and bit.band(thesavingthrow, 0x10000) == 0 and bit.band(thesavingthrow, 0x100000) == 0 and bit.band(thesavingthrow, 0x800000) > 0 then
						local matchHeader = IEex_ReadWord(eData + 0x48, 0x0)
						local spellRES = IEex_ReadLString(eData + 0x30, 8)
						if (theparameter1 == 0 or exhitIndexList[theparameter1] ~= nil) and spellRES ~= "" and (matchHeader == 0 or matchHeader == headerType) and (bit.band(thesavingthrow, 0x4000000) == 0 or bit.band(IEex_ReadDword(effectData + 0xD4), 0x40) == 0) then
							local thecasterlvl = 10
							local newEffectTarget = targetID
							local newEffectTargetX = IEex_ReadDword(effectData + 0x84)
							local newEffectTargetY = IEex_ReadDword(effectData + 0x88)
							if (bit.band(thesavingthrow, 0x200000) > 0) then
								newEffectTarget = sourceID
								newEffectTargetX = IEex_ReadDword(effectData + 0x7C)
								newEffectTargetY = IEex_ReadDword(effectData + 0x80)
							end
							local newEffectSource = sourceID
							local newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
							local newEffectSourceY = IEex_ReadDword(effectData + 0x80)
							if (bit.band(thesavingthrow, 0x400000) > 0) then
								newEffectSource = targetID
								newEffectSourceX = IEex_ReadDword(effectData + 0x84)
								newEffectSourceY = IEex_ReadDword(effectData + 0x88)
							end
							local usesLeft = IEex_ReadWord(eData + 0x4A, 0x0)
							if usesLeft == 1 then
								local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
								table.insert(sourceExpired, theparent_resource)
							elseif usesLeft > 0 then
								usesLeft = usesLeft - 1
								IEex_WriteWord(eData + 0x4A, usesLeft)
							end
							table.insert(onCriticalHitEffectList, {spellRES, thecasterlvl, newEffectTarget, newEffectSource, newEffectTargetX, newEffectTargetY, newEffectSourceX, newEffectSourceY})
						end
					elseif theopcode == 500 and theresource == "MEWEPENC" then
						local theweaponRES = IEex_ReadLString(eData + 0x1C, 8)
						local theenchantment = IEex_ReadWord(eData + 0x48, 0x0)
						local theheaderType = IEex_ReadWord(eData + 0x4A, 0x0)
						if (theweaponRES == "" or theweaponRES == weaponRES or theweaponRES == launcherRES) and (theheaderType == 0 or theheaderType == headerType) and theenchantment > special then
							special = theenchantment
							IEex_WriteDword(effectData + 0x44, special)
						end
					end
				end)
				if bit.band(parameter3, 0x40000) == 0 then
					parameter3 = bit.bor(parameter3, 0x40000)
					IEex_WriteDword(effectData + 0x5C, parameter3)
					local damageMultiplier = 100
					IEex_IterateActorEffects(sourceID, function(eData)
						local theopcode = IEex_ReadDword(eData + 0x10)
						local theparameter1 = IEex_ReadDword(eData + 0x1C)
						local theparameter2 = IEex_ReadDword(eData + 0x20)
						if theopcode == 73 and theparameter2 > 0 then
							if ex_damage_multiplier_type[IEex_ReadDword(effectData + 0x1C)] == theparameter2 then
								damageMultiplier = damageMultiplier + theparameter1
								local theresource = IEex_ReadLString(eData + 0x30, 8)
								if theresource == parent_resource then
									local thespecial = IEex_ReadDword(eData + 0x48)
									damageMultiplier = damageMultiplier + thespecial
								end
							end
						end
					end)
					if damageMultiplier ~= 100 then
						parameter1 = math.floor(parameter1 * damageMultiplier / 100)
						IEex_WriteDword(effectData + 0x18, parameter1)
					end
				end
				weaponWrapper:free()
				launcherWrapper:free()
				
				if bit.band(parameter3, 0x10000) > 0 then
					if criticalMultiplier ~= baseCriticalMultiplier then
						parameter1 = math.floor(parameter1 * criticalMultiplier / baseCriticalMultiplier)
						IEex_WriteDword(effectData + 0x18, parameter1)
					end
					for k, v in ipairs(onCriticalHitEffectList) do
						IEex_ApplyEffectToActor(v[3], {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = v[1],
["source_x"] = v[7],
["source_y"] = v[8],
["target_x"] = v[5],
["target_y"] = v[6],
["casterlvl"] = v[2],
["parent_resource"] = v[1],
["source_target"] = v[3],
["source_id"] = v[4]
})
					end
				end
				
				

--			end

		end
		if opcode == 13 or opcode == 420 then
			local timeSlowed, targetNotSlowed = IEex_CheckGlobalEffectOnActor(targetID, 0x2)
			local noChunkedDeath, targetYesChunkedDeath = IEex_CheckGlobalEffectOnActor(targetID, 0x4)
			if (parameter2 == 0x8 or parameter2 == 0x400) and (IEex_GetActorSpellState(targetID, 210) or timeSlowed or noChunkedDeath) then
				parameter2 = 0x4
				IEex_WriteDword(effectData + 0x1C, parameter2)
			end
		end
		if opcode == 13 and parent_resource == "" then
			local oldItemSlotList = {}
			IEex_IterateActorEffects(targetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
				if theopcode == 288 and theparameter2 == 187 and theparent_resource == "MEOLDITM" then
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thevvcresource = IEex_ReadLString(eData + 0x70, 8)
					local theoldItemSlot = IEex_ReadWord(eData + 0x62, 0x0)
					local thecasterlvl = IEex_ReadDword(eData + 0xC8)
					local theinternalFlags = bit.bor(IEex_ReadDword(eData + 0xD0), IEex_ReadDword(eData + 0xD8))
					table.insert(oldItemSlotList, {theoldItemSlot, thevvcresource, thecasterlvl, thesavingthrow, theinternalFlags})
				end
			end)
			for k, v in ipairs(oldItemSlotList) do
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 9,
["parameter1"] = v[1],
["resource"] = "MEERASEW",
["savingthrow"] = v[4],
["parent_resource"] = v[2],
["casterlvl"] = v[3],
["internal_flags"] = v[5],
["source_target"] = targetID,
["source_id"] = targetID,
})
			end
			local onKillEffectList = {}
			if IEex_GetActorSpellState(sourceID, 222) then
				IEex_IterateActorEffects(sourceID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					if theopcode == 288 and theparameter2 == 222 and bit.band(thesavingthrow, 0x100000) == 0 then
						local theresource = IEex_ReadLString(eData + 0x30, 8)
						if theresource ~= "" then
							local thecasterlvl = IEex_ReadDword(eData + 0xC8)
							local newEffectTarget = sourceID
							local newEffectTargetX = IEex_ReadDword(effectData + 0x7C)
							local newEffectTargetY = IEex_ReadDword(effectData + 0x80)
							if (bit.band(thesavingthrow, 0x200000) > 0) then
								newEffectTarget = targetID
								newEffectTargetX = IEex_ReadDword(effectData + 0x84)
								newEffectTargetY = IEex_ReadDword(effectData + 0x88)
							end
							local newEffectSource = sourceID
							local newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
							local newEffectSourceY = IEex_ReadDword(effectData + 0x80)
							if (bit.band(thesavingthrow, 0x400000) > 0) then
								newEffectSource = targetID
								newEffectSourceX = IEex_ReadDword(effectData + 0x84)
								newEffectSourceY = IEex_ReadDword(effectData + 0x88)
							end
							table.insert(onKillEffectList, {theresource, thecasterlvl, newEffectTarget, newEffectSource, newEffectTargetX, newEffectTargetY, newEffectSourceX, newEffectSourceY})
						end
					end
				end)
			end
			if IEex_GetActorSpellState(targetID, 222) then
				IEex_IterateActorEffects(targetID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					if theopcode == 288 and theparameter2 == 222 and bit.band(thesavingthrow, 0x100000) > 0 then
						local theresource = IEex_ReadLString(eData + 0x30, 8)
						if theresource ~= "" then
							local thecasterlvl = IEex_ReadDword(eData + 0xC8)
							local newEffectTarget = targetID
							local newEffectTargetX = IEex_ReadDword(effectData + 0x84)
							local newEffectTargetY = IEex_ReadDword(effectData + 0x88)
							if (bit.band(thesavingthrow, 0x200000) > 0) then
								newEffectTarget = sourceID
								newEffectTargetX = IEex_ReadDword(effectData + 0x7C)
								newEffectTargetY = IEex_ReadDword(effectData + 0x80)
							elseif (bit.band(thesavingthrow, 0x8000000) > 0) then
								newEffectTarget = IEex_GetActorSummonerID(targetID)
							end
							local newEffectSource = sourceID
							local newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
							local newEffectSourceY = IEex_ReadDword(effectData + 0x80)
							if (bit.band(thesavingthrow, 0x400000) > 0) then
								newEffectSource = targetID
								newEffectSourceX = IEex_ReadDword(effectData + 0x84)
								newEffectSourceY = IEex_ReadDword(effectData + 0x88)
							end
							table.insert(onKillEffectList, {theresource, thecasterlvl, newEffectTarget, newEffectSource, newEffectTargetX, newEffectTargetY, newEffectSourceX, newEffectSourceY})
						end
					end
				end)
			end
			for k, v in ipairs(onKillEffectList) do
				IEex_ApplyEffectToActor(v[3], {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = v[1],
["source_x"] = v[7],
["source_y"] = v[8],
["target_x"] = v[5],
["target_y"] = v[6],
["casterlvl"] = v[2],
["parent_resource"] = v[1],
["source_target"] = v[3],
["source_id"] = v[4]
})
			end
			local minHP = 0
			IEex_IterateActorEffects(targetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				if theopcode == 208 and theparameter1 > minHP then
					minHP = theparameter1
				end
			end)
			if minHP > 0 then
				IEex_WriteWord(creatureData + 0x5C0, minHP)
				IEex_DS(minHP)
				return true
			end
		end
		if opcode == 12 then
--[[
			IEex_WriteByte(creatureData + 0xA60, 0)
			IEex_WriteByte(creatureData + 0x18B8, 0)
			IEex_WriteDword(creatureData + 0x920, bit.band(IEex_ReadDword(creatureData + 0x920), 0xBFFFFFFF))
			IEex_WriteDword(creatureData + 0x1778, bit.band(IEex_ReadDword(creatureData + 0x1778), 0xBFFFFFFF))
--]]
			local onDamageEffectList = {}
			IEex_IterateActorEffects(targetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				local thetypesChecked = IEex_ReadDword(eData + 0x48) * 0x10000
				if theopcode == 288 and theparameter2 == 226 and theparameter1 <= parameter1 and ((damageType == 0 and bit.band(thetypesChecked, 0x20000000) > 0) or bit.band(thetypesChecked, damageType) > 0) then
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					if theresource ~= "" then
						local thecasterlvl = IEex_ReadDword(eData + 0xC8)
						local newEffectTarget = targetID
						local newEffectTargetX = IEex_ReadDword(effectData + 0x84)
						local newEffectTargetY = IEex_ReadDword(effectData + 0x88)
						if (bit.band(thesavingthrow, 0x200000) > 0) then
							newEffectTarget = sourceID
							newEffectTargetX = IEex_ReadDword(effectData + 0x7C)
							newEffectTargetY = IEex_ReadDword(effectData + 0x80)
						elseif (bit.band(thesavingthrow, 0x8000000) > 0) then
							newEffectTarget = IEex_GetActorSummonerID(targetID)
						end
						local newEffectSource = sourceID
						local newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
						local newEffectSourceY = IEex_ReadDword(effectData + 0x80)
						if (bit.band(thesavingthrow, 0x400000) > 0) then
							newEffectSource = targetID
							newEffectSourceX = IEex_ReadDword(effectData + 0x84)
							newEffectSourceY = IEex_ReadDword(effectData + 0x88)
						end
						table.insert(onDamageEffectList, {theresource, thecasterlvl, newEffectTarget, newEffectSource, newEffectTargetX, newEffectTargetY, newEffectSourceX, newEffectSourceY})
					end
				end
			end)
			for k, v in ipairs(onDamageEffectList) do
				IEex_ApplyEffectToActor(v[3], {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = v[1],
["source_x"] = v[7],
["source_y"] = v[8],
["target_x"] = v[5],
["target_y"] = v[6],
["casterlvl"] = v[2],
["parent_resource"] = v[1],
["source_target"] = v[3],
["source_id"] = v[4]
})
			end
		end
		if opcode == 98 and restype == 1 and IEex_GetActorSpellState(sourceID, 191) then
			local healingMultiplier = 100
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 191 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if thespecial == 2 and (bit.band(thesavingthrow, 0x100000) == 0 or targetID ~= sourceID) then
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
		if bit.band(internalFlags, 0x20) == 0 and ex_apply_effects_flags[targetID .. sourceID .. parent_resource] ~= nil then
			internalFlags = ex_apply_effects_flags[targetID .. sourceID .. parent_resource]
			IEex_WriteDword(effectData + 0xD4, internalFlags)
		end
		if opcode == 402 then
			if bit.band(internalFlags, 0x20) > 0 and internalFlags >= 0x1000 then
				ex_apply_effects_flags[targetID .. sourceID .. parent_resource] = internalFlags
			else
				ex_apply_effects_flags[targetID .. sourceID .. parent_resource] = nil
			end
		end
		if opcode == 430 then
			IEex_Helper_SetBridge("IEex_RecordOpcode430Spell", sourceID, "spellRES", resource)
		end
		if bit.band(internalFlags, 0x10000) > 0 and (timing == 0 or timing == 3 or timing == 4) and duration >= 30 then
			duration = 2400
			IEex_WriteDword(effectData + 0x24, duration)
			if opcode == 256 then
				parameter1 = 2400
				IEex_WriteDword(effectData + 0x18, parameter1)
			elseif opcode == 264 or opcode == 265 or opcode == 449 then
				parameter1 = 400
				IEex_WriteDword(effectData + 0x18, parameter1)
			end
		end
		if bit.band(internalFlags, 0x20000) > 0 and (timing == 0 or timing == 3 or timing == 4) and duration >= 2 then
			duration = duration * 2
			IEex_WriteDword(effectData + 0x24, duration)
			if opcode == 256 or opcode == 264 or opcode == 265 or opcode == 449 then
				parameter1 = parameter1 * 2
				IEex_WriteDword(effectData + 0x18, parameter1)
			end
		end
		if bit.band(internalFlags, 0x100000) > 0 then
			if opcode == 288 then
				if parameter2 == 191 or parameter2 == 192 or parameter2 == 193 or parameter2 == 194 or parameter2 == 207 or parameter2 == 236 or parameter2 == 237 or parameter2 == 242 or parameter2 == 243 or parameter2 == 246 then
					parameter1 = math.floor(parameter1 * 1.5)
					IEex_WriteDword(effectData + 0x18, parameter1)
				end
--[[
			elseif opcode == 500 then
				if resource == "MEHGTST" and special == 1 then
					parameter1 = math.floor(parameter1 * 1.5)
					IEex_WriteDword(effectData + 0x18, parameter1)
				end
--]]
			elseif ex_empowerable_opcodes[opcode] ~= nil then
				if opcode == 12 or opcode == 17 or opcode == 18 or opcode == 255 then
					parameter1 = math.floor(parameter1 * 1.5)
					IEex_WriteDword(effectData + 0x18, parameter1)
					dicenumber = math.floor(dicenumber * 1.5)
					IEex_WriteDword(effectData + 0x34, dicenumber)
				elseif opcode == 436 then
					parameter2 = math.floor(parameter2 * 1.5)
					IEex_WriteDword(effectData + 0x1C, parameter2)
				else
					parameter1 = math.floor(parameter1 * 1.5)
					IEex_WriteDword(effectData + 0x18, parameter1)
				end
			end

		end
		if (opcode == 235 and timing == 4096) or (opcode == 187 and parameter1 > 10000) then
			local timeSlowed, targetNotSlowed = IEex_CheckGlobalEffectOnActor(targetID, 0x2)
			if timeSlowed and not targetNotSlowed then
				if (opcode == 235 and timing == 4096) then
					IEex_WriteDword(effectData + 0x24, (duration - time_applied) * ex_time_slow_speed_divisor + time_applied - 15)
				elseif (opcode == 187 and parameter1 > 10000) then
					local tick = IEex_GetGameTick()
					local timerDelay = parameter1 - tick
					if timerDelay <= 255 then
						parameter1 = timerDelay * ex_time_slow_speed_divisor + tick
						IEex_WriteDword(effectData + 0x18, parameter1)
					end
				end
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
