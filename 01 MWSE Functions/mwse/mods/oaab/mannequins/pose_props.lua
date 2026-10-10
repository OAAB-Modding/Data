-- Runtime playback of static prop wrappers embedded in a pose NIF. This module
-- intentionally has no dependency on the Pose Designer or its editor metadata.
local M={prefix="OAAB Pose Prop "}
local function wrappers(root)
    local found={}
    local function visit(node)
        if not node then return end
        if (node.name or ""):sub(1,#M.prefix)==M.prefix then found[#found+1]=node
        elseif node:isInstanceOfType(tes3.niType.NiNode) then
            for _,child in pairs(node.children) do visit(child) end
        end
    end
    visit(root)
    return found
end
function M.prepare(source,sourceRoot,targetRoot,targetBones)
    local out={}
    for _,wrapper in ipairs(wrappers(source)) do
        local sourceParent=wrapper.parent
        local name=sourceParent and sourceParent.name and sourceParent.name:lower()
        local target=sourceParent==sourceRoot.parent and targetRoot.parent or targetBones[name]
        if not target then
            target=targetRoot.parent
            mwse.log("[OAAB Mannequins Props] Missing parent %s for %s; using root",tostring(name),wrapper.name)
        end
        local clone=assert(wrapper:clone(),"Embedded prop could not be cloned")
        out[#out+1]={node=clone,parent=assert(target,"Mannequin prop root is unavailable")}
    end
    return out
end
function M.replace(scene,prepared)
    local previous={}
    for _,node in ipairs(wrappers(scene)) do previous[#previous+1]={node=node,parent=node.parent} end
    local ok,err=pcall(function()
        for _,entry in ipairs(previous) do entry.parent:detachChild(entry.node) end
        for _,entry in ipairs(prepared) do entry.parent:attachChild(entry.node) end
        scene:update()
    end)
    if not ok then
        for _,entry in ipairs(prepared) do if entry.node.parent then entry.node.parent:detachChild(entry.node) end end
        for _,entry in ipairs(previous) do if not entry.node.parent then entry.parent:attachChild(entry.node) end end
        scene:update()
        error(err)
    end
    if #prepared>0 or #previous>0 then mwse.log("[OAAB Mannequins Props] Applied %d embedded props",#prepared) end
end
return M
