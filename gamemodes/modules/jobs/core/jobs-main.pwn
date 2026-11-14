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
Timer_Declare(Jobs_Timer)
{

    Jobs_Tick();
    return 1;
}

public Jobs_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    Jobs_ResetData(playerid);

    if (cache_num_rows() > 0)
    {
        new names[4][8] = {"","fish","mine","wood"};

        for (new job = E_JOB_FISHING;job < E_JOB_COUNT;job++)
        {
            new column[32];
            format(column,sizeof(column),"character_%scd",names[job]);
            cache_get_value_name_int(0,column,g_JobCooldown[playerid][job]);
            format(column,sizeof(column),"character_%sactionsleft",names[job]);
            cache_get_value_name_int(0,column,g_JobActions[playerid][job]);
        }
    }

    g_JobLoaded[playerid] = true;
    return 1;
}

stock Jobs_Tick()
{
    for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
    {
        if (!IsPlayerConnected(playerid) || g_JobKind[playerid] == E_JOB_NONE)
        {
            continue;
        }

        switch (g_JobKind[playerid])
        {
            case E_JOB_FISHING:
            {
                Fishing_Decay(playerid);
            }
            case E_JOB_MINING:
            {
                Mining_Decay(playerid);
            }
            case E_JOB_LUMBER:
            {
                Lumber_Decay(playerid);
            }
        }
    }

    Mining_Tick();
    Lumber_Tick();

    if (++g_JobExpiryCount >= JOB_EXPIRY_TICKS)
    {
        g_JobExpiryCount = 0;

        for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
        {
            if (IsPlayerConnected(playerid) && g_JobLoaded[playerid])
            {
                Jobs_ExpireCooldowns(playerid);
            }
        }
    }
}

static bool:Jobs_Throttle(&tick)
{
    new now = GetTickCount();

    if (now - tick < JOB_KEY_COOLDOWN_MS && tick != 0)
    {
        return true;
    }

    tick = now;

    if (tick == 0)
    {
        tick = 1;
    }

    return false;
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
    Migration_Add("jobs-1-columns","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_fishcd INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_woodcd INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_minecd INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_fishactionsleft INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_woodactionsleft INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_mineactionsleft INT NOT NULL DEFAULT 0");
}

hook OnGameModeInit()
{
    Mining_Init();
    Lumber_Init();
    Scatter_Init();
    Timer_Start(Jobs_Timer,JOB_TICK_MS);
}

hook OnPlayerConnect(playerid)
{
    Jobs_ResetData(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Jobs_Reset(playerid);
    Jobs_ResetData(playerid);
}

hook Character_OnLoad(playerid,characterid)
{
    mysql_tquery_s(g_Mysql,str_format("SELECT character_fishcd, character_woodcd, character_minecd, character_fishactionsleft, character_woodactionsleft, character_mineactionsleft FROM characters WHERE character_id = %d",characterid),"Jobs_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    Jobs_Fix(playerid);
    Jobs_ResetData(playerid);
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    new tool = Inventory_GetEquipped(playerid);

    if (tool == EQUIP_NONE)
    {
        return;
    }

    if ((newkeys & KEY_FIRE) != KEY:0 && Jobs_IsDoing(playerid))
    {
        if (!Jobs_Throttle(g_JobFixTick[playerid]))
        {
            Jobs_Fix(playerid);
        }

        return;
    }

    if ((newkeys & KEY_WALK) != KEY:0 && (oldkeys & KEY_WALK) == KEY:0)
    {
        if (tool != E_ITEM_EXTRA_FISHING_ROD && tool != E_ITEM_EXTRA_MINE_PICKAXE && tool != E_ITEM_EXTRA_LUMBER_HATCHET)
        {
            return;
        }

        if (Jobs_Throttle(g_JobKeyTick[playerid]))
        {
            return;
        }

        switch (tool)
        {
            case E_ITEM_EXTRA_FISHING_ROD:
            {
                Fishing_Start(playerid);
            }
            case E_ITEM_EXTRA_MINE_PICKAXE:
            {
                Mining_Start(playerid);
            }
            default:
            {
                Lumber_Start(playerid);
            }
        }

        return;
    }

    if ((newkeys & KEY_HANDBRAKE) != KEY:0)
    {
        switch (g_JobKind[playerid])
        {
            case E_JOB_FISHING:
            {
                Fishing_Reel(playerid);
            }
            case E_JOB_MINING:
            {
                Mining_Progress(playerid);
            }
            case E_JOB_LUMBER:
            {
                Lumber_Progress(playerid);
            }
        }
    }
}

hook OnPlayerLeaveDynamicArea(playerid,STREAMER_TAG_AREA:areaid)
{
    if (_:areaid == INVALID_STREAMER_ID || areaid != g_JobCircle[playerid])
    {
        return;
    }

    Jobs_Fix(playerid);
}
