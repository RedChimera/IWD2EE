
function IEex_Dev_DumpEngineVFTables()

	local engineToVFTable = {
		{ "CScreenChapter",     0x8519C4 }, -- 0x5D2EF2
		{ "CScreenCharacter",   0x851CB8 }, -- 0x5D5242
		{ "CScreenConnection",  0x852EBC }, -- 0x5F9BD2
		{ "CScreenCreateChar",  0x853B58 }, -- 0x605C62
		{ "CScreenInventory",   0x85513C }, -- 0x623EC2
		{ "CScreenJournal",     0x855B64 }, -- 0x635442
		{ "CScreenKeys",        0x855D70 }, -- 0x638102
		{ "CScreenLoad",        0x855F08 }, -- 0x63AFA2
		{ "CScreenMap",         0x85638C }, -- 0x63F982
		{ "CScreenMovies",      0x856968 }, -- 0x646A62
		{ "CScreenMultiPlayer", 0x856C68 }, -- 0x6481E2
		{ "CScreenOptions",     0x857938 }, -- 0x653102
		{ "CScreenSave",        0x857DA8 }, -- 0x659B32
		{ "CScreenSelectParty", 0x858390 }, -- 0x65FAE2
		{ "CScreenSpell",       0x858CB0 }, -- 0x667EE2
		{ "CScreenStart",       0x851750 }, -- 0x5995BD
		{ "CScreenStore",       0x859374 }, -- 0x670A02
		{ "CScreenWorld",       0x85A250 }, -- 0x685632
		{ "CScreenWorldMap",    0x85A768 }, -- 0x698882
		{ "Unknown1",           0x848270 }, -- 0x43E662
		{ "Unknown3",           0x859124 }, -- 0x66F0E2
	}

	local offsetBuckets = {}
	local insertI = 1

	for offset = 0, 0x118, 0x4 do

		local funcMap = {}
		local offsetBucket = { offset, funcMap }

		for _, engineEntry in ipairs(engineToVFTable) do
			local funcAddress = IEex_ReadDword(engineEntry[2] + offset)
			local funcEntries = IEex_GetOrCreate(funcMap, funcAddress, {})
			table.insert(funcEntries, engineEntry)
		end

		offsetBuckets[insertI] = offsetBucket
		insertI = insertI + 1
	end

	for _, offsetBucket in ipairs(offsetBuckets) do
		IEex_PrettyPrintHeader(IEex_ToHex(offsetBucket[1]))
		IEex_IterateMapAsSorted(offsetBucket[2],
			function(a, b) return a[1] < b[1] end,
			function(_, k, v)
				IEex_PrettyPrintHeader("["..IEex_ToHex(k).."]", "    ")
				for _, v2 in ipairs(v) do
					print(string.format("        %s [%s+%s]", v2[1], IEex_ToHex(v2[2]), IEex_ToHex(offsetBucket[1])))
				end
			end)
	end
end

function IEex_Dev_DumpControlVFTables()

	local assertTripped = IEex_Malloc(0x4)
	IEex_WriteDword(assertTripped, 0x0)

	IEex_DisableCodeProtection()
	IEex_WriteAssembly(0x780C00, {[[
		!mov_[dword]_dword ]], {assertTripped, 4}, [[ #1
		!ret
	]]})
	IEex_EnableCodeProtection()

	local CUIManager = IEex_Malloc(0xCA)
	IEex_Call(0x4D39B0, {}, CUIManager, 0x0)

	local causesCrash = {
		["GUIW"] = {
			[0] = {
				[2] = true,
			},
			[7] = {
				[2] = true,
			},
			[8] = {
				[52] = true,
				[53] = true,
			},
			[19] = {
				[2] = true,
				[4] = true,
			},
			[21] = {
				[2] = true,
			},
			[22] = {
				[2] = true,
			},
		},
		["WORLD"]  = {["malformed"] = true},
	}

	local willCauseCrash = function(resref, panelID, controlID)
		local resrefTable = causesCrash[resref]
		if not resrefTable then return false end
		if resrefTable.malformed then return true end
		local panelTable = resrefTable[panelID]
		if not panelTable then return false end
		local controlVal = panelTable[controlID]
		if controlVal == nil then return false end
		return controlVal
	end

	for i, resref in ipairs(IEex_IndexedResources[IEex_FileExtensionToType("CHU")]) do

		if not willCauseCrash(resref, nil, nil) then

			IEex_WriteLString(CUIManager + 0x8, resref, 8)

			local resWrapper = IEex_DemandRes(resref, "CHU")
			if resWrapper:isValid() then

				local CResUI = resWrapper:getRes()

				-- CResUI_GetPanelNo
				local numPanels = IEex_Call(0x4014A0, {}, CResUI, 0x0)
				local panelLimit = numPanels - 1

				for panelIndex = 0, panelLimit, 1 do

					-- CResUI_GetPanel
					local panelInfo = IEex_Call(0x401460, {panelIndex}, CResUI, 0x0)
					local CUIPanel = IEex_Malloc(0x12A)

					-- CUIPanel_Construct
					IEex_Call(0x4D2750, {panelInfo, CUIManager}, CUIPanel, 0x0)
					local panelID = IEex_GetPanelID(CUIPanel)

					-- CResUI_GetControlNo
					local numControls = IEex_Call(0x401520, {panelIndex}, CResUI, 0x0)
					local controlLimit = numControls - 1

					for controlIndex = 0, controlLimit, 1 do

						-- CResUI_GetControl
						local controlInfo = IEex_Call(0x4014C0, {controlIndex, panelIndex}, CResUI, 0x0)
						local controlID = IEex_ReadWord(controlInfo)

						if not willCauseCrash(resref, panelID, controlID) then

							-- CUIControlBase_CreateControl
							local CUIControl = IEex_Call(0x76D370, {controlInfo, CUIPanel}, nil, 0x8)

							if IEex_ReadDword(assertTripped) == 1 then
								IEex_WriteDword(assertTripped, 0x0)
								print(resref.."->"..panelID.."->"..controlID.." - Assert tripped")
							elseif CUIControl == 0x0 then
								print(resref.."->"..panelID.."->"..controlID.." - Undefined")
							else
								print(resref.."->"..panelID.."->"..controlID.." - "..IEex_ToHex(IEex_ReadDword(CUIControl)))
							end
						else
							print(resref.."->"..panelID.."->"..controlID.." - Crash")
						end
					end
				end
			end

			resWrapper:free()

		else
			print(resref.." - Malformed")
		end
	end

	IEex_DisableCodeProtection()
	IEex_WriteAssembly(0x780C00, {[[
		!mov_eax_[esp+byte] 08
		!sub_esp_dword #400
		!push_ebx
	]]})
	IEex_EnableCodeProtection()

	IEex_Free(assertTripped)
end

function IEex_Dev_SpamStateIcons()

	local sprite = IEex_GetActorShare(IEex_GetActorIDSelected())
	if sprite == 0x0 then return end

	IEex_ApplyEffectToSprite(sprite, {
		["opcode"] = 500,
		["timing"] = 1,
		["resource"] = "B3STSPAM",
	})
end

function B3STSPAM(effectData, creatureData)
	for i = 0, 19 do
		IEex_Call(0x7FBE4E, {i}, creatureData + 0x7130, 0x0) -- CPtrList_AddTail()
	end
end
