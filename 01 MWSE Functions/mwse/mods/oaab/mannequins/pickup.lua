local discovery = require("OAAB.Mannequins.discovery")
local poses = require("OAAB.Mannequins.poses")
local retail = require("OAAB.Mannequins.retail")

local M = {}

local namespace = "oaabMannequins"
local portableMarker = "portableMannequin"

local function createPortableItemData(reference)
	local portableId = discovery.getPortableId(reference)
	if not portableId then
		return nil, nil, "This mannequin has no matching portable item."
	end
	local added, item, itemData = tes3.addItem({
		reference = tes3.player,
		item = portableId,
		count = 1,
		playSound = true,
		updateGUI = true,
	})
	if added ~= 1 then
		return nil, nil, "The matching portable mannequin item is unavailable."
	end
	if not itemData then
		local ok, created = pcall(tes3.addItemData, {
			to = tes3.player,
			item = item or portableId,
			updateGUI = true,
		})
		if ok then itemData = created end
	end
	if not itemData then
		tes3.removeItem({ reference = tes3.player, item = item or portableId, count = 1 })
		return nil, nil, "The matching portable mannequin item is unavailable."
	end
	return item or tes3.getObject(portableId), itemData, nil
end

function M.portableValue(reference)
	local portableId = discovery.getPortableId(reference)
	local portable = portableId and tes3.getObject(portableId)
	return portable and portable.value or nil
end

function M.pickUp(reference, proxy, stolenOwner, takeProxyContents)
	if not discovery.isMannequin(reference) or reference.deleted then
		return false
	end
	-- Display copies are disposable presentation state. Clear them before
	-- deciding whether the mannequin contains real items.
	if not retail.clearDisplay(reference) then
		mwse.log("[OAAB Mannequins] ERROR: could not clear the retail display before pickup")
		tes3.messageBox({
			message = "The mannequin display could not be cleared.",
			showInDialog = false,
		})
		return false
	end
	if retail.hasRealItems(reference) then
		if proxy then retail.refresh(reference, proxy, true, nil, "pickupRejected") end
		tes3.messageBox({
			message = "Remove all items before picking up the mannequin.",
			showInDialog = false,
		})
		return false
	end

	local item, itemData, portableError = createPortableItemData(reference)
	if not itemData then
		if proxy then retail.refresh(reference, proxy, true, nil, "pickupRecovery") end
		tes3.messageBox({
			message = portableError or "The mannequin could not be picked up.",
			showInDialog = false,
		})
		return false
	end
	itemData.data[namespace] = {
		kind = portableMarker,
		baseId = reference.baseObject.id,
		poseFile = poses.getSelectedFile(reference),
	}
	if stolenOwner then
		itemData.owner = stolenOwner
	end
	if takeProxyContents then
		local transferred = retail.transferContents(proxy, tes3.player)
		if not transferred then
			tes3.removeItem({
				reference = tes3.player,
				item = item,
				itemData = itemData,
				count = 1,
			})
			tes3.messageBox({
				message = "The mannequin's contents could not be transferred.",
				showInDialog = false,
			})
			if proxy then retail.refresh(reference, proxy, true, nil, "pickupTransferRecovery") end
			return false
		end
	end

	reference:delete()
	return true, item
end

function M.steal(reference, proxy, stolenOwner)
	return M.pickUp(reference, proxy, stolenOwner, true)
end

-- createReference restores the NPC base record's authored inventory. The world
-- instance was required to be empty before pickup, so those defaults must not
-- reappear when the portable is placed or they become an item-duplication path.
local function clearSpawnedInventory(reference)
	local inventory = reference.object and reference.object.inventory
	local items = {}
	for _, stack in ipairs(inventory and inventory.items or {}) do
		if stack.object and stack.count and stack.count ~= 0 then
			table.insert(items, {
				object = stack.object,
				count = math.abs(stack.count),
			})
		end
	end

	for _, entry in ipairs(items) do
		if reference.mobile then
			reference.mobile:unequip({ item = entry.object })
		end
		local removed = tes3.removeItem({
			reference = reference,
			item = entry.object,
			count = entry.count,
			playSound = false,
			reevaluateEquipment = false,
			updateGUI = false,
		})
		if removed ~= entry.count then
			return false
		end
	end
	return true
end

function M.place(reference)
	if not discovery.isPortable(reference) then
		return nil
	end
	local state = reference.data and reference.data[namespace]
	if not state or state.kind ~= portableMarker or not state.baseId then
		return nil
	end
	local base = tes3.getObject(state.baseId)
	if not base or base.objectType ~= tes3.objectType.npc then
		tes3.messageBox({ message = "This mannequin's original form is unavailable.", showInDialog = false })
		return nil
	end

	local created = tes3.createReference({
		object = base,
		position = reference.position,
		orientation = reference.orientation,
		cell = reference.cell,
		scale = reference.scale,
	})
	if not created then
		return nil
	end
	if not clearSpawnedInventory(created) then
		created:delete()
		return nil
	end
	created.data[namespace] = created.data[namespace] or {}
	created.data[namespace].poseFile = state.poseFile
	reference:delete()
	timer.frame.delayOneFrame(function()
		if not created.deleted then poses.apply(created) end
	end)
	return created
end

return M
