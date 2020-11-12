
function IEex_Reload()
	dofile("override/IEex_IWD2_State.lua")
	IEex_Helper_SynchronizedBridgeOperation("IEex_ReloadListeners", function()
		IEex_Helper_ReadDataFromBridgeNL("IEex_ReloadListeners")
		IEex_Helper_ClearBridgeNL("IEex_ReloadListeners")
		local limit = #IEex_ReloadListeners
		for i = 1, limit, 1 do
			local funcName = IEex_ReloadListeners[i]
			_G[IEex_ReloadListeners[i]]()
		end
	end)
end

function IEex_AddReloadListener(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_ReloadListeners", function()
		IEex_AppendBridgeNL("IEex_ReloadListeners", funcName)
	end)
end

function IEex_ReaddReloadListener(funcName)
	IEex_AppendBridgeNL("IEex_ReloadListeners", funcName)
end

---------------------
-- Specific States --
---------------------

dofile("override/IEex_Bridge.lua")
dofile("override/IEex_Core_State.lua")

dofile("override/IEex_Action_State.lua")
dofile("override/IEex_Creature_State.lua")
dofile("override/IEex_Opcode_State.lua")
dofile("override/IEex_Gui_State.lua")
dofile("override/IEex_Key_State.lua")

dofile("override/IEex_TRA.lua")
dofile("override/IEex_WEIDU.lua")
dofile("override/IEex_INI.lua")

for module, tf in pairs(IEex_Modules) do
	if tf then
		dofile("override/" .. module .. ".lua")
	end
end

----------------------------
-- Start Memory Interface --
----------------------------

IEex_MemoryManagerStructMeta = {

	["CAIScriptFile"] = {
		["constructors"] = {
			["#default"] = {["address"] = 0x40FDC0},
		},
		["destructor"] = {["address"] = 0x40FEB0},
		["size"] = 0xEE,
	},

	["CString"] = {
		["constructors"] = {
			["fromString"] = {["address"] = 0x7FCC88},
		},
		["destructor"] = {["address"] = 0x7FCC1A},
		["size"] = 0x4,
	},

	["string"] = {
		["constructors"] = {
			["#default"] = function(startPtr, luaString)
				IEex_WriteString(startPtr, luaString)
			end,
		},
		["size"] = function(luaString)
			return #luaString + 1
		end,
	},
}

IEex_MemoryManager = {}
IEex_MemoryManager.__index = IEex_MemoryManager

function IEex_NewMemoryManager(structEntries)
	return IEex_MemoryManager:new(structEntries)
end

function IEex_MemoryManager:init(structEntries)

	local getConstructor = function(structEntry)
		return structEntry.constructor or {}
	end

	local nameToEntry = {}
	local currentOffset = 0

	for _, structEntry in ipairs(structEntries) do

		nameToEntry[structEntry.name] = structEntry
		local structMeta = IEex_MemoryManagerStructMeta[structEntry.struct]
		local size = structMeta.size
		local sizeType = type(size)

		structEntry.offset = currentOffset
		structEntry.structMeta = structMeta

		if sizeType == "function" then
			currentOffset = currentOffset + size(table.unpack(getConstructor(structEntry).luaArgs or {}))
		elseif sizeType == "number" then
			currentOffset = currentOffset + size
		else
			IEex_TracebackMessage("[IEex_MemoryManager] Invalid size type!")
		end
	end

	self.nameToEntry = nameToEntry
	local startAddress = IEex_Malloc(currentOffset)
	self.address = startAddress

	for _, structEntry in ipairs(structEntries) do

		local entryName = structEntry.name
		local offset = structEntry.offset
		local address = startAddress + offset
		structEntry.address = address

		local entryConstructor = getConstructor(structEntry)
		local constructor = structEntry.structMeta.constructors[entryConstructor.variant or "#default"]
		local constructorType = type(constructor)

		if constructorType == "function" then
			constructor(address, table.unpack(entryConstructor.luaArgs or {}))
		elseif constructorType == "table" then
			local args = entryConstructor.args or {}
			local argsToUse = {}
			for i = #args, 1, -1 do
				local arg = args[i]
				local argType = type(arg)
				if argType == "number" then
					table.insert(argsToUse, arg)
				elseif argType == "string" then
					local entry = nameToEntry[arg]
					if not entry then
						IEex_TracebackMessage("[IEex_MemoryManager] Invalid arg name!")
					end
					table.insert(argsToUse, startAddress + entry.offset)
				else
					IEex_TracebackMessage("[IEex_MemoryManager] Invalid arg type!")
				end
			end
			IEex_Call(constructor.address, argsToUse, address, constructor.popSize or 0x0)
		end
	end
end

function IEex_MemoryManager:getAddress(name)
	return self.nameToEntry[name].address
end

function IEex_MemoryManager:getAddresses()
	local nameToAddress = {}
	for name, entry in pairs(self.nameToEntry) do
		nameToAddress[name] = entry.address
	end
	return nameToAddress
end

function IEex_MemoryManager:free()
	for entryName, entry in pairs(self.nameToEntry) do
		local destructor = entry.structMeta.destructor
		if (not entry.noDestruct) and destructor then
			IEex_Call(destructor.address, {}, entry.address, destructor.popSize or 0x0)
		end
	end
	IEex_Free(self.address)
end

function IEex_MemoryManager:new(structEntries)
	local o = {}
	setmetatable(o, self)
	o:init(structEntries)
	return o
end

----------------------------
-- End Memory Interface --
----------------------------

-----------------------------------
-- Common Engine Structures Util --
-----------------------------------

function IEex_CString_Set(CString, newString)
	local newStringMem = IEex_WriteStringAuto(newString)
	-- CString_operator_equ_<char_const_ptr>
	IEex_Call(0x7FCD57, {newStringMem}, CString, 0x0)
	IEex_Free(newStringMem)
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

IEex_CasterClassToType = {
	[2] = 1,
	[3] = 2,
	[4] = 3,
	[7] = 4,
	[8] = 5,
	[10] = 6,
	[11] = 7,
}
function IEex_SetSpellInfo(actorID, casterType, spellLevel, resref, memorizedCount, castableCount)
	if not IEex_IsSprite(actorID, true) then return end
	local memMod = memorizedCount
	local castMod = castableCount

	local typeInfo = IEex_FetchSpellInfo(actorID, {casterType})
	local levelFill = typeInfo and typeInfo[casterType][spellLevel][3] or nil
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
	if not IEex_IsSprite(actorID, true) then return end
	if casterType < 1 or casterType > 11 then
		local message = "[IEex_AlterSpellInfo] Critical Caller Error: casterType out of bounds - got "..casterType.."; valid range includes [1,11]"
		print(message)
		IEex_MessageBox(message)
		return
	end
	local isSorcererType = false
	if casterType == 1 or casterType == 6 then
		isSorcererType = true
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
	local sorcererCastableCount = IEex_ReadDword(address + 0x18)
	if isSorcererType then
		sorcererCastableCount = sorcererCastableCount + castableMod
		if sorcererCastableCount < 0 then
			sorcererCastableCount = 0
		end
		IEex_WriteDword(address + 0x18, sorcererCastableCount)
	end
	local id = list[resref]
	if not id and not isSorcererType then
		local message = "[IEex_AlterSpellInfo] Critical Caller Error: resref \""..resref.."\" not present in corresponding master spell-list 2DA"
		print(message)
		--IEex_MessageBox(message)
		return
	end
	if not isSorcererType then
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

		IEex_Free(ptrMem)
	else
		local currentEntryBase = IEex_ReadDword(address + 0x4)
		local pEndEntry = IEex_ReadDword(address + 0x8)
		while currentEntryBase ~= pEndEntry do
			local castableCount = IEex_ReadDword(currentEntryBase + 0x8)
			castableCount = castableCount + castableMod
			if castableCount < 0 then
				castableCount = 0
			end
			IEex_WriteDword(currentEntryBase + 0x8, castableCount)
			currentEntryBase = currentEntryBase + 0x10
		end
	end
	if casterType <= 8 then
		local maxActiveLevelAddress = baseTypeAddress + 0xFC
		if IEex_ReadDword(maxActiveLevelAddress) < spellLevel and (memorizeMod > 0 or castableMod > 0) then
			IEex_WriteDword(maxActiveLevelAddress, spellLevel)
		end
	end

end

function IEex_FetchSpellInfo(actorID, casterTypes)
	if not IEex_IsSprite(actorID, true) then return {} end
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
			table.insert(typeFill, {IEex_ReadDword(currentLevelBase + 0x14), IEex_ReadDword(currentLevelBase + 0x18), levelFill})
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

function IEex_Debug_GiveAllWizardSpells()

	local actorID = IEex_GetActorIDSelected()
	if not IEex_IsSprite(actorID) then return end

	local base = "SPWI"

	for i = 100, 999, 1 do
		local resref = base..string.format("%03d", i)
		local level = math.floor(i / 100)
		IEex_SetSpellInfo(actorID, IEex_CasterType.Wizard, level, resref, 999, 999)
	end
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

	local IEex_CustomResDemand = {
		[0x3EA] = 0x401400, -- CHU
	}

	local extensionType = IEex_FileExtensionToType(extension)

	local resrefMem = IEex_Malloc(0x8)
	IEex_WriteLString(resrefMem, resref, 8)
	-- dimmGetResObject
	local pRes = IEex_Call(0x786DF0, {1, extensionType, resrefMem}, IEex_GetResourceManager(), 0x0)
	IEex_Free(resrefMem)

	if pRes ~= 0x0 then
		-- CRes_Load
		IEex_Call(0x77E610, {}, pRes, 0x0)
		-- CRes_Demand
		IEex_Call(IEex_CustomResDemand[extensionType] or 0x77E390, {}, pRes, 0x0)
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

function IEex_SetActorScript(actorID, level, resref)
	if not IEex_IsSprite(actorID, true) then return end
	IEex_ApplyEffectToActor(actorID, {
		["opcode"] = 82,
		["target"] = 1,
		["parameter2"] = level,
		["timing"] = 9,
		["resource"] = resref,
		["source_id"] = actorID,
	})
end

-- Directly applies an effect to an actor based on the args table.
function IEex_ApplyEffectToActor(actorID, args)
	local share = IEex_GetActorShare(actorID)
	if share <= 0 then return end
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

	-- CGameSprite::AddEffect(CGameSprite *this, CGameEffect *pEffect, char list, int noSave, int immediateResolve)
	IEex_Call(IEex_ReadDword(IEex_ReadDword(share) + 0x78), {1, 0, 1, CGameEffect}, share, 0x0)
end

function IEex_ApplyResref(resref, actorID)
	if not IEex_IsSprite(actorID, true) then return end
	local share = IEex_GetActorShare(actorID)

	local resrefMem = IEex_Malloc(#resref + 1)
	IEex_WriteString(resrefMem, resref)

	IEex_Call(IEex_Label("IEex_ApplyResref"), {resrefMem, share}, nil, 0x0)
	IEex_Free(resrefMem)

end

function IEex_SetActorName(actorID, strref)
	if not IEex_IsSprite(actorID, true) then return end
	local share = IEex_GetActorShare(actorID)
	IEex_WriteDword(share + 0x5A4, strref)
end

function IEex_SetActorTooltip(actorID, strref)
	if not IEex_IsSprite(actorID, true) then return end
	local share = IEex_GetActorShare(actorID)
	IEex_WriteDword(share + 0x5A8, strref)
end

-------------------
-- Actor Details --
-------------------

function IEex_CheckActorLOS(actorID, pointX, pointY)
	local share = IEex_GetActorShare(actorID)
	if share <= 0 then return false end
	local area = IEex_ReadDword(share + 0x12)

	local actorX, actorY = IEex_GetActorLocation(actorID)
	local points = IEex_Malloc(0x10)
	IEex_WriteDword(points + 0x0, actorX)
	IEex_WriteDword(points + 0x4, actorY)
	IEex_WriteDword(points + 0x8, pointX)
	IEex_WriteDword(points + 0xC, pointY)

	local terrainTable = IEex_Call(IEex_ReadDword(IEex_ReadDword(share) + 0x9C), {}, share, 0x0)
	local toReturn = IEex_Call(0x46A820, {1, terrainTable, points + 0x8, points}, area, 0x0)

	IEex_UndoActorShare(actorID)
	IEex_Free(points)
	return toReturn == 1
end

function IEex_CheckActorLOSObject(actorID, targetID)
	local targetX, targetY = IEex_GetActorLocation(targetID)
	return IEex_CheckActorLOS(actorID, targetX, targetY)
end

function IEex_GetActorName(actorID)
	-- CGameSprite::GetName()
	if not IEex_IsSprite(actorID, true) then return "" end
	local CString = IEex_Call(0x71F760, {}, IEex_GetActorShare(actorID), 0x0)
	return IEex_ReadString(IEex_ReadDword(CString))
end

function IEex_GetActorTooltip(actorID)
	if not IEex_IsSprite(actorID, true) then return "" end
	local share = IEex_GetActorShare(actorID)
	local nameStrref = IEex_ReadDword(share + 0x5A8)
	return IEex_FetchString(nameStrref)
end

function IEex_GetActorArmorClass(actorID)
	if not IEex_IsSprite(actorID, true) then return {0, 0, 0, 0, 0} end
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
	if not IEex_IsSprite(actorID, true) then return 0 end
	local share = IEex_GetActorShare(actorID)
	local bAllowEffectListCall = IEex_ReadDword(share + 0x72A4) == 1
	local activeStats = share + (bAllowEffectListCall and 0x920 or 0x1778)
	return IEex_Call(0x446DD0, {statID}, activeStats, 0x0)
end

function IEex_GetActorSpellState(actorID, spellStateID)
	if not IEex_IsSprite(actorID, true) then return false end
	local bitsetStruct = IEex_Malloc(0x8)
	local spellStateStart = IEex_Call(0x4531A0, {}, IEex_GetActorShare(actorID), 0x0) + 0xEC
	IEex_Call(0x45E380, {spellStateID, bitsetStruct}, spellStateStart, 0x0)
	local spellState = bit32.extract(IEex_Call(0x45E390, {}, bitsetStruct, 0x0), 0, 0x8)
	IEex_Free(bitsetStruct)
	return spellState == 1
end

function IEex_GetActorLocation(actorID)
	local share = IEex_GetActorShare(actorID)
	if share <= 0 then return -1, -1 end
	return IEex_ReadDword(share + 0x6), IEex_ReadDword(share + 0xA)
end

function IEex_GetActorDestination(actorID)
	if not IEex_IsSprite(actorID, true) then return -1, -1 end
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadDword(share + 0x556E), IEex_ReadDword(share + 0x5572)
end

-- Returns the creature the actor is targeting with their current action.
function IEex_GetActorTarget(actorID)
	if not IEex_IsSprite(actorID, true) then return -1, -1 end
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadDword(share + 0x4BE)
end

-- Returns the coordinates of the point the actor is targeting with their
--  current action.
function IEex_GetActorTargetPoint(actorID)
	if not IEex_IsSprite(actorID, true) then return -1, -1 end
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
	if not IEex_IsSprite(actorID, true) then return 0 end
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadDword(share + 0x4BE)
end

-- Returns the actor's direction (from DIR.IDS).
function IEex_GetActorDirection(actorID)
	if not IEex_IsSprite(actorID, true) then return 0 end
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
	if not IEex_IsSprite(actorID, true) then return end
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

function IEex_GetDistanceIsometric(x1, y1, x2, y2)
	return math.floor(((x1 - x2) ^ 2 + (4/3 * (y1 - y2)) ^ 2) ^ .5)
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
	if ex_classid_listspll[casterClass] == nil and ex_listspll[spellRES] ~= nil then
		for k, v in ipairs(ex_listspll[spellRES]) do
			if v > 0 and (classSpellLevel == 0 or v < classSpellLevel) then
				classSpellLevel = v
			end
		end
	end
	return classSpellLevel
end

function IEex_CompareActorAllegiances(actorID1, actorID2)
	if not IEex_IsSprite(actorID1, true) or not IEex_IsSprite(actorID2, true) then return -1 end
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

function IEex_IsActorDead(actorID)
	local share = IEex_GetActorShare(actorID)
	return bit32.band(IEex_ReadDword(share + 0x5BC), 0xFC0) ~= 0x0
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

function IEex_Eval(actionString, portraitIndex)

	local manager = IEex_NewMemoryManager({
		{
			["name"] = "scriptFile",
			["struct"] = "CAIScriptFile",
		},
		{
			["name"] = "actionStringChars",
			["struct"] = "string",
			["constructor"] = {
				["luaArgs"] = {actionString},
			},
		},
		{
			["name"] = "actionCString",
			["struct"] = "CString",
			["constructor"] = {
				["variant"] = "fromString",
				["args"] = {"actionStringChars"},
			},
			["noDestruct"] = true,
		},
	})

	local CAIScriptFile = manager:getAddress("scriptFile")
	local actionCString = manager:getAddress("actionCString")

	-- CAIScriptFile_ParseResponseString
	IEex_Call(0x410120, {IEex_ReadDword(actionCString)}, CAIScriptFile, 0x0)

	-- m_errors
	local errors = IEex_ReadString(IEex_ReadDword(CAIScriptFile + 0x16))
	if errors == "" then

		local actorID = -1
		if portraitIndex then
			actorID = IEex_GetActorIDPortrait(portraitIndex)
		else
			actorID = IEex_GetActorIDCursor()
		end

		if actorID == -1 then
			-- pGame->m_gameAreas[pGame->m_visibleArea]->m_nAIIndex
			local m_pObjectGame = IEex_GetGameData()
			local m_visibleArea = IEex_ReadByte(m_pObjectGame + 0x37E0, 0)
			local CGameArea = IEex_ReadDword(m_pObjectGame + m_visibleArea * 0x4 + 0x37E2)
			actorID = IEex_ReadDword(CGameArea + 0x41A)
		end

		local share = IEex_GetActorShare(actorID)
		local CGameAIBase_InsertAction = IEex_ReadDword(IEex_ReadDword(share) + 0x88)

		local m_actionList = IEex_ReadDword(CAIScriptFile + 0x12) + 0x8
		IEex_IterateCPtrList(m_actionList, function(CAIAction)
			IEex_Call(CGameAIBase_InsertAction, {CAIAction}, share, 0x0)
		end)
	else
		IEex_DisplayString("Action Errors:: "..errors)
	end

	manager:free()

end

function IEex_CreateCreature(resref)
	local mem = IEex_Malloc(0xC)
	IEex_WriteLString(mem, resref, 8)
	local resrefCStringPtr = mem + 0x8
	-- CResRef_GetResRefStr
	IEex_Call(0x78AA30, {resrefCStringPtr}, mem, 0x0)
	-- This is usually used with hardcoded resrefs by CtrlAltDelete:JeffKAttacks() and JeffKDefends()
	IEex_Call(0x4EC390, {IEex_ReadDword(resrefCStringPtr)}, nil, 0x0)
	IEex_Free(mem)
end

function IEex_GetCInfinity()
	local m_pObjectGame = IEex_GetGameData()
	local m_visibleArea = IEex_ReadByte(m_pObjectGame + 0x37E0, 0)
	local CGameArea = IEex_ReadDword(m_pObjectGame + m_visibleArea * 0x4 + 0x37E2)
	return CGameArea + 0x4CC
end

function IEex_GetGameData()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local m_pObjectGame = IEex_ReadDword(g_pBaldurChitin + 0x1C54)
	return m_pObjectGame
end

function IEex_GetGameTick()
	return IEex_ReadDword(IEex_GetGameData() + 0x1B78)
end

-- Returns a number between 1 (Very Easy) and 5 (Very Hard/Insane or Heart of Fury Mode)
function IEex_GetGameDifficulty()
	return IEex_ReadByte(IEex_GetGameData() + 0x4456, 0x0)
end

function IEex_GetActiveEngine()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	return IEex_ReadDword(g_pBaldurChitin + 0x3C4)
end

function IEex_GetEngineWorld()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	return IEex_ReadDword(g_pBaldurChitin + 0x1C88)
end

function IEex_GetEngineSpell()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	return IEex_ReadDword(g_pBaldurChitin + 0x1C80)
end

function IEex_IsGamePaused()
	return (bit32.band(IEex_ReadByte(IEex_GetGameData() + 0x48E4, 0x0), 0x1) > 0)
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

-- Like IEex_DisplayString, but can print nil values, booleans, and entire tables.
function IEex_DS(string)
	IEex_DisplayString(IEex_ToString(string))
end

function IEex_ToString(string)
	if string == nil then
		return "nil"
	else
		local stringType = type(string)
		if stringType == "boolean" then
			if string then
				return "true"
			else
				return "false"
			end
		elseif stringType == "function" then
			return "function()"
		elseif stringType == "table" then
			local tableString = "{"
			if string[1] == nil then
				for k, v in pairs(string) do
					tableString = tableString .. "[" .. IEex_ToString(k) .. "] = " .. IEex_ToString(v) .. ", "
				end
			else
				for k, v in ipairs(string) do
					tableString = tableString .. IEex_ToString(v) .. ", "
				end
			end
			tableString = tableString .. "}"
			return tableString
		elseif stringType == "string" then
			return "\"" .. string .. "\""
		else
			return string
		end

	end
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
			IEex_TracebackMessage("IEex CRITICAL ERROR - Couldn't find "..arrayName..".2DA!")
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

function IEex_GetAllActorIDSelected()
	local ids = {}
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local m_pObjectGame = IEex_ReadDword(g_pBaldurChitin + 0x1C54)
	local CPtrList = m_pObjectGame + 0x388A
	IEex_IterateCPtrList(CPtrList, function(actorID)
		table.insert(ids, actorID)
	end)
	return ids
end

function IEex_IterateIDs(m_gameArea, requiredObjectType, includeLiving, includeDead, func)
	if m_gameArea <= 0x0 then return end
	if includeLiving then
		local areaList = IEex_ReadDword(m_gameArea + 0x996)
		while areaList ~= 0x0 do
			local areaListID = IEex_ReadDword(areaList + 0x8)
			local share = IEex_GetActorShare(areaListID)
			if share > 0 then
				local objectType = IEex_ReadByte(share + 0x4, 0)
				if objectType == requiredObjectType or requiredObjectType == -1 then
					func(areaListID)
				end
			end
			areaList = IEex_ReadDword(areaList)
		end
	end
	if includeDead then
		local areaList = IEex_ReadDword(m_gameArea + 0x9B2)
		while areaList ~= 0x0 do
			local areaListID = IEex_ReadDword(areaList + 0x8)
			local share = IEex_GetActorShare(areaListID)
			if share > 0 then
				local objectType = IEex_ReadByte(share + 0x4, 0)
				if objectType == requiredObjectType or requiredObjectType == -1 then
					func(areaListID)
				end
			end
			areaList = IEex_ReadDword(areaList)
		end
	end
end

function IEex_GetIDArea(actorID, requiredObjectType, includeLiving, includeDead)
	local ids = {}
	local actorShare = IEex_GetActorShare(actorID)
	if actorShare <= 0 then return ids end
	local m_pArea = IEex_ReadDword(actorShare + 0x12)
	IEex_IterateIDs(m_pArea, requiredObjectType, includeLiving, includeDead, function(areaActorID)
		table.insert(ids, areaActorID)
	end)
	return ids
end

function IEex_IterateFireballs(projectileID, func)
	IEex_IterateIDs(IEex_ReadDword(IEex_GetActorShare(IEex_GetActorIDPortrait(0)) + 0x12), 0, true, true, function(areaListID)
		local share = IEex_GetActorShare(areaListID)
		if IEex_ReadWord(share + 0x6E, 0x0) == projectileID then
			func(share)
		end
	end)
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

function IEex_UndoActorShare(actorID)
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local m_pObjectGame = IEex_ReadDword(g_pBaldurChitin + 0x1C54)
	local CGameObjectArray = m_pObjectGame + 0x372C
	IEex_Call(0x599E70, {-1, 0, actorID}, CGameObjectArray, 0x0)
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

function Prereq_ExtendSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local extendSpellFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_EXTEND_SPELL"], 0x0)
	if extendSpellFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 6 or IEex_ReadByte(creatureData + 0x629, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 7 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 7 or IEex_ReadByte(creatureData + 0x630, 0x0) > 5 or IEex_ReadByte(creatureData + 0x631, 0x0) > 4)
	elseif extendSpellFeatCount == 2 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 12 or IEex_ReadByte(creatureData + 0x629, 0x0) > 8 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 8 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 13 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 13 or IEex_ReadByte(creatureData + 0x630, 0x0) > 9 or IEex_ReadByte(creatureData + 0x631, 0x0) > 8)
	elseif extendSpellFeatCount == 3 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 19 or IEex_ReadByte(creatureData + 0x629, 0x0) > 12 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 12 or IEex_ReadByte(creatureData + 0x630, 0x0) > 13 or IEex_ReadByte(creatureData + 0x631, 0x0) > 12)
	elseif extendSpellFeatCount == 4 then
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
	return (IEex_ReadByte(creatureData + 0x62F, 0x0) > 4)
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

function Prereq_MaximizeSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local maximizeSpellFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MAXIMIZE_SPELL"], 0x0)
	if maximizeSpellFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 19 or IEex_ReadByte(creatureData + 0x629, 0x0) > 12 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 12 or IEex_ReadByte(creatureData + 0x630, 0x0) > 13 or IEex_ReadByte(creatureData + 0x631, 0x0) > 12)
	elseif maximizeSpellFeatCount == 2 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 23 or IEex_ReadByte(creatureData + 0x629, 0x0) > 14 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 14 or IEex_ReadByte(creatureData + 0x630, 0x0) > 15 or IEex_ReadByte(creatureData + 0x631, 0x0) > 14)
	elseif maximizeSpellFeatCount == 3 then
		return (IEex_ReadByte(creatureData + 0x629, 0x0) > 16 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 16 or IEex_ReadByte(creatureData + 0x630, 0x0) > 17 or IEex_ReadByte(creatureData + 0x631, 0x0) > 16)
	else
		return true
	end
