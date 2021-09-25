
(function()

	IEex_DisableCodeProtection()

	--------------------------------------------------------------------
	-- Fix crash involving sound system not properly clearing invalid --
	-- sounds from various internal lists when they are destructed    --
	--------------------------------------------------------------------

	IEex_HookRestore(0x7A8E20, 0, 7, {[[
		!push_all_registers_iwd2
		!push(ecx)
		!call ]], {IEex_GetProcAddress("IEexHelper", "CSoundImp_Destruct"), 4, 4}, [[
		!pop_all_registers_iwd2
	]]})

	IEex_EnableCodeProtection()

end)()
