local discovery = require("OAAB.Mannequins.discovery")

local M = {}

local namespace = "oaabMannequins"
local poses = {
	{ label = "Relaxed", file = "oaab/k/mann_relax.nif" },
	{ label = "Contrapposto", file = "oaab/k/mann_contrapposto.nif" },
	{ label = "Adlocutio", file = "oaab/k/mann_adlocutio.nif" },
	{ label = "Adlocutio II", file = "oaab/k/mann_adlocutio2.nif" },
}

local function getState(reference)
	reference.data[namespace] = reference.data[namespace] or {}
	return reference.data[namespace]
end

local function updateLightingAfterPose(reference)
	local handle = tes3.makeSafeObjectHandle(reference)
	event.register(tes3.event.simulated, function()
		if not handle:valid() then
			return
		end
		local current = handle:getObject()
		if not current.sceneNode or current.deleted then
			return
		end
		current:updateLighting()
	end, { doOnce = true })
end

function M.getSelectedFile(reference)
	local state = reference.data and reference.data[namespace]
	return state and state.poseFile or nil
end

function M.setSelectedFile(reference, file)
	getState(reference).poseFile = file
end

function M.canPose(reference)
	local profile = discovery.getMannequinProfile(reference)
	return profile ~= nil and profile.id == "full"
end

function M.apply(reference)
	local file = M.getSelectedFile(reference)
	if not M.canPose(reference) or not reference.sceneNode or not file then
		return false
	end
	tes3.loadAnimation({ reference = reference, file = file })
	tes3.playAnimation({
		reference = reference,
		group = tes3.animationGroup.idle,
		loopCount = -1,
	})
	-- Animation transforms are evaluated later in the simulation frame. Relight
	-- after that pass so the newly posed scene graph keeps its light sources.
	updateLightingAfterPose(reference)
	return true
end

function M.showMenu(reference)
	if not M.canPose(reference) then
		return false
	end

	local buttons = {}
	for _, pose in ipairs(poses) do
		table.insert(buttons, pose.label)
	end
	table.insert(buttons, "Cancel")
	tes3.messageBox({
		message = "Mannequin Pose",
		buttons = buttons,
		showInDialog = false,
		callback = function(result)
			local selected = poses[result.button + 1]
			if not selected or reference.deleted then
				return
			end
			M.setSelectedFile(reference, selected.file)
			M.apply(reference)
		end,
	})
	return true
end

return M
