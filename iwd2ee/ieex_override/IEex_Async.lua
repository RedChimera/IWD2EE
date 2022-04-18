
function IEex_Extern_SetupAsyncState(asyncSharedMemory)

	IEex_InAsyncState = true

	-- IEex_ReadDword, IEex_ReadString, and IEex_ExposeToLua have all
	-- been hardcoded into the Async state so it can initialize itself.

	dofile("override/IEex_Common_State.lua")

	-- Initialize all labels from the Sync state passed-in via memory
	local labelCount = IEex_ReadDword(asyncSharedMemory + 0x4)
	local currentEntryAddress = asyncSharedMemory + 0xC

	for i = 1, labelCount, 1 do
		local label = IEex_ReadString(IEex_ReadDword(currentEntryAddress))
		local value = IEex_ReadDword(currentEntryAddress + 0x4)
		IEex_DefineAssemblyLabel(label, value)
		currentEntryAddress = currentEntryAddress + 0x8
	end

	-- Async thread should still be able to print to console/log
	IEex_ExposeToLua(IEex_Label("_l_log_print"), "print")

	-- Expose standard IEex functions to the Async state from the restored labels
	IEex_ExposeToLua(IEex_Label("IEex_Call"), "IEex_Call")
	IEex_ExposeToLua(IEex_Label("IEex_WriteString"), "IEex_WriteString")
	IEex_ExposeToLua(IEex_Label("IEex_RunWithStack"), "IEex_RunWithStack")
	IEex_ExposeToLua(IEex_Label("IEex_WriteLString"), "IEex_WriteLString")
	IEex_ExposeToLua(IEex_Label("IEex_ReadLString"), "IEex_ReadLString")
	IEex_ExposeToLua(IEex_Label("IEex_ReadUserdata"), "IEex_ReadUserdata")
	IEex_ExposeToLua(IEex_Label("IEex_ToLightUserdata"), "IEex_ToLightUserdata")
	IEex_ExposeToLua(IEex_Label("IEex_WriteByte"), "IEex_WriteByte")
	IEex_ExposeToLua(IEex_Label("IEex_GetCurrentThreadLua"), "IEex_GetCurrentThread")
	IEex_ExposeToLua(IEex_Label("IEex_GetMilliseconds"), "IEex_GetMilliseconds")
	IEex_ExposeToLua(IEex_Label("IEex_DumpCrashThreadStackLua"), "IEex_DumpCrashThreadStack")
	IEex_ExposeToLua(IEex_Label("IEex_DumpThreadStackLua"), "IEex_DumpThreadStack")

	-- Init helper dll for Async state
	IEex_DllCall("IEexHelper", "ExposeFunctions", {IEex_Label("_g_lua_async")}, nil, 0x0)
	for name, address in pairs(IEex_Helper_ExportFunctions()) do
		IEex_DefineAssemblyLabel(name, address)
	end

	IEex_Helper_SetBridge("IEex_ThreadBridge", "Async", IEex_GetCurrentThread())

	-- IMPORTANT: While the Async state initializes the entire IEex-IWD2 state,
	-- it does NOT have access to Sync-state variables, (they will contain their default values).
	-- The Async state can call functions defined in the IWD2 state, but it must use Bridge
	-- variables to pass information between threads.
	dofile("override/IEex_IWD2_State.lua")

	-- TODO: This adds a couple of seconds to startup - refactor these to use bridges
	IEex_DoStage1Indexing()
	IEex_DoStage2Indexing()

	-- Resume Sync thread - (the Sync thread is spinning until I do this)
	-- Not sure if the Sync thread needs to wait for me to finish initializing
	IEex_WriteDword(IEex_ReadDword(asyncSharedMemory + 0x8), 0x1)

end