end

function Feats_Mobility(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x805, 0x0) >= 13 and bit32.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0)
end

function Feats_NaturalSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x62A, 0x0) > 4 and IEex_ReadByte(creatureData + 0x807, 0x0) >= 13)
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

function Prereq_QuickenSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local quickenSpellFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_QUICKEN_SPELL"], 0x0)
	if quickenSpellFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 12 or IEex_ReadByte(creatureData + 0x629, 0x0) > 8 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 8 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 13 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 13 or IEex_ReadByte(creatureData + 0x630, 0x0) > 9 or IEex_ReadByte(creatureData + 0x631, 0x0) > 8)
	elseif quickenSpellFeatCount == 2 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 15 or IEex_ReadByte(creatureData + 0x629, 0x0) > 10 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 10 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 16 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 16 or IEex_ReadByte(creatureData + 0x630, 0x0) > 11 or IEex_ReadByte(creatureData + 0x631, 0x0) > 10)
	elseif quickenSpellFeatCount == 3 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 19 or IEex_ReadByte(creatureData + 0x629, 0x0) > 12 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 12 or IEex_ReadByte(creatureData + 0x630, 0x0) > 13 or IEex_ReadByte(creatureData + 0x631, 0x0) > 12)
	elseif quickenSpellFeatCount == 4 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 23 or IEex_ReadByte(creatureData + 0x629, 0x0) > 14 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 14 or IEex_ReadByte(creatureData + 0x630, 0x0) > 15 or IEex_ReadByte(creatureData + 0x631, 0x0) > 14)
	elseif quickenSpellFeatCount == 5 then
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

function Prereq_SafeSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local safeSpellFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SAFE_SPELL"], 0x0)
	if safeSpellFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 6 or IEex_ReadByte(creatureData + 0x629, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 7 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 7 or IEex_ReadByte(creatureData + 0x630, 0x0) > 5 or IEex_ReadByte(creatureData + 0x631, 0x0) > 4)
	elseif safeSpellFeatCount == 2 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 12 or IEex_ReadByte(creatureData + 0x629, 0x0) > 8 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 8 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 13 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 13 or IEex_ReadByte(creatureData + 0x630, 0x0) > 9 or IEex_ReadByte(creatureData + 0x631, 0x0) > 8)
	elseif safeSpellFeatCount == 3 then
		return (IEex_ReadByte(creatureData + 0x628, 0x0) > 19 or IEex_ReadByte(creatureData + 0x629, 0x0) > 12 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 12 or IEex_ReadByte(creatureData + 0x630, 0x0) > 13 or IEex_ReadByte(creatureData + 0x631, 0x0) > 12)
	elseif safeSpellFeatCount == 4 then
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

function Prereq_ShieldFocus(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	if bit32.band(IEex_ReadDword(creatureData + 0x760), 0x100000) == 0 then
		return false
	else
		local shieldFocusFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SHIELD_FOCUS"], 0x0)
		return (shieldFocusFeatCount <= 1 or IEex_ReadByte(creatureData + 0x62B, 0x0) > 3)
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

function Prereq_WhirlwindAttack(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local whirlwindAttackFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_WHIRLWIND_ATTACK"], 0x0)
	if whirlwindAttackFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x803, 0x0) >= 13 and IEex_ReadByte(creatureData + 0x805, 0x0) >= 13 and bit32.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0 and bit32.band(IEex_ReadDword(creatureData + 0x75C), 0x80000) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MOBILITY"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SPRING_ATTACK"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 4)
	elseif whirlwindAttackFeatCount == 2 then
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

ex_search_previous = {}
ex_search_exclude = {}
function IEex_Search_Change(read_size, search_start, search_length, noise_reduction)
	for i = 0, search_length, 1 do
		local previous = ex_search_previous["" .. i]
		local current = IEex_ReadSignedByte(search_start + i, 0x0)
		if read_size == 2 then
			current = IEex_ReadSignedWord(search_start + i, 0x0)
		elseif read_size == 4 then
			current = IEex_ReadDword(search_start + i)
		end
		if previous ~= nil and previous ~= current and ex_search_exclude["" .. i] == nil then
			IEex_DisplayString(IEex_ToHex(i, 0, true) .. ": Changed from " .. previous .. " to " .. current)
			if noise_reduction == true then
				ex_search_exclude["" .. i] = true
			end
		end
		ex_search_previous["" .. i] = current
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

function IEex_Search(search_target, search_start, search_length, noise_reduction)
	if type(search_target) == "string" then
		for i = 0, search_length, 1 do
			if IEex_ReadLString(search_start + i, 0x8) == search_target and ex_search_exclude["" .. i] == nil then
				IEex_DisplayString("Match found for " .. search_target .. " at offset " .. i)
				if noise_reduction == true then
					ex_search_exclude["" .. i] = true
				end
			end
		end
	else
		for i = 0, search_length, 1 do
			if ex_search_exclude["" .. i] == nil then
				if IEex_ReadDword(search_start + i) == search_target then
					IEex_DisplayString("Match found for " .. search_target .. " at offset " .. i .. " (4 bytes)")
				elseif search_target < 65536 and IEex_ReadWord(search_start + i, 0x0) == search_target then
					IEex_DisplayString("Match found for " .. search_target .. " at offset " .. i .. " (2 bytes)")
				elseif search_target < 256 and IEex_ReadByte(search_start + i, 0x0) == search_target then
					IEex_DisplayString("Match found for " .. search_target .. " at offset " .. i .. " (1 byte)")
				end
				if noise_reduction == true then
					ex_search_exclude["" .. i] = true
				end
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
ex_damage_source_spell = {["EFFAS1"] = "SPWI217", ["EFFAS2"] = "SPWI217", ["EFFCL"] = "SPPR302", ["EFFCT1"] = "SPWI117", ["EFFDA3"] = "SPWI228", ["EFFFS1"] = "SPWI427", ["EFFFS2"] = "SPWI426", ["EFFIK"] = "SPWI122", ["EFFMB1"] = "SPPR318", ["EFFMB2"] = "SPPR318", ["EFFMT1"] = "SPPR322", ["EFFPB1"] = "SPWI521", ["EFFPB2"] = "SPWI521", ["EFFS1"] = "SPPR113", ["EFFS2"] = "SPPR113", ["EFFS3"] = "SPPR113", ["EFFSC"] = "SPPR523", ["EFFSOF1"] = "SPWI511", ["EFFSOF2"] = "SPWI511", ["EFFSR1"] = "SPPR707", ["EFFSR2"] = "SPPR707", ["EFFSSO1"] = "SPPR608", ["EFFSSO2"] = "SPPR608", ["EFFSSO3"] = "SPPR608", ["EFFSSS1"] = "SPWI220", ["EFFSSS2"] = "SPWI220", ["EFFVS1"] = "SPWI424", ["EFFVS2"] = "SPWI424", ["EFFVS3"] = "SPWI424", ["EFFWOM1"] = "SPPR423", ["EFFWOM2"] = "SPPR423", ["EFFHW15"] = "SPWI805", ["EFFHW16"] = "SPWI805", ["EFFHW17"] = "SPWI805", ["EFFHW18"] = "SPWI805", ["EFFHW19"] = "SPWI805", ["EFFHW20"] = "SPWI805", ["EFFHW21"] = "SPWI805", ["EFFHW22"] = "SPWI805", ["EFFHW23"] = "SPWI805", ["EFFHW24"] = "SPWI805", ["EFFHW25"] = "SPWI805", ["EFFWT15"] = "SPWI805", ["EFFWT16"] = "SPWI805", ["EFFWT17"] = "SPWI805", ["EFFWT18"] = "SPWI805", ["EFFWT19"] = "SPWI805", ["EFFWT20"] = "SPWI805", ["EFFWT21"] = "SPWI805", ["EFFWT22"] = "SPWI805", ["EFFWT23"] = "SPWI805", ["EFFWT24"] = "SPWI805", ["EFFWT25"] = "SPWI805", ["USWI422D"] = "SPWI422", ["USWI452D"] = "USWI452", ["USWI652D"] = "USWI652", ["USWI755D"] = "USWI755", ["USWI954F"] = "USWI954", ["USDESTRU"] = "SPPR717", }
ex_feat_id_offset = {[18] = 0x78D, [38] = 0x777, [39] = 0x774, [40] = 0x779, [41] = 0x77D, [42] = 0x77B, [43] = 0x77E, [44] = 0x77A, [53] = 0x775, [54] = 0x778, [55] = 0x776, [56] = 0x77C, [57] = 0x77F}
ex_damage_multiplier_type = {[0] = 9, [0x10000] = 4, [0x20000] = 2, [0x40000] = 3, [0x80000] = 1, [0x100000] = 8, [0x200000] = 6, [0x400000] = 5, [0x800000] = 10, [0x1000000] = 7, [0x2000000] = 1, [0x4000000] = 2, [0x8000000] = 9, [0x10000000] = 5}
ex_damage_resistance_stat = {[0] = 22, [0x10000] = 17, [0x20000] = 15, [0x40000] = 16, [0x80000] = 14, [0x100000] = 23, [0x200000] = 74, [0x400000] = 73, [0x800000] = 24, [0x1000000] = 21, [0x2000000] = 19, [0x4000000] = 20, [0x8000000] = 22, [0x10000000] = 73}
function EXDAMAGE(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceData = IEex_GetActorShare(sourceID)
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
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	local sourceSpell = ex_damage_source_spell[parent_resource]
	if sourceSpell == nil then
		sourceSpell = parent_resource
	end
	local classSpellLevel = 0
	if IEex_IsSprite(sourceID, true) then
		classSpellLevel = IEex_GetClassSpellLevel(sourceID, casterClass, sourceSpell)
	end
	savebonus = savebonus + classSpellLevel
	local trueschool = 0
	if ex_trueschool[sourceSpell] ~= nil then
		trueschool = ex_trueschool[sourceSpell]
	end
	if trueschool > 0 then
		local sourceKit = IEex_GetActorStat(sourceID, 89)
		if bit32.band(sourceKit, 0x4000) > 0 then
			savebonus = savebonus + 1
		elseif ex_spell_focus_component_installed then
			if trueschool == 1 and bit32.band(sourceKit, 0x40) > 0 or trueschool == 2 and bit32.band(sourceKit, 0x80) > 0 or trueschool == 3 and bit32.band(sourceKit, 0x100) > 0 or trueschool == 5 and bit32.band(sourceKit, 0x400) > 0 then
				savebonus = savebonus + 2
			elseif trueschool == 1 and bit32.band(sourceKit, 0x2000) > 0 or trueschool == 2 and bit32.band(sourceKit, 0x800) > 0 or trueschool == 3 and bit32.band(sourceKit, 0x1000) > 0 or trueschool == 5 and bit32.band(sourceKit, 0x200) > 0 then
				savebonus = savebonus - 2
			end
		end
	end
	local rogueLevel = 0
	local isSneakAttack = false
	local isTrueBackstab = false
	local hasProtection = false
	if IEex_IsSprite(sourceID, true) then
		if bit32.band(savingthrow, 0x40) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x784, 0x0) * 2
		end
		if bit32.band(savingthrow, 0x80) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x785, 0x0) * 2
		end
		if bit32.band(savingthrow, 0x100) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x786, 0x0) * 2
		end
		if bit32.band(savingthrow, 0x200) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x787, 0x0) * 2
		end
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
	if IEex_IsSprite(sourceID, true) and (bit32.band(savingthrow, 0x20000) > 0 or bit32.band(savingthrow, 0x40000) > 0) then
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
	elseif IEex_IsSprite(sourceID, true) and bit32.band(savingthrow, 0x800000) > 0 then
		luck = IEex_GetActorStat(sourceID, 32)
		if IEex_GetActorSpellState(sourceID, 64) then
			luck = 127
		end
	else
		if IEex_GetActorStat(targetID, 32) ~= 0 then
			luck = 0 - IEex_GetActorStat(targetID, 32)
		end
		if IEex_IsSprite(sourceID, true) and IEex_GetActorSpellState(sourceID, 238) then
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
	if IEex_IsSprite(sourceID, true) then
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
			if saveBonusStat == 120 or ex_damage_source_spell[parent_resource] ~= nil then
				if casterClass == 11 then
					saveBonusStat = 38
				elseif casterClass == 3 or casterClass == 4 or casterClass == 7 or casterClass == 8 then
					saveBonusStat = 39
				elseif casterClass == 2 or casterClass == 10 then
					saveBonusStat = 42
				else
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
				end
				saveBonusStatValue = IEex_GetActorStat(sourceID, saveBonusStat)
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
		if IEex_GetActorSpellState(sourceID, 242) then
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 242 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if thespecial == trueschool or thespecial == -1 or ((thespecial == 4 or thespecial == 5) and bit32.band(savingthrow, 0x40) > 0) or ((thespecial == 2 or thespecial == 6) and bit32.band(savingthrow, 0x80) > 0) or ((thespecial == 3 or thespecial == 7) and bit32.band(savingthrow, 0x100) > 0) or ((thespecial == 1 or thespecial == 8) and bit32.band(savingthrow, 0x200) > 0) then
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
	if IEex_GetActorSpellState(targetID, 243) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 242 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if thespecial == trueschool or thespecial == -1 or ((thespecial == 4 or thespecial == 5) and bit32.band(savingthrow, 0x40) > 0) or ((thespecial == 2 or thespecial == 6) and bit32.band(savingthrow, 0x80) > 0) or ((thespecial == 3 or thespecial == 7) and bit32.band(savingthrow, 0x100) > 0) or ((thespecial == 1 or thespecial == 8) and bit32.band(savingthrow, 0x200) > 0) then
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
	local damageBlocked = false
	local damageAbsorbed = false
	if IEex_GetActorSpellState(targetID, 214) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if theopcode == 288 and theparameter2 == 214 and (theparameter1 == IEex_ReadWord(effectData + 0x1E, 0x0) or (theresource == parent_resource and (theresource ~= "" or bit32.band(thesavingthrow, 0x20000) > 0))) then
				damageBlocked = true
				if bit32.band(thesavingthrow, 0x10000) > 0 then
					damageAbsorbed = true
				end
			end
		end)
	end
	if IEex_IsSprite(sourceID, true) and bit32.band(savingthrow, 0x10000) > 0 then
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
		elseif damageBlocked == false then
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
		if (bit32.band(savingthrow, 0x200000) > 0 or bit32.band(savingthrow, 0x400000) > 0) and damageBlocked == false then
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
	["savingthrow"] = newSavingThrow,
	["savebonus"] = savebonus,
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
	if IEex_IsSprite(sourceID, true) and isSneakAttack then
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
	if IEex_IsSprite(sourceID, true) then
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
[1] = {[21] = "USRAGE3", [25] = "USRAGE4", [29] = "USRAGE5"}, -- Barbarian Rage
[2] = {[0] = "USMAXIM1", [12] = "USMAXIM2"}, -- Maximized Attacks
[3] = {[0] = "USDVSH01", [14] = "USDVSH02", [16] = "USDVSH03", [18] = "USDVSH04", [20] = "USDVSH05", [22] = "USDVSH06", [24] = "USDVSH07", [26] = "USDVSH08", [28] = "USDVSH09", [30] = "USDVSH10", [32] = "USDVSH11", [34] = "USDVSH12", [36] = "USDVSH13", [38] = "USDVSH14", [40] = "USDVSH15"}, -- Divine Shield
[4] = {[0] = "USW01L01", [10] = "USW01L10", [15] = "USW01L15", [20] = "USW01L20", [25] = "USW01L25", [30] = "USW01L30"}, -- Wild Shape: Winter Wolf
[5] = {[0] = "USW02L01", [9] = "USW02L09", [10] = "USW02L10", [13] = "USW02L13", [16] = "USW02L16", [19] = "USW02L19", [22] = "USW02L22", [24] = "USW02L24", [25] = "USW02L25", [28] = "USW02L28"}, -- Wild Shape: Polar Bear
[6] = {[0] = "USW03L01", [12] = "USW03L12", [15] = "USW03L15", [16] = "USW03L16", [18] = "USW03L18", [21] = "USW03L21", [24] = "USW03L24", [27] = "USW03L27", [30] = "USW03L30"}, -- Wild Shape: Giant Viper
[7] = {[0] = "USW04L01", [16] = "USW04L16", [21] = "USW04L21", [24] = "USW04L24", [26] = "USW04L26"}, -- Wild Shape: Salamander
[8] = {[0] = "USW05L01", [16] = "USW05L16", [21] = "USW05L21", [24] = "USW05L24", [26] = "USW05L26"}, -- Wild Shape: Frost Salamander
[9] = {[0] = "USW06L01", [16] = "USW06L16", [19] = "USW06L19", [22] = "USW06L22", [24] = "USW06L24", [25] = "USW06L25", [28] = "USW06L28"}, -- Wild Shape: Shambling Mound
[10] = {[0] = "USW07L01", [16] = "USW07L16", [20] = "USW07L20", [24] = "USW07L24", [25] = "USW07L25", [30] = "USW07L30"}, -- Wild Shape: Fire Elemental
[11] = {[0] = "USW08L01", [16] = "USW08L16", [20] = "USW08L20", [24] = "USW08L24", [25] = "USW08L25", [30] = "USW08L30"}, -- Wild Shape: Earth Elemental
[12] = {[0] = "USW09L01", [16] = "USW09L16", [20] = "USW09L20", [24] = "USW09L24", [25] = "USW09L25", [30] = "USW09L30"}, -- Wild Shape: Water Elemental
[13] = {[0] = "USW10L01", [16] = "USW10L16", [20] = "USW10L20", [24] = "USW10L24", [25] = "USW10L25", [30] = "USW10L30"}, -- Wild Shape: Air Elemental
[14] = {[0] = "USW11L01", }, -- Placeholder
[15] = {[0] = "USW12L01", }, -- Placeholder
[16] = {[0] = "USW21L01", [9] = "USW21L09", [16] = "USW21L16", [24] = "USW21L24"}, -- Wild Shape: Blink Dog (Feat 1)
[17] = {[0] = "USW22L01", [10] = "USW22L10", [15] = "USW22L15", [20] = "USW22L20", [25] = "USW22L25", [30] = "USW22L30"}, -- Wild Shape: Creeping Doom (Feat 2)
[18] = {[0] = "USW23L01", [13] = "USW23L13", [18] = "USW23L18", [23] = "USW23L23", [28] = "USW23L28"}, -- Wild Shape: Rhinoceros Beetle (Feat 3)
[19] = {[0] = "USW30L01", [40] = "USW30L40", [50] = "USW30L50"}, -- Wild Shape: Black Dragon
[20] = {[0] = "USDUHM01", [2] = "USDUHM02", [3] = "USDUHM03", [4] = "USDUHM04", [5] = "USDUHM05", [6] = "USDUHM06", [7] = "USDUHM07", [8] = "USDUHM08", [9] = "USDUHM09", [10] = "USDUHM10"},
[21] = {[12] = "USDAMA01", [14] = "USDAMA02", [16] = "USDAMA03", [18] = "USDAMA04", [20] = "USDAMA05", [22] = "USDAMA06", [24] = "USDAMA07", [26] = "USDAMA08", [28] = "USDAMA09", [30] = "USDAMA10", [32] = "USDAMA11", [34] = "USDAMA12", [36] = "USDAMA13", [38] = "USDAMA14", [40] = "USDAMA15"}, -- Stat-based bonuses to damage
[22] = {[14] = "USDAMA01", [18] = "USDAMA02", [22] = "USDAMA03", [26] = "USDAMA04", [30] = "USDAMA05", [34] = "USDAMA06", [38] = "USDAMA07"}, -- Half stat-based bonuses to damage
[23] = {[12] = "USATTA01", [14] = "USATTA02", [16] = "USATTA03", [18] = "USATTA04", [20] = "USATTA05", [22] = "USATTA06", [24] = "USATTA07", [26] = "USATTA08", [28] = "USATTA09", [30] = "USATTA10", [32] = "USATTA11", [34] = "USATTA12", [36] = "USATTA13", [38] = "USATTA14", [40] = "USATTA15"}, -- Stat-based attack bonuses
[24] = {[1] = "USDAMA01", [2] = "USDAMA02", [3] = "USDAMA03", [4] = "USDAMA04", [5] = "USDAMA05", [6] = "USDAMA06", [7] = "USDAMA07", [8] = "USDAMA08", [9] = "USDAMA09", [10] = "USDAMA10", [11] = "USDAMA11", [12] = "USDAMA12", [13] = "USDAMA13", [14] = "USDAMA14", [15] = "USDAMA15", [16] = "USDAMA16", [17] = "USDAMA17", [18] = "USDAMA18", [19] = "USDAMA19", [20] = "USDAMA20"}, -- Damage bonuses
[25] = {[1] = "USATTA01", [2] = "USATTA02", [3] = "USATTA03", [4] = "USATTA04", [5] = "USATTA05", [6] = "USATTA06", [7] = "USATTA07", [8] = "USATTA08", [9] = "USATTA09", [10] = "USATTA10", [11] = "USATTA11", [12] = "USATTA12", [13] = "USATTA13", [14] = "USATTA14", [15] = "USATTA15", [16] = "USATTA16", [17] = "USATTA17", [18] = "USATTA18", [19] = "USATTA19", [20] = "USATTA20"}, -- Attack bonuses
[26] = {[5] = "USACAR01", [10] = "USACAR02", [15] = "USACAR03", [20] = "USACAR04", [25] = "USACAR05", [30] = "USACAR06", [35] = "USACAR07", [40] = "USACAR08", [45] = "USACAR09", [50] = "USACAR10", [55] = "USACAR11", [60] = "USACAR12", [65] = "USACAR13", [70] = "USACAR14", [75] = "USACAR15", [80] = "USACAR16", [85] = "USACAR17", [90] = "USACAR18", [95] = "USACAR19", [100] = "USACAR20", [105] = "USACAR21", [110] = "USACAR22", [115] = "USACAR23", [120] = "USACAR24", [125] = "USACAR25"}, -- Armor bonus based on skills
[27] = {[1] = "USIRONDR"}, -- Extra Iron Skins damage reduction
[28] = {[12] = "USACSH01", [14] = "USACSH02", [16] = "USACSH03", [18] = "USACSH04", [20] = "USACSH05", [22] = "USACSH06", [24] = "USACSH07", [26] = "USACSH08", [28] = "USACSH09", [30] = "USACSH10", [32] = "USACSH11", [34] = "USACSH12", [36] = "USACSH13", [38] = "USACSH14", [40] = "USACSH15", [42] = "USACSH16", [44] = "USACSH17", [46] = "USACSH18", [48] = "USACSH19", [50] = "USACSH20", [52] = "USACSH21", [54] = "USACSH22", [56] = "USACSH23", [58] = "USACSH24", [60] = "USACSH25"}, -- Stat-based shield bonus
[29] = {[12] = "USREGE01", [14] = "USREGE02", [16] = "USREGE03", [18] = "USREGE04", [20] = "USREGE05", [22] = "USREGE06", [24] = "USREGE07", [26] = "USREGE08", [28] = "USREGE09", [30] = "USREGE10", [32] = "USREGE11", [34] = "USREGE12", [36] = "USREGE13", [38] = "USREGE14", [40] = "USREGE15", [42] = "USREGE16", [44] = "USREGE17", [46] = "USREGE18", [48] = "USREGE19", [50] = "USREGE20", [52] = "USREGE21", [54] = "USREGE22", [56] = "USREGE23", [58] = "USREGE24", [60] = "USREGE25"}, -- Stat-based healing}
[30] = {[12] = "USPHDR01", [14] = "USPHDR02", [16] = "USPHDR03", [18] = "USPHDR04", [20] = "USPHDR05", [22] = "USPHDR06", [24] = "USPHDR07", [26] = "USPHDR08", [28] = "USPHDR09", [30] = "USPHDR10", [32] = "USPHDR11", [34] = "USPHDR12", [36] = "USPHDR13", [38] = "USPHDR14", [40] = "USPHDR15"},
[31] = {[12] = "USSANC05", [14] = "USSANC10", [16] = "USSANC15", [18] = "USSANC20", [20] = "USSANC25", [22] = "USSANC30", [24] = "USSANC35", [26] = "USSANC40", [28] = "USSANC45", [30] = "USSANC50", [32] = "USSANC55", [34] = "USSANC60", [36] = "USSANC65", [38] = "USSANC70", [40] = "USSANC75"},
[32] = {[12] = "USSANC10", [14] = "USSANC20", [16] = "USSANC30", [18] = "USSANC40", [20] = "USSANC50", [22] = "USSANC60", [24] = "USSANC70", [26] = "USSANC80", [28] = "USSANC90", [30] = "USSANC00"},
[33] = {[3] = "USACAR01", [6] = "USACAR02", [9] = "USACAR03", [12] = "USACAR04", [15] = "USACAR05", [18] = "USACAR06", [21] = "USACAR07", [24] = "USACAR08", [27] = "USACAR09", [30] = "USACAR10", [33] = "USACAR11", [36] = "USACAR12", [39] = "USACAR13", [42] = "USACAR14", [45] = "USACAR15", [48] = "USACAR16", [51] = "USACAR17", [54] = "USACAR18", [57] = "USACAR19", [60] = "USACAR20", [63] = "USACAR21", [66] = "USACAR22", [69] = "USACAR23", [72] = "USACAR24", [75] = "USACAR25"}, -- Armor bonus based on skills
[34] = {[2] = "USDAMA01", [4] = "USDAMA02", [6] = "USDAMA03", [8] = "USDAMA04", [10] = "USDAMA05", [12] = "USDAMA06", [14] = "USDAMA07", [16] = "USDAMA08", [18] = "USDAMA09", [20] = "USDAMA10", [22] = "USDAMA11", [24] = "USDAMA12", [26] = "USDAMA13", [28] = "USDAMA14", [30] = "USDAMA15", [32] = "USDAMA16", [34] = "USDAMA17", [36] = "USDAMA18", [38] = "USDAMA19", [40] = "USDAMA20"}, -- Damage bonuses
[81] = {[12] = "USCOMP01", },
[82] = {[12] = "USCOMP01", [14] = "USCOMP02", },
[83] = {[12] = "USCOMP01", [14] = "USCOMP02", [16] = "USCOMP03", },
[84] = {[12] = "USCOMP01", [14] = "USCOMP02", [16] = "USCOMP03", [18] = "USCOMP04", },
[85] = {[12] = "USCOMP01", [14] = "USCOMP02", [16] = "USCOMP03", [18] = "USCOMP04", [20] = "USCOMP05", },
[86] = {[12] = "USCOMP01", [14] = "USCOMP02", [16] = "USCOMP03", [18] = "USCOMP04", [20] = "USCOMP05", [22] = "USCOMP06", },
[87] = {[12] = "USCOMP01", [14] = "USCOMP02", [16] = "USCOMP03", [18] = "USCOMP04", [20] = "USCOMP05", [22] = "USCOMP06", [24] = "USCOMP07", },
[88] = {[12] = "USCOMP01", [14] = "USCOMP02", [16] = "USCOMP03", [18] = "USCOMP04", [20] = "USCOMP05", [22] = "USCOMP06", [24] = "USCOMP07", [26] = "USCOMP08", },
[89] = {[12] = "USCOMP01", [14] = "USCOMP02", [16] = "USCOMP03", [18] = "USCOMP04", [20] = "USCOMP05", [22] = "USCOMP06", [24] = "USCOMP07", [26] = "USCOMP08", [28] = "USCOMP09", },
[90] = {[12] = "USCOMP01", [14] = "USCOMP02", [16] = "USCOMP03", [18] = "USCOMP04", [20] = "USCOMP05", [22] = "USCOMP06", [24] = "USCOMP07", [26] = "USCOMP08", [28] = "USCOMP09", [30] = "USCOMP10", },
[91] = {[12] = "USCOMP01", [14] = "USCOMP02", [16] = "USCOMP03", [18] = "USCOMP04", [20] = "USCOMP05", [22] = "USCOMP06", [24] = "USCOMP07", [26] = "USCOMP08", [28] = "USCOMP09", [30] = "USCOMP10", [32] = "USCOMP11", },
[92] = {[12] = "USCOMP01", [14] = "USCOMP02", [16] = "USCOMP03", [18] = "USCOMP04", [20] = "USCOMP05", [22] = "USCOMP06", [24] = "USCOMP07", [26] = "USCOMP08", [28] = "USCOMP09", [30] = "USCOMP10", [32] = "USCOMP11", [34] = "USCOMP12", },
[93] = {[12] = "USCOMP01", [14] = "USCOMP02", [16] = "USCOMP03", [18] = "USCOMP04", [20] = "USCOMP05", [22] = "USCOMP06", [24] = "USCOMP07", [26] = "USCOMP08", [28] = "USCOMP09", [30] = "USCOMP10", [32] = "USCOMP11", [34] = "USCOMP12", [36] = "USCOMP13", },
[94] = {[12] = "USCOMP01", [14] = "USCOMP02", [16] = "USCOMP03", [18] = "USCOMP04", [20] = "USCOMP05", [22] = "USCOMP06", [24] = "USCOMP07", [26] = "USCOMP08", [28] = "USCOMP09", [30] = "USCOMP10", [32] = "USCOMP11", [34] = "USCOMP12", [36] = "USCOMP13", [38] = "USCOMP14", },
[95] = {[12] = "USCOMP01", [14] = "USCOMP02", [16] = "USCOMP03", [18] = "USCOMP04", [20] = "USCOMP05", [22] = "USCOMP06", [24] = "USCOMP07", [26] = "USCOMP08", [28] = "USCOMP09", [30] = "USCOMP10", [32] = "USCOMP11", [34] = "USCOMP12", [36] = "USCOMP13", [38] = "USCOMP14", [40] = "USCOMP15", },
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

