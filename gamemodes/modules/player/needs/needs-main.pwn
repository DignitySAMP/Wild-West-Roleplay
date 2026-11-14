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
#define NEEDS_TICK_MS (600000)
#define NEEDS_MAX (100)
#define NEEDS_HUNGER_STEP (1)
#define NEEDS_THIRST_STEP (2)
#define NEEDS_WARN_BELOW (50)
#define NEEDS_REALLY_BELOW (25)
#define NEEDS_PAUSE_MS (2000)

static s_NeedsHunger[MAX_PLAYERS];
static s_NeedsThirst[MAX_PLAYERS];
static bool:s_NeedsLoaded[MAX_PLAYERS];
static s_NeedsLastUpdate[MAX_PLAYERS];

forward Needs_OnLoaded(playerid,token);

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
stock bool:Needs_IsLoaded(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_NeedsLoaded[playerid];
}

stock Needs_GetHunger(playerid)
{
    return Needs_IsLoaded(playerid) ? s_NeedsHunger[playerid] : 0;
}

stock Needs_GetThirst(playerid)
{
    return Needs_IsLoaded(playerid) ? s_NeedsThirst[playerid] : 0;
}

stock bool:Player_IsPaused(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid))
    {
        return false;
    }

    return GetTickCount() - s_NeedsLastUpdate[playerid] > NEEDS_PAUSE_MS;
}

stock Player_GetPausedMs(playerid)
{
    if (!Player_IsPaused(playerid))
    {
        return 0;
    }

    return GetTickCount() - s_NeedsLastUpdate[playerid];
}

static Needs_Save(playerid)
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_hunger = %d, character_thirst = %d WHERE character_id = %d",s_NeedsHunger[playerid],s_NeedsThirst[playerid],Character_GetId(playerid)));
}

static Needs_Clamp(value)
{
    if (value < 0)
    {
        return 0;
    }

    return value > NEEDS_MAX ? NEEDS_MAX : value;
}

stock bool:Needs_Set(playerid,hunger,thirst)
{
    if (!Needs_IsLoaded(playerid))
    {
        return false;
    }

    s_NeedsHunger[playerid] = Needs_Clamp(hunger);
    s_NeedsThirst[playerid] = Needs_Clamp(thirst);
    Hud_SetHunger(playerid,s_NeedsHunger[playerid]);
    Hud_SetThirst(playerid,s_NeedsThirst[playerid]);
    Needs_Save(playerid);
    return true;
}

stock bool:Needs_Give(playerid,hunger,thirst)
{
    if (!Needs_IsLoaded(playerid))
    {
        return false;
    }

    return Needs_Set(playerid,s_NeedsHunger[playerid] + hunger,s_NeedsThirst[playerid] + thirst);
}

forward Needs_OnHealthDamage(playerid,Float:amount);

stock Needs_DamageHealth(playerid,Float:amount)
{

    pawn_call_public("Needs_OnHealthDamage","df",playerid,amount);
}

stock bool:Needs_IsEligible(playerid)
{
    if (!Player_IsReady(playerid) || !Needs_IsLoaded(playerid) || Staff_IsOnDuty(playerid) || Player_IsPaused(playerid))
    {
        return false;
    }

    return true;
}

static Needs_Warn(playerid,const text[])
{
    Fade_In(playerid);
    SendClientMessage(playerid,-1," ");
    SendServerMessage(playerid,text,MSG_TYPE_WARN);
    SendClientMessage(playerid,-1," ");
}

stock bool:Needs_StepPlayer(playerid)
{
    if (!Needs_IsEligible(playerid))
    {
        return false;
    }

    new Float:cost = 0.0;
    s_NeedsHunger[playerid] = Needs_Clamp(s_NeedsHunger[playerid] - NEEDS_HUNGER_STEP);
    s_NeedsThirst[playerid] = Needs_Clamp(s_NeedsThirst[playerid] - NEEDS_THIRST_STEP);

    if (s_NeedsHunger[playerid] < NEEDS_WARN_BELOW)
    {
        if (s_NeedsHunger[playerid] < NEEDS_REALLY_BELOW)
        {
            Needs_Warn(playerid,"You're starting to get REALLY hungry! You should eat soon!");
            cost += 3.0;
        }
        else
        {
            cost += 1.0;
        }
    }

    if (s_NeedsThirst[playerid] < NEEDS_WARN_BELOW)
    {
        if (s_NeedsThirst[playerid] < NEEDS_REALLY_BELOW)
        {
            Needs_Warn(playerid,"You're starting to get REALLY thirsty! You should drink soon!");
            cost += 3.0;
        }
        else
        {
            cost += 1.0;
        }
    }

    if (cost > 0.0)
    {
        Needs_DamageHealth(playerid,cost);
    }

    Hud_SetHunger(playerid,s_NeedsHunger[playerid]);
    Hud_SetThirst(playerid,s_NeedsThirst[playerid]);
    Needs_Save(playerid);
    return true;
}

stock Needs_Tick()
{
    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        Needs_StepPlayer(i);
    }
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
public Needs_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    s_NeedsHunger[playerid] = NEEDS_MAX;
    s_NeedsThirst[playerid] = NEEDS_MAX;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_hunger",s_NeedsHunger[playerid]);
        cache_get_value_name_int(0,"character_thirst",s_NeedsThirst[playerid]);
    }

    s_NeedsHunger[playerid] = Needs_Clamp(s_NeedsHunger[playerid]);
    s_NeedsThirst[playerid] = Needs_Clamp(s_NeedsThirst[playerid]);
    s_NeedsLoaded[playerid] = true;
    Hud_SetHunger(playerid,s_NeedsHunger[playerid]);
    Hud_SetThirst(playerid,s_NeedsThirst[playerid]);
    return 1;
}

Timer_Declare(Needs_TickTimer)
{

    Needs_Tick();
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

hook OnMigrationRun()
{
    Migration_Add("needs-1-hunger-thirst","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_hunger INT NOT NULL DEFAULT 100, ADD COLUMN IF NOT EXISTS character_thirst INT NOT NULL DEFAULT 100");
}

hook OnGameModeInit()
{
    Timer_Start(Needs_TickTimer,NEEDS_TICK_MS);
}

hook OnPlayerConnect(playerid)
{
    s_NeedsHunger[playerid] = NEEDS_MAX;
    s_NeedsThirst[playerid] = NEEDS_MAX;
    s_NeedsLoaded[playerid] = false;
    s_NeedsLastUpdate[playerid] = GetTickCount();
}

hook OnPlayerUpdate(playerid)
{
    s_NeedsLastUpdate[playerid] = GetTickCount();
}

hook Character_OnLoad(playerid,characterid)
{
    s_NeedsLoaded[playerid] = false;
    mysql_tquery_s(g_Mysql,str_format("SELECT character_hunger, character_thirst FROM characters WHERE character_id = %d",characterid),"Needs_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    s_NeedsLoaded[playerid] = false;
    s_NeedsHunger[playerid] = NEEDS_MAX;
    s_NeedsThirst[playerid] = NEEDS_MAX;
}

public Needs_OnHealthDamage(playerid,Float:amount)
{
    return 1;
}
