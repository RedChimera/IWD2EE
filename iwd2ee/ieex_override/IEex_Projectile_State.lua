
function IEex_AddTypeMutatorGlobal(func_name, func)
	IEex_Helper_SynchronizedBridgeOperation("IEex_TypeMutatorGlobalFunctions", function()
		IEex_AppendBridgeNL("IEex_TypeMutatorGlobalFunctions", funcName)
	end)
end

function IEex_AddTypeMutatorOpcode(func_name, func)
	IEex_Helper_SynchronizedBridgeOperation("IEex_TypeMutatorOpcodeFunctions", function()
		IEex_AppendBridgeNL("IEex_TypeMutatorOpcodeFunctions", funcName)
	end)
end

function IEex_AddProjectileMutatorGlobal(func_name, func)
	IEex_Helper_SynchronizedBridgeOperation("IEex_ProjectileMutatorGlobalFunctions", function()
		IEex_AppendBridgeNL("IEex_ProjectileMutatorGlobalFunctions", funcName)
	end)
end

function IEex_AddProjectileMutatorOpcode(func_name, func)
	IEex_Helper_SynchronizedBridgeOperation("IEex_ProjectileMutatorOpcodeFunctions", function()
		IEex_AppendBridgeNL("IEex_ProjectileMutatorOpcodeFunctions", funcName)
	end)
end

function IEex_AddEffectMutatorGlobal(func_name, func)
	IEex_Helper_SynchronizedBridgeOperation("IEex_EffectMutatorGlobalFunctions", function()
		IEex_AppendBridgeNL("IEex_EffectMutatorGlobalFunctions", funcName)
	end)
end

function IEex_AddEffectMutatorOpcode(func_name, func)
	IEex_Helper_SynchronizedBridgeOperation("IEex_EffectMutatorOpcodeFunctions", function()
		IEex_AppendBridgeNL("IEex_EffectMutatorOpcodeFunctions", funcName)
	end)
end

--[[
--]]
--[[
IEex_AddProjectileMutatorGlobal("EXLINEFR", function(source, creatureData, projectileData)
	if IEex_IsProjectileOfType(projectileData, IEex_ProjectileType.CProjectileNewScorcher) and bit.band(IEex_ReadDword(projectileData + 0x120), 0x10000) > 0 then
		local effectRepeatTime = IEex_ReadWord(projectileData + 0x140, 0x0)
		IEex_WriteDword(projectileData + 0x3B0, effectRepeatTime)
	end
end)
--]]

IEex_ProjectileHookSource = {
	["SPELL"] = 0,
	["SPELL_POINT"] = 1,
	["FORCE_SPELL"] = 2,
	["FORCE_SPELL_POINT"] = 3,
	["FORCE_SPELL_OPCODE_430"] = 5,
	["MAGIC_MISSILE_PROJECTILE"] = 7,
	["EXPLOSION_PROJECTILE"] = 8,
	["RANGED_ATTACK_START"] = 11,
	["RANGED_ATTACK"] = 12,
	["USE_ITEM"] = 13,
	["USE_ITEM_POINT"] = 14,
}

IEex_DecodeProjectileSources = {
	[7611576] = IEex_ProjectileHookSource.SPELL,
	[7619492] = IEex_ProjectileHookSource.SPELL_POINT,
	[4592754] = IEex_ProjectileHookSource.FORCE_SPELL,
	[4595985] = IEex_ProjectileHookSource.FORCE_SPELL_POINT,
	[5679025] = IEex_ProjectileHookSource.FORCE_SPELL_OPCODE_430,
	[5442248] = IEex_ProjectileHookSource.MAGIC_MISSILE_PROJECTILE,
	[5702379] = IEex_ProjectileHookSource.EXPLOSION_PROJECTILE,
	[7577720] = IEex_ProjectileHookSource.RANGED_ATTACK_START,
	[7579961] = IEex_ProjectileHookSource.RANGED_ATTACK,
	[7630694] = IEex_ProjectileHookSource.USE_ITEM,
	[7633682] = IEex_ProjectileHookSource.USE_ITEM_POINT,
}

