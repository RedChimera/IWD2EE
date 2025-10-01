
-----------------------
-- General Functions --
-----------------------

function IEex_GetCursorXY()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local x = IEex_ReadDword(g_pBaldurChitin + 0x1906)
	local y = IEex_ReadDword(g_pBaldurChitin + 0x190A)
	return x, y
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

function IEex_GetResolution()
	return IEex_ReadWord(0x8BA31C, 0), IEex_ReadWord(0x8BA31E, 0)
end

function IEex_GetSpellIconResref(spellResref)
	local spellWrapper = IEex_DemandRes(spellResref, "SPL")
	if not spellWrapper:isValid() then return "" end
	local iconResref = IEex_ReadLString(spellWrapper:getData() + 0x3A, 8)
	spellWrapper:free()
	return iconResref
end

function IEex_WritePrivateProfileInt(lpAppName, lpKeyName, nInt, lpFileName)
	IEex_WritePrivateProfileString(lpAppName, lpKeyName, tostring(nInt), lpFileName)
end

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

-------------------------
-- CInfinity Functions --
-------------------------

function IEex_GetViewportRectFromCInfinity(CInfinity)
	local rViewPort = CInfinity + 0x48
	return IEex_ReadDword(rViewPort),       -- left
		   IEex_ReadDword(rViewPort + 0x4), -- top
		   IEex_ReadDword(rViewPort + 0x8), -- right
		   IEex_ReadDword(rViewPort + 0xC)  -- bottom
end

------------------------
-- Viewport Functions --
------------------------

function IEex_GetMainViewportBottom(excludeQuickloot, checkHidden)
	local _, _, _, minY = IEex_GetViewportRect()
	local worldScreen = IEex_GetEngineWorld()
	if not checkHidden or not IEex_IsEngineUIManagerHidden(worldScreen) then
		local ids = {0, 1, 7, 8, 9, 6, 17, 19, 21, 22}
		if not IEex_Vanilla and not excludeQuickloot then table.insert(ids, 23) end
		for _, panelID in ipairs(ids) do
			local panel = IEex_GetPanelFromEngine(worldScreen, panelID)
			if IEex_IsPanelActive(panel) then
				local _, y = IEex_GetPanelArea(panel)
				minY = math.min(minY, y)
			end
		end
	end
	return minY
end

function IEex_GetViewportRect()
	return IEex_GetViewportRectFromCInfinity(IEex_GetCInfinity())
end

function IEex_ResetViewport()
	local panel = IEex_GetPanelFromEngine(IEex_GetEngineWorld(), 1)
	local _, y, _, _ = IEex_GetPanelArea(panel)
	IEex_SetViewportBottom(y)
end

function IEex_SetViewportBottom(bottom)
	IEex_WriteDword(IEex_GetCInfinity() + 0x48 + 0xC, bottom)
end

----------------------
-- Engine Functions --
----------------------

function IEex_GetCHUResrefFromEngine(CBaldurEngine)
	return IEex_GetCHUResrefFromUIManager(IEex_GetUIManagerFromEngine(CBaldurEngine))
end

function IEex_GetPanelFromEngine(CBaldurEngine, panelID)
	return IEex_GetPanel(IEex_GetUIManagerFromEngine(CBaldurEngine), panelID)
end

function IEex_GetUIManagerFromEngine(CBaldurEngine)
	return CBaldurEngine + 0x30
end

function IEex_IsEngineUIManagerHidden(CBaldurEngine)
	return IEex_ReadDword(IEex_GetUIManagerFromEngine(CBaldurEngine)) == 1
end

function IEex_SetEngineScrollbarFocus(CBaldurEngine, CUIControlScrollbar)
	IEex_WriteDword(CBaldurEngine + 0xFA, CUIControlScrollbar)
end

--------------------------
-- UI Manager Functions --
--------------------------

function IEex_GetCHUResrefFromUIManager(CUIManager)
	return IEex_ReadLString(CUIManager + 0x8, 8)
end

function IEex_GetPanel(CUIManager, panelID)
	return IEex_Call(0x4D4000, {panelID}, CUIManager, 0x0)
end

function IEex_InvalidateUIManagerRect(CUIManager, l, r, t, b)
	IEex_RunWithStackManager({
		{["name"] = "rect", ["struct"] = "CRect", ["constructor"] = {["variant"] = "fill", ["luaArgs"] = {l, r, t, b} }}, },
		function(manager)
			IEex_Call(0x4D45E0, {manager:getAddress("rect")}, CUIManager, 0x0)
		end)
end

function IEex_IsUIManagerHidden(CUIManager)
	return IEex_ReadDword(CUIManager) == 1
end

---------------------
-- Panel Functions --
---------------------

function IEex_GetCHUResrefFromPanel(CUIPanel)
	return IEex_GetCHUResrefFromUIManager(IEex_GetUIManagerFromPanel(CUIPanel))
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

function IEex_GetPanelArea(CUIPanel)
	local x = IEex_ReadDword(CUIPanel + 0x24)
	local y = IEex_ReadDword(CUIPanel + 0x28)
	local w = IEex_ReadDword(CUIPanel + 0x34)
	local h = IEex_ReadDword(CUIPanel + 0x38)
	return x, y, w, h
end

function IEex_GetPanelBackgroundImage(CUIPanel)
	-- CUIPanel.m_mosaic.resHelper.cResRef
	return IEex_ReadLString(CUIPanel + 0x3E + 0xA0 + 0x8, 8)
end

function IEex_GetPanelID(CUIPanel)
	return IEex_ReadDword(CUIPanel + 0x20)
end

function IEex_GetUIManagerFromPanel(CUIPanel)
	return IEex_ReadDword(CUIPanel)
end

function IEex_InvalidatePanelUIManager(panel)
	IEex_InvalidateUIManagerRect(IEex_GetUIManagerFromPanel(panel), IEex_GetPanelArea(panel))
end

function IEex_IsPanelActive(CUIPanel)
	return IEex_ReadDword(CUIPanel + 0xF4) == 1
end

-- Flagged when panel is not interactable yet should still render
function IEex_IsPanelInactiveRender(CUIPanel)
	return IEex_ReadDword(CUIPanel + 0x10A) == 1
end

function IEex_IsPointOverControlID(CUIPanel, controlID, x, y)
	return IEex_IsPointOverControl(IEex_GetControlFromPanel(CUIPanel, controlID), x, y)
end

function IEex_IsPointOverPanel(CUIPanel, x, y)
	local panelX, panelY, panelW, panelH = IEex_GetPanelArea(CUIPanel)
	return x >= panelX and x <= (panelX + panelW) and y >= panelY and y <= (panelY + panelH)
end

function IEex_IteratePanelControls(CUIPanel, func)
	IEex_IterateCPtrList(CUIPanel + 0x4, func)
end

function IEex_PanelHasBackground(CUIPanel)
	return IEex_ReadDword(CUIPanel + 0xE2) ~= 0x0
end

function IEex_PanelInvalidate(CUIPanel)
	IEex_Call(0x4D3810, {0x0}, CUIPanel, 0x0)
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

function IEex_SetPanelActive(CUIPanel, active)
	IEex_Call(0x4D3980, {active and 1 or 0}, CUIPanel, 0x0)
end

function IEex_SetPanelArea(CUIPanel, x, y, w, h, bSetOriginal)
	IEex_SetPanelXY(CUIPanel, x, y, bSetOriginal)
	if w then IEex_WriteDword(CUIPanel + 0x34, w) end
	if h then IEex_WriteDword(CUIPanel + 0x38, h) end
end

function IEex_SetPanelEnabled(CUIPanel, enabled)
	IEex_Call(0x4D29D0, {enabled and 1 or 0}, CUIPanel, 0x0)
end

function IEex_SetPanelMosaicResref(CUIPanel, resref)
	IEex_Helper_SetPanelMosaicResref(CUIPanel, resref)
end

function IEex_SetPanelXY(CUIPanel, x, y, bSetOriginal)
	if x then
		IEex_WriteDword(CUIPanel + 0x24, x)
		if bSetOriginal then IEex_WriteDword(CUIPanel + 0x2C, x) end
	end
	if y then
		IEex_WriteDword(CUIPanel + 0x28, y)
		if bSetOriginal then IEex_WriteDword(CUIPanel + 0x30, y) end
	end
end

----------------------------
-- Control Base Functions --
----------------------------

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

function IEex_GetControlID(CUIControl)
	return IEex_ReadDword(CUIControl + 0xA)
end

function IEex_GetControlPanel(CUIControl)
	return IEex_ReadDword(CUIControl + 0x6)
end

function IEex_IsControlActive(CUIControl)
	return IEex_ReadByte(CUIControl + 0x1E) ~= 0
end

function IEex_IsControlActiveForRender(CUIControl)
	return IEex_IsControlActive(CUIControl) or IEex_IsControlInactiveRender(CUIControl)
end

function IEex_IsControlInactiveRender(CUIControl)
	return IEex_ReadDword(CUIControl + 0x32) ~= 0
end

function IEex_IsControlOnPanel(CUIControl, CUIPanel)
	return IEex_GetControlPanel(CUIControl) == CUIPanel
end

function IEex_IsPointOverControl(CUIControl, x, y)
	local controlX, controlY, controlW, controlH = IEex_GetControlAreaAbsolute(CUIControl)
	return x >= controlX and x <= (controlX + controlW) and y >= controlY and y <= (controlY + controlH)
end

function IEex_SetControlActive(CUIControl, active)
	IEex_WriteByte(CUIControl + 0x1E, active and 1 or 0)
end

function IEex_SetControlArea(CUIControl, x, y, w, h)
	if x then IEex_WriteDword(CUIControl + 0xE, x) end
	if y then IEex_WriteDword(CUIControl + 0x12, y) end
	if w then IEex_WriteDword(CUIControl + 0x16, w) end
	if h then IEex_WriteDword(CUIControl + 0x1A, h) end
end

function IEex_SetControlCustomHotkeyHintIndex(CUIControl, customMapIndex)
	-- IEexHelper's reimplementation of the hotkey hint formatting routine uses
	-- flag 0x8000 to differentiate between the engine's hardcoded hotkeys and
	-- our custom ones.
	IEex_SetControlHotkeyHintIndex(CUIControl, bit.bor(customMapIndex, 0x8000))
end

function IEex_SetControlHotkeyHintIndex(CUIControl, hotkeyIndex)
	IEex_WriteWord(CUIControl + 0x4A, hotkeyIndex)
end

function IEex_SetControlXY(CUIControl, x, y)
	if x then IEex_WriteDword(CUIControl + 0xE, x) end
	if y then IEex_WriteDword(CUIControl + 0x12, y) end
end

------------------------------
-- Control Button Functions --
------------------------------

function IEex_GetControlButtonBAM(CUIControlButton)
	-- CUIControlButton.m_vidCellButton.resHelper.cResRef
	return IEex_ReadLString(CUIControlButton + 0x52 + 0xA4 + 0x8, 8)
end

function IEex_GetControlButtonFrameDown(CUIControlButton)
	return IEex_ReadWord(CUIControlButton + 0x12E)
end

function IEex_GetControlButtonFrameUp(CUIControlButton)
	return IEex_ReadWord(CUIControlButton + 0x12C)
end

function IEex_GetControlButtonPendingRenderCount(CUIControlButton)
	return IEex_ReadWord(CUIControlButton + 0x132)
end

function IEex_SetControlButtonFrame(CUIControlButton, frame)
	IEex_WriteWord(CUIControlButton + 0x116, frame)
end

function IEex_SetControlButtonFrameDown(CUIControlButton, frame)
	IEex_WriteWord(CUIControlButton + 0x12E, frame)
end

function IEex_SetControlButtonFrameUp(CUIControlButton, frame)
	IEex_WriteWord(CUIControlButton + 0x12C, frame)
end

function IEex_SetControlButtonFrameUpForce(CUIControlButton, frame)
	IEex_SetControlButtonFrameUp(CUIControlButton, frame)
	IEex_SetControlButtonFrame(CUIControlButton, frame)
end

function IEex_SetControlButtonPendingRenderCount(CUIControlButton, newCount)
	return IEex_WriteWord(CUIControlButton + 0x132, newCount)
end

function IEex_SetControlButtonPlayLButtonDownSound(CUIControlButton, bPlayLButtonDownSound)
	return IEex_WriteDword(CUIControlButton + 0x662, bPlayLButtonDownSound and 1 or 0)
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

function IEex_ShouldControlButtonRender(CUIControlButton, bForceRender)
	return IEex_GetControlButtonPendingRenderCount(CUIControlButton) ~= 0 or bForceRender ~= 0
end

-----------------------------
-- Control Label Functions --
-----------------------------

function IEex_GetControlLabelTextFlags(CUIControlLabel)
	return IEex_ReadWord(CUIControlLabel + 0x55A)
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

function IEex_SetControlLabelTextFlags(CUIControlLabel, flags)
	IEex_WriteWord(CUIControlLabel + 0x55A, flags)
end

---------------------------------------------------
-- Control Button Mage Spell Info Icon Functions --
---------------------------------------------------

function IEex_SetControlButtonMageSpellInfoIcon(CUIControlButtonMageSpellInfoIcon, resref)
	IEex_RunWithStackManager({
		{["name"] = "resref",  ["struct"] = "CResRef", ["constructor"] = {["luaArgs"] = {resref}  }}, },
		function(manager)
			IEex_Call(0x66E500, {manager:getAddress("resref")}, CUIControlButtonMageSpellInfoIcon, 0x0)
		end)
end

--------------------------------
-- /START Container Functions --
--------------------------------

function IEex_GetContainerIDNumItems(containerID)
	local share = IEex_GetActorShare(containerID)
	local toReturn = IEex_GetContainerNumItems(share)
	IEex_UndoActorShare(containerID)
	return toReturn
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

function IEex_GetContainerType(CGameContainer)
	return IEex_ReadWord(CGameContainer + 0x5CA, 0)
end

function IEex_GetGroundPilesAroundActor(actorID)

	local toReturn = {}
	local panic = false

	local share = IEex_GetActorShare(actorID)
	local area = nil

	if share ~= 0x0 then
		area = IEex_ReadDword(share + 0x12)
		if area == 0x0 then
			panic = true
		end
	else
		panic = true
	end

	if panic then
		-- Actor is invalid, panic and use the area's AI runner just to have a valid object
		actorID = IEex_ReadDword(IEex_GetVisibleArea() + 0x41A) -- m_nAIIndex
		share = IEex_GetActorShare(actorID)
		area = IEex_ReadDword(share + 0x12)
	end

	local actorX, actorY = IEex_GetActorLocation(actorID)
	local m_lVertSortBack = area + 0x9AE

	local defaultContainerID = -1

	if not panic then

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
		end)

		table.sort(toReturn, function(a, b)
			return a.distance < b.distance
		end)
	else
		IEex_IterateCPtrList(m_lVertSortBack, function(containerID)

			local containerShare = IEex_GetActorShare(containerID)
			if containerShare == 0x0 then return end
			if IEex_ReadByte(containerShare + 0x4, 0) ~= 0x11 then return end

			defaultContainerID = containerID
			return true -- break loop
		end)
	end

	if defaultContainerID == -1 then
		defaultContainerID = IEex_Call(0x5B75C0, {actorID}, IEex_GetGameData(), 0x0)
	end

	toReturn.defaultContainerID = defaultContainerID
	return toReturn
end

------------------------------
-- /END Container Functions --
------------------------------

function IEex_MapCHU(chuWrapper)

	local chuData = chuWrapper:getData()

	local panelIDToAddress = {}
	local panelIDToControlIDToAddress = {}

	local curPanelAddress = chuData + IEex_ReadDword(chuData + 0x10)
	local numPanels = IEex_ReadDword(chuData + 0x8)

	for i = 1, numPanels do

		local panelID = IEex_ReadWord(curPanelAddress, 0)
		panelIDToAddress[panelID] = curPanelAddress

		local controlIDToAddress = {}
		panelIDToControlIDToAddress[panelID] = controlIDToAddress

		local firstControlIndex = IEex_ReadWord(curPanelAddress + 0x18)
		local currentListingIndex = chuData + IEex_ReadDword(chuData + 0xC) + (firstControlIndex * 0x8)
		local numControls = IEex_ReadWord(curPanelAddress + 0xE)

		for j = 1, numControls do
			local currentControlAddress = chuData + IEex_ReadDword(currentListingIndex)
			local controlID = IEex_ReadWord(currentControlAddress)
			controlIDToAddress[controlID] = currentControlAddress
			currentListingIndex = currentListingIndex + 0x8
		end

		curPanelAddress = curPanelAddress + 0x1C
	end

	chuWrapper.getPanel = function(panelID)
		return panelIDToAddress[panelID]
	end

	chuWrapper.getControl = function(panelID, controlID)
		return (panelIDToControlIDToAddress[panelID] or {})[controlID]
	end
end

-----------------------
-- General Variables --
-----------------------

IEex_WorldScreenSpellInfoPanelID = 50
IEex_ActionIndicatorsPanelID = 100
IEex_AllWorldScreenPanelIDs = {0, 1, 7, 8, 9, 6, 17, 19, 21, 22}
if not IEex_Vanilla then
	table.insert(IEex_AllWorldScreenPanelIDs, 23) -- Quickloot
	table.insert(IEex_AllWorldScreenPanelIDs, IEex_WorldScreenSpellInfoPanelID)
	table.insert(IEex_AllWorldScreenPanelIDs, IEex_ActionIndicatorsPanelID)
end

IEex_Helper_InitBridgeFromTable("IEex_ActionIndicators", {
	[0] = { [0] = nil, [1] = nil, [2] = nil },
	[1] = { [0] = nil, [1] = nil, [2] = nil	},
	[2] = { [0] = nil, [1] = nil, [2] = nil	},
	[3] = { [0] = nil, [1] = nil, [2] = nil },
	[4] = { [0] = nil, [1] = nil, [2] = nil },
	[5] = { [0] = nil, [1] = nil, [2] = nil },
})

IEex_ActionIndicators_PanelHeight = 31

IEex_ActionIndicators_PrimarySlotSize = 30
IEex_ActionIndicators_PrimarySlotOffsetX = 46 - IEex_ActionIndicators_PrimarySlotSize
IEex_ActionIndicators_PrimarySlotOffsetY = -IEex_ActionIndicators_PrimarySlotSize
IEex_ActionIndicators_PrimarySlotInset = 3
IEex_ActionIndicators_PrimarySlotDimension = IEex_ActionIndicators_PrimarySlotSize - 2 * IEex_ActionIndicators_PrimarySlotInset

IEex_ActionIndicators_SecondarySlotSize = 16
IEex_ActionIndicators_SecondarySlotOffsetX = 0
IEex_ActionIndicators_SecondarySlotOffsetY = -IEex_ActionIndicators_SecondarySlotSize

IEex_ActionIndicators_TertiarySlotSize = 16
IEex_ActionIndicators_TertiarySlotOffsetX = 0
IEex_ActionIndicators_TertiarySlotOffsetY = IEex_ActionIndicators_SecondarySlotOffsetY - IEex_ActionIndicators_TertiarySlotSize

IEex_ActionIndicators_PreviousIconsBuffer = {
	[0] = {}, [1] = {}, [2] = {},
	[3] = {}, [4] = {}, [5] = {},
}
IEex_ActionIndicators_PreviousIconsBufferSize = 2
IEex_ActionIndicators_MovementDelay = 2

IEex_NewScope(function()
	for i = 0, 5 do
		local buffer = IEex_ActionIndicators_PreviousIconsBuffer[i]
		buffer.movementDelayCounter = 0
		for j = 1, IEex_ActionIndicators_PreviousIconsBufferSize do
			buffer[j] = {}
		end
	end
end)

--------------------------------
-- Action Indicator Functions --
--------------------------------

function IEex_ActionIndicators_Show()
	local panel = IEex_ActionIndicators_GetPanel()
	IEex_SetPanelActive(panel, true)
end

function IEex_ActionIndicators_Hide()
	local panel = IEex_ActionIndicators_GetPanel()
	IEex_SetPanelActive(panel, false)
end

function IEex_ActionIndicators_GetPanel()
	return IEex_GetPanelFromEngine(IEex_GetEngineWorld(), IEex_ActionIndicatorsPanelID)
end

function IEex_ActionIndicators_GetCursorIndexIcons(cursorIndex)
	-- cursorIndex ==  0 -> AR6051, stones
	-- cursorIndex ==  2 -> AR1200, shield watched by soldier
	-- cursorIndex ==  8 -> AR2001, gate mechanism
	-- cursorIndex == 12 -> AR2000, logs
	-- cursorIndex == 20 -> AR6201, magic barrier
	-- cursorIndex == 22 -> AR3000, fortress main gate
	-- cursorIndex == 28 -> AR5100, pit
	-- cursorIndex == 32 -> AR6003, hidden container
	-- cursorIndex == 34 -> AR6001, unknown condition
	return {
		{"STONSLOT", 0, 0},
		{"B3INDCUR", cursorIndex + 1, 0, IEex_ActionIndicators_PrimarySlotDimension, IEex_ActionIndicators_PrimarySlotDimension},
	}
end

function IEex_ActionIndicators_GetAction(sprite)

	local action = IEex_GetObjectCurrentAction(sprite)
	local actionID = IEex_GetSpriteRealCurrentActionID(sprite)

	-- MoveToPoint, SmallWait
	if actionID == 23 or actionID == 83 then
		-- Hack to detect player-issued ProtectPoint
		local pendingActionNode = IEex_ReadDword(sprite + 0x416)
		if pendingActionNode ~= 0x0 then
			action = IEex_ReadDword(pendingActionNode + 0x8)
			actionID = IEex_GetActionID(action)
		end
	end

	return action, actionID
end

