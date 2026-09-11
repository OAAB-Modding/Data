local bodyparts = require("OAAB.Mannequins.bodyparts")
local equipment = require("OAAB.Mannequins.equipment")

local M = {}

local namespace = "oaabMannequins"
local displayMarker = "retailDisplay"

local function log(message, ...)
	if mwse and mwse.log then
		mwse.log("[OAAB Mannequins] " .. message, ...)
	end
end

local function getState(reference)
	reference.data[namespace] = reference.data[namespace] or {}
	return reference.data[namespace]
end

-- When a changed container instance is closed empty (e.g. barter sold its last
-- item), the engine discards the clone and sets the reference's isEmpty flag
-- instead. reference.object is then the base object, whose inventory still
-- lists the authored stock. Vanilla GetItemCount honours the flag; MWSE's
-- inventory access and tes3.getItemCount do not.
local function getInventoryItems(reference)
	if reference.isEmpty then
		return {}
	end
	local inventory = reference.object and reference.object.inventory
	return inventory and inventory.items or {}
end

-- Raw stack enumeration supplies candidate IDs. getItemCount supplies the
-- placement's current count, including a zero for a candidate removed since the
-- previous display refresh. Neither operation mutates or resolves the proxy.
local function getInventoryCounts(reference, knownItems)
	if reference.isEmpty then
		return {}
	end
	local candidates = {}
	for _, stack in ipairs(getInventoryItems(reference)) do
		if stack.object and stack.object.id then
			candidates[string.lower(stack.object.id)] = stack.object
		end
	end

	for _, knownItem in pairs(knownItems or {}) do
		local item = knownItem
		if type(item) == "table" and item.object and item.object.id then
			item = item.object
		elseif type(item) == "table" and item.id then
			item = item
		elseif type(item) == "string" then
			item = tes3.getObject(item)
		end
		if item and item.id then
			candidates[string.lower(item.id)] = item
		end
	end

	local counts = {}
	for key, item in pairs(candidates) do
		local count = math.abs(tes3.getItemCount({
			reference = reference,
			item = item,
		}) or 0)
		if count > 0 then
			counts[key] = {
				id = item.id,
				object = item,
				count = count,
			}
		end
	end
	return counts
end

local function sortedEntries(counts)
	local entries = {}
	for _, entry in pairs(counts or {}) do
		table.insert(entries, entry)
	end
	table.sort(entries, function(first, second)
		return string.lower(first.id) < string.lower(second.id)
	end)
	return entries
end

local function displaySignature(entries)
	local ids = {}
	for _, entry in ipairs(entries) do
		table.insert(ids, string.lower(entry.id))
	end
	return table.concat(ids, "|")
end

local function countSignature(counts)
	local entries = {}
	for _, entry in pairs(counts or {}) do
		table.insert(entries, string.format("%s=%d", string.lower(entry.id), entry.count))
	end
	table.sort(entries)
	return table.concat(entries, "|")
end

local function referenceKey(reference)
	local cell = reference.cell
	local position = reference.position or { x = 0, y = 0, z = 0 }
	return string.format("%s|%s|%s|%.3f|%.3f|%.3f",
		reference.id or "unknown",
		cell and cell.editorName or "unknown cell",
		tostring(reference.sourceModId or ""),
		position.x or 0, position.y or 0, position.z or 0)
end

local function getMarker(itemData)
	if not itemData then
		return nil
	end
	return itemData.data[namespace]
end

local function setMarker(itemData, proxyKey)
	itemData.data[namespace] = {
		kind = displayMarker,
		proxyKey = proxyKey,
	}
end

-- tes3itemStack.variables is sparse after entries are erased, so pairs() is
-- required here. ipairs() would stop at the first hole and leak later copies.
local function forEachItemData(reference, callback)
	for _, stack in ipairs(getInventoryItems(reference)) do
		for _, itemData in pairs(stack.variables or {}) do
			if itemData then
				callback(stack.object, itemData)
			end
		end
	end
end

local function getTaggedDisplayItems(reference)
	local tagged = {}
	forEachItemData(reference, function(item, itemData)
		local marker = getMarker(itemData)
		if marker and marker.kind == displayMarker then
			local key = string.lower(item.id)
			local entry = tagged[key] or {
				id = item.id,
				object = item,
				itemDatas = {},
			}
			table.insert(entry.itemDatas, itemData)
			tagged[key] = entry
		end
	end)
	return tagged
end

