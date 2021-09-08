
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
		!jnz_dword ]], {IEex_GetProcAddress("IEexHelper", "RenderFoWSolid"), 4, 4},
	})

	-- Install new transparent FoW rendering
	IEex_HookBeforeCall(0x477B61, {[[
		!call ]], {getFogTypePtr, 4, 4}, [[
		!cmp_[eax]_byte 00
		!jz_dword >no_hook
		!push_ecx
		!push_esi
		!call ]], {IEex_GetProcAddress("IEexHelper", "RenderFoW"), 4, 4}, [[
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

	IEex_EnableCodeProtection()

end)()
