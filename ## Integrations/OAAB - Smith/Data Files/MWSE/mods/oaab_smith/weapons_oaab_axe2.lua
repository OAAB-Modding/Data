local interop = require("sb_smith.interop")

---@type weapon[]
local weapons = {
    ["AB_w_DreughBattleAxe"] =
    {
        handles = { "Handle" },
        blades  = { "Blade 1", "Blade 2", "Blade 3" },
        rootIndexes = { 1, 3 }
    },
    ["AB_w_FlintAxe"] =
    {
        handles = { "Handle", "Ends" },
        blades  = { "Head", "Tri Rope 0", "Tri Rope 1", "Tri Rope 2" },
        rootIndexes = { 1, 3 }
    },
    ["AB_w_FlintPickaxe"] =
    {
        handles = { "Tri Handle 0", "Tri Handle 1" },
        blades  = { "Head", "Rope", "Tri Handle 0.002", "Tri Handle 0.003" },
        rootIndexes = { 2, 4 }
    },
    ["AB_w_GlassBattleAxe"] =
    {
        handles = { "Tri Cube.001 0", "Tri Cube.001 7", "Tri Cube.001 8" },
        blades  = { "Tri Cube.001 1", "Tri Cube.001 2", "Tri Cube.001 3", "Tri Cube.001 4", "Tri Cube.001 5", "Tri Cube.001 6",  },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_ImpEtool"] =
    {
        handles = { "Tri Tri Tri W_miner_pick 0 0 0", "Tri W_miner_pick 2" },
        blades  = { "Tri Tri Tri W_miner_pick 0 0 1", "Tri W_miner_pick 1" },
        rootIndexes = { 2, 2 }
    },
    ["AB_w_StalhrimBattleaxe"] =
    {
        handles = { "Tri_w_battleaxe_ice" },
        blades  = { "Tri_w_battleaxe_ice.001" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ToolEbonyPick"] =
    {
        handles = { "Tri Cylinder.006 2", "Tri Cylinder.006 3", "Tri Cylinder.006 4", "Tri Cylinder.006 6" },
        blades  = { "Tri Cylinder.006 0", "Tri Cylinder.006 1", "Tri Cylinder.006 5", "Tri Cylinder.006 7" },
        rootIndexes = { 4, 3 }
    }
}

interop:registerWeapons(weapons)