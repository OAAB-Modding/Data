local discovery = require("OAAB.Mannequins.discovery")
local ownership = require("OAAB.Mannequins.ownership")
local pairing = require("OAAB.Mannequins.pairing")

local M = {}

-- Equipping a weapon does not automatically draw it on a dead/static actor.
-- weaponReady is the engine flag that keeps the equipped model in hand without
-- starting combat AI.
function M.refreshWeaponState(reference)
	if not discovery.isMannequin(reference) or not reference.mobile
		or not ownership.hasOwner(pairing.findLinkedProxy(reference)) then
		return false
	end
	local shouldBeReady = reference.mobile.readiedWeapon ~= nil
	reference.mobile.weaponReady = shouldBeReady
	return shouldBeReady
end

function M.handleBodyPartsUpdated(e)
	M.refreshWeaponState(e.reference)
end

return M
