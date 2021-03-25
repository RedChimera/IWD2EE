
---------------
-- Functions --
---------------

function IEex_WritePrivateProfileString(lpAppName, lpKeyName, lpString, lpFileName)
	IEex_RunWithStackManager({
		{["name"] = "lpAppName",  ["struct"] = "string", ["constructor"] = {["luaArgs"] = {lpAppName}  }},
		{["name"] = "lpKeyName",  ["struct"] = "string", ["constructor"] = {["luaArgs"] = {lpKeyName}  }},
		{["name"] = "lpString",   ["struct"] = "string", ["constructor"] = {["luaArgs"] = {lpString}   }},
		{["name"] = "lpFileName", ["struct"] = "string", ["constructor"] = {["luaArgs"] = {lpFileName} }}, },
		function(manager)
			IEex_Call(IEex_ReadDword(0x847308), {
				manager:getAddress("lpFileName"),
				manager:getAddress("lpString"),
				manager:getAddress("lpKeyName"),
				manager:getAddress("lpAppName"),
			})
		end)
end

function IEex_WritePrivateProfileInt(lpAppName, lpKeyName, nInt, lpFileName)
	IEex_WritePrivateProfileString(lpAppName, lpKeyName, tostring(nInt), lpFileName)
end

function IEex_GetPrivateProfileString(lpAppName, lpKeyName, lpDefault, lpFileName)
	local toReturn
	IEex_RunWithStackManager({
		{["name"] = "lpAppName",        ["struct"] = "string",        ["constructor"] = {["luaArgs"] = {lpAppName}  }},
		{["name"] = "lpKeyName",        ["struct"] = "string",        ["constructor"] = {["luaArgs"] = {lpKeyName}  }},
		{["name"] = "lpDefault",        ["struct"] = "string",        ["constructor"] = {["luaArgs"] = {lpDefault}  }},
		{["name"] = "lpReturnedString", ["struct"] = "uninitialized", ["constructor"] = {["luaArgs"] = {0x1000}     }},
		{["name"] = "lpFileName",       ["struct"] = "string",        ["constructor"] = {["luaArgs"] = {lpFileName} }}, },
		function(manager)
			local returnedString = manager:getAddress("lpReturnedString")
			IEex_Call(IEex_ReadDword(0x84730C), {
				manager:getAddress("lpFileName"),
				0x1000,
				returnedString,
				manager:getAddress("lpDefault"),
				manager:getAddress("lpKeyName"),
				manager:getAddress("lpAppName"),
			})
			toReturn = IEex_ReadString(returnedString)
		end)
	return toReturn
end

function IEex_GetPrivateProfileInt(lpAppName, lpKeyName, nDefault, lpFileName)
	local toReturn
	IEex_RunWithStackManager({
		{["name"] = "lpAppName",  ["struct"] = "string", ["constructor"] = {["luaArgs"] = {lpAppName}  }},
		{["name"] = "lpKeyName",  ["struct"] = "string", ["constructor"] = {["luaArgs"] = {lpKeyName}  }},
		{["name"] = "lpFileName", ["struct"] = "string", ["constructor"] = {["luaArgs"] = {lpFileName} }}, },
		function(manager)
			toReturn = IEex_Call(IEex_ReadDword(0x847310), {
				manager:getAddress("lpFileName"),
				nDefault,
				manager:getAddress("lpKeyName"),
				manager:getAddress("lpAppName"),
			})
		end)
	return toReturn
end

function IEex_GetResolution()
	return IEex_ReadWord(0x8BA31C, 0), IEex_ReadWord(0x8BA31E, 0)
end

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

function IEex_GetUIManagerFromPanel(CUIPanel)
	return IEex_ReadDword(CUIPanel)
end

function IEex_GetCHUResrefFromPanel(CUIPanel)
	return IEex_ReadLString(IEex_GetUIManagerFromPanel(CUIPanel) + 0x8, 8)
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

function IEex_SetPanelEnabled(CUIPanel, enabled)
	IEex_Call(0x4D29D0, {enabled and 1 or 0}, CUIPanel, 0x0)
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

function IEex_SetControlButtonText(CUIControlButton, text)

	local manager = IEex_NewMemoryManager({
		{
			["name"] = "varChars",
			["struct"] = "string",
			["constructor"] = {
				["luaArgs"] = {text},
			},
		},
		{
			["name"] = "varString",
			["struct"] = "CString",
			["constructor"] = {
				["variant"] = "fromString",
				["args"] = {"varChars"},
			},
		},
	})

	IEex_Call(0x4D58A0, {manager:getAddress("varString")}, CUIControlButton, 0x0)
	manager:free()
end

function IEex_SetControlLabelText(CUIControlLabel, text)

	local manager = IEex_NewMemoryManager({
		{
			["name"] = "varChars",
			["struct"] = "string",
			["constructor"] = {
				["luaArgs"] = {text},
			},
		},
		{
			["name"] = "varString",
			["struct"] = "CString",
			["constructor"] = {
				["variant"] = "fromString",
				["args"] = {"varChars"},
			},
		},
	})

	IEex_Call(0x4E46F0, {manager:getAddress("varString")}, CUIControlLabel, 0x0)
	manager:free()
end

function IEex_SetControlButtonFrameUp(CUIControlButton, frame)
	IEex_WriteWord(CUIControlButton + 0x12C, frame)
end

function IEex_SetControlButtonFrame(CUIControlButton, frame)
	IEex_WriteWord(CUIControlButton + 0x116, frame)
end

function IEex_SetControlButtonFrameUpForce(CUIControlButton, frame)
	IEex_SetControlButtonFrameUp(CUIControlButton, frame)
	IEex_SetControlButtonFrame(CUIControlButton, frame)
end

function IEex_SetPanelXY(CUIPanel, x, y)
	IEex_WriteDword(CUIPanel + 0x24, x)
	IEex_WriteDword(CUIPanel + 0x28, y)
end

function IEex_SetControlXY(CUIControl, x, y)
	IEex_WriteDword(CUIControl + 0xE, x)
	IEex_WriteDword(CUIControl + 0x12, y)
end

function IEex_SetEngineScrollbarFocus(CBaldurEngine, CUIControlScrollbar)
	IEex_WriteDword(CBaldurEngine + 0xFA, CUIControlScrollbar)
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
	["pendingItemsAccessChange"] = 0,
	["pendingItemsAccessChangeDelayCounter"] = 0,
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

		-- Fixes weird flicker when performing right-side adjustment; unknown why this occurs
		-- without a 2 tick delay on itemsAccessIndex modification when picking up an item.
		local pendingItemsAccessChange = IEex_Helper_GetBridgeNL("IEex_Quickloot", "pendingItemsAccessChange")
		if pendingItemsAccessChange ~= 0 then
			local pendingItemsAccessChangeDelayCounter = IEex_Helper_GetBridgeNL("IEex_Quickloot", "pendingItemsAccessChangeDelayCounter") + 1
			if pendingItemsAccessChangeDelayCounter == 2 then
				IEex_Helper_SetBridgeNL("IEex_Quickloot", "pendingItemsAccessChange", 0)
				IEex_Helper_SetBridgeNL("IEex_Quickloot", "pendingItemsAccessChangeDelayCounter", 0)
				local newItemsAccessIndex = IEex_Helper_GetBridgeNL("IEex_Quickloot", "itemsAccessIndex") + pendingItemsAccessChange
				local maxIndex = math.max(1, IEex_Helper_GetBridgeNumIntsNL("IEex_Quickloot", "items") - 10 + 1)
				IEex_Helper_SetBridgeNL("IEex_Quickloot", "itemsAccessIndex", math.max(1, math.min(newItemsAccessIndex, maxIndex)))
			else
				IEex_Helper_SetBridgeNL("IEex_Quickloot", "pendingItemsAccessChangeDelayCounter", pendingItemsAccessChangeDelayCounter)
			end
		end

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

