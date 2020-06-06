
IEex_GameObjectData = {}
IEex_RegisteredLuaStats = {}

function IEex_RegisterLuaStat(attributes)

	-- ["init"] = function(stats)
	-- ["reload"] = function(stats)
	-- ["copy"] = function(sourceStats, destStats)
	-- ["cleanup"] = function(stats)

	table.insert(IEex_RegisteredLuaStats, attributes)
end

function IEex_AccessLuaStats(actorID)
	local share = IEex_GetActorShare(actorID)
	local bAllowEffectListCall = IEex_ReadDword(share + 0x72A4) == 1
	local actorData = IEex_GameObjectData[actorID]
	return bAllowEffectListCall and actorData.luaDerivedStats or actorData.luaTempStats
end

IEex_OnGameObjectAdded = function(actorID)

	local share = IEex_GetActorShare(actorID)
	if share == 0x0 then
		print("[IEex_OnGameObjectAdded] Engine attempted to add invalid object?")
		return
	end

	local myData = {}

	-- Sprite
	if IEex_ReadByte(share + 0x4, 0) == 0x31 then

		local luaDerivedStats = {}
		local luaTempStats = {}

		for _, luaStat in ipairs(IEex_RegisteredLuaStats) do
			local initFunc = luaStat.init
			if initFunc then
				initFunc(luaDerivedStats)
				initFunc(luaTempStats)
			end
			local reloadFunc = luaStat.reload
			if reloadFunc then
				reloadFunc(luaDerivedStats)
			end
		end

		myData.luaDerivedStats = luaDerivedStats
		myData.luaTempStats = luaTempStats

	end

	IEex_GameObjectData[actorID] = myData

end

IEex_OnGameObjectBeingDeleted = function(actorID)

	local share = IEex_GetActorShare(actorID)
	if share == 0x0 then
		-- Just in case the object was (somehow?) already deleted without me clearing this table
		IEex_GameObjectData[actorID] = nil
		return
	end

	if IEex_ReadByte(share + 0x4, 0) == 0x31 then

		local myData = IEex_GameObjectData[actorID]
		local luaDerivedStats = myData.luaDerivedStats
		local luaTempStats = myData.luaTempStats

		for _, luaStat in ipairs(IEex_RegisteredLuaStats) do
			local cleanupFunc = luaStat.cleanup
			if cleanupFunc then
				local myData = IEex_GameObjectData[actorID]
				cleanupFunc(luaDerivedStats)
				cleanupFunc(luaTempStats)
			end
		end
	end

	IEex_GameObjectData[actorID] = nil
end

IEex_OnGameObjectsBeingCleaned = function()

	for actorID, myData in pairs(IEex_GameObjectData) do

		local share = IEex_GetActorShare(actorID)
		if share ~= 0x0 and IEex_ReadByte(share + 0x4, 0) == 0x31 then

			for _, luaStat in ipairs(IEex_RegisteredLuaStats) do
				local cleanupFunc = luaStat.cleanup
				if cleanupFunc then
					cleanupFunc(myData.luaDerivedStats)
					cleanupFunc(myData.luaTempStats)
				end
			end
		end
	end

	IEex_GameObjectData = {}
end

IEex_OnReloadStats = function(share)

	if share == 0x0 then return end
	if IEex_ReadByte(share + 0x4, 0) == 0x31 then

		local actorID = IEex_GetActorIDShare(share)
		local luaDerivedStats = IEex_GameObjectData[actorID].luaDerivedStats

		for _, luaStat in ipairs(IEex_RegisteredLuaStats) do
			local reloadFunc = luaStat.reload
			if reloadFunc then
				reloadFunc(luaDerivedStats)
			end
		end
	end
end

IEex_OnUpdateTempStats = function(share)

	if share == 0x0 then return end
	if IEex_ReadByte(share + 0x4, 0) == 0x31 then

		local actorID = IEex_GetActorIDShare(share)
		local myData = IEex_GameObjectData[actorID]
		local luaDerivedStats = myData.luaDerivedStats
		local luaTempStats = myData.luaTempStats

		for _, luaStat in ipairs(IEex_RegisteredLuaStats) do
			local copyFunc = luaStat.copy
			if copyFunc then
				copyFunc(luaDerivedStats, luaTempStats)
			end
		end
	end
end

(function()

	IEex_DisableCodeProtection()

	----------------------------
	-- IEex_OnGameObjectAdded --
	----------------------------

	-- The function (sometimes) clobbers this arg during execution,
	-- have to save it myself so I can use it later.
	local onGameObjectAddedIndexPointer = IEex_Malloc(0x4)

	IEex_HookRestore(0x59A0F0, 0, 6, {[[
		!mov_eax_[esp+byte] 04
		!mov_[dword]_eax ]], {onGameObjectAddedIndexPointer, 4}, [[
	]]})

	IEex_HookAfterRestore(0x59A4FE, 0, 10, {[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_OnGameObjectAdded"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		!mov_eax_[dword] ]], {onGameObjectAddedIndexPointer, 4}, [[
		!mov_eax_[eax]

		; actorID ;
		!push_eax
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

		!pop_all_registers_iwd2

	]]})

	-----------------------------------
	-- IEex_OnGameObjectBeingDeleted --
	-----------------------------------

	IEex_HookRestore(0x59A530, 0, 6, {[[

		!push_complete_state

		!push_dword ]], {IEex_WriteStringAuto("IEex_OnGameObjectBeingDeleted"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; actorID ;
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
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError

		!pop_complete_state

	]]})

	------------------------------------
	-- IEex_OnGameObjectsBeingCleaned --
	------------------------------------

	IEex_HookRestore(0x59A9D0, 0, 7, {[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_OnGameObjectsBeingCleaned"), 4}, [[
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

	------------------------
	-- IEex_OnReloadStats --
	------------------------

	IEex_HookRestore(0x4440F0, 0, 6, {[[

		!push_complete_state

		!push_dword ]], {IEex_WriteStringAuto("IEex_OnReloadStats"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; share ;
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
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError

		!pop_complete_state

	]]})

	----------------------------
	-- IEex_OnUpdateTempStats --
	----------------------------

	local callOnUpdateTempStats = IEex_WriteAssemblyAuto({[[

		!push_all_registers_iwd2

		!push_dword ]], {IEex_WriteStringAuto("IEex_OnUpdateTempStats"), 4}, [[
		!push_dword *_g_lua
		!call >_lua_getglobal
		!add_esp_byte 08

		; share ;
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
		!push_byte 00
		!push_byte 01
		!push_dword *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18
		!call >IEex_CheckCallError

		!pop_all_registers_iwd2
		!ret

	]]})

	IEex_HookBeforeCall(0x72E1F9, {"!call", {callOnUpdateTempStats, 4, 4}})
	IEex_HookBeforeCall(0x733179, {"!call", {callOnUpdateTempStats, 4, 4}})

	IEex_EnableCodeProtection()

end)()
