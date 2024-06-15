local animations = {
    ["ab_anim_cower"] = { groupName = "cower_01" },
}

local function onStartGlobalScript(id, target)
    local animation = animations[id:lower()]
    if animation == nil then
        return
    end

    if target == nil then
        print("[OAAB] Error: animation script '%s' called without a valid target.", id)
    else
        target:sendEvent("oaab_play_animation", animation.groupName)
    end
end

return {
    engineHandlers = {
        onGlobalMWScript = onStartGlobalScript,
    },
}
