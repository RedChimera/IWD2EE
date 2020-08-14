
--------------------
-- Initialization --
--------------------

(function()

	local mainStatus, mainError = pcall(function()

		-- !!!----------------------------------------------------------------!!!
		--  | IEex_Init() is the only new function that is exposed by default. |
		--  | It does several things:                                          |
		--  |                                                                  |
		--  |   1. Exposes the hardcoded function IEex_WriteByte()             |
		--  |                                                                  |
		--  |   2. Exposes the hardcoded function IEex_ExposeToLua()           |
		--  |                                                                  |
		--  |   3. Calls VirtualAlloc() with the following params =>           |
		--  |        lpAddress = 0                                             |
		--  |        dwSize = 0x1000                                           |
		--  |        flAllocationType = MEM_COMMIT | MEM_RESERVE               |
		--  |        flProtect = PAGE_EXECUTE_READWRITE                        |
		--  |                                                                  |
		--  |   4. Passes along the VirtualAlloc()'s return value              |
		-- !!! ---------------------------------------------------------------!!!

		IEex_InitialMemory = IEex_Init()

		-- Inform the dynamic memory system of the hardcoded starting memory.
		-- (Had to hardcode initial memory because I couldn't include a VirtualAlloc wrapper
		-- without using more than the 340 alignment bytes available.)
		table.insert(IEex_CodePageAllocations, {
			{["address"] = IEex_InitialMemory, ["size"] = 0x1000, ["reserved"] = false}
		})

		-- Fetch the matched pattern addresses from the loader.
		-- (Thanks @mrfearless!): https://github.com/mrfearless/IEexLoader
		IEex_GlobalAssemblyLabels = IEex_AddressList()

		print("")
		for label, address in pairs(IEex_GlobalAssemblyLabels) do
			print(label..": "..IEex_ToHex(address))
		end
		print("")

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
			!call >_lua_rawlen
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
			!push_byte 00
			!push_byte FF
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
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
			!push_byte 00
			!push_byte 03
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
			!call >__ftol2_sse
			!push_eax
			!push_byte 00
			!push_byte 01
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
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
			!push_byte 00
			!push_byte 04
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
			!call >__ftol2_sse
			!add_esp_eax
			!mov_eax #01
			!pop_state
			!ret
		]]})

		-- Writes the given string at the specified address.
		-- NOTE: Writes a terminating NULL in addition to the raw string.

		-- SIGNATURE:
		-- <void> = IEex_WriteString(number address, string toWrite)
		IEex_WriteAssemblyFunction("IEex_WriteString", {[[

			$IEex_WriteString
			!build_stack_frame
			!push_registers

			!push_byte 00
			!push_byte 01
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
			!call >__ftol2_sse
			!mov_edi_eax

			!push_byte 00
			!push_byte 02
			!push_[ebp+byte] 08
			!call >_lua_tolstring
			!add_esp_byte 0C

			!mov_esi_eax

			@copy_loop
			!mov_al_[esi]
			!mov_[edi]_al
			!inc_esi
			!inc_edi
			!cmp_byte:[esi]_byte 00
			!jne_dword >copy_loop

			!mov_byte:[edi]_byte 00

			!xor_eax_eax
			!restore_stack_frame
			!ret

		]]})

		-- Writes a string to the given address, padding any remaining space with null bytes to achieve desired length.
		-- If #toWrite >= to maxLength, terminating null is not written.
		-- If #toWrite > maxLength, characters after [1, maxLength] are discarded and not written.

		-- SIGNATURE:
		-- <void> = IEex_WriteLString(number address, string toWrite, number maxLength)
		IEex_WriteAssemblyFunction("IEex_WriteLString", {[[

			$IEex_WriteLString
			!build_stack_frame
			!push_registers

			!push_byte 00
			!push_byte 01
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
			!call >__ftol2_sse
			!mov_edi_eax

			!push_byte 00
			!push_byte 02
			!push_[ebp+byte] 08
			!call >_lua_tolstring
			!add_esp_byte 0C
			!mov_esi_eax

			!push_byte 00
			!push_byte 03
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
			!call >__ftol2_sse
			!mov_ebx_eax

			!xor_edx_edx

			!cmp_edx_ebx
			!jae_dword >return

			!cmp_byte:[esi]_byte 00
			!je_dword >null_loop

			@copy_loop

			!mov_al_[esi]
			!mov_[edi]_al
			!inc_esi
			!inc_edi

			!inc_edx
			!cmp_edx_ebx
			!jae_dword >return

			!cmp_byte:[esi]_byte 00
			!jne_dword >copy_loop

			@null_loop
			!mov_byte:[edi]_byte 00
			!inc_edi

			!inc_edx
			!cmp_edx_ebx
			!jb_dword >null_loop

			@return
			!xor_eax_eax
			!restore_stack_frame
			!ret

		]]})

		-- Reads a dword at the given address. What more is there to say.

		-- SIGNATURE:
		-- number result = IEex_ReadDword(number address)
		IEex_WriteAssemblyFunction("IEex_ReadDword", {[[

			$IEex_ReadDword
			!push_state

			!push_byte 00
			!push_byte 01
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
			!call >__ftol2_sse

			!push_[eax]
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

		-- Reads a string from the given address until a NULL is encountered.
		-- NOTE: Certain game structures, (most commonly resrefs), don't
		-- necessarily end in a NULL. Regarding resrefs, if one uses all
		-- 8 characters of alloted space, no NULL will be written. To read
		-- this properly, please use IEex_ReadLString with maxLength set to 8.
		-- In cases where the string is guaranteed to have a terminating NULL,
		-- use this function.

		-- SIGNATURE:
		-- string result = IEex_ReadString(number address)
		IEex_WriteAssemblyFunction("IEex_ReadString", {[[
			$IEex_ReadString
			!push_state
			!push_byte 00
			!push_byte 01
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
			!call >__ftol2_sse
			!push_eax
			!push_[ebp+byte] 08
			!call >_lua_pushstring
			!add_esp_byte 08
			!mov_eax #01
			!pop_state
			!ret
		]]})

		-- This is much longer than IEex_ReadString because it had to use new behavior.
		-- Reads until NULL is encountered, OR until it reaches the given length.
		-- Registers esi, ebx, and edi are all assumed to be non-volitile.

		-- SIGNATURE:
		-- string result = IEex_ReadLString(number address, number maxLength)
		IEex_WriteAssemblyFunction("IEex_ReadLString", {[[
			$IEex_ReadLString
			!build_stack_frame
			!sub_esp_byte 08
			!push_registers
			!push_byte 00
			!push_byte 01
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
			!call >__ftol2_sse
			!mov_esi_eax
			!push_byte 00
			!push_byte 02
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
			!call >__ftol2_sse
			!mov_ebx_eax
			!and_eax_byte FC
			!add_eax_byte 04
			!mov_[ebp+byte]_esp FC
			!sub_esp_eax
			!mov_edi_esp
			!mov_[ebp+byte]_edi F8
			!add_ebx_esi
			@read_loop
			!mov_al_[esi]
			!mov_[edi]_al
			!test_al_al
			!je_dword >done
			!inc_esi
			!inc_edi
			!cmp_esi_ebx
			!jl_dword >read_loop
			!mov_[edi]_byte 00
			@done
			!push_[ebp+byte] F8
			!push_[ebp+byte] 08
			!call >_lua_pushstring
			!add_esp_byte 08
			!mov_esp_[ebp+byte] FC
			!mov_eax #01
			!restore_stack_frame
			!ret
		]]})

		-- Returns the memory address of the given userdata object.

		-- SIGNATURE:
		-- number result = IEex_ReadUserdata(userdata value)
		IEex_WriteAssemblyFunction("IEex_ReadUserdata", {
			"$IEex_ReadUserdata 55 8B EC 53 51 52 56 57 6A 01 FF 75 08 \z
			!call >_lua_touserdata \z
			83 C4 08 50 DB 04 24 83 EC 04 DD 1C 24 FF 75 08 \z
			!call >_lua_pushnumber \z
			83 C4 0C B8 01 00 00 00 5F 5E 5A 59 5B 5D C3"
		})

		-- Returns a lightuserdata object that points to the given address.

		-- SIGNATURE:
		-- userdata result = IEex_ToLightUserdata(number address)
		IEex_WriteAssemblyFunction("IEex_ToLightUserdata", {
			"$IEex_ToLightUserdata 55 8B EC 53 51 52 56 57 6A 00 6A 01 FF 75 08 \z
			!call >_lua_tonumberx \z
			83 C4 0C \z
			!call >__ftol2_sse \z
			50 FF 75 08 \z
			!call >_lua_pushlightuserdata \z
			83 C4 08 B8 01 00 00 00 5F 5E 5A 59 5B 5D C3"
		})

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

		-- The following are implemented in IEex.dll by default.
		-- Due to having to spin up an Async state, I need to know
		-- their actual addresses. Only way is to rewrite them myself.
		IEex_WriteAssemblyFunction("IEex_WriteByte", {[[

			$IEex_WriteByte
			!push_state

			!push_byte 00
			!push_byte 01
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
			!call >__ftol2_sse
			!mov_edi_eax

			!push_byte 00
			!push_byte 02
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
			!call >__ftol2_sse

			!mov_byte:[edi]_al

			!xor_eax_eax
			!pop_state
			!ret
		]]})

		IEex_WriteAssemblyFunction("IEex_ExposeToLua", {[[

			$IEex_ExposeToLua
			!push_state

			!push_byte 00
			!push_byte 02
			!push_[ebp+byte] 08
			!call >_lua_tolstring
			!add_esp_byte 0C
			; name ;
			!push_eax

			!push_byte 00
			!push_byte 01
			!push_[ebp+byte] 08
			!call >_lua_tonumberx
			!add_esp_byte 0C
			!call >__ftol2_sse

			; function ;
			!push_byte 00
			!push_eax
			!push_[ebp+byte] 08
			!call >_lua_pushcclosure
			!add_esp_byte 0C

			; name ;
			!push_[ebp+byte] 08
			!call >_lua_setglobal
			!add_esp_byte 08

			!xor_eax_eax
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
	end)

	if not mainStatus then
		-- Failed to initialize IEex, clean up junk.
		IEex_MinimalStartup = nil
		error(mainError.."\n"..debug.traceback())
	end

end)()
