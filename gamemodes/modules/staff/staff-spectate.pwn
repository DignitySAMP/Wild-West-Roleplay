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
#define SPECTATE_NONE (INVALID_PLAYER_ID)
#define SPECTATE_COMMAND_COLOUR (0xDEDEDEFF)

static s_SpectateTarget[MAX_PLAYERS] = {SPECTATE_NONE,...};
static bool:s_SpectateSaved[MAX_PLAYERS];
static bool:s_SpectateRestore[MAX_PLAYERS];
static Float:s_SpectateX[MAX_PLAYERS];
static Float:s_SpectateY[MAX_PLAYERS];
static Float:s_SpectateZ[MAX_PLAYERS];
static s_SpectateInterior[MAX_PLAYERS];
static s_SpectateWorld[MAX_PLAYERS];

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
stock Staff_GetSpectating(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return SPECTATE_NONE;
    }

    return s_SpectateTarget[playerid];
}

stock bool:Staff_IsSpectating(playerid)
{
    return Staff_GetSpectating(playerid) != SPECTATE_NONE;
}

static bool:Spectate_IsWatchable(playerid,targetid)
{
    return targetid != playerid && targetid >= 0 && targetid < MAX_PLAYERS && IsPlayerConnected(targetid) && !IsPlayerNPC(targetid) && Player_IsReady(targetid);
}

static Spectate_Point(playerid,targetid)
{
    SetPlayerInterior(playerid,GetPlayerInterior(targetid));
    SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(targetid));
    PlayerSpectatePlayer(playerid,targetid);
    s_SpectateTarget[playerid] = targetid;
}

stock bool:Spectate_Start(playerid,targetid)
{
    if (!Spectate_IsWatchable(playerid,targetid))
    {
        return false;
    }

    if (!s_SpectateSaved[playerid])
    {
        GetPlayerPos(playerid,s_SpectateX[playerid],s_SpectateY[playerid],s_SpectateZ[playerid]);
        s_SpectateInterior[playerid] = GetPlayerInterior(playerid);
        s_SpectateWorld[playerid] = GetPlayerVirtualWorld(playerid);
        s_SpectateSaved[playerid] = true;
    }

    SetPlayerInterior(playerid,GetPlayerInterior(targetid));
    SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(targetid));
    TogglePlayerSpectating(playerid,true);
    PlayerSpectatePlayer(playerid,targetid);
    s_SpectateTarget[playerid] = targetid;
    return true;
}

stock bool:Spectate_Stop(playerid)
{
    if (s_SpectateTarget[playerid] == SPECTATE_NONE)
    {
        return false;
    }

    s_SpectateTarget[playerid] = SPECTATE_NONE;
    s_SpectateRestore[playerid] = s_SpectateSaved[playerid];
    s_SpectateSaved[playerid] = false;
    PlayerSpectatePlayer(playerid,INVALID_PLAYER_ID);
    TogglePlayerSpectating(playerid,false);
    return true;
}

stock bool:Spectate_Step(playerid,direction)
{
    new current = s_SpectateTarget[playerid];

    if (current == SPECTATE_NONE || direction == 0)
    {
        return false;
    }

    new step = direction > 0 ? 1 : -1;

    for (new i = 1;i <= MAX_PLAYERS;i++)
    {
        new candidate = ((current + step * i) % MAX_PLAYERS + MAX_PLAYERS) % MAX_PLAYERS;

        if (!Spectate_IsWatchable(playerid,candidate))
        {
            continue;
        }

        new line[96], name[ACCOUNT_NAME_LEN];
        GetPlayerName(candidate,name,sizeof(name));
        Spectate_Point(playerid,candidate);
        format(line,sizeof(line),"You are now spectating %s (ID: %d).",name,candidate);
        SendServerMessage(playerid,line,MSG_TYPE_WARN);
        return true;
    }

    return false;
}

static Spectate_Release(targetid,bool:message)
{
    foreach (new i : Player)
    {
        if (i != targetid && s_SpectateTarget[i] == targetid)
        {
            Spectate_Stop(i);

            if (message)
            {
                SendServerMessage(i,"The player you were spectating is gone, you are no longer in spectator mode.",MSG_TYPE_WARN);
            }
        }
    }
}

