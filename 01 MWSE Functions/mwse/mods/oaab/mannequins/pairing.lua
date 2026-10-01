local discovery = require("OAAB.Mannequins.discovery")

local M = {}
local current = {
	byMannequin = {},
	byProxy = {},
	ambiguous = {},
}

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

	-- Same-distance candidates that share an endpoint are rejected before this
	-- comparison. The remaining ties are independent, so no unordered table
	-- iteration can affect ownership of a proxy.
	return false
end

local function describe(reference)
	local cell = reference.cell
	local cellName = cell and cell.displayName or "unknown cell"
	local objectId = reference.baseObject and reference.baseObject.id or reference.id or "unknown"
	return string.format('%s at %s (%.2f, %.2f, %.2f)', objectId, cellName,
		reference.position.x, reference.position.y, reference.position.z)
end

local function markAmbiguous(state, reference, reason)
	state.ambiguous[reference] = reason
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
			for candidateIndex = index, last do
				local candidate = candidates[candidateIndex]
				mannequinCounts[candidate.mannequin.reference] = (mannequinCounts[candidate.mannequin.reference] or 0) + 1
				proxyCounts[candidate.proxy.reference] = (proxyCounts[candidate.proxy.reference] or 0) + 1
			end

			for reference, count in pairs(mannequinCounts) do
				if count > 1 then
					markAmbiguous(state, reference, "equally close stock proxies")
				end
			end
			for reference, count in pairs(proxyCounts) do
				if count > 1 then
					markAmbiguous(state, reference, "equally close mannequins")
				end
			end
		end

		index = last + 1
	end
end

function M.rebuild(cells)
	local state = {
		byMannequin = {},
		byProxy = {},
		ambiguous = {},
	}
	local candidates = {}

	for _, cell in pairs(cells) do
		local mannequins, proxies = discovery.collectCellCandidates(cell)
		for _, proxy in ipairs(proxies) do
			local nearest
			local tied = false
			for _, mannequin in ipairs(mannequins) do
				local candidateDistanceSquared = distanceSquared(mannequin.reference, proxy.reference)
				if candidateDistanceSquared <= radiusSquared then
					if not nearest or candidateDistanceSquared < nearest.distanceSquared - tieEpsilon then
						nearest = {
							mannequin = mannequin,
							proxy = proxy,
							distanceSquared = candidateDistanceSquared,
						}
						tied = false
					elseif math.abs(candidateDistanceSquared - nearest.distanceSquared) <= tieEpsilon then
						tied = true
					end
				end
			end
			-- Each proxy may affect only its closest mannequin. If that mannequin
			-- is already paired, this proxy never falls back to another NPC.
			if tied then
				markAmbiguous(state, proxy.reference, "equally close mannequins")
			elseif nearest then
				table.insert(candidates, nearest)
			end
		end
	end

	table.sort(candidates, candidateSort)
	rejectTiedCandidates(candidates, state)

	for _, candidate in ipairs(candidates) do
		local mannequin = candidate.mannequin.reference
		local proxy = candidate.proxy.reference
		if not state.ambiguous[mannequin] and not state.ambiguous[proxy]
			and not state.byMannequin[mannequin] and not state.byProxy[proxy] then
			state.byMannequin[mannequin] = {
				proxy = proxy,
				distanceSquared = candidate.distanceSquared,
				-- The profile is discovered here and nowhere else. Carrying it through
				-- is what lets the display code tell a stand from a full mannequin.
				profile = candidate.mannequin.profile,
			}
			state.byProxy[proxy] = mannequin
		end
	end

	current = state
	return state
end

function M.findLinkedProxy(reference)
	local pair = current.byMannequin[reference]
	return pair and pair.proxy or nil
end

function M.findProfile(reference)
	local pair = current.byMannequin[reference]
	return pair and pair.profile or nil
end

function M.getState()
	return current
end

function M.describeReference(reference)
	return describe(reference)
end

return M
