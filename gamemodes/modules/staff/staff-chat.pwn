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
forward Character_OnRenamed(playerid,characterid);
forward Report_ListDeferred(playerid,token);
forward NameChange_Deferred(playerid,token,targetid,bool:accept,const reason[]);
forward NameChange_ListDeferred(playerid,token);

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
static Chat_Rank(playerid,dest[],size)
{
    if (Staff_IsManager(playerid))
    {
        Staff_GetRankName(Staff_GetLevel(playerid),dest,size);
        return;
    }

    Staff_GetGroupName(Staff_GetGroup(playerid),dest,size);
}

stock Staff_SendModeratorChat(playerid,const text[])
{
    new line[256], rank[36], name[ACCOUNT_NAME_LEN], staffName[ACCOUNT_NAME_LEN];
    Chat_Rank(playerid,rank,sizeof(rank));
    GetPlayerName(playerid,name,sizeof(name));
    Account_GetStaffName(playerid,staffName);

    if (staffName[0] == EOS)
    {
        format(line,sizeof(line),"[MOD] %s %s (%d){DEDEDE}: %s",rank,name,playerid,text);
    }
    else
    {
        format(line,sizeof(line),"[MOD] %s %s (%s) (%d){DEDEDE}: %s",rank,name,staffName,playerid,text);
    }

    foreach (new i : Player)
    {
        if (Staff_IsModerator(i))
        {
            SendSplitMessage(i,STAFF_MOD_CHAT_COLOUR,line);
        }
    }
}

stock Staff_PurgeReports()
{
    foreach (new i : Player)
    {
        Staff_ClearReport(i);
    }
}

static Convo_Dissolve(host)
{
    foreach (new i : Player)
    {
        if (Staff_GetConvo(i) == host)
        {
            Staff_SetConvo(i,STAFF_CONVO_NONE);
        }
    }
}

static Convo_Send(host,const text[])
{
    foreach (new i : Player)
    {
        if (Staff_GetConvo(i) == host)
        {
            SendSplitMessageEx(i,STAFF_CONVO_COLOUR,text);
        }
    }
}

static Report_List(playerid)
{
    yield 1;

    new body[1024], count = 0, response[DIALOG_RESPONSE];
    format(body,sizeof(body),"Reporter\tReported\tReason\tTime\n");

    foreach (new i : Player)
    {
        if (!Staff_HasReport(i))
        {
            continue;
        }

        new reporter[ACCOUNT_NAME_LEN], reported[ACCOUNT_NAME_LEN], reason[STAFF_REASON_LEN], age[32];
        Account_GetRoleplayName(i,reporter);
        Staff_GetReportTargetName(i,reported);
        Staff_GetReportReason(i,reason);
        Staff_FormatDuration(Staff_GetReportAge(i),age);

        for (new c = 0;reported[c] != EOS;c++)
        {
            if (reported[c] == '_')
            {
                reported[c] = ' ';
            }
        }

        format(body,sizeof(body),"%s(%d) %s\t(%d) %s\t%s\t%s\n",body,i,reporter,Staff_GetReportTarget(i),reported,reason,age);
        count++;
    }

    if (count == 0)
    {
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"Reports","No reports to display.","Continue","");
    }
    else
    {
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,"Reports",body,"Continue","");
    }
}

forward Report_List_Deferred(playerid,token);

public Report_List_Deferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Report_List(playerid);
    }

    return 1;
}

static Report_List_Defer(playerid)
{
    SetTimerEx("Report_List_Deferred",0,false,"dd",playerid,Account_GetToken(playerid));
}

static NameChange_List(playerid)
{
    yield 1;

    new body[512], count = 0, response[DIALOG_RESPONSE];
    format(body,sizeof(body),"Name\tType\tNew Name\n");

    foreach (new i : Player)
    {
        new kind = Account_GetNameChangeRequest(i);

        if (!kind)
        {
            continue;
        }

        new name[ACCOUNT_NAME_LEN], requested[ACCOUNT_NAME_LEN];
        GetPlayerName(i,name,sizeof(name));
        Account_GetNameChangeName(i,requested);
        format(body,sizeof(body),"%s%s \t %s \t %s\n",body,name,kind == 1 ? ("Character") : ("Master Account"),requested);
        count++;
    }

    if (!count)
    {
        SendServerMessage(playerid,"There are no current namechange requests.",MSG_TYPE_ERROR);
        return;
    }

    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,"Namechange Requests",body,"Continue","");
}

forward NameChange_List_Deferred(playerid,token);

public NameChange_List_Deferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        NameChange_List(playerid);
    }

    return 1;
}

static NameChange_List_Defer(playerid)
{
    SetTimerEx("NameChange_List_Deferred",0,false,"dd",playerid,Account_GetToken(playerid));
}

