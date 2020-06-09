
function IEex_Reload()
	dofile("override/IEex_IWD2.lua")
end

dofile("override/IEex_TRA.lua")
dofile("override/IEex_WEIDU.lua")
dofile("override/IEex_INI.lua")

for module, tf in pairs(IEex_Modules) do
	if tf then
		dofile("override/" .. module .. ".lua")
	end
end
----------------
-- Spell List --
----------------

IEex_CasterType = {
	["Bard"] = 1,
	["Cleric"] = 2,
	["Druid"] = 3,
	["Paladin"] = 4,
	["Ranger"] = 5,
	["Sorcerer"] = 6,
	["Wizard"] = 7,
	["Domain"] = 8,
	["Innate"] = 9,
	["Song"] = 10,
	["Shape"] = 11,
}

function IEex_SetSpellInfo(actorID, casterType, spellLevel, resref, memorizedCount, castableCount)

	local memMod = memorizedCount
	local castMod = castableCount

	local typeInfo = IEex_FetchSpellInfo(actorID, {casterType})
	local levelFill = typeInfo and typeInfo[casterType][spellLevel] or nil
	if levelFill then
		for _, entry in ipairs(levelFill) do
			if entry.resref == resref then
				memMod = memorizedCount - entry.memorizedCount
				castMod = castableCount - entry.castableCount
				break
			end
		end
	end

	IEex_AlterSpellInfo(actorID, casterType, spellLevel, resref, memMod, castMod)

end

function IEex_AlterSpellInfo(actorID, casterType, spellLevel, resref, memorizeMod, castableMod)

	if casterType < 1 or casterType > 11 then
		local message = "[IEex_AlterSpellInfo] Critical Caller Error: casterType out of bounds - got "..casterType.."; valid range includes [1,11]"
		print(message)
		IEex_MessageBox(message)
		return
	end

	local levelCheck = function(lower, higher)
		if spellLevel < lower or spellLevel > higher then
			local message = "[IEex_AlterSpellInfo] Critical Caller Error: spellLevel out of bounds - got "..spellLevel.." for type "..casterType.."; valid range includes ["..lower..","..higher.."]"
			print(message)
			IEex_MessageBox(message)
			return false
		end
		return true
	end

	if casterType <= 8 then
		if not levelCheck(1, 9) then return end
	else
		if not levelCheck(1, 1) then return end
	end

	local share = IEex_GetActorShare(actorID)

	local normal = function(casterType)
		return 0x4284 + (casterType - 1) * 0x100, IEex_LISTSPLL_Reverse
	end

	local switch = {
		[1]  = normal,
		[2]  = normal,
		[3]  = normal,
		[4]  = normal,
		[5]  = normal,
		[6]  = normal,
		[7]  = normal,
		[8]  = function(t) return 0x4984, IEex_LISTSPLL_Reverse end,
		[9]  = function(t) return 0x4A84, IEex_LISTINNT_Reverse end,
		[10] = function(t) return 0x4AA0, IEex_LISTSONG_Reverse end,
		[11] = function(t) return 0x4ABC, IEex_LISTSHAP_Reverse end,
	}

	local offset, list = switch[casterType](casterType)
	local baseTypeAddress = share + offset
	local address = baseTypeAddress + (spellLevel - 1) * 0x1C

	local id = list[resref]
	if not id then
		local message = "[IEex_AlterSpellInfo] Critical Caller Error: resref \""..resref.."\" not present in corresponding master spell-list 2DA"
		print(message)
		IEex_MessageBox(message)
		return
	end

	local ptrMem = IEex_Malloc(0x10)
	IEex_WriteDword(ptrMem, id)
	IEex_WriteDword(ptrMem + 0x4, memorizeMod)
	IEex_WriteDword(ptrMem + 0x8, castableMod)
	IEex_WriteDword(ptrMem + 0xC, 0x0)

	IEex_Call(0x725950, {
		ptrMem + 0xC,
		ptrMem + 0x8,
		ptrMem + 0x4,
		ptrMem
	}, address, 0x0)

	if casterType <= 8 then
		local maxActiveLevelAddress = baseTypeAddress + 0xFC
		if IEex_ReadDword(maxActiveLevelAddress) < spellLevel then
			IEex_WriteDword(maxActiveLevelAddress, spellLevel)
		end
	end

	IEex_Free(ptrMem)

end

function IEex_FetchSpellInfo(actorID, casterTypes)

	for _, casterType in ipairs(casterTypes) do
		if casterType < 1 or casterType > 11 then
			local message = "[IEex_FetchSpellInfo] Critical Caller Error: casterType out of bounds - got "..casterType.."; valid range includes [1,11]"
			print(message)
			IEex_MessageBox(message)
			return
		end
	end

	local toReturn = {}
	local share = IEex_GetActorShare(actorID)

	local dataFromEntry = function(address, t)
		return {
			["resref"] = t[IEex_ReadDword(address)],
			["memorizedCount"] = IEex_ReadDword(address + 0x4),
			["castableCount"] = IEex_ReadDword(address + 0x8),
		}
	end

	local genLevel = function(address, t)
		local levelFill = {}
		local currentEntryBase = IEex_ReadDword(address + 0x4)
		local pEndEntry = IEex_ReadDword(address + 0x8)
		while currentEntryBase ~= pEndEntry do
			table.insert(levelFill, dataFromEntry(currentEntryBase, t))
			currentEntryBase = currentEntryBase + 0x10
		end
		return levelFill
	end

	local typeFill = function(currentLevelBase, casterType)
		local typeFill = {}
		for level = 1, 9, 1 do
			local levelFill = genLevel(currentLevelBase, IEex_LISTSPLL)
			table.insert(typeFill, levelFill)
			currentLevelBase = currentLevelBase + 0x1C
		end
		toReturn[casterType] = typeFill
	end

	local levelFill = function(currentLevelBase, casterType, t)
		local typeFill = {}
		local levelFill = genLevel(currentLevelBase, t)
		table.insert(typeFill, levelFill)
		toReturn[casterType] = typeFill
	end

	local normal = function(casterType)
		typeFill(share + 0x4284 + (casterType - 1) * 0x100, casterType)
	end

	local switch = {
		[1]  = normal,
		[2]  = normal,
		[3]  = normal,
		[4]  = normal,
		[5]  = normal,
		[6]  = normal,
		[7]  = normal,
		[8]  = function(type) typeFill(share + 0x4984, type) end,
		[9]  = function(type) levelFill(share + 0x4A84, type, IEex_LISTINNT) end,
		[10] = function(type) levelFill(share + 0x4AA0, type, IEex_LISTSONG) end,
		[11] = function(type) levelFill(share + 0x4ABC, type, IEex_LISTSHAP) end,
	}

	for _, casterType in ipairs(casterTypes) do
		switch[casterType](casterType)
	end

	return toReturn

end

----------
-- DIMM --
----------

function IEex_FileExtensionToType(extension)

	local extensions = {
		["2DA"]  = 0x3F4, -- CResText
		["ARE"]  = 0x3F2, -- CResArea
		["BAM"]  = 0x3E8, -- CResCell
		["BCS"]  = 0x3EF, -- CResText
		["BIO"]  = 0x3FE, -- CResBIO
		["BMP"]  = 0x1  , -- CResBitmap
		["BS"]   = 0x3F9, -- CResText
		["CHR"]  = 0x3FA, -- CResCHR
		["CHU"]  = 0x3EA, -- CResUI
		["CRE"]  = 0x3F1, -- CResCRE
		["DLG"]  = 0x3F3, -- CResDLG
		["EFF"]  = 0x3F8, -- CResEffect
		["GAM"]  = 0x3F5, -- CResGame
		["GLSL"] = 0x405, -- CResText
		["GUI"]  = 0x402, -- CResText
		["IDS"]  = 0x3F0, -- CResText
		["INI"]  = 0x802, -- CRes(???)
		["ITM"]  = 0x3ED, -- CResItem
		["LUA"]  = 0x409, -- CResText
		["MENU"] = 0x408, -- CResText
		["MOS"]  = 0x3EC, -- CResMosaic
		["MVE"]  = 0x2  , -- CRes(???)
		["PLT"]  = 0x6  , -- CResPLT
		["PNG"]  = 0x40B, -- CResPng
		["PRO"]  = 0x3FD, -- CResBinary
		["PVRZ"] = 0x404, -- CResPVR
		["SPL"]  = 0x3EE, -- CResSpell
		["SQL"]  = 0x403, -- CResText
		["STO"]  = 0x3F6, -- CResStore
		["TGA"]  = 0x3  , -- CRes(???)
		["TIS"]  = 0x3EB, -- CResTileSet
		["TOH"]  = 0x407, -- CRes(???)
		["TOT"]  = 0x406, -- CRes(???)
		["TTF"]  = 0x40A, -- CResFont
		["VEF"]  = 0x3FC, -- CResBinary
		["VVC"]  = 0x3FB, -- CResBinary
		["WAV"]  = 0x4  , -- CResWave
		["WBM"]  = 0x3FF, -- CResWebm
		["WED"]  = 0x3E9, -- CResWED
		["WFX"]  = 0x5  , -- CResBinary
		["WMP"]  = 0x3F7, -- CResWorldMap
	}

	return extensions[extension:upper()]

