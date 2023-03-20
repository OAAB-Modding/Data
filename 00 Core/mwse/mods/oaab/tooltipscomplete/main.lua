local tooltipsComplete = include("Tooltips Complete.interop")
local tooltipData = {

	-- Ingredients:
    { id = "ab_dri_sillapi", description = "Sillapi is an egg miner's drink, sometimes used as a medicine as it can dull the pain and induce tranquil sleep. It's brewed from various kwama products, often right in the mines, and traditionally stored in a jug made of a treated kwama egg.", itemType = "ingredients" },
	{ id = "ab_ingcrea_dungcake", description = "A flat, crumbly patty made of dried manure. Has a slight musky smell.", itemType = "ingredients" },
	
	-- Clothing:
	{ id = "ab_c_commonamulet02", description = "A common amulet fashioned from slaughterfish teeth. The teeth have an iridescent coating which makes them popular adornments.", itemType = "clothing" },
	{ id = "ab_c_dwemeramuletclock", description = "A small ornate device of Dwemer make. The intricate mechanisms inside seem to still move in the same rhythm even after millenia.", itemType = "clothing" },
	
	-- Miscellaneous:
	{ id = "ab_misc_scalesbrass", description = "An unassuming, robust pair of weighing scales made of matte brass, with slight metal sheen. In Tamriel, scales like these are commonly seen as a symbol of both justice and commerce.", itemType = "miscItem" },
	{ id = "ab_misc_scalesbrassskew", description = "An unassuming, robust pair of weighing scales made of matte brass, with slight metal sheen. In Tamriel, scales like these are commonly seen as a symbol of both justice and commerce.", itemType = "miscItem" },
	{ id = "ab_misc_scalesbrasswght", description = "A tiny brass weight made to be used with weighing scales.", itemType = "miscItem" },
	{ id = "ab_misc_scalesbrasswghtbig", description = "A small brass weight made to be used with weighing scales.", itemType = "miscItem" },	
	
	{ id = "ab_misc_scalessilver", description = "An elegant pair of small weighing scales crafted from silver and polished to a shine. In Tamriel, scales like these are commonly seen as a symbol of both justice and commerce.", itemType = "miscItem" },
	{ id = "ab_misc_scalessilverskew", description = "An elegant pair of small weighing scales crafted from silver and polished to a shine. In Tamriel, scales like these are commonly seen as a symbol of both justice and commerce.", itemType = "miscItem" },
	{ id = "ab_misc_scalessilverwght", description = "A tiny silver weight made to be used with weighing scales.", itemType = "miscItem" },
	{ id = "ab_misc_scalessilverwghtbig", description = "A small silver weight made to be used with weighing scales.", itemType = "miscItem" },
	
	{ id = "ab_misc_sfishhead", description = "A severed slaughterfish head. Frequently used as chum to attract other slaughterfish.", itemType = "miscItem" },
	{ id = "ab_misc_shackles", description = "A simple, cheap, yet quite effective type of restraint, all too familiar to both criminal and slave.", itemType = "miscItem" },
	
	-- Weapons:
	{ id = "ab_w_dreughshortbow", description = "A smaller-sized bow made from springy Dreugh cartilage. Has some viscosity to its movements, compared to bows of different material.", itemType = "weapon" },	
	{ id = "ab_w_dwrvstar", description = "A disc-shaped thrown blade of Dwemer make. Still maintains its razor sharpness and metallic sheen.", itemType = "weapon" },
	{ id = "ab_w_dwrvknife", description = "A small knife made of Dwemer metal, designed for throwing. Would probably feel a bit too heavy if not for its well-calculated balance.", itemType = "weapon" },
	{ id = "ab_w_dwrvtoolcrowbar", description = "An old rusty crow bar made by the Dwemer. Hefty and sturdy, it might come in handy when trying to operate, or break down, their ancient machines.", itemType = "weapon" },
	
	-- Arrow quivers:
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