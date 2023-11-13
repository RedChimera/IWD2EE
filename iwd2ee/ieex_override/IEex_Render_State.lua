
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

function IEex_IsCncDDrawPresent()
	return IEex_GetModuleProcAddress(IEex_Helper_FindLoadedModule("ddraw.dll"), "GameHandlesClose") ~= 0x0
end

function IEex_IsCncDDrawWindowed()
	return IEex_DllCall("ddraw", "DDIsWindowed", {}, nil, 0x0) ~= 0
end

function IEex_Extern_CheckForceFullscreen()
	return IEex_IsCncDDrawPresent()
end

function IEex_Extern_CheckSuppressToggleFullscreen()

	if IEex_IsCncDDrawPresent() then

		local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
		local hWnd = IEex_ReadDword(g_pBaldurChitin + 0x94)

		local WM_APP = 0x8000

		-- cnc-ddraw specific
		local WM_TOGGLE_FULLSCREEN = WM_APP + 117
		local CNC_DDRAW_SET_FULLSCREEN = 1
		local CNC_DDRAW_SET_WINDOWED = 2

		local wParam = IEex_IsCncDDrawWindowed() and CNC_DDRAW_SET_FULLSCREEN or CNC_DDRAW_SET_WINDOWED
		IEex_PostMessageA(hWnd, WM_TOGGLE_FULLSCREEN, wParam, 0x0);

		-- Set m_bEffectiveFullScreen to resolve the engine's attempt to enter
		-- windowed mode so this function doesn't end up getting spammed
		IEex_WriteByte(g_pBaldurChitin + 0xE2, 1)
		return true
	end
	return false
end

function IEex_Extern_CheckOverrideOptionsScreenThinksGameIsFullScreen()
	if IEex_IsCncDDrawPresent() then
		return IEex_IsCncDDrawWindowed() and 0 or 1
	end
	return -1
end

function IEex_Extern_CheckForceOptionsScreenToRequestWindowedMode()
	return IEex_IsCncDDrawPresent()
end
