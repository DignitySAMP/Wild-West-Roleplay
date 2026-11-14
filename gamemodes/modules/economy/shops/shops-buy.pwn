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
#define SHOP_RANGE (15.0)
#define SHOP_RESHOW_MS (250)

static bool:s_ShopOpen[MAX_PLAYERS];

forward Shop_OnMask(playerid,pointid);
forward Shop_OnToys(playerid,pointid);
forward Shop_OnStable(playerid,pointid);
forward Shop_OnLottery(playerid,pointid);
forward Shop_OnBought(playerid,shop,index,item);
forward Shop_MenuDeferred(playerid,token,shop);

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
stock bool:Shop_IsOpen(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_ShopOpen[playerid];
}

static Shop_Title(shop,dest[],size = sizeof(dest))
{
    switch (shop)
    {
        case SHOP_GENERAL:
        {
            strcopy(dest,"General Store",size);
        }
        case SHOP_GUN:
        {
            strcopy(dest,"Weapon Store",size);
        }
        case SHOP_BLACKSMITH, SHOP_MISC:
        {
            strcopy(dest,"Blacksmith Store",size);
        }
        case SHOP_LIQUOR:
        {
            strcopy(dest,"Liquor Store",size);
        }
        default:
        {
            strcopy(dest,"Hunting Store",size);
        }
    }
}

static bool:Shop_Refuse(playerid,const text[])
{
    SendServerMessage(playerid,text,MSG_TYPE_ERROR);
    return false;
}

static bool:Shop_BuyWeapon(playerid,const item[e_SHOP_ITEM])
{
    new line[160];

    if (Character_GetLevel(playerid) < item[E_SHOP_LEVEL])
    {
        format(line,sizeof(line),"You need to be level %d to buy a %s.",item[E_SHOP_LEVEL],item[E_SHOP_NOUN]);
        return Shop_Refuse(playerid,line);
    }

    if (!Money_CanAfford(playerid,item[E_SHOP_PRICE]))
    {
        new text[MONEY_TEXT_LEN];
        Money_FormatShort(item[E_SHOP_PRICE],text);
        format(line,sizeof(line),"You don't have enough money. You need to pay %s for a %s.",text,item[E_SHOP_NOUN]);
        return Shop_Refuse(playerid,line);
    }

    if (!Weapons_Give(playerid,item[E_SHOP_WEAPON],item[E_SHOP_AMMO]))
    {
        return true;
    }

    Money_Take(playerid,item[E_SHOP_PRICE]);
    new name[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,name);
    Log_Info("guns/points","%s (%d) has bought a %s.",name,playerid,item[E_SHOP_NOUN]);
    SendServerMessage(playerid,item[E_SHOP_BOUGHT],MSG_TYPE_INFO);
    return true;
}

static bool:Shop_BuyBackpack(playerid,const item[e_SHOP_ITEM])
{
    new capacity = Inventory_GetCapacity(playerid), wanted = item[E_SHOP_KIND] == SHOP_KIND_LARGE ? 18 : 12;

    if (capacity >= wanted)
    {
        return Shop_Refuse(playerid,item[E_SHOP_KIND] == SHOP_KIND_LARGE ? ("You already own a large backpack.") : ("You already own a backpack that is this size or bigger."));
    }

    if (!Money_CanAfford(playerid,item[E_SHOP_PRICE]))
    {
        return Shop_Refuse(playerid,"You don't have enough money.");
    }

    Money_Take(playerid,item[E_SHOP_PRICE]);
    Inventory_SetBackpack(playerid,item[E_SHOP_KIND] == SHOP_KIND_LARGE ? 2 : 1);
    SendServerMessage(playerid,item[E_SHOP_BOUGHT],MSG_TYPE_INFO);
    return true;
}

static bool:Shop_BuyItem(playerid,const item[e_SHOP_ITEM])
{
    new line[160];

    if (item[E_SHOP_LEVEL] > 0 && Character_GetLevel(playerid) < item[E_SHOP_LEVEL])
    {
        format(line,sizeof(line),"You need to be level %d to buy a %s.",item[E_SHOP_LEVEL],item[E_SHOP_NOUN]);
        return Shop_Refuse(playerid,line);
    }

    return true;
}

