------------------------------------------
-- Initialization script, anything that --
-- doesn't belong in the faction script --
-- or the manager will go here, such as --
-- listeners and what not               --
------------------------------------------

-- refernces some stuff that will be used ALL over

local lm = _G._LICHEMANAGER
local legion = lm:get_faction_key()
local UTILITY = lm._UTILITY

local LicheLog = require("script/lichemaster/log") --# assume LicheLog: LICHE_LOG


----------------------
-- Helper Functions --
----------------------

-- triggered on campaign load and on per turn
-- disables unnecessary UIC's
local function kill_blood_kisses_and_tech()
    -- find and kill all the UI components that are unnecessary.
    local bloodKiss = find_uicomponent(core:get_ui_root(), "layout", "resources_bar", "topbar_list_parent", "canopic_jars_holder")
    bloodKiss:SetVisible(false)

    local bloodlines = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_group_management", "button_bloodlines")
    bloodlines:SetVisible(false)

    local tech = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_group_management", "button_technology")
    tech:SetVisible(false)

    local cuim = cm:get_campaign_ui_manager()
    --cuim:stop_end_of_turn_warning_suppression_system() -- is this needed?
    cuim:suppress_end_of_turn_warning("tech", true)

    -- effect bundle that sets blood kisses to -999
    cm:apply_effect_bundle("kill_blood_kisses", legion, 1)
end

-- prevents recruitment of specific VCount units that Kemmler shouldn't have. Prevents regular recruitment and Raise Dead recruitment
local function kill_extra_recruitment()
    local kill_units = {
        ["wh_dlc02_vmp_cav_blood_knights_0"] = true,
        ["wh_dlc04_vmp_veh_corpse_cart_0"] = true,
        ["wh_dlc04_vmp_veh_corpse_cart_1"] = true,
        ["wh_dlc04_vmp_veh_corpse_cart_2"] = true,
        ["wh_main_vmp_inf_crypt_ghouls"] = true,
        ["wh_main_vmp_mon_crypt_horrors"] = true,
        ["wh_main_vmp_mon_vargheists"] = true,
        ["wh_main_vmp_mon_varghulf"] = true,
        ["wh_main_vmp_veh_black_coach"] = true
    }--:map<string, boolean>
    for unit, _ in pairs(kill_units) do
        cm:add_event_restricted_unit_record_for_faction(unit, legion)
    end
end

-- prevents research of the base 4 technologies, preventing the use of any tech for Kemmler
local function kill_technologies()
    local technologies = {
        "tech_vmp_beasts_01",
        "tech_vmp_binding_01",
        "tech_vmp_blood_01",
        "tech_vmp_bones_01"
    }--: vector<string>

    cm:restrict_technologies_for_faction(legion, technologies, true)
end

-- enables the three missions to unlock the three unique lords
local function add_missions_and_unlock_requirements()

    local nameless_mission = mission_manager:new(legion, "lichemaster_lord_nameless")
    nameless_mission:set_mission_issuer("clicky_clack")
    nameless_mission:add_new_objective("SCRIPTED")
    nameless_mission:add_condition("script_key lichemaster_lord_nameless")
    nameless_mission:add_condition("override_text mission_text_text_lichemaster_lord_nameless")
    --nameless_mission:add_payload("money 1000")
    nameless_mission:add_payload("effect_bundle{bundle_key lichemaster_lord_nameless;turns 0;}")
    nameless_mission:set_should_whitelist(false)
    nameless_mission:trigger()

    local draesca_mission = mission_manager:new(legion, "lichemaster_lord_draesca")
    draesca_mission:set_mission_issuer("clicky_clack")
    draesca_mission:add_new_objective("SCRIPTED")
    draesca_mission:add_condition("script_key lichemaster_lord_draesca")
    draesca_mission:add_condition("override_text mission_text_text_lichemaster_lord_draesca")
    --draesca_mission:add_payload("money 1000")
    draesca_mission:add_payload("effect_bundle{bundle_key lichemaster_lord_draesca;turns 0;}")
    draesca_mission:set_should_whitelist(false)
    draesca_mission:trigger()

    local priestess_mission = mission_manager:new(legion, "lichemaster_lord_priestess")
    priestess_mission:set_mission_issuer("clicky_clack")
    priestess_mission:add_new_objective("SCRIPTED")
    priestess_mission:add_condition("script_key lichemaster_lord_priestess")
    priestess_mission:add_condition("override_text mission_text_text_lichemaster_lord_priestess")
    --priestess_mission:add_payload("money 1000")
    priestess_mission:add_payload("effect_bundle{bundle_key lichemaster_lord_priestess;turns 0;}")
    priestess_mission:set_should_whitelist(false)
    priestess_mission:trigger()
end

-- during VC turn, make blood kisses/lines visible.
local function return_blood_kisses()
    local bloodKiss = find_uicomponent(core:get_ui_root(), "layout", "resources_bar", "topbar_list_parent", "canopic_jars_holder")
    bloodKiss:SetVisible(true)

    local bloodlines = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_group_management", "button_bloodlines")
    bloodlines:SetVisible(true)
end

-- after Kemmler's turn, make these other technologies visible. Necessary for other players
local function return_tech()
    local tech = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_group_management", "button_technology")
    tech:SetVisible(true)
end

