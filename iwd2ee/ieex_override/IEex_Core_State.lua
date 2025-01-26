
IEex_Once("IEex_CoreInitializeVariables", function()

	-- Refactored: Now bridge ("IEex_Feats", "NEW_FEATS_MAXID")
	-- IEex_NEW_FEATS_MAXID = nil
	IEex_NEW_FEATS_SIZE = nil
	IEex_NEW_SKILLS_SIZE = nil

	IEex_LISTSPLL = {}
	IEex_LISTSPLL_Reverse = {}

	IEex_LISTINNT = {}
	IEex_LISTINNT_Reverse = {}

	IEex_LISTSONG = {}
	IEex_LISTSONG_Reverse = {}

	IEex_LISTSHAP = {}
	IEex_LISTSHAP_Reverse = {}

	IEex_IndexedResources = {}
	IEex_SpellToScroll = {}
	IEex_Loaded2DAs = {}

	IEex_Helper_SynchronizedBridgeOperation("IEex_FakeCursorPosMem", function(bridge)
		IEex_FakeCursorPosMem = IEex_Helper_GetBridgeNL(bridge, "value")
		if IEex_FakeCursorPosMem == nil then
			IEex_FakeCursorPosMem = IEex_Malloc(0xC)
			IEex_WriteDword(IEex_FakeCursorPosMem, 0)
			IEex_Helper_SetBridgeNL(bridge, "value", IEex_FakeCursorPosMem)
		end
	end)
end)

function IEex_Extern_CreateAsyncState()

	IEex_AssertThread(IEex_Thread.Sync, true)

	local asyncSharedMemory = IEex_Malloc(0x4)
	IEex_WriteDword(asyncSharedMemory, IEex_AsyncInitialLockPtr)

	IEex_WriteDword(IEex_AsyncSharedMemoryPtr, asyncSharedMemory)
end

-- Called by IEexHelper when it is handling thread creation
-- function IEex_Extern_PostAsyncThreadCreated()
-- 	IEex_AssertThread(IEex_Thread.Sync, true)
-- 	while IEex_ReadByte(IEex_AsyncInitialLockPtr) == 0 do
-- 		IEex_Helper_Sleep(1)
-- 	end
-- end

function IEex_Extern_ConsoleErrorFunc(message)
	message = debug.traceback(message, 2)
	IEex_DisplayString(tostring(message))
	return message
end

function IEex_Extern_AssertFailed(assertStringPtr)
	print("["..IEex_GetMilliseconds().."] IEex detected assertion failure; dumping info:\n    "..IEex_ReadLString(assertStringPtr, 1024):gsub("\n", "\n    "))
end

function IEex_Extern_Crashing(excCode, EXCEPTION_POINTERS)

	local needReturn = false
	IEex_Helper_SynchronizedBridgeOperation("IEex_Extern_Crashing", function()
		if IEex_Helper_GetBridgeNL("IEex_Extern_Crashing", "alreadyCrashed") then
			needReturn = true
			return
		end
		IEex_Helper_SetBridgeNL("IEex_Extern_Crashing", "alreadyCrashed", true)
	end)
	if needReturn then return end

	IEex_TracebackPrint("[!]", "[!]    ", "IEex detected crash; debug info:", 1)
	IEex_DumpCrashThreadStack(EXCEPTION_POINTERS, "LPRINT: [!]     ")

	local timeFormat = "%x_%X"
	local timeString = os.date(timeFormat):gsub("/", "_"):gsub(":", "_")
	local logPath = "crash\\IEex_"..timeString..".log"
	local dmpPath = "crash\\IEex_"..timeString..".dmp"
	local bigPath = "crash\\IEex_"..timeString.."_big.dmp"
	local crashSaveName = "crash_"..timeString

	-- Lua can't make directories itself
	os.execute("if not exist crash mkdir crash")

	local logFile = io.open("IEex.log", "r")
	local logCopy = logFile:read("*a")
	logFile:close()
	local logCopyFile = io.open(logPath, "w")
	logCopyFile:write(logCopy)
	logCopyFile:close()

	IEex_Helper_WriteDump(IEex_Flags({
		0x2,     -- MiniDumpWithFullMemory
		0x4,     -- MiniDumpWithHandleData
		0x20,    -- MiniDumpWithUnloadedModules
		0x100,   -- MiniDumpWithProcessThreadData
		0x800,   -- MiniDumpWithFullMemoryInfo
		0x1000,  -- MiniDumpWithThreadInfo
		0x8000,  -- MiniDumpWithFullAuxiliaryState
		0x20000, -- MiniDumpIgnoreInaccessibleMemory
		0x40000, -- MiniDumpWithTokenInformation
	}), EXCEPTION_POINTERS, bigPath)

	IEex_Helper_WriteDump(IEex_Flags({
		0x1,  -- MiniDumpWithDataSegs
		0x40, -- MiniDumpWithIndirectlyReferencedMemory
	}), EXCEPTION_POINTERS, dmpPath)

	IEex_MessageBox("Crash detected with error code "..IEex_ToHex(excCode).."\n\nIEex.log saved to:\n    \""..logPath.."\"\n\nDMP files saved to:\n    \""..dmpPath.."\"\n    \""..bigPath.."\"\n\nYour game will attempt to save under the following name after you press OK, though it may be corrupted:\n    \""..crashSaveName.."\"\n\nPlease upload files to the Red Chimera Discord for assistance", 0x10)

	IEex_CString_Set(IEex_GetGameData() + 0x4220, crashSaveName)
	IEex_CString_Set(0x8F3338, crashSaveName)
	IEex_Call(0x5AC430, {1, 0, 0}, IEex_GetGameData(), 0x0) -- CInfGame_SaveGame()