end

function IEex_GetResourceManager()
	return IEex_ReadDword(0x8CF6D8) + 0x542
end

IEex_ResWrapper = {}
IEex_ResWrapper.__index = IEex_ResWrapper

function IEex_ResWrapper:isValid()
	return self.pData ~= 0x0
end

function IEex_ResWrapper:getResRef()
	return self.resref
end

function IEex_ResWrapper:getRes()
	return self.pRes
end

function IEex_ResWrapper:getData()
	return self.pData
end

function IEex_ResWrapper:free()
	local pRes = self.pRes
	if pRes ~= 0x0 then
		-- CRes_Dump (opposite of demand)
		IEex_Call(0x77E5F0, {}, pRes, 0x0)
		-- CRes_Unload (opposite of load)
		IEex_Call(0x77E370, {}, pRes, 0x0)
		-- CResourceManager_DumpRes (opposite of dimmGetResObject)
		IEex_Call(0x787CE0, {pRes}, IEex_GetResourceManager(), 0x0)
		self.resref = ""
		self.pRes = 0x0
		self.pData = 0x0
	end
end

function IEex_ResWrapper:init(resref, pRes)
	self.resref = resref
	self.pRes = pRes
	self.pData = pRes ~= 0x0 and IEex_ReadDword(pRes + 0x8) or 0x0
end

function IEex_ResWrapper:new(resref, pRes, o)
	local o = o or {}
	setmetatable(o, self)
	o:init(resref, pRes)
	return o
end

function IEex_DemandRes(resref, extension)

	local resrefMem = IEex_Malloc(0x8)
	IEex_WriteLString(resrefMem, resref, 8)
	-- dimmGetResObject
	local pRes = IEex_Call(0x786DF0, {1, IEex_FileExtensionToType(extension), resrefMem}, IEex_GetResourceManager(), 0x0)
	IEex_Free(resrefMem)

	if pRes ~= 0x0 then
		-- CRes_Load
		IEex_Call(0x77E610, {}, pRes, 0x0)
		-- CRes_Demand
		IEex_Call(0x77E390, {}, pRes, 0x0)
	end

	return IEex_ResWrapper:new(resref, pRes)
end

function IEex_DemandCItem(resref)

	local resrefMem = IEex_Malloc(0x8)
	IEex_WriteLString(resrefMem, resref, 8)

	local CItem = IEex_Malloc(0xEE)
	-- CItem_Construct
	IEex_Call(0x4E7E90, {
		0x0, -- flags
		0x0, -- wear
		0x0, -- useCount3
		0x0, -- useCount2
		0x0, -- useCount1
		IEex_ReadDword(resrefMem + 0x4), -- resref (2/2)
		IEex_ReadDword(resrefMem + 0x0), -- resref (1/2)
	}, CItem, 0x0)

	-- CResItem_Demand
	IEex_Call(0x4015B0, {}, IEex_ReadDword(CItem + 0x8), 0x0)
	IEex_Free(resrefMem)

	return CItem
end

function IEex_DumpCItem(CItem)
	-- CResItem_Dump
	IEex_Call(0x401BA0, {}, IEex_ReadDword(CItem + 0x8), 0x0)
	-- CItem_Dump (handles both CRes_Unload and CResourceManager_DumpRes)
	IEex_Call(0x4E8180, {}, CItem, 0x0)
	IEex_Free(CItem)
end

function IEex_CanSpriteUseItem(sprite, resref)
	local CItem = IEex_DemandCItem(resref)
	local junkPtr = IEex_Malloc(0x4)
	local result = IEex_Call(0x5B9D20, {0x0, junkPtr, CItem, sprite}, IEex_GetGameData(), 0x0)
	IEex_Free(junkPtr)
	IEex_DumpCItem(CItem)
	return result == 1
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
	-- CGameSprite::GetName()
	local CString = IEex_Call(0x71F760, {}, IEex_GetActorShare(actorID), 0x0)
	return IEex_ReadString(IEex_ReadDword(CString))
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
	local share = IEex_GetActorShare(actorID)
	local bAllowEffectListCall = IEex_ReadDword(share + 0x72A4) == 1
	local activeStats = share + (bAllowEffectListCall and 0x920 or 0x1778)
	return IEex_Call(0x446DD0, {statID}, activeStats, 0x0)
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
	local share = IEex_GetActorShare(actorID)
	return share ~= 0x0 -- share != NULL
	   and IEex_ReadByte(share + 0x4, 0) == 0x31 -- m_objectType == TYPE_SPRITE
	   and (allowDead or bit32.band(IEex_ReadDword(share + 0x5BC), 0xFC0) == 0x0) -- allowDead or Status (not includes) STATE_*_DEATH
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

function IEex_SetToken(tokenString, valueString)

	local tokenStringLen = #tokenString
	local mem = IEex_Malloc(tokenStringLen + #valueString + 2)

	local valueStringMem = mem + tokenStringLen + 0x1
	IEex_WriteString(mem, tokenString)
	IEex_WriteString(valueStringMem, valueString)

	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	-- GetTokenCString
	local CString = IEex_Call(0x7FC1A5, {mem}, g_pBaldurChitin + 0x1CC8, 0x0)

	-- CString_equ_raw_string
	IEex_Call(0x7FCD57, {valueStringMem}, CString, 0x0)
	IEex_Free(mem)

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

function Feats_WhirlwindAttack(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local whirlwindAttackFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_WHIRLWIND_ATTACK"], 0x0)
	if whirlwindAttackFeatCount == 0 then
		return (IEex_ReadByte(creatureData + 0x803, 0x0) >= 13 and IEex_ReadByte(creatureData + 0x805, 0x0) >= 13 and bit32.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0 and bit32.band(IEex_ReadDword(creatureData + 0x75C), 0x80000) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MOBILITY"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SPRING_ATTACK"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 4)
	elseif whirlwindAttackFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x803, 0x0) >= 13 and IEex_ReadByte(creatureData + 0x805, 0x0) >= 21 and bit32.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0 and bit32.band(IEex_ReadDword(creatureData + 0x75C), 0x80000) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MOBILITY"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SPRING_ATTACK"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 4)
	else
		return true
	end
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

