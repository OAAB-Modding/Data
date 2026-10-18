local discovery = require("OAAB.Mannequins.discovery")

local M = { apiVersion = 6 }

local namespace = "oaabMannequins"
local poses = {
	{ label = "Relaxed", file = "oaab/k/mann_relax.nif" },
	{ label = "Contrapposto", file = "oaab/k/mann_contrapposto.nif" },
	{ label = "Adlocutio", file = "oaab/k/mann_adlocutio.nif" },
	{ label = "Adlocutio II", file = "oaab/k/mann_adlocutio2.nif" },
}
local registeredPoses = {}
local directPoses = setmetatable({}, { __mode = "k" })
local propRuntime

local function containsProps(node)
	if not node then return false end
	if (node.name or ""):sub(1,#("OAAB Pose Prop ")) == "OAAB Pose Prop " then return true end
	if node:isInstanceOfType(tes3.niType.NiNode) then
		for _,child in pairs(node.children) do if containsProps(child) then return true end end
	end
	return false
end

local function isBone(name)
	name = name and string.lower(name) or ""
	return name == "bip01" or name:match("^bip01 ") or name == "weapon bone" or name == "shield bone"
end

local function findRoot(node)
	if not node then return nil end
	if node.name and string.lower(node.name) == "bip01" then return node end
	if node:isInstanceOfType(tes3.niType.NiNode) then
		for _, child in pairs(node.children) do
			local found = findRoot(child)
			if found then return found end
		end
	end
end

local function boneMap(root)
	local result = {}
	local function visit(node)
		if not node or not node:isInstanceOfType(tes3.niType.NiNode) or not isBone(node.name) then return end
		local name = string.lower(node.name)
		if result[name] then return end
		result[name] = node
		for _, child in pairs(node.children) do visit(child) end
	end
	visit(root)
	return result
end

local function loadDirect(reference, file)
	-- Resolve both loose and BSA assets before loading, so a deleted assignment
	-- does not reach the native loader's missing-file warning/error-marker path.
	if tes3.getFileSource then
		assert(tes3.getFileSource("meshes\\" .. file:gsub("/", "\\")), "Pose NIF could not be found")
	end
	local source = assert(tes3.loadMesh(file, false), "Pose NIF could not be loaded")
	local sourceRoot = assert(findRoot(source), "Pose NIF has no Bip01 skeleton")
	local targetRoot = assert(findRoot(reference.sceneNode), "Mannequin has no Bip01 skeleton")
	local sourceBones, targetBones = boneMap(sourceRoot), boneMap(targetRoot)
	local transforms = {}
	for name, node in pairs(sourceBones) do
		local target = assert(targetBones[name], "Mannequin bone missing: " .. name)
		transforms[#transforms + 1] = {
			node = target,
			translation = node.translation:copy(),
			rotation = node.rotation:copy(),
			scale = node.scale,
		}
	end
	assert(#transforms >= 30, "Pose NIF has an incomplete mannequin skeleton")
	local props
	if containsProps(source) or containsProps(reference.sceneNode) then
		propRuntime = propRuntime or require("OAAB.Mannequins.pose_props")
		props = propRuntime.prepare(source, sourceRoot, targetRoot, targetBones)
	end
	return targetRoot, transforms, props
end

local function applyDirect(entry)
	for _, transform in ipairs(entry.transforms) do
		local node = transform.node
		node.translation = transform.translation:copy()
		node.rotation = transform.rotation:copy()
		node.scale = transform.scale
	end
	entry.root:update()
	-- Body-part meshes can sit outside Bip01. Their skin bounds must be updated
	-- after every bone's world transform is current, including meshes that
	-- precede the skeleton in the actor scene, or posed limbs are frustum-culled
	-- using bounds from the previous pose. Leave controllers disabled.
	entry.scene:update()
end

local function liveReference(key, entry)
	-- A weak Lua key can outlive its native reference. Reading even .deleted on
	-- that userdata throws after pickup; validate the handle before any access.
	if not entry.handle or not entry.handle:valid() then
		directPoses[key] = nil
		return nil
	end
	local reference = entry.handle:getObject()
	if not reference or reference.deleted then
		directPoses[key] = nil
		return nil
	end
	return reference
end

function M.suspend(reference, value)
	local entry = directPoses[reference]
	if not entry and value then
		entry = { handle = tes3.makeSafeObjectHandle(reference) }
		directPoses[reference] = entry
	end
	if entry then
		entry.suspended = value == true
		if not value and not entry.transforms then directPoses[reference] = nil end
	end
end

event.register(tes3.event.simulate, function()
	for key, entry in pairs(directPoses) do
		local reference = liveReference(key, entry)
		if reference and entry.transforms and not entry.suspended
			and reference.sceneNode == entry.scene then
			tes3.skipAnimationFrame({ reference = reference })
		end
	end
end, { priority = 1000 })

event.register(tes3.event.simulated, function()
	for key, entry in pairs(directPoses) do
		local reference = liveReference(key, entry)
		if reference and entry.transforms and not entry.suspended
			and reference.sceneNode == entry.scene then
			applyDirect(entry)
		end
	end
end, { priority = -200 })

-- Public MWSE extension API. The selected NIF path persists with the reference.
function M.registerPose(id, pose)
	assert(type(id) == "string" and id ~= "", "A pose ID is required")
	assert(type(pose) == "table" and type(pose.label) == "string"
		and type(pose.file) == "string", "A pose needs label and file strings")
	registeredPoses[id] = { label = pose.label, file = pose.file }
end

function M.unregisterPose(id)
	registeredPoses[id] = nil
end

-- Snapshot the file-based catalog without needing a mannequin or opening UI.
function M.listPoses()
	local entries = {}
	local function append(pose)
		local copy = {}
		for key, value in pairs(pose) do copy[key] = value end
		table.insert(entries, copy)
	end
	for _, pose in ipairs(poses) do append(pose) end
	local ids = {}
	for id in pairs(registeredPoses) do table.insert(ids, id) end
	table.sort(ids)
	for _, id in ipairs(ids) do append(registeredPoses[id]) end
	return entries
end

local function getState(reference)
	reference.data[namespace] = reference.data[namespace] or {}
	return reference.data[namespace]
end

local function updateLightingAfterPose(reference)
	local handle = tes3.makeSafeObjectHandle(reference)
	event.register(tes3.event.simulated, function()
		if not handle:valid() then
			return
		end
		local current = handle:getObject()
		if not current.sceneNode or current.deleted then
			return
		end
		current:updateLighting()
	end, { doOnce = true })
end

function M.getSelectedFile(reference)
	local state = reference.data and reference.data[namespace]
	if not state then return nil end
	return state.poseFile
end

function M.setSelectedFile(reference, file)
	getState(reference).poseFile = file
	if not file then
		if propRuntime and reference.sceneNode then propRuntime.replace(reference.sceneNode, {}) end
		directPoses[reference] = nil
	end
end

function M.canPose(reference)
	local profile = discovery.getMannequinProfile(reference)
	return profile ~= nil and profile.id == "full"
end

local function apply(reference, allowFallback)
	local file = M.getSelectedFile(reference)
	if not M.canPose(reference) or not reference.sceneNode or not file then
		return false
	end
	local suspended = directPoses[reference] and directPoses[reference].suspended
	-- Native animation replacement fails even for OAAB's stock alternate poses
	-- on mannequin references. Apply the static NIF skeleton to the live actor.
	local ok, root, transforms, props = pcall(loadDirect, reference, file)
	local fellBack = false
	local relaxed = poses[1].file
	if not ok and allowFallback and file:lower():gsub("\\", "/") ~= relaxed then
		local fallbackOK, fallbackRoot, fallbackTransforms, fallbackProps = pcall(loadDirect, reference, relaxed)
		if fallbackOK then
			ok, root, transforms, props = true, fallbackRoot, fallbackTransforms, fallbackProps
			file, fellBack = relaxed, true
		end
	end
	if not ok then
		mwse.log("[OAAB Mannequins] Could not load pose %s: %s", file, tostring(root))
		return false
	end
	local entry = { root = root, scene = reference.sceneNode, transforms = transforms, suspended = suspended,
		handle = tes3.makeSafeObjectHandle(reference) }
	local applied, err = pcall(function()
		applyDirect(entry)
		if props then propRuntime.replace(entry.scene, props) end
	end)
	if not applied then
		mwse.log("[OAAB Mannequins] Could not apply pose %s: %s", file, tostring(err))
		return false
	end
	directPoses[reference] = entry
	-- Commit only after the fallback skeleton and prop cleanup have succeeded.
	-- Persisting Relaxed avoids retrying the missing file on every rebuild/drop.
	if fellBack then M.setSelectedFile(reference, file) end
	updateLightingAfterPose(reference)
	return true
end

function M.apply(reference)
	-- Saved assignments may outlive deleted/uninstalled pose files. Reapply a
	-- usable Relaxed pose without showing a message or logging a handled failure.
	return apply(reference, true)
end

function M.select(reference, file)
	if not M.canPose(reference) or reference.deleted or not reference.sceneNode then return false end
	local previous = M.getSelectedFile(reference)
	M.setSelectedFile(reference, file)
	-- An explicit selection still reports failure and restores the prior pose;
	-- it must not claim that the requested file was selected after a fallback.
	if apply(reference, false) then return true end
	M.setSelectedFile(reference, previous)
	if previous then M.apply(reference) end
	return false
end

-- Saved custom poses can be intentionally replaced without changing their
-- persistent path. Refresh loaded users after the file transaction commits.
-- apply() uses loadMesh(file, false), so every refresh reads the new NIF.
function M.refreshFile(file, except)
	local normalized = file:lower():gsub("\\", "/")
	local references = {}
	for reference in pairs(directPoses) do references[#references + 1] = reference end
	for _, key in ipairs(references) do
		local entry = directPoses[key]
		local reference = entry and liveReference(key, entry)
		local selected = reference and M.getSelectedFile(reference)
		if reference and reference ~= except and selected and selected:lower():gsub("\\", "/") == normalized
			and reference.sceneNode then
			M.apply(reference)
		end
	end
end

local menuId = "OAAB:Mannequins:PoseMenu"

local function showEditableMenu(reference, entries, page, pageSize)
	local handle = tes3.makeSafeObjectHandle(reference)
	-- The native message box may still be closing when Change Pose is chosen.
	timer.frame.delayOneFrame(function()
		if not handle:valid() or not M.canPose(handle:getObject()) then return end
		if handle:getObject().deleted or tes3ui.findMenu(menuId) then return end
		local menu = tes3ui.createMenu({ id = menuId, fixedFrame = true })
		menu.flowDirection = tes3.flowDirection.topToBottom
		menu.childAlignX = 0.5
		menu:createLabel({ text = "Mannequin Pose" }).borderBottom = 6
		local closed = false
		menu:register(tes3.uiEvent.destroy, function() closed = true end)
		local function close()
			if closed then return end
			menu:destroy()
			tes3ui.leaveMenuMode()
		end
		local function run(action)
			if closed then return end
			close()
			timer.frame.delayOneFrame(function()
				if not handle:valid() then return end
				local current = handle:getObject()
				if current.deleted or not M.canPose(current) then return end
				action(current)
			end)
		end
		for index = (page - 1) * pageSize + 1, math.min(page * pageSize, #entries) do
			local entry = entries[index]
			local row = menu:createBlock({})
			row.flowDirection = tes3.flowDirection.leftToRight
			row.autoWidth = true
			row.autoHeight = true
			row.childAlignY = 0.5
			local select = row:createButton({ text = entry.label })
			select.width = 240
			select:register(tes3.uiEvent.mouseClick, function()
				run(function(current)
					if entry.callback then
						entry.callback(current)
					elseif not M.select(current, entry.file) then
						tes3.messageBox("The mannequin pose could not be loaded. Check its animation files.")
					end
				end)
			end)
			if entry.deleteCallback then
				local delete = row:createButton({ text = "X" })
				delete.borderLeft = 4
				delete:register(tes3.uiEvent.mouseClick, function()
					run(function(current) entry.deleteCallback(current, page) end)
				end)
			end
		end
		local navigation = menu:createBlock({})
		navigation.autoWidth = true
		navigation.autoHeight = true
		navigation.flowDirection = tes3.flowDirection.leftToRight
		navigation.borderTop = 6
		if page > 1 then
			navigation:createButton({ text = "Previous" }):register(tes3.uiEvent.mouseClick, function()
				run(function(current) M.showMenu(current, page - 1) end)
			end)
		end
		navigation:createButton({ text = "Cancel" }):register(tes3.uiEvent.mouseClick, close)
		if page * pageSize < #entries then
			navigation:createButton({ text = "Next" }):register(tes3.uiEvent.mouseClick, function()
				run(function(current) M.showMenu(current, page + 1) end)
			end)
		end
		menu:register(tes3.uiEvent.keyPress, function(e)
			if e.data0 == tes3.scanCode.escape then close(); return false end
		end)
		menu:updateLayout()
		tes3ui.enterMenuMode(menuId)
	end)
end

function M.showMenu(reference, page)
	if not M.canPose(reference) then
		return false
	end

	local entries = M.listPoses()
	-- Extensions append {label, file} or {label, callback=function(reference)}.
	-- Optional deleteCallback(reference, page) adds an X beside that entry.
	-- Raised only for full mannequins. No listener is required by OAAB_Data.
	local menuEvent = { reference = reference, entries = entries, handled = false }
	event.trigger("OAAB:mannequinPoseMenu", menuEvent)
	-- Optional UI replacement; with no handler the original menu is unchanged.
	if menuEvent.handled then return true end
	local pageSize = 7
	page = math.max(1, math.min(page or 1, math.ceil(#entries / pageSize)))
	for _, entry in ipairs(entries) do
		if entry.deleteCallback then
			showEditableMenu(reference, entries, page, pageSize)
			return true
		end
	end
	local buttons, actions = {}, {}
	local function add(label, action)
		table.insert(buttons, label)
		table.insert(actions, action)
	end
	for index = (page - 1) * pageSize + 1, math.min(page * pageSize, #entries) do
		local entry = entries[index]
		add(entry.label, function(current)
			if entry.callback then
				entry.callback(current)
			elseif not M.select(current, entry.file) then
				tes3.messageBox("The mannequin pose could not be loaded. Check its animation files.")
			end
		end)
	end
	if page > 1 then add("Previous", function(current) M.showMenu(current, page - 1) end) end
	if page * pageSize < #entries then add("Next", function(current) M.showMenu(current, page + 1) end) end
	table.insert(buttons, "Cancel")
	local handle = tes3.makeSafeObjectHandle(reference)
	tes3.messageBox({
		message = "Mannequin Pose",
		buttons = buttons,
		showInDialog = false,
		callback = function(result)
			local action = actions[result.button + 1]
			if not action or not handle:valid() then return end
			local current = handle:getObject()
			if current.deleted or not M.canPose(current) then return end
			action(current)
		end,
	})
	return true
end

return M
