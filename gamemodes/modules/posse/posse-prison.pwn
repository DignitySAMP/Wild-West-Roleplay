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
#define PRISON_MAX_MINUTES (130)
#define PRISON_TICK_MS (60000)
#define PRISON_RANGE (2.5)

static s_PrisonEnd[MAX_PLAYERS];
static Float:s_PrisonX[MAX_PLAYERS];
static Float:s_PrisonY[MAX_PLAYERS];
static Float:s_PrisonZ[MAX_PLAYERS];
static s_PrisonInterior[MAX_PLAYERS];
static s_PrisonWorld[MAX_PLAYERS];
static s_PrisonBail[MAX_PLAYERS];

forward Prison_OnLoaded(playerid,token);
forward Prison_Deferred(playerid,token,target,targetToken,minutes,bail);
forward Prison_OnReleased(playerid);

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
stock bool:Prison_IsPrisoned(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_PrisonEnd[playerid] != 0;
}

stock Prison_GetSecondsLeft(playerid)
{
    return Prison_IsPrisoned(playerid) ? s_PrisonEnd[playerid] - gettime() : 0;
}

stock Prison_GetBail(playerid)
{
    return s_PrisonBail[playerid];
}

stock Prison_GetEnd(playerid)
{
    return s_PrisonEnd[playerid];
}

static Prison_Write(playerid)
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_prison = %d, character_prison_pos_x = %f, character_prison_pos_y = %f, character_prison_pos_z = %f, character_prison_interior = %d, character_prison_vw = %d, character_prison_bail = %d, character_prison_bail_cents = %d WHERE character_id = %d",s_PrisonEnd[playerid],s_PrisonX[playerid],s_PrisonY[playerid],s_PrisonZ[playerid],s_PrisonInterior[playerid],s_PrisonWorld[playerid],Money_Dollars(s_PrisonBail[playerid]),Money_Cents(s_PrisonBail[playerid]),Character_GetId(playerid)));
}

stock Prison_Start(target,minutes,bail)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(target,x,y,z);
    s_PrisonEnd[target] = gettime() + minutes * 60;
    s_PrisonX[target] = x;
    s_PrisonY[target] = y;
    s_PrisonZ[target] = z;
    s_PrisonInterior[target] = GetPlayerInterior(target);
    s_PrisonWorld[target] = GetPlayerVirtualWorld(target);
    s_PrisonBail[target] = bail;
    Player_SetBusy(target,E_PLAYER_BUSY_PRISON,true);
    Prison_Write(target);
}

stock Prison_Release(playerid)
{
    s_PrisonEnd[playerid] = 0;
    s_PrisonX[playerid] = 0.0;
    s_PrisonY[playerid] = 0.0;
    s_PrisonZ[playerid] = 0.0;
    s_PrisonInterior[playerid] = 0;
    s_PrisonWorld[playerid] = 0;
    s_PrisonBail[playerid] = 0;
    Player_SetBusy(playerid,E_PLAYER_BUSY_PRISON,false);
    Prison_Write(playerid);
    new pointid = Point_FindService(playerid,POINT_BIZ_SHERIFF), point[e_POINT];

    if (pointid != 0 && Point_Get(pointid,point))
    {
        SetPlayerPos(playerid,point[E_POINT_EXT_X],point[E_POINT_EXT_Y],point[E_POINT_EXT_Z]);
        SetPlayerInterior(playerid,point[E_POINT_INT]);
        SetPlayerVirtualWorld(playerid,point[E_POINT_VW]);
        Point_SetPlayerPoint(playerid,0);
    }
    else
    {
        SetPlayerPos(playerid,SERVER_SPAWN_X,SERVER_SPAWN_Y,SERVER_SPAWN_Z);
        SetPlayerInterior(playerid,0);
        SetPlayerVirtualWorld(playerid,0);
    }

    pawn_call_public("Prison_OnReleased","d",playerid);
}

stock Prison_Tick()
{
    new now = gettime();

    foreach (new i : Player)
    {
        if (s_PrisonEnd[i] != 0 && s_PrisonEnd[i] < now)
        {
            Prison_Release(i);
            SendClientMessage(i,COLOR_DEFAULT,"You've done your time and have been released.");
        }
    }
}

Timer_Declare(Prison_Timer)
{

    Prison_Tick();
    return 1;
}

