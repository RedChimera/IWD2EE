
-- This patches the WineD3D dll included in the GOG distribution's ddrawfix to enable logging.
-- Enabling this on another version of WineD3D crashes the game.
IEex_PatchWineD3DLogging = false

function IEex_Extern_AfterDirectDrawCreate()
	if IEex_PatchWineD3DLogging and IEex_Helper_FindLoadedModule("wined3d.dll") ~= 0x0 then
		IEex_RunWithStack(0x4, function(esp)
			IEex_DllCall("Kernel32", "VirtualProtect", {esp, 0x40, 0xAE00, 0x6FEC1000}, nil, 0x0)
			IEex_HookReturnNOPs(0x6FEC1F6F, 0, {[[
				!add_esp_byte 04
				!call >IEex_Helper_logV
			]]})
			IEex_DllCall("Kernel32", "VirtualProtect", {esp, 0x20, 0xAE00, 0x6FEC1000}, nil, 0x0)
		end)
	end
end

function IEex_IsCncDDrawPresent()
	return IEex_GetProcAddressInternal(IEex_Helper_FindLoadedModule("ddraw.dll"), "GameHandlesClose") ~= 0x0
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

function IEex_Extern_OverrideContainerHighlightColor(CGameContainer, renderType, colorPtr)

	if IEex_Helper_GetBridge("IEex_Options", "options", "highlightEmptyContainersInGray")
		and IEex_ReadDword(CGameContainer + 0x5BA) == 0 -- m_lstItems.m_nCount
	then
		if renderType == 0 or renderType == 1 then -- Normal mouse hover or Bash

			IEex_WriteDword(colorPtr, 0xA6A6A6)

		elseif renderType == 2 then -- Alt down or thieving

			local pGame = IEex_GetGameData()
			local isThieving = (
				-- m_id == pArea.m_iPicked
				IEex_ReadDword(CGameContainer + 0x5C) == IEex_ReadDword(IEex_ReadDword(CGameContainer + 0x12) + 0x246)
				-- pGame.m_nState == 2 and pGame->m_iconIndex == 36
				and IEex_ReadWord(pGame + 0x1B96) == 2 and IEex_ReadByte(pGame + 0x1B98) == 36
				-- (m_trapActivated ~= 0 and m_trapDetected ~= 0) or (m_dwFlags & 1) ~= 0
				and (
					(IEex_ReadWord(CGameContainer + 0x896) ~= 0 and IEex_ReadWord(CGameContainer + 0x898) ~= 0)
					or IEex_IsBitSet(IEex_ReadByte(CGameContainer + 0x88E), 0)
				)
			)

			if isThieving then
				IEex_WriteDword(colorPtr, 0xA6A6A6)
			else
				IEex_WriteDword(colorPtr, 0x808080)
			end
		end
	end
end
