-- Containers own bodies and harvesting; activators own particles.
-- Only explicit setVisible callers grant this manager control of enabled.
local world = require('openmw.world')
local types = require('openmw.types')
local util = require('openmw.util')
local I = require('openmw.interfaces')
if I.OAABGlowbugs then
    local owner = I.OAABGlowbugs
    return {engineHandlers = {
        onSave = owner._saveState,
        onLoad = function(data) if data ~= nil then owner._loadState(data) end end,
    }}
end
local models = {
    ['oaab/e/glowbugsreal.nif'] = 'ab_fx_glowbugslargeblue',
    ['oaab/e/glowbugsreal02.nif'] = 'ab_fx_glowbugslargegreen',
}
local pairsBySource, policies = {}, {}
local activeCells, activeSources, missing = {}, {}, {}
local retired, timer = {}, 0
local function key(cell)
    return cell.isExterior and (cell.id .. ':' .. cell.gridX .. ':' .. cell.gridY) or cell.id
end
local function particleRecord(source)
    if source.type ~= types.Container then return nil end
    local model = types.Container.record(source).model:lower():gsub('\\', '/'):gsub('^meshes/', '')
    return models[model]
end
local function track(source)
    if source:isValid() and source.count > 0 and particleRecord(source) and source.cell then
        activeSources[source.id] = source
    end
end
local function retire(object)
    if object:isValid() and object.count > 0 then object.enabled = false; object:remove() end
end
local function onObjectActive(object)
    if object.recordId == 'oaab_gb_detail_blue' or object.recordId == 'oaab_gb_detail_green' then
        retire(object)
    else track(object) end
end
local function sameRotation(a, b)
    return (a:apply(util.vector3(1,0,0)) - b:apply(util.vector3(1,0,0))):length() < 0.00001
        and (a:apply(util.vector3(0,1,0)) - b:apply(util.vector3(0,1,0))):length() < 0.00001
end
local function maintain(source, player)
    local record = particleRecord(source)
    local pair = pairsBySource[source.id]
    if not record then
        if pair then retire(pair.particle); pairsBySource[source.id] = nil end
        return
    end
    local policy = policies[source.id]
    local visible = source.enabled
    if policy then
        visible = policy.visible
        local near = (source.position - player.position):length() <= 2560 * source.scale + 512
        source.enabled = visible and near
    end
    local particle = pair and pair.particle
    if not particle or not particle:isValid() or particle.count == 0 then
        if not visible then return end
        particle = world.createObject(record)
        pair = {source = source, particle = particle}
        pairsBySource[source.id] = pair
    end
    if particle.scale ~= source.scale then particle:setScale(source.scale) end
    if not particle.cell or key(particle.cell) ~= key(source.cell)
        or (particle.position-source.position):length() > 0.01
        or not sameRotation(particle.rotation, source.rotation) then
        particle:teleport(source.cell, source.position, {rotation = source.rotation})
        -- Teleport enables on the next engine action. A queued disable after
        -- it is allowed even while the reference is in transit (count == 0).
        if not visible then particle.enabled = false end
    else
        particle.enabled = visible
    end
end
local function scan(cell, nextCells)
    local id = key(cell)
    nextCells[id] = true
    if activeCells[id] then return end
    for _, source in ipairs(cell:getAll(types.Container)) do track(source) end
end
local function onUpdate(dt)
    for _, object in pairs(retired) do retire(object) end
    retired = {}
    timer = timer + dt
    if timer < 0.25 then return end
    timer = 0
    local player = world.players[1]
    if not player or not player.cell then return end
    local nextCells = {}
    if player.cell.isExterior then
        local x,y = math.floor(player.position.x/8192), math.floor(player.position.y/8192)
        for cx=x-1,x+1 do for cy=y-1,y+1 do scan(world.getExteriorCell(cx,cy,player.cell),nextCells) end end
    else scan(player.cell,nextCells) end
    activeCells = nextCells
    for id, source in pairs(activeSources) do
        local exists = source:isValid() and source.count > 0
        if not exists then
            -- A queued teleport also temporarily has count zero. Recheck on
            -- the following tick before treating the source as deleted.
            if missing[id] then
                local pair = pairsBySource[id]
                if pair then retire(pair.particle) end
                pairsBySource[id], policies[id], activeSources[id], missing[id] = nil,nil,nil,nil
            else missing[id] = true end
        elseif source.cell and activeCells[key(source.cell)] then
            missing[id] = nil
            maintain(source,player)
        else
            local pair = pairsBySource[id]
            if pair and pair.particle:isValid() then pair.particle.enabled = false end
            activeSources[id], missing[id] = nil,nil
        end
    end
end
local function saveState()
    return {version = 2, pairsBySource = pairsBySource, policies = policies}
end
local function loadState(data)
    pairsBySource, policies, retired = {}, {}, {}
    activeCells, activeSources, missing, timer = {}, {}, {}, 0
    if data and data.version == 2 then
        pairsBySource, policies = data.pairsBySource or {}, data.policies or {}
        for _, pair in pairs(pairsBySource) do activeSources[pair.source.id] = pair.source end
    elseif data then
        for _, pair in pairs(data.pairsBySource or {}) do
            if pair.detail then retired[#retired+1] = pair.detail end
        end
    end
end
return {
    interfaceName = 'OAABGlowbugs',
    interface = {
        version = 2,
        _saveState = saveState,
        _loadState = loadState,
        getParticles = function(source)
            local pair = pairsBySource[source.id]
            return pair and pair.particle
        end,
        -- Opt in and supply logical visibility; distance is composed here.
        -- While registered, callers must use this API instead of enabled.
        setVisible = function(source, visible)
            if not source:isValid() or not particleRecord(source) then return false end
            assert(type(visible) == 'boolean', 'visible must be boolean')
            policies[source.id] = {source = source, visible = visible}
            track(source)
            return true
        end,
        releaseVisibility = function(source)
            local policy = policies[source.id]
            if policy and source:isValid() and source.count > 0 then source.enabled = policy.visible end
            policies[source.id] = nil
        end,
    },
    engineHandlers = {onObjectActive = onObjectActive, onUpdate = onUpdate, onSave = saveState, onLoad = loadState},
}
