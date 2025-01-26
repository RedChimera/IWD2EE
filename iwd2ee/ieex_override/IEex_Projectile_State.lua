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
	["EXPLOSION_PROJECTILE_B"] = 9,
	["EXPLOSION_PROJECTILE_C"] = 10,
	["RANGED_ATTACK_START"] = 11,
	["RANGED_ATTACK"] = 12,
	["RANGED_ATTACK_B"] = 13,
	["RANGED_ATTACK_C"] = 14,
	["USE_ITEM"] = 20,
	["USE_ITEM_POINT"] = 22,
}

IEex_DecodeProjectileSources = {
	[7611576] = IEex_ProjectileHookSource.SPELL,
	[7619492] = IEex_ProjectileHookSource.SPELL_POINT,
	[4592754] = IEex_ProjectileHookSource.FORCE_SPELL,
	[4595985] = IEex_ProjectileHookSource.FORCE_SPELL_POINT,
	[5679025] = IEex_ProjectileHookSource.FORCE_SPELL_OPCODE_430,
	[5442248] = IEex_ProjectileHookSource.MAGIC_MISSILE_PROJECTILE,
	[5702379] = IEex_ProjectileHookSource.EXPLOSION_PROJECTILE,
	[5428946] = IEex_ProjectileHookSource.EXPLOSION_PROJECTILE_B,
	[5707789] = IEex_ProjectileHookSource.EXPLOSION_PROJECTILE_C,
	[7577720] = IEex_ProjectileHookSource.RANGED_ATTACK_START,
	[7579961] = IEex_ProjectileHookSource.RANGED_ATTACK,
	[7580013] = IEex_ProjectileHookSource.RANGED_ATTACK_B,
	[7580609] = IEex_ProjectileHookSource.RANGED_ATTACK_C,
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
[60] = 1, [61] = 1, [62] = 1, [63] = 6, [64] = 6, [65] = 1, [66] = 2, [67] = 6, [68] = 1, [69] = 3, [70] = 3, [71] = 3, [72] = 3, [73] = 3, [74] = 3, [75] = 3, [76] = 3, [77] = 3, [78] = 3, [79] = 1, 
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
[300] = 6, [301] = 6, [302] = 4, [303] = 1, [304] = 11, [305] = 16, [306] = 6, [307] = 6, [308] = 6, [309] = 6,
[310] = 6, [311] = 6, [312] = 12, [313] = 4, [314] = 1, [315] = 7, [316] = 1, [317] = 6, [318] = 6, [319] = 7,
[320] = 6, [321] = 6, [322] = 6, [323] = 6, [324] = 1, [325] = 3, [326] = 3, [327] = 3, [328] = 3, [329] = 3,
[330] = 3, [331] = 3, [332] = 3, [333] = 3, [334] = 3, [335] = 6, [336] = 6, [337] = 6, [338] = 6, [339] = 6,
[340] = 6, [341] = 6, [342] = 6, [343] = 7, [344] = 1, [345] = 3, [346] = 1, [347] = 1, [348] = 1, [349] = 6,
[350] = 1, [351] = 6, [352] = 1, [353] = 1, [354] = 1, [355] = 1, [356] = 1, [357] = 6, [358] = 6, [359] = 6,
[360] = 8, [361] = 1, [362] = 6, [363] = 6, [364] = 6, [365] = 6, [366] = 6, [367] = 6, [368] = 7, [369] = 6,
[370] = 11, [371] = 6, [372] = 6, [373] = 6, [374] = 7, [375] = 1, [376] = 6, [377] = 6, [378] = 1, [379] = 7,
[380] = 5, [381] = 6, [382] = 7, [383] = 4, [384] = 6, [385] = 6, [386] = 7,
}
IEex_ProjectileAOE = {[38] = 200, [64] = 150, [67] = 140, [95] = 100, [96] = 100, [98] = 200, [187] = 150, [190] = 150, 
[209] = 150, [211] = 200, [212] = 150, [214] = 100, [217] = 250, [236] = 250, [246] = 150, [248] = 200, [254] = 300, [255] = 150, [264] = 200, 
[277] = 300, [299] = 120, [317] = 120, [318] = 300, [335] = 250, [336] = 150, [366] = 300, [359] = 300, [360] = 257, [367] = 200, [373] = 200, 
}
ex_original_projectile = {}
ex_projectile_flags = {}
function IEex_Extern_OnProjectileDecode(esp)
	IEex_AssertThread(IEex_Thread.Async)
	local missileIndex = IEex_ReadWord(esp + 0x4)
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
			originalMissileIndex = IEex_ReadWord(originalCProjectile + 0x6E) + 1
			if CGameAIBase <= 65535 then
				CGameAIBase = IEex_GetActorShare(IEex_ReadDword(originalCProjectile + 0x72))
			end
		end
--]]
	end
	local sourceID = IEex_GetActorIDShare(CGameAIBase)
	local sourceRES = ""
	if (source == 0 or source == 1 or source == 2 or source == 3 or source == 7) and IEex_Helper_GetBridge("IEex_RecordSpell", sourceID, "spellRES") ~= nil then
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
					missileIndex = possibleProjectile
				end
			end
		end
	end
	for funcName, funcList in pairs(IEex_MutatorGlobalFunctions) do
		local possibleProjectile = funcList["typeMutator"](source, CGameAIBase, missileIndex, sourceRES)
		if possibleProjectile ~= nil then
			missileIndex = possibleProjectile
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
				local thecondition = IEex_ReadWord(eData + 0x48)
				local thelimit = IEex_ReadWord(eData + 0x4A)
				if (bit.band(thesavingthrow, 0x10000) == 0 or thecondition + 1 == missileIndex) and (bit.band(thesavingthrow, 0x20000) == 0 or thecondition == generalProjectileType) and (bit.band(thesavingthrow, 0x40000) == 0 or thecondition == source) and (bit.band(thesavingthrow, 0x80000) == 0 or thelimit > 0) then
					if bit.band(thesavingthrow, 0x4000000) > 0 then
						missileIndex = theparameter1 + 1
						if bit.band(thesavingthrow, 0x80000) > 0 and bit.band(thesavingthrow, 0x100000) == 0 then
							thelimit = thelimit - 1
							IEex_WriteWord(eData + 0x4A, thelimit)
						end
					end
				end
			end
		end)
	end
--	if newProjectile ~= missileIndex then
		IEex_WriteWord(esp + 0x4, missileIndex)
