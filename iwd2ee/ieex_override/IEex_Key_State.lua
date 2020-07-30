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

-- These need to be readded every IEex_Reload()
IEex_KeyPressedListeners = {}
IEex_KeyReleasedListeners = {}
IEex_InputStateListeners = {}
for i = 1, 254, 1 do
	IEex_DefineBridge("IEex_KeyDown" .. i, 0)
end

function IEex_AddKeyPressedListener(func)
	table.insert(IEex_KeyPressedListeners, func)
end

function IEex_AddKeyReleasedListener(func)
	table.insert(IEex_KeyReleasedListeners, func)
end

function IEex_AddInputStateListener(func)
	table.insert(IEex_InputStateListeners, func)
end

function IEex_IsKeyDown(key)
	return (IEex_GetBridge("IEex_KeyDown" .. key) == 1)
--	return IEex_Keys[key].isDown
end
----------------------------
-- Middle-mouse scrolling --
----------------------------

IEex_MiddleScroll_IsDown = false
IEex_MiddleScroll_OldX = 0
IEex_MiddleScroll_OldY = 0

IEex_AddKeyPressedListener(function(key)
	IEex_SetBridge("IEex_KeyDown" .. key,1)
	if key == 0x4 then
		IEex_MiddleScroll_IsDown = true
		IEex_MiddleScroll_OldX, IEex_MiddleScroll_OldY = IEex_GetCursorXY()
	end
end)

IEex_AddKeyReleasedListener(function(key)
	IEex_SetBridge("IEex_KeyDown" .. key,0)
	if key == 0x4 then
		IEex_MiddleScroll_IsDown = false
	end
end)

IEex_AddInputStateListener(function()

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
end)

-----------
-- Hooks --
-----------

function IEex_Extern_CChitin_ProcessEvents_CheckFlagClobber(key)
	local luaKey = IEex_Keys[key]
	if not luaKey then return false end
	local toReturn = luaKey.pressedSinceLastPoll
	luaKey.pressedSinceLastPoll = false
	return toReturn
end

function IEex_Extern_CChitin_ProcessEvents_CheckKeys()

	-- https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes

	for key = 0x1, 0xFE, 1 do

		-- USER32.DLL::GetAsyncKeyState
		local result = bit32.band(IEex_Call(IEex_ReadDword(0x8474A8), {key}, nil, 0x0), 0xFFFF)
		local isPhysicallyDown = bit32.band(result, 0x8000) ~= 0x0
		local pressedSinceLastPoll = bit32.band(result, 0x1) ~= 0x0
		local luaKey = IEex_Keys[key]
		luaKey.pressedSinceLastPoll = pressedSinceLastPoll

		if isPhysicallyDown and not luaKey.isDown then
			luaKey.isDown = true
			for _, func in ipairs(IEex_KeyPressedListeners) do
				func(key)
			end
		end

		if not isPhysicallyDown and luaKey.isDown then
			luaKey.isDown = false
			for _, func in ipairs(IEex_KeyReleasedListeners) do
				func(key)
			end
		end
	end

	for _, func in ipairs(IEex_InputStateListeners) do
		func()
	end

end

(function()
	for key = 0x1, 0xFE, 1 do
		IEex_Keys[key] = {["isDown"] = false, ["pressedSinceLastPoll"] = false}
	end
end)()