IEex_AddEffectToProjectileSources = {
	[5368489] = IEex_ProjectileHookSource.SPELL,
	[5443315] = IEex_ProjectileHookSource.MAGIC_MISSILE_PROJECTILE,
	[5443485] = IEex_ProjectileHookSource.MAGIC_MISSILE_PROJECTILE,
}

--[[
I'm not sure how closely these correspond to the actual projectile types in IWD2; 
 these are just my guesses of the different types. 
0: No Projectile
1: Single Target
2: Pillar
3: Magic Missile
4: Passes Through Target
5: Passes Through Target, Bounces Off Walls
6: Area of Effect
7: Cone
8: Skull Trap
9: Agannazar's Scorcher
10: Call Lightning Chain
11: Wall
12: Spiritual Wrath
13: Travel Door
14: Cow
15: Chain Lightning
16: Whirlwind
--]]
IEex_ProjectileType = {
[0] = 0, [1] = 0, [2] = 1, [3] = 6, [4] = 1, [5] = 1, [6] = 1, [7] = 1, [8] = 6, [9] = 1, [10] = 1, [11] = 1, [12] = 1, [13] = 6, [14] = 1, [15] = 1, [16] = 1, [17] = 1, [18] = 6, [19] = 1,
[20] = 1, [21] = 1, [22] = 7, [23] = 2, [24] = 1, [25] = 7, [26] = 7, [27] = 1, [28] = 6, [29] = 1, [30] = 1, [31] = 1, [32] = 1, [33] = 6, [34] = 1, [35] = 1, [36] = 1, [37] = 1, [38] = 6, [39] = 1, 
[40] = 5, [41] = 1, [42] = 6, [43] = 1, [44] = 1, [45] = 1, [46] = 1, [47] = 1, [48] = 1, [49] = 1, [50] = 1, [51] = 1, [52] = 1, [53] = 1, [54] = 1, [55] = 1, [56] = 1, [57] = 6, [58] = 1, [59] = 1, 
[60] = 1, [61] = 1, [62] = 1, [63] = 6, [64] = 1, [65] = 1, [66] = 2, [67] = 6, [68] = 1, [69] = 3, [70] = 3, [71] = 3, [72] = 3, [73] = 3, [74] = 3, [75] = 3, [76] = 3, [77] = 3, [78] = 3, [79] = 1, 
[80] = 6, [81] = 10, [82] = 10, [83] = 10, [84] = 10, [85] = 10, [86] = 10, [87] = 10, [88] = 10, [89] = 10, [90] = 10, [91] = 10, [92] = 6, [93] = 6, [94] = 6, [95] = 6, [96] = 8, [97] = 7, [98] = 6, [99] = 11, 
[100] = 8, [101] = 6, [102] = 1, [103] = 1, [104] = 1, [105] = 1, [106] = 1, [107] = 6, [108] = 1, [109] = 9, 
[110] = 13, [111] = 1, [112] = 1, [113] = 1, [114] = 1, [115] = 1, [116] = 1, [117] = 1, [118] = 1, [119] = 1, 
[120] = 1, [121] = 1, [122] = 1, [123] = 1, [124] = 1, [125] = 1, [126] = 1, [127] = 1, [128] = 1, [129] = 1, 
[130] = 1, [131] = 1, [132] = 1, [133] = 1, [134] = 1, [135] = 1, [136] = 1, [137] = 1, [138] = 1, [139] = 1, 
[140] = 1, [141] = 1, [142] = 1, [143] = 1, [144] = 1, [145] = 1, [146] = 1, [147] = 1, [148] = 1, [149] = 6, 
[150] = 6, [151] = 6, [152] = 6, [153] = 6, [154] = 6, [155] = 6, [156] = 6, [157] = 6, [158] = 6, [159] = 6, 
[160] = 6, [161] = 6, [162] = 6, [163] = 6, [164] = 6, [165] = 6, [166] = 6, [167] = 6, [168] = 6, [169] = 6, 
[170] = 6, [171] = 6, [172] = 6, [173] = 6, [174] = 6, [175] = 6, [176] = 6, [177] = 6, [178] = 6, [179] = 6, 
[180] = 6, [181] = 6, [182] = 6, [183] = 6, [184] = 1, [185] = 1, [186] = 6, [187] = 6, [188] = 1, [189] = 14, 
[190] = 6, [191] = 1, [192] = 1, [193] = 1, [194] = 1, [195] = 2, [196] = 6, [197] = 6, [198] = 6, [199] = 6, 
[200] = 6, [201] = 6, [202] = 6, [203] = 6, [204] = 6, [205] = 6, [206] = 5, [207] = 4, [208] = 1, [209] = 6,
[210] = 15, [211] = 6, [212] = 6, [213] = 6, [214] = 6, [215] = 6, [216] = 6, [217] = 6, [218] = 1, [219] = 1,
[220] = 1, [221] = 1, [222] = 1, [223] = 1, [224] = 1, [225] = 1, [226] = 1, [227] = 1, [228] = 1, [229] = 1,
[230] = 1, [231] = 1, [232] = 1, [233] = 1, [234] = 1, [235] = 6, [236] = 6, [237] = 6, [238] = 6, [239] = 6,
[240] = 6, [241] = 6, [242] = 6, [243] = 6, [244] = 6, [245] = 6, [246] = 6, [247] = 1, [248] = 6, [249] = 6,
[250] = 6, [251] = 1, [252] = 6, [253] = 6, [254] = 6, [255] = 6, [256] = 6, [257] = 6, [258] = 6, [259] = 6,
[260] = 1, [261] = 1, [262] = 1, [263] = 6, [264] = 6, [265] = 1, [266] = 6, [267] = 6, [268] = 1, [269] = 1,
[270] = 6, [271] = 1, [272] = 7, [273] = 6, [274] = 6, [275] = 6, [276] = 6, [277] = 6, [278] = 6, [279] = 6,
[280] = 6, [281] = 6, [282] = 6, [283] = 6, [284] = 6, [285] = 1, [286] = 6, [287] = 6, [288] = 6, [289] = 1,
[290] = 1, [291] = 1, [292] = 1, [293] = 1, [294] = 1, [295] = 6, [296] = 7, [297] = 1, [298] = 1, [299] = 6,
[300] = 6, [301] = 6, [302] = 4, [303] = 1, [304] = 1, [305] = 16, [306] = 6, [307] = 6, [308] = 6, [309] = 6,
[310] = 6, [311] = 6, [312] = 12, [313] = 4, [314] = 1, [315] = 7, [316] = 1, [317] = 6, [318] = 6, [319] = 7,
[320] = 6, [321] = 6, [322] = 6, [323] = 6, [324] = 1, [325] = 3, [326] = 3, [327] = 3, [328] = 3, [329] = 3,
[330] = 3, [331] = 3, [332] = 3, [333] = 3, [334] = 3, [335] = 6, [336] = 6, [337] = 6, [338] = 6, [339] = 6,
[340] = 6, [341] = 6, [342] = 6, [343] = 7, [344] = 1, [345] = 3, [346] = 1, [347] = 1, [348] = 1, [349] = 6,
[350] = 1, [351] = 6, [352] = 1, [353] = 1, [354] = 1, [355] = 1, [356] = 1, [357] = 6, [358] = 6, [359] = 6,
[360] = 8, [361] = 1, [362] = 6, [363] = 6, [364] = 6, [365] = 6, [366] = 6, [367] = 6, [368] = 7, [369] = 6,
[370] = 11, [371] = 6, [372] = 6, [373] = 6, [374] = 7, [375] = 1, [376] = 6, [377] = 6, [378] = 1, [379] = 7,
[380] = 5, [381] = 6, [382] = 7, [383] = 4, [384] = 6, [385] = 6, [386] = 7,
}

