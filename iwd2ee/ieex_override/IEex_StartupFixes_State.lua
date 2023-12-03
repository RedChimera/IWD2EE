
IEex_AbsoluteOnce("IEex_StartupFixes_Once", function()

	--------------------------------------------------
	-- Detect and fix incorrectly set [Alias] paths --
	--------------------------------------------------

	local hd0Path = IEex_Helper_GetGameDirectory()
	local iniPath = hd0Path.."icewind2.ini"
	IEex_WritePrivateProfileString("Alias", "HD0:", hd0Path, iniPath)

	local cd1Path = hd0Path.."Data\\"
	if IEex_Helper_DirectoryExists(cd1Path) then
		IEex_WritePrivateProfileString("Alias", "CD1:", cd1Path, iniPath)
	end

	local cd2Path = hd0Path.."CD2\\"
	if IEex_Helper_DirectoryExists(cd2Path) then
		IEex_WritePrivateProfileString("Alias", "CD2:", cd2Path, iniPath)
	end

end)
