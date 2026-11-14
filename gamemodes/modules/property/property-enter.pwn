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
static bool:s_PointSleeping[MAX_PLAYERS];

static s_PointMotel[MAX_PLAYERS];
static s_PointSpawnInside[MAX_PLAYERS];

forward Point_OnEntered(playerid,pointid);
forward Point_OnLeft(playerid,pointid);
forward Point_OnMotelLoaded(playerid,token);
forward Point_SleepDeferred(playerid,token);

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
stock bool:Point_IsSleeping(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_PointSleeping[playerid];
}

stock Point_SetSleeping(playerid,bool:sleeping)
{
    s_PointSleeping[playerid] = sleeping;
}

stock Point_GetMotel(playerid)
{
    return s_PointMotel[playerid];
}

stock Point_SetMotel(playerid,motel)
{
    s_PointMotel[playerid] = motel;
}

static Point_ShowCommands(playerid,biztype)
{
    switch (biztype)
    {
        case POINT_BIZ_GENERAL, POINT_BIZ_GUN, POINT_BIZ_LIQUOR, POINT_BIZ_SALOON, POINT_BIZ_BLACKSMITH:
        {
            SendServerMessage(playerid,"Available commands: /buy",MSG_TYPE_INFO);
        }
        case POINT_BIZ_CLOTHING:
        {
            SendServerMessage(playerid,"Available commands: /buy [optional: mask, attachments, misc]",MSG_TYPE_INFO);
        }
        case POINT_BIZ_BARBER, POINT_BIZ_SHERIFF:
        {
            SendServerMessage(playerid,"Available commands: None",MSG_TYPE_INFO);
        }
        case POINT_BIZ_HUNTING:
        {
            SendServerMessage(playerid,"Available commands: /buy - sell meat through your inventory.",MSG_TYPE_INFO);
        }
        case POINT_BIZ_BANK:
        {
            SendServerMessage(playerid,"Available commands: /bank",MSG_TYPE_INFO);
        }
        case POINT_BIZ_POSTAL:
        {
            SendServerMessage(playerid,"Available commands: /ad(vertise), /paycheck, /license, /buytelegramnumber, /tele(gram), /viewtelegrams, /buy lottery",MSG_TYPE_INFO);
        }
        case POINT_BIZ_STABLE:
        {
            SendServerMessage(playerid,"Available commands: /buy, /revivehorse",MSG_TYPE_INFO);
        }
    }
}

stock Point_ApplyInterior(playerid,world,interior)
{
    if (world != 0 || interior != 0)
    {
        SetPlayerWeather(playerid,0);
        SetPlayerTime(playerid,14,0);

        new url[128];
        Point_GetAmbientUrl(url);

        if (url[0] != EOS)
        {
            PlayAudioStreamForPlayer(playerid,url);
        }
    }
}

stock bool:Point_PlaceInside(playerid,pointid)
{
    new point[e_POINT];

    if (!Point_Get(pointid,point))
    {
        return false;
    }

    SetPlayerPos(playerid,point[E_POINT_INT_X],point[E_POINT_INT_Y],point[E_POINT_INT_Z]);
    SetPlayerVirtualWorld(playerid,point[E_POINT_INT_VW]);
    SetPlayerInterior(playerid,point[E_POINT_INT_INT]);
    Point_ApplyInterior(playerid,point[E_POINT_INT_VW],point[E_POINT_INT_INT]);
    Point_SetPlayerPoint(playerid,pointid);
    return true;
}

static Point_Enter(playerid,pointid)
{
    new point[e_POINT], line[128], money[MONEY_TEXT_LEN];
    Point_Get(pointid,point);

    if (point[E_POINT_OWNER] > 0 && point[E_POINT_OWNER] == Character_GetId(playerid))
    {
        SendServerMessage(playerid,"You own this entrance. Use /point to manage it.",MSG_TYPE_INFO);

        if (point[E_POINT_TYPE] == POINT_TYPE_BIZ)
        {
            Money_Delimit(point[E_POINT_TILL],money);
            format(line,sizeof(line),"There's %s waiting for you in the business till.",money);
            SendServerMessage(playerid,line,MSG_TYPE_INFO);
        }
    }

    if (point[E_POINT_LOCKED] != 0)
    {
        SendServerMessage(playerid,"You try the door to find out it's locked.",MSG_TYPE_ERROR);
        return;
    }

    if (point[E_POINT_FEE] > 0)
    {
        if (!Money_CanAfford(playerid,point[E_POINT_FEE]))
        {
            SendServerMessage(playerid,"You don't have enough money to enter this business.",MSG_TYPE_ERROR);
            return;
        }

        Money_Take(playerid,point[E_POINT_FEE]);
        new total = point[E_POINT_TILL] * 100 + point[E_POINT_TILL_CHANGE] + point[E_POINT_FEE];
        point[E_POINT_TILL] = total / 100;
        point[E_POINT_TILL_CHANGE] = total % 100;
        Point_Commit(pointid,point);
        mysql_tquery_s(g_Mysql,str_format("UPDATE points SET point_till = %d, point_till_change = %d WHERE point_id = %d",point[E_POINT_TILL],point[E_POINT_TILL_CHANGE],pointid));
        format(line,sizeof(line),"You've been charged $0.%02d for the entrance fee.",point[E_POINT_FEE]);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
    }

    Fade_In(playerid);
    Point_PlaceInside(playerid,pointid);

    if (point[E_POINT_TYPE] == POINT_TYPE_BIZ)
    {
        Point_ShowCommands(playerid,point[E_POINT_BIZTYPE]);
    }

    pawn_call_public("Point_OnEntered","dd",playerid,pointid);
}