end

function IEex_Extern_CSpell_UsableBySprite(CSpell, sprite)

	IEex_AssertThread(IEex_Thread.Both, true)
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
		--print(message)
		--IEex_MessageBox(message)
		return true
	end

	if ex_listspll[resref] then
		local spellLevel = ex_listspll[resref][7]
		if spellLevel > 0 then
			local spellsOffset = sprite + 0x4888 + 0x1C * (spellLevel - 1)
			local spellsKnown = math.floor((IEex_ReadDword(spellsOffset + 0x4) - IEex_ReadDword(spellsOffset)) / 16)
			if spellsKnown >= 24 then
				return false
			end
		end
	end

	local itemResRef = resWrapper:getResRef()
	local itemRes = resWrapper:getRes()
	local itemData = resWrapper:getData()

	local kit = IEex_GetActorStat(IEex_GetActorIDShare(sprite), 89)

	local mageKits = bit.band(kit, 0x7FC0)
	local unusableKits = IEex_Flags({
		bit.lshift(IEex_ReadByte(itemData + 0x29), 24),
		bit.lshift(IEex_ReadByte(itemData + 0x2B), 16),
		bit.lshift(IEex_ReadByte(itemData + 0x2D), 8),
		IEex_ReadByte(itemData + 0x2F)
	})

	resWrapper:free()

	if bit.band(unusableKits, mageKits) ~= 0x0 then
		-- Mage kit was explicitly excluded
		return false
	end

	return IEex_CanSpriteUseItem(sprite, itemResRef)

end

function IEex_Extern_CRuleTables_GetRaceName(race)
	IEex_AssertThread(IEex_Thread.Both, true)
	local result = IEex_2DAGetAtStrings("B3RACE", "STRREF", tostring(race))
	return result ~= "*" and tonumber(result) or ex_tra_5000
end

function IEex_Extern_CGameSprite_GetRacialFavoredClass(race)
	IEex_AssertThread(IEex_Thread.Both, true)
	local result = IEex_2DAGetAtStrings("B3RACE", "FAVORED_CLASS", tostring(race))
	return result ~= "*" and tonumber(result) or 1
end

---------------
-- Lua Hooks --
---------------

-----------
-- Feats --
-----------

function IEex_GetSpriteHasFeatAndMeetsRequirements(sprite, featID)
	return IEex_Call(0x763150, {featID}, sprite, 0x0) ~= 0
end

function IEex_GetActorHasFeatAndMeetsRequirements(actorID, featID)
	return IEex_GetSpriteHasFeatAndMeetsRequirements(IEex_GetActorShare(actorID), featID)
end

function IEex_IsFeatTakenInBaseStats(baseStats, featID)
	local mask = bit.lshift(1, bit.band(featID, 0x1F))
	local featFieldIndex = bit.rshift(featID, 5)
	local featField = IEex_ReadDword(baseStats + 0x1B8 + featFieldIndex * 4)
	return IEex_IsMaskSet(featField, mask)
end

function IEex_GetFeatCountFromBaseStats(baseStats, featID)
	if featID <= 74 then
		-- Abuse function's simple indexing and pretend like I have a sprite
		return IEex_Call(IEex_Label("CGameSprite::GetFeatCount"), {featID}, baseStats - 0x5A4, 0x0)
	elseif featID <= 111 then
		return IEex_ReadByte(baseStats + 0x1EB + (featID - 0x4B))
	else
		return IEex_ReadByte(baseStats + 0x300 + (featID - 0x70))
	end
end

