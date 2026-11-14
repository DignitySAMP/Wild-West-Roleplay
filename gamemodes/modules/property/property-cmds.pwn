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
forward Point_FeeDeferred(playerid,token);

static Point_NotOwner(playerid,pointid)
{
    if (!Point_IsOwner(playerid,pointid))
    {
        SendServerMessage(playerid,"You don't own this property.",MSG_TYPE_ERROR);
        return false;
    }

    return true;
}

static Point_Buy(playerid)
{
    new pointid = Point_FindExterior(playerid,POINT_COMMAND_RANGE);

    if (pointid == 0)
    {
        return;
    }

    new point[e_POINT], line[160], text[MONEY_TEXT_LEN];
    Point_Get(pointid,point);

    if (point[E_POINT_OWNER] > 0)
    {
        SendServerMessage(playerid,"This entrance has already been purchased.",MSG_TYPE_ERROR);
        return;
    }

    if (point[E_POINT_TYPE] == POINT_TYPE_PASS)
    {
        SendServerMessage(playerid,"You can't purchase this point.",MSG_TYPE_ERROR);
        return;
    }

    new total = Point_GetOwned(playerid,point[E_POINT_TYPE]);

    if (total == 1)
    {
        total = 2;
    }

    if (Character_GetLevel(playerid) < total * 10)
    {
        format(line,sizeof(line),"You can't purchase another %s until level %d0.",point[E_POINT_TYPE] == POINT_TYPE_HOUSE ? ("house") : ("business"),total);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return;
    }

    new cost = Money_Make(point[E_POINT_PRICE]);

    if (point[E_POINT_PRICE] < 0 || !Money_CanAfford(playerid,cost))
    {
        SendServerMessage(playerid,"You don't have enough money to purchase this point.",MSG_TYPE_ERROR);
        return;
    }

    Money_Take(playerid,cost);
    Money_Delimit(point[E_POINT_PRICE],text);
    format(line,sizeof(line),"You've bought point (%d) %s for $%s",pointid,point[E_POINT_NAME],text);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Levels_GiveExperience(playerid,POINT_EXPERIENCE_BUY);
    point[E_POINT_OWNER] = Character_GetId(playerid);
    Point_Store(pointid,point);
    Point_Update(pointid,"point_owner",point[E_POINT_OWNER]);
}

static Point_Sell(playerid)
{
    new pointid = Point_FindExterior(playerid,POINT_COMMAND_RANGE);

    if (pointid == 0)
    {
        return;
    }

    if (!Point_NotOwner(playerid,pointid))
    {
        return;
    }

    new point[e_POINT], line[160], text[MONEY_TEXT_LEN];
    Point_Get(pointid,point);

    if (point[E_POINT_WEAPON1] != 0 || point[E_POINT_WEAPON2] != 0)
    {
        SendServerMessage(playerid,"Take the weapons out of your storage before selling this property.",MSG_TYPE_ERROR);
        return;
    }

    new refund = Money_Make(point[E_POINT_PRICE] / 2);
    Money_Delimit(point[E_POINT_PRICE] / 2,text);
    format(line,sizeof(line),"You've been given back $%s for selling the property.",text);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Money_Give(playerid,refund);
    new till = point[E_POINT_TILL] * 100 + point[E_POINT_TILL_CHANGE];

    if (till > 0)
    {
        Money_Give(playerid,till,E_MONEY_SLOT_BANK);
        Money_Format(till,text);
        format(line,sizeof(line),"The %s left in the till was deposited in your bank.",text);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
    }

    Point_Clear(pointid);
}

