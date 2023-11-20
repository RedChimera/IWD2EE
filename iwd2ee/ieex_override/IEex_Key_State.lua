
IEex_KeyIDS = {
	["LEFT_MOUSE_CLICK"] = 1,
	["RIGHT_MOUSE_CLICK"] = 2,
	["MIDDLE_MOUSE_CLICK"] = 4,
	["BACKSPACE"] = 8,
	["TAB"] = 9,
	["ENTER"] = 13,
	["ESC"] = 27,
	["SPACE_BAR"] = 32,
	["PAGE_UP"] = 33,
	["PAGE_DOWN"] = 34,
	["END"] = 35,
	["HOME"] = 36,
	["LEFT"] = 37,
	["UP"] = 38,
	["RIGHT"] = 39,
	["DOWN"] = 40,
	["PRINT_SCREEN"] = 44,
	["DELETE"] = 46,
	["0"] = 48,
	["1"] = 49,
	["2"] = 50,
	["3"] = 51,
	["4"] = 52,
	["5"] = 53,
	["6"] = 54,
	["7"] = 55,
	["8"] = 56,
	["9"] = 57,
	["A"] = 65,
	["B"] = 66,
	["C"] = 67,
	["D"] = 68,
	["E"] = 69,
	["F"] = 70,
	["G"] = 71,
	["H"] = 72,
	["I"] = 73,
	["J"] = 74,
	["K"] = 75,
	["L"] = 76,
	["M"] = 77,
	["N"] = 78,
	["O"] = 79,
	["P"] = 80,
	["Q"] = 81,
	["R"] = 82,
	["S"] = 83,
	["T"] = 84,
	["U"] = 85,
	["V"] = 86,
	["W"] = 87,
	["X"] = 88,
	["Y"] = 89,
	["Z"] = 90,
	["NUMPAD0"] = 96,
	["NUMPAD1"] = 97,
	["NUMPAD2"] = 98,
	["NUMPAD3"] = 99,
	["NUMPAD4"] = 100,
	["NUMPAD5"] = 101,
	["NUMPAD6"] = 102,
	["NUMPAD7"] = 103,
	["NUMPAD8"] = 104,
	["NUMPAD9"] = 105,
	["F1"] = 112,
	["F2"] = 113,
	["F3"] = 114,
	["F4"] = 115,
	["F5"] = 116,
	["F6"] = 117,
	["F7"] = 118,
	["F8"] = 119,
	["F9"] = 120,
	["F10"] = 121,
	["F11"] = 122,
	["F12"] = 123,
	["LEFT_SHIFT"] = 160,
	["RIGHT_SHIFT"] = 161,
	["LEFT_CTRL"] = 162,
	["RIGHT_CTRL"] = 163,
	["LEFT_ALT"] = 164,
	["RIGHT_ALT"] = 165,
	["LEFT_SHIFT"] = 166,
}

IEex_Keys = IEex_Default( {}, IEex_Keys)
IEex_Helper_InitBridgeFromTable("IEex_Keys", function()
	for key = 0x1, 0xFE, 1 do
		IEex_Keys[key] = {["isDown"] = false}
	end
end)

-- These need to be readded every IEex_Reload()

function IEex_AddKeyPressedListener(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_KeyPressedListeners", function()
		IEex_AppendBridgeNL("IEex_KeyPressedListeners", funcName)
	end)
end

function IEex_AddKeyReleasedListener(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_KeyReleasedListeners", function()
		IEex_AppendBridgeNL("IEex_KeyReleasedListeners", funcName)
	end)
end

function IEex_AddInputStateListener(funcName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_InputStateListeners", function()
		IEex_AppendBridgeNL("IEex_InputStateListeners", funcName)
	end)
end

function IEex_IsKeyDown(key)
	return IEex_Helper_GetBridge("IEex_Keys", key, "isDown")
end

-- Signals the Raw Input implementation to act as if it received a RAWKEYBOARD / RAWMOUSE event (up or down).
--
-- Note: Does not spoof key repeat events.
--
-- Changes are only detected by the engine once per async tick; run "fake input" functions in
-- IEex_Extern_BeforeCheckKeys() to ensure correct timing.
function IEex_FakeKeyEvent(key, isDown)
	IEex_Helper_FakeKeyEvent(key, isDown)
end

-- Signals the Raw Input implementation to act as if it received RAWKEYBOARD / RAWMOUSE events (down + up).
--
-- Changes are only detected by the engine once per async tick; run "fake input" functions in
-- IEex_Extern_BeforeCheckKeys() to ensure correct timing.
function IEex_FakeKeyPress(key)
	IEex_Helper_FakeKeyEvent(key, true)
	IEex_Helper_FakeKeyEvent(key, false)
end

-- Causes the cursor to report a fake position to the engine / Lua.
--
-- Changes are only detected by the engine once per async tick; run "fake input" functions in
-- IEex_Extern_BeforeCheckKeys() to ensure correct timing.
function IEex_StartFakingCursorPos(initialX, initialY)
	IEex_Helper_LockGlobal("IEex_FakeCursorPosMem")
	IEex_WriteDword(IEex_FakeCursorPosMem, 1)
	IEex_WriteDword(IEex_FakeCursorPosMem + 4, initialX or 0)
	IEex_WriteDword(IEex_FakeCursorPosMem + 8, initialY or 0)
	IEex_Helper_UnlockGlobal("IEex_FakeCursorPosMem")
end

-- Moves the fake cursor.
--
-- Changes are only detected by the engine once per async tick; run "fake input" functions in
-- IEex_Extern_BeforeCheckKeys() to ensure correct timing.
function IEex_FakeCursorPos(x, y)
	IEex_Helper_LockGlobal("IEex_FakeCursorPosMem")
	IEex_WriteDword(IEex_FakeCursorPosMem + 4, x)
	IEex_WriteDword(IEex_FakeCursorPosMem + 8, y)
	IEex_Helper_UnlockGlobal("IEex_FakeCursorPosMem")
end

-- Returns the cursor to normal.
--
-- Changes are only detected by the engine once per async tick; run "fake input" functions in
-- IEex_Extern_BeforeCheckKeys() to ensure correct timing.
function IEex_StopFakingCursorPos()
	IEex_Helper_LockGlobal("IEex_FakeCursorPosMem")
	IEex_WriteDword(IEex_FakeCursorPosMem, 0)
	IEex_Helper_UnlockGlobal("IEex_FakeCursorPosMem")
end

IEex_FakeInputRoutineEvent = {
	FUNCTION = 0,      -- { IEex_FakeInputRoutineEvent.FUNCTION, function(state, eventT) -> IEex_FakeInputRoutineReturn }
	UP = 1,            -- { IEex_FakeInputRoutineEvent.UP, IEex_KeyIDS.<key> }
	DOWN = 2,          -- { IEex_FakeInputRoutineEvent.DOWN, IEex_KeyIDS.<key> }
	PRESS = 3,         -- { IEex_FakeInputRoutineEvent.PRESS, IEex_KeyIDS.<key> }
	SET_MOUSE_POS = 4, -- { IEex_FakeInputRoutineEvent.SET_MOUSE_POS, clientX, clientY }
	CLICK_CONTROL = 5, -- { IEex_FakeInputRoutineEvent.CLICK_CONTROL, <alowed CHU resrefs; table or string>, panelID, controlID }
	WAIT = 6,          -- { IEex_FakeInputRoutineEvent.WAIT, <minimum number of microseconds> }
}

IEex_FakeInputRoutineReturn = {
	CONTINUE = 0,             -- Process the next entry (next tick)
	CONTINUE_IMMEDIATELY = 1, -- Process the next entry (now)
	WAIT = 2,                 -- Process the same entry next tick
	END = 3,                  -- Terminate the fake input routine early
}

-- Allows a fake input routine to be started / stopped from any thread
IEex_FakeInputRoutine = {
	["active"] = false,
	["routine"] = nil,
}
IEex_Helper_InitBridgeFromTable("IEex_FakeInputRoutine", IEex_FakeInputRoutine)

-- Starts a fake input routine from any thread
function IEex_StartFakeInputRoutine(fakeInputRoutine, stopKey, alreadyLockedBridge)
	local doStart = function(bridge)
		IEex_Helper_SetBridgeNL(bridge, "active", true)
		IEex_Helper_SetBridgeNL(bridge, "routine", fakeInputRoutine)
		IEex_Helper_SetBridgeNL(bridge, "stopKey", stopKey)
	end
	if alreadyLockedBridge == nil then
		IEex_Helper_SynchronizedBridgeOperation("IEex_FakeInputRoutine", doStart)
	else
		doStart(alreadyLockedBridge)
	end
end

-- Stops the currently executing fake input routine from any thread
function IEex_StopFakeInputRoutine(alreadyLockedBridge)
	local doStop = function(bridge)
		IEex_Helper_SetBridgeNL(bridge, "active", false)
		IEex_Helper_SetBridgeNL(bridge, "routine", nil)
	end
	if alreadyLockedBridge == nil then
		IEex_Helper_SynchronizedBridgeOperation("IEex_FakeInputRoutine", doStop)
	else
		doStop(alreadyLockedBridge)
	end
end

-- From any thread, either:
--   * Starts a fake input routine if none are currently active
--   * Else stops the currently executing fake input routine
function IEex_StartOrStopFakeInputRoutine(fakeInputRoutine, stopKey)
	IEex_Helper_SynchronizedBridgeOperation("IEex_FakeInputRoutine", function(bridge)
		if not IEex_Helper_GetBridgeNL(bridge, "active") then
			IEex_StartFakeInputRoutine(fakeInputRoutine, stopKey, bridge)
		else
			IEex_StopFakeInputRoutine(bridge)
		end
	end)
end

IEex_Helper_InitBridgeFromTable("IEex_FakeInputRoutineStartStopKeys", {})

-- Registers keys that start/stop a fake input routine
function IEex_RegisterFakeInputRoutineStartStopKeys(uniqueKeybindingName, fakeInputRoutine, startKey, stopKey)
	IEex_Helper_SynchronizedBridgeOperation("IEex_FakeInputRoutineStartStopKeys", function(bridge)
		local i = IEex_Helper_GetBridgeNL(bridge, uniqueKeybindingName)
		if i == nil then
			i = IEex_Helper_GetBridgeNumIntsNL(bridge) + 1
			IEex_Helper_SetBridgeNL(bridge, uniqueKeybindingName, i)
		end
		IEex_Helper_SetBridgeNL(bridge, i, {
			["routine"] = fakeInputRoutine,
			["startKey"] = startKey,
			["stopKey"] = stopKey,
		})
	end)
end

-- Unregisters keys that start/stop a fake input routine
function IEex_UnregisterFakeInputRoutineStartStopKeys(uniqueKeybindingName)
	IEex_Helper_SynchronizedBridgeOperation("IEex_FakeInputRoutineStartStopKeys", function(bridge)
		local i = IEex_Helper_GetBridgeNL(bridge, uniqueKeybindingName)
		if i ~= nil then
			IEex_Helper_EraseBridgeKeyNL(bridge, uniqueKeybindingName)
			IEex_Helper_EraseBridgeKeyNL(bridge, i)
		end
	end)
end

function IEex_CheckViewPosition()
	local pInfinity = IEex_GetCInfinity()
	local nNewX = IEex_ReadDword(pInfinity + 0x40)
	local nNewY = IEex_ReadDword(pInfinity + 0x44)
	-- CInfinity_SetViewPosition
	IEex_Call(0x5D11F0, {0, nNewY, nNewX}, pInfinity, 0x0)
