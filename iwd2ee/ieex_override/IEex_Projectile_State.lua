IEex_MutatorOpcodeFunctions = {}
IEex_MutatorGlobalFunctions = {}
--[[

function IEex_AddTypeMutatorGlobal(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_TypeMutatorGlobalFunctions", function()
		IEex_AppendBridgeNL("IEex_TypeMutatorGlobalFunctions", funcName)
	end)
end

function IEex_AddTypeMutatorOpcode(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_TypeMutatorOpcodeFunctions", function()
		IEex_AppendBridgeNL("IEex_TypeMutatorOpcodeFunctions", funcName)
	end)
end

function IEex_AddProjectileMutatorGlobal(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_ProjectileMutatorGlobalFunctions", function()
		IEex_AppendBridgeNL("IEex_ProjectileMutatorGlobalFunctions", funcName)
	end)
end

function IEex_AddProjectileMutatorOpcode(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_ProjectileMutatorOpcodeFunctions", function()
		IEex_AppendBridgeNL("IEex_ProjectileMutatorOpcodeFunctions", funcName)
	end)
end

function IEex_AddEffectMutatorGlobal(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_EffectMutatorGlobalFunctions", function()
		IEex_AppendBridgeNL("IEex_EffectMutatorGlobalFunctions", funcName)
	end)
end

function IEex_AddEffectMutatorOpcode(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_EffectMutatorOpcodeFunctions", function()
		IEex_AppendBridgeNL("IEex_EffectMutatorOpcodeFunctions", funcName)
	end)
end
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
[80] = 6, [81] = 10, [82] = 10, [83] = 10, [84] = 10, [85] = 10, [86] = 10, [87] = 10, [88] = 10, [89] = 10, [90] = 10, [91] = 10, [92] = 6, [93] = 6, [94] = 8, [95] = 6, [96] = 8, [97] = 7, [98] = 6, [99] = 11, 
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
ex_original_projectile = {}
function IEex_Extern_OnProjectileDecode(esp)

	IEex_AssertThread(IEex_Thread.Async)
	local newProjectile = -1
	local missileIndex = IEex_ReadWord(esp + 0x4, 0)
	local generalProjectileType = IEex_ProjectileType[missileIndex]
	local source = IEex_DecodeProjectileSources[IEex_ReadDword(esp)]
	if source == nil then return end
	local CGameAIBase = IEex_ReadDword(esp + 0x8)
--	local originalMissileIndex = missileIndex
	if source == 5 then
		CGameAIBase = IEex_ReadDword(esp + 0x20)
	elseif source == 7 then
		CGameAIBase = IEex_ReadDword(esp + 0x18)
	elseif source == 8 then
		CGameAIBase = IEex_ReadDword(esp + 0xDC)
--[[
		local originalCProjectile = IEex_ReadDword(esp + 0x10)
		if originalCProjectile > 65535 then
			originalMissileIndex = IEex_ReadWord(originalCProjectile + 0x6E, 0x0) + 1
			if CGameAIBase <= 65535 then
				CGameAIBase = IEex_GetActorShare(IEex_ReadDword(originalCProjectile + 0x72))
			end
		end
--]]
	end
	local sourceID = IEex_GetActorIDShare(CGameAIBase)
	local sourceRES = ""
	if (source == 0 or source == 1 or source == 7) and IEex_Helper_GetBridge("IEex_RecordSpell", sourceID, "spellRES") ~= nil then
		sourceRES = IEex_Helper_GetBridge("IEex_RecordSpell", sourceID, "spellRES")
	end
	if IEex_GetActorSpellState(sourceID, 251) then
		local mutatorOpcodeList = {}
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if theopcode == 288 and theparameter2 == 251 and bit.band(thesavingthrow, 0x2000) == 0 then
				table.insert(mutatorOpcodeList, {IEex_ReadLString(eData + 0x30, 8), eData + 0x4})
			end
		end)
		for k, v in ipairs(mutatorOpcodeList) do
			local funcName = v[1]
			if IEex_MutatorOpcodeFunctions[funcName] ~= nil then
				local originatingEffectData = v[2]
				local possibleProjectile = IEex_MutatorOpcodeFunctions[funcName]["typeMutator"](source, originatingEffectData, CGameAIBase, missileIndex, sourceRES)
				if possibleProjectile ~= nil then
					newProjectile = possibleProjectile
				end
			end
		end
	end
	for funcName, funcList in pairs(IEex_MutatorGlobalFunctions) do
		local possibleProjectile = funcList["typeMutator"](source, CGameAIBase, missileIndex, sourceRES)
		if possibleProjectile ~= nil then
			newProjectile = possibleProjectile
		end
	end
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
				if (bit.band(thesavingthrow, 0x10000) == 0 or thecondition + 1 == missileIndex) and (bit.band(thesavingthrow, 0x20000) == 0 or thecondition == generalProjectileType) and (bit.band(thesavingthrow, 0x40000) == 0 or thecondition == source) and (bit.band(thesavingthrow, 0x80000) == 0 or thelimit > 0) then
					if bit.band(thesavingthrow, 0x4000000) > 0 then
						newProjectile = theparameter1 + 1
						if bit.band(thesavingthrow, 0x80000) > 0 and bit.band(thesavingthrow, 0x100000) == 0 then
							thelimit = thelimit - 1
							IEex_WriteWord(eData + 0x4A, thelimit)
						end
					end
				end
			end
		end)
	end
	if newProjectile ~= -1 then
		IEex_WriteWord(esp + 0x4, newProjectile)
	end
