local function bandageEquipEvent(e)
    if (e.item.id:find("^AB_alc_Gem")) then
        tes3.playSound({
            reference = e.reference,
            sound = "AB_GlassBreaking"
        })
    end
end
event.register("OAAB:equip", bandageEquipEvent)