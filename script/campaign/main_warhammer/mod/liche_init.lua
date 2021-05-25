------------------------------------------
-- Initialization script, anything that --
-- doesn't belong in the faction script --
-- or the manager will go here, such as --
-- listeners and what not               --
------------------------------------------

-- tell Mixu to pls not kill this Kemmy, pls pls pls
mixer_kill_hobo_kemmy = false

-- refernces some stuff that will be used ALL over
local lm = get_lichemanager()
local legion = lm:get_faction_key()

local UTILITY = lm:get_module_by_name("utility")
local LicheLog = lm:get_module_by_name("log")


----------------------
-- Helper Functions --
----------------------

--v function() --> number
local function calculate_post_battle_np()
    -- get kemmler's CQI to check if he was in the battle
    local cqi = lm:get_real_cqi()

    if cqi == 0 then
        return 0
    end

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
        return 0
    end

    if not player then
        lm:log("POST-BATTLE: Kemmler's faction not found in battle, despite being cached! Investigate?")
        return 0
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
        return 0
    end

    lm:log("POST-BATTLE: Kemmler fought as ["..player.."].")
    lm:log("POST-BATTLE: Enemy faction key ["..enemy_faction.."].")


    -- divide value of defender and attacker armies, to get a multiplier for NP value, if the player wins
    -- base the amount of NP lost on how many troops were lost

    local np_result = 0
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

    return np_result
end

-- checks curent NP value and applies attrition or adds a life
local function check_np_effects()
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
end

-- checks current max lives - if 0, trigger a single event


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

---- TODO remove dis
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

-- uggo resolution to the tech notification shit
local function disable_tech_notification()
    --# assume disable_tech_notification: function()

    local docker = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "end_turn_docker")
    if not is_uicomponent(docker) then
        cm:callback(function() 
            disable_tech_notification()
        end, 0.1)
        return
    end

    local settings_button = find_uicomponent(docker, "notification_frame", "button_notification_settings")

    if not is_uicomponent(settings_button) then
        cm:callback(function() 
            disable_tech_notification()
        end, 0.1)
        return
    end

    settings_button:SimulateLClick()

    cm:callback(function()
        local list = find_uicomponent(docker, "notification_settings_list")

        local checkbox = find_uicomponent(list, "2", "checkbox_toggle")
        if is_uicomponent(checkbox) then
            if checkbox:CurrentState() == "selected" then
                checkbox:SimulateLClick()
            end
        end

        cm:repeat_callback(function()
            if is_uicomponent(list) and list:Visible() then
                settings_button:SimulateLClick()
            else
                cm:remove_callback("kill_that_notification_list")
            end
        end, 0.1, "kill_that_notification_list")
        
    end, 0.5)
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

        local orphans = {}

        -- remove all other children of the parent bar, except for the treasury, so the new PR will be to the right of the treasury holder
        for i = 0, parent:ChildCount() - 1 do
            local child = UIComponent(parent:Find(i))
            if child:Id() ~= "treasury_holder" then
                -- dummy:Adopt(child:Address())
                orphans[#orphans+1] = child:Address()
            end
        end

        for i = 1, #orphans do
            dummy:Adopt(orphans[i])
        end
        
        -- add the PR component!
        parent:Adopt(uic:Address())

        for i = 1, #orphans do
            parent:Adopt(orphans[i])
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

    if cm:get_local_faction_name(true) == legion then
        create_uic()
        check_value()
    end

    local function adjust_tooltip()
        -- local tooltip = core:get_or_create_component("tooltip_necropower_breakdown", "ui/campaign ui/tooltip_pooled_resource_breakdown", core:get_ui_root())
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
            -- TODO reenable this, for now no tooltip :)
            lm:callback(adjust_tooltip, 10, "adjust_tooltip")
        end,
        true
    )

    core:add_listener(
        pooled_resource_key.."_value_changed",
        "PooledResourceEffectChangedEvent",
        function(context)
            return context:faction():name() == legion and context:resource():key() == pooled_resource_key and context:faction():is_human() and cm:get_local_faction_name(true) == legion
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

local function jacsen_are_you_ok()
    if core:svr_load_bool("JacsenSurvived") == true then
        local lm = get_lichemanager()

        -- prevent Jacsen from being recruited elsewise
        lm:set_regiment_status("AK_hobo_ror_jacsen", "STASIS")
    
        cm:add_turn_countdown_event(
            legion,
            9,
            "LichemanagerUnlockRoR",
            "AK_hobo_ror_jacsen"
        )

        cm:trigger_incident(legion, "jacsen_unlocked_early", true)
    end
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

            -- hide the character name component and replace it, hopefully?
            local dy_character_name = find_uicomponent(panel, "main", "characters_holder", "dy_character_name")
            dy_character_name:CopyComponent("dy_character_name_copy")
            dy_character_name:PropagatePriority(1)

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
        end,
        true
    )