end

function IEex_Extern_OnPostProjectileCreation(CProjectile, esp)

	IEex_AssertThread(IEex_Thread.Async)
	
	local missileIndex = IEex_ReadWord(esp + 0x4, 0)
	local generalProjectileType = IEex_ProjectileType[missileIndex]
	local source = IEex_DecodeProjectileSources[IEex_ReadDword(esp)]
	if source == nil then return end
	local CGameAIBase = IEex_ReadDword(esp + 0x8)
--	local originalMissileIndex = missileIndex
	if source == 5 then
		CGameAIBase = IEex_ReadDword(esp + 0x20)
	elseif source == 7 then
		CGameAIBase = IEex_ReadDword(esp + 0x18)
	elseif source == 8 then
		CGameAIBase = IEex_ReadDword(esp + 0xDC)
--[[
		local originalCProjectile = IEex_ReadDword(esp + 0x10)
		if originalCProjectile > 65535 then
			originalMissileIndex = IEex_ReadWord(originalCProjectile + 0x6E, 0x0) + 1
			if CGameAIBase <= 65535 then
				CGameAIBase = IEex_GetActorShare(IEex_ReadDword(originalCProjectile + 0x72))
			end
		end
--]]
	end
	local sourceID = IEex_GetActorIDShare(CGameAIBase)
	local sourceRES = ""
	if (source == 0 or source == 1 or source == 7) and IEex_Helper_GetBridge("IEex_RecordSpell", sourceID, "spellRES") ~= nil then
		sourceRES = IEex_Helper_GetBridge("IEex_RecordSpell", sourceID, "spellRES")
	end

	if IEex_GetActorSpellState(sourceID, 251) then
		local mutatorOpcodeList = {}
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			if theopcode == 288 and theparameter2 == 251 and bit.band(thesavingthrow, 0x4000) == 0 then
				table.insert(mutatorOpcodeList, {IEex_ReadLString(eData + 0x30, 8), eData + 0x4})
			end
		end)
		for k, v in ipairs(mutatorOpcodeList) do
			local funcName = v[1]
			if IEex_MutatorOpcodeFunctions[funcName] ~= nil then
				local originatingEffectData = v[2]
				IEex_MutatorOpcodeFunctions[funcName]["projectileMutator"](source, originatingEffectData, CGameAIBase, CProjectile, sourceRES)
			end
		end
	end
	for funcName, funcList in pairs(IEex_MutatorGlobalFunctions) do
		funcList["projectileMutator"](source, CGameAIBase, CProjectile, sourceRES)
	end
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
				if (bit.band(thesavingthrow, 0x10000) == 0 or thecondition + 1 == missileIndex) and (bit.band(thesavingthrow, 0x20000) == 0 or thecondition == generalProjectileType) and (bit.band(thesavingthrow, 0x40000) == 0 or thecondition == source) and (bit.band(thesavingthrow, 0x80000) == 0 or thelimit > 0) then
					if bit.band(thesavingthrow, 0x1000000) > 0 and generalProjectileType >= 6 and generalProjectileType <= 8 then
						areaMult = math.floor(areaMult * theparameter1 / 100)
						if bit.band(thesavingthrow, 0x80000) > 0 and bit.band(thesavingthrow, 0x100000) == 0 then
							thelimit = thelimit - 1
							IEex_WriteWord(eData + 0x4A, thelimit)
						end
					elseif bit.band(thesavingthrow, 0x2000000) > 0 then
						speedMult = math.floor(speedMult * theparameter1 / 100)
						if bit.band(thesavingthrow, 0x80000) > 0 and bit.band(thesavingthrow, 0x100000) == 0 then
							thelimit = thelimit - 1
							IEex_WriteWord(eData + 0x4A, thelimit)
						end
					elseif bit.band(thesavingthrow, 0x8000000) > 0 and generalProjectileType >= 6 and generalProjectileType <= 8 then
						rangeMult = math.floor(rangeMult * theparameter1 / 100)
						if bit.band(thesavingthrow, 0x80000) > 0 and bit.band(thesavingthrow, 0x100000) == 0 then
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
	local sourceID = IEex_ReadDword(CGameEffect + 0x10C)
	local CGameAIBase = IEex_GetActorShare(sourceID)
	local source = 0
