local M = {}

function M.getEffectiveOwner(proxy)
	if not proxy then
		return nil, nil
	end
	return tes3.getOwner({ reference = proxy })
end

function M.hasOwner(proxy)
	return M.getEffectiveOwner(proxy) ~= nil
end

function M.playerHasAccess(proxy)
	return not proxy or tes3.hasOwnershipAccess({
		reference = tes3.player,
		target = proxy,
	})
end

function M.commitTheft(proxy, value)
	local owner = M.getEffectiveOwner(proxy)
	if not owner or M.playerHasAccess(proxy) then
		return false
	end
	tes3.triggerCrime({
		type = tes3.crimeType.theft,
		victim = owner,
		value = value or 100,
	})
	return true, owner
end

return M
