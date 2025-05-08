local interop = require("sb_smith.interop")

---@type weapon[]
local weapons = {
    ["AB_w_ChitinGreatmace"] =
    {
        handles = { "Tri Cube.003 3", "Tri Cube.003 3.001", "Tri Cube.003 4" },
        blades  = { "Tri Cube.003 0", "Tri Cube.003 1", "Tri Cube.003 1.001", "Tri Cube.003 2" },
        rootIndexes = { 2, 3 }
    },
    ["AB_w_DreughGreatmace"] =
    {
        handles = { "Object", "Object.003" },
        blades  = { "Object.001", "Object.002" },
        rootIndexes = { 2, 2 }
    },
    ["AB_w_EbonyWarhammer"] =
    {
        handles = { "Tri Cube 0", "Tri Cube 1", "Tri Cube 5", "Tri Cube 8", "Tri Cube 9" },
        blades  = { "Tri Cube 2", "Tri Cube 3", "Tri Cube 4", "Tri Cube 6", "Tri Cube 7" },
        rootIndexes = { 4, 5 }
    },
    ["AB_w_GlassWarhammer"] =
    {
        handles = { "Tri Tri Cube.003 0.002 6", "Tri Tri Cube.003 0.002 7", "Tri Tri Cube.003 0.002 8" },
        blades  = { "Tri Tri Cube.003 0.002 0", "Tri Tri Cube.003 0.002 1", "Tri Tri Cube.003 0.002 2", "Tri Tri Cube.003 0.002 3", "Tri Tri Cube.003 0.002 4", "Tri Tri Cube.003 0.002 5" },
        rootIndexes = { 2, 3 }
    },
    ["AB_w_SilverWarhammer"] =
    {
        handles = { "Tri Cube.001 0", "Tri Cube.001 1", "Tri Cube.001 3" },
        blades  = { "Tri Cube.001 2" },
        rootIndexes = { 2, 1 }
    }
}

interop:registerWeapons(weapons)