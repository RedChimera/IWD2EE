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
	local m_curItemSlotNum = IEex_ReadByte(sourceShare + 0x4BA4)

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
			itemType = IEex_ReadWord(weaponData + 0x1C)
			if ex_item_type_critical[itemType] ~= nil then
				baseCriticalMultiplier = ex_item_type_critical[itemType][2]
				criticalMultiplier = baseCriticalMultiplier
			end
			local effectOffset = IEex_ReadDword(weaponData + 0x6A)
			local numGlobalEffects = IEex_ReadWord(weaponData + 0x70)
			for i = 0, numGlobalEffects - 1, 1 do
				local offset = weaponData + effectOffset + i * 0x30
				local theopcode = IEex_ReadWord(offset)
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
				local numGlobalEffects = IEex_ReadWord(launcherData + 0x70)
				for i = 0, numGlobalEffects - 1, 1 do
					local offset = launcherData + effectOffset + i * 0x30
					local theopcode = IEex_ReadWord(offset)
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

	local effectResource = IEex_ReadLString(pEffect + 0x2C, 8)
	IEex_Helper_SynchronizedBridgeOperation("IEex_DerivedStatsData", function()
		local screenEffects = IEex_Helper_GetBridgeNL("IEex_DerivedStatsData", IEex_GetSpriteDerivedStats(pSprite), "screenEffects")
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
	if IEex_ReadDword(pEffect + 0x68) == 0 then
		IEex_WriteDword(pEffect + 0x68, IEex_GetGameTick())
	end
	if IEex_ReadDword(pEffect + 0xD0) == 0 then
		IEex_WriteDword(pEffect + 0xD0, math.random(0x7FFFFFFF))
	end
	for func_name, func in pairs(IEex_ScreenEffectsGlobalFunctions) do
		if func(pEffect, pSprite) then
			return true
		end
	end

	local screenList = IEex_Helper_GetBridge(IEex_AccessActorLuaStats(actorID), "screenEffects")
	local numEntries = IEex_Helper_GetBridgeNumInts(screenList)
	if pSprite > 0 and IEex_ReadDword(pSprite + 0x12) > 0 then
		for i = 1, numEntries, 1 do
			local immunityFunction = _G[IEex_Helper_GetBridge(screenList, i, "functionName")]
			if immunityFunction and immunityFunction(IEex_Helper_GetBridge(screenList, i, "pOriginatingEffect"), pEffect, pSprite) then
				return true
			end
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
	if IEex_ReadByte(summonerData + 0x4) == 0x31 then
		IEex_WriteDword(summonedData + 0x72C, IEex_ReadDword(summonerData + 0x700))
		if bit.band(savingthrow, 0x100000) > 0 then
			IEex_WriteDword(summonedData + 0x740, bit.bor(IEex_ReadDword(summonedData + 0x740), 0x100000))
		end
	end
	IEex_WriteByte(summonedData + 0x730, IEex_ReadByte(effectData + 0xC4))
	IEex_WriteByte(summonedData + 0x731, IEex_ReadByte(effectData + 0xC5))
	IEex_WriteByte(summonedData + 0x732, IEex_ReadByte(effectData + 0xC6))
	local internalFlags = bit.bor(IEex_ReadDword(effectData + 0xCC), IEex_ReadDword(effectData + 0xD4))
	IEex_WriteDword(summonedData + 0x734, internalFlags)
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
ex_dead_pc_equipment_record = {}
--[[
ex_empowerable_opcodes = {[0] = true, [1] = true, [6] = true, [10] = true, [12] = true, [15] = true, [17] = true, [18] = true,
[19] = true, [21] = true, [22] = true, [25] = true, [27] = true, [28] = true, [29] = true, [30] = true, [31] = true,
[33] = true, [34] = true, [35] = true, [36] = true, [37] = true, [44] = true, [49] = true, [54] = true, [59] = true,
[60] = true, [67] = true, [73] = true, [78] = true, [84] = true, [85] = true, [86] = true, [87] = true, [88] = true, [89] = true,
[90] = true, [91] = true, [92] = true, [93] = true, [94] = true, [95] = true, [97] = true, [98] = true, [111] = true,
[126] = true, [127] = true, [129] = true, [130] = true, [131] = true, [132] = true, [137] = true, [166] = true, [167] = true,
[173] = true, [176] = true, [189] = true, [190] = true, [191] = true, [218] = true,
[238] = true, [239] = true, [247] = true, [255] = true, [266] = true,
[281] = true, [297] = true, [298] = true, [410] = true, [411] = true, [416] = true, [431] = true, [432] = true, [436] = true,}
--]]
ex_empowerable_opcodes = {[12] = true, [17] = true, [18] = true, [25] = true, [67] = true, [410] = true, [411] = true, [416] = true,}
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
		local target = IEex_ReadDword(effectData + 0x10)
		local parameter1 = IEex_ReadDword(effectData + 0x18)
		local parameter2 = IEex_ReadDword(effectData + 0x1C)
		local parameter3 = IEex_ReadDword(effectData + 0x5C)
		local damageType = bit.band(parameter2, 0xFFFF0000)
		local timing = IEex_ReadDword(effectData + 0x20)
		local duration = IEex_ReadDword(effectData + 0x24)
		local resource = IEex_ReadLString(effectData + 0x2C, 8)
		local dicenumber = IEex_ReadDword(effectData + 0x34)
		local dicesize = IEex_ReadDword(effectData + 0x38)
		local savingthrow = IEex_ReadDword(effectData + 0x3C)
		local savebonus = IEex_ReadDword(effectData + 0x40)
		local special = IEex_ReadDword(effectData + 0x44)
		local resist_dispel = IEex_ReadDword(effectData + 0x58)
		local time_applied = IEex_ReadDword(effectData + 0x68)
--[[
		if opcode == 500 and resource == "MECOPYEQ" then
			local effectIndex = parameter1
			local slotToCopy = parameter2
			local slotToMatchType = special
			local invItemInfo = IEex_ReadDword(creatureData + 0x4AD8 + slotToCopy * 0x4)
			if invItemInfo > 0 then
				local itemRES = IEex_ReadLString(invItemInfo + 0xC, 8)
				local resWrapper = IEex_DemandRes(itemRES, "ITM")
				if resWrapper:isValid() then
					local itemData = resWrapper:getData()
					if itemData > 0 then
						local itemCategory = IEex_ReadWord(itemData + 0x1C)
						local itemMatchesType = false
						for k, v in ipairs(me_item_type_slots[itemCategory]) do
							if v == slotToMatchType then
								itemMatchesType = true
							end
						end
						if itemMatchesType or slotToMatchType == -1 then
							local effectOffset = IEex_ReadDword(itemData + 0x6A)
							local firstGlobalEffectIndex = IEex_ReadWord(itemData + 0x6E)
							local numGlobalEffects = IEex_ReadWord(itemData + 0x70)
							if numGlobalEffects > effectIndex then
								local offset = effectOffset + (firstGlobalEffectIndex + effectIndex) * 0x30
								opcode = IEex_ReadWord(itemData + offset)
								IEex_WriteDword(effectData + 0xC, opcode)
								parameter1 = IEex_ReadDword(itemData + offset + 0x4)
								IEex_WriteDword(effectData + 0x18, parameter1)
								parameter2 = IEex_ReadDword(itemData + offset + 0x8)
								IEex_WriteDword(effectData + 0x1C, parameter2)
								resource = IEex_ReadLString(itemData + offset + 0x14, 8)
								IEex_WriteLString(effectData + 0x2C, resource, 8)
								savingthrow = IEex_ReadDword(itemData + offset + 0x24)
								IEex_WriteDword(effectData + 0x3C, savingthrow)
								savebonus = IEex_ReadDword(itemData + offset + 0x28)
								IEex_WriteDword(effectData + 0x40, savebonus)
								special = IEex_ReadDword(itemData + offset + 0x2C)
								IEex_WriteDword(effectData + 0x44, special)
								IEex_DS(opcode)
							else
								return true
							end
						end
					end
				end
				resWrapper:free()
			end
		end
--]]
		if bit.band(internalFlags, 0x2000000) > 0 then return false end
		local school = IEex_ReadDword(effectData + 0x48)
		local restype = IEex_ReadDword(effectData + 0x8C)
		local casterClass = IEex_ReadByte(effectData + 0xC5)
		local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
		local sourceSpell = ex_source_spell[parent_resource]
		if sourceSpell == nil then
			sourceSpell = string.sub(parent_resource, 1, 7)
		end
		if resist_dispel == 1 then
			local spellResistancePenetration = IEex_ReadDword(effectData + 0xC8)
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if theopcode == 288 and theparameter2 == 199 then
					if (thespecial == 0 or thespecial == casterClass) and (theresource == "" or theresource == parent_resource or theresource == sourceSpell) then
						spellResistancePenetration = spellResistancePenetration + theparameter1
						IEex_WriteDword(effectData + 0xC8, spellResistancePenetration)
					end
				end
			end)
		end
		if ex_trueschool[parent_resource] ~= nil then
			school = ex_trueschool[parent_resource]
		elseif ex_trueschool[sourceSpell] ~= nil then
			school = ex_trueschool[sourceSpell]
		end
		if target == 1 and timing ~= 2 and ex_listspll[parent_resource] ~= nil then
			if ex_persistent_spell[sourceID] == 1 then
				internalFlags = bit.bor(internalFlags, 0x10000)
			end
			if ex_extend_spell[sourceID] == 1 then
				internalFlags = bit.bor(internalFlags, 0x20000)
			end
			if ex_widen_spell[sourceID] == 1 then
				internalFlags = bit.bor(internalFlags, 0x40000)
			end
			if ex_safe_spell[sourceID] == 1 then
				internalFlags = bit.bor(internalFlags, 0x80000)
			end
			if ex_empower_spell[sourceID] == 1 then
				internalFlags = bit.bor(internalFlags, 0x100000)
			end
			if ex_maximize_spell[sourceID] == 1 then
				internalFlags = bit.bor(internalFlags, 0x200000)
			end
			IEex_WriteDword(effectData + 0xCC, internalFlags)
		end
		if opcode == 12 and parent_resource == "IEEX_DAM" and IEex_IsSprite(sourceID, true) then