static Spectate_Reset(playerid)
{
    s_SpectateTarget[playerid] = SPECTATE_NONE;
    s_SpectateSaved[playerid] = false;
    s_SpectateRestore[playerid] = false;
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
CMD:spectate(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    if (!strcmp(params,"off",true))
    {
        if (!Spectate_Stop(playerid))
        {
            SendServerMessage(playerid,"You are not spectating any player.",MSG_TYPE_ERROR);
            return 1;
        }

        new line[96], name[ACCOUNT_NAME_LEN];
        GetPlayerName(playerid,name,sizeof(name));
        format(line,sizeof(line),"[SPEC] %s (%d) has stopped spectating.",name,playerid);
        SendModeratorWarning(line,MOD_WARNING_MED);
        SendServerMessage(playerid,"You are no longer in spectator mode.",MSG_TYPE_WARN);
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/spectate [playerid/name] - Type \"/spectate off\" to stop spectating.",MSG_TYPE_ERROR);
        return 1;
    }

    if (target == playerid)
    {
        SendServerMessage(playerid,"You can't spectate yourself.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_IsValidTarget(target))
    {
        SendServerMessage(playerid,"You have specified an invalid player.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Spectate_Start(playerid,target))
    {
        SendServerMessage(playerid,"That player has not entered the world with a character yet.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[256], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN], note[ACCOUNT_NOTE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    Account_GetNote(target,note);
    format(line,sizeof(line),"(%d) %s's admin note: %s",target,targetName,note);
    SendClientMessage(playerid,COLOR_YELLOW,line);

    if (!Staff_IsManager(playerid))
    {
        format(line,sizeof(line),"[SPEC] %s (%d) is spectating %s (%d)",name,playerid,targetName,target);
        SendModeratorWarning(line,MOD_WARNING_MED);
    }

    if (Account_GetRuleCheck(target))
    {
        SendServerMessage(playerid,"This player's account is flagged as a \"Potential Rulebreaker\".",MSG_TYPE_WARN);
    }

    return 1;
}

ALT:spec=CMD:spectate;

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
    Spectate_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Spectate_Release(playerid,true);
    Spectate_Reset(playerid);
}

hook Character_OnUnload(playerid,characterid)
{
    Spectate_Release(playerid,true);
    Spectate_Reset(playerid);
}

hook OnPlayerSpawn(playerid)
{
    if (!s_SpectateRestore[playerid])
    {
        return;
    }

    s_SpectateRestore[playerid] = false;
    SetPlayerPos(playerid,s_SpectateX[playerid],s_SpectateY[playerid],s_SpectateZ[playerid]);
    SetPlayerInterior(playerid,s_SpectateInterior[playerid]);
    SetPlayerVirtualWorld(playerid,s_SpectateWorld[playerid]);
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (s_SpectateTarget[playerid] == SPECTATE_NONE)
    {
        return;
    }

    if (newkeys & KEY_FIRE)
    {
        Spectate_Step(playerid,1);
    }
    else if (newkeys & KEY_AIM)
    {
        Spectate_Step(playerid,-1);
    }
}

hook Command_OnPerformed(playerid,const cmdtext[],success)
{
    foreach (new i : Player)
    {
        if (s_SpectateTarget[i] != playerid)
        {
            continue;
        }

        new line[160], name[ACCOUNT_NAME_LEN];
        GetPlayerName(playerid,name,sizeof(name));
        format(line,sizeof(line),"[SPEC]: (%d) %s tried command (performed): %s",playerid,name,cmdtext);
        SendClientMessage(i,SPECTATE_COMMAND_COLOUR,line);
    }
}

hook Tick_OnPlayerSecond(playerid)
{
    new target = s_SpectateTarget[playerid];

    if (target == SPECTATE_NONE)
    {
        return;
    }

    if (!Spectate_IsWatchable(playerid,target))
    {
        Spectate_Stop(playerid);
        return;
    }

    if (GetPlayerInterior(playerid) != GetPlayerInterior(target) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(target))
    {
        Spectate_Point(playerid,target);
    }
}
