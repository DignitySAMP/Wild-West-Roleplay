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
#define USE_ANY (-1)
#define USE_HANDLER_LEN (32)

enum e_USE_HANDLER
{
    E_USE_TYPE,
    E_USE_EXTRA,
    E_USE_NAME[USE_HANDLER_LEN],
}

enum e_FOOD
{
    E_FOOD_EXTRA,
    E_FOOD_HUNGER,
    E_FOOD_THIRST,
    bool:E_FOOD_DRINK,
    E_FOOD_TEXT[40],
}

static List:s_UseHandlers;

static const s_FoodTable[][e_FOOD] =
{
    {E_ITEM_EXTRA_FOOD_WATER_FULL,0,20,true,"drinks a bottle of water"},
    {E_ITEM_EXTRA_FOOD_MILK_FULL,5,15,true,"drinks some milk"},
    {E_ITEM_EXTRA_FOOD_ORANGE,5,5,false,"eats an orange"},
    {E_ITEM_EXTRA_FOOD_APPLE_GREEN,5,5,false,"eats a green apple"},
    {E_ITEM_EXTRA_FOOD_APPLE_RED,5,5,false,"eats a red apple"},
    {E_ITEM_EXTRA_FOOD_TOMATO,5,0,false,"eats a tomato"},
    {E_ITEM_EXTRA_FOOD_CABBAGE,7,0,false,"eats some cabbage"},
    {E_ITEM_EXTRA_FOOD_BANANA,5,0,false,"eats a banana"},
    {E_ITEM_EXTRA_FOOD_BREAD,20,-5,false,"eats some bread"},
    {E_ITEM_EXTRA_FOOD_PUMPKIN,20,5,false,"eats a piece of pumpkin"},
    {E_ITEM_EXTRA_FOOD_MEAT,25,0,false,"eats some cooked meat"},
    {E_ITEM_EXTRA_FOOD_MEAT_LEG,25,0,false,"eats some cooked meat leg"},
    {E_ITEM_EXTRA_FOOD_COOKED_MEAT,25,0,false,"eats some cooked meat"},
    {E_ITEM_EXTRA_FOOD_COOKED_MEAT_LEG,25,0,false,"eats some cooked meat leg"},
    {E_ITEM_EXTRA_FOOD_CANNED_SALMON,15,5,false,"eats some canned salmon"},
    {E_ITEM_EXTRA_FOOD_CANNED_CORNED_BEEF,15,0,false,"eats some canned corned beef"},
    {E_ITEM_EXTRA_FOOD_CANNED_PINEAPPLES,10,5,false,"eats some canned pineapples"},
    {E_ITEM_EXTRA_FOOD_CANNED_STRAWBERRIES,10,5,false,"eats some canned strawberries"},
    {E_ITEM_EXTRA_FOOD_CANNED_KIDNEY_BEANS,15,0,false,"eats some canned kidney beans"},
    {E_ITEM_EXTRA_FOOD_CANNED_PEACHES,15,5,false,"eats some canned peaches"},
    {E_ITEM_EXTRA_FOOD_CANNED_SWEETCORN,10,5,false,"eats some canned sweetcorn"},
    {E_ITEM_EXTRA_FOOD_CANNED_BAKED_BEANS,15,0,false,"eats some baked beans"},
    {E_ITEM_EXTRA_FOOD_CANNED_APRICOTS,10,5,false,"eats some canned apricots"},
    {E_ITEM_EXTRA_FOOD_CANNED_PEAS,10,5,false,"eats some canned peas"}
};

forward Inventory_UseFood(playerid,uid,item,extra);
forward Inventory_UseInfo(playerid,uid,item,extra);

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
stock Inventory_RegisterUse(type,extra,const handler[])
{
    if (!list_valid(s_UseHandlers))
    {
        s_UseHandlers = list_new();
    }

    new entry[e_USE_HANDLER];
    entry[E_USE_TYPE] = type;
    entry[E_USE_EXTRA] = extra;
    strcopy(entry[E_USE_NAME],handler,USE_HANDLER_LEN);
    list_add_arr(s_UseHandlers,entry);
}

