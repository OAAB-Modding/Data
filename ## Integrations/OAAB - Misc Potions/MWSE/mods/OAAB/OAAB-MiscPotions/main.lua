local function blockPotionEvent(e)
    if (e.item.id:find("^AB_alc_")) then
        e.claim = true
     
        timer.frame.delayOneFrame(function()
            tes3.removeSound({
                reference = e.reference,
                sound = "Drink"
            })
        end)

        return true
    end
    return false
end

local function blockPotionEquipEvent(e)
    local blocked = blockPotionEvent(e)

    if (blocked == true) then
        event.trigger("OAAB:equip", e)
    end
end
local function blockPotionEquippedEvent(e)
    local blocked = blockPotionEvent(e)

    if (blocked == true) then
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

