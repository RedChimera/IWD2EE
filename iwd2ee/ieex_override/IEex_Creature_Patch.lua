
(function()

	IEex_DisableCodeProtection()

	----------------------------
	-- IEex_OnGameObjectAdded --
	----------------------------

	-- The function (sometimes) clobbers this arg during execution,
	-- have to save it myself so I can use it later.
	local onGameObjectAddedIndexPointer = IEex_Malloc(0x4)

	IEex_HookRestore(0x59A0F0, 0, 6, {[[
		!mov_eax_[esp+byte] 04
		!mov_[dword]_eax ]], {onGameObjectAddedIndexPointer, 4}, [[
	]]})

	IEex_HookAfterRestore(0x59A4FE, 0, 10, {[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnGameObjectAdded"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		!mov_eax_[dword] ]], {onGameObjectAddedIndexPointer, 4}, [[
		!mov_eax_[eax]

		; actorID ;
		!push_eax
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2

	]]})

	-----------------------------------
	-- IEex_OnGameObjectBeingDeleted --
	-----------------------------------

	IEex_HookRestore(0x59A530, 0, 6, {[[

		!push_complete_state

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnGameObjectBeingDeleted"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; actorID ;
		!push_[ebp+byte] 08
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!pop_complete_state

	]]})

	------------------------------------
	-- IEex_OnGameObjectsBeingCleaned --
	------------------------------------

	IEex_HookRestore(0x59A9D0, 0, 7, {[[

		!push_all_registers_iwd2

		!call >IEex_GetLuaState
		!mov_ebx_eax

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnGameObjectsBeingCleaned"), 4}, [[
		!push_ebx
		!call >_lua_getglobal
		!add_esp_byte 08

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_ebx
		!call >_lua_pcall
		!add_esp_byte 10
		!push_ebx
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2

	]]})

	------------------------
	-- IEex_OnReloadStats --
	------------------------

	IEex_HookRestore(0x4440F0, 0, 6, {[[

		!push_complete_state

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnReloadStats"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; share ;
		!push_[ebp+byte] 08
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!pop_complete_state

	]]})

	----------------------------
	-- IEex_OnUpdateTempStats --
	----------------------------

	local callOnUpdateTempStats = IEex_WriteAssemblyAuto({[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnUpdateTempStats"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; share ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2
		!ret

	]]})

	IEex_HookBeforeCall(0x72E1F9, {"!call", {callOnUpdateTempStats, 4, 4}})
	IEex_HookBeforeCall(0x733179, {"!call", {callOnUpdateTempStats, 4, 4}})

	-------------------------------------------------
	-- IEex_Extern_OnPostCreatureProcessEffectList --
	-------------------------------------------------

	IEex_HookAfterCall(0x72DAC7, IEex_FlattenTable({[[
		!mark_esp()
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_OnPostCreatureProcessEffectList", {
			["args"] = {
				{"!push(esi)"},
			},
		}), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))

	---------------------------------------------
	-- IEex_Extern_OnPostCreatureHandleEffects --
	---------------------------------------------

	IEex_HookAfterCall(0x72E754, IEex_FlattenTable({[[
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_OnPostCreatureHandleEffects", {
			["args"] = {
				{"!push(esi)"},
			},
		}), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))

	--------------------------------------------------------------------------
	-- Allow actionbar buttons to be programatically customized for non-PCs --
	--------------------------------------------------------------------------

	-- All creatures should use the customizable actionbar state
	IEex_WriteAssembly(0x5ADBAE, {"!repeat(2,!nop)"})

	-- Assign empty buttons to all creatures
	IEex_HookAfterRestore(0x6F2967, 0, 6, {[[
		!xor_ecx_ecx
		@loop
		!mov([esi+ecx*4+3D14],64)
		!inc_ecx
		!cmp_ecx_byte 09
		!jl_dword >loop
	]]})

	-- IEex_Extern_RestrictCreatureActionbar()
	IEex_HookJump(0x594831, 0, IEex_FlattenTable({[[

		!mark_esp(38)
		!push_all_registers_iwd2
		!add_eax_byte 02
		]], IEex_GenLuaCall("IEex_Extern_RestrictCreatureActionbar", {
			["args"] = {
				{"!push_using_marked_esp([esp-18])"},
				{"!push(eax)"},
			},
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}), [[

		!test_eax_eax
		!pop_all_registers_iwd2
		!jnz_dword >jmp_success
		!jmp_dword >jmp

		@call_error
		!pop_all_registers_iwd2
	]]}))

	-- Add local to CGameSprite_AssignDefaultButtons() that signals
	-- an override to the normal buttonType=0 restriction
	IEex_HookRestore(0x724610, 0, 5, IEex_FlattenTable({[[

		!mark_esp()
		!sub_esp_byte 04

		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_ShouldForceDefaultButtons", {
			["args"] = {
				{"!push(ecx)"},
			},
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}), [[
		!jmp_dword >call_success

		@call_error
		!mov_eax #1

		@call_success
		!marked_esp() !mov([esp-4],eax)
		!pop_all_registers_iwd2
	]]}))

	-- Check new local to override buttonType restriction
	IEex_HookJumpNoReturn(0x724637, {[[
		!cmp([ebx],0)
		!jz_dword :72463C
		!mark_esp(14)
		!marked_esp() !cmp([esp-4],1)
		!je_dword :72463C
		!jmp_dword :72467D
	]]})

	-- Cleanup new local and return
	IEex_HookAfterRestore(0x724686, 0, 4, {[[
		!add_esp_byte 04
		!ret
	]]})

	-- Global creature unmarshalling should use function
	-- to assign default buttons, not its inlined version,
	-- (that I haven't changed).
	IEex_HookJumpNoReturn(0x70C8E6, {[[
		!mov_ecx_ebp
		!call :724610 ; CGameSprite_AssignDefaultButtons ;
		!jmp_dword :70C970
	]]})

	-------------------------------------------------------------
	-- Rapid Shot shouldn't crash when game is paused and      --
	-- m_selectedWeaponAbility = -1. Note that this is just    --
	-- a band-aid on top of Rapid Shot; the underlying problem --
	-- of m_selectedWeaponAbility = -1 is not fixed.           --
	-------------------------------------------------------------

	IEex_HookRestore(0x444C31, 0, 7, {[[
		!test_eax_eax
		!jz_dword :444C49
	]]})

	----------------------------------------------------------------------------
	-- Fix inverted sound check in CGameSprite_Hide(), MOVESILENTLY shouldn't --
	-- have inverse relationship with hide success when enemies are around.   --
	----------------------------------------------------------------------------

	IEex_WriteAssembly(0x757E5F, {"!jg_byte"})

	IEex_EnableCodeProtection()

end)()
