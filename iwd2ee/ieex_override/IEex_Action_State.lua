
function IEex_AddActionHook(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_ActionHooks", function()
		IEex_AppendBridgeNL("IEex_ActionHooks", funcName)
	end)
end

function IEex_ReaddActionHook(funcName)
	IEex_AppendBridgeNL("IEex_ActionHooks", funcName)
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
	return IEex_ReadWord(actionData, 0)
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

function IEex_Extern_CGameSprite_SetCurrAction(actionData)
	IEex_AssertThread(IEex_Thread.Both, true)
	IEex_Helper_SynchronizedBridgeOperation("IEex_ActionHooks", function()
		IEex_Helper_ReadDataFromBridgeNL("IEex_ActionHooks")
		IEex_Helper_ClearBridgeNL("IEex_ActionHooks")
		local limit = #IEex_ActionHooks
		for i = 1, limit, 1 do
			_G[IEex_ActionHooks[i]](IEex_WrapAction(actionData))
		end
	end)
end
