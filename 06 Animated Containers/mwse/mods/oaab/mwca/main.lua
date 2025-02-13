local mwca = include("MWCA.interop");

-- interop patch for Morrowind Containers Animated by qqqbbb
-- https://www.nexusmods.com/morrowind/mods/42238

if mwca then
    mwca["oaab\\o\\comrchcloset.nif"] = {
        -- mesh path
        "oaab\\o\\comrchclosetac.nif", 
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
	mwca["oaab\\o\\comrchhutch.nif"] = {"OAAB\\o\\comrchhutchac.nif", 1, 2, 0.5, 0.5, "AC_drawer_open", "AC_drawer_close", 0};
	mwca["oaab\\o\\comrchdesk.nif"] = {"OAAB\\o\\comrchdeskac.nif", 1, 2, 0.5, 0.5, "AC_drawer_de_open", "AC_drawer_de_close", 0};
	mwca["oaab\\o\\comrchdesk2.nif"] = {"OAAB\\o\\comrchdesk2ac.nif", 1, 2, 0.5, 0.5, "AC_drawer_de_open", "AC_drawer_de_close", 0};
	mwca["oaab\\o\\comdrawers.nif"] = {"OAAB\\o\\comdrawersac.nif", 1, 2, 0.5, 0.5, "AC_drawer_open", "AC_drawer_close", 0};
	mwca["oaab\\o\\comcookhutch.nif"] = {"OAAB\\o\\comcookhutchac.nif", 1, 2, 0.5, 0.5, "AC_closet_open", "AC_closet_close", 0};
	mwca["oaab\\o\\comcookhutchopen.nif"] = {"OAAB\\o\\comcookhutchopenac.nif", 1, 2, 0.5, 0.5, "AC_closet_open", "AC_closet_close", 0};
	mwca["oaab\\o\\comcooktable.nif"] = {"oaab\\o\\comcooktableac.nif", 1, 2, 0.5, 0.5, "AC_drawer_open", "AC_drawer_close", 0};
	mwca["oaab\\o\\comrchchest.nif"] = {"oaab\\o\\comrchchestac.nif", 1, 2, 0.5, 0.5, "AC_chest_open", "AC_chest_close", 0};
	mwca["oaab\\o\\deplndesk2.nif"] = {"oaab\\o\\deplndesk2ac.nif", 1, 2, 0.5, 0.5, "AC_drawer_open", "AC_drawer_close", 0};
	mwca["oaab\\o\\commiddesk.nif"] = {"oaab\\o\\commiddeskac.nif", 1, 2, 0.5, 0.5, "AC_drawer_open", "AC_drawer_close", 0}

	mwca["oaab\\o\\complncoffin.nif"] = {"oaab\\o\\complncoffinac.nif", 1, 2, 0.5, 0.5, "AC_crate_open", "AC_crate_close", 0};	
	mwca["oaab\\o\\commidcoffin.nif"] = {"oaab\\o\\commidcoffinac.nif", 1, 2, 0.5, 0.5, "AC_crate_open", "AC_crate_close", 0};	
	mwca["oaab\\o\\comrchcoffin.nif"] = {"oaab\\o\\comrchcoffinac.nif", 1, 2, 0.5, 0.5, "AC_crate_open", "AC_crate_close", 0};	
	
	
end