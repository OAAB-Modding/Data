local onion = require("sb_onion.interop")

function startswith(string, start)
    return string.sub(string, 1, string.len(start)) == start
end

local oaabScarfIDs = {}

local oaabScarf = onion.addSlot {
    id   = "oaab_scarf",
    data = { "Scarf", tes3.activeBodyPart.head }
}

local function initializedCallback(e)
    --- @param object tes3armor
    for _, object in pairs(tes3.dataHandler.nonDynamicData.objects) do
        if (startswith(object.id, "AB_") and object.objectType == tes3.objectType.armor and object.name:find("Neck Wrap")) then
            table.insert(oaabScarfIDs, object.id)
            onion.register({
                id = object.id,
                slot = oaabScarf
            },
                onion.mode.layer
            )
        end
    end
end

event.register("initialized", initializedCallback, { priority = onion.offsetValue + 1 })
