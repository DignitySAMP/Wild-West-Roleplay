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
#define BURN_SLOT (0)
#define BURN_MODEL (18691)
#define BURN_BONE (1)
#define BURN_STOP_MS (1500)
#define BURN_WEAPON (37)

forward Atch_Resync(playerid);
forward Burn_OnStart(playerid);
forward Burn_OnStop(playerid);

public Burn_OnStart(playerid)
{
    return 1;
}

public Burn_OnStop(playerid)
{
    return 1;
}

static bool:s_Burning[MAX_PLAYERS];
static s_BurnLast[MAX_PLAYERS];

stock bool:Burn_IsBurning(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_Burning[playerid];
}

static Burn_Stop(playerid)
{
    s_Burning[playerid] = false;
    RemovePlayerAttachedObject(playerid,BURN_SLOT);
    Atch_Resync(playerid);
    pawn_call_public("Burn_OnStop","d",playerid);
}

static Burn_Check(playerid)
{
    if (s_Burning[playerid] && GetTickCount() - s_BurnLast[playerid] >= BURN_STOP_MS)
    {
        Burn_Stop(playerid);
    }
}

#include <pp-hooks>

hook OnPlayerConnect(playerid)
{
    s_Burning[playerid] = false;
    s_BurnLast[playerid] = 0;
}

hook OnPlayerDisconnect(playerid,reason)
{
    s_Burning[playerid] = false;
}

hook OnPlayerTakeDamage(playerid,issuerid,Float:amount,WEAPON:weaponid,bodypart)
{
    if (_:weaponid != BURN_WEAPON)
    {
        return;
    }

    s_BurnLast[playerid] = GetTickCount();

    if (!s_Burning[playerid])
    {
        s_Burning[playerid] = true;
        SetPlayerAttachedObject(playerid,BURN_SLOT,BURN_MODEL,BURN_BONE);
        pawn_call_public("Burn_OnStart","d",playerid);
    }
}

hook Tick_OnPlayerSecond(playerid)
{
    Burn_Check(playerid);
}

