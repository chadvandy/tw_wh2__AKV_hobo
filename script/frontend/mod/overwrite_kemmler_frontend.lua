local unit_card_manager = core:get_static_object("vandy_unit_card_manager")
--# assume unit_card_manager: VANDY_UCM

-- unit_card_manager:remove_frontend_unit_for_starting_general(
-- 	"wh_main_vmp_mon_dire_wolves", 
-- 	"928012504"
-- )

-- unit_card_manager:remove_frontend_unit_for_starting_general(
-- 	"wh_main_vmp_inf_cairn_wraiths", 
-- 	"928012504"
-- )

-- unit_card_manager:remove_frontend_unit_for_starting_general(
-- 	"wh_main_vmp_cav_hexwraiths", 
-- 	"928012504"
-- )

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
	"928012504"
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
	"928012504"
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
	"928012504"
)

-- TODO remove the vanilla Kemmy, or do something that differentiates between them
ModLog("HELLO THIS IS WORKING.")



-- TODO, trigger a big big big big big big big big error message if the Mixer isn't enabled when initially loading up the game
local function delete_component(uic)
	if not is_uicomponent(uic) then ModLog("You've given me a UIC that isn't a UIC to delete!") return end
	-- local dummy = find_uicomponent("script_dummy")
    -- if not is_uicomponent(dummy) then
	local dummy = core:get_or_create_component("script_dummy", "ui/campaign ui/script_dummy")
    -- end

    if is_uicomponent(uic) then
        dummy:Adopt(uic:Address())
    elseif is_table(uic) then
        for i = 1, #uic do
            local test = uic[i]
            if is_uicomponent(test) then
                dummy:Adopt(test:Address())
            else
                -- ERROR WOOPS
            end
        end
    end

    dummy:DestroyChildren()
