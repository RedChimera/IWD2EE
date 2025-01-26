
--------------------
-- Initialization --
--------------------

(function()

	local mainStatus, mainError = xpcall(function()

		print("")
		IEex_IterateMapAsSorted(IEex_GlobalAssemblyLabels,
			IEex_AlphanumericSortFunc,
			function(_, label, address)
				print(label..": "..IEex_ToHex(address))
			end
		)
		print("")

		IEex_InitialMemory = IEex_Malloc(0x1000) -- TODO: Can this allocate memory too far away?

		-- Inform the dynamic memory system of the starting memory.
		table.insert(IEex_CodePageAllocations, {
			{["address"] = IEex_InitialMemory, ["size"] = 0x1000, ["reserved"] = false}
		})

		IEex_Helper_InformThreadWatcherOfDynamicMemory(IEex_InitialMemory, 0x1000)

		------------------------
		--  Default Functions --
		------------------------

		-- Calls an internal function at the given address.

		-- stackArgs: Includes the values to be pushed before the function is called.
		--            Note that the stackArgs are pushed in the order they are defined,
		--            so in order to call a function properly these args should be defined in reverse.

		-- ecx: Sets the ecx register to the given value directly before calling the internal function.
		--      The ecx register is most commonly used to pass the "this" pointer.

		-- popSize: Some internal functions don't clean up the stackArgs pushed to them. This value
		--          defines the size, (in bytes), that should be removed from the stack after the
		--          internal function is called. Please note that if this value is wrong, the game
		--          WILL crash due to an imbalanced stack.

		-- SIGNATURE:
		-- number eax = IEex_Call(number address, table stackArgs, number ecx, number popSize)
		IEex_WriteAssemblyFunction("IEex_Call", {[[
			$IEex_Call
			!push_state
			!push_byte 02
			!push_[ebp+byte] 08
			!call >_lua_objlen
			!add_esp_byte 08
			!test_eax_eax
			!je_dword >no_args
			!mov_edi_eax
			!mov_esi #01
			@arg_loop
			!push_esi
			!push_byte 02
			!push_[ebp+byte] 08
			!call >_lua_rawgeti
			!add_esp_byte 0C
			!push_byte FF
			!push_[ebp+byte] 08
			!call >_lua_tonumber
			!add_esp_byte 08
			!call >__ftol2_sse
			!push_eax
			!push_byte FE
			!push_[ebp+byte] 08
			!call >_lua_settop
			!add_esp_byte 08
			!inc_esi
			!cmp_esi_edi
			!jle_dword >arg_loop
			@no_args
			!push_byte 03
			!push_[ebp+byte] 08
			!call >_lua_tonumber
			!add_esp_byte 08
			!call >__ftol2_sse
			!push_eax
			!push_byte 01
			!push_[ebp+byte] 08
			!call >_lua_tonumber
			!add_esp_byte 08
			!call >__ftol2_sse
			!pop_ecx
			!call_eax
			!push_eax
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_[ebp+byte] 08
			!call >_lua_pushnumber
			!add_esp_byte 0C
			!push_byte 04
			!push_[ebp+byte] 08
			!call >_lua_tonumber
			!add_esp_byte 08
			!call >__ftol2_sse
			!add_esp_eax
			!mov_eax #01
			!pop_state
			!ret
		]]})

		IEex_WriteAssemblyAuto({[[

			$IEex_PrintPopLuaString
			!build_stack_frame

			!push_byte 00
			!push_byte FF
			!push_[ebp+byte] 08
			!call >_lua_tolstring
			!add_esp_byte 0C

			; _lua_pushstring arg ;
			!push_eax

			!push_dword ]], {IEex_WriteStringAuto("print"), 4}, [[
			!push_[ebp+byte] 08
			!call >_lua_getglobal
			!add_esp_byte 08

			!push_[ebp+byte] 08
			!call >_lua_pushstring
			!add_esp_byte 08

			!push_byte 00
			!push_byte 00
			!push_byte 01
			!push_[ebp+byte] 08
			!call >_lua_pcall
			!add_esp_byte 10

			; Clear error string off of stack ;
			!push_byte FE
			!push_[ebp+byte] 08
			!call >_lua_settop
			!add_esp_byte 08

			!destroy_stack_frame
			!ret_word 04 00
		]]})

		IEex_WriteAssemblyAuto({[[

			$IEex_CheckCallError
			!test_eax_eax
			!jnz_dword >error
			!ret_word 04 00

			@error
			!push_[esp+byte] 04
			!call >IEex_PrintPopLuaString

			!mov_eax #1
			!ret_word 04 00
		]]})

		IEex_WriteAssemblyAuto({[[
			$IEex_GetCurrentThread
			!push_registers_iwd2
			!mov_eax_[dword] #847288
			!call_eax
			!pop_registers_iwd2
			!ret
		]]})

		IEex_WriteAssemblyFunction("IEex_GetCurrentThread", {[[

			$IEex_GetCurrentThreadLua
			!push_state

			!mov_eax_[dword] #847288
			!call_eax

			; Return read value ;
			!push_eax
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_[ebp+byte] 08
			!call >_lua_pushnumber
			!add_esp_byte 0C

			!mov_eax #1
			!pop_state
			!ret
		]]})

		IEex_WriteAssemblyFunction("IEex_GetMilliseconds", {[[

			$IEex_GetMilliseconds
			!build_stack_frame

			!call ]], {IEex_GetProcAddress("Kernel32", "GetTickCount"), 4, 4}, [[

			!push_eax
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_[ebp+byte] 08
			!call >_lua_pushnumber
			!add_esp_byte 0C

			!mov_eax #1
			!destroy_stack_frame
			!ret
		]]})

	end, debug.traceback)

	if not mainStatus then
		-- Failed to initialize IEex, clean up junk.
		IEex_MinimalStartup = nil
		IEex_Error(mainError)
	end

end)()