ex_order_multiclass = {
[1] = {{3, 0x8000}, {6, 0x10}, {7, -1}},
[2] = {{3, 0x40000}, {5, -1}, {7, -1}},
[4] = {{7, -1}, {10, -1}, {11, -1}},
[8] = {{4, -1}, {6, -1}, {9, -1}},
[16] = {{3, 0x8000}, {6, -1}, {7, 0x1}},
[32] = {{6, -1}, {9, -1}, {10, -1}}
}

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
Bit 19: If set, the character's Sneak Attack dice will be added to the damage if the conditions for a Sneak Attack are met.
Bit 21: If set, the character gains temporary Hit Points (for 1 hour) equal to the damage dealt.
Bit 22: If set, the character regains Hit Points equal to the damage dealt (but will not go over the character's max HP).
Bit 25: If set, the damage will be reduced by the target's damage reduction if the damage's enchantment level (specified in the fourth bit of special) is too low.

savebonus - The saving throw DC bonus of the damage is equal to that of the opcode 500 effect.

special - The first byte determines which stat should be used to determine an extra damage bonus (e.g. for Strength weapons, this would be stat 36 or 0x24: the Strength stat).
 If set to 0, there is no stat-based damage bonus. If the chosen stat is an ability score, the bonus will be based on the ability score bonus (e.g. 16 Strength would translate to +3);
 otherwise, the bonus is equal to the stat. The second byte determines a multiplier to the stat-based damage bonus, while the third byte determines a divisor to it (for example,
 if the damage was from a two-handed Strength weapon, special would be equal to 0x20324: the Strength bonus is multiplied by 3 then divided by 2 to get the damage bonus). If the
 multiplier or divisor is 0, the function sets it to 1.
--]]
ex_item_type_proficiency = {[15] = 39, [16] = 57, [17] = 54, [18] = 55, [19] = 57, [20] = 43, [21] = 42, [22] = 54, [23] = 40, [24] = 55, [25] = 38, [26] = 56, [27] = 53, [29] = 44, [30] = 44, [44] = 4, [57] = 41, [69] = 18}
ex_crippling_strike = {ex_tra_905, ex_tra_905, ex_tra_905, ex_tra_905, ex_tra_905, ex_tra_906, ex_tra_906, ex_tra_906, ex_tra_907, ex_tra_907, ex_tra_907, ex_tra_908, ex_tra_908, ex_tra_908, ex_tra_909, ex_tra_909, ex_tra_909, ex_tra_910, ex_tra_910, ex_tra_910, ex_tra_911, ex_tra_911, ex_tra_911, ex_tra_912, ex_tra_912, ex_tra_912, ex_tra_913, ex_tra_913, ex_tra_913, ex_tra_914}
ex_arterial_strike = {1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5}
ex_damage_source_spell = {["EFFAS1"] = "SPWI217", ["EFFAS2"] = "SPWI217", ["EFFCL"] = "SPPR302", ["EFFCT1"] = "SPWI117", ["EFFDA3"] = "SPWI228", ["EFFFS1"] = "SPWI427", ["EFFFS2"] = "SPWI426", ["EFFIK"] = "SPWI122", ["EFFMB1"] = "SPPR318", ["EFFMB2"] = "SPPR318", ["EFFMT1"] = "SPPR322", ["EFFPB1"] = "SPWI521", ["EFFPB2"] = "SPWI521", ["EFFS1"] = "SPPR113", ["EFFS2"] = "SPPR113", ["EFFS3"] = "SPPR113", ["EFFSC"] = "SPPR523", ["EFFSOF1"] = "SPWI511", ["EFFSOF2"] = "SPWI511", ["EFFSR1"] = "SPPR707", ["EFFSR2"] = "SPPR707", ["EFFSSO1"] = "SPPR608", ["EFFSSO2"] = "SPPR608", ["EFFSSO3"] = "SPPR608", ["EFFSSS1"] = "SPWI220", ["EFFSSS2"] = "SPWI220", ["EFFVS1"] = "SPWI424", ["EFFVS2"] = "SPWI424", ["EFFVS3"] = "SPWI424", ["EFFWOM1"] = "SPPR423", ["EFFWOM2"] = "SPPR423", ["EFFHW15"] = "SPWI805", ["EFFHW16"] = "SPWI805", ["EFFHW17"] = "SPWI805", ["EFFHW18"] = "SPWI805", ["EFFHW19"] = "SPWI805", ["EFFHW20"] = "SPWI805", ["EFFHW21"] = "SPWI805", ["EFFHW22"] = "SPWI805", ["EFFHW23"] = "SPWI805", ["EFFHW24"] = "SPWI805", ["EFFHW25"] = "SPWI805", ["EFFWT15"] = "SPWI805", ["EFFWT16"] = "SPWI805", ["EFFWT17"] = "SPWI805", ["EFFWT18"] = "SPWI805", ["EFFWT19"] = "SPWI805", ["EFFWT20"] = "SPWI805", ["EFFWT21"] = "SPWI805", ["EFFWT22"] = "SPWI805", ["EFFWT23"] = "SPWI805", ["EFFWT24"] = "SPWI805", ["EFFWT25"] = "SPWI805", ["USWI422D"] = "SPWI422", ["USWI652D"] = "USWI652", ["USWI954F"] = "USWI954", ["USDESTRU"] = "SPPR717", }
ex_feat_id_offset = {[18] = 0x78D, [38] = 0x777, [39] = 0x774, [40] = 0x779, [41] = 0x77D, [42] = 0x77B, [43] = 0x77E, [44] = 0x77A, [53] = 0x775, [54] = 0x778, [55] = 0x776, [56] = 0x77C, [57] = 0x77F}
ex_damage_multiplier_type = {[0] = 9, [0x10000] = 4, [0x20000] = 2, [0x40000] = 3, [0x80000] = 1, [0x100000] = 8, [0x200000] = 6, [0x400000] = 5, [0x800000] = 10, [0x1000000] = 7, [0x2000000] = 1, [0x4000000] = 2, [0x8000000] = 9, [0x10000000] = 5}
ex_damage_resistance_stat = {[0] = 22, [0x10000] = 17, [0x20000] = 15, [0x40000] = 16, [0x80000] = 14, [0x100000] = 23, [0x200000] = 74, [0x400000] = 73, [0x800000] = 24, [0x1000000] = 21, [0x2000000] = 19, [0x4000000] = 20, [0x8000000] = 22, [0x10000000] = 73}
function EXDAMAGE(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
			damage = damage + math.floor((IEex_GetActorStat(sourceID, 36) - 10) / 4)
		end
		rogueLevel = IEex_GetActorStat(sourceID, 104)
		local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
		if (rogueLevel > 0 or IEex_GetActorSpellState(sourceID, 192)) and bit32.band(savingthrow, 0x80000) and (IEex_GetActorSpellState(sourceID, 218) or (IEex_GetActorSpellState(sourceID, 217)) or IEex_IsValidBackstabDirection(sourceID, targetID) or bit32.band(stateValue, 0x80140029) > 0) and IEex_GetActorStat(targetID, 96) == 0 and IEex_GetActorSpellState(targetID, 216) == false and (bit32.band(savingthrow, 0x20000) > 0 or bit32.band(savingthrow, 0x40000) > 0 or bit32.band(savingthrow, 0x800000) > 0 or (bit32.band(savingthrow, 0x40000) == 0 and IEex_GetActorSpellState(sourceID, 232))) then
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

		if IEex_GetActorStat(sourceID, 103) > 0 then
--			local favoredEnemyDamage = math.floor((IEex_GetActorStat(sourceID, 103) / 5) + 1)
			local favoredEnemyDamage = 4
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
	if dicesize > 0 and dicenumber > 0 then
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
			local improvedSneakAttackFeatID = ex_feat_name_id["ME_IMPROVED_SNEAK_ATTACK"]
			local improvedSneakAttackCount = 0
			if improvedSneakAttackFeatID ~= nil then
				improvedSneakAttackCount = IEex_ReadByte(sourceData + 0x744 + improvedSneakAttackFeatID, 0x0)
				sneakAttackDiceNumber = sneakAttackDiceNumber + improvedSneakAttackCount
			end
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
		if saveBonusStat > 0 and bit32.band(savingthrow, 0x2000000) == 0 then
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
	local damageAbsorbed = false
	if IEex_GetActorSpellState(targetID, 214) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 214 and theparameter1 == IEex_ReadWord(effectData + 0x1E, 0x0) then
				damageAbsorbed = true
			end
		end)
	end
	if sourceID > 0 and bit32.band(savingthrow, 0x10000) > 0 then
		local damageMultiplier = 100
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 73 and theparameter2 > 0 then
				if ex_damage_multiplier_type[damageType] == theparameter2 then
					damageMultiplier = damageMultiplier + theparameter1
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					if theresource == parent_resource then
						local thespecial = IEex_ReadDword(eData + 0x48)
						damageMultiplier = damageMultiplier + thespecial
					end
				end
			elseif parameter2 == 0x7FFFFFFF and theopcode == 288 and theparameter2 == 191 then
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
	if bit32.band(savingthrow, 0x2000000) > 0 then
		local weaponEnchantment = IEex_ReadByte(effectData + 0x47, 0x0)
		local damageReduction = IEex_ReadByte(creatureData + 0x758, 0x0)
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			if theopcode == 436 then
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theparameter2 > damageReduction then
					damageReduction = theparameter2
				end
			end
		end)
		if IEex_GetActorSpellState(targetID, 18) and weaponEnchantment < 5 and damageReduction < 5 then
			damage = damage - 10
		elseif weaponEnchantment < damageReduction then
			damage = damage - damageReduction
		end
	end
	if damage <= 0 then
		damage = 0
	else
		if parameter2 == 0x7FFFFFFF or damageAbsorbed then
			newSavingThrow = bit32.band(newSavingThrow, 0xFFFFE3E3)
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
--[[
function MECRITIM(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
--]]

function MECRITIM(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local specialFlags = IEex_ReadByte(creatureData + 0x89F, 0)
	IEex_WriteByte(creatureData + 0x89F, bit32.bor(specialFlags, 0x2))
end

function MECRITRE(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
		turnLevel = turnLevel + math.floor((turnCheck - 1) / 3) - 3
	end
	if IEex_GetActorSpellState(sourceID, 194) then
		local healingMultiplier = 100
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 194 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				turnLevel = turnLevel + theparameter1
			end
		end)
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
["parent_resource"] = "USSMITEH",
["source_id"] = targetID
})
end