function MECLSCAS(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local casterlvl = IEex_GetActorStat(sourceID, IEex_ReadDword(effectData + 0x44))
	if casterlvl <= 0 then
		casterlvl = 1
	end
	if spellRES ~= "" then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = spellRES,
["target_x"] = IEex_ReadDword(creatureData + 0x6),
["target_y"] = IEex_ReadDword(creatureData + 0xA),
["casterlvl"] = casterlvl,
["parent_resource"] = spellRES,
["source_id"] = sourceID
})
	end
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

function MEPALSPL(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local casterlvl = IEex_ReadByte(effectData + 0xC4, 0)
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0)
	if casterClass == 7 or casterClass == 8 then
		casterlvl = IEex_GetActorStat(sourceID, 95 + casterClass)
		if casterlvl == 0 then
			casterlvl = 1
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
})
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
--	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
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

function MEBARRAG(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	IEex_WriteDword(effectData + 0x110, 1)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceData = 0
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	local barrageCount = IEex_ReadWord(effectData + 0x44, 0x0)
	local projectile = IEex_ReadWord(effectData + 0x46, 0x0)
	if bit32.band(savingthrow, 0x10000000) > 0 then
		parent_resource = spellRES
	end
--[[
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 430,
["target"] = 2,
["timing"] = 1,
["parameter2"] = projectile,
["casterlvl"] = casterlvl,
["resource"] = spellRES,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
--]]
	for i = 1, barrageCount, 1 do

		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 430,
["target"] = 2,
["timing"] = 6,
["duration"] = IEex_GetGameTick() + (i * 2) - 1,
["parameter2"] = projectile,
["casterlvl"] = casterlvl,
["resource"] = spellRES,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
	end
--[[
	for i = 1, barrageCount, 1 do
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 146,
["target"] = 2,
["timing"] = 1,
["duration"] = IEex_GetGameTick() + i - 1,
["parameter1"] = 1,
["parameter2"] = 1,
["casterlvl"] = casterlvl,
["resource"] = spellRES,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
	end
--]]
end

function MEGARGOY(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	IEex_WriteDword(effectData + 0x110, 1)
	local targetID = IEex_GetActorIDShare(creatureData)
	local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local currentAction = IEex_ReadWord(creatureData + 0x476, 0x0)
	if currentAction == 0 and not IEex_GetActorSpellState(targetID, 18) then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 4,
["duration"] = 6,
["resource"] = "USGARGO1",
["parent_resource"] = "USGARGO1",
["source_target"] = targetID,
["source_id"] = targetID
})
	else
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USGARGO1",
["parent_resource"] = "USGARGO1",
["source_target"] = targetID,
["source_id"] = targetID
})
	end
end

function MEGARGOS(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	IEex_WriteDword(effectData + 0x110, 1)
	local targetID = IEex_GetActorIDShare(creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		if theopcode == 218 then
			IEex_WriteDword(eData + 0x60, parameter1)
		end
	end)
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

function MERESTOR(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local baseStrength = IEex_ReadByte(creatureData + 0x802, 0x0)
	local baseDexterity = IEex_ReadByte(creatureData + 0x805, 0x0)
	local baseConstitution = IEex_ReadByte(creatureData + 0x806, 0x0)
	local baseIntelligence = IEex_ReadByte(creatureData + 0x803, 0x0)
	local baseWisdom = IEex_ReadByte(creatureData + 0x804, 0x0)
	local baseCharisma = IEex_ReadByte(creatureData + 0x807, 0x0)
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter1 = IEex_ReadDword(eData + 0x1C)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		local thetiming = IEex_ReadDword(eData + 0x24)
		local thesavingthrow = IEex_ReadDword(eData + 0x40)
		local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
		if thetiming ~= 2 and bit32.band(thesavingthrow, 0x4000000) == 0 then
			if (theopcode == 44 and ((theparameter2 == 0 and theparameter1 < 0) or (theparameter2 == 1 and theparameter1 < baseStrength) or (theparameter2 == 2 and theparameter1 < 100)))
			or (theopcode == 15 and ((theparameter2 == 0 and theparameter1 < 0) or (theparameter2 == 1 and theparameter1 < baseDexterity) or (theparameter2 == 2 and theparameter1 < 100)))
			or (theopcode == 10 and ((theparameter2 == 0 and theparameter1 < 0) or (theparameter2 == 1 and theparameter1 < baseConstitution) or (theparameter2 == 2 and theparameter1 < 100)))
			or (theopcode == 19 and ((theparameter2 == 0 and theparameter1 < 0) or (theparameter2 == 1 and theparameter1 < baseIntelligence) or (theparameter2 == 2 and theparameter1 < 100)))
			or (theopcode == 49 and ((theparameter2 == 0 and theparameter1 < 0) or (theparameter2 == 1 and theparameter1 < baseWisdom) or (theparameter2 == 2 and theparameter1 < 100)))
			or (theopcode == 6 and ((theparameter2 == 0 and theparameter1 < 0) or (theparameter2 == 1 and theparameter1 < baseCharisma) or (theparameter2 == 2 and theparameter1 < 100)))
			or (theopcode == 78 and ((theparameter2 >= 4 and theparameter2 <= 9) or theparameter2 == 13 or theparameter2 == 14)) then
				IEex_WriteDword(eData + 0x24, 4096)
				IEex_WriteDword(eData + 0x28, IEex_GetGameTick())
				IEex_WriteDword(eData + 0x114, 1)
			end
		end
	end)
end

function MEPOLYMO(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
--	local sourceID = IEex_ReadDword(effectData + 0x10C)
--	if not IEex_IsSprite(sourceID, false) then return end
	local creRES = IEex_ReadLString(effectData + 0x18, 8)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local baseAnimation = IEex_ReadDword(creatureData + 0x5C4)
	local baseStrength = IEex_ReadByte(creatureData + 0x802, 0x0)
	local baseDexterity = IEex_ReadByte(creatureData + 0x805, 0x0)
	local baseConstitution = IEex_ReadByte(creatureData + 0x806, 0x0)
	local baseIntelligence = IEex_ReadByte(creatureData + 0x803, 0x0)
	local baseWisdom = IEex_ReadByte(creatureData + 0x804, 0x0)
	local baseCharisma = IEex_ReadByte(creatureData + 0x807, 0x0)
	local specialFlags = IEex_ReadByte(creatureData + 0x89F, 0x0)
	local baseCritImmunity = 0
	if bit32.band(specialFlags, 0x2) > 0 then
		baseCritImmunity = 1
	end
	local hasCursedWeapon = false
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter1 = IEex_ReadDword(eData + 0x1C)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		local thesavingthrow = IEex_ReadDword(eData + 0x40)
		local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
		if theopcode == 288 and theparameter2 == 241 and thespecial >= 4 and bit32.band(thesavingthrow, 0x100000) > 0 then
			hasCursedWeapon = true
		end
	end)
	if hasCursedWeapon then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 290,
["target"] = 2,
["timing"] = 0,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_id"] = targetID
})
		return
	end
	if IEex_GetActorSpellState(targetID, 188) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 188 then
				baseAnimation = IEex_ReadDword(eData + 0x1C)
				baseStrength = IEex_ReadByte(eData + 0x44, 0x0)
				baseDexterity = IEex_ReadByte(eData + 0x45, 0x0)
				baseConstitution = IEex_ReadByte(eData + 0x46, 0x0)
				baseIntelligence = IEex_ReadByte(eData + 0x47, 0x0)
				baseWisdom = IEex_ReadByte(eData + 0x48, 0x0)
				baseCharisma = IEex_ReadByte(eData + 0x49, 0x0)
			end
		end)
	else
		IEex_DS(baseAnimation)
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 9,
["parameter1"] = baseAnimation,
["parameter2"] = 188,
["savingthrow"] = baseCritImmunity * 0x1000000,
["savebonus"] = baseStrength + baseDexterity * 0x100 + baseConstitution * 0x10000 + baseIntelligence * 0x1000000,
["special"] = baseWisdom + baseCharisma * 0x100,
["parent_resource"] = "USPOLYBA",
["source_id"] = targetID
})
	end
	local resWrapper = IEex_DemandRes(creRES, "CRE")
	if resWrapper:isValid() then
		local formData = resWrapper:getData()
		if bit32.band(IEex_ReadByte(formData + 0x303, 0x0), 0x2) > 0 then
			IEex_WriteByte(creatureData + 0x89F, bit32.bor(specialFlags, 0x2))
		else
			IEex_WriteByte(creatureData + 0x89F, bit32.band(specialFlags, 0xFD))
		end
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = "USPOLYSP",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = "USPOLYMO",
["source_id"] = targetID
})
		local newStrength = IEex_ReadByte(formData + 0x266, 0x0)
		if newStrength > baseStrength then
--			IEex_WriteByte(creatureData + 0x802, newStrength)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 44,
["target"] = 2,
["timing"] = 9,
["parameter1"] = newStrength,
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		else
--			IEex_WriteByte(creatureData + 0x802, baseStrength)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 44,
["target"] = 2,
["timing"] = 9,
["parameter1"] = baseStrength,
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		end
		local newDexterity = IEex_ReadByte(formData + 0x269, 0x0)
		if newDexterity > baseDexterity then
--			IEex_WriteByte(creatureData + 0x805, newDexterity)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 15,
["target"] = 2,
["timing"] = 9,
["parameter1"] = newDexterity,
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		else
--			IEex_WriteByte(creatureData + 0x805, baseDexterity)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 15,
["target"] = 2,
["timing"] = 9,
["parameter1"] = baseDexterity,
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		end
		local newConstitution = IEex_ReadByte(formData + 0x26A, 0x0)
		if newConstitution > baseConstitution then
--			IEex_WriteByte(creatureData + 0x806, newConstitution)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 10,
["target"] = 2,
["timing"] = 9,
["parameter1"] = newConstitution,
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		else
--			IEex_WriteByte(creatureData + 0x806, baseConstitution)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 10,
["target"] = 2,
["timing"] = 9,
["parameter1"] = baseConstitution,
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		end
--[[
		local newIntelligence = IEex_ReadByte(formData + 0x267, 0x0)
		if newIntelligence > baseIntelligence then
--			IEex_WriteByte(creatureData + 0x803, newIntelligence)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 19,
["target"] = 2,
["timing"] = 9,
["parameter1"] = newIntelligence,
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		else
--			IEex_WriteByte(creatureData + 0x803, baseIntelligence)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 19,
["target"] = 2,
["timing"] = 9,
["parameter1"] = baseIntelligence,
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		end
		local newWisdom = IEex_ReadByte(formData + 0x268, 0x0)
		if newWisdom > baseWisdom then
--			IEex_WriteByte(creatureData + 0x804, newWisdom)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 49,
["target"] = 2,
["timing"] = 9,
["parameter1"] = newWisdom,
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		else
--			IEex_WriteByte(creatureData + 0x804, baseWisdom)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 49,
["target"] = 2,
["timing"] = 9,
["parameter1"] = baseWisdom,
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		end
		local newCharisma = IEex_ReadByte(formData + 0x26B, 0x0)
		if newCharisma > baseCharisma then
--			IEex_WriteByte(creatureData + 0x807, newCharisma)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 6,
["target"] = 2,
["timing"] = 9,
["parameter1"] = newCharisma,
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		else
--			IEex_WriteByte(creatureData + 0x807, baseCharisma)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 6,
["target"] = 2,
["timing"] = 9,
["parameter1"] = baseCharisma,
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		end
--]]
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 144,
["target"] = 2,
["timing"] = 9,
["parameter2"] = 2,
["parent_resource"] = "USPOLYSP",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 145,
["target"] = 2,
["timing"] = 9,
["parameter2"] = 1,
["parent_resource"] = "USPOLYSP",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 9,
["parameter1"] = -4,
["parameter2"] = 193,
["special"] = 2,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 9,
["parameter1"] = IEex_ReadWord(formData + 0x46, 0x0) - 10,
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 1,
["target"] = 2,
["timing"] = 9,
["parameter1"] = IEex_ReadByte(formData + 0x51, 0x0),
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 30,
["target"] = 2,
["timing"] = 9,
["parameter1"] = IEex_ReadSignedByte(formData + 0x55, 0x0),
["parameter2"] = 0,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 28,
["target"] = 2,
["timing"] = 9,
["parameter1"] = IEex_ReadSignedByte(formData + 0x56, 0x0),
["parameter2"] = 0,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 29,
["target"] = 2,
["timing"] = 9,
["parameter1"] = IEex_ReadSignedByte(formData + 0x57, 0x0),
["parameter2"] = 0,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 27,
["target"] = 2,
["timing"] = 9,
["parameter1"] = IEex_ReadSignedByte(formData + 0x58, 0x0),
["parameter2"] = 0,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 166,
["target"] = 2,
["timing"] = 9,
["parameter1"] = IEex_ReadSignedByte(formData + 0x59, 0x0),
["parameter2"] = 1,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 86,
["target"] = 2,
["timing"] = 9,
["parameter1"] = IEex_ReadSignedByte(formData + 0x5C, 0x0),
["parameter2"] = 0,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 87,
["target"] = 2,
["timing"] = 9,
["parameter1"] = IEex_ReadSignedByte(formData + 0x5D, 0x0),
["parameter2"] = 0,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 88,
["target"] = 2,
["timing"] = 9,
["parameter1"] = IEex_ReadSignedByte(formData + 0x5E, 0x0),
["parameter2"] = 0,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 89,
["target"] = 2,
["timing"] = 9,
["parameter1"] = IEex_ReadSignedByte(formData + 0x5F, 0x0),
["parameter2"] = 0,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 31,
["target"] = 2,
["timing"] = 9,
["parameter1"] = IEex_ReadSignedByte(formData + 0x60, 0x0),
["parameter2"] = 0,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		if IEex_ReadWord(formData + 0x1BC, 0x0) > 0 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 436,
["target"] = 2,
["timing"] = 9,
["parameter2"] = IEex_ReadWord(formData + 0x1BC, 0x0),
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		end
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 53,
["target"] = 2,
["timing"] = 1,
["parameter1"] = IEex_ReadDword(formData + 0x28),
["parameter2"] = 2,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 53,
["target"] = 2,
["timing"] = 0,
["duration"] = 1,
["parameter1"] = IEex_ReadDword(formData + 0x28),
["parameter2"] = 0,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
	end
	resWrapper:free()
end

function MEPOLYBA(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
--	local sourceID = IEex_ReadDword(effectData + 0x10C)
--	if not IEex_IsSprite(sourceID, false) then return end
	local baseAnimation = 0
--	local baseStrength = IEex_ReadByte(creatureData + 0x802, 0x0)
--	local baseDexterity = IEex_ReadByte(creatureData + 0x805, 0x0)
--	local baseConstitution = IEex_ReadByte(creatureData + 0x806, 0x0)
--	local baseIntelligence = IEex_ReadByte(creatureData + 0x803, 0x0)
--	local baseWisdom = IEex_ReadByte(creatureData + 0x804, 0x0)
--	local baseCharisma = IEex_ReadByte(creatureData + 0x807, 0x0)
	local specialFlags = IEex_ReadByte(creatureData + 0x89F, 0x0)
	if IEex_GetActorSpellState(targetID, 188) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 188 then
				IEex_DS(IEex_ReadDword(eData + 0x1C))
				baseAnimation = IEex_ReadDword(eData + 0x1C)
--				baseStrength = IEex_ReadByte(eData + 0x44, 0x0)
--				baseDexterity = IEex_ReadByte(eData + 0x45, 0x0)
--				baseConstitution = IEex_ReadByte(eData + 0x46, 0x0)
--				baseIntelligence = IEex_ReadByte(eData + 0x47, 0x0)
--				baseWisdom = IEex_ReadByte(eData + 0x48, 0x0)
--				baseCharisma = IEex_ReadByte(eData + 0x49, 0x0)
				if bit32.band(IEex_ReadDword(eData + 0x40), 0x1000000) > 0 then
					IEex_WriteByte(creatureData + 0x89F, bit32.bor(specialFlags, 0x2))
				else
					IEex_WriteByte(creatureData + 0x89F, bit32.band(specialFlags, 0xFD))
				end
			end
		end)
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = "USPOLYSP",
["source_id"] = targetID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = "USPOLYMO",
["source_id"] = targetID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = "USPOLYBA",
["source_id"] = targetID
})
	if baseAnimation > 0 then
		IEex_DS(baseAnimation)
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 53,
["target"] = 2,
["timing"] = 1,
["parameter1"] = baseAnimation,
["parameter2"] = 2,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 53,
["target"] = 2,
["timing"] = 0,
["duration"] = 1,
["parameter1"] = baseAnimation,
["parameter2"] = 0,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 276,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 112,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 276,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 255,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
	end
end

function MEQUIPLE(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local duration = IEex_ReadDword(effectData + 0x44)
	if IEex_ReadLString(effectData + 0x92, 2) == "PR" then
		duration = math.floor(duration * IEex_GetActorStat(sourceID, 54) / 100)
	end
	local quiverData = IEex_ReadDword(creatureData + 0x4B04)
	local quiverRES = ""
	local quiverNum = 0
	local quiverFlags = 0
	if quiverData > 0 then
		quiverRES = IEex_ReadLString(quiverData + 0xC, 8)
		quiverNum = IEex_ReadWord(quiverData + 0x18, 0x0)
		quiverFlags = IEex_ReadByte(quiverData + 0x20, 0x0)
	end
--[[
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
--]]
	if quiverRES ~= "" then
		if IEex_ReadLString(quiverData + 0xC, 6) ~= "USQUIP" then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 143,
["target"] = 2,
["timing"] = 4,
["duration"] = duration,
["parameter1"] = 11,
["resource"] = quiverRES,
["parent_resource"] = "MEQUIPLE",
["source_id"] = targetID
})
		end
	end
	if not IEex_GetActorSpellState(targetID, 187) then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 1,
["parameter1"] = quiverNum,
["parameter2"] = 187,
["special"] = quiverFlags,
["resource"] = quiverRES,
["parent_resource"] = "MEQUIPLE",
["source_id"] = targetID
})
	else
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
			if theopcode == 143 and theparameter1 == 11 and theparent_resource == "MEQUIPLE" then
				IEex_WriteDword(eData + 0x28, IEex_ReadDword(effectData + 0x24) + duration * 15)
			end
		end)
	end
end

function MEQUIPL2(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local quiverData = IEex_ReadDword(creatureData + 0x4B04)
	if quiverData > 0 and IEex_ReadByte(creatureData + 0x34C0, 0x0) == 11 and IEex_ReadByte(creatureData + 0x3D3C, 0x0) == 11 then
		IEex_WriteByte(creatureData + 0x4BA4, 11)
		local resWrapper = IEex_DemandRes(IEex_ReadLString(quiverData + 0xC, 8), "ITM")
		if resWrapper:isValid() then
			local itemData = resWrapper:getData()
			IEex_WriteWord(creatureData + 0x34BC, IEex_ReadWord(quiverData + 0x18, 0x0))
			IEex_WriteLString(creatureData + 0x34A4, IEex_ReadLString(itemData + 0x3A, 8), 8)
			local thename1 = IEex_ReadDword(itemData + 0x8)
			local thename2 = IEex_ReadDword(itemData + 0xC)
			if thename2 > 0 and thename2 < 999999 and (IEex_ReadWord(itemData + 0x42, 0x0) == 0 or bit32.band(IEex_ReadByte(quiverData + 0x20, 0x0), 0x1) > 0) then
				IEex_WriteDword(creatureData + 0x34AC, thename2)
			else
				IEex_WriteDword(creatureData + 0x34AC, thename1)
			end
		end
		resWrapper:free()
	end
end

function MEQUIVNO(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local quiverData = IEex_ReadDword(creatureData + 0x4B04)
	local quiverRES = ""
	if quiverData > 0 then
		quiverRES = IEex_ReadLString(quiverData + 0xC, 8)
	end
	if IEex_GetActorSpellState(targetID, 187) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local thespecial = IEex_ReadDword(eData + 0x48)
			if theopcode == 288 and theparameter2 == 187 and theresource == quiverRES and quiverRES ~= "" then
				IEex_WriteWord(quiverData + 0x18, theparameter1)
				IEex_WriteByte(quiverData + 0x20, thespecial)
			end
		end)
	end
	if IEex_ReadByte(creatureData + 0x34C0, 0x0) == 11 and IEex_ReadByte(creatureData + 0x3D3C, 0x0) == 11 and IEex_ReadByte(creatureData + 0x4BA4, 0x0) == 10 then
		if IEex_ReadDword(creatureData + 0x4B04) > 0 then
			IEex_WriteByte(creatureData + 0x4BA4, 11)
		elseif IEex_ReadDword(creatureData + 0x4B08) > 0 then
			IEex_WriteByte(creatureData + 0x34C0, 12)
			IEex_WriteByte(creatureData + 0x3D3C, 12)
			IEex_WriteByte(creatureData + 0x4BA4, 12)
		elseif IEex_ReadDword(creatureData + 0x4B0C) > 0 then
			IEex_WriteByte(creatureData + 0x34C0, 13)
			IEex_WriteByte(creatureData + 0x3D3C, 13)
			IEex_WriteByte(creatureData + 0x4BA4, 13)
		else
			IEex_WriteByte(creatureData + 0x34C0, 10)
			IEex_WriteByte(creatureData + 0x3D3C, 0)
		end
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "MEQUIPLE",
["parent_resource"] = "MEQUIPLE",
["source_id"] = targetID
})

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
		local dexterityAdjust = 0
		local maxDexBonus = 99
		local armorCheckPenalty = 0
		if ex_armor_penalties[armorType] ~= nil then
			maxDexBonus = ex_armor_penalties[armorType][2]
			armorCheckPenalty = ex_armor_penalties[armorType][3]
			if dexterityBonus > maxDexBonus then
				dexterityAdjust = dexterityBonus - maxDexBonus
			end
		end
		if armorType == 60 or armorType == 61 then
			if armorCheckPenalty > 0 then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 59,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = armorCheckPenalty + dexterityAdjust,
