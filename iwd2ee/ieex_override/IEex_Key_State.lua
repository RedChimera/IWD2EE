
IEex_KeyIDS = {
	["LEFT_MOUSE_CLICK"] = 1,
	["RIGHT_MOUSE_CLICK"] = 2,
	["MIDDLE_MOUSE_CLICK"] = 4,
	["BACKSPACE"] = 8,
	["TAB"] = 9,
	["ENTER"] = 13,
	["ESC"] = 27,
	["SPACE_BAR"] = 32,
	["PAGE_UP"] = 33,
	["PAGE_DOWN"] = 34,
	["END"] = 35,
	["HOME"] = 36,
	["LEFT"] = 37,
	["UP"] = 38,
	["RIGHT"] = 39,
	["DOWN"] = 40,
	["PRINT_SCREEN"] = 44,
	["DELETE"] = 46,
	["0"] = 48,
	["1"] = 49,
	["2"] = 50,
	["3"] = 51,
	["4"] = 52,
	["5"] = 53,
	["6"] = 54,
	["7"] = 55,
	["8"] = 56,
	["9"] = 57,
	["A"] = 65,
	["B"] = 66,
	["C"] = 67,
	["D"] = 68,
	["E"] = 69,
	["F"] = 70,
	["G"] = 71,
	["H"] = 72,
	["I"] = 73,
	["J"] = 74,
	["K"] = 75,
	["L"] = 76,
	["M"] = 77,
	["N"] = 78,
	["O"] = 79,
	["P"] = 80,
	["Q"] = 81,
	["R"] = 82,
	["S"] = 83,
	["T"] = 84,
	["U"] = 85,
	["V"] = 86,
	["W"] = 87,
	["X"] = 88,
	["Y"] = 89,
	["Z"] = 90,
	["NUMPAD0"] = 96,
	["NUMPAD1"] = 97,
	["NUMPAD2"] = 98,
	["NUMPAD3"] = 99,
	["NUMPAD4"] = 100,
	["NUMPAD5"] = 101,
	["NUMPAD6"] = 102,
	["NUMPAD7"] = 103,
	["NUMPAD8"] = 104,
	["NUMPAD9"] = 105,
	["F1"] = 112,
	["F2"] = 113,
	["F3"] = 114,
	["F4"] = 115,
	["F5"] = 116,
	["F6"] = 117,
	["F7"] = 118,
	["F8"] = 119,
	["F9"] = 120,
	["F10"] = 121,
	["F11"] = 122,
	["F12"] = 123,
	["LEFT_SHIFT"] = 160,
	["RIGHT_SHIFT"] = 161,
	["LEFT_CTRL"] = 162,
	["RIGHT_CTRL"] = 163,
	["LEFT_ALT"] = 164,
	["RIGHT_ALT"] = 165,
	["LEFT_SHIFT"] = 166,
}

IEex_Keys = IEex_Default( {}, IEex_Keys)
IEex_Helper_InitBridgeFromTable("IEex_Keys", function()
	for key = 0x1, 0xFE, 1 do
		IEex_Keys[key] = {["isDown"] = false, ["pressedSinceLastPoll"] = false}
	end
end)

-- These need to be readded every IEex_Reload()

function IEex_AddKeyPressedListener(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_KeyPressedListeners", function()
		IEex_AppendBridgeNL("IEex_KeyPressedListeners", funcName)
	end)
end

function IEex_AddKeyReleasedListener(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_KeyReleasedListeners", function()
		IEex_AppendBridgeNL("IEex_KeyReleasedListeners", funcName)
	end)
end

function IEex_AddInputStateListener(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_InputStateListeners", function()
		IEex_AppendBridgeNL("IEex_InputStateListeners", funcName)
	end)
end

function IEex_IsKeyDown(key)
	return IEex_Helper_GetBridge("IEex_Keys", key, "isDown")
end

