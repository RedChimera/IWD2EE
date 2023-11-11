
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
		!call >IEex_Helper_WindowProcHook
		!push_esi
	]]})

	-----------------------------------------------------------------------------------
	-- Viewport should be able to scroll out of bounds to expose world under the GUI --
	-----------------------------------------------------------------------------------

	IEex_HookReturnNOPs(0x5D129E, 9, IEex_FlattenTable({[[
		!push_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_EnforceViewportBottomBound", {
			["args"] = {
				{"!push(esi)"},
				{"!push(eax)"},
			},
			["returnType"] = IEex_LuaCallReturnType.Number,
		}), [[
		@call_error
		!pop_registers_iwd2
		!jmp_dword :5D12C0
	]]}))

	IEex_HookJumpAutoFail(0x47742B, 6, IEex_FlattenTable({[[
		!mark_esp
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_AllowMouseScrollDown", {
			["args"] = {
				{"!push(esi)"},
				{"!marked_esp !push([esp+20])"},
			},
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}), [[
		@call_error
		!test_eax_eax
		!pop_all_registers_iwd2
		!jnz_dword >jmp_success
	]]}))

	IEex_HookJumpAutoFail(0x46E72A, 6, IEex_FlattenTable({[[
		!mark_esp
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_AllowMouseScrollDown", {
			["args"] = {
				{"!push(esi)"},
				{"!marked_esp !push([esp+14])"},
			},
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}), [[
		@call_error
		!test_eax_eax
		!pop_all_registers_iwd2
		!jnz_dword >jmp_success
	]]}))

	-----------------------------------------------------------------
	-- Viewport should auto-scroll to center of main viewport rect --
	-----------------------------------------------------------------

	IEex_HookRestore(0x68D328, 0, 6, IEex_FlattenTable({[[
		!push(ebx)
		]], IEex_GenLuaCall("IEex_Extern_AdjustAutoScrollY", {
			["args"] = {
				{"!push(ebp)"},
			},
			["returnType"] = IEex_LuaCallReturnType.Number,
		}), [[
		@call_error
		!mov(ebp,eax)
		!pop(ebx)
	]]}))

	IEex_HookRestore(0x68C389, 0, 6, IEex_FlattenTable({[[
		!push(ebx)
		]], IEex_GenLuaCall("IEex_Extern_AdjustAutoScrollY", {
			["args"] = {
				{"!push(eax)"},
			},
			["returnType"] = IEex_LuaCallReturnType.Number,
		}), [[
		@call_error
		!pop(ebx)
	]]}))

	IEex_Extern_MoveViewUntilDone_Stuck = IEex_Malloc(0x4)
	IEex_WriteDword(IEex_Extern_MoveViewUntilDone_Stuck, 0)

	IEex_HookJumpToAutoReturn(0x5CF0CD, IEex_FlattenTable({[[
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_AutoScroll", {
			["args"] = {
				{"!push(ecx)"},
				{"!push([esp+24])"},
				{"!push([esp+24])"},
				{"!movzx_eax_word:[esp+byte] 24 !push(eax)"},
			},
		}), [[
		@call_error
		!pop_all_registers_iwd2
		!add(esp,C)
	]]}))

	IEex_HookBeforeCall(0x45F39A, {[[
		!mov_[dword]_dword ]], {IEex_Extern_MoveViewUntilDone_Stuck, 4}, [[ #0
	]]})

	IEex_HookRestore(0x45F46B, 0, 6, {[[
		!cmp_[dword]_byte ]], {IEex_Extern_MoveViewUntilDone_Stuck, 4}, [[ 00
		!jnz_dword :45F45F
	]]})

	--------------------------------------------------------------------------------------
	-- Replace all GetAsyncKeyState() calls with a Raw Input implementation that fakes  --
	-- GetAsyncKeyState()'s behavior. GetAsyncKeyState() sets the low bit of its return --
	-- value when a key has been pressed since the last poll. This allows programs to   --
	-- detect whether it missed a keydown event. However, this behavior is unreliable,  --
	-- as the "since last poll" mechanism is OS-wide, which allows another program on   --
	-- the system to consume a keypress before the engine can read it.                  --
	--------------------------------------------------------------------------------------

		---------------------------------------------------------------------------------
		-- Create a hidden window on a separate thread that accepts Raw Input messages --
		---------------------------------------------------------------------------------

		-- CChitin_CreateWindow
		IEex_HookRestore(0x791291, 0, 6, {[[
			!push(ebx) ; hWnd ;
			!call >IEex_Helper_RegisterRawInput
		]]})

		-------------------------------------------
		-- Redirect all GetAsyncKeyState() calls --
		-------------------------------------------

		-- CScreenConnection_TimerAsynchronousUpdate
		IEex_HookRestore(0x5FB53D, 2, 3, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})

		-- CChitin_AsynchronousUpdate
		IEex_HookRestore(0x78F538, 2, 6, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})
		IEex_HookRestore(0x78F55F, 2, 6, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})
		IEex_HookRestore(0x78F587, 2, 6, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})
		IEex_HookRestore(0x78F620, 2, 3, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})
		IEex_HookRestore(0x78F7E5, 2, 3, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})
		IEex_HookRestore(0x78F9B7, 2, 3, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})
		IEex_HookReturnNOPs(0x78FBC3, 1, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})

		-- CChitin_B3AUTO_00790570
		IEex_HookRestore(0x790585, 2, 3, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})
		IEex_HookRestore(0x790591, 2, 3, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})
		IEex_HookRestore(0x79059B, 2, 6, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})
		IEex_HookRestore(0x7905D5, 2, 3, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})

		-- CChitin_SelectEngine
		IEex_HookRestore(0x7908EF, 2, 3, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})
		IEex_HookRestore(0x7908FB, 2, 3, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})
		IEex_HookRestore(0x790905, 2, 4, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})
		IEex_HookRestore(0x79093C, 2, 3, {"!call >IEex_Helper_GetAsyncKeyStateWrapper"})

		--------------------------------------------------------------------
		-- Unused: Patches the engine's message pump to maintain WM_INPUT --
		--------------------------------------------------------------------

		if false then

			IEex_HookReturnNOPs(0x792801, 35, {[[

				!mark_esp

				@loop_process_messages_before_WM_INPUT

				!push(1)                       ; PM_REMOVE    | UINT wRemoveMsg    ;
				!push(FE)                      ; WM_INPUT - 1 | UINT wMsgFilterMax ;
				!push(0)                       ;              | UINT wMsgFilterMin ;
				!push(0)                       ;              | HWND hWnd          ;
				!marked_esp !lea(edx,[esp+10])
				!push(edx)                     ;              | LPMSG lpMsg        ;
				!call_[dword] #847434          ;              | PeekMessageA()     ;
				!adjust_marked_esp(-14)

				!test(eax,eax)
				!jz_dword >loop_process_messages_after_WM_INPUT

				!marked_esp !lea(edx,[esp+10])
				!cmp([edx+4],12)               ; WM_QUIT      |                    ;
				!je_dword :79285B

				@not_WM_INPUT
				!push(edx)                     ;              | const MSG *lpMsg   ;
				!call_[dword] #84743C          ;              | TranslateMessage() ;
				!adjust_marked_esp(-4)

				!marked_esp !lea(edx,[esp+10])
				!push(edx)                     ;              | const MSG *lpMsg   ;
				!call_[dword] #847440          ;              | DispatchMessageA() ;
				!adjust_marked_esp(-4)

				!jmp_dword >loop_process_messages_before_WM_INPUT

				@loop_process_messages_after_WM_INPUT

				!push(1)                       ; PM_REMOVE,   | UINT wRemoveMsg    ;
				!push(-1)                      ; -1 (max)     | UINT wMsgFilterMax ;
				!push(100)                     ; WM_INPUT + 1 | UINT wMsgFilterMin ;
				!push(0)                       ;              | HWND hWnd          ;
				!marked_esp !lea(edx,[esp+10])
				!push(edx)                     ;              | LPMSG lpMsg        ;
				!call_[dword] #847434          ;              | PeekMessageA()     ;
				!adjust_marked_esp(-14)

				!test(eax,eax)
				!jz_dword >done

				!marked_esp !lea(edx,[esp+10])
				!push(edx)                     ;              | const MSG *lpMsg   ;
				!call_[dword] #84743C          ;              | TranslateMessage() ;
				!adjust_marked_esp(-4)

				!marked_esp !lea(edx,[esp+10])
				!push(edx)                     ;              | const MSG *lpMsg   ;
				!call_[dword] #847440          ;              | DispatchMessageA() ;
				!adjust_marked_esp(-4)

				!jmp_dword >loop_process_messages_after_WM_INPUT

				@done
				!jmp_dword :79282B ; Ensure a sync tick per message loop, else the engine
					               ; might end up processing messages forever
			]]})
		end


	IEex_EnableCodeProtection()

end)()
