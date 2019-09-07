local function hide_kemmler_hunter_panel()
    core:add_listener(
        "KillKemmlersHunters",
        "PanelOpenedCampaign",
        function(context)
            return context.string == "hunters_panel"
        end,
        function(context)
            local panel = find_uicomponent(core:get_ui_root(), "hunters_panel")
            local char_list = find_uicomponent(panel, "main", "characters_holder", "character_tab_parent_list")

            find_uicomponent(char_list, "AK_hobo_nameless"):SetVisible(false)
            find_uicomponent(char_list, "AK_hobo_draesca"):SetVisible(false)
            find_uicomponent(char_list, "AK_hobo_priestess"):SetVisible(false)
        end,
        true
    )
end

cm:add_first_tick_callback(function()
    hide_kemmler_hunter_panel()
end)