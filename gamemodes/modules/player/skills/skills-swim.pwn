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
#define SWIM_TICK_MS (1250)
#define SWIM_PASSOUT_TICKS (30)
#define SWIM_WARN_TICKS (15)
#define SWIM_SPRINT_WARN_TICKS (5)
#define SWIM_ANIM_FIRST (1538)
#define SWIM_ANIM_LAST (1544)
#define SWIM_SHORE_RANGE (200.0)
#define SWIM_SHORE_COUNT (9)

static const Float:s_SwimShore[SWIM_SHORE_COUNT][3] =
{
    {-686.8016,753.1329,1.7368},
    {-703.9090,716.8571,4.5989},
    {-783.2010,949.5403,0.8289},
    {-645.6351,1339.789,2.3973},
    {-1358.520,1690.508,1.8135},
    {-1865.594,2141.875,1.1363},
    {-1398.375,2132.951,43.176},
    {-1181.057,2676.636,41.364},
    {-2310.521,2517.633,1.7807}
};

static s_SwimTicks[MAX_PLAYERS];
static s_SwimWarn[MAX_PLAYERS];
static s_SwimSprintWarn[MAX_PLAYERS];

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
stock bool:Skills_IsSwimming(playerid)
{

    new animation = GetPlayerAnimationIndex(playerid);
    return animation >= SWIM_ANIM_FIRST && animation <= SWIM_ANIM_LAST;
}

stock Skills_GetSwimTicks(playerid)
{
    return s_SwimTicks[playerid];
}

stock Skills_NearShore(playerid,Float:range,point = -1)
{
    if (point == -1)
    {
        for (new i = 0;i < SWIM_SHORE_COUNT;i++)
        {
            if (IsPlayerInRangeOfPoint(playerid,range,s_SwimShore[i][0],s_SwimShore[i][1],s_SwimShore[i][2]))
            {
                return i;
            }
        }

        return -1;
    }

    if (point >= 0 && point < SWIM_SHORE_COUNT)
    {
        return IsPlayerInRangeOfPoint(playerid,range,s_SwimShore[point][0],s_SwimShore[point][1],s_SwimShore[point][2]) ? point : -1;
    }

    return -1;
}

static Skills_PassOut(playerid)
{
    s_SwimTicks[playerid] = 0;

    switch (random(3))
    {
        case 0:
        {
            SendServerMessage(playerid,"You lost your footing and slowly float to the bottom of the ocean..",MSG_TYPE_WARN);
        }
        case 1:
        {
            SendServerMessage(playerid,"You got a really bad cramp. You let yourself go deeper into the water as your eyes shut..",MSG_TYPE_WARN);
        }
        case 2:
        {
            SendServerMessage(playerid,"You puff in exhaustion. You aren't used to swimming like this. Everything slowly fades black..",MSG_TYPE_WARN);
        }
    }

    new shore = Skills_NearShore(playerid,SWIM_SHORE_RANGE);

    if (shore == -1)
    {
        SendServerMessage(playerid,"You're not near any shore. You're slowly starting to drown.",MSG_TYPE_ERROR);
        SetPlayerHealth(playerid,0.0);
        return;
    }

    SetPlayerPos(playerid,s_SwimShore[shore][0],s_SwimShore[shore][1],s_SwimShore[shore][2]);

    switch (random(6))
    {
        case 0:
        {
            ApplyAnimation(playerid,"CRACK","crckdeth1",4.1,false,false,false,true,0,SYNC_ALL);
        }
        case 1:
        {
            ApplyAnimation(playerid,"CRACK","crckdeth2",4.1,true,false,false,false,0,SYNC_ALL);
        }
        case 2:
        {
            ApplyAnimation(playerid,"CRACK","crckdeth3",4.1,false,false,false,true,0,SYNC_ALL);
        }
        case 3:
        {
            ApplyAnimation(playerid,"CRACK","crckidle1",4.1,false,false,false,true,0,SYNC_ALL);
        }
        case 4:
        {
            ApplyAnimation(playerid,"CRACK","crckidle2",4.1,false,false,false,true,0,SYNC_ALL);
        }
        case 5:
        {
            ApplyAnimation(playerid,"CRACK","crckidle3",4.1,false,false,false,true,0,SYNC_ALL);
        }
    }

    Needs_DamageHealth(playerid,float(5 + random(15)));
}

stock Skills_StepSwim(playerid)
{
    if (!Player_IsReady(playerid) || !Skills_IsLoaded(playerid))
    {
        return;
    }

    if (!Skills_IsSwimming(playerid))
    {
        s_SwimTicks[playerid] = 0;
        s_SwimWarn[playerid] = 0;
        s_SwimSprintWarn[playerid] = 0;
        return;
    }

    new KEY:keys, upDown, leftRight, skill = Skills_Get(playerid,E_SKILL_MISC_SWIMMING);
    GetPlayerKeys(playerid,keys,upDown,leftRight);

    if (keys == KEY_SPRINT && skill < 2)
    {
        if (s_SwimSprintWarn[playerid] == 0)
        {
            SendServerMessage(playerid,"You can't swim that quickly yet! You need swimming level two or higher. (/skills)",MSG_TYPE_ERROR);
        }

        if (++s_SwimSprintWarn[playerid] > SWIM_SPRINT_WARN_TICKS)
        {
            s_SwimSprintWarn[playerid] = 0;
        }

        ApplyAnimation(playerid,"CARRY","crry_prtial",4.0,false,false,false,false,0);
    }

    if (skill < 1 && ++s_SwimTicks[playerid] > SWIM_PASSOUT_TICKS)
    {
        Skills_PassOut(playerid);
        return;
    }

    if (skill < 1)
    {
        if (s_SwimWarn[playerid] == 1)
        {
            SendServerMessage(playerid,"You can't swim properly! You should get to a shore before you drown. (/skills)",MSG_TYPE_ERROR);
        }

        if (++s_SwimWarn[playerid] > SWIM_WARN_TICKS)
        {
            s_SwimWarn[playerid] = 0;
        }
    }
}

stock Skills_SwimTick()
{
    foreach (new i : Player)
    {
        Skills_StepSwim(i);
    }
}

Timer_Declare(Skills_SwimTimer)
{

    Skills_SwimTick();
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
    Timer_Start(Skills_SwimTimer,SWIM_TICK_MS);
}

hook OnPlayerConnect(playerid)
{
    s_SwimTicks[playerid] = 0;
    s_SwimWarn[playerid] = 0;
    s_SwimSprintWarn[playerid] = 0;
}
