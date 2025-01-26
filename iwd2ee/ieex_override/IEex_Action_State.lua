
function IEex_AddActionHook(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_ActionHooks", function()
		IEex_AppendBridgeNL("IEex_ActionHooks", funcName)
	end)
end

function IEex_ReaddActionHook(funcName)
	IEex_AppendBridgeNL("IEex_ActionHooks", funcName)
end

function IEex_AddActionHookOpcode(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_OpcodeActionHooks", function()
		IEex_AppendBridgeNL("IEex_OpcodeActionHooks", funcName)
	end)
end

function IEex_AddActionHookGlobal(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_GlobalActionHooks", function()
		IEex_AppendBridgeNL("IEex_GlobalActionHooks", funcName)
	end)
end

--[[

CAIAction =>
0x0     short            m_actionID    
0x2     CAIObjectType    m_actorID    
0x3e    CAIObjectType    m_acteeID    
0x7a    CAIObjectType    m_acteeID2    
0xb6    int              m_specificID    
0xba    int              m_specificID2    
0xbe    int              m_specificID3    
0xc2    CString          m_string1    
0xc6    CString          m_string2    
0xca    CPoint           m_dest    
0xd2    uint             m_internalFlags    

--]]

----------------------------
-- Start Action Interface --
----------------------------

function IEex_GetActionID(actionData)
	return IEex_ReadWord(actionData)
end

function IEex_SetActionID(actionData, id)
	IEex_WriteWord(actionData, id)
end

function IEex_GetActionObjectID(actionData)
	return IEex_ReadDword(actionData + 0x48)
end

function IEex_SetActionObjectID(actionData, objectID)
	IEex_WriteDword(actionData + 0x48, objectID)
end

function IEex_GetActionInt1(actionData)
	return IEex_ReadDword(actionData + 0xB6)
end

function IEex_SetActionInt1(actionData, int1)
	IEex_WriteDword(actionData + 0xB6, int1)
end

function IEex_GetActionInt2(actionData)
	return IEex_ReadDword(actionData + 0xBA)
end

function IEex_SetActionInt2(actionData, int2)
	IEex_WriteDword(actionData + 0xBA, int2)
end

function IEex_GetActionInt3(actionData)
	return IEex_ReadDword(actionData + 0xBE)
end

function IEex_SetActionInt3(actionData, int3)
	IEex_WriteDword(actionData + 0xBE, int3)
end

function IEex_GetActionString1(actionData)
	return IEex_ReadString(IEex_ReadDword(actionData + 0xC2))
end

function IEex_SetActionString1(actionData, string1)
	IEex_CString_Set(actionData + 0xC2, string1)
end

function IEex_GetActionString2(actionData)
	return IEex_ReadString(IEex_ReadDword(actionData + 0xC6))
end

function IEex_SetActionString2(actionData, string2)
	IEex_CString_Set(actionData + 0xC6, string2)
end

function IEex_GetActionPointX(actionData)
	return IEex_ReadDword(actionData + 0xCA)
end

function IEex_SetActionPointX(actionData, x)
	IEex_WriteDword(actionData + 0xCA, x)
end

function IEex_GetActionPointY(actionData)
	return IEex_ReadDword(actionData + 0xCE)
end

function IEex_SetActionPointY(actionData, y)
	IEex_WriteDword(actionData + 0xCE, y)
end

function IEex_GetActionInternalFlags(actionData)
	return IEex_ReadDword(actionData + 0xD2)
end

function IEex_SetActionInternalFlags(actionData, internalFlags)
	IEex_WriteDword(actionData + 0xD2, internalFlags)
end

IEex_ActionWrapper = {}
IEex_ActionWrapper.__index = IEex_ActionWrapper

function IEex_WrapAction(actionData)
	return IEex_ActionWrapper:new(actionData)
end