static NameChange_Process(playerid,targetid,bool:accept,const reason[])
{
    yield 1;

    new token = Account_GetToken(playerid), targetToken = Account_GetToken(targetid), kind = Account_GetNameChangeRequest(targetid);

    if (kind == 0 || !Staff_IsValidTarget(targetid))
    {
        return;
    }

    new line[256], adminName[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN], requested[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,adminName,sizeof(adminName));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    Account_GetNameChangeName(targetid,requested);

    if (!accept)
    {
        format(line,sizeof(line),"%s has denied your namechange request.  Reason: %s",adminName,reason);
        SendServerMessage(targetid,line,MSG_TYPE_INFO);
        format(line,sizeof(line),"You've denied %s's namechange request.  Reason: %s",targetName,reason);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        Account_ClearNameChangeRequest(targetid);
        return;
    }

    if (kind == 1)
    {
        await mysql_aquery_s(g_Mysql,str_format("UPDATE IGNORE characters SET character_name = '%e' WHERE character_id = %d",requested,Character_GetId(targetid)),false);
    }
    else
    {
        await mysql_aquery_s(g_Mysql,str_format("UPDATE IGNORE master_accounts SET account_name = '%e' WHERE account_id = %d",requested,Account_GetId(targetid)),false);
    }

    if (!Account_IsCurrent(targetid,targetToken) || !Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (cache_affected_rows() == 0)
    {
        SendServerMessage(playerid,"That name has been taken in the meantime, the request was not processed.",MSG_TYPE_ERROR);
        return;
    }

    format(line,sizeof(line),"You've accepted %s (%d)'s namechange.",targetName,targetid);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);

    if (kind == 1)
    {
        new oldName[ACCOUNT_NAME_LEN];
        strcopy(oldName,targetName);
        format(line,sizeof(line),"[NAMECHANGE] %s (%d) has namechanged to %s.",oldName,targetid,requested);
        SendSplitMessageToAll(COLOR_STAFF,line);
        Staff_Log("staff/namechange",line);
        Character_SetNameCached(targetid,requested);
        SetPlayerName(targetid,requested);
        pawn_call_public("Character_OnRenamed","dd",targetid,Character_GetId(targetid));
        new left = Account_GetNameChanges(targetid) - 1;
        Account_SetNameChanges(targetid,left);
        mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_namechanges = %d WHERE account_id = %d",left,Account_GetId(targetid)));
    }
    else
    {
        Account_SetName(targetid,requested);
        new left = Account_GetNameChanges(targetid) - 2;
        Account_SetNameChanges(targetid,left);
        format(line,sizeof(line),"Your Master Account name has been changed to %s.",requested);
        SendServerMessage(targetid,line,MSG_TYPE_INFO);
        format(line,sizeof(line),"%s (%d) has changed %s (%d) master account name to %s.",adminName,playerid,targetName,targetid,requested);
        Staff_Log("staff/namechange",line);
        mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_namechanges = %d WHERE account_id = %d",left,Account_GetId(targetid)));
    }

    Account_ClearNameChangeRequest(targetid);
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
CMD:mod(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid))
    {
        return 1;
    }

    new text[144];

    if (sscanf(params,"s[144]",text))
    {
        SendServerMessage(playerid,"/mod [text]",MSG_TYPE_ERROR);
        return 1;
    }

    if (Staff_IsModeratorChatMuted(playerid))
    {
        SendServerMessage(playerid,"You can't talk in moderator chat unless you unmute moderator chat.",MSG_TYPE_ERROR);
        return 1;
    }

    Staff_SendModeratorChat(playerid,text);
    return 1;
}

ALT:m=CMD:mod;

CMD:togmodwarnings(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid))
    {
        return 1;
    }

    if (Staff_IsOnDuty(playerid))
    {
        SendServerMessage(playerid,"You can't disable moderator warnings when you're on mod duty.",MSG_TYPE_WARN);
        return 1;
    }

    if (!Staff_HasWarnings(playerid))
    {
        Staff_SetWarnings(playerid,true);
        SendServerMessage(playerid,"Moderator warnings have been enabled. Use /togmodwarnings to disable it.",MSG_TYPE_INFO);
        return 1;
    }

    Staff_SetWarnings(playerid,false);
    SendServerMessage(playerid,"Moderator warnings have been disabled. Use /togmodwarnings to enable it.",MSG_TYPE_INFO);
    return 1;
}

