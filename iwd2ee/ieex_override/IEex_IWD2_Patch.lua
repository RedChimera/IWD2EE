
IEex_InSyncState = true
IEex_Debug_Stutter = false

(function()

	dofile("override/IEex_Core_Patch.lua")
	dofile("override/IEex_Creature_Patch.lua")
	dofile("override/IEex_Opcode_Patch.lua")
	dofile("override/IEex_Gui_Patch.lua")
	dofile("override/IEex_Key_Patch.lua")

	IEex_DisableCodeProtection()

	if IEex_Debug_Stutter then

		local inAreaRender = IEex_Malloc(0x4)
		IEex_WriteDword(inAreaRender, 0x0)
		IEex_DefineAssemblyLabel("inAreaRender", inAreaRender)

		IEex_HookRestore(0x790DC6, 6, 0, {[[
			!push_all_registers_iwd2
			!push_ecx
			!push_eax
			!call >IEex_Helper_GetMicroseconds
			!mov_ebx_eax
			!pop_eax
			!pop_ecx
			!mov_[dword]_dword *inAreaRender #1
			!call_[eax+dword] #C4
			!mov_[dword]_dword *inAreaRender #0
			!call >IEex_Helper_GetMicroseconds
			!sub_eax_ebx

			!cmp_eax_dword #8235
			!jb_dword >no_log

			!push_eax
			!push_byte 01
			!push_dword ]], {IEex_WriteStringAuto("Stutter -> %d"), 4}, [[
			!call >_SDL_Log
			!add_esp_byte 0C

			@no_log
			!pop_all_registers_iwd2
		]]})

	end

	IEex_EnableCodeProtection()

	-- Actually IWD2's "operator_new" and "operator_delete", (needed for IEex memory to interact with engine)
	-- NOTE: THESE NEED TO BE THE LAST LINES EXECUTED DURING INITIAL STARTUP!
	IEex_DefineAssemblyLabel("_malloc", 0x7FC95B)
	IEex_DefineAssemblyLabel("_free", 0x7FC984)

end)()