-- functionality for the NP icon on the topbar
local function add_pr_uic()
    local parent = find_uicomponent(core:get_ui_root(), "layout", "resources_bar", "topbar_list_parent")

    local uic --: CA_UIC
    local pooled_resource_key = "necropower"

    local function create_uic()
        uic = core:get_or_create_component(pooled_resource_key.."_"..legion, "ui/vandy_lib/pooled_resources/dy_canopic_jars", parent)
        local dummy = core:get_or_create_component("script_dummy", "ui/campaign ui/script_dummy")

        dummy:Adopt(uic:Address())

        -- remove all other children of the parent bar, except for the treasury, so the new PR will be to the right of the treasury holder
        for i = 0, parent:ChildCount() - 1 do
            local child = UIComponent(parent:Find(i))
            if child:Id() ~= "treasury_holder" then
                dummy:Adopt(child:Address())
            end
        end
        
        -- add the PR component!
        parent:Adopt(uic:Address())
    
        -- give the topbar the babies back
        for i = 0, dummy:ChildCount() - 1 do
            local child = UIComponent(dummy:Find(i))
            parent:Adopt(child:Address())
        end
    
        uic:SetInteractive(true)
        uic:SetVisible(true)
    
        local uic_icon = find_uicomponent(uic, "icon")
        uic_icon:SetImagePath("ui/kemmler/AK_hobo_necropowa_summarybutt.png")
        
        uic:SetTooltipText('{{tt:ui/campaign ui/tooltip_pooled_resource_breakdown}}', true)
    end

    local function check_value()
        if uic then
            local pr_obj = cm:get_faction(legion):pooled_resource(pooled_resource_key)
            local val = pr_obj:value()
            uic:SetStateText(tostring(val))
        end
    end

    if cm:whose_turn_is_it() == legion then
        create_uic()
        check_value()
    end

    local function adjust_tooltip()
        local tooltip = find_uicomponent(core:get_ui_root(), "tooltip_pooled_resource_breakdown")
        tooltip:SetVisible(true)

        print_all_uicomponent_children(tooltip)
    
        local list_parent = find_uicomponent(tooltip, "list_parent")
    
        local title_uic = find_uicomponent(list_parent, "dy_heading_textbox")
        local desc_uic = find_uicomponent(list_parent, "instructions")
    
        local loc_header = "pooled_resources"
        title_uic:SetStateText(effect.get_localised_string(loc_header.."_display_name_"..pooled_resource_key))
        desc_uic:SetStateText(effect.get_localised_string(loc_header.."_description_"..pooled_resource_key))
    
        local positive_list = find_uicomponent(list_parent, "positive_list")
        positive_list:SetVisible(true)
        local positive_list_header = find_uicomponent(positive_list, "list_header")
        positive_list_header:SetStateText(effect.get_localised_string(loc_header.."_positive_factors_display_name_"..pooled_resource_key))
    
        local negative_list = find_uicomponent(list_parent, "negative_list")
        negative_list:SetVisible(true)
        local negative_list_header = find_uicomponent(negative_list, "list_header")
        negative_list_header:SetStateText(effect.get_localised_string(loc_header.."_negative_factors_display_name_"..pooled_resource_key))

        local factors_list = {
            [100] = "necropower_buildings", 
            [101] = "necropower_chars",
            [102] = "necropower_battles",
            [103] = "necropower_units",
            [104] = "necropower_ror"
        } --: map<number, string>

        local faction_obj = cm:get_faction(legion)
        local pr_obj = faction_obj:pooled_resource(pooled_resource_key)
        local factors_list_obj = pr_obj:factors()
    
        local factors = {} --: map<string, number>
        local diff = 0 --: number
    
        for i = 0, factors_list_obj:num_items() - 1 do
            local factor = factors_list_obj:item_at(i)
            for num, key in pairs(factors_list) do
                if factor:maximum_value() == num then
                    factors[key] = factor:value()
                    break
                end
            end
            diff = diff + factor:value() -- adds/subtracts to set the "Change This turn" number
        end

        local total = find_child_uicomponent(list_parent, "change_this_turn")
        local total_val = find_child_uicomponent(total, "dy_value")
        if diff < 0 then
            total_val:SetState('0')
        elseif diff == 0 then
            total_val:SetState('1')
        elseif diff > 0 then
            total_val:SetState('2')
        end

        total_val:SetStateText(tostring(diff))

        --v function(key: string, parent: CA_UIC)
        local function new_factor(key, parent)
            local uic_path = "ui/vandy_lib/pooled_resources/"
            local state = ""

            if parent:Id() == "positive_list" then
                uic_path = uic_path .. "positive_list_entry"
                state = "positive"
            elseif parent:Id() == "negative_list" then
                uic_path = uic_path .. "negative_list_entry"
                state = "negative"
            end

            local factor_list = find_uicomponent(parent, "factor_list")

            local factor_entry = core:get_or_create_component(pooled_resource_key..key, uic_path, factor_list)
            factor_list:Adopt(factor_entry:Address())

            -- factor_entry = title text
            factor_entry:SetStateText(effect.get_localised_string("pooled_resource_factors_display_name_"..state.."_"..key))

            local value = factors[key]
            local value_uic = find_uicomponent(factor_entry, "dy_value")

            if state == "positive" then
                -- defaults to grey
                value_uic:SetState('0')
                if value > 0 then
                    value_uic:SetState('1') -- make green
                elseif value < 0 then
                    value_uic:SetState('2') -- make red
                end
            elseif state == "negative" then
                value_uic:SetState('0')
            end

            value_uic:SetStateText(tostring(value))
        end

        for key, value in pairs(factors) do
            if value >= 0 then
                -- positive path
                new_factor(key, positive_list)
            elseif value < 0 then
                -- negative path
                new_factor(key, negative_list)
            end
        end
    end

    core:add_listener(
        "example_pr_hovered_on",
        "ComponentMouseOn",
        function(context)
            return uic == UIComponent(context.component)
        end,
        function(context)
            cm:callback(function()
                adjust_tooltip()
            end, 0.1)
        end,
        true
    )

    core:add_listener(
        pooled_resource_key.."_value_changed",
        "PooledResourceEffectChangedEvent",
        function(context)
            return context:faction():name() == legion and context:resource():key() == pooled_resource_key and context:faction():is_human() and cm:whose_turn_is_it() == legion
        end,
        function(context)
            check_value()
        end,
        true
    )

    core:add_listener(
        pooled_resource_key.."_turn_start",
        "FactionTurnStart",
        function(context)
            return context:faction():name() == legion and context:faction():is_human()
        end,
        function(context)
            create_uic()
            check_value()
        end,
        true
    )

    core:add_listener(
        pooled_resource_key.."_faction_turn_end",
        "FactionTurnStart",
        function(context)
            return context:faction():name() ~= legion and cm:get_faction(legion):is_human()
        end,
        function(context)
            uic:SetVisible(false)
        end,
        true
    )
end

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