static Point_Lock(playerid)
{
    new pointid = Point_FindNear(playerid,POINT_COMMAND_RANGE);

    if (pointid == 0 || !Point_NotOwner(playerid,pointid))
    {
        return;
    }

    new point[e_POINT];
    Point_Get(pointid,point);

    if (point[E_POINT_LOCKED] == 0)
    {
        point[E_POINT_LOCKED] = 1;
        SendServerMessage(playerid,"You've locked the door of your entrance.",MSG_TYPE_INFO);
    }
    else
    {
        point[E_POINT_LOCKED] = 0;
        SendServerMessage(playerid,"You've unlocked the door of your entrance.",MSG_TYPE_INFO);
    }

    Point_Commit(pointid,point);
    Point_Update(pointid,"point_locked",point[E_POINT_LOCKED]);
}

static Point_SetFee(playerid)
{
    yield 1;

    new pointid = Point_FindNear(playerid,POINT_COMMAND_RANGE);

    if (pointid == 0 || !Point_NotOwner(playerid,pointid))
    {
        return;
    }

    new point[e_POINT];
    Point_Get(pointid,point);

    if (point[E_POINT_TYPE] != POINT_TYPE_BIZ)
    {
        SendServerMessage(playerid,"This point isn't a business.",MSG_TYPE_ERROR);
        return;
    }

    new token = Account_GetToken(playerid), response[DIALOG_RESPONSE];
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_INPUT,"Fee setup","Enter the amount you want to charge. (0-99 cents)","Continue","Exit");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE] || !Point_Get(pointid,point) || !Point_IsOwner(playerid,pointid))
    {
        return;
    }

    new fee = strval(response[DIALOG_RESPONSE_INPUTTEXT]), line[96];

    if (fee < 0 || fee > POINT_FEE_MAX)
    {
        SendServerMessage(playerid,"Entrance fee can't be less than 0 cents or more than 99 cents.",MSG_TYPE_ERROR);
        return;
    }

    point[E_POINT_FEE] = fee;
    Point_Store(pointid,point);
    Point_Update(pointid,"point_fee",fee);

    if (fee >= 1)
    {
        format(line,sizeof(line),"You've set this point's entrance fee to %d %s.",fee,fee == 1 ? ("cent") : ("cents"));
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
    }
    else
    {
        SendServerMessage(playerid,"You've removed this point's entrance fee.",MSG_TYPE_INFO);
    }
}

static Point_Collect(playerid)
{
    new pointid = Point_FindInterior(playerid,POINT_COMMAND_RANGE);

    if (pointid == 0)
    {
        SendServerMessage(playerid,"You're not near a point you own.",MSG_TYPE_ERROR);
        return;
    }

    new point[e_POINT];
    Point_Get(pointid,point);

    if (point[E_POINT_TYPE] != POINT_TYPE_BIZ)
    {
        SendServerMessage(playerid,"This point isn't a business.",MSG_TYPE_ERROR);
        return;
    }

    if (!Point_NotOwner(playerid,pointid))
    {
        return;
    }

    new cents = point[E_POINT_TILL] * 100 + point[E_POINT_TILL_CHANGE], line[128], text[MONEY_TEXT_LEN];
    Money_Delimit(point[E_POINT_TILL],text);
    format(line,sizeof(line),"You've recieved %s.%02d from your business till. It's been deposited in your bank.",text,point[E_POINT_TILL_CHANGE]);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Money_Give(playerid,cents,E_MONEY_SLOT_BANK);
    point[E_POINT_TILL] = 0;
    point[E_POINT_TILL_CHANGE] = 0;
    Point_Commit(pointid,point);
    mysql_tquery_s(g_Mysql,str_format("UPDATE points SET point_till = 0, point_till_change = 0 WHERE point_id = %d",pointid));
}

static Point_HouseStorage(playerid,&pointid,point[e_POINT])
{
    pointid = Point_FindInterior(playerid,POINT_COMMAND_RANGE);

    if (pointid == 0)
    {
        SendServerMessage(playerid,"You're not near a point you own.",MSG_TYPE_ERROR);
        return false;
    }

    Point_Get(pointid,point);

    if (!Point_NotOwner(playerid,pointid))
    {
        return false;
    }

    if (point[E_POINT_TYPE] != POINT_TYPE_HOUSE)
    {
        SendServerMessage(playerid,"This point isn't a house.",MSG_TYPE_ERROR);
        return false;
    }

    return true;
}