--[[
	local sourceRES = ""
	if (source == 0 or source == 1 or source == 7) and IEex_Helper_GetBridge("IEex_RecordSpell", sourceID, "spellRES") ~= nil then
		sourceRES = IEex_Helper_GetBridge("IEex_RecordSpell", sourceID, "spellRES")
	end
--]]
	local internalFlags = IEex_ReadDword(CGameEffect + 0xC8)
	if bit.band(internalFlags, 0x20) == 0 then
		internalFlags = bit.bor(internalFlags, 0x20)
		IEex_WriteDword(CGameEffect + 0xC8, internalFlags)
		if IEex_ReadDword(CGameEffect + 0xC) == 500 and IEex_ReadLString(CGameEffect + 0x2C, 8) == "METELEFI" and IEex_GetActorSpellState(sourceID, 246) then
			local areaMult = 100
			local missileIndex = IEex_ReadWord(CProjectile + 0x6E, 0x0)
			local generalProjectileType = IEex_ProjectileType[missileIndex]
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
					
				if theopcode == 288 and theparameter2 == 246 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thecondition = IEex_ReadWord(eData + 0x48, 0x0)
					local thelimit = IEex_ReadWord(eData + 0x4A, 0x0)
					if (bit.band(thesavingthrow, 0x10000) == 0 or thecondition + 1 == missileIndex) and (bit.band(thesavingthrow, 0x20000) == 0 or thecondition == generalProjectileType) and (bit.band(thesavingthrow, 0x40000) == 0 or thecondition == source) and (bit.band(thesavingthrow, 0x80000) == 0 or thelimit > 0) then
						if bit.band(thesavingthrow, 0x1000000) > 0 and generalProjectileType >= 6 and generalProjectileType <= 8 then
							areaMult = math.floor(areaMult * theparameter1 / 100)
							if bit.band(thesavingthrow, 0x80000) > 0 and bit.band(thesavingthrow, 0x100000) == 0 then
								thelimit = thelimit - 1
								IEex_WriteWord(eData + 0x4A, thelimit)
							end
						end
					end
				end
			end)
			if areaMult ~= 100 then
				local parameter1 = IEex_ReadDword(CGameEffect + 0x18)
				IEex_WriteDword(CGameEffect + 0x18, math.floor(parameter1 * areaMult / 100))
			end
		end
		if IEex_GetActorSpellState(sourceID, 251) then
			local mutatorOpcodeList = {}
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				if theopcode == 288 and theparameter2 == 251 and bit.band(thesavingthrow, 0x8000) == 0 then
					table.insert(mutatorOpcodeList, {IEex_ReadLString(eData + 0x30, 8), eData + 0x4})
				end
			end)
			for k, v in ipairs(mutatorOpcodeList) do
				local funcName = v[1]
				if IEex_MutatorOpcodeFunctions[funcName] ~= nil then
					local originatingEffectData = v[2]
					IEex_MutatorOpcodeFunctions[funcName]["effectMutator"](source, originatingEffectData, CGameAIBase, CProjectile, CGameEffect)
				end
			end
		end
		for funcName, funcList in pairs(IEex_MutatorGlobalFunctions) do
			funcList["effectMutator"](source, CGameAIBase, CProjectile, CGameEffect)
		end
	end
	return false

end

