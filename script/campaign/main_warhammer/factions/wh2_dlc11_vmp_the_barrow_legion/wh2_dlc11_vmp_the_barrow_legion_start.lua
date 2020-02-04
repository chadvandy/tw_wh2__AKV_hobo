-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	FACTION SCRIPT
--
--	Custom script for this faction starts here. The should_load_first_turn is
--	queried to determine whether to load the startup script for the full-prelude
--	first turn or just the standard startup script.
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

-- KAILUA TYPES because I'm tired of the errors!
--# assume local_faction: string
--# assume faction_new_sp_game_startup: function()
--# assume faction_each_sp_game_startup: function()
--# assume faction_new_mp_game_startup: function()
--# assume faction_each_mp_game_startup: function()
--# assume start_faction: function()
--# assume cutscene_intro_play: function()
--# assume cutscene_intro_skipped: function(advice_to_play: vector<string>)
--# assume show_benchmark_camera_pan_if_required: function(function())
--# assume cutscene_prebattle: function()


local debug = false

-- should play all advice (prevent things not happening because advice has played previously)
--cm:set_should_play_all_advice(true);


-- include the intro, prelude and quest chain scripts
cm:load_global_script(local_faction .. "_prelude");

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	FACTION SCRIPT
--
--	This script sets up the default start camera (for a multiplayer game) and
--	the intro cutscene/objective for a playable faction. The filename for this
--	script must match the name of the faction.
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
out("campaign script loaded for " .. local_faction);

local cam_start_x = 270.0
local cam_start_y = 368.9
local cam_start_d = 13.6
local cam_start_b = -2.5
local cam_start_h = 10.3

-------------------------------------------------------
--	Faction Start declaration/config
--	This object decides what to do when the faction
--	is initialised - do we play the cutscene, do we
--	position the camera at the start, or do we do
--	nothing, stuff like that.
--
--	Comment out the line adding the intro cutscene
--	to not play it (not ready for playtesting etc.)
-------------------------------------------------------


fs_player = faction_start:new(local_faction, cam_start_x, cam_start_y, cam_start_d, cam_start_b, cam_start_h);
-- singleplayer initialisation
fs_player:register_new_sp_game_callback(function() faction_new_sp_game_startup() end);
fs_player:register_each_sp_game_callback(function() faction_each_sp_game_startup() end);

-- multiplayer initialisation
fs_player:register_new_mp_game_callback(function() faction_new_mp_game_startup() end);
fs_player:register_each_mp_game_callback(function() faction_each_mp_game_startup() end);

if effect.tweaker_value("DISABLE_PRELUDE_CAMPAIGN_SCRIPTS") ~= "0" then
	out("Tweaker DISABLE_PRELUDE_CAMPAIGN_SCRIPTS is set so not running any prelude scripts");
else
	fs_player:register_intro_cutscene_callback(						-- comment out to not have intro cutscene
		function()
			show_benchmark_camera_pan_if_required(
				function()
					cutscene_prebattle();
				end
			);
		end
	);
end;

-------------------------------------------------------
--	This gets called each time the script restarts,
--	this could be at the start of a new game or
--	loading from a save-game (including coming back
--	from a campaign battle). Don't tamper with it.
-------------------------------------------------------
--v function(should_show_cutscene: boolean)
function start_game_for_faction(should_show_cutscene)
	out("start_game_for_faction() called");
	
	-- starts the playable faction script
	fs_player:start(should_show_cutscene);
end;

-------------------------------------------------------
--	This gets called only once - at the start of a 
--	new game. Initialise new game stuff for this 
--	faction here
-------------------------------------------------------

function faction_new_sp_game_startup()
	out("faction_new_sp_game_startup() called");
	
	-- used for interventions
    cm:start_faction_region_change_monitor(local_faction);
    
    if debug then
        --# assume cutscene_postbattle: function()
        cutscene_postbattle()
        return
    end
end;

function faction_new_mp_game_startup()
	out("faction_new_mp_game_startup() called");
end;

-------------------------------------------------------
--	This gets called any time the game loads in,
--	singleplayer including from a save game and 
--	from a campaign battle. Put stuff that needs
--	re-initialising each campaign load in here
-------------------------------------------------------

function faction_each_sp_game_startup()
	out("faction_each_sp_game_startup() called");
	
	-- put stuff here to be initialised each time a singleplayer game loads
	
	-- should we disable further advice
	if cm:get_saved_value("advice_is_disabled") then
		cm:set_advice_enabled(false);
    end;

    if not cm:get_saved_value("lichemaster_first_turn_completed") and cm:get_saved_value("lichemaster_intro_battle_completed") then
        --# assume cutscene_postbattle: function()
        cutscene_postbattle() 
    end
        
    ---------------------
    -- REMOVE THIS LATER ON AFTER FINISHING DEBUG
    --[[cm:repeat_callback(
        function()
            local x, y, d, b, h = cm:get_camera_position()
            out("X: "..x)
            out("Y: "..y)
            out("D: "..d)
            out("B: "..b)
            out("H: "..h)
        end,
        0.5,
        "testing_camera_debug"
    )]]
    ---------------------

