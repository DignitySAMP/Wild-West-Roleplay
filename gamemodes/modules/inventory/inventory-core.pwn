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
#define INV_SLOTS_MAX (18)
#define INV_SLOTS_PAGE (9)
#define INV_ROW_NONE (-1)
#define INV_LOAD_QUERY "SELECT player_table_id, player_item_id, player_item_amount, player_item_param1, player_item_param2 FROM items_player WHERE player_database_id = %d ORDER BY player_table_id"

enum e_INV_ROW
{
    E_INV_ROW_UID,
    E_INV_ROW_ID,
    E_INV_ROW_ITEM,
    E_INV_ROW_AMOUNT,
    E_INV_ROW_PARAM1,
    E_INV_ROW_PARAM2,
}

static List:s_InvRows[MAX_PLAYERS];
static bool:s_InvLoaded[MAX_PLAYERS];
static s_InvEpoch[MAX_PLAYERS];
static s_InvBackpack[MAX_PLAYERS];
static s_InvNextUid = 1;

forward Inventory_OnLoaded(playerid,token,epoch);
forward Inventory_OnBackpackLoaded(playerid,token);
forward Inventory_OnInserted(playerid,epoch,uid,amount);
forward Inventory_OnChanged(playerid);
forward Inventory_OnRowRemoved(playerid,uid,item);

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
stock bool:Inventory_IsLoaded(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_InvLoaded[playerid];
}

stock Inventory_GetCount(playerid)
{
    if (!Inventory_IsLoaded(playerid))
    {
        return 0;
    }

    return list_size(s_InvRows[playerid]);
}

stock Inventory_GetBackpackLevel(playerid)
{
    return s_InvBackpack[playerid];
}

stock Inventory_GetCapacity(playerid)
{
    switch (s_InvBackpack[playerid])
    {
        case 1:
        {
            return 12;
        }
        case 2:
        {
            return 18;
        }
    }

    return 6;
}

stock bool:Inventory_SetBackpack(playerid,level)
{
    if (level < 0 || level > 2 || !Player_IsReady(playerid))
    {
        return false;
    }

    s_InvBackpack[playerid] = level;
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_backpack = %d WHERE character_id = %d",level,Character_GetId(playerid)));
    return true;
}

stock bool:Inventory_GetRow(playerid,index,row[e_INV_ROW])
{
    if (!Inventory_IsLoaded(playerid) || index < 0 || index >= list_size(s_InvRows[playerid]))
    {
        return false;
    }

    list_get_arr(s_InvRows[playerid],index,row);
    return true;
}

stock Inventory_IndexOfUid(playerid,uid)
{
    if (!Inventory_IsLoaded(playerid) || uid <= 0)
    {
        return INV_ROW_NONE;
    }

    for (new i = 0,count = list_size(s_InvRows[playerid]);i < count;i++)
    {
        if (list_get(s_InvRows[playerid],i,_:E_INV_ROW_UID) == uid)
        {
            return i;
        }
    }

    return INV_ROW_NONE;
}

stock Inventory_GetUid(playerid,index)
{
    new row[e_INV_ROW];

    if (!Inventory_GetRow(playerid,index,row))
    {
        return 0;
    }

    return row[E_INV_ROW_UID];
}

stock Inventory_FindItem(playerid,item)
{
    new row[e_INV_ROW];

    for (new i = 0,count = Inventory_GetCount(playerid);i < count;i++)
    {
        list_get_arr(s_InvRows[playerid],i,row);

        if (row[E_INV_ROW_ITEM] == item)
        {
            return i;
        }
    }

    return INV_ROW_NONE;
}

stock Inventory_FindExtra(playerid,extra)
{
    new row[e_INV_ROW];

    for (new i = 0,count = Inventory_GetCount(playerid);i < count;i++)
    {
        list_get_arr(s_InvRows[playerid],i,row);

        if (row[E_INV_ROW_PARAM2] == extra)
        {
            return i;
        }
    }

    return INV_ROW_NONE;
}

stock Inventory_GetExtraAmount(playerid,extra)
{
    new index = Inventory_FindExtra(playerid,extra);

    if (index == INV_ROW_NONE)
    {
        return -1;
    }

    return list_get(s_InvRows[playerid],index,_:E_INV_ROW_AMOUNT);
}

