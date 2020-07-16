
(function()

	IEex_DisableCodeProtection()

	---------------------------------
	-- New Opcode #500 (InvokeLua) --
	---------------------------------

	local IEex_InvokeLua = IEex_WriteOpcode({

		["ApplyEffect"] = {[[

			!build_stack_frame
			!sub_esp_byte 0C
			!push_registers

			!mov_esi_ecx

			; Copy resref field into null-terminated stack space ;
			!mov_eax_[esi+byte] 2C
			!mov_[ebp+byte]_eax F4
			!mov_eax_[esi+byte] 30
			!mov_[ebp+byte]_eax F8
			!mov_byte:[ebp+byte]_byte FC 0

			!lea_eax_[ebp+byte] F4
			!push_eax
			!push_dword *_g_lua
			!call >_lua_getglobal
			!add_esp_byte 08

			!push_esi
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua
			!call >_lua_pushnumber
			!add_esp_byte 0C

			!push_[ebp+byte] 08
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua
			!call >_lua_pushnumber
			!add_esp_byte 0C

			!push_byte 00
			!push_byte 00
			!push_byte 00
			!push_byte 00
			!push_byte 02
			!push_dword *_g_lua
			!call >_lua_pcallk
			!add_esp_byte 18
			!call >IEex_CheckCallError

			@ret
			!mov_eax #1
			!restore_stack_frame
			!ret_word 04 00
		]]},
	})

	----------------------------------
	-- New Opcode #501 (ModifyData) --
	----------------------------------

	local IEex_ModifyData = IEex_WriteOpcode({

		["OnAddSpecific"] = {[[

			!push_state
			!mov_eax_[ecx+byte] 44

			; byte ;
			!cmp_eax_byte 01
			!jnz_dword >word

			!xor_eax_eax
			!mov_al_[ecx+byte] 18 ; To Add ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!add_[ecx+edi]_al

			@word
			!cmp_eax_byte 02
			!jne_dword >dword

			!xor_eax_eax
			!mov_ax_[ecx+byte] 18 ; To Add ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!add_[ecx+edi]_ax

			@dword
			!cmp_eax_byte 04
			!jne_dword >ret

			!mov_eax_[ecx+byte] 18 ; To Add ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!add_[ecx+edi]_eax

			@ret
			!mov_eax #1
			!pop_state
			!ret_word 04 00
		]]},


		["OnRemove"] = {[[

			!push_state
			!mov_eax_[ecx+byte] 44

			; byte ;
			!cmp_eax_byte 01
			!jnz_dword >word

			!xor_eax_eax
			!mov_al_[ecx+byte] 18 ; To Subtract ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!sub_[ecx+edi]_al

			@word
			!cmp_eax_byte 02
			!jne_dword >dword

			!xor_eax_eax
			!mov_ax_[ecx+byte] 18 ; To Subtract ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!sub_[ecx+edi]_ax

			@dword
			!cmp_eax_byte 04
			!jne_dword >ret

			!mov_eax_[ecx+byte] 18 ; To Subtract ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!sub_[ecx+edi]_eax

			@ret
			!mov_eax #1
			!pop_state
			!ret_word 04 00
		]]},
	})

	-------------------------------------
	-- New Opcode #502 (ScreenEffects) --
	-------------------------------------

	IEex_ScreenEffectsGlobalFunctions = {}
	
	function IEex_AddScreenEffectsGlobal(func_name, func)
		IEex_ScreenEffectsGlobalFunctions[func_name] = func
	end
--[[
	IEex_AddScreenEffectsGlobal("EXEFFMOD", function(effectData, creatureData)
		local targetID = IEex_ReadDword(creatureData + 0x34)
		local sourceID = IEex_ReadDword(effectData + 0x10C)
		local internal_flags = IEex_ReadDword(effectData + 0xC8)
		local opcode = IEex_ReadDword(effectData + 0xC)
		if bit32.band(internal_flags, 0x2000000) > 0 then return false end
		local savingthrow = IEex_ReadDword(effectData + 0x3C)
		local savebonus = IEex_ReadDword(effectData + 0x40)
		local school = IEex_ReadDword(effectData + 0x48)
		local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
		if ex_trueschool[parent_resource] ~= nil then
			school = ex_trueschool[parent_resource]
		end
		if bit32.band(savingthrow, 0x1C) > 0 and IEex_GetActorSpellState(sourceID, 195) then
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				if theopcode == 288 and theparameter2 == 195 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					if (theresource ~= "" and theresource == parent_resource) or bit32.band(thesavingthrow, 2 ^ (school + 15)) > 0 then
						savebonus = savebonus + theparameter1
					end
				end
			end)
			IEex_DisplayString(savebonus)
			IEex_WriteDword(effectData + 0x40, savebonus)
		end
		return false
	end)
--]]
	IEex_RegisterLuaStat({

		["reload"] = function(stats)
			stats.screenEffects = {}
		end,

		["copy"] = function(sourceStats, destStats)
			destStats.screenEffects = {}
			for _, entry in ipairs(sourceStats.screenEffects) do
				table.insert(destStats.screenEffects, entry)
			end
		end,

	})

	IEex_ScreenEffectsFunc = function(pEffect, pSprite)

		local actorID = IEex_GetActorIDShare(pSprite)
		local effectResource = IEex_ReadLString(pEffect + 0x2C, 8)

		local stats = IEex_AccessLuaStats(actorID)
		table.insert(IEex_GameObjectData[actorID].luaDerivedStats.screenEffects, {
			["pOriginatingEffect"] = pEffect,
			["functionName"] = effectResource,
		})

	end

	local IEex_ScreenEffects = IEex_WriteOpcode({

		["ApplyEffect"] = {[[

			!push_state

			; pEffect ;
			!push_ecx

			!push_dword ]], {IEex_WriteStringAuto("IEex_ScreenEffectsFunc"), 4}, [[
			!push_dword *_g_lua
			!call >_lua_getglobal
			!add_esp_byte 08

			; pEffect ;
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua
			!call >_lua_pushnumber
			!add_esp_byte 0C

			; pSprite ;
			!push_[ebp+byte] 08
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua
			!call >_lua_pushnumber
			!add_esp_byte 0C

			!push_byte 00
			!push_byte 00
			!push_byte 00
			!push_byte 00
			!push_byte 02
			!push_dword *_g_lua
			!call >_lua_pcallk
			!add_esp_byte 18
			!call >IEex_CheckCallError

			@ret
			!mov_eax #1
			!pop_state
			!ret_word 04 00

		]]},
	})

	IEex_OnCheckAddScreenEffectsHook = function(pEffect, pSprite)

		for func_name, func in pairs(IEex_ScreenEffectsGlobalFunctions) do
			if func(pEffect, pSprite) then
				return true
			end
		end
		
		local actorID = IEex_GetActorIDShare(pSprite)
		local screenList = IEex_AccessLuaStats(actorID).screenEffects

		for _, entry in ipairs(screenList) do

			local immunityFunction = _G[entry.functionName]

			if immunityFunction and immunityFunction(entry.pOriginatingEffect, pEffect, pSprite) then
				return true
			end
		end

		return false
	end

	IEex_HookAfterCall(0x733137, {[[

		!push_registers_iwd2
		!mov_ebx_eax

		!push_dword ]], {IEex_WriteStringAuto("IEex_OnCheckAddScreenEffectsHook"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; pEffect ;
		!push_edi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; pSprite ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 02
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError
		!jnz_dword >error

		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_toboolean
		!add_esp_byte 08
		!push_eax
		!push_byte FE
		!push_dword *_g_lua
		!call >_lua_settop
		!add_esp_byte 08
		!pop_eax
		!jmp_dword >no_error

		@error
		!xor_eax_eax

		@no_error
		!test_eax_eax
		!jz_dword >return_normally

		; Force both CheckAdd return value and function's noSave arg to false ;
		!mov_ebx #0
		!mov_[esp+byte]_dword 30 #0

		@return_normally
		!mov_eax_ebx
		!pop_registers_iwd2

	]]})

	-----------------------------
	-- Opcode Definitions Hook --
	-----------------------------

	local opcodesHook = IEex_WriteAssemblyAuto(IEex_ConcatTables({[[

		!cmp_eax_dword #1F4
		!jne_dword >501

		]], IEex_InvokeLua, [[

		@501
		!cmp_eax_dword #1F5
		!jne_dword >502

		]], IEex_ModifyData, [[

		@502
		!cmp_eax_dword #1F6
		!jne_dword >fail

		]], IEex_ScreenEffects, [[

		@fail
		!jmp_dword :492C44

	]]}))
	IEex_WriteAssembly(0x48C882, {{opcodesHook, 4, 4}})

	IEex_EnableCodeProtection()

end)()
