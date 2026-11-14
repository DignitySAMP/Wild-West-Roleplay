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
#define SERVER_SPAWN_X (-1358.9551)
#define SERVER_SPAWN_Y (2612.5303)
#define SERVER_SPAWN_Z (53.5066)
#define SERVER_SPAWN_A (51.7536)
#define SPAWN_DEFAULT_ANGLE (90.0)
#define SPAWN_TOWN_COUNT (2)
#define SPAWN_NOTICE_LEN (128)
#define SPAWN_FOLLOWUP_MS (1000)
#define SPAWN_NAMECHECK_MS (5000)
#define SPAWN_MAX_CHOICE (7)

enum _:E_SPAWN_CHOICE
{
    E_SPAWN_CHOICE_GLOBAL = 0,
    E_SPAWN_CHOICE_TOWN,
    E_SPAWN_CHOICE_HOUSE,
    E_SPAWN_CHOICE_BUSINESS,
    E_SPAWN_CHOICE_FACTION,
    E_SPAWN_CHOICE_MOTEL,
    E_SPAWN_CHOICE_LOCATION,
}

enum _:E_SPAWN_PRIORITY
{
    E_SPAWN_PRIORITY_CHOICE = 0,
    E_SPAWN_PRIORITY_CRASH = 50,
    E_SPAWN_PRIORITY_PRISON = 100,
    E_SPAWN_PRIORITY_JAIL = 150,
}

static const Float:s_SpawnTowns[SPAWN_TOWN_COUNT][3] =
{
    {-1418.1863, 2641.7834, 55.3046},
    {-797.6470, 1436.1898, 13.4218}
};

static s_SpawnChoicesAvailable;
static bool:s_SpawnHasPoint[MAX_PLAYERS];
static s_SpawnPriority[MAX_PLAYERS];
static Float:s_SpawnX[MAX_PLAYERS];
static Float:s_SpawnY[MAX_PLAYERS];
static Float:s_SpawnZ[MAX_PLAYERS];
static Float:s_SpawnAngle[MAX_PLAYERS];
static s_SpawnInterior[MAX_PLAYERS];
static s_SpawnWorld[MAX_PLAYERS];
static s_SpawnNotice[MAX_PLAYERS][SPAWN_NOTICE_LEN];
static bool:s_SpawnQuiet[MAX_PLAYERS];
static bool:s_SpawnPending[MAX_PLAYERS];
static bool:s_SpawnApplied[MAX_PLAYERS];

forward Spawn_OnChoose(playerid);
forward Spawn_OnChoiceRequest(playerid,choice);
forward Spawn_OnComplete(playerid);

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
stock Spawn_RegisterChoice(choice)
{
    if (choice >= 0 && choice < SPAWN_MAX_CHOICE)
    {
        s_SpawnChoicesAvailable |= 1 << choice;
    }
}

stock bool:Spawn_IsChoiceAvailable(choice)
{
    switch (choice)
    {
        case E_SPAWN_CHOICE_GLOBAL, E_SPAWN_CHOICE_TOWN, E_SPAWN_CHOICE_LOCATION:
        {
            return true;
        }
    }

    return choice >= 0 && choice < SPAWN_MAX_CHOICE && (s_SpawnChoicesAvailable & (1 << choice)) != 0;
}

stock Spawn_GetChoice(playerid)
{
    return Character_GetSpawnChoice(playerid);
}

stock Spawn_SetChoice(playerid,choice)
{
    Character_SetSpawnChoice(playerid,choice);
}

stock Spawn_ClearPoint(playerid)
{
    s_SpawnHasPoint[playerid] = false;
    s_SpawnPriority[playerid] = -1;
    s_SpawnNotice[playerid][0] = EOS;
    s_SpawnQuiet[playerid] = false;
}

stock bool:Spawn_SetPoint(playerid,Float:x,Float:y,Float:z,Float:angle,interior,world,priority,const notice[] = "",bool:quiet = false)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return false;
    }

    if (s_SpawnHasPoint[playerid] && priority <= s_SpawnPriority[playerid])
    {
        return false;
    }

    s_SpawnHasPoint[playerid] = true;
    s_SpawnPriority[playerid] = priority;
    s_SpawnX[playerid] = x;
    s_SpawnY[playerid] = y;
    s_SpawnZ[playerid] = z;
    s_SpawnAngle[playerid] = angle;
    s_SpawnInterior[playerid] = interior;
    s_SpawnWorld[playerid] = world;
    strcopy(s_SpawnNotice[playerid],notice,SPAWN_NOTICE_LEN);
    s_SpawnQuiet[playerid] = quiet;
    return true;
}

stock bool:Spawn_HasPoint(playerid)
{
    return s_SpawnHasPoint[playerid];
}

stock Spawn_GetPointPriority(playerid)
{
    return s_SpawnHasPoint[playerid] ? s_SpawnPriority[playerid] : -1;
}

stock Spawn_GetPoint(playerid,&Float:x,&Float:y,&Float:z,&Float:angle,&interior,&world)
{
    x = s_SpawnX[playerid];
    y = s_SpawnY[playerid];
    z = s_SpawnZ[playerid];
    angle = s_SpawnAngle[playerid];
    interior = s_SpawnInterior[playerid];
    world = s_SpawnWorld[playerid];
}

stock Spawn_GetTownPosition(town,&Float:x,&Float:y,&Float:z)
{
    new index = town >= 0 && town < SPAWN_TOWN_COUNT ? town : 0;
    x = s_SpawnTowns[index][0];
    y = s_SpawnTowns[index][1];
    z = s_SpawnTowns[index][2];
}

stock bool:Spawn_IsQuiet(playerid)
{
    return s_SpawnQuiet[playerid];
}

stock Spawn_GetNotice(playerid,dest[],size = sizeof(dest))
{
    strcopy(dest,s_SpawnNotice[playerid],size);
}

stock Spawn_SetPending(playerid,bool:pending)
{
    s_SpawnPending[playerid] = pending;
}

stock bool:Spawn_IsPending(playerid)
{
    return s_SpawnPending[playerid];
}

stock Spawn_SetApplied(playerid,bool:applied)
{
    s_SpawnApplied[playerid] = applied;
}

stock bool:Spawn_IsApplied(playerid)
{
    return s_SpawnApplied[playerid];
}