["parent_resource"] = "USARMMAS",
["source_id"] = targetID
})
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 90,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = armorCheckPenalty + dexterityAdjust,
["parent_resource"] = "USARMMAS",
["source_id"] = targetID
})
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 91,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = armorCheckPenalty + dexterityAdjust,
["parent_resource"] = "USARMMAS",
["source_id"] = targetID
})
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 92,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = armorCheckPenalty + dexterityAdjust,
["parent_resource"] = "USARMMAS",
["source_id"] = targetID
})
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 297,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = armorCheckPenalty + dexterityAdjust,
["parent_resource"] = "USARMMAS",
["source_id"] = targetID
})
			end
			if dexterityAdjust > 0 then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = dexterityAdjust,
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
					IEex_SetToken("EXWHNAME" .. ex_whirla_index, IEex_GetActorName(targetID))
					IEex_SetToken("EXWHWEAP" .. ex_whirla_index, IEex_FetchString(IEex_ReadDword(itemData + 0xC)))
--					local feedbackString = "Attacks " .. IEex_GetActorName(targetID) .. " with " .. IEex_FetchString(IEex_ReadDword(itemData + 0xC)) .. " : "
					if isHit then
						IEex_SetToken("EXWHHITMISS" .. ex_whirla_index, ex_str_hit)
--						feedbackString = feedbackString .. "Hit"
					else
						IEex_SetToken("EXWHHITMISS" .. ex_whirla_index, ex_str_miss)
--						feedbackString = feedbackString .. "Miss"
					end
--					IEex_SetToken("MEWHRA" .. ex_whirla_index, feedbackString)
					IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["parameter1"] = ex_whirla[ex_whirla_index],
["source_id"] = sourceID
})
					if ex_whirla_index == 40 then
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
--[[
		IEex_WriteWord(sourceData + 0x537C, -1)
		local orientation1 = IEex_ReadByte(sourceData + 0x5380, 0x0)
		IEex_WriteByte(sourceData + 0x537E, orientation1)
		IEex_WriteByte(sourceData + 0x5380, (orientation1 - 1) % 16)
--]]
		IEex_WriteWord(sourceData + 0x537C, 1)
		local orientation1 = IEex_ReadByte(sourceData + 0x5380, 0x0)
		IEex_WriteByte(sourceData + 0x537E, (orientation1 - 1) % 16)
--		IEex_WriteByte(sourceData + 0x5380, (orientation1 + 1) % 16)
	else
		IEex_WriteWord(creatureData + 0x537C, -1)
		local orientation1 = IEex_ReadByte(creatureData + 0x5380, 0x0)
		IEex_WriteByte(creatureData + 0x537E, orientation1)
		IEex_WriteByte(creatureData + 0x5380, (orientation1 - 1) % 16)
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
	if IEex_ReadSignedByte(creatureData + 0x603, 0x0) == -1 then
		for i = 0, 5, 1 do
			if IEex_GetActorIDCharacter(i) == targetID then
				IEex_WriteByte(creatureData + 0x603, 0)
			end
		end
	end
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
	
	if IEex_ReadByte(creatureData + 0x24, 0x0) <= 30 and (IEex_GetActorStat(targetID, 101) > 0 or IEex_GetActorStat(targetID, 102) > 0) then
		local specialFlags = IEex_ReadByte(creatureData + 0x89F, 0x0)
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
					if k <= 4 and bit32.band(specialFlags, 0x4) > 0 then
						IEex_WriteByte(creatureData + 0x89F, bit32.band(specialFlags, 0xFB))
					elseif k > 4 and bit32.band(specialFlags, 0x8) > 0 then
						IEex_WriteByte(creatureData + 0x89F, bit32.band(specialFlags, 0xF7))
					end
				else
					if k <= 4 and bit32.band(specialFlags, 0x4) == 0 then
						IEex_WriteByte(creatureData + 0x89F, bit32.bor(specialFlags, 0x4))
					elseif k > 4 and bit32.band(specialFlags, 0x8) == 0 then
						IEex_WriteByte(creatureData + 0x89F, bit32.bor(specialFlags, 0x8))
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
--[[
	if classSpellLevel > 0 and maximumExtendSpellLevel >= classSpellLevel then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 9,
["parameter1"] = 200,
["parameter2"] = 195,
["parent_resource"] = "USDURMAG",
["source_id"] = targetID
})
	end
--]]
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
To use the EXMODMEM function, create an opcode 500 effect in an item or spell, set the resource to EXMODMEM (all capitals),
 set the timing to instant, limited and the duration to 0, and choose parameters.

The EXMODMEM function changes which spells the target can cast. It can either restore spell uses or
 deplete spell uses. By default, it can only restore/remove spells of the same caster type as the spell that called this function
 (e.g. if this was cast as a bard spell, it will only restore/remove spells in the character's bard spell list) unless extra bits are
 set on the savingthrow parameter.

parameter1 - Determines the maximum number of spell uses that can be restored/removed. If set to 0, there is no limit.

parameter2 - Determines the highest spell level that can be restored (1 - 9).

savingthrow - This function uses several extra bits on this parameter:
Bit 16: If set, the function can restore/remove bard spells.
Bit 17: If set, the function can restore/remove cleric spells.
Bit 18: If set, the function can restore/remove druid spells.
Bit 19: If set, the function can restore/remove paladin spells.
Bit 20: If set, the function can restore/remove ranger spells.
Bit 21: If set, the function can restore/remove sorcerer spells.
Bit 22: If set, the function can restore/remove wizard spells.
Bit 23: If set, the function can restore/remove domain spells.
Bit 27: If set, the function generates feedback on which spells were restored/removed.

special - Determines the lowest spell level that can be restored (1 - 9).
--]]
ex_ssfeedback_levelstrings = {ex_str_1st_level, ex_str_2nd_level, ex_str_3rd_level, ex_str_4th_level, ex_str_5th_level, ex_str_6th_level, ex_str_7th_level, ex_str_8th_level, ex_str_9th_level}
function EXMODMEM(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	local modifyRemaining = IEex_ReadDword(effectData + 0x18)
	local maxLevel = IEex_ReadWord(effectData + 0x1C, 0x0)
	local minLevel = IEex_ReadWord(effectData + 0x44, 0x0)
	local maxStolenLevel = IEex_ReadWord(effectData + 0x1E, 0x0)
	local minStolenLevel = IEex_ReadWord(effectData + 0x46, 0x0)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadByte(effectData + 0xC4, 0x0)
--[[
	local matchSpell = IEex_ReadLString(effectData + 0x6C, 8)
	if matchSpell == "" then
		matchSpell = parent_resource
	end
	local ignoreSpell = IEex_ReadLString(effectData + 0x74, 8)
	if ignoreSpell == "" then
		ignoreSpell = parent_resource
	end
--]]
	local subtractSpells = false
	if modifyRemaining < 0 then
		subtractSpells = true
		modifyRemaining = math.abs(modifyRemaining)
	end
	if (maxStolenLevel > 0 and minStolenLevel > 0) then
		subtractSpells = true
		if bit32.band(savingthrow, 0x1000000) > 0 then
			modifyRemaining = modifyRemaining + math.floor((math.random(20) + casterlvl + IEex_GetActorStat(sourceID, 29)) / 10)
		end
	end
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	local casterType = IEex_CasterClassToType[casterClass]
	local casterTypes = {}
	if casterType ~= nil then
		if bit32.band(savingthrow, 2 ^ (casterType + 15)) == 0 then
			table.insert(casterTypes, casterType)
		end
		if casterType == 2 and bit32.band(savingthrow, 0x800000) > 0 then
			table.insert(casterTypes, 8)
		end
	end
	for i = 1, 7, 1 do
		if bit32.band(savingthrow, 2 ^ (i + 15)) > 0 then
			table.insert(casterTypes, i)
		end
	end
	local modifyList = {}
	local spellsStolen = 0
	local spells = IEex_FetchSpellInfo(targetID, casterTypes)
	for i = maxLevel, minLevel, -1 do
		for cType, levelList in pairs(spells) do
			if #levelList >= i then
				local levelI = levelList[i]
				local maxCastable = levelI[1]
				local sorcererCastableCount = levelI[2]
				local levelISpells = levelI[3]
				if #levelISpells > 0 then
					if cType == 1 or cType == 6 then
						if not subtractSpells then
							local modifyNum = maxCastable - sorcererCastableCount
							if modifyNum > modifyRemaining then
								modifyNum = modifyRemaining
							end
							if modifyNum > 0 then
								modifyRemaining = modifyRemaining - modifyNum
								table.insert(modifyList, {i, modifyNum, ""})
								IEex_AlterSpellInfo(targetID, cType, i, "", 0, modifyNum)
							end
						else
							local modifyNum = sorcererCastableCount
							if modifyNum > modifyRemaining then
								modifyNum = modifyRemaining
							end
							if modifyNum > 0 then
								modifyRemaining = modifyRemaining - modifyNum
								spellsStolen = spellsStolen + modifyNum
								table.insert(modifyList, {i, modifyNum, ""})
								IEex_AlterSpellInfo(targetID, cType, i, "", 0, modifyNum * -1)
							end
						end
					else
						for i2, spell in ipairs(levelISpells) do
							if not subtractSpells then
								local modifyNum = spell["memorizedCount"] - spell["castableCount"]
								if modifyNum > modifyRemaining then
									modifyNum = modifyRemaining
								end
								if modifyNum > 0 then
									modifyRemaining = modifyRemaining - modifyNum
									table.insert(modifyList, {i, modifyNum, spell["resref"]})
									IEex_AlterSpellInfo(targetID, cType, i, spell["resref"], 0, modifyNum)
								end
							else
								local modifyNum = spell["castableCount"]
								if modifyNum > modifyRemaining then
									modifyNum = modifyRemaining
								end
								if modifyNum > 0 then
									modifyRemaining = modifyRemaining - modifyNum
									spellsStolen = spellsStolen + modifyNum
									table.insert(modifyList, {i, modifyNum, spell["resref"]})
									IEex_AlterSpellInfo(targetID, cType, i, spell["resref"], 0, modifyNum * -1)
								end
							end
						end
					end
				end
			end
		end
	end
	if bit32.band(savingthrow, 0x8000000) > 0 then
		local feedbackString = ""
		for i = 1, #modifyList, 1 do
			if modifyList[i][2] == 1 then
				feedbackString = feedbackString .. ex_str_55431
			else
				feedbackString = feedbackString .. ex_str_55432
			end
			if i == 1 then
				if not subtractSpells then
					feedbackString = string.gsub(feedbackString, "<EXSSREGAINEDLOSTAND>", ex_str_55453)
				else
					feedbackString = string.gsub(feedbackString, "<EXSSREGAINEDLOSTAND>", ex_str_55454)
				end
			elseif i == #modifyList then
				feedbackString = string.gsub(feedbackString, "<EXSSREGAINEDLOSTAND>", ex_str_55455)
			else
				feedbackString = string.gsub(feedbackString, "<EXSSREGAINEDLOSTAND>", "")
			end
			feedbackString = string.gsub(feedbackString, "<EXSSNUMSPELLS>", modifyList[i][2])
			if modifyList[i][3] == "" then
				feedbackString = string.gsub(feedbackString, "<EXSSLEVELORNAME>", ex_ssfeedback_levelstrings[modifyList[i][1]])
			else
				local resWrapper = IEex_DemandRes(modifyList[i][3], "SPL")
				if resWrapper:isValid() then
					local spellData = resWrapper:getData()
					feedbackString = string.gsub(feedbackString, "<EXSSLEVELORNAME>", IEex_FetchString(IEex_ReadDword(spellData + 0x8)))
				else
					feedbackString = string.gsub(feedbackString, "<EXSSLEVELORNAME>", "unknown")
				end
				resWrapper:free()
			end
			if i ~= #modifyList then
				feedbackString = feedbackString .. ",\n"
			end
		end
		IEex_SetToken("EXSSFULL1", feedbackString)
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_55401,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	end
	if maxStolenLevel > 0 and minStolenLevel > 0 and spellsStolen > 0 and IEex_IsSprite(sourceID, true) then
		modifyRemaining = spellsStolen
		subtractSpells = false
		modifyList = {}
		spells = IEex_FetchSpellInfo(sourceID, casterTypes)
		for i = maxStolenLevel, minStolenLevel, -1 do
			for cType, levelList in pairs(spells) do
				if #levelList >= i then
					local levelI = levelList[i]
					local maxCastable = levelI[1]
					local sorcererCastableCount = levelI[2]
					local levelISpells = levelI[3]
					if #levelISpells > 0 then
						if cType == 1 or cType == 6 then
							local modifyNum = maxCastable - sorcererCastableCount
							if modifyNum > modifyRemaining then
								modifyNum = modifyRemaining
							end
							if modifyNum > 0 then
								modifyRemaining = modifyRemaining - modifyNum
								table.insert(modifyList, {i, modifyNum, ""})
								IEex_AlterSpellInfo(sourceID, cType, i, "", 0, modifyNum)
							end
						else
							for i2, spell in ipairs(levelISpells) do
								local modifyNum = spell["memorizedCount"] - spell["castableCount"]
								if modifyNum > modifyRemaining then
									modifyNum = modifyRemaining
								end
								if modifyNum > 0 then
									modifyRemaining = modifyRemaining - modifyNum
									table.insert(modifyList, {i, modifyNum, spell["resref"]})
									IEex_AlterSpellInfo(sourceID, cType, i, spell["resref"], 0, modifyNum)
								end
							end
						end
					end
				end
			end
		end
		if bit32.band(savingthrow, 0x8000000) > 0 and #modifyList > 0 then
			local feedbackString = ""
			for i = 1, #modifyList, 1 do
				if modifyList[i][2] == 1 then
					feedbackString = feedbackString .. ex_str_55431
				else
					feedbackString = feedbackString .. ex_str_55432
				end
				if i == 1 then
					if not subtractSpells then
						feedbackString = string.gsub(feedbackString, "<EXSSREGAINEDLOSTAND>", ex_str_55453)
					else
						feedbackString = string.gsub(feedbackString, "<EXSSREGAINEDLOSTAND>", ex_str_55454)
					end
				elseif i == #modifyList then
					feedbackString = string.gsub(feedbackString, "<EXSSREGAINEDLOSTAND>", ex_str_55455)
				else
					feedbackString = string.gsub(feedbackString, "<EXSSREGAINEDLOSTAND>", "")
				end
				feedbackString = string.gsub(feedbackString, "<EXSSNUMSPELLS>", modifyList[i][2])
				if modifyList[i][3] == "" then
					feedbackString = string.gsub(feedbackString, "<EXSSLEVELORNAME>", ex_ssfeedback_levelstrings[modifyList[i][1]])
				else
					local resWrapper = IEex_DemandRes(modifyList[i][3], "SPL")
					if resWrapper:isValid() then
						local spellData = resWrapper:getData()
						feedbackString = string.gsub(feedbackString, "<EXSSLEVELORNAME>", IEex_FetchString(IEex_ReadDword(spellData + 0x8)))
					else
						feedbackString = string.gsub(feedbackString, "<EXSSLEVELORNAME>", "unknown")
					end
					resWrapper:free()
				end
				if i ~= #modifyList then
					feedbackString = feedbackString .. ",\n"
				end
			end
			IEex_SetToken("EXSSFULL2", feedbackString)
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_55402,
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
7: The target gets immunity if they have any of the general types (e.g. undead) specified by parameter2.
--]]
function MESPLPRT(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	IEex_WriteDword(effectData + 0x110, 1)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	local checkID = targetID
	local newEffectTarget = targetID
	local hasProtection = false
	local protectionType = IEex_ReadDword(effectData + 0x44)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	if bit32.band(savingthrow, 0x20000) > 0 and IEex_IsSprite(sourceID, true) then
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
	elseif protectionType == 7 then
		local general = IEex_ReadByte(creatureData + 0x25, 0x0)
		local match_general1 = IEex_ReadByte(effectData + 0x1C, 0x0)
		local match_general2 = IEex_ReadByte(effectData + 0x1D, 0x0)
		local match_general3 = IEex_ReadByte(effectData + 0x1E, 0x0)
		local match_general4 = IEex_ReadByte(effectData + 0x1F, 0x0)
		if general == match_general1 or general == match_general2 or general == match_general3 or general == match_general4 then
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
ex_animation_size = {}
--[[
MESPLPR2 works similarly to opcodes 206 and 290. It grants immunity to the spell if the target satisfies a condition.

parameter2 - Determines the condition. If it's true, the target is immune to the spell. The conditions are the same as with
 opcodes 206 and 290, but will take things like Better Racial Enemies into account. There are some extras added at the end, though.
 Here are some of them:
 55: Unnatural (undead, construct, object, or extraplanar creature)
 94: Nonliving (undead, construct, or object)
 96: Mindless (undead, construct, object, shambling mound, or ooze)
 98: Drow or duergar
 100: Light-sensitive (drow, duergar, fungi, shadows, wights, and wraiths)
 

--]]
function MESPLPR2(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	IEex_WriteDword(effectData + 0x110, 1)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	local checkID = targetID
	local newEffectTarget = targetID
	local hasProtection = false
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local protectionType = IEex_ReadDword(effectData + 0x1C)
	local invert = false
	if (protectionType > 0 and protectionType <= 62 and bit32.band(protectionType, 0x1) == 0) or (((protectionType > 63 and protectionType <= 73) or (protectionType > 77)) and bit32.band(protectionType, 0x1) > 0) then
		invert = true
		protectionType = protectionType - 1
	end
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	if bit32.band(savingthrow, 0x20000) > 0 and IEex_IsSprite(sourceID, true) then
		checkID = sourceID
	end
	if bit32.band(savingthrow, 0x200000) > 0 then
		newEffectTarget = sourceID
	end
	local checkData = IEex_GetActorShare(checkID)
	local sourceData = IEex_GetActorShare(sourceID)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	if protectionType == 0 then
		hasProtection = true
	elseif protectionType == 1 and IEex_ReadByte(creatureData + 0x25, 0x0) == 4 then
		hasProtection = true
	elseif protectionType == 3 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		local baseFireResistance = IEex_ReadByte(creatureData + 0x5F1, 0x0)
		if animation == 29456 or animation == 57896 or animation == 60376 or ((animation == 32517 or animation == 32518 or animation == 59176 or animation == 60507 or animation == 62216) and baseFireResistance >= 50) then
			hasProtection = true
		end
	elseif protectionType == 5 and IEex_ReadByte(creatureData + 0x25, 0x0) == 1 then
		hasProtection = true
	elseif protectionType == 7 and IEex_ReadByte(creatureData + 0x25, 0x0) == 2 then
		hasProtection = true
	elseif protectionType == 9 and (IEex_ReadByte(creatureData + 0x26, 0x0) == 152 or IEex_ReadByte(creatureData + 0x26, 0x0) == 161) then
		hasProtection = true
	elseif protectionType == 11 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if animation == 60313 or animation == 60329 or animation == 60337 then
			hasProtection = true
		end
	elseif protectionType == 13 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if parameter1 == 0 then
			parameter1 = 5
		end
		local animationSize = 3
		if ex_animationSize[animation] ~= nil then
			animationSize = ex_animationSize[animation]
			if animationSize >= parameter1 then
				hasProtection = true
			end
		end
	elseif protectionType == 15 and (IEex_ReadByte(creatureData + 0x26, 0x0) == 2 or IEex_ReadByte(creatureData + 0x26, 0x0) == 183) then
		hasProtection = true
	elseif protectionType == 17 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if animation == 59225 or animation == 59385 then
			hasProtection = true
		end
	elseif protectionType == 19 and IEex_ReadByte(creatureData + 0x26, 0x0) == 3 then
		hasProtection = true
	elseif protectionType == 21 and (IEex_ReadByte(creatureData + 0x25, 0x0) == 1 or IEex_ReadByte(creatureData + 0x25, 0x0) == 2) then
		hasProtection = true
	elseif protectionType == 23 then
		local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
		if bit32.band(stateValue, 0x40000) > 0 then
			hasProtection = true
		end
	elseif protectionType == 25 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		local baseColdResistance = IEex_ReadByte(creatureData + 0x5F2, 0x0)
		if animation == 29187 or animation == 31491 or animation == 57656 or animation == 58201 or animation == 58664 or animation == 59192 or animation == 59244 or animation == 59337 or animation == 60184 or animation == 60392 or animation == 60427 or ((animation == 4097 or animation == 59176) and baseColdResistance >= 50) then
			hasProtection = true
		end
	elseif protectionType == 27 and IEex_ReadByte(creatureData + 0x26, 0x0) == ex_construct_race then
		hasProtection = true
	elseif protectionType == 29 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if animation == 59144 then
			hasProtection = true
		end
	elseif protectionType == 31 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if animation == 60313 or animation == 60329 or animation == 60337 or IEex_ReadByte(creatureData + 0x25, 0x0) == 4 then
			hasProtection = true
		end
	elseif protectionType == 33 and bit32.band(IEex_ReadByte(creatureData + 0x35, 0x0), 0x3) == 0x1 then
		hasProtection = true
	elseif protectionType == 35 and bit32.band(IEex_ReadByte(creatureData + 0x35, 0x0), 0x3) == 0x2 then
		hasProtection = true
	elseif protectionType == 37 and bit32.band(IEex_ReadByte(creatureData + 0x35, 0x0), 0x3) == 0x3 then
		hasProtection = true
	elseif protectionType == 39 and IEex_GetActorStat(targetID, 102) > 0 then
		hasProtection = true
	elseif protectionType == 41 and IEex_IsSprite(sourceID, true) then
		local alignment = IEex_ReadByte(creatureData + 0x35, 0x0)
		local sourceAlignment = IEex_ReadByte(sourceData + 0x35, 0x0)
		if bit32.band(alignment, 0x3) == bit32.band(sourceAlignment, 0x3) then
			hasProtection = true
		end
	elseif protectionType == 43 and targetID == sourceID then
		hasProtection = true
	elseif protectionType == 45 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if animation == 58280 or animation == 57912 or animation == 57938 or animation == 58008 or animation == 59368 or animation == 59385 or animation == 62475 or animation == 62491 then
			hasProtection = true
		end
	elseif protectionType == 47 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if IEex_ReadByte(creatureData + 0x25, 0x0) == 4 or IEex_ReadByte(creatureData + 0x26, 0x0) == ex_construct_race then
			hasProtection = true
		end
	elseif protectionType == 49 and IEex_IsSprite(sourceID, true) then
		if IEex_CompareActorAllegiances(targetID, sourceID) == 1 then
			hasProtection = true
		end
	elseif protectionType == 51 and IEex_IsSprite(sourceID, true) then
		if IEex_CompareActorAllegiances(targetID, sourceID) == -1 then
			hasProtection = true
		end
	elseif protectionType == 53 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		local baseFireResistance = IEex_ReadByte(creatureData + 0x5F1, 0x0)
		local baseColdResistance = IEex_ReadByte(creatureData + 0x5F2, 0x0)
		if animation == 29456 or animation == 57896 or animation == 60376 or ((animation == 32517 or animation == 32518 or animation == 59176 or animation == 60507 or animation == 62216) and baseFireResistance >= 50) or animation == 29187 or animation == 31491 or animation == 57656 or animation == 58201 or animation == 58664 or animation == 59192 or animation == 59244 or animation == 59337 or animation == 60184 or animation == 60392 or animation == 60427 or ((animation == 4097 or animation == 59176) and baseColdResistance >= 50) then
			hasProtection = true
		end
	elseif protectionType == 55 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if IEex_ReadByte(creatureData + 0x25, 0x0) == 4 or IEex_ReadByte(creatureData + 0x26, 0x0) == ex_construct_race or IEex_ReadByte(creatureData + 0x26, 0x0) == ex_fiend_race or IEex_ReadByte(creatureData + 0x26, 0x0) == 152 or IEex_ReadByte(creatureData + 0x26, 0x0) == 161 then
			hasProtection = true
		end
	elseif protectionType == 57 and IEex_ReadByte(creatureData + 0x34, 0x0) == 1 then
		hasProtection = true
	elseif protectionType == 59 and bit32.band(IEex_ReadByte(creatureData + 0x35, 0x0), 0x30) == 0x10 then
		hasProtection = true
	elseif protectionType == 61 and bit32.band(IEex_ReadByte(creatureData + 0x35, 0x0), 0x30) == 0x30 then
		hasProtection = true
	elseif protectionType == 64 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if animation == 59400 or animation == 59416 or animation == 59426 or animation == 59448 or animation == 59458 or animation == 59481 or animation == 59496 or animation == 59512 or animation == 59528 or animation == 59609 or animation == 59641 then
			hasProtection = true
		end
	elseif protectionType == 66 and IEex_GetActorSpellState(targetID, 38) then
		hasProtection = true
	elseif protectionType == 68 then
		local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
		if bit32.band(stateValue, 0x10000000) > 0 then
			hasProtection = true
		end
	elseif protectionType == 70 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if animation == 32513 or animation == 61427 then
			hasProtection = true
		end
	elseif protectionType == 72 then
		local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
		if bit32.band(stateValue, 0x1000) > 0 then
			hasProtection = true
		end
	elseif protectionType == 82 then
		if IEex_ReadByte(creatureData + 0x26, 0x0) == 183 or (IEex_ReadByte(creatureData + 0x26, 0x0) == 2 and IEex_ReadByte(creatureData + 0x7FF, 0x0) == 1) then
			hasProtection = true
		end
	elseif protectionType == 84 then
		if IEex_ReadByte(creatureData + 0x26, 0x0) == 185 or (IEex_ReadByte(creatureData + 0x26, 0x0) == 4 and IEex_ReadByte(creatureData + 0x7FF, 0x0) == 2) then
			hasProtection = true
		end
	elseif protectionType == 88 and bit32.band(IEex_ReadWord(IEex_ReadDword(creatureData + 0x12) + 0x40, 0x0), 0x1) > 0 then
		hasProtection = true
	elseif protectionType == 90 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if animation == 61264 or animation == 61280 or animation == 61296 then
			hasProtection = true
		end
	elseif protectionType == 92 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if IEex_ReadByte(creatureData + 0x26, 0x0) == ex_fiend_race or IEex_ReadByte(creatureData + 0x26, 0x0) == 152 or IEex_ReadByte(creatureData + 0x26, 0x0) == 161 then
			hasProtection = true
		end
	elseif protectionType == 94 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if IEex_ReadByte(creatureData + 0x25, 0x0) == 4 or IEex_ReadByte(creatureData + 0x26, 0x0) == ex_construct_race then
			hasProtection = true
		end
	elseif protectionType == 96 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if IEex_ReadByte(creatureData + 0x25, 0x0) == 4 or IEex_ReadByte(creatureData + 0x26, 0x0) == ex_construct_race or animation == 29442 or (animation >= 30976 and animation <= 30979) then
			hasProtection = true
		end
	elseif protectionType == 98 then
		if IEex_ReadByte(creatureData + 0x26, 0x0) == 183 or (IEex_ReadByte(creatureData + 0x26, 0x0) == 2 and IEex_ReadByte(creatureData + 0x7FF, 0x0) == 1) or IEex_ReadByte(creatureData + 0x26, 0x0) == 185 or (IEex_ReadByte(creatureData + 0x26, 0x0) == 4 and IEex_ReadByte(creatureData + 0x7FF, 0x0) == 2) then
			hasProtection = true
		end
	elseif protectionType == 100 then
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if IEex_ReadByte(creatureData + 0x26, 0x0) == 183 or (IEex_ReadByte(creatureData + 0x26, 0x0) == 2 and IEex_ReadByte(creatureData + 0x7FF, 0x0) == 1) or IEex_ReadByte(creatureData + 0x26, 0x0) == 185 or (IEex_ReadByte(creatureData + 0x26, 0x0) == 4 and IEex_ReadByte(creatureData + 0x7FF, 0x0) == 2) or animation == 58153 or animation == 58201 or animation == 58217 or animation == 59656 or animation == 59672 or animation == 60313 or animation == 60329 or animation == 60337 then
			hasProtection = true
		end
	end
	
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
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	if targetID <= 0 or not IEex_IsSprite(sourceID, true) then return end
	local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local school = IEex_ReadDword(effectData + 0x48)
	local sourceSpell = IEex_ReadLString(effectData + 0x18, 8)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	if sourceSpell == "" then
		sourceSpell = parent_resource
	end
	IEex_IterateActorEffects(targetID, function(eData)
		local thesourceID = IEex_ReadDword(eData + 0x110)
		local theschool = IEex_ReadDword(eData + 0x4C)
		local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
		if (thesourceID == sourceID or (thesourceID <= 0 and bit32.band(savingthrow, 0x10000) > 0)) and (((theparent_resource == sourceSpell) and bit32.band(savingthrow, 0x20000) == 0) or ((theschool == school) and bit32.band(savingthrow, 0x20000) > 0)) then
			IEex_WriteDword(eData + 0x28, 0)
			IEex_WriteDword(eData + 0x114, 1)
		end
	end)
end

local state_save_penalties = {
["USWI452"] = {0x4, 6},
["USWI452D"] = {0x4, 6},
}
function MESPLSAV(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceData = IEex_GetActorShare(sourceID)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = bit32.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local savebonus = IEex_ReadDword(effectData + 0x40)
	local saveBonusStat = IEex_ReadByte(effectData + 0x44, 0x0)
	local bonusStatMultiplier = IEex_ReadByte(effectData + 0x45, 0x0)
	local bonusStatDivisor = IEex_ReadByte(effectData + 0x46, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	local sourceSpell = ex_damage_source_spell[parent_resource]
	if sourceSpell == nil then
		sourceSpell = parent_resource
	end
	local classSpellLevel = 0
	if IEex_IsSprite(sourceID, true) then
		classSpellLevel = IEex_GetClassSpellLevel(sourceID, casterClass, sourceSpell)
	end
	savebonus = savebonus + classSpellLevel
	local trueschool = 0
	if ex_trueschool[sourceSpell] ~= nil then
		trueschool = ex_trueschool[sourceSpell]
	end
	if trueschool > 0 then
		local sourceKit = IEex_GetActorStat(sourceID, 89)
		if bit32.band(sourceKit, 0x4000) > 0 then
			savebonus = savebonus + 1
		elseif ex_spell_focus_component_installed then
			if trueschool == 1 and bit32.band(sourceKit, 0x40) > 0 or trueschool == 2 and bit32.band(sourceKit, 0x80) > 0 or trueschool == 3 and bit32.band(sourceKit, 0x100) > 0 or trueschool == 5 and bit32.band(sourceKit, 0x400) > 0 then
				savebonus = savebonus + 2
			elseif trueschool == 1 and bit32.band(sourceKit, 0x2000) > 0 or trueschool == 2 and bit32.band(sourceKit, 0x800) > 0 or trueschool == 3 and bit32.band(sourceKit, 0x1000) > 0 or trueschool == 5 and bit32.band(sourceKit, 0x200) > 0 then
				savebonus = savebonus - 2
			end
		end
	end
	if state_save_penalties[parent_resource] ~= nil then
		local stateValue = bit32.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
		if bit32.band(stateValue, state_save_penalties[parent_resource][1]) > 0 then
			savebonus = savebonus + state_save_penalties[parent_resource][2]
		end
	end
	local saveBonusStatValue = 0
	if IEex_IsSprite(sourceID, true) then
		if bit32.band(savingthrow, 0x40) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x784, 0x0) * 2
		end
		if bit32.band(savingthrow, 0x80) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x785, 0x0) * 2
		end
		if bit32.band(savingthrow, 0x100) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x786, 0x0) * 2
		end
		if bit32.band(savingthrow, 0x200) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x787, 0x0) * 2
		end
		if casterClass == 11 then
			savebonus = savebonus - math.floor((IEex_GetActorStat(sourceID, 38) - 10) / 2)
		elseif casterClass == 3 or casterClass == 4 or casterClass == 7 or casterClass == 8 then
			savebonus = savebonus - math.floor((IEex_GetActorStat(sourceID, 39) - 10) / 2)
		elseif casterClass == 2 or casterClass == 10 then
			savebonus = savebonus - math.floor((IEex_GetActorStat(sourceID, 42) - 10) / 2)
		end
		if saveBonusStat > 0 then
			if (saveBonusStat == 120 or saveBonusStat == 160) and casterClass == 0 then	
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
				saveBonusStatValue = IEex_GetActorStat(sourceID, saveBonusStat)
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
			elseif saveBonusStat ~= 120 and saveBonusStat ~= 160 then
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
		if IEex_GetActorSpellState(sourceID, 242) then
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 242 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if thespecial == trueschool or thespecial == -1 or ((thespecial == 4 or thespecial == 5) and bit32.band(savingthrow, 0x40) > 0) or ((thespecial == 2 or thespecial == 6) and bit32.band(savingthrow, 0x80) > 0) or ((thespecial == 3 or thespecial == 7) and bit32.band(savingthrow, 0x100) > 0) or ((thespecial == 1 or thespecial == 8) and bit32.band(savingthrow, 0x200) > 0) then
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
	if IEex_GetActorSpellState(targetID, 243) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 242 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if thespecial == trueschool or thespecial == -1 or ((thespecial == 4 or thespecial == 5) and bit32.band(savingthrow, 0x40) > 0) or ((thespecial == 2 or thespecial == 6) and bit32.band(savingthrow, 0x80) > 0) or ((thespecial == 3 or thespecial == 7) and bit32.band(savingthrow, 0x100) > 0) or ((thespecial == 1 or thespecial == 8) and bit32.band(savingthrow, 0x200) > 0) then
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

	if bit32.band(savingthrow, 0x10000000) > 0 then
		parent_resource = spellRES
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
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "MEWINGBU", 5) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if IEex_GetActorSpellState(targetID, 212) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local parameter4 = IEex_ReadDword(effectData + 0x60)
	local special = IEex_ReadDword(effectData + 0x44)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local targetX = IEex_ReadDword(creatureData + 0x6)
	local targetY = IEex_ReadDword(creatureData + 0xA)
	local sourceX = targetX
	local sourceY = targetY
	local disableTeleport = false
	local areaData = IEex_ReadDword(creatureData + 0x12)
	local areaRES = ""
	local areaX = 32767
	local areaY = 32767
	if areaData > 0 then
		areaRES = IEex_ReadLString(areaData, 8)
		areaX = IEex_ReadDword(areaData + 0x54C)
		areaY = IEex_ReadDword(areaData + 0x550)
		local areaType = IEex_ReadWord(areaData + 0x40, 0x0)
		if bit32.band(areaType, 0x800) > 0 then
			disableTeleport = true
		else
			if areaRES == "AR4102" and (targetX >= 400 and targetX <= 970 and targetY >= 1030 and targetY <= 1350) then
				disableTeleport = true
			end
		end
	end
	if parameter4 == 0 then
		IEex_WriteDword(effectData + 0x60, 1)
		if parameter2 == 5 or parameter2 == 6 then
			if sourceID > 0 then
				local sourceData = IEex_GetActorShare(sourceID)
				IEex_WriteDword(effectData + 0x7C, IEex_ReadDword(sourceData + 0x6))
				IEex_WriteDword(effectData + 0x80, IEex_ReadDword(sourceData + 0xA))
			end
		end
	end
	if parameter2 == 2 or parameter2 == 4 then
		if sourceID > 0 then
			local sourceData = IEex_GetActorShare(sourceID)
			sourceX = IEex_ReadDword(sourceData + 0x6)
			sourceY = IEex_ReadDword(sourceData + 0xA)
		end
	elseif parameter2 == 1 or parameter2 == 3 then
		sourceX = IEex_ReadDword(effectData + 0x84)
		sourceY = IEex_ReadDword(effectData + 0x88)
	elseif parameter2 == 5 or parameter2 == 6 then
		sourceX = IEex_ReadDword(effectData + 0x7C)
		sourceY = IEex_ReadDword(effectData + 0x80)
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
	if parameter2 == 3 or parameter2 == 4 or parameter2 == 6 then
		if math.abs(deltaX) > math.abs(distX) then
			deltaX = distX
		end
		if math.abs(deltaY) > math.abs(distY) then
			deltaY = distY
		end
		deltaX = deltaX * -1
		deltaY = deltaY * -1
	end
	if bit32.band(savingthrow, 0x10000000) > 0 then
		parent_resource = "MEWINGBU"
	end
	local finalX = targetX + deltaX
	local finalY = targetY + deltaY
	if IEex_IsGamePaused() then
		finalX = targetX
		finalY = targetY
	end
	if finalX < 0 then
		finalX = 1
	elseif finalX >= areaX then
		finalX = areaX - 1
	end
	if finalY < 0 then
		finalY = 1
	elseif finalY >= areaY then
		finalY = areaY - 1
	end
	if not disableTeleport then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 124,