function IEex_GetFeatCountFromDerivedStats(stats, featID)
	local toReturn = nil
	IEex_Helper_SynchronizedBridgeOperation("IEex_DerivedStatsData", function()
		local feats = IEex_Helper_GetBridgeNL("IEex_DerivedStatsData", stats, "feats")
		local featIndex = IEex_Helper_GetBridgeNL(feats, "feat_index_"..featID)
		toReturn = featIndex and IEex_Helper_GetBridgeNL(feats, featIndex, "count") or 0
	end)
	return toReturn
end

IEex_Feats_DefaultMaxPips = {
	[3]  = 3, [4]  = 3, [8]  = 2, [18] = 3, [20] = 3, [21] = 3, [22] = 3, [23] = 3,
	[38] = 3, [39] = 3, [40] = 3, [41] = 3, [42] = 3, [43] = 3, [44] = 3, [53] = 3,
	[54] = 3, [55] = 3, [56] = 3, [57] = 3, [60] = 2, [61] = 2, [62] = 2, [63] = 2,
	[64] = 2, [69] = 5,
}

function IEex_GetSpriteFeatCount(sprite, featID)
	if sprite <= 0 then return 0 end

	local baseStats = IEex_GetSpriteBaseStats(sprite)
	if not IEex_IsFeatTakenInBaseStats(baseStats, featID) then
		return 0
	end

	if featID > 74 or IEex_Feats_DefaultMaxPips[featID] then
		return IEex_GetFeatCountFromBaseStats(baseStats, featID)
	else
		local offset = tonumber(IEex_2DAGetAtRelated("B3FEATEX", "ID", "FEAT_COUNT_OFFSET", function(id) return tonumber(id) == featID end))
		if offset == nil or offset <= 0 then
			return 1
		else
			local featCount = IEex_ReadSignedByte(sprite + offset)
			if featCount < 1 then
				featCount = 1
				IEex_WriteByte(sprite + offset, featCount)
			end
			return featCount
		end
--		return IEex_GetFeatCountFromDerivedStats(IEex_GetSpriteDerivedStats(sprite), featID)
	end
end

function IEex_GetActorFeatCount(actorID, featID)
	return IEex_GetSpriteFeatCount(IEex_GetActorShare(actorID), featID)
end

function IEex_SetSpriteFeatCountStat(sprite, featID, count, onlyIfNew)
	local offset = tonumber(IEex_2DAGetAtRelated("B3FEATEX", "ID", "FEAT_COUNT_OFFSET", function(id) return tonumber(id) == featID end))
	if offset ~= nil and offset > 0 then
		IEex_WriteByte(sprite + offset, count)
	end
	if true then return end
	local applyEffect = false
	IEex_Helper_SynchronizedBridgeOperation("IEex_DerivedStatsData", function()
		local feats = IEex_Helper_GetBridgeNL("IEex_DerivedStatsData", IEex_GetSpriteDerivedStats(sprite), "feats")
		local featIndex = IEex_Helper_GetBridgeNL(feats, "feat_index_"..featID)
		if featIndex then
			if not onlyIfNew then
				IEex_WriteDword(IEex_Helper_GetBridgeNL(feats, featIndex, "pEffect") + 0x1C, count)
				IEex_Helper_SetBridgeNL(feats, featIndex, "count", count)
			end
		else
			applyEffect = true
		end
	end)
	if applyEffect then
		IEex_ApplyEffectToSprite(sprite, {
			["opcode"] = 500,
			["parameter1"] = featID,
			["parameter2"] = count,
			["timing"] = 9,
			["resource"] = "B3FEAT",
		})
	end
end

function IEex_SetSpriteFeatCount(sprite, featID, count)

	local featField = sprite + 0x75C + bit.rshift(featID, 5) * 4 -- sprite.m_baseStats.m_feats
	local featFieldVal = IEex_ReadDword(featField)
	local featFieldBitIndex = bit.band(featID, 0x1F)
	if count > 0 then
		IEex_WriteDword(featField, IEex_SetBit(featFieldVal, featFieldBitIndex))
	else
		IEex_WriteDword(featField, IEex_UnsetBit(featFieldVal, featFieldBitIndex))
	end

	if featID <= 74 then
		if not IEex_Feats_DefaultMaxPips[featID] then
			IEex_SetSpriteFeatCountStat(sprite, featID, count)
		else
			IEex_Call(IEex_Label("CGameSprite::SetFeatCount"), {count, featID}, sprite, 0x0)
		end
	elseif featID <= 111 then
		IEex_WriteByte(sprite + 0x78F + (featID - 0x4B), count)
	else
		IEex_WriteByte(sprite + 0x8A4 + (featID - 0x70), count)
	end
end

function IEex_SetActorFeatCount(actorID, featID, count)
	IEex_SetSpriteFeatCount(IEex_GetActorShare(actorID), featID, count)
