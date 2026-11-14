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
new MySQL:g_Mysql = MYSQL_INVALID_HANDLE;
new bool:g_DatabaseReady = false;

enum E_SAVE_REASON
{
    E_SAVE_REASON_PERIODIC,
    E_SAVE_REASON_DISCONNECT,
    E_SAVE_REASON_SHUTDOWN,
}

#define DATABASE_SAVE_INTERVAL_MS (120000)

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
static Database_Connect()
{
    g_Mysql = mysql_connect_file("mysql.ini");
    if (g_Mysql == MYSQL_INVALID_HANDLE || mysql_errno(g_Mysql) != 0)
    {
        printf("[mysql] FATAL could not connect (errno %d)",mysql_errno(g_Mysql));
        return;
    }

    g_DatabaseReady = true;
    mysql_log(WARNING | ERROR);
    SetTimer("Database_SaveTick",DATABASE_SAVE_INTERVAL_MS,true);
    print("[mysql] connected");
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
forward bool:IsDatabaseReady();

public bool:IsDatabaseReady()
{
    return g_DatabaseReady;
}

forward Database_OnPlayerSave(playerid,E_SAVE_REASON:reason);

public Database_OnPlayerSave(playerid,E_SAVE_REASON:reason)
{
    return true;
}

forward Database_SaveTick();

public Database_SaveTick()
{
    foreach(new i : Player)
    {
        pawn_call_public("Database_OnPlayerSave","dd",i,_:E_SAVE_REASON_PERIODIC);
    }
    return 1;
}

public OnQueryError(errorid,const error[],const callback[],const query[],MySQL:handle)
{
    printf("[mysql] query error %d in '%s': %s",errorid,callback,error);
    printf("[mysql] failed query: %s",query);
    return 1;
}

public pp_on_error(source[],message[],error_level:level,&retval)
{
    printf("[mysql] pawnplus error (level %d): %s %s",_:level,source,message);
    PrintBacktrace();
    retval = 0;
    return retval;
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
    Database_Connect();
}

hook OnPlayerDisconnect(playerid,reason)
{
    if (g_DatabaseReady)
    {
        pawn_call_public("Database_OnPlayerSave","dd",playerid,_:E_SAVE_REASON_DISCONNECT);
    }
}

hook OnGameModeExit()
{
    foreach(new i : Player)
    {
        pawn_call_public("Database_OnPlayerSave","dd",i,_:E_SAVE_REASON_SHUTDOWN);
    }

    if (g_Mysql != MYSQL_INVALID_HANDLE)
    {
        pawn_call_public("Log_WriteDatabaseSync","sss","info","boot","Wild West Roleplay stopped");
        printf("[boot] Wild West Roleplay stopped");

        g_DatabaseReady = false;
        mysql_close(g_Mysql);
    }
}