function IEex_ActionIndicators_GetPrimaryIcons(sprite, action, actionID)

	-- Spell, SpellPoint, ForceSpell, ForceSpellPoint, SpellNoDec, SpellPointNoDec
	if IEex_IsActionIDSpellCast(actionID) then

		local spellResref = IEex_GetObjectSpellRES(sprite)
		if spellResref == nil then return end

		if spellResref == "SPIN108" then
			 -- Animal Empathy
			return {{"GUIBTACT", 0, 124}}
		end

		return {
			{"STONSLOT", 0, 0},
			{IEex_GetSpellIconResref(spellResref), 0, 0, IEex_ActionIndicators_PrimarySlotDimension, IEex_ActionIndicators_PrimarySlotDimension},
		}

	-- UseItem, UseItemPoint
	elseif IEex_IsActionIDItemUse(actionID) then

		local slotNum, item, abilityNum = IEex_Helper_GetUseItemFields(sprite)
		if slotNum == nil then return end

		-- Read item ability icon
		if item ~= 0x0 then
			IEex_DemandCItem(item)
			local ability = IEex_GetCItemAbilityNum(item, abilityNum)
			if ability == 0x0 then
				IEex_DecrementCItemDemands(item)
				return
			end
			local abilityIcon = IEex_ReadLString(ability + 0x4, 8)
			IEex_DecrementCItemDemands(item)
			return {
				{"STONSLOT", 0, 0},
				{abilityIcon, 1, 0, IEex_ActionIndicators_PrimarySlotDimension, IEex_ActionIndicators_PrimarySlotDimension},
			}
		end

		return

	-- Attack, GroupAttack, AttackNoSound, AttackOneRound, AttackReevaluate
	elseif IEex_IsActionIDAttack(actionID) then

		local slotNum, item, abilityNum, launcherSlotNum, launcherItem = IEex_Helper_GetAttackItemFields(sprite)
		if slotNum == nil then return end

		local toReturn = {{"STONSLOT", 0, 0}}

		-- Read launcher item ability icon
		if launcherItem ~= 0x0 then
			IEex_DemandCItem(launcherItem)
			local launcherAbility = IEex_GetCItemAbilityNum(launcherItem, 0)
			if launcherAbility ~= 0x0 then
				local launcherAbilityIcon = IEex_ReadLString(launcherAbility + 0x4, 8)
				table.insert(toReturn, {launcherAbilityIcon, 1, 0, IEex_ActionIndicators_PrimarySlotDimension, IEex_ActionIndicators_PrimarySlotDimension})
			end
			IEex_DecrementCItemDemands(launcherItem)
		end

		-- Read item ability icon
		if item ~= 0x0 then
			IEex_DemandCItem(item)
			local ability = IEex_GetCItemAbilityNum(item, abilityNum)
			if ability ~= 0x0 then
				local abilityIcon = IEex_ReadLString(ability + 0x4, 8)
				table.insert(toReturn, {abilityIcon, 1, 0, IEex_ActionIndicators_PrimarySlotDimension, IEex_ActionIndicators_PrimarySlotDimension})
			end
			IEex_DecrementCItemDemands(item)
		end

		return toReturn

	-- PickPockets
	elseif actionID == 25 then
		return {
			{"STONSLOT", 0, 0},
			{"B3INDCUR", 41, 0, IEex_ActionIndicators_PrimarySlotDimension, IEex_ActionIndicators_PrimarySlotDimension},
		}
	-- ProtectPoint
	elseif actionID == 27 then

		return {{"GUIBTACT", 0, 0}}

	-- RemoveTraps
	elseif actionID == 28 then
		return {
			{"STONSLOT", 0, 0},
			{"B3INDCUR", 39, 0, IEex_ActionIndicators_PrimarySlotDimension, IEex_ActionIndicators_PrimarySlotDimension},
		}
	-- LeaveArea
	elseif actionID == 91 then
		return {
			{"STONSLOT", 0, 0},
			{"B3INDCUR", 35, 0, IEex_ActionIndicators_PrimarySlotDimension, IEex_ActionIndicators_PrimarySlotDimension},
		}
	-- LeaveAreaName
	elseif actionID == 93 then

		local targetID = IEex_GetActionInt1(action)
		local targetShare = IEex_GetActorShare(targetID)
		if targetShare == 0x0 then return end
		local cursorIndex = IEex_ReadDword(targetShare + 0x5AA)
		return IEex_ActionIndicators_GetCursorIndexIcons(cursorIndex)

	-- UseContainer
	elseif actionID == 112 then
		return {
			{"STONSLOT", 0, 0},
			{"B3INDCUR", 3, 0, IEex_ActionIndicators_PrimarySlotDimension, IEex_ActionIndicators_PrimarySlotDimension},
		}
	-- PlayerDialog
	elseif actionID == 139 then
		return {
			{"STONSLOT", 0, 0},
			{"B3INDCUR", 19, 0, IEex_ActionIndicators_PrimarySlotDimension, IEex_ActionIndicators_PrimarySlotDimension},
		}
	-- OpenDoor
	elseif actionID == 142 then

		local targetID = IEex_GetActionInt1(action)
		local targetShare = IEex_GetActorShare(targetID)
		if targetShare == 0x0 then return end
		local cursorIndex = IEex_ReadDword(targetShare + 0x5C0)
		return IEex_ActionIndicators_GetCursorIndexIcons(cursorIndex)

	-- PickLock
	elseif actionID == 145 then
		return {
			{"STONSLOT", 0, 0},
			{"B3INDCUR", 25, 0, IEex_ActionIndicators_PrimarySlotDimension, IEex_ActionIndicators_PrimarySlotDimension},
		}
	-- BashDoor
	elseif actionID == 148 then
		return {
			{"STONSLOT", 0, 0},
			{"B3INDCUR", 13, 0, IEex_ActionIndicators_PrimarySlotDimension, IEex_ActionIndicators_PrimarySlotDimension},
		}
	end
end

function IEex_ActionIndicators_GetSecondaryIcons(sprite, action, actionID, ignoreMovement)

	local modalState = IEex_GetSpriteModalState(sprite)
	local hasModalStateToDisplay = modalState == 1 or modalState == 2 or modalState == 3
	local hasMoveActionToDisplay = not ignoreMovement and (actionID == 23 or actionID == 84)

	if hasModalStateToDisplay then
		if modalState == 1 then -- BATTLE_SONG
			local bardSongResref = IEex_BardSongIndexToResref(IEex_GetSpriteCurrentBardSongIndex(sprite))
			local bardSongIcon = IEex_GetSpellIconResref(bardSongResref)
			return {
				{"GUIBTBUT", 0, 0, IEex_ActionIndicators_TertiarySlotSize, IEex_ActionIndicators_TertiarySlotSize},
				{bardSongIcon, 0, 0, IEex_ActionIndicators_SecondarySlotSize - 2, IEex_ActionIndicators_SecondarySlotSize - 2},
			}
		elseif modalState == 2 then -- SEARCH
			return {{"GUIBTACT", 0, 36, IEex_ActionIndicators_SecondarySlotSize, IEex_ActionIndicators_SecondarySlotSize}}
		elseif modalState == 3 then -- STEALTH
			return {{"GUIBTACT", 0, 28, IEex_ActionIndicators_SecondarySlotSize, IEex_ActionIndicators_SecondarySlotSize}}
		end
	end

	-- MoveToPoint, Face
	if hasMoveActionToDisplay then
		return {
			{"GUIBTBUT", 0, 0, IEex_ActionIndicators_SecondarySlotSize, IEex_ActionIndicators_SecondarySlotSize},
			{"B3MOVE", 0, 0, IEex_ActionIndicators_SecondarySlotSize - 5, IEex_ActionIndicators_SecondarySlotSize - 5},
		}
	end
end

function IEex_ActionIndicators_GetTertiaryIcons(sprite, action, actionID)

	local modalState = IEex_GetSpriteModalState(sprite)
	local hasModalStateToDisplay = modalState == 1 or modalState == 2 or modalState == 3
	local hasMoveActionToDisplay = actionID == 23 or actionID == 84

	if hasModalStateToDisplay and hasMoveActionToDisplay then
		return {
			{"GUIBTBUT", 0, 0, IEex_ActionIndicators_TertiarySlotSize, IEex_ActionIndicators_TertiarySlotSize},
			{"B3MOVE", 0, 0, IEex_ActionIndicators_TertiarySlotSize - 5, IEex_ActionIndicators_TertiarySlotSize - 5},
		}
	end
end

