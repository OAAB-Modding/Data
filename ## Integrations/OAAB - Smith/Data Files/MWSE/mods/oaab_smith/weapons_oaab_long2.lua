local interop = require("sb_smith.interop")

---@type weapon[]
local weapons = {
    ["AB_w_DreughClaymore"] =
    {
        handles = { "Object", "Object.002", "Object.004" },
        blades  = { "Object.001", "Object.003" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_EbonyClaymore"] =
    {
        handles = { "Tri Tri w_ebony_claymore 0.001 3", "Tri Tri w_ebony_claymore 0.001 4", "Tri Tri w_ebony_claymore 0.001 5", "Tri Tri w_ebony_claymore 0.001 6", "Tri Tri w_ebony_claymore 0.001 7" },
        blades  = { "Tri Tri w_ebony_claymore 0.001 0", "Tri Tri w_ebony_claymore 0.001 1", "Tri Tri w_ebony_claymore 0.001 2" },
        rootIndexes = { 5, 1 }
    },
    ["AB_w_EbonyDaiKatana"] =
    {
        handles = { "Tri Cube.002 1", "Tri Cube.002 2", "Tri Cube.002 3", "Tri Cube.002 4", "Tri Cube.002 5", "Tri Cube.002 6" },
        blades  = { "Tri Cube.002 0" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_GlassDkatana"] =
    {
        handles = { "Tri Cube 0", "Tri Cube 1", "Tri Cube 2", "Tri Cube 4", "Tri Cube 6" },
        blades  = { "Tri Cube 3", "Tri Cube 5" },
        rootIndexes = { 4, 1 }
    },
    ["AB_w_GoldStClaymore"] =
    {
        handles = { "Tri Tri Surfe44 0 0", "Tri Tri Surfe44 0 2" },
        blades  = { "Tri Tri Surfe44 0 1" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_ImpDaiKatana"] =
    {
        handles = { "Tri Daikatana 1", "Tri Daikatana 2", "Tri Daikatana 3", "Tri Daikatana 4" },
        blades  = { "Tri Daikatana 0" },
        rootIndexes = { 3, 1 }
    },
    ["AB_w_SilverDaiKatana"] =
    {
        handles = { "Tri Cube.000 1", "Tri Cube.000 2", "Tri Cube.000 3", "Tri Cube.000 3.001", "Tri Cube.000 4" },
        blades  = { "Tri Cube.000 0" },
        rootIndexes = { 4, 1 }
    }
}

interop:registerWeapons(weapons)