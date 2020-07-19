
---------------
-- Functions --
---------------

function IEex_SetViewportBottom(bottom)
	IEex_WriteDword(IEex_GetCInfinity() + 0x48 + 0xC, bottom)
end

function IEex_PanelInvalidateRect(CUIPanel, left, top, right, bottom)
	local rect = IEex_Malloc(0x10)
	IEex_WriteDword(rect + 0x0, left)
	IEex_WriteDword(rect + 0x4, top)
	IEex_WriteDword(rect + 0x8, right)
	IEex_WriteDword(rect + 0xC, bottom)
	IEex_Call(0x4D3810, {rect}, CUIPanel, 0x0)
	IEex_Free(rect)
end

function IEex_PanelInvalidate(CUIPanel)
	IEex_Call(0x4D3810, {0x0}, CUIPanel, 0x0)
end

function IEex_GetPanelArea(CUIManager)
	local x = IEex_ReadDword(CUIManager + 0x24)
	local y = IEex_ReadDword(CUIManager + 0x28)
	local w = IEex_ReadDword(CUIManager + 0x34)
	local h = IEex_ReadDword(CUIManager + 0x38)
	return x, y, w, h
end

function IEex_GetPanel(CUIManager, panelID)
	return IEex_Call(0x4D4000, {panelID}, CUIManager, 0x0)
end

function IEex_GetUIManagerFromEngine(CBaldurEngine)
	return CBaldurEngine + 0x30
end

function IEex_GetPanelFromEngine(CBaldurEngine, panelID)
	return IEex_GetPanel(CBaldurEngine + 0x30, panelID)
end

function IEex_IsPanelActive(CUIPanel)
	return IEex_ReadDword(CUIPanel + 0xF4) == 1
end

function IEex_SetPanelActive(CUIPanel, active)
	IEex_Call(0x4D3980, {active and 1 or 0}, CUIPanel, 0x0)
end

function IEex_GetControlID(CUIControl)
	return IEex_ReadDword(CUIControl + 0xA)
end

function IEex_GetContainerType(CGameContainer)
	return IEex_ReadWord(CGameContainer + 0x5CA, 0)
end

function IEex_GetContainerIDType(containerID)
	local share = IEex_GetActorShare(containerID)
	local toReturn = IEex_GetContainerType(share)
	IEex_UndoActorShare(containerID)
	return toReturn
end

function IEex_GetContainerNumItems(CGameContainer)
	return IEex_ReadDword(CGameContainer + 0x5AE + 0xC)
end

function IEex_GetContainerIDNumItems(containerID)
	local share = IEex_GetActorShare(containerID)
	local toReturn = IEex_GetContainerNumItems(share)
	IEex_UndoActorShare(containerID)
	return toReturn
end

function IEex_GetGroundPilesAroundActor(actorID)

	local toReturn = {}

	local share = IEex_GetActorShare(actorID)
	if share == 0x0 then return toReturn end
	local area = IEex_ReadDword(share + 0x12)
	if area == 0x0 then return toReturn end

	local actorX, actorY = IEex_GetActorLocation(actorID)
	local m_lVertSortBack = area + 0x9AE

	local defaultContainerID = -1

	IEex_IterateCPtrList(m_lVertSortBack, function(containerID)

		local containerShare = IEex_GetActorShare(containerID)
		if IEex_ReadByte(containerShare + 0x4, 0) ~= 0x11 then return end

		defaultContainerID = containerID

		if IEex_GetContainerType(containerShare) ~= 4 then return end -- Only ground piles
		if not IEex_CheckActorLOSObject(actorID, containerID) then return end
		if IEex_GetContainerNumItems(containerShare) <= 0 then return end

		local containerX, containerY = IEex_GetActorLocation(containerID)
		local distance = IEex_GetDistanceIsometric(actorX, actorY, containerX, containerY)
		table.insert(toReturn, {["containerID"] = containerID, ["distance"] = distance})

		IEex_UndoActorShare(containerID)
	end)

	table.sort(toReturn, function(a, b)
		return a.distance < b.distance
	end)

	if defaultContainer == -1 then
		local newContainer = IEex_Call(0x5B75C0, {actorID}, IEex_GetGameData(), 0x0)
		defaultContainerID = IEex_GetActorIDShare(newContainer)
	end

	toReturn.defaultContainerID = defaultContainerID
	return toReturn
