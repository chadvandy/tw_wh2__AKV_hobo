-- details for the RoR panel

local texts = {
    -- UI bullet points for the RoR panel!
    ["AK_hobo_ror_doomed_legion"] = {"{{tr:AK_hobo_units_risen}}", "{{tr:AK_hobo_ror_doomed_legion}}", "{{tr:AK_hobo_ror_doomed_legion_quickie}}"},
    ["AK_hobo_ror_caged"] = {"{{tr:AK_hobo_units_barrow}}", "{{tr:AK_hobo_ror_caged}}", "{{tr:AK_hobo_ror_caged_quickie}}"},
    ["AK_hobo_ror_storm"] = {"{{tr:AK_hobo_units_barrow}}", "{{tr:AK_hobo_ror_storm}}", "{{tr:AK_hobo_ror_storm_quickie}}"},
    ["AK_hobo_ror_wight_knights"] = {"{{tr:AK_hobo_units_risen}}", "{{tr:AK_hobo_ror_wight_knights}}", "{{tr:AK_hobo_ror_wight_knights_quickie}}"},
    ["AK_hobo_ror_jacsen"] = {"{{tr:AK_hobo_units_risen}}", "{{tr:AK_hobo_ror_jacsen}}", "{{tr:AK_hobo_ror_jacsen_quickie}}"},
    ["AK_hobo_ror_beast"] = {"{{tr:AK_hobo_units_barrow}}", "{{tr:AK_hobo_ror_beast}}", "{{tr:AK_hobo_ror_beast_quickie}}"},
    ["AK_hobo_ror_skulls"] = {"{{tr:AK_hobo_units_risen}}", "{{tr:AK_hobo_ror_skulls}}", "{{tr:AK_hobo_ror_skulls_quickie}}"},
    ["AK_hobo_ror_spider"] = {"{{tr:AK_hobo_units_risen}}", "{{tr:AK_hobo_ror_spider}}", "{{tr:AK_hobo_ror_spider_quickie}}"}
}--: map<string, vector<string>>

return {texts}






--[[ ANTIQUATED FROM THE ORIGINAL IDEA TO INCLUDE A UNIT INFO SHEET ]]
--[[ KEPT HERE IN ORDER TO REFER BACK IN THE FUTURE, IF WANTED      ]]


--[[

local stats = {
    -- armour // leadership // speed // melee attack // melee defence // weapon strength // charge bonus //
    -- RANGED ONLY: ammo // range // missile damage
    ["AK_hobo_ror_doomed_legion"] = {90, 65, 27, 36, 46, 32, 8},
    ["AK_hobo_ror_caged"] = {20, 40, 31, 20, 21, 26, 3, 22, 160, 34},
    ["AK_hobo_ror_storm"] = {90, 85, 70, 32, 51, 110, 26},
    ["AK_hobo_ror_wight_knights"] = {0, 50, 105, 29, 31, 40, 62}
}--: map<string, vector<number>>

local icons = {
    -- bottom icons, in order
    ["AK_hobo_ror_doomed_legion"] = {""},
    ["AK_hobo_ror_caged"] = {""},
    ["AK_hobo_ror_storm"] = {""},
    ["AK_hobo_ror_wight_knights"] = {""}
}--: map<string, vector<string>>

local text = {
    -- unit bulletpoints, in order
    ["AK_hobo_ror_doomed_legion"] = {"Armoured & Shielded", "Anti-Infantry", "Causes Terror"},
    ["AK_hobo_ror_caged"] = {""},
    ["AK_hobo_ror_storm"] = {""},
    ["AK_hobo_ror_wight_knights"] = {"Ethereal", "Vanguard Deployment", "Causes Terror"}
}--: map<string, vector<string>>

local unitCat = {
    -- UI category name // UI category icon
    ["AK_hobo_ror_doomed_legion"] = {"Axe Infantry"},
    ["AK_hobo_ror_caged"] = {""},
    ["AK_hobo_ror_storm"] = {""},
    ["AK_hobo_ror_wight_knights"] = {"Flying Cavalry", }
}--: map<string, vector<string>>

local upkeep = {
    -- num men // upkeep // health
    ["AK_hobo_ror_doomed_legion"] = {"90", "258", "7380"},
    ["AK_hobo_ror_caged"] = {""},
    ["AK_hobo_ror_storm"] = {""},
    ["AK_hobo_ror_wight_knights"] = {"45", "371", "4320"}
}--: map<string, vector<string>>
]]