function IEex_AdjustViewPosition(deltaX, deltaY)

	local infinity = IEex_GetCInfinity()
	local m_ptCurrentPosExact_x = IEex_ReadDword(infinity + 0x164)
	local m_ptCurrentPosExact_y = IEex_ReadDword(infinity + 0x168)

	m_ptCurrentPosExact_x = m_ptCurrentPosExact_x + deltaX * 10000
	m_ptCurrentPosExact_y = m_ptCurrentPosExact_y + deltaY * 10000
	IEex_WriteDword(infinity + 0x164, m_ptCurrentPosExact_x)
	IEex_WriteDword(infinity + 0x168, m_ptCurrentPosExact_y)

	-- CInfinity_SetViewPosition
	IEex_Call(0x5D11F0, {0, math.floor(m_ptCurrentPosExact_y / 10000), math.floor(m_ptCurrentPosExact_x / 10000)}, infinity, 0x0)
end

function IEex_AdjustViewPositionFromScrollState(scrollState, delta)
	if scrollState == 6 or scrollState == 7 or scrollState == 8 then
		IEex_AdjustViewPosition(-delta, 0)
	end
	if scrollState == 2 or scrollState == 3 or scrollState == 4 then
		IEex_AdjustViewPosition(delta, 0)
	end
	if scrollState == 1 or scrollState == 2 or scrollState == 8 then
		IEex_AdjustViewPosition(0, -delta)
	end
	if scrollState == 4 or scrollState == 5 or scrollState == 6 then
		IEex_AdjustViewPosition(0, delta)
	end
end

function IEex_Key_ReloadListener()
	IEex_Helper_ClearBridge("IEex_KeyPressedListeners")
	IEex_Helper_ClearBridge("IEex_KeyReleasedListeners")
	IEex_Helper_ClearBridge("IEex_InputStateListeners")
	IEex_ReaddReloadListener("IEex_Key_ReloadListener")
end

IEex_AbsoluteOnce("IEex_Key_RegisterReloadListener", function()
	IEex_AddReloadListener("IEex_Key_ReloadListener")
end)

---------------
-- Scrolling --
---------------

IEex_Scroll_KeyLeft  = IEex_KeyIDS.LEFT
IEex_Scroll_KeyRight = IEex_KeyIDS.RIGHT
IEex_Scroll_KeyUp    = IEex_KeyIDS.UP
IEex_Scroll_KeyDown  = IEex_KeyIDS.DOWN

IEex_Helper_InitBridgeFromTable("IEex_Scroll_MiddleMouseState", {
	["isDown"] = false,
	["oldX"] = 0,
	["oldY"] = 0,
})

function IEex_Scroll_CalculateDeltaFactor()
	local toReturn = 1
	IEex_Helper_StoreMicroseconds("curTick")
	if IEex_Helper_ExistsMicroseconds("lastTick") then
		local diff = IEex_Helper_GetMicrosecondsDiff("curTick", "lastTick")
		toReturn = diff / 25000
	end
	IEex_Helper_AssignMicroseconds("lastTick", "curTick")
	return toReturn
end

function IEex_Scroll_CheckMultiScrollState(m_nKeyScrollState)
	if m_nKeyScrollState == 1 then
		if IEex_IsKeyDown(IEex_Scroll_KeyLeft) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD4) then
			m_nKeyScrollState = 8
		elseif IEex_IsKeyDown(IEex_Scroll_KeyRight) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD6) then
			m_nKeyScrollState = 2
		end
	elseif m_nKeyScrollState == 3 then
		if IEex_IsKeyDown(IEex_Scroll_KeyUp) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD8) then
			m_nKeyScrollState = 2
		elseif IEex_IsKeyDown(IEex_Scroll_KeyDown) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD2) then
			m_nKeyScrollState = 4
		end
	elseif m_nKeyScrollState == 5 then
		if IEex_IsKeyDown(IEex_Scroll_KeyRight) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD6) then
			m_nKeyScrollState = 4
		elseif IEex_IsKeyDown(IEex_Scroll_KeyLeft) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD4) then
			m_nKeyScrollState = 6
		end
	elseif m_nKeyScrollState == 7 then
		if IEex_IsKeyDown(IEex_Scroll_KeyDown) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD2) then
			m_nKeyScrollState = 6
		elseif IEex_IsKeyDown(IEex_Scroll_KeyUp) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD8) then
			m_nKeyScrollState = 8
		end
	end
	return m_nKeyScrollState