static Point_Leave(playerid,pointid)
{
    new point[e_POINT];
    Point_Get(pointid,point);

    if (point[E_POINT_LOCKED] != 0)
    {
        SendServerMessage(playerid,"The door is locked. You can't leave now. If you are stuck, call an admin.",MSG_TYPE_ERROR);
        return;
    }

    SetPlayerPos(playerid,point[E_POINT_EXT_X],point[E_POINT_EXT_Y],point[E_POINT_EXT_Z]);
    SetPlayerTime(playerid,Time_GetHour(),Time_GetMinute());
    SetPlayerVirtualWorld(playerid,point[E_POINT_VW]);
    SetPlayerInterior(playerid,point[E_POINT_INT]);
    Point_SetPlayerPoint(playerid,0);
    pawn_call_public("Point_OnLeft","dd",playerid,pointid);
}

stock Point_UseDoor(playerid)
{
    if (!Player_IsReady(playerid))
    {
        return;
    }

    if (Player_IsBusyWith(playerid,E_PLAYER_BUSY_HORSE))
    {
        SendServerMessage(playerid,"You can't enter a business whilst being on a horse.",MSG_TYPE_ERROR);
        return;
    }

    if (Player_IsBusyWith(playerid,E_PLAYER_BUSY_JAIL) || Player_IsBusyWith(playerid,E_PLAYER_BUSY_PRISON))
    {
        SendServerMessage(playerid,"You can't leave a building when you're in prison.",MSG_TYPE_ERROR);
        return;
    }

    new inside = Point_GetPlayerPoint(playerid);

    if (inside != 0 && (!Point_Exists(inside) || (GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0)))
    {
        Point_SetPlayerPoint(playerid,0);
        inside = 0;
    }

    if (inside == 0)
    {
        new pointid = Point_FindExterior(playerid,POINT_ENTER_RANGE);

        if (pointid != 0)
        {
            Point_Enter(playerid,pointid);
        }

        return;
    }

    new point[e_POINT];
    Point_Get(inside,point);

    if (GetPlayerVirtualWorld(playerid) == point[E_POINT_INT_VW] && GetPlayerInterior(playerid) == point[E_POINT_INT_INT] && IsPlayerInRangeOfPoint(playerid,POINT_ENTER_RANGE,point[E_POINT_INT_X],point[E_POINT_INT_Y],point[E_POINT_INT_Z]))
    {
        Point_Leave(playerid,inside);
    }
}

stock Point_WakeUp(playerid)
{
    if (!s_PointSleeping[playerid])
    {
        return;
    }

    s_PointSleeping[playerid] = false;
    TogglePlayerControllable(playerid,true);
}

static Point_Sleep(playerid)
{
    yield 1;

    new pointid = Point_FindInterior(playerid,POINT_SLEEP_RANGE);

    if (pointid == 0 || !Point_IsOwner(playerid,pointid))
    {
        SendServerMessage(playerid,"You are not inside a house you own.",MSG_TYPE_ERROR);
        return;
    }

    new point[e_POINT];
    Point_Get(pointid,point);

    if (point[E_POINT_TYPE] != POINT_TYPE_HOUSE)
    {
        SendServerMessage(playerid,"This point isn't a house.",MSG_TYPE_ERROR);
        return;
    }

    if (s_PointSleeping[playerid])
    {
        Point_WakeUp(playerid);
        return;
    }

    new response[DIALOG_RESPONSE];
    TogglePlayerControllable(playerid,false);
    s_PointSleeping[playerid] = true;
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"Point Sleep","You are now sleeping ICly.\n\nYou will recieve half of your paycheck while sleeping along with recieving paychecks 25 percent slower.","Exit","");
}

stock Point_StartSleep(playerid)
{
    SetTimerEx("Point_SleepDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
}

public Point_SleepDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Point_Sleep(playerid);
    }

    return 1;
}

public Point_OnEntered(playerid,pointid)
{
    return 1;
}

public Point_OnLeft(playerid,pointid)
{
    return 1;
}

public Point_OnMotelLoaded(playerid,token)
{
    if (Account_IsCurrent(playerid,token) && cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_spawnmotel",s_PointMotel[playerid]);
    }

    return 1;
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

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (newkeys & KEY_CTRL_BACK)
    {
        Point_UseDoor(playerid);
    }
}