local function addDisplayItem(reference, item, proxyKey)
	local added, addedItem, addedData = tes3.addItem({
		reference = reference,
		item = item,
		count = 1,
		reevaluateEquipment = false,
		playSound = false,
		updateGUI = false,
	})
	if added ~= 1 then
		return nil
	end

	local resolvedItem = addedItem or item
	local itemData = addedData
	if not itemData then
		local ok, result = pcall(tes3.addItemData, {
			to = reference,
			item = resolvedItem,
			updateGUI = false,
		})
		if ok then
			itemData = result
		else
			log("ERROR: could not create display itemData for %s: %s",
				tostring(resolvedItem.id or resolvedItem), tostring(result))
		end
	end

	if not itemData then
		tes3.removeItem({
			reference = reference,
			item = resolvedItem,
			count = 1,
			reevaluateEquipment = false,
			playSound = false,
			updateGUI = false,
		})
		return nil
	end

	setMarker(itemData, proxyKey)
	return itemData, resolvedItem
end

local function inventoryCount(reference, item)
	local itemId = type(item) == "string" and item or item.id
	if not itemId then
		return 0
	end
	itemId = string.lower(itemId)
	for _, stack in ipairs(getInventoryItems(reference)) do
		if stack.object and stack.object.id
			and string.lower(stack.object.id) == itemId then
			return math.abs(stack.count or 0)
		end
	end
	return 0
end

local function removeTaggedCopy(reference, item, itemData)
	if reference.mobile then
		reference.mobile:unequip({ item = item, itemData = itemData })
	end

	local before = inventoryCount(reference, item)
	local removed = tes3.removeItem({
		reference = reference,
		item = item,
		itemData = itemData,
		count = 1,
		reevaluateEquipment = false,
		playSound = false,
		updateGUI = false,
	})
	if removed ~= 1 then
		local itemDataRemoved = false
		if tes3.removeItemData then
			local ok, result = pcall(tes3.removeItemData, {
				from = reference,
				item = item,
				itemData = itemData,
				force = true,
				updateGUI = false,
			})
			itemDataRemoved = ok and result == true
		end
		removed = tes3.removeItem({
			reference = reference,
			item = item,
			count = 1,
			reevaluateEquipment = false,
			playSound = false,
			updateGUI = false,
		})
		log("WARNING: exact display removal for %s returned zero; "
			.. "fallback itemDataRemoved=%s, countRemoved=%d",
			item.id, tostring(itemDataRemoved), removed)
	end

	local after = inventoryCount(reference, item)
	local success = removed == 1 and after == math.max(0, before - 1)
	if not success then
		log("ERROR: display removal failed for %s on %s: before=%d, removed=%d, after=%d",
			item.id, referenceKey(reference), before, removed, after)
	end
	return success
end

-- Only disposable visual copies are removed. Recorded IDs catch a copy which
-- lost its marker without allowing the display to accumulate duplicates.
local function removeDisplayCopies(reference, recordedIds)
	local tagged = getTaggedDisplayItems(reference)
	local success = true

	for _, entry in pairs(tagged) do
		for _, itemData in pairs(entry.itemDatas) do
			success = removeTaggedCopy(reference, entry.object, itemData) and success
		end
	end

	for _, itemId in ipairs(recordedIds or {}) do
		local key = string.lower(itemId)
		if not tagged[key] and inventoryCount(reference, itemId) > 0 then
			if reference.mobile then
				reference.mobile:unequip({ item = itemId })
			end
			local before = inventoryCount(reference, itemId)
			local removed = tes3.removeItem({
				reference = reference,
				item = itemId,
				count = 1,
				reevaluateEquipment = false,
				playSound = false,
				updateGUI = false,
			})
			success = removed == 1
				and inventoryCount(reference, itemId) == before - 1
				and success
		end
	end
	return success
end

local function displayMatches(reference, entries, proxyKey)
	local expected = {}
	for _, entry in ipairs(entries) do
		expected[string.lower(entry.id)] = true
	end

	local found = {}
	forEachItemData(reference, function(item, itemData)
		local marker = getMarker(itemData)
		if marker and marker.kind == displayMarker and marker.proxyKey == proxyKey then
			local key = string.lower(item.id)
			found[key] = (found[key] or 0) + 1
		end
	end)

	for itemId in pairs(expected) do
		if found[itemId] ~= 1 then
			return false
		end
	end
	for itemId, count in pairs(found) do
		if not expected[itemId] or count ~= 1 then
			return false
		end
	end
	return true
end

