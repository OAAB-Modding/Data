-- Check MWSE Build --
if (mwse.buildDate == nil) or (mwse.buildDate < 20200122) then
  local function warning()
      tes3.messageBox(
          "[Dark Temptations ERROR] Your MWSE is out of date!"
          .. " You will need to update to a more recent version to use this mod."
      )
  end
  event.register("initialized", warning)
  event.register("loaded", warning)
  return
end
----------------------------

-- Check Magicka Expanded framework --
local framework = include("OperatorJack.MagickaExpanded.magickaExpanded")
if (framework == nil) then
    local function warning()
        tes3.messageBox(
            "[Dark Temptations ERROR] Magicka Expanded framework is not installed!"
            .. " You will need to install it to use this mod."
        )
    end
    event.register("initialized", warning)
    event.register("loaded", warning)
    return
end
----------------------------

-- Initial Setup --
-- Register new Light Effect --
tes3.claimSpellEffectId("summonDarkSeducer", 427)

local function getDescription(creatureName)
    return "This effect summons a ".. creatureName .." from Oblivion."..
    " It appears six feet in front of the caster and attacks any entity that attacks the caster until"..
    " the effect ends or the summoning is killed. At death, or when the effect ends, the summoning"..
    " disappears, returning to Oblivion. If summoned in town, the guards will attack you and the summoning on sight."
end

local function addEffect()
	framework.effects.conjuration.createBasicSummoningEffect({
		id = tes3.effect.summonDarkSeducer,
		name = "Summon Dark Seducer",
		description = getDescription("Dark Seducer"),
		baseCost = 30,
		creatureId = "AB_Dae_DarkSeducer",
		icon = "OAAB-DT\\RFD_dt_darksedu.dds"
	})
end

event.register("magicEffectsResolved", addEffect)
-------------------------

local spellId = "OJ_ME_SummDarkSeducerSpell"
local function registerSpells()
  framework.spells.createBasicSpell({
    id = spellId,
    name = "Summon Dark Seducer",
    effect = tes3.effect.summonDarkSeducer,
    range = tes3.effectRange.self,
    duration = 60
  })
end

event.register("MagickaExpanded:Register", registerSpells)
-------------------------


-- Register Mod Initialization Event Handler --
local function journaled(e)
  if (e.topic.id == "DA_Sheogorath" and e.index == 70) then
    mwscript.addSpell({
      reference = tes3.player,
      spell = spellId
    })

    timer.start({
      duration = 27,
      callback = function ()
        tes3.messageBox("Sheogorath: 'Oh, a parting gift for your troubles. An agent of madness to summon to your side. Go and spread Sheogorath's gift wherever you wander.'")
      end
    })
  end
end
event.register("journal", journaled)
-------------------------