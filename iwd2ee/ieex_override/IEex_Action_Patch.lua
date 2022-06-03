
(function()

	IEex_DisableCodeProtection()

	IEex_HookBeforeCall(0x733FE0, {[[

		!push_all_registers_iwd2

		!call >IEex_GetLuaState
		!mov_ebx_eax

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CGameSprite_SetCurrAction"), 4}, [[
		!push_ebx
		!call >_lua_getglobal
		!add_esp_byte 08

		!push_ebp
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_ebx
		!call >_lua_pcall
		!add_esp_byte 10
		!push_ebx
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2

	]]})

	-----------------------
	-- Start New Actions --
	-----------------------

	------------------------
	-- IEex_Lua(S:Chunk*) --
	------------------------

	local IEex_Lua = {[[

		$debug
		!call >IEex_GetLuaState
		!mov_esi_eax

		!push_[ebx+dword] #538
		!push_esi
		; TODO: Cache Lua chunks ;
		!call >_luaL_loadstring
		!add_esp_byte 08

		!push_[ebx+byte] 5C
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_esi
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_dword ]], {IEex_WriteStringAuto("IEex_Lua_ActorID"), 4}, [[
		!push_esi
		!call >_lua_setglobal
		!add_esp_byte 08

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_esi
		!call >_lua_pcall
		!add_esp_byte 10
		!push_esi
		!call >IEex_CheckCallError

	]]}

	---------------------
	-- End New Actions --
	---------------------

	-----------------------------
	-- Action Definitions Hook --
	-----------------------------

	IEex_HookJump(0x44DC87, 0, IEex_FlattenTable({[[
		!jbe_dword >jmp_fail
		!cmp_ebp_dword #146
		!jne_dword >jmp_success ; not defined ;
		]], IEex_Lua, [[
		!mov_esi #FFFFFFFF
		!jmp_dword :4526F7 ; success ;
	]]}))

	----------------------------------------------------------
	-- Dialog actions / triggers should properly handle ')' --
	-- characters in strings, not cutting input short.      --
	----------------------------------------------------------

	local closingParenHook = IEex_WriteAssemblyAuto(IEex_FlattenTable({[[
		!push_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_FindScriptingStringClosingParen", {
			["args"] = {
				{"!push(ecx)"},
			},
			["returnType"] = IEex_LuaCallReturnType.Number,
		}), [[
		@call_error
		!pop_registers_iwd2
		!ret_word 04 00
	]]}))
	for _, address in ipairs({0x4830B4, 0x4832E7, 0x48358E}) do
		IEex_HookChangeRel32(address, closingParenHook)
	end

	--------------------------------------------------------------------------------
	-- Dialog actions / triggers shouldn't remove whitespace in string parameters --
	--------------------------------------------------------------------------------

	local stripWhitespaceHook = IEex_WriteAssemblyAuto(IEex_FlattenTable({[[
		!mark_esp
		!push(ebx)
		]], IEex_GenLuaCall("IEex_Extern_StripScriptingStringWhitespace", {
			["args"] = {
				{"!marked_esp !push([esp+4])"},
				{"!marked_esp !lea(eax,[esp+8]) !push(eax)"},
			},
		}), [[
		@call_error
		!marked_esp !mov(eax,[esp+4])
		!pop(ebx)
		!ret
	]]}))
	IEex_WriteAssembly(0x4210E0, {"!jmp_dword", {stripWhitespaceHook, 4, 4}})

	IEex_EnableCodeProtection()

end)()
