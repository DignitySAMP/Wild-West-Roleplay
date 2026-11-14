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
static Map:s_TicketPlayers;
static Map:s_TicketTokens;
static s_NextTicket;

forward Account_BeginDeferred(playerid,token);
forward Account_KickDeferred(playerid,token);
forward Account_PromptDeferred(playerid,token);
forward Account_OnHashed(ticket,hashid);
forward Account_OnVerified(ticket,bool:success);
forward Account_CharacterCheck(playerid);
forward Quiz_Start(playerid);

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
stock Account_QueueKick(playerid)
{
    SetTimerEx("Account_KickDeferred",ACCOUNT_KICK_DELAY_MS,false,"dd",playerid,g_AccountToken[playerid]);
}

stock Account_Restart(playerid)
{
    new token = Account_NewToken(playerid);
    g_AccountStage[playerid] = E_ACCOUNT_STAGE_CONNECTING;
    g_AccountLogged[playerid] = false;
    g_AccountHash[playerid][0] = EOS;
    SetTimerEx("Account_BeginDeferred",0,false,"dd",playerid,token);
}

static Account_NewTicket(playerid)
{
    if (!map_valid(s_TicketPlayers))
    {
        s_TicketPlayers = map_new();
        s_TicketTokens = map_new();
    }

    new ticket = ++s_NextTicket;
    map_add(s_TicketPlayers,ticket,playerid);
    map_add(s_TicketTokens,ticket,g_AccountToken[playerid]);
    return ticket;
}

static bool:Account_TakeTicket(ticket,&playerid)
{
    if (!map_valid(s_TicketPlayers) || !map_has_key(s_TicketPlayers,ticket))
    {
        return false;
    }

    playerid = map_get(s_TicketPlayers,ticket);
    new token = map_get(s_TicketTokens,ticket);
    map_remove(s_TicketPlayers,ticket);
    map_remove(s_TicketTokens,ticket);
    return Account_IsCurrent(playerid,token);
}

static Account_ReadRow(playerid)
{
    new account = playerid;
    g_Account[account][E_ACCOUNT_ID] = 0;
    cache_get_value_name_int(0,"account_id",g_Account[account][E_ACCOUNT_ID]);
    cache_get_value_name(0,"account_name",g_Account[account][E_ACCOUNT_NAME],ACCOUNT_NAME_LEN);
    cache_get_value_name_int(0,"account_registerquiz",g_Account[account][E_ACCOUNT_REGISTERQUIZ]);
    cache_get_value_name_int(0,"account_tutorial",g_Account[account][E_ACCOUNT_TUTORIAL]);
    cache_get_value_name_int(0,"account_rulecheck",g_Account[account][E_ACCOUNT_RULECHECK]);
    cache_get_value_name_int(0,"account_donatorlevel",g_Account[account][E_ACCOUNT_DONATOR_LEVEL]);
    cache_get_value_name_int(0,"account_donatorexpire",g_Account[account][E_ACCOUNT_DONATOR_EXPIRE]);
    cache_get_value_name_int(0,"account_stafflevel",g_Account[account][E_ACCOUNT_STAFF_LEVEL]);
    cache_get_value_name_int(0,"account_staffgroup",g_Account[account][E_ACCOUNT_STAFF_GROUP]);
    cache_get_value_name(0,"account_staffname",g_Account[account][E_ACCOUNT_STAFF_NAME],ACCOUNT_NAME_LEN);
    cache_get_value_name_int(0,"account_supportquestions",g_Account[account][E_ACCOUNT_SUPPORT_QUESTIONS]);
    cache_get_value_name_int(0,"account_namechanges",g_Account[account][E_ACCOUNT_NAME_CHANGES]);
    cache_get_value_name(0,"account_creation",g_Account[account][E_ACCOUNT_CREATION],36);
    cache_get_value_name_int(0,"account_lastlogin",g_Account[account][E_ACCOUNT_LAST_LOGIN]);
    cache_get_value_name(0,"account_anote",g_Account[account][E_ACCOUNT_NOTE],ACCOUNT_NOTE_LEN);
    cache_get_value_name(0,"account_pass",g_AccountHash[playerid],BCRYPT_HASH_LENGTH);
}

forward Task:Account_Lookup(playerid);

#pragma warning push
#pragma warning disable 204
async Task:Account_Lookup(playerid)
{
    new token = g_AccountToken[playerid], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    await mysql_aquery_s(g_Mysql,str_format("SELECT * FROM master_accounts WHERE account_name = '%e' LIMIT 1",name),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return async 0;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("account","account lookup failed for player %d",playerid);
        return async 0;
    }

    g_AccountExists[playerid] = cache_num_rows() > 0;

    if (g_AccountExists[playerid])
    {
        Account_ReadRow(playerid);
    }

    return async 1;
}
#pragma warning pop

