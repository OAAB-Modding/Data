local interop = require("sb_smith.interop")

---@type weapon[]
local weapons = {
    ["AB_w_AshlGlassSpear"] =
    {
        handles = { "Tri AshlGlassSpear 1", "Tri AshlGlassSpear 3", "Tri AshlGlassSpear 5" },
        blades  = { "Tri AshlGlassSpear 0", "Tri AshlGlassSpear 2", "Tri AshlGlassSpear 4", "Tri AshlGlassSpear 6" },
        rootIndexes = { 1, 3 }
    },
    ["AB_w_ChitinHalberd"] =
    {
        handles = { "Tri_w_chitin_halberd_3", "Tri_w_chitin_halberd_4", "Tri_w_chitin_halberd_5", "Tri_w_chitin_halberd_6", "Tri_w_chitin_halberd_7" },
        blades  = { "Tri_w_chitin_halberd_0", "Tri_w_chitin_halberd_1", "Tri_w_chitin_halberd_2" },
        rootIndexes = { 5, 2 }
    },
    ["AB_w_ChitinLongspear"] =
    {
        handles = { "Tri Cube 0", "Tri Cube 3" },
        blades  = { "Tri Cube 1", "Tri Cube 2" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_DaedricHalberd"] =
    {
        handles = { "Cube.001", "Cylinder", "Cylinder.002", "Cylinder.003", "Cylinder.006" },
        blades  = { "Cube", "Cylinder.001", "Plane.002", "Plane.003" },
        rootIndexes = { 2, 2 }
    },
    ["AB_w_DaeLongpear"] =
    {
        handles = { "Tri W_longspear_daedric 0", "Tri W_longspear_daedric 1", "Tri W_longspear_daedric 2", "Tri W_longspear_daedric 4", "Tri W_longspear_daedric 5" },
        blades  = { "Tri W_longspear_daedric 3" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_DreughHalberd"] =
    {
        handles = { "Object" },
        blades  = { "Object.001", "Object.002", "Object.003" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_DreughSpear"] =
    {
        handles = { "Object.001" },
        blades  = { "Object", "Object.002", "Object.003" },
        rootIndexes = { 1, 2 }
    },
    ["AB_w_DwrvLongspear"] =
    {
        handles = { "Tri W_Dwemer_longspear 0", "Tri W_Dwemer_longspear 1", "Tri W_Dwemer_longspear 2", "Tri W_Dwemer_longspear 3", "Tri W_Dwemer_longspear 4", "Tri W_Dwemer_longspear 6", },
        blades  = { "Tri W_Dwemer_longspear 5", "Tri W_Dwemer_longspear 7" },
        rootIndexes = { 6, 1 }
    },
    ["AB_w_EbonyGlaive"] =
    {
        handles = { "Object", "Object.003", "Object.004" },
        blades  = { "Object.001", "Object.002" },
        rootIndexes = { 3, 2 }
    },
    ["AB_w_EbonyHalberd"] =
    {
        handles = { "Tri Plane.000 1", "Tri Plane.000 4", "Tri Plane.000 8", "Tri Plane.000 10", "Tri Plane.000 11" },
        blades  = { "Tri Plane.000 0", "Tri Plane.000 2", "Tri Plane.000 3", "Tri Plane.000 5", "Tri Plane.000 6", "Tri Plane.000 7", "Tri Plane.000 9" },
        rootIndexes = { 2, 3 }
    },
    ["AB_w_EggminerHook"] =
    {
        handles = { "Tri Pole" },
        blades  = { "Tri Hook" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_FlintSpear"] =
    {
        handles = { "Rope.001", "Tri Handle 1", "Tri Handle 0.002" },
        blades  = { "Head.001", "Rope.002" },
        rootIndexes = { 3, 2 }
    },
    ["AB_w_GlassSpear"] =
    {
        handles = { "Tri Plane.003 1", "Tri Plane.003 3", "Tri Plane.003 4.004" },
        blades  = { "Tri Plane.003 0", "Tri Plane.003 2", "Tri Plane.003 4.001", "Tri Plane.003 4.002" },
        rootIndexes = { 3, 2 }
    },
    ["AB_w_ImpSpear"] =
    {
        handles = { "Tri Plane 1", "Tri Plane 2", "Tri Plane 3", "Tri Plane 4", "Tri Plane 7", "Tri Plane 8" },
        blades  = { "Tri Plane 0", "Tri Plane 5", "Tri Plane 6" },
        rootIndexes = { 2, 2 }
    },
    ["AB_w_NordicLongAxe"] =
    {
        handles = { "Object", "Object.003", "Object.005" },
        blades  = { "Object.001", "Object.002", "Object.004" },
        rootIndexes = { 1, 2 }
    },
    ["AB_w_NordicSilverSpear"] =
    {
        handles = { "W_Nord_spear.001" },
        blades  = { "W_Nord_spear.002" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_SilverHalberd"] =
    {
        handles = { "Tri Sphere.001 1", "Tri Sphere.001 6", "Tri Sphere.001 7", "Tri Sphere.001 8" },
        blades  = { "Tri Sphere.001 0", "Tri Sphere.001 2", "Tri Sphere.001 3", "Tri Sphere.001 4", "Tri Sphere.001 5" },
        rootIndexes = { 2, 3 }
    },
    ["AB_w_SixthSpear"] =
    {
        handles = { "Tri Cube.000 1", "Tri Cube.000 3", "Tri Cube.000 4", "Tri Cube.000 5", "Tri Cube.000 6", "Tri Cube.000 7", "Tri Cube.000 9" },
        blades  = { "Tri Cube.000 0", "Tri Cube.000 2", "Tri Cube.000 8", "Tri Cube.000 10" },
        rootIndexes = { 5, 2 }
    },
    ["AB_w_StalhrimSpear"] =
    {
        handles = { "W_Ice_spear.001" },
        blades  = { "W_Ice_spear.002" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ToolHoe"] =
    {
        handles = { "Sphere.002" },
        blades  = { "Sphere" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ToolPitchfork"] =
    {
        handles = { "PitchFork:0" },
        blades  = { "PitchFork:7" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ToolRake"] =
    {
        handles = { "Sphere.003" },
        blades  = { "Sphere.001" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ToolScythe"] =
    {
        handles = { "Tri Handle" },
        blades  = { "Tri Blade" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ToolShovel"] =
    {
        handles = { "Sphere.004" },
        blades  = { "Circle.001" },
        rootIndexes = { 1, 1 }
    }
}

interop:registerWeapons(weapons)