end

--v function(uic: CA_UIC, region_type: string, settlement_string: string)
local function add_settlement_floating_icon(uic, region_type, settlement_string)
    local parent = find_uicomponent(uic, "list_parent", "icon_holder")
    if not is_uicomponent(parent) then
        -- TODO error log
        return
    end

    local region_obj = cm:get_region(settlement_string)

    local uic_key = ""
    local uic

    if region_type == "occupy" then
        uic_key = "icon_kemm"
    elseif region_type == "ruins" then
        uic_key = "icon_defile"
    end

    local extant = find_uicomponent(parent, uic_key)

    if is_uicomponent(extant) then
        uic = extant
    else
        local resource_icon = find_uicomponent(parent, "resource_icon")
        uic = UIComponent(resource_icon:CopyComponent(uic_key))
    end

    if region_type == "occupy" then
        -- check if there's a 
    end

    local valid = true
    local tier = 0 --: number -- fuck you Kailua
    
    if region_type == "occupy" then
        if lm:get_necropower() < 60 then
            valid = false
        end
    elseif region_type == "ruins" then
        if lm._ruins[settlement_string].is_locked then
            valid = false
        else
            tier = lm:calculate_tier(settlement_string)
        end
    end
    
    local tt = "{{tr:kemmler_floating_settlement_tt_"..region_type.."_"
    local image_path = "ui/kemmler/AK_hobo_"..region_type.."_"

    if not valid then
        tt = tt .. "no}}"
        image_path = image_path .. "no.png"
    elseif valid and tier > 0 then
        tt = tt .. tier .. "}}"
        image_path = image_path .. tier .. ".png"
    else
        tt = tt .. "yes}}" 
        image_path = image_path .. "yes.png"
    end

    uic:SetVisible(true)
    uic:SetImagePath(image_path)
    uic:SetInteractive(true)
    uic:SetTooltipText(tt, true)
end

--v function(uic: CA_UIC, settlement_string: string)
local function check_settlement_floating_icons(uic, settlement_string)
    local parent = find_uicomponent(uic, "list_parent", "icon_holder")
    if not is_uicomponent(parent) then
        return
    end

    local region_obj = cm:get_region(settlement_string)

    do
        -- check ruins thing
        local extant = find_uicomponent(parent, "icon_defile")

        if is_uicomponent(extant) and extant:Visible() then
            if not region_obj:is_abandoned() then
                extant:SetVisible(false)
            end
        else
            if region_obj:is_abandoned() then
                add_settlement_floating_icon(uic, "ruins", settlement_string)
            end
        end
    end
    do
        -- check landmark thing
        local extant = find_uicomponent(parent, "icon_kemm")

        if lm:is_landmark_region(settlement_string) then
            if is_uicomponent(extant) and extant:Visible() then
                if region_obj:owning_faction():name() == legion then
                    extant:SetVisible(false)
                end
            else 
                if region_obj:owning_faction():name() ~= legion then
                    add_settlement_floating_icon(uic, "occupy", settlement_string)
                end
            end
        end
    end
end

local function check_settlements_on_map()
    local root = core:get_ui_root()
    local parent = find_uicomponent(root, "3d_ui_parent")
    if not is_uicomponent(parent) then
        return
    end

    for i = 0, parent:ChildCount() -1 do
        local child = UIComponent(parent:Find(i))
        local child_id = child:Id()
        if child_id:sub(1, 17) == "label_settlement:" then
            local settlement_string = child_id:gsub("label_settlement:", "")

            check_settlement_floating_icons(child, settlement_string)
--[[            if lm:is_landmark_region(settlement_string) and not cm:get_region(settlement_string):owning_faction():name() == legion then
                add_settlement_floating_icon(child, "occupy", settlement_string)
            end
            if cm:get_region(settlement_string):is_abandoned() then
                add_settlement_floating_icon(child, "ruins", settlement_string)
            end]]
        end
    end
end

----------------
-- Listeners! --
----------------

