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
#define BANK_AD_COOLDOWN_MS (30000)
#define BANK_AD_MIN_CASH (15)
#define BANK_AD_MAX_LEN (144)
#define BANK_AD_FREE_DONATOR (3)

static s_BankAdTick[MAX_PLAYERS];

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
static Bank_FormatBalance(playerid,dest[],size = sizeof(dest))
{
    new balance = Money_Get(playerid,E_MONEY_SLOT_BANK), whole[16];
    Money_Delimit(Money_Dollars(balance),whole);
    format(dest,size,"%s.%02d",whole,Money_Cents(balance));
}

static Bank_Move(playerid,bool:deposit,dollars,cents)
{
    if (dollars < 0)
    {
        SendServerMessage(playerid,deposit ? ("You cannot deposit a negative amount of money.") : ("You cannot withdraw a negative amount of money."),MSG_TYPE_ERROR);
        return;
    }

    if (cents < 0 || cents > 99)
    {
        SendServerMessage(playerid,deposit ? ("You must deposit between 1-99 cent(s).") : ("You must withdraw between 1-99 cent(s)."),MSG_TYPE_ERROR);
        return;
    }

    if (dollars > MONEY_MAX_DOLLARS)
    {
        SendServerMessage(playerid,"You don't have that much money.",MSG_TYPE_ERROR);
        return;
    }

    if (dollars == 0 && cents <= 0)
    {
        SendServerMessage(playerid,deposit ? ("You can't store less than 0 dollars or cents.") : ("You can't withdraw less than 0 dollars or cents."),MSG_TYPE_ERROR);
        return;
    }

    new amount = Money_Make(dollars,cents), from = deposit ? E_MONEY_SLOT_HAND : E_MONEY_SLOT_BANK, to = deposit ? E_MONEY_SLOT_BANK : E_MONEY_SLOT_HAND;

    if (!Money_CanAfford(playerid,amount,from))
    {
        SendServerMessage(playerid,"You don't have that much money.",MSG_TYPE_ERROR);
        return;
    }

    new oldBalance[MONEY_TEXT_LEN + 4], newBalance[MONEY_TEXT_LEN + 4], whole[16], line[160], name[ACCOUNT_NAME_LEN];
    Bank_FormatBalance(playerid,oldBalance);
    Money_Take(playerid,amount,from);
    Money_Give(playerid,amount,to);
    Bank_FormatBalance(playerid,newBalance);
    Money_Delimit(dollars,whole);

    if (cents > 0)
    {
        format(line,sizeof(line),"You've %s $%s.%02d %s your bank account.",deposit ? ("deposited") : ("withdrawn"),whole,cents,deposit ? ("into") : ("from"));
    }
    else
    {
        format(line,sizeof(line),"You've %s $%s %s your bank account.",deposit ? ("deposited") : ("withdrawn"),whole,deposit ? ("into") : ("from"));
    }

    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"New balance: $%s. Old balance: $%s.",newBalance,oldBalance);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Account_GetRoleplayName(playerid,name);
    Log_Info("bank","%s %s %d.%02d [bank: %s]",name,deposit ? ("deposited") : ("withdrew"),dollars,cents,newBalance);
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
CMD:bank(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (Point_FindService(playerid,POINT_BIZ_BANK) == 0)
    {
        SendServerMessage(playerid,"You're not inside of a bank!",MSG_TYPE_ERROR);
        return 1;
    }

    new option[24], value, cents;

    if (sscanf(params,"s[24]I(0)I(0)",option,value,cents))
    {
        SendServerMessage(playerid,"/bank [deposit, withdraw, balance] [optional:dollars] [optional:cents]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!strcmp(option,"deposit"))
    {
        Bank_Move(playerid,true,value,cents);
    }
    else if (!strcmp(option,"withdraw"))
    {
        Bank_Move(playerid,false,value,cents);
    }
    else if (!strcmp(option,"balance"))
    {
        new text[MONEY_TEXT_LEN + 4], line[96];
        Bank_FormatBalance(playerid,text);
        format(line,sizeof(line),"Bank balance: $%s",text);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
    }
    else
    {
        SendServerMessage(playerid,"/bank [deposit, withdraw, balance] [optional:dollars] [optional:cents]",MSG_TYPE_ERROR);
    }

    return 1;
}

CMD:paycheck(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    new pointid = Point_GetPlayerPoint(playerid), point[e_POINT];

    if (pointid == 0 || !Point_Get(pointid,point) || point[E_POINT_BIZTYPE] != POINT_BIZ_POSTAL || point[E_POINT_TYPE] != POINT_TYPE_BIZ)
    {
        SendServerMessage(playerid,"You're not inside of a postal office!",MSG_TYPE_ERROR);
        return 1;
    }

    new amount = Money_Get(playerid,E_MONEY_SLOT_PAYCHECK);

    if (amount <= 0)
    {
        SendServerMessage(playerid,"You don't have any money to receive through a paycheck.",MSG_TYPE_ERROR);
        return 1;
    }

    new whole[16], line[128];
    Money_Delimit(Money_Dollars(amount),whole);
    format(line,sizeof(line),"You've received $%s.%02d from your paycheck.",whole,Money_Cents(amount));
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Money_Take(playerid,amount,E_MONEY_SLOT_PAYCHECK);
    Money_Give(playerid,amount,E_MONEY_SLOT_BANK);
    return 1;
}

CMD:advertise(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (Point_FindService(playerid,POINT_BIZ_POSTAL) == 0)
    {
        SendServerMessage(playerid,"You're not inside of a postal office!",MSG_TYPE_ERROR);
        return 1;
    }

    new elapsed = GetTickCount() - s_BankAdTick[playerid], line[256], free = Account_GetDonatorLevel(playerid) >= BANK_AD_FREE_DONATOR;

    if (s_BankAdTick[playerid] != 0 && elapsed < BANK_AD_COOLDOWN_MS)
    {
        format(line,sizeof(line),"You must wait %0.2f seconds before posting another advertisement.",float(BANK_AD_COOLDOWN_MS - elapsed) / 1000.0);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return 1;
    }

    if (!free && !Money_CanAfford(playerid,Money_Make(BANK_AD_MIN_CASH)))
    {
        SendServerMessage(playerid,"You need at least $15 to post an advertisement.",MSG_TYPE_ERROR);
        return 1;
    }

    new advert[BANK_AD_MAX_LEN];

    if (sscanf(params,"s[144]",advert))
    {
        SendServerMessage(playerid,"You will have to pay per character. If you have 50 characters, you'll pay $25.",MSG_TYPE_ERROR);
        SendServerMessage(playerid,"/ad(vertise) [text]",MSG_TYPE_ERROR);
        return 1;
    }

    new price = strlen(advert) / 2;

    if (!free && !Money_CanAfford(playerid,Money_Make(price)))
    {
        format(line,sizeof(line),"You need at least $%d for this advertisement.",price);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return 1;
    }

    new name[ACCOUNT_NAME_LEN], plain[ACCOUNT_NAME_LEN];

    if (!free)
    {
        Money_Take(playerid,Money_Make(price));
    }

    format(line,sizeof(line),"[TOWN CRIER]: %s",advert);
    SendSplitMessageToAll(COLOR_TAB1,line);
    Account_GetRoleplayName(playerid,plain);
    Log_Info("advertisements","%s made ad: %s",plain,advert);

    if (!free)
    {
        new text[MONEY_TEXT_LEN];
        Money_Delimit(price,text);
        format(line,sizeof(line),"You've paid $%s for your advertisement.",text);
        SendServerMessage(playerid,line,MSG_TYPE_WARN);
    }

    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"[ADVERT] (%d) %s made the last advertisement.",playerid,name);
    SendModeratorWarning(line,MOD_WARNING_MED);
    s_BankAdTick[playerid] = GetTickCount();
    return 1;
}

ALT:ad=CMD:advertise;

#include <pp-hooks>

hook OnPlayerConnect(playerid)
{
    s_BankAdTick[playerid] = 0;
}