IEex_Helper_InitBridgeFromTable("IEex_GUIConstants", {

	["panelActiveByDefault"] = {
		["GUIW08"] = {
			[23] = false,
		},
		["GUIW10"] = {
			[23] = false,
		},
	},

	["controlTypeMeta"] = {
		["ButtonWorldContainerSlot"] = { ["constructor"] = 0x6956F0, ["size"] = 0x666 },
	},

	["controlOverrides"] = {
		["GUIW08"] = {
			[23] = {
				[0] = "ButtonWorldContainerSlot",
				[1] = "ButtonWorldContainerSlot",
				[2] = "ButtonWorldContainerSlot",
				[3] = "ButtonWorldContainerSlot",
				[4] = "ButtonWorldContainerSlot",
				[5] = "ButtonWorldContainerSlot",
				[6] = "ButtonWorldContainerSlot",
				[7] = "ButtonWorldContainerSlot",
				[8] = "ButtonWorldContainerSlot",
				[9] = "ButtonWorldContainerSlot",
			},
		},
		["GUIW10"] = {
			[23] = {
				[0] = "ButtonWorldContainerSlot",
				[1] = "ButtonWorldContainerSlot",
				[2] = "ButtonWorldContainerSlot",
				[3] = "ButtonWorldContainerSlot",
				[4] = "ButtonWorldContainerSlot",
				[5] = "ButtonWorldContainerSlot",
				[6] = "ButtonWorldContainerSlot",
				[7] = "ButtonWorldContainerSlot",
				[8] = "ButtonWorldContainerSlot",
				[9] = "ButtonWorldContainerSlot",
			},
		},
	},
})

function IEex_AddControlOverride(resref, panelID, controlID, controlType)
	IEex_Helper_SetBridge("IEex_GUIConstants", "controlOverrides", resref, panelID, controlID, controlType)
end

