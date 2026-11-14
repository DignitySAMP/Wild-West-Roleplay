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
forward bool:Player_IsPaused(playerid);

#define SESSION_SECONDS (60)

static s_SessionId[MAX_PLAYERS];
static s_SessionTime[MAX_PLAYERS];
static s_SessionIdle[MAX_PLAYERS];
static s_SessionSeconds[MAX_PLAYERS];

stock Session_GetId(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS ? s_SessionId[playerid] : 0;
}

stock Session_GetTime(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS ? s_SessionTime[playerid] : 0;
}

stock Session_GetIdle(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS ? s_SessionIdle[playerid] : 0;
}

static Session_Reset(playerid)
{
    s_SessionId[playerid] = 0;
    s_SessionTime[playerid] = 0;
    s_SessionIdle[playerid] = 0;
    s_SessionSeconds[playerid] = 0;
}

static Session_Step(playerid,bool:paused)
{
    s_SessionTime[playerid]++;

    if (paused)
    {
        s_SessionIdle[playerid]++;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE sessions SET e_session_time = %d, e_session_idle = %d WHERE e_session_id = %d",s_SessionTime[playerid],s_SessionIdle[playerid],s_SessionId[playerid]));
}

forward Session_OpenDeferred(playerid,token);

static Session_Open(playerid,token)
{
    yield 1;

    if (s_SessionId[playerid] != 0)
    {
        return;
    }

    await mysql_aquery_s(g_Mysql,str_format("INSERT INTO sessions (e_session_acc, e_session_time, e_session_idle) VALUES (%d, 0, 0)",Account_GetId(playerid)),false);
    new id = cache_insert_id();

    if (!Account_IsCurrent(playerid,token) || s_SessionId[playerid] != 0)
    {
        return;
    }

    s_SessionId[playerid] = id;
}

#include <pp-hooks>

hook OnMigrationRun()
{
    Migration_Add("sessions-1-sessions","CREATE TABLE IF NOT EXISTS sessions (e_session_id INT UNSIGNED NOT NULL AUTO_INCREMENT, e_session_acc INT UNSIGNED NOT NULL DEFAULT 0, e_session_time INT NOT NULL DEFAULT 0, e_session_idle INT NOT NULL DEFAULT 0, PRIMARY KEY (e_session_id), KEY idx_session_acc (e_session_acc)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

hook OnPlayerConnect(playerid)
{
    Session_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Session_Reset(playerid);
}

public Session_OpenDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Session_Open(playerid,token);
    }

    return 1;
}

hook Player_OnReady(playerid)
{
    SetTimerEx("Session_OpenDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
}

hook Tick_OnPlayerSecond(playerid)
{
    if (s_SessionId[playerid] == 0)
    {
        return;
    }

    if (++s_SessionSeconds[playerid] >= SESSION_SECONDS)
    {
        s_SessionSeconds[playerid] = 0;
        Session_Step(playerid,Player_IsPaused(playerid));
    }
}

