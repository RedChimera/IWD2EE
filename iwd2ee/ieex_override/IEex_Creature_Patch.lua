
(function()

	IEex_DisableCodeProtection()

	----------------------------
	-- IEex_OnGameObjectAdded --
	----------------------------

	-- The function (sometimes) clobbers this arg during execution,
	-- have to save it myself so I can use it later.
	local onGameObjectAddedIndexPointer = IEex_Malloc(0x4)

	IEex_HookRestore(0x59A0F0, 0, 6, {[[
		!mov_eax_[esp+byte] 04
		!mov_[dword]_eax ]], {onGameObjectAddedIndexPointer, 4}, [[
	]]})

	IEex_HookAfterRestore(0x59A4FE, 0, 10, {[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnGameObjectAdded"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		!mov_eax_[dword] ]], {onGameObjectAddedIndexPointer, 4}, [[
		!mov_eax_[eax]

		; actorID ;
		!push_eax
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2

	]]})

	-----------------------------------
	-- IEex_OnGameObjectBeingDeleted --
	-----------------------------------

	IEex_HookRestore(0x59A530, 0, 6, {[[

		!push_complete_state

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnGameObjectBeingDeleted"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; actorID ;
		!push_[ebp+byte] 08
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!pop_complete_state

	]]})

	------------------------------------
	-- IEex_OnGameObjectsBeingCleaned --
	------------------------------------

	IEex_HookRestore(0x59A9D0, 0, 7, {[[

		!push_all_registers_iwd2

		!call >IEex_GetLuaState
		!mov_ebx_eax		

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnGameObjectsBeingCleaned"), 4}, [[
		!push_ebx
		!call >_lua_getglobal
		!add_esp_byte 08

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_ebx
		!call >_lua_pcall
		!add_esp_byte 10
		!push_ebx
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2

	]]})

	------------------------
	-- IEex_OnReloadStats --
	------------------------

	IEex_HookRestore(0x4440F0, 0, 6, {[[

		!push_complete_state

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnReloadStats"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; share ;
		!push_[ebp+byte] 08
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!pop_complete_state

	]]})

	----------------------------
	-- IEex_OnUpdateTempStats --
	----------------------------

	local callOnUpdateTempStats = IEex_WriteAssemblyAuto({[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_OnUpdateTempStats"), 4}, [[
		!push_dword *_g_lua_async
		!call >_lua_getglobal
		!add_esp_byte 08

		; share ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua_async
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua_async
		!call >_lua_pcall
		!add_esp_byte 10
		!push_dword *_g_lua_async
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2
		!ret

	]]})

	IEex_HookBeforeCall(0x72E1F9, {"!call", {callOnUpdateTempStats, 4, 4}})
	IEex_HookBeforeCall(0x733179, {"!call", {callOnUpdateTempStats, 4, 4}})

	-------------------------------------------------
	-- IEex_Extern_OnPostCreatureProcessEffectList --
	-------------------------------------------------

	IEex_HookAfterCall(0x72DAC7, IEex_FlattenTable({[[
		!mark_esp()
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_OnPostCreatureProcessEffectList", {
			["args"] = {
				{"!push(esi)"},
			},
		}), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))

	IEex_EnableCodeProtection()

end)()
