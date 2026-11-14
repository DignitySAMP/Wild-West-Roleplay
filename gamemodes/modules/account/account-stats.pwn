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
#define STATS_TIME_OFFSET (3600)

static const s_StatsGenders[2][] = {"Male","Female"};
static const s_StatsRaces[5][] = {"Caucasian","Hispanic","African","Asian","Native"};
static const s_StatsTowns[2][] = {"Longcreek","Fremont"};

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
stock Stats_ToDate(timestamp,&year,&month,&day,&hour,&minute,&second)
{
    new shifted = timestamp + STATS_TIME_OFFSET, days = shifted / 86400, rest = shifted % 86400;
    hour = rest / 3600;
    minute = (rest % 3600) / 60;
    second = rest % 60;

    days += 719468;
    new era = days / 146097, dayOfEra = days - era * 146097;
    new yearOfEra = (dayOfEra - dayOfEra / 1460 + dayOfEra / 36524 - dayOfEra / 146096) / 365;
    new dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100);
    new shiftedMonth = (5 * dayOfYear + 2) / 153;

    day = dayOfYear - (153 * shiftedMonth + 2) / 5 + 1;
    month = shiftedMonth < 10 ? shiftedMonth + 3 : shiftedMonth - 9;
    year = yearOfEra + era * 400 + (month <= 2 ? 1 : 0);
}

stock Stats_Show(playerid,targetid = INVALID_PLAYER_ID)
{
    if (targetid == INVALID_PLAYER_ID)
    {
        targetid = playerid;
    }

    new line[512], name[ACCOUNT_NAME_LEN], year, month, day, hour, minute, second;
    GetPlayerName(targetid,name,sizeof(name));

    format(line,sizeof(line),"|________________________| Statistics of (%d) %s [accid: %d, charid: %d] |________________________|",targetid,name,g_Account[targetid][E_ACCOUNT_ID],g_Character[targetid][E_CHARACTER_ID]);
    SendClientMessage(playerid,COLOR_TAB0,line);

    Stats_ToDate(g_Account[targetid][E_ACCOUNT_LAST_LOGIN],year,month,day,hour,minute,second);
    format(line,sizeof(line),"[ACCOUNT]{A3A3A3} [Master Account]: %s{FFFFFF} [Creation Date]: %s{A3A3A3} [Last Login Date]: %02d/%02d/%d - %02d:%02d:%02d",g_Account[targetid][E_ACCOUNT_NAME],g_Account[targetid][E_ACCOUNT_CREATION],day,month,year,hour,minute,second);
    SendClientMessage(playerid,COLOR_TAB1,line);

    new rank[36], group[36], donator[32];
    Account_GetStaffRankName(g_Account[targetid][E_ACCOUNT_STAFF_LEVEL],rank);
    Account_GetStaffGroupName(g_Account[targetid][E_ACCOUNT_STAFF_GROUP],group);
    Account_GetDonatorRankName(g_Account[targetid][E_ACCOUNT_DONATOR_LEVEL],donator);
    format(line,sizeof(line),"[DATA]{A3A3A3} [Staff Level]: %s (%d){FFFFFF} [Staff Group]: %s (%d){A3A3A3} [Donator Level]: %s (%d){FFFFFF}",rank,g_Account[targetid][E_ACCOUNT_STAFF_LEVEL],group,g_Account[targetid][E_ACCOUNT_STAFF_GROUP],donator,g_Account[targetid][E_ACCOUNT_DONATOR_LEVEL]);
    SendClientMessage(playerid,COLOR_TAB2,line);

    format(line,sizeof(line),"[LEVEL]{A3A3A3} [Level]: %d (%d exp left){FFFFFF} [Hours: %d]",g_Character[targetid][E_CHARACTER_LEVEL],g_Character[targetid][E_CHARACTER_EXPLEFT],g_Character[targetid][E_CHARACTER_HOURS]);
    SendClientMessage(playerid,COLOR_TAB1,line);

    new gender = g_Character[targetid][E_CHARACTER_GENDER], origin = g_Character[targetid][E_CHARACTER_ORIGIN], town = g_Character[targetid][E_CHARACTER_TOWN];
    gender = gender >= 0 && gender < 2 ? gender : 0;
    origin = origin >= 0 && origin < 5 ? origin : 0;
    town = town >= 0 && town < 2 ? town : 0;

    format(line,sizeof(line),"[CHAR]{A3A3A3} [Gender]: %s{FFFFFF} [Age]: %d{A3A3A3} [Skin ID]: %d",s_StatsGenders[gender],g_Character[targetid][E_CHARACTER_AGE],g_Character[targetid][E_CHARACTER_SKIN]);
    SendClientMessage(playerid,COLOR_TAB2,line);

    format(line,sizeof(line),"[CHAR]{A3A3A3} [Race]: %s{FFFFFF} [Spawn Town]: %s",s_StatsRaces[origin],s_StatsTowns[town]);
    SendClientMessage(playerid,COLOR_TAB1,line);

    pawn_call_public("Account_OnStatistics","dd",playerid,targetid);
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
public Account_OnStatistics(playerid,targetid)
{
    return 1;
}
