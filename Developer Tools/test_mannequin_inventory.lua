-- Run from the repository root with Lua 5.1 or later. These checks assert that
-- Inventory invokes native activation; they do not simulate native transfers.
local mwsePath = '01 MWSE Functions/mwse/mods/oaab/mannequins/'
local tests = 0
local function check(name, fn)
    fn()
    tests = tests + 1
    print('PASS ' .. name)
end
local function loadModule(path, name, prefix)
    local module = assert(loadfile(path .. name .. '.lua'))()
    package.loaded[prefix .. name] = module
    return module
end
local function forbidden() error('Non-retail inventory/equipment handling was invoked') end
local vectorMethods = {
    __sub = function(a, b) return { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z } end,
}
local function position(x) return setmetatable({ x = x, y = 0, z = 0 }, vectorMethods) end
local cell = { id = 'test', editorName = 'test', displayName = 'test' }
local mannequins, proxies = {}, {}
local function mannequin(id, x)
    return {
        id = id, recordId = id, kind = 'npc', position = position(x), cell = cell,
        baseObject = { id = id, objectType = 'npc', class = { id = 'ab_mannequinclassfull' } },
        record = { class = 'ab_mannequinclassfull', isMale = true, head = 'headed' },
        data = {}, object = { inventory = setmetatable({}, { __index = forbidden }), reevaluateEquipment = forbidden },
        mobile = { equip = forbidden, unequip = forbidden }, updateEquipment = forbidden,
    }
end
local function proxy(id, x)
    return {
        id = id, position = position(x), cell = cell, owner = {},
        baseObject = { id = id, objectType = 'container', script = { id = 'ab_mannstockproxy_s' } },
    }
end
cell.iterateReferences = function(_, objectType)
    local entries = objectType == 'npc' and mannequins or proxies
    local i = 0
    return function() i = i + 1; return entries[i] end
end
local callbacks, messages, timerCallback = {}, {}, nil
local posesShown, pickups = 0, 0
local deferred, nativeActivations = {}, 0
local player = { id = 'player', kind = 'player' }
tes3 = {
    player = player, mobilePlayer = { isSneaking = false },
    objectType = { npc = 'npc', container = 'container' },
    event = setmetatable({}, { __index = function(_, key) return key end }),
    getOwner = function(options) return options.reference.owner.recordId end,
    getActiveCells = function() return { cell } end,
    messageBox = function(options) table.insert(messages, options) end,
    showContentsMenu = forbidden, addItem = forbidden, removeItem = forbidden,
    addItemData = forbidden, getItemCount = forbidden,
    makeSafeObjectHandle = function(reference)
        return { valid = function() return not reference.deleted end,
            getObject = function() return reference end }
    end,
}
-- Native NPC references have no stock-container owner field.
local function ownerlessNpc(npc) npc.owner = {}; return npc end
mwse = { log = function() end }
event = { register = function(name, fn)
    callbacks[name] = callbacks[name] or {}
    table.insert(callbacks[name], fn)
end }
timer = {
    frame = { delayOneFrame = forbidden },
    start = function(options) timerCallback = options.callback end,
    delayOneFrame = function(fn) table.insert(deferred, fn) end,
}
local function fire(name, data)
    for _, callback in ipairs(callbacks[name] or {}) do
        callback(data or {})
        if data and data.claim then break end
    end
