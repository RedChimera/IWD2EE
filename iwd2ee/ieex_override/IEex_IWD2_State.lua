
function IEex_Reload()

	IEex_AssertThread(IEex_Thread.Async, true)

	dofile("override/IEex_IWD2_State.lua")
	
	IEex_Helper_SetBridge("IEex_NeedSyncTick", "val", 1)
	while IEex_Helper_GetBridge("IEex_NeedSyncTick", "val") == 1 do
		-- Spin until sync state is reloaded
		-- Need sleep call so this thread doesn't (effectively) keep IEex_NeedSyncTick locked
		IEex_Helper_Sleep(1)
	end
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

function IEex_Extern_SyncTick()
	dofile("override/IEex_IWD2_State.lua")
	IEex_Helper_SetBridge("IEex_NeedSyncTick", "val", 0)
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

dofile("override/IEex_TRA.lua")
dofile("override/IEex_WEIDU.lua")
dofile("override/IEex_INI.lua")

dofile("override/IEex_Bridge.lua")
dofile("override/IEex_Core_State.lua")

dofile("override/IEex_Action_State.lua")
dofile("override/IEex_Creature_State.lua")
dofile("override/IEex_Opcode_State.lua")
dofile("override/IEex_Gui_State.lua")
dofile("override/IEex_Key_State.lua")
dofile("override/IEex_Resource_State.lua")
dofile("override/IEex_Projectile_State.lua")
dofile("override/IEex_Debug_State.lua")



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
			currentOffset = currentOffset + size(unpack(getConstructor(structEntry).luaArgs or {}))
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
			constructor(address, unpack(entryConstructor.luaArgs or {}))
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
--	local memorizedCount = IEex_ReadDword(address + 0x14)
	local sorcererCastableCount = IEex_ReadDword(address + 0x18)
	if isSorcererType and resref == "" then
--[[
		memorizedCount = memorizedCount + memorizeMod
		if memorizedCount < 0 then
			memorizedCount = 0
		end
--]]
		sorcererCastableCount = sorcererCastableCount + castableMod
		if sorcererCastableCount < 0 then
			sorcererCastableCount = 0
		end
--		IEex_WriteDword(address + 0x14, memorizedCount)
		IEex_WriteDword(address + 0x18, sorcererCastableCount)
	end
	local id = list[resref]
	if not id and not isSorcererType then
		local message = "[IEex_AlterSpellInfo] Critical Caller Error: resref \""..resref.."\" not present in corresponding master spell-list 2DA"
		print(message)
		--IEex_MessageBox(message)
		return
	end
	if not isSorcererType or resref ~= "" then
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
	elseif isSorcererType and resref == "" then
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

function IEex_IsActorSolelySelected(actorID)
	local pGame = IEex_GetGameData()
	return IEex_ReadDword(pGame + 0x3896) == 1 and IEex_ReadDword(IEex_ReadDword(pGame + 0x388E) + 0x8) == actorID
end

function IEex_CanSpriteUseItem(sprite, resref)
	local CItem = IEex_DemandCItem(resref)
	local junkPtr = IEex_Malloc(0x4)
	local result = IEex_Call(0x5B9D20, {0x0, junkPtr, CItem, sprite}, IEex_GetGameData(), 0x0)
	IEex_Free(junkPtr)
	IEex_DumpCItem(CItem)
	return result == 1
end

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

ex_class_base_attack_table = {"BAATFGT", "BAATNFG", "BAATNFG", "BAATNFG", "BAATFGT", "BAATMKU", "BAATFGT", "BAATFGT", "BAATNFG", "BAATMAG", "BAATMAG"}
function IEex_GetActorBaseAttackBonus(actorID, fixMonkAttackBonus)
	if not IEex_IsSprite(actorID, true) then return 0 end
	local creatureData = IEex_GetActorShare(actorID)
	local baseAttackBonus = IEex_ReadSignedByte(creatureData + 0x5EC, 0x0)
	local monkAttackBonusDisabled = false
	local hasOtherClasses = false
	local monkLevel = IEex_GetActorStat(actorID, 101)
	if monkLevel > 0 then
		if IEex_GetActorStat(actorID, 96) > 0 or IEex_GetActorStat(actorID, 97) > 0 or IEex_GetActorStat(actorID, 98) > 0 or IEex_GetActorStat(actorID, 99) > 0 or IEex_GetActorStat(actorID, 100) > 0 or IEex_GetActorStat(actorID, 102) > 0 or IEex_GetActorStat(actorID, 103) > 0 or IEex_GetActorStat(actorID, 104) > 0 or IEex_GetActorStat(actorID, 105) > 1 or IEex_GetActorStat(actorID, 106) > 1 then
			monkAttackBonusDisabled = true
			hasOtherClasses = true
		end
		if IEex_ReadByte(creatureData + 0x4BA4, 0x0) ~= 10 then
			monkAttackBonusDisabled = true
		end
		IEex_IterateActorEffects(actorID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
			if theopcode == 288 and theparameter2 == 241 then
				if thespecial ~= 6 then
					monkAttackBonusDisabled = true
					if (thespecial == 1 and (theparameter1 ~= 67 or not ex_elven_chainmail_counts_as_unarmored)) or thespecial == 3 or (thespecial >= 4 and ex_special_monk_weapon_types[theparameter1] == nil) then
						fixMonkAttackBonus = false
					end
				end
			end
		end)
	end
	if monkAttackBonusDisabled and not fixMonkAttackBonus and not hasOtherClasses then
		baseAttackBonus = baseAttackBonus + tonumber(IEex_2DAGetAtStrings("BAATNFG", "BASE_ATTACK", tostring(monkLevel))) - tonumber(IEex_2DAGetAtStrings("BAATMKU", "BASE_ATTACK", tostring(monkLevel)))
	elseif fixMonkAttackBonus and hasOtherClasses then
		baseAttackBonus = baseAttackBonus + tonumber(IEex_2DAGetAtStrings("BAATMKU", "BASE_ATTACK", tostring(monkLevel))) - tonumber(IEex_2DAGetAtStrings("BAATNFG", "BASE_ATTACK", tostring(monkLevel)))
	end
	if bit.band(IEex_ReadByte(creatureData + 0x89F, 0x0), 0x1) > 0 then
		if IEex_ReadByte(creatureData + 0x24, 0x0) <= 30 then
			baseAttackBonus = 0
		end
		for i = 1, 11, 1 do
			local classLevel = IEex_ReadByte(creatureData + 0x626 + i, 0x0)
			if classLevel > 0 then
				baseAttackBonus = baseAttackBonus + tonumber(IEex_2DAGetAtStrings(ex_class_base_attack_table[i], "BASE_ATTACK", tostring(classLevel)))
			end
		end
	end
	return baseAttackBonus
end

function IEex_GetActorArmorClass(actorID)
	if not IEex_IsSprite(actorID, true) then return {0, 0, 0, 0, 0} end
	local creatureData = IEex_GetActorShare(actorID)
	local armorClass = IEex_ReadSignedWord(creatureData + 0x5E2, 0x0)
	if bit.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0 then
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
		local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
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
	local stateValue = bit.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
	if bit.band(stateValue, 0x8000) > 0 then
		armorClass = armorClass + 4
	end
	if bit.band(stateValue, 0x10000) > 0 then
		armorClass = armorClass - 2
	end
	if bit.band(stateValue, 0x40000) > 0 then
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

-- Return the specified stat of the actor (from STATS.IDS).
function IEex_GetActorStat(actorID, statID)
	if not IEex_IsSprite(actorID, true) then return 0 end
	local share = IEex_GetActorShare(actorID)
	local bAllowEffectListCall = IEex_ReadDword(share + 0x72A4) == 1
	local activeStats = share + (bAllowEffectListCall and 0x920 or 0x1778)
	if statID == 2 then
		return IEex_GetActorArmorClass(actorID)[1]
	elseif statID > 106 and ex_stat_offset[statID] ~= nil then
		local specialReadSize = ex_stat_offset[statID][2]
		local statValue = 0
		if specialReadSize == 1 then
			statValue = IEex_ReadSignedByte(share + ex_stat_offset[statID][1], 0x0)
		elseif specialReadSize == 2 then
			statValue = IEex_ReadSignedWord(share + ex_stat_offset[statID][1], 0x0)
		elseif specialReadSize == 4 then
			statValue = IEex_ReadDword(share + ex_stat_offset[statID][1])
		end
		return statValue
	else
		return IEex_Call(0x446DD0, {statID}, activeStats, 0x0)
	end
	
end

-- Returns true if the actor has any of the specified states (from STATE.IDS).
-- For example, IEex_GetActorState(targetID, 0x28) returns true if targetID is helpless or stunned.
function IEex_GetActorState(actorID, state)
	if not IEex_IsSprite(actorID, true) then return false end
	local share = IEex_GetActorShare(actorID)
	local stateValue = bit.bor(IEex_ReadDword(share + 0x5BC), IEex_ReadDword(share + 0x920))
	return ((state == 0 and stateValue == 0) or bit.band(stateValue, state) ~= 0)
end

-- Returns true if the actor has the specified spell state (from SPLSTATE.IDS).
function IEex_GetActorSpellState(actorID, spellStateID)
	if not IEex_IsSprite(actorID, true) then return false end
--[[
	IEex_IterateActorEffects(actorID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		if theopcode == 288 and theparameter2 == spellStateID then
			return true
		end
	end)
--]]
	local bitsetStruct = IEex_Malloc(0x8)
	local spellStateStart = IEex_Call(0x4531A0, {}, IEex_GetActorShare(actorID), 0x0) + 0xEC
	IEex_Call(0x45E380, {spellStateID, bitsetStruct}, spellStateStart, 0x0)
	local spellState = bit.extract(IEex_Call(0x45E390, {}, bitsetStruct, 0x0), 0, 0x8)
	IEex_Free(bitsetStruct)
	return spellState == 1
end

-- Returns the actor's location.
function IEex_GetActorLocation(actorID)
	local share = IEex_GetActorShare(actorID)
	if share <= 0 then return -1, -1 end
	return IEex_ReadDword(share + 0x6), IEex_ReadDword(share + 0xA)
end

-- Returns the location the actor is moving to.
function IEex_GetActorDestination(actorID)
	if not IEex_IsSprite(actorID, true) then return -1, -1 end
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadDword(share + 0x556E), IEex_ReadDword(share + 0x5572)
end

-- Returns the creature the actor is targeting with their current action.
function IEex_GetActorTarget(actorID)
	if not IEex_IsSprite(actorID, true) then return 0 end
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
	local targetID = IEex_GetActorTarget(actorID)
	if targetID > 0 then
		targetX, targetY = IEex_GetActorLocation(targetID)
	end
	return targetX, targetY
end

-- Returns the actor's current action (from ACTION.IDS).
function IEex_GetActorCurrentAction(actorID)
	if not IEex_IsSprite(actorID, true) then return 0 end
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadDword(share + 0x4BE)
end

-- Returns the resref of the spell the actor is currently casting.
IEex_SpellIDSPrefix = {[1] = "SPPR", [2] = "SPWI", [3] = "SPIN"}
function IEex_GetActorSpellRES(actorID)
	if not IEex_IsSprite(actorID, false) then return "" end
	local share = IEex_GetActorShare(actorID)
	local actionID = IEex_ReadWord(share + 0x476, 0x0)
	local spellRES = ""
	if actionID == 31 or actionID == 95 or actionID == 113 or actionID == 114 or actionID == 191 or actionID == 192 then
		spellRES = IEex_ReadString(IEex_ReadDword(share + 0x538))
		if spellRES == "" then
			local spellIDS = IEex_ReadWord(share + 0x52C, 0x0)
			if IEex_SpellIDSPrefix[math.floor(spellIDS / 1000)] ~= nil then
				spellRES = IEex_SpellIDSPrefix[math.floor(spellIDS / 1000)] .. (spellIDS % 1000)
			end
		end
	end
	return spellRES
end

-- Returns the resref of the item the actor has in the chosen inventory slot (from REALSLOT.IDS).
function IEex_GetItemSlotRES(actorID, slot)
	if not IEex_IsSprite(actorID, true) then return "" end
	local share = IEex_GetActorShare(actorID)
	local slotData = IEex_ReadDword(share + 0x4AD8 + slot * 0x4)
	if slotData <= 0 then return "" end
	return IEex_ReadLString(slotData + 0xC, 8)
end

-- Returns the slot number of the actor's currently equipped weapon (from REALSLOT.IDS).
-- If the actor has a launcher equipped, it returns the slot number of the ammo.
function IEex_GetEquippedWeaponSlot(actorID)
	if not IEex_IsSprite(actorID, true) then return 0 end
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadByte(share + 0x4BA4, 0x0)
end

-- Returns the resref of the actor's currently equipped weapon.
-- If the actor has a launcher equipped, it returns the resref of the ammo.
function IEex_GetEquippedWeaponRES(actorID)
	if not IEex_IsSprite(actorID, true) then return "" end
	return IEex_GetItemSlotRES(actorID, IEex_GetEquippedWeaponSlot(actorID))
end

-- Returns the current header number of the actor's currently equipped weapon.
-- For example, if the actor is wielding a throwing axe, this will return 0 or 1 depending
-- on whether the axe is being used as ranged weapon or a melee weapon. In most other cases,
-- it will return 0. 
function IEex_GetEquippedWeaponHeader(actorID)
	if not IEex_IsSprite(actorID, true) then return 0 end
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadByte(share + 0x4BA6, 0x0)
end

-- Returns the resref of the actor's currently equipped launcher.
-- Returns "" if no launcher is equipped.
function IEex_GetLauncherRES(actorID, slot)
	if not IEex_IsSprite(actorID, true) then return "" end
	local launcherRES = ""
	IEex_IterateActorEffects(actorID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
		if theopcode == 288 and theparameter2 == 241 and thespecial == 7 then
			launcherRES = IEex_ReadLString(eData + 0x94, 8)
		end
	end)
	return launcherRES
end

-- Returns the actor's direction (from DIR.IDS).
function IEex_GetActorDirection(actorID)
	if not IEex_IsSprite(actorID, true) then return 0 end
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadByte(share + 0x537E, 0x0)
end

-- Returns the actor's direction (from DIR.IDS).
function IEex_GetActorDirection(actorID)
	if not IEex_IsSprite(actorID, true) then return 0 end
	local share = IEex_GetActorShare(actorID)
	return IEex_ReadByte(share + 0x537E, 0x0)
end

key_angles = {-90, -67.5, -45, -22.5, 0, 22.5, 45, 67.5, 90}
function IEex_GetActorRequiredDirection(actorID, targetX, targetY)
	if not IEex_IsSprite(actorID, true) then return 0 end
	local share = IEex_GetActorShare(actorID)
	local sourceX, sourceY = IEex_GetActorLocation(actorID)
	local deltaX = targetX - sourceX
	local deltaY = targetY - sourceY
	local angle = 90
	if deltaX ~= 0 then
		angle = math.deg(math.atan(deltaY / deltaX))
		for i = 1, 9, 1 do
			if (angle >= key_angles[i] and angle - 11.25 <= key_angles[i]) or (angle <= key_angles[i] and angle + 11.25 >= key_angles[i]) then
				if deltaX < 0 then 
					return (i - 1)
				elseif deltaX > 0 then
					return ((i + 7) % 16)
				end
			end
		end
	else
		if deltaY >= 0 then
			return 0
		else
			return 8
		end
	end
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
	local targetX, targetY = IEex_GetActorLocation(targetID)
	local requiredDirection = IEex_GetActorRequiredDirection(attackerID, targetX, targetY)
	return (IEex_WithinCyclicRange(attackerDirection, targetDirection, 3, 0, 15) and IEex_WithinCyclicRange(attackerDirection, requiredDirection, 3, 0, 15))
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
	if (bit.band(IEex_ReadDword(itemData + 0x1E), 0x400) > 0) or IEex_GetActorStat(actorID, 106) == 0 or IEex_ReadWord(itemdata + 0x1C, 0x0) ~= 11 or IEex_ReadWord(itemdata + 0x68, 0x0) < 2 then
		return false
	end
	local kitUnusability = ex_kit_unusability_locations[IEex_GetActorStat(actorID, 89)]
	if kitUnusability == nil then
		return true
	elseif bit.band(IEex_ReadByte(itemData + kitUnusability[1], 0x0), kitUnusability[2]) > 0 then
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
	return bit.band(IEex_ReadDword(share + 0x5BC), 0xFC0) ~= 0x0
end

function IEex_IsSprite(actorID, allowDead)
	local share = IEex_GetActorShare(actorID)
	return share ~= 0x0 -- share != NULL
	   and IEex_ReadByte(share + 0x4, 0) == 0x31 -- m_objectType == TYPE_SPRITE
	   and (allowDead or bit.band(IEex_ReadDword(share + 0x5BC), 0xFC0) == 0x0) -- allowDead or Status (not includes) STATE_*_DEATH
end

----------------
-- Game State --
----------------

function IEex_GetActionbarState()
	return IEex_ReadDword(IEex_GetGameData() + 0x1C78 + 0x1982)
end

function IEex_SetActionbarButton(actorID, customizableButtonIndex, buttonType)

	if not IEex_IsSprite(actorID, true) then return end
	local customizableActionbarSlotTypes = IEex_GetActorShare(actorID) + 0x3D14
	IEex_WriteDword(customizableActionbarSlotTypes + customizableButtonIndex * 0x4, buttonType)

	if IEex_GetActionbarState() == 0x72 and IEex_IsActorSolelySelected(actorID) then
		-- CInfGame_UpdateActionbar
		IEex_Call(0x5ADAE0, {}, IEex_GetGameData(), 0x0)
	end
end

function IEex_GetCVariable(CVariableHash, name)

	local manager = IEex_NewMemoryManager({
		{
			["name"] = "varChars",
			["struct"] = "string",
			["constructor"] = {
				["luaArgs"] = {name},
			},
		},
		{
			["name"] = "varString",
			["struct"] = "CString",
			["constructor"] = {
				["variant"] = "fromString",
				["args"] = {"varChars"},
			},
			["noDestruct"] = true,
		},
	})

	local varString = IEex_ReadDword(manager:getAddress("varString"))

	-- CVariableHash_FindKey
	local CVariable = IEex_Call(IEex_ReadDword(IEex_ReadDword(CVariableHash) + 0x4), {varString}, CVariableHash, 0x0)
	manager:free()
	return CVariable
end

function IEex_GetVariable(CVariableHash, name)
	local CVariable = IEex_GetCVariable(CVariableHash, name)
	if CVariable == 0x0 then return 0 end
	return IEex_ReadDword(CVariable + 0x28)
end

function IEex_SetVariable(CVariableHash, name, val)

	local CVariable = IEex_GetCVariable(CVariableHash, name)

	if CVariable == 0x0 then

		CVariable = IEex_Malloc(0x54)
		IEex_Call(0x452BD0, {}, CVariable, 0x0)
		IEex_WriteLString(CVariable, name:upper(), 32)
		IEex_WriteDword(CVariable + 0x28, val)

		-- CVariableHash_AddKey
		IEex_Call(IEex_ReadDword(IEex_ReadDword(CVariableHash)), {CVariable}, CVariableHash, 0x0)
		IEex_Free(CVariable)
	else
		IEex_WriteDword(CVariable + 0x28, val)
	end
end

function IEex_GetGlobal(name)
	return IEex_GetVariable(IEex_GetGameData() + 0x47FC, name)
end

function IEex_SetGlobal(name, val)
	IEex_SetVariable(IEex_GetGameData() + 0x47FC, name, val)
end

function IEex_GetActorLocal(actorID, name)
	if not IEex_IsSprite(actorID, true) then return 0 end
	return IEex_GetVariable(IEex_ReadDword(IEex_GetActorShare(actorID) + 0x72B2), name)
end

function IEex_SetActorLocal(actorID, name, val)
	if not IEex_IsSprite(actorID, true) then return end
	IEex_SetVariable(IEex_ReadDword(IEex_GetActorShare(actorID) + 0x72B2), name, val)
end

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
			if portraitIndex >= 0 and portraitIndex <= 5 then
				actorID = IEex_GetActorIDPortrait(portraitIndex)
			else
				actorID = portraitIndex
			end
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

function IEex_GetVisibleArea()
	local m_pObjectGame = IEex_GetGameData()
	local m_visibleArea = IEex_ReadByte(m_pObjectGame + 0x37E0, 0)
	return IEex_ReadDword(m_pObjectGame + m_visibleArea * 0x4 + 0x37E2)
end

function IEex_GetGameTick()
	return IEex_ReadDword(IEex_GetGameData() + 0x1B78)
end

-- Returns a number between 1 (Very Easy) and 6 (Heart of Fury Mode)
function IEex_GetGameDifficulty()
	local gameData = IEex_GetGameData()
	if bit.band(IEex_ReadByte(gameData + 0x44AC, 0x0), 0x1) > 0 then
		return 6
	else
		return IEex_ReadByte(gameData + 0x4456, 0x0)
	end
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
	return (bit.band(IEex_ReadByte(IEex_GetGameData() + 0x48E4, 0x0), 0x1) > 0)
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

	valueString = tostring(valueString)
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
			IEex_TracebackMessage("IEex CRITICAL ERROR - Couldn't find " .. arrayName .. ".2DA!")
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
	if share <= 65535 or share == nil then return 0 end
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
		return IEex_ReadDword(IEex_GetGameData() + 0x3816 + characterNum * 0x4)
	end
	return -1
end

function IEex_GetActorIDPortrait(portraitNum)
	if portraitNum >= 0 and portraitNum <= 5 then
		return IEex_ReadDword(IEex_GetGameData() + 0x382E + portraitNum * 0x4)
	end
	return -1
end

function IEex_GetActorPortraitNum(actorID)
	local curAddress = IEex_GetGameData() + 0x382E
	for i = 0, 5 do
		if IEex_ReadDword(curAddress) == actorID then return i end
		curAddress = curAddress + 0x4
	end
	return -1
end

function IEex_IsPartyMember(actorID)
	return (IEex_GetActorPortraitNum(actorID) ~= -1)
end

function IEex_GetActorIDSelected()
	local nodeHead = IEex_ReadDword(IEex_GetGameData() + 0x388E)
	if nodeHead ~= 0x0 then
		return IEex_ReadDword(nodeHead + 0x8)
	end
	return -1
end

function IEex_GetAllActorIDSelected()
	local ids = {}
	local CPtrList = IEex_GetGameData() + 0x388A
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

function IEex_IterateProjectiles(projectileID, func)
	IEex_IterateIDs(IEex_ReadDword(IEex_GetActorShare(IEex_GetActorIDPortrait(0)) + 0x12), 0, true, true, function(areaListID)
		local share = IEex_GetActorShare(areaListID)
		if projectileID == -1 or IEex_ReadWord(share + 0x6E, 0x0) == projectileID then
			func(share)
		end
	end)
end

function IEex_IterateFireballs(func)
	IEex_IterateIDs(IEex_ReadDword(IEex_GetActorShare(IEex_GetActorIDPortrait(0)) + 0x12), 0, true, true, function(areaListID)
		local share = IEex_GetActorShare(areaListID)
		if IEex_ReadDword(share) == 8712412 then
			func(share)
		end
	end)
end

function IEex_IterateTemporals(func)
	IEex_IterateIDs(IEex_ReadDword(IEex_GetActorShare(IEex_GetActorIDPortrait(0)) + 0x12), 0, true, true, function(areaListID)
		local share = IEex_GetActorShare(areaListID)
		if IEex_ReadDword(share) == 8712524 then
			func(share)
		end
	end)
end

function IEex_IterateCastingGlows(func)
	IEex_IterateIDs(IEex_ReadDword(IEex_GetActorShare(IEex_GetActorIDPortrait(0)) + 0x12), 0, true, true, function(areaListID)
		local share = IEex_GetActorShare(areaListID)
		if IEex_ReadDword(share) == 8720284 then
			func(share)
		end
	end)
end

function IEex_GetOngoingProjectile(index)
	local ids = IEex_GetIDArea(IEex_GetActorShare(IEex_GetActorIDPortrait(0)), 0, true, true)
	if index <= #ids then
		return IEex_GetActorShare(ids[index])
	else
		return 0
	end
end

function IEex_GetActorShare(actorID)
	if not actorID then return 0 end
	local CGameObjectArray = IEex_GetGameData() + 0x372C

	local resultPtr = IEex_Malloc(0x4)
	IEex_Call(0x599A50, {-1, resultPtr, 0, actorID}, CGameObjectArray, 0x0)

	local toReturn = IEex_ReadDword(resultPtr)
	IEex_Free(resultPtr)
	return toReturn
end

function IEex_UndoActorShare(actorID)
	local CGameObjectArray = IEex_GetGameData() + 0x372C
	IEex_Call(0x599E70, {-1, 0, actorID}, CGameObjectArray, 0x0)
end

function IEex_GS(actorID)
	return IEex_GetActorShare(actorID)
end

function IEex_GIDC()
	return IEex_GetActorIDCursor()
end

function IEex_GIDS()
	return IEex_GetActorIDSelected()
end

function IEex_GIDA(requiredObjectType)
	return IEex_GetIDArea(IEex_GetActorIDCharacter(0), requiredObjectType, true, true)
end

function IEex_GSC()
	return IEex_GetActorShare(IEex_GetActorIDCursor())
end

function IEex_GSS()
	return IEex_GetActorShare(IEex_GetActorIDSelected())
end

function IEex_IIDS(requiredObjectType, func)
	IEex_IterateIDs(IEex_ReadDword(IEex_GetActorShare(IEex_GetActorIDCharacter(0)) + 0x12), requiredObjectType, true, true, func)
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

function Feats_CombatReflexes(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 1)
end

function Feats_ConcoctPotions(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x7B4, 0x0) >= 10)
end

function Feats_Counterspell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x628, 0x0) > 3 or IEex_ReadByte(creatureData + 0x629, 0x0) > 2 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 2 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 4 or IEex_ReadByte(creatureData + 0x630, 0x0) > 3 or IEex_ReadByte(creatureData + 0x631, 0x0) > 2)
end

function Feats_DefensiveRoll(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x62F, 0x0) > 9)
end

function Feats_DefensiveStance(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 2)
--	return (IEex_ReadByte(creatureData + 0x627, 0x0) > 0 or IEex_ReadByte(creatureData + 0x62B, 0x0) > 0 or IEex_ReadByte(creatureData + 0x62C, 0x0) > 0 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 0 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 0)
end

function Feats_EmpowerSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x628, 0x0) > 6 or IEex_ReadByte(creatureData + 0x629, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 7 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 7 or IEex_ReadByte(creatureData + 0x630, 0x0) > 5 or IEex_ReadByte(creatureData + 0x631, 0x0) > 4)
end

function Feats_ExtendSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x628, 0x0) > 3 or IEex_ReadByte(creatureData + 0x629, 0x0) > 2 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 2 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 4 or IEex_ReadByte(creatureData + 0x630, 0x0) > 3 or IEex_ReadByte(creatureData + 0x631, 0x0) > 2)
end
--[[
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
--]]
function Feats_Feint(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x7B6, 0x0) >= 4)
end

function Feats_ImprovedSneakAttack(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x62F, 0x0) > 4)
end
--[[
function Feats_ImprovedTwoWeaponFighting(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x62E, 0x0) > 8 or (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 16 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x2) > 0 and bit.band(IEex_ReadDword(creatureData + 0x764), 0x40) > 0))
end
--]]
function Feats_ImprovedTwoWeaponFighting(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local imptwfFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_IMPROVED_TWO_WEAPON_FIGHTING"], 0x0)
	if imptwfFeatCount == 0 then
		return (IEex_ReadByte(creatureData + 0x62E, 0x0) > 8 or (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 16 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x2) > 0 and bit.band(IEex_ReadDword(creatureData + 0x764), 0x40) > 0))
	elseif imptwfFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x62E, 0x0) > 15)
	else
		return true
	end
end

function Prereq_ImprovedTwoWeaponFighting(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local imptwfFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_IMPROVED_TWO_WEAPON_FIGHTING"], 0x0)
	if imptwfFeatCount == 0 then
		return (IEex_ReadByte(creatureData + 0x62E, 0x0) > 8 or (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 16 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x2) > 0 and bit.band(IEex_ReadDword(creatureData + 0x764), 0x40) > 0))
	elseif imptwfFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x62E, 0x0) > 15)
	else
		return true
	end
end

function Feats_ImprovedUnarmedAbilities(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (bit.band(IEex_ReadDword(creatureData + 0x764), 0x8) > 0)
end

function Feats_Kensei(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
--[[
--	IEex_Search_Log(1, IEex_GetGameData(), 0x7200, false)
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
--	local m_pObjectGame = IEex_ReadDword(g_pBaldurChitin + 0x1C54)
	local mysteriousData = IEex_ReadDword(g_pBaldurChitin + 0x1C64)
	if mysteriousData > 0 then
		IEex_Search_Change_Log(1, mysteriousData, 0x1000, false)
	end
--]]
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
--[[
function Feats_Manyshot(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x62E, 0x0) > 8 or (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 16 and bit.band(IEex_ReadDword(creatureData + 0x760), 0x30000) == 0x30000))
end
--]]
function Feats_Manyshot(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local manyshotFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MANYSHOT"], 0x0)
	if manyshotFeatCount == 0 then
		return (IEex_ReadByte(creatureData + 0x62E, 0x0) > 8 or (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 16 and bit.band(IEex_ReadDword(creatureData + 0x760), 0x30000) == 0x30000))
	elseif manyshotFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x62E, 0x0) > 15)
	else
		return true
	end
end

function Prereq_Manyshot(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local manyshotFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MANYSHOT"], 0x0)
	if manyshotFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x62E, 0x0) > 8 or (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 16 and bit.band(IEex_ReadDword(creatureData + 0x760), 0x30000) == 0x30000))
	elseif manyshotFeatCount == 2 then
		return (IEex_ReadByte(creatureData + 0x62E, 0x0) > 15)
	else
		return true
	end
end

function Feats_MassSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x628, 0x0) > 15 or IEex_ReadByte(creatureData + 0x629, 0x0) > 10 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 10 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 16 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 16 or IEex_ReadByte(creatureData + 0x630, 0x0) > 11 or IEex_ReadByte(creatureData + 0x631, 0x0) > 10)
end

function Feats_MasterOfMagicForce(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x7C1, 0x0) >= 10 and (IEex_ReadByte(creatureData + 0x628, 0x0) > 9 or IEex_ReadByte(creatureData + 0x629, 0x0) > 6 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 6 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 10 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 10 or IEex_ReadByte(creatureData + 0x630, 0x0) > 7 or IEex_ReadByte(creatureData + 0x631, 0x0) > 6))
end

function Feats_MaximizeSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x628, 0x0) > 9 or IEex_ReadByte(creatureData + 0x629, 0x0) > 6 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 6 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 10 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 10 or IEex_ReadByte(creatureData + 0x630, 0x0) > 7 or IEex_ReadByte(creatureData + 0x631, 0x0) > 6)
end
--[[
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
--]]
function Feats_Mobility(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x805, 0x0) >= 13 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0)
end

function Feats_NaturalSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x62A, 0x0) > 4 and IEex_ReadByte(creatureData + 0x807, 0x0) >= 13)
end

function Feats_PersistentSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x628, 0x0) > 18 or IEex_ReadByte(creatureData + 0x629, 0x0) > 12 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 12 or IEex_ReadByte(creatureData + 0x630, 0x0) > 13 or IEex_ReadByte(creatureData + 0x631, 0x0) > 12)
end

function Feats_QuickenSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x628, 0x0) > 6 or IEex_ReadByte(creatureData + 0x629, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 7 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 7 or IEex_ReadByte(creatureData + 0x630, 0x0) > 5 or IEex_ReadByte(creatureData + 0x631, 0x0) > 4)
end
--[[
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
--]]
function Feats_RapidReload(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 6 and IEex_ReadByte(creatureData + 0x775, 0x0) >= 2)
end

function Feats_SafeSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x628, 0x0) > 3 or IEex_ReadByte(creatureData + 0x629, 0x0) > 2 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 2 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 4 or IEex_ReadByte(creatureData + 0x630, 0x0) > 3 or IEex_ReadByte(creatureData + 0x631, 0x0) > 2)
end
--[[
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
--]]
function Feats_ShieldFocus(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	if bit.band(IEex_ReadDword(creatureData + 0x760), 0x100000) == 0 then
		return false
	else
		local shieldFocusFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SHIELD_FOCUS"], 0x0)
		return (shieldFocusFeatCount == 0 or IEex_ReadByte(creatureData + 0x62B, 0x0) > 3)
	end
end

function Prereq_ShieldFocus(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	if bit.band(IEex_ReadDword(creatureData + 0x760), 0x100000) == 0 then
		return false
	else
		local shieldFocusFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SHIELD_FOCUS"], 0x0)
		return (shieldFocusFeatCount <= 1 or IEex_ReadByte(creatureData + 0x62B, 0x0) > 3)
	end
end

function Feats_SpringAttack(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x805, 0x0) >= 13 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MOBILITY"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 4)
end

function Feats_TerrifyingRage(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x627, 0x0) > 14 and IEex_ReadByte(creatureData + 0x7BB, 0x0) >= 18)
end

function Feats_TwoWeaponDefense(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x62E, 0x0) > 0 or bit.band(IEex_ReadDword(creatureData + 0x764), 0x40) > 0)
end

function Feats_WhirlwindAttack(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local whirlwindAttackFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_WHIRLWIND_ATTACK"], 0x0)
	if whirlwindAttackFeatCount == 0 then
		return (IEex_ReadByte(creatureData + 0x805, 0x0) >= 13 and (IEex_ReadByte(creatureData + 0x62E, 0x0) > 5 or (IEex_ReadByte(creatureData + 0x803, 0x0) >= 13 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x80000) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MOBILITY"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SPRING_ATTACK"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 4)))
	elseif whirlwindAttackFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x805, 0x0) >= 21 and (IEex_ReadByte(creatureData + 0x62E, 0x0) > 5 or (IEex_ReadByte(creatureData + 0x803, 0x0) >= 13 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x80000) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MOBILITY"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SPRING_ATTACK"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 4)))
	elseif whirlwindAttackFeatCount == 2 then
		return (IEex_ReadByte(creatureData + 0x805, 0x0) >= 27 and IEex_ReadByte(creatureData + 0x62E, 0x0) > 29)
	else
		return true
	end
end

function Prereq_WhirlwindAttack(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	local whirlwindAttackFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_WHIRLWIND_ATTACK"], 0x0)
	if whirlwindAttackFeatCount == 1 then
		return (IEex_ReadByte(creatureData + 0x805, 0x0) >= 13 and (IEex_ReadByte(creatureData + 0x62E, 0x0) > 5 or (IEex_ReadByte(creatureData + 0x803, 0x0) >= 13 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x80000) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MOBILITY"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SPRING_ATTACK"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 4)))
	elseif whirlwindAttackFeatCount == 2 then
		return (IEex_ReadByte(creatureData + 0x805, 0x0) >= 21 and (IEex_ReadByte(creatureData + 0x62E, 0x0) > 5 or (IEex_ReadByte(creatureData + 0x803, 0x0) >= 13 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x10000) > 0 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x80000) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MOBILITY"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SPRING_ATTACK"], 0x0) > 0 and IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 4)))
	elseif whirlwindAttackFeatCount == 3 then
		return (IEex_ReadByte(creatureData + 0x805, 0x0) >= 27 and IEex_ReadByte(creatureData + 0x62E, 0x0) > 29)
	else
		return true
	end
end

function Feats_WidenSpell(actorID, featID)
	local creatureData = IEex_GetActorShare(actorID)
	return (IEex_ReadByte(creatureData + 0x628, 0x0) > 3 or IEex_ReadByte(creatureData + 0x629, 0x0) > 2 or IEex_ReadByte(creatureData + 0x62A, 0x0) > 2 or IEex_ReadByte(creatureData + 0x62D, 0x0) > 4 or IEex_ReadByte(creatureData + 0x62E, 0x0) > 4 or IEex_ReadByte(creatureData + 0x630, 0x0) > 3 or IEex_ReadByte(creatureData + 0x631, 0x0) > 2)
end

------------------------------------------------------------
-- Functions which can be used by Opcode 500 (Invoke Lua) --
------------------------------------------------------------

-- Changes the actionbar button at index [parameter1]
--  to the type in [parameter2].
function EXBUTTON(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local internalFlags = IEex_ReadDword(effectData + 0xC8)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	if bit.band(internalFlags, 0x10) == 0 or sourceID <= 0 then
		IEex_WriteDword(effectData + 0x10C, targetID)
		IEex_WriteDword(effectData + 0xC8, bit.bor(internalFlags, 0x10))
		IEex_SetActionbarButton(IEex_GetActorIDShare(creatureData), parameter1, parameter2)
	end
end

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

function IEex_Search_Change_Log(read_size, search_start, search_length, noise_reduction)
	for i = 0, search_length, 1 do
		local previous = ex_search_previous["" .. i]
		local current = IEex_ReadSignedByte(search_start + i, 0x0)
		if read_size == 2 then
			current = IEex_ReadSignedWord(search_start + i, 0x0)
		elseif read_size == 4 then
			current = IEex_ReadDword(search_start + i)
		end
		if previous ~= nil and previous ~= current and ex_search_exclude["" .. i] == nil then
			print(IEex_ToHex(i, 0, true) .. ": Changed from " .. previous .. " to " .. current)
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
				IEex_DisplayString("Match found for " .. search_target .. " at offset " .. IEex_ToHex(i, 0, false))
				if noise_reduction == true then
					ex_search_exclude["" .. i] = true
				end
			end
		end
	else
		for i = 0, search_length, 1 do
			if ex_search_exclude["" .. i] == nil then
				if IEex_ReadDword(search_start + i) == search_target then
					IEex_DisplayString("Match found for " .. search_target .. " at offset " .. IEex_ToHex(i, 0, false) .. " (4 bytes)")
				elseif search_target < 65536 and IEex_ReadWord(search_start + i, 0x0) == search_target then
					IEex_DisplayString("Match found for " .. search_target .. " at offset " .. IEex_ToHex(i, 0, false) .. " (2 bytes)")
				elseif search_target < 256 and IEex_ReadByte(search_start + i, 0x0) == search_target then
					IEex_DisplayString("Match found for " .. search_target .. " at offset " .. IEex_ToHex(i, 0, false) .. " (1 byte)")
				end
				if noise_reduction == true then
					ex_search_exclude["" .. i] = true
				end
			end
		end
	end
end

function IEex_Search_Log(search_target, search_start, search_length, noise_reduction)
	if type(search_target) == "string" then
		for i = 0, search_length, 1 do
			if IEex_ReadLString(search_start + i, 0x8) == search_target and ex_search_exclude["" .. i] == nil then
				print("Match found for " .. search_target .. " at offset " .. IEex_ToHex(i, 0, false))
				if noise_reduction == true then
					ex_search_exclude["" .. i] = true
				end
			end
		end
	else
		for i = 0, search_length, 1 do
			if ex_search_exclude["" .. i] == nil then
				if IEex_ReadDword(search_start + i) == search_target then
					print("Match found for " .. search_target .. " at offset " .. IEex_ToHex(i, 0, false) .. " (4 bytes)")
				elseif search_target < 65536 and IEex_ReadWord(search_start + i, 0x0) == search_target then
					print("Match found for " .. search_target .. " at offset " .. IEex_ToHex(i, 0, false) .. " (2 bytes)")
				elseif search_target < 256 and IEex_ReadByte(search_start + i, 0x0) == search_target then
					print("Match found for " .. search_target .. " at offset " .. IEex_ToHex(i, 0, false) .. " (1 byte)")
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
Bit 19: If set, the character's Sneak Attack dice will be added to the damage if the conditions for a Sneak Attack are met. Bit 17, 18 or 23 must be set for a sneak attack to happen, unless the character has a "Sneak Attack with Spells" effect.
Bit 21: If set, the character gains temporary Hit Points (for 1 hour) equal to the damage dealt.
Bit 22: If set, the character regains Hit Points equal to the damage dealt (but will not go over the character's max HP).
Bit 23: If set, the damage can count as a Sneak Attack even if Bits 17 and 18 are not set.
Bit 24: If set, no damage will be dealt except on a successful Sneak Attack.
Bit 25: If set, the damage will be reduced by the target's damage reduction if the damage's enchantment level (specified in the fourth bit of special) is too low.
Bit 26: If set, the damage bypasses Mirror Image.

savebonus - The saving throw DC bonus of the damage is equal to that of the opcode 500 effect.

special - The first byte determines which stat should be used to determine an extra damage bonus (e.g. for Strength weapons, this would be stat 36 or 0x24: the Strength stat).
 If set to 0, there is no stat-based damage bonus. If the chosen stat is an ability score, the bonus will be based on the ability score bonus (e.g. 16 Strength would translate to +3);
 otherwise, the bonus is equal to the stat. The second byte determines a multiplier to the stat-based damage bonus, while the third byte determines a divisor to it (for example,
 if the damage was from a two-handed Strength weapon, special would be equal to 0x20324: the Strength bonus is multiplied by 3 then divided by 2 to get the damage bonus). If the
 multiplier or divisor is 0, the function sets it to 1.
--]]
ex_item_type_proficiency = {[5] = 39, [14] = 55, [15] = 39, [16] = 57, [17] = 54, [18] = 55, [19] = 57, [20] = 43, [21] = 42, [22] = 54, [23] = 40, [24] = 55, [25] = 38, [26] = 56, [27] = 53, [29] = 44, [30] = 44, [31] = 53, [44] = 4, [57] = 41, [69] = 18}
ex_item_type_critical = {[0] = {0, 2}, [5] = {0, 3}, [14] = {0, 2}, [15] = {0, 3}, [16] = {1, 2}, [17] = {0, 2}, [18] = {0, 2}, [19] = {1, 2}, [20] = {1, 2}, [21] = {0, 3}, [22] = {0, 3}, [23] = {0, 3}, [24] = {0, 2}, [25] = {0, 3}, [26] = {0, 2}, [27] = {0, 2}, [28] = {0, 2}, [29] = {0, 3}, [30] = {0, 3}, [31] = {0, 2}, [44] = {0, 2}, [57] = {1, 2}, [69] = {1, 2}}
ex_crippling_strike = {ex_tra_905, ex_tra_905, ex_tra_905, ex_tra_905, ex_tra_905, ex_tra_906, ex_tra_906, ex_tra_906, ex_tra_907, ex_tra_907, ex_tra_907, ex_tra_908, ex_tra_908, ex_tra_908, ex_tra_909, ex_tra_909, ex_tra_909, ex_tra_910, ex_tra_910, ex_tra_910, ex_tra_911, ex_tra_911, ex_tra_911, ex_tra_912, ex_tra_912, ex_tra_912, ex_tra_913, ex_tra_913, ex_tra_913, ex_tra_914}
ex_arterial_strike = {1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5}
ex_damage_source_spell = {["EFFAS1"] = "SPWI217", ["EFFAS2"] = "SPWI217", ["EFFCL"] = "SPPR302", ["EFFCT1"] = "SPWI117", ["EFFDA3"] = "SPWI228", ["EFFFS1"] = "SPWI427", ["EFFFS2"] = "SPWI426", ["EFFIK"] = "SPWI122", ["EFFMB1"] = "SPPR318", ["EFFMB2"] = "SPPR318", ["EFFMT1"] = "SPPR322", ["EFFPB1"] = "SPWI521", ["EFFPB2"] = "SPWI521", ["EFFS1"] = "SPPR113", ["EFFS2"] = "SPPR113", ["EFFS3"] = "SPPR113", ["EFFSC"] = "SPPR523", ["EFFSOF1"] = "SPWI511", ["EFFSOF2"] = "SPWI511", ["EFFSR1"] = "SPPR707", ["EFFSR2"] = "SPPR707", ["EFFSSO1"] = "SPPR608", ["EFFSSO2"] = "SPPR608", ["EFFSSO3"] = "SPPR608", ["EFFSSS1"] = "SPWI220", ["EFFSSS2"] = "SPWI220", ["EFFVS1"] = "SPWI424", ["EFFVS2"] = "SPWI424", ["EFFVS3"] = "SPWI424", ["EFFWOM1"] = "SPPR423", ["EFFWOM2"] = "SPPR423", ["EFFHW15"] = "SPWI805", ["EFFHW16"] = "SPWI805", ["EFFHW17"] = "SPWI805", ["EFFHW18"] = "SPWI805", ["EFFHW19"] = "SPWI805", ["EFFHW20"] = "SPWI805", ["EFFHW21"] = "SPWI805", ["EFFHW22"] = "SPWI805", ["EFFHW23"] = "SPWI805", ["EFFHW24"] = "SPWI805", ["EFFHW25"] = "SPWI805", ["EFFWT15"] = "SPWI805", ["EFFWT16"] = "SPWI805", ["EFFWT17"] = "SPWI805", ["EFFWT18"] = "SPWI805", ["EFFWT19"] = "SPWI805", ["EFFWT20"] = "SPWI805", ["EFFWT21"] = "SPWI805", ["EFFWT22"] = "SPWI805", ["EFFWT23"] = "SPWI805", ["EFFWT24"] = "SPWI805", ["EFFWT25"] = "SPWI805", ["USWI422D"] = "SPWI422", ["USWI452D"] = "USWI452", ["USWI652D"] = "USWI652", ["USWI755D"] = "USWI755", ["USWI954F"] = "USWI954", ["USDESTRU"] = "SPPR717", ["USPR953D"] = "USPR953", ["USWI653D"] = "USWI653", ["USWI956D"] = "USWI956", ["USWI759D"] = "USWI759", ["USWI759E"] = "USWI759", }
ex_feat_id_offset = {[18] = 0x78D, [38] = 0x777, [39] = 0x774, [40] = 0x779, [41] = 0x77D, [42] = 0x77B, [43] = 0x77E, [44] = 0x77A, [53] = 0x775, [54] = 0x778, [55] = 0x776, [56] = 0x77C, [57] = 0x77F}
ex_damage_multiplier_type = {[0] = 9, [0x10000] = 4, [0x20000] = 2, [0x40000] = 3, [0x80000] = 1, [0x100000] = 8, [0x200000] = 6, [0x400000] = 5, [0x800000] = 10, [0x1000000] = 7, [0x2000000] = 1, [0x4000000] = 2, [0x8000000] = 9, [0x10000000] = 5}
ex_damage_resistance_stat = {[0] = 22, [0x10000] = 17, [0x20000] = 15, [0x40000] = 16, [0x80000] = 14, [0x100000] = 23, [0x200000] = 74, [0x400000] = 73, [0x800000] = 24, [0x1000000] = 21, [0x2000000] = 19, [0x4000000] = 20, [0x8000000] = 22, [0x10000000] = 73}
function EXDAMAGE(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then 
--		IEex_DS(IEex_ReadLString(effectData + 0x90, 8))
	return
	end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceData = IEex_GetActorShare(sourceID)
	local damage = IEex_ReadByte(effectData + 0x18, 0x0)
	local dicesize = IEex_ReadByte(effectData + 0x19, 0x0)
	local dicenumber = IEex_ReadByte(effectData + 0x1A, 0x0)
	local proficiency = IEex_ReadByte(effectData + 0x1B, 0x0)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local parameter3 = IEex_ReadDword(effectData + 0x5C)
	local parameter4 = IEex_ReadDword(effectData + 0x60)
	local damageType = bit.band(parameter2, 0xFFFF0000)
	local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local savebonus = IEex_ReadDword(effectData + 0x40)
--	IEex_DS("savebonus A: " .. savebonus)
	local bonusStat = IEex_ReadByte(effectData + 0x44, 0x0)
	local bonusStatMultiplier = IEex_ReadByte(effectData + 0x45, 0x0)
	local bonusStatDivisor = IEex_ReadByte(effectData + 0x46, 0x0)
	local saveBonusStat = IEex_ReadByte(effectData + 0x47, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	local internalFlags = IEex_ReadDword(effectData + 0xC8)
	local sourceSpell = ex_damage_source_spell[parent_resource]
	if sourceSpell == nil then
		sourceSpell = parent_resource
	end
	local classSpellLevel = 0
	if IEex_IsSprite(sourceID, true) then
		classSpellLevel = IEex_GetClassSpellLevel(sourceID, casterClass, sourceSpell)
	end
	if classSpellLevel <= 0 then
		local resWrapper = IEex_DemandRes(sourceSpell, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if IEex_ReadWord(spellData + 0x1C, 0x0) == 1 or IEex_ReadWord(spellData + 0x1C, 0x0) == 2 then
				classSpellLevel = IEex_ReadDword(spellData + 0x34)
			end
		end
		resWrapper:free()
	end
	savebonus = savebonus + classSpellLevel
--	IEex_DS("savebonus B: " .. savebonus)
	local trueschool = 0
	if ex_trueschool[sourceSpell] ~= nil then
		trueschool = ex_trueschool[sourceSpell]
	end
	if trueschool > 0 then
		local sourceKit = IEex_GetActorStat(sourceID, 89)
		if bit.band(sourceKit, 0x4000) > 0 then
			savebonus = savebonus + 1
		elseif ex_spell_focus_component_installed then
			if trueschool == 1 and bit.band(sourceKit, 0x40) > 0 or trueschool == 2 and bit.band(sourceKit, 0x80) > 0 or trueschool == 3 and bit.band(sourceKit, 0x100) > 0 or trueschool == 5 and bit.band(sourceKit, 0x400) > 0 then
				savebonus = savebonus + 2
			elseif trueschool == 1 and bit.band(sourceKit, 0x2000) > 0 or trueschool == 2 and bit.band(sourceKit, 0x800) > 0 or trueschool == 3 and bit.band(sourceKit, 0x1000) > 0 or trueschool == 5 and bit.band(sourceKit, 0x200) > 0 then
				savebonus = savebonus - 2
			end
		end
	end
--	IEex_DS("savebonus C: " .. savebonus)
	local rogueLevel = 0
	local sneakAttackDiceNumber = 0
	local isSneakAttack = false
	local isTrueBackstab = false
	local hasProtection = false
	if IEex_IsSprite(sourceID, true) then
		if bit.band(savingthrow, 0x40) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x784, 0x0) * 2
		end
		if bit.band(savingthrow, 0x80) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x785, 0x0) * 2
		end
		if bit.band(savingthrow, 0x100) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x786, 0x0) * 2
		end
		if bit.band(savingthrow, 0x200) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x787, 0x0) * 2
		end
--		IEex_DS("savebonus D: " .. savebonus)
		if proficiency > 0 and ex_feat_id_offset[proficiency] ~= nil then
			local proficiencyDamage = ex_proficiency_damage[IEex_ReadByte(sourceData + ex_feat_id_offset[proficiency], 0x0)]
			if proficiencyDamage ~= nil then
				damage = damage + proficiencyDamage
			end
		end
		if bit.band(savingthrow, 0x20000) > 0 then
			for i = 1, 5, 1 do
				if IEex_GetActorSpellState(sourceID, i + 75) then
					damage = damage + i
				end
			end
		end
		if IEex_GetActorSpellState(sourceID, 233) and bit.band(savingthrow, 0x20000) == 0 and bit.band(savingthrow, 0x40000) == 0 and bit.band(savingthrow, 0x800000) == 0 then
			damage = damage + math.floor((IEex_GetActorStat(sourceID, 36) - 10) / 4)
		end
		rogueLevel = IEex_GetActorStat(sourceID, 104)
		local stateValue = bit.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
		if (rogueLevel > 0 or IEex_GetActorSpellState(sourceID, 192)) and bit.band(savingthrow, 0x80000) and (IEex_GetActorSpellState(sourceID, 218) or (IEex_GetActorSpellState(sourceID, 217)) or IEex_IsValidBackstabDirection(sourceID, targetID) or bit.band(stateValue, 0x80140029) > 0 or IEex_GetActorSpellState(targetID, 183) or IEex_GetActorSpellState(targetID, 186)) and IEex_GetActorStat(targetID, 96) == 0 and IEex_GetActorSpellState(targetID, 216) == false and (bit.band(savingthrow, 0x20000) > 0 or bit.band(savingthrow, 0x40000) > 0 or bit.band(savingthrow, 0x800000) > 0 or (bit.band(savingthrow, 0x40000) == 0 and IEex_GetActorSpellState(sourceID, 232))) then
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
["parent_resource"] = "USINVSNR",
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
			sneakAttackDiceNumber = math.floor((rogueLevel + 1) / 2)
			local improvedSneakAttackFeatID = ex_feat_name_id["ME_IMPROVED_SNEAK_ATTACK"]
			local improvedSneakAttackCount = 0
			if improvedSneakAttackFeatID ~= nil then
				improvedSneakAttackCount = IEex_ReadByte(sourceData + 0x744 + improvedSneakAttackFeatID, 0x0)
				sneakAttackDiceNumber = sneakAttackDiceNumber + improvedSneakAttackCount
			end
--			if IEex_GetActorSpellState(sourceID, 192) then
				IEex_IterateActorEffects(sourceID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					if theopcode == 288 and theparameter2 == 192 then
						local theparameter1 = IEex_ReadDword(eData + 0x1C)
						local thesavingthrow = IEex_ReadDword(eData + 0x40)
						local theresource = IEex_ReadLString(eData + 0x30, 8)
						local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
						if (bit.band(thesavingthrow, 0x10000) == 0 or theresource == parent_resource or theparent_resource == parent_resource) and (bit.band(thesavingthrow, 0x20000) == 0 or isTrueBackstab) and (bit.band(thesavingthrow, 0x40000) > 0 or rogueLevel > 0) then
							sneakAttackDiceNumber = sneakAttackDiceNumber + theparameter1
						end
					end
				end)
--			end
		end
	end
	local luck = 0
	local currentRoll = 0
	if IEex_IsSprite(sourceID, true) and (bit.band(savingthrow, 0x20000) > 0 or bit.band(savingthrow, 0x40000) > 0) then
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
	elseif IEex_IsSprite(sourceID, true) and bit.band(savingthrow, 0x800000) > 0 then
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
			if (maximumMaximizeSpellLevel >= 99 or classSpellLevel > 0) and maximumMaximizeSpellLevel >= classSpellLevel then
				luck = 127
			end
		end
	end
	if bit.band(internalFlags, 0x200000) > 0 then
		luck = 127
	end
	if dicesize > 0 and dicenumber > 0 and (bit.band(savingthrow, 0x1000000) == 0 or (isSneakAttack and rogueLevel > 0)) then
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
		hasCripplingStrikeFeat = (bit.band(IEex_ReadDword(sourceData + 0x75C), 0x800) > 0)
		if bit.band(savingthrow, 0x80000) > 0 and isSneakAttack and sneakAttackDiceNumber > 0 then

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
			bonusStatValue = IEex_GetActorStat(sourceID, bonusStat)

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
		if saveBonusStat > 0 and bit.band(savingthrow, 0x2000000) == 0 then
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
--		if IEex_GetActorSpellState(sourceID, 236) then
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
--		end
--		if IEex_GetActorSpellState(sourceID, 242) then
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 242 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if thespecial == trueschool or thespecial == -1 or ((thespecial == 4 or thespecial == 5) and bit.band(savingthrow, 0x40) > 0) or ((thespecial == 2 or thespecial == 6) and bit.band(savingthrow, 0x80) > 0) or ((thespecial == 3 or thespecial == 7) and bit.band(savingthrow, 0x100) > 0) or ((thespecial == 1 or thespecial == 8) and bit.band(savingthrow, 0x200) > 0) then
						savebonus = savebonus + theparameter1
					end
				end
			end)
--		end
	end
--	if IEex_GetActorSpellState(targetID, 237) then
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
--	end
--	if IEex_GetActorSpellState(targetID, 243) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 242 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if thespecial == trueschool or thespecial == -1 or ((thespecial == 4 or thespecial == 5) and bit.band(savingthrow, 0x40) > 0) or ((thespecial == 2 or thespecial == 6) and bit.band(savingthrow, 0x80) > 0) or ((thespecial == 3 or thespecial == 7) and bit.band(savingthrow, 0x100) > 0) or ((thespecial == 1 or thespecial == 8) and bit.band(savingthrow, 0x200) > 0) then
					savebonus = savebonus + theparameter1
				end
			end
		end)
--	end
--	IEex_DS("savebonus E: " .. savebonus)
	local newSavingThrow = 0
	if bit.band(savingthrow, 0x400) > 0 then
		newSavingThrow = bit.bor(newSavingThrow, 0x4)
	end
	if bit.band(savingthrow, 0x800) > 0 then
		newSavingThrow = bit.bor(newSavingThrow, 0x8)
	end
	if bit.band(savingthrow, 0x1000) > 0 then
		newSavingThrow = bit.bor(newSavingThrow, 0x10)
	end
	local damageBlocked = false
	local damageAbsorbed = false
--	if IEex_GetActorSpellState(targetID, 214) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if theopcode == 288 and theparameter2 == 214 and (theparameter1 == IEex_ReadWord(effectData + 0x1E, 0x0) or (theresource == parent_resource and (theresource ~= "" or bit.band(thesavingthrow, 0x20000) > 0))) then
				damageBlocked = true
				if bit.band(thesavingthrow, 0x10000) > 0 then
					damageAbsorbed = true
				end
			end
		end)
--	end
	if IEex_IsSprite(sourceID, true) and bit.band(savingthrow, 0x10000) > 0 then
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
	if bit.band(internalFlags, 0x100000) > 0 then
		damage = math.floor(damage * 1.5)
	end
	if parameter4 > 0 then
		damage = damage * parameter4
		newSavingThrow = bit.bor(newSavingThrow, 0x10000)
	end
	if bit.band(savingthrow, 0x2000000) > 0 then
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
	local newvvcresource = ""
	local newparent_resource = parent_resource
	if bit.band(savingthrow, 0x20000) > 0 then
		newvvcresource = parent_resource
		newparent_resource = "IEEX_DAM"
	end
	local previousMirrorImages = 0
	if damage <= 0 then
		damage = 0
	else
		if parameter2 == 0x7FFFFFFF or damageAbsorbed then
			newSavingThrow = bit.band(newSavingThrow, 0xFFFFE3E3)
			IEex_ApplyEffectToActor(targetID, {
	["opcode"] = 17,
	["target"] = 2,
	["timing"] = 1,
	["parameter1"] = damage,
	["parameter2"] = 0,
	["savingthrow"] = newSavingThrow,
	["savebonus"] = savebonus,
	["vvcresource"] = newvvcresource,
	["parent_resource"] = newparent_resource,
	["source_target"] = targetID,
	["source_id"] = sourceID
	})
		elseif damageBlocked == false then
			if bit.band(savingthrow, 0x4000000) > 0 then
				previousMirrorImages = IEex_ReadSignedByte(creatureData + 0xA60, 0x0)
				IEex_WriteByte(creatureData + 0xA60, 0)
				IEex_WriteByte(creatureData + 0x18B8, 0)
				IEex_WriteDword(creatureData + 0x920, bit.band(IEex_ReadDword(creatureData + 0x920), 0xBFFFFFFF))
				IEex_WriteDword(creatureData + 0x1778, bit.band(IEex_ReadDword(creatureData + 0x1778), 0xBFFFFFFF))
			end
			IEex_ApplyEffectToActor(targetID, {
	["opcode"] = 12,
	["target"] = 2,
	["timing"] = 1,
	["parameter1"] = damage,
	["parameter2"] = parameter2,
	["savingthrow"] = newSavingThrow,
	["savebonus"] = savebonus,
	["vvcresource"] = newvvcresource,
	["parent_resource"] = newparent_resource,
	["source_target"] = targetID,
	["source_id"] = sourceID
	})
			if previousMirrorImages > 0 then
				IEex_WriteByte(creatureData + 0xA60, previousMirrorImages)
				IEex_WriteByte(creatureData + 0x18B8, previousMirrorImages)
				IEex_WriteDword(creatureData + 0x920, bit.bor(IEex_ReadDword(creatureData + 0x920), 0x40000000))
				IEex_WriteDword(creatureData + 0x1778, bit.bor(IEex_ReadDword(creatureData + 0x1778), 0x40000000))
			end
		end
		if (bit.band(savingthrow, 0x200000) > 0 or bit.band(savingthrow, 0x400000) > 0) and damageBlocked == false then
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
					if bit.band(savingthrow, 0x200000) > 0 then
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
--		if IEex_GetActorSpellState(sourceID, 223) then
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
						if (bit.band(IEex_ReadDword(eData + 0x38), 0x200000) > 0) then
							newEffectTarget = sourceID
							newEffectTargetX = IEex_ReadDword(effectData + 0x7C)
							newEffectTargetY = IEex_ReadDword(effectData + 0x80)
						end
						local newEffectSource = sourceID
						local newEffectSourceX = IEex_ReadDword(effectData + 0x7C)
						local newEffectSourceY = IEex_ReadDword(effectData + 0x80)
						if (bit.band(IEex_ReadDword(eData + 0x38), 0x400000) > 0) then
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
--		end
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
	if bit.band(savingthrow, 0x20000) > 0 or bit.band(savingthrow, 0x40000) > 0 then
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
	if bit.band(savingthrow, 0x10000) > 0 then
		local damageMultiplier = 100
		local damageType = bit.band(parameter2, 0xFFFF0000)
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
	local damageType = bit.band(parameter2, 0xFFFF0000)
	local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local internalFlags = IEex_ReadDword(effectData + 0xC8)
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
			if ((maximumMaximizeSpellLevel >= 99 or classSpellLevel > 0) and maximumMaximizeSpellLevel > classSpellLevel) or bit.band(internalFlags, 0x200000) > 0 then
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
--		if IEex_GetActorSpellState(sourceID, 191) then
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
			dicenumber = math.floor(dicenumber * healingMultiplier / 100)
--		end
	end
	if bit.band(internalFlags, 0x100000) > 0 then
		healing = math.floor(healing * 1.5)
		dicenumber = math.floor(dicenumber * 1.5)
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
			bitList = bit.band(bitList, 0xFFFFFFFF - bit)
		else
			bitList = bit.bor(bitList, bit)
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
	local isImmune = (bit.band(specialFlags, 0x2) ~= 0)
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
			IEex_WriteByte(creatureData + 0x89F, bit.bor(specialFlags, 0x2))
		end
	elseif modifier < 0 then
		immunityCount = immunityCount + modifier
		if immunityCount <= -1 then
			IEex_WriteByte(creatureData + 0x89F, bit.band(specialFlags, 0xFD))
		end
	end
	IEex_WriteWord(creatureData + 0x700, immunityCount)
end
--]]

function MECRITIM(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local specialFlags = IEex_ReadByte(creatureData + 0x89F, 0)
	IEex_WriteByte(creatureData + 0x89F, bit.bor(specialFlags, 0x2))
end

function MECRITRE(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local immunityCount = IEex_ReadSignedWord(creatureData + 0x700, 0x0)
	local permanentImmunity = IEex_ReadByte(creatureData + 0x702, 0x0)
	local specialFlags = IEex_ReadByte(creatureData + 0x89F, 0)
	local isImmune = (bit.band(specialFlags, 0x2) ~= 0)
	if (isImmune and immunityCount == -1) or permanentImmunity == 1 then
		immunityCount = 0
		permanentImmunity = 1
		IEex_WriteByte(creatureData + 0x702, permanentImmunity)
		IEex_WriteByte(creatureData + 0x89F, bit.bor(specialFlags, 0x2))
	else
		immunityCount = -1
		IEex_WriteByte(creatureData + 0x89F, bit.band(specialFlags, 0xFD))
	end
	IEex_WriteWord(creatureData + 0x700, immunityCount)
end

function IEex_ApplyStatScaling(targetID)
	local creatureData = IEex_GetActorShare(targetID)
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theresource = IEex_ReadLString(eData + 0x30, 8)

		if theopcode == 500 and ex_stat_scaling_functions[theresource] ~= nil then
			_G[theresource](eData + 0x4, creatureData, true)
		end

	end)
end

function IEex_ApplyStatSpell(targetID, index, statValue)
	if statValue < 0 then
		statValue = 0
	end
	local statSpellList = ex_stat_spells[index]
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

function MESTATSC(effectData, creatureData, isSpecialCall)
	if not isSpecialCall then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local statValue = 0
	local stat = IEex_ReadWord(effectData + 0x18, 0x0)
	local otherStat = IEex_ReadByte(effectData + 0x1A, 0x0)
	local subtractStat = IEex_ReadByte(effectData + 0x1B, 0x0)
	local index = IEex_ReadWord(effectData + 0x1C, 0x0)
	local matchNonStat = IEex_ReadWord(effectData + 0x1E, 0x0)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local modifiedStat = IEex_ReadDword(effectData + 0x44)
	if bit.band(savingthrow, 0x200000) > 0 then
		local matchRace = IEex_ReadByte(effectData + 0x1E, 0x0)
		local matchSubrace = IEex_ReadByte(effectData + 0x1F, 0x0)
		if matchRace ~= IEex_ReadByte(creatureData + 0x26, 0x0) or (matchSubrace ~= 0 and matchSubrace ~= IEex_GetActorStat(targetID, 93) + 1) then return end
	end
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
	if statValue < 0 then
		statValue = 0
	end
	local statScalingList = ex_stat_scaling[index]
	if statScalingList ~= nil then
		local modificationAmount = 0
		local highest = -1
		for key,value in pairs(statScalingList) do
			if statValue >= key and key > highest then
				modificationAmount = value
				highest = key
			end
		end
		if ex_stat_offset[modifiedStat][2] == 1 then
			local modifiedStatValue = IEex_ReadSignedByte(creatureData + ex_stat_offset[modifiedStat][1], 0x0) + modificationAmount
			IEex_WriteByte(creatureData + ex_stat_offset[modifiedStat][1], modifiedStatValue)
			IEex_WriteByte(creatureData + ex_stat_offset[modifiedStat][1] + 0xE58, modifiedStatValue)
		elseif ex_stat_offset[modifiedStat][2] == 2 then
			local modifiedStatValue = IEex_ReadSignedWord(creatureData + ex_stat_offset[modifiedStat][1], 0x0) + modificationAmount
			IEex_WriteWord(creatureData + ex_stat_offset[modifiedStat][1], modifiedStatValue)
			IEex_WriteWord(creatureData + ex_stat_offset[modifiedStat][1] + 0xE58, modifiedStatValue)
		elseif ex_stat_offset[modifiedStat][2] == 4 then
			local modifiedStatValue = IEex_ReadDword(creatureData + ex_stat_offset[modifiedStat][1]) + modificationAmount
			IEex_WriteDword(creatureData + ex_stat_offset[modifiedStat][1], modifiedStatValue)
			IEex_WriteDword(creatureData + ex_stat_offset[modifiedStat][1] + 0xE58, modifiedStatValue)
		end
	end
end

function MESPLSTC(effectData, creatureData, isSpecialCall)
	if not isSpecialCall then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local statValue = 0
	local stat = IEex_ReadWord(effectData + 0x18, 0x0)
	local otherStat = IEex_ReadByte(effectData + 0x1A, 0x0)
	local subtractStat = IEex_ReadByte(effectData + 0x1B, 0x0)
	local index = IEex_ReadWord(effectData + 0x1C, 0x0)
	local matchNonStat = IEex_ReadWord(effectData + 0x1E, 0x0)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local modifiedStat = IEex_ReadDword(effectData + 0x44)
	if bit.band(savingthrow, 0x200000) > 0 then
		local matchRace = IEex_ReadByte(effectData + 0x1E, 0x0)
		local matchSubrace = IEex_ReadByte(effectData + 0x1F, 0x0)
		if matchRace ~= IEex_ReadByte(creatureData + 0x26, 0x0) or (matchSubrace ~= 0 and matchSubrace ~= IEex_GetActorStat(targetID, 93) + 1) then return end
	end
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
	if statValue < 0 then
		statValue = 0
	end
	local statScalingList = ex_stat_scaling[index]
	if statScalingList ~= nil then
		local modificationAmount = 0
		local highest = -1
		for key,value in pairs(statScalingList) do
			if statValue >= key and key > highest then
				modificationAmount = value
				highest = key
			end
		end
		if ex_stat_offset[modifiedStat][2] == 1 then
			IEex_WriteByte(creatureData + ex_stat_offset[modifiedStat][1], IEex_ReadSignedByte(creatureData + ex_stat_offset[modifiedStat][1], 0x0) + modificationAmount)
		elseif ex_stat_offset[modifiedStat][2] == 2 then
			IEex_WriteWord(creatureData + ex_stat_offset[modifiedStat][1], IEex_ReadSignedWord(creatureData + ex_stat_offset[modifiedStat][1], 0x0) + modificationAmount)
		elseif ex_stat_offset[modifiedStat][2] == 4 then
			IEex_WriteDword(creatureData + ex_stat_offset[modifiedStat][1], IEex_ReadDword(creatureData + ex_stat_offset[modifiedStat][1]) + modificationAmount)
		end
	end
end

function MEHALFTH(effectData, creatureData, isSpecialCall)
	MESTATSC(effectData, creatureData, isSpecialCall)
end

function MESTATSP(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local statValue = 0
	local stat = IEex_ReadWord(effectData + 0x18, 0)
	local otherStat = IEex_ReadByte(effectData + 0x1A, 0)
	local subtractStat = IEex_ReadByte(effectData + 0x1B, 0)
	local index = IEex_ReadWord(effectData + 0x1C, 0)
	local readType = IEex_ReadWord(effectData + 0x1E, 0)
	local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	if readType == 0 then
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
	elseif readType == 1 then
		statValue = IEex_ReadSignedByte(creatureData + stat, 0)
	elseif readType == 2 then
		statValue = IEex_ReadSignedWord(creatureData + stat, 0)
	elseif readType == 4 then
		statValue = IEex_ReadDword(creatureData + stat)
	end
	statValue = statValue + IEex_ReadDword(effectData + 0x44)
	if bit.band(savingthrow, 0x10000) > 0 then
		statValue = statValue + IEex_ReadByte(creatureData + 0x78A, 0) * 3
	end
--	IEex_ApplyStatSpell(targetID, index, statValue)
	if statValue < 0 then
		statValue = 0
	end
	local statSpellList = ex_stat_spells[index]
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
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 0,
["resource"] = spellRES,
["parent_resource"] = spellRES,
["casterlvl"] = IEex_ReadDword(effectData + 0xC4),
["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
["source_target"] = targetID,
["source_id"] = sourceID,
})
		end
	end
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
	baseBonus = baseBonus + IEex_ReadByte(creatureData + 0x789, 0)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["duration"] = duration,
["parameter1"] = baseBonus,
["special"] = 36,
["resource"] = "MEMODSTA",
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["duration"] = duration,
["parameter1"] = baseBonus,
["special"] = 41,
["resource"] = "MEMODSTA",
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
--[[
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
--]]
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
["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
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
	if targetGeneral ~= 4 and (targetRace ~= ex_fiend_race or bit.band(IEex_ReadDword(sourceData + 0x760), 0x2) == 0) then return end
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
--	if IEex_GetActorSpellState(sourceID, 194) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 194 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				turnLevel = turnLevel + theparameter1
			end
		end)
--	end
	local turningFeat = IEex_ReadByte(sourceData + 0x78C, 0)
	turnLevel = turnLevel + turningFeat * 3
	local sourceAlignment = IEex_ReadByte(sourceData + 0x35, 0)
	local sourceKit = IEex_GetActorStat(sourceID, 89)
	local targetLevel = IEex_GetActorStat(targetID, 95)
	if turnLevel >= targetLevel * 2 then
		if bit.band(sourceAlignment, 0x3) == 0x3 or (bit.band(sourceAlignment, 0x3) == 0x2 and (sourceKit == 0x200000 or sourceKit == 0x400000 or sourceKit == 0x800000)) then
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
	if special == 0 and bit.band(targetAlignment, 0x3) ~= 0x3 then
		return
	elseif special == 1 and bit.band(targetAlignment, 0x3) ~= 0x1 then
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
["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
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
	IEex_ApplyStatSpell(targetID, index, statValue)
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
["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
["source_target"] = targetID,
["source_id"] = sourceID,
})
end

function MEPERFEC(effectData, creatureData, isSpecialCall)
	if not isSpecialCall then return end
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
--	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local statValue = IEex_ReadDword(effectData + 0x44)
	statValue = statValue + math.floor((IEex_GetActorStat(targetID, 38) - 10) / 2)
	statValue = statValue + math.floor((IEex_GetActorStat(targetID, 39) - 10) / 2)
	statValue = statValue + math.floor((IEex_GetActorStat(targetID, 40) - 10) / 2)
	statValue = statValue + math.floor((IEex_GetActorStat(targetID, 41) - 10) / 2)
	statValue = statValue + math.floor((IEex_GetActorStat(targetID, 42) - 10) / 2)
--	local index = IEex_ReadWord(effectData + 0x1C, 0)
--	IEex_ApplyStatSpell(targetID, index, statValue)
	IEex_WriteWord(creatureData + 0x9A6, IEex_ReadSignedWord(creatureData + 0x9A6, 0x0) + statValue)
end

function MESTATRO(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local stat = IEex_ReadWord(effectData + 0x44, 0x0)
	local statValue = IEex_GetActorStat(targetID, stat)
	local dc = IEex_ReadWord(effectData + 0x46, 0x0)
	local roll = math.random(20)
	local invert = (bit.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
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
	local stateValue = bit.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
	local invert = (bit.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
	if bit.band(stateValue, state) ~= 0 then
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
	local stateValue = bit.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
	local invert = (bit.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
	if bit.band(stateValue, 0x10) > 0 and bit.band(stateValue, 0x400000) == 0 then
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
	local stateValue = bit.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
	local invert = (bit.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
	if bit.band(stateValue, 0xFC0) > 0 then
		if invert == false then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if bit.band(stateValue, 0xC0) > 0 then
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
["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
["source_id"] = sourceID
})
			end
		end
	else
		if invert == true then
			local spellRES = IEex_ReadLString(effectData + 0x18, 8)
			if bit.band(stateValue, 0xC0) > 0 then
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
["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
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
	local invert = (bit.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
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
	local invert = (bit.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
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
	local invert = (bit.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
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
	local invert = (bit.band(IEex_ReadDword(effectData + 0x3C), 0x100000) > 0)
	if (action ~= IEex_ReadWord(creatureData + 0x476, 0x0) and not invert) or action == IEex_ReadWord(creatureData + 0x476, 0x0) and invert then return end
	local targetID = IEex_ReadDword(creatureData + 0x4BE)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	if casterlvl <= 1 then
		casterlvl = IEex_GetActorStat(sourceID, 95)
	end
	local sourceX = IEex_ReadDword(creatureData + 0x6)
	local sourceY = IEex_ReadDword(creatureData + 0xA)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local range = IEex_ReadWord(effectData + 0x46, 0x0)
	local invertRangeCheck = (bit.band(savingthrow, 0x200000) > 0)
	local checkLineOfSight = (bit.band(savingthrow, 0x400000) > 0)
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
["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
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
["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
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
		if bit.band(parameter2, 0x1) > 0 then
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
		if bit.band(parameter2, 0x2) > 0 then
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
	local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	local barrageCount = IEex_ReadWord(effectData + 0x44, 0x0)
	local projectile = IEex_ReadWord(effectData + 0x46, 0x0)
	if bit.band(savingthrow, 0x10000000) > 0 then
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

function MEBARRAM(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	IEex_WriteDword(effectData + 0x110, 1)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	local targetX = IEex_ReadDword(creatureData + 0x6)
	local targetY = IEex_ReadDword(creatureData + 0xA)
--	local targetX = IEex_ReadDword(effectData + 0x84)
--	local targetY = IEex_ReadDword(effectData + 0x88)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	if spellRES == "" then
		spellRES = parent_resource .. "D"
	end
	local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	local barrageCount = IEex_ReadWord(effectData + 0x44, 0x0)
	local parameter4 = IEex_ReadDword(effectData + 0x60)
	if barrageCount == 0 then
		barrageCount = 1
	end
--	local projectile = IEex_ReadWord(effectData + 0x46, 0x0)
	local currentAngle = 0
	local angleIncrement = 6
	local delta = 100
	local deltaX = 0
	local deltaY = 0
	if bit.band(savingthrow, 0x10000000) > 0 then
		parent_resource = spellRES
	end
	if parameter4 == 0 then
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = math.floor(barrageCount / 10) + 1,
["parameter2"] = 250,
["special"] = barrageCount,
["target_x"] = targetX,
["target_y"] = targetY,
["casterlvl"] = casterlvl,
["resource"] = "MEBARRAA",
["vvcresource"] = spellRES,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	end
	for i = 1, barrageCount, 1 do
		if i > parameter4 then
			deltaX = math.floor(math.cos(currentAngle) * delta)
			deltaY = math.floor(math.sin(currentAngle) * delta)
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 148,
["target"] = 2,
["timing"] = 1,
--["duration"] = IEex_GetGameTick() + i - 1,
["parameter1"] = IEex_ReadByte(effectData + 0xC4, 0x0),
["parameter2"] = 1,
["source_x"] = targetX,
["source_y"] = targetY,
["target_x"] = targetX + deltaX,
["target_y"] = targetY + deltaY,
["casterlvl"] = casterlvl,
["resource"] = spellRES,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
		end
		currentAngle = currentAngle + angleIncrement
	end

end

function MEBARRAA(originatingEffectData, actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	local special = IEex_ReadDword(originatingEffectData + 0x44) * 2
	local parameter4 = IEex_ReadDword(originatingEffectData + 0x60)
	local spellRES = IEex_ReadLString(originatingEffectData + 0x6C, 8)
	local parent_resource = IEex_ReadLString(originatingEffectData + 0x90, 8)
	local targetX = IEex_ReadDword(originatingEffectData + 0x84)
	local targetY = IEex_ReadDword(originatingEffectData + 0x88)
	if spellRES == "" then
		spellRES = parent_resource .. "D"
		IEex_WriteLString(originatingEffectData + 0x6C, spellRES, 8)
	end
	if actionID == 114 and IEex_GetActorSpellRES(sourceID) == spellRES then
		parameter4 = parameter4 + 1
--		IEex_DS(parameter4)
		IEex_WriteDword(originatingEffectData + 0x60, parameter4)
	elseif parameter4 < special then
--		IEex_DS(actionID)
		IEex_SetActionID(actionData, 0)
		local casterlvl = IEex_ReadDword(originatingEffectData + 0xC4)
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = IEex_ReadDword(originatingEffectData + 0x6C),
["parameter2"] = IEex_ReadDword(originatingEffectData + 0x70),
["parameter4"] = parameter4,
["special"] = special,
["casterlvl"] = casterlvl,
["resource"] = "MEBARRAM",
["parent_resource"] = parent_resource,
["target_x"] = targetX,
["target_y"] = targetY,
["source_id"] = sourceID
})
	end
end

IEex_AddActionHookOpcode("MEBARRAA")

function MEGARGOY(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	IEex_WriteDword(effectData + 0x110, 1)
	local targetID = IEex_GetActorIDShare(creatureData)
	local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
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

function MEGLOBEF(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local player1ID = IEex_GetActorIDCharacter(0)
	if not IEex_IsSprite(player1ID, true) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	local timing = IEex_ReadDword(effectData + 0x20)
	local duration = IEex_ReadDword(effectData + 0x24)
	if timing == 4096 then
		timing = 0
		duration = math.floor((duration - IEex_ReadDword(effectData + 0x68)) / 15)
	end
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local special = IEex_ReadDword(effectData + 0x44)
	local casterlvl = IEex_ReadByte(effectData + 0xC4, 0)
	if spellRES == "" then
		for i = 0, 30, 1 do
			if 2 ^ i == special then
				spellRES = "MEGLOB" .. i
			end
		end
	end
	if bit.band(savingthrow, 0x10000) == 0 then
		IEex_ApplyEffectToActor(player1ID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = timing,
["duration"] = duration,
["parameter2"] = 230,
["special"] = special,
["resource"] = IEex_ReadLString(effectData + 0x90, 8),
["parent_resource"] = spellRES,
["casterlvl"] = casterlvl,
["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
["source_target"] = player1ID,
["source_id"] = sourceID,
})
	else
		IEex_IterateActorEffects(player1ID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thespecial = IEex_ReadDword(eData + 0x48)
			local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
			if theopcode == 288 and theparameter2 == 230 and thespecial == special and theparent_resource == spellRES then
				IEex_WriteDword(eData + 0x114, 1)
			end
		end)
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
		local theresource = IEex_ReadLString(eData + 0x30, 8)
		if thetiming ~= 2 and bit.band(thesavingthrow, 0x4000000) == 0 then
			if (theopcode == 44 and ((theparameter2 == 0 and theparameter1 < 0) or (theparameter2 == 1 and theparameter1 < baseStrength) or (theparameter2 == 2 and theparameter1 < 100)))
			or (theopcode == 15 and ((theparameter2 == 0 and theparameter1 < 0) or (theparameter2 == 1 and theparameter1 < baseDexterity) or (theparameter2 == 2 and theparameter1 < 100)))
			or (theopcode == 10 and ((theparameter2 == 0 and theparameter1 < 0) or (theparameter2 == 1 and theparameter1 < baseConstitution) or (theparameter2 == 2 and theparameter1 < 100)))
			or (theopcode == 19 and ((theparameter2 == 0 and theparameter1 < 0) or (theparameter2 == 1 and theparameter1 < baseIntelligence) or (theparameter2 == 2 and theparameter1 < 100)))
			or (theopcode == 49 and ((theparameter2 == 0 and theparameter1 < 0) or (theparameter2 == 1 and theparameter1 < baseWisdom) or (theparameter2 == 2 and theparameter1 < 100)))
			or (theopcode == 6 and ((theparameter2 == 0 and theparameter1 < 0) or (theparameter2 == 1 and theparameter1 < baseCharisma) or (theparameter2 == 2 and theparameter1 < 100)))
			or (theopcode == 78 and ((theparameter2 >= 4 and theparameter2 <= 9) or theparameter2 == 13 or theparameter2 == 14)) or (theopcode == 500 and theresource == "MEMODSTA" and theparameter1 < 0 and theparameter2 >= 36 and theparameter2 <= 42) then
				IEex_WriteDword(eData + 0x24, 4096)
				IEex_WriteDword(eData + 0x28, IEex_GetGameTick())
				IEex_WriteDword(eData + 0x114, 1)
			end
		end
	end)
end

function MEMODDUR(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local condition = IEex_ReadDword(effectData + 0x44)
	if bit.band(savingthrow, 0x200000) > 0 and parameter2 == 0 and parameter1 < 0 then
		local castCounter = IEex_ReadSignedWord(creatureData + 0x54E8, 0x0)
		if castCounter > -1 then
			IEex_WriteWord(creatureData + 0x54E8, castCounter - parameter1)
		end
		local destinationX, destinationY = IEex_GetActorDestination(targetID)
		if destinationX > 0 and destinationY > 0 then
			IEex_JumpActorToPoint(targetID, destinationX, destinationY, true)
		end
	end
	if bit.band(savingthrow, 0x100000) == 0 then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thetiming = IEex_ReadDword(eData + 0x24)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local theresourceflags = IEex_ReadDword(eData + 0x9C)
			local theinternalflags = IEex_ReadDword(eData + 0xCC)
			if thetiming ~= 2 and (bit.band(savingthrow, 0x10000) == 0 or bit.band(theinternalflags, 0x4000) == 0)then
				if condition == 0 or (condition == 1 and (bit.band(theresourceflags, 0x400) > 0 or theopcode == 12)) or (condition == 2 and (bit.band(theresourceflags, 0x400) == 0 and theopcode ~= 12)) then
					IEex_WriteDword(eData + 0xCC, bit.bor(theinternalflags, 0x4000))
					local theduration = IEex_ReadDword(eData + 0x28)
					local thetime_applied = IEex_ReadDword(eData + 0x6C)
					if parameter2 == 0 then
						IEex_WriteDword(eData + 0x28, theduration + parameter1)
					elseif parameter2 == 1 then
						IEex_WriteDword(eData + 0x28, theduration + parameter1)
					elseif parameter2 == 2 then
						IEex_WriteDword(eData + 0x28, thetime_applied + math.floor((theduration - thetime_applied) * parameter1 / 100))
					end
				end
			end
		end)
	else
		if parameter2 == 0 and parameter1 < 0 then
			IEex_IterateProjectiles(-1, function(projectileData)
				if IEex_ProjectileType[IEex_ReadWord(projectileData + 0x6E, 0x0) + 1] == 6 then
					local remainingDuration = IEex_ReadSignedWord(projectileData + 0x4C0, 0x0)
					remainingDuration = remainingDuration + parameter1
					if remainingDuration <= 0 then
						remainingDuration = 1
					end
					IEex_WriteWord(projectileData + 0x4C0, remainingDuration)

				end
				IEex_WriteWord(projectileData + 0x70, 1000)
			end)
		end
		IEex_IterateTemporals(function(temporalData)
			local remainingDuration = IEex_ReadSignedWord(temporalData + 0x9C, 0x0)
			local elapsedDuration = IEex_ReadSignedWord(temporalData + 0x10E, 0x0)
			if parameter2 == 0 then
				local newRemainingDuration = remainingDuration + parameter1
				if newRemainingDuration <= 0 then
					newRemainingDuration = 1
				end
				if parameter1 < 0 then
					elapsedDuration = elapsedDuration + remainingDuration - newRemainingDuration
				end
				IEex_WriteWord(temporalData + 0x9C, newRemainingDuration)
				IEex_WriteWord(temporalData + 0x10E, elapsedDuration)
			end
		end)
	end
end

function MEHIDECR(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	local targetID = IEex_GetActorIDShare(creatureData)
	local special = IEex_ReadDword(effectData + 0x44)
	IEex_WriteByte(creatureData + 0x838, special)
end

ex_monk_animation_conversion = {[0x6000] = 0x6500, [0x6005] = 0x6500, [0x6100] = 0x6500, [0x6105] = 0x6500, [0x6200] = 0x6500, [0x6205] = 0x6500, [0x6300] = 0x6500, [0x6305] = 0x6500, [0x6010] = 0x6510, [0x6015] = 0x6510, [0x6110] = 0x6510, [0x6115] = 0x6510, [0x6210] = 0x6510, [0x6215] = 0x6510, [0x6310] = 0x6510, [0x6315] = 0x6510, }
function MEMONKAN(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	if IEex_IsGamePaused() then
		if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "MEMONKAN", 5) then return end
	else
		if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "MEMONKAN", 2) then return end
	end
	local special = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local baseAnimation = IEex_ReadDword(creatureData + 0x5C4)
	if special == 0 or special == 2 then
		if ex_monk_animation_conversion[baseAnimation] ~= nil and not IEex_GetActorSpellState(targetID, 188) then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = "USMONKAN",
["source_id"] = targetID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 9,
["parameter1"] = baseAnimation,
["parameter2"] = 188,
["savingthrow"] = 0x20000,
["parent_resource"] = "USMONKAN",
["source_id"] = targetID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 53,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_monk_animation_conversion[baseAnimation],
["parameter2"] = 2,
["parent_resource"] = "USMONKAN",
["source_id"] = targetID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 53,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["parameter1"] = ex_monk_animation_conversion[baseAnimation],
["parameter2"] = 0,
["parent_resource"] = "USMONKAN",
["source_id"] = targetID
})
		end
--[[
		if special == 0 then
			if ex_monk_animation_conversion[baseAnimation] ~= nil or baseAnimation == 0x6500 or baseAnimation == 0x6510 then
				if IEex_GetItemSlotRES(targetID, 10) ~= IEex_GetItemSlotRES(targetID, 43) and string.sub(IEex_GetItemSlotRES(targetID, 10), 1, 7) ~= "00MFIST" then
					IEex_ApplyEffectToActor(targetID, {
["opcode"] = 143,
["target"] = 2,
["timing"] = 9,
["parameter1"] = 43,
["resource"] = IEex_GetItemSlotRES(targetID, 10),
["parent_resource"] = "USMONKAN",
["source_id"] = targetID
})

				end
				if IEex_ReadByte(creatureData + 0x4BA4, 0x0) == 10 then
	--				IEex_Eval('SelectWeaponAbility(43,0)',targetID)
					IEex_Eval('EquipMostDamagingMelee()',targetID)
					IEex_WriteByte(creatureData + 0x3448, 43)
					IEex_WriteByte(creatureData + 0x4BA4, 43)
					IEex_WriteByte(creatureData + 0x569E, 43)
				end
			end



		end
--]]
	elseif special == 1 and (baseAnimation == 0x6500 or baseAnimation == 0x6510) then
		local oldAnimation = 0
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if theopcode == 288 and theparameter2 == 188 and bit.band(thesavingthrow, 0x20000) > 0 then
				oldAnimation = IEex_ReadDword(eData + 0x1C)
			end
		end)
		if oldAnimation > 0 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = "USMONKAN",
["source_id"] = targetID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 53,
["target"] = 2,
["timing"] = 1,
["parameter1"] = oldAnimation,
["parameter2"] = 2,
["parent_resource"] = "USMONKAN",
["source_id"] = targetID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 53,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["parameter1"] = oldAnimation,
["parameter2"] = 0,
["parent_resource"] = "USMONKAN",
["source_id"] = targetID
})
		end
	end
end

function MEPOLYMO(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
--	local sourceID = IEex_ReadDword(effectData + 0x10C)
--	if not IEex_IsSprite(sourceID, false) then return end
	local creRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
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
	if bit.band(specialFlags, 0x2) > 0 then
		baseCritImmunity = 1
	end
	local hasCursedWeapon = false
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter1 = IEex_ReadDword(eData + 0x1C)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		local thesavingthrow = IEex_ReadDword(eData + 0x40)
		local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
		if theopcode == 288 and theparameter2 == 241 and thespecial >= 4 and bit.band(thesavingthrow, 0x100000) > 0 then
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
	local oldAnimationDataFound = false
	if IEex_GetActorSpellState(targetID, 188) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if theopcode == 288 and theparameter2 == 188 and bit.band(thesavingthrow, 0x20000) == 0 then
				oldAnimationDataFound = true
				baseAnimation = IEex_ReadDword(eData + 0x1C)
				baseStrength = IEex_ReadByte(eData + 0x44, 0x0)
				baseDexterity = IEex_ReadByte(eData + 0x45, 0x0)
				baseConstitution = IEex_ReadByte(eData + 0x46, 0x0)
				baseIntelligence = IEex_ReadByte(eData + 0x47, 0x0)
				baseWisdom = IEex_ReadByte(eData + 0x48, 0x0)
				baseCharisma = IEex_ReadByte(eData + 0x49, 0x0)
			end
		end)
	end
	if not oldAnimationDataFound then
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
		if bit.band(IEex_ReadByte(formData + 0x303, 0x0), 0x2) > 0 then
			IEex_WriteByte(creatureData + 0x89F, bit.bor(specialFlags, 0x2))
		else
			IEex_WriteByte(creatureData + 0x89F, bit.band(specialFlags, 0xFD))
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
		if bit.band(savingthrow, 0x200000) > 0 then
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
		end
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
--	if IEex_GetActorSpellState(targetID, 188) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if theopcode == 288 and theparameter2 == 188 and bit.band(thesavingthrow, 0x20000) == 0 then
				baseAnimation = IEex_ReadDword(eData + 0x1C)
--				baseStrength = IEex_ReadByte(eData + 0x44, 0x0)
--				baseDexterity = IEex_ReadByte(eData + 0x45, 0x0)
--				baseConstitution = IEex_ReadByte(eData + 0x46, 0x0)
--				baseIntelligence = IEex_ReadByte(eData + 0x47, 0x0)
--				baseWisdom = IEex_ReadByte(eData + 0x48, 0x0)
--				baseCharisma = IEex_ReadByte(eData + 0x49, 0x0)
				if bit.band(thesavingthrow, 0x1000000) > 0 then
					IEex_WriteByte(creatureData + 0x89F, bit.bor(specialFlags, 0x2))
				else
					IEex_WriteByte(creatureData + 0x89F, bit.band(specialFlags, 0xFD))
				end
			end
		end)
--	end
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
ex_moonblade_items = {["00SWDL09"] = true, ["USHFSL09"] = true, }
function MEMOONBL(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local internalFlags = IEex_ReadDword(effectData + 0xC8)
	local weaponRES = IEex_ReadLString(effectData + 0x18, 8)
	local special = IEex_ReadDword(effectData + 0x44)
	local equippedSlot = IEex_ReadByte(creatureData + 0x4BA4, 0x0)
	if ex_moonblade_items[IEex_GetItemSlotRES(targetID, equippedSlot)] ~= nil then
		IEex_WriteDword(creatureData + 0xA00, IEex_ReadDword(creatureData + 0xA00) + special)
		IEex_WriteByte(creatureData + 0x9F8, IEex_ReadSignedByte(creatureData + 0x9F8, 0x0) + special)
	elseif equippedSlot >= 43 and equippedSlot <= 49 and ex_moonblade_items[IEex_GetItemSlotRES(targetID, equippedSlot + 1)] ~= nil then
		IEex_WriteDword(creatureData + 0xA04, IEex_ReadDword(creatureData + 0xA04) + special)
		IEex_WriteByte(creatureData + 0x9FC, IEex_ReadSignedByte(creatureData + 0x9FC, 0x0) + special)
	elseif bit.band(internalFlags, 0x10) == 0 then
		IEex_WriteDword(effectData + 0xC8, bit.bor(internalFlags, 0x10))
		local timing = IEex_ReadDword(effectData + 0x20)
		local duration = IEex_ReadDword(effectData + 0x24)
		local time_applied = IEex_ReadDword(effectData + 0x68)
		if timing == 4096 then
			timing = 0
			duration = math.floor((duration - time_applied) / 15)
		end
		IEex_WriteDword(effectData + 0x110, 1)
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 111,
["target"] = 2,
["timing"] = timing,
["duration"] = duration,
["resource"] = weaponRES,
["parent_resource"] = IEex_ReadLString(effectData + 0x90, 8),
["casterlvl"] = IEex_ReadDword(effectData + 0xC8),
["internal_flags"] = internalFlags,
["source_target"] = targetID,
["source_id"] = sourceID,
})
	end
	IEex_WriteDword(effectData + 0xC8, bit.bor(internalFlags, 0x10))
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
["savingthrow"] = 0x100000,
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
			if thename2 > 0 and thename2 < 999999 and (IEex_ReadWord(itemData + 0x42, 0x0) == 0 or bit.band(IEex_ReadByte(quiverData + 0x20, 0x0), 0x1) > 0) then
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
--	if IEex_GetActorSpellState(targetID, 187) then
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
--	end
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

IEex_AddScreenEffectsGlobal("MEREPLIT", function(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local opcode = IEex_ReadDword(effectData + 0xC)
	if opcode == 143 then
		local parameter1 = IEex_ReadDword(effectData + 0x18)
		local savingthrow = IEex_ReadDword(effectData + 0x3C)
		if ((parameter1 >= 10 and parameter1 <= 17) or (parameter1 >= 43 and parameter1 <= 50)) and bit.band(savingthrow, 0x100000) == 0 then
			local itemRES = IEex_ReadLString(effectData + 0x2C, 8)
			local currentWeaponSet = IEex_ReadByte(creatureData + 0x4C68, 0x0)
			local resWrapper = IEex_DemandRes(itemRES, "ITM")
			local itemName = 0
			local itemIcon = ""
			if resWrapper:isValid() then
				local itemData = resWrapper:getData()
				local requiredLore = IEex_ReadWord(itemData + 0x42, 0x0)
				if requiredLore == 0 then
					itemName = IEex_ReadDword(itemData + 0xC)
				else
					itemName = IEex_ReadDword(itemData + 0x8)
				end
				itemIcon = IEex_ReadLString(itemData + 0x3A, 8)
			end
			resWrapper:free()
			if parameter1 >= 15 and parameter1 <= 17 then
				local quickItemOffset = creatureData + 0x3828 + (parameter1 - 15) * 0x3C
				IEex_WriteDword(quickItemOffset + 0x1C, parameter1)
				IEex_WriteLString(quickItemOffset, itemIcon, 8)
				IEex_WriteDword(quickItemOffset + 0x8, itemName)
				IEex_WriteDword(quickItemOffset + 0x2A, itemName)
				if IEex_GetItemSlotRES(targetID, parameter1) == itemRES then
					IEex_WriteWord(quickItemOffset + 0x18, IEex_ReadSignedWord(quickItemOffset + 0x18, 0x0) + 1)
					local itemSlotData = IEex_ReadDword(creatureData + 0x4AD8 + parameter1 * 0x4)
					local charges1 = IEex_ReadSignedWord(itemSlotData + 0x18, 0x0)
					if charges1 == 0 then
						charges1 = 1
					end
					IEex_WriteWord(quickItemOffset + 0x18, charges1 + 1)
					IEex_WriteWord(itemSlotData + 0x18, charges1 + 1)
					return true
				else
					IEex_WriteWord(quickItemOffset + 0x18, 1)
				end
			else
				for i = 0, 3, 1 do
					local weaponSetOffset = creatureData + 0x342C + i * 0x78
					if IEex_ReadByte(weaponSetOffset + 0x1C, 0x0) == parameter1 or 43 + i * 2 == parameter1 then
						IEex_WriteDword(weaponSetOffset + 0x1C, parameter1)
						IEex_WriteLString(weaponSetOffset, itemIcon, 8)
						IEex_WriteDword(weaponSetOffset + 0x8, itemName)
						IEex_WriteDword(weaponSetOffset + 0x2A, itemName)
					end
				end
			end
		end
	end
end)

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
		local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
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
				if (theparameter1 > 0 or bit.band(thesavingthrow, 0x10000) > 0) and ((thespecial >= classSpellLevel and classSpellLevel > 0) or (theresource == sourceSpell and theresource ~= "")) and (bit.band(savingthrow, 0x40000) == 0 or bit.band(thesavingthrow, 0x40000) > 0) then
					if bit.band(thesavingthrow, 0x80000) == 0 then
						spellBlocked = true
					end
					if bit.band(thesavingthrow, 0x100000) == 0 then
						spellTurned = true
					end
					if bit.band(thesavingthrow, 0x10000) == 0 then
						theparameter1 = theparameter1 - classSpellLevel
						if theparameter1 <= 0 and bit.band(thesavingthrow, 0x20000) == 0 then
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
			if bit.band(savingthrow, 0x10000) > 0 then
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

function MECOUNTE(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	IEex_SetToken("EXCSNAM1", IEex_GetActorName(targetID))
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local actionID = IEex_ReadWord(creatureData + 0x476, 0x0)
	if actionID == 31 or actionID == 95 or actionID == 113 or actionID == 114 or actionID == 191 or actionID == 192 then
		local casterClass = IEex_ReadSignedByte(creatureData + 0x530, 0x0)
		local classSpellLevel = IEex_ReadSignedByte(creatureData + 0x534, 0x0)
		local spellRES = IEex_GetActorSpellRES(targetID)
		if ex_true_spell[spellRES] ~= nil then
			spellRES = ex_true_spell[spellRES]
		end
		if classSpellLevel <= 0 and (ex_listspll[spellRES] ~= nil or ex_listdomn[spellRES] ~= nil) then
			if casterClass <= 0 then
				if IEex_GetActorStat(targetID, 97) > 0 and ex_listspll[spellRES][1] > 0 then
					casterClass = 2
				elseif IEex_GetActorStat(targetID, 98) > 0 and ex_listspll[spellRES][2] > 0 then
					casterClass = 3
				elseif IEex_GetActorStat(targetID, 99) > 0 and ex_listspll[spellRES][3] > 0 then
					casterClass = 4
				elseif IEex_GetActorStat(targetID, 102) > 0 and ex_listspll[spellRES][4] > 0 then
					casterClass = 7
				elseif IEex_GetActorStat(targetID, 103) > 0 and ex_listspll[spellRES][5] > 0 then
					casterClass = 8
				elseif IEex_GetActorStat(targetID, 105) > 0 and ex_listspll[spellRES][6] > 0 then
					casterClass = 10
				elseif IEex_GetActorStat(targetID, 105) > 0 and ex_listspll[spellRES][6] > 0 then
					casterClass = 11
				end
			end
			classSpellLevel = IEex_GetClassSpellLevel(targetID, casterClass, spellRES)
		end
		if classSpellLevel <= 0 then
			local resWrapper = IEex_DemandRes(spellRES, "SPL")
			if resWrapper:isValid() then
				local spellData = resWrapper:getData()
				if IEex_ReadWord(spellData + 0x1C, 0x0) == 1 or IEex_ReadWord(spellData + 0x1C, 0x0) == 2 then
					classSpellLevel = IEex_ReadDword(spellData + 0x34)
				end
			end
			resWrapper:free()
		end
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["parameter1"] = ex_tra_55483,
["source_id"] = sourceID
})
		local spells = IEex_FetchSpellInfo(sourceID, {1, 2, 3, 4, 5, 6, 7, 8})
		local sourceHasSpell = false
		if classSpellLevel > 0 then
			for i = 1, 9, 1 do
				for cType, levelList in pairs(spells) do
					if #levelList >= i then
						local levelI = levelList[i]
						local maxCastable = levelI[1]
						local sorcererCastableCount = levelI[2]
						local levelISpells = levelI[3]
						if #levelISpells > 0 then
							for i2, spell in ipairs(levelISpells) do
								if spellRES == spell["resref"] then
									if cType == 1 or cType == 6 then
										if sorcererCastableCount > 0 then
											sourceHasSpell = true
										end
									else
										if spell["castableCount"] > 0 then
											sourceHasSpell = true
										end
									end
								end
							end
						end
					end
				end
			end
		end
		if sourceHasSpell then
			IEex_WriteWord(creatureData + 0x476, 0)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 138,
["target"] = 2,
["timing"] = 0,
["parameter2"] = 4,
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 233,
["target"] = 2,
["timing"] = 0,
["parameter2"] = 67,
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 174,
["target"] = 2,
["timing"] = 0,
["resource"] = "CASTB",
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = -1,
["parameter2"] = 9,
["special"] = 1,
["savingthrow"] = 0x2FF0000,
["resource"] = "EXMODMEM",
["vvcresource"] = spellRES,
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["parameter1"] = ex_tra_55481,
["source_id"] = sourceID
})
		else
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["parameter1"] = ex_tra_55482,
["source_id"] = sourceID
})
		end
	else
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["parameter1"] = ex_tra_55484,
["source_id"] = sourceID
})
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

function MEKENSE2(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local fighterLevel = IEex_GetActorStat(targetID, 100)
	if fighterLevel < 3 then
		fighterLevel = 3
	end
--	if IEex_GetActorSpellState(targetID, 241) then
		local hasArmor = false
		local hasMeleeWeapon = false
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 241 then
				local thespecialtype = IEex_ReadByte(eData + 0x48, 0x0)
				if (thespecialtype == 1 and (theparameter1 ~= 67 or not ex_elven_chainmail_counts_as_unarmored)) or thespecialtype == 3 then
					hasArmor = true
				elseif thespecialtype == 5 then
					hasMeleeWeapon = true
				end
			end
		end)
		if hasArmor == false and hasMeleeWeapon == true then
			IEex_WriteWord(creatureData + 0x92C, IEex_ReadSignedWord(creatureData + 0x92C, 0x0) + 2)
			IEex_WriteWord(creatureData + 0x938, IEex_ReadSignedWord(creatureData + 0x938, 0x0) + math.floor(fighterLevel / 3))
			IEex_WriteWord(creatureData + 0x9A6, IEex_ReadSignedWord(creatureData + 0x9A6, 0x0) + math.floor(fighterLevel / 3))
		end
--	end
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
--[[
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
--]]
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

function MEARMMA2(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
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
				IEex_WriteByte(creatureData + 0xA6A, IEex_ReadSignedByte(creatureData + 0xA6A, 0x0) + armorCheckPenalty + dexterityAdjust)
				IEex_WriteByte(creatureData + 0xA6D, IEex_ReadSignedByte(creatureData + 0xA6D, 0x0) + armorCheckPenalty + dexterityAdjust)
				IEex_WriteByte(creatureData + 0xA6F, IEex_ReadSignedByte(creatureData + 0xA6F, 0x0) + armorCheckPenalty + dexterityAdjust)
			end
			if dexterityAdjust > 0 then
				IEex_WriteWord(creatureData + 0x92C, IEex_ReadSignedWord(creatureData + 0x92C, 0x0) + dexterityAdjust)
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
	if true then return end
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
	if math.random(100) <= 20 then
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
		if weaponCount >= 2 and (IEex_GetActorStat(sourceID, 103) < 9 or wearingLightArmor or (IEex_ReadByte(sourceData + 0x5EC, 0x0) >= 16 and bit.band(IEex_ReadDword(sourceData + 0x75C), 0x2) > 0 and bit.band(IEex_ReadDword(sourceData + 0x764), 0x40) > 0)) then
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 442,
["target"] = 2,
["timing"] = 0,
["parent_resource"] = "USIMPTWX",
["source_id"] = sourceID
})
		end
	end
end
--[[
function MEIMPTW2(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local weaponCount = 0
	local wearingLightArmor = true
	if math.random(100) <= 20 then
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
		if weaponCount >= 2 and (IEex_GetActorStat(sourceID, 103) < 9 or wearingLightArmor or (IEex_ReadByte(sourceData + 0x5EC, 0x0) >= 16 and bit.band(IEex_ReadDword(sourceData + 0x75C), 0x2) > 0 and bit.band(IEex_ReadDword(sourceData + 0x764), 0x40) > 0)) then
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 442,
["target"] = 2,
["timing"] = 0,
["parent_resource"] = "USIMPTWX",
["source_id"] = sourceID
})
		end
	end
end
--]]
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

function MESHLDF2(effectData, creatureData)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local shieldRES = ""
	local shieldBonus = 0
	if IEex_GetActorSpellState(targetID, 241) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
			if theopcode == 288 and theparameter2 == 241 then
				if thespecial == 3 then
					shieldRES = IEex_ReadLString(eData + 0x94, 8)
				end
			end
		end)
	end
	if shieldRES ~= "" then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
			local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
			if theopcode == 0 and theparameter2 == 3 and theparent_resource == shieldRES then
				shieldBonus = theparameter1
			end
		end)
		shieldBonus = shieldBonus + IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SHIELD_FOCUS"], 0x0) * parameter1
		if shieldBonus > IEex_ReadSignedWord(creatureData + 0x92A, 0x0) then
			IEex_WriteWord(creatureData + 0x92A, shieldBonus)
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
	if weaponCount >= 2 and (IEex_GetActorStat(targetID, 103) == 0 or wearingLightArmor or bit.band(IEex_ReadDword(creatureData + 0x764), 0x40) > 0) then
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

function METWDEF2(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local weaponCount = 0
	local wearingLightArmor = true
--	if IEex_GetActorSpellState(targetID, 241) then
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
--	end
	if weaponCount >= 2 and (IEex_GetActorStat(targetID, 103) == 0 or wearingLightArmor or bit.band(IEex_ReadDword(creatureData + 0x764), 0x40) > 0) then
		local twoWeaponDefenseBonus = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_TWO_WEAPON_DEFENSE"], 0x0) * parameter1
		IEex_WriteWord(creatureData + 0x92A, IEex_ReadSignedWord(creatureData + 0x92A, 0x0) + twoWeaponDefenseBonus)
	end
end

extra_hands = {[32558] = 4, [60365] = 6, [60697] = 4,}
ex_whirla_index = 1
ex_difficulty_attack_bonus = {-4, -2, 0, 3, 9, 9}
function MEWHIRLA(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID) or IEex_CompareActorAllegiances(sourceID, targetID) > -1 then return end
	local sourceData = IEex_GetActorShare(sourceID)
--	IEex_DS(IEex_ReadSignedByte(sourceData + 0x5636, 0x0))
	local sourceX = IEex_ReadDword(sourceData + 0x6)
	local sourceY = IEex_ReadDword(sourceData + 0xA)
	local targetX = IEex_ReadDword(creatureData + 0x6)
	local targetY = IEex_ReadDword(creatureData + 0xA)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local weaponRES = {"", ""}
	local weaponHand = {1, 2}
	local wearingLightArmor = true
	local equippedSlot = IEex_ReadByte(sourceData + 0x4BA4, 0x0)
	local currentAttack = IEex_ReadSignedByte(sourceData + 0x5636, 0x0)
	if bit.band(savingthrow, 0x10000) > 0 then
		weaponRES[1] = IEex_GetItemSlotRES(sourceID, equippedSlot)
	end
	if bit.band(savingthrow, 0x20000) > 0 then
		if equippedSlot == 43 or equippedSlot == 45 or equippedSlot == 47 or equippedSlot == 49 then
			weaponRES[2] = IEex_GetItemSlotRES(sourceID, equippedSlot + 1)
		elseif IEex_GetActorStat(sourceID, 101) > 0 and (equippedSlot == 10 or IEex_GetItemSlotRES(sourceID, 10) == IEex_GetItemSlotRES(sourceID, 43)) then
			weaponRES[2] = IEex_GetItemSlotRES(sourceID, 10)
		end
	end

	local numWeapons = 0
	if ex_record_attacks_made[sourceID] == nil then
		ex_record_attacks_made[sourceID] = {0, 0, 0, 0}
	end
	local extraAttacksMade = ex_record_attacks_made[sourceID][2]
	local extraMainhandAttacksMade = ex_record_attacks_made[sourceID][3]
	local currentAttackPenalty = 0
	IEex_IterateActorEffects(sourceID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter1 = IEex_ReadDword(eData + 0x1C)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		local theresource = IEex_ReadLString(eData + 0x30, 8)
		local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
		if theopcode == 288 and theparameter2 == 241 then

			if thespecial == 5 or thespecial == 6 then
				numWeapons = numWeapons + 1
--[[
				if weaponRES[1] == "" then
					weaponRES[1] = IEex_ReadLString(eData + 0x94, 8)
				else
					weaponRES[2] = IEex_ReadLString(eData + 0x94, 8)
				end
--]]
			end

			if (theparameter1 >= 62 and theparameter1 <= 66) or theparameter1 == 68 then
				wearingLightArmor = false
			end
		end
	end)
--	IEex_DS(currentAttack .. ", " .. extraMainhandAttacksMade .. ", " .. extraAttacksMade)
	if bit.band(savingthrow, 0x30000) == 0 then
		weaponRES[1] = IEex_ReadLString(effectData + 0x18, 8)
		local attackPenaltyIncrement = 5
		if IEex_GetActorStat(sourceID, 101) > 0 and equippedSlot == 10 then
			attackPenaltyIncrement = 3
		end
		if weaponRES[1] == "" then
			if numWeapons >= 2 and currentAttack == IEex_GetActorStat(sourceID, 8) then
--				currentAttackPenalty = extraAttacksMade * attackPenaltyIncrement
				if equippedSlot == 43 or equippedSlot == 45 or equippedSlot == 47 or equippedSlot == 49 then
					weaponRES[2] = IEex_GetItemSlotRES(sourceID, equippedSlot + 1)
				elseif IEex_GetActorStat(sourceID, 101) > 0 and (equippedSlot == 10 or IEex_GetItemSlotRES(sourceID, 10) == IEex_GetItemSlotRES(sourceID, 43)) then
					weaponRES[2] = IEex_GetItemSlotRES(sourceID, 10)
				end
			elseif currentAttack >= 1 then
				currentAttackPenalty = (currentAttack - 1) * attackPenaltyIncrement
				if numWeapons >= 2 and currentAttack == IEex_GetActorStat(sourceID, 8) - 1 then
--					currentAttackPenalty = currentAttackPenalty + extraMainhandAttacksMade * attackPenaltyIncrement
				elseif numWeapons < 2 then
--					currentAttackPenalty = currentAttackPenalty + extraAttacksMade * attackPenaltyIncrement
				end
				weaponRES[1] = IEex_GetItemSlotRES(sourceID, equippedSlot)
			else
				weaponRES[1] = parent_resource
			end
		end
	end
	local dualWielding = false
	local dualWieldingPenalty = {0, 0}
--	if weaponRES[1] ~= "" and weaponRES[2] ~= "" then
	if numWeapons >= 2 then
		dualWielding = true
		dualWieldingPenalty = {6, 10}
		local resWrapper = IEex_DemandRes(weaponRES[2], "ITM")
		if resWrapper:isValid() then
			local itemData = resWrapper:getData()
			local itemType = IEex_ReadWord(itemData + 0x1C, 0x0)
			if itemType == 16 or itemType == 19 then
				dualWieldingPenalty[1] = dualWieldingPenalty[1] - 2
				dualWieldingPenalty[2] = dualWieldingPenalty[2] - 2
			end
		end
		resWrapper:free()
		if IEex_GetActorStat(sourceID, 103) > 0 and wearingLightArmor then
			dualWieldingPenalty[1] = dualWieldingPenalty[1] - 2
			dualWieldingPenalty[2] = dualWieldingPenalty[2] - 6
		else
			if bit.band(IEex_ReadDword(sourceData + 0x75C), 0x2) > 0 then
				dualWieldingPenalty[1] = dualWieldingPenalty[1] - 2
				dualWieldingPenalty[2] = dualWieldingPenalty[2] - 2
			end
			if bit.band(IEex_ReadDword(sourceData + 0x764), 0x40) > 0 then
				dualWieldingPenalty[2] = dualWieldingPenalty[2] - 4
			end
		end
	end
	local spriteHands = 2
	local animation = IEex_ReadDword(sourceData + 0x5C4)
	if extra_hands[animation] ~= nil then
		spriteHands = extra_hands[animation]
	end
	if spriteHands == 4 then
		if weaponRES[2] == "" then
			weaponRES = {weaponRES[1], weaponRES[1], weaponRES[1], weaponRES[1]}
			weaponHand = {1, 1, 1, 1}
		else
			weaponRES = {weaponRES[1], weaponRES[1], weaponRES[2], weaponRES[2]}
			weaponHand = {1, 1, 2, 2}
		end
	elseif spriteHands == 6 then
		if weaponRES[2] == "" then
			weaponRES = {weaponRES[1], weaponRES[1], weaponRES[1], weaponRES[1], weaponRES[1], weaponRES[1]}
			weaponHand = {1, 1, 1, 1, 1, 1}
		else
			weaponRES = {weaponRES[1], weaponRES[1], weaponRES[1], weaponRES[2], weaponRES[2], weaponRES[2]}
			weaponHand = {1, 1, 1, 2, 2, 2}
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
			local isTwoHanded = (bit.band(IEex_ReadDword(itemData + 0x18), 0x2) > 0)
			local itemType = IEex_ReadWord(itemData + 0x1C, 0x0)
			if ex_item_type_proficiency[itemType] ~= nil then
				proficiencyFeat = ex_item_type_proficiency[itemType]
			end
			local criticalHitBonus = 0
			local baseCriticalMultiplier = 2
			if ex_item_type_critical[itemType] ~= nil then
				criticalHitBonus = ex_item_type_critical[itemType][1]
				baseCriticalMultiplier = ex_item_type_critical[itemType][2]
			end
			local effectOffset = IEex_ReadDword(itemData + 0x6A)
			local numHeaders = IEex_ReadWord(itemData + 0x68, 0x0)
			for header = 1, numHeaders, 1 do
				local offset = itemData + 0x4A + header * 0x38
				local headerFlags = IEex_ReadDword(offset + 0x26)
				local itemRange = 20 * IEex_ReadWord(offset + 0xE, 0x0) + 40
				local whirlwindAttackFeatID = ex_feat_name_id["ME_WHIRLWIND_ATTACK"]
				if bit.band(savingthrow, 0x2000000) > 0 and whirlwindAttackFeatID ~= nil and IEex_ReadByte(sourceData + 0x744 + whirlwindAttackFeatID, 0x0) >= 2 then
					itemRange = itemRange + 60
				end
				local itemDamageType = IEex_ReadWord(offset + 0x1C, 0x0)
				if IEex_ReadByte(offset, 0x0) == 1 and (IEex_GetDistance(sourceX, sourceY, targetX, targetY) <= itemRange or bit.band(savingthrow, 0x1000000) == 0) then
					local attackRoll = math.random(20) + IEex_GetActorStat(sourceID, 32)
					if attackRoll > 20 then
						attackRoll = 20
					elseif attackRoll < 1 then
						attackRoll = 1
					end
					local hit = 0
					local stateValue = bit.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
					local sourceStateValue = bit.bor(IEex_ReadDword(sourceData + 0x5BC), IEex_ReadDword(sourceData + 0x920))
					local concealment = 0
					if bit.band(stateValue, 0x20000000) > 0 then
						concealment = 20
					end
					if (bit.band(stateValue, 0x10) > 0 and IEex_GetActorStat(sourceID, 81) == 0) or bit.band(sourceStateValue, 0x40000) > 0 then
						concealment = 50
					end
					if bit.band(stateValue, 0xE9) > 0 or IEex_ReadSignedWord(offset + 0x14, 0x0) == 32767 then
						hit = 5
					elseif IEex_GetActorSpellState(sourceID, 59) and math.random(100) <= 20 then
						IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["parameter1"] = 18352,
["source_id"] = sourceID
})
					elseif IEex_GetActorSpellState(targetID, 59) and math.random(100) <= 50 then
						IEex_ApplyEffectToActor(targetID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["parameter1"] = 18353,
["source_id"] = targetID
})
					else
						local concealed = false
						if math.random(100) <= concealment then
							concealed = true
						end
						if concealment > 0 and bit.band(IEex_ReadDword(sourceData + 0x75C), 0x40) > 0 then
							if not concealed or math.random(100) > concealment then
								IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["parameter1"] = ex_tra_55390,
["source_id"] = sourceID
})
								concealed = false
							else
								IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["parameter1"] = ex_tra_55391,
["source_id"] = sourceID
})
							end
						end
						if concealed then
							IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["parameter1"] = ex_tra_55392,
["source_id"] = sourceID
})
						else
							local attackBonus = IEex_GetActorBaseAttackBonus(sourceID) + IEex_GetActorStat(sourceID, 7) + IEex_ReadSignedWord(offset + 0x14, 0x0) + IEex_ReadDword(effectData + 0x44) - currentAttackPenalty
							if proficiencyFeat > 0 then
								attackBonus = attackBonus + ex_proficiency_attack[IEex_ReadByte(sourceData + ex_feat_id_offset[proficiencyFeat], 0x0)]
							end
							if IEex_ReadByte(sourceData + 0x24, 0x0) >= 200 then
								attackBonus = attackBonus + ex_difficulty_attack_bonus[IEex_GetGameDifficulty()]
							end
							if IEex_GetActorStat(sourceID, 103) > 0 then
								local favoredEnemyBonus = 0
								local enemyRace = IEex_ReadByte(creatureData + 0x26, 0x0)
								for i = 7, 0, -1 do
									local favoredEnemy = IEex_ReadByte(sourceData + 0x7F7 + i, 0x0)
									if favoredEnemy ~= 255 then
										favoredEnemyBonus = favoredEnemyBonus + 1
									end
									if favoredEnemy == enemyRace then
										attackBonus = attackBonus + favoredEnemyBonus
									end
								end
							end
							if weaponHand[hand] == 1 then
								attackBonus = attackBonus - dualWieldingPenalty[1] + IEex_ReadSignedByte(sourceData + 0x9F8, 0x0)
							else
								attackBonus = attackBonus - dualWieldingPenalty[2] + IEex_ReadSignedByte(sourceData + 0x9FC, 0x0)
							end
							if bit.band(headerFlags, 0x20000) > 0 then
								criticalHitBonus = criticalHitBonus + 1
							end
							if bit.band(IEex_ReadDword(sourceData + 0x75C), 0x40000000) > 0 then
								criticalHitBonus = criticalHitBonus + 1
							end
--							if IEex_GetActorSpellState(sourceID, 56) then
								criticalHitBonus = criticalHitBonus + IEex_ReadSignedByte(sourceData + 0x936, 0x0)
--							end
							local attackStatBonus = 0
							if bit.band(headerFlags, 0x1) > 0 then
								attackStatBonus = math.floor((IEex_GetActorStat(sourceID, 36) - 10) / 2)
							end
							if (itemType == 16 or itemType == 19) and bit.band(IEex_ReadDword(sourceData + 0x764), 0x80) > 0 then
								local dexterityBonus = math.floor((IEex_GetActorStat(sourceID, 40) - 10) / 2)
								if dexterityBonus > attackStatBonus then
									attackStatBonus = dexterityBonus
								end
							end
							attackBonus = attackBonus + attackStatBonus
							for i = 1, 5, 1 do
								if IEex_GetActorSpellState(sourceID, i + 75) or IEex_GetActorSpellState(sourceID, i + 80) then
									attackBonus = attackBonus - i
								end
							end
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
							if attackRoll == 1 then
								hit = 4
							elseif attackRoll == 20 or attackRoll + attackBonus >= ac then
								hit = 1
							else
								hit = 2
							end
							if weaponHand[hand] == 2 then
								if bit.band(savingthrow, 0x30000) == 0 then
									IEex_SetToken("EXWHACTION" .. ex_whirla_index, IEex_FetchString(14643) .. "1 (" .. IEex_FetchString(733) .. ")")
								else
									IEex_SetToken("EXWHACTION" .. ex_whirla_index, IEex_FetchString(14643) .. "(" .. IEex_FetchString(733) .. ")")
								end
							else
								if bit.band(savingthrow, 0x30000) == 0 then
									IEex_SetToken("EXWHACTION" .. ex_whirla_index, IEex_FetchString(14643) .. currentAttack .. " ")
								else
									IEex_SetToken("EXWHACTION" .. ex_whirla_index, IEex_FetchString(14643))
								end
							end
							IEex_SetToken("EXWHROLL" .. ex_whirla_index, attackRoll)
							if attackBonus >= 0 then
								IEex_SetToken("EXWHBONUS" .. ex_whirla_index, "+ " .. attackBonus)
							else
								IEex_SetToken("EXWHBONUS" .. ex_whirla_index, "- " .. math.abs(attackBonus))
							end
							IEex_SetToken("EXWHTOTAL" .. ex_whirla_index, attackRoll + attackBonus)
							IEex_SetToken("EXWHHITMISS" .. ex_whirla_index, IEex_FetchString(16459 + hit))
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
							if attackRoll >= 20 - criticalHitBonus and bit.band(IEex_ReadByte(creatureData + 0x89F, 0x0), 0x2) == 0 then
								local threatRoll = math.random(20) + IEex_GetActorStat(sourceID, 32)
								if threatRoll > 20 then
									threatRoll = 20
								elseif threatRoll < 1 then
									threatRoll = 1
								end
								if threatRoll == 20 or (threatRoll >= 2 and threatRoll + attackBonus >= ac) then
									hit = 3
								end
								if weaponHand[hand] == 2 then
									if bit.band(savingthrow, 0x30000) == 0 then
										IEex_SetToken("EXWHACTION" .. ex_whirla_index, IEex_FetchString(39874) .. " 1 (" .. IEex_FetchString(733) .. ")")
									else
										IEex_SetToken("EXWHACTION" .. ex_whirla_index, IEex_FetchString(39874) .. " (" .. IEex_FetchString(733) .. ")")
									end
								else
									if bit.band(savingthrow, 0x30000) == 0 then
										IEex_SetToken("EXWHACTION" .. ex_whirla_index, IEex_FetchString(39874) .. " " .. currentAttack .. " ")
									else
										IEex_SetToken("EXWHACTION" .. ex_whirla_index, IEex_FetchString(39874) .. " ")
									end
								end
								IEex_SetToken("EXWHROLL" .. ex_whirla_index, threatRoll)
								if attackBonus >= 0 then
									IEex_SetToken("EXWHBONUS" .. ex_whirla_index, "+ " .. attackBonus)
								else
									IEex_SetToken("EXWHBONUS" .. ex_whirla_index, "- " .. math.abs(attackBonus))
								end
								IEex_SetToken("EXWHTOTAL" .. ex_whirla_index, threatRoll + attackBonus)
								if hit == 3 then
									IEex_SetToken("EXWHHITMISS" .. ex_whirla_index, IEex_FetchString(16462))
								else
									IEex_SetToken("EXWHHITMISS" .. ex_whirla_index, IEex_FetchString(33752))
								end
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
							end
						end
					end

					if hit == 1 or hit == 3 or hit == 5 then
						if itemDamageType > 0 then
							local newparameter2 = 0
							if itemDamageType == 1 or itemDamageType == 4 then
								newparameter2 = 0x100000
							elseif itemDamageType == 3 or itemDamageType == 7 or itemDamageType == 8 then
								newparameter2 = 0x1000000
							elseif itemDamageType == 5 then
								newparameter2 = 0x8000000
							end
							local newparameter4 = 0
							if hit == 3 then
--[[
								local criticalMultiplier = baseCriticalMultiplier
								local effectOffset = IEex_ReadDword(itemData + 0x6A)
								local numGlobalEffects = IEex_ReadWord(itemData + 0x70, 0x0)
								for i = 0, numGlobalEffects - 1, 1 do
									local offset = itemData + effectOffset + i * 0x30
									local theopcode = IEex_ReadWord(offset, 0x0)
									local theparameter2 = IEex_ReadDword(offset + 0x8)
									local thesavingthrow = IEex_ReadDword(offset + 0x24)
									if theopcode == 288 and theparameter2 == 195 and bit.band(thesavingthrow, 0x10000) > 0 then
										local theparameter1 = IEex_ReadDword(offset + 0x4)
										criticalMultiplier = criticalMultiplier + theparameter1
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
--]]
								newparameter4 = baseCriticalMultiplier
							end
							local bonusStat = 0
							local bonusStatMultiplier = 0
							local bonusStatDivisor = 0
							local weaponEnchantment = IEex_ReadDword(itemData + 0x60)
							if bit.band(headerFlags, 0x1) > 0 then
								bonusStat = 36
								if bit.band(IEex_ReadDword(itemData + 0x18), 0x2) > 0 then
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
["parameter4"] = newparameter4,
["parameter5"] = hand,
["savingthrow"] = effectFlags,
["special"] = bonusStat + (bonusStatMultiplier * 0x100) + (bonusStatDivisor * 0x10000) + (weaponEnchantment * 0x1000000),
["resource"] = "EXDAMAGE",
["source_id"] = sourceID
})
						end
						local probabilityRoll = math.random(100) - 1
						local firstEffectIndex = IEex_ReadWord(offset + 0x20, 0x0)
						local headerNumEffects = IEex_ReadWord(offset + 0x1E, 0x0)
						local extraAttackChance = 0
						local improvedTwoWeaponFightingFeatID = ex_feat_name_id["ME_IMPROVED_TWO_WEAPON_FIGHTING"]
						if dualWielding and improvedTwoWeaponFightingFeatID ~= nil and IEex_ReadByte(sourceData + 0x744 + improvedTwoWeaponFightingFeatID, 0x0) > 0 then
							extraAttackChance = 20
						end
						for headerEffect = 1, headerNumEffects, 1 do
							local headerEffectOffset = itemData + effectOffset + 0x30 * firstEffectIndex + 0x30 * (headerEffect - 1)
							local effopcode = IEex_ReadWord(headerEffectOffset, 0x0)
							local effprobability1 = IEex_ReadByte(headerEffectOffset + 0x12, 0x0)
							local effprobability2 = IEex_ReadByte(headerEffectOffset + 0x13, 0x0)
							local effsavingthrow = IEex_ReadDword(headerEffectOffset + 0x24)
							if effopcode == 442 then
								extraAttackChance = extraAttackChance + effprobability1 - effprobability2 + 1
							elseif probabilityRoll <= effprobability1 and probabilityRoll >= effprobability2 and bit.band(effsavingthrow, 0x40) == 0 then
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
									effsavingthrow = bit.bor(effsavingthrow, 0x10000)
									if bit.band(effsavingthrow, 0x4) > 0 then
										effsavingthrow = bit.bor(effsavingthrow, 0x400)
									end
									if bit.band(effsavingthrow, 0x8) > 0 then
										effsavingthrow = bit.bor(effsavingthrow, 0x800)
									end
									if bit.band(effsavingthrow, 0x10) > 0 then
										effsavingthrow = bit.bor(effsavingthrow, 0x1000)
									end
									effsavingthrow = bit.band(effsavingthrow, 0xFFFFFFE3)
									if effopcode == 500 and weaponRES[1] == weaponRES[2] then
										effsavingthrow = bit.bor(effsavingthrow, 0x4000)
									end
									effspecial = 0
								end
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
	["source_y"] = sourceY,
	["target_x"] = targetX,
	["target_y"] = targetY,
	["parent_resource"] = res,
	["internal_flags"] = 0x41,
	["source_id"] = sourceID
	})
							end
						end
						if hand <= spriteHands and math.random(100) <= extraAttackChance and bit.band(savingthrow, 0x40000000) == 0 then
							numAttacks = numAttacks + 1
							table.insert(weaponRES, res)
							table.insert(weaponHand, weaponHand[hand])
							IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["parameter1"] = 39846,
["source_id"] = sourceID
})
--[[
							local newsavingthrow = bit.bor(savingthrow, 0x40000000)
							if weaponHand[hand] == 1 then
								newsavingthrow = bit.band(savingthrow, 0xFFFDFFFF)
							else
								newsavingthrow = bit.band(savingthrow, 0xFFFEFFFF)
							end
							IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["savingthrow"] = newsavingthrow,
["resource"] = "MEWHIRLA",
["source_id"] = sourceID
})
--]]
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

function MESPIN(effectData, creatureData, isSpecialCall)
	if not isSpecialCall then return end
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
--	if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "MESPIN", 5) then return end
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local special = IEex_ReadDword(effectData + 0x44)
	local doSpin = false
	if bit.band(savingthrow, 0x80000) > 0 then
		IEex_WriteWord(creatureData + 0x476, 0)
	end
	if bit.band(savingthrow, 0x20000) > 0 then
		doSpin = false
		local animationSequence = IEex_ReadByte(creatureData + 0x50F4, 0x0)
		if bit.band(savingthrow, 0x20000) == 0 or animationSequence == special or (special == 0 and animationSequence >= 11 and animationSequence <= 13) then
			if bit.band(savingthrow, 0x2000000) > 0 then
				local itemRange = 40
				local numEnemiesInRange = 0
				local weaponRES = IEex_GetItemSlotRES(targetID, IEex_ReadByte(creatureData + 0x4BA4, 0x0))
				local weaponHeader = IEex_ReadByte(creatureData + 0x4BA4, 0x0)
				local resWrapper = IEex_DemandRes(weaponRES, "ITM")
				if resWrapper:isValid() then
					local itemData = resWrapper:getData()
					local offset = itemData + 0x82 + weaponHeader * 0x38
					itemRange = itemRange + 20 * IEex_ReadWord(offset + 0xE, 0x0)
					local whirlwindAttackFeatID = ex_feat_name_id["ME_WHIRLWIND_ATTACK"]
					if whirlwindAttackFeatID ~= nil and IEex_ReadByte(creatureData + 0x744 + whirlwindAttackFeatID, 0x0) >= 2 then
						itemRange = itemRange + 60
					end
				end
				resWrapper:free()
				local targetX, targetY = IEex_GetActorLocation(targetID)
				local ids = {}
				if IEex_ReadDword(creatureData + 0x12) > 0 then
					ids = IEex_GetIDArea(targetID, 0x31, true, true)
				end
				local closestDistance = 0x7FFFFFFF
				local possibleTargets = {}
				for k, currentID in ipairs(ids) do
					local currentShare = IEex_GetActorShare(currentID)
					if currentShare > 0 then
						local currentX = IEex_ReadDword(currentShare + 0x6)
						local currentY = IEex_ReadDword(currentShare + 0xA)
						local currentDistance = IEex_GetDistance(targetX, targetY, currentX, currentY)
						local states = IEex_ReadDword(currentShare + 0x5BC)
						local animation = IEex_ReadDword(currentShare + 0x5C4)
						local cea = IEex_CompareActorAllegiances(targetID, currentID)
						if currentDistance <= itemRange and cea == -1 and IEex_CheckActorLOSObject(targetID, currentID) and animation >= 0x1000 and (animation < 0xD000 or animation >= 0xE000) and bit.band(states, 0x800) == 0 and IEex_ReadByte(currentShare + 0x838, 0x0) == 0 then
							numEnemiesInRange = numEnemiesInRange + 1
						end
					end
				end
				if numEnemiesInRange >= 2 then
					doSpin = true
				end
			else
				doSpin = true
			end
		end
	end
	if not doSpin then return end
	local rotationAmount = IEex_ReadSignedWord(effectData + 0x18, 0x0)

	if rotationAmount == 0 then
		rotationAmount = 1
	end
	local newRotationDirection = IEex_ReadSignedWord(effectData + 0x1C, 0x0)
	if newRotationDirection ~= 1 then
		newRotationDirection = -1
	end
	local currentDirection = IEex_ReadByte(creatureData + 0x5380, 0x0)
	IEex_WriteWord(creatureData + 0x537C, newRotationDirection)
	IEex_WriteByte(creatureData + 0x537E, (currentDirection + rotationAmount * newRotationDirection) % 16)
end

function MESPELL(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	if spellRES ~= "" then
		local newTiming = 0
		local newDuration = 0
		if bit.band(savingthrow, 0x4000000) > 0 then
			newTiming = 6
			newDuration = IEex_GetGameTick() + IEex_ReadDword(effectData + 0x44)
		end
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = newTiming,
["duration"] = newDuration,
["resource"] = spellRES,
["parent_resource"] = spellRES,
["casterlvl"] = IEex_ReadDword(effectData + 0xC4),
["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
["target_x"] = IEex_ReadDword(effectData + 0x84),
["target_y"] = IEex_ReadDword(effectData + 0x88),
["source_target"] = targetID,
["source_id"] = IEex_ReadDword(effectData + 0x10C),
})
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
	local onHitEffectList = {}
--	if IEex_GetActorSpellState(sourceID, 225) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if theopcode == 288 and theparameter2 == 225 and bit.band(thesavingthrow, 0x100000) == 0 and bit.band(thesavingthrow, 0x800000) == 0 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local matchHeader = IEex_ReadWord(eData + 0x48, 0x0)
				local spellRES = IEex_ReadLString(eData + 0x30, 8)
				if theparameter1 == index and spellRES ~= "" and (matchHeader == 0 or matchHeader == headerType) and (bit.band(thesavingthrow, 0x4000000) == 0 or bit.band(IEex_ReadDword(effectData + 0xC8), 0x40) == 0) then
					local thecasterlvl = IEex_ReadDword(eData + 0xC8)
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
					table.insert(onHitEffectList, {spellRES, thecasterlvl, newEffectTarget, newEffectSource, newEffectTargetX, newEffectTargetY, newEffectSourceX, newEffectSourceY})
				end
			end
		end)
--	end
	for k, v in ipairs(onHitEffectList) do
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
	local onBeingHitEffectList = {}
--	if IEex_GetActorSpellState(targetID, 225) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if theopcode == 288 and theparameter2 == 225 and bit.band(thesavingthrow, 0x100000) > 0 and bit.band(thesavingthrow, 0x800000) == 0 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local matchHeader = IEex_ReadWord(eData + 0x48, 0x0)
				local spellRES = IEex_ReadLString(eData + 0x30, 8)
				if theparameter1 == index and spellRES ~= "" and (matchHeader == 0 or matchHeader == headerType) then
					local thecasterlvl = IEex_ReadDword(eData + 0xC8)
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
						table.insert(targetExpired, theparent_resource)
					elseif usesLeft > 0 then
						usesLeft = usesLeft - 1
						IEex_WriteWord(eData + 0x4A, usesLeft)
					end
					table.insert(onBeingHitEffectList, {spellRES, thecasterlvl, newEffectTarget, newEffectSource, newEffectTargetX, newEffectTargetY, newEffectSourceX, newEffectSourceY})
				end
			end
		end)
--	end
	for k, v in ipairs(onBeingHitEffectList) do
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
	MEONHIT(effectData, creatureData)
--[[
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
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if theopcode == 288 and theparameter2 == 225 and bit.band(thesavingthrow, 0x100000) == 0 and bit.band(thesavingthrow, 0x800000) == 0 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local matchHeader = IEex_ReadWord(eData + 0x48, 0x0)
				local spellRES = IEex_ReadLString(eData + 0x30, 8)
				if theparameter1 == index and spellRES ~= "" and (matchHeader == 0 or matchHeader == headerType) and (bit.band(thesavingthrow, 0x4000000) == 0 or bit.band(IEex_ReadDword(effectData + 0xC8), 0x40) == 0) then
					local thecasterlvl = IEex_ReadDword(eData + 0xC8)
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
					IEex_ApplyEffectToActor(newEffectTarget, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = spellRES,
["source_x"] = newEffectSourceX,
["source_y"] = newEffectSourceY,
["target_x"] = newEffectTargetX,
["target_y"] = newEffectTargetY,
["casterlvl"] = thecasterlvl,
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
	if IEex_GetActorSpellState(targetID, 225) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if theopcode == 288 and theparameter2 == 225 and bit.band(thesavingthrow, 0x100000) > 0 and bit.band(thesavingthrow, 0x800000) == 0 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local matchHeader = IEex_ReadWord(eData + 0x48, 0x0)
				local spellRES = IEex_ReadLString(eData + 0x30, 8)
				if theparameter1 == index and spellRES ~= "" and (matchHeader == 0 or matchHeader == headerType) then
					local thecasterlvl = IEex_ReadDword(eData + 0xC8)
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
						table.insert(targetExpired, theparent_resource)
					elseif usesLeft > 0 then
						usesLeft = usesLeft - 1
						IEex_WriteWord(eData + 0x4A, usesLeft)
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
["casterlvl"] = thecasterlvl,
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
--]]
end

repeat_record = {}
--[[
function IEex_CheckForEffectRepeat(actorID, effectData)
	if bit.band(IEex_ReadDword(effectData + 0x3C), 0x4000) > 0 then return false end
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
--	if bit.band(IEex_ReadDword(effectData + 0x3C), 0x4000) > 0 then return false end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local parameter5 = IEex_ReadDword(effectData + 0x64)
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
			elseif v["effectData"] == effectData and v["parameter5"] == parameter5 then
				return true
			end
		end
	end
	if newTick then
		repeat_record[actorID][funcName] = {}
	end
	table.insert(repeat_record[actorID][funcName], {["effectData"] = effectData, ["time"] = time, ["parameter5"] = parameter5,})
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
	if true then return end
end
ex_last_evaluation_tick = {}
ex_record_projectile_position = {}
function IEex_EvaluatePermanentRepeatingEffects(creatureData)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
--	if IEex_ReadDword(effectData + 0x10C) <= 0 then return end
	local usedFunction = false
	local tick = IEex_GetGameTick()
	local targetID = IEex_GetActorIDShare(creatureData)
	if ex_last_evaluation_tick[targetID] ~= nil then
		timeSinceLastEvaluation = tick - ex_last_evaluation_tick[targetID]
		if timeSinceLastEvaluation <= 0 and timeSinceLastEvaluation >= -2 then return end
	end
	ex_last_evaluation_tick[targetID] = tick
--	if IEex_CheckForInfiniteLoop(targetID, IEex_ReadDword(effectData + 0x24), "MEREPERM", 5) then return end
	if IEex_ReadSignedByte(creatureData + 0x603, 0x0) == -1 then
		for i = 0, 5, 1 do
			if IEex_GetActorIDCharacter(i) == targetID then
				IEex_WriteByte(creatureData + 0x603, 0)
			end
		end
	end

	if targetID == IEex_GetActorIDCharacter(0) then
		local globalEffectFlags = 0
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 230 and IEex_ReadDword(eData + 0x114) == 0 then
				local thespecial = IEex_ReadDword(eData + 0x48)
				globalEffectFlags = bit.bor(globalEffectFlags, thespecial)
			end
		end)
		IEex_WriteDword(creatureData + 0x73C, globalEffectFlags)
		if bit.band(globalEffectFlags, 0x2) > 0 and tick % ex_time_slow_speed_divisor ~= 0 then
			IEex_IterateCastingGlows(function(share)
				local frame = IEex_ReadSignedWord(share + 0x256, 0x0)
				if frame > 0 then
					IEex_WriteWord(share + 0x256, frame - 1)
				end
			end)
			IEex_IterateFireballs(function(share)
				local frame = IEex_ReadSignedWord(share + 0x14E, 0x0)
				if frame > 0 then
					IEex_WriteWord(share + 0x14E, frame - 1)
				end
			end)
			IEex_IterateTemporals(function(temporalData)
				local temporalAnimationData = IEex_ReadDword(temporalData + 0x82)
				if temporalAnimationData > 0 then
					local temporalAnimationFrame = IEex_ReadSignedWord(temporalAnimationData + 0x4CA, 0x0)
					if temporalAnimationFrame > 0 then
						IEex_WriteWord(temporalAnimationData + 0x4CA, temporalAnimationFrame - 1)
					end
				end
				local timeRemaining = IEex_ReadSignedWord(temporalData + 0x9C, 0x0)
				local timeElapsed = IEex_ReadSignedWord(temporalData + 0x10E, 0x0)
				if timeElapsed > 0 then
					IEex_WriteWord(temporalData + 0x9C, timeRemaining + 1)
					IEex_WriteWord(temporalData + 0x10E, timeElapsed - 1)
				end
			end)
			IEex_IterateProjectiles(-1, function(projectileData)
				local projectileAnimationData = IEex_ReadDword(projectileData + 0x192)
				if projectileAnimationData > 65535 then
					local frame = IEex_ReadSignedWord(projectileAnimationData + 0xC4, 0x0)
					if frame > 0 then
						IEex_WriteWord(projectileAnimationData + 0xC4, frame - 1)
					end
				end
				local projectileType = IEex_ProjectileType[IEex_ReadWord(projectileData + 0x6E, 0x0) + 1]
				if projectileType == 6 then
					local timeRemaining = IEex_ReadSignedWord(projectileData + 0x4C0)
					if timeRemaining > 0 then
						IEex_WriteWord(projectileData + 0x4C0, timeRemaining + 1)
					end
				end
			end)
			IEex_IterateIDs(IEex_ReadDword(creatureData + 0x12), 0x30, true, true, function(staticID)
				local staticData = IEex_GetActorShare(staticID)
				local staticFrame = IEex_ReadSignedWord(staticData + 0x17E, 0x0)
				if staticFrame > 0 then
					IEex_WriteWord(staticData + 0x17E, staticFrame - 1)
				end
			end)
		end
	end
	local extraFlags = IEex_ReadDword(creatureData + 0x740)

	if bit.band(extraFlags, 0x1000) == 0 then
		extraFlags = bit.bor(extraFlags, 0x1000)
		IEex_WriteDword(creatureData + 0x740, extraFlags)
		local armoredArcanaFeatCount = IEex_ReadByte(creatureData + 0x781, 0x0)
		IEex_WriteByte(creatureData + 0x781, armoredArcanaFeatCount * ex_armored_arcana_multiplier)
	end
	local repermList = {}
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		if theopcode == 288 and theparameter2 == 224 then
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			if theresource ~= "" then
				usedFunction = true
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				if theparameter1 <= 0 then
					theparameter1 = 1
				end
				if bit.band(thesavingthrow, 0x100000) == 0 then
					theparameter1 = theparameter1 * 15
				end
				if tick % theparameter1 == 0 then
					table.insert(repermList, theresource)
				end
			end
		end
	end)
	for k, v in ipairs(repermList) do
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = v,
["parent_resource"] = v,
["source_id"] = targetID,
})
	end
	local castingSpeedModifier = 0
--	if IEex_GetActorSpellState(targetID, 193) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 193 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if thespecial == 2 then
					usedFunction = true
					castingSpeedModifier = castingSpeedModifier + theparameter1
				end
			end
		end)
--	end

	local monkLevel = IEex_GetActorStat(targetID, 101)
	local fistWeaponRES = IEex_GetItemSlotRES(targetID, 10)
	local weapon1RES = IEex_GetItemSlotRES(targetID, 43)
	local baseAnimation = IEex_ReadDword(creatureData + 0x5C4)
	if fistWeaponRES ~= "" then
		if not IEex_GetActorSpellState(targetID, 182) and not IEex_GetActorSpellState(targetID, 189) then
			if monkLevel > 0 and (ex_monk_animation_conversion[baseAnimation] ~= nil or baseAnimation == 0x6500 or baseAnimation == 0x6510) and weapon1RES == ex_monk_fist_progression[monkLevel] and IEex_ReadByte(creatureData + 0x4BA4, 0x0) == 10 then
	--			IEex_Eval('EquipMostDamagingMelee()',targetID)
				IEex_Eval('SelectWeaponAbility(43,0)',targetID)
				IEex_WriteDword(creatureData + 0x3448, 43)
				IEex_WriteByte(creatureData + 0x4BA4, 43)
				IEex_WriteByte(creatureData + 0x4C68, 0)
				IEex_WriteByte(creatureData + 0x569E, 43)
			elseif monkLevel > 0 and (ex_monk_animation_conversion[baseAnimation] ~= nil or baseAnimation == 0x6500 or baseAnimation == 0x6510) and weapon1RES ~= ex_monk_fist_progression[monkLevel] and fistWeaponRES == ex_monk_fist_progression[monkLevel] then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 143,
["target"] = 2,
["timing"] = 1,
["parameter1"] = 43,
["resource"] = ex_monk_fist_progression[monkLevel],
["parent_resource"] = "USMFIST",
["source_id"] = targetID
})
			elseif fistWeaponRES ~= ex_monk_fist_progression[monkLevel] and ex_monk_fist_progression[monkLevel] ~= nil then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 143,
["target"] = 2,
["timing"] = 1,
["parameter1"] = 10,
["resource"] = ex_monk_fist_progression[monkLevel],
["parent_resource"] = "USMFIST",
["source_id"] = targetID
})
			end
		else
			if monkLevel > 0 and (ex_monk_animation_conversion[baseAnimation] ~= nil or baseAnimation == 0x6500 or baseAnimation == 0x6510) and weapon1RES == ex_incorporeal_monk_fist_progression[monkLevel] and IEex_ReadByte(creatureData + 0x4BA4, 0x0) == 10 then
	--			IEex_Eval('EquipMostDamagingMelee()',targetID)
				IEex_Eval('SelectWeaponAbility(43,0)',targetID)
				IEex_WriteDword(creatureData + 0x3448, 43)
				IEex_WriteByte(creatureData + 0x4BA4, 43)
				IEex_WriteByte(creatureData + 0x4C68, 0)
				IEex_WriteByte(creatureData + 0x569E, 43)
			elseif monkLevel > 0 and (ex_monk_animation_conversion[baseAnimation] ~= nil or baseAnimation == 0x6500 or baseAnimation == 0x6510) and weapon1RES ~= ex_incorporeal_monk_fist_progression[monkLevel] and fistWeaponRES == ex_incorporeal_monk_fist_progression[monkLevel] then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 143,
["target"] = 2,
["timing"] = 1,
["parameter1"] = 43,
["resource"] = ex_incorporeal_monk_fist_progression[monkLevel],
["parent_resource"] = "USMFIST",
["source_id"] = targetID
})
			elseif fistWeaponRES ~= ex_incorporeal_monk_fist_progression[monkLevel] and ex_incorporeal_monk_fist_progression[monkLevel] ~= nil then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 143,
["target"] = 2,
["timing"] = 1,
["parameter1"] = 10,
["resource"] = ex_incorporeal_monk_fist_progression[monkLevel],
["parent_resource"] = "USMFIST",
["source_id"] = targetID
})
			end
		end
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
	if bit.band(extraFlags, 0x10000) == 0 and (IEex_GetActorStat(targetID, 97) > 12 or IEex_GetActorStat(targetID, 105) > 9 or IEex_GetActorStat(targetID, 106) > 8) then
		local spells = IEex_FetchSpellInfo(targetID, {1, 6, 7})
		local sourceHasSpell = false
		for i = 1, 9, 1 do
			for cType, levelList in pairs(spells) do
				if #levelList >= i then
					local levelI = levelList[i]
					local maxCastable = levelI[1]
					local sorcererCastableCount = levelI[2]
					local levelISpells = levelI[3]
					if #levelISpells > 0 then
						for i2, spell in ipairs(levelISpells) do
							if spell["resref"] == "USWI553" then
								sourceHasSpell = true
							end
						end
					end
				end
			end
		end
		if sourceHasSpell then
			extraFlags = bit.bor(extraFlags, 0x10000)
			IEex_WriteDword(creatureData + 0x740, extraFlags)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = "USTIMELS",
["parent_resource"] = "USTIMELS",
["source_id"] = targetID,
})
		end
	end
	if bit.band(extraFlags, 0x20000) == 0 then
		extraFlags = bit.bor(extraFlags, 0x20000)
		IEex_WriteDword(creatureData + 0x740, extraFlags)
		local extendSpellFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_EXTEND_SPELL"], 0x0)
		local maximizeSpellFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MAXIMIZE_SPELL"], 0x0)
		local quickenSpellFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_QUICKEN_SPELL"], 0x0)
		local safeSpellFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_SAFE_SPELL"], 0x0)
		if extendSpellFeatCount > 0 and IEex_GetActorSpellState(targetID, 239) then
			IEex_WriteByte(creatureData + 0x744 + ex_feat_name_id["ME_EXTEND_SPELL"], 1)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "FE_" .. ex_feat_name_id["ME_EXTEND_SPELL"] .. "_1",
["source_id"] = targetID,
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 171,
["target"] = 2,
["timing"] = 1,
["resource"] = "USMM003",
["source_id"] = targetID,
})
		end
		if maximizeSpellFeatCount > 0 and IEex_GetActorSpellState(targetID, 238) then
			IEex_WriteByte(creatureData + 0x744 + ex_feat_name_id["ME_MAXIMIZE_SPELL"], 1)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "FE_" .. ex_feat_name_id["ME_MAXIMIZE_SPELL"] .. "_1",
["source_id"] = targetID,
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 171,
["target"] = 2,
["timing"] = 1,
["resource"] = "USMM002",
["source_id"] = targetID,
})
		end
		if quickenSpellFeatCount > 0 and IEex_GetActorSpellState(targetID, 234) then
			IEex_WriteByte(creatureData + 0x744 + ex_feat_name_id["ME_QUICKEN_SPELL"], 1)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "FE_" .. ex_feat_name_id["ME_QUICKEN_SPELL"] .. "_1",
["source_id"] = targetID,
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 171,
["target"] = 2,
["timing"] = 1,
["resource"] = "USMM007",
["source_id"] = targetID,
})
		end
		if safeSpellFeatCount > 0 and IEex_GetActorSpellState(targetID, 235) then
			IEex_WriteByte(creatureData + 0x744 + ex_feat_name_id["ME_SAFE_SPELL"], 1)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "FE_" .. ex_feat_name_id["ME_SAFE_SPELL"] .. "_1",
["source_id"] = targetID,
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 171,
["target"] = 2,
["timing"] = 1,
["resource"] = "USMM004",
["source_id"] = targetID,
})
		end
	end
	if IEex_ReadByte(creatureData + 0x24, 0x0) <= 30 and (IEex_GetActorStat(targetID, 101) > 0 or IEex_GetActorStat(targetID, 102) > 0) then
		local specialFlags = IEex_ReadByte(creatureData + 0x89F, 0x0)
		local kit = IEex_GetActorStat(targetID, 89)
		for k, v in pairs(ex_order_multiclass) do
			if bit.band(kit, k) > 0 then
				local acceptable = true
				local acceptable_classes = {}
				for i, c in ipairs(v) do
					acceptable_classes["" .. c[1]] = c[2]
				end
				for i = 1, 11, 1 do
					if IEex_GetActorStat(targetID, 95 + i) > 0 then
						if acceptable_classes["" .. i] == nil then
							acceptable = false
						elseif acceptable_classes["" .. i] ~= -1 and bit.band(kit, acceptable_classes["" .. i]) == 0 then
							acceptable = false
						end
					end
				end
				if acceptable then
					if k <= 4 and bit.band(specialFlags, 0x4) > 0 then
						IEex_WriteByte(creatureData + 0x89F, bit.band(specialFlags, 0xFB))
					elseif k > 4 and bit.band(specialFlags, 0x8) > 0 then
						IEex_WriteByte(creatureData + 0x89F, bit.band(specialFlags, 0xF7))
					end
				else
					if k <= 4 and bit.band(specialFlags, 0x4) == 0 then
						IEex_WriteByte(creatureData + 0x89F, bit.bor(specialFlags, 0x4))
					elseif k > 4 and bit.band(specialFlags, 0x8) == 0 then
						IEex_WriteByte(creatureData + 0x89F, bit.bor(specialFlags, 0x8))
					end
				end
			end
		end
	end
	return usedFunction
end

function MEONCAST(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
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
--	if IEex_GetActorSpellState(targetID, 234) then
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
--	end
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
--	if IEex_GetActorSpellState(targetID, 239) then
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
--	end
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
--	if IEex_GetActorSpellState(targetID, 193) then
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
--	end
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
--	if IEex_GetActorSpellState(targetID, 227) then
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
--	end
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
--	if IEex_GetActorSpellState(sourceID, 235) then
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
--	end
	local allowAbsorption = false
	if bit.band(savingthrow, 0x20000) > 0 and IEex_GetActorSpellState(targetID, 214) then
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
	local internalFlags = IEex_ReadDword(effectData + 0xC8)
	if (bit.band(internalFlags, 0x80000) > 0 or (classSpellLevel > 0 and maximumSafeSpellLevel >= classSpellLevel)) and allowAbsorption == false then
		if bit.band(savingthrow, 0x10000) == 0 then
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

parameter1 - Determines the maximum number of spell uses that can be restored. If negative, it removes spells instead.

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
Bit 25: If set, the function will only restore the spell specified in the "vvcresource" (referred to as Resource2 in NearInfinity).
Bit 27: If set, the function generates feedback on which spells were restored/removed.

special - Determines the lowest spell level that can be restored (1 - 9).
--]]

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
	local matchSpell = IEex_ReadLString(effectData + 0x6C, 8)
	if matchSpell == "" then
		matchSpell = parent_resource
	end
--[[
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
		if bit.band(savingthrow, 0x1000000) > 0 then
			modifyRemaining = modifyRemaining + math.floor((math.random(20) + casterlvl + IEex_GetActorStat(sourceID, 29)) / 10)
		end
	end
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	local casterType = IEex_CasterClassToType[casterClass]
	local casterTypes = {}
	if casterType ~= nil then
		if bit.band(savingthrow, 2 ^ (casterType + 15)) == 0 then
			table.insert(casterTypes, casterType)
		end
		if casterType == 2 and bit.band(savingthrow, 0x800000) > 0 then
			table.insert(casterTypes, 8)
		end
	end
	for i = 1, 7, 1 do
		if bit.band(savingthrow, 2 ^ (i + 15)) > 0 then
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
						local matchSpellFound = true
						if bit.band(savingthrow, 0x2000000) > 0 then
							matchSpellFound = false
							for i2, spell in ipairs(levelISpells) do
								if matchSpell == spell["resref"] then
									matchSpellFound = true
								end
							end
						end
						if matchSpellFound then
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
						end
					else
						for i2, spell in ipairs(levelISpells) do
							if bit.band(savingthrow, 0x2000000) == 0 or matchSpell == spell["resref"] then
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
	end
	if bit.band(savingthrow, 0x8000000) > 0 then
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
				feedbackString = string.gsub(feedbackString, "<EXSSLEVELORNAME>", IEex_FetchString(ex_spelllevelstrrefs[modifyList[i][1]]))
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
		if bit.band(savingthrow, 0x8000000) > 0 and #modifyList > 0 then
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
					feedbackString = string.gsub(feedbackString, "<EXSSLEVELORNAME>", IEex_FetchString(ex_spelllevelstrrefs[modifyList[i][1]]))
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
	local sourceData = IEex_GetActorShare(sourceID)
	local targetID = IEex_GetActorIDShare(creatureData)
	local checkID = targetID
	local newEffectTarget = targetID
	local hasProtection = false
	local protectionType = IEex_ReadDword(effectData + 0x44)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	if bit.band(savingthrow, 0x20000) > 0 and IEex_IsSprite(sourceID, true) then
		checkID = sourceID
	end
	if bit.band(savingthrow, 0x200000) > 0 then
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
		local stateValue = bit.bor(IEex_ReadDword(checkData + 0x5BC), IEex_ReadDword(checkData + 0x920))
		if bit.band(stateValue, match_state) > 0 then
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
		local statValue = IEex_GetActorStat(checkID, match_stat)
		if (statOperator == 0 and statValue >= match_value) or (statOperator == 1 and statValue == match_value) or (statOperator == 2 and bit.band(statValue, match_value) == match_value) or (statOperator == 3 and bit.band(statValue, match_value) > 0) then
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
		if (statOperator == 0 and statValue >= match_value) or (statOperator == 1 and statValue == match_value) or (statOperator == 2 and bit.band(statValue, match_value) == match_value) or (statOperator == 3 and bit.band(statValue, match_value) > 0) then
			hasProtection = true
		end
	elseif protectionType == 6 then
		local race = IEex_ReadByte(checkData + 0x26, 0x0)
		local match_race1 = IEex_ReadByte(effectData + 0x1C, 0x0)
		local match_race2 = IEex_ReadByte(effectData + 0x1D, 0x0)
		local match_race3 = IEex_ReadByte(effectData + 0x1E, 0x0)
		local match_race4 = IEex_ReadByte(effectData + 0x1F, 0x0)
		if race == match_race1 or race == match_race2 or race == match_race3 or race == match_race4 then
			hasProtection = true
		end
	elseif protectionType == 7 then
		local general = IEex_ReadByte(checkData + 0x25, 0x0)
		local match_general1 = IEex_ReadByte(effectData + 0x1C, 0x0)
		local match_general2 = IEex_ReadByte(effectData + 0x1D, 0x0)
		local match_general3 = IEex_ReadByte(effectData + 0x1E, 0x0)
		local match_general4 = IEex_ReadByte(effectData + 0x1F, 0x0)
		if general == match_general1 or general == match_general2 or general == match_general3 or general == match_general4 then
			hasProtection = true
		end
	elseif protectionType == 8 then
		local match_value = IEex_ReadDword(effectData + 0x18)
		local match_stat = IEex_ReadWord(effectData + 0x1C, 0x0)
		local statOperator = IEex_ReadByte(effectData + 0x1F, 0x0)
		local statValue = math.abs(IEex_GetActorStat(targetID, match_stat) - IEex_GetActorStat(sourceID, match_stat))
		if (statOperator == 0 and statValue >= match_value) or (statOperator == 1 and statValue == match_value) or (statOperator == 2 and bit.band(statValue, match_value) == match_value) or (statOperator == 3 and bit.band(statValue, match_value) > 0) then
			hasProtection = true
		end
	end
	local invert = (bit.band(savingthrow, 0x100000) > 0)
	if (hasProtection == true and invert == false) or (hasProtection == false and invert == true) then
		if bit.band(savingthrow, 0x10000) == 0 then
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
 102: Fiend
 104: Fiend or undead
 106: Airborne
 108: Incorporeal or ethereal
 110: Yuan-ti

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
	if (protectionType > 0 and protectionType <= 62 and bit.band(protectionType, 0x1) == 0) or (((protectionType > 63 and protectionType <= 73) or (protectionType > 77)) and bit.band(protectionType, 0x1) > 0) then
		invert = true
		protectionType = protectionType - 1
	end
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	if bit.band(savingthrow, 0x20000) > 0 and IEex_IsSprite(sourceID, true) then
		checkID = sourceID
	end
	if bit.band(savingthrow, 0x200000) > 0 then
		newEffectTarget = sourceID
	end
	local checkData = IEex_GetActorShare(checkID)
	local sourceData = IEex_GetActorShare(sourceID)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local general = IEex_ReadByte(checkData + 0x25, 0x0)
	local race = IEex_ReadByte(checkData + 0x26, 0x0)
	local gender = IEex_ReadByte(checkData + 0x34, 0x0)
	local alignment = IEex_ReadByte(checkData + 0x35, 0x0)
	local animation = IEex_ReadDword(checkData + 0x5C4)
	local subrace = IEex_ReadByte(checkData + 0x7FF, 0x0)
	local stateValue = bit.bor(IEex_ReadDword(checkData + 0x5BC), IEex_ReadDword(checkData + 0x920))
	if protectionType == 0 then
		hasProtection = true
	elseif protectionType == 1 and general == 4 then
		hasProtection = true
	elseif protectionType == 3 then
		local baseFireResistance = IEex_ReadByte(checkData + 0x5F1, 0x0)
		if animation == 29456 or animation == 57896 or animation == 60376 or ((animation == 32517 or animation == 32518 or animation == 59176 or animation == 60507 or animation == 62216) and baseFireResistance >= 50) then
			hasProtection = true
		end
	elseif protectionType == 5 and general == 1 then
		hasProtection = true
	elseif protectionType == 7 and general == 2 then
		hasProtection = true
	elseif protectionType == 9 and (race == 152 or race == 161) then
		hasProtection = true
	elseif protectionType == 11 then
		if animation == 60313 or animation == 60329 or animation == 60337 then
			hasProtection = true
		end
	elseif protectionType == 13 then
		if parameter1 == 0 then
			parameter1 = 5
		end
		local animationData = IEex_ReadDword(checkData + 0x50F0)
		if animationData > 0 and IEex_ReadByte(animationData + 0x3E4, 0x0) >= parameter1 then
			hasProtection = true
		end
	elseif protectionType == 15 and (race == 2 or race == 183) then
		hasProtection = true
	elseif protectionType == 17 then
		if animation == 59225 or animation == 59385 then
			hasProtection = true
		end
	elseif protectionType == 19 and race == 3 then
		hasProtection = true
	elseif protectionType == 21 and (general == 1 or general == 2) then
		hasProtection = true
	elseif protectionType == 23 then
		if bit.band(stateValue, 0x40000) > 0 then
			hasProtection = true
		end
	elseif protectionType == 25 then
		local baseColdResistance = IEex_ReadByte(checkData + 0x5F2, 0x0)
		if animation == 29187 or animation == 31491 or animation == 57656 or animation == 58201 or animation == 58664 or animation == 59192 or animation == 59244 or animation == 59337 or animation == 60184 or animation == 60392 or animation == 60427 or ((animation == 4097 or animation == 59176) and baseColdResistance >= 50) then
			hasProtection = true
		end
	elseif protectionType == 27 and race == ex_construct_race then
		hasProtection = true
	elseif protectionType == 29 then
		if animation == 59144 then
			hasProtection = true
		end
	elseif protectionType == 31 then
		if animation == 60313 or animation == 60329 or animation == 60337 or general == 4 then
			hasProtection = true
		end
	elseif protectionType == 33 and bit.band(alignment, 0x3) == 0x1 then
		hasProtection = true
	elseif protectionType == 35 and bit.band(alignment, 0x3) == 0x2 then
		hasProtection = true
	elseif protectionType == 37 and bit.band(alignment, 0x3) == 0x3 then
		hasProtection = true
	elseif protectionType == 39 and IEex_GetActorStat(targetID, 102) > 0 then
		hasProtection = true
	elseif protectionType == 41 and IEex_IsSprite(sourceID, true) then
		local targetAlignment = IEex_ReadByte(creatureData + 0x35, 0x0)
		local sourceAlignment = IEex_ReadByte(sourceData + 0x35, 0x0)
		if bit.band(targetAlignment, 0x3) == bit.band(sourceAlignment, 0x3) then
			hasProtection = true
		end
	elseif protectionType == 43 and targetID == sourceID then
		hasProtection = true
	elseif protectionType == 45 then
		if animation == 58280 or animation == 57912 or animation == 57938 or animation == 58008 or animation == 59368 or animation == 59385 or animation == 62475 or animation == 62491 then
			hasProtection = true
		end
	elseif protectionType == 47 then
		if general == 4 or race == ex_construct_race then
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
		local baseFireResistance = IEex_ReadByte(checkData + 0x5F1, 0x0)
		local baseColdResistance = IEex_ReadByte(checkData + 0x5F2, 0x0)
		if animation == 29456 or animation == 57896 or animation == 60376 or ((animation == 32517 or animation == 32518 or animation == 59176 or animation == 60507 or animation == 62216) and baseFireResistance >= 50) or animation == 29187 or animation == 31491 or animation == 57656 or animation == 58201 or animation == 58664 or animation == 59192 or animation == 59244 or animation == 59337 or animation == 60184 or animation == 60392 or animation == 60427 or ((animation == 4097 or animation == 59176) and baseColdResistance >= 50) then
			hasProtection = true
		end
	elseif protectionType == 55 then
		if general == 4 or race == ex_construct_race or race == ex_fiend_race or race == 152 or race == 161 then
			hasProtection = true
		end
	elseif protectionType == 57 and gender == 1 then
		hasProtection = true
	elseif protectionType == 59 and bit.band(alignment, 0x30) == 0x10 then
		hasProtection = true
	elseif protectionType == 61 and bit.band(alignment, 0x30) == 0x30 then
		hasProtection = true
	elseif protectionType == 64 then
		if animation == 59400 or animation == 59416 or animation == 59426 or animation == 59448 or animation == 59458 or animation == 59481 or animation == 59496 or animation == 59512 or animation == 59528 or animation == 59609 or animation == 59641 then
			hasProtection = true
		end
	elseif protectionType == 66 and IEex_GetActorSpellState(checkID, 38) then
		hasProtection = true
	elseif protectionType == 68 then
		if bit.band(stateValue, 0x10000000) > 0 then
			hasProtection = true
		end
	elseif protectionType == 70 then
		if animation == 32513 or animation == 61427 then
			hasProtection = true
		end
	elseif protectionType == 72 then
		if bit.band(stateValue, 0x1000) > 0 then
			hasProtection = true
		end
	elseif protectionType == 82 then
		if race == 183 or (race == 2 and subrace == 1) then
			hasProtection = true
		end
	elseif protectionType == 84 then
		if race == 185 or (race == 4 and subrace == 2) then
			hasProtection = true
		end
	elseif protectionType == 88 then
		local areaData = IEex_ReadDword(checkData + 0x12)
		if areaData > 0 and bit.band(IEex_ReadWord(areaData + 0x40, 0x0), 0x1) > 0 then
			hasProtection = true
		end
	elseif protectionType == 90 then
		if animation == 61264 or animation == 61280 or animation == 61296 then
			hasProtection = true
		end
	elseif protectionType == 92 then
		if race == ex_fiend_race or race == 152 or race == 161 then
			hasProtection = true
		end
	elseif protectionType == 94 then
		if general == 4 or race == ex_construct_race then
			hasProtection = true
		end
	elseif protectionType == 96 then
		if general == 4 or race == ex_construct_race or animation == 29442 or (animation >= 30976 and animation <= 30979) then
			hasProtection = true
		end
	elseif protectionType == 98 then
		if race == 183 or (race == 2 and subrace == 1) or race == 185 or (race == 4 and subrace == 2) then
			hasProtection = true
		end
	elseif protectionType == 100 then
		if race == 183 or (race == 2 and subrace == 1) or race == 185 or (race == 4 and subrace == 2) or animation == 58153 or animation == 58201 or animation == 58217 or animation == 59656 or animation == 59672 or animation == 60313 or animation == 60329 or animation == 60337 then
			hasProtection = true
		end
	elseif protectionType == 102 then
		if race == ex_fiend_race then
			hasProtection = true
		end
	elseif protectionType == 104 then
		if race == ex_fiend_race or general == 4 then
			hasProtection = true
		end
	elseif protectionType == 106 then
		if parameter1 == 0 then
			parameter1 = 50
		end
		if IEex_ReadSignedWord(checkData + 0x720, 0x0) >= parameter1 or IEex_GetActorSpellState(checkID, 184) then
			hasProtection = true
		end
	elseif protectionType == 108 then
		if IEex_GetActorSpellState(checkID, 182) or IEex_GetActorSpellState(checkID, 189) then
			hasProtection = true
		end
	elseif protectionType == 110 then
		if race == 168 and animation ~= 59545 and animation ~= 61961 and animation ~= 61976 then
			hasProtection = true
		end
	end
	
	if (hasProtection == true and invert == false) or (hasProtection == false and invert == true) then
		if bit.band(savingthrow, 0x10000) == 0 then
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
	local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
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
		if (thesourceID == sourceID or (thesourceID <= 0 and bit.band(savingthrow, 0x10000) > 0)) and (((theparent_resource == sourceSpell) and bit.band(savingthrow, 0x20000) == 0) or ((theschool == school) and bit.band(savingthrow, 0x20000) > 0)) then
			IEex_WriteDword(eData + 0x28, 0)
			IEex_WriteDword(eData + 0x114, 1)
		end
	end)
end

function MEREMOPC(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local match_opcode = IEex_ReadSignedWord(effectData + 0x18, 0x0)
	local match_opcode2 = IEex_ReadSignedWord(effectData + 0x1A, 0x0)
	local match_parameter2 = IEex_ReadDword(effectData + 0x1C)
	local match_special = IEex_ReadDword(effectData + 0x44)
	local match_resource = IEex_ReadLString(effectData + 0x18, 8)
	local checkResource = (bit.band(IEex_ReadDword(effectData + 0x3C), 0x10000) > 0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	if targetID <= 0x0 then return end
	IEex_IterateActorEffects(targetID, function(eData)
		local the_opcode = IEex_ReadDword(eData + 0x10)
		local the_parameter2 = IEex_ReadDword(eData + 0x20)
		local the_special = IEex_ReadDword(eData + 0x48)
		local the_resource = IEex_ReadLString(eData + 0x30, 8)
		if not checkResource then
			if (match_opcode == -1 or match_opcode == the_opcode or (match_opcode2 > 0 and match_opcode2 == the_opcode)) and (match_parameter2 == -1 or match_parameter2 == the_parameter2) and (match_special == -1 or match_special == the_special) then
				IEex_WriteDword(eData + 0x28, IEex_ReadDword(eData + 0x6C))
			end
		else
			if (match_special == -1 or match_special == the_opcode) and match_resource == the_resource then
				IEex_WriteDword(eData + 0x28, IEex_ReadDword(eData + 0x6C))
			end
		end
	end)
end

function MEREMSSE(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local match_opcode = IEex_ReadDword(effectData + 0x18, 0x0)
	local match_parameter2 = IEex_ReadDword(effectData + 0x1C)
	local match_special = IEex_ReadDword(effectData + 0x44)
	local match_resource = IEex_ReadLString(effectData + 0x18, 8)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	if targetID <= 0x0 then return end
	local resourcesToRemove = {}
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		local thespecial = IEex_ReadDword(eData + 0x48)
		if (match_opcode == -1 or match_opcode == theopcode) and (match_parameter2 == -1 or match_parameter2 == theparameter2) and (match_special == -1 or match_special == thespecial) then
			table.insert(resourcesToRemove, IEex_ReadLString(eData + 0x94, 8))
		end
	end)
	for k, res in ipairs(resourcesToRemove) do
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["resource"] = res,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	end
end


function MEAOESP2(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 0x1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local maxradius = IEex_ReadWord(effectData + 0x44, 0x0)
	local minradius = IEex_ReadSignedWord(effectData + 0x46, 0x0)
	local sourceX = IEex_ReadDword(effectData + 0x7C)
	local sourceY = IEex_ReadDword(effectData + 0x80)
	local targetX = IEex_ReadDword(effectData + 0x84)
	local targetY = IEex_ReadDword(effectData + 0x88)
	if bit.band(savingthrow, 0x40000) > 0 then
		sourceID = targetID
	end
	if (targetX <= 0 and targetY <= 0) or bit.band(savingthrow, 0x80000) > 0 then
		targetX = IEex_ReadDword(creatureData + 0x6)
		targetY = IEex_ReadDword(creatureData + 0xA)
	end
	local ids = {}
	if IEex_ReadDword(creatureData + 0x12) > 0 then
		ids = IEex_GetIDArea(sourceID, 0x31, true, true)
	end
	local closestDistance = 0x7FFFFFFF
	local possibleTargets = {}
	if bit.band(savingthrow, 0x40000000) == 0 then
		for k, currentID in ipairs(ids) do
			local currentShare = IEex_GetActorShare(currentID)
			if currentShare > 0 then
				local currentX = IEex_ReadDword(currentShare + 0x6)
				local currentY = IEex_ReadDword(currentShare + 0xA)
				local currentDistance = IEex_GetDistance(targetX, targetY, currentX, currentY)
				local states = IEex_ReadDword(currentShare + 0x5BC)
				local animation = IEex_ReadDword(currentShare + 0x5C4)
				local cea = IEex_CompareActorAllegiances(sourceID, currentID)
				if currentDistance < maxradius and currentDistance >= minradius and (bit.band(savingthrow, 0x2000000) == 0 or currentDistance < closestDistance) and (bit.band(savingthrow, 0x8000) == 0 or bit.band(IEex_ReadByte(currentShare + 0x35, 0x0), 0x3) == 0x3) and (bit.band(savingthrow, 0x200000) == 0 or cea ~= 1) and (bit.band(savingthrow, 0x400000) == 0 or cea ~= 0) and (bit.band(savingthrow, 0x800000) == 0 or cea ~= -1) and (bit.band(savingthrow, 0x1000000) == 0 or currentID ~= targetID) and (bit.band(savingthrow, 0x4000000) == 0 or IEex_CheckActorLOSObject(sourceID, currentID)) and animation >= 0x1000 and (animation < 0xD000 or animation >= 0xE000) and bit.band(states, 0x800) == 0 and IEex_ReadByte(currentShare + 0x838, 0x0) == 0 then
					if bit.band(savingthrow, 0x2000000) == 0 then
						table.insert(possibleTargets, {currentID, currentX, currentY})
					else
						closestDistance = currentDistance
						possibleTargets = {{currentID, currentX, currentY}}
					end
				end
			end
		end
	end
	if #possibleTargets > 0 then
		if bit.band(savingthrow, 0x10000) == 0 then
			local randomTarget = possibleTargets[math.random(#possibleTargets)]
			IEex_ApplyEffectToActor(randomTarget[1], {
["opcode"] = 402,
["target"] = 2,
["timing"] = 9,
["resource"] = spellRES,
["parent_resource"] = spellRES,
["casterlvl"] = casterlvl,
["source_target"] = randomTarget[1],
["source_id"] = sourceID,
["source_x"] = sourceX,
["source_y"] = sourceY,
["target_x"] = randomTarget[2],
["target_y"] = randomTarget[3]
})
		else
			for k, currentTarget in ipairs(possibleTargets) do
				IEex_ApplyEffectToActor(currentTarget[1], {
["opcode"] = 402,
["target"] = 2,
["timing"] = 9,
["resource"] = spellRES,
["parent_resource"] = spellRES,
["casterlvl"] = casterlvl,
["source_target"] = currentTarget[1],
["source_id"] = sourceID,
["source_x"] = sourceX,
["source_y"] = sourceY,
["target_x"] = currentTarget[2],
["target_y"] = currentTarget[3]
})
			end
		end
	elseif bit.band(savingthrow, 0x20000) > 0 then
		local deltaX = math.random(maxradius * 2 + 1) - maxradius - 1
		local deltaY = math.random(maxradius * 2 + 1) - maxradius - 1
		local currentDistance = math.floor((deltaX ^ 2 + deltaY ^ 2) ^ .5)
		while currentDistance >= maxradius or currentDistance < minradius do
			deltaX = math.random(maxradius * 2 + 1) - maxradius - 1
			deltaY = math.random(maxradius * 2 + 1) - maxradius - 1
			currentDistance = math.floor((deltaX ^ 2 + deltaY ^ 2) ^ .5)
		end
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 148,
["target"] = 2,
["timing"] = 9,
["parameter1"] = IEex_ReadByte(effectData + 0xC4, 0x0),
["parameter2"] = 2,
["resource"] = spellRES,
["casterlvl"] = casterlvl,
["source_target"] = targetID,
["source_id"] = sourceID,
["source_x"] = sourceX,
["source_y"] = sourceY,
["target_x"] = targetX + deltaX,
["target_y"] = targetY + deltaY
})
	end
end

local state_save_penalties = {
["USWI452"] = {0x4, 6},
["USWI452D"] = {0x4, 6},
}
function MESPLSAV(effectData, creatureData)
--	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceData = IEex_GetActorShare(sourceID)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local savebonus = IEex_ReadDword(effectData + 0x40)
	if bit.band(savingthrow, 0x8000000) > 0 then
		savebonus = savebonus * -1
	end
	local saveBonusStat = IEex_ReadByte(effectData + 0x44, 0x0)
	local bonusStatMultiplier = IEex_ReadByte(effectData + 0x45, 0x0)
	local bonusStatDivisor = IEex_ReadByte(effectData + 0x46, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	if bit.band(savingthrow, 0x20000000) > 0 and IEex_IsSprite(sourceID, false) and IEex_IsSprite(IEex_ReadDword(sourceData + 0x72C), false) then
		local creatureName = IEex_ReadLString(sourceData + 0x598, 8)
		local summonNumber = IEex_ReadWord(sourceData + 0x732, 0x0)
		sourceID = IEex_ReadDword(sourceData + 0x72C)
		sourceData = IEex_GetActorShare(sourceID)
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local theparameter3 = IEex_ReadWord(eData + 0x60, 0x0)
			if theopcode == 288 and theparameter2 == 207 and (theresource == creatureName or (summonNumber > 0 and theparameter3 == summonNumber)) then
				casterlvl = IEex_ReadDword(eData + 0xC8)
				casterClass = IEex_ReadByte(eData + 0xC9, 0x0)
			end
		end)
	end
	local sourceSpell = ex_damage_source_spell[parent_resource]
	if sourceSpell == nil then
		sourceSpell = parent_resource
	end
	local classSpellLevel = 0
	if IEex_IsSprite(sourceID, true) then
		classSpellLevel = IEex_GetClassSpellLevel(sourceID, casterClass, sourceSpell)
	end
	if classSpellLevel <= 0 then
		local resWrapper = IEex_DemandRes(sourceSpell, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if IEex_ReadWord(spellData + 0x1C, 0x0) == 1 or IEex_ReadWord(spellData + 0x1C, 0x0) == 2 then
				classSpellLevel = IEex_ReadDword(spellData + 0x34)
			end
		end
		resWrapper:free()
	end
	savebonus = savebonus + classSpellLevel
	local trueschool = 0
	if ex_trueschool[sourceSpell] ~= nil then
		trueschool = ex_trueschool[sourceSpell]
	end
	if trueschool > 0 then
		local sourceKit = IEex_GetActorStat(sourceID, 89)
		if bit.band(sourceKit, 0x4000) > 0 then
			savebonus = savebonus + 1
		elseif ex_spell_focus_component_installed then
			if trueschool == 1 and bit.band(sourceKit, 0x40) > 0 or trueschool == 2 and bit.band(sourceKit, 0x80) > 0 or trueschool == 3 and bit.band(sourceKit, 0x100) > 0 or trueschool == 5 and bit.band(sourceKit, 0x400) > 0 then
				savebonus = savebonus + 2
			elseif trueschool == 1 and bit.band(sourceKit, 0x2000) > 0 or trueschool == 2 and bit.band(sourceKit, 0x800) > 0 or trueschool == 3 and bit.band(sourceKit, 0x1000) > 0 or trueschool == 5 and bit.band(sourceKit, 0x200) > 0 then
				savebonus = savebonus - 2
			end
		end
	end
	if state_save_penalties[parent_resource] ~= nil then
		local stateValue = bit.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
		if bit.band(stateValue, state_save_penalties[parent_resource][1]) > 0 then
			savebonus = savebonus + state_save_penalties[parent_resource][2]
		end
	end
	local saveBonusStatValue = 0
	if IEex_IsSprite(sourceID, true) then
		if bit.band(savingthrow, 0x40) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x784, 0x0) * 2
		end
		if bit.band(savingthrow, 0x80) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x785, 0x0) * 2
		end
		if bit.band(savingthrow, 0x100) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x786, 0x0) * 2
		end
		if bit.band(savingthrow, 0x200) > 0 then
			savebonus = savebonus + IEex_ReadByte(sourceData + 0x787, 0x0) * 2
		end
		if bit.band(savingthrow, 0x40000) == 0 then
			if casterClass == 11 then
				savebonus = savebonus - math.floor((IEex_GetActorStat(sourceID, 38) - 10) / 2)
			elseif casterClass == 3 or casterClass == 4 or casterClass == 7 or casterClass == 8 then
				savebonus = savebonus - math.floor((IEex_GetActorStat(sourceID, 39) - 10) / 2)
			elseif casterClass == 2 or casterClass == 10 then
				savebonus = savebonus - math.floor((IEex_GetActorStat(sourceID, 42) - 10) / 2)
			end
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
--		if IEex_GetActorSpellState(sourceID, 236) then
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
--		end
--		if IEex_GetActorSpellState(sourceID, 242) then
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 242 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if thespecial == trueschool or thespecial == -1 or ((thespecial == 4 or thespecial == 5) and bit.band(savingthrow, 0x40) > 0) or ((thespecial == 2 or thespecial == 6) and bit.band(savingthrow, 0x80) > 0) or ((thespecial == 3 or thespecial == 7) and bit.band(savingthrow, 0x100) > 0) or ((thespecial == 1 or thespecial == 8) and bit.band(savingthrow, 0x200) > 0) then
						savebonus = savebonus + theparameter1
					end
				end
			end)
--		end
	end
--	if IEex_GetActorSpellState(targetID, 237) then
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
--	end
--	if IEex_GetActorSpellState(targetID, 243) then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 242 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if thespecial == trueschool or thespecial == -1 or ((thespecial == 4 or thespecial == 5) and bit.band(savingthrow, 0x40) > 0) or ((thespecial == 2 or thespecial == 6) and bit.band(savingthrow, 0x80) > 0) or ((thespecial == 3 or thespecial == 7) and bit.band(savingthrow, 0x100) > 0) or ((thespecial == 1 or thespecial == 8) and bit.band(savingthrow, 0x200) > 0) then
					savebonus = savebonus + theparameter1
				end
			end
		end)
--	end
	local newSavingThrow = 0
	if bit.band(savingthrow, 0x400) > 0 then
		newSavingThrow = bit.bor(newSavingThrow, 0x4)
	end
	if bit.band(savingthrow, 0x800) > 0 then
		newSavingThrow = bit.bor(newSavingThrow, 0x8)
	end
	if bit.band(savingthrow, 0x1000) > 0 then
		newSavingThrow = bit.bor(newSavingThrow, 0x10)
	end

	if bit.band(savingthrow, 0x10000000) > 0 then
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
["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
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
	local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local savebonus = IEex_ReadDword(effectData + 0x40)
	local saveBonusStat = IEex_ReadByte(effectData + 0x44, 0x0)
	local saveBonusLevel = IEex_ReadByte(effectData + 0x45, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	savebonus = savebonus + math.floor(IEex_GetActorStat(sourceID, saveBonusLevel) / 2) + math.floor((IEex_GetActorStat(sourceID, saveBonusStat) - 10) / 2)
--	if IEex_GetActorSpellState(sourceID, 236) then
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
--	end
	local newSavingThrow = 0
	if bit.band(savingthrow, 0x400) > 0 then
		newSavingThrow = bit.bor(newSavingThrow, 0x4)
	end
	if bit.band(savingthrow, 0x800) > 0 then
		newSavingThrow = bit.bor(newSavingThrow, 0x8)
	end
	if bit.band(savingthrow, 0x1000) > 0 then
		newSavingThrow = bit.bor(newSavingThrow, 0x10)
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
	local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
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
		newSavingThrow = bit.bor(newSavingThrow, 0x8)
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_915,
["parent_resource"] = "USKNKDOM",
["source_id"] = sourceID
})
	else
		newSavingThrow = bit.bor(newSavingThrow, 0x4)
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
--	if IEex_GetActorSpellState(sourceID, 236) then
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
--	end
--	if IEex_GetActorSpellState(targetID, 237) then
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
--	end
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
	local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
	local savebonus = IEex_ReadDword(effectData + 0x40)
	local saveBonusLevel = IEex_ReadByte(effectData + 0x45, 0x0)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local feintFeatID = ex_feat_name_id["ME_FEINT"]
	local feintFeatCount = 0
	if feintFeatID ~= nil then
		feintFeatCount = IEex_ReadByte(sourceData + 0x744 + feintFeatID, 0x0)
	end
	savebonus = savebonus + IEex_ReadByte(sourceData + 0x7B6, 0x0) + math.floor((IEex_GetActorStat(sourceID, 38) - 10) / 2)
--	if IEex_GetActorSpellState(sourceID, 236) then
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
--	end
--	if IEex_GetActorSpellState(targetID, 237) then
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
--	end
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
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = 4,
["parameter2"] = 183,
["savebonus"] = savebonus,
["parent_resource"] = "USFEINTA",
["source_target"] = targetID,
["source_id"] = sourceID
})
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
	local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
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
--	if IEex_GetActorSpellState(sourceID, 241) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x20)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 241 then
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
				if (thespecial >= 3 and thespecial <= 5 and theparameter1 ~= 41) then
					if bit.band(thesavingthrow, 0x20000) == 0 then
						handsUsed = handsUsed + 1
					else
						handsUsed = handsUsed + 2
					end
				end
			end
		end)
--	end
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
	local stateValue = bit.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
	if IEex_CompareActorAllegiances(sourceID, targetID) < 1 or bit.band(stateValue, 0x29) == 0 then
		newSavingThrow = bit.bor(newSavingThrow, 0x8)
	end
	savebonus = savebonus + math.floor(IEex_GetActorStat(sourceID, 95) / 2) + math.floor((saveBonusStatBonus - 10) / 2)
	if handsUsed == 0 then
		savebonus = savebonus + 4
	end
--	if IEex_GetActorSpellState(sourceID, 236) then
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
--	end
--	if IEex_GetActorSpellState(targetID, 237) then
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
--	end
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
	local savingthrow = bit.band(IEex_ReadDword(effectData + 0x3C), 0xFFFFFFE3)
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
		newSavingThrow = bit.bor(newSavingThrow, 0x8)
	else
		newSavingThrow = bit.bor(newSavingThrow, 0x4)
	end
	savebonus = savebonus + math.floor(IEex_GetActorStat(sourceID, 95) / 2) + math.floor((saveBonusStatBonus - 10) / 2)
--	if IEex_GetActorSpellState(sourceID, 236) then
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
--	end
--	if IEex_GetActorSpellState(targetID, 237) then
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
--	end
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
		bonusStatValue = IEex_GetActorStat(sourceID, bonusStat)
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
	["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
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
	["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
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
["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
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
	if bit.band(special, 0x1) > 0 then
		additionalDC = additionalDC + IEex_GetActorStat(sourceID, 25)
	end
	if bit.band(special, 0x2) > 0 then
		additionalDC = additionalDC + IEex_GetActorStat(sourceID, 25) * 2
	end
	if bit.band(special, 0x4) > 0 then
		additionalDC = additionalDC + IEex_GetActorStat(sourceID, 40)
	end
	if bit.band(special, 0x8) > 0 then
		additionalDC = additionalDC + IEex_GetActorStat(sourceID, 40) * 2
	end
	if bit.band(special, 0x10) > 0 then
		additionalDC = additionalDC + IEex_GetActorStat(sourceID, 38)
	end
	if bit.band(special, 0x20) > 0 then
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

function MEWOFOST(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	if not IEex_IsSprite(IEex_ReadDword(effectData + 0x10C), false) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local wallAlreadyExists = false
	IEex_IterateIDs(IEex_ReadDword(creatureData + 0x12), 0, true, true, function(id)
		local projectileData = IEex_GetActorShare(id)
		if IEex_ReadWord(projectileData + 0x6E, 0x0) == 303 then
			wallAlreadyExists = true
		end
	end)
	if spellRES ~= "" and not wallAlreadyExists then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 6,
["duration"] = IEex_GetGameTick() + IEex_ReadDword(effectData + 0x44),
["resource"] = spellRES,
["parent_resource"] = spellRES,
["casterlvl"] = IEex_ReadDword(effectData + 0xC4),
["internal_flags"] = IEex_ReadDword(effectData + 0xC8),
["target_x"] = IEex_ReadDword(effectData + 0x84),
["target_y"] = IEex_ReadDword(effectData + 0x88),
["source_target"] = targetID,
["source_id"] = IEex_ReadDword(effectData + 0x10C),
})
	end
end


ex_key_angles = {-90, -67.5, -45, -22.5, 0, 22.5, 45, 67.5, 90}
ex_woforc_positions = {0, {}}
function MEWOFORC(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 0x1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local creatureRES = IEex_ReadLString(effectData + 0x18, 8)
	if creatureRES == "" then
		creatureRES = "USWOFORC"
	end
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local numCreatures = IEex_ReadWord(effectData + 0x44, 0x0)
	if numCreatures == 0 then return end
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local wallAnimation = ""
	local wallDeltaBase = IEex_ReadWord(effectData + 0x46, 0x0)
	if wallDeltaBase == 0 then
		wallDeltaBase = 30
	end
	local sourceX, sourceY = IEex_GetActorLocation(sourceID)
	local targetX = IEex_ReadDword(effectData + 0x84)
	local targetY = IEex_ReadDword(effectData + 0x88)
	local casterOrientation = IEex_ReadByte(creatureData + 0x5380, 0x0)
	if casterOrientation > 8 then
		casterOrientation = casterOrientation - 8
	end
	local orientation = 0

	local wallAlreadyExists = false
	IEex_IterateIDs(IEex_ReadDword(creatureData + 0x12), 0, true, true, function(id)
		local projectileData = IEex_GetActorShare(id)
		if IEex_ReadWord(projectileData + 0x6E, 0x0) == 303 then
			orientation = IEex_ReadWord(IEex_ReadDword(projectileData + 0x192) + 0xC6, 0x0)
			if orientation == 0 and casterOrientation ~= 0 then
				orientation = casterOrientation
			elseif targetX > sourceX then
				orientation = 8 - orientation
			end

		end
	end)
	
	local duration = IEex_ReadDword(effectData + 0x5C)
	local timing = 0
	if duration == 0 then
		timing = 9
		duration = 60
	end
	if bit.band(savingthrow, 0x10000000) > 0 then
		sourceX = IEex_ReadDword(effectData + 0x7C)
		sourceY = IEex_ReadDword(effectData + 0x80)
	end
	local deltaX = targetX - sourceX
	local deltaY = targetY - sourceY
	local angle = ex_key_angles[orientation + 1]
	local wallDeltaX = math.floor(math.sin(math.rad(angle)) * wallDeltaBase * -1)
	local wallDeltaY = math.floor(math.cos(math.rad(angle)) * wallDeltaBase)
	local areaRES = ""
	if IEex_ReadDword(creatureData + 0x12) > 0 then
		areaRES = IEex_ReadLString(IEex_ReadDword(creatureData + 0x12), 8)
	end
	local resWrapper = IEex_DemandRes(areaRES .. "SR", "BMP")
	if not resWrapper:isValid() then
		resWrapper:free()
		return
	end
	local bitmapData = resWrapper:getData()
	local fileSize = IEex_ReadDword(bitmapData + 0x2)
	local dataOffset = IEex_ReadDword(bitmapData + 0xA)
	local bitmapX = IEex_ReadDword(bitmapData + 0x12)
	local bitmapY = IEex_ReadDword(bitmapData + 0x16)
	local padding = (bitmapX / 2) % 4
	local areaX = bitmapX * 16
	local areaY = bitmapY * 12
	local pixelSizeX = 16
	local pixelSizeY = 12
	local current = 0
	local currentA = 0
	local currentB = 0
	local currentX = 0
	local currentY = 0
	local x = 0
	local y = 0
	local trueBitmapX = math.floor(bitmapX / 2) + padding
	ex_woforc_positions = {0, {}}
	if numCreatures % 2 == 1 then
--[[
		x = math.floor(targetX / pixelSizeX)
		y = bitmapY - math.floor((targetY + 7) / pixelSizeY)
		if y < 1 then
			y = 1
		end
		current = IEex_ReadByte(bitmapData + dataOffset + y * trueBitmapX + math.floor(x / 2), 0x0)
		if ex_default_terrain_table_1[math.floor(current / 16) + 1] ~= -1 and ex_default_terrain_table_1[(current % 16) + 1] ~= -1 then
			IEex_Eval('CreateCreature(\"' .. creatureRES .. '\", \"USWOFORC\", [' .. targetX .. '.' .. targetY + 7 .. '], ' .. 0, sourceID)
		end
--]]
		table.insert(ex_woforc_positions[2], {targetX, targetY + 7})
		IEex_Eval('CreateCreature(\"' .. creatureRES .. '\", \"USWOFORC\", [' .. targetX .. '.' .. targetY + 7 .. '], ' .. 0, sourceID)
--[[
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 67,
["target"] = 2,
["timing"] = timing,
["duration"] = duration,
["parameter2"] = 2,
["resource"] = creatureRES,
["vvcresource"] = vvcresource,
["casterlvl"] = casterlvl,
["source_target"] = sourceID,
["source_id"] = sourceID,
["source_x"] = sourceX,
["source_y"] = sourceY,
["target_x"] = targetX,
["target_y"] = targetY
})
--]]
		numCreatures = math.floor((numCreatures - 1) / 2)
		for i = 1, numCreatures, 1 do
--[[
			x = math.floor((targetX + (wallDeltaX * i)) / pixelSizeX)
			y = bitmapY - math.floor((targetY + (wallDeltaY * i) + 7) / pixelSizeY)
			if y < 1 then
				y = 1
			end
			current = IEex_ReadByte(bitmapData + dataOffset + y * trueBitmapX + math.floor(x / 2), 0x0)
			if ex_default_terrain_table_1[math.floor(current / 16) + 1] ~= -1 and ex_default_terrain_table_1[(current % 16) + 1] ~= -1 then
				IEex_Eval('CreateCreature(\"' .. creatureRES .. '\", \"USWOFORC\", [' .. targetX + (wallDeltaX * i) .. '.' .. targetY + (wallDeltaY * i) + 7 .. '], ' .. 0, sourceID)
			end
--]]
			table.insert(ex_woforc_positions[2], {targetX + (wallDeltaX * i), targetY + (wallDeltaY * i) + 7})
			IEex_Eval('CreateCreature(\"' .. creatureRES .. '\", \"USWOFORC\", [' .. targetX + (wallDeltaX * i) .. '.' .. targetY + (wallDeltaY * i) + 7 .. '], ' .. 0, sourceID)

			
--[[
			IEex_ApplyEffectToActor(sourceID, {
	["opcode"] = 67,
	["target"] = 2,
	["timing"] = timing,
	["duration"] = duration,
	["parameter2"] = 2,
	["resource"] = creatureRES,
	["vvcresource"] = vvcresource,
	["casterlvl"] = casterlvl,
	["source_target"] = sourceID,
	["source_id"] = sourceID,
	["source_x"] = sourceX,
	["source_y"] = sourceY,
	["target_x"] = targetX + (wallDeltaX * i),
	["target_y"] = targetY + (wallDeltaY * i)
	})
--]]

--[[
			x = math.floor((targetX - (wallDeltaX * i)) / pixelSizeX)
			y = bitmapY - math.floor((targetY - (wallDeltaY * i) + 7) / pixelSizeY)
			if y < 1 then
				y = 1
			end
			current = IEex_ReadByte(bitmapData + dataOffset + y * trueBitmapX + math.floor(x / 2), 0x0)
			if ex_default_terrain_table_1[math.floor(current / 16) + 1] ~= -1 and ex_default_terrain_table_1[(current % 16) + 1] ~= -1 then
				IEex_Eval('CreateCreature(\"' .. creatureRES .. '\", \"USWOFORC\", [' .. targetX - (wallDeltaX * i) .. '.' .. targetY - (wallDeltaY * i) + 7 .. '], ' .. 0, sourceID)
			end
--]]
			table.insert(ex_woforc_positions[2], {targetX - (wallDeltaX * i), targetY - (wallDeltaY * i) + 7})
			IEex_Eval('CreateCreature(\"' .. creatureRES .. '\", \"USWOFORC\", [' .. targetX - (wallDeltaX * i) .. '.' .. targetY - (wallDeltaY * i) + 7 .. '], ' .. 0, sourceID)
--[[
			IEex_ApplyEffectToActor(sourceID, {
	["opcode"] = 67,
	["target"] = 2,
	["timing"] = timing,
	["duration"] = duration,
	["parameter2"] = 2,
	["resource"] = creatureRES,
	["vvcresource"] = vvcresource,
	["casterlvl"] = casterlvl,
	["source_target"] = sourceID,
	["source_id"] = sourceID,
	["source_x"] = sourceX,
	["source_y"] = sourceY,
	["target_x"] = targetX - (wallDeltaX * i),
	["target_y"] = targetY - (wallDeltaY * i)
	})
--]]
		end
	else
		for i = 1, numCreatures, 1 do
			table.insert(ex_woforc_positions[2], {targetX + math.floor(wallDeltaX / 2) + (wallDeltaX * i), targetY + math.floor(wallDeltaY / 2) + (wallDeltaY * i) + 7})
			IEex_Eval('CreateCreature(\"' .. creatureRES .. '\", \"USWOFORC\", [' .. targetX + math.floor(wallDeltaX / 2) + (wallDeltaX * i) .. '.' .. targetY + math.floor(wallDeltaY / 2) + (wallDeltaY * i) + 7 .. '], ' .. 0, sourceID)
--[[
			IEex_ApplyEffectToActor(sourceID, {
	["opcode"] = 67,
	["target"] = 2,
	["timing"] = timing,
	["duration"] = duration,
	["parameter2"] = 2,
	["resource"] = creatureRES,
	["vvcresource"] = vvcresource,
	["casterlvl"] = casterlvl,
	["source_target"] = sourceID,
	["source_id"] = sourceID,
	["source_x"] = sourceX,
	["source_y"] = sourceY,
	["target_x"] = targetX + math.floor(wallDeltaX / 2) + (wallDeltaX * i),
	["target_y"] = targetY + math.floor(wallDeltaY / 2) + (wallDeltaY * i)
	})
--]]
			table.insert(ex_woforc_positions[2], {targetX - math.floor(wallDeltaX / 2) - (wallDeltaX * i), targetY - math.floor(wallDeltaY / 2) - (wallDeltaY * i) + 7})
			IEex_Eval('CreateCreature(\"' .. creatureRES .. '\", \"USWOFORC\", [' .. targetX - math.floor(wallDeltaX / 2) - (wallDeltaX * i) .. '.' .. targetY - math.floor(wallDeltaY / 2) - (wallDeltaY * i) + 7 .. '], ' .. 0, sourceID)
--[[
			IEex_ApplyEffectToActor(sourceID, {
	["opcode"] = 67,
	["target"] = 2,
	["timing"] = timing,
	["duration"] = duration,
	["parameter2"] = 2,
	["resource"] = creatureRES,
	["vvcresource"] = vvcresource,
	["casterlvl"] = casterlvl,
	["source_target"] = sourceID,
	["source_id"] = sourceID,
	["source_x"] = sourceX,
	["source_y"] = sourceY,
	["target_x"] = targetX - math.floor(wallDeltaX / 2) - (wallDeltaX * i),
	["target_y"] = targetY - math.floor(wallDeltaY / 2) - (wallDeltaY * i)
	})
--]]
		end
	end
	resWrapper:free()
end

function MEWOFOR2(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
--	if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "MEWOFOR2", 5) then return end
	local wallAlreadyExists = false
	IEex_IterateIDs(IEex_ReadDword(creatureData + 0x12), 0, true, true, function(id)
		local projectileData = IEex_GetActorShare(id)
		if IEex_ReadWord(projectileData + 0x6E, 0x0) == 303 then
			wallAlreadyExists = true
		end
	end)
	local extraFlags = IEex_ReadDword(creatureData + 0x740)
	if bit.band(extraFlags, 0x800000) == 0 and IEex_GetGameTick() - IEex_ReadDword(effectData + 0x68) >= 1 then
		IEex_WriteDword(creatureData + 0x740, bit.bor(extraFlags, 0x800000))
		local nextPosition = ex_woforc_positions[1] + 1
		local numPositions = #ex_woforc_positions[2]
		ex_woforc_positions[1] = nextPosition
		if nextPosition <= numPositions then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 124,
["target"] = 2,
["timing"] = 1,
["savingthrow"] = 0x10000,
["target_x"] = ex_woforc_positions[2][nextPosition][1],
["target_y"] = ex_woforc_positions[2][nextPosition][2],
["source_target"] = targetID,
["source_id"] = targetID,
})
		end
	elseif not wallAlreadyExists then
		IEex_WriteByte(creatureData + 0x25, 105)
	end
end

function MECRIT(effectData, creatureData)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
--	if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "MECRIT", 5) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	if bit.band(savingthrow, 0x100000) > 0 then return end
	local matchItemType = IEex_ReadWord(effectData + 0x44, 0x0)
	local totalUses = IEex_ReadSignedWord(effectData + 0x46, 0x0)
	local uses = IEex_ReadSignedWord(effectData + 0x5C, 0x0)
	if totalUses > 0 and uses >= totalUses then return end
	if matchItemType > 0 or bit.band(savingthrow, 0x70000) > 0 then
		local weaponSlot = IEex_ReadByte(creatureData + 0x4BA4, 0x0)
		local weaponHeader = IEex_ReadByte(creatureData + 0x4BA6, 0x0)
		local slotData = IEex_ReadDword(creatureData + 0x4AD8 + weaponSlot * 0x4)
		if ((weaponSlot >= 11 and weaponSlot <= 14) and bit.band(savingthrow, 0x20000) > 0) or slotData <= 0 then return end
		local weaponRES = IEex_ReadLString(slotData + 0xC, 8)
		local resWrapper = IEex_DemandRes(weaponRES, "ITM")
		if resWrapper:isValid() then
			local itemData = resWrapper:getData()
			local numHeaders = IEex_ReadSignedWord(itemData + 0x68, 0x0)
			if weaponHeader >= numHeaders then
				weaponHeader = 0
			end
			local itemType = IEex_ReadWord(itemData + 0x1C, 0x0)
			local equippedAppearance = IEex_ReadLString(itemData + 0x22, 2)
			local headerType = IEex_ReadByte(itemData + 0x82 + weaponHeader * 0x38, 0x0)
			if (bit.band(savingthrow, 0x10000) > 0 and headerType ~= 1) or (bit.band(savingthrow, 0x20000) > 0 and headerType ~= 2) or (bit.band(savingthrow, 0x40000) > 0 and (headerType ~= 1 or equippedAppearance ~= "" or (itemType ~= 0 and itemType ~= 16 and itemType ~= 19 and itemType ~= 28))) or (matchItemType > 0 and matchItemType ~= special) then
				resWrapper:free()
				return
			end
		end
		resWrapper:free()
	end
	IEex_WriteByte(creatureData + 0x936, IEex_ReadByte(creatureData + 0x936, 0x0) + parameter1)
	IEex_WriteByte(creatureData + 0x178E, IEex_ReadByte(creatureData + 0x178E, 0x0) + parameter1)
end
ex_stat_offset = {
[1] = {0x924, 2},
[3] = {0x92E, 2},
[4] = {0x930, 2},
[5] = {0x932, 2},
[6] = {0x934, 2},
[7] = {0x938, 2},
[8] = {0x93A, 2},
[9] = {0x93C, 2},
[10] = {0x93E, 2},
[11] = {0x940, 2},
[12] = {0x96C, 1},
[14] = {0x942, 2},
[15] = {0x944, 2},
[16] = {0x946, 2},
[17] = {0x948, 2},
[18] = {0x94A, 2},
[19] = {0x94C, 2},
[20] = {0x94E, 2},
[21] = {0x950, 2},
[22] = {0x952, 2},
[23] = {0x954, 2},
[24] = {0x956, 2},
[25] = {0x964, 1},
[26] = {0x96E, 1},
[27] = {0x96D, 1},
[28] = {0x970, 1},
[29] = {0x96F, 1},
[33] = {0x973, 1},
[36] = {0x974, 2},
[38] = {0x976, 2},
[39] = {0x978, 2},
[40] = {0x97A, 2},
[41] = {0x97C, 2},
[42] = {0x97E, 2},
[43] = {0x980, 4},
[44] = {0x984, 4},
[50] = {0x9A6, 2},
[51] = {0x9A8, 2},
[52] = {0x9AA, 2},
[53] = {0x9AC, 2},
[54] = {0x9AE, 2},
[55] = {0x9B0, 2},
[56] = {0x9B2, 2},
[71] = {0x9D4, 2},
[72] = {0x9D6, 2},
[73] = {0x9D8, 2},
[74] = {0x9DA, 2},
[75] = {0x9DC, 4},
[76] = {0x9E0, 4},
[77] = {0x9E4, 2},
[78] = {0x9E6, 2},
[79] = {0x9E8, 2},
[80] = {0x9EA, 2},
[81] = {0x9EC, 4},
[82] = {0x9F0, 4},
[83] = {0x9F4, 4},
[84] = {0x9F8, 1},
[85] = {0x9FC, 1},
[86] = {0xA00, 4},
[87] = {0xA04, 4},
[90] = {0x96A, 1},
[94] = {0x972, 1},
[95] = {0x966, 1},
[96] = {0x967, 1},
[97] = {0x968, 1},
[98] = {0x969, 1},
[99] = {0x96A, 1},
[100] = {0x96B, 1},
[101] = {0x96C, 1},
[102] = {0x96D, 1},
[103] = {0x96E, 1},
[104] = {0x96F, 1},
[105] = {0x970, 1},
[106] = {0x971, 1},
[200] = {0x5C0, 2}, --Current HP
[201] = {0x5C4, 4}, --Animation
[202] = {0x758, 1}, --Base Damage Reduction
[203] = {0x774, 1}, --Proficiency: Bow
[204] = {0x775, 1}, --Proficiency: Crossbow
[205] = {0x776, 1}, --Proficiency: Missile
[206] = {0x777, 1}, --Proficiency: Axe
[207] = {0x778, 1}, --Proficiency: Mace
[208] = {0x779, 1}, --Proficiency: Flail
[209] = {0x77A, 1}, --Proficiency: Polearm
[210] = {0x77B, 1}, --Proficiency: Hammer
[211] = {0x77C, 1}, --Proficiency: Quarterstaff
[212] = {0x77D, 1}, --Proficiency: Greatsword
[213] = {0x77E, 1}, --Proficiency: Large Sword
[214] = {0x77F, 1}, --Proficiency: Small Blade
[215] = {0x780, 1}, --Toughness
[216] = {0x781, 1}, --Armored Arcana
[217] = {0x782, 1}, --Cleave
[218] = {0x783, 1}, --Armor Proficiency
[219] = {0x784, 1}, --Spell Focus: Enhantment
[220] = {0x785, 1}, --Spell Focus: Evocation
[221] = {0x786, 1}, --Spell Focus: Necromancy
[222] = {0x787, 1}, --Spell Focus: Transmutation
[223] = {0x788, 1}, --Spell Penetration
[224] = {0x789, 1}, --Extra Rage
[225] = {0x78A, 1}, --Extra Wild Shape
[226] = {0x78B, 1}, --Extra Smiting
[227] = {0x78C, 1}, --Extra Turning
[228] = {0x78D, 1}, --Proficiency: Bastard Sword
[229] = {0xA65, 1}, --Animal Empathy
[230] = {0xA66, 1}, --Bluff
[231] = {0xA67, 1}, --Concentration
[232] = {0xA68, 1}, --Diplomacy
[233] = {0xA69, 1}, --Disable Device
[234] = {0xA6B, 1}, --Intimidate
[235] = {0xA71, 1}, --Spellcraft
[236] = {0x7F6, 1}, --Challenge Rating
[237] = {0x936, 2}, --Critical Hit Bonus
[238] = {0x926, 2}, --Armor AC Bonus
[239] = {0x928, 2}, --Deflection AC Bonus
[240] = {0x92A, 2}, --Shield AC Bonus
[241] = {0x92C, 2}, --Generic AC Bonus
[242] = {0x4C53, 1}, --Modal State
[243] = {0x4C54, 4}, --Expertise
[244] = {0x4C58, 4}, --Power Attack
[245] = {0x72EA, 1}, --Movement Speed
[246] = {0x720, 2}, --Height
[252] = {0xA60, 1}, --Mirror Images Remaining
}
function MEMODSTA(effectData, creatureData)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
--	if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "MECRIT", 5) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local special = IEex_ReadDword(effectData + 0x44)
	local statValue = 0x7FFFFFFF
	if ex_stat_offset[special] ~= nil then
		if ex_stat_offset[special][2] == 1 then
			statValue = IEex_ReadSignedByte(creatureData + ex_stat_offset[special][1], 0x0)
			if parameter2 == 0 then
				statValue = statValue + parameter1
			elseif parameter2 == 1 then
				statValue = parameter1
			elseif parameter2 == 2 then
				statValue = math.floor(statValue * parameter1 / 100)
			end
			IEex_WriteByte(creatureData + ex_stat_offset[special][1], statValue)
			IEex_WriteByte(creatureData + ex_stat_offset[special][1] + 0xE58, statValue)
		elseif ex_stat_offset[special][2] == 2 then
			statValue = IEex_ReadSignedWord(creatureData + ex_stat_offset[special][1], 0x0)
			if parameter2 == 0 then
				statValue = statValue + parameter1
			elseif parameter2 == 1 then
				statValue = parameter1
			elseif parameter2 == 2 then
				statValue = math.floor(statValue * parameter1 / 100)
			end
			IEex_WriteWord(creatureData + ex_stat_offset[special][1], statValue)
			IEex_WriteWord(creatureData + ex_stat_offset[special][1] + 0xE58, statValue)
		elseif ex_stat_offset[special][2] == 4 then
			statValue = IEex_ReadDword(creatureData + ex_stat_offset[special][1])
			if parameter2 == 0 then
				statValue = statValue + parameter1
			elseif parameter2 == 1 then
				statValue = parameter1
			elseif parameter2 == 2 then
				statValue = math.floor(statValue * parameter1 / 100)
			end
			IEex_WriteDword(creatureData + ex_stat_offset[special][1], statValue)
			IEex_WriteDword(creatureData + ex_stat_offset[special][1] + 0xE58, statValue)
		end
	end
	if special >= 36 and special <= 42 and statValue <= 0 then
		IEex_WriteDword(effectData + 0x110, 1)
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 13,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 0x4,
["parent_resource"] = IEex_ReadLString(effectData + 0x90, 8),
["source_id"] = IEex_ReadDword(effectData + 0x10C)
})
	end
end
function MEMODSKL(effectData, creatureData)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
--	if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "MECRIT", 5) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local special = IEex_ReadDword(effectData + 0x44)
	if special > 15 then return end
	if special >= 0 then
		if IEex_ReadSignedByte(creatureData + 0x7B4 + special, 0x0) <= 0 then
			if tonumber(IEex_2DAGetAtStrings("SKILLS", "UNTRAINED", ex_skill_name[special])) == 0 then return end
		end
		IEex_WriteByte(creatureData + 0xA64 + special, IEex_ReadSignedByte(creatureData + 0xA64 + special, 0x0) + parameter1)
	else
		for i = 0, 15, 1 do
			if IEex_ReadSignedByte(creatureData + 0x7B4 + i, 0x0) > 0 or tonumber(IEex_2DAGetAtStrings("SKILLS", "UNTRAINED", ex_skill_name[i])) == 1 then
				IEex_WriteByte(creatureData + 0xA64 + i, IEex_ReadSignedByte(creatureData + 0xA64 + i, 0x0) + parameter1)
			end
		end
	end
end
--[[
function MEMODMSL(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local maxLevel = IEex_ReadDword(effectData + 0x1C)
	if maxLevel > 9 then
		maxLevel = 9
	elseif maxLevel <= 0 then
		maxLevel = 1
	end
	local minLevel = IEex_ReadDword(effectData + 0x44)
	if minLevel > 9 then
		minLevel = 9
	elseif minLevel <= 0 then
		minLevel = 1
	end
	if maxLevel < minLevel then
		maxLevel = minLevel
	end
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local casterTypes = {}
	for i = 1, 7, 1 do
		if bit.band(savingthrow, 2 ^ (i + 15)) > 0 then
			table.insert(casterTypes, i)
		end
	end
	if bit.band(savingthrow, 0x7F0000) == 0 then
		casterTypes = {1, 2, 3, 4, 5, 6, 7}
	end
	for k, cType in ipairs(casterTypes) do
		for level = minLevel, maxLevel, 1 do
			local offset = creatureData + 0x4284 + (cType - 1) * 0x100 + (level - 1) * 0x1C
			local totalCount = IEex_ReadDword(offset + 0x14)
			local sorcererCastableCount = IEex_ReadDword(offset + 0x18)
			if totalCount > 0 or bit.band(savingthrow, 0x1000000) > 0 then
				totalCount = totalCount + parameter1
				if totalCount < 0 then
					totalCount = 0
				end
				IEex_WriteDword(offset + 0x14, totalCount)
				local currentSpell = IEex_ReadDword(offset + 0x4)
				local lastSpell = IEex_ReadDword(offset + 0x8)

				if cType == 1 or cType == 6 then
					if sorcererCastableCount > totalCount then
						IEex_WriteDword(offset + 0x18, totalCount)
					end
					while currentSpell ~= lastSpell do
						local currentMemorizedCount = IEex_ReadDword(currentSpell + 0x8)
						IEex_DS(currentMemorizedCount)
						currentMemorizedCount = currentMemorizedCount + parameter1
						if currentMemorizedCount < 0 then
							currentMemorizedCount = 0
						end
						IEex_WriteDword(currentSpell + 0x8, currentMemorizedCount)
						currentSpell = currentSpell + 0x10

					end
				end
			end
		end
	end
end
--]]

function MEBARBDR(effectData, creatureData)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
--	if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "MECRIT", 5) then return end
	local barbarianLevel = IEex_GetActorStat(targetID, 96)
	local barbarianDamageResistance = math.floor((barbarianLevel + 1) / 3)
	local applyExtraResistance = false
	local slotData = IEex_ReadDword(creatureData + 0x4ADC)
	if slotData <= 0 then return end
	local armorRES = IEex_ReadLString(slotData + 0xC, 8)
	local resWrapper = IEex_DemandRes(armorRES, "ITM")
	if resWrapper:isValid() then
		local itemData = resWrapper:getData()
		local itemType = IEex_ReadWord(itemData + 0x1C, 0x0)
		if itemType == 62 or itemType == 66 or itemType == 68 then
			applyExtraResistance = true
		end
	end
	resWrapper:free()
	if not applyExtraResistance then return end
	IEex_WriteWord(creatureData + 0x950, IEex_ReadSignedWord(creatureData + 0x950, 0x0) + barbarianDamageResistance)
	IEex_WriteWord(creatureData + 0x952, IEex_ReadSignedWord(creatureData + 0x952, 0x0) + barbarianDamageResistance)
	IEex_WriteWord(creatureData + 0x954, IEex_ReadSignedWord(creatureData + 0x954, 0x0) + barbarianDamageResistance)
	IEex_WriteWord(creatureData + 0x956, IEex_ReadSignedWord(creatureData + 0x956, 0x0) + barbarianDamageResistance)
end

--[[
function IEex_EvaluatePersistentEffects(actorID)
	if not IEex_IsSprite(actorID, false) then return end
	local creatureData = IEex_GetActorShare(actorID)
	local tick = IEex_GetGameTick()
	local previousTick = ex_last_evaluation_tick[actorID]
	if previousTick == nil or tick ~= previousTick then
		ex_last_evaluation_tick[actorID] = tick
--	local temporaryFlags = IEex_ReadWord(creatureData + 0x9FA, 0x0)
--	if bit.band(temporaryFlags, 0x1) == 0 then
--		IEex_WriteWord(creatureData + 0x9FA, bit.bor(temporaryFlags, 0x1))
		local persistentEffectsList = {}
		
		IEex_IterateActorEffects(actorID, function(eData)
			local theperiod = 1
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local thetime_applied = IEex_ReadDword(eData + 0x68)
			local newopcode = 402
			local newparameter1 = 1
			local newparameter2 = 0
			local addEffect = false
			if theopcode == 25 or theopcode == 98 then
				addEffect = true
				if theopcode == 25 then
					newopcode = 12
					newparameter2 = 0x200000
				elseif theopcode == 98 then
					newopcode = 17
				end
				if theparameter2 == 1 or theparameter2 == 2 or theparameter2 == 4 then
					newparameter1 = theparameter1
				end
				if theparameter2 == 3 then
					theperiod = theparameter1
				elseif theparameter2 == 4 then
					theperiod = 7
				end
			end
			if theopcode == 434 then
				addEffect = true
				newparameter1 = 0
				theperiod = theparameter1
			end

			if addEffect and (tick - thetime_applied) % (theperiod * 15) == 0 and (tick > thetime_applied + 1 or theopcode == 434) then
				table.insert(persistentEffectsList, {
["opcode"] = newopcode,
["parameter1"] = newparameter1,
["parameter2"] = newparameter2,
["resource"] = theresource,
["parent_resource"] = IEex_ReadLString(eData + 0x94, 8),
["casterlvl"] = IEex_ReadDword(eData + 0xC8),
["source_id"] = IEex_ReadDword(eData + 0x110),
})
			end
		end)
		for k, effect in ipairs(persistentEffectsList) do
			IEex_ApplyEffectToActor(actorID, {
["opcode"] = effect["opcode"],
["target"] = 2,
["parameter1"] = effect["parameter1"],
["parameter2"] = effect["parameter2"],
["timing"] = 1,
["resource"] = effect["resource"],
["parent_resource"] = effect["parent_resource"],
["casterlvl"] = effect["casterlvl"],
["source_id"] = effect["source_id"],
})
		end
		local repermCounter = IEex_ReadSignedByte(creatureData + 0x731, 0x0)
		if repermCounter == -1 then
			repermCounter = 0
		end
		repermCounter = repermCounter + 1
		if repermCounter >= 15 then
			repermCounter = 0
			IEex_WriteByte(creatureData + 0x731, repermCounter)
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["resource"] = "MEREPERM",
["source_id"] = sourceID
})
		else
			IEex_WriteByte(creatureData + 0x731, repermCounter)
		end
	end
end
--]]
function MESPLOPP(actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	if actionID == 31 or actionID == 95 or actionID == 113 or actionID == 114 or actionID == 191 or actionID == 192 then
		ex_attopp_casting[sourceID] = {}
	end
end

IEex_AddActionHookGlobal("MESPLOPP")


ex_superfast_attack_cut = {
[16] = {1, 1, 1, 1, 1, 1, 1},
[17] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
[18] = {2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
[19] = {2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
[20] = {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1},
[21] = {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1},
[22] = {3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
[23] = {3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
[24] = {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
[25] = {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2},
[26] = {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2},
[27] = {4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
[28] = {4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
[29] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
[30] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
[31] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
[32] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
[33] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3},
[34] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3},
[35] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3},
[36] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[37] = {5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[38] = {5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[39] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[40] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[41] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[42] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[43] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[44] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[45] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[46] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[47] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[48] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[49] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
[50] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5},
}
ex_attopp_count = {}
ex_attopp_timer = {}
ex_attopp_repeat_timer = {}
ex_attopp_casting = {}
ex_attopp_target = {}

function IEex_CheckMonkAttackBonus(creatureData)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local fixMonkAttackBonus = false
	local monkAttackBonusDisabled = false
	local monkLevel = IEex_GetActorStat(targetID, 101)
	if monkLevel > 0 then
		fixMonkAttackBonus = true
		if IEex_GetActorStat(targetID, 96) > 0 or IEex_GetActorStat(targetID, 97) > 0 or IEex_GetActorStat(targetID, 98) > 0 or IEex_GetActorStat(targetID, 99) > 0 or IEex_GetActorStat(targetID, 100) > 0 or IEex_GetActorStat(targetID, 102) > 0 or IEex_GetActorStat(targetID, 103) > 0 or IEex_GetActorStat(targetID, 104) > 0 or IEex_GetActorStat(targetID, 105) > 1 or IEex_GetActorStat(targetID, 106) > 1 then
			monkAttackBonusDisabled = true
		end
		if IEex_ReadByte(creatureData + 0x4BA4, 0x0) ~= 10 then
			monkAttackBonusDisabled = true
		end
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			local thespecial = IEex_ReadDword(eData + 0x48)
			if theopcode == 288 and theparameter2 == 241 then
				local thegeneralitemcategory = IEex_ReadByte(eData + 0x48, 0x0)
				if thegeneralitemcategory ~= 6 then
					monkAttackBonusDisabled = true
					if (thegeneralitemcategory == 1 and (theparameter1 ~= 67 or not ex_elven_chainmail_counts_as_unarmored)) or thegeneralitemcategory == 3 or (thegeneralitemcategory >= 4 and ex_special_monk_weapon_types[theparameter1] == nil) then
						fixMonkAttackBonus = false
					end
				end
			end
		end)
	end
	return monkAttackBonusDisabled, fixMonkAttackBonus
end

function IEex_CheckMonkACBonus(creatureData)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local fixMonkACBonus = false
	local monkACBonusDisabled = false
	local monkLevel = IEex_GetActorStat(targetID, 101)
	if monkLevel > 0 then
		fixMonkACBonus = true
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			local thespecial = IEex_ReadDword(eData + 0x48)
			if theopcode == 288 and theparameter2 == 241 then
				local thegeneralitemcategory = IEex_ReadByte(eData + 0x48, 0x0)
				if thegeneralitemcategory >= 1 and thegeneralitemcategory <= 3 then
					monkACBonusDisabled = true
					if (thegeneralitemcategory == 1 and (theparameter1 ~= 67 or not ex_elven_chainmail_counts_as_unarmored)) or thegeneralitemcategory == 3 then
						fixMonkACBonus = false
					end
				end
			end
		end)
	end
	return monkACBonusDisabled, fixMonkACBonus
end

function IEex_IncrementAnimationFrame(creatureData, value)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local animationData = IEex_ReadDword(creatureData + 0x50F0)
	local sequence = IEex_ReadDword(creatureData + 0x50F4)
	if sequence == 0 or sequence == 8 or sequence == 11 then
		local animationFrame = IEex_ReadSignedWord(animationData + 0x694, 0x0)
		IEex_WriteWord(animationData + 0x694, animationFrame + value)
		IEex_WriteWord(animationData + 0xA2C, animationFrame + value)
		IEex_WriteWord(animationData + 0xDC4, animationFrame + value)
		IEex_WriteWord(animationData + 0x1236, animationFrame + value)
	elseif sequence == 12 then
		local animationFrame = IEex_ReadSignedWord(animationData + 0x76E, 0x0)
		IEex_WriteWord(animationData + 0x76E, animationFrame + value)
		IEex_WriteWord(animationData + 0xB06, animationFrame + value)
		IEex_WriteWord(animationData + 0xE9E, animationFrame + value)
		IEex_WriteWord(animationData + 0x1310, animationFrame + value)
	elseif sequence == 13 then
		local animationFrame = IEex_ReadSignedWord(animationData + 0x848, 0x0)
		IEex_WriteWord(animationData + 0x848, animationFrame + value)
		IEex_WriteWord(animationData + 0xBE0, animationFrame + value)
		IEex_WriteWord(animationData + 0xF78, animationFrame + value)
		IEex_WriteWord(animationData + 0x13EA, animationFrame + value)
	elseif sequence == 2 or sequence == 3 then
		local animationFrame = IEex_ReadSignedWord(animationData + 0x5BA, 0x0)
		IEex_WriteWord(animationData + 0x5BA, animationFrame + value)
		IEex_WriteWord(animationData + 0x115C, animationFrame + value)
	else
		local animationFrame = IEex_ReadSignedWord(animationData + 0x4E0, 0x0)
		IEex_WriteWord(animationData + 0x4E0, animationFrame + value)
		IEex_WriteWord(animationData + 0x952, animationFrame + value)
		IEex_WriteWord(animationData + 0xCEA, animationFrame + value)
		IEex_WriteWord(animationData + 0x1082, animationFrame + value)
	end
end

function IEex_SetAttackAnimationFrame(creatureData, value)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local animationData = IEex_ReadDword(creatureData + 0x50F0)
	local sequence = IEex_ReadDword(creatureData + 0x50F4)
	if sequence == 0 or sequence == 8 or sequence == 11 then
		IEex_WriteWord(animationData + 0x694, value)
		IEex_WriteWord(animationData + 0xA2C, value)
		IEex_WriteWord(animationData + 0xDC4, value)
		IEex_WriteWord(animationData + 0x1236, value)
	elseif sequence == 12 then
		IEex_WriteWord(animationData + 0x76E, value)
		IEex_WriteWord(animationData + 0xB06, value)
		IEex_WriteWord(animationData + 0xE9E, value)
		IEex_WriteWord(animationData + 0x1310, value)
	elseif sequence == 13 then
		IEex_WriteWord(animationData + 0x848, value)
		IEex_WriteWord(animationData + 0xBE0, value)
		IEex_WriteWord(animationData + 0xF78, value)
		IEex_WriteWord(animationData + 0x13EA, value)
	end
end

function MEAPRBON(effectData, creatureData)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
--	if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "MEAPRBON", 5) then return end
	IEex_ApplyStatScaling(targetID)
	local monkLevel = IEex_GetActorStat(targetID, 101)
	local baseAPR = IEex_ReadByte(creatureData + 0x5ED, 0x0)
	if monkLevel > 0 then
--		if baseAPR < 4 then
			local monkAttackBonusDisabled, fixMonkAttackBonus = IEex_CheckMonkAttackBonus(creatureData)
			local trueBaseAPR = tonumber(IEex_2DAGetAtStrings("BAATMKU", "NUM_ATTACKS", tostring(monkLevel)))
			baseAPR = math.floor((IEex_GetActorBaseAttackBonus(targetID, false) - 1) / 5) + 1
			if baseAPR > 4 then
				baseAPR = 4
			end
			if trueBaseAPR > 4 then
				trueBaseAPR = 4
			end
			if monkAttackBonusDisabled and fixMonkAttackBonus then
				if trueBaseAPR > baseAPR then
					IEex_WriteByte(creatureData + 0x5ED, trueBaseAPR)
				end
			end
			local trueAPR = trueBaseAPR
			local weaponSlot = IEex_ReadByte(creatureData + 0x4BA4, 0x0)
			local slotData = IEex_ReadDword(creatureData + 0x4AD8 + weaponSlot * 0x4)
			local rapidShotEnabled = (IEex_ReadByte(creatureData + 0x4C64, 0x0) > 0)

			if slotData > 0 then
				local weaponRES = IEex_ReadLString(slotData + 0xC, 8)
				if fixMonkAttackBonus or not monkAttackBonusDisabled then
					trueAPR = trueAPR + ex_monk_apr_progression[monkLevel]
					if weaponRES == ex_monk_fist_progression[monkLevel] or weaponRES == ex_incorporeal_monk_fist_progression[monkLevel] or string.sub(weaponRES, 1, 7) == "00MFIST" then
						trueAPR = trueAPR + 1
					end
				end
				if weaponSlot ~= 10 and rapidShotEnabled then
					local resWrapper = IEex_DemandRes(weaponRES, "ITM")
					if resWrapper:isValid() then
						local itemData = resWrapper:getData()
						local numHeaders = IEex_ReadSignedWord(itemData + 0x68, 0x0)
						if weaponHeader >= numHeaders then
							weaponHeader = 0
						end
						local itemType = IEex_ReadWord(itemData + 0x1C, 0x0)
						headerType = IEex_ReadByte(itemData + 0x82 + weaponHeader * 0x38, 0x0)
						if rapidShotEnabled and headerType == 2 and itemType ~= 27 and itemType ~= 31 then
							trueAPR = trueAPR + 1
						end
					end
					resWrapper:free()
				end

			end
			local numWeapons = 0
			IEex_IterateActorEffects(targetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if theopcode == 1 then
					if theparameter2 == 0 then
						trueAPR = trueAPR + theparameter1
					elseif theparameter2 == 1 then
						trueAPR = theparameter1
					elseif theparameter2 == 1 then
						trueAPR = math.floor(trueAPR * theparameter1 / 100)
					end
				elseif theopcode == 288 and theparameter2 == 241 then
					local thegeneralitemcategory = IEex_ReadByte(eData + 0x48, 0x0)
					if thegeneralitemcategory == 5 then
						numWeapons = numWeapons + 1
					end
				end
			end)
			local imptwfFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_IMPROVED_TWO_WEAPON_FIGHTING"], 0x0)
			local usingImptwf = false
			if numWeapons >= 2 then
				trueAPR = trueAPR + 1
				if imptwfFeatCount > 0 and (IEex_GetActorStat(targetID, 103) < 9 or wearingLightArmor or (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 16 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x2) > 0 and bit.band(IEex_ReadDword(creatureData + 0x764), 0x40) > 0)) then
					trueAPR = trueAPR + 1
					usingImptwf = true
					if imptwfFeatCount > 1 and (IEex_GetActorStat(targetID, 103) < 14 or wearingLightArmor or (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 21 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x2) > 0 and bit.band(IEex_ReadDword(creatureData + 0x764), 0x40) > 0)) then
						trueAPR = trueAPR + 1
					end
				end
			end
			if IEex_GetActorSpellState(targetID, 17) then
				trueAPR = trueAPR + 1
			end
			local stateValue = bit.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
			if bit.band(stateValue, 0x8000) > 0 then
				trueAPR = trueAPR + 1
			end
			if bit.band(stateValue, 0x10000) > 0 then
				trueAPR = trueAPR - 1
			end
			if trueAPR > 5 then
				trueAPR = 5
			end
			IEex_WriteWord(creatureData + 0x93A, trueAPR)
			IEex_WriteWord(creatureData + 0x1792, trueAPR)
--		end
		local monkACBonusDisabled, fixMonkACBonus = IEex_CheckMonkACBonus(creatureData)
		if monkACBonusDisabled and fixMonkACBonus then
			local wisdomBonus = math.floor((IEex_GetActorStat(targetID, 39) - 10) / 2)
			IEex_WriteWord(creatureData + 0x92C, IEex_ReadSignedWord(creatureData + 0x92C, 0x0) + wisdomBonus)
		end
	end
	local strengthBonus = math.floor((IEex_GetActorStat(targetID, 36) - 10) / 2)
	local dexterityBonus = math.floor((IEex_GetActorStat(targetID, 40) - 10) / 2)
	if dexterityBonus > strengthBonus then
		local finesseBonus = math.floor(dexterityBonus / 2)
		local race = IEex_ReadByte(creatureData + 0x26, 0x0)
		local subrace = IEex_GetActorStat(targetID, 93)
		local hasWeaponFinesse = (bit.band(IEex_ReadDword(creatureData + 0x764), 0x80) > 0)
		if hasWeaponFinesse or (race == 5 and subrace == 0) then
			local weaponSlot = IEex_ReadByte(creatureData + 0x4BA4, 0x0)
			local weaponHeader = IEex_ReadByte(creatureData + 0x4BA6, 0x0)
			local weaponRES = IEex_GetItemSlotRES(targetID, weaponSlot)
			local weaponWrapper = IEex_DemandRes(weaponRES, "ITM")
			if weaponWrapper:isValid() then
				local itemData = weaponWrapper:getData()
				local itemType = IEex_ReadWord(itemData + 0x1C, 0x0)
				local numHeaders = IEex_ReadSignedWord(itemData + 0x68, 0x0)
				if weaponHeader >= numHeaders then
					weaponHeader = 0
				end
				local headerType = IEex_ReadByte(itemData + 0x82 + weaponHeader * 0x38, 0x0)
				local headerFlags = IEex_ReadDword(itemData + 0xA8 + weaponHeader * 0x38)
				if bit.band(IEex_ReadDword(itemData + 0x18), 0x2) > 0 then
					strengthBonus = math.floor(strengthBonus * 1.5)
				end
				local finesseDifference = finesseBonus - strengthBonus
				if bit.band(headerFlags, 0x1) > 0 then
					if finesseDifference > 0 and ((hasWeaponFinesse and (itemType == 16 or itemType == 19)) or (race == 5 and subrace == 0 and itemType ~= 5 and itemType ~= 15 and itemType ~= 27 and itemType ~= 31) or ((race == 2 or race == 183) and (itemType == 20 or itemType == 69))) then
						IEex_WriteDword(creatureData + 0xA00, IEex_ReadDword(creatureData + 0xA00) + finesseDifference)
					end
					if (race == 2 or race == 183) and (itemType == 20 or itemType == 69) and dexterityBonus - strengthBonus > 0 then
						IEex_WriteByte(creatureData + 0x9F8, IEex_ReadSignedByte(creatureData + 0x9F8, 0x0) + dexterityBonus - strengthBonus)
					end
				end
			end
			weaponWrapper:free()
			if hasWeaponFinesse and weaponSlot >= 43 and weaponSlot <= 49 then
				weaponSlot = weaponSlot + 1
				local offhandRES = IEex_GetItemSlotRES(targetID, weaponSlot)
				local offhandWrapper = IEex_DemandRes(offhandRES, "ITM")
				if offhandWrapper:isValid() then
					local itemData = offhandWrapper:getData()
					local itemType = IEex_ReadWord(itemData + 0x1C, 0x0)
					local numHeaders = IEex_ReadSignedWord(itemData + 0x68, 0x0)
					if numHeaders > 0 then
						local headerType = IEex_ReadByte(itemData + 0x82, 0x0)
						local headerFlags = IEex_ReadDword(itemData + 0xA8)
						if headerType == 1 and bit.band(headerFlags, 0x1) > 0 then
							strengthBonus = math.floor(strengthBonus / 2)
							local finesseDifference = finesseBonus - strengthBonus
							if finesseDifference > 0 and (itemType == 16 or itemType == 19 or ((race == 2 or race == 183) and (itemType == 20 or itemType == 69))) then
								IEex_WriteDword(creatureData + 0xA04, IEex_ReadDword(creatureData + 0xA04) + finesseDifference)
							end
							if (race == 2 or race == 183) and (itemType == 20 or itemType == 69) then
								IEex_WriteByte(creatureData + 0x9FC, IEex_ReadSignedByte(creatureData + 0x9FC, 0x0) + dexterityBonus - strengthBonus)
							end
						end
					end
				end
				offhandWrapper:free()
			end
		end
	end
end
ex_record_attack_stats = {}
ex_record_attack_stats_hidden_difference = {}
ex_record_attacks_made = {}
function IEex_ExtraAttacks(creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local tempFlags = IEex_ReadWord(creatureData + 0x9FA, 0x0)
	local newEvaluation = false
	local attackBonus = IEex_ReadSignedWord(creatureData + 0x938, 0x0)
	local criticalHitBonus = IEex_ReadSignedWord(creatureData + 0x936, 0x0)
	local attackPenaltyIncrement = 5
	if bit.band(tempFlags, 0x2) > 0 and ex_record_attack_stats[targetID] ~= nil then
		attackBonus = ex_record_attack_stats[targetID][1]
		criticalHitBonus = ex_record_attack_stats[targetID][2]
		IEex_WriteWord(creatureData + 0x936, criticalHitBonus)
		IEex_WriteWord(creatureData + 0x938, attackBonus)
		IEex_WriteWord(creatureData + 0x178E, criticalHitBonus)
		IEex_WriteWord(creatureData + 0x1790, attackBonus)
	end
	local attackCounter = IEex_ReadSignedByte(creatureData + 0x5622, 0x0)
	if false then
		local animationIncrement = 1
		IEex_IncrementAnimationFrame(creatureData, animationIncrement)
	end
	local timeSlowed, targetNotSlowed = IEex_CheckGlobalEffectOnActor(targetID, 0x2)
	if IEex_GetGameTick() % ex_time_slow_speed_divisor ~= 0 then
		if timeSlowed and not targetNotSlowed then
			IEex_WriteWord(creatureData + 0x5322, 0)

			local castCounter = IEex_ReadSignedWord(creatureData + 0x54E8, 0x0)
			if castCounter > 0 then
				IEex_WriteWord(creatureData + 0x54E8, castCounter - 1)
			end
		end
	end
	if attackCounter < 0 then return end
	ex_record_attack_stats_hidden_difference[targetID] = {0, 0}
	if bit.band(tempFlags, 0x2) == 0 then
		IEex_WriteWord(creatureData + 0x9FA, bit.bor(tempFlags, 0x2))
		newEvaluation = true
		ex_record_attack_stats[targetID] = {attackBonus, criticalHitBonus}
	end
	local speedFactor = IEex_ReadByte(creatureData + 0x5604, 0x0)
	local currentAttack = IEex_ReadByte(creatureData + 0x5636, 0x0)
	local normalAPR = IEex_GetActorStat(targetID, 8)
	local combatReflexesFeatID = ex_feat_name_id["ME_COMBAT_REFLEXES"]
	local combatReflexesFeatCount = 0
	if combatReflexesFeatID ~= nil then
		combatReflexesFeatCount = IEex_ReadByte(creatureData + 0x744 + combatReflexesFeatID, 0x0)
	end
	local maxAttacksOfOpportunity = ex_base_num_attacks_of_opportunity
	if combatReflexesFeatCount > 0 and ex_base_num_attacks_of_opportunity == 0 then
		maxAttacksOfOpportunity = 1
	end
	if combatReflexesFeatCount > 1 or (combatReflexesFeatCount > 0 and ex_base_num_attacks_of_opportunity > 0) then
		maxAttacksOfOpportunity = maxAttacksOfOpportunity + math.floor((IEex_GetActorStat(targetID, 40) - 10) / 2)
		if maxAttacksOfOpportunity < 1 then
			maxAttacksOfOpportunity = 1
		end
	end
	local imptwfFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_IMPROVED_TWO_WEAPON_FIGHTING"], 0x0)
	local manyshotFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MANYSHOT"], 0x0)
	local rapidShotEnabled = (IEex_ReadByte(creatureData + 0x4C64, 0x0) > 0)
	local monkLevel = IEex_GetActorStat(targetID, 101)

	local monkAttackBonusDisabled, fixMonkAttackBonus = IEex_CheckMonkAttackBonus(creatureData)
	local monkAttackBonusNowEnabled = (monkLevel > 0 and (not monkAttackBonusDisabled or fixMonkAttackBonus))
	local isFistWeapon = false
	local isBow = false
	local isLauncher = false
	local wearingLightArmor = true
	local isOffhandAttack = false
	local hasSpecificCritBonuses = false
	local numWeapons = 0
	local headerType = 1
	local range = 1
	local weaponSlot = IEex_ReadByte(creatureData + 0x4BA4, 0x0)
	local weaponHeader = IEex_ReadByte(creatureData + 0x4BA6, 0x0)
	local weaponRES = ""
	local slotData = IEex_ReadDword(creatureData + 0x4AD8 + weaponSlot * 0x4)
	local weaponWrapper = 0
	local offhandWrapper = 0
	local launcherWrapper = 0
	if slotData > 0 then
		weaponRES = IEex_ReadLString(slotData + 0xC, 8)
		weaponWrapper = IEex_DemandRes(weaponRES, "ITM")
		if weaponWrapper:isValid() then
			local itemData = weaponWrapper:getData()
			local numHeaders = IEex_ReadSignedWord(itemData + 0x68, 0x0)
			if weaponHeader >= numHeaders then
				weaponHeader = 0
			end
			headerType = IEex_ReadByte(itemData + 0x82 + weaponHeader * 0x38, 0x0)
			range = IEex_ReadWord(itemData + 0x90 + weaponHeader * 0x38, 0x0)
		end
	end
	local bitmapWrapper = IEex_DemandRes("RNDBASE" .. IEex_GetActorStat(targetID, 8), "BMP")
	local aboutToAttack = false
	local aboutToSwing = false
	local justAttacked = false
	if bitmapWrapper:isValid() then
		local bitmapData = bitmapWrapper:getData()
		local nextPixelColor = IEex_GetBitmapPixelColor(bitmapData, attackCounter + 1, speedFactor)
		aboutToAttack = (nextPixelColor == 0xFF0000)
		aboutToSwing = (nextPixelColor == 0xFF00 or nextPixelColor == 0xFFFF00 or nextPixelColor == 0xFF or nextPixelColor == 0xFF00FF or nextPixelColor == 0xFFFF)
		justAttacked = (IEex_GetBitmapPixelColor(bitmapData, attackCounter, speedFactor) == 0xFF0000)
		if justAttacked and IEex_GetActorSpellState(targetID, 246) then
			local sourceAnimationSequence = IEex_ReadByte(creatureData + 0x50F4, 0x0)
			if sourceAnimationSequence == 0 or sourceAnimationSequence == 8 or sourceAnimationSequence == 11 or sourceAnimationSequence == 12 or sourceAnimationSequence == 13 then
				IEex_IterateActorEffects(targetID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					if theopcode == 288 and theparameter2 == 246 and bit.band(thesavingthrow, 0x100000) > 0 then
						local thelimit = IEex_ReadSignedWord(eData + 0x4A, 0x0)
						if thelimit > 0 then
							thelimit = thelimit - 1
							IEex_WriteWord(eData + 0x4A, thelimit)
						end
					end
				end)
			end
		end
	end
	if IEex_GetGameTick() % ex_time_slow_speed_divisor ~= 0 and timeSlowed and not targetNotSlowed and not justAttacked and attackCounter > 0 then
		attackCounter = attackCounter - 1
		IEex_WriteByte(creatureData + 0x5622, attackCounter)
	end
	if false then
		if not aboutToAttack and not aboutToSwing and attackCounter > 0 and attackCounter < 100 then
			attackCounter = attackCounter + 1
			IEex_WriteByte(creatureData + 0x5622, attackCounter)
		end
	end
	if false and IEex_GetGameTick() % 2 == 0 then
		if not justAttacked and attackCounter > 0 then
			attackCounter = attackCounter - 1
			IEex_WriteByte(creatureData + 0x5622, attackCounter)
		end
	end
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter1 = IEex_ReadDword(eData + 0x1C)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		local theresource = IEex_ReadLString(eData + 0x30, 8)
		local thesavingthrow = IEex_ReadDword(eData + 0x40)
		local thespecial = IEex_ReadDword(eData + 0x48)
		if theopcode == 288 and theparameter2 == 241 then
			local thegeneralitemcategory = IEex_ReadByte(eData + 0x48, 0x0)
			if thegeneralitemcategory == 5 then
				numWeapons = numWeapons + 1
			elseif thegeneralitemcategory == 6 then
				isFistWeapon = true
			elseif (theparameter1 >= 62 and theparameter1 <= 66) or theparameter1 == 68 then
				wearingLightArmor = false
			elseif theparameter1 == 15 then
				isBow = true
			end
			if thegeneralitemcategory == 7 then
				isLauncher = true
				launcherWrapper = IEex_DemandRes(IEex_ReadLString(eData + 0x94, 8), "ITM")
			end
		elseif theopcode == 500 and theresource == "MECRIT" and bit.band(thesavingthrow, 0x100000) > 0 then
			hasSpecificCritBonuses = true
		end
	end)
	if numWeapons >= 2 and currentAttack == normalAPR then
		isOffhandAttack = true
	end
	if numWeapons >= 2 and weaponSlot >= 43 then
		local offhandSlotData = IEex_ReadDword(creatureData + 0x4AD8 + (weaponSlot + 1) * 0x4)
		if offhandSlotData > 0 then
			offhandWrapper = IEex_DemandRes(IEex_ReadLString(offhandSlotData + 0xC, 8), "ITM")
		end
	end
	if monkAttackBonusDisabled and fixMonkAttackBonus then
		attackBonus = attackBonus + tonumber(IEex_2DAGetAtStrings("BAATMKU", "BASE_ATTACK", tostring(monkLevel))) - tonumber(IEex_2DAGetAtStrings("BAATNFG", "BASE_ATTACK", tostring(monkLevel)))
		if currentAttack >= 2 then
			attackBonus = attackBonus + 2 * (currentAttack - 1)
		end
		if currentAttack >= 5 then
			attackBonus = attackBonus - 5
		end
	end
	local extraMonkAttacks = 0
	if monkAttackBonusNowEnabled then
		attackPenaltyIncrement = 3
		extraMonkAttacks = ex_monk_apr_progression[monkLevel]
		if weaponRES == ex_monk_fist_progression[monkLevel] or weaponRES == ex_incorporeal_monk_fist_progression[monkLevel] or string.sub(weaponRES, 1, 7) == "00MFIST" then
			extraMonkAttacks = extraMonkAttacks + 1
		end
	end
	local doAttackOfOpportunity = false
	local opportunityAttackBonus = 0
	local actionTargetID = IEex_ReadDword(creatureData + 0x4BE)
	local actionTargetData = IEex_GetActorShare(actionTargetID)
	if maxAttacksOfOpportunity > 0 and IEex_CompareActorAllegiances(targetID, actionTargetID) == -1 then
		local actionID = IEex_ReadWord(creatureData + 0x476, 0x0)
		if actionID == 3 or actionID == 94 or actionID == 105 or actionID == 134 then
			local ignoreFleeingOpportunity = ex_no_attacks_of_opportunity_on_fleeing
			local ignoreRangedWeaponOpportunity = ex_no_attacks_of_opportunity_on_ranged_attack
			local ignoreSpellCastOpportunity = ex_no_attacks_of_opportunity_on_spell_cast
			local fleeingOpportunityAttackBonus = 0
			local rangedWeaponOpportunityAttackBonus = 0
			local spellCastOpportunityAttackBonus = 0
			IEex_IterateActorEffects(actionTargetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				if theopcode == 288 and theparameter2 == 231 then
					if bit.band(thesavingthrow, 0x10000) > 0 then
						if theparameter1 ~= 0 then
							fleeingOpportunityAttackBonus = fleeingOpportunityAttackBonus - theparameter1
						else
							ignoreFleeingOpportunity = true
						end
					end
					if bit.band(thesavingthrow, 0x20000) > 0 then
						if theparameter1 ~= 0 then
							rangedWeaponOpportunityAttackBonus = rangedWeaponOpportunityAttackBonus - theparameter1
						else
							ignoreRangedWeaponOpportunity = true
						end
					end
					if bit.band(thesavingthrow, 0x40000) > 0 then
						if theparameter1 ~= 0 then
							spellCastOpportunityAttackBonus = spellCastOpportunityAttackBonus - theparameter1
						else
							ignoreSpellCastOpportunity = true
						end
					end
					if bit.band(thesavingthrow, 0x70000) == 0 then
						if theparameter1 ~= 0 then
							fleeingOpportunityAttackBonus = fleeingOpportunityAttackBonus - theparameter1
							rangedWeaponOpportunityAttackBonus = rangedWeaponOpportunityAttackBonus - theparameter1
							spellCastOpportunityAttackBonus = spellCastOpportunityAttackBonus - theparameter1
						else
							ignoreFleeingOpportunity = true
							ignoreRangedWeaponOpportunity = true
							ignoreSpellCastOpportunity = true
						end

					end
				end
			end)
			local tick = IEex_GetGameTick()
			if headerType ~= 1 or not IEex_IsSprite(actionTargetID, false) then
				ex_attopp_target[targetID] = nil
			else
				if ex_attopp_repeat_timer[targetID] == nil then
					ex_attopp_repeat_timer[targetID] = {}
				end
				local targetX, targetY = IEex_GetActorLocation(targetID)
				local actionTargetX, actionTargetY = IEex_GetActorLocation(actionTargetID)
				if IEex_GetDistance(targetX, targetY, actionTargetX, actionTargetY) <= range * 20 + 40 then
					ex_attopp_target[targetID] = actionTargetID
					local animationSequence = IEex_ReadByte(IEex_GetActorShare(actionTargetID) + 0x50F4, 0x0)
					if ex_attopp_casting[actionTargetID] == nil then
						ex_attopp_casting[actionTargetID] = {}
					end
					local actionTargetHasRangedWeapon = false
					if animationSequence == 0 or animationSequence == 8 or animationSequence == animationSequence == 11 or animationSequence == 12 or animationSequence == 13 then
						weaponSlot = IEex_ReadByte(actionTargetData + 0x4BA4, 0x0)
						weaponHeader = IEex_ReadByte(actionTargetData + 0x4BA6, 0x0)
						slotData = IEex_ReadDword(actionTargetData + 0x4AD8 + weaponSlot * 0x4)
						if slotData > 0 then
							local weaponRES = IEex_ReadLString(slotData + 0xC, 8)
							local resWrapper = IEex_DemandRes(weaponRES, "ITM")
							if resWrapper:isValid() then
								local itemData = resWrapper:getData()
								local numHeaders = IEex_ReadSignedWord(itemData + 0x68, 0x0)
								if weaponHeader >= numHeaders then
									weaponHeader = 0
								end
								if IEex_ReadByte(itemData + 0x82 + weaponHeader * 0x38, 0x0) ~= 1 then
									actionTargetHasRangedWeapon = true
								end
							end
							resWrapper:free()
						end
					end
					if (animationSequence == 2 or animationSequence == 3) and not ex_attopp_casting[actionTargetID][targetID] and not ignoreSpellCastOpportunity and (ex_attopp_repeat_timer[targetID][actionTargetID] == nil or tick - ex_attopp_repeat_timer[targetID][actionTargetID] >= 30) then
						if ex_attopp_count[targetID] == nil or (ex_attopp_timer[targetID] ~= nil and tick - ex_attopp_timer[targetID] >= 100) then
							ex_attopp_count[targetID] = 0
							ex_attopp_timer[targetID] = tick
						end
						if ex_attopp_count[targetID] < maxAttacksOfOpportunity then
							ex_attopp_count[targetID] = ex_attopp_count[targetID] + 1
							ex_attopp_repeat_timer[targetID][actionTargetID] = tick
							ex_attopp_casting[actionTargetID][targetID] = true
							opportunityAttackBonus = spellCastOpportunityAttackBonus
							doAttackOfOpportunity = true
						end
					elseif actionTargetHasRangedWeapon and not ignoreRangedWeaponOpportunity and (ex_attopp_repeat_timer[targetID][actionTargetID] == nil or tick - ex_attopp_repeat_timer[targetID][actionTargetID] >= 30) then
						if ex_attopp_count[targetID] == nil or (ex_attopp_timer[targetID] ~= nil and tick - ex_attopp_timer[targetID] >= 100) then
							ex_attopp_count[targetID] = 0
							ex_attopp_timer[targetID] = tick
						end
						if ex_attopp_count[targetID] < maxAttacksOfOpportunity then
							ex_attopp_count[targetID] = ex_attopp_count[targetID] + 1
							ex_attopp_repeat_timer[targetID][actionTargetID] = tick
							opportunityAttackBonus = rangedWeaponOpportunityAttackBonus
							doAttackOfOpportunity = true
						end
					end
				else
					if ex_attopp_target[targetID] == actionTargetID and not ignoreFleeingOpportunity and (ex_attopp_repeat_timer[targetID][actionTargetID] == nil or tick - ex_attopp_repeat_timer[targetID][actionTargetID] >= 30) then
						if ex_attopp_count[targetID] == nil or (ex_attopp_timer[targetID] ~= nil and tick - ex_attopp_timer[targetID] >= 100) then
							ex_attopp_count[targetID] = 0
							ex_attopp_timer[targetID] = tick
						end
						if ex_attopp_count[targetID] < maxAttacksOfOpportunity then
							ex_attopp_count[targetID] = ex_attopp_count[targetID] + 1
							ex_attopp_repeat_timer[targetID][actionTargetID] = tick
							opportunityAttackBonus = fleeingOpportunityAttackBonus
							doAttackOfOpportunity = true
						end
					end
					ex_attopp_target[targetID] = nil
				end
			end
		else
			ex_attopp_target[targetID] = nil
		end
	end
	if ex_record_attacks_made[targetID] == nil then
		ex_record_attacks_made[targetID] = {0, 0, 0, 0}
	end
	if (normalAPR + imptwfFeatCount + extraMonkAttacks >= 5 or (manyshotFeatCount > 0 and rapidShotEnabled)) and attackCounter >= 0 then
		IEex_WriteWord(creatureData + 0x9E6, 10)
--		IEex_DS(attackCounter)
		local totalAttacks = IEex_ReadByte(creatureData + 0x5ED, 0x0) + extraMonkAttacks
		local extraAttacks = 0
		local extraMainhandAttacks = extraMonkAttacks
		local manyshotAttacks = manyshotFeatCount
		local slotData = IEex_ReadDword(creatureData + 0x4AD8 + weaponSlot * 0x4)
		if slotData > 0 then
			local weaponRES = IEex_ReadLString(slotData + 0xC, 8)
			local resWrapper = IEex_DemandRes(weaponRES, "ITM")
			if resWrapper:isValid() then
				local itemData = resWrapper:getData()
				local numHeaders = IEex_ReadSignedWord(itemData + 0x68, 0x0)
				if weaponHeader >= numHeaders then
					weaponHeader = 0
				end
				local itemType = IEex_ReadWord(itemData + 0x1C, 0x0)
				headerType = IEex_ReadByte(itemData + 0x82 + weaponHeader * 0x38, 0x0)
				if rapidShotEnabled and headerType == 2 and itemType ~= 27 and itemType ~= 31 then
					totalAttacks = totalAttacks + 1
				end
			end
			resWrapper:free()
		end

		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			local thespecial = IEex_ReadDword(eData + 0x48)
			if theopcode == 1 then
				if theparameter2 == 0 then
					totalAttacks = totalAttacks + theparameter1
				elseif theparameter2 == 1 then
					totalAttacks = theparameter1
				end
			elseif theopcode == 288 and theparameter2 == 196 and (thespecial == 0 or thespecial == headerType) then
				if bit.band(thesavingthrow, 0x10000) > 0 then
					extraMainhandAttacks = extraMainhandAttacks + theparameter1
				elseif bit.band(thesavingthrow, 0x20000) > 0 then
					manyshotAttacks = manyshotAttacks + theparameter1
				else
					extraAttacks = extraAttacks + theparameter1
				end
--[[
			elseif theopcode == 288 and theparameter2 == 241 then
				local thegeneralitemcategory = IEex_ReadByte(eData + 0x48, 0x0)
				if thegeneralitemcategory == 5 then
					numWeapons = numWeapons + 1
				elseif thegeneralitemcategory == 6 then
					isFistWeapon = true
				elseif (theparameter1 >= 62 and theparameter1 <= 66) or theparameter1 == 68 then
					wearingLightArmor = false
				elseif theparameter1 == 15 then
					isBow = true
				end

			elseif theopcode == 500 and IEex_ReadLString(eData + 0x30, 8) == "MECRIT" and IEex_ReadSignedWord(eData + 0x4A, 0x0) > 0 and then
				local thegeneralitemcategory = IEex_ReadByte(eData + 0x48, 0x0)
				if thegeneralitemcategory == 5 then
					numWeapons = numWeapons + 1
				elseif thegeneralitemcategory == 6 then
					isFistWeapon = true
				elseif (theparameter1 >= 62 and theparameter1 <= 66) or theparameter1 == 68 then
					wearingLightArmor = false
				elseif theparameter1 == 15 then
					isBow = true
				end
--]]
			end

		end)

		if not isBow or not rapidShotEnabled then
			manyshotAttacks = 0
		end
		local usingImptwf = false
		if numWeapons >= 2 then
			totalAttacks = totalAttacks + 1
			extraMainhandAttacks = extraMainhandAttacks + 1
		end
		if IEex_GetActorSpellState(targetID, 17) then
			totalAttacks = totalAttacks + 1
		end
		local stateValue = bit.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
		if bit.band(stateValue, 0x8000) > 0 then
			totalAttacks = totalAttacks + 1
		end
		if bit.band(stateValue, 0x10000) > 0 then
			totalAttacks = totalAttacks - 1
		end
		if ex_no_apr_limit then
			extraMainhandAttacks = 1000
		end
		if totalAttacks > extraAttacks + extraMainhandAttacks + 5 then
			totalAttacks = extraAttacks + extraMainhandAttacks + 5
		end
		if extraMainhandAttacks > totalAttacks - normalAPR then
			extraMainhandAttacks = totalAttacks - normalAPR
		end
		if extraAttacks > totalAttacks - normalAPR - extraMainhandAttacks then
			extraAttacks = totalAttacks - normalAPR - extraMainhandAttacks
		end
		if numWeapons >= 2 then
			if imptwfFeatCount > 0 and (IEex_GetActorStat(targetID, 103) < 9 or wearingLightArmor or (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 16 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x2) > 0 and bit.band(IEex_ReadDword(creatureData + 0x764), 0x40) > 0)) then
				totalAttacks = totalAttacks + 1
				extraAttacks = extraAttacks + 1
				usingImptwf = true
				if imptwfFeatCount > 1 and (IEex_GetActorStat(targetID, 103) < 14 or wearingLightArmor or (IEex_ReadByte(creatureData + 0x5EC, 0x0) >= 21 and bit.band(IEex_ReadDword(creatureData + 0x75C), 0x2) > 0 and bit.band(IEex_ReadDword(creatureData + 0x764), 0x40) > 0)) then
					totalAttacks = totalAttacks + 1
					extraAttacks = extraAttacks + 1
				end
			end
		else
			extraAttacks = extraAttacks + extraMainhandAttacks
			extraMainhandAttacks = 0

		end
		if IEex_GetActorSpellState(targetID, 138) then
			if numWeapons >= 2 then
				extraMainhandAttacks = extraMainhandAttacks * 2 + (normalAPR - 1)
				extraAttacks = extraAttacks * 2 + 1
			else
				extraAttacks = extraAttacks * 2 + normalAPR
			end
			totalAttacks = normalAPR + extraAttacks + extraMainhandAttacks
			manyshotAttacks = manyshotAttacks * 2
		end
		if totalAttacks >= 6 or usingImptwf or manyshotAttacks > 0 or extraMonkAttacks > 0 then
			local totalAttacksMade = ex_record_attacks_made[targetID][1]
			local extraAttacksMade = ex_record_attacks_made[targetID][2]
			local extraMainhandAttacksMade = ex_record_attacks_made[targetID][3]
			local manyshotAttacksMade = ex_record_attacks_made[targetID][4]
			IEex_WriteByte(creatureData + 0x5630, 1)
			if normalAPR == 4 then
				local counterCut = 0
				local remainderCut = 0
				if usingImptwf or extraMonkAttacks > 0 then
					counterCut = 3
					remainderCut = 5
					extraAttacks = 1
				else
					extraAttacks = 0
				end
				extraMainhandAttacks = 0
				if attackCounter == 6 and manyshotAttacksMade < manyshotAttacks then
					manyshotAttacksMade = manyshotAttacksMade + 1
					ex_record_attacks_made[targetID][4] = manyshotAttacksMade
					IEex_WriteByte(creatureData + 0x5622, 0)
				elseif attackCounter == 1 and manyshotAttacksMade > 0 then
					attackCounter = 5
					IEex_WriteByte(creatureData + 0x5622, attackCounter)
				elseif attackCounter >= 19 - counterCut and attackCounter >= 6 and attackCounter < 19 then
					IEex_WriteByte(creatureData + 0x5622, 18)
				elseif attackCounter >= 39 - counterCut and attackCounter >= 25 and attackCounter < 39 then
					IEex_WriteByte(creatureData + 0x5622, 38)
				elseif attackCounter >= 59 - counterCut and attackCounter >= 45 and attackCounter < 59 then
					IEex_WriteByte(creatureData + 0x5622, 58)
				elseif attackCounter >= 79 - counterCut and attackCounter >= 65 and attackCounter < 79 and extraAttacksMade < extraAttacks then
					extraAttacksMade = extraAttacksMade + 1
					ex_record_attacks_made[targetID][2] = extraAttacksMade
					IEex_WriteByte(creatureData + 0x5622, 58)
				elseif attackCounter >= 80 - counterCut and attackCounter >= 65 and attackCounter < 80 then
					IEex_WriteByte(creatureData + 0x5622, 79)
				elseif attackCounter >= 100 - remainderCut and attackCounter >= 80 then
					IEex_WriteByte(creatureData + 0x5622, 99)
					ex_record_attacks_made[targetID] = {0, 0, 0, 0}
				elseif attackCounter == 0 then
					ex_record_attacks_made[targetID] = {0, 0, 0, 0}
				end
				if attackCounter == 5 or attackCounter == 24 or attackCounter == 44 or attackCounter == 64 then
					ex_record_attacks_made[targetID][1] = totalAttacksMade + 1
					if IEex_ReadByte(creatureData + 0x5636, 0x0) == 0 then
						if attackCounter == 5 then
							IEex_WriteByte(creatureData + 0x5636, 1)
						elseif attackCounter == 24 then
							IEex_WriteByte(creatureData + 0x5636, 2)
						elseif attackCounter == 44 then
							IEex_WriteByte(creatureData + 0x5636, 3)
						elseif attackCounter == 64 then
							IEex_WriteByte(creatureData + 0x5636, 4)
						end
					end
				end
				if attackCounter == 5 then
					if manyshotAttacks > 0 then
						attackBonus = attackBonus - attackPenaltyIncrement * manyshotAttacks
					end
				elseif attackCounter == 64 then
					attackBonus = attackBonus - attackPenaltyIncrement * extraAttacksMade
				end
			elseif normalAPR == 5 then
				local counterCut = math.floor((extraAttacks + extraMainhandAttacks) * 16 / (totalAttacks + 1))
				local remainderCut = (((extraAttacks + extraMainhandAttacks) * 16) % (totalAttacks + 1)) + counterCut
				if totalAttacks >= 15 then
					counterCut = 100
					remainderCut = 100
				elseif counterCut == 10 then
					remainderCut = remainderCut + 1
				end
				if attackCounter == 6 and manyshotAttacksMade < manyshotAttacks then
					manyshotAttacksMade = manyshotAttacksMade + 1
					ex_record_attacks_made[targetID][4] = manyshotAttacksMade
					IEex_WriteByte(creatureData + 0x5622, 0)
				elseif attackCounter == 1 and manyshotAttacksMade > 0 then
					attackCounter = 5
					IEex_WriteByte(creatureData + 0x5622, attackCounter)
				elseif attackCounter >= 18 - counterCut and attackCounter >= 6 and attackCounter < 18 then
					IEex_SetAttackAnimationFrame(creatureData, 14)
					IEex_WriteByte(creatureData + 0x5622, 17)
				elseif attackCounter >= 36 - counterCut and attackCounter >= 24 and attackCounter < 36 then
					IEex_SetAttackAnimationFrame(creatureData, 14)
					IEex_WriteByte(creatureData + 0x5622, 35)
				elseif attackCounter >= 52 - counterCut and attackCounter >= 42 and attackCounter < 52 then
					IEex_SetAttackAnimationFrame(creatureData, 14)
					IEex_WriteByte(creatureData + 0x5622, 51)
				elseif attackCounter >= 68 - counterCut and attackCounter >= 58 and attackCounter < 68 and extraMainhandAttacksMade < extraMainhandAttacks then
					extraMainhandAttacksMade = extraMainhandAttacksMade + 1
					ex_record_attacks_made[targetID][3] = extraMainhandAttacksMade
					IEex_SetAttackAnimationFrame(creatureData, 14)
					IEex_WriteByte(creatureData + 0x5622, 51)
				elseif attackCounter >= 69 - counterCut and attackCounter >= 58 and attackCounter < 69 then
					IEex_SetAttackAnimationFrame(creatureData, 14)
					IEex_WriteByte(creatureData + 0x5622, 68)
				elseif attackCounter >= 85 - counterCut and attackCounter >= 75 and attackCounter < 85 and extraAttacksMade < extraAttacks then
					extraAttacksMade = extraAttacksMade + 1
					ex_record_attacks_made[targetID][2] = extraAttacksMade
					IEex_SetAttackAnimationFrame(creatureData, 14)
					IEex_WriteByte(creatureData + 0x5622, 68)
				elseif attackCounter >= 86 - counterCut and attackCounter >= 75 and attackCounter < 86 then
					IEex_SetAttackAnimationFrame(creatureData, 14)
					IEex_WriteByte(creatureData + 0x5622, 85)
				elseif attackCounter >= 100 - remainderCut and attackCounter >= 86 then
					IEex_WriteByte(creatureData + 0x5622, 99)
					ex_record_attacks_made[targetID] = {0, 0, 0, 0}
				elseif attackCounter == 0 then
					ex_record_attacks_made[targetID] = {0, 0, 0, 0}
				end
				if totalAttacks > 50 then
					totalAttacks = 50
				end
				if totalAttacks >= 16 and (attackCounter == 0 or attackCounter == 18 or attackCounter == 36 or attackCounter == 52 or attackCounter == 69) and ex_superfast_attack_cut[totalAttacks][totalAttacksMade + 1] ~= nil then
					attackCounter = attackCounter + ex_superfast_attack_cut[totalAttacks][totalAttacksMade + 1]
					if IEex_IsSprite(actionTargetID, false) then
						IEex_SetAttackAnimationFrame(creatureData, 1 + ex_superfast_attack_cut[totalAttacks][totalAttacksMade + 1])
					end
					IEex_WriteByte(creatureData + 0x5622, attackCounter)
				end
				if attackCounter == 5 or attackCounter == 23 or attackCounter == 41 or attackCounter == 57 or attackCounter == 74 then
					ex_record_attacks_made[targetID][1] = totalAttacksMade + 1
					if IEex_ReadByte(creatureData + 0x5636, 0x0) == 0 then
						if attackCounter == 5 then
							IEex_WriteByte(creatureData + 0x5636, 1)
						elseif attackCounter == 23 then
							IEex_WriteByte(creatureData + 0x5636, 2)
						elseif attackCounter == 41 then
							IEex_WriteByte(creatureData + 0x5636, 3)
						elseif attackCounter == 57 then
							IEex_WriteByte(creatureData + 0x5636, 4)
						elseif attackCounter == 74 then
							IEex_WriteByte(creatureData + 0x5636, 5)
						end
					end
				end

				if attackCounter == 5 then
					if manyshotAttacks > 0 then
						attackBonus = attackBonus - attackPenaltyIncrement * manyshotAttacks
					end
				elseif attackCounter == 57 then
					attackBonus = attackBonus - attackPenaltyIncrement * extraMainhandAttacksMade
				elseif attackCounter == 74 then
					attackBonus = attackBonus - attackPenaltyIncrement * extraAttacksMade
				end
			end
		end
	end
	attackCounter = IEex_ReadSignedByte(creatureData + 0x5622, 0x0)
	if aboutToAttack then
		if not isOffhandAttack then
			attackBonus = attackBonus + IEex_ReadSignedByte(creatureData + 0x9F8, 0x0)
		else
			attackBonus = attackBonus + IEex_ReadSignedByte(creatureData + 0x9FC, 0x0)
		end
		if hasSpecificCritBonuses then
			if not isOffhandAttack then
				local weaponData = weaponWrapper:getData()
				local effectOffset = IEex_ReadDword(weaponData + 0x6A)
				local numGlobalEffects = IEex_ReadWord(weaponData + 0x70, 0x0)
				for i = 0, numGlobalEffects - 1, 1 do
					local offset = weaponData + effectOffset + i * 0x30
					local theopcode = IEex_ReadWord(offset, 0x0)
					local theresource = IEex_ReadLString(offset + 0x14, 8)
					local thesavingthrow = IEex_ReadDword(offset + 0x24)
					if theopcode == 500 and theresource == "MECRIT" and bit.band(thesavingthrow, 0x100000) > 0 then
						local theparameter1 = IEex_ReadDword(offset + 0x4)
						criticalHitBonus = criticalHitBonus + theparameter1
					end
				end
			else
				local weaponData = offhandWrapper:getData()
				local effectOffset = IEex_ReadDword(weaponData + 0x6A)
				local numGlobalEffects = IEex_ReadWord(weaponData + 0x70, 0x0)
				for i = 0, numGlobalEffects - 1, 1 do
					local offset = weaponData + effectOffset + i * 0x30
					local theopcode = IEex_ReadWord(offset, 0x0)
					local theresource = IEex_ReadLString(offset + 0x14, 8)
					local thesavingthrow = IEex_ReadDword(offset + 0x24)
					if theopcode == 500 and theresource == "MECRIT" and bit.band(thesavingthrow, 0x100000) > 0 then
						local theparameter1 = IEex_ReadDword(offset + 0x4)
						criticalHitBonus = criticalHitBonus + theparameter1
					end
				end
			end
			if isLauncher then
				local weaponData = launcherWrapper:getData()
				local effectOffset = IEex_ReadDword(weaponData + 0x6A)
				local numGlobalEffects = IEex_ReadWord(weaponData + 0x70, 0x0)
				for i = 0, numGlobalEffects - 1, 1 do
					local offset = weaponData + effectOffset + i * 0x30
					local theopcode = IEex_ReadWord(offset, 0x0)
					local theresource = IEex_ReadLString(offset + 0x14, 8)
					local thesavingthrow = IEex_ReadDword(offset + 0x24)
					if theopcode == 500 and theresource == "MECRIT" and bit.band(thesavingthrow, 0x100000) > 0 then
						local theparameter1 = IEex_ReadDword(offset + 0x4)
						criticalHitBonus = criticalHitBonus + theparameter1
					end
				end
			end
		end
		if IEex_IsSprite(actionTargetID, false) then
			local sourceVisualHeight = IEex_ReadDword(creatureData + 0xE)
			local targetVisualHeight = IEex_ReadDword(actionTargetData + 0xE)
			if math.abs(targetVisualHeight - sourceVisualHeight) > range * 20 + 40 then
				attackBonus = attackBonus - 20
			end
		end
		ex_record_attack_stats_hidden_difference[targetID] = {attackBonus - ex_record_attack_stats[targetID][1], criticalHitBonus - ex_record_attack_stats[targetID][2]}
		IEex_WriteWord(creatureData + 0x936, criticalHitBonus)
		IEex_WriteWord(creatureData + 0x938, attackBonus)
		IEex_WriteWord(creatureData + 0x178E, criticalHitBonus)
		IEex_WriteWord(creatureData + 0x1790, attackBonus)
	end
--	IEex_EvaluatePersistentEffects(targetID)
	bitmapWrapper:free()
	weaponWrapper:free()
	if numWeapons >= 2 then
		offhandWrapper:free()
	end
	if isLauncher then
		launcherWrapper:free()
	end
	if doAttackOfOpportunity then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["parameter1"] = ex_tra_55395,
["parent_resource"] = "USAPRBON",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 174,
["target"] = 2,
["timing"] = 0,
["resource"] = "EFF_M17B",
["parent_resource"] = "USAPRBON",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(actionTargetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["savingthrow"] = 0x10000,
["special"] = opportunityAttackBonus,
["resource"] = "MEWHIRLA",
["parent_resource"] = "USATTOPP",
["source_id"] = targetID
})
	end
end

function IEex_GetBitmapPixelColor(bitmapData, x, y)
	local fileSize = IEex_ReadDword(bitmapData + 0x2)
	local dataOffset = IEex_ReadDword(bitmapData + 0xA)
	local bitmapX = IEex_ReadDword(bitmapData + 0x12)
	local bitmapY = IEex_ReadDword(bitmapData + 0x16)
	local padding = 4 - (bitmapX / 2) % 4
	if padding == 4 then
		padding = 0
	end
	local areaX = bitmapX * 16
	local areaY = bitmapY * 12
	y = bitmapY - y - 1
	if x < 0 or x >= bitmapX or y < 0 or y >= bitmapY then
		return -1
	end
	local trueBitmapX = math.floor(bitmapX / 2) + padding
	local current = IEex_ReadByte(bitmapData + dataOffset + y * trueBitmapX + math.floor(x / 2), 0x0)
	if x % 2 == 0 then
		return bit.band(IEex_ReadDword(bitmapData + 0x36 + math.floor(current / 16) * 0x4), 0xFFFFFF)
	else
		return bit.band(IEex_ReadDword(bitmapData + 0x36 + (current % 16) * 0x4), 0xFFFFFF)
	end
end

function IEex_GetBitmapPixelIndex(bitmapData, x, y)
	local fileSize = IEex_ReadDword(bitmapData + 0x2)
	local dataOffset = IEex_ReadDword(bitmapData + 0xA)
	local bitmapX = IEex_ReadDword(bitmapData + 0x12)
	local bitmapY = IEex_ReadDword(bitmapData + 0x16)
	local padding = 4 - (bitmapX / 2) % 4
	if padding == 4 then
		padding = 0
	end
	local areaX = bitmapX * 16
	local areaY = bitmapY * 12
	y = bitmapY - y - 1
	if x < 0 or x >= bitmapX or y < 0 or y >= bitmapY then
		return -1
	end
	local trueBitmapX = math.floor(bitmapX / 2) + padding
	local current = IEex_ReadByte(bitmapData + dataOffset + y * trueBitmapX + math.floor(x / 2), 0x0)
	if x % 2 == 0 then
		return (math.floor(current / 16))
	else
		return (current % 16)
	end
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
	if bit.band(areaType, 0x800) > 0 then
		disableTeleport = true
	else
		local areaRES = IEex_ReadLString(areaData, 8)
		if ex_specific_teleport_zone[areaRES] ~= nil then
			local noTeleportMapWrapper = IEex_DemandRes(areaRES .. "NT", "BMP")
			if noTeleportMapWrapper:isValid() then
				local noTeleportMapData = noTeleportMapWrapper:getData()
				local currentZone = IEex_GetBitmapPixelIndex(noTeleportMapData, math.floor(sourceX / 16), math.floor(sourceY / 12))
				local destinationZone = IEex_GetBitmapPixelIndex(noTeleportMapData, math.floor(targetX / 16), math.floor(targetY / 12))
				if currentZone ~= destinationZone then
					disableTeleport = true
				end
			end
			noTeleportMapWrapper:free()
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

function MERECALL(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local sourceData = IEex_GetActorShare(sourceID)
	if IEex_ReadDword(creatureData + 0x12) ~= IEex_ReadDword(sourceData + 0x12) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local sourceX, sourceY = IEex_GetActorLocation(sourceID)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 124,
["target"] = 2,
["timing"] = 1,
["target_x"] = sourceX,
["target_y"] = sourceY,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
end

function METRANST(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, true) then return end
	local sourceData = IEex_GetActorShare(sourceID)
	if IEex_ReadDword(creatureData + 0x12) ~= IEex_ReadDword(sourceData + 0x12) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local sourceX, sourceY = IEex_GetActorLocation(sourceID)
	local targetX, targetY = IEex_GetActorLocation(targetID)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	IEex_IterateProjectiles(-1, function(projectileData)
		local projectileType = IEex_ProjectileType[IEex_ReadWord(projectileData + 0x6E, 0x0) + 1] 
		local doSwitchProjectile = true
		if projectileType == 6 then
			if IEex_ReadByte(projectileData + 0x2B6, 0x0) > 0 then
				doSwitchProjectile = false
			end
		elseif projectileType == 8 then
			if IEex_ReadByte(projectileData + 0x2A8, 0x0) > 0 then
				doSwitchProjectile = false
			end
		end
		if doSwitchProjectile then
			local projectileSourceID = IEex_ReadDword(projectileData + 0x72)
			local projectileTargetID = IEex_ReadDword(projectileData + 0x76)
			if projectileSourceID == sourceID then
				IEex_WriteDword(projectileData + 0x72, targetID)
			elseif projectileSourceID == targetID then
				IEex_WriteDword(projectileData + 0x72, sourceID)
			end
			if projectileTargetID == sourceID then
				IEex_WriteDword(projectileData + 0x76, targetID)
			elseif projectileTargetID == targetID then
				IEex_WriteDword(projectileData + 0x76, sourceID)
			end
		end
	end)
	local sourceVisualHeight = IEex_ReadDword(sourceData + 0xE)
	IEex_WriteDword(sourceData + 0xE, IEex_ReadDword(creatureData + 0xE))
	IEex_WriteDword(creatureData + 0xE, sourceVisualHeight)
	local sourceHeight = IEex_ReadSignedWord(sourceData + 0x720, 0x0)
	IEex_WriteWord(sourceData + 0x720, IEex_ReadSignedWord(creatureData + 0x720, 0x0))
	IEex_WriteWord(creatureData + 0x720, sourceHeight)
	local sourceVelocity = IEex_ReadSignedWord(sourceData + 0x722, 0x0)
	IEex_WriteWord(sourceData + 0x722, IEex_ReadSignedWord(creatureData + 0x722, 0x0))
	IEex_WriteWord(creatureData + 0x722, sourceVelocity)
	local sourceAccel = IEex_ReadSignedWord(sourceData + 0x724, 0x0)
	IEex_WriteWord(sourceData + 0x724, IEex_ReadSignedWord(creatureData + 0x724, 0x0))
	IEex_WriteWord(creatureData + 0x724, sourceAccel)
	IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 184,
["target"] = 2,
["timing"] = 0,
["parameter2"] = 1,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 184,
["target"] = 2,
["timing"] = 0,
["parameter2"] = 1,
["parent_resource"] = parent_resource,
["source_id"] = targetID
})
	IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 124,
["target"] = 2,
["timing"] = 1,
["target_x"] = targetX,
["target_y"] = targetY,
["parent_resource"] = parent_resource,
["source_id"] = sourceID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 124,
["target"] = 2,
["timing"] = 1,
["target_x"] = sourceX,
["target_y"] = sourceY,
["parent_resource"] = parent_resource,
["source_id"] = targetID
})
end

function IEex_JumpActorToPoint(actorID, pointX, pointY, bSendSpriteUpdateMessage)
    if not IEex_IsSprite(actorID, true) then return end
    if bSendSpriteUpdateMessage == nil then bSendSpriteUpdateMessage = true end 
    IEex_Call(0x745950, {bSendSpriteUpdateMessage and 1 or 0, pointY, pointX}, IEex_GetActorShare(actorID), 0x0)
end

function MESETZ(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	IEex_WriteDword(creatureData + 0xE, parameter1 * -1)
end

function MEWINGBU(effectData, creatureData, isSpecialCall)
	if not isSpecialCall then return end
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
--	if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "MEWINGBU", 5) then return end
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local sourceData = IEex_GetActorShare(sourceID)
	if IEex_GetActorSpellState(targetID, 212) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	if parameter1 <= 0 then return end
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	if parameter2 == 4 and not IEex_IsSprite(sourceID, false) then return end
	local timeSlowed, targetNotSlowed = IEex_CheckGlobalEffectOnActor(targetID, 0x2)
	if IEex_GetGameTick() % ex_time_slow_speed_divisor ~= 0 then
		if timeSlowed and not targetNotSlowed then return end
	end
	local parameter4 = IEex_ReadDword(effectData + 0x60)
	local special = IEex_ReadDword(effectData + 0x44)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local internalFlags = IEex_ReadDword(effectData + 0xC8)
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
		if bit.band(areaType, 0x800) > 0 then
			disableTeleport = true
--[[
		else
			if areaRES == "AR4102" and (targetX >= 400 and targetX <= 970 and targetY >= 1030 and targetY <= 1350) then
				disableTeleport = true
			end
--]]
		end
	end
	if parameter4 == 0 then
		IEex_WriteDword(effectData + 0x60, 1)
		if (parameter2 == 5 or parameter2 == 6) and sourceData > 0 then
			IEex_WriteDword(effectData + 0x7C, IEex_ReadDword(sourceData + 0x6))
			IEex_WriteDword(effectData + 0x80, IEex_ReadDword(sourceData + 0xA))
		end
	end

	if parameter2 == 2 or parameter2 == 4 then
		if sourceData > 0 then
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
	if parameter2 == 4 then
		local sizeSpaceX = IEex_ReadDword(IEex_ReadDword(sourceData + 0x50F0) + 0x10) + IEex_ReadDword(IEex_ReadDword(creatureData + 0x50F0) + 0x10)
		local sizeSpaceY = IEex_ReadDword(IEex_ReadDword(sourceData + 0x50F0) + 0x14) + IEex_ReadDword(IEex_ReadDword(creatureData + 0x50F0) + 0x14)
		local destinationX = IEex_ReadDword(sourceData + 0x556E)
		local destinationY = IEex_ReadDword(sourceData + 0x5572)
		if destinationX > 0 and destinationY > 0 and IEex_ReadDword(sourceData + 0x4BE) ~= targetID then
			local orientation = IEex_ReadByte(sourceData + 0x5380, 0x0)
			if orientation >= 2 and orientation <= 6 then
				sourceX = sourceX + sizeSpaceX
			elseif orientation >= 10 and orientation <= 14 then
				sourceX = sourceX - sizeSpaceX
			end
			if orientation >= 6 and orientation <= 10 then
				sourceY = sourceY + sizeSpaceY
			elseif orientation <= 2 or orientation >= 14 then
				sourceY = sourceY - sizeSpaceY
			end
--[[
			if destinationX >= sourceX then
				sourceX = sourceX - sizeSpaceX
			else
				sourceX = sourceX + sizeSpaceX
			end
			if destinationY >= sourceY then
				sourceY = sourceY - sizeSpaceY
			else
				sourceY = sourceY + sizeSpaceY
			end
--]]
		else
			if targetX >= sourceX then
				sourceX = sourceX + sizeSpaceX
			else
				sourceX = sourceX - sizeSpaceX
			end
			if targetY >= sourceY then
				sourceY = sourceY + sizeSpaceY
			else
				sourceY = sourceY - sizeSpaceY
			end
		end
	end
	local distX = targetX - sourceX
	local distY = targetY - sourceY
--[[
	if parameter2 == 4 then
		local sizeSpaceX = IEex_ReadDword(IEex_ReadDword(sourceData + 0x50F0) + 0x10) + IEex_ReadDword(IEex_ReadDword(creatureData + 0x50F0) + 0x10)
		local sizeSpaceY = IEex_ReadDword(IEex_ReadDword(sourceData + 0x50F0) + 0x14) + IEex_ReadDword(IEex_ReadDword(creatureData + 0x50F0) + 0x14)

		if distX >= 0 then
			distX = distX - sizeSpaceX
			if distX < 0 then
				distX = 0
			end
		else
			distX = distX + sizeSpaceX
			if distX > 0 then
				distX = 0
			end
		end
		if distY >= 0 then
			distY = distY - sizeSpaceY
			if distY < 0 then
				distY = 0
			end
		else
			distY = distY + sizeSpaceY
			if distY > 0 then
				distY = 0
			end
		end

	end
--]]
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
	local height = IEex_ReadSignedWord(creatureData + 0x720, 0x0)
	local destinationHeight = 0
	local collideWithWall = false
	if ex_specific_teleport_zone[areaRES] ~= nil then
		local noTeleportMapWrapper = IEex_DemandRes(areaRES .. "NT", "BMP")
		if noTeleportMapWrapper:isValid() then
			local noTeleportMapData = noTeleportMapWrapper:getData()
			local currentZone = IEex_GetBitmapPixelIndex(noTeleportMapData, math.floor(targetX / 16), math.floor(targetY / 12))
			local destinationZone = IEex_GetBitmapPixelIndex(noTeleportMapData, math.floor(finalX / 16), math.floor(finalY / 12))
			if currentZone ~= destinationZone then
				disableTeleport = true
			end
		end
		noTeleportMapWrapper:free()
	end
	if ex_specific_floor_height[areaRES] ~= nil then


		local heightMap2Wrapper = IEex_DemandRes(areaRES .. "H2", "BMP")
		if heightMap2Wrapper:isValid() then
			local heightMap2Data = heightMap2Wrapper:getData()
			local specificFloorHeight = IEex_GetBitmapPixelColor(heightMap2Data, math.floor(finalX / 16), math.floor(finalY / 12))

			if ex_specific_floor_height[areaRES][specificFloorHeight] ~= nil then
				destinationHeight = ex_specific_floor_height[areaRES][specificFloorHeight]
			end
			if height < 0 and destinationHeight > math.floor(height / 2) then
				collideWithWall = true
--				finalX = targetX
--				finalY = targetY
			elseif destinationHeight < math.floor(height / 2) then
				IEex_WriteByte(creatureData + 0x9DC, 1)
			end
		end
		heightMap2Wrapper:free()
	end
	local searchMapWrapper = IEex_DemandRes(areaRES .. "SR", "BMP")
	if searchMapWrapper:isValid() then
		local searchMapData = searchMapWrapper:getData()
		local destinationAccessibility = ex_default_terrain_table_1[IEex_GetBitmapPixelIndex(searchMapData, math.floor(finalX / 16), math.floor(finalY / 12)) + 1] 
		if destinationAccessibility == -1 and destinationHeight >= 0 then
			collideWithWall = true
		end
	end
	searchMapWrapper:free()
	if collideWithWall and (parameter2 == 1 or parameter2 == 2 or parameter2 == 5) and (height < 0 or IEex_ReadByte(creatureData + 0x9DC, 0x0) == 0) and not IEex_GetActorSpellState(targetID, 182) and not IEex_GetActorSpellState(targetID, 189) then
		local damageDice = math.floor((parameter1 - 10) / 3)
		if damageDice > 100 then
			damageDice = 100
		end
		if damageDice > 0 then
			IEex_WriteDword(effectData + 0x18, 0)
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = 0x600 + damageDice * 0x10000,
["savingthrow"] = 0x90000,
["resource"] = "EXDAMAGE",
["parent_resource"] = "MEWALDMG",
["internal_flags"] = internalFlags,
["source_target"] = targetID,
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 1,
["resource"] = "MEWALDMG",
["source_target"] = targetID,
["source_id"] = sourceID
})
		end

	end
	if height == 0 or special > 0 then
		IEex_WriteDword(effectData + 0x18, parameter1 + special)
	end
	if not disableTeleport then
		IEex_JumpActorToPoint(targetID, finalX, finalY, true)
--[[
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
--]]
	end
end

function METELMOV(effectData, creatureData, isSpecialCall)
	if not isSpecialCall then return end
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
--	if IEex_CheckForInfiniteLoop(targetID, IEex_GetGameTick(), "METELMOV", 5) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local special = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local targetX = IEex_ReadDword(creatureData + 0x6)
	local targetY = IEex_ReadDword(creatureData + 0xA)
	local destinationX = IEex_ReadDword(creatureData + 0x556E)
	local destinationY = IEex_ReadDword(creatureData + 0x5572)
	local action = IEex_ReadWord(creatureData + 0x476, 0x0)
	local actionX = IEex_ReadDword(creatureData + 0x540)
	local actionY = IEex_ReadDword(creatureData + 0x544)
	local disableTeleport = false
	local areaData = IEex_ReadDword(creatureData + 0x12)
	if areaData <= 0 then return end
	local areaType = IEex_ReadWord(areaData + 0x40, 0x0)
	if bit.band(areaType, 0x800) > 0 then
		disableTeleport = true
	else
		local areaRES = IEex_ReadLString(areaData, 8)
--[[
		if areaRES == "AR4102" and ((targetX >= 400 and targetX <= 970 and targetY >= 1030 and targetY <= 1350) or (destinationX >= 400 and destinationX <= 970 and destinationY >= 1030 and destinationY <= 1350)) then
			disableTeleport = true
		end
--]]
		if ex_specific_teleport_zone[areaRES] ~= nil then
			local noTeleportMapWrapper = IEex_DemandRes(areaRES .. "NT", "BMP")
			if noTeleportMapWrapper:isValid() then
				local noTeleportMapData = noTeleportMapWrapper:getData()
				local currentZone = IEex_GetBitmapPixelIndex(noTeleportMapData, math.floor(targetX / 16), math.floor(targetY / 12))
				local destinationZone = IEex_GetBitmapPixelIndex(noTeleportMapData, math.floor(destinationX / 16), math.floor(destinationY / 12))
				if currentZone ~= destinationZone then
					disableTeleport = true
				end
			end
			noTeleportMapWrapper:free()
		end
	end
--[[
	if destinationX <= 0 and destinationY <= 0 then
		destinationX = targetX
		destinationY = targetY
	end
--]]
	if disableTeleport == false then
		if (destinationX > 0 or destinationY > 0) then
--			IEex_EvaluatePersistentEffects(targetID)
--[[
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
--]]
--			local newDirection = IEex_GetActorRequiredDirection(targetID, destinationX, destinationY)
			IEex_JumpActorToPoint(targetID, destinationX, destinationY, true)
--[[
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
--]]
--[[
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = newDirection,
["resource"] = "MEFACE",
["parent_resource"] = "USTELMOV",
["source_id"] = targetID
})
--]]
--			IEex_WriteByte(creatureData + 0x537E, newDirection)
--			IEex_WriteByte(creatureData + 0x5380, (newDirection + 1) % 16)
--[[
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
--]]
		end
	end
end

ex_ghostwalk_dest = {}
ex_ghostwalk_direction = {}
ex_ghostwalk_area = {}
ex_ghostwalk_offsets = {{-20, -20}, {0, -20}, {20, -20}, {20, 0}, {20, 20}, {0, 20}, {-20, 20}, {-20, 0}, {-10, -30}, {10, -30}, {30, -10}, {30, 10}, {10, 30}, {-10, 30}, {-30, 10}, {-30, -10}}
ex_ghostwalk_positions = {}
ex_ghostwalk_actors = {}
function MEGHOSTW(effectData, creatureData, isSpecialCall)
	if not isSpecialCall then return end
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local sourceID = IEex_GetActorIDShare(creatureData)
	if IEex_ReadDword(effectData + 0x10C) <= 0 or bit.band(IEex_ReadDword(effectData + 0xC8), 0x10) == 0 then
		IEex_WriteDword(effectData + 0x10C, sourceID)
		IEex_WriteDword(effectData + 0xC8, bit.bor(IEex_ReadDword(effectData + 0xC8), 0x10))
		ex_ghostwalk_dest["" .. sourceID] = nil
		ex_ghostwalk_area["" .. sourceID] = nil
	end
	local timeSlowed, targetNotSlowed = IEex_CheckGlobalEffectOnActor(sourceID, 0x2)
	if IEex_GetGameTick() % ex_time_slow_speed_divisor ~= 0 then
		if timeSlowed and not targetNotSlowed then return end
	end
--	if IEex_CheckForInfiniteLoop(sourceID, IEex_GetGameTick(), "MEGHOSTW", 0) then return end
--	if not IEex_GetActorSpellState(sourceID, 184) and not IEex_GetActorSpellState(sourceID, 189) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local parameter4 = IEex_ReadDword(effectData + 0x60)
--	local movementRate = IEex_ReadByte(creatureData + 0x72EA, 0x0)
	local movementRate = 9
	IEex_IterateActorEffects(sourceID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		if theopcode == 266 then
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if bit.band(thesavingthrow, 0x100000) == 0 then
				if theparameter2 == 0 then
					movementRate = movementRate + theparameter1
				elseif theparameter2 == 1 then
					movementRate = theparameter1
				elseif theparameter2 == 2 then
					movementRate = math.floor(movementRate * theparameter1 / 100)
				end
			end
		end
	end)
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
		if bit.band(areaType, 0x800) > 0 then
			disableTeleport = true
		elseif bit.band(areaType, 0x1) == 0 and not IEex_GetActorSpellState(sourceID, 182) and not IEex_GetActorSpellState(sourceID, 189) then
			disableTeleport = true
--[[
		else
			if areaRES == "AR4102" and (targetX >= 400 and targetX <= 970 and targetY >= 1030 and targetY <= 1350) then
				disableTeleport = true
			end
--]]
		end
	end
	if parameter4 == 0 or (areaRES ~= "" and ex_ghostwalk_area["" .. sourceID] ~= areaRES) then
		IEex_WriteDword(effectData + 0x60, 1)
		ex_ghostwalk_dest["" .. sourceID] = {0, 0}
	end
	if areaRES ~= "" then
		ex_ghostwalk_area["" .. sourceID] = areaRES
	end
	local storedX = 0
	local storedY = 0
	if ex_ghostwalk_dest["" .. sourceID] ~= nil then		
		storedX = ex_ghostwalk_dest["" .. sourceID][1]
		storedY = ex_ghostwalk_dest["" .. sourceID][2]
	end
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
		local resWrapper = IEex_DemandRes(IEex_GetActorSpellRES(sourceID), "SPL")
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
	if IEex_IsSprite(targetID, true) and targetID ~= sourceID then
		local targetShare = IEex_GetActorShare(targetID)
		local newDirection = IEex_GetActorRequiredDirection(sourceID, IEex_ReadDword(targetShare + 0x6), IEex_ReadDword(targetShare + 0xA))
		ex_ghostwalk_direction[sourceID] = newDirection
		IEex_WriteWord(creatureData + 0x537C, 0)
		IEex_WriteByte(creatureData + 0x537E, (newDirection + 1) % 16)
		IEex_WriteByte(creatureData + 0x5380, newDirection)
	elseif math.abs(destinationX - targetX) > 50 or math.abs(destinationY - targetY) > 50 then
		local newDirection = IEex_GetActorRequiredDirection(sourceID, destinationX, destinationY)
		ex_ghostwalk_direction[sourceID] = newDirection
		IEex_WriteWord(creatureData + 0x537C, 0)
		IEex_WriteByte(creatureData + 0x537E, (newDirection + 1) % 16)
		IEex_WriteByte(creatureData + 0x5380, newDirection)
	elseif ex_ghostwalk_direction[sourceID] ~= nil then
		local newDirection = ex_ghostwalk_direction[sourceID]
		IEex_WriteWord(creatureData + 0x537C, 0)
		IEex_WriteByte(creatureData + 0x537E, (newDirection + 1) % 16)
		IEex_WriteByte(creatureData + 0x5380, newDirection)
	end

	local finalX = targetX + deltaX
	local finalY = targetY + deltaY
	if IEex_IsGamePaused() then
		finalX = targetX
		finalY = targetY
	elseif movementRate >= dist then
		finalX = destinationX
		finalY = destinationY
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
	if ex_specific_teleport_zone[areaRES] ~= nil then
		local noTeleportMapWrapper = IEex_DemandRes(areaRES .. "NT", "BMP")
		if noTeleportMapWrapper:isValid() then
			local noTeleportMapData = noTeleportMapWrapper:getData()
			local currentZone = IEex_GetBitmapPixelIndex(noTeleportMapData, math.floor(targetX / 16), math.floor(targetY / 12))
			local destinationZone = IEex_GetBitmapPixelIndex(noTeleportMapData, math.floor(finalX / 16), math.floor(finalY / 12))
			if currentZone ~= destinationZone then
				disableTeleport = true
			end
		end
		noTeleportMapWrapper:free()
	end
	if not disableTeleport then
--		IEex_EvaluatePersistentEffects(sourceID)
		IEex_JumpActorToPoint(sourceID, finalX, finalY, true)
--[[
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
--]]
	end
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
	if ex_flying_animation[animation] ~= nil or IEex_GetActorSpellState(actorID, 181) or IEex_GetActorSpellState(actorID, 182) or IEex_GetActorSpellState(actorID, 184) or IEex_GetActorSpellState(actorID, 189) then
		isFlying = true
	end
	return isFlying
end

function IEex_CanFly(actorID)
	if not IEex_IsSprite(actorID, false) then return false end
	local isFlying = false
	local animation = IEex_ReadDword(IEex_GetActorShare(actorID) + 0x5C4)
	if ex_can_fly_animation[animation] ~= nil or IEex_GetActorSpellState(actorID, 181) or IEex_GetActorSpellState(actorID, 182) or IEex_GetActorSpellState(actorID, 184) or IEex_GetActorSpellState(actorID, 189) then
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

function MEUNSTUC(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 124,
["target"] = 2,
["timing"] = 1,
["target_x"] = IEex_ReadDword(creatureData + 0x6),
["target_y"] = IEex_ReadDword(creatureData + 0xA),
["parent_resource"] = "USUNSTUC",
["source_id"] = targetID
})
end

ex_ceiling_height = {["AR1000"] = 32767, ["AR1001"] = 140, ["AR1002"] = 140, ["AR1003"] = 55, ["AR1004"] = 75, ["AR1005"] = 65, ["AR1006"] = 75, ["AR1007"] = 110, ["AR1100"] = 32767, ["AR1101"] = 85, ["AR1102"] = 75, ["AR1103"] = 60, ["AR1104"] = 70, ["AR1105"] = 0, ["AR1106"] = 70, ["AR1107"] = 70, ["AR1200"] = 32767, ["AR1201"] = 75, ["AR2000"] = 32767, ["AR2001"] = 32767, ["AR2002"] = 180, ["AR2100"] = 32767, ["AR2101"] = 32767, ["AR2102"] = 32767, ["AR3000"] = 32767, ["AR3001"] = 160, ["AR3002"] = 170, ["AR3100"] = 32767, ["AR3101"] = 80, ["AR4000"] = 32767, ["AR4001"] = 70, ["AR4100"] = 32767, ["AR4101"] = 90, ["AR4102"] = 90, ["AR4103"] = 90, ["AR5000"] = 32767, ["AR5001"] = 32767, ["AR5002"] = 80, ["AR5004"] = 32767, ["AR5005"] = 32767, ["AR5010"] = 32767, ["AR5011"] = 32767, ["AR5012"] = 32767, ["AR5013"] = 32767, ["AR5014"] = 32767, ["AR5015"] = 32767, ["AR5016"] = 32767, ["AR5017"] = 32767, ["AR5018"] = 32767, ["AR5019"] = 32767, ["AR5020"] = 32767, ["AR5021"] = 32767, ["AR5022"] = 32767, ["AR5023"] = 32767, ["AR5024"] = 32767, ["AR5025"] = 32767, ["AR5026"] = 32767, ["AR5027"] = 32767, ["AR5028"] = 32767, ["AR5029"] = 32767, ["AR5030"] = 32767, ["AR5100"] = 200, ["AR5101"] = 170, ["AR5102"] = 110, ["AR5200"] = 32767, ["AR5201"] = 120, ["AR5202"] = 110, ["AR5203"] = 300, ["AR5300"] = 200, ["AR5301"] = 160, ["AR5302"] = 80, ["AR5303"] = 32767, ["AR6000"] = 32767, ["AR6001"] = 32767, ["AR6002"] = 32767, ["AR6003"] = 160, ["AR6004"] = 75, ["AR6005"] = 130, ["AR6006"] = 110, ["AR6007"] = 70, ["AR6008"] = 320, ["AR6009"] = 250, ["AR6010"] = 110, ["AR6050"] = 32767, ["AR6051"] = 150, ["AR6100"] = 32767, ["AR6101"] = 190, ["AR6102"] = 170, ["AR6103"] = 140, ["AR6104"] = 220, ["AR6200"] = 32767, ["AR6201"] = 32767, ["AR6300"] = 32767, ["AR6301"] = 310, ["AR6302"] = 320, ["AR6303"] = 170, ["AR6304"] = 200, ["AR6305"] = 170, ["AR6400"] = 32767, ["AR6401"] = 100, ["AR6402"] = 270, ["AR6403"] = 140, ["AR6500"] = 250, ["AR6501"] = 320, ["AR6502"] = 120, ["AR6503"] = 100, ["AR6600"] = 200, ["AR6601"] = 160, ["AR6602"] = 110, ["AR6603"] = 215, ["AR6700"] = 95, ["AR6701"] = 110, ["AR6702"] = 230, ["AR6703"] = 32767, ["AR6800"] = 32767, }
ex_specific_floor_height = {["AR3000"] = {[0xFF00] = -750}, ["AR5200"] = {[0xFF00] = -500}, ["AR5300"] = {[0xFF00] = -1500}, ["AR5303"] = {[0xFF00] = -4000}, ["AR6000"] = {[0xFF00] = -900}, ["AR6001"] = {[0xFF00] = -4800}, ["AR6051"] = {[0xFF00] = -300}, ["AR6104"] = {[0xFF00] = -20}, ["AR6300"] = {[0xFF00] = -120}, ["AR6302"] = {[0xFF00] = -900}, ["AR6303"] = {[0xFF00] = -900}, ["AR6304"] = {[0xFF00] = -900}, ["AR6305"] = {[0xFF00] = -900}, ["AR6400"] = {[0xFF00] = -3500}, ["AR6703"] = {[0xFF00] = -5800}, ["AR6800"] = {[0xFF00] = -5000}, }
ex_specific_floor_spell = {["AR6051"] = {[0xFF00] = "USFL6051"}, ["AR6104"] = {[0xFF00] = "USFL6104"}, ["AR6300"] = {[0xFF00] = "USFL6300"}, }
ex_specific_teleport_zone = {["AR4102"] = true, ["AR5202"] = true, }
function MEHGTMOD(effectData, creatureData)
	if true then return end
end
function IEex_HeightMod(creatureData)
--	print(IEex_ReadDword(effectData + 0xC))
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = targetID
	local savingthrow = 0
	local parent_resource = ""
	local spellRES = ""
	local casterlvl = 1
	local internalFlags = 0
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
		if bit.band(areaType, 0x800) > 0 then
			disableTeleport = true
--		elseif bit.band(areaType, 0x1) == 0 and not IEex_GetActorSpellState(sourceID, 189) then
--			disableTeleport = true
--[[
		else
			if areaRES == "AR4102" and (targetX >= 400 and targetX <= 970 and targetY >= 1030 and targetY <= 1350) then
				disableTeleport = true
			end
--]]
		end
	end
	if ex_ceiling_height[areaRES] ~= nil then
		roofHeight = ex_ceiling_height[areaRES] * 2
	end
	local animation = IEex_ReadDword(creatureData + 0x5C4)
	local height = IEex_ReadSignedWord(creatureData + 0x720, 0x0)
	local speed = IEex_ReadSignedWord(creatureData + 0x722, 0x0)
	local accel = IEex_ReadSignedWord(creatureData + 0x724, 0x0)
	if height == -1 and speed == -1 and accel == -1 then
		height = 0
		speed = 0
		accel = -2
		IEex_WriteWord(creatureData + 0x720, height)
		IEex_WriteWord(creatureData + 0x722, speed)
		IEex_WriteWord(creatureData + 0x724, accel)
	end
	local extraSpeed = 0
	local extraAccel = 0
	local minHeight = 0
	local maxHeight = 0
	local minSpeed = 0
	local previousHeight = height
	local floorSpellRES = ""
	local targetX, targetY = IEex_GetActorLocation(targetID)
	if ex_specific_floor_height[areaRES] ~= nil and not IEex_IsFlying(targetID) then
		local resWrapper = IEex_DemandRes(areaRES .. "H2", "BMP")
		if resWrapper:isValid() then
			local bitmapData = resWrapper:getData()
			
			local specificFloorHeight = IEex_GetBitmapPixelColor(bitmapData, math.floor(targetX / 16), math.floor(targetY / 12))
			if ex_specific_floor_height[areaRES][specificFloorHeight] ~= nil then
				minHeight = ex_specific_floor_height[areaRES][specificFloorHeight]
			end
			if ex_specific_floor_spell[areaRES] ~= nil and ex_specific_floor_spell[areaRES][specificFloorHeight] ~= nil then
				floorSpellRES = ex_specific_floor_spell[areaRES][specificFloorHeight]
			end
		end
		resWrapper:free()
	end
	local centerHeight = minHeight
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		local theresource = IEex_ReadLString(eData + 0x30, 8)
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
		elseif theopcode == 500 and theresource == "MEHGTMOD" then
			spellRES = IEex_ReadLString(eData + 0x1C, 8)
			savingthrow = IEex_ReadDword(eData + 0x40)
			parent_resource = IEex_ReadLString(eData + 0x94, 8)
			casterlvl = IEex_ReadDword(eData + 0xC8)
			internalFlags = IEex_ReadDword(eData + 0xCC)
			if spellRES == "" and #parent_resource < 8 then
				spellRES = parent_resource .. "E"
			end
			if IEex_ReadDword(eData + 0x110) > 0 then
				sourceID = IEex_ReadDword(eData + 0x110)
			end
		end
	end)
	if IEex_GetActorSpellState(targetID, 181) or IEex_GetActorSpellState(targetID, 182) or IEex_GetActorSpellState(targetID, 184) or IEex_GetActorSpellState(targetID, 189) then
		local isSelected = false
		for i, id in ipairs(IEex_GetAllActorIDSelected()) do
			if id == targetID then
				isSelected = true
			end
		end
		if IEex_IsKeyDown(160) and isSelected and height <= 500 then
			extraSpeed = extraSpeed + 5
			if accel == -1 or accel == -2 then
				accel = 0
			end
		end
		if IEex_IsKeyDown(161) and isSelected then
			extraSpeed = extraSpeed - 5
			if accel == -1 or accel == -2 then
				accel = 0
			end
		end
		if speed <= 0 and (accel == -1 or accel == -2) and IEex_GetActorSpellState(targetID, 189) then
			speed = 0
			accel = 0
		end
	end
	accel = accel + extraAccel
	if minSpeed == 0 then
		minSpeed = -32768
	end
	if height >= 50 then

	end
	if height > minHeight then
		IEex_WriteByte(creatureData + 0x9DC, 1)
	end
	if height == 0 and speed + extraSpeed == 0 and accel <= 0 and minHeight == 0 and not IEex_GetActorSpellState(targetID, 190) then return end
	local timeSlowed, targetNotSlowed = IEex_CheckGlobalEffectOnActor(targetID, 0x2)
	if IEex_GetGameTick() % ex_time_slow_speed_divisor ~= 0 then
		if timeSlowed and not targetNotSlowed then
			IEex_WriteDword(creatureData + 0x5326, 0)
			return true
		end
	end
	if ((bit.band(areaType, 0x1) == 0 and not IEex_GetActorSpellState(targetID, 182) and not IEex_GetActorSpellState(targetID, 189)) or disableTeleport) and IEex_GetActorStat(targetID, 75) > 0 then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
			if theopcode == 184 and theparent_resource == parent_resource then
				IEex_WriteDword(eData + 0x20, 0)
				IEex_WriteByte(creatureData + 0x9DC, 0)
			end
		end)
	elseif (bit.band(areaType, 0x1) > 0 or IEex_GetActorSpellState(targetID, 182) or IEex_GetActorSpellState(targetID, 189)) and not disableTeleport and IEex_GetActorStat(targetID, 75) == 0 then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
			if theopcode == 184 and theparent_resource == parent_resource then
				IEex_WriteDword(eData + 0x20, 1)
				IEex_WriteByte(creatureData + 0x9DC, 1)
			end
		end)
	end
--[[
	if minHeight < 0 then
		minHeight = 0
	end
--]]
	if maxHeight <= 0 or maxHeight > 10000 then
		maxHeight = 10000
	end
	if maxHeight > (roofHeight - targetHeight) and not IEex_GetActorSpellState(targetID, 182) and not IEex_GetActorSpellState(targetID, 189) then
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
			if speed >= 33 and maxHeight < 10000 and not IEex_GetActorSpellState(targetID, 182) and not IEex_GetActorSpellState(targetID, 189) then
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
["internal_flags"] = internalFlags,
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
			if speed <= -33 and (minHeight <= 0 or bit.band(savingthrow, 0x10000) > 0) and not IEex_GetActorSpellState(targetID, 182) and not IEex_GetActorSpellState(targetID, 189) then
				local damageDice = math.floor(math.abs(speed + 30) / 3)
				if damageDice > 100 then
					damageDice = 100
				end
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 208,
["target"] = 2,
["timing"] = 0,
["duration"] = 2,
["parameter1"] = -2,
["parent_resource"] = "MEFALDMG",
["source_target"] = targetID,
["source_id"] = sourceID
})
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = 0x600 + damageDice * 0x10000,
["savingthrow"] = 0x90000,
["resource"] = "EXDAMAGE",
["parent_resource"] = "MEFALDMG",
["internal_flags"] = internalFlags,
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
			if speed >= 33 and maxHeight < 10000 and not IEex_GetActorSpellState(targetID, 182) and not IEex_GetActorSpellState(targetID, 189) then
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
["internal_flags"] = internalFlags,
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
--	if bit.band(IEex_ReadDword(creatureData + 0x434), 0x2000) > 0 then return end

	IEex_WriteDword(creatureData + 0x5326, 0)
	if (minHeight <= 0 or bit.band(savingthrow, 0x10000) > 0) and bit.band(savingthrow, 0x20000) == 0 and (height <= minHeight and speed <= 0 and accel <= 0) then 

		IEex_WriteWord(creatureData + 0x722, 0)
		IEex_WriteWord(creatureData + 0x724, -2)
--[[
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
			if theparent_resource == parent_resource and parent_resource ~= "" then
				if theopcode == 184 then
					IEex_WriteDword(eData + 0x20, 0)
					IEex_WriteByte(creatureData + 0x9DC, 0)
				end
				IEex_WriteDword(eData + 0x114, 1)
			end
		end)
--]]
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = parent_resource,
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = sourceID
})
--		IEex_WriteDword(creatureData + 0xE, 0)
		if bit.band(savingthrow, 0x80000) > 0 and spellRES ~= "" then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 9,
["resource"] = spellRES,
["parent_resource"] = spellRES,
["internal_flags"] = internalFlags,
["source_x"] = IEex_ReadDword(creatureData + 0x6),
["source_y"] = IEex_ReadDword(creatureData + 0xA),
["target_x"] = IEex_ReadDword(creatureData + 0x6),
["target_y"] = IEex_ReadDword(creatureData + 0xA),
["source_target"] = targetID,
["source_id"] = sourceID
})
		end
		if floorSpellRES ~= "" then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 9,
["resource"] = floorSpellRES,
["parent_resource"] = floorSpellRES,
["internal_flags"] = internalFlags,
["source_x"] = IEex_ReadDword(creatureData + 0x6),
["source_y"] = IEex_ReadDword(creatureData + 0xA),
["target_x"] = IEex_ReadDword(creatureData + 0x6),
["target_y"] = IEex_ReadDword(creatureData + 0xA),
["source_target"] = targetID,
["source_id"] = sourceID
})
		end
		if minHeight <= 0 and IEex_IsSprite(targetID, false) then
--			height = 0
		end
		if (not IEex_GetActorSpellState(targetID, 182) and not IEex_GetActorSpellState(targetID, 189)) and targetID ~= IEex_GetActorIDCharacter(0) and targetID ~= IEex_GetActorIDCharacter(1) and targetID ~= IEex_GetActorIDCharacter(2) and targetID ~= IEex_GetActorIDCharacter(3) and targetID ~= IEex_GetActorIDCharacter(4) and targetID ~= IEex_GetActorIDCharacter(5) then
			IEex_WriteByte(creatureData + 0x9DC, 0)
--			IEex_JumpActorToPoint(targetID, targetX, targetY, true)

			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 3,
["duration"] = 1,
["resource"] = "MEUNSTUC",
["source_target"] = targetID,
["source_id"] = targetID
})

		end
	end
	IEex_WriteWord(creatureData + 0x720, height)
	IEex_WriteWord(creatureData + 0x722, speed)
	local visualHeight = -math.ceil(height / 2)
	if visualHeight == -0 then
		visualHeight = 0
	end

	IEex_WriteDword(creatureData + 0xE, visualHeight)
	return true
end

ex_outdoor_flight_terrain_table = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, -1, 5}
ex_indoor_flight_terrain_table = {-1, 5, 5, 5, 5, 5, 5, 5, 5, 5, -1, 5, 5, -1, -1, 5}

ex_default_terrain_table_1 = {-1, 5, 5, 5, 5, 5, 5, 5, -1, 5, -1, 5, -1, -1, -1, 5}
ex_default_terrain_table_2 = {-1, 5, 5, 5, 5, 5, 5, 5, 5, 5, -1, 5, 5, -1, 5, 5}
ex_default_terrain_table_3 = {-1, 5, 5, 5, 5, 5, 5, 5, 5, 5, -1, 5, 5, -1, 5, 5}

function IEex_ModifyTerrainTable(offset, terraintable)
	for i = 1, 16, 1 do
		IEex_WriteByte(offset + i - 1, terraintable[i])
	end
end

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

function MEACTIVA(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	if targetID <= 0 or not IEex_IsSprite(targetID, true) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	IEex_WriteByte(creatureData + 0x838, parameter1)
end

function MECIRCLE(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	if targetID <= 0 or not IEex_IsSprite(targetID, true) then return end
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local animationData = IEex_ReadDword(creatureData + 0x50F0)
	if bit.band(savingthrow, 0x10000) == 0 then
		if parameter2 == 0 then
			IEex_WriteDword(animationData + 0x8, IEex_ReadDword(animationData + 0x8) - parameter1)
			IEex_WriteDword(animationData + 0xC, IEex_ReadDword(animationData + 0xC) - math.floor(parameter1 * 3 / 4))
			IEex_WriteDword(animationData + 0x10, IEex_ReadDword(animationData + 0x10) + parameter1)
			IEex_WriteDword(animationData + 0xC, IEex_ReadDword(animationData + 0x14) + math.floor(parameter1 * 3 / 4))
		elseif parameter2 == 1 then
			IEex_WriteDword(animationData + 0x8, 0 - parameter1)
			IEex_WriteDword(animationData + 0xC, 0 - math.floor(parameter1 * 3 / 4))
			IEex_WriteDword(animationData + 0x10, parameter1)
			IEex_WriteDword(animationData + 0xC, math.floor(parameter1 * 3 / 4))
		elseif parameter2 == 2 then
			IEex_WriteDword(animationData + 0x8, math.floor(IEex_ReadDword(animationData + 0x8) * parameter1 / 100))
			IEex_WriteDword(animationData + 0xC, math.floor(IEex_ReadDword(animationData + 0xC) * parameter1 / 100))
			IEex_WriteDword(animationData + 0x10, math.floor(IEex_ReadDword(animationData + 0x10) * parameter1 / 100))
			IEex_WriteDword(animationData + 0x14, math.floor(IEex_ReadDword(animationData + 0x14) * parameter1 / 100))
		end
	else
		if parameter2 == 0 then
			IEex_WriteByte(animationData + 0x3E4, IEex_ReadByte(animationData + 0x3E4, 0x0) + parameter1)
		elseif parameter2 == 1 then
			IEex_WriteByte(animationData + 0x3E4, parameter1)
		elseif parameter2 == 2 then
			IEex_WriteByte(animationData + 0x3E4, math.floor(IEex_ReadByte(animationData + 0x3E4, 0x0) * parameter1 / 100))
		end
	end
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
			if bit.band(IEex_ReadDword(containerData + 0x88E), 0x20) == 0 and IEex_ReadWord(containerData + 0x892, 0x0) ~= 100 and IEex_ReadWord(containerData + 0x896, 0x0) > 0 then
				IEex_WriteWord(containerData + 0x898, 1)
				IEex_WriteWord(containerData + 0x8D0, 362)
			end
		end
	end)
	IEex_IterateIDs(areaData, 0x21, true, true, function(id)
		local doorData = IEex_GetActorShare(id)
		if special <= 0 or IEex_GetDistance(targetx, targety, IEex_ReadDword(doorData + 0x6), IEex_ReadDword(doorData + 0xA)) < special then
			local doorFlags = IEex_ReadDword(doorData + 0x5C4)
			if bit.band(doorFlags, 0x8) > 0 and (bit.band(doorFlags, 0x80) == 0 or bit.band(doorFlags, 0x100) > 0) and bit.band(doorFlags, 0x2000) == 0 and IEex_ReadWord(doorData + 0x648, 0x0) ~= 100 and IEex_ReadWord(doorData + 0x64C, 0x0) > 0 then
				IEex_WriteWord(doorData + 0x64E, 1)
				IEex_WriteWord(doorData + 0x664, 362)
			end
		end
	end)
	IEex_IterateIDs(areaData, 0x41, true, true, function(id)
		local triggerData = IEex_GetActorShare(id)
		if special <= 0 or IEex_GetDistance(targetx, targety, IEex_ReadDword(triggerData + 0x6), IEex_ReadDword(triggerData + 0xA)) < special then
			local triggerFlags = IEex_ReadDword(triggerData + 0x5D6)
			if IEex_ReadWord(triggerData + 0x598, 0x0) == 0 and bit.band(triggerFlags, 0x8) > 0 and bit.band(triggerFlags, 0x100) == 0 and IEex_ReadWord(triggerData + 0x60E, 0x0) ~= 100 and IEex_ReadWord(triggerData + 0x612, 0x0) > 0 then
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
	IEex_WriteDword(creatureData + 0x5BC, bit.band(IEex_ReadDword(creatureData + 0x5BC), 0xEFFFFFFF))
	IEex_WriteDword(creatureData + 0x920, bit.band(IEex_ReadDword(creatureData + 0x920), 0xEFFFFFFF))
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
				targetIsFiendSummoner = (bit.band(IEex_ReadDword(eData + 0x40), 0x100000) > 0)
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
				local applyOnReload = (bit.band(thesavingthrow, 0x100000) > 0)
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
					if (bit.band(thesavingthrow, 0x200000) > 0) then
						newEffectTarget = targetID
						newEffectTargetX = IEex_ReadDword(effectData + 0x84)
						newEffectTargetY = IEex_ReadDword(effectData + 0x88)
					end
					local newEffectSource = targetID
					local newEffectSourceX = IEex_ReadDword(effectData + 0x84)
					local newEffectSourceY = IEex_ReadDword(effectData + 0x88)
					if (bit.band(thesavingthrow, 0x400000) > 0) then
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
["opcode"] = 288,
["target"] = 2,
["timing"] = 1,
["parameter1"] = 1,
["parameter2"] = 224,
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
	if summonerData <= 0 or IEex_GetActorState(summonerID, 0xFC0) then return end
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
ex_simulacrum_copied_fields = {
{0x24, 0x28, 1},
{0x34, 0x35, 1},
{0x38, 0x38, 4},
{0x5C8, 0x5CE, 1},
{0x5E2, 0x5EA, 2},
{0x5F0, 0x604, 1},
{0x648, 0x744, 4},
{0x758, 0x758, 2},
{0x75C, 0x770, 4},
{0x774, 0x7B3, 1},
{0x7B4, 0x7C3, 1},
{0x7F7, 0x807, 1},
{0x89F, 0x89F, 1},
{0x962, 0x962, 4},
{0x17BA, 0x17BA, 4},
{0x3E12, 0x3E12, 4},
{0x3E4E, 0x3E4E, 4},
}

ex_caster_type_spell_slots = {
{"MXSPLBRD", 42},
{"MXSPLCLR", 39},
{"MXSPLDRD", 39},
{"MXSPLPAL", 39},
{"MXSPLRGR", 39},
{"MXSPLSOR", 42},
{"MXSPLWIZ", 38},
}
function MESIMULA(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local summonerID = IEex_ReadDword(creatureData + 0x72C)
	local summonerData = IEex_GetActorShare(summonerID)
	if not IEex_IsSprite(summonerID, false) then return end
	local extraFlags = IEex_ReadDword(creatureData + 0x740)
	extraFlags = bit.bor(extraFlags, 0x400000)
	IEex_WriteDword(creatureData + 0x740, extraFlags)
	local newHP = math.ceil(IEex_ReadSignedWord(summonerData + 0x5C2, 0x0) / 2)
--	IEex_WriteWord(creatureData + 0x5C0, newHP)
--	IEex_WriteWord(creatureData + 0x5C2, newHP)
	local newLevelTotal = 0
--[[
	local casterTypes = {9, }
	local newCasterLevels = {0, 0, 0, 0, 0, 0, 0, 0}
	local newSpellSlots = {{0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, }
--]]
	for iClass = 1, 11, 1 do
		local newLevel = math.ceil(IEex_ReadByte(summonerData + 0x626 + iClass, 0x0) / 2)
		newLevelTotal = newLevelTotal + newLevel
		IEex_WriteByte(creatureData + 0x626 + iClass, newLevel)
--[[
		local iCasterType = IEex_CasterClassToType[iClass]
		if newLevel > 0 and iCasterType ~= nil then
			table.insert(casterTypes, IEex_CasterClassToType[iClass])
			newCasterLevels[iCasterType] = newLevel
			if iClass == 3 then
				table.insert(casterTypes, 8)
				newCasterLevels[8] = newLevel
			end
		end
--]]
	end
	IEex_WriteByte(creatureData + 0x626, newLevelTotal)
	for k, offset in ipairs(ex_simulacrum_copied_fields) do
		if offset[3] == 1 then
			for i = offset[1], offset[2], 1 do
				IEex_WriteByte(creatureData + i, IEex_ReadSignedByte(summonerData + i, 0x0))
			end
		elseif offset[3] == 2 then
			for i = offset[1], offset[2], 2 do
				IEex_WriteWord(creatureData + i, IEex_ReadSignedWord(summonerData + i, 0x0))
			end
		elseif offset[3] == 4 then
			for i = offset[1], offset[2], 4 do
				IEex_WriteDword(creatureData + i, IEex_ReadDword(summonerData + i))
			end
		else
			for i = offset[1], offset[2], offset[3] do
				IEex_WriteLString(creatureData + i, IEex_ReadLString(summonerData + i, offset[3]), offset[3])
			end
		end
	end

	IEex_IterateActorEffects(summonerID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local thetiming = IEex_ReadDword(eData + 0x24)
		if thetiming == 9 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = IEex_ReadDword(eData + 0x10),
["target"] = IEex_ReadDword(eData + 0x14),
["power"] = IEex_ReadDword(eData + 0x18),
["parameter1"] = IEex_ReadDword(eData + 0x1C),
["parameter2"] = IEex_ReadDword(eData + 0x20),
["timing"] = IEex_ReadDword(eData + 0x24),
["duration"] = IEex_ReadDword(eData + 0x28),
["resource"] = IEex_ReadLString(eData + 0x30, 8),
["dicenumber"] = IEex_ReadDword(eData + 0x38),
["dicesize"] = IEex_ReadDword(eData + 0x3C),
["savingthrow"] = IEex_ReadDword(eData + 0x40),
["savebonus"] = IEex_ReadDword(eData + 0x44),
["special"] = IEex_ReadDword(eData + 0x48),
["school"] = IEex_ReadDword(eData + 0x4C),
["parameter3"] = IEex_ReadDword(eData + 0x60),
["parameter4"] = IEex_ReadDword(eData + 0x64),
["parameter5"] = IEex_ReadDword(eData + 0x68),
["time_applied"] = IEex_ReadDword(eData + 0x6C),
["vvcresource"] = IEex_ReadLString(eData + 0x70, 8),
["resource2"] = IEex_ReadLString(eData + 0x78, 8),
["source_x"] = IEex_ReadDword(eData + 0x80),
["source_y"] = IEex_ReadDword(eData + 0x84),
["target_x"] = IEex_ReadDword(eData + 0x88),
["target_y"] = IEex_ReadDword(eData + 0x8C),
["restype"] = IEex_ReadDword(eData + 0x90),
["parent_resource"] = IEex_ReadLString(eData + 0x94, 8),
["resource_flags"] = bit.band(IEex_ReadDword(eData + 0x9C), 0xFFFFF9FF),
["impact_projectile"] = IEex_ReadDword(eData + 0xA0),
["sourceslot"] = IEex_ReadDword(eData + 0xA4),
["effvar"] = IEex_ReadLString(eData + 0xA8, 32),
["casterlvl"] = IEex_ReadDword(eData + 0xC8),
["internal_flags"] = IEex_ReadDword(eData + 0xCC),
["sectype"] = IEex_ReadDword(eData + 0xD0),
["source_id"] = IEex_ReadDword(eData + 0x110),
})
		end
	end)
--[[
	for iCasterType = 1, 7, 1 do
		local newLevel = newCasterLevels[iCasterType]
		if newLevel > 0 then
			for iLevel = 1, 9, 1 do
				local numSlots = tonumber(IEex_2DAGetAtStrings(ex_caster_type_spell_slots[iCasterType][1], tostring(iLevel), tostring(newLevel)))
				if numSlots > 0 then
					numSlots = numSlots + tonumber(IEex_2DAGetAtStrings("MXSPLBON", tostring(iLevel), tostring(IEex_GetActorStat(summonerID, ex_caster_type_spell_slots[iCasterType][2]))))
					if iCasterType == 3 then
						newSpellSlots[8][iLevel] = 1
					end
				end
				newSpellSlots[iCasterType][iLevel] = numSlots
			end
		end
	end
	local summonerSpells = IEex_FetchSpellInfo(summonerID, casterTypes)
	for cType, levelList in pairs(summonerSpells) do
		for i = 1, 9, 1 do
			if #levelList >= i then
				local numSlots = 0
				if newSpellSlots[cType] ~= nil and newSpellSlots[cType][i] ~= nil then
					numSlots = newSpellSlots[cType][i]
				end
				local levelI = levelList[i]
				local maxCastable = levelI[1]
				local sorcererCastableCount = levelI[2]
				local levelISpells = levelI[3]
				if levelISpells ~= nil and #levelISpells > 0 then
					if cType == 1 or cType == 6 then
						if numSlots > sorcererCastableCount then
							numSlots = sorcererCastableCount
						end
						if numSlots > 0 then
							IEex_AlterSpellInfo(targetID, cType, i, "", numSlots, numSlots)
							for i2, spell in ipairs(levelISpells) do
								IEex_AlterSpellInfo(targetID, cType, i, spell["resref"], numSlots, numSlots)
							end
							IEex_AlterSpellInfo(targetID, cType, i, "", numSlots, numSlots)
						end
					elseif cType <= 8 then
						if numSlots > 0 then
							for i2, spell in ipairs(levelISpells) do
								local castableCount = spell["castableCount"]
								if castableCount > numSlots then
									castableCount = numSlots
								end
								if castableCount > 0 then
									IEex_AlterSpellInfo(targetID, cType, i, spell["resref"], castableCount, castableCount)
									numSlots = numSlots - castableCount
								end
							end
						end
					end
				end
			end
		end
	end
	if summonerSpells[9] ~= nil and summonerSpells[9][1] ~= nil then
		local levelISpells = summonerSpells[9][1]
		for i2, spell in ipairs(levelISpells) do
			local castableCount = spell["castableCount"]
			if castableCount > 0 then
				IEex_AlterSpellInfo(targetID, 9, 1, spell["resref"], spell["memorizedCount"], castableCount)
			end
		end
	end
--]]
	if newHP > 10 then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 18,
["target"] = 2,
["timing"] = 1,
["parameter1"] = newHP - 10,
["parameter2"] = 0,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 53,
["target"] = 2,
["timing"] = 1,
["parameter1"] = IEex_ReadDword(summonerData + 0x5C4),
["parameter2"] = 2,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 53,
["target"] = 2,
["timing"] = 0,
["duration"] = 1,
["parameter1"] = IEex_ReadDword(summonerData + 0x5C4),
["parameter2"] = 0,
["parent_resource"] = "USPOLYMO",
["source_id"] = targetID
})
	for buttonIndex = 0, 8, 1 do
		local buttonType = IEex_ReadDword(summonerData + 0x3D14 + buttonIndex * 0x4)
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 9,
["parameter1"] = buttonIndex,
["parameter2"] = buttonType,
["resource"] = "EXBUTTON",
["source_id"] = targetID
})
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 3,
["duration"] = 1,
["parameter1"] = summonerID,
["resource"] = "MESIMUL2",
["source_target"] = targetID,
["source_id"] = targetID
})
--	IEex_DS(IEex_FetchSpellInfo(targetID, casterTypes))
end

function MESIMUL2(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
--	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local summonerID = IEex_ReadDword(effectData + 0x18)
	local summonerData = IEex_GetActorShare(summonerID)
	if not IEex_IsSprite(summonerID, false) then return end
	local newLevelTotal = 0
	local casterTypes = {9, }
	local newCasterLevels = {0, 0, 0, 0, 0, 0, 0, 0}
	local newSpellSlots = {{0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0, 0}, }
	for iClass = 1, 11, 1 do
		local newLevel = IEex_ReadByte(creatureData + 0x626 + iClass, 0x0)
		local iCasterType = IEex_CasterClassToType[iClass]
		if newLevel > 0 and iCasterType ~= nil then
			table.insert(casterTypes, IEex_CasterClassToType[iClass])
			newCasterLevels[iCasterType] = newLevel
			if iClass == 3 then
				table.insert(casterTypes, 8)
				newCasterLevels[8] = newLevel
			end
		end
	end
	for iCasterType = 1, 7, 1 do
		local newLevel = newCasterLevels[iCasterType]
		if newLevel > 0 then
			for iLevel = 1, 9, 1 do
				local numSlots = tonumber(IEex_2DAGetAtStrings(ex_caster_type_spell_slots[iCasterType][1], tostring(iLevel), tostring(newLevel)))
				if numSlots > 0 then
					numSlots = numSlots + tonumber(IEex_2DAGetAtStrings("MXSPLBON", tostring(iLevel), tostring(IEex_GetActorStat(summonerID, ex_caster_type_spell_slots[iCasterType][2]))))
					if iCasterType == 3 then
						newSpellSlots[8][iLevel] = 1
					end
				end
				newSpellSlots[iCasterType][iLevel] = numSlots
			end
		end
	end
	local summonerSpells = IEex_FetchSpellInfo(summonerID, casterTypes)
	for cType, levelList in pairs(summonerSpells) do
		for i = 1, 9, 1 do
			if #levelList >= i then
				local numSlots = 0
				if newSpellSlots[cType] ~= nil and newSpellSlots[cType][i] ~= nil then
					numSlots = newSpellSlots[cType][i]
				end
				local levelI = levelList[i]
				local maxCastable = levelI[1]
				local sorcererCastableCount = levelI[2]
				local levelISpells = levelI[3]
				if levelISpells ~= nil and #levelISpells > 0 then
					if cType == 1 or cType == 6 then
						if numSlots > sorcererCastableCount then
							numSlots = sorcererCastableCount
						end
						if numSlots > 0 then
--							IEex_AlterSpellInfo(targetID, cType, i, "", numSlots, numSlots)
							for i2, spell in ipairs(levelISpells) do
								IEex_AlterSpellInfo(targetID, cType, i, spell["resref"], numSlots, numSlots)
							end
							IEex_AlterSpellInfo(targetID, cType, i, "", numSlots, numSlots)
						end
					elseif cType <= 8 then
						if numSlots > 0 then
							for i2, spell in ipairs(levelISpells) do
								local castableCount = spell["castableCount"]
								if castableCount > numSlots then
									castableCount = numSlots
								end
								if castableCount > 0 then
									IEex_AlterSpellInfo(targetID, cType, i, spell["resref"], castableCount, castableCount)
									numSlots = numSlots - castableCount
								end
							end
						end
					end
				end
			end
		end
	end
	if summonerSpells[9] ~= nil and summonerSpells[9][1] ~= nil then
		local levelISpells = summonerSpells[9][1]
		for i2, spell in ipairs(levelISpells) do
			local castableCount = spell["castableCount"]
			if castableCount > 0 then
				IEex_AlterSpellInfo(targetID, 9, 1, spell["resref"], spell["memorizedCount"], castableCount)
			end
		end
	end
end

function MEERUPT(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local sourceID = IEex_GetActorIDShare(creatureData)
	if sourceID <= 0 then return end
	local summonerID = IEex_ReadDword(creatureData + 0x72C)
--	IEex_WriteWord(creatureData + 0x730, 0)
	local summonerData = IEex_GetActorShare(summonerID)
	if summonerData <= 0 then return end
	local summonerX, summonerY = IEex_GetActorLocation(summonerID)
	IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = 30,
["resource"] = "METELEFI",
["source_x"] = summonerX,
["source_y"] = summonerY,
["target_x"] = summonerX,
["target_y"] = summonerY,
["source_id"] = sourceID
})
	IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 0,
["resource"] = spellRES,
["parent_resource"] = spellRES,
["source_x"] = summonerX,
["source_y"] = summonerY,
["target_x"] = summonerX,
["target_y"] = summonerY,
["source_id"] = sourceID
})
end

function MEERUPT2(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local sourceData = IEex_GetActorShare(sourceID)
	if sourceData <= 0 then return end
	local summonerID = IEex_ReadDword(sourceData + 0x72C)
--	IEex_WriteWord(creatureData + 0x730, 0)
	local summonerData = IEex_GetActorShare(summonerID)
	if summonerData <= 0 then return end
	local summonerX, summonerY = IEex_GetActorLocation(summonerID)
	local creatureName = IEex_ReadLString(sourceData + 0x598, 8)
	local casterlvl = 1
	IEex_IterateActorEffects(summonerID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theresource = IEex_ReadLString(eData + 0x30, 8)
		if theopcode == 0 and theresource == creatureName then
			casterlvl = IEex_ReadDword(eData + 0xC8)
		end
	end)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 430,
["target"] = 2,
["timing"] = 0,
["parameter2"] = 37,
["resource"] = spellRES,
["parent_resource"] = spellRES,
["source_x"] = IEex_ReadDword(effectData + 0x84),
["source_y"] = IEex_ReadDword(effectData + 0x88),
["target_x"] = IEex_ReadDword(effectData + 0x84),
["target_y"] = IEex_ReadDword(effectData + 0x88),
["casterlvl"] = casterlvl,
["source_id"] = summonerID
})

	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 6,
["duration"] = IEex_GetGameTick() + 1,
["resource"] = "MEERUPT3",
["source_x"] = IEex_ReadDword(effectData + 0x84),
["source_y"] = IEex_ReadDword(effectData + 0x88),
["target_x"] = IEex_ReadDword(effectData + 0x84),
["target_y"] = IEex_ReadDword(effectData + 0x88),
["source_id"] = targetID
})
--[[
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 6,
["duration"] = IEex_GetGameTick() + 2,
["resource"] = "MEERUPT3",
["source_x"] = IEex_ReadDword(effectData + 0x84),
["source_y"] = IEex_ReadDword(effectData + 0x88),
["target_x"] = IEex_ReadDword(effectData + 0x84),
["target_y"] = IEex_ReadDword(effectData + 0x88),
["source_id"] = targetID
})
--]]
end

function MEERUPT3(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local sourceData = IEex_GetActorShare(sourceID)
	if sourceData <= 0 then return end
	local summonerID = IEex_ReadDword(sourceData + 0x72C)
	local summonerData = IEex_GetActorShare(summonerID)
	if summonerData <= 0 then return end
	local summonerX, summonerY = IEex_GetActorLocation(summonerID)
	local found_it = false
	IEex_IterateIDs(IEex_ReadDword(summonerData + 0x12), 0, true, true, function(id)
		local projectileData = IEex_GetActorShare(id)
		if found_it == false and IEex_ReadWord(projectileData + 0x6E, 0x0) == 37 and IEex_ReadDword(projectileData + 0x72) == summonerID and IEex_ReadDword(projectileData + 0x76) == targetID then
			found_it = true
--			IEex_Search(IEex_ReadDword(projectileData + 0x6), IEex_ReadDword(projectileData + 0x192), 0x300, false)
--			IEex_Search(IEex_ReadDword(projectileData + 0xA), IEex_ReadDword(projectileData + 0x192), 0x300, false)
			IEex_WriteDword(projectileData + 0x6, IEex_ReadDword(creatureData + 0x6))
			IEex_WriteDword(projectileData + 0xA, IEex_ReadDword(creatureData + 0xA))
			IEex_WriteWord(projectileData + 0x70, 100)
		end
	end)
--	IEex_DS(found_it)
end

--[[
function MEERUPT3(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local sourceData = IEex_GetActorShare(sourceID)
	if sourceData <= 0 then return end
	local found_it = false
	IEex_IterateIDs(IEex_ReadDword(creatureData + 0x12), 0, true, true, function(id)
		local projectileData = IEex_GetActorShare(id)
		if found_it == false and IEex_ReadWord(projectileData + 0x6E, 0x0) == 37 and IEex_ReadDword(projectileData + 0x72) == sourceID then
			found_it = true
			local projectileTargetData = IEex_GetActorShare(IEex_ReadDword(projectileData + 0x76))
			IEex_DS(projectileTargetData)
			if projectileTargetData > 0 then
				IEex_WriteDword(projectileData + 0x6, IEex_ReadDword(projectileTargetData + 0x6))
				IEex_WriteDword(projectileData + 0xA, IEex_ReadDword(projectileTargetData + 0xA))
			end
		end
	end)
end
--]]
function MESUMCAS(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local spellRES = IEex_ReadLString(effectData + 0x18, 8)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local sourceData = IEex_GetActorShare(sourceID)
	if sourceData <= 0 then return end
	local summonerID = IEex_ReadDword(sourceData + 0x72C)
--	IEex_WriteWord(creatureData + 0x730, 0)
	local summonerData = IEex_GetActorShare(summonerID)
	if summonerData <= 0 then return end
	local summonerX, summonerY = IEex_GetActorLocation(summonerID)
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 0,
["resource"] = spellRES,
["parent_resource"] = spellRES,
["source_x"] = summonerX,
["source_y"] = summonerY,
["target_x"] = IEex_ReadDword(effectData + 0x84),
["target_y"] = IEex_ReadDword(effectData + 0x88),
["source_id"] = summonerID
})
end

me_past_seconds = {}
me_past_seconds_count = 18
me_past_effects = {}
function METIMELG(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 0x1)
	local targetID = IEex_GetActorIDShare(creatureData)
	local time_applied = IEex_ReadDword(effectData + 0x24)
	local me_current_effects = {}
	IEex_IterateActorEffects(targetID, function(eData)
		local the_opcode = IEex_ReadDword(eData + 0x10)
		local the_timing = IEex_ReadDword(eData + 0x24)
		local the_duration = IEex_ReadDword(eData + 0x28)
		local the_internal_flags = IEex_ReadDword(eData + 0xCC)
--[[
		if IEex_ReadLString(eData + 0x94, 8) == "SPPR406" then
			Infinity_DisplayString("the_duration: " .. the_duration .. ", time_applied: " .. time_applied)
		end
--]]
		if the_timing ~= 1 and the_timing ~= 2 and the_timing ~= 9 and the_opcode ~= 124 and the_opcode ~= 500 and ((the_duration - time_applied < 15 and bit.band(the_internal_flags, 0x8000000) == 0) or the_opcode == 119 or the_opcode == 218) then
			IEex_WriteDword(eData + 0xCC, bit.bor(the_internal_flags, 0x8000000))
			table.insert(me_current_effects, {
["opcode"] = IEex_ReadDword(eData + 0x10),
["target"] = IEex_ReadDword(eData + 0x14),
["power"] = IEex_ReadDword(eData + 0x18),
["parameter1"] = IEex_ReadDword(eData + 0x1C),
["parameter2"] = IEex_ReadDword(eData + 0x20),
["timing"] = IEex_ReadDword(eData + 0x24),
["duration"] = IEex_ReadDword(eData + 0x28),
["resource"] = IEex_ReadLString(eData + 0x30, 8),
["dicenumber"] = IEex_ReadDword(eData + 0x38),
["dicesize"] = IEex_ReadDword(eData + 0x3C),
["savingthrow"] = IEex_ReadDword(eData + 0x40),
["savebonus"] = IEex_ReadDword(eData + 0x44),
["special"] = IEex_ReadDword(eData + 0x48),
["school"] = IEex_ReadDword(eData + 0x4C),
["parameter3"] = IEex_ReadDword(eData + 0x60),
["parameter4"] = IEex_ReadDword(eData + 0x64),
["parameter5"] = IEex_ReadDword(eData + 0x68),
["time_applied"] = IEex_ReadDword(eData + 0x6C),
["vvcresource"] = IEex_ReadLString(eData + 0x70, 8),
["resource2"] = IEex_ReadLString(eData + 0x78, 8),
["source_x"] = IEex_ReadDword(eData + 0x80),
["source_y"] = IEex_ReadDword(eData + 0x84),
["target_x"] = IEex_ReadDword(eData + 0x88),
["target_y"] = IEex_ReadDword(eData + 0x8C),
["restype"] = IEex_ReadDword(eData + 0x90),
["parent_resource"] = IEex_ReadLString(eData + 0x94, 8),
["resource_flags"] = bit.band(IEex_ReadDword(eData + 0x9C), 0xFFFFF9FF),
["impact_projectile"] = IEex_ReadDword(eData + 0xA0),
["sourceslot"] = IEex_ReadDword(eData + 0xA4),
["effvar"] = IEex_ReadLString(eData + 0xA8, 32),
["casterlvl"] = IEex_ReadDword(eData + 0xC8),
["internal_flags"] = the_internal_flags,
["sectype"] = IEex_ReadDword(eData + 0xD0),
["source_id"] = IEex_ReadDword(eData + 0x110),
})
		end
	end)
	if me_past_seconds["" .. targetID] == nil or (me_past_seconds["" .. targetID][1][6] ~= nil and me_past_seconds["" .. targetID][1][6] > time_applied) then
--		me_past_seconds["" .. targetID] = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}
		me_past_seconds["" .. targetID] = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}	
	end
	for i = me_past_seconds_count, 2, -1 do
		me_past_seconds["" .. targetID][i] = me_past_seconds["" .. targetID][i - 1]
	end
--[[
	Infinity_DisplayString(#me_current_effects)
	if #me_current_effects > 0 then
		Infinity_DisplayString(me_current_effects[1]["parent_resource"])
	end
--]]
	local areaRES = ""
	if IEex_ReadDword(creatureData + 0x12) > 0 then
		areaRES = IEex_ReadLString(IEex_ReadDword(creatureData + 0x12), 8)
	end
	
	me_past_seconds["" .. targetID][1] = {IEex_ReadSignedWord(creatureData + 0x5C0, 0x0), IEex_ReadDword(creatureData + 0x6), IEex_ReadDword(creatureData + 0xA), areaRES, me_current_effects, time_applied}
end

function METIMETR(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 0x1)
	local targetID = IEex_GetActorIDShare(creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local time_applied = IEex_ReadDword(effectData + 0x24)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local previous_second = {}
	local game_tick = IEex_GetGameTick()
	if parameter1 <= 0 then return end
	if parameter1 > me_past_seconds_count then
		parameter1 = me_past_seconds_count
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 9,
["parameter1"] = 1,
["parameter2"] = 224,
["resource"] = "USTIMELG",
["parent_resource"] = "USTIMELS",
["internal_flags"] = 0x18000000,
["source_target"] = targetID,
["source_id"] = targetID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 9,
["parameter1"] = ex_tra_55701,
["parent_resource"] = "USTIMELS",
["internal_flags"] = 0x18000000,
["source_target"] = targetID,
["source_id"] = targetID
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 9,
["resource"] = "USTIMELS",
["parent_resource"] = "USTIMELS",
["internal_flags"] = 0x18000000,
["source_target"] = targetID,
["source_id"] = targetID
})
--	local current_past_seconds = me_past_seconds
	if me_past_seconds["" .. targetID] == nil then
--		me_past_seconds["" .. targetID] = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}
		me_past_seconds["" .. targetID] = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}
	end
--	me_past_effects["" .. targetID] = {}
	local areaRES = ""
	local areaType = 0x800
	if IEex_ReadDword(creatureData + 0x12) > 0 then
		areaRES = IEex_ReadLString(IEex_ReadDword(creatureData + 0x12), 8)
		areaType = IEex_ReadWord(IEex_ReadDword(creatureData + 0x12) + 0x40, 0x0)
	end
	local currentHP = IEex_ReadSignedWord(creatureData + 0x5C0, 0x0)
	local currentX = IEex_ReadDword(creatureData + 0x6)
	local currentY = IEex_ReadDword(creatureData + 0xA)
	local seconds_ago = 0
	local the_effect = {}
	local effect_opcode = 0
	local effect_duration = 0
	local effect_timing = 0
	for i = 1, parameter1, 1 do
		if #me_past_seconds["" .. targetID][i] > 0 then
			seconds_ago = seconds_ago + 1
		end
	end
	for i = 1, parameter1, 1 do
		previous_second = me_past_seconds["" .. targetID][1]
		for j = 1, me_past_seconds_count - 1, 1 do
			me_past_seconds["" .. targetID][j] = me_past_seconds["" .. targetID][j + 1]
		end
		me_past_seconds["" .. targetID][me_past_seconds_count] = {}
--		me_past_effects["" .. targetID]["" .. i] = previous_second[5]
		if #previous_second > 0 then
--			Infinity_DisplayString(i .. " second(s) before: " .. previous_second[1] .. " HP, [" .. previous_second[2] .. "." .. previous_second[3] .. "], " .. previous_second[4]) 
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 17,
["target"] = 2,
["timing"] = 6,
["duration"] = game_tick + i,
["parameter1"] = previous_second[1],
["parameter2"] = 1,
["parent_resource"] = parent_resource,
["internal_flags"] = 0x18000000,
["source_target"] = targetID,
["source_id"] = targetID
})
			currentHP = previous_second[1]
			if bit.band(areaType, 0x800) == 0 and areaRES ~= "" and areaRES == previous_second[4] then
--[[
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 124,
["target"] = 2,
["timing"] = 1,
["duration"] = game_tick + i,
["parent_resource"] = parent_resource,
["source_x"] = currentX,
["source_y"] = currentY,
["target_x"] = previous_second[2],
["target_y"] = previous_second[3],
["internal_flags"] = 0x18000000,
["source_target"] = targetID,
["source_id"] = targetID
})
--]]
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 6,
["duration"] = game_tick + i,
["resource"] = "USINTELE",
["parent_resource"] = parent_resource,
["source_x"] = currentX,
["source_y"] = currentY,
["target_x"] = previous_second[2],
["target_y"] = previous_second[3],
["internal_flags"] = 0x18000000,
["source_target"] = targetID,
["source_id"] = targetID
})
--				currentX = previous_second[2]
--				currentY = previous_second[3]
			end
			for j = 1, #previous_second[5], 1 do
				the_effect = previous_second[5][j]
				effect_opcode = the_effect["opcode"]
				effect_timing = the_effect["timing"]
				effect_duration = the_effect["duration"]
				if the_effect["time_applied"] + seconds_ago * 15 < time_applied and (effect_duration < time_applied or (effect_opcode == 218 and the_effect["parameter1"] > 0 and not IEex_GetActorSpellState(targetID, 18) and not IEex_GetActorSpellState(targetID, 19)) or (effect_opcode == 119 and the_effect["parameter1"] > 0 and not IEex_GetActorSpellState(targetID, 63) and not IEex_GetActorSpellState(targetID, 66))) then
					
					if effect_timing == 4096 then
						effect_timing = 10
						effect_duration = the_effect["duration"] - time_applied + (seconds_ago * 15)
					else
						effect_duration = game_tick + the_effect["duration"] - time_applied + (seconds_ago * 15)
					end		
					IEex_ApplyEffectToActor(targetID, {
["opcode"] = the_effect["opcode"],
["target"] = the_effect["target"],
["power"] = the_effect["power"],
["parameter1"] = the_effect["parameter1"],
["parameter2"] = the_effect["parameter2"],
["timing"] = effect_timing,
["duration"] = effect_duration,
["resource"] = the_effect["resource"],
["dicenumber"] = the_effect["dicenumber"],
["dicesize"] = the_effect["dicesize"],
["savingthrow"] = the_effect["savingthrow"],
["savebonus"] = the_effect["savebonus"],
["special"] = the_effect["special"],
["school"] = the_effect["school"],
["parameter3"] = the_effect["parameter3"],
["parameter4"] = the_effect["parameter4"],
["parameter5"] = the_effect["parameter5"],
["vvcresource"] = the_effect["vvcresource"],
["resource2"] = the_effect["resource2"],
["source_x"] = the_effect["source_x"],
["source_y"] = the_effect["source_y"],
["target_x"] = the_effect["target_x"],
["target_y"] = the_effect["target_y"],
["restype"] = the_effect["restype"],
["parent_resource"] = the_effect["parent_resource"],
["resource_flags"] = the_effect["resource_flags"],
["impact_projectile"] = the_effect["impact_projectile"],
["sourceslot"] = the_effect["sourceslot"],
["effvar"] = the_effect["effvar"],
["casterlvl"] = the_effect["casterlvl"],
["internal_flags"] = bit.bor(the_effect["internal_flags"], 0x18000000),
["sectype"] = the_effect["sectype"],
["source_id"] = the_effect["source_id"],
})
					if effect_opcode == 119 then
						IEex_IterateActorEffects(targetID, function(eData)
							local the_opcode = IEex_ReadDword(eData + 0x10)
							if the_opcode == effect_opcode then
								IEex_WriteDword(eData + 0x1C, the_effect["parameter1"])
							end
						end)
					end
				elseif effect_opcode == 119 and the_effect["parameter1"] > 0 then
					IEex_IterateActorEffects(targetID, function(eData)
						local the_opcode = IEex_ReadDword(eData + 0x10)
						if the_opcode == effect_opcode then
							IEex_WriteDword(eData + 0x1C, the_effect["parameter1"])
						end
					end)
				elseif effect_opcode == 218 then
					if the_effect["parameter2"] == 0 and the_effect["parameter3"] > 0 then
						IEex_IterateActorEffects(targetID, function(eData)
							local the_opcode = IEex_ReadDword(eData + 0x10)
							local the_parameter2 = IEex_ReadDword(eData + 0x20)
							if the_opcode == effect_opcode and the_parameter2 == 0 then
								IEex_WriteDword(eData + 0x1C, the_effect["parameter1"])
								IEex_WriteDword(eData + 0x60, the_effect["parameter3"])
							end
						end)
					elseif the_effect["parameter2"] == 1 and the_effect["parameter1"] > 0 then
						IEex_IterateActorEffects(targetID, function(eData)
							local the_opcode = IEex_ReadDword(eData + 0x10)
							local the_parameter2 = IEex_ReadDword(eData + 0x20)
							if the_opcode == effect_opcode and the_parameter2 == 1 then
								IEex_WriteDword(eData + 0x1C, the_effect["parameter1"])
							end
						end)
					end
				end
			end
--[[
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 6,
["duration"] = game_tick + i,
["parameter1"] = i,
["parameter2"] = time_applied,
["special"] = game_tick,
["resource"] = "METIMEEF",
["parent_resource"] = parent_resource,
["source_target"] = targetID,
["source_id"] = targetID
})
--]]
		end
	end

	if seconds_ago > 0 then

		IEex_IterateActorEffects(targetID, function(eData)
			local the_opcode = IEex_ReadDword(eData + 0x10)
			local the_timing = IEex_ReadDword(eData + 0x24)
			local the_parent_resource = IEex_ReadLString(eData + 0x94, 8)
			local the_internal_flags = IEex_ReadDword(eData + 0xCC)
			local the_time_applied = IEex_ReadDword(eData + 0x6C)
			if the_time_applied < time_applied and the_timing ~= 1 and the_timing ~= 2 and the_timing ~= 9 and the_parent_resource ~= parent_resource and the_opcode ~= 500 and bit.band(the_internal_flags, 0x10000000) == 0 then
				local the_duration = IEex_ReadDword(eData + 0x28)
				the_duration = the_duration + (seconds_ago * 15)
				the_time_applied = the_time_applied + (seconds_ago * 15)
				IEex_WriteDword(eData + 0x28, the_duration)
				IEex_WriteDword(eData + 0x6C, the_time_applied)
				if the_time_applied >= time_applied then
					IEex_WriteDword(eData + 0x28, 0)
					IEex_WriteDword(eData + 0x114, 1)
				end
			end
		end)

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
	local getHighestLevel = (bit.band(savingthrow, 0x100000) > 0)
	local ignoreHigherLevel = (bit.band(savingthrow, 0x200000) > 0)
	local includeNonliving = (bit.band(savingthrow, 0x800000) > 0)
	local recruitTarget = (bit.band(savingthrow, 0x1000000) > 0)
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
			if bit.band(currentStates, 0xE00) > 0 and bit.band(currentStates, 0xC0) == 0 and (IEex_ReadDword(currentShare + 0x5C4) > 1000) and (includeNonliving or (IEex_ReadByte(currentShare + 0x25, 0x0) ~= 4 and nonliving_race["" .. IEex_ReadByte(currentShare + 0x26, 0x0)] == nil)) then
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
--		IEex_WriteDword(currentShare + 0x5BC, bit.band(currentStates, 0xFFFFFAFF)) 
--		IEex_WriteDword(currentShare + 0x920, bit.band(IEex_ReadDword(currentShare + 0x920), 0xFFFFFAFF)) 
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
							if (slot == 43 or slot == 45 or slot == 47 or slot == 49) and chosenItemSlot == -1 and inventoryItems[slot + 1] ~= "" and inventoryItems[slot + 2] == "" and (IEex_ReadByte(currentShare + 0x62E, 0x0) > 0 or bit.band(IEex_ReadDword(currentShare + 0x75C), 0x2) > 0) and IEex_ReadByte(itemData + 0x82, 0x0) == 1 and bit.band(IEex_ReadDword(itemData + 0x18), 0x2) == 0 then
								local rightItemWrapper = resWrapper
								if itemRES ~= inventoryItems[slot + 1] then
									rightItemWrapper = IEex_DemandRes(inventoryItems[slot + 1], "ITM")
									local rightItemData = rightItemWrapper:getData()
									if rightItemWrapper:isValid() and IEex_ReadByte(rightItemData + 0x72, 0x0) == 1 and bit.band(IEex_ReadDword(rightItemData + 0x18), 0x2) == 0 then
										chosenItemSlot = slot + 1
										inventoryItems[slot + 2] = itemRES
									end
									rightItemWrapper:free()
								else
									local rightItemData = itemData
									if IEex_ReadByte(rightItemData + 0x72, 0x0) == 1 and bit.band(IEex_ReadDword(rightItemData + 0x18), 0x2) == 0 then
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
			resWrapper:free()
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
	local doNotModifyQuantity = (bit.band(savingthrow, 0x10000) > 0)
	local doNotModifyCharges = (bit.band(savingthrow, 0x20000) > 0)
	local goOverMaximum = (bit.band(savingthrow, 0x40000) > 0)
	if bit.band(savingthrow, 0x80000) == 0 then
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
				if maxCharges1 > 0 and bit.band(IEex_ReadDword(itemData + 0xA8), 0x100000) == 0 and ((maxQuantity > 1 and doNotModifyQuantity == false) or (maxQuantity <= 1 and doNotModifyCharges == false)) then
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
				if maxCharges2 > 0 and bit.band(IEex_ReadDword(itemData + 0xE0), 0x100000) == 0 and ((maxQuantity > 1 and doNotModifyQuantity == false) or (maxQuantity <= 1 and doNotModifyCharges == false)) then
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
				if maxCharges3 > 0 and bit.band(IEex_ReadDword(itemData + 0x118), 0x100000) == 0 and ((maxQuantity > 1 and doNotModifyQuantity == false) or (maxQuantity <= 1 and doNotModifyCharges == false)) then
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
		resWrapper:free()
	end
end

function MEHOFSUM(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 44,
["target"] = 2,
["parameter1"] = -10,
["timing"] = 1,
["parent_resource"] = "USHOFSUM",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 15,
["target"] = 2,
["parameter1"] = -10,
["timing"] = 1,
["parent_resource"] = "USHOFSUM",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 10,
["target"] = 2,
["parameter1"] = -10,
["timing"] = 1,
["parent_resource"] = "USHOFSUM",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 19,
["target"] = 2,
["parameter1"] = -10,
["timing"] = 1,
["parent_resource"] = "USHOFSUM",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 49,
["target"] = 2,
["parameter1"] = -10,
["timing"] = 1,
["parent_resource"] = "USHOFSUM",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 6,
["target"] = 2,
["parameter1"] = -10,
["timing"] = 1,
["parent_resource"] = "USHOFSUM",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 17,
["target"] = 2,
["parameter1"] = 100,
["parameter2"] = 2,
["timing"] = 1,
["parent_resource"] = "USHOFSUM",
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 1,
["resource"] = "USHOFSUM",
["parent_resource"] = "USHOFSUM",
["source_id"] = targetID
})
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
	if bit.band(IEex_ReadByte(creatureData + 0x89F, 0), 0x2) ~= 0 then
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
--[[
I'm not sure how closely these correspond to the actual projectile types in IWD2; 
 these are just my guesses of the different types. 
0: No Projectile
1: Single Target
2: Pillar
3: Magic Missile
4: Passes Through Target
5: Passes Through Target, Bounces Off Walls
6: Area of Effect
7: Cone
8: Skull Trap
9: Agannazar's Scorcher
10: Call Lightning Chain
11: Wall
12: Spiritual Wrath
13: Travel Door
14: Cow
15: Chain Lightning
16: Whirlwind
--]]
ex_projectile_type = {
[0] = 0, [1] = 0, [2] = 1, [3] = 6, [4] = 1, [5] = 1, [6] = 1, [7] = 1, [8] = 6, [9] = 1, [10] = 1, [11] = 1, [12] = 1, [13] = 6, [14] = 1, [15] = 1, [16] = 1, [17] = 1, [18] = 6, [19] = 1,
[20] = 1, [21] = 1, [22] = 7, [23] = 2, [24] = 1, [25] = 7, [26] = 7, [27] = 1, [28] = 6, [29] = 1, [30] = 1, [31] = 1, [32] = 1, [33] = 6, [34] = 1, [35] = 1, [36] = 1, [37] = 1, [38] = 6, [39] = 1, 
[40] = 5, [41] = 1, [42] = 6, [43] = 1, [44] = 1, [45] = 1, [46] = 1, [47] = 1, [48] = 1, [49] = 1, [50] = 1, [51] = 1, [52] = 1, [53] = 1, [54] = 1, [55] = 1, [56] = 1, [57] = 6, [58] = 1, [59] = 1, 
[60] = 1, [61] = 1, [62] = 1, [63] = 6, [64] = 1, [65] = 1, [66] = 2, [67] = 6, [68] = 1, [69] = 3, [70] = 3, [71] = 3, [72] = 3, [73] = 3, [74] = 3, [75] = 3, [76] = 3, [77] = 3, [78] = 3, [79] = 1, 
[80] = 6, [81] = 10, [82] = 10, [83] = 10, [84] = 10, [85] = 10, [86] = 10, [87] = 10, [88] = 10, [89] = 10, [90] = 10, [91] = 10, [92] = 6, [93] = 6, [94] = 6, [95] = 6, [96] = 8, [97] = 7, [98] = 6, [99] = 11, 
[100] = 8, [101] = 6, [102] = 1, [103] = 1, [104] = 1, [105] = 1, [106] = 1, [107] = 6, [108] = 1, [109] = 9, 
[110] = 13, [111] = 1, [112] = 1, [113] = 1, [114] = 1, [115] = 1, [116] = 1, [117] = 1, [118] = 1, [119] = 1, 
[120] = 1, [121] = 1, [122] = 1, [123] = 1, [124] = 1, [125] = 1, [126] = 1, [127] = 1, [128] = 1, [129] = 1, 
[130] = 1, [131] = 1, [132] = 1, [133] = 1, [134] = 1, [135] = 1, [136] = 1, [137] = 1, [138] = 1, [139] = 1, 
[140] = 1, [141] = 1, [142] = 1, [143] = 1, [144] = 1, [145] = 1, [146] = 1, [147] = 1, [148] = 1, [149] = 6, 
[150] = 6, [151] = 6, [152] = 6, [153] = 6, [154] = 6, [155] = 6, [156] = 6, [157] = 6, [158] = 6, [159] = 6, 
[160] = 6, [161] = 6, [162] = 6, [163] = 6, [164] = 6, [165] = 6, [166] = 6, [167] = 6, [168] = 6, [169] = 6, 
[170] = 6, [171] = 6, [172] = 6, [173] = 6, [174] = 6, [175] = 6, [176] = 6, [177] = 6, [178] = 6, [179] = 6, 
[180] = 6, [181] = 6, [182] = 6, [183] = 6, [184] = 1, [185] = 1, [186] = 6, [187] = 6, [188] = 1, [189] = 14, 
[190] = 6, [191] = 1, [192] = 1, [193] = 1, [194] = 1, [195] = 2, [196] = 6, [197] = 6, [198] = 6, [199] = 6, 
[200] = 6, [201] = 6, [202] = 6, [203] = 6, [204] = 6, [205] = 6, [206] = 5, [207] = 4, [208] = 1, [209] = 6,
[210] = 15, [211] = 6, [212] = 6, [213] = 6, [214] = 6, [215] = 6, [216] = 6, [217] = 6, [218] = 1, [219] = 1,
[220] = 1, [221] = 1, [222] = 1, [223] = 1, [224] = 1, [225] = 1, [226] = 1, [227] = 1, [228] = 1, [229] = 1,
[230] = 1, [231] = 1, [232] = 1, [233] = 1, [234] = 1, [235] = 6, [236] = 6, [237] = 6, [238] = 6, [239] = 6,
[240] = 6, [241] = 6, [242] = 6, [243] = 6, [244] = 6, [245] = 6, [246] = 6, [247] = 1, [248] = 6, [249] = 6,
[250] = 6, [251] = 1, [252] = 6, [253] = 6, [254] = 6, [255] = 6, [256] = 6, [257] = 6, [258] = 6, [259] = 6,
[260] = 1, [261] = 1, [262] = 1, [263] = 6, [264] = 6, [265] = 1, [266] = 6, [267] = 6, [268] = 1, [269] = 1,
[270] = 6, [271] = 1, [272] = 7, [273] = 6, [274] = 6, [275] = 6, [276] = 6, [277] = 6, [278] = 6, [279] = 6,
[280] = 6, [281] = 6, [282] = 6, [283] = 6, [284] = 6, [285] = 1, [286] = 6, [287] = 6, [288] = 6, [289] = 1,
[290] = 1, [291] = 1, [292] = 1, [293] = 1, [294] = 1, [295] = 6, [296] = 7, [297] = 1, [298] = 1, [299] = 6,
[300] = 6, [301] = 6, [302] = 4, [303] = 1, [304] = 1, [305] = 16, [306] = 6, [307] = 6, [308] = 6, [309] = 6,
[310] = 6, [311] = 6, [312] = 12, [313] = 4, [314] = 1, [315] = 7, [316] = 1, [317] = 6, [318] = 6, [319] = 7,
[320] = 6, [321] = 6, [322] = 6, [323] = 6, [324] = 1, [325] = 3, [326] = 3, [327] = 3, [328] = 3, [329] = 3,
[330] = 3, [331] = 3, [332] = 3, [333] = 3, [334] = 3, [335] = 6, [336] = 6, [337] = 6, [338] = 6, [339] = 6,
[340] = 6, [341] = 6, [342] = 6, [343] = 7, [344] = 1, [345] = 3, [346] = 1, [347] = 1, [348] = 1, [349] = 6,
[350] = 1, [351] = 6, [352] = 1, [353] = 1, [354] = 1, [355] = 1, [356] = 1, [357] = 6, [358] = 6, [359] = 6,
[360] = 8, [361] = 1, [362] = 6, [363] = 6, [364] = 6, [365] = 6, [366] = 6, [367] = 6, [368] = 7, [369] = 6,
[370] = 11, [371] = 6, [372] = 6, [373] = 6, [374] = 7, [375] = 1, [376] = 6, [377] = 6, [378] = 1, [379] = 7,
[380] = 5, [381] = 6, [382] = 7, [383] = 4, [384] = 6, [385] = 6, [386] = 7,
}

--[[
To use the EXSPLDEF function, create an opcode 502 effect in a spell, set the resource to EXSPLDEF (all capitals), and choose parameters.

The EXSPLDEF function works like Spell Deflection, Spell Turning or Spell Trap from the other EE games, except it works against area of effect spells.

parameter1 - Determines the lowest spell level that can be deflected (0 - 9).

parameter2 - Determines the highest spell level that can be deflected (0 - 9).

special - Determines the number of spell levels that can be deflected. If set to -1, there is no limit.

savingthrow - This function uses several extra bits on this parameter:
Bit 17: If set, once the last spell level is deflected, another spell is cast on the creature whose spell
 was deflected. The spell resref is specified by resource2 (in an EFF file). If you aren't using this from an
 EFF file, then the spell resref is set to the resref of the source spell, with an E added at the end.
Bit 18: If set, whenever a spell is deflected, another spell is cast on the creature whose spell
 was deflected. The spell resref is specified by resource3 (in an EFF file). If you aren't using this from an
 EFF file, then the spell resref is set to the resref of the source spell, with an F added at the end.
Bit 19: If set, up to special spells (rather than spell levels) are deflected.
Bit 20: If NOT set, the function will remove all effects of the spell that called EXSPLDEF once the last spell level is deflected.
Bit 21: If set, only spells with the hostile flag, or that deal damage, will be deflected.
Bit 22: If set, the function will reflect rather than deflect the spell.
Bit 23: If set, the function will absorb the spell as with Spell Trap, restoring one of the character's previously-used spells.
Bit 24: If set, spells from allies will not be deflected.
Bit 25: If set, area of effect spells will not be deflected.

--]]
previous_spells_turned = {}
function EXSPLDEF(originatingEffectData, effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local o_parent_resource = IEex_ReadLString(originatingEffectData + 0x90, 8)
	local internal_flags = IEex_ReadDword(effectData + 0xC8)
	if bit.band(internal_flags, 0x4000000) > 0 or targetID <= 0 or sourceID <= 0 or targetID == sourceID then return false end
	local o_savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
	local o_parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
	local o_parameter2 = IEex_ReadDword(originatingEffectData + 0x1C)
	local match_spellRES = IEex_ReadLString(originatingEffectData + 0x18, 8)
	local spellRES = IEex_ReadLString(effectData + 0x90, 8)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local resource = IEex_ReadLString(effectData + 0x2C, 8)
	local spellLevel = IEex_ReadDword(effectData + 0x14)
	local endSpellRES = IEex_ReadLString(originatingEffectData + 0x6C, 8)
	local repeatSpellRES = IEex_ReadLString(originatingEffectData + 0x74, 8)
	if endSpellRES == "" then
		endSpellRES = o_parent_resource .. "E"
	end
	if repeatSpellRES == "" then
		repeatSpellRES = o_parent_resource .. "F"
	end
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local casterClass = IEex_ReadByte(effectData + 0xC5, 0x0)
	local sourceSpell = ex_damage_source_spell[spellRES]
	if sourceSpell == nil then
		sourceSpell = spellRES
	end
	local classSpellLevel = 0
	if IEex_IsSprite(sourceID, true) then
		classSpellLevel = IEex_GetClassSpellLevel(sourceID, casterClass, sourceSpell)
		if classSpellLevel == 0 and IEex_GetActorStat(sourceID, 105) > 0 then
			classSpellLevel = IEex_GetClassSpellLevel(sourceID, 10, sourceSpell)
		end
	end
	if ex_bypass_spell_deflection[sourceSpell] ~= nil then return false end
--	if spellLevel <= 0 and bit.band(o_savingthrow, 0x10000) == 0 and (classSpellLevel == 0 or resource ~= "MESPLSAV") then return false end
	if bit.band(o_savingthrow, 0x1000000) > 0 and IEex_CompareActorAllegiances(sourceID, targetID) == 1 then return false end
	local o_special = IEex_ReadDword(originatingEffectData + 0x44)
	local time_applied = IEex_ReadDword(effectData + 0x68)
	local projectile = 1
	local isHostile = false
	local resWrapper = IEex_DemandRes(sourceSpell, "SPL")
	local spellData = 0
	if resWrapper:isValid() then
		spellData = resWrapper:getData()
		isHostile = (bit.band(IEex_ReadDword(spellData + 0x18), 0x400) > 0)
		local spellType = IEex_ReadWord(spellData + 0x1C, 0x0)
		if classSpellLevel == 0 and (spellType == 1 or spellType == 2) then
			classSpellLevel = IEex_ReadDword(spellData + 0x34)
		end
		local realCasterLevel = IEex_ReadByte(effectData + 0xC4, 0x0)
		local numHeaders = IEex_ReadWord(spellData + 0x68, 0x0)
		
		for i = 1, numHeaders, 1 do
			if realCasterLevel >= IEex_ReadWord(spellData + 0x5A + 0x28 * i + 0x10, 0x0) then
				projectile = IEex_ReadWord(spellData + 0x5A + 0x28 * i + 0x26, 0x0)
			end
		end
	end
	resWrapper:free()
	if classSpellLevel < o_parameter1 or classSpellLevel > o_parameter2 then return false end
	if bit.band(o_savingthrow, 0x200000) > 0 and opcode ~= 12 and opcode ~= 25 and opcode ~= 78 and not isHostile then return false end
	local separateDelay = 1
	if ex_projectile_type[projectile] == 3 then
		separateDelay = 15
	end

	if previous_spells_turned["" .. targetID] == nil then
		previous_spells_turned["" .. targetID] = {}
	end
	if previous_spells_turned["" .. targetID]["" .. sourceID] == nil then
		previous_spells_turned["" .. targetID]["" .. sourceID] = {}
	end
	if previous_spells_turned["" .. targetID]["" .. sourceID][sourceSpell] == nil or math.abs(previous_spells_turned["" .. targetID]["" .. sourceID][sourceSpell] - time_applied) > separateDelay then

		if bit.band(o_savingthrow, 0x2000000) > 0 and ex_projectile_type[projectile] >= 4 and ex_projectile_type[projectile] ~= 9 and ex_projectile_type[projectile] ~= 14 and ex_projectile_type[projectile] ~= 15 then return false end
		if o_special == 0 then
			return false
		elseif o_special ~= -1 then
			if bit.band(o_savingthrow, 0x80000) == 0 and classSpellLevel > 0 then
				o_special = o_special - classSpellLevel
				if o_special < 0 then
					o_special = 0
				end
			else
				o_special = o_special - 1
			end
			IEex_WriteDword(originatingEffectData + 0x44, o_special)
		end
--[[
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 0,
["resource"] = spellRES,
["internal_flags"] = 0x4000000,
["source_target"] = targetID,
["source_id"] = targetID
})
--]]
		if bit.band(o_savingthrow, 0x400000) > 0 then
			if ex_projectile_type[projectile] ~= 6 and ex_projectile_type[projectile] ~= 8 and ex_projectile_type[projectile] ~= 11 and ex_projectile_type[projectile] ~= 16 then
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 430,
["target"] = 2,
["parameter2"] = projectile - 1,
["timing"] = 1,
["resource"] = sourceSpell,
["savingthrow"] = IEex_ReadDword(effectData + 0x3C),
["savebonus"] = IEex_ReadDword(effectData + 0x40),
["source_x"] = IEex_ReadDword(creatureData + 0x8),
["source_y"] = IEex_ReadDword(creatureData + 0xC),
["target_x"] = IEex_ReadDword(IEex_GetActorShare(sourceID) + 0x8),
["target_y"] = IEex_ReadDword(IEex_GetActorShare(sourceID) + 0xC),
["restype"] = IEex_ReadDword(effectData + 0x8C),
["parent_resource"] = sourceSpell,
["resource_flags"] = IEex_ReadDword(effectData + 0x98),
["casterlvl"] = casterlvl,
["internal_flags"] = bit.bor(internal_flags, 0x4000000),
["source_target"] = sourceID,
["source_id"] = targetID
})
			else
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = sourceSpell,
["savingthrow"] = IEex_ReadDword(effectData + 0x3C),
["savebonus"] = IEex_ReadDword(effectData + 0x40),
["source_x"] = IEex_ReadDword(creatureData + 0x8),
["source_y"] = IEex_ReadDword(creatureData + 0xC),
["target_x"] = IEex_ReadDword(IEex_GetActorShare(sourceID) + 0x8),
["target_y"] = IEex_ReadDword(IEex_GetActorShare(sourceID) + 0xC),
["restype"] = IEex_ReadDword(effectData + 0x8C),
["parent_resource"] = sourceSpell,
["resource_flags"] = IEex_ReadDword(effectData + 0x98),
["casterlvl"] = casterlvl,
["internal_flags"] = bit.bor(internal_flags, 0x4000000),
["source_target"] = sourceID,
["source_id"] = targetID
})
			end
		end
		if bit.band(o_savingthrow, 0x800000) > 0 then
			local o_casterClass = IEex_ReadByte(originatingEffectData + 0xC5, 0x0)
			local modmemflags = 0x8000000
			if o_casterClass == 0 then
				modmemflags = bit.bor(modmemflags, 0xFF0000)
			elseif o_casterClass == 2 then
				modmemflags = bit.bor(modmemflags, 0x10000)
			elseif o_casterClass == 3 then
				modmemflags = bit.bor(modmemflags, 0x820000)
			elseif o_casterClass == 4 then
				modmemflags = bit.bor(modmemflags, 0x40000)
			elseif o_casterClass == 7 then
				modmemflags = bit.bor(modmemflags, 0x80000)
			elseif o_casterClass == 8 then
				modmemflags = bit.bor(modmemflags, 0x100000)
			elseif o_casterClass == 10 then
				modmemflags = bit.bor(modmemflags, 0x200000)
			elseif o_casterClass == 11 then
				modmemflags = bit.bor(modmemflags, 0x400000)
			end
			local restoreSpellLevel = IEex_GetClassSpellLevel(targetID, o_casterClass, o_parent_resource) - 1
			if restoreSpellLevel == -1 then
				restoreSpellLevel = 9
			end
			if restoreSpellLevel > classSpellLevel then
				restoreSpellLevel = classSpellLevel
			end
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = 1,
["parameter2"] = restoreSpellLevel,
["special"] = 1,
["resource"] = "EXMODMEM",
["savingthrow"] = modmemflags,
["internal_flags"] = 0x4000000,
["source_target"] = targetID,
["source_id"] = targetID
})		
		end
		if bit.band(o_savingthrow, 0x40000) > 0 then
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = repeatSpellRES,
["parent_resource"] = repeatSpellRES,
["internal_flags"] = 0x4000000,
["casterlvl"] = IEex_ReadDword(originatingEffectData + 0xC4),
["source_target"] = sourceID,
["source_id"] = targetID
})
		end
		if o_special == 0 then
			if bit.band(o_savingthrow, 0x20000) > 0 then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = endSpellRES,
["parent_resource"] = endSpellRES,
["internal_flags"] = 0x4000000,
["casterlvl"] = IEex_ReadDword(originatingEffectData + 0xC4),
["source_target"] = targetID,
["source_id"] = targetID
})
			end
			if bit.band(o_savingthrow, 0x100000) == 0 then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["duration"] = IEex_GetGameTick() + 1,
["resource"] = o_parent_resource,
["internal_flags"] = 0x4000000,
["source_target"] = targetID,
["source_id"] = targetID
})
--[[
				IEex_RemoveEffectsByResource(targetID, parent_resource)
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 6,
["duration"] = IEex_GetGameTick() + 2,
["resource"] = "USBASEEF",
["internal_flags"] = 0x4000000,
["casterlvl"] = IEex_ReadDword(originatingEffectData + 0xC4),
["source_target"] = targetID,
["source_id"] = targetID
})
--]]
			end
		end
	end
	previous_spells_turned["" .. targetID]["" .. sourceID][sourceSpell] = time_applied
	return true
end

function MEPOLYBL(originatingEffectData, effectData, creatureData)

	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	if opcode == 111 and bit.band(savingthrow, 0x10000) == 0 then
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

function METELEBL(originatingEffectData, effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	if opcode == 124 and bit.band(savingthrow, 0x10000) == 0 then
		return true
	end
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
	if bit.band(internal_flags, 0x4000000) == 0 then
		local targetID = IEex_GetActorIDShare(creatureData)
		if targetID ~= sourceID or not IEex_IsSprite(targetID) or not IEex_IsSprite(sourceID) then return false end
		local o_spellRES = IEex_ReadLString(originatingEffectData + 0x18, 8)
		local o_spellRES2 = IEex_ReadLString(originatingEffectData + 0x6C, 8)
		local o_spellRES3 = IEex_ReadLString(originatingEffectData + 0x74, 8)
		local o_savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
		if bit.band(o_savingthrow, 0x100000) > 0 and parent_resource ~= o_spellRES and parent_resource ~= o_spellRES2 and parent_resource ~= o_spellRES3 then return false end
		if bit.band(o_savingthrow, 0x200000) > 0 and classSpellLevel > IEex_ReadDword(originatingEffectData + 0x18) then return false end
		if bit.band(o_savingthrow, 0x400000) > 0 and school ~= IEex_ReadDword(originatingEffectData + 0x1C) then return false end
		local o_special = IEex_ReadDword(originatingEffectData + 0x44)
		if bit.band(o_savingthrow, 0x10000) > 0 then
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
	local damage = IEex_ReadDword(effectData + 0x18)
	local damage_type = IEex_ReadWord(effectData + 0x1E, 0x0)
	local flags = IEex_ReadDword(effectData + 0x44)
	local restype = IEex_ReadDword(effectData + 0x8C)
	local internal_flags = IEex_ReadDword(effectData + 0xC8)
	if bit.band(internal_flags, 0x4000000) > 0 then return false end
	local opcode = IEex_ReadDword(effectData + 0xC)
	local effectRES = IEex_ReadLString(effectData + 0x90, 8)
	local isOnHitEffect = false
	local doDeflect = true
	if bit.band(savingthrow, 0x10000) == 0 and delay > 0 then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local thesavingthrow = IEex_ReadDword(eData + 0x48)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local thevvcresource = IEex_ReadLString(eData + 0x70, 8)
			if theopcode == 0 and bit.band(thesavingthrow, 0x100000) > 0 and theresource == parent_resource and thevvcresource == "MEDEFLEC" then
				doDeflect = false
			end
		end)
	end
	if previous_attacks_deflected["" .. targetID] == nil then
		previous_attacks_deflected["" .. targetID] = {}
	end
	if opcode == 12 and effectRES == "IEEX_DAM" and (damage_type == 0 and bit.band(types_blocked, 0x2000) > 0) or (damage_type ~= 0 and bit.band(types_blocked, damage_type) > 0) and ((bit.band(savingthrow, 0x10000) > 0 and delay ~= 0) or (bit.band(savingthrow, 0x10000) == 0 and doDeflect)) then
--		effectRES = IEex_ReadLString(effectData + 0x6C, 8)
		effectRES = "IEEX_DAM"
		previous_attacks_deflected["" .. targetID][effectRES] = IEex_GetGameTick()
	elseif bit.band(savingthrow, 0x80000) > 0 and previous_attacks_deflected["" .. targetID]["IEEX_DAM"] == IEex_GetGameTick() and restype == 2 then
		isOnHitEffect = true
	end
	if opcode ~= 12 and isOnHitEffect == false then return false end
	
	if bit.band(savingthrow, 0x200000) > 0 then
		if IEex_GetActorStat(targetID, 101) == 0 and IEex_GetActorStat(targetID, 40) < 19 then return false end
		local hasArmor = false
		local handsUsed = 0
		local spriteHands = 2
		local animation = IEex_ReadDword(creatureData + 0x5C4)
		if extra_hands[animation] ~= nil then
			spriteHands = extra_hands[animation]
		end
--		if IEex_GetActorSpellState(targetID, 241) then
			IEex_IterateActorEffects(targetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 241 then
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thespecial = IEex_ReadByte(eData + 0x48, 0x0)
					if (thespecial >= 3 and thespecial <= 5 and theparameter1 ~= 41) then
						if bit.band(thesavingthrow, 0x20000) == 0 then
							handsUsed = handsUsed + 1
						else
							handsUsed = handsUsed + 2
						end
					elseif thespecial == 1 or thespecial == 3 then
						hasArmor = true
					end
				end
			end)
--		end
--		if hasArmor or ((spriteHands - handsUsed) < 2) then return false end
		if ((spriteHands - handsUsed) < 1) then return false end
	end
	if bit.band(savingthrow, 0x400000) > 0 and damage < IEex_ReadSignedWord(creatureData + 0x5C0, 0x0) then return false end
	
	if bit.band(savingthrow, 0x800000) > 0 then
		local stateValue = bit.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
		if bit.band(stateValue, 0xFE9) ~= 0 then return false end
	end

	if isOnHitEffect or (damage_type == 0 and bit.band(types_blocked, 0x2000) > 0) or (damage_type ~= 0 and bit.band(types_blocked, damage_type) > 0) then
		if doDeflect or isOnHitEffect then
			if bit.band(savingthrow, 0x10000) > 0 and delay ~= -1 and isOnHitEffect == false then
				if delay > 0 then
					delay = delay - 1
					IEex_WriteDword(originatingEffectData + 0x44, delay)
				else
					return false
				end
			end
			if bit.band(savingthrow, 0x10000) == 0 and delay > 0 and isOnHitEffect == false then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 0,
["duration"] = delay,
["resource"] = parent_resource,
["vvcresource"] = "MEDEFLEC",
["parent_resource"] = "MEDEFDEL",
["savingthrow"] = 0x100000,
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
			if bit.band(savingthrow, 0x100000) > 0 and IEex_IsSprite(sourceID, false) and targetID ~= sourceID then
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
["internal_flags"] = bit.bor(internal_flags, 0x4000000),
["sectype"] = IEex_ReadDword(effectData + 0xCC),
["source_target"] = sourceID,
["source_id"] = targetID
})
			end
			if bit.band(savingthrow, 0x10000) > 0 and bit.band(savingthrow, 0x20000) > 0 and delay == 0 and isOnHitEffect == false then
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

function MEDAMPRC(originatingEffectData, effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local percentageModifier = IEex_ReadDword(originatingEffectData + 0x18)
	local types_blocked = IEex_ReadDword(originatingEffectData + 0x1C)
	local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
	local delay = IEex_ReadDword(originatingEffectData + 0x44)
	local parent_resource = IEex_ReadLString(originatingEffectData + 0x90, 8)
	local damage = IEex_ReadDword(effectData + 0x18)
	local damage_type = IEex_ReadWord(effectData + 0x1E, 0x0)
	local dicenumber = IEex_ReadDword(effectData + 0x34)
	local flags = IEex_ReadDword(effectData + 0x44)
	local restype = IEex_ReadDword(effectData + 0x8C)
	local internal_flags = IEex_ReadDword(effectData + 0xC8)
	if bit.band(internal_flags, 0x4000000) > 0 then return false end
	local opcode = IEex_ReadDword(effectData + 0xC)
	local effectRES = IEex_ReadLString(effectData + 0x90, 8)
	local doDeflect = true
	if opcode ~= 12 then return false end
	if (damage_type == 0 and bit.band(types_blocked, 0x2000) > 0) or (damage_type ~= 0 and bit.band(types_blocked, damage_type) > 0) then
		if bit.band(savingthrow, 0x10000) == 0 and delay > 0 then
			IEex_IterateActorEffects(targetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local thesavingthrow = IEex_ReadDword(eData + 0x48)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				local thevvcresource = IEex_ReadLString(eData + 0x70, 8)
				if theopcode == 0 and bit.band(thesavingthrow, 0x100000) > 0 and theresource == parent_resource and thevvcresource == "MEDAMPRC" then
					doDeflect = false
				end
			end)
		end
		if doDeflect then
			if bit.band(savingthrow, 0x10000) > 0 and delay ~= -1 then
				if delay > 0 then
					delay = delay - 1
					IEex_WriteDword(originatingEffectData + 0x44, delay)
				else
					return false
				end
			end
			
			if bit.band(savingthrow, 0x10000) == 0 and delay > 0 then
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 0,
["duration"] = delay,
["resource"] = parent_resource,
["vvcresource"] = "MEDAMPRC",
["parent_resource"] = "MEDEFDEL",
["savingthrow"] = 0x100000,
["internal_flags"] = 0x4000000,
["source_target"] = targetID,
["source_id"] = targetID,
})
			end
			IEex_WriteDword(effectData + 0x18, math.floor(damage - damage * percentageModifier / 100))
			IEex_WriteDword(effectData + 0x34, math.floor(dicenumber - dicenumber * percentageModifier / 100))
			if bit.band(savingthrow, 0x10000) > 0 and bit.band(savingthrow, 0x20000) > 0 and delay == 0 then
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
			if percentageModifier >= 100 then return true end
		end
	end
	return false
end

function MEDAMSLV(originatingEffectData, effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local modifier = IEex_ReadDword(originatingEffectData + 0x18)
	local reductionType = IEex_ReadWord(originatingEffectData + 0x1C, 0x0)
	local maxEnchantment = IEex_ReadWord(originatingEffectData + 0x1E, 0x0)
	local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
	local string = IEex_ReadDword(originatingEffectData + 0x44)
	local parent_resource = IEex_ReadLString(originatingEffectData + 0x90, 8)
	local damage = IEex_ReadDword(effectData + 0x18)
	local damage_type = IEex_ReadWord(effectData + 0x1E, 0x0)
	local dicenumber = IEex_ReadDword(effectData + 0x34)
	local flags = IEex_ReadDword(effectData + 0x44)
	local restype = IEex_ReadDword(effectData + 0x8C)
	local internal_flags = IEex_ReadDword(effectData + 0xC8)
	if bit.band(internal_flags, 0x4000000) > 0 then return false end
	local opcode = IEex_ReadDword(effectData + 0xC)
	if opcode ~= 12 or IEex_ReadLString(effectData + 0x90, 8) ~= "IEEX_DAM" then return false end
	if damage <= 0 and dicenumber <= 0 then return false end
	local doDeflect = false
	local weaponEnchantment = 0
	local weaponRES = IEex_ReadLString(effectData + 0x6C, 8)
	local resWrapper = IEex_DemandRes(weaponRES, "ITM")
	local weaponData = 0
	if resWrapper:isValid() then
		weaponData = resWrapper:getData()
	end

	if weaponData > 0 then
		local weaponFlags = IEex_ReadDword(weaponData + 0x18)
		if (reductionType == 1 and bit.band(weaponFlags, 0x40) > 0) or (reductionType == 2 and bit.band(weaponFlags, 0x40) == 0) or (reductionType == 3 and bit.band(weaponFlags, 0x100) > 0) or (reductionType == 4 and bit.band(weaponFlags, 0x100) == 0) or (reductionType == 5 and bit.band(weaponFlags, 0x140) == 0) or (reductionType == 6 and bit.band(weaponFlags, 0x2) > 0) or (reductionType == 7 and bit.band(weaponFlags, 0x2) == 0) or (reductionType == 8 and bit.band(weaponFlags, 0x10) > 0) or (reductionType == 9 and bit.band(weaponFlags, 0x10) == 0) or (reductionType == 10 and bit.band(weaponFlags, 0x200) > 0) or (reductionType == 11 and bit.band(weaponFlags, 0x200) == 0) then
			doDeflect = true
		end
		weaponEnchantment = IEex_ReadDword(weaponData + 0x60)
	end
	resWrapper:free()
	if reductionType == 0 and weaponEnchantment <= maxEnchantment then
		doDeflect = true
	end
	if doDeflect then
		if string > 0 then
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
		if bit.band(savingthrow, 0x10000) == 0 then
			damage = damage - modifier
		else
			damage = math.floor(damage - damage * modifier / 100)
		end
		if damage < 0 then 
			damage = 0
		end
		IEex_WriteDword(effectData + 0x18, damage)

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
	if bit.band(internal_flags, 0x4000000) > 0 then return false end
	local opcode = IEex_ReadDword(effectData + 0xC)
	local effectRES = IEex_ReadLString(effectData + 0x90, 8)
	local doDeflect = true
	if opcode ~= 12 then return false end
	if bit.band(savingthrow, 0x10000) == 0 and IEex_GetActorSpellState(targetID, 246) then
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
	if (damage_type == 0 and bit.band(types_blocked, 0x4000) > 0) or (damage_type ~= 0 and bit.band(types_blocked, damage_type) > 0) then
		if doDeflect then
			if bit.band(savingthrow, 0x10000) > 0 and delay ~= -1 then
				if delay > 0 then
					delay = delay - 1
					IEex_WriteDword(originatingEffectData + 0x44, delay)
				else
					return false
				end
			end
			
			if bit.band(savingthrow, 0x10000) == 0 and delay ~= -1 then
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
			if bit.band(savingthrow, 0x100000) > 0 and IEex_IsSprite(sourceID, false) and targetID ~= sourceID then
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
["internal_flags"] = bit.bor(internal_flags, 0x4000000),
["sectype"] = IEex_ReadDword(effectData + 0xCC),
["source_target"] = sourceID,
["source_id"] = targetID
})
			end
			if bit.band(savingthrow, 0x10000) > 0 and bit.band(savingthrow, 0x20000) > 0 and delay == 0 then
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
	if opcode == 12 and bit.band(internal_flags, 0x4000000) > 0 then
		local damage = IEex_ReadDword(effectData + 0x18)
		IEex_WriteDword(effectData + 0x18, damage * 3)
		IEex_WriteDword(effectData + 0x1C, 0)
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

IEex_AddScreenEffectsGlobal("MERESTRE", function(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	if opcode == 17 and parameter1 == 1 and parameter2 == 0 and parent_resource == "" and sourceID == -1 then
		IEex_WriteDword(effectData + 0x18, IEex_GetActorStat(targetID, 95))
	end
end)

IEex_AddScreenEffectsGlobal("MEETHERE", function(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, true) then return false end
	local targetGhostState = 0
	local sourceGhostState = 0
	if IEex_GetActorSpellState(targetID, 182) then
		targetGhostState = 2
	elseif IEex_GetActorSpellState(targetID, 189) then
		targetGhostState = 1
	end
	if IEex_GetActorSpellState(sourceID, 182) then
		sourceGhostState = 2
	elseif IEex_GetActorSpellState(sourceID, 189) then
		sourceGhostState = 1
	end
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	if parent_resource == "IEEX_DAM" then
		if ex_ethereal_sources[IEex_ReadLString(effectData + 0x6C, 8)] ~= nil or ex_ethereal_sources[IEex_ReadLString(effectData + 0x74, 8)] ~= nil then return false end
	elseif ex_ethereal_sources[parent_resource] ~= nil then 
		return false
	end
	if IEex_ReadDword(effectData + 0x14) == 10 then return false end
	if targetGhostState - sourceGhostState == 1 then
		local opcode = IEex_ReadDword(effectData + 0xC)
		local damageType = IEex_ReadWord(effectData + 0x1E, 0x0)
		if opcode == 12 and (damageType == 0 or bit.band(damageType, 0xF90) > 0) then
			if math.random(100) <= 50 then 
				IEex_ApplyEffectToActor(targetID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_55385,
["source_id"] = targetID
})
				return true
			end
		end
	elseif math.abs(targetGhostState - sourceGhostState) == 2 then
		return true
	end
	return false
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

IEex_AddScreenEffectsGlobal("METELGWK", function(effectData, creatureData)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local parameter2 = IEex_ReadDword(effectData + 0x1C)
	if opcode == 124 and parameter2 == 0 then
		local targetX = IEex_ReadDword(effectData + 0x84)
		local targetY = IEex_ReadDword(effectData + 0x88)
		local targetID = IEex_GetActorIDShare(creatureData)
		if ex_ghostwalk_dest["" .. targetID] ~= nil then
			ex_ghostwalk_dest["" .. targetID] = {targetX, targetY}
		end
		
		local areaRES = IEex_ReadLString(IEex_ReadDword(creatureData + 0x12), 8)
		local destinationHeight = 0
		if ex_specific_floor_height[areaRES] ~= nil then
			local heightMap2Wrapper = IEex_DemandRes(areaRES .. "H2", "BMP")
			if heightMap2Wrapper:isValid() then
				local heightMap2Data = heightMap2Wrapper:getData()
				local specificFloorHeight = IEex_GetBitmapPixelColor(heightMap2Data, math.floor(targetX / 16), math.floor(targetY / 12))

				if ex_specific_floor_height[areaRES][specificFloorHeight] ~= nil then
					destinationHeight = ex_specific_floor_height[areaRES][specificFloorHeight]
				end
			end
			heightMap2Wrapper:free()
		end
		local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
		if destinationHeight < 0 then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 184,
["target"] = 2,
["timing"] = 0,
["parameter2"] = 1,
["source_id"] = targetID
})
		end
	end
end)

function MELINKST(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 0x1)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(targetID, false) or not IEex_IsSprite(sourceID, false) or targetID == sourceID then return false end
	local linkRES = IEex_ReadLString(effectData + 0x18, 8)
	local timing = IEex_ReadDword(effectData + 0x20)
	local duration = IEex_ReadDword(effectData + 0x24)
	if timing == 4096 then
		timing = 0
		duration = math.floor((duration - IEex_GetGameTick()) / 15)
	end
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local special = IEex_ReadDword(effectData + 0x44)
	local re = IEex_ReadDword(effectData + 0x44)
	local linkNumber = math.random(0x40000000)
	if bit.band(savingthrow, 0x10000) > 0 or bit.band(savingthrow, 0x20000) == 0 then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = linkRES,
["internal_flags"] = 0x4000001,
["source_target"] = targetID,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = timing,
["duration"] = duration,
["parameter2"] = 209,
["parameter3"] = linkNumber,
["resource"] = linkRES,
["internal_flags"] = 0x4000001,
["source_target"] = sourceID,
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 502,
["target"] = 2,
["timing"] = timing,
["duration"] = duration,
["resist_dispel"] = IEex_ReadDword(effectData + 0x58),
["parameter3"] = linkNumber,
["special"] = IEex_ReadDword(effectData + 0x44),
["resource"] = linkRES,
["parent_resource"] = linkRES,
["casterlvl"] = IEex_ReadDword(effectData + 0xC4),
["internal_flags"] = 0x4000001,
["source_target"] = targetID,
["source_id"] = sourceID
})
	end
	if bit.band(savingthrow, 0x20000) > 0 then
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = linkRES,
["internal_flags"] = 0x4000001,
["source_target"] = sourceID,
["source_id"] = targetID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = timing,
["duration"] = duration,
["parameter2"] = 209,
["parameter3"] = linkNumber,
["resource"] = linkRES,
["internal_flags"] = 0x4000001,
["source_target"] = targetID,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 502,
["target"] = 2,
["timing"] = timing,
["duration"] = duration,
["resist_dispel"] = IEex_ReadDword(effectData + 0x58),
["parameter3"] = linkNumber,
["special"] = IEex_ReadDword(effectData + 0x44),
["resource"] = linkRES,
["parent_resource"] = linkRES,
["casterlvl"] = IEex_ReadDword(effectData + 0xC4),
["internal_flags"] = 0x4000001,
["source_target"] = sourceID,
["source_id"] = targetID
})
	end
end

function MELINKSH(originatingEffectData, effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local linkID = IEex_ReadDword(originatingEffectData + 0x10C)
	local linkNumber = IEex_ReadDword(originatingEffectData + 0x5C)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local damage = IEex_ReadDword(effectData + 0x18)
	local damageType = IEex_ReadWord(effectData + 0x1E, 0x0)
	local internal_flags = IEex_ReadDword(effectData + 0xC8)
	if opcode ~= 12 or damageType == 0x20 or bit.band(internal_flags, 0x4000000) > 0 then return false end
	if linkID <= 0 then
		IEex_IterateIDs(IEex_ReadDword(creatureData + 0x12), 0x31, true, false, function(areaActorID)
			if linkID <= 0 and areaActorID ~= targetID and IEex_GetActorSpellState(areaActorID, 209) then
				IEex_IterateActorEffects(areaActorID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					local theparameter3 = IEex_ReadDword(eData + 0x60)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					if theopcode == 288 and theparameter2 == 209 and theresource == "MELINKSH" and theparameter3 == linkNumber then
						linkID = areaActorID
						IEex_WriteDword(originatingEffectData + 0x10C, linkID)
					end
				end)
			end
		end)
	end
	if not IEex_IsSprite(linkID, false) then return false end
	local damagePercentage = IEex_ReadWord(originatingEffectData + 0x44, 0x0)
	if damagePercentage > 100 then
		damagePercentage = 100
	elseif damagePercentage == 0 then
		damagePercentage = 50
	end
	local maxDistance = IEex_ReadWord(originatingEffectData + 0x46, 0x0)
	local targetX, targetY = IEex_GetActorLocation(targetID)
	local linkX, linkY = IEex_GetActorLocation(linkID)
	if maxDistance ~= 0 and (IEex_GetDistance(targetX, targetY, linkX, linkY) > maxDistance or not IEex_CheckActorLOSObject(targetID, linkID)) then return false end
	local redirectedDamage = math.ceil(damage * damagePercentage / 100)
	if redirectedDamage <= 0 then return false end
	damage = damage - redirectedDamage
	IEex_WriteDword(effectData + 0x18, damage)
	IEex_ApplyEffectToActor(linkID, {
["opcode"] = IEex_ReadDword(effectData + 0xC),
["target"] = IEex_ReadDword(effectData + 0x10),
["power"] = IEex_ReadDword(effectData + 0x14),
["parameter1"] = redirectedDamage,
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
["sectype"] = IEex_ReadDword(effectData + 0x4C),
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
["internal_flags"] = bit.bor(internal_flags, 0x4000000),
["source_target"] = linkID,
["source_id"] = sourceID
})
	if damage <= 0 then
		return true
	else
		return false
	end
end

function MELINKEF(originatingEffectData, effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local linkID = IEex_ReadDword(originatingEffectData + 0x10C)
	local linkNumber = IEex_ReadDword(originatingEffectData + 0x5C)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local timing = IEex_ReadDword(effectData + 0x20)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local internal_flags = IEex_ReadDword(effectData + 0xC8)
	if timing == 2 or bit.band(internal_flags, 0x4000000) > 0 then return false end
	if linkID <= 0 then
		IEex_IterateIDs(IEex_ReadDword(creatureData + 0x12), 0x31, true, false, function(areaActorID)
			if linkID <= 0 and areaActorID ~= targetID and IEex_GetActorSpellState(areaActorID, 209) then
				IEex_IterateActorEffects(areaActorID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					local theparameter3 = IEex_ReadDword(eData + 0x60)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					if theopcode == 288 and theparameter2 == 209 and theresource == "MELINKEF" and theparameter3 == linkNumber then
						linkID = areaActorID
						IEex_WriteDword(originatingEffectData + 0x10C, linkID)
					end
				end)
			end
		end)
	end
	if not IEex_IsSprite(linkID, false) then return false end
	if (opcode == 402 or opcode == 430) and bit.band(savingthrow, 0x1C) == 0 then return false end
	local isSpell = false
	local itemCheckWrapper = IEex_DemandRes(parent_resource, "ITM")
	if itemCheckWrapper:isValid() then
		itemCheckWrapper:free()
		return false
	end
	itemCheckWrapper:free()
	local resWrapper = IEex_DemandRes(parent_resource, "SPL")
	if resWrapper:isValid() then
		local spellData = resWrapper:getData()
		local spellType = IEex_ReadWord(spellData + 0x1C, 0x0)
		if spellType == 1 or spellType == 2 then
			isSpell = true
		end
	end
	resWrapper:free()
	local prefix = IEex_ReadLString(effectData + 0x90, 4)
	if ex_not_linkable_spell_list[parent_resource] ~= nil or (not isSpell and ex_linkable_ability_list[parent_resource] == nil and ex_linkable_prefix_list[prefix] == nil) then return false end
	if ex_linkable_self_spell_list[parent_resource] ~= nil then
		sourceID = targetID
	end
	IEex_ApplyEffectToActor(linkID, {
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
["sectype"] = IEex_ReadDword(effectData + 0x4C),
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
["internal_flags"] = bit.bor(IEex_ReadDword(effectData + 0xC8), 0x4000000),
["source_target"] = linkID,
["source_id"] = sourceID
})
	return false
end

function MEHIDEPS(originatingEffectData, actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	if actionID == 18 then
		IEex_SetActionID(actionData, 0)
		IEex_WriteByte(creatureData + 0x4C53, 3)
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 174,
["target"] = 2,
["timing"] = 0,
["resource"] = "ACT_07",
["parent_resource"] = "USHIDEPS",
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 0,
["parameter1"] = 19944,
["parent_resource"] = "USHIDEPS",
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 20,
["target"] = 2,
["timing"] = 0,
["duration"] = 20,
["parent_resource"] = "USHIDEPS",
["source_id"] = sourceID
})
--[[
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 1,
["resource"] = USHIDEPS,
["source_target"] = sourceID,
["source_id"] = sourceID
})
--]]
	end
end

IEex_AddActionHookOpcode("MEHIDEPS")

function MESYMPAT(originatingEffectData, actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	if actionID == 22 and IEex_GetActorSpellState(sourceID, 123) then
		local sourceX = IEex_ReadDword(creatureData + 0x6)
		local sourceY = IEex_ReadDword(creatureData + 0xA)
		local ids = {}
		if IEex_ReadDword(creatureData + 0x12) > 0 then
			ids = IEex_GetIDArea(sourceID, 0x31, true, true)
		end
		local closestDistance = 0x7FFFFFFF
		local nearestTarget = nil
		for k, currentID in ipairs(ids) do
			local currentShare = IEex_GetActorShare(currentID)
			if currentShare > 0 then
				local currentX = IEex_ReadDword(currentShare + 0x6)
				local currentY = IEex_ReadDword(currentShare + 0xA)
				local currentDistance = IEex_GetDistance(sourceX, sourceY, currentX, currentY)
				local states = IEex_ReadDword(currentShare + 0x5BC)
				local general = IEex_ReadByte(currentShare + 0x25, 0x0)
				local cea = IEex_CompareActorAllegiances(sourceID, currentID)
				if general == 104 and currentDistance < closestDistance and cea ~= 1 and bit.band(states, 0x800) == 0 then
					nearestTarget = currentID
					closestDistance = currentDistance
				end
			end
		end
		if nearestTarget ~= nil then
			IEex_WriteDword(creatureData + 0x4BE, nearestTarget)
		else
			IEex_SetActionID(actionData, 0)
		end
	end
end

IEex_AddActionHookOpcode("MESYMPAT")

function METELMOA(originatingEffectData, actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	local special = IEex_ReadDword(originatingEffectData + 0x44)
	local targetX = IEex_ReadDword(creatureData + 0x6)
	local targetY = IEex_ReadDword(creatureData + 0xA)
	local destinationX = IEex_ReadDword(creatureData + 0x556E)
	local destinationY = IEex_ReadDword(creatureData + 0x5572)
	local action = IEex_ReadWord(creatureData + 0x476, 0x0)
	local actionX = IEex_ReadDword(creatureData + 0x540)
	local actionY = IEex_ReadDword(creatureData + 0x544)
	local disableTeleport = false
	local areaData = IEex_ReadDword(creatureData + 0x12)
	if areaData <= 0 then return end
	local areaType = IEex_ReadWord(areaData + 0x40, 0x0)
	if bit.band(areaType, 0x800) > 0 then
		disableTeleport = true
	else
		local areaRES = IEex_ReadLString(areaData, 8)
		if areaRES == "AR4102" and ((targetX >= 400 and targetX <= 970 and targetY >= 1030 and targetY <= 1350) or (destinationX >= 400 and destinationX <= 970 and destinationY >= 1030 and destinationY <= 1350)) then
			disableTeleport = true
		end
	end
	if disableTeleport == false and not IEex_IsGamePaused() then
		if action == 23 and (actionX > 0 and actionY > 0 and actionX < 10000 and actionY < 10000) then
			if special == 1 then
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 233,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 59,
["parent_resource"] = "USTELMOV",
["source_id"] = sourceID
})
			end
--			IEex_SetActionID(actionData, 0)
			local newDirection = IEex_GetActorRequiredDirection(sourceID, actionX, actionY)
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 124,
["target"] = 2,
["timing"] = 1,
["source_x"] = targetX,
["source_y"] = targetY,
["target_x"] = actionX,
["target_y"] = actionY,
["parent_resource"] = "USTELMOV",
["source_id"] = sourceID
})

			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = newDirection,
["resource"] = "MEFACE",
["parent_resource"] = "USTELMOV",
["source_id"] = sourceID
})

--			IEex_WriteByte(creatureData + 0x537E, newDirection)
--			IEex_WriteByte(creatureData + 0x5380, (newDirection + 1) % 16)
			if special == 1 then
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 233,
["target"] = 2,
["timing"] = 1,
["parameter2"] = 60,
["parent_resource"] = "USTELMOV",
["source_id"] = sourceID
})
			end

		else
--[[
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 0,
["parent_resource"] = "USTELMOV",
["source_id"] = sourceID
})
--]]
		end
	end
end

IEex_AddActionHookOpcode("METELMOA")

function MEFACE(effectData, creatureData)
	local parameter1 = IEex_ReadDword(effectData + 0x18)
	IEex_WriteWord(creatureData + 0x537C, 0)
	IEex_WriteByte(creatureData + 0x537E, (parameter1 + 1) % 16)
	IEex_WriteByte(creatureData + 0x5380, parameter1)
end
ex_spell_no_dec_opcode = {}
IEex_AddScreenEffectsGlobal("MEFORCND", function(effectData, creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local opcode = IEex_ReadDword(effectData + 0xC)
	local savingthrow = IEex_ReadDword(effectData + 0x3C)
	if (opcode == 146 or opcode == 148) and bit.band(savingthrow, 0x10000) > 0 then
		ex_spell_no_dec_opcode[targetID] = IEex_ReadLString(effectData + 0x2C, 8)
	end
end)

function EXFORCDI(actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	if actionID == 113 or actionID == 114 then
		local spellRES = IEex_GetActorSpellRES(sourceID)
		local targetID = IEex_GetActionObjectID(actionData)
		local targetX = IEex_GetActionPointX(actionData)
		local targetY = IEex_GetActionPointY(actionData)
		local casterClass = IEex_ReadByte(creatureData + 0x530, 0x0)
		local highestClassLevel = 0
		local highestLevelClass = 0
		local classSpellLevel = 1
		if casterClass == 0 then
			for i = 1, 11, 1 do
				if IEex_GetActorStat(sourceID, 95 + i) > highestClassLevel and IEex_GetClassSpellLevel(sourceID, i, spellRES) > 0 then
					highestLevelClass = i
					highestClassLevel = IEex_GetActorStat(sourceID, 95 + i)
					classSpellLevel = IEex_GetClassSpellLevel(sourceID, i, spellRES)
				end
			end
			casterClass = highestLevelClass
		end
		if IEex_ReadDword(creatureData + 0x52C) == 0 then
			IEex_WriteByte(creatureData + 0x530, casterClass)
			IEex_WriteByte(creatureData + 0x534, classSpellLevel)
			IEex_WriteDword(creatureData + 0x52C, IEex_GetActorStat(sourceID, 95 + casterClass))
		end
		if actionID == 113 then
			targetX, targetY = IEex_GetActorLocation(targetID)
			if ex_spell_no_dec_opcode[sourceID] == spellRES then
				ex_spell_no_dec_opcode[sourceID] = nil
				IEex_SetActionID(actionData, 191)
			end
		elseif actionID == 114 then
			if ex_spell_no_dec_opcode[sourceID] == spellRES then
				ex_spell_no_dec_opcode[sourceID] = nil
				IEex_SetActionID(actionData, 192)
			end
		end
		if (actionID == 113 and sourceID ~= targetID) or actionID == 114 then
			local newDirection = IEex_GetActorRequiredDirection(sourceID, targetX, targetY)

			IEex_WriteWord(creatureData + 0x537C, 0)
			IEex_WriteByte(creatureData + 0x537E, (newDirection + 1) % 16)
			IEex_WriteByte(creatureData + 0x5380, newDirection)
--[[
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = newDirection,
["resource"] = "MEFACE",
["parent_resource"] = "USFORCDI",
["source_id"] = sourceID
})
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 0,
["parent_resource"] = "USFORCDI",
["source_id"] = sourceID
})
--]]
		end
	end
end

IEex_AddActionHookGlobal("EXFORCDI")

function MEHIDDEN(actionData, creatureData)
	local extraFlags = IEex_ReadDword(creatureData + 0x740)
	if extraFlags > 0 then
		local isHidden = IEex_ReadByte(creatureData + 0x838, 0x0)
		if bit.band(extraFlags, 0x2000) > 0 and isHidden then
			IEex_SetActionID(actionData, 0)
		end
	end
end

IEex_AddActionHookGlobal("MEHIDDEN")

function MENOTHIN(originatingEffectData, actionData, creatureData)
	IEex_WriteWord(creatureData + 0x476, 0)
end

IEex_AddActionHookOpcode("MENOTHIN")

function IEex_CheckGlobalEffect(bitCheck)
	local player1Data = IEex_GetActorShare(IEex_GetActorIDCharacter(0))
	if player1Data > 0 then
		local globalEffectFlags = IEex_ReadDword(player1Data + 0x73C)
		if globalEffectFlags ~= -1 and bit.band(globalEffectFlags, bitCheck) ~= 0 then
			return true
		end
	end
	return false
end

function IEex_CheckGlobalEffectOnActor(actorID, bitCheck)
	local globalEffectActive = false
	local isUnaffected = false
	local player1Data = IEex_GetActorShare(IEex_GetActorIDCharacter(0))
	if player1Data > 0 then
		local globalEffectFlags = IEex_ReadDword(player1Data + 0x73C)
		if globalEffectFlags ~= -1 and bit.band(globalEffectFlags, bitCheck) > 0 then
			globalEffectActive = true
			local unaffectedFlags = 0
			IEex_IterateActorEffects(actorID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if theopcode == 206 and theresource == "EXGLOBEF" then
					unaffectedFlags = bit.bor(unaffectedFlags, thespecial)
				end
			end)
			if bit.band(bitCheck, unaffectedFlags) == bitCheck then
				isUnaffected = true
			end
		end
	end
	return globalEffectActive, isUnaffected
end

function IEex_DuelHide(creatureData)
	local targetID = IEex_GetActorIDShare(creatureData)
	local duelActive, inDuel = IEex_CheckGlobalEffectOnActor(targetID, 0x1)
	local extraFlags = IEex_ReadDword(creatureData + 0x740)
--	IEex_DS(IEex_GetActorName(targetID) .. ": " .. IEex_ToHex(extraFlags, 0, false))
	if duelActive then
		if not inDuel then
			IEex_WriteWord(creatureData + 0x476, 0)
			if IEex_ReadByte(creatureData + 0x838, 0x0) == 0 then
				IEex_WriteDword(creatureData + 0x740, bit.bor(extraFlags, 0x2000))
				IEex_WriteByte(creatureData + 0x838, 1)
			end
		end
	else
		if bit.band(extraFlags, 0x2000) > 0 and extraFlags ~= -1 and extraFlags ~= -65536 and extraFlags ~= -50393088 then
			IEex_WriteDword(creatureData + 0x740, bit.band(extraFlags, 0xFFFFDFFF))
			IEex_WriteByte(creatureData + 0x838, 0)
		end
	end
end

function MEMAGOCR(actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	if actionID == 150 then
		local isMage = false
		for class, v in pairs(ex_courteous_magocracy_classes) do
			if IEex_GetActorStat(sourceID, class + 95) > 0 then
				isMage = true
			end
		end
		local targetID = IEex_ReadDword(creatureData + 0x4BE)
		local targetShare = IEex_GetActorShare(targetID)
		if IEex_IsSprite(targetID, false) and bit.band(IEex_ReadDword(targetShare + 0x75C), 0x400) > 0 then
			IEex_WriteWord(targetShare + 0x97E, IEex_ReadSignedWord(targetShare + 0x97E, 0x0) + ex_courteous_magocracy_charisma_bonus)
		end
	end
end

IEex_AddActionHookGlobal("MEMAGOCR")

ex_ailment_contingency_conditions = {["SPPR103"] = 1, ["SPPR108"] = 10, ["SPPR212"] = 11, ["SPPR214"] = 1, ["SPPR307"] = 12, ["SPPR308"] = 13, ["SPPR314"] = 14, ["SPPR316"] = 15, ["SPPR401"] = 1, ["SPPR404"] = 16, ["SPPR426"] = 17, ["SPPR502"] = 1, ["SPPR607"] = 9, ["SPPR725"] = 59, ["USPR753"] = 9, ["USPR754"] = 1, ["SPWI203"] = 18, ["SPWI210"] = 10, ["SPWI219"] = 19, ["SPWI410"] = 12, ["SPWI614"] = 21, }
function MEAILCON(originatingEffectData, actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
	local parameter3 = IEex_ReadDword(originatingEffectData + 0x5C)
	local special = IEex_ReadDword(originatingEffectData + 0x44) * IEex_GetActorStat(sourceID, 54)
	if parameter3 == 1 then return end
	if actionID == 31 or actionID == 113 or actionID == 181 or actionID == 191 then
		
		local targetID = IEex_ReadDword(creatureData + 0x4BE)
		if not IEex_IsSprite(targetID, false) then return end
		local spellRES = IEex_GetActorSpellRES(sourceID)
		local resWrapper = IEex_DemandRes(spellRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			IEex_SetToken("EXACVAL1", IEex_FetchString(IEex_ReadDword(spellData + 0x8)))
		end
		resWrapper:free()
		local classSpellLevel = IEex_GetClassSpellLevel(sourceID, IEex_ReadByte(originatingEffectData + 0xC5, 0x0), spellRES)
		if ex_ailment_contingency_conditions[spellRES] == nil or classSpellLevel > parameter1 or classSpellLevel == 0 then
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 9,
["parameter1"] = ex_tra_55500,
["source_id"] = sourceID
})
			return
		end
		IEex_WriteDword(originatingEffectData + 0x5C, 1)
		local casterlvl = IEex_ReadDword(originatingEffectData + 0xC4)
		local parent_resource = IEex_ReadLString(originatingEffectData + 0x90, 8)
		local internalContingencyRES = parent_resource .. "S"
		if #internalContingencyRES > 8 then
			internalContingencyRES = "MEAILCON"
		end

		local playerIndex = -1
		for i = 0, 5, 1 do
			if sourceID == IEex_GetActorIDCharacter(i) then
				playerIndex = i
			end
		end
		IEex_SetActionID(actionData, 0)
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = internalContingencyRES,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 148,
["target"] = 2,
["timing"] = 9,
["resource"] = "USAILCOE",
["parent_resource"] = internalContingencyRES,
["source_x"] = IEex_ReadDword(creatureData + 0x6),
["source_y"] = IEex_ReadDword(creatureData + 0xA),
["target_x"] = IEex_ReadDword(IEex_GetActorShare(targetID) + 0x6),
["target_y"] = IEex_ReadDword(IEex_GetActorShare(targetID) + 0xA),
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 233,
["target"] = 2,
["timing"] = 9,
["parameter2"] = 69,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = -1,
["parameter2"] = classSpellLevel,
["special"] = classSpellLevel,
["savingthrow"] = 0x2000000,
["resource"] = "EXMODMEM",
["vvcresource"] = spellRES,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 0,
["duration"] = special,
["parameter4"] = playerIndex,
["savingthrow"] = 0x2000000,
["vvcresource"] = spellRES,
["resource2"] = parent_resource,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = special,
["parameter2"] = 224,
["resource"] = "USAILCON",
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 9,
["parameter1"] = ex_tra_55598,
["source_id"] = sourceID
})
	elseif actionID == 95 or actionID == 114 or actionID == 192 then
		local spellRES = IEex_GetActorSpellRES(sourceID)
		local resWrapper = IEex_DemandRes(spellRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			IEex_SetToken("EXACVAL1", IEex_FetchString(IEex_ReadDword(spellData + 0x8)))
		end
		resWrapper:free()
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 9,
["parameter1"] = ex_tra_55500,
["source_id"] = sourceID
})
	end
end

IEex_AddActionHookOpcode("MEAILCON")

function MEAILCO2(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = 0
	local spellRES = ""
	local internalContingencyRES = ""
	local casterlvl = 1
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local thesavingthrow = IEex_ReadDword(eData + 0x40)
		if theopcode == 0 and bit.band(thesavingthrow, 0x2000000) > 0 then
			spellRES = IEex_ReadLString(eData + 0x70, 8)
			internalContingencyRES = IEex_ReadLString(eData + 0x94, 8)
			casterlvl = IEex_ReadDword(eData + 0xC8)
			sourceID = IEex_ReadDword(eData + 0x110)
			if sourceID <= 0 then
				sourceID = IEex_GetActorIDCharacter(IEex_ReadDword(eData + 0x64))
			end
			if sourceID <= 0 then
				sourceID = targetID
			end
		end
	end)
	local condition = ex_ailment_contingency_conditions[spellRES]
	if condition == nil then return end
	local conditionMet = false
	if condition == 1 and IEex_ReadSignedWord(creatureData + 0x5C0, 0x0) / IEex_GetActorStat(targetID, 1) < .4 then
		conditionMet = true
	elseif condition == 9 and (IEex_ReadSignedWord(creatureData + 0x5C0, 0x0) / IEex_GetActorStat(targetID, 1) < .4 or IEex_GetActorState(targetID, 0x1C4000)) then
		conditionMet = true
	elseif condition == 10 and IEex_GetActorState(targetID, 0x4) then
		conditionMet = true
	elseif condition == 11 and (IEex_GetActorState(targetID, 0x4000) or IEex_GetActorStat(targetID, 31) >= 50) then
		conditionMet = true
	elseif condition == 12 and IEex_GetActorState(targetID, 0x80102023) then
		conditionMet = true
	elseif condition == 13 and IEex_GetActorState(targetID, 0x28) then
		conditionMet = true
	elseif condition == 14 and IEex_GetActorState(targetID, 0x80000) then
		conditionMet = true
	elseif condition == 15 and (IEex_GetActorState(targetID, 0x80100007) or IEex_GetActorSpellState(targetID, 0) or IEex_GetActorStat(targetID, 31) >= 50) then
		conditionMet = true
	elseif condition == 16 and (IEex_GetActorState(targetID, 0x4000) or IEex_GetActorStat(targetID, 31) >= 50) then
		conditionMet = true
	elseif condition == 17 and IEex_GetActorSpellState(targetID, 57) then
		conditionMet = true
	elseif condition == 18 and IEex_GetActorState(targetID, 0x40000) then
		conditionMet = true
	elseif condition == 19 and IEex_GetActorState(targetID, 0x1000) then
		conditionMet = true
	elseif condition == 20 and IEex_GetActorState(targetID, 0x10000) then
		conditionMet = true
	elseif condition == 21 and IEex_GetActorState(targetID, 0x80) then
		conditionMet = true
	elseif condition == 59 and (IEex_ReadSignedWord(creatureData + 0x5C0, 0x0) / IEex_GetActorStat(targetID, 1) < .4 or IEex_GetActorState(targetID, 0x801D70AF) or IEex_GetActorSpellState(targetID, 57)) then
		conditionMet = true
	end
	if not conditionMet then return end
	local resWrapper = IEex_DemandRes(spellRES, "SPL")
	local projectile = 0
	if resWrapper:isValid() then
		local spellData = resWrapper:getData()
		projectile = IEex_ReadWord(spellData + 0xA8, 0x0) - 1
	end
	resWrapper:free()
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 9,
["parameter1"] = ex_tra_55599,
["source_id"] = targetID
})
	if projectile == 0 then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 402,
["target"] = 2,
["timing"] = 9,
["resource"] = spellRES,
["parent_resource"] = spellRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
	else
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 430,
["target"] = 2,
["timing"] = 9,
["parameter2"] = projectile,
["resource"] = spellRES,
["parent_resource"] = spellRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
	end
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = internalContingencyRES,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
	IEex_WriteDword(effectData + 0x110, 1)
end

function MESPLSEQ(originatingEffectData, actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	local numSpells = IEex_ReadWord(originatingEffectData + 0x18, 0x0)
	local maxSpellLevel = IEex_ReadWord(originatingEffectData + 0x1A, 0x0)
	if maxSpellLevel == 0 then
		maxSpellLevel = 9
	end
	local special = IEex_ReadDword(originatingEffectData + 0x44)
	if numSpells <= 0 then return end
	if actionID == 31 or actionID == 95 or actionID == 113 or actionID == 114 or actionID == 181 or actionID == 191 or actionID == 192 then
		
		local spellRES = IEex_GetActorSpellRES(sourceID)
		local resWrapper = IEex_DemandRes(spellRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			IEex_SetToken("EXACVAL1", IEex_FetchString(IEex_ReadDword(spellData + 0x8)))
		end
		resWrapper:free()
		local casterClass = IEex_ReadSignedByte(creatureData + 0x530, 0x0)
		local classSpellLevel = IEex_ReadSignedByte(creatureData + 0x534, 0x0)
		if classSpellLevel <= 0 then
			classSpellLevel = IEex_GetClassSpellLevel(sourceID, IEex_ReadByte(originatingEffectData + 0xC5, 0x0), spellRES)
		end
		if classSpellLevel > maxSpellLevel or classSpellLevel == 0 then
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 9,
["parameter1"] = ex_tra_55596,
["source_id"] = sourceID
})
			return
		end
		numSpells = numSpells - 1
		IEex_WriteWord(originatingEffectData + 0x18, numSpells)
		local casterlvl = IEex_ReadDword(originatingEffectData + 0xC4)
		local parent_resource = IEex_ReadLString(originatingEffectData + 0x90, 8)
		local internalContingencyRES = parent_resource .. "S"
		if #internalContingencyRES > 8 then
			internalContingencyRES = "MESPLSEQ"
		end
		
		IEex_SetActionID(actionData, 0)
		local newTiming = 0
		if special == 0 then
			newTiming = 9
		end
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 233,
["target"] = 2,
["timing"] = 9,
["parameter2"] = 69,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = -1,
["parameter2"] = classSpellLevel,
["special"] = classSpellLevel,
["savingthrow"] = 0x2000000,
["resource"] = "EXMODMEM",
["vvcresource"] = spellRES,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = newTiming,
["duration"] = special,
["savingthrow"] = 0x4000000,
["vvcresource"] = spellRES,
["resource2"] = parent_resource,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = IEex_GetActorStat(sourceID, casterClass + 95) + (casterClass * 0x100),
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 172,
["target"] = 2,
["timing"] = 0,
["duration"] = special,
["resource"] = internalContingencyRES,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 171,
["target"] = 2,
["timing"] = 0,
["duration"] = special,
["resource"] = internalContingencyRES,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
		if newTiming == 0 then
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 172,
["target"] = 2,
["timing"] = 4,
["duration"] = special,
["resource"] = internalContingencyRES,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
		end
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 9,
["parameter1"] = ex_tra_55597,
["source_id"] = sourceID
})
	end
end

IEex_AddActionHookOpcode("MESPLSEQ")

function MESPLSE2(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	local spellRES = ""
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local spellList = {}
	IEex_IterateActorEffects(sourceID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local thesavingthrow = IEex_ReadDword(eData + 0x40)
		local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
		if theopcode == 0 and bit.band(thesavingthrow, 0x4000000) > 0 and theparent_resource == parent_resource then
			table.insert(spellList, {IEex_ReadLString(eData + 0x70, 8), IEex_ReadDword(eData + 0xC8)})
		end
	end)
	local sourceX, sourceY = IEex_GetActorLocation(sourceID)
	local targetX, targetY = IEex_GetActorLocation(targetID)
	local distance = math.floor(((((sourceX - targetX) / 16) ^ 2) + (((sourceY - targetY) / 12) ^ 2)) ^ .5) - 2
	for i = 1, #spellList, 1 do
		local resWrapper = IEex_DemandRes(spellList[i][1], "SPL")
		local projectile = 0
		local range = 1
		local target = 1
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			target = IEex_ReadByte(spellData + 0x8E, 0x0)
			range = IEex_ReadWord(spellData + 0x90, 0x0)
			projectile = IEex_ReadWord(spellData + 0xA8, 0x0) - 1
			IEex_SetToken("EXACVAL1", IEex_FetchString(IEex_ReadDword(spellData + 0x8)))
		end
		resWrapper:free()
		local newTargetID = targetID
		if target == 5 then
			newTargetID = sourceID
		end
		local newTargetX, newTargetY = IEex_GetActorLocation(newTargetID)
		if distance <= range or newTargetID == sourceID then
			IEex_ApplyEffectToActor(newTargetID, {
["opcode"] = 430,
["target"] = 2,
["timing"] = 9,
["parameter2"] = projectile,
["resource"] = spellList[i][1],
["parent_resource"] = spellList[i][1],
["source_x"] = sourceX,
["source_y"] = sourceY,
["target_x"] = newTargetX,
["target_y"] = newTargetY,
["casterlvl"] = spellList[i][2],
["source_id"] = sourceID
})
		end
	end
	IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = internalContingencyRES,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
	IEex_WriteDword(effectData + 0x110, 1)
end
ex_copy_spell_target_ability = {[0] = "USWI454D", [1] = "USWI454D", [2] = "USWI454D", [3] = "USWI454D", [4] = "USWI454P", [5] = "USWI454S", [6] = "USWI454D", [7] = "USWI454S"}
function MECOPYSP(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if targetID == sourceID or not IEex_IsSprite(sourceID, false) then return end
	local maxSpellLevel = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterlvl = IEex_ReadDword(effectData + 0xC4)
	local actionID = IEex_ReadWord(creatureData + 0x476, 0x0)
	IEex_SetToken("EXCPNAM1", IEex_GetActorName(targetID))
	if actionID == 31 or actionID == 95 or actionID == 191 or actionID == 192 then
		local spellRES = IEex_GetActorSpellRES(targetID)
		if ex_true_spell[spellRES] ~= nil then
			spellRES = ex_true_spell[spellRES]
		end
		local resWrapper = IEex_DemandRes(spellRES, "SPL")
		local spellTarget = 1
		local spellType = 1
		local baseSpellLevel = 0
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			spellType = IEex_ReadWord(spellData + 0x1C, 0x0)
			spellTarget = IEex_ReadByte(spellData + 0x8E, 0x0)
			baseSpellLevel = IEex_ReadDword(spellData + 0x34)
			IEex_SetToken("EXCPVAL1", IEex_FetchString(IEex_ReadDword(spellData + 0x8)))
		end
		resWrapper:free()
		local casterClass = IEex_ReadSignedByte(creatureData + 0x530, 0x0)
		local classSpellLevel = IEex_ReadSignedByte(creatureData + 0x534, 0x0)
		if classSpellLevel <= 0 then
			classSpellLevel = IEex_GetClassSpellLevel(targetID, casterClass, spellRES)
		end
		if classSpellLevel <= 0 then
			classSpellLevel = baseSpellLevel
		end
		if spellType < 1 or spellType > 2 or classSpellLevel <= 0 or ex_copy_spell_target_ability[spellTarget] == nil then
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 9,
["parameter1"] = ex_tra_55582,
["source_id"] = sourceID
})
		elseif classSpellLevel > maxSpellLevel then
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 9,
["parameter1"] = ex_tra_55581,
["source_id"] = sourceID
})
		end
		if spellType < 1 or spellType > 2 or classSpellLevel <= 0 or classSpellLevel > maxSpellLevel or ex_copy_spell_target_ability[spellTarget] == nil then return end
		local internalContingencyRES = ex_copy_spell_target_ability[spellTarget]
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 9,
["parameter1"] = ex_tra_55583,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = internalContingencyRES,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 0,
["target"] = 2,
["timing"] = 9,
["savingthrow"] = 0x8000000,
["vvcresource"] = spellRES,
["resource2"] = parent_resource,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = IEex_ReadByte(effectData + 0xC4, 0x0) + casterClass * 0x100,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 172,
["target"] = 2,
["timing"] = 9,
["resource"] = internalContingencyRES,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 171,
["target"] = 2,
["timing"] = 9,
["resource"] = internalContingencyRES,
["parent_resource"] = internalContingencyRES,
["casterlvl"] = casterlvl,
["source_id"] = sourceID
})
	else
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 9,
["parameter1"] = ex_tra_55580,
["source_id"] = sourceID
})
	end
end

function MECOPYS2(effectData, creatureData)
	if IEex_CheckForEffectRepeat(effectData, creatureData) then return end
	local targetID = IEex_GetActorIDShare(creatureData)
	local sourceID = IEex_ReadDword(effectData + 0x10C)
	if not IEex_IsSprite(sourceID, false) then return end
	local spellTarget = IEex_ReadDword(effectData + 0x44)
	local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
	local casterClass = 0
	local casterLevel = 1
	local spellRES = ""
	IEex_IterateActorEffects(sourceID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local thesavingthrow = IEex_ReadDword(eData + 0x40)
		local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
		if theopcode == 0 and bit.band(thesavingthrow, 0x8000000) > 0 and theparent_resource == parent_resource then
			spellRES = IEex_ReadLString(eData + 0x70, 8)
			casterLevel = IEex_ReadByte(eData + 0xC8, 0x0)
			casterClass = IEex_ReadByte(eData + 0xC9, 0x0)
		end
	end)
	if spellRES == "" then return end
	IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 9,
["resource"] = parent_resource,
["source_id"] = sourceID
})
	if spellTarget == 4 then
		local targetX = IEex_ReadDword(effectData + 0x84)
		local targetY = IEex_ReadDword(effectData + 0x88)
		local newDirection = IEex_GetActorRequiredDirection(sourceID, targetX, targetY)
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = newDirection,
["resource"] = "MEFACE",
["source_id"] = sourceID
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 148,
["target"] = 2,
["timing"] = 9,
["parameter1"] = casterLevel,
["savingthrow"] = 0x10000,
["resource"] = spellRES,
["target_x"] = targetX,
["target_y"] = targetY,
["casterlvl"] = casterLevel + casterClass * 0x100,
["source_id"] = sourceID
})
	else
		local targetX = IEex_ReadDword(creatureData + 0x6)
		local targetY = IEex_ReadDword(creatureData + 0xA)
		if targetID ~= sourceID then
			local newDirection = IEex_GetActorRequiredDirection(sourceID, targetX, targetY)
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = newDirection,
["resource"] = "MEFACE",
["source_id"] = sourceID
})
		end
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 146,
["target"] = 2,
["timing"] = 9,
["parameter1"] = casterLevel,
["savingthrow"] = 0x10000,
["resource"] = spellRES,
["target_x"] = IEex_ReadDword(creatureData + 0x6),
["target_y"] = IEex_ReadDword(creatureData + 0xA),
["casterlvl"] = casterLevel + casterClass * 0x100,
["source_id"] = sourceID
})
	end
end

function MEBOULDR(actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	local spellActions = {
		[31]  = 95 , -- Spell            => SpellPoint
		[113] = 114, -- ForceSpell       => ForceSpellPoint
		[181] = 114, -- ReallyForceSpell => ForceSpellPoint
		[191] = 192, -- SpellNoDec       => SpellPointNoDec
	}
--	IEex_DS(actionID)
	
	if spellActions[actionID] ~= nil and ex_due_south_spells[IEex_GetActorSpellRES(sourceID)] ~= nil then
--		IEex_DS("[" .. IEex_ReadDword(creatureData + 0x540) .. "." .. IEex_ReadDword(creatureData + 0x544) .. "]")
		local sourceX, sourceY = IEex_GetActorLocation(sourceID)
		local areaRES = ""
		if IEex_ReadDword(creatureData + 0x12) > 0 then
			areaRES = IEex_ReadLString(IEex_ReadDword(creatureData + 0x12), 8)
		end
		local resWrapper = IEex_DemandRes(areaRES .. "SR", "BMP")
		if resWrapper:isValid() then
			local bitmapData = resWrapper:getData()
			local fileSize = IEex_ReadDword(bitmapData + 0x2)
			local dataOffset = IEex_ReadDword(bitmapData + 0xA)
			local bitmapX = IEex_ReadDword(bitmapData + 0x12)
			local bitmapY = IEex_ReadDword(bitmapData + 0x16)
			local padding = 4 - (bitmapX / 2) % 4
			if padding == 4 then
				padding = 0
			end
			local areaX = bitmapX * 16
			local areaY = bitmapY * 12
			local pixelSizeX = 16
			local pixelSizeY = 12
			local current = 0
			local currentA = 0
			local currentB = 0
			local currentX = 0
			local currentY = 0
			local x = math.floor(sourceX / pixelSizeX)
			local y = bitmapY - math.floor(sourceY / pixelSizeY) - 2
			if y < 1 then
				y = 1
			end
			local trueBitmapX = math.floor(bitmapX / 2) + padding
			while y >= 2 do
				current = IEex_ReadByte(bitmapData + dataOffset + y * trueBitmapX + math.floor(x / 2), 0x0)
--				IEex_DS(current)
				if ex_default_terrain_table_1[math.floor(current / 16) + 1] == -1 and ex_default_terrain_table_1[(current % 16) + 1] == -1 then
					break
				end
				y = y - 1
			end
			IEex_WriteWord(creatureData + 0x476, spellActions[actionID])
			IEex_WriteDword(creatureData + 0x540, sourceX)
			IEex_WriteDword(creatureData + 0x544, (bitmapY - y) * pixelSizeY)
		end
		resWrapper:free()
--		IEex_DS("[" .. IEex_ReadDword(creatureData + 0x540) .. "." .. IEex_ReadDword(creatureData + 0x544) .. "]")
	end
end

IEex_AddActionHookGlobal("MEBOULDR")

function MERECACT(actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	if actionID == 31 or actionID == 113 or actionID == 181 or actionID == 191 then
		local targetID = IEex_ReadDword(creatureData + 0x4BE)
		local targetX, targetY = IEex_GetActorLocation(targetID)
		local spellRES = IEex_GetActorSpellRES(sourceID)
		IEex_Helper_SetBridge("IEex_RecordSpell", sourceID, "actionID", actionID)
		IEex_Helper_SetBridge("IEex_RecordSpell", sourceID, "targetID", targetID)
		IEex_Helper_SetBridge("IEex_RecordSpell", sourceID, "targetX", targetX)
		IEex_Helper_SetBridge("IEex_RecordSpell", sourceID, "targetY", targetY)
		IEex_Helper_SetBridge("IEex_RecordSpell", sourceID, "spellRES", spellRES)
	elseif actionID == 95 or actionID == 114 or actionID == 192 then
		local targetID = 0
		local targetX = IEex_ReadDword(creatureData + 0x540)
		local targetY = IEex_ReadDword(creatureData + 0x544)
		local spellRES = IEex_GetActorSpellRES(sourceID)
		IEex_Helper_SetBridge("IEex_RecordSpell", sourceID, "actionID", actionID)
		IEex_Helper_SetBridge("IEex_RecordSpell", sourceID, "targetID", targetID)
		IEex_Helper_SetBridge("IEex_RecordSpell", sourceID, "targetX", targetX)
		IEex_Helper_SetBridge("IEex_RecordSpell", sourceID, "targetY", targetY)
		IEex_Helper_SetBridge("IEex_RecordSpell", sourceID, "spellRES", spellRES)
	elseif actionID == 3 or actionID == 98 or actionID == 105 or actionID == 134 then
		local targetID = IEex_ReadDword(creatureData + 0x4BE)
		local weaponInfo = IEex_ReadDword(creatureData + 0x4AD8 + IEex_ReadByte(creatureData + 0x4BA4, 0x0) * 0x4)
		local weaponRES = ""
		local weaponHeader = IEex_ReadByte(creatureData + 0x4BA6, 0x0)
		if weaponInfo > 0 then
			weaponRES = IEex_ReadLString(weaponInfo + 0xC, 8)
		end
		IEex_Helper_SetBridge("IEex_RecordAttack", sourceID, "actionID", actionID)
		IEex_Helper_SetBridge("IEex_RecordAttack", sourceID, "targetID", targetID)
		IEex_Helper_SetBridge("IEex_RecordAttack", sourceID, "weaponRES", weaponRES)
		IEex_Helper_SetBridge("IEex_RecordAttack", sourceID, "weaponHeader", weaponHeader)	
	end
end

IEex_AddActionHookGlobal("MERECACT")