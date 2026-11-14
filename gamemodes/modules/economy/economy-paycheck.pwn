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
#define PAYCHECK_INTERVAL_MINUTES (30)
#define PAYCHECK_INCOME (250)
#define PAYCHECK_CHARGES (8)
#define PAYCHECK_LABEL_LEN (24)
#define PAYCHECK_TICK_MS (60000)

static const s_PaycheckDonatorBonus[4] = {0,400,600,800};
static const s_PaycheckDonatorExperience[4] = {1,2,3,4};

static s_PaycheckMinutes[MAX_PLAYERS];
static s_PaycheckIncome[MAX_PLAYERS];
static s_PaycheckPercent[MAX_PLAYERS];
static bool:s_PaycheckSkip[MAX_PLAYERS];
static s_PaycheckChargeCount[MAX_PLAYERS];
static s_PaycheckChargeAmount[MAX_PLAYERS][PAYCHECK_CHARGES];
static s_PaycheckChargeLabel[MAX_PLAYERS][PAYCHECK_CHARGES][PAYCHECK_LABEL_LEN];
static s_PlayMinutes[MAX_PLAYERS];

forward Paycheck_OnIncome(playerid);
forward Paycheck_OnCharges(playerid);
forward Paycheck_OnSkipCheck(playerid);
forward Paycheck_OnInterval(playerid);
forward Paycheck_OnPaid(playerid,income);
forward Paycheck_OnLoaded(playerid,token);

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
stock Paycheck_SetIncome(playerid,cents)
{
    s_PaycheckIncome[playerid] = cents < 0 ? 0 : cents;
}

stock bool:Paycheck_AddCharge(playerid,const label[],cents)
{
    if (cents <= 0 || s_PaycheckChargeCount[playerid] >= PAYCHECK_CHARGES)
    {
        return false;
    }

    new slot = s_PaycheckChargeCount[playerid]++;
    s_PaycheckChargeAmount[playerid][slot] = cents;
    strcopy(s_PaycheckChargeLabel[playerid][slot],label,PAYCHECK_LABEL_LEN);
    return true;
}

stock Paycheck_RequestSkip(playerid)
{
    s_PaycheckSkip[playerid] = true;
}

stock Paycheck_SetIntervalPercent(playerid,percent)
{
    s_PaycheckPercent[playerid] = percent < 1 ? 1 : percent;
}

stock Paycheck_GetIntervalPercent(playerid)
{
    return s_PaycheckPercent[playerid];
}

stock Paycheck_GetProgress(playerid)
{
    return s_PaycheckMinutes[playerid];
}

static Paycheck_Process(playerid)
{
    s_PaycheckIncome[playerid] = PAYCHECK_INCOME;
    s_PaycheckChargeCount[playerid] = 0;
    pawn_call_public("Paycheck_OnIncome","d",playerid);
    pawn_call_public("Paycheck_OnCharges","d",playerid);

    new level = Account_GetDonatorLevel(playerid), income = s_PaycheckIncome[playerid], oldBank = Money_Get(playerid,E_MONEY_SLOT_BANK), bonus = 0, taxes = 0;

    if (level < 0 || level > 3)
    {
        level = 0;
    }

    bonus = s_PaycheckDonatorBonus[level];

    if (bonus > 0)
    {
        Money_Give(playerid,bonus,E_MONEY_SLOT_BANK);
    }

    if (income > 0)
    {
        Money_Give(playerid,income,E_MONEY_SLOT_PAYCHECK);
    }

    new paid[PAYCHECK_CHARGES];

    for (new i = 0;i < s_PaycheckChargeCount[playerid];i++)
    {
        paid[i] = s_PaycheckChargeAmount[playerid][i];

        if (paid[i] > Money_Get(playerid,E_MONEY_SLOT_BANK))
        {
            paid[i] = Money_Get(playerid,E_MONEY_SLOT_BANK);
        }

        if (paid[i] > 0)
        {
            Money_Take(playerid,paid[i],E_MONEY_SLOT_BANK);
            taxes += paid[i];
        }
    }

    if (Money_Get(playerid,E_MONEY_SLOT_PAYCHECK) < 0)
    {
        new old = Money_Get(playerid,E_MONEY_SLOT_PAYCHECK), line[160], name[ACCOUNT_NAME_LEN], text[MONEY_TEXT_LEN];
        Money_Set(playerid,0,E_MONEY_SLOT_PAYCHECK);
        Account_GetRoleplayName(playerid,name);
        Money_Format(old,text);
        format(line,sizeof(line),"[Paycheck] (%d) %s's paycheck was in the negative.  Paycheck: %s",playerid,name,text);
        SendModeratorWarning(line,MOD_WARNING_MED);
    }

    new line[256], first[MONEY_TEXT_LEN], second[MONEY_TEXT_LEN];
    SendClientMessage(playerid,COLOR_TAB0,"|_______| Paycheck |_______|");
    SendClientMessage(playerid,-1," ");

    Money_FormatShort(taxes,first);
    format(line,sizeof(line),"[Taxes paid:] %s",first);

    for (new i = 0;i < s_PaycheckChargeCount[playerid];i++)
    {
        Money_FormatShort(paid[i],first);
        format(line,sizeof(line),"%s [%s]: %s",line,s_PaycheckChargeLabel[playerid][i],first);
    }

    SendClientMessage(playerid,COLOR_TAB1,line);
    Money_Format(Money_Get(playerid,E_MONEY_SLOT_PAYCHECK),second);

    if (income > 0)
    {
        Money_Format(income,first);
        format(line,sizeof(line),"[Incoming]: %s [Total Paycheck]: %s",first,second);
    }
    else
    {
        format(line,sizeof(line),"[Incoming]: $0 [Total Paycheck]: %s",second);
    }

    SendClientMessage(playerid,COLOR_TAB1,line);

    if (level > 0)
    {
        Money_FormatShort(bonus,first);
        format(line,sizeof(line),"[Donator]: %s",first);
        SendClientMessage(playerid,COLOR_TAB1,line);
    }

    Money_Format(oldBank,first);
    Money_Format(Money_Get(playerid,E_MONEY_SLOT_BANK),second);
    format(line,sizeof(line),"[Old Balance:] %s [New Balance:] %s",first,second);
    SendClientMessage(playerid,COLOR_TAB1,line);
    SendClientMessage(playerid,-1," ");
    SendServerMessage(playerid,"To collect your paycheck, type /paycheck in any postal office.",MSG_TYPE_INFO);

    Levels_GiveExperience(playerid,s_PaycheckDonatorExperience[level]);
    pawn_call_public("Paycheck_OnPaid","dd",playerid,income);
}

