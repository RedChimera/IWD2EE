
(function()

	local mainStatus, mainError = xpcall(function()

		dofile("override/IEex_Common_State.lua")
		dofile("override/IEex_Common_Patch.lua")

		IEex_DllCall("IEexHelper", "InitHelperDLL", {IEex_Label("Hardcoded_log"), IEex_Label("_g_lua")}, nil, 0x0)

		IEex_DllCall("IEexHelper", "ExposeFunctions", {IEex_Label("_g_lua")}, nil, 0x0)
		for name, address in pairs(IEex_Helper_ExportFunctions()) do
			IEex_DefineAssemblyLabel(name, address)
		end

		for _, dynamicAllocation in ipairs(IEex_PendingDynamicAllocationInforms) do
			IEex_Helper_InformThreadWatcherOfDynamicMemory(dynamicAllocation[1], dynamicAllocation[2])
		end
		IEex_PendingDynamicAllocationInforms = nil

		dofile("override/IEex_Helper_Addresses.lua")
		dofile("override/IEex_Helper_Patch.lua")

		IEex_InSyncState = true

		dofile("override/IEex_IWD2_State.lua")
		dofile("override/IEex_IWD2_Patch.lua")

		IEex_Helper_InitAddresses(IEex_Helper_Addresses)

		print("IEex startup completed successfully!")
		print("")

	end, debug.traceback)

	if not mainStatus then
		print("ERROR: "..mainError)
		IEex_MessageBox("ERROR: "..mainError)
	end

end)()
