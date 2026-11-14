/**
 *           __             __
 *          |  \           |  |
 *      ____| $$  ______  _| $$_     ______
 *     /      $$ |      \|   $$ \   |      |
 *    |  $$$$$$$  \$$$$$$\\$$$$$$    \$$$$$$|
 *    | $$  | $$ /      $$ | $$ __  /      $$
 *    | $$__| $$|  $$$$$$$ | $$|  \|  $$$$$$$
 *     \$$    $$ \$$    $$  \$$  $$ \$$    $$
 *      \$$$$$$$  \$$$$$$$   \$$$$   \$$$$$$$
 *
 */
#define ROAD_COUNT (58)
#define ROAD_MATERIAL_COUNT (209)

enum e_ROAD
{
    E_ROAD_MODEL,
    Float:E_ROAD_X,
    Float:E_ROAD_Y,
    Float:E_ROAD_Z,
    Float:E_ROAD_RX,
    Float:E_ROAD_RY,
    Float:E_ROAD_RZ,
    bool:E_ROAD_STATIC
}

enum e_ROAD_MATERIAL
{
    E_ROAD_MATERIAL_OBJECT,
    E_ROAD_MATERIAL_INDEX,
    E_ROAD_MATERIAL_MODEL,
    E_ROAD_MATERIAL_TXD[24],
    E_ROAD_MATERIAL_TEXTURE[32],
    E_ROAD_MATERIAL_COLOUR
}

