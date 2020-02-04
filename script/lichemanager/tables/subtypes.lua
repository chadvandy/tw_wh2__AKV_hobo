-- spawn deets!

local subtypes = {
    ["AK_hobo_nameless"] = {
        ["forename"] = "names_name_666777891",
        ["family_name"] = "names_name_666777892",
        ["clan_name"] = "",
        ["other_name"] = "", 
        ["age"] = 50, 
        ["is_male"] = true, 
        ["agent_type"] = "general",
        ["agent_subtype"] = "AK_hobo_nameless",
        ["is_immortal"] = true, 
        ["art_set_id"] = "AK_hobo_nameless",
        ["ancillaries"] = {}
    },
    ["AK_hobo_draesca"] = {
        ["forename"] = "names_name_666777893",
        ["family_name"] = "names_name_666777894",
        ["clan_name"] = "",
        ["other_name"] = "", 
        ["age"] = 50, 
        ["is_male"] = true, 
        ["agent_type"] = "general",
        ["agent_subtype"] = "AK_hobo_draesca",
        ["is_immortal"] = true, 
        ["art_set_id"] = "AK_hobo_draesca",
        ["ancillaries"] = {"AK_hobo_draesca_helmet"}
    },
    ["AK_hobo_priestess"] = {
        ["forename"] = "names_name_666777895",
        ["family_name"] = "names_name_666777896",
        ["clan_name"] = "",
        ["other_name"] = "", 
        ["age"] = 50, 
        ["is_male"] = true, 
        ["agent_type"] = "general",
        ["agent_subtype"] = "AK_hobo_priestess",
        ["is_immortal"] = true, 
        ["art_set_id"] = "AK_hobo_priestess",
        ["ancillaries"] = {"AK_hobo_priestess_trickster", "AK_hobo_priestess_charms"}
    }
} --: map<string, LICHE_SUBTYPE>

return subtypes