static Account_Authenticate(playerid)
{
    if (Attempts_Count(playerid) >= ACCOUNT_MAX_TRIES)
    {
        SendServerMessage(playerid,"You've been kicked for entering the incorrect password too often.",MSG_TYPE_ERROR);
        Account_QueueKick(playerid);
        return;
    }

    g_AccountStage[playerid] = E_ACCOUNT_STAGE_LOGIN;
    Account_Prompt(playerid);
}

static Account_Begin(playerid)
{
    yield 1;

    new token = g_AccountToken[playerid];
    TogglePlayerSpectating(playerid,true);
    Intro_Start(playerid);

    new found = await Account_Lookup(playerid);

    if (!found || !Account_IsCurrent(playerid,token))
    {
        return;
    }

    Account_Authenticate(playerid);
}

static Account_Rejected(playerid,const text[])
{
    SendServerMessage(playerid,text,MSG_TYPE_ERROR);
}

static Account_ShowLoginBody(playerid,body[],size)
{
    new name[ACCOUNT_NAME_LEN], tries = Attempts_Count(playerid);
    GetPlayerName(playerid,name,sizeof(name));

    if (tries == 0)
    {
        format(body,size,"{DEDEDE}Welcome to {6B5538}Wild West Roleplay{DEDEDE}!\n\nAccount Name: \t {6B5538}%s{DEDEDE}\n\nPlease enter your password below.",name);
        return;
    }

    format(body,size,"{DEDEDE}Welcome to {6B5538}Wild West Roleplay{DEDEDE}!\n\nAccount Name: \t {6B5538}%s{DEDEDE}\n\nPlease enter your password below.\n\nIncorrect password! Login attempts: {6B5538}%d/%d{DEDEDE}\n",name,tries,ACCOUNT_MAX_TRIES);
}

static Account_Prompt(playerid)
{
    yield 1;

    new token = g_AccountToken[playerid], response[DIALOG_RESPONSE], body[512], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));

    for (;;)
    {
        if (!g_AccountExists[playerid])
        {
            format(body,sizeof(body),"{DEDEDE}Welcome to {6B5538}Wild West Roleplay{DEDEDE}!\n\nThe name {6B5538}%s{DEDEDE} is currently not registered.\n\nPlease enter your desired password below.",name);
            await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_PASSWORD,ACCOUNT_TITLE,body,"Register","Exit");
        }
        else
        {
            Account_ShowLoginBody(playerid,body,sizeof(body));
            await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_PASSWORD,ACCOUNT_TITLE,body,"Login","Exit");
        }

        if (!Account_IsCurrent(playerid,token) || g_AccountStage[playerid] != E_ACCOUNT_STAGE_LOGIN)
        {
            return;
        }

        if (!response[DIALOG_RESPONSE_RESPONSE])
        {
            Kick(playerid);
            return;
        }

        PlayerPlaySound(playerid,ACCOUNT_CONFIRM_SOUND,0.0,0.0,0.0);

        new length = strlen(response[DIALOG_RESPONSE_INPUTTEXT]);

        if (length > ACCOUNT_PASSWORD_MAX || length < ACCOUNT_PASSWORD_MIN)
        {
            if (length > ACCOUNT_PASSWORD_MAX)
            {
                Account_Rejected(playerid,"Your password can't have more than 65 characters.");
            }
            else
            {
                Account_Rejected(playerid,"Your password can't have less than 4 characters.");
            }

            if (g_AccountExists[playerid] && Attempts_Add(playerid) >= ACCOUNT_MAX_TRIES)
            {
                SendServerMessage(playerid,"You've been kicked for entering the incorrect password too often.",MSG_TYPE_ERROR);
                Account_QueueKick(playerid);
                return;
            }

            continue;
        }

        break;
    }

    new ticket = Account_NewTicket(playerid);

    if (g_AccountExists[playerid])
    {
        bcrypt_verify(ticket,"Account_OnVerified",response[DIALOG_RESPONSE_INPUTTEXT],g_AccountHash[playerid]);
    }
    else
    {
        bcrypt_hash(ticket,"Account_OnHashed",response[DIALOG_RESPONSE_INPUTTEXT],ACCOUNT_BCRYPT_COST);
    }
}

