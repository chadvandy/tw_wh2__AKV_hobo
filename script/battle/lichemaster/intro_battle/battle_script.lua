load_script_libraries()

bm = battle_manager:new(empire_battle:new())


local gc = generated_cutscene:new(true, true)
local cam = bm:camera()

core:svr_save_bool("JacsenSurvived", false)

jacsen_survived = true --: boolean

--# assume end_deployment_phase: function()

gb = generated_battle:new(
    false,
    false,
    false,
    function() end_deployment_phase() end,
    false -- debug mode
)

bm:register_phase_change_callback(
    "Deployment",
    function()
        cam:fade(true, 1)

        bm:callback(function()

            local battle_uic = find_uicomponent(core:get_ui_root(), "battle")
            if battle_uic then
                battle_uic:SetVisible(false)
            end

            local unit_id_holder_uic = find_uicomponent(core:get_ui_root(), "unit_id_holder")
            if unit_id_holder_uic then
                unit_id_holder_uic:SetVisible(false)
            end

            local uic_reinforcements_parent = find_uicomponent(core:get_ui_root(), "layout", "radar_holder", "reinforcements_parent")
            if uic_reinforcements_parent then
                uic_reinforcements_parent:SetVisible(false);
            end

            local start_deployment = find_uicomponent(core:get_ui_root(), "winds_of_magic", "pre_deployment_parent", "button_start_deployment")
            start_deployment:SimulateLClick()
            
            
            -- remotely necessary? TODO
                local start_battle = find_uicomponent(core:get_ui_root(), "finish_deployment", "deployment_end_sp", "button_battle_start")

            core:add_listener(
                "deployment_begun",
                "ComponentLClickUp",
                function(context)
                    return context.string = "button_battle_start"
                end,
                function(context)
                    bm:callback(function() -- TODO find these UIC's anew within this callback
                        if is_uicomponent(battle_uic) then
                            battle_uic:SetVisible(true)
                        end
                        
                        if is_uicomponent(unit_id_holder_uic) then
                            unit_id_holder_uic:SetVisible(true)
                        end
                    end, 0.5) -- TODO verify that bm callbacks take seconds and not milliseconds
                end,
                false
            )
        end, 1)
    end
)



gb:add_listener(
    "battle_started",
    function()
        --bm:camera():fade(true, 1)
        local uic_reinforcements_parent = find_uicomponent(core:get_ui_root(), "layout", "radar_holder", "reinforcements_parent")
        if uic_reinforcements_parent then
            uic_reinforcements_parent:SetVisible(false);
        end
    end
)

gb:add_listener(
    "jacsen_dead",
    function()
        jacsen_survived = false
    end
)

-- check if jacsen died if victory; default to false if defeat
bm:register_results_callbacks(
    function() core:svr_save_bool("JacsenSurvived", jacsen_survived) end,
    function() core:svr_save_bool("JacsenSurvived", false) end
)


function end_deployment_phase()
    cam:fade(false, 1)

    cam:move_to(v(91.8, 172.5, -470.9), v(79.7, 148.8, -575.1), 0, false, 0)
    cam:move_to(v(-172.7, 178.7, -367.5), v(-113.8, 131.6, -290.8), 2, false, 0)

    gb.sm:trigger_message("kill_kill")

    ---- TODO grab this and throw it in the Vandy Lib, using some UI
    --[[bm:repeat_callback(function()
        bm:cache_camera()
        local pos = bm:get_cached_camera_pos()
        local targ = bm:get_cached_camera_targ()

        local pos_y = pos:get_y();
        local pos_x = pos:get_x();
        local pos_z = pos:get_z();
        
        local targ_y = targ:get_y();
        local targ_x = targ:get_x();
        local targ_z = targ:get_z();

        pos_out = "POS: ("..tostring(pos_x).."\n"..tostring(pos_y).."\n"..tostring(pos_z)..")"
        targ_out = "TARG: ("..tostring(targ_x).."\n"..tostring(targ_y).."\n"..tostring(targ_z)..")"
        
        out(pos_out)
        out(targ_out)
    end,
    200,
    "debug_camera_tracker")]]

end


---- ARMY SETUP ----


