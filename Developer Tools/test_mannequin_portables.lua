-- Run from the repository root with Lua 5.1 (the MWSE language version).
-- Engine doubles exercise inventory conservation and the actual event routes;
-- rendering, barter UI and save serialization still require in-game checks.
local mwsePath = "01 MWSE Functions/mwse/mods/oaab/mannequins/"
local openmwPath = "01 OpenMW Functions/scripts/oaab/mannequins/"
local cases = {
    { "AB_Furn_Mannequin2F", "ab_mannequin2f" },
    { "AB_Furn_Mannequin2M", "ab_mannequin2m" },
    { "AB_Furn_MannequinHeadF", "ab_mannequinheadf" },
    { "AB_Furn_MannequinHeadM", "ab_mannequinheadm" },
    { "AB_Furn_MannequinHeadlessF", "ab_mannequinheadlessf" },
    { "AB_Furn_MannequinHeadlessM", "ab_mannequinheadlessm" },
}
local tests = 0
local function check(name, fn)
    fn()
    tests = tests + 1
    print("PASS " .. name)
end
local function load(path) return assert(loadfile(path))() end
local function install(name, value) package.loaded[name] = value end

-- MWSE ----------------------------------------------------------------------
local created, deferred, failAt, failInventory, poseCalls
local function resetMWSE()
    created, deferred, poseCalls = {}, {}, {}
    failAt, failInventory = nil, false
end
local bases = {}
for _, case in ipairs(cases) do
    bases[case[2]] = { id = case[2], objectType = "npc" }
end
bases.custom_mannequin = { id = "custom_mannequin", objectType = "npc" }
tes3 = {
    objectType = { npc = "npc" },
    getObject = function(id) return bases[id] end,
    messageBox = function() end,
    getActiveCells = function() return {} end,
    event = setmetatable({}, { __index = function(_, key) return key end }),
    createReference = function(options)
        if failAt == #created + 1 then error("injected spawn failure") end
        local npc = {
            baseObject = options.object, data = {},
            position = options.position, orientation = options.orientation,
            cell = options.cell, scale = options.scale,
            object = { inventory = { items = { { object = { id = "authored_shirt" }, count = 2 } } } },
            delete = function(self) self.deleted = true end,
        }
        table.insert(created, npc)
        return npc
    end,
    removeItem = function(options)
        if failInventory then return 0 end
        options.reference.object.inventory.items = {}
        return options.count
    end,
}
timer = { frame = { delayOneFrame = function(fn) table.insert(deferred, fn) end } }
mwse = { log = function() end }
local callbacks = {}
event = { register = function(name, fn, options)
    if name == "itemDropped" then callbacks[options.filter] = fn end
end }
local discoveryMWSE = load(mwsePath .. "discovery.lua")
install("OAAB.Mannequins.discovery", discoveryMWSE)
install("OAAB.Mannequins.poses", { apply = function(npc) table.insert(poseCalls, npc) end })
install("OAAB.Mannequins.retail", { refreshAll = function() end })
install("OAAB.Mannequins.pairing", { rebuild = function() return { ambiguous = {} } end })
for _, module in ipairs({ "activation", "bodyparts", "equipment", "interaction" }) do
    install("OAAB.Mannequins." .. module, {})
end
local pickupMWSE = load(mwsePath .. "pickup.lua")
install("OAAB.Mannequins.pickup", pickupMWSE)
load(mwsePath .. "main.lua")
local function portableMWSE(id, count, saved)
    return {
        baseObject = { id = id }, stackSize = count or 1,
        data = saved and { oaabMannequins = saved } or {},
        position = { 1, 2, 3 }, orientation = { 0, 0, 1 }, cell = "test", scale = 1.25,
        delete = function(self) self.deleted = true end,
    }
