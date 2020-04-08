
function IEex_Reload()
	dofile("override/IEex_IWD2.lua")
end

dofile("override/IEex_TRA.lua")
dofile("override/IEex_WEIDU.lua")

------------------------
-- Actor Manipulation --
------------------------

-- Directly applies an effect to an actor based on the args table.
function IEex_ApplyEffectToActor(actorID, args)

	local writeType = {
		["BYTE"]   = 0,
		["WORD"]   = 1,
		["DWORD"]  = 2,
		["RESREF"] = 3,
	}

	local writeTypeFunc = {
		[writeType.BYTE]   = IEex_WriteByte,
		[writeType.WORD]   = IEex_WriteWord,
		[writeType.DWORD]  = IEex_WriteDword,
		[writeType.RESREF] = function(address, arg) IEex_WriteLString(address, arg, 0x8) end,
	}

	local argFailType = {
		["ERROR"]   = 0,
		["DEFAULT"] = 1,
	}

	local writeArgs = function(address, writeDefs)
		for _, writeDef in ipairs(writeDefs) do
			local argKey = writeDef[1]
			local arg = args[argKey]
			if not arg then
				if writeDef[4] == argFailType.DEFAULT then
					arg = writeDef[5]
				else
					IEex_Error(argKey.." must be defined!")
				end
			end
			writeTypeFunc[writeDef[3]](address + writeDef[2], arg)
		end
	end

	local Item_effect_st = IEex_Malloc(0x30)
	writeArgs(Item_effect_st, {
		{ "opcode",        0x0,  writeType.WORD,   argFailType.ERROR        },
		{ "target",        0x2,  writeType.BYTE,   argFailType.DEFAULT, 1   },
		{ "power",         0x3,  writeType.BYTE,   argFailType.DEFAULT, 0   },
		{ "parameter1",    0x4,  writeType.DWORD,  argFailType.DEFAULT, 0   },
		{ "parameter2",    0x8,  writeType.DWORD,  argFailType.DEFAULT, 0   },
		{ "timing",        0xC,  writeType.BYTE,   argFailType.DEFAULT, 0   },
		{ "resist_dispel", 0xD,  writeType.BYTE,   argFailType.DEFAULT, 0   },
		{ "duration",      0xE,  writeType.DWORD,  argFailType.DEFAULT, 0   },
		{ "probability1",  0x12, writeType.BYTE,   argFailType.DEFAULT, 100 },
		{ "probability2",  0x13, writeType.BYTE,   argFailType.DEFAULT, 0   },
		{ "resource",      0x14, writeType.RESREF, argFailType.DEFAULT, ""  },
		{ "dicenumber",    0x1C, writeType.DWORD,  argFailType.DEFAULT, 0   },
		{ "dicesize",      0x20, writeType.DWORD,  argFailType.DEFAULT, 0   },
		{ "savingthrow",   0x24, writeType.DWORD,  argFailType.DEFAULT, 0   },
		{ "savebonus",     0x28, writeType.DWORD,  argFailType.DEFAULT, 0   },
		{ "special",       0x2C, writeType.DWORD,  argFailType.DEFAULT, 0   },
	})

	local source = IEex_Malloc(0x8)
	IEex_WriteDword(source + 0x0, args["source_x"] or -1)
	IEex_WriteDword(source + 0x4, args["source_y"] or -1)

	local target = IEex_Malloc(0x8)
	IEex_WriteDword(target + 0x0, args["target_x"] or -1)
	IEex_WriteDword(target + 0x4, args["target_y"] or -1)

	-- CGameEffect::DecodeEffect(Item_effect_st *effect, CPoint *source, int sourceID, CPoint *target)
	local CGameEffect = IEex_Call(0x48C800, {
		target,
		args["source_id"] or -1,
		source,
		Item_effect_st,
	}, nil, 0x10)

	IEex_Free(Item_effect_st)
	IEex_Free(source)
	IEex_Free(target)
	
	writeArgs(CGameEffect, {
		{ "sectype",           0x4C, writeType.DWORD,  argFailType.DEFAULT, 0  },
		{ "parameter3",        0x5C, writeType.DWORD,  argFailType.DEFAULT, 0  },
		{ "parameter4",        0x60, writeType.DWORD,  argFailType.DEFAULT, 0  },
		{ "parameter5",        0x64, writeType.DWORD,  argFailType.DEFAULT, 0  },
		{ "vvcresource",       0x6C, writeType.RESREF, argFailType.DEFAULT, "" },
		{ "resource2",         0x74, writeType.RESREF, argFailType.DEFAULT, "" },
		{ "restype",           0x8C, writeType.DWORD,  argFailType.DEFAULT, 0  },
		{ "parent_resource",   0x90, writeType.RESREF, argFailType.DEFAULT, "" },
		{ "resource_flags",    0x98, writeType.DWORD,  argFailType.DEFAULT, 0  },
		{ "impact_projectile", 0x9C, writeType.DWORD,  argFailType.DEFAULT, 0  },
		{ "sourceslot",        0xA0, writeType.DWORD,  argFailType.DEFAULT, -1 },
		{ "effvar",            0xA4, writeType.RESREF, argFailType.DEFAULT, "" },
		{ "casterlvl",         0xC4, writeType.DWORD,  argFailType.DEFAULT, 1  },
		{ "internal_flags",    0xC8, writeType.DWORD,  argFailType.DEFAULT, 0  },
	})

	local share = IEex_GetActorShare(actorID)
	-- CGameSprite::AddEffect(CGameSprite *this, CGameEffect *pEffect, char list, int noSave, int immediateResolve)
	IEex_Call(IEex_ReadDword(IEex_ReadDword(share) + 0x78), {1, 0, 1, CGameEffect}, share, 0x0)
end

function IEex_ApplyResref(resref, actorID)

	local share = IEex_GetActorShare(actorID)
	if actorID == 0 or actorID == -1 or share == 0 then
		print("IEex_ApplyResref(\"" .. resref .. "\", " .. actorID .. ") passed invalid actorID")
		return
	end

	local resrefMem = IEex_Malloc(#resref + 1)
	IEex_WriteString(resrefMem, resref)

	IEex_Call(IEex_Label("IEex_ApplyResref"), {resrefMem, share}, nil, 0x0)
	IEex_Free(resrefMem)

end

function IEex_SetActorName(actorID, strref)
	local share = IEex_GetActorShare(actorID)
	IEex_WriteDword(share + 0x5A4, strref)
end

function IEex_SetActorTooltip(actorID, strref)
	local share = IEex_GetActorShare(actorID)
	IEex_WriteDword(share + 0x5A8, strref)
end



-------------------
-- Actor Details --
-------------------

function IEex_GetActorName(actorID)
	local share = IEex_GetActorShare(actorID)
	local nameStrref = IEex_ReadDword(share + 0x5A4)
	return IEex_FetchString(nameStrref)
end

function IEex_GetActorTooltip(actorID)
	local share = IEex_GetActorShare(actorID)
	local nameStrref = IEex_ReadDword(share + 0x5A8)
	return IEex_FetchString(nameStrref)
end

function IEex_GetActorArmorClass(actorID)
	if actorID <= 0 then return {0, 0, 0, 0, 0} end
	local creatureData = IEex_GetActorShare(actorID)
	local armorClass = IEex_ReadSignedWord(creatureData + 0x5E2, 0x0)
	if bit32.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0 then
		armorClass = armorClass + 1
	end
	local slashingAC = IEex_GetActorStat(actorID, 6)
	local piercingAC = IEex_GetActorStat(actorID, 5)
	local bludgeoningAC = IEex_GetActorStat(actorID, 3)
	local missileAC = IEex_GetActorStat(actorID, 4)
	local dexterityBonus = math.floor((IEex_GetActorStat(actorID, 40) - 10) / 2)
	local wisdomBonus = math.floor((IEex_GetActorStat(actorID, 39) - 10) / 2)
	local armorBonus = 0
	local deflectionBonus = 0
	local shieldBonus = 0
	local barkskinBonus = 0
	local armorType = 0
	local hasShield = false
	IEex_IterateActorEffects(actorID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter1 = IEex_ReadDword(eData + 0x1C)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		local thespecial = IEex_ReadDword(eData + 0x48)
		if theopcode == 288 and theparameter2 == 241 then
			if theparameter1 >= 60 and theparameter1 <= 68 then
				armorType = theparameter1
			elseif thespecial == 3 then
				hasShield = true
			end
		elseif theopcode == 0 then
			if theparameter2 == 0 then
				armorClass = armorClass + theparameter1
			elseif theparameter2 == 1 and theparameter1 > armorBonus then
				armorBonus = theparameter1
			elseif theparameter2 == 2 and theparameter1 > deflectionBonus then
				deflectionBonus = theparameter1
			elseif theparameter2 == 1 and theparameter1 > shieldBonus then
				shieldBonus = theparameter1
			end
		elseif theopcode == 415 then
			local thecasterlvl = IEex_ReadByte(eData + 0xC8, 0x0)
			if thecasterlvl < 6 and barkskinBonus < 3 then
				barkskinBonus = 3
			elseif thecasterlvl >= 6 and thecasterlvl < 12 and barkskinBonus < 4 then
				barkskinBonus = 4
			elseif thecasterlvl >= 12 and barkskinBonus < 5 then
				barkskinBonus = 5
			end
		end
	end)
	local maxDexBonus = 99
	if ex_armor_penalties[armorType] ~= nil then
		maxDexBonus = ex_armor_penalties[armorType][2]
		if maxDexBonus < dexterityBonus then
			dexterityBonus = maxDexBonus
		end
	end
	if IEex_GetActorSpellState(actorID, 1) and deflectionBonus < 2 then
		deflectionBonus = 2
	end
	if IEex_GetActorSpellState(actorID, 55) and deflectionBonus < 5 then
		deflectionBonus = 5
	end
	if IEex_GetActorSpellState(actorID, 30) and deflectionBonus < 6 then
		deflectionBonus = 6
	end
	local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
	if bit32.band(stateValue, 0x8000) > 0 then
		armorClass = armorClass + 4
	end
	if bit32.band(stateValue, 0x10000) > 0 then
		armorClass = armorClass - 2
	end
	if bit32.band(stateValue, 0x40000) > 0 then
		armorClass = armorClass - 2
	else
		armorClass = armorClass + dexterityBonus
	end
	
	armorClass = armorClass + armorBonus
	armorClass = armorClass + deflectionBonus
	armorClass = armorClass + shieldBonus
	armorClass = armorClass + barkskinBonus
	if IEex_GetActorStat(actorID, 101) > 0 and armorType == 0 and hasShield == false then
		armorClass = armorClass + wisdomBonus
	end
	for i = 1, 5, 1 do
		if IEex_GetActorSpellState(actorID, 80 + i) then
			armorClass = armorClass + i
		end
	end
	if IEex_GetActorSpellState(actorID, 70) then
		armorClass = armorClass + 4
	end
	return {armorClass, slashingAC, piercingAC, bludgeoningAC, missileAC}
end

function IEex_GetActorStat(actorID, statID)
	local ecx = IEex_Call(0x4531A0, {}, IEex_GetActorShare(actorID), 0x0)
	return IEex_Call(0x446DD0, {statID}, ecx, 0x0)
end

function IEex_GetActorSpellState(actorID, spellStateID)
	local bitsetStruct = IEex_Malloc(0x8)
	local spellStateStart = IEex_Call(0x4531A0, {}, IEex_GetActorShare(actorID), 0x0) + 0xEC
	IEex_Call(0x45E380, {spellStateID, bitsetStruct}, spellStateStart, 0x0)
	local spellState = bit32.extract(IEex_Call(0x45E390, {}, bitsetStruct, 0x0), 0, 0x8)
	IEex_Free(bitsetStruct)
	return spellState == 1
end

function IEex_GetActorLocation(actorID)
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadDword(share + 0x6), IEex_ReadDword(share + 0xA)
end

function IEex_GetActorDestination(actorID)
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadDword(share + 0x556E), IEex_ReadDword(share + 0x5572)
end

-- Returns the creature the actor is targeting with their current action.
function IEex_GetActorTarget(actorID)
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadDword(share + 0x4BE)
end

-- Returns the coordinates of the point the actor is targeting with their
--  current action. 
function IEex_GetActorTargetPoint(actorID)
	local share = IEex_GetActorShare(actorID)
	local targetX = IEex_ReadDword(share + 0x540)
	local targetY = IEex_ReadDword(share + 0x544)
	if targetX < -1 or targetY < -1 then
		local targetID = IEex_GetActorTarget(actorID)
		if targetID > 0 then
			targetX, targetY = IEex_GetActorLocation(targetID)
		else
			targetX = -1
			targetY = -1
		end
	end
	return targetX, targetY
end

-- Returns the actor's current action (from ACTION.IDS).
function IEex_GetActorCurrentAction(actorID)
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadDword(share + 0x4BE)
end

-- Returns the actor's direction (from DIR.IDS).
function IEex_GetActorDirection(actorID)
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadByte(share + 0x537E, 0x0)
end

-- Sanity function to help work with number ranges that are cyclic, (like actor direction).
-- Example:
-- 	IEex_CyclicBound(num, 0, 15)
-- defines a range of 0 to 15. num = 16 rolls over to 0, as does num = 32. num = -1 wraps around to 15, as does num = -17.
function IEex_CyclicBound(num, lowerBound, upperBound)
	local tolerance = upperBound - lowerBound + 1
	local cycleCount = math.floor((num - lowerBound) / tolerance)
	return num - tolerance * cycleCount
end

-- Returns true if num2 is within <range> positions of num in the cyclic bounds. See IEex_CyclicBound() for more info about cyclic ranges.
function IEex_WithinCyclicRange(num, num2, range, lowerBound, higherBound)
	if num2 < (lowerBound + range) then
		-- Underflows
		return num > IEex_CyclicBound(num2 + higherBound - range + 1, lowerBound, higherBound) or num < (num2 + range)
	elseif num2 <= (higherBound - range + 1) then
		-- Normal
		return num > (num2 - range) and num < (num2 + range)
	else
		-- Overflows
		return num > (num2 - range) or num < IEex_CyclicBound(num2 + range, lowerBound, higherBound)
	end
end

function IEex_DirectionWithinCyclicRange(attackerID, targetID, range)
	local attackerDirection = IEex_GetActorDirection(attackerID)
	local targetDirection = IEex_GetActorDirection(targetID)
	return IEex_WithinCyclicRange(attackerDirection, targetDirection, range, 0, 15)
end

-- Returns true if the attackerID actor's direction is sufficent to backstab the targetID actor.
function IEex_IsValidBackstabDirection(attackerID, targetID)
	local attackerDirection = IEex_GetActorDirection(attackerID)
	local targetDirection = IEex_GetActorDirection(targetID)
	return IEex_WithinCyclicRange(attackerDirection, targetDirection, 3, 0, 15)
end

function IEex_IterateActorEffects(actorID, func)
	local esi = IEex_ReadDword(IEex_GetActorShare(actorID) + 0x552A)
	while esi ~= 0x0 do
		local edi = IEex_ReadDword(esi + 0x8) - 0x4
		if edi > 0x0 then
			func(edi)
		end
		esi = IEex_ReadDword(esi)
	end
	esi = IEex_ReadDword(IEex_GetActorShare(actorID) + 0x54FE)
	while esi ~= 0x0 do
		local edi = IEex_ReadDword(esi + 0x8) - 0x4
		if edi > 0x0 then
			func(edi)
		end
		esi = IEex_ReadDword(esi)
	end
end

ex_kit_unusability_locations = {
[0x40] = {0x2F, 0x40},
[0x80] = {0x2F, 0x80},
[0x100] = {0x2D, 0x1},
[0x200] = {0x2D, 0x2},
[0x400] = {0x2D, 0x4},
[0x800] = {0x2D, 0x8},
[0x1000] = {0x2D, 0x10},
[0x2000] = {0x2D, 0x20},
}

function IEex_CanLearnScroll(actorID, itemData)
	if (bit32.band(IEex_ReadDword(itemData + 0x1E), 0x400) > 0) or IEex_GetActorStat(actorID, 106) == 0 or IEex_ReadWord(itemdata + 0x1C, 0x0) ~= 11 or IEex_ReadWord(itemdata + 0x68, 0x0) < 2 then
		return false
	end
	local kitUnusability = ex_kit_unusability_locations[IEex_GetActorStat(actorID, 89)]
	if kitUnusability == nil then
		return true
	elseif bit32.band(IEex_ReadByte(itemData + kitUnusability[1], 0x0), kitUnusability[2]) > 0 then
		return false
	end
	return true
end

function IEex_GetDistance(x1, y1, x2, y2)
	return math.floor((((x1 - x2) ^ 2) + ((y1 - y2) ^ 2)) ^ .5) 
end

ex_classid_listspll = {[2] = 1, [3] = 2, [4] = 3, [7] = 4, [8] = 5, [10] = 6, [11] = 7}
ex_kitid_listdomn = {[0x8000] = 1, [0x10000] = 2, [0x20000] = 3, [0x40000] = 4, [0x80000] = 5, [0x100000] = 6, [0x200000] = 7, [0x400000] = 8, [0x800000] = 9}
function IEex_GetClassSpellLevel(actorID, casterClass, spellRES)
	local classSpellLevel = 0
	if ex_classid_listspll[casterClass] ~= nil and ex_listspll[spellRES] ~= nil then
		classSpellLevel = ex_listspll[spellRES][ex_classid_listspll[casterClass]]
	end
	if classSpellLevel == 0 and casterClass == 3 then
		local casterKit = IEex_GetActorStat(actorID, 89)
		if ex_kitid_listdomn[casterKit] ~= nil and ex_listdomn[spellRES] ~= nil then
			classSpellLevel = ex_listdomn[spellRES][ex_kitid_listdomn[casterKit]]
		end
	end
	return classSpellLevel
end

function IEex_CompareActorAllegiances(actorID1, actorID2)
	local creatureData1 = IEex_GetActorShare(actorID1)
	local creatureData2 = IEex_GetActorShare(actorID2)
	local ea1 = IEex_ReadByte(creatureData1 + 0x24, 0x0)
	local ea2 = IEex_ReadByte(creatureData2 + 0x24, 0x0)
	if ((ea1 >= 2 and ea1 <= 30) and (ea2 >= 200)) or ((ea1 >= 200) and (ea2 >= 2 and ea2 <= 30)) then
		return -1
	elseif ((ea1 >= 2 and ea1 <= 30) and (ea2 >= 2 and ea2 <= 30)) or ((ea1 >= 200) and (ea2 >= 200)) then
		return 1
	else
		return 0
	end
end

function IEex_IsSprite(actorID, allowDead)
	if actorID > 0 then
		local share = IEex_GetActorShare(actorID)
		if IEex_ReadByte(share + 0x4, 0) == 0x31 then
			return allowDead or bit32.band(IEex_ReadDword(share + 0x434), 0xFC0) == 0x0
		end
	end
	return false
end

----------------
-- Game State --
----------------

function IEex_GetGameData()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local m_pObjectGame = IEex_ReadDword(g_pBaldurChitin + 0x1C54)
	return m_pObjectGame
end

function IEex_DisplayString(string)

	string = tostring(string)
	local stringMem = IEex_Malloc(#string + 1)
	IEex_WriteString(stringMem, string)

	local CString = IEex_Malloc(0x4)
	IEex_Call(0x7FCC88, {stringMem}, CString, 0x0)
	IEex_Free(stringMem)

	IEex_Call(0x4EC1C0, {IEex_ReadDword(CString)}, nil, 0x0)
	IEex_Free(CString)

end

function IEex_TF(bool)
	if bool == true then
		IEex_DisplayString("True")
	elseif bool == false then
		IEex_DisplayString("False")
	else
		IEex_DisplayString("Huh?")
	end
end

function IEex_FetchString(strref)

	local resultPtr = IEex_Malloc(0x4)
	IEex_Call(0x427B60, {strref, resultPtr}, nil, 0x8)

	local toReturn = IEex_ReadString(IEex_ReadDword(resultPtr))
	IEex_Call(0x7FCC1A, {}, resultPtr, 0x0)
	IEex_Free(resultPtr)

	return toReturn

end

function IEex_2DALoad(resref)

	local C2DArray = IEex_Malloc(0x24)
	IEex_WriteDword(C2DArray + 0x0, 0x0) -- lock?
	IEex_WriteDword(C2DArray + 0x4, 0x0) -- res
	IEex_WriteLString(C2DArray + 0x8, "", 0x8) -- resref
	IEex_WriteDword(C2DArray + 0x10, 0x0) -- m_pNamesX
	IEex_WriteDword(C2DArray + 0x14, 0x0) -- m_pNamesY
	IEex_WriteDword(C2DArray + 0x18, 0x0) -- m_pArray
	IEex_WriteDword(C2DArray + 0x1C, IEex_ReadDword(0x8C1758)) -- defaultCString (afxPchNil)
	IEex_WriteWord(C2DArray + 0x20, 0x0) -- m_nSizeX
	IEex_WriteWord(C2DArray + 0x22, 0x0) -- m_nSizeY

	local resrefMem = IEex_Malloc(0x8)
	IEex_WriteLString(resrefMem, resref, 0x8)
	IEex_Call(0x402B70, {resrefMem}, C2DArray, 0x0)
	IEex_Free(resrefMem)

	return C2DArray

end

function IEex_2DADemand(arrayName)
	local C2DArray = IEex_Loaded2DAs[arrayName]
	if not C2DArray then
		C2DArray = IEex_2DALoad(arrayName)
		if IEex_ReadDword(C2DArray + 0x18) == 0x0 then
			IEex_Free(C2DArray)
			IEex_TracebackMessage("IEex CRITICAL ERROR - Couldn't find "..arrayName..".2DA!\n"..debug.traceback())
			return nil
		end
		IEex_Loaded2DAs[arrayName] = C2DArray
	end
	return C2DArray
end

function IEex_2DAFindColumn(C2DArray, columnString)
	local m_nSizeX = IEex_ReadWord(C2DArray + 0x20, 0)
	local columnIndex = nil
	local columnAccess = IEex_ReadDword(C2DArray + 0x10)
	for i = 1, m_nSizeX, 1 do
		local column = IEex_ReadString(IEex_ReadDword(columnAccess))
		if column == columnString then
			columnIndex = i - 1 -- zero-indexing in memory
			break
		end
		columnAccess = columnAccess + 0x4
	end
	return columnIndex
end

function IEex_2DAFindRow(C2DArray, rowString)
	local m_nSizeY = IEex_ReadWord(C2DArray + 0x20, 1)
	local rowIndex = nil
	local rowAccess = IEex_ReadDword(C2DArray + 0x14)
	for i = 1, m_nSizeY, 1 do
		local row = IEex_ReadString(IEex_ReadDword(rowAccess))
		if row == rowString then
			rowIndex = i - 1 -- zero-indexing in memory
			break
		end
		rowAccess = rowAccess + 0x4
	end
	return rowIndex
end

function IEex_2DAGetAt(C2DArray, x, y)
	local array = IEex_ReadDword(C2DArray + 0x18)
	local m_nSizeX = IEex_ReadWord(C2DArray + 0x20, 0)
	local accessOffset = (m_nSizeX * y + x) * 4
	return IEex_ReadString(IEex_ReadDword(array + accessOffset))
end

function IEex_2DAGetAtStrings(arrayName, columnString, rowString)

	local C2DArray = IEex_2DADemand(arrayName)
	local defaultString = IEex_ReadString(IEex_ReadDword(C2DArray + 0x1C))

	local columnIndex = IEex_2DAFindColumn(C2DArray, columnString)
	-- Tried to lookup a non-existent column, serve default
	if not columnIndex then return defaultString end 

	local rowIndex = IEex_2DAFindRow(C2DArray, rowString)
	-- Tried to lookup a non-existent row, serve default
	if not rowIndex then return defaultString end 

	local array = IEex_ReadDword(C2DArray + 0x18)
	local m_nSizeX = IEex_ReadWord(C2DArray + 0x20, 0)
	local accessOffset = (m_nSizeX * rowIndex + columnIndex) * 4
	return IEex_ReadString(IEex_ReadDword(array + accessOffset))

end

function IEex_2DAGetAtRelated(arrayName, relatedColumn, columnString, compareFunc)

	local C2DArray = IEex_2DADemand(arrayName)
	local defaultString = IEex_ReadString(IEex_ReadDword(C2DArray + 0x1C))

	local relatedColumnIndex = IEex_2DAFindColumn(C2DArray, relatedColumn)
	if not relatedColumnIndex then return defaultString end 

	local columnIndex = IEex_2DAFindColumn(C2DArray, columnString)
	if not columnIndex then return defaultString end 

	local foundRowIndex = nil
	local maxRowIndex = IEex_ReadWord(C2DArray + 0x20, 1) - 1
	for rowIndex = 0, maxRowIndex, 1 do
		if compareFunc(IEex_2DAGetAt(C2DArray, relatedColumnIndex, rowIndex)) then
			foundRowIndex = rowIndex
			break
		end
	end

	if not foundRowIndex then return defaultString end 

	return IEex_2DAGetAt(C2DArray, columnIndex, foundRowIndex)

end

----------------------
-- ActorID Fetching --
----------------------

function IEex_GetActorIDShare(share)
	return IEex_ReadDword(share + 0x5C)
end

function IEex_GetActorIDCursor()

	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local m_pObjectGame = IEex_ReadDword(g_pBaldurChitin + 0x1C54)

	local m_visibleArea = IEex_ReadByte(m_pObjectGame + 0x37E0, 0)
	-- m_gameAreas[m_visibleArea]
	local CGameArea = IEex_ReadDword(m_pObjectGame + m_visibleArea * 0x4 + 0x37E2)
	local m_iPicked = IEex_ReadDword(CGameArea + 0x246)

	return m_iPicked

end

function IEex_GetActorIDCharacter(characterNum)
	if characterNum >= 0 and characterNum <= 5 then
		local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
		local m_pObjectGame = IEex_ReadDword(g_pBaldurChitin + 0x1C54)
		return IEex_ReadDword(m_pObjectGame + 0x3816 + characterNum * 0x4)
	end
	return -1
end

function IEex_GetActorIDPortrait(portraitNum)
	if portraitNum >= 0 and portraitNum <= 5 then
		local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
		local m_pObjectGame = IEex_ReadDword(g_pBaldurChitin + 0x1C54)
		return IEex_ReadDword(m_pObjectGame + 0x382E + portraitNum * 0x4)
	end
	return -1
end

function IEex_GetActorIDSelected()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local m_pObjectGame = IEex_ReadDword(g_pBaldurChitin + 0x1C54)
	local nodeHead = IEex_ReadDword(m_pObjectGame + 0x388E)
	if nodeHead ~= 0x0 then
		return IEex_ReadDword(nodeHead + 0x8)
	end
	return -1
end

function IEex_GetActorShare(actorID)

	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local m_pObjectGame = IEex_ReadDword(g_pBaldurChitin + 0x1C54)
	local CGameObjectArray = m_pObjectGame + 0x372C

	local resultPtr = IEex_Malloc(0x4)
	IEex_Call(0x599A50, {-1, resultPtr, 0, actorID}, CGameObjectArray, 0x0)

	local toReturn = IEex_ReadDword(resultPtr)
	IEex_Free(resultPtr)
	return toReturn

end

---------------------------------------------------------------------------
-- Functions which are called to determine if certain feats can be taken --
---------------------------------------------------------------------------

function Feats_True(actorID, featID)
	return true
end

function Feats_AugmentSummoning(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x785, 0x0) > 0)
end

function Feats_ConcoctPotions(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x7B4, 0x0) >= 10)
end

