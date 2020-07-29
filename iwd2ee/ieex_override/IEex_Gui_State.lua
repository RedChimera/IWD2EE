
---------------
-- Functions --
---------------

function IEex_GetCursorXY()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local x = IEex_ReadDword(g_pBaldurChitin + 0x1906)
	local y = IEex_ReadDword(g_pBaldurChitin + 0x190A)
	return x, y
end

function IEex_SetViewportBottom(bottom)
	IEex_WriteDword(IEex_GetCInfinity() + 0x48 + 0xC, bottom)
end

function IEex_ResetViewport()
	local panel = IEex_GetPanelFromEngine(IEex_GetEngineWorld(), 1)
	local _, y, _, _ = IEex_GetPanelArea(panel)
	IEex_SetViewportBottom(y)
end

function IEex_PanelInvalidateRect(CUIPanel, left, top, right, bottom)
	local rect = IEex_Malloc(0x10)
	IEex_WriteDword(rect + 0x0, left)
	IEex_WriteDword(rect + 0x4, top)
	IEex_WriteDword(rect + 0x8, right)
	IEex_WriteDword(rect + 0xC, bottom)
	IEex_Call(0x4D3810, {rect}, CUIPanel, 0x0)
	IEex_Free(rect)
end

function IEex_PanelInvalidate(CUIPanel)
	IEex_Call(0x4D3810, {0x0}, CUIPanel, 0x0)
end

function IEex_GetPanelArea(CUIPanel)
	local x = IEex_ReadDword(CUIPanel + 0x24)
	local y = IEex_ReadDword(CUIPanel + 0x28)
	local w = IEex_ReadDword(CUIPanel + 0x34)
	local h = IEex_ReadDword(CUIPanel + 0x38)
	return x, y, w, h
end

function IEex_GetPanel(CUIManager, panelID)
	return IEex_Call(0x4D4000, {panelID}, CUIManager, 0x0)
end

function IEex_GetPanelID(CUIPanel)
	return IEex_ReadDword(CUIPanel + 0x20)
end

function IEex_GetUIManagerFromEngine(CBaldurEngine)
	return CBaldurEngine + 0x30
end

function IEex_GetPanelFromEngine(CBaldurEngine, panelID)
	return IEex_GetPanel(IEex_GetUIManagerFromEngine(CBaldurEngine), panelID)
end

function IEex_IsPanelActive(CUIPanel)
	return IEex_ReadDword(CUIPanel + 0xF4) == 1
end

function IEex_SetPanelActive(CUIPanel, active)
	IEex_Call(0x4D3980, {active and 1 or 0}, CUIPanel, 0x0)
end

function IEex_GetControlFromPanel(CUIPanel, controlID)
	local foundControl = 0x0
	IEex_IterateCPtrList(CUIPanel + 0x4, function(CUIControl)
		if IEex_GetControlID(CUIControl) == controlID then
			foundControl = CUIControl
			return true
		end
	end)
	return foundControl
end

function IEex_GetControlPanel(CUIControl)
	return IEex_ReadDword(CUIControl + 0x6)
end

function IEex_GetControlArea(CUIControl)
	local x = IEex_ReadDword(CUIControl + 0xE)
	local y = IEex_ReadDword(CUIControl + 0x12)
	local w = IEex_ReadDword(CUIControl + 0x16)
	local h = IEex_ReadDword(CUIControl + 0x1A)
	return x, y, w, h
end

function IEex_GetControlAreaAbsolute(CUIControl)
	local panelX, panelY, _, _ = IEex_GetPanelArea(IEex_GetControlPanel(CUIControl))
	local controlX, controlY, controlW, controlH = IEex_GetControlArea(CUIControl)
	return panelX + controlX, panelY + controlY, controlW, controlH
end

function IEex_IsControlOnPanel(CUIControl, CUIPanel)
	return IEex_GetControlPanel(CUIControl) == CUIPanel
end

function IEex_IsPointOverControl(CUIControl, x, y)
	local controlX, controlY, controlW, controlH = IEex_GetControlAreaAbsolute(CUIControl)
	return x >= controlX and x <= (controlX + controlW) and y >= controlY and y <= (controlY + controlH)
end

function IEex_IsPointOverControlID(CUIPanel, controlID, x, y)
	return IEex_IsPointOverControl(IEex_GetControlFromPanel(CUIPanel, controlID), x, y)
end

function IEex_GetControlID(CUIControl)
	return IEex_ReadDword(CUIControl + 0xA)
end

