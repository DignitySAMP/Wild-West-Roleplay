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
forward Campfire_CreateDeferred(playerid,token);
forward Campfire_FuelDeferred(playerid,token);
forward Cooking_PromptDeferred(playerid,token,uid);

enum
{
    COOKING_FIXED_LOCATIONS = 2
}

static const Float:s_CookingLocations[COOKING_FIXED_LOCATIONS][3] =
{
    {-835.8579,1624.4568,27.0458},
    {-814.7105,1514.9229,20.5856}
};

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
static Campfire_Animate(playerid)
{
    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.1,false,false,false,false,0,SYNC_ALL);
}

static bool:Campfire_CanLight(playerid)
{
    if (Campfire_Has(playerid))
    {
        SendServerMessage(playerid,"You've already got a campfire made.",MSG_TYPE_ERROR);
        return false;
    }

    if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
    {
        SendServerMessage(playerid,"You can only light a campfire outside.",MSG_TYPE_ERROR);
        return false;
    }

    if (Horse_IsRiding(playerid))
    {
        SendServerMessage(playerid,"You can't light a campfire while you're riding.",MSG_TYPE_ERROR);
        return false;
    }

    return true;
}

public Campfire_CreateDeferred(playerid,token)
{
    Campfire_CreateFlow(playerid,token);
    return 1;
}

static Campfire_CreateFlow(playerid,token)
{
    yield 1;
    new response[DIALOG_RESPONSE];
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"Campfire Creation - Choose Log to Start Fire","Birch Log\nOak Log","Select","Exit");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE] || !Campfire_CanLight(playerid))
    {
        return;
    }

    new extra = E_ITEM_EXTRA_LUMBER_BIRCH_LOG, minutes = CAMPFIRE_BIRCH_MINUTES, line[96];

    if (response[DIALOG_RESPONSE_LISTITEM] != 0)
    {
        extra = E_ITEM_EXTRA_LUMBER_OAK_LOG;
        minutes = CAMPFIRE_OAK_MINUTES;
    }

    new index = Inventory_FindExtra(playerid,extra);

    if (index == INV_ROW_NONE)
    {
        SendServerMessage(playerid,extra == E_ITEM_EXTRA_LUMBER_BIRCH_LOG ? ("You don't have any birch logs to start a fire.") : ("You don't have any oak logs to start a fire."),MSG_TYPE_ERROR);
        return;
    }

    Campfire_Light(playerid,minutes);
    Inventory_Decrease(playerid,index,1,false);
    Campfire_Animate(playerid);
    format(line,sizeof(line),"You've created a campfire.  It will remain lit for %d minutes unless you add more fuel.",minutes);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
}

public Campfire_FuelDeferred(playerid,token)
{
    Campfire_FuelFlow(playerid,token);
    return 1;
}

static Campfire_FuelFlow(playerid,token)
{
    yield 1;
    new stage[CAMPFIRE_STAGE_LEN], title[96];
    Campfire_GetStage(Campfire_GetMinutes(playerid),stage);
    format(title,sizeof(title),"Campfire Current Status: %s - Select Log Type",stage);
    new response[DIALOG_RESPONSE];
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,title,"Birch - 5 minutes\nOak - 7 minutes\nYew - 10 minutes","Select","Exit");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE] || !Campfire_Has(playerid))
    {
        return;
    }

    if (!Campfire_InRange(playerid,playerid,CAMPFIRE_RANGE))
    {
        SendServerMessage(playerid,"You need to be near your campfire to add fuel.",MSG_TYPE_ERROR);
        return;
    }

    new extra, minutes, name[8], line[64];

    switch (response[DIALOG_RESPONSE_LISTITEM])
    {
        case 0:
        {
            extra = E_ITEM_EXTRA_LUMBER_BIRCH_LOG;
            minutes = CAMPFIRE_BIRCH_MINUTES;
            name = "birch";
        }
        case 1:
        {
            extra = E_ITEM_EXTRA_LUMBER_OAK_LOG;
            minutes = CAMPFIRE_OAK_MINUTES;
            name = "oak";
        }
        default:
        {
            extra = E_ITEM_EXTRA_LUMBER_YEW_LOG;
            minutes = CAMPFIRE_YEW_MINUTES;
            name = "yew";
        }
    }

    new index = Inventory_FindExtra(playerid,extra);

    if (index == INV_ROW_NONE)
    {
        format(line,sizeof(line),"You don't have any %s logs.",name);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return;
    }

    Campfire_AddMinutes(playerid,minutes);
    Inventory_Decrease(playerid,index,1,false);
    Campfire_Animate(playerid);
    format(line,sizeof(line),"You've added %d more minutes to the fire.",minutes);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
}

