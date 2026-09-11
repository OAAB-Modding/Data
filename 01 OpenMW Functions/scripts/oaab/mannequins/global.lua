local types = require("openmw.types")
local world = require("openmw.world")
local interfaces = require("openmw.interfaces")

local discovery = require("scripts.oaab.mannequins.discovery")
local ownership = require("scripts.oaab.mannequins.ownership")
local pickup = require("scripts.oaab.mannequins.pickup")
local poses = require("scripts.oaab.mannequins.poses")

local state = {
	retail = {},
	portables = {},
	poses = {},
}
local pairedProxies = {}
local registeredActivations = {}
local playerSneaking = {}
local syncedPoses = {}

local function resolveInventory(inventory)
	-- Resolve leveled-list entries before reading. Global scripts are allowed to
	-- make inventory contents stable, and unresolved stock is invisible until the
	-- player first opens the container.
	if not inventory:isResolved() then
		inventory:resolve()
	end
end

-- The display set is one copy per distinct item ID, regardless of stock depth, so
-- buying 1 of 5 shirts must not rebuild the mannequin.
local function getDisplayIds(proxy)
	local inventory = types.Container.inventory(proxy)
	resolveInventory(inventory)

	local seen = {}
	local ids = {}
	for _, item in ipairs(inventory:getAll()) do
		-- Restocking stock is stored with a NEGATIVE count, and the absolute value
		-- is the quantity. A `count > 0` test silently hides every restocking
		-- entry, which for a shop proxy is the normal authoring case, so presence
		-- is tested against zero. The stack itself is never rewritten; the proxy
		-- stays authoritative.
		if item.recordId and item.count ~= 0 then
			local key = string.lower(item.recordId)
			if not seen[key] then
				seen[key] = true
				table.insert(ids, item.recordId)
			end
		end
	end
	table.sort(ids)
	return ids
end

local function signature(ids)
	return table.concat(ids, "|")
end

-- Removes only what this mod put here. Wiping the mannequin's whole inventory
-- destroys authored items on any mannequin that gets mispaired, so display copies
-- are tracked by the object id world.createObject handed back. Strays are also
-- caught by record id via the recorded display set, so a copy whose object went
-- missing still cannot accumulate.
local function removeDisplayCopies(mannequin, entry)
	local trackedObjectIds = {}
	for _, objectId in ipairs(entry.displayObjectIds or {}) do
		trackedObjectIds[objectId] = true
	end
	local trackedRecordIds = {}
	for _, recordId in ipairs(entry.displayRecordIds or {}) do
		trackedRecordIds[string.lower(recordId)] = true
	end

	if next(trackedObjectIds) or next(trackedRecordIds) then
		local inventory = types.Actor.inventory(mannequin)
		resolveInventory(inventory)

		-- Collected before removing anything: removal mutates the inventory, and
		-- iterating it at the same time skips entries.
		local doomed = {}
		for _, item in ipairs(inventory:getAll()) do
			if trackedObjectIds[item.id]
				or (item.recordId and trackedRecordIds[string.lower(item.recordId)]) then
				table.insert(doomed, item)
			end
		end
		for _, item in ipairs(doomed) do
			item:remove()
		end
	end

	entry.displayObjectIds = nil
	entry.displayRecordIds = nil
end

local function dispatchEquipmentRefresh(mannequin, entry, ids)
	mannequin:sendEvent("OAABMannequins_RefreshEquipment", { itemIds = ids })
	entry.equipmentRefreshRetries = math.max((entry.equipmentRefreshRetries or 0) - 1, 0)
end