function IEex_GetContainerType(CGameContainer)
	return IEex_ReadWord(CGameContainer + 0x5CA, 0)
end

function IEex_GetContainerIDType(containerID)
	local share = IEex_GetActorShare(containerID)
	local toReturn = IEex_GetContainerType(share)
	IEex_UndoActorShare(containerID)
	return toReturn
end

function IEex_GetContainerNumItems(CGameContainer)
	return IEex_ReadDword(CGameContainer + 0x5AE + 0xC)
end

function IEex_GetContainerIDNumItems(containerID)
	local share = IEex_GetActorShare(containerID)
	local toReturn = IEex_GetContainerNumItems(share)
	IEex_UndoActorShare(containerID)
	return toReturn
end

function IEex_GetGroundPilesAroundActor(actorID)

	local toReturn = {}

	local share = IEex_GetActorShare(actorID)
	if share == 0x0 then return toReturn end
	local area = IEex_ReadDword(share + 0x12)
	if area == 0x0 then return toReturn end

	local actorX, actorY = IEex_GetActorLocation(actorID)
	local m_lVertSortBack = area + 0x9AE

	local defaultContainerID = -1

	IEex_IterateCPtrList(m_lVertSortBack, function(containerID)

		local containerShare = IEex_GetActorShare(containerID)
		if containerShare == 0x0 then return end
		if IEex_ReadByte(containerShare + 0x4, 0) ~= 0x11 then return end

		defaultContainerID = containerID

		if IEex_GetContainerType(containerShare) ~= 4 then return end -- Only ground piles
		if not IEex_CheckActorLOSObject(actorID, containerID) then return end
		if IEex_GetContainerNumItems(containerShare) <= 0 then return end

		local containerX, containerY = IEex_GetActorLocation(containerID)
		local distance = IEex_GetDistanceIsometric(actorX, actorY, containerX, containerY)
		table.insert(toReturn, {["containerID"] = containerID, ["distance"] = distance})

		IEex_UndoActorShare(containerID)
	end)

	table.sort(toReturn, function(a, b)
		return a.distance < b.distance
	end)

	if defaultContainerID == -1 then
		defaultContainerID = IEex_Call(0x5B75C0, {actorID}, IEex_GetGameData(), 0x0)
	end

	toReturn.defaultContainerID = defaultContainerID
	return toReturn
end

-------------------------
-- Quickloot Functions --
-------------------------

-- Thread: Shared
IEex_DefineBridge("IEex_Bridge_Quickloot_On", 0)
IEex_DefineBridge("IEex_Bridge_Quickloot_HighlightContainerID", -1)
IEex_DefineStringBridge("IEex_Bridge_Quickloot_SimpleAsyncOrder", "")

-- Thread: Synchronous
IEex_Quickloot_Items = {}
IEex_Quickloot_ItemsAccessIndex = 1
IEex_Quickloot_DefaultContainerID = -1
IEex_Quickloot_OldActorX = -1
IEex_Quickloot_OldActorY = -1

function IEex_Quickloot_Start()
	IEex_SetBridge("IEex_Bridge_Quickloot_On", 1)
end

function IEex_Quickloot_Stop()
	IEex_SetBridge("IEex_Bridge_Quickloot_On", 0)
	IEex_Quickloot_Hide()
end

function IEex_Quickloot_Show()
	IEex_Quickloot_UpdateItems()
	local panel = IEex_Quickloot_GetPanel()
	IEex_SetPanelActive(panel, true)
	local _, y, _, _ = IEex_GetPanelArea(panel)
	IEex_SetViewportBottom(y)
end

function IEex_Quickloot_Hide(changeViewport)
	local panel = IEex_Quickloot_GetPanel()
	IEex_SetPanelActive(panel, false)
	if changeViewport or changeViewport == nil then
		local _, y, _, h = IEex_GetPanelArea(panel)
		IEex_SetViewportBottom(y + h)
	end
end