function IEex_Extern_OnProjectileDecode(esp)

	IEex_AssertThread(IEex_Thread.Async)
	local newProjectile = -1
	local missileIndex = IEex_ReadWord(esp + 0x4, 0)
	local generalProjectileType = IEex_ProjectileType[missileIndex]
	local source = IEex_DecodeProjectileSources[IEex_ReadDword(esp)]
	if source == nil then return end
	local CGameAIBase = IEex_ReadDword(esp + 0x8)
	local originalMissileIndex = missileIndex
	if source == 8 then
		originalMissileIndex = IEex_ReadWord(IEex_ReadDword(esp + 0x10) + 0x6E, 0x0)
		CGameAIBase = IEex_ReadDword(esp + 0x20)
	end
	local sourceID = IEex_GetActorIDShare(CGameAIBase)
	if IEex_GetActorSpellState(sourceID, 251) then
		local mutatorOpcodeList = {}
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if theopcode == 288 and theparameter2 == 251 and bit.band(thesavingthrow, 0x2000) == 0 then
				mutatorOpcodeList[IEex_ReadLString(eData + 0x30, 8)] = eData + 0x4
			end
		end)
		IEex_Helper_SynchronizedBridgeOperation("IEex_TypeMutatorOpcodeFunctions", function()
			IEex_Helper_ReadDataFromBridgeNL("IEex_TypeMutatorOpcodeFunctions")
			local limit = #IEex_TypeMutatorOpcodeFunctions
			for i = 1, limit, 1 do
				local originatingEffectData = mutatorOpcodeList[IEex_TypeMutatorOpcodeFunctions[i]]
				if originatingEffectData ~= nil then
					_G[IEex_TypeMutatorOpcodeFunctions[i]](source, originatingEffectData, CGameAIBase, missileIndex)
				end
			end
		end)
	end
	IEex_Helper_SynchronizedBridgeOperation("IEex_TypeMutatorGlobalFunctions", function()
		IEex_Helper_ReadDataFromBridgeNL("IEex_TypeMutatorGlobalFunctions")
		local limit = #IEex_TypeMutatorGlobalFunctions
		for i = 1, limit, 1 do
			_G[IEex_TypeMutatorGlobalFunctions[i]](source, CGameAIBase, missileIndex)
		end
	end)

	if IEex_GetActorSpellState(sourceID, 246) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 246 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				local thecondition = IEex_ReadWord(eData + 0x48, 0x0)
				local thelimit = IEex_ReadWord(eData + 0x4A, 0x0)
				if (bit.band(thesavingthrow, 0x10000) == 0 or thecondition + 1 == originalMissileIndex) and (bit.band(thesavingthrow, 0x20000) == 0 or thecondition == generalProjectileType) and (bit.band(thesavingthrow, 0x40000) == 0 or thecondition == source) and (bit.band(thesavingthrow, 0x80000) == 0 or thelimit > 0) then
					if bit.band(thesavingthrow, 0x4000000) > 0 then
						newProjectile = theparameter1
						if bit.band(thesavingthrow, 0x80000) > 0 then
							thelimit = thelimit - 1
							IEex_WriteWord(eData + 0x4A, thelimit)
						end
					end
				end
			end
		end)
	end
	if newProjectile ~= -1 then
		IEex_WriteWord(esp + 0x4, newProjectile + 1)
	end
