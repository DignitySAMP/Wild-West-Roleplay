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
#define MIGRATION_KEY_LEN (48)

static List:s_MigrationKeys;
static List:s_MigrationSql;
static Map:s_MigrationApplied;
static s_MigrationRunning = -1;
static s_MigrationRan;
static s_MigrationSkipped;
static s_MigrationFailed;

#define BOOT_NAME_LEN (32)

enum e_BOOT_LOADER
{
    E_BOOT_NAME[BOOT_NAME_LEN],
    E_BOOT_AFTER[BOOT_NAME_LEN],
    bool:E_BOOT_DONE,
}

static List:s_BootLoaders;
static s_BootRunning = -1;

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
stock Migration_Add(const key[], const sql[])
{
    if (!list_valid(s_MigrationSql))
    {
        s_MigrationKeys = list_new();
        s_MigrationSql = list_new();
    }

    list_add_str(s_MigrationKeys, key);
    list_add_str(s_MigrationSql, sql);
}

stock Migrations_Run()
{
    pawn_call_public("OnMigrationRun", "");
    pawn_call_public("Migrations_RunOnBoot", "");
}

static Boot_CountLoaders()
{
    return list_valid(s_BootLoaders) ? list_size(s_BootLoaders) : 0;
}

stock Boot_RegisterLoader(const name[], const after[] = "")
{
    if (!list_valid(s_BootLoaders))
    {
        s_BootLoaders = list_new();
    }

    new loader[e_BOOT_LOADER];
    format(loader[E_BOOT_NAME], BOOT_NAME_LEN, "%s", name);
    format(loader[E_BOOT_AFTER], BOOT_NAME_LEN, "%s", after);
    list_add_arr(s_BootLoaders, loader);
}

static bool:Boot_IsDone(const name[])
{
    new loader[e_BOOT_LOADER];

    for (new i = 0, count = Boot_CountLoaders();i < count;i++)
    {
        list_get_arr(s_BootLoaders, i, loader);

        if (!strcmp(loader[E_BOOT_NAME], name))
        {
            return loader[E_BOOT_DONE];
        }
    }

    return true;
}

static Boot_Finish()
{
    s_BootRunning = -1;
    pawn_call_public("OnServerFinishLoading", "");
}

stock Boot_LoaderDone()
{
    if (s_BootRunning == -1)
    {
        return;
    }

    list_set_cell(s_BootLoaders, s_BootRunning, _:E_BOOT_DONE, true);
    s_BootRunning = -1;
    Boot_Next();
}

stock Boot_Run()
{
    if (!IsDatabaseReady())
    {
        Log_Warn("boot", "database not ready, %d loaders skipped", Boot_CountLoaders());
        Boot_Finish();
        return;
    }

    Migrations_Run();
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
forward OnMigrationRun();

public OnMigrationRun()
{
    return 1;
}

forward Migrations_RunOnBoot();

public Migrations_RunOnBoot()
{
    yield 1;

    await mysql_aquery_s(g_Mysql, str_new("CREATE TABLE IF NOT EXISTS schema_migrations (migration_key VARCHAR(48) NOT NULL, applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (migration_key)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"));

    if (map_valid(s_MigrationApplied))
    {
        map_clear(s_MigrationApplied);
    }
    else
    {
        s_MigrationApplied = map_new();
    }

    await mysql_aquery_s(g_Mysql, str_new("SELECT migration_key FROM schema_migrations"));

    for (new row = 0, rows = cache_num_rows();row < rows;row++)
    {
        new key[MIGRATION_KEY_LEN];
        cache_get_value_name(row, "migration_key", key, MIGRATION_KEY_LEN);
        map_str_add(s_MigrationApplied, key, 1);
    }

    s_MigrationRan = 0;
    s_MigrationSkipped = 0;
    s_MigrationFailed = 0;

    Migrations_Step(0);
    return 1;
}

static Migrations_Step(from)
{
    for (new i = from, count = list_valid(s_MigrationKeys) ? list_size(s_MigrationKeys) : 0;i < count;i++)
    {
        new key[MIGRATION_KEY_LEN];
        list_get_str(s_MigrationKeys, i, key);

        if (map_has_str_key(s_MigrationApplied, key))
        {
            s_MigrationSkipped++;
            continue;
        }

        s_MigrationRunning = i;
        mysql_tquery_s(g_Mysql, list_get_str_s(s_MigrationSql, i), "Migrations_OnStatement", "d", i);
        return;
    }

    printf("[migrations] %d applied, %d already in place, %d failed", s_MigrationRan, s_MigrationSkipped, s_MigrationFailed);
    pawn_call_public("Boot_Next", "");
}

forward Migrations_OnStatement(index);

public Migrations_OnStatement(index)
{
    if (index != s_MigrationRunning)
    {
        return 1;
    }

    s_MigrationRunning = -1;

    new key[MIGRATION_KEY_LEN];
    list_get_str(s_MigrationKeys, index, key);
    mysql_pquery_s(g_Mysql, str_format("INSERT IGNORE INTO schema_migrations (migration_key) VALUES ('%e')", key));
    s_MigrationRan++;

    Migrations_Step(index + 1);
    return 1;
}

#include <pp-hooks>

hook OnQueryError(errorid, const error[], const callback[], const query[], MySQL:handle)
{
    #pragma unused error
    #pragma unused query
    #pragma unused handle

    if (s_MigrationRunning == -1 || strcmp(callback, "Migrations_OnStatement") != 0)
    {
        return;
    }

    new index = s_MigrationRunning, key[MIGRATION_KEY_LEN];
    s_MigrationRunning = -1;
    list_get_str(s_MigrationKeys, index, key);

    Log_Warn("migrations", "%s failed with error %d, it gets another go on the next boot", key, errorid);
    s_MigrationFailed++;

    Migrations_Step(index + 1);
}

forward Boot_Next();

public Boot_Next()
{
    new pending = 0, loader[e_BOOT_LOADER];

    for (new i = 0, count = Boot_CountLoaders();i < count;i++)
    {
        list_get_arr(s_BootLoaders, i, loader);

        if (loader[E_BOOT_DONE])
        {
            continue;
        }

        pending++;

        if (loader[E_BOOT_AFTER][0] != EOS && !Boot_IsDone(loader[E_BOOT_AFTER]))
        {
            continue;
        }

        s_BootRunning = i;
        pawn_call_public(loader[E_BOOT_NAME], "");
        return 1;
    }

    if (pending > 0)
    {
        Log_Warn("boot", "%d loaders wait on something that never finished", pending);
    }

    Boot_Finish();
    return 1;
}
