
-- This file speeds up loading by caching non-player scripts and
-- by removing some SleepEx() calls that seem to have no effect
-- other than slowing down the load process.

(function()

	IEex_DisableCodeProtection()

	-- Modern version of sscanf() is slightly faster
	IEex_WriteAssembly(0x7E7B99, {[[
		!jmp_dword ]], {IEex_Label("IEex_Helper_sscanf"), 4, 4}, [[
	]]})

	-- Cache non-player scripts
	IEex_WriteAssembly(0x45FE00, {[[
		!lea(eax,[esp+4])
		!push(eax)
		!push(ecx)
		!call ]], {IEex_Label("IEex_Helper_CAIScript_ConstructCached"), 4, 4}, [[
		!ret(8)
	]]})

	-- CInfGame_Unmarshal()
	IEex_WriteAssembly(0x5A8338, {"!add(esp,8) !repeat(3,!nop)"})
	IEex_WriteAssembly(0x5A89C4, {"!add(esp,8) !repeat(3,!nop)"})
	IEex_WriteAssembly(0x5A921D, {"!add(esp,8) !repeat(3,!nop)"})

	-- CVariableHash_Unknown()
	IEex_WriteAssembly(0x54FD8F, {"!add(esp,8) !repeat(3,!nop)"})

	-- CCacheStatus_Update()
	IEex_WriteAssembly(0x4408A6, {"!repeat(5,!nop)"})
	IEex_WriteAssembly(0x4413AC, {"!repeat(5,!nop)"})

	-- CGameSprite_Construct()
	IEex_HookRestore(0x6F242F, 2, 7, {"!add(esp,8)"})
	IEex_WriteAssembly(0x6F2458, {"!repeat(5,!nop)"})
	IEex_WriteAssembly(0x6F2464, {"!repeat(5,!nop)"})

	-- CInfGame_LoadArea()
	IEex_WriteAssembly(0x5A25C8, {"!add(esp,8) !repeat(3,!nop)"})
	IEex_WriteAssembly(0x5A287A, {"!repeat(12,!nop)"})
	IEex_WriteAssembly(0x5A30AE, {"!add(esp,8) !repeat(3,!nop)"})

	-- CInfGame_LoadGame()
	IEex_WriteAssembly(0x5AB2B2, {"!add(esp,8) !repeat(3,!nop)"})
	IEex_WriteAssembly(0x5AB89F, {"!add(esp,8) !repeat(3,!nop)"})

	-- CInfGame_ProgressBarCallback()
	IEex_WriteAssembly(0x5A9761, {"!add(esp,8) !repeat(3,!nop)"})

	-- CInfTileSet_Destruct()
	IEex_WriteAssembly(0x5CB040, {"!repeat(9,!nop)"})

	-- CAIScript_Read()
	IEex_WriteAssembly(0x40F7BD, {"!repeat(5,!nop)"})

	-- CGameArea_AIUpdate() - Long hang when entering an area
	IEex_WriteAssembly(0x46F3CE, {"!repeat(12,!nop)"})

	-- CInfGame_GiveUpAreaListsThenYieldToSyncThread()
	IEex_WriteAssembly(0x59FB3C, {"!repeat(6,!nop)"})
	IEex_WriteAssembly(0x59FA95, {"!repeat(6,!nop)"})
	IEex_WriteAssembly(0x59FB0C, {"!repeat(6,!nop)"})

	-- CGameArea_ProgressBarCallback()
	IEex_WriteAssembly(0x474EF0, {"!add(esp,4) !repeat(3,!nop)"})

	-- CInfGame_SynchronousUpdate() - Autosave
	IEex_WriteAssembly(0x5BEC07, {"!repeat(8,!nop)"})

	IEex_EnableCodeProtection()

end)()