CMD:report(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (Staff_GetReportCooldown(playerid) >= gettime())
    {
        new line[96];
        format(line,sizeof(line),"You need to wait %d seconds before sending another report",Staff_GetReportCooldown(playerid) - gettime());
        SendServerMessage(playerid,line,MSG_TYPE_WARN);
        return 1;
    }

    new target, reason[64];

    if (sscanf(params,"us[64]",target,reason))
    {
        SendServerMessage(playerid,"/report [playerid] [reason]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"That playerid is not connected."))
    {
        return 1;
    }

    Staff_SetReport(playerid,target,reason);
    SendServerMessage(playerid,"Report successfully sent. Please wait a few minutes before reporting again.",MSG_TYPE_WARN);

    new line[256], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));

    foreach (new i : Player)
    {
        if (!Staff_IsModerator(i))
        {
            continue;
        }

        format(line,sizeof(line),"{59BD93}[REPORT]{DEDEDE} (%d) %s is reporting (%d) %s:{DEDEDE} %s",playerid,name,target,targetName,reason);
        SendSplitMessage(i,COLOR_DEFAULT,line);

        if (Account_GetRuleCheck(target))
        {
            format(line,sizeof(line),"{CF4040}[WARNING]{DEDEDE} (%d) %s is flagged as a \"Potential Rulebreaker\".",target,targetName);
            SendClientMessage(i,COLOR_DEFAULT,line);
        }

        format(line,sizeof(line),"To accept this report, type {59BD93}/acceptreport %d (/ar)",playerid);
        SendClientMessage(i,COLOR_DEFAULT,line);
    }

    return 1;
}

CMD:reports(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    SetTimerEx("Report_ListDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
    return 1;
}

ALT:re=CMD:reports;

CMD:acceptreport(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/acceptreport [targetid]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"That player doesn't seem to be connected anymore."))
    {
        return 1;
    }

    if (!Staff_HasReport(target))
    {
        SendServerMessage(playerid,"That player doesn't seem to have a pending report.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[256], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN], reason[STAFF_REASON_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    Staff_GetReportReason(target,reason);
    Staff_ClearReport(target);

    format(line,sizeof(line),"Your report has been accepted by moderator (%d) %s. They will contact you shortly.",playerid,name);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"[REPORT] (%d) %s accepted the report of (%d) %s: %s",playerid,name,target,targetName,reason);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    return 1;
}

ALT:ar=CMD:acceptreport;