static Point_StoreMoney(playerid,amount)
{
    if (amount < 1)
    {
        SendServerMessage(playerid,"/point store money [amount] - amount can't be less than 1.",MSG_TYPE_ERROR);
        return;
    }

    new pointid, point[e_POINT], line[128], text[MONEY_TEXT_LEN];

    if (!Point_HouseStorage(playerid,pointid,point))
    {
        return;
    }

    Money_Delimit(amount,text);

    if (amount > MONEY_MAX_DOLLARS || !Money_CanAfford(playerid,Money_Make(amount)))
    {
        format(line,sizeof(line),"You don't have $%d to store in your house.",amount);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return;
    }

    Money_Take(playerid,Money_Make(amount));
    point[E_POINT_TILL] += amount;
    Point_Commit(pointid,point);
    Point_Update(pointid,"point_till",point[E_POINT_TILL]);
    new name[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,name);
    Log_Info("point/store","%s has stored $%s (%d) in their house. (point: %d)",name,text,amount,pointid);
    format(line,sizeof(line),"You've stored $%s in your house storage.",text);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
}

static Point_TakeMoney(playerid,amount)
{
    if (amount < 1)
    {
        SendServerMessage(playerid,"/point take money [amount] - amount can't be less than 1.",MSG_TYPE_ERROR);
        return;
    }

    new pointid, point[e_POINT], line[128], text[MONEY_TEXT_LEN];

    if (!Point_HouseStorage(playerid,pointid,point))
    {
        return;
    }

    Money_Delimit(amount,text);

    if (point[E_POINT_TILL] < amount)
    {
        format(line,sizeof(line),"You don't have $%d stored in your house.",amount);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return;
    }

    point[E_POINT_TILL] -= amount;
    Money_Give(playerid,Money_Make(amount));
    Point_Commit(pointid,point);
    Point_Update(pointid,"point_till",point[E_POINT_TILL]);
    new name[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,name);
    Log_Info("point/store","%s has taken $%s (%d) from their house. (point: %d)",name,text,amount,pointid);
    format(line,sizeof(line),"You've withdrew $%s from your house storage.",text);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
}

static Point_StoreWeapon(playerid,slot)
{
    new pointid, point[e_POINT];

    if (!Point_HouseStorage(playerid,pointid,point))
    {
        return;
    }

    if (slot < 1 || slot > 2)
    {
        SendServerMessage(playerid,"/point store weapon [slot] - slot can't be less than 1 or more than 2.",MSG_TYPE_ERROR);
        return;
    }

    new used = slot == 1 ? point[E_POINT_WEAPON1] : point[E_POINT_WEAPON2];

    if (used != 0)
    {
        SendServerMessage(playerid,"This slot already has a weapon stored.",MSG_TYPE_ERROR);
        return;
    }

    new weapon = Weapons_Get(playerid,E_GUN_SLOT_HAND), ammo = Weapons_GetAmmo(playerid,E_GUN_SLOT_HAND);

    if (weapon == 0)
    {
        SendServerMessage(playerid,"You're not wearing a weapon which can be stored.",MSG_TYPE_ERROR);
        return;
    }

    if (slot == 1)
    {
        point[E_POINT_WEAPON1] = weapon;
        point[E_POINT_WEAPON1_AMMO] = ammo;
    }
    else
    {
        point[E_POINT_WEAPON2] = weapon;
        point[E_POINT_WEAPON2_AMMO] = ammo;
    }

    Weapons_RemoveHand(playerid);
    Point_Commit(pointid,point);
    Point_UpdateOwnership(pointid);
}

