
(function()

	-- Special globals required to spin up Async state.
	IEex_AsyncState = IEex_Call(IEex_Label("_luaL_newstate"), {}, nil, 0x0)
	IEex_Call(IEex_Label("_luaL_openlibs"), {IEex_AsyncState}, nil, 0x4)
	IEex_DefineAssemblyLabel("_g_lua_async", IEex_AsyncState)

	IEex_AsyncInitialLock = IEex_Malloc(0x4)
	IEex_WriteDword(IEex_AsyncInitialLock, 0x0)

	IEex_AsyncSharedMemoryPtr = IEex_Malloc(0x4)
	IEex_WriteDword(IEex_AsyncSharedMemoryPtr, 0x0)

	----------------------------------
	-- IEex_DefineAssemblyFunctions --
	----------------------------------

	IEex_WriteAssemblyAuto({[[

		$IEex_GetLuaState
		!push_registers_iwd2

		!call >IEex_GetCurrentThread
		!mov_ebx_eax

		!push_dword ]], {IEex_WriteStringAuto("Sync"), 4}, [[
		!push_dword ]], {IEex_WriteStringAuto("IEex_ThreadBridge"), 4}, [[
		!call >IEex_Helper_GetBridgeDirect
		!add_esp_byte 08

		!cmp_ebx_eax
		!jne_dword >not_sync
		!mov_eax *_g_lua
		!jmp_dword >return

		@not_sync
		!push_dword ]], {IEex_WriteStringAuto("Async"), 4}, [[
		!push_dword ]], {IEex_WriteStringAuto("IEex_ThreadBridge"), 4}, [[
		!call >IEex_Helper_GetBridgeDirect
		!add_esp_byte 08

		!cmp_ebx_eax
		!jne_dword >not_async
		!mov_eax *_g_lua_async
		!jmp_dword >return

		@not_async
		!xor_eax_eax

		@return
		!pop_registers_iwd2
		!ret
	]]})

	IEex_WriteAssemblyAuto({[[

		$IEex_CheckCallError

		!test_eax_eax
		!jnz_dword >error
		!ret_word 04 00

		@error
		!build_stack_frame

		!push_byte 00
		!push_byte FF
		!push_[ebp+byte] 08
		!call >_lua_tolstring
		!add_esp_byte 0C

		; _lua_pushstring arg ;
		!push_eax

		!push_dword ]], {IEex_WriteStringAuto("print"), 4}, [[
		!push_[ebp+byte] 08
		!call >_lua_getglobal
		!add_esp_byte 08

		!push_[ebp+byte] 08
		!call >_lua_pushstring
		!add_esp_byte 08

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_[ebp+byte] 08
		!call >_lua_pcallk
		!add_esp_byte 18

		; Clear error string off of stack ;
		!push_byte FE
		!push_[ebp+byte] 08
		!call >_lua_settop
		!add_esp_byte 08

		!mov_eax #1
		!destroy_stack_frame
		!ret_word 04 00
	]]})

	-- push resref
	-- push share
	IEex_WriteAssemblyAuto({[[

		$IEex_ApplyResref

		!build_stack_frame
		!sub_esp_byte 0C
		!push_registers

		!push_byte 01 ; level ;
		!push_[ebp+byte] 0C ; resref ;
		!push_[ebp+byte] 08 ; share ;
		!lea_ecx_[ebp+byte] F4
		!push_ecx
		!call :586220 ; Get_Resref_Effects ;
		!add_esp_byte 10

		!mov_ebx_[ebp+byte] F8 ; list start ;
		!mov_edi_[ebx] ; head ;

		!cmp_edi_ebx
		!je_dword >free_everything

		@apply_loop
		!push_byte 01 ; immediateResolve ;
		!push_byte 00 ; noSave ;
		!push_byte 01 ; Timed list ;
		!push_[edi+byte] 08 ; Effect ;
		!mov_ecx_[ebp+byte] 08
		!mov_eax_[ecx]
		!call_[eax+dword] #78 ; Add Effect ;

		!mov_edi_[edi]
		!cmp_edi_ebx
		!jne_dword >apply_loop

		@free_everything
		!mov_edi_[ebx] ; head ;
		!cmp_edi_ebx
		!je_dword >free_start

		@free_everything_loop
		!mov_eax_edi
		!mov_edx_[eax+byte] 04
		!mov_ecx_[eax]
		!mov_edi_[edi]
		!mov_[edx]_ecx
		!mov_edx_[eax]
		!mov_ecx_[eax+byte] 04
		!push_eax
		!mov_[edx+byte]_ecx 04
		!call :7FC984 ; free ;
		!add_esp_byte 04
		!dec_[ebp+byte] FC
		!cmp_edi_ebx
		!jne_dword >free_everything_loop

		@free_start
		!push_ebx
		!call :7FC984 ; free ;
		!add_esp_byte 04

		!restore_stack_frame
		!ret_word 08 00
	]]})

	-----------------------
	-- IEex_WritePatches --
	-----------------------

	IEex_DisableCodeProtection()

	-----------------
	-- Async State --
	-----------------

	IEex_HookRestore(0x7901FE, 5, 0, {[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CreateAsyncState"), 4}, [[
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
		!push_dword *_g_lua
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2

		!call :7E9429

		; This spins the Sync thread until the Async state is done initializing.
		Unsure if this is needed, but let's keep it just in case. ;
		@wait
		!cmp_[dword]_byte ]], {IEex_AsyncInitialLock, 4}, [[ 00
		!jz_dword >wait

	]]})

	-- Both invokes IEex_Async.lua and calls IEex_Extern_SetupAsyncState()
	-- using the Async state. Also directly exposes IEex_ReadDword, IEex_ReadString,
	-- and IEex_ExposeToLua so the Async state can initialize itself.
	IEex_HookRestore(0x7928E0, 0, 6, {[[

		!push_all_registers_iwd2

		!push_byte 00
		!push_dword *IEex_ReadDword
		!push_dword *_g_lua_async
		!call >_lua_pushcclosure
		!add_esp_byte 0C

		!push_dword ]], {IEex_WriteStringAuto("IEex_ReadDword"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_setglobal
		!add_esp_byte 08

		!push_byte 00
		!push_dword *IEex_ReadString
		!push_dword *_g_lua_async
		!call >_lua_pushcclosure
		!add_esp_byte 0C

		!push_dword ]], {IEex_WriteStringAuto("IEex_ReadString"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_setglobal
		!add_esp_byte 08

		!push_byte 00
		!push_dword *IEex_ExposeToLua
		!push_dword *_g_lua_async
		!call >_lua_pushcclosure
		!add_esp_byte 0C

		!push_dword ]], {IEex_WriteStringAuto("IEex_ExposeToLua"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_setglobal
		!add_esp_byte 08

		!push_byte 00
		!push_dword ]], {IEex_WriteStringAuto("override\\IEex_Async.lua"), 4}, [[
		!push_dword *_g_lua_async
		!call >_luaL_loadfilex
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_dword *_g_lua_async
		!call >_lua_pcallk
		!add_esp_byte 18
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_SetupAsyncState"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; asyncSharedMemory ;
		!push_[dword] ]], {IEex_AsyncSharedMemoryPtr, 4}, [[
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
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcallk
		!add_esp_byte 18
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2

	]]})

	--------------------
	-- Crash Handling --
	--------------------

	IEex_HookBeforeCall(0x7F0C76, {[[

		!push_all_registers_iwd2

		!call >IEex_GetLuaState
		!mov_ebx_eax

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_Crashing"), 4}, [[
		!push_ebx
		!call >_lua_getglobal
		!add_esp_byte 08

		; excCode ;
		!push_[ebp+byte] 08
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; EXCEPTION_POINTERS ;
		!push_[ebp+byte] 0C
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 02
		!push_ebx
		!call >_lua_pcallk
		!add_esp_byte 18
		!push_ebx
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2

		!mov_eax #1
		!pop_esi
		!pop_ebx
		!pop_ecx
		!leave
		!ret
	]]})

	---------------------
	-- Stage 1 Startup --
	---------------------

	local stage1StartupHookAddress = 0x59CC58
	local stage1StartupHook = IEex_WriteAssemblyAuto({[[

		!call :53CB60
		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_Stage1Startup"), 4}, [[
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
		!push_dword *_g_lua
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2
		!jmp_dword ]], {stage1StartupHookAddress + 0x5, 4, 4},

	})
	IEex_WriteAssembly(stage1StartupHookAddress, {"!jmp_dword", {stage1StartupHook, 4, 4}})

	---------------------
	-- Stage 2 Startup --
	---------------------

	local stage2StartupHookAddress = 0x421BA9
	local stage2StartupHook = IEex_WriteAssemblyAuto({[[

		!call :423800
		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_Stage2Startup"), 4}, [[
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
		!push_dword *_g_lua
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2
		!jmp_dword ]], {stage2StartupHookAddress + 0x5, 4, 4},

	})
	IEex_WriteAssembly(stage2StartupHookAddress, {"!jmp_dword", {stage2StartupHook, 4, 4}})

	---------------------------------------------------------
	-- Fix non-player animations crashing when leveling up --
	---------------------------------------------------------

	local animationChangeCall = 0x5E676C
	local animationChangeHook = IEex_WriteAssemblyAuto({[[

		!push_ecx

		!mov_ecx_ebp
		!call :45B730
		!mov_ecx_eax
		!call :45B690
		!movzx_eax_ax

		!pop_ecx

		!cmp_eax_dword #6000
		!jb_dword :5E67F5

		!cmp_eax_dword #6313
		!ja_dword :5E67F5

		!call :447AD0
		!jmp_dword ]], {animationChangeCall + 0x5, 4, 4}, [[

	]]})
	IEex_WriteAssembly(animationChangeCall, {"!jmp_dword", {animationChangeHook, 4, 4}})

	---------------------------------------------------------
	-- Debug Console should execute Lua if not using cheat --
	---------------------------------------------------------

	local niceTryCheaterCall = 0x58398E
	local niceTryCheaterHook = IEex_WriteAssemblyAuto({[[

		!add_esp_byte 08
		!push_ebp
		!push_dword *_g_lua
		; TODO: Cache Lua chunks ;
		!call >_luaL_loadstring
		!add_esp_byte 08

		!test_eax_eax
		!jnz_dword >error

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18

		!test_eax_eax
		!jnz_dword >error
		!jmp_dword ]], {niceTryCheaterCall + 0x5, 4, 4}, [[

		@error
		!push_byte 00
		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_tolstring
		!add_esp_byte 0C

		!push_eax
		!push_byte FE
		!push_dword *_g_lua
		!call >_lua_settop
		!add_esp_byte 08
		!pop_eax

		!push_ecx
		!mov_ecx_esp
		!push_eax
		!call :7FCC88
		!call :4EC1C0

		!jmp_dword ]], {niceTryCheaterCall + 0x5, 4, 4}, [[

	]]})
	IEex_WriteAssembly(niceTryCheaterCall, {"!jmp_dword", {niceTryCheaterHook, 4, 4}})
	IEex_WriteAssembly(0x583996, {"!nop !nop !nop !nop !nop"})

	----------------------------------------------
	-- Feats should apply our spells when taken --
	----------------------------------------------

	local featHookName = "IEex_Extern_FeatHook"
	local featHookNameAddress = IEex_Malloc(#featHookName + 1)
	IEex_WriteString(featHookNameAddress, featHookName)

	local hasMetStunningAttackRequirements = 0x71E4D2
	local featsHook = IEex_WriteAssemblyAuto({[[

		!push_registers

		!push_dword ]], {featHookNameAddress, 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; Current share ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; Old base stats ;
		!push_edi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; Old derived stats ;
		!push_[esp+byte] 40
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
		!push_byte 03
		!push_dword *_g_lua_async
		!call >_lua_pcallk
		!add_esp_byte 18
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!pop_registers

		!call :763150
		!jmp_dword ]], {hasMetStunningAttackRequirements + 0x5, 4, 4}, [[

	]]})
	IEex_WriteAssembly(hasMetStunningAttackRequirements, {"!jmp_dword", {featsHook, 4, 4}})

	-------------------------------------------------------------------------
	-- Unequipping item should properly trigger Opcode OnRemove() function --
	-------------------------------------------------------------------------

	local unequipSpriteGlobal = IEex_Malloc(0x4)
	IEex_WriteDword(unequipSpriteGlobal, 0x0)

	local fixUnequipOnRemove1 = 0x4E8F04
	local fixUnequipOnRemove1Hook = IEex_WriteAssemblyAuto({[[
		!mov_[dword]_edi ]], {unequipSpriteGlobal, 4}, [[
		!call :4C0830 ; CGameEffectList_RemoveMatchingEffect() ;
		!mov_[dword]_dword ]], {unequipSpriteGlobal, 4}, [[ #0
		!jmp_dword ]], {fixUnequipOnRemove1 + 0x5, 4, 4}, [[
	]]})
	IEex_WriteAssembly(fixUnequipOnRemove1, {"!jmp_dword", {fixUnequipOnRemove1Hook, 4, 4}})

	local fixUnequipOnRemove2 = 0x4C0870
	local fixUnequipOnRemove2Hook = IEex_WriteAssemblyAuto({[[

		!call :7FB3E3 ; CPtrList::RemoveAt() ;

		!cmp_[dword]_byte ]], {unequipSpriteGlobal, 4}, [[ 00
		!je_dword ]], {fixUnequipOnRemove2 + 0x5, 4, 4}, [[

		!push_all_registers_iwd2
		!push_[dword] ]], {unequipSpriteGlobal, 4}, [[
		!mov_ecx_edi
		!mov_eax_[ecx]
		!call_[eax+byte] 24
		!pop_all_registers_iwd2
		!jmp_dword ]], {fixUnequipOnRemove2 + 0x5, 4, 4}, [[

	]]})
	IEex_WriteAssembly(fixUnequipOnRemove2, {"!jmp_dword", {fixUnequipOnRemove2Hook, 4, 4}})

	-------------------------------------------------------------
	-- Spell writability is now determined by scroll usability --
	-------------------------------------------------------------

	local writableCheckAddress = 0x54AA40
	local writableCheckHook = IEex_WriteAssemblyAuto({[[

		!push_registers_iwd2

		; push sprite ;
		!push_[esp+byte] 1C
		; push CSpell ;
		!push_ecx

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CSpell_UsableBySprite"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; CSpell ;
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; sprite ;
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
		!ret_word 04 00

	]]})
	IEex_WriteAssembly(writableCheckAddress, {"!jmp_dword", {writableCheckHook, 4, 4}})

	-----------------------------------------------------
	-- SPECIAL_1 and TEAM scripts should be persistent --
	-----------------------------------------------------

	-- 0x71DB62 - SPECIAL_1
	IEex_HookJumpNoReturn(0x71DB62, {[[

		!mov_ecx_[eax]
		!mov_[esp+byte]_ecx 10
		!mov_ecx_[eax+byte] 04
		!mov_[esp+byte]_ecx 14

		!add_esi_dword #750
		!push_esi
		!lea_ecx_[esp+byte] 14

		!jmp_dword :71DCCC

	]]})

	-- 0x71DBB3 - TEAM
	IEex_HookJumpNoReturn(0x71DBB3, {[[

		!mov_eax_[esp+byte] 5C

		!mov_ecx_[eax]
		!mov_[esp+byte]_ecx 10
		!mov_ecx_[eax+byte] 04
		!mov_[esp+byte]_ecx 14

		!add_esi_dword #748
		!push_esi
		!lea_ecx_[esp+byte] 14

		!jmp_dword :71DCCC

	]]})

	--------------------------------------------------------
	-- NPC Core: Engine should tolerate non-standard NPCs --
	--------------------------------------------------------

	---------------------------------------------------------
	-- CRuleTables_GetRaceName():                          --
	--   Pull out-of-bounds race strings from B3RACEST.2DA --
	---------------------------------------------------------

	IEex_HookJump(0x544DFA, 0, {[[

		!ja_dword >extended_race
		!jmp_dword >jmp_fail

		@extended_race
		!push_registers_iwd2

		; race ;
		!push_ecx

		!call >IEex_GetLuaState
		!mov_ebx_eax

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CRuleTables_GetRaceName"), 4}, [[
		!push_ebx
		!call >_lua_getglobal
		!add_esp_byte 08

		; race ;
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 01
		!push_ebx
		!call >_lua_pcallk
		!add_esp_byte 18
		!push_ebx
		!call >IEex_CheckCallError
		!test_eax_eax
		!jz_dword >ok
		!mov_eax ]], {ex_tra_5000, 4}, [[
		!jmp_dword >error

		@ok
		!push_byte 00
		!push_byte FF
		!push_ebx
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!push_eax
		!push_byte FE
		!push_ebx
		!call >_lua_settop
		!add_esp_byte 08
		!pop_eax

		@error
		!pop_registers_iwd2
		!jmp_dword :545009

	]]})

	------------------------------------------------------------
	-- InfScreenCharacter_InitLevelupClassSelectionButtons(): --
	--   Allow out-of-bounds races to take levels             --
	------------------------------------------------------------

	IEex_WriteAssembly(0x5E8CE1, {"!ja_dword :5E8D11"})

	-----------------------------------------------------
	-- Action JoinParty(): Should correctly set up NPC --
	-----------------------------------------------------

	IEex_HookBeforeCall(0x72958F, {[[

		!push_all_registers_iwd2

		!sub_esp_byte 04
		!mov_eax_esp
		!push_byte FF
		!push_eax
		!push_byte 00
		!mov_edi_[esi+byte] 5C
		!push_edi
		!mov_ebx_[dword] #8CF6DC ; g_pBaldurhitin ;
		!mov_ebx_[ebx+dword] #1C54 ; m_pObjectGame ;
		!add_ebx_dword #372C ; CGameObjectArray ;
		!mov_ecx_ebx
		!call :599C70 ; CGameObjectArray_GetDeny ;

		!pop_ecx
		!xor_edx_edx

		@button_loop
		!push_byte 00
		!push_edx
		!call :594120 ; CGameSprite_SetButtonType ;
		!inc_edx
		!cmp_edx_byte 09
		!jne_dword >button_loop

		!call :724610 ; CGameSprite_AssignDefaultButtons ;

		!push_byte FF
		!push_byte 00
		!push_edi
		!mov_ecx_ebx
		!call :59A010 ; CGameObjectArray_UndoDeny ;

		!mov_byte:[esi+dword]_byte #4C52 01 ; m_bGlobal ;

		!pop_all_registers_iwd2

	]]})

	------------------------------------------------------
	-- Action LeaveParty(): Should correctly set up NPC --
	------------------------------------------------------

	IEex_HookBeforeCall(0x7295F7, {[[
		!mov_byte:[esi+dword]_byte #4C52 00 ; m_bGlobal ;
	]]})

	---------------------------------------------------------
	-- CGameSprite_GetRacialFavoredClass():                --
	--   Pull out-of-bounds racial classes from B3RACE.2DA --
	---------------------------------------------------------

	IEex_HookJump(0x7645A9, 0, {[[

		!ja_dword >extended_race
		!jmp_dword >jmp_fail

		@extended_race
		!push_eax
		!push_ebx
		!push_ecx
		!push_edx
		!push_ebp
		!push_esi

		; race ;
		!inc_eax
		!push_eax

		!call >IEex_GetLuaState
		!mov_ebx_eax

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CGameSprite_GetRacialFavoredClass"), 4}, [[
		!push_ebx
		!call >_lua_getglobal
		!add_esp_byte 08

		; race ;
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 01
		!push_ebx
		!call >_lua_pcallk
		!add_esp_byte 18
		!push_ebx
		!call >IEex_CheckCallError
		!test_eax_eax
		!jz_dword >ok
		!mov_edi #1
		!jmp_dword >error

		@ok
		!push_byte 00
		!push_byte FF
		!push_ebx
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!push_eax
		!push_byte FE
		!push_ebx
		!call >_lua_settop
		!add_esp_byte 08
		!pop_edi

		@error
		!pop_esi
		!pop_ebp
		!pop_edx
		!pop_ecx
		!pop_ebx
		!pop_eax
		!jmp_dword :7646B7

	]]})

	----------------------------------------------------------------------------
	-- Run CtrlAltDelete:EnableCheatKeys() by default if Cheats are turned on --
	----------------------------------------------------------------------------

	IEex_HookReturnNOPs(0x686EAC, 1, {[[
		!mov_eax_[dword] #8CF6DC
		!mov_eax_[eax+dword] #1C54
		!mov_eax_[eax+dword] #446E
		!mov_[esi+dword]_eax #156
	]]})

	-------------------------------------------------------------------------------
	-- Load screen's hint text should render correctly on widescreen resolutions --
	-------------------------------------------------------------------------------

	IEex_HookAfterCall(0x44229E, {[[
		!push_eax
		!mov_[esp+byte]_dword 28 #0
		!mov_[esp+byte]_dword 2C #0
		!movzx_eax_word:[dword] #8BA31C
		!mov_[esp+byte]_eax 30
		!movzx_eax_word:[dword] #8BA31E
		!mov_[esp+byte]_eax 34
		!pop_eax
	]]})

	-----------------------------------------------------------------------
	-- Inventory shouldn't crash if character has non-standard animation --
	-----------------------------------------------------------------------

	IEex_HookRestore(0x62EFA1, 0, 6, {[[

		!push_eax

		!mov_eax_edi
		!and_eax_dword #F000
		!cmp_eax_dword #5000
		!je_dword >character_animation
		!cmp_eax_dword #6000
		!jne_dword >skip

		@character_animation
		!mov_eax_edi
		!and_eax_dword #F00
		!cmp_eax_dword #400
		!jne_dword >no_skip

		!mov_eax_edi
		!and_eax_byte 0F
		!cmp_eax_byte 01
		!je_dword >no_skip
		!cmp_eax_byte 05
		!ja_dword >no_skip

		; The following use the OLD character animation type, (which is invalid for this flag):
		      0x6400 <unlisted>
		      0x6402 MONK
		      0x6403 Skeleton (BG)
		      0x6404 <unlisted>
		      0x6405 Doom Guard
		;

		@skip
		!pop_eax
		!jmp_dword >return_skip

		@no_skip
		!pop_eax
		; fall through to restore/return ;

	]]})

	IEex_EnableCodeProtection()

end)()
