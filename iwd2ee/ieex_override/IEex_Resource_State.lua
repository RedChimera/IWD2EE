
function IEex_FileExtensionToType(extension)
	return ({
		["2DA"] = 0x3F4, -- CResText     (0x85DB90)
		["ARE"] = 0x3F2, -- CResArea     (0x847688)
		["BAH"] = 0x44C, -- CResBAH      (0x85DB24)
		["BAM"] = 0x3E8, -- CResCell     (0x85DB00)
		["BCS"] = 0x3EF, -- CResText     (0x85DB90)
		["BIO"] = 0x3FE, -- CResBIO      (0x8480C8)
		["BMP"] = 0x001, -- CResBitmap   (0x85DAB8)
		[ "BS"] = 0x3F9, -- CResText     (0x85DB90)
		["CHR"] = 0x3FA, -- CResCHR      (0x847664)
		["CHU"] = 0x3EA, -- CResUI       (0x8475D4)
		["CRE"] = 0x3F1, -- CResCRE      (0x847640)
		["DLG"] = 0x3F3, -- CResDLG      (0x8476F4)
		["EFF"] = 0x3F8, -- CResEffect   (0x84773C)
		["GAM"] = 0x3F5, -- CResGame     (0x8476AC)
		["IDS"] = 0x3F0, -- CResText     (0x85DB90)
		["INI"] = 0x802, -- CRes         (0x85DA70)
		["ITM"] = 0x3ED, -- CResItem     (0x8475F8)
		["MOS"] = 0x3EC, -- CResMosaic   (0x85DB48)
		["MVE"] = 0x002, -- CRes         (0x85DA70)
		["PLT"] = 0x006, -- CResPLT      (0x85DADC)
		["SPL"] = 0x3EE, -- CResSpell    (0x84761C)
		["STO"] = 0x3F6, -- CResStore    (0x8476D0)
		["TGA"] = 0x003, -- CRes         (0x85DA70)
		["TIS"] = 0x3EB, -- CResTileSet  (0x85DB6C)
		["TOH"] = 0x407, -- CRes         (0x85DA70)
		["TOT"] = 0x406, -- CRes         (0x85DA70)
		["VEF"] = 0x3FC, -- CResBinary   (0x847760)
		["VVC"] = 0x3FB, -- CResBinary   (0x847760)
		["WAV"] = 0x004, -- CResWave     (0x85DA94)
		["WED"] = 0x3E9, -- CResWED      (0x8475B0)
		["WFX"] = 0x005, -- CResBinary   (0x847760)
		["WMP"] = 0x3F7, -- CResWorldMap (0x847718)
	})[extension:upper()]
end

function IEex_FileTypeToExtension(fileType)
	return ({
		[0x3F4] = "2DA", -- CResText     (0x85DB90)
		[0x3F2] = "ARE", -- CResArea     (0x847688)
		[0x44C] = "BAH", -- CResBAH      (0x85DB24)
		[0x3E8] = "BAM", -- CResCell     (0x85DB00)
		[0x3EF] = "BCS", -- CResText     (0x85DB90)
		[0x3FE] = "BIO", -- CResBIO      (0x8480C8)
		[0x001] = "BMP", -- CResBitmap   (0x85DAB8)
		[0x3F9] =  "BS", -- CResText     (0x85DB90)
		[0x3FA] = "CHR", -- CResCHR      (0x847664)
		[0x3EA] = "CHU", -- CResUI       (0x8475D4)
		[0x3F1] = "CRE", -- CResCRE      (0x847640)
		[0x3F3] = "DLG", -- CResDLG      (0x8476F4)
		[0x3F8] = "EFF", -- CResEffect   (0x84773C)
		[0x3F5] = "GAM", -- CResGame     (0x8476AC)
		[0x3F0] = "IDS", -- CResText     (0x85DB90)
		[0x802] = "INI", -- CRes         (0x85DA70)
		[0x3ED] = "ITM", -- CResItem     (0x8475F8)
		[0x3EC] = "MOS", -- CResMosaic   (0x85DB48)
		[0x002] = "MVE", -- CRes         (0x85DA70)
		[0x006] = "PLT", -- CResPLT      (0x85DADC)
		[0x3EE] = "SPL", -- CResSpell    (0x84761C)
		[0x3F6] = "STO", -- CResStore    (0x8476D0)
		[0x003] = "TGA", -- CRes         (0x85DA70)
		[0x3EB] = "TIS", -- CResTileSet  (0x85DB6C)
		[0x407] = "TOH", -- CRes         (0x85DA70)
		[0x406] = "TOT", -- CRes         (0x85DA70)
		[0x3FC] = "VEF", -- CResBinary   (0x847760)
		[0x3FB] = "VVC", -- CResBinary   (0x847760)
		[0x004] = "WAV", -- CResWave     (0x85DA94)
		[0x3E9] = "WED", -- CResWED      (0x8475B0)
		[0x005] = "WFX", -- CResBinary   (0x847760)
		[0x3F7] = "WMP", -- CResWorldMap (0x847718)
	})[fileType]
