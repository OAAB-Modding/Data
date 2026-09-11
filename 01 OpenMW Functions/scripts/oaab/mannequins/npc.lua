local animation = require("openmw.animation")
local core = require("openmw.core")
local self = require("openmw.self")
local types = require("openmw.types")

local discovery = require("scripts.oaab.mannequins.discovery")
local poses = require("scripts.oaab.mannequins.poses")

local clothingSlots = {
	[types.Clothing.TYPE.Amulet] = types.Actor.EQUIPMENT_SLOT.Amulet,
	[types.Clothing.TYPE.Belt] = types.Actor.EQUIPMENT_SLOT.Belt,
	[types.Clothing.TYPE.LGlove] = types.Actor.EQUIPMENT_SLOT.LeftGauntlet,
	[types.Clothing.TYPE.Pants] = types.Actor.EQUIPMENT_SLOT.Pants,
	[types.Clothing.TYPE.RGlove] = types.Actor.EQUIPMENT_SLOT.RightGauntlet,
	[types.Clothing.TYPE.Ring] = types.Actor.EQUIPMENT_SLOT.RightRing,
	[types.Clothing.TYPE.Robe] = types.Actor.EQUIPMENT_SLOT.Robe,
	[types.Clothing.TYPE.Shirt] = types.Actor.EQUIPMENT_SLOT.Shirt,
	[types.Clothing.TYPE.Shoes] = types.Actor.EQUIPMENT_SLOT.Boots,
	[types.Clothing.TYPE.Skirt] = types.Actor.EQUIPMENT_SLOT.Skirt,
}

local armorSlots = {
	[types.Armor.TYPE.Boots] = types.Actor.EQUIPMENT_SLOT.Boots,
	[types.Armor.TYPE.Cuirass] = types.Actor.EQUIPMENT_SLOT.Cuirass,
	[types.Armor.TYPE.Greaves] = types.Actor.EQUIPMENT_SLOT.Greaves,
	[types.Armor.TYPE.Helmet] = types.Actor.EQUIPMENT_SLOT.Helmet,
	[types.Armor.TYPE.LBracer] = types.Actor.EQUIPMENT_SLOT.LeftGauntlet,
	[types.Armor.TYPE.LGauntlet] = types.Actor.EQUIPMENT_SLOT.LeftGauntlet,
	[types.Armor.TYPE.LPauldron] = types.Actor.EQUIPMENT_SLOT.LeftPauldron,
	[types.Armor.TYPE.RBracer] = types.Actor.EQUIPMENT_SLOT.RightGauntlet,
	[types.Armor.TYPE.RGauntlet] = types.Actor.EQUIPMENT_SLOT.RightGauntlet,
	[types.Armor.TYPE.RPauldron] = types.Actor.EQUIPMENT_SLOT.RightPauldron,
	[types.Armor.TYPE.Shield] = types.Actor.EQUIPMENT_SLOT.CarriedLeft,
}

local ammunitionTypes = {
	[types.Weapon.TYPE.Arrow] = true,
	[types.Weapon.TYPE.Bolt] = true,
}

local function resolveSlot(itemId)
	local clothing = types.Clothing.record(itemId)
	if clothing then
		return clothingSlots[clothing.type], false, clothing.type
	end

	local armor = types.Armor.record(itemId)
	if armor then
		if armor.type == types.Armor.TYPE.Helmet and discovery.isEmptyHead(self) then
			return nil, false, armor.type
		end
		return armorSlots[armor.type], false, armor.type
	end

	local weapon = types.Weapon.record(itemId)
	if weapon then
		if ammunitionTypes[weapon.type] then
			return types.Actor.EQUIPMENT_SLOT.Ammunition, false, weapon.type
		end
		return types.Actor.EQUIPMENT_SLOT.CarriedRight, true, weapon.type
	end

	return nil, false, nil
end

local retryInterval = 0.1
local retryLimit = 50
local retryElapsed = 0
local pendingItemIds = nil
local retriesRemaining = 0
local selectedPoseId = nil
local poseNeedsApply = false
local poseRetryElapsed = 0
local poseWarning = nil

local function sendPlayerMessage(player, message)
	if player then
		player:sendEvent("OAABMannequins_Message", message)
	end
end

