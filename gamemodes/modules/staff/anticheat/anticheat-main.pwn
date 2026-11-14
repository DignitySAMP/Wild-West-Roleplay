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
#define AC_MAX_WARNINGS (3)
#define AC_SPEED_FOOT (175.0)
#define AC_SPEED_WILD (600.0)
#define AC_FLY_HEIGHT (5.0)
#define AC_FLY_MIN_Z (6.0)
#define AC_AMMO_LIMIT (150)
#define AC_DECAY_SECONDS (30)
#define AC_LOSS_SECONDS (300)
#define AC_LOSS_LIMIT (10.0)
#define AC_CBUG_MS (650)
#define AC_FREEZE_MS (750)
#define AC_FREEZE_TICK_MS (250)
#define AC_STRIKES_TO_KICK (3)
#define AC_WEAPON_CAMERA (43)

enum
{
    AC_COUNT_MONEY,
    AC_COUNT_WEAPON,
    AC_COUNT_STRIKE,
    AC_COUNT_SPEED,
    AC_COUNT_FLY,
    AC_COUNTERS
}

static const g_AcDisallowed[] =
{
    1,2,3,9,10,11,12,13,16,17,22,23,27,28,29,30,31,32,35,36,37,38,39,40,41,42,44,45,46
};

static s_AcCount[MAX_PLAYERS][AC_COUNTERS];
static s_AcDecay[MAX_PLAYERS];
static s_AcLoss[MAX_PLAYERS];
static s_AcLastRevolver[MAX_PLAYERS];
static s_AcFreezeDue[MAX_PLAYERS];
static Float:s_AcPos[MAX_PLAYERS][3];

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
stock AC_SetPlayerPos(playerid,Float:x,Float:y,Float:z,bool:stream = true)
{
    s_AcPos[playerid][0] = x;
    s_AcPos[playerid][1] = y;
    s_AcPos[playerid][2] = z;
    SetPlayerPos(playerid,x,y,z);

    if (stream)
    {
        Streamer_Update(playerid);
    }
}

stock bool:AC_IsDisallowedWeapon(weaponid)
{
    for (new i = 0;i < sizeof(g_AcDisallowed);i++)
    {
        if (g_AcDisallowed[i] == weaponid)
        {
            return true;
        }
    }

    return false;
}

stock Float:AC_HorseLimit(type)
{
    switch (type)
    {
        case 4: return 203.0;
        case 5: return 227.0;
    }

    return 181.0;
}

stock Float:AC_GetSpeed(playerid)
{
    new Float:vx, Float:vy, Float:vz;
    GetPlayerVelocity(playerid,vx,vy,vz);
    return floatsqroot(vx * vx + vy * vy) * 200.0;
}

stock bool:AC_IsExempt(playerid)
{
    return Staff_IsModerator(playerid) && Staff_IsOnDuty(playerid);
}

static AC_Name(playerid,dest[],size = sizeof(dest))
{
    Name_Real(playerid,dest,size);
}

static bool:AC_Hit(playerid,counter,const text[])
{
    if (++s_AcCount[playerid][counter] <= AC_MAX_WARNINGS)
    {
        return false;
    }

    s_AcCount[playerid][counter] = 0;
    SendModeratorWarning(text,MOD_WARNING_HIGH);
    Log_Info("anticheat","%s",text);
    return true;
}

static AC_Warn(const text[])
{
    SendModeratorWarning(text,MOD_WARNING_HIGH);
    Log_Info("anticheat","%s",text);
}

stock bool:AC_CheckLoss(playerid,Float:loss)
{
    if (loss <= AC_LOSS_LIMIT)
    {
        return false;
    }

    new name[MAX_PLAYER_NAME + 1], line[160];
    AC_Name(playerid,name);
    format(line,sizeof(line),"You're desynced! Packets lost: %.2f percent.",loss);
    SendClientMessage(playerid,COLOR_RED,line);
    format(line,sizeof(line),"[DESYNC] (%d) %s IS DESYNCED. Packets lost: %.2f percent. !!! MAKE THEM RELOG !!!",playerid,name,loss);
    SendModeratorWarning(line,MOD_WARNING_MED);
    return true;
}