function IEex_DefineCustomControl(controlName, controlStructType, args)

	local newVFTable

	local fillVFTableDefaults = function(vftableSize, vftableAddress)
		newVFTable = IEex_Malloc(vftableSize)
		local currentFillAddress = newVFTable
		for i = vftableAddress, vftableAddress + vftableSize, 0x4 do
			IEex_WriteDword(currentFillAddress, IEex_ReadDword(i))
			currentFillAddress = currentFillAddress + 0x4
		end
	end

	local structSize
	local newConstructor

	if controlStructType == IEex_ControlStructType.BUTTON then

		fillVFTableDefaults(0x78, 0x84C984)
		IEex_WriteArgs(newVFTable, args, {
			{ "OnLButtonClick", 0x68, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
			{ "OnLButtonDoubleClick", 0x6C, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		})

		structSize = 0x666
		newConstructor = IEex_WriteAssemblyAuto({[[
			!push_esi
			!mov_esi_ecx
			!push_byte 01 ; bInvalidatePanel ;
			!push_byte 01 ; bButtonActive ;
			!push_[esp+byte] 14 ; pControlInfo ;
			!push_[esp+byte] 14 ; pPanel ;
			!mov_ecx_esi
			!call :4D47D0 ; CUIControlButton_Construct ;
			!mov_[esi]_dword ]], {newVFTable, 4}, [[
			!mov_eax_esi
			!pop_esi
			!ret_word 08 00
		]]})

	elseif controlStructType == IEex_ControlStructType.LABEL then

		fillVFTableDefaults(0x68, 0x84CCD4)

		structSize = 0x560
		newConstructor = IEex_WriteAssemblyAuto({[[
			!mark_esp()
			!push(esi)
			!mov(esi,ecx)
			!marked_esp() !push([esp+8]) ; pControlInfo ;
			!marked_esp() !push([esp+4]) ; pPanel ;
			!mov(ecx,esi)
			!call :4E4000 ; CUIControlLabel_Construct ;
			!mov([esi],$1) ]], {newVFTable}, [[
			!mov(eax,esi)
			!pop(esi)
			!ret(8)
		]]})

	elseif controlStructType == IEex_ControlStructType.TEXT_AREA then

		fillVFTableDefaults(0x78, 0x84CC5C)

		structSize = 0xAB8
		newConstructor = IEex_WriteAssemblyAuto({[[
			!mark_esp
			!push(esi)
			!mov(esi,ecx)
			!push(1) ; bInitStringsList ;
			!marked_esp !push([esp+8]) ; pControlInfo ;
			!marked_esp !push([esp+4]) ; pPanel ;
			!mov(ecx,esi)
			!call :4E1A90 ; CUIControlEditMultiLine_Construct ;
			!mov([esi],$1) ]], {newVFTable}, [[
			!mov(eax,esi)
			!pop(esi)
			!ret(8)
		]]})

	elseif controlStructType == IEex_ControlStructType.SCROLL_BAR then

		fillVFTableDefaults(0x84, 0x84CDB4)

		structSize = 0x14A
		newConstructor = IEex_WriteAssemblyAuto({[[
			!mark_esp
			!push(esi)
			!mov(esi,ecx)
			!marked_esp !push([esp+8]) ; pControlInfo ;
			!marked_esp !push([esp+4]) ; pPanel ;
			!mov(ecx,esi)
			!call :4E47C0 ; CUIControlEditMultiLine_Construct ;
			!mov([esi],$1) ]], {newVFTable}, [[
			!mov(eax,esi)
			!pop(esi)
			!ret(8)
		]]})
	else
		IEex_Error("Unimplemented controlStructType")
	end

	IEex_WriteArgs(newVFTable, args, {
		{ "SetActive",               0x4,  IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "NeedMouseMove",           0x8,  IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "OnLButtonUp",             0xC,  IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "KillFocus",               0x10, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "OnMouseMove",             0x14, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "OnLButtonDown",           0x18, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "OnLButtonUpCoords",       0x1C, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "OnLButtonDblClk",         0x20, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "OnRButtonDown",           0x24, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "OnRButtonUp",             0x28, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "OnKeyDown",               0x2C, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "TimerAsynchronousUpdate", 0x30, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "ActivateToolTip",         0x4C, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "InvalidateRect",          0x50, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "TimerSynchronousUpdate",  0x54, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "Render",                  0x58, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "NeedRender",              0x64, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
	})

	IEex_Helper_SetBridge("IEex_GUIConstants", "controlTypeMeta", controlName, {
		["constructor"] = newConstructor,
		["size"] = structSize,
	})
end

IEex_ControlStructType = {
	["BUTTON"]     = 0,
	["UNKNOWN1"]   = 1,
	["SLIDER"]     = 2,
	["TEXT_FIELD"] = 3,
	["UNKNOWN2"]   = 4,
	["TEXT_AREA"]  = 5,
	["LABEL"]      = 6,
	["SCROLL_BAR"] = 7,
}

function IEex_AddControlToPanel(CUIPanel, args)

	local type = args.type
	if not type then IEex_Error("type must be defined") end

	local typeLength = ({
		[IEex_ControlStructType.BUTTON]     = 0x20,
		[IEex_ControlStructType.UNKNOWN1]   = 0xE,
		[IEex_ControlStructType.SLIDER]     = 0x34,
		[IEex_ControlStructType.TEXT_FIELD] = 0x6A,
		[IEex_ControlStructType.UNKNOWN2]   = 0xE,
		[IEex_ControlStructType.TEXT_AREA]  = 0x2E,
		[IEex_ControlStructType.LABEL]      = 0x24,
		[IEex_ControlStructType.SCROLL_BAR] = 0x28,
	})[type]

	if not typeLength then IEex_Error("Invalid type") end
	local UI_Control_st = IEex_Malloc(typeLength)

	IEex_WriteArgs(UI_Control_st, args, {
		{ "id",           0x0, IEex_WriteType.WORD, IEex_WriteFailType.ERROR      },
		{ "bufferLength", 0x2, IEex_WriteType.WORD, IEex_WriteFailType.DEFAULT, 0 },
		{ "x",            0x4, IEex_WriteType.WORD, IEex_WriteFailType.DEFAULT, 0 },
		{ "y",            0x6, IEex_WriteType.WORD, IEex_WriteFailType.DEFAULT, 0 },
		{ "width",        0x8, IEex_WriteType.WORD, IEex_WriteFailType.DEFAULT, 0 },
		{ "height",       0xA, IEex_WriteType.WORD, IEex_WriteFailType.DEFAULT, 0 },
		{ "type",         0xC, IEex_WriteType.BYTE, IEex_WriteFailType.ERROR      },
		{ "unknown",      0xD, IEex_WriteType.BYTE, IEex_WriteFailType.DEFAULT, 0 },
	})

	if type == IEex_ControlStructType.BUTTON then
		IEex_WriteArgs(UI_Control_st, args, {
			{ "bam",              0xE,  IEex_WriteType.RESREF, IEex_WriteFailType.ERROR      },
			{ "sequence",         0x16, IEex_WriteType.BYTE,   IEex_WriteFailType.DEFAULT, 0 },
			{ "textFlags",        0x17, IEex_WriteType.BYTE,   IEex_WriteFailType.DEFAULT, 0 },
			{ "frameUnpressed",   0x18, IEex_WriteType.BYTE,   IEex_WriteFailType.DEFAULT, 0 },
			{ "textAnchorLeft",   0x19, IEex_WriteType.BYTE,   IEex_WriteFailType.DEFAULT, 0 },
			{ "framePressed",     0x1A, IEex_WriteType.BYTE,   IEex_WriteFailType.DEFAULT, 0 },
			{ "textAnchorRight",  0x1B, IEex_WriteType.BYTE,   IEex_WriteFailType.DEFAULT, 0 },
			{ "frameSelected",    0x1C, IEex_WriteType.BYTE,   IEex_WriteFailType.DEFAULT, 0 },
			{ "textAnchorTop",    0x1D, IEex_WriteType.BYTE,   IEex_WriteFailType.DEFAULT, 0 },
			{ "frameDisabled",    0x1E, IEex_WriteType.BYTE,   IEex_WriteFailType.DEFAULT, 0 },
			{ "textAnchorBottom", 0x1F, IEex_WriteType.BYTE,   IEex_WriteFailType.DEFAULT, 0 },
		})
	elseif type == IEex_ControlStructType.LABEL then
		IEex_WriteArgs(UI_Control_st, args, {
			{ "initialTextStrref", 0xE,  IEex_WriteType.DWORD,  IEex_WriteFailType.DEFAULT, -1       },
			{ "fontBam",           0x12, IEex_WriteType.RESREF, IEex_WriteFailType.ERROR             },
			{ "fontColor1",        0x1A, IEex_WriteType.DWORD,  IEex_WriteFailType.DEFAULT, 0xFFFFF6 },
			{ "fontColor2",        0x1E, IEex_WriteType.DWORD,  IEex_WriteFailType.DEFAULT, 0x0      },
			{ "textFlags",         0x22, IEex_WriteType.WORD,   IEex_WriteFailType.DEFAULT, 0        },
		})
	elseif type == IEex_ControlStructType.TEXT_AREA then
		IEex_WriteArgs(UI_Control_st, args, {
			{ "fontBam",         0xE,  IEex_WriteType.RESREF, IEex_WriteFailType.ERROR                 },
			{ "fontBamInitials", 0x16, IEex_WriteType.RESREF, IEex_WriteFailType.DEFAULT, args.fontBam },
			{ "fontColor1",      0x1E, IEex_WriteType.DWORD,  IEex_WriteFailType.DEFAULT, 0xFFFFFF     },
			{ "fontColor2",      0x22, IEex_WriteType.DWORD,  IEex_WriteFailType.DEFAULT, 0xFFFFFF     },
			{ "fontColor3",      0x26, IEex_WriteType.DWORD,  IEex_WriteFailType.DEFAULT, 0x0          },
			{ "scrollbarID",     0x2A, IEex_WriteType.DWORD,  IEex_WriteFailType.ERROR                 },
		})
	elseif type == IEex_ControlStructType.SCROLL_BAR then
		IEex_WriteArgs(UI_Control_st, args, {
			{ "graphicsBam",             0xE,  IEex_WriteType.RESREF, IEex_WriteFailType.ERROR },
			{ "animationNumber",         0x16, IEex_WriteType.WORD,   IEex_WriteFailType.ERROR },
			{ "upArrowFrameUnpressed",   0x18, IEex_WriteType.WORD,   IEex_WriteFailType.ERROR },
			{ "upArrowFramePressed",     0x1A, IEex_WriteType.WORD,   IEex_WriteFailType.ERROR },
			{ "downArrowFrameUnpressed", 0x1C, IEex_WriteType.WORD,   IEex_WriteFailType.ERROR },
			{ "downArrowFramePressed",   0x1E, IEex_WriteType.WORD,   IEex_WriteFailType.ERROR },
			{ "troughFrame",             0x20, IEex_WriteType.WORD,   IEex_WriteFailType.ERROR },
			{ "sliderFrame",             0x22, IEex_WriteType.WORD,   IEex_WriteFailType.ERROR },
			{ "textAreaID",              0x24, IEex_WriteType.DWORD,  IEex_WriteFailType.ERROR },
		})
	else
		IEex_Error("type unimplemented")
	end

	IEex_Call(0x4D2AE0, {UI_Control_st}, CUIPanel, 0x0)
	IEex_Free(UI_Control_st)
end

function IEex_AddPanelToEngine(CBaldurEngine, args)

	local UI_PanelHeader_st = IEex_Malloc(0x1C)
	IEex_WriteArgs(UI_PanelHeader_st, args, {
		{ "id",                0x0,  IEex_WriteType.DWORD,  IEex_WriteFailType.ERROR       },
		{ "x",                 0x4,  IEex_WriteType.WORD,   IEex_WriteFailType.DEFAULT, 0  },
		{ "y",                 0x6,  IEex_WriteType.WORD,   IEex_WriteFailType.DEFAULT, 0  },
		{ "width",             0x8,  IEex_WriteType.WORD,   IEex_WriteFailType.DEFAULT, 0  },
		{ "height",            0xA,  IEex_WriteType.WORD,   IEex_WriteFailType.DEFAULT, 0  },
		{ "hasBackground",     0xC,  IEex_WriteType.WORD,   IEex_WriteFailType.DEFAULT, 0  },
		{ "numControls",       0xE,  IEex_WriteType.WORD,   IEex_WriteFailType.DEFAULT, 0  },
		{ "backgroundImage",   0x10, IEex_WriteType.RESREF, IEex_WriteFailType.DEFAULT, "" },
		{ "firstControlIndex", 0x18, IEex_WriteType.WORD,   IEex_WriteFailType.DEFAULT, 0  },
		{ "flags",             0x1A, IEex_WriteType.WORD,   IEex_WriteFailType.DEFAULT, 0  },
	})

	local CUIPanel = IEex_Malloc(0x12A)
	local uiManager = IEex_GetUIManagerFromEngine(CBaldurEngine)
	IEex_Call(0x4D2750, {UI_PanelHeader_st, uiManager}, CUIPanel, 0x0) -- CUIPanel_Construct()
	IEex_Call(0x7FBE4E, {CUIPanel}, uiManager + 0xAE, 0x0) -- CPtrList_AddTail()

	IEex_Free(UI_PanelHeader_st)
	return CUIPanel
end

------------------------
-- GUI Hook Functions --
------------------------

------------------
-- Thread: Both --
------------------

function IEex_Extern_CUIManager_fInit_CHUInitialized(CUIManager, resrefPointer)

	IEex_AssertThread(IEex_Thread.Both, true)
	local resref = IEex_ReadLString(resrefPointer, 8)

	local resrefOverride = IEex_Helper_GetBridge("IEex_GUIConstants", "panelActiveByDefault", resref)
	if not resrefOverride then return end

	IEex_Helper_IterateBridge(resrefOverride, function(panelID, active)
		local panel = IEex_GetPanel(CUIManager, panelID)
		if panel ~= 0x0 then
			IEex_SetPanelActive(panel, active)
		end
	end)
end

function IEex_Extern_CUIControlBase_CreateControl(resrefPointer, panel, controlInfo)

	IEex_AssertThread(IEex_Thread.Both, true)

	local resref = IEex_ReadLString(resrefPointer, 8)
	local panelID = IEex_ReadDword(panel + 0x20)
	local controlID = IEex_ReadDword(controlInfo)

	local controlOverride = IEex_Helper_GetBridge("IEex_GUIConstants", "controlOverrides", resref, panelID, controlID)
	if not controlOverride then return 0x0 end

	local controlMeta = IEex_Helper_GetBridge("IEex_GUIConstants", "controlTypeMeta", controlOverride)
	if not controlMeta then
		IEex_TracebackMessage("IEex Critical Error - No metadata defined for IEex_ControlType "..controlOverride)
		return 0x0
	end

	local control = IEex_Malloc(IEex_Helper_GetBridge(controlMeta, "size"))
	IEex_Call(IEex_Helper_GetBridge(controlMeta, "constructor"), {controlInfo, panel}, control, 0x0)

	return control
end

--------------------------------
-- General Custom UI Controls --
--------------------------------

-------------------
-- Thread: Async --
-------------------

function IEex_Extern_UI_ButtonLClick(CUIControlButton)

	IEex_AssertThread(IEex_Thread.Async, true)

	local panel = IEex_GetControlPanel(CUIControlButton)
	local resref = IEex_GetCHUResrefFromPanel(panel)
	local panelID = IEex_GetPanelID(panel)
	local controlID = IEex_GetControlID(CUIControlButton)

	local trySetPanelEnabled = function(panel, enabled)
		if panel ~= 0x0 then
			IEex_SetPanelEnabled(panel, enabled)
		end
	end

	local setCommonPanelsEnabled = function(engine, enabled)
		trySetPanelEnabled(IEex_GetPanelFromEngine(engine, -2), enabled)
		trySetPanelEnabled(IEex_GetPanelFromEngine(engine, -3), enabled)
		trySetPanelEnabled(IEex_GetPanelFromEngine(engine, -4), enabled)
		trySetPanelEnabled(IEex_GetPanelFromEngine(engine, -5), enabled)
		IEex_SetPanelEnabled(IEex_GetPanelFromEngine(engine, 0), enabled)
		IEex_SetPanelEnabled(IEex_GetPanelFromEngine(engine, 1), enabled)
		IEex_SetPanelEnabled(IEex_GetPanelFromEngine(engine, 2), enabled)
	end

	local handlers = {
		["GUIOPT"] = {
			[2] = {
				-- "IEex Options" Button
				[15] = function()

					IEex_InitOptionButtons()
					-- Copy current options to working temp
					IEex_Helper_SetBridge("IEex_Options", "workingOptions", IEex_Helper_GetBridge("IEex_Options", "options"))

					local screenOptions = IEex_GetEngineOptions()
					local worldOptionsPanel = IEex_GetPanelFromEngine(screenOptions, 2)
					local newOptionsPanel = IEex_GetPanelFromEngine(screenOptions, 14)

					-- Add to popup stack
					IEex_Call(0x7FBE4E, {newOptionsPanel}, screenOptions + 0x434, 0x0) -- CPtrList_AddTail()

					local worldOptionsPanelX, worldOptionsPanelY, _, _ = IEex_GetPanelArea(worldOptionsPanel)
					setCommonPanelsEnabled(screenOptions, false)
					IEex_SetPanelEnabled(worldOptionsPanel, false)
					IEex_SetPanelXY(newOptionsPanel, worldOptionsPanelX, worldOptionsPanelY)
					IEex_SetPanelActive(newOptionsPanel, true)
					IEex_SetEngineScrollbarFocus(screenOptions, IEex_GetControlFromPanel(newOptionsPanel, 4))
					IEex_PanelInvalidate(newOptionsPanel)
				end,
			},
			[14] = {
				-- "Done" Button
				[1] = function()

					-- Save (copy) working temp back to options. This invalidates IEex_FogTypePtr,
					-- as the original "options->transparentFogOfWar" is replaced during the copy.
					-- Lock access to this ptr, update it, and unlock to maintain valid state.
					IEex_Helper_LockGlobal("IEex_Options")
					IEex_Helper_SetBridge("IEex_Options", "options", IEex_Helper_GetBridge("IEex_Options", "workingOptions"))
					IEex_WriteDword(IEex_FogTypePtr, IEex_Helper_GetBridgePtr("IEex_Options", "options", "transparentFogOfWar"))
					IEex_Helper_UnlockGlobal("IEex_Options")

					IEex_WriteOptions()
					local screenOptions = IEex_GetEngineOptions()
					local worldOptionsPanel = IEex_GetPanelFromEngine(screenOptions, 2)
					local newOptionsPanel = IEex_GetPanelFromEngine(screenOptions, 14)

					-- Remove from popup stack
					IEex_Call(0x7FB343, {}, screenOptions + 0x434, 0x0) -- CPtrList_RemoveTail()

					IEex_SetPanelActive(newOptionsPanel, false)
					setCommonPanelsEnabled(screenOptions, true)
					IEex_SetPanelEnabled(worldOptionsPanel, true)
				end,
				-- "Cancel" Button
				[2] = function()
					local screenOptions = IEex_GetEngineOptions()
					local worldOptionsPanel = IEex_GetPanelFromEngine(screenOptions, 2)
					local newOptionsPanel = IEex_GetPanelFromEngine(screenOptions, 14)

					-- Remove from popup stack
					IEex_Call(0x7FB343, {}, screenOptions + 0x434, 0x0) -- CPtrList_RemoveTail()

					IEex_SetPanelActive(newOptionsPanel, false)
					setCommonPanelsEnabled(screenOptions, true)
					IEex_SetPanelEnabled(worldOptionsPanel, true)
				end,
				-- "Transparent Fog of War" Toggle
				[6] = function()
					local workingOptions = IEex_Helper_GetBridge("IEex_Options", "workingOptions")
					if IEex_Helper_GetBridge(workingOptions, "transparentFogOfWar") then
						IEex_SetControlButtonFrameUp(CUIControlButton, 1)
						IEex_Helper_SetBridge(workingOptions, "transparentFogOfWar", false)
					else
						IEex_SetControlButtonFrameUp(CUIControlButton, 3)
						IEex_Helper_SetBridge(workingOptions, "transparentFogOfWar", true)
					end
				end,
			},
		},
	}

	local resrefHandler = handlers[resref]
	if not resrefHandler then return end
	local panelHandler = resrefHandler[panelID]
	if not panelHandler then return end
	local controlHandler = panelHandler[controlID]
	if controlHandler then
		controlHandler()
	end
end

function IEex_Extern_UI_LabelLDown(CUIControlLabel)

	IEex_AssertThread(IEex_Thread.Async, true)

	local panel = IEex_GetControlPanel(CUIControlLabel)
	local resref = IEex_GetCHUResrefFromPanel(panel)
	local panelID = IEex_GetPanelID(panel)
	local controlID = IEex_GetControlID(CUIControlLabel)

	local handlers = {
		["GUIOPT"] = {
			[14] = {
				[5] = function()
					IEex_SetTextAreaToString(IEex_GetEngineOptions(), 14, 3, "Replaces the interlaced fog of war with \z
						a version that uses transparency. This fixes the flickering caused by the vanilla implementation.")
				end,
			},
		},
	}

	local resrefHandler = handlers[resref]
	if not resrefHandler then return end
	local panelHandler = resrefHandler[panelID]
	if not panelHandler then return end
	local controlHandler = panelHandler[controlID]
	if controlHandler then
		controlHandler()
	end
end

------------------------------------
-- Record Screen Description Hook --
------------------------------------

------------------
-- Thread: Both --
------------------

ex_current_record_hand = 1
function IEex_Extern_OnUpdateRecordDescription(CScreenCharacter, CGameSprite, CUIControlEditMultiLine, m_plstStrings)
	IEex_AssertThread(IEex_Thread.Both, true)
	local creatureData = CGameSprite
	local targetID = IEex_GetActorIDShare(creatureData)
	local descPanelNum = IEex_ReadByte(CScreenCharacter + 0x1844, 0)
	local extraFlags = IEex_ReadDword(creatureData + 0x740)
	if bit.band(extraFlags, 0x1000) > 0 then
		IEex_WriteDword(creatureData + 0x740, bit.band(extraFlags, 0xFFFFEFFF))
		local armoredArcanaFeatCount = IEex_ReadByte(creatureData + 0x781, 0x0)
		IEex_WriteByte(creatureData + 0x781, math.floor(armoredArcanaFeatCount / ex_armored_arcana_multiplier))
	end
	local armoredArcanaString = IEex_FetchString(36352)
	local sneakAttackDamageString = IEex_FetchString(24898)
	local turnUndeadLevelString = IEex_FetchString(12126)
	local wholenessOfBodyString = IEex_FetchString(39768)
	local genericString = IEex_FetchString(33552)
	local monkWisdomBonusString = ex_str_925
	local mainhandString = IEex_FetchString(734)
	local offhandString = IEex_FetchString(733)
	local baseString = IEex_FetchString(31353)
	local rangedString = IEex_FetchString(41123)
	local numberOfAttacksString = IEex_FetchString(9458)
	local criticalHitString = IEex_FetchString(41122)
	IEex_IterateCPtrList(m_plstStrings, function(lineEntry)
		local line = IEex_ReadString(IEex_ReadDword(lineEntry + 0x4))

		if string.match(line, mainhandString) or string.match(line, rangedString) then
			ex_current_record_hand = 1
		elseif string.match(line, offhandString) then
			ex_current_record_hand = 2
		end
		if string.match(line, sneakAttackDamageString .. ":") then
			local rogueLevel = IEex_GetActorStat(targetID, 104)
			local sneakAttackDiceNumber = math.floor((rogueLevel + 1) / 2) + IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_IMPROVED_SNEAK_ATTACK"], 0x0)
			if IEex_GetActorSpellState(targetID, 192) then
				IEex_IterateActorEffects(targetID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					if theopcode == 288 and theparameter2 == 192 then
						local theparameter1 = IEex_ReadDword(eData + 0x1C)
						local thesavingthrow = IEex_ReadDword(eData + 0x40)
						local theresource = IEex_ReadLString(eData + 0x30, 8)
						if bit.band(thesavingthrow, 0x20000) == 0 and (bit.band(thesavingthrow, 0x40000) > 0 or rogueLevel > 0) then
							sneakAttackDiceNumber = sneakAttackDiceNumber + theparameter1
						end
					end
				end)
			end
			line = string.gsub(line, "%d+d6", sneakAttackDiceNumber .. "d6")
		elseif string.match(line, turnUndeadLevelString .. ":") then
			local clericLevel = IEex_GetActorStat(targetID, 98)
			local paladinLevel = IEex_GetActorStat(targetID, 102)
			local charismaBonus = math.floor((IEex_GetActorStat(targetID, 42) - 10) / 2)
			local turnLevel = clericLevel + charismaBonus
			if paladinLevel >= 3 then
				turnLevel = turnLevel + paladinLevel - 2
			end
			if IEex_GetActorSpellState(targetID, 194) then
				IEex_IterateActorEffects(targetID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					if theopcode == 288 and theparameter2 == 194 then
						local theparameter1 = IEex_ReadDword(eData + 0x1C)
						turnLevel = turnLevel + theparameter1
					end
				end)
			end
			local turningFeat = IEex_ReadByte(creatureData + 0x78C, 0)
			turnLevel = turnLevel + turningFeat * 3
			line = string.gsub(line, "%d+", turnLevel)
		elseif string.match(line, wholenessOfBodyString .. ":") then
			local monkLevel = IEex_GetActorStat(targetID, 101)
			local wisdomBonus = math.floor((IEex_GetActorStat(targetID, 39) - 10) / 2)
			if wisdomBonus < 1 then
				wisdomBonus = 1
			end
			line = string.gsub(line, "%d+", monkLevel * wisdomBonus)
		elseif string.match(line, monkWisdomBonusString .. ":") or string.match(line, genericString .. ":") then
			local monkLevel = IEex_GetActorStat(targetID, 101)
			local wisdomBonus = math.floor((IEex_GetActorStat(targetID, 39) - 10) / 2)
			local monkACBonusDisabled = false
			local fixMonkACBonus = true
			IEex_IterateActorEffects(targetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
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
			if monkACBonusDisabled and fixMonkACBonus then
				if string.match(line, monkWisdomBonusString .. ":") then
					line = string.gsub(line, "0", wisdomBonus)
				elseif string.match(line, genericString .. ":") then
					local genericAC = string.match(line, "%d+") - wisdomBonus
					if genericAC > 0 then
						line = string.gsub(line, "%+" .. "%d+", "+" .. genericAC)
					elseif genericAC < 0 then
						line = string.gsub(line, "." .. "%d+", "-" .. math.abs(genericAC))
					else
						line = ""
					end
				end
			end
		elseif descPanelNum == 1 and string.match(line, armoredArcanaString .. ":") then
			local armoredArcanaFeatCount = IEex_ReadByte(creatureData + 0x781, 0x0)
			line = string.gsub(line, "%d+", (armoredArcanaFeatCount * ex_armored_arcana_multiplier) * 5)
		elseif string.match(line, mainhandString .. ":") or string.match(line, offhandString .. ":") or string.match(line, numberOfAttacksString) then
			local normalAPR = IEex_GetActorStat(targetID, 8)
			local imptwfFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_IMPROVED_TWO_WEAPON_FIGHTING"], 0x0)
			local manyshotFeatCount = IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_MANYSHOT"], 0x0)
			local rapidShotEnabled = (IEex_ReadByte(creatureData + 0x4C64, 0x0) > 0)
			local monkLevel = IEex_GetActorStat(targetID, 101)
			local handSpecificAttackBonus = IEex_ReadSignedByte(creatureData + 0x9F8, 0x0)
			if ex_current_record_hand == 2 then
				handSpecificAttackBonus = IEex_ReadSignedByte(creatureData + 0x9FC, 0x0)
			end
			local baseAPR = IEex_ReadByte(creatureData + 0x5ED, 0x0)
			local trueBaseAPR = baseAPR
			local monkAttackBonusDisabled, fixMonkAttackBonus = IEex_CheckMonkAttackBonus(creatureData)
			if monkAttackBonusDisabled and fixMonkAttackBonus then
				trueBaseAPR = tonumber(IEex_2DAGetAtStrings("BAATMKU", "NUM_ATTACKS", tostring(monkLevel)))
				if trueBaseAPR > 4 then
					trueBaseAPR = 4
				end
				handSpecificAttackBonus = handSpecificAttackBonus + tonumber(IEex_2DAGetAtStrings("BAATMKU", "BASE_ATTACK", tostring(monkLevel))) - tonumber(IEex_2DAGetAtStrings("BAATNFG", "BASE_ATTACK", tostring(monkLevel)))
			end
			if ex_record_attack_stats_hidden_difference[targetID] ~= nil then
				handSpecificAttackBonus = handSpecificAttackBonus - ex_record_attack_stats_hidden_difference[targetID][1]
			end
			local attackPenaltyIncrement = 5
			local monkAttackBonusNowEnabled = (monkLevel > 0 and (not monkAttackBonusDisabled or fixMonkAttackBonus))
			local extraMonkAttacks = 0
			if monkAttackBonusNowEnabled then
				attackPenaltyIncrement = 3
				extraMonkAttacks = ex_monk_apr_progression[monkLevel]
				if IEex_GetEquippedWeaponRES(targetID) == ex_monk_fist_progression[monkLevel] or IEex_GetEquippedWeaponRES(targetID) == ex_incorporeal_monk_fist_progression[monkLevel] or string.sub(IEex_GetEquippedWeaponRES(targetID), 1, 7) == "00MFIST" then
					extraMonkAttacks = extraMonkAttacks + 1
				end
			end
			local attackI = 0
			if not string.match(line, numberOfAttacksString) then
				line = string.gsub(line, "(%d+)", "!%1!")
				for w in string.gmatch(line, "%d+") do
					attackI = attackI + 1
					local monkAttackPenaltyIncrementFix = 0
					if attackI >= 2 and monkAttackBonusDisabled and fixMonkAttackBonus then
						monkAttackPenaltyIncrementFix = (attackI - 1) * 2
					end
					line = string.gsub(line, "!" .. w .. "!", w + handSpecificAttackBonus + monkAttackPenaltyIncrementFix)
				end
			end
			if ((normalAPR + imptwfFeatCount + extraMonkAttacks >= 5) or ((trueBaseAPR + imptwfFeatCount + extraMonkAttacks >= 5))) or (manyshotFeatCount > 0 and rapidShotEnabled) then
				local totalAttacks = trueBaseAPR + extraMonkAttacks
				local extraAttacks = 0
				local extraMainhandAttacks = extraMonkAttacks
				local manyshotAttacks = manyshotFeatCount
				local numWeapons = 0
				local headerType = 1
				local weaponSlot = IEex_ReadByte(creatureData + 0x4BA4, 0x0)
				local weaponHeader = IEex_ReadByte(creatureData + 0x4BA6, 0x0)
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
				local isFistWeapon = false
				local isBow = false
				local wearingLightArmor = true
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
		--[[
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
				else
					extraAttacks = extraAttacks + extraMainhandAttacks
					extraMainhandAttacks = 0
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
				totalAttacks = totalAttacks + manyshotAttacks
				if IEex_GetActorSpellState(targetID, 138) then
					if numWeapons >= 2 then
						extraMainhandAttacks = extraMainhandAttacks * 2 + (normalAPR - 1)
						extraAttacks = extraAttacks * 2 + 1
					else
						extraAttacks = extraAttacks * 2 + normalAPR
					end
					manyshotAttacks = manyshotAttacks * 2
					totalAttacks = normalAPR + extraAttacks + extraMainhandAttacks + manyshotAttacks

				end
				if string.match(line, numberOfAttacksString) then
					if numWeapons >= 2 then
						line = string.gsub(line, "%d.%d", (normalAPR - 1 + extraMainhandAttacks) .. "+" .. (1 + extraAttacks))
					else
						line = string.gsub(line, "%d+", totalAttacks)
					end
				else
					local lastAttackRollBonus = 0
					for w in string.gmatch(line, "%d+") do
						lastAttackRollBonus = w
					end
					if manyshotAttacks > 0 then
						local firstAttackRollBonus = string.match(line, "%d+")
						local manyshotAttackRollBonus = firstAttackRollBonus - attackPenaltyIncrement * manyshotAttacks
						local manyshotAttackListString = ""
						if manyshotAttackRollBonus >= 0 then
							for i = 1, manyshotAttacks, 1 do
								manyshotAttackListString = manyshotAttackListString .. "+" .. manyshotAttackRollBonus .. "/"
							end
							line = string.gsub(line, "." .. firstAttackRollBonus .. ".." .. firstAttackRollBonus, manyshotAttackListString .. "+" .. manyshotAttackRollBonus .. "/+" .. firstAttackRollBonus)
						else
							for i = 1, manyshotAttacks, 1 do
								manyshotAttackListString = manyshotAttackListString .. "-" .. math.abs(manyshotAttackRollBonus) .. "/"
							end
							line = string.gsub(line, "(.)" .. math.abs(firstAttackRollBonus), manyshotAttackListString .. "-" .. math.abs(manyshotAttackRollBonus) .. "/%1" .. firstAttackRollBonus)
						end
					end
					if string.match(line, mainhandString .. ":") and numWeapons >= 2 then
						for i = 1, extraMainhandAttacks, 1 do
							local nextAttackRollBonus = lastAttackRollBonus - i * attackPenaltyIncrement
							if nextAttackRollBonus >= 0 then
								line = line .. "/+" .. nextAttackRollBonus
							else
								line = line .. "/-" .. math.abs(nextAttackRollBonus)
							end
						end
					else
						for i = 1, extraAttacks, 1 do
							local nextAttackRollBonus = lastAttackRollBonus - i * attackPenaltyIncrement
							if nextAttackRollBonus >= 0 then
								line = line .. "/+" .. nextAttackRollBonus
							else
								line = line .. "/-" .. math.abs(nextAttackRollBonus)
							end
						end
					end
				end
			end
		elseif string.match(line, baseString .. ":") and string.match(line, "%+") and ex_current_record_hand == 1 then
			local normalAPR = IEex_GetActorStat(targetID, 8)
			local monkLevel = IEex_GetActorStat(targetID, 101)
			local handSpecificAttackBonus = 0
			local baseAPR = IEex_ReadByte(creatureData + 0x5ED, 0x0)
			local trueBaseAPR = baseAPR
			local monkAttackBonusDisabled, fixMonkAttackBonus = IEex_CheckMonkAttackBonus(creatureData)
			if monkAttackBonusDisabled and fixMonkAttackBonus then
				trueBaseAPR = tonumber(IEex_2DAGetAtStrings("BAATMKU", "NUM_ATTACKS", tostring(monkLevel)))
				if trueBaseAPR > 4 then
					trueBaseAPR = 4
				end
				handSpecificAttackBonus = handSpecificAttackBonus + tonumber(IEex_2DAGetAtStrings("BAATMKU", "BASE_ATTACK", tostring(monkLevel))) - tonumber(IEex_2DAGetAtStrings("BAATNFG", "BASE_ATTACK", tostring(monkLevel)))
				local attackPenaltyIncrement = 3
				local attackI = 0
				local attackIBonus = 0
				line = string.gsub(line, "(%d+)", "!%1!")
				for w in string.gmatch(line, "%d+") do
					attackI = attackI + 1
					local monkAttackPenaltyIncrementFix = 0
					if attackI >= 2 then
						monkAttackPenaltyIncrementFix = (attackI - 1) * 2
					end
					attackIBonus = w + handSpecificAttackBonus + monkAttackPenaltyIncrementFix
					line = string.gsub(line, "!" .. w .. "!", attackIBonus)
				end
				if trueBaseAPR > attackI then
					for i = 1, trueBaseAPR - attackI, 1 do
						local nextAttackRollBonus = attackIBonus - i * attackPenaltyIncrement
						if nextAttackRollBonus >= 0 then
							line = line .. "/+" .. nextAttackRollBonus
						else
							line = line .. "/-" .. math.abs(nextAttackRollBonus)
						end
					end
				end
			end
		elseif string.match(line, criticalHitString .. ":") then
			local weaponRES = ""
			local weaponSlot = IEex_ReadByte(creatureData + 0x4BA4, 0x0)
			if ex_current_record_hand == 2 and weaponSlot >= 43 then
				weaponSlot = weaponSlot + 1
			end
			local itemType = 0
			local headerType = 0
			local currentHeader = IEex_ReadByte(creatureData + 0x4BA6, 0x0)
			local criticalMultiplier = 2
			local specificCriticalHitBonus = 0
			if ex_record_attack_stats_hidden_difference[targetID] ~= nil then
				specificCriticalHitBonus = specificCriticalHitBonus - ex_record_attack_stats_hidden_difference[targetID][2]
			end
			local slotData = IEex_ReadDword(creatureData + 0x4AD8 + weaponSlot * 0x4)
			if slotData > 0 and weaponSlot <= 50 then
				weaponRES = IEex_ReadLString(slotData + 0xC, 8)
			end
			local weaponWrapper = IEex_DemandRes(weaponRES, "ITM")
			if weaponWrapper:isValid() then
				local weaponData = weaponWrapper:getData()
				itemType = IEex_ReadWord(weaponData + 0x1C, 0x0)
				if ex_item_type_critical[itemType] ~= nil then
					criticalMultiplier = ex_item_type_critical[itemType][2]
				end
				if currentHeader >= IEex_ReadSignedWord(weaponData + 0x68, 0x0) then
					currentHeader = 0
				end
				headerType = IEex_ReadByte(weaponData + 0x82 + currentHeader * 0x38, 0x0)
				local effectOffset = IEex_ReadDword(weaponData + 0x6A)
				local numGlobalEffects = IEex_ReadWord(weaponData + 0x70, 0x0)
				for i = 0, numGlobalEffects - 1, 1 do
					local offset = weaponData + effectOffset + i * 0x30
					local theopcode = IEex_ReadWord(offset, 0x0)
					local theparameter1 = IEex_ReadDword(offset + 0x4)
					local theparameter2 = IEex_ReadDword(offset + 0x8)
					local theresource = IEex_ReadLString(offset + 0x14, 8)
					local thesavingthrow = IEex_ReadDword(offset + 0x24)
					if theopcode == 288 and theparameter2 == 195 and bit.band(thesavingthrow, 0x10000) > 0 then
						criticalMultiplier = criticalMultiplier + theparameter1
					elseif theopcode == 500 and theresource == "MECRIT" and bit.band(thesavingthrow, 0x100000) > 0 then
						specificCriticalHitBonus = specificCriticalHitBonus + theparameter1
					end
				end
			end
			local launcherRES = ""
			if weaponSlot >= 11 and weaponSlot <= 14 then
				IEex_IterateActorEffects(targetID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					local thegeneralitemcategory = IEex_ReadByte(eData + 0x48, 0x0)
					if theopcode == 288 and theparameter2 == 241 and thegeneralitemcategory == 7 then
						launcherRES = IEex_ReadLString(eData + 0x94, 8)
					end
				end)
			end
			local launcherWrapper = IEex_DemandRes(launcherRES, "ITM")
			if launcherWrapper:isValid() then
				local launcherData = weaponWrapper:getData()
				local effectOffset = IEex_ReadDword(launcherData + 0x6A)
				local numGlobalEffects = IEex_ReadWord(launcherData + 0x70, 0x0)
				for i = 0, numGlobalEffects - 1, 1 do
					local offset = launcherData + effectOffset + i * 0x30
					local theopcode = IEex_ReadWord(offset, 0x0)
					local theparameter1 = IEex_ReadDword(offset + 0x4)
					local theparameter2 = IEex_ReadDword(offset + 0x8)
					local theresource = IEex_ReadLString(offset + 0x14, 8)
					local thesavingthrow = IEex_ReadDword(offset + 0x24)
					if theopcode == 288 and theparameter2 == 195 and bit.band(thesavingthrow, 0x10000) > 0 then
						criticalMultiplier = criticalMultiplier + theparameter1
					elseif theopcode == 500 and theresource == "MECRIT" and bit.band(thesavingthrow, 0x100000) > 0 then
						specificCriticalHitBonus = specificCriticalHitBonus + theparameter1
					end
				end
			end
			IEex_IterateActorEffects(targetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if theopcode == 288 and theparameter2 == 195 and bit.band(thesavingthrow, 0x10000) == 0 and (thespecial == -1 or thespecial == itemType) then
					criticalMultiplier = criticalMultiplier + theparameter1
				end
			end)
			line = string.gsub(line, "x%d+", "x" .. criticalMultiplier)
			local newLowestCriticalHitRoll = string.match(line, "%d+") - specificCriticalHitBonus
			if newLowestCriticalHitRoll < 1 then
				newLowestCriticalHitRoll = 1
			end
			line = string.gsub(line, "%d+%-", newLowestCriticalHitRoll .. "-")
		end
		-- do whatever changes you want to the line here
		IEex_CString_Set(lineEntry + 0x4, line)
	end)
end

---------------
-- Quickloot --
---------------

-------------------
-- Thread: Async --
-------------------

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
	IEex_Helper_SynchronizedBridgeOperation("IEex_Quickloot", function()
		local itemsAccessIndex = IEex_Helper_GetBridgeNL("IEex_Quickloot", "itemsAccessIndex")
		IEex_Helper_SetBridgeNL("IEex_Quickloot", "itemsAccessIndex", math.max(1, itemsAccessIndex - 10))
	end)
end

function IEex_Extern_Quickloot_ScrollRight()
	IEex_AssertThread(IEex_Thread.Async, true)
	IEex_Helper_SynchronizedBridgeOperation("IEex_Quickloot", function()
		local itemsAccessIndex = IEex_Helper_GetBridgeNL("IEex_Quickloot", "itemsAccessIndex")
		local maxIndex = math.max(1, IEex_Helper_GetBridgeNumIntsNL("IEex_Quickloot", "items") - 10 + 1)
		IEex_Helper_SetBridgeNL("IEex_Quickloot", "itemsAccessIndex", math.min(itemsAccessIndex + 10, maxIndex))
	end)
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
	IEex_Helper_SynchronizedBridgeOperation("IEex_Quickloot", function()
		local pendingItemsAccessChange = IEex_Helper_GetBridgeNL("IEex_Quickloot", "pendingItemsAccessChange") - 1
		IEex_Helper_SetBridgeNL("IEex_Quickloot", "pendingItemsAccessChange", pendingItemsAccessChange)
	end)
end

function IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot(control)
	IEex_AssertThread(IEex_Thread.Async, true)
	return IEex_Quickloot_IsControlOnPanel(control)
end

------------------
-- Thread: Both --
------------------

function IEex_Extern_GetHighlightContainerID()
	IEex_AssertThread(IEex_Thread.Both, true)
	return IEex_Helper_GetBridge("IEex_Quickloot", "highlightContainerID")
end

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

----------------------------
-- Define Custom Controls --
----------------------------

IEex_AbsoluteOnce("IEex_CustomControls", function()

	if not IEex_InAsyncState then return false end

	---------------
	-- Quickloot --
	---------------

	-------------------------------
	-- IEex_Quickloot_ScrollLeft --
	-------------------------------

	IEex_DefineCustomControl("IEex_Quickloot_ScrollLeft", IEex_ControlStructType.BUTTON, {
		["OnLButtonClick"] = IEex_WriteAssemblyAuto(IEex_FlattenTable({
			{"!push_all_registers_iwd2"},
			IEex_GenLuaCall("IEex_Extern_Quickloot_ScrollLeft", {
				["args"] = {
					{"!push(ecx)"},
				},
			}),
			{[[
				@call_error
				!pop_all_registers_iwd2
				!ret_word 08 00
			]]}
		})),
		["OnLButtonDoubleClick"] = 0x4D4D70, -- CUIControlButton_OnLButtonDown; prevents double-click cooldown.
	})

	IEex_AddControlOverride("GUIW08", 23, 10, "IEex_Quickloot_ScrollLeft")
	IEex_AddControlOverride("GUIW10", 23, 10, "IEex_Quickloot_ScrollLeft")

	--------------------------------
	-- IEex_Quickloot_ScrollRight --
	--------------------------------

	IEex_DefineCustomControl("IEex_Quickloot_ScrollRight", IEex_ControlStructType.BUTTON, {
		["OnLButtonClick"] = IEex_WriteAssemblyAuto(IEex_FlattenTable({
			{"!push_all_registers_iwd2"},
			IEex_GenLuaCall("IEex_Extern_Quickloot_ScrollRight", {
				["args"] = {
					{"!push(ecx)"},
				},
			}),
			{[[
				@call_error
				!pop_all_registers_iwd2
				!ret_word 08 00
			]]}
		})),
		["OnLButtonDoubleClick"] = 0x4D4D70, -- CUIControlButton_OnLButtonDown; prevents double-click cooldown.
	})


	IEex_AddControlOverride("GUIW08", 23, 11, "IEex_Quickloot_ScrollRight")
	IEex_AddControlOverride("GUIW10", 23, 11, "IEex_Quickloot_ScrollRight")

	--------------------------------
	-- General Custom UI Controls --
	--------------------------------

	IEex_DefineCustomControl("IEex_UI_Button", IEex_ControlStructType.BUTTON, {
		["OnLButtonClick"] = IEex_WriteAssemblyAuto(IEex_FlattenTable({
			{"!push_all_registers_iwd2"},
			IEex_GenLuaCall("IEex_Extern_UI_ButtonLClick", {
				["args"] = {
					{"!push(ecx)"},
				},
			}),
			{[[
				@call_error
				!pop_all_registers_iwd2
				!ret_word 08 00
			]]}
		})),
		["OnLButtonDoubleClick"] = 0x4D4D70, -- CUIControlButton_OnLButtonDown; prevents double-click cooldown.
	})

	IEex_DefineCustomControl("IEex_UI_Label", IEex_ControlStructType.LABEL, {
		["OnLButtonDown"] = IEex_WriteAssemblyAuto(IEex_FlattenTable({
			{"!push_all_registers_iwd2"},
			IEex_GenLuaCall("IEex_Extern_UI_LabelLDown", {
				["args"] = {
					{"!push(ecx)"},
				},
			}),
			{[[
				@call_error
				!pop_all_registers_iwd2
				!ret_word 08 00
			]]}
		})),
	})

	IEex_DefineCustomControl("IEex_UI_TextArea", IEex_ControlStructType.TEXT_AREA, {})
	IEex_DefineCustomControl("IEex_UI_Scrollbar", IEex_ControlStructType.SCROLL_BAR, {})

	------------------
	-- IEex Options --
	------------------

	local screenOptions = IEex_GetEngineOptions()
	local worldOptionsPanel = IEex_GetPanelFromEngine(screenOptions, 2)

	-- Move the normal "Return" button over to make room
	IEex_SetControlXY(IEex_GetControlFromPanel(worldOptionsPanel, 11), 612, 338)

	IEex_AddControlOverride("GUIOPT", 2, 15, "IEex_UI_Button")
	IEex_AddControlToPanel(worldOptionsPanel, {
		["type"] = IEex_ControlStructType.BUTTON,
		["id"] = 15,
		["x"] = 497,
		["y"] = 338,
		["width"] = 117,
		["height"] = 25,
		["bam"] = "GBTNSTD",
		["frameUnpressed"] = 1,
		["framePressed"] = 2,
		["frameDisabled"] = 3,
	})
	IEex_SetControlButtonText(IEex_GetControlFromPanel(worldOptionsPanel, 15), "IEex Options")

	-- IEex Options panel - ID 14
	local newOptionsPanel = IEex_AddPanelToEngine(screenOptions, {
		["id"] = 14,
		["width"] = 800,
		["height"] = 433,
		["hasBackground"] = 1,
		["backgroundImage"] = "GOPPAUB",
	})

	-- "IEex Options" Label - ID 0
	IEex_AddControlOverride("GUIOPT", 14, 0, "IEex_UI_Label")
	IEex_AddControlToPanel(newOptionsPanel, {
		["type"] = IEex_ControlStructType.LABEL,
		["id"] = 0,
		["x"] = 279,
		["y"] = 23,
		["width"] = 242,
		["height"] = 30,
		["fontBam"] = "STONEBIG",
		["textFlags"] = 0x44, -- Center justify(4) | Middle justify(6)
	})
	IEex_SetControlLabelText(IEex_GetControlFromPanel(newOptionsPanel, 0), "IEex Options")

	-- "Done" Button - ID 1
	IEex_AddControlOverride("GUIOPT", 14, 1, "IEex_UI_Button")
	IEex_AddControlToPanel(newOptionsPanel, {
		["type"] = IEex_ControlStructType.BUTTON,
		["id"] = 1,
		["x"] = 614,
		["y"] = 338,
		["width"] = 117,
		["height"] = 25,
		["bam"] = "GBTNSTD",
		["frameUnpressed"] = 1,
		["framePressed"] = 2,
		["frameDisabled"] = 3,
	})
	IEex_SetControlButtonText(IEex_GetControlFromPanel(newOptionsPanel, 1), "Done")

	-- "Cancel" Button - ID 2
	IEex_AddControlOverride("GUIOPT", 14, 2, "IEex_UI_Button")
	IEex_AddControlToPanel(newOptionsPanel, {
		["type"] = IEex_ControlStructType.BUTTON,
		["id"] = 2,
		["x"] = 491,
		["y"] = 338,
		["width"] = 117,
		["height"] = 25,
		["bam"] = "GBTNSTD",
		["frameUnpressed"] = 1,
		["framePressed"] = 2,
		["frameDisabled"] = 3,
	})
	IEex_SetControlButtonText(IEex_GetControlFromPanel(newOptionsPanel, 2), "Cancel")

	-- Description Area - ID 3
	IEex_AddControlOverride("GUIOPT", 14, 3, "IEex_UI_TextArea")
	IEex_AddControlToPanel(newOptionsPanel, {
		["type"] = IEex_ControlStructType.TEXT_AREA,
		["id"] = 3,
		["x"] = 438,
		["y"] = 71,
		["width"] = 270,
		["height"] = 253,
		["fontBam"] = "NORMAL",
		["scrollbarID"] = 4,
	})

	-- Description Area Scrollbar - ID 4
	IEex_AddControlOverride("GUIOPT", 14, 4, "IEex_UI_Scrollbar")
	IEex_AddControlToPanel(newOptionsPanel, {
		["type"] = IEex_ControlStructType.SCROLL_BAR,
		["id"] = 4,
		["x"] = 717,
		["y"] = 69,
		["width"] = 12,
		["height"] = 257,
		["graphicsBam"] = "GBTNSCRL",
		["animationNumber"] = 0,
		["upArrowFrameUnpressed"] = 0,
		["upArrowFramePressed"] = 1,
		["downArrowFrameUnpressed"] = 2,
		["downArrowFramePressed"] = 3,
		["troughFrame"] = 4,
		["sliderFrame"] = 5,
		["textAreaID"] = 3,
	})

	-- "Transparent Fog of War" Label - ID 5
	IEex_AddControlOverride("GUIOPT", 14, 5, "IEex_UI_Label")
	IEex_AddControlToPanel(newOptionsPanel, {
		["type"] = IEex_ControlStructType.LABEL,
		["id"] = 5,
		["x"] = 74,
		["y"] = 70,
		["width"] = 308,
		["height"] = 18,
		["fontBam"] = "NORMAL",
		["textFlags"] = 0x51, -- Use color(0) | Right justify(4) | Middle justify(6)
	})
	IEex_SetControlLabelText(IEex_GetControlFromPanel(newOptionsPanel, 5), "Transparent Fog of War")

	-- "Transparent Fog of War" Toggle - ID 6
	IEex_AddControlOverride("GUIOPT", 14, 6, "IEex_UI_Button")
	IEex_AddControlToPanel(newOptionsPanel, {
		["type"] = IEex_ControlStructType.BUTTON,
		["id"] = 6,
		["x"] = 394,
		["y"] = 67,
		["width"] = 23,
		["height"] = 24,
		["bam"] = "GBTNOPT3",
		["frameUnpressed"] = 1,
		["framePressed"] = 2,
	})


	IEex_SetPanelActive(newOptionsPanel, false)

end)

------------------
-- IEex Options --
------------------

IEex_Helper_InitBridgeFromTable("IEex_Options", {
	["options"] = {
		["transparentFogOfWar"] = false,
	},
	["workingOptions"] = {},
	["fogTypePtr"] = 0x0,
})

IEex_AbsoluteOnce("IEex_InitFogTypePtr", function()
	IEex_FogTypePtr = IEex_Malloc(0x4)
	IEex_WriteDword(IEex_FogTypePtr, IEex_Helper_GetBridgePtr("IEex_Options", "options", "transparentFogOfWar"))
	IEex_Helper_SetBridge("IEex_Options", "fogTypePtr", IEex_FogTypePtr)
end)
IEex_FogTypePtr = IEex_FogTypePtr or IEex_Helper_GetBridge("IEex_Options", "fogTypePtr")

function IEex_LoadOptions()

	local options = IEex_Helper_GetBridge("IEex_Options", "options")
	IEex_Helper_SetBridge(options, "transparentFogOfWar",
    	IEex_GetPrivateProfileInt("IEex Options", "Transparent Fog of War", 0, ".\\Icewind2.ini") ~= 0 and true or false)

	IEex_InitOptionButtons()
end

function IEex_WriteOptions()
	IEex_WritePrivateProfileString("IEex Options", "Transparent Fog of War",
		IEex_Helper_GetBridge("IEex_Options", "options", "transparentFogOfWar") and "1" or "0", ".\\Icewind2.ini")
end

function IEex_InitOptionButtons()

	local screenOptions = IEex_GetEngineOptions()
	local newOptionsPanel = IEex_GetPanelFromEngine(screenOptions, 14)
	local options = IEex_Helper_GetBridge("IEex_Options", "options")

	IEex_SetTextAreaToString(screenOptions, 14, 3, "")

	IEex_SetControlButtonFrameUpForce(IEex_GetControlFromPanel(newOptionsPanel, 6),
		IEex_Helper_GetBridge(options, "transparentFogOfWar") and 3 or 1)
end

IEex_AbsoluteOnce("IEex_InitOptions", function()
	if not IEex_InAsyncState then return false end
	IEex_LoadOptions()
end)

function IEex_Extern_OnOptionsScreenESC(CScreenOptions)

	local trySetPanelEnabled = function(panel, enabled)
		if panel ~= 0x0 then
			IEex_SetPanelEnabled(panel, enabled)
		end
	end

	local setCommonPanelsEnabled = function(engine, enabled)
		trySetPanelEnabled(IEex_GetPanelFromEngine(engine, -2), enabled)
		trySetPanelEnabled(IEex_GetPanelFromEngine(engine, -3), enabled)
		trySetPanelEnabled(IEex_GetPanelFromEngine(engine, -4), enabled)
		trySetPanelEnabled(IEex_GetPanelFromEngine(engine, -5), enabled)
		IEex_SetPanelEnabled(IEex_GetPanelFromEngine(engine, 0), enabled)
		IEex_SetPanelEnabled(IEex_GetPanelFromEngine(engine, 1), enabled)
		IEex_SetPanelEnabled(IEex_GetPanelFromEngine(engine, 2), enabled)
	end

	local lastPanel = IEex_ReadDword(IEex_ReadDword(CScreenOptions + 0x43C) + 0x8)
	if IEex_GetPanelID(lastPanel) == 14 then
		IEex_Call(0x7FB343, {}, CScreenOptions + 0x434, 0x0) -- CPtrList_RemoveTail()
		local screenOptions = IEex_GetEngineOptions()
		local worldOptionsPanel = IEex_GetPanelFromEngine(screenOptions, 2)
		local newOptionsPanel = IEex_GetPanelFromEngine(screenOptions, 14)
		IEex_SetPanelActive(newOptionsPanel, false)
		setCommonPanelsEnabled(screenOptions, true)
		IEex_SetPanelEnabled(worldOptionsPanel, true)
		return true
	end
	return false
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
