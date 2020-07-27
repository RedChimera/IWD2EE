
IEex_Keys = IEex_Default( {}, IEex_Keys)

-- These need to be readded every IEex_Reload()
IEex_KeyPressedListeners = {}
IEex_KeyReleasedListeners = {}

function IEex_AddKeyPressedListener(func)
	table.insert(IEex_KeyPressedListeners, func)
end

function IEex_AddKeyReleasedListener(func)
	table.insert(IEex_KeyReleasedListeners, func)
end

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
end

IEex_Once("IEex_Key", function()

	for key = 0x1, 0xFE, 1 do
		IEex_Keys[key] = {["isDown"] = false, ["pressedSinceLastPoll"] = false}
	end

	IEex_DisableCodeProtection()

	IEex_HookRestore(0x78FBC9, 0, 5, {[[

		!push_registers_iwd2
		!push_eax

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CChitin_ProcessEvents_CheckFlagClobber"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; key ;
		!movzx_eax_byte:[edi+byte] 04
		!push_eax
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
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
		!pop_ecx

		!pop_eax
		!or_eax_ecx

		!pop_registers_iwd2

	]]})

	IEex_HookAfterRestore(0x78FC63, 0, 6, {[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CChitin_ProcessEvents_CheckKeys"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2

	]]})

	IEex_EnableCodeProtection()

end)
