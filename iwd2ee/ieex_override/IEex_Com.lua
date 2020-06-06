
-------------
-- Options --
-------------

IEex_MinimalStartup = false

--------------------
-- Initialization --
--------------------

IEex_InitialMemory = nil
(function()

	local mainStatus, mainError = pcall(function()

	-- !!!----------------------------------------------------------------!!!
	--  | IEex_Init() is the only new function that is exposed by default. |
	--  | It does several things:                                          |
	--  |                                                                  |
	--  |   1. Exposes the hardcoded function IEex_WriteByte()             |
	--  |                                                                  |
	--  |   2. Exposes the hardcoded function IEex_ExposeToLua()           |
	--  |                                                                  |
	--  |   3. Calls VirtualAlloc() with the following params =>           |
	--  |        lpAddress = 0                                             |
	--  |        dwSize = 0x1000                                           |
	--  |        flAllocationType = MEM_COMMIT | MEM_RESERVE               |
	--  |        flProtect = PAGE_EXECUTE_READWRITE                        |
	--  |                                                                  |
	--  |   4. Passes along the VirtualAlloc()'s return value              |
	-- !!! ---------------------------------------------------------------!!!

		IEex_InitialMemory = IEex_Init()

	end)

	if not mainStatus then
		-- Failed to initialize IEex, clean up junk.
		IEex_MinimalStartup = nil
		error(mainError)
	end

end)()

---------------------
-- Memory Utililty --
---------------------

function IEex_Malloc(size)
	return IEex_Call(IEex_Label("_malloc"), {size}, nil, 0x4)
end

function IEex_Free(address)
	return IEex_Call(IEex_Label("_free"), {address}, nil, 0x4)
end

function IEex_ReadByte(address, index)
	return bit32.extract(IEex_ReadDword(address), index * 0x8, 0x8)
end

function IEex_ReadWord(address, index)
	return bit32.extract(IEex_ReadDword(address), index * 0x10, 0x10)
end

-- Reads a signed 2-byte word at the given address, shifted over by 2*index bytes.
function IEex_ReadSignedWord(address, index)
	local readValue = bit32.extract(IEex_ReadDword(address), index * 0x10, 0x10)
	-- TODO: This is definitely not the right way to do the conversion,
	-- but I have at least 32 bits to play around with; will do for now.
	if readValue >= 32768 then
		return -65536 + readValue
	else
		return readValue
	end
end

function IEex_WriteWord(address, value)
	for i = 0, 1, 1 do
		IEex_WriteByte(address + i, bit32.extract(value, i * 0x8, 0x8))
	end
end

function IEex_WriteDword(address, value)
	for i = 0, 3, 1 do
		IEex_WriteByte(address + i, bit32.extract(value, i * 0x8, 0x8))
	end
end