-- Thread: Async
function IEex_ActionIndicators_Update()

	for portraitI = 0, 5 do

		local sprite = IEex_GetActorShare(IEex_GetActorIDPortrait(portraitI))
		local previousIconsBuffer = IEex_ActionIndicators_PreviousIconsBuffer[portraitI]

		local primaryIcons = nil
		local secondaryIcons = nil
		local tertiaryIcons = nil

		local storeIcons = false

		if IEex_IsObjectSprite(sprite) then

			local action, actionID = IEex_ActionIndicators_GetAction(sprite)
			local noMovementDelay = actionID ~= 23 and actionID ~= 84

			-- Reset the movement delay when a non-movement action is started
			if actionID ~= 0 and noMovementDelay then
				previousIconsBuffer.movementDelayCounter = 0
			end

			-- Slightly delay showing movement actions to prevent flicker on certain player-issued actions
			if not noMovementDelay then
				local delayCount = previousIconsBuffer.movementDelayCounter
				if delayCount < IEex_ActionIndicators_MovementDelay then
					previousIconsBuffer.movementDelayCounter = delayCount + 1
				else
					noMovementDelay = true
				end
			end

			if actionID ~= 0 and noMovementDelay then
				-- Use the action as is
				primaryIcons = IEex_ActionIndicators_GetPrimaryIcons(sprite, action, actionID)
				secondaryIcons = IEex_ActionIndicators_GetSecondaryIcons(sprite, action, actionID)
				tertiaryIcons = IEex_ActionIndicators_GetTertiaryIcons(sprite, action, actionID)
				storeIcons = true
			else
				-- Attempt to use previous icons
				local previousIcons = nil
				for i = 1, IEex_ActionIndicators_PreviousIconsBufferSize do
					local previousIconsTemp = previousIconsBuffer[i]
					if previousIconsTemp.valid then
						previousIcons = previousIconsTemp
						break
					end
				end

				if previousIcons ~= nil then
					primaryIcons = previousIcons[1]
					secondaryIcons = IEex_ActionIndicators_GetSecondaryIcons(sprite, action, actionID, true) or previousIcons[2]
					tertiaryIcons = previousIcons[3]
					storeIcons = not noMovementDelay
				else
					primaryIcons = nil
					secondaryIcons = IEex_ActionIndicators_GetSecondaryIcons(sprite, action, actionID)
					tertiaryIcons = nil
				end
			end
		end

		-- Advance the buffers
		for i = IEex_ActionIndicators_PreviousIconsBufferSize, 2, -1 do
			previousIconsBuffer[i] = IEex_Helper_DeepCopy(previousIconsBuffer[i - 1])
		end

		-- Store the resolved icons (or a dummy entry if no icons were resolved)
		local previousIcons = previousIconsBuffer[1]
		if storeIcons then
			previousIcons.valid = true
			previousIcons[1] = primaryIcons
			previousIcons[2] = secondaryIcons
			previousIcons[3] = tertiaryIcons
		else
			previousIcons.valid = false
			previousIcons[1] = nil
			previousIcons[2] = nil
			previousIcons[3] = nil
		end

		local portraitBridge = IEex_Helper_GetBridge("IEex_ActionIndicators", portraitI)
		IEex_Helper_SetBridge(portraitBridge, 0, primaryIcons)
		IEex_Helper_SetBridge(portraitBridge, 1, secondaryIcons)
		IEex_Helper_SetBridge(portraitBridge, 2, tertiaryIcons)

		local actionIndicatorsPanel = IEex_ActionIndicators_GetPanel()
		IEex_SetControlActive(IEex_GetControlFromPanel(actionIndicatorsPanel, portraitI * 3    ), primaryIcons   ~= nil and #primaryIcons   > 0)
		IEex_SetControlActive(IEex_GetControlFromPanel(actionIndicatorsPanel, portraitI * 3 + 1), secondaryIcons ~= nil and #secondaryIcons > 0)
		IEex_SetControlActive(IEex_GetControlFromPanel(actionIndicatorsPanel, portraitI * 3 + 2), tertiaryIcons  ~= nil and #tertiaryIcons  > 0)
	end
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
	local panel = IEex_Quickloot_GetPanel()
	IEex_SetPanelActive(panel, true)
end

function IEex_Quickloot_Hide()
	local panel = IEex_Quickloot_GetPanel()
	IEex_SetPanelActive(panel, false)
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
		if IEex_Quickloot_IsPanelActive() then
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

---------------------------------------
-- World Screen Spell Info Functions --
---------------------------------------

function IEex_LaunchWorldScreenSpellInfo(spellResref)

	local spellWrapper = IEex_DemandRes(spellResref, "SPL")
	if not spellWrapper:isValid() then
		return
	end

	local worldScreen = IEex_GetEngineWorld()
	local newSpellInfoPanel = IEex_GetPanelFromEngine(worldScreen, IEex_WorldScreenSpellInfoPanelID)

	local spellData = spellWrapper:getData()
	local spellName = IEex_FetchString(IEex_ReadDword(spellData + 0x8))
	local spellDesc = IEex_FetchString(IEex_ReadDword(spellData + 0x50))
	spellWrapper:free()

	local nameLabel = IEex_GetControlFromPanel(newSpellInfoPanel, 1)
	IEex_SetControlLabelText(nameLabel, spellName)

	local iconControl = IEex_GetControlFromPanel(newSpellInfoPanel, 2)
	IEex_SetControlButtonMageSpellInfoIcon(iconControl, spellResref)
	IEex_SetPanelActive(newSpellInfoPanel, true)

	local descTextDisplay = IEex_GetControlFromPanel(newSpellInfoPanel, 3)
	IEex_SetControlTextDisplay(descTextDisplay, spellDesc)
end

function IEex_StopWorldScreenSpellInfo()
	local worldScreen = IEex_GetEngineWorld()
	local newSpellInfoPanel = IEex_GetPanelFromEngine(worldScreen, IEex_WorldScreenSpellInfoPanelID)
	if IEex_IsPanelActive(newSpellInfoPanel) then
		IEex_SetPanelActive(newSpellInfoPanel, false)
		IEex_InvalidatePanelUIManager(newSpellInfoPanel)
	end
end

---------------
-- Listeners --
---------------

function IEex_GuiKeyPressedListener(key)
	local worldScreen = IEex_GetEngineWorld()
	if IEex_GetActiveEngine() == worldScreen then
		if key == IEex_KeyIDS.ESC then
			IEex_StopWorldScreenSpellInfo()
		end
	end
end

function IEex_GuiRegisterListeners()
	if IEex_Vanilla then return end
	IEex_AddKeyPressedListener("IEex_GuiKeyPressedListener")
	IEex_AddKeyPressedListener("IEex_Hotkeys_KeyPressedListener")
end

function IEex_GuiReloadListener()
	IEex_GuiRegisterListeners()
	IEex_ReaddReloadListener("IEex_GuiReloadListener")
end

IEex_AbsoluteOnce("IEex_GuiInitListeners", function()
	IEex_GuiRegisterListeners()
	IEex_AddReloadListener("IEex_GuiReloadListener")
end)

------------------------
-- GUI Hook Functions --
------------------------

function IEex_IsPanelBlockingViewport(panel, nCursorX, nCursorY)
	if not IEex_IsPanelActive(panel) then return false end
	if IEex_PanelHasBackground(panel) then
		return IEex_IsPointOverPanel(panel, nCursorX, nCursorY)
	else
		local result = false
		IEex_IteratePanelControls(panel, function(control)
			result = IEex_IsControlActiveForRender(control) and IEex_IsPointOverControl(control, nCursorX, nCursorY)
			return result
		end)
		return result
	end
end

function IEex_IsUIBlockingViewport(nCursorX, nCursorY)
	local worldScreen = IEex_GetEngineWorld()
	if IEex_GetActiveEngine() == worldScreen and not IEex_IsEngineUIManagerHidden(worldScreen) then
		for _, i in ipairs(IEex_AllWorldScreenPanelIDs) do
			if IEex_IsPanelBlockingViewport(IEex_GetPanelFromEngine(worldScreen, i), nCursorX, nCursorY) then
				return true
			end
		end
	end
	return false
end

function IEex_MouseInViewport(CInfinity, nCursorX, nCursorY)

	if IEex_IsUIBlockingViewport(nCursorX, nCursorY) then
		return false
	end

	local rViewPortLeft, rViewPortTop, rViewPortRight, rViewPortBottom = IEex_GetViewportRectFromCInfinity(CInfinity)
	return nCursorX >= rViewPortLeft and nCursorX < rViewPortRight
	   and nCursorY >= rViewPortTop  and nCursorY < rViewPortBottom
end

function IEex_MoveHighResolutionPaddingPanels()

	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	panelLeft_st = g_pBaldurChitin + 0x49B4
	panelRight_st = g_pBaldurChitin + 0x49D0
	panelTop_st = g_pBaldurChitin + 0x49EC
	panelBottom_st = g_pBaldurChitin + 0x4A08

	local getMosWidthHeight = function(resref)
		local wrapper = IEex_DemandRes(resref, "MOS")
		local data = wrapper:getData()
		local w = IEex_ReadWord(data + 0x8)
		local h = IEex_ReadWord(data + 0xA)
		wrapper:free()
		return w, h
	end

	local leftW, leftH = getMosWidthHeight("STON10L")
	local rightW, rightH = getMosWidthHeight("STON10R")
	local topW, topH = getMosWidthHeight("STON10T")
	local bottomW, bottomH = getMosWidthHeight("STON10B")

	local resW, resH = IEex_GetResolution()
	local baseResolutionW = 800
	local baseResolutionH = 600

	IEex_WriteWord(panelLeft_st + 0x4, (resW - baseResolutionW) / 2 - leftW)
	IEex_WriteWord(panelLeft_st + 0x6, (resH - leftH) / 2)
	IEex_WriteWord(panelLeft_st + 0x8, leftW)
	IEex_WriteWord(panelLeft_st + 0xA, leftH)

	IEex_WriteWord(panelRight_st + 0x4, (resW + baseResolutionW) / 2)
	IEex_WriteWord(panelRight_st + 0x6, (resH - rightH) / 2)
	IEex_WriteWord(panelRight_st + 0x8, rightW)
	IEex_WriteWord(panelRight_st + 0xA, rightH)

	IEex_WriteWord(panelTop_st + 0x4, (resW - topW) / 2)
	IEex_WriteWord(panelTop_st + 0x6, (resH - baseResolutionH) / 2 - topH)
	IEex_WriteWord(panelTop_st + 0x8, topW)
	IEex_WriteWord(panelTop_st + 0xA, topH)

	IEex_WriteWord(panelBottom_st + 0x4, (resW - bottomW) / 2)
	IEex_WriteWord(panelBottom_st + 0x6, (resH + baseResolutionH) / 2)
	IEex_WriteWord(panelBottom_st + 0x8, bottomW)
	IEex_WriteWord(panelBottom_st + 0xA, bottomH)
end

------------------
-- Thread: Sync --
------------------

function IEex_Extern_BeforeWorldRender()

	IEex_AssertThread(IEex_Thread.Sync, true)

	local worldScreen = IEex_GetEngineWorld()

	------------------------------------------------
	-- Worldscreen spell info position processing --
	------------------------------------------------

	if not IEex_Vanilla then

		local newSpellInfoPanel = IEex_GetPanelFromEngine(worldScreen, IEex_WorldScreenSpellInfoPanelID)

		if IEex_IsPanelActive(newSpellInfoPanel) then

			local rViewPortLeft, rViewPortTop, rViewPortRight, rViewPortBottom = IEex_GetViewportRect()
			local _, _, panelWidth, panelHeight = IEex_GetPanelArea(newSpellInfoPanel)
			local centeredX = rViewPortLeft + (rViewPortRight - rViewPortLeft) / 2 - panelWidth / 2
			local centeredY = math.max(0, rViewPortTop + (IEex_GetMainViewportBottom() - rViewPortTop) / 2 - panelHeight / 2)

			IEex_SetPanelXY(newSpellInfoPanel, centeredX, centeredY)
			IEex_PanelInvalidate(newSpellInfoPanel)
		end
	end

	--------------------------------------------
	-- Action Indicators show/hide processing --
	--------------------------------------------

	if IEex_Helper_GetBridge("IEex_Options", "options", "actionIndicators") then

		local panel1 = IEex_GetPanelFromEngine(worldScreen, 1)
		local actionIndicatorsPanel = IEex_GetPanelFromEngine(worldScreen, IEex_ActionIndicatorsPanelID)

		if IEex_IsPanelActive(panel1) then

			local _, panel1Y = IEex_GetPanelArea(panel1)
			local _, _, _, panelHeight = IEex_GetPanelArea(actionIndicatorsPanel)
			IEex_SetPanelXY(actionIndicatorsPanel, nil, panel1Y - panelHeight + 3)

			if not IEex_IsPanelActive(actionIndicatorsPanel) then
				IEex_ActionIndicators_Show()
			end

		elseif IEex_IsPanelActive(actionIndicatorsPanel) then
			IEex_ActionIndicators_Hide()
		end
	end

	------------------------------------
	-- Quickloot show/hide processing --
	------------------------------------

	if IEex_Helper_GetBridge("IEex_Quickloot", "on") then

		local quicklootPanel = IEex_GetPanelFromEngine(worldScreen, 23)

		if IEex_IsPanelActive(quicklootPanel) and (
			   IEex_IsPanelActive(IEex_GetPanelFromEngine(worldScreen, 6))  -- Debug Console
			or IEex_IsPanelActive(IEex_GetPanelFromEngine(worldScreen, 7))  -- Dialog
			or IEex_IsPanelActive(IEex_GetPanelFromEngine(worldScreen, 8))) -- Container
		then
			IEex_Quickloot_Hide()
		elseif IEex_IsPanelActive(IEex_GetPanelFromEngine(worldScreen, 1)) then -- Main Panel
			IEex_Quickloot_Show()
		end

		local _, _, _, panelHeight = IEex_GetPanelArea(quicklootPanel)
		IEex_SetPanelXY(quicklootPanel, nil, IEex_GetMainViewportBottom(true) - panelHeight)
	end

	---------------------------------------
	-- Invalidate all worldscreen panels --
	-- (so they render above viewport)   --
	---------------------------------------

	for _, i in ipairs(IEex_AllWorldScreenPanelIDs) do
		local panel = IEex_GetPanelFromEngine(worldScreen, i)
		if IEex_IsPanelActive(panel) or IEex_IsPanelInactiveRender(panel) then
			IEex_PanelInvalidate(panel)
		end
	end

	-------------------------------------------------------------------
	-- Adjust viewport if a panel state change exposed out-of-bounds --
	-------------------------------------------------------------------

	IEex_CheckViewPosition()
end

function IEex_Extern_OverrideWorldScreenScrollbarFocus()

	IEex_AssertThread(IEex_Thread.Sync, true)

	local worldScreen = IEex_GetEngineWorld()
	local newSpellInfoPanel = IEex_GetPanelFromEngine(worldScreen, IEex_WorldScreenSpellInfoPanelID)

	if IEex_IsPanelActive(newSpellInfoPanel) then
		local descTextDisplayScrollbar = IEex_GetControlFromPanel(newSpellInfoPanel, 4)
		IEex_SetEngineScrollbarFocus(worldScreen, descTextDisplayScrollbar)
		return true
	end

	return false
end

function IEex_Extern_InitResolution()

	IEex_AssertThread(IEex_Thread.Sync, true)

	local nWidth, nHeight = IEex_Helper_AskResolution()
	IEex_WriteWord(0x8BA31C, nWidth)  -- g_resolution.width
	IEex_WriteWord(0x8BA31E, nHeight) -- g_resolution.height
	IEex_WritePrivateProfileInt("Program Options", "BitsPerPixel", 32, ".\\Icewind2.ini")

	------------------------------------------------------------------
	-- Standardize when the engine non-instantaneously auto-scrolls --
	-- to dialog to just outside of viewport range                  --
	------------------------------------------------------------------

	IEex_DisableCodeProtection()

	local maxNonInstantRange = math.pow(nWidth / 2, 2) + math.pow(nHeight / 2, 2)
	IEex_WriteDword(0x484BA2, maxNonInstantRange)
	IEex_HookRestore(0x6902D4, 3, 2, {"!mov_ecx", {maxNonInstantRange, 4}})

	IEex_EnableCodeProtection()
end

function IEex_Extern_CheckBitDepth()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local nBitDepth = IEex_ReadWord(g_pBaldurChitin + 0x7EA)
	if nBitDepth ~= 32 then
		IEex_MessageBox("Error: Unable to find a display mode at the target resolution with a 32-bit color depth.\n\nThe game will exit after you press OK...")
		return false
	end
	return true
end

function IEex_Extern_InitGUIConstants()
	IEex_AssertThread(IEex_Thread.Sync, true)
	local resW, resH = IEex_GetResolution()
	IEex_SetCRect(0x8E7548, 0, 0, resW, resH) -- WorldScreenInterfaceHiddenViewPortRect
	IEex_SetCRect(0x8E79B8, 0, 0, resW, resH) -- WorldScreenCurrentHiddenViewPortRect
	IEex_SetCRect(0x8E7958, 0, 0, resW, resH) -- WorldScreenDialogViewPortRect
	IEex_SetCRect(0x8E7988, 0, 0, resW, resH) -- WorldScreenDeathViewPortRect
	IEex_WriteDword(0x8E79D4, resH)           -- WorldScreenConsoleBottom
	IEex_WriteDword(0x8E79EC, resH)           -- WorldScreenToolbarBottom
	IEex_SetCRect(0x8E79F8, 0, 0, resW, resH) -- WorldScreenContainerViewPortRect
end

function IEex_Extern_InitHighResolutionPaddingPanels(pBaldurChitin)

	IEex_AssertThread(IEex_Thread.Sync, true)

	local resW, resH = IEex_GetResolution()

	-- If the selected resolution can't display the
	-- high-resolution padding panels, remove them.
	if resW < 1024 or resH < 768 then

		IEex_DisableCodeProtection()

		-- Wipe out the hardcoded panel definitions. This is overkill, but they deserve it.
		IEex_Helper_Memset(pBaldurChitin + 0x49B4, 0, 4 * 0x1C)

		-- Common panels are disabled - skip code that assumes they are there.
		-- Note: Multiplayer panels HAVE NOT BEEN FIXED because IWD2:EE doesn't
		-- support Multiplayer.
		IEex_WriteAssembly(0x5DBC09, {"!jmp_byte"})
		IEex_WriteAssembly(0x5FEDE9, {"!jmp_byte"})
		IEex_WriteAssembly(0x607B57, {"!jmp_byte"})
		IEex_WriteAssembly(0x626D59, {"!jmp_byte"})
		IEex_WriteAssembly(0x63DBA9, {"!jmp_byte"})
		IEex_WriteAssembly(0x641789, {"!jmp_byte"})
		IEex_WriteAssembly(0x654F19, {"!jmp_byte"})
		IEex_WriteAssembly(0x65CF09, {"!jmp_byte"})
		IEex_WriteAssembly(0x661D29, {"!jmp_byte"})
		IEex_WriteAssembly(0x66A854, {"!jmp_byte"})
		IEex_WriteAssembly(0x672EED, {"!jmp_byte"})

		IEex_EnableCodeProtection()
	end
end

-------------------
-- Thread: Async --
-------------------

function IEex_Extern_MouseInAreaViewport(CGameArea)

	IEex_AssertThread(IEex_Thread.Async, true)

	if IEex_GetActiveEngine() ~= IEex_GetEngineWorld() then
		return false
	end

	local nCursorX = IEex_ReadDword(CGameArea + 0x256)
	local nCursorY = IEex_ReadDword(CGameArea + 0x25A)
	return IEex_MouseInViewport(IEex_GetCInfinityFromArea(CGameArea), nCursorX, nCursorY)
end

function IEex_Extern_RejectGetWorldCoordinates(CInfinity, x, y)
	IEex_AssertThread(IEex_Thread.Async, true)
	return IEex_IsUIBlockingViewport(x, y)
end

function IEex_Extern_OnActionbarUnhandledRButtonClick(nIndex)
	IEex_AssertThread(IEex_Thread.Async, true)
	local nState = IEex_GetActionbarState()
	if nState == 0x66 or nState == 0x67 or nState == 0x6A or nState == 0x6B then
		local nButtonType = IEex_GetActionbarButtonType(nIndex)
		if nButtonType >= 0x15 and nButtonType <= 0x20 then
			local nScrollIndex = IEex_GetActionbarScrollIndex()
			local nSpellButtonIndex = nScrollIndex + (nButtonType - 0x15)
			local buttonData = IEex_GetAtCPtrListIndex(IEex_GetCurrentActionbarQuickButtons(), nSpellButtonIndex)
			if not buttonData then return end
			local resref = IEex_ReadLString(buttonData + 0x1A + 0x6, 8) -- CButtonData.m_abilityId.m_res
			IEex_LaunchWorldScreenSpellInfo(resref)
		end
	end
end

function IEex_Extern_RejectWorldScreenEsc()
	IEex_AssertThread(IEex_Thread.Async, true)
	local newSpellInfoPanel = IEex_GetPanelFromEngine(IEex_GetEngineWorld(), IEex_WorldScreenSpellInfoPanelID)
	return IEex_IsPanelActive(newSpellInfoPanel)
end

function IEex_Extern_StartDebugConsole()
	IEex_AssertThread(IEex_Thread.Async, true)
	local worldScreen = IEex_GetEngineWorld()
	local panel1 = IEex_GetPanelFromEngine(worldScreen, 1)
	IEex_SetPanelActive(panel1, false)
end

function IEex_Extern_StopDebugConsole()
	IEex_AssertThread(IEex_Thread.Async, true)
	local worldScreen = IEex_GetEngineWorld()
	local panel1 = IEex_GetPanelFromEngine(worldScreen, 1)
	IEex_SetPanelActive(panel1, true)
end

------------------
-- Thread: Both --
------------------

function IEex_Extern_OnSetActionbarState(nState)
	IEex_AssertThread(IEex_Thread.Both, true)
	if IEex_GetGameData() == 0x0 then return end
end

IEex_TooltipKillReason = {
	UNKNOWN = 0,
	EFFECT_LIST_UPDATE = 1,
}

function IEex_Extern_ShouldTooltipRefreshInsteadOfDying(killReason)
	IEex_AssertThread(IEex_Thread.Both, true)
	return killReason == IEex_TooltipKillReason.EFFECT_LIST_UPDATE
end

function IEex_Extern_CUIManager_fInit_CHUInitialized(CUIManager, resrefPointer)

	IEex_AssertThread(IEex_Thread.Both, true)
	local resref = IEex_ReadLString(resrefPointer, 8)

	IEex_OnCHUInitialized(resref)

	if not IEex_Vanilla then

		local resrefOverride = IEex_Helper_GetBridge("IEex_GUIConstants", "panelActiveByDefault", resref)
		if not resrefOverride then return end

		IEex_Helper_IterateBridge(resrefOverride, function(panelID, active)
			local panel = IEex_GetPanel(CUIManager, panelID)
			if panel ~= 0x0 then
				IEex_SetPanelActive(panel, active)
			end
		end)
	end
end

function IEex_Extern_CUIControlBase_CreateControl(resrefPointer, panel, controlInfo)

	IEex_AssertThread(IEex_Thread.Both, true)

	local resref = IEex_ReadLString(resrefPointer, 8)
	local panelID = IEex_ReadDword(panel + 0x20)
	local controlID = IEex_ReadDword(controlInfo)

	-- Hack to get the chargen animation preview control to call its TimerAsynchronousUpdate() every tick
	if resref == "GUICG" and panelID == 13 and controlID == 1 then
		local flagsAddress = controlInfo + 0xD
		IEex_WriteByte(flagsAddress, IEex_SetBit(IEex_ReadByte(flagsAddress), 0))
	end

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

-------------------
-- GUI Additions --
-------------------

IEex_Helper_InitBridgeFromTable("IEex_GUIConstants", {

	["panelActiveByDefault"] = {
		["GUIW08"] = {
			[23] = false,
			[IEex_ActionIndicatorsPanelID] = false,
		},
		["GUIW10"] = {
			[23] = false,
			[IEex_ActionIndicatorsPanelID] = false,
		},
	},

	["controlTypeMeta"] = {
		["ButtonWorldContainerSlot"] = { ["constructor"] = 0x6956F0, ["size"] = 0x666 },
		["ButtonMageSpellInfoIcon"] =  { ["constructor"] = 0x66E3A0, ["size"] = 0x676 },
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
		for i = vftableAddress, vftableAddress + vftableSize - 0x4, 0x4 do
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
			!mark_esp
			!push(esi)
			!mov(esi,ecx)
			!marked_esp !push([esp+8]) ; pControlInfo ;
			!marked_esp !push([esp+4]) ; pPanel ;
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
			!call :4E1A90 ; CUIControlTextDisplay_Construct ;
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
			!call :4E47C0 ; CUIControlTextDisplay_Construct ;
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

IEex_ControlStructTypeLength = {
	[IEex_ControlStructType.BUTTON]     = 0x20,
	[IEex_ControlStructType.UNKNOWN1]   = 0xE,
	[IEex_ControlStructType.SLIDER]     = 0x34,
	[IEex_ControlStructType.TEXT_FIELD] = 0x6A,
	[IEex_ControlStructType.UNKNOWN2]   = 0xE,
	[IEex_ControlStructType.TEXT_AREA]  = 0x2E,
	[IEex_ControlStructType.LABEL]      = 0x24,
	[IEex_ControlStructType.SCROLL_BAR] = 0x28,
}

function IEex_AddControlStToPanel(CUIPanel, UI_Control_st)
	IEex_Call(0x4D2AE0, {UI_Control_st}, CUIPanel, 0x0)
end

function IEex_AddControlToPanel(CUIPanel, args)

	local type = args.type
	if not type then IEex_Error("type must be defined") end

	local typeLength = IEex_ControlStructTypeLength[type]
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

	IEex_AddControlStToPanel(CUIPanel, UI_Control_st)
	IEex_Free(UI_Control_st)

	local control = IEex_GetControlFromPanel(CUIPanel, args.id)

	IEex_WriteArgs(control, args, {
		{ "tooltipStrref",   0x3E, IEex_WriteType.DWORD, IEex_WriteFailType.NOTHING },
		{ "hotkeyHintIndex", 0x4A, IEex_WriteType.WORD,  IEex_WriteFailType.NOTHING },
	})

	local customHotkeyHintIndex = args["customHotkeyHintIndex"]
	if customHotkeyHintIndex ~= nil then
		IEex_SetControlCustomHotkeyHintIndex(control, customHotkeyHintIndex)
	end

	if type == IEex_ControlStructType.BUTTON then
		local playLButtonDownSound = args["playLButtonDownSound"]
		if playLButtonDownSound ~= nil then
			IEex_SetControlButtonPlayLButtonDownSound(control, playLButtonDownSound)
		end
	end
end

function IEex_ReadControlSt(UI_Control_st)

	local toReturn = {}

	IEex_FillArgs(toReturn, UI_Control_st, {
		{ "id",           0x0, IEex_ReadType.WORD },
		{ "bufferLength", 0x2, IEex_ReadType.WORD },
		{ "x",            0x4, IEex_ReadType.WORD },
		{ "y",            0x6, IEex_ReadType.WORD },
		{ "width",        0x8, IEex_ReadType.WORD },
		{ "height",       0xA, IEex_ReadType.WORD },
		{ "type",         0xC, IEex_ReadType.BYTE },
		{ "unknown",      0xD, IEex_ReadType.BYTE },
	})

	local type = toReturn.type
	if type == IEex_ControlStructType.BUTTON then
		IEex_FillArgs(toReturn, UI_Control_st, {
			{ "bam",              0xE,  IEex_ReadType.RESREF },
			{ "sequence",         0x16, IEex_ReadType.BYTE   },
			{ "textFlags",        0x17, IEex_ReadType.BYTE   },
			{ "frameUnpressed",   0x18, IEex_ReadType.BYTE   },
			{ "textAnchorLeft",   0x19, IEex_ReadType.BYTE   },
			{ "framePressed",     0x1A, IEex_ReadType.BYTE   },
			{ "textAnchorRight",  0x1B, IEex_ReadType.BYTE   },
			{ "frameSelected",    0x1C, IEex_ReadType.BYTE   },
			{ "textAnchorTop",    0x1D, IEex_ReadType.BYTE   },
			{ "frameDisabled",    0x1E, IEex_ReadType.BYTE   },
			{ "textAnchorBottom", 0x1F, IEex_ReadType.BYTE   },
		})
	elseif type == IEex_ControlStructType.LABEL then
		IEex_FillArgs(toReturn, UI_Control_st, {
			{ "initialTextStrref", 0xE,  IEex_ReadType.DWORD  },
			{ "fontBam",           0x12, IEex_ReadType.RESREF },
			{ "fontColor1",        0x1A, IEex_ReadType.DWORD  },
			{ "fontColor2",        0x1E, IEex_ReadType.DWORD  },
			{ "textFlags",         0x22, IEex_ReadType.WORD   },
		})
	elseif type == IEex_ControlStructType.TEXT_AREA then
		IEex_FillArgs(toReturn, UI_Control_st, {
			{ "fontBam",         0xE,  IEex_ReadType.RESREF },
			{ "fontBamInitials", 0x16, IEex_ReadType.RESREF },
			{ "fontColor1",      0x1E, IEex_ReadType.DWORD  },
			{ "fontColor2",      0x22, IEex_ReadType.DWORD  },
			{ "fontColor3",      0x26, IEex_ReadType.DWORD  },
			{ "scrollbarID",     0x2A, IEex_ReadType.DWORD  },
		})
	elseif type == IEex_ControlStructType.SCROLL_BAR then
		IEex_FillArgs(toReturn, UI_Control_st, {
			{ "graphicsBam",             0xE  },
			{ "animationNumber",         0x16 },
			{ "upArrowFrameUnpressed",   0x18 },
			{ "upArrowFramePressed",     0x1A },
			{ "downArrowFrameUnpressed", 0x1C },
			{ "downArrowFramePressed",   0x1E },
			{ "troughFrame",             0x20 },
			{ "sliderFrame",             0x22 },
			{ "textAreaID",              0x24 },
		})
	else
		IEex_Error("type unimplemented")
	end

	return toReturn
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

----------------------------------------
-- General Custom UI Control Handlers --
----------------------------------------

------------------
-- Thread: Sync --
------------------

function IEex_Extern_UI_ButtonRender(CUIControlButton, bForceRender)

	IEex_AssertThread(IEex_Thread.Sync, true)

	local panel = IEex_GetControlPanel(CUIControlButton)
	local resref = IEex_GetCHUResrefFromPanel(panel)
	local panelID = IEex_GetPanelID(panel)
	local controlID = IEex_GetControlID(CUIControlButton)

	local renderActionIndicator = function(portraitI, indicatorI)
		return function()
			IEex_Helper_DecrementButtonDoRender(CUIControlButton)
			local sprite = IEex_GetActorShare(IEex_GetActorIDPortrait(portraitI))
			if not IEex_IsObjectSprite(sprite) then return end
			local iconsDataBridge = IEex_Helper_GetBridge("IEex_ActionIndicators", portraitI, indicatorI)
			if iconsDataBridge == nil then return end
			local iconsData = IEex_Helper_ReadDataFromBridge(iconsDataBridge)
			for _, iconData in ipairs(iconsData) do
				local _, _, controlW, controlH = IEex_GetControlArea(CUIControlButton)
				local resref = iconData[1]
				local sequence = iconData[2]
				local frame = iconData[3]
				local width = iconData[4] or controlW
				local height = iconData[5] or controlH
				local offsetX = iconData[6] or 0
				local offsetY = iconData[7] or 0
				IEex_Helper_RenderButtonIcon(CUIControlButton, resref, sequence, frame, width, height, offsetX, offsetY)
			end
		end
	end

	local worldHandler = {
		[IEex_ActionIndicatorsPanelID] = {
			[0] = renderActionIndicator(0, 0),
			[1] = renderActionIndicator(0, 1),
			[2] = renderActionIndicator(0, 2),
			[3] = renderActionIndicator(1, 0),
			[4] = renderActionIndicator(1, 1),
			[5] = renderActionIndicator(1, 2),
			[6] = renderActionIndicator(2, 0),
			[7] = renderActionIndicator(2, 1),
			[8] = renderActionIndicator(2, 2),
			[9] = renderActionIndicator(3, 0),
			[10] = renderActionIndicator(3, 1),
			[11] = renderActionIndicator(3, 2),
			[12] = renderActionIndicator(4, 0),
			[13] = renderActionIndicator(4, 1),
			[14] = renderActionIndicator(4, 2),
			[15] = renderActionIndicator(5, 0),
			[16] = renderActionIndicator(5, 1),
			[17] = renderActionIndicator(5, 2),
		},
	}

	local handlers = {
		["GUIW08"] = worldHandler,
		["GUIW10"] = worldHandler,
	}

	local handle = function()

		local resrefHandler = handlers[resref]
		if not resrefHandler then return end
		local panelHandler = resrefHandler[panelID]
		if not panelHandler then return end
		local controlHandler = panelHandler[controlID]
		if not controlHandler then return end

		if
			not IEex_IsControlActiveForRender(CUIControlButton)
			or not IEex_ShouldControlButtonRender(CUIControlButton, bForceRender)
		then
			return
		end

		controlHandler()
		return true
	end

	if handle() then return end
	IEex_Call(0x4D5070, {bForceRender}, CUIControlButton, 0x0) -- CUIControlButton_Render()
end

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

	local worldHandler = {
		[0] = {
			[15] = IEex_CScreenWorld_OnQuicklootButtonLClick,
		},
--[[
		[22] = {
			[15] = IEex_CScreenWorld_OnQuicklootButtonLClick,
		},
--]]
		[IEex_WorldScreenSpellInfoPanelID] = {
			[5] = IEex_StopWorldScreenSpellInfo,
		}
	}

	local handlers = {
		["GUICG"] = {
			[4] = {
				[37] = function()
					IEex_Chargen_Reroll()
				end,
				[38] = function()
					local chargenData = IEex_GetEngineCreateChar()
					local share = IEex_GetActorShare(IEex_ReadDword(chargenData + 0x4E2))
					recordedAbilityScores = currentAbilityScores
					recordedUnallocatedAbilityScores = unallocatedAbilityScores
					if ex_new_ability_score_system == 2 then
						ex_recorded_remaining_points = IEex_ReadDword(chargenData + 0x4EA)
					end
					IEex_Chargen_UpdateAbilityScores(chargenData, share)
				end,
				[39] = function()
					local chargenData = IEex_GetEngineCreateChar()
					local share = IEex_GetActorShare(IEex_ReadDword(chargenData + 0x4E2))
					if (recordedAbilityScores[1] > 0 or #recordedUnallocatedAbilityScores > 0) then
						currentAbilityScores = recordedAbilityScores
						unallocatedAbilityScores = recordedUnallocatedAbilityScores
						for i = 1, 6, 1 do
							IEex_WriteByte(share + ex_base_ability_score_cre_offset[i], currentAbilityScores[i])
						end
						if ex_new_ability_score_system == 2 then
							ex_current_remaining_points = ex_recorded_remaining_points
							IEex_WriteDword(chargenData + 0x4EA, ex_current_remaining_points)
						end
					end
					IEex_Chargen_UpdateAbilityScores(chargenData, share)
				end,
				[40] = function()
					local chargenData = IEex_GetEngineCreateChar()
					local share = IEex_GetActorShare(IEex_ReadDword(chargenData + 0x4E2))
					if ex_new_ability_score_system == 1 then
						for i = 1, 6, 1 do
							if currentAbilityScores[i] > 0 then
								table.insert(unallocatedAbilityScores, currentAbilityScores[i] - racialAbilityBonuses[i])
								IEex_WriteByte(share + ex_base_ability_score_cre_offset[i], 0)
--								currentAbilityScores[i] = 0
							end
							table.sort(unallocatedAbilityScores)
						end
					end
					IEex_Chargen_UpdateAbilityScores(chargenData, share)
				end,
			},
		},
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

					if not IEex_Helper_GetBridge("IEex_Options", "options", "actionIndicators") then
						IEex_ActionIndicators_Hide()
					end

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
				-- "Action Indicators" Toggle
				[8] = function()
					local workingOptions = IEex_Helper_GetBridge("IEex_Options", "workingOptions")
					if IEex_Helper_GetBridge(workingOptions, "actionIndicators") then
						IEex_SetControlButtonFrameUp(CUIControlButton, 1)
						IEex_Helper_SetBridge(workingOptions, "actionIndicators", false)
					else
						IEex_SetControlButtonFrameUp(CUIControlButton, 3)
						IEex_Helper_SetBridge(workingOptions, "actionIndicators", true)
					end
				end,
				-- "Highlight Empty Containers in Gray" Toggle
				[10] = function()
					local workingOptions = IEex_Helper_GetBridge("IEex_Options", "workingOptions")
					if IEex_Helper_GetBridge(workingOptions, "highlightEmptyContainersInGray") then
						IEex_SetControlButtonFrameUp(CUIControlButton, 1)
						IEex_Helper_SetBridge(workingOptions, "highlightEmptyContainersInGray", false)
					else
						IEex_SetControlButtonFrameUp(CUIControlButton, 3)
						IEex_Helper_SetBridge(workingOptions, "highlightEmptyContainersInGray", true)
					end
				end,
			},
		},
		["GUIREC"] = {
			[2] = {
				[38] = function()
					if ex_current_record_actorID ~= IEex_GetActorIDCharacter(0) and ex_current_record_actorID ~= 0 then
						IEex_WriteWord(IEex_GetActorShare(ex_current_record_actorID) + 0x476, 21)
					end
				end,
			},
			[58] = {
				[32] = function()
					local screenCharacter = IEex_GetEngineCharacter()
					local newWizardSpellsPanel = IEex_GetPanelFromEngine(screenCharacter, 58)
					for buttonID = 0, 29, 1 do
						local thisButton = IEex_GetControlFromPanel(newWizardSpellsPanel, buttonID)
						IEex_SetControlButtonFrameUpForce(thisButton, 1)
					end
					ex_menu_sorcerer_spells_replaced = {}
					for spellRES, justTaken in pairs(ex_menu_wizard_spells_learned) do
						if justTaken then
							ex_menu_wizard_spells_learned[spellRES] = nil
							ex_menu_num_wizard_spells_remaining = ex_menu_num_wizard_spells_remaining + 1
						end
					end
					ex_menu_num_learned_spells_per_level = {0, 0, 0, 0, 0, 0, 0, 0, 0}
					IEex_SetControlLabelText(IEex_GetControlFromPanel(newWizardSpellsPanel, 34), tostring(ex_menu_num_wizard_spells_remaining))
					ex_menu_in_second_replacement_step = false
					IEex_DisplayWizardSpellsToLearn(ex_current_menu_spell_level)
					IEex_NewWizardSpellsPanelDoneButtonUpdate()
					IEex_PanelInvalidate(newWizardSpellsPanel)
				end,
				[35] = function()
					if IEex_NewWizardSpellsPanelDoneButtonClickable() then
						local screenCharacter = IEex_GetEngineCharacter()
						local characterRecordPanel = IEex_GetPanelFromEngine(screenCharacter, 2)
						local newWizardSpellsPanel = IEex_GetPanelFromEngine(screenCharacter, 58)
						local actorID = IEex_ReadDword(screenCharacter + 0x136)
						if not IEex_IsSprite(actorID, false) then return end

						-- Remove from popup stack
						IEex_Call(0x7FB343, {}, screenCharacter + 0x62A, 0x0) -- CPtrList_RemoveTail()

						IEex_SetPanelActive(newWizardSpellsPanel, false)
						setCommonPanelsEnabled(screenCharacter, true)
						IEex_SetPanelEnabled(characterRecordPanel, true)
						if ex_alternate_spell_menu_class == 11 then
							for spellRES, justTaken in pairs(ex_menu_wizard_spells_learned) do
								if justTaken then
									IEex_ApplyEffectToActor(actorID, {
["opcode"] = 147,
["target"] = 2,
["timing"] = 1,
["resource"] = spellRES,
["source_id"] = actorID
})
								end
							end
						elseif ex_alternate_spell_menu_class == 2 or ex_alternate_spell_menu_class == 10 then
							local share = IEex_GetActorShare(actorID)
							local casterType = IEex_CasterClassToType[ex_alternate_spell_menu_class]
							local currentLevelBase = share + 0x4284 + (casterType - 1) * 0x100
							for level = 1, ex_menu_max_castable_level, 1 do
								local currentEntryBase = IEex_ReadDword(currentLevelBase + 0x4)
								local pEndEntry = IEex_ReadDword(currentLevelBase + 0x8)
								while currentEntryBase ~= pEndEntry do
									local spellRES = IEex_LISTSPLL[IEex_ReadDword(currentEntryBase)]
									if ex_menu_sorcerer_spells_replaced[spellRES] then
										IEex_WriteDword(currentEntryBase,IEex_LISTSPLL_Reverse[ex_menu_sorcerer_spells_replaced[spellRES]])
										for i = 0x360C, 0x37EC, 0x3C do
											if IEex_ReadLString(share + i + 0x20, 8) == spellRES and IEex_ReadByte(share + i + 0x36, 0x0) == ex_alternate_spell_menu_class then
												IEex_WriteLString(share + i, string.sub(ex_menu_sorcerer_spells_replaced[spellRES], 1, 7) .. "B", 8)
												IEex_WriteLString(share + i + 0x20, ex_menu_sorcerer_spells_replaced[spellRES], 8)
											end
										end
									end
									currentEntryBase = currentEntryBase + 0x10
								end
								currentLevelBase = currentLevelBase + 0x1C
							end
						end
					end
				end,
				[36] = function()
					local screenCharacter = IEex_GetEngineCharacter()
					local newWizardSpellsPanel = IEex_GetPanelFromEngine(screenCharacter, 58)
					if ex_current_menu_spell_level > 1 and not ex_menu_in_second_replacement_step then
						ex_current_menu_spell_level = ex_current_menu_spell_level - 1
						IEex_DisplayWizardSpellsToLearn(ex_current_menu_spell_level)
						if ex_alternate_spell_menu_class == 11 then
							for buttonID = 0, 29, 1 do
								local thisButton = IEex_GetControlFromPanel(newWizardSpellsPanel, buttonID)
								local spellResref = ex_menu_available_wizard_spells[ex_current_menu_spell_level][buttonID + 1]
								if not ex_menu_wizard_spells_learned[spellResref] then
									IEex_SetControlButtonFrameUpForce(thisButton, 1)
								else
									IEex_SetControlButtonFrameUpForce(thisButton, 0)
								end
							end
						end
					end
					IEex_PanelInvalidate(newWizardSpellsPanel)
				end,
				[37] = function()
					local screenCharacter = IEex_GetEngineCharacter()
					local newWizardSpellsPanel = IEex_GetPanelFromEngine(screenCharacter, 58)
					local actorID = IEex_ReadDword(screenCharacter + 0x136)
					if not IEex_IsSprite(actorID, false) then return end
					if ex_current_menu_spell_level < ex_menu_max_castable_level and not ex_menu_in_second_replacement_step then
						ex_current_menu_spell_level = ex_current_menu_spell_level + 1
						IEex_DisplayWizardSpellsToLearn(ex_current_menu_spell_level)
						if ex_alternate_spell_menu_class == 11 then
							for buttonID = 0, 29, 1 do
								local thisButton = IEex_GetControlFromPanel(newWizardSpellsPanel, buttonID)
								local spellResref = ex_menu_available_wizard_spells[ex_current_menu_spell_level][buttonID + 1]
								if not ex_menu_wizard_spells_learned[spellResref] then
									IEex_SetControlButtonFrameUpForce(thisButton, 1)
								else
									IEex_SetControlButtonFrameUpForce(thisButton, 0)
								end
							end
						end
					end
--					local thisButton = IEex_GetControlFromPanel(newWizardSpellsPanel, 0)
--					IEex_SetControlButtonFrameUpForce(thisButton, 2)
--[[
					-- Remove from popup stack
					IEex_Call(0x7FB343, {}, screenCharacter + 0x62A, 0x0) -- CPtrList_RemoveTail()

					-- Add to popup stack
					IEex_Call(0x7FBE4E, {newWizardSpellsPanel}, screenCharacter + 0x62A, 0x0) -- CPtrList_AddTail()
--]]
					IEex_PanelInvalidate(newWizardSpellsPanel)
				end,
			},
		},
		["GUIW08"] = worldHandler,
		["GUIW10"] = worldHandler,
	}

	for buttonID = 0, 29, 1 do
		handlers["GUIREC"][58][buttonID] = function()
			local screenCharacter = IEex_GetEngineCharacter()
			local newWizardSpellsPanel = IEex_GetPanelFromEngine(screenCharacter, 58)
			local thisButton = IEex_GetControlFromPanel(newWizardSpellsPanel, buttonID)
			local spellResref = ""
			if ex_alternate_spell_menu_class == 11 then
				spellResref = ex_menu_available_wizard_spells[ex_current_menu_spell_level][buttonID + 1]
			elseif ex_alternate_spell_menu_class == 2 or ex_alternate_spell_menu_class == 10 then
				if not ex_menu_in_second_replacement_step then
					local i = 0
					for spellRES, isKnown in pairs(ex_menu_known_wizard_spells[ex_current_menu_spell_level]) do
						if i == buttonID then
							if not ex_menu_sorcerer_spells_replaced[spellRES] then
								spellResref = spellRES
							else
								spellResref = ex_menu_sorcerer_spells_replaced[spellRES]
							end
						end
						i = i + 1
					end
				else
					spellResref = ex_menu_available_wizard_spells[ex_current_menu_spell_level][buttonID + 1]
					if ex_menu_wizard_spells_learned[spellResref] then
						spellResref = ""
					end
				end
			end
			if not spellResref then return end
			local spellWrapper = IEex_DemandRes(spellResref, "SPL")
			if not spellWrapper:isValid() then
				spellWrapper:free()
				return
			end
			local descTextDisplay = IEex_GetControlFromPanel(newWizardSpellsPanel, 30)
			if ex_alternate_spell_menu_class == 11 then
				if not ex_menu_wizard_spells_learned[spellResref] then
					if (ex_menu_num_known_spells_per_level[ex_current_menu_spell_level] + ex_menu_num_learned_spells_per_level[ex_current_menu_spell_level] + 1) > 24 then
						IEex_SetControlTextDisplay(descTextDisplay, IEex_FetchString(ex_tra_55771))
						spellWrapper:free()
						return
					elseif ex_menu_num_wizard_spells_remaining > 0 then
						ex_menu_wizard_spells_learned[spellResref] = true
						ex_menu_num_learned_spells_per_level[ex_current_menu_spell_level] = ex_menu_num_learned_spells_per_level[ex_current_menu_spell_level] + 1
						ex_menu_num_wizard_spells_remaining = ex_menu_num_wizard_spells_remaining - 1
						IEex_SetControlLabelText(IEex_GetControlFromPanel(newWizardSpellsPanel, 34), tostring(ex_menu_num_wizard_spells_remaining))
						IEex_SetControlButtonFrameUp(thisButton, 0)
					end
				else
					ex_menu_wizard_spells_learned[spellResref] = nil
					ex_menu_num_learned_spells_per_level[ex_current_menu_spell_level] = ex_menu_num_learned_spells_per_level[ex_current_menu_spell_level] - 1
					ex_menu_num_wizard_spells_remaining = ex_menu_num_wizard_spells_remaining + 1
					IEex_SetControlLabelText(IEex_GetControlFromPanel(newWizardSpellsPanel, 34), tostring(ex_menu_num_wizard_spells_remaining))
					IEex_SetControlButtonFrameUp(thisButton, 1)
				end
			elseif ex_alternate_spell_menu_class == 2 or ex_alternate_spell_menu_class == 10 then
				if not ex_menu_in_second_replacement_step then
					if not ex_menu_wizard_spells_learned[spellResref] then
						if ex_menu_num_wizard_spells_remaining > 0 then
							ex_menu_sorcerer_spell_to_replace = spellResref
							ex_menu_in_second_replacement_step = true
							IEex_DisplayWizardSpellsToLearn(ex_current_menu_spell_level)
						end
					else
						for spellRES, replacementRES in pairs(ex_menu_sorcerer_spells_replaced) do
							if replacementRES == spellResref then
								ex_menu_sorcerer_spells_replaced[spellRES] = nil
								ex_menu_wizard_spells_learned[spellResref] = nil
							end
						end
						ex_menu_num_wizard_spells_remaining = ex_menu_num_wizard_spells_remaining + 1
						IEex_SetControlLabelText(IEex_GetControlFromPanel(newWizardSpellsPanel, 34), tostring(ex_menu_num_wizard_spells_remaining))
						IEex_SetControlButtonFrameUp(thisButton, 1)
						IEex_DisplayWizardSpellsToLearn(ex_current_menu_spell_level)
					end
				else
					ex_menu_wizard_spells_learned[spellResref] = true
					ex_menu_sorcerer_spells_replaced[ex_menu_sorcerer_spell_to_replace] = spellResref
					ex_menu_sorcerer_spell_to_replace = ""
					ex_menu_num_wizard_spells_remaining = ex_menu_num_wizard_spells_remaining - 1
					IEex_SetControlLabelText(IEex_GetControlFromPanel(newWizardSpellsPanel, 34), tostring(ex_menu_num_wizard_spells_remaining))
					ex_menu_in_second_replacement_step = false
					IEex_DisplayWizardSpellsToLearn(ex_current_menu_spell_level)
				end
			end
--[[
			if IEex_GetControlButtonFrameUp(thisButton) == 0 then
				IEex_SetControlButtonFrameUp(thisButton, 1)
			else
				IEex_SetControlButtonFrameUp(thisButton, 0)
			end
--]]
			local spellData = spellWrapper:getData()
--			local spellName = IEex_FetchString(IEex_ReadDword(spellData + 0x8))
			local spellDesc = IEex_FetchString(IEex_ReadDword(spellData + 0x50))
			spellWrapper:free()

			IEex_SetControlTextDisplay(descTextDisplay, spellDesc)
			IEex_NewWizardSpellsPanelDoneButtonUpdate()
			IEex_PanelInvalidate(newWizardSpellsPanel)
		end
	end

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
					IEex_SetTextAreaToString(IEex_GetEngineOptions(), 14, 3, IEex_FetchString(ex_tra_55903))
				end,
				[7] = function()
					IEex_SetTextAreaToString(IEex_GetEngineOptions(), 14, 3, IEex_FetchString(ex_tra_55906))
				end,
				[9] = function()
					IEex_SetTextAreaToString(IEex_GetEngineOptions(), 14, 3, IEex_FetchString(ex_tra_55908))
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

---------------------
-- Quickloot Hooks --
---------------------

-------------------
-- Thread: Async --
-------------------

function IEex_Extern_CScreenWorld_AsynchronousUpdate()

	IEex_AssertThread(IEex_Thread.Async, true)
	-- For some reason the main menu's options screen ticks this function
	if IEex_GetActiveEngine() ~= IEex_GetEngineWorld() then return end

	IEex_Quickloot_UpdateItems()
	IEex_ActionIndicators_Update()
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
	if true then return end
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

-- This runs before the engine has been initialized, it /CANNOT/ access UI structures. It should only
-- be used to define custom control types via IEex_DefineCustomControl(), and potentially define type
-- overrides for specific MENU->PANEL->CONTROL ids via IEex_AddControlOverride().

IEex_AbsoluteOnce("IEex_CustomControls", function()

	if IEex_Vanilla then return end

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
		["Render"] = IEex_WriteAssemblyAuto(IEex_FlattenTable({
			{[[
				!mark_esp
				!push_all_registers_iwd2
			]]},
			IEex_GenLuaCall("IEex_Extern_UI_ButtonRender", {
				["args"] = {
					{"!push(ecx)"},
					{"!marked_esp !push([esp+4])"},
				},
			}),
			{[[
				@call_error
				!pop_all_registers_iwd2
				!ret_word 04 00
			]]}
		})),
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
end)

function IEex_InstallActionIndicators()

	local worldScreen = IEex_GetEngineWorld()
	local chuResref = IEex_GetCHUResrefFromEngine(worldScreen)
	local panel1 = IEex_GetPanelFromEngine(worldScreen, 1)
	local x1, y1, w1, h1 = IEex_GetPanelArea(panel1)

	local actionIndicatorsPanel = IEex_AddPanelToEngine(worldScreen, {
		["id"]     = IEex_ActionIndicatorsPanelID,
		["x"]      = x1,
		["y"]      = y1 - IEex_ActionIndicators_PanelHeight,
		["width"]  = w1,
		["height"] = IEex_ActionIndicators_PanelHeight,
	})

	for refI = 0, 5 do

		local i = refI * 3
		local referenceControl = IEex_GetControlFromPanel(panel1, refI)
		local referenceControlX, _, referenceControlW = IEex_GetControlArea(referenceControl)

		IEex_AddControlOverride(chuResref, IEex_ActionIndicatorsPanelID, i, "IEex_UI_Button")
		IEex_AddControlToPanel(actionIndicatorsPanel, {
			["id"]     = i,
			["x"]      = referenceControlX + IEex_ActionIndicators_PrimarySlotOffsetX,
			["y"]      = IEex_ActionIndicators_PanelHeight + IEex_ActionIndicators_PrimarySlotOffsetY,
			["width"]  = IEex_ActionIndicators_PrimarySlotSize,
			["height"] = IEex_ActionIndicators_PrimarySlotSize,
			["type"]   = IEex_ControlStructType.BUTTON,
			["bam"]    = IEex_GetControlButtonBAM(referenceControl),
		})
		IEex_SetControlButtonPlayLButtonDownSound(IEex_GetControlFromPanel(actionIndicatorsPanel, i), false)

		IEex_AddControlOverride(chuResref, IEex_ActionIndicatorsPanelID, i + 1, "IEex_UI_Button")
		IEex_AddControlToPanel(actionIndicatorsPanel, {
			["id"]     = i + 1,
			["x"]      = referenceControlX + IEex_ActionIndicators_SecondarySlotOffsetX,
			["y"]      = IEex_ActionIndicators_PanelHeight + IEex_ActionIndicators_SecondarySlotOffsetY,
			["width"]  = IEex_ActionIndicators_SecondarySlotSize,
			["height"] = IEex_ActionIndicators_SecondarySlotSize,
			["type"]   = IEex_ControlStructType.BUTTON,
			["bam"]    = IEex_GetControlButtonBAM(referenceControl),
		})
		IEex_SetControlButtonPlayLButtonDownSound(IEex_GetControlFromPanel(actionIndicatorsPanel, i + 1), false)

		IEex_AddControlOverride(chuResref, IEex_ActionIndicatorsPanelID, i + 2, "IEex_UI_Button")
		IEex_AddControlToPanel(actionIndicatorsPanel, {
			["id"]     = i + 2,
			["x"]      = referenceControlX + IEex_ActionIndicators_TertiarySlotOffsetX,
			["y"]      = math.max(0, IEex_ActionIndicators_PanelHeight + IEex_ActionIndicators_TertiarySlotOffsetY),
			["width"]  = IEex_ActionIndicators_TertiarySlotSize,
			["height"] = IEex_ActionIndicators_TertiarySlotSize,
			["type"]   = IEex_ControlStructType.BUTTON,
			["bam"]    = IEex_GetControlButtonBAM(referenceControl),
		})
		IEex_SetControlButtonPlayLButtonDownSound(IEex_GetControlFromPanel(actionIndicatorsPanel, i + 2), false)
	end
end

function IEex_InstallQuickloot()

	local worldScreen = IEex_GetEngineWorld()

	local panel1Memory = IEex_GetPanelFromEngine(worldScreen, 1)
	local panel8Memory = IEex_GetPanelFromEngine(worldScreen, 8)

	local x1, y1, w1, h1 = IEex_GetPanelArea(panel1Memory)
	local quicklootPanel = IEex_AddPanelToEngine(worldScreen, {
		["id"]              = 23,
		["x"]               = x1,
		["y"]               = y1 - h1,
		["width"]           = w1,
		["height"]          = h1,
		["hasBackground"]   = 1,
		["backgroundImage"] = "B3QKLOOT"
	})

	for i = 7, 16 do

		local referenceControl = IEex_GetControlFromPanel(panel1Memory, i)
		local copyControl = IEex_GetControlFromPanel(panel8Memory, i - 7)

		local referenceControlX, referenceControlY = IEex_GetControlArea(referenceControl)
		local _, _, copyControlW, copyControlH = IEex_GetControlArea(copyControl)

		IEex_AddControlToPanel(quicklootPanel, {
			["id"]     = IEex_GetControlID(copyControl),
			["x"]      = referenceControlX + 1,
			["y"]      = referenceControlY + 1,
			["width"]  = copyControlW,
			["height"] = copyControlH,
			["type"]   = IEex_ControlStructType.BUTTON,
			["bam"]    = IEex_GetControlButtonBAM(copyControl),
		})
	end

	local leftArrow = IEex_GetControlFromPanel(panel1Memory, 6)
	local leftArrowX, leftArrowY, leftArrowW, leftArrowH = IEex_GetControlArea(leftArrow)
	IEex_AddControlToPanel(quicklootPanel, {
		["id"]             = 10,
		["x"]              = leftArrowX,
		["y"]              = leftArrowY,
		["width"]          = leftArrowW,
		["height"]         = leftArrowH,
		["type"]           = IEex_ControlStructType.BUTTON,
		["bam"]            = "GUIBTACT",
		["frameUnpressed"] = 48,
		["framePressed"]   = 49,
	})

	local rightArrow = IEex_GetControlFromPanel(panel1Memory, 17)
	local rightArrowX, rightArrowY, rightArrowW, rightArrowH = IEex_GetControlArea(rightArrow)
	IEex_AddControlToPanel(quicklootPanel, {
		["id"]             = 11,
		["x"]              = rightArrowX,
		["y"]              = rightArrowY,
		["width"]          = rightArrowW,
		["height"]         = rightArrowH,
		["type"]           = IEex_ControlStructType.BUTTON,
		["bam"]            = "GUIBTACT",
		["frameUnpressed"] = 52,
		["framePressed"]   = 53,
	})
end

function IEex_InstallIEexOptions()

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
	IEex_SetControlButtonText(IEex_GetControlFromPanel(worldOptionsPanel, 15), IEex_FetchString(ex_tra_55901)) -- "IEex Options"

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
	IEex_SetControlLabelText(IEex_GetControlFromPanel(newOptionsPanel, 0), IEex_FetchString(ex_tra_55901)) -- "IEex Options"

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
	IEex_SetControlButtonText(IEex_GetControlFromPanel(newOptionsPanel, 1), IEex_FetchString(11973)) -- "Done"

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
	IEex_SetControlButtonText(IEex_GetControlFromPanel(newOptionsPanel, 2), IEex_FetchString(13727)) -- "Cancel"

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
		["y"] = 124,
		["width"] = 308,
		["height"] = 18,
		["fontBam"] = "NORMAL",
		["textFlags"] = 0x51, -- Use color(0) | Right justify(4) | Middle justify(6)
	})
	IEex_SetControlLabelText(IEex_GetControlFromPanel(newOptionsPanel, 5), IEex_FetchString(ex_tra_55902)) -- "Transparent Fog of War"

	-- "Transparent Fog of War" Toggle - ID 6
	IEex_AddControlOverride("GUIOPT", 14, 6, "IEex_UI_Button")
	IEex_AddControlToPanel(newOptionsPanel, {
		["type"] = IEex_ControlStructType.BUTTON,
		["id"] = 6,
		["x"] = 394,
		["y"] = 122,
		["width"] = 23,
		["height"] = 24,
		["bam"] = "GBTNOPT3",
		["frameUnpressed"] = 1,
		["framePressed"] = 2,
	})

	-- "Action Indicators" Label - ID 7
	IEex_AddControlOverride("GUIOPT", 14, 7, "IEex_UI_Label")
	IEex_AddControlToPanel(newOptionsPanel, {
		["type"] = IEex_ControlStructType.LABEL,
		["id"] = 7,
		["x"] = 74,
		["y"] = 70,
		["width"] = 308,
		["height"] = 18,
		["fontBam"] = "NORMAL",
		["textFlags"] = 0x51, -- Use color(0) | Right justify(4) | Middle justify(6)
	})
	IEex_SetControlLabelText(IEex_GetControlFromPanel(newOptionsPanel, 7), IEex_FetchString(ex_tra_55905)) -- "Action Indicators"

	-- "Action Indicators" Toggle - ID 8
	IEex_AddControlOverride("GUIOPT", 14, 8, "IEex_UI_Button")
	IEex_AddControlToPanel(newOptionsPanel, {
		["type"] = IEex_ControlStructType.BUTTON,
		["id"] = 8,
		["x"] = 394,
		["y"] = 67,
		["width"] = 23,
		["height"] = 24,
		["bam"] = "GBTNOPT3",
		["frameUnpressed"] = 1,
		["framePressed"] = 2,
	})

	-- "Highlight Empty Containers in Gray" Label - ID 9
	IEex_AddControlOverride("GUIOPT", 14, 9, "IEex_UI_Label")
	IEex_AddControlToPanel(newOptionsPanel, {
		["type"] = IEex_ControlStructType.LABEL,
		["id"] = 9,
		["x"] = 74,
		["y"] = 97,
		["width"] = 308,
		["height"] = 18,
		["fontBam"] = "NORMAL",
		["textFlags"] = 0x51, -- Use color(0) | Right justify(4) | Middle justify(6)
	})
	IEex_SetControlLabelText(IEex_GetControlFromPanel(newOptionsPanel, 9), IEex_FetchString(ex_tra_55907)) -- "Highlight Empty Containers in Gray"

	-- "Highlight Empty Containers in Gray" Toggle - ID 10
	IEex_AddControlOverride("GUIOPT", 14, 10, "IEex_UI_Button")
	IEex_AddControlToPanel(newOptionsPanel, {
		["type"] = IEex_ControlStructType.BUTTON,
		["id"] = 10,
		["x"] = 394,
		["y"] = 95,
		["width"] = 23,
		["height"] = 24,
		["bam"] = "GBTNOPT3",
		["frameUnpressed"] = 1,
		["framePressed"] = 2,
	})

	IEex_SetPanelActive(newOptionsPanel, false)
end

-- Use this function to modify existing panels / controls. The engine has been semi-initialized at this point, and the
-- passed `chuResref` signifies that the given .CHU has been fully created, and that its UI structures can be accessed.

function IEex_OnCHUInitialized(chuResref)

	if chuResref == "GUIW08" or chuResref == "GUIW10" then

		local worldScreen = IEex_GetEngineWorld()

		----------------------------------------
		-- Fix incorrect vanilla press-frames --
		----------------------------------------

		local panel8Memory = IEex_GetPanelFromEngine(worldScreen, 8)
		for i = 6, 9 do
			local fixControl = IEex_GetControlFromPanel(panel8Memory, i)
			IEex_SetControlButtonFrameDown(fixControl, 0)
		end

		----------------------------
		-- Widescreen Adjustments --
		----------------------------

		local resW, resH = IEex_GetResolution()

		local panel0Memory = IEex_GetPanelFromEngine(worldScreen, 0)
		local panel1Memory = IEex_GetPanelFromEngine(worldScreen, 1)
		local panel6Memory = IEex_GetPanelFromEngine(worldScreen, 6)
		local panel7Memory = IEex_GetPanelFromEngine(worldScreen, 7)
		local panel8Memory = IEex_GetPanelFromEngine(worldScreen, 8)
		local panel9Memory = IEex_GetPanelFromEngine(worldScreen, 9)
		local panel17Memory = IEex_GetPanelFromEngine(worldScreen, 17)

		local control_9_0_Memory = IEex_GetControlFromPanel(panel9Memory, 0)

		local x0, y0, w0, h0 = IEex_GetPanelArea(panel0Memory)
		local x1, y1, w1, h1 = IEex_GetPanelArea(panel1Memory)
		local x6, y6, w6, h6 = IEex_GetPanelArea(panel6Memory)
		local x7, y7, w7, h7 = IEex_GetPanelArea(panel7Memory)
		local x8, y8, w8, h8 = IEex_GetPanelArea(panel8Memory)
		local x9, y9, w9, h9 = IEex_GetPanelArea(panel7Memory)
		local x17, y17, w17, h17 = IEex_GetPanelArea(panel17Memory)

		local x_9_0, y_9_0, w_9_0, h_9_0 = IEex_GetControlArea(control_9_0_Memory)

		local toolbarBottom = resH - h0

		IEex_SetPanelXY(panel0Memory, (resW - w0) / 2, toolbarBottom)
		IEex_SetPanelXY(panel1Memory, (resW - w1) / 2, toolbarBottom - h1, true)
		IEex_SetPanelArea(panel6Memory, (resW - 800) / 2, resH - h6, 800)
		IEex_SetPanelXY(panel7Memory, (resW - w7) / 2, resH - h7)
		IEex_SetPanelXY(panel8Memory, (resW - w8) / 2, resH - h8)
		IEex_SetPanelArea(panel9Memory, (resW - w_9_0) / 2, resH - h_9_0 - 4, w_9_0, h_9_0)
		IEex_SetPanelXY(panel17Memory, (resW - w17) / 2, resH - h17)

		IEex_SetControlXY(control_9_0_Memory, 0, 0)

		---------------
		-- Quickloot --
		---------------

		if not IEex_Vanilla then
			IEex_InstallQuickloot()
		end

		-----------------------
		-- Action Indicators --
		-----------------------

		if not IEex_Vanilla then
			IEex_InstallActionIndicators()
		end

		----------------------------------
		-- Worldscreen Spell Info Popup --
		----------------------------------

		if not IEex_Vanilla then

			-- IEex Spell Info - Panel ID <IEex_WorldScreenSpellInfoPanelID>
			local newSpellInfoPanel = IEex_AddPanelToEngine(worldScreen, {
				["id"] = IEex_WorldScreenSpellInfoPanelID,
				["width"] = 429,
				["height"] = 446,
				["hasBackground"] = 1,
				["backgroundImage"] = "GUISPLHB",
			})

			-- "Spell information" label - Control ID 0
			IEex_AddControlOverride(chuResref, IEex_WorldScreenSpellInfoPanelID, 0, "IEex_UI_Label")
			IEex_AddControlToPanel(newSpellInfoPanel, {
				["type"] = IEex_ControlStructType.LABEL,
				["id"] = 0,
				["x"] = 22,
				["y"] = 22,
				["width"] = 343,
				["height"] = 20,
				["initialTextStrref"] = 16189, -- "Spell Information"
				["fontBam"] = "NORMAL",
				["fontColor1"] = 0xFFFFFF,
				["textFlags"] = 0x45, -- Use color(0) | Center justify(4) | Middle justify(6)
			})

			-- Spell name label - Control ID 1
			IEex_AddControlOverride(chuResref, IEex_WorldScreenSpellInfoPanelID, 1, "IEex_UI_Label")
			IEex_AddControlToPanel(newSpellInfoPanel, {
				["type"] = IEex_ControlStructType.LABEL,
				["id"] = 1,
				["x"] = 22,
				["y"] = 52,
				["width"] = 343,
				["height"] = 20,
				["fontBam"] = "NORMAL",
				["fontColor1"] = 0xFFFFFF,
				["textFlags"] = 0x45, -- Use color(0) | Center justify(4) | Middle justify(6)
			})

			-- Spell icon - Control ID 2
			IEex_AddControlOverride(chuResref, IEex_WorldScreenSpellInfoPanelID, 2, "ButtonMageSpellInfoIcon")
			IEex_AddControlToPanel(newSpellInfoPanel, {
				["type"] = IEex_ControlStructType.BUTTON,
				["id"] = 2,
				["x"] = 375,
				["y"] = 22,
				["bam"] = "",
				["width"] = 32,
				["height"] = 32,
			})

			-- Spell description area - Control ID 3
			IEex_AddControlOverride(chuResref, IEex_WorldScreenSpellInfoPanelID, 3, "IEex_UI_TextArea")
			IEex_AddControlToPanel(newSpellInfoPanel, {
				["type"] = IEex_ControlStructType.TEXT_AREA,
				["id"] = 3,
				["x"] = 23,
				["y"] = 83,
				["width"] = 363,
				["height"] = 312,
				["fontBam"] = "NORMAL",
				["scrollbarID"] = 4,
			})

			-- Spell description area scrollbar - Control ID 4
			IEex_AddControlOverride(chuResref, IEex_WorldScreenSpellInfoPanelID, 4, "IEex_UI_Scrollbar")
			IEex_AddControlToPanel(newSpellInfoPanel, {
				["type"] = IEex_ControlStructType.SCROLL_BAR,
				["id"] = 4,
				["x"] = 396,
				["y"] = 82,
				["width"] = 12,
				["height"] = 313,
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

			-- "Done" - Control ID 5
			IEex_AddControlOverride(chuResref, IEex_WorldScreenSpellInfoPanelID, 5, "IEex_UI_Button")
			IEex_AddControlToPanel(newSpellInfoPanel, {
				["type"] = IEex_ControlStructType.BUTTON,
				["id"] = 5,
				["x"] = 135,
				["y"] = 402,
				["width"] = 156,
				["height"] = 24,
				["bam"] = "GBTNMED",
				["frameUnpressed"] = 1,
				["framePressed"] = 2,
				["frameDisabled"] = 3,
			})
			IEex_SetControlButtonText(IEex_GetControlFromPanel(newSpellInfoPanel, 5), IEex_FetchString(11973))

			IEex_SetPanelActive(newSpellInfoPanel, false)

			local commandsPanel = IEex_GetPanelFromEngine(worldScreen, 0)
			local quicklootButtonX = 705
			if chuResref == "GUIW10" then
				quicklootButtonX = 817
			end
			local commandsPanelMultiplayer = IEex_GetPanelFromEngine(worldScreen, 22)
			IEex_AddControlOverride(chuResref, 0, 15, "IEex_UI_Button")
			IEex_AddControlToPanel(commandsPanel, {
				["type"] = IEex_ControlStructType.BUTTON,
				["id"] = 15,
				["x"] = quicklootButtonX,
				["y"] = 73,
				["width"] = 29,
				["height"] = 34,
				["bam"] = "USGBTNQL",
				["sequence"] = 0,
				["frameUnpressed"] = 0,
				["framePressed"] = 1,
				["frameDisabled"] = 0,
				["tooltipStrref"] = ex_tra_55927,
				["customHotkeyHintIndex"] = IEex_Hotkeys_CustomBinding.TOGGLE_QUICKLOOT,
			})

			IEex_AddControlOverride(chuResref, 22, 15, "IEex_UI_Button")
			IEex_AddControlToPanel(commandsPanelMultiplayer, {
				["type"] = IEex_ControlStructType.BUTTON,
				["id"] = 15,
				["x"] = quicklootButtonX,
				["y"] = 73,
				["width"] = 29,
				["height"] = 34,
				["bam"] = "USGBTNQL",
				["sequence"] = 0,
				["frameUnpressed"] = 0,
				["framePressed"] = 1,
				["frameDisabled"] = 0,
				["tooltipStrref"] = ex_tra_55927,
				["customHotkeyHintIndex"] = IEex_Hotkeys_CustomBinding.TOGGLE_QUICKLOOT,
			})
		end

	elseif chuResref == "GUIREC" then

		if not IEex_Vanilla then

			local screenCharacter = IEex_GetEngineCharacter()
			local newWizardSpellsPanel = IEex_AddPanelToEngine(screenCharacter, {
				["id"] = 58,
				["x"] = 245,
				["width"] = 555,
				["height"] = 433,
				["hasBackground"] = 1,
				["backgroundImage"] = "GUIRLVL5",
				["flags"] = 0x1,
			})
			local buttonID = 0

			for i = 0, 4, 1 do
				for j = 0, 5, 1 do
					IEex_AddControlOverride("GUIREC", 58, buttonID, "IEex_UI_Button")
					IEex_AddControlToPanel(newWizardSpellsPanel, {
						["type"] = IEex_ControlStructType.BUTTON,
						["id"] = buttonID,
						["x"] = 14 + 43 * j,
						["y"] = 76 + 43 * i,
						["width"] = 40,
						["height"] = 39,
						["bam"] = "SPLBUT",
						["frameUnpressed"] = 1,
						["framePressed"] = 2,
						["frameDisabled"] = 3,
					})
					IEex_AddControlOverride("GUIREC", 58, (buttonID + 100), "ButtonMageSpellInfoIcon")
					IEex_AddControlToPanel(newWizardSpellsPanel, {
						["type"] = IEex_ControlStructType.BUTTON,
						["id"] = (buttonID + 100),
						["x"] = 18 + 43 * j,
						["y"] = 79 + 43 * i,
						["bam"] = "",
						["width"] = 32,
						["height"] = 32,
					})
					buttonID = buttonID + 1
				end
			end

			IEex_AddControlOverride("GUIREC", 58, 30, "IEex_UI_TextArea")
			IEex_AddControlToPanel(newWizardSpellsPanel, {
				["type"] = IEex_ControlStructType.TEXT_AREA,
				["id"] = 30,
				["x"] = 305,
				["y"] = 26,
				["width"] = 207,
				["height"] = 339,
				["fontBam"] = "NORMAL",
				["scrollbarID"] = 31,
			})

			IEex_AddControlOverride("GUIREC", 58, 31, "IEex_UI_Scrollbar")
			IEex_AddControlToPanel(newWizardSpellsPanel, {
				["type"] = IEex_ControlStructType.SCROLL_BAR,
				["id"] = 31,
				["x"] = 523,
				["y"] = 23,
				["width"] = 12,
				["height"] = 348,
				["graphicsBam"] = "GBTNSCRL",
				["animationNumber"] = 0,
				["upArrowFrameUnpressed"] = 0,
				["upArrowFramePressed"] = 1,
				["downArrowFrameUnpressed"] = 2,
				["downArrowFramePressed"] = 3,
				["troughFrame"] = 4,
				["sliderFrame"] = 5,
				["textAreaID"] = 30,
			})

			IEex_AddControlOverride("GUIREC", 58, 32, "IEex_UI_Button")
			IEex_AddControlToPanel(newWizardSpellsPanel, {
				["type"] = IEex_ControlStructType.BUTTON,
				["id"] = 32,
				["x"] = 298,
				["y"] = 382,
				["width"] = 117,
				["height"] = 25,
				["bam"] = "GBTNSTD",
				["sequence"] = 0,
				["frameUnpressed"] = 1,
				["framePressed"] = 2,
				["frameDisabled"] = 3,
			})
			IEex_SetControlButtonText(IEex_GetControlFromPanel(newWizardSpellsPanel, 32), IEex_FetchString(ex_tra_55770))

			IEex_AddControlOverride("GUIREC", 58, 33, "IEex_UI_Label")
			IEex_AddControlToPanel(newWizardSpellsPanel, {
				["type"] = IEex_ControlStructType.LABEL,
				["id"] = 33,
				["x"] = 10,
				["y"] = 23,
				["width"] = 205,
				["height"] = 28,
				["fontBam"] = "NORMAL",
				["fontColor1"] = 0xFFFFF6,
				["textFlags"] = 0x45, -- Use color(0) | Center justify(4) | Middle justify(6)
			})

			IEex_AddControlOverride("GUIREC", 58, 34, "IEex_UI_Label")
			IEex_AddControlToPanel(newWizardSpellsPanel, {
				["type"] = IEex_ControlStructType.LABEL,
				["id"] = 34,
				["x"] = 226,
				["y"] = 23,
				["width"] = 50,
				["height"] = 28,
				["fontBam"] = "NORMAL",
				["fontColor1"] = 0xFFFF,
				["textFlags"] = 0x45, -- Use color(0) | Center justify(4) | Middle justify(6)
			})

			IEex_AddControlOverride("GUIREC", 58, 35, "IEex_UI_Button")
			IEex_AddControlToPanel(newWizardSpellsPanel, {
				["type"] = IEex_ControlStructType.BUTTON,
				["id"] = 35,
				["x"] = 419,
				["y"] = 382,
				["width"] = 117,
				["height"] = 25,
				["bam"] = "GBTNSTD",
				["sequence"] = 1,
				["frameUnpressed"] = 1,
				["framePressed"] = 2,
				["frameDisabled"] = 3,
			})
			IEex_SetControlButtonText(IEex_GetControlFromPanel(newWizardSpellsPanel, 35), IEex_FetchString(11973))

			IEex_AddControlOverride("GUIREC", 58, 36, "IEex_UI_Button")
			IEex_AddControlToPanel(newWizardSpellsPanel, {
				["type"] = IEex_ControlStructType.BUTTON,
				["id"] = 36,
				["x"] = 14,
				["y"] = 300,
				["width"] = 47,
				["height"] = 39,
				["bam"] = "GBTNJBTN",
				["sequence"] = 0,
				["frameUnpressed"] = 1,
				["framePressed"] = 2,
				["frameDisabled"] = 3,
			})

			IEex_AddControlOverride("GUIREC", 58, 37, "IEex_UI_Button")
			IEex_AddControlToPanel(newWizardSpellsPanel, {
				["type"] = IEex_ControlStructType.BUTTON,
				["id"] = 37,
				["x"] = 222,
				["y"] = 300,
				["width"] = 47,
				["height"] = 39,
				["bam"] = "GBTNJBTN",
				["sequence"] = 1,
				["frameUnpressed"] = 1,
				["framePressed"] = 2,
				["frameDisabled"] = 3,
			})

			IEex_SetPanelActive(newWizardSpellsPanel, false)
		end

	elseif chuResref == "GUIOPT" then

		------------------
		-- IEex Options --
		------------------

		if not IEex_Vanilla then
			IEex_InstallIEexOptions()
		end

	elseif chuResref == "GUIKEYS" then

		-----------------------
		-- GUIKEYS Expansion --
		-----------------------

		if not IEex_Vanilla then

			local screenKeys = IEex_GetEngineKeys()

			local panel0 = IEex_GetPanelFromEngine(screenKeys, 0)
			IEex_SetPanelMosaicResref(panel0, "B3KEYS")

			local curNameControlId = 0x10000005 + 60
			local curValueControlId = 0x10000005

			for columnI = 0, 2 do

				local firstValueControlOfColumn = IEex_GetControlFromPanel(panel0, curValueControlId)
				local firstValueControlOfColumnX, firstValueControlOfColumnY, firstValueControlOfColumnW = IEex_GetControlArea(firstValueControlOfColumn)

				-- Install left divider for column
				local lDividerId = 6 + columnI * 2
				IEex_AddControlOverride("GUIKEYS", 0, lDividerId, "IEex_UI_Button")
				IEex_AddControlToPanel(panel0, {
					["type"] = IEex_ControlStructType.BUTTON,
					["id"] = lDividerId,
					["x"] = firstValueControlOfColumnX - IEex_Hotkeys_ValueControlExpansion - 5,
					["y"] = firstValueControlOfColumnY - 1,
					["width"] = 5,
					["height"] = 399,
					["bam"] = "B3LDVIDR",
					["sequence"] = columnI % 3,
					["playLButtonDownSound"] = false,
				})

				-- Install right divider for column
				local rDividerId = 7 + columnI * 2
				IEex_AddControlOverride("GUIKEYS", 0, rDividerId, "IEex_UI_Button")
				IEex_AddControlToPanel(panel0, {
					["type"] = IEex_ControlStructType.BUTTON,
					["id"] = rDividerId,
					["x"] = firstValueControlOfColumnX + firstValueControlOfColumnW,
					["y"] = firstValueControlOfColumnY - 1,
					["width"] = 5,
					["height"] = 399,
					["bam"] = "B3RDVIDR",
					["sequence"] = columnI % 2,
					["playLButtonDownSound"] = false,
				})

				-- Increase keybind mapping widths (taken from name labels)
				for i = 1, 20 do

					local nameControl = IEex_GetControlFromPanel(panel0, curNameControlId)
					local valueControl = IEex_GetControlFromPanel(panel0, curValueControlId)

					local nameX, _, nameW = IEex_GetControlArea(nameControl)
					local valueX, _, valueW = IEex_GetControlArea(valueControl)

					IEex_SetControlArea(nameControl, nameX, nil, nameW - IEex_Hotkeys_ValueControlExpansion)
					IEex_SetControlArea(valueControl, valueX - IEex_Hotkeys_ValueControlExpansion, nil, valueW + IEex_Hotkeys_ValueControlExpansion)

					curNameControlId = curNameControlId + 1
					curValueControlId = curValueControlId + 1
				end
			end
		end
	end
end

------------------
-- IEex Options --
------------------

IEex_Helper_InitBridgeFromTable("IEex_Options", {
	["options"] = {
		["actionIndicators"] = false,
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

	IEex_Helper_SetBridge(options, "actionIndicators",
		IEex_GetPrivateProfileInt("IEex Options", "Action Indicators", 1, ".\\Icewind2.ini") ~= 0 and true or false)

	IEex_Helper_SetBridge(options, "highlightEmptyContainersInGray",
		IEex_GetPrivateProfileInt("IEex Options", "Highlight Empty Containers in Gray", 1, ".\\Icewind2.ini") ~= 0 and true or false)
end

function IEex_WriteOptions()

	local options = IEex_Helper_GetBridge("IEex_Options", "options")

	IEex_WritePrivateProfileString("IEex Options", "Transparent Fog of War",
		IEex_Helper_GetBridge(options, "transparentFogOfWar") and "1" or "0", ".\\Icewind2.ini")

	IEex_WritePrivateProfileString("IEex Options", "Action Indicators",
		IEex_Helper_GetBridge(options, "actionIndicators") and "1" or "0", ".\\Icewind2.ini")

	IEex_WritePrivateProfileString("IEex Options", "Highlight Empty Containers in Gray",
		IEex_Helper_GetBridge(options, "highlightEmptyContainersInGray") and "1" or "0", ".\\Icewind2.ini")
end

function IEex_InitOptionButtons()

	local screenOptions = IEex_GetEngineOptions()
	local newOptionsPanel = IEex_GetPanelFromEngine(screenOptions, 14)
	local options = IEex_Helper_GetBridge("IEex_Options", "options")

	IEex_SetTextAreaToString(screenOptions, 14, 3, "")

	IEex_SetControlButtonFrameUpForce(IEex_GetControlFromPanel(newOptionsPanel, 6),
		IEex_Helper_GetBridge(options, "transparentFogOfWar") and 3 or 1)

	IEex_SetControlButtonFrameUpForce(IEex_GetControlFromPanel(newOptionsPanel, 8),
		IEex_Helper_GetBridge(options, "actionIndicators") and 3 or 1)

	IEex_SetControlButtonFrameUpForce(IEex_GetControlFromPanel(newOptionsPanel, 10),
		IEex_Helper_GetBridge(options, "highlightEmptyContainersInGray") and 3 or 1)
end

IEex_AbsoluteOnce("IEex_InitOptions", function()
	if not IEex_InAsyncState then return false end
	if IEex_Vanilla then return end
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

function IEex_CScreenWorld_OnQuicklootButtonLClick()
	IEex_AssertThread(IEex_Thread.Async, true)
	if IEex_Helper_GetBridge("IEex_Quickloot", "on") then
		IEex_Quickloot_Stop()
	else
		IEex_Quickloot_Start()
	end
end

-----------------------
-- GUIKEYS Expansion --
-----------------------

IEex_Hotkeys_HardcodedMapDefaults = {
	[00] = "I",
	[01] = "R",
	[02] = "G",
	[03] = "J",
	[04] = "M",
	[05] = "S",
	[06] = "O",
	[07] = "C",
	[08] = nil,
	[09] = nil,
	[10] = nil,
	[11] = nil,
	[12] = nil,
	[13] = "D",
	[14] = nil,
	[15] = nil,
	[16] = nil,
	[17] = nil,
	[18] = nil,
	[19] = "V",
	[20] = nil,
	[21] = nil,
	[22] = "L",
	[23] = "H",
	[24] = "T",
	[25] = "X",
	[26] = "Q",
	[27] = "A",
	[28] = "Y",
	[29] = "Z",
	[30] = ".",
	[31] = "F",
	[32] = "7",
	[33] = "8",
	[34] = "9",
	[35] = "0",
	[36] = "-",
	[37] = "=",
	[38] = nil,
	[39] = nil,
	[40] = nil,
	[41] = nil,
	[42] = nil,
	[43] = nil,
	[44] = nil,
	[45] = nil,
	[46] = nil,
	[47] = nil,
	[48] = nil,
	[49] = nil,
	[50] = nil,
	[51] = nil,
	[52] = nil,
}

IEex_Hotkeys_CustomBinding = {
	TOGGLE_QUICKLOOT        =  0,
	SCROLL_UP               =  1,
	SCROLL_UP_ALT           =  2,
	SCROLL_LEFT             =  3,
	SCROLL_LEFT_ALT         =  4,
	SCROLL_DOWN             =  5,
	SCROLL_DOWN_ALT         =  6,
	SCROLL_RIGHT            =  7,
	SCROLL_RIGHT_ALT        =  8,
	SCROLL_TOP_LEFT         =  9,
	SCROLL_TOP_LEFT_ALT     = 10,
	SCROLL_BOTTOM_LEFT      = 11,
	SCROLL_BOTTOM_LEFT_ALT  = 12,
	SCROLL_BOTTOM_RIGHT     = 13,
	SCROLL_BOTTOM_RIGHT_ALT = 14,
	SCROLL_TOP_RIGHT        = 15,
	SCROLL_TOP_RIGHT_ALT    = 16,
}

IEex_Hotkeys_CustomBindings = {
	[IEex_Hotkeys_CustomBinding.TOGGLE_QUICKLOOT]        = { ["iniSection"] = "IEex", ["iniKey"] = "Toggle Quickloot",          ["default"] = "`"        },
	[IEex_Hotkeys_CustomBinding.SCROLL_UP]               = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Up",                 ["default"] = "Up"       },
	[IEex_Hotkeys_CustomBinding.SCROLL_UP_ALT]           = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Up (Alt)",           ["default"] = "Keypad 8" },
	[IEex_Hotkeys_CustomBinding.SCROLL_LEFT]             = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Left",               ["default"] = "Left"     },
	[IEex_Hotkeys_CustomBinding.SCROLL_LEFT_ALT]         = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Left (Alt)",         ["default"] = "Keypad 4" },
	[IEex_Hotkeys_CustomBinding.SCROLL_DOWN]             = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Down",               ["default"] = "Down"     },
	[IEex_Hotkeys_CustomBinding.SCROLL_DOWN_ALT]         = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Down (Alt)",         ["default"] = "Keypad 2" },
	[IEex_Hotkeys_CustomBinding.SCROLL_RIGHT]            = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Right",              ["default"] = "Right"    },
	[IEex_Hotkeys_CustomBinding.SCROLL_RIGHT_ALT]        = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Right (Alt)",        ["default"] = "Keypad 6" },
	[IEex_Hotkeys_CustomBinding.SCROLL_TOP_LEFT]         = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Top Left",           ["default"] = nil        },
	[IEex_Hotkeys_CustomBinding.SCROLL_TOP_LEFT_ALT]     = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Top Left (Alt)",     ["default"] = "Keypad 7" },
	[IEex_Hotkeys_CustomBinding.SCROLL_BOTTOM_LEFT]      = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Bottom Left",        ["default"] = nil        },
	[IEex_Hotkeys_CustomBinding.SCROLL_BOTTOM_LEFT_ALT]  = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Bottom Left (Alt)",  ["default"] = "Keypad 1" },
	[IEex_Hotkeys_CustomBinding.SCROLL_BOTTOM_RIGHT]     = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Bottom Right",       ["default"] = nil        },
	[IEex_Hotkeys_CustomBinding.SCROLL_BOTTOM_RIGHT_ALT] = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Bottom Right (Alt)", ["default"] = "Keypad 3" },
	[IEex_Hotkeys_CustomBinding.SCROLL_TOP_RIGHT]        = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Top Right",          ["default"] = nil        },
	[IEex_Hotkeys_CustomBinding.SCROLL_TOP_RIGHT_ALT]    = { ["iniSection"] = "IEex", ["iniKey"] = "Scroll Top Right (Alt)",    ["default"] = "Keypad 9" },
}

IEex_Hotkeys_CustomBindingsHandlers = {
	[IEex_Hotkeys_CustomBinding.TOGGLE_QUICKLOOT] = IEex_CScreenWorld_OnQuicklootButtonLClick,
}

IEex_Hotkeys_ValueControlExpansion = 38

IEex_Hotkeys_KeysScreenLayout = {

	------------
	-- Page 1 --
	------------

	-- Column 1
	{ ["hardcodedMapIndex"] = -1, ["strref"] = 33478 },
	{ ["hardcodedMapIndex"] =  0, ["strref"] = 16307 },
	{ ["hardcodedMapIndex"] =  1, ["strref"] = 16306 },
	{ ["hardcodedMapIndex"] =  3, ["strref"] = 16308 },
	{ ["hardcodedMapIndex"] =  4, ["strref"] = 33505 },
	{ ["hardcodedMapIndex"] =  5, ["strref"] = 17384 },
	{ ["hardcodedMapIndex"] =  6, ["strref"] = 13696 },
	{ ["hardcodedMapIndex"] =  7, ["strref"] = 13902 },
	{ ["hardcodedMapIndex"] =  2, ["strref"] = 16313 },
	{ ["hardcodedMapIndex"] = -1, ["strref"] =    -1 },
	{ ["hardcodedMapIndex"] = -1, ["strref"] = 33501 },
	{ ["hardcodedMapIndex"] =  8, ["strref"] = 15925 },
	{ ["hardcodedMapIndex"] =  9, ["strref"] =  4974 },
	{ ["hardcodedMapIndex"] = 10, ["strref"] =  4918 },
	{ ["hardcodedMapIndex"] = 11, ["strref"] =  4688 },
	{ ["hardcodedMapIndex"] = 12, ["strref"] =  4978 },
	{ ["hardcodedMapIndex"] = 13, ["strref"] =  4933 },
	{ ["hardcodedMapIndex"] = 14, ["strref"] =  4971 },
	{ ["hardcodedMapIndex"] = 15, ["strref"] =  4968 },
	{ ["hardcodedMapIndex"] = 16, ["strref"] =  4927 },

	-- Column 2
	{ ["hardcodedMapIndex"] = 17, ["strref"] = 15924 },
	{ ["hardcodedMapIndex"] = 18, ["strref"] =  4666 },
	{ ["hardcodedMapIndex"] = 19, ["strref"] =  4954 },
	{ ["hardcodedMapIndex"] = 20, ["strref"] = 30289 },
	{ ["hardcodedMapIndex"] = 21, ["strref"] = 30290 },
	{ ["hardcodedMapIndex"] = -1, ["strref"] =    -1 },
	{ ["hardcodedMapIndex"] = -1, ["strref"] = 33500 },
	{ ["hardcodedMapIndex"] = 25, ["strref"] = 33506 },
	{ ["hardcodedMapIndex"] = 26, ["strref"] = 33507 },
	{ ["hardcodedMapIndex"] = 22, ["strref"] = 33508 },
	{ ["hardcodedMapIndex"] = 23, ["strref"] = 32050 },
	{ ["hardcodedMapIndex"] = 28, ["strref"] = 40248 },
	{ ["hardcodedMapIndex"] = 24, ["strref"] = 40249 },
	{ ["hardcodedMapIndex"] = 27, ["strref"] = 33509 },
	{ ["hardcodedMapIndex"] = 29, ["strref"] = 11942 },
	{ ["hardcodedMapIndex"] = 30, ["strref"] = 40250 },
	{ ["hardcodedMapIndex"] = 31, ["strref"] = 40251 },
	{ ["hardcodedMapIndex"] = 32, ["strref"] = 40252 },
	{ ["hardcodedMapIndex"] = 33, ["strref"] = 40253 },
	{ ["hardcodedMapIndex"] = 34, ["strref"] = 40254 },

	-- Column 3
	{ ["hardcodedMapIndex"] = 35, ["strref"] = 40255 },
	{ ["hardcodedMapIndex"] = 36, ["strref"] = 40256 },
	{ ["hardcodedMapIndex"] = 37, ["strref"] = 40273 },
	{ ["hardcodedMapIndex"] = -1, ["strref"] =    -1 },
	{ ["hardcodedMapIndex"] = -1, ["strref"] = 40257 },
	{ ["hardcodedMapIndex"] = 41, ["strref"] = 40258 },
	{ ["hardcodedMapIndex"] = 42, ["strref"] = 40259 },
	{ ["hardcodedMapIndex"] = 43, ["strref"] = 40260 },
	{ ["hardcodedMapIndex"] = 44, ["strref"] = 40261 },
	{ ["hardcodedMapIndex"] = 38, ["strref"] = 40262 },
	{ ["hardcodedMapIndex"] = 39, ["strref"] = 40263 },
	{ ["hardcodedMapIndex"] = 40, ["strref"] = 40264 },
	{ ["hardcodedMapIndex"] = 45, ["strref"] = 40265 },
	{ ["hardcodedMapIndex"] = 46, ["strref"] = 40266 },
	{ ["hardcodedMapIndex"] = 47, ["strref"] = 40267 },
	{ ["hardcodedMapIndex"] = 48, ["strref"] = 40268 },
	{ ["hardcodedMapIndex"] = 49, ["strref"] = 40269 },
	{ ["hardcodedMapIndex"] = 50, ["strref"] = 40270 },
	{ ["hardcodedMapIndex"] = 51, ["strref"] = 40271 },
	{ ["hardcodedMapIndex"] = 52, ["strref"] = 40272 },

	------------
	-- Page 2 --
	------------

	-- Column 1
	{                                                                          ["strref"] = ex_tra_55909 }, -- "Scrolling"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_UP,               ["strref"] = ex_tra_55910 }, -- "Scroll Up"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_LEFT,             ["strref"] = ex_tra_55911 }, -- "Scroll Left"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_DOWN,             ["strref"] = ex_tra_55912 }, -- "Scroll Down"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_RIGHT,            ["strref"] = ex_tra_55913 }, -- "Scroll Right"
	{                                                                                                    },
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_UP_ALT,           ["strref"] = ex_tra_55914 }, -- "Scroll Up (Alt)"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_LEFT_ALT,         ["strref"] = ex_tra_55915 }, -- "Scroll Left (Alt)"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_DOWN_ALT,         ["strref"] = ex_tra_55916 }, -- "Scroll Down (Alt)"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_RIGHT_ALT,        ["strref"] = ex_tra_55917 }, -- "Scroll Right (Alt)"
	{                                                                                                    },
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_TOP_LEFT,         ["strref"] = ex_tra_55918 }, -- "Scroll Top Left"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_BOTTOM_LEFT,      ["strref"] = ex_tra_55919 }, -- "Scroll Bottom Left"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_BOTTOM_RIGHT,     ["strref"] = ex_tra_55920 }, -- "Scroll Bottom Right"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_TOP_RIGHT,        ["strref"] = ex_tra_55921 }, -- "Scroll Top Right"
	{                                                                                                    },
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_TOP_LEFT_ALT,     ["strref"] = ex_tra_55922 }, -- "Scroll Top Left (Alt)"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_BOTTOM_LEFT_ALT,  ["strref"] = ex_tra_55923 }, -- "Scroll Bottom Left (Alt)"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_BOTTOM_RIGHT_ALT, ["strref"] = ex_tra_55924 }, -- "Scroll Bottom Right (Alt)"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.SCROLL_TOP_RIGHT_ALT,    ["strref"] = ex_tra_55925 }, -- "Scroll Top Right (Alt)"

	-- Column 2
	{                                                                          ["strref"] = ex_tra_55926 }, -- "IEex"
	{ ["customMapIndex"] = IEex_Hotkeys_CustomBinding.TOGGLE_QUICKLOOT,        ["strref"] = ex_tra_55927 }, -- "Toggle Quickloot"
}

