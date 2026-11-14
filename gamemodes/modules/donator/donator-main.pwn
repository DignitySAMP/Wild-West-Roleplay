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
#define DONATOR_CHECK_SECONDS (1800)
#define DONATOR_RANKS (4)

#if !defined COLOR_DONATOR
    #define COLOR_DONATOR (0xB59664FF)
#endif

static const s_DonatorHex[DONATOR_RANKS][] = {"{FFFFFF}","{917656}","{AEBABD}","{DBB053}"};
static s_DonatorSeconds[MAX_PLAYERS];

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
stock Donator_GetRankName(level,dest[],size = sizeof(dest))
{
    Account_GetDonatorRankName(level >= 0 && level < DONATOR_RANKS ? level : 0,dest,size);
}

stock Donator_GetHex(level,dest[],size = sizeof(dest))
{
    strcopy(dest,s_DonatorHex[level >= 0 && level < DONATOR_RANKS ? level : 0],size);
}

stock bool:Donator_CheckExpiry(playerid)
{
    if (!Account_IsLoggedIn(playerid) || Account_GetDonatorLevel(playerid) == 0 || Account_GetDonatorExpire(playerid) >= gettime())
    {
        return false;
    }

    Account_SetDonator(playerid,0,0);
    mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_donatorlevel = 0, account_donatorexpire = 0 WHERE account_id = %d",Account_GetId(playerid)));
    SendServerMessage(playerid,"Your donator level has expired.",MSG_TYPE_WARN);
    return true;
}

static bool:Donator_CanChat(playerid)
{
    return Account_GetDonatorLevel(playerid) > 0 || Staff_IsModerator(playerid);
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
CMD:customskin(cmdid,playerid,params[])
{
    #pragma unused cmdid, playerid, params
    return 1;
}

CMD:donatorchat(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Donator_CanChat(playerid))
    {
        SendServerMessage(playerid,"You are not a donator!",MSG_TYPE_ERROR);
        return 1;
    }

    new text[144];

    if (sscanf(params,"s[144]",text))
    {
        SendServerMessage(playerid,"/d(onator)c(hat) [message]",MSG_TYPE_ERROR);
        return 1;
    }

    new line[256], name[ACCOUNT_NAME_LEN], level = Account_GetDonatorLevel(playerid);
    Account_GetRoleplayName(playerid,name);

    if (level > 0)
    {
        new rank[16], hex[12];
        Donator_GetRankName(level,rank);
        Donator_GetHex(level,hex);
        format(line,sizeof(line),"(( [%s%s{B59664} Donator] (%d) %s: %s ))",hex,rank,playerid,name,text);
    }
    else
    {
        format(line,sizeof(line),"(( [Moderator] (%d) %s: %s ))",playerid,name,text);
    }

    foreach (new i : Player)
    {
        if (Account_IsLoggedIn(i) && Donator_CanChat(i))
        {
            SendSplitMessage(i,COLOR_DONATOR,line);
        }
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
    s_DonatorSeconds[playerid] = 0;
}

hook Tick_OnPlayerSecond(playerid)
{
    if (!Account_IsLoggedIn(playerid))
    {
        return;
    }

    s_DonatorSeconds[playerid]++;

    if (s_DonatorSeconds[playerid] >= DONATOR_CHECK_SECONDS)
    {
        s_DonatorSeconds[playerid] = 0;
        Donator_CheckExpiry(playerid);
    }
}