local function set_hunters_panel()
    local hunter_button = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_group_management", "button_hunters")
    if hunter_button then
        hunter_button:SetVisible(true)
        hunter_button:SetImagePath("ui/kemmler/hunter_button.png")
        hunter_button:SetTooltipText("{{tr:kemmler_hunter_button}}", true)
    end

    local function hide_vanilla_bois()
        local panel = find_uicomponent(core:get_ui_root(), "hunters_panel")
        local char_list = find_uicomponent(panel, "main", "characters_holder", "character_tab_parent_list")
        
        find_uicomponent(char_list, "wh2_dlc13_emp_hunter_doctor_hertwig_van_hal"):SetVisible(false)
        find_uicomponent(char_list, "wh2_dlc13_emp_hunter_jorek_grimm"):SetVisible(false)
        find_uicomponent(char_list, "wh2_dlc13_emp_hunter_kalara_of_wydrioth"):SetVisible(false)
        find_uicomponent(char_list, "wh2_dlc13_emp_hunter_rodrik_l_anguille"):SetVisible(false)
    end

    -- check states and shit?
    --v function(subtype: string)
    local function panel_check(subtype)
        local panel = find_uicomponent(core:get_ui_root(), "hunters_panel")
        local character_holder = find_uicomponent(panel, "main", "characters_holder", "character_template", "character_holder")
        local movie = find_uicomponent(character_holder, "movie")
        local locked_character = find_uicomponent(character_holder, "locked_character")

        local effects_holder = find_uicomponent(panel, "main", "characters_holder", "character_template", "effects_holder")
        local attributes_text = find_uicomponent(effects_holder, "attributes_holder", "attributes_text")
        attributes_text:SetStateText("{{tr:kemmler_evil_specialities}}")

        --local battle_effect_holder = find_uicomponent(effects_holder, "battle_effect_holder")
        --battle_effect_holder:SetVisible(true)

        -- read if the character is un/locked

        --movie:Resize(1, 1) movie:MoveTo(0,0)
        --movie:SetVisible(false)
        movie:SetImagePath("ui/kemmler/"..subtype.."_bg.png")
        local w, h = locked_character:Dimensions() movie:Resize(w, h)
        locked_character:SetImagePath("ui/kemmler/"..subtype.."_bg.png")
        locked_character:SetVisible(true)

        local new_uic = find_uicomponent(panel, "main", "characters_holder", "dy_character_name_copy")
        new_uic:SetStateText("{{tr:"..subtype.."_name}}")
    end

    core:add_listener(
        "KemmlersHunters",
        "PanelOpenedCampaign",
        function(context)
            return context.string == "hunters_panel"
        end,
        function(context)
            local panel = find_uicomponent(core:get_ui_root(), "hunters_panel")
            local char_list = find_uicomponent(panel, "main", "characters_holder", "character_tab_parent_list")

            -- rename the component
            local title = find_uicomponent(panel, "header_frame", "dy_faction") 
            title:SetStateText("{{tr:kemmler_hunter_panel_title}}")

            -- set up the scene to be on Nameless, instead of on Van Hel
            local click = find_uicomponent(char_list, "AK_hobo_nameless") 
            if click then 
                click:SimulateLClick() 
            end

            local nameless = find_uicomponent(char_list, "AK_hobo_nameless")
            local draesca = find_uicomponent(char_list, "AK_hobo_draesca")
            local priestess = find_uicomponent(char_list, "AK_hobo_priestess")

            nameless:SetImagePath("ui/kemmler/AK_hobo_nameless_mini.png")
            nameless:SetTooltipText("{{tr:AK_hobo_nameless_mini}}", true)

            draesca:SetImagePath("ui/kemmler/AK_hobo_draesca_mini.png")
            draesca:SetTooltipText("{{tr:AK_hobo_draesca_mini}}", true)

            priestess:SetImagePath("ui/kemmler/AK_hobo_priestess_mini.png")
            priestess:SetTooltipText("{{tr:AK_hobo_priestess_mini}}", true)

            -- hide the character name component and replace it, hopefully?
            local dy_character_name = find_uicomponent(panel, "main", "characters_holder", "dy_character_name")
            dy_character_name:CopyComponent("dy_character_name_copy")
            dy_character_name:PropagatePriority(1)
            --dy_character_name:SetVisible(false)

            -- hide the vanilla Hunters
            hide_vanilla_bois()

            -- set text and backgrounds and what not
            panel_check("AK_hobo_nameless")
        end,
        true
    )

    core:add_listener(
        "KemmlersHuntersButtons",
        "ComponentLClickUp",
        function(context)
            local t = context.string
            local uic = UIComponent(context.component)
            return (t == "AK_hobo_nameless" or t == "AK_hobo_priestess" or t == "AK_hobo_draesca") and UIComponent(uic:Parent()):Id() == "character_tab_parent_list"
        end,
        function(context)
            panel_check(context.string)
            cm:callback(function()
                --panel_check(context.string)
            end, 0.1)
        end,
        true
    )
end

----------------
-- Listeners! --
----------------

-- this is triggered ONCE, after the faction start script (wh2_dlc11_vmp_the_barrow_legion_start.lua) is over and the intro battle is completed
function lichemaster_postbattle_setup()

    add_missions_and_unlock_requirements()
    kill_extra_recruitment()

end