function IEex_Extern_GiveEngineKeysScreenLayout()
	return IEex_Hotkeys_KeysScreenLayout
end

IEex_Hotkeys_KeyToCustomMapIndex = {}

-- This function is called by the engine whenever a custom hotkey binding is updated, (this includes initialization).
--     deltaT = {
--         { ["customMapIndex"] = ?, ["oldVirtualKey"] = ?, ["oldVirtualKeyHasCtrl"] = ?, ["newVirtualKey"] = ?, ["newVirtualKeyHasCtrl"] = ? },
--         { ["customMapIndex"] = ?, ["oldVirtualKey"] = ?, ["oldVirtualKeyHasCtrl"] = ?, ["newVirtualKey"] = ?, ["newVirtualKeyHasCtrl"] = ? },
--         ...
--     }
function IEex_Extern_KeysScreenOnCustomBindingsChanged(deltaT)

	IEex_AssertThread(IEex_Thread.Async, true)

	for _, deltaEntry in ipairs(deltaT) do

		local customMapIndex       = deltaEntry.customMapIndex
		local oldVirtualKey        = deltaEntry.oldVirtualKey
		local oldVirtualKeyHasCtrl = deltaEntry.oldVirtualKeyHasCtrl
		local newVirtualKey        = deltaEntry.newVirtualKey
		local newVirtualKeyHasCtrl = deltaEntry.newVirtualKeyHasCtrl

		-- Using 0x100 (outside of VK_ range of 0xFF) to flag ctrl
		if oldVirtualKeyHasCtrl then oldVirtualKey = bit.bor(oldVirtualKey, 0x100) end
		if newVirtualKeyHasCtrl then newVirtualKey = bit.bor(newVirtualKey, 0x100) end

		-- (Potentially) clear old mapping if it hasn't been changed already
		if IEex_Hotkeys_KeyToCustomMapIndex[oldVirtualKey] == customMapIndex then
			IEex_Hotkeys_KeyToCustomMapIndex[oldVirtualKey] = nil
		end

		-- Set new mapping
		IEex_Hotkeys_KeyToCustomMapIndex[newVirtualKey] = newVirtualKey ~= 0 and customMapIndex or nil
	end