local function applySelectedPose(player)
	if not selectedPoseId then
		poseNeedsApply = false
		return true
	end
	local applied, reason = poses.apply(self, selectedPoseId, animation)
	poseNeedsApply = not applied
	if applied then
		poseWarning = nil
		return true
	end
	if player then
		if reason == "unavailable" then
			sendPlayerMessage(player,
				"That pose animation is unavailable. Verify the mod's OpenMW animation files are installed.")
		else
			sendPlayerMessage(player, "The mannequin could not change pose.")
		end
	end
	if poseWarning ~= reason then
		poseWarning = reason
		print(string.format("[OAAB Mannequins] WARNING: could not apply pose %s on %s (%s)",
			selectedPoseId, self.id, tostring(reason)))
	end
	return false
end

local function selectPose(data)
	local profile = discovery.getMannequinProfile(self)
	if not data or not poses.canPose(profile) or not poses.get(data.poseId) then
		return
	end
	selectedPoseId = data.poseId
	poseNeedsApply = true
	poseRetryElapsed = 0
	core.sendGlobalEvent("OAABMannequins_PoseChanged", {
		mannequin = self.object,
		poseId = selectedPoseId,
	})
	applySelectedPose(data.player)
end

local function applyPendingEquipment()
	if not pendingItemIds then
		return true
	end

	local inventory = types.Actor.inventory(self)
	local equipment = {}
	local expectedIds = {}
	local wantsWeaponStance = false
	for _, itemId in ipairs(pendingItemIds) do
		local slot, isWeapon = resolveSlot(itemId)
		if slot then
			local item = inventory:find(itemId)
			if not item then
				retriesRemaining = retriesRemaining - 1
				return false
			end
			equipment[slot] = item
			expectedIds[slot] = itemId
			wantsWeaponStance = wantsWeaponStance or isWeapon
		end
	end

	-- Starting from a complete table also unequips a display item whose final
	-- authoritative stock copy has just been sold.
	types.Actor.setEquipment(self, equipment)
	types.Actor.setStance(self, wantsWeaponStance and types.Actor.STANCE.Weapon or types.Actor.STANCE.Nothing)
	local requestedCount = 0
	local appliedCount = 0
	for slot, itemId in pairs(expectedIds) do
		requestedCount = requestedCount + 1
		local applied = types.Actor.getEquipment(self, slot)
		if applied and applied.recordId and string.lower(applied.recordId) == string.lower(itemId) then
			appliedCount = appliedCount + 1
		end
	end
	if appliedCount == requestedCount then
		print(string.format("[OAAB Mannequins] applied %d equipment slots on %s", appliedCount, self.id))
		pendingItemIds = nil
		if selectedPoseId then
			poseNeedsApply = true
		end
		return true
	end

	retriesRemaining = retriesRemaining - 1
	return false
end

local function finishFailedRefresh()
	if pendingItemIds and retriesRemaining <= 0 then
		print(string.format("[OAAB Mannequins] WARNING: applied %d of %d requested equipment slots on %s",
			0, #pendingItemIds, self.id))
		pendingItemIds = nil
	end
end

local function refreshEquipment(data)
	if not discovery.isMannequin(self) then
		return
	end

	pendingItemIds = {}
	for _, itemId in ipairs(data.itemIds or {}) do
		table.insert(pendingItemIds, itemId)
	end
	retriesRemaining = retryLimit
	retryElapsed = 0
	applyPendingEquipment()
	finishFailedRefresh()
end

return {
	engineHandlers = {
		onLoad = function(data)
			selectedPoseId = poses.get(data and data.poseId) and data.poseId or nil
			poseNeedsApply = selectedPoseId ~= nil
			poseRetryElapsed = 0
		end,
		onSave = function()
			return { poseId = selectedPoseId }
		end,
		onActive = function()
			poseNeedsApply = selectedPoseId ~= nil
			poseRetryElapsed = 0
		end,
		onUpdate = function(dt)
			if pendingItemIds then
				retryElapsed = retryElapsed + dt
				if retryElapsed >= retryInterval then
					retryElapsed = 0
					applyPendingEquipment()
					finishFailedRefresh()
				end
			end

			if selectedPoseId then
				poseRetryElapsed = poseRetryElapsed + dt
				if poseNeedsApply or poseRetryElapsed >= 1 then
					poseRetryElapsed = 0
					if poseNeedsApply or not poses.isPlaying(self, selectedPoseId, animation) then
						applySelectedPose(nil)
					end
				end
			end
		end,
	},
	eventHandlers = {
		OAABMannequins_RefreshEquipment = refreshEquipment,
		OAABMannequins_SetPose = selectPose,
	},
}