static Point_TakeWeapon(playerid,slot)
{
    new pointid, point[e_POINT];

    if (!Point_HouseStorage(playerid,pointid,point))
    {
        return;
    }

    if (slot < 1 || slot > 2)
    {
        SendServerMessage(playerid,"/point store weapon [slot] - slot can't be less than 1 or more than 2.",MSG_TYPE_ERROR);
        return;
    }

    new weapon = slot == 1 ? point[E_POINT_WEAPON1] : point[E_POINT_WEAPON2], ammo = slot == 1 ? point[E_POINT_WEAPON1_AMMO] : point[E_POINT_WEAPON2_AMMO];

    if (weapon == 0)
    {
        SendServerMessage(playerid,"This slot does not have a weapon stored.",MSG_TYPE_ERROR);
        return;
    }

    if (Weapons_Get(playerid,E_GUN_SLOT_HAND) != 0)
    {
        SendServerMessage(playerid,"You're already holding a weapon. Holster it first.",MSG_TYPE_ERROR);
        return;
    }

    if (!Weapons_Give(playerid,weapon,ammo))
    {
        return;
    }

    if (slot == 1)
    {
        point[E_POINT_WEAPON1] = 0;
        point[E_POINT_WEAPON1_AMMO] = 0;
    }
    else
    {
        point[E_POINT_WEAPON2] = 0;
        point[E_POINT_WEAPON2_AMMO] = 0;
    }

    Point_Commit(pointid,point);
    Point_UpdateOwnership(pointid);
}

static Point_ShowStorage(playerid,bool:money)
{
    new pointid, point[e_POINT], line[128], text[MONEY_TEXT_LEN];

    if (!Point_HouseStorage(playerid,pointid,point))
    {
        return;
    }

    if (money)
    {
        Money_Delimit(point[E_POINT_TILL],text);
        format(line,sizeof(line),"You have $%s stored in your house.",text);
        SendServerMessage(playerid,line,MSG_TYPE_WARN);
        return;
    }

    new first[WEAPON_NAME_LEN], second[WEAPON_NAME_LEN];
    Weapon_GetName(point[E_POINT_WEAPON1],first);
    Weapon_GetName(point[E_POINT_WEAPON2],second);
    format(line,sizeof(line),"Point %d's weapons storage:",pointid);
    SendClientMessage(playerid,COLOR_TAB0,line);
    format(line,sizeof(line),"[SLOT 1]: %s (%d ammo)",first,point[E_POINT_WEAPON1_AMMO]);
    SendClientMessage(playerid,COLOR_TAB1,line);
    format(line,sizeof(line),"[SLOT 2]: %s (%d ammo)",second,point[E_POINT_WEAPON2_AMMO]);
    SendClientMessage(playerid,COLOR_TAB1,line);
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
public Point_FeeDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Point_SetFee(playerid);
    }

    return 1;
}

