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
#define ZONE_NONE (-1)
#define ZONE_COUNT (20)
#define ZONE_NAME_LEN (36)
#define ZONE_WEATHER_KINDS (7)
#define ZONE_WEATHER_MS (1500000)
#define ZONE_WEATHER_MAX (255)
#define SAWMILL_MIN_X (-829.0)
#define SAWMILL_MIN_Y (919.5)
#define SAWMILL_MAX_X (-776.0)
#define SAWMILL_MAX_Y (964.5)
#define SAWMILL_AUDIO "jobs/sawmill.mp3"

enum e_ZONE
{
    E_ZONE_NAME[ZONE_NAME_LEN],
    bool:E_ZONE_SAFE,
    Float:E_ZONE_MIN_X,
    Float:E_ZONE_MIN_Y,
    Float:E_ZONE_MAX_X,
    Float:E_ZONE_MAX_Y,
    E_ZONE_AUDIO[48]
}

static const s_Zones[ZONE_COUNT][e_ZONE] =
{
    {"Bayside",true,-3000.0000,2084.0000,-2159.0000,3000.0000,"ambient/ambient_blackwater.mp3"},
    {"Fremont",true,-920.75341,1359.0208,-566.75341,1656.0208,"ambient/ambient_las_hermanas.mp3"},
    {"Longcreek",true,-1736.0100,2432.0000,-1246.0103,3000.0000,"ambient/ambient_armadillo.mp3"},
    {"Butter Bridge",false,-2159.0000,2434.0000,-1736.0000,3000.0000,"ambient/ambient_butter_bridge.mp3"},
    {"Hamlins Passing",false,-2159.0000,2084.0000,-1631.0000,2434.0000,"ambient/ambient_hamlins_passing.mp3"},
    {"El Quebrados Docks",false,-1246.0346,2571.0000,-1116.0346,3000.0000,"ambient/ambient_pacific_railroad_union.mp3"},
    {"Cueva Seca",false,-1631.0103,2166.0104,-1245.0103,2434.0104,"ambient/ambient_cueva_seca.mp3"},
    {"El Matadero",false,-1246.0242,2225.0000,-946.02423,2571.0000,"ambient/ambient_el_matadero.mp3"},
    {"Fort Earp",false,-1245.0242,2083.0070,-958.02423,2225.0069,"ambient/ambient_benedict_point.mp3"},
    {"Escalera",false,-1631.0103,2084.0103,-1245.0103,2167.0103,"ambient/ambient_escalera.mp3"},
    {"Casa Madrugada",false,-1864.7290,1602.0103,-1533.7290,2084.0103,"ambient/ambient_casa_madraguda.mp3"},
    {"Nekoti Rock North",false,-1231.7395,1656.0173,-662.73950,2083.0173,"ambient/ambient_nekoti_rock_2.mp3"},
    {"Nekoti Rock South",false,-1231.7395,1202.0208,-920.73950,1656.0208,"ambient/ambient_nekoti_rock_1.mp3"},
    {"New El Matadero",false,-1169.7290,921.02429,-791.72900,1203.0242,"ambient/ambient_el_matadero.mp3"},
    {"Rattlesnake Hollow",false,-920.75341,1202.0242,-573.75341,1360.0242,"ambient/ambient_rattlesnake_hollow.mp3"},
    {"Rio Bravado",false,-791.73950,921.03811,-526.73950,1203.0381,"ambient/ambient_rio_bravado.mp3"},
    {"Thieves Landing",false,-963.72900,624.03807,-562.72900,921.03807,"ambient/ambient_thieves_landing.mp3"},
    {"Torquenada",false,-1532.7291,1601.0208,-1232.7291,2084.0208,"ambient/ambient_torquenada.mp3"},
    {"Refugee Camp",true,-2137.0156,-1583.9531,-1852.0156,-1358.953,""},
    {"Staff Island",true,483.0675,-2747.5730,694.5912,-2620.3042,""}
};

static s_ZoneWeather[ZONE_COUNT];
static s_ZoneCurrent[MAX_PLAYERS] = {ZONE_NONE,...};
static s_ZoneWeatherDue;

forward World_OnTick(now);
forward Zone_OnEntered(playerid,zone);

new g_ZoneArea[ZONE_COUNT];
new g_SawmillArea;

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
public World_OnTick(now)
{
    return 1;
}

