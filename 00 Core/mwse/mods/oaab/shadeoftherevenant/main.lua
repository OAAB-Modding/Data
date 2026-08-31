local function necroAltarGlobalSetter(e)
	if e.caster == tes3.player then
		if e.effect.id == 58 then
			if e.target.object.name == "Strange Altar" then
				local someVar = tes3.setGlobal("AB_NecroAltarHitWithSoulTrap", 1)
				if someVar == false then
					tes3.messageBox("Something went wrong setting global")
				end
			end
		end
	end
end

-- The function to call on the initialized event.
local function initialized()
	event.register(tes3.event.spellResist, necroAltarGlobalSetter)
end

-- Register our initialized function to the initialized event.
event.register(tes3.event.initialized, initialized)