local function registerActivation(mannequin)
	if registeredActivations[mannequin.id] then
		return
	end
	registeredActivations[mannequin.id] = true
	interfaces.Activation.addHandlerForObject(mannequin, function(_, actor)
		if not types.Player.objectIsInstance(actor) then
			return
		end
		local proxy = pairedProxies[mannequin.id]
		if playerSneaking[actor.id] then
			local profile = discovery.getMannequinProfile(mannequin)
			actor:sendEvent("OAABMannequins_ShowMenu", {
				mannequin = mannequin,
				owned = ownership.hasOwner(proxy),
				canPose = poses.canPose(profile),
			})
			return false
		end
		if proxy then
			if ownership.hasOwner(proxy) then
				actor:sendEvent("OAABMannequins_Message", "You can't use an owned mannequin.")
				return false
			end
			proxy:activateBy(actor)
			return false
		end
	end)
end

-- One-way: proxy container -> mannequin visual inventory. The proxy otherwise
-- remains an ordinary container and the engine handles its ownership and trade.
local function refreshRetailMannequin(mannequin, proxy, force)
	local entry = state.retail[mannequin.id] or {}
	state.retail[mannequin.id] = entry

	local ids = getDisplayIds(proxy)
	local desiredSignature = signature(ids)
	if not force and entry.proxyId == proxy.id and entry.signature == desiredSignature then
		if (entry.equipmentRefreshRetries or 0) > 0 then
			dispatchEquipmentRefresh(mannequin, entry, ids)
		end
		return
	end

	-- The ESP contract reserves a retail mannequin inventory for runtime display
	-- copies. Replacing only our own copies prevents old ones becoming loot
	-- without destroying anything an author placed.
	removeDisplayCopies(mannequin, entry)

	local inventory = types.Actor.inventory(mannequin)
	local displayObjectIds = {}
	local displayRecordIds = {}
	for _, itemId in ipairs(ids) do
		local copy = world.createObject(itemId)
		copy:moveInto(inventory)
		table.insert(displayObjectIds, copy.id)
		table.insert(displayRecordIds, itemId)
	end

	entry.proxyId = proxy.id
	entry.signature = desiredSignature
	entry.displayObjectIds = displayObjectIds
	entry.displayRecordIds = displayRecordIds
	entry.equipmentRefreshRetries = 2
	local owner = proxy.owner
	print(string.format("[OAAB Mannequins] mirrored %d display item(s) from %s (owner=%s, faction=%s) to %s",
		#ids, proxy.recordId or proxy.id, owner and owner.recordId or "none",
		owner and owner.factionId or "none", mannequin.recordId or mannequin.id))
	dispatchEquipmentRefresh(mannequin, entry, ids)
end

-- Keeps the entry so a later pairing can still identify and remove any existing
-- display copies. Pairing can flicker for a single tick during cell load.
local function removeRetailMirror(mannequin)
	local entry = state.retail[mannequin.id]
	if not entry then
		return
	end
	removeDisplayCopies(mannequin, entry)
	entry.proxyId = nil
	entry.signature = nil
	entry.equipmentRefreshRetries = 0
	mannequin:sendEvent("OAABMannequins_RefreshEquipment", { itemIds = {} })
end

local function clearDisplay(mannequin)
	local entry = state.retail[mannequin.id]
	if not entry then
		return
	end
	removeDisplayCopies(mannequin, entry)
	entry.proxyId = nil
	entry.signature = nil
	entry.equipmentRefreshRetries = 0
end

local function sendMessage(player, message)
	if player then
		player:sendEvent("OAABMannequins_Message", message)
	end
end

