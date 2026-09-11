local M = {}

-- OpenMW cannot swap an actor's animation source at runtime like MWSE can.
-- Instead, the supplied poses are installed as additional animation groups.
-- Their short internal ids are baked into the matching KF text keys under
-- Animations/xbase_anim; keeping those ids unique prevents these files from
-- replacing idle or death animations on ordinary actors.
M.options = {
	-- Relaxed is the pose authored into every full mannequin's base animation
	-- mesh. Returning to it only requires removing any added pose layer.
	{ id = "relaxed", label = "Relaxed" },
	{ id = "contrapposto", label = "Contrapposto", group = "mnc1" },
	{ id = "adlocutio", label = "Adlocutio", group = "mna1" },
	{ id = "adlocutio2", label = "Adlocutio II", group = "mna2" },
}

local byId = {}
for _, pose in ipairs(M.options) do
	byId[pose.id] = pose
end

function M.get(poseId)
	return type(poseId) == "string" and byId[poseId] or nil
end

function M.canPose(profile)
	return profile ~= nil and profile.id == "full"
end

function M.isPlaying(actor, poseId, animation)
	local pose = M.get(poseId)
	if not pose then
		return false
	end
	if not pose.group then
		for _, other in ipairs(M.options) do
			if other.group then
				local ok, playing = pcall(animation.isPlaying, actor, other.group)
				if ok and playing == true then
					return false
				end
			end
		end
		return true
	end
	local ok, playing = pcall(animation.isPlaying, actor, pose.group)
	return ok and playing == true
end

function M.apply(actor, poseId, animation)
	local pose = M.get(poseId)
	if not pose then
		return false, "invalid"
	end

	-- The relaxed KF has coincident Start and Stop keys, so OpenMW ends that
	-- group immediately. The base mannequin mesh is already authored in the
	-- relaxed pose; cancelling every added pose restores it directly.
	if not pose.group then
		for _, other in ipairs(M.options) do
			if other.group then
				pcall(animation.cancel, actor, other.group)
			end
		end
		return true
	end

	-- hasGroup and isPlaying both raise while an actor has no scene animation
	-- object (for example, briefly during cell load), so every call is guarded.
	local okHas, has = pcall(animation.hasGroup, actor, pose.group)
	if not okHas or not has then
		return false, "unavailable"
	end

	for _, other in ipairs(M.options) do
		-- Replacing the selected group as well prevents a second active layer
		-- when an equipment refresh asks us to reassert an existing pose.
		if other.group then
			pcall(animation.cancel, actor, other.group)
		end
	end

	local options = {
		startKey = "start",
		stopKey = "stop",
		loops = 0,
		forceLoop = false,
		-- The pose clips have no loop segment. Retaining the final frame gives a
		-- stable pose without replaying the transition on every loop.
		autoDisable = false,
	}
	if animation.BLEND_MASK and animation.BLEND_MASK.All ~= nil then
		options.blendMask = animation.BLEND_MASK.All
	end
	if animation.PRIORITY and animation.PRIORITY.Scripted ~= nil then
		options.priority = animation.PRIORITY.Scripted
	end

	local okPlay = pcall(animation.playBlended, actor, pose.group, options)
	if not okPlay or not M.isPlaying(actor, poseId, animation) then
		return false, "failed"
	end
	return true
end

return M