end

function IEex_GetSpriteMeetsFeatRequirements(sprite, featID, bUseBaseAttributes)
	local actorID = IEex_GetActorIDShare(sprite)
	if featID <= 74 then
		local prerequisiteFunc = IEex_2DAGetAtRelated("B3FEATEX", "ID", "PREREQUISITE_FUNCTION", function(id) return tonumber(id) == featID end)
		if prerequisiteFunc ~= "*" and prerequisiteFunc ~= "" then
			return _G[prerequisiteFunc](actorID, featID, bUseBaseAttributes)
		else
			return IEex_Call(IEex_Label("CGameSprite::MeetsFeatRequirements"), {bUseBaseAttributes, featID}, sprite, 0x0) ~= 0
		end
	else
		local prerequisiteFunc = IEex_2DAGetAtRelated("B3FEATS", "ID", "PREREQUISITE_FUNCTION", function(id) return tonumber(id) == featID end)
		return prerequisiteFunc == "*" or prerequisiteFunc == "" or _G[prerequisiteFunc](actorID, featID, bUseBaseAttributes)
	end
end

function IEex_GetActorMeetsFeatRequirements(actorID, featID, bUseBaseAttributes)
	return IEex_GetSpriteMeetsFeatRequirements(IEex_GetActorShare(actorID), featID, bUseBaseAttributes)
end

function IEex_GetFeatMaxPips(featID)
	if featID <= 74 then
		local newMax = tonumber(IEex_2DAGetAtRelated("B3FEATEX", "ID", "MAX", function(id) return tonumber(id) == featID end))
		if newMax then
			return newMax
		else
			return IEex_Feats_DefaultMaxPips[featID] or 1
		end
	else
		return tonumber(IEex_2DAGetAtRelated("B3FEATS", "ID", "MAX", function(id) return tonumber(id) == featID end))
	end
end

function IEex_GetSpriteFeatIncrementable(sprite, featID, bCheckOnePipRequirements)
	if sprite <= 0 then return false end
	local featCount = IEex_GetSpriteFeatCount(sprite, featID)
	local featMaxPips = IEex_GetFeatMaxPips(featID)
	if featCount >= featMaxPips then
		return false
	end

	local actorID = IEex_GetActorIDShare(sprite)
	if featID <= 74 then
		local incrementableFunc = IEex_2DAGetAtRelated("B3FEATEX", "ID", "INCREMENTABLE_FUNCTION", function(id) return tonumber(id) == featID end)
		if incrementableFunc ~= "*" and incrementableFunc ~= "" then
			if not _G[incrementableFunc](actorID, featID) then
				return false
			end
		elseif ((featID >= 38 and featID <= 44) or (featID >= 53 and featID <= 57)) and featCount == 2 and IEex_ReadByte(sprite + 0x62B) < 4 then -- sprite.m_baseStats.m_fighterLevel
			return false
		end
	else
		local incrementableFunc = IEex_2DAGetAtRelated("B3FEATS", "ID", "INCREMENTABLE_FUNCTION", function(id) return tonumber(id) == featID end)
		if incrementableFunc ~= "*" and incrementableFunc ~= "" and not _G[incrementableFunc](actorID, featID) then
			return false
		end
	end

	return (featMaxPips == 1 and not bCheckOnePipRequirements) or IEex_GetSpriteMeetsFeatRequirements(sprite, featID, true)
end

function IEex_GetActorFeatIncrementable(actorID, featID, bCheckOnePipRequirements)
	return IEex_GetSpriteFeatIncrementable(IEex_GetActorShare(actorID), featID, bCheckOnePipRequirements)
end

function IEex_Extern_FeatHook(sprite, oldBaseStats, oldDerivedStats)
	if sprite <= 0 then return end
	IEex_AssertThread(IEex_Thread.Async, true)
	local maxID = IEex_Helper_GetBridge("IEex_Feats", "NEW_FEATS_MAXID")
	if IEex_GetActiveEngine() == IEex_GetEngineCharacter() then
		for featID = 0, maxID do
			if IEex_IsFeatTakenInBaseStats(IEex_GetSpriteBaseStats(sprite), featID) then
				local oldFeatCount = (featID > 74 or IEex_Feats_DefaultMaxPips[featID])
					and IEex_GetFeatCountFromBaseStats(oldBaseStats, featID)
					or IEex_GetFeatCountFromBaseStats(oldBaseStats, featID)
				local newFeatCount = IEex_GetSpriteFeatCount(sprite, featID)
				if oldFeatCount ~= newFeatCount then
					for featLevel = oldFeatCount + 1, newFeatCount, 1 do
						IEex_ApplyResref("FE_"..featID.."_"..featLevel, IEex_GetActorIDShare(sprite))
					end
				end
			end
		end
	end
