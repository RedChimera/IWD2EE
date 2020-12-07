
IEex_Once("IEex_CoreInitializeVariables", function()

	-- Refactored: Now bridge ("IEex_Feats", "NEW_FEATS_MAXID")
	-- IEex_NEW_FEATS_MAXID = nil 
	IEex_NEW_FEATS_SIZE  = nil

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

end)

function IEex_Extern_CreateAsyncState()

	IEex_AssertThread(IEex_Thread.Sync, true)

	-- Figure size of asyncSharedMemory
	IEex_LabelCount = 0
	IEex_LabelTotalKeyLength = 0
	for key, _ in pairs(IEex_GlobalAssemblyLabels) do
		IEex_LabelCount = IEex_LabelCount + 1
		IEex_LabelTotalKeyLength = IEex_LabelTotalKeyLength + #key + 1
	end
	local asyncSharedMemory = IEex_Malloc(0xC + IEex_LabelCount * 0x8)

	IEex_WriteDword(asyncSharedMemory, IEex_AsyncState)
	IEex_WriteDword(asyncSharedMemory + 0x4, IEex_LabelCount)
	IEex_WriteDword(asyncSharedMemory + 0x8, IEex_AsyncInitialLock)

	-- Write all Sync labels to shared memory so the Async state can initialize itself
	local currentEntryPointer = asyncSharedMemory + 0xC
	local currentKeysMemPointer = IEex_Malloc(IEex_LabelTotalKeyLength)

	for key, val in pairs(IEex_GlobalAssemblyLabels) do
		IEex_WriteString(currentKeysMemPointer, key)
		IEex_WriteDword(currentEntryPointer, currentKeysMemPointer)
		IEex_WriteDword(currentEntryPointer + 0x4, val)
		currentEntryPointer = currentEntryPointer + 0x8
		currentKeysMemPointer = currentKeysMemPointer + #key + 1
	end

	IEex_WriteDword(IEex_AsyncSharedMemoryPtr, asyncSharedMemory)

end

function IEex_Extern_AssertFailed(assertStringPtr)
	print("["..IEex_GetMilliseconds().."] IEex detected assertion failure; dumping info:\n    "..IEex_ReadLString(assertStringPtr, 1024):gsub("\n", "\n    "))
end

function IEex_Extern_Crashing(excCode, EXCEPTION_POINTERS)

	IEex_AssertThread(IEex_Thread.Both, true)
	IEex_TracebackPrint("IEex detected crash; Lua traceback ->", 1)

	local timeFormat = "%x_%X"
	local timeString = os.date(timeFormat):gsub("/", "_"):gsub(":", "_")
	local logPath = "crash\\IEex_"..timeString..".log"
	local dmpPath = "crash\\IEex_"..timeString..".dmp"

	-- Lua can't make directories itself :(
	os.execute("mkdir crash")

	local logFile = io.open("IEex.log", "r")
	local logCopy = logFile:read("*a")
	logFile:close()
	local logCopyFile = io.open(logPath, "w")
	logCopyFile:write(logCopy)
	logCopyFile:close()

	local dmpPathMem = IEex_WriteStringAuto(dmpPath)
	IEex_DllCall("IEexHelper", "WriteDump", {dmpPathMem, EXCEPTION_POINTERS, excCode, 0x41}, nil, 0x10)
	IEex_Free(dmpPathMem)

	IEex_MessageBox("Crash detected with error code "..IEex_ToHex(excCode).."\n\nIEex.log saved to \""..logPath.."\"\nDMP file saved to \""..dmpPath.."\"\n\nPlease upload files to the Red Chimera Discord for assistance", 0x10)
end

