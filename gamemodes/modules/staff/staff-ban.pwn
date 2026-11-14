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
#define BAN_TEMP_HOURS (24)
#define BAN_MIN_HOURS (12)
#define BAN_MAX_HOURS (720)
#define BAN_REASON_LEN (96)
#define BAN_OFFLINE_IP "OFFLINE BAN"
#define BAN_EVASION_MASK (26)

forward Ban_CheckDeferred(playerid,token);
forward Ban_OnEvasionRows(playerid,token);
forward OfflineBan_Deferred(playerid,token,hours,const reason[],const account[]);
forward Unban_Deferred(playerid,token,const account[]);
forward Unbanip_Deferred(playerid,token,const address[]);

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
stock bool:Staff_ParseIp(const text[],&value)
{
    new octet = 0, digits = 0, parts = 0, result = 0;

    for (new i = 0;;i++)
    {
        new letter = text[i];

        if (letter >= '0' && letter <= '9')
        {
            octet = octet * 10 + (letter - '0');
            digits++;

            if (digits > 3 || octet > 255)
            {
                return false;
            }

            continue;
        }

        if ((letter != '.' && letter != EOS) || digits == 0)
        {
            return false;
        }

        result = (result << 8) | octet;
        parts++;
        octet = 0;
        digits = 0;

        if (letter == EOS)
        {
            break;
        }
    }

    if (parts != 4)
    {
        return false;
    }

    value = result;
    return true;
}

stock bool:Staff_IpMatch(const first[],const second[],range = BAN_EVASION_MASK)
{
    new a, b;

    if (!Staff_ParseIp(first,a) || !Staff_ParseIp(second,b))
    {
        return false;
    }

    new mask = -1 << (32 - range);
    return (a & mask) == (b & mask);
}

stock Staff_AddRecord(accountid,adminAccountId,type,const reason[],time)
{
    new date[36];
    Staff_FormatDateTime(date);
    mysql_pquery_s(g_Mysql,str_format("INSERT INTO admin_record (account_id, record_type, record_reason, record_time, record_admin, record_date) VALUES (%d, %d, '%e', %d, %d, '%e')",accountid,type,reason,time,adminAccountId,date));
}

stock Staff_InsertBan(accountid,const accountName[],const address[],const adminName[],const reason[],hours)
{
    new until = hours > 0 ? gettime() + hours * 3600 : 0;
    mysql_pquery_s(g_Mysql,str_format("INSERT INTO bans (account_id, account_name, ip, ban_admin, ban_reason, ban_time, unban_time) VALUES (%d, '%e', '%e', '%e', '%e', %d, %d)",accountid,accountName,address,adminName,reason,gettime(),until));
}

stock Staff_Ban(targetid,adminAccountId,const adminName[],hours,const reason[],bool:temporary = false)
{
    if (!Staff_IsValidTarget(targetid))
    {
        return false;
    }

    new stored[BAN_REASON_LEN], targetName[ACCOUNT_NAME_LEN];
    Account_GetName(targetid,targetName);

    if (temporary)
    {
        format(stored,sizeof(stored),"[TEMP] %s",reason);
    }
    else
    {
        strcopy(stored,reason);
    }

    Staff_InsertBan(Account_GetId(targetid),targetName,Util_GetPlayerIp(targetid),adminName,stored,hours);
    Staff_AddRecord(Account_GetId(targetid),adminAccountId,E_RECORD_TYPE_BAN,reason,hours);
    Select_Close(targetid);
    Account_QueueKick(targetid);
    return true;
}

stock Staff_Kick(targetid,adminAccountId,const reason[])
{
    if (!Staff_IsValidTarget(targetid))
    {
        return false;
    }

    Staff_AddRecord(Account_GetId(targetid),adminAccountId,E_RECORD_TYPE_KICK,reason,0);
    Account_QueueKick(targetid);
    return true;
}

static bool:Ban_Protected(playerid,targetid)
{
    if (targetid == playerid || (Staff_GetLevel(targetid) > E_STAFF_LEVEL_NONE && Staff_GetLevel(targetid) >= Staff_GetLevel(playerid)))
    {
        SendServerMessage(playerid,"You can't ban yourself or staff of your own rank or above.",MSG_TYPE_ERROR);
        return true;
    }

    return false;
}

static Ban_Announce(playerid,targetid,const verb[],const reason[])
{
    new line[256], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"[STAFF] %s (%d) has %s %s (%d) for \"%s\"",name,playerid,verb,targetName,targetid,reason);
    SendSplitMessageToAll(COLOR_STAFF,line);
    Staff_Log("staff/bans",line);
}

