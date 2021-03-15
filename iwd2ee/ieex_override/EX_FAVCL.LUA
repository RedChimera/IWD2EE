--Taken from "Custom DLL Fixes & Changes v1.5.0 by MindChild" (https://sorcerers.net/Games/IWD2/index_editors.php)

--Disables favored classes, so all races can multiclass without experience penalties

IEex_DisableCodeProtection()

IEex_WriteDword(0x7645AF, 0xC0E9)
IEex_WriteDword(0x7645B3, 0x33909000)

IEex_EnableCodeProtection()