function Feats_DefensiveStance(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 2)
--	return (IEex_ReadByte(creatureData + 0x627, 0x0) > 0 or IEex_ReadByte(creatureData + 0x62B, 0x0) > 0 or IEex_ReadByte(creatureData + 0x62C, 0x0) > 0 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 0 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 0)
end

function Feats_ExtendSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local extendSpellFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_EXTEND_SPELL"], 0x0)
	if extendSpellFeatCount == 0 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 6 or IEex_ReadByte(creatureData + 0x629, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 7 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 7 or IEex_ReadByte(creatureData + 0x630, 0x0) > 5 or IEex_ReadByte(creatureData + 0x631, 0x0) > 4)
	elseif extendSpellFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 12 or IEex_ReadByte(creatureData + 0x629, 0x0) > 8 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 8 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 13 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 13 or IEex_ReadByte(creatureData + 0x630, 0x0) > 9 or IEex_ReadByte(creatureData + 0x631, 0x0) > 8)
	elseif extendSpellFeatCount == 2 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 19 or IEex_ReadByte(creatureData + 0x629, 0x0) > 12 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 12 or IEex_ReadByte(creatureData + 0x630, 0x0) > 13 or IEex_ReadByte(creatureData + 0x631, 0x0) > 12)
	elseif extendSpellFeatCount == 3 then
		return (IEex_ReadByte(creatureData + 0x629, 0x0) > 16 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 16 or IEex_ReadByte(creatureData + 0x630, 0x0) > 17 or IEex_ReadByte(creatureData + 0x631, 0x0) > 16)
	else
		return true
	end
end

function Feats_Feint(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x7B6, 0x0) >= 4)
end

function Feats_ImprovedSneakAttack(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x62F, 0x0) > 0)
end

function Feats_ImprovedTwoWeaponFighting(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 16 and (IEex_ReadByte(creatureData + 0x62E, 0x0) > 0 or (bit32.band(IEex_ReadDword(creatureData + 0x75C), 0x2) > 0 and bit32.band(IEex_ReadDword(creatureData + 0x764), 0x40) > 0)))
end

function Feats_ImprovedUnarmedAbilities(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (bit32.band(IEex_ReadDword(creatureData + 0x764), 0x8) > 0)
end

function Feats_Kensei(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x626, 0x0) < 2 and IEex_ReadByte(creatureData + 0x62B, 0x0) > 0)
end

function Feats_Knockdown(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 5)
end

function Feats_LightArmorMastery(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x805, 0x0) >= 17 and IEex_ReadByte(creatureData + 0x783, 0x0) > 0)
end

function Feats_MasterOfMagicForce(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x7C1, 0x0) >= 10 and (IEex_ReadByte(creatureData + 0x628, 0x0) > 9 or IEex_ReadByte(creatureData + 0x629, 0x0) > 6 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 6 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 10 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 10 or IEex_ReadByte(creatureData + 0x630, 0x0) > 7 or IEex_ReadByte(creatureData + 0x631, 0x0) > 6))
end

function Feats_MaximizeSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local maximizeSpellFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MAXIMIZE_SPELL"], 0x0)
	if maximizeSpellFeatCount == 0 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 19 or IEex_ReadByte(creatureData + 0x629, 0x0) > 12 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 12 or IEex_ReadByte(creatureData + 0x630, 0x0) > 13 or IEex_ReadByte(creatureData + 0x631, 0x0) > 12)
	elseif maximizeSpellFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 23 or IEex_ReadByte(creatureData + 0x629, 0x0) > 14 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 14 or IEex_ReadByte(creatureData + 0x630, 0x0) > 15 or IEex_ReadByte(creatureData + 0x631, 0x0) > 14)
	elseif maximizeSpellFeatCount == 2 then
		return (IEex_ReadByte(creatureData + 0x629, 0x0) > 16 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 16 or IEex_ReadByte(creatureData + 0x630, 0x0) > 17 or IEex_ReadByte(creatureData + 0x631, 0x0) > 16)
	else
		return true
	end
end

function Feats_Mobility(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x805, 0x0) >= 13 and bit32.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0)
end

function Feats_QuickenSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local quickenSpellFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_QUICKEN_SPELL"], 0x0)
	if quickenSpellFeatCount == 0 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 12 or IEex_ReadByte(creatureData + 0x629, 0x0) > 8 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 8 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 13 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 13 or IEex_ReadByte(creatureData + 0x630, 0x0) > 9 or IEex_ReadByte(creatureData + 0x631, 0x0) > 8)
	elseif quickenSpellFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 15 or IEex_ReadByte(creatureData + 0x629, 0x0) > 10 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 10 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 16 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 16 or IEex_ReadByte(creatureData + 0x630, 0x0) > 11 or IEex_ReadByte(creatureData + 0x631, 0x0) > 10)
	elseif quickenSpellFeatCount == 2 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 19 or IEex_ReadByte(creatureData + 0x629, 0x0) > 12 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 12 or IEex_ReadByte(creatureData + 0x630, 0x0) > 13 or IEex_ReadByte(creatureData + 0x631, 0x0) > 12)
	elseif quickenSpellFeatCount == 3 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 23 or IEex_ReadByte(creatureData + 0x629, 0x0) > 14 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 14 or IEex_ReadByte(creatureData + 0x630, 0x0) > 15 or IEex_ReadByte(creatureData + 0x631, 0x0) > 14)
	elseif quickenSpellFeatCount == 4 then
		return (IEex_ReadByte(creatureData + 0x629, 0x0) > 16 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 16 or IEex_ReadByte(creatureData + 0x630, 0x0) > 17 or IEex_ReadByte(creatureData + 0x631, 0x0) > 16)
	else
		return true
	end
end

function Feats_RapidReload(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 11 and IEex_ReadByte(creatureData + 0x775, 0x0) >= 2)
end

function Feats_SafeSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local safeSpellFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SAFE_SPELL"], 0x0)
	if safeSpellFeatCount == 0 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 6 or IEex_ReadByte(creatureData + 0x629, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 7 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 7 or IEex_ReadByte(creatureData + 0x630, 0x0) > 5 or IEex_ReadByte(creatureData + 0x631, 0x0) > 4)
	elseif safeSpellFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 12 or IEex_ReadByte(creatureData + 0x629, 0x0) > 8 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 8 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 13 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 13 or IEex_ReadByte(creatureData + 0x630, 0x0) > 9 or IEex_ReadByte(creatureData + 0x631, 0x0) > 8)
	elseif safeSpellFeatCount == 2 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 19 or IEex_ReadByte(creatureData + 0x629, 0x0) > 12 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 12 or IEex_ReadByte(creatureData + 0x630, 0x0) > 13 or IEex_ReadByte(creatureData + 0x631, 0x0) > 12)
	elseif safeSpellFeatCount == 3 then
		return (IEex_ReadByte(creatureData + 0x629, 0x0) > 16 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 16 or IEex_ReadByte(creatureData + 0x630, 0x0) > 17 or IEex_ReadByte(creatureData + 0x631, 0x0) > 16)
	else
		return true
	end
end

function Feats_ShieldFocus(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	if bit32.band(IEex_ReadDword(creatureData + 0x760), 0x100000) == 0 then
		return false
	else
		local shieldFocusFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SHIELD_FOCUS"], 0x0)
		return (shieldFocusFeatCount == 0 or IEex_ReadByte(creatureData + 0x62B, 0x0) > 3)
	end
end

function Feats_SpringAttack(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x805, 0x0) >= 13 and bit32.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MOBILITY"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 4)
end

function Feats_TerrifyingRage(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x627, 0x0) > 14 and IEex_ReadByte(creatureData + 0x7BB, 0x0) >= 18)
end

function Feats_TwoWeaponDefense(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x62E, 0x0) > 0 or bit32.band(IEex_ReadDword(creatureData + 0x764), 0x40) > 0)
end

------------------------------------------------------------
-- Functions which can be used by Opcode 500 (Invoke Lua) --
------------------------------------------------------------

-- Does a search through the creature's data for the
--  number specified by parameter1. Each time it finds the number,
--  it prints the value's offset from the beginning of the creature data.
--  The special parameter determines the number of bytes to search. If the
--  save bonus parameter is greater than 0, it searches for an 8-character string
--  rather than a number.
-- This function can be used to find where a certain stat is stored in the creature's data.
function EXSEARCH(effectData, creatureData)
	local is_string = IEex_ReadDword(effectData + 0x40)
	local search_end = IEex_ReadDword(effectData + 0x44)
	if is_string > 0 then
		local search_target = IEex_ReadLString(effectData + 0x18, 0x8)
		for i = 0, search_end, 1 do
			if IEex_ReadLString(creatureData + i, 0x8) == search_target then
				IEex_DisplayString("Match found for " .. search_target .. " at offset " .. i)
			end
		end
	else
		local search_byte = IEex_ReadByte(effectData + 0x18, 0x0)
		local search_word = IEex_ReadWord(effectData + 0x18, 0x0)
		local search_dword = IEex_ReadDword(effectData + 0x18)
		for i = 0, search_end, 1 do
			if IEex_ReadDword(creatureData + i) == search_dword then
				IEex_DisplayString("Match found for " .. search_dword .. " at offset " .. i .. " (4 bytes)")
			elseif search_dword < 65536 and IEex_ReadWord(creatureData + i, 0x0) == search_word then
				IEex_DisplayString("Match found for " .. search_word .. " at offset " .. i .. " (2 bytes)")
			elseif search_dword < 256 and IEex_ReadByte(creatureData + i, 0x0) == search_byte then
				IEex_DisplayString("Match found for " .. search_byte .. " at offset " .. i .. " (1 byte)")
			end
		end
	end
end

function EXPRINTO(effectData, creatureData)
	local offset = IEex_ReadDword(effectData + 0x1c)
	local read_size = IEex_ReadDword(effectData + 0x40)
	if read_size == 1 then
		IEex_DisplayString("Byte at offset " .. offset .. " is " .. IEex_ReadByte(creatureData + offset, 0x0))
	elseif read_size == 2 then
		IEex_DisplayString("Word at offset " .. offset .. " is " .. IEex_ReadWord(creatureData + offset, 0x0))
	elseif read_size == 4 or read_size == 0 then
		IEex_DisplayString("Dword at offset " .. offset .. " is " .. IEex_ReadDword(creatureData + offset))
	else
		IEex_DisplayString("String at offset " .. offset .. " is " .. IEex_ReadLString(creatureData + offset, 0x8))
	end
end

function EXPRINTS(effectData, creatureData)
	local starting = IEex_ReadDword(effectData + 0x1C)
	local ending = IEex_ReadDword(effectData + 0x44)
	for i = starting, ending, 1 do
		IEex_DisplayString(IEex_ToHex(i, 0, true) .. ": " .. IEex_ReadByte(creatureData + i, 0x0) .. ", " .. IEex_ReadWord(creatureData + i, 0x0) .. ", " .. IEex_ReadDword(creatureData + i) .. ", \"" .. IEex_ReadLString(creatureData + i, 8) .. "\"")
	end 
end

function IEex_Search(search_target, search_start, search_length, is_string)
	if is_string then
		for i = 0, search_length, 1 do
			if IEex_ReadLString(search_start + i, 0x8) == search_target then
				IEex_DisplayString("Match found for " .. search_target .. " at offset " .. i)
			end
		end
	else
		for i = 0, search_length, 1 do
			if IEex_ReadDword(search_start + i) == search_target then
				IEex_DisplayString("Match found for " .. search_target .. " at offset " .. i .. " (4 bytes)")
			elseif search_target < 65536 and IEex_ReadWord(search_start + i, 0x0) == search_target then
				IEex_DisplayString("Match found for " .. search_target .. " at offset " .. i .. " (2 bytes)")
			elseif search_target < 256 and IEex_ReadByte(search_start + i, 0x0) == search_target then
				IEex_DisplayString("Match found for " .. search_target .. " at offset " .. i .. " (1 byte)")
			end
		end
	end
end

function IEex_PrintData(search_start, search_length)
	for i = 0, search_length, 1 do
		IEex_DisplayString(IEex_ToHex(i, 0, true) .. ": " .. IEex_ReadByte(search_start + i, 0x0) .. ", " .. IEex_ReadWord(search_start + i, 0x0) .. ", " .. IEex_ReadDword(search_start + i) .. ", \"" .. IEex_ReadLString(search_start + i, 8) .. "\"")
	end 
end

ex_stat_check = {
[200] = {0x5C0, 2, 0}, --Current HP
[201] = {0x5C4, 4, 0}, --Animation
[202] = {0x758, 1, 0}, --Base Damage Reduction
[203] = {0x774, 1, 0}, --Proficiency: Bow
[204] = {0x775, 1, 0}, --Proficiency: Crossbow
[205] = {0x776, 1, 0}, --Proficiency: Missile
[206] = {0x777, 1, 0}, --Proficiency: Axe
[207] = {0x778, 1, 0}, --Proficiency: Mace
[208] = {0x779, 1, 0}, --Proficiency: Flail
[209] = {0x77A, 1, 0}, --Proficiency: Polearm
[210] = {0x77B, 1, 0}, --Proficiency: Hammer
[211] = {0x77C, 1, 0}, --Proficiency: Quarterstaff
[212] = {0x77D, 1, 0}, --Proficiency: Greatsword
[213] = {0x77E, 1, 0}, --Proficiency: Large Sword
[214] = {0x77F, 1, 0}, --Proficiency: Small Blade
[215] = {0x780, 1, 0}, --Toughness
[216] = {0x781, 1, 0}, --Armored Arcana
[217] = {0x782, 1, 0}, --Cleave
[218] = {0x783, 1, 0}, --Armor Proficiency
[219] = {0x784, 1, 0}, --Spell Focus: Enhantment
[220] = {0x785, 1, 0}, --Spell Focus: Evocation
[221] = {0x786, 1, 0}, --Spell Focus: Necromancy
[222] = {0x787, 1, 0}, --Spell Focus: Transmutation
[223] = {0x788, 1, 0}, --Spell Penetration
[224] = {0x789, 1, 0}, --Extra Rage
[225] = {0x78A, 1, 0}, --Extra Wild Shape
[226] = {0x78B, 1, 0}, --Extra Smiting
[227] = {0x78C, 1, 0}, --Extra Turning
[228] = {0x78D, 1, 0}, --Proficiency: Bastard Sword
[229] = {0x7B5, 1, 42}, --Animal Empathy
[230] = {0x7B6, 1, 42}, --Bluff
[231] = {0x7B7, 1, 41}, --Concentration
[232] = {0x7B8, 1, 42}, --Diplomacy
[233] = {0x7B9, 1, 38}, --Disable Device
[234] = {0x7BB, 1, 42}, --Intimidate
[235] = {0x7C1, 1, 38}, --Spellcraft
[236] = {0x7F6, 1, 0}, --Challenge Rating
}
--[[
To use the EXDAMAGE function, create an opcode 500 effect in an item or spell, set the resource to EXDAMAGE (all capitals),
 set the timing to instant, limited and the duration to 0, and choose parameters.

The EXDAMAGE function deals damage to the target. The main use of it is to put it on a weapon that should deal non-physical
 damage, such as the Flame Blade. The function can add bonuses to the damage dealt based on the character's Strength, proficiencies,
 and general weapon damage bonuses. This can't be done simply by applying a damage effect normally.

parameter1 - The first byte determines the damage, the second byte determines the dice size, the third byte determines the dice number,
 and the fourth byte determines the feat ID of the proficiency used. For example, if the effect is from a greatsword and should do 2d6+3 damage,
 parameter1 should be this:
 0x29020603
 0x29 is the Martial Weapon: Greatsword feat ID, 0x2 is the dice number, 0x6 is the dice size, and 0x3 is the damage bonus.
 If a proficiency is not specified, it doesn't give a damage bonus based on proficiency.

parameter2 - It's the same as parameter2 on the damage opcode: the first two bytes determine whether to just deal damage or set HP or whatever.
 The last two bytes determine the damage type. If you simply want to deal fire damage, parameter2 would be 0x80000.

savingthrow - This function uses several extra bits on this parameter:
Bit 10: If set, there is a Fortitude saving throw to prevent/halve the damage.
Bit 11: If set, there is a Reflex saving throw to prevent/halve the damage.
Bit 12: If set, there is a Will saving throw to prevent/halve the damage.
Bit 16: If set, the damage is multiplied by opcode 73 (when parameter2 > 0).
Bit 17: If set, the damage is treated as the base damage of a melee weapon, so it gets damage bonuses from opcode 73 (when parameter2 = 0) and Power Attack.
Bit 18: If set, the damage is treated as the base damage of a missile weapon, so it gets damage bonuses from opcode 73 (when parameter2 = 0).
If both bits 17 and 18 are set, opcode 73 damage bonuses are not applied multiple times. Also, if at least one
 of those two bits are set, the minimum damage of each die will be increased based on the source character's Luck bonuses.
 If neither of those two bits are set, the maximum damage of each die is decreased based on the target character's Luck bonuses.

savebonus - The saving throw DC bonus of the damage is equal to that of the opcode 500 effect.

special - The first byte determines which stat should be used to determine an extra damage bonus (e.g. for Strength weapons, this would be stat 36 or 0x24: the Strength stat).
 If set to 0, there is no stat-based damage bonus. If the chosen stat is an ability score, the bonus will be based on the ability score bonus (e.g. 16 Strength would translate to +3);
 otherwise, the bonus is equal to the stat. The second byte determines a multiplier to the stat-based damage bonus, while the third byte determines a divisor to it (for example,
 if the damage was from a two-handed Strength weapon, special would be equal to 0x20324: the Strength bonus is multiplied by 3 then divided by 2 to get the damage bonus). If the
 multiplier or divisor is 0, the function sets it to 1.
--]]
ex_crippling_strike = {ex_tra_905, ex_tra_905, ex_tra_905, ex_tra_905, ex_tra_905, ex_tra_906, ex_tra_906, ex_tra_906, ex_tra_907, ex_tra_907, ex_tra_907, ex_tra_908, ex_tra_908, ex_tra_908, ex_tra_909, ex_tra_909, ex_tra_909, ex_tra_910, ex_tra_910, ex_tra_910, ex_tra_911, ex_tra_911, ex_tra_911, ex_tra_912, ex_tra_912, ex_tra_912, ex_tra_913, ex_tra_913, ex_tra_913, ex_tra_914}
ex_arterial_strike = {1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5}
ex_damage_source_spell = {["EFFAS1"] = "SPWI217", ["EFFAS2"] = "SPWI217", ["EFFCL"] = "SPPR302", ["EFFCT1"] = "SPWI117", ["EFFDA3"] = "SPWI228", ["EFFFS1"] = "SPWI427", ["EFFFS2"] = "SPWI426", ["EFFIK"] = "SPWI122", ["EFFMB1"] = "SPPR318", ["EFFMB2"] = "SPPR318", ["EFFMT1"] = "SPPR322", ["EFFPB1"] = "SPWI521", ["EFFPB2"] = "SPWI521", ["EFFS1"] = "SPPR113", ["EFFS2"] = "SPPR113", ["EFFS3"] = "SPPR113", ["EFFSC"] = "SPPR523", ["EFFSOF1"] = "SPWI511", ["EFFSOF2"] = "SPWI511", ["EFFSR1"] = "SPPR707", ["EFFSR2"] = "SPPR707", ["EFFSSO1"] = "SPPR608", ["EFFSSO2"] = "SPPR608", ["EFFSSO3"] = "SPPR608", ["EFFSSS1"] = "SPWI220", ["EFFSSS2"] = "SPWI220", ["EFFVS1"] = "SPWI424", ["EFFVS2"] = "SPWI424", ["EFFVS3"] = "SPWI424", ["EFFWOM1"] = "SPPR423", ["EFFWOM2"] = "SPPR423", ["EFFHW15"] = "SPWI805", ["EFFHW16"] = "SPWI805", ["EFFHW17"] = "SPWI805", ["EFFHW18"] = "SPWI805", ["EFFHW19"] = "SPWI805", ["EFFHW20"] = "SPWI805", ["EFFHW21"] = "SPWI805", ["EFFHW22"] = "SPWI805", ["EFFHW23"] = "SPWI805", ["EFFHW24"] = "SPWI805", ["EFFHW25"] = "SPWI805", ["EFFWT15"] = "SPWI805", ["EFFWT16"] = "SPWI805", ["EFFWT17"] = "SPWI805", ["EFFWT18"] = "SPWI805", ["EFFWT19"] = "SPWI805", ["EFFWT20"] = "SPWI805", ["EFFWT21"] = "SPWI805", ["EFFWT22"] = "SPWI805", ["EFFWT23"] = "SPWI805", ["EFFWT24"] = "SPWI805", ["EFFWT25"] = "SPWI805", ["USWI422D"] = "SPWI422", ["USWI652D"] = "USWI652", ["USWI954F"] = "USWI954", ["USDESTRU"] = "SPPR717", }
ex_feat_id_offset = {[18] = 0x78D, [38] = 0x777, [39] = 0x774, [40] = 0x779, [41] = 0x77D, [42] = 0x77B, [43] = 0x77E, [44] = 0x77A, [53] = 0x775, [54] = 0x778, [55] = 0x776, [56] = 0x77C, [57] = 0x77F}
ex_damage_multiplier_type = {[0] = 9, [0x10000] = 4, [0x20000] = 2, [0x40000] = 3, [0x80000] = 1, [0x100000] = 8, [0x200000] = 6, [0x400000] = 5, [0x800000] = 10, [0x1000000] = 7, [0x2000000] = 1, [0x4000000] = 2, [0x8000000] = 9, [0x10000000] = 5}
ex_damage_resistance_stat = {[0] = 22, [0x10000] = 17, [0x20000] = 15, [0x40000] = 16, [0x80000] = 14, [0x100000] = 23, [0x200000] = 74, [0x400000] = 73, [0x800000] = 24, [0x1000000] = 21, [0x2000000] = 19, [0x4000000] = 20, [0x8000000] = 22, [0x10000000] = 73}
function EXDAMAGE(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	if not IEex_IsSprite(sourceID, false) then
		sourceID = 0
	end
	local sourceData = 0
	local damage = IEex_ReadByte(effectData + 0x18, 0x0)
	local dicesize = IEex_ReadByte(effectData + 0x19, 0x0)
	local dicenumber = IEex_ReadByte(effectData + 0x1A, 0x0)
	local proficiency = IEex_ReadByte(effectData + 0x1B, 0x0)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local parameter3 = IEex_ReadDword(effectData + 0x5C)
	local damageType = bit32.band(parameter2, 0xFFFF0000)
	local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local savebonus = IEex_ReadDword(effectData + 0x40)
	local bonusStat = IEex_ReadByte(effectData + 0x44, 0x0)
	local bonusStatMultiplier = IEex_ReadByte(effectData + 0x45, 0x0)
	local bonusStatDivisor = IEex_ReadByte(effectData + 0x46, 0x0)
	local saveBonusStat = IEex_ReadByte(effectData + 0x47, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local rogueLevel = 0
	local isSneakAttack = false
	local isTrueBackstab = false
	local hasProtection = false
	if sourceID > 0 then
		sourceData = IEex_GetActorShare(sourceID)
		if proficiency > 0 and ex_feat_id_offset[proficiency] ~= nil then
			local proficiencyDamage = ex_proficiency_damage[IEex_ReadByte(sourceData + ex_feat_id_offset[proficiency], 0x0)]
			if proficiencyDamage ~= nil then
				damage = damage + proficiencyDamage
			end
		end
		if bit32.band(savingthrow, 0x20000) > 0 then
			for i = 1, 5, 1 do
				if IEex_GetActorSpellState(sourceID, i + 75) then
					damage = damage + i
				end
			end
		end
		if IEex_GetActorSpellState(sourceID, 233) and bit32.band(savingthrow, 0x20000) == 0 and bit32.band(savingthrow, 0x40000) == 0 and bit32.band(savingthrow, 0x800000) == 0 then
			damage = damage + math.floor((IEex_GetActorStat(sourceID, 36) - 10) / 2)
		end
		rogueLevel = IEex_GetActorStat(sourceID, 104)
		local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
		if (rogueLevel > 0 or IEex_GetActorSpellState(sourceID, 192)) and bit32.band(savingthrow, 0x80000) and (IEex_GetActorSpellState(sourceID, 218) or (IEex_GetActorSpellState(sourceID, 217) and IEex_DirectionWithinCyclicRange(sourceID, targetID, 9)) or IEex_IsValidBackstabDirection(sourceID, targetID) or bit32.band(stateValue, 0x80140029) > 0) and IEex_GetActorStat(targetID, 96) == 0 and IEex_GetActorSpellState(targetID, 216) == false and (bit32.band(savingthrow, 0x20000) > 0 or bit32.band(savingthrow, 0x40000) > 0 or bit32.band(savingthrow, 0x800000) > 0 or (bit32.band(savingthrow, 0x40000) == 0 and IEex_GetActorSpellState(sourceID, 232))) then
			isSneakAttack = true
			if IEex_GetActorSpellState(sourceID, 217) then
				if IEex_IsValidBackstabDirection(sourceID, targetID) then
					isTrueBackstab = true
				end
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 0,
["resource"] = "USINVSNA",
["source_id"] = sourceID
})
			end
			if IEex_GetActorSpellState(sourceID, 218) == false and ex_no_sneak_attack_delay == false then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = ex_sneak_attack_delay,