end

function IEex_AdjustViewPosition(deltaX, deltaY)

	local infinity = IEex_GetCInfinity()
	local m_ptCurrentPosExact_x = IEex_ReadDword(infinity + 0x164)
	local m_ptCurrentPosExact_y = IEex_ReadDword(infinity + 0x168)

	m_ptCurrentPosExact_x = m_ptCurrentPosExact_x + deltaX * 10000
	m_ptCurrentPosExact_y = m_ptCurrentPosExact_y + deltaY * 10000
	IEex_WriteDword(infinity + 0x164, m_ptCurrentPosExact_x)
	IEex_WriteDword(infinity + 0x168, m_ptCurrentPosExact_y)

	-- CInfinity_SetViewPosition
	IEex_Call(0x5D11F0, {0, math.floor(m_ptCurrentPosExact_y / 10000), math.floor(m_ptCurrentPosExact_x / 10000)}, infinity, 0x0)
end

function IEex_AdjustViewPositionFromScrollState(scrollState, delta)
	if scrollState == 6 or scrollState == 7 or scrollState == 8 then
		IEex_AdjustViewPosition(-delta, 0)
	end
	if scrollState == 2 or scrollState == 3 or scrollState == 4 then
		IEex_AdjustViewPosition(delta, 0)
	end
	if scrollState == 1 or scrollState == 2 or scrollState == 8 then
		IEex_AdjustViewPosition(0, -delta)
	end
	if scrollState == 4 or scrollState == 5 or scrollState == 6 then
		IEex_AdjustViewPosition(0, delta)
	end
end

function IEex_Key_ReloadListener()
	IEex_Helper_ClearBridge("IEex_KeyPressedListeners")
	IEex_Helper_ClearBridge("IEex_KeyReleasedListeners")
	IEex_Helper_ClearBridge("IEex_InputStateListeners")
	IEex_ReaddReloadListener("IEex_Key_ReloadListener")
end

IEex_AbsoluteOnce("IEex_Key_RegisterReloadListener", function()
	IEex_AddReloadListener("IEex_Key_ReloadListener")
end)

---------------
-- Scrolling --
---------------

IEex_Scroll_KeyLeft  = IEex_KeyIDS.LEFT
IEex_Scroll_KeyRight = IEex_KeyIDS.RIGHT
IEex_Scroll_KeyUp    = IEex_KeyIDS.UP
IEex_Scroll_KeyDown  = IEex_KeyIDS.DOWN

IEex_Helper_InitBridgeFromTable("IEex_Scroll_MiddleMouseState", {
	["isDown"] = false,
	["oldX"] = 0,
	["oldY"] = 0,
})

function IEex_Scroll_CalculateDeltaFactor()
	local toReturn = 1
	IEex_Helper_StoreMicroseconds("curTick")
	if IEex_Helper_ExistsMicroseconds("lastTick") then
		local diff = IEex_Helper_GetMicrosecondsDiff("curTick", "lastTick")
		toReturn = diff / 25000
	end
	IEex_Helper_AssignMicroseconds("lastTick", "curTick")
	return toReturn
end

function IEex_Scroll_CheckMultiScrollState(m_nKeyScrollState)
	if m_nKeyScrollState == 1 then
		if IEex_IsKeyDown(IEex_Scroll_KeyLeft) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD4) then
			m_nKeyScrollState = 8
		elseif IEex_IsKeyDown(IEex_Scroll_KeyRight) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD6) then
			m_nKeyScrollState = 2
		end
	elseif m_nKeyScrollState == 3 then
		if IEex_IsKeyDown(IEex_Scroll_KeyUp) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD8) then
			m_nKeyScrollState = 2
		elseif IEex_IsKeyDown(IEex_Scroll_KeyDown) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD2) then
			m_nKeyScrollState = 4
		end
	elseif m_nKeyScrollState == 5 then
		if IEex_IsKeyDown(IEex_Scroll_KeyRight) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD6) then
			m_nKeyScrollState = 4
		elseif IEex_IsKeyDown(IEex_Scroll_KeyLeft) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD4) then
			m_nKeyScrollState = 6
		end
	elseif m_nKeyScrollState == 7 then
		if IEex_IsKeyDown(IEex_Scroll_KeyDown) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD2) then
			m_nKeyScrollState = 6
		elseif IEex_IsKeyDown(IEex_Scroll_KeyUp) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD8) then
			m_nKeyScrollState = 8
		end
	end
	return m_nKeyScrollState
end

function IEex_Scroll_KeyPressedListener(key)

	if key == IEex_KeyIDS.MIDDLE_MOUSE_CLICK then
		IEex_Helper_SynchronizedBridgeOperation("IEex_Scroll_MiddleMouseState", function()
			IEex_Helper_SetBridgeNL("IEex_Scroll_MiddleMouseState", "isDown", true)
			local oldX, oldY = IEex_GetCursorXY()
			IEex_Helper_SetBridgeNL("IEex_Scroll_MiddleMouseState", "oldX", oldX)
			IEex_Helper_SetBridgeNL("IEex_Scroll_MiddleMouseState", "oldY", oldY)
		end)
	end

	if IEex_GetActiveEngine() == IEex_GetEngineWorld() then
		local visibleArea = IEex_GetVisibleArea()
		if visibleArea ~= 0x0 then
			local m_nKeyScrollStateAddress = visibleArea + 0x23C
			local m_nKeyScrollState = IEex_ReadDword(m_nKeyScrollStateAddress)
			IEex_WriteDword(m_nKeyScrollStateAddress, IEex_Scroll_CheckMultiScrollState(m_nKeyScrollState))
		end
	end
end

function IEex_Scroll_KeyReleasedListener(key)

	if key == IEex_KeyIDS.MIDDLE_MOUSE_CLICK then
		IEex_Helper_SetBridge("IEex_Scroll_MiddleMouseState", "isDown", false)
	end

	if IEex_GetActiveEngine() == IEex_GetEngineWorld() then

		local visibleArea = IEex_GetVisibleArea()
		if visibleArea ~= 0x0 then

			local m_nKeyScrollStateAddress = visibleArea + 0x23C
			local m_nKeyScrollState = IEex_ReadDword(m_nKeyScrollStateAddress)

			if key == IEex_Scroll_KeyLeft or key == IEex_KeyIDS.NUMPAD4 then
				if IEex_IsKeyDown(IEex_Scroll_KeyRight) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD6) then
					m_nKeyScrollState = IEex_Scroll_CheckMultiScrollState(3)
				elseif m_nKeyScrollState == 6 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD1) then
					m_nKeyScrollState = 5
				elseif m_nKeyScrollState == 7 then
					m_nKeyScrollState = 0
				elseif m_nKeyScrollState == 8 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD7) then
					m_nKeyScrollState = 1
				end
			elseif key == IEex_Scroll_KeyRight or key == IEex_KeyIDS.NUMPAD6 then
				if IEex_IsKeyDown(IEex_Scroll_KeyLeft) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD4) then
					m_nKeyScrollState = IEex_Scroll_CheckMultiScrollState(7)
				elseif m_nKeyScrollState == 2 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD9) then
					m_nKeyScrollState = 1
				elseif m_nKeyScrollState == 3 then
					m_nKeyScrollState = 0
				elseif m_nKeyScrollState == 4 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD3) then
					m_nKeyScrollState = 5
				end
			elseif key == IEex_Scroll_KeyUp or key == IEex_KeyIDS.NUMPAD8 then
				if IEex_IsKeyDown(IEex_Scroll_KeyDown) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD2) then
					m_nKeyScrollState = IEex_Scroll_CheckMultiScrollState(5)
				elseif m_nKeyScrollState == 1 then
					m_nKeyScrollState = 0
				elseif m_nKeyScrollState == 2 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD9) then
					m_nKeyScrollState = 3
				elseif m_nKeyScrollState == 8 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD7) then
					m_nKeyScrollState = 7
				end
			elseif key == IEex_Scroll_KeyDown or key == IEex_KeyIDS.NUMPAD2 then
				if IEex_IsKeyDown(IEex_Scroll_KeyUp) or IEex_IsKeyDown(IEex_KeyIDS.NUMPAD8) then
					m_nKeyScrollState = IEex_Scroll_CheckMultiScrollState(1)
				elseif m_nKeyScrollState == 4 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD3) then
					m_nKeyScrollState = 3
				elseif m_nKeyScrollState == 5 then
					m_nKeyScrollState = 0
				elseif m_nKeyScrollState == 6 and not IEex_IsKeyDown(IEex_KeyIDS.NUMPAD1) then
					m_nKeyScrollState = 7
				end
			elseif (key == IEex_KeyIDS.NUMPAD7 and m_nKeyScrollState == 8)
				or (key == IEex_KeyIDS.NUMPAD9 and m_nKeyScrollState == 2)
				or (key == IEex_KeyIDS.NUMPAD3 and m_nKeyScrollState == 4)
				or (key == IEex_KeyIDS.NUMPAD1 and m_nKeyScrollState == 6)
			then
				m_nKeyScrollState = 0
			end

			IEex_WriteDword(m_nKeyScrollStateAddress, m_nKeyScrollState)
		end
	end
end

ex_buff_reactivate_cooldown = 3
ex_buff_activate_tick = 0
ex_buff_recorded_list = {{}, {}, {}, {}, {}, {}, }
function IEex_BuffRecordingListener(key)
--	if IEex_IsKeyDown(IEex_KeyIDS.LEFT_ALT) or IEex_IsKeyDown(IEex_KeyIDS.RIGHT_ALT) then
	if ex_enable_autobuffing_keys then
		if key == 221 then
			IEex_SetGlobal("EX_Recording_Buffs", 0)
			IEex_DisplayString(IEex_FetchString(ex_tra_55707))
			for i = 0, 5, 1 do
				local actorID = IEex_GetActorIDPortrait(i)
				IEex_IterateActorEffects(actorID, function(eData)
					local theopcode = IEex_ReadDword(eData + 0x10)
					local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
					if theopcode == 0 and theparent_resource == "EXBUFFRC" then
						IEex_WriteDword(eData + 0x114, 1)
					end
				end)
			end
		elseif key == 219 then
			if IEex_GetGlobal("EX_Recording_Buffs") == 0 then
				IEex_SetGlobal("EX_Recording_Buffs", 1)
				IEex_DisplayString(IEex_FetchString(ex_tra_55708))
			else
				IEex_SetGlobal("EX_Recording_Buffs", 0)
				IEex_DisplayString(IEex_FetchString(ex_tra_55709))
			end
		elseif key == 186 then
			local tick = IEex_GetGameTick()
			if IEex_GetGlobal("EX_Recording_Buffs") == 0 and tick > IEex_GetGlobal("EX_Recording_Reactivate_Tick") then
				IEex_SetGlobal("EX_Recording_Reactivate_Tick", tick + ex_buff_reactivate_cooldown * 15)
				local foundRecordedBuff = false
				for i = 0, 5, 1 do
					local recordedBuffs = {}
					local actorID = IEex_GetActorIDPortrait(i)
					IEex_IterateActorEffects(actorID, function(eData)
						local theopcode = IEex_ReadDword(eData + 0x10)
						local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
						if theopcode == 0 and theparent_resource == "EXBUFFRC" and IEex_ReadDword(eData + 0x114) ~= 1 then
							if not foundRecordedBuff then
								foundRecordedBuff = true
								IEex_DisplayString(IEex_FetchString(ex_tra_55710))
							end
							local theresource = IEex_ReadLString(eData + 0x30, 8)
							local theparameter3 = IEex_ReadDword(eData + 0x60)
							local theparameter4 = IEex_ReadDword(eData + 0x64)
							table.insert(recordedBuffs, {theresource, theparameter3, theparameter4})
						end
					end)
					local sourceX, sourceY = IEex_GetActorLocation(actorID)
					for k, v in ipairs(recordedBuffs) do
						local targetID = IEex_GetActorIDCharacter(v[2])
						if IEex_IsSprite(targetID, false) and IEex_CheckActorLOSObject(actorID, targetID) then