function MESMITE(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	if not IEex_IsSprite(sourceID, false) then return end
	local sourceData = IEex_GetActorShare(sourceID)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local special = IEex_ReadDword(effectData + 0x44)
	local targetAlignment = IEex_ReadByte(creatureData + 0x35, 0x0)
	if special == 0 and bit32.band(targetAlignment, 0x3) ~= 0x3 then
		return
	elseif special == 1 and bit32.band(targetAlignment, 0x3) ~= 0x1 then
		return
	end
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local paladinLevel = IEex_GetActorStat(sourceID, 102)
	local charismaBonus = math.floor((IEex_GetActorStat(sourceID, 42) - 10) / 2)
--[[
	local extraDamage = paladinLevel + charismaBonus
	local smitingFeat = IEex_ReadByte(sourceData + 0x78B, 0)
	extraDamage = extraDamage + extraDamage * smitingFeat
--]]
	local diceSize = IEex_ReadByte(effectData + 0x19, 0x0)
	if diceSize == 0 then
		diceSize = 4
	end
	local extraDice = charismaBonus
	local smitingFeat = IEex_ReadByte(sourceData + 0x78B, 0)
	extraDice = extraDice + extraDice * smitingFeat + paladinLevel + IEex_ReadByte(effectData + 0x1A, 0x0)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = IEex_ReadByte(effectData + 0x18, 0x0) + diceSize * 0x100 + extraDice * 0x10000,
["parameter2"] = parameter2,
["savingthrow"] = 0x10000,
["resource"] = "EXDAMAGE",
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 0,
["resource"] = "USSMITEH",
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
end

function MEHOLYMI(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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

function MEQUIPLE(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local hasBow = false
	if IEex_GetActorSpellState(targetID, 241) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 241 then
				if theparameter1 == 15 then
					hasBow = true
				end
			end
		end)
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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

extra_hands = {[32558] = 4, [60365] = 6, [60697] = 4,}
ex_whirla_index = 1
function MEWHIRLA(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID) or IEex_CompareActorAllegiances(sourceID, targetID) > -1 then return end
	local sourceData = IEex_GetActorShare(sourceID)
	local sourceX = IEex_ReadDword(sourceData + 0x6)
	local sourceY = IEex_ReadDword(sourceData + 0xA)
	local targetX = IEex_ReadDword(creatureData + 0x6)
	local targetY = IEex_ReadDword(creatureData + 0xA)
	local weaponRES = {"", ""}
	local wearingLightArmor = true
	if IEex_GetActorSpellState(sourceID, 241) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
			if theopcode == 288 and theparameter2 == 241 then
				if thespecial == 5 or thespecial == 6 then
					if weaponRES[1] == "" then
						weaponRES[1] = IEex_ReadLString(eData + 0x94, 8)
					else
						weaponRES[2] = IEex_ReadLString(eData + 0x94, 8)
					end
				elseif (theparameter1 >= 62 and theparameter1 <= 66) or theparameter1 == 68 then
					wearingLightArmor = false
				end
			end
		end)
	end
	local spriteHands = 2
	local animation = IEex_ReadDword(sourceData + 0x5C4)
	if extra_hands[animation] ~= nil then
		spriteHands = extra_hands[animation]
	end
	if spriteHands == 4 then
		if weaponRES[2] == "" then
			weaponRES = {weaponRES[1], weaponRES[1], weaponRES[1], weaponRES[1]}
		else
			weaponRES = {weaponRES[1], weaponRES[1], weaponRES[2], weaponRES[2]}
		end
	elseif spriteHands == 6 then
		if weaponRES[2] == "" then
			weaponRES = {weaponRES[1], weaponRES[1], weaponRES[1], weaponRES[1], weaponRES[1], weaponRES[1]}
		else
			weaponRES = {weaponRES[1], weaponRES[1], weaponRES[1], weaponRES[2], weaponRES[2], weaponRES[2]}
		end
	end
	local numAttacks = spriteHands
	local hand = 1
	while hand <= numAttacks do
		local res = weaponRES[hand]
		local resWrapper = IEex_DemandRes(res, "ITM")
		if resWrapper:isValid() then
			local itemData = resWrapper:getData()
			local proficiencyFeat = 0
			local isTwoHanded = (bit32.band(IEex_ReadDword(itemData + 0x18), 0x2) > 0)
			local itemType = IEex_ReadWord(itemData + 0x1C, 0x0)
			if ex_item_type_proficiency[itemType] ~= nil then
				proficiencyFeat = ex_item_type_proficiency[itemType]
			end
			local effectOffset = IEex_ReadDword(itemData + 0x6A)
			local numHeaders = IEex_ReadWord(itemData + 0x68, 0x0)
			for header = 1, numHeaders, 1 do
				local offset = itemData + 0x4A + header * 0x38

				local itemRange = 20 * IEex_ReadWord(offset + 0xE, 0x0) + 40
				local whirlwindAttackFeatID = ex_feat_name_id["ME_WHIRLWIND_ATTACK"]
				if whirlwindAttackFeatID ~= nil and IEex_ReadByte(sourceData + 0x744 + whirlwindAttackFeatID, 0x0) >= 2 then
					itemRange = itemRange + 60
				end
				local itemDamageType = IEex_ReadWord(offset + 0x1C, 0x0)
				if IEex_ReadByte(offset, 0x0) == 1 and IEex_GetDistance(sourceX, sourceY, targetX, targetY) <= itemRange then

					local attackRoll = math.random(20) + IEex_GetActorStat(sourceID, 32)
					local isHit = false
					local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
					if attackRoll >= 20 or bit32.band(stateValue, 0xE9) > 0 then
						isHit = true
					elseif attackRoll >= 2 then
						local attackBonus = IEex_ReadByte(sourceData + 0x5EC, 0x0) + IEex_GetActorStat(sourceID, 7) + IEex_ReadSignedWord(offset + 0x14, 0x0) - 4
						if proficiencyFeat > 0 then
							attackBonus = attackBonus + ex_proficiency_attack[IEex_ReadByte(sourceData + ex_feat_id_offset[proficiencyFeat], 0x0)]
						end
						if IEex_GetActorStat(sourceID, 103) > 0 then
						local favoredEnemyBonus = math.floor((IEex_GetActorStat(sourceID, 103) / 5) + 1)
							local enemyRace = IEex_ReadByte(creatureData + 0x26, 0x0)
							if enemyRace == IEex_ReadByte(sourceData + 0x7F7, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7F8, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7F9, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7FA, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7FB, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7FC, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7FD, 0x0) or enemyRace == IEex_ReadByte(sourceData + 0x7FE, 0x0) then
								attackBonus = attackBonus + favoredEnemyBonus
							end
						end
						if weaponRES[2] ~= "" then
							local dualWieldingPenalty = 4
							if hand >= 2 then
								dualWieldingPenalty = 8
							end
							if IEex_GetActorStat(sourceID, 103) > 0 and wearingLightArmor then
								dualWieldingPenalty = dualWieldingPenalty - 6
							else
								if bit32.band(IEex_ReadDword(sourceData + 0x75C), 0x2) > 0 then
									dualWieldingPenalty = dualWieldingPenalty - 4
								end
								if bit32.band(IEex_ReadDword(sourceData + 0x764), 0x40) > 0 then
									dualWieldingPenalty = dualWieldingPenalty - 2
								end
							end
							if dualWieldingPenalty < 0 then
								dualWieldingPenalty = 0
							end
							attackBonus = attackBonus - dualWieldingPenalty
						end
						local attackStatBonus = 0
						if bit32.band(IEex_ReadDword(offset + 0x26), 0x1) > 0 then
							attackStatBonus = math.floor((IEex_GetActorStat(sourceID, 36) - 10) / 2)
						end
						if (itemType == 16 or itemType == 19) and bit32.band(IEex_ReadDword(sourceData + 0x764), 0x80) > 0 then
							local dexterityBonus = math.floor((IEex_GetActorStat(sourceID, 40) - 10) / 2)
							if dexterityBonus > attackStatBonus then
								attackStatBonus = dexterityBonus
							end
						end
						attackBonus = attackBonus + attackStatBonus
						local armorClassList = IEex_GetActorArmorClass(targetID)
						local ac = armorClassList[1]
						local acslashing = armorClassList[2]
						local acpiercing = armorClassList[3]
						local acbludgeoning = armorClassList[4]
						local acmissile = armorClassList[5]
						if itemDamageType == 3 or (itemDamageType == 7 and acslashing <= acpiercing) or (itemDamageType == 8 and acslashing <= acbludgeoning) then
							ac = ac + acslashing
						elseif itemDamageType == 1 or (itemDamageType == 6 and acpiercing <= acbludgeoning) or (itemDamageType == 7 and acpiercing <= acslashing) then
							ac = ac + acpiercing
						elseif itemDamageType == 2 or (itemDamageType == 6 and acbludgeoning <= acpiercing) or (itemDamageType == 8 and acbludgeoning <= acslashing) then
							ac = ac + acbludgeoning
						elseif itemDamageType == 4 or itemDamageType == 9 then
							ac = ac + acmissile
						end
						if attackRoll + attackBonus >= ac then
							isHit = true
						end
--						IEex_DisplayString(attackRoll .. " + " .. attackBonus .. " = " .. attackRoll + attackBonus .. " vs " .. ac)
					end
					local feedbackString = "Attacks " .. IEex_GetActorName(targetID) .. " with " .. IEex_FetchString(IEex_ReadDword(itemData + 0xC)) .. " : "
					if isHit then
						feedbackString = feedbackString .. "Hit"
					else
						feedbackString = feedbackString .. "Miss"
					end
					IEex_SetToken("MEWHRA" .. ex_whirla_index, feedbackString)
					IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["parameter1"] = ex_whirla[ex_whirla_index],
["source_id"] = sourceID
})
					if ex_whirla_index == 20 then
						ex_whirla_index = 1
					else
						ex_whirla_index = ex_whirla_index + 1
					end
--					IEex_DisplayString(feedbackString)

					if isHit then
						if itemDamageType > 0 then
							local newparameter2 = 0
							if itemDamageType == 1 or itemDamageType == 4 then
								newparameter2 = 0x100000
							elseif itemDamageType == 3 or itemDamageType == 7 or itemDamageType == 8 then
								newparameter2 = 0x1000000
							elseif itemDamageType == 5 then
								newparameter2 = 0x8000000
							end
							local bonusStat = 0
							local bonusStatMultiplier = 0
							local bonusStatDivisor = 0
							local weaponEnchantment = IEex_ReadDword(itemData + 0x60)
							if bit32.band(IEex_ReadDword(offset + 0x26), 0x1) > 0 then
								bonusStat = 36
								if bit32.band(IEex_ReadDword(itemData + 0x18), 0x2) > 0 then
									bonusStatMultiplier = 3
									bonusStatDivisor = 2
								elseif hand == 2 then
									bonusStatMultiplier = 1
									bonusStatDivisor = 2
								end
							end
							local effectFlags = 0x2020000
