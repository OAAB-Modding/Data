event.register("initialized", function(e)
    local root = tes3.game.worldSceneGraphRoot
	local proj = root:getObjectByName("WorldProjectileRoot")
	local land = root:getObjectByName("WorldLandscapeRoot")
	
	root:detachChild(proj)
	root:detachChild(land)
	root:attachChild(land, true)
    root:attachChild(proj, true)	
	
	--root:detachChild(tes3.game.worldObjectRoot)
	--root:detachChild(tes3.game.worldPickRoot)
	--root:detachChild(tes3.game.worldLandscapeRoot)
	--root:attachChild(tes3.game.worldLandscapeRoot, true)
	--root:attachChild(tes3.game.worldObjectRoot, true)
	--root:attachChild(tes3.game.worldPickRoot, true)	
	
    --root:detachChild(tes3.game.worldObjectRoot)
    --root:detachChild(tes3.game.worldLandscapeRoot)
    --root:attachChild(tes3.game.worldLandscapeRoot, true)
    --root:attachChild(tes3.game.worldObjectRoot, true)
	
	
end)