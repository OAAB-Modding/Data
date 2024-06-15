local animation = require("openmw.animation")
local self = require("openmw.self")
local async = require("openmw.async")

return {
    eventHandlers = {
        oaab_play_animation = function(groupName)
            async:newUnsavableSimulationTimer(0.0, function()
                animation.playBlended(self, groupName, { priority = animation.PRIORITY.Scripted })
            end)
        end,
    },
}