end

function IEex_Hotkeys_KeyPressedListener(key)

	if IEex_GetActiveEngine() ~= IEex_GetEngineWorld() or not IEex_IsWorldScreenAcceptingInput() then return end

	if IEex_IsKeyDown(IEex_KeyIDS.LEFT_CTRL) or IEex_IsKeyDown(IEex_KeyIDS.RIGHT_CTRL) then
		key = bit.bor(key, 0x100)
	end

	local customMapIndex = IEex_Hotkeys_KeyToCustomMapIndex[key]
	if customMapIndex == nil then return end

	local func = IEex_Hotkeys_CustomBindingsHandlers[customMapIndex]
	if func ~= nil then func() end
end

function IEex_Hotkeys_GetBoundCustomMapIndex(key)

	if IEex_IsKeyDown(IEex_KeyIDS.LEFT_CTRL) or IEex_IsKeyDown(IEex_KeyIDS.RIGHT_CTRL) then
		key = bit.bor(key, 0x100)
	end

	return IEex_Hotkeys_KeyToCustomMapIndex[key]
end

IEex_Hotkeys_ScrollUpCustomMapIndices = {
	IEex_Hotkeys_CustomBinding.SCROLL_UP, IEex_Hotkeys_CustomBinding.SCROLL_UP_ALT,
}