["parameter2"] = 216,
["parameter3"] = 1,
["parent_resource"] = "USSNEAKN",
["source_id"] = targetID
})

			end
		end
	end
	local luck = 0
	local currentRoll = 0
	if sourceID > 0 and (bit32.band(savingthrow, 0x20000) > 0 or bit32.band(savingthrow, 0x40000) > 0) then
		damage = damage + IEex_GetActorStat(sourceID, 50)
		luck = IEex_GetActorStat(sourceID, 32)
		if IEex_GetActorSpellState(sourceID, 64) then
			luck = 127
		end
		
		if IEex_GetActorStat(targetID, 103) > 0 then
			local favoredEnemyDamage = math.floor((IEex_GetActorStat(targetID, 103) / 5) + 1)
			local enemyRace = IEex_ReadByte(creatureData + 0x26, 0x0)
			if enemyRace == IEex_ReadByte(sourceData + 0x7F7, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7F8, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7F9, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7FA, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7FB, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7FC, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7FD, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7FE, 0x0) then
				damage = damage + favoredEnemyDamage
			end
		end
	elseif sourceID > 0 and bit32.band(savingthrow, 0x800000) > 0 then
		luck = IEex_GetActorStat(sourceID, 32)
		if IEex_GetActorSpellState(sourceID, 64) then
			luck = 127
		end
	else
		if IEex_GetActorStat(targetID, 32) ~= 0 then
			luck = 0 - IEex_GetActorStat(targetID, 32)
		end
		if sourceID > 0 and IEex_GetActorSpellState(sourceID, 238) then
			local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
			local sourceSpell = ex_damage_source_spell[parent_resource]
			if sourceSpell == nil then
				sourceSpell = parent_resource
			end
			local classSpellLevel = IEex_GetClassSpellLevel(sourceID, casterClass, sourceSpell)
			local maximumMaximizeSpellLevel = 0
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 238 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					if theresource ~= "" and theresource == sourceSpell then
						maximumMaximizeSpellLevel = 99
					else
						maximumMaximizeSpellLevel = maximumMaximizeSpellLevel + theparameter1
					end
				end
			end)
			if (maximumMaximizeSpellLevel >= 99 or classSpellLevel > 0) and maximumMaximizeSpellLevel > classSpellLevel then
				luck = 127
			end
		end
	end
	if dicesize > 0 then
		for i = 1, dicenumber, 1 do
			currentRoll = math.random(dicesize)
			if luck > 0 and currentRoll <= luck then
				currentRoll = luck + 1
			elseif luck < 0 and currentRoll > (dicesize + luck) then
				currentRoll = dicesize + luck
			end
			if currentRoll > dicesize then
				currentRoll = dicesize
			elseif currentRoll < 1 then
				currentRoll = 1
			end
			damage = damage + currentRoll
		end
	end
	local arterialStrikeCount = 0
	local hasCripplingStrikeFeat = false
	if sourceID > 0 then
		hasCripplingStrikeFeat = (bit32.band(IEex_ReadDword(sourceData + 0x75C), 0x800) > 0)
		if bit32.band(savingthrow, 0x80000) > 0 and isSneakAttack then
			local sneakAttackDiceNumber = math.floor((rogueLevel + 1) / 2)
			if IEex_GetActorSpellState(sourceID, 192) then
				IEex_IterateActorEffects(sourceID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					if theopcode == 288 and theparameter2 == 192 then
						local theparameter1 = IEex_ReadDword(eData + 0x1C)
						local thespecial = IEex_ReadDword(eData + 0x48)
						local theresource = IEex_ReadLString(eData + 0x30, 8)
						if (bit32.band(thespecial, 0x1) == 0 or theresource == parent_resource) and (bit32.band(thespecial, 0x2) == 0 or isTrueBackstab) then
							sneakAttackDiceNumber = sneakAttackDiceNumber + theparameter1
						end
					end
				end)
			end
			if IEex_GetActorSpellState(sourceID, 86) then
				if rogueLevel > 30 then
					arterialStrikeCount = 5
				elseif ex_arterial_strike[rogueLevel] ~= nil then
					arterialStrikeCount = ex_arterial_strike[rogueLevel]
				end
				sneakAttackDiceNumber = sneakAttackDiceNumber - arterialStrikeCount
			end
			if IEex_GetActorSpellState(sourceID, 87) then
				sneakAttackDiceNumber = sneakAttackDiceNumber - 2
			end
			dicesize = 6
			for i = 1, sneakAttackDiceNumber, 1 do
				currentRoll = math.random(dicesize)
				if luck > 0 and currentRoll <= luck then
					currentRoll = luck + 1
				elseif luck < 0 and currentRoll > (dicesize + luck) then
					currentRoll = dicesize + luck
				end
				if currentRoll > dicesize then
					currentRoll = dicesize
				elseif currentRoll < 1 then
					currentRoll = 1
				end
				damage = damage + currentRoll
			end
			local sneakAttackString = 25053
			if hasCripplingStrikeFeat then
				if rogueLevel > 30 then
					sneakAttackString = ex_crippling_strike[30]
				elseif rogueLevel > 0 then
					sneakAttackString = ex_crippling_strike[rogueLevel]
				end
			end
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = sneakAttackString,
["parent_resource"] = "USSNEAKM",
["source_id"] = sourceID
})
		end
		if bonusStat > 0 then
			local bonusStatValue = 0
			if ex_stat_check[bonusStat] ~= nil then
				local specialReadSize = ex_stat_check[bonusStat][2]
				if specialReadSize == 1 then
					bonusStatValue = IEex_ReadByte(sourceData + ex_stat_check[bonusStat][1], 0x0)
				elseif specialReadSize == 2 then
					bonusStatValue = IEex_ReadSignedWord(sourceData + ex_stat_check[bonusStat][1], 0x0)
				elseif specialReadSize == 4 then
					bonusStatValue = IEex_ReadDword(sourceData + ex_stat_check[bonusStat][1])
				end
				local specialBonusStat = ex_stat_check[bonusStat][3]
				if specialBonusStat > 0 then
					if specialBonusStat >= 36 and specialBonusStat <= 42 then
						bonusStatValue = bonusStatValue + math.floor((IEex_GetActorStat(sourceID, specialBonusStat) - 10) / 2)
					else
						bonusStatValue = bonusStatValue + IEex_GetActorStat(sourceID, specialBonusStat)
					end
				end
			else
				bonusStatValue = IEex_GetActorStat(sourceID, bonusStat)
			end
			
			if bonusStat >= 36 and bonusStat <= 42 then
				bonusStatValue = math.floor((bonusStatValue - 10) / 2)
			end
			if bonusStatMultiplier ~= 0 then
				bonusStatValue = bonusStatValue * bonusStatMultiplier
			end
			if bonusStatDivisor ~= 0 then
				bonusStatValue = math.floor(bonusStatValue / bonusStatDivisor)
			end
			damage = damage + bonusStatValue
		end
		local saveBonusStatValue = 0
		if saveBonusStat > 0 then
			if saveBonusStat == 120 then
				local highestStatValue = IEex_GetActorStat(sourceID, 38)
				saveBonusStat = 38
				if IEex_GetActorStat(sourceID, 39) > highestStatValue then
					highestStatValue = IEex_GetActorStat(sourceID, 39)
					saveBonusStat = 39
				end
				if IEex_GetActorStat(sourceID, 42) > highestStatValue then
					highestStatValue = IEex_GetActorStat(sourceID, 42)
					saveBonusStat = 42
				end
				saveBonusStatValue = highestStatValue
			else
				saveBonusStatValue = IEex_GetActorStat(sourceID, saveBonusStat)
			end
			if saveBonusStat >= 36 and saveBonusStat <= 42 then
				saveBonusStatValue = math.floor((saveBonusStatValue - 10) / 2)
			end
			if bonusStatMultiplier ~= 0 then
				saveBonusStatValue = saveBonusStatValue * bonusStatMultiplier
			end
			if bonusStatDivisor ~= 0 then
				saveBonusStatValue = math.floor(saveBonusStatValue / bonusStatDivisor)
			end
			savebonus = savebonus + saveBonusStatValue
		end
		if IEex_GetActorSpellState(sourceID, 236) then
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 236 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					if theresource == parent_resource then
						savebonus = savebonus + theparameter1
					end
				end
			end)
		end
	end
	local newSavingThrow = 0
	if bit32.band(savingthrow, 0x400) > 0 then
		newSavingThrow = bit32.bor(newSavingThrow, 0x4)
	end
	if bit32.band(savingthrow, 0x800) > 0 then
		newSavingThrow = bit32.bor(newSavingThrow, 0x8)
	end
	if bit32.band(savingthrow, 0x1000) > 0 then
		newSavingThrow = bit32.bor(newSavingThrow, 0x10)
	end
	if sourceID > 0 and bit32.band(savingthrow, 0x10000) > 0 then
		local damageMultiplier = 100
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 73 and theparameter2 > 0 then
				if ex_damage_multiplier_type[damageType] == theparameter2 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					damageMultiplier = damageMultiplier + theparameter1
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					if theresource == parent_resource then
						local thespecial = IEex_ReadDword(eData + 0x48)
						damageMultiplier = damageMultiplier + thespecial
					end
				end
			elseif parameter2 == 0x7FFFFFFF and theopcode == 288 and theparameter2 == 191 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if thespecial == 0 then
					damage = damage + theparameter1
				elseif thespecial == 2 then
					damageMultiplier = damageMultiplier + theparameter1
				end
			end
		end)
		damage = math.floor(damage * damageMultiplier / 100)
	end
	if parameter2 == 0x7FFFFFFF then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 17,
["target"] = 2,
["timing"] = 1,
["parameter1"] = damage,
["parameter2"] = 0,
["savingthrow"] = newSavingThrow,
["savebonus"] = savebonus,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
	else
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 12,
["target"] = 2,
["timing"] = 1,
["parameter1"] = damage,
["parameter2"] = parameter2,
["savingthrow"] = newSavingThrow,
["savebonus"] = savebonus,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
	end
	if bit32.band(savingthrow, 0x200000) > 0 or bit32.band(savingthrow, 0x400000) > 0 then
		local targetResistance = 0
		if ex_damage_resistance_stat[damageType] ~= nil then
			targetResistance = IEex_GetActorStat(targetID, ex_damage_resistance_stat[damageType])
		end
		local damageDrained = damage - targetResistance
		local drainDuration = 350
		if parameter3 > 0 then
			drainDuration = parameter3
		end
		if damageDrained > 0 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = 4392,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
			if sourceID > 0 then
				if bit32.band(savingthrow, 0x200000) > 0 then
					IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 18,
["target"] = 2,
["timing"] = 0,
["duration"] = drainDuration,
["parameter1"] = damageDrained,
["parameter2"] = 3,
["parent_resource"] = parent_resource,
["source_target"] = sourceID,
["source_id"] = sourceID
})
				end
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 17,
["target"] = 2,
["timing"] = 1,
["parameter1"] = damageDrained,
["parent_resource"] = parent_resource,
["source_target"] = sourceID,
["source_id"] = sourceID
})
			end
		end
	end
	if sourceID > 0 and isSneakAttack then
		if IEex_GetActorSpellState(sourceID, 86) then
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = 37673,
["parent_resource"] = "USSNEAKM",
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = "USWOUN0" .. arterialStrikeCount,
["parent_resource"] = "USWOUN0" .. arterialStrikeCount,
["source_id"] = sourceID
})
		end
		if IEex_GetActorSpellState(sourceID, 87) then
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = 37675,
["parent_resource"] = "USSNEAKM",
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 176,
["target"] = 2,
["timing"] = 0,
["duration"] = 70,
["parameter1"] = 50,
["parameter2"] = 2,
["parent_resource"] = "USHAMSTR",
["source_id"] = sourceID
})
		end
		if hasCripplingStrikeFeat then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 44,
["target"] = 2,
["timing"] = 0,
["duration"] = 70,
["parameter1"] = math.floor(rogueLevel / 3) * -1,
["parent_resource"] = "USCRPSTR",
["source_id"] = sourceID
})
		end
		if IEex_GetActorSpellState(sourceID, 223) then
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 223 then
	--				local theparameter1 = IEex_ReadDword(eData + 0x1C)
	--				local matchHeader = IEex_ReadByte(eData + 0x48, 0x0)
					local spellRES = IEex_ReadLString(eData + 0x30, 8)
					if spellRES ~= "" then
						local newEffectTarget = targetID
						local newEffectTargetX = IEex_ReadDword(effectData + 0x84)
						local newEffectTargetY = IEex_ReadDword(effectData + 0x88)
						if (bit32.band(IEex_ReadDword(eData + 0x38), 0x200000) > 0) then
							newEffectTarget = sourceID
							newEffectTargetX = IEex_ReadDword(effectData + 0x7C)
							newEffectTargetY = IEex_ReadDword(effectData + 0x80)
						end
						local newEffectSource = sourceID
						local newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
						local newEffectSourceY = IEex_ReadDword(effectData + 0x80)
						if (bit32.band(IEex_ReadDword(eData + 0x38), 0x400000) > 0) then
							newEffectSource = targetID
							newEffectSourceX = IEex_ReadDword(effectData + 0x84)
							newEffectSourceY = IEex_ReadDword(effectData + 0x88)
						end
						local usesLeft = IEex_ReadByte(eData + 0x49, 0x0)
						if usesLeft == 1 then
							local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
							IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = theparent_resource,
["source_id"] = sourceID
})
						elseif usesLeft > 0 then
							usesLeft = usesLeft - 1
							IEex_WriteByte(eData + 0x49, usesLeft)
						end
						IEex_ApplyEffectToActor(newEffectTarget, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = spellRES,
["source_x"] = newEffectSourceX,
["source_y"] = newEffectSourceY,
["target_x"] = newEffectTargetX,
["target_y"] = newEffectTargetY,
["casterlvl"] = casterlvl,
["parent_resource"] = spellRES,
["source_target"] = newEffectTarget,
["source_id"] = newEffectSource
})
					end
				end
			end)
		end
	end
end

function MESNEAKA(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local damage = 0
	local dicesize = 6
	local dicenumber = math.floor((IEex_GetActorStat(sourceID, 104) + 1) / 2)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local luck = 0
	if bit32.band(savingthrow, 0x20000) > 0 or bit32.band(savingthrow, 0x40000) > 0 then
		damage = damage + IEex_GetActorStat(sourceID, 50)
		luck = IEex_GetActorStat(sourceID, 32)
		if IEex_GetActorSpellState(sourceID, 64) then
			luck = 127
		end
		parent_resource = ""
	else
		if IEex_GetActorStat(targetID, 32) ~= 0 then
			luck = 0 - IEex_GetActorStat(targetID, 32)
		end
	end
	if dicesize > 0 then
		for i = 1, dicenumber, 1 do
			local currentRoll = math.random(dicesize)
			if luck > 0 and currentRoll <= luck then
				currentRoll = luck + 1
			elseif luck < 0 and currentRoll > (dicesize + luck) then
				currentRoll = dicesize + luck
			end
			if currentRoll > dicesize then
				currentRoll = dicesize
			elseif currentRoll < 1 then
				currentRoll = 1
			end
			damage = damage + currentRoll
		end
	end
	if bit32.band(savingthrow, 0x10000) > 0 then
		local damageMultiplier = 100
		local damageType = bit32.band(parameter2, 0xFFFF0000)
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 73 and theparameter2 > 0 then
				if ex_damage_multiplier_type[damageType] == theparameter2 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					damageMultiplier = damageMultiplier + theparameter1
				end
			end
		end)
		damage = math.floor(damage * damageMultiplier / 100)
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 12,
["target"] = 2,
["timing"] = 1,
["parameter1"] = damage,
["parameter2"] = parameter2,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
end

function MEHEALIN(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	if not IEex_IsSprite(sourceID, false) then
		sourceID = 0
	end
	local sourceData = 0
	local healing = IEex_ReadSignedWord(effectData + 0x18, 0x0)
	local dicesize = IEex_ReadByte(effectData + 0x1A, 0x0)
	local dicenumber = IEex_ReadByte(effectData + 0x1B, 0x0)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local parameter3 = IEex_ReadDword(effectData + 0x5C)
	local damageType = bit32.band(parameter2, 0xFFFF0000)
	local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	if sourceID > 0 then
		sourceData = IEex_GetActorShare(sourceID)
		if IEex_GetActorSpellState(sourceID, 238) and dicenumber > 0 then
			local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
			local sourceSpell = ex_damage_source_spell[parent_resource]
			if sourceSpell == nil then
				sourceSpell = parent_resource
			end
			local classSpellLevel = IEex_GetClassSpellLevel(sourceID, casterClass, sourceSpell)
			local maximumMaximizeSpellLevel = 0
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 238 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					if theresource ~= "" and theresource == sourceSpell then
						maximumMaximizeSpellLevel = 99
					else
						maximumMaximizeSpellLevel = maximumMaximizeSpellLevel + theparameter1
					end
				end
			end)
			if (maximumMaximizeSpellLevel >= 99 or classSpellLevel > 0) and maximumMaximizeSpellLevel > classSpellLevel then
				healing = healing + dicesize * dicenumber
				dicenumber = 0
				dicesize = 0
			end
		end
		if parameter2 == 3 then
			local charismaModifier = ((IEex_GetActorStat(sourceID, 42) - 10) / 2)
			if charismaModifier < 1 then
				charismaModifier = 1
			end
			healing = charismaModifier * IEex_GetActorStat(sourceID, 102)
			parameter2 = 0
		elseif parameter2 == 4 then
			local wisdomModifier = ((IEex_GetActorStat(sourceID, 39) - 10) / 2)
			if wisdomModifier < 1 then
				wisdomModifier = 1
			end
			healing = wisdomModifier * IEex_GetActorStat(sourceID, 101)
			parameter2 = 0
		elseif parameter2 == 5 then
			healing = IEex_GetActorStat(sourceID, 98) * 2
			parameter2 = 0
		end
		if IEex_GetActorSpellState(sourceID, 191) then
			local healingMultiplier = 100
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 191 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if thespecial == 0 then
						healing = healing + theparameter1
					elseif thespecial == 2 then
						healingMultiplier = healingMultiplier + theparameter1
					end
				end
			end)
			healing = math.floor(healing * healingMultiplier / 100)
		end
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 17,
["target"] = 2,
["timing"] = 1,
["parameter1"] = healing,
["parameter2"] = parameter2,
["dicenumber"] = dicenumber,
["dicesize"] = dicesize,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
end

ex_feat_bit_location = {
[0x774] = {0x760, 0x80},
[0x775] = {0x760, 0x200000},
[0x776] = {0x760, 0x800000},
[0x777] = {0x760, 0x40},
[0x778] = {0x760, 0x400000},
[0x779] = {0x760, 0x100},
[0x77A] = {0x760, 0x1000},
[0x77B] = {0x760, 0x400},
[0x77C] = {0x760, 0x1000000},
[0x77D] = {0x760, 0x200},
[0x77E] = {0x760, 0x800},
[0x77F] = {0x760, 0x2000000},
[0x780] = {0x764, 0x20},
[0x781] = {0x75C, 0x10},
[0x782] = {0x75C, 0x100},
[0x783] = {0x75C, 0x8},
[0x784] = {0x760, 0x10000000},
[0x785] = {0x760, 0x20000000},
[0x786] = {0x760, 0x40000000},
[0x787] = {0x760, 0x80000000},
[0x788] = {0x764, 0x1},
[0x78D] = {0x75C, 0x40000},
}