static const s_Roads[ROAD_COUNT][e_ROAD] =
{
    {11430,-801.14838,698.93750,9.13177,0.00000,0.00000,0.00000,true},
    {11537,-847.16412,852.28912,12.18120,0.00000,0.00000,0.00000,true},
    {11557,-802.53131,1070.78125,25.37006,0.00000,0.00000,0.00000,true},
    {11536,-1023.64838,1088.18750,19.46683,0.00000,0.00000,0.00000,true},
    {11560,-614.15631,1083.82813,6.37180,0.00000,0.00000,0.00000,true},
    {11559,-648.76563,1299.39063,-2.93290,0.00000,0.00000,0.00000,true},
    {11535,-806.50781,1310.53125,7.22370,0.00000,0.00000,0.00000,true},
    {11534,-1009.28131,1255.65625,20.10340,0.00000,0.00000,0.0000,true},
    {11542,-1016.78912,1372.00781,21.16580,0.00000,0.00000,0.00000,true},
    {11555,-981.32031,1473.06250,29.66460,0.00000,0.00000,0.00000,true},
    {11553,-1211.30469,1545.18750,3.69650,0.00000,0.00000,0.00000,true},
    {11532,-779.90631,1535.17188,28.40361,0.00000,0.00000,0.00000,true},
    {11554,-974.47662,1596.50000,3.91840,0.00000,0.00000,0.00000,true},
    {11531,-947.52344,1750.87500,25.67,0.00000,0.00000,0.00000,true},
    {11552,-1175.67969,1740.92969,36.69624,0.00000,0.00000,0.00000,true},
    {11526,-1248.97656,1934.34375,81.40842,0.00000,0.00000,0.00000,true},
    {11522,-1283.52344,2173.95313,77.01682,0.00000,0.00000,0.00000,true},
    {11517,-1303.70,2382.11,102.92,0.00000,0.00000,0.00000,true},
    {11516,-1543.91406,2386.89844,54.71580,0.00000,0.00000,0.00000,true},
    {11511,-1489.72656,2617.60156,69.08891,0.00000,0.00000,0.00000,true},
    {11512,-1251.07813,2622.30469,73.83083,0.00000,0.00000,0.00000,true},
    {11510,-1720.34375,2615.95313,82.02,0.00000,0.00000,0.00000,true},
    {11515,-1757.03125,2385.03125,52.30608,0.00000,0.00000,0.00000,true},
    {11530,-1408.73438,1726.65625,8.88186,0.00000,0.00000,0.00000,true},
    {11525,-1489.46875,1930.00781,34.83909,0.00000,0.00000,0.00000,true},
    {11529,-1648.618,1748.61719,1.44,0.00000,0.00000,0.00000,true},
    {11524,-1731.61719,1916.03906,8.02569,0.00000,0.00000,0.00000,true},
    {11520,-1724.67969,2147.22656,21.18647,0.00000,0.00000,0.00000,true},
    {11519,-1946.6500,2153.9500,3.8293,0.00000,0.00000,0.00000,true},
    {11509,-1938.18750,2600.16063,93.08325,0.00000,0.00000,0.00000,true},
    {11514,-1979.61719,2361.43750,36.76798,0.00000,0.00000,0.00000,true},
    {11528,-866.399,1929.03125,50.30,0.00000,0.00000,0.00000,true},
    {11539,-794.81813,2025.43750,31.34355,0.00000,0.00000,0.00000,true},
    {11540,-615.36060,2028.43237,31.37373,0.00000,0.00000,0.00000,true},
    {11527,-1021.02344,1958.82813,65.74234,0.00000,0.00000,0.00000,true},
    {11628,-2142.07031,2593.13281,82.80799,0.00000,0.00000,0.00000,true},
    {9267,-2329.75000,2654.57031,55.64497,0.00000,0.00000,0.00000,true},
    {9266,-2479.17969,2641.55469,61.77779,0.00000,0.00000,0.00000,true},
    {9264,-2657.78906,2535.45313,69.01968,0.00000,0.00000,0.00000,true},
    {9265,-2674.17969,2576.99219,83.08440,0.00000,0.00000,0.00000,true},
    {9476,-2750.64063,2393.84375,79.97660,0.00000,0.00000,0.00000,true},
    {9262,-2717.78125,2249.25781,61.51371,0.00000,0.00000,0.00000,true},
    {9231,-2688.62500,2421.92188,51.27766,0.00000,0.00000,0.00000,true},
    {9250,-2580.87500,2471.77344,23.64446,0.00000,0.00000,0.00000,true},
    {9251,-2524.92969,2342.88281,9.79671,0.00000,0.00000,0.00000,true},
    {9232,-2391.11719,2354.72656,4.38696,0.00000,0.00000,0.00000,true},
    {9233,-2584.56250,2359.71875,8.86685,0.00000,0.00000,0.00000,true},
    {9205,-2482.16333,2334.22974,9.76450,0.00000,0.00000,0.00000,true},
    {9252,-2399.46875,2404.75000,10.12806,0.00000,0.00000,0.00000,true},
    {9222,-2276.53906,2330.14844,4.23177,0.00000,0.00000,0.00000,true},
    {9254,-2463.66406,2234.03906,4.38688,0.00000,0.00000,0.00000,false},
    {9230,-2413.23438,2249.65625,-19.07030,0.00000,0.00000,0.00000,true},
    {9257,-2545.82031,2225.85156,-19.11720,0.00000,0.00000,0.00000,true},
    {9255,-2614.08594,2259.29688,6.14060,0.00000,0.00000,0.00000,true},
    {9351,-2592.34375,2246.07031,3.98440,0.00000,0.00000,0.00000,true},
    {9329,-2329.55469,2284.57813,-19.07030,0.00000,0.00000,0.00000,true},
    {9253,-2218.27344,2359.90625,-19.09380,0.00000,0.00000,44.30000,true},
    {9229,-2284.35156,2460.60156,-19.09380,0.00000,0.00000,0.00000,true}
};

