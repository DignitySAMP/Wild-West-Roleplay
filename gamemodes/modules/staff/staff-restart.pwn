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
#include <pp-hooks>

#define RESTART_DELAY (30)
#define RESTART_WARN_AT (10)
#define RESTART_TICK_MS (1000)
#define RESTART_REASON_LEN (64)

forward Staff_OnServerRestart();
forward Restart_Timer();

static s_RestartDue;
static bool:s_RestartWarned;
static s_RestartReason[RESTART_REASON_LEN];
static s_RestartBy[MAX_PLAYER_NAME];
static bool:s_RestartIssued;
static bool:s_RestartLive = true;

public Staff_OnServerRestart()
{
    return 1;
}

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
stock bool:Restart_IsPending()
{
    return s_RestartDue != 0;
}

stock Restart_GetSecondsLeft()
{
    return s_RestartDue == 0 ? -1 : s_RestartDue - gettime();
}

stock bool:Restart_WasIssued()
{
    return s_RestartIssued;
}

static Restart_Fire()
{
    s_RestartDue = 0;
    s_RestartWarned = false;
    SendClientMessageToAll(COLOR_STAFF,"[SERVER]:{DEDEDE} The server is restarting now.");
    Log_Info("staff/restart","%s restarted the server: %s",s_RestartBy,s_RestartReason);
    pawn_call_public("Staff_OnServerRestart","");
    s_RestartIssued = true;

    if (s_RestartLive)
    {
        SendRconCommand("gmx");
    }
}

public Restart_Timer()
{
    if (s_RestartDue == 0)
    {
        return 1;
    }

    new left = s_RestartDue - gettime();

    if (left <= 0)
    {
        Restart_Fire();
        return 1;
    }

    if (left <= RESTART_WARN_AT && !s_RestartWarned)
    {
        s_RestartWarned = true;
        SendClientMessageToAll(COLOR_STAFF,"[SERVER]:{DEDEDE} The server restarts in 10 seconds.");
    }

    return 1;
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
CMD:gmx(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireManager(playerid))
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME], line[160];
    GetPlayerName(playerid,name,sizeof(name));

    if (!strcmp(params,"cancel",true) && params[0] != EOS)
    {
        if (s_RestartDue == 0)
        {
            SendServerMessage(playerid,"No restart is pending.",MSG_TYPE_ERROR);
            return 1;
        }

        s_RestartDue = 0;
        s_RestartWarned = false;
        SendClientMessageToAll(COLOR_STAFF,"[SERVER]:{DEDEDE} The server restart has been cancelled.");
        Log_Info("staff/restart","%s cancelled the restart: %s",name,s_RestartReason);
        return 1;
    }

    if (s_RestartDue != 0)
    {
        SendServerMessage(playerid,"A restart is already pending. Use /gmx cancel to stop it.",MSG_TYPE_ERROR);
        return 1;
    }

    if (sscanf(params,"s[64]",s_RestartReason))
    {
        SendServerMessage(playerid,"/gmx [reason] or /gmx cancel",MSG_TYPE_ERROR);
        return 1;
    }

    strcopy(s_RestartBy,name,sizeof(s_RestartBy));
    s_RestartDue = gettime() + RESTART_DELAY;
    s_RestartWarned = false;
    format(line,sizeof(line),"[SERVER]:{DEDEDE} %s restarts the server in 30 seconds (%s). Card games will be refunded.",name,s_RestartReason);
    SendClientMessageToAll(COLOR_STAFF,line);
    Log_Info("staff/restart","%s started a restart: %s",name,s_RestartReason);
    return 1;
}