end

function IEex_GetResourceManager()
	return IEex_ReadDword(0x8CF6D8) + 0x542
end

IEex_ResWrapper = {}
IEex_ResWrapper.__index = IEex_ResWrapper

function IEex_ResWrapper:isValid()
	return self.pData ~= 0x0
end

function IEex_ResWrapper:getResRef()
	return self.resref
end

function IEex_ResWrapper:getRes()
	return self.pRes
end

function IEex_ResWrapper:getData()
	return self.pData
end

function IEex_ResWrapper:free()
	local pRes = self.pRes
	if pRes ~= 0x0 then
		-- CRes_DecrementDemands (opposite of CRes_Demand)
		IEex_Call(0x77E5F0, {}, pRes, 0x0)
		-- CRes_DecrementRequests (opposite of CRes_Request)
		IEex_Call(0x77E370, {}, pRes, 0x0)
		-- CResourceManager_DumpResObject (opposite of CResourceManager_GetResObject)
		IEex_Call(0x787CE0, {pRes}, IEex_GetResourceManager(), 0x0)
		self.resref = ""
		self.pRes = 0x0
		self.pData = 0x0
	end
end

function IEex_ResWrapper:init(resref, pRes)
	self.resref = resref
	self.pRes = pRes
	self.pData = pRes ~= 0x0 and IEex_ReadDword(pRes + 0x8) or 0x0
end

function IEex_ResWrapper:new(resref, pRes, o)
	local o = o or {}
	setmetatable(o, self)
	o:init(resref, pRes)
	return o
end

function IEex_DemandRes(resref, extension)

	local IEex_CustomResDemand = {
		[0x3EA] = 0x401400, -- CHU
		[0x3ED] = 0x4015B0, -- ITM
	}

	local extensionType = IEex_FileExtensionToType(extension)

	local resrefMem = IEex_Malloc(0x8)
	IEex_WriteLString(resrefMem, resref, 8)
	-- CResourceManager_GetResObject(pResref, nType, bWarningIfMissing)
	local pRes = IEex_Call(0x786DF0, {1, extensionType, resrefMem}, IEex_GetResourceManager(), 0x0)
	IEex_Free(resrefMem)

	if pRes ~= 0x0 then
		-- CRes_Request
		IEex_Call(0x77E610, {}, pRes, 0x0)
		-- CRes_Demand
		IEex_Call(IEex_CustomResDemand[extensionType] or 0x77E390, {}, pRes, 0x0)
	end

	return IEex_ResWrapper:new(resref, pRes)
end

function IEex_CreateAndDemandCItem(resref, useCount1, useCount2, useCount3, wear, flags)
	local CItem = IEex_CreateCItem(resref, useCount1, useCount2, useCount3, wear, flags)
	IEex_Call(0x4015B0, {}, IEex_ReadDword(CItem + 0x8), 0x0) -- CResItem_Demand
	return CItem
end

function IEex_CreateCItem(resref, useCount1, useCount2, useCount3, wear, flags)

	local resrefMem = IEex_Malloc(0x8)
	IEex_WriteLString(resrefMem, resref, 8)

	local CItem = IEex_Malloc(0xEE)

	-- CItem_Construct
	IEex_Call(0x4E7E90, {
		flags     or 0, -- flags
		wear      or 0, -- wear
		useCount3 or 0, -- useCount3
		useCount2 or 0, -- useCount2
		useCount1 or 0, -- useCount1
		IEex_ReadDword(resrefMem + 0x4), -- resref (2/2)
		IEex_ReadDword(resrefMem + 0x0), -- resref (1/2)
	}, CItem, 0x0)

	IEex_Free(resrefMem)
	return CItem
end

function IEex_DemandCItem(CItem)
	local res = IEex_ReadDword(CItem + 0x8)
	IEex_Call(0x4015B0, {}, res, 0x0) -- CResItem_Demand
	return IEex_ReadDword(res + 0x58)
end

function IEex_DestructCItem(CItem)
	-- CItem_Destruct (handles both CRes_DecrementRequests and CResourceManager_DumpResObject)
	IEex_Call(0x4E8180, {}, CItem, 0x0)
end

function IEex_DumpCItem(CItem)
	IEex_UndemandCItem(CItem)
	IEex_DestructCItem(CItem)
	IEex_Free(CItem)