static AC_Announce(playerid,const verb[],const reason[],bool:ban)
{
    new line[160], name[ACCOUNT_NAME_LEN];
    AC_Name(playerid,name);
    format(line,sizeof(line),"[ANTICHEAT] %s (%d) has been %s for %s.",name,playerid,verb,reason);
    SendSplitMessageToAll(COLOR_STAFF,line);
    Log_Info("anticheat","%s",line);

    if (ban)
    {
        format(line,sizeof(line),"%s: anticheat detection",reason);
        line[0] = toupper(line[0]);
        Staff_Ban(playerid,0,"Anticheat",0,line);
    }
    else
    {
        format(line,sizeof(line),"%s: anticheat detection",reason);
        line[0] = toupper(line[0]);
        Staff_Kick(playerid,0,line);
    }
}

stock AC_Check(playerid)
{
    if (!Player_IsSpawned(playerid) || Player_IsPaused(playerid))
    {
        return;
    }

    new line[200], name[ACCOUNT_NAME_LEN], client, hand, bool:isLoaded = Weapons_IsLoaded(playerid);
    AC_Name(playerid,name);
    client = GetPlayerWeapon(playerid);
    hand = isLoaded ? Weapons_Get(playerid,E_GUN_SLOT_HAND) : 0;

    if (Character_GetLevel(playerid) < 3 && client != 0 && client != hand && client != AC_WEAPON_CAMERA)
    {
        format(line,sizeof(line),"[WEAPON] (%d) %s is below level 3 but has a weapon. (client gun doesnt match server gun)",playerid,name);
        AC_Warn(line);
    }

    if (!Account_IsLoggedIn(playerid))
    {
        format(line,sizeof(line),"[EPP] (%d) %s has spawned without being logged in. They should be kicked. If not, kick them.",playerid,name);
        AC_Warn(line);
    }

    if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && !AC_IsExempt(playerid))
    {
        new Float:speed = AC_GetSpeed(playerid), bool:riding = Horse_IsRiding(playerid), Float:limit = riding ? AC_HorseLimit(Horse_GetType(playerid)) : AC_SPEED_FOOT;

        if (speed > AC_SPEED_WILD)
        {
            format(line,sizeof(line),"[ANTICHEAT] (%d) %s is moving at %.2f, far beyond any normal speed!",playerid,name,speed);
            AC_Warn(line);
        }
        else if (speed > limit)
        {
            if (riding)
            {
                format(line,sizeof(line),"[ANTICHEAT] (%d) %s may be speed hacking! (On Horse) NORMAL SPEED: %.0f, HAS SPEED: %.2f",playerid,name,limit,speed);
            }
            else
            {
                format(line,sizeof(line),"[ANTICHEAT] (%d) %s may be speed hacking! NORMAL SPEED: 175, HAS SPEED: %.2f",playerid,name,speed);
            }

            AC_Hit(playerid,AC_COUNT_SPEED,line);
        }
    }

    if (Money_IsLoaded(playerid))
    {
        new serverMoney = Money_Get(playerid) / 100, clientMoney = GetPlayerMoney(playerid);

        if (clientMoney != serverMoney)
        {
            Money_SyncClient(playerid);
            format(line,sizeof(line),"[ANTICHEAT] (%d) %s may be money hacking! Client money: %d, server money: %d",playerid,name,clientMoney,serverMoney);
            AC_Hit(playerid,AC_COUNT_MONEY,line);
        }
    }

    if (client != 0 && client != hand && !(client == AC_WEAPON_CAMERA && Inventory_GetEquipped(playerid) == E_ITEM_EXTRA_CAMERA))
    {
        if (isLoaded)
        {
            Weapons_SyncEngine(playerid);
        }

        format(line,sizeof(line),"[ANTICHEAT] (%d) %s may be weapon hacking! Client weapon: %d, server weapon %d",playerid,name,client,hand);
        AC_Hit(playerid,AC_COUNT_WEAPON,line);

        if (AC_IsDisallowedWeapon(client))
        {
            s_AcCount[playerid][AC_COUNT_STRIKE]++;
            format(line,sizeof(line),"[ANTICHEAT] (%d) %s holds a weapon the server never gave (%d), strike %d of %d.",playerid,name,client,s_AcCount[playerid][AC_COUNT_STRIKE],AC_STRIKES_TO_KICK);
            AC_Warn(line);

            if (s_AcCount[playerid][AC_COUNT_STRIKE] >= AC_STRIKES_TO_KICK)
            {
                s_AcCount[playerid][AC_COUNT_STRIKE] = 0;
                AC_Announce(playerid,"kicked","weapon hacking",false);
            }
        }
    }
    else if (client != 0 && client == hand)
    {
        new clientAmmo = GetPlayerAmmo(playerid), serverAmmo = Weapons_GetAmmo(playerid,E_GUN_SLOT_HAND);

        if (clientAmmo > serverAmmo)
        {
            SetPlayerAmmo(playerid,WEAPON:hand,serverAmmo);

            if (clientAmmo > AC_AMMO_LIMIT)
            {
                format(line,sizeof(line),"[ANTICHEAT] (%d) %s may be ammo hacking! Client ammo: %d, server ammo %d",playerid,name,clientAmmo,serverAmmo);
                AC_Warn(line);
            }
        }
    }

    new Float:armour;
    GetPlayerArmour(playerid,armour);

    if (armour > 1.0)
    {
        SetPlayerArmour(playerid,0.0);
        format(line,sizeof(line),"[ANTICHEAT] (%d) %s may be armour hacking! Armour: %.0f",playerid,name,armour);
        AC_Warn(line);
    }

    new bool:jetpack = GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK;

    if (jetpack)
    {
        SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);
        AC_Announce(playerid,"banned","jetpack hacking",true);
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);

    if (z > AC_FLY_MIN_Z && GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0 && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
    {
        new Float:ground, bool:found = CA_FindZ_For2DCoord(x,y,ground) != 0;

        if (found && z > ground + AC_FLY_HEIGHT)
        {
            format(line,sizeof(line),"[ANTICHEAT] (%d) %s may be fly hacking! GROUND: %.2f, PLAYER HEIGHT: %.2f",playerid,name,ground,z);
            AC_Hit(playerid,AC_COUNT_FLY,line);
        }
    }
}