["target"] = 2,
["timing"] = 1,
["source_x"] = targetX,
["source_y"] = targetY,
["target_x"] = finalX,
["target_y"] = finalY,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	end
end

function METELMOV(effectData, creatureData)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "METELMOV", 5) then return end
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

ex_ghostwalk_dest = {}
ex_ghostwalk_area = {}
ex_ghostwalk_offsets = {{-20, -20}, {0, -20}, {20, -20}, {20, 0}, {20, 20}, {0, 20}, {-20, 20}, {-20, 0}, {-10, -30}, {10, -30}, {30, -10}, {30, 10}, {10, 30}, {-10, 30}, {-30, 10}, {-30, -10}}
ex_ghostwalk_positions = {}
ex_ghostwalk_actors = {}
function MEGHOSTW(effectData, creatureData)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_GetActorIDShare(creatureData)
	if IEex_CheckForInfiniteLoop(sourceID, IEex_GetGameTick(), "MEGHOSTW", 0) then return end
--	if not IEex_GetActorSpellState(sourceID, 184) and not IEex_GetActorSpellState(sourceID, 189) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local parameter4 = IEex_ReadDword(effectData + 0x60)
	local movementRate = IEex_ReadByte(creatureData + 0x72EA, 0x0)
	if parameter2 == 0 then
		movementRate = movementRate + parameter1
	elseif parameter2 == 1 then
		movementRate = parameter1
	elseif parameter2 == 2 then
		movementRate = math.floor(movementRate * parameter1 / 100)
	end
	local targetX = IEex_ReadDword(creatureData + 0x6)
	local targetY = IEex_ReadDword(creatureData + 0xA)
	local disableTeleport = false
	local areaData = IEex_ReadDword(creatureData + 0x12)
	local areaRES = ""
	local areaX = 32767
	local areaY = 32767
	if areaData > 0 then
		areaRES = IEex_ReadLString(areaData, 8)
		areaX = IEex_ReadDword(areaData + 0x54C)
		areaY = IEex_ReadDword(areaData + 0x550)
		local areaType = IEex_ReadWord(areaData + 0x40, 0x0)
		if bit32.band(areaType, 0x800) > 0 then
			disableTeleport = true
		elseif bit32.band(areaType, 0x1) == 0 and not IEex_GetActorSpellState(sourceID, 189) then
			disableTeleport = true
		else
			if areaRES == "AR4102" and (targetX >= 400 and targetX <= 970 and targetY >= 1030 and targetY <= 1350) then
				disableTeleport = true
			end
		end
	end
	if parameter4 == 0 or (areaRES ~= "" and ex_ghostwalk_area["" .. sourceID] ~= areaRES) then
		IEex_WriteDword(effectData + 0x60, 1)
		ex_ghostwalk_dest["" .. sourceID] = {0, 0}
	end
	if areaRES ~= "" then
		ex_ghostwalk_area["" .. sourceID] = areaRES
	end
	local storedX = ex_ghostwalk_dest["" .. sourceID][1]
	local storedY = ex_ghostwalk_dest["" .. sourceID][2]
	local duration = IEex_ReadDword(effectData + 0x24)
	local time_applied = IEex_ReadDword(effectData + 0x68)
	local special = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)

	local destinationX = IEex_ReadDword(creatureData + 0x556E)
	local destinationY = IEex_ReadDword(creatureData + 0x5572)
	local targetID = IEex_ReadDword(creatureData + 0x4BE)
	local action = IEex_ReadWord(creatureData + 0x476, 0x0)
	local actionRange = 1
	local moveType = 3
	if action == 29 or action == 184 or action == 250 then
		moveType = 1
	end
	if (IEex_IsSprite(targetID, true) and (action == 31 or action == 113 or action == 191)) or action == 95 or action == 114 or action == 192 then
--[[
		if action == 31 or action == 113 or action == 191 then
			destinationX = IEex_ReadDword(IEex_GetActorShare(targetID) + 0x6)
			destinationY = IEex_ReadDword(IEex_GetActorShare(targetID) + 0xA)
		end
--]]
		local resWrapper = IEex_DemandRes(IEex_ReadLString(IEex_ReadDword(creatureData + 0x538), 8), "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			actionRange = IEex_ReadWord(spellData + 0x90, 0x0)
		end
		resWrapper:free()
		if actionRange > 28 then
			actionRange = 28
		end
		if actionRange >= 6 and ((destinationX - targetX) / 16) ^ 2 + ((destinationY - targetY) / 12) ^ 2 <= actionRange ^ 2 then
			destinationX = targetX
			destinationY = targetY
		elseif targetID ~= sourceID and IEex_GetDistance(destinationX, destinationY, storedX, storedY) < 20 then
			destinationX = 0
			destinationY = 0
		end
	elseif (IEex_IsSprite(targetID, true) and targetID ~= sourceID) or (action == 3 or action == 98 or action == 105 or action == 134) then
--[[
		if IEex_IsSprite(targetID, true) then
			destinationX = IEex_ReadDword(IEex_GetActorShare(targetID) + 0x6)
			destinationY = IEex_ReadDword(IEex_GetActorShare(targetID) + 0xA)
		else
			targetX = destx
			targetY = desty
		end
--]]
		if (action == 3 or action == 98 or action == 105 or action == 134) then
			local equippedWeaponSlot = IEex_ReadByte(creatureData + 0x4BA4, 0x0)
			local equippedWeaponHeader = IEex_ReadByte(creatureData + 0x4BA6, 0x0)
			if equippedWeaponSlot < 11 or equippedWeaponSlot > 14 then
				if IEex_ReadDword(creatureData + 0x4DA8 + equippedWeaponSlot * 0x4) > 0 then
					local resWrapper = IEex_DemandRes(IEex_ReadLString(IEex_ReadDword(creatureData + 0x4DA8 + equippedWeaponSlot * 0x4) + 0xC, 8), "ITM")
					if resWrapper:isValid() then
						local itemData = resWrapper:getData()
						actionRange = IEex_ReadWord(itemData + 0x90 + equippedWeaponHeader * 0x38, 0x0)
					end
					resWrapper:free()
				end
			else
				IEex_IterateActorEffects(sourceID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if theopcode == 288 and theparameter2 == 241 and thespecial == 7 then
						local theresource = IEex_ReadLString(eData + 0x94, 8)
						local resWrapper = IEex_DemandRes(theresource, "ITM")
						if resWrapper:isValid() then
							local itemData = resWrapper:getData()
							actionRange = IEex_ReadWord(itemData + 0x90, 0x0)
						end
						resWrapper:free()
					end
				end)
			end
		end
		if actionRange > 28 then
			actionRange = 28
		end
		if actionRange >= 6 and ((destinationX - targetX) / 16) ^ 2 + ((destinationY - targetY) / 12) ^ 2 <= actionRange ^ 2 then
			destinationX = targetX
			destinationY = targetY
		elseif targetID ~= sourceID and IEex_GetDistance(destinationX, destinationY, storedX, storedY) < 20 then
			destinationX = 0
			destinationY = 0
		end
--[[
	elseif destx > 0 and desty > 0 and (destx ~= storedx or desty ~= storedy) then
		targetX = destx
		targetY = desty
	elseif destx2 > 0 and desty2 > 0 and (destx2 ~= storedx or desty2 ~= storedy) and action ~= 0 then
		targetX = destx2
		targetY = desty2
--]]
	end
	if ((IEex_IsSprite(targetID, true) and targetID ~= sourceID) or action == 3 or action == 134) then
		local targetLocX = destinationX
		local targetLocY = destinationY
		if targetLocX > targetX then
			destinationX = targetLocX - 20
		elseif targetLocX > targetX then
			destinationX = targetLocX + 20
		end
		if targetLocY > targetY then
			destinationY = targetLocY - 20
		elseif targetLocY > targetY then
			destinationY = targetLocY + 20
		end
		local coordinateString = destinationX .. "." .. destinationY
		local otherCoordinateString = "0.0"
		if ex_ghostwalk_positions[coordinateString] == nil or coordinateString == ex_ghostwalk_actors["" .. sourceID] then
			if ex_ghostwalk_actors["" .. sourceID] ~= nil then
				ex_ghostwalk_positions[ex_ghostwalk_actors["" .. sourceID]] = nil
			end
			ex_ghostwalk_actors["" .. sourceID] = coordinateString
			ex_ghostwalk_positions[coordinateString] = sourceID
		else
			local emptySlotFound = false
			if ex_ghostwalk_actors["" .. sourceID] ~= nil then
				ex_ghostwalk_positions[ex_ghostwalk_actors["" .. sourceID]] = nil
			end
			for key,value in pairs(ex_ghostwalk_offsets) do
				if not emptySlotFound then
					otherCoordinateString = (targetLocX + value[1]) .. "." .. (targetLocY + value[2])
					if otherCoordinateString == ex_ghostwalk_actors["" .. sourceID] then
						emptySlotFound = true
						if ex_ghostwalk_actors["" .. sourceID] ~= nil then
							ex_ghostwalk_positions[ex_ghostwalk_actors["" .. sourceID]] = nil
						end
						ex_ghostwalk_actors["" .. sourceID] = otherCoordinateString
						ex_ghostwalk_positions[otherCoordinateString] = sourceID
						destinationX = targetLocX + value[1]
						destinationY = targetLocY + value[2]
					end
				end
			end
			for key,value in pairs(ex_ghostwalk_offsets) do
				if not emptySlotFound then
					otherCoordinateString = (targetLocX + value[1]) .. "." .. (targetLocY + value[2])
					if ex_ghostwalk_positions[otherCoordinateString] == nil then
						emptySlotFound = true
						if ex_ghostwalk_actors["" .. sourceID] ~= nil then
							ex_ghostwalk_positions[ex_ghostwalk_actors["" .. sourceID]] = nil
						end
						ex_ghostwalk_actors["" .. sourceID] = otherCoordinateString
						ex_ghostwalk_positions[otherCoordinateString] = sourceID
						destinationX = targetLocX + value[1]
						destinationY = targetLocY + value[2]
					end
				end
			end
			if not emptySlotFound then
				if ex_ghostwalk_actors["" .. sourceID] ~= nil then
					ex_ghostwalk_positions[ex_ghostwalk_actors["" .. sourceID]] = nil
				end
				ex_ghostwalk_actors["" .. sourceID] = coordinateString
				ex_ghostwalk_positions[coordinateString] = sourceID
			end
		end

		if actionRange >= 6 and ((destinationX - targetX) / 16) ^ 2 + ((destinationY - targetY) / 12) ^ 2 <= actionRange ^ 2 then
			destinationX = targetX
			destinationY = targetY
		end
	end
	if destinationX <= 0 or destinationY <= 0 then
		if storedX > 0 and storedY > 0 then
			destinationX = storedX
			destinationY = storedY
		else
			destinationX = targetX
			destinationY = targetY
		end
	else
		ex_ghostwalk_dest["" .. sourceID][1] = destinationX
		ex_ghostwalk_dest["" .. sourceID][2] = destinationY
	end
	local distX = destinationX - targetX
	local distY = destinationY - targetY
	local dist = math.floor((distX ^ 2 + distY ^ 2) ^ .5)
	local deltaX = 0
	local deltaY = 0
	if dist ~= 0 then
		deltaX = math.floor(movementRate * distX / dist)
		deltaY = math.floor(movementRate * distY / dist)
	end
	if math.abs(deltaX) > math.abs(distX) then
		deltaX = distX
	end
	if math.abs(deltaY) > math.abs(distY) then
		deltaY = distY
	end
	if disableTeleport and IEex_GetActorStat(sourceID, 75) > 0 then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
			if theopcode == 184 and theparent_resource == parent_resource then
				IEex_WriteDword(eData + 0x20, 0)
			end
		end)
	elseif not disableTeleport and IEex_GetActorStat(sourceID, 75) == 0 then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
			if theopcode == 184 and theparent_resource == parent_resource then
				IEex_WriteDword(eData + 0x20, 1)
			end
		end)
	end
	local finalX = targetX + deltaX
	local finalY = targetY + deltaY
	if IEex_IsGamePaused() then
		finalX = targetX
		finalY = targetY
	end
	if finalX < 0 then
		finalX = 1
	elseif finalX >= areaX then
		finalX = areaX - 1
	end
	if finalY < 0 then
		finalY = 1
	elseif finalY >= areaY then
		finalY = areaY - 1
	end
	
	if not disableTeleport then
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 124,
["target"] = 2,
["timing"] = 1,
["source_x"] = targetX,
["source_y"] = targetY,
["target_x"] = finalX,
["target_y"] = finalY,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	end
--[[
	IEex_WriteDword(effectData + 0x110, 0x1)
	if duration == time_applied and not firstIteration then
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 6,
["duration"] = IEex_GetGameTick() + 1,
["parameter1"] = parameter1,
["parameter2"] = parameter2,
["parameter4"] = parameter4,
["resource"] = "MEGHOSTW",
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	else
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 3,
["parameter1"] = parameter1,
["parameter2"] = parameter2,
["parameter4"] = parameter4,
["resource"] = "MEGHOSTW",
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	end
--]]
end

function IEex_RemoveEffectsByResource(actorID, resource_to_remove)
	if not IEex_IsSprite(actorID, false) then return end
	IEex_IterateActorEffects(actorID, function(eData)
		local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
		if theparent_resource == resource_to_remove then
			IEex_WriteDword(eData + 0x114, 1)
		end
	end)
end

function MEREMEFF(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	if spellRES == "" then
		spellRES = IEex_ReadLString(effectData + 0x90, 8)
	end
	IEex_RemoveEffectsByResource(targetID, spellRES)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = spellRES,
["source_id"] = IEex_ReadDword(effectData + 0x10C)
})
end

