
(function()

	IEex_DisableCodeProtection()

	IEex_WriteAssemblyFunction("IEex_DumpCrashThreadStack", {[[

		$IEex_DumpCrashThreadStackLua
		!build_stack_frame
		!push_registers_iwd2

		!push_byte 00
		!push_byte 02
		!push_[ebp+byte] 08
		!call >_lua_tolstring
		!add_esp_byte 0C
		!push_eax

		!push_byte 01
		!push_[ebp+byte] 08
		!call >_lua_tonumber
		!add_esp_byte 08
		!call >__ftol2_sse
		!push_eax

		!call >IEex_Helper_DumpCrashThreadStack

		!xor_eax_eax
		!pop_registers_iwd2
		!destroy_stack_frame
		!ret
	]]})

	IEex_WriteAssemblyFunction("IEex_DumpThreadStack", {[[

		$IEex_DumpThreadStackLua
		!build_stack_frame
		!push_registers_iwd2

		!push_byte 02
		!push_[ebp+byte] 08
		!call >_lua_toboolean
		!add_esp_byte 08
		!push_eax

		!push_byte 00
		!push_byte 01
		!push_[ebp+byte] 08
		!call >_lua_tolstring
		!add_esp_byte 0C
		!push_eax

		!lea_eax_[ebp+byte] 08
		!push_eax
		!call >IEex_Helper_DumpThreadStack

		!xor_eax_eax
		!pop_registers_iwd2
		!destroy_stack_frame
		!ret
	]]})

	IEex_EnableCodeProtection()

end)()
