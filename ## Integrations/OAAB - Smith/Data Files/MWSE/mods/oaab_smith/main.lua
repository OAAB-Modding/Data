--- @param e initializedEventData
local function initializedCallback(e)
    require("oaab_smith.weapons_oaab_axe1")
    require("oaab_smith.weapons_oaab_axe2")
    require("oaab_smith.weapons_oaab_blunt1")
    require("oaab_smith.weapons_oaab_blunt2c")
    require("oaab_smith.weapons_oaab_blunt2w")
    require("oaab_smith.weapons_oaab_short")
    require("oaab_smith.weapons_oaab_long1")
    require("oaab_smith.weapons_oaab_long2")
    require("oaab_smith.weapons_oaab_spear")
end
event.register(tes3.event.initialized, initializedCallback)