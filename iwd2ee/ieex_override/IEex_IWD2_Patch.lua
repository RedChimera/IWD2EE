
IEex_Normal_Patch_Files = {
	"override/IEex_Core_Patch.lua",
	"override/IEex_Trigger_Patch.lua",
	"override/IEex_Action_Patch.lua",
	"override/IEex_Creature_Patch.lua",
	"override/IEex_Opcode_Patch.lua",
	"override/IEex_Gui_Patch.lua",
	"override/IEex_Render_Patch.lua",
	"override/IEex_Key_Patch.lua",
	"override/IEex_Projectile_Patch.lua",
	"override/IEex_Sound_Patch.lua",
	"override/IEex_LoadTimes_Patch.lua",
	"override/IEex_UncapFPS_Patch.lua",
	"override/IEex_Thread_Patch.lua",
	"override/IEex_MiscFixes_Patch.lua",
	"override/IEex_Debug_Patch.lua",
}

IEex_Vanilla_Patch_Files = {
	"override/IEex_Core_Patch.lua",
	"override/IEex_Gui_Patch.lua",
	"override/IEex_Render_Patch.lua",
	"override/IEex_Key_Patch.lua",
	"override/IEex_LoadTimes_Patch.lua",
	"override/IEex_UncapFPS_Patch.lua",
}

(function()

	for _, filePath in ipairs(not IEex_Vanilla and IEex_Normal_Patch_Files or IEex_Vanilla_Patch_Files) do
		dofile(filePath)
	end

	-- Actually IWD2's "operator_new" and "operator_delete", (needed for IEex memory to interact with engine)
	-- NOTE: THESE NEED TO BE THE LAST LINES EXECUTED DURING INITIAL STARTUP!
	IEex_DefineAssemblyLabel("_malloc", 0x7FC95B)
	IEex_DefineAssemblyLabel("_free", 0x7FC984)

end)()