stock Inventory_GetExtraTotal(playerid,extra)
{
    new row[e_INV_ROW], total = 0;

    for (new i = 0,count = Inventory_GetCount(playerid);i < count;i++)
    {
        list_get_arr(s_InvRows[playerid],i,row);

        if (row[E_INV_ROW_PARAM2] == extra)
        {
            total += row[E_INV_ROW_AMOUNT];
        }
    }

    return total > 0 ? total : -1;
}

stock Inventory_GetAmount(playerid,item,param1,param2)
{
    new row[e_INV_ROW];

    for (new i = 0,count = Inventory_GetCount(playerid);i < count;i++)
    {
        list_get_arr(s_InvRows[playerid],i,row);

        if (row[E_INV_ROW_ITEM] == item && row[E_INV_ROW_PARAM1] == param1 && row[E_INV_ROW_PARAM2] == param2)
        {
            return row[E_INV_ROW_AMOUNT];
        }
    }

    return -1;
}

static stock Inventory_Changed(playerid)
{
    pawn_call_public("Inventory_OnChanged","d",playerid);
}

static stock Inventory_SaveAmount(playerid,index)
{
    new row[e_INV_ROW];
    list_get_arr(s_InvRows[playerid],index,row);

    if (row[E_INV_ROW_ID] > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE items_player SET player_item_amount = %d WHERE player_table_id = %d AND player_database_id = %d",row[E_INV_ROW_AMOUNT],row[E_INV_ROW_ID],Character_GetId(playerid)));
    }
}

static stock Inventory_AddRow(playerid,item,amount,param1,param2)
{
    new row[e_INV_ROW];
    row[E_INV_ROW_UID] = s_InvNextUid++;
    row[E_INV_ROW_ID] = 0;
    row[E_INV_ROW_ITEM] = item;
    row[E_INV_ROW_AMOUNT] = amount;
    row[E_INV_ROW_PARAM1] = param1;
    row[E_INV_ROW_PARAM2] = param2;
    list_add_arr(s_InvRows[playerid],row);
    mysql_tquery_s(g_Mysql,str_format("INSERT INTO items_player (player_database_id, player_item_id, player_item_amount, player_item_param1, player_item_param2) VALUES (%d, %d, %d, %d, %d)",Character_GetId(playerid),item,amount,param1,param2),"Inventory_OnInserted","dddd",playerid,s_InvEpoch[playerid],row[E_INV_ROW_UID],amount);
    return row[E_INV_ROW_UID];
}

stock bool:Inventory_Remove(playerid,index)
{
    new row[e_INV_ROW];

    if (!Inventory_GetRow(playerid,index,row))
    {
        return false;
    }

    list_remove(s_InvRows[playerid],index);

    if (row[E_INV_ROW_ID] > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("DELETE FROM items_player WHERE player_table_id = %d AND player_database_id = %d",row[E_INV_ROW_ID],Character_GetId(playerid)));
    }

    pawn_call_public("Inventory_OnRowRemoved","ddd",playerid,row[E_INV_ROW_UID],row[E_INV_ROW_ITEM]);
    Inventory_Changed(playerid);
    return true;
}

stock bool:Inventory_Decrease(playerid,index,amount = 1,bool:message = true)
{
    new row[e_INV_ROW];

    if (amount < 1 || !Inventory_GetRow(playerid,index,row))
    {
        return false;
    }

    if (amount >= row[E_INV_ROW_AMOUNT])
    {
        Inventory_Remove(playerid,index);

        if (message)
        {
            SendServerMessage(playerid,"You've used the last quantity you had of this item.",MSG_TYPE_ERROR);
        }

        return true;
    }

    list_set_cell(s_InvRows[playerid],index,_:E_INV_ROW_AMOUNT,row[E_INV_ROW_AMOUNT] - amount);
    Inventory_SaveAmount(playerid,index);
    Inventory_Changed(playerid);
    return true;
}

