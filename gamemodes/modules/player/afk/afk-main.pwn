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
#define GATE_GAP_MS (1750)
#define AFK_WARN_SECONDS (540)
#define AFK_KICK_SECONDS (600)
#define AFK_COMMAND_WARN_SECONDS (1740)
#define AFK_COMMAND_KICK_SECONDS (1800)
#define AFK_MOVE_RANGE (0.5)
#define GATE_SPEC_COLOUR (0xDEDEDEFF)

forward Command_OnGate(playerid,cmdid,const cmdtext[]);

static s_GateGap = GATE_GAP_MS;
static s_LastCommand[MAX_PLAYERS];
static s_AfkSeconds[MAX_PLAYERS];
static Float:s_AfkPosition[MAX_PLAYERS][3];
static bool:s_AfkSampled[MAX_PLAYERS];

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
stock Afk_GetSeconds(playerid)
{
    return s_AfkSeconds[playerid];
}

public Command_OnGate(playerid,cmdid,const cmdtext[])
{
    foreach (new i : Player)
    {
        if (Staff_GetSpectating(i) == playerid)
        {
            new line[200], name[MAX_PLAYER_NAME + 1];
            GetPlayerName(playerid,name,sizeof(name));
            format(line,sizeof(line),"[SPEC]: (%d) %s tried command (received): %s",playerid,name,cmdtext);
            SendClientMessage(i,GATE_SPEC_COLOUR,line);
        }
    }

    if (Point_IsSleeping(playerid) && strcmp(cmdtext,"/point sleep"))
    {
        SendServerMessage(playerid,"You can't use any commands while using /point sleep.",MSG_TYPE_ERROR);
        return 0;
    }

    if (Staff_IsModerator(playerid) || s_GateGap <= 0)
    {
        return 1;
    }

    new elapsed = GetTickCount() - s_LastCommand[playerid];

    if (elapsed < s_GateGap)
    {
        new line[96];
        format(line,sizeof(line),"You must wait %0.2f seconds to use any command.",float(s_GateGap - elapsed) / 1000.0);
        SendServerMessage(playerid,line,MSG_TYPE_WARN);
        return 0;
    }

    return 1;
}

static Afk_Kick(playerid)
{
    SendServerMessage(playerid,"You've been kicked for being AFK.",MSG_TYPE_WARN);
    s_AfkSeconds[playerid] = 0;
    Account_QueueKick(playerid);
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
CMD:afk(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (Switch_IsRunning(playerid))
    {
        SendServerMessage(playerid,"You cannot use this while switching characters.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Afk_IsAfk(playerid))
    {
        Afk_SetAfk(playerid,true);
        TogglePlayerControllable(playerid,false);
        SendServerMessage(playerid,"You are now afk, you won't be kicked for 30 minutes.",MSG_TYPE_INFO);
    }
    else
    {
        Afk_SetAfk(playerid,false);
        TogglePlayerControllable(playerid,true);
        SendServerMessage(playerid,"You are no longer AFK.",MSG_TYPE_INFO);
    }

    s_AfkSeconds[playerid] = 0;
    Nametag_Refresh(playerid);
    return 1;
}

CMD:afklist(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_BLUE,"List of all AFK players");

    foreach (new i : Player)
    {
        if (!Player_IsPaused(i))
        {
            continue;
        }

        new line[128], name[MAX_PLAYER_NAME + 1];
        GetPlayerName(i,name,sizeof(name));
        format(line,sizeof(line),"(%d) %s: paused for %d seconds.%s",i,name,Player_GetPausedMs(i) / 1000,Point_IsSleeping(i) ? (" [Sleeping]") : (""));
        SendClientMessage(playerid,COLOR_DEFAULT,line);
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

hook OnPlayerConnect(playerid)
{
    s_LastCommand[playerid] = 0;
    s_AfkSeconds[playerid] = 0;
    s_AfkSampled[playerid] = false;
    Afk_SetAfk(playerid,false);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Afk_SetAfk(playerid,false);
}

hook Command_OnPerformed(playerid,const cmdtext[],success)
{
    if (success)
    {
        s_LastCommand[playerid] = GetTickCount();
    }
}

hook Tick_OnPlayerSecond(playerid)
{
    if (!Player_IsReady(playerid) || !Player_IsSpawned(playerid))
    {
        s_AfkSeconds[playerid] = 0;
        s_AfkSampled[playerid] = false;
        return;
    }

    Nametag_Refresh(playerid);

    if (Staff_IsModerator(playerid))
    {
        s_AfkSeconds[playerid] = 0;
        return;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);

    if (!s_AfkSampled[playerid] || (!Afk_IsAfk(playerid) && (floatabs(x - s_AfkPosition[playerid][0]) > AFK_MOVE_RANGE || floatabs(y - s_AfkPosition[playerid][1]) > AFK_MOVE_RANGE || floatabs(z - s_AfkPosition[playerid][2]) > AFK_MOVE_RANGE)))
    {
        s_AfkSampled[playerid] = true;
        s_AfkPosition[playerid][0] = x;
        s_AfkPosition[playerid][1] = y;
        s_AfkPosition[playerid][2] = z;

        if (!Afk_IsAfk(playerid))
        {
            s_AfkSeconds[playerid] = 0;
            return;
        }
    }

    if (Point_IsSleeping(playerid))
    {
        return;
    }

    s_AfkSeconds[playerid]++;

    if (!Afk_IsAfk(playerid))
    {
        if (s_AfkSeconds[playerid] == AFK_WARN_SECONDS)
        {
            SendServerMessage(playerid,"You will be kicked for inactivity in one minute. Move around to avoid this.",MSG_TYPE_WARN);
        }
        else if (s_AfkSeconds[playerid] >= AFK_KICK_SECONDS)
        {
            Afk_Kick(playerid);
        }

        return;
    }

    if (s_AfkSeconds[playerid] == AFK_COMMAND_WARN_SECONDS)
    {
        SendServerMessage(playerid,"You will be kicked for inactivity in one minute. Use /afk to avoid this.",MSG_TYPE_WARN);
    }
    else if (s_AfkSeconds[playerid] >= AFK_COMMAND_KICK_SECONDS)
    {
        Afk_Kick(playerid);
    }
}
