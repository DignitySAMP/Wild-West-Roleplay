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
enum E_LOG_LEVEL
{
    LOG_LEVEL_DEBUG,
    LOG_LEVEL_INFO,
    LOG_LEVEL_WARN,
    LOG_LEVEL_ERROR,
}

#define Log_Info(%0,%1) Log_Emit(LOG_LEVEL_INFO,%0,sprintf(%1))
#define Log_Warn(%0,%1) Log_Emit(LOG_LEVEL_WARN,%0,sprintf(%1))
#define Log_Error(%0,%1) Log_Emit(LOG_LEVEL_ERROR,%0,sprintf(%1))

static const s_LogPrefixes[][6] = {"debug","info","warn","error"};

static const s_LogColours[] = {0x9A9A9AFF,0xC8C8C8FF,0xE5861AFF,0xE10000FF};

static E_LOG_LEVEL:s_LogConsoleLevel = LOG_LEVEL_INFO;
static E_LOG_LEVEL:s_LogMirrorLevel[MAX_PLAYERS] = {LOG_LEVEL_WARN,...};
static bool:s_LogMirrorEnabled[MAX_PLAYERS] = {true,...};

#define LOG_PRUNE_INTERVAL_MS (3600000)
#define LOG_RETENTION_DAYS (14)

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
static Log_CreateTable()
{
    mysql_tquery(g_Mysql,"CREATE TABLE IF NOT EXISTS server_log (log_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, level VARCHAR(8) NOT NULL, tag VARCHAR(32) NOT NULL, message VARCHAR(512) NOT NULL, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (log_id), KEY idx_created (created_at)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
}

static Log_Prune()
{
    if (!g_DatabaseReady)
    {
        return;
    }

    mysql_tquery_s(g_Mysql,str_format("DELETE FROM server_log WHERE created_at < (NOW() - INTERVAL %d DAY)",LOG_RETENTION_DAYS));
}

static Log_WriteDatabase(const level[],const tag[],const message[])
{
    if (!g_DatabaseReady || isnull(message))
    {
        return;
    }

    mysql_tquery_s(g_Mysql,str_format("INSERT INTO server_log (level,tag,message) VALUES ('%e','%e','%e')",level,tag,message));
}

static Log_WriteFile(E_LOG_LEVEL:level,const tag[],const message[])
{
    new year, month, day;
    getdate(year,month,day);

    new hour, minute, second;
    gettime(hour,minute,second);

    new path[48];
    format(path,sizeof(path),"logs/log_%04d-%02d-%02d.txt",year,month,day);

    new File:handle = fopen(path,io_append);

    if (!handle)
    {
        return;
    }

    new line[256];
    format(line,sizeof(line),"[%02d:%02d:%02d][%s][%s] %s\r\n",hour,minute,second,s_LogPrefixes[_:level],tag,message);
    fwrite(handle,line);
    fclose(handle);
}

stock Log_Emit(E_LOG_LEVEL:level,const tag[],const message[])
{
    Log_WriteFile(level,tag,message);

    if (level >= s_LogConsoleLevel)
    {
        printf("[%s][%s] %s",s_LogPrefixes[_:level],tag,message);
    }

    Log_WriteDatabase(s_LogPrefixes[_:level],tag,message);

    foreach(new i : Player)
    {
        if (IsPlayerNPC(i) || !IsPlayerAdmin(i) || !s_LogMirrorEnabled[i] || level < s_LogMirrorLevel[i])
        {
            continue;
        }

        new line[224];
        format(line,sizeof(line),"[%s][%s] %s",s_LogPrefixes[_:level],tag,message);
        SendClientMessage(i,s_LogColours[_:level],line);
    }

    return 1;
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
forward Log_WriteDatabaseSync(const level[],const tag[],const message[]);

public Log_WriteDatabaseSync(const level[],const tag[],const message[])
{
    if (!g_DatabaseReady || isnull(message))
    {
        return 0;
    }

    mysql_query_s(g_Mysql,str_format("INSERT INTO server_log (level,tag,message) VALUES ('%e','%e','%e')",level,tag,message),false);
    return 1;
}

forward Log_PruneTick();

public Log_PruneTick()
{
    Log_Prune();
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
    Log_CreateTable();
    Log_Prune();
    SetTimer("Log_PruneTick",LOG_PRUNE_INTERVAL_MS,true);
}

hook OnPlayerConnect(playerid)
{
    s_LogMirrorEnabled[playerid] = true;
    s_LogMirrorLevel[playerid] = LOG_LEVEL_WARN;
}

hook OnRconLoginAttempt(ip[],password[],success)
{
    if (!success)
    {
        return;
    }

    new playerIp[16];

    foreach(new playerid : Player)
    {
        if (IsPlayerNPC(playerid))
        {
            continue;
        }

        GetPlayerIp(playerid,playerIp,sizeof(playerIp));

        if (strcmp(playerIp,ip) != 0)
        {
            continue;
        }

        s_LogMirrorEnabled[playerid] = true;
        s_LogMirrorLevel[playerid] = LOG_LEVEL_DEBUG;
        SendClientMessage(playerid,s_LogColours[0],"[debug][log] RCON login - debug log mirror enabled.");
    }
}