ga_kemmler = gb:get_army(gb:get_player_alliance_num(), 1, "kemmler")                    -- PLAYER ARMY
ga_kemmler_kemmler = gb:get_army(gb:get_player_alliance_num(), 1, "kemmler_kemmler")    -- KEMMLER PROPER
ga_kemmler_krell = gb:get_army(gb:get_player_alliance_num(), 1, "kemmler_krell")        -- KRELL PROPER
ga_jacsen = gb:get_army(gb:get_player_alliance_num(), 1, "jacsen")                      -- PLAYER REINFORCEMENTS
ga_dwarf_1 = gb:get_army(gb:get_non_player_alliance_num(), 1, "dwarf_1")                -- ENEMY ARMY
ga_dwarf_2 = gb:get_army(gb:get_non_player_alliance_num(), 1, "dwarf_2")                -- ENEMY REINFORCEMENTS

---- OBJECTIVES ----

ga_kemmler:message_on_victory("player_wins")
ga_kemmler:message_on_defeat("jacsen_dead")

gb:set_objective_on_message("battle_started", "lichemaster_intro_battle_starting_objective");
gb:complete_objective_on_message("first_army_killed", "lichemaster_intro_battle_starting_objective");

gb:set_objective_on_message("dwarf_reinforcements", "lichemaster_intro_battle_secondary_objective");
gb:complete_objective_on_message("second_army_killed", "lichemaster_intro_battle_secondary_objective");

gb:set_objective_on_message("battle_started", "lichemaster_intro_battle_stay_alive")
gb:complete_objective_on_message("player_wins", "lichemaster_intro_battle_stay_alive")

---- HINTS ----
gb:queue_help_on_message("dwarf_reinforcements", "lichemaster_intro_battle_enemy_reinforcements", 8000, 2000, 500)

gb:queue_help_on_message("help_me_jacsen", "lichemaster_intro_battle_ally_reinforcements", 8000, 2000, 500);


---- AI ORDERS ----

ga_kemmler_kemmler:message_on_rout_proportion("kemmler_killed", 1)
ga_kemmler_krell:message_on_rout_proportion("krell_killed", 1)

ga_dwarf_1:force_victory_on_message("kemmler_killed", 15000)
ga_dwarf_1:force_victory_on_message("krell_killed", 15000)

ga_kemmler:teleport_to_start_location_offset_on_message("battle_started", 50, 350)
ga_kemmler_kemmler:teleport_to_start_location_offset_on_message("battle_started", 50, 350)
ga_kemmler_krell:teleport_to_start_location_offset_on_message("battle_started", 50, 350)
ga_kemmler:release_on_message("battle_started")
ga_kemmler_kemmler:release_on_message("battle_started")
ga_kemmler_krell:release_on_message("battle_started")

ga_dwarf_1:teleport_to_start_location_offset_on_message("battle_started", 0, 200)
ga_dwarf_1:release_on_message("battle_started")

ga_dwarf_1:attack_on_message("kill_kill", 500)
ga_dwarf_1:attack_on_message("kill_kill", 1000)
ga_dwarf_1:attack_on_message("kill_kill", 20000)
ga_dwarf_1:attack_on_message("kill_kill", 30000)

ga_dwarf_1:message_on_casualties("dwarf_reinforcements", 0.2)
ga_dwarf_1:message_on_casualties("first_army_killed", 1.0)

ga_dwarf_2:message_on_casualties("second_army_killed", 1.0)

ga_dwarf_2:reinforce_on_message("dwarf_reinforcements")
ga_dwarf_2:attack_on_message("dwarf_reinforcements", 20000);
ga_dwarf_2:attack_on_message("dwarf_reinforcements", 30000);
ga_dwarf_2:attack_on_message("dwarf_reinforcements", 40000);

gb.sm:add_listener(
    "dwarf_reinforcements",
    function()
        -- in 90 seconds, deploy the Jacsen army
        bm:callback(
            function()
                gb.sm:trigger_message("help_me_jacsen")
            end,
            90000
        )
    end
)

--ga_dwarf_2:message_on_proximity_to_enemy("help_me_jacsen", 1)

--ga_kemmler:message_on_casualties("help_me_jacsen", 0.4)

ga_jacsen:reinforce_on_message("help_me_jacsen")
ga_jacsen:attack_on_message("help_me_jacsen", 20000);
ga_jacsen:attack_on_message("help_me_jacsen", 30000);
ga_jacsen:attack_on_message("help_me_jacsen", 40000);

ga_jacsen:message_on_commander_death("jacsen_dead")
ga_jacsen:message_on_defeat("jacsen_dead")