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
#define CHARGE_MAX_AMOUNT (5000)
#define CHARGE_CLEAR_RANGE (5.0)
#define CHARGE_MAX_PER_CHARACTER (100)
#define CHARGE_TEXT_LEN (32)
#define CHARGE_LIST_LEN (3072)

forward Charge_Deferred(playerid,token,flow,target,chargeid,const name[]);

enum _:E_CHARGE_FLOW
{
    CHARGE_FLOW_ADD = 0,
    CHARGE_FLOW_CLEAR,
    CHARGE_FLOW_VIEW,
}

static s_ChargeAmount[MAX_PLAYERS];
static s_ChargeText[MAX_PLAYERS][CHARGE_TEXT_LEN];

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
static bool:Charge_Require(playerid)
{
    if (!Posse_IsLawMember(playerid))
    {
        SendServerMessage(playerid,"You have to be in a police posse in order to do this command.",MSG_TYPE_INFO);
        return false;
    }

    return true;
}

static Charge_Add(playerid,cents,const user[],const text[])
{
    yield 1;

    new token = Account_GetToken(playerid);
    await mysql_aquery_s(g_Mysql,str_format("SELECT character_name FROM characters WHERE character_name = '%e'",user),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (cache_num_rows() < 1)
    {
        new line[128];
        format(line,sizeof(line),"The character '%s' does not exist.",user);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return;
    }

    new holder[ACCOUNT_NAME_LEN];
    cache_get_value_name(0,"character_name",holder);
    await mysql_aquery_s(g_Mysql,str_format("SELECT COUNT(*) AS total FROM charges WHERE charge_holder = '%e' AND (charge_amount > 0 OR charge_change > 0)",holder),false);
    new total = 0;
    cache_get_value_name_int(0,"total",total);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (total >= CHARGE_MAX_PER_CHARACTER)
    {
        SendServerMessage(playerid,"That character already has 100 charges.",MSG_TYPE_WARN);
        return;
    }

    new placer[ACCOUNT_NAME_LEN], date[48];
    GetPlayerName(playerid,placer,sizeof(placer));
    Time_FormatDate(date);
    mysql_tquery_s(g_Mysql,str_format("INSERT INTO charges (charge_placer, charge_holder, charge_amount, charge_change, charge_info, charge_date) VALUES ('%e', '%e', %d, %d, '%e', '%e')",placer,holder,Money_Dollars(cents),Money_Cents(cents),text,date));
    new rank[POSSE_RANK_LEN], line[200], whole[16], posseid = Posse_GetPlayer(playerid);
    Posse_GetRank(playerid,rank);
    Money_Delimit(Money_Dollars(cents),whole);
    format(line,sizeof(line),"{[ %s %s has charged %s with '%s' for $%s.%02d.",rank,placer,holder,text,whole,Money_Cents(cents));
    Posse_Warning(posseid,line);

    foreach (new i : Player)
    {
        new name[ACCOUNT_NAME_LEN];
        GetPlayerName(i,name,sizeof(name));

        if (!strcmp(name,holder,true))
        {
            new byName[ACCOUNT_NAME_LEN];
            Posse_DisplayName(playerid,false,byName);
            format(line,sizeof(line),"You've been charged with '%s' for $%s.%02d by %s %s.",text,whole,Money_Cents(cents),rank,byName);
            SendServerMessage(i,line,MSG_TYPE_INFO);
        }
    }
}

static Charge_Clear(playerid,target,chargeid)
{
    yield 1;

    new token = Account_GetToken(playerid), holder[ACCOUNT_NAME_LEN], posseid = Posse_GetPlayer(playerid);
    GetPlayerName(target,holder,sizeof(holder));
    await mysql_aquery_s(g_Mysql,str_format("SELECT charge_amount, charge_change FROM charges WHERE charge_id = %d AND charge_holder = '%e' AND (charge_amount > 0 OR charge_change > 0)",chargeid,holder),false);

    if (!Account_IsCurrent(playerid,token) || posseid == POSSE_NONE)
    {
        return;
    }

    if (cache_num_rows() < 1)
    {
        SendServerMessage(playerid,"There is no charge present with that charge ID.",MSG_TYPE_ERROR);
        return;
    }

    new dollars, cents;
    cache_get_value_name_int(0,"charge_amount",dollars);
    cache_get_value_name_int(0,"charge_change",cents);
    new total = Money_Make(dollars,cents);

    if (!Money_Take(target,total))
    {
        new name[ACCOUNT_NAME_LEN], line[128];
        Posse_DisplayName(target,false,name);
        format(line,sizeof(line),"%s doesn't have enough money to pay that charge.",name);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return;
    }

    Posse_BankGive(posseid,total);
    mysql_tquery_s(g_Mysql,str_format("UPDATE charges SET charge_amount = 0, charge_change = 0 WHERE charge_id = %d",chargeid));
    new name[ACCOUNT_NAME_LEN], mine[ACCOUNT_NAME_LEN], rank[POSSE_RANK_LEN], line[200];
    Posse_DisplayName(target,false,name);
    Posse_DisplayName(playerid,false,mine);
    Posse_GetRank(playerid,rank);
    format(line,sizeof(line),"You have successfully cleared %s's charge of $%i.",name,dollars);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"%s %s has cleared %s's charge of $%i.",rank,mine,name,dollars);
    Posse_Warning(posseid,line);
}

