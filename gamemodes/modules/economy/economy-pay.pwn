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
#define PAY_MIN_LEVEL (3)
#define PAY_RANGE (6.0)
#define PAY_ANIMATION_RANGE (2.0)
#define PAY_CHAT_RANGE (20.0)

#if !defined COLOR_ACTION
    #define COLOR_ACTION (0xC2A2DAAA)
#endif

forward Charity_Deferred(playerid,token,cents,const reason[]);

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
static bool:Pay_IsNear(playerid,targetid,Float:range)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid,x,y,z);
    return GetPlayerInterior(playerid) == GetPlayerInterior(targetid) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid) && IsPlayerInRangeOfPoint(playerid,range,x,y,z);
}

static Pay_Face(playerid,targetid)
{
    new Float:x, Float:y, Float:z, Float:px, Float:py, Float:pz;
    GetPlayerPos(targetid,x,y,z);
    GetPlayerPos(playerid,px,py,pz);
    SetPlayerFacingAngle(playerid,atan2(y - py,x - px) - 90.0);
}

static Charity_Run(playerid,cents,const reason[])
{
    yield 1;

    new token = Account_GetToken(playerid), response[DIALOG_RESPONSE], body[512], text[MONEY_TEXT_LEN];
    Money_Format(cents,text);
    format(body,sizeof(body),"{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\nYou're about to charity {C23030}%s{DEDEDE} to the server.\n\n{C23030}THERE IS NO WAY TO GET THIS MONEY BACK.{DEDEDE}\n\nOnly press continue if you're certain.",text);
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"{C23030}ANTI DUMBASS WARNING{DEDEDE}",body,"{C23030}Continue","No way");

    if (!Account_IsCurrent(playerid,token) || !Player_IsReady(playerid) || !response[DIALOG_RESPONSE_RESPONSE])
    {
        return;
    }

    if (!Money_Take(playerid,cents))
    {
        SendServerMessage(playerid,"You don't have that much money in your hand!",MSG_TYPE_ERROR);
        return;
    }

    new line[256], name[ACCOUNT_NAME_LEN], plain[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    Account_GetRoleplayName(playerid,plain);
    format(line,sizeof(line),"[CHARITY] (%d) %s has just charitied %s. Reason: %s",playerid,name,text,reason);
    SendSplitMessageToAll(COLOR_YELLOW,line);
    SendModeratorWarning(line,MOD_WARNING_MED);
    format(line,sizeof(line),"%s has charitied %s, reason: %s",plain,text,reason);
    Log_Info("money/charity","%s",line);
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
CMD:pay(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (Character_GetLevel(playerid) < PAY_MIN_LEVEL)
    {
        SendServerMessage(playerid,"You need to be level 3 to use this command.",MSG_TYPE_ERROR);
        return 1;
    }

    new target, amount, cents;

    if (sscanf(params,"uiI(0)",target,amount,cents))
    {
        SendServerMessage(playerid,"/pay [player] [dollars] [cents]",MSG_TYPE_ERROR);
        return 1;
    }

    if (target < 0 || target >= MAX_PLAYERS || !IsPlayerConnected(target) || !Player_IsReady(target) || !Money_IsLoaded(target))
    {
        SendServerMessage(playerid,"Your target player seems to not exist.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Pay_IsNear(playerid,target,PAY_RANGE))
    {
        SendServerMessage(playerid,"You are not near that player.",MSG_TYPE_ERROR);
        return 1;
    }

    if (target == playerid)
    {
        SendServerMessage(playerid,"You cannot pay yourself.",MSG_TYPE_ERROR);
        return 1;
    }

    if (amount < 0)
    {
        SendServerMessage(playerid,"You cannot pay negative amounts of money.",MSG_TYPE_ERROR);
        return 1;
    }

    if (amount < 1 && (cents < 1 || cents > 99))
    {
        SendServerMessage(playerid,"You can only give between 0-99 cent(s).",MSG_TYPE_ERROR);
        return 1;
    }

    if (amount >= 1 && (cents < 0 || cents > 99))
    {
        SendServerMessage(playerid,"You can only give between 1-99 cent(s).",MSG_TYPE_ERROR);
        return 1;
    }

    if (amount > MONEY_MAX_DOLLARS || !Money_CanAfford(playerid,Money_Make(amount,cents)))
    {
        SendServerMessage(playerid,"You don't have that much money.",MSG_TYPE_ERROR);
        return 1;
    }

    Money_Transfer(playerid,target,Money_Make(amount,cents));

    new line[200], whole[16], from[ACCOUNT_NAME_LEN], to[ACCOUNT_NAME_LEN], fromName[ACCOUNT_NAME_LEN], toName[ACCOUNT_NAME_LEN];
    Money_Delimit(amount,whole);
    Account_GetRoleplayName(playerid,from);
    Account_GetRoleplayName(target,to);

    if (cents != 0)
    {
        format(line,sizeof(line),"* %s has paid $%s.%02d to %s.",from,whole,cents,to);
    }
    else
    {
        format(line,sizeof(line),"* %s has paid $%s to %s.",from,whole,to);
    }

    ProxDetector(playerid,PAY_CHAT_RANGE,COLOR_ACTION,line);

    if (Pay_IsNear(playerid,target,PAY_ANIMATION_RANGE))
    {
        Pay_Face(playerid,target);
        Pay_Face(target,playerid);
        ApplyAnimation(target,"GANGS","prtial_hndshk_biz_01",4.0,false,false,false,false,0,SYNC_ALL);
        ApplyAnimation(playerid,"GANGS","prtial_hndshk_biz_01",4.0,false,false,false,false,0,SYNC_ALL);
    }

    GetPlayerName(playerid,fromName,sizeof(fromName));
    GetPlayerName(target,toName,sizeof(toName));
    format(line,sizeof(line),"[PAY] %s has paid $%s.%02d to %s.",fromName,whole,cents,toName);
    SendModeratorWarning(line,MOD_WARNING_MED);
    format(line,sizeof(line),"%s paid %s $%s.%02d",from,to,whole,cents);
    Log_Info("money/pay","%s",line);
    return 1;
}

CMD:charity(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new amount, cents, reason[64];

    if (sscanf(params,"iis[64]",amount,cents,reason))
    {
        SendServerMessage(playerid,"/charity [dollars] [cents] [reason]",MSG_TYPE_ERROR);
        return 1;
    }

    if (amount < 0 || cents < 0 || (amount == 0 && cents == 0))
    {
        SendServerMessage(playerid,"Nice try.",MSG_TYPE_ERROR);
        return 1;
    }

    if (cents > 99)
    {
        SendServerMessage(playerid,"You can only give between 0-99 cent(s).",MSG_TYPE_ERROR);
        return 1;
    }

    if (amount > MONEY_MAX_DOLLARS || amount > Money_Get(playerid) / 100)
    {
        SendServerMessage(playerid,"You don't have that much money in your hand!",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Money_CanAfford(playerid,Money_Make(amount,cents)))
    {
        SendServerMessage(playerid,"You don't have that much cents in your hand!",MSG_TYPE_ERROR);
        return 1;
    }

    SetTimerEx("Charity_Deferred",0,false,"ddds",playerid,Account_GetToken(playerid),Money_Make(amount,cents),reason);
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
public Charity_Deferred(playerid,token,cents,const reason[])
{
    if (Account_IsCurrent(playerid,token))
    {
        Charity_Run(playerid,cents,reason);
    }

    return 1;
}