stock Inventory_DecreaseExtra(playerid,extra,amount,bool:message = true)
{
    new left = amount, row[e_INV_ROW];

    for (new i = 0;i < Inventory_GetCount(playerid) && left > 0;i++)
    {
        list_get_arr(s_InvRows[playerid],i,row);

        if (row[E_INV_ROW_PARAM2] != extra)
        {
            continue;
        }

        if (left >= row[E_INV_ROW_AMOUNT])
        {
            left -= row[E_INV_ROW_AMOUNT];
            Inventory_Remove(playerid,i);

            if (message)
            {
                SendServerMessage(playerid,"You've used the last quantity you had of this item.",MSG_TYPE_ERROR);
            }

            i--;
            continue;
        }

        list_set_cell(s_InvRows[playerid],i,_:E_INV_ROW_AMOUNT,row[E_INV_ROW_AMOUNT] - left);
        Inventory_SaveAmount(playerid,i);
        left = 0;
    }

    Inventory_Changed(playerid);
    return amount - left;
}

stock Inventory_FreeSlots(playerid)
{
    new free = Inventory_GetCapacity(playerid) - Inventory_GetCount(playerid);
    return free > 0 ? free : 0;
}

stock bool:Inventory_CanHold(playerid,item,amount,param1 = -1,param2 = -1)
{
    if (!Item_IsValid(item) || amount < 1 || !Inventory_IsLoaded(playerid))
    {
        return false;
    }

    if (param1 == -1)
    {
        param1 = Item_GetParam(item);
    }

    if (param2 == -1)
    {
        param2 = Item_GetExtra(item);
    }

    new stack = Item_GetStack(item), space = 0, row[e_INV_ROW];

    for (new i = 0,count = list_size(s_InvRows[playerid]);i < count;i++)
    {
        list_get_arr(s_InvRows[playerid],i,row);

        if (row[E_INV_ROW_ITEM] == item && row[E_INV_ROW_PARAM1] == param1 && row[E_INV_ROW_PARAM2] == param2 && row[E_INV_ROW_AMOUNT] < stack)
        {
            space += stack - row[E_INV_ROW_AMOUNT];
        }
    }

    new rest = amount > space ? amount - space : 0, rows = (rest + stack - 1) / stack;
    return rows <= Inventory_FreeSlots(playerid);
}

stock bool:Inventory_Give(playerid,item,amount,param1 = -1,param2 = -1,price = 0,bool:message = true)
{
    if (!Item_IsValid(item))
    {
        new line[128];
        format(line,sizeof(line),"Itemid returned -1, send this to a developer and/or make a bug report.  [%d|%d]",param1,param2);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return false;
    }

    if (!Player_IsReady(playerid) || !Inventory_IsLoaded(playerid) || amount < 1 || price < 0)
    {
        return false;
    }

    if (param1 == -1)
    {
        param1 = Item_GetParam(item);
    }

    if (param2 == -1)
    {
        param2 = Item_GetExtra(item);
    }

    if (!Inventory_CanHold(playerid,item,amount,param1,param2))
    {
        if (price > 0)
        {
            SendServerMessage(playerid,"You don't have enough inventory slots! The transaction was cancelled.",MSG_TYPE_ERROR);
        }
        else
        {
            SendServerMessage(playerid,"You don't have enough backpack size to pick this item up. You have to get a bigger backpack.",MSG_TYPE_ERROR);
        }

        return false;
    }

    new name[ITEM_NAME_LEN], line[160];
    Item_GetName(item,name);

    if (price > 0 && !Money_CanAfford(playerid,price))
    {
        new cost[MONEY_TEXT_LEN];
        Money_FormatShort(price,cost);
        format(line,sizeof(line),"You don't have enough money to purchase a %s. You need at least %s.",name,cost);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return false;
    }

    new stack = Item_GetStack(item), left = amount, row[e_INV_ROW], bool:merged = false;

    for (new i = 0,count = list_size(s_InvRows[playerid]);i < count && left > 0;i++)
    {
        list_get_arr(s_InvRows[playerid],i,row);

        if (row[E_INV_ROW_ITEM] != item || row[E_INV_ROW_PARAM1] != param1 || row[E_INV_ROW_PARAM2] != param2 || row[E_INV_ROW_AMOUNT] >= stack)
        {
            continue;
        }

        new add = stack - row[E_INV_ROW_AMOUNT];

        if (add > left)
        {
            add = left;
        }

        list_set_cell(s_InvRows[playerid],i,_:E_INV_ROW_AMOUNT,row[E_INV_ROW_AMOUNT] + add);
        Inventory_SaveAmount(playerid,i);
        left -= add;
        merged = true;
    }

    new bool:created = left > 0;

    while (left > 0)
    {
        new put = left > stack ? stack : left;
        Inventory_AddRow(playerid,item,put,param1,param2);
        left -= put;
    }

    if (price > 0)
    {
        Money_Take(playerid,price);
    }

    if (message)
    {
        if (price > 0)
        {
            if (price < 100)
            {
                format(line,sizeof(line),"You have purchased a %s for %d cents.",name,price);
            }
            else
            {
                new cost[MONEY_TEXT_LEN];
                Money_FormatShort(price,cost);
                format(line,sizeof(line),"You have purchased a %s for %s.",name,cost);
            }
        }
        else if (merged && !created)
        {
            format(line,sizeof(line),"You tried to loot item (%d) %s but already owned it. It's amount (%d) has been stacked onto the existing item.",item,name,amount);
        }
        else
        {
            format(line,sizeof(line),"You have received %d of item id (%d) %s.",amount,item,name);
        }

        SendServerMessage(playerid,line,MSG_TYPE_INFO);
    }

    Inventory_Changed(playerid);
    return true;
}

