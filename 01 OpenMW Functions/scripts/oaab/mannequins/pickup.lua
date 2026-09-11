local types = require("openmw.types")
local world = require("openmw.world")

local ownership = require("scripts.oaab.mannequins.ownership")
local discovery = require("scripts.oaab.mannequins.discovery")

local M = {}

local function resolveInventory(inventory)
	if not inventory:isResolved() then
		inventory:resolve()
	end
end

local function isValid(object)
	return object and (not object.isValid or object:isValid())
end

function M.hasRealItems(mannequin, retailEntry)
	local tracked = {}
	for _, objectId in ipairs(retailEntry and retailEntry.displayObjectIds or {}) do
		tracked[objectId] = true
	end

	local inventory = types.Actor.inventory(mannequin)
	resolveInventory(inventory)
	for _, item in ipairs(inventory:getAll()) do
		if item.count ~= 0 and not tracked[item.id] then
			return true
		end
	end
	return false
end

local function createPortableRecord(mannequin)
	local portableId = discovery.getPortableId(mannequin)
	if not portableId then
		return nil, "This mannequin has no matching portable item."
	end

	local template = types.Miscellaneous.record(portableId)
	if not template then
		return nil, "The matching portable mannequin item is unavailable."
	end

	-- Each pickup gets its own generated record. That prevents two mannequins
	-- from stacking and losing which original NPC base each one must recreate.
	local draft = types.Miscellaneous.createRecordDraft({
		template = template,
		name = template.name,
	})
	return world.createRecord(draft), nil
end

function M.portableValue(mannequin)
	local portableId = discovery.getPortableId(mannequin)
	local record = portableId and types.Miscellaneous.record(portableId)
	return record and record.value or nil
end

-- Move every authoritative stock object to the player before removing the
-- mannequin. A restocking object has a negative count and must become a finite,
-- positive player stack; moving it directly can preserve its restocking state.
local function transferProxyContents(proxy, player, owner)
	if not isValid(proxy) then
		return false
	end
	local source = types.Container.inventory(proxy)
	resolveInventory(source)
	local destination = types.Actor.inventory(player)
	local items = {}
	for _, item in ipairs(source:getAll()) do
		if item.count ~= 0 then
			table.insert(items, item)
		end
	end

	for _, item in ipairs(items) do
		local restocking = item.count < 0
			or (types.Item and types.Item.isRestocking and types.Item.isRestocking(item))
		if restocking then
			local copy = world.createObject(item.recordId, math.abs(item.count))
			ownership.copyOwner(copy, owner)
			copy:moveInto(destination)
			item:remove()
		else
			ownership.copyOwner(item, owner)
			item:moveInto(destination)
		end
	end

	-- OpenMW may apply world mutations at a frame boundary. Successful method
	-- calls are sufficient here; re-reading the inventory in this tick can see
	-- stale objects and incorrectly roll back an otherwise successful pickup.
	return true
end

function M.pickUp(options)
	local mannequin = options.mannequin
	local player = options.player
	if not isValid(mannequin) or M.hasRealItems(mannequin, options.retailEntry) then
		return nil, "Remove all items before picking up the mannequin."
	end

	local portableRecord, portableError = createPortableRecord(mannequin)
	if not portableRecord then
		return nil, portableError
	end
	local portable = world.createObject(portableRecord.id)
	local saved = {
		baseId = mannequin.recordId,
		scale = mannequin.scale,
		poseId = options.poseId,
	}
	options.portables[portableRecord.id] = saved
	ownership.copyOwner(portable, options.owner)
	portable:moveInto(types.Actor.inventory(player))
	if options.takeProxyContents
		and not transferProxyContents(options.proxy, player, options.owner) then
		portable:remove()
		options.portables[portableRecord.id] = nil
		return nil, "The mannequin's contents could not be transferred."
	end

	if options.clearDisplay then
		options.clearDisplay(mannequin)
	end
	mannequin:remove()
	return portable, nil
end

local function findPortableState(object, portables)
	if not object then
		return nil, nil
	end
	if portables[object.recordId] then
		return portables[object.recordId], object.recordId
	end
	-- Compatibility with any early development save that keyed a generic
	-- portable by object id rather than by its unique generated record.
	if portables[object.id] then
		return portables[object.id], object.id
	end
	return nil, nil
end

-- world.createObject(baseId) starts a fresh NPC from its base record, including
-- that record's authored inventory. A mannequin can only become portable after
-- its instance has been emptied, so letting the base inventory survive here
-- would duplicate every authored item when the portable is placed again.
local function clearSpawnedInventory(mannequin)
	local inventory = types.Actor.inventory(mannequin)
	resolveInventory(inventory)

	-- getAll may expose a live collection. Snapshot it before removal so adjacent
	-- stacks cannot be skipped as the inventory changes.
	local items = {}
	for _, item in ipairs(inventory:getAll()) do
		table.insert(items, item)
	end
	for _, item in ipairs(items) do
		item:remove()
	end

	for _, item in ipairs(inventory:getAll()) do
		if item.count ~= 0 then
			return false
		end
	end
	return true
end

function M.place(object, actor, position, rotation, portables)
	local saved, key = findPortableState(object, portables)
	if not saved or not saved.baseId or not isValid(object) then
		return nil
	end

	local mannequin = world.createObject(saved.baseId)
	if not clearSpawnedInventory(mannequin) then
		mannequin:remove()
		return nil
	end
	if saved.scale and mannequin.setScale then
		mannequin:setScale(saved.scale)
	end
	local cell = object.cell or (actor and actor.cell)
	if rotation then
		mannequin:teleport(cell, position, rotation)
	else
		mannequin:teleport(cell, position)
	end
	object:remove()
	portables[key] = nil
	return mannequin, saved.poseId
end

return M