end

-------------------------
-- Quickloot Functions --
-------------------------

IEex_Quickloot_On = false
IEex_Quickloot_Active = false
IEex_Quickloot_Items = {}
IEex_Quickloot_ItemsAccessIndex = 1
IEex_Quickloot_DefaultContainerID = 0
IEex_Quickloot_OldActorX = -1
IEex_Quickloot_OldActorY = -1

function IEex_Quickloot_Start()
	IEex_Quickloot_On = true
end

function IEex_Quickloot_Stop()
	IEex_Quickloot_On = false
	IEex_Quickloot_Hide()
end

function IEex_Quickloot_Show()
	IEex_Quickloot_UpdateItems()
	IEex_SetPanelActive(IEex_Quickloot_GetPanel(), true)
	local _, y, _, _ = IEex_GetPanelArea(IEex_GetPanelFromEngine(IEex_GetEngineWorld(), 23))
	IEex_SetViewportBottom(y)
	IEex_Quickloot_Active = true
end

function IEex_Quickloot_Hide(changeViewport)
	IEex_SetPanelActive(IEex_Quickloot_GetPanel(), false)
	if changeViewport or changeViewport == nil then
		local _, y, _, h = IEex_GetPanelArea(IEex_GetPanelFromEngine(IEex_GetEngineWorld(), 23))
		IEex_SetViewportBottom(y + h)
	end
	IEex_Quickloot_Active = false
end

function IEex_Quickloot_UpdateItems()

	local actorID = IEex_Quickloot_GetValidPartyMember()
	local piles = IEex_GetGroundPilesAroundActor(actorID)

	IEex_Quickloot_Items = {}
	IEex_Quickloot_DefaultContainerID = piles.defaultContainerID

	for _, pile in ipairs(piles) do
		local maxIndex = IEex_GetContainerIDNumItems(pile.containerID) - 1
		for i = 0, maxIndex, 1 do
			table.insert(IEex_Quickloot_Items, {["containerID"] = pile.containerID, ["slotIndex"] = i})
		end
	end

	-- If actor moved, force list back to start
	local actorX, actorY = IEex_GetActorLocation(actorID)

	if actorX ~= IEex_Quickloot_OldActorX or IEex_Quickloot_OldActorY ~= actorY then
		IEex_Quickloot_ItemsAccessIndex = 1
	end

	IEex_Quickloot_OldActorX = actorX
	IEex_Quickloot_OldActorY = actorY
	IEex_Quickloot_InvalidatePanel()
end

function IEex_Quickloot_GetSlotData(controlID)

	local entry = IEex_Quickloot_Items[IEex_Quickloot_ItemsAccessIndex + controlID]
	if entry then
		return entry
	else
		return {
			["containerID"] = IEex_Quickloot_DefaultContainerID,
			["slotIndex"] = IEex_GetContainerIDNumItems(IEex_Quickloot_DefaultContainerID),
		}
	end
end

function IEex_Quickloot_GetValidPartyMember()
	local actorID = IEex_GetActorIDSelected()
	if actorID == -1 then
		for i = 0, 5, 1 do
			actorID = IEex_GetActorIDPortrait(i)
			if IEex_IsSprite(actorID) then break end
		end
	end
	return actorID
end

function IEex_Quickloot_GetPanel()
	return IEex_GetPanelFromEngine(IEex_GetEngineWorld(), 23)
end

function IEex_Quickloot_InvalidatePanel()
	IEex_PanelInvalidate(IEex_Quickloot_GetPanel())
end

function IEex_Quickloot_IsPanelActive()
	return IEex_IsPanelActive(IEex_Quickloot_GetPanel())
end

function IEex_Quickloot_ScrollLeft(control)
	IEex_Quickloot_ItemsAccessIndex = math.max(1, IEex_Quickloot_ItemsAccessIndex - 10)
end

