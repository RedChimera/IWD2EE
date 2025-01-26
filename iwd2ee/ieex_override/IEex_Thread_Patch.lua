
(function()

    IEex_DisableCodeProtection()

    -- Actually WinMain()
    IEex_HookBeforeCall(0x4218F5, {[[
		!push_all_registers_iwd2
        !call >IEex_Helper_OnSyncThreadEntry
        !pop_all_registers_iwd2
	]]})

    IEex_HookBeforeCall(0x5492FA, {[[
		!push_all_registers_iwd2
        !call >IEex_Helper_OnSearchThreadEntry
        !pop_all_registers_iwd2
	]]})

    IEex_HookBeforeCall(0x424263, {[[
		!push_all_registers_iwd2
        !call >IEex_Helper_OnResourceThreadEntry
        !pop_all_registers_iwd2
	]]})

    IEex_HookBeforeCall(0x424184, {[[
		!push_all_registers_iwd2
        !call >IEex_Helper_OnNetworkThreadEntry
        !pop_all_registers_iwd2
	]]})

    IEex_HookBeforeCall(0x424223, {[[
		!push_all_registers_iwd2
        !call >IEex_Helper_OnSoundThreadEntry
        !pop_all_registers_iwd2
	]]})

    -- Must be run after IEex_UncapFPS.lua
	if not IEex_UncapFPS_Enabled then
        IEex_HookBeforeCall(0x4242CE, {[[
            !push_all_registers_iwd2
            !call >IEex_Helper_OnAsyncThreadEntry
            !pop_all_registers_iwd2
        ]]})
	end

    IEex_EnableCodeProtection()

end)()