--							if weaponRES[1] == weaponRES[2] then
								effectFlags = 0x2024000
--							end
							IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["parameter1"] = IEex_ReadByte(offset + 0x1A, 0x0) + (IEex_ReadByte(offset + 0x16, 0x0) * 0x100) + (IEex_ReadByte(offset + 0x18, 0x0) * 0x10000) + (proficiencyFeat * 0x1000000),
["parameter2"] = newparameter2,
["savingthrow"] = effectFlags,
["special"] = bonusStat + (bonusStatMultiplier * 0x100) + (bonusStatDivisor * 0x10000) + (weaponEnchantment * 0x1000000),
["resource"] = "EXDAMAGE",
["source_id"] = sourceID
})
						end
						local probabilityRoll = math.random(100) - 1
						local firstEffectIndex = IEex_ReadWord(offset + 0x20, 0x0)
						local headerNumEffects = IEex_ReadWord(offset + 0x1E, 0x0)
						for headerEffect = 1, headerNumEffects, 1 do
							local headerEffectOffset = itemData + effectOffset + 0x30 * firstEffectIndex + 0x30 * (headerEffect - 1)
							local effprobability1 = IEex_ReadByte(headerEffectOffset + 0x12, 0x0)
							local effprobability2 = IEex_ReadByte(headerEffectOffset + 0x13, 0x0)
							if probabilityRoll <= effprobability1 and probabilityRoll >= effprobability2 then
								local effopcode = IEex_ReadWord(headerEffectOffset, 0x0)
								local effTargetID = targetID
								local effTargetX = targetX
								local effTargetY = targetY
								if IEex_ReadByte(headerEffectOffset + 0x2, 0x0) == 1 then
									effTargetID = sourceID
									effTargetX = sourceX
									effTargetY = sourceY
								end
								local effpower = IEex_ReadByte(headerEffectOffset + 0x3, 0x0)
								local effparameter1 = IEex_ReadDword(headerEffectOffset + 0x4)
								local effparameter2 = IEex_ReadDword(headerEffectOffset + 0x8)
								local efftiming = IEex_ReadByte(headerEffectOffset + 0xC, 0x0)
								local effresist_dispel = IEex_ReadByte(headerEffectOffset + 0xD, 0x0)
								local effduration = IEex_ReadDword(headerEffectOffset + 0xE)
								local effresource = IEex_ReadLString(headerEffectOffset + 0x14, 8)
								local effdicenumber = IEex_ReadDword(headerEffectOffset + 0x1C)
								local effdicesize = IEex_ReadDword(headerEffectOffset + 0x20)
								local effsavingthrow = IEex_ReadDword(headerEffectOffset + 0x24)
								local effsavebonus = IEex_ReadDword(headerEffectOffset + 0x28)
								local effspecial = IEex_ReadDword(headerEffectOffset + 0x2C)

								if effopcode == 12 then
									effopcode = 500
									if effdicenumber < 0 then
										effdicenumber = 0
									end
									if effdicesize < 0 then
										effdicesize = 0
									end
									effparameter1 = IEex_ReadByte(headerEffectOffset + 0x4, 0x0) + (effdicesize * 0x100) + (effdicenumber * 0x10000)
									efftiming = 0
									effduration = 0
									effresource = "EXDAMAGE"
									effdicenumber = 0
									effdicesize = 0
									effsavingthrow = bit32.bor(effsavingthrow, 0x10000)
									if bit32.band(effsavingthrow, 0x4) > 0 then
										effsavingthrow = bit32.bor(effsavingthrow, 0x400)
									end
									if bit32.band(effsavingthrow, 0x8) > 0 then
										effsavingthrow = bit32.bor(effsavingthrow, 0x800)
									end
									if bit32.band(effsavingthrow, 0x10) > 0 then
										effsavingthrow = bit32.bor(effsavingthrow, 0x1000)
									end
									effsavingthrow = bit32.band(effsavingthrow, 0xFFFFFFE3)
									if effopcode == 500 and weaponRES[1] == weaponRES[2] then
										effsavingthrow = bit32.bor(effsavingthrow, 0x4000)
									end
									effspecial = 0
								end
								if effopcode == 442 then
									if hand <= spriteHands then
										numAttacks = numAttacks + 1
										table.insert(weaponRES, res)
										IEex_ApplyEffectToActor(sourceID, {
	["opcode"] = 139,
	["target"] = 2,
	["timing"] = 0,
	["parameter1"] = 39846,
	["source_id"] = sourceID
	})
									end
								else
									IEex_ApplyEffectToActor(effTargetID, {
	["opcode"] = effopcode,
	["target"] = 2,
	["timing"] = efftiming,
	["duration"] = effduration,
	["parameter1"] = effparameter1,
	["parameter2"] = effparameter2,
	["dicenumber"] = effdicenumber,
	["dicesize"] = effdicesize,
	["resource"] = effresource,
	["resist_dispel"] = effresist_dispel,
	["savingthrow"] = effsavingthrow,
	["savebonus"] = effsavebonus,
	["special"] = effspecial,
	["source_x"] = sourceX,
	["source_y"] = sourceX,
	["target_x"] = targetX,
	["target_y"] = targetX,
	["parent_resource"] = res,
	["source_id"] = sourceID
	})
								end
							end
						end
					end
				end
			end

			resWrapper:free()
		end
		hand = hand + 1
	end
end

function MEROTATE(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if IEex_ReadDword(effectData + 0x1C) > 0 and IEex_IsSprite(sourceID) then
		local sourceData = IEex_GetActorShare(sourceID)
		local orientation1 = IEex_ReadByte(sourceData + 0x537E, 0x0)
		orientation1 = (orientation1 + 1) % 16
		IEex_WriteByte(sourceData + 0x537E, orientation1)
--		local orientation2 = IEex_ReadByte(sourceData + 0x5380, 0x0)
--		orientation2 = (orientation2 + 1) % 16
--		IEex_WriteByte(sourceData + 0x5380, orientation2)
	else
		local orientation1 = IEex_ReadByte(creatureData + 0x537E, 0x0)
		orientation1 = (orientation1 + 1) % 16
		IEex_WriteByte(creatureData + 0x537E, orientation1)
--		local orientation2 = IEex_ReadByte(creatureData + 0x5380, 0x0)
--		orientation2 = (orientation2 + 1) % 16
--		IEex_WriteByte(creatureData + 0x5380, orientation2)
	end

end

function MESPELL(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local headerType = IEex_ReadDword(effectData + 0x44)
	local sourceExpired = {}
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
						table.insert(sourceExpired, theparent_resource)
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
	for k, v in ipairs(sourceExpired) do
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = v,
["source_id"] = sourceID
})
	end
	local targetExpired = {}
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
						table.insert(targetExpired, theparent_resource)
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
	for k, v in ipairs(targetExpired) do
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = v,
["source_id"] = targetID
})
	end
end

function MEEXHIT(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local index = IEex_ReadDword(effectData + 0x1C)
	local headerType = IEex_ReadDword(effectData + 0x44)
	local sourceExpired = {}
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
						table.insert(sourceExpired, theparent_resource)
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
	for k, v in ipairs(sourceExpired) do
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = v,
["source_id"] = sourceID
})
	end
	local targetExpired = {}
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
						table.insert(targetExpired, theparent_resource)
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
	for k, v in ipairs(targetExpired) do
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = v,
["source_id"] = targetID
})
	end
end

repeat_record = {}
--[[
function IEex_CheckForEffectRepeat(actorID, effectData)
	if bit32.band(IEex_ReadDword(effectData + 0x3C), 0x4000) > 0 then return false end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local special = IEex_ReadDword(effectData + 0x44)
	local time = IEex_ReadDword(effectData + 0x24)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local funcName = IEex_ReadLString(effectData + 0x2C, 8)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	if repeat_record[actorID] == nil then
		repeat_record[actorID] = {}
	end
	local newTick = false
	if repeat_record[actorID][funcName] == nil then
		repeat_record[actorID][funcName] = {}
	else
		for k, v in ipairs(repeat_record[actorID][funcName]) do
			if v["time"] ~= time then
				newTick = true
			elseif v["parameter1"] == parameter1 and v["parameter2"] == parameter2 and v["special"] == special and v["sourceID"] == sourceID and v["parent_resource"] == parent_resource then
				return true
			end
		end
	end
	if newTick then
		repeat_record[actorID][funcName] = {}
	end
	table.insert(repeat_record[actorID][funcName], {["parameter1"] = parameter1, ["parameter2"] = parameter2, ["special"] = special, ["time"] = time, ["sourceID"] = sourceID, ["parent_resource"] = parent_resource})
	return false
end
--]]
function IEex_CheckForEffectRepeat(effectData, creatureData)
	local actorID = IEex_GetActorIDShare(creatureData)