static Prison_Flow(playerid,token,target,targetToken,minutes,bail)
{
    yield 1;

    new response[DIALOG_RESPONSE], body[400], name[ACCOUNT_NAME_LEN];
    Posse_DisplayName(target,false,name);
    format(body,sizeof(body),"{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\nYou're about to prison %s for %i %s.\nMake sure the time is correct and that %s is in a cell.\n\nWith that in mind, go ahead.",name,minutes,minutes == 1 ? ("minute") : ("minutes"),name);
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"{C23030}WARNING",body,"{C23030}Proceed","Cancel");

    if (!Account_IsCurrent(playerid,token) || !Account_IsCurrent(target,targetToken) || !response[DIALOG_RESPONSE_RESPONSE] || !Posse_IsLawMember(playerid) || s_PrisonEnd[target] != 0)
    {
        return;
    }

    new line[200], rank[POSSE_RANK_LEN], mine[ACCOUNT_NAME_LEN];
    Prison_Start(target,minutes,bail);
    format(line,sizeof(line),"You've been put into prison for %i %s.",minutes,minutes == 1 ? ("minute") : ("minutes"));
    SendServerMessage(target,line,MSG_TYPE_INFO);
    Posse_GetRank(playerid,rank);
    Posse_DisplayName(playerid,false,mine);
    format(line,sizeof(line),"{[ %s %s has prisoned %s for %i %s. ]}",rank,mine,name,minutes,minutes == 1 ? ("minute") : ("minutes"));
    Posse_Warning(Posse_GetPlayer(playerid),line);
    Log_Info("prison","%s (%d) has prisoned %s (%d) for %i %s.",mine,playerid,name,target,minutes,minutes == 1 ? ("minute") : ("minutes"));
}

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
CMD:prisontimeleft(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (!Prison_IsPrisoned(playerid))
    {
        SendServerMessage(playerid,"You aren't in jail/prison!",MSG_TYPE_ERROR);
        return 1;
    }

    new left = Prison_GetSecondsLeft(playerid), line[96];

    if (left > 0)
    {
        format(line,sizeof(line),"Prison/jail time left: %d minutes",left / 60);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
    }
    else
    {
        SendServerMessage(playerid,"Prison/jail time left: Less than 1 minute remaining.",MSG_TYPE_INFO);
    }

    return 1;
}

CMD:prison(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Posse_IsLawMember(playerid))
    {
        SendServerMessage(playerid,"You have to be in a police posse in order to do this command.",MSG_TYPE_INFO);
        return 1;
    }

    new target, minutes, bail, cents;

    if (sscanf(params,"uiI(0)I(0)",target,minutes,bail,cents))
    {
        SendServerMessage(playerid,"Syntax: /prison <user> <time: minutes> <bail (dollars): total of all fines, if none add 25. To disable, add 0.> <optional:cents>",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_IsValidTarget(target))
    {
        SendServerMessage(playerid,"This player isn't connected!",MSG_TYPE_INFO);
        return 1;
    }

    if (minutes > PRISON_MAX_MINUTES)
    {
        SendServerMessage(playerid,"You can't arrest someone longer than 130 minutes.",MSG_TYPE_WARN);
        return 1;
    }

    if (minutes < 1)
    {
        SendServerMessage(playerid,"You can't arrest someone for less than 1 minute.",MSG_TYPE_WARN);
        return 1;
    }

    if (Prison_IsPrisoned(target))
    {
        SendServerMessage(playerid,"This player is already in prison!",MSG_TYPE_WARN);
        return 1;
    }

    if (bail < 0)
    {
        SendServerMessage(playerid,"You cannot set someone's bail to a negative amount.",MSG_TYPE_WARN);
        return 1;
    }

    if (cents < 0 || cents > 99)
    {
        SendServerMessage(playerid,"You can only set cents between 0-99 cent(s).",MSG_TYPE_WARN);
        return 1;
    }

    SetTimerEx("Prison_Deferred",0,false,"dddddd",playerid,Account_GetToken(playerid),target,Account_GetToken(target),minutes,Money_Make(bail,cents));
    return 1;
}