end

function IEex_GetCItemAbilityNum(CItem, abilityNum)
	-- CItem_GetAbilityNum
	return IEex_Call(0x4E9610, {abilityNum}, CItem, 0x0)
end

function IEex_GetCItemResref(CItem)
	return IEex_ReadLString(CItem + 0xC, 8)
end

function IEex_IsCItemResValid(CItem)
	return IEex_ReadDword(CItem + 0x8) ~= 0x0
end

function IEex_SafeDemandCItem(CItem)
	-- CItem_Demand
	IEex_Call(0x4E82B0, {}, CItem, 0x0)
end

function IEex_SafeUndemandCItem(CItem)
	-- CItem_DecrementDemands
	IEex_Call(0x4E82F0, {}, CItem, 0x0)
end

function IEex_UndemandCItem(CItem)
	IEex_Call(0x401BA0, {}, IEex_ReadDword(CItem + 0x8), 0x0) -- CResItem_DecrementDemands
end

---------
-- Dev --
---------

function IEex_Dev_DumpCResVFTableMappings()

	local vftableToExtension = {
		[0x8475B0] = {"WED"},
		[0x8475D4] = {"CHU"},
		[0x8475F8] = {"ITM"},
		[0x84761C] = {"SPL"},
		[0x847640] = {"CRE"},
		[0x847664] = {"CHR"},
		[0x847688] = {"ARE"},
		[0x8476AC] = {"GAM"},
		[0x8476D0] = {"STO"},
		[0x8476F4] = {"DLG"},
		[0x847718] = {"WMP"},
		[0x84773C] = {"EFF"},
		[0x847760] = {"VEF", "VVC", "WFX"},
		[0x8480C8] = {"BIO"},
		[0x85DA70] = {"INI", "MVE", "TGA", "TOH", "TOT"},
		[0x85DA94] = {"WAV"},
		[0x85DAB8] = {"BMP"},
		[0x85DADC] = {"PLT"},
		[0x85DB00] = {"BAM"},
		[0x85DB24] = {"UNKNOWN"},
		[0x85DB48] = {"MOS"},
		[0x85DB6C] = {"TIS"},
		[0x85DB90] = {"2DA", "BCS", "BS", "IDS"},
	}

	local iterateMapInOrder = function(map, func)
		local list = {}
		for k, v in pairs(map) do
			table.insert(list, {k, v})
		end
		table.sort(list, function(a, b)
			return a[1] < b[1]
		end)
		for _, v in ipairs(list) do
			func(v[1], v[2])
		end
	end

	local doOutputForOffset = function(offset)

		local funcAddressToExtensions = {}

		for vftable, extensions in pairs(vftableToExtension) do
			local funcAddress = IEex_ReadDword(vftable + offset)
			local funcExtensions = funcAddressToExtensions[funcAddress]
			if not funcExtensions then funcExtensions = {}; funcAddressToExtensions[funcAddress] = funcExtensions end
			for _, extension in ipairs(extensions) do
				funcExtensions[extension] = true
			end
		end

		print("-------------------------")
		print(IEex_ToHex(offset)..":")
		print("-------------------------")
		iterateMapInOrder(funcAddressToExtensions, function(funcAddress, extensions)
			print("    "..IEex_ToHex(funcAddress)..":")
			iterateMapInOrder(extensions, function(extension, _)
				print("        "..extension)
			end)
		end)
	end

	print("--------------------------------------------------")
	print("CRes vftable functions ->")
	print("--------------------------------------------------")
	for i = 0x0, 0x20, 0x4 do
		doOutputForOffset(i)
	end
end

function IEex_Dev_DumpCResVFTables()

	IEex_DisableCodeProtection()
	IEex_WriteAssembly(0x78EE0F, {"!xor_eax_eax !nop !nop !nop"})

	local g_pBaldurChitin = IEex_ReadDword(0x8CF6DC)
	local fileTypeToVFTable = {}

	for i = 0, 1000000, 1 do
		-- CBaldurChitin_AllocResObject
		local CRes = IEex_Call(0x423210, {i}, g_pBaldurChitin, 0x0)
		if CRes ~= 0x0 then
			local vftable = IEex_ReadDword(CRes)
			if not fileTypeToVFTable[i] then
				fileTypeToVFTable[i] = vftable
			else
				IEex_MessageBox("Error")
			end
			IEex_Free(CRes)
		end
	end

	for k, v in pairs(fileTypeToVFTable) do
		print(IEex_ToHex(k).." -> "..IEex_ToHex(v))
	end

	IEex_WriteAssembly(0x78EE0F, {"!call :77E250"})
	IEex_EnableCodeProtection()
end