static Account_Register(playerid,const hash[])
{
    yield 1;

    new token = g_AccountToken[playerid], name[ACCOUNT_NAME_LEN], creation[36], year, month, day, hour, minute, second;
    GetPlayerName(playerid,name,sizeof(name));
    getdate(year,month,day);
    gettime(hour,minute,second);
    format(creation,sizeof(creation),"%02d/%02d/%d - %02d:%02d:%02d",day,month,year,hour,minute,second);

    await mysql_aquery_s(g_Mysql,str_format("INSERT IGNORE INTO master_accounts (account_name, account_pass, account_creation) VALUES ('%e', '%e', '%e')",name,hash,creation),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    new errorid = mysql_errno(g_Mysql);

    if (errorid != 0)
    {
        Log_Error("account","register failed for player %d (errno %d)",playerid,errorid);
        Account_Prompt(playerid);
        return;
    }

    new found = await Account_Lookup(playerid);

    if (!found || !Account_IsCurrent(playerid,token))
    {
        return;
    }

    Account_Authenticate(playerid);
}

static Account_Succeed(playerid)
{
    g_AccountLogged[playerid] = true;
    Attempts_Clear(playerid);

    mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_lastlogin = %d WHERE account_id = %d",gettime(),g_Account[playerid][E_ACCOUNT_ID]));

    if (!g_Account[playerid][E_ACCOUNT_REGISTERQUIZ])
    {
        g_AccountStage[playerid] = E_ACCOUNT_STAGE_QUIZ;
        Quiz_Start(playerid);
        return;
    }

    g_AccountHash[playerid][0] = EOS;

    if (g_Account[playerid][E_ACCOUNT_DONATOR_LEVEL] && g_Account[playerid][E_ACCOUNT_DONATOR_EXPIRE] < gettime())
    {
        g_Account[playerid][E_ACCOUNT_DONATOR_LEVEL] = 0;
        g_Account[playerid][E_ACCOUNT_DONATOR_EXPIRE] = 0;
        mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_donatorlevel = 0, account_donatorexpire = 0 WHERE account_id = %d",g_Account[playerid][E_ACCOUNT_ID]));
        SendServerMessage(playerid,"Your donator level has expired.",MSG_TYPE_WARN);
    }

    Account_CharacterCheck(playerid);
}

stock Account_ReauthenticateAfterQuiz(playerid)
{
    g_AccountStage[playerid] = E_ACCOUNT_STAGE_LOGIN;
    Account_Prompt(playerid);
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
public Account_BeginDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Account_Begin(playerid);
    }

    return 1;
}

public Account_KickDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Kick(playerid);
    }

    return 1;
}

public Account_OnHashed(ticket,hashid)
{
    #pragma unused hashid

    new playerid;

    if (!Account_TakeTicket(ticket,playerid))
    {
        return 1;
    }

    new hash[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(hash,sizeof(hash));
    Account_Register(playerid,hash);
    return 1;
}

public Account_OnVerified(ticket,bool:success)
{
    new playerid;

    if (!Account_TakeTicket(ticket,playerid))
    {
        return 1;
    }

    if (success)
    {
        Account_Succeed(playerid);
        return 1;
    }

    if (Attempts_Add(playerid) >= ACCOUNT_MAX_TRIES)
    {
        SendServerMessage(playerid,"You've been kicked for entering the incorrect password too often.",MSG_TYPE_ERROR);
        Account_QueueKick(playerid);
        return 1;
    }

    Account_Prompt(playerid);
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

hook OnPlayerConnect(playerid)
{
    if (IsPlayerNPC(playerid))
    {
        return;
    }

    Account_ResetPlayer(playerid);
    new token = Account_NewToken(playerid);
    SetPlayerColor(playerid,ACCOUNT_IDLE_COLOUR);
    TogglePlayerSpectating(playerid,true);

    new name[ACCOUNT_NAME_LEN], ip[16 + 1];
    GetPlayerName(playerid,name,sizeof(name));
    strcopy(ip,Util_GetPlayerIp(playerid));

    foreach (new i : Player)
    {
        if (i == playerid || IsPlayerNPC(i) || !g_AccountLogged[i])
        {
            continue;
        }

        if (!strcmp(name,g_Account[i][E_ACCOUNT_NAME],true))
        {
            new line[192], other[ACCOUNT_NAME_LEN];
            GetPlayerName(i,other,sizeof(other));
            format(line,sizeof(line),"%s tried to connect onto (%d) %s's master account (%s).",ip,i,other,g_Account[i][E_ACCOUNT_NAME]);
            SendModeratorWarning(line,MOD_WARNING_HIGH);
            SendClientMessage(playerid,COLOR_YELLOW,"Someone is already connected on this master account. Try again later or contact a moderator on Discord.");
            Account_QueueKick(playerid);
            return;
        }

        if (!strcmp(ip,Util_GetPlayerIp(i),true))
        {
            new line[192], other[ACCOUNT_NAME_LEN];
            GetPlayerName(i,other,sizeof(other));
            format(line,sizeof(line),"(%d) %s is connecting with IP %s. It is already in use by (%d) %s (%s).",playerid,name,ip,i,other,ip);
            SendModeratorWarning(line,MOD_WARNING_HIGH);
        }
    }

    SetTimerEx("Account_BeginDeferred",0,false,"dd",playerid,token);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Account_NewToken(playerid);
    g_AccountHash[playerid][0] = EOS;
    g_AccountPendingPassword[playerid][0] = EOS;
}
