local function bandageEquipEvent(e)
    if (e.item.id:find("^AB_alc_HealBandage")) then
        tes3.playSound({
            reference = e.reference,
            sound = "AB_Bandaging"
        })
    end
end
event.register("OAAB:equip", bandageEquipEvent)