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
#define TELEGRAM_PRICE (500)
#define TELEGRAM_BASE (10000)
#define TELEGRAM_LIMIT (100)
#define TELEGRAM_TEXT_LEN (100)
#define TELEGRAM_DELAY_MS (300000)
#define TELEGRAM_TICK_MS (1000)
#define TELEGRAM_NONE (-1)

forward Telegram_OnNumber(playerid,token,characterid);
forward Telegram_OnPending(playerid,token,characterid);
forward Telegram_ViewDeferred(playerid,token,mode);

enum e_TELEPENDING
{
    E_TELEPENDING_NUMBER,
    E_TELEPENDING_DUE
}

static s_TeleNumber[MAX_PLAYERS];
static List:s_TelePending;

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
stock Telegram_GetNumber(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS ? s_TeleNumber[playerid] : TELEGRAM_NONE;
}

stock Telegram_PendingCount()
{
    return list_valid(s_TelePending) ? list_size(s_TelePending) : 0;
}

static Telegram_Notify(playerid)
{
    SendServerMessage(playerid,"You have recieved a telegram!",MSG_TYPE_INFO);

    if (s_TeleNumber[playerid] != TELEGRAM_NONE)
    {
        mysql_pquery_s(g_Mysql,str_format("UPDATE telegrams SET telegram_notified = 1 WHERE telegram_reciever = %d",s_TeleNumber[playerid]));
    }
}

stock Telegram_Tick()
{
    if (!list_valid(s_TelePending))
    {
        return;
    }

    new now = GetTickCount();

    for (new i = list_size(s_TelePending) - 1;i >= 0;i--)
    {
        new entry[e_TELEPENDING];
        list_get_arr(s_TelePending,i,entry);

        if (now - entry[E_TELEPENDING_DUE] < 0)
        {
            continue;
        }

        list_remove(s_TelePending,i);

        for (new p = 0;p < MAX_PLAYERS;p++)
        {
            if (IsPlayerConnected(p) && s_TeleNumber[p] == entry[E_TELEPENDING_NUMBER])
            {
                Telegram_Notify(p);
                break;
            }
        }
    }
}

public Telegram_OnNumber(playerid,token,characterid)
{
    if (!Account_IsCurrent(playerid,token) || Character_GetId(playerid) != characterid)
    {
        return 1;
    }

    s_TeleNumber[playerid] = TELEGRAM_NONE;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_telegram_id",s_TeleNumber[playerid]);
    }

    if (s_TeleNumber[playerid] != TELEGRAM_NONE)
    {
        mysql_tquery_s(g_Mysql,str_format("SELECT COUNT(*) AS waiting FROM telegrams WHERE telegram_reciever = %d AND telegram_notified = 0",s_TeleNumber[playerid]),"Telegram_OnPending","ddd",playerid,token,characterid);
    }

    return 1;
}

public Telegram_OnPending(playerid,token,characterid)
{
    if (!Account_IsCurrent(playerid,token) || Character_GetId(playerid) != characterid)
    {
        return 1;
    }

    new waiting;
    cache_get_value_name_int(0,"waiting",waiting);

    if (waiting > 0)
    {
        Telegram_Notify(playerid);
    }

    return 1;
}

static Telegram_View(playerid,token,mode)
{
    yield 1;
    new number = s_TeleNumber[playerid];
    await mysql_aquery_s(g_Mysql,str_format("SELECT telegram_sender, telegram_reciever, telegram_message, telegram_date FROM telegrams WHERE %s = %d ORDER BY telegram_id DESC LIMIT %d",mode == 0 ? "telegram_reciever" : "telegram_sender",number,TELEGRAM_LIMIT),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    new rows = cache_num_rows();

    if (rows == 0)
    {
        SendServerMessage(playerid,mode == 0 ? ("You have no telegrams!") : ("You haven't sent any telegrams!"),MSG_TYPE_ERROR);
        return;
    }

    new body[4096], line[200], message[TELEGRAM_TEXT_LEN], date[64], response[DIALOG_RESPONSE];
    strcopy(body,mode == 0 ? "From\tDate\tMessage\n" : "To\tDate\tMessage\n",sizeof(body));

    for (new i = 0;i < rows;i++)
    {
        new other;
        cache_get_value_name_int(i,mode == 0 ? "telegram_sender" : "telegram_reciever",other);
        cache_get_value_name(i,"telegram_message",message,sizeof(message));
        cache_get_value_name(i,"telegram_date",date,sizeof(date));
        format(line,sizeof(line),"%d\t%s\t%s\n",other,date,message);

        if (strlen(body) + strlen(line) >= sizeof(body))
        {
            break;
        }

        strcat(body,line);
    }

    mysql_pquery_s(g_Mysql,str_format("UPDATE telegrams SET telegram_notified = 1 WHERE telegram_reciever = %d",number));
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,mode == 0 ? ("Telegrams: Received") : ("Telegrams: Sent"),body,"Close","");
}

public Telegram_ViewDeferred(playerid,token,mode)
{
    Telegram_View(playerid,token,mode);
    return 1;
}