function IEex_Quickloot_UpdateItems()

	-- Build IEex_Quickloot_Items
	local actorID = IEex_Quickloot_GetValidPartyMember()
	local piles = IEex_GetGroundPilesAroundActor(actorID)

	IEex_Quickloot_Items = {}
	IEex_Quickloot_DefaultContainerID = piles.defaultContainerID

	for _, pile in ipairs(piles) do
		local maxIndex = IEex_GetContainerIDNumItems(pile.containerID) - 1
		for i = 0, maxIndex, 1 do
			table.insert(IEex_Quickloot_Items, {["containerID"] = pile.containerID, ["slotIndex"] = i})
		end
	end

	-- If actor moved, force list back to start
	local actorX, actorY = IEex_GetActorLocation(actorID)

	if actorX ~= IEex_Quickloot_OldActorX or IEex_Quickloot_OldActorY ~= actorY then
		IEex_Quickloot_ItemsAccessIndex = 1
	end

	IEex_Quickloot_OldActorX = actorX
	IEex_Quickloot_OldActorY = actorY

	-- Update container highlight on hover

	local highlightContainerID = -1
	local panel = IEex_Quickloot_GetPanel()
	local cursorX, cursorY = IEex_GetCursorXY()

	for i = 0, 9, 1 do
		if IEex_IsPointOverControlID(panel, i, cursorX, cursorY) then
			local overSlotData = IEex_Quickloot_GetSlotData(i)
			if not overSlotData.isFallback then
				highlightContainerID = overSlotData.containerID
			end
		end
	end

	IEex_SetBridge("IEex_Bridge_Quickloot_HighlightContainerID", highlightContainerID)

	-- Redraw panel
	IEex_Quickloot_InvalidatePanel()
end

function IEex_Quickloot_GetSlotData(controlID)

	local slotData = IEex_Quickloot_Items[IEex_Quickloot_ItemsAccessIndex + controlID]

	if not slotData then
		-- Empty quickloot slots will request slot data on main-area transitions.
		-- IEex_Quickloot_DefaultContainerID will still be pointing to a container
		-- in the old area, causing a crash. If we detect an invalid default container,
		-- force a IEex_Quickloot_UpdateItems() call to get quickloot in sync with the
		-- new area.
		if IEex_GetActorShare(IEex_Quickloot_DefaultContainerID) == 0x0 then
			IEex_Quickloot_UpdateItems()
		end

		slotData = {
			["containerID"] = IEex_Quickloot_DefaultContainerID,
			["slotIndex"] = IEex_GetContainerIDNumItems(IEex_Quickloot_DefaultContainerID),
			["isFallback"] = true,
		}
	end

	return slotData
end

function IEex_Quickloot_GetValidPartyMember()
	local actorID = IEex_GetActorIDSelected()
	if actorID == -1 then
		for i = 0, 5, 1 do
			actorID = IEex_GetActorIDPortrait(i)
			if IEex_IsSprite(actorID) then break end
		end
	end
	return actorID
end

function IEex_Quickloot_GetPanel()
	return IEex_GetPanelFromEngine(IEex_GetEngineWorld(), 23)
end

function IEex_Quickloot_InvalidatePanel()
	IEex_PanelInvalidate(IEex_Quickloot_GetPanel())
end

function IEex_Quickloot_IsPanelActive()
	return IEex_IsPanelActive(IEex_Quickloot_GetPanel())
end

function IEex_Quickloot_IsControlOnPanel(control)
	return IEex_IsControlOnPanel(control, IEex_Quickloot_GetPanel())
end

function IEex_Quickloot_ScrollLeft()
	IEex_Quickloot_ItemsAccessIndex = math.max(1, IEex_Quickloot_ItemsAccessIndex - 10)
end

