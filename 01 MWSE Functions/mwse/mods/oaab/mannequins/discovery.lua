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

local function lowerId(object)
	return object and object.id and string.lower(object.id) or nil
end

function M.getMannequinProfile(reference)
	if not reference or not reference.baseObject
		or reference.baseObject.objectType ~= tes3.objectType.npc then
		return nil
	end

	local class = reference.baseObject.class
	return class and M.profiles[lowerId(class)] or nil
end

function M.isMannequin(reference)
	return M.getMannequinProfile(reference) ~= nil
end

function M.isStockProxy(reference)
	return reference and reference.baseObject
		and reference.baseObject.objectType == tes3.objectType.container
		and lowerId(reference.baseObject.script) == M.stockProxyScriptId
end

function M.isEmptyHead(reference)
	if not M.isMannequin(reference) then
		return false
	end
	return M.emptyHeadIds[lowerId(reference.baseObject.head)] == true
end

function M.getPortableId(reference)
	local baseObject = type(reference) == "string" and { id = reference }
		or reference and reference.baseObject
	return M.portableIdsByMannequinId[lowerId(baseObject)]
end

function M.isPortable(reference)
	return mannequinIdsByPortableId[lowerId(reference and reference.baseObject)] ~= nil
end

-- Render-level suppression sets, keyed by tes3.activeBodyPart index.
--
-- The ESP contract (plan 8.1) requires that a stand mannequin still ACCEPT and
-- equip lower-body items; only their geometry is suppressed. Rejecting Pants,
-- Boots or Shirts outright is explicitly forbidden, because a Shirt record may
-- legitimately carry leg body parts.
--
-- Populated lazily: tes3.activeBodyPart is unavailable at file scope in the
-- offline test harness.
local standSuppressedNames = {
	"groin",
	"rightUpperLeg",
	"leftUpperLeg",
	"rightKnee",
	"leftKnee",
	"rightAnkle",
	"leftAnkle",
	"rightFoot",
	"leftFoot",
}

local standSuppressedParts = nil

-- "skirt" is deliberately absent pending the evaluation called for in plan 8.1.
function M.getStandSuppressedParts()
	if standSuppressedParts then
		return standSuppressedParts
	end

	local enum = tes3 and tes3.activeBodyPart
	if not enum then
		return {}
	end

	standSuppressedParts = {}
	for _, name in ipairs(standSuppressedNames) do
		local index = enum[name]
		if index then
			standSuppressedParts[index] = true
		end
	end
	return standSuppressedParts
end

-- A helmet is the only thing an empty-head mannequin must refuse to wear. The
-- mannequin's own empty head/hair BODY records must still render, so this is
-- checked against the source item rather than the slot index alone.
function M.isHelmet(item)
	if not item or not tes3 or not tes3.objectType then
		return false
	end
	if item.objectType ~= tes3.objectType.armor then
		return false
	end
	return tes3.armorSlot == nil or item.slot == tes3.armorSlot.helmet
end

function M.collectCellCandidates(cell)
	local mannequins = {}
	local proxies = {}

	for reference in cell:iterateReferences(tes3.objectType.npc, false) do
		local profile = M.getMannequinProfile(reference)
		if profile then
			table.insert(mannequins, {
				reference = reference,
				profile = profile,
			})
		end
	end

	for reference in cell:iterateReferences(tes3.objectType.container, false) do
		if M.isStockProxy(reference) then
			table.insert(proxies, { reference = reference })
		end
	end

	return mannequins, proxies
end

return M