end

--------------------
-- FeatList Hooks --
--------------------

function IEex_Extern_GetFeatStringHasCountHook(featID)
	IEex_AssertThread(IEex_Thread.Both, true)
	return IEex_GetFeatMaxPips(featID) > 1
end

function IEex_Extern_GetFeatMaxPipsHook(featID)
	IEex_AssertThread(IEex_Thread.Sync, true)
	return IEex_GetFeatMaxPips(featID)
end

function IEex_Extern_GetSpriteFeatCountHook(sprite, featID)
	IEex_AssertThread(IEex_Thread.Both, true)
	return IEex_GetSpriteFeatCount(sprite, featID)
end

function IEex_Extern_SetSpriteFeatCountHook(sprite, featID, count)
	IEex_AssertThread(IEex_Thread.Async, true)
	IEex_SetSpriteFeatCount(sprite, featID, count)
end

function IEex_Extern_GetSpriteMeetsFeatRequirementsHook(sprite, featID, bUseBaseAttributes)
	IEex_AssertThread(IEex_Thread.Both, true)
	return IEex_GetSpriteMeetsFeatRequirements(sprite, featID, bUseBaseAttributes ~= 0)
end

function IEex_Extern_GetFeatIncrementableHook(sprite, featID, bCheckOnePipRequirements)
	IEex_AssertThread(IEex_Thread.Both, true)
	return IEex_GetSpriteFeatIncrementable(sprite, featID, bCheckOnePipRequirements ~= 0)
end

function IEex_FeatStat_Init(stats)
	IEex_Helper_GetBridgeCreateNL(stats, "feats")
end

function IEex_FeatStat_Reload(stats)
	IEex_Helper_ClearBridgeNL(stats, "feats")
end

function IEex_FeatStat_Copy(sourceStats, destStats)
	IEex_Helper_ClearBridgeNL(destStats, "feats")
	local sourceFeats = IEex_Helper_GetBridgeNL(sourceStats, "feats")
	local destFeats = IEex_Helper_GetBridgeNL(destStats, "feats")
	for i = 1, IEex_Helper_GetBridgeNumIntsNL(sourceFeats) do
		local sourceFeat = IEex_Helper_GetBridgeNL(sourceFeats, i)
		IEex_Helper_SetBridgeNL(destFeats, i, sourceFeat)
		IEex_Helper_SetBridgeNL(destFeats, "feat_index_"..IEex_Helper_GetBridgeNL(sourceFeat, "featID"), i)
	end
end

function B3FEAT(pEffect, pSprite)

	IEex_AssertThread(IEex_Thread.Async, true)

	local actorID = IEex_GetActorIDShare(pSprite)
	local featID = IEex_ReadDword(pEffect + 0x18)
	local count = IEex_ReadDword(pEffect + 0x1C)

	IEex_Helper_SynchronizedBridgeOperation("IEex_DerivedStatsData", function()
		local feats = IEex_Helper_GetBridgeNL("IEex_DerivedStatsData", IEex_GetSpriteDerivedStats(pSprite), "feats")
		local featIndex = IEex_Helper_GetBridgeNL(feats, "feat_index_"..featID)
		if featIndex then
			IEex_Helper_SetBridgeNL(feats, featIndex, "count", count)
		else
			local newEntry, newEntryI = IEex_AppendBridgeTableNL(feats)
			IEex_Helper_SetBridgeNL(newEntry, "pEffect", pEffect)
			IEex_Helper_SetBridgeNL(newEntry, "featID", featID)
			IEex_Helper_SetBridgeNL(newEntry, "count", count)
			IEex_Helper_SetBridgeNL(feats, "feat_index_"..featID, newEntryI)
		end
	end)
end

---------------
-- Functions --
---------------

-- Earliest possible hook into engine
-- Directly before CBaldurChitin_Construct()
function IEex_Extern_Stage0Startup()
	IEex_Helper_SetBridge("IEex_ThreadBridge", "Sync", IEex_GetCurrentThread())
end

-- CBaldurChitin = partially initialized
-- Engines = constructed
-- Directly before CInfGame_Construct()
function IEex_Extern_Stage1Startup()
	IEex_AssertThread(IEex_Thread.Sync, true)
	IEex_DoStage1Indexing()
	IEex_LoadInitial2DAs()
	IEex_WriteDelayedPatches()
end

-- CBaldurChitin = initialized
-- Engines = constructed
-- CInfGame = constructed
-- Directly after CBaldurChitin_Init()
function IEex_Extern_Stage2Startup()
	IEex_AssertThread(IEex_Thread.Sync, true)
	IEex_DoStage2Indexing()
