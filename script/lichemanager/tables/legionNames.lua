-- used for agent spawns!

local forenames = {
    "names_name_1406951171",
    "names_name_1768171990",
    "names_name_1880091843",
    "names_name_1928172943",
    "names_name_1966785637",
    "names_name_2147345100",
    "names_name_2147345109",
    "names_name_2147345117",
    "names_name_2147345149",
    "names_name_2147345161",
    "names_name_2147345165",
    "names_name_2147345166",
    "names_name_2147345180",
    "names_name_2147345200",
    "names_name_2147345209",
    "names_name_2147345217",
    "names_name_2147345230",
    "names_name_2147345239",
    "names_name_2147345257",
    "names_name_2147345260",
    "names_name_2147345266",
    "names_name_2147345279",
    "names_name_2147345281",
    "names_name_2147345303",
    "names_name_2147345862",
    "names_name_2147345872",
    "names_name_2147357264",
    "names_name_2147357272",
    "names_name_2147357278",
    "names_name_2147357284",
    "names_name_2147357289",
    "names_name_2147357295",
    "names_name_2147357301",
    "names_name_2147357304",
    "names_name_2147357306",
    "names_name_2147357315",
    "names_name_2147357322",
    "names_name_2147357330",
    "names_name_2147357531",
    "names_name_2147357577",
    "names_name_2147357583",
    "names_name_2147357593",
    "names_name_2147357595",
    "names_name_2147357596",
    "names_name_2147357905",
    "names_name_2147357909",
    "names_name_2147357911",
    "names_name_2147357919",
    "names_name_2147357925",
    "names_name_2147357928",
    "names_name_2147357935",
    "names_name_2147357949",
    "names_name_2147357952",
    "names_name_2147357970",
    "names_name_2147357974",
    "names_name_2147357977",
    "names_name_2147357980",
    "names_name_2147357990",
    "names_name_2147357991",
    "names_name_2147357994",
    "names_name_2147358006",
    "names_name_2147358011",
    "names_name_2147358022",
    "names_name_2147358030",
    "names_name_2147358038",
    "names_name_2147358047",
    "names_name_2147358057",
    "names_name_2147358063",
    "names_name_2147358070",
    "names_name_2147358072",
    "names_name_2147358074",
    "names_name_2147358076",
    "names_name_2147358083",
    "names_name_2147358089",
    "names_name_2147358096",
    "names_name_2147358103",
    "names_name_2147358110",
    "names_name_2147358113",
    "names_name_2147358121",
    "names_name_2147358122",
    "names_name_2147358126",
    "names_name_2147358136",
    "names_name_2147358140",
    "names_name_2147358143",
    "names_name_2147358144",
    "names_name_2147358148",
    "names_name_2147358157",
    "names_name_2147358165",
    "names_name_2147358170",
    "names_name_2147358174",
    "names_name_2147358184",
    "names_name_2147358193",
    "names_name_2147358194",
    "names_name_2147358199",
    "names_name_2147358201",
    "names_name_2147358210",
    "names_name_2147358220",
    "names_name_2147358224",
    "names_name_2147358230",
    "names_name_2147358234",
    "names_name_2147358241",
    "names_name_2147358243",
    "names_name_2147358244",
    "names_name_2147358248",
    "names_name_2147358254",
    "names_name_2147358259",
    "names_name_2147358260",
    "names_name_2147358265",
    "names_name_2147358275",
    "names_name_2147358279",
    "names_name_2147358289",
    "names_name_2147358298",
    "names_name_2147358299",
    "names_name_2147358304",
    "names_name_2147358305",
    "names_name_2147358308",
    "names_name_2147358310",
    "names_name_2147358319",
    "names_name_2147358324",
    "names_name_677402052",
    "names_name_79061478"    
} --: vector < string >

local family_names = {
    "names_name_1003038241",
    "names_name_1041741800",
    "names_name_1064541212",
    "names_name_1090640497",
    "names_name_1139217754",
    "names_name_1199231259",
    "names_name_1227554475",
    "names_name_1238864252",
    "names_name_1305581408",
    "names_name_1323396643",
    "names_name_168545332",
    "names_name_1702107794",
    "names_name_1777692413",
    "names_name_2012155459",
    "names_name_2051685651",
    "names_name_2147345093",
    "names_name_2147345151",
    "names_name_2147345172",
    "names_name_2147345224",
    "names_name_2147345237",
    "names_name_2147345247",
    "names_name_2147345271",
    "names_name_2147345290",
    "names_name_2147345294",
    "names_name_2147352928",
    "names_name_2147357525",
    "names_name_26926004",
    "names_name_378511030",
    "names_name_463976820",
    "names_name_522579314",
    "names_name_680207862",
    "names_name_693999515",
    "names_name_722999650",
    "names_name_817148109",
    "names_name_86899705",
    "names_name_943406012"
} --: vector < string >

return { forenames, family_names }