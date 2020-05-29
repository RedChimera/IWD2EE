--Taken from "Custom DLL Fixes & Changes v1.5.0 by MindChild" (https://sorcerers.net/Games/IWD2/index_editors.php)

--Makes it so you can save more than one skill point for the next level up.

IEex_DisableCodeProtection()

IEex_WriteDword(0x5E2155, 0x8B9001B2)

IEex_EnableCodeProtection()