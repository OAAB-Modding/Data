local discovery = require("scripts.oaab.mannequins.discovery")

local M = {}
local radiusSquared = discovery.pairingRadius * discovery.pairingRadius
local tieEpsilon = 0.0001

local function distanceSquared(first, second)
	local delta = first.position - second.position
	return delta.x * delta.x + delta.y * delta.y + delta.z * delta.z
end

local function candidateSort(first, second)
	if first.distanceSquared ~= second.distanceSquared then
		return first.distanceSquared < second.distanceSquared
	end

	-- Any equal-distance candidates sharing an endpoint are removed before
	-- pairing. Other ties are independent, so their ordering has no effect.
	return false
end

local function markAmbiguous(state, object, reason)
	state.ambiguous[object.id] = {
		object = object,
		reason = reason,
	}
end

local function rejectTiedCandidates(candidates, state)
	local index = 1
	while index <= #candidates do
		local last = index
		while last < #candidates
			and math.abs(candidates[last + 1].distanceSquared - candidates[index].distanceSquared) <= tieEpsilon do
			last = last + 1
		end

		if last > index then
			local mannequinCounts = {}
			local proxyCounts = {}
			local mannequinsById = {}
			local proxiesById = {}
			for candidateIndex = index, last do
				local candidate = candidates[candidateIndex]
				mannequinCounts[candidate.mannequin.id] = (mannequinCounts[candidate.mannequin.id] or 0) + 1
				proxyCounts[candidate.proxy.id] = (proxyCounts[candidate.proxy.id] or 0) + 1
				mannequinsById[candidate.mannequin.id] = candidate.mannequin
				proxiesById[candidate.proxy.id] = candidate.proxy
			end

			for objectId, count in pairs(mannequinCounts) do
				if count > 1 then
					markAmbiguous(state, mannequinsById[objectId], "equally close stock proxies")
				end
			end
			for objectId, count in pairs(proxyCounts) do
				if count > 1 then
					markAmbiguous(state, proxiesById[objectId], "equally close mannequins")
				end
			end
		end

		index = last + 1
	end
end

function M.build(mannequins, proxies)
	local state = {
		byMannequin = {},
		byProxy = {},
		ambiguous = {},
	}
	local candidates = {}

	for _, mannequin in ipairs(mannequins) do
		for _, proxy in ipairs(proxies) do
			if mannequin.cell and proxy.cell and mannequin.cell.id == proxy.cell.id then
				local candidateDistanceSquared = distanceSquared(mannequin, proxy)
				if candidateDistanceSquared <= radiusSquared then
					table.insert(candidates, {
						mannequin = mannequin,
						proxy = proxy,
						distanceSquared = candidateDistanceSquared,
					})
				end
			end
		end
	end

	table.sort(candidates, candidateSort)
	rejectTiedCandidates(candidates, state)

	for _, candidate in ipairs(candidates) do
		local mannequinId = candidate.mannequin.id
		local proxyId = candidate.proxy.id
		if not state.ambiguous[mannequinId] and not state.ambiguous[proxyId]
			and not state.byMannequin[mannequinId] and not state.byProxy[proxyId] then
			state.byMannequin[mannequinId] = {
				mannequin = candidate.mannequin,
				proxy = candidate.proxy,
				distanceSquared = candidate.distanceSquared,
			}
			state.byProxy[proxyId] = candidate.mannequin
		end
	end

	return state
end

return M
