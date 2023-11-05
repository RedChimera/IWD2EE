
-- This patches the WineD3D dll included in the GOG distribution's ddrawfix to enable logging.
-- Enabling this on another version of WineD3D crashes the game.
IEex_PatchWineD3DLogging = false

function IEex_Extern_AfterDirectDrawCreate()
	if IEex_PatchWineD3DLogging and IEex_Helper_FindLoadedModule("wined3d.dll") ~= 0x0 then
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
