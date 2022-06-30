local activeBugs = {}

--- Detect when bug references are created, and start tracking them.
---
local function refCreated(e)
    if e.reference.sceneNode:hasStringDataWith("HasBugsRoot") then
        activeBugs[e.reference] = true
    end
end


--- Detect when bug references are deleted, and stop tracking them.
---
local function refDeleted(e)
    activeBugs[e.object] = nil
end


--- Toggle visibility for all currently active bugs references.
---
local function toggleBugsVisibility(state)
    local index = state and 1 or 0
    for ref in pairs(activeBugs) do
        if ref.sceneNode then
            local root = ref.sceneNode:getObjectByName("BugsRoot")
            if root.switchIndex ~= index then
                root.switchIndex = index
            end
        end
    end
end


--- Global manager for active bugs. Runs once per hour.
---
local bugsVisible = {}
local function updateBugs()
    local isBugsVisible = true

    if tes3.player.cell.isInterior then
        -- global variable used for dialogue filtering
        tes3.setGlobal("AB_GlowbugsVisible", 0)
    else
        -- exterior cells require valid hours/weathers
        local wc = tes3.worldController

        local hour = wc.hour.value
        local day = wc.daysPassed.value
        local weather = wc.weatherController.currentWeather.index

        -- percentage chance to spawn on any given day
        -- is determined by the AB_GlowbugsChance global
        -- we only want to calculate this once per day!
        if bugsVisible[day] == nil then
            local roll = math.random(100)
            local glob = tes3.getGlobal("AB_GlowbugsChance")
            bugsVisible[day] = roll <= glob
        end

        local isActiveHours = (hour >= 18) or (hour <= 6)
        local isValidWeather = weather < tes3.weather.rain
        local isValidDay = bugsVisible[day]

        isBugsVisible = isActiveHours and isValidWeather and isValidDay

        -- global variable used for dialogue filtering
        tes3.setGlobal("AB_GlowbugsVisible", isBugsVisible and 1 or 0)
    end

    toggleBugsVisibility(isBugsVisible)
end


--- Harvest a single bug. Called on "activate" event.
---
local function harvestBugs(e)
    if not activeBugs[e.target] then
        return
    end

    local rayHit = tes3.rayTest{
        position = tes3.getPlayerEyePosition(),
        direction = tes3.getPlayerEyeVector(),
        root = e.target.sceneNode,
    }
    if not (rayHit and rayHit.object) then
        return
    end

    -- hide the bug
    rayHit.object.parent.parent.parent.appCulled = true

    -- add the loot
    for _, stack in pairs(e.target.baseObject.inventory) do
        local item = stack.object
        if item.canCarry ~= false then
            if item.objectType == tes3.objectType.leveledItem then
                item = item:pickFrom()
            end
            if item then
                tes3.addItem{reference=e.activator, item=item}
                tes3.messageBox("You harvested %s %s.", stack.count, item.name)
            else
                tes3.playSound{reference=e.activator, sound="scribright"}
                tes3.messageBox("You failed to harvest anything of value.")
            end
        end
    end

    return false
end


--- Update bugs once per hour.
---
local function bugsTimer()
    timer.start{
        type = timer.game,
        iterations = -1,
        duration = 1,
        callback = function()
            timer.delayOneFrame(updateBugs)
        end
    }
end


event.register("initialized", function()
    if tes3.isModActive("OAAB_Data.esm") then
        event.register("referenceSceneNodeCreated", refCreated)
        event.register("objectInvalidated", refDeleted)
        event.register("cellChanged", updateBugs)
        event.register("weatherTransitionFinished", updateBugs)
        event.register("activate", harvestBugs, {priority = 600})
        event.register("loaded", bugsTimer)
    end
end)
