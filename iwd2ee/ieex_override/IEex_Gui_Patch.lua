
(function()

	-------------------------------
	-- IEex_Quickloot_ScrollLeft --
	-------------------------------

	local IEex_Quickloot_ScrollLeft_OnLButtonClick = IEex_WriteAssemblyAuto({[[

		!push_complete_state

		; control ;
		!push_ecx

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_Async_Quickloot_ScrollLeft"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; control ;
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
		!call >IEex_CheckCallError_Async

		!pop_complete_state
		!ret_word 08 00

	]]})

	IEex_DefineCustomButtonControl("IEex_Quickloot_ScrollLeft", {
		["OnLButtonClick"] = IEex_Quickloot_ScrollLeft_OnLButtonClick,
		["OnLButtonDoubleClick"] = 0x4D4D70, -- CUIControlButton_OnLButtonDown; prevents double-click cooldown.
	})

	--------------------------------
	-- IEex_Quickloot_ScrollRight --
	--------------------------------

	local IEex_Quickloot_ScrollRight_OnLButtonClick = IEex_WriteAssemblyAuto({[[

		!push_complete_state

		; control ;
		!push_ecx

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_Async_Quickloot_ScrollRight"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; control ;
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
		!call >IEex_CheckCallError_Async

		!pop_complete_state
		!ret_word 08 00

	]]})

	IEex_DefineCustomButtonControl("IEex_Quickloot_ScrollRight", {
		["OnLButtonClick"] = IEex_Quickloot_ScrollRight_OnLButtonClick,
		["OnLButtonDoubleClick"] = 0x4D4D70, -- CUIControlButton_OnLButtonDown; prevents double-click cooldown.
	})

	-------------------------------
	-- Dynamic Control Overrides --
	-------------------------------

	IEex_AddControlOverride("GUIW08", 23, 10, IEex_ControlType.IEex_Quickloot_ScrollLeft)
	IEex_AddControlOverride("GUIW10", 23, 10, IEex_ControlType.IEex_Quickloot_ScrollLeft)
	IEex_AddControlOverride("GUIW08", 23, 11, IEex_ControlType.IEex_Quickloot_ScrollRight)
	IEex_AddControlOverride("GUIW10", 23, 11, IEex_ControlType.IEex_Quickloot_ScrollRight)

	-------------
	-- Patches --
	-------------

	IEex_DisableCodeProtection()

	local activeContainerIDFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetActiveContainerID")
	local activeContainerSpriteIDFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetActiveContainerSpriteID")
	local containerItemIndexFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetContainerItemIndex")
	local onlyUpdateSlotFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot")

	--------------------
	--- GUI Hooks ASM --
	--------------------

	-- CUIControlBase_CreateControl
	IEex_HookJump(0x76D41B, 0, {[[

		!push_registers_iwd2

		!xor_ebx_ebx
		!jnz_dword >original_fail
		!mov_ebx #1

		@original_fail

		; CHU resref ;
		!push_edx

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CUIControlBase_CreateControl"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; CHU resref ;
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; panel ;
		!push_edi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; controlInfo ;
		!push_esi
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
		!push_byte 03
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError
		!test_eax_eax
		!jz_dword >ok
		!xor_eax_eax
		!jmp_dword >error

		@ok
		!push_byte 00
		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!push_eax
		!push_byte FE
		!push_dword *_g_lua
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

	-- CUIManager_fInit
	IEex_HookBeforeCall(0x4D3D55, {[[

		!push_all_registers_iwd2

		; resref ;
		!push_[ecx+byte] 10

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CUIManager_fInit_CHUInitialized"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; CUIManager ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; resref ;
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
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2
	]]})

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
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError_Async
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

	-- 0x695C8E OnLButtonClick - CUIControlScrollBarWorldContainer_UpdateScrollBar
	IEex_HookBeforeCall(0x695C8E, {[[
		!push_[esp+byte] 18
		!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot
		!test_eax_eax
		!jnz_dword >return
	]]})

	-- 0x696080 OnLButtonClick - CUIControlEncumbrance_SetVolume
	IEex_HookBeforeCall(0x696080, {[[
		!push_[esp+byte] 20
		!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot
		!test_eax_eax
		!jz_dword >call
		!add_esp_byte 08
		!jmp_dword >return
	]]})

	-- 0x69608D OnLButtonClick - CUIControlEncumbrance_SetEncumbrance
	IEex_HookBeforeCall(0x69608D, {[[
		!push_[esp+byte] 20
		!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot
		!test_eax_eax
		!jz_dword >call
		!add_esp_byte 08
		!jmp_dword >return
	]]})

	-- 0x69608D OnLButtonClick - CUIControlLabel_SetText
	IEex_HookBeforeCall(0x6960EE, {[[
		!push_[esp+byte] 1C
		!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot
		!test_eax_eax
		!jz_dword >call
		!add_esp_byte 04
		!jmp_dword >return
	]]})

	-- push func_name
	-- push arg
	IEex_WriteAssemblyAuto({[[

		$IEex_CallIntsOneArgOneReturn
		!push_state

		!push_[ebp+byte] 0C
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; arg ;
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
		!push_byte 01
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError
		!jz_dword >ok
		!mov_eax #FFFFFFFF
		!jmp_dword >error

		@ok
		!push_byte 00
		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!push_eax
		!push_byte FE
		!push_dword *_g_lua
		!call >_lua_settop
		!add_esp_byte 08
		!pop_eax

		@error
		!pop_state
		!ret_word 08 00
	]]})

	-- 0x69589C OnLButtonClick - activeContainerID
	IEex_HookRestore(0x69589C, 0, 6, {[[
		!push_dword ]], {activeContainerIDFuncName, 4}, [[
		!push_[esp+byte] 08
		!call >IEex_CallIntsOneArgOneReturn
		!cmp_eax_byte FF
		!jne_dword >return_skip
	]]})

	-- 0x6958C7 OnLButtonClick - activeContainerSpriteID
	IEex_HookRestore(0x6958C7, 0, 6, {[[
		!push_dword ]], {activeContainerSpriteIDFuncName, 4}, [[
		!push_[esp+byte] 08
		!call >IEex_CallIntsOneArgOneReturn
		!mov_esi_eax
		!cmp_eax_byte FF
		!jne_dword >return_skip
	]]})

	-- 0x6959A3 OnLButtonClick - m_nTopContainerRow
	IEex_HookRestore(0x6959A3, 0, 8, {[[

		; save eax because I clobber it ;
		!push_eax

		!push_dword ]], {containerItemIndexFuncName, 4}, [[
		!push_[esp+byte] 0C
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

	-- 0x696208 Render - activeContainerSpriteID
	IEex_HookRestore(0x696208, 0, 6, {[[
		!push_dword ]], {activeContainerSpriteIDFuncName, 4}, [[
		!push_esi
		!call >IEex_CallIntsOneArgOneReturn
		!cmp_eax_byte FF
		!jne_dword >return_skip
	]]})

	-- 0x69623F Render - activeContainerID
	IEex_HookRestore(0x69623F, 0, 6, {[[
		!push_dword ]], {activeContainerIDFuncName, 4}, [[
		!push_esi
		!call >IEex_CallIntsOneArgOneReturn
		!mov_ebx_eax
		!cmp_eax_byte FF
		!jne_dword >return_skip
	]]})

	-- 0x69627D Render - m_nTopContainerRow
	IEex_HookRestore(0x69627D, 0, 8, {[[

		; save eax because I clobber it ;
		!push_eax

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

	IEex_HookRestore(0x696107, 0, 7, {[[

		!push_complete_state

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_Async_CUIControlButtonWorldContainerSlot_OnLButtonClick_Done"), 4}, [[
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
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError_Async

		!pop_complete_state
	]]})

	IEex_HookBeforeCall(0x68DF87, {[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CScreenWorld_TimerSynchronousUpdate"), 4}, [[
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
		!push_byte 00
		!push_byte 00
		!push_dword *_g_lua_async
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError_Async

		!pop_all_registers_iwd2
		!ret_word 08 00
	]]}))

	IEex_HookAfterRestore(0x47F954, 0, 5, {[[

		!test_eax_eax
		!jnz_dword >return

		!push_registers_iwd2

		!mov_edx_[dword] *IEex_Bridge_Quickloot_HighlightContainerID
		!xor_eax_eax
		!cmp_edx_[esi+byte] 5C
		!jne_dword >no_highlight
		!mov_eax #1

		@no_highlight
		!pop_registers_iwd2
	]]})

	-- Redirect empty CUIControlButtonWorldContainerSlot_OnLButtonDoubleClick to CUIControlButton_OnLButtonDown.
	-- Prevents double-click cooldown.
	IEex_WriteDword(0x85A3E4, 0x4D4D70)

	IEex_EnableCodeProtection()

end)()
