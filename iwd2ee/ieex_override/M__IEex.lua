
(function()

	local mainStatus, mainError = pcall(function()

		dofile("override/IEex_Common_State.lua")
		dofile("override/IEex_Common_Patch.lua")

		IEex_DllCall("IEexHelper", "InitHelperDLL", {IEex_Label("_SDL_Log")}, nil, 0x4)
		IEex_DllCall("IEexHelper", "ExposeFunctions", {IEex_Label("_g_lua")}, nil, 0x4)
		IEex_Helper_ExportFunctions()
		for name, address in pairs(IEex_Helper_Functions) do
			IEex_DefineAssemblyLabel(name, address)
		end

		dofile("override/IEex_IWD2_State.lua")
		dofile("override/IEex_IWD2_Patch.lua")
		print("IEex startup completed successfully!")
	end)

	if not mainStatus then
		print(mainError)
		IEex_MessageBox("ERROR: "..mainError)
	end

end)()