--	if bit32.band(IEex_ReadDword(effectData + 0x3C), 0x4000) > 0 then return false end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local special = IEex_ReadDword(effectData + 0x44)
	local time = IEex_ReadDword(effectData + 0x24)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local funcName = IEex_ReadLString(effectData + 0x2C, 8)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	if repeat_record[actorID] == nil then
		repeat_record[actorID] = {}
	end
	local newTick = false
	if repeat_record[actorID][funcName] == nil then
		repeat_record[actorID][funcName] = {}
	else
		for k, v in ipairs(repeat_record[actorID][funcName]) do
			if v["time"] ~= time then
				newTick = true
			elseif v["effectData"] == effectData then
				return true
			end
		end
	end
	if newTick then
		repeat_record[actorID][funcName] = {}
	end
	table.insert(repeat_record[actorID][funcName], {["effectData"] = effectData, ["time"] = time})
	return false
end
loop_record = {}

function IEex_CheckForInfiniteLoop(actorID, time, funcName, repeatLimit)
	if loop_record[actorID] == nil then
		loop_record[actorID] = {}
	end
	if loop_record[actorID][funcName] ~= nil and time == loop_record[actorID][funcName][1] then
		loop_record[actorID][funcName][1] = time
		local repeatCount = loop_record[actorID][funcName][2]
		repeatCount = repeatCount + 1
--		print("" .. repeatCount)
		if repeatCount >= repeatLimit then
			return true
		else
			loop_record[actorID][funcName][2] = repeatCount
		end
	else
		loop_record[actorID][funcName] = {time, 1}
	end
	return false
end

function MEREPERM(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	if IEex_ReadDword(effectData + 0x10C) <= 0 then return end
	local targetID = IEex_GetActorIDShare(creatureData)
--	if IEex_CheckForInfiniteLoop(targetID, IEex_ReadDword(effectData + 0x24), "MEREPERM", 5) then return end

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
	if IEex_GetActorSpellState(targetID, 193) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 193 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if thespecial == 2 then
					castingSpeedModifier = castingSpeedModifier + theparameter1
				end
			end
		end)
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
	local specialFlags = IEex_ReadByte(creatureData + 0x89F, 0x0)
	if bit32.band(specialFlags, 0xC) > 0 then
		local kit = IEex_GetActorStat(targetID, 89)
		for k, v in pairs(ex_order_multiclass) do
			if bit32.band(kit, k) > 0 then
				local acceptable = true
				local acceptable_classes = {}
				for i, c in ipairs(v) do
					acceptable_classes["" .. c[1]] = c[2]
				end
				for i = 1, 11, 1 do
					if IEex_GetActorStat(targetID, 95 + i) > 0 then
						if acceptable_classes["" .. i] == nil then
							acceptable = false
						elseif acceptable_classes["" .. i] ~= -1 and bit32.band(kit, acceptable_classes["" .. i]) == 0 then
							acceptable = false
						end
					end
				end
				if acceptable then
					if k <= 4 and bit32.band(specialFlags, 0x4) then
						IEex_WriteByte(creatureData + 0x89F, bit32.band(specialFlags, 0xFB))
					elseif k > 4 and bit32.band(specialFlags, 0x8) then
						IEex_WriteByte(creatureData + 0x89F, bit32.band(specialFlags, 0xF7))
					end
				end
			end
		end
	end
end

