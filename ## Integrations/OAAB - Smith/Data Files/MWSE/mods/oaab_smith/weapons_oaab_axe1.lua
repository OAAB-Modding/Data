local interop = require("sb_smith.interop")

---@type weapon[]
local weapons = {
    ["AB_w_AshlGlassWarAxe"] =
    {
        handles = { "Tri AshlGlassWarAxe 2" },
        blades  = { "Tri AshlGlassWarAxe 0", "Tri AshlGlassWarAxe 1", "Tri AshlGlassWarAxe 3", "Tri Tri AshlGlassWarAxe 4 0", "Tri Tri AshlGlassWarAxe 4 1" },
        rootIndexes = { 1, 4 }
    },
    ["AB_w_CookKnifeCleave"] =
    {
        handles = { "Tri Handle" },
        blades  = { "Tri Blade" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_DreughWarAxe"] =
    {
        handles = { "Handle" },
        blades  = { "Blade 1", "Blade 2", "Blade 3", "Blade 4" },
        rootIndexes = { 1, 3 }
    },
    ["AB_w_DwrvToolCrowbar"] =
    {
        handles = { "Tri Tri BezierCurve.003 0 0", "Tri Tri BezierCurve.003 0 1" },
        blades  = { "Tri BezierCurve.003 1" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ImpWarAxe"] =
    {
        handles = { "Tri Cube.001 0", "Tri Cube.001 3", "Tri Cube.001 5" },
        blades  = { "Tri Cube.001 1", "Tri Cube.001 2", "Tri Cube.001 4" },
        rootIndexes = { 1, 3 }
    },
    ["AB_w_ToolClimbingPick"] =
    {
        handles = { "Object", "Object.001", "Object.002" },
        blades  = { "Object.003", "Object.004" },
        rootIndexes = { 1, 2 }
    },
    ["AB_w_ToolFireplacePoker"] =
    {
        handles = { "FireplacePoker" },
        blades  = { "FireplacePoker.001" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ToolWoodAxe"] =
    {
        handles = { "Handle" },
        blades  = { "Axehead" },
        rootIndexes = { 1, 1 }
    }
}

interop:registerWeapons(weapons)