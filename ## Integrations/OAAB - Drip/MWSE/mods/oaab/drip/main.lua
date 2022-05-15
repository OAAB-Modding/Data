--OAAB
local materials = require("oaab.drip.config.materials")
for _, pattern in ipairs(materials) do
    interop.registerMaterialPattern(pattern)
end
local weapons = require("oaab.drip.config.weapons")
for _, weapon in ipairs(weapons) do
    interop.registerWeapon(weapon)
end
local armor = require("oaab.drip.config.armor")
for _, armor in ipairs(armor) do
    interop.registerArmor(armor)
end
local clothing = require("oaab.drip.config.clothing")
for _, clothing in ipairs(clothing) do
    interop.registerClothing(clothing)
end
