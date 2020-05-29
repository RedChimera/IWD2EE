level_cap = 30
xp_cap = 528000

IEex_DisableCodeProtection()

IEex_WriteByte(0x543895, level_cap)
IEex_WriteByte(0x54389B, level_cap)
IEex_WriteByte(0x5DCD4A, level_cap)
IEex_WriteDword(0x544C71, xp_cap)

IEex_EnableCodeProtection()