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
#define TIME_TICK_MS (30000)
#define TIME_MONTH_NAME_LEN (10)
#define TIME_DATE_LEN (96)
#define TIME_DEFAULT_MINUTE (30)
#define TIME_DEFAULT_HOUR (9)
#define TIME_DEFAULT_DAY (1)
#define TIME_DEFAULT_MONTH (1)
#define TIME_DEFAULT_YEAR (1850)

enum _:E_TIME_SEASON
{
    E_TIME_SEASON_SPRING = 0,
    E_TIME_SEASON_SUMMER,
    E_TIME_SEASON_AUTUMN,
    E_TIME_SEASON_WINTER,
}

static const s_TimeMonthNames[12][TIME_MONTH_NAME_LEN] =
{
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
};

static const s_TimeMonthDays[12] = {31,28,31,30,31,30,31,31,30,31,30,31};
static const s_TimeSeasonNames[4][8] = {"Spring","Summer","Autumn","Winter"};
static const s_TimeWeekdays[7][10] = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
static const s_TimeWeekdayOffsets[12] = {0,3,2,5,0,3,5,1,4,6,2,4};

static s_TimeMinute = TIME_DEFAULT_MINUTE;
static s_TimeHour = TIME_DEFAULT_HOUR;
static s_TimeDay = TIME_DEFAULT_DAY;
static s_TimeMonth = TIME_DEFAULT_MONTH;
static s_TimeYear = TIME_DEFAULT_YEAR;
static bool:s_TimeLoaded;

forward Time_Load();

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
stock Time_GetMinute()
{
    return s_TimeMinute;
}

stock Time_GetHour()
{
    return s_TimeHour;
}

stock Time_GetDay()
{
    return s_TimeDay;
}

stock Time_GetMonth()
{
    return s_TimeMonth;
}

stock Time_GetYear()
{
    return s_TimeYear;
}

stock bool:Time_IsLoaded()
{
    return s_TimeLoaded;
}

stock Time_GetMonthName(month,dest[],size = sizeof(dest))
{
    if (month < 0 || month > 11)
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_TimeMonthNames[month],size);
}

stock Time_GetMonthDays(month)
{
    if (month < 0 || month > 11)
    {
        return 0;
    }

    return s_TimeMonthDays[month];
}

stock Time_GetSeason(month)
{
    switch (month)
    {
        case 2, 3, 4:
        {
            return E_TIME_SEASON_SPRING;
        }

        case 5, 6, 7:
        {
            return E_TIME_SEASON_SUMMER;
        }

        case 8, 9, 10:
        {
            return E_TIME_SEASON_AUTUMN;
        }

        case 11, 0, 1:
        {
            return E_TIME_SEASON_WINTER;
        }
    }

    return E_TIME_SEASON_SPRING;
}

stock Time_GetSeasonName(month,dest[],size = sizeof(dest))
{
    strcopy(dest,s_TimeSeasonNames[Time_GetSeason(month)],size);
}

stock Time_DayOfWeek(day,month,year)
{
    if (month < 0 || month > 11)
    {
        return 0;
    }

    new y = month < 2 ? year - 1 : year;
    return (y + y / 4 - y / 100 + y / 400 + s_TimeWeekdayOffsets[month] + day) % 7;
}

stock Time_GetWeekdayName(day,month,year,dest[],size = sizeof(dest))
{
    strcopy(dest,s_TimeWeekdays[Time_DayOfWeek(day,month,year)],size);
}

stock Time_Ordinal(number,dest[],size = sizeof(dest))
{
    number = number < 0 ? -number : number;
    new last = number % 10, tens = number % 100;

    if (tens >= 11 && tens <= 13)
    {
        strcopy(dest,"th",size);
        return;
    }

    switch (last)
    {
        case 1:
        {
            strcopy(dest,"st",size);
        }

        case 2:
        {
            strcopy(dest,"nd",size);
        }

        case 3:
        {
            strcopy(dest,"rd",size);
        }

        default:
        {
            strcopy(dest,"th",size);
        }
    }
}

