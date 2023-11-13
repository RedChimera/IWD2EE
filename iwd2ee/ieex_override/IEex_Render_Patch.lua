
(function()

	IEex_DisableCodeProtection()

	--------------------------------------------------------------------------
	-- wined3d.dll + WINEDEBUG environment variable should log debug output --
	--------------------------------------------------------------------------

	IEex_HookAfterCall(0x7952FB, IEex_FlattenTable({[[
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_AfterDirectDrawCreate"), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))

	----------------------------------
	-- Transparent Fog of War Hooks --
	----------------------------------

	local optionsStr = IEex_WriteStringAuto("IEex_Options")

	local getFogTypePtr = IEex_WriteAssemblyAuto({[[
		!push_ecx
		!push_edx
		!push_dword ]], {optionsStr, 4}, [[
		!call >IEex_Helper_LockGlobal
		!push_[dword] ]], {IEex_FogTypePtr, 4}, [[
		!push_dword ]], {optionsStr, 4}, [[
		!call >IEex_Helper_UnlockGlobal
		!pop_eax
		!pop_edx
		!pop_ecx
		!ret
	]]})

	-- Install new solid FoW rendering
	IEex_HookRestore(0x551FF0, 0, 5, {[[
		!call ]], {getFogTypePtr, 4, 4}, [[
		!cmp_[eax]_byte 00
		!jnz_dword >IEex_Helper_RenderFoWSolid
	]]})

	-- Install new transparent FoW rendering
	IEex_HookBeforeCall(0x477B61, {[[
		!call ]], {getFogTypePtr, 4, 4}, [[
		!cmp_[eax]_byte 00
		!jz_dword >no_hook
		!push_ecx
		!push_esi
		!call >IEex_Helper_RenderFoW
		!pop_ecx
		@no_hook
	]]})

	-- Toggle common FoW interlacing for sprites
	local spriteInterlaceHook = IEex_WriteAssemblyAuto({[[
		!mark_esp
		!push(eax)
		!call ]], {getFogTypePtr, 4, 4}, [[
		!cmp_[eax]_byte 00
		!jz_dword >no_hook
		!marked_esp !mov([esp+2C],0)
		@no_hook
		!pop(eax)
		!ret
	]]})

	for _, address in ipairs({0x56ECD3, 0x61DF8F, 0x62ED48, 0x7040AA, 0x704235, 0x70F4D9, 0x70FCDB, 0x710539}) do
		IEex_HookRestore(address, 0, 6, {"!call", {spriteInterlaceHook, 4, 4}})
	end

	-- Toggle FoW interlacing for ground piles
	IEex_HookJump(0x47FA0D, 4, {[[
		!call ]], {getFogTypePtr, 4, 4}, [[
		!cmp_[eax]_byte 00
		!jnz_dword >jmp_success
		!mov_al_[esp+byte] 12
		!test_al_al
	]]})

	--------------------------------------------------------------
	-- Don't crash when attempting to dither a sprite           --
	-- effect on a creature with a large posZ                   --
	-- (engine failed to calculate rClip correctly, subtracting --
	--  posZ out of rClip.bottom when it should keep it)        --
	--------------------------------------------------------------

	IEex_WriteAssembly(0x709AA7, {"!repeat(3,!nop)"})

	-----------------------------------------------------------------------------------------
	-- Disable engine's default windowed mode under cnc-ddraw. When the engine attempts to --
	-- toggle the window mode, send cnc-ddraw the correct WindowProc message and suppress  --
	-- the default toggle behavior.                                                        --
	-----------------------------------------------------------------------------------------

		-----------------------------------------------------------------
		-- Detect cnc-ddraw and force fullscreen mode if it is present --
		-----------------------------------------------------------------

		IEex_HookReturnNOPs(0x422092, 3, IEex_FlattenTable({
			{[[
				!push_registers_iwd2
			]]},
			IEex_GenLuaCall("IEex_Extern_CheckForceFullscreen", {
				["returnType"] = IEex_LuaCallReturnType.Boolean,
			}),
			{[[
				!jmp_dword >no_error

				@call_error
				!xor(eax,eax)

				@no_error
				!pop_registers_iwd2
				!test(eax,eax)
				!jz_dword >do_call

				!add(esp,10)
				!jmp_dword >skip_call

				@do_call
				!call_ebp

				@skip_call
				!mov_byte:[esi+dword]_al #E1
			]]},
		}))

		----------------------------------------------------------------------
		-- Suppress the default window mode toggle behavior under cnc-ddraw --
		-- and send cnc-ddraw the correct WindowProc message                --
		----------------------------------------------------------------------

		IEex_HookRestore(0x7912F0, 0, 6, IEex_FlattenTable({
			{[[
				!push_registers_iwd2
			]]},
			IEex_GenLuaCall("IEex_Extern_CheckSuppressToggleFullscreen", {
				["returnType"] = IEex_LuaCallReturnType.Boolean,
			}),
			{[[
				!jmp_dword >no_error

				@call_error
				!xor(eax,eax)

				@no_error
				!pop_registers_iwd2
				!test(eax,eax)
				!jz_dword >return

				!ret_word 04 00
			]]},
		}))

		----------------------------------------------------------------------------
		-- Make the options screen report the correct window mode under cnc-ddraw --
		----------------------------------------------------------------------------

		IEex_HookBeforeCall(0x655E95, IEex_FlattenTable({
			{[[
				!push_registers_iwd2
			]]},
			IEex_GenLuaCall("IEex_Extern_CheckOverrideOptionsScreenThinksGameIsFullScreen", {
				["returnType"] = IEex_LuaCallReturnType.Number,
			}),
			{[[
				!jmp_dword >no_error

				@call_error
				!mov(eax,-1)

				@no_error
				!pop_registers_iwd2
				!cmp(eax,-1)
				!je_dword >call

				!mov([esp],eax)
			]]},
		}))

		IEex_HookReturnNOPs(0x6558E2, 3, IEex_FlattenTable({
			{[[
				!push(eax)
				!push(ebx)
				!push(edx)
				!push(ebp)
				!push(esi)
				!push(edi)
			]]},
			IEex_GenLuaCall("IEex_Extern_CheckOverrideOptionsScreenThinksGameIsFullScreen", {
				["returnType"] = IEex_LuaCallReturnType.Number,
			}),
			{[[
				!jmp_dword >no_error

				@call_error
				!mov(eax,-1)

				@no_error
				!cmp(eax,-1)
				!je_dword >continue_normally

				!xor(ecx,ecx)
				!mov_cl_al
				!jmp_dword >continue

				@continue_normally
				!xor(ecx,ecx)
				!mov_cl_byte:[edx+dword] #E1

				@continue
				!pop(edi)
				!pop(esi)
				!pop(ebp)
				!pop(edx)
				!pop(ebx)
				!pop(eax)
			]]},
		}))

		--------------------------------------------------------------------------------------
		-- Force the options screen to request windowed mode when it attempts to toggle the --
		-- mode under cnc-ddraw. Since the engine permanently thinks it is in fullscreen    --
		-- mode under cnc-ddraw, in order to trigger the toggle behavior the engine must    --
		-- attempt to enter windowed mode.                                                  --
		--------------------------------------------------------------------------------------

		IEex_HookRestore(0x6558FD, 0, 6, IEex_FlattenTable({
			{[[
				!push_all_registers_iwd2
			]]},
			IEex_GenLuaCall("IEex_Extern_CheckForceOptionsScreenToRequestWindowedMode", {
				["returnType"] = IEex_LuaCallReturnType.Boolean,
			}),
			{[[
				!jmp_dword >no_error

				@call_error
				!xor(eax,eax)

				@no_error
				!test(eax,eax)
				!pop_all_registers_iwd2
				!jz_dword >return

				!mov_al 00
			]]},
		}))


	IEex_EnableCodeProtection()

end)()
