local discovery = require("OAAB.Mannequins.discovery")
local ownership = require("OAAB.Mannequins.ownership")
local pairing = require("OAAB.Mannequins.pairing")

local M = {}
local inventoryActivation

function M.isInventoryActivation(reference)
	return inventoryActivation == reference
end

function M.openInventory(reference)
	if not reference or reference.deleted or not discovery.isMannequin(reference)
		or ownership.hasOwner(pairing.findLinkedProxy(reference)) then
		return false
	end

	-- Native activation opens the NPC's inventory and lets the engine handle
	-- equipment. Bypass our menu only for this synchronous activation call.
	inventoryActivation = reference
	local ok, err = pcall(function() tes3.player:activate(reference) end)
	inventoryActivation = nil
	if not ok then error(err) end
	return true
end

function M.redirectRetailActivation(e)
	if e.activator ~= tes3.player or not discovery.isMannequin(e.target) then
		return
	end
	if not ownership.hasOwner(pairing.findLinkedProxy(e.target)) then
		return
	end

	e.block = true
	e.claim = true
	tes3.messageBox({ message = "You can't use an owned mannequin.", showInDialog = false })
end

function M.verifyContentsSource(e)
	local reference = e.element:getPropertyObject("MenuContents_ObjectRefr")
	if not reference then
		return
	end
	if pairing.getState().byProxy[reference] then
		mwse.log("[OAAB Mannequins] verified MenuContents source: %s",
			pairing.describeReference(reference))
	elseif discovery.isMannequin(reference)
		and ownership.hasOwner(pairing.findLinkedProxy(reference)) then
		mwse.log("[OAAB Mannequins] ERROR: retail MenuContents bound to mannequin instead of proxy: %s",
			pairing.describeReference(reference))
	end
end

return M
