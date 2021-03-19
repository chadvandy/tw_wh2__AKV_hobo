--- Define the victory conditions! Woop!

return {
    -- Short viccon
    [[
        mission{
            victory_type wh_main_victory_type_short;
            key wh_main_short_victory;
            issuer CLAN_ELDERS;

            primary_objectives_and_payload{
                objective{
                    type OWN_N_REGIONS_INCLUDING;
                    total 5;
                    region wh_main_reikland_altdorf;
                    region wh_main_eastern_sylvania_castle_drakenhof;
                    region wh_main_northern_grey_mountains_blackstone_post;
                }
                objective{
                    type CONSTRUCT_N_BUILDINGS_INCLUDING;
					total 1;
					building_level AK_hobo_throne;
					faction hobo_kemmy;
                }
                objective{
                    type DESTROY_FACTION;
                    faction wh_main_brt_bretonnia;
                    faction wh_dlc05_wef_wood_elves;
                }
                payload{
                    game_victory;
                }
            }
        }
    ]],

    -- Long viccon
    [[
        mission{
            victory_type wh_main_victory_type_long;
            key wh_main_long_victory;
            issuer CLAN_ELDERS;

            primary_objectives_and_payload{
                objective{
                    type OWN_N_REGIONS_INCLUDING;
                    total 11;
                    region wh2_main_albion_albion;
                    region wh2_main_iron_mountains_altar_of_ultimate_darkness;
                    region wh_main_reikland_altdorf;
                    region wh_main_couronne_et_languille_couronne;
                    region wh_main_eastern_sylvania_castle_drakenhof;
                    region wh_main_northern_grey_mountains_blackstone_post;
                    region wh_main_southern_badlands_galbaraz;
                    region wh2_main_the_chill_road_ghrond;
                    region wh2_main_devils_backbone_lahmia;
                    region wh2_main_great_mortis_delta_black_pyramid_of_nagash;
                    region wh2_main_the_broken_teeth_nagashizar;
                }
                objective{
                    type CONSTRUCT_N_BUILDINGS_INCLUDING;
					total 1;
					building_level AK_hobo_throne;
					faction hobo_kemmy;
                }
                objective{
                    type DESTROY_FACTION;
                    faction wh_main_brt_bretonnia;
                    faction wh_dlc05_wef_wood_elves;
                }
                payload{
                    game_victory;
                }
            }
        }
    ]],
}