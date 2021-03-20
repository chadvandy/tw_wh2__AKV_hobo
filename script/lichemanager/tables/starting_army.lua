---- This table defines the units that Kemmy begins a new game with! And other stuff!

---@class kemmy_starting_units
return {
    -- List of units Kemmy starts off with. No agents! main_units
    units = {
        "AK_hobo_skeleton_2h",
        "AK_hobo_skeleton_spears",
        "AK_hobo_skeleton_spears",
        "AK_hobo_hexwr",
        "AK_hobo_barrow_guardians",
        "AK_hobo_glooms",
        "AK_hobo_simulacra",
    },
    -- Buildings that Kemmy starts with, building_levels
    buildings = {
        "AK_hobo_ruination_1",
        "AK_hobo_recr1_1",
    },
    -- X/Y coords to try and spawn them at
    loc = {
        423,
        429,
    },
    region = "wh_main_forest_of_arden_gisoreux",
}