ex_metamagic_list = {["EXEMPSPL"] = true, ["EXEXTSPL"] = true, ["EXINTSPL"] = true, ["EXIRRSPL"] = true, ["EXMASSPL"] = true, ["EXMAXSPL"] = true, ["EXPERSPL"] = true, ["EXQUISPL"] = true, ["EXSAFSPL"] = true, ["EXWIDSPL"] = true,}
ex_can_use_metamagic = {}
ex_is_first_spell = {}
function EXMETAMA(originatingEffectData, actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	local spellAvailable = false
	ex_quicken_spell[sourceID] = nil
	if actionID == 31 or actionID == 95 or actionID == 113 or actionID == 114 or actionID == 181 or actionID == 191 or actionID == 192 then
		local currentSpellRES = IEex_GetActorSpellRES(sourceID)
		local resWrapper = IEex_DemandRes(currentSpellRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x10000000) > 0 then
				resWrapper:free()
				return
			end
		end
		resWrapper:free()
		local metamagicLevelModifier = 0
		local hasMetamagic = false
		ex_is_first_spell[sourceID] = {}
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			if theopcode == 206 and theresource == "USMM007D" then
				ex_quicken_spell[sourceID] = false
			end
		end)
		local metamagicInUse = {}
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local thespecial = IEex_ReadDword(eData + 0x48)
			if theopcode == 288 and theparameter2 == 251 and ex_metamagic_list[theresource] ~= nil and thespecial ~= 0 then
				if theresource == "EXQUISPL" then
					if ex_quicken_spell[sourceID] ~= false then
						metamagicLevelModifier = metamagicLevelModifier + theparameter1
						metamagicInUse[theresource] = theparameter1
						hasMetamagic = true
						ex_quicken_spell[sourceID] = true
						if thespecial > 0 then
							IEex_WriteDword(eData + 0x48, thespecial - 1)
						end
					end
				else
					metamagicLevelModifier = metamagicLevelModifier + theparameter1
					hasMetamagic = true
					metamagicInUse[theresource] = theparameter1
				end
			end
		end)
		if hasMetamagic and IEex_GetActorSpellState(sourceID, 240) then
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				local thespecial = IEex_ReadDword(eData + 0x48)
				if theopcode == 288 and theparameter2 == 240 and (theresource == "" or metamagicInUse[theresource] ~= nil) then
					local metamagicCostReduction = theparameter1
					if metamagicInUse[theresource] ~= nil then
						if metamagicCostReduction > metamagicInUse[theresource] then
							metamagicCostReduction = metamagicInUse[theresource]
						end
						metamagicInUse[theresource] = metamagicInUse[theresource] - metamagicCostReduction
					end
					if metamagicCostReduction > metamagicLevelModifier then
						metamagicCostReduction = metamagicLevelModifier
					end
					metamagicLevelModifier = metamagicLevelModifier - metamagicCostReduction
				end
			end)
		end
		local casterClass = IEex_ReadByte(creatureData + 0x530, 0x0)
		local casterType = IEex_CasterClassToType[casterClass]
		local casterTypes = {}
		if casterType ~= nil then
			table.insert(casterTypes, casterType)
			if casterType == 2 then
				table.insert(casterTypes, 8)
			end
		end
		local classSpellLevel = IEex_ReadByte(creatureData + 0x534, 0x0)
		local newSpellLevel = classSpellLevel + metamagicLevelModifier
		local spells = IEex_FetchSpellInfo(sourceID, casterTypes)
		local noSpellsFound = true
		if hasMetamagic and classSpellLevel > 0 and newSpellLevel <= 9 then
			for i = newSpellLevel, 9, 1 do
				for cType, levelList in pairs(spells) do
					if #levelList >= i then
						local levelI = levelList[i]
						local maxCastable = levelI[1]
						local sorcererCastableCount = levelI[2]
						local levelISpells = levelI[3]
						if #levelISpells > 0 then
							noSpellsFound = false
							for i2, spell in ipairs(levelISpells) do
								if not spellAvailable then
									if cType == 1 or cType == 6 then
										if sorcererCastableCount > 0 then
											spellAvailable = true
											ex_can_use_metamagic[sourceID] = {currentSpellRES, classSpellLevel, i, casterClass}
										end
									else
										if spell["castableCount"] > 0 then
											spellAvailable = true
											ex_can_use_metamagic[sourceID] = {currentSpellRES, classSpellLevel, i, casterClass}
										end
									end
								end
							end
						end
					end
				end
			end
			if noSpellsFound then
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_55491,
["source_target"] = sourceID,
["source_id"] = sourceID,
})
			elseif not spellAvailable then
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_55492,
["source_target"] = sourceID,
["source_id"] = sourceID,
})
			end
		elseif newSpellLevel > 9 then
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_55493,
["source_target"] = sourceID,
["source_id"] = sourceID,
})
		end
	end
	if spellAvailable and ex_quicken_spell[sourceID] then
		local castCounter = IEex_ReadSignedWord(creatureData + 0x54E8, 0x0)
		if castCounter ~= -1 then
			ex_quicken_spell[sourceID] = nil
		end

		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 189,