--			if (bit.band(savingthrow, 0x10000) > 0 and (IEex_GetActorSpellState(sourceID, 195) or IEex_GetActorSpellState(sourceID, 225))) or bit.band(savingthrow, 0x40000) == 0 then
				local weaponRES = IEex_ReadLString(effectData + 0x6C, 8)
				local launcherRES = IEex_ReadLString(effectData + 0x74, 8)
				local baseCriticalMultiplier = 2
				local criticalMultiplier = baseCriticalMultiplier
				local itemType = 0
				local headerType = 0
				local currentHeader = IEex_ReadByte(sourceData + 0x4BA6)
				local exhitIndexList = {}
				local onCriticalHitEffectList = {}
				local weaponWrapper = IEex_DemandRes(weaponRES, "ITM")
				if weaponWrapper:isValid() then
					local weaponData = weaponWrapper:getData()
					itemType = IEex_ReadWord(weaponData + 0x1C)
					if ex_item_type_critical[itemType] ~= nil then
						baseCriticalMultiplier = ex_item_type_critical[itemType][2]
						criticalMultiplier = baseCriticalMultiplier
					end
					if currentHeader >= IEex_ReadSignedWord(weaponData + 0x68) then
						currentHeader = 0
					end
					headerType = IEex_ReadByte(weaponData + 0x82 + currentHeader * 0x38)
					local effectOffset = IEex_ReadDword(weaponData + 0x6A)
					local numGlobalEffects = IEex_ReadWord(weaponData + 0x70)
					local numHeaderEffects = IEex_ReadWord(weaponData + 0x82 + currentHeader * 0x38 + 0x1E)
					local headerFirstEffectIndex = IEex_ReadWord(weaponData + 0x82 + currentHeader * 0x38 + 0x20)
					for i = 0, numHeaderEffects - 1, 1 do
						local offset = weaponData + effectOffset + (headerFirstEffectIndex + i) * 0x30
						local theopcode = IEex_ReadWord(offset)
						local theparameter2 = IEex_ReadDword(offset + 0x8)
						local theresource = IEex_ReadLString(offset + 0x14, 8)
						if theopcode == 500 and theresource == "MEEXHIT" then
							exhitIndexList[theparameter2] = true
						end
					end
					for i = 0, numGlobalEffects - 1, 1 do
						local offset = weaponData + effectOffset + i * 0x30
						local theopcode = IEex_ReadWord(offset)
						local theparameter2 = IEex_ReadDword(offset + 0x8)
						local thesavingthrow = IEex_ReadDword(offset + 0x24)
						if theopcode == 288 and theparameter2 == 195 and bit.band(thesavingthrow, 0x10000) > 0 then
							local theparameter1 = IEex_ReadDword(offset + 0x4)
							criticalMultiplier = criticalMultiplier + theparameter1
						elseif theopcode == 288 and theparameter2 == 213 and bit.band(thesavingthrow, 0x10000) > 0 then
							IEex_WriteWord(effectData + 0x1E, IEex_ReadWord(offset + 0x4))
							parameter2 = IEex_ReadDword(effectData + 0x1C)
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
					local numGlobalEffects = IEex_ReadWord(launcherData + 0x70)
					for i = 0, numGlobalEffects - 1, 1 do
						local offset = launcherData + effectOffset + i * 0x30
						local theopcode = IEex_ReadWord(offset)
						local theparameter2 = IEex_ReadDword(offset + 0x8)
						local thesavingthrow = IEex_ReadDword(offset + 0x24)
						if theopcode == 288 and theparameter2 == 195 and bit.band(thesavingthrow, 0x10000) > 0 then
							local theparameter1 = IEex_ReadDword(offset + 0x4)
							criticalMultiplier = criticalMultiplier + theparameter1
						elseif theopcode == 288 and theparameter2 == 213 and bit.band(thesavingthrow, 0x10000) > 0 then
							IEex_WriteWord(effectData + 0x1E, IEex_ReadWord(offset + 0x4))
							parameter2 = IEex_ReadDword(effectData + 0x1C)
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
					elseif theopcode == 288 and theparameter2 == 225 and bit.band(thesavingthrow, 0x10000) == 0 and bit.band(thesavingthrow, 0x100000) == 0 and bit.band(thesavingthrow, 0x800000) > 0 then
						local matchHeader = IEex_ReadWord(eData + 0x48)
						local spellRES = IEex_ReadLString(eData + 0x30, 8)
						local thesourceID = IEex_ReadDword(eData + 0x110)
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
							local newEffectSource = thesourceID
							local newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
							local newEffectSourceY = IEex_ReadDword(effectData + 0x80)
							if not IEex_IsSprite(thesourceID, false) then
								newEffectSource = sourceID
							end
							if (bit.band(thesavingthrow, 0x80000) > 0) then
								newEffectSource = sourceID
							elseif (bit.band(thesavingthrow, 0x400000) > 0) then
								newEffectSource = targetID
								newEffectSourceX = IEex_ReadDword(effectData + 0x84)
								newEffectSourceY = IEex_ReadDword(effectData + 0x88)
							end
							local usesLeft = IEex_ReadWord(eData + 0x4A)
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
						local thesavingthrow = IEex_ReadDword(eData + 0x40)
						local theenchantment = IEex_ReadWord(eData + 0x48)
						local theheaderType = IEex_ReadSignedByte(eData + 0x4A)
						if (theweaponRES == "" or theweaponRES == weaponRES or theweaponRES == launcherRES) and (bit.band(thesavingthrow, 0x20000000) == 0 or theheaderType == -1 or theheaderType == itemType) and (bit.band(thesavingthrow, 0x20000000) > 0 or theheaderType == 0 or theheaderType == headerType) and theenchantment > special and (bit.band(thesavingthrow, 0x10000000) == 0 or not exhitIndexList[2001]) then
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
								local thesavingthrow = IEex_ReadDword(eData + 0x40)
								local thespecial = IEex_ReadDword(eData + 0x48)
								damageMultiplier = damageMultiplier + theparameter1
								local theresource = IEex_ReadLString(eData + 0x30, 8)
								if (theresource == "" or theresource == parent_resource) and (bit.band(thesavingthrow, 0x20000) == 0 or bit.band(thesavingthrow, 0x78000000) == bit.band(parameter3, 0x78000000)) then
									if bit.band(thesavingthrow, 0x100000) == 0 then
										damageMultiplier = damageMultiplier + thespecial
									else
										parameter1 = parameter1 + thespecial
										IEex_WriteDword(effectData + 0x18, parameter1)
									end
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
		local constantID = IEex_ReadDword(creatureData + 0x700)
		if opcode == 13 or opcode == 420 then
			local timeSlowed, targetNotSlowed = IEex_CheckGlobalEffectOnActor(targetID, 0x2)
			local noChunkedDeath, targetYesChunkedDeath = IEex_CheckGlobalEffectOnActor(targetID, 0x4)
			if bit.band(parameter2, 0x6F8) > 0 and (IEex_GetActorSpellState(targetID, 210) or timeSlowed or noChunkedDeath) then
				parameter2 = 0x4
				IEex_WriteDword(effectData + 0x1C, parameter2)
			end
			if IEex_IsPartyMember(targetID) then
				ex_dead_pc_equipment_record[constantID] = {}
				for i = 0, 50, 1 do
					local slotData = IEex_ReadDword(creatureData + 0x4AD8 + i * 0x4)
					if slotData > 0 then
						local itemRES = IEex_ReadLString(slotData + 0xC, 8)
						local charges1 = IEex_ReadWord(slotData + 0x18)
						local charges2 = IEex_ReadWord(slotData + 0x1A)
						local charges3 = IEex_ReadWord(slotData + 0x1C)
						local slotFlags = IEex_ReadDword(slotData + 0x20)
						local resWrapper = IEex_DemandRes(itemRES, "ITM")
						local itemData = 0
						if resWrapper:isValid() then
							itemData = resWrapper:getData()
						end
						if itemData > 0 then
							local itemFlags = IEex_ReadDword(itemData + 0x18)
							if bit.band(itemFlags, 0x4) > 0 then
								table.insert(ex_dead_pc_equipment_record[constantID], {i, itemRES, charges1, charges2, charges3, slotFlags})
							end
						end
						resWrapper:free()
					end
				end
			end
		end