--	end
end
me_projectile_ptr = 0xDEFA
me_projectile_actor = 0xDEFA
function IEex_Extern_OnPostProjectileCreation(CProjectile, esp)
	IEex_AssertThread(IEex_Thread.Async)
	ex_projectile_flags[CProjectile] = {["Metamagic"] = 0}
	local missileIndex = IEex_ReadWord(esp + 0x4)
	local generalProjectileType = IEex_ProjectileType[missileIndex]
	local source = IEex_DecodeProjectileSources[IEex_ReadDword(esp)]
--	IEex_DS("source ptr: " .. IEex_ReadDword(esp) .. ", missileIndex: " .. missileIndex)
	if source == nil then 
--		IEex_DS("Unknown source ptr: " .. IEex_ReadDword(esp) .. ", missileIndex: " .. missileIndex)
		return
	end
	local CGameAIBase = IEex_ReadDword(esp + 0x8)
--	local originalMissileIndex = missileIndex
--	IEex_DS("CProjectile: " .. CProjectile .. ", source: " .. source)
	if source == 0 or source == 1 then
		me_projectile_ptr = CProjectile
		me_projectile_actor = CGameAIBase
	end
	if source == 5 then
		CGameAIBase = IEex_ReadDword(esp + 0x20)
	elseif source == 7 then
		CGameAIBase = IEex_ReadDword(esp + 0x18)
	elseif source == 8 then
		CGameAIBase = IEex_ReadDword(esp + 0xDC)
		if ex_projectile_flags[IEex_ReadDword(esp + 0x10)] ~= nil then
			ex_projectile_flags[CProjectile]["Metamagic"] = ex_projectile_flags[IEex_ReadDword(esp + 0x10)]["Metamagic"]
		elseif ex_projectile_flags[IEex_ReadDword(esp + 0x14)] ~= nil then
			ex_projectile_flags[CProjectile]["Metamagic"] = ex_projectile_flags[IEex_ReadDword(esp + 0x14)]["Metamagic"]
		end
--[[
		local originalCProjectile = IEex_ReadDword(esp + 0x10)
		if originalCProjectile > 65535 then
			originalMissileIndex = IEex_ReadWord(originalCProjectile + 0x6E) + 1
			if CGameAIBase <= 65535 then
				CGameAIBase = IEex_GetActorShare(IEex_ReadDword(originalCProjectile + 0x72))
			end
		end
--]]
	elseif source == 9 then
--		CGameAIBase = IEex_ReadDword(esp + 0xDC)
		if ex_projectile_flags[IEex_ReadDword(esp + 0x14)] ~= nil then
			ex_projectile_flags[CProjectile]["Metamagic"] = ex_projectile_flags[IEex_ReadDword(esp + 0x14)]["Metamagic"]
		end
--[[
		local originalCProjectile = IEex_ReadDword(esp + 0x10)
		if originalCProjectile > 65535 then
			originalMissileIndex = IEex_ReadWord(originalCProjectile + 0x6E) + 1
			if CGameAIBase <= 65535 then
				CGameAIBase = IEex_GetActorShare(IEex_ReadDword(originalCProjectile + 0x72))
			end
		end
--]]
	elseif source == 10 then
		CGameAIBase = IEex_ReadDword(esp + 0x24)
		if ex_projectile_flags[IEex_ReadDword(esp + 0x1C)] ~= nil then
			ex_projectile_flags[CProjectile]["Metamagic"] = ex_projectile_flags[IEex_ReadDword(esp + 0x1C)]["Metamagic"]
		end
--[[
		local originalCProjectile = IEex_ReadDword(esp + 0x10)
		if originalCProjectile > 65535 then
			originalMissileIndex = IEex_ReadWord(originalCProjectile + 0x6E) + 1
			if CGameAIBase <= 65535 then
				CGameAIBase = IEex_GetActorShare(IEex_ReadDword(originalCProjectile + 0x72))
			end
		end
--]]
	end
	local sourceID = IEex_GetActorIDShare(CGameAIBase)
	local sourceRES = ""
	if (source == 0 or source == 1 or source == 2 or source == 3 or source == 5 or source == 7) and IEex_Helper_GetBridge("IEex_RecordSpell", sourceID, "spellRES") ~= nil then
		sourceRES = IEex_Helper_GetBridge("IEex_RecordSpell", sourceID, "spellRES")
	end
	if source == 5 and IEex_Helper_GetBridge("IEex_RecordOpcode430Spell", sourceID, "spellRES") ~= nil then
		sourceRES = IEex_Helper_GetBridge("IEex_RecordOpcode430Spell", sourceID, "spellRES")
		IEex_WriteLString(CProjectile + 0x18A, sourceRES, 8)
	end
	if IEex_GetActorSpellState(sourceID, 216) then
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			local thespecial = IEex_ReadDword(eData + 0x48)
			if theopcode == 288 then
				if theparameter2 == 182 then
					ex_projectile_flags[CProjectile]["Metamagic"] = bit.bor(ex_projectile_flags[CProjectile]["Metamagic"], 0x400)
				elseif theparameter2 == 216 and thespecial == 2 then
					ex_projectile_flags[CProjectile]["Metamagic"] = bit.bor(ex_projectile_flags[CProjectile]["Metamagic"], 0x800)
				end
			end
		end)
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
		local areaSet = -1
		local durationSet = -1
		local areaMult = 100
		local rangeMult = 100
		local speedMult = 100
		local durationMult = 100
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			
			if theopcode == 288 and theparameter2 == 246 then
				local theparameter1 = IEex_ReadDword(eData + 0x1C)
				local theresource = IEex_ReadLString(eData + 0x30, 8)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				local thecondition = IEex_ReadWord(eData + 0x48)
				local thelimit = IEex_ReadWord(eData + 0x4A)
				if (bit.band(thesavingthrow, 0x10000) == 0 or thecondition + 1 == missileIndex) and (bit.band(thesavingthrow, 0x20000) == 0 or thecondition == generalProjectileType) and (bit.band(thesavingthrow, 0x40000) == 0 or thecondition == source) and (bit.band(thesavingthrow, 0x80000) == 0 or thelimit > 0) then
					if bit.band(thesavingthrow, 0x1000000) > 0 and generalProjectileType >= 6 and generalProjectileType <= 8 then
						if bit.band(thesavingthrow, 0x100) > 0 then
							areaSet = theparameter1
						else
							areaMult = math.floor(areaMult * theparameter1 / 100)
						end
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
					elseif bit.band(thesavingthrow, 0x10000000) > 0 and generalProjectileType == 6 then
						if bit.band(thesavingthrow, 0x100) > 0 then
							durationSet = theparameter1
						else
							durationMult = math.floor(durationMult * theparameter1 / 100)
						end
						if bit.band(thesavingthrow, 0x80000) > 0 and bit.band(thesavingthrow, 0x100000) == 0 then
							thelimit = thelimit - 1
							IEex_WriteWord(eData + 0x4A, thelimit)
						end
					elseif bit.band(thesavingthrow, 0x20000000) > 0 then
						if IEex_ReadDword(CProjectile + 0x192) > 0 then
							IEex_WriteDword(IEex_ReadDword(CProjectile + 0x192) + 0xD6, 1)
						end
						if bit.band(thesavingthrow, 0x80000) > 0 and bit.band(thesavingthrow, 0x100000) == 0 then
							thelimit = thelimit - 1
							IEex_WriteWord(eData + 0x4A, thelimit)
						end
					end
				end
			end
		end)
		if areaSet ~= -1 then
			if generalProjectileType == 6 then
				IEex_WriteWord(CProjectile + 0x2AE, areaSet)
			elseif generalProjectileType == 7 then
				IEex_WriteWord(CProjectile + 0x2CE, areaSet)
			elseif generalProjectileType == 8 then
				IEex_WriteWord(CProjectile + 0x2A0, areaSet)
			end
		end
		if areaMult ~= 100 then
			if generalProjectileType == 6 then
				IEex_WriteWord(CProjectile + 0x2AE, math.floor(IEex_ReadWord(CProjectile + 0x2AE) * areaMult / 100))
			elseif generalProjectileType == 7 then
				IEex_WriteWord(CProjectile + 0x2CE, math.floor(IEex_ReadWord(CProjectile + 0x2CE) * areaMult / 100))
			elseif generalProjectileType == 8 then
				IEex_WriteWord(CProjectile + 0x2A0, math.floor(IEex_ReadWord(CProjectile + 0x2A0) * areaMult / 100))
			end
		end
		if speedMult ~= 100 then
			IEex_WriteWord(CProjectile + 0x70, math.floor(IEex_ReadWord(CProjectile + 0x70) * speedMult / 100))
		end
		if rangeMult ~= 100 then
			if generalProjectileType == 6 then
				IEex_WriteWord(CProjectile + 0x2B0, math.floor(IEex_ReadWord(CProjectile + 0x2B0) * rangeMult / 100))
			elseif generalProjectileType == 7 then
				IEex_WriteWord(CProjectile + 0x2D2, math.floor(IEex_ReadWord(CProjectile + 0x2D2) * rangeMult / 100))
			elseif generalProjectileType == 8 then
				IEex_WriteWord(CProjectile + 0x2A2, math.floor(IEex_ReadWord(CProjectile + 0x2A2) * rangeMult / 100))
			end
		end
		if durationSet ~= -1 then
			if generalProjectileType == 6 and IEex_ReadSignedWord(CProjectile + 0x4C0) > 0 then
				IEex_WriteWord(CProjectile + 0x4C0, durationSet)
			end
		end
		if durationMult ~= 100 then
			if generalProjectileType == 6 and IEex_ReadSignedWord(CProjectile + 0x4C0) > 0 then
				IEex_WriteWord(CProjectile + 0x4C0, math.floor(IEex_ReadSignedWord(CProjectile + 0x4C0) * durationMult / 100))
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
	CProjectile = CProjectile - 0x7E