ex_flying_animation = {[0xC000] = true, [0xC500] = true, [0x7F02] = true, [0xD300] = true, [0xD000] = true, [0xD400] = true, [0xD200] = true, [0x7F05] = true, [0x6405] = true, [0x7320] = true, [0x7321] = true, [0xE269] = true, [0xE289] = true, [0xE928] = true, [0x7F03] = true, [0xE908] = true, [0xE918] = true, [0xE249] = true, [0xE3BB] = true, [0xEF91] = true, [0xA000] = true, [0x1001] = true, [0xEA20] = true, }
ex_can_fly_animation = {[0xC000] = true, [0xC500] = true, [0x7F02] = true, [0xD300] = true, [0xD000] = true, [0xD400] = true, [0xD200] = true, [0x7F05] = true, [0x6405] = true, [0x7320] = true, [0x7321] = true, [0xE269] = true, [0xE289] = true, [0xE928] = true, [0x7F03] = true, [0xE908] = true, [0xE918] = true, [0xE249] = true, [0xE3BB] = true, [0xEF91] = true, [0xA000] = true, [0x1001] = true, [0xEA20] = true, [0xE7C9] = true, [0xEC33] = true, [0xED09] = true, [0x7F06] = true, [0x1201] = true, [0xEC0B] = true, [0xEC4B] = true, [0xEC5B] = true, [0xEF0D] = true, [0xEF1D] = true, [0xEBCD] = true, }
function IEex_IsFlying(actorID)
	if not IEex_IsSprite(actorID, false) then return false end
	local isFlying = false
	local animation = IEex_ReadDword(IEex_GetActorShare(actorID) + 0x5C4)
	if ex_flying_animation[animation] ~= nil or IEex_GetActorSpellState(actorID, 184) or IEex_GetActorSpellState(actorID, 189) then
		isFlying = true
	end
	return isFlying
end

function IEex_CanFly(actorID)
	if not IEex_IsSprite(actorID, false) then return false end
	local isFlying = false
	local animation = IEex_ReadDword(IEex_GetActorShare(actorID) + 0x5C4)
	if ex_can_fly_animation[animation] ~= nil or IEex_GetActorSpellState(actorID, 184) or IEex_GetActorSpellState(actorID, 189) then
		isFlying = true
	end
	return isFlying
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

function MEHGTST(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local animation = IEex_ReadDword(creatureData + 0x5C4)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local special = IEex_ReadDword(effectData + 0x44)
	if special == 0 then
		local height = IEex_ReadSignedWord(creatureData + 0x720, 0x0)
--		IEex_DisplayString(height)
		if parameter2 == 0 then
			IEex_WriteWord(creatureData + 0x720, height + parameter1)
		elseif parameter2 == 1 then
			IEex_WriteWord(creatureData + 0x720, parameter1)
		elseif parameter2 == 2 then
			IEex_WriteWord(creatureData + 0x720, math.floor(height * (parameter1 / 100)))
		end
	elseif special == 1 then
		local speed = IEex_ReadSignedWord(creatureData + 0x722, 0x0)
--		IEex_DisplayString(speed)
		if parameter2 == 0 then
			IEex_WriteWord(creatureData + 0x722, speed + parameter1)
		elseif parameter2 == 1 then
			IEex_WriteWord(creatureData + 0x722, parameter1)
		elseif parameter2 == 2 then
			IEex_WriteWord(creatureData + 0x722, math.floor(speed * (parameter1 / 100)))
		end
	elseif special == 2 then
		local accel = IEex_ReadSignedWord(creatureData + 0x724, 0x0)
--		IEex_DisplayString(accel)
		if parameter2 == 0 then
			IEex_WriteWord(creatureData + 0x724, accel + parameter1)
		elseif parameter2 == 1 then
			IEex_WriteWord(creatureData + 0x724, parameter1)
		elseif parameter2 == 2 then
			IEex_WriteWord(creatureData + 0x724, math.floor(accel * (parameter1 / 100)))
		end
	elseif special == 3 then
		local minHeight = IEex_ReadSignedWord(creatureData + 0x726, 0x0)
--		IEex_DisplayString(minHeight)
		if parameter2 == 0 then
			IEex_WriteWord(creatureData + 0x726, minHeight + parameter1)
		elseif parameter2 == 1 then
			IEex_WriteWord(creatureData + 0x726, parameter1)
		elseif parameter2 == 2 then
			IEex_WriteWord(creatureData + 0x726, math.floor(minHeight * (parameter1 / 100)))
		end
	elseif special == 4 then
		local maxHeight = IEex_ReadSignedWord(creatureData + 0x728, 0x0)
--		IEex_DisplayString(maxHeight)
		if parameter2 == 0 then
			IEex_WriteWord(creatureData + 0x728, maxHeight + parameter1)
		elseif parameter2 == 1 then
			IEex_WriteWord(creatureData + 0x728, parameter1)
		elseif parameter2 == 2 then
			IEex_WriteWord(creatureData + 0x728, math.floor(maxHeight * (parameter1 / 100)))
		end
	end
end

ex_ceiling_height = {["AR1000"] = 32767, ["AR1001"] = 140, ["AR1002"] = 140, ["AR1003"] = 55, ["AR1004"] = 75, ["AR1005"] = 65, ["AR1006"] = 75, ["AR1007"] = 110, ["AR1100"] = 32767, ["AR1101"] = 85, ["AR1102"] = 75, ["AR1103"] = 60, ["AR1104"] = 70, ["AR1105"] = 0, ["AR1106"] = 70, ["AR1107"] = 70, ["AR1200"] = 32767, ["AR1201"] = 75, ["AR2000"] = 32767, ["AR2001"] = 32767, ["AR2002"] = 180, ["AR2100"] = 32767, ["AR2101"] = 32767, ["AR2102"] = 32767, ["AR3000"] = 32767, ["AR3001"] = 160, ["AR3002"] = 170, ["AR3100"] = 32767, ["AR3101"] = 80, ["AR4000"] = 32767, ["AR4001"] = 70, ["AR4100"] = 32767, ["AR4101"] = 90, ["AR4102"] = 90, ["AR4103"] = 90, ["AR5000"] = 32767, ["AR5001"] = 32767, ["AR5002"] = 80, ["AR5004"] = 32767, ["AR5005"] = 32767, ["AR5010"] = 32767, ["AR5011"] = 32767, ["AR5012"] = 32767, ["AR5013"] = 32767, ["AR5014"] = 32767, ["AR5015"] = 32767, ["AR5016"] = 32767, ["AR5017"] = 32767, ["AR5018"] = 32767, ["AR5019"] = 32767, ["AR5020"] = 32767, ["AR5021"] = 32767, ["AR5022"] = 32767, ["AR5023"] = 32767, ["AR5024"] = 32767, ["AR5025"] = 32767, ["AR5026"] = 32767, ["AR5027"] = 32767, ["AR5028"] = 32767, ["AR5029"] = 32767, ["AR5030"] = 32767, ["AR5100"] = 200, ["AR5101"] = 170, ["AR5102"] = 110, ["AR5200"] = 32767, ["AR5201"] = 120, ["AR5202"] = 110, ["AR5203"] = 300, ["AR5300"] = 200, ["AR5301"] = 160, ["AR5302"] = 80, ["AR5303"] = 32767, ["AR6000"] = 32767, ["AR6001"] = 32767, ["AR6002"] = 32767, ["AR6003"] = 160, ["AR6004"] = 75, ["AR6005"] = 130, ["AR6006"] = 110, ["AR6007"] = 70, ["AR6008"] = 320, ["AR6009"] = 250, ["AR6010"] = 110, ["AR6050"] = 32767, ["AR6051"] = 150, ["AR6100"] = 32767, ["AR6101"] = 190, ["AR6102"] = 170, ["AR6103"] = 140, ["AR6104"] = 220, ["AR6200"] = 32767, ["AR6201"] = 32767, ["AR6300"] = 32767, ["AR6301"] = 310, ["AR6302"] = 320, ["AR6303"] = 170, ["AR6304"] = 200, ["AR6305"] = 170, ["AR6400"] = 32767, ["AR6401"] = 100, ["AR6402"] = 270, ["AR6403"] = 140, ["AR6500"] = 250, ["AR6501"] = 320, ["AR6502"] = 120, ["AR6503"] = 100, ["AR6600"] = 200, ["AR6601"] = 160, ["AR6602"] = 110, ["AR6603"] = 215, ["AR6700"] = 95, ["AR6701"] = 110, ["AR6702"] = 230, ["AR6703"] = 32767, ["AR6800"] = 32767, }
function MEHGTMOD(effectData, creatureData)
--	print(IEex_ReadDword(effectData + 0xC))
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
--	if not IEex_IsSprite(sourceID) then return end
	if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "MEHGTMOD", 5) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local parameter3 = IEex_ReadDword(effectData + 0x5C)
	local parameter4 = IEex_ReadDword(effectData + 0x60)
	local special = IEex_ReadDword(effectData + 0x44)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local duration = IEex_ReadDword(effectData + 0x24)
	local time_applied = IEex_ReadDword(effectData + 0x68)
	local firstIteration = false
	local roofHeight = 32767
	local targetHeight = 70
	local targetX = IEex_ReadDword(creatureData + 0x6)
	local targetY = IEex_ReadDword(creatureData + 0xA)
	local disableTeleport = false
	local areaData = IEex_ReadDword(creatureData + 0x12)
	local areaRES = ""
	local areaType = 0
	if areaData > 0 then
		areaRES = IEex_ReadLString(areaData, 8)
		areaType = IEex_ReadWord(areaData + 0x40, 0x0)
		if bit32.band(areaType, 0x800) > 0 then
			disableTeleport = true
--		elseif bit32.band(areaType, 0x1) == 0 and not IEex_GetActorSpellState(sourceID, 189) then
--			disableTeleport = true
		else
			if areaRES == "AR4102" and (targetX >= 400 and targetX <= 970 and targetY >= 1030 and targetY <= 1350) then
				disableTeleport = true
			end
		end
	end
	if ex_ceiling_height[areaRES] ~= nil then
		roofHeight = ex_ceiling_height[areaRES] * 2
	end
	if bit32.band(parameter4, 0x1) == 0 then
		parameter4 = bit32.bor(parameter4, 0x1)
		firstIteration = true
	end
	local animation = IEex_ReadDword(creatureData + 0x5C4)
	local height = IEex_ReadSignedWord(creatureData + 0x720, 0x0)
	local speed = IEex_ReadSignedWord(creatureData + 0x722, 0x0)
	local accel = IEex_ReadSignedWord(creatureData + 0x724, 0x0)
	local extraSpeed = 0
	local extraAccel = 0
	local minHeight = 0
	local maxHeight = 0
	local centerHeight = 0
	local minSpeed = 0
	local previousHeight = height
	if IEex_GetActorSpellState(targetID, 190) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 190 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if thespecial == 1 then
					extraSpeed = extraSpeed + theparameter1
				elseif thespecial == 2 then
					extraAccel = extraAccel + theparameter1
				elseif thespecial == 3 then
					minHeight = minHeight + theparameter1
				elseif thespecial == 4 then
					maxHeight = maxHeight + theparameter1
				elseif thespecial == 5 then
					centerHeight = centerHeight + theparameter1
				elseif thespecial == 6 then
					minSpeed = minSpeed + theparameter1
				end
			end
		end)
	end
	if IEex_GetActorSpellState(targetID, 184) or IEex_GetActorSpellState(targetID, 189) then
		local isSelected = false
		for i, id in ipairs(IEex_GetAllActorIDSelected()) do
			if id == targetID then
				isSelected = true
			end
		end
		if IEex_IsKeyDown(160) and isSelected then
			extraSpeed = extraSpeed + 5
			if accel == -1 then
				accel = 0
			end
		end
		if IEex_IsKeyDown(161) and isSelected then
			extraSpeed = extraSpeed - 5
			if accel == -1 then
				accel = 0
			end
		end
		if speed <= 0 and accel == -1 and IEex_GetActorSpellState(targetID, 189) then
			speed = 0
			accel = 0
		end
	end
	accel = accel + extraAccel
	if minSpeed == 0 then
		minSpeed = -32768
	end
--[[
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = "MEGOOVER",
["source_target"] = targetID,
["source_id"] = sourceID
})
--]]
--[[
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = "MEOVERAC",
["source_target"] = targetID,
["source_id"] = sourceID
})
--]]

	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
		if theparent_resource == "MEOVERAC" then
			IEex_WriteDword(eData + 0x1C, 0)
			IEex_WriteDword(eData + 0x20, 0)
			IEex_WriteDword(eData + 0x28, 0)
			IEex_WriteDword(eData + 0x114, 1)
		end
	end)
--	IEex_RemoveEffectsByResource(targetID, "MEOVERAC")
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["parameter1"] = 0,
["parameter2"] = 0,
["parent_resource"] = "MEOVERAC",
["source_target"] = targetID,
["source_id"] = targetID
})
	if height >= 50 then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 54,
["target"] = 2,
["timing"] = 4096,
["duration"] = IEex_GetGameTick(),
["parameter1"] = -10,
["parent_resource"] = "MEOVERAC",
["source_target"] = targetID,
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 167,
["target"] = 2,
["timing"] = 4096,
["duration"] = IEex_GetGameTick(),
["parameter1"] = 20,
["parent_resource"] = "MEOVERAC",
["source_target"] = targetID,
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 4096,
["duration"] = IEex_GetGameTick(),
["parameter1"] = 20,
["parameter2"] = 4,
["parent_resource"] = "MEOVERAC",
["source_target"] = targetID,
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 4096,
["duration"] = IEex_GetGameTick(),
["parameter1"] = 20,
["parameter2"] = 5,
["parent_resource"] = "MEOVERAC",
["source_target"] = targetID,
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 4096,
["duration"] = IEex_GetGameTick(),
["parameter1"] = 20,
["parameter2"] = 6,
["parent_resource"] = "MEOVERAC",
["source_target"] = targetID,
["source_id"] = targetID
})
--[[
		if bit32.band(areaType, 0x1) > 0 and not disableTeleport then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 184,
["target"] = 2,
["timing"] = 4096,
["duration"] = IEex_GetGameTick(),
["parameter2"] = 1,
["parent_resource"] = "MEGOOVER",
["source_target"] = targetID,
["source_id"] = targetID
})
		end
--]]
	end
	if ((bit32.band(areaType, 0x1) == 0 and not IEex_GetActorSpellState(targetID, 189)) or disableTeleport) and IEex_GetActorStat(targetID, 75) > 0 then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
			if theopcode == 184 and theparent_resource == parent_resource then
				IEex_WriteDword(eData + 0x20, 0)
			end
		end)
	elseif (bit32.band(areaType, 0x1) > 0 or IEex_GetActorSpellState(targetID, 189)) and not disableTeleport and IEex_GetActorStat(targetID, 75) == 0 then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
			if theopcode == 184 and theparent_resource == parent_resource then
				IEex_WriteDword(eData + 0x20, 1)
			end
		end)
	end
	if (minHeight <= 0 or bit32.band(savingthrow, 0x10000) > 0) and bit32.band(savingthrow, 0x20000) == 0 and (height <= minHeight and speed <= 0 and accel <= 0) then 
		IEex_WriteWord(creatureData + 0x720, 0)
		IEex_WriteWord(creatureData + 0x722, 0)
		IEex_WriteWord(creatureData + 0x724, -1)
		IEex_WriteDword(effectData + 0x110, 0x1)
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
			if theparent_resource == parent_resource then
				IEex_WriteDword(eData + 0x114, 1)
			end
		end)
--[[
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
--]]
		if bit32.band(savingthrow, 0x80000) > 0 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 9,
["resource"] = parent_resource .. "E",
["source_target"] = targetID,
["source_id"] = sourceID
})
		end
		IEex_WriteDword(creatureData + 0xE, 0)
--		return 
	end
	if minHeight < 0 then
		minHeight = 0
	end
	if maxHeight <= 0 or maxHeight > 10000 then
		maxHeight = 10000
	end
	if maxHeight > (roofHeight - targetHeight) and not IEex_GetActorSpellState(targetID, 189) then
		if targetHeight >= roofHeight then
			maxHeight = 1
		else
			maxHeight = (roofHeight - targetHeight)
		end
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
			if speed >= 33 and bit32.band(savingthrow, 0x400000) > 0 and maxHeight < 10000 and not IEex_GetActorSpellState(targetID, 189) then
				local damageDice = math.floor((speed - 30) / 3)
				if damageDice > 100 then
					damageDice = 100
				end
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = 0x600 + damageDice * 0x10000,
["savingthrow"] = 0x90000,
["resource"] = "EXDAMAGE",
["parent_resource"] = "MEFALDMG",
["source_target"] = targetID,
["source_id"] = sourceID
})
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 1,
["resource"] = "MEFALDMG",
["source_target"] = targetID,
["source_id"] = sourceID
})
			end
			speed = 0
		end
	end
	height = height + speed + extraSpeed
	if height - speed < centerHeight then
		speed = speed - accel
	elseif height - speed > centerHeight then
		speed = speed + accel
	end
	if speed <= minSpeed then
		speed = minSpeed + 1
	end

	if height <= minHeight then
		height = minHeight
		
		if speed < 0 then
			if speed <= -33 and bit32.band(savingthrow, 0x400000) > 0 and (minHeight <= 0 or bit32.band(savingthrow, 0x10000) > 0) and not IEex_GetActorSpellState(targetID, 189) then
				local damageDice = math.floor(math.abs(speed + 30) / 3)
				if damageDice > 100 then
					damageDice = 100
				end
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = 0x600 + damageDice * 0x10000,
["savingthrow"] = 0x90000,
["resource"] = "EXDAMAGE",
["parent_resource"] = "MEFALDMG",
["source_target"] = targetID,
["source_id"] = sourceID
})
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 1,
["resource"] = "MEFALDMG",
["source_target"] = targetID,
["source_id"] = sourceID
})
			end
			speed = 0
		end
	elseif height >= maxHeight then
		height = maxHeight - 1
		if speed > 0 then
			if speed >= 33 and bit32.band(savingthrow, 0x400000) > 0 and maxHeight < 10000 and not IEex_GetActorSpellState(targetID, 189) then
				local damageDice = math.floor((speed - 30) / 3)
				if damageDice > 100 then
					damageDice = 100
				end
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = 0x600 + damageDice * 0x10000,
["savingthrow"] = 0x90000,
["resource"] = "EXDAMAGE",
["parent_resource"] = "MEFALDMG",
["source_target"] = targetID,
["source_id"] = sourceID
})
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 1,
["resource"] = "MEFALDMG",
["source_target"] = targetID,
["source_id"] = sourceID
})
			end
			speed = 0
		end
	end
--	if bit32.band(IEex_ReadDword(creatureData + 0x434), 0x2000) > 0 then return end

	if ((minHeight > 0 and bit32.band(savingthrow, 0x10000) == 0) or (height > minHeight)) and not (IEex_IsFlying(targetID)) then

		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 266,
["target"] = 2,
["timing"] = 4096,
["duration"] = IEex_GetGameTick(),
["parameter2"] = 1,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})

	end

	IEex_WriteWord(creatureData + 0x720, height)
	IEex_WriteWord(creatureData + 0x722, speed)
	local visualHeight = -math.ceil(height / 2)
	if visualHeight > 0 or visualHeight == -0 then
		visualHeight = 0
	end

	IEex_WriteDword(creatureData + 0xE, visualHeight)
	IEex_WriteDword(creatureData + 0x5326, 0)
--	IEex_WriteDword(effectData + 0x110, 0x1)
--[[
	if bit32.band(savingthrow, 0x100000) > 0 then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 337,
["target"] = 2,
["timing"] = 1,
["parameter1"] = parameter2,
["parameter2"] = 402,
["parameter3"] = parameter3,
["parameter4"] = parameter4,
["resource"] = "MEHGTMOD",
["special"] = special,
["casterlvl"] = casterlvl,
["parent_resource"] = "MEHGTREM",
["source_target"] = targetID,
["source_id"] = sourceID
})
	end

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
--]]
end

ex_default_terrain_table_1 = {-1, 5, 5, 5, 5, 5, 5, 5, -1, 5, -1, 5, -1, -1, -1, 5}
ex_default_terrain_table_2 = {-1, 5, 5, 5, 5, 5, 5, 5, 5, 5, -1, 5, 5, -1, 5, 5}
ex_default_terrain_table_3 = {-1, 5, 5, 5, 5, 5, 5, 5, 5, 5, -1, 5, 5, -1, 5, 5}

function MESMDAOE(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if IEex_GetActorShare(sourceID) <= 0 then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local special = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local found_it = false
	IEex_IterateIDs(IEex_ReadDword(creatureData + 0x12), 0, true, true, function(id)
		local projectileData = IEex_GetActorShare(id)
		if found_it == false and (IEex_ReadWord(projectileData + 0x6E, 0x0) == special or special == -1) and IEex_ReadDword(projectileData + 0x72) == sourceID then
			found_it = true
			IEex_WriteWord(projectileData + 0x2AE, math.floor(IEex_ReadWord(projectileData + 0x2AE, 0x0) * parameter1 / 100))
		end
	end)
end

function MEFINDTR(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if IEex_GetActorShare(sourceID) <= 0 then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local special = IEex_ReadDword(effectData + 0x44)
	local targetx = IEex_ReadDword(effectData + 0x84)
	local targety = IEex_ReadDword(effectData + 0x88)
	if targetx <= 0 or targety <= 0 then
		targetx = IEex_ReadDword(creatureData + 0x6)
		targety = IEex_ReadDword(creatureData + 0xA)
	end
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local areaData = IEex_ReadDword(creatureData + 0x12)
	IEex_IterateIDs(areaData, 0x11, true, true, function(id)
		local containerData = IEex_GetActorShare(id)
		if special <= 0 or IEex_GetDistance(targetx, targety, IEex_ReadDword(containerData + 0x6), IEex_ReadDword(containerData + 0xA)) < special then
			if bit32.band(IEex_ReadDword(containerData + 0x88E), 0x20) == 0 and IEex_ReadWord(containerData + 0x892, 0x0) ~= 100 and IEex_ReadWord(containerData + 0x896, 0x0) > 0 then
				IEex_WriteWord(containerData + 0x898, 1)
				IEex_WriteWord(containerData + 0x8D0, 362)
			end
		end
	end)
	IEex_IterateIDs(areaData, 0x21, true, true, function(id)
		local doorData = IEex_GetActorShare(id)
		if special <= 0 or IEex_GetDistance(targetx, targety, IEex_ReadDword(doorData + 0x6), IEex_ReadDword(doorData + 0xA)) < special then
			local doorFlags = IEex_ReadDword(doorData + 0x5C4)
			if bit32.band(doorFlags, 0x8) > 0 and (bit32.band(doorFlags, 0x80) == 0 or bit32.band(doorFlags, 0x100) > 0) and bit32.band(doorFlags, 0x2000) == 0 and IEex_ReadWord(doorData + 0x648, 0x0) ~= 100 and IEex_ReadWord(doorData + 0x64C, 0x0) > 0 then
				IEex_WriteWord(doorData + 0x64E, 1)
				IEex_WriteWord(doorData + 0x664, 362)
			end
		end
	end)
	IEex_IterateIDs(areaData, 0x41, true, true, function(id)
		local triggerData = IEex_GetActorShare(id)
		if special <= 0 or IEex_GetDistance(targetx, targety, IEex_ReadDword(triggerData + 0x6), IEex_ReadDword(triggerData + 0xA)) < special then
			local triggerFlags = IEex_ReadDword(triggerData + 0x5D6)
			if IEex_ReadWord(triggerData + 0x598, 0x0) == 0 and bit32.band(triggerFlags, 0x8) > 0 and bit32.band(triggerFlags, 0x100) == 0 and IEex_ReadWord(triggerData + 0x60E, 0x0) ~= 100 and IEex_ReadWord(triggerData + 0x612, 0x0) > 0 then
				IEex_WriteWord(triggerData + 0x614, 1)
				IEex_WriteWord(triggerData + 0x626, 263)
			end
		end
	end)
end

function MENPCXP(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local sourceData = IEex_GetActorShare(sourceID)
	if sourceData <= 0 then return end
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
	if sourceData == 0 then return end
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
	local summonerData = IEex_GetActorShare(summonerID)
	if summonererData <= 0 then return end
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

function MEREANIM(effectData, creatureData)
	local nonliving_race = {["" .. ex_construct_race] = 1, ["" .. ex_fiend_race] = 1, ["108"] = 1, ["115"] = 1, ["120"] = 1, ["152"] = 1, ["156"] = 1, ["164"] = 1, ["167"] = 1, ["175"] = 1, ["178"] = 1, ["190"] = 1, ["192"] = 1, ["201"] = 1, ["202"] = 1, ["203"] = 1, ["204"] = 1, ["205"] = 1, ["206"] = 1, ["207"] = 1, ["208"] = 1, ["209"] = 1, ["210"] = 1, ["211"] = 1, ["212"] = 1, ["213"] = 1, ["214"] = 1, ["215"] = 1, ["255"] = 1, }
--	IEex_WriteDword(effectData + 0x110, 0x1)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local sourceData = IEex_GetActorShare(sourceID)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local getHighestLevel = (bit32.band(savingthrow, 0x100000) > 0)
	local ignoreHigherLevel = (bit32.band(savingthrow, 0x200000) > 0)
	local includeNonliving = (bit32.band(savingthrow, 0x800000) > 0)
	local recruitTarget = (bit32.band(savingthrow, 0x1000000) > 0)
	local maxDistance = IEex_ReadDword(effectData + 0x44)
	local casterlvl = IEex_ReadByte(effectData + 0xC4, 0x0)
	local targetX = IEex_ReadDword(effectData + 0x84)
	local targetY = IEex_ReadDword(effectData + 0x88)
	local areaActorIDList = IEex_GetIDArea(sourceID, 0x31, true, true)
	local actorX = 0
	local actorY = 0
	local currentShare = 0
	local currentStates = 0
	local currentDistance = 0
	local shortestDistance = 32767
	local currentLevel = 0
	local highestLevel = 0
	local chosenID = 0
	for k, v in ipairs(areaActorIDList) do
		if IEex_IsSprite(v, true) then
			currentShare = IEex_GetActorShare(v)
			actorX = IEex_ReadDword(currentShare + 0x6)
			actorY = IEex_ReadDword(currentShare + 0xA)
			currentStates = IEex_ReadDword(currentShare + 0x5BC)
			if bit32.band(currentStates, 0xE00) > 0 and bit32.band(currentStates, 0xC0) == 0 and (IEex_ReadDword(currentShare + 0x5C4) > 1000) and (includeNonliving or (IEex_ReadByte(currentShare + 0x25, 0x0) ~= 4 and nonliving_race["" .. IEex_ReadByte(currentShare + 0x26, 0x0)] == nil)) then
				currentDistance = IEex_GetDistance(targetX, targetY, actorX, actorY)
				currentLevel = IEex_ReadByte(currentShare + 0x626, 0x0)
				if IEex_ReadDword(sourceData + 0x12) == IEex_ReadDword(currentShare + 0x12) and (maxDistance <= 0 or currentDistance <= maxDistance) and (currentDistance < shortestDistance or (getHighestLevel and currentLevel > highestLevel)) and (ignoreHigherLevel == false or currentLevel <= casterlvl + ex_reanimation_level_check_bonus) and (getHighestLevel == false or highestLevel <= currentLevel) then
					shortestDistance = currentDistance
					highestLevel = currentLevel
					chosenID = v
				end
			end
		end
	end
	if chosenID > 0 then
		
		currentShare = IEex_GetActorShare(chosenID)
		actorX = IEex_ReadDword(currentShare + 0x6)
		actorY = IEex_ReadDword(currentShare + 0xA)

		currentStates = IEex_ReadDword(currentShare + 0x5BC)
--		IEex_WriteDword(currentShare + 0x5BC, bit32.band(currentStates, 0xFFFFFAFF)) 
--		IEex_WriteDword(currentShare + 0x920, bit32.band(IEex_ReadDword(currentShare + 0x920), 0xFFFFFAFF)) 
		IEex_WriteWord(currentShare + 0x5C0, 0)
		IEex_WriteLString(currentShare + 0x56DC, "", 8)
		IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 32,
["target"] = 2,
["parameter2"] = 0,
["timing"] = 9,
["parent_resource"] = parent_resource,
["source_target"] = chosenID,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 17,
["target"] = 2,
["parameter1"] = 100,
["parameter2"] = 2,
["timing"] = 1,
["parent_resource"] = parent_resource,
["source_target"] = chosenID,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 72,
["target"] = 2,
["parameter1"] = 4,
["parameter2"] = 1,
["timing"] = 1,
["parent_resource"] = parent_resource,
["source_target"] = chosenID,
["source_id"] = sourceID
})
		local reanimatedEA = 4
		local sourceEA = IEex_ReadByte(sourceData + 0x24, 0x0)
		if sourceEA <= 30 then		
			IEex_WriteLString(currentShare + 0x810, "", 8)
			IEex_WriteLString(currentShare + 0x750, "", 8)
			IEex_WriteLString(currentShare + 0x4FFC, "", 8)
			IEex_WriteLString(currentShare + 0x818, "", 8)
			IEex_WriteLString(currentShare + 0x820, "", 8)
			IEex_WriteLString(currentShare + 0x828, "", 8)
			IEex_WriteLString(currentShare + 0x830, "", 8)
--[[
			IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 82,
["target"] = 2,
["parameter2"] = 0,
["timing"] = 1,
["resource"] = "MENOBCS",
["parent_resource"] = parent_resource,
["source_target"] = chosenID,
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 82,
["target"] = 2,
["parameter2"] = 1,
["timing"] = 1,
["resource"] = "MENOBCS",
["parent_resource"] = parent_resource,
["source_target"] = chosenID,
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 82,
["target"] = 2,
["parameter2"] = 2,
["timing"] = 1,
["resource"] = "MENOBCS",
["parent_resource"] = parent_resource,
["source_target"] = chosenID,
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 82,
["target"] = 2,
["parameter2"] = 4,
["timing"] = 1,
["resource"] = "MENOBCS",
["parent_resource"] = parent_resource,
["source_target"] = chosenID,
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 82,
["target"] = 2,
["parameter2"] = 5,
["timing"] = 1,
["resource"] = "MENOBCS",
["parent_resource"] = parent_resource,
["source_target"] = chosenID,
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 82,
["target"] = 2,
["parameter2"] = 6,
["timing"] = 1,
["resource"] = "MENOBCS",
["parent_resource"] = parent_resource,
["source_target"] = chosenID,
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 82,
["target"] = 2,
["parameter2"] = 7,
["timing"] = 1,
["resource"] = "MENOBCS",
["parent_resource"] = parent_resource,
["source_target"] = chosenID,
["source_id"] = sourceID
})
--]]
		else
			reanimatedEA = sourceEA
		end

		IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 72,