for _, pair in ipairs({
	{ IEex_GetActionID,            "getID"            },
	{ IEex_SetActionID,            "setID"            },
	{ IEex_GetActionObjectID,      "getObjectID"      },
	{ IEex_SetActionObjectID,      "setObjectID"      },
	{ IEex_GetActionInt1,          "getInt1"          },
	{ IEex_SetActionInt1,          "setInt1"          },
	{ IEex_GetActionInt2,          "getInt2"          },
	{ IEex_SetActionInt2,          "setInt2"          },
	{ IEex_GetActionInt3,          "getInt3"          },
	{ IEex_SetActionInt3,          "setInt3"          },
	{ IEex_GetActionString1,       "getString1"       },
	{ IEex_SetActionString1,       "setString1"       },
	{ IEex_GetActionString2,       "getString2"       },
	{ IEex_SetActionString2,       "setString2"       },
	{ IEex_GetActionPointX,        "getPointX"        },
	{ IEex_SetActionPointX,        "setPointX"        },
	{ IEex_GetActionPointY,        "getPointY"        },
	{ IEex_SetActionPointY,        "setPointY"        },
	{ IEex_GetActionInternalFlags, "getInternalFlags" },
	{ IEex_SetActionInternalFlags, "setInternalFlags" },
}) do
	IEex_ActionWrapper[pair[2]] = function(self, ...)
		return pair[1](self.actionData, ...)
	end
end

function IEex_ActionWrapper:getData()
	return self.actionData
end

function IEex_ActionWrapper:init(actionData)
	self.actionData = actionData
end

function IEex_ActionWrapper:new(actionData)
	local o = {}
	setmetatable(o, self)
	o:init(actionData)
	return o
end

--------------------------
-- End Action Interface --
--------------------------

------------------------
-- Start Action Hooks --
------------------------

--[[

Invoke via IEex_Lua before running a spell action to target the ground instead of the actor.
Example:

IEex_Lua("B3SpellToPoint()")
SpellNoDec(Player2,WIZARD_FIREBALL)

--]]

function B3SpellToPointHook(action)
	local spellActions = {
		[31]  = 95 , -- Spell            => SpellPoint
		[113] = 114, -- ForceSpell       => ForceSpellPoint
		[181] = 337, -- ReallyForceSpell => ReallyForceSpellPoint
		[191] = 192, -- SpellNoDec       => SpellPointNoDec
	}
	local newActionID = spellActions[action:getID()]
	if newActionID then
		action:setID(newActionID)
		local targetX, targetY = IEex_GetActorLocation(action:getObjectID())
		action:setPointX(targetX)
		action:setPointY(targetY)
	end
end

function B3SpellToPoint()
	IEex_AddActionHook("B3SpellToPointHook")
end

----------------------
-- End Action Hooks --
----------------------

function IEex_Extern_FindScriptingStringClosingParen(actionCString)
	local actionString = IEex_ReadString(IEex_ReadDword(actionCString))
	local inString = false
	for i = 1, #actionString do
		local char = actionString:sub(i, i)
		if char == '"' then
			inString = not inString
		elseif not inString and char == ')' then
			return i - 1
		end
	end
	return -1
end

-- Contract:
--    Construct resultCStringPtr
--    Destruct inCStringPtr
function IEex_Extern_StripScriptingStringWhitespace(resultCStringPtr, inCStringPtr)

	local inString = IEex_ReadString(IEex_ReadDword(inCStringPtr))
	local toBuild = {}
	local insertI = 1
	local IsCharAlphaNumericA = IEex_ReadDword(0x8474EC)
	local inStringParam = false
	local lastChar = nil

	for i = 1, #inString do

		local char = inString:sub(i, i)

		if char == '"' then
			inStringParam = not inStringParam
		elseif not inStringParam and char == "/" and lastChar == "/" then
			break
		end

		if inStringParam or IEex_Call(IsCharAlphaNumericA, {char:byte()}, nil, 0x0) ~= 0 or ({
			["!"] = true, ['"'] = true, ["#"] = true, ["("] = true,
			[")"] = true, ["*"] = true, [","] = true, ["-"] = true,
			["."] = true, ["["] = true, ["]"] = true, ["_"] = true, })[char]
		then
			toBuild[insertI] = char
			insertI = insertI + 1
		end

		lastChar = char
	end

	IEex_RunWithStackManager({
		{ ["name"] = "result", ["struct"] = "string", ["constructor"] = { ["luaArgs"] = { table.concat(toBuild) } } }, },
		function(manager)
			-- CString_Construct
			IEex_Call(0x7FCC88, {manager:getAddress("result")}, resultCStringPtr, 0x0)
		end)

	-- CString_Destruct
	IEex_Call(0x7FCC1A, {}, inCStringPtr, 0x0)
end