["target"] = 2,
["timing"] = 0,
["duration"] = 1,
["parameter1"] = 30,
["parent_resource"] = "USMM007D",
["source_target"] = sourceID,
["source_id"] = sourceID,
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 188,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["parameter2"] = 1,
["parent_resource"] = "USMM007E",
["source_target"] = sourceID,
["source_id"] = sourceID,
})
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 206,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["resource"] = "USMM007D",
["parent_resource"] = "USMM007F",
["source_target"] = sourceID,
["source_id"] = sourceID,
})
	else
		IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USMM007D",
["source_target"] = sourceID,
["source_id"] = sourceID,
})
	end
	if not spellAvailable then
		ex_can_use_metamagic[sourceID] = nil
	end
end

IEex_AddActionHookOpcode("EXMETAMA")

function EXMETALV(effectData, creatureData)
	IEex_WriteDword(effectData + 0x110, 0x1)
	local targetID = IEex_GetActorIDShare(creatureData)
	if not IEex_IsSprite(targetID, false) then return end
	if not ex_quicken_spell[targetID] then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = "USMM007E",
["source_target"] = targetID,
["source_id"] = targetID,
})
	end
	if ex_can_use_metamagic[targetID] == nil then return end
	local currentSpellRES = ex_can_use_metamagic[targetID][1]
	local originalSpellLevel = ex_can_use_metamagic[targetID][2]
	local newSpellLevel = ex_can_use_metamagic[targetID][3]
	if originalSpellLevel == newSpellLevel then return end
	local casterClass = ex_can_use_metamagic[targetID][4]
	local savingthrow = 0
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = 1,
["parameter2"] = originalSpellLevel,
["special"] = originalSpellLevel,
["savingthrow"] = 0x2000000,
["resource"] = "EXMODMEM",
["vvcresource"] = currentSpellRES,
["casterlvl"] = 1 + casterClass * 0x100,
["source_target"] = targetID,
["source_id"] = targetID,
})
	IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = -1,
["parameter2"] = newSpellLevel,
["special"] = newSpellLevel,
["savingthrow"] = 0,
["resource"] = "EXMODMEM",
["casterlvl"] = 1 + casterClass * 0x100,
["source_target"] = targetID,
["source_id"] = targetID,
})
end