stock bool:Paycheck_Force(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || IsPlayerNPC(playerid) || !Player_IsReady(playerid) || !Money_IsLoaded(playerid))
    {
        return false;
    }

    s_PaycheckMinutes[playerid] = 0;
    Paycheck_Process(playerid);
    return true;
}

static Paycheck_AddPlayMinute(playerid)
{
    s_PlayMinutes[playerid]++;
    new hours = Character_GetHours(playerid);

    if (s_PlayMinutes[playerid] >= 60)
    {
        s_PlayMinutes[playerid] = 0;
        hours++;
        Character_SetHoursCached(playerid,hours);
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_hours = %d, character_minutes = %d WHERE character_id = %d",hours,s_PlayMinutes[playerid],Character_GetId(playerid)));
}

stock Paycheck_StepPlayer(playerid)
{
    if (IsPlayerNPC(playerid) || !Player_IsReady(playerid) || !Player_IsSpawned(playerid) || !Money_IsLoaded(playerid))
    {
        return;
    }

    s_PaycheckSkip[playerid] = false;
    pawn_call_public("Paycheck_OnSkipCheck","d",playerid);

    if (s_PaycheckSkip[playerid])
    {
        return;
    }

    Paycheck_AddPlayMinute(playerid);
    s_PaycheckPercent[playerid] = 100;
    pawn_call_public("Paycheck_OnInterval","d",playerid);
    s_PaycheckMinutes[playerid]++;

    new needed = (PAYCHECK_INTERVAL_MINUTES * s_PaycheckPercent[playerid] + 99) / 100;

    if (s_PaycheckMinutes[playerid] >= needed)
    {
        s_PaycheckMinutes[playerid] = 0;
        Paycheck_Process(playerid);
    }
}

stock Paycheck_Minute()
{
    foreach (new i : Player)
    {
        Paycheck_StepPlayer(i);
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
public Paycheck_OnIncome(playerid)
{
    return 1;
}

public Paycheck_OnCharges(playerid)
{
    return 1;
}

public Paycheck_OnSkipCheck(playerid)
{
    return 1;
}

public Paycheck_OnInterval(playerid)
{
    return 1;
}

public Paycheck_OnPaid(playerid,income)
{
    return 1;
}

Timer_Declare(Paycheck_MinuteTimer)
{

    Paycheck_Minute();
    return 1;
}

public Paycheck_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    s_PlayMinutes[playerid] = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_minutes",s_PlayMinutes[playerid]);
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

hook OnGameModeInit()
{
    Timer_Start(Paycheck_MinuteTimer,PAYCHECK_TICK_MS);
}

hook OnPlayerConnect(playerid)
{
    s_PaycheckMinutes[playerid] = 0;
    s_PlayMinutes[playerid] = 0;
    s_PaycheckChargeCount[playerid] = 0;
}

hook Character_OnLoad(playerid,characterid)
{
    s_PaycheckMinutes[playerid] = 0;
    s_PlayMinutes[playerid] = 0;
    mysql_tquery_s(g_Mysql,str_format("SELECT character_minutes FROM characters WHERE character_id = %d",characterid),"Paycheck_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    s_PaycheckMinutes[playerid] = 0;
    s_PlayMinutes[playerid] = 0;
}
