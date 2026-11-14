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
#define LOTTERY_START (100)
#define LOTTERY_MAX (50000)
#define LOTTERY_PRICE (1)
#define LOTTERY_NUMBERS (200)
#define LOTTERY_DRAW_MS (3600000)
#define LOTTERY_TICK_MS (1000)
#define LOTTERY_COLOUR (0xAAC4E5FF)

forward Lottery_Load();

static s_LotteryPot;
static s_LotteryDue;
static s_LotteryItem;

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
stock Lottery_GetPot()
{
    return s_LotteryPot;
}

static Lottery_SavePot()
{
    mysql_pquery_s(g_Mysql,str_format("UPDATE lottery SET lottery_amount = %d",s_LotteryPot));
}

stock Lottery_AddToPot(dollars)
{
    s_LotteryPot += dollars;

    if (s_LotteryPot > LOTTERY_MAX)
    {
        s_LotteryPot = LOTTERY_MAX;
    }

    Lottery_SavePot();
}

static Lottery_Item()
{
    if (s_LotteryItem == 0)
    {
        s_LotteryItem = Item_FindByParam(E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_LOTTERY_TICKET);
    }

    return s_LotteryItem;
}

stock Lottery_Draw()
{
    new number = random(LOTTERY_NUMBERS), winners[MAX_PLAYERS], count, item = Lottery_Item(), line[256], names[200], name[ACCOUNT_NAME_LEN];

    for (new p = 0;p < MAX_PLAYERS;p++)
    {
        if (!IsPlayerConnected(p) || !Player_IsReady(p))
        {
            continue;
        }

        new bool:won = false;

        for (new i = Inventory_GetCount(p) - 1;i >= 0;i--)
        {
            new row[e_INV_ROW];

            if (!Inventory_GetRow(p,i,row) || row[E_INV_ROW_ITEM] != item)
            {
                continue;
            }

            if (row[E_INV_ROW_PARAM1] == number)
            {
                won = true;
            }

            Inventory_Remove(p,i);
        }

        if (won)
        {
            winners[count++] = p;
        }
    }

    mysql_pquery_s(g_Mysql,str_format("DELETE FROM items_player WHERE player_item_id = %d",item));

    if (count == 0)
    {
        SendSplitMessageToAll(LOTTERY_COLOUR,"[Lottery] There are no winners to the lottery.");
        return number;
    }

    new reward = s_LotteryPot / count, rest = s_LotteryPot % count;

    for (new w = 0;w < count;w++)
    {
        Money_Give(winners[w],Money_Make(reward + (w == 0 ? rest : 0)),E_MONEY_SLOT_BANK);
        Name_Real(winners[w],name);

        if (w > 0)
        {
            strcat(names,", ");
        }

        strcat(names,name);
    }

    if (count == 1)
    {
        format(line,sizeof(line),"[Lottery] %s has won the lottery of $%d.",names,reward + rest);
    }
    else
    {
        format(line,sizeof(line),"[Lottery] %s have won the lottery, each winning $%d.",names,reward);
    }

    SendSplitMessageToAll(LOTTERY_COLOUR,line);
    s_LotteryPot = LOTTERY_START;
    Lottery_SavePot();
    return number;
}

stock Lottery_Tick()
{
    if (s_LotteryDue != 0 && GetTickCount() - s_LotteryDue >= 0)
    {
        s_LotteryDue = GetTickCount() + LOTTERY_DRAW_MS;
        Lottery_Draw();
    }
}

static Lottery_Init()
{
    yield 1;
    await mysql_aquery_s(g_Mysql,str_new("SELECT lottery_amount FROM lottery"),false);

    if (cache_num_rows() == 0)
    {
        s_LotteryPot = LOTTERY_START;
        mysql_pquery_s(g_Mysql,str_format("INSERT INTO lottery (lottery_amount) VALUES (%d)",LOTTERY_START));
    }
    else
    {
        cache_get_value_name_int(0,"lottery_amount",s_LotteryPot);
    }

    Log_Info("lottery","Loaded lottery pot of %d",s_LotteryPot);
    s_LotteryDue = GetTickCount() + LOTTERY_DRAW_MS;
    Boot_LoaderDone();
}

#pragma warning push
#pragma warning disable 204
public Lottery_Load()
{
    Lottery_Init();
    return 1;
}
#pragma warning pop

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
CMD:forcelottery(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    Lottery_Draw();
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
    Migration_Add("lottery-1-pot","CREATE TABLE IF NOT EXISTS lottery (lottery_amount INT NOT NULL DEFAULT 100) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

Timer_Declare(Lottery_Timer)
{
    Lottery_Tick();
    return 1;
}

hook OnGameModeInit()
{
    s_LotteryPot = LOTTERY_START;
    Boot_RegisterLoader("Lottery_Load");
    Timer_Start(Lottery_Timer,LOTTERY_TICK_MS);
}

hook Shop_OnLottery(playerid,pointid)
{
    new item = Lottery_Item(), number = random(LOTTERY_NUMBERS), line[96];

    if (!Inventory_Give(playerid,item,1,number,E_ITEM_EXTRA_LOTTERY_TICKET,Money_Make(LOTTERY_PRICE)))
    {
        return;
    }

    Lottery_AddToPot(LOTTERY_PRICE);
    format(line,sizeof(line),"Your lottery ticket number is %d.",number);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
}
