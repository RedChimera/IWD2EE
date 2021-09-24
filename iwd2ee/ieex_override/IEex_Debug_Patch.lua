
IEex_Debug_CompressTime = false
IEex_Debug_Stutter = false
IEex_Debug_BadSoundDestructor = true

if IEex_Debug_CompressTime then
	IEex_DisableCodeProtection()
	IEex_HookRestore(0x68CAAD, 0, 7, IEex_FlattenTable({[[
		!mark_esp()
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_Debug_OnCompressTime"), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))
	IEex_EnableCodeProtection()
end

if IEex_Debug_Stutter then

	local inAreaRender = IEex_Malloc(0x4)
	IEex_WriteDword(inAreaRender, 0x0)
	IEex_DefineAssemblyLabel("inAreaRender", inAreaRender)

	IEex_DisableCodeProtection()
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
	IEex_EnableCodeProtection()

end

if IEex_Debug_BadSoundDestructor then
	IEex_DisableCodeProtection()
	IEex_HookAfterCall(0x7A8E66, {[[
		!push_all_registers_iwd2
		!push(esp)
		!push(edi)
		!call ]], {IEex_GetProcAddress("IEexHelper", "CSoundImp_Destruct"), 4, 4}, [[
		!pop_all_registers_iwd2
	]]})
	IEex_EnableCodeProtection()
end