function IEex_Hotkeys_IsScrollUp(customMapIndex)
	return customMapIndex ~= nil and IEex_FindInTable(IEex_Hotkeys_ScrollUpCustomMapIndices, customMapIndex) ~= nil
end

IEex_Hotkeys_ScrollLeftCustomMapIndices = {
	IEex_Hotkeys_CustomBinding.SCROLL_LEFT, IEex_Hotkeys_CustomBinding.SCROLL_LEFT_ALT,
}

function IEex_Hotkeys_IsScrollLeft(customMapIndex)
	return customMapIndex ~= nil and IEex_FindInTable(IEex_Hotkeys_ScrollLeftCustomMapIndices, customMapIndex) ~= nil
end

IEex_Hotkeys_ScrollDownCustomMapIndices = {
	IEex_Hotkeys_CustomBinding.SCROLL_DOWN, IEex_Hotkeys_CustomBinding.SCROLL_DOWN_ALT,
}

function IEex_Hotkeys_IsScrollDown(customMapIndex)
	return customMapIndex ~= nil and IEex_FindInTable(IEex_Hotkeys_ScrollDownCustomMapIndices, customMapIndex) ~= nil
end

IEex_Hotkeys_ScrollRightCustomMapIndices = {
	IEex_Hotkeys_CustomBinding.SCROLL_RIGHT, IEex_Hotkeys_CustomBinding.SCROLL_RIGHT_ALT,
}

function IEex_Hotkeys_IsScrollRight(customMapIndex)
	return customMapIndex ~= nil and IEex_FindInTable(IEex_Hotkeys_ScrollRightCustomMapIndices, customMapIndex) ~= nil
end

IEex_Hotkeys_ScrollTopLeftCustomMapIndices = {
	IEex_Hotkeys_CustomBinding.SCROLL_TOP_LEFT, IEex_Hotkeys_CustomBinding.SCROLL_TOP_LEFT_ALT,
}

function IEex_Hotkeys_IsScrollTopLeft(customMapIndex)
	return customMapIndex ~= nil and IEex_FindInTable(IEex_Hotkeys_ScrollTopLeftCustomMapIndices, customMapIndex) ~= nil
end

IEex_Hotkeys_ScrollBottomLeftCustomMapIndices = {
	IEex_Hotkeys_CustomBinding.SCROLL_BOTTOM_LEFT, IEex_Hotkeys_CustomBinding.SCROLL_BOTTOM_LEFT_ALT,
}

function IEex_Hotkeys_IsScrollBottomLeft(customMapIndex)
	return customMapIndex ~= nil and IEex_FindInTable(IEex_Hotkeys_ScrollBottomLeftCustomMapIndices, customMapIndex) ~= nil
end

IEex_Hotkeys_ScrollBottomRightCustomMapIndices = {
	IEex_Hotkeys_CustomBinding.SCROLL_BOTTOM_RIGHT, IEex_Hotkeys_CustomBinding.SCROLL_BOTTOM_RIGHT_ALT,
}

function IEex_Hotkeys_IsScrollBottomRight(customMapIndex)
	return customMapIndex ~= nil and IEex_FindInTable(IEex_Hotkeys_ScrollBottomRightCustomMapIndices, customMapIndex) ~= nil
end

IEex_Hotkeys_ScrollTopRightCustomMapIndices = {
	IEex_Hotkeys_CustomBinding.SCROLL_TOP_RIGHT, IEex_Hotkeys_CustomBinding.SCROLL_TOP_RIGHT_ALT,
}

function IEex_Hotkeys_IsScrollTopRight(customMapIndex)
	return customMapIndex ~= nil and IEex_FindInTable(IEex_Hotkeys_ScrollTopRightCustomMapIndices, customMapIndex) ~= nil
end

IEex_AbsoluteOnce("IEex_Hotkeys", function()
	IEex_Helper_RegisterKeysScreenHardcodedMapDefaults(IEex_Hotkeys_HardcodedMapDefaults)
	IEex_Helper_RegisterKeysScreenCustomBindings(IEex_Hotkeys_CustomBindings)
end)

----------------
-- OlvynChuru --
----------------

ex_current_menu_spell_level = 1
ex_menu_in_second_replacement_step = false
function IEex_DisplayWizardSpellsToLearn(level)
	local screenCharacter = IEex_GetEngineCharacter()
	local actorID = IEex_ReadDword(screenCharacter + 0x136)
	if not IEex_IsSprite(actorID, false) then return end
	local newWizardSpellsPanel = IEex_GetPanelFromEngine(screenCharacter, 58)
	if ex_alternate_spell_menu_class == 11 then
		IEex_SetControlLabelText(IEex_GetControlFromPanel(newWizardSpellsPanel, 33), IEex_FetchString(ex_spelllevelmenustrrefs[level]))
		for i = 1, 30, 1 do
			if i <= #ex_menu_available_wizard_spells[level] then
				IEex_SetControlButtonMageSpellInfoIcon(IEex_GetControlFromPanel(newWizardSpellsPanel, i + 99), ex_menu_available_wizard_spells[level][i])
			else
				IEex_SetControlButtonMageSpellInfoIcon(IEex_GetControlFromPanel(newWizardSpellsPanel, i + 99), "")
			end
		end
	elseif ex_alternate_spell_menu_class == 2 or ex_alternate_spell_menu_class == 10 then
		IEex_SetControlLabelText(IEex_GetControlFromPanel(newWizardSpellsPanel, 33), IEex_FetchString(ex_spelllevelreplacementmenustrrefs[level]))
		if not ex_menu_in_second_replacement_step then
			local i = 1
			for spellRES, isKnown in pairs(ex_menu_known_wizard_spells[level]) do
				if isKnown then
					if ex_menu_sorcerer_spells_replaced[spellRES] then
						IEex_SetControlButtonMageSpellInfoIcon(IEex_GetControlFromPanel(newWizardSpellsPanel, i + 99), ex_menu_sorcerer_spells_replaced[spellRES])
						IEex_SetControlButtonFrameUpForce(IEex_GetControlFromPanel(newWizardSpellsPanel, i - 1), 0)
					else
						IEex_SetControlButtonMageSpellInfoIcon(IEex_GetControlFromPanel(newWizardSpellsPanel, i + 99), spellRES)
						IEex_SetControlButtonFrameUpForce(IEex_GetControlFromPanel(newWizardSpellsPanel, i - 1), 1)
					end
					i = i + 1
				end
			end
			for j = i, 30, 1 do
				IEex_SetControlButtonMageSpellInfoIcon(IEex_GetControlFromPanel(newWizardSpellsPanel, j + 99), "")
				IEex_SetControlButtonFrameUpForce(IEex_GetControlFromPanel(newWizardSpellsPanel, j - 1), 1)
			end
		else
			for i = 1, 30, 1 do
				if i <= #ex_menu_available_wizard_spells[level] and not ex_menu_wizard_spells_learned[ex_menu_available_wizard_spells[level][i]] then
					IEex_SetControlButtonMageSpellInfoIcon(IEex_GetControlFromPanel(newWizardSpellsPanel, i + 99), ex_menu_available_wizard_spells[level][i])
				else
					IEex_SetControlButtonMageSpellInfoIcon(IEex_GetControlFromPanel(newWizardSpellsPanel, i + 99), "")
				end
				IEex_SetControlButtonFrameUpForce(IEex_GetControlFromPanel(newWizardSpellsPanel, i - 1), 1)
			end
		end
	end
	local leftButton = IEex_GetControlFromPanel(newWizardSpellsPanel, 36)
	local rightButton = IEex_GetControlFromPanel(newWizardSpellsPanel, 37)
	if level <= 1 or ex_menu_in_second_replacement_step then
		IEex_SetControlButtonFrameUpForce(leftButton, 3)
		IEex_SetControlButtonFrameDown(leftButton, 3)
	else
		IEex_SetControlButtonFrameUpForce(leftButton, 1)
		IEex_SetControlButtonFrameDown(leftButton, 2)
	end
	if level >= ex_menu_max_castable_level or ex_menu_in_second_replacement_step then
		IEex_SetControlButtonFrameUpForce(rightButton, 3)
		IEex_SetControlButtonFrameDown(rightButton, 3)
	else
		IEex_SetControlButtonFrameUpForce(rightButton, 1)
		IEex_SetControlButtonFrameDown(rightButton, 2)
	end
end

