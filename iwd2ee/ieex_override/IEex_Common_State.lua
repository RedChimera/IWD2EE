
-------------
-- Options --
-------------

IEex_MinimalStartup = false
IEex_InitialMemory = nil

IEex_OnceTable = {}
IEex_GlobalAssemblyLabels = {}
IEex_GlobalAssemblyMacros = {}
IEex_CodePageAllocations = {}

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
	return bit.extract(IEex_ReadDword(address), index * 0x8, 0x8)
end

-- Reads a dword from the given address, extracting and returning the "index"th signed byte.
function IEex_ReadSignedByte(address, index)
	local readValue = bit.extract(IEex_ReadDword(address), index * 0x8, 0x8)
	-- TODO: Implement better conversion code.
	if readValue >= 128 then
		return -256 + readValue
	else
		return readValue
	end
end

function IEex_ReadWord(address, index)
	return bit.extract(IEex_ReadDword(address), index * 0x10, 0x10)
end

-- Reads a signed 2-byte word at the given address, shifted over by 2*index bytes.
function IEex_ReadSignedWord(address, index)
	local readValue = bit.extract(IEex_ReadDword(address), index * 0x10, 0x10)
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
		IEex_WriteByte(address + i, bit.extract(value, i * 0x8, 0x8))
	end
end

function IEex_WriteDword(address, value)
	for i = 0, 3, 1 do
		IEex_WriteByte(address + i, bit.extract(value, i * 0x8, 0x8))
	end
end