CMD:denyreport(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target, reason[64];

    if (sscanf(params,"us[64]",target,reason))
    {
        SendServerMessage(playerid,"/denyreport [targetid] [reason]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"That player doesn't seem to be connected anymore."))
    {
        return 1;
    }

    if (!Staff_HasReport(target))
    {
        SendServerMessage(playerid,"That player doesn't seem to have a pending report.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[256], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN], original[STAFF_REASON_LEN];
    Account_GetRoleplayName(playerid,name);
    Account_GetRoleplayName(target,targetName);
    Staff_GetReportReason(target,original);
    Staff_ClearReport(target);

    format(line,sizeof(line),"Your report has been denied by moderator (%d) %s. Reason: %s.",playerid,name,reason);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"[REPORT] (%d) %s denied the report of (%d) %s: %s",playerid,name,target,targetName,original);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    format(line,sizeof(line),"Reason: %s",reason);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    return 1;
}

ALT:dr=CMD:denyreport;

CMD:acinvite(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_IsModerator(playerid))
    {
        SendServerMessage(playerid,"You're not a moderator.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Staff_GetGroup(playerid) < E_STAFF_GROUP_TRIAL)
    {
        SendServerMessage(playerid,"You must be at least a trial moderator in order to do this.",MSG_TYPE_ERROR);
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/acinvite [target]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"The target you selected doesn't seem to be connected. Try again."))
    {
        return 1;
    }

    if (Staff_GetConvo(target) != STAFF_CONVO_NONE)
    {
        SendServerMessage(playerid,"The target seems to already be in a admin conversation. Ask for an admin to remove them.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Staff_GetConvo(playerid) != STAFF_CONVO_NONE && Staff_GetConvo(playerid) != playerid)
    {
        SendServerMessage(playerid,"You can only invite players to an admin conversation you started.",MSG_TYPE_ERROR);
        return 1;
    }

    Staff_SetConvo(playerid,playerid);
    Staff_SetConvo(target,playerid);

    new line[200], targetName[ACCOUNT_NAME_LEN], name[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(target,targetName);
    format(line,sizeof(line),"[AC] (%d) %s has been added to the admin conversation.",target,targetName);
    Convo_Send(playerid,line);

    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"Moderator (%d) %s has invited you to their admin conversation. Use /ac to speak.",playerid,name);
    SendServerMessage(target,line,MSG_TYPE_ERROR);
    GetPlayerName(target,targetName,sizeof(targetName));
    format(line,sizeof(line),"You have invited (%d) %s to your admin convo. Use /ac to speak or /acuninvite to remove them.",target,targetName);
    SendServerMessage(playerid,line,MSG_TYPE_ERROR);
    return 1;
}

CMD:acuninvite(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_IsModerator(playerid))
    {
        SendServerMessage(playerid,"You're not a moderator.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Staff_GetGroup(playerid) < E_STAFF_GROUP_TRIAL)
    {
        SendServerMessage(playerid,"You must be at least a trial moderator in order to do this.",MSG_TYPE_ERROR);
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/acuninvite [target]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"The target you selected doesn't seem to be connected. Try again."))
    {
        return 1;
    }

    new host = Staff_GetConvo(target);

    if (host == STAFF_CONVO_NONE)
    {
        SendServerMessage(playerid,"The target doesn't seem to be in any admin conversation.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[200], targetName[ACCOUNT_NAME_LEN], name[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(target,targetName);
    Account_GetRoleplayName(playerid,name);
    format(line,sizeof(line),"[AC] (%d) %s has been removed from the admin conversation by moderator (%d) %s.",target,targetName,playerid,name);
    Convo_Send(host,line);

    if (host == target)
    {
        Convo_Dissolve(host);
    }
    else
    {
        Staff_SetConvo(target,STAFF_CONVO_NONE);
    }

    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    format(line,sizeof(line),"Moderator (%d) %s has removed you from your current admin conversation.",playerid,name);
    SendServerMessage(target,line,MSG_TYPE_ERROR);
    format(line,sizeof(line),"You have removed (%d) %s from their current admin conversation.",target,targetName);
    SendServerMessage(playerid,line,MSG_TYPE_ERROR);
    return 1;
}

CMD:ac(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (Staff_GetConvo(playerid) == STAFF_CONVO_NONE)
    {
        SendServerMessage(playerid,"You're not in an admin conversation.",MSG_TYPE_ERROR);
        return 1;
    }

    new text[144];

    if (sscanf(params,"s[144]",text))
    {
        SendServerMessage(playerid,"/ac [text]",MSG_TYPE_ERROR);
        return 1;
    }

    new line[256], name[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,name);
    format(line,sizeof(line),"[AC] (%d) %s: %s",playerid,name,text);
    Convo_Send(Staff_GetConvo(playerid),line);
    return 1;
}

CMD:processnamechange(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_BASIC))
    {
        return 1;
    }

    new target, option[8], reason[64];

    if (sscanf(params,"us[8]S(None specified.)[64]",target,option,reason))
    {
        SendServerMessage(playerid,"/processn(ame)c(hange) [playerid] [accept/deny] [reason (if denied)]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"That player doesn't seem to be connected."))
    {
        return 1;
    }

    if (!Account_GetNameChangeRequest(target))
    {
        SendServerMessage(playerid,"This player hasn't requested a namechange.",MSG_TYPE_ERROR);
        return 1;
    }

    new bool:accept;

    if (!strcmp(option,"accept",true))
    {
        accept = true;
    }
    else if (!strcmp(option,"deny",true))
    {
        accept = false;
    }
    else
    {
        SendServerMessage(playerid,"/processn(ame)c(hange) [playerid] [accept/deny] [reason (if denied)]",MSG_TYPE_ERROR);
        return 1;
    }

    SetTimerEx("NameChange_Deferred",0,false,"dddds",playerid,Account_GetToken(playerid),target,accept ? 1 : 0,reason);
    return 1;
}

ALT:processnc=CMD:processnamechange;

CMD:namechanges(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_BASIC))
    {
        return 1;
    }

    SetTimerEx("NameChange_ListDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
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
public Report_ListDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Report_List_Defer(playerid);
    }

    return 1;
}

public NameChange_Deferred(playerid,token,targetid,bool:accept,const reason[])
{
    if (Account_IsCurrent(playerid,token) && Staff_IsValidTarget(targetid))
    {
        NameChange_Process(playerid,targetid,accept,reason);
    }

    return 1;
}

public NameChange_ListDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        NameChange_List_Defer(playerid);
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

hook Player_OnReady(playerid)
{
    if (Staff_IsModerator(playerid))
    {
        Staff_SetWarnings(playerid,true);
        SendServerMessage(playerid,"Moderator warnings have been automatically enabled. Use /togmodwarnings to disable it.",MSG_TYPE_WARN);
    }
}

hook OnPlayerConnect(playerid)
{
    Staff_ResetPlayer(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Staff_ClearReport(playerid);

    if (Staff_GetConvo(playerid) == playerid)
    {
        Convo_Dissolve(playerid);
    }

    Staff_SetConvo(playerid,STAFF_CONVO_NONE);
}
