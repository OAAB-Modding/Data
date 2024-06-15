local animations = {
    ["ab_anim_cower"] = {
        group = tes3.animationGroup.idle8,
        mesh = "oaab\\k\\cower_01.nif",
    },
}

local function onStartGlobalScript(e)
    local id = e.script.id:lower()
    local animation = animations[id]
    if animation == nil then
        return
    end

    e.block = true
    e.claim = true

    if e.reference == nil then
        mwse.log("[OAAB] Error: animation script '%s' called without a valid target.", id)
    else
        timer.delayOneFrame(function()
            tes3.playAnimation({
                reference = e.reference,
                group = animation.group,
                mesh = animation.mesh,
            })
        end)
    end
end
event.register("startGlobalScript", onStartGlobalScript)