end

function IEex_Scroll_KeyPressedListener(key)

	if key == IEex_KeyIDS.MIDDLE_MOUSE_CLICK then
		IEex_Helper_SynchronizedBridgeOperation("IEex_Scroll_MiddleMouseState", function()
			IEex_Helper_SetBridgeNL("IEex_Scroll_MiddleMouseState", "isDown", true)
			local oldX, oldY = IEex_GetCursorXY()
			IEex_Helper_SetBridgeNL("IEex_Scroll_MiddleMouseState", "oldX", oldX)
			IEex_Helper_SetBridgeNL("IEex_Scroll_MiddleMouseState", "oldY", oldY)
		end)
	end

	if IEex_GetActiveEngine() == IEex_GetEngineWorld() then
		local visibleArea = IEex_GetVisibleArea()
		if visibleArea ~= 0x0 then
			local m_nKeyScrollStateAddress = visibleArea + 0x23C
			local m_nKeyScrollState = IEex_ReadDword(m_nKeyScrollStateAddress)
			IEex_WriteDword(m_nKeyScrollStateAddress, IEex_Scroll_CheckMultiScrollState(m_nKeyScrollState))
		end
	end
end

function IEex_Scroll_KeyReleasedListener(key)

	if key == IEex_KeyIDS.MIDDLE_MOUSE_CLICK then
		IEex_Helper_SetBridge("IEex_Scroll_MiddleMouseState", "isDown", false)
	end

	if IEex_GetActiveEngine() == IEex_GetEngineWorld() then

		local visibleArea = IEex_GetVisibleArea()
		if visibleArea ~= 0x0 then

			local m_nKeyScrollStateAddress = visibleArea + 0x23C
			local m_nKeyScrollState = IEex_ReadDword(m_nKeyScrollStateAddress)

			if key == IEex_Scroll_KeyLeft or key == IEex_KeyIDS.NUMPAD4 then
				if IEex_IsKeyDown(IEex_Scroll_KeyRight) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD6) then
					m_nKeyScrollState = IEex_Scroll_CheckMultiScrollState(3)
				elseif m_nKeyScrollState == 6 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD1) then
					m_nKeyScrollState = 5
				elseif m_nKeyScrollState == 7 then
					m_nKeyScrollState = 0
				elseif m_nKeyScrollState == 8 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD7) then
					m_nKeyScrollState = 1
				end
			elseif key == IEex_Scroll_KeyRight or key == IEex_KeyIDS.NUMPAD6 then
				if IEex_IsKeyDown(IEex_Scroll_KeyLeft) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD4) then
					m_nKeyScrollState = IEex_Scroll_CheckMultiScrollState(7)
				elseif m_nKeyScrollState == 2 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD9) then
					m_nKeyScrollState = 1
				elseif m_nKeyScrollState == 3 then
					m_nKeyScrollState = 0
				elseif m_nKeyScrollState == 4 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD3) then
					m_nKeyScrollState = 5
				end
			elseif key == IEex_Scroll_KeyUp or key == IEex_KeyIDS.NUMPAD8 then
				if IEex_IsKeyDown(IEex_Scroll_KeyDown) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD2) then
					m_nKeyScrollState = IEex_Scroll_CheckMultiScrollState(5)
				elseif m_nKeyScrollState == 1 then
					m_nKeyScrollState = 0
				elseif m_nKeyScrollState == 2 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD9) then
					m_nKeyScrollState = 3
				elseif m_nKeyScrollState == 8 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD7) then
					m_nKeyScrollState = 7
				end
			elseif key == IEex_Scroll_KeyDown or key == IEex_KeyIDS.NUMPAD2 then
				if IEex_IsKeyDown(IEex_Scroll_KeyUp) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD8) then
					m_nKeyScrollState = IEex_Scroll_CheckMultiScrollState(1)
				elseif m_nKeyScrollState == 4 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD3) then
					m_nKeyScrollState = 3
				elseif m_nKeyScrollState == 5 then
					m_nKeyScrollState = 0
				elseif m_nKeyScrollState == 6 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD1) then
					m_nKeyScrollState = 7
				end
			elseif (key == IEex_KeyIDS.NUMPAD7 and m_nKeyScrollState == 8)
				or (key == IEex_KeyIDS.NUMPAD9 and m_nKeyScrollState == 2)
				or (key == IEex_KeyIDS.NUMPAD3 and m_nKeyScrollState == 4)
				or (key == IEex_KeyIDS.NUMPAD1 and m_nKeyScrollState == 6)
			then
				m_nKeyScrollState = 0
			end

			IEex_WriteDword(m_nKeyScrollStateAddress, m_nKeyScrollState)
		end
	end
