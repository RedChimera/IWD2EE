
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

function IEex_Extern_CChitin_ProcessEvents_CheckKeys()

	-- https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes

	for key = 0x1, 0xFE, 1 do

		-- USER32.DLL::GetAsyncKeyState
		local result = bit32.band(IEex_Call(IEex_ReadDword(0x8474A8), {key}, nil, 0x0), 0xFFFF)
		local isPhysicallyDown = bit32.band(result, 0x8000) ~= 0x0
		local luaKey = IEex_Keys[key]

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
		IEex_Keys[key] = {["isDown"] = false}
	end

	IEex_DisableCodeProtection()

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