function MEONCAST(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
--	print("MEONCAST")
	if not IEex_IsSprite(targetID, false) then return end
--	print("from " .. targetID)
	local casterlvl = IEex_ReadByte(effectData + 0xC4, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x18, 8)
	local lowestClassSpellLevel = 10
	local classSpellLevel = 0
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
["resource"] = "USDURMAG",
["source_id"] = targetID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USDURPRI",
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
	local wizardDurationModifier = 100
	local priestDurationModifier = 100
	if IEex_GetActorSpellState(targetID, 193) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 193 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local thespecial = IEex_ReadDword(eData + 0x48)
				local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
				if thespecial == 0 then
					wizardDurationModifier = math.floor(wizardDurationModifier * theparameter1 / 100)
				elseif thespecial == 1 then
					priestDurationModifier = math.floor(priestDurationModifier * theparameter1 / 100)
				end
			end
		end)
	end
	if classSpellLevel > 0 and maximumExtendSpellLevel >= classSpellLevel then
		wizardDurationModifier = wizardDurationModifier * 2
		priestDurationModifier = priestDurationModifier * 2
	end
	if wizardDurationModifier > 255 then
		wizardDurationModifier = 255
	end
	if priestDurationModifier > 255 then
		priestDurationModifier = 255
	end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local casterlvl = IEex_ReadByte(effectData + 0xC4, 0x0)
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
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
	local allowAbsorption = false
	if bit32.band(savingthrow, 0x20000) > 0 and IEex_GetActorSpellState(targetID, 214) then
		local damageTypeAllowed = IEex_ReadDword(effectData + 0x44)
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 214 and theparameter1 == damageTypeAllowed then
				allowAbsorption = true
			end
		end)
	end
	if classSpellLevel > 0 and maximumSafeSpellLevel >= classSpellLevel and allowAbsorption == false then
		if bit32.band(savingthrow, 0x10000) == 0 then
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
		else
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
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
6: The target gets immunity if they have any of the races specified by parameter2.
--]]
function MESPLPRT(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	elseif protectionType == 6 then
		local race = IEex_ReadByte(creatureData + 0x26, 0x0)
		local match_race1 = IEex_ReadByte(effectData + 0x1C, 0x0)
		local match_race2 = IEex_ReadByte(effectData + 0x1D, 0x0)
		local match_race3 = IEex_ReadByte(effectData + 0x1E, 0x0)
		local match_race4 = IEex_ReadByte(effectData + 0x1F, 0x0)
		if race == match_race1 or race == match_race2 or race == match_race3 or race == match_race4 then
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	local spriteHands = 2
	local animation = IEex_ReadDword(sourceData + 0x5C4)
	if extra_hands[animation] ~= nil then
		spriteHands = extra_hands[animation]
	end
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
	if handsUsed >= spriteHands then
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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

function MEMIRRIM(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local duration = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local foundIt = false
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		if theopcode == 119 then
			foundIt = true
			local numImages = IEex_ReadDword(eData + 0x1C)
			if parameter2 == 0 then
				numImages = numImages + parameter1
			elseif parameter2 == 1 then
				numImages = parameter1
			elseif parameter2 == 2 then
				numImages = math.floor(numImages * parameter1 / 100)
			end
			if numImages > 8 then
				numImages = 8
			elseif numImages < 0 then
				numImages = 0
			end
			IEex_WriteDword(eData + 0x1C, numImages)
			IEex_WriteDword(eData + 0x20, 0)
		end
	end)
	if foundIt == false and parameter2 == 0 then
		IEex_ApplyEffectToActor(targetID, {
	["opcode"] = 119,
	["target"] = 2,
	["timing"] = 0,
	["duration"] = duration,
	["parameter1"] = 1,
	["parameter2"] = 1,
	["parent_resource"] = parent_resource,
	["source_id"] = sourceID
	})
		parameter1 = parameter1 - 1
		if parameter1 > 0 then
			IEex_IterateActorEffects(targetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				if theopcode == 119 then
					foundIt = true
					local numImages = IEex_ReadDword(eData + 0x1C)
					if parameter2 == 0 then
						numImages = numImages + parameter1
					elseif parameter2 == 1 then
						numImages = parameter1
					elseif parameter2 == 2 then
						numImages = math.floor(numImages * parameter1 / 100)
					end
					if numImages > 8 then
						numImages = 8
					elseif numImages < 0 then
						numImages = 0
					end
					IEex_WriteDword(eData + 0x1C, numImages)
					IEex_WriteDword(eData + 0x20, 0)
				end
			end)
		end
	end
end

function MEPOISON(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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

function MENOTEL(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local sourceData = IEex_GetActorShare(sourceID)
	local sourceX = IEex_ReadDword(sourceData + 0x6)
	local sourceY = IEex_ReadDword(sourceData + 0xA)
	local targetX = IEex_ReadDword(effectData + 0x84)
	local targetY = IEex_ReadDword(effectData + 0x88)
	local targetIDX = IEex_ReadDword(creatureData + 0x6)
	local targetIDY = IEex_ReadDword(creatureData + 0xA)
	local disableTeleport = false

	local areaData = IEex_ReadDword(creatureData + 0x12)
	if areaData <= 0 then return end
	local areaType = IEex_ReadWord(areaData + 0x40, 0x0)
	if bit32.band(areaType, 0x800) > 0 then
		disableTeleport = true
	else
		local areaRES = IEex_ReadLString(areaData, 8)
		if areaRES == "AR4102" and ((sourceX >= 400 and sourceX <= 970 and sourceY >= 1030 and sourceY <= 1350) or (targetX >= 400 and targetX <= 970 and targetY >= 1030 and targetY <= 1350) or (targetIDX >= 400 and targetIDX <= 970 and targetIDY >= 1030 and targetIDY <= 1350)) then
			disableTeleport = true
		end
	end
	if disableTeleport then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["resource"] = IEex_ReadLString(effectData + 0x90, 8),
["source_id"] = sourceID
})
	end
end

function METELEFI(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	IEex_WriteDword(creatureData + 0xE, parameter1 * -1)
end

function MEWINGBU(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local special = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local targetX = IEex_ReadDword(creatureData + 0x6)
	local targetY = IEex_ReadDword(creatureData + 0xA)
	local destinationX = IEex_ReadDword(creatureData + 0x556E)
	local destinationY = IEex_ReadDword(creatureData + 0x5572)
	local disableTeleport = false
	local areaData = IEex_ReadDword(creatureData + 0x12)
	if areaData <= 0 then return end
	local areaType = IEex_ReadWord(areaData + 0x40, 0x0)
	if bit32.band(areaType, 0x800) > 0 then
		disableTeleport = true
	else
		local areaRES = IEex_ReadLString(areaData, 8)
		if areaRES == "AR4102" and ((targetX >= 400 and targetX <= 970 and targetY >= 1030 and targetY <= 1350) or (destinationX >= 400 and destinationX <= 970 and destinationY >= 1030 and destinationY <= 1350)) then
			disableTeleport = true
		end
	end
	if (destinationX > 0 or destinationY > 0) and disableTeleport == false then
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
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	IEex_WriteDword(creatureData + 0x5BC, bit32.band(IEex_ReadDword(creatureData + 0x5BC), 0xEFFFFFFF))
	IEex_WriteDword(creatureData + 0x920, bit32.band(IEex_ReadDword(creatureData + 0x920), 0xEFFFFFFF))
end

function MESUCREA(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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

function IEex_GetNth(n)
	local nth = "" .. n
	if n < 0 then
		n = n * -1
	end
	if n % 10 == 1 and n % 100 ~= 11 then
		nth = nth .. "st"
	elseif n % 10 == 2 and n % 100 ~= 12 then
		nth = nth .. "nd"
	elseif n % 10 == 3 and n % 100 ~= 13 then
		nth = nth .. "rd"
	else
		nth = nth .. "th"
	end
	return nth
end

opcodenames = {[3] = "berserk", [5] = "charm", [12] = "damage", [17] = "healing", [20] = "invisibility", [23] = "morale failure", [24] = "fear", [25] = "poison", [38] = "silence", [39] = "sleep", [40] = "slow", [45] = "stun", [58] = "dispelling", [60] = "spell failure", [74] = "blindness", [76] = "feeblemindedness", [78] = "disease", [80] = "deafness", [93] = "fatigue", [94] = "intoxication", [109] = "paralysis", [124] = "teleportation", [128] = "confusion", [134] = "petrification", [135] = "polymorphing", [154] = "entangle", [157] = "web", [158] = "grease", [175] = "hold", [176] = "movement penalties", [241] = "vampiric effects", [247] = "Beltyn's Burning Blood", [255] = "salamander auras", [256] = "umber hulk gaze", [279] = "Animal Rage", [281] = "Vitriolic Sphere", [294] = "harpy wail", [295] = "jackalwere gaze", [400] = "hopelessness", [404] = "nausea", [405] = "enfeeblement", [412] = "Domination", [414] = "Otiluke's Resilient Sphere", [416] = "wounding", [419] = "knockdown", [420] = "instant death", [424] = "Hold Undead", [425] = "Control Undead", [428] = "Dismissal/Banishment", [429] = "energy drain"}

classstatnames = {"Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Wizard"}
function MESTATPR(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
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
	IEex_DisplayString(MEGetStat(targetID, "Slashing Resistance: ", 21, "\n") .. MEGetStat(targetID, "Piercing Resistance: ", 23, "\n") .. MEGetStat(targetID, "Bludgeoning Resistance: ", 22, "\n") .. MEGetStat(targetID, "Missile Resistance: ", 24, "\n") .. MEGetStat(targetID, "Fire Resistance: ", 14, "\n") .. MEGetStat(targetID, "Cold Resistance: ", 15, "\n") .. MEGetStat(targetID, "Electricity Resistance: ", 16, "\n") .. MEGetStat(targetID, "Acid Resistance: ", 17, "\n") .. MEGetStat(targetID, "Poison Resistance: ", 74, "\n") .. MEGetStat(targetID, "Magic Damage Resistance: ", 73, "\n") .. MEGetStat(targetID, "Spell Resistance: ", 18, "\n"))
	local damageReduction = IEex_ReadByte(creatureData + 0x758, 0x0)
	local mirrorImagesRemaining = 0
	local stoneskinDamageRemaining = 0
	local sneakAttackModifier = 0
	local extendSpellLevel = 0
	local quickenSpellLevel = 0
	local maximizeSpellLevel = 0
	local safeSpellLevel = 0
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
		elseif theopcode == 288 then
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theparameter2 == 192 then
				sneakAttackModifier = sneakAttackModifier + theparameter1
			elseif theparameter2 == 234 then
				quickenSpellLevel = quickenSpellLevel + theparameter1
			elseif theparameter2 == 235 then
				safeSpellLevel = safeSpellLevel + theparameter1
			elseif theparameter2 == 238 then
				maximizeSpellLevel = maximizeSpellLevel + theparameter1
			elseif theparameter2 == 239 then
				extendSpellLevel = extendSpellLevel + theparameter1
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
		IEex_DisplayString("Sneak attack damage: " .. math.floor((IEex_GetActorStat(targetID, 104) + 1) / 2) + sneakAttackModifier)
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
	if extendSpellLevel > 0 then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " can extend up to " .. IEex_GetNth(extendSpellLevel) .. "-level spells")
	end
	if maximizeSpellLevel > 0 then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " can maximize up to " .. IEex_GetNth(maximizeSpellLevel) .. "-level spells")
	end
	if quickenSpellLevel > 0 then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " can quicken up to " .. IEex_GetNth(quickenSpellLevel) .. "-level spells")
	end
	if safeSpellLevel > 0 then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " can safen up to " .. IEex_GetNth(safeSpellLevel) .. "-level spells")
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
	if IEex_GetActorSpellState(targetID, 216) then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " is protected from sneak attacks")
	end
	if IEex_GetActorSpellState(targetID, 64) then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " deals maximum damage with each hit")
	end
	if IEex_GetActorSpellState(targetID, 218) then
		IEex_DisplayString(IEex_GetActorName(targetID) .. " can sneak attack on each hit")
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

function IEex_Stage1Startup()
	IEex_IndexAllResources()
	IEex_MapSpellsToScrolls()
	IEex_LoadInitial2DAs()
	IEex_WriteDelayedPatches()
end

function IEex_Stage2Startup()
	IEex_IndexMasterSpellLists()
end

function IEex_IndexMasterSpellLists()

	local index = function(address, t, r)

		local currentAddress = IEex_ReadDword(address)
		local limit = IEex_ReadDword(address + 0x4) - 1

		if limit >= 0 then
			local resref = IEex_ReadLString(currentAddress, 8)
			t[0] = resref
			r[resref] = 0
			currentAddress = currentAddress + 0x8
		end

		for i = 1, limit, 1 do
			local resref = IEex_ReadLString(currentAddress, 8)
			table.insert(t, resref)
			r[resref] = i
			currentAddress = currentAddress + 0x8
		end

	end

	local data = IEex_GetGameData()

	IEex_LISTSPLL = {}
	IEex_LISTSPLL_Reverse = {}
	index(data + 0x4BF8, IEex_LISTSPLL, IEex_LISTSPLL_Reverse)

	IEex_LISTINNT = {}
	IEex_LISTINNT_Reverse = {}
	index(data + 0x4C00, IEex_LISTINNT, IEex_LISTINNT_Reverse)

	IEex_LISTSONG = {}
	IEex_LISTSONG_Reverse = {}
	index(data + 0x4C08, IEex_LISTSONG, IEex_LISTSONG_Reverse)

	IEex_LISTSHAP = {}
	IEex_LISTSHAP_Reverse = {}
	index(data + 0x4C10, IEex_LISTSHAP, IEex_LISTSHAP_Reverse)

end

function IEex_IndexAllResources()

	IEex_IndexedResources = {}

	local unknownSubstruct = IEex_GetResourceManager() + 0x24C
	local unknownSubstruct2 = IEex_ReadDword(unknownSubstruct + 0x10)

	local limit = IEex_ReadDword(unknownSubstruct + 0xC)
	local currentIndex = 0
	local currentAddress = 0

	while currentIndex ~= limit do
		local resref = IEex_ReadLString(unknownSubstruct2 + currentAddress, 8)
		if resref ~= "" then
			local type = IEex_ReadWord(unknownSubstruct2 + currentAddress + 0x12, 0)
			local typeBucket = IEex_IndexedResources[type]
			if not typeBucket then
				typeBucket = {}
				IEex_IndexedResources[type] = typeBucket
			end
			table.insert(typeBucket, resref)
		end
		currentIndex = currentIndex + 1
		currentAddress = currentAddress + 0x18
	end

	for type, bucket in pairs(IEex_IndexedResources) do
		table.sort(bucket)
	end

end