stock Time_FormatDate(dest[],size = sizeof(dest))
{
    new weekday[TIME_MONTH_NAME_LEN], ordinal[4], month[TIME_MONTH_NAME_LEN];
    Time_GetWeekdayName(s_TimeDay,s_TimeMonth,s_TimeYear,weekday);
    Time_Ordinal(s_TimeDay,ordinal);
    Time_GetMonthName(s_TimeMonth,month);
    format(dest,size,"%s the %d%s,~n~%s, %d",weekday,s_TimeDay,ordinal,month,s_TimeYear);
}

stock Time_FormatClock(dest[],size = sizeof(dest))
{
    format(dest,size,"%02d/%02d/%d - %02d:%02d",s_TimeDay,s_TimeMonth + 1,s_TimeYear,s_TimeHour,s_TimeMinute);
}

static Time_Refresh()
{
    new text[TIME_DATE_LEN];
    Time_FormatDate(text);
    Hud_SetDate(text);
    SetWorldTime(s_TimeHour);
}

static Time_Save()
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE servertime SET time_minute = %d, time_hour = %d, time_day = %d, time_month = %d, time_year = %d WHERE time_id = 1",s_TimeMinute,s_TimeHour,s_TimeDay,s_TimeMonth,s_TimeYear));
}

stock bool:Time_Set(minute,hour,day,month,year)
{
    if (minute < 0 || minute > 59 || hour < 0 || hour > 23 || month < 0 || month > 11 || day < 1 || day > s_TimeMonthDays[month] || year < 1)
    {
        return false;
    }

    s_TimeMinute = minute;
    s_TimeHour = hour;
    s_TimeDay = day;
    s_TimeMonth = month;
    s_TimeYear = year;
    Time_Refresh();
    Time_Save();
    return true;
}

stock bool:Time_SetHour(hour)
{
    return Time_Set(s_TimeMinute,hour,s_TimeDay,s_TimeMonth,s_TimeYear);
}

stock Time_Advance()
{
    if (++s_TimeMinute >= 60)
    {
        s_TimeMinute = 0;

        if (++s_TimeHour >= 24)
        {
            s_TimeHour = 0;

            if (++s_TimeDay > s_TimeMonthDays[s_TimeMonth])
            {
                s_TimeDay = 1;

                if (++s_TimeMonth >= 12)
                {
                    s_TimeMonth = 0;
                    s_TimeYear++;
                }
            }
        }
    }

    Time_Refresh();
    Time_Save();
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
#pragma warning push
#pragma warning disable 204
public Time_Load()
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("INSERT IGNORE INTO servertime (time_id, time_minute, time_hour, time_day, time_month, time_year) VALUES (1, %d, %d, %d, %d, %d)",TIME_DEFAULT_MINUTE,TIME_DEFAULT_HOUR,TIME_DEFAULT_DAY,TIME_DEFAULT_MONTH,TIME_DEFAULT_YEAR),false);
    await mysql_aquery_s(g_Mysql,str_new("SELECT time_minute, time_hour, time_day, time_month, time_year FROM servertime WHERE time_id = 1"),false);

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"time_minute",s_TimeMinute);
        cache_get_value_name_int(0,"time_hour",s_TimeHour);
        cache_get_value_name_int(0,"time_day",s_TimeDay);
        cache_get_value_name_int(0,"time_month",s_TimeMonth);
        cache_get_value_name_int(0,"time_year",s_TimeYear);
    }

    s_TimeLoaded = true;
    Time_Refresh();
    Boot_LoaderDone();
    return 1;
}
#pragma warning pop

Timer_Declare(Time_TickTimer)
{

    if (!s_TimeLoaded)
    {
        return 1;
    }

    Time_Advance();
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

hook OnMigrationRun()
{
    Migration_Add("time-1-servertime","CREATE TABLE IF NOT EXISTS servertime (time_id TINYINT UNSIGNED NOT NULL DEFAULT 1, time_minute INT NOT NULL DEFAULT 30, time_hour INT NOT NULL DEFAULT 9, time_day INT NOT NULL DEFAULT 1, time_month INT NOT NULL DEFAULT 1, time_year INT NOT NULL DEFAULT 1850, PRIMARY KEY (time_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
}

hook OnGameModeInit()
{
    Boot_RegisterLoader("Time_Load");
    Timer_Start(Time_TickTimer,TIME_TICK_MS);
    Time_Refresh();
}
