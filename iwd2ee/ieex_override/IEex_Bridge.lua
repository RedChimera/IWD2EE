
IEex_Bridge_LockFunctions = {
	["IEex_Helper_InitBridgeFromTable"] = IEex_Helper_InitBridgeFromTable,
	["IEex_Helper_WriteDataToBridge"]   = IEex_Helper_WriteDataToBridge,
	["IEex_Helper_ReadDataFromBridge"]  = IEex_Helper_ReadDataFromBridge,
	["IEex_Helper_PrintBridgeData"]     = IEex_Helper_PrintBridgeData,
	["IEex_Helper_SetBridge"]           = IEex_Helper_SetBridge,
	["IEex_Helper_GetBridge"]           = IEex_Helper_GetBridge,
	["IEex_Helper_GetBridgePtr"]        = IEex_Helper_GetBridgePtr,
	["IEex_Helper_IterateBridge"]       = IEex_Helper_IterateBridge,
	["IEex_Helper_GetBridgeNumInts"]    = IEex_Helper_GetBridgeNumInts,
	["IEex_Helper_EraseBridgeKey"]      = IEex_Helper_EraseBridgeKey,
	["IEex_Helper_GetBridgeCreate"]     = IEex_Helper_GetBridgeCreate,
	["IEex_Helper_ClearBridge"]         = IEex_Helper_ClearBridge,
	["IEex_Helper_InitBridge"]          = IEex_Helper_InitBridge,
}

IEex_Bridge_NoLockFunctions = {
	["IEex_Helper_InitBridgeFromTable"] = IEex_Helper_InitBridgeFromTableNL,
	["IEex_Helper_WriteDataToBridge"]   = IEex_Helper_WriteDataToBridgeNL,
	["IEex_Helper_ReadDataFromBridge"]  = IEex_Helper_ReadDataFromBridgeNL,
	["IEex_Helper_PrintBridgeData"]     = IEex_Helper_PrintBridgeDataNL,
	["IEex_Helper_SetBridge"]           = IEex_Helper_SetBridgeNL,
	["IEex_Helper_GetBridgePtr"]        = IEex_Helper_GetBridgePtrNL,
	["IEex_Helper_IterateBridge"]       = IEex_Helper_IterateBridgeNL,
	["IEex_Helper_GetBridgeNumInts"]    = IEex_Helper_GetBridgeNumIntsNL,
	["IEex_Helper_EraseBridgeKey"]      = IEex_Helper_EraseBridgeKeyNL,
	["IEex_Helper_GetBridgeCreate"]     = IEex_Helper_GetBridgeCreateNL,
	["IEex_Helper_ClearBridge"]         = IEex_Helper_ClearBridgeNL,
	["IEex_Helper_InitBridge"]          = IEex_Helper_InitBridgeNL,
}

function IEex_UpdateBridge(bridgeName, updateFunc)
	IEex_Helper_SynchronizedBridgeOperation(bridgeName, function()
		IEex_Helper_ReadDataFromBridgeNL(bridgeName)
		updateFunc(_G[bridgeName])
		IEex_Helper_WriteDataToBridgeNL(bridgeName)
	end)
end

function IEex_AppendBridgeTable(bridge)
	local next = IEex_Helper_GetBridgeNumInts(bridge) + 1
	return IEex_Helper_GetBridgeCreate(bridge, next)
end

function IEex_AppendBridgeTableNL(bridge)
	local next = IEex_Helper_GetBridgeNumIntsNL(bridge) + 1
	return IEex_Helper_GetBridgeCreateNL(bridge, next)
end

function IEex_AppendBridge(bridge, value)
	local next = IEex_Helper_GetBridgeNumInts(bridge) + 1
	return IEex_Helper_SetBridge(bridge, next, value)
end

function IEex_AppendBridgeNL(bridge, value)
	local next = IEex_Helper_GetBridgeNumIntsNL(bridge) + 1
	return IEex_Helper_SetBridgeNL(bridge, next, value)
end

function IEex_AbsoluteOnce(onceKey, func)
	IEex_Helper_SynchronizedBridgeOperation(onceKey, function()
		local val = IEex_Helper_GetBridgeNL(onceKey, "val")
		if (not val) and func() ~= false then
			IEex_Helper_SetBridgeNL(onceKey, "val", true)
		end
	end)
end

IEex_Helper_InitBridgeFromTable("IEex_ThreadBridge", {
	["Sync"] = -1,
	["Async"] = -1,
})

IEex_Thread = {
	["Sync"] = 0,
	["Async"] = 1,
	["Both"] = 2,
}

function IEex_AssertThread(thread, once)

	local printMessage = function(message, onceType)
		IEex_Helper_SynchronizedBridgeOperation("IEex_AssertCount", function()
			if not once then
				IEex_TracebackPrint("", "", message, 4)
			else
				local info = debug.getinfo(2, "Sl")
				local onceID = info.source.."_"..info.currentline
				local log = IEex_Helper_GetBridgeNL("IEex_AssertCount", onceID, "log")
				if (not log) or (not IEex_Helper_GetBridgeNL(log, onceType)) then
					IEex_TracebackPrint("", "", message, 4)
				end
				IEex_Helper_SetBridgeNL("IEex_AssertCount", onceID, "log", onceType, true)
			end
		end)
	end

	local syncThread = IEex_Helper_GetBridge("IEex_ThreadBridge", "Sync")
	local asyncThread = IEex_Helper_GetBridge("IEex_ThreadBridge", "Async")
	local currentThread = IEex_GetCurrentThread()

	if thread == IEex_Thread.Both then
		if currentThread == syncThread then thread = IEex_Thread.Sync end
		if currentThread == asyncThread then thread = IEex_Thread.Async end
	end

	if thread == IEex_Thread.Sync then
		if syncThread ~= -1 then
			if currentThread ~= syncThread then
				printMessage("[ASSERT FAILED] Not in Sync THREAD", 1)
				return true
			end
			if not IEex_InSyncState then
				printMessage("[ASSERT FAILED] Not in Sync STATE", 2)
				return true
			end
		else
			printMessage("[ASSERT FAILED] Sync THREAD not yet discovered", 4)
			return true
		end
	elseif thread == IEex_Thread.Async then
		if asyncThread ~= -1 then
			if currentThread ~= asyncThread then
				printMessage("[ASSERT FAILED] Not in Async THREAD", 3)
				return true
			end
			if not IEex_InAsyncState then
				printMessage("[ASSERT FAILED] Not in Async STATE", 4)
				return true
			end
		else
			printMessage("[ASSERT FAILED] Async THREAD not yet discovered", 4)
			return true
		end
	end

	return false
end
