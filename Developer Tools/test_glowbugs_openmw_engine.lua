-- Load as GLOBAL in an isolated OpenMW test profile with OAAB_Data.omwscripts.
-- Start in a Bitter Coast exterior, freeze timescale, and set all weather
-- transition deltas to 1 in the profile. Creates test objects and quits on success.
local core = require('openmw.core')
local world = require('openmw.world')
local util = require('openmw.util')
local I = require('openmw.interfaces')
local elapsed, stage, last = 0, 0, 0
local source, hidden, particle, region
local function pass(label)
    print('OAAB_GB_ENGINE PASS ' .. label)
    stage, last = stage + 1, elapsed
end
local function visible(expected)
    assert(source.enabled == expected, 'body visibility mismatch, stage ' .. stage)
    assert(I.OAABGlowbugs.getParticles(source).enabled == expected, 'particle visibility mismatch, stage ' .. stage)
    assert(not hidden.enabled, 'initially disabled source enabled')
end
return {engineHandlers = {onUpdate = function(dt)
    elapsed = elapsed + dt
    assert(elapsed - last < 25, 'stage timeout ' .. stage)
    local player = world.players[1]
    if not player then return end
    local globals = world.mwscript.getGlobalVariables()
    local api = I.OAABGlowbugs
    if stage == 0 and elapsed > 1 then
        assert(api.version == 3, 'API version')
        region = player.cell.region
        core.weather.changeWeather(region, core.weather.records['clear'])
        api.setSpawnChance(100)
        globals.gamehour = 22
        source = world.createObject('ab_r_glowbugslargeblue')
        source:teleport(player.cell, player.position + util.vector3(0,150,0))
        hidden = world.createObject('ab_r_glowbugslargegreen')
        hidden:teleport(player.cell, player.position + util.vector3(150,0,0))
        hidden.enabled = false
        pass('created native sources')
    elseif stage == 1 and elapsed-last > 2 and core.weather.getCurrent(player.cell).scriptId == 0
        and core.weather.getNext(player.cell) == nil then
        visible(true); particle = api.getParticles(source)
        pass('clear night and initially disabled source'); globals.gamehour = 12
    elseif stage == 2 and elapsed-last > 1 then
        visible(false); pass('day hides body and particle'); globals.gamehour = 18
    elseif stage == 3 and elapsed-last > 1 then
        visible(true); pass('18:00 inclusive and reactivation'); globals.gamehour = 6
    elseif stage == 4 and elapsed-last > 1 then
        visible(true); pass('06:00 inclusive'); globals.gamehour = 22
        core.sendGlobalEvent('OAABGlowbugs_SetSpawnChance', {chance=0})
    elseif stage == 5 and elapsed-last > 1 then
        visible(false); assert(api.getSpawnChance() == 0, 'event did not set chance')
        pass('global event sets 0 percent'); api.setSpawnChance(100)
    elseif stage == 6 and elapsed-last > 1 then
        visible(true); assert(api.getParticles(source) == particle, 'duplicate particles')
        pass('same-day change restores existing pair')
        core.weather.changeWeather(region, core.weather.records['rain'])
    elseif stage == 7 and elapsed-last > 1 and core.weather.getCurrent(player.cell).scriptId == 4 and not source.enabled then
        visible(false); pass('native rain suppresses bugs')
        core.weather.changeWeather(region, core.weather.records['clear'])
    elseif stage == 8 and elapsed-last > 1 and core.weather.getCurrent(player.cell).scriptId == 0 and source.enabled then
        visible(true); pass('native clear weather restores bugs')
        api.setSpawnChance(0); globals.gamehour = 12
        local cell = world.getCellByName('Seyda Neen, Census and Excise Office')
        player:teleport(cell, util.vector3(0,0,0))
        source:teleport(cell, util.vector3(0,150,0))
        hidden:teleport(cell, util.vector3(150,0,0)); hidden.enabled = false
    elseif stage == 9 and elapsed-last > 2 then
        visible(true); assert(globals.ab_glowbugsvisible == 0, 'interior dialogue flag')
        pass('interior bypasses chance and hour')
        print('OAAB_GB_ENGINE ALL CHECKS PASSED'); core.quit()
    end
end}}