ex_menu_known_wizard_spells = {{}, {}, {}, {}, {}, {}, {}, {}, {}, }
ex_menu_available_wizard_spells = {{}, {}, {}, {}, {}, {}, {}, {}, {}, }
ex_menu_num_known_spells_per_level = {0, 0, 0, 0, 0, 0, 0, 0, 0}
ex_menu_max_castable_level = 0
function IEex_InitializeWizardLearnList()
	local screenCharacter = IEex_GetEngineCharacter()
	local actorID = IEex_ReadDword(screenCharacter + 0x136)
	if not IEex_IsSprite(actorID, false) then return end
	local kit = IEex_GetActorStat(actorID, 89)
	local specialistBit = 0x40
	local specialistSchool = 0
	for i = 1, 9, 1 do
		if bit.band(kit, specialistBit) > 0 then
			specialistSchool = i
		end
		specialistBit = specialistBit * 2
	end
	if specialistSchool == 0 then
		specialistSchool = 9
	end
	local knownSpellsOfLevel = {}
	local casterType = IEex_CasterClassToType[ex_alternate_spell_menu_class]
	local spells = IEex_FetchSpellInfo(actorID, {casterType})
	local levelList = spells[casterType]
	if ex_alternate_spell_menu_class == 11 then
		ex_menu_max_castable_level = 0
	end
	ex_menu_known_wizard_spells = {{}, {}, {}, {}, {}, {}, {}, {}, {}, }
	ex_menu_available_wizard_spells = {{}, {}, {}, {}, {}, {}, {}, {}, {}, }
	ex_menu_num_known_spells_per_level = {0, 0, 0, 0, 0, 0, 0, 0, 0}
	if levelList ~= nil then
		for level = 1, #levelList, 1 do
			local levelI = levelList[level]
			if levelI ~= nil then
				if levelI[1] > 0 then
					if ex_alternate_spell_menu_class == 11 then
						ex_menu_max_castable_level = ex_menu_max_castable_level + 1
					end
					local levelISpells = levelI[3]
					if #levelISpells > 0 then
						for i, spell in ipairs(levelISpells) do
							ex_menu_known_wizard_spells[level][spell["resref"]] = true
							ex_menu_num_known_spells_per_level[level] = ex_menu_num_known_spells_per_level[level] + 1
						end
					end
				end
			end
		end
	end
	local alignment = IEex_ReadByte(IEex_GetActorShare(actorID) + 0x35, 0x0)
	local listspll = IEex_2DADemand("LISTSPLL")
	local m_nSizeY = IEex_ReadWord(listspll + 0x22, 0x0)
	for i = 0, m_nSizeY - 1, 1 do
		local wizardLevel = tonumber(IEex_2DAGetAt(listspll, casterType - 1, i))
		local spellRES = IEex_2DAGetAt(listspll, 7, i)
		if wizardLevel > 0 and wizardLevel <= ex_menu_max_castable_level and not ex_menu_known_wizard_spells[wizardLevel][spellRES] then
			local scrollWrapper = IEex_DemandRes(spellRES .. "Z", "ITM")
			if scrollWrapper:isValid() then
				local scrollData = scrollWrapper:getData()
				local unusabilityFlags = IEex_ReadDword(scrollData + 0x1E)
				local kitUnusability3 = IEex_ReadByte(scrollData + 0x2D, 0x0)
				local kitUnusability4 = IEex_ReadByte(scrollData + 0x2F, 0x0)
				if (bit.band(unusabilityFlags, 0x1000) == 0 or bit.band(alignment, 0x30) ~= 0x30) and (bit.band(unusabilityFlags, 0x2000) == 0 or bit.band(alignment, 0x3) ~= 0x3) and (bit.band(unusabilityFlags, 0x4000) == 0 or bit.band(alignment, 0x3) ~= 0x1) and (bit.band(unusabilityFlags, 0x8000) == 0 or bit.band(alignment, 0x3) ~= 0x2) and (bit.band(unusabilityFlags, 0x10000) == 0 or bit.band(alignment, 0x30) ~= 0x10) and (bit.band(unusabilityFlags, 0x20000) == 0 or bit.band(alignment, 0x30) ~= 0x20) then
					if ex_alternate_spell_menu_class ~= 11 or (((specialistSchool == 1 or specialistSchool == 2) and bit.band(kitUnusability4, 2 ^ (specialistSchool + 5)) == 0x0) or (specialistSchool >= 3 and bit.band(kitUnusability3, 2 ^ (specialistSchool - 3)) == 0x0)) then
						table.insert(ex_menu_available_wizard_spells[wizardLevel], spellRES)
					end
				end
			end
			scrollWrapper:free()
		end
	end
	IEex_NewWizardSpellsPanelDoneButtonUpdate()
end

function IEex_NewWizardSpellsPanelDoneButtonClickable()
	if ex_alternate_spell_menu_class == 2 or ex_alternate_spell_menu_class == 10 then
		return (not ex_menu_in_second_replacement_step)
	else
		if ex_menu_num_wizard_spells_remaining == 0 then return true end
		local isClickable = true
		for level = 1, ex_menu_max_castable_level, 1 do
			if ex_menu_num_learned_spells_per_level[level] < #ex_menu_available_wizard_spells[level] and (ex_menu_num_known_spells_per_level[level] + ex_menu_num_learned_spells_per_level[level]) < 24 then
				isClickable = false
			end
		end
		return isClickable
	end
end

function IEex_NewWizardSpellsPanelDoneButtonUpdate()
	local screenCharacter = IEex_GetEngineCharacter()
	local newWizardSpellsPanel = IEex_GetPanelFromEngine(screenCharacter, 58)
	local doneButton = IEex_GetControlFromPanel(newWizardSpellsPanel, 35)
	if not IEex_NewWizardSpellsPanelDoneButtonClickable() then
		IEex_SetControlButtonFrameUpForce(doneButton, 3)
		IEex_SetControlButtonFrameDown(doneButton, 3)
	else
		IEex_SetControlButtonFrameUpForce(doneButton, 1)
		IEex_SetControlButtonFrameDown(doneButton, 2)
	end
end

------------------------------------
-- Record Screen Description Hook --
------------------------------------

------------------
-- Thread: Both --
------------------
ex_class_name_strings = {
{34},
{1083},
{1079, 38097, 38098, 38099, 38100, 38101, 38102, 38103, 38106, 38107},
{1080},
{10174},
{33, 36877, 36878, 36879},
{1078, 36875, 36872, 36873},
{1077},
{1082},
{32, 40352},
{9987, 502, 504, 2012, 2022, 3015, 2862, 12744, 12745},
}
ex_current_record_hand = 1
ex_current_record_actorID = 0
ex_current_record_weapon_die_number = 0
ex_current_record_weapon_die_size = 0
ex_previous_line_was_race = false
ex_checking_bonus_spells = false
ex_current_record_on_weapon_statistics = false
function IEex_Extern_OnUpdateRecordDescription(CScreenCharacter, CGameSprite, CUIControlEditMultiLine, m_plstStrings)
	IEex_AssertThread(IEex_Thread.Both, true)
	local creatureData = CGameSprite
	local targetID = IEex_GetActorIDShare(creatureData)
	ex_current_record_actorID = targetID
	local descPanelNum = IEex_ReadByte(CScreenCharacter + 0x1844, 0)
	local extraFlags = IEex_ReadDword(creatureData + 0x740)
	if bit.band(extraFlags, 0x1000) > 0 then
		IEex_WriteDword(creatureData + 0x740, bit.band(extraFlags, 0xFFFFEFFF))
		local armoredArcanaFeatCount = IEex_ReadByte(creatureData + 0x781, 0x0)
		IEex_WriteByte(creatureData + 0x781, math.floor(armoredArcanaFeatCount / ex_armored_arcana_multiplier))
	end
	local levelString = IEex_FetchString(7192)
	local bonusSpellsString = IEex_FetchString(10344)
	local damageString = IEex_FetchString(39518)
	local damagePotentialString = IEex_FetchString(41120)
	local castingFailureString = IEex_FetchString(41390)
	local armoredArcanaString = IEex_FetchString(36352)
	local sneakAttackDamageString = IEex_FetchString(24898)
	local turnUndeadLevelString = IEex_FetchString(12126)
	local wholenessOfBodyString = IEex_FetchString(39768)
	local abilitiesString = IEex_FetchString(33547)
	local expertiseString = IEex_FetchString(39818)
	local genericString = IEex_FetchString(33552)
	local monkWisdomBonusString = ex_str_925
	local mainhandString = IEex_FetchString(734)
	local offhandString = IEex_FetchString(733)
	local strengthString = IEex_FetchString(1145)
	local dexterityString = IEex_FetchString(1151)
	local proficiencyString = IEex_FetchString(32561)
	local raceString = IEex_FetchString(1048)
	local baseString = IEex_FetchString(31353)
	local rangedString = IEex_FetchString(41123)
	local numberOfAttacksString = IEex_FetchString(9458)
	local criticalHitString = IEex_FetchString(41122)
	local favoredClassString = IEex_FetchString(40310)
	local acidString = IEex_FetchString(15578)
	local coldString = IEex_FetchString(15546)
	local electricityString = IEex_FetchString(15577)
	local fireString = IEex_FetchString(15545)
	local magicDamageString = IEex_FetchString(40319)
	local poisonString = IEex_FetchString(5805)
	local slashingString = IEex_FetchString(11768)
	local piercingString = IEex_FetchString(11769)
	local bludgeoningString = IEex_FetchString(11770)
	local missileString = IEex_FetchString(11767)
	local hasDamageImmunity = false
	local damageImmunityList = {[0x0] = 0, [0x1] = 0, [0x2] = 0, [0x4] = 0, [0x8] = 0, [0x10] = 0, [0x20] = 0, [0x40] = 0, [0x80] = 0, [0x100] = 0, }
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		if theopcode == 288 and theparameter2 == 214 then
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if damageImmunityList[theparameter1] then
				hasDamageImmunity = true
				if bit.band(thesavingthrow, 0x10000) > 0 then
					damageImmunityList[theparameter1] = 2
				else
					damageImmunityList[theparameter1] = 1
				end
			end
		end
	end)
	local lookForClassNames = (descPanelNum == 0)
	ex_current_record_on_weapon_statistics = false
	IEex_IterateCPtrListNode(m_plstStrings, function(lineEntry, node)
		local line = IEex_ReadString(IEex_ReadDword(lineEntry + 0x4))

		if string.match(line, mainhandString) or string.match(line, rangedString) then
			ex_current_record_hand = 1
		elseif string.match(line, offhandString) then
			ex_current_record_hand = 2
		end
		if lookForClassNames then
			IEex_IterateActorEffects(targetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				if theopcode == 500 and theresource == "MECLSNAM" then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					local found_it = false
					for k, v in ipairs(ex_class_name_strings[theparameter2]) do
						local classString = IEex_FetchString(v)
						if not found_it and string.match(line, classString .. ":") then
							found_it = true
							line = string.gsub(line, classString, IEex_FetchString(theparameter1))
						end
					end
				end
			end)
			if string.match(line, favoredClassString) then
				lookForClassNames = false
			end
		elseif ex_previous_line_was_race then
			ex_previous_line_was_race = false
			if IEex_ReadByte(creatureData + 0x7B3, 0x0) > 4 then
				line = line .. IEex_FetchString(ex_tra_55603)
			end
		elseif string.match(line, raceString) then
			ex_previous_line_was_race = true
		elseif string.match(line, sneakAttackDamageString .. ":") then
			local rogueLevel = IEex_GetActorStat(targetID, 104)
			local sneakAttackDiceNumberMainHand = math.floor((rogueLevel + 1) / 2) + IEex_ReadByte(creatureData + 0x744 + ex_feat_name_id["ME_IMPROVED_SNEAK_ATTACK"], 0x0)
			local sneakAttackDiceNumberOffHand = sneakAttackDiceNumberMainHand
			local isLauncher = false
			local numWeapons = 0
			IEex_IterateActorEffects(targetID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if theopcode == 288 and theparameter2 == 192 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					if bit.band(thesavingthrow, 0x30000) == 0 and (bit.band(thesavingthrow, 0x40000) > 0 or rogueLevel > 0) then
						sneakAttackDiceNumberMainHand = sneakAttackDiceNumberMainHand + theparameter1
						sneakAttackDiceNumberOffHand = sneakAttackDiceNumberOffHand + theparameter1
					end
				elseif theopcode == 288 and theparameter2 == 241 then
					if thespecial == 5 then
						numWeapons = numWeapons + 1
					elseif thespecial == 7 then
						isLauncher = true
					end
				end
			end)
			local weaponSlot = IEex_ReadByte(creatureData + 0x4BA4, 0x0)
			local weaponHeader = IEex_ReadWord(creatureData + 0x4BA6, 0x0)
			local slotData = IEex_ReadDword(creatureData + 0x4AD8 + weaponSlot * 0x4)
			local weaponRES = ""
			local weaponWrapper = 0
--			local headerType = 1
			local offhandSlotData = 0
			local offhandRES = ""
			if slotData > 0 then
				weaponRES = IEex_ReadLString(slotData + 0xC, 8)
				local weaponWrapper = IEex_DemandRes(weaponRES, "ITM")
				if weaponWrapper:isValid() then
					local weaponData = weaponWrapper:getData()
					local numHeaders = IEex_ReadSignedWord(weaponData + 0x68, 0x0)
					if weaponHeader >= numHeaders then
						weaponHeader = 0
					end
					local numEffects = IEex_ReadWord(weaponData + 0x82 + weaponHeader * 0x38 + 0x1E, 0x0)
					local firstEffectIndex = IEex_ReadWord(weaponData + 0x82 + weaponHeader * 0x38 + 0x20, 0x0)
--					local itemType = IEex_ReadWord(weaponData + 0x1C, 0x0)
--					headerType = IEex_ReadByte(weaponData + 0x82 + weaponHeader * 0x38, 0x0)
					local effectOffset = IEex_ReadDword(weaponData + 0x6A)
					local numGlobalEffects = IEex_ReadWord(weaponData + 0x70, 0x0)
					for i = 0, numGlobalEffects - 1, 1 do
						local offset = weaponData + effectOffset + i * 0x30
						local theopcode = IEex_ReadWord(offset, 0x0)
						local theparameter2 = IEex_ReadDword(offset + 0x8)
						if theopcode == 288 and theparameter2 == 192 then
							local theparameter1 = IEex_ReadDword(offset + 0x4)
							local thesavingthrow = IEex_ReadDword(offset + 0x24)
							if bit.band(thesavingthrow, 0x30000) == 0x10000 and (bit.band(thesavingthrow, 0x40000) > 0 or rogueLevel > 0) then
								sneakAttackDiceNumberMainHand = sneakAttackDiceNumberMainHand + theparameter1
							end
						end
					end
					for i = firstEffectIndex, firstEffectIndex + numEffects - 1, 1 do
						local offset = weaponData + effectOffset + i * 0x30
						local theopcode = IEex_ReadWord(offset, 0x0)
						local theresource = IEex_ReadLString(offset + 0x14, 8)
						if theopcode == 500 and theresource == "EXDAMAGE" then
							local headerExtraSneakAttackDice = IEex_ReadByte(offset + 0x6, 0x0)
							local thesavingthrow = IEex_ReadDword(offset + 0x24)
							if bit.band(thesavingthrow, 0x1800000) == 0x1800000 and sneakAttackDiceNumberMainHand > 0 then
								sneakAttackDiceNumberMainHand = sneakAttackDiceNumberMainHand + headerExtraSneakAttackDice
							end
						end
					end
				end
				weaponWrapper:free()
			end
			if weaponSlot == 42 and numWeapons >= 2 then
				numWeapons = 1
			end
			if numWeapons >= 2 and weaponSlot >= 43 then
				offhandSlotData = IEex_ReadDword(creatureData + 0x4AD8 + (weaponSlot + 1) * 0x4)
				if offhandSlotData > 0 then
					offhandRES = IEex_ReadLString(offhandSlotData + 0xC, 8)
					local offhandWrapper = IEex_DemandRes(offhandRES, "ITM")
					if offhandWrapper:isValid() then
						local weaponData = offhandWrapper:getData()
						local numEffects = IEex_ReadWord(weaponData + 0x82 + 0x1E, 0x0)
						local firstEffectIndex = IEex_ReadWord(weaponData + 0x82 + 0x20, 0x0)
	--					local itemType = IEex_ReadWord(weaponData + 0x1C, 0x0)
	--					headerType = IEex_ReadByte(weaponData + 0x82 + weaponHeader * 0x38, 0x0)
						local effectOffset = IEex_ReadDword(weaponData + 0x6A)
						local numGlobalEffects = IEex_ReadWord(weaponData + 0x70, 0x0)
						for i = 0, numGlobalEffects - 1, 1 do
							local offset = weaponData + effectOffset + i * 0x30
							local theopcode = IEex_ReadWord(offset, 0x0)
							local theparameter2 = IEex_ReadDword(offset + 0x8)
							if theopcode == 288 and theparameter2 == 192 then
								local theparameter1 = IEex_ReadDword(offset + 0x4)
								local thesavingthrow = IEex_ReadDword(offset + 0x24)
								if bit.band(thesavingthrow, 0x30000) == 0x10000 and (bit.band(thesavingthrow, 0x40000) > 0 or rogueLevel > 0) then
									sneakAttackDiceNumberOffHand = sneakAttackDiceNumberOffHand + theparameter1
								end
							end
						end
						for i = firstEffectIndex, firstEffectIndex + numEffects - 1, 1 do
							local offset = weaponData + effectOffset + i * 0x30
							local theopcode = IEex_ReadWord(offset, 0x0)
							local theresource = IEex_ReadLString(offset + 0x14, 8)
							if theopcode == 500 and theresource == "EXDAMAGE" then
								local headerExtraSneakAttackDice = IEex_ReadByte(offset + 0x6, 0x0)
								local thesavingthrow = IEex_ReadDword(offset + 0x24)
								if bit.band(thesavingthrow, 0x1800000) == 0x1800000 and sneakAttackDiceNumberOffHand > 0 then
									sneakAttackDiceNumberOffHand = sneakAttackDiceNumberOffHand + headerExtraSneakAttackDice
								end
							end
						end
					end
					offhandWrapper:free()
				end
			end
			if isLauncher then
				local weaponSet = IEex_ReadByte(creatureData + 0x4C68, 0x0)
				local launcherSlotData = IEex_ReadDword(creatureData + 0x4AD8 + (43 + 2 * weaponSet) * 0x4)
				if launcherSlotData > 0 then
					local launcherRES = IEex_ReadLString(launcherSlotData + 0xC, 8)
					local launcherWrapper = IEex_DemandRes(launcherRES, "ITM")
					if launcherWrapper:isValid() then
						local weaponData = launcherWrapper:getData()
						local numHeaders = IEex_ReadSignedWord(weaponData + 0x68, 0x0)
						local numEffects = IEex_ReadWord(weaponData + 0x82 + 0x1E, 0x0)
						local firstEffectIndex = IEex_ReadWord(weaponData + 0x82 + 0x20, 0x0)
	--					local itemType = IEex_ReadWord(weaponData + 0x1C, 0x0)
	--					headerType = IEex_ReadByte(weaponData + 0x82 + weaponHeader * 0x38, 0x0)
						local effectOffset = IEex_ReadDword(weaponData + 0x6A)
						local numGlobalEffects = IEex_ReadWord(weaponData + 0x70, 0x0)
						for i = 0, numGlobalEffects - 1, 1 do
							local offset = weaponData + effectOffset + i * 0x30
							local theopcode = IEex_ReadWord(offset, 0x0)
							local theparameter2 = IEex_ReadDword(offset + 0x8)
							if theopcode == 288 and theparameter2 == 192 then
								local theparameter1 = IEex_ReadDword(offset + 0x4)
								local thesavingthrow = IEex_ReadDword(offset + 0x24)
								if bit.band(thesavingthrow, 0x30000) == 0x10000 and (bit.band(thesavingthrow, 0x40000) > 0 or rogueLevel > 0) then
									sneakAttackDiceNumberMainHand = sneakAttackDiceNumberMainHand + theparameter1
								end
							end
						end
						for i = firstEffectIndex, firstEffectIndex + numEffects - 1, 1 do
							local offset = weaponData + effectOffset + i * 0x30
							local theopcode = IEex_ReadWord(offset, 0x0)
							local theresource = IEex_ReadLString(offset + 0x14, 8)
							if theopcode == 500 and theresource == "EXDAMAGE" then
								local headerExtraSneakAttackDice = IEex_ReadByte(offset + 0x6, 0x0)
								local thesavingthrow = IEex_ReadDword(offset + 0x24)
								if bit.band(thesavingthrow, 0x1800000) == 0x1800000 and sneakAttackDiceNumberMainHand > 0 then
									sneakAttackDiceNumberMainHand = sneakAttackDiceNumberMainHand + headerExtraSneakAttackDice
								end
							end
						end
					end
					launcherWrapper:free()
				end
			end
			if numWeapons >= 2 and weaponSlot >= 43 then
				line = string.gsub(line, "%d+d6", sneakAttackDiceNumberMainHand .. "d6/" .. sneakAttackDiceNumberOffHand .. "d6")
			else
				line = string.gsub(line, "%d+d6", sneakAttackDiceNumberMainHand .. "d6")
			end
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
		elseif string.match(line, monkWisdomBonusString .. ":") or string.match(line, genericString .. ":") or string.match(line, expertiseString .. ":") then
			local monkLevel = IEex_GetActorStat(targetID, 101)
			if monkLevel > 0 then
				local wisdomBonus = math.floor((IEex_GetActorStat(targetID, 39) - 10) / 2)
				if wisdomBonus > 0 then
					local monkACBonusDisabled = false
					local fixMonkACBonus = true
					local unfixMonkACBonus = (IEex_ReadByte(creatureData + 0x9D4, 0x0) > 0)
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
						elseif theopcode == 502 and theresource == "MEPOLYBL" then
							if thespecial > monkLevel then
								unfixMonkACBonus = true
							end
						end
					end)
					if not monkACBonusDisabled and unfixMonkACBonus then
						if string.match(line, monkWisdomBonusString .. ":") then
							line = string.gsub(line, "%d+", 0)
						elseif string.match(line, genericString .. ":") then
							local genericAC = string.match(line, "%d+")
							if string.match(line, "%-") then
								genericAC = genericAC * -1
							end
							genericAC = genericAC + wisdomBonus
							if genericAC > 0 then
								line = string.gsub(line, "." .. "%d+", "+" .. genericAC)
							elseif genericAC < 0 then
								line = string.gsub(line, "." .. "%d+", "-" .. math.abs(genericAC))
							else
								line = ""
							end
						end
					elseif monkACBonusDisabled and fixMonkACBonus and not unfixMonkACBonus then
						if string.match(line, monkWisdomBonusString .. ":") then
							line = string.gsub(line, "0", wisdomBonus)
						elseif string.match(line, genericString .. ":") then
							local genericAC = string.match(line, "%d+")
							if string.match(line, "%-") then
								genericAC = genericAC * -1
							end
							genericAC = genericAC - wisdomBonus
							if genericAC > 0 then
								line = string.gsub(line, "." .. "%d+", "+" .. genericAC)
							elseif genericAC < 0 then
								line = string.gsub(line, "." .. "%d+", "-" .. math.abs(genericAC))
							else
								line = ""
							end
						end
					end
				end
			end
			local expertiseCount = IEex_ReadDword(creatureData + 0x4C54)
			if expertiseCount > 0 then
				local actionID = IEex_ReadWord(creatureData + 0x476, 0x0)
				if actionID ~= 3 and actionID ~= 94 and actionID ~= 98 and actionID ~= 105 and actionID ~= 134 and actionID ~= 27 then
					local isRanged = false
					local weaponSlot = IEex_ReadByte(creatureData + 0x4BA4, 0x0)
					local weaponHeader = IEex_ReadByte(creatureData + 0x4BA6, 0x0)
					local weaponRES = ""
					local slotData = IEex_ReadDword(creatureData + 0x4AD8 + weaponSlot * 0x4)
					local weaponWrapper = 0
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
							local itemType = IEex_ReadWord(itemData + 0x1C, 0x0)
							if headerType == 2 then
								isRanged = true
							end
						end
					end
					if not isRanged then
						if string.match(line, expertiseString .. ":") then
							line = string.gsub(line, "%d+", 0)
						elseif string.match(line, genericString .. ":") then
							local genericAC = string.match(line, "%d+")
							if string.match(line, "%-") then
								genericAC = genericAC * -1
							end
							genericAC = genericAC + expertiseCount
							if genericAC > 0 then
								line = string.gsub(line, "." .. "%d+", "+" .. genericAC)
							elseif genericAC < 0 then
								line = string.gsub(line, "." .. "%d+", "-" .. math.abs(genericAC))
							else
								line = ""
							end
						end
					end
				end
			end
		elseif string.match(line, bonusSpellsString) then
			ex_checking_bonus_spells = true
		elseif ex_checking_bonus_spells and line == "" then
			ex_checking_bonus_spells = false
			if IEex_GetActorSpellState(targetID, 197) then
				local advancedSlotsList = {}
				IEex_IterateActorEffects(targetID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					local theparameter3 = IEex_ReadDword(eData + 0x60)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if theopcode == 288 and theparameter2 == 197 and bit.band(thesavingthrow, 0x10000) > 0 then
						if not advancedSlotsList[thespecial] then
							advancedSlotsList[thespecial] = {theparameter1 - theparameter3, theparameter1}
						else
							advancedSlotsList[thespecial] = {advancedSlotsList[thespecial][1] + theparameter1 - theparameter3, advancedSlotsList[thespecial][2] + theparameter1}
						end
					end
				end)
				if #advancedSlotsList > 0 then
					line = IEex_FetchString(ex_tra_55495)
				end
				local firstAdvancedSlot = true
				for k, v in ipairs(advancedSlotsList) do
					if not firstAdvancedSlot then
						line = line .. ", "
					end
					line = line .. levelString .. " +" .. k .. ": " .. v[1] .. "/" .. v[2]
					firstAdvancedSlot = false
				end
			end
		elseif descPanelNum == 1 and string.match(line, castingFailureString .. ":") then
			local armoredArcanaFeatCount = IEex_ReadByte(creatureData + 0x781, 0x0)
			local castingFailure = string.match(line, "%d+")
			castingFailure = castingFailure - (armoredArcanaFeatCount * (ex_armored_arcana_multiplier - 1)) * 5
			if castingFailure < 0 then
				castingFailure = 0
			end
			line = string.gsub(line, "%d+", castingFailure)
		elseif descPanelNum == 1 and string.match(line, armoredArcanaString .. ":") then
			local armoredArcanaFeatCount = IEex_ReadByte(creatureData + 0x781, 0x0)
			line = string.gsub(line, "%d+", (armoredArcanaFeatCount * ex_armored_arcana_multiplier) * 5)
		elseif descPanelNum == 1 and string.match(line, abilitiesString .. ":") then
			local abilityBonus = string.match(line, "%d+")
			if string.match(line, "%-") then
				abilityBonus = abilityBonus * -1
			end
			if ex_current_record_hand == 1 then
				abilityBonus = abilityBonus + IEex_ReadSignedByte(creatureData + 0x9F8, 0x0)
			else
				abilityBonus = abilityBonus + IEex_ReadSignedByte(creatureData + 0x9FC, 0x0)
			end
			if abilityBonus > 0 then
				line = string.gsub(line, "." .. "%d+", "+" .. abilityBonus)
			elseif abilityBonus < 0 then
				line = string.gsub(line, "." .. "%d+", "-" .. math.abs(abilityBonus))
			else
				line = ""
			end
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
			local firstFiveAttacksDisabled = {0, 0, 0, 0, 0}
			local firstFiveAttacksFixed = {0, 0, 0, 0, 0}
			local weaponSlot = IEex_ReadByte(creatureData + 0x4BA4, 0x0)
			local weaponHeader = IEex_ReadByte(creatureData + 0x4BA6, 0x0)
			local slotData = IEex_ReadDword(creatureData + 0x4AD8 + weaponSlot * 0x4)
			local weaponRES = ""
			local weaponWrapper = 0
			local rapidShotActive = false
			if slotData > 0 then
				weaponRES = IEex_ReadLString(slotData + 0xC, 8)
				weaponWrapper = IEex_DemandRes(weaponRES, "ITM")
				if weaponWrapper:isValid() then
					local weaponData = weaponWrapper:getData()
					local numHeaders = IEex_ReadSignedWord(weaponData + 0x68, 0x0)
					if weaponHeader >= numHeaders then
						weaponHeader = 0
					end
					local itemType = IEex_ReadWord(weaponData + 0x1C, 0x0)
					headerType = IEex_ReadByte(weaponData + 0x82 + weaponHeader * 0x38, 0x0)
					if rapidShotEnabled and headerType == 2 and itemType ~= 27 and itemType ~= 31 then
						rapidShotActive = true
					end
				end
			end
			if monkAttackBonusDisabled and fixMonkAttackBonus then
				trueBaseAPR = tonumber(IEex_2DAGetAtStrings("BAATMKU", "NUM_ATTACKS", tostring(monkLevel)))
				if trueBaseAPR > 4 then
					trueBaseAPR = 4
				end
				firstFiveAttacksDisabled[1] = tonumber(IEex_2DAGetAtStrings("BAATNFG", "BASE_ATTACK", tostring(monkLevel)))
				firstFiveAttacksFixed[1] = tonumber(IEex_2DAGetAtStrings("BAATMKU", "BASE_ATTACK", tostring(monkLevel)))
				for i = 2, 5, 1 do
					if i == 2 and rapidShotActive then
						firstFiveAttacksDisabled[i] = firstFiveAttacksDisabled[i - 1]
						firstFiveAttacksFixed[i] = firstFiveAttacksFixed[i - 1]
					else
						firstFiveAttacksDisabled[i] = firstFiveAttacksDisabled[i - 1] - 5
						if firstFiveAttacksDisabled[i] < 0 then
							firstFiveAttacksDisabled[i] = 0
						end
						firstFiveAttacksFixed[i] = firstFiveAttacksFixed[i - 1] - 3
					end
				end
