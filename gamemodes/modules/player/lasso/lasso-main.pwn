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
#define LASSO_RANGE (10.0)
#define LASSO_UNTIE_RANGE (5.0)
#define LASSO_COOLDOWN_MS (10000)
#define LASSO_RELEASE_MS (300000)
#define LASSO_CATCH_BELOW (5)
#define LASSO_ROLLS (11)
#define LASSO_TICK_MS (500)

new bool:g_LassoMode[MAX_PLAYERS];
new g_LassoTarget[MAX_PLAYERS] = {INVALID_PLAYER_ID,...};
new g_LassoCooldownDue[MAX_PLAYERS];
new g_LassoReleaseDue[MAX_PLAYERS];

forward Lasso_OnCaught(playerid,target);
forward Lasso_OnMissed(playerid,target);
forward Lasso_OnReleased(target,helper);

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
stock bool:Lasso_IsInMode(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && g_LassoMode[playerid];
}

stock bool:Lasso_IsCaught(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && Player_IsBusyWith(playerid,E_PLAYER_BUSY_LASSOED);
}

stock bool:Lasso_OnCooldown(playerid)
{
    return g_LassoCooldownDue[playerid] != 0;
}

stock Lasso_GetTarget(playerid)
{
    return g_LassoTarget[playerid];
}

stock Lasso_GetReleaseDue(playerid)
{
    return g_LassoReleaseDue[playerid];
}

static Lasso_Name(playerid,dest[],size = sizeof(dest))
{
    Account_GetRoleplayName(playerid,dest,size);
}

stock Lasso_Clear(playerid)
{
    g_LassoMode[playerid] = false;
    g_LassoTarget[playerid] = INVALID_PLAYER_ID;
    g_LassoCooldownDue[playerid] = 0;
    g_LassoReleaseDue[playerid] = 0;
    Player_SetBusy(playerid,E_PLAYER_BUSY_LASSOED,false);

    for (new other = 0;other < MAX_PLAYERS;other++)
    {
        if (g_LassoTarget[other] == playerid)
        {
            g_LassoMode[other] = false;
            g_LassoTarget[other] = INVALID_PLAYER_ID;
        }
    }
}

stock Lasso_Release(target,helper = INVALID_PLAYER_ID)
{
    if (!Lasso_IsCaught(target))
    {
        return false;
    }

    g_LassoReleaseDue[target] = 0;
    Player_SetBusy(target,E_PLAYER_BUSY_LASSOED,false);

    if (Injury_GetMode(target) == INJURY_MODE_NORMAL)
    {
        TogglePlayerControllable(target,true);
        ClearAnimations(target,SYNC_ALL);
    }

    if (helper == INVALID_PLAYER_ID)
    {
        SendServerMessage(target,"You have automatically been untied from the lasso.",MSG_TYPE_INFO);
    }
    else
    {
        new name[ACCOUNT_NAME_LEN], line[96];
        Lasso_Name(target,name);
        format(line,sizeof(line),"You untied %s from the lasso.",name);
        SendServerMessage(helper,line,MSG_TYPE_INFO);
        SendServerMessage(target,"You have been freed from the lasso. Please roleplay properly!",MSG_TYPE_INFO);
    }

    pawn_call_public("Lasso_OnReleased","dd",target,helper);
    return true;
}

stock Lasso_Try(playerid,target)
{
    new roll = random(LASSO_ROLLS), name[ACCOUNT_NAME_LEN], line[128];

    g_LassoCooldownDue[playerid] = GetTickCount() + LASSO_COOLDOWN_MS;

    if (g_LassoCooldownDue[playerid] == 0)
    {
        g_LassoCooldownDue[playerid] = 1;
    }

    Lasso_Name(target,name);

    if (roll >= LASSO_CATCH_BELOW)
    {
        SendServerMessage(playerid,"You missed your target!",MSG_TYPE_INFO);
        pawn_call_public("Lasso_OnMissed","dd",playerid,target);
        return false;
    }

    g_LassoMode[playerid] = false;
    g_LassoReleaseDue[target] = GetTickCount() + LASSO_RELEASE_MS;

    if (Player_IsBusyWith(target,E_PLAYER_BUSY_HORSE))
    {
        Horse_ForceDismount(target);
        SendServerMessage(target,"You've been caught by a lasso and pulled off your horse!",MSG_TYPE_INFO);
        format(line,sizeof(line),"You've caught %s with your lasso and pulled them off their horse",name);
    }
    else
    {
        SendServerMessage(target,"You've been caught by a lasso and pulled to the ground!",MSG_TYPE_INFO);
        format(line,sizeof(line),"You've caught %s with your lasso and pulled them to the ground.",name);
    }

    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Player_SetBusy(target,E_PLAYER_BUSY_LASSOED,true);
    TogglePlayerControllable(target,false);
    ApplyAnimation(target,"CRACK","crckidle2",4.0,true,false,false,false,0,SYNC_ALL);
    pawn_call_public("Lasso_OnCaught","dd",playerid,target);
    return true;
}

