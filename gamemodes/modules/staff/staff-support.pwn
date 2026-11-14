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
#define SUPPORT_QUESTION_MAX (75)
#define SUPPORT_QUESTION_BUFFER (SUPPORT_QUESTION_MAX + 1)
#define SUPPORT_COOLDOWN (30)
#define SUPPORT_CHAT_MAX (144)
#define SUPPORT_CHAT_COLOUR (0x467CB3FF)
#define SUPPORT_PAGE (15)
#define SUPPORT_BODY (2048)

static bool:s_SupportPending[MAX_PLAYERS];
static s_SupportQuestion[MAX_PLAYERS][SUPPORT_QUESTION_BUFFER];
static s_SupportCooldown[MAX_PLAYERS];

forward Questions_ListDeferred(playerid,token);
forward Supporters_ListDeferred(playerid,token);

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
stock bool:Support_HasQuestion(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_SupportPending[playerid];
}

stock Support_GetQuestion(playerid,dest[],size = sizeof(dest))
{
    strcopy(dest,s_SupportQuestion[playerid],size);
}

stock Support_PurgeQuestions()
{
    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        s_SupportPending[i] = false;
        s_SupportQuestion[i][0] = EOS;
        s_SupportCooldown[i] = 0;
    }
}

stock Support_SendChat(playerid,const text[])
{
    new line[256], rank[36], name[ACCOUNT_NAME_LEN], staffName[ACCOUNT_NAME_LEN];

    if (Staff_IsModerator(playerid) && !Staff_IsManager(playerid))
    {
        Staff_GetGroupName(Staff_GetGroup(playerid),rank,sizeof(rank));
    }
    else
    {
        Staff_GetRankName(Staff_GetLevel(playerid),rank,sizeof(rank));
    }

    GetPlayerName(playerid,name,sizeof(name));
    Account_GetStaffName(playerid,staffName);

    if (staffName[0] == EOS)
    {
        format(line,sizeof(line),"[SUP] %s %s (%d){DEDEDE}: %s",rank,name,playerid,text);
    }
    else
    {
        format(line,sizeof(line),"[SUP] %s %s (%s) (%d){DEDEDE}: %s",rank,name,staffName,playerid,text);
    }

    foreach (new i : Player)
    {
        if (Staff_IsSupporter(i) && !Staff_IsSupporterChatMuted(i))
        {
            SendSplitMessage(i,SUPPORT_CHAT_COLOUR,line);
        }
    }
}

static Questions_List(playerid)
{
    yield 1;

    new token = Account_GetToken(playerid), ids[MAX_PLAYERS], count = 0, page = 0;

    foreach (new i : Player)
    {
        if (s_SupportPending[i])
        {
            ids[count++] = i;
        }
    }

    for (;;)
    {
        new body[SUPPORT_BODY], response[DIALOG_RESPONSE], first = page * SUPPORT_PAGE, last = first + SUPPORT_PAGE;

        if (count == 0)
        {
            strcopy(body,"No questions to display.");
        }

        if (last > count)
        {
            last = count;
        }

        for (new row = first;row < last;row++)
        {
            new line[128], name[ACCOUNT_NAME_LEN];
            GetPlayerName(ids[row],name,sizeof(name));
            format(line,sizeof(line),"%s(%d) %s: %s",row == first ? ("") : ("\n"),ids[row],name,s_SupportQuestion[ids[row]]);
            strcat(body,line,sizeof(body));
        }

        new bool:hasNext = last < count;

        if (hasNext)
        {
            strcat(body,"\nNext Page >>",sizeof(body));
        }

        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"Welcome!",body,hasNext ? ("Next") : ("Continue"),"");

        if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE] || !hasNext)
        {
            return;
        }

        page++;
    }
}

forward Questions_List_Deferred(playerid,token);

public Questions_List_Deferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Questions_List(playerid);
    }

    return 1;
}

static Questions_List_Defer(playerid)
{
    SetTimerEx("Questions_List_Deferred",0,false,"dd",playerid,Account_GetToken(playerid));
}

