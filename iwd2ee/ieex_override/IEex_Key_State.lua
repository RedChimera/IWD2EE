
IEex_Keys = IEex_Default( {}, IEex_Keys)

-- These need to be readded every IEex_Reload()
IEex_KeyPressedListeners = {}
IEex_KeyReleasedListeners = {}
IEex_InputStateListeners = {}

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
	return IEex_Keys[key].isDown
end

----------------------------
-- Middle-mouse scrolling --
----------------------------

IEex_MiddleScroll_IsDown = false
IEex_MiddleScroll_OldX = 0
IEex_MiddleScroll_OldY = 0

IEex_AddKeyPressedListener(function(key)
	if key == 0x4 then
		IEex_MiddleScroll_IsDown = true
		IEex_MiddleScroll_OldX, IEex_MiddleScroll_OldY = IEex_GetCursorXY()
	end
end)

IEex_AddKeyReleasedListener(function(key)
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
