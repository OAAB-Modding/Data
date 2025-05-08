local interop = require("sb_smith.interop")

---@type weapon[]
local weapons = {
    ["AB_w_AshlGlassDagger"] =
    {
        handles = { "Tri AshlGlassDagger 0", "Tri AshlGlassDagger 1", "Tri AshlGlassDagger 3", "Tri AshlGlassDagger 4" },
        blades  = { "Tri AshlGlassDagger 2" },
        rootIndexes = { 3, 1 }
    },
    ["AB_w_AshlGlassShortsword"] =
    {
        handles = { "Tri AshlGlassSSword 0", "Tri AshlGlassSSword 1", "Tri AshlGlassSSword 2", "Tri AshlGlassSSword 4" },
        blades  = { "Tri AshlGlassSSword 3" },
        rootIndexes = { 3, 1 }
    },
    ["AB_w_BottleBroken"] =
    {
        handles = { "Tri Tri Misc_Com_Bottle_02 0 1" },
        blades  = { "Tri Tri Misc_Com_Bottle_02 0 0" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ChitinSickle"] =
    {
        handles = { "Tri_W_Sickle_chitin_2", "Tri_W_Sickle_chitin_3", "Tri_W_Sickle_chitin_4" },
        blades  = { "Tri_W_Sickle_chitin_0", "Tri_W_Sickle_chitin_1", "Tri_W_Sickle_chitin_5" },
        rootIndexes = { 2, 2 }
    },
    ["AB_w_CookKnifeBone"] =
    {
        handles = { "Tri Handle" },
        blades  = { "Tri Blade" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_CookKnifeBread"] =
    {
        handles = { "Tri Handle" },
        blades  = { "Tri Blade" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_CookKnifeChef"] =
    {
        handles = { "Tri Handle" },
        blades  = { "Tri Blade" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_CookKnifeDinner"] =
    {
        handles = { "Tri Handle" },
        blades  = { "Tri Blade" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_DreughDagger"] =
    {
        handles = { "Object", "Object.001", "Object.003" },
        blades  = { "Object.002" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_DreughShortsword"] =
    {
        handles = { "Object", "Object.001", "Object.003" },
        blades  = { "Object.002", "Object.004" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_DwrvDagger"] =
    {
        handles = { "Tri Cube.001 0", "Tri Cube.001 1", "Tri Cube.001 1.001", "Tri Cube.001 2", "Tri Cube.001 4" },
        blades  = { "Tri Cube.001 3" },
        rootIndexes = { 3, 1 }
    },
    ["AB_w_DwrvSpectreSword"] =
    {
        handles = { "Object.001", "Object.002", "Object.003", "Object.004", "Object.005" },
        blades  = { "Object" },
        rootIndexes = { 5, 1 }
    },
    ["AB_w_EbonyDagger"] =
    {
        handles = { "Cube.000", "Tri Cube.000 0", "Tri Cube.000 1", "Tri Cube.000 2", "Tri Cube.000 4" },
        blades  = { "Tri Cube.000 3" },
        rootIndexes = { 5, 1 }
    },
    ["AB_w_EbonyTanto"] =
    {
        handles = { "Tri Cube.002 1", "Tri Cube.002 2", "Tri Cube.002 3", "Tri Cube.002 4", "Tri Cube.002 5", "Tri Cube.002 6" },
        blades  = { "Tri Cube.002 0" },
        rootIndexes = { 3, 1 }
    },
    ["AB_w_EbonyWakizashi"] =
    {
        handles = { "Cube", "Cube.001", "Cube.003", "Cube.004", "Cube.005", "Cube.006", "Cube.007" },
        blades  = { "Cube.002" },
        rootIndexes = { 7, 1 }
    },
    ["AB_w_FlintKnife"] =
    {
        handles = { "Tri Handle 1" },
        blades  = { "Head", "Rope.001" },
        rootIndexes = { 1, 2 }
    },
    ["AB_w_GlassTanto"] =
    {
        handles = { "a3.blade.004", "a3.blade.01", "a3.blade.02", "a3.blade.03" },
        blades  = { "Tri Cube 5", "Tri Cube.001 4" },
        rootIndexes = { 1, 2 }
    },
    ["AB_w_GlassWakizashi"] =
    {
        handles = { "a3.blade.01", "a3.blade.02", "a3.blade.03", "a3.blade.04", "Tri Cube.001 2", "Tri Cube.001 4.001" },
        blades  = { "Tri Cube 5", "Tri Cube.001 4" },
        rootIndexes = { 4, 2 }
    },
    ["AB_w_ImpTanto"] =
    {
        handles = { "Tri W_N_Katana 0", "Tri W_N_Katana 2", "Tri Katana 2" },
        blades  = { "Tri Katana 0" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_ImpWakizashi"] =
    {
        handles = { "Object", "Tri Katana 2", "Tri W_N_Katana 0", "Tri W_N_Katana 2" },
        blades  = { "Tri Katana 0" },
        rootIndexes = { 4, 1 }
    },
    ["AB_w_MarkingKnife"] =
    {
        handles = { "Tri Marking Knife 0", "Tri Marking Knife 1", "Tri Marking Knife 4" },
        blades  = { "Tri Marking Knife 3" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_SilverTanto"] =
    {
        handles = { "Tri Cube.001 1", "Tri Cube.001 1.001", "Tri Cube.001 2", "Tri Cube.001 3" },
        blades  = { "Tri Cube.001 0" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_SilverWakizashi"] =
    {
        handles = { "Tri Cube.001 0", "Tri Cube.001 0.001", "Tri Cube.001 2", "Tri Cube.001 3" },
        blades  = { "Tri Cube.001 1" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_StalhrimShortsword"] =
    {
        handles = { "W_Ice_shortsword.001", "W_Ice_shortsword.003" },
        blades  = { "W_Ice_shortsword.002" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_SteelShortSaber"] =
    {
        handles = { "Tri Cube 1", "Tri Cube 2", "Tri Cube 3", "Tri Cube 4", "Tri Cube 5" },
        blades  = { "Tri Cube 0" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ToolHandscythe00"] =
    {
        handles = { "Tri Handle", "Tri Tri Metal 2" },
        blades  = { "Tri Tri Metal 1" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ToolHandscythe01"] =
    {
        handles = { "Tri Handle" },
        blades  = { "Tri Blade", "Tri Handle.001" },
        rootIndexes = { 1, 2 }
    },
    ["AB_w_WoodStake"] =
    {
        handles = { "Cylinder", "Cylinder.001" },
        blades  = { "Cylinder.002", "Cylinder.003" },
        rootIndexes = { 1, 2 }
    }
}

interop:registerWeapons(weapons)