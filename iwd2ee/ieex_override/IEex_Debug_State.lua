
------------
-- Spells --
------------

function IEex_Debug_GiveAllWizardSpells()

	local actorID = IEex_GetActorIDSelected()
	if not IEex_IsSprite(actorID) then return end

	local base = "SPWI"

	for i = 100, 999, 1 do
		local resref = base..string.format("%03d", i)
		local level = math.floor(i / 100)
		IEex_SetSpellInfo(actorID, IEex_CasterType.Wizard, level, resref, 999, 999)
	end
end

------------------------------------
-- IEex_Debug_CompressTime = true --
------------------------------------

IEex_Helper_InitBridgeFromTable("IEex_Debug_SpamRestCounter", {
	["max"] = -1,
	["i"] = 0,
})

function IEex_Extern_Debug_OnCompressTime()
	IEex_Helper_SynchronizedBridgeOperation("IEex_Debug_SpamRestCounter", function()
		local max = IEex_Helper_GetBridgeNL("IEex_Debug_SpamRestCounter", "max")
		local i = IEex_Helper_GetBridgeNL("IEex_Debug_SpamRestCounter", "i")
		if i <= max then
			print("rest call #"..i.."...")
			IEex_Helper_SetBridgeNL("IEex_Debug_SpamRestCounter", "i", i + 1)
			IEex_Call(0x5C1160, {0, 1}, IEex_GetGameData(), 0x0)
		end
	end)
end

function IEex_Debug_SpamRest(numTimes)
	if numTimes <= 0 then return end
	IEex_Helper_SynchronizedBridgeOperation("IEex_Debug_SpamRestCounter", function()
		IEex_Helper_SetBridgeNL("IEex_Debug_SpamRestCounter", "max", numTimes)
		IEex_Helper_SetBridgeNL("IEex_Debug_SpamRestCounter", "i", 2)
		print("rest call #1...")
		IEex_Call(0x5C1160, {0, 1}, IEex_GetGameData(), 0x0)
	end)
end
