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
forward Traps_UseTrap(playerid,uid,item,extra);
forward Traps_UseBait(playerid,uid,item,extra);
forward Traps_Load();
forward Traps_ReloadDeferred(playerid);

Timer_Declare(Traps_Timer)
{

    Trap_Tick();
    return 1;
}

#pragma warning push
#pragma warning disable 204
forward Task:Traps_FetchTask();

async Task:Traps_FetchTask()
{
    await mysql_aquery_s(g_Mysql,str_new("SELECT trap_id, trap_constant, trap_owner, trap_deployed_state, trap_bait, trap_pos_x, trap_pos_y, trap_pos_z, trap_rot_x, trap_rot_y, trap_rot_z FROM traps ORDER BY trap_id"),false);
    new loaded = 0;

    for (new i = 0,rows = cache_num_rows();i < rows && loaded < TRAP_LIMIT;i++)
    {
        new id, trap[e_TRAP], deployed;
        cache_get_value_name_int(i,"trap_id",id);
        cache_get_value_name_int(i,"trap_constant",trap[E_TRAP_TYPE]);
        cache_get_value_name_int(i,"trap_owner",trap[E_TRAP_OWNER]);
        cache_get_value_name_int(i,"trap_deployed_state",deployed);
        cache_get_value_name_int(i,"trap_bait",trap[E_TRAP_BAIT]);
        cache_get_value_name_float(i,"trap_pos_x",trap[E_TRAP_X]);
        cache_get_value_name_float(i,"trap_pos_y",trap[E_TRAP_Y]);
        cache_get_value_name_float(i,"trap_pos_z",trap[E_TRAP_Z]);
        cache_get_value_name_float(i,"trap_rot_x",trap[E_TRAP_RX]);
        cache_get_value_name_float(i,"trap_rot_y",trap[E_TRAP_RY]);
        cache_get_value_name_float(i,"trap_rot_z",trap[E_TRAP_RZ]);
        trap[E_TRAP_DEPLOYED] = deployed != 0;
        trap[E_TRAP_OWNER_PLAYER] = INVALID_PLAYER_ID;

        if (id < 1 || (map_valid(g_Traps) && map_has_key(g_Traps,id)))
        {
            continue;
        }

        Trap_Register(id,trap);
        loaded++;
    }

    Log_Info("traps","Loaded %d traps",loaded);
    return async 1;
}

public Traps_Load()
{
    yield 1;
    await Traps_FetchTask();
    Boot_LoaderDone();
    return 1;
}

static Traps_Reload()
{
    yield 1;
    await Traps_FetchTask();
}

public Traps_ReloadDeferred(playerid)
{
    Traps_Reload();
    #pragma unused playerid
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
    Migration_Add("traps-1-table","CREATE TABLE IF NOT EXISTS traps (trap_id INT UNSIGNED NOT NULL AUTO_INCREMENT, trap_constant INT NOT NULL DEFAULT 0, trap_owner INT NOT NULL DEFAULT 0, trap_deployed_state INT NOT NULL DEFAULT 1, trap_bait INT NOT NULL DEFAULT 0, trap_pos_x FLOAT NOT NULL DEFAULT 0, trap_pos_y FLOAT NOT NULL DEFAULT 0, trap_pos_z FLOAT NOT NULL DEFAULT 0, trap_rot_x FLOAT NOT NULL DEFAULT 0, trap_rot_y FLOAT NOT NULL DEFAULT 0, trap_rot_z FLOAT NOT NULL DEFAULT 0, PRIMARY KEY (trap_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

hook OnGameModeInit()
{
    g_Traps = map_new();
    g_TrapAreas = map_new();
    Boot_RegisterLoader("Traps_Load");
    Timer_Start(Traps_Timer,TRAP_TICK_MS);
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_HUNTING_TRAP,"Traps_UseTrap");
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_HUNTING_BAIT,"Traps_UseBait");
}

hook OnPlayerEnterDynamicArea(playerid,STREAMER_TAG_AREA:areaid)
{
    if (!map_valid(g_TrapAreas) || !map_has_key(g_TrapAreas,_:areaid))
    {
        return;
    }

    Trap_Catch(map_get(g_TrapAreas,_:areaid),playerid);
}

hook Wildlife_OnMove(id)
{
    Trap_AnimalCheck(id);
}

static Traps_Forget(playerid)
{
    g_TrapCaught[playerid] = TRAP_NONE;
    g_TrapReleaseDue[playerid] = 0;
    Player_SetBusy(playerid,E_PLAYER_BUSY_TRAPPED,false);

    if (map_valid(g_Traps))
    {
        for (new Iter:it = map_iter(g_Traps);iter_inside(it);iter_move_next(it))
        {
            new trap[e_TRAP];
            iter_get_arr(it,trap);

            if (trap[E_TRAP_OWNER_PLAYER] == playerid)
            {
                trap[E_TRAP_OWNER_PLAYER] = INVALID_PLAYER_ID;
                map_set_arr(g_Traps,iter_get_key(it),trap);
            }
        }
    }
}

hook OnPlayerConnect(playerid)
{
    Traps_Forget(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Traps_Forget(playerid);
}

hook Character_OnUnload(playerid,characterid)
{
    Traps_Forget(playerid);
}