stock bool:Shop_Buy(playerid,shop,index)
{
    new item[e_SHOP_ITEM];

    if (!Shop_GetItem(shop,index,item))
    {
        return false;
    }

    if (shop == SHOP_GUN && item[E_SHOP_KIND] == SHOP_KIND_WEAPON)
    {
        if (Inventory_GetEquipped(playerid) != EQUIP_NONE)
        {
            Shop_Refuse(playerid,"Please unequip the item you have equipped before buying a weapon.");
            return false;
        }

        if (Weapons_Get(playerid,E_GUN_SLOT_HAND) != 0)
        {
            Shop_Refuse(playerid,"You can't buy a weapon whilst you already have one equipped.");
            return false;
        }
    }

    new bool:go = false;

    switch (item[E_SHOP_KIND])
    {
        case SHOP_KIND_WEAPON:
        {
            go = Shop_BuyWeapon(playerid,item);
        }
        case SHOP_KIND_SMALL, SHOP_KIND_LARGE:
        {
            go = Shop_BuyBackpack(playerid,item);
        }
        default:
        {
            go = Shop_BuyItem(playerid,item);

            if (go)
            {
                if (Inventory_GiveByParam(playerid,item[E_SHOP_PARAM],item[E_SHOP_EXTRA],item[E_SHOP_AMOUNT],-1,-1,item[E_SHOP_PRICE]))
                {
                    if (shop == SHOP_GUN)
                    {
                        new name[ACCOUNT_NAME_LEN];
                        Account_GetRoleplayName(playerid,name);
                        Log_Info("guns/points","%s (%d) has bought a %s.",name,playerid,item[E_SHOP_NOUN]);
                    }

                    pawn_call_public("Shop_OnBought","dddd",playerid,shop,index,item[E_SHOP_EXTRA]);
                }
            }
        }
    }

    return go;
}

stock Shop_Open(playerid,shop,delay = 0)
{
    SetTimerEx("Shop_MenuDeferred",delay,false,"ddd",playerid,Account_GetToken(playerid),shop);
}

static Shop_Menu(playerid,shop)
{
    yield 1;

    if (s_ShopOpen[playerid])
    {
        return;
    }

    new title[24], token = Account_GetToken(playerid);
    Picker_Begin(playerid);

    for (new i = 0,count = Shop_GetCount(shop);i < count;i++)
    {
        new item[e_SHOP_ITEM], model = 0, caption[PICK_CAPTION_LEN];
        Shop_GetItem(shop,i,item);

        if (!Shop_GetPick(shop,i,model,caption))
        {
            strcopy(caption,item[E_SHOP_LABEL]);
        }

        if (model == 0)
        {
            model = Item_GetModel(Item_FindByParam(item[E_SHOP_PARAM],item[E_SHOP_EXTRA]));
        }

        Picker_Add(playerid,model,caption);
    }

    Shop_Title(shop,title);
    s_ShopOpen[playerid] = true;
    new response[DIALOG_RESPONSE];
    await_arr(response) Picker_Show(playerid,title,"Select","Cancel");

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    s_ShopOpen[playerid] = false;

    if (!response[DIALOG_RESPONSE_RESPONSE] || Point_FindInterior(playerid,SHOP_RANGE) == 0)
    {
        return;
    }

    if (Shop_Buy(playerid,shop,response[DIALOG_RESPONSE_LISTITEM]))
    {
        Shop_Open(playerid,shop,SHOP_RESHOW_MS);
    }
}

