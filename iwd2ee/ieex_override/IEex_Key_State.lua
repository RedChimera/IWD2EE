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
	["RIGHT_SHIFT"] = 160,
	["LEFT_CTRL"] = 160,
	["RIGHT_CTRL"] = 160,
	["LEFT_ALT"] = 160,
	["RIGHT_ALT"] = 160,
	["LEFT_SHIFT"] = 160,
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

function IEex_Key_ReloadListener()
	IEex_Helper_ClearBridge("IEex_KeyPressedListeners")
	IEex_Helper_ClearBridge("IEex_KeyReleasedListeners")
	IEex_Helper_ClearBridge("IEex_InputStateListeners")
	IEex_ReaddReloadListener("IEex_Key_ReloadListener")
end

IEex_AbsoluteOnce("IEex_Key_RegisterReloadListener", function()
	IEex_AddReloadListener("IEex_Key_ReloadListener")
end)

----------------------------
-- Middle-mouse scrolling --
----------------------------

function IEex_MiddleScroll_KeyPressedListener(key)
	if key == 0x4 then
		IEex_MiddleScroll_IsDown = true
		IEex_MiddleScroll_OldX, IEex_MiddleScroll_OldY = IEex_GetCursorXY()
	end
end

function IEex_MiddleScroll_KeyReleasedListener(key)
	if key == 0x4 then
		IEex_MiddleScroll_IsDown = false
	end
end

function IEex_MiddleScroll_InputStateListener()

	if IEex_MiddleScroll_IsDown and IEex_GetActiveEngine() == IEex_GetEngineWorld() then

		local cursorX, cursorY = IEex_GetCursorXY()
		local deltaX = IEex_MiddleScroll_OldX - cursorX
		local deltaY = IEex_MiddleScroll_OldY - cursorY

		local infinity = IEex_GetCInfinity()
		local m_ptCurrentPosExact_x = IEex_ReadDword(infinity + 0x164)
		local m_ptCurrentPosExact_y = IEex_ReadDword(infinity + 0x168)

		m_ptCurrentPosExact_x = m_ptCurrentPosExact_x + deltaX * 10000
		m_ptCurrentPosExact_y = m_ptCurrentPosExact_y + deltaY * 10000
		IEex_WriteDword(infinity + 0x164, m_ptCurrentPosExact_x)
		IEex_WriteDword(infinity + 0x168, m_ptCurrentPosExact_y)

		IEex_Call(0x5D11F0, {0, math.floor(m_ptCurrentPosExact_y / 10000), math.floor(m_ptCurrentPosExact_x / 10000)}, infinity, 0x0)

		IEex_MiddleScroll_OldX = cursorX
		IEex_MiddleScroll_OldY = cursorY
	end
end

function IEex_MiddleScroll_RegisterListeners()
	IEex_AddKeyPressedListener("IEex_MiddleScroll_KeyPressedListener")
	IEex_AddKeyReleasedListener("IEex_MiddleScroll_KeyReleasedListener")
	IEex_AddInputStateListener("IEex_MiddleScroll_InputStateListener")
end

function IEex_MiddleScroll_ReloadListener()
	IEex_MiddleScroll_RegisterListeners()
	IEex_ReaddReloadListener("IEex_MiddleScroll_ReloadListener")
end

IEex_AbsoluteOnce("IEex_MiddleScroll_Init", function()
	if not IEex_InAsyncState then return false end
	IEex_MiddleScroll_IsDown = false
	IEex_MiddleScroll_OldX = 0
	IEex_MiddleScroll_OldY = 0
	IEex_MiddleScroll_RegisterListeners()
	IEex_AddReloadListener("IEex_MiddleScroll_ReloadListener")
end)

-----------
-- Hooks --
-----------

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
		local result = bit32.band(IEex_Call(IEex_ReadDword(0x8474A8), {key}, nil, 0x0), 0xFFFF)
		local isPhysicallyDown = bit32.band(result, 0x8000) ~= 0x0
		local pressedSinceLastPoll = bit32.band(result, 0x1) ~= 0x0

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
