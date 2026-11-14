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
#define JAIL_X (154.1281)
#define JAIL_Y (-1951.9653)
#define JAIL_Z (47.4766)
#define JAIL_ANGLE (90.0)
#define JAIL_TICK_MS (60000)
#define JAIL_OFFLINE_MIN (10)
#define JAIL_OFFLINE_MAX (120)
#define JAIL_TEXT "~w~~n~~n~~n~~n~~n~Time left in admin jail:~n~~r~%d~w~ minutes"

static s_JailMinutes[MAX_PLAYERS];
static bool:s_Jailed[MAX_PLAYERS];

forward Jail_OnLoaded(playerid,token);
forward OfflineJail_Deferred(playerid,token,minutes,const reason[],const name[]);

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
stock bool:Jail_IsJailed(playerid)
{
    return s_Jailed[playerid];
}

stock Jail_GetMinutes(playerid)
{
    return s_JailMinutes[playerid];
}

static Jail_Save(playerid)
{
    mysql_pquery_s(g_Mysql,str_format("UPDATE characters SET character_ajailed = %d WHERE character_id = %d",s_JailMinutes[playerid],Character_GetId(playerid)));
}

static Jail_Place(playerid,bool:showTime)
{
    SetPlayerInterior(playerid,0);
    SetPlayerVirtualWorld(playerid,0);
    SetPlayerPos(playerid,JAIL_X,JAIL_Y,JAIL_Z);
    TogglePlayerControllable(playerid,true);

    if (showTime)
    {
        new line[96];
        format(line,sizeof(line),JAIL_TEXT,s_JailMinutes[playerid]);
        GameTextForPlayer(playerid,line,59500,3);
    }
}

static Jail_Release(playerid)
{
    s_Jailed[playerid] = false;
    s_JailMinutes[playerid] = 0;
    Player_SetBusy(playerid,E_PLAYER_BUSY_JAIL,false);
    TogglePlayerControllable(playerid,true);
    SendServerMessage(playerid,"You've been released from admin jail. Try to behave this time.",MSG_TYPE_INFO);
    Spawn_Begin(playerid);
}

stock Jail_Tick()
{
    foreach (new i : Player)
    {
        if (!s_Jailed[i] || !Player_IsReady(i))
        {
            continue;
        }

        if (s_JailMinutes[i] <= 0)
        {
            Jail_Release(i);
            continue;
        }

        new line[96];
        format(line,sizeof(line),JAIL_TEXT,s_JailMinutes[i]);
        GameTextForPlayer(i,line,59500,3);
        s_JailMinutes[i]--;
        SetPlayerPos(i,JAIL_X,JAIL_Y,JAIL_Z);
        TogglePlayerControllable(i,true);
        Jail_Save(i);
    }
}

stock Jail_Start(targetid,adminAccountId,minutes,const reason[])
{
    s_JailMinutes[targetid] = minutes;
    s_Jailed[targetid] = true;
    Player_SetBusy(targetid,E_PLAYER_BUSY_JAIL,true);
    Jail_Save(targetid);
    Jail_Place(targetid,true);
    Staff_AddRecord(Account_GetId(targetid),adminAccountId,E_RECORD_TYPE_AJAIL,reason,minutes);
}

