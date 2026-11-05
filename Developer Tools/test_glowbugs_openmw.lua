-- Run from the repository root with Lua 5.1+. Exercises the production manager
-- with deferred engine mutations, including save/load and v2 policy migration.
local path = '01 OpenMW Functions/scripts/oaab/glowbugs/lod.lua'
local checks, rollCount, nextRoll = 0, 0, 33
local function check(label, condition)
    assert(condition, label)
    checks = checks + 1
    print('PASS ' .. label)
end
local vector = {}
vector.__index = vector
vector.__sub = function(a,b) return setmetatable({x=a.x-b.x}, vector) end
function vector:length() return math.abs(self.x) end
local function pos(x) return setmetatable({x=x or 0,y=0,z=0},vector) end
local rotation = {apply=function(_,v) return v end}
local container = {record=function(o) return {model=o.model} end}
local cells, queue, objects = {}, {}, {}
local function cell(id, exterior)
    local c = {id=id, isExterior=exterior, gridX=0, gridY=0}
    function c:getAll(kind)
        local list = {}
        for _,o in pairs(objects) do
            if o.cell == self and o.count > 0 and (not kind or o.type == kind) then list[#list+1]=o end
        end
        return list
    end
    cells[id]=c
    return c
end
local outside, inside = cell('outside',true), cell('inside',false)
local player = {cell=outside, position=pos()}
local globals = {gamehour=22, dayspassed=1, ab_glowbugschance=33.33, ab_glowbugsvisible=0}
local weather, queriedCell = {scriptId=0}, nil
local function object(id, kind, enabled)
    local data = {id=id,recordId=id,type=kind,enabled=enabled,count=1,scale=1,
        position=pos(),rotation=rotation,model='oaab/e/glowbugsreal.nif'}
    local o = setmetatable({}, {
        __index=data,
        __newindex=function(_,k,v)
            if k=='enabled' then queue[#queue+1]=function() data[k]=v end else data[k]=v end
        end,
    })
    function data:isValid() return not data.deleted end
    function data:remove() data.count=0; data.deleted=true end
    function data:setScale(scale) data.scale=scale end
    function data:teleport(c,p,options)
        queue[#queue+1]=function()
            data.cell,data.position,data.enabled=c,p,true
            if options then data.rotation=options.rotation end
        end
    end
    objects[id]=o
    return o
end
local world = {players={player},mwscript={getGlobalVariables=function() return globals end}}
function world.getExteriorCell(x,y) return (x==0 and y==0) and outside or cell(x..':'..y,true) end
local particles=0
function world.createObject(record)
    particles=particles+1
    return object(record..particles,'activator',false)
end
local interfaces={}
package.loaded['openmw.core']={weather={getCurrent=function(c) queriedCell=c; return weather end}}
package.loaded['openmw.world']=world
package.loaded['openmw.types']={Container=container}
package.loaded['openmw.util']={vector3=function(x) return pos(x) end}
package.loaded['openmw.interfaces']=interfaces
math.random=function(n) assert(n==100); rollCount=rollCount+1; return nextRoll end
local manager=assert(loadfile(path))()
local api=manager.interface
local function flush()
    local pending=queue; queue={}
    for _,action in ipairs(pending) do action() end
end
local function tick()
    manager.engineHandlers.onUpdate(0.25)
    flush()
end
local source=object('source',container,true)
source.cell=outside
local hidden=object('hidden',container,false)
hidden.cell=outside
local standalone=object('standalone','activator',true)
standalone.cell=outside
tick()
local particle=api.getParticles(source)
check('default chance and clear night show body and particles', source.enabled and particle.enabled and api.getSpawnChance()==33.33)
check('initially disabled source and independent activator preserved', not hidden.enabled and standalone.enabled)
for _,hour in ipairs({0,6,18,23.99}) do
    globals.gamehour=hour; tick()
    check('active hour '..hour, source.enabled and particle.enabled)
end
for _,hour in ipairs({6.01,12,17.99}) do
    globals.gamehour=hour; tick()
    check('inactive hour '..hour, not source.enabled and not particle.enabled)
end
globals.gamehour=22
for id=0,9 do
    weather={scriptId=id}; tick()
    check('weather '..id, source.enabled==(id<4) and particle.enabled==(id<4))
    check('weather API '..id, api.isValidWeather(id)==(id<4) and api.isCurrentWeatherValid()==(id<4))
end
weather=nil; tick()
check('unknown weather hides exterior bugs', not source.enabled and not particle.enabled)
check('weather API rejects unavailable exterior weather', not api.isCurrentWeatherValid(outside))
for _,value in ipairs({-1,0.5,math.huge,-math.huge,0/0,'0',false,{scriptId=0}}) do
    check('weather API rejects invalid ID '..tostring(value), not api.isValidWeather(value))
end
check('weather API rejects absent ID', not api.isValidWeather())
local oldFlag, oldRollCount = globals.ab_glowbugsvisible, rollCount
queriedCell=nil
check('interior weather check bypasses lookup', api.isCurrentWeatherValid(inside) and queriedCell==nil)
world.players={}
check('weather API handles absent player', not api.isCurrentWeatherValid())
weather={scriptId=0}
check('explicit cell weather check works without player', api.isCurrentWeatherValid(outside) and queriedCell==outside)
world.players={player}; player.cell=nil
check('weather API handles player without cell', not api.isCurrentWeatherValid())
player.cell=outside
check('weather queries leave rolls visibility and dialogue untouched', rollCount==oldRollCount
    and globals.ab_glowbugsvisible==oldFlag and not source.enabled and not particle.enabled)
weather={scriptId=0}; tick()
check('same day never rerolls across hours and weather', rollCount==1)
globals.dayspassed=2; nextRoll=34; tick()
check('next day rolls and fails default threshold', rollCount==2 and not source.enabled and globals.ab_glowbugsvisible==0)
api.setSpawnChance(34); tick()
check('chance change reuses roll and takes effect', rollCount==2 and source.enabled and globals.ab_glowbugsvisible==1)
manager.eventHandlers.OAABGlowbugs_SetSpawnChance({chance=0}); tick()
check('player event can suppress exterior days', not source.enabled and api.getSpawnChance()==0)
for _,value in ipairs({-1,101,math.huge,-math.huge,0/0,'50',false}) do
    local ok=pcall(api.setSpawnChance,value)
    check('invalid chance rejected: '..tostring(value), not ok and api.getSpawnChance()==0)
end
local saved=manager.engineHandlers.onSave()
manager.engineHandlers.onLoad(saved); tick()
api.setSpawnChance(100); tick()
check('save/load preserves hidden logical state and daily roll', source.enabled and particle.enabled and rollCount==2)
check('reload reuses existing particle pair', api.getParticles(source)==particle and particles==1)
api.setVisible(source,true)
player.position=pos(4000); tick()
check('distance LOD hides only the body', not source.enabled and particle.enabled)
globals.gamehour=12; tick()
check('environment also hides distant particles', not source.enabled and not particle.enabled)
api.releaseVisibility(source); tick()
check('release retains environmental restrictions', not source.enabled and not particle.enabled)
globals.gamehour=22; tick()
check('release removes LOD and retains logical visibility', source.enabled and particle.enabled)
source.enabled=false; flush(); tick()
globals.gamehour=12; tick(); globals.gamehour=22; tick()
check('external disable remains disabled after day/night cycle', not source.enabled and not particle.enabled)
source.enabled=true; flush(); tick()
check('external enable observed', source.enabled and particle.enabled)
api.setVisible(source,false); tick()
check('explicit hidden policy overrides favorable conditions', not source.enabled and not particle.enabled)
api.setVisible(source,true)
source.cell=inside; player.cell=inside; player.position=pos()
globals.gamehour=12; api.setSpawnChance(0); weather={scriptId=9}; tick()
check('interior bypasses time weather chance but dialogue flag stays zero', source.enabled and particle.enabled and globals.ab_glowbugsvisible==0)
check('interior does not roll a new day', rollCount==2)
api.setVisible(source,false); api.releaseVisibility(source); tick()
check('release preserves explicitly hidden state indoors', not source.enabled)
api.setVisible(source,true); tick()
manager.engineHandlers.onLoad({version=2,pairsBySource={[source.id]={source=source,particle=particle}},policies={[source.id]={source=source,visible=true}}})
tick()
check('version 2 save migration preserves pair and policy', api.getParticles(source)==particle and source.enabled and particles==1)
interfaces.OAABGlowbugs=api
local duplicate=assert(loadfile(path))()
check('duplicate registration delegates without second manager or event handler', duplicate.interface==nil and duplicate.eventHandlers==nil and duplicate.engineHandlers.onSave==api._saveState)
duplicate.engineHandlers.onLoad(nil)
check('empty duplicate save does not erase owner state', api.getParticles(source)==particle)
source:remove(); tick(); tick()
check('deleting source removes companion', not particle:isValid() and api.getParticles(source)==nil)
print('ALL '..checks..' GLOWBUG CHECKS PASSED')