stock AC_Decay(playerid)
{
    for (new i = 0;i < AC_COUNTERS;i++)
    {
        if (s_AcCount[playerid][i] > 0)
        {
            s_AcCount[playerid][i]--;
        }
    }
}

stock AC_GetCounter(playerid,counter)
{
    return s_AcCount[playerid][counter];
}

stock bool:AC_IsFrozen(playerid)
{
    return s_AcFreezeDue[playerid] != 0;
}

static AC_CheckRevolver(playerid)
{
    new now = GetTickCount(), line[128], name[ACCOUNT_NAME_LEN];

    if (s_AcLastRevolver[playerid] != 0 && now - s_AcLastRevolver[playerid] < AC_CBUG_MS)
    {
        AC_Name(playerid,name);
        format(line,sizeof(line),"(%d) %s has tried to c-bug.",playerid,name);
        Log_Info("anticheat/cbug","%s",line);
        TogglePlayerControllable(playerid,false);
        s_AcFreezeDue[playerid] = now + AC_FREEZE_MS;

        if (s_AcFreezeDue[playerid] == 0)
        {
            s_AcFreezeDue[playerid] = 1;
        }
    }

    s_AcLastRevolver[playerid] = now;

    if (s_AcLastRevolver[playerid] == 0)
    {
        s_AcLastRevolver[playerid] = 1;
    }
}

stock AC_ReleaseFrozen()
{
    new now = GetTickCount();

    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (s_AcFreezeDue[i] != 0 && IsPlayerConnected(i) && now - s_AcFreezeDue[i] >= 0)
        {
            s_AcFreezeDue[i] = 0;
            TogglePlayerControllable(i,true);
        }
    }
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

Timer_Declare(AC_Timer)
{
    AC_ReleaseFrozen();
    return 1;
}

hook OnGameModeInit()
{
    Timer_Start(AC_Timer,AC_FREEZE_TICK_MS);
}

hook OnPlayerConnect(playerid)
{
    for (new i = 0;i < AC_COUNTERS;i++)
    {
        s_AcCount[playerid][i] = 0;
    }

    s_AcDecay[playerid] = 0;
    s_AcLoss[playerid] = 0;
    s_AcLastRevolver[playerid] = 0;
    s_AcFreezeDue[playerid] = 0;
}

hook Tick_OnPlayerSecond(playerid)
{

    AC_Check(playerid);

    if (++s_AcLoss[playerid] >= AC_LOSS_SECONDS)
    {
        s_AcLoss[playerid] = 0;
        AC_CheckLoss(playerid,NetStats_PacketLossPercent(playerid));
    }

    if (++s_AcDecay[playerid] >= AC_DECAY_SECONDS)
    {
        s_AcDecay[playerid] = 0;
        AC_Decay(playerid);
    }
}

hook Weapon_OnShot(playerid,weaponid,ammo)
{
    if (weaponid == 24)
    {
        AC_CheckRevolver(playerid);
    }
}