--	IEex_DS("CProjectile3: " .. CProjectile)
	local CGameEffect = IEex_ReadDword(esp + 0x4)
	local sourceID = IEex_ReadDword(CGameEffect + 0x10C)
	local CGameAIBase = IEex_GetActorShare(sourceID)
	local source = 0
--	IEex_DS("missileIndex: " .. IEex_ReadWord(CProjectile + 0x6E) + 1)
--[[
	local sourceRES = ""
	if (source == 0 or source == 1 or source == 7) and IEex_Helper_GetBridge("IEex_RecordSpell", sourceID, "spellRES") ~= nil then
		sourceRES = IEex_Helper_GetBridge("IEex_RecordSpell", sourceID, "spellRES")
	end
--]]

	local internalFlags = IEex_ReadDword(CGameEffect + 0xD4)
	if bit.band(internalFlags, 0x20) == 0 then
		internalFlags = bit.bor(internalFlags, 0x20)
		IEex_WriteDword(CGameEffect + 0xD4, internalFlags)
		if IEex_ReadDword(CGameEffect + 0xC) == 500 and IEex_ReadLString(CGameEffect + 0x2C, 8) == "METELEFI" and IEex_GetActorSpellState(sourceID, 246) then
			local areaMult = 100
			local missileIndex = IEex_ReadWord(CProjectile + 0x6E) + 1
			local generalProjectileType = IEex_ProjectileType[missileIndex]
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
					
				if theopcode == 288 and theparameter2 == 246 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thecondition = IEex_ReadWord(eData + 0x48)
					local thelimit = IEex_ReadWord(eData + 0x4A)
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
ex_metamagic_in_use = {}
ex_is_first_spell = {}
function EXMETAMA(actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	local spellAvailable = false
	ex_quicken_spell[sourceID] = nil
	if actionID == 31 or actionID == 95 or actionID == 113 or actionID == 114 or actionID == 181 or actionID == 191 or actionID == 192 then
		local doingMetamagic = false
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			if theopcode == 288 and theparameter2 == 250 and theresource == "EXMETAMA" then
				doingMetamagic = true
			end
		end)
		local currentSpellRES = IEex_GetActorSpellRES(sourceID)
		local resWrapper = IEex_DemandRes(currentSpellRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x10000000) > 0 or ex_source_spell[currentSpellRES] ~= nil then
				resWrapper:free()
				return
			end
		end
		resWrapper:free()
		local metamagicLevelModifier = 0
		local hasMetamagic = false
		ex_metamagic_in_use[sourceID] = {}
		ex_is_first_spell[sourceID] = {}
		IEex_IterateActorEffects(sourceID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			if theopcode == 206 and theresource == "USMM007D" then
				ex_quicken_spell[sourceID] = false
			end
		end)
		local metamagicModifiers = {}
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
						hasMetamagic = true
						metamagicModifiers[theresource] = theparameter1
						ex_metamagic_in_use[sourceID][theresource] = true
						ex_quicken_spell[sourceID] = true
						if thespecial > 0 then
							IEex_WriteDword(eData + 0x48, thespecial - 1)
						end
					end
				else
					metamagicLevelModifier = metamagicLevelModifier + theparameter1
					hasMetamagic = true
					metamagicModifiers[theresource] = theparameter1
					ex_metamagic_in_use[sourceID][theresource] = true
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
				if theopcode == 288 and theparameter2 == 240 and (theresource == "" or metamagicModifiers[theresource] ~= nil) then
					local metamagicCostReduction = theparameter1
					if metamagicModifiers[theresource] ~= nil then
						if metamagicCostReduction > metamagicModifiers[theresource] then
							metamagicCostReduction = metamagicModifiers[theresource]
						end
						metamagicModifiers[theresource] = metamagicModifiers[theresource] - metamagicCostReduction
					end
					if metamagicCostReduction > metamagicLevelModifier then
						metamagicCostReduction = metamagicLevelModifier
					end
					metamagicLevelModifier = metamagicLevelModifier - metamagicCostReduction
				end
			end)
		end
		local casterClass = IEex_ReadByte(creatureData + 0x530)
		local casterDomain = IEex_ReadByte(creatureData + 0x531)
		local casterType = IEex_CasterClassToType[casterClass]
