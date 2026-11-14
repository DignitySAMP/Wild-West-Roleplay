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
forward Temperature_UseThermostat(playerid,uid,item,extra);
forward Temperature_OnLoaded(playerid,token);

static s_PlayerWhole[MAX_PLAYERS] = {TEMPERATURE_NORMAL,...};
static s_PlayerDecimal[MAX_PLAYERS] = {TEMPERATURE_NORMAL_DECIMAL,...};
static bool:s_PlayerLoaded[MAX_PLAYERS];
static s_TemperaturePlayerDue;

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
stock Temperature_GetPlayer(playerid,&whole,&decimal)
{
    whole = s_PlayerWhole[playerid];
    decimal = s_PlayerDecimal[playerid];
}

static bool:Temperature_IsNormal(playerid)
{
    return s_PlayerWhole[playerid] == TEMPERATURE_NORMAL && s_PlayerDecimal[playerid] == TEMPERATURE_NORMAL_DECIMAL;
}

stock bool:Temperature_ResetPlayer(playerid)
{
    if (!s_PlayerLoaded[playerid] || Temperature_IsNormal(playerid))
    {
        return false;
    }

    s_PlayerWhole[playerid] = TEMPERATURE_NORMAL;
    s_PlayerDecimal[playerid] = TEMPERATURE_NORMAL_DECIMAL;
    Hud_SetTemperature(playerid,float(TEMPERATURE_NORMAL) + (float(TEMPERATURE_NORMAL_DECIMAL) / 10.0));
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_temperature = %d, character_temperature_decimal = %d WHERE character_id = %d",TEMPERATURE_NORMAL,TEMPERATURE_NORMAL_DECIMAL,Character_GetId(playerid)));
    return true;
}

stock Temperature_ResetAll()
{
    for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
    {
        if (IsPlayerConnected(playerid) && Account_IsLoggedIn(playerid))
        {
            Temperature_ResetPlayer(playerid);
        }
    }
}

public Temperature_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    s_PlayerWhole[playerid] = TEMPERATURE_NORMAL;
    s_PlayerDecimal[playerid] = TEMPERATURE_NORMAL_DECIMAL;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_temperature",s_PlayerWhole[playerid]);
        cache_get_value_name_int(0,"character_temperature_decimal",s_PlayerDecimal[playerid]);
    }

    s_PlayerLoaded[playerid] = true;
    return 1;
}

public Temperature_UseThermostat(playerid,uid,item,extra)
{
    new value = Temperature_GetZone(Zone_OfPlayer(playerid)), line[64];

    if (value == INVALID_TEMPERATURE)
    {
        SendServerMessage(playerid,"You are in a zone that doesn't have a valid temperature.",MSG_TYPE_ERROR);
        return 1;
    }

    format(line,sizeof(line),"The thermostat reads %d F\176;.",value);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    #pragma unused uid,item,extra
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
    Migration_Add("temperature-1-columns","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_temperature INT NOT NULL DEFAULT 98, ADD COLUMN IF NOT EXISTS character_temperature_decimal INT NOT NULL DEFAULT 6");
}

hook OnGameModeInit()
{
    Temperature_Roll();
    Temperature_SetDriftDue(GetTickCount() + TEMPERATURE_DRIFT_MS);
    s_TemperaturePlayerDue = GetTickCount() + TEMPERATURE_PLAYER_MS;
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_THERMOSTAT,"Temperature_UseThermostat");
}

hook OnPlayerConnect(playerid)
{
    s_PlayerWhole[playerid] = TEMPERATURE_NORMAL;
    s_PlayerDecimal[playerid] = TEMPERATURE_NORMAL_DECIMAL;
    s_PlayerLoaded[playerid] = false;
}

hook Character_OnLoad(playerid,characterid)
{
    s_PlayerLoaded[playerid] = false;
    mysql_tquery_s(g_Mysql,str_format("SELECT character_temperature, character_temperature_decimal FROM characters WHERE character_id = %d",characterid),"Temperature_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    s_PlayerLoaded[playerid] = false;
    s_PlayerWhole[playerid] = TEMPERATURE_NORMAL;
    s_PlayerDecimal[playerid] = TEMPERATURE_NORMAL_DECIMAL;
}

hook World_OnTick(now)
{
    if (now - Temperature_GetDriftDue() >= 0)
    {
        Temperature_SetDriftDue(now + TEMPERATURE_DRIFT_MS);
        Temperature_Drift();
    }

    if (now - s_TemperaturePlayerDue >= 0)
    {
        s_TemperaturePlayerDue = now + TEMPERATURE_PLAYER_MS;
        Temperature_ResetAll();
    }
}

hook Injury_OnRevived(playerid,helperid)
{
    Temperature_ResetPlayer(playerid);
}

hook Injury_OnRespawned(playerid)
{
    Temperature_ResetPlayer(playerid);
}