end

function IEex_DoStage1Indexing()
	IEex_IndexAllResources()
	IEex_MapSpellsToScrolls()
end

function IEex_DoStage2Indexing()
	IEex_IndexMasterSpellLists()
	IEex_MoveHighResolutionPaddingPanels()
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
			local type = IEex_ReadWord(unknownSubstruct2 + currentAddress + 0x12)
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
				local category = IEex_ReadWord(data + 0x1C)
				local abilitiesNum = IEex_ReadWord(data + 0x68)

				if category == 11 and abilitiesNum >= 2 then

					local secondAbilityAddress = data + IEex_ReadDword(data + 0x64) + 0x38
					local secondAbilityEffectCount = IEex_ReadWord(secondAbilityAddress + 0x1E)

					if secondAbilityEffectCount >= 1 then
						local effectIndex = IEex_ReadWord(secondAbilityAddress + 0x20)
						local effectAddress = data + IEex_ReadDword(data + 0x6A) + effectIndex * 0x30
						if IEex_ReadWord(effectAddress) == 147 then
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

	if IEex_Vanilla then return end

	IEex_Loaded2DAs = {}

	local feats2DA = IEex_2DADemand("B3FEATS")

	local idColumn = IEex_2DAFindColumn(feats2DA, "ID")
	local maxRowIndex = IEex_ReadWord(feats2DA + 0x22) - 1

	local previousID = 74
	for rowIndex = 0, maxRowIndex, 1 do
		local myID = tonumber(IEex_2DAGetAt(feats2DA, idColumn, rowIndex))
		if (previousID + 1) ~= myID then
			IEex_TracebackMessage("IEex CRITICAL ERROR - B3FEATS.2DA contains hole at ID = "..(previousID + 1).."; Fix this!")
		end
		previousID = myID
	end

	IEex_Helper_SetBridge("IEex_Feats", "NEW_FEATS_MAXID", previousID)
	IEex_NEW_FEATS_SIZE = previousID + 1

	local skills2DA = IEex_2DADemand("SKILLS")

	IEex_NEW_SKILLS_SIZE = tonumber(IEex_2DAGetAt(skills2DA, IEex_2DAFindColumn(skills2DA, "ID"), IEex_ReadWord(skills2DA + 0x22) - 1)) + 1
--	print(IEex_NEW_SKILLS_SIZE)
end



-- This is special and is needed in some IEex_Gui_State calls;
-- it SHOULD be in a Patch file, but some major refactoring would
-- have to take place to make that happen.
IEex_AbsoluteOnce("IEex_GetLuaState", function()

	-- Rest of special async globals in IEex_Core_Patch
	IEex_AsyncState = IEex_Call(IEex_Label("_luaL_newstate"), {}, nil, 0x0)
	IEex_Call(IEex_Label("_luaL_openlibs"), {IEex_AsyncState}, nil, 0x4)
	IEex_DefineAssemblyLabel("_g_lua_async", IEex_AsyncState)

	----------------------
	-- IEex_GetLuaState --
	----------------------

	local IEex_GetLuaState = IEex_WriteAssemblyAuto({[[

		$IEex_GetLuaState
		!push_registers_iwd2

		!call >IEex_GetCurrentThread
		!mov_ebx_eax

		!push_dword ]], {IEex_WriteStringAuto("Sync"), 4}, [[
		!push_dword ]], {IEex_WriteStringAuto("IEex_ThreadBridge"), 4}, [[
		!call >IEex_Helper_GetBridgeDirect

		!cmp_ebx_eax
		!jne_dword >not_sync
		!mov_eax *_g_lua
		!jmp_dword >return

		@not_sync
		!push_dword ]], {IEex_WriteStringAuto("Async"), 4}, [[
		!push_dword ]], {IEex_WriteStringAuto("IEex_ThreadBridge"), 4}, [[
		!call >IEex_Helper_GetBridgeDirect

		!cmp_ebx_eax
		!jne_dword >not_async
		!mov_eax *_g_lua_async
		!jmp_dword >return

		@not_async
		!xor_eax_eax

		@return
		!pop_registers_iwd2
		!ret
	]]})

	IEex_Helper_DefineAddress("IEex_JIT_GetLuaState", IEex_GetLuaState)
end)

