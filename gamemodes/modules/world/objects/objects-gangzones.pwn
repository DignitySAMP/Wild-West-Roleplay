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
#define COVER_ZONE_COUNT (5)
#define COVER_COLOUR (0x000000FF)

static const Float:s_CoverZones[COVER_ZONE_COUNT][4] =
{
    {-3000.0,-3000.000045776367,-1892.0,2016.4999542236328},
    {-1892.0,-3000.0,-1236.0,1590.5},
    {-1236.0,-3000.0,3000.0,577.5},
    {-901.9998779296875,2188.0,3000.0001220703125,3000.0},
    {-478.0,576.0,2998.0,2188.0}
};

static s_CoverIds[COVER_ZONE_COUNT];
static bool:s_CoverShown[MAX_PLAYERS];

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
stock Cover_Init()
{
    for (new i = 0;i < COVER_ZONE_COUNT;i++)
    {
        s_CoverIds[i] = GangZoneCreate(s_CoverZones[i][0],s_CoverZones[i][1],s_CoverZones[i][2],s_CoverZones[i][3]);
    }
}

stock Cover_Reset(playerid)
{
    s_CoverShown[playerid] = false;
}

stock bool:Cover_IsShown(playerid)
{
    return s_CoverShown[playerid];
}

stock Cover_Show(playerid)
{
    if (s_CoverShown[playerid])
    {
        return;
    }

    s_CoverShown[playerid] = true;

    for (new i = 0;i < COVER_ZONE_COUNT;i++)
    {
        GangZoneShowForPlayer(playerid,s_CoverIds[i],COVER_COLOUR);
    }
}
