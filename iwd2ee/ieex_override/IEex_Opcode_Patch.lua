
(function()

	local IEex_Debug_DisableOpcodesMem = IEex_Malloc(0x4)
	IEex_WriteDword(IEex_Debug_DisableOpcodesMem, IEex_Debug_DisableOpcodes and 1 or 0)
	IEex_DefineAssemblyLabel("IEex_Debug_DisableOpcodes", IEex_Debug_DisableOpcodesMem)

	IEex_DisableCodeProtection()

	--------------------
	-- Opcode Changes --
	--------------------

	-----------------------------------------------------
	-- Add metadata to hardcoded weapon damage effects --
	-----------------------------------------------------

	IEex_HookRestore(0x73EA38, 0, 7, IEex_FlattenTable({[[
		!mark_esp
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_OnWeaponDamageCRE", {
			["args"] = {
				{"!push(ebp)"},
				{"!push(esi)"},
				{"!lea_using_marked_esp(eax,[esp+E4]) !push(eax)"},
			},
		}), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))

	--------------------------------------------------------
	-- Fix persistent effects being able to crash when:   --
	-- 1) The game is paused                              --
	-- 2) AND the party attempts to rest                  --
	-- 3) AND the party gets interrupted at an early time --
	--------------------------------------------------------

	-- Sets bAllowEffectListCall = 0 while the engine is
	-- running CPersistantEffectListRegenerated_AIUpdate(),
	-- so it can't call CGameSprite_ProcessEffectList()
	-- and accidently reload its stats, invalidating the
	-- function's local variables.
	IEex_HookRestore(0x51E8B0, 0, 5, IEex_FlattenTable({[[
		; bAllowEffectListCall = 0 ;
		!mov(eax,[esp+4])
		!mov([eax+72A4],0)
	]]}))

	-- Restores bAllowEffectListCall = 1 at the end of
	-- CPersistantEffectListRegenerated_AIUpdate(), and
	-- runs CGameSprite_ProcessEffectList() if the engine
	-- was blocked from calling it during the function.
	IEex_HookRestore(0x51E926, 0, 7, IEex_FlattenTable({[[

		!mov(ecx,[esp+14])

		; bAllowEffectListCall = 1 ;
		!mov([ecx+72A4],1)

		; if (m_nEffectListCalls > 0) CGameSprite_ProcessEffectList() ;
		!mov(ax,word:[ecx+72A2])
		!test(ax,ax)
		!jle_dword >return

		; CGameSprite_ProcessEffectList ;
		!call :72DE60
	]]}))

	--------------------------------------------------
	-- Remove DAMAGEBONUS cap of 20 from Opcode #73 --
	--------------------------------------------------

	IEex_WriteAssembly(0x4B524C, {"!jmp_dword :4B5277 !repeat(2,!nop)"})

	-----------------
	-- New Opcodes --
	-----------------

	---------------------------------
	-- New Opcode #500 (InvokeLua) --
	---------------------------------

	local IEex_InvokeLua = IEex_WriteOpcode({

		["ApplyEffect"] = {[[

			!mov_eax_[dword] *IEex_Debug_DisableOpcodes
			!test_eax_eax
			!jz_dword >normal
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
			!push_byte 02
			!push_dword *_g_lua_async
			!call >_lua_pcall
			!add_esp_byte 10
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
			!test_eax_eax
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
			!test_eax_eax
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
			!test_eax_eax
			!jz_dword >normal
			!mov_eax #1
			!ret_word 04 00

			@normal
			!push_state

			; pEffect ;
			!push_ecx

			!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_ScreenEffectsFunc"), 4}, [[
			!push_dword *_g_lua_async
			!call >_lua_getglobal
			!add_esp_byte 08

			; pEffect ;
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua_async
			!call >_lua_pushnumber
			!add_esp_byte 0C

			; pSprite ;
			!push_[ebp+byte] 08
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua_async
			!call >_lua_pushnumber
			!add_esp_byte 0C

			!push_byte 00
			!push_byte 00
			!push_byte 02
			!push_dword *_g_lua_async
			!call >_lua_pcall
			!add_esp_byte 10
			!push_dword *_g_lua_async
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
			!push_byte 01
			!push_byte 02
			!push_dword *_g_lua_async
			!call >_lua_pcall
			!add_esp_byte 10
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
			["init"] = "IEex_ScreenEffectsStats_Init",
			["reload"] = "IEex_ScreenEffectsStats_Reload",
			["copy"] = "IEex_ScreenEffectsStats_Copy",
		})
	end

	IEex_HookBeforeCall(0x55F787, {[[

		!push_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnCheckSummonLimitHook"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; effectData ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; summonerData ;
		!push_[esp+byte] 18
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 01
		!push_byte 02
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError
		!jnz_dword >error

		!push_byte FF
		!push_dword *_g_lua_async
		!call >_lua_type
		!add_esp_byte 08
		!test_eax_eax
		!jz_dword >continueNormally

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

		!pop_registers_iwd2
		!add_esp_byte 04
		!jmp_dword >return

		@continueNormally
		!push_byte FE
		!push_dword *_g_lua_async
		!call >_lua_settop
		!add_esp_byte 08

		@error
		!pop_registers_iwd2
	]]})

	IEex_HookBeforeCall(0x55FE99, {[[

		!push_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnAddSummonToLimitHook"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; effectData ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; summonerData ;
		!push_[esp+byte] 18
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; summonedData ;
		!push_[esp+byte] 1C
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 01
		!push_byte 03
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError
		!jnz_dword >continueNormally

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

		!test_eax_eax
		!jz_dword >continueNormally

		!pop_registers_iwd2
		!add_esp_byte 08
		!jmp_dword >return

		@continueNormally
		!pop_registers_iwd2
	]]})

	-----------------------------
	-- Opcode Definitions Hook --
	-----------------------------

	local opcodesHook = IEex_WriteAssemblyAuto(IEex_FlattenTable({[[

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
