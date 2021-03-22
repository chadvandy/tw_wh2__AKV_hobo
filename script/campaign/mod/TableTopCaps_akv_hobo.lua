--adds new units to Drunk Flamingo's TT-based unit caps script


local rm = _G.rm;


    local hobo_units = {
        {"AK_hobo_skeleton_swords", "kem_core"},
        {"AK_hobo_skeleton_spears", "kem_core"},
        {"AK_hobo_skeleton_2h", "kem_core"},
        {"AK_hobo_skeleton_lobber", "kem_core"},
        {"AK_hobo_barrow_guardians", "kem_special", 1},
        {"AK_hobo_barrow_guardians_dual", "kem_special", 1},
        {"AK_hobo_barrow_guardians_halb", "kem_special", 1},
        {"AK_hobo_simulacra", "kem_core"},
        {"AK_hobo_embalmed", "kem_special", 1},
        {"AK_hobo_glooms", "kem_rare", 1},
        {"AK_hobo_ghost", "kem_core"},
        {"AK_hobo_horsemen", "kem_special", 1},
        {"AK_hobo_horsemen_lances", "kem_special", 1},
        {"AK_hobo_stalker", "kem_rare", 2},
        {"AK_hobo_dragon", "kem_rare", 3},
        {"AK_hobo_cairn", "kem_rare", 1},
        {"AK_hobo_hexwr", "kem_special", 2},
        {"AK_hobo_mortis_engine", "kem_rare", 3},
        {"AK_hobo_terrorgheist", "kem_rare", 3}
    }
    

local main_unit_to_land_units = {
["AK_hobo_cairn"] = "wh_main_vmp_inf_cairn_wraiths",
["AK_hobo_hexwr"] = "wh_main_vmp_cav_hexwraiths",
["AK_hobo_mortis_engine"] = "wh_dlc04_vmp_veh_mortis_engine_0",
["AK_hobo_terrorgheist"] = "wh_main_vmp_mon_terrorgheist"
                                                --WATCH THE COMMA
}
    
if not not rm then
    rm:add_units_in_table_to_tabletop_groups(hobo_units)
    --rm:add_loaned_units_in_table(hobo_loaned_units)
	rm:add_post_setup_callback(function()
        for main_unit_key, land_unit_key in pairs(main_unit_to_land_units) do
            rm:get_unit(main_unit_key):set_land_unit(land_unit_key)
        end
    end)
end



