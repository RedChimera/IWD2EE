
(function()

	local mainStatus, mainError = xpcall(function()

		dofile("override/IEex_Common_State.lua")
		dofile("override/IEex_Common_Patch.lua")

		IEex_DllCall("IEexHelper", "InitHelperDLL", {IEex_Label("_SDL_LogV"), IEex_Label("_SDL_Log")}, nil, 0x0)
		IEex_DllCall("IEexHelper", "ExposeFunctions", {IEex_Label("_g_lua")}, nil, 0x0)
		for name, address in pairs(IEex_Helper_ExportFunctions()) do
			IEex_DefineAssemblyLabel(name, address)
		end

		dofile("override/IEex_Helper_Addresses.lua")
		dofile("override/IEex_Helper_Patch.lua")

		dofile("override/IEex_IWD2_State.lua")
		dofile("override/IEex_IWD2_Patch.lua")

		IEex_Helper_InitAddresses(IEex_Helper_Addresses)

		print("IEex startup completed successfully!")

	end, debug.traceback)

	if not mainStatus then
		print("ERROR: "..mainError)
		IEex_MessageBox("ERROR: "..mainError)
	end

end)()
