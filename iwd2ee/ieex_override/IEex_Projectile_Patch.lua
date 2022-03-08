
(function()

	IEex_DisableCodeProtection()

	IEex_HookRestore(0x51EAF0, 0, 7, {[[

		!push_all_registers_iwd2

		!call >IEex_GetLuaState
		!mov_ebx_eax
	
		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnProjectileDecode"), 4}, [[
		!push_ebx
		!call >_lua_getglobal
		!add_esp_byte 08
	
		!lea_eax_[esp+byte] 1C
		!push_eax
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C
	
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_ebx
		!call >_lua_pcall
		!add_esp_byte 10
		!push_ebx
		!call >IEex_CheckCallError
	
		!pop_all_registers_iwd2

	]]})

	IEex_HookRestore(0x528E5E, 0, 7, {[[

		!push_all_registers_iwd2

		!call >IEex_GetLuaState
		!mov_ebx_eax
	
		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnPostProjectileCreation"), 4}, [[
		!push_ebx
		!call >_lua_getglobal
		!add_esp_byte 08
	
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!lea_eax_[esp+dword] #ED8
		!push_eax
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C
	
		!push_byte 00
		!push_byte 00
		!push_byte 02
		!push_ebx
		!call >_lua_pcall
		!add_esp_byte 10
		!push_ebx
		!call >IEex_CheckCallError
	
		!pop_all_registers_iwd2

	]]})

	local onAddEffectHook = IEex_WriteAssemblyAuto({[[

		!push_all_registers_iwd2
		!push_ecx

		!call >IEex_GetLuaState
		!mov_ebx_eax
	
		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnAddEffectToProjectile"), 4}, [[
		!push_ebx
		!call >_lua_getglobal
		!add_esp_byte 08
	
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!lea_eax_[esp+byte] 1C
		!push_eax
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C
	
		!push_byte 00
		!push_byte 01
		!push_byte 02
		!push_ebx
		!call >_lua_pcall
		!add_esp_byte 10
		!push_ebx
		!call >IEex_CheckCallError
		!test_eax_eax
		!jz_dword >no_error

		!pop_all_registers_iwd2
		!jmp_dword :7FBE4E ; CPtrList_AddTail ;
		
		@no_error
		!push_byte FF
		!push_ebx
		!call >_lua_toboolean
		!add_esp_byte 08
		!push_eax
		!push_byte FE
		!push_ebx
		!call >_lua_settop
		!add_esp_byte 08
		!pop_eax

		!test_eax_eax
		!pop_all_registers_iwd2
		!jz_dword :7FBE4E ; CPtrList_AddTail ;
		!ret_word 04 00

	]]})

	for _, address in ipairs({
		0x51EAA4,
		0x51EAE0,
		0x52D745,
		0x530086,
		0x530EEE,
		0x530F98,
		0x533F9E,
		0x581025,
	}) do
		IEex_HookChangeRel32(address, onAddEffectHook)
	end

	----------------------------------------------------------------------
	-- Fix out-of-bounds array indexing in CSearchBitmap_GetLOSCost()   --
	-- when certain projectiles pass -1 as either the x or y coordinate --
	----------------------------------------------------------------------

	IEex_HookRestore(0x547A09, 0, 8, {[[
		!cmp([esi],0)
		!jl_dword :547A26
		!cmp([esi+4],0)
		!jl_dword :547A26
	]]})

	IEex_EnableCodeProtection()

end)()