static stock bool:Use_Find(type,extra,dest[],size)
{
    if (!list_valid(s_UseHandlers))
    {
        return false;
    }

    new entry[e_USE_HANDLER], found = -1;

    for (new i = 0,count = list_size(s_UseHandlers);i < count;i++)
    {
        list_get_arr(s_UseHandlers,i,entry);

        if (entry[E_USE_TYPE] != type)
        {
            continue;
        }

        if (entry[E_USE_EXTRA] == extra)
        {
            strcopy(dest,entry[E_USE_NAME],size);
            return true;
        }

        if (entry[E_USE_EXTRA] == USE_ANY && found == -1)
        {
            found = i;
        }
    }

    if (found == -1)
    {
        return false;
    }

    list_get_arr(s_UseHandlers,found,entry);
    strcopy(dest,entry[E_USE_NAME],size);
    return true;
}

stock bool:Inventory_Use(playerid,index)
{
    new row[e_INV_ROW];

    if (!Player_IsReady(playerid) || !Inventory_GetRow(playerid,index,row))
    {
        return false;
    }

    new item = row[E_INV_ROW_ITEM];

    if (!Item_IsEnabled(item))
    {
        SendServerMessage(playerid,"This item serves either no function, or it isn't enabled.",MSG_TYPE_ERROR);
        return false;
    }

    new type = Item_GetType(item), extra = Item_GetExtra(item), handler[USE_HANDLER_LEN];

    if (type == E_ITEM_TYPE_UNDEFINED)
    {
        SendServerMessage(playerid,"This item has no use!",MSG_TYPE_ERROR);
        return false;
    }

    if (!Use_Find(type,extra,handler,sizeof(handler)))
    {
        SendServerMessage(playerid,"This item can't be used yet.",MSG_TYPE_ERROR);
        return false;
    }

    if (!pawn_call_public(handler,"dddd",playerid,row[E_INV_ROW_UID],item,extra))
    {
        SendServerMessage(playerid,"This item can't be used yet.",MSG_TYPE_ERROR);
        return false;
    }

    return true;
}

static stock Use_Say(playerid,const text[])
{
    new line[160], name[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,name);
    format(line,sizeof(line),"* %s %s.",name,text);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
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
forward bool:Injury_IsBleeding(playerid);
forward bool:Horse_OfferApple(playerid,uid,item,extra);

public Inventory_UseFood(playerid,uid,item,extra)
{
    new index = Inventory_IndexOfUid(playerid,uid);

    if ((extra == E_ITEM_EXTRA_FOOD_APPLE_RED || extra == E_ITEM_EXTRA_FOOD_APPLE_GREEN) && Horse_OfferApple(playerid,uid,item,extra))
    {
        return 1;
    }

    if (Injury_IsBleeding(playerid))
    {
        SendServerMessage(playerid,"You cannot eat or drink whilst bleeding.",MSG_TYPE_ERROR);
        return 1;
    }

    if (index == INV_ROW_NONE)
    {
        return 1;
    }

    if (!Needs_IsLoaded(playerid))
    {
        SendServerMessage(playerid,"You can't eat or drink right now.",MSG_TYPE_ERROR);
        return 1;
    }

    for (new i = 0;i < sizeof(s_FoodTable);i++)
    {
        if (s_FoodTable[i][E_FOOD_EXTRA] != extra)
        {
            continue;
        }

        Needs_Give(playerid,s_FoodTable[i][E_FOOD_HUNGER],s_FoodTable[i][E_FOOD_THIRST]);

        if (s_FoodTable[i][E_FOOD_DRINK])
        {
            ApplyAnimation(playerid,"SMOKING","M_smk_drag",4.1,false,false,false,false,0,SYNC_ALL);
        }
        else
        {
            ApplyAnimation(playerid,"FOOD","EAT_Burger",4.1,false,false,false,false,0,SYNC_ALL);
        }

        Use_Say(playerid,s_FoodTable[i][E_FOOD_TEXT]);
        Inventory_Decrease(playerid,index,1);
        return 1;
    }

    new line[96];
    format(line,sizeof(line),"Something went wrong, please send this to a developer. [Error: ID %d array]",item);
    SendServerMessage(playerid,line,MSG_TYPE_ERROR);
    return 1;
}

public Inventory_UseInfo(playerid,uid,item,extra)
{
    SendServerMessage(playerid,"These items automatically help keep you warm in cold regions but heat you up in warmer regions.",MSG_TYPE_INFO);
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
    Inventory_RegisterUse(E_ITEM_TYPE_FOOD,USE_ANY,"Inventory_UseFood");
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_GLOVES,"Inventory_UseInfo");
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_LONG_JOHNS,"Inventory_UseInfo");
}
