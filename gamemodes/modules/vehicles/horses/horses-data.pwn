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
#define HORSE_NONE (-1)
#define HORSE_COW (99)
#define HORSE_CATALOG_SIZE (6)
#define HORSE_NAME_LEN (32)
#define HORSE_MAX_HEALTH (100.0)
#define HORSE_REVIVE_LIMIT (5.0)
#define HORSE_REVIVE_PRICE (1500)
#define HORSE_SADDLE_SLOTS (2)
#define HORSE_STABLE_RANGE (15.0)

enum e_HORSE_TYPE
{
    E_HORSE_NAME[HORSE_NAME_LEN],
    Float:E_HORSE_SPEED,
    Float:E_HORSE_STAMINA,
    Float:E_HORSE_HEALTH,
    E_HORSE_COLOUR,
    E_HORSE_LEVEL,
    bool:E_HORSE_DONATOR,
    bool:E_HORSE_ENABLED,
    E_HORSE_PRICE
}

static const s_HorseCatalog[HORSE_CATALOG_SIZE][e_HORSE_TYPE] =
{
    {"Cleveland Bay",50.0,70.0,90.0,0xFFFFFFFF,1,false,false,99900},
    {"Dutch Warmblood",65.0,80.0,100.0,0xFF917959,1,false,true,4500},
    {"Highland Chestnut",65.0,80.0,90.0,0xFFC9725F,3,false,true,9000},
    {"American Standardbred",75.0,90.0,100.0,0xFF423625,5,false,true,12500},
    {"Kentucky Saddler",90.0,115.0,115.0,0xFF696969,6,false,false,99900},
    {"Hungarian Half-bred",125.0,150.0,150.0,0xFF111111,1,true,false,99900}
};

static s_HorseType[MAX_PLAYERS] = {HORSE_NONE,...};
static Float:s_HorseHealth[MAX_PLAYERS];
static bool:s_HorseLoaded[MAX_PLAYERS];
static s_HorseSaddleWeapon[MAX_PLAYERS][HORSE_SADDLE_SLOTS];
static s_HorseSaddleAmmo[MAX_PLAYERS][HORSE_SADDLE_SLOTS];

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
stock bool:Horse_IsLoaded(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_HorseLoaded[playerid];
}

stock Horse_GetType(playerid)
{
    return s_HorseType[playerid];
}

stock bool:Horse_HasHorse(playerid)
{
    return s_HorseType[playerid] != HORSE_NONE;
}

stock bool:Horse_IsCow(playerid)
{
    return s_HorseType[playerid] == HORSE_COW;
}

stock Float:Horse_GetHealth(playerid)
{
    return s_HorseHealth[playerid];
}

stock Horse_CatalogCount()
{
    return HORSE_CATALOG_SIZE;
}

stock bool:Horse_CatalogGet(type,row[e_HORSE_TYPE])
{
    if (type < 0 || type >= HORSE_CATALOG_SIZE)
    {
        return false;
    }

    row = s_HorseCatalog[type];
    return true;
}

stock Horse_GetTypeName(type,dest[],size)
{
    if (type == HORSE_COW)
    {
        strcopy(dest,"cow",size);
        return;
    }

    if (type < 0 || type >= HORSE_CATALOG_SIZE)
    {
        strcopy(dest,"horse",size);
        return;
    }

    strcopy(dest,s_HorseCatalog[type][E_HORSE_NAME],size);
}

stock bool:Horse_IsValidAssignment(type)
{
    return type == HORSE_NONE || type == 1 || type == 2 || type == 3 || type == HORSE_COW;
}

stock Horse_GetSaddleWeapon(playerid,slot)
{
    return s_HorseSaddleWeapon[playerid][slot];
}

stock Horse_GetSaddleAmmo(playerid,slot)
{
    return s_HorseSaddleAmmo[playerid][slot];
}

stock Horse_SetSaddle(playerid,slot,weapon,ammo)
{
    s_HorseSaddleWeapon[playerid][slot] = weapon;
    s_HorseSaddleAmmo[playerid][slot] = ammo;
}

stock Horse_SaveSaddle(playerid)
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_sb_gun0 = %d, character_sb_gun1 = %d, character_sb_ammo0 = %d, character_sb_ammo1 = %d WHERE character_id = %d",s_HorseSaddleWeapon[playerid][0],s_HorseSaddleWeapon[playerid][1],s_HorseSaddleAmmo[playerid][0],s_HorseSaddleAmmo[playerid][1],Character_GetId(playerid)));
}

stock Horse_SetType(playerid,type)
{
    s_HorseType[playerid] = type;
}

stock Horse_SaveType(playerid)
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_horseid = %d WHERE character_id = %d",s_HorseType[playerid],Character_GetId(playerid)));
}

stock Horse_SetStoredHealth(playerid,Float:health)
{
    s_HorseHealth[playerid] = health < 0.0 ? 0.0 : health;
}

stock Horse_SaveHealth(playerid)
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_horsehealth = %f WHERE character_id = %d",s_HorseHealth[playerid],Character_GetId(playerid)));
}

stock Horse_SetLoaded(playerid,bool:loaded)
{
    s_HorseLoaded[playerid] = loaded;
}

stock Horse_ResetData(playerid)
{
    s_HorseType[playerid] = HORSE_NONE;
    s_HorseHealth[playerid] = HORSE_MAX_HEALTH;
    s_HorseLoaded[playerid] = false;

    for (new slot = 0;slot < HORSE_SADDLE_SLOTS;slot++)
    {
        s_HorseSaddleWeapon[playerid][slot] = 0;
        s_HorseSaddleAmmo[playerid][slot] = 0;
    }
}