function IEex_WriteStringAuto(string)
	local address = IEex_Malloc(#string + 1)
	IEex_WriteString(address, string)
	return address
end

-- OS:WINDOWS
function IEex_GetProcAddress(dll, proc)
	local procaddress = #dll + 1
	local dlladdress = IEex_Malloc(procaddress + #proc + 1)
	procaddress = dlladdress + procaddress
	IEex_WriteString(dlladdress, dll)
	IEex_WriteString(procaddress, proc)
	local dllhandle = IEex_Call(IEex_Label("__imp__LoadLibraryA"), {dlladdress}, nil, 0x0)
	local procfunc = IEex_Call(IEex_Label("__imp__GetProcAddress"), {procaddress, dllhandle}, nil, 0x0)
	IEex_Free(dlladdress)
	return procfunc
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
	error(debug.traceback(message))
end

function IEex_TracebackPrint(message, levelMod)
	print(debug.traceback("["..IEex_GetMilliseconds().."] "..message, 2 + (levelMod or 0)))
end

function IEex_TracebackMessage(message, levelMod)
	local message = debug.traceback("["..IEex_GetMilliseconds().."] "..message, 2 + (levelMod or 0))
	print(message)
	IEex_MessageBox(message)
end

function IEex_DumpLuaStack()
	IEex_FunctionLog("Lua Stack =>")
	local lua_State = IEex_Label("_g_lua")
	local top = IEex_Call(IEex_Label("_lua_gettop"), {lua_State}, nil, 0x4)
	for i = 1, top, 1 do
		local t = IEex_Call(IEex_Label("_lua_type"), {i, lua_State}, nil, 0x8)
		if t == 0 then
			IEex_FunctionLog("    nil")
		elseif t == 1 then
			local boolean = IEex_Call(IEex_Label("_lua_toboolean"), {i, lua_State}, nil, 0x8)
			IEex_FunctionLog("    boolean: "..boolean)
		elseif t == 3 then
			local number = IEex_Call(IEex_Label("_lua_tonumber"), {i, lua_State}, nil, 0x8)
			IEex_FunctionLog("    number: "..IEex_ToHex(number))
		elseif t == 4 then
			local string = IEex_Call(IEex_Label("_lua_tolstring"), {0x0, i, lua_State}, nil, 0x8)
			IEex_FunctionLog("    string: "..IEex_ReadString(string))
		else
			local typeName = IEex_Call(IEex_Label("_lua_typename"), {i, lua_State}, nil, 0x8)
			IEex_FunctionLog("    type: "..t..", typeName: "..IEex_ReadString(typeName))
		end
	end
end

function IEex_DumpDynamicCode()
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
							local byte = bit.extract(currentDword, k * 8, 8)
							byteDump = byteDump..IEex_ToHex(byte, 2, true).." "
						end
					end
				end
				IEex_FunctionLog(byteDump)
			end
		end
	end
end

-- OS:WINDOWS
function IEex_MessageBox(message, iconOverride)
	local caption = "IEex"
	local messageAddress = IEex_Malloc(#message + 1 + #caption + 1)
	local captionAddress = messageAddress + #message + 1
	IEex_WriteString(messageAddress, message)
	IEex_WriteString(captionAddress, caption)
	IEex_DllCall("User32", "MessageBoxA", {IEex_Flags({iconOverride or 0x40}), captionAddress, messageAddress, 0x0}, nil, 0x0)
	IEex_Free(messageAddress)
end

--------------------
-- Random Utility --
--------------------

function IEex_Once(key, func)
	if not IEex_OnceTable[key] then
		IEex_OnceTable[key] = true
		func()
	end
end

function IEex_Default(defaultVal, val)
	return val ~= nil and val or defaultVal
end

function IEex_IterateCPtrList(CPtrList, func)
	local m_pNext = IEex_ReadDword(CPtrList + 0x4)
	while m_pNext ~= 0x0 do
		if IEex_ReadDword(m_pNext + 0x8) > 0 and func(IEex_ReadDword(m_pNext + 0x8)) then
			break
		end
		m_pNext = IEex_ReadDword(m_pNext)
	end
end

function IEex_FlattenTable(table)
	local toReturn = {}
	local insertionIndex = 1
	for i = 1, #table do
		local element = table[i]
		if type(element) == "table" then
			for j = 1, #element do
				toReturn[insertionIndex] = element[j]
				insertionIndex = insertionIndex + 1
			end
		else
			toReturn[insertionIndex] = element
			insertionIndex = insertionIndex + 1
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

function IEex_Split(text, splitBy, usePattern, allowEmptyCapture)
	
	local toReturn = {}
	local matchedPatterns = {}

	local plain = usePattern == nil or not usePattern
	local insertionIndex = 1
	local captureStart = 1
	local foundStart, foundEnd = text:find(splitBy, 1, plain)

	while foundStart do
		if allowEmptyCapture or (foundStart > captureStart) then
			toReturn[insertionIndex] = text:sub(captureStart, foundStart - 1)
			matchedPatterns[insertionIndex] = text:sub(foundStart, foundEnd)
			insertionIndex = insertionIndex + 1
		end
		captureStart = foundEnd + 1
		foundStart, foundEnd = text:find(splitBy, captureStart, plain)
	end

	local limit = #text
	if captureStart <= limit then
		toReturn[insertionIndex] = text:sub(captureStart, limit)
	end

	return toReturn, matchedPatterns
end

function IEex_SplitByWhitespaceProcess(text, func)

	text = text:gsub("%s+", " ")
	local limit = #text
	local captureStart = (limit > 0 and text:sub(1, 1) == " ") and 2 or 1

	for i = captureStart + 1, limit do
		if text:sub(i, i) == " " then
			func(text:sub(captureStart, i - 1))
			captureStart = i + 1
		end
	end

	if captureStart <= limit then
		func(text:sub(captureStart, limit))
	end
end

function IEex_ExpandToBytes(num, length)
	local toReturn = {}
	for i = 1, length do
		toReturn[i] = bit.band(num, 0xFF)
		num = bit.rshift(num, 8)
	end
	return unpack(toReturn)
end

function IEex_ProcessNumberAsBytes(num, length, func)
	for i = 1, length do
		func(bit.band(num, 0xFF), i)
		num = bit.rshift(num, 8)
	end
end

---------------
-- IEex_Dump --
---------------

function IEex_AlphanumericSortEntries(o)
	local function conv(s)
		local res, dot = "", ""
		for n, m, c in tostring(s):gmatch"(0*(%d*))(.?)" do
			if n == "" then
				dot, c = "", dot..c
			else
				res = res..(dot == "" and ("%03d%s"):format(#m, m) or "."..n)
				dot, c = c:match"(%.?)(.*)"
			end
			res = res..c:gsub(".", "\0%0")
		end
		return res
	end
	table.sort(o,
		function (a, b)
			local ca, cb = conv(a.string), conv(b.string)
			return ca < cb or ca == cb and a.string < b.string
		end)
	return o
end

function IEex_FillDumpLevel(tableName, levelTable, levelToFill, levelTableKey)
	local tableKey, tableValue = next(levelTable, levelTableKey)
	while tableValue ~= nil do
		local tableValueType = type(tableValue)
		if tableValueType == 'string' or tableValueType == 'number' or tableValueType == 'boolean' then
			local entry = {}
			entry.string = tableValueType..' '..tableKey..' = '
			entry.value = tableValue
			table.insert(levelToFill, entry)
		elseif tableValueType == 'table' then
			if tableKey ~= '_G' then
				local entry = {}
				entry.string = tableValueType..' '..tableKey..':'
				entry.value = {} --entry.value is a levelToFill
				entry.value.previous = {}
				entry.value.previous.tableName = tableName
				entry.value.previous.levelTable = levelTable
				entry.value.previous.levelToFill = levelToFill
				entry.value.previous.levelTableKey = tableKey
				table.insert(levelToFill, entry)
				return IEex_FillDumpLevel(tableKey, tableValue, entry.value)
			end
		elseif tableValueType == 'userdata' then
			local metatable = getmetatable(tableValue)
			local entry = {}
			if metatable ~= nil then
				entry.string = tableValueType..' '..tableKey..':\n'
				entry.value = {} --entry.value is a levelToFill
				entry.value.previous = {}
				entry.value.previous.tableName = tableName
				entry.value.previous.levelTable = levelTable
				entry.value.previous.levelToFill = levelToFill
				entry.value.previous.levelTableKey = tableKey
				table.insert(levelToFill, entry)
				return IEex_FillDumpLevel(tableKey, metatable, entry.value)
			else
				entry.string = tableValueType..' '..tableKey..' = '
				entry.value = 'nil'
				table.insert(levelToFill, entry)
			end
		else
			local entry = {}
			entry.string = tableValueType..' '..tableKey
			entry.value = nil
			table.insert(levelToFill, entry)
		end
		--Iteration
		tableKey, tableValue = next(levelTable, tableKey)
		--Iteration
	end
	--Sort the now finished level
	IEex_AlphanumericSortEntries(levelToFill)
	--Sort the now finished level
	local previous = levelToFill.previous
	if previous ~= nil then
		--Clear out "previous" metadata, as it is no longer needed.
		local previousTableName = previous.tableName
		local previousLevelTable = previous.levelTable
		local previousLevelToFill = previous.levelToFill
		local previousLevelTableKey = previous.levelTableKey
		levelToFill.previous = nil
		--Clear out "previous" metadata, as it is no longer needed.
		return IEex_FillDumpLevel(previousTableName, previousLevelTable,
								  previousLevelToFill, previousLevelTableKey)
	else
		return levelToFill
	end
end

IEex_DumpFunction = print

function IEex_PrintEntries(entriesTable, indentLevel, indentStrings, previousState, levelTableKey)
	local tableEntryKey, tableEntry = next(entriesTable, levelTableKey)
	while(tableEntry ~= nil) do
		local tableEntryString = tableEntry.string
		local tableEntryValue = tableEntry.value
		local indentString = indentStrings[indentLevel]
		if tableEntryValue ~= nil then
			if type(tableEntryValue) ~= 'table' then
				local valueToPrint = string.gsub(tostring(tableEntryValue), '\n', '\\n')
				IEex_DumpFunction(indentString..tableEntryString..valueToPrint)
			else
				IEex_DumpFunction(indentString..tableEntryString)
				IEex_DumpFunction(indentString..'{')
				local previous = {}
				previous.entriesTable = entriesTable
				previous.indentLevel = indentLevel
				previous.levelTableKey = tableEntryKey
				previous.previousState = previousState
				indentLevel = indentLevel + 1
				local indentStringsSize = #indentStrings
				if indentLevel > indentStringsSize then
					indentStrings[indentStringsSize + 1] = indentStrings[indentStringsSize]..'	'
				end
				return IEex_PrintEntries(tableEntryValue, indentLevel, indentStrings, previous)
			end
		else
			IEex_DumpFunction(indentString..tableEntryString)
		end
		--Increment
		tableEntryKey, tableEntry = next(entriesTable, tableEntryKey)
		--Increment
	end
	IEex_DumpFunction(indentStrings[indentLevel - 1]..'}')
	--Finish previous levels
	if previousState ~= nil then
		return IEex_PrintEntries(previousState.entriesTable, previousState.indentLevel, indentStrings,
								 previousState.previousState, previousState.levelTableKey)
	end
end

function IEex_Dump(key, valueToDump)
	local valueToDumpType = type(valueToDump)
	if valueToDumpType == 'string' or valueToDumpType == 'number' or valueToDumpType == 'boolean' then
		IEex_DumpFunction(valueToDumpType..' '..key..' = '..tostring(valueToDump))
	elseif valueToDumpType == 'table' then
		IEex_DumpFunction(valueToDumpType..' '..key..':')
		IEex_DumpFunction('{')
		local entries = IEex_FillDumpLevel(key, valueToDump, {})
		IEex_PrintEntries(entries, 1, {[0] = '', [1] = '	'})
	elseif valueToDumpType == 'userdata' then
		local metatable = getmetatable(valueToDump)
		if metatable ~= nil then
			IEex_DumpFunction(valueToDumpType..' '..key..':')
			IEex_DumpFunction('{')
			local entries = IEex_FillDumpLevel(key, metatable, {})
			IEex_PrintEntries(entries, 1, {[0] = '', [1] = '	'})
		else
			IEex_DumpFunction(valueToDumpType..' '..key..' = nil')
		end
	else
		IEex_DumpFunction(valueToDumpType..' '..key)
	end
end

----------------------
-- Assembly Writing --
----------------------

function IEex_DefineAssemblyLabel(label, value)
	IEex_GlobalAssemblyLabels[label] = value
end

function IEex_LabelDefault(label, default)
	return IEex_GlobalAssemblyLabels[label] or default
end

function IEex_Label(label)
	local value = IEex_GlobalAssemblyLabels[label]
	if not value then
		IEex_Error("Label @"..label.." is not defined in the global scope!")
	end
	return IEex_GlobalAssemblyLabels[label]
end

function IEex_DefineAssemblyMacro(macroName, macroValue)
	IEex_GlobalAssemblyMacros[macroName] = macroValue
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

function IEex_WriteAssembly(address, assembly)
	IEex_WriteSanitizedAssembly(address, IEex_SanitizeAssembly(assembly))
end

function IEex_CollectSanitizedMacroName(section, hasPrefix)
	local macroArgsStart = section:find("(", 1, true)
	local macroName = section:sub(hasPrefix and 2 or 1, macroArgsStart - 1)
	return macroName, macroArgsStart
end

function IEex_CollectSanitizedMacroArgs(section, macroArgsStart)
	macroArgsStart = macroArgsStart or section:find("(", 1, true)
	local macroArgsEnd = section:find(")", 1, true)
	return IEex_Split(section:sub(macroArgsStart + 1, macroArgsEnd - 1), ",")
end

function IEex_GetSanitizedMacroLength(state, address, section)
	local macroName, macroArgsStart = IEex_CollectSanitizedMacroName(section, false)
	local lengthVal = IEex_GlobalAssemblyMacros[macroName].length
	local lengthType = type(lengthVal)
	if lengthType == "function" then
		local args = IEex_CollectSanitizedMacroArgs(section, macroArgsStart)
		return lengthVal(state, address, args)
	elseif lengthType == "number" then
		return lengthVal
	else
		return 0
	end
end

function IEex_SanitizeAssembly(assembly)

	local state = {
		["sanitizedStructure"] = {},
		["seenLabelAddresses"] = {},
		["firstUnexploredSection"] = {
			["address"] = 0,
			["index"] = 0,
			["inComment"] = false,
		},
		["unroll"] = {},
		["write"] = {},
	}

	local sanitizedStructure = state.sanitizedStructure

	-- For some reason unrollTextArg has to be split up so it can see itself
	local unrollTextArg
	unrollTextArg = function(arg)

		IEex_SplitByWhitespaceProcess(arg, function(section)

			if section:sub(1, 1) == "!" then

				local macroName = section:sub(2)
				local macroArgsStart = section:find("(", 1, true)
				if macroArgsStart then macroName = section:sub(2, macroArgsStart - 1) end

				local macro = IEex_GlobalAssemblyMacros[macroName]
				if not macro then
					IEex_Error("Macro \""..macroName.."\" not defined in the current scope!")
				end

				local macroType = type(macro)
				if macroType == "string" then
					-- Return is for tail call, not for returning a value
					return unrollTextArg(macro)
				elseif macroType == "table" then

					local addMacroTextToStructure = true
					local unrollFunc = macro.unroll

					if unrollFunc then

						local macroArgsEnd = section:find(")", 1, true)
						if not macroArgsEnd then
							IEex_Error("No closing parentheses for macro function \""..macroName.."\"!")
						end

						if macroArgsEnd ~= #section then
							IEex_Error("Invalid closing parentheses for macro function \""..macroName.."\"!")
						end

						local args = IEex_Split(section:sub(macroArgsStart + 1, macroArgsEnd - 1), ",")
						local unrollResult = unrollFunc(state, args)
						
						if unrollResult then
							
							addMacroTextToStructure = false
							local unrollResultType = type(unrollResult)

							if unrollResultType == "string" then
								return unrollTextArg(unrollResult)
							elseif unrollResultType == "table" then
								for _, val in ipairs(unrollResult) do
									local valType = type(val)
									if valType == "string" then
										return unrollTextArg(val)
									elseif valType == "table" then
										table.insert(sanitizedStructure, val)
									else
										IEex_Error("Invalid macro return type \""..valType.."\" for macro \""..macroName.."\"!")
									end
								end
							else
								IEex_Error("Invalid macro return type \""..macroType.."\" for macro \""..macroName.."\"!")
							end
						end
					end

					if addMacroTextToStructure then
						local lengthType = type(macro.length)
						if lengthType ~= "function" and lengthType ~= "number" and lengthType ~= "nil" then
							IEex_Error("Invalid macro length type \""..lengthType.."\" for macro \""..macroName.."\"!")
						end
						table.insert(sanitizedStructure, section)
					end
				else
					IEex_Error("Invalid macro type \""..macroType.."\" for macro \""..macroName.."\"!")
				end
			else
				table.insert(sanitizedStructure, section)
			end
		end)
	end

	for _, arg in ipairs(assembly) do
		local argType = type(arg)
		if argType == "string" then
			unrollTextArg(arg)
		elseif argType == "table" then
			local argSize = #arg
			if argSize == 2 or argSize == 3 then
				local relativeFromOffset = arg[3]
				if type(arg[1]) == "number" and type(arg[2]) == "number"
					and (not relativeFromOffset or type(relativeFromOffset) == "number")
				then
					table.insert(sanitizedStructure, arg)
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

	return state
end

function IEex_WriteSanitizedAssembly(address, state, funcOverride)

	if not funcOverride then

		-- Print a hex-dump of what is about to be written to the log
		local writeDump = ""
		IEex_WriteSanitizedAssembly(address, state, function(writeAddress, ...)
			local bytes = {...}
			for i = 1, #bytes do
				writeDump = writeDump..IEex_ToHex(bytes[i], 2, true).." "
			end
		end)
		IEex_FunctionLog("\n\nWriting Assembly at "..IEex_ToHex(address).." => "..writeDump.."\n")

		funcOverride = function(writeAddress, ...)
			local bytes = {...}
			for i = 1, #bytes do
				IEex_WriteByte(writeAddress, bytes[i])
				writeAddress = writeAddress + 1
			end
		end
	end

	local firstUnexploredSection = state.firstUnexploredSection
	local currentWriteAddress = address
	local inComment = false

	local prefixProcessing = {
		["!"] = function(section)
			local macroName, macroArgsStart = IEex_CollectSanitizedMacroName(section, false)
			local writeVal = IEex_GlobalAssemblyMacros[macroName].write
			if type(writeVal) == "function" then
				local args = IEex_CollectSanitizedMacroArgs(section, macroArgsStart)
				currentWriteAddress = currentWriteAddress + writeVal(state, currentWriteAddress, args, funcOverride)
			end
		end,
		[":"] = function(section)
			local targetOffset = tonumber(section, 16)
			local relativeOffsetNeeded = targetOffset - (currentWriteAddress + 4)
			for i = 0, 3, 1 do
				local byte = bit.extract(relativeOffsetNeeded, i * 8, 8)
				funcOverride(currentWriteAddress, byte)
				currentWriteAddress = currentWriteAddress + 1
			end
		end,
		["+"] = function(section)
			local targetOffset = currentWriteAddress + 4 + tonumber(section, 16)
			for i = 0, 3, 1 do
				local byte = bit.extract(targetOffset, i * 8, 8)
				funcOverride(currentWriteAddress, byte)
				currentWriteAddress = currentWriteAddress + 1
			end
		end,
		["#"] = function(section)
			local toWrite = tonumber(section, 16)
			for i = 0, 3, 1 do
				local byte = bit.extract(toWrite, i * 8, 8)
				funcOverride(currentWriteAddress, byte)
				currentWriteAddress = currentWriteAddress + 1
			end
		end,
		["*"] = function(label)
			local targetOffset = IEex_CalcLabelAddress(state, label)
			if not targetOffset then
				targetOffset = IEex_GlobalAssemblyLabels[label]
				if not targetOffset then
					IEex_Error("Label @"..label.." is not defined in current scope!")
				end
			end
			for i = 0, 3, 1 do
				local byte = bit.extract(targetOffset, i * 8, 8)
				funcOverride(currentWriteAddress, byte)
				currentWriteAddress = currentWriteAddress + 1
			end
		end,
		[">"] = function(label)
			local targetOffset = IEex_CalcLabelAddress(state, label)
			if not targetOffset then
				targetOffset = IEex_GlobalAssemblyLabels[label]
				if not targetOffset then
					IEex_Error("Label @"..label.." is not defined in current scope!")
				end
			end
			local relativeOffsetNeeded = targetOffset - (currentWriteAddress + 4)
			for i = 0, 3, 1 do
				local byte = bit.extract(relativeOffsetNeeded, i * 8, 8)
				funcOverride(currentWriteAddress, byte)
				currentWriteAddress = currentWriteAddress + 1
			end
		end,
		["$"] = function(label)
			IEex_DefineAssemblyLabel(label, currentWriteAddress)
			state.seenLabelAddresses[label] = currentWriteAddress
		end,
		["@"] = function(label)
			state.seenLabelAddresses[label] = currentWriteAddress
		end,
	}

	-----------------------
	-- Process Structure --
	-----------------------

	local sanitizedStructure = state.sanitizedStructure

	-- Structure is sanitized so I can make assumptions
	for i = 1, #sanitizedStructure do

		local arg = sanitizedStructure[i]
		if type(arg) == "string" then
			local prefix = string.sub(arg, 1, 1)
			if prefix == ";" then
				inComment = not inComment
			elseif not inComment then
				local prefixFunc = prefixProcessing[prefix]
				if prefixFunc then
					prefixFunc(arg:sub(2))
				else
					local byte = tonumber(arg, 16)
					funcOverride(currentWriteAddress, byte)
					currentWriteAddress = currentWriteAddress + 1
				end
			end
		else
			local address = arg[1]
			local relativeFromOffset = arg[3]
			if relativeFromOffset then address = address - currentWriteAddress - relativeFromOffset end
			for i = 0, arg[2] - 1 do
				local byte = bit.extract(address, i * 8, 8)
				funcOverride(currentWriteAddress, byte)
				currentWriteAddress = currentWriteAddress + 1
			end
		end

		if i > firstUnexploredSection.index then
			firstUnexploredSection.address = currentWriteAddress
			firstUnexploredSection.index = i + 1
			firstUnexploredSection.inComment = inComment
		end

	end
end

function IEex_InvalidateAssemblyState(state)
	state.seenLabelAddresses = {}
	state.firstUnexploredSection.address = 0
	state.firstUnexploredSection.index = 0
	state.firstUnexploredSection.inComment = false
end

function IEex_CalcWriteLength(state, address)

	local firstUnexploredSection = state.firstUnexploredSection
	local curAddress = address
	local inComment = false

	local prefixProcessing = {
		["!"] = function(section)
			curAddress = curAddress + IEex_GetSanitizedMacroLength(state, address, section)
		end,
		[":"] = function(section)
			curAddress = curAddress + 4
		end,
		["+"] = function(section)
			curAddress = curAddress + 4
		end,
		["#"] = function(section)
			curAddress = curAddress + 4
		end,
		["*"] = function(label)
			curAddress = curAddress + 4
		end,
		[">"] = function(label)
			curAddress = curAddress + 4
		end,
		["$"] = function(label)
			state.seenLabelAddresses[label] = curAddress
		end,
		["@"] = function(label)
			state.seenLabelAddresses[label] = curAddress
		end,
	}

	-----------------------
	-- Process Structure --
	-----------------------

	local sanitizedStructure = state.sanitizedStructure

	for i = 1, #sanitizedStructure do

		local arg = sanitizedStructure[i]
		if type(arg) == "string" then
			local prefix = string.sub(arg, 1, 1)
			if prefix == ";" then
				inComment = not inComment
			elseif not inComment then
				local prefixFunc = prefixProcessing[prefix]
				if prefixFunc then
					prefixFunc(arg:sub(2))
				else
					curAddress = curAddress + 1
				end
			end
		else
			curAddress = curAddress + arg[2]
		end

		if i > firstUnexploredSection.index then
			firstUnexploredSection.address = curAddress
			firstUnexploredSection.index = i + 1
			firstUnexploredSection.inComment = inComment
		end

	end

	return curAddress - address
end

function IEex_CalcLabelAddress(state, toFind)

	local knownAddress = state.seenLabelAddresses[toFind]
	if knownAddress then return knownAddress end

	local firstUnexploredSection = state.firstUnexploredSection
	local curAddress = firstUnexploredSection.address
	local inComment = state.firstUnexploredSection.inComment

	local prefixProcessing = {
		["!"] = function(section)
			curAddress = curAddress + IEex_GetSanitizedMacroLength(state, address, section)
		end,
		[":"] = function(section)
			curAddress = curAddress + 4
		end,
		["+"] = function(section)
			curAddress = curAddress + 4
		end,
		["#"] = function(section)
			curAddress = curAddress + 4
		end,
		["*"] = function(label)
			curAddress = curAddress + 4
		end,
		[">"] = function(label)
			curAddress = curAddress + 4
		end,
		["$"] = function(label)
			state.seenLabelAddresses[label] = curAddress
			return label == toFind
		end,
		["@"] = function(label)
			state.seenLabelAddresses[label] = curAddress
			return label == toFind
		end,
	}

	-----------------------
	-- Process Structure --
	-----------------------

	local sanitizedStructure = state.sanitizedStructure

	for i = firstUnexploredSection.index, #sanitizedStructure do

		local found = false

		local arg = sanitizedStructure[i]
		if type(arg) == "string" then
			local prefix = string.sub(arg, 1, 1)
			if prefix == ";" then
				inComment = not inComment
			elseif not inComment then
				local prefixFunc = prefixProcessing[prefix]
				if prefixFunc then
					found = prefixFunc(arg:sub(2))
				else
					curAddress = curAddress + 1
				end
			end
		else
			curAddress = curAddress + arg[2]
		end

		if i > firstUnexploredSection.index then
			firstUnexploredSection.address = curAddress
			firstUnexploredSection.index = i + 1
			firstUnexploredSection.inComment = inComment
		end

		if found then return curAddress end
		
	end
end

-- NOTE: Same as IEex_WriteAssembly(), but writes to a dynamically
-- allocated memory space instead of a provided address.
-- Very useful for writing new executable code into memory.
function IEex_WriteAssemblyAuto(assembly)
	local state = IEex_SanitizeAssembly(assembly)
	local reservedAddress, reservedLength = IEex_ReserveCodeMemory(state)
	IEex_FunctionLog("Reserved "..IEex_ToHex(reservedLength).." bytes at "..IEex_ToHex(reservedAddress))
	IEex_WriteSanitizedAssembly(reservedAddress, state)
	return reservedAddress
end

function IEex_WriteAssemblyFunction(functionName, assembly)
	local functionAddress = IEex_WriteAssemblyAuto(assembly)
	IEex_ExposeToLua(functionAddress, functionName)
	return functionAddress
end

function IEex_HookBeforeCall(address, assembly)
	local returnAddress = address + 0x5
	IEex_DefineAssemblyLabel("return", returnAddress)
	IEex_WriteAssembly(address, {"!jmp_dword", {IEex_WriteAssemblyAuto(
		IEex_FlattenTable({
			assembly,
			{[[
				@call
				!call ]], {address + IEex_ReadDword(address + 0x1) + 0x5, 4, 4}, [[
				!jmp_dword ]], {returnAddress, 4, 4},
			},
		})
	), 4, 4}})
end

function IEex_HookAfterCall(address, assembly)
	IEex_WriteAssembly(address, {"!jmp_dword", {IEex_WriteAssemblyAuto(
		IEex_FlattenTable({
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

function IEex_HookReturnNOPs(address, nopCount, assembly)

	local afterInstruction = address + 0x5 + nopCount
	IEex_DefineAssemblyLabel("return", afterInstruction)

	local hookCode = IEex_WriteAssemblyAuto(IEex_FlattenTable({
		assembly,
		{
			"!jmp_dword", {afterInstruction, 4, 4},
		},
	}))

	local nops = {}
	local limit = nopCount
	for i = 1, limit, 1 do
		table.insert(nops, {0x90, 1})
	end

	IEex_WriteAssembly(address, IEex_FlattenTable({
		{
			"!jmp_dword", {hookCode, 4, 4}
		},
		nops,
	}))
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

	IEex_DefineAssemblyLabel("return_skip", afterInstruction)

	local hookCode = IEex_WriteAssemblyAuto(IEex_FlattenTable({
		assembly,
		"@return",
		restoreBytes,
		{[[
			!jmp_dword ]], {afterInstruction, 4, 4},
		},
	}))

	IEex_WriteAssembly(address, IEex_FlattenTable({
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

	local hookCode = IEex_WriteAssemblyAuto(IEex_FlattenTable({
		restoreBytes,
		assembly,
		"@return",
		{[[
			!jmp_dword ]], {afterInstruction, 4, 4},
		},
	}))

	IEex_WriteAssembly(address, IEex_FlattenTable({
		{
			"!jmp_dword", {hookCode, 4, 4}
		},
		nops,
	}))
end

function IEex_HookJump(address, restoreSize, assembly)

	local storeBytes = function(startAddress, size)
		local bytes = {}
		local limit = startAddress + size - 1
		for i = startAddress, limit, 1 do
			table.insert(bytes, {IEex_ReadByte(i, 0), 1})
		end
		return bytes
	end

	local byteToDwordJmp = {
		[0x70] = {{0x0F, 1}, {0x80, 1}},
		[0x71] = {{0x0F, 1}, {0x81, 1}},
		[0x72] = {{0x0F, 1}, {0x82, 1}},
		[0x73] = {{0x0F, 1}, {0x83, 1}},
		[0x74] = {{0x0F, 1}, {0x84, 1}},
		[0x75] = {{0x0F, 1}, {0x85, 1}},
		[0x76] = {{0x0F, 1}, {0x86, 1}},
		[0x77] = {{0x0F, 1}, {0x87, 1}},
		[0x78] = {{0x0F, 1}, {0x88, 1}},
		[0x79] = {{0x0F, 1}, {0x89, 1}},
		[0x7A] = {{0x0F, 1}, {0x8A, 1}},
		[0x7B] = {{0x0F, 1}, {0x8B, 1}},
		[0x7C] = {{0x0F, 1}, {0x8C, 1}},
		[0x7D] = {{0x0F, 1}, {0x8D, 1}},
		[0x7E] = {{0x0F, 1}, {0x8E, 1}},
		[0x7F] = {{0x0F, 1}, {0x8F, 1}},
		[0xEB] = {{0xE9, 1}},
	}

	local instructionByte = IEex_ReadByte(address, 0)
	local instructionBytes = {}
	local instructionSize = nil
	local offset = nil

	local switchBytes = byteToDwordJmp[instructionByte]
	if switchBytes then
		instructionBytes = switchBytes
		instructionSize = 2
		offset = IEex_ReadByte(address + 1, 0)
	elseif instructionByte == 0xE9 then
		instructionBytes = {{instructionByte, 1}}
		instructionSize = 5
		offset = IEex_ReadDword(address + 1)
	else
		instructionBytes = {{instructionByte, 1}, {IEex_ReadByte(address + 1, 0), 1}}
		instructionSize = 6
		offset = IEex_ReadDword(address + 2)
	end

	local afterInstruction = address + instructionSize
	local jmpFailDest = afterInstruction + restoreSize
	local restoreBytes = storeBytes(afterInstruction, restoreSize)
	local jmpDest = afterInstruction + offset

	IEex_DefineAssemblyLabel("jmp_success", jmpDest)

	local hookCode = IEex_WriteAssemblyAuto(IEex_FlattenTable({
		assembly,
		"@jmp",
		instructionBytes,
		{
			{jmpDest, 4, 4},
		},
		"@jmp_fail",
		restoreBytes,
		{[[
			!jmp_dword ]], {jmpFailDest, 4, 4},
		},
	}))

	IEex_WriteAssembly(address, {"!jmp_dword", {hookCode, 4, 4}})
end

function IEex_HookJumpNoReturn(address, assembly)
	IEex_WriteAssembly(address, {"!jmp_dword", {IEex_WriteAssemblyAuto(assembly), 4, 4}})
end

function IEex_HookChangeCallDest(address, dest)
	IEex_WriteAssembly(address + 0x1, {{dest, 4, 4}})
end

IEex_LuaCallReturnType = {
	["Boolean"] = 0,
	["Number"] = 1,
}

function IEex_GenLuaCall(funcName, meta)

	local pushNumberTemplate = {[[
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_ebx
		!call >_lua_pushnumber
		!add_esp_byte 0C
	]]}

	local returnBooleanTemplate = {[[
		!push_byte FF
		!push_ebx
		!call >_lua_toboolean
		!add_esp_byte 08
		!push_eax
		!push_byte FE
		!push_ebx
		!call >_lua_settop
		!add_esp_byte 08
		!pop_eax
	]]}

	local returnNumberTemplate = {[[
		!push_byte FF
		!push_ebx
		!call >_lua_tonumber
		!add_esp_byte 08
		!call >__ftol2_sse
		!push_eax
		!push_byte FE
		!push_ebx
		!call >_lua_settop
		!add_esp_byte 08
		!pop_eax
	]]}

	local numRet = ((meta or {}).returnType) and 1 or 0
	local numArgs = #((meta or {}).args or {})

	local genArgPushes1 = function()

		local toReturn = {}
		local insertionIndex = 1

		if not meta then return toReturn end
		local args = meta.args
		if not args then return toReturn end

		for i = numArgs, 1, -1 do
			toReturn[insertionIndex] = args[i]
			insertionIndex = insertionIndex + 1
		end

		return IEex_FlattenTable(toReturn)
	end

	local genArgPushes2 = function()

		local toReturn = {}
		local insertionIndex = 1

		if not meta then return toReturn end
		local args = meta.args
		if not args then return toReturn end

		for i = 1, numArgs do
			toReturn[insertionIndex] = pushNumberTemplate
			insertionIndex = insertionIndex + 1
		end

		return IEex_FlattenTable(toReturn)
	end

	local genReturnHandling = function()

		if not meta then return {} end
		local returnType = meta.returnType
		if not returnType then return {} end

		if returnType == IEex_LuaCallReturnType.Boolean then
			return returnBooleanTemplate
		elseif returnType == IEex_LuaCallReturnType.Number then
			return returnNumberTemplate
		else
			IEex_Error("Invalid")
		end
	end

	return IEex_FlattenTable({
		genArgPushes1(),
		{[[
			!call >IEex_GetLuaState
			!mov_ebx_eax

			!push_dword ]], {IEex_WriteStringAuto(funcName), 4}, [[
			!push_ebx
			!call >_lua_getglobal
			!add_esp_byte 08
		]]},
		genArgPushes2(),
		{[[
			!push_byte 00
			!push_byte ]], {numRet, 1}, [[
			!push_byte ]], {numArgs, 1}, [[
			!push_ebx
			!call >_lua_pcall
			!add_esp_byte 10
			!push_ebx
			!call >IEex_CheckCallError
			!test_eax_eax
			!jnz_dword >call_error
		]]},
		genReturnHandling(),
	})
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
		result = bit.bor(result, flag)
	end
	return result
end

-- LuaJIT doesn't include this :(
function bit.extract(num, start, len)
	local mask = 0x0
	for i = 1, len, 1 do
		mask = bit.lshift(mask, 1)
		mask = bit.bor(mask, 1)
	end
	return bit.band(bit.rshift(num, start), mask)
end

function IEex_IsBitSet(original, isSetIndex)
	return bit.band(original, bit.lshift(0x1, isSetIndex)) ~= 0x0
end

function IEex_AreBitsSet(original, bitsString)
	return IEex_IsMaskSet(original, tonumber(bitsString, 2))
end

function IEex_IsMaskSet(original, isSetMask)
	return bit.band(original, isSetMask) == isSetMask
end

function IEex_IsBitUnset(original, isUnsetIndex)
	return bit.band(original, bit.lshift(0x1, isUnsetIndex)) == 0x0
end

function IEex_AreBitsUnset(original, bitsString)
	return IEex_IsMaskUnset(original, tonumber(bitsString, 2))
end

function IEex_IsMaskUnset(original, isUnsetMask)
	return bit.band(original, isUnsetMask) == 0x0
end

function IEex_SetBit(original, toSetIndex)
	return bit.bor(original, bit.lshift(0x1, toSetIndex))
end

function IEex_SetBits(original, bitsString)
	return IEex_SetMask(original, tonumber(bitsString, 2))
end

function IEex_SetMask(original, toSetMask)
	return bit.bor(original, toSetMask)
end

function IEex_UnsetBit(original, toUnsetIndex)
	return bit.band(original, bit.bnot(bit.lshift(0x1, toUnsetIndex)))
end

function IEex_UnsetBits(original, bitsString)
	return IEex_UnsetMask(original, tonumber(bitsString, 2))
end

function IEex_UnsetMask(original, toUnsetmask)
	return bit.band(original, bit.bnot(toUnsetmask))
end

function IEex_ToHex(number, minLength, suppressPrefix)
	if type(number) ~= "number" then
		-- This is usually a critical error somewhere else
		-- in the code, so throw a fully fledged error.
		IEex_Error("Passed a NaN value: '"..tostring(number).."'!")
	end
	local hexString = nil
	if number < 0 then
		-- string.format can't handle "negative" numbers for some reason
		hexString = ""
		while number ~= 0x0 do
			hexString = string.format("%x", bit.extract(number, 0, 4)):upper()..hexString
			number = bit.rshift(number, 4)
		end
	else
		hexString = string.format("%x", number):upper()
		local wantedLength = (minLength or 0) - #hexString
		for i = 1, wantedLength, 1 do
			hexString = "0"..hexString
		end
	end
	return suppressPrefix and hexString or "0x"..hexString
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
function IEex_ReserveCodeMemory(state)
	local reservedAddress = -1
	local writeLength = -1
	local processCodePageEntry = function(codePage)
		for i, allocEntry in ipairs(codePage) do
			if not allocEntry.reserved then
				writeLength = IEex_CalcWriteLength(state, allocEntry.address)
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
				else
					IEex_InvalidateAssemblyState(state)
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

-- Assembly Macros
dofile("override/IEex_Mac.lua")