function MEMODFEA(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local stat = IEex_ReadByte(creatureData + parameter2, 0x0)
	stat = stat + parameter1
	if stat < 0 then
		stat = 0
	end
	if ex_feat_bit_location[parameter2] ~= nil then
		local bitLocation = ex_feat_bit_location[parameter2][1]
		local bit = ex_feat_bit_location[parameter2][2]
		local bitList = IEex_ReadDword(creatureData + bitLocation)
		if stat == 0 then
			bitList = bit32.band(bitList, 0xFFFFFFFF - bit)
		else
			bitList = bit32.bor(bitList, bit)
		end
	end
	IEex_WriteByte(creatureData + parameter2, stat)
end

function MECRITIM(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local immunityCount = IEex_ReadSignedWord(creatureData + 0x700, 0x0)
	local permanentImmunity = IEex_ReadByte(creatureData + 0x702, 0x0)
	local specialFlags = IEex_ReadByte(creatureData + 0x89F, 0)
	local isImmune = (bit32.band(specialFlags, 0x2) ~= 0)
	local makePermanent = IEex_ReadDword(effectData + 0x1C)
	if (isImmune and immunityCount == -1) or makePermanent == 1 then 
		immunityCount = 0
		permanentImmunity = 1
		IEex_WriteByte(creatureData + 0x702, permanentImmunity)
	end
	local modifier = IEex_ReadDword(effectData + 0x18)
	if modifier > 0 then
		immunityCount = immunityCount + modifier
		if immunityCount > -1 then
			IEex_WriteByte(creatureData + 0x89F, bit32.bor(specialFlags, 0x2))
		end
	elseif modifier < 0 then
		immunityCount = immunityCount + modifier
		if immunityCount <= -1 then
			IEex_WriteByte(creatureData + 0x89F, bit32.band(specialFlags, 0xFD))
		end
	end
	IEex_WriteWord(creatureData + 0x700, immunityCount)
end

function MECRITRE(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local immunityCount = IEex_ReadSignedWord(creatureData + 0x700, 0x0)
	local permanentImmunity = IEex_ReadByte(creatureData + 0x702, 0x0)
	local specialFlags = IEex_ReadByte(creatureData + 0x89F, 0)
	local isImmune = (bit32.band(specialFlags, 0x2) ~= 0)
	if (isImmune and immunityCount == -1) or permanentImmunity == 1 then 
		immunityCount = 0
		permanentImmunity = 1
		IEex_WriteByte(creatureData + 0x702, permanentImmunity)
		IEex_WriteByte(creatureData + 0x89F, bit32.bor(specialFlags, 0x2))
	else
		immunityCount = -1
		IEex_WriteByte(creatureData + 0x89F, bit32.band(specialFlags, 0xFD))
	end
	IEex_WriteWord(creatureData + 0x700, immunityCount)
end

statspells = {
{[21] = "USRAGE3", [25] = "USRAGE4", [29] = "USRAGE5"}, -- Barbarian Rage
{[0] = "USMAXIM1", [12] = "USMAXIM2"}, -- Maximized Attacks
{[0] = "USDVSH01", [14] = "USDVSH02", [16] = "USDVSH03", [18] = "USDVSH04", [20] = "USDVSH05", [22] = "USDVSH06", [24] = "USDVSH07", [26] = "USDVSH08", [28] = "USDVSH09", [30] = "USDVSH10", [32] = "USDVSH11", [34] = "USDVSH12", [36] = "USDVSH13", [38] = "USDVSH14", [40] = "USDVSH15"}, -- Divine Shield
{[0] = "USW01L01", [10] = "USW01L10", [15] = "USW01L15", [20] = "USW01L20", [25] = "USW01L25", [30] = "USW01L30"}, -- Wild Shape: Winter Wolf
{[0] = "USW02L01", [9] = "USW02L09", [10] = "USW02L10", [13] = "USW02L13", [16] = "USW02L16", [19] = "USW02L19", [22] = "USW02L22", [24] = "USW02L24", [25] = "USW02L25", [28] = "USW02L28"}, -- Wild Shape: Polar Bear
{[0] = "USW03L01", [12] = "USW03L12", [15] = "USW03L15", [16] = "USW03L16", [18] = "USW03L18", [21] = "USW03L21", [24] = "USW03L24", [27] = "USW03L27", [30] = "USW03L30"}, -- Wild Shape: Giant Viper
{[0] = "USW04L01", [16] = "USW04L16", [21] = "USW04L21", [24] = "USW04L24", [26] = "USW04L26"}, -- Wild Shape: Salamander
{[0] = "USW05L01", [16] = "USW05L16", [21] = "USW05L21", [24] = "USW05L24", [26] = "USW05L26"}, -- Wild Shape: Frost Salamander
{[0] = "USW06L01", [16] = "USW06L16", [19] = "USW06L19", [22] = "USW06L22", [24] = "USW06L24", [25] = "USW06L25", [28] = "USW06L28"}, -- Wild Shape: Shambling Mound
{[0] = "USW07L01", [16] = "USW07L16", [20] = "USW07L20", [24] = "USW07L24", [25] = "USW07L25", [30] = "USW07L30"}, -- Wild Shape: Fire Elemental
{[0] = "USW08L01", [16] = "USW08L16", [20] = "USW08L20", [24] = "USW08L24", [25] = "USW08L25", [30] = "USW08L30"}, -- Wild Shape: Earth Elemental
{[0] = "USW09L01", [16] = "USW09L16", [20] = "USW09L20", [24] = "USW09L24", [25] = "USW09L25", [30] = "USW09L30"}, -- Wild Shape: Water Elemental
{[0] = "USW10L01", [16] = "USW10L16", [20] = "USW10L20", [24] = "USW10L24", [25] = "USW10L25", [30] = "USW10L30"}, -- Wild Shape: Air Elemental
{[0] = "USW11L01", }, -- Placeholder
{[0] = "USW12L01", }, -- Placeholder
{[0] = "USW21L01", [9] = "USW21L09", [16] = "USW21L16", [24] = "USW21L24"}, -- Wild Shape: Blink Dog (Feat 1)
{[0] = "USW22L01", [10] = "USW22L10", [15] = "USW22L15", [20] = "USW22L20", [25] = "USW22L25", [30] = "USW22L30"}, -- Wild Shape: Creeping Doom (Feat 2)
{[0] = "USW23L01", [13] = "USW23L13", [18] = "USW23L18", [23] = "USW23L23", [28] = "USW23L28"}, -- Wild Shape: Rhinoceros Beetle (Feat 3)
{[0] = "USW30L01"}, -- Wild Shape: Black Dragon
{[0] = "USDUHM01", [2] = "USDUHM02", [3] = "USDUHM03", [4] = "USDUHM04", [5] = "USDUHM05", [6] = "USDUHM06", [7] = "USDUHM07", [8] = "USDUHM08", [9] = "USDUHM09", [10] = "USDUHM10"},
{[12] = "USDAMA01", [14] = "USDAMA02", [16] = "USDAMA03", [18] = "USDAMA04", [20] = "USDAMA05", [22] = "USDAMA06", [24] = "USDAMA07", [26] = "USDAMA08", [28] = "USDAMA09", [30] = "USDAMA10", [32] = "USDAMA11", [34] = "USDAMA12", [36] = "USDAMA13", [38] = "USDAMA14", [40] = "USDAMA15"}, -- Stat-based bonuses to damage
{[14] = "USDAMA01", [18] = "USDAMA02", [22] = "USDAMA03", [26] = "USDAMA04", [30] = "USDAMA05", [34] = "USDAMA06", [38] = "USDAMA07"}, -- Half stat-based bonuses to damage
{[12] = "USATTA01", [14] = "USATTA02", [16] = "USATTA03", [18] = "USATTA04", [20] = "USATTA05", [22] = "USATTA06", [24] = "USATTA07", [26] = "USATTA08", [28] = "USATTA09", [30] = "USATTA10", [32] = "USATTA11", [34] = "USATTA12", [36] = "USATTA13", [38] = "USATTA14", [40] = "USATTA15"}, -- Stat-based attack bonuses
{[1] = "USDAMA01", [2] = "USDAMA02", [3] = "USDAMA03", [4] = "USDAMA04", [5] = "USDAMA05", [6] = "USDAMA06", [7] = "USDAMA07", [8] = "USDAMA08", [9] = "USDAMA09", [10] = "USDAMA10", [11] = "USDAMA11", [12] = "USDAMA12", [13] = "USDAMA13", [14] = "USDAMA14", [15] = "USDAMA15", [16] = "USDAMA16", [17] = "USDAMA17", [18] = "USDAMA18", [19] = "USDAMA19", [20] = "USDAMA20"}, -- Damage bonuses
{[1] = "USATTA01", [2] = "USATTA02", [3] = "USATTA03", [4] = "USATTA04", [5] = "USATTA05", [6] = "USATTA06", [7] = "USATTA07", [8] = "USATTA08", [9] = "USATTA09", [10] = "USATTA10", [11] = "USATTA11", [12] = "USATTA12", [13] = "USATTA13", [14] = "USATTA14", [15] = "USATTA15", [16] = "USATTA16", [17] = "USATTA17", [18] = "USATTA18", [19] = "USATTA19", [20] = "USATTA20"}, -- Attack bonuses
{[5] = "USACAR01", [10] = "USACAR02", [15] = "USACAR03", [20] = "USACAR04", [25] = "USACAR05", [30] = "USACAR06", [35] = "USACAR07", [40] = "USACAR08", [45] = "USACAR09", [50] = "USACAR10", [55] = "USACAR11", [60] = "USACAR12", [65] = "USACAR13", [70] = "USACAR14", [75] = "USACAR15", [80] = "USACAR16", [85] = "USACAR17", [90] = "USACAR18", [95] = "USACAR19", [100] = "USACAR20", [105] = "USACAR21", [110] = "USACAR22", [115] = "USACAR23", [120] = "USACAR24", [125] = "USACAR25"}, -- Armor bonus based on skills
{[1] = "USIRONDR"}, -- Extra Iron Skins damage reduction
{[12] = "USACSH01", [14] = "USACSH02", [16] = "USACSH03", [18] = "USACSH04", [20] = "USACSH05", [22] = "USACSH06", [24] = "USACSH07", [26] = "USACSH08", [28] = "USACSH09", [30] = "USACSH10", [32] = "USACSH11", [34] = "USACSH12", [36] = "USACSH13", [38] = "USACSH14", [40] = "USACSH15", [42] = "USACSH16", [44] = "USACSH17", [46] = "USACSH18", [48] = "USACSH19", [50] = "USACSH20", [52] = "USACSH21", [54] = "USACSH22", [56] = "USACSH23", [58] = "USACSH24", [60] = "USACSH25"}, -- Stat-based shield bonus
{[12] = "USREGE01", [14] = "USREGE02", [16] = "USREGE03", [18] = "USREGE04", [20] = "USREGE05", [22] = "USREGE06", [24] = "USREGE07", [26] = "USREGE08", [28] = "USREGE09", [30] = "USREGE10", [32] = "USREGE11", [34] = "USREGE12", [36] = "USREGE13", [38] = "USREGE14", [40] = "USREGE15", [42] = "USREGE16", [44] = "USREGE17", [46] = "USREGE18", [48] = "USREGE19", [50] = "USREGE20", [52] = "USREGE21", [54] = "USREGE22", [56] = "USREGE23", [58] = "USREGE24", [60] = "USREGE25"}, -- Stat-based healing}
{[12] = "USPHDR01", [14] = "USPHDR02", [16] = "USPHDR03", [18] = "USPHDR04", [20] = "USPHDR05", [22] = "USPHDR06", [24] = "USPHDR07", [26] = "USPHDR08", [28] = "USPHDR09", [30] = "USPHDR10", [32] = "USPHDR11", [34] = "USPHDR12", [36] = "USPHDR13", [38] = "USPHDR14", [40] = "USPHDR15"},
{[12] = "USSANC05", [14] = "USSANC10", [16] = "USSANC15", [18] = "USSANC20", [20] = "USSANC25", [22] = "USSANC30", [24] = "USSANC35", [26] = "USSANC40", [28] = "USSANC45", [30] = "USSANC50", [32] = "USSANC55", [34] = "USSANC60", [36] = "USSANC65", [38] = "USSANC70", [40] = "USSANC75"},
{[12] = "USSANC10", [14] = "USSANC20", [16] = "USSANC30", [18] = "USSANC40", [20] = "USSANC50", [22] = "USSANC60", [24] = "USSANC70", [26] = "USSANC80", [28] = "USSANC90", [30] = "USSANC00"},
{[3] = "USACAR01", [6] = "USACAR02", [9] = "USACAR03", [12] = "USACAR04", [15] = "USACAR05", [18] = "USACAR06", [21] = "USACAR07", [24] = "USACAR08", [27] = "USACAR09", [30] = "USACAR10", [33] = "USACAR11", [36] = "USACAR12", [39] = "USACAR13", [42] = "USACAR14", [45] = "USACAR15", [48] = "USACAR16", [51] = "USACAR17", [54] = "USACAR18", [57] = "USACAR19", [60] = "USACAR20", [63] = "USACAR21", [66] = "USACAR22", [69] = "USACAR23", [72] = "USACAR24", [75] = "USACAR25"}, -- Armor bonus based on skills
{[2] = "USDAMA01", [4] = "USDAMA02", [6] = "USDAMA03", [8] = "USDAMA04", [10] = "USDAMA05", [12] = "USDAMA06", [14] = "USDAMA07", [16] = "USDAMA08", [18] = "USDAMA09", [20] = "USDAMA10", [22] = "USDAMA11", [24] = "USDAMA12", [26] = "USDAMA13", [28] = "USDAMA14", [30] = "USDAMA15", [32] = "USDAMA16", [34] = "USDAMA17", [36] = "USDAMA18", [38] = "USDAMA19", [40] = "USDAMA20"}, -- Damage bonuses
}

function applyStatSpell(targetID, index, statValue)
	if statValue < 0 then
		statValue = 0
	end
	local statSpellList = statspells[index]
	if statSpellList ~= nil then
		local spellRES = ""
		local highest = -1
		for key,value in pairs(statSpellList) do
			if statValue >= key and key > highest then
				spellRES = value
				highest = key
			end
		end
		if spellRES ~= "" then
			IEex_ApplyResref(spellRES, targetID)
		end
	end
end

function MESTATSP(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local statValue = 0
	local stat = IEex_ReadWord(effectData + 0x18, 0)
	local otherStat = IEex_ReadByte(effectData + 0x1A, 0)
	local subtractStat = IEex_ReadByte(effectData + 0x1B, 0)
	local index = IEex_ReadWord(effectData + 0x1C, 0)
	local readType = IEex_ReadWord(effectData + 0x1E, 0)
	local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	if readType == 0 then
		if ex_stat_check[stat] ~= nil then
			local specialReadSize = ex_stat_check[stat][2]
			if specialReadSize == 1 then
				statValue = IEex_ReadByte(creatureData + ex_stat_check[stat][1], 0x0)
			elseif specialReadSize == 2 then
				statValue = IEex_ReadSignedWord(creatureData + ex_stat_check[stat][1], 0x0)
			elseif specialReadSize == 4 then
				statValue = IEex_ReadDword(creatureData + ex_stat_check[stat][1])
			end
			local specialBonusStat = ex_stat_check[stat][3]
			if specialBonusStat > 0 then
				if specialBonusStat >= 36 and specialBonusStat <= 42 then
					statValue = statValue + math.floor((IEex_GetActorStat(targetID, specialBonusStat) - 10) / 2)
				else
					statValue = statValue + IEex_GetActorStat(targetID, specialBonusStat)
				end
			end
		else
			statValue = IEex_GetActorStat(targetID, stat)
			if otherStat > 0 then
				local otherStatValue = IEex_GetActorStat(targetID, otherStat)
				if otherStatValue > statValue then
					statValue = otherStatValue
				end
			end
			if subtractStat > 0 then
				statValue = statValue - IEex_GetActorStat(targetID, subtractStat)
			end
		end
	elseif readType == 1 then
		statValue = IEex_ReadByte(creatureData + stat, 0)
	elseif readType == 2 then
		statValue = IEex_ReadSignedWord(creatureData + stat, 0)
	elseif readType == 4 then
		statValue = IEex_ReadDword(creatureData + stat)
	end
	statValue = statValue + IEex_ReadDword(effectData + 0x44)
	if bit32.band(savingthrow, 0x10000) > 0 then
		statValue = statValue + IEex_ReadByte(creatureData + 0x78A, 0) * 3
	end
	applyStatSpell(targetID, index, statValue)
end

function MERAGE(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local sourceData = IEex_GetActorShare(sourceID)
	local targetID = IEex_GetActorIDShare(creatureData)
	local duration = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local barbarianLevel = IEex_GetActorStat(sourceID, 96)
	local baseBonus = 0
	if barbarianLevel >= 29 then
		baseBonus = 12
	elseif barbarianLevel >= 25 then
		baseBonus = 10			
	elseif barbarianLevel >= 21 then
		baseBonus = 8	
	elseif barbarianLevel >= 15 then
		baseBonus = 6	
	elseif barbarianLevel >= 1 then
		baseBonus = 4
	end
	local willBonus = math.floor(baseBonus / 2)
	baseBonus = baseBonus + IEex_ReadByte(sourceData + 0x789, 0)

	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 44,
["target"] = 2,
["timing"] = 0,
["duration"] = duration,
["parameter1"] = baseBonus,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 10,
["target"] = 2,
["timing"] = 0,
["duration"] = duration,
["parameter1"] = baseBonus,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 35,
["target"] = 2,
["timing"] = 0,
["duration"] = duration,
["parameter1"] = willBonus,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
end

function METURNUN(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local sourceData = IEex_GetActorShare(sourceID)
	local targetID = IEex_GetActorIDShare(creatureData)
	local targetGeneral = IEex_ReadByte(creatureData + 0x25, 0)
	local targetRace = IEex_ReadByte(creatureData + 0x26, 0)
	if targetGeneral ~= 4 and (targetRace ~= ex_fiend_race or bit32.band(IEex_ReadDword(sourceData + 0x760), 0x2) == 0) then return end
	local duration = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local clericLevel = IEex_GetActorStat(sourceID, 98)
	local paladinLevel = IEex_GetActorStat(sourceID, 102)
	local charismaBonus = math.floor((IEex_GetActorStat(sourceID, 42) - 10) / 2)
	local turnLevel = clericLevel + charismaBonus + IEex_ReadDword(effectData + 0x18)
	if paladinLevel >= 3 then
		turnLevel = turnLevel + paladinLevel - 2
	end
	local turnCheck = math.random(20) + charismaBonus
	if turnCheck <= 0 then
		turnLevel = turnLevel - 4
	elseif turnCheck >= 22 then
		turnLevel = turnLevel + 4
	else
		turnLevel = turnLevel + math.floor((turnCheck - 1) / 3)
	end
	local turningFeat = IEex_ReadByte(sourceData + 0x78C, 0)
	turnLevel = turnLevel + turningFeat * 3
	local sourceAlignment = IEex_ReadByte(sourceData + 0x35, 0)
	local sourceKit = IEex_GetActorStat(sourceID, 89)
	local targetLevel = IEex_GetActorStat(targetID, 95)
	if turnLevel >= targetLevel * 2 then
		if bit32.band(sourceAlignment, 0x3) == 0x3 or (bit32.band(sourceAlignment, 0x3) == 0x2 and (sourceKit == 0x200000 or sourceKit == 0x400000 or sourceKit == 0x800000)) then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 233,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 8,
["parent_resource"] = "USTURNUN",
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 263,
["target"] = 2,
["timing"] = 0,
["duration"] = duration,
["parameter2"] = 4,
["parent_resource"] = "USTURNUN",
["source_id"] = sourceID
})
		elseif IEex_GetActorSpellState(targetID, 8) == false then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 233,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 8,
["parent_resource"] = "USTURNUN",
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 13,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 1,
["parameter2"] = 0x4,
["parent_resource"] = "USTURNUN",
["source_id"] = sourceID
})
		end
	elseif turnLevel > targetLevel then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 233,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 8,
["parent_resource"] = "USTURNUN",
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 236,
["target"] = 2,
["timing"] = 0,
["duration"] = duration,
["parent_resource"] = "USTURNUN",
["source_id"] = sourceID
})
	end
end

function MESMITEH(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local duration = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local charismaBonus = math.floor((IEex_GetActorStat(targetID, 42) - 10) / 2)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 178,
["target"] = 2,
["timing"] = 0,
["duration"] = duration,
["parameter1"] = 3,
["parameter2"] = 8,
["parameter3"] = charismaBonus,
["parent_resource"] = parent_resource,
["source_id"] = targetID
})
end

function MESMITE(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local sourceData = IEex_GetActorShare(sourceID)
	local targetID = IEex_GetActorIDShare(creatureData)
	local duration = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local paladinLevel = IEex_GetActorStat(sourceID, 102)
	local charismaBonus = math.floor((IEex_GetActorStat(sourceID, 42) - 10) / 2)
	local extraDamage = paladinLevel + charismaBonus
	local smitingFeat = IEex_ReadByte(sourceData + 0x78B, 0)
	extraDamage = extraDamage + extraDamage * smitingFeat
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = extraDamage,
["parameter2"] = 0x400000,
["resource"] = "EXDAMAGE",
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
end

function MEHOLYMI(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local statValue = IEex_ReadDword(effectData + 0x44)

	local index = IEex_ReadWord(effectData + 0x1C, 0)
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0)
	if casterClass == 7 then
		statValue = statValue + math.floor((IEex_GetActorStat(targetID, 42) - 10) / 2)
	end
	applyStatSpell(targetID, index, statValue)
end

function MEPERFEC(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local statValue = IEex_ReadDword(effectData + 0x44)
	statValue = statValue + math.floor((IEex_GetActorStat(targetID, 38) - 10) / 2)
	statValue = statValue + math.floor((IEex_GetActorStat(targetID, 39) - 10) / 2)
	statValue = statValue + math.floor((IEex_GetActorStat(targetID, 40) - 10) / 2)
	statValue = statValue + math.floor((IEex_GetActorStat(targetID, 41) - 10) / 2)
	statValue = statValue + math.floor((IEex_GetActorStat(targetID, 42) - 10) / 2)
	local index = IEex_ReadWord(effectData + 0x1C, 0)
	applyStatSpell(targetID, index, statValue)
end

function MESTATRO(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local stat = IEex_ReadWord(effectData + 0x44, 0x0)
	local statValue = IEex_GetActorStat(targetID, stat)
	local dc = IEex_ReadWord(effectData + 0x46, 0x0)
	local roll = math.random(20)
	local invert = (bit32.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
	if roll > 1 and (roll == 20 or statValue + roll >= dc) then
		if invert == false then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, targetID)
			end
		end
	else
		if invert == true then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, targetID)
			end
		end
	end
end

function MESTATES(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local state = IEex_ReadDword(effectData + 0x44)
	local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
	local invert = (bit32.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
	if bit32.band(stateValue, state) > 0 then
		if invert == false then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, targetID)
			end
		end
	else
		if invert == true then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, targetID)
			end
		end
	end
end

function MESTATEI(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
	local invert = (bit32.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
	if bit32.band(stateValue, 0x10) > 0 and bit32.band(stateValue, 0x400000) == 0 then
		if invert == false then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, targetID)
			end
		end
	else
		if invert == true then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, targetID)
			end
		end
	end
end

function MEKILLSP(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
	local invert = (bit32.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
	if bit32.band(stateValue, 0xFC0) > 0 then
		if invert == false then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if bit32.band(stateValue, 0x40) > 0 then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 13,
["target"] = 2,
["timing"] = 1,
["parameter1"] = 1,
["parameter2"] = 0x40,
["target_x"] = IEex_ReadDword(creatureData + 0x6),
["target_y"] = IEex_ReadDword(creatureData + 0xA),
["source_id"] = sourceID
})
			end
			if spellRES ~= "" then
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = spellRES,
["target_x"] = IEex_ReadDword(creatureData + 0x6),
["target_y"] = IEex_ReadDword(creatureData + 0xA),
["parent_resource"] = spellRES,
["source_id"] = sourceID
})
			end
		end
	else
		if invert == true then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if bit32.band(stateValue, 0x40) > 0 then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 13,
["target"] = 2,
["timing"] = 1,
["parameter1"] = 1,
["parameter2"] = 0x40,
["target_x"] = IEex_ReadDword(creatureData + 0x6),
["target_y"] = IEex_ReadDword(creatureData + 0xA),
["source_id"] = sourceID
})
			end
			if spellRES ~= "" then
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = spellRES,
["target_x"] = IEex_ReadDword(creatureData + 0x6),
["target_y"] = IEex_ReadDword(creatureData + 0xA),
["parent_resource"] = spellRES,
["source_id"] = sourceID
})
			end
		end
	end
end

function MESPLSTS(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local spellState1 = IEex_ReadByte(effectData + 0x44, 0x0)
	local spellState2 = IEex_ReadByte(effectData + 0x45, 0x0)
	local spellState3 = IEex_ReadByte(effectData + 0x46, 0x0)
	local spellState4 = IEex_ReadByte(effectData + 0x47, 0x0)
	local invert = (bit32.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
	if IEex_GetActorSpellState(targetID, spellState1) or (spellState2 > 0 and IEex_GetActorSpellState(targetID, spellState2)) or (spellState3 > 0 and IEex_GetActorSpellState(targetID, spellState3)) or (spellState4 > 0 and IEex_GetActorSpellState(targetID, spellState4)) then
		if invert == false then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, targetID)
			end
		end
	else
		if invert == true then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, targetID)
			end
		end
	end
end

function MEMOVSPL(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = spellRES,
["source_id"] = targetID
})
	local destinationX = IEex_ReadDword(creatureData + 0x556E)
	local destinationY = IEex_ReadDword(creatureData + 0x5572)
	local invert = (bit32.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
	if destinationX > 0 or destinationY > 0 then
		if invert == false then
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, targetID)
			end
		end
	else
		if invert == true then
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, targetID)
			end
		end
	end
end

function MERACESP(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local matchRace = IEex_ReadByte(effectData + 0x44, 0x0)
	local matchSubrace = IEex_ReadByte(effectData + 0x45, 0x0)
	local invert = (bit32.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
	if matchRace == IEex_ReadByte(creatureData + 0x26, 0x0) and (matchSubrace == 0 or matchSubrace == IEex_GetActorStat(targetID, 93) + 1) then
		if invert == false then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, targetID)
			end
		end
	else
		if invert == true then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, targetID)
			end
		end
	end
end

function MEACTSPL(effectData, creatureData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	if not IEex_IsSprite(sourceID, false) then return end
	local action = IEex_ReadWord(effectData + 0x44, 0x0)
	if action ~= IEex_ReadWord(creatureData + 0x476, 0x0) then return end
	local targetID = IEex_ReadDword(creatureData + 0x4BE)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	if casterlvl <= 1 then
		casterlvl = IEex_GetActorStat(sourceID, 95)
	end
	local sourceX = IEex_ReadDword(creatureData + 0x6)
	local sourceY = IEex_ReadDword(creatureData + 0xA)
	local range = IEex_ReadWord(effectData + 0x46, 0x0)
	local invert = (bit32.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
	local invertRangeCheck = (bit32.band(IEex_ReadDword(effectData + 0x3C), 0x200000) > 0)
	if targetID > 0 then
		local targetX = IEex_ReadDword(IEex_GetActorShare(targetID) + 0x6)
		local targetY = IEex_ReadDword(IEex_GetActorShare(targetID) + 0xA)
		if range > 0 then
			if invertRangeCheck then
				if IEex_GetDistance(sourceX, sourceY, targetX, targetY) < range then return end
			else
				if IEex_GetDistance(sourceX, sourceY, targetX, targetY) >= range then return end
			end
		end
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 0,
["resource"] = spellRES,
["parent_resource"] = spellRES,
["casterlvl"] = casterlvl,
["source_target"] = targetID,
["source_id"] = sourceID,
["source_x"] = sourceX,
["source_y"] = sourceY,
["target_x"] = targetX,
["target_y"] = targetY
})
	else
		local targetX = IEex_ReadDword(creatureData + 0x540)
		local targetY = IEex_ReadDword(creatureData + 0x544)
		if range > 0 then
			if invertRangeCheck then
				if IEex_GetDistance(sourceX, sourceY, targetX, targetY) < range then return end
			else
				if IEex_GetDistance(sourceX, sourceY, targetX, targetY) >= range then return end
			end
		end
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 0,
["resource"] = spellRES,
["parent_resource"] = spellRES,
["casterlvl"] = casterlvl,
["source_target"] = sourceID,
["source_id"] = sourceID,
["source_x"] = sourceX,
["source_y"] = sourceY,
["target_x"] = targetX,
["target_y"] = targetY
})
	end

end

function MERAGEST(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "MERAGEST",
["source_id"] = targetID
})	
	if IEex_GetActorSpellState(targetID, 159) or IEex_GetActorSpellState(targetID, 160) then
		local barbarianLevel = IEex_GetActorStat(targetID, 96)
		local baseBonus = 0
		if barbarianLevel >= 29 then
			baseBonus = 12
		elseif barbarianLevel >= 25 then
			baseBonus = 10			
		elseif barbarianLevel >= 21 then
			baseBonus = 8	
		elseif barbarianLevel >= 15 then
			baseBonus = 6	
		elseif barbarianLevel >= 1 then
			baseBonus = 4
		end
		baseBonus = baseBonus + IEex_ReadByte(creatureData + 0x789, 0)
		if bit32.band(parameter2, 0x1) > 0 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 44,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = baseBonus + parameter1,
["parent_resource"] = "MERAGEST",
["source_id"] = targetID
})
		end
		if bit32.band(parameter2, 0x2) > 0 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 10,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = baseBonus + parameter1,
["parent_resource"] = "MERAGEST",
["source_id"] = targetID
})
		end
	end
end

