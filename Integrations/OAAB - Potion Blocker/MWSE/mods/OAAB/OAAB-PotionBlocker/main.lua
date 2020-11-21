local function blockPotionEquipEvent(e)
    if (e.item.id:find("^AB_eff_")) then
        e.claim = true
    end
end
event.register("equip", blockPotionEquipEvent, {priority = 1000})
event.register("equipped", blockPotionEquipEvent, {priority = 1000})