CMD:point(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new option[16], soption[32], amount;

    if (sscanf(params,"s[16]S()[32]I(0)",option,soption,amount))
    {
        SendServerMessage(playerid,"/point [buy, sell, lock, furni(ture), fee, collect, store, take, storage, sleep]",MSG_TYPE_INFO);
        return 1;
    }

    if (!strcmp(option,"buy"))
    {
        Point_Buy(playerid);
    }
    else if (!strcmp(option,"sell"))
    {
        Point_Sell(playerid);
    }
    else if (!strcmp(option,"lock"))
    {
        Point_Lock(playerid);
    }
    else if (!strcmp(option,"furniture",true) || !strcmp(option,"furni",true))
    {
        new pointid = Point_GetPlayerPoint(playerid);

        if (pointid == 0)
        {
            SendServerMessage(playerid,"You need to be inside a point.",MSG_TYPE_ERROR);
            return 1;
        }

        if (!Point_IsOwner(playerid,pointid))
        {
            SendServerMessage(playerid,"You don't own this property.",MSG_TYPE_ERROR);
            return 1;
        }

        new point[e_POINT];
        Point_Get(pointid,point);

        if (point[E_POINT_TYPE] != POINT_TYPE_HOUSE)
        {
            SendServerMessage(playerid,"You can only add furniture to houses.",MSG_TYPE_ERROR);
            return 1;
        }

        pawn_call_public("Point_OnFurniture","dd",playerid,pointid);
    }
    else if (!strcmp(option,"fee"))
    {
        SetTimerEx("Point_FeeDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
    }
    else if (!strcmp(option,"collect"))
    {
        Point_Collect(playerid);
    }
    else if (!strcmp(option,"store"))
    {
        if (isnull(soption))
        {
            SendServerMessage(playerid,"/point store [money/weapon]",MSG_TYPE_ERROR);
        }
        else if (!strcmp(soption,"money"))
        {
            Point_StoreMoney(playerid,amount);
        }
        else if (!strcmp(soption,"weapon"))
        {
            Point_StoreWeapon(playerid,amount);
        }
        else
        {
            SendServerMessage(playerid,"/point store [money/weapons] [amount]",MSG_TYPE_ERROR);
        }
    }
    else if (!strcmp(option,"take"))
    {
        if (isnull(soption))
        {
            SendServerMessage(playerid,"/point take [money/weapon]",MSG_TYPE_ERROR);
        }
        else if (!strcmp(soption,"money"))
        {
            Point_TakeMoney(playerid,amount);
        }
        else if (!strcmp(soption,"weapon"))
        {
            Point_TakeWeapon(playerid,amount);
        }
        else
        {
            SendServerMessage(playerid,"/point take [money/weapon] [amount]",MSG_TYPE_ERROR);
        }
    }
    else if (!strcmp(option,"storage"))
    {
        if (isnull(soption))
        {
            SendServerMessage(playerid,"/point storage [money/weapon]",MSG_TYPE_ERROR);
        }
        else if (!strcmp(soption,"money"))
        {
            Point_ShowStorage(playerid,true);
        }
        else if (!strcmp(soption,"weapon"))
        {
            Point_ShowStorage(playerid,false);
        }
        else
        {
            SendServerMessage(playerid,"/point storage [money/weapon]",MSG_TYPE_ERROR);
        }
    }
    else if (!strcmp(option,"sleep"))
    {
        Point_StartSleep(playerid);
    }
    else
    {
        SendServerMessage(playerid,"/point [buy, sell, lock, fee, collect, store, take, storage, sleep]",MSG_TYPE_INFO);
    }

    return 1;
}

CMD:mypoints(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    SendServerMessage(playerid,"Your owned points:",MSG_TYPE_WARN);
    new count = 0, character = Character_GetId(playerid);

    for (new Iter:it = Point_Iterator();iter_inside(it);iter_move_next(it))
    {
        new point[e_POINT], line[96];
        iter_get_arr(it,point);

        if (point[E_POINT_OWNER] == character)
        {
            count++;
            format(line,sizeof(line),"(%d) %s [DB: %d]",iter_get_key(it),point[E_POINT_NAME],iter_get_key(it));
            SendClientMessage(playerid,0xDEDEDEFF,line);
        }
    }

    if (count == 0)
    {
        SendServerMessage(playerid,"You have no points.",MSG_TYPE_ERROR);
    }

    return 1;
}

CMD:doorshout(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[144];

    if (sscanf(params,"s[144]",text))
    {
        SendServerMessage(playerid,"/doorshout [text]",MSG_TYPE_ERROR);
        return 1;
    }

    new pointid = Point_FindNear(playerid,POINT_COMMAND_RANGE);

    if (pointid == 0)
    {
        SendServerMessage(playerid,"You're not near a door.",MSG_TYPE_ERROR);
        return 1;
    }

    new point[e_POINT], line[220], name[ACCOUNT_NAME_LEN];
    Point_Get(pointid,point);
    Account_GetRoleplayName(playerid,name);

    foreach (new i : Player)
    {
        if (i == playerid)
        {
            continue;
        }

        if (GetPlayerVirtualWorld(i) == point[E_POINT_INT_VW] && GetPlayerInterior(i) == point[E_POINT_INT_INT] && IsPlayerInRangeOfPoint(i,POINT_COMMAND_RANGE,point[E_POINT_INT_X],point[E_POINT_INT_Y],point[E_POINT_INT_Z]))
        {
            format(line,sizeof(line),"%s shouts (door: outside): %s",name,text);
            SendClientMessage(i,COLOR_BLUE,line);
        }
        else if (GetPlayerVirtualWorld(i) == point[E_POINT_VW] && GetPlayerInterior(i) == point[E_POINT_INT] && IsPlayerInRangeOfPoint(i,POINT_COMMAND_RANGE,point[E_POINT_EXT_X],point[E_POINT_EXT_Y],point[E_POINT_EXT_Z]))
        {
            format(line,sizeof(line),"%s shouts (door: inside): %s",name,text);
            SendClientMessage(i,COLOR_BLUE,line);
        }
    }

    format(line,sizeof(line),"%s shouts (door): %s",name,text);
    ProxDetector(playerid,30.0,-1,line);
    return 1;
}

ALT:ds=CMD:doorshout;

CMD:license(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (Point_FindService(playerid,POINT_BIZ_POSTAL) == 0)
    {
        return 1;
    }

    if (Inventory_FindExtra(playerid,E_ITEM_EXTRA_CARD_PASSPORT) != INV_ROW_NONE)
    {
        SendServerMessage(playerid,"You already have a state passport.",MSG_TYPE_ERROR);
        return 1;
    }

    Inventory_GiveByParam(playerid,E_ITEM_PARAM_MISC,E_ITEM_EXTRA_CARD_PASSPORT,1,-1,-1,Money_Make(POINT_PASSPORT_PRICE));
    return 1;
}

CMD:givegunpermit(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_IsModerator(playerid))
    {
        SendServerMessage(playerid,"Nice try.",MSG_TYPE_INFO);
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/givegunpermit [target]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"Player isn't online!"))
    {
        return 1;
    }

    if (Inventory_FindExtra(target,E_ITEM_EXTRA_CARD_PASSPORT) == INV_ROW_NONE)
    {
        SendServerMessage(playerid,"Target doesn't have a passport.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Inventory_FindExtra(target,E_ITEM_EXTRA_CARD_GUNPERMIT) != INV_ROW_NONE)
    {
        SendServerMessage(playerid,"Target already has a weapon permit.",MSG_TYPE_ERROR);
        return 1;
    }

    SendServerMessage(playerid,"Mis use of this will result in a ban. ",MSG_TYPE_ERROR);
    Inventory_GiveByParam(target,E_ITEM_PARAM_MISC,E_ITEM_EXTRA_CARD_GUNPERMIT,1,-1,-1,0);
    SendServerMessage(playerid,"You've have given the goods.",MSG_TYPE_WARN);
    return 1;
}

CMD:givelicense(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_IsModerator(playerid))
    {
        SendServerMessage(playerid,"Nice try.",MSG_TYPE_INFO);
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/givelicense [target]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"Player isn't online!"))
    {
        return 1;
    }

    if (Inventory_FindExtra(target,E_ITEM_EXTRA_CARD_PASSPORT) != INV_ROW_NONE)
    {
        SendServerMessage(playerid,"Target already has a state passport.",MSG_TYPE_ERROR);
        return 1;
    }

    Inventory_GiveByParam(target,E_ITEM_PARAM_MISC,E_ITEM_EXTRA_CARD_PASSPORT,1,-1,-1,0);
    SendServerMessage(playerid,"You've have given the goods.",MSG_TYPE_WARN);
    return 1;
}