-- this is triggered ONCE, after the faction start script (hobo_kemmy_start.lua) is over and the intro battle is completed
function lichemaster_postbattle_setup()

    add_missions_and_unlock_requirements()
    kill_extra_recruitment()

    -- trigger the How To Play event
    cm:show_message_event(
        legion,
        "event_feed_strings_text_wh2_scripted_event_how_they_play_title",
        "factions_screen_name_"..legion,
        "event_feed_strings_text_AK_hobo_how",
        true,
        594,
        nil,
        nil
    )

    -- check to see if Jacsen survived pre-battle (delay to make sure the below stuff worked fine)
    cm:callback(function()
        jacsen_are_you_ok()
    end, 5)

end

-- run every game creation or game load
local function liche_init_listeners()
    local ok, err = pcall(function()
        -- read through the entirety of the current region list on script load
        -- done on every script load, the ruins are saved but doing this will catch any mistakes or changes
        do
            local region_list = cm:model():world():region_manager():region_list()
            for i = 0, region_list:num_items() - 1 do
                local current_region = region_list:item_at(i)
                if current_region:is_abandoned() then
                    lm:set_ruin(current_region:name())
                end
            end
        end

        -- only runs on first load
        if not cm:get_saved_value("liche_init") then
            -- set up data-end objects for tracking LL progress and LoU progress
            lm:setup_regiments()
            lm:setup_lords()
            lm:setup_hero_spawn_rank()
            -- lm:setup_raise_dead()
        
            -- disable confederation betwixt Kemmy and Vampies
            cm:force_diplomacy(legion, "culture:wh_main_vmp_vampire_counts", "form confederation", false, false, true)

            -- remove units from the Raise Dead pool
            kill_extra_recruitment()

            -- remove unwanted tech
            kill_technologies()

            -- start the victory objectives!
            local vic_con = require("script/lichemanager/tables/victory_condition")
            for i = 1, #vic_con do
                cm:trigger_custom_mission_from_string(legion, vic_con[i])
            end

            cm:set_saved_value("liche_init", true)
        end

        -- every Kemmler turn, check NP. 
        -- If it's over 80, and lives hasn't been increased for 20 turns, then +1 lives
        -- If under 20, add attrition throughout the character list to any character not in Kemmler's region
        core:add_listener(
            "LicheKemmlerLives",
            "FactionTurnStart",
            function(context)
                return context:faction():name() == legion --and context:faction():is_human()
            end,
            function(context)
                check_np_effects()

                -- TODO temp disbabled
                -- lm:refresh_raise_dead()
            end,
            true
        )

        -- read Max Lives change; if it hits 0, trigger an event
        core:add_listener(
            "LicheMaxLivesLost",
            "PooledResourceEffectChangedEvent",
            function(context)
                return context:resource():key() == "lichemaster_max_remaining_lives" and context:faction():is_human() and context:faction():pooled_resource("lichemaster_max_remaining_lives"):value() <= 0
            end,
            function(context)
                local event_string_base = "event_feed_strings_text_AK_hobo_zero_max_lives_"

                cm:show_message_event(
                    context:faction():name(),
                    event_string_base .. "primary_detail",
                    event_string_base .. "secondary_detail",
                    event_string_base .. "flavour_text",
                    true,
                    131
                )
            end,
            false
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
                lm:legendary_lord_spawned(char)
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

                if lm:get_hero_spawn_rank() == 5 then
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
                    local region = context:garrison_residence():region()
                    return region:owning_faction():name() == legion and region:name() == "wh_main_northern_grey_mountains_blackstone_post" and region:settlement():primary_slot():building():building_level() >= 2
                end,
                function(context)
                    cm:complete_scripted_mission_objective("lichemaster_lord_nameless", "lichemaster_lord_nameless", true)
                    lm:unlock_lord("AK_hobo_nameless")

                    core:remove_listener("LicheNamelessUnlock2")
                end,
                false
            )

            core:add_listener(
                "LicheNamelessUnlock2",
                "GarrisonOccupiedEvent",
                function(context)
                    local region = context:garrison_residence():region()
                    local settlement = region:settlement()
                    return (region:name() == "wh_main_northern_grey_mountains_blackstone_post" and context:character():faction():name() == legion and 
                    settlement:primary_slot():building():building_level() >= 2)
                end,
                function(context)
                    cm:complete_scripted_mission_objective("lichemaster_lord_nameless", "lichemaster_lord_nameless", true)
                    lm:unlock_lord("AK_hobo_nameless")

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
                    return context.number >= 6
                end,
                function(context)
                    cm:complete_scripted_mission_objective("lichemaster_lord_priestess", "lichemaster_lord_priestess", true)
                    lm:unlock_lord("AK_hobo_priestess")
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
                        core:remove_listener("LicheDraescaUnlock")
                    end
                end,
                true
            )
        end

        core:add_listener(
            "LichemanagerUnlockRoR",
            "LichemanagerUnlockRoR",
            true,
            function(context)
                cm:trigger_incident(legion, "barrow_"..context.string, true)
                lm:set_regiment_status(context.string, "AVAILABLE")
            end,
            true
        )

        -- prevent AI from settling ruins post-Kemmy-raze
        core:add_listener(
            "LicheRazedSettlement",
            "CharacterRazedSettlement",
            function(context)
                return context:character():faction():name() == legion
            end,
            function(context)
                local garr = context:garrison_residence()
                local region = garr:region()
                local region_key = region:name()

                local num_turns = cm:random_number(8, 4)

                cm:set_saved_value("lm_ruin_cooldown|"..region_key, num_turns)
                cm:cai_disable_targeting_against_settlement("settlement:"..region_key)
            end,
            true
        )

        -- unlock AI settlement after x turn_to_spawn
        core:add_listener(
            "LicheUnrazedSettlement",
            "RegionTurnStart",
            function(context)
                local region_key = context:region():name()
                local test = cm:get_saved_value("lm_ruin_cooldown|"..region_key)
                return test and test > 0
            end,
            function(context)
                local region = context:region()
                local region_key = region:name()
                local cd = cm:get_saved_value("lm_ruin_cooldown|"..region_key) -1

                if cd <= 0 then
                    cm:cai_enable_targeting_against_settlement("settlement:"..region_key)
                    cm:set_saved_value("lm_ruin_cooldown|"..region_key, nil)
                else
                    cm:set_saved_value("lm_ruin_cooldown|"..region_key, cd)
                end
            end,
            true
        )
        
        core:add_listener(
            "LicheBattleCompletedOccupyUI",
            "ScriptEventPlayerWinsSettlementAttackBattle",
            function(context)
                --lm:log("TESTING 0000000")
                local pb = context:pending_battle()
                --[[lm:log(cm:pending_battle_cache_faction_is_involved(legion))
                lm:log(cm:get_local_faction_name(true) == legion)
                lm:log(pb:seige_battle())
                lm:log(pb:has_attacker())
                lm:log(pb:attacker():faction():name() == legion)]]
                return cm:pending_battle_cache_faction_is_involved(legion) and cm:get_local_faction_name(true) == legion and pb:seige_battle() and pb:has_attacker() and pb:attacker():faction():name() == legion --and pb:has_defender() -- Requires an actual garrisoned army, unnecessary
            end,
            function(context)
                --lm:log("TESTING 111111")
                local pb = context:pending_battle()
                local region = pb:contested_garrison():region()
                local region_key = region:name()

                --[[local attacker = pb:attacker()

                local char = attacker

                local char_cqi = char:command_queue_index()]]

                core:add_listener(
                    "LicheSettlementCapturedPanel",
                    "PanelOpenedCampaign",
                    function(context)
                        return context.string == "settlement_captured" and cm:get_local_faction_name(true) == legion
                    end,
                    function(context)
                        local root = core:get_ui_root()
        
                        local panel = find_uicomponent(core:get_ui_root(), "settlement_captured")
                        --local name = find_uicomponent(panel, "header_docker", "panel_subtitle", "settlement_name"):GetStateText()
                                
                        if not region:is_abandoned() then
                            if not lm:can_occupy_region(region_key) then
                                local loot_and_occupy_button = find_uicomponent(panel, "9819842")
                                local occupy_button = find_uicomponent(panel, "9819843")
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
                    false
                )
            end,
            true
        )

        -- all the stuff needed for the Ruins UI
        core:add_listener(
            "LicheRuinsDefileBarrowUI",
            "CharacterCapturedSettlementUnopposed",
            function(context)
                return context:character():faction():name() == legion and cm:get_local_faction_name(true) == legion
            end,
            function(context)
                local region = context:garrison_residence():region()
                local region_key = region:name()

                local character = context:character()
                local character_cqi = character:command_queue_index()

                core:add_listener(
                    "LicheRuinsSettlemendCapturedPanel",
                    "PanelOpenedCampaign",
                    function(context)
                        return context.string == "settlement_captured" and cm:get_local_faction_name(true) == legion
                    end,
                    function(context)
                        local panel = UIComponent(context.component)

                        if region:is_abandoned() then
                            -- local search_ruins_button = find_uicomponent(panel, "1240")
                            local resettle_button = find_uicomponent(panel, "9819844")
                            local colonise_button = find_uicomponent(panel, "9819841")
                            -- if not not search_ruins_button then 
                            --     UTILITY.remove_component(search_ruins_button) 
                            -- end
                            if not lm:can_occupy_region(region_key) then
                                -- remove occupation options
                                if not not colonise_button then
                                    UTILITY.remove_component(colonise_button)
                                end
                                if not not resettle_button then
                                    UTILITY.remove_component(resettle_button)
                                end
        
                                lm:ruinsUI(region_key)
                            else
                                -- keep occupation options, passing the number in order to move the UIC over
                                if not not colonise_button then
                                    lm:ruinsUI(region_key, "9819841")
                                elseif not not resettle_button then
                                    lm:ruinsUI(region_key, "9819844")
                                else
                                    lm:error("How did this happen?")
                                end
                            end
        
                            -- listens for an occupy option being pressed
                            core:add_listener(
                                "LicheOccupyButtonPressed",
                                "ComponentLClickUp",
                                function(context)
                                    return context.string == "option_button" and cm:get_local_faction_name(true) == legion
                                    --local component = find_uicomponent(core:get_ui_root(), "settlement_captured", "button_parent", "template_button_occupy", "option_button")
                                end,
                                function(context)
                                    -- the Defile Barrow option has been pressed, do it. Otherwise, do nothing, just end the listener
                                    if UIComponent(UIComponent(context.component):Parent()):Id() == "template_button_occupy" then
                                        local button = find_uicomponent(panel, "button_parent", "9819845", "option_button")
                                        button:SimulateLClick() -- click the "Do Nothing" button
        
                                        lm:defile_ruin(region_key, character_cqi) -- set the ruin as defiled
                                    end
                                end,
                                false
                            )
                        else -- region is occupied, but with a dead garrison
                            if not lm:can_occupy_region(region_key) then
                                local loot_and_occupy_button = find_uicomponent(panel, "9819842")
                                local occupy_button = find_uicomponent(panel, "9819843")
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
                return context:character():faction():name() == legion and cm:get_local_faction_name(true) == legion
                -- required to prevent the Wounded Kemmy spawn from interrupting the internal tracking
                and not lm:is_respawn_pending()
            end,
            function(context)
                local char_obj = context:character()
                local char_cqi = char_obj:command_queue_index()
                lm:set_character_selected_cqi(char_cqi)

                cm:callback(function()
                    if not char_obj:has_military_force() then
                        -- not general, don't go on
                        return
                    end
                    
                    lm:ror_UI(char_cqi)

                    -- in case there's a click from settlement to garrisoned lord
                    -- lm:lord_lock_UI(false)
                end, 0.1)
            end,
            true
        )
            
        -- lock the create army button if there's no available lords - prevents a glitch where you can recruit a locked general
        --[[core:add_listener(
            "LicheHordePanel",
            "ComponentLClickUp",
            function(context)
                return context.string == "tab_horde_buildings" and cm:get_local_faction_name(true) == legion
            end,
            function(context)
                lm:lord_lock_UI(false)
            end,
            true
        )]]

        --[[core:add_listener(
            "LicheSettlementPanel",
            "PanelOpenedCampaign",
            function(context)
                return context.string == "settlement_panel" and cm:get_local_faction_name(true) == legion
            end,
            function(context)
                cm:callback(function()
                    lm:lord_lock_UI(true)
                end, 0.1)
            end,
            true
        )]]

        -- hides all the unavailable lords in the create army panel
        core:add_listener(
            "LicheGeneralUI",
            "ComponentLClickUp",
            function(context)
                return context.string == "button_create_army" and cm:get_local_faction_name(true) == legion
            end,
            function(context)
                cm:callback(function()
                    lm:lord_pool_UI("lord")
                end, 0.1)
            end,
            true
        )

        core:add_listener(
            "LicheGeneralUI",
            "ComponentLClickUp",
            function(context)
                return context.string == "button_agents" and cm:get_local_faction_name(true) == legion
            end,
            function(context)
                cm:callback(function()
                    lm:lord_pool_UI("agent")
                end, 0.1)
            end,
            true
        )

        core:add_listener(
            "LicheAgentUI",
            "ComponentLClickUp",
            function(context)
                return (context.string == "wizard" or context.string == "champion") and UIComponent(UIComponent(context.component):Parent()):Id() == "button_group_agents" and cm:get_local_faction_name(true) == legion
            end,
            function(context)
                local str = context.string
                cm:callback(function()
                    local list = find_uicomponent("character_panel", "agent_parent", "wizard_type", "type_list")

                    if str == "wizard" then
                        for i = 0, list:ChildCount() -1 do
                            local child = UIComponent(list:Find(i))
                            local id = tostring(child:Id())

                            if not string.find(id, "AK_hobo_druid") then
                                child:SetVisible(false)
                            end
                        end
                    elseif str == "champion" then
                        for i = 0, list:ChildCount() -1 do
                            local child = UIComponent(list:Find(i))
                            local id = child:Id()
                            if not string.find(id, "AK_hobo_barrow_king") then
                                child:SetVisible(false)
                            end
                        end
                    end

                    local nc = find_uicomponent("character_panel", "no_candidates_panel")
                    --nc:SetVisible(false)
            
                    if nc:Visible() then
                        local nc_tx = find_uicomponent(nc, "tx_reason")
                        nc_tx:SetStateText("Unlock agents through Defiling Barrows.")
                    end
                end, 0.1)
            end,
            true
        )

        -- run once a turn, see if turn_to_spawn is this turn. 
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
                local wounded_kemmy_obj = cm:get_character_by_cqi(wounded_kemmy_cqi)
                local kemmy_cqi = lm:get_real_cqi()
    
                local spawn_x, spawn_y, spawn_region = lm:get_wounded_kemmy_position()
                if spawn_x == -1 then
                    lm:error("Spawn Wounded Kemmy but the coordinates returned were -1, -1 - investigate.")
                    return
                end

                spawn_x, spawn_y = cm:find_valid_spawn_location_for_character_from_position(legion, spawn_x, spawn_y, true)

                local unit_list = lm:get_unit_list()
    
                -- respawns original Kemmy, with the saved unit list from when he died
                cm:create_force_with_existing_general(
                    cm:char_lookup_str(kemmy_cqi),
                    legion, 
                    unit_list,
                    spawn_region,
                    spawn_x,
                    spawn_y,
                    function(cqi)
                        -- blah
                    end
                )
                lm:log("WOUNDED KEMMY: Kemmler respawned in region ["..spawn_region.."] at location ("..spawn_x..", "..spawn_y.."). Enjoy.")
                
                -- axe the wounded version and revert all the respawn details
                lm:kill_wounded_kemmy()
            end,
            true
        )

        -- track character in pending battle for occupy/ruins/etc
        core:add_listener(
            "LicheTrackCharacterInBattle",
            "PendingBattle",
            function(context)
                local pb = context:pending_battle()
                if pb:has_attacker() and pb:has_defender() then
                    local attacker_faction = pb:attacker():faction():name()
                    local defender_faction = pb:defender():faction():name()
                    return (attacker_faction == legion or defender_faction == legion) --and lm:can_revive()
                end
                return false
            end,
            function(context)
                local pb = context:pending_battle()
                local attacker = pb:attacker()
                local defender = pb:defender()
                local attacker_faction = attacker:faction():name()

                if attacker_faction == legion then
                    lm:set_character_in_battle_cqi(attacker:command_queue_index())
                else
                    lm:set_character_in_battle_cqi(defender:command_queue_index())
                end
            end,
            true
        )

        -- spawn Wounded Kemmy off-screen when Kemmler is in a pending battle and has at least one life.
        -- PendingBattle happens BEFORE the battle begins, around the time the "attack" and "retreat" options are available
        core:add_listener(
            "LicheKemmyWoundedOffscreen",
            "PendingBattle",
            function(context)
                local pb = context:pending_battle()
                if pb:has_attacker() and pb:has_defender() then
                    local attacker_faction = pb:attacker():faction():name()
                    local defender_faction = pb:defender():faction():name()
                    return (attacker_faction == legion or defender_faction == legion) and lm:can_revive()
                end
                return false
            end,
            function(context)
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
                elseif defender:character_subtype("vmp_heinrich_kemmler") then
                    kemmy = defender
                else
                    for i = 0, secondary_attackers:num_items() - 1 do
                        local secondary_attacker = secondary_attackers:item_at(i)
                        if secondary_attacker:character_subtype("vmp_heinrich_kemmler") then
                            kemmy = secondary_attacker
                            break
                        end
                    end
                    for i = 0, secondary_defenders:num_items() - 1 do
                        local secondary_defender = secondary_defenders:item_at(i)
                        if secondary_defender:character_subtype("vmp_heinrich_kemmler") then
                            kemmy = secondary_defender
                            break
                        end
                    end
                end

                -- don't go any further if Kemmler isn't actually in this battle
                if not kemmy then
                    return
                end

                lm:log("WOUNDED KEMMY: Kemmler is in a battle and has enough stuff to revive. Spawning Wounded Kemmy off-screen.")

                local x, y = kemmy:logical_position_x(), kemmy:logical_position_y()

                local kem_unit_list = "" --: string
                local unit_list = kemmy:military_force():unit_list()
                for i = 0, unit_list:num_items() -1 do
                    local unit = unit_list:item_at(i)
                    local unit_key = unit:unit_key()
                    if unit_key:find("_cha_") then
                        -- ignore characters
                    elseif kem_unit_list == "" then
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

                -- spawn the wounded version of kemmy offscreen
                lm:spawn_wounded_kemmy(kemmy:command_queue_index(), kem_unit_list)
            end,
            true
        )

        -- needed for Wounded Kemmler to die if it's just a "Continue Siege" battle above
        core:add_listener(
            "WoundedKemmyContinueSiege",
            "BattleCompletedCameraMove",
            function()
                return cm:pending_battle_cache_faction_is_involved(legion) and lm:is_respawn_pending()
            end,
            function()
                local pb = cm:model():pending_battle()

                if not pb:has_been_fought() then
                    lm:log("WOUNDED KEMMY: Kemmler is only sieging. Axing wounded kemmy.")
                    lm:kill_wounded_kemmy()
                end
            end,
            true
        )

        -- check if, after the battle, Kemmler is wounded - if not, kill the fake version of Kemmler. If he is, begin the respawn mechanic
        core:add_listener(
            "WoundedKemmyBattleCompleted",
            "BattleCompleted",
            function(context)
                -- should only be true through spawn_wounded_kemmy()
                return lm:is_respawn_pending()
            end,
            function(context)
                local liche = cm:get_faction(legion)
                if liche:faction_leader():is_wounded() then
                    lm:log("WOUNDED KEMMY: Kemmler was wounded in the battle. Beginning the respawn process!")
                    lm:respawn_kemmy(cm:model():turn_number())
                else
                    lm:log("WOUNDED KEMMY: Kemmler survived the battle. Axing wounded kemmy.")
                    lm:kill_wounded_kemmy()
                end
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

                -- grab random names from the legion_names.lua file
                local forenames, family_names = lm:get_names()

                local forename = forenames[cm:random_number(#forenames, 1)]
                local family_name = family_names[cm:random_number(#family_names, 1)]

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

        core:add_listener(
            "LicheTTSet",
            "ComponentMouseOn",
            function(context)
                return context.string == "enslavewh_captive_option_enslave_vampire_counts" and cm:pending_battle_cache_faction_is_involved(legion) and cm:get_local_faction_name(true) == legion
            end,
            function(context)
                local np_result = calculate_post_battle_np()
                if np_result == 0 then
                    -- issue!
                    return
                end

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

        -- display the Necromantic Power add from Sack
        core:add_listener(
            "LicheTTSet",
            "PanelOpenedCampaign",
            function(context)
                return context.string == "settlement_captured" and cm:get_local_faction_name(true) == legion
            end,
            function(context)
                local panel = find_uicomponent("settlement_captured")
                if not is_uicomponent(panel) then
                    -- wtf
                    lm:error("LicheTTSet listener triggered but the panel doesn't exist")
                    return false
                end

                local sack_button = find_uicomponent(panel, "button_parent", "956")
                if not is_uicomponent(sack_button) then
                    -- can't sack this settlement
                    return false
                end

                local icon_parent = find_uicomponent(sack_button, "frame", "icon_parent")
                local copy = find_uicomponent(icon_parent, "dy_income")

                local np_uic = UIComponent(copy:CopyComponent("dy_necropower"))
                local np_uic_icon = UIComponent(np_uic:Find("icon"))

                local tt = effect.get_localised_string("pooled_resources_display_name_necropower").."||"..effect.get_localised_string("pooled_resources_description_necropower")

                np_uic:SetTooltipText(tt, true)
                np_uic:SetStateText(tostring(calculate_post_battle_np()))

                np_uic_icon:SetTooltipText(tt, true)
                np_uic_icon:SetImagePath('ui/kemmler/AK_hobo_necropowa_bullet.png')
            end,
            true
        )
        
        core:add_listener(
            "LicheApplyNP",
            "CharacterPostBattleEnslave",
            function(context)
                return context:character():faction():name() == legion
            end,
            function(context)
                local np_result = calculate_post_battle_np()
                if np_result == 0 then
                    -- issue!
                    return
                end
                cm:faction_add_pooled_resource(legion, "necropower", "necropower_battles", np_result)
            end,
            true
        )

        -- re-unlock RoR if they die/are disbanded
        core:add_listener(
            "LichemasterRorDisbanded",
            "UnitDisbanded",
            function(context)
                return context:unit():faction():name() == legion and lm:is_regiment_key(context:unit():unit_key())
            end,
            function(context)
                lm:set_regiment_status(context:unit():unit_key(), "AVAILABLE")
            end,
            true
        )

        core:add_listener(
            "LichemasterRorDestroyed",
            "BattleCompleted",
            function(context)
                return cm:pending_battle_cache_faction_is_involved(legion)
            end,
            function(context)
                lm:post_battle_regiment_status_check()

                -- if this is a Barrow Invasion, kill the invasion and revive the barrow units!
                local invasion_key = lm._defile_data.invasion_key

                if is_string(invasion_key) then
                    lm._defile_data.invasion_key = nil
                    local invasion = invasion_manager:get_invasion(invasion_key)

                    if invasion then invasion:kill() end

                    lm:revive_barrow_units(lm._defile_data.cqi)
                end
            end,
            true
        )

        -- MP Compat listeners
        core:add_listener(
            "LichemasterLegionOfUndeathSpawn",
            "UITrigger",
            function(context)
                return context:trigger():starts_with("lichemanager_ror|")
            end,
            function(context)
                local str = context:trigger()
                local char_cqi = context:faction_cqi()
                local regiment_key = string.gsub(str, "lichemanager_ror|", "")

                -- make sure that regiment object exists
                local regiment_obj = lm:get_regiment_with_key(regiment_key)

                -- lock the object, to prevent more than one existing
                regiment_obj:set_status("RECRUITED")

                -- add the unit and charge the -5 NP
                cm:grant_unit_to_character("character_cqi:"..char_cqi, regiment_key)
                cm:faction_add_pooled_resource(legion, "necropower", "necropower_ror", -5)

                lm:log("LEGIONS OF UNDEATH: Spawning Legion with key ["..regiment_key.."] for character with CQI ["..char_cqi.."].")
            end,
            true
        )

        core:add_listener(
            "LichemasterDefileBarrowTrigger",
            "UITrigger",
            function(context)
                return context:trigger():starts_with("lm_db|")
            end,
            function(context)
                local str = context:trigger()
                local char_cqi = context:faction_cqi()
                local effect = string.gsub(str, "lm_db|", "")

                -- tell both clients which character to apply this all to!
                lm:set_character_selected_cqi(char_cqi)

                --if effect == "effectBundle" then
                    --self:ruinsEffectBundle()
                if effect == "spawnAgent" then
                    lm:ruins_spawn_agent()
                elseif effect == "spawnRoR" then
                    lm:ruins_spawn_ror()
                elseif effect == "enemy" then
                    lm:ruins_spawn_enemy()
                elseif effect == "item" then
                    lm:ruins_spawn_item()
                end

                --self:force_replen()
                if effect ~= "enemy" then
                    lm:revive_barrow_units()
                end
                
                lm:apply_defile_xp()
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

        for i = 1, #killBloodlines do
            cm:lock_ritual(cm:get_faction(legion), killBloodlines[i])
        end
    end)
    if not ok then LicheLog.error(tostring(err)) end
end

cm:add_first_tick_callback(
    function()
        -- all the stuff that has to be done on Liche turnstart will also be done here, for loading games
        local kemmy = cm:get_faction(legion)

        -- don't do shit if Kemmy isn't human or if Kemmy doesn't exist
        if not kemmy then
            return
        end

        if not kemmy:is_human() then
            if cm:is_new_game() then
                cm:kill_all_armies_for_faction(kemmy)
            end

            return
        end

        if cm:is_new_game() then
            -- kill vanilla kemmy
            local vanilla = cm:get_faction("wh2_dlc11_vmp_the_barrow_legion")
            cm:kill_all_armies_for_faction(vanilla)
        end

        liche_init_listeners()
        check_np_effects()

        -- UI stuff
        if cm:get_local_faction_name(true) == legion then
            CampaignUI.ClearSelection()
            
            disable_tech_notification()
            kill_blood_kisses_and_tech()
            set_hunters_panel()
            add_pr_uic()

            cm:repeat_callback(function()
                check_settlements_on_map()
            end, 0.1, "kemmler_check_map")
        else
            hide_kemmler_hunter_panel()
        end
    end
)