["target"] = 2,
["parameter1"] = reanimatedEA,
["parameter2"] = 0,
["timing"] = 9,
["parent_resource"] = "MEREANEA",
["source_target"] = chosenID,
["source_id"] = sourceID
})
		if spellRES ~= "" then
			IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 9,
["resource"] = spellRES,
["parent_resource"] = spellRES,
["casterlvl"] = casterlvl,
["source_target"] = chosenID,
["source_id"] = sourceID
})
		end
		local containerX = 0
		local containerY = 0
		local closestContainer = 0
		currentDistance = 0
		shortestDistance = 32767
		IEex_IterateIDs(IEex_ReadDword(currentShare + 0x14), 0x11, false, true, function(containerID)
			local containerData = IEex_GetActorShare(containerID)
			containerX = IEex_ReadDword(containerData + 0x6)
			containerY = IEex_ReadDword(containerData + 0xA)
			currentDistance = IEex_GetDistance(actorX, actorY, containerX, containerY)
			if currentDistance < 20 and currentDistance < shortestDistance and IEex_ReadWord(containerData + 0x5CA, 0x0) == 4 then
				shortestDistance = currentDistance
				closestContainer = containerData
			end
		end)
		if closestContainer > 0 then
			local inventoryItems = {}
			for i = 1, 51, 1 do
				local invItemInfo = IEex_ReadDword(currentShare + 0x4AD4 + i * 0x4)
				if invItemInfo <= 0 then
					table.insert(inventoryItems, "")
				else
					table.insert(inventoryItems, IEex_ReadLString(invItemInfo + 0xC, 8))
				end
			end
			IEex_IterateCPtrList(closestContainer + 0x5AE, function(containerItemData)
				local itemRES = IEex_ReadLString(containerItemData + 0xC, 8)
				local charges1 = IEex_ReadWord(containerItemData + 0x18, 0x0)
				local charges2 = IEex_ReadWord(containerItemData + 0x1A, 0x0)
				local charges3 = IEex_ReadWord(containerItemData + 0x1C, 0x0)
				local resWrapper = IEex_DemandRes(itemRES, "ITM")
				local itemData = 0
				if resWrapper:isValid() then
					itemData = resWrapper:getData()
				end
				if itemData > 0 then
					local itemSlotChoices = me_item_type_slots[IEex_ReadWord(itemData + 0x1C, 0x0)]
					local chosenItemSlot = -1
					if itemSlotChoices ~= nil then
						
						for sloti, slot in ipairs(itemSlotChoices) do
							if (slot == 43 or slot == 45 or slot == 47 or slot == 49) and chosenItemSlot == -1 and inventoryItems[slot + 1] ~= "" and inventoryItems[slot + 2] == "" and (IEex_ReadByte(currentShare + 0x62E, 0x0) > 0 or bit32.band(IEex_ReadDword(currentShare + 0x75C), 0x2) > 0) and IEex_ReadByte(itemData + 0x82, 0x0) == 1 and bit32.band(IEex_ReadDword(itemData + 0x18), 0x2) == 0 then
								local rightItemWrapper = resWrapper
								if itemRES ~= inventoryItems[slot + 1] then
									rightItemWrapper = IEex_DemandRes(inventoryItems[slot + 1], "ITM")
									local rightItemData = rightItemWrapper:getData()
									if rightItemWrapper:isValid() and IEex_ReadByte(rightItemData + 0x72, 0x0) == 1 and bit32.band(IEex_ReadDword(rightItemData + 0x18), 0x2) == 0 then
										chosenItemSlot = slot + 1
										inventoryItems[slot + 2] = itemRES
									end
									rightItemWrapper:free()
								else
									local rightItemData = itemData
									if IEex_ReadByte(rightItemData + 0x72, 0x0) == 1 and bit32.band(IEex_ReadDword(rightItemData + 0x18), 0x2) == 0 then
										chosenItemSlot = slot + 1
										inventoryItems[slot + 2] = itemRES
									end
								end
							elseif chosenItemSlot == -1 and inventoryItems[slot + 1] == "" then
								chosenItemSlot = slot
								inventoryItems[slot + 1] = itemRES
							end
						end
					end
					if chosenItemSlot == -1 then
						itemSlotChoices = {18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41}
						for sloti, slot in ipairs(itemSlotChoices) do
							if chosenItemSlot == -1 and inventoryItems[slot + 1] == "" then
								chosenItemSlot = slot
								inventoryItems[slot + 1] = itemRES
							end
						end
					end
					if chosenItemSlot ~= -1 then
						IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 143,
["target"] = 2,
["timing"] = 1,
["parameter1"] = chosenItemSlot,
["parameter2"] = 2,
["resource"] = itemRES,
["source_target"] = chosenID,
["source_id"] = chosenID
})
						if charges1 > 1 or charges2 > 1 or charges3 > 1 then
							IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = charges1,
["parameter2"] = 1,
["parameter3"] = charges2,
["parameter4"] = charges3,
["special"] = chosenItemSlot,
["savingthrow"] = 0x80000,
["resource"] = "EXCHARGE",
["source_target"] = chosenID,
["source_id"] = chosenID
})
							
						end
						
					end
				end
				resWrapper:free()
			end)
--[[
			IEex_ApplyEffectToActor(chosenID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["resource"] = "MEEQUIPR",
["source_target"] = chosenID,
["source_id"] = chosenID
})
--]]
			IEex_WriteByte(closestContainer + 0x863, 1)
		end
	end
end

function MEEQUIPR(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 0x1)
	local targetID = IEex_GetActorIDShare(creatureData)
	local launcherSlot = 0
	local ammoRES = ""
	local ammoInfo = IEex_ReadDword(creatureData + 0xAAC)
	local ammoData = 0
	if ammoInfo > 0 then
		ammoRES = IEex_ReadLString(ammoInfo + 0x8, 8)
		ammoData = IEex_DemandResData(ammoRES, "ITM")
	end
	for i = 1, 4, 1 do
		local invItemInfo = IEex_ReadDword(creatureData + 0xB08 + i * 4)
		if invItemInfo > 0 then
			local itemRES = IEex_ReadLString(invItemInfo + 0xC, 8)
			local charges1 = IEex_ReadWord(invItemInfo + 0x14, 0x0)
			local resWrapper = IEex_DemandRes(itemRES, "ITM")
			local itemData = 0
			if resWrapper:isValid() then
				itemData = resWrapper:getData()
			end
			if itemData > 0 then
				local itemName = IEex_ReadDword(itemData + 0x8)
				local itemType = IEex_ReadWord(itemData + 0x1C, 0x0)
				local itemIcon = IEex_ReadLString(itemData + 0x3A, 8)
				local slotData = creatureData + 0x266C + i * 0x34
				if (itemType == 15 or itemType == 18 or itemType == 27) and IEex_ReadByte(itemData + 0x72, 0x0) == 4 and ammoData > 0 and launcherSlot == 0 then
					launcherSlot = i
					IEex_WriteLString(slotData, IEex_ReadLString(ammoData + 0x3A, 8), 8)
					IEex_WriteDword(slotData + 0x8, IEex_ReadDword(ammoData + 0x8))
					IEex_WriteLString(slotData + 0xC, itemIcon, 8)
					IEex_WriteDword(slotData + 0x14, itemName)
					IEex_WriteWord(slotData + 0x18, IEex_ReadWord(ammoInfo + 0x14, 0x0))
					IEex_WriteWord(slotData + 0x1E, 11)
					IEex_WriteLString(slotData + 0x22, ammoRES, 8)
					IEex_WriteDword(slotData + 0x2C, IEex_ReadDword(ammoData + 0x8))
					slotData = creatureData + 0x3574
					IEex_WriteLString(slotData, IEex_ReadLString(ammoData + 0x3A, 8), 8)
					IEex_WriteDword(slotData + 0x8, IEex_ReadDword(ammoData + 0x8))
					IEex_WriteLString(slotData + 0xC, itemIcon, 8)
					IEex_WriteDword(slotData + 0x14, itemName)
					IEex_WriteWord(slotData + 0x18, IEex_ReadWord(ammoInfo + 0x14, 0x0))
					IEex_WriteWord(slotData + 0x1E, 11)
					IEex_WriteLString(slotData + 0x22, ammoRES, 8)
					IEex_WriteDword(slotData + 0x2C, IEex_ReadDword(ammoData + 0x8))
				else
					IEex_WriteLString(slotData, itemIcon, 8)
					IEex_WriteDword(slotData + 0x8, itemName)
					IEex_WriteLString(slotData + 0xC, "", 8)
					IEex_WriteDword(slotData + 0x14, 0)
					IEex_WriteWord(slotData + 0x18, charges1)
					IEex_WriteWord(slotData + 0x1E, 34 + i)
					IEex_WriteLString(slotData + 0x22, itemRES, 8)
					IEex_WriteDword(slotData + 0x2C, itemName)
					if i == 1 then
						IEex_WriteByte(slotData + 0x30, 0)
						slotData = creatureData + 0x3574
						IEex_WriteLString(slotData, itemIcon, 8)
						IEex_WriteDword(slotData + 0x8, itemName)
						IEex_WriteLString(slotData + 0xC, "", 8)
						IEex_WriteDword(slotData + 0x14, 0)
						IEex_WriteWord(slotData + 0x18, charges1)
						IEex_WriteWord(slotData + 0x1E, 34 + i)
						IEex_WriteLString(slotData + 0x22, itemRES, 8)
						IEex_WriteDword(slotData + 0x2C, itemName)
						IEex_WriteByte(slotData + 0x30, 0)
					end
				end
			end
		end
	end
	if launcherSlot == 1 then
		IEex_WriteByte(creatureData + 0xB1C, 11)
		IEex_WriteByte(creatureData + 0x3572, 11)
	else
		IEex_WriteByte(creatureData + 0xB1C, 35)
		IEex_WriteByte(creatureData + 0x3572, 35)
	end
	IEex_WriteByte(creatureData + 0x3AC0, 1)
end

me_item_type_slots = {
[0] = {15, 16, 17},
[1] = {0},
[2] = {1},
[3] = {2},
[4] = {3},
[5] = {11, 12, 13},
[6] = {5},
[7] = {6},
[9] = {15, 16, 17},
[10] = {7, 8},
[11] = {15, 16, 17},
[12] = {44, 46, 48, 50},
[13] = {15, 16, 17},
[14] = {11, 12, 13},
[15] = {43, 45, 47, 49},
[16] = {43, 45, 47, 49},
[17] = {43, 45, 47, 49},
[18] = {43, 45, 47, 49},
[19] = {43, 45, 47, 49},
[20] = {43, 45, 47, 49},
[21] = {43, 45, 47, 49},
[22] = {43, 45, 47, 49},
[23] = {43, 45, 47, 49},
[24] = {43, 45, 47, 49},
[25] = {43, 45, 47, 49},
[26] = {43, 45, 47, 49},
[27] = {43, 45, 47, 49},
[28] = {43, 45, 47, 49},
[29] = {43, 45, 47, 49},
[30] = {43, 45, 47, 49},
[31] = {11, 12, 13},
[32] = {4},
[35] = {15, 16, 17},
[41] = {44, 46, 48, 50},
[44] = {43, 45, 47, 49},
[47] = {44, 46, 48, 50},
[49] = {44, 46, 48, 50},
[51] = {15, 16, 17},
[53] = {44, 46, 48, 50},
[57] = {43, 45, 47, 49},
[60] = {1},
[61] = {1},
[62] = {1},
[63] = {1},
[64] = {1},
[65] = {1},
[66] = {1},
[67] = {1},
[68] = {1},
[69] = {43, 45, 47, 49},
[72] = {6},
[73] = {5},
}
function EXCHARGE(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	local targetID = IEex_GetActorIDShare(creatureData)
	local chargeMod1 = IEex_ReadDword(effectData + 0x18)
	local chargeMod2 = IEex_ReadDword(effectData + 0x5C)
	local chargeMod3 = IEex_ReadDword(effectData + 0x60)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local doNotModifyQuantity = (bit32.band(savingthrow, 0x10000) > 0)
	local doNotModifyCharges = (bit32.band(savingthrow, 0x20000) > 0)
	local goOverMaximum = (bit32.band(savingthrow, 0x40000) > 0)
	if bit32.band(savingthrow, 0x80000) == 0 then
		chargeMod2 = chargeMod1
		chargeMod3 = chargeMod1
	end
	local special = IEex_ReadDword(effectData + 0x44)
	local invItemData = IEex_ReadDword(currentShare + 0x4AD8 + special * 0x4)
	if invItemData > 0 then
		local charges1 = IEex_ReadWord(invItemData + 0x18, 0x0)
		local charges2 = IEex_ReadWord(invItemData + 0x1A, 0x0)
		local charges3 = IEex_ReadWord(invItemData + 0x1C, 0x0)
		local resWrapper = IEex_DemandRes(IEex_ReadLString(invItemData + 0xC, 8), "ITM")
		local itemData = 0
		if resWrapper:isValid() then
			itemData = resWrapper:getData()
		end
		if itemData > 0 then
			local maxQuantity = IEex_ReadWord(itemData + 0x38, 0x0)
			local numAbilities = IEex_ReadWord(itemData + 0x68, 0x0)
			if numAbilities >= 1 then
				local maxCharges1 = IEex_ReadWord(itemData + 0xA4, 0x0)
				if maxCharges1 > 0 and bit32.band(IEex_ReadDword(itemData + 0xA8), 0x100000) == 0 and ((maxQuantity > 1 and doNotModifyQuantity == false) or (maxQuantity <= 1 and doNotModifyCharges == false)) then
					if parameter2 == 0 then
						charges1 = charges1 + chargeMod1
					elseif parameter2 == 1 then
						charges1 = chargeMod1
					elseif parameter2 == 2 then
						charges1 = math.floor(charges1 * chargeMod1 / 100)
					end
					if charges1 <= 0 then
						charges1 = 1
					elseif goOverMaximum == false then
						if maxQuantity > 1 and charges1 > maxQuantity then
							charges1 = maxQuantity
						elseif maxQuantity <= 1 and charges1 > maxCharges1 then
							charges1 = maxCharges1
						end
					elseif charges1 > 32767 then
						charges1 = 32767
					end
					IEex_WriteWord(invItemData + 0x18, charges1)
				end
			end
			if numAbilities >= 2 then
				local maxCharges2 = IEex_ReadWord(itemData + 0xDC, 0x0)
				if maxCharges2 > 0 and bit32.band(IEex_ReadDword(itemData + 0xE0), 0x100000) == 0 and ((maxQuantity > 1 and doNotModifyQuantity == false) or (maxQuantity <= 1 and doNotModifyCharges == false)) then
					if parameter2 == 0 then
						charges2 = charges2 + chargeMod2
					elseif parameter2 == 1 then
						charges2 = chargeMod2
					elseif parameter2 == 2 then
						charges2 = math.floor(charges2 * chargeMod2 / 100)
					end
					if charges2 <= 0 then
						charges2 = 1
					elseif goOverMaximum == false then
						if maxQuantity > 1 and charges2 > maxQuantity then
							charges2 = maxQuantity
						elseif maxQuantity <= 1 and charges2 > maxCharges2 then
							charges2 = maxCharges2
						end
					elseif charges2 > 32767 then
						charges2 = 32767
					end
					IEex_WriteWord(invItemData + 0x1A, charges2)
				end
			end
			if numAbilities >= 3 then
				local maxCharges3 = IEex_ReadWord(itemData + 0x114, 0x0)
				if maxCharges3 > 0 and bit32.band(IEex_ReadDword(itemData + 0x118), 0x100000) == 0 and ((maxQuantity > 1 and doNotModifyQuantity == false) or (maxQuantity <= 1 and doNotModifyCharges == false)) then
					if parameter2 == 0 then
						charges3 = charges3 + chargeMod3
					elseif parameter2 == 1 then
						charges3 = chargeMod3
					elseif parameter2 == 2 then
						charges3 = math.floor(charges3 * chargeMod3 / 100)
					end
					if charges3 <= 0 then
						charges3 = 1
					elseif goOverMaximum == false then
						if maxQuantity > 1 and charges3 > maxQuantity then
							charges3 = maxQuantity
						elseif maxQuantity <= 1 and charges3 > maxCharge3 then
							charges3 = maxCharges3
						end
					elseif charges3 > 32767 then
						charges3 = 32767
					end
					IEex_WriteWord(invItemData + 0x1C, charges3)
				end
			end
		end
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

opcodenames = {[3] = ex_str_berserk, [5] = ex_str_charm, [12] = ex_str_damage, [17] = ex_str_healing, [20] = ex_str_invisibility, [23] = ex_str_moralefailure, [24] = ex_str_fear, [25] = ex_str_poison, [38] = ex_str_silence, [39] = ex_str_sleep, [40] = ex_str_slow, [45] = ex_str_stun, [58] = ex_str_dispelling, [60] = ex_str_spellfailure, [74] = ex_str_blindness, [76] = ex_str_feeblemindedness, [78] = ex_str_disease, [80] = ex_str_deafness, [93] = ex_str_fatigue, [94] = ex_str_intoxication, [109] = ex_str_paralysis, [124] = ex_str_teleportation, [128] = ex_str_confusion, [134] = ex_str_petrification, [135] = ex_str_polymorphing, [154] = ex_str_entangle, [157] = ex_str_web, [158] = ex_str_grease, [175] = ex_str_hold, [176] = ex_str_movementpenalties, [241] = ex_str_vampiriceffects, [247] = ex_str_beltyn, [255] = ex_str_salamanderauras, [256] = ex_str_umberhulkgaze, [279] = ex_str_animalrage, [281] = ex_str_vitriolicsphere, [294] = ex_str_harpywail, [295] = ex_str_jackalweregaze, [400] = ex_str_hopelessness, [404] = ex_str_nausea, [405] = ex_str_enfeeblement, [412] = ex_str_domination, [414] = ex_str_otiluke, [416] = ex_str_wounding, [419] = ex_str_knockdown, [420] = ex_str_instantdeath, [424] = ex_str_holdundead, [425] = ex_str_controlundead, [428] = ex_str_banishment, [429] = ex_str_energydrain}

classstatnames = {ex_str_barbarian, ex_str_bard, ex_str_cleric, ex_str_druid, ex_str_fighter, ex_str_monk, ex_str_paladin, ex_str_ranger, ex_str_rogue, ex_str_sorcerer, ex_str_wizard}
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
	local levelstring = ex_str_level .. levelsum
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

	IEex_DisplayString(ex_str_hitpoints .. IEex_ReadSignedWord(creatureData + 0x5C0, 0x0) .. "/" .. IEex_GetActorStat(targetID, 1))
	local armorClassList = IEex_GetActorArmorClass(targetID)
	local ac = armorClassList[1]
	local acslashing = armorClassList[2]
	local acpiercing = armorClassList[3]
	local acbludgeoning = armorClassList[4]
	local acmissile = armorClassList[5]
	if acslashing == acpiercing and acslashing == acbludgeoning and acslashing == acmissile then
		IEex_DisplayString(ex_str_armorclass .. (ac + acslashing))
	else
		IEex_DisplayString(ex_str_acslashing .. ac + acslashing .. "  " .. ex_str_acpiercing .. ac + acpiercing .. "  " .. ex_str_acbludgeoning .. ac + acbludgeoning .. "  " .. ex_str_acmissile .. ac + acmissile)
	end
--[[
	if IEex_GetActorStat(targetID, 7) >= 0 then
		IEex_DisplayString(ex_str_attackbonus .. "+" .. IEex_GetActorStat(targetID, 7))
	else
		IEex_DisplayString(ex_str_attackbonus .. IEex_GetActorStat(targetID, 7))
	end
--]]
	IEex_DisplayString(ex_str_attacksperround .. IEex_GetActorStat(targetID, 8))
	IEex_DisplayString(ex_str_abilityscores)
	IEex_DisplayString(ex_str_strength .. IEex_GetActorStat(targetID, 36) .. "  " .. ex_str_dexterity .. IEex_GetActorStat(targetID, 40) .. "  " .. ex_str_constitution .. IEex_GetActorStat(targetID, 41) .. "  " .. ex_str_intelligence .. IEex_GetActorStat(targetID, 38) .. "  " .. ex_str_wisdom .. IEex_GetActorStat(targetID, 39) .. "  " .. ex_str_charisma .. IEex_GetActorStat(targetID, 42))
	IEex_DisplayString(MEGetStat(targetID, ex_str_slashingresistance, 21, "/-\n") .. MEGetStat(targetID, ex_str_piercingresistance, 23, "/-\n") .. MEGetStat(targetID, ex_str_bludgeoningresistance, 22, "/-\n") .. MEGetStat(targetID, ex_str_missileresistance, 24, "/-\n") .. MEGetStat(targetID, ex_str_fireresistance, 14, "/-\n") .. MEGetStat(targetID, ex_str_coldresistance, 15, "/-\n") .. MEGetStat(targetID, ex_str_electricityresistance, 16, "/-\n") .. MEGetStat(targetID, ex_str_acidresistance, 17, "/-\n") .. MEGetStat(targetID, ex_str_poisonresistance, 74, "/-\n") .. MEGetStat(targetID, ex_str_magicdamageresistance, 73, "/-\n") .. MEGetStat(targetID, ex_str_spellresistance, 18, "/-\n"))
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
		IEex_DisplayString(ex_str_damagereduction .. "20/+1")
	elseif damageReduction < 5 and IEex_GetActorSpellState(targetID, 18) then
		IEex_DisplayString(ex_str_damagereduction .. "10/+5")
	elseif damageReduction > 0 then
		IEex_DisplayString(ex_str_damagereduction .. 5 * damageReduction .. "/+" .. damageReduction)
	end
	IEex_DisplayString(ex_str_savingthrows)
	IEex_DisplayString(ex_str_fortitude .. IEex_GetActorStat(targetID, 9) .. "  " .. ex_str_reflex .. IEex_GetActorStat(targetID, 10) .. "  " .. ex_str_will .. IEex_GetActorStat(targetID, 11))
	if #immunities > 0 then
		local immunitiesString = ex_str_immunities
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
		IEex_DisplayString(ex_str_concentrationskill .. IEex_ReadByte(creatureData + 0x7B7, 0x0) + math.floor((IEex_GetActorStat(targetID, 41) - 10) / 2))
	end
	if mirrorImagesRemaining > 0 then
		IEex_DisplayString(ex_str_mirrorimages .. mirrorImagesRemaining)
	end
	if stoneskinDamageRemaining > 0 then
		IEex_DisplayString(ex_str_stoneskins .. stoneskinDamageRemaining)
	end
	IEex_DisplayString(MEGetStat(targetID, ex_str_ironskins, 88, "\n") .. MEGetStat(targetID, ex_str_castingtime, 77, "\n"))
	if IEex_GetActorStat(targetID, 104) > 0 then
		IEex_DisplayString(ex_str_sneakattackdamage .. math.floor((IEex_GetActorStat(targetID, 104) + 1) / 2) + sneakAttackModifier)
	end
	if IEex_GetActorStat(targetID, 79) > 0 then
		IEex_DisplayString(string.gsub(string.gsub(ex_str_55048, "<EXICNAME>", IEex_GetActorName(targetID)), "<EXICVAL1>", IEex_GetActorStat(targetID, 79)))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " casts arcane spells as if " .. IEex_GetActorStat(targetID, 79) .. " levels higher")
	end
	if IEex_GetActorStat(targetID, 53) ~= 100 then
		IEex_DisplayString(string.gsub(string.gsub(ex_str_55049, "<EXICNAME>", IEex_GetActorName(targetID)), "<EXICVAL1>", IEex_GetActorStat(targetID, 53)))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " casts arcane spells with " .. IEex_GetActorStat(targetID, 53) .. "% the normal duration")
	end
	if IEex_GetActorStat(targetID, 80) > 0 then
		IEex_DisplayString(string.gsub(string.gsub(ex_str_55050, "<EXICNAME>", IEex_GetActorName(targetID)), "<EXICVAL1>", IEex_GetActorStat(targetID, 80)))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " casts divine spells as if " .. IEex_GetActorStat(targetID, 80) .. " levels higher")
	end
	if IEex_GetActorStat(targetID, 54) ~= 100 then
		IEex_DisplayString(string.gsub(string.gsub(ex_str_55051, "<EXICNAME>", IEex_GetActorName(targetID)), "<EXICVAL1>", IEex_GetActorStat(targetID, 54)))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " casts divine spells with " .. IEex_GetActorStat(targetID, 54) .. "% the normal duration")
	end
	if extendSpellLevel > 0 then
		IEex_DisplayString(string.gsub(string.gsub(ex_str_55052, "<EXICNAME>", IEex_GetActorName(targetID)), "<EXICVAL1>", extendSpellLevel))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " can extend up to " .. IEex_GetNth(extendSpellLevel) .. "-level spells")
	end
	if maximizeSpellLevel > 0 then
		IEex_DisplayString(string.gsub(string.gsub(ex_str_55053, "<EXICNAME>", IEex_GetActorName(targetID)), "<EXICVAL1>", maximizeSpellLevel))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " can maximize up to " .. IEex_GetNth(maximizeSpellLevel) .. "-level spells")
	end
	if quickenSpellLevel > 0 then
		IEex_DisplayString(string.gsub(string.gsub(ex_str_55054, "<EXICNAME>", IEex_GetActorName(targetID)), "<EXICVAL1>", quickenSpellLevel))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " can quicken up to " .. IEex_GetNth(quickenSpellLevel) .. "-level spells")
	end
	if safeSpellLevel > 0 then
		IEex_DisplayString(string.gsub(string.gsub(ex_str_55055, "<EXICNAME>", IEex_GetActorName(targetID)), "<EXICVAL1>", safeSpellLevel))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " can safen up to " .. IEex_GetNth(safeSpellLevel) .. "-level spells")
	end
	if IEex_GetActorStat(targetID, 76) ~= 0 then
		IEex_DisplayString(string.gsub(ex_str_55056, "<EXICNAME>", IEex_GetActorName(targetID)))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " can cast more than one spell per round")
	end
	if IEex_GetActorStat(targetID, 81) ~= 0 then
		IEex_DisplayString(string.gsub(ex_str_55057, "<EXICNAME>", IEex_GetActorName(targetID)))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " can see invisible creatures")
	end
	if bit32.band(IEex_ReadByte(creatureData + 0x89F, 0), 0x2) ~= 0 then
		IEex_DisplayString(string.gsub(ex_str_55058, "<EXICNAME>", IEex_GetActorName(targetID)))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " is protected from critical hits")
	end
	if IEex_GetActorSpellState(targetID, 216) then
		IEex_DisplayString(string.gsub(ex_str_55059, "<EXICNAME>", IEex_GetActorName(targetID)))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " is protected from sneak attacks")
	end
	if IEex_GetActorSpellState(targetID, 64) then
		IEex_DisplayString(string.gsub(ex_str_55060, "<EXICNAME>", IEex_GetActorName(targetID)))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " deals maximum damage with each hit")
	end
	if IEex_GetActorSpellState(targetID, 218) then
		IEex_DisplayString(string.gsub(ex_str_55061, "<EXICNAME>", IEex_GetActorName(targetID)))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " can sneak attack on each hit")
	end
	if IEex_GetActorStat(targetID, 83) ~= 0 then
		IEex_DisplayString(string.gsub(string.gsub(ex_str_55051, "<EXICNAME>", IEex_GetActorName(targetID)), "<EXICVAL1>", IEex_GetActorStat(targetID, 83)))