function IEex_Quickloot_ScrollRight()
	local maxIndex = math.max(1, #IEex_Quickloot_Items - 10 + 1)
	IEex_Quickloot_ItemsAccessIndex = math.min(IEex_Quickloot_ItemsAccessIndex + 10, maxIndex)
end

-------------------
-- GUI Constants --
-------------------

IEex_PanelActiveByDefault = {
	["GUIW08"] = {
		[23] = false,
	},
	["GUIW10"] = {
		[23] = false,
	},
}

IEex_ControlTypeMaxIndex = 0
IEex_ControlType = {
	["ButtonWorldContainerSlot"] = 0,
}

IEex_ControlTypeMeta = {
	[IEex_ControlType.ButtonWorldContainerSlot] = { ["constructor"] = 0x6956F0, ["size"] = 0x666 },
}

IEex_ControlOverrides = {
	["GUIW08"] = {
		[23] = {
			[0] = IEex_ControlType.ButtonWorldContainerSlot,
			[1] = IEex_ControlType.ButtonWorldContainerSlot,
			[2] = IEex_ControlType.ButtonWorldContainerSlot,
			[3] = IEex_ControlType.ButtonWorldContainerSlot,
			[4] = IEex_ControlType.ButtonWorldContainerSlot,
			[5] = IEex_ControlType.ButtonWorldContainerSlot,
			[6] = IEex_ControlType.ButtonWorldContainerSlot,
			[7] = IEex_ControlType.ButtonWorldContainerSlot,
			[8] = IEex_ControlType.ButtonWorldContainerSlot,
			[9] = IEex_ControlType.ButtonWorldContainerSlot,
		},
	},
	["GUIW10"] = {
		[23] = {
			[0] = IEex_ControlType.ButtonWorldContainerSlot,
			[1] = IEex_ControlType.ButtonWorldContainerSlot,
			[2] = IEex_ControlType.ButtonWorldContainerSlot,
			[3] = IEex_ControlType.ButtonWorldContainerSlot,
			[4] = IEex_ControlType.ButtonWorldContainerSlot,
			[5] = IEex_ControlType.ButtonWorldContainerSlot,
			[6] = IEex_ControlType.ButtonWorldContainerSlot,
			[7] = IEex_ControlType.ButtonWorldContainerSlot,
			[8] = IEex_ControlType.ButtonWorldContainerSlot,
			[9] = IEex_ControlType.ButtonWorldContainerSlot,
		},
	},
}

-- The following functions / definitions are just enough for simple on-click buttons.

function IEex_AddControlOverride(resref, panelID, controlID, controlType)

	local resrefOverride = IEex_ControlOverrides[resref]
	if not resrefOverride then
		resrefOverride = {}
		IEex_ControlOverrides[resref] = resrefOverride
	end

	panelOverride = resrefOverride[panelID]
	if not panelOverride then
		panelOverride = {}
		IEex_ControlOverrides[panelID] = panelOverride
	end

	panelOverride[controlID] = controlType
end

function IEex_DefineCustomButtonControl(controlName, args)

	-- Fill defaults
	local newButtonVFTable = IEex_Malloc(0x78)
	local currentFillAddress = newButtonVFTable
	for i = 0x84C984, 0x84C9F8, 0x4 do
		IEex_WriteDword(currentFillAddress, IEex_ReadDword(i))
		currentFillAddress = currentFillAddress + 0x4
	end

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
		["NOTHING"] = 2,
	}

	local writeArgs = function(address, writeDefs)
		for _, writeDef in ipairs(writeDefs) do
			local argKey = writeDef[1]
			local arg = args[argKey]
			local skipWrite = false
			if not arg then
				local failType = writeDef[4]
				if failType == argFailType.DEFAULT then
					arg = writeDef[5]
				elseif failType == argFailType.ERROR then
					IEex_Error(argKey.." must be defined!")
				else
					skipWrite = true
				end
			end
			if not skipWrite then
				writeTypeFunc[writeDef[3]](address + writeDef[2], arg)
			end
		end
	end

	writeArgs(newButtonVFTable, {
		{ "OnLButtonClick", 0x68, writeType.DWORD, argFailType.NOTHING },
		{ "OnLButtonDoubleClick", 0x6C, writeType.DWORD, argFailType.NOTHING },
	})

	IEex_ControlTypeMaxIndex = IEex_ControlTypeMaxIndex + 1
	IEex_ControlType[controlName] = IEex_ControlTypeMaxIndex

	local newConstructor = IEex_WriteAssemblyAuto({[[

		!push_esi
		!mov_esi_ecx

		!push_byte 01
		!push_byte 01
		!push_[esp+byte] 14
		!push_[esp+byte] 14
		!mov_ecx_esi
		!call :4D47D0

		!mov_[esi]_dword ]], {newButtonVFTable, 4}, [[
		!mov_eax_esi
		!pop_esi

		!ret_word 08 00
	]]})

	IEex_ControlTypeMeta[IEex_ControlTypeMaxIndex] = {
		["constructor"] = newConstructor,
		["size"] = 0x666,
	}
end

------------------------
-- GUI Hook Functions --
------------------------

-- Helpful comment: The following function names are too long.

-- Thread: Synchronous
function IEex_Extern_CUIControlBase_CreateControl(resrefPointer, panel, controlInfo)

	local resref = IEex_ReadLString(resrefPointer, 8)
	local panelID = IEex_ReadDword(panel + 0x20)
	local controlID = IEex_ReadDword(controlInfo)

	local resrefOverride = IEex_ControlOverrides[resref]
	if not resrefOverride then return 0x0 end

	panelOverride = resrefOverride[panelID]
	if not panelOverride then return 0x0 end

	local controlOverride = panelOverride[controlID]
	if not controlOverride then return 0x0 end

	local controlMeta = IEex_ControlTypeMeta[controlOverride]

	if not controlMeta then
		IEex_TracebackMessage("IEex Critical Error - No metadata defined for IEex_ControlType "..controlOverride)
		return 0x0
	end

	local control = IEex_Malloc(controlMeta.size)
	IEex_Call(controlMeta.constructor, {controlInfo, panel}, control, 0x0)

	return control