--[[
		if casterType == 2 and casterDomain > 0 then
			casterType = 8
		end
--]]
		local casterTypes = {}
		if casterType ~= nil then
			table.insert(casterTypes, casterType)

			if casterType == 2 and casterDomain > 0 then
				table.insert(casterTypes, 8)
			end

		end
		local classSpellLevel = IEex_ReadByte(creatureData + 0x534)
		local newSpellLevel = classSpellLevel + metamagicLevelModifier
		local spells = IEex_FetchSpellInfo(sourceID, casterTypes)
		local noSpellsFound = true
		if hasMetamagic and classSpellLevel > 0 then
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
											ex_can_use_metamagic[sourceID] = {currentSpellRES, classSpellLevel, i, casterClass, casterDomain, false}
										end
									elseif cType == 8 then
										if spell["castableCount"] > 0 then
											spellAvailable = true
											ex_can_use_metamagic[sourceID] = {currentSpellRES, classSpellLevel, i, casterClass, casterDomain, true}
										end
									else
										if spell["castableCount"] > 0 then
											spellAvailable = true
											ex_can_use_metamagic[sourceID] = {currentSpellRES, classSpellLevel, i, casterClass, casterDomain, false}
										end
									end
								end
							end
						end
					end
				end
			end
			if not spellAvailable and casterType > 0 and IEex_GetActorStat(sourceID, 95 + casterClass) >= ex_caster_max_spell_level[casterClass][1] then
				local lowestAvailableExtraSpellLevel = 0x7FFFFFFF
				IEex_IterateActorEffects(sourceID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theparameter2 = IEex_ReadDword(eData + 0x20)
					local theparameter3 = IEex_ReadDword(eData + 0x60)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if theopcode == 288 and theparameter2 == 197 and theparameter3 < theparameter1 then
						local extraSlotSpellLevel = thespecial
						if bit.band(thesavingthrow, 0x10000) > 0 then
							extraSlotSpellLevel = ex_caster_max_spell_level[casterClass][2] + thespecial
						end
						if extraSlotSpellLevel < lowestAvailableExtraSpellLevel and extraSlotSpellLevel >= newSpellLevel then
							lowestAvailableExtraSpellLevel = extraSlotSpellLevel
							spellAvailable = true
							noSpellsFound = false
						end
					end
				end)
				if spellAvailable then
					ex_can_use_metamagic[sourceID] = {currentSpellRES, classSpellLevel, lowestAvailableExtraSpellLevel, casterClass, casterDomain, false}
				end
			end
			IEex_SetToken("EXMMLEVEL", IEex_FetchString(ex_spelllevelstrrefs[newSpellLevel]))
			if noSpellsFound and doingMetamagic then
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_55491,
["source_target"] = sourceID,
["source_id"] = sourceID,
})
			elseif not spellAvailable and doingMetamagic then
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_55492,
["source_target"] = sourceID,
["source_id"] = sourceID,
})
			end
		elseif newSpellLevel > 9 and doingMetamagic then
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_55493,
["source_target"] = sourceID,
["source_id"] = sourceID,
})
		end
		if spellAvailable and ex_quicken_spell[sourceID] then
			local castCounter = IEex_ReadSignedWord(creatureData + 0x54E8)
			if castCounter ~= -1 then
				ex_quicken_spell[sourceID] = nil
			end
--[[
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
--]]
			IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 288,
["target"] = 2,
["timing"] = 0,
["duration"] = 6,
["parameter1"] = 30,
["parameter2"] = 193,
["special"] = 2,
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
	end
	if not spellAvailable and actionID ~= 83 then
		ex_metamagic_in_use[sourceID] = nil
		ex_can_use_metamagic[sourceID] = nil
	end
end

IEex_AddActionHookGlobal("EXMETAMA")

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
	local casterDomain = ex_can_use_metamagic[targetID][5]
	local useDomainSlot = ex_can_use_metamagic[targetID][6]
	local savingthrow = 0
	IEex_IterateActorEffects(targetID, function(eData)
		local theopcode = IEex_ReadDword(eData + 0x10)
		local theparameter1 = IEex_ReadDword(eData + 0x1C)
		local theparameter2 = IEex_ReadDword(eData + 0x20)
		local theresource = IEex_ReadLString(eData + 0x30, 8)
		local thesavingthrow = IEex_ReadDword(eData + 0x40)
		local thespecial = IEex_ReadDword(eData + 0x48)
		if theopcode == 288 and theparameter2 == 251 and thespecial > 0 and ex_metamagic_in_use[targetID][theresource] ~= nil and theresource ~= "EXQUISPL" then
			IEex_WriteDword(eData + 0x48, thespecial - 1)
		end
	end)
	local foundExtraMetamagicSlot = false
	if newSpellLevel > ex_caster_max_spell_level[casterClass][2] then
		IEex_IterateActorEffects(targetID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theparameter3 = IEex_ReadDword(eData + 0x60)
			local thesavingthrow = IEex_ReadDword(eData + 0x40)
			local thespecial = IEex_ReadDword(eData + 0x48)
			if theopcode == 288 and theparameter2 == 197 and theparameter3 < theparameter1 and not foundExtraMetamagicSlot then
				local extraSlotSpellLevel = thespecial
				if bit.band(thesavingthrow, 0x10000) > 0 then
					extraSlotSpellLevel = ex_caster_max_spell_level[casterClass][2] + thespecial
				end
				if extraSlotSpellLevel == newSpellLevel then
					foundExtraMetamagicSlot = true
					IEex_WriteDword(eData + 0x60, theparameter3 + 1)
				end
			end
		end)
		IEex_SetToken("EXMMLEVEL", IEex_FetchString(ex_spelllevelstrrefs[newSpellLevel]))
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 139,
["target"] = 2,
["timing"] = 1,
["parameter1"] = ex_tra_55460,
["source_id"] = targetID,
})
	end
	if casterDomain > 0 then
		IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = 1,
