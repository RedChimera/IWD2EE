
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

IEex_Helper_InitBridgeFromTable("IEex_Quickloot", {
	["on"] = false,
	["itemsAccessIndex"] = 1,
	["highlightContainerID"] = -1,
	["oldActorX"] = nil,
	["oldActorY"] = nil,
})

function IEex_Quickloot_Start()
	IEex_Helper_SetBridge("IEex_Quickloot", "on", true)
end

function IEex_Quickloot_Stop()
	IEex_Helper_SetBridge("IEex_Quickloot", "on", false)
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

function IEex_Quickloot_UpdateItems(alreadyLocked)

	local doUpdate = function()

		local items = IEex_Helper_GetBridgeCreateNL("IEex_Quickloot", "items")
		IEex_Helper_ClearBridgeNL(items)

		-- Build IEex_Quickloot
		local actorID = IEex_Quickloot_GetValidPartyMember()
		local piles = IEex_GetGroundPilesAroundActor(actorID)

		IEex_Helper_SetBridgeNL("IEex_Quickloot", "defaultContainerID", piles.defaultContainerID)

		for _, pile in ipairs(piles) do
			local maxIndex = IEex_GetContainerIDNumItems(pile.containerID) - 1
			for i = 0, maxIndex, 1 do
				local newEntry = IEex_AppendBridgeTable(items)
				IEex_Helper_SetBridgeNL(newEntry, "containerID", pile.containerID)
				IEex_Helper_SetBridgeNL(newEntry, "slotIndex", i)
			end
		end

		-- If actor moved, force list back to start
		local actorX, actorY = IEex_GetActorLocation(actorID)
		local oldX = IEex_Helper_GetBridgeNL("IEex_Quickloot", "oldActorX")
		local oldY = IEex_Helper_GetBridgeNL("IEex_Quickloot", "oldActorY")

		if actorX ~= oldX or actorY ~= oldY then
			IEex_Helper_SetBridgeNL("IEex_Quickloot", "itemsAccessIndex", 1)
		end

		IEex_Helper_SetBridgeNL("IEex_Quickloot", "oldActorX", actorX)
		IEex_Helper_SetBridgeNL("IEex_Quickloot", "oldActorY", actorY)

		-- Update container highlight on hover

		local highlightContainerID = -1
		local panel = IEex_Quickloot_GetPanel()
		local cursorX, cursorY = IEex_GetCursorXY()

		for i = 0, 9, 1 do
			if IEex_IsPointOverControlID(panel, i, cursorX, cursorY) then
				local overSlotData = IEex_Quickloot_GetSlotData(i, true)
				if not overSlotData.isFallback then
					highlightContainerID = overSlotData.containerID
				end
			end
		end

		IEex_Helper_SetBridgeNL("IEex_Quickloot", "highlightContainerID", highlightContainerID)

	end

	if not alreadyLocked then
		IEex_Helper_SynchronizedBridgeOperation("IEex_Quickloot", doUpdate)
	else
		doUpdate()
	end

	-- Redraw panel
	IEex_Quickloot_InvalidatePanel()
end

function IEex_Quickloot_GetSlotData(controlID, alreadyLocked)

	local slotData = nil

	local getSlotData = function()

		local accessIndex = IEex_Helper_GetBridgeNL("IEex_Quickloot", "itemsAccessIndex") + controlID
		local maxItemIndex = IEex_Helper_GetBridgeNumIntsNL("IEex_Quickloot", "items")

		if accessIndex > maxItemIndex then

			local defaultContainerID = IEex_Helper_GetBridgeNL("IEex_Quickloot", "defaultContainerID")

			if IEex_GetActorShare(defaultContainerID) == 0x0 then
				IEex_Quickloot_UpdateItems(true)
				defaultContainerID = IEex_Helper_GetBridgeNL("IEex_Quickloot", "defaultContainerID")
			end

			slotData = {
				["containerID"] = defaultContainerID,
				["slotIndex"] = IEex_GetContainerIDNumItems(defaultContainerID),
				["isFallback"] = true,
			}
		else
			local entry = IEex_Helper_GetBridgeNL("IEex_Quickloot", "items", accessIndex)
			slotData = {
				["containerID"] = IEex_Helper_GetBridgeNL(entry, "containerID"),
				["slotIndex"] = IEex_Helper_GetBridgeNL(entry, "slotIndex"),
			}
		end
	end

	if not alreadyLocked then
		IEex_Helper_SynchronizedBridgeOperation("IEex_Quickloot", getSlotData)
	else
		getSlotData(IEex_Bridge_LockFunctions)
	end

	return slotData