CMD:campfire(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new option[16];

    if (sscanf(params,"s[16]",option))
    {
        SendServerMessage(playerid,"/campfire [info,create,addfuel,destroy]",MSG_TYPE_INFO);
        return 1;
    }

    if (!strcmp(option,"info",true))
    {
        new owner = Campfire_Nearest(playerid);

        if (owner == CAMPFIRE_NONE)
        {
            SendServerMessage(playerid,"You are not near a campfire.",MSG_TYPE_ERROR);
            return 1;
        }

        new stage[CAMPFIRE_STAGE_LEN], line[96];
        Campfire_GetStage(Campfire_GetMinutes(owner),stage);
        format(line,sizeof(line),"{d18214}[CAMPFIRE]{FFFFFF}: %s",stage);
        SendClientMessage(playerid,-1,line);
        return 1;
    }

    if (!strcmp(option,"create",true))
    {
        if (Campfire_CanLight(playerid))
        {
            SetTimerEx("Campfire_CreateDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
        }

        return 1;
    }

    if (!strcmp(option,"addfuel",true))
    {
        if (!Campfire_Has(playerid))
        {
            SendServerMessage(playerid,"You don't have a campfire.",MSG_TYPE_ERROR);
            return 1;
        }

        if (!Campfire_InRange(playerid,playerid,CAMPFIRE_RANGE))
        {
            SendServerMessage(playerid,"You need to be near your campfire to add fuel.",MSG_TYPE_ERROR);
            return 1;
        }

        SetTimerEx("Campfire_FuelDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
        return 1;
    }

    if (!strcmp(option,"destroy",true))
    {
        if (!Campfire_Has(playerid))
        {
            SendServerMessage(playerid,"You already don't have a campfire.",MSG_TYPE_ERROR);
            return 1;
        }

        if (!Campfire_InRange(playerid,playerid,CAMPFIRE_RANGE))
        {
            SendServerMessage(playerid,"You need to be near your campfire to put it out.",MSG_TYPE_ERROR);
            return 1;
        }

        Campfire_Remove(playerid);
        Campfire_Animate(playerid);
        SendServerMessage(playerid,"You've put out the campfire.",MSG_TYPE_INFO);
        return 1;
    }

    SendServerMessage(playerid,"/campfire [info,create,addfuel,destroy]",MSG_TYPE_INFO);
    return 1;
}

stock bool:Cooking_IsNear(playerid)
{
    for (new i = 0;i < COOKING_FIXED_LOCATIONS;i++)
    {
        if (IsPlayerInRangeOfPoint(playerid,CAMPFIRE_COOK_RANGE,s_CookingLocations[i][0],s_CookingLocations[i][1],s_CookingLocations[i][2]))
        {
            return true;
        }
    }

    return Campfire_Nearest(playerid,CAMPFIRE_COOK_RANGE) != CAMPFIRE_NONE;
}

stock Cooking_GetLocation(index,&Float:x,&Float:y,&Float:z)
{
    if (index < 0 || index >= COOKING_FIXED_LOCATIONS)
    {
        return false;
    }

    x = s_CookingLocations[index][0];
    y = s_CookingLocations[index][1];
    z = s_CookingLocations[index][2];
    return true;
}

stock Cooking_Locations()
{
    return COOKING_FIXED_LOCATIONS;
}

static bool:Cooking_IsNumber(const text[])
{
    if (text[0] == EOS)
    {
        return false;
    }

    for (new i = 0;text[i] != EOS;i++)
    {
        if (text[i] < '0' || text[i] > '9')
        {
            return false;
        }
    }

    return true;
}

public Cooking_PromptDeferred(playerid,token,uid)
{
    Cooking_PromptFlow(playerid,token,uid);
    return 1;
}

static Cooking_PromptFlow(playerid,token,uid)
{
    yield 1;
    new index = Inventory_IndexOfUid(playerid,uid), row[e_INV_ROW];

    if (index == INV_ROW_NONE || !Inventory_GetRow(playerid,index,row))
    {
        return;
    }

    new extra = Item_GetExtra(row[E_INV_ROW_ITEM]), notice[160], body[256], response[DIALOG_RESPONSE];
    notice[0] = EOS;

    for (;;)
    {
        format(body,sizeof(body),"%s{FFFFFF}Please enter amount you wish to cook. (Max: %d)",notice,row[E_INV_ROW_AMOUNT]);
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_INPUT,"Cooking Location",body,"Cook","Exit");

        if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
        {
            return;
        }

        new amount = 0;
        notice[0] = EOS;

        if (!Cooking_IsNumber(response[DIALOG_RESPONSE_INPUTTEXT]))
        {
            strcopy(notice,"{CF4040}Amount needs to be a number.{FFFFFF}\n\n");
        }
        else if ((amount = strval(response[DIALOG_RESPONSE_INPUTTEXT])) <= 0)
        {
            strcopy(notice,"{CF4040}Amount needs to be a positive number or more than 0.{FFFFFF}\n\n");
        }
        else if (amount > row[E_INV_ROW_AMOUNT])
        {
            strcopy(notice,"{CF4040}You do not have that much of this meat, refer to max amount.{FFFFFF}\n\n");
        }

        if (notice[0] != EOS)
        {
            continue;
        }

        index = Inventory_IndexOfUid(playerid,uid);

        if (index == INV_ROW_NONE)
        {
            return;
        }

        new cooked = extra == E_ITEM_EXTRA_WILDLIFE_MEAT ? E_ITEM_EXTRA_FOOD_COOKED_MEAT : E_ITEM_EXTRA_FOOD_COOKED_MEAT_LEG;

        if (Inventory_GiveByParam(playerid,E_ITEM_PARAM_HUNGER,cooked,amount))
        {
            Inventory_Decrease(playerid,index,amount,false);
            format(body,sizeof(body),extra == E_ITEM_EXTRA_WILDLIFE_MEAT ? ("You've cooked %d pieces of meat.") : ("You've cooked %d pieces of meat leg."),amount);
            SendServerMessage(playerid,body,MSG_TYPE_INFO);
        }

        return;
    }
}
