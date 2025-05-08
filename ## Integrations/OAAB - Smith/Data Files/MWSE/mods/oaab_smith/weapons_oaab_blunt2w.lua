local interop = require("sb_smith.interop")

---@type weapon[]
local weapons = {
    ["AB_w_AshlGlassStaff"] =
    {
        handles = { "Tri AshlGlassStaff 3", "Tri AshlGlassStaff 5", "Tri AshlGlassStaff 6" },
        blades  = { "Tri AshlGlassStaff 0", "Tri AshlGlassStaff 1", "Tri AshlGlassStaff 2", "Tri AshlGlassStaff 4" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_AshlStaffAzura"] =
    {
        handles = { "Cube.001" },
        blades  = { "Cube", "Cube.002" },
        rootIndexes = { 1, 2 }
    },
    ["AB_w_AshlStaffBoethiah"] =
    {
        handles = { "Cube" },
        blades  = { "Cube.001" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_AshlStaffMephala"] =
    {
        handles = { "Tri Cube 0", "Tri Cube 1" },
        blades  = { "Tri Cube 2", "Tri Cube 3", "Tri Cube 4", "Tri Cube 5", "Tri Cube 6", "Tri Cube 7", "Tri Cube 8" },
        rootIndexes = { 1, 7 }
    },
    ["AB_w_ImpStaff"] =
    {
        handles = { "Tri Cube.002 0", "Tri Cube.002 4", "Tri Cube.002 5", "Tri Cube.002 6" },
        blades  = { "Tri Cube.002 1", "Tri Cube.002 2", "Tri Cube.002 3" },
        rootIndexes = { 1, 3 }
    },
    ["AB_w_ResinStaff"] =
    {
        handles = { "Resin" },
        blades  = { "Resin.001", "Crystal" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ToolFishingNet"] =
    {
        handles = { "Object.002", "Object.005", "Object.006" },
        blades  = { "Object", "Object.001", "Object.003", "Object.004", },
        rootIndexes = { 1, 4 }
    }
}

interop:registerWeapons(weapons)