end

-- Thread: Synchronous
function IEex_Extern_CUIManager_fInit_CHUInitialized(CUIManager, resrefPointer)

	local resref = IEex_ReadLString(resrefPointer, 8)

	local resrefOverride = IEex_PanelActiveByDefault[resref]
	if not resrefOverride then return end

	for panelID, active in pairs(resrefOverride) do
		local panel = IEex_GetPanel(CUIManager, panelID)
		IEex_SetPanelActive(panel, active)
	end
end

-- Thread: Synchronous
function IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetActiveContainerID(control)
	if IEex_Quickloot_IsControlOnPanel(control) then
		return IEex_Quickloot_GetSlotData(IEex_GetControlID(control)).containerID
	else
		return -1
	end
end

-- Thread: Synchronous
function IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetActiveContainerSpriteID(control)
	if IEex_Quickloot_IsControlOnPanel(control) then
		return IEex_Quickloot_GetValidPartyMember()
	else
		return -1
	end
end

-- Thread: Synchronous
function IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetContainerItemIndex(control)
	if IEex_Quickloot_IsControlOnPanel(control) then
		return IEex_Quickloot_GetSlotData(IEex_GetControlID(control)).slotIndex
	else
		return -1
	end
end

-- Thread: Synchronous
function IEex_Extern_Sync_CUIControlButtonWorldContainerSlot_OnLButtonClick_Done()
	local maxIndex = math.max(1, #IEex_Quickloot_Items - 10)
	IEex_Quickloot_ItemsAccessIndex = math.min(IEex_Quickloot_ItemsAccessIndex, maxIndex)
	IEex_Quickloot_InvalidatePanel()
end

-- Thread: Synchronous
function IEex_Extern_CScreenWorld_TimerSynchronousUpdate()

	if IEex_GetBridge("IEex_Bridge_Quickloot_On") == 1 then

		local asyncOrder = IEex_GetStringBridge("IEex_Bridge_Quickloot_SimpleAsyncOrder")
		if asyncOrder ~= "" then
			IEex_SetStringBridge("IEex_Bridge_Quickloot_SimpleAsyncOrder", "")
			_G[asyncOrder]()
		end

		local worldScreen = IEex_GetEngineWorld()
		local panelActive = IEex_Quickloot_IsPanelActive()

		-- Need to hide if dialog / container is present
		if panelActive and (
			   IEex_IsPanelActive(IEex_GetPanelFromEngine(worldScreen, 7))
			or IEex_IsPanelActive(IEex_GetPanelFromEngine(worldScreen, 8)))
		then
			IEex_Quickloot_Hide(false)
		elseif IEex_IsPanelActive(IEex_GetPanelFromEngine(worldScreen, 1)) then
			-- This calls IEex_Quickloot_UpdateItems() internally.
			-- It's a little ineffecient to call this every tick,
			-- but this is the only way I've found to maintain state
			-- correctly when dialog / opening containers screws around
			-- with the viewport.
			IEex_Quickloot_Show()
		end

	end
end

-- Thread: Asynchronous
function IEex_Extern_CScreenWorld_OnInventoryButtonRClick()
	if IEex_GetBridge("IEex_Bridge_Quickloot_On") == 1 then
		IEex_Quickloot_Stop()
	else
		IEex_Quickloot_Start()
	end
end

-- Thread: Asynchronous
function IEex_Extern_Async_CUIControlButtonWorldContainerSlot_OnLButtonClick_Done(control)
	IEex_SetStringBridge("IEex_Bridge_Quickloot_SimpleAsyncOrder", "IEex_Extern_Sync_CUIControlButtonWorldContainerSlot_OnLButtonClick_Done")
end

-- Thread: Asynchronous
function IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot(control)
	return IEex_Quickloot_IsControlOnPanel(control)
end

-- Thread: Asynchronous
function IEex_Extern_Async_Quickloot_ScrollLeft(control)
	IEex_SetStringBridge("IEex_Bridge_Quickloot_SimpleAsyncOrder", "IEex_Quickloot_ScrollLeft")
end

-- Thread: Asynchronous
function IEex_Extern_Async_Quickloot_ScrollRight(control)
	IEex_SetStringBridge("IEex_Bridge_Quickloot_SimpleAsyncOrder", "IEex_Quickloot_ScrollRight")
end

---------
-- Dev --
---------

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
						local controlID = IEex_ReadWord(controlInfo, 0)

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
