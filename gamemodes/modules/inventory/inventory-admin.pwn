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
#define ADMIN_ITEM_PAGE (20)
#define ADMIN_ITEM_PAGES ((ITEM_COUNT + ADMIN_ITEM_PAGE - 1) / ADMIN_ITEM_PAGE)

forward Items_ListDeferred(playerid,token);

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
static Admin_ListRows(playerid,targetid)
{
    new row[e_INV_ROW], name[ITEM_NAME_LEN], line[200];

    for (new i = 0,count = Inventory_GetCount(targetid);i < count;i++)
    {
        Inventory_GetRow(targetid,i,row);
        Item_GetName(row[E_INV_ROW_ITEM],name);
        format(line,sizeof(line),"id: %d | i_id: %d\t i_name: %s\t i_amount: %d\t i_val1: %d\t i_val2: %d\n",i,row[E_INV_ROW_ITEM],name,row[E_INV_ROW_AMOUNT],row[E_INV_ROW_PARAM1],row[E_INV_ROW_PARAM2]);
        SendClientMessage(playerid,-1,line);
    }
}

stock bool:Inventory_GiveCommand(playerid,const params[])
{
    new id, amount, param1, param2;

    if (sscanf(params,"iiI(-1)I(-1)",id,amount,param1,param2))
    {
        SendClientMessage(playerid,-1,"/giveitem [item id] [amount] [extra param] [extra param] (leave extra params empty if unknown");
        return false;
    }

    if (id < 1 || id >= ITEM_COUNT)
    {
        new line[128];
        format(line,sizeof(line),"You can't go lower than ID 0. You also can't go higher than the maximum number of items (%d).",ITEM_COUNT);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return false;
    }

    if (amount > ITEM_STACK_LIMIT)
    {
        SendServerMessage(playerid,"A player can only have an item stacked five times.",MSG_TYPE_ERROR);
        return false;
    }

    if (amount < 1)
    {
        SendServerMessage(playerid,"The amount has to be at least 1.",MSG_TYPE_ERROR);
        return false;
    }

    return Inventory_Give(playerid,id,amount,param1,param2);
}

static Items_List(playerid)
{
    yield 1;

    new token = Account_GetToken(playerid), page = 0;

    for (;;)
    {
        new body[2048] = "Item ID\tItem Name\tItem Model\tItem Type\n", first = page * ADMIN_ITEM_PAGE, last = first + ADMIN_ITEM_PAGE, title[48], response[DIALOG_RESPONSE];

        if (last > ITEM_COUNT)
        {
            last = ITEM_COUNT;
        }

        for (new i = first;i < last;i++)
        {
            new name[ITEM_NAME_LEN], line[96];
            Item_GetName(i,name);
            format(line,sizeof(line),"%d\t%s\t%d\t%d\n",i,name,Item_GetModel(i),Item_GetType(i));
            strcat(body,line,sizeof(body));
        }

        new bool:hasNext = last < ITEM_COUNT;
        format(title,sizeof(title),"Item List: Page %d of %d",page + 1,ADMIN_ITEM_PAGES);
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,title,body,hasNext ? ("Next") : ("Close"),hasNext ? ("Close") : (""));

        if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE] || !hasNext)
        {
            return;
        }

        page++;
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
CMD:giveitem(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!IsPlayerAdmin(playerid))
    {
        SendClientMessage(playerid,COLOR_RED,"Fuck off.");
        return 1;
    }

    Inventory_GiveCommand(playerid,params);
    return 1;
}

CMD:showitems(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!IsPlayerAdmin(playerid))
    {
        SendClientMessage(playerid,COLOR_RED,"Fuck off.");
        return 1;
    }

    SendServerMessage(playerid,"Use /giveitem to give an item to a player.",MSG_TYPE_ERROR);
    SetTimerEx("Items_ListDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
    return 1;
}

CMD:playeritems(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    Admin_ListRows(playerid,playerid);
    return 1;
}

CMD:viewplayeritems(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_BASIC))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/viewplayeritems [playerid/name]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"That player is not connected."))
    {
        return 1;
    }

    Admin_ListRows(playerid,target);
    return 1;
}

CMD:reloaddata(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    Inventory_Reload(playerid);
    return 1;
}

CMD:invhelp(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,0x669CADFF,"Inventory Commands");
    SendClientMessage(playerid,-1,"/playeritems - Parses ALL of your items in text");
    SendClientMessage(playerid,-1,"/showitems - Displays a complete list of all items");
    SendClientMessage(playerid,-1,"Press \"N\" to display / hide your inventory.");
    return 1;
}

CMD:clearplayerinventory(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/clearplayerinventory [playerid]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"That player is not connected."))
    {
        return 1;
    }

    new line[160], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    Inventory_ClearAll(target);
    format(line,sizeof(line),"[STAFF] %s (%d) has reset your inventory.",name,playerid);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"[STAFF] %s (%d) has reset %s's (%d) inventory.",name,playerid,targetName,target);
    SendModeratorWarning(line,MOD_WARNING_MED);
    return 1;
}

CMD:clearbuggeditems(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_BASIC))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/clearbuggeditems [playerid]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"That player is not online."))
    {
        return 1;
    }

    new line[160], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    Inventory_ClearBugged(target);
    format(line,sizeof(line),"(%d) %s's bugged items should be cleared.",target,targetName);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"(%d) %s has cleared your inventory of bugged items.",playerid,name);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    return 1;
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
public Items_ListDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token) && IsPlayerAdmin(playerid))
    {
        Items_List(playerid);
    }

    return 1;
}
