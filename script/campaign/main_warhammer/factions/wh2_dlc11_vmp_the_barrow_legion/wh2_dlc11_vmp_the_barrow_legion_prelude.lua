
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	VAMPIRE COUNTS PRELUDE SCRIPT
--
-----------------------------------------------------------------------------------

-- Kailua Types because I'm tired of the errors!
--# assume chapter_one_mission: CA_CHAPTER_MISSION
--# assume local_faction: string
--# assume in_vampires_racial_advice: CA_INTERVENTION
--# assume in_vampires_raising_dead_advice: CA_INTERVENTION
--# assume BOOL_INTERVENTIONS_DEBUG: boolean
--# assume start_global_interventions: function()
--# assume trigger_in_vampires_racial_advice: function()
--# assume trigger_in_vampires_raising_dead_advice: function()


--v function(advice_already_played: boolean?)
function start_the_barrow_legion_prelude(advice_already_played)	
	-- chapter missions
	chapter_one_mission:manual_start();
	
	-- start intervention managers
	start_global_interventions();
end;

-----------------------------------------------------------------------------------
---------------------------------------------------------------
--
--	Chapter Missions
--
---------------------------------------------------------------

if not cm:is_multiplayer() then
	chapter_one_mission = chapter_mission:new(
		1, 
		local_faction, 
		"wh2_dlc11_objective_kemmler_01", 
		"war.camp.prelude.vmp.chapter_one.001", 
		{
			"war.camp.advice.victory_conditions.info_001",
			"war.camp.advice.victory_conditions.info_002",
			"war.camp.advice.victory_conditions.info_003"
		}
	);
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh2_dlc11_objective_kemmler_02", "war.camp.advice.chapter_two.001");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh2_dlc11_objective_kemmler_03", "war.camp.advice.chapter_three.001");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh2_dlc11_objective_kemmler_04", "war.camp.advice.chapter_four.001");
	chapter_five_mission = chapter_mission:new(5, local_faction, "wh2_dlc11_objective_kemmler_05", "war.camp.advice.chapter_five.001");
	chapter_six_mission = chapter_mission:new(6, local_faction, "wh_main_objective_vampire_06", "war.camp.advice.chapter_six.001");
	
	-- start the first chapter mission when the player captures a settlement (and it hasn't been started before)
	if not chapter_one_mission:has_been_issued() then
		core:add_listener(
			"chapter_one_trigger_listener",
			"ScriptEventPlayerCaptureSettlement", 
			true,
			function()
				chapter_one_mission:manual_start();
			end,
			false
		);
	end;
end;

---------------------------------------------------------------
--
--	Start all vampire counts interventions
--
---------------------------------------------------------------

function start_vampire_counts_interventions()
	
	--out.interventions("* start_vampire_counts_interventions() called");
	--out("* start_vampire_counts_interventions() called");
	
	in_vampires_racial_advice:start();
	in_vampires_raising_dead_advice:start();
	
	-- global
	start_global_interventions();
end;

---------------------------------------------------------------
--
--	Vampires racial advice
--
---------------------------------------------------------------

-- intervention declaration
in_vampires_racial_advice = intervention:new(
	"in_vampires_racial_advice", 												-- string name
	50, 																		-- cost
	function() trigger_in_vampires_racial_advice() end,						-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_vampires_racial_advice:set_min_advice_level(1);
in_vampires_racial_advice:add_precondition_unvisited_page("vampires");
in_vampires_racial_advice:add_advice_key_precondition("war.camp.prelude.vmp.vampires.001");
in_vampires_racial_advice:set_min_turn(2);

in_vampires_racial_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		return true;
	end
);


function trigger_in_vampires_racial_advice()
	in_vampires_racial_advice:play_advice_for_intervention(
		-- Your kind are a nightmare made flesh, Sire. Yoke the power of the dead and you shall be unstoppable.
		"war.camp.prelude.vmp.vampires.001", 
		{
			"war.camp.advice.vampires.info_001",
			"war.camp.advice.vampires.info_002",
			"war.camp.advice.vampires.info_003"
		}
	)
end;

---------------------------------------------------------------
--
--	Raising Dead advice
--
---------------------------------------------------------------

-- intervention declaration
in_vampires_raising_dead_advice = intervention:new(
	"in_vampires_raising_dead_advice", 											-- string name
	60, 																		-- cost
	function() trigger_in_vampires_raising_dead_advice() end,					-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_vampires_raising_dead_advice:set_min_advice_level(1);
in_vampires_raising_dead_advice:add_advice_key_precondition("war.camp.prelude.vmp.raising_dead.001");
in_vampires_raising_dead_advice:add_precondition_unvisited_page("raising_dead");
in_vampires_raising_dead_advice:give_priority_to_intervention("in_vampires_racial_advice");
in_vampires_raising_dead_advice:set_min_turn(4);

in_vampires_raising_dead_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		return true;
	end
);


function trigger_in_vampires_raising_dead_advice()
	in_vampires_raising_dead_advice:play_advice_for_intervention(
		-- The dead may be summoned to your will, my Lord. Rapidly augment your forces by raising the slain to your banner.
		"war.camp.prelude.vmp.raising_dead.001", 
		{
			"war.camp.advice.raising_dead.info_001",
			"war.camp.advice.raising_dead.info_002",
			"war.camp.advice.raising_dead.info_003"
		}
	)
end;

--[[
	TODO
		- replace the vanilla Chapter Objectives - capturing settlements? pah.
		- go through and disable antiquated advice
]]