local discovery = require("OAAB.Mannequins.discovery")
local ownership = require("OAAB.Mannequins.ownership")
local pairing = require("OAAB.Mannequins.pairing")
local pickup = require("OAAB.Mannequins.pickup")
local poses = require("OAAB.Mannequins.poses")
local activation = require("OAAB.Mannequins.activation")

local M = {}

function M.handleActivate(e)
	if e.activator ~= tes3.player or not discovery.isMannequin(e.target) then
		return
	end
	if activation.isInventoryActivation(e.target) then
		return
	end

	local reference = e.target
	local proxy = pairing.findLinkedProxy(reference)
	local owner = ownership.getEffectiveOwner(proxy)
	e.block = true
	e.claim = true

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
		and { "Inventory", "Change Pose", "Pick Up", "Cancel" }
		or { "Inventory", "Pick Up", "Cancel" }
	tes3.messageBox({
		message = "Mannequin",
		buttons = buttons,
		showInDialog = false,
		callback = function(result)
			if reference.deleted then return end
			if result.button == 0 then
				local handle = tes3.makeSafeObjectHandle(reference)
				timer.delayOneFrame(function()
					if handle:valid() then activation.openInventory(handle:getObject()) end
				end, timer.simulate)
			elseif canPose and result.button == 1 then
				poses.showMenu(reference)
			elseif result.button == (canPose and 2 or 1) then
				pickup.pickUp(reference, proxy, nil)
			end
		end,
	})
end

return M