-- run every game creation or game load
function liche_init_listeners()
    local ok, err = pcall(function()
        -- read through the entirety of the current region list on script load
        -- needed for every script load, as the ruins list isn't saved
        do
            local region_list = cm:model():world():region_manager():region_list()
            for i = 0, region_list:num_items() - 1 do
                local current_region = region_list:item_at(i)
                if current_region:is_abandoned() then
                    lm:set_ruin(current_region:name())
                end
            end
        end

        -- TODO this can be done better and somewhere else, but this will do for now
        -- set up the regiments!
        lm:setup_regiments()
        
        -- disable confederation betwixt Kemmy and Vampies
        cm:force_diplomacy(legion, "culture:wh_main_vmp_vampire_counts", "form confederation", false, false, true)

        -- remove units from the Raise Dead pool
        kill_extra_recruitment()

        -- remove unwanted tech
        kill_technologies()

        -- every Kemmler turn, hide the blood kisses and tech UI, and create the necropower button.
        core:add_listener(
            "LicheNPUI",
            "FactionTurnStart",
            function(context)
                return context:faction():name() == legion and cm:get_local_faction() == legion
            end,
            function(context)
                CampaignUI.ClearSelection()
                kill_blood_kisses_and_tech()
                set_hunters_panel()
            end,
            true
        )

        -- every Kemmler turn, check NP. 
        -- If it's over 80, and lives hasn't been increased for 20 turns, then +1 lives
        -- If under 20, add attrition throughout the character list to any character not in Kemmler's region
        core:add_listener(
            "LicheKemmlerLives",
            "FactionTurnStart",
            function(context)
                return context:faction():name() == legion and context:faction():is_human()
            end,
            function(context)
                local turn = cm:model():turn_number()
                local npvalue = context:faction():pooled_resource("necropower"):value()

                if npvalue >= 80 then
                    -- checks the last turn lives changed within this method
                    lm:add_life()
                end

                if npvalue <= 20 then
                    lm:apply_attrition()
                end
            end,
            true
        )

        -- set ruins whenever a settlement is razed
        core:add_listener(
            "LicheAddRuins",
            "CharacterRazedSettlement",
            true,
            function(context)
                lm:set_ruin(context:garrison_residence():region():name())
            end,
            true
        )

        -- remove ruin whenever a settlement is occupied (does nothing for non-ruins)
        core:add_listener(
            "LicheRemoveRuins",
            "GarrisonOccupiedEvent",
            true,
            function(context)
                lm:remove_ruin(context:garrison_residence():region():name())
            end,
            true
        )

        -- set the rank increase to 5 whenever the Priestess building is built. Levels up all custom spawned agents by 5 when they're created
        core:add_listener(
            "LichePriestessBuilding",
            "MilitaryForceBuildingCompleteEvent",
            function(context)
                return context:building() == "AK_hobo_priestesses"
            end,
            function(context)
                lm:increase_hero_spawn_rank(5)
            end,
            false
        )

        -- adds the ancillaries and experience to the LL's when they're spawned. 
        core:add_listener(
            "LicheNewLLSpawned",
            "CharacterCreated",
            function(context)
                local subtype = context:character():character_subtype_key()
                return lm:is_subtype_key_legendary(subtype)
            end,
            function(context)
                local char = context:character()
                local char_cqi = char:command_queue_index()
                local char_str = cm:char_lookup_str(char_cqi)

                local subtype = context:character():character_subtype_key()

                --local num_existing = lm:get_num_legendary_lords()
                local xp_to_apply = 0

                local turn = cm:model():turn_number()

                if turn >= 150 then
                    xp_to_apply = 15
                elseif turn >= 100 then
                    xp_to_apply = 10
                elseif turn >= 50 then
                    xp_to_apply = 5
                end

                if xp_to_apply > 0 then
                    cm:add_agent_experience(char_str, xp_to_apply, true)
                end
                lm:add_ancillaries_to_lord(subtype, char_str)
            end,
            true
        )

        -- adds XP to newly created agents, if the Priestess building is built
        core:add_listener(
            "LicheNewCharacterSpawned",
            "CharacterCreated",
            function(context)
                local subtype = context:character():character_subtype_key()
                return lm:is_subtype_key_agent(subtype)
            end,
            function(context)
                local char = context:character()
                local char_cqi = char:command_queue_index()
                local char_str = cm:char_lookup_str(char_cqi)

                local type = context:character_type_key()
                local subtype = context:character_subtype_key()

                if lm:get_hero_spawn_rank_increase() == 5 then
                    cm:add_agent_experience(char_str, 5, true)
                end
            end,
            true
        )

        -- add a huge replen boost to Lichemaster after occupying
        core:add_listener(
            "LicheColonizeBundle",
            "GarrisonOccupiedEvent",
            function(context)
                return context:character():faction():name() == legion
            end,
            function(context)
                local char = context:character()
                cm:apply_effect_bundle_to_characters_force("lichemaster_colonize_replenishment", char:command_queue_index(), 2, true)
            end,
            true
        )

        -- gets rid of that annoying yellow movement path from having the character selected
        core:add_listener(
            "LicheRorButtonPressed2",
            "ComponentLClickUp",
            function(context)
                return context.string == "LicheRorButton"
            end,
            function(context)
                CampaignUI.ClearSelection()
            end,
            true
        )

        -- following three are the unlock conditions to complete the unlock missions as well as actually spawn the lord
        if not lm:is_lord_unlocked("AK_hobo_nameless") then
            core:add_listener(
                "LicheNamelessUnlock",
                "BuildingCompleted",
                function(context)
                    return context:garrison_residence():region():owning_faction():name() == legion and context:building():name() == "wh_main_vmp_settlement_major_2" and context:garrison_residence():region():name() == "wh_main_northern_grey_mountains_blackstone_post"
                end,
                function(context)
                    if not lm:is_lord_unlocked("AK_hobo_nameless") then
                        cm:complete_scripted_mission_objective("lichemaster_lord_nameless", "lichemaster_lord_nameless", true)
                        lm:unlock_lord("AK_hobo_nameless")
                    end
                    core:remove_listener("LicheNamelessUnlock2")
                end,
                false
            )
            core:add_listener(
                "LicheNamelessUnlock2",
                "GarrisonOccupiedEvent",
                function(context)
                    local region = context:garrison_residence():region()
                    return region:name() == "wh_main_northern_grey_mountains_blackstone_post" and context:character():faction():name() == legion and 
                    (region:building_exists("wh_main_vmp_settlement_major_2") or region:building_exists("wh_main_vmp_settlement_major_3") or region:building_exists("wh_main_vmp_settlement_major_4") or region:building_exists("wh_main_vmp_settlement_major_5"))
                end,
                function(context)
                    if not lm:is_lord_unlocked("AK_hobo_nameless") then
                        cm:complete_scripted_mission_objective("lichemaster_lord_nameless", "lichemaster_lord_nameless", true)
                        lm:unlock_lord("AK_hobo_nameless")
                    end
                    core:remove_listener("LicheNamelessUnlock")
                end,
                false
            )
        end
    
        if not lm:is_lord_unlocked("AK_hobo_priestess") then
            core:add_listener(
                "LichePriestessUnlock",
                "LichemasterEventRuinDefiled",
                function(context)
                    return context.string == "6"
                end,
                function(context)
                    if not lm:is_lord_unlocked("AK_hobo_priestess") then
                        cm:complete_scripted_mission_objective("lichemaster_lord_priestess", "lichemaster_lord_priestess", true)
                        lm:unlock_lord("AK_hobo_priestess")
                    end
                end,
                false
            )
        end

        if not lm:is_lord_unlocked("AK_hobo_draesca") then
            core:add_listener(
                "LicheDraescaUnlock",
                "CharacterRazedSettlement",
                function(context)
                    return context:character():faction():name() == legion
                end,
                function(context)
                    lm:increment_num_razed_settlements()
                    if lm:get_num_razed_settlements() >= 3 and not lm:is_lord_unlocked("AK_hobo_draesca") then
                        cm:complete_scripted_mission_objective("lichemaster_lord_draesca", "lichemaster_lord_draesca", true)
                        lm:unlock_lord("AK_hobo_draesca")
                    end
                    core:remove_listener("LicheDraescaUnlock")
                end,
                true
            )
        end
        
        -- complicated lil' bugger
        -- sets up the Ruins UI, the new button and the turn tracker, on the Settlement Captured screen, if it's a ruin
        -- disables unwanted Occupation Options
        core:add_listener(
            "LicheSettlementCapturedPanel",
            "PanelOpenedCampaign",
            function(context)
                return context.string == "settlement_captured" and cm:whose_turn_is_it() == legion and cm:get_local_faction() == legion
            end,
            function(context)
                local root = core:get_ui_root()
                -- this is a very unfortunate work around I had to do in order to read the "Settlement Captured" UI panel for the region's name.
                -- currently potentially buggy if more than one of Vaul's Anvils are ruins

                local panel = find_uicomponent(core:get_ui_root(), "settlement_captured")
                local name = find_uicomponent(panel, "header_docker", "panel_subtitle", "settlement_name"):GetStateText()
                local region

                for k, v in pairs(lm:get_region_names()) do
                    if k == name then
                        region = cm:get_region(v)
                    end
                end

                if not region then 
                    lm:error("LicheRuinsUI listener triggered, but region with key ["..name.."] not found in the regionNames table! Aborting")
                    return
                end
                
                if region:is_abandoned() then
                    local search_ruins_button = find_uicomponent(panel, "1240")
                    local resettle_button = find_uicomponent(panel, "948")
                    local colonise_button = find_uicomponent(panel, "906")
                    if not not search_ruins_button then 
                        UTILITY.remove_component(search_ruins_button) 
                    end
                    if not lm:can_occupy_region(region:name()) then
                        -- remove occupation options
                        if not not colonise_button then
                            UTILITY.remove_component(colonise_button)
                        end
                        if not not resettle_button then
                            UTILITY.remove_component(resettle_button)
                        end

                        lm:ruinsUI(region:name())
                    else
                        -- keep occupation options, passing the number in order to move the UIC over
                        if not not colonise_button then
                            lm:ruinsUI(region:name(), "906")
                        elseif not not resettle_button then
                            lm:ruinsUI(region:name(), "948")
                        else
                            lm:error("How did this happen?")
                        end
                    end
                else
                    -- get rid of occupation options 
                    if not lm:can_occupy_region(region:name()) then
                        local loot_and_occupy_button = find_uicomponent(panel, "924")
                        local occupy_button = find_uicomponent(panel, "930")
                        local option_width, option_height = occupy_button:Width(), occupy_button:Height()
                        if not not loot_and_occupy_button then
                            UTILITY.remove_component(loot_and_occupy_button)
                        end
                        if not not occupy_button then
                            UTILITY.remove_component(occupy_button)
                        end
                        -- fix the ugly stretch!
                        panel:Resize(option_width * 2 + option_width / 3, panel:Height())
                    end
                end                
            end,
            true
        )

        -- set up the RoR UI button and stuff.
        -- char selected is needed for spawning the unit onto an army
        core:add_listener(
            "LicheRorUI",
            "PanelOpenedCampaign",
            function(context)
                local cuim = cm:get_campaign_ui_manager()
                return context.string == "units_panel" and cuim:is_char_selected_from_faction(legion) and cm:whose_turn_is_it() == legion and cm:get_local_faction() == legion
            end,
            function(context)
                local cuim = cm:get_campaign_ui_manager()
                local selected = cuim:get_char_selected_cqi()
                lm:ror_UI(selected)

                -- repeat callback to make sure the ror button stays invisible
                cm:repeat_callback(function()
                    local ror_button = find_uicomponent(core:get_ui_root(), "layout", "hud_center_docker", "hud_center", "small_bar", "button_group_army", "button_renown")
                    if is_uicomponent(ror_button) then
                        ror_button:SetVisible(false)
                    end
                end, 0.1, "kill_that_ror_button")

                -- once the panel is closed, stop forcing the ror button invisible every 0.1s
                core:add_listener(
                    "LicheRorUIKiller",
                    "PanelClosedCampaign",
                    function(context)
                        return context.string == "units_panel"
                    end,
                    function(context)
                        cm:remove_callback("kill_that_ror_button")
                    end,
                    false
                )
            end,
            true
        )
    

        -- char selected needed for a lot of mechanics, just tracks the last selected Legion character by the Legion
        core:add_listener(
            "LicheCharacterTracker",
            "CharacterSelected",
            function(context)
                return context:character():faction():name() == legion and cm:whose_turn_is_it() == legion and cm:get_local_faction() == legion
            end,
            function(context)
                lm:set_character_selected_cqi(context:character():cqi())
            end,
            true
        )

        --[[
        core:add_listener(
            "LicheNecroButtonPressed",
            "ComponentLClickUp",
            function(context)
                return context.string == "button_necropower"
            end,
            function(context)
                CampaignUI.ClearSelection()
                lm:set_necropower_panel()
            end,
            true
        )]]
            
        -- idk
        core:add_listener(
            "LicheHordePanel",
            "ComponentLClickUp",
            function(context)
                return context.string == "tab_horde_buildings" and cm:whose_turn_is_it() == legion and cm:get_local_faction() == legion
            end,
            function(context)
                lm:lord_lock_UI()
            end,
            true
        )

        -- idk
        --[[core:add_listener(
            "LicheGeneralUI",
            "PanelOpenedCampaign",
            function(context)
                return context.string == "character_panel" and cm:whose_turn_is_it() == legion
            end,
            function(context)
                lm:lord_pool_UI()
            end,
            true
        )]]

        core:add_listener(
            "LicheGeneralUI2",
            "ComponentLClickUp",
            function(context)
                return context.string == "button_create_army" and cm:whose_turn_is_it() == legion
            end,
            function(context)
                cm:callback(function()
                    lm:lord_pool_UI()
                end, 0.1)
            end,
            true
        )
            
        -- why don't you work?
        -- TODO make this work
        --[[core:add_listener(
            "RemoveNotificationForTech",
            "ScriptEventPlayerFactionTurnStart",
            function(context)
                return context:faction():name() == legion
            end,
            function(context)

            end,
            true
        )]]

        -- listens for the custom occupy option being pressed
        core:add_listener(
            "LicheOccupyButtonPressed",
            "ComponentLClickUp",
            function(context)
                local component = find_uicomponent(core:get_ui_root(), "settlement_captured", "button_parent", "template_button_occupy", "option_button")
                return UIComponent(context.component) == component
            end,
            function(context)
                -- no direct way to access the region, so we're reading UI, ugh. MUST BE DONE BEFORE THE SIMCLICK! DUH!
                local panel = find_uicomponent(core:get_ui_root(), "settlement_captured")
                local name = find_uicomponent(panel, "header_docker", "panel_subtitle", "settlement_name"):GetStateText()

                local region
                for k, v in pairs(lm:get_region_names()) do
                    if k == name then
                        region = cm:get_region(v)
                    end
                end

                if not region then 
                    lm:error("LicheOccupyButtonPressed listener triggered, but region with key ["..name.."] not found in the regionNames table! Aborting")
                    return
                end

                local button = find_uicomponent(panel, "button_parent", "915", "option_button")
                button:SimulateLClick() -- click the "Do Nothing" button

                lm:defile_ruin(region:name()) -- set the ruin as defiled

            end,
            true
        )

        -- run once a turn, see if turnToSpawn is this turn. 
        core:add_listener(
            "RespawnKemmy",
            "FactionTurnStart",
            function(context)
                local turn_to_spawn = lm:get_turn_to_spawn()
                return 
                    context:faction():name() == legion and 
                    cm:model():turn_number() >= turn_to_spawn and 
                    turn_to_spawn ~= 0
            end,
            function(context)
                -- time to spawn Real Kemmy!

                -- grab the CQI and objects needed to go on
                local wounded_kemmy_cqi = lm:get_wounded_cqi()
                local kemmy_cqi = lm:get_real_cqi()
                local woundedKemmy = cm:get_character_by_cqi(wounded_kemmy_cqi)
    
                local spawnX, spawnY, spawnRegion = lm:wounded_kemmy_coords()
                if spawnRegion == "" then
                    lm:error("Spawn Wounded Kemmy but the coordinates returned were -1, -1 - investigate.")
                end

                local unit_list = lm:get_unit_list()
    
                -- respawns original Kemmy, with the saved unit list from when he died
                cm:create_force_with_existing_general(
                    cm:char_lookup_str(kemmy_cqi),
                    legion, 
                    unit_list,
                    spawnRegion,
                    spawnX,
                    spawnY,
                    function(cqi)
                        -- blah
                    end
                )
                lm:log("WOUNDED KEMMY: Kemmler respawned in region ["..spawnRegion.."] at location ("..spawnX..", "..spawnY.."). Enjoy.")
                
                -- axe the wounded version
                lm:kill_wounded_kemmy()
    
                lm:set_turn_to_spawn(0)
    
            end,
            true
        )

        -- spawn Wounded Kemmy off-screen when Kemmler is in a pending battle and has at least one life.
        -- PendingBattle happens BEFORE the battle begins, around the time the "attack" and "retreat" options are available
        core:add_listener(
            "LicheKemmyWoundedOffscreen",
            "PendingBattle",
            function(context)
                if context:pending_battle():has_attacker() and context:pending_battle():has_defender() then
                    local attacker_faction = context:pending_battle():attacker():faction():name()
                    local defender_faction = context:pending_battle():defender():faction():name()
                    return (attacker_faction == legion or defender_faction == legion) and lm:can_revive()
                end
                return false
            end,
            function(context)
                lm:log("WOUNDED KEMMY: Kemmler is in a battle and has enough stuff to revive. Spawning Wounded Kemmy off-screen.")


                local kemmy --: CA_CHAR
                local pb = context:pending_battle()

                local attacker = pb:attacker()
                local secondary_attackers = pb:secondary_attackers()
                local defender = pb:defender()
                local secondary_defenders = pb:secondary_defenders()
                local position = ""

                -- try to find if Kemmler is in the battle
                if attacker:character_subtype("vmp_heinrich_kemmler") then
                    kemmy = attacker
                    position = "attacker"
                elseif defender:character_subtype("vmp_heinrich_kemmler") then
                    kemmy = defender
                    position = "defender"
                else
                    for i = 0, secondary_attackers:num_items() - 1 do
                        local secondary_attacker = secondary_attackers:item_at(i)
                        if secondary_attacker:character_subtype("vmp_heinrich_kemmler") then
                            kemmy = secondary_attacker
                            position = "secondary_attacker_"..i
                            break
                        end
                    end
                    for i = 0, secondary_defenders:num_items() - 1 do
                        local secondary_defender = secondary_defenders:item_at(i)
                        if secondary_defender:character_subtype("vmp_heinrich_kemmler") then
                            kemmy = secondary_defender
                            position = "secondary_defender_"..i
                            break
                        end
                    end
                end

                -- don't go any further if Kemmler isn't actually in this battle
                if not kemmy then
                    return
                end

                local x, y = kemmy:logical_position_x(), kemmy:logical_position_y()

                local kem_unit_list --: string
                local unit_list = kemmy:military_force():unit_list()
                for i = 0, unit_list:num_items() -1 do
                    local unit = unit_list:item_at(i)
                    local unit_key = unit:unit_key()
                    if unit_key:find("_cha_") then
                        -- ignore characters
                    elseif i == 0 then
                        -- create the beginning of the unit key string
                        kem_unit_list = unit_key .. ","
                    elseif i == unit_list:num_items() -1 then
                        -- create the end of the unit key string
                        kem_unit_list = kem_unit_list .. unit_key
                    else
                        -- add a key in the middle of the string
                        kem_unit_list = kem_unit_list .. unit_key .. ","
                    end
                end

                -- the last two parameters aren't even used anymore, but it's easier to just keep them in
                -- spawn the wounded version of kemmy offscreen, and use the (x,y) arguments passed here to spawn Kemmler there later on
                lm:spawn_wounded_kemmy(x, y, kemmy:command_queue_index(), position)
                lm:log("WOUNDED KEMMY: Wounded Kemmy spawned at ("..x..", "..y..").")

                -- check if, after the battle, Kemmler is wounded - if not, kill the fake version of Kemmler. If he is, begin the respawn mechanic
                core:add_listener(
                    "WoundedKemmyBattleCompleted",
                    "BattleCompleted",
                    true,
                    function(context)
                        local liche = cm:get_faction("wh2_dlc11_vmp_the_barrow_legion")
                        if liche:faction_leader():is_wounded() then
                            lm:log("WOUNDED KEMMY: Kemmler was wounded in the battle. Beginning the respawn process!")
                            lm:respawn_kemmy(cm:model():turn_number(), kem_unit_list)
                        else
                            lm:log("WOUNDED KEMMY: Kemmler survived the battle. Axing wounded kemmy.")
                            lm:kill_wounded_kemmy()
                        end
                    end,
                    false
                )
            end,
            true
        )

        -- spawns a new agent on specific skills being learned
        core:add_listener(
            "LicheSpawnNewAgent",
            "CharacterSkillPointAllocated",
            function(context)
                return context:skill_point_spent_on() == "AK_hobo_camp_spawn_druid" or context:skill_point_spent_on() == "AK_hobo_camp_spawn_wight"
            end,
            function(context)
                -- will use these later, easier to do it this way then to write the same thing twice
                local subtype --: string
                local type --: string
                local art_set --: string

                -- barrow king stuff!
                if context:skill_point_spent_on() == "AK_hobo_camp_spawn_wight" then
                    subtype = "AK_hobo_barrow_king"
                    type = "champion"
                    local chance = cm:random_number(3, 1)
                    art_set = subtype.."_"..chance
                else -- druid stuff!
                    local druids = {"AK_hobo_druid_shadow", "AK_hobo_druid_death", "AK_hobo_druid_heavens"} --:vector<string>
                    local chance = cm:random_number(#druids, 1)
                    subtype = druids[chance]
                    type = "wizard"
                    local chance = cm:random_number(3, 1)
                    art_set = subtype.."_"..chance
                end

                -- grab random names from the legionNames.lua file
                local chance1 = cm:random_number(#lm._forenames, 1)
                local chance2 = cm:random_number(#lm._family_names, 1)
                local forename = lm._forenames[chance1]
                local family_name = lm._family_names[chance2]

                -- spawn the new druid/barrow king to the pool with the deets above
                cm:spawn_character_to_pool(
                    legion,
                    forename,
                    family_name,
                    "",
                    "",
                    50,
                    true,
                    type,
                    subtype,
                    false,
                    art_set
                )
            end,
            true
        )

        -- this actually doesn't do anything right now I think
        --[[core:add_listener(
            "LicheShadowDruidUIThing",
            "CharacterSelected",
            function(context)
                return context:character():character_subtype("AK_hobo_druid_shadow")
            end,
            function(context)
                local panel = find_uicomponent(core:get_ui_root(), "layout", "info_panel_holder")
                if not not panel then
                    local icon = find_uicomponent(panel, "secondary_info_panel_holder", "info_panel_background", "AgentInfoPopup", "action_list", "wh2_main_agent_action_wizard_passive_spread_corruption", "wh2_main_agent_action_wizard_passive_spread_corruption", "dy_action", "dy_icon")
                    if not not icon then
                        icon:SetImagePath("ui/campaign ui/effect_bundles/religion_undeath.png")
                    end
                    local text = find_uicomponent(panel, "secondary_info_panel_holder", "info_panel_background", "AgentInfoPopup", "action_list", "wh2_main_agent_action_wizard_passive_spread_corruption", "wh2_main_agent_action_wizard_passive_spread_corruption", "dy_action")
                    if not not text then
                        text:SetStateText("Spread Corruption")
                    end
                end
            end,
            true
        )]]

        core:add_listener(
            "LicheBattleTracker",
            "PanelOpenedCampaign",
            function(context)
                -- only run this if Kemmy's faction is in the battle
                return context.string == "popup_battle_results" and cm:pending_battle_cache_faction_is_involved(legion) and cm:get_faction(legion):is_human() and cm:get_local_faction() == legion
            end,
            function(context)
                -- needed to prevent some weird bugginess
                if cm:pending_battle_cache_num_defenders() >= 1 and cm:pending_battle_cache_num_attackers() >=1 then

                    -- get kemmler's CQI to check if he was in the battle
                    local cqi = lm:get_real_cqi()

                    -- player variable is used to define which side the player was on, defense or offense
                    local player --: string

                    -- enemy faction key
                    local enemy_faction --: string

                    if cm:pending_battle_cache_char_is_defender(cqi) then
                        player = "defender"
                    elseif cm:pending_battle_cache_char_is_attacker(cqi) then
                        player = "attacker"
                    else
                        -- Kemmy proper is not in the battle, cease fire
                        return
                    end

                    if not player then
                        lm:log("POST-BATTLE: Kemmler's faction not found in battle, despite being cached! Investigate?")
                        return
                    end

                    if player == "defender" then
                        local this_char_cqi, this_mf_cqi, this_faction = cm:pending_battle_cache_get_attacker(1)
                        enemy_faction = this_faction
                    elseif player == "attacker" then
                        local this_char_cqi, this_mf_cqi, this_faction = cm:pending_battle_cache_get_defender(1)
                        enemy_faction = this_faction
                    end

                    local attacker_won = cm:pending_battle_cache_attacker_victory()
                    local attacker_value = cm:pending_battle_cache_attacker_value()

                    local defender_won = cm:pending_battle_cache_defender_victory()
                    local defender_value = cm:pending_battle_cache_defender_value()

                    if not attacker_won and not defender_won then
                        -- draw or retreat or flee, do nothing
                        lm:log("POST-BATTLE: Both sides lost battle; not tracking NP change!")
                        return
                    end

                    lm:log("POST-BATTLE: Kemmler fought as ["..player.."].")
                    lm:log("POST-BATTLE: Enemy faction key ["..enemy_faction.."].")


                    -- divide value of defender and attacker armies, to get a multiplier for NP value, if the player wins
                    -- base the amount of NP lost on how many troops were lost

                    local np_result
                    if player == "attacker" then 
                        if attacker_won then 
                            local multiplier = defender_value / attacker_value 
                            multiplier = math.clamp(multiplier, 0.5, 1.5)

                            np_result = (defender_value / 1000) * multiplier
                            local kill_ratio = cm:model():pending_battle():percentage_of_defender_killed()

                            np_result = np_result * kill_ratio

                            if np_result >= 5 then 
                                np_result = 5 
                            end
                        end
                    elseif player == "defender" then
                        if defender_won then
                            local multiplier = attacker_value / defender_value
                            multiplier = math.clamp(multiplier, 0.5, 1.5)

                            local np_result = (attacker_value / 1000) * multiplier
                            local kill_ratio = cm:model():pending_battle():percentage_of_attacker_killed()

                            np_result = np_result * kill_ratio

                            if np_result >= 5 then 
                                np_result = 5 
                            end
                        end
                    end

                    np_result = math.floor(np_result)

                    core:add_listener(
                        "LicheTTSet",
                        "ComponentMouseOn",
                        function(context)
                            return context.string == "enslavewh_captive_option_enslave_vampire_counts"
                        end,
                        function(context)
                            cm:callback(function() 
                                local tt = find_uicomponent(core:get_ui_root(), "tooltip_captive_options")
                                local pr_uic = find_uicomponent(tt, "effects_list", "pooled_resources")

                                pr_uic:SetVisible(true)
                                local np_uic = core:get_or_create_component("necropower", "ui/kemmler/pr_captive_tooltip_template", pr_uic)
                                pr_uic:Adopt(np_uic:Address())

                                np_uic:SetState('positive')
                                np_uic:SetImagePath('ui/kemmler/AK_hobo_necropowa_bullet.png')
                                np_uic:SetStateText(effect.get_localised_string("pooled_resources_display_name_necropower") .. ": +"..np_result)

                                local value = find_uicomponent(np_uic, "value")
                                value:SetState('positive')
                                value:SetStateText('')
                            end, 0.1)
                        end,
                        true
                    )

                    -- add the NP when that button is pressed
                    core:add_listener(
                        "LicheApplyNP",
                        "ComponentLClickUp",
                        function(context)
                            return context.string == "enslavewh_captive_option_enslave_vampire_counts"
                        end,
                        function(context)
                            -- add on the PR and log it!
                            cm:faction_add_pooled_resource(legion, "necropower", "necropower_battles", np_result)

                            lm:log("POST-BATTLE: Kemmler wins! Necromantic Power added for Kemmler.")
                            lm:log("POST-BATTLE: Necromantic Power added [" .. np_result .. "].")
                            lm:log("POST-BATTLE: Other army gold-value is [" .. defender_value .. "].")
                            lm:log("POST-BATTLE: Kemmler army gold-value is [" .. attacker_value .. "].")
                        end,
                        false
                    )

                    -- remove the above listener when the panel closed, to prevent any over-hang
                    core:add_listener(
                        "LicheKillAboveListener",
                        "PanelClosedCampaign",
                        function(context)
                            return context.string == "popup_battle_results"
                        end,
                        function(context)
                            core:remove_listener("LicheApplyNP")
                        end,
                        false
                    )
                end    
            end,
            true
        )


        local killBloodlines = {
            "wh2_dlc11_vmp_ritual_bloodline_awaken_blood_dragon_01",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_blood_dragon_02",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_blood_dragon_03",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_lahmian_01",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_lahmian_02",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_lahmian_03",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_necrarch_01",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_necrarch_02",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_necrarch_03",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_strigoi_01",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_strigoi_02",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_strigoi_03",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_von_carstein_01",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_von_carstein_02",
            "wh2_dlc11_vmp_ritual_bloodline_awaken_von_carstein_03"
        }--: vector<string>
        local cqi = cm:get_faction(legion):command_queue_index()
        for i = 1, #killBloodlines do
            cm:set_ritual_unlocked(cqi, killBloodlines[i], false)
        end


        end)
    if not ok then LicheLog.error(tostring(err)) end
end

-- needed to be done on UI created for obvious reasons
core:add_ui_created_callback(
    function()
        if cm:whose_turn_is_it() == legion then
            kill_blood_kisses_and_tech()
        end
    end
)

cm:add_first_tick_callback(
    function()
        -- check if Kemmler is the local player
        -- all the stuff that has to be done on Liche turnstart will also be done here, for loading games

        liche_init_listeners()

        if cm:get_local_faction() == legion then
            -- UI stuff
            kill_blood_kisses_and_tech()
            CampaignUI.ClearSelection()

            add_pr_uic()

            set_hunters_panel()

            -- quick check for NP life added
            local turn = cm:model():turn_number()
            local npvalue = lm:get_necropower()

            if npvalue >= 80 then
                -- checks the last turn lives changed within this method
                lm:add_life()
            end

            if npvalue <= 20 then
                lm:apply_attrition()
            end
        else
            hide_kemmler_hunter_panel()
        end
    end
)