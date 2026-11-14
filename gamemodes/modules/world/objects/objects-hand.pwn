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
#define HAND_GROUND_FIX_COUNT (10)
#define HAND_SIGN_COUNT (2)
#define HAND_SIGN_ARIAL "Arial"

enum e_GROUND_FIX
{
    Float:E_GROUND_FIX_X,
    Float:E_GROUND_FIX_Y,
    Float:E_GROUND_FIX_Z,
    Float:E_GROUND_FIX_RX,
    Float:E_GROUND_FIX_RY,
    Float:E_GROUND_FIX_RZ
}

static const s_GroundFixes[HAND_GROUND_FIX_COUNT][e_GROUND_FIX] =
{
    {-2374.22510,2448.69238,6.13586,4.00000,0.00000,-20.82000},
    {-2373.52515,2450.62109,6.26575,4.00000,0.00000,-20.82000},
    {-2381.47583,2451.66675,6.33982,3.10000,0.00000,-20.82000},
    {-2380.72876,2453.36548,6.33982,3.10000,0.00000,-20.82000},
    {-2387.30884,2453.85156,6.23220,3.60000,-2.00000,-20.82000},
    {-2386.40771,2455.90161,6.45519,3.60000,-2.00000,-20.82000},
    {-2422.45166,2454.12012,9.74985,0.00000,0.00000,1.08000},
    {-2412.58911,2454.33521,9.74985,0.00000,0.00000,1.08000},
    {-2415.81689,2457.26074,9.74985,0.00000,0.00000,1.08000},
    {-2418.35571,2455.53979,9.74985,0.00000,0.00000,1.08000}
};

static const s_SignTextOutOfCharacter[] = "(( Welcome to Wild West Roleplay.\n\nYou should probably head to a nearby settlement and\nequip yourself with a fishing rod and start catching\nfish for money. Then you can head to Bayside\nand buy yourself a horse and maybe better tools\nfor other jobs such as mining, woodcutting\nor hunting.\n\nFor help, use /help, /ask or /report when in trouble.))";
static const s_SignTextInCharacter[] = "GREETINGS TRAVELER\n\nTHE TOWN OF FREMONT IS LOOKING FOR\nSOME FRESHLY ARRIVED MEN AND WOMEN TO\nREPORT THEIR ARRIVAL TO THE LOCAL TOWN-\nHOUSE. YOU'LL WANT TO START YOUR JOURNEY\nTHERE.\n\nSIGNED,\nTHE SAN ANDREAS JUDICIARY.";

static STREAMER_TAG_OBJECT:s_HandObjects[16];
static s_HandObjectCount;

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
static STREAMER_TAG_OBJECT:Hand_Add(model,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
    new STREAMER_TAG_OBJECT:objectid = CreateDynamicObject(model,x,y,z,rx,ry,rz);

    if (s_HandObjectCount < sizeof(s_HandObjects))
    {
        s_HandObjects[s_HandObjectCount++] = objectid;
    }

    return objectid;
}

stock Hand_Load()
{
    s_HandObjectCount = 0;

    for (new i = 0;i < HAND_GROUND_FIX_COUNT;i++)
    {
        new STREAMER_TAG_OBJECT:fix = CreateDynamicObject(18765,s_GroundFixes[i][E_GROUND_FIX_X],s_GroundFixes[i][E_GROUND_FIX_Y],s_GroundFixes[i][E_GROUND_FIX_Z],s_GroundFixes[i][E_GROUND_FIX_RX],s_GroundFixes[i][E_GROUND_FIX_RY],s_GroundFixes[i][E_GROUND_FIX_RZ]);
        SetDynamicObjectMaterial(fix,0,0,"INVALID","INVALID",0xFFFFFFFF);
    }

    Hand_Add(18856,-869.82867,2308.63770,156.71696,0.0,0.0,0.0);
    Hand_Add(19087,-869.89563,2308.86914,160.67020,0.0,0.0,0.0);

    new STREAMER_TAG_OBJECT:tree = Hand_Add(11420,-2090.83594,2314.06250,23.82556,0.0,0.0,0.0);
    SetDynamicObjectMaterial(tree,0,726,"gtatreesh","oakbark64",0xFFFFFFFF);
    tree = Hand_Add(737,-2092.5,2314.66016,24.85,0.0,0.0,0.0);
    SetDynamicObjectMaterial(tree,0,726,"gtatreesh","oakbark64",0xFFFFFFFF);
    SetDynamicObjectMaterial(tree,1,1829,"kbmiscfrn2","man_mny1",0xFFFFFFFF);

    new STREAMER_TAG_OBJECT:sign = Hand_Add(19329,-829.87097,1091.17126,35.80889,0.0,0.0,-53.70000);
    SetDynamicObjectMaterial(sign,0,13694,"lahillstxd1a","planks01",0xFFFFFFFF);
    sign = Hand_Add(19329,-829.87213,1091.15125,35.80889,0.0,0.0,-53.70000);
    SetDynamicObjectMaterialText(sign,0,s_SignTextOutOfCharacter,OBJECT_MATERIAL_SIZE_512x256,HAND_SIGN_ARIAL,24,1,0xFFAAC4E5,0);

    sign = Hand_Add(19327,-829.87097,1091.17126,34.69724,0.0,0.0,-53.70003);
    SetDynamicObjectMaterial(sign,0,13694,"lahillstxd1a","planks01",0xFFFFFFFF);
    sign = Hand_Add(19327,-829.87097,1091.17053,34.69724,0.0,0.0,-53.70003);
    SetDynamicObjectMaterialText(sign,0,s_SignTextInCharacter,OBJECT_MATERIAL_SIZE_512x256);
}

stock Hand_GetCount()
{
    return s_HandObjectCount + HAND_GROUND_FIX_COUNT;
}
