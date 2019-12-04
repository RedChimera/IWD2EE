
function IEex_Reload()
	dofile("override/IEex_IWD2.lua")
end

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
		IEex_Error("IEex_ApplyResref() passed invalid actorID")
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

function IEex_IterateActorEffects(actorID, func)
	local esi = IEex_ReadDword(IEex_GetActorShare(actorID) + 0x552A)
	while esi ~= 0x0 do
		local edi = IEex_ReadDword(esi + 0x8) - 0x4
		func(edi)
		esi = IEex_ReadDword(esi)
	end
	esi = IEex_ReadDword(IEex_GetActorShare(actorID) + 0x54FE)
	while esi ~= 0x0 do
		local edi = IEex_ReadDword(esi + 0x8) - 0x4
		func(edi)
		esi = IEex_ReadDword(esi)
	end
end

----------------
-- Game State --
----------------

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
			elseif IEex_ReadWord(creatureData + i, 0x0) == search_word then
				IEex_DisplayString("Match found for " .. search_word .. " at offset " .. i .. " (2 bytes)")
			elseif IEex_ReadByte(creatureData + i, 0x0) == search_byte then
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

function MESNEAKS(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		if theopcode == 287 then
		end
	end)
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
	local targetID = IEex_GetActorIDShare(creatureData)
	local statValue = 0
	local stat = IEex_ReadDword(effectData + 0x18)
	local index = IEex_ReadWord(effectData + 0x1C, 0)
	local readType = IEex_ReadWord(effectData + 0x1E, 0)
	if readType == 0 then
		statValue = IEex_GetActorStat(targetID, stat)
	elseif readType == 1 then
		statValue = IEex_ReadByte(creatureData + stat, 0)
	elseif readType == 2 then
		statValue = IEex_ReadSignedWord(creatureData + stat, 0)
	elseif readType == 4 then
		statValue = IEex_ReadDword(creatureData + stat)
	end
	statValue = statValue + IEex_ReadDword(effectData + 0x44)
	applyStatSpell(targetID, index, statValue)
end

function MEHOLYMI(effectData, creatureData)
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
	local targetID = IEex_GetActorIDShare(creatureData)
	local stat = IEex_ReadWord(effectData + 0x44, 0x0)
	local statValue = IEex_GetActorStat(targetID, stat)
	local dc = IEex_ReadWord(effectData + 0x46, 0x0)
	local roll = math.random(20)
	local invert = (bit32.band(IEex_ReadDword(effectData + 0x34), 0x100000) > 0)
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
	local targetID = IEex_GetActorIDShare(creatureData)
	local state = IEex_ReadDword(effectData + 0x44)
	local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
	local invert = (bit32.band(IEex_ReadDword(effectData + 0x34), 0x100000) > 0)
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
	local targetID = IEex_GetActorIDShare(creatureData)
	local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
	local invert = (bit32.band(IEex_ReadDword(effectData + 0x34), 0x100000) > 0)
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
	local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
	local invert = (bit32.band(IEex_ReadDword(effectData + 0x34), 0x100000) > 0)
	if bit32.band(stateValue, 0xFC0) > 0 then
		if invert == false then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, sourceID)
			end
		end
	else
		if invert == true then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if spellRES ~= "" then
				IEex_ApplyResref(spellRES, sourceID)
			end
		end
	end
end

function MESPLSTS(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local spellState1 = IEex_ReadByte(effectData + 0x44, 0x0)
	local spellState2 = IEex_ReadByte(effectData + 0x45, 0x0)
	local spellState3 = IEex_ReadByte(effectData + 0x46, 0x0)
	local spellState4 = IEex_ReadByte(effectData + 0x47, 0x0)
	local invert = (bit32.band(IEex_ReadDword(effectData + 0x34), 0x100000) > 0)
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

function MESPELL(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	if spellRES ~= "" then
		IEex_ApplyResref(spellRES, targetID)
	end
end

onhitspells = {
[1] = "USOHTEST",
[5020] = "USCLEA20",
[5050] = "USCLEA50",
[5100] = "USCLEA00",
}

function MEONHIT(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local headerType = IEex_ReadDword(effectData + 0x44)
	if IEex_GetActorSpellState(sourceID, 225) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 225 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local matchHeader = IEex_ReadDword(eData + 0x48)
				local spellRES = onhitspells[theparameter1]
				if spellRES ~= nil and (matchHeader == 0 or matchHeader == headerType) then
					local targetSource = (bit32.band(IEex_ReadDword(eData + 0x38), 0x200000) > 0)
					local fromTarget = (bit32.band(IEex_ReadDword(eData + 0x38), 0x400000) > 0)
					if targetSource == true then
						IEex_ApplyResref(spellRES, sourceID)
					else
						IEex_ApplyResref(spellRES, targetID)
					end
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
				local matchHeader = IEex_ReadDword(eData + 0x48)
				local spellRES = onhitspells[theparameter1]
				if spellRES ~= nil and (matchHeader == 0 or matchHeader == headerType) then
					local targetSource = (bit32.band(IEex_ReadDword(eData + 0x38), 0x200000) > 0)
					local fromTarget = (bit32.band(IEex_ReadDword(eData + 0x38), 0x400000) > 0)
					if targetSource == true then
						IEex_ApplyResref(spellRES, sourceID)
					else
						IEex_ApplyResref(spellRES, targetID)
					end
				end
			end
		end)
	end
end

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
--[[
	local ac = IEex_GetActorStat(targetID, 2)
	local acslashing = IEex_GetActorStat(targetID, 6)
	local acpiercing = IEex_GetActorStat(targetID, 5)
	local acbludgeoning = IEex_GetActorStat(targetID, 3)
	local acmissile = IEex_GetActorStat(targetID, 4)
	if acslashing == acpiercing and acslashing == acbludgeoning and acslashing == acmissile then
		IEex_DisplayString("Armor Class: " .. (ac + acslashing))
	else
		IEex_DisplayString("AC vs. slashing: " .. ac + acslashing .. "  AC vs. piercing: " .. ac + acpiercing .. "  AC vs. bludgeoning: " .. ac + acbludgeoning .. "  AC vs. missiles: " .. ac + acmissile)
	end
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
	IEex_DisplayString("Saving Throws: ")
	IEex_DisplayString("Fortitude: " .. IEex_GetActorStat(targetID, 9) .. "  Reflex: " .. IEex_GetActorStat(targetID, 10) .. "  Will: " .. IEex_GetActorStat(targetID, 11))
	IEex_DisplayString(MEGetStat(targetID, "Stoneskins remaining: ", 88, "\n") .. MEGetStat(targetID, "Casting time reduced by ", 77, "\n"))
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
	for featID = 0, 74, 1 do
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

function IEex_WritePatches()

	IEex_DisableCodeProtection()

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

	IEex_EnableCodeProtection()

end

if not IEex_AlreadyInitialized then

	IEex_AlreadyInitialized = true

	IEex_DefineAssemblyFunctions()
	IEex_WritePatches()
	dofile("override/IEex_Opc.lua")

end