end

function IEex_Quickloot_GetValidPartyMember()

	local validate = function(actorID)
		if actorID == -1 then return false end
		local share = IEex_GetActorShare(actorID)
		if share == 0x0 then return false end
		local area = IEex_ReadDword(share + 0x12)
		return area ~= 0x0
	end

	local selectedID = IEex_GetActorIDSelected()
	if validate(selectedID) then return selectedID end

	for i = 0, 5, 1 do
		local portraitID = IEex_GetActorIDPortrait(i)
		if validate(portraitID) then return portraitID end
	end
	return -1
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

-------------------
-- GUI Constants --
-------------------

IEex_Once("IEex_GuiConstants", function()

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

end)

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

-------------------------------
-- Quickloot custom controls --
-------------------------------

IEex_Once("IEex_QuicklootCustomControls", function()

	if not IEex_InAsyncState then return end

	-------------------------------
	-- IEex_Quickloot_ScrollLeft --
	-------------------------------

	local IEex_Quickloot_ScrollLeft_OnLButtonClick = IEex_WriteAssemblyAuto({[[

		!push_complete_state

		; control ;
		!push_ecx

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_Quickloot_ScrollLeft"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; control ;
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!pop_complete_state
		!ret_word 08 00

	]]})

	--------------------------------
	-- IEex_Quickloot_ScrollRight --
	--------------------------------

	local IEex_Quickloot_ScrollRight_OnLButtonClick = IEex_WriteAssemblyAuto({[[

		!push_complete_state

		; control ;
		!push_ecx

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_Quickloot_ScrollRight"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; control ;
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!pop_complete_state
		!ret_word 08 00

	]]})

	IEex_DefineCustomButtonControl("IEex_Quickloot_ScrollLeft", {
		["OnLButtonClick"] = IEex_Quickloot_ScrollLeft_OnLButtonClick,
		["OnLButtonDoubleClick"] = 0x4D4D70, -- CUIControlButton_OnLButtonDown; prevents double-click cooldown.
	})

	IEex_DefineCustomButtonControl("IEex_Quickloot_ScrollRight", {
		["OnLButtonClick"] = IEex_Quickloot_ScrollRight_OnLButtonClick,
		["OnLButtonDoubleClick"] = 0x4D4D70, -- CUIControlButton_OnLButtonDown; prevents double-click cooldown.
	})

	IEex_AddControlOverride("GUIW08", 23, 10, IEex_ControlType.IEex_Quickloot_ScrollLeft)
	IEex_AddControlOverride("GUIW10", 23, 10, IEex_ControlType.IEex_Quickloot_ScrollLeft)
	IEex_AddControlOverride("GUIW08", 23, 11, IEex_ControlType.IEex_Quickloot_ScrollRight)
	IEex_AddControlOverride("GUIW10", 23, 11, IEex_ControlType.IEex_Quickloot_ScrollRight)

end)

------------------------
-- GUI Hook Functions --
------------------------

------------------
-- Thread: Both --
------------------

function IEex_Extern_GetHighlightContainerID()
	IEex_AssertThread(IEex_Thread.Both, true)
	return IEex_Helper_GetBridge("IEex_Quickloot", "highlightContainerID")
end

-------------------
-- Thread: Async --
-------------------

function IEex_Extern_CUIControlBase_CreateControl(resrefPointer, panel, controlInfo)

	IEex_AssertThread(IEex_Thread.Async, true)

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