static const s_RoadMaterials[ROAD_MATERIAL_COUNT][e_ROAD_MATERIAL] =
{
    {0,6,8538,"vgsrailroad","des_dirt1",0},
    {0,7,8538,"vgsrailroad","des_dirt1",0},
    {0,8,16202,"des_cen","des_dirttrack1",0},
    {1,2,16202,"des_cen","des_dirttrack1",0},
    {1,3,8538,"vgsrailroad","des_dirt1",0},
    {1,5,8538,"vgsrailroad","des_dirt1",0},
    {1,6,8538,"vgsrailroad","des_dirt1",0},
    {2,2,16202,"des_cen","des_dirttrack1",0},
    {2,5,8538,"vgsrailroad","des_dirt1",0},
    {2,7,8538,"vgsrailroad","des_dirt1",0},
    {3,2,16202,"des_cen","des_dirttrack1",0},
    {3,3,8538,"vgsrailroad","des_dirt1",0},
    {3,6,8538,"vgsrailroad","des_dirt1",0},
    {3,7,8538,"vgsrailroad","des_dirt1",0},
    {3,10,16202,"des_cen","des_dirttrack1",0},
    {4,0,16202,"des_cen","des_dirttrack1",0},
    {5,2,16202,"des_cen","des_dirttrack1",0},
    {6,2,16202,"des_cen","des_dirttrack1",0},
    {6,3,16202,"des_cen","des_dirttrack1",0},
    {6,6,8538,"vgsrailroad","des_dirt1",0},
    {7,1,8538,"vgsrailroad","des_dirt1",0},
    {7,2,8538,"vgsrailroad","des_dirt1",0},
    {7,3,16202,"des_cen","des_dirttrack1",0},
    {7,6,8538,"vgsrailroad","des_dirt1",0},
    {7,7,8538,"vgsrailroad","des_dirt1",0},
    {7,8,16202,"des_cen","des_dirttrack1",0},
    {7,9,16202,"des_cen","des_dirttrack1",0},
    {7,10,16202,"des_cen","des_dirttrack1",0},
    {8,3,16202,"des_cen","des_dirttrack1",0},
    {8,5,8538,"vgsrailroad","des_dirt1",0},
    {8,6,16202,"des_cen","des_dirttrack1",0},
    {8,7,8538,"vgsrailroad","des_dirt1",0},
    {8,8,8538,"vgsrailroad","des_dirt1",0},
    {8,10,16202,"des_cen","des_dirttrack1",0},
    {9,5,8538,"vgsrailroad","des_dirt1",0},
    {9,6,8538,"vgsrailroad","des_dirt1",0},
    {9,7,16202,"des_cen","des_dirttrack1",0},
    {10,4,16202,"des_cen","des_dirttrack1",0},
    {10,5,8538,"vgsrailroad","des_dirt1",0},
    {10,6,8538,"vgsrailroad","des_dirt1",0},
    {11,2,16202,"des_cen","des_dirttrack1",0},
    {11,3,8538,"vgsrailroad","des_dirt1",0},
    {11,6,8538,"vgsrailroad","des_dirt1",0},
    {11,7,8538,"vgsrailroad","des_dirt1",0},
    {11,8,8538,"vgsrailroad","des_dirt1",0},
    {11,9,8538,"vgsrailroad","des_dirt1",0},
    {11,10,8538,"vgsrailroad","des_dirt1",0},
    {11,15,8538,"vgsrailroad","des_dirt1",0},
    {12,0,16202,"des_cen","des_dirttrack1",0},
    {12,9,8538,"vgsrailroad","des_dirt1",0},
    {12,10,8538,"vgsrailroad","des_dirt1",0},
    {13,3,16202,"des_cen","des_dirttrack1",0},
    {13,0,8538,"vgsrailroad","des_dirt1",0},
    {14,6,16202,"des_cen","des_dirttrack1",0},
    {14,7,16202,"des_cen","des_dirttrack1",0},
    {14,9,8538,"vgsrailroad","des_dirt1",0},
    {14,10,8538,"vgsrailroad","des_dirt1",0},
    {14,13,16202,"des_cen","des_dirttrack1",0},
    {15,6,16202,"des_cen","des_dirttrack1",0},
    {15,9,8538,"vgsrailroad","des_dirt1",0},
    {15,8,8538,"vgsrailroad","des_dirt1",0},
    {16,8,16202,"des_cen","des_dirttrack1",0},
    {17,2,16202,"des_cen","des_dirttrack1",0},
    {18,7,16202,"des_cen","des_dirttrack1",0},
    {19,4,16202,"des_cen","des_dirttrack1",0},
    {19,6,8538,"vgsrailroad","des_dirt1",0},
    {19,7,8538,"vgsrailroad","des_dirt1",0},
    {19,13,8538,"vgsrailroad","des_dirt1",0},
    {19,14,8538,"vgsrailroad","des_dirt1",0},
    {20,1,16202,"des_cen","des_dirttrack1",0},
    {20,9,8538,"vgsrailroad","des_dirt1",0},
    {20,13,8538,"vgsrailroad","des_dirt1",0},
    {20,14,8538,"vgsrailroad","des_dirt1",0},
    {20,15,8538,"vgsrailroad","des_dirt1",0},
    {21,8,16202,"des_cen","des_dirttrack1",0},
    {21,11,8538,"vgsrailroad","des_dirt1",0},
    {21,7,8538,"vgsrailroad","des_dirt1",0},
    {22,4,16202,"des_cen","des_dirttrack1",0},
    {22,5,16202,"des_cen","des_dirttrack1",0},
    {22,7,8538,"vgsrailroad","des_dirt1",0},
    {22,8,8538,"vgsrailroad","des_dirt1",0},
    {23,4,16202,"des_cen","des_dirttrack1",0},
    {23,5,8538,"vgsrailroad","des_dirt1",0},
    {23,6,8538,"vgsrailroad","des_dirt1",0},
    {24,3,16202,"des_cen","des_dirttrack1",0},
    {24,4,16202,"des_cen","des_dirttrack1",0},
    {24,6,8538,"vgsrailroad","des_dirt1",0},
    {24,7,8538,"vgsrailroad","des_dirt1",0},
    {24,14,8538,"vgsrailroad","des_dirt1",0},
    {24,15,8538,"vgsrailroad","des_dirt1",0},
    {25,4,16202,"des_cen","des_dirttrack1",0},
    {25,5,8538,"vgsrailroad","des_dirt1",0},
    {25,6,8538,"vgsrailroad","des_dirt1",0},
    {26,2,8538,"vgsrailroad","des_dirt1",0},
    {26,4,16202,"des_cen","des_dirttrack1",0},
    {26,5,16202,"des_cen","des_dirttrack1",0},
    {26,6,8538,"vgsrailroad","des_dirt1",0},
    {26,7,8538,"vgsrailroad","des_dirt1",0},
    {27,8,8538,"vgsrailroad","des_dirt1",0},
    {27,5,16202,"des_cen","des_dirttrack1",0},
    {27,6,16202,"des_cen","des_dirttrack1",0},
    {27,7,8538,"vgsrailroad","des_dirt1",0},
    {28,4,8538,"vgsrailroad","des_dirt1",0},
    {28,5,8538,"vgsrailroad","des_dirt1",0},
    {28,2,16202,"des_cen","des_dirttrack1",0},
    {28,3,16202,"des_cen","des_dirttrack1",0},
    {29,1,8538,"vgsrailroad","des_dirt1",0},
    {29,6,11509,"des_nw2","des_grass2dirt1",0},
    {29,2,16202,"des_cen","des_dirttrack1",0},
    {29,7,16202,"des_cen","des_dirttrack1",0},
    {29,8,8538,"vgsrailroad","des_dirt1",0},
    {29,9,8538,"vgsrailroad","des_dirt1",0},
    {30,5,16202,"des_cen","des_dirttrack1",0},
    {30,6,8538,"vgsrailroad","des_dirt1",0},
    {30,7,8538,"vgsrailroad","des_dirt1",0},
    {30,0,8538,"vgsrailroad","des_dirt1",0},
    {30,1,16202,"des_cen","des_dirttrack1",0},
    {30,9,8538,"vgsrailroad","des_dirt1",0},
    {31,8,8538,"vgsrailroad","des_dirt1",0},
    {31,7,8538,"vgsrailroad","des_dirt1",0},
    {31,6,16202,"des_cen","des_dirttrack1",0},
    {31,5,8538,"vgsrailroad","des_dirt1",0},
    {31,4,8538,"vgsrailroad","des_dirt1",0},
    {32,0,8839,"vgsecarshow","sw_wallbrick_06",0},
    {32,1,8839,"vgsecarshow","sw_wallbrick_06",0},
    {32,2,16202,"des_cen","des_dirttrack1",0},
    {32,3,8839,"vgsecarshow","sw_wallbrick_06",0},
    {32,4,8839,"vgsecarshow","sw_wallbrick_06",0},
    {32,5,8839,"vgsecarshow","sw_wallbrick_06",0},
    {32,6,8839,"vgsecarshow","sw_wallbrick_06",0},
    {33,0,8839,"vgsecarshow","sw_wallbrick_06",0},
    {33,1,8839,"vgsecarshow","sw_wallbrick_06",0},
    {33,2,16202,"des_cen","des_dirttrack1",0},
    {33,3,8839,"vgsecarshow","sw_wallbrick_06",0},
    {33,4,8839,"vgsecarshow","sw_wallbrick_06",0},
    {33,5,8839,"vgsecarshow","sw_wallbrick_06",0},
    {33,6,8839,"vgsecarshow","sw_wallbrick_06",0},
    {34,3,8538,"vgsrailroad","des_dirt1",0},
    {34,4,8538,"vgsrailroad","des_dirt1",0},
    {34,5,8538,"vgsrailroad","des_dirt1",0},
    {35,1,8538,"vgsrailroad","des_dirt1",0},
    {35,3,16202,"des_cen","des_dirttrack1",0},
    {36,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {36,0,8868,"vgsecnstrct02","desmudtrail",0},
    {37,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {37,0,8868,"vgsecnstrct02","desmudtrail",0},
    {38,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {38,0,8868,"vgsecnstrct02","desmudtrail",0},
    {39,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {39,0,8868,"vgsecnstrct02","desmudtrail",0},
    {40,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {40,0,8868,"vgsecnstrct02","desmudtrail",0},
    {40,2,8868,"vgsecnstrct02","desmudtrail",0},
    {40,3,8868,"vgsecnstrct02","desmudtrail",0},
    {41,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {41,0,8868,"vgsecnstrct02","desmudtrail",0},
    {42,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {42,0,8868,"vgsecnstrct02","desmudtrail",0},
    {43,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {43,0,8868,"vgsecnstrct02","desmudtrail",0},
    {44,1,8868,"vgsecnstrct02","desmudtrail",0},
    {44,2,11509,"des_nw2","rocktbrn128blndlit",0},
    {44,3,8868,"vgsecnstrct02","desmudtrail",0},
    {45,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {45,0,8868,"vgsecnstrct02","desmudtrail",0},
    {46,0,8868,"vgsecnstrct02","desmudtrail",0},
    {46,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {46,3,8868,"vgsecnstrct02","desmudtrail",0},
    {47,0,8868,"vgsecnstrct02","desmudtrail",0},
    {47,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {47,3,8868,"vgsecnstrct02","desmudtrail",0},
    {48,0,8868,"vgsecnstrct02","desmudtrail",0},
    {48,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {48,2,11509,"des_nw2","rocktbrn128blndlit",0},
    {48,3,8868,"vgsecnstrct02","desmudtrail",0},
    {49,0,8868,"vgsecnstrct02","desmudtrail",0},
    {49,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {49,2,8868,"vgsecnstrct02","desmudtrail",0},
    {49,3,8868,"vgsecnstrct02","desmudtrail",0},
    {49,4,8868,"vgsecnstrct02","desmudtrail",0},
    {50,0,11509,"des_nw2","rocktbrn128blndlit",0},
    {50,2,8868,"vgsecnstrct02","desmudtrail",0},
    {50,3,8868,"vgsecnstrct02","desmudtrail",0},
    {50,4,8868,"vgsecnstrct02","desmudtrail",0},
    {51,0,916,"crates_n_stuffext","CJ_SLATEDWOOD",0},
    {51,1,13731,"mulveg2lahills","des_woodfence1",0xFFFFFFFF},
    {51,3,1463,"BREAK_FARM","CJ_DarkWood",0},
    {51,4,916,"crates_n_stuffext","CJ_SLATEDWOOD",0},
    {52,0,13731,"mulveg2lahills","des_woodfence1",0xFFFFFFFF},
    {52,2,1463,"BREAK_FARM","CJ_DarkWood",0},
    {52,3,916,"crates_n_stuffext","CJ_SLATEDWOOD",0},
    {53,1,11509,"des_nw2","rocktbrn128blndlit",0},
    {53,2,8868,"vgsecnstrct02","desmudtrail",0},
    {53,3,916,"crates_n_stuffext","CJ_SLATEDWOOD",0},
    {54,0,916,"crates_n_stuffext","CJ_SLATEDWOOD",0},
    {55,0,916,"crates_n_stuffext","CJ_SLATEDWOOD",0},
    {55,1,916,"crates_n_stuffext","CJ_SLATEDWOOD",0},
    {55,2,13731,"mulveg2lahills","des_woodfence1",0xFFFFFFFF},
    {55,3,916,"crates_n_stuffext","CJ_SLATEDWOOD",0},
    {55,4,1463,"BREAK_FARM","CJ_DarkWood",0},
    {55,5,916,"crates_n_stuffext","CJ_SLATEDWOOD",0},
    {56,0,916,"crates_n_stuffext","CJ_SLATEDWOOD",0},
    {56,1,13731,"mulveg2lahills","des_woodfence1",0xFFFFFFFF},
    {56,3,1463,"BREAK_FARM","CJ_DarkWood",0},
    {56,4,916,"crates_n_stuffext","CJ_SLATEDWOOD",0},
    {57,0,916,"crates_n_stuffext","CJ_SLATEDWOOD",0},
    {57,1,13731,"mulveg2lahills","des_woodfence1",0xFFFFFFFF},
    {57,3,1463,"BREAK_FARM","CJ_DarkWood",0},
    {57,4,916,"crates_n_stuffext","CJ_SLATEDWOOD",0}
};

static STREAMER_TAG_OBJECT:s_RoadObjects[ROAD_COUNT];

/**
 *      ______                                   __      __
 *     /      \                                 |  \    |  |
 *    |  $$$$$$\ __    __  _______    _______  _| $$_    \$$  ______   _______    _______
 *    | $$_  \$$|  \  |  \|       \  /       \|   $$ \  |  \ /      \ |       \  /       |
 *    | $$ \    | $$  | $$| $$$$$$$\|  $$$$$$$ \$$$$$$  | $$|  $$$$$$\| $$$$$$$\|  $$$$$$$
 *    | $$$$    | $$  | $$| $$  | $$| $$        | $$ __ | $$| $$  | $$| $$  | $$ \$$    |
 *    | $$      | $$__/ $$| $$  | $$| $$_____   | $$|  \| $$| $$__/ $$| $$  | $$ _\$$$$$$|
 *    | $$       \$$    $$| $$  | $$ \$$     \   \$$  $$| $$ \$$    $$| $$  | $$|       $$
 *     \$$        \$$$$$$  \$$   \$$  \$$$$$$$    \$$$$  \$$  \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
stock Roads_Load()
{
    for (new i = 0;i < ROAD_COUNT;i++)
    {
        s_RoadObjects[i] = CreateDynamicObject(s_Roads[i][E_ROAD_MODEL],s_Roads[i][E_ROAD_X],s_Roads[i][E_ROAD_Y],s_Roads[i][E_ROAD_Z],s_Roads[i][E_ROAD_RX],s_Roads[i][E_ROAD_RY],s_Roads[i][E_ROAD_RZ]);

        if (s_Roads[i][E_ROAD_STATIC])
        {
            Streamer_ToggleItemStatic(STREAMER_TYPE_OBJECT,s_RoadObjects[i],true);
        }
    }

    for (new i = 0;i < ROAD_MATERIAL_COUNT;i++)
    {
        SetDynamicObjectMaterial(s_RoadObjects[s_RoadMaterials[i][E_ROAD_MATERIAL_OBJECT]],s_RoadMaterials[i][E_ROAD_MATERIAL_INDEX],s_RoadMaterials[i][E_ROAD_MATERIAL_MODEL],s_RoadMaterials[i][E_ROAD_MATERIAL_TXD],s_RoadMaterials[i][E_ROAD_MATERIAL_TEXTURE],s_RoadMaterials[i][E_ROAD_MATERIAL_COLOUR]);
    }
}

stock Roads_Count()
{
    return ROAD_COUNT;
}

stock Roads_GetObject(index)
{
    if (index < 0 || index >= ROAD_COUNT)
    {
        return INVALID_STREAMER_ID;
    }

    return _:s_RoadObjects[index];
}
