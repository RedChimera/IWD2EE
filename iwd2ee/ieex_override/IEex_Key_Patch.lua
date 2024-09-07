
(function()

	--------------------------------------
	-- Define Assembly-to-Lua Functions --
	--------------------------------------

	-------------------------
	-- IEex_GetCursorPos() --
	-------------------------

	IEex_WriteAssemblyFunction("IEex_GetCursorPos", {[[

		$IEex_GetCursorPosLua
		!sub(esp,8)
		!push(esp)
		!call >IEex_GetCursorPos

		; x ;
		!push([esp])
		!fild_[esp]
		!sub(esp,4)
		!fstp_qword:[esp]
		!push([esp+14])
		!call >_lua_pushnumber
		!add(esp,C)

		; y ;
		!push([esp+4])
		!fild_[esp]
		!sub(esp,4)
		!fstp_qword:[esp]
		!push([esp+14])
		!call >_lua_pushnumber
		!add(esp,C)

		!mov(eax,2)
		!add(esp,8)
		!ret
	]]})

	---------------------------
	-- IEex_ClientToScreen() --
	---------------------------

	IEex_WriteAssemblyFunction("IEex_ClientToScreen", {[[

		$IEex_ClientToScreenLua
		!build_stack_frame

		; in x ;
		!push(2)
		!push([ebp+8])
		!call >_lua_tonumber
		!add(esp,8)
		!call >__ftol2_sse
		!push(eax)

		; in y ;
		!push(1)
		!push([ebp+8])
		!call >_lua_tonumber
		!add(esp,8)
		!call >__ftol2_sse
		!push(eax)

		!push(esp)
		!mov(eax,[8CF6DC])
		!push([eax+94])
		!call_[dword] #847478 ; ClientToScreen ;

		; out x ;
		!push([esp])
		!fild_[esp]
		!sub(esp,4)
		!fstp_qword:[esp]
		!push([ebp+8])
		!call >_lua_pushnumber
		!add(esp,C)

		; out y ;
		!push([esp+4])
		!fild_[esp]
		!sub(esp,4)
		!fstp_qword:[esp]
		!push([ebp+8])
		!call >_lua_pushnumber
		!add(esp,C)

		!mov(eax,2)
		!destroy_stack_frame
		!ret
	]]})

	---------------------------
	-- IEex_ScreenToClient() --
	---------------------------

	IEex_WriteAssemblyFunction("IEex_ScreenToClient", {[[

		$IEex_ScreenToClientLua
		!build_stack_frame

		; in x ;
		!push(2)
		!push([ebp+8])
		!call >_lua_tonumber
		!add(esp,8)
		!call >__ftol2_sse
		!push(eax)

		; in y ;
		!push(1)
		!push([ebp+8])
		!call >_lua_tonumber
		!add(esp,8)
		!call >__ftol2_sse
		!push(eax)

		!push(esp)
		!mov(eax,[8CF6DC])
		!push([eax+94])
		!call_[dword] #847470 ; ScreenToClient ;

		; out x ;
		!push([esp])
		!fild_[esp]
		!sub(esp,4)
		!fstp_qword:[esp]
		!push([ebp+8])
		!call >_lua_pushnumber
		!add(esp,C)

		; out y ;
		!push([esp+4])
		!fild_[esp]
		!sub(esp,4)
		!fstp_qword:[esp]
		!push([ebp+8])
		!call >_lua_pushnumber
		!add(esp,C)

		!mov(eax,2)
		!destroy_stack_frame
		!ret
	]]})

	-------------------
	-- Write Patches --
	-------------------

	IEex_DisableCodeProtection()

	----------------------------------------------------------------
	-- Hook that runs directly before the engine checks for input --
	----------------------------------------------------------------

	if not IEex_Vanilla then
		IEex_HookBeforeCall(0x78F112, IEex_FlattenTable({
			{[[
				!push(ecx)
			]]},
			IEex_GenLuaCall("IEex_Extern_BeforeCheckKeys"),
			{[[
				@call_error
				!pop(ecx)
			]]},
		}))
	end

	---------------------------------------------------------------
	-- Hook that runs directly after the engine checks for input --
	---------------------------------------------------------------

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

	---------------------------------------------------
	-- Enable window-edge scrolling in windowed mode --
	---------------------------------------------------

	IEex_WriteAssembly(0x78F43F, {"!jmp_byte"})

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
	-- value when a key has been pressed since the last poll. This allows a process to  --
	-- detect whether it missed a keydown event. However, this behavior is unreliable,  --
	-- as the "since last poll" mechanism is OS-wide, which allows another process on   --
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

	----------------------------------------------------
	-- Potentially fake the cursor position for debug --
	----------------------------------------------------

	if not IEex_Vanilla then
		IEex_WriteAssembly(0x45F6F8, {"!call >IEex_GetCursorPos !nop"})
		IEex_WriteAssembly(0x78F2B3, {"!call >IEex_GetCursorPos !nop"})
	end

	--------------------------------------------------------------
	-- Allow hardcoded worldscreen keybindings to be suppressed --
	--------------------------------------------------------------

	IEex_HookRestore(0x687829, 0, 7, IEex_FlattenTable({
		{[[
			!push_all_registers_iwd2
		]]},
		IEex_GenLuaCall("IEex_Extern_OnBeforeWorldScreenCheckingHardcodedKeybinding", {
			["args"] = {
				{[[
					!xor(eax,eax)
					!mov_al_byte:[edi]
					!push(eax)
				]]},
			},
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}),
		{[[
			@call_error
			!test(eax,eax)
			!pop_all_registers_iwd2
			!jnz_dword :689504
		]]},
	}))


	IEex_EnableCodeProtection()

end)()