ex_empower_spell = {}
IEex_MutatorOpcodeFunctions["EXEMPSPL"] = {
    ["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)

    end,
    ["projectileMutator"] = function(source, originatingEffectData, creatureData, projectileData, sourceRES)
		local resWrapper = IEex_DemandRes(sourceRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C, 0x0) >= 1 and IEex_ReadWord(spellData + 0x1C, 0x0) <= 2 then
				local actorID = IEex_GetActorIDShare(creatureData)
				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
		    	if ex_can_use_metamagic[actorID] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_empower_spell[actorID] = nil
					end
			    	if source <= 3 or ((source == 5 or source == 6) and ex_is_first_spell[actorID]["EXEMPSPL"] == nil) then
			    		ex_is_first_spell[actorID]["EXEMPSPL"] = true
			    	    if special ~= 0 then
							ex_empower_spell[actorID] = 0
							if special > 0 then
								IEex_WriteDword(originatingEffectData + 0x44, special - 1)
							end
						else
							ex_empower_spell[actorID] = nil
						end
			    	end
			    	if source >= 11 then
			    		ex_empower_spell[actorID] = nil
			    	end
					if source ~= 4 and source < 11 and ex_empower_spell[actorID] ~= nil then
						ex_empower_spell[actorID] = 1
					end
				else
					ex_empower_spell[actorID] = nil
				end
			end
		end
		resWrapper:free()
	end,
    ["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
		local actorID = IEex_GetActorIDShare(creatureData)
		if ex_empower_spell[actorID] == 1 then
			local internalFlags = IEex_ReadDword(effectData + 0xC8)
			internalFlags = bit.bor(internalFlags, 0x100000)
			IEex_WriteDword(effectData + 0xC8, internalFlags)
		end
    end,
}

ex_extend_spell = {}
IEex_MutatorOpcodeFunctions["EXEXTSPL"] = {
    ["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)

    end,
    ["projectileMutator"] = function(source, originatingEffectData, creatureData, projectileData, sourceRES)
		local resWrapper = IEex_DemandRes(sourceRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C, 0x0) >= 1 and IEex_ReadWord(spellData + 0x1C, 0x0) <= 2 then
				local actorID = IEex_GetActorIDShare(creatureData)
				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
		    	if ex_can_use_metamagic[actorID] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_extend_spell[actorID] = nil
					end
			    	if source <= 3 or ((source == 5 or source == 6) and ex_is_first_spell[actorID]["EXEXTSPL"] == nil) then
			    		ex_is_first_spell[actorID]["EXEXTSPL"] = true
			    	    if special ~= 0 then
							ex_extend_spell[actorID] = 0
							if special > 0 then
								IEex_WriteDword(originatingEffectData + 0x44, special - 1)
							end
						else
							ex_extend_spell[actorID] = nil
						end
			    	end
			    	if source >= 11 then
			    		ex_extend_spell[actorID] = nil
			    	end
					if source ~= 4 and source < 11 and ex_extend_spell[actorID] ~= nil then
						ex_extend_spell[actorID] = 1
					end
				else
					ex_extend_spell[actorID] = nil
				end
			end
		end
		resWrapper:free()
	end,
    ["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
		local actorID = IEex_GetActorIDShare(creatureData)
		if ex_extend_spell[actorID] == 1 then
			local internalFlags = IEex_ReadDword(effectData + 0xC8)
			internalFlags = bit.bor(internalFlags, 0x20000)
			IEex_WriteDword(effectData + 0xC8, internalFlags)
		end
    end,
}

ex_mass_spell = {}
IEex_MutatorOpcodeFunctions["EXMASSPL"] = {
    ["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)
		local resWrapper = IEex_DemandRes(sourceRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C, 0x0) >= 1 and IEex_ReadWord(spellData + 0x1C, 0x0) <= 2 then
				local actorID = IEex_GetActorIDShare(creatureData)
				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
		    	if ex_can_use_metamagic[actorID] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_mass_spell[actorID] = nil
					end
			    	if source <= 3 or ((source == 5 or source == 6) and ex_is_first_spell[actorID]["EXMASSPL"] == nil) then
			    		ex_is_first_spell[actorID]["EXMASSPL"] = true
			    	    if special ~= 0 then
							ex_mass_spell[actorID] = 0
							if special > 0 then
								IEex_WriteDword(originatingEffectData + 0x44, special - 1)
							end
						else
							ex_mass_spell[actorID] = nil
						end
			    	end
			    	if source >= 11 then
			    		ex_mass_spell[actorID] = nil
			    	end
					if source ~= 4 and source < 11 and ex_mass_spell[actorID] ~= nil then
						return 94
					end
				else
					ex_mass_spell[actorID] = nil
				end
			end
		end
		resWrapper:free()
    end,
    ["projectileMutator"] = function(source, originatingEffectData, creatureData, projectileData, sourceRES)

	end,
    ["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
    end,
}

ex_maximize_spell = {}
IEex_MutatorOpcodeFunctions["EXMAXSPL"] = {
    ["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)

    end,
    ["projectileMutator"] = function(source, originatingEffectData, creatureData, projectileData, sourceRES)
		local resWrapper = IEex_DemandRes(sourceRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C, 0x0) >= 1 and IEex_ReadWord(spellData + 0x1C, 0x0) <= 2 then
				local actorID = IEex_GetActorIDShare(creatureData)
				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
		    	if ex_can_use_metamagic[actorID] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_maximize_spell[actorID] = nil
					end
			    	if source <= 3 or ((source == 5 or source == 6) and ex_is_first_spell[actorID]["EXMAXSPL"] == nil) then
			    		ex_is_first_spell[actorID]["EXMAXSPL"] = true
			    	    if special ~= 0 then
							ex_maximize_spell[actorID] = 0
							if special > 0 then
								IEex_WriteDword(originatingEffectData + 0x44, special - 1)
							end
						else
							ex_maximize_spell[actorID] = nil
						end
			    	end
			    	if source >= 11 then
			    		ex_maximize_spell[actorID] = nil
			    	end
					if source ~= 4 and source < 11 and ex_maximize_spell[actorID] ~= nil then
						ex_maximize_spell[actorID] = 1
					end
				else
					ex_maximize_spell[actorID] = nil
				end
			end
		end
		resWrapper:free()
	end,
    ["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
		local actorID = IEex_GetActorIDShare(creatureData)
		if ex_maximize_spell[actorID] == 1 then
			local internalFlags = IEex_ReadDword(effectData + 0xC8)
			internalFlags = bit.bor(internalFlags, 0x200000)
			IEex_WriteDword(effectData + 0xC8, internalFlags)
		end
    end,
}

ex_persistent_spell = {}
IEex_MutatorOpcodeFunctions["EXPERSPL"] = {
    ["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)

    end,
    ["projectileMutator"] = function(source, originatingEffectData, creatureData, projectileData, sourceRES)
		local resWrapper = IEex_DemandRes(sourceRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C, 0x0) >= 1 and IEex_ReadWord(spellData + 0x1C, 0x0) <= 2 then
				local actorID = IEex_GetActorIDShare(creatureData)
				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
		    	if ex_can_use_metamagic[actorID] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_persistent_spell[actorID] = nil
					end
			    	if source <= 3 or ((source == 5 or source == 6) and ex_is_first_spell[actorID]["EXPERSPL"] == nil) then
			    		ex_is_first_spell[actorID]["EXPERSPL"] = true
			    	    if special ~= 0 then
							ex_persistent_spell[actorID] = 0
							if special > 0 then
								IEex_WriteDword(originatingEffectData + 0x44, special - 1)
							end
						else
							ex_persistent_spell[actorID] = nil
						end
			    	end
			    	if source >= 11 then
			    		ex_persistent_spell[actorID] = nil
			    	end
					if source ~= 4 and source < 11 and ex_persistent_spell[actorID] ~= nil then
						ex_persistent_spell[actorID] = 1
					end
				else
					ex_persistent_spell[actorID] = nil
				end
			end
		end
		resWrapper:free()
	end,
    ["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
		local actorID = IEex_GetActorIDShare(creatureData)
		if ex_persistent_spell[actorID] == 1 then
			local internalFlags = IEex_ReadDword(effectData + 0xC8)
			internalFlags = bit.bor(internalFlags, 0x10000)
			IEex_WriteDword(effectData + 0xC8, internalFlags)
		end
    end,
}

ex_quicken_spell = {}
IEex_MutatorOpcodeFunctions["EXQUISPL"] = {
    ["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)

    end,
    ["projectileMutator"] = function(source, originatingEffectData, creatureData, projectileData, sourceRES)
	
	end,
    ["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)

    end,
}

ex_safe_spell = {}
IEex_MutatorOpcodeFunctions["EXSAFSPL"] = {
    ["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)

    end,
    ["projectileMutator"] = function(source, originatingEffectData, creatureData, projectileData, sourceRES)
		local resWrapper = IEex_DemandRes(sourceRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C, 0x0) >= 1 and IEex_ReadWord(spellData + 0x1C, 0x0) <= 2 then
				local actorID = IEex_GetActorIDShare(creatureData)
				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
		    	if ex_can_use_metamagic[actorID] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_safe_spell[actorID] = nil
					end
			    	if source <= 3 or ((source == 5 or source == 6) and ex_is_first_spell[actorID]["EXSAFSPL"] == nil) then
			    		ex_is_first_spell[actorID]["EXSAFSPL"] = true
			    	    if special ~= 0 then
							ex_safe_spell[actorID] = 0
							if special > 0 then
								IEex_WriteDword(originatingEffectData + 0x44, special - 1)
							end
						else
							ex_safe_spell[actorID] = nil
						end
			    	end
			    	if source >= 11 then
			    		ex_safe_spell[actorID] = nil
			    	end
					if source ~= 4 and source < 11 and ex_safe_spell[actorID] ~= nil then
						ex_safe_spell[actorID] = 1
					end
				else
					ex_safe_spell[actorID] = nil
				end
			end
		end
		resWrapper:free()
	end,
    ["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
		local actorID = IEex_GetActorIDShare(creatureData)
		if ex_safe_spell[actorID] == 1 then
			local internalFlags = IEex_ReadDword(effectData + 0xC8)
			internalFlags = bit.bor(internalFlags, 0x80000)
			IEex_WriteDword(effectData + 0xC8, internalFlags)
		end
    end,
}

ex_widen_spell = {}
IEex_MutatorOpcodeFunctions["EXWIDSPL"] = {
    ["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)
    
    end,
    ["projectileMutator"] = function(source, originatingEffectData, creatureData, projectileData, sourceRES)
		local actorID = IEex_GetActorIDShare(creatureData)
    	if (source == 11 or source == 12) and IEex_GetActorSpellState(actorID, 246) then
    		local projectileIndex = IEex_ReadWord(projectileData + 0x6E, 0x0)
    		IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local theinternalFlags = IEex_ReadDword(eData + 0xCC)
				if theopcode == 288 and theparameter2 == 246 and bit.band(theinternalFlags, 0x40000) > 0 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thecondition = IEex_ReadWord(eData + 0x48, 0x0)
					local thelimit = IEex_ReadWord(eData + 0x4A, 0x0)
					if (bit.band(thesavingthrow, 0x40000) == 0 or thecondition == source) and (bit.band(thesavingthrow, 0x80000) == 0 or thelimit > 0) then
						if bit.band(thesavingthrow, 0x4000000) > 0 and theparameter1 == projectileIndex then
							local generalProjectileType = IEex_ProjectileType[projectileIndex + 1]
							if generalProjectileType == 6 then
								IEex_WriteWord(projectileData + 0x2AE, math.floor(IEex_ReadWord(projectileData + 0x2AE, 0x0) * 1.5))
							elseif generalProjectileType == 7 then
								IEex_WriteWord(projectileData + 0x2CE, math.floor(IEex_ReadWord(projectileData + 0x2CE, 0x0) * 1.5))
							elseif generalProjectileType == 8 then
								IEex_WriteWord(projectileData + 0x2A0, math.floor(IEex_ReadWord(projectileData + 0x2A0, 0x0) * 1.5))
							end
						end
					end
				end
			end)
    	end
		local resWrapper = IEex_DemandRes(sourceRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C, 0x0) >= 1 and IEex_ReadWord(spellData + 0x1C, 0x0) <= 2 then

				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
		    	if ex_can_use_metamagic[actorID] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_widen_spell[actorID] = nil
					end
			    	if source <= 3 or ((source == 5 or source == 6) and ex_is_first_spell[actorID]["EXWIDSPL"] == nil) then
			    		ex_is_first_spell[actorID]["EXWIDSPL"] = true
			    	    if special ~= 0 then
							ex_widen_spell[actorID] = 0
							if special > 0 then
								IEex_WriteDword(originatingEffectData + 0x44, special - 1)
							end
						else
							ex_widen_spell[actorID] = nil
						end
			    	end
			    	if source >= 11 then
			    		ex_widen_spell[actorID] = nil
			    	end
					if source ~= 4 and source < 11 and ex_widen_spell[actorID] ~= nil then
						ex_widen_spell[actorID] = 1
						local missileIndex = IEex_ReadWord(projectileData + 0x6E, 0x0) + 1
						local generalProjectileType = IEex_ProjectileType[missileIndex]
						if generalProjectileType == 6 then
							IEex_WriteWord(projectileData + 0x2AE, math.floor(IEex_ReadWord(projectileData + 0x2AE, 0x0) * 1.5))
						elseif generalProjectileType == 7 then
							IEex_WriteWord(projectileData + 0x2CE, math.floor(IEex_ReadWord(projectileData + 0x2CE, 0x0) * 1.5))
						elseif generalProjectileType == 8 then
							IEex_WriteWord(projectileData + 0x2A0, math.floor(IEex_ReadWord(projectileData + 0x2A0, 0x0) * 1.5))
						end
					end
				else
					ex_widen_spell[actorID] = nil
				end
			end
		end
		resWrapper:free()
	end,
    ["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
		local actorID = IEex_GetActorIDShare(creatureData)
		if ex_widen_spell[actorID] == 1 then
			local internalFlags = IEex_ReadDword(effectData + 0xC8)
			internalFlags = bit.bor(internalFlags, 0x40000)
			IEex_WriteDword(effectData + 0xC8, internalFlags)
			if IEex_ReadDword(effectData + 0xC) == 500 and IEex_ReadLString(effectData + 0x2C, 8) == "METELEFI" then
				local parameter1 = IEex_ReadDword(effectData + 0x18)
				IEex_WriteDword(effectData + 0x18, math.floor(parameter1 * 1.5))
			end
		end
    end,
}

IEex_MutatorGlobalFunctions["USWI252"] = {
    ["typeMutator"] = function(source, creatureData, missileIndex, sourceRES)

    end,
    ["projectileMutator"] = function(source, creatureData, projectileData, sourceRES)
		if sourceRES == "USWI252" then
			IEex_WriteWord(projectileData + 0x2B2, 314)
		end
	end,
    ["effectMutator"] = function(source, creatureData, projectileData, effectData)
    end,
}

IEex_MutatorGlobalFunctions["USWI858"] = {
    ["typeMutator"] = function(source, creatureData, missileIndex, sourceRES)

    end,
    ["projectileMutator"] = function(source, creatureData, projectileData, sourceRES)
		if sourceRES == "USWI858" and source ~= 8 then
			IEex_WriteWord(projectileData + 0x2B2, 37)
		end
	end,
    ["effectMutator"] = function(source, creatureData, projectileData, effectData)
    end,
}