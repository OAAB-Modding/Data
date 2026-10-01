local discovery = require("OAAB.Mannequins.discovery")

local M = { apiVersion = 2 }

local namespace = "oaabMannequins"
local poses = {
	{ label = "Relaxed", file = "oaab/k/mann_relax.nif" },
	{ label = "Contrapposto", file = "oaab/k/mann_contrapposto.nif" },
	{ label = "Adlocutio", file = "oaab/k/mann_adlocutio.nif" },
	{ label = "Adlocutio II", file = "oaab/k/mann_adlocutio2.nif" },
}
local registeredPoses = {}
local directPoses = setmetatable({}, { __mode = "k" })

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
	return targetRoot, transforms
end

local function applyDirect(entry)
	for _, transform in ipairs(entry.transforms) do
		local node = transform.node
		node.translation = transform.translation:copy()
		node.rotation = transform.rotation:copy()
		node.scale = transform.scale
	end
	entry.root:update()
end

function M.suspend(reference, value)
	local entry = directPoses[reference]
	if not entry and value then
		entry = {}
		directPoses[reference] = entry
	end
	if entry then
		entry.suspended = value == true
		if not value and not entry.transforms then directPoses[reference] = nil end
	end
end

event.register(tes3.event.simulate, function()
	for reference, entry in pairs(directPoses) do
		if entry.transforms and not entry.suspended and not reference.deleted
			and reference.sceneNode == entry.scene then
			tes3.skipAnimationFrame({ reference = reference })
		end
	end
end, { priority = 1000 })

event.register(tes3.event.simulated, function()
	for reference, entry in pairs(directPoses) do
		if entry.transforms and not entry.suspended and not reference.deleted
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
	return state and state.poseFile or nil
end

function M.setSelectedFile(reference, file)
	getState(reference).poseFile = file
	if not file then directPoses[reference] = nil end
end

function M.canPose(reference)
	local profile = discovery.getMannequinProfile(reference)
	return profile ~= nil and profile.id == "full"
end

function M.apply(reference)
	local file = M.getSelectedFile(reference)
	if not M.canPose(reference) or not reference.sceneNode or not file then
		return false
	end
	local suspended = directPoses[reference] and directPoses[reference].suspended
	-- Native animation replacement fails even for OAAB's stock alternate poses
	-- on mannequin references. Apply the static NIF skeleton to the live actor.
	local ok, root, transforms = pcall(loadDirect, reference, file)
	if not ok then
		mwse.log("[OAAB Mannequins] Could not load pose %s: %s", file, tostring(root))
		return false
	end
	local entry = { root = root, scene = reference.sceneNode, transforms = transforms, suspended = suspended }
	local applied, err = pcall(applyDirect, entry)
	if not applied then
		mwse.log("[OAAB Mannequins] Could not apply pose %s: %s", file, tostring(err))
		return false
	end
	directPoses[reference] = entry
	updateLightingAfterPose(reference)
	return true
end

function M.select(reference, file)
	if not M.canPose(reference) or reference.deleted or not reference.sceneNode then return false end
	local previous = M.getSelectedFile(reference)
	M.setSelectedFile(reference, file)
	if M.apply(reference) then return true end
	M.setSelectedFile(reference, previous)
	if previous then M.apply(reference) end
	return false
end

function M.showMenu(reference, page)
	if not M.canPose(reference) then
		return false
	end

	local entries = {}
	for _, pose in ipairs(poses) do
		table.insert(entries, { label = pose.label, file = pose.file })
	end
	local ids = {}
	for id in pairs(registeredPoses) do table.insert(ids, id) end
	table.sort(ids)
	for _, id in ipairs(ids) do table.insert(entries, registeredPoses[id]) end
	-- Extensions append {label, file} or {label, callback=function(reference)}.
	-- Raised only for full mannequins. No listener is required by OAAB_Data.
	event.trigger("OAAB:mannequinPoseMenu", { reference = reference, entries = entries })
	local pageSize = 7
	page = math.max(1, math.min(page or 1, math.ceil(#entries / pageSize)))
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