end

function IEex_Extern_OnPostProjectileCreation(CProjectile, esp)

	IEex_AssertThread(IEex_Thread.Async)
	
	local missileIndex = IEex_ReadWord(esp + 0x4, 0)
	local generalProjectileType = IEex_ProjectileType[missileIndex]
	local source = IEex_DecodeProjectileSources[IEex_ReadDword(esp)]
	if source == nil then return end
	local CGameAIBase = IEex_ReadDword(esp + 0x8)
	local originalMissileIndex = missileIndex
	if source == 5 then
		CGameAIBase = IEex_ReadDword(esp + 0x20)
	elseif source == 7 then
		CGameAIBase = IEex_ReadDword(esp + 0x18)
	elseif source == 8 then
		originalMissileIndex = IEex_ReadWord(IEex_ReadDword(esp + 0x10) + 0x6E, 0x0) + 1
		CGameAIBase = IEex_ReadDword(esp + 0xDC)
	end
	local sourceID = IEex_GetActorIDShare(CGameAIBase)

	if IEex_GetActorSpellState(sourceID, 251) then
		local mutatorOpcodeList = {}
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if theopcode == 288 and theparameter2 == 251 and bit.band(thesavingthrow, 0x4000) == 0 then
				mutatorOpcodeList[IEex_ReadLString(eData + 0x30, 8)] = eData + 0x4
			end
		end)
		IEex_Helper_SynchronizedBridgeOperation("IEex_ProjectileMutatorOpcodeFunctions", function()
			IEex_Helper_ReadDataFromBridgeNL("IEex_ProjectileMutatorOpcodeFunctions")
			local limit = #IEex_ProjectileMutatorOpcodeFunctions
			for i = 1, limit, 1 do
				local originatingEffectData = mutatorOpcodeList[IEex_ProjectileMutatorOpcodeFunctions[i]]
				if originatingEffectData ~= nil then
					_G[IEex_ProjectileMutatorOpcodeFunctions[i]](source, originatingEffectData, CGameAIBase, CProjectile)
				end
			end
		end)
	end
	IEex_Helper_SynchronizedBridgeOperation("IEex_ProjectileMutatorGlobalFunctions", function()
		IEex_Helper_ReadDataFromBridgeNL("IEex_ProjectileMutatorGlobalFunctions")
		local limit = #IEex_ProjectileMutatorGlobalFunctions
		for i = 1, limit, 1 do
			_G[IEex_ProjectileMutatorGlobalFunctions[i]](source, CGameAIBase, CProjectile)
		end
	end)
	
	if IEex_GetActorSpellState(sourceID, 246) then
		local areaMult = 100
		local rangeMult = 100
		local speedMult = 100
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			
			if theopcode == 288 and theparameter2 == 246 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				local thecondition = IEex_ReadWord(eData + 0x48, 0x0)
				local thelimit = IEex_ReadWord(eData + 0x4A, 0x0)
				if (bit.band(thesavingthrow, 0x10000) == 0 or thecondition + 1 == originalMissileIndex) and (bit.band(thesavingthrow, 0x20000) == 0 or thecondition == generalProjectileType) and (bit.band(thesavingthrow, 0x40000) == 0 or thecondition == source) and (bit.band(thesavingthrow, 0x80000) == 0 or thelimit > 0) then
					if bit.band(thesavingthrow, 0x1000000) > 0 and generalProjectileType >= 6 and generalProjectileType <= 8 then
						areaMult = math.floor(areaMult * theparameter1 / 100)
						if bit.band(thesavingthrow, 0x80000) > 0 then
							thelimit = thelimit - 1
							IEex_WriteWord(eData + 0x4A, thelimit)
						end
					elseif bit.band(thesavingthrow, 0x2000000) > 0 then
						speedMult = math.floor(speedMult * theparameter1 / 100)
						if bit.band(thesavingthrow, 0x80000) > 0 then
							thelimit = thelimit - 1
							IEex_WriteWord(eData + 0x4A, thelimit)
						end
					elseif bit.band(thesavingthrow, 0x8000000) > 0 and generalProjectileType >= 6 and generalProjectileType <= 8 then
						rangeMult = math.floor(rangeMult * theparameter1 / 100)
						if bit.band(thesavingthrow, 0x80000) > 0 then
							thelimit = thelimit - 1
							IEex_WriteWord(eData + 0x4A, thelimit)
						end
					end
				end
			end
		end)
		if areaMult ~= 100 then
			if generalProjectileType == 6 then
				IEex_WriteWord(CProjectile + 0x2AE, math.floor(IEex_ReadWord(CProjectile + 0x2AE, 0x0) * areaMult / 100))
			elseif generalProjectileType == 7 then
				IEex_WriteWord(CProjectile + 0x2CE, math.floor(IEex_ReadWord(CProjectile + 0x2CE, 0x0) * areaMult / 100))
			elseif generalProjectileType == 8 then
				IEex_WriteWord(CProjectile + 0x2A0, math.floor(IEex_ReadWord(CProjectile + 0x2A0, 0x0) * areaMult / 100))
			end
		end
		if speedMult ~= 100 then
			IEex_WriteWord(CProjectile + 0x70, math.floor(IEex_ReadWord(CProjectile + 0x70, 0x0) * speedMult / 100))
		end
		if rangeMult ~= 100 then
			if generalProjectileType == 6 then
				IEex_WriteWord(CProjectile + 0x2B0, math.floor(IEex_ReadWord(CProjectile + 0x2B0, 0x0) * rangeMult / 100))
			elseif generalProjectileType == 7 then
				IEex_WriteWord(CProjectile + 0x2D2, math.floor(IEex_ReadWord(CProjectile + 0x2D2, 0x0) * rangeMult / 100))
			elseif generalProjectileType == 8 then
				IEex_WriteWord(CProjectile + 0x2A2, math.floor(IEex_ReadWord(CProjectile + 0x2A2, 0x0) * rangeMult / 100))
			end
		end
	end
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
