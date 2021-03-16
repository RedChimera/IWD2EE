
(function()

	IEex_DisableCodeProtection()

	IEex_LuaTrigger = IEex_FlattenTable({
		{[[
			!call >IEex_GetLuaState
			!mov_ebx_eax

			; Set IEex_LuaTriggerActorID ;
			!push_[edi+byte] 5C
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_ebx
			!call >_lua_pushnumber
			!add_esp_byte 0C

			!push_dword ]], {IEex_WriteStringAuto("IEex_LuaTriggerActorID"), 4}, [[
			!push_ebx
			!call >_lua_setglobal
			!add_esp_byte 08
		]]}, 
		IEex_GenLuaCall(nil, {
			["functionChunk"] = {[[
				!marked_esp() !mov(eax,[esp+4])
				!push([eax+4E])
			]]},
			["returnType"] = IEex_LuaCallReturnType.Boolean,
		}),
		{[[
			!jmp_dword >no_error
			@call_error
			!xor_eax_eax
			@no_error
			!mov_esi_eax
		]]},
	})

	IEex_HookJumpOnSuccess(0x453933, IEex_FlattenTable({
		{[[
			!mark_esp(3D8)
			!add_eax_dword #400A

			!cmp_eax_dword #40F9 ; IEex_LuaTrigger ;
			!jne_dword >jmp_success
		]]}, IEex_LuaTrigger, {[[
			!jmp_dword :45AD4C
		]]},
	}))

	IEex_EnableCodeProtection()

end)()
