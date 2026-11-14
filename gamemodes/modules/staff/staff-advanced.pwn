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
#define GIVE_MONEY_MAX (5000)
#define GIVE_MONEY_TITLE "{C23030}ABUSE WARNING"
#define GIVE_MONEY_TEXT "{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\nYou're about to give a valuable item to a player.\nAbuse of this will lead to you being caught, and you being /PERMANENTLY/ banned.\n\nWith that in mind, go ahead."

forward GiveMoney_Deferred(playerid,token,target,targetToken,dollars);

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
static GiveMoney_Confirm(playerid,target,targetToken,dollars)
{
    yield 1;

    new token = Account_GetToken(playerid), response[DIALOG_RESPONSE];
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,GIVE_MONEY_TITLE,GIVE_MONEY_TEXT,"{C23030}Proceed","Cancel");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
    {
        return;
    }

    if (!Staff_IsModerator(playerid) || Staff_GetGroup(playerid) < E_STAFF_GROUP_ADVANCED)
    {
        SendServerMessage(playerid,"You must be at least an advanced moderator in order to do this.",MSG_TYPE_ERROR);
        return;
    }

    if (!Account_IsCurrent(target,targetToken) || !Staff_IsValidTarget(target) || !Player_IsReady(target) || !Money_IsLoaded(target))
    {
        SendServerMessage(playerid,"Target doesn't seem to be a valid player.",MSG_TYPE_ERROR);
        return;
    }

    new line[200], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN], text[16];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    Money_Delimit(dollars,text);
    Money_Give(target,Money_Make(dollars,0));
    format(line,sizeof(line),"You've been given $%s by (%d) %s",text,playerid,name);
    SendServerMessage(target,line,MSG_TYPE_WARN);
    format(line,sizeof(line),"[STAFF] %s (%d) gave (%d) %s $%s.",name,playerid,target,targetName,text);
    SendModeratorWarning(line,MOD_WARNING_HIGH);
    Staff_Log("staff/money",line);
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
CMD:givemoney(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    new target, dollars;

    if (sscanf(params,"ui",target,dollars))
    {
        SendServerMessage(playerid,"/givemoney [player] [money]",MSG_TYPE_ERROR);
        return 1;
    }

    if (dollars < 1)
    {
        SendServerMessage(playerid,"You have to give at least $1.",MSG_TYPE_ERROR);
        return 1;
    }

    if (dollars > GIVE_MONEY_MAX)
    {
        SendServerMessage(playerid,"That's not going to happen. Don't give more than 5000 money per turn.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_IsValidTarget(target) || !Player_IsReady(target) || !Money_IsLoaded(target))
    {
        SendServerMessage(playerid,"Target doesn't seem to be a valid player.",MSG_TYPE_ERROR);
        return 1;
    }

    SetTimerEx("GiveMoney_Deferred",0,false,"ddddd",playerid,Account_GetToken(playerid),target,Account_GetToken(target),dollars);
    return 1;
}

CMD:forcepaycheck(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    foreach (new i : Player)
    {
        Paycheck_Force(i);
    }

    new line[96], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"[STAFF] %s (%d) forced a global paycheck.",name,playerid);
    SendModeratorWarning(line,MOD_WARNING_HIGH);
    Staff_Log("staff/money",line);
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
public GiveMoney_Deferred(playerid,token,target,targetToken,dollars)
{
    if (Account_IsCurrent(playerid,token))
    {
        GiveMoney_Confirm(playerid,target,targetToken,dollars);
    }

    return 1;
}