CMD:unprison(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Posse_IsLawMember(playerid))
    {
        SendServerMessage(playerid,"You have to be in a police posse in order to do this command.",MSG_TYPE_INFO);
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"Syntax: /unprison <user>",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_IsValidTarget(target))
    {
        SendServerMessage(playerid,"Player isn't online.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Prison_IsPrisoned(target))
    {
        SendServerMessage(playerid,"This player isn't in prison!",MSG_TYPE_WARN);
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(target,x,y,z);

    if (!IsPlayerInRangeOfPoint(playerid,PRISON_RANGE,x,y,z) || GetPlayerInterior(playerid) != GetPlayerInterior(target) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(target))
    {
        SendServerMessage(playerid,"You are not near that player.",MSG_TYPE_ERROR);
        return 1;
    }

    new rank[POSSE_RANK_LEN], mine[ACCOUNT_NAME_LEN], name[ACCOUNT_NAME_LEN], line[200];
    Posse_GetRank(playerid,rank);
    Posse_DisplayName(playerid,false,mine);
    Posse_DisplayName(target,false,name);
    Prison_Release(target);
    format(line,sizeof(line),"You have been released from prison by %s %s.",rank,mine);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"{[ %s %s has unprisoned %s. ]}",rank,mine,name);
    Posse_Warning(Posse_GetPlayer(playerid),line);
    return 1;
}

CMD:bail(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (!Prison_IsPrisoned(playerid))
    {
        SendServerMessage(playerid,"You don't seem to be prisoned. Contact an admin if you are.",MSG_TYPE_ERROR);
        return 1;
    }

    new bail = s_PrisonBail[playerid];

    if (bail <= 0)
    {
        SendServerMessage(playerid,"You're not eligible for bail.",MSG_TYPE_ERROR);
        return 1;
    }

    new whole[16], line[160];
    Money_Delimit(Money_Dollars(bail),whole);

    if (!Money_CanAfford(playerid,bail))
    {
        format(line,sizeof(line),"You don't have enough money for your bail! Total: $%s.%02d",whole,Money_Cents(bail));
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return 1;
    }

    new posseid = Posse_FirstOfType(POSSE_TYPE_GOVERNMENT);

    if (posseid == 0)
    {
        SendServerMessage(playerid,"Bail isn't accepted right now.",MSG_TYPE_ERROR);
        return 1;
    }

    Money_Take(playerid,bail);
    Posse_BankGive(posseid,bail);
    new name[ACCOUNT_NAME_LEN];
    Posse_DisplayName(playerid,false,name);
    format(line,sizeof(line),"{[ %s (%d) has paid for their bail. ]}",name,playerid);
    Posse_Message(posseid,line);
    SendServerMessage(playerid,"You've paid for your crimes.",MSG_TYPE_INFO);
    Prison_Release(playerid);
    return 1;
}

public Prison_Deferred(playerid,token,target,targetToken,minutes,bail)
{
    if (Account_IsCurrent(playerid,token) && Account_IsCurrent(target,targetToken))
    {
        Prison_Flow(playerid,token,target,targetToken,minutes,bail);
    }

    return 1;
}

public Prison_OnReleased(playerid)
{
    return 1;
}

public Prison_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    s_PrisonEnd[playerid] = 0;

    if (cache_num_rows() > 0)
    {
        new dollars, cents;
        cache_get_value_name_int(0,"character_prison",s_PrisonEnd[playerid]);
        cache_get_value_name_float(0,"character_prison_pos_x",s_PrisonX[playerid]);
        cache_get_value_name_float(0,"character_prison_pos_y",s_PrisonY[playerid]);
        cache_get_value_name_float(0,"character_prison_pos_z",s_PrisonZ[playerid]);
        cache_get_value_name_int(0,"character_prison_interior",s_PrisonInterior[playerid]);
        cache_get_value_name_int(0,"character_prison_vw",s_PrisonWorld[playerid]);
        cache_get_value_name_int(0,"character_prison_bail",dollars);
        cache_get_value_name_int(0,"character_prison_bail_cents",cents);
        s_PrisonBail[playerid] = Money_Make(dollars,cents);
    }

    Player_SetBusy(playerid,E_PLAYER_BUSY_PRISON,s_PrisonEnd[playerid] != 0);
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

hook OnGameModeInit()
{
    Timer_Start(Prison_Timer,PRISON_TICK_MS);
}

hook OnPlayerConnect(playerid)
{
    s_PrisonEnd[playerid] = 0;
    s_PrisonBail[playerid] = 0;
}

hook Character_OnLoad(playerid,characterid)
{
    mysql_tquery_s(g_Mysql,str_format("SELECT character_prison, character_prison_pos_x, character_prison_pos_y, character_prison_pos_z, character_prison_interior, character_prison_vw, character_prison_bail, character_prison_bail_cents FROM characters WHERE character_id = %d",characterid),"Prison_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    s_PrisonEnd[playerid] = 0;
    Player_SetBusy(playerid,E_PLAYER_BUSY_PRISON,false);
}

hook Spawn_OnChoose(playerid)
{
    if (s_PrisonEnd[playerid] == 0)
    {
        return;
    }

    if (s_PrisonEnd[playerid] > gettime())
    {
        Spawn_SetPoint(playerid,s_PrisonX[playerid],s_PrisonY[playerid],s_PrisonZ[playerid],SPAWN_DEFAULT_ANGLE,s_PrisonInterior[playerid],s_PrisonWorld[playerid],E_SPAWN_PRIORITY_PRISON,"",true);
        return;
    }

    s_PrisonEnd[playerid] = 0;
    s_PrisonX[playerid] = 0.0;
    s_PrisonY[playerid] = 0.0;
    s_PrisonZ[playerid] = 0.0;
    s_PrisonInterior[playerid] = 0;
    s_PrisonWorld[playerid] = 0;
    Player_SetBusy(playerid,E_PLAYER_BUSY_PRISON,false);
    Prison_Write(playerid);
}

hook Spawn_OnComplete(playerid)
{
    if (s_PrisonEnd[playerid] != 0)
    {
        if (random(2) == 0)
        {
            SendClientMessage(playerid,COLOR_DEFAULT,"** You've woken up from fighting inside the cell block..");
        }
        else
        {
            SendClientMessage(playerid,COLOR_DEFAULT,"** You've woken up from a guard arguing with another inmate..");
        }
    }
}
