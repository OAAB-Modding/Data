event.register("initialized", function()

    local gh_config = include("graphicHerbalism.config")
    if gh_config then
        gh_config.whitelist["ab_o_ventworm00"] = true
        gh_config.whitelist["ab_o_ventworm01"] = true
        gh_config.whitelist["ab_o_ventworm02"] = true
        gh_config.whitelist["ab_o_ventworm03"] = true
        gh_config.whitelist["ab_o_ventworm04"] = true
        gh_config.whitelist["ab_o_kwamaStorager"] = true
    end

end)