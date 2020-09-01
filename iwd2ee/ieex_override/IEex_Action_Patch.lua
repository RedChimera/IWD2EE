
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
	!push_byte 00
	!push_byte 00
	!push_byte 01
	!push_ebx
	!call >_lua_pcallk
	!add_esp_byte 18
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
	!push_byte 00
	!push_byte 00
	!push_esi
	!call >_lua_pcallk
	!add_esp_byte 18
	!push_esi
	!call >IEex_CheckCallError

]]}

---------------------
-- End New Actions --
---------------------

-----------------------------
-- Action Definitions Hook --
-----------------------------

IEex_HookJump(0x44DC87, 0, IEex_ConcatTables({[[
	!jbe_dword >jmp_fail
	!cmp_ebp_dword #146
	!jne_dword >jmp_success ; not defined ;
	]], IEex_Lua, [[
	!mov_esi #FFFFFFFF
	!jmp_dword :4526F7 ; success ;
]]}))

IEex_EnableCodeProtection()
