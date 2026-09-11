local discovery = require("OAAB.Mannequins.discovery")
local ownership = require("OAAB.Mannequins.ownership")
local pairing = require("OAAB.Mannequins.pairing")
local pickup = require("OAAB.Mannequins.pickup")
local poses = require("OAAB.Mannequins.poses")

local M = {}

function M.handleActivate(e)
	if e.activator ~= tes3.player or not discovery.isMannequin(e.target)
		or not (tes3.mobilePlayer and tes3.mobilePlayer.isSneaking) then
		return
	end

	e.block = true
	e.claim = true
	local reference = e.target
	local proxy = pairing.findLinkedProxy(reference)
	local owner = ownership.getEffectiveOwner(proxy)

	if owner then
		tes3.messageBox({
			message = "Mannequin",
			buttons = { "Steal Mannequin", "Cancel" },
			showInDialog = false,
			callback = function(result)
				if result.button ~= 0 or reference.deleted then return end
				local portableValue = pickup.portableValue(reference)
				if not portableValue then
					tes3.messageBox({
						message = "The matching portable mannequin item is unavailable.",
						showInDialog = false,
					})
					return
				end
				local stolen, stolenFrom = ownership.commitTheft(proxy, portableValue)
				pickup.steal(reference, proxy, stolen and stolenFrom or nil)
			end,
		})
		return
	end

	local canPose = poses.canPose(reference)
	local buttons = canPose
		and { "Change Pose", "Pick Up", "Cancel" }
		or { "Pick Up", "Cancel" }
	tes3.messageBox({
		message = "Mannequin",
		buttons = buttons,
		showInDialog = false,
		callback = function(result)
			if reference.deleted then return end
			if canPose and result.button == 0 then
				poses.showMenu(reference)
			elseif result.button == (canPose and 1 or 0) then
				pickup.pickUp(reference, proxy, nil)
			end
		end,
	})
end

return M
