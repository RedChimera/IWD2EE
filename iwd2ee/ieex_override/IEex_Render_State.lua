
function IEex_Extern_AfterDirectDrawCreate()
	if IEex_Helper_FindLoadedModule("wined3d.dll") ~= 0x0 then
		IEex_RunWithStack(0x4, function(esp)
			IEex_DllCall("Kernel32", "VirtualProtect", {esp, 0x40, 0xAE00, 0x6FEC1000}, nil, 0x0)
			IEex_HookReturnNOPs(0x6FEC1F6F, 0, {[[
				!add_esp_byte 04
				!call >_SDL_LogV
			]]})
			IEex_DllCall("Kernel32", "VirtualProtect", {esp, 0x20, 0xAE00, 0x6FEC1000}, nil, 0x0)
		end)
	end
end
