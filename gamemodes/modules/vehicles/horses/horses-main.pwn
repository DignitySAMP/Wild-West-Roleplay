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
forward Horse_OnLoaded(playerid,token);

Timer_Declare(Horse_Timer)
{
    Horse_Tick();
    return 1;
}

public Horse_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    Horse_ResetData(playerid);
    new type = HORSE_NONE, Float:health = HORSE_MAX_HEALTH;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_horseid",type);
        cache_get_value_name_float(0,"character_horsehealth",health);

        for (new slot = 0;slot < HORSE_SADDLE_SLOTS;slot++)
        {
            new weapon, ammo;
            cache_get_value_name_int(0,slot == 0 ? "character_sb_gun0" : "character_sb_gun1",weapon);
            cache_get_value_name_int(0,slot == 0 ? "character_sb_ammo0" : "character_sb_ammo1",ammo);
            Horse_SetSaddle(playerid,slot,weapon,ammo);
        }
    }

    Horse_SetType(playerid,type);
    Horse_SetStoredHealth(playerid,health);
    Horse_SetLoaded(playerid,true);
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
    Migration_Add("horses-1-columns","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_horseid INT NOT NULL DEFAULT -1, ADD COLUMN IF NOT EXISTS character_horsehealth FLOAT NOT NULL DEFAULT 100, ADD COLUMN IF NOT EXISTS character_sb_gun0 INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_sb_gun1 INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_sb_ammo0 INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_sb_ammo1 INT NOT NULL DEFAULT 0");
}

hook OnGameModeInit()
{
    Timer_Start(Horse_Timer,HORSE_TICK_MS);
}

hook OnPlayerConnect(playerid)
{
    Horse_Cleanup(playerid);
    Horse_ResetData(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Horse_Cleanup(playerid);
    Horse_ResetData(playerid);
}

hook Character_OnLoad(playerid,characterid)
{
    mysql_tquery_s(g_Mysql,str_format("SELECT character_horseid, character_horsehealth, character_sb_gun0, character_sb_gun1, character_sb_ammo0, character_sb_ammo1 FROM characters WHERE character_id = %d",characterid),"Horse_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    Horse_ForceDismount(playerid);
    Horse_Cleanup(playerid);
    Horse_ResetData(playerid);
}

hook OnPlayerDeath(playerid,killerid,WEAPON:reason)
{
    Horse_ForceDismount(playerid);
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if ((newkeys & KEY_SECONDARY_ATTACK) == KEY:0 || !Horse_IsSpawned(playerid))
    {
        return;
    }

    if (Horse_IsRiding(playerid))
    {
        Horse_TryDismount(playerid);
    }
    else
    {
        Horse_TryMount(playerid);
    }
}

hook Shop_OnStable(playerid,pointid)
{
    SetTimerEx("Horse_StableDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
}