static Charge_View(playerid,const user[])
{
    yield 1;

    new token = Account_GetToken(playerid), body[CHARGE_LIST_LEN];
    await mysql_aquery_s(g_Mysql,str_format("SELECT charge_id, charge_placer, charge_amount, charge_change, charge_info FROM charges WHERE charge_holder = '%e' ORDER BY charge_id",user),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    new rows = cache_num_rows();

    if (rows < 1)
    {
        SendServerMessage(playerid,"There are no current charges for this player or this player doesn't exist.",MSG_TYPE_ERROR);
        return;
    }

    new sum = 0;

    for (new i = 0;i < rows;i++)
    {
        new id, placer[ACCOUNT_NAME_LEN], dollars, cents, info[CHARGE_TEXT_LEN], line[200], whole[16];
        cache_get_value_name_int(i,"charge_id",id);
        cache_get_value_name(i,"charge_placer",placer);
        cache_get_value_name_int(i,"charge_amount",dollars);
        cache_get_value_name_int(i,"charge_change",cents);
        cache_get_value_name(i,"charge_info",info);
        sum += Money_Make(dollars,cents);
        Money_Delimit(dollars,whole);
        format(line,sizeof(line),"Charge ID: %i - Charge Placer: %s - Charge Amount: $%s.%02d - Charge Info: %s\n",id,placer,whole,cents,info);
        strcat(body,line,sizeof(body));
    }

    new whole[16], line[96], title[64], response[DIALOG_RESPONSE];
    Money_Delimit(Money_Dollars(sum),whole);
    format(line,sizeof(line),"\nCombined Charges Total: $%s.%02d",whole,Money_Cents(sum));
    strcat(body,line,sizeof(body));
    format(title,sizeof(title),"%s's Charges",user);
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,title,body,"Exit","");
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
CMD:charge(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Charge_Require(playerid))
    {
        return 1;
    }

    new user[ACCOUNT_NAME_LEN], amount, cents, charge[CHARGE_TEXT_LEN];

    if (sscanf(params,"s[24]iis[32]",user,amount,cents,charge))
    {
        SendServerMessage(playerid,"/charge [criminal_name] [dollars] [cents] [charge text]",MSG_TYPE_ERROR);
        return 1;
    }

    if (amount < 0)
    {
        SendServerMessage(playerid,"A charge cannot have negative dollars!",MSG_TYPE_WARN);
        return 1;
    }

    if (cents < 0 || cents > 99)
    {
        SendServerMessage(playerid,"A charge can only have between 0-99 cent(s)!",MSG_TYPE_WARN);
        return 1;
    }

    if (amount > CHARGE_MAX_AMOUNT || (amount == CHARGE_MAX_AMOUNT && cents > 0))
    {
        SendServerMessage(playerid,"A charge can't be more than $5,000!",MSG_TYPE_WARN);
        return 1;
    }

    if (amount == 0 && cents == 0)
    {
        SendServerMessage(playerid,"A charge needs an amount.",MSG_TYPE_WARN);
        return 1;
    }

    s_ChargeAmount[playerid] = Money_Make(amount,cents);
    strcopy(s_ChargeText[playerid],charge,CHARGE_TEXT_LEN);
    SetTimerEx("Charge_Deferred",0,false,"ddddds",playerid,Account_GetToken(playerid),CHARGE_FLOW_ADD,0,0,user);
    return 1;
}

CMD:clearcharge(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Charge_Require(playerid))
    {
        return 1;
    }

    if (Point_FindService(playerid,POINT_BIZ_SHERIFF) == 0)
    {
        SendServerMessage(playerid,"You are not in a sheriff's office!",MSG_TYPE_ERROR);
        return 1;
    }

    new target, chargeid;

    if (sscanf(params,"ui",target,chargeid))
    {
        SendServerMessage(playerid,"/clearcharge [playerid] [chargeid]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_IsValidTarget(target))
    {
        SendServerMessage(playerid,"Player isn't online.",MSG_TYPE_ERROR);
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(target,x,y,z);

    if (!IsPlayerInRangeOfPoint(playerid,CHARGE_CLEAR_RANGE,x,y,z) || GetPlayerInterior(playerid) != GetPlayerInterior(target) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(target))
    {
        SendServerMessage(playerid,"You are not near that player.",MSG_TYPE_ERROR);
        return 1;
    }

    SetTimerEx("Charge_Deferred",0,false,"ddddds",playerid,Account_GetToken(playerid),CHARGE_FLOW_CLEAR,target,chargeid,"");
    return 1;
}

CMD:viewcharges(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Charge_Require(playerid))
    {
        return 1;
    }

    new user[ACCOUNT_NAME_LEN];

    if (sscanf(params,"s[24]",user))
    {
        SendServerMessage(playerid,"/viewcharges [player_name]",MSG_TYPE_ERROR);
        return 1;
    }

    if (Point_FindService(playerid,POINT_BIZ_SHERIFF) == 0)
    {
        SendServerMessage(playerid,"You are not in a sheriff's office!",MSG_TYPE_ERROR);
        return 1;
    }

    SetTimerEx("Charge_Deferred",0,false,"ddddds",playerid,Account_GetToken(playerid),CHARGE_FLOW_VIEW,0,0,user);
    return 1;
}

public Charge_Deferred(playerid,token,flow,target,chargeid,const name[])
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    switch (flow)
    {
        case CHARGE_FLOW_ADD:
        {
            Charge_Add(playerid,s_ChargeAmount[playerid],name,s_ChargeText[playerid]);
        }
        case CHARGE_FLOW_CLEAR:
        {
            Charge_Clear(playerid,target,chargeid);
        }
        case CHARGE_FLOW_VIEW:
        {
            Charge_View(playerid,name);
        }
    }

    return 1;
}