stock Lasso_Throw(playerid)
{
    new target = g_LassoTarget[playerid];

    if (!g_LassoMode[playerid] || target == INVALID_PLAYER_ID || !IsPlayerConnected(target))
    {
        Lasso_Clear(playerid);
        return;
    }

    if (g_LassoCooldownDue[playerid] != 0)
    {
        SendServerMessage(playerid,"You are currently on a lasso cooldown to prevent abuse! Try again in a few seconds.",MSG_TYPE_ERROR);
        return;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(target,x,y,z);

    if (GetPlayerInterior(playerid) != GetPlayerInterior(target) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(target) || !IsPlayerInRangeOfPoint(playerid,LASSO_RANGE,x,y,z))
    {
        SendServerMessage(playerid,"You are too far from your target. A attempt from here will surely miss!",MSG_TYPE_ERROR);
        return;
    }

    Lasso_Try(playerid,target);
}

stock Lasso_Tick()
{
    new now = GetTickCount();

    for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
    {
        if (!IsPlayerConnected(playerid))
        {
            continue;
        }

        if (g_LassoCooldownDue[playerid] != 0 && now - g_LassoCooldownDue[playerid] >= 0)
        {
            g_LassoCooldownDue[playerid] = 0;
            SendServerMessage(playerid,"Your lasso cooldown has expired, you can now use it again.",MSG_TYPE_INFO);
        }

        if (g_LassoReleaseDue[playerid] != 0 && now - g_LassoReleaseDue[playerid] >= 0)
        {
            Lasso_Release(playerid);
        }
    }
}

public Lasso_OnCaught(playerid,target)
{
    return 1;
}

public Lasso_OnMissed(playerid,target)
{
    return 1;
}

public Lasso_OnReleased(target,helper)
{
    return 1;
}

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
Timer_Declare(Lasso_Timer)
{

    Lasso_Tick();
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
CMD:lasso(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (g_LassoMode[playerid])
    {
        g_LassoMode[playerid] = false;
        g_LassoTarget[playerid] = INVALID_PLAYER_ID;
        SendServerMessage(playerid,"You exited lasso mode.",MSG_TYPE_INFO);
        return 1;
    }

    if (Inventory_GetEquipped(playerid) != E_ITEM_EXTRA_SHERIFF_LASSO)
    {
        SendServerMessage(playerid,"You must have a lasso equipped to use this command.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Posse_IsLawMember(playerid))
    {
        SendServerMessage(playerid,"You are not in a law enforcement posse.",MSG_TYPE_ERROR);
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/lasso [target]",MSG_TYPE_ERROR);
        return 1;
    }

    if (target == INVALID_PLAYER_ID || !IsPlayerConnected(target))
    {
        SendServerMessage(playerid,"Player specified is not connected!",MSG_TYPE_ERROR);
        return 1;
    }

    if (target == playerid)
    {
        SendServerMessage(playerid,"You can't target yourself.",MSG_TYPE_INFO);
        return 1;
    }

    if (Posse_IsLawMember(target))
    {
        SendServerMessage(playerid,"You can't target a player in the same posse as yours!",MSG_TYPE_ERROR);
        return 1;
    }

    new name[ACCOUNT_NAME_LEN], line[160];
    Lasso_Name(target,name);
    g_LassoMode[playerid] = true;
    g_LassoTarget[playerid] = target;
    format(line,sizeof(line),"You have sucessfully entered lasso mode on %s (%i). Use LEFT-CLICK to try catching the target.",name,target);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    SendServerMessage(playerid,"You can exit lasso mode by doing /lasso again.",MSG_TYPE_INFO);
    return 1;
}

CMD:untielasso(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    new Float:px, Float:py, Float:pz, best = INVALID_PLAYER_ID, Float:bestDistance = LASSO_UNTIE_RANGE * LASSO_UNTIE_RANGE;
    GetPlayerPos(playerid,px,py,pz);

    for (new other = 0;other < MAX_PLAYERS;other++)
    {
        if (other == playerid || !IsPlayerConnected(other) || !Lasso_IsCaught(other))
        {
            continue;
        }

        new Float:x, Float:y, Float:z;
        GetPlayerPos(other,x,y,z);
        new Float:distance = ((x - px) * (x - px)) + ((y - py) * (y - py)) + ((z - pz) * (z - pz));

        if (distance <= bestDistance)
        {
            bestDistance = distance;
            best = other;
        }
    }

    if (best == INVALID_PLAYER_ID)
    {
        SendServerMessage(playerid,"You aren't near any players caught in a lasso!",MSG_TYPE_ERROR);
        return 1;
    }

    Lasso_Release(best,playerid);
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
    Timer_Start(Lasso_Timer,LASSO_TICK_MS);
}

hook OnPlayerConnect(playerid)
{
    Lasso_Clear(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Lasso_Clear(playerid);
}

hook Character_OnUnload(playerid,characterid)
{
    Lasso_Clear(playerid);
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if ((newkeys & KEY_FIRE) != KEY:0 && (oldkeys & KEY_FIRE) == KEY:0 && g_LassoMode[playerid])
    {
        Lasso_Throw(playerid);
    }
}