function MEREDIRE(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local spellTargetID = IEex_ReadDword(creatureData + 0x4BE)
	local sourceData = IEex_GetActorShare(sourceID)
	local action = IEex_ReadWord(creatureData + 0x476, 0x0)
	if action ~= 31 and action ~= 95 and action ~= 113 and action ~= 114 and action ~= 191 and action ~= 192 and action ~= 321 then return end
	if spellTargetID <= 0 then return end
	if IEex_CompareActorAllegiances(targetID, spellTargetID) == 1 then
		IEex_WriteDword(creatureData + 0x4BE, sourceID)
		IEex_WriteDword(creatureData + 0x540, IEex_ReadDword(sourceData + 0x6))
		IEex_WriteDword(creatureData + 0x544, IEex_ReadDword(sourceData + 0xA))
	else
		IEex_WriteDword(creatureData + 0x4BE, targetID)
		IEex_WriteDword(creatureData + 0x540, IEex_ReadDword(creatureData + 0x6))
		IEex_WriteDword(creatureData + 0x544, IEex_ReadDword(creatureData + 0xA))
	end
end

ex_real_projectile = {
[68] = 67,
[69] = 67,
[70] = 67,
[71] = 67,
[72] = 67,
[73] = 67,
[74] = 67,
[75] = 67,
[76] = 67,
[77] = 67,
}
function MESPELLT(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if targetID == sourceID or not IEex_IsSprite(sourceID, false) or not IEex_IsSprite(targetID, false) then return end
	local sourceData = IEex_GetActorShare(sourceID)
	if IEex_GetActorSpellState(targetID, 193) then
		local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
		local special = IEex_ReadDword(effectData + 0x44)
		local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
		local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
		local sourceSpell = IEex_ReadLString(effectData + 0x18, 8)
		if sourceSpell == "" then
			sourceSpell = parent_resource
		end
		local classSpellLevel = IEex_GetClassSpellLevel(sourceID, casterClass, sourceSpell)
		if classSpellLevel == 0 then
			classSpellLevel = IEex_ReadDword(effectData + 0x14)
		end
		local spellBlocked = false
		local spellTurned = false
		local endTurningRES = "DEFA"
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 193 and spellBlocked == false and spellTurned == false then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if (theparameter1 > 0 or bit32.band(thesavingthrow, 0x10000) > 0) and ((thespecial >= classSpellLevel and classSpellLevel > 0) or (theresource == sourceSpell and theresource ~= "")) and (bit32.band(savingthrow, 0x40000) == 0 or bit32.band(thesavingthrow, 0x40000) > 0) then
					if bit32.band(thesavingthrow, 0x80000) == 0 then
						spellBlocked = true
					end
					if bit32.band(thesavingthrow, 0x100000) == 0 then
						spellTurned = true
					end
					if bit32.band(thesavingthrow, 0x10000) == 0 then
						theparameter1 = theparameter1 - classSpellLevel
						if theparameter1 <= 0 and bit32.band(thesavingthrow, 0x20000) == 0 then
							endTurningRES = IEex_ReadLString(eData + 0x94, 8)
						else
							IEex_WriteDword(eData + 0x1C, theparameter1)
						end
					end
				end
			end
		end)
		if endTurningRES ~= "DEFA" then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = endTurningRES,
["source_id"] = targetID
})
		end
		if spellTurned then
			local projectile = IEex_ReadDword(effectData + 0x9C)
			if ex_real_projectile[projectile] ~= nil then
				projectile = ex_real_projectile[projectile]
			end
			if bit32.band(savingthrow, 0x10000) > 0 then
				projectile = special
			end
			local casterlvl = IEex_ReadDword(effectData + 0xC4)
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 430,
["target"] = 2,
["timing"] = 0,
["parameter2"] = projectile,
["resource"] = sourceSpell,
["parent_resource"] = sourceSpell,
["casterlvl"] = casterlvl,
["source_x"] = IEex_ReadDword(creatureData + 0x6),
["source_y"] = IEex_ReadDword(creatureData + 0xA),
["target_x"] = IEex_ReadDword(sourceData + 0x6),
["target_y"] = IEex_ReadDword(sourceData + 0xA),
["source_id"] = targetID
})
		end
		if spellBlocked then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["resource"] = sourceSpell,
["parent_resource"] = sourceSpell,
["source_id"] = sourceID
})
		end
	end
end

function MEKENSEI(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local casterlvl = IEex_GetActorStat(targetID, 100)
	if casterlvl < 3 then
		casterlvl = 3
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USKENBON",
["source_id"] = targetID
})	

	if IEex_GetActorSpellState(targetID, 241) then
		local hasArmor = false
		local hasMeleeWeapon = false
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 241 then
				local thespecialtype = IEex_ReadByte(eData + 0x48, 0x0)
				if thespecialtype == 1 or thespecialtype == 3 then
					hasArmor = true
				elseif thespecialtype == 5 then
					hasMeleeWeapon = true
				end
			end
		end)
		if hasArmor == false and hasMeleeWeapon == true then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 54,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = math.floor(casterlvl / 3),
["parent_resource"] = "USKENBON",
["source_id"] = targetID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 73,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = math.floor(casterlvl / 3),
["parent_resource"] = "USKENBON",
["source_id"] = targetID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = 2,
["parent_resource"] = "USKENBON",
["source_id"] = targetID
})
		end
	end
end
ex_armor_penalties = {
[41] = {5, 99, 1},
[47] = {50, 99, 10},
[49] = {15, 99, 2},
[53] = {5, 99, 1},
[60] = {10, 6, 0},
[61] = {15, 5, 1},
[62] = {30, 2, 5},
[63] = {40, 0, 7},
[64] = {40, 0, 7},
[65] = {35, 1, 6},
[66] = {20, 4, 3},
[67] = {0, 99, 0},
[68] = {30, 2, 5},
}
function MEARMMAS(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USARMMAS",
["source_id"] = targetID
})	
	local armorType = 67
	if IEex_GetActorSpellState(targetID, 241) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 241 then
				if theparameter1 >= 60 and theparameter1 <= 68 then
					armorType = theparameter1
				end
			end
		end)
		local dexterityBonus = math.floor((IEex_GetActorStat(targetID, 40) - 10) / 2)
		local maxDexBonus = 99
		local armorCheckPenalty = 0
		if ex_armor_penalties[armorType] ~= nil then
			maxDexBonus = ex_armor_penalties[armorType][2]
			armorCheckPenalty = ex_armor_penalties[armorType][3]
		end
		if armorType == 60 or armorType == 61 then
			if armorCheckPenalty > 0 then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 59,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = armorCheckPenalty,
["parent_resource"] = "USARMMAS",
["source_id"] = targetID
})
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 90,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = armorCheckPenalty,
["parent_resource"] = "USARMMAS",
["source_id"] = targetID
})
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 91,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = armorCheckPenalty,
["parent_resource"] = "USARMMAS",
["source_id"] = targetID
})
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 92,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = armorCheckPenalty,
["parent_resource"] = "USARMMAS",
["source_id"] = targetID
})
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 297,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = armorCheckPenalty,
["parent_resource"] = "USARMMAS",
["source_id"] = targetID
})
			end
			if dexterityBonus > maxDexBonus then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = dexterityBonus - maxDexBonus,
["parent_resource"] = "USARMMAS",
["source_id"] = targetID
})
			end
		end
	end
end

function MEARMARC(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USARMARC",
["source_id"] = targetID
})	
	local armorType = 0
	local shieldType = 0
	if IEex_GetActorSpellState(targetID, 241) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 241 then
				local thespecialtype = IEex_ReadByte(eData + 0x48, 0x0)
				if theparameter1 >= 60 and theparameter1 <= 68 then
					armorType = theparameter1
				elseif thespecialtype == 3 then
					shieldType = theparameter1
				end
			end
		end)
		local armoredArcanaFeatCount = IEex_ReadByte(creatureData + 0x781, 0x0)
		local spellFailure = 0
		if ex_armor_penalties[armorType] ~= nil then
			if (armoredArcanaFeatCount >= 1 and (armorType == 60 or armorType == 61)) or (armoredArcanaFeatCount >= 2 and (armorType == 62 or armorType == 66 or armorType == 68)) or (armoredArcanaFeatCount >= 3 and (armorType == 63 or armorType == 64 or armorType == 65)) then
				spellFailure = spellFailure + ex_armor_penalties[armorType][1]
			end
		end
		if ex_armor_penalties[shieldType] ~= nil then
			if (armoredArcanaFeatCount >= 1 and (shieldType == 41 or shieldType == 53)) or (armoredArcanaFeatCount >= 2 and shieldType == 49) or (armoredArcanaFeatCount >= 3 and shieldType == 47) then
				spellFailure = spellFailure + ex_armor_penalties[shieldType][1]
			end
		end
		if spellFailure > 0 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 60,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = 0 - spellFailure,
["parent_resource"] = "USARMARC",
["source_id"] = targetID
})
		end
	end
end

function MERAPREL(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USRAPREX",
["source_id"] = targetID
})
	local oneAPRRES = ""
	local crossbowRES = ""
	if IEex_GetActorSpellState(targetID, 241) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thetiming = IEex_ReadDword(eData + 0x24)
			if thetiming == 2 then
				if theopcode == 1 and theparameter1 == 1 and theparameter2 == 1 then
					oneAPRRES = IEex_ReadLString(eData + 0x94, 8)
				elseif theopcode == 288 and theparameter1 == 27 and theparameter2 == 241 then
					crossbowRES = IEex_ReadLString(eData + 0x94, 8)
				end
			end
		end)
	end
	if oneAPRRES ~= "" and crossbowRES ~= "" and oneAPRRES == crossbowRES then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 1,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = 1,
["parent_resource"] = "USRAPREX",
["source_id"] = targetID
})
	end
--[[
	local rapidReloadFeatID = ex_feat_name_id["ME_RAPID_RELOAD"]
	if rapidReloadFeatID ~= nil then
		local hasRapidReloadFeat = IEex_ReadByte(creatureData + 0x744 + rapidReloadFeatID, 0x0)
		if hasRapidReloadFeat then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USRAPREX",
["source_id"] = targetID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 1,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = 1,
["parent_resource"] = "USRAPREX",
["source_id"] = targetID
})
		end
	end
--]]
end

function MEIMPTWF(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local sourceData = IEex_GetActorShare(sourceID)
--[[
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USIMPTWX",
["source_id"] = targetID
})
--]]
	local weaponCount = 0
	local wearingLightArmor = true
	if IEex_GetActorSpellState(sourceID, 241) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
			if theopcode == 288 and theparameter2 == 241 then
				if thespecial == 5 or thespecial == 6 then
					weaponCount = weaponCount + 1
				elseif (theparameter1 >= 62 and theparameter1 <= 66) or theparameter1 == 68 then
					wearingLightArmor = false
				end
			end
		end)
	end
	if math.random(100) <= 20 and weaponCount >= 2 and (IEex_GetActorStat(sourceID, 103) == 0 or wearingLightArmor or (bit32.band(IEex_ReadDword(sourceData + 0x75C), 0x2) > 0 and bit32.band(IEex_ReadDword(sourceData + 0x764), 0x40) > 0)) then
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 442,
["target"] = 2,
["timing"] = 0,
["parent_resource"] = "USIMPTWX",
["source_id"] = sourceID
})
	end
end

function MESHLDFO(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USSHLDFD",
["source_id"] = targetID
})
	local hasShield = false
	if IEex_GetActorSpellState(targetID, 241) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
			if theopcode == 288 and theparameter2 == 241 then
				if thespecial == 3 then
					hasShield = true
				end
			end
		end)
	end
	if hasShield then
		local shieldFocusFeatID = ex_feat_name_id["ME_SHIELD_FOCUS"]
		if shieldFocusFeatID ~= nil then
			local shieldFocusBonus = IEex_ReadByte(creatureData + 0x744 + shieldFocusFeatID, 0x0) * parameter1
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = shieldFocusBonus,
["parent_resource"] = "USSHLDFD",
["source_id"] = targetID
})
		end
	end
end

function METWDEFE(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USTWDEFD",
["source_id"] = targetID
})
	local weaponCount = 0
	local wearingLightArmor = true
	if IEex_GetActorSpellState(targetID, 241) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
			if theopcode == 288 and theparameter2 == 241 then
				if thespecial == 5 or thespecial == 6 then
					weaponCount = weaponCount + 1
				elseif (theparameter1 >= 62 and theparameter1 <= 66) or theparameter1 == 68 then
					wearingLightArmor = false
				end
			end
		end)
	end
	if weaponCount >= 2 and (IEex_GetActorStat(targetID, 103) == 0 or wearingLightArmor or bit32.band(IEex_ReadDword(creatureData + 0x764), 0x40) > 0) then
		local twoWeaponDefenseFeatID = ex_feat_name_id["ME_TWO_WEAPON_DEFENSE"]
		if twoWeaponDefenseFeatID ~= nil then
			local twoWeaponDefenseBonus = IEex_ReadByte(creatureData + 0x744 + twoWeaponDefenseFeatID, 0x0) * parameter1
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = twoWeaponDefenseBonus,
["parent_resource"] = "USTWDEFD",
["source_id"] = targetID
})
		end
	end
end

function MESPELL(effectData, creatureData)
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	if spellRES ~= "" then
		IEex_ApplyResref(spellRES, targetID)
	end
end

onhitspells = {
[1] = "USOHTEST",
[51] = "USPOISOW",
[5020] = "USCLEA20",
[5050] = "USCLEA50",
[5100] = "USCLEA00",
}

exhitspells = {
[1] = {[10001] = "USSERW10", [10002] = "USSLAY20"},
[2] = {[10003] = "USCRIW20", [10004] = "USDEST30"},
[1001] = {[11001] = "USSNEAKP"},
[2001] = {[12001] = "USBRACTC", [12002] = "USHFBCTC", [12003] = "USQUIVPA", [12004] = "USSTUNAT",},
}

function MEONHIT(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local headerType = IEex_ReadDword(effectData + 0x44)
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		if theopcode == 287 then
			local thetiming = IEex_ReadDword(eData + 0x24)
			local theparameter3 = IEex_ReadDword(eData + 0x60)
			if thetiming == 4096 and theparameter3 == 0 then
				IEex_WriteDword(eData + 0x60, 1)
			end
		end
	end)
	if IEex_GetActorSpellState(sourceID, 225) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 225 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local matchHeader = IEex_ReadByte(eData + 0x48, 0x0)
				local spellRES = IEex_ReadLString(eData + 0x30, 8)
				if spellRES ~= "" and (matchHeader == 0 or matchHeader == headerType) then
					local casterLevel = IEex_ReadDword(effectData + 0xC4)
					local newEffectTarget = targetID
					local newEffectTargetX = IEex_ReadDword(effectData + 0x84)
					local newEffectTargetY = IEex_ReadDword(effectData + 0x88)
					if (bit32.band(IEex_ReadDword(eData + 0x40), 0x200000) > 0) then
						newEffectTarget = sourceID
						newEffectTargetX = IEex_ReadDword(effectData + 0x7C)
						newEffectTargetY = IEex_ReadDword(effectData + 0x80)
					end
					local newEffectSource = sourceID
					local newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
					local newEffectSourceY = IEex_ReadDword(effectData + 0x80)
					if (bit32.band(IEex_ReadDword(eData + 0x40), 0x400000) > 0) then
						newEffectSource = targetID
						newEffectSourceX = IEex_ReadDword(effectData + 0x84)
						newEffectSourceY = IEex_ReadDword(effectData + 0x88)
					end
					local usesLeft = IEex_ReadByte(eData + 0x49, 0x0)
					if usesLeft == 1 then
						local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
						IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = theparent_resource,
["source_id"] = sourceID
})
					elseif usesLeft > 0 then
						usesLeft = usesLeft - 1
						IEex_WriteByte(eData + 0x49, usesLeft)
					end
					IEex_ApplyEffectToActor(newEffectTarget, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = spellRES,
["source_x"] = newEffectSourceX,
["source_y"] = newEffectSourceY,
["target_x"] = newEffectTargetX,
["target_y"] = newEffectTargetY,
["casterlvl"] = casterLevel,
["parent_resource"] = spellRES,
["source_target"] = newEffectTarget,
["source_id"] = newEffectSource
})
				end
			end
		end)
	end
	if IEex_GetActorSpellState(targetID, 226) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 226 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local matchHeader = IEex_ReadByte(eData + 0x48, 0x0)
				local spellRES = IEex_ReadLString(eData + 0x30, 8)
				if spellRES ~= "" and (matchHeader == 0 or matchHeader == headerType) then
					local casterLevel = IEex_ReadDword(effectData + 0xC4)
					local newEffectTarget = targetID
					local newEffectTargetX = IEex_ReadDword(effectData + 0x84)
					local newEffectTargetY = IEex_ReadDword(effectData + 0x88)
					if (bit32.band(IEex_ReadDword(eData + 0x40), 0x200000) > 0) then
						newEffectTarget = sourceID
						newEffectTargetX = IEex_ReadDword(effectData + 0x7C)
						newEffectTargetY = IEex_ReadDword(effectData + 0x80)
					end
					local newEffectSource = sourceID
					local newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
					local newEffectSourceY = IEex_ReadDword(effectData + 0x80)
					if (bit32.band(IEex_ReadDword(eData + 0x40), 0x400000) > 0) then
						newEffectSource = targetID
						newEffectSourceX = IEex_ReadDword(effectData + 0x84)
						newEffectSourceY = IEex_ReadDword(effectData + 0x88)
					end
					local usesLeft = IEex_ReadByte(eData + 0x49, 0x0)
					if usesLeft == 1 then
						local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
						IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = theparent_resource,
["source_id"] = sourceID
})
					elseif usesLeft > 0 then
						usesLeft = usesLeft - 1
						IEex_WriteByte(eData + 0x49, usesLeft)
					end
					IEex_ApplyEffectToActor(newEffectTarget, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = spellRES,
["source_x"] = newEffectSourceX,
["source_y"] = newEffectSourceY,
["target_x"] = newEffectTargetX,
["target_y"] = newEffectTargetY,
["casterlvl"] = casterLevel,
["parent_resource"] = spellRES,
["source_target"] = newEffectTarget,
["source_id"] = newEffectSource
})
				end
			end
		end)
	end
end

function MEEXHIT(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local index = IEex_ReadDword(effectData + 0x1C)
	local headerType = IEex_ReadDword(effectData + 0x44)
	if IEex_GetActorSpellState(sourceID, 225) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 225 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local matchHeader = IEex_ReadByte(eData + 0x48, 0x0)
				local spellRES = IEex_ReadLString(eData + 0x30, 8)
				if theparameter1 == index and spellRES ~= "" and (matchHeader == 0 or matchHeader == headerType) then
					local casterLevel = IEex_ReadDword(effectData + 0xC4)
					local newEffectTarget = targetID
					local newEffectTargetX = IEex_ReadDword(effectData + 0x84)
					local newEffectTargetY = IEex_ReadDword(effectData + 0x88)
					if (bit32.band(IEex_ReadDword(eData + 0x40), 0x200000) > 0) then
						newEffectTarget = sourceID
						newEffectTargetX = IEex_ReadDword(effectData + 0x7C)
						newEffectTargetY = IEex_ReadDword(effectData + 0x80)
					end
					local newEffectSource = sourceID
					local newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
					local newEffectSourceY = IEex_ReadDword(effectData + 0x80)
					if (bit32.band(IEex_ReadDword(eData + 0x40), 0x400000) > 0) then
						newEffectSource = targetID
						newEffectSourceX = IEex_ReadDword(effectData + 0x84)
						newEffectSourceY = IEex_ReadDword(effectData + 0x88)
					end
					local usesLeft = IEex_ReadByte(eData + 0x49, 0x0)
					if usesLeft == 1 then
						local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
						IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = theparent_resource,
["source_id"] = sourceID
})
					elseif usesLeft > 0 then
						usesLeft = usesLeft - 1
						IEex_WriteByte(eData + 0x49, usesLeft)
					end
					IEex_ApplyEffectToActor(newEffectTarget, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = spellRES,
["source_x"] = newEffectSourceX,
["source_y"] = newEffectSourceY,
["target_x"] = newEffectTargetX,
["target_y"] = newEffectTargetY,
["casterlvl"] = casterLevel,
["parent_resource"] = spellRES,
["source_target"] = newEffectTarget,
["source_id"] = newEffectSource
})
				end
			end
		end)
	end
	if IEex_GetActorSpellState(targetID, 226) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 226 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local matchHeader = IEex_ReadByte(eData + 0x48, 0x0)
				local spellRES = IEex_ReadLString(eData + 0x30, 8)
				if theparameter1 == index and spellRES ~= "" and (matchHeader == 0 or matchHeader == headerType) then
					local casterLevel = IEex_ReadDword(effectData + 0xC4)
					local newEffectTarget = targetID
					local newEffectTargetX = IEex_ReadDword(effectData + 0x84)
					local newEffectTargetY = IEex_ReadDword(effectData + 0x88)
					if (bit32.band(IEex_ReadDword(eData + 0x40), 0x200000) > 0) then
						newEffectTarget = sourceID
						newEffectTargetX = IEex_ReadDword(effectData + 0x7C)
						newEffectTargetY = IEex_ReadDword(effectData + 0x80)
					end
					local newEffectSource = sourceID
					local newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
					local newEffectSourceY = IEex_ReadDword(effectData + 0x80)
					if (bit32.band(IEex_ReadDword(eData + 0x40), 0x400000) > 0) then
						newEffectSource = targetID
						newEffectSourceX = IEex_ReadDword(effectData + 0x84)
						newEffectSourceY = IEex_ReadDword(effectData + 0x88)
					end
					local usesLeft = IEex_ReadByte(eData + 0x49, 0x0)
					if usesLeft == 1 then
						local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
						IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = theparent_resource,
["source_id"] = sourceID
})
					elseif usesLeft > 0 then
						usesLeft = usesLeft - 1
						IEex_WriteByte(eData + 0x49, usesLeft)
					end
					IEex_ApplyEffectToActor(newEffectTarget, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = spellRES,
["source_x"] = newEffectSourceX,
["source_y"] = newEffectSourceY,
["target_x"] = newEffectTargetX,
["target_y"] = newEffectTargetY,
["casterlvl"] = casterLevel,
["parent_resource"] = spellRES,
["source_target"] = newEffectTarget,
["source_id"] = newEffectSource
})
				end
			end
		end)
	end
end

function MEREPERM(effectData, creatureData)
	if IEex_ReadDword(effectData + 0x10C) <= 0 then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	if IEex_GetActorSpellState(targetID, 224) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 224 then
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource ~= "" then
					IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = theresource,
["parent_resource"] = theresource,
["source_id"] = targetID,
})
				end
			end
		end)
	end
	local castingSpeedModifier = 0
	local wizardDurationModifier = 100
	local priestDurationModifier = 100
	local spellAlreadyExtended = false
	if IEex_GetActorSpellState(targetID, 193) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 193 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local thespecial = IEex_ReadDword(eData + 0x48)
				local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
				if thespecial == 0 then
					wizardDurationModifier = wizardDurationModifier + theparameter1 - 100
				elseif thespecial == 1 then
					priestDurationModifier = priestDurationModifier + theparameter1 - 100
				elseif thespecial == 2 then
					castingSpeedModifier = castingSpeedModifier + theparameter1
				end
				if theparent_resource == "USLONGSP" then
					spellAlreadyExtended = true
				end
			end
		end)
	end
	if spellAlreadyExtended then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USLONGSP",
["source_id"] = targetID
})
	end
	if castingSpeedModifier ~= IEex_GetActorStat(targetID, 77) then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USCASTSP",
["source_id"] = targetID
})
		if castingSpeedModifier ~= 0 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 189,
["target"] = 2,
["timing"] = 9,
["parameter1"] = castingSpeedModifier,
["parent_resource"] = "USCASTSP",
["source_id"] = targetID
})
		end
	end

	if wizardDurationModifier ~= IEex_GetActorStat(targetID, 53) then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USDURMAG",
["source_id"] = targetID
})
		if wizardDurationModifier ~= 100 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 99,
["target"] = 2,
["timing"] = 9,
["parameter1"] = wizardDurationModifier,
["parent_resource"] = "USDURMAG",
["source_id"] = targetID
})
		end
	end
	if priestDurationModifier ~= IEex_GetActorStat(targetID, 54) then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USDURPRI",
["source_id"] = targetID
})
		if priestDurationModifier ~= 100 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 99,
["target"] = 2,
["timing"] = 9,
["parameter1"] = priestDurationModifier,
["parameter2"] = 1,
["parent_resource"] = "USDURPRI",
["source_id"] = targetID
})
		end
	end

end

function MEONCAST(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	if not IEex_IsSprite(targetID, false) then return end
	local casterlvl = IEex_ReadByte(effectData + 0xC4, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x18, 8)
	local lowestClassSpellLevel = 10
	local classSpellLevel = 1
	for i = 2, 11, 1 do
		if IEex_GetActorStat(targetID, 95 + i) > 0 then 
			classSpellLevel = IEex_GetClassSpellLevel(targetID, i, parent_resource)
			if classSpellLevel > 0 and classSpellLevel < lowestClassSpellLevel then
				lowestClassSpellLevel = classSpellLevel
			end
		end
	end
	classSpellLevel = lowestClassSpellLevel
	
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USFREESP",
["source_id"] = targetID
})
	local maximumQuickenSpellLevel = 0
	if IEex_GetActorSpellState(targetID, 234) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 234 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource ~= "" and theresource == parent_resource then
					maximumQuickenSpellLevel = 99
				else
					maximumQuickenSpellLevel = maximumQuickenSpellLevel + theparameter1
				end
			end
		end)
	end
	if classSpellLevel > 0 and maximumQuickenSpellLevel >= classSpellLevel then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 188,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["parameter2"] = 1,
["parent_resource"] = "USFREESP",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["resource"] = "USFREESP",
["parent_resource"] = "USFREESP",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["resource"] = "USFREESP",
["parent_resource"] = "USFREES2",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["resource"] = "USFREES2",
["parent_resource"] = "USFREES2",
["source_id"] = targetID
})
	end

	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USLONGSP",
["source_id"] = targetID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USLONGS2",
["source_id"] = targetID
})
	local maximumExtendSpellLevel = 0
	if IEex_GetActorSpellState(targetID, 239) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 239 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource ~= "" and theresource == parent_resource then
					maximumExtendSpellLevel = 99
				else
					maximumExtendSpellLevel = maximumExtendSpellLevel + theparameter1
				end
			end
		end)
	end
	if classSpellLevel > 0 and maximumExtendSpellLevel >= classSpellLevel then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 99,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["parameter1"] = 200,
["parameter2"] = 0,
["parent_resource"] = "USLONGSP",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 99,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["parameter1"] = 200,
["parameter2"] = 1,
["parent_resource"] = "USLONGSP",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["parameter1"] = 200,
["parameter2"] = 193,
["special"] = 0,
["parent_resource"] = "USLONGS2",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["parameter1"] = 200,
["parameter2"] = 193,
["special"] = 1,
["parent_resource"] = "USLONGS2",
["source_id"] = targetID
})
	end
	if IEex_GetActorSpellState(targetID, 227) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 227 then
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource ~= "" then
					IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = theresource,
