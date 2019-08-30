local LOG = require("script/lichemaster/log") --# assume LOG: LICHE_LOG

local names = require("script/lichemaster/tables/legionNames")

--[[
local liche_manager = {
    _lives = 0,
    _currentPower = 0,
    _ruins = {},
    _faction_key = "wh2_dlc11_vmp_the_barrow_legion"
} --# assume liche_manager: LICHE_MANAGER]]

local liche_manager = {} --# assume liche_manager: LICHE_MANAGER

-----------------------------------------
----------------- LOGS! -----------------
-----------------------------------------

--v method(text: any)
function liche_manager:log(text)
    LOG.out(tostring(text))
end

--v method(text: any)
function liche_manager:error(text)
    LOG.error(tostring(text))
end

-----------------------------------------
--------------- CREATION ----------------
-----------------------------------------

--v function() --> LICHE_MANAGER
function liche_manager.init()
    --# assume self: LICHE_MANAGER
    local self = {}
    setmetatable(self, {__index = liche_manager})
    --# assume self: LICHE_MANAGER
    --self._UI = UI
    self._LOG = LOG
    self._UTILITY = require("script/lichemaster/ui/utility")

    --[[ REGIMENTS ]]
    self._regiments = {}
    self._selected_legion = "" --: string
    
    -- [[ LORDS ]]
    self._can_recruit_lord = {
        ["AK_hobo_draesca"] = false,
        ["AK_hobo_priestess"] = false,
        ["AK_hobo_nameless"] = false
    }
    self._is_draesca_unlocked = false
    self._is_priestess_unlocked = false
    self._is_nameless_unlocked = false

    --[[ RUINS ]]
    self._ruins = {}
    self._num_ruins_defiled = 0 --: number
    self._num_razed_settlements = 0 --: number
    self._defile_debug = ""

    --[[ MINOR INFOS ]]
    self._hero_spawn_rank_increase = 0 --: number
    self._turn_to_spawn = 0 --: number
    self._currentPower = 0

    --[[ WOUNDED KEMMY DEETS ]]
    self._last_turn_lives_changed = 0 --: number
    self._remaining_max_lives = 0 --: number
    self._unit_list = "" --: string

    -- create the log file and beginning text
    self._LOG.init()

    _G._LICHEMANAGER = self
    return self
end

-----------------------------------------
------------- BASIC DEETS ---------------
-----------------------------------------

liche_manager._faction_key = "wh2_dlc11_vmp_the_barrow_legion"

liche_manager._regionNames = require("script/lichemaster/tables/regionNames")
liche_manager._units = require("script/lichemaster/tables/units")

liche_manager._forenames = names[1]
liche_manager._family_names = names[2]

------------------------------------
------------- DEBUGGING ------------
------------------------------------

--v method(effect_option: string) 
function liche_manager:set_defile_debug(effect_option)
    --# assume self: LICHE_MANAGER
    local options = {
        --"effectBundle",
        "spawnAgent",
        "spawnRoR",
        "item",
        "enemy"
    }--: vector<string>

    for i = 1, #options do
        local option = options[i]
        if effect_option == option then
            self._defile_debug = effect_option
            return
        end
    end

    self:error("set_defile_debug() called, but the argument passed isn't a defile option!")
    self:error("Valid options are: 'spawnAgent', 'spawnRoR', 'item', and 'enemy'")
end

--v method()
function liche_manager:reset_defile_debug()
    --# assume self: LICHE_MANAGER
    self._defile_debug = ""
end

-------------------------------------
-------------- HELPERS --------------
-------------------------------------

----
---- Functions that make life easier later on
----

--v method() --> string
function liche_manager:get_unit_list()
    --# assume self: LICHE_MANAGER
    return self._unit_list
end

--v method() --> number
function liche_manager:get_turn_to_spawn()
    --# assume self: LICHE_MANAGER
    return self._turn_to_spawn
end

--v method(turn: number)
function liche_manager:set_turn_to_spawn(turn)
    --# assume self: LICHE_MANAGER
    self._turn_to_spawn = turn
end

--v method() --> CA_CQI
function liche_manager:get_character_selected_cqi()
    --# assume self: LICHE_MANAGER
    return self._characterSelected
end

--v method(cqi: CA_CQI)
function liche_manager:set_character_selected_cqi(cqi)
    --# assume self: LICHE_MANAGER
    self._characterSelected = cqi
end

--v method() --> string
function liche_manager:get_faction_key()
    --# assume self: LICHE_MANAGER
    return self._faction_key
end

--v method() --> map<string, string>
function liche_manager:get_region_names()
    --# assume self: LICHE_MANAGER
    return self._regionNames
end

---- Check if lord is still locked
--v method(subtype: string) --> boolean
function liche_manager:is_lord_unlocked(subtype)
    --# assume self: LICHE_MANAGER
    if subtype == "AK_hobo_nameless" then
        return self._is_nameless_unlocked
    elseif subtype == "AK_hobo_draesca" then
        return self._is_draesca_unlocked
    elseif subtype == "AK_hobo_priestess" then
        return self._is_priestess_unlocked
    end
    return false
end

---- Quick shorthand for checking subtypes of generals
--v method(subtype: string) --> boolean
function liche_manager:is_subtype_key_legendary(subtype)
    --# assume self: LICHE_MANAGER
    if subtype == "AK_hobo_nameless" or subtype == "AK_hobo_draesca" or subtype == "AK_hobo_priestess" then
        return true
    else
        return false
    end
end

---- Quick shorthand for checking subtypes of agents
--v method(subtype: string) --> boolean
function liche_manager:is_subtype_key_agent(subtype)
    --# assume self: LICHE_MANAGER
    if subtype == "AK_hobo_barrow_king" or subtype == "AK_hobo_druid_shadow" or subtype == "AK_hobo_druid_death" or subtype == "AK_hobo_druid_heavens" then
        return true
    else
        return false
    end
end

---- Grab the number of legendary lords in Legion, used to determine the level the next lord will spawn at
--v method() --> number 
function liche_manager:get_num_legendary_lords()
    --# assume self: LICHE_MANAGER

    local faction = cm:get_faction(self._faction_key)
    local char_list = faction:character_list()

    local total = 0

    for i = 0, char_list:num_items() - 1 do
        local char = char_list:item_at(i)
        if self:is_subtype_key_legendary(char:character_subtype_key()) then
            total = total + 1
        end
    end
    
    return total
end

---- Grab the total value of NP
--v method() --> number
function liche_manager:get_necropower()
    --# assume self: LICHE_MANAGER
    local faction = cm:get_faction(self._faction_key)
    local pr = faction:pooled_resource("necropower")
    return pr:value()
end

---- Internal value that determines the rank that heroes spawn at
--v method() --> number
function liche_manager:get_hero_spawn_rank_increase()
    --# assume self: LICHE_MANAGER
    return self._hero_spawn_rank_increase
end

--v method(increase: number)
function liche_manager:increase_hero_spawn_rank(increase)
    --# assume self: LICHE_MANAGER
    self._hero_spawn_rank_increase = self._hero_spawn_rank_increase + increase
end

--v method()
function liche_manager:increment_num_razed_settlements()
    --# assume self: LICHE_MANAGER
    self._num_razed_settlements = self._num_razed_settlements + 1
end

--v method() --> number
function liche_manager:get_num_razed_settlements()
    --# assume self: LICHE_MANAGER
    return self._num_razed_settlements
end

-- TODO make this easier to edit, read subtypes.lua fam
---- Apply ancillaries to LL's upon spawn
--v method(subtype: string, char_str: string)
function liche_manager:add_ancillaries_to_lord(subtype, char_str)
    --# assume self: LICHE_MANAGER
    if subtype == "AK_hobo_draesca" then
        cm:force_add_and_equip_ancillary(char_str, "AK_hobo_draesca_helmet")
    elseif subtype == "AK_hobo_priestess" then
        cm:force_add_and_equip_ancillary(char_str, "AK_hobo_priestess_trickster")
        cm:force_add_and_equip_ancillary(char_str, "AK_hobo_priestess_charms")
    end
end

---- Check the list of landmarks against the supplied region
--v method(region_name: string) --> boolean 
function liche_manager:is_landmark_region(region_name)
    local landmarks = {
        ["wh2_main_albion_albion"] = true,
        ["wh2_main_iron_mountains_altar_of_ultimate_darkness"] = true,
        ["wh_main_reikland_altdorf"] = true,
        ["wh_main_couronne_et_languille_couronne"] = true,
        ["wh_main_eastern_sylvania_castle_drakenhof"] = true,
        ["wh_main_northern_grey_mountains_blackstone_post"] = true,
        ["wh_main_southern_badlands_galbaraz"] = true,
        ["wh2_main_the_chill_road_ghrond"] = true,
        ["wh2_main_devils_backbone_lahmia"] = true,
        ["wh2_main_great_mortis_delta_black_pyramid_of_nagash"]  = true
    }--:map<string, boolean>

    if landmarks[region_name] then
        return true
    end
    return false
end

---- used to determine if a region is occupiable.
---- needs to be a landmark, and the player needs over 60 NP
--v method(region_name: string) --> boolean
function liche_manager:can_occupy_region(region_name)
    --# assume self: LICHE_MANAGER
    local is_landmark = self:is_landmark_region(region_name)
    if is_landmark then
        local value = self:get_necropower()
        if value >= 60 then
            return true
        end
    end
    return false
end

-- TODO this list should be outsourced to a secondary Lua file, for Cataph's sake
---- Simple and quick check to see if a unit is in the Barrow unit set.
--v method(unit_key: string) --> boolean
function liche_manager:is_unit_barrow(unit_key)
    local barrow_units = {
        ["AK_hobo_barrow_guardians"] = true,
        ["AK_hobo_barrow_guardians_dual"] = true,
        ["AK_hobo_barrow_guardians_halb"] = true,
        ["AK_hobo_simulacra"] = true,
        ["AK_hobo_embalmed"] = true,
        ["AK_hobo_glooms"] = true,
        ["AK_hobo_ghost"] = true,
        ["AK_hobo_stalker"] = true,
        ["AK_hobo_ror_caged"] = true,
        ["AK_hobo_ror_storm"] = true,
        ["AK_hobo_ror_beast"] = true,
        ["AK_hobo_ror_skulls"] = true,
        ["CTT_hobo_glooms"] = true
    }--:map<string, boolean>

    return not not barrow_units[unit_key]

end

-----------------------------------------
--------------   RUINS!   ---------------
-----------------------------------------

---- Grab the number of turns the ruin has been ruined.
--v method(ruin: string) --> number 
function liche_manager:calculate_turns_ruined(ruin)
    --# assume self: LICHE_MANAGER
    local region = cm:get_region(ruin)
    if self._ruins[region:name()] == nil or not region:is_abandoned() then
        self:error("calculate_turns_ruined() called, but the region supplied, ["..region:name().."], is not abandoned, or wasn't initially tracked! Returning zero turns.")
        return 0
    end

    local current_turn = cm:model():turn_number()
    local ruined_turn = self._ruins[ruin].turn
    local turns_ruined = current_turn - ruined_turn
    return turns_ruined
end

---- Method to grab the 'tier' of the Ruin, based on how many turns its been ruined. Affects the chances of the effect given.
--v method(region_name: string) --> number
function liche_manager:calculate_tier(region_name)
    --# assume self: LICHE_MANAGER

    local turns = self:calculate_turns_ruined(region_name)

    local tier = 0

    if turns >= 0 and turns <= 3 then
        tier = 1
    elseif turns <= 6 then
        tier = 2
    else
        tier = 3
    end
    self:log("RUIN TRACKER: Ruin Tier calculated at ["..tier.."].")
    return tier
end

-- TODO make these less fucked up
---- Grab the effect, based on the tier of the ruin and some randomized chances
--v method(ruin: string) --> string
function liche_manager:calculate_effect(ruin)
    --# assume self: LICHE_MANAGER
    local tier = self:calculate_tier(ruin)
    local effects = {
        --"effectBundle",
        "spawnAgent",
        "spawnRoR",
        "item",
        "enemy"
    } --:vector<string>

    local chance = cm:random_number(100, 1)
    local effect = "" --: string

    if tier == 1 then
        if chance <= 40 then 
            effect = effects[4] -- enemy
        elseif chance > 40 and chance <= 80 then 
            effect = effects[3] -- item
        elseif chance > 80 and chance <= 90 then 
            effect = effects[1] -- spawnAgent
        elseif chance > 90 then 
            effect = effects[2] -- spawnRoR
        end
    elseif tier == 2 then
        if chance <= 30 then 
            effect = effects[4] -- enemy
        elseif chance > 30 and chance <= 60 then 
            effect = effects[3] -- item
        elseif chance > 60 and chance <= 85 then 
            effect = effects[1] -- spawnAgent
        elseif chance > 85 then 
            effect = effects[2] -- spawnRoR
        end
    elseif tier == 3 then
        if chance <= 20 then 
            effect = effects[4] -- enemy
        elseif chance > 20 and chance <= 45 then 
            effect = effects[3] -- item
        elseif chance > 45 and chance <= 70 then 
            effect = effects[1] -- spawnAgent
        elseif chance > 70 then 
            effect = effects[2] -- spawnRoR
        end
    end

    if cm:model():turn_number() <= 15 and effect == "spawnRoR" then
        self:log("DEFILE BARROWS: Changing effect to 'item', too early for 'spawnRoR'")
        effect = "item"
    end


    if effect == "" then
        self:error("calculate_effect() called, but the supplied tier is not 1, 2, or 3! Returning a blank string.")
        return ""
    end
    self:log("DEFILE BARROWS: Effect calculated is ["..effect.."].")
    return effect
end

---- Apply some XP to the character which just defiled
--v method()
function liche_manager:apply_defile_xp()
    --# assume self: LICHE_MANAGER
    local cqi = self:get_character_selected_cqi()
    if not cqi then
        self:error("apply_defile_xp() called, but no character selected is found.")
        return
    end

    cm:apply_effect_bundle_to_characters_force("AK_hobo_barrow_force", cqi, 1, false)

    --# assume cqi: number
    self:log("DEFILE BARROW: Applying Defile XP effect bundle to character with CQI ["..cqi.."].")
end

---- Needed because of a bug currently in the software, which causes a "colonel" type agent to spawn whenever a modded unit is removed from an army
---- DO NOT LIKE
--v method()
function liche_manager:kill_colonel()
    --# assume self: LICHE_MANAGER
    local faction = cm:get_faction(self._faction_key)
    local char_list = faction:character_list()
    for i = 0, char_list:num_items() - 1 do
        local char = char_list:item_at(i)
        if char:character_type("colonel") and not char:has_garrison_residence() and not char:is_politician() then
            cm:kill_character(char:command_queue_index(), true, true)
        end
    end
end

---- Method to check the Defiling army's unit list, to run through and check if each unit is a Barrow unit.
---- If they are, kill and revive each Barrow unit.
--v method(cqi: CA_CQI?)
function liche_manager:revive_barrow_units(cqi)
    --# assume self: LICHE_MANAGER
    if not cqi then
        cqi = self:get_character_selected_cqi()
    end

    if not cqi or not is_number(cqi) then
        self:error("revive_barrow_units() called, but no character selected is found?")
        return
    end

    local char = cm:get_character_by_cqi(cqi)
    local char_str = cm:char_lookup_str(cqi)

    local mf = char:military_force()
    local unit_list = mf:unit_list()
    local barrows = {} --: vector<string>

    -- remove all barrow units from the army, and save them in the above table
    for i = 0, unit_list:num_items() - 1 do
        local unit = unit_list:item_at(i)
        if self:is_unit_barrow(unit:unit_key()) then
            table.insert(barrows, unit:unit_key())
            cm:remove_unit_from_character(char_str, unit:unit_key())
        end
    end

    -- run through the above table and add new units back in
    if not is_nil(barrows) and not is_nil(barrows[1]) then
        for i = 1, #barrows do
            cm:grant_unit_to_character(char_str, barrows[i])
        end
    end

    -- remove the colonel that spawns from remove_unit_from_character()
    cm:callback(function()
        self:kill_colonel()
    end, 0.1)

    --# assume cqi: number -- I HATE DOING THIS 
    self:log("DEFILE BARROW: Revived Barrow units for character with CQI ["..cqi.."] and killed that cruel Colonel.")
end


-- TODO maybe variable turn number? defaulting to 5 for now
-- TODO decide if I want to do this. Disabled for now.
---- Unattached method, just exists if I want to use it later
--v method()
function liche_manager:ruins_effect_bundle()
    --# assume self: LICHE_MANAGER
    local cqi = self:get_character_selected_cqi()
    if not cqi then
        self:error("ruins_effect_bundle() called, but no character selected is found!")
    end

    local bundles = {
        -- build the effect bundles!
    } --: vector < string >

    local chance = cm:random_number(#bundles, 1)
    local bundle = bundles[chance]

    cm:apply_effect_bundle_to_characters_force(bundle, cqi, 5, false)
end

---- random shot between spawning a Druid or Barrow King
--v method()
function liche_manager:ruins_spawn_agent()
    --# assume self: LICHE_MANAGER

    local agents = {
        "AK_hobo_druid",
        "AK_hobo_barrow_king"
    } --: vector < string >

    -- details used for spawning the agent
    local chance = cm:random_number(#agents, 1)
    local agent = agents[chance]
    local type --: string
    local art_set --: string

    -- grab the type, and randomize between the three Druid types
    if agent == "AK_hobo_druid" then
        local chance2 = cm:random_number(3, 1)
        if chance2 == 1 then 
            agent = agent .. "_shadow" 
        elseif chance2 == 2 then 
            agent = agent.."_death"
        elseif chance2 == 3 then agent = agent.."_heavens"
        end
        type = "wizard"
    else
        type = "champion"
    end

    -- grab one of the three art sets available for each type, '_01' through '_03'
    local chance3 = cm:random_number(3, 1)
    art_set = agent .. "_0" .. chance3

    -- grab name keys from the integrated Lua file with a huge list of name
    local forename = self._forenames[cm:random_number(#self._forenames, 1)]
    local family_name = self._family_names[cm:random_number(#self._family_names, 1)]

    -- spawn the agent to the pool
    cm:spawn_character_to_pool(
        self._faction_key,
        forename,
        family_name,
        "",
        "",
        50,
        true,
        type,
        agent,
        true,
        art_set
    )

    cm:trigger_incident(self._faction_key, "barrow_"..agent, true)
    self:log("DEFILE BARROWS: Spawning agent type ["..agent.."] to character pool.")     
end

---- Picks a locked Regiment from random, unlocks it, and triggers an incident for UX
--v method()
function liche_manager:ruins_spawn_ror()
    --# assume self: LICHE_MANAGER

    -- list of rors that haven't been unlocked yet
    local rors = self:get_locked_regiments()

    -- pick between a random one!
    local chance = cm:random_number(#rors, 1)
    local ror = rors[chance]

    self:set_regiment_unlocked(ror._key)
    cm:trigger_incident(self._faction_key, "barrow_"..ror._key, true)
    self:log("DEFILE BARROWS: Legion of Undeath with key ["..ror._key.."] unlocked")
end

---- Spawns an enemty army to deal with
--v method()
function liche_manager:ruins_spawn_enemy()
    --# assume self: LICHE_MANAGER

    -- list of optional armies to spawn
    local factions = {
        "wh2_main_skv_skaven_qb1",
        "wh_main_vmp_vampire_counts_qb1"
    } --: vector < string >

    local chance = cm:random_number(2, 1) -- TODO change the randomness later on, post-release
    local faction = factions[chance]

    local force_key --: string
    if faction == "wh2_main_skv_skaven_qb1" then 
        force_key = "barrow_skaven"
    elseif faction == "wh_main_vmp_vampire_counts_qb1" then 
        force_key = "barrow_undead"
    end

    -- TODO increase randomness based on army comp? Sounds like a lot of work
    -- setup ram forces, one for each faction
    random_army_manager:new_force("barrow_skaven")
    random_army_manager:add_unit("barrow_skaven", "wh2_main_skv_inf_clanrats_0", 4)
    random_army_manager:add_unit("barrow_skaven", "wh2_main_skv_inf_clanrats_1", 4)
    random_army_manager:add_unit("barrow_skaven", "wh2_main_skv_inf_skavenslaves_0", 7)
    random_army_manager:add_unit("barrow_skaven", "wh2_main_skv_inf_skavenslave_slingers_0", 5)
    random_army_manager:add_unit("barrow_skaven", "wh2_main_skv_inf_stormvermin_0", 2)
    random_army_manager:add_unit("barrow_skaven", "wh2_main_skv_mon_rat_ogres", 1)
    random_army_manager:add_unit("barrow_skaven", "wh2_main_skv_inf_gutter_runner_slingers_0", 1)

    random_army_manager:new_force("barrow_undead")
    random_army_manager:add_unit("barrow_undead", "wh_main_vmp_inf_zombie", 8)
    random_army_manager:add_unit("barrow_undead", "wh_main_vmp_inf_skeleton_warriors_0", 4)
    random_army_manager:add_unit("barrow_undead", "wh_main_vmp_inf_skeleton_warriors_1", 3)
    random_army_manager:add_unit("barrow_undead", "wh_main_vmp_inf_crypt_ghouls", 2)
    random_army_manager:add_unit("barrow_undead", "wh_main_vmp_cav_black_knights_0", 1)
    random_army_manager:add_unit("barrow_undead", "wh_main_vmp_mon_fell_bats", 6)
    random_army_manager:add_unit("barrow_undead", "wh_main_vmp_mon_dire_wolves", 3)

    -- spawn the enemy army close to the player's defile character
    local char = cm:get_character_by_cqi(self:get_character_selected_cqi())
    local x, y = char:logical_position_x(), char:logical_position_y()
    local spawn_x, spawn_y = cm:find_valid_spawn_location_for_character_from_position(faction, x, y, false)
    local valid = false
    while not valid do
        if spawn_x ~= -1 then
            valid = true
            break
        end
        local square = {x - 10, x + 10, y - 10, y + 10}
        spawn_x, spawn_y = cm:find_valid_spawn_location_for_character_from_position(faction, cm:random_number(square[2], square[1]), cm:random_number(square[4], square[3]), false)
    end
    local loc = {spawn_x, spawn_y}

    -- create the force and the invasion objects
    local force = random_army_manager:generate_force(force_key, {6, 13}, false)
    local invasion = invasion_manager:get_invasion(force_key .. "_invasion")

    -- if one isn't found to already exist, then make a new one!
    if is_nil(invasion) then
        invasion = invasion_manager:new_invasion(force_key .. "_invasion", faction, force, loc)
    end
    
    -- neither of these are actually needed since the faction doesn't have any AI and won't survive the turn
    invasion:set_target("CHARACTER", char:command_queue_index(), char:faction():name())
    invasion:apply_effect("wh_main_bundle_military_upkeep_free_force", -1)

    -- spawn the army!
    invasion:start_invasion(
        function(self)
            local leader = self:get_general()
            -- make sure it actually freaking spawned
            if not is_nil(leader) then

                -- upon DoW, teleport the invasion to the player
                core:add_listener(
                    "BarrowDeclareWar",
                    "FactionLeaderDeclaresWar",
                    true,
                    function(context)
                        cm:teleport_to(cm:char_lookup_str(leader:command_queue_index()), spawn_x, spawn_y, false)
                        -- force the *player* to attack the *enemy*
                        cm:force_attack_of_opportunity(char:military_force():command_queue_index(), leader:military_force():command_queue_index(), false)
                    end,
                    false
                )

                -- prevent retreat
                core:add_listener(
                    "BarrowPrebattleScreen",
                    "PanelOpenedCampaign",
                    function(context)
                        return context.string == "popup_pre_battle"
                    end,
                    function(context)
                        cm:callback(function()
                            local component = find_uicomponent(core:get_ui_root(), "popup_pre_battle", "mid", "battle_deployment",
                            "regular_deployment", "button_set_attack", "button_dismiss")
                            if not not component then
                                component:SetDisabled(true)
                                component:SetState("inactive")
                            end
                        end, 0.5)
                    end,
                    false
                )

                -- trigger a listener that will be completed upon the next battle (can only be the invasion battle)
                -- destroy the invasion, regardless of status, and give the player their units!
                core:add_listener(
                    "BarrowKillThing",
                    "BattleCompleted",
                    true,
                    function(context)
                        core:remove_listener("BarrowPrebattleScreen")
                        local invasion = invasion_manager:get_invasion(force_key .. "_invasion")
                        if not is_nil(invasion) then
                            invasion:kill()
                        end
                        liche_manager:revive_barrow_units(char:command_queue_index())
                    end,
                    false
                )

                cm:force_declare_war(faction, "wh2_dlc11_vmp_the_barrow_legion", false, false, false)
            else
                liche_manager:error("ruins_spawn_enemy() called but the army didn't spawn? Reviving barrow units and calling it a day!")
                liche_manager:revive_barrow_units(char:command_queue_index())
            end
        end,
        false,
        false,
        false
    )

    self:log("DEFILE BARROWS: Enemy army spawned. Army details --")
    self:log("--- Spawn Location: [(" .. spawn_x .. ", " .. spawn_y .. ")]")
    self:log("--- Faction Key: [" .. faction .. "]")     
    self:log("--- Force Key: [" .. force_key .. "]")
end

---- Super simple option that triggers an incident that adds a random ancillary to the faction
--v method()
function liche_manager:ruins_spawn_item()
    --# assume self: LICHE_MANAGER

    cm:trigger_incident(self._faction_key, "barrow_item", true)
    self:log("DEFILE BARROWS: [barrow_item] incident triggered.")     
end

---- currently antiquated, horde replenishment is all kinds of fucked
--v method()
function liche_manager:force_replen()
    --# assume self: LICHE_MANAGER
    local cqi = self:get_character_selected_cqi()
    local char_str = cm:char_lookup_str(cqi)
    cm:replenish_action_points(char_str)
    cm:force_character_force_into_stance(char_str, "MILITARY_FORCE_ACTIVE_STANCE_TYPE_SETTLE")
    cm:zero_action_points(char_str)
end

---- Link between the calculate_effect method and the methods that should be triggered, called directly from the liche_init file for now
--v method(ruin: string)
function liche_manager:apply_effect(ruin)
    --# assume self: LICHE_MANAGER
    local effect = self:calculate_effect(ruin)

    if effect == "" then
        self:error("apply_effect() called for region with key ["..ruin.."], but no effect was calculated. View log trace!")
        return
    end

    if self._defile_debug ~= "" then
        effect = self._defile_debug
    end

    --if effect == "effectBundle" then
        --self:ruinsEffectBundle()
    if effect == "spawnAgent" then
        self:ruins_spawn_agent()
    elseif effect == "spawnRoR" then
        self:ruins_spawn_ror()
    elseif effect == "enemy" then
        self:ruins_spawn_enemy()
    elseif effect == "item" then
        self:ruins_spawn_item()
    end

    --self:force_replen()
    if effect ~= "enemy" then
        self:revive_barrow_units()
    end
    
    self:apply_defile_xp()
end

-- TODO save the character's id better
---- to be called whenever a settlement_captured panel is opened by Kemmler for a ruined faction
--v method(region: string, button_number: string?)
function liche_manager:ruinsUI(region, button_number)
    --# assume self: LICHE_MANAGER

    local panel = find_uicomponent(core:get_ui_root(), "settlement_captured")
    local turns = self:calculate_turns_ruined(region)
    local isLocked = self._ruins[region].isLocked

    local RUINSUI = require("script/lichemaster/ui/ruins")
    if not button_number then
        RUINSUI.set(turns, isLocked)
    else
        RUINSUI.set(turns, isLocked, button_number)
    end
end

---- Save some details about the ruin within the LM
--v method(ruin: string)
function liche_manager:set_ruin(ruin)
    --# assume self: LICHE_MANAGER

    -- grab the region object and check its status
    local region = cm:get_region(ruin)
    if not region:is_abandoned() then
        self:error("set_ruin() called, but the region supplied, ["..ruin.."], is not abandoned!")
        return
    end

    -- save the current turn number, used when the ruin is defiled
    local turn = cm:model():turn_number()
    self._ruins[ruin] = {["turn"] = turn, ["isLocked"] = false};

    self:log("RUIN TRACKER: Setting ruin for region ["..ruin.."] on turn number ["..tostring(turn).."]")
end

---- Stop tracking the ruin
--v method(ruin: string)
function liche_manager:remove_ruin(ruin)
    --# assume self: LICHE_MANAGER

    -- grab the region object and check its status
    local region = cm:get_region(ruin)
    if region:is_abandoned() then
        self:error("remove_ruin() called, but the region applied, ["..region:name().."], is still abandoned!")
        return
    end

    -- remove the internal entry for that region
    self._ruins[region:name()] = nil

    self:log("RUIN TRACKER: Removing ruin for region ["..ruin.."]")
end

---- Defile the ruin and apply the effect from defiling!
--v method(ruin: string)
function liche_manager:defile_ruin(ruin)
    --# assume self: LICHE_MANAGER

    -- run through the method that checks the "tier" of the ruin and applies the result - enemy/item/RoR/agent
    self:apply_effect(ruin)

    -- prevent this ruin from being defiled again
    self._ruins[ruin].isLocked = true
    
    -- tracker for the Priestess unlock condition
    self._num_ruins_defiled = self._num_ruins_defiled + 1
    core:trigger_event("LichemasterEventRuinDefiled", tostring(self._num_ruins_defiled))
end

-----------------------------------------
--------------  REGIMENTS! --------------
-----------------------------------------

---- regiment object which saves basic data about the different legions of undeath
local regiment = {} --# assume regiment: LICHE_REGIMENT

-- TODO make this work for non-English
---- instantiate a new regiment
--v function(key: string, ui_name: string) --> LICHE_REGIMENT
function regiment.new_regiment(key, ui_name)
    local self = {}

    -- give the object the same metatable as the regiment prototype
    -- __tostring allows me to type-check later on
    setmetatable(self, {__index = regiment, __tostring = "LICHE_REGIMENT"})
    --# assume self: LICHE_REGIMENT

    -- basic initiation data
    self._key = key
    self._ui_name = ui_name

    -- used to track status later on
    self._is_recruited = false
    self._is_unlocked = false

    -- text from an internal file, determines some UI stuff in the Legions of Undeath panel
    local TEXTS = liche_manager._units[1]
    local texts
    for k, v in pairs(TEXTS) do
        if k == key then
            texts = v
        end
    end

    if not texts then
        texts = {"", "", ""}
    end

    self._t1 = texts[1]
    self._t2 = texts[2]
    self._t3 = texts[3]
    return self
end

---- Getter for the 'key'
--v method() --> string
function regiment:key()
    --# assume self: LICHE_REGIMENT
    return self._key
end

---- Getter for the 'ui_name'
--v method() --> string
function regiment:ui_name()
    --# assume self: LICHE_REGIMENT
    return self._ui_name
end

---- Getter for unlocked status
--v method() --> bool
function regiment:is_unlocked()
    --# assume self: LICHE_REGIMENT
    return not not self._is_unlocked
end

---- Setter for unlocked status - true to unlock, false to lock
--v method(enable: boolean)
function regiment:set_unlocked(enable)
    --# assume self: LICHE_REGIMENT
    self._is_unlocked = not not enable
end

---- Create a new regiment using the regiment.new_regiment() constructor, and then save the resulting regiment in the LM
--v method(key: string, ui_name: string)
function liche_manager:new_regiment(key, ui_name)
    --# assume self: LICHE_MANAGER

    local new = regiment.new_regiment(key, ui_name)
    self._regiments[key] = new
end

--- Grab a regiment by a key
--v method(key: string) --> ( LICHE_REGIMENT | nil )
function liche_manager:get_regiment_with_key(key)
    --# assume self: LICHE_MANAGER

    local get = self._regiments[key]
    if not get then
        self:error("get_regiment_with_key() called but the supplied key ["..key.."] doesn't have an associated regiment entry! Returning nil.")
        return nil
    end

    return get
end

--- Grab all regiments that are unlocked
--v method() --> vector<LICHE_REGIMENT>
function liche_manager:get_unlocked_regiments()
    --# assume self: LICHE_MANAGER

    local regiments = self._regiments

    local get = {}
    for k, v in pairs(regiments) do
        if v._is_unlocked == true then
            table.insert(get, v)
        end
    end

    return get
end

--- Grab all regiments that are locked
--v method() --> vector<LICHE_REGIMENT>
function liche_manager:get_locked_regiments()
    --# assume self: LICHE_MANAGER

    local regiments = self._regiments

    local get = {}
    for k, v in pairs(regiments) do
        if v._is_unlocked == false then
            table.insert(get, v)
        end
    end

    return get 
end

---- Grab all regiments that are already recruited
--v method() --> vector<LICHE_REGIMENT>
function liche_manager:get_recruited_regiments()
    --# assume self: LICHE_MANAGER

    local regiments = self._regiments

    local get = {}
    for k, v in pairs(regiments) do
        if v._is_recruited == true then
            table.insert(get, v)
        end
    end

    return get 
end

---- Wrapper to read the unlock status of a regiment
--v method(key: string) --> bool
function liche_manager:is_regiment_unlocked(key)
    --# assume self: LICHE_MANAGER

    local regiment_obj = self:get_regiment_with_key(key)
    if is_nil(regiment_obj) then
        self:error("is_regiment_unlocked() called but there's no saved regiment with the key ["..key.."]")
        return false
    end

    return regiment_obj:is_unlocked()
end

---- Wrapper to unlock a regiment by the key
--v method(key: string)
function liche_manager:set_regiment_unlocked(key)
    --# assume self: LICHE_MANAGER

    local regiment_obj = self:get_regiment_with_key(key)
    if is_nil(regiment_obj) then
        self:error("set_regiment_unlocked() called but there's no saved regiment with the key ["..key.."]")
        return
    end

    regiment_obj:set_unlocked(true)
end

---- Wrapper to lock a regiment by the key
--v method(key: string)
function liche_manager:set_regiment_locked(key)
    --# assume self: LICHE_MANAGER

    local regiment_obj = self:get_regiment_with_key(key)
    if is_nil(regiment_obj) then
        self:error("set_regiment_locked() called but there's no saved regiment with the key ["..key.."]")
        return
    end

    regiment_obj:set_unlocked(false)
end

---- Spawn specific unit for the current 'character_selected' characted
--v method(selectedCQI: CA_CQI, key: string)
function liche_manager:spawn_ror_for_character(selectedCQI, key)
    --# assume self: LICHE_MANAGER
    --# assume selectedCQI: number

    -- make sure that regiment object exists
    local regiment_obj = self:get_regiment_with_key(key)
    if is_nil(regiment_obj) then
        self:error("spawn_ror_for_character() called but there's no saved regiment with the key ["..key.."]")
        return
    end

    -- lock the object, to prevent more than one existing
    regiment_obj:set_unlocked(false)

    -- add the unit and charge the -5 NP
    cm:grant_unit_to_character("character_cqi:"..selectedCQI, key)
    cm:faction_add_pooled_resource(self._faction_key, "necropower", "necropower_ror", -5)

    self:log("LEGIONS OF UNDEATH: Spawning Legion with key ["..key.."] for character with CQI ["..selectedCQI.."].")
end

---- Internal function from the UI
--v method(key: string)
function liche_manager:set_selected_legion(key)
    --# assume self: LICHE_MANAGER
    self._selected_legion = key
    core:trigger_event("LichemasterLegionSelected", key)
end

---- Big function that sets the UI and stuff, called when a LM character is selected by Kemmler player
--v method(cqi: CA_CQI)
function liche_manager:ror_UI(cqi)
    --# assume self: LICHE_MANAGER
    if is_number(cqi) then
        self:set_character_selected_cqi(cqi)
    else
        self:error("rorUI() called, but the provided CQI wasn't a number, aborting probably.")
        return
    end

    -- the actual functions to create the UI panel are in this subfile
    local create_panel = require("script/lichemaster/ui/ror")

    -- see if the button was already created
    local parent = find_uicomponent(core:get_ui_root(), "layout", "hud_center_docker", "hud_center", "small_bar", "button_group_army")
    local test = find_uicomponent(parent, "LicheRorButton")
    if not test then
        -- create the button!
        parent:CreateComponent("LicheRorButton", "ui/templates/square_medium_button")
        local button = find_uicomponent(parent, "LicheRorButton")
        button:SetImagePath("ui/skins/default/icon_renown.png")

        -- hide and prevent the use of the vanilla RoR button
        local ror = find_uicomponent(parent, "button_renown")
        if is_uicomponent(ror) then
            button:MoveTo(ror:Position())
            ror:SetDisabled(true)
            ror:SetVisible(false)
            ror:SetInteractive(false)
        end

        -- swap positions of raise dead and the new button
        local raise_dead = find_uicomponent(parent, "button_mercenaries")
        local x1, y1 = raise_dead:Position()
        local x2, y2 = button:Position()

        raise_dead:MoveTo(x2, y2)
        button:MoveTo(x1, y1)

        button:SetTooltipText("Raise Legions of Undeath||Bolster the ranks with ancient warriors.", true)

        -- when the new button is pressed, create the panel!
        core:add_listener(
            "LicheRorButtonPressed",
            "ComponentLClickUp",
            function(context)
                return context.string == "LicheRorButton"
            end,
            function(context)
                local ok, err = pcall(function()
                    create_panel()
                end)
                if not ok then self:error(err) end
            end,
            true
        )
    else
        -- if the button already exists, hide the vanilla RoR button and call it a day
        local ror = find_uicomponent(parent, "button_renown")
        if is_uicomponent(ror) then
            ror:SetVisible(false)
        end
    end

end

--v method()
function liche_manager:setup_regiments()
    --# assume self: LICHE_MANAGER
    self:new_regiment("AK_hobo_ror_doomed_legion", "The Doomed Legion")
    self:new_regiment("AK_hobo_ror_caged", "The Caged")
    self:new_regiment("AK_hobo_ror_storm", "Guardians of Medhe")
    self:new_regiment("AK_hobo_ror_wight_knights", "Wight Knights")
    self:new_regiment("AK_hobo_ror_jacsen", "Mikeal Jacsen")
    self:new_regiment("AK_hobo_ror_beast", "Beast of Cailledh")
    self:new_regiment("AK_hobo_ror_skulls", "Skulls of Geistenmund")
    self:new_regiment("AK_hobo_ror_spider", "Terror of the Lichemaster")
end

-----------------------------------------
-------------- LORD LOCKS ---------------
-----------------------------------------

---- Currently unused object, might return it for easy of use later
local liche_lord = {} --# assume liche_lord: LICHE_LORD

--[[
    deets needed:
    - lord subtype
    - lord artset
    - lord unlock conditions
    - lord locked/unlocked
    - 
]]

--v function(subtype_key: string, artset_key: string, unlock_condition: function)
function liche_lord.new(subtype_key, artset_key, unlock_condition)
    

end

---- Self-explanatory getter
--v method(subtype: string) --> boolean
function liche_manager:can_recruit_lord(subtype)
    --# assume self: LICHE_MANAGER
    return not not self._can_recruit_lord[subtype]
end

--- Self-explanatory getter x2
--v method() --> boolean
function liche_manager:can_recruit_any_lord()
    --# assume self: LICHE_MANAGER
    if not self:can_recruit_lord("AK_hobo_nameless") and not self:can_recruit_lord("AK_hobo_draesca") and not self:can_recruit_lord("AK_hobo_priestess") then
        return false
    else
        return true
    end
end

---- Called if there are no available lords to recruit
--v method()
function liche_manager:lord_lock_UI()
    --# assume self: LICHE_MANAGER

    local component = find_uicomponent(core:get_ui_root(), "layout", "hud_center_docker", "hud_center",
    "small_bar", "button_group_army_settled", "button_create_army")

    if not component then
        self:error("lord_lock_UI() called, but the Create Army button is not existent!")
        return
    end

    if not self:can_recruit_any_lord() then
    -- grey the button and give a tooltip for UX
        component:SetState("inactive")
        component:SetTooltipText("[[col:red]]Cannot recruit a new army - no available lords![[/col]]", false)
        self:log("LORDS: Locking the 'create army' button because there are no available lords to recruit!")
    else
        component:SetState("active")
        self:log("LORDS: Unlocking the 'create army' button!")
    end

end

---- Runs through the pool of lords, when that panel opens up, and hides any lord that isn't one of the legendary lords
--v method()
function liche_manager:lord_pool_UI()
    --# assume self: LICHE_MANAGER

    -- grab the listbox (scroll bar) and make sure it exists
    local component = find_uicomponent(core:get_ui_root(), "character_panel", "general_selection_panel", "character_list_parent", "character_list", "listview", "list_clip", "list_box")
    if not component then
        self:error("lordPoolUI() called, but the general candidate list is nonexistent!")
        return
    end

    local selected = false
    -- loop through all the UIC's found underneath the listbox
    for i = 0, 20 do
        local agent = find_uicomponent(component, "general_candidate_"..i.."_")

        -- stop loop if there is not UIC with that name
        if not agent then break end
        -- check the on-screen text
        -- TODO make this work for non-English
        local subtype = find_uicomponent(agent, "dy_subtype"):GetStateText()
        if subtype ~= "Legendary Evil" and subtype ~= "Legendary Druid" and subtype ~= "Legendary Wight King" and subtype ~= "Legendary Lord"  then
            agent:SetVisible(false)
        else
            if not selected then
                -- select the top legendary lord, to prevent it from defaulting to a vanilla Vamp Lord
                agent:SimulateLClick()
            end
        end
    end

    self:log("LORDS: Hiding all candidates from the lord pool except for the legendary Barrow subtypes.")
end

---- Unlock the lord and spawn it to pool!
--v method(subtype: string)
function liche_manager:unlock_lord(subtype)
    --# assume self: LICHE_MANAGER

    local subtypes = require("script/lichemaster/tables/subtypes")
    for key, table in pairs(subtypes) do
        if subtype == key then
            cm:spawn_character_to_pool(
                self._faction_key,
                table.forename,
                table.family_name,
                table.clan_name,
                table.other_name,
                table.age,
                table.is_male,
                table.agent_type,
                table.agent_subtype,
                table.is_immortal,
                table.art_set_id
            )
            self._can_recruit_lord[subtype] = true

            if key == "AK_hobo_nameless" then
                self._is_nameless_unlocked = true
            elseif key == "AK_hobo_draesca" then
                self._is_draesca_unlocked = true
            elseif key == "AK_hobo_priestess" then
                self._is_priestess_unlocked = true
            end

            self:log("LORDS: Unlocked lord with subtype ["..subtype.."].")
        end
    end
end

-----------------------------------------
-------------- NECRO POWER! -------------
-----------------------------------------

--v method()
function liche_manager:necropower_button()
    --# assume self: LICHE_MANAGER
    local docker = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_group_management")
    local existing_button = find_uicomponent(docker, "button_necropower")
    if not existing_button then
        local np_button = core:get_or_create_component("button_necropower", "ui/templates/round_medium_button", docker)
        np_button:SetImagePath("ui/kemmler/AK_hobo_necropowa_summarybutt.png")

        local tech = find_uicomponent(docker, "button_technology")
        local bloodlines = find_uicomponent(docker, "button_bloodlines")
        local rites = find_uicomponent(docker, "button_rituals")

        -- gently nudge the button to a different position
        if not not rites then
            local x, y = bloodlines:Position()
            np_button:MoveTo(x, y)
        else
            local x, y = tech:Position()
            np_button:MoveTo(x, y)
        end

        -- force-updates the UI
        np_button:SetVisible(false)
        np_button:SetVisible(true)

        np_button:SetTooltipText("Necromantic Power||View details about your current Necromantic Power amounts.", true)
    else
        existing_button:SetVisible(true)
    end
end

--v method()
function liche_manager:clear_necropower_button()
    --# assume self: LICHE_MANAGER
    local docker = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_group_management")
    local existing_button = find_uicomponent(docker, "button_necropower")
    if not not existing_button then
        existing_button:SetVisible(false)
    end
end

--v method()
function liche_manager:populate_necropower_panel()
    --# assume self: LICHE_MANAGER
    local panel = find_uicomponent(core:get_ui_root(), "necropower_panel")
    local parchment = find_uicomponent(panel, "parchment")

    local faction = cm:get_faction(self._faction_key)
    local necropower = faction:pooled_resource("necropower")
    
    local total_value = necropower:value()
    local factors = necropower:factors()
    local factor_buildings_value = 0 --: number
    local factor_chars_value = 0 --: number
    local factor_battles_value = 0 --: number
    local factor_units_value = 0 --: number
    local factor_ror_value = 0 --: number

    for i = 0, factors:num_items() - 1 do
        local factor = factors:item_at(i)
        local factor_value = factor:value()
        local factor_max_value = factor:maximum_value()
        if factor_max_value == 100 then
            factor_buildings_value = factor_value
        elseif factor_max_value == 101 then
            factor_chars_value = factor_value
        elseif factor_max_value == 102 then
            factor_battles_value = factor_value
        elseif factor_max_value == 103 then
            factor_units_value = factor_value
        elseif factor_max_value == 104 then
            factor_ror_value = factor_value
        end
    end

    local pX, pY = parchment:Position()

    local tX = pX --: number
    local tY = pY --: number

    --v function(key: string, header_loc: string, value_loc: string)
    local function new_text_pair(key, header_loc, value_loc)
        local header = core:get_or_create_component(key.."_header", "ui/vandy_lib/black_text", parchment)
        local value = core:get_or_create_component(key.."_value", "ui/vandy_lib/black_text", parchment)
        parchment:Adopt(header:Address())
        parchment:Adopt(value:Address())
        if key == "total" then
            header:MoveTo(tX + header:Width() / 2, tY + header:Height() * 2)
            tX, tY = header:Position()
            value:MoveTo(tX + value:Width() * 2, tY)
        else
            header:MoveTo(tX, tY + header:Height() * 2)
            tX, tY = header:Position()
            value:MoveTo(tX + value:Width() * 2, tY)
        end
        header:SetStateText(header_loc)
        value:SetStateText(value_loc)
    end

    new_text_pair("total", "Total:", tostring(total_value))
    new_text_pair("factor_buildings", "Buildings:", tostring(factor_buildings_value))
    new_text_pair("factor_chars", "Characters:", tostring(factor_chars_value))
    new_text_pair("factor_units", "Units:", tostring(factor_units_value))
    new_text_pair("factor_ror", "Legions of Undeath:", tostring(factor_ror_value))
end

--v method()
function liche_manager:set_necropower_panel()
    --# assume self: LICHE_MANAGER
    local root = core:get_ui_root()
    local layout = find_uicomponent(root, "layout")
    if not not layout then
        layout:SetVisible(false)
    end

    local existing_frame = find_uicomponent(root, "necropower_panel")

    if not not existing_frame then
        --existing_frame:SetVisible(true)
        self._UTILITY.remove_component(existing_frame)
    end

    local panel = core:get_or_create_component("necropower_panel", "ui/campaign ui/objectives_screen", root)
    local parchment = find_uicomponent(panel, "parchment")

    local kill1 = UIComponent(panel:Find("TabGroup"))
    local kill2 = UIComponent(panel:Find("button_info"))

    self._UTILITY.remove_component({kill1, kill2})
    
    local sX, sY = core:get_screen_resolution()

    panel:SetCanResizeWidth(true)
    panel:SetCanResizeHeight(true)
    panel:Resize(sX * 0.5, sY * 0.5)
    panel:SetCanResizeWidth(false)
    panel:SetCanResizeHeight(false)
   
    local fW, fH = panel:Bounds()
    panel:MoveTo(sX/2 - fW/2, sY/2 - fH/2)

    local parchment = find_uicomponent(panel, "parchment")

    local fX, fY = panel:Position()
    local fW, fH = panel:Bounds()

    parchment:SetCanResizeWidth(true)
    parchment:SetCanResizeHeight(true)
    parchment:Resize(fW * 0.98, fH * 0.85)
    parchment:SetCanResizeWidth(false)
    parchment:SetCanResizeHeight(false)

    local pW, pH = parchment:Bounds()
    local gapX, gapY = fW - pW, fH - pH
    parchment:MoveTo(fX + gapX/2, fY + gapY/2)

    local title = find_uicomponent(panel, "panel_title", "tx_objectives")
    title:SetStateText("Necromantic Power")

    if not find_uicomponent(panel, "necropower_panel_close_button") then
        panel:CreateComponent("necropower_panel_close_button", "ui/templates/round_medium_button")
        core:add_listener(
            "LicheRorCloseButton",
            "ComponentLClickUp",
            function(context)
                return context.string == "necropower_panel_close_button"
            end,
            function(context)
                panel:SetVisible(false)
                layout:SetVisible(true)
            end,
            true
        )

        local closeButton = find_uicomponent(panel, "necropower_panel_close_button")
        closeButton:SetImagePath("ui/skins/default/icon_check.png")

        fX, fY = panel:Position()
        fW, fH = panel:Bounds()
        local bW, bH = closeButton:Width(), closeButton:Height()

        closeButton:MoveTo(fX + (fW/2 - bW/2), fY + (fH - bH))
    end

    self:populate_necropower_panel()
end

---- apply attrition to any lords who aren't in Kemmler's region
--v method()
function liche_manager:apply_attrition()
    --# assume self: LICHE_MANAGER
    self:log("NECROMANTIC POWER: Checking Kemmy's faction character list, applying attrition to any Kemmler generals who are not in the same region as Kemmler.")
    local faction = cm:get_faction(self._faction_key)
    local char_list = faction:character_list()
    local kemmy = faction:faction_leader()
    for i = 0, char_list:num_items() - 1 do
        local char = char_list:item_at(i)
        if not char:character_subtype("vmp_heinrich_kemmler") and not char:character_subtype("AK_hobo_kemmy_wounded") and char:has_military_force() and char:faction():name() == "wh2_dlc11_vmp_the_barrow_legion" then
            if char:region():name() ~= kemmy:region():name() then
                self:log("NECROMANTIC POWER: Applying the low-necromantic-power attrition to character with surname ["..char:get_surname().."] in region ["..char:region():name().."] for one turn.")
                cm:apply_effect_bundle_to_characters_force("lichemaster_distance_attrition", char:command_queue_index(), 1, false)
            end
        end
    end
end

-----------------------------------
------  LIVES/WOUNDED KEMMY  ------
-----------------------------------

---- Current value of lives
--v method() --> number 
function liche_manager:get_lives()
    --# assume self: LICHE_MANAGER
    local faction = cm:get_faction(self._faction_key)
    return faction:pooled_resource("lichemaster_lives"):value()
end

---- Maximum total lives - can only be revived 3 times
--v method() --> number
function liche_manager:get_max_lives()
    --# assume self: LICHE_MANAGER
    local remaining = self._remaining_max_lives
    return remaining
end

---- Check if the player can revive
--v method() --> boolean
function liche_manager:can_revive()
    --# assume self: LICHE_MANAGER
    local value = self:get_lives()
    local remaining = self:get_max_lives()
    if value >= 1 and remaining ~= 0 then
        return true
    else 
        return false 
    end
end

---- Grab the turn number of the last time add_life() method was called
--v method() --> number
function liche_manager:last_turn_lives_changed()
    --# assume self: LICHE_MANAGER
    return self._last_turn_lives_changed
end

---- Add one life, as long as the last time lives changed was more than 20 turns ago
--v method()
function liche_manager:add_life()
    --# assume self: LICHE_MANAGER

    local turn = cm:model():turn_number()

    if turn >= self._last_turn_lives_changed + 20 then
        cm:faction_add_pooled_resource(self._faction_key, "lichemaster_lives", "bribes", 1)
        self._last_turn_lives_changed = turn
    end
end

---- Remove one of the lives!
--v method()
function liche_manager:spend_life()
    --# assume self: LICHE_MANAGER
    cm:faction_add_pooled_resource(self._faction_key, "lichemaster_lives", "bribes", -1)

    -- subtract 1 from the remaining max lives
    self._remaining_max_lives = self._remaining_max_lives - 1
end

---- run through the character list of the faction and return the CQI of Wounded Kemmy
--v method() --> CA_CQI
function liche_manager:get_wounded_cqi() 
    --# assume self: LICHE_MANAGER

    local char_list = cm:get_faction(self._faction_key):character_list()

    for i = 0, char_list:num_items() - 1 do
        local char = char_list:item_at(i)
        if char:character_subtype("AK_hobo_kemmy_wounded") then
            return char:command_queue_index()
        end
    end

    local cqi = 0
    self:error("WOUNDED KEMMY: Get Wounded CQI called, none found? Returning 0.")
    return cqi
end

---- run through the character list and get the CQI of the actual Kemmy character
--v method() --> CA_CQI
function liche_manager:get_real_cqi()
    --# assume self: LICHE_MANAGER

    local char_list = cm:get_faction(self._faction_key):character_list()

    for i = 0, char_list:num_items() - 1 do
        local char = char_list:item_at(i)
        if char:character_subtype("vmp_heinrich_kemmler") then
            return char:command_queue_index()
        end
    end

    local cqi = 0
    self:error("WOUNDED KEMMY: Get Real CQI called, none found? Returning 0.")
    return cqi
end

---- select one of a few spots for the Wounded Kemmy army to spawn
function liche_manager:wounded_kemmy_coords() --> (number, number, string)
    local regionNames = {
        "wh2_main_albion_albion",
        "wh_main_tilea_miragliano",
        "wh_main_western_border_princes_myrmidens",
        "wh_main_stirland_wurtbad",
        "wh_main_the_wasteland_marienburg"
    }--: vector<string>

    local regions = {
        ["wh2_main_albion_albion"] = {322, 332, 548, 558},
        ["wh_main_tilea_miragliano"] = {468, 492, 270, 290},
        ["wh_main_western_border_princes_myrmidens"] = {555, 593, 306, 331},
        ["wh_main_stirland_wurtbad"] = {631, 649, 390, 402},
        ["wh_main_the_wasteland_marienburg"] = {420, 434, 453, 462}
    }--: map<string, vector<number>>

    local region = regionNames[cm:random_number(#regionNames, 1)]
    local regionCoords = regions[region]

    local valid = false

    while not valid do
        local x = cm:random_number(regionCoords[2], regionCoords[1])
        local y = cm:random_number(regionCoords[4], regionCoords[3])

        if is_valid_spawn_point(x, y) then
            valid = true
            return x, y, region
        end
    end

    return -1, -1, ""
end

---- Called to kill Wounded Kemmy if the battle ends and Kemmler is still alive.
--v method()
function liche_manager:kill_wounded_kemmy()
    --# assume self: LICHE_MANAGER
    self:log("WOUNDED KEMMLER: Killing wounded Kemmy.")
    local cqi = self:get_wounded_cqi()
    local char = cm:get_character_by_cqi(cqi)
    cm:disable_event_feed_events(true, "", "", "character_dies_in_action")
    if not char then
        --# assume cqi: number
        self:error("WOUNDED KEMMLER: Kill Wounded Kemmy failed, char with CQI ["..cqi.."] unfound. Investigate!")
        return
    end
    if not char:character_subtype("AK_hobo_kemmy_wounded") then
        --# assume cqi: number
        self:error("WOUNDED KEMMLER: Kill Wounded Kemmy failed, char with CQI ["..cqi.."] does not have the correct subtype. Investigate!")
        return
    end
    cm:kill_character(cqi, true, false)
    cm:callback(function() cm:disable_event_feed_events(false, "", "", "character_dies_in_action") end, 1)
end

-- TODO test that this works between saves
---- Called to establish the countdown until the wounded kemmy is killed and real kemmy is revived!
---- Wounded Kemmy is spawned elsewhere, this method simply costs the life and tracks the 
--v method(turn: number, unit_list: string)
function liche_manager:respawn_kemmy(turn, unit_list)
    --# assume self: LICHE_MANAGER
    self._turn_to_spawn = turn + 5

    self:log("WOUNDED KEMMY: Kemmler wounded on turn ["..turn.."], and will be revived on turn ["..(turn + 5).."].")
    self:log("WOUNDED KEMMY: Removing the stored life.")

    self:spend_life()

    local kemmy_cqi = self:get_real_cqi()

    self._unit_list = unit_list
end

---- Build a basic army for the Wounded Kemmy temporary spawn
--v method() --> string
function liche_manager:wounded_kemmy_unit_list()
    --# assume self: LICHE_MANAGER
    local force_key = "wounded_kemmy"
    random_army_manager:new_force(force_key)

    random_army_manager:add_unit(force_key, "AK_hobo_skeleton_swords", 4)
    random_army_manager:add_unit(force_key, "AK_hobo_skeleton_spears", 4)
    random_army_manager:add_unit(force_key, "AK_hobo_skeleton_2h", 3)
    random_army_manager:add_unit(force_key, "AK_hobo_skeleton_lobber", 2)
    random_army_manager:add_unit(force_key, "AK_hobo_horsemen", 2)
    random_army_manager:add_unit(force_key, "AK_hobo_horsemen_lances", 1)

    return random_army_manager:generate_force(force_key, {6, 13}, false) 
end

---- Spawn Wounded Kemmy off-screen when Kemmler is in a pending battle and has at least one life.
--v method(x: number, y: number, kem_cqi: CA_CQI, position: string)
function liche_manager:spawn_wounded_kemmy(x, y, kem_cqi, position)
    --# assume self: LICHE_MANAGER

    local unit_list = self:wounded_kemmy_unit_list()

    local spawnX, spawnY, spawnRegion = self:wounded_kemmy_coords()
    if spawnRegion == "" then
        self:error("WOUNDED KEMMY: Spawn Wounded Kemmy called but the coordinates returned were -1, -1. Investigate!")
    end

    cm:create_force_with_general(
        self._faction_key,
        unit_list,
        spawnRegion,
        spawnX,
        spawnY,
        "general",
        "AK_hobo_kemmy_wounded",
        "names_name_2147345320",
        "",
        "names_name_2147345313",
        "",
        false,
        function(cqi)
            -- for later? idk
        end
    )

end

-- initialize the actual manager, now that everything is loaded
liche_manager.init()

-- needed for some of the external files, since these apparently don't exist in the global env?
_G.UIComponent = UIComponent;
_G.find_uicomponent = find_uicomponent;
_G.print_all_uicomponent_children = print_all_uicomponent_children;
_G.is_uicomponent = is_uicomponent;
_G.out = out;
_G.core = core;
_G.output_uicomponent = output_uicomponent;

-- save details 
cm:add_saving_game_callback(
    function(context)
        cm:save_named_value("lichemaster_can_recruit_lord_table", _G._LICHEMANAGER._can_recruit_lord, context)
        cm:save_named_value("lichemaster_hero_spawn_rank_increase", _G._LICHEMANAGER._hero_spawn_rank_increase, context)
        cm:save_named_value("lichemaster_turn_to_spawn", _G._LICHEMANAGER._turn_to_spawn, context)
        cm:save_named_value("lichemaster_unit_list", _G._LICHEMANAGER._unit_list, context)
        cm:save_named_value("lichemaster_num_ruins_defiled", _G._LICHEMANAGER._num_ruins_defiled, context)
        cm:save_named_value("lichemaster_num_razed_settlements", _G._LICHEMANAGER._num_razed_settlements, context)
        cm:save_named_value("lichemaster_remaining_max_lives", _G._LICHEMANAGER._remaining_max_lives, context)
        cm:save_named_value("lichemaster_is_draesca_unlocked", _G._LICHEMANAGER._is_draesca_unlocked, context)
        cm:save_named_value("lichemaster_is_nameless_unlocked", _G._LICHEMANAGER._is_nameless_unlocked, context)
        cm:save_named_value("lichemaster_is_priestess_unlocked", _G._LICHEMANAGER._is_priestess_unlocked, context)
    end
)

-- load 'em back up!
cm:add_loading_game_callback(
    function(context)
        if not cm:is_new_game() then
            _G._LICHEMANAGER._can_recruit_lord = cm:load_named_value("lichemaster_can_recruit_lord_table", {}, context)
            _G._LICHEMANAGER._turn_to_spawn = cm:load_named_value("lichemaster_turn_to_spawn", 0, context)
            _G._LICHEMANAGER._unit_list = cm:load_named_value("lichemaster_unit_list", "", context)
            _G._LICHEMANAGER._num_ruins_defiled = cm:load_named_value("lichemaster_num_ruins_defiled", 0, context)
            _G._LICHEMANAGER._num_razed_settlements = cm:load_named_value("lichemaster_num_razed_settlements", 0, context)
            _G._LICHEMANAGER._hero_spawn_rank_increase = cm:load_named_value("lichemaster_hero_spawn_rank_increase", 0, context)
            _G._LICHEMANAGER._remaining_max_lives = cm:load_named_value("lichemaster_remaining_max_lives", 3, context)
            _G._LICHEMANAGER._is_draesca_unlocked = cm:load_named_value("lichemaster_is_draesca_unlocked", false, context)
            _G._LICHEMANAGER._is_nameless_unlocked = cm:load_named_value("lichemaster_is_nameless_unlocked", false, context)
            _G._LICHEMANAGER._is_priestess_unlocked = cm:load_named_value("lichemaster_is_priestess_unlocked", false, context)
        end
    end
)