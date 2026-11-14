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
#define WORLD_TICK_MS (5000)
#define ZONE_NAME_X (70.0)
#define ZONE_NAME_Y (315.0)
#define ZONE_NAME_COLOUR (0xD17F5EFF)

static PlayerText:s_ZoneText[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW,...};

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
stock World_Step()
{
    new now = GetTickCount();

    if (now - Zone_GetWeatherDue() >= 0)
    {
        Zone_RollWeather();
        SendClientMessageToAll(COLOR_STAFF,"[WEATHER]:{DEDEDE} The clouds have shifted and the weather has changed.");
    }

    pawn_call_public("World_OnTick","d",now);
}

Timer_Declare(World_Ticker)
{

    World_Step();
    return 1;
}

static Zone_ShowName(playerid,const name[])
{
    if (s_ZoneText[playerid] == PlayerText:INVALID_TEXT_DRAW)
    {
        s_ZoneText[playerid] = CreatePlayerTextDraw(playerid,ZONE_NAME_X,ZONE_NAME_Y,name);
        PlayerTextDrawSetShadow(playerid,s_ZoneText[playerid],1);
        PlayerTextDrawAlignment(playerid,s_ZoneText[playerid],TEXT_DRAW_ALIGN_CENTER);
        PlayerTextDrawColor(playerid,s_ZoneText[playerid],ZONE_NAME_COLOUR);
        PlayerTextDrawLetterSize(playerid,s_ZoneText[playerid],0.500,1.500);
    }

    PlayerTextDrawSetString(playerid,s_ZoneText[playerid],name);
    PlayerTextDrawShow(playerid,s_ZoneText[playerid]);
}

stock Zone_ResyncAmbient(playerid)
{
    StopAudioStreamForPlayer(playerid);
    new zone = Zone_OfPlayer(playerid);

    if (zone != ZONE_NONE)
    {
        new file[48];
        Zone_GetAudio(zone,file);
        Audio_Play(playerid,file);
    }
}

static Zone_Enter(playerid,zone)
{
    if (!Account_IsLoggedIn(playerid) && !Player_IsSpawned(playerid))
    {
        return;
    }

    Zone_SetCurrent(playerid,zone);

    if (Zone_InSawmill(playerid))
    {
        return;
    }

    if (Player_IsSpawned(playerid) && (!Horse_IsRiding(playerid) || Horse_IsSoundOn(playerid)))
    {
        new file[48];
        Zone_GetAudio(zone,file);
        Audio_Play(playerid,file);
    }

    new name[ZONE_NAME_LEN];
    Zone_GetName(zone,name);
    SetPlayerWeather(playerid,Zone_GetWeather(zone));
    Zone_ShowName(playerid,name);

    if (Zone_IsSafe(zone))
    {
        SendServerMessage(playerid,"You have entered a safezone. Use /safezone to see whether you are in a safezone or not. For big crimes (shootouts, gangwars), you need admin permission.",MSG_TYPE_WARN);
        SendServerMessage(playerid,"In order to commit a small crime, three law enforcement officers have to be online (before 12 PM), after 12 PM only two will be necessary. (/servertime).",MSG_TYPE_WARN);
    }

    if (Staff_IsModerator(playerid))
    {
        new line[144], temperature[24];
        Zone_DescribeTemperature(zone,temperature);
        format(line,sizeof(line),"Entered zone %s (%d), setting weather to ID %d, current temperature is %s",name,zone,Zone_GetWeather(zone),temperature);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
    }

    pawn_call_public("Zone_OnEntered","dd",playerid,zone);
}

stock Zone_DescribeTemperature(zone,dest[],size = sizeof(dest))
{
    new value = Temperature_GetZone(zone);

    if (value == INVALID_TEMPERATURE)
    {
        strcopy(dest,"no reading",size);
        return;
    }

    format(dest,size,"%d F\176;",value);
}

/**
 *     __                            __
 *    |  \                          |  |
 *    | $$____    ______    ______  | $$   __   _______
 *    | $$    \  /      \  /      \ | $$  /  \ /       |
 *    | $$$$$$$\|  $$$$$$\|  $$$$$$\| $$_/  $$|  $$$$$$$
 *    | $$  | $$| $$  | $$| $$  | $$| $$   $$  \$$    |
 *    | $$  | $$| $$__/ $$| $$__/ $$| $$$$$$\  _\$$$$$$|
 *    | $$  | $$ \$$    $$ \$$    $$| $$  \$$\|       $$
 *     \$$   \$$  \$$$$$$   \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
#include <pp-hooks>

hook OnGameModeInit()
{
    for (new zone = 0;zone < ZONE_COUNT;zone++)
    {
        new Float:minx, Float:miny, Float:maxx, Float:maxy;
        Zone_GetBounds(zone,minx,miny,maxx,maxy);
        g_ZoneArea[zone] = _:CreateDynamicRectangle(minx,miny,maxx,maxy);
    }

    g_SawmillArea = _:CreateDynamicRectangle(SAWMILL_MIN_X,SAWMILL_MIN_Y,SAWMILL_MAX_X,SAWMILL_MAX_Y);
    Zone_RollWeather();
    Timer_Start(World_Ticker,WORLD_TICK_MS);
}

hook OnPlayerConnect(playerid)
{
    s_ZoneText[playerid] = PlayerText:INVALID_TEXT_DRAW;
    Zone_SetCurrent(playerid,ZONE_NONE);
}

hook OnPlayerDisconnect(playerid,reason)
{
    s_ZoneText[playerid] = PlayerText:INVALID_TEXT_DRAW;
    Zone_SetCurrent(playerid,ZONE_NONE);
}

hook OnPlayerEnterDynamicArea(playerid,STREAMER_TAG_AREA:areaid)
{
    if (_:areaid == g_SawmillArea)
    {
        Audio_Play(playerid,SAWMILL_AUDIO);
        return;
    }

    new zone = Zone_FromArea(_:areaid);

    if (zone != ZONE_NONE)
    {
        Zone_Enter(playerid,zone);
    }
}

hook OnPlayerLeaveDynamicArea(playerid,STREAMER_TAG_AREA:areaid)
{
    if (_:areaid == g_SawmillArea)
    {
        Zone_ResyncAmbient(playerid);
        return;
    }

    new zone = Zone_FromArea(_:areaid);

    if (zone != ZONE_NONE && Zone_GetCurrent(playerid) == zone)
    {
        Zone_SetCurrent(playerid,ZONE_NONE);
    }
}

hook Injury_OnCollapsed(playerid,issuerid)
{
    if (!Zone_IsSafe(Zone_OfPlayer(playerid)))
    {
        return;
    }

    new name[MAX_PLAYER_NAME + 1], line[160];
    GetPlayerName(playerid,name,sizeof(name));

    if (issuerid != INVALID_PLAYER_ID && IsPlayerConnected(issuerid))
    {
        new other[MAX_PLAYER_NAME + 1];
        GetPlayerName(issuerid,other,sizeof(other));
        format(line,sizeof(line),"[IN A SAFEZONE] (%d) %s has been injured by (%d) %s.",playerid,name,issuerid,other);
    }
    else
    {
        format(line,sizeof(line),"[IN A SAFEZONE] (%d) %s has been injured.",playerid,name);
    }

    Log_Info("death","%s",line);
}
