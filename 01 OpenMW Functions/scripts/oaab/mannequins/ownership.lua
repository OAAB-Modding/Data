local interfaces = require("openmw.interfaces")
local types = require("openmw.types")
local world = require("openmw.world")

local M = {}

function M.getEffectiveOwner(proxy)
	if not proxy or not proxy.owner then
		return nil
	end
	local owner = proxy.owner
	if not owner.recordId and not owner.factionId then
		return nil
	end
	return {
		recordId = owner.recordId,
		factionId = owner.factionId,
		factionRank = owner.factionRank,
	}
end

function M.hasOwner(proxy)
	return M.getEffectiveOwner(proxy) ~= nil
end

local function findActiveOwner(owner)
	if not owner or not owner.recordId then
		return nil
	end
	for _, actor in ipairs(world.activeActors) do
		if types.NPC.objectIsInstance(actor) and actor.recordId == owner.recordId then
			return actor
		end
	end
	return nil
end

function M.commitTheft(player, proxy, value)
	local owner = M.getEffectiveOwner(proxy)
	if not owner then
		return false, nil
	end

	interfaces.Crimes.commitCrime(player, {
		type = types.Player.OFFENSE_TYPE.Theft,
		victim = findActiveOwner(owner),
		faction = owner.factionId,
		arg = value,
		-- Let the native crime system determine whether any actor witnessed it.
		victimAware = false,
	})
	return true, owner
end

function M.copyOwner(object, owner)
	if not object or not object.owner or not owner then
		return
	end
	object.owner.recordId = owner.recordId
	object.owner.factionId = owner.factionId
	object.owner.factionRank = owner.factionRank
end

return M