static Telegram_Send(playerid,token,number,const message[])
{
    yield 1;
    await mysql_aquery_s(g_Mysql,str_format("SELECT character_id FROM characters WHERE character_telegram_id = %d",number),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (cache_num_rows() == 0)
    {
        SendServerMessage(playerid,"That telegram number does not exist.",MSG_TYPE_ERROR);
        return;
    }

    new date[64], line[64];
    Staff_FormatDateTime(date);
    mysql_pquery_s(g_Mysql,str_format("INSERT INTO telegrams (telegram_sender, telegram_reciever, telegram_message, telegram_date, telegram_notified) VALUES (%d, %d, '%e', '%e', 0)",s_TeleNumber[playerid],number,message,date));
    format(line,sizeof(line),"You have sent a telegram to %d.",number);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);

    for (new p = 0;p < MAX_PLAYERS;p++)
    {
        if (IsPlayerConnected(p) && s_TeleNumber[p] == number)
        {
            if (!list_valid(s_TelePending))
            {
                s_TelePending = list_new();
            }

            new entry[e_TELEPENDING];
            entry[E_TELEPENDING_NUMBER] = number;
            entry[E_TELEPENDING_DUE] = GetTickCount() + TELEGRAM_DELAY_MS;
            list_add_arr(s_TelePending,entry);
            break;
        }
    }
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
CMD:buytelegramnumber(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (Point_FindService(playerid,POINT_BIZ_POSTAL) == 0)
    {
        SendServerMessage(playerid,"You're not inside of a postal office!",MSG_TYPE_ERROR);
        return 1;
    }

    if (s_TeleNumber[playerid] != TELEGRAM_NONE)
    {
        SendServerMessage(playerid,"You already have a telegram number!",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Money_CanAfford(playerid,Money_Make(TELEGRAM_PRICE)))
    {
        SendServerMessage(playerid,"You need $500 to buy a telegram number.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[96];
    Money_Take(playerid,Money_Make(TELEGRAM_PRICE));
    s_TeleNumber[playerid] = TELEGRAM_BASE + Character_GetId(playerid);
    mysql_pquery_s(g_Mysql,str_format("UPDATE characters SET character_telegram_id = %d WHERE character_id = %d",s_TeleNumber[playerid],Character_GetId(playerid)));
    format(line,sizeof(line),"You've bought a telegram number, your number is %d.",s_TeleNumber[playerid]);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
}

CMD:telegram(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (Point_FindService(playerid,POINT_BIZ_POSTAL) == 0)
    {
        SendServerMessage(playerid,"You're not inside of a postal office!",MSG_TYPE_ERROR);
        return 1;
    }

    if (s_TeleNumber[playerid] == TELEGRAM_NONE)
    {
        SendServerMessage(playerid,"You don't have a telegram number!",MSG_TYPE_ERROR);
        return 1;
    }

    new number, message[TELEGRAM_TEXT_LEN];

    if (sscanf(params,"ds[100]",number,message))
    {
        SendServerMessage(playerid,"/tele(gram) [number] [message]",MSG_TYPE_ERROR);
        return 1;
    }

    if (number == s_TeleNumber[playerid])
    {
        SendServerMessage(playerid,"You cannot send a telegram to yourself!",MSG_TYPE_ERROR);
        return 1;
    }

    Telegram_Send(playerid,Account_GetToken(playerid),number,message);
    return 1;
}

ALT:tele=CMD:telegram;

CMD:viewtelegrams(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (Point_FindService(playerid,POINT_BIZ_POSTAL) == 0)
    {
        SendServerMessage(playerid,"You're not inside of a postal office!",MSG_TYPE_ERROR);
        return 1;
    }

    if (s_TeleNumber[playerid] == TELEGRAM_NONE)
    {
        SendServerMessage(playerid,"You don't have a telegram number!",MSG_TYPE_ERROR);
        return 1;
    }

    new option[16], mode = 0;

    if (!sscanf(params,"s[16]",option))
    {
        if (!strcmp(option,"sent",true))
        {
            mode = 1;
        }
        else if (strcmp(option,"recieved",true) && strcmp(option,"received",true))
        {
            SendServerMessage(playerid,"/viewtelegrams [sent/recieved]",MSG_TYPE_ERROR);
            return 1;
        }
    }

    SetTimerEx("Telegram_ViewDeferred",0,false,"ddd",playerid,Account_GetToken(playerid),mode);
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
    Migration_Add("telegram-1-number","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_telegram_id INT NOT NULL DEFAULT -1");
    Migration_Add("telegram-2-telegrams","CREATE TABLE IF NOT EXISTS telegrams (telegram_id INT UNSIGNED NOT NULL AUTO_INCREMENT, telegram_sender INT NOT NULL DEFAULT 0, telegram_reciever INT NOT NULL DEFAULT 0, telegram_message VARCHAR(100) NOT NULL DEFAULT '', telegram_date VARCHAR(64) NOT NULL DEFAULT '', telegram_notified TINYINT NOT NULL DEFAULT 0, PRIMARY KEY (telegram_id), KEY idx_telegram_reciever (telegram_reciever)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

Timer_Declare(Telegram_Timer)
{
    Telegram_Tick();
    return 1;
}

hook OnGameModeInit()
{
    s_TelePending = list_new();
    Timer_Start(Telegram_Timer,TELEGRAM_TICK_MS);
}

hook OnPlayerConnect(playerid)
{
    s_TeleNumber[playerid] = TELEGRAM_NONE;
}

hook Character_OnLoad(playerid,characterid)
{
    s_TeleNumber[playerid] = TELEGRAM_NONE;
    mysql_tquery_s(g_Mysql,str_format("SELECT character_telegram_id FROM characters WHERE character_id = %d",characterid),"Telegram_OnNumber","ddd",playerid,Account_GetToken(playerid),characterid);
}

hook Character_OnUnload(playerid,characterid)
{
    s_TeleNumber[playerid] = TELEGRAM_NONE;
}