function IEex_Extern_CUIManager_fInit_CHUInitialized(CUIManager, resrefPointer)

	IEex_AssertThread(IEex_Thread.Async, true)
	local resref = IEex_ReadLString(resrefPointer, 8)

	local resrefOverride = IEex_PanelActiveByDefault[resref]
	if not resrefOverride then return end

	for panelID, active in pairs(resrefOverride) do
		local panel = IEex_GetPanel(CUIManager, panelID)
		IEex_SetPanelActive(panel, active)
	end
end

function IEex_Extern_CScreenWorld_AsynchronousUpdate()

	IEex_AssertThread(IEex_Thread.Async, true)

	if IEex_Helper_GetBridge("IEex_Quickloot", "on") then

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

function IEex_Extern_Quickloot_ScrollLeft()
	IEex_AssertThread(IEex_Thread.Async, true)
	local itemsAccessIndex = IEex_Helper_GetBridge("IEex_Quickloot", "itemsAccessIndex")
	IEex_Helper_SetBridge("IEex_Quickloot", "itemsAccessIndex", math.max(1, itemsAccessIndex - 10))
end

function IEex_Extern_Quickloot_ScrollRight()
	IEex_AssertThread(IEex_Thread.Async, true)
	local itemsAccessIndex = IEex_Helper_GetBridge("IEex_Quickloot", "itemsAccessIndex")
	local maxIndex = math.max(1, IEex_Helper_GetBridgeNumInts("IEex_Quickloot", "items") - 10 + 1)
	IEex_Helper_SetBridge("IEex_Quickloot", "itemsAccessIndex", math.min(itemsAccessIndex + 10, maxIndex))
end

function IEex_Extern_CScreenWorld_OnInventoryButtonRClick()
	IEex_AssertThread(IEex_Thread.Async, true)
	if IEex_Helper_GetBridge("IEex_Quickloot", "on") then
		IEex_Quickloot_Stop()
	else
		IEex_Quickloot_Start()
	end
end

function IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_Done(control)
	IEex_AssertThread(IEex_Thread.Async, true)
	local itemsAccessIndex = IEex_Helper_GetBridge("IEex_Quickloot", "itemsAccessIndex")
	local maxIndex = math.max(1, IEex_Helper_GetBridgeNumInts("IEex_Quickloot", "items") - 10)
	IEex_Helper_SetBridge("IEex_Quickloot", "itemsAccessIndex", math.min(itemsAccessIndex, maxIndex))
	IEex_Quickloot_InvalidatePanel()
end

function IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot(control)
	IEex_AssertThread(IEex_Thread.Async, true)
	return IEex_Quickloot_IsControlOnPanel(control)
end

------------------
-- Thread: Both --
------------------

-- (Render->Sync, OnLClick->Async)
function IEex_Extern_CUIControlButtonWorldContainerSlot_GetActiveContainerID(control)
	IEex_AssertThread(IEex_Thread.Both, true)
	if IEex_Quickloot_IsControlOnPanel(control) then
		return IEex_Quickloot_GetSlotData(IEex_GetControlID(control)).containerID
	else
		return -1
	end
end

-- (Render->Sync, OnLClick->Async)
function IEex_Extern_CUIControlButtonWorldContainerSlot_GetActiveContainerSpriteID(control)
	IEex_AssertThread(IEex_Thread.Both, true)
	if IEex_Quickloot_IsControlOnPanel(control) then
		return IEex_Quickloot_GetValidPartyMember()
	else
		return -1
	end
end

-- (Render->Sync, OnLClick->Async)
function IEex_Extern_CUIControlButtonWorldContainerSlot_GetContainerItemIndex(control)
	IEex_AssertThread(IEex_Thread.Both, true)
	if IEex_Quickloot_IsControlOnPanel(control) then
		return IEex_Quickloot_GetSlotData(IEex_GetControlID(control)).slotIndex
	else
		return -1
	end
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