end
player.activate = function(self, target)
    assert(self == player)
    local nativeEvent = { activator = self, target = target }
    local messageCount = #messages
    fire('activate', nativeEvent)
    assert(nativeEvent.block == nil and nativeEvent.claim == nil and #messages == messageCount)
    nativeActivations = nativeActivations + 1
end
local prefix = 'OAAB.Mannequins.'
local discovery = loadModule(mwsePath, 'discovery', prefix)
loadModule(mwsePath, 'ownership', prefix)
local pairingMWSE = loadModule(mwsePath, 'pairing', prefix)
package.loaded[prefix .. 'poses'] = {
    canPose = function() return true end, apply = function() end,
    showMenu = function() posesShown = posesShown + 1 end,
}
package.loaded[prefix .. 'pickup'] = {
    pickUp = function() pickups = pickups + 1 end, portableValue = function() return 100 end,
}
package.loaded[prefix .. 'bodyparts'] = { filterBodyPart = function() end, ensureStandSupport = function() end }
local equipment = loadModule(mwsePath, 'equipment', prefix)
local retail = loadModule(mwsePath, 'retail', prefix)
local activationModule = loadModule(mwsePath, 'activation', prefix)
loadModule(mwsePath, 'interaction', prefix)
loadModule(mwsePath, 'main', prefix)
local near = ownerlessNpc(mannequin('nearest', 1))
local other = ownerlessNpc(mannequin('ordinary', 10))
local firstProxy, secondProxy = proxy('first', 0), proxy('second', 3)
firstProxy.owner.recordId, secondProxy.owner.recordId = 'merchant', 'merchant'
mannequins, proxies = { near, other }, { firstProxy, secondProxy }
check('MWSE proxy affects only its closest mannequin, with no fallback', function()
    local state = pairingMWSE.rebuild({ cell })
    assert(state.byProxy[firstProxy] == near and state.byProxy[secondProxy] == nil)
    assert(state.byMannequin[other] == nil)
end)
check('MWSE normal activation opens the mannequin menu with Inventory', function()
    local activation = { activator = player, target = other }
    fire('activate', activation)
    assert(activation.block and activation.claim and #messages == 1)
    assert(messages[1].buttons[1] == 'Inventory')
end)
check('MWSE Inventory activates only the NPC, without inventory/equipment handling', function()
    messages[1].callback({ button = 0 })
    assert(#deferred == 1 and nativeActivations == 0)
    deferred[1](); deferred = {}
    assert(nativeActivations == 1 and not activationModule.isInventoryActivation(other))
    local activation = { activator = player, target = other }
    fire('activate', activation)
    assert(activation.block and messages[#messages].buttons[1] == 'Inventory')
end)
check('MWSE ordinary inventory close does not schedule any work', function()
    fire('containerClosed', { reference = other })
    fire('bodyPartsUpdated', { reference = other })
    assert(equipment.handleContainerClosed == nil)
end)
check('MWSE unowned proxy and saved retail data cause no inventory handling', function()
    firstProxy.owner.recordId, secondProxy.owner.recordId = nil, nil
    other.data.oaabMannequins = { retailDisplayIds = { 'old_shirt' }, retailProxyKey = 'old' }
    fire('loaded')
    fire('menuExit')
    assert(timerCallback); timerCallback()
    fire('containerClosed', { reference = firstProxy })
    assert(other.data.oaabMannequins.retailDisplayIds[1] == 'old_shirt')
    local activation = { activator = player, target = near }
    local messageCount = #messages
    fire('activate', activation)
    assert(activation.block and #messages == messageCount + 1 and messages[#messages].buttons[1] == 'Inventory')
end)
check('MWSE normal menu retains poses and pickup without sneaking', function()
    local activation = { activator = player, target = other }
    fire('activate', activation)
    assert(activation.block and activation.claim)
    local menu = messages[#messages]
    assert(menu.buttons[1] == 'Inventory' and menu.buttons[2] == 'Change Pose' and menu.buttons[3] == 'Pick Up')
    menu.callback({ button = 1 }); menu.callback({ button = 2 })
    assert(posesShown == 1 and pickups == 1)
end)
check('MWSE nearest retail mannequin still intercepts activation', function()
    firstProxy.owner.recordId = 'merchant'
    pairingMWSE.rebuild({ cell })
    local activation = { activator = player, target = near }
    fire('activate', activation)
    assert(activation.block and messages[#messages].buttons[1] == 'Steal Mannequin')
    assert(not activationModule.openInventory(near))
end)
check('MWSE nearest ties remain unpaired', function()
    mannequins, proxies = { ownerlessNpc(mannequin('left', -1)), ownerlessNpc(mannequin('right', 1)) }, { firstProxy }
    local state = pairingMWSE.rebuild({ cell })
    assert(next(state.byMannequin) == nil and state.ambiguous[firstProxy])
end)
check('MWSE independent nearest pairs at equal distances remain paired', function()
    local left, right = ownerlessNpc(mannequin('left', 1)), ownerlessNpc(mannequin('right', 3))
    local rightProxy = proxy('right_stock', 4)
    mannequins, proxies = { left, right }, { firstProxy, rightProxy }
    local state = pairingMWSE.rebuild({ cell })
    assert(state.byProxy[firstProxy] == left and state.byProxy[rightProxy] == right)
end)
check('MWSE custom-ID portable matching remains available', function()
    for _, female in ipairs({ false, true }) do
        other.baseObject.female = female
        assert(discovery.getPortableId(other) == 'AB_Furn_MannequinHead' .. (female and 'F' or 'M'))
    end
end)

-- Pickup converts custom IDs to existing OAAB portable/NPC pairs.
local portableCases = {
    { 'stand', true, 'headed', 'AB_Furn_Mannequin2F', 'ab_mannequin2f' },
    { 'stand', false, 'headed', 'AB_Furn_Mannequin2M', 'ab_mannequin2m' },
    { 'full', true, 'headed', 'AB_Furn_MannequinHeadF', 'ab_mannequinheadf' },
    { 'full', false, 'headed', 'AB_Furn_MannequinHeadM', 'ab_mannequinheadm' },
    { 'full', true, 'ab_b_mann_hd02_f', 'AB_Furn_MannequinHeadlessF', 'ab_mannequinheadlessf' },
    { 'full', false, 'ab_b_mann_hd02_m', 'AB_Furn_MannequinHeadlessM', 'ab_mannequinheadlessm' },
}
local records, addedItemData = {}, nil
for _, case in ipairs(portableCases) do
    records[string.lower(case[4])] = { id = case[4], objectType = 'misc' }
    records[case[5]] = { id = case[5], objectType = 'npc' }
end
tes3.getObject = function(id) return records[string.lower(id)] end
tes3.addItem = function(options)
    local item = assert(records[string.lower(options.item)])
    addedItemData = { data = {} }
    return options.count, item, addedItemData
end
tes3.createReference = function(options)
    return {
        baseObject = options.object, object = { inventory = { items = {} } }, data = {},
        delete = function(self) self.deleted = true end,
    }
end
timer.frame.delayOneFrame = function(fn) fn() end
package.loaded[prefix .. 'retail'] = { clearDisplay = function() return true end, hasRealItems = function() return false end }
package.loaded[prefix .. 'poses'] = { getSelectedFile = function() return 'saved_pose.nif' end, apply = function() end }
local pickup = loadModule(mwsePath, 'pickup', prefix)
local function portableReference(item, state)
    return {
        baseObject = item, data = state and { oaabMannequins = state } or {},
        cell = cell, stackSize = 1, position = position(0), orientation = {}, scale = 1,
        delete = function(self) self.deleted = true end,
    }
end
for index, case in ipairs(portableCases) do
    check('MWSE custom pickup converts to the standard OAAB pair: ' .. case[4], function()
        local source = mannequin('custom_copy_' .. index, 0)
        source.baseObject.class.id = case[1] == 'stand' and 'ab_mannequinclassstand' or 'ab_mannequinclassfull'
        source.baseObject.female, source.baseObject.head = case[2], { id = case[3] }
        source.delete = function(self) self.deleted = true end
        local ok, item = pickup.pickUp(source)
        assert(ok and source.deleted and item == records[string.lower(case[4])])
        local saved = addedItemData.data.oaabMannequins
        assert(saved.baseId == nil and saved.poseFile == 'saved_pose.nif')
        local portable = portableReference(item, saved)
        local placed = assert(pickup.place(portable))
        assert(portable.deleted and placed.baseObject == records[case[5]])
        assert(placed.data.oaabMannequins.poseFile == 'saved_pose.nif')
    end)
end
check('MWSE older saved custom IDs also place the standard OAAB NPC', function()
    local item = records[string.lower(portableCases[3][4])]
    local portable = portableReference(item, {
        kind = 'portableMannequin', baseId = 'missing_custom_record', poseFile = 'legacy_pose.nif',
    })
    local placed = assert(pickup.place(portable))
    assert(portable.deleted and placed.baseObject == records[portableCases[3][5]])
    assert(placed.data.oaabMannequins.poseFile == 'legacy_pose.nif')
end)
check('MWSE missing standard NPC preserves the portable item', function()
    local case = portableCases[1]
    local base = records[case[5]]
    records[case[5]] = nil
    local portable = portableReference(records[string.lower(case[4])])
    assert(not pickup.place(portable) and not portable.deleted)
    records[case[5]] = base
end)
print(string.format('%d MWSE mannequin regression checks passed.', tests))
