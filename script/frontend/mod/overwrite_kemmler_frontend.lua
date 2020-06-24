local unit_card_manager = core:get_static_object("vandy_unit_card_manager")
--# assume unit_card_manager: VANDY_UCM

unit_card_manager:remove_frontend_unit_for_starting_general(
	"wh_main_vmp_mon_dire_wolves", 
	"2140783651"
)

unit_card_manager:remove_frontend_unit_for_starting_general(
	"wh_main_vmp_inf_cairn_wraiths", 
	"2140783651"
)

unit_card_manager:remove_frontend_unit_for_starting_general(
	"wh_main_vmp_cav_hexwraiths", 
	"2140783651"
)

unit_card_manager:new_unit_card(
	"AK_hobo_barrow_guardians", 
	"land_units_onscreen_name_AK_hobo_barrow_guardians", 
	"infantry_sword", 
	"unit_description_short_texts_text_AK_hobo_barrow_guardians", 
	{"armoured_and_shielded","anti_infantry"}, 
	"AK_hobo_barrow_guardians.png", 
	120, 
	false, 
	212, 
	9840, 
	{90,55,27,30,34,30,8}, 
	{
		"shielded","ws_bvsi"
	}
)

unit_card_manager:add_shield_value_to_unit(
	"AK_hobo_barrow_guardians", 
	55
)

unit_card_manager:add_weapon_strength_breakdown_to_unit(
	"AK_hobo_barrow_guardians", 
	23, 
	7, 
	0, 
	0
)

unit_card_manager:add_resistances_to_unit(
	"AK_hobo_barrow_guardians", 
	0, 
	0, 
	0, 
	0, 
	0
)

unit_card_manager:add_attributes_to_unit(
	"AK_hobo_barrow_guardians", 
	{"causes_fear","hide_forest","undead"}
)

unit_card_manager:new_ability(
	"wh_main_unit_passive_unstable_mark_ii", 
	"wh_main_unit_passive_unstable_mark_ii.png", 
	"unit_abilities_onscreen_name_wh_main_unit_passive_unstable_mark_ii", 
	"unit", 
	"common", 
	"unit_abilities_tooltip_text_wh_main_unit_passive_unstable_mark_ii", 
	false, 
	false, 
	false, 
	"wh_type_direct_damage", 
	"Constant", 
	"Self", 
	"", 
	"[[img:icon_morale]][[/img]]Leadership is above shattered, Battle outcome decided", 
	{"wh_main_all_direct_damage_self_high"}
)

unit_card_manager:add_ability_to_unit(
	"AK_hobo_barrow_guardians", 
	"wh_main_unit_passive_unstable_mark_ii"
)

unit_card_manager:new_ability(
	"wh_main_unit_passive_unstable", 
	"wh_main_unit_passive_unstable.png", 
	"unit_abilities_onscreen_name_wh_main_unit_passive_unstable", 
	"unit", 
	"common", 
	"unit_abilities_tooltip_text_wh_main_unit_passive_unstable", 
	false, 
	false, 
	false, 
	"wh_type_direct_damage", 
	"Constant", 
	"Self", 
	"", 
	"Battle outcome decided, [[img:icon_morale]]Leadership is above zero", 
	{"wh_main_all_direct_damage_self"}
)

unit_card_manager:add_ability_to_unit(
	"AK_hobo_barrow_guardians", 
	"wh_main_unit_passive_unstable"
)

unit_card_manager:add_frontend_unit_for_starting_general(
	"AK_hobo_barrow_guardians", 
	"2140783651"
)

unit_card_manager:new_unit_card(
	"AK_hobo_hexwr", 
	"land_units_onscreen_name_wh_main_vmp_cav_hexwraiths", 
	"vmp_cavalry_scythe", 
	"unit_description_short_texts_text_wh_main_unit_short_text_vmp_hexwraiths", 
	{"armour_piercing","ethereal","terror","vanguard_deployment"}, 
	"wh_main_vmp_hexwraiths.png", 
	60, 
	false, 
	350, 
	5280, 
	{0,38,33,24,20,38,34}, 
	{
		"ma_flaming","ma_magical","ws_ap"
	}
)

unit_card_manager:add_shield_value_to_unit(
	"AK_hobo_hexwr", 
	0
)

unit_card_manager:add_weapon_strength_breakdown_to_unit(
	"AK_hobo_hexwr", 
	4, 
	34, 
	0, 
	0
)

unit_card_manager:add_resistances_to_unit(
	"AK_hobo_hexwr", 
	75, 
	0, 
	0, 
	0, 
	0
)

unit_card_manager:add_attributes_to_unit(
	"AK_hobo_hexwr", 
	{"causes_fear","causes_terror","guerrilla_deploy","hide_forest","undead"}
)

unit_card_manager:new_ability(
	"wh_main_unit_passive_unstable", 
	"wh_main_unit_passive_unstable.png", 
	"unit_abilities_onscreen_name_wh_main_unit_passive_unstable", 
	"unit", 
	"common", 
	"unit_abilities_tooltip_text_wh_main_unit_passive_unstable", 
	-1, 
	false, 
	false, 
	"wh_type_direct_damage", 
	nil, 
	"", 
	"", 
	"Battle outcome decided, [[img:icon_morale]]Leadership is above zero", 
	{"wh_main_all_direct_damage_self"}
)

