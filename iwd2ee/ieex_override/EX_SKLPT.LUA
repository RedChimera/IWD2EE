--Taken from "Custom DLL Fixes & Changes v1.5.0 by MindChild" (https://sorcerers.net/Games/IWD2/index_editors.php)

--Makes it so you can save more than one skill point for the next level up.

IEex_DisableCodeProtection()

if ex_max_skill_points_saved_for_next_level == -1 then
	IEex_WriteDword(0x5E2155, 0x8B9001B2)
else
	IEex_WriteByte(0x5E2154, ex_max_skill_points_saved_for_next_level)
end

IEex_EnableCodeProtection()