function IEex_WriteStringAuto(string)
	local address = IEex_Malloc(#string + 1)
	IEex_WriteString(address, string)
	return address
end

-- OS:WINDOWS
function IEex_DllCall(dll, proc, args, ecx, pop)
	local procaddress = #dll + 1
	local dlladdress = IEex_Malloc(procaddress + #proc + 1)
	procaddress = dlladdress + procaddress
	IEex_WriteString(dlladdress, dll)
	IEex_WriteString(procaddress, proc)
	local dllhandle = IEex_Call(IEex_Label("__imp__LoadLibraryA"), {dlladdress}, nil, 0x0)
	local procfunc = IEex_Call(IEex_Label("__imp__GetProcAddress"), {procaddress, dllhandle}, nil, 0x0)
	local result = IEex_Call(procfunc, args, ecx, pop)
	IEex_Free(dlladdress)
	return result
end

-------------------
-- Debug Utility --
-------------------

function IEex_FunctionLog(message)
	local name = debug.getinfo(2, "n").name
	if name == nil then name = "(Unknown)" end
	print("[IEex] "..name..": "..message)
end

function IEex_Error(message)
	error(message.." "..debug.traceback())
end

function IEex_TracebackMessage(message)
	message = message.."\n"..debug.traceback()
	print(message)
	IEex_MessageBox(message)
end

IEex_ReadDwordDebug_Suppress = false
function IEex_ReadDwordDebug(reading, read)
	if not IEex_ReadDwordDebug_Suppress then
		--print("[IEex] IEex_ReadDwordDebug: "..IEex_ToHex(reading).." => "..IEex_ToHex(read))
	end
end

function IEex_DumpLuaStack()
	IEex_FunctionLog("Lua Stack =>")
	IEex_ReadDwordDebug_Suppress = true
	local lua_State = IEex_ReadDword(IEex_Label("_g_lua"))
	local top = IEex_Call(IEex_Label("_lua_gettop"), {lua_State}, nil, 0x4)
	for i = 1, top, 1 do
		local t = IEex_Call(IEex_Label("_lua_type"), {i, lua_State}, nil, 0x8)
		if t == 0 then
			IEex_FunctionLog("    nil")
		elseif t == 1 then
			local boolean = IEex_Call(IEex_Label("_lua_toboolean"), {i, lua_State}, nil, 0x8)
			IEex_FunctionLog("    boolean: "..boolean)
		elseif t == 3 then
			local number = IEex_Call(IEex_Label("_lua_tonumberx"), {0x0, i, lua_State}, nil, 0xC)
			IEex_FunctionLog("    number: "..IEex_ToHex(number))
		elseif t == 4 then
			local string = IEex_Call(IEex_Label("_lua_tolstring"), {0x0, i, lua_State}, nil, 0x8)
			IEex_FunctionLog("    string: "..IEex_ReadString(string))
		else
			local typeName = IEex_Call(IEex_Label("_lua_typename"), {i, lua_State}, nil, 0x8)
			IEex_FunctionLog("    type: "..t..", typeName: "..IEex_ReadString(typeName))
		end
	end
	IEex_ReadDwordDebug_Suppress = false
end

function IEex_DumpDynamicCode()
	IEex_ReadDwordDebug_Suppress = true
	IEex_FunctionLog("IEex => Dynamic Code")
	for i, codePage in ipairs(IEex_CodePageAllocations) do
		IEex_FunctionLog(i)
		for j, entry in ipairs(codePage) do
			IEex_FunctionLog("    "..j)
			IEex_FunctionLog("        Entry Address: "..IEex_ToHex(entry.address))
			IEex_FunctionLog("        Entry Size: "..IEex_ToHex(entry.size))
			IEex_FunctionLog("        Entry Reserved: "..tostring(entry.reserved))
			if entry.reserved then
				local byteDump = "        "
				local address = entry.address
				local limit = address + entry.size
				for address = entry.address, limit, 4 do
					local currentDword = IEex_ReadDword(address)
					for k = 0, 3, 1 do
						local byteAddress = address + k
						if byteAddress < limit then
							local byte = bit32.extract(currentDword, k * 8, 8)
							byteDump = byteDump..IEex_ToHex(byte, 2, true).." "
						end
					end
				end
				IEex_FunctionLog(byteDump)
			end
		end
	end
	IEex_ReadDwordDebug_Suppress = false
end

-- OS:WINDOWS
function IEex_MessageBox(message)
	local caption = "IEex"
	local messageAddress = IEex_Malloc(#message + 1 + #caption + 1)
	local captionAddress = messageAddress + #message + 1
	IEex_WriteString(messageAddress, message)
	IEex_WriteString(captionAddress, caption)
	IEex_DllCall("User32", "MessageBoxA", {IEex_Flags({0x40}), captionAddress, messageAddress, 0x0}, nil, 0x0)
	IEex_Free(messageAddress)
end

--------------------
-- Random Utility --
--------------------

function IEex_ConcatTables(tables)
	local toReturn = {}
	for _, _table in ipairs(tables) do
		if type(_table) == "table" then
			for _, element in ipairs(_table) do
				table.insert(toReturn, element)
			end
		else
			table.insert(toReturn, _table)
		end
	end
	return toReturn
end

function IEex_RoundUp(numToRound, multiple)
	if multiple == 0 then
		return numToRound
	end
	local remainder = numToRound % multiple
	if remainder == 0 then
		return numToRound
	end
	return numToRound + multiple - remainder;
end

function IEex_CharFind(string, char, startingIndex)
	local limit = #string
	for i = startingIndex or 1, limit, 1 do
		local subChar = string:sub(i, i)
		if subChar == char then
			return i
		end
	end
	return -1
end

function IEex_SplitByChar(string, char)
	local splits = {}
	local startIndex = 1
	local found = IEex_CharFind(string, char)
	while found ~= -1 do
		table.insert(splits, string:sub(startIndex, found - 1))
		startIndex = found + 1
		found = IEex_CharFind(string, char, startIndex)
	end
	if #string - startIndex + 1 > 0 then
		table.insert(splits, string:sub(startIndex, #string))
	end
	return splits
end

----------------------
-- Assembly Writing --
----------------------

IEex_GlobalAssemblyLabels = {}
function IEex_DefineAssemblyLabel(label, value)
	IEex_GlobalAssemblyLabels[label] = value
end

function IEex_Label(label)
	local value = IEex_GlobalAssemblyLabels[label]
	if not value then
		IEex_Error("Label @"..label.." is not defined in the global scope!")
	end
	return IEex_GlobalAssemblyLabels[label]
end

IEex_GlobalAssemblyMacros = {}
function IEex_DefineAssemblyMacro(macroName, macroValue)
	IEex_GlobalAssemblyMacros[macroName] = macroValue
end

-- Some more complex assembly solutions require special macro functions
-- to generate the correct bytes on the fly
function IEex_ResolveMacro(address, args, currentWriteAddress, section, func)
	func = func or function() end
	local sectionSplit = IEex_SplitByChar(section, ",")
	local macro = sectionSplit[1]
	local macroName = string.sub(macro, 2, #macro)
	local macroValue = IEex_GlobalAssemblyMacros[macroName]
	if not macroValue then
		IEex_Error("Macro "..macro.." not defined!")
	end
	local macroType = type(macroValue)
	if macroType == "string" then
		return macroValue
	elseif macroType == "function" then
		local macroArgs = {}
		local limit = #sectionSplit
		for i = 2, limit, 1 do
			local resolvedArg = IEex_ResolveMacroArg(address, args, currentWriteAddress, sectionSplit[i])
			table.insert(macroArgs, resolvedArg)
		end
		return macroValue(currentWriteAddress, macroArgs, func)
	else
		IEex_Error("Invalid macro type in \""..macroName.."\": \""..macroType.."\"!")
	end
end

function IEex_ResolveMacroArg(address, args, currentWriteAddress, section)
	local toReturn = nil
	local prefix = string.sub(section, 1, 1)
	if prefix == ":" then
		local targetOffset = tonumber(string.sub(section, 2, #section), 16)
		toReturn = targetOffset - (currentWriteAddress + 4)
	elseif prefix == "#" then
		toReturn = tonumber(string.sub(section, 2, #section), 16)
	elseif prefix == "+" then
		toReturn = currentWriteAddress + 4 + tonumber(string.sub(section, 2, #section), 16)
	elseif prefix == ">" then
		local label = string.sub(section, 2, #section)
		local offset = IEex_CalcLabelOffset(address, args, label)
		local targetOffset = nil
		if offset then
			targetOffset = address + offset
		else
			targetOffset = IEex_GlobalAssemblyLabels[label]
			if not targetOffset then
				IEex_Error("Label @"..label.." is not defined in current scope!")
			end
		end
		toReturn = targetOffset - (currentWriteAddress + 4)
	elseif prefix == "*" then
		local label = string.sub(section, 2, #section)
		local offset = IEex_CalcLabelOffset(address, args, label)
		local targetOffset = nil
		if offset then
			targetOffset = address + offset
		else
			targetOffset = IEex_GlobalAssemblyLabels[label]
			if not targetOffset then
				IEex_Error("Label @"..label.." is not defined in current scope!")
			end
		end
		toReturn = targetOffset
	elseif prefix == "!" then
		IEex_Error("Nested macros are not implemented! (did you really expect me to implement proper bracket matching?)")
	elseif prefix == "@" then
		IEex_Error("Why have you passed a label to a macro?")
	else
		toReturn = tonumber(section, 16)
	end
	return toReturn
end

function IEex_CalcWriteLength(address, args)
	local toReturn = 0
	for _, arg in ipairs(args) do
		local argType = type(arg)
		if argType == "string" then
			-- processTextArg needs to be "defined" up here to have processSection see it.
			local processTextArg = nil
			local inComment = false
			local processSection = function(section)
				local prefix = string.sub(section, 1, 1)
				if prefix == ";" then
					inComment = not inComment
				elseif not inComment then
					if prefix == ":" or prefix == "#" or prefix == "+" then
						toReturn = toReturn + 4
					elseif prefix == ">" or prefix == "*" then
						local label = string.sub(section, 2, #section)
						if
							not IEex_CalcLabelOffset(address, args, label)
							and not IEex_GlobalAssemblyLabels[label]
						then
							IEex_Error("Label @"..label.." is not defined in current scope!")
						end
						toReturn = toReturn + 4
					elseif prefix == "!" then -- Processes a macro
						local macroResult = IEex_ResolveMacro(address, args, toReturn, section)
						if type(macroResult) == "string" then
							if processTextArg(macroResult) then
								return true
							end
						else
							toReturn = toReturn + macroResult
						end
					elseif prefix ~= "@" and prefix ~= "$" then
						toReturn = toReturn + 1
					end
				end
			end
			processTextArg = function(innerArg)
				innerArg = innerArg:gsub("%s+", " ")
				local limit = #innerArg
				local lastSpace = 0
				for i = 1, limit, 1 do
					local char = string.sub(innerArg, i, i)
					if char == " " then
						if i - lastSpace > 1 then
							local section = string.sub(innerArg, lastSpace + 1, i - 1)
							processSection(section)
						end
						lastSpace = i
					end
				end
				if limit - lastSpace > 0 then
					local lastSection = string.sub(innerArg, lastSpace + 1, limit)
					processSection(lastSection)
				end
			end
			processTextArg(arg)
		elseif argType == "table" then
			local argSize = #arg
			if argSize == 2 or argSize == 3 then
				local address = arg[1]
				local length = arg[2]
				local relativeFromOffset = arg[3]
				if type(address) == "number" and type(length) == "number"
					and (not relativeFromOffset or type(relativeFromOffset) == "number")
				then
					toReturn = toReturn + length
				else
					IEex_Error("Variable write argument included invalid data-type!")
				end
			else
				IEex_Error("Variable write argument did not have at 2-3 args!")
			end
		else
			IEex_Error("Illegal data-type in assembly declaration!")
		end
	end
	return toReturn
end

function IEex_CalcLabelOffset(address, args, label)
	local toReturn = 0
	for _, arg in ipairs(args) do
		local argType = type(arg)
		if argType == "string" then
			-- processTextArg needs to be "defined" up here to have processSection see it.
			local processTextArg = nil
			local inComment = false
			local processSection = function(section)
				local prefix = string.sub(section, 1, 1)
				if prefix == ";" then
					inComment = not inComment
				elseif not inComment then
					if prefix == ":" or prefix == "#" or prefix == "+" or prefix == ">" or prefix == "*" then
						toReturn = toReturn + 4
					elseif prefix == "!" then -- Processes a macro
						local macroResult = IEex_ResolveMacro(address, args, toReturn, section)
						if type(macroResult) == "string" then
							if processTextArg(macroResult) then
								return true
							end
						else
							toReturn = toReturn + macroResult
						end
					elseif prefix == "@" or prefix == "$" then
						local argLabel = string.sub(section, 2, #section)
						if argLabel == label then
							return true
						end
					else
						toReturn = toReturn + 1
					end
				end
			end
			processTextArg = function(innerArg)
				innerArg = innerArg:gsub("%s+", " ")
				local limit = #innerArg
				local lastSpace = 0
				for i = 1, limit, 1 do
					local char = string.sub(innerArg, i, i)
					if char == " " then
						if i - lastSpace > 1 then
							local section = string.sub(innerArg, lastSpace + 1, i - 1)
							if processSection(section) then
								return true
							end
						end
						lastSpace = i
					end
				end
				if limit - lastSpace > 0 then
					local lastSection = string.sub(innerArg, lastSpace + 1, limit)
					if processSection(lastSection) then
						return true
					end
				end
			end
			if processTextArg(arg) then
				return toReturn
			end
		elseif argType == "table" then
			local argSize = #arg
			if argSize == 2 or argSize == 3 then
				local address = arg[1]
				local length = arg[2]
				local relativeFromOffset = arg[3]
				if type(address) == "number" and type(length) == "number"
					and (not relativeFromOffset or type(relativeFromOffset) == "number")
				then
					toReturn = toReturn + length
				else
					IEex_Error("Variable write argument included invalid data-type!")
				end
			else
				IEex_Error("Variable write argument did not have at 2-3 args!")
			end
		else
			IEex_Error("Illegal data-type in assembly declaration!")
		end
	end
end

--[[

Core function that writes assembly declarations into memory. args syntax =>

"args" MUST be a table. Acceptable sub-argument types:

	a) string:

		Every byte / operation MUST be seperated by some kind of whitespace. Syntax:

		number  = Writes hex number as byte.
		:number = Writes relative offset to hex number. Depreciated; please use label operations instead.
		#number = Writes hex number as dword.
		+number = Writes address of relative offset. Depreciated; please use label operations instead.
		>label  = Writes relative offset to label's address.
		*label  = Writes label's address.
		@label  = Defines a local label that can be used in the above two operations.
		          (only in current IEex_WriteAssembly call, use IEex_DefineAssemblyLabel()
		          if you want to create a global label)
		$label  = Defines a global label
		!macro  = Writes macro's bytes.

	b) table:

		Used to write the value of a Lua variable into memory.

		table[1] = Value to write.
		table[2] = How many bytes of table[1] to write.
		table[3] = If present, writes the relative offset to table[1] from table[3]. (Optional)

--]]

function IEex_WriteAssembly(address, args, funcOverride)
	local currentWriteAddress = address
	if not funcOverride then
		local writeDump = ""
		IEex_WriteAssembly(address, args, function(writeAddress, byte)
			writeDump = writeDump..IEex_ToHex(byte, 2, true).." "
		end)
		IEex_FunctionLog("\n\nWriting Assembly at "..IEex_ToHex(address).." => "..writeDump.."\n")
		funcOverride = function(writeAddress, byte)
			IEex_WriteByte(writeAddress, byte)
		end
	end
	for _, arg in ipairs(args) do
		local argType = type(arg)
		if argType == "string" then
			-- processTextArg needs to be "defined" up here to have processSection see it.
			local processTextArg = nil
			local inComment = false
			local processSection = function(section)
				local prefix = string.sub(section, 1, 1)
				if prefix == ";" then
					inComment = not inComment
				elseif not inComment then
					if prefix == ":" then -- Writes relative offset to known address
						local targetOffset = tonumber(string.sub(section, 2, #section), 16)
						local relativeOffsetNeeded = targetOffset - (currentWriteAddress + 4)
						for i = 0, 3, 1 do
							local byte = bit32.extract(relativeOffsetNeeded, i * 8, 8)
							funcOverride(currentWriteAddress, byte)
							currentWriteAddress = currentWriteAddress + 1
						end
					elseif prefix == "#" then
						local toWrite = tonumber(string.sub(section, 2, #section), 16)
						for i = 0, 3, 1 do
							local byte = bit32.extract(toWrite, i * 8, 8)
							funcOverride(currentWriteAddress, byte)
							currentWriteAddress = currentWriteAddress + 1
						end
					elseif prefix == "+" then -- Writes absolute address of relative offset
						local targetOffset = currentWriteAddress + 4 + tonumber(string.sub(section, 2, #section), 16)
						for i = 0, 3, 1 do
							local byte = bit32.extract(targetOffset, i * 8, 8)
							funcOverride(currentWriteAddress, byte)
							currentWriteAddress = currentWriteAddress + 1
						end
					elseif prefix == ">" then -- Writes relative offset to label
						local label = string.sub(section, 2, #section)
						local offset = IEex_CalcLabelOffset(address, args, label)
						local targetOffset = nil
						if offset then
							targetOffset = address + offset
						else
							targetOffset = IEex_GlobalAssemblyLabels[label]
							if not targetOffset then
								IEex_Error("Label @"..label.." is not defined in current scope!")
							end
						end
						local relativeOffsetNeeded = targetOffset - (currentWriteAddress + 4)
						for i = 0, 3, 1 do
							local byte = bit32.extract(relativeOffsetNeeded, i * 8, 8)
							funcOverride(currentWriteAddress, byte)
							currentWriteAddress = currentWriteAddress + 1
						end
					elseif prefix == "*" then -- Writes absolute address of label
						local label = string.sub(section, 2, #section)
						local offset = IEex_CalcLabelOffset(address, args, label)
						local targetOffset = nil
						if offset then
							targetOffset = address + offset
						else
							targetOffset = IEex_GlobalAssemblyLabels[label]
							if not targetOffset then
								IEex_Error("Label @"..label.." is not defined in current scope!")
							end
						end
						for i = 0, 3, 1 do
							local byte = bit32.extract(targetOffset, i * 8, 8)
							funcOverride(currentWriteAddress, byte)
							currentWriteAddress = currentWriteAddress + 1
						end
					elseif prefix == "!" then -- Processes a macro
						local macroResult = IEex_ResolveMacro(address, args, toReturn, section, func)
						if type(macroResult) == "string" then
							processTextArg(macroResult)
						else
							currentWriteAddress = currentWriteAddress + macroResult
						end
					elseif prefix == "$" then
						local label = string.sub(section, 2, #section)
						IEex_DefineAssemblyLabel(label, currentWriteAddress)
					elseif prefix ~= "@" then
						local byte = tonumber(section, 16)
						funcOverride(currentWriteAddress, byte)
						currentWriteAddress = currentWriteAddress + 1
					end
				end
			end
			processTextArg = function(innerArg)
				innerArg = innerArg:gsub("%s+", " ")
				local limit = #innerArg
				local lastSpace = 0
				for i = 1, limit, 1 do
					local char = string.sub(innerArg, i, i)
					if char == " " then
						if i - lastSpace > 1 then
							local section = string.sub(innerArg, lastSpace + 1, i - 1)
							processSection(section)
						end
						lastSpace = i
					end
				end
				if limit - lastSpace > 0 then
					local lastSection = string.sub(innerArg, lastSpace + 1, limit)
					processSection(lastSection)
				end
			end
			processTextArg(arg)
		elseif argType == "table" then
			local argSize = #arg
			if argSize == 2 or argSize == 3 then
				local address = arg[1]
				local length = arg[2]
				local relativeFromOffset = arg[3]
				if type(address) == "number" and type(length) == "number"
					and (not relativeFromOffset or type(relativeFromOffset) == "number")
				then
					if relativeFromOffset then address = address - currentWriteAddress - relativeFromOffset end
					local limit = length - 1
					for i = 0, limit, 1 do
						local byte = bit32.extract(address, i * 8, 8)
						funcOverride(currentWriteAddress, byte)
						currentWriteAddress = currentWriteAddress + 1
					end
				else
					IEex_Error("Variable write argument included invalid data-type!")
				end
			else
				IEex_Error("Variable write argument did not have at 2-3 args!")
			end
		else
			IEex_Error("Illegal data-type in assembly declaration!")
		end
	end
end

-- NOTE: Same as IEex_WriteAssembly(), but writes to a dynamically
-- allocated memory space instead of a provided address.
-- Very useful for writing new executable code into memory.
function IEex_WriteAssemblyAuto(assembly)
	local reservedAddress, reservedLength = IEex_ReserveCodeMemory(assembly)
	IEex_FunctionLog("Reserved "..IEex_ToHex(reservedLength).." bytes at "..IEex_ToHex(reservedAddress))
	IEex_WriteAssembly(reservedAddress, assembly)
	return reservedAddress
end

function IEex_WriteAssemblyFunction(functionName, assembly)
	local functionAddress = IEex_WriteAssemblyAuto(assembly)
	IEex_ExposeToLua(functionAddress, functionName)
	return functionAddress
end

function IEex_HookBeforeCall(address, assembly)
	IEex_WriteAssembly(address, {"!jmp_dword", {IEex_WriteAssemblyAuto(
		IEex_ConcatTables({
			assembly,
			{
				"!call", {address + IEex_ReadDword(address + 0x1) + 0x5, 4, 4},
			},
			{[[
				@return
				!jmp_dword ]], {address + 0x5, 4, 4},
			},
		})
	), 4, 4}})
end

function IEex_HookAfterCall(address, assembly)
	IEex_WriteAssembly(address, {"!jmp_dword", {IEex_WriteAssemblyAuto(
		IEex_ConcatTables({
			{
				"!call", {address + IEex_ReadDword(address + 0x1) + 0x5, 4, 4},
			},
			assembly,
			{[[
				@return
				!jmp_dword ]], {address + 0x5, 4, 4},
			},
		})
	), 4, 4}})
end

function IEex_HookRestore(address, restoreDelay, restoreSize, assembly)

	local storeBytes = function(startAddress, size)
		local bytes = {}
		local limit = startAddress + size - 1
		for i = startAddress, limit, 1 do
			table.insert(bytes, {IEex_ReadByte(i, 0), 1})
		end
		return bytes
	end

	local afterInstruction = address + restoreDelay + restoreSize
	local restoreBytes = storeBytes(address + restoreDelay, restoreSize)

	local nops = {}
	local limit = restoreDelay + restoreSize - 5
	for i = 1, limit, 1 do
		table.insert(nops, {0x90, 1})
	end

	local hookCode = IEex_WriteAssemblyAuto(IEex_ConcatTables({
		assembly,
		"@return",
		restoreBytes,
		{[[
			!jmp_dword ]], {afterInstruction, 4, 4},
		},
	}))

	IEex_WriteAssembly(address, IEex_ConcatTables({
		{
			"!jmp_dword", {hookCode, 4, 4}
		},
		nops,
	}))
end

function IEex_HookAfterRestore(address, restoreDelay, restoreSize, assembly)

	local storeBytes = function(startAddress, size)
		local bytes = {}
		local limit = startAddress + size - 1
		for i = startAddress, limit, 1 do
			table.insert(bytes, {IEex_ReadByte(i, 0), 1})
		end
		return bytes
	end

	local afterInstruction = address + restoreDelay + restoreSize
	local restoreBytes = storeBytes(address + restoreDelay, restoreSize)

	local nops = {}
	local limit = restoreDelay + restoreSize - 5
	for i = 1, limit, 1 do
		table.insert(nops, {0x90, 1})
	end

	local hookCode = IEex_WriteAssemblyAuto(IEex_ConcatTables({
		restoreBytes,
		assembly,
		"@return",
		{[[
			!jmp_dword ]], {afterInstruction, 4, 4},
		},
	}))

	IEex_WriteAssembly(address, IEex_ConcatTables({
		{
			"!jmp_dword", {hookCode, 4, 4}
		},
		nops,
	}))
end

function IEex_WriteOpcode(opcodeFunctions)

	local IEex_RunOpcodeDecode = function(vftable)
		return {[[
			!push_dword #18C
			!call :7FC95B
			!mov_ebx_eax
			!add_esp_byte 04
			!mov_[esp+byte]_ebx 20
			!cmp_ebx_edi
			!mov_[esp+byte]_dword 18 #1
			!jz_dword :492C9B
			!mov_eax_[esp+byte] 2C
			!mov_ecx_[eax+byte] 04
			!mov_edx_[eax]
			!mov_eax_[esp+byte] 28
			!push_edi
			!push_ecx
			!mov_ecx_[esp+byte] 2C
			!push_edx
			!push_eax
			!push_ecx
			!push_esi
			!mov_ecx_ebx
			!call :48C310
			!mov_[ebx]_dword ]], {vftable, 4}, [[
			!mov_edi_ebx
			!jmp_dword :492C9B
		]]}
	end

	local IEex_WriteOpcodeCopy = function(vftable)

		local UnwindMapEntry = IEex_Malloc(0x8)
		IEex_WriteDword(UnwindMapEntry + 0x0, -0x1)
		IEex_WriteDword(UnwindMapEntry + 0x4, IEex_WriteAssemblyAuto({[[
			!mov_eax_[ebp+byte] F0
			!push_eax
			!call :7FC984
			!pop_ecx
			!ret
		]]}))

		local FuncInfo_V1 = IEex_Malloc(0x1C)
		IEex_WriteDword(FuncInfo_V1 + 0x0,  0x19930520)
		IEex_WriteDword(FuncInfo_V1 + 0x4,  0x1)
		IEex_WriteDword(FuncInfo_V1 + 0x8,  UnwindMapEntry)
		IEex_WriteDword(FuncInfo_V1 + 0xC,  0x0)
		IEex_WriteDword(FuncInfo_V1 + 0x10, 0x0)
		IEex_WriteDword(FuncInfo_V1 + 0x14, 0x0)
		IEex_WriteDword(FuncInfo_V1 + 0x18, 0x0)

		local SEH = IEex_WriteAssemblyAuto({[[
			!mov_eax ]], {FuncInfo_V1, 4}, [[
			!jmp_dword :7E7598
		]]})

		return IEex_WriteAssemblyAuto({[[
			!push_byte FF
			!push_dword ]], {SEH, 4}, [[
			!mov_eax_fs:[0]
			!push_eax
			!mov_fs:[0]_esp
			!push_ecx
			!push_ebx
			!push_esi
			!push_edi
			!mov_esi_ecx
			!call :4A4B00
			!push_dword #18C
			!mov_ebx_eax
			!call :7FC95B
			!mov_edi_eax
			!add_esp_byte 04
			!mov_[esp+byte]_edi 0C
			!test_edi_edi
			!mov_[esp+byte]_dword 18 #0
			!je_dword >0
			!mov_ecx_[esi+dword] #88
			!mov_edx_[esi+dword] #84
			!mov_eax_[esi+dword] #10C
			!push_byte 00
			!push_ecx
			!push_edx
			!push_eax
			!lea_eax_[esi+byte] 7C
			!push_eax
			!push_ebx
			!mov_ecx_edi
			!call :48C310
			!mov_[edi]_dword ]], {vftable, 4}, [[
			!jmp_dword >1
			@0
			!xor_edi_edi
			@1
			!push_ebx
			!mov_[esp+byte]_dword 1C #FFFFFFFF
			!call :7FC984
			!add_esp_byte 04
			!test_esi_esi
			!je_dword >3
			!lea_eax_[esi+byte] 04
			!jmp_dword >4
			@3
			!xor_eax_eax
			@4
			!push_eax
			!mov_ecx_edi
			!call :48C670
			!mov_ecx_[esp+byte] 10
			!mov_eax_edi
			!pop_edi
			!pop_esi
			!pop_ebx
			!mov_fs:[0]_ecx
			!add_esp_byte 10
			!ret
		]]})
	end

	local vftable = IEex_Malloc(0x28)

	local writeOrDefault = function(writeAddress, writeStuff, defaultValue)
		local toWrite = nil
		if writeStuff ~= nil then
			toWrite = IEex_WriteAssemblyAuto(writeStuff)
		else
			toWrite = defaultValue
		end
		IEex_WriteDword(writeAddress, toWrite)
	end

	writeOrDefault(vftable + 0x0,  opcodeFunctions["__vecDelDtor"],  0x499BE0) -- retn 0x4  - (implemented)
	writeOrDefault(vftable + 0x4,  opcodeFunctions["Copy"],          IEex_WriteOpcodeCopy(vftable))
	writeOrDefault(vftable + 0x8,  opcodeFunctions["ApplyEffect"],   0x799E20) -- retn 0x4  - (xor eax, eax)
	writeOrDefault(vftable + 0xC,  opcodeFunctions["ResolveEffect"], 0x4A3030) -- retn 0x4  - (implemented)
	writeOrDefault(vftable + 0x10, opcodeFunctions["OnAddSpecific"], 0x799E60) -- retn 0x4  - (nullsub)
	writeOrDefault(vftable + 0x14, opcodeFunctions["OnLoad"],        0x799E60) -- retn 0x4  - (nullsub)
	writeOrDefault(vftable + 0x18, opcodeFunctions["CheckSave"],     0x4A42F0) -- retn 0x14 - (implemented)
	writeOrDefault(vftable + 0x1C, opcodeFunctions["UsesDice"],      0x78E6E0) -- retn 0x0  - (xor eax, eax)
	writeOrDefault(vftable + 0x20, opcodeFunctions["DisplayString"], 0x4A4BB0) -- retn 0x4  - (implemented)
	writeOrDefault(vftable + 0x24, opcodeFunctions["OnRemove"],      0x4A51D0) -- retn 0x4  - (implemented)

	return IEex_RunOpcodeDecode(vftable)

end

----------------------
--  Bits Utilility  --
----------------------

function IEex_Flags(flags)
	local result = 0x0
	for _, flag in ipairs(flags) do
		result = bit32.bor(result, flag)
	end
	return result
end

function IEex_IsBitSet(original, isSetIndex)
	return bit32.band(original, bit32.lshift(0x1, isSetIndex)) ~= 0x0
end

function IEex_AreBitsSet(original, bitsString)
	return IEex_IsMaskSet(original, tonumber(bitsString, 2))
end

function IEex_IsMaskSet(original, isSetMask)
	return bit32.band(original, isSetMask) == isSetMask
end

function IEex_IsBitUnset(original, isUnsetIndex)
	return bit32.band(original, bit32.lshift(0x1, isUnsetIndex)) == 0x0
end

function IEex_AreBitsUnset(original, bitsString)
	return IEex_IsMaskUnset(original, tonumber(bitsString, 2))
end

function IEex_IsMaskUnset(original, isUnsetMask)
	return bit32.band(original, isUnsetMask) == 0x0
end

function IEex_SetBit(original, toSetIndex)
	return bit32.bor(original, bit32.lshift(0x1, toSetIndex))
end

function IEex_SetBits(original, bitsString)
	return IEex_SetMask(original, tonumber(bitsString, 2))
end

function IEex_SetMask(original, toSetMask)
	return bit32.bor(original, toSetMask)
end

function IEex_UnsetBit(original, toUnsetIndex)
	return bit32.band(original, bit32.bnot(bit32.lshift(0x1, toUnsetIndex)))
end

function IEex_UnsetBits(original, bitsString)
	return IEex_UnsetMask(original, tonumber(bitsString, 2))
end

function IEex_UnsetMask(original, toUnsetmask)
	return bit32.band(original, bit32.bnot(toUnsetmask))
end

function IEex_ToHex(number, minLength, prefix)
	if type(number) ~= "number" then
		-- This is usually a critical error somewhere else
		-- in the code, so throw a fully fledged error.
		IEex_Error("Passed a NaN value: '"..tostring(number).."'!")
	end
	local hexString = string.format("%x", number)
	local wantedLength = (minLength or 0) - #hexString
	for i = 1, wantedLength, 1 do
		hexString = "0"..hexString
	end
	hexString = hexString:upper()
	if not prefix then
		return "0x"..hexString
	else
		return hexString
	end
end

-------------------------------
-- Dynamic Memory Allocation --
-------------------------------

-- OS:WINDOWS
function IEex_GetAllocGran()
	local systemInfo = IEex_Malloc(0x24)
	IEex_DllCall("Kernel32", "GetSystemInfo", {systemInfo}, nil, 0x0)
	local allocGran = IEex_ReadDword(systemInfo + 0x1C)
	IEex_Free(systemInfo)
	return allocGran
end

-- OS:WINDOWS
function IEex_VirtualAlloc(dwSize, flProtect)
	-- 0x1000 = MEM_COMMIT
	-- 0x2000 = MEM_RESERVE
	return IEex_DllCall("Kernel32", "VirtualAlloc", {flProtect, IEex_Flags({0x1000, 0x2000}), dwSize, 0x0}, nil, 0x0)
end

IEex_CodePageAllocations = {}
-- NOTE: Please don't call this directly. This is used internally
-- by IEex_ReserveCodeMemory() to allocate additional code pages
-- when needed. If you ignore this message, god help you.
function IEex_AllocCodePage(size)
	local allocGran = IEex_GetAllocGran()
	size = IEex_RoundUp(size, allocGran)
	local address = IEex_VirtualAlloc(size, 0x40)
	local initialEntry = {}
	initialEntry.address = address
	initialEntry.size = size
	initialEntry.reserved = false
	local codePageEntry = {initialEntry}
	table.insert(IEex_CodePageAllocations, codePageEntry)
	return codePageEntry
end

-- NOTE: Dynamically allocates and reserves executable memory for
-- new code. No reason to use instead of IEex_WriteAssemblyAuto,
-- unless you want to reserve memory for later use.
-- Supports filling holes caused by freeing code reservations,
-- (if you would ever want to do that?...), though freeing is not
-- currently implemented.
function IEex_ReserveCodeMemory(assembly)
	local reservedAddress = -1
	local writeLength = -1
	local processCodePageEntry = function(codePage)
		for i, allocEntry in ipairs(codePage) do
			if not allocEntry.reserved then
				writeLength = IEex_CalcWriteLength(allocEntry.address, assembly)
				if writeLength <= allocEntry.size then
					local memLeftOver = allocEntry.size - writeLength
					if memLeftOver > 0 then
						local newAddress = allocEntry.address + writeLength
						local nextEntry = codePage[i + 1]
						if nextEntry then
							if not nextEntry.reserved then
								local addressDifference = nextEntry.address - newAddress
								nextEntry.address = newAddress
								nextEntry.size = allocEntry.size + addressDifference
							else
								local newEntry = {}
								newEntry.address = newAddress
								newEntry.size = memLeftOver
								newEntry.reserved = false
								table.insert(codePage, newEntry, i + 1)
							end
						else
							local newEntry = {}
							newEntry.address = newAddress
							newEntry.size = memLeftOver
							newEntry.reserved = false
							table.insert(codePage, newEntry)
						end
					end
					allocEntry.size = writeLength
					allocEntry.reserved = true
					reservedAddress = allocEntry.address
					return true
				end
			end
		end
		return false
	end
	for _, codePage in ipairs(IEex_CodePageAllocations) do
		if processCodePageEntry(codePage) then
			break
		end
	end
	if reservedAddress == -1 then
		local newCodePage = IEex_AllocCodePage(1)
		if not processCodePageEntry(newCodePage) then
			IEex_Error("***FATAL*** I CAN ONLY ALLOCATE UP TO ALLOCGRAN ***FATAL*** \z
				Tell Bubb he should at least guess at how big the write needs to be, \z
				overestimating where required, instead of crashing like an idiot. \z
				(Though, I must ask, how in the world are you writing a function that is \z
				longer than 65536 bytes?!)")
		end
	end
	return reservedAddress, writeLength
end

-------------------------
-- !CODE MANIPULATION! --
-------------------------

-- OS:WINDOWS
-- Don't use this unless
-- you REALLY know what you are doing.
-- Enables writing to the .text section of the
-- exe (code).
function IEex_DisableCodeProtection()
	local temp = IEex_Malloc(0x4)
	-- 0x40 = PAGE_EXECUTE_READWRITE
	-- 0x401000 = Start of .text section in memory.
	-- 0x49F000 = Size of .text section in memory.
	IEex_DllCall("Kernel32", "VirtualProtect", {temp, 0x40, 0x49F000, 0x401000}, nil, 0x0)
	IEex_Free(temp)
end

-- OS:WINDOWS
-- If you were crazy enough to use
-- IEex_DisableCodeProtection(), please
-- use this to reverse your bad decisions.
-- Reverts the .text section protections back
-- to default.
function IEex_EnableCodeProtection()
	local temp = IEex_Malloc(0x4)
	-- 0x20 = PAGE_EXECUTE_READ
	-- 0x401000 = Start of .text section in memory.
	-- 0x49F000 = Size of .text section in memory.
	IEex_DllCall("Kernel32", "VirtualProtect", {temp, 0x20, 0x49F000, 0x401000}, nil, 0x0)
	IEex_Free(temp)
end

-------------
-- Startup --
-------------

(function()

	-- Inform the dynamic memory system of the hardcoded starting memory.
	-- (Had to hardcode initial memory because I couldn't include a VirtualAlloc wrapper
	-- without using more than the 340 alignment bytes available.)
	table.insert(IEex_CodePageAllocations, {
		{["address"] = IEex_InitialMemory, ["size"] = 0x1000, ["reserved"] = false}
	})

	-- Fetch the matched pattern addresses from the loader.
	-- (Thanks @mrfearless!): https://github.com/mrfearless/IEexLoader
	IEex_GlobalAssemblyLabels = IEex_AddressList()

	print("")
	for label, address in pairs(IEex_GlobalAssemblyLabels) do
		print(label..": "..IEex_ToHex(address))
	end
	print("")

	-- Assembly Macros
	dofile("override/IEex_Mac.lua")

	------------------------
	--  Default Functions --
	------------------------

	-- Calls an internal function at the given address.

	-- stackArgs: Includes the values to be pushed before the function is called.
	--            Note that the stackArgs are pushed in the order they are defined,
	--            so in order to call a function properly these args should be defined in reverse.

	-- ecx: Sets the ecx register to the given value directly before calling the internal function.
	--      The ecx register is most commonly used to pass the "this" pointer.

	-- popSize: Some internal functions don't clean up the stackArgs pushed to them. This value
	--          defines the size, (in bytes), that should be removed from the stack after the
	--          internal function is called. Please note that if this value is wrong, the game
	--          WILL crash due to an imbalanced stack.

	-- SIGNATURE:
	-- number eax = IEex_Call(number address, table stackArgs, number ecx, number popSize)
	IEex_WriteAssemblyFunction("IEex_Call", {[[
		!push_state
		!push_byte 02
		!push_[ebp+byte] 08
		!call >_lua_rawlen
		!add_esp_byte 08
		!test_eax_eax
		!je_dword >no_args
		!mov_edi_eax
		!mov_esi #01
		@arg_loop
		!push_esi
		!push_byte 02
		!push_[ebp+byte] 08
		!call >_lua_rawgeti
		!add_esp_byte 0C
		!push_byte 00
		!push_byte FF
		!push_[ebp+byte] 08
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!push_eax
		!push_byte FE
		!push_[ebp+byte] 08
		!call >_lua_settop
		!add_esp_byte 08
		!inc_esi
		!cmp_esi_edi
		!jle_dword >arg_loop
		@no_args
		!push_byte 00
		!push_byte 03
		!push_[ebp+byte] 08
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!push_eax
		!push_byte 00
		!push_byte 01
		!push_[ebp+byte] 08
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!pop_ecx
		!call_eax
		!push_eax
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_[ebp+byte] 08
		!call >_lua_pushnumber
		!add_esp_byte 0C
		!push_byte 00
		!push_byte 04
		!push_[ebp+byte] 08
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!add_esp_eax
		!mov_eax #01
		!pop_state
		!ret
	]]})

	-- Writes the given string at the specified address.
	-- NOTE: Writes a terminating NULL in addition to the raw string.

	-- SIGNATURE:
	-- <void> = IEex_WriteString(number address, string toWrite)
	IEex_WriteAssemblyFunction("IEex_WriteString", {[[

		!build_stack_frame
		!push_registers

		!push_byte 00
		!push_byte 01
		!push_[ebp+byte] 08
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!mov_edi_eax

		!push_byte 00
		!push_byte 02
		!push_[ebp+byte] 08
		!call >_lua_tolstring
		!add_esp_byte 0C

		!mov_esi_eax

		@copy_loop
		!mov_al_[esi]
		!mov_[edi]_al
		!inc_esi
		!inc_edi
		!cmp_byte:[esi]_byte 00
		!jne_dword >copy_loop

		!mov_byte:[edi]_byte 00

		!xor_eax_eax
		!restore_stack_frame
		!ret

	]]})

	-- Writes a string to the given address, padding any remaining space with null bytes to achieve desired length.
	-- If #toWrite >= to maxLength, terminating null is not written.
	-- If #toWrite > maxLength, characters after [1, maxLength] are discarded and not written.

	-- SIGNATURE:
	-- <void> = IEex_WriteLString(number address, string toWrite, number maxLength)
	IEex_WriteAssemblyFunction("IEex_WriteLString", {[[

		!build_stack_frame
		!push_registers

		!push_byte 00
		!push_byte 01
		!push_[ebp+byte] 08
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!mov_edi_eax

		!push_byte 00
		!push_byte 02
		!push_[ebp+byte] 08
		!call >_lua_tolstring
		!add_esp_byte 0C
		!mov_esi_eax

		!push_byte 00
		!push_byte 03
		!push_[ebp+byte] 08
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!mov_ebx_eax

		!xor_edx_edx

		!cmp_edx_ebx
		!jae_dword >return

		!cmp_byte:[esi]_byte 00
		!je_dword >null_loop

		@copy_loop

		!mov_al_[esi]
		!mov_[edi]_al
		!inc_esi
		!inc_edi

		!inc_edx
		!cmp_edx_ebx
		!jae_dword >return

		!cmp_byte:[esi]_byte 00
		!jne_dword >copy_loop

		@null_loop
		!mov_byte:[edi]_byte 00
		!inc_edi

		!inc_edx
		!cmp_edx_ebx
		!jb_dword >null_loop

		@return
		!xor_eax_eax
		!restore_stack_frame
		!ret

	]]})

	local debugHookName = "IEex_ReadDwordDebug"
	local debugHookAddress = IEex_Malloc(#debugHookName + 1)
	IEex_WriteString(debugHookAddress, debugHookName)

	-- Reads a dword at the given address. What more is there to say.

	-- SIGNATURE:
	-- number result = IEex_ReadDword(number address)
	IEex_WriteAssemblyFunction("IEex_ReadDword", {
		"55 8B EC 53 51 52 56 57 6A 00 6A 01 FF 75 08 \z
		!call >_lua_tonumberx \z
		83 C4 0C \z
		!call >__ftol2_sse \z
		FF 30 \z
		50 \z
		68", {debugHookAddress, 4},
		"FF 75 08 \z
		!call >_lua_getglobal \z
		83 C4 08 \z
		DB 04 24 83 EC 04 DD 1C 24 FF 75 08 \z
		!call >_lua_pushnumber \z
		83 C4 0C \z
		FF 34 24 \z
		DB 04 24 83 EC 04 DD 1C 24 FF 75 08 \z
		!call >_lua_pushnumber \z
		83 C4 0C \z
		6A 00 6A 00 6A 00 6A 00 6A 02 FF 75 08 \z
		!call >_lua_pcallk \z
		83 C4 18 \z
		DB 04 24 83 EC 04 DD 1C 24 FF 75 08 \z
		!call >_lua_pushnumber \z
		83 C4 0C B8 01 00 00 00 5F 5E 5A 59 5B 5D C3"
	})

	-- Reads a string from the given address until a NULL is encountered.
	-- NOTE: Certain game structures, (most commonly resrefs), don't
	-- necessarily end in a NULL. Regarding resrefs, if one uses all
	-- 8 characters of alloted space, no NULL will be written. To read
	-- this properly, please use IEex_ReadLString with maxLength set to 8.
	-- In cases where the string is guaranteed to have a terminating NULL,
	-- use this function.

	-- SIGNATURE:
	-- string result = IEex_ReadString(number address)
	IEex_WriteAssemblyFunction("IEex_ReadString", {[[
		!push_state
		!push_byte 00
		!push_byte 01
		!push_[ebp+byte] 08
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!push_eax
		!push_[ebp+byte] 08
		!call >_lua_pushstring
		!add_esp_byte 08
		!mov_eax #01
		!pop_state
		!ret
	]]})

	-- This is much longer than IEex_ReadString because it had to use new behavior.
	-- Reads until NULL is encountered, OR until it reaches the given length.
	-- Registers esi, ebx, and edi are all assumed to be non-volitile.

	-- SIGNATURE:
	-- string result = IEex_ReadLString(number address, number maxLength)
	IEex_WriteAssemblyFunction("IEex_ReadLString", {[[
		!build_stack_frame
		!sub_esp_byte 08
		!push_registers
		!push_byte 00
		!push_byte 01
		!push_[ebp+byte] 08
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!mov_esi_eax
		!push_byte 00
		!push_byte 02
		!push_[ebp+byte] 08
		!call >_lua_tonumberx
		!add_esp_byte 0C
		!call >__ftol2_sse
		!mov_ebx_eax
		!and_eax_byte FC
		!add_eax_byte 04
		!mov_[ebp+byte]_esp FC
		!sub_esp_eax
		!mov_edi_esp
		!mov_[ebp+byte]_edi F8
		!add_ebx_esi
		@read_loop
		!mov_al_[esi]
		!mov_[edi]_al
		!test_al_al
		!je_dword >done
		!inc_esi
		!inc_edi
		!cmp_esi_ebx
		!jl_dword >read_loop
		!mov_[edi]_byte 00
		@done
		!push_[ebp+byte] F8
		!push_[ebp+byte] 08
		!call >_lua_pushstring
		!add_esp_byte 08
		!mov_esp_[ebp+byte] FC
		!mov_eax #01
		!restore_stack_frame
		!ret
	]]})

	-- Returns the memory address of the given userdata object.

	-- SIGNATURE:
	-- number result = IEex_ReadUserdata(userdata value)
	IEex_WriteAssemblyFunction("IEex_ReadUserdata", {
		"55 8B EC 53 51 52 56 57 6A 01 FF 75 08 \z
		!call >_lua_touserdata \z
		83 C4 08 50 DB 04 24 83 EC 04 DD 1C 24 FF 75 08 \z
		!call >_lua_pushnumber \z
		83 C4 0C B8 01 00 00 00 5F 5E 5A 59 5B 5D C3"
	})

	-- Returns a lightuserdata object that points to the given address.

	-- SIGNATURE:
	-- userdata result = IEex_ToLightUserdata(number address)
	IEex_WriteAssemblyFunction("IEex_ToLightUserdata", {
		"55 8B EC 53 51 52 56 57 6A 00 6A 01 FF 75 08 \z
		!call >_lua_tonumberx \z
		83 C4 0C \z
		!call >__ftol2_sse \z
		50 FF 75 08 \z
		!call >_lua_pushlightuserdata \z
		83 C4 08 B8 01 00 00 00 5F 5E 5A 59 5B 5D C3"
	})

end)()