stock bool:Inventory_GiveByParam(playerid,param,extra,amount,param1 = -1,param2 = -1,price = 0)
{
    new item = Item_FindByParam(param,extra);

    if (item == ITEM_NONE)
    {
        new line[128];
        format(line,sizeof(line),"Error processing GivePlayerItemByParam request. [PLAYER: %d] [ERROR CODE: %d, %d]",playerid,param,extra);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return false;
    }

    return Inventory_Give(playerid,item,amount,param1,param2,price);
}

stock bool:Inventory_Split(playerid,index)
{
    new row[e_INV_ROW];

    if (!Inventory_GetRow(playerid,index,row))
    {
        return false;
    }

    if (row[E_INV_ROW_AMOUNT] <= 1)
    {
        SendServerMessage(playerid,"You need to actually have a stack of this item.",MSG_TYPE_ERROR);
        return false;
    }

    if (Inventory_GetCount(playerid) >= Inventory_GetCapacity(playerid))
    {
        SendServerMessage(playerid,"You don't have enough inventory slots!",MSG_TYPE_ERROR);
        return false;
    }

    new half = row[E_INV_ROW_AMOUNT] / 2, name[ITEM_NAME_LEN], line[128];
    list_set_cell(s_InvRows[playerid],index,_:E_INV_ROW_AMOUNT,row[E_INV_ROW_AMOUNT] - half);
    Inventory_SaveAmount(playerid,index);
    Inventory_AddRow(playerid,row[E_INV_ROW_ITEM],half,row[E_INV_ROW_PARAM1],row[E_INV_ROW_PARAM2]);
    Item_GetName(row[E_INV_ROW_ITEM],name);
    format(line,sizeof(line),"You have split your (%d) %s into a stack of %d.",row[E_INV_ROW_ITEM],name,half);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Inventory_Changed(playerid);
    return true;
}

static stock Inventory_Release(playerid)
{
    for (new i = list_size(s_InvRows[playerid]) - 1;i >= 0;i--)
    {
        pawn_call_public("Inventory_OnRowRemoved","ddd",playerid,list_get(s_InvRows[playerid],i,_:E_INV_ROW_UID),list_get(s_InvRows[playerid],i,_:E_INV_ROW_ITEM));
    }

    list_clear(s_InvRows[playerid]);
    s_InvEpoch[playerid]++;
}

stock Inventory_ClearAll(playerid)
{
    if (!Inventory_IsLoaded(playerid))
    {
        return;
    }

    Inventory_Release(playerid);
    mysql_tquery_s(g_Mysql,str_format("DELETE FROM items_player WHERE player_database_id = %d",Character_GetId(playerid)));
    Inventory_Changed(playerid);
}

