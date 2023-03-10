local ashfall = include("mer.ashfall.interop")
if ashfall then

    ashfall.registerActivators{
		AB_Flora_AshTree_01 = "tree",
		AB_Flora_AshTree_02 = "tree",
		AB_Flora_ParasolMid01 = "tree",
		AB_Flora_ParasolMid02 = "tree",
		AB_Flora_ParasolMid03 = "tree",
		AB_Flora_TramaHedge_01 = "tree",
		AB_Flora_TramaHedge_02 = "tree",
		AB_Furn_ComBucket02Water = "water",
		AB_Furn_Barrel01Water = "water",
		AB_Furn_LwBowlWater = "water",
		AB_Ex_VelWellFountain = "well",
		AB_Fx_WaterCircle1024 = "waterDirty",
		AB_Fx_WaterCircle128 = "waterDirty",
		AB_Fx_WaterCircle2048 = "waterDirty",
		AB_Fx_WaterCircle256 = "waterDirty",
		AB_Fx_WaterCircle512 = "waterDirty",
		AB_Fx_WaterCircle64 = "waterDirty",
		AB_Fx_WaterFallMid = "waterDirty",
		AB_Fx_WaterFallSmall = "waterDirty",
		AB_Fx_WaterFallStreamCanal = "waterDirty",
		AB_Fx_WaterFallStreamMid = "waterDirty",
		AB_Fx_WaterFallTall = "waterDirty",
		AB_Fx_WaterFlowCv256a = "waterDirty",
		AB_Fx_WaterFlowCv256b = "waterDirty",
		AB_Fx_WaterFlowCv512a = "waterDirty",
		AB_Fx_WaterFlowCv512b = "waterDirty",
		AB_Fx_WaterFlowSq1024 = "waterDirty",
		AB_Fx_WaterFlowSq256 = "waterDirty",
		AB_Fx_WaterFlowSq512 = "waterDirty",
		AB_Fx_WaterFlowSt256a = "waterDirty",
		AB_Fx_WaterFlowSt256b = "waterDirty",
		AB_Fx_WaterFlowSt256c = "waterDirty",
		AB_Fx_WaterRapid = "waterDirty",
		AB_Fx_WaterRapidCv256a = "waterDirty",
		AB_Fx_WaterRapidCv256b = "waterDirty",
		AB_Fx_WaterRapidCv512a = "waterDirty",
		AB_Fx_WaterRapidCv512b = "waterDirty",
		AB_Fx_WaterRapidSt256a = "waterDirty",
		AB_Fx_WaterRapidSt256b = "waterDirty",
		AB_Fx_WaterRapidSt256c = "waterDirty",
		AB_Fx_WaterRect256a = "waterDirty",
		AB_Fx_WaterRect256b = "waterDirty",
		AB_Fx_WaterRect256c = "waterDirty",
		AB_Fx_WaterSquare1024 = "waterDirty",
		AB_Fx_WaterSquare256 = "waterDirty",
		AB_Fx_WaterSquare512 = "waterDirty",
		AB_Ex_HlaWell01 = "well",
		AB_Terr_StreamGravelBendL = "partial",
		AB_Terr_StreamGravelBendR = "partial",
		AB_Terr_StreamGravelLong = "partial",
		AB_Terr_StreamGravelShort01 = "partial",
		AB_Terr_StreamGravelShort02 = "partial",
		AB_Terr_StreamGravelSplit = "partial"
    }

    ashfall.registerWaterContainers{
        ab_misc_6thmug = "mug",
        ab_misc_combottle_01 = "bottle",
        ab_misc_combottle_02 = "bottle",
        ab_misc_combottle_03 = "bottle",
		AB_Misc_ComBottleR01 = "bottle",
		AB_Misc_ComBottleR02 = "bottle",
		AB_Misc_ComBottleR03 = "bottle",
		AB_Misc_ComBottleR04 = "bottle",
		AB_Misc_ComBottleR05 = "bottle",
		AB_Misc_ComBottleR06 = "bottle",
		ab_misc_comkagoutihorn = "flask",
        ab_misc_compewtercup01 = "cup",
        ab_misc_compewterpot_01 = "pot",
        ab_misc_comsilverpot_01 = "pot",
        ab_misc_comsilvertank_01 = "tankard",
        ab_misc_comwoodtankard = "tankard",
		ab_misc_daegoblet_01 = "goblet",
        ab_misc_debluecup_01 = "cup",
        ab_misc_deblueflask_01 = "flask",
        ab_misc_deblueflask_02 = "flask",
        ab_misc_deblueglass_01 = "glass",
        ab_misc_deblueglasscup_01 = "cup",
        ab_misc_debluetankard_01 = "tankard",
        ab_misc_deceramiccup_01 = "cup",
        ab_misc_deceramiccup_02 = "cup",
        ab_misc_deceramicflask_01 = "flask",
        ab_misc_deceramicpot_01 = "pot",
        ab_misc_declaycup_01 = "cup",
        ab_misc_declayflask_01 = "flask",
        ab_misc_declayflask_02 = "flask",
		ab_misc_decrglasscup_01 = "cup",
		ab_misc_decrglassflask_01 = "flask",
		ab_misc_decrglasspot_01 = "pot",
        ab_misc_deebonycup_01 = "cup",
        ab_misc_deebonyflask_01 = "flask",
        ab_misc_deebonyglass_01 = "glass",
        ab_misc_degreenglasscup_01 = "cup",
        ab_misc_degreenpitcher = "pitcher",
        ab_misc_degreenpot = "pot",
        ab_misc_depeachglascup_01 = "cup",
		ab_misc_deredglasscup_01 = "cup",
		ab_misc_deredglassflask_01 = "flask",
		ab_misc_deredglasspot_01 = "pot",
        ab_misc_deyelglasscup_01 = "cup",
        ab_misc_deyelglassflask_01 = "flask",
        ab_misc_deyelglasspot_01 = "pot",
        ab_misc_drinkcyrobrandy = "bottle",
        ab_misc_drinkflin = "bottle",
        ab_misc_drinkgreef = "bottle",
        ab_misc_drinkmazte = "bottle",
        ab_misc_drinkshein = "bottle",
        ab_misc_drinksujamma = "bottle",
		ab_misc_waterskin = "bottle",
		ab_misc_impcanteen = "bottle"
    }

    ashfall.registerFoods{
		AB_IngCrea_GuarMeat_01 = "meat",
		AB_IngCrea_HorseMeat01 = "meat",
		AB_IngCrea_SfMeat_01 = "meat",
		AB_IngCrea_SturgeonMeat01 = "meat",
		AB_IngCrea_SturgeonMeat02 = "meat",
		AB_IngCrea_SturgeonMeat03 = "meat",
		AB_IngFlor_BgSlime_01 = "vegetable",
		AB_IngFlor_Pomegranate01 = "food",
		AB_IngFlor_Pomegranate02 = "food",
		AB_IngFood_WickwheatDumpling = "food",
		AB_IngFood_Bread01a = "food",
		AB_IngFood_Bread01b = "food",
		AB_IngFood_Bread02 = "food",
		AB_IngFood_ComJam = "food",
		AB_IngFood_KwamaEggCentCut = "food",
		AB_IngFood_KwamaEggCentWrap = "food",
		AB_IngFood_KwamaLoaf = "food",
		AB_IngFood_KwamaLoafSlice = "food",
		AB_IngFood_SaltriceBread = "food",
		AB_IngFood_SaltricePorridge = "food",
		AB_IngFood_ScuttlePie = "food",
		AB_IngFood_Sweetroll = "food",
		AB_IngCrea_SturgeonRoe = "food",
		AB_IngFlor_Dustcap = "mushroom",
		AB_IngFlor_Fomentarius = "mushroom",
		AB_IngFlor_GlMuscaria_01 = "mushroom",
		AB_IngFlor_Urnula = "mushroom",
		AB_IngFlor_ViMuscaria_01 = "mushroom",
		AB_IngFlor_Harrada_01 = "vegetable",
		AB_IngFlor_Harrada_02 = "vegetable",
		AB_IngFlor_BlueKanet_01 = "herb",
		AB_IngFlor_Bloodgrass_01 = "herb",
		AB_IngFlor_Bloodgrass_02 = "herb",
		AB_IngFlor_CinderSparkLichen_01 = "herb"
    }
	
	ashfall.registerWoodAxes{
		"AB_w_ToolWoodAxe",
		"AB_w_FlintAxe",
		"AB_w_ImpEtool"
	
	}

    ashfall.registerHeatSources{
		AB_Fx_Lava1024 = 250,
		AB_Fx_Lava256rnd = 250,
		AB_Fx_Lava4096 = 250,
		AB_Fx_LavaBubble = 100,
		AB_Fx_LavaBubbles = 100,
		AB_Fx_LavaFall00 = 200,
		AB_Fx_LavaFall01 = 200,
		AB_Fx_LavaMagma1024 = 200,
		AB_Fx_LavaMagma4096 = 200,
		AB_Fx_LavaRipple = 250,
		AB_Fx_LavaTrans00 = 200,
		AB_Fx_SulfurMist = 80,
		AB_In_CaveLavaLavaPool = 200,
		AB_In_CavePySpoutFire = 150,
		AB_In_CavePySpoutLava00 = 250,
		AB_In_CavePyVentSteam01 = 50,
		AB_In_CavePyVentSteam02 = 50,
		AB_In_LavaPool01 = 200,
		AB_Fx_LavaFire = 50,
		AB_Fx_LavaMist = 50,
		AB_In_CavePyLavaPool = 200,
		AB_In_LavaCrust01 = 100,
		AB_In_LavaCrust02 = 100,
		AB_In_LavaCrust03 = 100
    }

	ashfall.registerTeas{
		['ab_ingflor_pomegranate01'] = {
			teaName = "Pomegranate Tea",
			teaDescription = "A tea with refreshing fruit accents brewed with pomegranate seeds. Its sweet taste has a tart bite to it that makes you forget your ills.",
			effectDescription = "Restore All Attributes 1 Point",
			spell = {
				id = "AB_sp_PomegranateTea",
				spellType = tes3.spellType.spell,
				effects = {
					{
						id = tes3.effect.restoreAttribute,
						attribute = tes3.attribute.endurance,
						amount = 1,
						duration = 1
					},
					{
						id = tes3.effect.restoreAttribute,
						attribute = tes3.attribute.strength,
						amount = 1,
						duration = 1
					},
					{
						id = tes3.effect.restoreAttribute,
						attribute = tes3.attribute.agility,
						amount = 1,
						duration = 1
					},
					{
						id = tes3.effect.restoreAttribute,
						attribute = tes3.attribute.intelligence,
						amount = 1,
						duration = 1
					},
					{
						id = tes3.effect.restoreAttribute,
						attribute = tes3.attribute.willpower,
						amount = 1,
						duration = 1
					},
					{
						id = tes3.effect.restoreAttribute,
						attribute = tes3.attribute.luck,
						amount = 1,
						duration = 1
					},
					{
						id = tes3.effect.restoreAttribute,
						attribute = tes3.attribute.speed,
						amount = 1,
						duration = 1
					},
					{
						id = tes3.effect.restoreAttribute,
						attribute = tes3.attribute.personality,
						amount = 1,
						duration = 1
					},
				}
			}
		}
	}

end