end

function IEex_ExtraCheatKeysListener(key)
	if IEex_IsKeyDown(IEex_KeyIDS.LEFT_CTRL) or IEex_IsKeyDown(IEex_KeyIDS.RIGHT_CTRL) then
		if key == IEex_KeyIDS.V then
			local actorID = IEex_GetActorIDCursor()
			if IEex_IsSprite(actorID, false) then
				local share = IEex_GetActorShare(actorID)
				local extraFlags = IEex_ReadDword(share + 0x740)
				if bit.band(extraFlags, 0x1000000) == 0 then
					IEex_DisplayString("Opcode printing on " .. IEex_GetActorName(actorID) .. " enabled")
					IEex_WriteDword(share + 0x740, bit.bor(extraFlags, 0x1000000))
				else
					IEex_DisplayString("Opcode printing on " .. IEex_GetActorName(actorID) .. " disabled")
					IEex_WriteDword(share + 0x740, bit.band(extraFlags, 0xFEFFFFFF))
				end
			end
		elseif key == IEex_KeyIDS.N then
			local actorID = IEex_GetActorIDCursor()
			if IEex_IsSprite(actorID, false) then
				local share = IEex_GetActorShare(actorID)
				local extraFlags = IEex_ReadDword(share + 0x740)
				if bit.band(extraFlags, 0x2000000) == 0 then
					IEex_DisplayString("Action printing on " .. IEex_GetActorName(actorID) .. " enabled")
					IEex_WriteDword(share + 0x740, bit.bor(extraFlags, 0x2000000))
				else
					IEex_DisplayString("Action printing on " .. IEex_GetActorName(actorID) .. " disabled")
					IEex_WriteDword(share + 0x740, bit.band(extraFlags, 0xFDFFFFFF))
				end
			end
		end
	end
end

function IEex_Scroll_InputStateListener()

end

function IEex_Scroll_RegisterListeners()
	IEex_AddKeyPressedListener("IEex_ExtraCheatKeysListener")
	IEex_AddKeyPressedListener("IEex_Scroll_KeyPressedListener")
	IEex_AddKeyReleasedListener("IEex_Scroll_KeyReleasedListener")
	IEex_AddInputStateListener("IEex_Scroll_InputStateListener")
end

function IEex_Scroll_ReloadListener()
	IEex_Scroll_RegisterListeners()
	IEex_ReaddReloadListener("IEex_Scroll_ReloadListener")
end

IEex_AbsoluteOnce("IEex_Scroll_InitListeners", function()
	IEex_Scroll_RegisterListeners()
	IEex_AddReloadListener("IEex_Scroll_ReloadListener")
end)