--				handSpecificAttackBonus = handSpecificAttackBonus + tonumber(IEex_2DAGetAtStrings("BAATMKU", "BASE_ATTACK", tostring(monkLevel))) - tonumber(IEex_2DAGetAtStrings("BAATNFG", "BASE_ATTACK", tostring(monkLevel)))
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
					if monkAttackBonusDisabled and fixMonkAttackBonus then
						monkAttackPenaltyIncrementFix = firstFiveAttacksFixed[attackI] - firstFiveAttacksDisabled[attackI]
					end
					line = string.gsub(line, "!" .. w .. "!", w + handSpecificAttackBonus + monkAttackPenaltyIncrementFix, 1)
				end
			end

			if ((normalAPR + imptwfFeatCount + extraMonkAttacks >= 5) or ((trueBaseAPR + imptwfFeatCount + extraMonkAttacks >= 5))) or (manyshotFeatCount > 0 and rapidShotEnabled) then
				local totalAttacks = trueBaseAPR + extraMonkAttacks
				local extraAttacks = 0
				local extraMainhandAttacks = extraMonkAttacks
				local manyshotAttacks = manyshotFeatCount
				local numWeapons = 0
				local headerType = 1
				local offhandSlotData = 0
				local offhandRES = ""
				if slotData > 0 then
					weaponRES = IEex_ReadLString(slotData + 0xC, 8)
					local weaponWrapper = IEex_DemandRes(weaponRES, "ITM")
					if weaponWrapper:isValid() then
						local weaponData = weaponWrapper:getData()
						local numHeaders = IEex_ReadSignedWord(weaponData + 0x68, 0x0)
						if weaponHeader >= numHeaders then
							weaponHeader = 0
						end
						local itemType = IEex_ReadWord(weaponData + 0x1C, 0x0)
						headerType = IEex_ReadByte(weaponData + 0x82 + weaponHeader * 0x38, 0x0)
						if rapidShotEnabled and headerType == 2 and itemType ~= 27 and itemType ~= 31 then
							totalAttacks = totalAttacks + 1
							extraMainhandAttacks = extraMainhandAttacks + 1
						end
						local effectOffset = IEex_ReadDword(weaponData + 0x6A)
						local numGlobalEffects = IEex_ReadWord(weaponData + 0x70, 0x0)
						for i = 0, numGlobalEffects - 1, 1 do
							local offset = weaponData + effectOffset + i * 0x30
							local theopcode = IEex_ReadWord(offset, 0x0)
							local theparameter2 = IEex_ReadDword(offset + 0x8)
							if theopcode == 1 and theparameter2 == 0 then
								local theparameter1 = IEex_ReadDword(offset + 0x4)
								totalAttacks = totalAttacks + theparameter1
								extraMainhandAttacks = extraMainhandAttacks + theparameter1
							end
						end
					end
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
					end
				end)
				if weaponSlot == 42 and numWeapons >= 2 then
					numWeapons = 1
				end
				if numWeapons >= 2 and weaponSlot >= 43 then
					offhandSlotData = IEex_ReadDword(creatureData + 0x4AD8 + (weaponSlot + 1) * 0x4)
					if offhandSlotData > 0 then
						offhandRES = IEex_ReadLString(offhandSlotData + 0xC, 8)
						local offhandWrapper = IEex_DemandRes(offhandRES, "ITM")
						if offhandWrapper:isValid() then
							local weaponData = offhandWrapper:getData()
							local effectOffset = IEex_ReadDword(weaponData + 0x6A)
							local numGlobalEffects = IEex_ReadWord(weaponData + 0x70, 0x0)
							for i = 0, numGlobalEffects - 1, 1 do
								local offset = weaponData + effectOffset + i * 0x30
								local theopcode = IEex_ReadWord(offset, 0x0)
								local theparameter2 = IEex_ReadDword(offset + 0x8)
								if theopcode == 1 and theparameter2 == 0 then
									local theparameter1 = IEex_ReadDword(offset + 0x4)
									totalAttacks = totalAttacks + theparameter1
									extraAttacks = extraAttacks + theparameter1
								end
							end
						end
						offhandWrapper:free()
					end
				end
				IEex_IterateActorEffects(targetID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thespecial = IEex_ReadDword(eData + 0x48)
					local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
					if theopcode == 1 then
						if theparameter2 == 0 and theparent_resource ~= weaponRES and theparent_resource ~= offhandRES then
							totalAttacks = totalAttacks + theparameter1
							if bit.band(thesavingthrow, 0x100000) > 0 and offhandRES ~= "" then
								extraAttacks = extraAttacks + theparameter1
							else
								extraMainhandAttacks = extraMainhandAttacks + theparameter1
							end
						elseif theparameter2 == 1 then
							totalAttacks = theparameter1
							if setAPR ~= 0 then
								setAPR = theparameter1
							end
						end
					elseif theopcode == 288 and theparameter2 == 196 and (thespecial == 0 or thespecial == headerType) then
						if bit.band(thesavingthrow, 0x20000) > 0 then
							manyshotAttacks = manyshotAttacks + theparameter1
						end
					end
				end)
				if not isBow or not rapidShotEnabled then
					manyshotAttacks = 0
				end
				local usingImptwf = false
				if numWeapons >= 2 then
					totalAttacks = totalAttacks + 1
				end
				local stateValue = bit.bor(IEex_ReadDword(creatureData + 0x5BC), IEex_ReadDword(creatureData + 0x920))
				if bit.band(stateValue, 0x8000) > 0 then
					totalAttacks = totalAttacks + 1
					extraMainhandAttacks = extraMainhandAttacks + 1
				end
				if bit.band(stateValue, 0x10000) > 0 then
					totalAttacks = totalAttacks - 1
					extraMainhandAttacks = extraMainhandAttacks - 1
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
					if normalAPR == 5 and baseAPR < 4 then
						extraMainhandAttacks = extraMainhandAttacks + baseAPR - normalAPR + 1
					end
				else
					extraAttacks = extraAttacks + extraMainhandAttacks
					extraMainhandAttacks = 0
					if normalAPR == 5 then
						extraAttacks = extraAttacks + baseAPR - normalAPR
						if extraAttacks < 0 then
							extraAttacks = 0
						end
					end
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
				if imptwfFeatCount > 2 and numWeapons >= 2 then
					extraAttacks = extraMainhandAttacks + (normalAPR - 1)
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
			weaponWrapper:free()
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
		elseif descPanelNum == 1 and string.match(line, damageString .. ":") then
			ex_current_record_on_weapon_statistics = true
			local damageBonus = IEex_ReadSignedWord(creatureData + 0x9A6, 0x0)
			if damageBonus > 0 then
				IEex_SetToken("EXRDVAL1", damageBonus)
				line = line .. string.gsub(IEex_FetchString(ex_tra_55604), "<EXRDVAL1>", damageBonus)
			elseif damageBonus < 0 then
				IEex_SetToken("EXRDVAL1", math.abs(damageBonus))
				line = line .. string.gsub(IEex_FetchString(ex_tra_55605), "<EXRDVAL1>", math.abs(damageBonus))
			end
			local numbersProcessed = 0
			for w in string.gmatch(line, "%d+") do
				if numbersProcessed == 0 then
					ex_current_record_weapon_die_number = tonumber(w)
				elseif numbersProcessed == 1 then
					ex_current_record_weapon_die_size = tonumber(w)
				end
				numbersProcessed = numbersProcessed + 1
			end
			local luckBonus = IEex_ReadSignedWord(creatureData + 0x95C, 0x0)
			if IEex_GetActorSpellState(targetID, 64) then
				line = string.gsub(line, "%d+d%d+", ex_current_record_weapon_die_number * ex_current_record_weapon_die_size)
			elseif luckBonus > 0 then
				local minimumRoll = 1 + luckBonus
				if minimumRoll > ex_current_record_weapon_die_size then
					minimumRoll = ex_current_record_weapon_die_size
				end
				if minimumRoll == ex_current_record_weapon_die_size then
					line = string.gsub(line, "%d+d%d+", ex_current_record_weapon_die_number * ex_current_record_weapon_die_size)
				else
					IEex_SetToken("EXRLVAL1", minimumRoll)
					line = line .. string.gsub(IEex_FetchString(ex_tra_55606), "<EXRLVAL1>", minimumRoll)
				end
			elseif luckBonus < 0 then
				local maximumRoll = ex_current_record_weapon_die_size + luckBonus
				if maximumRoll < 1 then
					maximumRoll = 1
				end
				if maximumRoll == 1 then
					line = string.gsub(line, "%d+d%d+", ex_current_record_weapon_die_number)
				else
					IEex_SetToken("EXRLVAL1", maximumRoll)
					line = line .. string.gsub(IEex_FetchString(ex_tra_55607), "<EXRLVAL1>", maximumRoll)
				end
			end
		elseif descPanelNum == 1 and (string.match(line, strengthString .. ":") or string.match(line, proficiencyString .. ":")) and ex_current_record_on_weapon_statistics then
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
					if ex_current_record_hand == 1 then
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
								if finesseDifference > 0 and ((hasWeaponFinesse and ex_weapon_finesse_damage_bonus and (itemType == 16 or itemType == 19)) or (race == 5 and subrace == 0 and ex_lightfoot_halfling_thrown_dexterity_bonus_to_damage and headerType == 2 and itemType ~= 5 and itemType ~= 15 and itemType ~= 27 and itemType ~= 31) or ((race == 2 or race == 183) and ex_elf_large_sword_weapon_finesse and ex_weapon_finesse_damage_bonus and (itemType == 20))) then
									if string.match(line, strengthString .. ":") then
										line = string.gsub(line, "%p%d+", "+" .. finesseBonus)
										line = string.gsub(line, strengthString, dexterityString)
									elseif string.match(line, proficiencyString .. ":") then
										local proficiencyBonus = tonumber(string.match(line, "%d+"))
										if string.match(line, "%-") then
											proficiencyBonus = proficiencyBonus * -1
										end
										if strengthBonus == 0 then
											if proficiencyBonus == finesseDifference then
												line = string.gsub(line, proficiencyString, dexterityString)
											else
												line = string.gsub(line, proficiencyString, dexterityString .. "/" .. proficiencyString)
											end
										else
											proficiencyBonus = proficiencyBonus - finesseDifference
											if proficiencyBonus == 0 then
												IEex_RemoveEntryFromCPtrList(m_plstStrings, node)
											elseif proficiencyBonus > 0 then
												line = string.gsub(line, "%p%d+", "+" .. proficiencyBonus)
											else
												line = string.gsub(line, "%p%d+", proficiencyBonus)
											end
										end
									end
								end
							end
						end
						weaponWrapper:free()
					elseif ex_current_record_hand == 2 and hasWeaponFinesse and weaponSlot >= 43 and weaponSlot <= 49 then
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
									local offhandStrengthBonus = math.floor(strengthBonus / 2)
									if offhandStrengthBonus == 0 and strengthBonus == 1 then
										offhandStrengthBonus = 1
									end
									local finesseDifference = finesseBonus - offhandStrengthBonus
									if finesseDifference > 0 and ex_weapon_finesse_damage_bonus and (itemType == 16 or itemType == 19 or ((race == 2 or race == 183) and ex_elf_large_sword_weapon_finesse and (itemType == 20))) then
										if string.match(line, strengthString .. ":") then
											line = string.gsub(line, "%p%d+", "+" .. finesseBonus)
											line = string.gsub(line, strengthString, dexterityString)
										elseif string.match(line, proficiencyString .. ":") then

											local proficiencyBonus = tonumber(string.match(line, "%d+"))
											if string.match(line, "%-") then
												proficiencyBonus = proficiencyBonus * -1
											end
											if strengthBonus == 0 then
												if proficiencyBonus == finesseDifference then
													line = string.gsub(line, proficiencyString, dexterityString)
												else
													line = string.gsub(line, proficiencyString, dexterityString .. "/" .. proficiencyString)
												end
											else
												proficiencyBonus = proficiencyBonus - finesseDifference
												if proficiencyBonus == 0 then
													IEex_RemoveEntryFromCPtrList(m_plstStrings, node)
												elseif proficiencyBonus > 0 then
													line = string.gsub(line, "%p%d+", "+" .. proficiencyBonus)
												else
													line = string.gsub(line, "%p%d+", proficiencyBonus)
												end
											end
										end
									end
								end
							end
						end
						offhandWrapper:free()
					end
				end
			end
		elseif string.match(line, damagePotentialString .. ":") then
			local damageBonus = IEex_ReadSignedWord(creatureData + 0x9A6, 0x0)
			local numbersProcessed = 0
			local minimumDamage = 0
			local maximumDamage = 0
			for w in string.gmatch(line, "%d+") do
				if numbersProcessed == 0 then
					minimumDamage = tonumber(w)
				elseif numbersProcessed == 1 then
					maximumDamage = tonumber(w)
				end
				numbersProcessed = numbersProcessed + 1
			end
			minimumDamage = minimumDamage + damageBonus
			maximumDamage = maximumDamage + damageBonus
			local luckBonus = IEex_ReadSignedWord(creatureData + 0x95C, 0x0)
			if IEex_GetActorSpellState(targetID, 64) then
				minimumDamage = maximumDamage
			elseif luckBonus > 0 then
				local minimumRoll = 1 + luckBonus
				if minimumRoll > ex_current_record_weapon_die_size then
					minimumRoll = ex_current_record_weapon_die_size
				end
				minimumDamage = minimumDamage + (minimumRoll - 1) * ex_current_record_weapon_die_number
			elseif luckBonus < 0 then
				local maximumRoll = ex_current_record_weapon_die_size + luckBonus
				if maximumRoll < 1 then
					maximumRoll = 1
				end
				maximumDamage = maximumDamage - (ex_current_record_weapon_die_size - maximumRoll) * ex_current_record_weapon_die_number
			end
			line = string.gsub(line, "%d+%-%d+", minimumDamage .. "-" .. maximumDamage)
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
		elseif hasDamageImmunity and descPanelNum == 0 then
			if string.match(line, bludgeoningString .. ":") then
				if damageImmunityList[0x0] == 1 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55601))
				elseif damageImmunityList[0x0] == 2 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55602))
				end
			elseif string.match(line, acidString .. ":") then
				if damageImmunityList[0x1] == 1 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55601))
				elseif damageImmunityList[0x1] == 2 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55602))
				end
			elseif string.match(line, coldString .. ":") then
				if damageImmunityList[0x2] == 1 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55601))
				elseif damageImmunityList[0x2] == 2 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55602))
				end
			elseif string.match(line, electricityString .. ":") then
				if damageImmunityList[0x4] == 1 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55601))
				elseif damageImmunityList[0x4] == 2 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55602))
				end
			elseif string.match(line, fireString .. ":") then
				if damageImmunityList[0x8] == 1 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55601))
				elseif damageImmunityList[0x8] == 2 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55602))
				end
			elseif string.match(line, piercingString .. ":") then
				if damageImmunityList[0x10] == 1 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55601))
				elseif damageImmunityList[0x10] == 2 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55602))
				end
			elseif string.match(line, poisonString .. ":") then
				if damageImmunityList[0x20] == 1 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55601))
				elseif damageImmunityList[0x20] == 2 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55602))
				end
			elseif string.match(line, magicDamageString .. ":") then
				if damageImmunityList[0x40] == 1 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55601))
				elseif damageImmunityList[0x40] == 2 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55602))
				end
			elseif string.match(line, missileString .. ":") then
				if damageImmunityList[0x80] == 1 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55601))
				elseif damageImmunityList[0x80] == 2 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55602))
				end
			elseif string.match(line, slashingString .. ":") then
				if damageImmunityList[0x100] == 1 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55601))
				elseif damageImmunityList[0x100] == 2 then
					line = string.gsub(line, "%d+", IEex_FetchString(ex_tra_55602))
				end
			end
		end
		-- do whatever changes you want to the line here
		IEex_CString_Set(lineEntry + 0x4, line)
	end)
	local bardLevel = IEex_ReadByte(creatureData + 0x628, 0x0)
	if bardLevel > 0 then
		local baseSpellSlots = {0, 0, 0, 0, 0, 0, 0, 0}
		for level, baseNumSlots in ipairs(baseSpellSlots) do
			baseNumSlots = tonumber(IEex_2DAGetAtStrings("MXSPLBRD", tostring(level), tostring(bardLevel)))
			if baseNumSlots > 0 then
				local spellListOffset = IEex_ReadDword(creatureData + 0x4288 + 0x1C * (level - 1))
				local spellListEnd = IEex_ReadDword(creatureData + 0x428C + 0x1C * (level - 1))
				while spellListOffset < spellListEnd do
					if IEex_ReadDword(spellListOffset + 0x8) > baseNumSlots then
						IEex_WriteDword(spellListOffset + 0x8, baseNumSlots)
					end
					spellListOffset = spellListOffset + 0x10
				end
			end
		end
	end
	local sorcererLevel = IEex_ReadByte(creatureData + 0x630, 0x0)
	if sorcererLevel > 0 then
		local baseSpellSlots = {0, 0, 0, 0, 0, 0, 0, 0, 0}
		for level, baseNumSlots in ipairs(baseSpellSlots) do
			baseNumSlots = tonumber(IEex_2DAGetAtStrings("MXSPLSOR", tostring(level), tostring(sorcererLevel)))
			if baseNumSlots > 0 then
				local spellListOffset = IEex_ReadDword(creatureData + 0x4788 + 0x1C * (level - 1))
				local spellListEnd = IEex_ReadDword(creatureData + 0x478C + 0x1C * (level - 1))
				while spellListOffset < spellListEnd do
					if IEex_ReadDword(spellListOffset + 0x8) > baseNumSlots then
						IEex_WriteDword(spellListOffset + 0x8, baseNumSlots)
					end
					spellListOffset = spellListOffset + 0x10
				end
			end
		end
	end
end
