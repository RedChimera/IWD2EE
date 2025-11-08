
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

function IEex_Debug_GiveRandomItems()

	local actorID = IEex_GetActorIDSelected()
	if not IEex_IsSprite(actorID) then return end

	local sprite = IEex_GetActorShare(actorID)
	local items = sprite + 0x4AD8

	local itemsResrefs = IEex_IndexedResources[IEex_FileExtensionToType("ITM")]
	local numItems = #itemsResrefs

	local shouldGiveItem = function(itemData)
		local itemFlags = IEex_ReadDword(itemData + 0x18)
		if bit.band(itemFlags, 0x4) == 0 then return false end
		local itemIcon = IEex_ReadLString(itemData + 0x3A, 8)
		if itemIcon == "" or itemIcon:lower() == "temp" then return false end
		return true
	end

	local resolveSlot = function(rowIndex, columnIndex, slotIndex)

		local slot = items + slotIndex * 0x4
		local existingItem = IEex_ReadDword(slot)

		if existingItem ~= 0x0 then
			IEex_DestructCItem(existingItem)
			IEex_Free(existingItem)
		end

		while true do

			local randomItemResref = itemsResrefs[math.random(numItems)]

			local wrapper = IEex_DemandRes(randomItemResref, "ITM")
			local willCrash = not wrapper:isValid()
			wrapper:free()

			if not willCrash then

				local item = IEex_CreateCItem(randomItemResref, 0, 0, 0, 0, 1)

				if IEex_IsCItemResValid(item) then

					local itemData = IEex_DemandCItem(item)

					if itemData ~= 0x0 and shouldGiveItem(itemData) then

						local resolvedResref = IEex_GetCItemResref(item)
						local strOut = string.format("%-8s", resolvedResref)

						if resolvedResref ~= randomItemResref then
							strOut = string.format("%s | from %-8s", strOut, randomItemResref)
						else
							strOut = strOut.." |              "
						end

						local nameStrref = IEex_ReadDword(itemData + 0xC)
						print(string.format("Slot %d, INV[%d,%d] = %s | %s", slotIndex, rowIndex, columnIndex, strOut, IEex_FetchString(nameStrref)))

						IEex_UndemandCItem(item)
						IEex_WriteDword(slot, item)
						break
					end

					IEex_UndemandCItem(item)
				end

				IEex_DestructCItem(item)
				IEex_Free(item)
			end
		end
	end

	for rowIndex = 1, 2 do
		local rowSlotBase = 18 + rowIndex - 1
		for columnIndex = 1, 8 do
			resolveSlot(rowIndex, columnIndex, rowSlotBase + (columnIndex - 1) * 2)
		end
	end

	for columnIndex = 1, 8 do
		resolveSlot(3, columnIndex, 33 + columnIndex)
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

function IEex_Extern_Debug_LogPanelInvalidation(panel, rRect, m_rInvalid, esp)

	local rectString = function(rect)
		return "("..IEex_ReadDword(rect)..","..IEex_ReadDword(rect + 0x4)..","..IEex_ReadDword(rect + 0x8)..","..IEex_ReadDword(rect + 0xC)..")"
	end

	if rRect == 0x0 then
		print(IEex_GetCurrentThreadName().." ["..IEex_ToHex(IEex_ReadDword(esp)).."] panel "..IEex_GetPanelID(panel).." being completely invalidated, new m_rInvalid: "..rectString(m_rInvalid))
	else
		print(IEex_GetCurrentThreadName().." ["..IEex_ToHex(IEex_ReadDword(esp)).."] panel "..IEex_GetPanelID(panel).." being invalidated with "..rectString(rRect)..", new m_rInvalid: "..rectString(m_rInvalid))
	end
end

function IEex_Extern_Debug_LogButtonInvalidation(button, esp)
	local panelID = IEex_GetPanelID(IEex_GetControlPanel(button))
	local controlID = IEex_GetControlID(button)
	print(IEex_GetCurrentThreadName().." ["..IEex_ToHex(IEex_ReadDword(esp)).."] panel "..panelID.." control "..controlID.." being invalidated")
end

function IEex_Extern_Debug_LogButtonInvalidationReset(button, esp)
	local panelID = IEex_GetPanelID(IEex_GetControlPanel(button))
	local controlID = IEex_GetControlID(button)
	print(IEex_GetCurrentThreadName().." ["..IEex_ToHex(IEex_ReadDword(esp)).."] panel "..panelID.." control "..controlID.." invalidation reset")
end
