local discovery = require("OAAB.Mannequins.discovery")

local M = {}

-- AB_b_Mann2_ul is the stand's long centre support. Vanilla equipment layering
-- removes its base-layer upper-leg assignment when a skirt occupies the groin
-- layer, even though the skirt has no upper-leg BODY entries of its own. Keep a
-- fallback copy in an otherwise suppressed ankle location on the garment's
-- clothing layer so the support and a hanging garment can render at the same
-- time.
local standSupportBodyPartId = "AB_b_Mann2_ul"

-- Render-level BODY-part suppression for mannequin profiles.
--
-- This runs for every mannequin, retail or decorative, because it is a property
-- of the mannequin's Class and head record rather than of its stock source. The
-- item stays equipped and stays in inventory; only the geometry is blocked, so
-- third-party clothing that mixes chest and leg BODY entries still renders its
-- upper half.
-- Only geometry that comes from a worn ITEM may be suppressed.
--
-- A stand mannequin's own base is authored as ordinary lower-body BODY records, so
-- it is assigned to exactly the slots the stand profile suppresses. Filtering by
-- slot alone therefore erases the stand itself along with any pants, which is what
-- made stand mannequins render with nothing below the waist.
local function isWornItem(object)
	if not object or not tes3 or not tes3.objectType then
		return false
	end
	return object.objectType == tes3.objectType.clothing
		or object.objectType == tes3.objectType.armor
end

-- Garments that hang rather than wrap a leg still read correctly on a legless
-- stand, so they are exempt from lower-body suppression.
--
-- Without this a skirt disappears: a skirt and a pair of trousers both render
-- through the groin and upper-leg slots, so the body-part index alone cannot tell
-- them apart. The user-facing rule is "no pants or shoes", not "nothing below the
-- waist", and that distinction lives on the item, not the slot.
local function hangsFreely(object)
	if not object or not tes3 or not tes3.objectType
		or object.objectType ~= tes3.objectType.clothing then
		return false
	end
	local slots = tes3.clothingSlot
	if not slots then
		return false
	end
	return object.slot == slots.skirt or object.slot == slots.robe
end

function M.filterBodyPart(e)
	local profile = discovery.getMannequinProfile(e.reference)
	if not profile then
		return
	end

	if profile.id == "stand"
		and discovery.getStandSuppressedParts()[e.index]
		and isWornItem(e.object)
		and not hangsFreely(e.object) then
		return false
	end

	-- Plan 9: a helmet may sit in inventory, but an empty-head mannequin must
	-- never render it. The mannequin's own empty head record is not an armor
	-- item, so it passes through untouched.
	if e.index == tes3.activeBodyPart.head
		and discovery.isHelmet(e.object)
		and discovery.isEmptyHead(e.reference) then
		return false
	end
end

-- Used by the retail equip loop so an empty-head mannequin never equips a
-- helmet in the first place. Decorative mannequins are equipped by the engine
-- and rely on filterBodyPart alone.
function M.shouldEquip(reference, item)
	if discovery.isHelmet(item) and discovery.isEmptyHead(reference) then
		return false
	end
	return true
end

local function activeBodyPartMatches(manager, index)
	local layers = tes3 and tes3.activeBodyPartLayer
	if not manager or not layers or index == nil then
		return false
	end
	for _, layer in pairs(layers) do
		if type(layer) == "number" then
			local active = manager:getActiveBodyPart(layer, index)
			local bodyPart = active and active.bodyPart
			if bodyPart and bodyPart.id
				and string.lower(bodyPart.id) == string.lower(standSupportBodyPartId) then
				return true
			end
		end
	end
	return false
end

local function getSupportSource(reference)
	-- setBodyPartByIdForObject requires an inventory item, not the NPC base.
	-- Bind the support to the hanging garment whose layer displaced it. When the
	-- garment is removed, vanilla rebuilds the base pole normally.
	for _, stack in pairs(reference.object and reference.object.equipment or {}) do
		if stack.object and hangsFreely(stack.object) then
			return stack.object
		end
	end
	return nil
end

-- bodyPartsUpdated fires after the engine has resolved all clothing layers. At
-- that point we can tell whether the stand support survived. If it did not, put
-- the same BODY record in the hanging garment's right-ankle location. Worn ankle
-- geometry is filtered above, so the fallback cannot leak boots onto the stand.
function M.ensureStandSupport(e)
	local reference = e and e.reference
	local profile = discovery.getMannequinProfile(reference)
	if not profile or profile.id ~= "stand" then
		return false
	end

	local parts = tes3 and tes3.activeBodyPart
	local manager = reference and reference.bodyPartManager
	if not parts or not manager then
		return false
	end

	if activeBodyPartMatches(manager, parts.rightUpperLeg)
		or activeBodyPartMatches(manager, parts.rightAnkle) then
		return false
	end
	local source = getSupportSource(reference)
	if not source then
		return false
	end

	manager:setBodyPartByIdForObject(
		source,
		parts.rightAnkle,
		standSupportBodyPartId,
		false
	)
	e.updated = true
	return true
end

return M
