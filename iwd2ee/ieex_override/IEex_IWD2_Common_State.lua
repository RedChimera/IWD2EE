function IEex_GetEngineCharacter()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	return IEex_ReadDword(g_pBaldurChitin + 0x1C60)
end

function IEex_GetEngineCreateChar()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	return IEex_ReadDword(g_pBaldurChitin + 0x1C64)
end

function IEex_GetEngineOptions()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	return IEex_ReadDword(g_pBaldurChitin + 0x1C78)
end

function IEex_GetEngineWorld()
	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	return IEex_ReadDword(g_pBaldurChitin + 0x1C88)
end

----------------------------
-- Start Memory Interface --
----------------------------

IEex_MemoryManagerStructMeta = {

	["CAIScriptFile"] = {
		["constructors"] = {
			["#default"] = {["address"] = 0x40FDC0},
		},
		["destructor"] = {["address"] = 0x40FEB0},
		["size"] = 0xEE,
	},

	["CString"] = {
		["constructors"] = {
			["fromString"] = {["address"] = 0x7FCC88},
		},
		["destructor"] = {["address"] = 0x7FCC1A},
		["size"] = 0x4,
	},

	["string"] = {
		["constructors"] = {
			["#default"] = function(startPtr, luaString)
				IEex_WriteString(startPtr, luaString)
			end,
		},
		["size"] = function(luaString)
			return #luaString + 1
		end,
	},

	["CResRef"] = {
		["constructors"] = {
			["#default"] = function(startPtr, luaString)
				IEex_WriteLString(startPtr, luaString:upper(), 8)
			end,
		},
		["size"] = 8,
	},

	["CRect"] = {
		["constructors"] = {
			["fill"] = function(ptr, left, top, right, bottom)
				IEex_WriteDword(ptr, left)
				IEex_WriteDword(ptr + 0x4, top)
				IEex_WriteDword(ptr + 0x8, right)
				IEex_WriteDword(ptr + 0xC, bottom)
			end,
		},
		["size"] = 16,
	},

	["uninitialized"] = {
		["constructors"] = {},
		["size"] = function(luaSize)
			return luaSize
		end,
	},
}

IEex_MemoryManager = {}
IEex_MemoryManager.__index = IEex_MemoryManager

function IEex_NewMemoryManager(structEntries)
	return IEex_MemoryManager:new(structEntries)
end

function IEex_RunWithStackManager(structEntries, func)
	IEex_MemoryManager:runWithStack(structEntries, func)
end

function IEex_MemoryManager:init(structEntries, stackModeFunc)

	local getConstructor = function(structEntry)
		return structEntry.constructor or {}
	end

	local nameToEntry = {}
	local currentOffset = 0

	for _, structEntry in ipairs(structEntries) do

		nameToEntry[structEntry.name] = structEntry
		local structMeta = IEex_MemoryManagerStructMeta[structEntry.struct]
		local size = structMeta.size
		local sizeType = type(size)

		structEntry.offset = currentOffset
		structEntry.structMeta = structMeta

		if sizeType == "function" then
			currentOffset = currentOffset + size(unpack(getConstructor(structEntry).luaArgs or {}))
		elseif sizeType == "number" then
			currentOffset = currentOffset + size
		else
			IEex_TracebackMessage("[IEex_MemoryManager] Invalid size type!")
		end
	end

	self.nameToEntry = nameToEntry

	local initMemory = function(startAddress)

		self.address = startAddress

		for _, structEntry in ipairs(structEntries) do

			local entryName = structEntry.name
			local offset = structEntry.offset
			local address = startAddress + offset
			structEntry.address = address

			local entryConstructor = getConstructor(structEntry)
			local constructor = structEntry.structMeta.constructors[entryConstructor.variant or "#default"]
			local constructorType = type(constructor)

			if constructorType == "function" then
				constructor(address, unpack(entryConstructor.luaArgs or {}))
			elseif constructorType == "table" then
				local args = entryConstructor.args or {}
				local argsToUse = {}
				for i = #args, 1, -1 do
					local arg = args[i]
					local argType = type(arg)
					if argType == "number" then
						table.insert(argsToUse, arg)
					elseif argType == "string" then
						local entry = nameToEntry[arg]
						if not entry then
							IEex_TracebackMessage("[IEex_MemoryManager] Invalid arg name!")
						end
						table.insert(argsToUse, startAddress + entry.offset)
					else
						IEex_TracebackMessage("[IEex_MemoryManager] Invalid arg type!")
					end
				end
				IEex_Call(constructor.address, argsToUse, address, constructor.popSize or 0x0)
			end
		end
	end

	if stackModeFunc then
		IEex_RunWithStack(currentOffset, function(esp)
			initMemory(esp)
			stackModeFunc(self)
			self:destruct()
		end)
	else
		initMemory(IEex_Malloc(currentOffset))
	end
end

function IEex_MemoryManager:getAddress(name)
	return self.nameToEntry[name].address
end

function IEex_MemoryManager:getAddresses()
	local nameToAddress = {}
	for name, entry in pairs(self.nameToEntry) do
		nameToAddress[name] = entry.address
	end
	return nameToAddress
end

function IEex_MemoryManager:destruct()
	for entryName, entry in pairs(self.nameToEntry) do
		local destructor = entry.structMeta.destructor
		if (not entry.noDestruct) and destructor then
			IEex_Call(destructor.address, {}, entry.address, destructor.popSize or 0x0)
		end
	end
end

function IEex_MemoryManager:free()
	self:destruct()
	IEex_Free(self.address)
end

function IEex_MemoryManager:new(structEntries)
	local o = {}
	setmetatable(o, self)
	o:init(structEntries)
	return o
end

function IEex_MemoryManager:runWithStack(structEntries, stackModeFunc)
	local o = {}
	setmetatable(o, self)
	o:init(structEntries, stackModeFunc)
end

--------------------------
-- End Memory Interface --
--------------------------

function IEex_SetControlTextDisplay(CUIControlTextDisplay, text)
	IEex_RunWithStackManager({
		{["name"] = "text",  ["struct"] = "string", ["constructor"] = {["luaArgs"] = {text} }}, },
		function(manager)
			-- CUIControlTextDisplay_RemoveAll()
			IEex_Call(0x4E2B50, {}, CUIControlTextDisplay, 0x0)
			-- CBaldurEngine_AppendTextDisplay()
			IEex_Call(0x427C20, {manager:getAddress("text"), 0x8A6A68, CUIControlTextDisplay, 0x0}, nil, 0x10)
		end)
end

function IEex_SetTextAreaToStrref(engine, panelID, controlID, strref)
	IEex_Call(0x6103A0, {strref, controlID, panelID}, engine, 0x0)
end

function IEex_SetTextAreaToString(engine, panelID, controlID, string)
	local CUIControlTextDisplay = IEex_GetControlFromPanel(IEex_GetPanelFromEngine(engine, panelID), controlID)
	IEex_SetControlTextDisplay(CUIControlTextDisplay, string)
end
