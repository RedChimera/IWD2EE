
function IEex_Extern_SetupAsyncState(asyncSharedMemory)

	IEex_InAsyncState = true

	-- Init common state
	dofile("override/IEex_Common_State.lua")

	-- Expose standard IEex functions to the Async state from the restored labels
	IEex_ExposeToLua(IEex_Label("IEex_Call"), "IEex_Call")
	IEex_ExposeToLua(IEex_Label("IEex_ClientToScreenLua"), "IEex_ClientToScreen")
	IEex_ExposeToLua(IEex_Label("IEex_DumpCrashThreadStackLua"), "IEex_DumpCrashThreadStack")
	IEex_ExposeToLua(IEex_Label("IEex_DumpThreadStackLua"), "IEex_DumpThreadStack")
	IEex_ExposeToLua(IEex_Label("IEex_GetCurrentThreadLua"), "IEex_GetCurrentThread")
	IEex_ExposeToLua(IEex_Label("IEex_GetCursorPosLua"), "IEex_GetCursorPos")
	IEex_ExposeToLua(IEex_Label("IEex_GetMilliseconds"), "IEex_GetMilliseconds")
	IEex_ExposeToLua(IEex_Label("IEex_ScreenToClientLua"), "IEex_ScreenToClient")

	-- Init helper dll for Async state
	IEex_DllCall("IEexHelper", "ExposeFunctions", {IEex_Label("_g_lua_async")}, nil, 0x0)

	-- Note async thread id
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
	IEex_WriteByte(IEex_ReadDword(asyncSharedMemory), 0x1)

end