static Ban_Check(playerid)
{
    yield 1;

    new token = Account_GetToken(playerid);
    await mysql_aquery_s(g_Mysql,str_format("SELECT unban_time, ban_admin, ban_reason FROM bans WHERE (account_id = %d OR ip = '%e') AND (unban_time = 0 OR unban_time > %d) ORDER BY unban_time = 0 DESC, unban_time DESC LIMIT 1",Account_GetId(playerid),Util_GetPlayerIp(playerid),gettime()),false);

    if (!Account_IsCurrent(playerid,token) || cache_num_rows() == 0)
    {
        return;
    }

    new until, admin[ACCOUNT_NAME_LEN], reason[BAN_REASON_LEN], line[200];
    cache_get_value_name_int(0,"unban_time",until);
    cache_get_value_name(0,"ban_admin",admin,sizeof(admin));
    cache_get_value_name(0,"ban_reason",reason,sizeof(reason));

    Select_Close(playerid);
    SendClientMessage(playerid,COLOR_RED,"");

    if (until == 0)
    {
        SendClientMessage(playerid,COLOR_RED,"This account has been permanently suspended due to a breach of our rules.");
    }
    else
    {
        SendClientMessage(playerid,COLOR_RED,"This account has been temporarily suspended due to a breach of our rules.");
    }

    SendClientMessage(playerid,COLOR_RED,"");
    format(line,sizeof(line),"You got banned by moderator %s for %s.",admin,reason);
    SendClientMessage(playerid,COLOR_RED,line);

    if (until != 0)
    {
        new year, month, day, hour, minute, second;
        Stats_ToDate(until,year,month,day,hour,minute,second);
        format(line,sizeof(line),"You will be unbanned at {DEDEDE}%02d/%02d/%02d %02d:%02d:%02d",day,month,year,hour,minute,second);
        SendClientMessage(playerid,COLOR_RED,line);
        SendClientMessage(playerid,COLOR_RED,"");
        SendClientMessage(playerid,COLOR_RED,"Please do not try to evade this ban, as it is only temporary and ban evading results in a permanent ban.");
    }
    else
    {
        SendClientMessage(playerid,COLOR_RED,"");
    }

    SendClientMessage(playerid,COLOR_RED,"If you do not agree with this ban, please appeal the ban on our forums. {DEDEDE}(www.ww-rp.net)");
    SendClientMessage(playerid,COLOR_RED,"");
    Account_QueueKick(playerid);
}

forward Ban_Check_Deferred(playerid,token);

public Ban_Check_Deferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Ban_Check(playerid);
    }

    return 1;
}

static Ban_Check_Defer(playerid)
{
    SetTimerEx("Ban_Check_Deferred",0,false,"dd",playerid,Account_GetToken(playerid));
}

