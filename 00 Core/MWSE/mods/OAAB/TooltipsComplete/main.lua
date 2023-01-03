local tooltipsComplete = include("Tooltips Complete.interop")
local tooltipData = {
    { id = "ab_dri_sillapi", description = "Sillapi is an egg miner's drink, sometimes used as a medicine as it can dull the pain and induce tranquil sleep. It's brewed from various kwama products, often right in the mines, and traditionally stored in a jug made of a treated kwama egg.", itemType = "ingredients" },
	{ id = "ab_ingcrea_dungcake", description = "A flat, crumbly patty made of dried manure. Has a slight musky smell.", itemType = "ingredients" },
	{ id = "ab_c_commonamulet02", description = "A common amulet fashioned from slaughterfish teeth. The teeth have an iridescent coating which makes them popular adornments.", itemType = "clothing" },
	{ id = "ab_misc_sfishhead", description = "A severed slaughterfish head. Frequently used as chum to attract other slaughterfish.", itemType = "miscItem" },
	{ id = "AB_w_AshlEbonyArrow10x", description = "Attack: 3 - 5", itemType = "miscItem" },
	{ id = "AB_w_AshlGlassArrow10x", description = "Attack: 1 - 5", itemType = "miscItem" },
	{ id = "AB_w_BoneArrow10x", description = "Attack: 2 - 3", itemType = "miscItem" },
	{ id = "AB_w_BonemoldArrow10x", description = "Attack: 1 - 4", itemType = "miscItem" },
	{ id = "AB_w_ChitinArrow10x", description = "Attack: 1 - 2", itemType = "miscItem" },
	{ id = "AB_w_CorkbulbArrow10x", description = "Attack: 1 - 1", itemType = "miscItem" },
	{ id = "AB_w_DaedricArrow10x", description = "Attack: 10 - 15", itemType = "miscItem" },
	{ id = "AB_w_DreughArrow10x", description = "Attack: 1 - 5", itemType = "miscItem" },
	{ id = "AB_w_EbonyArrow10x", description = "Attack: 5 - 10", itemType = "miscItem" },
	{ id = "AB_w_FlintArrow10x", description = "Attack: 1 - 2", itemType = "miscItem" },
	{ id = "AB_w_GlassArrow10x", description = "Attack: 1 - 6", itemType = "miscItem" },
	{ id = "AB_w_GoblinArrow10x", description = "Attack: 6 - 12", itemType = "miscItem" },
	{ id = "AB_w_HuntsArrow10x", description = "Attack: 1 - 5", itemType = "miscItem" },
	{ id = "AB_w_IronArrow10x", description = "Attack: 1 - 3", itemType = "miscItem" },
	{ id = "AB_w_OrcishArrow10x", description = "Attack: 3 - 5", itemType = "miscItem" },
	{ id = "AB_w_SilverArrow10x", description = "Attack: 1 - 3", itemType = "miscItem" },
	{ id = "AB_w_StalhrimArrow10x", description = "Attack: 9 - 16", itemType = "miscItem" },
	{ id = "AB_w_SteelArrow10x", description = "Attack: 1 - 4", itemType = "miscItem" }
}
local function initialized()
    if tooltipsComplete then
        for _, data in ipairs(tooltipData) do
            tooltipsComplete.addTooltip(data.id, data.description, data.itemType)
        end
    end
end
event.register("initialized", initialized)