function IEex_Quickloot_ScrollRight(control)
	local maxIndex = math.max(1, #IEex_Quickloot_Items - 10 + 1)
	IEex_Quickloot_ItemsAccessIndex = math.min(IEex_Quickloot_ItemsAccessIndex + 10, maxIndex)
end

-------------------
-- GUI Constants --
-------------------

IEex_PanelActiveByDefault = {
	["GUIW08"] = {
		[23] = false,
	},
	["GUIW10"] = {
		[23] = false,
	},
}

IEex_ControlTypeMaxIndex = 0
IEex_ControlType = {
	["ButtonWorldContainerSlot"] = 0,
}

IEex_ControlTypeMeta = {
	[IEex_ControlType.ButtonWorldContainerSlot] = { ["constructor"] = 0x6956F0, ["size"] = 0x666 },
}

IEex_ControlOverrides = {
	["GUIW08"] = {
		[23] = {
			[0] = IEex_ControlType.ButtonWorldContainerSlot,
			[1] = IEex_ControlType.ButtonWorldContainerSlot,
			[2] = IEex_ControlType.ButtonWorldContainerSlot,
			[3] = IEex_ControlType.ButtonWorldContainerSlot,
			[4] = IEex_ControlType.ButtonWorldContainerSlot,
			[5] = IEex_ControlType.ButtonWorldContainerSlot,
			[6] = IEex_ControlType.ButtonWorldContainerSlot,
			[7] = IEex_ControlType.ButtonWorldContainerSlot,
			[8] = IEex_ControlType.ButtonWorldContainerSlot,
			[9] = IEex_ControlType.ButtonWorldContainerSlot,
		},
	},
	["GUIW10"] = {
		[23] = {
			[0] = IEex_ControlType.ButtonWorldContainerSlot,
			[1] = IEex_ControlType.ButtonWorldContainerSlot,
			[2] = IEex_ControlType.ButtonWorldContainerSlot,
			[3] = IEex_ControlType.ButtonWorldContainerSlot,
			[4] = IEex_ControlType.ButtonWorldContainerSlot,
			[5] = IEex_ControlType.ButtonWorldContainerSlot,
			[6] = IEex_ControlType.ButtonWorldContainerSlot,
			[7] = IEex_ControlType.ButtonWorldContainerSlot,
			[8] = IEex_ControlType.ButtonWorldContainerSlot,
			[9] = IEex_ControlType.ButtonWorldContainerSlot,
		},
	},
}

-- The following functions / definitions are just enough for simple on-click buttons.

function IEex_AddControlOverride(resref, panelID, controlID, controlType)

	local resrefOverride = IEex_ControlOverrides[resref]
	if not resrefOverride then
		resrefOverride = {}
		IEex_ControlOverrides[resref] = resrefOverride
	end

	panelOverride = resrefOverride[panelID]
	if not panelOverride then
		panelOverride = {}
		IEex_ControlOverrides[panelID] = panelOverride
	end

	panelOverride[controlID] = controlType
end

function IEex_DefineCustomButtonControl(controlName, args)

	-- Fill defaults
	local newButtonVFTable = IEex_Malloc(0x78)
	local currentFillAddress = newButtonVFTable
	for i = 0x84C984, 0x84C9F8, 0x4 do
		IEex_WriteDword(currentFillAddress, IEex_ReadDword(i))
		currentFillAddress = currentFillAddress + 0x4
	end

	local writeType = {
		["BYTE"]   = 0,
		["WORD"]   = 1,
		["DWORD"]  = 2,
		["RESREF"] = 3,
	}

	local writeTypeFunc = {
		[writeType.BYTE]   = IEex_WriteByte,
		[writeType.WORD]   = IEex_WriteWord,
		[writeType.DWORD]  = IEex_WriteDword,
		[writeType.RESREF] = function(address, arg) IEex_WriteLString(address, arg, 0x8) end,
	}

	local argFailType = {
		["ERROR"]   = 0,
		["DEFAULT"] = 1,
		["NOTHING"] = 2,
	}

	local writeArgs = function(address, writeDefs)
		for _, writeDef in ipairs(writeDefs) do
			local argKey = writeDef[1]
			local arg = args[argKey]
			if not arg then
				local failType = writeDef[4]
				if failType == argFailType.DEFAULT then
					arg = writeDef[5]
				elseif failType ~= argFailType.NOTHING then
					IEex_Error(argKey.." must be defined!")
				end
			end
			writeTypeFunc[writeDef[3]](address + writeDef[2], arg)
		end
	end

	writeArgs(newButtonVFTable, {
		{ "OnLButtonClick", 0x68, writeType.DWORD, argFailType.NOTHING },
	})

	IEex_ControlTypeMaxIndex = IEex_ControlTypeMaxIndex + 1
	IEex_ControlType[controlName] = IEex_ControlTypeMaxIndex

	local newConstructor = IEex_WriteAssemblyAuto({[[

		!push_esi
		!mov_esi_ecx

		!push_byte 01
		!push_byte 01
		!push_[esp+byte] 14
		!push_[esp+byte] 14
		!mov_ecx_esi
		!call :4D47D0

		!mov_[esi]_dword ]], {newButtonVFTable, 4}, [[
		!mov_eax_esi
		!pop_esi

		!ret_word 08 00
	]]})

	IEex_ControlTypeMeta[IEex_ControlTypeMaxIndex] = {
		["constructor"] = newConstructor,
		["size"] = 0x666,
	}
end

(function()

	-------------------------------
	-- IEex_Quickloot_ScrollLeft --
	-------------------------------

	local IEex_Quickloot_ScrollLeft_OnLButtonClick = IEex_WriteAssemblyAuto({[[

		!push_complete_state

		; control ;
		!push_ecx

		!push_dword ]], {IEex_WriteStringAuto("IEex_Quickloot_ScrollLeft"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; control ;
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError

		!pop_complete_state
		!ret_word 08 00

	]]})

	IEex_DefineCustomButtonControl("IEex_Quickloot_ScrollLeft", {
		["OnLButtonClick"] = IEex_Quickloot_ScrollLeft_OnLButtonClick,
	})

	--------------------------------
	-- IEex_Quickloot_ScrollRight --
	--------------------------------

	local IEex_Quickloot_ScrollRight_OnLButtonClick = IEex_WriteAssemblyAuto({[[

		!push_complete_state

		; control ;
		!push_ecx

		!push_dword ]], {IEex_WriteStringAuto("IEex_Quickloot_ScrollRight"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; control ;
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError

		!pop_complete_state
		!ret_word 08 00

	]]})

	IEex_DefineCustomButtonControl("IEex_Quickloot_ScrollRight", {
		["OnLButtonClick"] = IEex_Quickloot_ScrollRight_OnLButtonClick,
	})

	-------------------------------
	-- Dynamic Control Overrides --
	-------------------------------

	IEex_AddControlOverride("GUIW08", 23, 10, IEex_ControlType.IEex_Quickloot_ScrollLeft)
	IEex_AddControlOverride("GUIW10", 23, 10, IEex_ControlType.IEex_Quickloot_ScrollLeft)
	IEex_AddControlOverride("GUIW08", 23, 11, IEex_ControlType.IEex_Quickloot_ScrollRight)
	IEex_AddControlOverride("GUIW10", 23, 11, IEex_ControlType.IEex_Quickloot_ScrollRight)

end)()

------------------------
-- GUI Hook Functions --
------------------------

-- Helpful comment: The following function names are too long.

function IEex_Extern_CUIControlBase_CreateControl(resrefPointer, panel, controlInfo)

	local resref = IEex_ReadLString(resrefPointer, 8)
	local panelID = IEex_ReadDword(panel + 0x20)
	local controlID = IEex_ReadDword(controlInfo)

	local resrefOverride = IEex_ControlOverrides[resref]
	if not resrefOverride then return 0x0 end

	panelOverride = resrefOverride[panelID]
	if not panelOverride then return 0x0 end

	local controlOverride = panelOverride[controlID]
	if not controlOverride then return 0x0 end

	local controlMeta = IEex_ControlTypeMeta[controlOverride]

	if not controlMeta then
		IEex_TracebackMessage("IEex Critical Error - No metadata defined for IEex_ControlType "..controlOverride)
		return 0x0
	end

	local control = IEex_Malloc(controlMeta.size)
	IEex_Call(controlMeta.constructor, {controlInfo, panel}, control, 0x0)

	return control
end

function IEex_Extern_CUIManager_fInit_CHUInitialized(CUIManager, resrefPointer)

	local resref = IEex_ReadLString(resrefPointer, 8)

	local resrefOverride = IEex_PanelActiveByDefault[resref]
	if not resrefOverride then return end

	for panelID, active in pairs(resrefOverride) do
		local panel = IEex_GetPanel(CUIManager, panelID)
		IEex_SetPanelActive(panel, active)
	end
end

function IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetActiveContainerID(control)
	if not IEex_Quickloot_Active then return -1 end
	return IEex_Quickloot_GetSlotData(IEex_GetControlID(control)).containerID
end

function IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetActiveContainerSpriteID(control)
	if not IEex_Quickloot_Active then return -1 end
	return IEex_Quickloot_GetValidPartyMember()
end

function IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetContainerItemIndex(control)
	if not IEex_Quickloot_Active then return -1 end
	return IEex_Quickloot_GetSlotData(IEex_GetControlID(control)).slotIndex
end

function IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_Done(control)
	local maxIndex = math.max(1, #IEex_Quickloot_Items - 10)
	IEex_Quickloot_ItemsAccessIndex = math.min(IEex_Quickloot_ItemsAccessIndex, maxIndex)
	IEex_Quickloot_InvalidatePanel()
end

function IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_IsQuicklootActive(control)
	return IEex_Quickloot_IsPanelActive()
end

IEex_Extern_CScreenWorld_ScheduledTasks = {
	["blocks"] = {},
	["tasks"] = {
		-- {["tickDelay"] = 1, ["func"] = function() end},
	},
}

function IEex_Extern_CScreenWorld_ScheduleTask(blockingKey, tickDelay, func)

	if blockingKey then
		if IEex_Extern_CScreenWorld_ScheduledTasks.blocks[blockingKey] then
			return
		else
			IEex_Extern_CScreenWorld_ScheduledTasks.blocks[blockingKey] = true
		end
	end

	table.insert(IEex_Extern_CScreenWorld_ScheduledTasks.tasks, {
		["blockingKey"] = blockingKey,
		["tickDelay"] = tickDelay,
		["func"] = func,
	})
end

function IEex_Extern_CScreenWorld_TimerSynchronousUpdate()

	if IEex_Quickloot_On then

		local worldScreen = IEex_GetEngineWorld()
		local panelActive = IEex_Quickloot_IsPanelActive()
		
		-- Need to hide if dialog / container is present
		if panelActive and (
			   IEex_IsPanelActive(IEex_GetPanelFromEngine(worldScreen, 7)) 
			or IEex_IsPanelActive(IEex_GetPanelFromEngine(worldScreen, 8)))
		then
			IEex_Quickloot_Hide(false)
		elseif IEex_IsPanelActive(IEex_GetPanelFromEngine(worldScreen, 1)) then
			-- This calls IEex_Quickloot_UpdateItems() internally.
			-- It's a little ineffecient to call this every tick,
			-- but this is the only way I've found to maintain state
			-- correctly when dialog / opening containers screws around
			-- with the viewport.
			IEex_Quickloot_Show()
		end

		-- The following allows some ability to schedule tasks for later, (while the worldscreen is active).
		-- For future use.

		local runningTasks = IEex_Extern_CScreenWorld_ScheduledTasks
		IEex_Extern_CScreenWorld_ScheduledTasks = {
			["blocks"] = {},
			["tasks"] = {},
		}

		for i, scheduledTask in ipairs(runningTasks.tasks) do
			if scheduledTask.tickDelay <= 0 then
				if scheduledTask.blockingKey then
					IEex_Extern_CScreenWorld_ScheduledTasks.blocks[blockingKey] = nil
				end
				scheduledTask.func()
			else
				scheduledTask.tickDelay = scheduledTask.tickDelay - 1
				table.insert(IEex_Extern_CScreenWorld_ScheduledTasks, scheduledTask)
			end
		end

	end
end

function IEex_Extern_CScreenWorld_OnInventoryButtonRClick()
	if IEex_Quickloot_On then
		IEex_Quickloot_Stop()
	else
		IEex_Quickloot_Start()
	end
end

(function()

	IEex_DisableCodeProtection()

	local activeContainerIDFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetActiveContainerID")
	local activeContainerSpriteIDFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetActiveContainerSpriteID")
	local containerItemIndexFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_GetContainerItemIndex")
	local quicklootActiveFuncName = IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_IsQuicklootActive")

	--------------------
	--- GUI Hooks ASM --
	--------------------

	-- CUIControlBase_CreateControl
	IEex_HookJump(0x76D41B, 0, {[[

		!push_registers_iwd2

		!xor_ebx_ebx
		!jnz_dword >original_fail
		!mov_ebx #1

		@original_fail

		; CHU resref ;
		!push_edx

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CUIControlBase_CreateControl"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; CHU resref ;
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; panel ;
		!push_edi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; controlInfo ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 03
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError
		!test_eax_eax
		!jz_dword >ok
		!xor_eax_eax
		!jmp_dword >error

		@ok
		!push_byte 00
		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!push_eax
		!push_byte FE
		!push_dword *_g_lua
		!call >_lua_settop
		!add_esp_byte 08
		!pop_eax

		@error
		!test_eax_eax
		!jz_dword >not_custom
		!pop_registers_iwd2
		!jmp_dword :76E93F

		@not_custom
		!test_ebx_ebx
		!pop_registers_iwd2
		!jnz_dword >jmp_success
		!jmp_dword >jmp_fail
	]]})

	-- CUIManager_fInit
	IEex_HookBeforeCall(0x4D3D55, {[[

		!push_all_registers_iwd2

		; resref ;
		!push_[ecx+byte] 10

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CUIManager_fInit_CHUInitialized"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; CUIManager ;
		!push_esi
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		; resref ;
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 02
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2
	]]})

	IEex_WriteAssemblyAuto({[[

		$IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_IsQuicklootActive
		!push_registers_iwd2

		!push_dword ]], {quicklootActiveFuncName, 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 00
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError
		!jz_dword >ok
		!xor_eax_eax
		!jmp_dword >error

		@ok
		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_toboolean
		!add_esp_byte 08
		!push_eax
		!push_byte FE
		!push_dword *_g_lua
		!call >_lua_settop
		!add_esp_byte 08
		!pop_eax

		@error
		!pop_registers_iwd2
		!ret
	]]})

	-- 0x695C8E OnLButtonClick - CUIControlScrollBarWorldContainer_UpdateScrollBar
	IEex_HookBeforeCall(0x695C8E, {[[
		!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_IsQuicklootActive
		!test_eax_eax
		!jnz_dword >return
	]]})

	-- 0x696080 OnLButtonClick - CUIControlEncumbrance_SetVolume
	IEex_HookBeforeCall(0x696080, {[[
		!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_IsQuicklootActive
		!test_eax_eax
		!jz_dword >call
		!add_esp_byte 08
		!jmp_dword >return
	]]})

	-- 0x69608D OnLButtonClick - CUIControlEncumbrance_SetEncumbrance
	IEex_HookBeforeCall(0x69608D, {[[
		!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_IsQuicklootActive
		!test_eax_eax
		!jz_dword >call
		!add_esp_byte 08
		!jmp_dword >return
	]]})

	-- 0x69608D OnLButtonClick - CUIControlLabel_SetText
	IEex_HookBeforeCall(0x6960EE, {[[
		!call >IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_IsQuicklootActive
		!test_eax_eax
		!jz_dword >call
		!add_esp_byte 04
		!jmp_dword >return
	]]})

	-- push func_name
	-- push arg
	IEex_WriteAssemblyAuto({[[

		$IEex_CallIntsOneArgOneReturn
		!push_state

		!push_[ebp+byte] 0C
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; arg ;
		!push_[ebp+byte] 08
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError
		!jz_dword >ok
		!mov_eax #FFFFFFFF
		!jmp_dword >error

		@ok
		!push_byte 00
		!push_byte FF
		!push_dword *_g_lua
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!push_eax
		!push_byte FE
		!push_dword *_g_lua
		!call >_lua_settop
		!add_esp_byte 08
		!pop_eax

		@error
		!pop_state
		!ret_word 08 00
	]]})

	-- 0x69589C OnLButtonClick - activeContainerID
	IEex_HookRestore(0x69589C, 0, 6, {[[
		!push_dword ]], {activeContainerIDFuncName, 4}, [[
		!push_[esp+byte] 08
		!call >IEex_CallIntsOneArgOneReturn
		!cmp_eax_byte FF
		!jne_dword >return_skip
	]]})

	-- 0x6958C7 OnLButtonClick - activeContainerSpriteID
	IEex_HookRestore(0x6958C7, 0, 6, {[[
		!push_dword ]], {activeContainerSpriteIDFuncName, 4}, [[
		!push_[esp+byte] 08
		!call >IEex_CallIntsOneArgOneReturn
		!mov_esi_eax
		!cmp_eax_byte FF
		!jne_dword >return_skip
	]]})

	-- 0x6959A3 OnLButtonClick - m_nTopContainerRow
	IEex_HookRestore(0x6959A3, 0, 8, {[[

		; save eax because I clobber it ;
		!push_eax

		!push_dword ]], {containerItemIndexFuncName, 4}, [[
		!push_[esp+byte] 0C
		!call >IEex_CallIntsOneArgOneReturn
		!cmp_eax_byte FF

		!jne_dword >override
		; restore eax ;
		!pop_eax
		!jmp_dword >return

		@override
		!mov_edi_eax
		; clear eax off of stack (only matters when running normal code) ;
		!add_esp_byte 04
		!mov_[esp+byte]_edi 34
		!jmp_dword >return_skip
	]]})

	-- 0x696208 Render - activeContainerSpriteID
	IEex_HookRestore(0x696208, 0, 6, {[[
		!push_dword ]], {activeContainerSpriteIDFuncName, 4}, [[
		!push_esi
		!call >IEex_CallIntsOneArgOneReturn
		!cmp_eax_byte FF
		!jne_dword >return_skip
	]]})

	-- 0x69623F Render - activeContainerID
	IEex_HookRestore(0x69623F, 0, 6, {[[
		!push_dword ]], {activeContainerIDFuncName, 4}, [[
		!push_esi
		!call >IEex_CallIntsOneArgOneReturn
		!mov_ebx_eax
		!cmp_eax_byte FF
		!jne_dword >return_skip
	]]})

	-- 0x69627D Render - m_nTopContainerRow
	IEex_HookRestore(0x69627D, 0, 8, {[[

		; save eax because I clobber it ;
		!push_eax

		!push_dword ]], {containerItemIndexFuncName, 4}, [[
		!push_esi
		!call >IEex_CallIntsOneArgOneReturn
		!cmp_eax_byte FF
		!jne_dword >override

		; restore eax ;
		!pop_eax
		!jmp_dword >return

		@override
		; clear eax off of stack (I'm overriding it) ;
		!add_esp_byte 04
		!lea_ecx_[esp+byte] 2C
		!mov_[esp+byte]_edi 34
		!jmp_dword >return_skip
	]]})

	IEex_HookRestore(0x696107, 0, 7, {[[

		!push_complete_state

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CUIControlButtonWorldContainerSlot_OnLButtonClick_Done"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; control ;
		!push_[ebp+byte] 08
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_dword *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 01
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError

		!pop_complete_state
	]]})

	IEex_HookBeforeCall(0x68DF87, {[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CScreenWorld_TimerSynchronousUpdate"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2
	]]})

	-- Enable right-click on inventory button
	IEex_WriteAssembly(0x77CFD6, {"!mov_eax 03"})

	IEex_WriteDword(0x85D798, IEex_WriteAssemblyAuto({[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_Extern_CScreenWorld_OnInventoryButtonRClick"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2
		!ret_word 08 00
	]]}))

	IEex_EnableCodeProtection()

end)()