static Supporters_List(playerid)
{
    yield 1;

    new token = Account_GetToken(playerid), page = 0;

    for (;;)
    {
        await mysql_aquery_s(g_Mysql,str_format("SELECT account_id, account_name, account_supportquestions FROM master_accounts WHERE account_stafflevel = 1 ORDER BY account_id LIMIT %d OFFSET %d",SUPPORT_PAGE + 1,page * SUPPORT_PAGE),false);

        if (!Account_IsCurrent(playerid,token))
        {
            return;
        }

        new rows = cache_num_rows(), bool:hasNext = rows > SUPPORT_PAGE, response[DIALOG_RESPONSE];

        if (rows == 0)
        {
            SendServerMessage(playerid,"There are no supporter accounts to display.",MSG_TYPE_INFO);
            return;
        }

        if (hasNext)
        {
            rows = SUPPORT_PAGE;
        }

        new body[SUPPORT_BODY] = "Account Data \t Questions\n";

        for (new i = 0;i < rows;i++)
        {
            new accountId, name[ACCOUNT_NAME_LEN], questions, line[96];
            cache_get_value_name_int(i,"account_id",accountId);
            cache_get_value_name(i,"account_name",name,ACCOUNT_NAME_LEN);
            cache_get_value_name_int(i,"account_supportquestions",questions);
            format(line,sizeof(line),"[MA: %s:%d]: \t %d questions accepted\n",name,accountId,questions);
            strcat(body,line,sizeof(body));
        }

        if (hasNext)
        {
            strcat(body,"Next Page >>",sizeof(body));
        }

        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,"Supporter Activity",body,hasNext ? ("Next") : ("Close"),"");

        if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE] || !hasNext)
        {
            return;
        }

        page++;
    }
}

forward Supporters_List_Deferred(playerid,token);

public Supporters_List_Deferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Supporters_List(playerid);
    }

    return 1;
}

static Supporters_List_Defer(playerid)
{
    SetTimerEx("Supporters_List_Deferred",0,false,"dd",playerid,Account_GetToken(playerid));
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
CMD:ask(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (s_SupportCooldown[playerid] >= gettime())
    {
        new line[96];
        format(line,sizeof(line),"You need to wait %d seconds before asking another question.",s_SupportCooldown[playerid] - gettime());
        SendServerMessage(playerid,line,MSG_TYPE_WARN);
        return 1;
    }

    new question[STAFF_TEXT_LEN];

    if (sscanf(params,"s[145]",question))
    {
        SendServerMessage(playerid,"/ask [question]",MSG_TYPE_ERROR);
        return 1;
    }

    if (strlen(question) > SUPPORT_QUESTION_MAX)
    {
        SendServerMessage(playerid,"Keep questions to the point. No more than 75 characters.",MSG_TYPE_WARN);
        return 1;
    }

    strcopy(s_SupportQuestion[playerid],question,SUPPORT_QUESTION_BUFFER);
    s_SupportPending[playerid] = true;
    s_SupportCooldown[playerid] = gettime() + SUPPORT_COOLDOWN;

    new line[256], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"You asked \"%s\", a supporter will contact you soon!",question);
    SendSplitMessage(playerid,SUPPORTER_COLOR,line);

    foreach (new i : Player)
    {
        if (!Staff_IsSupporter(i))
        {
            continue;
        }

        format(line,sizeof(line),"{44639C}[QUESTION] (%d) %s asks:{DEDEDE} %s",playerid,name,question);
        SendSplitMessage(i,0xDEDEDEFF,line);
        format(line,sizeof(line),"To answer this question, type {59BD93}/accepthelp %d (/ah)",playerid);
        SendClientMessage(i,0xDEDEDEFF,line);
    }

    return 1;
}