static OfflineBan_Run(playerid,hours,const reason[],const account[])
{
    yield 1;

    new token = Account_GetToken(playerid);
    await mysql_aquery_s(g_Mysql,str_format("SELECT account_id, account_name, account_stafflevel FROM master_accounts WHERE account_name = '%e' LIMIT 1",account),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (cache_num_rows() == 0)
    {
        SendServerMessage(playerid,"Database didn't return any account data. Maybe your mistyped the name.",MSG_TYPE_WARN);
        return;
    }

    new accountId, level, accountName[ACCOUNT_NAME_LEN];
    cache_get_value_name_int(0,"account_id",accountId);
    cache_get_value_name_int(0,"account_stafflevel",level);
    cache_get_value_name(0,"account_name",accountName,sizeof(accountName));

    if (level > E_STAFF_LEVEL_NONE && level >= Staff_GetLevel(playerid))
    {
        SendServerMessage(playerid,"You can't ban yourself or staff of your own rank or above.",MSG_TYPE_ERROR);
        return;
    }

    new adminName[ACCOUNT_NAME_LEN], line[256], name[ACCOUNT_NAME_LEN];
    Account_GetName(playerid,adminName);
    GetPlayerName(playerid,name,sizeof(name));
    Staff_InsertBan(accountId,accountName,BAN_OFFLINE_IP,adminName,reason,hours);
    Staff_AddRecord(accountId,Account_GetId(playerid),E_RECORD_TYPE_BAN,reason,hours);
    format(line,sizeof(line),"[STAFF] %s (%d) has offline banned %s for \"%s\"",name,playerid,accountName,reason);
    SendSplitMessageToAll(COLOR_STAFF,line);
    Staff_Log("staff/bans",line);
}

static Unban_Run(playerid,const account[])
{
    yield 1;

    new token = Account_GetToken(playerid);
    await mysql_aquery_s(g_Mysql,str_format("SELECT account_id, account_name FROM master_accounts WHERE account_name = '%e' LIMIT 1",account),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (cache_num_rows() == 0)
    {
        SendServerMessage(playerid,"Database didn't return any account data. Maybe your mistyped the name.",MSG_TYPE_WARN);
        return;
    }

    new accountId, accountName[ACCOUNT_NAME_LEN];
    cache_get_value_name_int(0,"account_id",accountId);
    cache_get_value_name(0,"account_name",accountName,sizeof(accountName));
    await mysql_aquery_s(g_Mysql,str_format("DELETE FROM bans WHERE account_id = %d",accountId),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    new line[160], name[ACCOUNT_NAME_LEN];

    if (cache_affected_rows() == 0)
    {
        format(line,sizeof(line),"(%d) %s doesn't seem to be banned. Did you type the name correctly?",accountId,accountName);
        SendServerMessage(playerid,line,MSG_TYPE_WARN);
        return;
    }

    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"[STAFF] %s (%d) unbanned %s (%d)",name,playerid,accountName,accountId);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    Staff_Log("staff/unbans",line);
}

static Unbanip_Run(playerid,const address[])
{
    yield 1;

    new token = Account_GetToken(playerid);
    await mysql_aquery_s(g_Mysql,str_format("DELETE FROM bans WHERE ip = '%e'",address),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (cache_affected_rows() == 0)
    {
        SendServerMessage(playerid,"No ban matches that IP.",MSG_TYPE_WARN);
        return;
    }

    new line[128], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"[STAFF] %s (%d) unbanned IP %s",name,playerid,address);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    Staff_Log("staff/unban",line);
}

/**
 *                                   __
 *                                  |  |
 *      _______  ______ ____    ____| $$  _______
 *     /       \|      \    \  /      $$ /       |
 *    |  $$$$$$$| $$$$$$\$$$$\|  $$$$$$$|  $$$$$$$
 *    | $$      | $$ | $$ | $$| $$  | $$ \$$    |
 *    | $$_____ | $$ | $$ | $$| $$__| $$ _\$$$$$$|
 *     \$$     \| $$ | $$ | $$ \$$    $$|       $$
 *      \$$$$$$$ \$$  \$$  \$$  \$$$$$$$ \$$$$$$$
 *
 */
CMD:kick(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target, reason[64];

    if (sscanf(params,"us[64]",target,reason))
    {
        SendServerMessage(playerid,"/kick [ playerid / name ] [ reason ]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    Staff_Kick(target,Account_GetId(playerid),reason);
    Ban_Announce(playerid,target,"kicked",reason);
    return 1;
}

CMD:trialban(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target, reason[64];

    if (sscanf(params,"us[64]",target,reason))
    {
        SendServerMessage(playerid,"This command will ban a player for 24 hours, contact a basic moderator for a permanant ban situation.",MSG_TYPE_WARN);
        SendServerMessage(playerid,"/trialban [ playerid / name ] [ reason ]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"Selected player doesn't exist, they might be offline.") || Ban_Protected(playerid,target))
    {
        return 1;
    }

    new adminName[ACCOUNT_NAME_LEN];
    Account_GetName(playerid,adminName);
    Ban_Announce(playerid,target,"temp-banned",reason);
    Staff_Ban(target,Account_GetId(playerid),adminName,BAN_TEMP_HOURS,reason,true);
    return 1;
}

CMD:ban(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_BASIC))
    {
        return 1;
    }

    new target, reason[64], hours;

    if (sscanf(params,"uis[64]",target,hours,reason))
    {
        SendServerMessage(playerid,"/ban [ playerid / name ] [ hours ] [ reason ]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    if (hours != 0 && (hours < BAN_MIN_HOURS || hours > BAN_MAX_HOURS))
    {
        SendServerMessage(playerid,"Ban hours must be between 12 and 720 hours, or 0 for a permanent ban.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Ban_Protected(playerid,target))
    {
        return 1;
    }

    new adminName[ACCOUNT_NAME_LEN];
    Account_GetName(playerid,adminName);
    Ban_Announce(playerid,target,"banned",reason);
    Staff_Ban(target,Account_GetId(playerid),adminName,hours,reason);
    return 1;
}

CMD:offlineban(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_BASIC))
    {
        return 1;
    }

    new account[ACCOUNT_NAME_LEN], hours, reason[64];

    if (sscanf(params,"s[25]is[64]",account,hours,reason))
    {
        SendServerMessage(playerid,"/offlineban [master_account] [hours] [reason] ( use /getma or /getc to get acc name )",MSG_TYPE_ERROR);
        return 1;
    }

    if (hours != 0 && (hours < BAN_MIN_HOURS || hours > BAN_MAX_HOURS))
    {
        SendServerMessage(playerid,"Ban hours must be between 12 and 720 hours, or 0 for a permanent ban.",MSG_TYPE_ERROR);
        return 1;
    }

    new stored[ACCOUNT_NAME_LEN];

    foreach (new i : Player)
    {
        if (!Account_IsLoggedIn(i))
        {
            continue;
        }

        Account_GetName(i,stored);

        if (!strcmp(account,stored,true))
        {
            new line[96];
            format(line,sizeof(line),"Player seems to be connected as ID %d. Use /ban instead.",i);
            SendServerMessage(playerid,line,MSG_TYPE_WARN);
            return 1;
        }
    }

    SetTimerEx("OfflineBan_Deferred",0,false,"dddss",playerid,Account_GetToken(playerid),hours,reason,account);
    return 1;
}

ALT:oban=CMD:offlineban;

CMD:unban(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_BASIC))
    {
        return 1;
    }

    new account[ACCOUNT_NAME_LEN];

    if (sscanf(params,"s[25]",account))
    {
        SendServerMessage(playerid,"/unban [master_account] ( use /getma or /getc to get acc name )",MSG_TYPE_ERROR);
        return 1;
    }

    SetTimerEx("Unban_Deferred",0,false,"dds",playerid,Account_GetToken(playerid),account);
    return 1;
}

CMD:unbanip(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_BASIC))
    {
        return 1;
    }

    new address[16], value;

    if (sscanf(params,"s[16]",address))
    {
        SendServerMessage(playerid,"/unbanip [ip] ( use /getma or /getc to get acc name )",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_ParseIp(address,value))
    {
        SendServerMessage(playerid,"That is not a valid IP address.",MSG_TYPE_ERROR);
        return 1;
    }

    SetTimerEx("Unbanip_Deferred",0,false,"dds",playerid,Account_GetToken(playerid),address);
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
public Ban_CheckDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Ban_Check_Defer(playerid);
    }

    return 1;
}

public Ban_OnEvasionRows(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    new address[17], playerIp[17], name[ACCOUNT_NAME_LEN];
    strcopy(playerIp,Util_GetPlayerIp(playerid));
    GetPlayerName(playerid,name,sizeof(name));

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        cache_get_value_name(i,"ip",address,sizeof(address));

        if (!Staff_IpMatch(address,playerIp))
        {
            continue;
        }

        new line[160];
        format(line,sizeof(line),"[BAN EVADING] User %s (%d) may be ban evading!",name,playerid);
        SendModeratorWarning(line,MOD_WARNING_HIGH);
        format(line,sizeof(line),"Their IP (%s) matches netblock of banned IP (%s). Do a GEO location check!",playerIp,address);
        SendModeratorWarning(line,MOD_WARNING_MED);
    }

    return 1;
}

public OfflineBan_Deferred(playerid,token,hours,const reason[],const account[])
{
    if (Account_IsCurrent(playerid,token))
    {
        OfflineBan_Run(playerid,hours,reason,account);
    }

    return 1;
}

public Unban_Deferred(playerid,token,const account[])
{
    if (Account_IsCurrent(playerid,token))
    {
        Unban_Run(playerid,account);
    }

    return 1;
}

public Unbanip_Deferred(playerid,token,const address[])
{
    if (Account_IsCurrent(playerid,token))
    {
        Unbanip_Run(playerid,address);
    }

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

hook Account_OnCharactersLoaded(playerid)
{
    SetTimerEx("Ban_CheckDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
}

hook Character_OnLoad(playerid,characterid)
{
    mysql_tquery_s(g_Mysql,str_format("SELECT ip FROM bans WHERE ip <> '%s' AND (unban_time = 0 OR unban_time > %d)",BAN_OFFLINE_IP,gettime()),"Ban_OnEvasionRows","dd",playerid,Account_GetToken(playerid));
}
