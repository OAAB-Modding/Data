-- List of sounds we want to block.
local soundsToBlock = {}

-- Strings suck, objects for life.
local function onInitialized()
    -- Currently only manually blocking the Drink sound.
    local sounds = { 
        "Drink" 
    }
    for _, soundId in ipairs(sounds) do
        soundsToBlock[tes3.getSound(soundId)] = true
    end
end
event.register("initialized", onInitialized)

-- Set to true to disable blacklisted sounds.
local blockSounds = false

-- Handles the blocking.
local function blockPlayerSounds(e)
    if (blockSounds and e.reference == tes3.player and soundsToBlock[e.sound]) then
        return false
    end
end
event.register("addSound", blockPlayerSounds)

-- 
-- Block event for relevant items.
-- 
local function blockPotionEvent(e)
    if (e.item.id:find("^AB_alc_")) then
        e.claim = true
        return true
    end
    return false
end

local function blockPotionEquipEvent(e)
    local blocked = blockPotionEvent(e)

    if (blocked == true) then
        -- Enable sound blocking for drink sound.
        blockSounds = true
        event.trigger("OAAB:equip", e)
    end
end
local function blockPotionEquippedEvent(e)
    local blocked = blockPotionEvent(e)

    if (blocked == true) then
        -- Disable sound blocking for drink sound.
        blockSounds = false
        event.trigger("OAAB:equipped", e)
    end
end
event.register("equip", blockPotionEquipEvent, {priority = 1000})
event.register("equipped", blockPotionEquippedEvent, {priority = 1000})


local function stopItemSounds(e)
    if (e.item.id:find("^AB_alc_")) then
        if (e.state == 0) then --UP
            tes3.playSound({
                reference = e.reference,
                sound = "Item Misc Up"
            })
        elseif (e.state == 1) then -- DOWN
            tes3.playSound({
                reference = e.reference,
                sound = "Item Misc Down"
            })
        elseif (e.state == 2) then -- ?

        elseif (e.state == 3) then -- ?

        end
        return false
    end
end
event.register("playItemSound", stopItemSounds)