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
enum e_SELL
{
    E_SELL_EXTRA,
    E_SELL_BIZ,
    E_SELL_MIN,
    E_SELL_MAX,
}

static const s_ShopSellTable[][e_SELL] =
{
    {E_ITEM_EXTRA_FISHING_BLUE_1,POINT_BIZ_HUNTING,10,21},
    {E_ITEM_EXTRA_FISHING_BLUE_2,POINT_BIZ_HUNTING,20,34},
    {E_ITEM_EXTRA_FISHING_YELLOW,POINT_BIZ_HUNTING,8,20},
    {E_ITEM_EXTRA_FISHING_BIGFISH,POINT_BIZ_HUNTING,13,28},
    {E_ITEM_EXTRA_FISHING_SHARK,POINT_BIZ_HUNTING,50,99},
    {E_ITEM_EXTRA_WILDLIFE_HIDE,POINT_BIZ_HUNTING,20,60},
    {E_ITEM_EXTRA_WILDLIFE_MEAT,POINT_BIZ_HUNTING,25,70},
    {E_ITEM_EXTRA_WILDLIFE_MEAT_LEG,POINT_BIZ_HUNTING,25,70},
    {E_ITEM_EXTRA_MINE_ROCK,POINT_BIZ_BLACKSMITH,1,5},
    {E_ITEM_EXTRA_MINE_IRON_ORE,POINT_BIZ_BLACKSMITH,15,33},
    {E_ITEM_EXTRA_MINE_COPPER_ORE,POINT_BIZ_BLACKSMITH,15,33},
    {E_ITEM_EXTRA_MINE_GOLD_ORE,POINT_BIZ_BLACKSMITH,45,85},
    {E_ITEM_EXTRA_MINE_COAL_ORE,POINT_BIZ_BLACKSMITH,13,31},
    {E_ITEM_EXTRA_MINE_TIN_ORE,POINT_BIZ_BLACKSMITH,13,31},
    {E_ITEM_EXTRA_LUMBER_OAK_LOG,POINT_BIZ_BLACKSMITH,8,21},
    {E_ITEM_EXTRA_LUMBER_BIRCH_LOG,POINT_BIZ_BLACKSMITH,6,15},
    {E_ITEM_EXTRA_LUMBER_YEW_LOG,POINT_BIZ_BLACKSMITH,15,30}
};

forward Shop_UseSell(playerid,uid,item,extra);
forward Shop_OnSold(playerid,item,extra,cents);
forward Shop_OnSellAttempt(playerid,uid,item);

static bool:s_ShopSellHandled[MAX_PLAYERS];

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
stock Shop_SetSellHandled(playerid)
{
    s_ShopSellHandled[playerid] = true;
}

static Shop_RandomRange(low,high)
{
    return low + random(high - low + 1);
}

static Shop_SellRow(biz,extra)
{
    for (new i = 0;i < sizeof(s_ShopSellTable);i++)
    {
        if (s_ShopSellTable[i][E_SELL_EXTRA] == extra && s_ShopSellTable[i][E_SELL_BIZ] == biz)
        {
            return i;
        }
    }

    return -1;
}

stock Shop_GetSellRange(biz,extra,&low,&high)
{
    new row = Shop_SellRow(biz,extra);

    if (row == -1)
    {
        return false;
    }

    low = s_ShopSellTable[row][E_SELL_MIN];
    high = s_ShopSellTable[row][E_SELL_MAX];
    return true;
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
public Shop_UseSell(playerid,uid,item,extra)
{
    new index = Inventory_IndexOfUid(playerid,uid);

    if (index == INV_ROW_NONE)
    {
        return 1;
    }

    s_ShopSellHandled[playerid] = false;
    pawn_call_public("Shop_OnSellAttempt","ddd",playerid,uid,item);

    if (s_ShopSellHandled[playerid])
    {
        s_ShopSellHandled[playerid] = false;
        return 1;
    }

    new pointid = Point_FindInterior(playerid,SHOP_RANGE), point[e_POINT], name[ITEM_NAME_LEN], line[160];

    if (pointid == 0 || !Point_Get(pointid,point) || point[E_POINT_TYPE] != POINT_TYPE_BIZ)
    {
        SendServerMessage(playerid,"Something went wrong. You can't sell your items at the location you're at.",MSG_TYPE_ERROR);
        return 1;
    }

    Item_GetName(item,name);

    switch (point[E_POINT_BIZTYPE])
    {
        case POINT_BIZ_HUNTING, POINT_BIZ_BLACKSMITH:
        {
            new row = Shop_SellRow(point[E_POINT_BIZTYPE],extra);

            if (row == -1)
            {
                SendServerMessage(playerid,"You can't sell these items at the location you're at.",MSG_TYPE_ERROR);
                return 1;
            }

            new cents = Shop_RandomRange(s_ShopSellTable[row][E_SELL_MIN],s_ShopSellTable[row][E_SELL_MAX]);
            Inventory_Decrease(playerid,index,1,false);
            Money_Give(playerid,cents);
            format(line,sizeof(line),"You have sold your %s for $0.%02d.",name,cents);
            SendServerMessage(playerid,line,MSG_TYPE_INFO);
            pawn_call_public("Shop_OnSold","dddd",playerid,item,extra,cents);
        }
        case POINT_BIZ_GENERAL:
        {
            if (Item_GetParam(item) != E_ITEM_PARAM_FARMING)
            {
                SendServerMessage(playerid,"You can't sell these items at the location you're at.",MSG_TYPE_ERROR);
                return 1;
            }

            new dollars = Shop_RandomRange(1,3), cents = Shop_RandomRange(50,95);
            Inventory_Decrease(playerid,index,1,false);
            Money_Give(playerid,Money_Make(dollars,cents));
            Inventory_GiveByParam(playerid,E_ITEM_PARAM_FARMING,E_ITEM_EXTRA_EMPTY_BASKET,1);
            format(line,sizeof(line),"You have sold your %s for $%d.%02d.",name,dollars,cents);
            SendServerMessage(playerid,line,MSG_TYPE_INFO);
            pawn_call_public("Shop_OnSold","dddd",playerid,item,extra,Money_Make(dollars,cents));
        }
        default:
        {
            SendServerMessage(playerid,"Something went wrong. You can't sell your items at the location you're at.",MSG_TYPE_ERROR);
        }
    }

    return 1;
}

public Shop_OnSold(playerid,item,extra,cents)
{
    return 1;
}

public Shop_OnSellAttempt(playerid,uid,item)
{
    return 1;
}

#include <pp-hooks>

hook OnGameModeInit()
{
    Inventory_RegisterUse(E_ITEM_TYPE_SELL,USE_ANY,"Shop_UseSell");
}
