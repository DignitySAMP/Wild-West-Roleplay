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
#define SAFEZONE_SPAWN_X (-828.4460)
#define SAFEZONE_SPAWN_Y (1087.0280)
#define SAFEZONE_SPAWN_Z (38.9719)
#define SAFEZONE_SPAWN_RANGE (50.0)
#define SAFEZONE_POINT_RANGE (25.0)

/**
 *                                   __
 *                                  |  |
 *      _______  ______ ____    ____| $$  _______
 *     /       \|      \    \  /      $$ /       |
 *    |  $$$$$$$| $$$$$$\$$$$\|  $$$$$$$|  $$$$$$$
 *    | $$      | $$ | $$ | $$| $$  | $$ \$$    |
 *    | $$_____ | $$ | $$ | $$| $$__| $$ _\$$$$$$|
 *     \$$     \| $$ | $$ | $$ \$$    $$|       $$
 *      \$$$$$$$ \$$  \$$  \$$  \$$$$$$$ \$$$$$$$
 *
 */
CMD:resyncambient(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    Zone_ResyncAmbient(playerid);
    return 1;
}

static bool:Safezone_AtPoint(playerid)
{
    new world = GetPlayerVirtualWorld(playerid), interior = GetPlayerInterior(playerid);

    for (new Iter:it = Point_Iterator();iter_inside(it);iter_move_next(it))
    {
        new point[e_POINT];
        iter_get_arr(it,point);

        if (!IsPlayerInRangeOfPoint(playerid,SAFEZONE_POINT_RANGE,point[E_POINT_INT_X],point[E_POINT_INT_Y],point[E_POINT_INT_Z]) || world != point[E_POINT_INT_VW] || interior != point[E_POINT_INT_INT])
        {
            continue;
        }

        if (Zone_IsSafe(Zone_FromPosition(point[E_POINT_EXT_X],point[E_POINT_EXT_Y])))
        {
            return true;
        }
    }

    return false;
}

CMD:safezone(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (IsPlayerInRangeOfPoint(playerid,SAFEZONE_SPAWN_RANGE,SAFEZONE_SPAWN_X,SAFEZONE_SPAWN_Y,SAFEZONE_SPAWN_Z))
    {
        SendServerMessage(playerid,"You're in a safezone near the spawn, but only until you leave this area.",MSG_TYPE_WARN);
        SendServerMessage(playerid,"If you return after, you won't be safe anymore for the safezone rule.",MSG_TYPE_WARN);
        return 1;
    }

    if (GetPlayerVirtualWorld(playerid) == 0)
    {
        if (Zone_IsSafe(Zone_OfPlayer(playerid)))
        {
            SendServerMessage(playerid,"You're in a safezone.",MSG_TYPE_INFO);
            return 1;
        }
    }
    else if (Safezone_AtPoint(playerid))
    {
        SendServerMessage(playerid,"You're in a safezone.",MSG_TYPE_INFO);
        return 1;
    }

    SendServerMessage(playerid,"You're not in a safezone.",MSG_TYPE_ERROR);
    return 1;
}

CMD:refreshweather(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], line[128];
    GetPlayerName(playerid,name,sizeof(name));
    Zone_RollWeather();
    SendClientMessageToAll(COLOR_STAFF,"[WEATHER]:{DEDEDE} The clouds have shifted and the weather has changed.");
    format(line,sizeof(line),"[STAFF] %s (%d) has refreshed the weather.",name,playerid);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    return 1;
}

CMD:setweather(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new zone, weather;

    if (sscanf(params,"ii",zone,weather))
    {
        SendServerMessage(playerid,"/setweather [zone] [weather]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Zone_IsValid(zone))
    {
        SendServerMessage(playerid,"Invalid zone ID. Make sure you're at the right zone first and then use the ID sent to you.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Zone_SetWeather(zone,weather))
    {
        SendServerMessage(playerid,"Weather can't be lower than 0 or higher than 255.",MSG_TYPE_ERROR);
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], line[128];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"[STAFF] %s (%d) has set the weather for zone %d to %d",name,playerid,zone,weather);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    format(line,sizeof(line),"You've changed the weather of zone %d, anyone who is in it needs to re-enter it in order for it to update.",zone);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
}