local function handleAction(data)
	if not data or not types.Player.objectIsInstance(data.player)
		or not data.mannequin or not data.mannequin.isValid
		or not data.mannequin:isValid() then
		return
	end

	local mannequin = data.mannequin
	local mannequinId = mannequin.id
	local player = data.player
	local proxy = pairedProxies[mannequinId]
	local owner
	if data.action == "steal" then
		local portableValue = pickup.portableValue(mannequin)
		if not portableValue then
			sendMessage(player, "The matching portable mannequin item is unavailable.")
			return
		end
		local stolen
		stolen, owner = ownership.commitTheft(player, proxy, portableValue)
		if not stolen then
			return
		end
	elseif data.action ~= "pickup" or ownership.hasOwner(proxy) then
		return
	end

	local ok, portable, message = pcall(pickup.pickUp, {
		mannequin = mannequin,
		player = player,
		owner = owner,
		proxy = proxy,
		takeProxyContents = data.action == "steal",
		portables = state.portables,
		poseId = state.poses[mannequinId],
		retailEntry = state.retail[mannequinId],
		clearDisplay = clearDisplay,
	})
	if not ok then
		print("[OAAB Mannequins] WARNING: mannequin pickup failed: " .. tostring(portable))
		sendMessage(player, "The mannequin could not be picked up.")
		return
	end
	if not portable then
		sendMessage(player, message or "The mannequin could not be picked up.")
		return
	end
	-- pickup removes the NPC. Use the id captured while its object handle was
	-- still valid rather than dereferencing the disposed handle afterward.
	state.poses[mannequinId] = nil
	syncedPoses[mannequinId] = nil
	sendMessage(player, "Mannequin added to your inventory.")
end

local function handlePortablePlacement(object, actor, position, rotation)
	if not object or object.isValid and not object:isValid() then
		return
	end
	if not state.portables[object.recordId] and not state.portables[object.id] then
		return
	end
	local ok, mannequin, poseId = pcall(pickup.place, object, actor, position, rotation, state.portables)
	if not ok then
		print("[OAAB Mannequins] WARNING: mannequin placement failed: " .. tostring(mannequin))
		sendMessage(actor, "The mannequin could not be placed.")
		return
	end
	if mannequin then
		if poses.get(poseId) then
			state.poses[mannequin.id] = poseId
			syncedPoses[mannequin.id] = poseId
			mannequin:sendEvent("OAABMannequins_SetPose", { poseId = poseId })
		end
		sendMessage(actor, "Mannequin placed.")
	end
end

local function loadState(saved)
	local loaded = saved or {}
	loaded.retail = loaded.retail or {}
	loaded.portables = loaded.portables or {}
	loaded.poses = loaded.poses or {}
	return loaded
end

return {
	engineHandlers = {
		onLoad = function(data)
			state = loadState(data)
			syncedPoses = {}
		end,
		onSave = function()
			return state
		end,
		-- onDropped/onPlaced were added after the 0.51 build used by the
		-- supported setup. onItemActive is available there and fires when a
		-- portable leaves inventory and becomes active in a cell, for both a
		-- normal drop and surface placement.
		onItemActive = function(object)
			handlePortablePlacement(object, nil, object.position, object.rotation)
		end,
	},
	eventHandlers = {
		OAABMannequins_SneakChanged = function(data)
			if data and data.player then
				playerSneaking[data.player.id] = data.sneaking == true
			end
		end,
		OAABMannequins_PoseChanged = function(data)
			if data and data.mannequin and poses.get(data.poseId)
				and poses.canPose(discovery.getMannequinProfile(data.mannequin)) then
				state.poses[data.mannequin.id] = data.poseId
				syncedPoses[data.mannequin.id] = data.poseId
			end
		end,
		OAABMannequins_Action = handleAction,
		OAABMannequins_PairingsUpdated = function(data)
			pairedProxies = {}
			local paired = {}
			for _, pair in ipairs(data.pairs) do
				paired[pair.mannequin.id] = true
				pairedProxies[pair.mannequin.id] = pair.proxy
				refreshRetailMannequin(pair.mannequin, pair.proxy, data.force == true)
			end

			for _, mannequin in ipairs(data.mannequins) do
				registerActivation(mannequin)
				local poseId = state.poses[mannequin.id]
				if poses.get(poseId) and syncedPoses[mannequin.id] ~= poseId then
					syncedPoses[mannequin.id] = poseId
					mannequin:sendEvent("OAABMannequins_SetPose", { poseId = poseId })
				end
				if not paired[mannequin.id] then
					removeRetailMirror(mannequin)
				end
			end
		end,
	},
}