hook OnPlayerConnect(playerid)
{
    Point_SetPlayerPoint(playerid,0);
    s_PointSleeping[playerid] = false;
    s_PointMotel[playerid] = 0;
}

hook OnPlayerDisconnect(playerid,reason)
{
    Point_SetPlayerPoint(playerid,0);
    s_PointSleeping[playerid] = false;
}

hook Character_OnLoad(playerid,characterid)
{
    mysql_tquery_s(g_Mysql,str_format("SELECT character_spawnmotel FROM characters WHERE character_id = %d",characterid),"Point_OnMotelLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    Point_SetPlayerPoint(playerid,0);
    s_PointSleeping[playerid] = false;
}

hook Character_OnSavePosition(playerid)
{
    new pointid = Point_GetPlayerPoint(playerid);
    new point[e_POINT];

    if (pointid != 0 && Point_Get(pointid,point))
    {
        Character_SetSaveOverride(playerid,point[E_POINT_EXT_X],point[E_POINT_EXT_Y],point[E_POINT_EXT_Z]);
    }
}

hook Paycheck_OnInterval(playerid)
{
    if (s_PointSleeping[playerid])
    {
        Paycheck_SetIntervalPercent(playerid,125);
    }
}

hook Paycheck_OnCharges(playerid)
{
    new tax = 0;

    if (Point_GetOwned(playerid,POINT_TYPE_HOUSE) > 0)
    {
        tax += POINT_TAX_HOUSE;
    }

    if (Point_GetOwned(playerid,POINT_TYPE_BIZ) > 0)
    {
        tax += POINT_TAX_BUSINESS;
    }

    if (tax > 0)
    {
        Paycheck_AddCharge(playerid,"Property Tax",tax);
    }
}

hook Tick_OnPlayerSecond(playerid)
{
    if (!s_PointSleeping[playerid])
    {
        return;
    }

    new pointid = Point_FindInterior(playerid,POINT_SLEEP_RANGE);

    if (pointid == 0 || !Point_IsOwner(playerid,pointid))
    {
        Point_WakeUp(playerid);
    }
}

hook Spawn_OnChoiceRequest(playerid,choice)
{
    switch (choice)
    {
        case E_SPAWN_CHOICE_HOUSE:
        {
            if (Point_GetOwned(playerid,POINT_TYPE_HOUSE) < 1)
            {
                SendServerMessage(playerid,"You don't have any house to spawn in.",MSG_TYPE_ERROR);
                return;
            }

            Spawn_SetChoice(playerid,E_SPAWN_CHOICE_HOUSE);
            SendServerMessage(playerid,"You will now spawn in one of your houses.",MSG_TYPE_INFO);
        }
        case E_SPAWN_CHOICE_BUSINESS:
        {
            if (Point_GetOwned(playerid,POINT_TYPE_BIZ) < 1)
            {
                SendServerMessage(playerid,"You don't have any business to spawn in.",MSG_TYPE_ERROR);
                return;
            }

            Spawn_SetChoice(playerid,E_SPAWN_CHOICE_BUSINESS);
            SendServerMessage(playerid,"You will now spawn in one of your businesses.",MSG_TYPE_INFO);
        }
    }
}

hook Spawn_OnChoose(playerid)
{
    new choice = Character_GetSpawnChoice(playerid), pointid = 0, notice[64];

    switch (choice)
    {
        case E_SPAWN_CHOICE_HOUSE:
        {
            pointid = Point_FindOwned(playerid,POINT_TYPE_HOUSE);
            notice = "You have spawned inside your house.";
        }
        case E_SPAWN_CHOICE_BUSINESS:
        {
            pointid = Point_FindOwned(playerid,POINT_TYPE_BIZ);
            notice = "You have spawned inside your business.";
        }
        default:
        {
            return;
        }
    }

    new point[e_POINT];

    if (pointid == 0 || !Point_Get(pointid,point))
    {
        return;
    }

    Spawn_SetPoint(playerid,point[E_POINT_INT_X],point[E_POINT_INT_Y],point[E_POINT_INT_Z],SPAWN_DEFAULT_ANGLE,point[E_POINT_INT_INT],point[E_POINT_INT_VW],E_SPAWN_PRIORITY_CHOICE,notice);
    s_PointSpawnInside[playerid] = pointid;
}

hook Spawn_OnComplete(playerid)
{
    if (s_PointSpawnInside[playerid] != 0)
    {
        new pointid = s_PointSpawnInside[playerid], point[e_POINT];
        s_PointSpawnInside[playerid] = 0;

        if (Point_Get(pointid,point))
        {
            Point_SetPlayerPoint(playerid,pointid);
            Point_ApplyInterior(playerid,point[E_POINT_INT_VW],point[E_POINT_INT_INT]);
        }
    }
}
