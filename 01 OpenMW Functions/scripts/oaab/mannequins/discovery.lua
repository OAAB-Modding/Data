local types = require("openmw.types")

local M = {}

M.stockProxyScriptId = "ab_mannstockproxy_s"
M.pairingRadius = 32

M.profiles = {
	["ab_mannequinclassfull"] = {
		id = "full",
		label = "full mannequin",
	},
	["ab_mannequinclassstand"] = {
		id = "stand",
		label = "stand mannequin",
	},
}

M.emptyHeadIds = {
	["ab_b_mann_hd02_f"] = true,
	["ab_b_mann_hd02_m"] = true,
	["ab_b_mann2_hd02_f"] = true,
	["ab_b_mann2_hd02_m"] = true,
}

M.portableIds = {
	"AB_Furn_Mannequin2F",
	"AB_Furn_Mannequin2M",
	"AB_Furn_MannequinHeadF",
	"AB_Furn_MannequinHeadM",
	"AB_Furn_MannequinHeadlessF",
	"AB_Furn_MannequinHeadlessM",
}

M.portableIdsByMannequinId = {
	["ab_mannequin2f"] = "AB_Furn_Mannequin2F",
	["ab_mannequin2m"] = "AB_Furn_Mannequin2M",
	["ab_mannequinheadf"] = "AB_Furn_MannequinHeadF",
	["ab_mannequinheadm"] = "AB_Furn_MannequinHeadM",
	["ab_mannequinheadlessf"] = "AB_Furn_MannequinHeadlessF",
	["ab_mannequinheadlessm"] = "AB_Furn_MannequinHeadlessM",
}

local mannequinIdsByPortableId = {}
for mannequinId, portableId in pairs(M.portableIdsByMannequinId) do
	mannequinIdsByPortableId[string.lower(portableId)] = mannequinId
end

function M.getMannequinProfile(object)
	if not object or not types.NPC.objectIsInstance(object) or types.Player.objectIsInstance(object) then
		return nil
	end

	local record = types.NPC.record(object)
	return record and record.class and M.profiles[string.lower(record.class)] or nil
end

function M.isMannequin(object)
	return M.getMannequinProfile(object) ~= nil
end

function M.isStockProxy(object)
	if not object or not types.Container.objectIsInstance(object) then
		return false
	end
	local record = types.Container.record(object)
	return record and record.mwscript
		and string.lower(record.mwscript) == M.stockProxyScriptId or false
end

function M.isEmptyHead(object)
	if not M.isMannequin(object) then
		return false
	end
	local record = types.NPC.record(object)
	return record and record.head
		and M.emptyHeadIds[string.lower(record.head)] == true or false
end

function M.getPortableId(object)
	local recordId = type(object) == "string" and object or object and object.recordId
	return recordId and M.portableIdsByMannequinId[string.lower(recordId)] or nil
end

function M.isPortable(object)
	return object and object.recordId
		and mannequinIdsByPortableId[string.lower(object.recordId)] ~= nil or false
end

return M