["casterlvl"] = casterlvl,
["source_id"] = targetID
})
				end
			end
		end)
	end
end

function MESAFESP(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local casterlvl = IEex_ReadByte(effectData + 0xC4, 0x0)
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local sourceSpell = IEex_ReadLString(effectData + 0x18, 8)
	if sourceSpell == "" then
		sourceSpell = parent_resource
	end
	local classSpellLevel = IEex_GetClassSpellLevel(targetID, casterClass, sourceSpell)
	local maximumSafeSpellLevel = 0
	if IEex_GetActorSpellState(sourceID, 235) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 235 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource ~= "" and theresource == sourceSpell then
					maximumSafeSpellLevel = 99
				else
					maximumSafeSpellLevel = maximumSafeSpellLevel + theparameter1
				end
			end
		end)
	end
	if classSpellLevel > 0 and maximumSafeSpellLevel >= classSpellLevel then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 290,
["target"] = 2,
["timing"] = 0,
["duration"] = 1,
["parameter2"] = 49,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	end
end
--[[
MESPLPRT works similarly to opcode 290. It grants immunity to the spell if the target satisfies a condition.

Values for special:
0: The target gets immunity if they have protection from the opcode specified by parameter2.
1: The target gets immunity if they have protection from the spell specified by parameter1 and parameter2.
2: The target gets immunity if they have any of the states specified by parameter2.
3: The target gets immunity if they have the spell state specified by parameter2.
4: The target gets immunity if their stat specified by parameter2 satisfies a condition based on the last byte of parameter2.
5:
--]]
function MESPLPRT(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	local checkID = targetID
	local newEffectTarget = targetID
	local hasProtection = false
	local protectionType = IEex_ReadDword(effectData + 0x44)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	if bit32.band(savingthrow, 0x20000) > 0 and sourceID > 0 then
		checkID = sourceID
	end
	if bit32.band(savingthrow, 0x200000) > 0 then
		newEffectTarget = sourceID
	end
	local checkData = IEex_GetActorShare(checkID)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	if protectionType == 0 then
		local match_opcode = IEex_ReadDword(effectData + 0x1C)
		local targetRace = IEex_ReadByte(checkData + 0x26, 0x0)
		local targetSubrace = IEex_ReadByte(checkData + 0x7FF, 0x0)
		if (match_opcode == 39 and (targetRace == 2 or targetRace == 3 or targetRace == 183)) or ((match_opcode == 109 or match_opcode == 175) and ((targetRace == 4 and targetSubrace == 2) or targetRace == 185)) then
			hasProtection = true
		elseif ((match_opcode == 55 or match_opcode == 420) and IEex_GetActorSpellState(checkID, 8)) or ((match_opcode == 40 or match_opcode == 109 or match_opcode == 154 or match_opcode == 157 or match_opcode == 158 or match_opcode == 175 or match_opcode == 176) and IEex_GetActorSpellState(checkID, 29)) then
			hasProtection = true
		elseif ((match_opcode == 24 or match_opcode == 236) and IEex_GetActorStat(checkID, 102) >= 2) or (match_opcode == 25 and (IEex_GetActorStat(checkID, 99) >= 9 or IEex_GetActorStat(checkID, 101) >= 11)) or (match_opcode == 78 and (IEex_GetActorStat(checkID, 101) >= 5 or IEex_GetActorStat(checkID, 102) >= 1)) then
			hasProtection = true
		else
			IEex_IterateActorEffects(checkID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if (theopcode == 101 or theopcode == 261) and theparameter2 == match_opcode then
					hasProtection = true
				end
			end)
		end
	elseif protectionType == 1 then
		local protectionRES = IEex_ReadLString(effectData + 0x18, 8)
		IEex_IterateActorEffects(checkID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			if (theopcode == 206 or theopcode == 290) and theresource == protectionRES then
				hasProtection = true
			end
		end)
	elseif protectionType == 2 then
		local match_state = IEex_ReadDword(effectData + 0x1C)
		local stateValue = bit32.bor(IEex_ReadDword(checkData + 0x5BC), IEex_ReadDword(checkData + 0x920))
		if bit32.band(stateValue, match_state) > 0 then
			hasProtection = true
		end
	elseif protectionType == 3 then
		local match_spellState = IEex_ReadDword(effectData + 0x1C)
		if IEex_GetActorSpellState(checkID, match_spellState) then
			hasProtection = true
		end
	elseif protectionType == 4 then
		local match_value = IEex_ReadDword(effectData + 0x18)
		local match_stat = IEex_ReadWord(effectData + 0x1C, 0x0)
		local statOperator = IEex_ReadByte(effectData + 0x1F, 0x0)
		local statValue = IEex_GetActorStat(checkID, bonusStat)
		if ex_stat_check[match_stat] ~= nil then
			local specialReadSize = ex_stat_check[match_stat][2]
			if specialReadSize == 1 then
				statValue = IEex_ReadByte(checkData + ex_stat_check[match_stat][1], 0x0)
			elseif specialReadSize == 2 then
				statValue = IEex_ReadSignedWord(checkData + ex_stat_check[match_stat][1], 0x0)
			elseif specialReadSize == 4 then
				statValue = IEex_ReadDword(checkData + ex_stat_check[match_stat][1])
			end
			local specialBonusStat = ex_stat_check[match_stat][3]
			if specialBonusStat > 0 then
				if specialBonusStat >= 36 and specialBonusStat <= 42 then
					statValue = statValue + math.floor((IEex_GetActorStat(checkID, specialBonusStat) - 10) / 2)
				else
					statValue = statValue + IEex_GetActorStat(checkID, specialBonusStat)
				end
			end
		end
		if (statOperator == 0 and statValue >= match_value) or (statOperator == 1 and statValue == match_value) or (statOperator == 2 and bit32.band(statValue, match_value) == match_value) or (statOperator == 3 and bit32.band(statValue, match_value) > 0) then
			hasProtection = true
		end
	elseif protectionType == 5 then
		local match_value = IEex_ReadDword(effectData + 0x18)
		local match_offset = IEex_ReadWord(effectData + 0x1C, 0x0)
		local readSize = IEex_ReadByte(effectData + 0x1E, 0x0)
		local statOperator = IEex_ReadByte(effectData + 0x1F, 0x0)
		local statValue = 0
		if readSize == 2 then
			statValue = IEex_ReadSignedWord(checkData + match_offset, 0x0)
		elseif readSize == 4 then
			statValue = IEex_ReadDword(checkData + match_offset)
		elseif readSize > 4 then
			statValue = IEex_ReadLString(checkData + match_offset, readSize)
		else
			statValue = IEex_ReadByte(checkData + match_offset, 0x0)
		end
		if (statOperator == 0 and statValue >= match_value) or (statOperator == 1 and statValue == match_value) or (statOperator == 2 and bit32.band(statValue, match_value) == match_value) or (statOperator == 3 and bit32.band(statValue, match_value) > 0) then
			hasProtection = true
		end
	end
	local invert = (bit32.band(savingthrow, 0x100000) > 0)
	if (hasProtection == true and invert == false) or (hasProtection == false and invert == true) then
		if bit32.band(savingthrow, 0x10000) == 0 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 290,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
		else
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
		end
	end
end

function MEPSTACK(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	if targetID <= 0 or not IEex_IsSprite(sourceID, false) then return end
	local sourceSpell = IEex_ReadLString(effectData + 0x18, 8)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	if sourceSpell == "" then
		sourceSpell = parent_resource
	end
	IEex_IterateActorEffects(sourceID, function(eData)
		local thesourceID = IEex_ReadDword(eData + 0x110)
		local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
		if thesourceID == sourceID and theparent_resource == sourceSpell then
			IEex_WriteDword(eData + 0x28, 0)
		end
	end)
end

function MESPLSAV(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	if not IEex_IsSprite(sourceID, false) then 
		sourceID = 0
	end
	local sourceData = 0
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local savebonus = IEex_ReadDword(effectData + 0x40)
	local saveBonusStat = IEex_ReadByte(effectData + 0x44, 0x0)
	local bonusStatMultiplier = IEex_ReadByte(effectData + 0x45, 0x0)
	local bonusStatDivisor = IEex_ReadByte(effectData + 0x46, 0x0)
	local spellFocus = IEex_ReadByte(effectData + 0x47, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)

	local saveBonusStatValue = 0
	if sourceID > 0 then
		sourceData = IEex_GetActorShare(sourceID)
		if saveBonusStat > 0 then
			if saveBonusStat == 160 then
				local highestStatValue = IEex_GetActorStat(sourceID, 38)
				saveBonusStat = 38
				if IEex_GetActorStat(sourceID, 39) > highestStatValue then
					highestStatValue = IEex_GetActorStat(sourceID, 39)
					saveBonusStat = 39
				end
				if IEex_GetActorStat(sourceID, 42) > highestStatValue then
					highestStatValue = IEex_GetActorStat(sourceID, 42)
					saveBonusStat = 42
				end
				saveBonusStatValue = highestStatValue
			elseif ex_stat_check[saveBonusStat] ~= nil then
				local specialReadSize = ex_stat_check[saveBonusStat][2]
				if specialReadSize == 1 then
					saveBonusStatValue = IEex_ReadByte(sourceData + ex_stat_check[saveBonusStat][1], 0x0)
				elseif specialReadSize == 2 then
					saveBonusStatValue = IEex_ReadSignedWord(sourceData + ex_stat_check[saveBonusStat][1], 0x0)
				elseif specialReadSize == 4 then
					saveBonusStatValue = IEex_ReadDword(sourceData + ex_stat_check[saveBonusStat][1])
				end
				local specialBonusStat = ex_stat_check[saveBonusStat][3]
				if specialBonusStat > 0 then
					if specialBonusStat >= 36 and specialBonusStat <= 42 then
						saveBonusStatValue = saveBonusStatValue + math.floor((IEex_GetActorStat(sourceID, specialBonusStat) - 10) / 2)
					else
						saveBonusStatValue = saveBonusStatValue + IEex_GetActorStat(sourceID, specialBonusStat)
					end
				end
			else
				saveBonusStatValue = IEex_GetActorStat(sourceID, saveBonusStat)
			end
			if saveBonusStat >= 36 and saveBonusStat <= 42 then
				saveBonusStatValue = math.floor((saveBonusStatValue - 10) / 2)
			end
			if bonusStatMultiplier ~= 0 then
				saveBonusStatValue = saveBonusStatValue * bonusStatMultiplier
			end
			if bonusStatDivisor ~= 0 then
				saveBonusStatValue = math.floor(saveBonusStatValue / bonusStatDivisor)
			end
			if spellFocus > 0 then
				saveBonusStatValue = saveBonusStatValue + IEex_ReadByte(sourceData + spellFocus + 0x783, 0x0) * 2
			end
			savebonus = savebonus + saveBonusStatValue
		end
		if IEex_GetActorSpellState(sourceID, 236) then
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 236 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					if theresource == parent_resource then
						savebonus = savebonus + theparameter1
					end
				end
			end)
		end
	end
	if IEex_GetActorSpellState(targetID, 237) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 237 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource == parent_resource then
					savebonus = savebonus + theparameter1
				end
			end
		end)
	end
	local newSavingThrow = 0
	if bit32.band(savingthrow, 0x400) > 0 then
		newSavingThrow = bit32.bor(newSavingThrow, 0x4)
	end
	if bit32.band(savingthrow, 0x800) > 0 then
		newSavingThrow = bit32.bor(newSavingThrow, 0x8)
	end
	if bit32.band(savingthrow, 0x1000) > 0 then
		newSavingThrow = bit32.bor(newSavingThrow, 0x10)
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["savingthrow"] = newSavingThrow,
["savebonus"] = savebonus,
["casterlvl"] = casterlvl,
["resource"] = spellRES,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
end

function MEQUIVPA(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceData = IEex_GetActorShare(sourceID)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local savebonus = IEex_ReadDword(effectData + 0x40)
	local saveBonusStat = IEex_ReadByte(effectData + 0x44, 0x0)
	local saveBonusLevel = IEex_ReadByte(effectData + 0x45, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	savebonus = savebonus + math.floor(IEex_GetActorStat(sourceID, saveBonusLevel) / 2) + math.floor((IEex_GetActorStat(sourceID, saveBonusStat) - 10) / 2)
	if IEex_GetActorSpellState(sourceID, 236) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 236 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource == parent_resource then
					savebonus = savebonus + theparameter1
				end
			end
		end)
	end
	local newSavingThrow = 0
	if bit32.band(savingthrow, 0x400) > 0 then
		newSavingThrow = bit32.bor(newSavingThrow, 0x4)
	end
	if bit32.band(savingthrow, 0x800) > 0 then
		newSavingThrow = bit32.bor(newSavingThrow, 0x8)
	end
	if bit32.band(savingthrow, 0x1000) > 0 then
		newSavingThrow = bit32.bor(newSavingThrow, 0x10)
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["savingthrow"] = newSavingThrow,
["savebonus"] = savebonus,
["casterlvl"] = casterlvl,
["resource"] = spellRES,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
end

function MEKNOCKD(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceData = IEex_GetActorShare(sourceID)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local savebonus = IEex_ReadDword(effectData + 0x40)
	local saveBonusLevel = IEex_ReadByte(effectData + 0x45, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local knockdownFeatID = ex_feat_name_id["ME_KNOCKDOWN"]
	local knockdownFeatCount = 0
	if knockdownFeatID ~= nil then
		knockdownFeatCount = IEex_ReadByte(sourceData + 0x744 + knockdownFeatID, 0x0)
	end
	local newSavingThrow = 0
	local saveBonusStatBonus = IEex_GetActorStat(sourceID, 36)
	if IEex_GetActorStat(sourceID, 40) > saveBonusStatBonus then
		saveBonusStatBonus = IEex_GetActorStat(sourceID, 40)
		newSavingThrow = bit32.bor(newSavingThrow, 0x8)
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_915,
["parent_resource"] = "USKNKDOM",
["source_id"] = sourceID
})
	else
		newSavingThrow = bit32.bor(newSavingThrow, 0x4)
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_904,
["parent_resource"] = "USKNKDOM",
["source_id"] = sourceID
})
	end
	savebonus = savebonus + math.floor(IEex_GetActorStat(sourceID, 95) / 2) + math.floor((saveBonusStatBonus - 10) / 2)
	if IEex_GetActorSpellState(sourceID, 236) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 236 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource == parent_resource then
					savebonus = savebonus + theparameter1
				end
			end
		end)
	end
	if IEex_GetActorSpellState(targetID, 237) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 237 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource == parent_resource then
					savebonus = savebonus + theparameter1
				end
			end
		end)
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = 70,
["parameter1"] = -4,
["parameter2"] = 237,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
	if knockdownFeatCount < 2 then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 290,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 13,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 419,
["target"] = 2,
["timing"] = 0,
["duration"] = 4,
["parameter2"] = 1,
["savingthrow"] = newSavingThrow,
["savebonus"] = savebonus,
["parent_resource"] = "USKNKDO",
["source_target"] = targetID,
["source_id"] = sourceID
})
end

function MEFEINT(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceData = IEex_GetActorShare(sourceID)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local savebonus = IEex_ReadDword(effectData + 0x40)
	local saveBonusLevel = IEex_ReadByte(effectData + 0x45, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local feintFeatID = ex_feat_name_id["ME_FEINT"]
	local feintFeatCount = 0
	if feintFeatID ~= nil then
		feintFeatCount = IEex_ReadByte(sourceData + 0x744 + feintFeatID, 0x0)
	end
	savebonus = savebonus + IEex_ReadByte(sourceData + 0x7B6, 0x0) + math.floor((IEex_GetActorStat(sourceID, 38) - 10) / 2)
	if IEex_GetActorSpellState(sourceID, 236) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 236 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource == parent_resource then
					savebonus = savebonus + theparameter1
				end
			end
		end)
	end
	if IEex_GetActorSpellState(targetID, 237) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 237 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource == parent_resource then
					savebonus = savebonus + theparameter1
				end
			end
		end)
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = 70,
["parameter1"] = -4,
["parameter2"] = 237,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["savingthrow"] = 0x10,
["savebonus"] = savebonus,
["parent_resource"] = "USFEINTA",
["source_target"] = targetID,
["source_id"] = sourceID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 138,
["target"] = 2,
["timing"] = 0,
["parameter2"] = 4,
["savingthrow"] = 0x10,
["savebonus"] = savebonus,
["parent_resource"] = "USFEINTA",
["source_target"] = targetID,
["source_id"] = sourceID
})
--[[
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 233,
["target"] = 2,
["timing"] = 0,
["parameter2"] = 7,
["savingthrow"] = 0x10,
["savebonus"] = savebonus,
["parent_resource"] = "USFEINTA",
["source_target"] = targetID,
["source_id"] = sourceID
})
--]]
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 9,
["target"] = 2,
["timing"] = 0,
["duration"] = 4,
["parameter1"] = 0x14141400,
["parameter2"] = 0xF00FF,
["savingthrow"] = 0x10,
["savebonus"] = savebonus,
["parent_resource"] = "USFEINTA",
["source_target"] = targetID,
["source_id"] = sourceID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 0,
["duration"] = 4,
["parameter1"] = 0 - math.floor((IEex_GetActorStat(targetID, 40) - 10) / 2) - math.floor(IEex_ReadByte(sourceData + 0x7B6, 0x0) / 3),
["savingthrow"] = 0x10,
["savebonus"] = savebonus,
["parent_resource"] = "USFEINTA",
["source_target"] = targetID,
["source_id"] = sourceID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 54,
["target"] = 2,
["timing"] = 0,
["duration"] = 4,
["parameter1"] = 0 - math.floor(IEex_ReadByte(sourceData + 0x7B6, 0x0) / 3),
["savingthrow"] = 0x10,
["savebonus"] = savebonus,
["parent_resource"] = "USFEINTA",
["source_target"] = targetID,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USFREESP",
["source_id"] = sourceID
})
	if feintFeatCount >= 2 then
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 188,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["parameter2"] = 1,
["parent_resource"] = "USFREESP",
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["resource"] = "USFREESP",
["parent_resource"] = "USFREESP",
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["resource"] = "USFREESP",
["parent_resource"] = "USFREES2",
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["resource"] = "USFREES2",
["parent_resource"] = "USFREES2",
["source_id"] = sourceID
})
	end
end

function MEGRAPPL(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceData = IEex_GetActorShare(sourceID)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local savebonus = IEex_ReadDword(effectData + 0x40)
	local saveBonusLevel = IEex_ReadByte(effectData + 0x45, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local newSavingThrow = 0
	local saveBonusStatBonus = IEex_GetActorStat(sourceID, 36)
	local handsUsed = 0
	if IEex_GetActorSpellState(sourceID, 241) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 241 then
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
				if (thespecial >= 3 and thespecial <= 5) or thespecial == 85 then
					if bit32.band(thesavingthrow, 0x20000) == 0 then
						handsUsed = handsUsed + 1
					else
						handsUsed = handsUsed + 2
					end
				end
			end
		end)
	end
	if handsUsed >= 2 then
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_917,
["parent_resource"] = "USGRAPPM",
["source_id"] = sourceID
})
		return
	end
	IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_916,
["parent_resource"] = "USGRAPPM",
["source_id"] = sourceID
})
	if IEex_GetActorStat(sourceID, 40) > saveBonusStatBonus then
		saveBonusStatBonus = IEex_GetActorStat(sourceID, 40)
	end
	local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
	if IEex_CompareActorAllegiances(sourceID, targetID) < 1 or bit32.band(stateValue, 0x29) == 0 then
		newSavingThrow = bit32.bor(newSavingThrow, 0x8)
	end
	savebonus = savebonus + math.floor(IEex_GetActorStat(sourceID, 95) / 2) + math.floor((saveBonusStatBonus - 10) / 2)
	if IEex_GetActorSpellState(sourceID, 236) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 236 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource == parent_resource then
					savebonus = savebonus + theparameter1
				end
			end
		end)
	end
	if IEex_GetActorSpellState(targetID, 237) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 237 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource == parent_resource then
					savebonus = savebonus + theparameter1
				end
			end
		end)
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = 70,
["parameter1"] = -4,
["parameter2"] = 237,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 290,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 13,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 0,
["duration"] = 4,
["savingthrow"] = newSavingThrow,
["savebonus"] = savebonus,
["resource"] = "USGRAPPD",
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
end

function MEGRAPP2(effectData, creatureData)
	IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = 14,
["parameter1"] = 0,
["parameter2"] = 241,
["special"] = 85,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
end

function MEDISARM(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceData = IEex_GetActorShare(sourceID)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local savebonus = IEex_ReadDword(effectData + 0x40)
	local saveBonusLevel = IEex_ReadByte(effectData + 0x45, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local disarmFeatID = ex_feat_name_id["ME_DISARM"]
	local knockdownFeatCount = 0
	if knockdownFeatID ~= nil then
		knockdownFeatCount = IEex_ReadByte(sourceData + 0x744 + knockdownFeatID, 0x0)
	end
	local newSavingThrow = 0
	local saveBonusStatBonus = IEex_GetActorStat(sourceID, 36)
	if IEex_GetActorStat(sourceID, 40) > saveBonusStatBonus then
		saveBonusStatBonus = IEex_GetActorStat(sourceID, 40)
		newSavingThrow = bit32.bor(newSavingThrow, 0x8)
	else
		newSavingThrow = bit32.bor(newSavingThrow, 0x4)
	end
	savebonus = savebonus + math.floor(IEex_GetActorStat(sourceID, 95) / 2) + math.floor((saveBonusStatBonus - 10) / 2)
	if IEex_GetActorSpellState(sourceID, 236) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 236 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource == parent_resource then
					savebonus = savebonus + theparameter1
				end
			end
		end)
	end
	if IEex_GetActorSpellState(targetID, 237) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 237 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theresource == parent_resource then
					savebonus = savebonus + theparameter1
				end
			end
		end)
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = 70,
["parameter1"] = -4,
["parameter2"] = 237,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
	if knockdownFeatCount < 2 then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 290,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 13,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 419,
["target"] = 2,
["timing"] = 0,
["duration"] = 4,
["parameter2"] = 1,
["savingthrow"] = newSavingThrow,
["savebonus"] = savebonus,
["parent_resource"] = "USKNKDO",
["source_target"] = targetID,
["source_id"] = sourceID
})
end

