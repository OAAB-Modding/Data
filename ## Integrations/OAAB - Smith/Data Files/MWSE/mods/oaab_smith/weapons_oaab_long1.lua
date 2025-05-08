local interop = require("sb_smith.interop")

---@type weapon[]
local weapons = {
    ["AB_w_AdamRapier"] =
    {
        handles = { "Handle 1", "Handle 2", "Handle 3", "Handle 4", "Handle 5" },
        blades  = { "Blade" },
        rootIndexes = { 4, 1 }
    },
    ["AB_w_AshlGlassLongsword"] =
    {
        handles = { "Tri AshlGlassLSword 1", "Tri AshlGlassLSword 2", "Tri AshlGlassLSword 4" },
        blades  = { "Tri AshlGlassLSword 0", "Tri AshlGlassLSword 3" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_BoneSaw"] =
    {
        handles = { "Tri Bonesaw 0", "Tri Bonesaw 1" },
        blades  = { "Tri Bonesaw 2" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ChitinLongsword"] =
    {
        handles = { "Tri Cube 0", "Tri Cube 1", "Tri Cube 2", "Tri Cube 3" },
        blades  = { "Tri Cube 4", "Tri Cube 5", "Tri Cube 6" },
        rootIndexes = { 4, 2 }
    },
    ["AB_w_DaedricRapier"] =
    {
        handles = { "BezierCurve", "Tri W_Claymore_Daedric 4.002", "Tri W_Claymore_Daedric 5.001", "Tri W_Longsword_Daedric 2.003", "Tri W_Shortsword_Daedric 4.002" },
        blades  = { "Tri W_Claymore_Daedric 4.001", "Tri W_Claymore_Daedric 4.003", "Tri W_Claymore_Daedric 4.004", "Tri W_Shortsword_Daedric 4.001" },
        rootIndexes = { 4, 1 }
    },
    ["AB_w_DreughLongsword"] =
    {
        handles = { "Object", "Object.001", "Object.002", "Object.004" },
        blades  = { "Object.003" },
        rootIndexes = { 4, 1 }
    },
    ["AB_w_DwrvLongsword"] =
    {
        handles = { "Tri Cube.003 0", "Tri Cube.003 0.001", "Tri Cube.003 1", "Tri Cube.003 2", "Tri Cube.003 5", "Tri Cube.003 6" },
        blades  = { "Tri Cube.003 3", "Tri Cube.003 4" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_EbonyKatana"] =
    {
        handles = { "Tri Cube.002 1", "Tri Cube.002 2", "Tri Cube.002 3", "Tri Cube.002 4", "Tri Cube.002 5", "Tri Cube.002 6" },
        blades  = { "Tri Cube.002 0" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_GlassKatana"] =
    {
        handles = { "Tri Cube.001 0", "Tri Cube.001 2", "Tri Cube.001 3", "Tri Cube.001 4", "Tri Cube.001 6", "Tri Cube.001 7" },
        blades  = { "Tri Cube.001 1", "Tri Cube.001 5" },
        rootIndexes = { 5, 1 }
    },
    ["AB_w_GlassRapier"] =
    {
        handles = { "Tri W_staff_glass 13.001", "Tri W_staff_glass 13.002", "Tri W_staff_glass 13.003", "Tri W_staff_glass 13.004", "Tri W_staff_glass 13.005", "Tri W_staff_glass 13.006" },
        blades  = { "Tri W_staff_glass 13.007" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_GlassSaber"] =
    {
        handles = { "Tri Cube 0", "Tri Cube 2", "Tri Cube 3", "Tri Cube 4" },
        blades  = { "Tri Cube 1" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_ImpKatana"] =
    {
        handles = { "Tri Katana 1", "Tri Katana 2", "Tri Katana 3", "Tri Katana 4" },
        blades  = { "Tri Katana 0" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_ImpLongsword"] =
    {
        handles = { "Tri Cube.000 0", "Tri Cube.000 1", "Tri Cube.000 2", "Tri Cube.000 2.001" },
        blades  = { "Tri Cube.000 3" },
        rootIndexes = { 4, 1 }
    },
    ["AB_w_IronRapier"] =
    {
        handles = { "Cylinder.002", "Cylinder.003", "Cylinder.004" },
        blades  = { "Cylinder.001" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_Machete"] =
    {
        handles = { "Tri Machete 0", "Tri Machete 1" },
        blades  = { "Tri Machete 2" },
        rootIndexes = { 1, 1 }
    },
    ["AB_w_SilverKatana"] =
    {
        handles = { "Tri Cube.004 0", "Tri Cube.004 0.001", "Tri Cube.004 1", "Tri Cube.004 2", "Tri Cube.004 3" },
        blades  = { "Tri Cube.004 1" },
        rootIndexes = { 2, 1 }
    },
    ["AB_w_SilverRapier"] =
    {
        handles = { "BezierCurve.005", "BezierCurve.006", "BezierCurve.004", "Sphere1", "Sphere2" },
        blades  = { "Tri W_Longsword_Silver 0", "Tri W_Longsword_Silver 1" },
        rootIndexes = { 5, 2 }
    },
    ["AB_w_SteelRapier"] =
    {
        handles = { "Cube.003", "Cylinder.001", "Cylinder.004", "Sphere", "Sphere.002", "Sphere.003" },
        blades  = { "Sphere.001" },
        rootIndexes = { 4, 2 }
    },
    ["AB_w_Wood Sword"] =
    {
        handles = { "Tri woodensword 0", "Tri woodensword 0.001", "Tri woodensword 1" },
        blades  = { "Tri woodensword 2" },
        rootIndexes = { 2, 1 }
    }
}

interop:registerWeapons(weapons)