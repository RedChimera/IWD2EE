
(function()

	local mainStatus, mainError = pcall(function()
		dofile("override/IEex_Com.lua")
		dofile("override/IEex_IWD2.lua")
		print("IEex startup completed successfully!")
	end)

	if not mainStatus then
		print(mainError)
		IEex_MessageBox("ERROR: "..mainError)
	end

end)()