end;

function faction_each_mp_game_startup()
	out("faction_each_mp_game_startup() called");
	
	-- put stuff here to be initialised each time a multiplayer game loads	
end;

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	INTRO CUTSCENE
--
--	This function declares and configures the cutscene,
--	loads it with actions and plays it.
--	Customise it to suit.
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

function setup_battle()
    cm:set_saved_value("lichemaster_intro_battle_completed", true)

    --[[cm:win_next_autoresolve_battle("wh2_dlc11_vmp_the_barrow_legion")

    cm:modify_next_autoresolve_battle(
        1,
        0,
        1,
        5,
        true
    )]]

    --# assume remove_battle_script_override: function()
    remove_battle_script_override()

    cm:add_custom_battlefield(
        "lichemaster_intro_battle",
        0,
        0,
        5000,
        false,
        "",
        "",
        "script/battle/lichemaster/intro_battle/battle.xml",
        0,
        true,
        true,
        false
    )

end

function cutscene_prebattle_prep()
    cm:transfer_region_to_faction("wh_main_northern_grey_mountains_blackstone_post", "wh_main_dwf_karak_ziflin")
    local faction = cm:get_faction("wh2_dlc11_vmp_the_barrow_legion")

    local kemmler_start_x = 423
    local kemmler_start_y = 429

    local kemmler = faction:faction_leader()
    local kemmler_cqi = kemmler:command_queue_index()

    --# assume kemmler_cqi: number
    cm:teleport_to("character_cqi:"..kemmler_cqi, kemmler_start_x, kemmler_start_y, false)
end

function cutscene_prebattle()
    out("cutscene_prebattle() called")

    cutscene_prebattle_prep()
    

    local cam_start_x = 270.0
    local cam_start_y = 368.9
    local cam_start_d = 13.6
    local cam_start_b = -2.5
    local cam_start_h = 10.3

    local cam_mid_x = 285.3
    local cam_mid_y = 334.5
    local cam_mid_d = 15.6
    local cam_mid_b = 0.3
    local cam_mid_h = 7.1

    local cam_end_x = 288.5
    local cam_end_y = 338.9
    local cam_end_d = 12.4
    local cam_end_b = 0.6
    local cam_end_h = 4.3
    
    local cutscene_prebattle = campaign_cutscene:new(
        "lichemaster_prebattle",
        25,
        function() 
            setup_battle() 
        end
    )

    cutscene_prebattle:set_skippable(false)
    --cutscene_prebattle:set_skip_camera(cam_end_x, cam_end_y, cam_end_d, cam_end_b, cam_end_h);
    cutscene_prebattle:set_disable_settlement_labels(true)
    cutscene_prebattle:set_dismiss_advice_on_end(false)

    cutscene_prebattle:action(
        function()
            cm:show_shroud(true)
            cm:set_camera_position(cam_start_x, cam_start_y, cam_start_d, cam_start_b, cam_start_h)
        end,
        0
    )

    cutscene_prebattle:action(
        function()
            cm:scroll_camera_from_current(true, 14, {cam_mid_x, cam_mid_y, cam_mid_d, cam_mid_b, cam_mid_h})
            cm:show_advice("lichemaster_intro_1")
        end,
        1
    )

    cutscene_prebattle:action(
        function()
            cm:scroll_camera_from_current(true, 8, {cam_end_x, cam_end_y, cam_end_d, cam_end_b, cam_end_h})
            cm:show_advice("lichemaster_intro_2")
        end,
        15.1
    )

    cutscene_prebattle:action(
        function()
            cutscene_prebattle:set_disable_settlement_labels(true)
        end,
        24.5
    )

    cutscene_prebattle:start()
end

-- due to a likely startpos-induced limitation, we have to "refresh" the PR value to make the bundle trigger on turn one.
local function fix_necropower()
    cm:faction_add_pooled_resource("wh2_dlc11_vmp_the_barrow_legion", "necropower", "bribes", 1)
    cm:faction_add_pooled_resource("wh2_dlc11_vmp_the_barrow_legion", "necropower", "bribes", -1)
end

