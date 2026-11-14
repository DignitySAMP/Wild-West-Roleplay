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
forward Namechange_Deferred(playerid,token,kind,const name[]);

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
static Namechange_Run(playerid,kind,const name[])
{
    yield 1;

    new token = g_AccountToken[playerid], bool:taken;

    if (kind == 1)
    {
        await mysql_aquery_s(g_Mysql,str_format("SELECT character_name FROM characters WHERE character_name = '%e'",name),false);
    }
    else
    {
        await mysql_aquery_s(g_Mysql,str_format("SELECT account_name FROM master_accounts WHERE account_name = '%e'",name),false);
    }

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    taken = cache_num_rows() > 0;

    if (taken)
    {
        if (kind == 1)
        {
            SendServerMessage(playerid,"This character name already exists.",MSG_TYPE_ERROR);
        }
        else
        {
            SendServerMessage(playerid,"This master account name already exists.",MSG_TYPE_ERROR);
        }

        return;
    }

    g_AccountNameChangeKind[playerid] = kind;
    strcopy(g_AccountNameChangeName[playerid],name,ACCOUNT_NAME_LEN);

    new playerName[ACCOUNT_NAME_LEN], line[192];
    GetPlayerName(playerid,playerName,sizeof(playerName));

    foreach (new i : Player)
    {
        if (IsPlayerNPC(i) || !g_AccountLogged[i] || g_Account[i][E_ACCOUNT_STAFF_LEVEL] < 2)
        {
            continue;
        }

        format(line,sizeof(line),"[NAMECHANGE] (%d) %s requests a {DEDEDE}%s{59BD93} namechange to :{DEDEDE} %s",playerid,playerName,kind == 1 ? ("Character") : ("Master Account"),name);
        SendClientMessage(i,COLOR_STAFF,line);
        format(line,sizeof(line),"To accept or deny the namechange, type {59BD93}/processnamechange %d [accept/deny] (/processnc)",playerid);
        SendClientMessage(i,COLOR_DEFAULT,line);
    }
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
CMD<CMD_FLAG_PRELOGIN>:relog(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Account_Relog(playerid))
    {
        SendServerMessage(playerid,"You can't do this when you're already logged in. Use /logout",MSG_TYPE_ERROR);
    }

    return 1;
}

CMD:statistics(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Player_IsSpawned(playerid))
    {
        SendServerMessage(playerid,"You need to be spawned and logged in to use this command!",MSG_TYPE_ERROR);
        return 1;
    }

    Stats_Show(playerid);
    SendServerMessage(playerid,"You can use /guns to view your holstered weapons.",MSG_TYPE_INFO);
    SendServerMessage(playerid,"You can press ~k~~CONVERSATION_NO~ to open your inventory.",MSG_TYPE_INFO);
    return 1;
}

ALT:stats=CMD:statistics;

CMD:namechange(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (g_Account[playerid][E_ACCOUNT_NAME_CHANGES] == 0)
    {
        SendServerMessage(playerid,"You don't have any namechanges to use!",MSG_TYPE_ERROR);
        return 1;
    }

    if (g_AccountNameChangeKind[playerid] != 0)
    {
        SendServerMessage(playerid,"You've already requested a namechange!",MSG_TYPE_ERROR);
        return 1;
    }

    new option[16], name[ACCOUNT_NAME_LEN], changes = g_Account[playerid][E_ACCOUNT_NAME_CHANGES];

    if (sscanf(params,"s[16]s[25]",option,name))
    {
        new line[64];
        SendServerMessage(playerid,"/n(ame)c(hange) [character/account] [new name]",MSG_TYPE_INFO);
        format(line,sizeof(line),"You currently have %d %s.",changes,changes == 1 ? ("namechange") : ("namechanges"));
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        return 1;
    }

    new kind = 0;

    if (!strcmp(option,"character",true))
    {
        if (changes < 1)
        {
            SendServerMessage(playerid,"You need at least 1 namechanges to change your character name!",MSG_TYPE_ERROR);
            return 1;
        }

        kind = 1;
    }
    else if (!strcmp(option,"account",true))
    {
        if (changes < 2)
        {
            SendServerMessage(playerid,"You need at least 2 namechanges to change your master account name!",MSG_TYPE_ERROR);
            return 1;
        }

        kind = 2;
    }
    else
    {
        SendServerMessage(playerid,"[character/account] are options, you don't put a name for this parameter.",MSG_TYPE_ERROR);
        return 1;
    }

    SetTimerEx("Namechange_Deferred",0,false,"ddds",playerid,g_AccountToken[playerid],kind,name);
    return 1;
}

CMD<CMD_FLAG_PRELOGIN>:logout(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!g_AccountLogoutPermission[playerid])
    {
        SendServerMessage(playerid,"You don't have permission to use this command.",MSG_TYPE_ERROR);
        return 1;
    }

    Account_Logout(playerid);
    return 1;
}

CMD:switchcharacter(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Switch_Open(playerid))
    {
        SendServerMessage(playerid,"You can't do this right now.",MSG_TYPE_ERROR);
    }

    return 1;
}

ALT:switchc=CMD:switchcharacter;

CMD<CMD_FLAG_PRELOGIN>:selectcharacter(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new slot;

    if (sscanf(params,"i",slot) || slot < 1)
    {
        SendServerMessage(playerid,"/selectcharacter [slot 1-3]",MSG_TYPE_ERROR);
        return 1;
    }

    if (slot > CHARACTER_SLOTS)
    {
        SendServerMessage(playerid,"You can only have three characters.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Select_IsOpen(playerid))
    {
        SendServerMessage(playerid,"You're not in the character selection screen. If you are but it says you're not, use /logout to fix it.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!g_CharacterSlots[playerid][slot - 1][E_CHARACTER_ID])
    {
        SendServerMessage(playerid,"There isn't a character in the slot you selected.",MSG_TYPE_ERROR);
        SendServerMessage(playerid,"You can use {E87654}/charactercreate{DEDEDE} to create one.",MSG_TYPE_ERROR);
        return 1;
    }

    Character_Select(playerid,slot - 1);
    return 1;
}

CMD<CMD_FLAG_PRELOGIN>:charactercreate(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Create_StartDialogs(playerid))
    {
        SendServerMessage(playerid,"You can only use this during character creation.",MSG_TYPE_ERROR);
    }

    return 1;
}

CMD<CMD_FLAG_PRELOGIN>:fixchartds(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    Select_Hide(playerid);
    Create_Hide(playerid);
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
public Namechange_Deferred(playerid,token,kind,const name[])
{
    if (Account_IsCurrent(playerid,token))
    {
        Namechange_Run(playerid,kind,name);
    }

    return 1;
}