function IEex_MapSpellsToScrolls()

	IEex_SpellToScroll = {}

	for i, resref in ipairs(IEex_IndexedResources[IEex_FileExtensionToType("ITM")]) do

		local prefix = resref:sub(1, 4)
		if prefix == "SPWI" or prefix == "SPPR" or prefix == "USWI" or prefix == "USPR" then

			local resWrapper = IEex_DemandRes(resref, "ITM")

			if resWrapper:isValid() then

				local data = resWrapper:getData()
				local category = IEex_ReadWord(data + 0x1C, 0)
				local abilitiesNum = IEex_ReadWord(data + 0x68, 0)

				if category == 11 and abilitiesNum >= 2 then

					local secondAbilityAddress = data + IEex_ReadDword(data + 0x64) + 0x38
					local secondAbilityEffectCount = IEex_ReadWord(secondAbilityAddress + 0x1E, 0)

					if secondAbilityEffectCount >= 1 then
						local effectIndex = IEex_ReadWord(secondAbilityAddress + 0x20, 0)
						local effectAddress = data + IEex_ReadDword(data + 0x6A) + effectIndex * 0x30
						if IEex_ReadWord(effectAddress, 0) == 147 then
							local spellResref = IEex_ReadLString(effectAddress + 0x14, 8)
							IEex_SpellToScroll[spellResref:upper()] = resref
						end
					end
				end

				resWrapper:free()

			else
				local message = "[IEex_MapSpellsToScrolls] Critical Error: "..resref..".ITM couldn't be accessed."
				print(message)
				IEex_MessageBox(message)
			end
		end
	end
end

function IEex_LoadInitial2DAs()

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

end

function IEex_WriteDelayedPatches()

	IEex_DisableCodeProtection()

	--------------------
	-- FeatList Hooks --
	--------------------

	IEex_FeatPanelStringHook = function(featID)
		local foundMax = tonumber(IEex_2DAGetAtRelated("B3FEATS", "ID", "MAX", function(id) return tonumber(id) == featID end))
		return foundMax > 1
	end

	IEex_FeatPipsHook = function(featID)
		return tonumber(IEex_2DAGetAtRelated("B3FEATS", "ID", "MAX", function(id) return tonumber(id) == featID	end))
	end

	IEex_GetFeatCountHook = function(sprite, featID)
		return IEex_ReadByte(sprite + 0x78F + (featID - 0x4B), 0)
	end

	IEex_SetFeatCountHook = function(sprite, featID, count)
		IEex_WriteByte(sprite + 0x78F + (featID - 0x4B), count)
	end

	IEex_FeatIncrementableHook = function (sprite, featID)

		local featCount = IEex_ReadByte(sprite + 0x78F + (featID - 0x4B), 0)
		local foundMax = tonumber(IEex_2DAGetAtRelated("B3FEATS", "ID", "MAX", function(id) return tonumber(id) == featID end))
		if featCount >= foundMax then return false end

		local actorID = IEex_GetActorIDShare(sprite)

		local prerequisiteFunc = IEex_2DAGetAtRelated("B3FEATS", "ID", "PREREQUISITE_FUNCTION", function(id) return tonumber(id) == featID end)
		if prerequisiteFunc ~= "*" and prerequisiteFunc ~= "" and not _G[prerequisiteFunc](actorID, featID) then return false end

		local incrementableFunc = IEex_2DAGetAtRelated("B3FEATS", "ID", "INCREMENTABLE_FUNCTION", function(id) return tonumber(id) == featID end)
		if incrementableFunc ~= "*" and incrementableFunc ~= "" and not _G[incrementableFunc](actorID, featID) then return false end

		return true
	end

	IEex_MeetsFeatRequirementsHook = function(sprite, featID)
		local foundFunc = IEex_2DAGetAtRelated("B3FEATS", "ID", "PREREQUISITE_FUNCTION", function(id) return tonumber(id) == featID end)
		if foundFunc ~= "*" and foundFunc ~= "" and not _G[foundFunc](IEex_GetActorIDShare(sprite), featID) then return false end
		return true
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
		!call >IEex_CheckCallError

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
		!call >IEex_CheckCallError

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
		!call >IEex_CheckCallError

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

	---------------------------------------
	-- CGameSprite_MeetsFeatRequirements --
	---------------------------------------

	IEex_WriteByte(0x763206 + 2, IEex_NEW_FEATS_SIZE)

	local meetsFeatRequirementsHookAddress = 0x763270
	local meetsFeatRequirementsHook = IEex_WriteAssemblyAuto({[[

		!cmp_ebp_byte 4A
		!jbe_dword ]], {meetsFeatRequirementsHookAddress + 0x6, 4, 4}, [[

		!push_eax
		!push_ecx
		!push_edx
		!push_ebp
		!push_esi
		!push_edi

		!push_dword ]], {IEex_WriteStringAuto("IEex_MeetsFeatRequirementsHook"), 4}, [[
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
		!call >IEex_CheckCallError

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
	IEex_WriteAssembly(meetsFeatRequirementsHookAddress, {"!jmp_dword", {meetsFeatRequirementsHook, 4, 4}, "!nop"})

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
		!call >IEex_CheckCallError

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
		!call >IEex_CheckCallError

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

	IEex_WriteAssemblyAuto({[[

		$IEex_CheckCallError

		!test_eax_eax
		!jnz_dword >error
		!ret

		@error
		!push_byte 00
		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_tolstring
		!add_esp_byte 0C

		; _lua_pushstring arg ;
		!push_eax

		!push_dword ]], {IEex_WriteStringAuto("print"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		!push_dword *_g_lua
		!call >_lua_pushstring
		!add_esp_byte 08

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError

		; Clear error string off of stack ;
		!push_byte FE
		!push_dword *_g_lua
		!call >_lua_settop
		!add_esp_byte 08

		!mov_eax #1
		!ret

	]]})

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

	---------------------
	-- Stage 1 Startup --
	---------------------

	local stage1StartupHookAddress = 0x59CC58
	local stage1StartupHook = IEex_WriteAssemblyAuto({[[

		!call :53CB60
		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Stage1Startup"), 4}, [[
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
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2
		!jmp_dword ]], {stage1StartupHookAddress + 0x5, 4, 4},

	})
	IEex_WriteAssembly(stage1StartupHookAddress, {"!jmp_dword", {stage1StartupHook, 4, 4}})

	---------------------
	-- Stage 2 Startup --
	---------------------

	local stage2StartupHookAddress = 0x421BA9
	local stage2StartupHook = IEex_WriteAssemblyAuto({[[

		!call :423800
		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Stage2Startup"), 4}, [[
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
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2
		!jmp_dword ]], {stage2StartupHookAddress + 0x5, 4, 4},

	})
	IEex_WriteAssembly(stage2StartupHookAddress, {"!jmp_dword", {stage2StartupHook, 4, 4}})

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
		!call >IEex_CheckCallError

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
		!call >IEex_CheckCallError

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

	IEex_Extern_CSpell_UsableBySprite = function(CSpell, sprite)

		local resref = IEex_ReadLString(CSpell + 0x8, 8)

		local scrollResref = IEex_SpellToScroll[resref]
		local resWrapper = nil
		local scrollError = false

		if scrollResref then
			resWrapper = IEex_DemandRes(scrollResref, "ITM")
			if not resWrapper:isValid() then scrollError = true end
		else
			scrollError = true
		end

		if scrollError then
			local message = "[IEex_Extern_CSpell_UsableBySprite] Critical Error: "..resref..".SPL doesn't have a valid scroll!"
			print(message)
			IEex_MessageBox(message)
			return true
		end

		local itemResRef = resWrapper:getResRef()
		local itemRes = resWrapper:getRes()
		local itemData = resWrapper:getData()

		local kit = IEex_GetActorStat(IEex_GetActorIDShare(sprite), 89)

		local mageKits = bit32.band(kit, 0x7FC0)
		local unusableKits = IEex_Flags({
			bit32.lshift(IEex_ReadByte(itemData + 0x29, 0), 24),
			bit32.lshift(IEex_ReadByte(itemData + 0x2B, 0), 16),
			bit32.lshift(IEex_ReadByte(itemData + 0x2D, 0), 8),
			IEex_ReadByte(itemData + 0x2F, 0)
		})

		resWrapper:free()

		if bit32.band(unusableKits, mageKits) ~= 0x0 then
			-- Mage kit was explicitly excluded
			return false
		end

		return IEex_CanSpriteUseItem(sprite, itemResRef)

	end

	local writableCheckAddress = 0x54AA40
	local writableCheckHook = IEex_WriteAssemblyAuto({[[

		!push_registers_iwd2

		; push sprite ;
		!push_[esp+byte] 1C
		; push CSpell ;
		!push_ecx

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CSpell_UsableBySprite"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; CSpell ;
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; sprite ;
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
		!call >IEex_CheckCallError

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
		!ret_word 04 00

	]]})
	IEex_WriteAssembly(writableCheckAddress, {"!jmp_dword", {writableCheckHook, 4, 4}})

	IEex_EnableCodeProtection()

end

if not IEex_AlreadyInitialized then

	IEex_AlreadyInitialized = true

	IEex_DefineAssemblyFunctions()
	IEex_WritePatches()
	dofile("override/IEex_Cre.lua")
	dofile("override/IEex_Opc.lua")

end