CMD:accepthelp(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_IsSupporter(playerid))
    {
        SendServerMessage(playerid,"You need to be a supporter in order to be able to do this!",MSG_TYPE_ERROR);
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/a(ccept)h(elp) [targetid]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"That player doesn't seem to be connected anymore."))
    {
        return 1;
    }

    if (!s_SupportPending[target])
    {
        SendServerMessage(playerid,"That player doesn't seem to have a pending question.",MSG_TYPE_ERROR);
        return 1;
    }

    if (target == playerid)
    {
        SendServerMessage(playerid,"You can't accept your own question.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[256], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN], count = Account_GetSupportQuestions(playerid) + 1;
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    s_SupportPending[target] = false;
    Account_SetSupportQuestions(playerid,count);
    mysql_tquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_supportquestions = %d WHERE account_id = %d",count,Account_GetId(playerid)));

    format(line,sizeof(line),"Your question has been selected by supporter (%d) %s. They will contact you shortly.",playerid,name);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"[QUESTION] (%d) %s selected question of (%d) %s",playerid,name,target,targetName);
    Staff_SendSupporterWarning(line);
    format(line,sizeof(line),"\"%s\"",s_SupportQuestion[target]);
    Staff_SendSupporterWarning(line);
    format(line,sizeof(line),"(%d) %s selected question of (%d) %s: %s",playerid,name,target,targetName,s_SupportQuestion[target]);
    Staff_Log("supporter/ah",line);
    return 1;
}

ALT:ah=CMD:accepthelp;

CMD:questions(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_IsSupporter(playerid))
    {
        SendServerMessage(playerid,"You need to be a supporter in order to be able to do this!",MSG_TYPE_ERROR);
        return 1;
    }

    SetTimerEx("Questions_ListDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
    return 1;
}

CMD:support(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_IsSupporter(playerid))
    {
        SendServerMessage(playerid,"You need to be a supporter in order to be able to do this!",MSG_TYPE_ERROR);
        return 1;
    }

    new text[SUPPORT_CHAT_MAX];

    if (sscanf(params,"s[144]",text))
    {
        SendServerMessage(playerid,"/support or /sc [text]",MSG_TYPE_ERROR);
        return 1;
    }

    if (Staff_IsSupporterChatMuted(playerid))
    {
        SendServerMessage(playerid,"You can't talk in supporter chat unless you unmute supporter chat.",MSG_TYPE_ERROR);
        return 1;
    }

    Support_SendChat(playerid,text);
    return 1;
}

ALT:sc=CMD:support;

CMD:supportercheck(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid))
    {
        return 1;
    }

    SetTimerEx("Supporters_ListDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
    return 1;
}

CMD:purgequestions(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    new line[128], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    Support_PurgeQuestions();
    format(line,sizeof(line),"[STAFF] %s (%d) purged all server questions.",name,playerid);
    SendModeratorWarning(line,MOD_WARNING_HIGH);
    return 1;
}

CMD:purgereports(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    new line[128], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    Staff_PurgeReports();
    format(line,sizeof(line),"[STAFF] %s (%d) purged all server reports.",name,playerid);
    SendModeratorWarning(line,MOD_WARNING_HIGH);
    return 1;
}

CMD:clearsupporterdata(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireManager(playerid))
    {
        return 1;
    }

    mysql_tquery_s(g_Mysql,str_new("UPDATE master_accounts SET account_supportquestions = 0 WHERE account_stafflevel = 1"));

    foreach (new i : Player)
    {
        if (Account_IsLoggedIn(i) && Account_GetAdminLevel(i) == E_STAFF_LEVEL_SUPPORTER)
        {
            Account_SetSupportQuestions(i,0);
        }
    }

    new line[160], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"[SUPPORTER] (%d) %s has removed all supporter data: questions answered.",playerid,name);
    SendModeratorWarning(line,MOD_WARNING_MED);
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
public Questions_ListDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token) && Staff_IsSupporter(playerid))
    {
        Questions_List_Defer(playerid);
    }

    return 1;
}

public Supporters_ListDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token) && Staff_IsModerator(playerid))
    {
        Supporters_List_Defer(playerid);
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

hook OnPlayerConnect(playerid)
{
    s_SupportPending[playerid] = false;
    s_SupportQuestion[playerid][0] = EOS;
    s_SupportCooldown[playerid] = 0;
}

hook OnPlayerDisconnect(playerid,reason)
{
    s_SupportPending[playerid] = false;
}