function IEex_Extern_CGameSprite_SetCurrAction(actionData)

	IEex_AssertThread(IEex_Thread.Both, true)

	local actionID = IEex_GetActionID(actionData)
	local creatureData = actionData - 0x476
	local actorID = IEex_GetActorIDShare(creatureData)

	IEex_Helper_SetBridge("IEex_GameObjectData", actorID, "realActionID", actionID)

	IEex_Helper_SynchronizedBridgeOperation("IEex_ActionHooks", function()
		IEex_ActionHooks = IEex_Helper_ReadDataFromBridgeNL("IEex_ActionHooks")
		IEex_Helper_ClearBridgeNL("IEex_ActionHooks")
		local limit = #IEex_ActionHooks
		for i = 1, limit, 1 do
			_G[IEex_ActionHooks[i]](IEex_WrapAction(actionData))
		end
	end)

	if creatureData > 0 and bit.band(IEex_ReadDword(creatureData + 0x740), 0x2000000) > 0 and IEex_ReadDword(creatureData + 0x740) > 0 then
		IEex_DisplayString("Action ID " .. actionID .. " from " .. IEex_GetActorName(actorID) .. " - Parameter 1: " .. IEex_GetActionInt1(actionData) .. ", Parameter2: " .. IEex_GetActionInt2(actionData) .. ", Parameter3: " .. IEex_GetActionInt3(actionData) .. ", Target: " .. IEex_GetActionObjectID(actionData) .. ", Target X: " .. IEex_GetActionPointX(actionData) .. ", Target Y: " .. IEex_GetActionPointY(actionData))
	end

	if IEex_GetActorSpellState(actorID, 250) then

		local actorActionHookOpcodeList = {}

		IEex_IterateActorEffects(actorID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			if theopcode == 288 and theparameter2 == 250 then
				actorActionHookOpcodeList[IEex_ReadLString(eData + 0x30, 8)] = eData + 0x4
			end
		end)

		IEex_Helper_SynchronizedBridgeOperation("IEex_OpcodeActionHooks", function()
			local actorActionHookOpcodeListChecked = {}
			IEex_OpcodeActionHooks = IEex_Helper_ReadDataFromBridgeNL("IEex_OpcodeActionHooks")
			for k, v in ipairs(IEex_OpcodeActionHooks) do
				local originatingEffectData = actorActionHookOpcodeList[v]
				if originatingEffectData ~= nil and actorActionHookOpcodeListChecked[v] == nil then
					actorActionHookOpcodeListChecked[v] = true
					_G[v](originatingEffectData, actionData, creatureData)
				end
			end
		end)
	end

	IEex_Helper_SynchronizedBridgeOperation("IEex_GlobalActionHooks", function()
		local actorActionHookGlobalListChecked = {}
		IEex_GlobalActionHooks = IEex_Helper_ReadDataFromBridgeNL("IEex_GlobalActionHooks")
		for k, v in ipairs(IEex_GlobalActionHooks) do
			if actorActionHookGlobalListChecked[v] == nil then
				actorActionHookGlobalListChecked[v] = true
				_G[v](actionData, creatureData)
			end
		end
	end)
end

