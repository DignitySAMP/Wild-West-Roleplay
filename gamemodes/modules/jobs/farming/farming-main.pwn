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
forward Farming_UseSoilBag(playerid,uid,item,extra);
forward Farming_UseShovel(playerid,uid,item,extra);
forward Farming_UsePail(playerid,uid,item,extra);
forward Farming_UseEmptyPail(playerid,uid,item,extra);
forward Farming_UseBasket(playerid,uid,item,extra);
forward Farming_UseSeed(playerid,uid,item,extra);
forward Soils_Load();

Timer_Declare(Farming_Timer)
{

    Farming_Tick();
    return 1;
}

#pragma warning push
#pragma warning disable 204
public Soils_Load()
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_new("SELECT soil_id, soil_owner, soil_plant, soil_x, soil_y, soil_z, soil_rotx, soil_roty, soil_rotz, soil_water, soil_health, soil_state, s_ticks, finished_growing FROM soildata"),false);
    new now = GetTickCount(), loaded = 0;

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, soil[e_SOIL], finished;
        cache_get_value_name_int(i,"soil_id",id);
        cache_get_value_name_int(i,"soil_owner",soil[E_SOIL_OWNER]);
        cache_get_value_name_int(i,"soil_plant",soil[E_SOIL_PLANT]);
        cache_get_value_name_float(i,"soil_x",soil[E_SOIL_X]);
        cache_get_value_name_float(i,"soil_y",soil[E_SOIL_Y]);
        cache_get_value_name_float(i,"soil_z",soil[E_SOIL_Z]);
        cache_get_value_name_float(i,"soil_rotx",soil[E_SOIL_RX]);
        cache_get_value_name_float(i,"soil_roty",soil[E_SOIL_RY]);
        cache_get_value_name_float(i,"soil_rotz",soil[E_SOIL_RZ]);
        cache_get_value_name_int(i,"soil_water",soil[E_SOIL_WATER]);
        cache_get_value_name_int(i,"soil_health",soil[E_SOIL_HEALTH]);
        cache_get_value_name_int(i,"soil_state",soil[E_SOIL_STATE]);
        cache_get_value_name_int(i,"s_ticks",soil[E_SOIL_TICKS]);
        cache_get_value_name_int(i,"finished_growing",finished);

        if (id < 1 || (map_valid(g_Soils) && map_has_key(g_Soils,id)))
        {
            continue;
        }

        soil[E_SOIL_FINISHED] = finished != 0 || soil[E_SOIL_STATE] == SOIL_STATE_GROWN;

        if (soil[E_SOIL_STATE] == SOIL_STATE_GROWING && !soil[E_SOIL_FINISHED])
        {
            if (soil[E_SOIL_HEALTH] == SOIL_HEALTH_DEAD)
            {
                soil[E_SOIL_DEAD_DUE] = now + SOIL_DEAD_MS;
            }
            else
            {
                soil[E_SOIL_TICK_DUE] = now + SOIL_TICK_MS;
            }
        }

        Soil_Register(id,soil);
        loaded++;
    }

    Log_Info("farming","Loaded %d soil plots",loaded);
    Boot_LoaderDone();
    return 1;
}
#pragma warning pop

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
    Migration_Add("farming-1-soil","CREATE TABLE IF NOT EXISTS soildata (soil_id INT UNSIGNED NOT NULL AUTO_INCREMENT, soil_owner INT NOT NULL DEFAULT 0, soil_plant INT NOT NULL DEFAULT -1, soil_x FLOAT NOT NULL DEFAULT 0, soil_y FLOAT NOT NULL DEFAULT 0, soil_z FLOAT NOT NULL DEFAULT 0, soil_rotx FLOAT NOT NULL DEFAULT 0, soil_roty FLOAT NOT NULL DEFAULT 0, soil_rotz FLOAT NOT NULL DEFAULT 0, soil_water INT NOT NULL DEFAULT 0, soil_health INT NOT NULL DEFAULT 0, soil_state INT NOT NULL DEFAULT 0, s_ticks INT NOT NULL DEFAULT 0, finished_growing TINYINT NOT NULL DEFAULT 0, PRIMARY KEY (soil_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

hook OnGameModeInit()
{
    g_Soils = map_new();
    Boot_RegisterLoader("Soils_Load");
    Timer_Start(Farming_Timer,SOIL_TICKER_MS);
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_FARMING_SOIL_BAG,"Farming_UseSoilBag");
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_FARMING_SHOVEL,"Farming_UseShovel");
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_FARMING_PAIL,"Farming_UsePail");
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_FARMING_EMPTY_PAIL,"Farming_UseEmptyPail");
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_EMPTY_BASKET,"Farming_UseBasket");
    Inventory_RegisterUse(E_ITEM_TYPE_SEED,USE_ANY,"Farming_UseSeed");
}
