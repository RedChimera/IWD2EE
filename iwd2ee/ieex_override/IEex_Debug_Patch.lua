
IEex_Debug_CompressTime = false
IEex_Debug_EnableThreadWatcher = false
IEex_Debug_ForceTracePatches = false
IEex_Debug_LogButtonInvalidations = false
IEex_Debug_LogPanelInvalidations = false
IEex_Debug_Stutter = false
--IEex_Debug_UpdateLoadTimes = false
--IEex_Debug_UpdateTimes = false

function IEex_Debug_WriteTracePatches()

	if not IEex_Debug_EnableThreadWatcher and not IEex_Debug_ForceTracePatches
		and not IEex_Debug_UpdateLoadTimes and not IEex_Debug_UpdateTimes
	then
		return
	end

	local parseLargeLua = function(fileName)
		local file, fileErr = io.open(fileName, "r")
		if file == nil then
			print("File error: \n" .. fileErr)
			return false
		end
		for line in file:lines() do
			local code, loadErr = loadstring(line)
			if loadErr then
				print("Loadstring error: \n" .. loadErr)
				return false
			end
			code()
		end
		file:close()
	end

	parseLargeLua("override/IEex_Trace.lua")

	-- if IEex_Debug_UpdateTimes then
	-- 	IEex_Helper_RegisterTrace("CChitin_AsynchronousUpdate", 0x78F0E0, 66) -- AI
	-- 	IEex_Helper_RegisterTrace("CChitin_SynchronousUpdate", 0x790B70, 33)  -- Render
	-- end

	-- if IEex_Debug_UpdateLoadTimes then
	-- 	IEex_Helper_RegisterTrace("CInfGame_LoadGame", 0x5AB190, 0)
	-- end

	if IEex_Debug_EnableThreadWatcher then
		IEex_Helper_LaunchThreadWatcher()
	end
end

(function()

	if IEex_Debug_CompressTime then
		IEex_DisableCodeProtection()
		IEex_HookRestore(0x68CAAD, 0, 7, IEex_FlattenTable({[[
			!push_all_registers_iwd2
			]], IEex_GenLuaCall("IEex_Extern_Debug_OnCompressTime"), [[
			@call_error
			!pop_all_registers_iwd2
		]]}))
		IEex_EnableCodeProtection()
	end

	if IEex_Debug_Stutter then

		local inAreaRender = IEex_Malloc(0x4)
		IEex_WriteDword(inAreaRender, 0x0)
		IEex_DefineAssemblyLabel("inAreaRender", inAreaRender)

		IEex_DisableCodeProtection()
		IEex_HookRestore(0x790DC6, 6, 0, {[[
			!push_all_registers_iwd2
			!push_ecx
			!push_eax
			!call >IEex_Helper_GetMicroseconds
			!mov_ebx_eax
			!pop_eax
			!pop_ecx
			!mov_[dword]_dword *inAreaRender #1
			!call_[eax+dword] #C4
			!mov_[dword]_dword *inAreaRender #0
			!call >IEex_Helper_GetMicroseconds
			!sub_eax_ebx

			!cmp_eax_dword #8235
			!jb_dword >no_log

			!push_eax
			!push_dword ]], {IEex_WriteStringAuto("Stutter -> %d"), 4}, [[
			!call >IEex_Helper_logV
			!add_esp_byte 08

			@no_log
			!pop_all_registers_iwd2
		]]})
		IEex_EnableCodeProtection()
	end

	if IEex_Debug_LogPanelInvalidations then
		IEex_DisableCodeProtection()
		IEex_HookRestore(0x4D394D, 0, 12, IEex_FlattenTable({[[
			!mark_esp(44)
			!push_all_registers_iwd2
			]], IEex_GenLuaCall("IEex_Extern_Debug_LogPanelInvalidation", {
				["args"] = {
					{"!push(esi)"},                             -- panel
					{"!marked_esp !push([esp+4])"},             -- rRect
					{"!push(edi)"},                             -- m_rInvalid
					{"!marked_esp !lea(eax,[esp]) !push(eax)"}, -- esp
				},
			}), [[
			@call_error
			!pop_all_registers_iwd2
		]]}))
		IEex_EnableCodeProtection()
	end

	if IEex_Debug_LogButtonInvalidations then

		IEex_DisableCodeProtection()

		IEex_HookRestore(0x4D56A0, 0, 6, IEex_FlattenTable({[[
			!mark_esp
			!push_all_registers_iwd2
			]], IEex_GenLuaCall("IEex_Extern_Debug_LogButtonInvalidation", {
				["args"] = {
					{"!push(ecx)"},                             -- button
					{"!marked_esp !lea(eax,[esp]) !push(eax)"}, -- esp
				},
			}), [[
			@call_error
			!pop_all_registers_iwd2
		]]}))

		IEex_HookRestore(0x4D5730, 0, 6, IEex_FlattenTable({[[
			!mark_esp
			!push_all_registers_iwd2
			]], IEex_GenLuaCall("IEex_Extern_Debug_LogButtonInvalidationReset", {
				["args"] = {
					{"!push(ecx)"},                             -- button
					{"!marked_esp !lea(eax,[esp]) !push(eax)"}, -- esp
				},
			}), [[
			@call_error
			!pop_all_registers_iwd2
		]]}))

		IEex_EnableCodeProtection()
	end

end)()
