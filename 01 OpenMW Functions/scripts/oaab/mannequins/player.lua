local core = require("openmw.core")
local nearby = require("openmw.nearby")
local self = require("openmw.self")
local ui = require("openmw.ui")
local async = require("openmw.async")
local util = require("openmw.util")
local interfaces = require("openmw.interfaces")

local discovery = require("scripts.oaab.mannequins.discovery")
local pairing = require("scripts.oaab.mannequins.pairing")
local poses = require("scripts.oaab.mannequins.poses")

local refreshInterval = 1
local elapsed = refreshInterval
local previousCellId = nil
local previousSneak = nil
local warned = {}
local menuElement = nil
local menuModeActive = false
local current = {
	byMannequin = {},
	byProxy = {},
	ambiguous = {},
}

local function logWarning(entry)
	local object = entry.object
	local cellName = object.cell and object.cell.displayName or "unknown cell"
	local key = string.format("%s|%s|%s", object.id, cellName, entry.reason)
	if warned[key] then
		return
	end
	warned[key] = true
	print(string.format("[OAAB Mannequins] WARNING: Ambiguous stock proxies near mannequin %s at %s; left unpaired (%s).",
		object.recordId, cellName, entry.reason))
end

local function rebuildPairings(force)
	local mannequins = {}
	local proxies = {}

	for _, actor in ipairs(nearby.actors) do
		if discovery.isMannequin(actor) then
			table.insert(mannequins, actor)
		end
	end
	for _, container in ipairs(nearby.containers) do
		if discovery.isStockProxy(container) then
			table.insert(proxies, container)
		end
	end

	current = pairing.build(mannequins, proxies)
	for _, entry in pairs(current.ambiguous) do
		logWarning(entry)
	end
	local pairedReferences = {}
	for _, pair in pairs(current.byMannequin) do
		table.insert(pairedReferences, {
			mannequin = pair.mannequin,
			proxy = pair.proxy,
		})
	end
	if force then
		print(string.format("[OAAB Mannequins] found %d paired retail mannequin(s) in %s",
			#pairedReferences, self.cell and self.cell.displayName or "unknown cell"))
	end
	core.sendGlobalEvent("OAABMannequins_PairingsUpdated", {
		force = force == true,
		mannequins = mannequins,
		pairs = pairedReferences,
	})
end

local function closeMenu()
	if menuElement then
		menuElement:destroy()
		menuElement = nil
	end
	if menuModeActive then
		menuModeActive = false
		interfaces.UI.removeMode(interfaces.UI.MODE.Interface)
	end
end

local function button(label, callback)
	return {
		template = interfaces.MWUI.templates.box,
		events = {
			mouseClick = async:callback(callback),
		},
		content = ui.content({
			{
				template = interfaces.MWUI.templates.padding,
				content = ui.content({
					{
						template = interfaces.MWUI.templates.textNormal,
						props = { text = label },
					},
				}),
			},
		}),
	}
end

local function createMenu(title, choices)
	menuElement = ui.create({
		-- OpenMW's native interactive messagebox layouts use the Modal layer.
		layer = "Modal",
		type = ui.TYPE.Container,
		props = {
			relativePosition = util.vector2(0.5, 0.5),
			anchor = util.vector2(0.5, 0.5),
		},
		content = ui.content({
			{
				template = interfaces.MWUI.templates.boxSolid,
				content = ui.content({
					{
						template = interfaces.MWUI.templates.padding,
						content = ui.content({
							{
								type = ui.TYPE.Flex,
								props = { arrange = ui.ALIGNMENT.Center },
								content = ui.content({
									{
										template = interfaces.MWUI.templates.textHeader,
										props = { text = title },
									},
									{ template = interfaces.MWUI.templates.interval },
									unpack(choices),
								}),
							},
						}),
					},
				}),
			},
		}),
	})
	-- Lua-created message boxes do not enter menu mode by themselves. Use an
	-- empty Interface mode so OpenMW exposes the cursor, routes input to the
	-- buttons, and applies its normal menu pause behavior without opening
	-- inventory panes.
	if not menuModeActive then
		interfaces.UI.addMode(interfaces.UI.MODE.Interface, { windows = {} })
		menuModeActive = true
	end
end

local function showPoseMenu(data)
	if not data or not data.mannequin or data.owned or not data.canPose then
		return
	end
	-- Replace the first panel without leaving menu mode. Removing and immediately
	-- re-adding Interface mode can deliver a delayed UiModeChanged event that
	-- closes the newly created pose panel.
	if menuElement then
		menuElement:destroy()
		menuElement = nil
	end

	local choices = {}
	for _, pose in ipairs(poses.options) do
		local selected = pose
		table.insert(choices, button(selected.label, function()
			closeMenu()
			data.mannequin:sendEvent("OAABMannequins_SetPose", {
				poseId = selected.id,
				player = self.object,
			})
		end))
	end
	table.insert(choices, { template = interfaces.MWUI.templates.interval })
	table.insert(choices, button("Cancel", closeMenu))
	createMenu("Mannequin Pose", choices)
end

local function showMenu(data)
	closeMenu()
	if not data or not data.mannequin then
		return
	end

	local function choose(action)
		closeMenu()
		if action then
			core.sendGlobalEvent("OAABMannequins_Action", {
				action = action,
				mannequin = data.mannequin,
				player = self.object,
			})
		end
	end

	local choices = {}
	if data.owned then
		table.insert(choices, button("Steal Mannequin", function() choose("steal") end))
	else
		if data.canPose then
			table.insert(choices, button("Change Pose", function()
				showPoseMenu(data)
			end))
		end
		table.insert(choices, button("Pick Up", function() choose("pickup") end))
	end
	table.insert(choices, { template = interfaces.MWUI.templates.interval })
	table.insert(choices, button("Cancel", function() choose(nil) end))
	createMenu("Mannequin", choices)
end

local function syncSneak(force)
	local sneaking = self.controls.sneak == true
	if force or sneaking ~= previousSneak then
		previousSneak = sneaking
		core.sendGlobalEvent("OAABMannequins_SneakChanged", {
			player = self.object,
			sneaking = sneaking,
		})
	end
end

return {
	engineHandlers = {
		onActive = function()
			syncSneak(true)
			rebuildPairings(true)
		end,
		onInactive = closeMenu,
		onUpdate = function(dt)
			syncSneak(false)
			local cellId = self.cell and self.cell.id or nil
			elapsed = elapsed + dt
			if cellId ~= previousCellId or elapsed >= refreshInterval then
				local cellChanged = cellId ~= previousCellId
				previousCellId = cellId
				elapsed = 0
				rebuildPairings(cellChanged)
			end
		end,
	},
	eventHandlers = {
		OAABMannequins_ShowMenu = showMenu,
		OAABMannequins_Message = function(message)
			ui.showMessage(message, { showInDialogue = false })
		end,
		UiModeChanged = function(data)
			-- Escape removes the engine mode before this event reaches us. Destroy
			-- the now-orphaned Lua window without trying to remove the mode again.
			if menuElement and menuModeActive
				and (not data or data.newMode ~= interfaces.UI.MODE.Interface) then
				menuModeActive = false
				closeMenu()
			end
		end,
	},
}
