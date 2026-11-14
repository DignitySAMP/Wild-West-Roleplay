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
#define MONEY_SLOTS (3)
#define MONEY_TEXT_LEN (24)
#define MONEY_MAX_DOLLARS (20000000)

enum _:E_MONEY_SLOT
{
    E_MONEY_SLOT_HAND = 0,
    E_MONEY_SLOT_BANK,
    E_MONEY_SLOT_PAYCHECK,
}

static s_MoneyCents[MAX_PLAYERS][MONEY_SLOTS];
static bool:s_MoneyLoaded[MAX_PLAYERS];

forward Money_OnChange(playerid,slot,before,after);
forward Money_OnLoaded(playerid,token);

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
stock Money_Make(dollars,cents = 0)
{
    return dollars * 100 + cents;
}

stock Money_Dollars(cents)
{
    return cents / 100;
}

stock Money_Cents(cents)
{
    return cents < 0 ? -(-cents % 100) : cents % 100;
}

stock Money_Delimit(value,dest[],size = sizeof(dest))
{
    new text[16];
    format(text,sizeof(text),"%d",value);

    for (new i = strlen(text) - 3,j = value < 0 ? 1 : 0;i > j;i -= 3)
    {
        strins(text,",",i,sizeof(text));
    }

    strcopy(dest,text,size);
}

stock Money_Format(cents,dest[],size = sizeof(dest))
{
    new whole[16], absolute = cents < 0 ? -cents : cents;
    Money_Delimit(absolute / 100,whole);
    format(dest,size,"%s$%s.%02d",cents < 0 ? ("-") : (""),whole,absolute % 100);
}

stock Money_FormatShort(cents,dest[],size = sizeof(dest))
{
    new whole[16], absolute = cents < 0 ? -cents : cents;
    Money_Delimit(absolute / 100,whole);

    if (absolute % 100 == 0)
    {
        format(dest,size,"%s$%s",cents < 0 ? ("-") : (""),whole);
        return;
    }

    format(dest,size,"%s$%s.%02d",cents < 0 ? ("-") : (""),whole,absolute % 100);
}

stock bool:Money_IsLoaded(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_MoneyLoaded[playerid];
}

stock Money_Get(playerid,slot = E_MONEY_SLOT_HAND)
{
    if (!Money_IsLoaded(playerid) || slot < 0 || slot >= MONEY_SLOTS)
    {
        return 0;
    }

    return s_MoneyCents[playerid][slot];
}

stock bool:Money_CanAfford(playerid,cents,slot = E_MONEY_SLOT_HAND)
{
    return cents >= 0 && Money_IsLoaded(playerid) && Money_Get(playerid,slot) >= cents;
}

static Money_Save(playerid)
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_money_hand = %d, character_money_bank = %d, character_money_paycheck = %d WHERE character_id = %d",s_MoneyCents[playerid][E_MONEY_SLOT_HAND],s_MoneyCents[playerid][E_MONEY_SLOT_BANK],s_MoneyCents[playerid][E_MONEY_SLOT_PAYCHECK],Character_GetId(playerid)));
}

stock Money_SyncClient(playerid)
{
    ResetPlayerMoney(playerid);
    new dollars = s_MoneyCents[playerid][E_MONEY_SLOT_HAND] / 100;

    if (dollars > 0)
    {
        GivePlayerMoney(playerid,dollars);
    }
}

static Money_Apply(playerid,slot,value)
{
    new before = s_MoneyCents[playerid][slot];
    s_MoneyCents[playerid][slot] = value;
    Money_Save(playerid);

    if (slot == E_MONEY_SLOT_HAND)
    {
        Money_SyncClient(playerid);
    }

    pawn_call_public("Money_OnChange","dddd",playerid,slot,before,value);
}

stock bool:Money_Set(playerid,cents,slot = E_MONEY_SLOT_HAND)
{
    if (!Money_IsLoaded(playerid) || slot < 0 || slot >= MONEY_SLOTS)
    {
        return false;
    }

    Money_Apply(playerid,slot,cents);
    return true;
}

stock bool:Money_Give(playerid,cents,slot = E_MONEY_SLOT_HAND)
{
    if (cents < 0 || !Money_IsLoaded(playerid) || slot < 0 || slot >= MONEY_SLOTS)
    {
        return false;
    }

    Money_Apply(playerid,slot,s_MoneyCents[playerid][slot] + cents);
    return true;
}

stock bool:Money_Take(playerid,cents,slot = E_MONEY_SLOT_HAND)
{
    if (!Money_CanAfford(playerid,cents,slot))
    {
        return false;
    }

    Money_Apply(playerid,slot,s_MoneyCents[playerid][slot] - cents);
    return true;
}

stock bool:Money_Transfer(fromid,toid,cents,slot = E_MONEY_SLOT_HAND)
{
    if (fromid == toid || !Money_IsLoaded(toid) || !Money_CanAfford(fromid,cents,slot))
    {
        return false;
    }

    Money_Take(fromid,cents,slot);
    Money_Give(toid,cents,slot);
    return true;
}

static Money_Reset(playerid)
{
    s_MoneyLoaded[playerid] = false;

    for (new i = 0;i < MONEY_SLOTS;i++)
    {
        s_MoneyCents[playerid][i] = 0;
    }
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
public Money_OnChange(playerid,slot,before,after)
{
    return 1;
}

public Money_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    Money_Reset(playerid);

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_money_hand",s_MoneyCents[playerid][E_MONEY_SLOT_HAND]);
        cache_get_value_name_int(0,"character_money_bank",s_MoneyCents[playerid][E_MONEY_SLOT_BANK]);
        cache_get_value_name_int(0,"character_money_paycheck",s_MoneyCents[playerid][E_MONEY_SLOT_PAYCHECK]);
    }

    s_MoneyLoaded[playerid] = true;
    Money_SyncClient(playerid);
    pawn_call_public("Money_OnChange","dddd",playerid,E_MONEY_SLOT_HAND,0,s_MoneyCents[playerid][E_MONEY_SLOT_HAND]);
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
    Money_Reset(playerid);
}

hook Character_OnLoad(playerid,characterid)
{
    Money_Reset(playerid);
    mysql_tquery_s(g_Mysql,str_format("SELECT character_money_hand, character_money_bank, character_money_paycheck FROM characters WHERE character_id = %d",characterid),"Money_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    Money_Reset(playerid);
}

hook Character_OnCreated(playerid,characterid)
{
    new hand = Money_Make(10,random(25) + 1), bank = Money_Make(25,random(25) + 1);
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_money_hand = %d, character_money_bank = %d WHERE character_id = %d",hand,bank,characterid));
}

hook Account_OnStatistics(playerid,targetid)
{
    new line[200], hand[MONEY_TEXT_LEN], bank[MONEY_TEXT_LEN], pay[MONEY_TEXT_LEN];
    Money_Format(Money_Get(targetid,E_MONEY_SLOT_HAND),hand);
    Money_Format(Money_Get(targetid,E_MONEY_SLOT_BANK),bank);
    Money_Format(Money_Get(targetid,E_MONEY_SLOT_PAYCHECK),pay);
    format(line,sizeof(line),"[MONEY]{A3A3A3}[Money]: %s{FFFFFF} [Bank Money]: %s {A3A3A3}[Paycheck]: %s",hand,bank,pay);
    SendClientMessage(playerid,COLOR_TAB2,line);
}