static Shop_SkinMenu(playerid)
{
    yield 1;

    if (s_ShopOpen[playerid])
    {
        return;
    }

    new ids[SHOP_MAX_LIST], count = 0, gender = Character_GetGender(playerid), origin = Character_GetOrigin(playerid), token = Account_GetToken(playerid);

    Picker_Begin(playerid);

    for (new i = 0,total = Shop_GetSkinCount();i < total && count < SHOP_MAX_LIST;i++)
    {
        new skin[e_SHOP_SKIN], caption[8];
        Shop_GetSkin(i,skin);

        if (skin[E_SHOP_SKIN_GENDER] == gender && skin[E_SHOP_SKIN_ETHNICITY] == origin)
        {
            ids[count++] = skin[E_SHOP_SKIN_ID];
            format(caption,sizeof(caption),"%d",i);
            Picker_Add(playerid,skin[E_SHOP_SKIN_ID],caption);
        }
    }

    if (count == 0)
    {
        SendServerMessage(playerid,"Error processing skin data. Please try again or call a developer.",MSG_TYPE_ERROR);
        return;
    }

    new response[DIALOG_RESPONSE];
    s_ShopOpen[playerid] = true;
    await_arr(response) Picker_Show(playerid,"Skin selection","Select","Cancel");

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    s_ShopOpen[playerid] = false;

    if (!response[DIALOG_RESPONSE_RESPONSE] || response[DIALOG_RESPONSE_LISTITEM] < 0 || response[DIALOG_RESPONSE_LISTITEM] >= count)
    {
        return;
    }

    if (!Money_CanAfford(playerid,SHOP_SKIN_PRICE))
    {
        SendServerMessage(playerid,"You don't have enough money. You need to pay $1.25 for a new skin.",MSG_TYPE_ERROR);
        return;
    }

    new skinid = ids[response[DIALOG_RESPONSE_LISTITEM]], line[96];
    Money_Take(playerid,SHOP_SKIN_PRICE);
    format(line,sizeof(line),"You've purchased skin ID %d for $1.25.",skinid);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Character_SetSkinCached(playerid,skinid);
    SetPlayerSkin(playerid,skinid);
    TogglePlayerControllable(playerid,true);
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_skin = %d WHERE character_id = %d",skinid,Character_GetId(playerid)));
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
CMD:buy(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new option[32];

    if (sscanf(params,"S()[32]",option))
    {
        option[0] = EOS;
    }

    new pointid = Point_FindInterior(playerid,SHOP_RANGE);

    if (pointid == 0)
    {
        return 1;
    }

    new point[e_POINT];
    Point_Get(pointid,point);

    if (point[E_POINT_TYPE] != POINT_TYPE_BIZ)
    {
        SendServerMessage(playerid,"You're not in a business. If you are and you get this message, it's not set up correctly. Get an admin.",MSG_TYPE_ERROR);
        return 1;
    }

    switch (point[E_POINT_BIZTYPE])
    {
        case POINT_BIZ_GENERAL:
        {
            Shop_Open(playerid,SHOP_GENERAL);
        }
        case POINT_BIZ_GUN:
        {
            if (Character_GetLevel(playerid) < SHOP_GUN_LEVEL)
            {
                SendServerMessage(playerid,"Your level must at least be 3.",MSG_TYPE_ERROR);
                return 1;
            }

            Shop_Open(playerid,SHOP_GUN);
        }
        case POINT_BIZ_CLOTHING:
        {
            if (isnull(option))
            {
                Shop_Open(playerid,SHOP_SKINS);
            }
            else if (!strcmp(option,"mask"))
            {
                if (Character_GetLevel(playerid) < SHOP_MASK_LEVEL)
                {
                    SendServerMessage(playerid,"You need to be level 10 to buy masks.",MSG_TYPE_ERROR);
                    return 1;
                }

                pawn_call_public("Shop_OnMask","dd",playerid,pointid);
            }
            else if (!strcmp(option,"attachments"))
            {
                pawn_call_public("Shop_OnToys","dd",playerid,pointid);
            }
            else if (!strcmp(option,"misc"))
            {
                Shop_Open(playerid,SHOP_MISC);
            }
            else
            {
                SendServerMessage(playerid,"You can't do this in a clothing score. Correct param for a clothing store is: /buy [optional: mask, attachments, misc]",MSG_TYPE_ERROR);
            }
        }
        case POINT_BIZ_BARBER:
        {
            SendServerMessage(playerid,"This entrance has no /buy scripted to it yet!",MSG_TYPE_ERROR);
        }
        case POINT_BIZ_LIQUOR, POINT_BIZ_SALOON:
        {
            Shop_Open(playerid,SHOP_LIQUOR);
        }
        case POINT_BIZ_HUNTING:
        {
            SendServerMessage(playerid,"You can sell meat through your inventory.",MSG_TYPE_ERROR);
            Shop_Open(playerid,SHOP_HUNTING);
        }
        case POINT_BIZ_BANK:
        {
            SendServerMessage(playerid,"You cannot buy anything here.",MSG_TYPE_ERROR);
        }
        case POINT_BIZ_POSTAL:
        {
            if (!strcmp(option,"lottery"))
            {
                pawn_call_public("Shop_OnLottery","dd",playerid,pointid);
            }
            else
            {
                SendServerMessage(playerid,"/buy does not work here, /ad does though.",MSG_TYPE_ERROR);
            }
        }
        case POINT_BIZ_SHERIFF:
        {
            SendServerMessage(playerid,"You can't buy anything here.",MSG_TYPE_ERROR);
        }
        case POINT_BIZ_BLACKSMITH:
        {
            Shop_Open(playerid,SHOP_BLACKSMITH);
        }
        case POINT_BIZ_STABLE:
        {
            pawn_call_public("Shop_OnStable","dd",playerid,pointid);
        }
    }

    return 1;
}

#include <pp-hooks>

hook OnPlayerConnect(playerid)
{
    s_ShopOpen[playerid] = false;
}

public Shop_MenuDeferred(playerid,token,shop)
{
    if (Account_IsCurrent(playerid,token))
    {
        if (shop == SHOP_SKINS)
        {
            Shop_SkinMenu(playerid);
        }
        else
        {
            Shop_Menu(playerid,shop);
        }
    }

    return 1;
}

public Shop_OnMask(playerid,pointid)
{
    return 1;
}

public Shop_OnToys(playerid,pointid)
{
    return 1;
}

public Shop_OnStable(playerid,pointid)
{
    return 1;
}

public Shop_OnLottery(playerid,pointid)
{
    return 1;
}

public Shop_OnBought(playerid,shop,index,item)
{
    return 1;
}