--[[
							IEex_ApplyEffectToActor(actorID, {
["opcode"] = 500,
["target"] = 2,
["timing"] = 4,
["duration"] = k,
["parameter3"] = v[2],
["parameter4"] = v[3],
["resource"] = "MEBUFFCA",
["vvcresource"] = v[1],
["parent_resource"] = "EXBUFFCA",
["source_id"] = actorID
})
--]]

							if v[3] == 0 then
								IEex_Eval('SpellRES(\"' .. v[1] .. '\",Player' .. (v[2] + 1) .. ')',i)
							else
								IEex_Eval('SpellPointRES(\"' .. v[1] .. '\",[' .. sourceX .. '.' .. sourceY .. '])',i)
							end
							IEex_Eval('SmallWait(1)',i)

						end
					end
				end
				if not foundRecordedBuff then
					IEex_DisplayString(IEex_FetchString(ex_tra_55714))
				end
			end
		end
	end
end

ex_debug_counter = 0
function IEex_ExtraCheatKeysListener(key)
--[[
	if ex_debug_counter == 30 then
		ex_debug_counter = 0

		local gameData = IEex_GetGameData()
		if gameData > 0 then
			IEex_DS(IEex_ReadDword(gameData + 0x3328))
		end
	else
		ex_debug_counter = ex_debug_counter + 1
	end
--]]
	if IEex_IsKeyDown(IEex_KeyIDS.LEFT_CTRL) or IEex_IsKeyDown(IEex_KeyIDS.RIGHT_CTRL) then
		if key == IEex_KeyIDS.V then
			local actorID = IEex_GetActorIDCursor()
			if IEex_IsSprite(actorID, false) then
				local share = IEex_GetActorShare(actorID)
				local extraFlags = IEex_ReadDword(share + 0x740)
				if bit.band(extraFlags, 0x1000000) == 0 then
					IEex_DisplayString("Opcode printing on " .. IEex_GetActorName(actorID) .. " enabled")
					IEex_WriteDword(share + 0x740, bit.bor(extraFlags, 0x1000000))
				else
					IEex_DisplayString("Opcode printing on " .. IEex_GetActorName(actorID) .. " disabled")
					IEex_WriteDword(share + 0x740, bit.band(extraFlags, 0xFEFFFFFF))
				end
			end
		elseif key == IEex_KeyIDS.N then
			local actorID = IEex_GetActorIDCursor()
			if IEex_IsSprite(actorID, false) then
				local share = IEex_GetActorShare(actorID)
				local extraFlags = IEex_ReadDword(share + 0x740)
				if bit.band(extraFlags, 0x2000000) == 0 then
					IEex_DisplayString("Action printing on " .. IEex_GetActorName(actorID) .. " enabled")
					IEex_WriteDword(share + 0x740, bit.bor(extraFlags, 0x2000000))
				else
					IEex_DisplayString("Action printing on " .. IEex_GetActorName(actorID) .. " disabled")
					IEex_WriteDword(share + 0x740, bit.band(extraFlags, 0xFDFFFFFF))
				end
			end
		end
	end
end
ex_chargen_ability_strrefs = {17247, 14838, 14840, 9582, 9584, 9583, 9585, 9586, 9587, }
ex_base_ability_score_cre_offset = {0x802, 0x805, 0x806, 0x803, 0x804, 0x807}
ex_chargen_reroll_key = IEex_KeyIDS.Z
ex_chargen_store_key = IEex_KeyIDS.X
ex_chargen_recall_key = IEex_KeyIDS.C
ex_chargen_reallocate_key = IEex_KeyIDS.V
ex_chargen_ability_buttons_pressed = {[16] = false, [17] = false, [18] = false, [19] = false, [20] = false, [21] = false, [22] = false, [23] = false, [24] = false, [25] = false, [26] = false, [27] = false, }
ex_ability_scores_initialized = false
ex_extra_feats_granted = false
ex_extra_skill_points_granted = false
ex_current_remaining_points = ex_new_ability_score_total_points
ex_recorded_remaining_points = 0
racialAbilityBonuses = {0, 0, 0, 0, 0, 0}
currentAbilityScores = {0, 0, 0, 0, 0, 0}
recordedAbilityScores = {0, 0, 0, 0, 0, 0}
unallocatedAbilityScores = {}
recordedUnallocatedAbilityScores = {}
function IEex_Chargen_ExtraFeatListener()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local chargenData = IEex_ReadDword(g_pBaldurChitin + 0x1C64)
	if chargenData > 0 then
		local actorID = IEex_ReadDword(chargenData + 0x4E2)
		local share = IEex_GetActorShare(actorID)
		if share > 0 then
			ex_randomizer = math.random(6)
			local panelID = IEex_GetEngineCreateCharPanelID()
			if panelID == -1 then return end
			local racePlusSub = IEex_ReadByte(share + 0x26, 0x0) * 0x10000 + IEex_ReadByte(share + 0x3E3D, 0x0)
			if panelID == 4 or panelID == 53 then
				if not ex_ability_scores_initialized then
					ex_ability_scores_initialized = true
					if ex_subrace_name[racePlusSub] ~= nil then
						local racePlusSubName = ex_subrace_name[racePlusSub]
						racialAbilityBonuses[1] = tonumber(IEex_2DAGetAtStrings("ABRACEAD", "MOD_STR", racePlusSubName))
						racialAbilityBonuses[2] = tonumber(IEex_2DAGetAtStrings("ABRACEAD", "MOD_DEX", racePlusSubName))
						racialAbilityBonuses[3] = tonumber(IEex_2DAGetAtStrings("ABRACEAD", "MOD_CON", racePlusSubName))
						racialAbilityBonuses[4] = tonumber(IEex_2DAGetAtStrings("ABRACEAD", "MOD_INT", racePlusSubName))
						racialAbilityBonuses[5] = tonumber(IEex_2DAGetAtStrings("ABRACEAD", "MOD_WIS", racePlusSubName))
						racialAbilityBonuses[6] = tonumber(IEex_2DAGetAtStrings("ABRACEAD", "MOD_CHR", racePlusSubName))
					end
					if ex_new_ability_score_system == 1 or ex_new_ability_score_system == 2 then
						if ex_new_ability_score_system == 2 then
							IEex_WriteDword(chargenData + 0x4EA, ex_current_remaining_points)
						end
						if currentAbilityScores[1] == 0 and #unallocatedAbilityScores == 0 then
							IEex_Chargen_Reroll()
						else
							for i = 1, 6, 1 do
								IEex_WriteByte(share + ex_base_ability_score_cre_offset[i], currentAbilityScores[i])
							end
							IEex_Chargen_UpdateAbilityScores(chargenData, share)
						end
					elseif ex_new_ability_score_system == 3 then
						IEex_WriteDword(chargenData + 0x4EA, ex_new_ability_score_total_points)
						for i = 1, 6, 1 do
							currentAbilityScores[i] = IEex_ReadByte(share + ex_base_ability_score_cre_offset[i], currentAbilityScores[i])
						end
					end
					IEex_EngineCreateCharUpdatePopupPanel()
				end
				if panelID == 4 and ex_new_ability_score_system == 1 then
					local panelData = IEex_ReadDword(IEex_ReadDword(chargenData + 0x53E) + 0x8)
					IEex_IterateCPtrList(panelData + 0x4, function(controlData)
						local controlIndex = IEex_ReadByte(controlData + 0xA, 0x0)
						if ex_chargen_ability_buttons_pressed[controlIndex] ~= nil then
							local buttonWasPressed = ex_chargen_ability_buttons_pressed[controlIndex]
							local buttonIsPressed = (IEex_ReadByte(controlData + 0x134, 0x0) > 0)
							if buttonWasPressed and not buttonIsPressed then
								if controlIndex == 16 or controlIndex == 18 or controlIndex == 20 or controlIndex == 22 or controlIndex == 24 or controlIndex == 26 then
									local a = math.floor(controlIndex / 2) - 7
									if currentAbilityScores[a] == 0 and #unallocatedAbilityScores > 0 then
										IEex_WriteByte(share + ex_base_ability_score_cre_offset[a], table.remove(unallocatedAbilityScores) + racialAbilityBonuses[a])
--										currentAbilityScores[a] = table.remove(unallocatedAbilityScores) + racialAbilityBonuses[a]
									end
								elseif controlIndex == 17 or controlIndex == 19 or controlIndex == 21 or controlIndex == 23 or controlIndex == 25 or controlIndex == 27 then
									local a = math.floor(controlIndex / 2) - 7
									if currentAbilityScores[a] > 0 and #unallocatedAbilityScores < 6 then
										table.insert(unallocatedAbilityScores, currentAbilityScores[a] - racialAbilityBonuses[a])
										table.sort(unallocatedAbilityScores)
										IEex_WriteByte(share + ex_base_ability_score_cre_offset[a], 0)
--										currentAbilityScores[a] = 0
									end
								end
								IEex_Chargen_UpdateAbilityScores(chargenData, share)
							end
							ex_chargen_ability_buttons_pressed[controlIndex] = buttonIsPressed
						end
					end)
					if #unallocatedAbilityScores > 0 then
						IEex_IterateCPtrList(panelData + 0x4, function(controlData)
							if IEex_ReadDword(controlData) == 8732244 then
								IEex_WriteByte(controlData + 0x1E, 0)
								IEex_WriteByte(controlData + 0x32, 1)
								IEex_WriteByte(controlData + 0x116, 3)
							end
						end)
					else
						IEex_IterateCPtrList(panelData + 0x4, function(controlData)
							if IEex_ReadDword(controlData) == 8732244 then
								IEex_WriteByte(controlData + 0x1E, 1) 
								IEex_WriteByte(controlData + 0x32, 0)
								IEex_WriteByte(controlData + 0x116, 1)
							end
						end)
					end
				elseif panelID == 4 and ex_new_ability_score_system == 3 then
					local panelData = IEex_ReadDword(IEex_ReadDword(chargenData + 0x53E) + 0x8)
					IEex_IterateCPtrList(panelData + 0x4, function(controlData)
						local controlIndex = IEex_ReadByte(controlData + 0xA, 0x0)
						if ex_chargen_ability_buttons_pressed[controlIndex] ~= nil then
							local buttonWasPressed = ex_chargen_ability_buttons_pressed[controlIndex]
							local buttonIsPressed = (IEex_ReadByte(controlData + 0x134, 0x0) > 0)
							if buttonWasPressed or buttonIsPressed then
--[[
								if controlIndex == 16 or controlIndex == 18 or controlIndex == 20 or controlIndex == 22 or controlIndex == 24 or controlIndex == 26 then
									local a = math.floor(controlIndex / 2) - 7
									if currentAbilityScores[a] == 0 and #unallocatedAbilityScores > 0 then
										currentAbilityScores[a] = table.remove(unallocatedAbilityScores) + racialAbilityBonuses[a]
									end
								elseif controlIndex == 17 or controlIndex == 19 or controlIndex == 21 or controlIndex == 23 or controlIndex == 25 or controlIndex == 27 then
									local a = math.floor(controlIndex / 2) - 7
									local newAbilityScore = IEex_ReadByte(share + ex_base_ability_score_cre_offset[a], 0x0)
									if currentAbilityScores[a] ~ then
										table.insert(unallocatedAbilityScores, currentAbilityScores[a] - racialAbilityBonuses[a])
										table.sort(unallocatedAbilityScores)
										currentAbilityScores[a] = 0
									end
								end
--]]
								IEex_Chargen_UpdateAbilityScores(chargenData, share)
							end
							ex_chargen_ability_buttons_pressed[controlIndex] = buttonIsPressed
						end
					end)
				end
			else
				if (panelID == 2 or panelID == 8 or ex_new_ability_score_system == 3) and (currentAbilityScores[1] > 0 or #unallocatedAbilityScores > 0) then
					ex_current_remaining_points = ex_new_ability_score_total_points
					ex_recorded_remaining_points = 0
					racialAbilityBonuses = {0, 0, 0, 0, 0, 0}
					currentAbilityScores = {0, 0, 0, 0, 0, 0}
					recordedAbilityScores = {0, 0, 0, 0, 0, 0}
					unallocatedAbilityScores = {}
					recordedUnallocatedAbilityScores = {}
				end
				if ex_ability_scores_initialized then
					ex_ability_scores_initialized = false
--					IEex_WriteDword(chargenData + 0x4EA, 0)
				end
			end
			if panelID == 6 then
				if not ex_extra_skill_points_granted and ex_extra_skill_point_races[racePlusSub] ~= nil then
					ex_extra_skill_points_granted = true
					local skillPointsRemaining = IEex_ReadDword(chargenData + 0x4F2)
					skillPointsRemaining = skillPointsRemaining + ex_extra_skill_point_races[racePlusSub]
					if racePlusSub == 0x10000 then
						skillPointsRemaining = skillPointsRemaining - 2
					end
					IEex_WriteDword(chargenData + 0x4F2, skillPointsRemaining)
					IEex_EngineCreateCharUpdatePopupPanel()
				end
			else
				if ex_extra_skill_points_granted then
					ex_extra_skill_points_granted = false
					IEex_WriteDword(chargenData + 0x4F2, 0)
				end
			end
			if panelID == 55 then
				if not ex_extra_feats_granted and ex_extra_feat_races[racePlusSub] ~= nil then
					ex_extra_feats_granted = true
					local featsRemaining = IEex_ReadDword(chargenData + 0x4E6)
					featsRemaining = featsRemaining + ex_extra_feat_races[racePlusSub]
					if racePlusSub == 0x10000 or racePlusSub == 0x50001 then
						featsRemaining = featsRemaining - 1
					end
					IEex_WriteDword(chargenData + 0x4E6, featsRemaining)
					IEex_EngineCreateCharUpdatePopupPanel()
				end
			else
				if ex_extra_feats_granted then
					ex_extra_feats_granted = false
					IEex_WriteDword(chargenData + 0x4E6, 0)
				end
			end
		end
	end
end
ex_starting_level = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}
ex_starting_skill_points = -1
ex_class_level_up = {["numLevelUps"] = -1, ["class"] = -1}
ex_levelup_extra_skill_points_granted = false
function IEex_LevelUp_ExtraFeatListener()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local levelUpData = IEex_ReadDword(g_pBaldurChitin + 0x1C60)
	if levelUpData > 0 then
		local actorID = IEex_ReadDword(levelUpData + 0x136)
		local share = IEex_GetActorShare(actorID)
		local panelID = IEex_GetEngineCharacterPanelID()
		if panelID <= 0 and ex_starting_level[1] ~= -1 then
			ex_starting_level = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}
			ex_starting_skill_points = -1
			ex_class_level_up["numLevelUps"] = -1
			ex_class_level_up["class"] = -1
		end
		if share > 0 then
			if panelID == 54 then
				if ex_starting_level[1] == -1 then
					for i = 1, 12, 1 do
						ex_starting_level[i] = IEex_ReadByte(share + i + 0x625, 0x0)
					end
					ex_starting_skill_points = IEex_ReadByte(share + 0x8A3, 0x0)
				end
				if ex_class_level_up["numLevelUps"] ~= -1 then
					ex_class_level_up["numLevelUps"] = -1
					ex_class_level_up["class"] = -1
				end
			elseif panelID > 0 and panelID ~= 2 then
				if IEex_ReadByte(share + 0x626, 0x0) > ex_starting_level[1] and ex_starting_level[1] ~= -1 and ex_class_level_up["numLevelUps"] == -1 then
					ex_class_level_up["numLevelUps"] = IEex_ReadByte(share + 0x626, 0x0) - ex_starting_level[1]
					for i = 2, 12, 1 do
						if IEex_ReadByte(share + i + 0x625, 0x0) > ex_starting_level[i] then
							ex_class_level_up["class"] = i - 1
						end
					end
				end
			end
