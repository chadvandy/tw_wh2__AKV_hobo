-- spawn deets!
--# type SUBTYPE = {
--# forename: string,
--# family_name: string,
--# clan_name: string,
--# other_name: string,
--# age: int,
--# is_male: boolean,
--# agent_type: string,
--# agent_subtype: string,
--# is_immortal: boolean,
--# art_set_id: string,
--# ancillary1: string?,
--# ancillary2: string?
--# }

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
        ["art_set_id"] = "AK_hobo_nameless"
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
        ["ancillary1"] = "AK_hobo_draesca_helmet"
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
        ["ancillary1"] = "AK_hobo_priestess_trickster",
        ["ancillary2"] = "AK_hobo_priestess_charms"
    }
} --: map<string, SUBTYPE>

return subtypes