function IEex_WriteDelayedPatches()

	if IEex_Vanilla then return end

	IEex_DisableCodeProtection()

	------------------------
	-- FeatList Hooks ASM --
	------------------------

	--------------------------------
	-- FIX CHARGEN ARRAY OVERFLOW --
	--------------------------------

		local featsArraySize = IEex_NEW_FEATS_SIZE * 0x4

		local chargenBeforeFeatCounts = IEex_Malloc(featsArraySize)
		IEex_Helper_Memset(chargenBeforeFeatCounts, 0, featsArraySize)

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

	--------------------------------
	-- FIX LEVELUP ARRAY OVERFLOW --
	--------------------------------

		local levelupBeforeFeatCounts = IEex_Malloc(featsArraySize)
		IEex_Helper_Memset(levelupBeforeFeatCounts, 0, featsArraySize)

		----------------------------------------
		-- CScreenCharacter_OnBackButtonClick --
		----------------------------------------

		IEex_WriteAssembly(0x5E4311, {"!mov_edi", {levelupBeforeFeatCounts, 4}, "!nop"})

		-----------------------------------------
		-- CScreenCharacter_OnFeatPipTakenBack --
		-----------------------------------------

		IEex_WriteAssembly(0x5F89D5, {"!mov_ebp", {levelupBeforeFeatCounts, 4}, "!nop"})

		-------------------------------------
		-- CScreenCharacter_ResetFeatPanel --
		-------------------------------------

		IEex_WriteAssembly(0x5DA2DE, {"!mov_[ecx*4+dword]_eax", {levelupBeforeFeatCounts, 4}})

		--------------------------------------
		-- CScreenCharacter_UpdateFeatPanel --
		--------------------------------------

		IEex_WriteAssembly(0x5E8AD7, {"!cmp_[ecx*4+dword]_eax", {levelupBeforeFeatCounts, 4}})

		-----------------------------------------------------------
		-- CUIControlButtonFeatListPlusMinus_OnLButtonDownActive --
		-----------------------------------------------------------

		IEex_WriteAssembly(0x5F7156, {"!cmp_[esi*4+dword]_eax", {levelupBeforeFeatCounts, 4}})

	------------------------------
	-- CGameSprite_SetFeatCount --
	------------------------------

	IEex_WriteByte(0x762897 + 2, IEex_NEW_FEATS_SIZE)

	IEex_HookReplaceFunctionMaintainOriginal(0x762890, 7, "CGameSprite::SetFeatCount", IEex_FlattenTable({
		{[[
			!mark_esp
			!push_registers_iwd2
		]]},
		IEex_GenLuaCall("IEex_Extern_SetSpriteFeatCountHook", {
			["args"] = {
				{"!push(ecx)"},                 -- sprite
				{"!marked_esp !push([esp+4])"}, -- featID
				{"!marked_esp !push([esp+8])"}, -- count
			},
		}),
		{[[
			@call_error
			!pop_registers_iwd2
			!ret(8)
		]]},
	}))

	-- Disable default maximum-feat-count assertions
	for _, address in ipairs({0x762923, 0x76294D, 0x762977, 0x7629A1, 0x7629CB, 0x7629F5, 0x762A1F, 0x762A49,
		0x762A73, 0x762A9D, 0x762AC7, 0x762AF1, 0x762B1B, 0x762B45, 0x762B6F, 0x762B99, 0x762BC3, 0x762BED,
		0x762C17, 0x762C41, 0x762C6B, 0x762C95, 0x762CBF, 0x762CE9, 0x762D13, 0x762D3D})
	do
		IEex_WriteAssembly(address, {"!jmp_byte"})
	end

	IEex_RegisterLuaStat({
		["init"] = "IEex_FeatStat_Init",
		["reload"] = "IEex_FeatStat_Reload",
		["copy"] = "IEex_FeatStat_Copy",
	})

	------------------------------
	-- CGameSprite_GetFeatCount --
	------------------------------

	IEex_WriteByte(0x762E26 + 2, IEex_NEW_FEATS_SIZE)

	IEex_HookReplaceFunctionMaintainOriginal(0x762E20, 6, "CGameSprite::GetFeatCount", IEex_FlattenTable({
		{[[
			!mark_esp
			!push_registers_iwd2
		]]},
		IEex_GenLuaCall("IEex_Extern_GetSpriteFeatCountHook", {
			["args"] = {
				{"!push(ecx)"},                 -- sprite
				{"!marked_esp !push([esp+4])"}, -- featID
			},
			["returnType"] = IEex_LuaCallReturnType.Number,
		}),
		{[[
			!jmp_dword >no_error

			@call_error
			!xor_eax_eax

			@no_error
			!pop_registers_iwd2
			!ret(4)
		]]},
	}))

	-----------------------------------
	-- CGameSprite_FeatGetNumMaxPips --
	-----------------------------------

	IEex_WriteByte(0x7630A5 + 2, IEex_NEW_FEATS_SIZE)

	-- Complete function reimplementation
	IEex_HookJumpNoReturn(0x7630A0, IEex_FlattenTable({
		{[[
			!mark_esp
			!push_registers_iwd2
		]]},
		IEex_GenLuaCall("IEex_Extern_GetFeatMaxPipsHook", {
			["args"] = {
				{"!marked_esp !push([esp+4])"}, -- featID
			},
			["returnType"] = IEex_LuaCallReturnType.Number,
		}),
		{[[
			!jmp_dword >no_error

			@call_error
			!mov_eax #1

			@no_error
			!pop_registers_iwd2
			!ret(4)
		]]},
	}))

	---------------------------------------
	-- CGameSprite_MeetsFeatRequirements --
	---------------------------------------

	IEex_WriteByte(0x763206 + 2, IEex_NEW_FEATS_SIZE)

	IEex_HookReplaceFunctionMaintainOriginal(0x763200, 6, "CGameSprite::MeetsFeatRequirements", IEex_FlattenTable({
		{[[
			!mark_esp
			!push_registers_iwd2
		]]},
		IEex_GenLuaCall("IEex_Extern_GetSpriteMeetsFeatRequirementsHook", {
			["args"] = {
				{"!push(ecx)"},                 -- sprite
				{"!marked_esp !push([esp+4])"}, -- featID
				{"!marked_esp !push([esp+8])"}, -- bUseBaseAttributes
			},
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}),
		{[[
			!jmp_dword >no_error

			@call_error
			!xor_eax_eax

			@no_error
			!pop_registers_iwd2
			!ret(8)
		]]},
	}))

	-----------------------------------
	-- CGameSprite_FeatIncrementable --
	-----------------------------------

	IEex_WriteByte(0x763A46 + 2, IEex_NEW_FEATS_SIZE)

	-- Complete function reimplementation
	IEex_HookJumpNoReturn(0x763A40, IEex_FlattenTable({
		{[[
			!mark_esp
			!push_registers_iwd2
		]]},
		IEex_GenLuaCall("IEex_Extern_GetFeatIncrementableHook", {
			["args"] = {
				{"!push(ecx)"},                 -- sprite
				{"!marked_esp !push([esp+4])"}, -- featID
				{"!marked_esp !push([esp+8])"}, -- bCheckOnePipRequirements
			},
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}),
		{[[
			!jmp_dword >no_error

			@call_error
			!xor_eax_eax

			@no_error
			!pop_registers_iwd2
			!ret(8)
		]]},
	}))

	-----------------------------------------
	-- CGameSprite_UpdateSkillsAndFeatsTab --
	-----------------------------------------

	IEex_WriteByte(0x765CE8 + 2, IEex_NEW_FEATS_SIZE)
	IEex_WriteByte(0x765DC8 + 2, IEex_NEW_FEATS_SIZE)

	IEex_HookJumpNoReturn(0x765D24, IEex_FlattenTable({
		{[[
			!push_registers_iwd2
		]]},
		IEex_GenLuaCall("IEex_Extern_GetFeatStringHasCountHook", {
			["args"] = {
				{"!push(esi)"}, -- featID
			},
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}),
		{[[
			!jmp_dword >no_error

			@call_error
			!xor_eax_eax

			@no_error
			!pop_registers_iwd2
			!test_eax_eax
			!jz_dword :765D7E
			!jmp_dword :765D3B
		]]},
	}))

	---------------------------------------------
	-- CGameSprite_HasFeatAndMeetsRequirements --
	---------------------------------------------

	IEex_WriteByte(0x763156 + 2, IEex_NEW_FEATS_SIZE)

	---------------------------------------
	-- CScreenCharacter_CheckSummonPopup --
	---------------------------------------

	IEex_WriteByte(0x5E1251 + 2, IEex_NEW_FEATS_SIZE)

	---------------
	-- nNumItems --
	---------------

	IEex_WriteWord(0x84EA66, IEex_NEW_FEATS_SIZE)

	--This code prevents the game from crashing when there are more than 16 skills in SKILLS.2DA, but the additional skills still aren't displayed on the skills screen.
	IEex_WriteByte(0x763E9D + 2, IEex_NEW_SKILLS_SIZE)
	IEex_WriteByte(0x76429A + 2, IEex_NEW_SKILLS_SIZE)
	IEex_WriteByte(0x7642D6 + 2, IEex_NEW_SKILLS_SIZE)
	IEex_WriteByte(0x764313 + 4, IEex_NEW_SKILLS_SIZE)
	IEex_WriteByte(0x7644C6 + 2, IEex_NEW_SKILLS_SIZE)

	-- This needs to come after all other patches... even the delayed ones
	IEex_Debug_WriteTracePatches()

	IEex_EnableCodeProtection()

end