--			local racePlusSub = IEex_ReadByte(share + 0x26, 0x0) * 0x10000 + IEex_ReadByte(share + 0x3E3D, 0x0)
--[[
			if panelID == 7 then
				if not ex_ability_scores_initialized then
					ex_ability_scores_initialized = true
					if ex_subrace_name[racePlusSub] ~= nil then
						local racePlusSubName = ex_subrace_name[racePlusSub]
						racialAbilityBonuses[1] = tonumber(IEex_2DAGetAtStrings("ABRACEAD", "MOD_STR", racePlusSubName))
						racialAbilityBonuses[2] = tonumber(IEex_2DAGetAtStrings("ABRACEAD", "MOD_DEX", racePlusSubName))
						racialAbilityBonuses[3] = tonumber(IEex_2DAGetAtStrings("ABRACEAD", "MOD_CON", racePlusSubName))
						racialAbilityBonuses[4] = tonumber(IEex_2DAGetAtStrings("ABRACEAD", "MOD_INT", racePlusSubName))
						racialAbilityBonuses[5] = tonumber(IEex_2DAGetAtStrings("ABRACEAD", "MOD_WIS", racePlusSubName))
						racialAbilityBonuses[6] = tonumber(IEex_2DAGetAtStrings("ABRACEAD", "MOD_CHR", racePlusSubName))
					end
					if ex_new_ability_score_system == 2 then
						IEex_WriteDword(chargenData + 0x4EA, ex_current_remaining_points)
						for i = 1, 6, 1 do
							IEex_WriteByte(share + ex_base_ability_score_cre_offset[i], currentAbilityScores[i])
						end
					end
					if ex_new_ability_score_system == 1 or ex_new_ability_score_system == 2 then
						if currentAbilityScores[1] == 0 and #unallocatedAbilityScores == 0 then
							IEex_Chargen_Reroll()
						else
							IEex_Chargen_UpdateAbilityScores(chargenData, share)
						end
					end
					IEex_EngineCreateCharUpdatePopupPanel()
				end
				if panelID == 4 and ex_new_ability_score_system == 1 then
					local panelData = IEex_ReadDword(IEex_ReadDword(chargenData + 0x53E) + 0x8)
					IEex_IterateCPtrList(panelData + 0x4, function(controlData)
						local controlIndex = IEex_ReadByte(controlData + 0xA, 0x0)
						if ex_chargen_ability_buttons_pressed[controlIndex] ~= nil then
							local buttonWasPressed = ex_chargen_ability_buttons_pressed[controlIndex]
							local buttonIsPressed = (IEex_ReadByte(controlData + 0x134, 0x0) > 0)
							if buttonWasPressed and not buttonIsPressed then
								if controlIndex == 16 or controlIndex == 18 or controlIndex == 20 or controlIndex == 22 or controlIndex == 24 or controlIndex == 26 then
									local a = math.floor(controlIndex / 2) - 7
									if currentAbilityScores[a] == 0 and #unallocatedAbilityScores > 0 then
										currentAbilityScores[a] = table.remove(unallocatedAbilityScores) + racialAbilityBonuses[a]
									end
								elseif controlIndex == 17 or controlIndex == 19 or controlIndex == 21 or controlIndex == 23 or controlIndex == 25 or controlIndex == 27 then
									local a = math.floor(controlIndex / 2) - 7
									if currentAbilityScores[a] > 0 and #unallocatedAbilityScores < 6 then
										table.insert(unallocatedAbilityScores, currentAbilityScores[a] - racialAbilityBonuses[a])
										table.sort(unallocatedAbilityScores)
										currentAbilityScores[a] = 0
									end
								end
								IEex_Chargen_UpdateAbilityScores(chargenData, share)
							end
							ex_chargen_ability_buttons_pressed[controlIndex] = buttonIsPressed
						end
					end)
					if #unallocatedAbilityScores > 0 then
						IEex_IterateCPtrList(panelData + 0x4, function(controlData)
							if IEex_ReadDword(controlData) == 8732244 then
								IEex_WriteByte(controlData + 0x1E, 0)
								IEex_WriteByte(controlData + 0x32, 1)
								IEex_WriteByte(controlData + 0x116, 3)
							end
						end)
					else
						IEex_IterateCPtrList(panelData + 0x4, function(controlData)
							if IEex_ReadDword(controlData) == 8732244 then
								IEex_WriteByte(controlData + 0x1E, 1)
								IEex_WriteByte(controlData + 0x32, 0)
								IEex_WriteByte(controlData + 0x116, 1)
							end
						end)
					end
				end
			else
				if (panelID == 2 or panelID == 8) and (currentAbilityScores[1] > 0 or #unallocatedAbilityScores > 0) then
					racialAbilityBonuses = {0, 0, 0, 0, 0, 0}
					currentAbilityScores = {0, 0, 0, 0, 0, 0}
					recordedAbilityScores = {0, 0, 0, 0, 0, 0}
					unallocatedAbilityScores = {}
					recordedUnallocatedAbilityScores = {}
				end
				if ex_ability_scores_initialized then
					ex_ability_scores_initialized = false
--					IEex_WriteDword(chargenData + 0x4EA, 0)
				end
			end
--]]
			if panelID == 55 then
				local racePlusSub = IEex_ReadByte(share + 0x26, 0x0) * 0x10000 + IEex_ReadByte(share + 0x3E3D, 0x0)
				if not ex_levelup_extra_skill_points_granted then
					ex_levelup_extra_skill_points_granted = true
					local skillPointsRemaining = IEex_ReadByte(levelUpData + 0x798, 0x0)
					IEex_IterateActorEffects(actorID, function(eData)
						local theopcode = IEex_ReadDword(eData + 0x10)
						local theresource = IEex_ReadLString(eData + 0x30, 8)
						if theopcode == 500 and theresource == "MESKLPTC" then
							local theparameter1 = IEex_ReadDword(eData + 0x1C)
							local thesavingthrow = IEex_ReadDword(eData + 0x40)
							if bit.band(thesavingthrow, 2 ^ (ex_class_level_up["class"] + 15)) > 0 then
								skillPointsRemaining = skillPointsRemaining + theparameter1 * ex_class_level_up["numLevelUps"]
								local baseSkillPoints = ex_starting_skill_points + ex_class_level_up["numLevelUps"]
								if ex_subrace_name[racePlusSub] == "HUMAN" then
									baseSkillPoints = baseSkillPoints + ex_class_level_up["numLevelUps"]
								end
								if skillPointsRemaining < baseSkillPoints then
									skillPointsRemaining = baseSkillPoints
								end
							end
						end
					end)
					IEex_WriteByte(levelUpData + 0x798, skillPointsRemaining)
					IEex_EngineCharacterUpdatePopupPanel()
				end
			elseif panelID == 54 or panelID == 7 then
				if ex_levelup_extra_skill_points_granted then
					ex_levelup_extra_skill_points_granted = false
					IEex_WriteByte(levelUpData + 0x798, 0)
				end
			end
--[[
			if panelID == 56 then
				if not ex_extra_feats_granted and ex_extra_feat_races[racePlusSub] ~= nil then
					ex_extra_feats_granted = true
					local featsRemaining = IEex_ReadDword(levelUpData + 0x646)
					featsRemaining = featsRemaining + ex_extra_feat_races[racePlusSub]
					if racePlusSub == 0x10000 or racePlusSub == 0x50001 then
						featsRemaining = featsRemaining - 1
					end
					IEex_WriteDword(levelUpData + 0x646, featsRemaining)
					IEex_EngineCreateCharUpdatePopupPanel()
				end
			else
				if ex_extra_feats_granted then
					ex_extra_feats_granted = false
					IEex_WriteDword(levelUpData + 0x646, 0)
				end
			end
--]]
		end
	end
end

function IEex_Chargen_RerollListener(key)
	if key == ex_chargen_reroll_key or key == ex_chargen_store_key or key == ex_chargen_recall_key or key == ex_chargen_reallocate_key or key == IEex_KeyIDS.T or key == IEex_KeyIDS.P then
		local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
		local chargenData = IEex_ReadDword(g_pBaldurChitin + 0x1C64)
		if chargenData > 0 then
			local actorID = IEex_ReadDword(chargenData + 0x4E2)
			local share = IEex_GetActorShare(actorID)
			if share > 0 then

				local panelID = IEex_GetEngineCreateCharPanelID()
				if key == IEex_KeyIDS.T then
					IEex_Search_Change_Log(1, chargenData, 0xA00, true)
				end
				if key == IEex_KeyIDS.P then
					IEex_Search_Change_Log(1, chargenData, 0xA00, false)
					if panelID > 0 then
						local panelData = IEex_ReadDword(IEex_ReadDword(chargenData + 0x53E) + 0x8)
						IEex_IterateCPtrList(panelData + 0x4, function(thingData)
	--[[
							if IEex_ReadDword(thingData) == 8703068 then
								IEex_PrintData_Log(thingData, 0xFF)
								IEex_IterateCPtrList(thingData + 0x52, function(lineEntry)
									local line = IEex_ReadString(IEex_ReadDword(lineEntry + 0x4))
									IEex_CString_Set(lineEntry + 0x4, line)
								end)

--								IEex_PrintData_Log(IEex_ReadDword(IEex_ReadDword(thingData + 0x108) + 0x8), 0x8)
--								IEex_Search_Change_Log(1, thingData, 0x200, false)
--								print(IEex_ReadString(IEex_ReadDword(thingData + 0x52)))
							end
--]]
							if IEex_ReadDword(thingData) == 8703188 then
--								print(IEex_ReadDword(thingData + 0xA))
--								IEex_PrintData_Log(IEex_ReadDword(thingData + 0x4E), 0x8)
--								IEex_PrintData_Log(IEex_ReadDword(thingData + 0x68), 0x8)
--								IEex_Search_Change_Log(1, thingData, 0x200, false)
--								print(IEex_ReadString(IEex_ReadDword(thingData + 0x52)))
--								print(IEex_ReadString(IEex_ReadDword(thingData + 0x4E)))
							elseif IEex_ReadDword(thingData) == 8732244 then
--								print(IEex_ReadDword(thingData + 0xA))
--								IEex_Search_Change_Log(1, thingData, 0x200, false)
--								IEex_WriteByte(thingData + 0x1E, 0)
--								IEex_WriteByte(thingData + 0x32, 1)
--								IEex_WriteByte(thingData + 0x116, 3)
							end
						end)
					end
				end
				if panelID == 4 and ex_ability_scores_initialized then

					if ex_new_ability_score_system == 1 or ex_new_ability_score_system == 2 then
						if key == ex_chargen_reroll_key then
							IEex_Chargen_Reroll()
						elseif key == ex_chargen_store_key then
							recordedAbilityScores = currentAbilityScores
							recordedUnallocatedAbilityScores = unallocatedAbilityScores
							if ex_new_ability_score_system == 2 then
								ex_recorded_remaining_points = IEex_ReadDword(chargenData + 0x4EA)
							end
						elseif key == ex_chargen_recall_key and (recordedAbilityScores[1] > 0 or #recordedUnallocatedAbilityScores > 0) then
							currentAbilityScores = recordedAbilityScores
							unallocatedAbilityScores = recordedUnallocatedAbilityScores
							if ex_new_ability_score_system == 2 then
								ex_current_remaining_points = ex_recorded_remaining_points
								IEex_WriteDword(chargenData + 0x4EA, ex_current_remaining_points)
								for i = 1, 6, 1 do
									IEex_WriteByte(share + ex_base_ability_score_cre_offset[i], currentAbilityScores[i])
								end
							end
						elseif key == ex_chargen_reallocate_key and ex_new_ability_score_system == 1 then
							for i = 1, 6, 1 do
								if currentAbilityScores[i] > 0 then
									table.insert(unallocatedAbilityScores, currentAbilityScores[i] - racialAbilityBonuses[i])
									currentAbilityScores[i] = 0
								end
								table.sort(unallocatedAbilityScores)
							end
						end

						IEex_Chargen_UpdateAbilityScores(chargenData, share)
					end
				end
			end
		end
	end
end

function IEex_Chargen_Reroll()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local chargenData = IEex_ReadDword(g_pBaldurChitin + 0x1C64)
	if chargenData > 0 then
		local actorID = IEex_ReadDword(chargenData + 0x4E2)
		local share = IEex_GetActorShare(actorID)
		if share > 0 then
			local panelID = IEex_GetEngineCreateCharPanelID()
			local racePlusSub = IEex_ReadByte(share + 0x26, 0x0) * 0x10000 + IEex_ReadByte(share + 0x3E3D, 0x0)
			if panelID == 4 then
				if ex_new_ability_score_system == 1 or ex_new_ability_score_system == 2 then
					IEex_WriteDword(chargenData + 0x4EA, 0)
					unallocatedAbilityScores = {}
					local doNewReroll = true
					while doNewReroll do
						doNewReroll = false
						local baseAbilityScoreTotal = 0
						currentAbilityScores = {0, 0, 0, 0, 0, 0}
						local metMinimumStat = false
						for i = 1, 6, 1 do
							local currentAbilityDice = {}
							for j = 1, ex_new_ability_score_dicenumber, 1 do
								table.insert(currentAbilityDice, math.random(ex_new_ability_score_dicesize))
							end
							table.sort(currentAbilityDice)
							for j = ex_new_ability_score_ignored_dice + 1, ex_new_ability_score_dicenumber, 1 do
								currentAbilityScores[i] = currentAbilityScores[i] + currentAbilityDice[j]
							end
							baseAbilityScoreTotal = baseAbilityScoreTotal + currentAbilityScores[i]
							if currentAbilityScores[i] >= ex_automatic_reroll_minimum_stat then
								metMinimumStat = true
							end
						end
						if (baseAbilityScoreTotal < ex_automatic_reroll_minimum_total and ex_automatic_reroll_minimum_total > 0) or (not metMinimumStat and ex_automatic_reroll_minimum_stat > 0) then
							doNewReroll = true
						end
					end
					for i = 1, 6, 1 do
						currentAbilityScores[i] = currentAbilityScores[i] + racialAbilityBonuses[i]
						if currentAbilityScores[i] < 1 then
							currentAbilityScores[i] = 1
						elseif currentAbilityScores[i] > 40 then
							currentAbilityScores[i] = 40
						end
						IEex_WriteByte(share + ex_base_ability_score_cre_offset[i], currentAbilityScores[i])
					end
					IEex_Chargen_UpdateAbilityScores(chargenData, share)
				end
			end
		end
	end
end

function IEex_Chargen_UpdateAbilityScores(chargenData, share)
	if ex_new_ability_score_system == 1 or ex_new_ability_score_system == 2 then
		local abilityScoreTotal = 0
		local recordedAbilityScoreTotal = 0
		for i = 1, 6, 1 do
			currentAbilityScores[i] = IEex_ReadByte(share + ex_base_ability_score_cre_offset[i], 0x0)
			abilityScoreTotal = abilityScoreTotal + currentAbilityScores[i]
			if currentAbilityScores[i] == 0 then
				abilityScoreTotal = abilityScoreTotal + racialAbilityBonuses[i]
			end
			recordedAbilityScoreTotal = recordedAbilityScoreTotal + recordedAbilityScores[i]
			if recordedAbilityScores[i] == 0 then
				recordedAbilityScoreTotal = recordedAbilityScoreTotal + racialAbilityBonuses[i]
			end
			if ex_new_ability_score_system == 1 then
				if #unallocatedAbilityScores == 0 then
					IEex_WriteDword(chargenData + 0x4EA, 0)
				else
					IEex_WriteDword(chargenData + 0x4EA, unallocatedAbilityScores[#unallocatedAbilityScores])
					if #unallocatedAbilityScores >= i then
						abilityScoreTotal = abilityScoreTotal + unallocatedAbilityScores[i]
					end
				end
				if #recordedUnallocatedAbilityScores >= i then
					recordedAbilityScoreTotal = recordedAbilityScoreTotal + recordedUnallocatedAbilityScores[i]
				end
				IEex_WriteByte(chargenData + 0x50D + i, currentAbilityScores[i])
				IEex_WriteByte(chargenData + 0x513 + i, currentAbilityScores[i])
--				IEex_WriteByte(share + ex_base_ability_score_cre_offset[i], currentAbilityScores[i])
			end
	
		end
		if recordedAbilityScoreTotal >= -4 and recordedAbilityScoreTotal <= 4 then
			recordedAbilityScoreTotal = 0
		end
		if ex_new_ability_score_system == 2 then
			ex_current_remaining_points = IEex_ReadDword(chargenData + 0x4EA)
		end
		local infoString = string.gsub(string.gsub(ex_str_ability_roll_total, "<EXRRTOTAL>", abilityScoreTotal + ex_current_remaining_points), "<EXRRRECTOTAL>", recordedAbilityScoreTotal + ex_recorded_remaining_points)
	
		if ex_new_ability_score_system == 1 then
			local unallocatedString = ""
			for i = #unallocatedAbilityScores, 1, -1 do
				unallocatedString = unallocatedString .. unallocatedAbilityScores[i] .. " "
			end
			infoString = infoString .. string.gsub(ex_str_ability_roll_unallocated, "<EXRRUNALLOCATED>", unallocatedString)
		end
		infoString = infoString .. ex_str_ability_roll_help_1
		if ex_new_ability_score_system == 1 then
			infoString = infoString .. ex_str_ability_roll_help_2
		end
		infoString = infoString .. "--------\n"
		IEex_SetToken("EXRRINFO", infoString)
		IEex_EngineCreateCharUpdatePopupPanel()
		local infoStrref = 17247
		local textAreaData = 0
		IEex_IterateCPtrList(IEex_ReadDword(IEex_ReadDword(chargenData + 0x53E) + 0x8) + 0x4, function(controlData)
			if IEex_ReadByte(controlData + 0xA, 0x0) == 29 then
				textAreaData = controlData
			end
		end)
		if textAreaData > 0 and IEex_ReadDword(textAreaData + 0x56) > 0 then
			local foundIt = false
			for k, v in ipairs(ex_chargen_ability_strrefs) do
				if not foundIt then
					local vString = string.gsub(IEex_FetchString(v), "<EXRRINFO>", "")
					local matchNext = false
					IEex_IterateCPtrList(textAreaData + 0x52, function(lineEntry)
						local line = IEex_ReadString(IEex_ReadDword(lineEntry + 0x4))
						if string.match(line, "%-%-%-%-%-%-%-%-") then
							matchNext = true
						elseif matchNext then
							matchNext = false
							line = string.gsub(line, "%(", "")
							line = string.gsub(line, "%)", "")
							vString = string.gsub(vString, "%(", "")
							vString = string.gsub(vString, "%)", "")
							if string.match(vString, line) then
								foundIt = true
								infoStrref = v
							end
						end
					end)
				end
			end
		end
		IEex_SetTextAreaToStrref(chargenData, 4, 29, infoStrref)
	elseif ex_new_ability_score_system == 3 then
		for i = 1, 6, 1 do
			local newAbilityScore = IEex_ReadByte(share + ex_base_ability_score_cre_offset[i], 0x0)
			if newAbilityScore > currentAbilityScores[i] then
				for j = currentAbilityScores[i] + 1, newAbilityScore, 1 do
					local cost = ex_new_ability_score_increase_cost[j - racialAbilityBonuses[i]]
					if cost <= ex_current_remaining_points then
						ex_current_remaining_points = ex_current_remaining_points - cost
					else
						newAbilityScore = j - 1
						IEex_WriteDword(chargenData + 0x4EA, ex_current_remaining_points)
						IEex_WriteByte(share + ex_base_ability_score_cre_offset[i], newAbilityScore)
						break
					end
					IEex_WriteDword(chargenData + 0x4EA, ex_current_remaining_points)
				end
			elseif newAbilityScore < currentAbilityScores[i] then
				for j = currentAbilityScores[i], newAbilityScore + 1, -1 do
					local cost = ex_new_ability_score_increase_cost[j - racialAbilityBonuses[i]]
					ex_current_remaining_points = ex_current_remaining_points + cost
					IEex_WriteDword(chargenData + 0x4EA, ex_current_remaining_points)
				end
			end
			currentAbilityScores[i] = newAbilityScore
		end
		ex_current_remaining_points = IEex_ReadDword(chargenData + 0x4EA)
		IEex_EngineCreateCharUpdatePopupPanel()
	end
end

function IEex_DeathwatchListener()
	local actorID = IEex_GetActorIDCursor()
	if actorID > 0 then
		local share = IEex_GetActorShare(actorID)
		if share > 0 then
			local deathwatchActive = false
			for i = 0, 5, 1 do
				local id = IEex_GetActorIDCharacter(i)
				if id > 0 and IEex_GetActorSpellState(id, 211) and not IEex_GetActorState(id, 0x80140FED) then
					IEex_IterateActorEffects(id, function(eData)
						local theopcode = IEex_ReadDword(eData + 0x10)
						local theparameter2 = IEex_ReadDword(eData + 0x20)
						local thesavingthrow = IEex_ReadDword(eData + 0x40)
						if theopcode == 288 and theparameter2 == 211 and bit.band(thesavingthrow, 0x10000) > 0 then
							deathwatchActive = true
						end
					end)
				end
			end
			if deathwatchActive then
				IEex_SetToken("EXHPSTATE1", IEex_ReadSignedWord(share + 0x5C0, 0x0) .. "/" .. IEex_GetActorStat(actorID, 1))
				IEex_SetToken("EXHPSTATE2", IEex_ReadSignedWord(share + 0x5C0, 0x0) .. "/" .. IEex_GetActorStat(actorID, 1))
				IEex_SetToken("EXHPSTATE3", IEex_ReadSignedWord(share + 0x5C0, 0x0) .. "/" .. IEex_GetActorStat(actorID, 1))
				IEex_SetToken("EXHPSTATE4", IEex_ReadSignedWord(share + 0x5C0, 0x0) .. "/" .. IEex_GetActorStat(actorID, 1))
				IEex_SetToken("EXHPSTATE5", IEex_ReadSignedWord(share + 0x5C0, 0x0) .. "/" .. IEex_GetActorStat(actorID, 1))
			else
				IEex_SetToken("EXHPSTATE1", ex_str_uninjured)
				IEex_SetToken("EXHPSTATE2", ex_str_barely_injured)
				IEex_SetToken("EXHPSTATE3", ex_str_hurt)
				IEex_SetToken("EXHPSTATE4", ex_str_badly_wounded)
				IEex_SetToken("EXHPSTATE5", ex_str_almost_dead)
			end
		end
	end
end
ex_arcane_sight_previous_tick = 0
ex_arcane_sight_actors_viewed = {}
function IEex_ArcaneSightListener(key)
	if key ~= IEex_KeyIDS.TAB then return end
	local actorID = IEex_GetActorIDCursor()
	local share = IEex_GetActorShare(actorID)
	if share <= 0 then return end
	local tick = IEex_GetGameTick()
	if tick ~= ex_arcane_sight_previous_tick then
		ex_arcane_sight_actors_viewed = {}
		ex_arcane_sight_previous_tick = tick
	end
	if ex_arcane_sight_actors_viewed[actorID] ~= nil then return end
	ex_arcane_sight_actors_viewed[actorID] = true
	local arcaneSightActive = false
	for i = 0, 5, 1 do
		local id = IEex_GetActorIDCharacter(i)
		if id > 0 and IEex_GetActorSpellState(id, 211) and not IEex_GetActorState(id, 0x80140FED) then
			IEex_IterateActorEffects(id, function(eData)
				local theopcode = IEex_ReadDword(eData + 0x10)
				local theparameter2 = IEex_ReadDword(eData + 0x20)
				local thesavingthrow = IEex_ReadDword(eData + 0x40)
				if theopcode == 288 and theparameter2 == 211 and bit.band(thesavingthrow, 0x20000) > 0 then
					arcaneSightActive = true
				end
			end)
		end
	end
	if arcaneSightActive then
		local detectedSpells = {}
		local detectedSpellResrefs = {}
		local iSpell = 0
		local atLeastOneSpellActive = false
		IEex_IterateActorEffects(actorID, function(eData)
			local theopcode = IEex_ReadDword(eData + 0x10)
			local theparameter1 = IEex_ReadDword(eData + 0x1C)
			local theparameter2 = IEex_ReadDword(eData + 0x20)
			local theparameter3 = IEex_ReadDword(eData + 0x60)
			local thetiming = IEex_ReadDword(eData + 0x24)
			local theduration = IEex_ReadDword(eData + 0x28)
			local theresource = IEex_ReadLString(eData + 0x30, 8)
			local theparent_resource = IEex_ReadLString(eData + 0x94, 8)
			local theTrueDuration = math.floor((theduration - tick) / 15)
			if theTrueDuration >= 3600000 then
				theduration = -1
			end
			if (thetiming == 6 or thetiming == 7 or thetiming == 4096) then
				if ex_damage_source_spell[theparent_resource] ~= nil then
					theparent_resource = ex_damage_source_spell[theparent_resource]
				end
				local extraString = ""
				if theopcode == 119 then
					if theparameter1 == 1 or theparameter2 == 1 then
						extraString = ex_str_arcane_sight_b_mirror_image
					elseif theparameter1 > 0 then
						extraString = string.gsub(ex_str_arcane_sight_b_mirror_images, "<EXASVAL3>", theparameter1)
					end
				elseif theopcode == 218 then
					if theparameter2 == 0 then
						if theparameter3 == 1 then
							extraString = ex_str_arcane_sight_b_stoneskin
						elseif theparameter3 > 0 then
							extraString = string.gsub(ex_str_arcane_sight_b_stoneskins, "<EXASVAL3>", theparameter3)
						end
					elseif theparameter2 == 1 then
						if theparameter1 == 1 then
							extraString = ex_str_arcane_sight_b_iron_skin
						elseif theparameter1 > 0 then
							extraString = string.gsub(ex_str_arcane_sight_b_iron_skins, "<EXASVAL3>", theparameter1)
						end
					end
				elseif theopcode == 288 then
					if theparameter2 == 251 and theresource == "MEBOULSH" then
						local theNumUses = IEex_ReadSignedWord(eData + 0x4A, 0x0)
						if theNumUses == 1 then
							extraString = ex_str_arcane_sight_b_magic_stone
						elseif theNumUses > 0 then
							extraString = string.gsub(ex_str_arcane_sight_b_magic_stones, "<EXASVAL3>", theNumUses)
						end
					end
				end
--				if detectedSpells[theparent_resource] == nil then
				if detectedSpellResrefs[theparent_resource] == nil then
					iSpell = iSpell + 1
					detectedSpellResrefs[theparent_resource] = iSpell
					local resWrapper = IEex_DemandRes(theparent_resource, "SPL")
					if resWrapper:isValid() then
						local spellData = resWrapper:getData()
--						local spellType = IEex_ReadWord(spellData + 0x1C, 0x0)
--						local spellLevel = IEex_ReadDword(spellData + 0x34)
						local spellNameRef = IEex_ReadDword(spellData + 0x8)

						table.insert(detectedSpells, {spellNameRef, theduration, extraString})

						if spellNameRef > 0 and theduration > 0 then
							atLeastOneSpellActive = true
						end
					else
						table.insert(detectedSpells, {-1, -1, ""})
					end
					resWrapper:free()
				else
					if theduration > detectedSpells[detectedSpellResrefs[theparent_resource]][2] then
						detectedSpells[detectedSpellResrefs[theparent_resource]][2] = theduration
					end
					if extraString ~= "" then
						detectedSpells[detectedSpellResrefs[theparent_resource]][3] = extraString
					end
				end
			end
		end)
		if atLeastOneSpellActive then
			IEex_DisplayString(string.gsub(ex_str_arcane_sight_a, "<EXASNAME>", IEex_GetActorName(actorID)))
			table.sort(detectedSpells, function(i1, i2)
				return (i1[2] < i2[2])
			end)
			for k, spell in ipairs(detectedSpells) do
				if spell[1] > 0 and spell[2] > 0 then
					local spellName = IEex_FetchString(spell[1])
					local trueDuration = (spell[2] - tick) / 15
					if trueDuration >= 14400 then
						IEex_DisplayString(string.gsub(string.gsub(ex_str_arcane_sight_b_days, "<EXASVAL1>", spellName), "<EXASVAL2>", math.floor(trueDuration / 7200)) .. spell[3])
					elseif trueDuration >= 7200 then
						IEex_DisplayString(string.gsub(ex_str_arcane_sight_b_day, "<EXASVAL1>", spellName) .. spell[3])
					elseif trueDuration >= 600 then
						IEex_DisplayString(string.gsub(string.gsub(ex_str_arcane_sight_b_hours, "<EXASVAL1>", spellName), "<EXASVAL2>", math.floor(trueDuration / 300)) .. spell[3])
					elseif trueDuration >= 300 then
						IEex_DisplayString(string.gsub(ex_str_arcane_sight_b_hour, "<EXASVAL1>", spellName) .. spell[3])
					elseif trueDuration >= 14 then
						IEex_DisplayString(string.gsub(string.gsub(ex_str_arcane_sight_b_rounds, "<EXASVAL1>", spellName), "<EXASVAL2>", math.floor(trueDuration / 7)) .. spell[3])
					elseif trueDuration >= 7 then
						IEex_DisplayString(string.gsub(ex_str_arcane_sight_b_round, "<EXASVAL1>", spellName) .. spell[3])
					elseif trueDuration >= 2 then
						IEex_DisplayString(string.gsub(string.gsub(ex_str_arcane_sight_b_seconds, "<EXASVAL1>", spellName), "<EXASVAL2>", math.floor(trueDuration)) .. spell[3])
					elseif trueDuration >= 1 then
						IEex_DisplayString(string.gsub(ex_str_arcane_sight_b_second, "<EXASVAL1>", spellName) .. spell[3])
					else
						IEex_DisplayString(string.gsub(string.gsub(ex_str_arcane_sight_b_seconds, "<EXASVAL1>", spellName), "<EXASVAL2>", math.floor(trueDuration * 100) / 100) .. spell[3])
					end
				end
			end
		end
	end
end

function IEex_AbilityScoreCapListener()
	if ex_full_ability_score_cap > 40 then
		for i = 0, 5, 1 do
			local actorID = IEex_GetActorIDCharacter(i)
			local share = IEex_GetActorShare(actorID)
			if share > 0 then
				for j = 0, 5, 1 do
					local statID = 37 + j
					if statID == 37 then
						statID = 36
					end
					if IEex_ReadSignedWord(share + 0x974 + j * 0x2, 0x0) == 40 then
						local fullStatValue = IEex_GetActorFullStat(actorID, statID)
						IEex_WriteWord(share + 0x974 + j * 0x2, fullStatValue)
						IEex_WriteWord(share + 0x17CC + j * 0x2, fullStatValue)
					end
				end
			end
		end
	end
end

ex_reform_party_button_added = 1
ex_reroll_buttons_added = 0
function IEex_AddButtonListener()

	-----------------------------
	-- Add Reform Party button --
	-----------------------------

	if ex_reform_party_button_added == 0 then
		local screenCharacter = IEex_GetEngineCharacter()
		local characterRecordPanel = IEex_GetPanelFromEngine(screenCharacter, 2)
		if characterRecordPanel > 0 then
			-- Move the normal "Level Up" button over to make room
			IEex_SetControlXY(IEex_GetControlFromPanel(characterRecordPanel, 37), 655, 361)
		
			IEex_AddControlOverride("GUIREC", 2, 38, "IEex_UI_Button")
			IEex_AddControlToPanel(characterRecordPanel, {
				["type"] = IEex_ControlStructType.BUTTON,
				["id"] = 38,
				["x"] = 655,
				["y"] = 388,
				["width"] = 117,
				["height"] = 25,
				["bam"] = "GBTNSTD",
				["frameUnpressed"] = 1,
				["framePressed"] = 2,
				["frameDisabled"] = 3,
			})
			IEex_SetControlButtonText(IEex_GetControlFromPanel(characterRecordPanel, 38), IEex_FetchString(ex_tra_55904)) -- "Reform Party"
			ex_reform_party_button_added = 1
		end
	end
	if ex_reroll_buttons_added == 0 and (ex_new_ability_score_system == 1 or ex_new_ability_score_system == 2) then
		local screenCreateChar = IEex_GetEngineCreateChar()
		local abilitiesPanel = IEex_GetPanelFromEngine(screenCreateChar, 4)
		if abilitiesPanel > 0 then
			IEex_AddControlOverride("GUICG", 4, 37, "IEex_UI_Button")
			IEex_AddControlToPanel(abilitiesPanel, {
				["type"] = IEex_ControlStructType.BUTTON,
				["id"] = 37,
				["x"] = 22,
				["y"] = 320,
				["width"] = 253,
				["height"] = 32,
				["bam"] = "GBTNLRG",
				["frameUnpressed"] = 1,
				["framePressed"] = 2,
				["frameDisabled"] = 3,
			})
			IEex_SetControlButtonText(IEex_GetControlFromPanel(abilitiesPanel, 37), IEex_FetchString(ex_tra_55757)) -- "Reroll"
			IEex_AddControlOverride("GUICG", 4, 38, "IEex_UI_Button")
			IEex_AddControlToPanel(abilitiesPanel, {
				["type"] = IEex_ControlStructType.BUTTON,
				["id"] = 38,
				["x"] = 22,
				["y"] = 360,
				["width"] = 117,
				["height"] = 25,
				["bam"] = "GBTNSTD",
				["frameUnpressed"] = 1,
				["framePressed"] = 2,
				["frameDisabled"] = 3,
			})
			IEex_SetControlButtonText(IEex_GetControlFromPanel(abilitiesPanel, 38), IEex_FetchString(ex_tra_55758)) -- "Store"
			IEex_AddControlOverride("GUICG", 4, 39, "IEex_UI_Button")
			IEex_AddControlToPanel(abilitiesPanel, {
				["type"] = IEex_ControlStructType.BUTTON,
				["id"] = 39,
				["x"] = 158,
				["y"] = 360,
				["width"] = 117,
				["height"] = 25,
				["bam"] = "GBTNSTD",
				["frameUnpressed"] = 1,
				["framePressed"] = 2,
				["frameDisabled"] = 3,
			})
			IEex_SetControlButtonText(IEex_GetControlFromPanel(abilitiesPanel, 39), IEex_FetchString(ex_tra_55759)) -- "Recall"
			if ex_new_ability_score_system == 1 then
				IEex_AddControlOverride("GUICG", 4, 40, "IEex_UI_Button")
				IEex_AddControlToPanel(abilitiesPanel, {
					["type"] = IEex_ControlStructType.BUTTON,
					["id"] = 40,
					["x"] = 22,
					["y"] = 393,
					["width"] = 253,
					["height"] = 32,
					["bam"] = "GBTNLRG",
					["frameUnpressed"] = 1,
					["framePressed"] = 2,
					["frameDisabled"] = 3,
				})
				IEex_SetControlButtonText(IEex_GetControlFromPanel(abilitiesPanel, 40), IEex_FetchString(ex_tra_55760)) -- "Reallocate"
			end
			ex_reroll_buttons_added = 1
		end
	end
end

function IEex_Scroll_InputStateListener()

end

function IEex_Scroll_RegisterListeners()
	IEex_AddKeyPressedListener("IEex_BuffRecordingListener")
	IEex_AddKeyPressedListener("IEex_ExtraCheatKeysListener")
	IEex_AddKeyPressedListener("IEex_ArcaneSightListener")
	IEex_AddKeyPressedListener("IEex_Scroll_KeyPressedListener")
	IEex_AddKeyPressedListener("IEex_FakeInputRoutineStartStopListener")
	IEex_AddKeyReleasedListener("IEex_Scroll_KeyReleasedListener")
--	IEex_AddKeyReleasedListener("IEex_Chargen_RerollListener")
	IEex_AddInputStateListener("IEex_AddButtonListener")
	IEex_AddInputStateListener("IEex_DeathwatchListener")
	IEex_AddInputStateListener("IEex_AbilityScoreCapListener")
	IEex_AddInputStateListener("IEex_Chargen_ExtraFeatListener")
	IEex_AddInputStateListener("IEex_LevelUp_ExtraFeatListener")
	IEex_AddInputStateListener("IEex_Scroll_InputStateListener")
end

function IEex_Scroll_ReloadListener()
	IEex_Scroll_RegisterListeners()
	IEex_ReaddReloadListener("IEex_Scroll_ReloadListener")
end

IEex_AbsoluteOnce("IEex_Scroll_InitListeners", function()
	IEex_Scroll_RegisterListeners()
	IEex_AddReloadListener("IEex_Scroll_ReloadListener")
end)

-----------
-- Hooks --
-----------

------------------
-- Thread: Both --
------------------

function IEex_Extern_CheckScroll()

	IEex_AssertThread(IEex_Thread.Both, true)

	if IEex_Helper_GetBridge("IEex_Helper_SupressScrollCheck", "value") then
		return
	end

	IEex_Helper_SynchronizedBridgeOperation("IEex_Scroll_MiddleMouseState", function()

		if IEex_Helper_GetBridgeNL("IEex_Scroll_MiddleMouseState", "isDown") then

			local cursorX, cursorY = IEex_ScreenToClient(IEex_GetCursorPos())
			local deltaX = IEex_Helper_GetBridgeNL("IEex_Scroll_MiddleMouseState", "oldX") - cursorX
			local deltaY = IEex_Helper_GetBridgeNL("IEex_Scroll_MiddleMouseState", "oldY") - cursorY
			IEex_AdjustViewPosition(deltaX, deltaY)

			IEex_Helper_SetBridgeNL("IEex_Scroll_MiddleMouseState", "oldX", cursorX)
			IEex_Helper_SetBridgeNL("IEex_Scroll_MiddleMouseState", "oldY", cursorY)
		end
	end)

	local visibleArea = IEex_GetVisibleArea()
	if visibleArea ~= 0x0 then

		local deltaFactor = IEex_Scroll_CalculateDeltaFactor()

		if not IEex_Helper_GetBridgeNL("IEex_Scroll_MiddleMouseState", "isDown") then

			local m_nScrollState = IEex_ReadDword(visibleArea + 0x238)
			local m_nKeyScrollState = IEex_ReadDword(visibleArea + 0x23C)

			local gameData = IEex_GetGameData()
			local scrollSpeed = IEex_ReadDword(gameData + 0x43F2)
			local keyboardScrollSpeed = IEex_ReadDword(gameData + 0x443E) / 3

			IEex_AdjustViewPositionFromScrollState(m_nScrollState, scrollSpeed * deltaFactor)
			IEex_AdjustViewPositionFromScrollState(m_nKeyScrollState, keyboardScrollSpeed * deltaFactor)
		end
	end
end

function IEex_GetEffectiveViewBottom(nViewY)
	return nViewY + IEex_GetMainViewportBottom(false, true)
end

function IEex_Extern_EnforceViewportBottomBound(CInfinity, nViewY)
	IEex_AssertThread(IEex_Thread.Both, true)
	local nEffectiveViewBottom = IEex_GetEffectiveViewBottom(nViewY)
	local nAreaHeight = IEex_ReadDword(CInfinity + 0x84)
	if nEffectiveViewBottom > nAreaHeight then
		local nNewY = nViewY - (nEffectiveViewBottom - nAreaHeight)
		IEex_WriteDword(CInfinity + 0x168, nNewY * 10000)
		return nNewY
	end
	return nViewY
end

function IEex_Extern_AdjustAutoScrollY(y)
	local _, resH = IEex_GetResolution()
	return y + (resH - IEex_GetMainViewportBottom(false, true)) / 2
end

function IEex_Extern_AutoScroll(CInfinity, targetViewX, targetViewY, speed)

	-- CInfinity_Scroll
	IEex_Call(0x5D1380, {speed, targetViewY, targetViewX}, CInfinity, 0x0)

	-- If (m_ptScrollDest.x == -1 && m_ptScrollDest.y == -1) auto-scrolling is done.
	-- I might have adjusted m_ptScrollDest after MoveViewPointUntilDone() stored
	-- the location, (and expects to end up there), so let's just pretend like
	-- MoveViewPointUntilDone() hit a deadlock so the action terminates.
	if IEex_ReadDword(CInfinity + 0x18E) == -1 and IEex_ReadDword(CInfinity + 0x192) == -1 then
		IEex_WriteDword(IEex_Extern_MoveViewUntilDone_Stuck, 1)
		return
	end

	local resW, resH = IEex_GetResolution()

	local nNewX = IEex_ReadDword(CInfinity + 0x40)
	local nNewY = IEex_ReadDword(CInfinity + 0x44)

	local nAreaWidth = IEex_ReadDword(CInfinity + 0x80)
	local nAreaHeight = IEex_ReadDword(CInfinity + 0x84)

	local xStuck = (targetViewX < nNewX and nNewX <= 0) or (targetViewX > nNewX and nNewX >= nAreaWidth - resW)
	local yStuck = (targetViewY < nNewY and nNewY <= 0) or (targetViewY > nNewY and IEex_GetEffectiveViewBottom(nNewY) >= nAreaHeight)

	if (xStuck and yStuck) or (xStuck and nNewY == targetViewY) or (yStuck and nNewX == targetViewX) then
		IEex_WriteDword(CInfinity + 0x18E, -1) -- m_ptScrollDest.x
		IEex_WriteDword(CInfinity + 0x192, -1) -- m_ptScrollDest.y
		IEex_WriteDword(IEex_Extern_MoveViewUntilDone_Stuck, 1)
	end
end

-------------------
-- Thread: Async --
-------------------

function IEex_Extern_AllowMouseScrollDown(CGameArea, nViewY)
	IEex_AssertThread(IEex_Thread.Async, true)
	local nEffectiveViewBottom = IEex_GetEffectiveViewBottom(nViewY)
	local nAreaHeight = IEex_ReadDword(CGameArea + 0x550)
	return nEffectiveViewBottom < nAreaHeight
end

-- Async thread state for currently executing fake input routine
IEex_FakeInputRoutineActive = false
IEex_FakeInputRoutineT = nil
IEex_FakeInputRoutineI = nil
IEex_FakeInputRoutineStopKey = nil

-- Allows the user to start/stop a fake input routine via keypress
function IEex_FakeInputRoutineStartStopListener(key)
	if not IEex_FakeInputRoutineActive then
		IEex_Helper_SynchronizedBridgeOperation("IEex_FakeInputRoutineStartStopKeys", function(bridge)
			for i = 1, IEex_Helper_GetBridgeNumIntsNL(bridge) do
				local info = IEex_Helper_GetBridgeNL(bridge, i)
				if key == IEex_Helper_GetBridgeNL(info, "startKey") then
					IEex_StartFakeInputRoutine(
						IEex_Helper_GetBridgeNL(info, "routine"),
						IEex_Helper_GetBridgeNL(info, "stopKey")
					)
				end
			end
		end)
	elseif key == IEex_FakeInputRoutineStopKey then
		IEex_StopFakeInputRoutine()
	end
end

-- Starts a fake input routine from the async thread.
--   Note: Assuming IEex_FakeInputRoutine is already locked.
function IEex_StartFakeInputThread()
	IEex_StartFakingCursorPos()
	IEex_FakeInputRoutineActive = true
	IEex_FakeInputRoutine = IEex_Helper_ReadDataFromBridgeNL("IEex_FakeInputRoutine")
	IEex_FakeInputRoutineT = IEex_FakeInputRoutine.routine
	IEex_FakeInputRoutineI = 1
	IEex_FakeInputRoutineStopKey = IEex_FakeInputRoutine.stopKey or IEex_FakeInputRoutineT.stopKey
end

-- Stops a fake input routine from the async thread
function IEex_StopFakeInputRoutineThread(alreadyLockedBridge)
	IEex_StopFakingCursorPos()
	if alreadyLockedBridge == nil then
		IEex_Helper_SetBridge("IEex_FakeInputRoutine", "active", false)
	else
		IEex_Helper_SetBridgeNL(alreadyLockedBridge, "active", false)
	end
	IEex_FakeInputRoutineActive = false
	IEex_FakeInputRoutineT = nil
	IEex_FakeInputRoutineI = nil
	IEex_FakeInputRoutineStopKey = nil
end

-- Fake input routine event logic
IEex_FakeInputRoutineSwitch = {
	[IEex_FakeInputRoutineEvent.FUNCTION] = function(state, eventT)
		return eventT[2](state, eventT)
	end,
	[IEex_FakeInputRoutineEvent.UP] = function(state, eventT)
		IEex_FakeKeyEvent(eventT[2], false)
	end,
	[IEex_FakeInputRoutineEvent.DOWN] = function(state, eventT)
		IEex_FakeKeyEvent(eventT[2], true)
	end,
	[IEex_FakeInputRoutineEvent.PRESS] = function(state, eventT)
		IEex_FakeKeyPress(eventT[2])
	end,
	[IEex_FakeInputRoutineEvent.SET_MOUSE_POS] = function(state, eventT)
		IEex_FakeCursorPos(IEex_ClientToScreen(eventT[2], eventT[3]))
	end,
	[IEex_FakeInputRoutineEvent.CLICK_CONTROL] = function(state, eventT)

		local activeEngine = IEex_GetActiveEngine()
		local chuResref = IEex_GetCHUResrefFromEngine(activeEngine)

		local acceptableCHUs = eventT[2]
		if type(acceptableCHUs) == "table" then
			local found = false
			for _, acceptableCHU in ipairs(acceptableCHUs) do
				if chuResref == acceptableCHU then
					found = true
					break
				end
			end
			if not found then
				print("[!] Fake input routine attempted to click a control of an inactive engine")
				return IEex_FakeInputRoutineReturn.END
			end
		elseif chuResref ~= acceptableCHUs then
			print("[!] Fake input routine attempted to click a control of an inactive engine")
			return IEex_FakeInputRoutineReturn.END
		end

		local panel = IEex_GetPanelFromEngine(activeEngine, eventT[3])
		if panel == 0x0 then
			state.lastControlClickFailed = true
			return IEex_FakeInputRoutineReturn.CONTINUE_IMMEDIATELY
		end
		local control = IEex_GetControlFromPanel(panel, eventT[4])
		if control == 0x0 then
			state.lastControlClickFailed = true
			return IEex_FakeInputRoutineReturn.CONTINUE_IMMEDIATELY
		end
		local clientX, clientY, clientWidth, clientHeight = IEex_GetControlAreaAbsolute(control)
		local centerClientX = clientX + clientWidth / 2
		local centerClientY = clientY + clientHeight / 2
		local centerScreenX, centerScreenY = IEex_ClientToScreen(centerClientX, centerClientY)
		IEex_FakeCursorPos(centerScreenX, centerScreenY)
		IEex_FakeKeyPress(IEex_KeyIDS.LEFT_MOUSE_CLICK)
		state.lastControlClickFailed = false
	end,
	[IEex_FakeInputRoutineEvent.WAIT] = function(state, eventT)

		if state.lastControlClickFailed then
			state.lastControlClickFailed = false
			return IEex_FakeInputRoutineReturn.CONTINUE_IMMEDIATELY
		end

		if state.waitInitialized == nil then
			IEex_Helper_StoreMicroseconds("IEex_FakeInputRoutineEventWaitStart")
			state.waitInitialized = true
		end

		IEex_Helper_StoreMicroseconds("IEex_FakeInputRoutineEventWaitCurrent")
		local diff = IEex_Helper_GetMicrosecondsDiff("IEex_FakeInputRoutineEventWaitCurrent", "IEex_FakeInputRoutineEventWaitStart")
		if diff < eventT[2] then
			return IEex_FakeInputRoutineReturn.WAIT
		end
		state.waitInitialized = nil
	end
}

function IEex_Extern_BeforeCheckKeys()

	IEex_AssertThread(IEex_Thread.Async, true)

	-- Check if the async thread should start/stop a fake input routine
	IEex_Helper_SynchronizedBridgeOperation("IEex_FakeInputRoutine", function(bridge)
		if IEex_Helper_GetBridgeNL(bridge, "active") then
			if not IEex_FakeInputRoutineActive then
				IEex_StartFakeInputThread()
			end
		elseif IEex_FakeInputRoutineActive then
			IEex_StopFakeInputRoutineThread(bridge)
		end
	end)

	if not IEex_FakeInputRoutineActive then
		return
	end

	-- Handle fake input routine events
	while true do

		local eventT = IEex_FakeInputRoutineT[IEex_FakeInputRoutineI]
		if eventT == nil then
			IEex_StopFakeInputRoutineThread()
			break
		end

		local result = IEex_FakeInputRoutineSwitch[eventT[1]](IEex_FakeInputRoutineT, eventT)
		if result == nil or result == IEex_FakeInputRoutineReturn.CONTINUE then
			IEex_FakeInputRoutineI = IEex_FakeInputRoutineI + 1
			break
		elseif result == IEex_FakeInputRoutineReturn.WAIT then
			break
		elseif result == IEex_FakeInputRoutineReturn.CONTINUE_IMMEDIATELY then
			IEex_FakeInputRoutineI = IEex_FakeInputRoutineI + 1
			-- Loop
		elseif result == IEex_FakeInputRoutineReturn.END then
			IEex_StopFakeInputRoutineThread()
			break
		else
			IEex_TracebackMessage("[!] Unhandled IEex_FakeInputRoutineReturn: "..tostring(result))
			break
		end
	end
end

function IEex_Extern_CChitin_ProcessEvents_CheckKeys()

	-- https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes

	IEex_AssertThread(IEex_Thread.Async, true)

	for key = 0x1, 0xFE, 1 do

		-- IEex_Helper_GetAsyncKeyStateClient() allows up to 15 ([0-14]) clients (0 = engine) to query key state while
		-- each having their own "pressed since last poll" state
		--
		-- The export "IEex_Helper_GetAsyncKeyStateWrapper" is IEex_Helper_GetAsyncKeyStateClient() with nClient = 0
		local keyState = IEex_Helper_GetAsyncKeyStateClient(1, key)

		local isDownRightNow = bit.band(keyState, 0x8000) ~= 0x0
		local wasDown = bit.band(keyState, 0x1) ~= 0x0

		local keyData = IEex_Helper_GetBridge("IEex_Keys", key)
		local isDownBridge = IEex_Helper_GetBridge(keyData, "isDown")

		-- Update bridge
		if isDownRightNow then
			if not isDownBridge then
				IEex_Helper_SetBridge(keyData, "isDown", true)
			end
		elseif isDownBridge then
			IEex_Helper_SetBridge(keyData, "isDown", false)
		end

		-- If the async thread is running really slow it might miss a keydown + keyup
		-- This corrects missing exactly 1 keydown + keyup sequence for a key
		local missedPress = not isDownRightNow and wasDown

		-- Run key pressed listeners
		if (isDownRightNow and not isDownBridge) or missedPress then
			IEex_Helper_IterateBridge("IEex_KeyPressedListeners", function(_, funcName)
				_G[funcName](key)
			end)
		end

		-- Run key released listeners
		if (not isDownRightNow and isDownBridge) or missedPress then
			IEex_Helper_IterateBridge("IEex_KeyReleasedListeners", function(_, funcName)
				_G[funcName](key)
			end)
		end
	end

	IEex_Helper_IterateBridge("IEex_InputStateListeners", function(_, funcName)
		_G[funcName](key)
	end)
end
