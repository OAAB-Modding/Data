local discovery = require("OAAB.Mannequins.discovery")
local ownership = require("OAAB.Mannequins.ownership")
local pairing = require("OAAB.Mannequins.pairing")

local M = {}

function M.redirectRetailActivation(e)

	if e.activator ~= tes3.player or not discovery.isMannequin(e.target) then
		return
	end
	if tes3.mobilePlayer and tes3.mobilePlayer.isSneaking then
		return
	end

	local proxy = pairing.findLinkedProxy(e.target)
	if not proxy then
		return
	end

	e.block = true
	e.claim = true
	if ownership.hasOwner(proxy) then
		tes3.messageBox({
			message = "You can't use an owned mannequin.",
			showInDialog = false,
		})
		mwse.log("[OAAB Mannequins] refused normal activation of owned mannequin %s",
			pairing.describeReference(e.target))
		return
	end

	-- A paired but unowned proxy is still the authoritative inventory. This is
	-- not part of the retail contract, but retaining the redirect keeps such a
	-- placement usable without exposing the mannequin's display copies.
	local shown = tes3.showContentsMenu({ reference = proxy })
	mwse.log("[OAAB Mannequins] opened unowned stock %s -> %s (shown=%s)",
		pairing.describeReference(e.target), pairing.describeReference(proxy), tostring(shown))
end

function M.verifyContentsSource(e)
	local reference = e.element:getPropertyObject("MenuContents_ObjectRefr")
	if not reference then
		return
	end
	if pairing.getState().byProxy[reference] then
		mwse.log("[OAAB Mannequins] verified MenuContents source: %s",
			pairing.describeReference(reference))
	elseif discovery.isMannequin(reference) and pairing.findLinkedProxy(reference) then
		mwse.log("[OAAB Mannequins] ERROR: retail MenuContents bound to mannequin instead of proxy: %s",
			pairing.describeReference(reference))
	end
end

return M