unit_card_manager:add_ability_to_unit(
	"AK_hobo_hexwr", 
	"wh_main_unit_passive_unstable"
)

unit_card_manager:new_ability(
	"wh_main_unit_passive_unstable_mark_ii", 
	"wh_main_unit_passive_unstable_mark_ii.png", 
	"unit_abilities_onscreen_name_wh_main_unit_passive_unstable_mark_ii", 
	"unit", 
	"common", 
	"unit_abilities_tooltip_text_wh_main_unit_passive_unstable_mark_ii", 
	-1, 
	false, 
	false, 
	"wh_type_direct_damage", 
	nil, 
	"", 
	"", 
	"[[img:icon_morale]][[/img]]Leadership is above shattered, Battle outcome decided", 
	{"wh_main_all_direct_damage_self_high"}
)

unit_card_manager:add_ability_to_unit(
	"AK_hobo_hexwr", 
	"wh_main_unit_passive_unstable_mark_ii"
)

unit_card_manager:add_frontend_unit_for_starting_general(
	"AK_hobo_hexwr", 
	"2140783651"
)

unit_card_manager:new_ui_unit_bullet_point_enum(
	"AK_hobo_tormented", 
	"negative"
)

unit_card_manager:new_unit_card(
	"AK_hobo_glooms", 
	"land_units_onscreen_name_AK_hobo_glooms", 
	"infantry_sword", 
	"unit_description_short_texts_text_AK_hobo_glooms", 
	{"meat_shield","ethereal","AK_hobo_tormented"}, 
	"AK_hobo_glooms.png", 
	160, 
	false, 
	37, 
	9280, 
	{0,40,31,5,6,18,3}, 
	{
		"ma_magical"
	}
)

unit_card_manager:add_shield_value_to_unit(
	"AK_hobo_glooms", 
	0
)

unit_card_manager:add_weapon_strength_breakdown_to_unit(
	"AK_hobo_glooms", 
	16, 
	2, 
	0, 
	0
)

unit_card_manager:add_resistances_to_unit(
	"AK_hobo_glooms", 
	75, 
	0, 
	0, 
	0, 
	0
)

unit_card_manager:add_attributes_to_unit(
	"AK_hobo_glooms", 
	{"causes_fear","hide_forest","undead"}
)

unit_card_manager:new_ability(
	"AK_hobo_tormented", 
	"AK_hobo_tormented.png", 
	"unit_abilities_onscreen_name_AK_hobo_tormented", 
	"unit", 
	"uncommon", 
	"unit_abilities_tooltip_text_AK_hobo_tormented", 
	false, 
	false, 
	false, 
	"wh_type_direct_damage", 
	"Constant", 
	"Self", 
	"", 
	"[[img:icon_morale]][[/img]]Leadership is above zero", 
	{}
)

unit_card_manager:add_ability_to_unit(
	"AK_hobo_glooms", 
	"AK_hobo_tormented"
)

unit_card_manager:new_ability(
	"AK_hobo_spirit_levy", 
	"AK_hobo_spirit_levy.png", 
	"unit_abilities_onscreen_name_AK_hobo_spirit_levy", 
	"unit", 
	"common", 
	"unit_abilities_tooltip_text_AK_hobo_spirit_levy", 
	false, 
	false, 
	false, 
	"wh_type_augment", 
	"Constant", 
	"Self", 
	"", 
	"[[img:icon_morale]][[/img]]Leadership is lower than 50%", 
	{}
)

unit_card_manager:add_ability_to_unit(
	"AK_hobo_glooms", 
	"AK_hobo_spirit_levy"
)

unit_card_manager:add_frontend_unit_for_starting_general(
	"AK_hobo_glooms", 
	"2140783651"
)

-- hide the effects from vanilla
core:add_listener(
    "HideKemmlerEffects",
    "ComponentLClickUp",
	function(context) 
		local uic = UIComponent(context.component)
        return uic:GetProperty("lord_key") == "2140783651"
    end, 
    function(context)
        --local tm = get_tm()
		--tm:callback(function()
		local function do_it()
			local root = core:get_ui_root()
			local parent = find_uicomponent(root, "sp_grand_campaign", "dockers", "centre_docker", "lord_details_panel", "faction", "faction_traits", "effects", "listview", "list_clip", "list_box")
			if is_uicomponent(parent) then
				local kill1 = find_uicomponent(parent, "lord_effect6") kill1:SetVisible(false)
				local kill2 = find_uicomponent(parent, "lord_effect10") kill2:SetVisible(false)
				local kill3 = find_uicomponent(parent, "lord_effect7") kill3:SetVisible(false)
				local kill4 = find_uicomponent(parent, "lord_effect9") kill4:SetVisible(false)
				local kill5 = find_uicomponent(parent, "lord_effect8") kill5:SetVisible(false)
				local kill6 = find_uicomponent(parent, "lord_effect11") kill6:SetVisible(false)
			end
		end

		core:add_listener(
			"trigger_timer",
			"RealTimeTrigger",
			function(context) 
				return context.string == "do_it"
			end,
			function(context)
				do_it()
			end,
			false
		)

		real_timer.register_singleshot("do_it", 0)
        --end, 50)
    end,
    true
)