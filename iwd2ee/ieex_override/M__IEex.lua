
(function()

	local mainStatus, mainError = pcall(function()
		dofile("override/IEex_Common_State.lua")
		dofile("override/IEex_Common_Patch.lua")
		dofile("override/IEex_IWD2_State.lua")
		dofile("override/IEex_IWD2_Patch.lua")
		print("IEex startup completed successfully!")
	end)

	if not mainStatus then
		print(mainError)
		IEex_MessageBox("ERROR: "..mainError)
	end

end)()
