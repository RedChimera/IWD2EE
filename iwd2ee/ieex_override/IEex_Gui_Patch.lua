
(function()

	IEex_DisableCodeProtection()


	local activeContainerIDFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_GetActiveContainerID")
	local activeContainerSpriteIDFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_GetActiveContainerSpriteID")
	local containerItemIndexFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_GetContainerItemIndex")
	local onlyUpdateSlotFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot")

	----------------------------------------------
	-- IEex_Extern_CUIControlBase_CreateControl --
	----------------------------------------------

	IEex_HookJump(0x76D41B, 0, {[[

		!push_registers_iwd2

		!xor_ebx_ebx
		!jnz_dword >original_fail
		!mov_ebx #1

		@original_fail

		; CHU resref ;
		!push_edx

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CUIControlBase_CreateControl"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; CHU resref ;
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; panel ;
		!push_edi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; controlInfo ;
		!push_esi
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
		!test_eax_eax
		!jz_dword >ok
		!xor_eax_eax
		!jmp_dword >error

		@ok
		!push_byte FF
		!push_dword *_g_lua_async
		!call >_lua_tonumber
		!add_esp_byte 08
		!call >__ftol2_sse
		!push_eax
		!push_byte FE
		!push_dword *_g_lua_async
		!call >_lua_settop
		!add_esp_byte 08
		!pop_eax

		@error
		!test_eax_eax
		!jz_dword >not_custom
		!pop_registers_iwd2
		!jmp_dword :76E93F

		@not_custom
		!test_ebx_ebx
		!pop_registers_iwd2
		!jnz_dword >jmp_success
		!jmp_dword >jmp_fail
	]]})

	-------------------------------------------------
	-- IEex_Extern_CUIManager_fInit_CHUInitialized --
	-------------------------------------------------

	IEex_HookBeforeCall(0x4D3D55, {[[

		!push_all_registers_iwd2

		; resref ;
		!push_[ecx+byte] 10

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CUIManager_fInit_CHUInitialized"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; CUIManager ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; resref ;
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

		!pop_all_registers_iwd2
	]]})

	-------------------------------------------------------------------------------------
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot --
	-------------------------------------------------------------------------------------

	IEex_WriteAssemblyAuto({[[

		$IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot
		!push_state

		!push_dword ]], {onlyUpdateSlotFuncName, 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; arg ;
		!push_[ebp+byte] 08
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
		!jz_dword >ok
		!xor_eax_eax
		!jmp_dword >error

		@ok
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

		@error
		!pop_state
		!ret_word 04 00
	]]})

	-------------------------------------------------------------------------------------
	-- CUIControlScrollBarWorldContainer_UpdateScrollBar                               --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot --
	-------------------------------------------------------------------------------------

	IEex_HookBeforeCall(0x695C8E, {[[
		!push_[esp+byte] 18
		!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot
		!test_eax_eax
		!jnz_dword >return
	]]})

	-------------------------------------------------------------------------------------
	-- CUIControlEncumbrance_SetVolume                                                 --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot --
	-------------------------------------------------------------------------------------

	IEex_HookBeforeCall(0x696080, {[[
		!push_[esp+byte] 20
		!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot
		!test_eax_eax
		!jz_dword >call
		!add_esp_byte 08
		!jmp_dword >return
	]]})

	-------------------------------------------------------------------------------------
	-- CUIControlEncumbrance_SetEncumbrance                                            --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot --
	-------------------------------------------------------------------------------------

	IEex_HookBeforeCall(0x69608D, {[[
		!push_[esp+byte] 20
		!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot
		!test_eax_eax
		!jz_dword >call
		!add_esp_byte 08
		!jmp_dword >return
	]]})

	-------------------------------------------------------------------------------------
	-- CUIControlLabel_SetText                                                         --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot --
	-------------------------------------------------------------------------------------

	IEex_HookBeforeCall(0x6960EE, {[[
		!push_[esp+byte] 1C
		!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot
		!test_eax_eax
		!jz_dword >call
		!add_esp_byte 04
		!jmp_dword >return
	]]})

	---------------------
	-- push lua_State* --
	-- push func_name  --
	-- push arg        --
	---------------------
	IEex_WriteAssemblyAuto({[[

		$IEex_CallIntsOneArgOneReturn
		!push_state

		!push_[ebp+byte] 0C
		!push_[ebp+byte] 10
		!call >_lua_getglobal
		!add_esp_byte 08

		; arg ;
		!push_[ebp+byte] 08
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_[ebp+byte] 10
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 01
		!push_byte 01
		!push_[ebp+byte] 10
		!call >_lua_pcall
		!add_esp_byte 10
		!push_[ebp+byte] 10
		!call >IEex_CheckCallError
		!jz_dword >ok
		!mov_eax #FFFFFFFF
		!jmp_dword >error

		@ok
		!push_byte FF
		!push_[ebp+byte] 10
		!call >_lua_tonumber
		!add_esp_byte 08
		!call >__ftol2_sse
		!push_eax
		!push_byte FE
		!push_[ebp+byte] 10
		!call >_lua_settop
		!add_esp_byte 08
		!pop_eax

		@error
		!pop_state
		!ret_word 0C 00
	]]})

	-------------------------------------------------------------------------
	-- OnLButtonClick - activeContainerID                                  --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_GetActiveContainerID --
	-------------------------------------------------------------------------

	IEex_HookRestore(0x69589C, 0, 6, {[[
		!push_dword *_g_lua_async
		!push_dword ]], {activeContainerIDFuncName, 4}, [[
		!push_[esp+byte] 20
		!call >IEex_CallIntsOneArgOneReturn
		!cmp_eax_byte FF
		!jne_dword >return_skip
	]]})

	-------------------------------------------------------------------------------
	-- OnLButtonClick - activeContainerSpriteID                                  --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_GetActiveContainerSpriteID --
	-------------------------------------------------------------------------------

	IEex_HookRestore(0x6958C7, 0, 6, {[[
		!push_dword *_g_lua_async
		!push_dword ]], {activeContainerSpriteIDFuncName, 4}, [[
		!push_[esp+byte] 20
		!call >IEex_CallIntsOneArgOneReturn
		!mov_esi_eax
		!cmp_eax_byte FF
		!jne_dword >return_skip
	]]})

	--------------------------------------------------------------------------
	-- OnLButtonClick - m_nTopContainerRow                                  --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_GetContainerItemIndex --
	--------------------------------------------------------------------------

	IEex_HookRestore(0x6959A3, 0, 8, {[[

		; save eax because I clobber it ;
		!push_eax

		!push_dword *_g_lua_async
		!push_dword ]], {containerItemIndexFuncName, 4}, [[
		!push_[esp+byte] 24
		!call >IEex_CallIntsOneArgOneReturn
		!cmp_eax_byte FF

		!jne_dword >override
		; restore eax ;
		!pop_eax
		!jmp_dword >return

		@override
		!mov_edi_eax
		; clear eax off of stack (only matters when running normal code) ;
		!add_esp_byte 04
		!mov_[esp+byte]_edi 34
		!jmp_dword >return_skip
	]]})

	-------------------------------------------------------------------------------
	-- Render - activeContainerSpriteID                                          --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_GetActiveContainerSpriteID --
	-------------------------------------------------------------------------------

	IEex_HookRestore(0x696208, 0, 6, {[[
		!push_dword *_g_lua
		!push_dword ]], {activeContainerSpriteIDFuncName, 4}, [[
		!push_esi
		!call >IEex_CallIntsOneArgOneReturn
		!cmp_eax_byte FF
		!jne_dword >return_skip
	]]})

	-------------------------------------------------------------------------
	-- Render - activeContainerID                                          --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_GetActiveContainerID --
	-------------------------------------------------------------------------

	IEex_HookRestore(0x69623F, 0, 6, {[[
		!push_dword *_g_lua
		!push_dword ]], {activeContainerIDFuncName, 4}, [[
		!push_esi
		!call >IEex_CallIntsOneArgOneReturn
		!mov_ebx_eax
		!cmp_eax_byte FF
		!jne_dword >return_skip
	]]})

	--------------------------------------------------------------------------
	-- Render - m_nTopContainerRow                                          --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_GetContainerItemIndex --
	--------------------------------------------------------------------------

	IEex_HookRestore(0x69627D, 0, 8, {[[

		; save eax because I clobber it ;
		!push_eax

		!push_dword *_g_lua
		!push_dword ]], {containerItemIndexFuncName, 4}, [[
		!push_esi
		!call >IEex_CallIntsOneArgOneReturn
		!cmp_eax_byte FF
		!jne_dword >override

		; restore eax ;
		!pop_eax
		!jmp_dword >return

		@override
		; clear eax off of stack (I'm overriding it) ;
		!add_esp_byte 04
		!lea_ecx_[esp+byte] 2C
		!mov_[esp+byte]_edi 34
		!jmp_dword >return_skip
	]]})

	------------------------------------------------------------------------
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_Done --
	------------------------------------------------------------------------

	IEex_HookRestore(0x696107, 0, 7, {[[

		!push_complete_state

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_Done"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; control ;
		!push_[ebp+byte] 08
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

		!pop_complete_state
	]]})

	-------------------------------------------------
	-- IEex_Extern_CScreenWorld_AsynchronousUpdate --
	-------------------------------------------------

	IEex_HookRestore(0x68C3D0, 0, 7, {[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CScreenWorld_AsynchronousUpdate"), 4}, [[
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

	------------------------------------------------------
	-- IEex_Extern_CScreenWorld_OnInventoryButtonRClick --
	------------------------------------------------------

	-- Enable right-click on inventory button
	IEex_WriteAssembly(0x77CFD6, {"!mov_eax 03"})

	IEex_WriteDword(0x85D798, IEex_WriteAssemblyAuto({[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CScreenWorld_OnInventoryButtonRClick"), 4}, [[
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
		!ret_word 08 00
	]]}))

	-----------------------------------------
	-- IEex_Extern_GetHighlightContainerID --
	-----------------------------------------

	IEex_HookAfterRestore(0x47F954, 0, 5, {[[

		!test_eax_eax
		!jnz_dword >return

		!push_registers_iwd2

		!call >IEex_GetLuaState
		!mov_ebx_eax

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_GetHighlightContainerID"), 4}, [[
		!push_ebx
		!call >_lua_getglobal
		!add_esp_byte 08

		!push_byte 00
		!push_byte 01
		!push_byte 00
		!push_ebx
		!call >_lua_pcall
		!add_esp_byte 10
		!push_ebx
		!call >IEex_CheckCallError

		!push_byte FF
		!push_ebx
		!call >_lua_tonumber
		!add_esp_byte 08
		!call >__ftol2_sse
		!push_eax
		!push_byte FE
		!push_ebx
		!call >_lua_settop
		!add_esp_byte 08
		!pop_edx

		!xor_eax_eax
		!cmp_edx_[esi+byte] 5C
		!jne_dword >no_highlight
		!mov_eax #1

		@no_highlight
		!pop_registers_iwd2
	]]})

	------------------------------------------------------------------------------
	-- Redirect empty CUIControlButtonWorldContainerSlot_OnLButtonDoubleClick() --
	-- to CUIControlButtonWorldContainerSlot_OnLButtonDown().                   --
	-- Prevents double-click cooldown.                                          --
	------------------------------------------------------------------------------

	IEex_WriteDword(0x85A3E4, 0x66D760)

	-------------------------------------------
	-- IEex_Extern_OnUpdateRecordDescription --
	-------------------------------------------

	IEex_HookBeforeCall(0x5DC792, IEex_FlattenTable({[[
		!mark_esp(50)
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_OnUpdateRecordDescription", {
			["args"] = {
				{"!push(esi)"},
				{"!push_using_marked_esp([esp-3C])"},
				{"!push(ebx)"},
				{"!push(ecx)"},
			},
		}), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))

	------------------------------------------------------------------
	-- Smooth Cursor Drawing                                        --
	-- Unlock refresh rate to a maximum of 200fps and render cursor --
	-- at true position; cursor logic still updates at 30fps.       --
	------------------------------------------------------------------

	IEex_HookRestore(0x79FA44, 12, 0, {[[
		!push(eax)
		!sub_esp_byte 08

		!push_esp
		!call_[dword] #8474D4 ; GetCursorPos ;

		!push(esp)
		!mov(eax,[8CF6DC])
		!push([eax+94])
		!call_[dword] #847470 ; ScreenToClient ;

		!mov(ebx,[esp])
		!mov(ecx,[esp+4])

		!add_esp_byte 08
		!pop(eax)
	]]})

	IEex_HookRestore(0x79F80F, 6, 0, {[[
		!push(eax)
		!sub_esp_byte 08

		!push_esp
		!call_[dword] #8474D4 ; GetCursorPos ;

		!push(esp)
		!mov(eax,[8CF6DC])
		!push([eax+94])
		!call_[dword] #847470 ; ScreenToClient ;

		!mov(ecx,[esp])
		!mov(edx,[esp+4])

		!add_esp_byte 08
		!pop(eax)
	]]})

	IEex_WriteAssembly(0x79F819, {"!repeat(6,!nop)"})

	IEex_HookAfterRestore(0x79284D, 0, 6, {[[
		!push_dword #5
		!call >IEex_Helper_Sleep
		!mov([esi+193A],1)
	]]})

	--------------------------------------------------
	-- Remove click cooldown from actionbar buttons --
	--------------------------------------------------

	IEex_WriteDword(0x85C518, 0x4D4D70)

	-------------------------------------------
	-- Remove cooldown from dialog responses --
	-------------------------------------------

	IEex_WriteAssembly(0x687606, {"!repeat(2,!nop)"}) -- Number key
	IEex_WriteAssembly(0x68746A, {"!repeat(6,!nop)"}) -- Enter
	IEex_WriteAssembly(0x6968E0, {"!repeat(2,!nop)"}) -- Left click (continue)
	IEex_WriteAssembly(0x77BCC8, {"!repeat(2,!nop)"}) -- Left click (reply)

	-- Redirect empty Continue button OnLButtonDoubleClick() => OnLButtonDown()
	IEex_WriteDword(0x85A45C, 0x4D4D70)

	IEex_EnableCodeProtection()

end)()