stock Inventory_ClearBugged(playerid)
{
    mysql_tquery_s(g_Mysql,str_format("DELETE FROM items_player WHERE player_database_id = %d AND (player_item_id < 1 OR player_item_id >= %d)",Character_GetId(playerid),ITEM_COUNT));
    Inventory_Reload(playerid);
}

stock Inventory_Reload(playerid)
{
    if (!Player_IsReady(playerid))
    {
        return;
    }

    Inventory_Release(playerid);
    mysql_tquery_s(g_Mysql,str_format(INV_LOAD_QUERY,Character_GetId(playerid)),"Inventory_OnLoaded","ddd",playerid,Account_GetToken(playerid),s_InvEpoch[playerid]);
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
public Inventory_OnChanged(playerid)
{
    return 1;
}

public Inventory_OnRowRemoved(playerid,uid,item)
{
    return 1;
}

public Inventory_OnInserted(playerid,epoch,uid,amount)
{
    if (!IsPlayerConnected(playerid) || epoch != s_InvEpoch[playerid] || !s_InvLoaded[playerid])
    {
        return 1;
    }

    new id = cache_insert_id(), index = Inventory_IndexOfUid(playerid,uid);

    if (index == INV_ROW_NONE)
    {
        mysql_tquery_s(g_Mysql,str_format("DELETE FROM items_player WHERE player_table_id = %d",id));
        return 1;
    }

    list_set_cell(s_InvRows[playerid],index,_:E_INV_ROW_ID,id);
    new current = list_get(s_InvRows[playerid],index,_:E_INV_ROW_AMOUNT);

    if (current != amount)
    {
        Inventory_SaveAmount(playerid,index);
    }

    return 1;
}

public Inventory_OnLoaded(playerid,token,epoch)
{
    if (!Account_IsCurrent(playerid,token) || epoch != s_InvEpoch[playerid])
    {
        return 1;
    }

    list_clear(s_InvRows[playerid]);

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new row[e_INV_ROW];
        cache_get_value_name_int(i,"player_table_id",row[E_INV_ROW_ID]);
        cache_get_value_name_int(i,"player_item_id",row[E_INV_ROW_ITEM]);
        cache_get_value_name_int(i,"player_item_amount",row[E_INV_ROW_AMOUNT]);
        cache_get_value_name_int(i,"player_item_param1",row[E_INV_ROW_PARAM1]);
        cache_get_value_name_int(i,"player_item_param2",row[E_INV_ROW_PARAM2]);

        if (!Item_IsValid(row[E_INV_ROW_ITEM]) || row[E_INV_ROW_AMOUNT] < 1)
        {
            continue;
        }

        row[E_INV_ROW_UID] = s_InvNextUid++;
        list_add_arr(s_InvRows[playerid],row);
    }

    s_InvLoaded[playerid] = true;
    Inventory_Changed(playerid);
    return 1;
}

public Inventory_OnBackpackLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    s_InvBackpack[playerid] = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_backpack",s_InvBackpack[playerid]);
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
    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        s_InvRows[i] = list_new();
    }
}

hook OnPlayerConnect(playerid)
{
    list_clear(s_InvRows[playerid]);
    s_InvLoaded[playerid] = false;
    s_InvBackpack[playerid] = 0;
    s_InvEpoch[playerid]++;
}

hook OnPlayerDisconnect(playerid,reason)
{
    list_clear(s_InvRows[playerid]);
    s_InvLoaded[playerid] = false;
    s_InvEpoch[playerid]++;
}

hook Character_OnLoad(playerid,characterid)
{
    list_clear(s_InvRows[playerid]);
    s_InvLoaded[playerid] = false;
    s_InvEpoch[playerid]++;
    mysql_tquery_s(g_Mysql,str_format("SELECT character_backpack FROM characters WHERE character_id = %d",characterid),"Inventory_OnBackpackLoaded","dd",playerid,Account_GetToken(playerid));
    mysql_tquery_s(g_Mysql,str_format(INV_LOAD_QUERY,characterid),"Inventory_OnLoaded","ddd",playerid,Account_GetToken(playerid),s_InvEpoch[playerid]);
}

hook Character_OnUnload(playerid,characterid)
{
    Inventory_Release(playerid);
    s_InvLoaded[playerid] = false;
}
