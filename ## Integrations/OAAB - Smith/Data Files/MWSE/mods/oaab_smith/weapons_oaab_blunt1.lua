local interop = require("sb_smith.interop")

---@type weapon[]
local weapons = {
    ["AB_w_AshlGlassClub"] =
    {
        handles = { "Tri AshlGlassClub 2" },
        blades  = { "Tri AshlGlassClub 0", "Tri AshlGlassClub 1", "Tri AshlGlassClub 3", "Tri Tri AshlGlassClub 4 0", "Tri Tri AshlGlassClub 4 1" },
        rootIndexes = { 1, 3 }
    },
    ["AB_w_BoneScepter"] =
    {
        handles = { "Tri Cylinder.001 0", "Tri Cylinder.001 2" },
        blades  = { "Tri Cylinder.001 1", "Tri Cylinder.001 3", "Tri Cylinder.001 4", "Tri Cylinder.001 5" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_ChitinMace"] =
    {
        handles = { "Tri_W_chitin_mace_0", "Tri_W_chitin_mace_5" },
        blades  = { "Tri_W_chitin_mace_1", "Tri_W_chitin_mace_2", "Tri_W_chitin_mace_3", "Tri_W_chitin_mace_4" },
        rootIndexes = { 1, 4 }
    },
    ["AB_w_DaedricScepter"] =
    {
        handles = { "Object.003", "Object.004", "Object.005" },
        blades  = { "Object", "Object.002", "Object.006" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_DreughMace"] =
    {
        handles = { "Handle" },
        blades  = { "Blade 1", "Blade 2", "Blade 3", "Blade 4" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_DwrvScepter"] =
    {
        handles = { "Tri Object.004 0", "Tri Object.004 1" },
        blades  = { "Object", "Object.001", "Object.002", "Object.003", "Object.004", "Tri Object.005 0", "Tri Object.005 1" },
        rootIndexes = { 1, 6 }
    },
    ["AB_w_DwrvSpectreHammer"] =
    {
        handles = { "Handle" },
        blades  = { "Head" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_EbonyScepter"] =
    {
        handles = { "Object.004", "Object.005", "Object.006", "Object.008" },
        blades  = { "Object", "Object.001", "Object.002", "Object.003", "Object.007" },
        rootIndexes = { 2, 5 }
    },
    ["AB_w_GlassMace"] =
    {
        handles = { "Tri Cube.003 1", "Tri Cube.003 3" },
        blades  = { "Tri Cube.003 0", "Tri Cube.003 2", "Tri Cube.003 4" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_GlassScepter"] =
    {
        handles = { "Object.002", "Object.004", "Object.005" },
        blades  = { "Object", "Object.001", "Object.003" },
        rootIndexes = { 1, 2 }
    },
    ["AB_w_ImpClub"] =
    {
        handles = { "Tri Cube 0", "Tri Cube 1", "Tri Cube 2" },
        blades  = { "Tri Cube 3", "Tri Cube 4" },
        rootIndexes = { 2, 2 }
    },
    ["AB_w_ImpMace"] =
    {
        handles = { "Cube", "Cube.001" },
        blades  = { "Cube.002", "Cube.003" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_NordicMace"] =
    {
        handles = { "Tri Tri Cylinder 7 0", "Tri Tri Cylinder 7 1", "Tri Tri Cylinder 7 3", "Tri Tri Cylinder 7 4", "Tri Tri Cylinder 7 5", "Tri Tri Cylinder 7 1.002", "Tri Tri Cylinder 7 3.002", "Tri Tri Cylinder 7 6.001" },
        blades  = { "Tri Tri Cylinder 7 2", "Tri Tri Cylinder 7 6", "Tri Tri Cylinder 7 1.001", "Tri Tri Cylinder 7 3.001" },
        rootIndexes = { 6, 4 }
    },
    ["AB_w_OrcishMace"] =
    {
        handles = { "Tri Tri Cylinder.003 5 2", "Tri Tri Cylinder.003 5 3", "Tri Tri Cylinder.003 5 4", "Tri Tri Cylinder.003 5 5" },
        blades  = { "Tri Tri Cylinder.003 5 0", "Tri Tri Cylinder.003 5 1", "Tri Tri Cylinder.003 5 2.001" },
        rootIndexes = { 3, 2 }
    },
    ["AB_w_SilverScepter"] =
    {
        handles = { "Object.003", "Object.004", "Object.006", "Object.009", "Object.010" },
        blades  = { "Object", "Object.001", "Object.002", "Object.005", "Object.007", "Object.008" },
        rootIndexes = { 5, 4 }
    },
    ["AB_w_ToolFireplaceBrush"] =
    {
        handles = { "Tri FireplacePoker.001 0" },
        blades  = { "Tri FireplacePoker.001 1", "Tri FireplacePoker.001 2" },
        rootIndexes = { 1, 2 }
    },
    ["AB_w_ToolFireplaceShovel"] =
    {
        handles = { "Tri FireplaceShovel 0" },
        blades  = { "Tri FireplaceShovel 1", "Tri FireplaceShovel 2" },
        rootIndexes = { 1, 2 }
    },
    ["AB_w_ToolHammer"] =
    {
        handles = { "Handle 1", "Handle 2" },
        blades  = { "Head" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_ToolSmithHammer"] =
    {
        handles = { "Tri misc_hammer10 1", "Tri misc_hammer10 2" },
        blades  = { "Tri misc_hammer10 0" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_WoodClub"] =
    {
        handles = { "Tri W_chitin_club 0", "Tri W_chitin_club 1" },
        blades  = { "Tri W_chitin_club 2", "Tri W_chitin_club 3" },
        rootIndexes = { 1, 2 }
    }
}

interop:registerWeapons(weapons)