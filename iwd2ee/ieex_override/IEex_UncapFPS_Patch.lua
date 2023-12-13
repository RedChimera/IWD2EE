
(function()

	if not IEex_UncapFPS_Enabled then
		return
	end

	IEex_DisableCodeProtection()

	-----------------------------------------------------------------------------------
	-- Unlock FPS                                                                    --
	-----------------------------------------------------------------------------------
	--   Replace the sync and async thread procedures to make the typical game loop: --
	--     1) Handle messages                                                        --
	--     2) Tick the async thread                                                  --
	--     3) Tick the sync thread                                                   --
	--     4) Sleep for a small time                                                 --
	--                                                                               --
	--   This allows the sync thread to run at a high tps while staying aligned      --
	--   with how the engine expects the sync and async threads to interweave.       --
	-----------------------------------------------------------------------------------

	IEex_WriteAssembly(0x7926B0, {"!jmp_dword >IEex_Helper_CChitin_Update"})
	IEex_WriteAssembly(0x4242B0, {"!jmp_dword >IEex_Helper_CBaldurChitin_AsyncThread"})

	-- The engine sometimes intertwines a sync tick with an async tick - for example,
	-- to display the loading screen. It does this by signaling the sync thread
	-- with m_bDisplayStale = 1. The following hooks every instance where the
	-- engine does this to also signal the sync thread's condition variable.

	local signalSyncThread = IEex_WriteAssemblyAuto({[[
		!push_registers_iwd2
		!call >IEex_Helper_SignalSyncThread
		!pop_registers_iwd2
		!ret
	]]})

	IEex_HookAfterRestore(0x429981, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x42DA8C, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x42DBDD, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x42F2CA, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x4318A8, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x433B73, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x43D6B9, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x43DB8E, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x474ED1, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x4FFF7D, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5A00A5, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5A25BE, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5A288F, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5A30FA, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5A3155, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5A832E, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5A89BA, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5A9213, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5A9741, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5AB2A8, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5AB955, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5AC001, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5ACDCC, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5ACF7E, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5C3EF6, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5C3F56, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5C45ED, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5C487B, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5C49B8, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5C4A14, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5C4F21, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5C4F8E, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5C5EE7, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5C6839, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5C6AFF, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5C6C81, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5C6CE1, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5FB533, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5FE3E1, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5FE551, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x5FE5C1, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x60199C, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x601BC1, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x649BAF, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x649CAF, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x64C96C, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x64C9D6, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x64CA30, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x64CC62, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x64D116, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x64D255, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x64D431, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x651BF3, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x6520C6, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x660E93, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x660F94, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x662D3F, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x662DA9, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x662E03, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x66303B, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x66325B, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x663399, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x6634EB, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x666793, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x666C76, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x68DE21, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x69D38F, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x69D3ED, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x69EA1F, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x69F3B0, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x69F675, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x69F80C, 0, 6, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x69F863, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x74BF61, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x74F4AF, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x7830E8, 0, 10, {"!call", {signalSyncThread, 4, 4}})
	IEex_HookAfterRestore(0x78C95B, 0, 10, {"!call", {signalSyncThread, 4, 4}})

	----------------------------------------------------------------------------
	-- Smooth Cursor Drawing                                                  --
	----------------------------------------------------------------------------
	--   Render cursor at true position; cursor logic still updates at 30fps. --
	----------------------------------------------------------------------------

	IEex_HookRestore(0x79FA44, 12, 0, {[[
		!push(eax)
		!sub_esp_byte 08

		!push_esp
		!call >IEex_GetCursorPos

		!push(esp)
		!mov(eax,[8CF6DC])
		!push([eax+94])
		!call_[dword] #847470 ; ScreenToClient ;

		!mov(ebx,[esp])
		!mov(ecx,[esp+4])

		!add_esp_byte 08
		!pop(eax)
	]]})

	IEex_HookRestore(0x79F80F, 6, 0, {[[
		!push(eax)
		!sub_esp_byte 08

		!push_esp
		!call >IEex_GetCursorPos

		!push(esp)
		!mov(eax,[8CF6DC])
		!push([eax+94])
		!call_[dword] #847470 ; ScreenToClient ;

		!mov(ecx,[esp])
		!mov(edx,[esp+4])

		!add_esp_byte 08
		!pop(eax)
	]]})

	IEex_WriteAssembly(0x79F819, {"!repeat(6,!nop)"})

	-------------------------------------------------------------------------------------------------
	-- Smooth Scrolling                                                                            --
	-------------------------------------------------------------------------------------------------
	--   Replace viewport scrolling with implementation that runs on sync thread, (at higher tps). --
	-------------------------------------------------------------------------------------------------

	-- Disable inbuilt keyboard scrolling
	IEex_WriteAssembly(0x4777EF, {"!xor_eax_eax !repeat(4,!nop)"})

	-- Disable inbuilt cursor scrolling
	IEex_WriteAssembly(0x477824, {"!xor_eax_eax !repeat(4,!nop)"})
	IEex_WriteAssembly(0x47784B, {"!xor_edx_edx !repeat(4,!nop)"})

	-- Redirect engine to Lua implementation
	IEex_HookAfterCall(0x5CF0D7, IEex_FlattenTable({[[
		!push_all_registers_iwd2
		]], IEex_GenLuaCall("IEex_Extern_CheckScroll"), [[
		@call_error
		!pop_all_registers_iwd2
	]]}))

	--------------------------------------------------------------------------------------------------------------
	-- Remove unnecessary SleepEx() calls                                                                       --
	--------------------------------------------------------------------------------------------------------------
	--   Slightly speeds up loading. Note that these patches are made here, and not in IEex_LoadTimes_Patch.lua --
	--   because the vanilla game loop deadlocks without these sleep calls.                                     --
	--------------------------------------------------------------------------------------------------------------

	-- CInfGame_GiveUpAreaListsThenYieldToSyncThread()
	IEex_WriteAssembly(0x59FB3C, {"!repeat(6,!nop)"})
	IEex_WriteAssembly(0x59FA95, {"!repeat(6,!nop)"})
	IEex_WriteAssembly(0x59FB0C, {"!repeat(6,!nop)"})

	----------------------------------------------------------------------------------------------
	-- Allow the sync thread to run while the async thread is processing an area fade effect    --
	----------------------------------------------------------------------------------------------
	--   There is a visible stutter in rendering without this patch - for example, when asking  --
	--   Hedron to watch over you rest. It is safe for the sync thread to run in this situation --
	--   because the async thread is just spinning.                                             --
	----------------------------------------------------------------------------------------------

	-- Entering the area fade loop
	IEex_HookJumpOnFail(0x4FFF1F, 7, {[[

		!push_all_registers_iwd2

		; Allow the sync thread to run concurrently with me (the async thread) ;
		!push_byte 01
		!call >IEex_Helper_SetSyncThreadAllowedToRunWithoutSignal

		!pop_all_registers_iwd2
	]]})

	-- Leaving the area fade loop
	IEex_HookReturnNOPs(0x4FFF83, 0, {[[
		;
		  Reimplement the instructions I clobbered. Normally I would use IEex_HookJumpOnFail() here, but there aren't
		  enough bytes after the jump that can be clobbered, (only 4, another instruction jumps to the 5th).
		;
		!call_esi
		!dec_edi
		!jnz_dword :4FFF33

		; Leaving the area fade loop ;

		!push_all_registers_iwd2

		;
		  Disallow the sync thread from running concurrently with me (the async thread)
		  and make sure the sync thread is yielding before I resume
		;
		!call >IEex_Helper_CommandAndWaitForSyncThreadYield

		!pop_all_registers_iwd2
		!jmp_dword :4FFF88
	]]})


	IEex_EnableCodeProtection()

end)()
