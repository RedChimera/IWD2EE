
(function()

	IEex_DisableCodeProtection()


	local activeContainerIDFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_GetActiveContainerID")
	local activeContainerSpriteIDFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_GetActiveContainerSpriteID")
	local containerItemIndexFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_GetContainerItemIndex")
	local onlyUpdateSlotFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot")

	----------------------------------------------
	-- IEex_Extern_CUIControlBase_CreateControl --
	----------------------------------------------

	if not IEex_Vanilla then

		IEex_HookJump(0x76D41B, 0, IEex_FlattenTable({
			{[[
				!push_registers_iwd2

				!xor_ebx_ebx
				!jnz_dword >original_fail
				!mov_ebx #1

				@original_fail
			]]},
			IEex_GenLuaCall("IEex_Extern_CUIControlBase_CreateControl", {
				["args"] = {
					{"!push(edx)"}, -- CHU resref
					{"!push(edi)"}, -- panel
					{"!push(esi)"}, -- controlInfo
				},
				["returnType"] = IEex_LuaCallReturnType.Number,
			}),
			{[[
				@call_error
				!test_eax_eax
				!jz_dword >not_custom
				!pop_registers_iwd2
				!jmp_dword :76E93F

				@not_custom
				!test_ebx_ebx
				!pop_registers_iwd2
				!jnz_dword >jmp_success
				!jmp_dword >jmp_fail
			]]},
		}))
	end

	-------------------------------------------------
	-- IEex_Extern_CUIManager_fInit_CHUInitialized --
	-------------------------------------------------

	IEex_HookBeforeCall(0x4D3D55, IEex_FlattenTable({
		{"!push_all_registers_iwd2"},
		IEex_GenLuaCall("IEex_Extern_CUIManager_fInit_CHUInitialized", {
			["args"] = {
				{"!push(esi)"},
				{"!push([ecx+10])"},
			},
		}),
		{[[
			@call_error
			!pop_all_registers_iwd2
		]]},
	}))

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

	if not IEex_Vanilla then
		IEex_HookBeforeCall(0x695C8E, {[[
			!push_[esp+byte] 18
			!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot
			!test_eax_eax
			!jnz_dword >return
		]]})
	end

	-------------------------------------------------------------------------------------
	-- CUIControlEncumbrance_SetVolume                                                 --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot --
	-------------------------------------------------------------------------------------

	if not IEex_Vanilla then
		IEex_HookBeforeCall(0x696080, {[[
			!push_[esp+byte] 20
			!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot
			!test_eax_eax
			!jz_dword >call
			!add_esp_byte 08
			!jmp_dword >return
		]]})
	end

	-------------------------------------------------------------------------------------
	-- CUIControlEncumbrance_SetEncumbrance                                            --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot --
	-------------------------------------------------------------------------------------

	if not IEex_Vanilla then
		IEex_HookBeforeCall(0x69608D, {[[
			!push_[esp+byte] 20
			!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot
			!test_eax_eax
			!jz_dword >call
			!add_esp_byte 08
			!jmp_dword >return
		]]})
	end

	-------------------------------------------------------------------------------------
	-- CUIControlLabel_SetText                                                         --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot --
	-------------------------------------------------------------------------------------

	if not IEex_Vanilla then
		IEex_HookBeforeCall(0x6960EE, {[[
			!push_[esp+byte] 1C
			!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetOnlyUpdateSlot
			!test_eax_eax
			!jz_dword >call
			!add_esp_byte 04
			!jmp_dword >return
		]]})
	end

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

	if not IEex_Vanilla then
		IEex_HookRestore(0x69589C, 0, 6, {[[
			!push_dword *_g_lua_async
			!push_dword ]], {activeContainerIDFuncName, 4}, [[
			!push_[esp+byte] 20
			!call >IEex_CallIntsOneArgOneReturn
			!cmp_eax_byte FF
			!jne_dword >return_skip
		]]})
	end

	-------------------------------------------------------------------------------
	-- OnLButtonClick - activeContainerSpriteID                                  --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_GetActiveContainerSpriteID --
	-------------------------------------------------------------------------------

	if not IEex_Vanilla then
		IEex_HookRestore(0x6958C7, 0, 6, {[[
			!push_dword *_g_lua_async
			!push_dword ]], {activeContainerSpriteIDFuncName, 4}, [[
			!push_[esp+byte] 20
			!call >IEex_CallIntsOneArgOneReturn
			!mov_esi_eax
			!cmp_eax_byte FF
			!jne_dword >return_skip
		]]})
	end

	--------------------------------------------------------------------------
	-- OnLButtonClick - m_nTopContainerRow                                  --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_GetContainerItemIndex --
	--------------------------------------------------------------------------

	if not IEex_Vanilla then

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
	end

	-------------------------------------------------------------------------------
	-- Render - activeContainerSpriteID                                          --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_GetActiveContainerSpriteID --
	-------------------------------------------------------------------------------

	if not IEex_Vanilla then
		IEex_HookRestore(0x696208, 0, 6, {[[
			!push_dword *_g_lua
			!push_dword ]], {activeContainerSpriteIDFuncName, 4}, [[
			!push_esi
			!call >IEex_CallIntsOneArgOneReturn
			!cmp_eax_byte FF
			!jne_dword >return_skip
		]]})
	end

	-------------------------------------------------------------------------
	-- Render - activeContainerID                                          --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_GetActiveContainerID --
	-------------------------------------------------------------------------

	if not IEex_Vanilla then
		IEex_HookRestore(0x69623F, 0, 6, {[[
			!push_dword *_g_lua
			!push_dword ]], {activeContainerIDFuncName, 4}, [[
			!push_esi
			!call >IEex_CallIntsOneArgOneReturn
			!mov_ebx_eax
			!cmp_eax_byte FF
			!jne_dword >return_skip
		]]})
	end

	--------------------------------------------------------------------------
	-- Render - m_nTopContainerRow                                          --
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_GetContainerItemIndex --
	--------------------------------------------------------------------------

	if not IEex_Vanilla then

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
	end

	------------------------------------------------------------------------
	-- IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_Done --
	------------------------------------------------------------------------

	if not IEex_Vanilla then

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
	end

	-------------------------------------------------
	-- IEex_Extern_CScreenWorld_AsynchronousUpdate --
	-------------------------------------------------

	if not IEex_Vanilla then

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
	end

	------------------------------------------------------
	-- IEex_Extern_CScreenWorld_OnInventoryButtonRClick --
	------------------------------------------------------

	if not IEex_Vanilla then

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
	end

	-----------------------------------------
	-- IEex_Extern_GetHighlightContainerID --
	-----------------------------------------

	if not IEex_Vanilla then

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
	end

	------------------------------------------------------------------------------
	-- Redirect empty CUIControlButtonWorldContainerSlot_OnLButtonDoubleClick() --
	-- to CUIControlButtonWorldContainerSlot_OnLButtonDown().                   --
	-- Prevents double-click cooldown.                                          --
	------------------------------------------------------------------------------

	if not IEex_Vanilla then
		IEex_WriteDword(0x85A3E4, 0x66D760)
	end

	-------------------------------------------
	-- IEex_Extern_OnUpdateRecordDescription --
	-------------------------------------------

	if not IEex_Vanilla then
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
	end

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

	-----------------------------------------
	-- Also use space to "Continue" dialog --
	-----------------------------------------

	IEex_HookJump(0x687434, 5, {[[
		!je_dword >jmp_fail
		!cmp_al_byte 20 ; spacebar ;
	]]})

	--------------------------------------
	-- IEex_Extern_OnOptionsScreenESC() --
	--------------------------------------

	if not IEex_Vanilla then
		IEex_HookBeforeCall(0x654446, IEex_FlattenTable({
			{[[
				!push_registers_iwd2
			]]},
			IEex_GenLuaCall("IEex_Extern_OnOptionsScreenESC", {
				["args"] = {
					{"!push(ecx)"}, -- CScreenOptions
				},
				["returnType"] = IEex_LuaCallReturnType.Boolean,
			}),
			{[[
				@call_error
				!test_eax_eax
				!pop_registers_iwd2
				!jnz_dword >return
			]]},
		}))
	end

	-----------------------------------------------------------------------------
	-- Don't throw assert when restoring CVidMode on non-vanilla options panel --
	-----------------------------------------------------------------------------

	if not IEex_Vanilla then
		IEex_WriteAssembly(0x6554FB, {"!repeat(5,!nop)"})
	end

	--------------------------------------------------
	-- Render CScreenWorld UI AFTER the worldscreen --
	--------------------------------------------------

	IEex_WriteAssembly(0x68DF87, {"!repeat(5,!nop)"})

	IEex_HookBeforeCall(0x68DF9F, IEex_FlattenTable({
		{[[
			!push_registers_iwd2
		]]},
		IEex_GenLuaCall("IEex_Extern_BeforeWorldRender"),
		{[[
			@call_error
			!pop_registers_iwd2
		]]},
	}))

	IEex_HookRestore(0x68DFB6, 0, 5, {[[
		!mov(ecx,ebp)
		!call :4D4540 ; CUIManager_Render ;
	]]})

	---------------------------------------
	-- IEex_Extern_MouseInAreaViewport() --
	---------------------------------------

	IEex_HookReturnNOPs(0x46E45F, 0x4A, IEex_FlattenTable({
		{[[
			!mark_esp
			!push_registers_iwd2
		]]},
		IEex_GenLuaCall("IEex_Extern_MouseInAreaViewport", {
			["args"] = {
				{"!push(esi)"},
			},
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}),
		{[[
			!jmp_dword >no_error

			@call_error
			!mov(eax,1)

			@no_error
			!marked_esp !mov([esp+1C],eax)
			!pop_registers_iwd2
		]]},
	}))

	---------------------------------------------
	-- IEex_Extern_RejectGetWorldCoordinates() --
	---------------------------------------------

	IEex_HookJump(0x5CDFCE, 3, IEex_FlattenTable({
		{[[
			!push_all_registers_iwd2
		]]},
		IEex_GenLuaCall("IEex_Extern_RejectGetWorldCoordinates", {
			["args"] = {
				{"!push_ecx"},
				{"!push([eax])"},
				{"!push([eax+4])"},
			},
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}),
		{[[
			!jmp_dword >no_error

			@call_error
			!xor_eax_eax

			@no_error
			!test_eax_eax
			!pop_all_registers_iwd2
			!jnz_dword >jmp_success
			!cmp(edi,ebx)
		]]},
	}))

	IEex_HookJump(0x4765DC, 0, IEex_FlattenTable({
		{[[
			!push_all_registers_iwd2
		]]},
		IEex_GenLuaCall("IEex_Extern_RejectGetWorldCoordinates", {
			["args"] = {
				{"!lea(eax,[edi+4CC]) !push_eax"},
				{"!push([ebp])"},
				{"!push([ebp+4])"},
			},
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}),
		{[[
			!jmp_dword >no_error

			@call_error
			!xor_eax_eax

			@no_error
			!test_eax_eax
			!pop_all_registers_iwd2
			!jnz_dword >jmp_success
			!cmp(ecx,edx)
		]]},
	}))

	IEex_HookJump(0x475465, 0, IEex_FlattenTable({
		{[[
			!push_all_registers_iwd2
		]]},
		IEex_GenLuaCall("IEex_Extern_RejectGetWorldCoordinates", {
			["args"] = {
				{"!lea(eax,[esi+4CC]) !push_eax"},
				{"!push([edi])"},
				{"!push([edi+4])"},
			},
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}),
		{[[
			!jmp_dword >no_error

			@call_error
			!xor_eax_eax

			@no_error
			!test_eax_eax
			!pop_all_registers_iwd2
			!jnz_dword >jmp_success
			!cmp(eax,[esi+514])
		]]},
	}))

	-----------------------------------------------------
	-- IEex_Extern_OverrideWorldScreenScrollbarFocus() --
	-----------------------------------------------------

	if not IEex_Vanilla then

		-- [Before !push_all_registers_iwd2]
		-- Don't crash in CScreenWorld_TimerSynchronousUpdate() if m_displayStale
		-- was set to 1 by the above patch when in the middle of a quickload.
		-- TODO: Review other cases of m_displayStale being used to block while
		-- waiting for another thread to finish a task.
		IEex_HookAfterRestore(0x68DECB, 0, 5, IEex_FlattenTable({
			{[[
				!cmp([ebp+4],0) ; m_UIManager->m_resLoaded ;
				!jz_dword :68DF04
				!push_all_registers_iwd2
			]]},
			IEex_GenLuaCall("IEex_Extern_OverrideWorldScreenScrollbarFocus", {
				["returnType"] = IEex_LuaCallReturnType.Boolean,
			}),
			{[[
				!jmp_dword >no_error

				@call_error
				!xor_eax_eax

				@no_error
				!test_eax_eax
				!pop_all_registers_iwd2
				!jnz_dword :68DF04
			]]},
		}))
	end

	---------------------------------------
	-- IEex_Extern_OnSetActionbarState() --
	---------------------------------------

	if not IEex_Vanilla then
		IEex_HookRestore(0x589110, 0, 5, IEex_FlattenTable({
			{[[
				!mark_esp
				!push_all_registers_iwd2
			]]},
			IEex_GenLuaCall("IEex_Extern_OnSetActionbarState", {
				["args"] = {
					{"!marked_esp !push([esp+4])"}, -- nState
				},
			}),
			{[[
				@call_error
				!pop_all_registers_iwd2
			]]},
		}))
	end

	----------------------------------------------------
	-- IEex_Extern_OnActionbarUnhandledRButtonClick() --
	----------------------------------------------------

	if not IEex_Vanilla then
		IEex_HookJumpOnSuccess(0x5947DA, 0, IEex_FlattenTable({
			{[[
				!push_all_registers_iwd2
			]]},
			IEex_GenLuaCall("IEex_Extern_OnActionbarUnhandledRButtonClick", {
				["args"] = {
					{"!push_esi"}, -- nIndex
				},
			}),
			{[[
				@call_error
				!pop_all_registers_iwd2
				!jmp_dword >jmp_success
			]]},
		}))
	end

	----------------------------------------
	-- IEex_Extern_RejectWorldScreenEsc() --
	----------------------------------------

	if not IEex_Vanilla then
		IEex_HookRestore(0x68785E, 0, 6, IEex_FlattenTable({
			{[[
				!push_all_registers_iwd2
			]]},
			IEex_GenLuaCall("IEex_Extern_RejectWorldScreenEsc", {
				["returnType"] = IEex_LuaCallReturnType.Boolean,
			}),
			{[[
				!jmp_dword >no_error

				@call_error
				!xor_eax_eax

				@no_error
				!test_eax_eax
				!pop_all_registers_iwd2
				!jnz_dword :689504
			]]},
		}))
	end

	------------------------
	-- Widescreen Support --
	------------------------

	-- Select resolution on game start
	IEex_HookReturnNOPs(0x42212A, 1, IEex_FlattenTable({[[
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_InitResolution"), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))

	-- Reject non-32-bit bit depths
	IEex_HookRestore(0x79B3DF, 0, 5, IEex_FlattenTable({[[
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_CheckBitDepth", {
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}), [[
		!jmp_dword >no_error
		@call_error
		!xor_eax_eax
		@no_error
		!test_eax_eax
		!pop_all_registers_iwd2
		!jnz_dword >return
		!mov(ecx,[8CF6D8])
		!jmp_dword :79B34B
	]]}))

	-- If selected resolution is 800x600 use GUIW08, else use customized GUIW10
	IEex_HookJumpNoReturn(0x42216E, IEex_FlattenTable({[[
		!cmp(ecx,320)
		!jne_dword :422198
		!cmp(word:[8BA31E],258)
		!jne_dword :422198
		!jmp_dword :4224CC
	]]}))

	-- Don't set g_resolution[1] when using GUIW10
	IEex_WriteAssembly(0x42228C, {"!repeat(7,!nop)"})

	-- Used to tweak various GUI constants
	IEex_HookRestore(0x422848,0, 6, IEex_FlattenTable({[[
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_InitGUIConstants"), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))

	-- Used to tweak the high resolution panels
	IEex_HookAfterRestore(0x4229D5, 0, 7, IEex_FlattenTable({[[
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_InitHighResolutionPaddingPanels", {["args"] = {{"!push(esi)"}}}), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))

	-- Disable instances where the engine rendered the mouse at non-buffer-flip moments.
	-- This renders the mouse before everything is drawn to the screen, yet blocks
	-- the mouse from rendering again at buffer-flip, causing it to flicker.
	IEex_WriteAssembly(0x79F6A0, {[[
		!mov(eax,0)
		!ret
	]]})

	-- On opening the debug console
	IEex_HookAfterCall(0x69126A, IEex_FlattenTable({[[
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_StartDebugConsole"), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))

	-- On closing the debug console
	IEex_HookAfterRestore(0x6913AF, 0, 10, IEex_FlattenTable({[[
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_StopDebugConsole"), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))

	-- Blank the back buffer after switching engines (or on starting CCacheStatus)
	-- so that left-over junk isn't rendered
	IEex_HookRestore(0x790DC4, 0, 8, {[[
		!push_all_registers_iwd2
		!push(ecx)
		!call >IEex_Helper_BlankBackBuffer
		!pop_all_registers_iwd2
	]]})

	IEex_HookRestore(0x4408C2, 0, 5, {[[
		!push_all_registers_iwd2
		!call >IEex_Helper_BlankCCache1
		!pop_all_registers_iwd2
	]]})
	IEex_HookAfterRestore(0x44208D, 0, 6, {[[
		!push_all_registers_iwd2
		!call >IEex_Helper_BlankCCache2
		!pop_all_registers_iwd2
	]]})
	IEex_HookAfterRestore(0x4422AF, 0, 6, {[[
		!push_all_registers_iwd2
		!call >IEex_Helper_BlankCCache2
		!pop_all_registers_iwd2
	]]})
	IEex_HookAfterRestore(0x4427FF, 0, 6, {[[
		!push_all_registers_iwd2
		!call >IEex_Helper_BlankCCache2
		!pop_all_registers_iwd2
	]]})

	-- Tab should always force tooltip regardless of where the cursor is in relation to the viewport
	IEex_WriteAssembly(0x687AFB, {"!jmp_byte"})
	IEex_WriteAssembly(0x68BC16, {"!jmp_byte"})
	IEex_WriteAssembly(0x6873D5, {"!jmp_byte"})

	------------------------------------------------
	-- Disable Gamma-correction on mainscreen MOS --
	------------------------------------------------

	if not IEex_Vanilla then
		IEex_HookJumpToAutoReturn(0x4D3435, {[[
			!push(edi)
			!call >IEex_Helper__CUIPanel_Render__CVidMosaic_Render
		]]})
	end

	---------------------------------------------------------
	-- m_lPopupStack shouldn't be modified while           --
	-- CScreenSpell_TimerSynchronousUpdate is accessing it --
	---------------------------------------------------------

	if not IEex_Vanilla then

		local lock_IEex_CScreenSpell_m_lPopupStack = IEex_Helper_GetOrCreateGlobalLock("IEex_CScreenSpell_m_lPopupStack")

		for _, address in ipairs({0x66B480, 0x66B71E}) do
			IEex_HookJumpToAutoReturn(address, {[[
				!push_all_registers_iwd2
				!push_dword ]], {lock_IEex_CScreenSpell_m_lPopupStack, 4}, [[
				!call >IEex_Helper_LockGlobalDirect
				!pop_all_registers_iwd2
				!call >original_dest
				!push_all_registers_iwd2
				!push_dword ]], {lock_IEex_CScreenSpell_m_lPopupStack, 4}, [[
				!call >IEex_Helper_UnlockGlobalDirect
				!pop_all_registers_iwd2
			]]})
		end

		IEex_HookRestore(0x66A59C, 0, 6, {[[
			!push_all_registers_iwd2
			!push_dword ]], {lock_IEex_CScreenSpell_m_lPopupStack, 4}, [[
			!call >IEex_Helper_LockGlobalDirect
			!pop_all_registers_iwd2
		]]})

		IEex_HookRestore(0x66A6F5, 0, 5, {[[
			!push_all_registers_iwd2
			!push_dword ]], {lock_IEex_CScreenSpell_m_lPopupStack, 4}, [[
			!call >IEex_Helper_UnlockGlobalDirect
			!pop_all_registers_iwd2
		]]})
	end

	----------------------------------------------------------------------------------
	-- Dialog auto-scroll should be consistent for when it instantly moves viewport --
	----------------------------------------------------------------------------------

	IEex_HookRestore(0x484B94, 2, 3, IEex_FlattenTable({[[
		!push_registers_iwd2
		!push_eax
		]], IEex_GenLuaCall("IEex_Extern_AdjustAutoScrollY", {
			["args"] = {{"!push(esi)"}},
			["returnType"] = IEex_LuaCallReturnType.Number,
		}), [[
		@call_error
		!sub_[esp]_eax
		!pop_eax
		!pop_registers_iwd2
	]]}))

	-------------------------------------------------------------------------------------------------
	-- Remove 1-second "message screen" (non-functional?) when instantly moving viewport to dialog --
	-------------------------------------------------------------------------------------------------

	IEex_WriteAssembly(0x484BE1, {"!jmp_byte"})

	----------------------------------------------------------------------------
	-- Prevent portraits / health bars from flickering above inventory popups --
	----------------------------------------------------------------------------

	if not IEex_Vanilla then

		local noNeedRenderWhenInventoryPopupOpen = IEex_WriteAssemblyAuto({[[

			!mov_edx_[dword] #8CF6DC ; g_pBaldurChitin ;
			!test_edx_edx
			!jz_dword :4D4C20

			!mov_eax_[edx+dword] #1C68 ; m_pEngineInventory ;
			!test_eax_eax
			!jz_dword :4D4C20

			!mov_edx_[edx+dword] #3C4 ; pActiveEngine ;
			!test_edx_edx
			!jz_dword :4D4C20

			!cmp_eax_edx
			!jne_dword :4D4C20

			!mov_eax_[eax+dword] #49C ; m_pEngineInventory.m_lPopupStack.m_nCount ;
			!test_eax_eax
			!jz_dword :4D4C20

			!xor_eax_eax
			!ret
		]]})

		IEex_WriteDword(0x855AC8, noNeedRenderWhenInventoryPopupOpen) -- Inventory Portraits
		IEex_WriteDword(0x85C770, noNeedRenderWhenInventoryPopupOpen) -- Portrait Health Bars
	end

	--------------------------------------------------------------
	-- Allow CHU files to define panels at negative coordinates --
	--------------------------------------------------------------

	if not IEex_Vanilla then
		IEex_WriteAssembly(0x4D2822, {"!movsx_eax_word:[edi+byte] 04"})
		IEex_WriteAssembly(0x4D2828, {"!movsx_ecx_word:[edi+byte] 06"})
		IEex_WriteAssembly(0x4D27F4, {"!movsx_eax_word:[edi+byte] 04"})
		IEex_WriteAssembly(0x4D27FA, {"!movsx_ecx_word:[edi+byte] 06"})
	end

	------------------------------------------------------------------------------
	-- Tooltips shouldn't be killed every time a character's actionbar updates, --
	-- for example, when their effect list is processed.                        --
	------------------------------------------------------------------------------

	if not IEex_Vanilla then

		local inEffectListButtonArrayUpdateMem = IEex_Malloc(0x4)
		IEex_WriteDword(inEffectListButtonArrayUpdateMem, 0x0)

		IEex_HookBeforeAndAfterCall(0x734704,
			{"!mov_[dword]_dword", {inEffectListButtonArrayUpdateMem, 4}, "#1"},
			{"!mov_[dword]_dword", {inEffectListButtonArrayUpdateMem, 4}, "#0"}
		)

		local determineTooltipKillReason = IEex_WriteAssemblyAuto({[[

			!push_registers_iwd2

			!cmp_[dword]_byte ]], {inEffectListButtonArrayUpdateMem, 4}, [[ 00
			!jz_dword >unknown

			!mov_eax ]], {IEex_TooltipKillReason.EFFECT_LIST_UPDATE, 4}, [[
			!jmp_dword >return

			@unknown
			!mov_eax ]], {IEex_TooltipKillReason.UNKNOWN, 4}, [[

			@return
			!pop_registers_iwd2
			!ret
		]]})

		local killTooltipHookMem = IEex_Malloc(0x8)

		local shouldTooltipBeRefreshedMem = killTooltipHookMem
		IEex_WriteDword(shouldTooltipBeRefreshedMem, 0x0)

		local savedTooltipUIManagerMem = killTooltipHookMem + 0x4
		IEex_WriteDword(savedTooltipUIManagerMem, 0x0)

		IEex_HookRestore(0x4D4060, 0, 7, IEex_FlattenTable({
			{[[
				!push_all_registers_iwd2
				!mov_[dword]_ecx ]], {savedTooltipUIManagerMem, 4}, [[
			]]},
			IEex_GenLuaCall("IEex_Extern_ShouldTooltipRefreshInsteadOfDying", {
				["args"] = {
					{[[
						!call ]], {determineTooltipKillReason, 4, 4}, [[
						!push(eax)
					]]},
				},
				["returnType"] = IEex_LuaCallReturnType.Boolean,
			}),
			{[[
				!jmp_dword >no_error

				@call_error
				!xor(eax,eax)

				@no_error
				!mov_[dword]_eax ]], {shouldTooltipBeRefreshedMem, 4}, [[

				!pop_all_registers_iwd2
			]]},
		}))

		IEex_HookAfterRestore(0x4D40A8, 0, 7, {[[

			!push_all_registers_iwd2

			!cmp_[dword]_byte ]], {shouldTooltipBeRefreshedMem, 4}, [[ 00
			!jz_dword >allow_tooltip_kill

			!mov_eax_[dword] ]], {savedTooltipUIManagerMem, 4}, [[
			!mov([eax+0x76],1) ; m_bIsForceToolTip = 1 ;

			@allow_tooltip_kill
			!pop_all_registers_iwd2
		]]})
	end

	------------------------------------------------------------------
	-- Render green overlay on scrolls that the character can learn --
	--   Hardcoded resref: B3TINTG.BAM                              --
	------------------------------------------------------------------

	if not IEex_Vanilla then

		-- CUIControlButtonItemSlot::Render()
		IEex_HookJumpOnSuccess(0x62E560, 0, {[[
			!mark_esp
			!push_all_registers_iwd2
			!push(esi)                    ; pButton ;
			!marked_esp !push([esp+0x24]) ; pItem   ;
			!marked_esp !push([esp+0x14]) ; pSprite ;
			!call >IEex_Helper_PostItemSlotRenderHook
			!pop_all_registers_iwd2
		]]})

		-- CUIControlButtonStoreItem::Render()
		IEex_HookJumpOnSuccess(0x681C3B, 3, {[[
			!mark_esp
			!push_all_registers_iwd2
			!push(esi)                    ; pButton ;
			!lea(eax,[esi+0x66E])
			!push(eax)                    ; pItem   ;
			!marked_esp !push([esp+0x20]) ; pSprite ;
			!call >IEex_Helper_PostItemSlotRenderHook
			!pop_all_registers_iwd2
		]]})

		-- CUIControlButtonStorePartyItem::Render()
		IEex_HookJumpOnSuccess(0x68278B, 3, {[[
			!mark_esp
			!push_all_registers_iwd2
			!push(esi)                    ; pButton ;
			!lea(eax,[esi+0x66E])
			!push(eax)                    ; pItem   ;
			!marked_esp !push([esp+0x20]) ; pSprite ;
			!call >IEex_Helper_PostItemSlotRenderHook
			!pop_all_registers_iwd2
		]]})

		-- CUIControlButtonWorldContainerSlot::Render()
		IEex_HookJumpOnSuccess(0x696623, 3, {[[
			!mark_esp
			!push_all_registers_iwd2
			!push(esi)                    ; pButton ;
			!marked_esp !push([esp+0x1C]) ; pItem   ;
			!marked_esp !push([esp+0x10]) ; pSprite ;
			!call >IEex_Helper_PostItemSlotRenderHook
			!pop_all_registers_iwd2
		]]})

		IEex_HookReplaceFunctionMaintainOriginal(0x7AEAD0, 5, "CVidCell::RenderIconOriginal", {[[
			!jmp_dword >IEex_Helper_CVidCell_RenderIconOverride
		]]})
		IEex_Helper_DefineAddress("CVidCell::RenderIconOriginal", IEex_Label("CVidCell::RenderIconOriginal"))
	else
		-- Silence warning from IEexHelper.dll when running in vanilla mode
		IEex_Helper_DefineAddress("CVidCell::RenderIconOriginal", -1)
	end

	----------------------------------------
	-- Allow elves to be raised by stores --
	----------------------------------------

	if not IEex_Vanilla then
		IEex_WriteAssembly(0x67E7E2, {"!jmp_byte"})
	end

	---------------------------------------------------------------
	-- Fix the animation preview during chargen running too fast --
	---------------------------------------------------------------

	if not IEex_Vanilla then

		-- Disable sync-thread advancement of the animation
		IEex_WriteAssembly(0x61DE34, {"!jmp_byte"})

		-- Override CUIControlButtonChargenAnimationPreview::TimerAsynchronousUpdateOverride()
		-- to make it perform the animation advancement instead
		IEex_DisableRDataProtection()
		IEex_WriteDword(0x85CDF0, IEex_Label("IEex_Helper_CUIControlButtonChargenAnimationPreview_TimerAsynchronousUpdateOverride"))
		IEex_EnableRDataProtection()
	end

	-------------------------------------------------------------------
	-- Extend CScreenKeys (GUIKEYS.CHU) to allow for custom keybinds --
	-------------------------------------------------------------------

	if not IEex_Vanilla then
		IEex_WriteAssembly(0x597740, { "!jmp_dword >IEex_Helper_CInfCursor_SetToolTipOverride                 !repeat(2,!nop)" })
		IEex_WriteAssembly(0x5A98F0, { "!jmp_dword >IEex_Helper_CInfGame_InitHotkeyMapOverride                !repeat(2,!nop)" })
		IEex_WriteAssembly(0x5A9B00, { "!jmp_dword >IEex_Helper_CInfGame_UpdateKeybindMappingOverride                        " })
		IEex_WriteAssembly(0x639DC0, { "!jmp_dword >IEex_Helper_CScreenKeys_InitDueToUserInteractionOverride                 " })
		IEex_WriteAssembly(0x639160, { "!jmp_dword >IEex_Helper_CScreenKeys_OnKeyDownProcessOverride          !repeat(2,!nop)" })
		IEex_WriteAssembly(0x639790, { "!jmp_dword >IEex_Helper_CScreenKeys_OnLButtonDownOverride                            " })
		IEex_WriteAssembly(0x63A480, { "!jmp_dword >IEex_Helper_CScreenKeys_OnPanel1ButtonClickOverride       !repeat(2,!nop)" })
		IEex_WriteAssembly(0x63AA60, { "!jmp_dword >IEex_Helper_CScreenKeys_SetSelectedDisplayIndexOverride             !nop " })
		IEex_WriteAssembly(0x63A910, { "!jmp_dword >IEex_Helper_CScreenKeys_SetStagedKeybindOverride          !repeat(2,!nop)" })
		IEex_WriteAssembly(0x63A7A0, { "!jmp_dword >IEex_Helper_CScreenKeys_UpdateHoverPalettesOverride                      " })
		IEex_WriteAssembly(0x63A660, { "!jmp_dword >IEex_Helper_CScreenKeys_UpdateLabelPalettesOverride       !repeat(5,!nop)" })
		IEex_WriteAssembly(0x639A50, { "!jmp_dword >IEex_Helper_CScreenKeys_UpdateMainPanelOverride           !repeat(2,!nop)" })
		IEex_WriteAssembly(0x63ACA0, { "!jmp_dword >IEex_Helper_CUIControlButtonKeys_OnLButtonClickOverride             !nop " })
	end

	---------------------------------------------
	-- Allow spontaneous casting customization --
	---------------------------------------------

	if not IEex_Vanilla then

		IEex_HookReturnNOPs(0x5915F4, 15, IEex_FlattenTable({
			{[[
				!cmp_byte:[ebp+byte] 3A 00 ; m_bDisabled ;
				!jnz_dword :59162B

				!mark_esp
				!push_all_registers_iwd2
			]]},
			IEex_GenLuaCall("IEex_Extern_AttemptSpontaneousCast", {
				["args"] = {
					{"!marked_esp !push([esp+0x10])"}, -- sprite
					{"!push(ebp)"},                    -- buttonData
				},
				["returnType"] = IEex_LuaCallReturnType.Boolean,
			}),
			{[[
				!jmp_dword >no_error

				@call_error
				!xor_eax_eax

				@no_error
				!test_eax_eax
				!pop_all_registers_iwd2

				!jz_dword :59162B
			]]},
		}))

		-- Disable cleric-enforcing asserts
		IEex_WriteAssembly(0x7167BB, {"!jmp_byte"})
		IEex_WriteAssembly(0x7167D9, {"!jmp_byte"})

		IEex_HookReturnNOPs(0x716841, 24, IEex_FlattenTable({
			{[[
				!mark_esp
				!push(eax)
				!push(ecx)
				!push(edx)
				!push(esi)
				!push(edi)

				!push(-1) ; [esp-0x18] returnValues.row ;
				!push(-1) ; [esp-0x1C] returnValues.column ;
			]]},
			IEex_GenLuaCall("IEex_Extern_GetSpontaneousCastColumnAndRow", {
				["args"] = {
					{"!marked_esp !push([esp+0x14])"},               -- sprite
					{"!marked_esp !push([esp+0x90])"},               -- buttonData
					{"!marked_esp !lea(eax,[esp-0x1C]) !push(eax)"}, -- returnValues
				},
			}),
			{[[
				@call_error
				!marked_esp !mov(ebp,[esp-0x1C]) ; ebp holds the SPONCAST.2DA column ;
				!marked_esp !mov(ebx,[esp-0x18]) ; ebx holds the SPONCAST.2DA row ;

				!add(esp,8) !adjust_marked_esp(-8)
				!pop(edi)
				!pop(esi)
				!pop(edx)
				!pop(ecx)
				!pop(eax)
			]]},
		}))
	end

	-- [HD UI fonts] crisp 2x for the HD-repacked fonts. At 2x UI the engine doubles 1x font BAMs via
	-- CVidCell::m_bDoubleSize, passed as the bDoubleSize ARG to CResCell::GetFrame (dims x2) and
	-- CResCell::GetFrameData (NN pixel x2). We ship 2x-authored BAMs, so any doubling makes them 4x. The flag
	-- is read on MANY paths incl. GetResFrame INLINED (CUtil::SplitString) -> these two CResCell resource fns
	-- are the single convergence point all of them hit. Each: this=ecx=CResCell*; m_pDimmKeyTableEntry @+0x10,
	-- its resRef first dword @+0. If the resref matches an HD-repacked font, force the bDoubleSize stack ARG
	-- to 0 -> native (sharp 2x). NULL-guarded; resref-scoped so sprites/items/NON-repacked fonts keep doubling.
	-- Match the FULL 8-char resref (both dwords), NOT just the 4-char prefix: "STON" collides with 20+
	-- inventory stone graphics (STONARM/STONSLOT/STONWEAP/STONQUIV/...) and "TOOL" with TOOLTIP -- a prefix
	-- filter de-doubled those too and broke the inventory. Each font: if resref[0:4]==dword1 AND
	-- resref[4:8]==dword2 -> hit. dword2 = chars 5-8 LE (null-padded). Add a font here when its HD BAM ships.
	-- NORMAL "NORM"/"AL\0\0" · TOOLFONT "TOOL"/"FONT" · STONESML "STON"/"ESML" · INFOFONT "INFO"/"FONT"
	-- · NUMFONT "NUMF"/"ONT\0" (portrait HP numbers -- replaced the stock 1-bit bevel digits with a crisp
	-- silly_pixel BAM authored at final px, so it must de-double too, else the 1px outline renders 2px).
	-- · REALMS "REAL"/"MS\0\0" (uncial display/title face; HD BAM repacked from an auto-traced TTF of the
	-- stock REALMS glyphs -- potrace+FontForge, scripts/realms_trace.py + realms_build.py).
	-- · INITIALS "INIT"/"IALS" (ornate illuminated drop-caps; full-colour, so the HD BAM is a 2x Lanczos
	-- upscale of the stock colour frames repacked verbatim in the original palette, scripts/initials_upscale.py).
	-- See HD_UI_FONTS.md §1a/§7/§8.
	local hd_match =
		"!push(eax) !mov(eax,[ecx+0x10]) !test_eax_eax !jz_dword >skip "
		.. "!mov(eax,[eax]) !cmp_eax_dword #4D524F4E !jne_dword >c1 !mov(eax,[ecx+0x10]) !mov(eax,[eax+0x4]) !cmp_eax_dword #00004C41 !jz_dword >hit @c1 "
		.. "!mov(eax,[ecx+0x10]) !mov(eax,[eax]) !cmp_eax_dword #4C4F4F54 !jne_dword >c2 !mov(eax,[ecx+0x10]) !mov(eax,[eax+0x4]) !cmp_eax_dword #544E4F46 !jz_dword >hit @c2 "
		.. "!mov(eax,[ecx+0x10]) !mov(eax,[eax]) !cmp_eax_dword #4E4F5453 !jne_dword >c3 !mov(eax,[ecx+0x10]) !mov(eax,[eax+0x4]) !cmp_eax_dword #4C4D5345 !jz_dword >hit @c3 "
		.. "!mov(eax,[ecx+0x10]) !mov(eax,[eax]) !cmp_eax_dword #4F464E49 !jne_dword >c4 !mov(eax,[ecx+0x10]) !mov(eax,[eax+0x4]) !cmp_eax_dword #544E4F46 !jz_dword >hit @c4 "
		.. "!mov(eax,[ecx+0x10]) !mov(eax,[eax]) !cmp_eax_dword #464D554E !jne_dword >c5 !mov(eax,[ecx+0x10]) !mov(eax,[eax+0x4]) !cmp_eax_dword #00544E4F !jz_dword >hit @c5 "
		.. "!mov(eax,[ecx+0x10]) !mov(eax,[eax]) !cmp_eax_dword #4C414552 !jne_dword >c6 !mov(eax,[ecx+0x10]) !mov(eax,[eax+0x4]) !cmp_eax_dword #0000534D !jz_dword >hit @c6 "
		.. "!mov(eax,[ecx+0x10]) !mov(eax,[eax]) !cmp_eax_dword #54494E49 !jne_dword >c7 !mov(eax,[ecx+0x10]) !mov(eax,[eax+0x4]) !cmp_eax_dword #534C4149 !jz_dword >hit @c7 "
	-- [HD UI buttons] the SAME CResCell de-double, extended to the 49 UI button/graphic BAMs
	-- (action bar GUIBTACT, the GBTN* family, inventory/spell/store/options buttons, inn-room
	-- images) that draw via CUIControlButton -> CVidCell with m_bDoubleSize = manager->m_bDoubleSize.
	-- Each is AI-upscaled (Remacri) to 2x and de-doubled here by FULL 8-char resref (branches c8+).
	-- The 255-frame stone fonts (STONEBIG/STONESM3) + STATES2 status icons stay 1x. See §11.
	local btn_list = {
		{0x54554243, 0x00000000}, -- CBUT
		{0x41454743, 0x00000052}, -- CGEAR
		{0x4B494C43, 0x4E4F4332}, -- CLIK2CON
		{0x544E4F43, 0x4B434142}, -- CONTBACK
		{0x47414C46, 0x00000031}, -- FLAG1
		{0x4E544247, 0x4D524642}, -- GBTNBFRM
		{0x4E544247, 0x4B4E4C42}, -- GBTNBLNK
		{0x4E544247, 0x00004143}, -- GBTNCA
		{0x4E544247, 0x4E54424A}, -- GBTNJBTN
		{0x4E544247, 0x4B43494B}, -- GBTNKICK
		{0x4E544247, 0x0047524C}, -- GBTNLRG
		{0x4E544247, 0x3247524C}, -- GBTNLRG2
		{0x4E544247, 0x3347524C}, -- GBTNLRG3
		{0x4E544247, 0x0044454D}, -- GBTNMED
		{0x4E544247, 0x3244454D}, -- GBTNMED2
		{0x4E544247, 0x534E494D}, -- GBTNMINS
		{0x4E544247, 0x3154504F}, -- GBTNOPT1
		{0x4E544247, 0x3354504F}, -- GBTNOPT3
		{0x4E544247, 0x4D524550}, -- GBTNPERM
		{0x4E544247, 0x53554C50}, -- GBTNPLUS
		{0x4E544247, 0x00524F50}, -- GBTNPOR
		{0x4E544247, 0x42434552}, -- GBTNRECB
		{0x4E544247, 0x4C524353}, -- GBTNSCRL
		{0x4E544247, 0x31425053}, -- GBTNSPB1
		{0x4E544247, 0x32425053}, -- GBTNSPB2
		{0x4E544247, 0x33425053}, -- GBTNSPB3
		{0x4E544247, 0x00445453}, -- GBTNSTD
		{0x4E544247, 0x4E445055}, -- GBTNUPDN
		{0x4D4F4347, 0x4E54424D}, -- GCOMMBTN
		{0x4D4F4347, 0x0042534D}, -- GCOMMSB
		{0x42495547, 0x54434154}, -- GUIBTACT
		{0x42495547, 0x54554254}, -- GUIBTBUT
		{0x43495547, 0x004C5254}, -- GUICTRL
		{0x4D495547, 0x43575041}, -- GUIMAPWC
		{0x52495547, 0x524F5053}, -- GUIRSPOR
		{0x52495547, 0x524F505A}, -- GUIRZPOR
		{0x53495547, 0x0052444C}, -- GUISLDR
		{0x53495547, 0x43424254}, -- GUISTBBC
		{0x53495547, 0x43534D54}, -- GUISTMSC
		{0x42564E49, 0x00325455}, -- INVBUT2
		{0x42564E49, 0x00335455}, -- INVBUT3
		{0x4D4F4F52, 0x554C4544}, -- ROOMDELU
		{0x4D4F4F52, 0x4352454D}, -- ROOMMERC
		{0x4D4F4F52, 0x45424F4E}, -- ROOMNOBE
		{0x4D4F4F52, 0x53414550}, -- ROOMPEAS
		{0x424C5053, 0x00005455}, -- SPLBUT
		{0x4E4F5453, 0x544F4C53}, -- STONSLOT
		{0x524F5453, 0x52435345}, -- STORESCR
		{0x47474F54, 0x0000454C}, -- TOGGLE
		{0x424D554E, 0x00005245}, -- NUMBER (action-bar/item count digits; CIcon::RenderIcon, HD LycheeSoda)
		{0x4E4F5453, 0x47494245}, -- STONEBIG (inventory/record names + titles; HD Amood IV serif)
		{0x4E4F5453, 0x334D5345}, -- STONESM3 (stone small-caps; HD Amood IV caps)
	}
	for k, p in ipairs(btn_list) do
		local lbl = "c" .. (7 + k)
		hd_match = hd_match
			.. "!mov(eax,[ecx+0x10]) !mov(eax,[eax]) !cmp_eax_dword #" .. string.format("%08X", p[1])
			.. " !jne_dword >" .. lbl
			.. " !mov(eax,[ecx+0x10]) !mov(eax,[eax+0x4]) !cmp_eax_dword #" .. string.format("%08X", p[2])
			.. " !jz_dword >hit @" .. lbl .. " "
	end
	hd_match = hd_match .. "!jmp_dword >skip @hit "
	IEex_AttemptHook(0x77F520,  -- CResCell::GetFrame (metrics); bDoubleSize arg @[esp+0x0C] (->+0x10 after push)
		{hd_match .. "!mov([esp+10],0) @skip !pop(eax)"},
		{"8B 51 64 56 85 D2 !jmp_dword :77F526"}, {0x8B, 0x51, 0x64, 0x56, 0x85, 0xD2})
	IEex_AttemptHook(0x77F5F0,  -- CResCell::GetFrameData (pixels); bDoubleSize arg @[esp+0x08] (->+0x0C after push)
		{hd_match .. "!mov([esp+0C],0) @skip !pop(eax)"},
		{"83 EC 10 53 8B D9 !jmp_dword :77F5F6"}, {0x83, 0xEC, 0x10, 0x53, 0x8B, 0xD9})

	-- === Tooltip box 2x (so the HD TOOLFONT actually fits) ===
	-- The cursor/tooltip layer (CInfCursor/CInfToolTip) is SEPARATE from CUIManager's
	-- m_bUseNewGui 2x path: CInfCursor::Initialize sets the TOOLTIP box AND TOOLFONT with
	-- bDoubleSize=FALSE, and CInfToolTip::Initialize @0x597F39 hardcodes field_5E4=256 (the
	-- 1x text-wrap budget). So tooltips always rendered 1x -- fine until the HD TOOLFONT BAM
	-- made the glyphs 2x: the still-1x box (too short) + 256 budget (too narrow) then
	-- clipped/truncated the text. Fix: at that same store, when m_bUseNewGui is set, force
	-- the box CVidCell m_bDoubleSize=TRUE (this+0xD6, BOOL -> engine doubles the TOOLTIP
	-- panel to 2x) and write field_5E4=512 (2x budget); otherwise keep vanilla 256/undoubled.
	-- Gated on m_bUseNewGui (g_pBaldurChitin+0x4A28) so the 1x UI is untouched. TOOLTIP is
	-- NOT de-doubled by the hook above ("TOOL"+"TIP\0" != "TOOL"+"FONT"), so it doubles here.
	-- esi=this at 0x597F39; eax saved/restored; we own the field_5E4 write (orig not re-run).
	-- See HD_UI_FONTS.md §8.
	IEex_AttemptHook(0x597F39,
		{"!push(eax) !mov_eax_[dword] #8CF6DC !test_eax_eax !jz_dword >van "
		.. "0F B6 80 28 4A 00 00 !test_eax_eax !jz_dword >van "
		.. "C7 86 D6 00 00 00 01 00 00 00 "
		.. "66 C7 86 E4 05 00 00 00 02 !jmp_dword >done "
		.. "@van 66 C7 86 E4 05 00 00 00 01 "
		.. "@done !pop(eax)"},
		{"!jmp_dword :597F42"},
		{0x66, 0xC7, 0x86, 0xE4, 0x05, 0x00, 0x00, 0x00, 0x01})

	-- === HD UI mosaics (MOS) de-double -- crisp upscaled panels instead of NN-doubled ===
	-- CResMosaic is the MOS twin of CResCell: GetMosaicWidth/Height/TileSize(bDoubleSize)
	-- return 2x the header dim, GetTileData(nTile,bDoubleSize) NN-expands each pixel to a 2x2
	-- block. Under m_bUseNewGui the panel MOS double -> blocky. Ship a 2x-authored (Lanczos/AI
	-- upscaled) MOS and force bDoubleSize=0 for its resref in all FOUR fns -> renders native =
	-- crisp 2x. Resref via m_pDimmKeyTableEntry @[this+0x10] (same as the font de-double).
	-- bDoubleSize: @[esp+4] in the 3 size fns (->+8 after push eax), @[esp+8] in GetTileData
	-- (->+0xC). Every UI panel MOS (height>=90, width>=250) is AI-upscaled (Remacri) to 2x and
	-- shipped; each entry below is its resref's two LE dwords (chars 0-3, 4-7). Match ANY -> force
	-- bDoubleSize=0 (renders native = crisp 2x). The thin fill/bar strips (<90px tall) stay
	-- NN-doubled (imperceptible, no detail to recover). Add a MOS here as its HD .MOS ships.
	local mos_list = {
		{0x41495547, 0x00004242}, -- GUIABB
		{0x41495547, 0x00004250}, -- GUIAPB
		{0x41495547, 0x00324250}, -- GUIAPB2
		{0x42495547, 0x0048414C}, -- GUIBLAH
		{0x43495547, 0x42425241}, -- GUICARBB
		{0x43495547, 0x00505845}, -- GUICEXP
		{0x43495547, 0x00004247}, -- GUICGB
		{0x43495547, 0x42534948}, -- GUICHISB
		{0x43495547, 0x42305048}, -- GUICHP0B
		{0x43495547, 0x42315048}, -- GUICHP1B
		{0x43495547, 0x42325048}, -- GUICHP2B
		{0x43495547, 0x42335048}, -- GUICHP3B
		{0x43495547, 0x42345048}, -- GUICHP4B
		{0x43495547, 0x42355048}, -- GUICHP5B
		{0x43495547, 0x42365048}, -- GUICHP6B
		{0x43495547, 0x0054534C}, -- GUICLST
		{0x43495547, 0x454D414E}, -- GUICNAME
		{0x43495547, 0x42524F50}, -- GUICPORB
		{0x43495547, 0x45434152}, -- GUICRACE
		{0x43495547, 0x42545355}, -- GUICUSTB
		{0x44495547, 0x424C4343}, -- GUIDCCLB
		{0x45495547, 0x42305252}, -- GUIERR0B
		{0x45495547, 0x42315252}, -- GUIERR1B
		{0x45495547, 0x42325252}, -- GUIERR2B
		{0x45495547, 0x42335252}, -- GUIERR3B
		{0x45495547, 0x42345252}, -- GUIERR4B
		{0x46495547, 0x00544145}, -- GUIFEAT
		{0x46495547, 0x32544145}, -- GUIFEAT2
		{0x47495547, 0x50595441}, -- GUIGATYP
		{0x47495547, 0x00004244}, -- GUIGDB
		{0x48495547, 0x00504C45}, -- GUIHELP
		{0x48495547, 0x00004253}, -- GUIHSB
		{0x49495547, 0x3830564E}, -- GUIINV08
		{0x49495547, 0x4241564E}, -- GUIINVAB
		{0x49495547, 0x4252564E}, -- GUIINVRB
		{0x4A495547, 0x004C4E52}, -- GUIJRNL
		{0x4C495547, 0x00425055}, -- GUILUPB
		{0x4D495547, 0x42415041}, -- GUIMAPAB
		{0x4D495547, 0x4D475041}, -- GUIMAPGM
		{0x4D495547, 0x42575041}, -- GUIMAPWB
		{0x4D495547, 0x43575041}, -- GUIMAPWC
		{0x4D495547, 0x0042564F}, -- GUIMOVB
		{0x52495547, 0x38304345}, -- GUIREC08
		{0x52495547, 0x004E4547}, -- GUIRGEN
		{0x52495547, 0x314C564C}, -- GUIRLVL1
		{0x52495547, 0x324C564C}, -- GUIRLVL2
		{0x52495547, 0x334C564C}, -- GUIRLVL3
		{0x52495547, 0x344C564C}, -- GUIRLVL4
		{0x52495547, 0x354C564C}, -- GUIRLVL5
		{0x52495547, 0x364C564C}, -- GUIRLVL6
		{0x52495547, 0x374C564C}, -- GUIRLVL7
		{0x53495547, 0x00005845}, -- GUISEX
		{0x53495547, 0x38304C50}, -- GUISPL08
		{0x53495547, 0x00324C50}, -- GUISPL2
		{0x53495547, 0x42484C50}, -- GUISPLHB
		{0x53495547, 0x42515252}, -- GUISRRQB
		{0x53495547, 0x42565352}, -- GUISRSVB
		{0x53495547, 0x53544154}, -- GUISTATS
		{0x53495547, 0x42424254}, -- GUISTBBB
		{0x53495547, 0x42534254}, -- GUISTBSB
		{0x53495547, 0x42524454}, -- GUISTDRB
		{0x53495547, 0x42444954}, -- GUISTIDB
		{0x53495547, 0x42504D54}, -- GUISTMPB
		{0x53495547, 0x424F5254}, -- GUISTROB
		{0x56495547, 0x00425245}, -- GUIVERB
	}
	local mos_match = "!push(eax) !mov(eax,[ecx+0x10]) !test_eax_eax !jz_dword >skip "
	for k, p in ipairs(mos_list) do
		mos_match = mos_match
			.. "!mov(eax,[ecx+0x10]) !mov(eax,[eax]) !cmp_eax_dword #" .. string.format("%08X", p[1])
			.. " !jne_dword >m" .. k
			.. " !mov(eax,[ecx+0x10]) !mov(eax,[eax+0x4]) !cmp_eax_dword #" .. string.format("%08X", p[2])
			.. " !jz_dword >hit @m" .. k .. " "
	end
	mos_match = mos_match .. "!jmp_dword >skip @hit "
	IEex_AttemptHook(0x780310,  -- CResMosaic::GetMosaicWidth
		{mos_match .. "!mov([esp+8],0) @skip !pop(eax)"},
		{"8B 44 24 04 85 C0 !jmp_dword :780316"}, {0x8B, 0x44, 0x24, 0x04, 0x85, 0xC0})
	IEex_AttemptHook(0x780340,  -- CResMosaic::GetMosaicHeight
		{mos_match .. "!mov([esp+8],0) @skip !pop(eax)"},
		{"8B 44 24 04 85 C0 !jmp_dword :780346"}, {0x8B, 0x44, 0x24, 0x04, 0x85, 0xC0})
	IEex_AttemptHook(0x780370,  -- CResMosaic::GetTileSize
		{mos_match .. "!mov([esp+8],0) @skip !pop(eax)"},
		{"8B 44 24 04 85 C0 !jmp_dword :780376"}, {0x8B, 0x44, 0x24, 0x04, 0x85, 0xC0})
	IEex_AttemptHook(0x7803A0,  -- CResMosaic::GetTileData
		{mos_match .. "!mov([esp+0C],0) @skip !pop(eax)"},
		{"83 EC 08 33 D2 53 !jmp_dword :7803A6"}, {0x83, 0xEC, 0x08, 0x33, 0xD2, 0x53})

	-- === HD UI portraits (BMP) de-double -- crisp upscaled character art instead of NN-doubled ===
	-- Portrait controls blit via CVidBitmap with m_bDoubleSize = manager->m_bDoubleSize
	-- (CUIControlFactory), so under the 2x UI the stock 210x330 _L / 42x42 _S portrait BMP get
	-- NN-doubled (blocky). Ship an AI-upscaled (RealESRGAN x4) 420x660 _L + 84x84 _S (face crop)
	-- and force bDoubleSize=0 in CResBitmap::GetImageData (0x77ECF0) + GetImageDimensions
	-- (0x77EF70) when the native dims are our HD sizes -> renders native = crisp 2x. BOTH fns
	-- must agree (the control sizes the blit rect from GetImageDimensions, reads pixels from
	-- GetImageData). Gate on DIMS not resref: no stock BMP is 420x660 or 84x84 (verified scan),
	-- so this also covers custom party portraits authored at HD. CResBitmap layout:
	-- bParsed @[this+0x58]; pBitmapInfoHeader @[this+0x64]; biWidth @[+4]; biHeight @[+8].
	local bmp_match =
		"!push(eax) !mov(eax,[ecx+0x58]) !test_eax_eax !jz_dword >skip "          -- not parsed -> leave
		.. "!mov(eax,[ecx+0x64]) !test_eax_eax !jz_dword >skip "                  -- null BITMAPINFOHEADER guard
		.. "!mov(eax,[eax+0x4]) !cmp_eax_dword #000001A4 !jne_dword >c84 "        -- biWidth==420?
		.. "!mov(eax,[ecx+0x64]) !mov(eax,[eax+0x8]) !cmp_eax_dword #00000294 !jz_dword >hit " -- biHeight==660 -> HD _L
		.. "@c84 !mov(eax,[ecx+0x64]) !mov(eax,[eax+0x4]) !cmp_eax_dword #00000054 !jne_dword >skip " -- biWidth==84?
		.. "!mov(eax,[ecx+0x64]) !mov(eax,[eax+0x8]) !cmp_eax_dword #00000054 !jne_dword >skip "       -- biHeight==84 -> HD _S
		.. "@hit "
	IEex_AttemptHook(0x77ECF0,  -- CResBitmap::GetImageData; bDoubleSize @[esp+4] (->+8 after push eax)
		{bmp_match .. "!mov([esp+8],0) @skip !pop(eax)"},
		{"83 EC 14 53 56 !jmp_dword :77ECF5"}, {0x83, 0xEC, 0x14, 0x53, 0x56})
	IEex_AttemptHook(0x77EF70,  -- CResBitmap::GetImageDimensions; bDoubleSize @[esp+8] (->+0xC after push eax)
		{bmp_match .. "!mov([esp+0C],0) @skip !pop(eax)"},
		{"8B 41 58 85 C0 !jmp_dword :77EF75"}, {0x8B, 0x41, 0x58, 0x85, 0xC0})

	IEex_EnableCodeProtection()

end)()