local function refreshDisplay(reference, proxy, force, profile, trigger)
	local state = getState(reference)
	local counts = getInventoryCounts(proxy, state.retailDisplayIds)
	local entries = sortedEntries(counts)
	local proxyKey = referenceKey(proxy)
	local desiredSignature = displaySignature(entries)

	if not force and state.retailProxyKey == proxyKey
		and state.retailSignature == desiredSignature
		and displayMatches(reference, entries, proxyKey) then
		return false
	end

	if not removeDisplayCopies(reference, state.retailDisplayIds) then
		log("ERROR: retail display refresh aborted for %s", referenceKey(reference))
		return false
	end

	local placedIds = {}
	if reference.mobile then
		for _, entry in ipairs(entries) do
			local itemData, item = addDisplayItem(reference, entry.object, proxyKey)
			if itemData then
				table.insert(placedIds, entry.id)
				if bodyparts.shouldEquip(reference, entry.object) then
					reference.mobile:equip({
						item = item,
						itemData = itemData,
						playSound = false,
					})
				end
			end
		end
		reference.object:reevaluateEquipment()
		reference:updateEquipment()
		equipment.refreshWeaponState(reference)
	end

	state.retailProxyKey = proxyKey
	state.retailSignature = desiredSignature
	state.retailDisplayIds = placedIds
	log("retail display %s [%s] via %s: proxyStock=[%s]",
		referenceKey(reference), profile and profile.id or "unpaired",
		trigger or "unspecified", countSignature(counts))
	return true
end

-- The proxy is only observed here. It remains an ordinary owned container, and
-- vanilla Morrowind alone exposes and transfers its stock during trade.
function M.refresh(reference, proxy, force, profile, trigger)
	return refreshDisplay(reference, proxy, force, profile, trigger)
end

function M.refreshAll(pairingState, force, trigger)
	for mannequin, pair in pairs(pairingState.byMannequin) do
		M.refresh(mannequin, pair.proxy, force, pair.profile, trigger)
	end
end

function M.isDisplayItemData(itemData)
	local marker = getMarker(itemData)
	return marker and marker.kind == displayMarker or false
end

function M.hasRealItems(reference)
	for _, stack in ipairs(getInventoryItems(reference)) do
		local count = math.abs(stack.count or 0)
		local displayCount = 0
		for _, itemData in pairs(stack.variables or {}) do
			if itemData and M.isDisplayItemData(itemData) then
				displayCount = displayCount + 1
			end
		end
		if count > displayCount then
			return true
		end
	end
	return false
end

function M.clearDisplay(reference)
	local state = getState(reference)
	if removeDisplayCopies(reference, state.retailDisplayIds) then
		state.retailProxyKey = nil
		state.retailSignature = nil
		state.retailDisplayIds = nil
		return true
	end
	return false
end

-- Taking an owned mannequin is the one explicit action which moves real proxy
-- contents: the stock is stolen into the player's inventory with the mannequin.
function M.transferContents(proxy, destination)
	if not proxy or not destination then
		return false, 0
	end

	local entries = sortedEntries(getInventoryCounts(proxy))
	local expected = 0
	local transferredTotal = 0
	for _, entry in ipairs(entries) do
		expected = expected + entry.count
		local transferred = tes3.transferItem({
			from = proxy,
			to = destination,
			item = entry.object or entry.id,
			count = entry.count,
			limitCapacity = false,
			playSound = false,
			reevaluateEquipment = false,
			updateGUI = false,
		})
		transferredTotal = transferredTotal + transferred
	end

	if expected > 0 then
		tes3.updateInventoryGUI({ reference = proxy })
		tes3.updateInventoryGUI({ reference = destination })
	end

	local emptied = next(getInventoryCounts(proxy, entries)) == nil
	return transferredTotal == expected and emptied, transferredTotal
end

-- Container-close handling is only an immediate display refresh. It does not
-- participate in, inspect, or alter the game's trade transaction.
function M.handleContainerClosed(e, pairingState, scheduleNextFrame)
	local mannequin = pairingState.byProxy[e.reference]
	if not mannequin then
		return false
	end
	local pair = pairingState.byMannequin[mannequin]
	if not pair then
		return false
	end

	scheduleNextFrame(function()
		M.refresh(mannequin, pair.proxy, false, pair.profile, "containerClosed")
	end)
	return true
end

function M.getDisplayIds(proxy)
	local ids = {}
	for _, entry in ipairs(sortedEntries(getInventoryCounts(proxy))) do
		table.insert(ids, entry.id)
	end
	return ids
end

return M