function MESPLPRC(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local percentChance = IEex_ReadByte(effectData + 0x44, 0x0)
	local bonusStatMultiplier = IEex_ReadByte(effectData + 0x45, 0x0)
	local bonusStatDivisor = IEex_ReadByte(effectData + 0x46, 0x0)
	local bonusStat = IEex_ReadByte(effectData + 0x47, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)

	local bonusStatValue = 0
	if bonusStat > 0 then
		if ex_stat_check[bonusStat] ~= nil then
			local specialReadSize = ex_stat_check[bonusStat][2]
			local sourceData = IEex_GetActorShare(sourceID)
			if specialReadSize == 1 then
				bonusStatValue = IEex_ReadByte(sourceData + ex_stat_check[bonusStat][1], 0x0)
			elseif specialReadSize == 2 then
				bonusStatValue = IEex_ReadSignedWord(sourceData + ex_stat_check[bonusStat][1], 0x0)
			elseif specialReadSize == 4 then
				bonusStatValue = IEex_ReadDword(sourceData + ex_stat_check[bonusStat][1])
			end
			local specialBonusStat = ex_stat_check[bonusStat][3]
			if specialBonusStat > 0 then
				if specialBonusStat >= 36 and specialBonusStat <= 42 then
					bonusStatValue = bonusStatValue + math.floor((IEex_GetActorStat(sourceID, specialBonusStat) - 10) / 2)
				else
					bonusStatValue = bonusStatValue + IEex_GetActorStat(sourceID, specialBonusStat)
				end
			end
		else
			bonusStatValue = IEex_GetActorStat(sourceID, bonusStat)
		end
		if bonusStat >= 36 and bonusStat <= 42 then
			bonusStatValue = math.floor((bonusStatValue - 10) / 2)
		end
		if bonusStatMultiplier ~= 0 then
			bonusStatValue = bonusStatValue * bonusStatMultiplier
		end
		if bonusStatDivisor ~= 0 then
			bonusStatValue = math.floor(bonusStatValue / bonusStatDivisor)
		end
		percentChance = percentChance + bonusStatValue
	end
	if math.random(100) <= percentChance then
		IEex_ApplyEffectToActor(targetID, {
	["opcode"] = 402,
	["target"] = 2,
	["timing"] = 1,
	["casterlvl"] = casterlvl,
	["resource"] = spellRES,
	["parent_resource"] = parent_resource,
	["source_target"] = targetID,
	["source_id"] = sourceID
	})
	end
end

function MEPOISON(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	if parameter2 == 0 then
		parameter1 = 1
		parameter2 = 2
	elseif parameter2 == 3 and (parameter1 == 6 or parameter1 == 7) then
		parameter1 = 1
		parameter2 = 4
	end
	local duration = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	if casterClass == 2 or casterClass == 10 or casterClass == 11 then
		duration = math.floor(duration * IEex_GetActorStat(sourceID, 53) / 100)
	elseif casterClass == 3 or casterClass == 4 or casterClass == 7 or casterClass == 8 then
		duration = math.floor(duration * IEex_GetActorStat(sourceID, 54) / 100)
	end
	local damageMultiplier = 100
	IEex_IterateActorEffects(sourceID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		if theopcode == 73 and theparameter2 == 6 then
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			damageMultiplier = damageMultiplier + theparameter1
		end
	end)
	parameter1 = math.floor(parameter1 * damageMultiplier / 100)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 25,
["target"] = 2,
["timing"] = 0,
["duration"] = duration,
["parameter1"] = parameter1,
["parameter2"] = parameter2,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
end

function MEPOISOW(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadWord(effectData + 0x1C, 0x0)
	local duration = IEex_ReadWord(effectData + 0x1E, 0x0)
	local savebonus = IEex_ReadDword(effectData + 0x40)
	local special = IEex_ReadDword(effectData + 0x40)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local additionalDC = 0
	if bit32.band(special, 0x1) > 0 then
		additionalDC = additionalDC + IEex_GetActorStat(sourceID, 25)
	end
	if bit32.band(special, 0x2) > 0 then
		additionalDC = additionalDC + IEex_GetActorStat(sourceID, 25) * 2
	end
	if bit32.band(special, 0x4) > 0 then
		additionalDC = additionalDC + IEex_GetActorStat(sourceID, 40)
	end
	if bit32.band(special, 0x8) > 0 then
		additionalDC = additionalDC + IEex_GetActorStat(sourceID, 40) * 2
	end
	if bit32.band(special, 0x10) > 0 then
		additionalDC = additionalDC + IEex_GetActorStat(sourceID, 38)
	end
	if bit32.band(special, 0x20) > 0 then
		additionalDC = additionalDC + IEex_GetActorStat(sourceID, 38) * 2
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 25,
["target"] = 2,
["parameter1"] = parameter1,
["parameter2"] = parameter2,
["timing"] = 0,
["duration"] = duration,
["savingthrow"] = 0x4,
["savebonus"] = savebonus + additionalDC,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
end

function METELEFI(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local sourceX = IEex_ReadDword(effectData + 0x7C)
	local sourceY = IEex_ReadDword(effectData + 0x80)
	local targetX = IEex_ReadDword(effectData + 0x84)
	local targetY = IEex_ReadDword(effectData + 0x88)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local done = false
	local deltaX = 0
	local deltaY = 0
	while done == false do
		deltaX = (math.random(parameter1 + 1) - 1) * 2 - parameter1
		deltaY = (math.random(parameter1 + 1) - 1) * 2 - parameter1
		if (deltaX * deltaX + deltaY * deltaY <= parameter1 * parameter1) then
			done = true
		end
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 124,
["target"] = 2,
["timing"] = 1,
["source_x"] = targetX,
["source_y"] = targetY,
["target_x"] = targetX + deltaX,
["target_y"] = targetY + deltaY,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
end

function MESETZ(effectData, creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	IEex_WriteDword(creatureData + 0xE, parameter1 * -1)
end

function MEWINGBU(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if IEex_GetActorSpellState(targetID, 230) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local special = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local targetX = IEex_ReadDword(creatureData + 0x6)
	local targetY = IEex_ReadDword(creatureData + 0xA)
	local sourceX = targetX
	local sourceY = targetY
	if parameter2 == 2 or parameter2 == 4 then
		if sourceID > 0 then
			local sourceData = IEex_GetActorShare(sourceID)
			sourceX = IEex_ReadDword(sourceData + 0x6)
			sourceY = IEex_ReadDword(sourceData + 0xA)
		end
	elseif parameter2 == 1 or parameter2 == 3 then
		sourceX = IEex_ReadDword(effectData + 0x84)
		sourceY = IEex_ReadDword(effectData + 0x88)
	end
	local distX = targetX - sourceX
	local distY = targetY - sourceY
	local dist = math.floor((distX ^ 2 + distY ^ 2) ^ .5)
	local deltaX = 0
	local deltaY = 0
	if dist ~= 0 then
		deltaX = math.floor(parameter1 * distX / dist)
		deltaY = math.floor(parameter1 * distY / dist)
	end
	if parameter2 == 3 or parameter2 == 4 then
		if math.abs(deltaX) > math.abs(distX) then
			deltaX = distX
		end
		if math.abs(deltaY) > math.abs(distY) then
			deltaY = distY
		end
		deltaX = deltaX * -1
		deltaY = deltaY * -1
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 124,
["target"] = 2,
["timing"] = 1,
["source_x"] = targetX,
["source_y"] = targetY,
["target_x"] = targetX + deltaX,
["target_y"] = targetY + deltaY,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
end

function METELMOV(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local special = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local targetX = IEex_ReadDword(creatureData + 0x6)
	local targetY = IEex_ReadDword(creatureData + 0xA)
	local destinationX = IEex_ReadDword(creatureData + 0x556E)
	local destinationY = IEex_ReadDword(creatureData + 0x5572)
	if destinationX > 0 or destinationY > 0 then
		if special == 1 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 233,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 59,
["parent_resource"] = "USTELMOV",
["source_id"] = targetID
})
		end
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 124,
["target"] = 2,
["timing"] = 1,
["source_x"] = targetX,
["source_y"] = targetY,
["target_x"] = destinationX,
["target_y"] = destinationY,
["parent_resource"] = "USTELMOV",
["source_id"] = targetID
})
		if special == 1 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 233,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 60,
["parent_resource"] = "USTELMOV",
["source_id"] = targetID
})
		end
	end
end

function MEGHOSTW(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local special = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local targetX = IEex_ReadDword(creatureData + 0x6)
	local targetY = IEex_ReadDword(creatureData + 0xA)
	local destinationX = IEex_ReadDword(creatureData + 0x556E)
	local destinationY = IEex_ReadDword(creatureData + 0x5572)
	if destinationX <= 0 or destinationY <= 0 then
		destinationX = targetX
		destinationY = targetY
	end
	local distX = destinationX - targetX
	local distY = destinationY - targetY
	local dist = math.floor((distX ^ 2 + distY ^ 2) ^ .5)
	local deltaX = 0
	local deltaY = 0
	if dist ~= 0 then
		deltaX = math.floor(parameter1 * distX / dist)
		deltaY = math.floor(parameter1 * distY / dist)
	end
	if math.abs(deltaX) > math.abs(distX) then
		deltaX = distX
	end
	if math.abs(deltaY) > math.abs(distY) then
		deltaY = distY
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 124,
["target"] = 2,
["timing"] = 1,
["source_x"] = targetX,
["source_y"] = targetY,
["target_x"] = targetX + deltaX,
["target_y"] = targetY + deltaY,
["parent_resource"] = parent_resource,
["source_id"] = targetID
})
end

function MEHGTSET(effectData, creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local currentHeight = IEex_ReadDword(creatureData + 0xE)
	if parameter2 == 0 then
		IEex_WriteDword(creatureData + 0xE, currentHeight - parameter1)
	elseif parameter2 == 1 then
		IEex_WriteDword(creatureData + 0xE, currentHeight * parameter1)
	elseif parameter2 == 2 then
		IEex_WriteDword(creatureData + 0xE, math.floor(currentHeight + (currentHeight * parameter1 / 100)))
	end
end

--[[
function MEHGTMOD(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
--	if not IEex_IsSprite(sourceID) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local parameter3 = IEex_ReadDword(effectData + 0x5C)
	local parameter4 = IEex_ReadDword(effectData + 0x60)
	local special = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local spellRes = IEex_ReadLString(effectData + 0x18, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local duration = IEex_ReadDword(effectData + 0x24)
	local time_applied = IEex_ReadDword(effectData + 0x68)
	local firstIteration = false
	local roofHeight = 32767
	local targetHeight = 70

	if bit32.band(parameter4, 0x1) == 0 then
		parameter4 = bit32.bor(parameter4, 0x1)
		firstIteration = true
	end

	local animation = IEex_GetActorAnimation(targetID)
	local height = IEex_ReadSignedWord(creatureData + 0x618, 0x0) + IEex_GetActorStat(targetID, 641)
	local speed = IEex_ReadSignedWord(creatureData + 0x61A, 0x0) + IEex_GetActorStat(targetID, 642)
	local accel = IEex_ReadSignedWord(creatureData + 0x61C, 0x0) + IEex_GetActorStat(targetID, 643)
	local minHeight = IEex_GetActorStat(targetID, 647)
	local maxHeight = IEex_GetActorStat(targetID, 648)
	local centerHeight = IEex_GetActorStat(targetID, 649)

	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 321,
["target"] = 2,
["timing"] = 9,
["resource"] = "MEGOOVER",
["source_target"] = targetID,
["source_id"] = sourceID
})
	local theareatype = 0
	if IEex_ReadDword(IEex_GetActorShare(targetID) + 0x14) > 0 then
		theareatype = IEex_ReadWord(IEex_ReadDword(IEex_GetActorShare(targetID) + 0x14) + 0x40, 0x0)
	end
	if bit32.band(theareatype, 0x1) == 1 and bit32.band(theareatype, 0x800) == 0 and height >= 100 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 184,
["target"] = 2,
["timing"] = 10,
["duration"] = 15,
["parameter2"] = 1,
["parent_resource"] = "MEGOOVER",
["source_target"] = targetID,
["source_id"] = targetID
})
	end
	
	if (minHeight <= 0 or bit32.band(special, 0x1) == 0x1) and (height <= minHeight and speed <= 0 and accel <= 0) then 
		IEex_WriteWord(creatureData + 0x618, 0)
		IEex_WriteWord(creatureData + 0x61A, 0)
		IEex_WriteWord(creatureData + 0x61C, -1)
		if bit32.band(special, 0x2) == 0x2 then
			IEex_WriteDword(effectData + 0x110, 0x1)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 321,
["target"] = 2,
["timing"] = 9,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 407,
["target"] = 2,
["parameter1"] = casterlvl,
["parameter2"] = 2,
["timing"] = 10,
["duration"] = 1,
["resource"] = "MEUNSTUC",
["casterlvl"] = casterlvl,
["parent_resource"] = "MEUNSTUC",
["source_target"] = targetID,
["source_id"] = sourceID
})
		end
		if bit32.band(special, 0x8) == 0x8 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 146,
["target"] = 2,
["parameter1"] = 1,
["parameter2"] = 2,
["timing"] = 9,
["resource"] = parent_resource .. "E",
["source_target"] = targetID,
["source_id"] = sourceID
})
			IEex_WriteDword(creatureData + 0x10, 0)
		end
		if bit32.band(special, 0x2) == 0x2 or bit32.band(special, 0x8) == 0x8 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 325,
["target"] = 2,
["timing"] = 3,
["duration"] = 0,
["source_target"] = targetID,
["source_id"] = sourceID
})
			return 
		end
	end
	if minHeight < 0 then
		minHeight = 0
	end
	if maxHeight > (roofHeight - targetHeight) and not IEex_IsEthereal(targetID) then
		if targetHeight >= roofHeight then
			maxHeight = 1
		else
			maxHeight = (roofHeight - targetHeight)
		end
	end
	if maxHeight <= 0 or maxHeight > 10000 then
		maxHeight = 10000
	end
	if minHeight >= maxHeight then
		minHeight = maxHeight - 1
	end

	if height <= minHeight then
		height = minHeight
		if speed < 0 then
			speed = 0
		end
	elseif height >= maxHeight then
		height = maxHeight - 1
		if speed > 0 then
			speed = 0
		end
	end

	height = height + speed
	if height - speed < centerHeight then
		speed = speed - accel
	elseif height - speed > centerHeight then
		speed = speed + accel
	end

	if height <= minHeight then
		height = minHeight
		if speed < 0 then
			speed = 0
		end
	elseif height >= maxHeight then
		height = maxHeight - 1
		if speed > 0 then
			speed = 0
		end
	end
	if ((minHeight > 0 and bit32.band(special, 0x1) == 0x0) or ((height > minHeight) and (height < maxHeight - 1))) and not (IEex_IsFlying(targetID)) then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 176,
["target"] = 2,
["timing"] = 3,
["parameter2"] = 1,
["duration"] = 0,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
	end
	IEex_WriteWord(creatureData + 0x618, height)
	IEex_WriteWord(creatureData + 0x61A, speed)

	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 325,
["target"] = 2,
["timing"] = 3,
["duration"] = 0,
["source_target"] = targetID,
["source_id"] = sourceID
})
	local visualHeight = -math.ceil(height / 2)
	if visualHeight > 0 or visualHeight == -0 then
		visualHeight = 0
	end

	IEex_WriteDword(creatureData + 0x10, visualHeight)
	IEex_WriteDword(creatureData + 0x2D00, 0)
	IEex_WriteDword(effectData + 0x110, 0x1)
	if duration == time_applied and not firstIteration then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 6,
["duration"] = IEex_GetGameTick() + 1,
["parameter1"] = parameter1,
["parameter2"] = parameter2,
["parameter3"] = parameter3,
["parameter4"] = parameter4,
["resource"] = "MEHGTMOD",
["special"] = special,
["casterlvl"] = casterlvl,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
	else
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 3,
["parameter1"] = parameter1,
["parameter2"] = parameter2,
["parameter3"] = parameter3,
["parameter4"] = parameter4,
["resource"] = "MEHGTMOD",
["special"] = special,
["casterlvl"] = casterlvl,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
	end
end
--]]

function MENPCXP(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if sourceID <= 0 then return end
	local sourceData = IEex_GetActorShare(sourceID)
	local special = IEex_ReadDword(effectData + 0x44)
	local totalXP = 0
	local slotID = 0
	local slotCount = 0
	for i = 0, 5, 1 do
		slotID = IEex_GetActorIDCharacter(i)
		if slotID > 0 and slotID ~= sourceID then
			slotCount = slotCount + 1
			totalXP = totalXP + IEex_ReadDword(IEex_GetActorShare(slotID) + 0x5B4)
		end
	end
	if special == 0 and slotCount > 0 then
		IEex_WriteDword(sourceData + 0x5B4, math.floor(totalXP / slotCount))
	elseif special == 1 then
		IEex_WriteDword(sourceData + 0x5B4, math.floor(totalXP / 5))
	end
end

function MENOSUST(effectData, creatureData)
	EEex_WriteDword(creatureData + 0x5BC, bit32.band(IEex_ReadDword(creatureData + 0x5BC), 0xEFFFFFFF))
	EEex_WriteDword(creatureData + 0x920, bit32.band(IEex_ReadDword(creatureData + 0x920), 0xEFFFFFFF))
end

function MESUCREA(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if sourceID <= 0 then return end
	local sourceData = IEex_GetActorShare(sourceID)
	local targetID = IEex_GetActorIDShare(creatureData)
	local creatureName = IEex_ReadLString(sourceData + 0x598, 8)
	local isReload = false
	if creatureName == "" then
		isReload = true
	end
	local targetIsSummoner = false
	local targetIsFiendSummoner = false
	local hasFoundSummoner = IEex_ReadByte(sourceData + 0x730, 0x0)
	if hasFoundSummoner ~= 0 and (hasFoundSummoner == -1 or hasFoundSummoner == 255 or creatureName == "") then
		hasFoundSummoner = 0
		IEex_WriteByte(sourceData + 0x730, 0)
	end
	local summonNumber = IEex_ReadSignedWord(sourceData + 0x732, 0x0)
	if summonNumber == -1 then
		summonNumber = 0
		IEex_WriteWord(sourceData + 0x732, summonNumber)
	end
	if hasFoundSummoner == 0 and IEex_GetActorSpellState(targetID, 207) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local theparameter3 = IEex_ReadWord(eData + 0x60, 0x0)
			if targetIsSummoner == false and theopcode == 288 and theparameter2 == 207 and (theresource == creatureName or summonNumber > 0) and (isReload == false or theparameter3 == summonNumber) and (isReload or theparameter1 > 0) then
				IEex_WriteLString(sourceData + 0x598, theresource, 8)
				if theparameter1 > 0 then
					IEex_WriteDword(eData + 0x1C, theparameter1 - 1)
				end
				if theparameter3 > 0 then
					summonNumber = theparameter3
				elseif summonNumber == 0 then
					summonNumber = math.random(32767)
					IEex_WriteDword(eData + 0x60, summonNumber)
				end
				IEex_WriteWord(sourceData + 0x732, summonNumber)
				targetIsSummoner = true
				targetIsFiendSummoner = (bit32.band(IEex_ReadDword(eData + 0x40), 0x100000) > 0)
				IEex_WriteDword(sourceData + 0x72C, targetID)
				hasFoundSummoner = 1
				IEex_WriteByte(sourceData + 0x730, hasFoundSummoner)
			end
		end)
	end
	
	if targetIsSummoner and IEex_GetActorSpellState(targetID, 228) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 228 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				local applyOnReload = (bit32.band(thesavingthrow, 0x100000) > 0)
				local matchRace = IEex_ReadByte(eData + 0x48, 0x0)
				local spellRES = IEex_ReadLString(eData + 0x30, 8)
				if spellRES ~= "" and (matchRace == 0 or matchRace == IEex_ReadByte(sourceData + 0x26, 0x0)) and (isReload == false or applyOnReload == true) then
					local casterLevel = IEex_ReadDword(effectData + 0xC4)
					if casterLevel == 0 then
						casterLevel = 1
					end
					local newEffectTarget = sourceID
					local newEffectTargetX = IEex_ReadDword(effectData + 0x7C)
					local newEffectTargetY = IEex_ReadDword(effectData + 0x80)
					if (bit32.band(thesavingthrow, 0x200000) > 0) then
						newEffectTarget = targetID
						newEffectTargetX = IEex_ReadDword(effectData + 0x84)
						newEffectTargetY = IEex_ReadDword(effectData + 0x88)
					end
					local newEffectSource = targetID
					local newEffectSourceX = IEex_ReadDword(effectData + 0x84)
					local newEffectSourceY = IEex_ReadDword(effectData + 0x88)
					if (bit32.band(thesavingthrow, 0x400000) > 0) then
						newEffectSource = sourceID
						newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
						newEffectSourceY = IEex_ReadDword(effectData + 0x80)
					end
					if isReload == false then
						local usesLeft = IEex_ReadByte(eData + 0x49, 0x0)
						if usesLeft == 1 then
							local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
							IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = theparent_resource,
["source_id"] = sourceID
})
						elseif usesLeft > 0 then
							usesLeft = usesLeft - 1
							IEex_WriteByte(eData + 0x49, usesLeft)
						end
					end
					IEex_ApplyEffectToActor(newEffectTarget, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = spellRES,
["source_x"] = newEffectSourceX,
["source_y"] = newEffectSourceY,
["target_x"] = newEffectTargetX,
["target_y"] = newEffectTargetY,
["casterlvl"] = casterLevel,
["parent_resource"] = spellRES,
["source_target"] = newEffectTarget,
["source_id"] = newEffectSource
})
				end
			end
		end)
	end
	if targetIsFiendSummoner and isReload == false then
		local summonerIsEnemy = false
		local summonerAllegiance = IEex_ReadByte(creatureData + 0x24, 0x0)
		if summonerAllegiance == 255 or summonerAllegiance == 254 or summonerAllegiance == 200 then
			summonerIsEnemy = true
		end 
		local summonerHasProtection = IEex_GetActorSpellState(targetID, 1)

		if (summonerIsEnemy and summonerHasProtection) or (summonerIsEnemy == false and summonerHasProtection == false) then
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USPCFIEN",
["source_id"] = sourceID
})
		else
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 208,
["parent_resource"] = "USPCFIEN",
["source_id"] = sourceID
})
		end
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 434,
["target"] = 2,
["timing"] = 1,
["parameter1"] = 1,
["resource"] = "USEAFIEN",
["parent_resource"] = "USEAFIEN",
["source_id"] = sourceID
})
	end
end

function MEEAFIEN(effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if sourceID <= 0 then return end
	local summonerID = IEex_ReadDword(creatureData + 0x72C)
--	IEex_WriteWord(creatureData + 0x730, 0)
	if summonerID <= 0 then return end
	local summonerData = IEex_GetActorShare(summonerID)
	local summonerIsEnemy = false
	local summonerAllegiance = IEex_ReadByte(summonerData + 0x24, 0x0)
	if summonerAllegiance == 255 or summonerAllegiance == 254 or summonerAllegiance == 200 then
		summonerIsEnemy = true
	end 
	local summonerHasProtection = IEex_GetActorSpellState(summonerID, 1)

	if (summonerIsEnemy and summonerHasProtection) or (summonerIsEnemy == false and summonerHasProtection == false) then
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USPCFIEN",
["source_id"] = sourceID
})
	elseif IEex_GetActorSpellState(sourceID, 208) == false then
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 208,
["parent_resource"] = "USPCFIEN",
["source_id"] = sourceID
})
	end
end

opcodenames = {[3] = "berserk", [5] = "charm", [12] = "damage", [17] = "healing", [20] = "invisibility", [23] = "morale failure", [24] = "fear", [25] = "poison", [38] = "silence", [39] = "sleep", [40] = "slow", [45] = "stun", [58] = "dispelling", [60] = "spell failure", [74] = "blindness", [76] = "feeblemindedness", [78] = "disease", [80] = "deafness", [93] = "fatigue", [94] = "intoxication", [109] = "paralysis", [124] = "teleportation", [128] = "confusion", [134] = "petrification", [135] = "polymorphing", [154] = "entangle", [157] = "web", [158] = "grease", [175] = "hold", [176] = "movement penalties", [241] = "vampiric effects", [247] = "Beltyn's Burning Blood", [255] = "salamander auras", [256] = "umber hulk gaze", [279] = "Animal Rage", [281] = "Vitriolic Sphere", [294] = "harpy wail", [295] = "jackalwere gaze", [400] = "hopelessness", [404] = "nausea", [405] = "enfeeblement", [412] = "Domination", [414] = "Otiluke's Resilient Sphere", [416] = "wounding", [419] = "knockdown", [420] = "instant death", [424] = "Hold Undead", [425] = "Control Undead", [428] = "Dismissal/Banishment", [429] = "energy drain"}

