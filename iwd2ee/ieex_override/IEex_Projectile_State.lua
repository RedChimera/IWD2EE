
function IEex_Extern_OnProjectileDecode(esp)

	IEex_AssertThread(IEex_Thread.Async)

	local wProjectileType = IEex_ReadWord(esp + 0x4, 0)
	local CGameAIBase = IEex_ReadDword(esp + 0x8)
	-- local bFromMessage = IEex_ReadDword(esp + 0xC)

end

function IEex_Extern_OnPostProjectileCreation(CProjectile, esp)

	IEex_AssertThread(IEex_Thread.Async)

	local wProjectileType = IEex_ReadWord(esp + 0x4, 0)
	local CGameAIBase = IEex_ReadDword(esp + 0x8)
	-- local bFromMessage = IEex_ReadDword(esp + 0xC)

end

-- return:
--   false (or nil) -> to allow effect
--   true           -> to block effect
function IEex_Extern_OnAddEffectToProjectile(CProjectile, esp)

	IEex_AssertThread(IEex_Thread.Async)

	local CGameEffect = IEex_ReadDword(esp + 0x4)
	local m_sourceId = IEex_ReadDword(CGameEffect + 0x10C)

	return false

end