static OfflineJail_Run(playerid,minutes,const reason[],const name[])
{
    yield 1;

    new token = Account_GetToken(playerid);
    await mysql_aquery_s(g_Mysql,str_format("SELECT character_id, account_id FROM characters WHERE character_name = '%e' LIMIT 1",name),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (cache_num_rows() == 0)
    {
        SendServerMessage(playerid,"Database didn't return any account data. Maybe your mistyped the name.",MSG_TYPE_WARN);
        return;
    }

    new characterId, accountId, line[256], adminName[ACCOUNT_NAME_LEN];
    cache_get_value_name_int(0,"character_id",characterId);
    cache_get_value_name_int(0,"account_id",accountId);
    mysql_pquery_s(g_Mysql,str_format("UPDATE characters SET character_ajailed = %d WHERE character_id = %d",minutes,characterId));
    Staff_AddRecord(accountId,Account_GetId(playerid),E_RECORD_TYPE_AJAIL,reason,minutes);
    GetPlayerName(playerid,adminName,sizeof(adminName));
    format(line,sizeof(line),"[STAFF] %s (%d) has offline jailed %s for \"%s\"",adminName,playerid,name,reason);
    SendSplitMessageToAll(COLOR_STAFF,line);
    Staff_Log("staff/ajail",line);
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
CMD:ajail(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target, minutes, reason[64];

    if (sscanf(params,"uis[64]",target,minutes,reason))
    {
        SendServerMessage(playerid,"/ajail [player] [time in minutes] [reason]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    if (!Player_IsReady(target))
    {
        SendServerMessage(playerid,"That player has not entered the world with a character yet.",MSG_TYPE_ERROR);
        return 1;
    }

    if (minutes < 1)
    {
        SendServerMessage(playerid,"Admin jail time has to be at least 1 minute.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[256], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    Jail_Start(target,Account_GetId(playerid),minutes,reason);

    format(line,sizeof(line),"[STAFF] %s (%d) has ajailed %s (%d) for %d minutes",name,playerid,targetName,target,minutes);
    SendSplitMessageToAll(COLOR_STAFF,line);
    format(line,sizeof(line),"[STAFF] Reason: \"%s\"",reason);
    SendSplitMessageToAll(COLOR_STAFF,line);
    format(line,sizeof(line),"%s (%d) has ajailed %s (%d) for %d minutes. Reason: \"%s\"",name,playerid,targetName,target,minutes,reason);
    Staff_Log("staff/ajail",line);
    return 1;
}

CMD:unajail(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/unajail [playerid]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    if (!Player_IsReady(target))
    {
        SendServerMessage(playerid,"That player has not entered the world with a character yet.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!s_Jailed[target])
    {
        s_JailMinutes[target] = 0;
        Jail_Save(target);
        SendServerMessage(playerid,"Player doesn't seem to be in admin jail, but their data has been reset nonetheless.",MSG_TYPE_WARN);
        return 1;
    }

    new line[160], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    s_JailMinutes[target] = 0;
    Jail_Save(target);
    Jail_Release(target);
    format(line,sizeof(line),"[STAFF] %s (%d) has unjailed %s (%d)",name,playerid,targetName,target);
    SendSplitMessageToAll(COLOR_STAFF,line);
    Staff_Log("staff/unjail",line);
    return 1;
}

CMD:offlinejail(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new name[ACCOUNT_NAME_LEN], minutes, reason[64];

    if (sscanf(params,"s[25]is[64]",name,minutes,reason))
    {
        SendServerMessage(playerid,"/offlinejail [character] [time in minutes] [reason] ( use /getma or /getc to get acc name )",MSG_TYPE_ERROR);
        return 1;
    }

    if (minutes < JAIL_OFFLINE_MIN || minutes > JAIL_OFFLINE_MAX)
    {
        SendServerMessage(playerid,"You can't admin jail someone for more than 2 hours or less than 10 minutes.",MSG_TYPE_ERROR);
        return 1;
    }

    foreach (new i : Player)
    {
        new current[ACCOUNT_NAME_LEN];
        GetPlayerName(i,current,sizeof(current));

        if (!strcmp(name,current,true))
        {
            new line[96];
            format(line,sizeof(line),"Player seems to be connected as ID %d. Use /ajail instead.",i);
            SendServerMessage(playerid,line,MSG_TYPE_WARN);
            return 1;
        }
    }

    SetTimerEx("OfflineJail_Deferred",0,false,"dddss",playerid,Account_GetToken(playerid),minutes,reason,name);
    return 1;
}

ALT:ojail=CMD:offlinejail;

/**
 *                        __  __  __                            __
 *                       |  \|  \|  \                          |  |
 *      _______  ______  | $$| $$| $$____    ______    _______ | $$   __   _______
 *     /       \|      \ | $$| $$| $$    \  |      \  /       \| $$  /  \ /       |
 *    |  $$$$$$$ \$$$$$$\| $$| $$| $$$$$$$\  \$$$$$$\|  $$$$$$$| $$_/  $$|  $$$$$$$
 *    | $$      /      $$| $$| $$| $$  | $$ /      $$| $$      | $$   $$  \$$    |
 *    | $$_____|  $$$$$$$| $$| $$| $$__/ $$|  $$$$$$$| $$_____ | $$$$$$\  _\$$$$$$|
 *     \$$     \\$$    $$| $$| $$| $$    $$ \$$    $$ \$$     \| $$  \$$\|       $$
 *      \$$$$$$$ \$$$$$$$ \$$ \$$ \$$$$$$$   \$$$$$$$  \$$$$$$$ \$$   \$$ \$$$$$$$
 *
 */
Timer_Declare(Jail_TickTimer)
{

    Jail_Tick();
    return 1;
}

public Jail_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    new minutes = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_ajailed",minutes);
    }

    s_JailMinutes[playerid] = minutes;
    s_Jailed[playerid] = minutes > 0;
    Player_SetBusy(playerid,E_PLAYER_BUSY_JAIL,minutes > 0);
    return 1;
}

public OfflineJail_Deferred(playerid,token,minutes,const reason[],const name[])
{
    if (Account_IsCurrent(playerid,token))
    {
        OfflineJail_Run(playerid,minutes,reason,name);
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

hook OnGameModeInit()
{
    Timer_Start(Jail_TickTimer,JAIL_TICK_MS);
}

hook OnPlayerConnect(playerid)
{
    s_JailMinutes[playerid] = 0;
    s_Jailed[playerid] = false;
}

hook Character_OnLoad(playerid,characterid)
{
    s_JailMinutes[playerid] = 0;
    s_Jailed[playerid] = false;
    mysql_tquery_s(g_Mysql,str_format("SELECT character_ajailed FROM characters WHERE character_id = %d",characterid),"Jail_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    s_Jailed[playerid] = false;
    s_JailMinutes[playerid] = 0;
    Player_SetBusy(playerid,E_PLAYER_BUSY_JAIL,false);
}

hook Spawn_OnChoose(playerid)
{
    if (s_Jailed[playerid] && s_JailMinutes[playerid] > 0)
    {
        Spawn_SetPoint(playerid,JAIL_X,JAIL_Y,JAIL_Z,JAIL_ANGLE,0,0,E_SPAWN_PRIORITY_JAIL,"",false);
    }
}

hook Spawn_OnComplete(playerid)
{
    if (!s_Jailed[playerid] || s_JailMinutes[playerid] <= 0)
    {
        return;
    }

    new line[80];
    format(line,sizeof(line),"You have %d minutes left in admin jail.",s_JailMinutes[playerid]);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    TogglePlayerControllable(playerid,false);
    SendServerMessage(playerid,"You've been returned to admin jail.",MSG_TYPE_WARN);
}