local function setup_kemmler()
    local lm = _G._LICHEMANAGER
    local faction = cm:get_faction("wh2_dlc11_vmp_the_barrow_legion")

    local kemmler = faction:faction_leader()
    local kemmlerCQI = kemmler:command_queue_index()

    cm:disable_event_feed_events(true, "wh_event_category_character", "", "")
    cm:disable_event_feed_events(true, "", "", "character_trait_lost")
    cm:disable_event_feed_events(true, "", "", "character_ancillary_lost")
    cm:disable_event_feed_events(true, "", "", "character_wounded")

    do
        cm:force_add_trait("character_cqi:" .. kemmlerCQI, "AK_kemmler_wound_reduction", false)
    end

    cm:transfer_region_to_faction("wh_main_northern_grey_mountains_blackstone_post", "wh2_dlc11_vmp_the_barrow_legion")

    cm:kill_character_and_commanded_unit("character_cqi:"..kemmlerCQI, true, true)
    
    cm:callback(function()
        local kemmy_cqi = lm:get_real_cqi()

        cm:stop_character_convalescing(kemmy_cqi)

        local starting_army = {
            faction_key = "wh2_dlc11_vmp_the_barrow_legion",
            army_list = "AK_hobo_skeleton_2h,AK_hobo_skeleton_spears,AK_hobo_skeleton_spears,AK_hobo_hexwr,AK_hobo_barrow_guardians,AK_hobo_glooms",
            region = "wh_main_forest_of_arden_gisoreux",
            x = 423,
            y = 429,
            starting_buildings = {"AK_hobo_ruination_1", "AK_hobo_recr1_1"}
        }

        local first_turn_army = starting_army.army_list

        if cm:get_saved_value("Faction_Unlocker") then
            first_turn_army = "AK_hobo_skeleton_2h,AK_hobo_skeleton_spears,AK_hobo_skeleton_spears,AK_hobo_hexwr,AK_hobo_barrow_guardians,AK_hobo_glooms,AK_hobo_skeleton_spears,AK_hobo_skeleton_spears,AK_hobo_cairn"
        end

        --# assume kemmy_cqi: number
        cm:create_force_with_existing_general(
            "character_cqi:"..kemmy_cqi,
            starting_army.faction_key,
            first_turn_army,
            starting_army.region,
            starting_army.x,
            starting_army.y,
            function(cqi)

            end
        )

        cm:force_remove_trait("character_cqi:"..kemmy_cqi, "AK_kemmler_wound_reduction")
        cm:force_remove_ancillary("character_cqi:"..kemmy_cqi, "wh2_dlc11_anc_follower_vmp_the_ravenous_dead", false)
        --# assume kemmy_cqi: CA_CQI
        cm:apply_effect_bundle_to_characters_force("lichemaster_turn_one_growth", kemmy_cqi, 1, false)

        cm:callback(function()
            cm:disable_event_feed_events(false, "wh_event_category_character", "", "")
            cm:disable_event_feed_events(false, "", "", "character_trait_lost")
            cm:disable_event_feed_events(false, "", "", "character_ancillary_lost")
            cm:disable_event_feed_events(false, "", "", "character_wounded") 
        end, 1)
    end, 0.5)
end

local function cutscene_postbattle_prep()
    fix_necropower()
    setup_kemmler()
    cm:callback(function()
		CampaignUI.ClearSelection()
    end, 1)
    cm:set_saved_value("lichemaster_first_turn_completed", true)
end

function cutscene_postbattle()
    cutscene_postbattle_prep()

    local cam_start_x = 282.9
    local cam_start_y = 342.4
    local cam_start_d = 15.2
    local cam_start_b = -0.4
    local cam_start_h = 4.0

    cm:callback(function()

        local cutscene_postbattle = campaign_cutscene:new(
            "lichemaster_postbattle",
            6,
            function()
                lichemaster_postbattle_setup()
            end
        )

        cutscene_postbattle:set_skippable(false)
        cutscene_postbattle:set_disable_settlement_labels(false)
        cutscene_postbattle:set_dismiss_advice_on_end(false)
        
        cutscene_postbattle:action(
            function()
                cm:show_shroud(true)
                cm:set_camera_position(282.9, 342.4, 15.2, -0.4, 4.0)

                local lm = _G._LICHEMANAGER
                -- first things first, get rid of the ownership of the Blackstone Post!
                cm:set_region_abandoned("wh_main_northern_grey_mountains_blackstone_post")
                -- needed because the above command doesn't trigger any events
                lm:set_ruin("wh_main_northern_grey_mountains_blackstone_post")
            end,
            0
        )

        cutscene_postbattle:action(
            function()
                cm:show_advice("lichemaster_postbattle_1")
                cm:scroll_camera_from_current(true, 5, {280.1, 338.9, 16.3, 0.5, 8.2})
            end,
            1
        )

        cutscene_postbattle:start()

    end, 0.6)   

end

-------------------------------------------------------
--	This gets called after the intro cutscene ends,
--	Kick off any missions or similar scripts here
-------------------------------------------------------

function start_faction()
	out("start_faction() called");
	
	-- show advisor progress button
	cm:modify_advice(true);
	
	start_the_barrow_legion_prelude();
	
	if cm:is_multiplayer() == false then
        -- show_how_to_play_event(local_faction);
    end
    
end