--		IEex_DisplayString(IEex_GetActorName(targetID) .. " cannot be reduced below " .. IEex_GetActorStat(targetID, 83) .. " HP")
	end
end

function MEGetStat(targetID, pre, stat, post)
	if IEex_GetActorStat(targetID, stat) == 0 then
		return ""
	else
		return pre .. IEex_GetActorStat(targetID, stat) .. post
	end
end

----------------------------------------------------------------
-- Functions which can be used by Opcode 502 (Screen Effects) --
----------------------------------------------------------------

function MEPOLYBL(originatingEffectData, effectData, creatureData)

	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	if opcode == 111 and bit32.band(savingthrow, 0x10000) == 0 then
		return true
--[[
	elseif opcode == 58 then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 9,
["resource"] = "SPIN122",
["source_id"] = targetID
})
--]]
	end
--[[
	local timing = IEex_ReadDword(effectData + 0x20)
	if timing == 2 then
		for i = 43, 50, 1 do
			if IEex_ReadDword(creatureData + 0x4AD8 + i * 0x4) > 0 and IEex_ReadLString(IEex_ReadDword(creatureData + 0x4AD8 + i * 0x4) + 0xC, 8) == parent_resource then
				return true
			end
		end
	end
--]]
	return false
end

function MESUMMOD(originatingEffectData, effectData, creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local power = IEex_ReadDword(effectData + 0x10)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local special = IEex_ReadDword(effectData + 0x44)
	local school = IEex_ReadDword(effectData + 0x48)
	local resource = IEex_ReadLString(effectData + 0x2C, 8)
	local vvcresource = IEex_ReadLString(effectData + 0x6C, 8)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	local sourceSpell = ex_damage_source_spell[parent_resource]
	if sourceSpell == nil then
		sourceSpell = parent_resource
	end
	local classSpellLevel = 0
	if IEex_IsSprite(sourceID, true) then
		classSpellLevel = IEex_GetClassSpellLevel(sourceID, casterClass, sourceSpell)
	end
	if opcode ~= 67 and opcode ~= 410 and opcode ~= 411 and (opcode ~= 288 or parameter2 ~= 207) then return false end
	local internal_flags = IEex_ReadDword(effectData + 0xC8)
	if bit32.band(internal_flags, 0x4000000) == 0 then
		local targetID = IEex_GetActorIDShare(creatureData)
		if targetID ~= sourceID or not IEex_IsSprite(targetID) or not IEex_IsSprite(sourceID) then return false end
		local o_spellRES = IEex_ReadLString(originatingEffectData + 0x18, 8)
		local o_spellRES2 = IEex_ReadLString(originatingEffectData + 0x6C, 8)
		local o_spellRES3 = IEex_ReadLString(originatingEffectData + 0x74, 8)
		local o_savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
		if bit32.band(o_savingthrow, 0x100000) > 0 and parent_resource ~= o_spellRES and parent_resource ~= o_spellRES2 and parent_resource ~= o_spellRES3 then return false end
		if bit32.band(o_savingthrow, 0x200000) > 0 and classSpellLevel > IEex_ReadDword(originatingEffectData + 0x18) then return false end
		if bit32.band(o_savingthrow, 0x400000) > 0 and school ~= IEex_ReadDword(originatingEffectData + 0x1C) then return false end
		local o_special = IEex_ReadDword(originatingEffectData + 0x44)
		if bit32.band(o_savingthrow, 0x10000) > 0 then
			parameter1 = parameter1 * o_special
		else
			parameter1 = parameter1 + o_special
		end
		if parameter1 <= 0 then return true end
		IEex_WriteDword(effectData + 0x18, parameter1)
	end
	return false
end

function MEOPCSPL(originatingEffectData, effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local match_opcode = IEex_ReadDword(originatingEffectData + 0x44)
	local match_parent_resource = IEex_ReadLString(originatingEffectData + 0x18, 8)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	
	if opcode == match_opcode and parent_resource == match_parent_resource then
		return true
	end
	return false
end

previous_attacks_deflected = {}
function MEDEFLEC(originatingEffectData, effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local string = IEex_ReadDword(originatingEffectData + 0x18)
	local types_blocked = IEex_ReadDword(originatingEffectData + 0x1C)
	local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
	local delay = IEex_ReadDword(originatingEffectData + 0x44)
	local parent_resource = IEex_ReadLString(originatingEffectData + 0x90, 8)
	local damage_type = IEex_ReadWord(effectData + 0x1E, 0x0)
	local flags = IEex_ReadDword(effectData + 0x44)
	local restype = IEex_ReadDword(effectData + 0x8C)
	local internal_flags = IEex_ReadDword(effectData + 0xC8)
	if bit32.band(internal_flags, 0x4000000) > 0 then return false end
	local opcode = IEex_ReadDword(effectData + 0xC)
	local effectRES = IEex_ReadLString(effectData + 0x90, 8)
	local isOnHitEffect = false
	local doDeflect = true
	if bit32.band(savingthrow, 0x10000) == 0 and IEex_GetActorSpellState(targetID, 246) then
		IEex_IterateActorEffects(targetID, function(eData)
			local the_opcode = IEex_ReadDword(eData + 0x10)
			local the_parameter1 = IEex_ReadDword(eData + 0x1C)
			local the_parameter2 = IEex_ReadDword(eData + 0x20)
			local the_special = IEex_ReadDword(eData + 0x48)
			local the_resource = IEex_ReadLString(eData + 0x30, 8)
			if the_opcode == 288 and the_parameter1 > 0 and the_parameter2 == 246 and the_resource == parent_resource then
				doDeflect = false
			end
		end)
	end
	if previous_attacks_deflected["" .. targetID] == nil then
		previous_attacks_deflected["" .. targetID] = {}
	end
	if opcode == 12 and effectRES == "" and (damage_type == 0 and bit32.band(types_blocked, 0x4000) > 0) or (damage_type ~= 0 and bit32.band(types_blocked, damage_type) > 0) and ((bit32.band(savingthrow, 0x10000) > 0 and delay ~= 0) or (bit32.band(savingthrow, 0x10000) == 0 and doDeflect)) then
--		effectRES = IEex_ReadLString(effectData + 0x6C, 8)
		effectRES = "IEex_DAM"
		previous_attacks_deflected["" .. targetID][effectRES] = IEex_GetGameTick()
	elseif bit32.band(savingthrow, 0x80000) > 0 and previous_attacks_deflected["" .. targetID]["IEex_DAM"] == IEex_GetGameTick() and restype == 2 then
		isOnHitEffect = true
	end
	if opcode ~= 12 and isOnHitEffect == false then return false end
	
	if bit32.band(savingthrow, 0x200000) > 0 then
		if IEex_GetActorStat(targetID, 101) == 0 and IEex_GetActorStat(targetID, 40) < 19 then return false end
		local hasArmor = false
		local handsUsed = 0
		local spriteHands = 2
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if extra_hands[animation] ~= nil then
			spriteHands = extra_hands[animation]
		end
		if IEex_GetActorSpellState(targetID, 241) then
			IEex_IterateActorEffects(targetID, function(eData)
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
					elseif thespecial == 1 or thespecial == 3 then
						hasArmor = true
					end
				end
			end)
		end
--		if hasArmor or ((spriteHands - handsUsed) < 2) then return false end
		if ((spriteHands - handsUsed) < 1) then return false end
	end
	

	if isOnHitEffect or (damage_type == 0 and bit32.band(types_blocked, 0x4000) > 0) or (damage_type ~= 0 and bit32.band(types_blocked, damage_type) > 0) then
		if doDeflect or isOnHitEffect then
			if bit32.band(savingthrow, 0x10000) > 0 and delay ~= -1 and isOnHitEffect == false then
				if delay > 0 then
					delay = delay - 1
					IEex_WriteDword(originatingEffectData + 0x44, delay)
				else
					return false
				end
			end
			if bit32.band(savingthrow, 0x10000) == 0 and delay ~= -1 and isOnHitEffect == false then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = delay,
["parameter1"] = 1,
["parameter2"] = 246,
["resource"] = parent_resource,
["parent_resource"] = "MEDEFDEL",
["internal_flags"] = 0x4000000,
["source_target"] = targetID,
["source_id"] = targetID,
})
			end
			if string ~= -1 and isOnHitEffect == false then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = string,
["resource"] = parent_resource,
["parent_resource"] = "MEDEFSTR",
["internal_flags"] = 0x4000000,
["source_target"] = targetID,
["source_id"] = targetID,
})
			end
			if bit32.band(savingthrow, 0x100000) > 0 and IEex_IsSprite(sourceID, false) and targetID ~= sourceID then
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = IEex_ReadDword(effectData + 0xC),
["target"] = IEex_ReadDword(effectData + 0x10),
["power"] = IEex_ReadDword(effectData + 0x14),
["parameter1"] = IEex_ReadDword(effectData + 0x18),
["parameter2"] = IEex_ReadDword(effectData + 0x1C),
["timing"] = IEex_ReadDword(effectData + 0x20),
["duration"] = IEex_ReadDword(effectData + 0x24),
["resource"] = IEex_ReadLString(effectData + 0x2C, 8),
["dicenumber"] = IEex_ReadDword(effectData + 0x34),
["dicesize"] = IEex_ReadDword(effectData + 0x38),
["savingthrow"] = IEex_ReadDword(effectData + 0x3C),
["savebonus"] = IEex_ReadDword(effectData + 0x40),
["special"] = IEex_ReadDword(effectData + 0x44),
["school"] = IEex_ReadDword(effectData + 0x48),
["resist_dispel"] = IEex_ReadDword(effectData + 0x58),
["parameter3"] = IEex_ReadDword(effectData + 0x5C),
["parameter4"] = IEex_ReadDword(effectData + 0x60),
["parameter5"] = IEex_ReadDword(effectData + 0x64),
["vvcresource"] = IEex_ReadLString(effectData + 0x6C, 8),
["resource2"] = IEex_ReadLString(effectData + 0x74, 8),
["source_x"] = IEex_ReadDword(creatureData + 0x8),
["source_y"] = IEex_ReadDword(creatureData + 0xC),
["target_x"] = IEex_ReadDword(IEex_GetActorShare(sourceID) + 0x8),
["target_y"] = IEex_ReadDword(IEex_GetActorShare(sourceID) + 0xC),
["restype"] = IEex_ReadDword(effectData + 0x8C),
["parent_resource"] = IEex_ReadLString(effectData + 0x90, 8),
["resource_flags"] = IEex_ReadDword(effectData + 0x98),
["impact_projectile"] = IEex_ReadDword(effectData + 0x9C),
["sourceslot"] = IEex_ReadDword(effectData + 0xA0),
["effvar"] = IEex_ReadLString(effectData + 0xA4, 32),
["casterlvl"] = IEex_ReadDword(effectData + 0xC4),
["internal_flags"] = bit32.bor(internal_flags, 0x4000000),
["sectype"] = IEex_ReadDword(effectData + 0xCC),
["source_target"] = sourceID,
["source_id"] = targetID
})
			end
			if bit32.band(savingthrow, 0x10000) > 0 and bit32.band(savingthrow, 0x20000) > 0 and delay == 0 and isOnHitEffect == false then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["duration"] = IEex_GetGameTick() + 1,
["resource"] = parent_resource,
["internal_flags"] = 0x4000000,
["source_target"] = targetID,
["source_id"] = targetID
})
			end
			return true
		end
	end
	return false
end

function MEREBOUN(originatingEffectData, effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local percentage = IEex_ReadDword(originatingEffectData + 0x18)
	local types_blocked = IEex_ReadDword(originatingEffectData + 0x1C)
	local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
	local delay = IEex_ReadDword(originatingEffectData + 0x44)
	local parent_resource = IEex_ReadLString(originatingEffectData + 0x90, 8)
	local damage = IEex_ReadDword(effectData + 0x18)
	local damage_type = IEex_ReadWord(effectData + 0x1E, 0x0)
	local flags = IEex_ReadDword(effectData + 0x44)
	local restype = IEex_ReadDword(effectData + 0x8C)
	local internal_flags = IEex_ReadDword(effectData + 0xC8)
	if bit32.band(internal_flags, 0x4000000) > 0 then return false end
	local opcode = IEex_ReadDword(effectData + 0xC)
	local effectRES = IEex_ReadLString(effectData + 0x90, 8)
	local doDeflect = true
	if opcode ~= 12 then return false end
	if bit32.band(savingthrow, 0x10000) == 0 and IEex_GetActorSpellState(targetID, 246) then
		IEex_IterateActorEffects(targetID, function(eData)
			local the_opcode = IEex_ReadDword(eData + 0x10)
			local the_parameter1 = IEex_ReadDword(eData + 0x1C)
			local the_parameter2 = IEex_ReadDword(eData + 0x20)
			local the_special = IEex_ReadDword(eData + 0x48)
			local the_resource = IEex_ReadLString(eData + 0x30, 8)
			if the_opcode == 288 and the_parameter1 > 0 and the_parameter2 == 246 and the_resource == parent_resource then
				doDeflect = false
			end
		end)
	end
	if (damage_type == 0 and bit32.band(types_blocked, 0x4000) > 0) or (damage_type ~= 0 and bit32.band(types_blocked, damage_type) > 0) then
		if doDeflect then
			if bit32.band(savingthrow, 0x10000) > 0 and delay ~= -1 then
				if delay > 0 then
					delay = delay - 1
					IEex_WriteDword(originatingEffectData + 0x44, delay)
				else
					return false
				end
			end
			
			if bit32.band(savingthrow, 0x10000) == 0 and delay ~= -1 then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = delay,
["parameter1"] = 1,
["parameter2"] = 246,
["resource"] = parent_resource,
["parent_resource"] = "MEREBDEL",
["internal_flags"] = 0x4000000,
["source_target"] = targetID,
["source_id"] = targetID,
})
			end
			damage = math.floor(damage * percentage / 100)
			if bit32.band(savingthrow, 0x100000) > 0 and IEex_IsSprite(sourceID, false) and targetID ~= sourceID then
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = IEex_ReadDword(effectData + 0xC),
["target"] = IEex_ReadDword(effectData + 0x10),
["power"] = IEex_ReadDword(effectData + 0x14),
["parameter1"] = damage,
["parameter2"] = IEex_ReadDword(effectData + 0x1C),
["timing"] = IEex_ReadDword(effectData + 0x20),
["duration"] = IEex_ReadDword(effectData + 0x24),
["resource"] = IEex_ReadLString(effectData + 0x2C, 8),
["dicenumber"] = IEex_ReadDword(effectData + 0x34),
["dicesize"] = IEex_ReadDword(effectData + 0x38),
["savingthrow"] = IEex_ReadDword(effectData + 0x3C),
["savebonus"] = IEex_ReadDword(effectData + 0x40),
["special"] = IEex_ReadDword(effectData + 0x44),
["school"] = IEex_ReadDword(effectData + 0x48),
["resist_dispel"] = IEex_ReadDword(effectData + 0x58),
["parameter3"] = IEex_ReadDword(effectData + 0x5C),
["parameter4"] = IEex_ReadDword(effectData + 0x60),
["parameter5"] = IEex_ReadDword(effectData + 0x64),
["vvcresource"] = IEex_ReadLString(effectData + 0x6C, 8),
["resource2"] = IEex_ReadLString(effectData + 0x74, 8),
["source_x"] = IEex_ReadDword(creatureData + 0x8),
["source_y"] = IEex_ReadDword(creatureData + 0xC),
["target_x"] = IEex_ReadDword(IEex_GetActorShare(sourceID) + 0x8),
["target_y"] = IEex_ReadDword(IEex_GetActorShare(sourceID) + 0xC),
["restype"] = IEex_ReadDword(effectData + 0x8C),
["parent_resource"] = IEex_ReadLString(effectData + 0x90, 8),
["resource_flags"] = IEex_ReadDword(effectData + 0x98),
["impact_projectile"] = IEex_ReadDword(effectData + 0x9C),
["sourceslot"] = IEex_ReadDword(effectData + 0xA0),
["effvar"] = IEex_ReadLString(effectData + 0xA4, 32),
["casterlvl"] = IEex_ReadDword(effectData + 0xC4),
["internal_flags"] = bit32.bor(internal_flags, 0x4000000),
["sectype"] = IEex_ReadDword(effectData + 0xCC),
["source_target"] = sourceID,
["source_id"] = targetID
})
			end
			if bit32.band(savingthrow, 0x10000) > 0 and bit32.band(savingthrow, 0x20000) > 0 and delay == 0 then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["duration"] = IEex_GetGameTick() + 1,
["resource"] = parent_resource,
["internal_flags"] = 0x4000000,
["source_target"] = targetID,
["source_id"] = targetID
})
			end
		end
	end
	return false
end

function MESANCTU(originatingEffectData, effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, true) then return false end
	if IEex_GetActorSpellState(targetID, 189) and not IEex_GetActorSpellState(sourceID, 189) and IEex_ReadDword(effectData + 0x14) ~= 10 then return true end
	return false
end

function MEKAERVA(originatingEffectData, effectData, creatureData)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local internal_flags = IEex_ReadDword(effectData + 0xC8)
	if opcode == 12 and bit32.band(internal_flags, 0x4000000) > 0 then
		local damage = IEex_ReadDword(effectData + 0x18)
		IEex_WriteDword(effectData + 0x18, damage * 3)
	end
	return false
end

IEex_AddScreenEffectsGlobal("MEQUABIL", function(effectData, creatureData)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local timing = IEex_ReadDword(effectData + 0x20)
	if opcode == 171 and (timing <= 1 or timing >= 9) then
		local resource = IEex_ReadLString(effectData + 0x2C, 8)
		for i = 0, 8, 1 do
			local offset = creatureData + 0x38DC + 0x3C * i
			if IEex_ReadLString(offset + 0x20, 8) == resource then
				local count = IEex_ReadSignedWord(offset + 0x18, 0x0)
				if count >= 0 then
					IEex_WriteWord(offset + 0x18, count + 1)
					IEex_WriteByte(offset + 0x3A, 0)
				end
			end
		end
	end
end)
me_portrait_0_xp = 0
IEex_AddScreenEffectsGlobal("MEXPBALA", function(effectData, creatureData)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	if opcode == 104 and parameter2 == 0 then
		local targetID = IEex_GetActorIDShare(creatureData)
		local parameter1 = IEex_ReadDword(effectData + 0x18)
		if targetID == IEex_GetActorIDPortrait(0) then
			me_portrait_0_xp = parameter1
		elseif parameter1 == me_portrait_0_xp - 1 then
			parameter1 = me_portrait_0_xp
			IEex_WriteDword(effectData + 0x18, parameter1)
		end
	end
end)