function EXAPPLSP(actionData, creatureData)
	local actionID = IEex_GetActionID(actionData)
	local sourceID = IEex_GetActorIDShare(creatureData)
	if actionID == 31 or actionID == 95 or actionID == 191 or actionID == 192 then
		local targetID = IEex_GetActionObjectID(actionData)
		if actionID == 191 or actionID == 192 then
			for i = 0, 5, 1 do
				local currentID = IEex_GetActorIDPortrait(i)
				if currentID == sourceID and ex_party_cast_counter[i + 1] ~= nil then
					IEex_WriteWord(creatureData + 0x54E8, ex_party_cast_counter[i + 1])
				end
			end
		end
		local spellRES = IEex_GetActorSpellRES(sourceID)
		local casterClass = IEex_ReadByte(creatureData + 0x530)
		local casterDomain = IEex_ReadByte(creatureData + 0x531)
		local classSpellLevel = IEex_ReadDword(creatureData + 0x534)
		if (actionID == 31 or actionID == 95) and IEex_IsPartyMember(sourceID) and spellRES ~= "SPIN108" then
			local sourceHasSpell = false
			local spells = IEex_FetchSpellInfo(sourceID, {1, 2, 3, 4, 5, 6, 7, 8})
			local hasSpellAsCleric = false
			local hasSpellAsDomain = false
			for i = 1, 9, 1 do
				for cType, levelList in pairs(spells) do
					if #levelList >= i then
						local levelI = levelList[i]
						local maxCastable = levelI[1]
						local sorcererCastableCount = levelI[2]
						local levelISpells = levelI[3]
						if #levelISpells > 0 then
							for i2, spell in ipairs(levelISpells) do
								if spellRES == spell["resref"] then
									if cType == 1 or cType == 6 then
										if sorcererCastableCount > 0 then
											if casterClass == 0 then
												casterClass = IEex_CasterTypeToClass[cType]
												IEex_WriteByte(creatureData + 0x530, casterClass)
												classSpellLevel = i
												IEex_WriteDword(creatureData + 0x534, classSpellLevel)
											end
											sourceHasSpell = true
										end
									else
										if spell["castableCount"] > 0 then
											if casterClass == 0 then
												casterClass = IEex_CasterTypeToClass[cType]
												IEex_WriteByte(creatureData + 0x530, casterClass)
												classSpellLevel = i
												IEex_WriteDword(creatureData + 0x534, classSpellLevel)
											end
											sourceHasSpell = true
											if cType == 2 then
												hasSpellAsCleric = true
											elseif cType == 8 then
												hasSpellAsDomain = true
											end
										end
									end
								end
							end
						end
					end
				end
			end
			if casterClass == 3 and casterDomain == 0 and hasSpellAsDomain and not hasSpellAsCleric then
				local kit = IEex_GetActorStat(sourceID, 89)
				for i = 1, 9, 1 do
					if bit.band(kit, 2 ^ (i + 14)) > 0 then
						casterDomain = i
					end
				end
				if casterDomain > 0 then
					IEex_WriteByte(creatureData + 0x531, casterDomain)
				end
			end
			spells = IEex_FetchSpellInfo(sourceID, {9, 11})
			for cType, levelList in pairs(spells) do
				local levelISpells = levelList[1]
				if levelISpells ~= nil then
					for i2, spell in ipairs(levelISpells) do
						if spellRES == spell["resref"] then
							if cType == 11 then
--								if sorcererCastableCount > 0 then
									sourceHasSpell = true
--								end
							else
								if spell["castableCount"] > 0 then
									sourceHasSpell = true
								end
							end
						end
					end
				end
			end
			if not sourceHasSpell then
				IEex_SetActionID(actionData, 0)
			end
		end
		local resWrapper = IEex_DemandRes(spellRES, "SPL")
		if resWrapper:isValid() then
			local spellData = resWrapper:getData()
			local spellFlags = IEex_ReadDword(spellData + 0x18)
			if bit.band(spellFlags, 0x10000000) > 0 then
				local targetX = IEex_GetActionPointX(actionData)
				local targetY = IEex_GetActionPointY(actionData)
				if actionID == 31 then
					targetX = IEex_ReadDword(IEex_GetActorShare(targetID) + 0x6)
					targetY = IEex_ReadDword(IEex_GetActorShare(targetID) + 0xA)
				elseif actionID == 95 then
					targetID = sourceID
				end
				local casterClass = IEex_ReadByte(creatureData + 0x530)
				if casterClass < 0 then 
					casterClass = 0
				end
				local casterLevel = IEex_GetActorStat(sourceID, 95 + casterClass)
				IEex_SetActionID(actionData, 0)
--				IEex_SetActionObjectID(actionData, IEex_GetActionInt2(actionData))
				IEex_ApplyEffectToActor(targetID, {
					["opcode"] = 402,
					["target"] = 2,
					["timing"] = 1,
					["casterlvl"] = casterLevel + casterClass * 0x100,
					["resource"] = spellRES,
					["parent_resource"] = spellRES,
					["source_x"] = IEex_ReadDword(creatureData + 0x6),
					["source_y"] = IEex_ReadDword(creatureData + 0xA),
					["target_x"] = targetX,
					["target_y"] = targetY,
					["source_target"] = targetID,
					["source_id"] = sourceID
				})
			elseif bit.band(spellFlags, 0x20000000) > 0 then
				if actionID == 31 or actionID == 191 then
					IEex_SetActionID(actionData, 113)
				elseif actionID == 95 or actionID == 192 then
					IEex_SetActionID(actionData, 114)
				end
			end
			if bit.band(spellFlags, 0x40000000) > 0 then
				IEex_ApplyEffectToActor(sourceID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 0,
["parameter1"] = -1,
["parameter2"] = 9,
["special"] = 1,
["savingthrow"] = 0x2000000,
["resource"] = "EXMODMEM",
["vvcresource"] = spellRES,
["casterlvl"] = 1 + casterClass * 0x100,
["source_id"] = sourceID
})
			end
		end
		resWrapper:free()
	end
end

IEex_AddActionHookGlobal("EXAPPLSP")