["parameter2"] = originalSpellLevel,
["special"] = originalSpellLevel,
["savingthrow"] = 0x2800000,
["resource"] = "EXMODMEM",
["vvcresource"] = currentSpellRES,
["casterlvl"] = 1,
["source_target"] = targetID,
["source_id"] = targetID,
})
	else
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
["casterlvl"] = 1 + casterClass * 0x100 + casterDomain * 0x10000,
["source_target"] = targetID,
["source_id"] = targetID,
})
	end
	if not foundExtraMetamagicSlot and newSpellLevel <= 9 then
		if useDomainSlot then
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = -1,
["parameter2"] = newSpellLevel,
["special"] = newSpellLevel,
["savingthrow"] = 0x800000,
["resource"] = "EXMODMEM",
["casterlvl"] = 1,
["source_target"] = targetID,
["source_id"] = targetID,
})
		else
			IEex_ApplyEffectToActor(targetID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = -1,
["parameter2"] = newSpellLevel,
["special"] = newSpellLevel,
["savingthrow"] = 0,
["resource"] = "EXMODMEM",
["casterlvl"] = 1 + casterClass * 0x100 + casterDomain * 0x10000,
["source_target"] = targetID,
["source_id"] = targetID,
})
		end
	end
end

ex_empower_spell = {}
IEex_MutatorOpcodeFunctions["EXEMPSPL"] = {
	["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)

	end,
	["projectileMutator"] = function(source, originatingEffectData, creatureData, projectileData, sourceRES)
		local resWrapper = IEex_DemandRes(sourceRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C) >= 1 and IEex_ReadWord(spellData + 0x1C) <= 2 then
				local actorID = IEex_GetActorIDShare(creatureData)
				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
				if ex_metamagic_in_use[actorID] ~= nil and ex_metamagic_in_use[actorID]["EXEMPSPL"] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_empower_spell[actorID] = nil
					end
					if source <= 3 or ((source == 5 or source == 6 or source == 7) and ex_is_first_spell[actorID]["EXEMPSPL"] == nil) then
						ex_is_first_spell[actorID]["EXEMPSPL"] = true
						ex_empower_spell[actorID] = 0
					end
					if source >= 11 then
						ex_empower_spell[actorID] = nil
					end
					if source ~= 4 and source < 11 and ex_empower_spell[actorID] ~= nil then
						ex_empower_spell[actorID] = 1
						ex_projectile_flags[projectileData]["Metamagic"] = bit.bor(ex_projectile_flags[projectileData]["Metamagic"], 0x100000)
					end
				else
					ex_empower_spell[actorID] = nil
				end
			end
		end
		resWrapper:free()
	end,
	["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
--[[
		local actorID = IEex_GetActorIDShare(creatureData)
		if ex_empower_spell[actorID] == 1 then
			local internalFlags = IEex_ReadDword(effectData + 0xD4)
			internalFlags = bit.bor(internalFlags, 0x100000)
			IEex_WriteDword(effectData + 0xD4, internalFlags)
		end
--]]
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
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C) >= 1 and IEex_ReadWord(spellData + 0x1C) <= 2 then
				local actorID = IEex_GetActorIDShare(creatureData)
				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
				if ex_metamagic_in_use[actorID] ~= nil and ex_metamagic_in_use[actorID]["EXEXTSPL"] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_extend_spell[actorID] = nil
					end
					if source <= 3 or ((source == 5 or source == 6 or source == 7) and ex_is_first_spell[actorID]["EXEXTSPL"] == nil) then
						ex_is_first_spell[actorID]["EXEXTSPL"] = true
						ex_extend_spell[actorID] = 0
					end
					if source >= 11 then
						ex_extend_spell[actorID] = nil
					end
					if source ~= 4 and source < 11 and ex_extend_spell[actorID] ~= nil then
						ex_extend_spell[actorID] = 1
						ex_projectile_flags[projectileData]["Metamagic"] = bit.bor(ex_projectile_flags[projectileData]["Metamagic"], 0x20000)
					end
				else
					ex_extend_spell[actorID] = nil
				end
			end
		end
		resWrapper:free()
	end,
	["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
--[[
		local actorID = IEex_GetActorIDShare(creatureData)
		if ex_extend_spell[actorID] == 1 then
			local internalFlags = IEex_ReadDword(effectData + 0xD4)
			internalFlags = bit.bor(internalFlags, 0x20000)
			IEex_WriteDword(effectData + 0xD4, internalFlags)
		end
--]]
	end,
}

ex_mass_spell = {}
IEex_MutatorOpcodeFunctions["EXMASSPL"] = {
	["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)
		local resWrapper = IEex_DemandRes(sourceRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C) >= 1 and IEex_ReadWord(spellData + 0x1C) <= 2 then
				local actorID = IEex_GetActorIDShare(creatureData)
				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
				if ex_metamagic_in_use[actorID] ~= nil and ex_metamagic_in_use[actorID]["EXMASSPL"] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_mass_spell[actorID] = nil
					end
					if source <= 3 or ((source == 5 or source == 6 or source == 7) and ex_is_first_spell[actorID]["EXMASSPL"] == nil) then
						ex_is_first_spell[actorID]["EXMASSPL"] = true
						ex_mass_spell[actorID] = 0
					end
					if source >= 11 then
						ex_mass_spell[actorID] = nil
					end
					if source ~= 4 and source < 11 and ex_mass_spell[actorID] ~= nil then
--						ex_projectile_flags[projectileData]["Metamagic"] = bit.bor(ex_projectile_flags[projectileData]["Metamagic"], 0x400000)
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
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C) >= 1 and IEex_ReadWord(spellData + 0x1C) <= 2 then
				local actorID = IEex_GetActorIDShare(creatureData)
				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
				if ex_metamagic_in_use[actorID] ~= nil and ex_metamagic_in_use[actorID]["EXMAXSPL"] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_maximize_spell[actorID] = nil
					end
					if source <= 3 or ((source == 5 or source == 6 or source == 7) and ex_is_first_spell[actorID]["EXMAXSPL"] == nil) then
						ex_is_first_spell[actorID]["EXMAXSPL"] = true
						ex_maximize_spell[actorID] = 0
					end
					if source >= 11 then
						ex_maximize_spell[actorID] = nil
					end
					if source ~= 4 and source < 11 and ex_maximize_spell[actorID] ~= nil then
						ex_maximize_spell[actorID] = 1
						ex_projectile_flags[projectileData]["Metamagic"] = bit.bor(ex_projectile_flags[projectileData]["Metamagic"], 0x200000)
					end
				else
					ex_maximize_spell[actorID] = nil
				end
			end
		end
		resWrapper:free()
	end,
	["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
--[[
		local actorID = IEex_GetActorIDShare(creatureData)
		if ex_maximize_spell[actorID] == 1 then
			local internalFlags = IEex_ReadDword(effectData + 0xD4)
			internalFlags = bit.bor(internalFlags, 0x200000)
			IEex_WriteDword(effectData + 0xD4, internalFlags)
		end
--]]
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
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C) >= 1 and IEex_ReadWord(spellData + 0x1C) <= 2 then
				local actorID = IEex_GetActorIDShare(creatureData)
				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
				if ex_metamagic_in_use[actorID] ~= nil and ex_metamagic_in_use[actorID]["EXPERSPL"] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_persistent_spell[actorID] = nil
					end
					if source <= 3 or ((source == 5 or source == 6 or source == 7) and ex_is_first_spell[actorID]["EXPERSPL"] == nil) then
						ex_is_first_spell[actorID]["EXPERSPL"] = true
						ex_persistent_spell[actorID] = 0
					end
					if source >= 11 then
						ex_persistent_spell[actorID] = nil
					end
					if source ~= 4 and source < 11 and ex_persistent_spell[actorID] ~= nil then
						ex_persistent_spell[actorID] = 1
						ex_projectile_flags[projectileData]["Metamagic"] = bit.bor(ex_projectile_flags[projectileData]["Metamagic"], 0x10000)
					end
				else
					ex_persistent_spell[actorID] = nil
				end
			end
		end
		resWrapper:free()
	end,
	["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
--[[
		local actorID = IEex_GetActorIDShare(creatureData)
		if ex_persistent_spell[actorID] == 1 then
			local internalFlags = IEex_ReadDword(effectData + 0xD4)
			internalFlags = bit.bor(internalFlags, 0x10000)
			IEex_WriteDword(effectData + 0xD4, internalFlags)
		end
--]]
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
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C) >= 1 and IEex_ReadWord(spellData + 0x1C) <= 2 then
				local actorID = IEex_GetActorIDShare(creatureData)
				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
				if ex_metamagic_in_use[actorID] ~= nil and ex_metamagic_in_use[actorID]["EXSAFSPL"] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_safe_spell[actorID] = nil
					end
					if source <= 3 or ((source == 5 or source == 6 or source == 7) and ex_is_first_spell[actorID]["EXSAFSPL"] == nil) then
						ex_is_first_spell[actorID]["EXSAFSPL"] = true
						ex_safe_spell[actorID] = 0
					end
					if source >= 11 then
						ex_safe_spell[actorID] = nil
					end
					if source ~= 4 and source < 11 and ex_safe_spell[actorID] ~= nil then
						ex_safe_spell[actorID] = 1
						ex_projectile_flags[projectileData]["Metamagic"] = bit.bor(ex_projectile_flags[projectileData]["Metamagic"], 0x80000)
					end
				else
					ex_safe_spell[actorID] = nil
				end
			end
		end
		resWrapper:free()
	end,
	["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
--[[
		local actorID = IEex_GetActorIDShare(creatureData)
		if ex_safe_spell[actorID] == 1 then
			local internalFlags = IEex_ReadDword(effectData + 0xD4)
			internalFlags = bit.bor(internalFlags, 0x80000)
			IEex_WriteDword(effectData + 0xD4, internalFlags)
		end
--]]
	end,
}

ex_widen_spell = {}
IEex_MutatorOpcodeFunctions["EXWIDSPL"] = {
	["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)
	
	end,
	["projectileMutator"] = function(source, originatingEffectData, creatureData, projectileData, sourceRES)
		local actorID = IEex_GetActorIDShare(creatureData)
		if (source == 11 or source == 12 or source == 13 or source == 14) and IEex_GetActorSpellState(actorID, 246) then
			local projectileIndex = IEex_ReadWord(projectileData + 0x6E)
			IEex_IterateActorEffects(sourceID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local theinternalFlags = bit.bor(IEex_ReadDword(eData + 0xD0), IEex_ReadDword(eData + 0xD8))
				if theopcode == 288 and theparameter2 == 246 and bit.band(theinternalFlags, 0x40000) > 0 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					local thesavingthrow = IEex_ReadDword(eData + 0x40)
					local thecondition = IEex_ReadWord(eData + 0x48)
					local thelimit = IEex_ReadWord(eData + 0x4A)
					if (bit.band(thesavingthrow, 0x40000) == 0 or thecondition == source) and (bit.band(thesavingthrow, 0x80000) == 0 or thelimit > 0) then
						if bit.band(thesavingthrow, 0x4000000) > 0 and theparameter1 == projectileIndex then
							local generalProjectileType = IEex_ProjectileType[projectileIndex + 1]
							if generalProjectileType == 6 then
								IEex_WriteWord(projectileData + 0x2AE, math.floor(IEex_ReadWord(projectileData + 0x2AE) * 1.5))
							elseif generalProjectileType == 7 then
								IEex_WriteWord(projectileData + 0x2CE, math.floor(IEex_ReadWord(projectileData + 0x2CE) * 1.5))
							elseif generalProjectileType == 8 then
								IEex_WriteWord(projectileData + 0x2A0, math.floor(IEex_ReadWord(projectileData + 0x2A0) * 1.5))
							end
						end
					end
				end
			end)
		end
		local resWrapper = IEex_DemandRes(sourceRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			if bit.band(IEex_ReadDword(spellData + 0x18), 0x40000) == 0 and IEex_ReadWord(spellData + 0x1C) >= 1 and IEex_ReadWord(spellData + 0x1C) <= 2 then

				local parameter1 = IEex_ReadDword(originatingEffectData + 0x18)
			   	local special = IEex_ReadDword(originatingEffectData + 0x44)
				if ex_metamagic_in_use[actorID] ~= nil and ex_metamagic_in_use[actorID]["EXWIDSPL"] ~= nil then
					local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
					if bit.band(savingthrow, 0x10000000) == 0 then
						savingthrow = bit.bor(savingthrow, 0x10000000)
						IEex_WriteDword(originatingEffectData + 0x3C, savingthrow)
						ex_widen_spell[actorID] = nil
					end
					if source <= 3 or ((source == 5 or source == 6 or source == 7) and ex_is_first_spell[actorID]["EXWIDSPL"] == nil) then
						ex_is_first_spell[actorID]["EXWIDSPL"] = true
						ex_widen_spell[actorID] = 0
					end
					if source >= 11 then
						ex_widen_spell[actorID] = nil
					end
					if source ~= 4 and source < 11 and ex_widen_spell[actorID] ~= nil then
						ex_widen_spell[actorID] = 1
						ex_projectile_flags[projectileData]["Metamagic"] = bit.bor(ex_projectile_flags[projectileData]["Metamagic"], 0x40000)
						local missileIndex = IEex_ReadWord(projectileData + 0x6E) + 1
						local generalProjectileType = IEex_ProjectileType[missileIndex]
						if generalProjectileType == 6 then
							IEex_WriteWord(projectileData + 0x2AE, math.floor(IEex_ReadWord(projectileData + 0x2AE) * 1.5))
						elseif generalProjectileType == 7 then
							IEex_WriteWord(projectileData + 0x2CE, math.floor(IEex_ReadWord(projectileData + 0x2CE) * 1.5))
						elseif generalProjectileType == 8 then
							IEex_WriteWord(projectileData + 0x2A0, math.floor(IEex_ReadWord(projectileData + 0x2A0) * 1.5))
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
--[[
		local actorID = IEex_GetActorIDShare(creatureData)
		if ex_widen_spell[actorID] == 1 then
			local internalFlags = IEex_ReadDword(effectData + 0xD4)
			internalFlags = bit.bor(internalFlags, 0x40000)
			IEex_WriteDword(effectData + 0xD4, internalFlags)
			if IEex_ReadDword(effectData + 0xC) == 500 and IEex_ReadLString(effectData + 0x2C, 8) == "METELEFI" then
				local parameter1 = IEex_ReadDword(effectData + 0x18)
				IEex_WriteDword(effectData + 0x18, math.floor(parameter1 * 1.5))
			end
		end
--]]
	end,
}

IEex_MutatorGlobalFunctions["MEMETAGL"] = {
	["typeMutator"] = function(source, creatureData, missileIndex, sourceRES)
	end,
	["projectileMutator"] = function(source, creatureData, projectileData, sourceRES)
	end,
	["effectMutator"] = function(source, creatureData, projectileData, effectData)
		if ex_projectile_flags[projectileData] ~= nil then

			local internalFlags = bit.bor(IEex_ReadDword(effectData + 0xCC), IEex_ReadDword(effectData + 0xD4))
			internalFlags = bit.bor(internalFlags, ex_projectile_flags[projectileData]["Metamagic"])
			if bit.band(internalFlags, 0x40000) > 0 then
				if IEex_ReadDword(effectData + 0xC) == 500 and IEex_ReadLString(effectData + 0x2C, 8) == "METELEFI" then
					local parameter1 = IEex_ReadDword(effectData + 0x18)
					IEex_WriteDword(effectData + 0x18, math.floor(parameter1 * 1.5))
				end
			end
			IEex_WriteDword(effectData + 0xCC, internalFlags)
			IEex_WriteDword(effectData + 0xD4, internalFlags)
		end
	end,
}

IEex_MutatorOpcodeFunctions["MEATKSAV"] = {
	["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)
	end,
	["projectileMutator"] = function(source, originatingEffectData, creatureData, projectileData, sourceRES)
	
	end,

	["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
		local actorID = IEex_GetActorIDShare(creatureData)
		local opcode = IEex_ReadDword(effectData + 0xC)
		local matchProjectile = IEex_ReadDword(originatingEffectData + 0x18)
		if opcode == 12 and IEex_ReadLString(effectData + 0x90, 8) == "IEEX_DAM" and (matchProjectile == -1 or IEex_ReadWord(projectileData + 0x6E) == matchProjectile) then
			local savebonus = IEex_ReadDword(originatingEffectData + 0x40)
			local sourceSpell = IEex_ReadLString(originatingEffectData + 0x90, 8)
			if ex_source_spell[sourceSpell] ~= nil then
				sourceSpell = ex_source_spell[sourceSpell]
			end
			local trueschool = IEex_ReadDword(originatingEffectData + 0x48)
			if ex_trueschool[sourceSpell] ~= nil then
				trueschool = ex_trueschool[sourceSpell]
			end
			IEex_IterateActorEffects(actorID, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				if theopcode == 288 and theparameter2 == 236 and bit.band(thesavingthrow, 0x10000) == 0 then
					local theparameter1 = IEex_ReadDword(eData + 0x1C)
					local theresource = IEex_ReadLString(eData + 0x30, 8)
					local thespecial = IEex_ReadDword(eData + 0x48)
					if bit.band(thesavingthrow, 0x20000) == 0 then
						if theresource == "" or theresource == sourceSpell then
							savebonus = savebonus + theparameter1
						end
					else
						if thespecial == trueschool or thespecial == -1 then
							savebonus = savebonus + theparameter1
						end
					end
				end
			end)
			IEex_WriteWord(effectData + 0x1C, 3)
			IEex_WriteDword(effectData + 0x3C, bit.bor(IEex_ReadDword(effectData + 0x3C), 0x8))
			IEex_WriteDword(effectData + 0x40, savebonus)
		end
	end,
}



ex_is_boulder_shot = {}
IEex_MutatorOpcodeFunctions["MEBOULSH"] = {
	["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)
		local actorID = IEex_GetActorIDShare(creatureData)
		if ex_is_boulder_shot[actorID] == nil then
			ex_is_boulder_shot[actorID] = {}
		end
		local matchMissileIndexTable = IEex_ReadWord(originatingEffectData + 0x44)
		local functionIdentifier = IEex_ReadLString(originatingEffectData + 0x90, 8)
		local newMissileIndex = missileIndex
		local savingthrow = IEex_ReadDword(originatingEffectData + 0x3C)
		local projectileMatched = false
		if matchMissileIndexTable <= 0 then
			projectileMatched = true
		elseif ex_match_missile_index[matchMissileIndexTable] ~= nil and ex_match_missile_index[matchMissileIndexTable][missileIndex] ~= nil then
			projectileMatched = true
			newMissileIndex = ex_match_missile_index[matchMissileIndexTable][missileIndex]
		end
		local thelimit = IEex_ReadSignedWord(originatingEffectData + 0x46)
		if (bit.band(savingthrow, 0x80000) > 0 and thelimit == 0) or not projectileMatched or (bit.band(savingthrow, 0x200000) == 0 and (source < 11 or source > 14)) then
			ex_is_boulder_shot[actorID][functionIdentifier] = nil
			if bit.band(savingthrow, 0x100000) > 0 then
				thelimit = thelimit - 1
				IEex_WriteWord(originatingEffectData + 0x46, thelimit)
				if (bit.band(savingthrow, 0x80000) > 0 and thelimit == 0) then
					IEex_WriteWord(creatureData + 0x476, 0)
					IEex_ApplyEffectToActor(actorID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = IEex_ReadLString(originatingEffectData + 0x90, 8),
["source_target"] = actorID,
["source_id"] = actorID,
})
				end
			end

			return missileIndex
		elseif bit.band(savingthrow, 0x80000) > 0 and thelimit > 0 and source ~= 11 and source ~= 13 then
			thelimit = thelimit - 1
			IEex_WriteWord(originatingEffectData + 0x46, thelimit)
		end
		ex_is_boulder_shot[actorID][functionIdentifier] = true
		
		if (bit.band(savingthrow, 0x80000) > 0 and thelimit == 0) then
			IEex_WriteWord(creatureData + 0x476, 0)
			IEex_ApplyEffectToActor(actorID, {
["opcode"] = 254,
["target"] = 2,
["timing"] = 1,
["resource"] = IEex_ReadLString(originatingEffectData + 0x90, 8),
["source_target"] = actorID,
["source_id"] = actorID,
})
		end
		return newMissileIndex
	end,
	["projectileMutator"] = function(source, originatingEffectData, creatureData, projectileData, sourceRES)
	
	end,

	["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
		local actorID = IEex_GetActorIDShare(creatureData)
		local opcode = IEex_ReadDword(effectData + 0xC)
		local damageType = IEex_ReadWord(effectData + 0x1E)
		local damageEnchantment = IEex_ReadWord(effectData + 0x44)
		local functionIdentifier = IEex_ReadLString(originatingEffectData + 0x90, 8)
		local matchMissileIndexTable = IEex_ReadWord(originatingEffectData + 0x44)
		if ex_is_boulder_shot[actorID][functionIdentifier] ~= nil and opcode == 12 and IEex_ReadLString(effectData + 0x90, 8) == "IEEX_DAM" then
			ex_is_boulder_shot[actorID][functionIdentifier] = nil
			if ex_new_projectile_damage_type[matchMissileIndexTable] ~= nil and ex_new_projectile_damage_type[matchMissileIndexTable][damageType] ~= nil then
				damageType = ex_new_projectile_damage_type[matchMissileIndexTable][damageType]
				IEex_WriteWord(effectData + 0x1E, damageType)
			end
			local damageBonus = IEex_ReadSignedByte(originatingEffectData + 0x18)
			local dicesize = IEex_ReadByte(originatingEffectData + 0x19)
			local dicenumber = IEex_ReadByte(originatingEffectData + 0x1A)
			local luck = 0
--[[
			local luck = IEex_GetActorStat(actorID, 32)
			if IEex_GetActorSpellState(actorID, 64) then
				luck = 255
			end
--]]
			for i = 1, dicenumber, 1 do
				local diceRoll = math.random(dicesize) + luck
				if diceRoll > dicesize then
					diceRoll = dicesize
				elseif diceRoll < 1 then
					diceRoll = 1
				end
				damageBonus = damageBonus + diceRoll
			end
			if damageEnchantment == 0 then
				IEex_WriteWord(effectData + 0x44, 1)
			end
			IEex_WriteDword(effectData + 0x18, IEex_ReadDword(effectData + 0x18) + damageBonus)
		end
	end,
}

IEex_MutatorOpcodeFunctions["MEMODDTP"] = {
	["typeMutator"] = function(source, originatingEffectData, creatureData, missileIndex, sourceRES)
	
	end,
	["projectileMutator"] = function(source, originatingEffectData, creatureData, projectileData, sourceRES)
	
	end,

	["effectMutator"] = function(source, originatingEffectData, creatureData, projectileData, effectData)
		local opcode = IEex_ReadDword(effectData + 0xC)
		if opcode == 12 and IEex_ReadLString(effectData + 0x90, 8) == "IEEX_DAM" and (IEex_ReadLString(effectData + 0x6C, 8) == IEex_ReadLString(originatingEffectData + 0x90, 8) or IEex_ReadLString(effectData + 0x74, 8) == IEex_ReadLString(originatingEffectData + 0x90, 8)) then
			local newDamageType = IEex_ReadWord(originatingEffectData + 0x18)
			IEex_WriteWord(effectData + 0x1E, newDamageType)
		end
	end,
}

IEex_MutatorGlobalFunctions["METIMESL"] = {
	["typeMutator"] = function(source, creatureData, missileIndex, sourceRES)
--[[
		if missileIndex == 335 and ex_time_slow_speed_divisor == 0x7FFFFFFF then
			local timeSlowed = IEex_CheckGlobalEffect(0x2)
			if timeSlowed then
				return 1
			end
		end
--]]
	end,
	["projectileMutator"] = function(source, creatureData, projectileData, sourceRES)
		if ex_time_slow_speed_divisor ~= 0x7FFFFFFF then
			local timeSlowed = IEex_CheckGlobalEffect(0x2)
			if timeSlowed then
				IEex_WriteWord(projectileData + 0x70, math.ceil(IEex_ReadWord(projectileData + 0x70) / ex_time_slow_speed_divisor))
			end
		end
	end,
	["effectMutator"] = function(source, creatureData, projectileData, effectData)
	end,
}

--[[
IEex_MutatorGlobalFunctions["USPR954"] = {
	["typeMutator"] = function(source, creatureData, missileIndex, sourceRES)

	end,
	["projectileMutator"] = function(source, creatureData, projectileData, sourceRES)
		if ex_true_spell[sourceRES] ~= nil then
			sourceRES = ex_true_spell[sourceRES]
		end
		local projectileIndex = IEex_ReadWord(projectileData + 0x6E)
--		if sourceRES == "USPR954" and source ~= 8 then
		if projectileIndex == 308 then
		end
	end,
	["effectMutator"] = function(source, creatureData, projectileData, effectData)
	end,
}
--]]
IEex_MutatorGlobalFunctions["USWI252"] = {
	["typeMutator"] = function(source, creatureData, missileIndex, sourceRES)

	end,
	["projectileMutator"] = function(source, creatureData, projectileData, sourceRES)
		if ex_true_spell[sourceRES] ~= nil then
			sourceRES = ex_true_spell[sourceRES]
		end
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
		if ex_true_spell[sourceRES] ~= nil then
			sourceRES = ex_true_spell[sourceRES]
		end
		if sourceRES == "USWI858" and source ~= 8 then
			IEex_WriteWord(projectileData + 0x2B2, 37)
		end
	end,
	["effectMutator"] = function(source, creatureData, projectileData, effectData)
	end,
}

IEex_MutatorGlobalFunctions["USDLVMOD"] = {
	["typeMutator"] = function(source, creatureData, missileIndex, sourceRES)

	end,
	["projectileMutator"] = function(source, creatureData, projectileData, sourceRES)
	end,
	["effectMutator"] = function(source, creatureData, projectileData, effectData)
		local parent_resource = IEex_ReadLString(effectData + 0x90, 8)
		local trueSpellLevel = ex_alternate_spell_level_list[parent_resource]
		if trueSpellLevel then
			IEex_WriteDword(effectData + 0x14, trueSpellLevel)
		end
	end,
}