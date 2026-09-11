local discovery = require("OAAB.Mannequins.discovery")
local pairing = require("OAAB.Mannequins.pairing")
local retail = require("OAAB.Mannequins.retail")
local activation = require("OAAB.Mannequins.activation")
local bodyparts = require("OAAB.Mannequins.bodyparts")
local equipment = require("OAAB.Mannequins.equipment")
local interaction = require("OAAB.Mannequins.interaction")
local pickup = require("OAAB.Mannequins.pickup")
local poses = require("OAAB.Mannequins.poses")

local M = {}
local warned = {}

local function log(message)
	mwse.log("[OAAB Mannequins] " .. message)
end

local function warningKey(reference, reason)
	local cell = reference.cell
	return string.format("%s|%s|%s", reference.id or "unknown", cell and cell.editorName or "unknown", reason)
end

function M.rebuildPairings()
	local cells = tes3.getActiveCells()
	local state = pairing.rebuild(cells)
	retail.refreshAll(state, true, "rebuildPairings")
	for _, cell in pairs(cells) do
		for reference in cell:iterateReferences(tes3.objectType.npc, false) do
			if discovery.isMannequin(reference) then
				poses.apply(reference)
				equipment.refreshWeaponState(reference)
			end
		end
	end
	for reference, reason in pairs(state.ambiguous) do
		local key = warningKey(reference, reason)
		if not warned[key] then
			warned[key] = true
			log(string.format("WARNING: Ambiguous stock proxies near mannequin %s; mannequin left unpaired (%s).",
				pairing.describeReference(reference), reason))
		end
	end
	return state
end

function M.getMannequinProfile(reference)
	return discovery.getMannequinProfile(reference)
end

function M.findLinkedProxy(reference)
	return pairing.findLinkedProxy(reference)
end

event.register(tes3.event.cellChanged, function()
	M.rebuildPairings()
end)

-- The proxy remains a normal container. This timer only keeps its mannequin
-- display current when an inventory change has no dedicated close event.
--
-- It has to be started here rather than at file scope: MWSE cancels every active
-- timer immediately before the loaded event fires, so a timer created when the mod
-- initialises is destroyed the moment a save is loaded and never runs during play.
-- Simulate timers pause while a menu is open and resume after it closes.
local function startRefreshTimer()
	timer.start({
		type = timer.simulate,
		duration = 5,
		iterations = -1,
		persist = false,
		callback = function()
			retail.refreshAll(pairing.getState(), false, "safetyTimer")
		end,
	})
end

event.register(tes3.event.loaded, function()
	M.rebuildPairings()
	startRefreshTimer()
end)

event.register(tes3.event.activate, interaction.handleActivate, { priority = 200 })

event.register(tes3.event.activate, activation.redirectRetailActivation, { priority = 100 })

-- Profile-driven BODY-part suppression: stand mannequins hide lower-body
-- geometry, empty-head mannequins hide helmets. Applies to decorative
-- mannequins too, so it is registered here rather than inside retail.
event.register(tes3.event.bodyPartAssigned, bodyparts.filterBodyPart)

event.register(tes3.event.bodyPartsUpdated, bodyparts.ensureStandSupport)
event.register(tes3.event.bodyPartsUpdated, equipment.handleBodyPartsUpdated)

event.register(tes3.event.containerClosed, function(e)
	retail.handleContainerClosed(e, pairing.getState(), timer.frame.delayOneFrame)
end)

-- Vanilla has committed barter and every other menu-side inventory change by the
-- time menu mode ends. Refresh synchronously here: barterOffer fires too early,
-- while the proxy can still report its pre-transaction stock to Lua.
event.register(tes3.event.menuExit, function()
	retail.refreshAll(pairing.getState(), false, "menuExit")
end)

event.register(tes3.event.uiActivated, activation.verifyContentsSource, { filter = "MenuContents" })

for _, portableId in ipairs(discovery.portableIds) do
	-- Native object-event filters are lowercased; string registrations are not.
	local portableFilter = string.lower(portableId)
	event.register(tes3.event.itemDropped, function(e)
		local placed = pickup.place(e.reference)
		if placed then
			timer.frame.delayOneFrame(M.rebuildPairings)
		end
	end, { filter = portableFilter })
end

return M