--[[
		if opcode == 287 and IEex_IsPartyMember(targetID) and not IEex_IsSprite(targetID, false) then
			IEex_IterateIDs(IEex_ReadDword(creatureData + 0x12), 0x11, function(containerID)
				local containerData = IEex_GetActorShare(containerID)
				containerX = IEex_ReadDword(containerData + 0x6)
				containerY = IEex_ReadDword(containerData + 0xA)
				currentDistance = IEex_GetDistance(actorX, actorY, containerX, containerY)
				if currentDistance < 20 and currentDistance < shortestDistance and IEex_ReadWord(containerData + 0x5CA) == 4 then
					shortestDistance = currentDistance
					closestContainer = containerData
				end
			end)
		end
--]]
		if opcode == 13 or opcode == 420 then
--			if parameter2 == 0x40 and timing == 4 then
--				IEex_WriteDword(effectData + 0x20, 9)
--			end
			local oldItemSlotList = {}
			IEex_IterateActorEffects(targetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
				if theopcode == 288 and theparameter2 == 187 and theparent_resource == "MEOLDITM" then
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thevvcresource = IEex_ReadLString(eData + 0x70, 8)
					local theoldItemSlot = IEex_ReadWord(eData + 0x62)
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
							local newEffectTargetX = IEex_ReadDword(sourceData + 0x6)
							local newEffectTargetY = IEex_ReadDword(sourceData + 0xA)
							if (bit.band(thesavingthrow, 0x200000) > 0) then
								newEffectTarget = targetID
								newEffectTargetX = IEex_ReadDword(creatureData + 0x6)
								newEffectTargetY = IEex_ReadDword(creatureData + 0xA)
							end
							local newEffectSource = sourceID
							local newEffectSourceX = IEex_ReadDword(sourceData + 0x6)
							local newEffectSourceY = IEex_ReadDword(sourceData + 0xA)
							if (bit.band(thesavingthrow, 0x400000) > 0) then
								newEffectSource = targetID
								newEffectSourceX = IEex_ReadDword(creatureData + 0x6)
								newEffectSourceY = IEex_ReadDword(creatureData + 0xA)
							end
							if (bit.band(thesavingthrow, 0x800000) > 0) then
								newEffectSource = IEex_ReadDword(eData + 0x110)
								newEffectSourceX = IEex_ReadDword(eData + 0x88)
								newEffectSourceY = IEex_ReadDword(eData + 0x8C)
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
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter1 > minHP and theparameter2 == 205 then
					minHP = theparameter1
				end
			end)
			if minHP > 0 then
				IEex_WriteWord(creatureData + 0x5C0, minHP)
				return true
			end
			if ex_current_ghostwalk_target_offset["" .. targetID] then
				local ghostwalkTargetID = ex_current_ghostwalk_target_offset["" .. targetID][1]
				local ghostwalkOffsetX = ex_current_ghostwalk_target_offset["" .. targetID][2]
				local ghostwalkOffsetY = ex_current_ghostwalk_target_offset["" .. targetID][3]
				local offsetString = ghostwalkOffsetX .. "." .. ghostwalkOffsetY
				if ex_ghostwalk_offsets_taken["" .. ghostwalkTargetID] then
					ex_ghostwalk_offsets_taken["" .. ghostwalkTargetID][offsetString] = nil
				end
				ex_current_ghostwalk_target_offset["" .. targetID] = nil
			end
		end
		if opcode == 12 then
			local altDamageList = ex_alternative_damage_type[damageType]
			local altDamageBits = math.floor(bit.band(parameter3, 0x78000000) / 0x8000000)
			local resistance = IEex_ReadSignedWord(creatureData + ex_damage_resistance_stat_offset[damageType])
			if altDamageList then
				local altDamage = altDamageList[altDamageBits]
				if altDamage then
					if (altDamage[2] == 0x1 or altDamage[2] == 0x2) and ex_damage_resistance_stat_offset[damageType] then
						if resistance > 0 or altDamage[2] == 0x1 then
							resistance = 0
						end
					end
				end
			end

			local onDamageEffectList = {}
			local resistanceOpcode = ex_damage_resistance_opcode[damageType]
			if not resistanceOpcode then
				resistanceOpcode = -1
			end
			IEex_IterateActorEffects(targetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				local thetypesChecked = IEex_ReadDword(eData + 0x48)
				if theopcode == 288 and theparameter2 == 226 and theparameter1 <= parameter1 and ((damageType == 0 and bit.band(thetypesChecked, 0x2000) > 0) or bit.band(thetypesChecked * 0x10000, damageType) > 0) and (bit.band(thetypesChecked, 0x4000000) == 0 or bit.band(thetypesChecked, 0x78000000) == bit.band(parameter3, 0x78000000)) then
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
				elseif theopcode == resistanceOpcode and bit.band(thesavingthrow, 0x78000000) == bit.band(parameter3, 0x78000000) and theparameter1 == 0 and theparameter2 == 0 then
					local thespecial = IEex_ReadDword(eData + 0x48)
					resistance = resistance + thespecial
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
			if altDamageList then
				local altDamage = altDamageList[altDamageBits]
				if altDamage[3] ~= "" then
					IEex_ApplyEffectToActor(targetID, {
["opcode"] = 174,
["target"] = 2,
["timing"] = 1,
["resource"] = altDamage[3],
["source_x"] = v[7],
["source_y"] = v[8],
["target_x"] = IEex_ReadDword(creatureData + 0x6),
["target_y"] = IEex_ReadDword(creatureData + 0xA),
["parent_resource"] = "USDAMSND",
["source_target"] = targetID,
["source_id"] = sourceID
})
				end
				if altDamage[1] > 0 then
					IEex_SetToken(ex_alternative_damage_token[damageType], IEex_FetchString(altDamage[1]))
				end
			end
			IEex_WriteWord(creatureData + ex_damage_resistance_stat_offset[damageType], resistance)
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
		if bit.band(internalFlags, 0x20000) > 0 and (timing == 0 or timing == 3 or timing == 4) and duration >= 30 then
			duration = duration * 2
			IEex_WriteDword(effectData + 0x24, duration)
			if opcode == 256 or opcode == 264 or opcode == 265 or opcode == 449 then
				parameter1 = parameter1 * 2
				IEex_WriteDword(effectData + 0x18, parameter1)
			end
		end
		if bit.band(internalFlags, 0x100000) > 0 then
			if opcode == 288 then
--[[
				if parameter2 == 191 or parameter2 == 192 or parameter2 == 193 or parameter2 == 194 or parameter2 == 207 or parameter2 == 236 or parameter2 == 237 or parameter2 == 242 or parameter2 == 243 or parameter2 == 246 then
					parameter1 = math.floor(parameter1 * 1.5)
					IEex_WriteDword(effectData + 0x18, parameter1)
				end
--]]
			elseif opcode == 500 then
--[[
				if resource == "MEHGTST" and special == 1 then
					parameter1 = math.floor(parameter1 * 1.5)
					IEex_WriteDword(effectData + 0x18, parameter1)
				elseif resource == "MEMODSKL" or resource == "MEMODSTA" then
					parameter1 = math.floor(parameter1 * 1.5)
					IEex_WriteDword(effectData + 0x18, parameter1)
				end
--]]
			elseif ex_empowerable_opcodes[opcode] ~= nil then
				if opcode == 12 then
				
				elseif opcode == 17 or opcode == 18 or opcode == 255 then
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

		if (timing == 0 or timing == 3 or timing == 4) and (ex_listspll[sourceSpell] ~= nil or ex_listdomn[sourceSpell] ~= nil or casterClass > 0) and (opcode ~= 500 or math.abs(duration - time_applied) > 16) then
			local durationMultiplier = 100
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 198 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if (thespecial == 0 or thespecial == school) and (theresource == "" or theresource == parent_resource or theresource == sourceSpell) and ((casterClass == 2 and bit.band(thesavingthrow, 0x10000) > 0) or (casterClass == 3 and bit.band(thesavingthrow, 0x20000) > 0) or (casterClass == 4 and bit.band(thesavingthrow, 0x40000) > 0) or (casterClass == 7 and bit.band(thesavingthrow, 0x80000) > 0) or (casterClass == 8 and bit.band(thesavingthrow, 0x100000) > 0) or (casterClass == 10 and bit.band(thesavingthrow, 0x200000) > 0) or (casterClass == 11 and bit.band(thesavingthrow, 0x400000) > 0)) then
						durationMultiplier = durationMultiplier + theparameter1 - 100
					end
				end
			end)
			if casterClass == 11 and school > 0 and (2 ^ (school + 5)) == bit.band(IEex_GetActorStat(sourceID, 89), 0x7FC0) then
				durationMultiplier = durationMultiplier + ex_specialist_duration_multiplier - 100
			end
			if durationMultiplier ~= 100 then
				duration = math.ceil(duration * durationMultiplier / 100)
				IEex_WriteDword(effectData + 0x24, duration)
			end
		end

	end)

	IEex_ScreenEffectsStats_Init = function(stats)
		IEex_Helper_GetBridgeCreateNL(stats, "screenEffects")
	end


	IEex_ScreenEffectsStats_Reload = function(stats)
		IEex_Helper_ClearBridgeNL(stats, "screenEffects")
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