-----------
-- Hooks --
-----------

------------------
-- Thread: Sync --
------------------

function IEex_Extern_CheckScroll()

	IEex_AssertThread(IEex_Thread.Sync, true)

	IEex_Helper_SynchronizedBridgeOperation("IEex_Scroll_MiddleMouseState", function()

		if IEex_Helper_GetBridgeNL("IEex_Scroll_MiddleMouseState", "isDown") then

			local cursorX, cursorY = IEex_GetCursorClientPos()
			local deltaX = IEex_Helper_GetBridgeNL("IEex_Scroll_MiddleMouseState", "oldX") - cursorX
			local deltaY = IEex_Helper_GetBridgeNL("IEex_Scroll_MiddleMouseState", "oldY") - cursorY
			IEex_AdjustViewPosition(deltaX, deltaY)

			IEex_Helper_SetBridgeNL("IEex_Scroll_MiddleMouseState", "oldX", cursorX)
			IEex_Helper_SetBridgeNL("IEex_Scroll_MiddleMouseState", "oldY", cursorY)
		end
	end)

	local visibleArea = IEex_GetVisibleArea()
	if visibleArea ~= 0x0 then

		local m_nScrollState = IEex_ReadDword(visibleArea + 0x238)
		local m_nKeyScrollState = IEex_ReadDword(visibleArea + 0x23C)

		local gameData = IEex_GetGameData()
		local scrollSpeed = IEex_ReadDword(gameData + 0x43F2)
		local keyboardScrollSpeed = IEex_ReadDword(gameData + 0x443E) / 3

		local deltaFactor = IEex_Scroll_CalculateDeltaFactor()
		IEex_AdjustViewPositionFromScrollState(m_nScrollState, scrollSpeed * deltaFactor)
		IEex_AdjustViewPositionFromScrollState(m_nKeyScrollState, keyboardScrollSpeed * deltaFactor)
	end
end

-------------------
-- Thread: Async --
-------------------

function IEex_Extern_CChitin_ProcessEvents_CheckFlagClobber(key)
	IEex_AssertThread(IEex_Thread.Async, true)
	local keyData = IEex_Helper_GetBridge("IEex_Keys", key)
	if not keyData then return false end
	local toReturn = IEex_Helper_GetBridge(keyData, "pressedSinceLastPoll")
	IEex_Helper_SetBridge(keyData, "pressedSinceLastPoll", false)
	return toReturn
end

function IEex_Extern_CChitin_ProcessEvents_CheckKeys()

	-- https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes

	IEex_AssertThread(IEex_Thread.Async, true)

	for key = 0x1, 0xFE, 1 do

		-- USER32.DLL::GetAsyncKeyState
		local result = bit.band(IEex_Call(IEex_ReadDword(0x8474A8), {key}, nil, 0x0), 0xFFFF)
		local isPhysicallyDown = bit.band(result, 0x8000) ~= 0x0
		local pressedSinceLastPoll = bit.band(result, 0x1) ~= 0x0

		local keyData = IEex_Helper_GetBridge("IEex_Keys", key)
		local isDown = IEex_Helper_GetBridge(keyData, "isDown")
		IEex_Helper_SetBridge(keyData, "pressedSinceLastPoll", pressedSinceLastPoll)

		if isPhysicallyDown and not isDown then
			IEex_Helper_SetBridge(keyData, "isDown", true)
			IEex_Helper_IterateBridge("IEex_KeyPressedListeners", function(_, funcName)
				_G[funcName](key)
			end)
		end

		if not isPhysicallyDown and isDown then
			IEex_Helper_SetBridge(keyData, "isDown", false)
			IEex_Helper_IterateBridge("IEex_KeyReleasedListeners", function(_, funcName)
				_G[funcName](key)
			end)
		end
	end

	IEex_Helper_IterateBridge("IEex_InputStateListeners", function(_, funcName)
		_G[funcName](key)
	end)

end