end
for _, case in ipairs(cases) do
    check("MWSE fresh stock/loot: " .. case[1], function()
        resetMWSE()
        local source = portableMWSE(case[1])
        assert(callbacks[string.lower(case[1])], "Missing drop event filter")({ reference = source })
        assert(source.deleted and #created == 1)
        local npc = created[1]
        assert(npc.baseObject.id == case[2] and #npc.object.inventory.items == 0)
        assert(npc.position == source.position and npc.orientation == source.orientation)
        assert(npc.cell == source.cell and npc.scale == source.scale)
        for _, fn in ipairs(deferred) do fn() end
        assert(#poseCalls == 1)
        assert(not pickupMWSE.place(source) and #created == 1, "Deleted source converted twice")
    end)
end
check("MWSE dropped stack conserves quantity", function()
    resetMWSE()
    local source = portableMWSE(cases[1][1], 3)
    assert(pickupMWSE.place(source) and source.deleted and #created == 3)
end)
check("MWSE saved custom base converts to OAAB and preserves its pose", function()
    resetMWSE()
    local source = portableMWSE(cases[3][1], 1, {
        kind = "portableMannequin", baseId = "custom_mannequin", poseFile = "saved_pose.nif",
    })
    local npc = assert(pickupMWSE.place(source))
    assert(npc.baseObject.id == cases[3][2])
    assert(npc.data.oaabMannequins.poseFile == "saved_pose.nif")
end)
check("MWSE missing standard base keeps original item", function()
    resetMWSE()
    local base = bases[cases[3][2]]
    bases[cases[3][2]] = nil
    local source = portableMWSE(cases[3][1], 1, { kind = "portableMannequin", baseId = "missing" })
    assert(not pickupMWSE.place(source) and not source.deleted and #created == 0)
    bases[cases[3][2]] = base
end)
check("MWSE partial stack failure rolls back every NPC", function()
    resetMWSE()
    failAt = 2
    local source = portableMWSE(cases[1][1], 3)
    assert(not pickupMWSE.place(source) and not source.deleted and source.stackSize == 3)
    assert(#created == 1 and created[1].deleted)
end)
check("MWSE failed inventory cleanup preserves portable", function()
    resetMWSE()
    failInventory = true
    local source = portableMWSE(cases[1][1])
    assert(not pickupMWSE.place(source) and not source.deleted and created[1].deleted)
end)
check("MWSE unrelated items and inventory items are ignored", function()
    resetMWSE()
    assert(not pickupMWSE.place(portableMWSE("gold_001")))
    local source = portableMWSE(cases[1][1]); source.cell = nil
    assert(not pickupMWSE.place(source) and #created == 0)
end)

-- OpenMW --------------------------------------------------------------------
local omCreated, omFailAt, omFailInventory, handlers, omGlobal
local function inventory()
    local items = { { count = 2 }, { count = -1 } }
    for _, item in ipairs(items) do
        item.remove = function(self) if not omFailInventory then self.count = 0 end end
    end
    return {
        isResolved = function() return true end,
        getAll = function() return items end,
    }
end
local types = {
    Actor = { inventory = function(npc) return npc.inventory end },
    NPC = { objectIsInstance = function(obj) return type(obj) == "table" and obj.kind == "npc" end },
    Player = { objectIsInstance = function(obj) return obj.kind == "player" end },
}
local npcRecords, portableRecords = {}, {}
for i, case in ipairs(cases) do
    npcRecords[case[2]] = {
        class = i <= 2 and "ab_mannequinclassstand" or "ab_mannequinclassfull",
        isMale = i % 2 == 0,
        head = i >= 5 and (i % 2 == 0 and "ab_b_mann_hd02_m" or "ab_b_mann_hd02_f") or "headed",
    }
    portableRecords[string.lower(case[1])] = { id = string.lower(case[1]), value = 100 }
    npcRecords["custom_mannequin_" .. i] = npcRecords[case[2]]
end
npcRecords.custom_mannequin = npcRecords[cases[3][2]]
types.NPC.record = function(object)
    return npcRecords[type(object) == "string" and string.lower(object) or object.recordId]
end
types.Miscellaneous = {
    record = function(id) return portableRecords[string.lower(id)] end,
    createRecordDraft = function() error("Pickup must not generate portable records") end,
}
install("openmw.types", types)
install("openmw.world", {
createRecord = function() error("Pickup must not generate portable records") end,
createObject = function(id)
    if omFailAt == #omCreated + 1 then error("injected spawn failure") end
    assert(npcRecords[id] or portableRecords[id], "Unknown record: " .. tostring(id))
    local npc = {
        id = "object" .. tostring(#omCreated + 1), recordId = id,
        kind = npcRecords[id] and "npc" or "misc", count = 1,
        inventory = inventory(), events = {},
        remove = function(self) self.removed = true end,
        moveInto = function(self, destination) self.destination = destination end,
        setScale = function(self, scale) self.scale = scale end,
        teleport = function(self, cell, position, rotation)
            self.cell, self.position, self.rotation = cell, position, rotation
        end,
        sendEvent = function(self, name, data) self.events[name] = data end,
    }
    table.insert(omCreated, npc)
    return npc
end })
install("openmw.interfaces", { Activation = { addHandlerForObject = function(npc, fn)
    handlers[npc.id] = fn
end } })
install("scripts.oaab.mannequins.ownership", {
    hasOwner = function() return false end,
    copyOwner = function(item, owner) item.owner = owner end,
})
local discoveryOM = load(openmwPath .. "discovery.lua")
install("scripts.oaab.mannequins.discovery", discoveryOM)
install("scripts.oaab.mannequins.poses", {
    get = function(id) return id == "adlocutio" end,
    canPose = function(profile) return profile.id == "full" end,
})
local pickupOM = load(openmwPath .. "pickup.lua")
install("scripts.oaab.mannequins.pickup", pickupOM)
local function resetOM()
    omCreated, handlers = {}, {}
    omFailAt, omFailInventory = nil, false
    omGlobal = load(openmwPath .. "global.lua")
end
local function portableOM(id, count)
    return {
        id = "source", recordId = string.lower(id), count = count or 1,
        cell = "test", scale = 1.25, position = { 1, 2, 3 }, rotation = { 0, 0, 1 },
        isValid = function() return true end,
        -- Deliberately leave count/validity unchanged to model pending removal.
        remove = function(self) self.removed = true end,
    }
end
for _, case in ipairs(cases) do
    check("OpenMW fresh stock/loot: " .. case[1], function()
        resetOM()
        local source = portableOM(case[1])
        omGlobal.engineHandlers.onItemActive(source)
        assert(source.removed and #omCreated == 1)
        local npc = omCreated[1]
        assert(npc.recordId == case[2])
        assert(npc.position == source.position and npc.rotation == source.rotation)
        assert(npc.cell == source.cell and npc.scale == source.scale)
        for _, item in ipairs(npc.inventory:getAll()) do assert(item.count == 0) end
        assert(handlers[npc.id], "New mannequin must be interactive immediately")
        omGlobal.engineHandlers.onItemActive(source)
        assert(#omCreated == 1, "Pending removal converted twice")
    end)
end
check("OpenMW dropped stack conserves quantity", function()
    resetOM()
    local source = portableOM(cases[1][1], 3)
    omGlobal.engineHandlers.onItemActive(source)
    assert(source.removed and #omCreated == 3)
    for _, npc in ipairs(omCreated) do assert(handlers[npc.id]) end
end)
for _, key in ipairs({ "generated_record", "source" }) do
    check("OpenMW legacy custom ID converts to OAAB and preserves pose: " .. key, function()
        resetOM()
        local saved = { portables = { [key] = {
            baseId = "custom_mannequin", scale = 0.9, poseId = "adlocutio",
        } } }
        omGlobal.engineHandlers.onLoad(saved)
        local source = portableOM("generated_record")
        omGlobal.engineHandlers.onItemActive(source)
        local npc = assert(omCreated[1])
        assert(source.removed and npc.recordId == cases[3][2] and npc.scale == 0.9)
        assert(npc.events.OAABMannequins_SetPose.poseId == "adlocutio")
        local state = omGlobal.engineHandlers.onSave()
        assert(state.poses[npc.id] == "adlocutio" and not state.portables[key])
    end)
end
check("OpenMW partial failure keeps source and saved reconstruction state", function()
    resetOM()
    omFailAt = 2
    local saved = { portables = { generated_record = { baseId = "custom_mannequin" } } }
    omGlobal.engineHandlers.onLoad(saved)
    local source = portableOM("generated_record", 3)
    omGlobal.engineHandlers.onItemActive(source)
    assert(not source.removed and source.count == 3 and omCreated[1].removed)
    assert(omGlobal.engineHandlers.onSave().portables.generated_record)
end)
check("OpenMW failed inventory cleanup rolls back NPC", function()
    resetOM()
    omFailInventory = true
    local source = portableOM(cases[1][1])
    omGlobal.engineHandlers.onItemActive(source)
    assert(not source.removed and omCreated[1].removed)
end)
check("OpenMW unrelated, unresolved-inventory and removed items are ignored", function()
    resetOM()
    omGlobal.engineHandlers.onItemActive(portableOM("gold_001"))
    local source = portableOM(cases[1][1]); source.cell = nil
    omGlobal.engineHandlers.onItemActive(source)
    source.cell, source.count = "test", 0
    omGlobal.engineHandlers.onItemActive(source)
    assert(#omCreated == 0)
end)
check("OpenMW fresh mannequin immediately offers its normal menu", function()
    resetOM()
    omGlobal.engineHandlers.onItemActive(portableOM(cases[3][1]))
    local player = { kind = "player", id = "player", sendEvent = function(_, name, data)
        assert(name == "OAABMannequins_ShowMenu" and data.canPose and not data.owned)
    end }
    assert(handlers[omCreated[1].id](nil, player) == false)
end)

for i, case in ipairs(cases) do
    check("OpenMW custom pickup uses the existing OAAB pair: " .. case[1], function()
        resetOM()
        local mannequin = {
            id = "custom_npc", recordId = "custom_mannequin_" .. i, kind = "npc", scale = 0.9,
            inventory = { isResolved = function() return true end, getAll = function() return {} end },
            remove = function(self) self.removed = true end,
        }
        local player = { kind = "player", inventory = {} }
        local state, owner = {}, { recordId = "merchant" }
        local portable = assert(pickupOM.pickUp({
            mannequin = mannequin, player = player, portables = state, poseId = "adlocutio", owner = owner,
        }))
        assert(mannequin.removed and portable.recordId == string.lower(case[1]) and #omCreated == 1)
        assert(portable.destination == player.inventory and portable.owner == owner)
        assert(not state[portable.recordId] and state[portable.id].baseId == nil)
        portable.cell, portable.position, portable.rotation = "test", { 1, 2, 3 }, { 0, 0, 1 }
        local mannequins, poseId = pickupOM.place(portable, player, portable.position, portable.rotation, state)
        assert(portable.removed and mannequins[1].recordId == case[2])
        assert(mannequins[1].scale == 0.9 and poseId == "adlocutio" and not state[portable.id])
    end)
    check("OpenMW legacy generated custom portable converts: " .. case[1], function()
        resetOM()
        omGlobal.engineHandlers.onLoad({ portables = { generated_record = {
            baseId = "custom_mannequin_" .. i, scale = 0.9,
        } } })
        local source = portableOM("generated_record")
        omGlobal.engineHandlers.onItemActive(source)
        assert(source.removed and omCreated[1].recordId == case[2])
    end)
end
check("OpenMW ordinary item ignores an older missing custom base", function()
    resetOM()
    omGlobal.engineHandlers.onLoad({ portables = { source = { baseId = "missing_custom_record" } } })
    local source = portableOM(cases[3][1])
    omGlobal.engineHandlers.onItemActive(source)
    assert(source.removed and omCreated[1].recordId == cases[3][2])
end)
check("OpenMW missing standard NPC preserves the portable and its saved data", function()
    resetOM()
    local base = npcRecords[cases[3][2]]
    npcRecords[cases[3][2]] = nil
    local state = { source = { poseId = "adlocutio" } }
    local source = portableOM(cases[3][1])
    assert(not pickupOM.place(source, nil, source.position, source.rotation, state))
    assert(not source.removed and #omCreated == 0 and state.source)
    npcRecords[cases[3][2]] = base
end)
check("OpenMW separate pickups do not overwrite data for the same item ID", function()
    resetOM()
    local state, player = {}, { kind = "player", inventory = {} }
    local function pick(pose)
        return assert(pickupOM.pickUp({
            mannequin = {
                recordId = "custom_mannequin", kind = "npc", scale = 1,
                inventory = { isResolved = function() return true end, getAll = function() return {} end },
                remove = function() end,
            },
            player = player, portables = state, poseId = pose,
        }))
    end
    local first, second = pick("adlocutio"), pick("other_pose")
    assert(first.recordId == second.recordId and first.id ~= second.id)
    assert(state[first.id].poseId == "adlocutio" and state[second.id].poseId == "other_pose")
    assert(not state[first.recordId])
end)
check("OpenMW merged or split standard stacks need no pickup metadata", function()
    resetOM()
    local source = portableOM(cases[3][1], 3)
    local state = { old_object = { poseId = "adlocutio" } }
    local mannequins = assert(pickupOM.place(source, nil, source.position, source.rotation, state))
    assert(source.removed and #mannequins == 3)
    for _, npc in ipairs(mannequins) do assert(npc.recordId == cases[3][2]) end
end)
print(string.format("%d portable regression checks passed.", tests))