public Zone_OnEntered(playerid,zone)
{
    return 1;
}

stock Zone_Count()
{
    return ZONE_COUNT;
}

stock bool:Zone_IsValid(zone)
{
    return zone >= 0 && zone < ZONE_COUNT;
}

stock bool:Zone_IsSafe(zone)
{
    return zone >= 0 && zone < ZONE_COUNT && s_Zones[zone][E_ZONE_SAFE];
}

stock Zone_GetName(zone,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (zone >= 0 && zone < ZONE_COUNT)
    {
        strcopy(dest,s_Zones[zone][E_ZONE_NAME],size);
    }
}

stock Zone_GetAudio(zone,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (zone >= 0 && zone < ZONE_COUNT)
    {
        strcopy(dest,s_Zones[zone][E_ZONE_AUDIO],size);
    }
}

stock bool:Zone_GetBounds(zone,&Float:minx,&Float:miny,&Float:maxx,&Float:maxy)
{
    if (zone < 0 || zone >= ZONE_COUNT)
    {
        return false;
    }

    minx = s_Zones[zone][E_ZONE_MIN_X];
    miny = s_Zones[zone][E_ZONE_MIN_Y];
    maxx = s_Zones[zone][E_ZONE_MAX_X];
    maxy = s_Zones[zone][E_ZONE_MAX_Y];
    return true;
}

stock Zone_FromPosition(Float:x,Float:y)
{
    for (new zone = 0;zone < ZONE_COUNT;zone++)
    {
        if (x >= s_Zones[zone][E_ZONE_MIN_X] && x <= s_Zones[zone][E_ZONE_MAX_X] && y >= s_Zones[zone][E_ZONE_MIN_Y] && y <= s_Zones[zone][E_ZONE_MAX_Y])
        {
            return zone;
        }
    }

    return ZONE_NONE;
}

stock Zone_OfPlayer(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    return Zone_FromPosition(x,y);
}

stock Zone_GetCurrent(playerid)
{
    return s_ZoneCurrent[playerid];
}

stock Zone_SetCurrent(playerid,zone)
{
    s_ZoneCurrent[playerid] = zone;
}

stock Zone_GetWeather(zone)
{
    if (zone < 0 || zone >= ZONE_COUNT)
    {
        return 0;
    }

    return s_ZoneWeather[zone];
}

stock Zone_GetArea(zone)
{
    if (zone < 0 || zone >= ZONE_COUNT)
    {
        return INVALID_STREAMER_ID;
    }

    return g_ZoneArea[zone];
}

stock Zone_FromArea(areaid)
{
    for (new zone = 0;zone < ZONE_COUNT;zone++)
    {
        if (g_ZoneArea[zone] == areaid)
        {
            return zone;
        }
    }

    return ZONE_NONE;
}

stock Zone_ApplyWeather(zone)
{
    for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
    {
        if (IsPlayerConnected(playerid) && s_ZoneCurrent[playerid] == zone)
        {
            SetPlayerWeather(playerid,s_ZoneWeather[zone]);
        }
    }
}

stock bool:Zone_SetWeather(zone,weather)
{
    if (zone < 0 || zone >= ZONE_COUNT || weather < 0 || weather > ZONE_WEATHER_MAX)
    {
        return false;
    }

    s_ZoneWeather[zone] = weather;
    Zone_ApplyWeather(zone);
    return true;
}

stock Zone_RollWeather()
{
    for (new zone = 0;zone < ZONE_COUNT;zone++)
    {
        s_ZoneWeather[zone] = random(ZONE_WEATHER_KINDS);
    }

    for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
    {
        new zone = s_ZoneCurrent[playerid];

        if (IsPlayerConnected(playerid) && zone != ZONE_NONE)
        {
            SetPlayerWeather(playerid,s_ZoneWeather[zone]);
        }
    }

    s_ZoneWeatherDue = GetTickCount() + ZONE_WEATHER_MS;
}

stock Zone_GetWeatherDue()
{
    return s_ZoneWeatherDue;
}

stock Zone_SetWeatherDue(due)
{
    s_ZoneWeatherDue = due;
}

stock bool:Zone_InSawmill(playerid)
{
    return bool:IsPlayerInDynamicArea(playerid,STREAMER_TAG_AREA:g_SawmillArea);
}
