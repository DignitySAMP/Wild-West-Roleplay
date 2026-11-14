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
forward Record_Deferred(playerid,token,accountId,bool:own);
forward Record_LookupDeferred(playerid,token,const account[]);

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
static Record_TypeName(type,dest[],size)
{
    switch (type)
    {
        case E_RECORD_TYPE_KICK:
        {
            strcopy(dest,"Kick",size);
        }
        case E_RECORD_TYPE_AJAIL:
        {
            strcopy(dest,"Admin-jail",size);
        }
        default:
        {
            strcopy(dest,"Account Ban",size);
        }
    }
}

static Record_Show(playerid,accountId,bool:own)
{
    yield 1;

    new token = Account_GetToken(playerid), page = 0;

    for (;;)
    {
        await mysql_aquery_s(g_Mysql,str_format("SELECT COUNT(*) AS total FROM admin_record WHERE account_id = %d",accountId),false);

        if (!Account_IsCurrent(playerid,token))
        {
            return;
        }

        new total = 0;
        cache_get_value_name_int(0,"total",total);

        if (total > STAFF_RECORD_MAX)
        {
            total = STAFF_RECORD_MAX;
        }

        if (total == 0)
        {
            if (own)
            {
                SendServerMessage(playerid,"You don't have any records to your account.",MSG_TYPE_INFO);
            }
            else
            {
                SendServerMessage(playerid,"That account doesn't have any records.",MSG_TYPE_INFO);
            }

            return;
        }

        await mysql_aquery_s(g_Mysql,str_format("SELECT record_id, record_type, record_reason, record_admin, record_date FROM admin_record WHERE account_id = %d ORDER BY record_id LIMIT %d OFFSET %d",accountId,STAFF_RECORD_PAGE,page * STAFF_RECORD_PAGE),false);

        if (!Account_IsCurrent(playerid,token))
        {
            return;
        }

        new ids[STAFF_RECORD_PAGE], types[STAFF_RECORD_PAGE], admins[STAFF_RECORD_PAGE], reasons[STAFF_RECORD_PAGE][STAFF_REASON_LEN], dates[STAFF_RECORD_PAGE][36], rows = cache_num_rows();

        if (rows > STAFF_RECORD_PAGE)
        {
            rows = STAFF_RECORD_PAGE;
        }

        new body[2048] = "Record ID \t Record Type\t Record Date\t Record Reason\n";

        for (new i = 0;i < rows;i++)
        {
            cache_get_value_name_int(i,"record_id",ids[i]);
            cache_get_value_name_int(i,"record_type",types[i]);
            cache_get_value_name_int(i,"record_admin",admins[i]);
            cache_get_value_name(i,"record_reason",reasons[i],STAFF_REASON_LEN);
            cache_get_value_name(i,"record_date",dates[i],36);

            new typeName[16], shortReason[40];
            Record_TypeName(types[i],typeName,sizeof(typeName));

            if (strlen(reasons[i]) > 12)
            {
                format(shortReason,sizeof(shortReason),"[Reason: %.12s...]",reasons[i]);
            }
            else
            {
                format(shortReason,sizeof(shortReason),"[Reason: %s]",reasons[i]);
            }

            format(body,sizeof(body),"%s[ID %d]\t[Type: %s]\t[Date: %s]\t%s\n",body,ids[i],typeName,dates[i],shortReason);
        }

        new bool:hasNext = (page + 1) * STAFF_RECORD_PAGE < total, pages = (total + STAFF_RECORD_PAGE - 1) / STAFF_RECORD_PAGE, title[48], response[DIALOG_RESPONSE];

        if (hasNext)
        {
            strcat(body,"Next Page >>",sizeof(body));
        }

        format(title,sizeof(title),"Admin Record: Page %d of %d",page + 1,pages);
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,title,body,"View","Close");

        if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
        {
            return;
        }

        new pick = response[DIALOG_RESPONSE_LISTITEM];

        if (hasNext && pick == rows)
        {
            page++;
            continue;
        }

        if (pick < 0 || pick >= rows)
        {
            return;
        }

        new line[200], typeName[16];
        PlayerPlaySound(playerid,ACCOUNT_CONFIRM_SOUND,0.0,0.0,0.0);
        Record_TypeName(types[pick],typeName,sizeof(typeName));
        SendClientMessage(playerid,COLOR_ADMIN_BLUE,"[ADMIN RECORD PARSE DATA]");
        format(line,sizeof(line),"[ID %d]\t[Type: %s]\t[Date: %s]\t[Admin ID: %d]",ids[pick],typeName,dates[pick],admins[pick]);
        SendClientMessage(playerid,COLOR_ADMIN_BLUE,line);
        format(line,sizeof(line),"[Reason: %s]",reasons[pick]);
        SendClientMessage(playerid,COLOR_ADMIN_BLUE,line);
        return;
    }
}

static Record_Lookup(playerid,const account[])
{
    yield 1;

    new token = Account_GetToken(playerid), accountId = 0;
    await mysql_aquery_s(g_Mysql,str_format("SELECT account_id FROM master_accounts WHERE account_name = '%e' LIMIT 1",account),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (cache_num_rows() == 0)
    {
        SendServerMessage(playerid,"Database didn't return any account data. Maybe your mistyped the name.",MSG_TYPE_WARN);
        return;
    }

    cache_get_value_name_int(0,"account_id",accountId);
    Record_Show(playerid,accountId,false);
}

forward Record_Lookup_Deferred(playerid,token,const account[]);

public Record_Lookup_Deferred(playerid,token,const account[])
{
    if (Account_IsCurrent(playerid,token))
    {
        Record_Lookup(playerid,account);
    }

    return 1;
}

static Record_Lookup_Defer(playerid,const account[])
{
    SetTimerEx("Record_Lookup_Deferred",0,false,"dds",playerid,Account_GetToken(playerid),account);
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
CMD:adminrecord(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (params[0] == EOS)
    {
        SendServerMessage(playerid,"Loading admin record, one moment...",MSG_TYPE_WARN);
        SetTimerEx("Record_Deferred",0,false,"dddd",playerid,Account_GetToken(playerid),Account_GetId(playerid),1);
        return 1;
    }

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target;

    if (!sscanf(params,"u",target) && Staff_IsValidTarget(target))
    {
        SendServerMessage(playerid,"Loading admin record, one moment...",MSG_TYPE_WARN);
        SetTimerEx("Record_Deferred",0,false,"dddd",playerid,Account_GetToken(playerid),Account_GetId(target),0);
        return 1;
    }

    new account[ACCOUNT_NAME_LEN];

    if (sscanf(params,"s[25]",account))
    {
        SendServerMessage(playerid,"/adminrecord [player / master_account]",MSG_TYPE_ERROR);
        return 1;
    }

    SendServerMessage(playerid,"Loading admin record, one moment...",MSG_TYPE_WARN);
    SetTimerEx("Record_LookupDeferred",0,false,"dds",playerid,Account_GetToken(playerid),account);
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
public Record_Deferred(playerid,token,accountId,bool:own)
{
    if (Account_IsCurrent(playerid,token) && Player_IsReady(playerid))
    {
        Record_Show(playerid,accountId,own);
    }

    return 1;
}

public Record_LookupDeferred(playerid,token,const account[])
{
    if (Account_IsCurrent(playerid,token) && Player_IsReady(playerid))
    {
        Record_Lookup_Defer(playerid,account);
    }

    return 1;
}
