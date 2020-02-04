local LOG = require("script/lichemanager/helpers/log")

--v function(root: CA_UIC) --> CA_UIC
local function create_dummy(root)
    local name = "VandyDummy"
    local path = "ui/campaign ui/script_dummy"

    local dummy = core:get_or_create_component(name, path, root)

    return dummy
end

--v function(component: CA_UIC | vector<CA_UIC>)
local function remove_component(component)
    local dummy = create_dummy(core:get_ui_root())

    --# assume component: vector<CA_UIC>
    if type(component) == "table" then
        for i = 1, #component do
            if not is_uicomponent(component[i]) then
                LOG.error("removeComponent() called on a table but one of the indices wasn't a component, returning!")
                break
            end
            dummy:Adopt(component[i]:Address())
        end
    elseif is_uicomponent(component) then
        --# assume component: CA_UIC
        dummy:Adopt(component:Address())
    else
        LOG.error("removeComponent() called on a non-table or non-component")
    end
    
    dummy:DestroyChildren()
end

return { remove_component = remove_component }