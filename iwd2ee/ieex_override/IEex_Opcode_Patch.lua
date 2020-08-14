
(function()

	local IEex_Debug_DisableOpcodesMem = IEex_Malloc(0x4)
	IEex_WriteDword(IEex_Debug_DisableOpcodesMem, IEex_Debug_DisableOpcodes and 1 or 0)
	IEex_DefineAssemblyLabel("IEex_Debug_DisableOpcodes", IEex_Debug_DisableOpcodesMem)

	IEex_DisableCodeProtection()

	---------------------------------
	-- New Opcode #500 (InvokeLua) --
	---------------------------------

	local IEex_InvokeLua = IEex_WriteOpcode({

		["ApplyEffect"] = {[[

			!mov_eax_[dword] *IEex_Debug_DisableOpcodes
			!jmp_dword >normal
			!mov_eax #1
			!ret_word 04 00

			@normal
			!build_stack_frame
			!sub_esp_byte 0C
			!push_registers

			!mov_esi_ecx

			; Copy resref field into null-terminated stack space ;
			!mov_eax_[esi+byte] 2C
			!mov_[ebp+byte]_eax F4
			!mov_eax_[esi+byte] 30
			!mov_[ebp+byte]_eax F8
			!mov_byte:[ebp+byte]_byte FC 0

			!lea_eax_[ebp+byte] F4
			!push_eax
			!push_dword *_g_lua_async
			!call >_lua_getglobal
			!add_esp_byte 08

			!push_esi
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua_async
			!call >_lua_pushnumber
			!add_esp_byte 0C

			!push_[ebp+byte] 08
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua_async
			!call >_lua_pushnumber
			!add_esp_byte 0C

			!push_byte 00
			!push_byte 00
			!push_byte 00
			!push_byte 00
			!push_byte 02
			!push_dword *_g_lua_async
			!call >_lua_pcallk
			!add_esp_byte 18
			!push_dword *_g_lua_async
			!call >IEex_CheckCallError

			@ret
			!mov_eax #1
			!restore_stack_frame
			!ret_word 04 00
		]]},
	})

	----------------------------------
	-- New Opcode #501 (ModifyData) --
	----------------------------------

	local IEex_ModifyData = IEex_WriteOpcode({

		["OnAddSpecific"] = {[[

			!mov_eax_[dword] *IEex_Debug_DisableOpcodes
			!jz_dword >normal
			!mov_eax #1
			!ret_word 04 00

			@normal
			!push_state
			!mov_eax_[ecx+byte] 44

			; byte ;
			!cmp_eax_byte 01
			!jnz_dword >word

			!xor_eax_eax
			!mov_al_[ecx+byte] 18 ; To Add ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!add_[ecx+edi]_al

			@word
			!cmp_eax_byte 02
			!jne_dword >dword

			!xor_eax_eax
			!mov_ax_[ecx+byte] 18 ; To Add ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!add_[ecx+edi]_ax

			@dword
			!cmp_eax_byte 04
			!jne_dword >ret

			!mov_eax_[ecx+byte] 18 ; To Add ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!add_[ecx+edi]_eax

			@ret
			!mov_eax #1
			!pop_state
			!ret_word 04 00
		]]},


		["OnRemove"] = {[[

			!mov_eax_[dword] *IEex_Debug_DisableOpcodes
			!jz_dword >normal
			!mov_eax #1
			!ret_word 04 00

			@normal
			!push_state
			!mov_eax_[ecx+byte] 44

			; byte ;
			!cmp_eax_byte 01
			!jnz_dword >word

			!xor_eax_eax
			!mov_al_[ecx+byte] 18 ; To Subtract ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!sub_[ecx+edi]_al

			@word
			!cmp_eax_byte 02
			!jne_dword >dword

			!xor_eax_eax
			!mov_ax_[ecx+byte] 18 ; To Subtract ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!sub_[ecx+edi]_ax

			@dword
			!cmp_eax_byte 04
			!jne_dword >ret

			!mov_eax_[ecx+byte] 18 ; To Subtract ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!sub_[ecx+edi]_eax

			@ret
			!mov_eax #1
			!pop_state
			!ret_word 04 00
		]]},
	})

	-------------------------------------
	-- New Opcode #502 (ScreenEffects) --
	-------------------------------------

	local IEex_ScreenEffects = IEex_WriteOpcode({

		["ApplyEffect"] = {[[

			!mov_eax_[dword] *IEex_Debug_DisableOpcodes
			!jz_dword >normal
			!mov_eax #1
			!ret_word 04 00

			@normal
			!push_state

			; pEffect ;
			!push_ecx

			!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_ScreenEffectsFunc"), 4}, [[
			!push_dword *_g_lua
			!call >_lua_getglobal
			!add_esp_byte 08

			; pEffect ;
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua
			!call >_lua_pushnumber
			!add_esp_byte 0C

			; pSprite ;
			!push_[ebp+byte] 08
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua
			!call >_lua_pushnumber
			!add_esp_byte 0C

			!push_byte 00
			!push_byte 00
			!push_byte 00
			!push_byte 00
			!push_byte 02
			!push_dword *_g_lua
			!call >_lua_pcallk
			!add_esp_byte 18
			!push_dword *_g_lua
			!call >IEex_CheckCallError

			@ret
			!mov_eax #1
			!pop_state
			!ret_word 04 00

		]]},
	})

	if (not IEex_Debug_DisableOpcodes) and (not IEex_Debug_DisableScreenEffects) then

		IEex_HookAfterCall(0x733137, {[[

			!push_registers_iwd2
			!mov_ebx_eax

			!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnCheckAddScreenEffectsHook"), 4}, [[
			!push_dword *_g_lua_async
			!call >_lua_getglobal
			!add_esp_byte 08

			; pEffect ;
			!push_edi
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua_async
			!call >_lua_pushnumber
			!add_esp_byte 0C

			; pSprite ;
			!push_esi
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua_async
			!call >_lua_pushnumber
			!add_esp_byte 0C

			!push_byte 00
			!push_byte 00
			!push_byte 00
			!push_byte 01
			!push_byte 02
			!push_dword *_g_lua_async
			!call >_lua_pcallk
			!add_esp_byte 18
			!push_dword *_g_lua_async
			!call >IEex_CheckCallError
			!jnz_dword >error

			!push_byte FF
			!push_dword *_g_lua_async
			!call >_lua_toboolean
			!add_esp_byte 08
			!push_eax
			!push_byte FE
			!push_dword *_g_lua_async
			!call >_lua_settop
			!add_esp_byte 08
			!pop_eax
			!jmp_dword >no_error

			@error
			!xor_eax_eax

			@no_error
			!test_eax_eax
			!jz_dword >return_normally

			; Force both CheckAdd return value and function's noSave arg to false ;
			!mov_ebx #0
			!mov_[esp+byte]_dword 30 #0

			@return_normally
			!mov_eax_ebx
			!pop_registers_iwd2

		]]})

	end

	if (not IEex_Debug_DisableOpcodes) and (not IEex_Debug_DisableScreenEffects) then
		IEex_RegisterLuaStat({
			["reload"] = "IEex_ScreenEffectsStats_Reload",
			["copy"] = "IEex_ScreenEffectsStats_Copy",
		})
	end

	-----------------------------
	-- Opcode Definitions Hook --
	-----------------------------

	local opcodesHook = IEex_WriteAssemblyAuto(IEex_ConcatTables({[[

		!cmp_eax_dword #1F4
		!jne_dword >501

		]], IEex_InvokeLua, [[

		@501
		!cmp_eax_dword #1F5
		!jne_dword >502

		]], IEex_ModifyData, [[

		@502
		!cmp_eax_dword #1F6
		!jne_dword >fail

		]], IEex_ScreenEffects, [[

		@fail
		!jmp_dword :492C44

	]]}))
	IEex_WriteAssembly(0x48C882, {{opcodesHook, 4, 4}})

	IEex_EnableCodeProtection()

end)()