classstatnames = {"Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Wizard"}
function MESTATPR(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	IEex_DisplayString(IEex_GetActorName(targetID))
	local levelsum = IEex_GetActorStat(targetID, 95)
	local classlevels = {}
	for i = 96, 106, 1 do
		local leveli = IEex_GetActorStat(targetID, i)
		if leveli > 0 then
			table.insert(classlevels, {classstatnames[i - 95], leveli})
		end
	end
	local levelstring = "Level " .. levelsum
	local numclasses = #classlevels
	if numclasses == 1 then
		levelstring = levelstring .. " " .. classlevels[1][1]
	elseif numclasses > 1 then
		levelstring = levelstring .. " ("
		for i = 1, numclasses, 1 do
			levelstring = levelstring .. classlevels[i][1] .. " " .. classlevels[i][2]
			if i < numclasses then
				levelstring = levelstring .. ", "
			end
		end
		levelstring = levelstring .. ")"
	end
	IEex_DisplayString(levelstring)
	
	IEex_DisplayString("Hit Points: " .. IEex_ReadSignedWord(creatureData + 0x5C0, 0x0) .. "/" .. IEex_GetActorStat(targetID, 1))
	local armorClassList = IEex_GetActorArmorClass(targetID)
	local ac = armorClassList[1]
	local acslashing = armorClassList[2]
	local acpiercing = armorClassList[3]
	local acbludgeoning = armorClassList[4]
	local acmissile = armorClassList[5]
	if acslashing == acpiercing and acslashing == acbludgeoning and acslashing == acmissile then
		IEex_DisplayString("Armor Class: " .. (ac + acslashing))
	else
		IEex_DisplayString("AC vs. slashing: " .. ac + acslashing .. "  AC vs. piercing: " .. ac + acpiercing .. "  AC vs. bludgeoning: " .. ac + acbludgeoning .. "  AC vs. missiles: " .. ac + acmissile)
	end
--[[
	if IEex_GetActorStat(targetID, 7) >= 0 then
		IEex_DisplayString("Attack Bonus: +" .. IEex_GetActorStat(targetID, 7))
	else
		IEex_DisplayString("Attack Bonus: " .. IEex_GetActorStat(targetID, 7))
	end
--]]
	IEex_DisplayString("Attacks per round: " .. IEex_GetActorStat(targetID, 8))
	IEex_DisplayString("Ability Scores: ")
	IEex_DisplayString("Strength: " .. IEex_GetActorStat(targetID, 36) .. "  Dexterity: " .. IEex_GetActorStat(targetID, 40) .. "  Constitution: " .. IEex_GetActorStat(targetID, 41) .. "  Intelligence: " .. IEex_GetActorStat(targetID, 38) .. "  Wisdom: " .. IEex_GetActorStat(targetID, 39) .. "  Charisma: " .. IEex_GetActorStat(targetID, 42))
	IEex_DisplayString(MEGetStat(targetID, "Slashing Resistance: ", 21, "%\n") .. MEGetStat(targetID, "Piercing Resistance: ", 23, "%\n") .. MEGetStat(targetID, "Bludgeoning Resistance: ", 22, "%\n") .. MEGetStat(targetID, "Missile Resistance: ", 24, "%\n") .. MEGetStat(targetID, "Fire Resistance: ", 14, "%\n") .. MEGetStat(targetID, "Magical Fire Resistance: ", 19, "%\n") .. MEGetStat(targetID, "Cold Resistance: ", 15, "%\n") .. MEGetStat(targetID, "Magical Cold Resistance: ", 20, "%\n") .. MEGetStat(targetID, "Electricity Resistance: ", 16, "%\n") .. MEGetStat(targetID, "Acid Resistance: ", 17, "%\n") .. MEGetStat(targetID, "Poison Resistance: ", 74, "%\n") .. MEGetStat(targetID, "Magic Damage Resistance: ", 73, "%\n") .. MEGetStat(targetID, "Spell Resistance: ", 18, "%\n"))
	local damageReduction = IEex_ReadByte(creatureData + 0x758, 0x0)
	local mirrorImagesRemaining = 0
	local stoneskinDamageRemaining = 0
	local sneakAttackProtection = false
	local immunities = {}
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		if theopcode == 101 or theopcode == 261 then
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			immunities[theparameter2] = true
		elseif theopcode == 119 then
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theparameter2 == 0 and theparameter1 > mirrorImagesRemaining then
				mirrorImagesRemaining = theparameter1
			elseif theparameter2 == 1 and mirrorImagesRemaining == 0 then
				mirrorImagesRemaining = 1
			end
		elseif theopcode == 218 then
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theparameter3 = IEex_ReadDword(eData + 0x60)
			if theparameter2 == 0 and theparameter3 > stoneskinDamageRemaining then
				stoneskinDamageRemaining = theparameter3
			end
		elseif theopcode == 287 then
			local thetiming = IEex_ReadDword(eData + 0x24)
			if thetiming ~= 4096 then
				sneakAttackProtection = true
			end
		elseif theopcode == 436 then
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theparameter2 > damageReduction then
				damageReduction = theparameter2
			end
		end
	end)
	if IEex_GetActorSpellState(targetID, 8) then
		immunities[420] = true
	end
	if IEex_GetActorSpellState(targetID, 29) then
		immunities[40] = true
		immunities[109] = true
		immunities[154] = true
		immunities[157] = true
		immunities[158] = true
		immunities[175] = true
		immunities[176] = true
	end
	if damageReduction <= 1 and IEex_GetActorStat(targetID, 101) > 19 then
		IEex_DisplayString("Damage Reduction: 20/+1")
	elseif damageReduction < 5 and IEex_GetActorSpellState(targetID, 18) then
		IEex_DisplayString("Damage Reduction: 10/+5")
	elseif damageReduction > 0 then
		IEex_DisplayString("Damage Reduction: " .. 5 * damageReduction .. "/+" .. damageReduction)
	end
	IEex_DisplayString("Saving Throws: ")
	IEex_DisplayString("Fortitude: " .. IEex_GetActorStat(targetID, 9) .. "  Reflex: " .. IEex_GetActorStat(targetID, 10) .. "  Will: " .. IEex_GetActorStat(targetID, 11))
	if #immunities > 0 then
		local immunitiesString = "Immunities: "
		local firstImmunity = true
		for key,value in pairs(immunities) do
			if opcodenames[key] ~= nil then
				if firstImmunity == false then
					immunitiesString = immunitiesString .. ", " .. opcodenames[key]
				else
					immunitiesString = immunitiesString .. opcodenames[key]
					firstImmunity = false
				end
			end
		end
		IEex_DisplayString(immunitiesString)
	end
	if IEex_GetActorStat(targetID, 97) > 0 or IEex_GetActorStat(targetID, 98) > 0 or IEex_GetActorStat(targetID, 99) > 0 or IEex_GetActorStat(targetID, 102) > 0 or IEex_GetActorStat(targetID, 103) > 0 or IEex_GetActorStat(targetID, 105) > 0 or IEex_GetActorStat(targetID, 106) > 0 then
		IEex_DisplayString("Concentration skill: " .. IEex_ReadByte(creatureData + 0x7B7, 0x0) + math.floor((IEex_GetActorStat(targetID, 41) - 10) / 2))
	end
	if mirrorImagesRemaining > 0 then
		IEex_DisplayString("Mirror images remaining: " .. mirrorImagesRemaining)
	end	
	if stoneskinDamageRemaining > 0 then
		IEex_DisplayString("Stoneskin damage remaining: " .. stoneskinDamageRemaining)
	end	
	IEex_DisplayString(MEGetStat(targetID, "Iron skins remaining: ", 88, "\n") .. MEGetStat(targetID, "Casting time reduced by ", 77, "\n"))
	if IEex_GetActorStat(targetID, 104) > 0 then
		IEex_DisplayString("Sneak attack damage: " .. math.floor((IEex_GetActorStat(targetID, 104) + 1) / 2))
	end	
	if IEex_GetActorStat(targetID, 79) > 0 then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " casts arcane spells as if " .. IEex_GetActorStat(targetID, 79) .. " levels higher")
	end	
	if IEex_GetActorStat(targetID, 53) ~= 100 then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " casts arcane spells with " .. IEex_GetActorStat(targetID, 53) .. "% the normal duration")
	end	
	if IEex_GetActorStat(targetID, 80) > 0 then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " casts divine spells as if " .. IEex_GetActorStat(targetID, 80) .. " levels higher")
	end	
	if IEex_GetActorStat(targetID, 54) ~= 100 then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " casts divine spells with " .. IEex_GetActorStat(targetID, 54) .. "% the normal duration")
	end	
	if IEex_GetActorStat(targetID, 76) ~= 0 then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " can cast more than one spell per round")
	end
	if IEex_GetActorStat(targetID, 81) ~= 0 then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " can see invisible creatures")
	end
	if bit32.band(IEex_ReadByte(creatureData + 0x89F, 0), 0x2) ~= 0 then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " is protected from critical hits")
	end
	if sneakAttackProtection then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " is protected from sneak attacks")
	end
	if IEex_GetActorSpellState(targetID, 64) then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " deals maximum damage with each hit")
	end
	if IEex_GetActorStat(targetID, 83) ~= 0 then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " cannot be reduced below " .. IEex_GetActorStat(targetID, 83) .. " HP")
	end
end

function MEGetStat(targetID, pre, stat, post)
	if IEex_GetActorStat(targetID, stat) == 0 then
		return ""
	else
		return pre .. IEex_GetActorStat(targetID, stat) .. post
	end
end

---------------
-- Lua Hooks --
---------------

-----------
-- Feats --
-----------

function IEex_IsFeatTaken(baseStats, featID)
	local mask = bit32.lshift(1, bit32.band(featID, 0x1F))
	local offset = bit32.rshift(featID, 5)
	--IEex_DisplayString(tostring(featID.." => "..IEex_ToHex(offset*4+0x1B8).." => "..IEex_ToHex(mask)))
	local featField = IEex_ReadDword(baseStats+offset*4+0x1B8)
	return IEex_IsMaskSet(featField, mask)
end

function IEex_GetFeatCount(baseStats, featID)
	-- Abuse function's simple indexing to treat in terms of baseStats and not CGameSprite
	return IEex_Call(0x762E20, {featID}, baseStats - 0x5A4, 0x0)
end

function IEex_FeatHook(share, oldBaseStats, oldDerivedStats)

	--IEex_MessageBox("share: "..IEex_ToHex(share))
	--IEex_MessageBox("oldBaseStats: "..IEex_ToHex(oldBaseStats))
	--IEex_MessageBox("oldDerivedStats: "..IEex_ToHex(oldDerivedStats))

	local newBaseStats = share + 0x5A4
	for featID = 0, IEex_NEW_FEATS_MAXID, 1 do
		if IEex_IsFeatTaken(newBaseStats, featID) then
			local oldFeatCount = IEex_GetFeatCount(oldBaseStats, featID)
			local newFeatCount = IEex_GetFeatCount(newBaseStats, featID)
			if oldFeatCount ~= newFeatCount then
				for featLevel = oldFeatCount + 1, newFeatCount, 1 do
					IEex_ApplyResref("FE_"..featID.."_"..featLevel, IEex_GetActorIDShare(share))
					--IEex_DisplayString("You took featID "..featID.." with level "..featLevel)
				end
			end
		end
	end

end

--------------------
-- Initialization --
--------------------

---------------
-- CONSTANTS --
---------------

IEex_NEW_FEATS_MAXID = nil
IEex_NEW_FEATS_SIZE  = nil

---------------
-- Functions --
---------------

function IEex_LoadResources()

	IEex_Loaded2DAs = {}

	local feats2DA = IEex_2DADemand("B3FEATS")
	
	local idColumn = IEex_2DAFindColumn(feats2DA, "ID")
	local maxRowIndex = IEex_ReadWord(feats2DA + 0x20, 1) - 1

	local previousID = 74
	for rowIndex = 0, maxRowIndex, 1 do
		local myID = tonumber(IEex_2DAGetAt(feats2DA, idColumn, rowIndex))
		if (previousID + 1) ~= myID then
			IEex_TracebackMessage("IEex CRITICAL ERROR - B3FEATS.2DA contains hole at ID = "..(previousID + 1).."; Fix this!")
		end
		previousID = myID
	end

	IEex_NEW_FEATS_MAXID = previousID
	IEex_NEW_FEATS_SIZE = IEex_NEW_FEATS_MAXID + 1

	IEex_WriteDelayedPatches()

end

function IEex_WriteDelayedPatches()

	IEex_DisableCodeProtection()

	--------------------
	-- FeatList Hooks --
	--------------------

	IEex_FeatPanelStringHook = function(featID)
		local foundMax = tonumber(IEex_2DAGetAtRelated("B3FEATS", "ID", "MAX", function(id)
			return tonumber(id) == featID
		end))
		return foundMax > 1
	end

	IEex_FeatPipsHook = function(featID)
		local foundValue = tonumber(IEex_2DAGetAtRelated("B3FEATS", "ID", "MAX", function(id)
			return tonumber(id) == featID
		end))
		return foundValue
	end

	IEex_GetFeatCountHook = function(sprite, featID)
		return IEex_ReadByte(sprite + 0x78F + (featID - 0x4B), 0)
	end

	IEex_SetFeatCountHook = function(sprite, featID, count)
		IEex_WriteByte(sprite + 0x78F + (featID - 0x4B), count)
	end

	IEex_FeatIncrementableHook = function (sprite, featID)
		local featCount = IEex_ReadByte(sprite + 0x78F + (featID - 0x4B), 0)
		local foundMax = tonumber(IEex_2DAGetAtRelated("B3FEATS", "ID", "MAX", function(id)
			return tonumber(id) == featID
		end))
		return featCount < foundMax
	end

	IEex_FeatTakeableHook = function(sprite, featID)
		local foundFunc = IEex_2DAGetAtRelated("B3FEATS", "ID", "PREREQUISITE_FUNCTION", function(id)
			return tonumber(id) == featID
		end)
		return _G[foundFunc](IEex_GetActorIDShare(sprite), featID)
	end

	------------------------
	-- FeatList Hooks ASM --
	------------------------

	--------------------------------
	-- FIX CHARGEN ARRAY OVERFLOW --
	-------------------------------- 

	local chargenBeforeFeatCounts = IEex_Malloc(IEex_NEW_FEATS_SIZE * 0x4)
	for i = 0, IEex_NEW_FEATS_MAXID, 1 do
		IEex_WriteDword(chargenBeforeFeatCounts + i * 4, 0x0)
	end

	------------------------
	-- Chargen_Init_Feats --
	------------------------

	IEex_WriteAssembly(0x60CD6C, {"!mov_[edx*4+dword]_eax", {chargenBeforeFeatCounts, 4}})

	-----------------------------
	-- Chargen_Update_FeatList --
	-----------------------------

	IEex_WriteAssembly(0x60E689, {"!cmp_[ecx*4+dword]_eax", {chargenBeforeFeatCounts, 4}})

	-------------------------------
	-- Chargen_OnFeatCountChange --
	-------------------------------

	IEex_WriteAssembly(0x623447, {"!cmp_[esi*4+dword]_eax", {chargenBeforeFeatCounts, 4}})

	------------------------------
	-- CGameSprite_SetFeatCount --
	------------------------------

	IEex_WriteByte(0x762897 + 2, IEex_NEW_FEATS_SIZE)

	local featGetCountHookAddress = 0x76290B
	local featGetCountHook = IEex_WriteAssemblyAuto({[[

		!jbe_dword ]], {featGetCountHookAddress + 0x6, 4, 4}, [[
		!cmp_eax_byte 47
		!jle_dword :762D5E

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_SetFeatCountHook"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; sprite ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; featID ;
		!push_edi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; count ;
		!push_ebx
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 03
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18

		!pop_all_registers_iwd2
		!jmp_dword :762D5E

	]]})
	IEex_WriteAssembly(featGetCountHookAddress, {"!jmp_dword", {featGetCountHook, 4, 4}, "!nop"})
	
	---------------------------
	-- FeatList_GetFeatCount --
	---------------------------

	IEex_WriteByte(0x762E26 + 2, IEex_NEW_FEATS_SIZE)

	local featGetCountHookAddress = 0x762E6A
	local featGetCountHook = IEex_WriteAssemblyAuto({[[

		!jbe_dword ]], {featGetCountHookAddress + 0x6, 4, 4}, [[
		!cmp_eax_byte 47
		!jle_dword :762FD1

		!push_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_GetFeatCountHook"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; sprite ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; featID ;
		!push_edi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 02
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18

		!push_byte 00
		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_tonumberx
		!add_esp_byte 0C

		!call >__ftol2_sse
		!push_eax

		!push_byte FE
		!push_dword *_g_lua
		!call >_lua_settop
		!add_esp_byte 08

		!pop_eax

		!pop_registers_iwd2
		!pop_edi
		!pop_esi
		!ret_word 04 00

	]]})
	IEex_WriteAssembly(featGetCountHookAddress, {"!jmp_dword", {featGetCountHook, 4, 4}, "!nop"})

	--------------------------
	-- Feat_Get_Number_Pips --
	--------------------------

	IEex_WriteByte(0x7630A5 + 2, IEex_NEW_FEATS_SIZE)

	local featNumberPipsHookAddress = 0x7630C6
	local featNumberPipsHook = IEex_WriteAssemblyAuto({[[

		!cmp_eax_byte 42
		!pop_esi
		!jbe_dword ]], {featNumberPipsHookAddress + 0x6, 4, 4}, [[

		!cmp_eax_byte 47
		!jle_dword :7630F3

		!push_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_FeatPipsHook"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; featID ;
		!mov_eax_[esp+byte] 1C
		!push_eax
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18

		!push_byte 00
		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_tonumberx
		!add_esp_byte 0C

		!call >__ftol2_sse
		!push_eax

		!push_byte FE
		!push_dword *_g_lua
		!call >_lua_settop
		!add_esp_byte 08

		!pop_eax

		!pop_registers_iwd2
		!ret_word 04 00

	]]})
	IEex_WriteAssembly(featNumberPipsHookAddress, {"!jmp_dword", {featNumberPipsHook, 4, 4}, "!nop"})

	-------------------
	-- Feat_Takeable --
	-------------------

	IEex_WriteByte(0x763206 + 2, IEex_NEW_FEATS_SIZE)

	local featTakeableHookAddress = 0x763270
	local featTakeableHook = IEex_WriteAssemblyAuto({[[

		!cmp_ebp_byte 4A
		!jbe_dword ]], {featTakeableHookAddress + 0x6, 4, 4}, [[

		!push_eax
		!push_ecx
		!push_edx
		!push_ebp
		!push_esi
		!push_edi

		!push_dword ]], {IEex_WriteStringAuto("IEex_FeatTakeableHook"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; sprite ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; featID ;
		!push_ebp
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 02
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18

		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_toboolean
		!add_esp_byte 08

		!push_eax

		!push_byte FE
		!push_dword *_g_lua
		!call >_lua_settop
		!add_esp_byte 08

		!pop_ebx

		!pop_edi
		!pop_esi
		!pop_ebp
		!pop_edx
		!pop_ecx
		!pop_eax
		!jmp_dword :7638FD

	]]})
	IEex_WriteAssembly(featTakeableHookAddress, {"!jmp_dword", {featTakeableHook, 4, 4}, "!nop"})

	------------------------
	-- Feat_Incrementable --
	------------------------

	IEex_WriteByte(0x763A46 + 2, IEex_NEW_FEATS_SIZE)

	local featIncrementableHookAddress = 0x763A6C
	local featIncrementableHook = IEex_WriteAssemblyAuto({[[

		!jbe_dword ]], {featIncrementableHookAddress + 0x6, 4, 4}, [[
		!cmp_eax_byte 47
		!jle_dword :763BB7

		!push_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_FeatIncrementableHook"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; sprite ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; featID ;
		!push_edi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 02
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18

		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_toboolean
		!add_esp_byte 08

		!push_eax

		!push_byte FE
		!push_dword *_g_lua
		!call >_lua_settop
		!add_esp_byte 08

		!pop_eax

		!pop_registers_iwd2

		!test_eax_eax
		!jz_dword :763A9D
		!jmp_dword :763BDD

	]]})
	IEex_WriteAssembly(featIncrementableHookAddress, {"!jmp_dword", {featIncrementableHook, 4, 4}, "!nop"})

	----------------------------------
	-- Feat_Update_Panel_With_Taken --
	----------------------------------

	IEex_WriteByte(0x765CE8 + 2, IEex_NEW_FEATS_SIZE)
	IEex_WriteByte(0x765DC8 + 2, IEex_NEW_FEATS_SIZE)

	local featPanelStringHookAddress = 0x765D27
	local featPanelStringHook = IEex_WriteAssemblyAuto({[[

		!cmp_eax_byte 42
		!jbe_dword ]], {featPanelStringHookAddress + 0x5, 4, 4}, [[
		!cmp_eax_byte 47
		!jle_dword :765D7E

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_FeatPanelStringHook"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; featID ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18

		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_toboolean
		!add_esp_byte 08

		!push_eax

		!push_byte FE
		!push_dword *_g_lua
		!call >_lua_settop
		!add_esp_byte 08

		!pop_eax
		!test_eax_eax

		!pop_all_registers_iwd2

		!jz_dword :765D7E
		!jmp_dword :765D3B

	]]})
	IEex_WriteAssembly(featPanelStringHookAddress, {"!jmp_dword", {featPanelStringHook, 4, 4}})

	-------------------------------------
	-- Has_Feat_And_Meets_Requirements --
	-------------------------------------

	IEex_WriteByte(0x763156 + 2, IEex_NEW_FEATS_SIZE)

	----------------------------
	-- Level_Up_Accept_Skills --
	----------------------------

	IEex_WriteByte(0x5E1251 + 2, IEex_NEW_FEATS_SIZE)

	---------------
	-- nNumItems --
	---------------

	IEex_WriteWord(0x84EA66, IEex_NEW_FEATS_SIZE)



	IEex_EnableCodeProtection()

end

----------------------------------
-- IEex_DefineAssemblyFunctions --
----------------------------------

function IEex_DefineAssemblyFunctions()

	-- push resref
	-- push share
	IEex_WriteAssemblyAuto({[[

		$IEex_ApplyResref

		!build_stack_frame
		!sub_esp_byte 0C
		!push_registers

		!push_byte 01 ; level ;
		!push_[ebp+byte] 0C ; resref ;
		!push_[ebp+byte] 08 ; share ;
		!lea_ecx_[ebp+byte] F4
		!push_ecx
		!call :586220 ; Get_Resref_Effects ;
		!add_esp_byte 10

		!mov_ebx_[ebp+byte] F8 ; list start ;
		!mov_edi_[ebx] ; head ;

		!cmp_edi_ebx
		!je_dword >free_everything

		@apply_loop
		!push_byte 01 ; immediateResolve ;
		!push_byte 00 ; noSave ;
		!push_byte 01 ; Timed list ;
		!push_[edi+byte] 08 ; Effect ;
		!mov_ecx_[ebp+byte] 08
		!mov_eax_[ecx]
		!call_[eax+dword] #78 ; Add Effect ;

		!mov_edi_[edi]
		!cmp_edi_ebx
		!jne_dword >apply_loop

		@free_everything
		!mov_edi_[ebx] ; head ;
		!cmp_edi_ebx
		!je_dword >free_start

		@free_everything_loop
		!mov_eax_edi
		!mov_edx_[eax+byte] 04
		!mov_ecx_[eax]
		!mov_edi_[edi]
		!mov_[edx]_ecx
		!mov_edx_[eax]
		!mov_ecx_[eax+byte] 04
		!push_eax
		!mov_[edx+byte]_ecx 04
		!call :7FC984 ; free ;
		!add_esp_byte 04
		!dec_[ebp+byte] FC
		!cmp_edi_ebx
		!jne_dword >free_everything_loop

		@free_start
		!push_ebx
		!call :7FC984 ; free ;
		!add_esp_byte 04

		!restore_stack_frame
		!ret_word 08 00

	]]})

end

-----------------------
-- IEex_WritePatches --
-----------------------

function IEex_WritePatches()

	IEex_DisableCodeProtection()

	-------------------------
	-- Resources Load Hook --
	-------------------------

	local loadResourcesHookAddress = 0x59CC58
	local loadResourcesHook = IEex_WriteAssemblyAuto({[[

		!call :53CB60
		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_LoadResources"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18

		!pop_all_registers_iwd2
		!jmp_dword ]], {loadResourcesHookAddress + 0x5, 4, 4},

	})
	IEex_WriteAssembly(loadResourcesHookAddress, {"!jmp_dword", {loadResourcesHook, 4, 4}})

	---------------------------------------------------------
	-- Fix non-player animations crashing when leveling up --
	---------------------------------------------------------

	local animationChangeCall = 0x5E676C
	local animationChangeHook = IEex_WriteAssemblyAuto({[[

		!push_ecx

		!mov_ecx_ebp
		!call :45B730
		!mov_ecx_eax
		!call :45B690
		!movzx_eax_ax

		!pop_ecx

		!cmp_eax_dword #6000
		!jb_dword :5E67F5

		!cmp_eax_dword #6313
		!ja_dword :5E67F5

		!call :447AD0
		!jmp_dword ]], {animationChangeCall + 0x5, 4, 4}, [[

	]]})
	IEex_WriteAssembly(animationChangeCall, {"!jmp_dword", {animationChangeHook, 4, 4}})

	---------------------------------------------------------
	-- Debug Console should execute Lua if not using cheat --
	---------------------------------------------------------

	local niceTryCheaterCall = 0x58398E
	local niceTryCheaterHook = IEex_WriteAssemblyAuto({[[

		!add_esp_byte 08
		!push_ebp
		!push_dword *_g_lua
		; TODO: Cache Lua chunks ;
		!call >_luaL_loadstring
		!add_esp_byte 08

		!test_eax_eax
		!jnz_dword >error

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18

		!test_eax_eax
		!jnz_dword >error
		!jmp_dword ]], {niceTryCheaterCall + 0x5, 4, 4}, [[

		@error
		!push_byte 00
		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_tolstring
		!add_esp_byte 0C

		!push_eax
		!push_byte FE
		!push_dword *_g_lua
		!call >_lua_settop
		!add_esp_byte 08
		!pop_eax

		!push_ecx
		!mov_ecx_esp
		!push_eax
		!call :7FCC88
		!call :4EC1C0

		!jmp_dword ]], {niceTryCheaterCall + 0x5, 4, 4}, [[

	]]})
	IEex_WriteAssembly(niceTryCheaterCall, {"!jmp_dword", {niceTryCheaterHook, 4, 4}})
	IEex_WriteAssembly(0x583996, {"!nop !nop !nop !nop !nop"})

	----------------------------------------------
	-- Feats should apply our spells when taken --
	----------------------------------------------

	local featHookName = "IEex_FeatHook"
	local featHookNameAddress = IEex_Malloc(#featHookName + 1)
	IEex_WriteString(featHookNameAddress, featHookName)

	local hasMetStunningAttackRequirements = 0x71E4D2
	local featsHook = IEex_WriteAssemblyAuto({[[

		!push_registers

		!push_dword ]], {featHookNameAddress, 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; Current share ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; Old base stats ;
		!push_edi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; Old derived stats ;
		!push_[esp+byte] 40
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 03
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18

		!pop_registers

		!call :763150
		!jmp_dword ]], {hasMetStunningAttackRequirements + 0x5, 4, 4}, [[

	]]})
	IEex_WriteAssembly(hasMetStunningAttackRequirements, {"!jmp_dword", {featsHook, 4, 4}})

	-------------------------------------------------------------------------
	-- Unequipping item should properly trigger Opcode OnRemove() function --
	-------------------------------------------------------------------------

	local unequipSpriteGlobal = IEex_Malloc(0x4)
	IEex_WriteDword(unequipSpriteGlobal, 0x0)

	local fixUnequipOnRemove1 = 0x4E8F04
	local fixUnequipOnRemove1Hook = IEex_WriteAssemblyAuto({[[
		!mov_[dword]_edi ]], {unequipSpriteGlobal, 4}, [[
		!call :4C0830 ; CGameEffectList_RemoveMatchingEffect() ;
		!mov_[dword]_dword ]], {unequipSpriteGlobal, 4}, [[ #0
		!jmp_dword ]], {fixUnequipOnRemove1 + 0x5, 4, 4}, [[
	]]})
	IEex_WriteAssembly(fixUnequipOnRemove1, {"!jmp_dword", {fixUnequipOnRemove1Hook, 4, 4}})

	local fixUnequipOnRemove2 = 0x4C0870
	local fixUnequipOnRemove2Hook = IEex_WriteAssemblyAuto({[[

		!call :7FB3E3 ; CPtrList::RemoveAt() ;

		!cmp_[dword]_byte ]], {unequipSpriteGlobal, 4}, [[ 00
		!je_dword ]], {fixUnequipOnRemove2 + 0x5, 4, 4}, [[

		!push_all_registers_iwd2
		!push_[dword] ]], {unequipSpriteGlobal, 4}, [[
		!mov_ecx_edi
		!mov_eax_[ecx]
		!call_[eax+byte] 24
		!pop_all_registers_iwd2
		!jmp_dword ]], {fixUnequipOnRemove2 + 0x5, 4, 4}, [[

	]]})
	IEex_WriteAssembly(fixUnequipOnRemove2, {"!jmp_dword", {fixUnequipOnRemove2Hook, 4, 4}})

	-------------------------------------------------------------
	-- Spell writability is now determined by scroll usability --
	-------------------------------------------------------------

	local writableCheckAddress = 0x62995B
	local writableCheckHook = IEex_WriteAssemblyAuto({[[
		!add_esp_byte 04
		!mov_eax_[esp+byte] 14
		!push_eax
		!push_edx
		!call :5BA080
		!jmp_dword ]], {writableCheckAddress + 0x5, 4, 4}, [[
	]]})
	IEex_WriteAssembly(writableCheckAddress, {"!jmp_dword", {writableCheckHook, 4, 4}})


	IEex_EnableCodeProtection()

end

if not IEex_AlreadyInitialized then

	IEex_AlreadyInitialized = true

	IEex_DefineAssemblyFunctions()
	IEex_WritePatches()
	dofile("override/IEex_Opc.lua")

end