end
-- create the actual popup, yay
local function trigger_popup(key, text, two_buttons, button_one_callback, button_two_callback)

    -- verify shit is alright
    if not is_string(key) then
        -- mct:error("trigger_popup() called, but the key passed is not a string!")
        return false
    end

    if is_function(text) then
        text = text()
    end

    if not is_string(text) then
        -- mct:error("trigger_popup() called, but the text passed is not a string!")
        return false
    end

    if is_function(two_buttons) then
        two_buttons = two_buttons()
    end

    if not is_boolean(two_buttons) then
        -- mct:error("trigger_popup() called, but the two_buttons arg passed is not a boolean!")
        return false
    end

    if not two_buttons then button_two_callback = function() end end

    -- build the popup panel itself
    local popup_parent = nil

    -- local frame = self.panel
    -- if is_uicomponent(frame) then
    --     frame:UnLockPriority()
    --     popup_parent = frame
    -- end

    local popup = core:get_or_create_component(key, "ui/kemmler/mct_dialogue")

    local function do_stuff()

        local both_group = UIComponent(popup:CreateComponent("both_group", "ui/campaign ui/script_dummy"))
        local ok_group = UIComponent(popup:CreateComponent("ok_group", "ui/campaign ui/script_dummy"))
        local DY_text = UIComponent(popup:CreateComponent("DY_text", "ui/vandy_lib/text/la_gioconda/center"))

        both_group:SetDockingPoint(8)
        both_group:SetDockOffset(0, 0)

        ok_group:SetDockingPoint(8)
        ok_group:SetDockOffset(0, 0)

        DY_text:SetDockingPoint(5)
        local ow, oh = popup:Width() * 0.9, popup:Height() * 0.8
        DY_text:Resize(ow, oh)
        DY_text:SetDockOffset(1, -35)
        DY_text:SetVisible(true)

        local cancel_img = effect.get_skinned_image_path("icon_cross.png")
        local tick_img = effect.get_skinned_image_path("icon_check.png")

        do
            local button_tick = UIComponent(both_group:CreateComponent("button_tick", "ui/templates/round_medium_button"))
            local button_cancel = UIComponent(both_group:CreateComponent("button_cancel", "ui/templates/round_medium_button"))

            button_tick:SetImagePath(tick_img)
            button_tick:SetDockingPoint(8)
            button_tick:SetDockOffset(-30, -10)
            button_tick:SetCanResizeWidth(false)
            button_tick:SetCanResizeHeight(false)

            button_cancel:SetImagePath(cancel_img)
            button_cancel:SetDockingPoint(8)
            button_cancel:SetDockOffset(30, -10)
            button_cancel:SetCanResizeWidth(false)
            button_cancel:SetCanResizeHeight(false)
        end

        do
            local button_tick = UIComponent(ok_group:CreateComponent("button_tick", "ui/templates/round_medium_button"))

            button_tick:SetImagePath(tick_img)
            button_tick:SetDockingPoint(8)
            button_tick:SetDockOffset(0, -10)
            button_tick:SetCanResizeWidth(false)
            button_tick:SetCanResizeHeight(false)
        end

        popup:PropagatePriority(1000)

        popup:LockPriority()

        -- grey out the rest of the world
        --popup:RegisterTopMost()

        local both_group = find_uicomponent(popup, "both_group")
        local ok_group = find_uicomponent(popup, "ok_group")

        if two_buttons then
            both_group:SetVisible(true)
            ok_group:SetVisible(false)
        else
            both_group:SetVisible(false)
            ok_group:SetVisible(true)
        end

        -- grab and set the text
        local tx = find_uicomponent(popup, "DY_text")

        local w,h = tx:TextDimensionsForText(text)
        tx:ResizeTextResizingComponentToInitialSize(w,h)

        tx:SetStateText(text)

        tx:Resize(ow,oh)
        --w,h = tx:TextDimensionsForText(text)
        tx:ResizeTextResizingComponentToInitialSize(ow,oh)

        core:add_listener(
            key.."_button_pressed",
            "ComponentLClickUp",
            function(context)
                local button = UIComponent(context.component)
                return (button:Id() == "button_tick" or button:Id() == "button_cancel") and UIComponent(UIComponent(button:Parent()):Parent()):Id() == key
            end,
            function(context)
				ModLog("Button pressed")
                local button = UIComponent(context.component)
                
                local id = context.string
                

                -- close the popup
				ModLog("Pre delete")
				local ok, err = pcall(function() delete_component(popup) end) if not ok then ModLog(err) end
                delete_component(find_uicomponent(key))
				ModLog("Post!")

                -- mct:log("button pres'd 3")

                -- local frame = self.panel
                -- mct:log("button pres'd 4")
                -- if is_uicomponent(frame) then
                --     frame:LockPriority()
                -- end

                -- mct:log("button pres'd 5")

                if id == "button_tick" then
                    -- mct:log("button pres'd 6")
                    button_one_callback()
                    -- mct:log("button pres'd 7")
                else
                    -- mct:log("button pres'd 6")
                    button_two_callback()
                    -- mct:log("button pres'd 7")
                end
            end,
            false
        )
    end

    core:add_listener(
        "do_stuff",
        "RealTimeTrigger",
        function(context)
            return context.string == "do_stuff"
        end,
        function(context)
            do_stuff()
        end,
        false
    )

    real_timer.register_singleshot("do_stuff", 5)
end

ModLog("ADDING UI CREATED")
core:add_ui_created_callback(function(context)
	ModLog("Overwrite kemmy frontend")
	if not core:is_mod_loaded("mixu_asspos_frontend") then
		ModLog("No Mixer - erroring!")
		trigger_popup(
			"no_mixu_found",
			"[[col:red]]You HAVE TO USE Mixu's Unlocker to use the Return of the Lichemaster mod nowadays![[/col]]\nMixu's Unlocker is linked as a required item on Return of the Lichemaster's Steam page.\n\nEnjoy!",
			false,
			function() end
		)
	end
end)
ModLog("ADDED UI CREATED")