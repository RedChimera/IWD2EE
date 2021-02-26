
(function()

	-----------------------------
	-- IEex_GetCursorClientPos --
	-----------------------------

	IEex_WriteAssemblyFunction("IEex_GetCursorClientPos", {[[

		!push_state
		!sub_esp_byte 08

		!push_esp
		!call_[dword] #8474D4 ; GetCursorPos ;

		!push(esp)
		!mov(eax,[8CF6DC])
		!push([eax+94])
		!call_[dword] #847470 ; ScreenToClient ;

		!push([esp])
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push([ebp+8])
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push([esp+4])
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push([ebp+8])
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!add_esp_byte 08
		!mov_eax #2
		!pop_state
		!ret
	]]})

	IEex_DisableCodeProtection()

	IEex_HookRestore(0x78FBC9, 0, 5, {[[

		!push_registers_iwd2
		!push_eax

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CChitin_ProcessEvents_CheckFlagClobber"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; key ;
		!movzx_eax_byte:[edi+byte] 04
		!push_eax
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 01
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!push_byte FF
		!push_dword *_g_lua_async
		!call >_lua_toboolean
		!add_esp_byte 08
		!push_eax
		!push_byte FE
		!push_dword *_g_lua_async
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
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2

	]]})

	-- Enable window-edge scrolling in windowed mode
	IEex_WriteAssembly(0x78F43F, {"!jmp_byte"})

	----------------------------------------------------
	-- Smooth Scrolling                               --
	-- Replace viewport scrolling with implementation --
	-- that runs on sync thread, (at higher tps)      --
	----------------------------------------------------

	-- Disable inbuilt keyboard scrolling
	IEex_WriteAssembly(0x4777EF, {"!xor_eax_eax !repeat(4,!nop)"})

	-- Disable inbuilt cursor scrolling
	IEex_WriteAssembly(0x477824, {"!xor_eax_eax !repeat(4,!nop)"})
	IEex_WriteAssembly(0x47784B, {"!xor_edx_edx !repeat(4,!nop)"})

	-- Redirect engine to Lua implementation
	IEex_HookAfterCall(0x5CF0D7, IEex_FlattenTable({[[
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_CheckScroll"), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))

	---------------------------------------------------
	-- Fullscreen should respect minimizing the game --
	---------------------------------------------------

	IEex_HookRestore(0x78D960, 0, 6, {[[
		!pop_esi
		!call ]], {IEex_GetProcAddress("IEexHelper", "WindowProcHook"), 4, 4}, [[
		!push_esi
	]]})

	IEex_EnableCodeProtection()

end)()