function IEex_Extern_CSpell_UsableBySprite(CSpell, sprite)

	IEex_AssertThread(IEex_Thread.Async, true)
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

	local itemResRef = resWrapper:getResRef()
	local itemRes = resWrapper:getRes()
	local itemData = resWrapper:getData()

	local kit = IEex_GetActorStat(IEex_GetActorIDShare(sprite), 89)

	local mageKits = bit.band(kit, 0x7FC0)
	local unusableKits = IEex_Flags({
		bit.lshift(IEex_ReadByte(itemData + 0x29, 0), 24),
		bit.lshift(IEex_ReadByte(itemData + 0x2B, 0), 16),
		bit.lshift(IEex_ReadByte(itemData + 0x2D, 0), 8),
		IEex_ReadByte(itemData + 0x2F, 0)
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

function IEex_IsFeatTaken(baseStats, featID)
	local mask = bit.lshift(1, bit.band(featID, 0x1F))
	local offset = bit.rshift(featID, 5)
	local featField = IEex_ReadDword(baseStats+offset*4+0x1B8)
	return IEex_IsMaskSet(featField, mask)
end

function IEex_GetFeatCount(baseStats, featID)
	-- Abuse function's simple indexing to treat in terms of baseStats and not CGameSprite
	return IEex_Call(0x762E20, {featID}, baseStats - 0x5A4, 0x0)
end

function IEex_Extern_FeatHook(share, oldBaseStats, oldDerivedStats)
	IEex_AssertThread(IEex_Thread.Async, true)
	local newBaseStats = share + 0x5A4
	local maxID = IEex_Helper_GetBridge("IEex_Feats", "NEW_FEATS_MAXID")
	for featID = 0, maxID, 1 do
		if IEex_IsFeatTaken(newBaseStats, featID) then
			local oldFeatCount = IEex_GetFeatCount(oldBaseStats, featID)
			local newFeatCount = IEex_GetFeatCount(newBaseStats, featID)
			if oldFeatCount ~= newFeatCount then
				for featLevel = oldFeatCount + 1, newFeatCount, 1 do
					IEex_ApplyResref("FE_"..featID.."_"..featLevel, IEex_GetActorIDShare(share))
				end
			end
		end
	end
end

--------------------
-- FeatList Hooks --
--------------------

function IEex_Extern_FeatPanelStringHook(featID)
	IEex_AssertThread(IEex_Thread.Async, true)
	local foundMax = tonumber(IEex_2DAGetAtRelated("B3FEATS", "ID", "MAX", function(id) return tonumber(id) == featID end))
	return foundMax > 1
end

function IEex_Extern_FeatPipsHook(featID)
	IEex_AssertThread(IEex_Thread.Sync, true)
	return tonumber(IEex_2DAGetAtRelated("B3FEATS", "ID", "MAX", function(id) return tonumber(id) == featID	end))
end

function IEex_Extern_GetFeatCountHook(sprite, featID)
	IEex_AssertThread(IEex_Thread.Both, true)
	return IEex_ReadByte(sprite + 0x78F + (featID - 0x4B), 0)
end

function IEex_Extern_SetFeatCountHook(sprite, featID, count)
	IEex_AssertThread(IEex_Thread.Async, true)
	IEex_WriteByte(sprite + 0x78F + (featID - 0x4B), count)
end

function IEex_Extern_FeatIncrementableHook(sprite, featID)

	IEex_AssertThread(IEex_Thread.Both, true)

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

function IEex_Extern_MeetsFeatRequirementsHook(sprite, featID)
	IEex_AssertThread(IEex_Thread.Both, true)
	local foundFunc = IEex_2DAGetAtRelated("B3FEATS", "ID", "PREREQUISITE_FUNCTION", function(id) return tonumber(id) == featID end)
	if foundFunc ~= "*" and foundFunc ~= "" and not _G[foundFunc](IEex_GetActorIDShare(sprite), featID) then return false end
	return true
end

---------------
-- Functions --
---------------

function IEex_Extern_Stage1Startup()
	IEex_Helper_SetBridge("IEex_ThreadBridge", "Sync", IEex_GetCurrentThread())
	IEex_DoStage1Indexing()
	IEex_LoadInitial2DAs()
	IEex_WriteDelayedPatches()
end

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

	IEex_Helper_SetBridge("IEex_Feats", "NEW_FEATS_MAXID", previousID)
	IEex_NEW_FEATS_SIZE = previousID + 1

end

function IEex_WriteDelayedPatches()

	IEex_DisableCodeProtection()

	------------------------
	-- FeatList Hooks ASM --
	------------------------

	--------------------------------
	-- FIX CHARGEN ARRAY OVERFLOW --
	--------------------------------

	local chargenBeforeFeatCounts = IEex_Malloc(IEex_NEW_FEATS_SIZE * 0x4)
	local maxID = IEex_Helper_GetBridge("IEex_Feats", "NEW_FEATS_MAXID")
	for i = 0, maxID, 1 do
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

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_SetFeatCountHook"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; sprite ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; featID ;
		!push_edi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; count ;
		!push_ebx
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 03
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
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

		!call >IEex_GetLuaState
		!mov_ebx_eax

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_GetFeatCountHook"), 4}, [[
		!push_ebx
		!call >_lua_getglobal
		!add_esp_byte 08

		; sprite ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; featID ;
		!push_edi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 01
		!push_byte 02
		!push_ebx
		!call >_lua_pcall
		!add_esp_byte 10
		!push_ebx
		!call >IEex_CheckCallError


		!push_byte FF
		!push_ebx
		!call >_lua_tonumber
		!add_esp_byte 08

		!call >__ftol2_sse
		!push_eax

		!push_byte FE
		!push_ebx
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

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_FeatPipsHook"), 4}, [[
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
		!push_byte 01
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua
		!call >IEex_CheckCallError

		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_tonumber
		!add_esp_byte 08

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

		!call >IEex_GetLuaState
		!mov_ebx_eax

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_MeetsFeatRequirementsHook"), 4}, [[
		!push_ebx
		!call >_lua_getglobal
		!add_esp_byte 08

		; sprite ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; featID ;
		!push_ebp
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 01
		!push_byte 02
		!push_ebx
		!call >_lua_pcall
		!add_esp_byte 10
		!push_ebx
		!call >IEex_CheckCallError

		!push_byte FF
		!push_ebx
		!call >_lua_toboolean
		!add_esp_byte 08

		!push_eax

		!push_byte FE
		!push_ebx
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

		!call >IEex_GetLuaState
		!mov_ebx_eax

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_FeatIncrementableHook"), 4}, [[
		!push_ebx
		!call >_lua_getglobal
		!add_esp_byte 08

		; sprite ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; featID ;
		!push_edi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 01
		!push_byte 02
		!push_ebx
		!call >_lua_pcall
		!add_esp_byte 10
		!push_ebx
		!call >IEex_CheckCallError

		!push_byte FF
		!push_ebx
		!call >_lua_toboolean
		!add_esp_byte 08

		!push_eax

		!push_byte FE
		!push_ebx
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

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_FeatPanelStringHook"), 4}, [[
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
		!push_byte 01
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua
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
