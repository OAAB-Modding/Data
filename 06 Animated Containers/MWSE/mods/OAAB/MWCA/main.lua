local mwca = include("MWCA.interop");

-- interop patch for Morrowind Containers Animated by qqqbbb
-- https://www.nexusmods.com/morrowind/mods/42238

if mwca then
    mwca["OAAB\\o\\ComRichCloset.nif"] = {
        -- mesh path
        "OAAB\\o\\ComRichClosetAC.nif", 
        -- open animation group
        1, 
        -- close animation group
        2, 
        -- open animation length (seconds)
        0.5, 
        -- close animation length (seconds)
        0.5, 
        -- open sound
        "AC_closet_open", 
        -- close sound
        "AC_closet_close", 
        -- items ontop of container disable distance
        0
    };
	mwca["OAAB\\o\\ComRichHutch.nif"] = {"OAAB\\o\\ComRichHutchAC.nif", 1, 2, 0.5, 0.5, "AC_drawer_open", "AC_drawer_close", 0};
	mwca["OAAB\\o\\ComRichDesk.nif"] = {"OAAB\\o\\ComRichDeskAC.nif", 1, 2, 0.5, 0.5, "AC_drawer_de_open", "AC_drawer_de_close", 0};
	mwca["OAAB\\o\\ComRichDesk2.nif"] = {"OAAB\\o\\ComRichDesk2AC.nif", 1, 2, 0.5, 0.5, "AC_drawer_de_open", "AC_drawer_de_close", 0};
	mwca["OAAB\\o\\ComDrawers.nif"] = {"OAAB\\o\\ComDrawersAC.nif", 1, 2, 0.5, 0.5, "AC_drawer_open", "AC_drawer_close", 0}
	
	
end