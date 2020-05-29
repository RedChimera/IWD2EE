--Taken from "Custom DLL Fixes & Changes v1.5.0 by MindChild" (https://sorcerers.net/Games/IWD2/index_editors.php)

--Disables level adjustment, so aasimar, tieflings, drow, duergar, svirfneblin level up just as fast as other races.

IEex_DisableCodeProtection()

IEex_WriteDword(0x764531, 0x24FF40EB)

IEex_EnableCodeProtection()