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
forward Point_ClearDeferred(playerid,token);
forward Point_StaffDeferred(playerid,token,flow,arg);

enum _:E_POINT_FLOW
{
    POINT_FLOW_CREATE = 0,
    POINT_FLOW_OWNER,
    POINT_FLOW_INACTIVE,
    POINT_FLOW_CLEAR,
    POINT_FLOW_RELOAD,
}

static Point_Defer(playerid,flow,arg)
{
    SetTimerEx("Point_StaffDeferred",0,false,"dddd",playerid,Account_GetToken(playerid),flow,arg);
}

static Point_StaffName(playerid,dest[],size = sizeof(dest))
{
    GetPlayerName(playerid,dest,size);
}

static Point_Warn(playerid,level,const text[])
{
    new name[ACCOUNT_NAME_LEN], line[200];
    Point_StaffName(playerid,name);
    format(line,sizeof(line),"[STAFF] %s (%d) %s",name,playerid,text);
    SendModeratorWarning(line,level);
    Log_Info("mod/points","%s (%d) %s",name,playerid,text);
}

static bool:Point_RequireManager(playerid)
{
    if (!Staff_IsManager(playerid))
    {
        SendServerMessage(playerid,"Nope.",MSG_TYPE_ERROR);
        return false;
    }

    return true;
}

static bool:Point_RequireId(playerid,pointid,const usage[])
{
    if (pointid == -1)
    {
        SendServerMessage(playerid,usage,MSG_TYPE_ERROR);
        return false;
    }

    if (!Point_Exists(pointid))
    {
        SendServerMessage(playerid,"Invalid point ID. Please select a proper ID.",MSG_TYPE_ERROR);
        return false;
    }

    return true;
}

static Point_ListInactive(playerid,bool:clear)
{
    yield 1;

    new token = Account_GetToken(playerid);
    await mysql_aquery_s(g_Mysql,str_format("SELECT p.point_id, p.point_name, c.character_name, a.account_name FROM points p JOIN characters c ON c.character_id = p.point_owner JOIN master_accounts a ON a.account_id = c.account_id WHERE p.point_owner > 0 AND a.account_lastlogin < %d",gettime() - POINT_INACTIVE_SECONDS),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    new rows = cache_num_rows(), ids[64], count = 0;

    if (!clear)
    {
        SendClientMessage(playerid,COLOR_YELLOW,"Inactive points:");
    }

    for (new i = 0;i < rows;i++)
    {
        new id, name[POINT_NAME_LEN], owner[ACCOUNT_NAME_LEN], account[ACCOUNT_NAME_LEN], line[160];
        cache_get_value_name_int(i,"point_id",id);
        cache_get_value_name(i,"point_name",name);
        cache_get_value_name(i,"character_name",owner);
        cache_get_value_name(i,"account_name",account);

        if (clear)
        {
            if (count < sizeof(ids))
            {
                ids[count++] = id;
            }
        }
        else
        {
            format(line,sizeof(line),"[%d] %s - Owner: %s (%s)",id,name,owner,account);
            SendServerMessage(playerid,line,MSG_TYPE_INFO);
        }
    }

    new line[96];

    if (clear)
    {
        for (new i = 0;i < count;i++)
        {
            Point_Clear(ids[i]);
        }

        format(line,sizeof(line),"%d inactive points cleared.",count);
    }
    else
    {
        format(line,sizeof(line),"%d total inactive points.",rows);
    }

    SendServerMessage(playerid,line,MSG_TYPE_INFO);
}

static Point_ClearInactive(playerid)
{
    yield 1;

    new token = Account_GetToken(playerid), response[DIALOG_RESPONSE];
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"{C23030}WARNING","{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\nYou're about to clear all inactive points.\nIf you completely sure to clear all inactive points, press \"Proceed\".","{C23030}Proceed","Cancel");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
    {
        return;
    }

    SetTimerEx("Point_ClearDeferred",0,false,"dd",playerid,token);
}

public Point_StaffDeferred(playerid,token,flow,arg)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    switch (flow)
    {
        case POINT_FLOW_CREATE:
        {
            Point_Create_Run(playerid,arg);
        }
        case POINT_FLOW_OWNER:
        {
            Point_ShowOwner(playerid,arg);
        }
        case POINT_FLOW_INACTIVE:
        {
            Point_ListInactive(playerid,false);
        }
        case POINT_FLOW_CLEAR:
        {
            Point_ClearInactive(playerid);
        }
        case POINT_FLOW_RELOAD:
        {
            Point_ReloadRun(playerid);
        }
    }

    return 1;
}

public Point_ClearDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Point_ListInactive(playerid,true);
    }

    return 1;
}

static Point_ShowOwner(playerid,pointid)
{
    yield 1;

    new point[e_POINT], token = Account_GetToken(playerid);
    Point_Get(pointid,point);

    if (point[E_POINT_OWNER] <= 0)
    {
        SendServerMessage(playerid,"No players own a business.",MSG_TYPE_ERROR);
        return;
    }

    await mysql_aquery_s(g_Mysql,str_format("SELECT account_id, character_id, character_name FROM characters WHERE character_id = %d",point[E_POINT_OWNER]),false);

    if (!Account_IsCurrent(playerid,token) || cache_num_rows() < 1)
    {
        return;
    }

    new account, character, name[ACCOUNT_NAME_LEN], line[128];
    cache_get_value_name_int(0,"account_id",account);
    cache_get_value_name_int(0,"character_id",character);
    cache_get_value_name(0,"character_name",name);
    format(line,sizeof(line),"Point %d is owned by %s [char %d, ma %d ]",pointid,name,character,account);
    SendServerMessage(playerid,line,MSG_TYPE_WARN);
}

static Point_Create_Run(playerid,type)
{
    yield 1;

    new token = Account_GetToken(playerid), pointid = await Point_Create(playerid,type);

    if (!Account_IsCurrent(playerid,token) || pointid <= 0)
    {
        return;
    }

    new line[96];
    format(line,sizeof(line),"has created a point with ID %d and type %d.",pointid,type);
    Point_Warn(playerid,MOD_WARNING_LOW,line);
}

static Point_ReloadRun(playerid)
{
    yield 1;

    new token = Account_GetToken(playerid);
    await Point_Reload();

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    Point_Warn(playerid,MOD_WARNING_LOW,"reloaded all points.");
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
CMD:apoint(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    new option[32], setting, extra[32];

    if (sscanf(params,"s[32]I(-1)S()[32]",option,setting,extra))
    {
        SendServerMessage(playerid,"/apoint [param] [setting] [extra: optional]",MSG_TYPE_ERROR);
        SendServerMessage(playerid,"PARAMS: [info, create, delete, sell, int, move, name, type, price, biz, lock, goto, inactive, clearinactive, owner, fee]",MSG_TYPE_WARN);
        SendServerMessage(playerid,"To see what additional info, type /apoint info. It will show the biztypes and types.",MSG_TYPE_INFO);
        return 1;
    }

    new Float:x, Float:y, Float:z, line[200], point[e_POINT];
    GetPlayerPos(playerid,x,y,z);

    if (!strcmp(option,"info"))
    {
        SendServerMessage(playerid,"[Point Types]: 0: Passpoint, 1: House, 2: Business",MSG_TYPE_INFO);
        SendServerMessage(playerid,"[Biz Types]: 0: General store, 1: Gun store, 2: Clothing store, 3: Barber, 4: Liquor store, 5: Saloon 6: Hunting store",MSG_TYPE_INFO);
        SendServerMessage(playerid,"[Biz Types]: 7: Bank, 8: Postal Office, 9: Sheriff's Office, 10: Blacksmith, 11: Stablemaster",MSG_TYPE_INFO);
    }
    else if (!strcmp(option,"create"))
    {
        if (!Point_RequireManager(playerid))
        {
            return 1;
        }

        if (setting < 0 || setting > 2)
        {
            SendServerMessage(playerid,"Setting can't be lower than 0 or higher than 2.",MSG_TYPE_ERROR);
            return 1;
        }

        Point_Defer(playerid,POINT_FLOW_CREATE,setting);
    }
    else if (!strcmp(option,"int"))
    {
        if (!Point_RequireManager(playerid) || !Point_RequireId(playerid,setting,"/ap int [pointid]"))
        {
            return 1;
        }

        Point_Get(setting,point);
        point[E_POINT_INT_X] = x;
        point[E_POINT_INT_Y] = y;
        point[E_POINT_INT_Z] = z;
        mysql_tquery_s(g_Mysql,str_format("UPDATE points SET point_int_x = %f, point_int_y = %f, point_int_z = %f WHERE point_id = %d",x,y,z,setting));
        format(line,sizeof(line),"You've set point ID %d's interior position to yours.",setting);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        format(line,sizeof(line),"has updated point %d's interior to their location.",setting);
        Point_Warn(playerid,MOD_WARNING_LOW,line);

        if (point[E_POINT_TYPE] == POINT_TYPE_HOUSE || point[E_POINT_TYPE] == POINT_TYPE_BIZ)
        {
            point[E_POINT_INT_VW] = GetPlayerVirtualWorld(playerid) + 1 + setting;
            point[E_POINT_INT_INT] = GetPlayerInterior(playerid);
            mysql_tquery_s(g_Mysql,str_format("UPDATE points SET point_int_vw = %d, point_int_int = %d WHERE point_id = %d",point[E_POINT_INT_VW],point[E_POINT_INT_INT],setting));
            format(line,sizeof(line),"Based on the point's type, the interior and virtual world has been updated accordingly. (%d:%d)",point[E_POINT_INT_VW],point[E_POINT_INT_INT]);
            SendServerMessage(playerid,line,MSG_TYPE_INFO);
        }

        Point_Commit(setting,point);
    }
    else if (!strcmp(option,"move"))
    {
        if (!Point_RequireManager(playerid) || !Point_RequireId(playerid,setting,"/ap move [pointid]"))
        {
            return 1;
        }

        Point_Get(setting,point);
        point[E_POINT_EXT_X] = x;
        point[E_POINT_EXT_Y] = y;
        point[E_POINT_EXT_Z] = z;
        point[E_POINT_VW] = GetPlayerVirtualWorld(playerid);
        point[E_POINT_INT] = GetPlayerInterior(playerid);
        mysql_tquery_s(g_Mysql,str_format("UPDATE points SET point_ext_x = %f, point_ext_y = %f, point_ext_z = %f, point_vw = %d, point_int = %d WHERE point_id = %d",x,y,z,point[E_POINT_VW],point[E_POINT_INT],setting));
        format(line,sizeof(line),"You've moved point ID %d to your location.",setting);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        format(line,sizeof(line),"has moved point %d to their location.",setting);
        Point_Warn(playerid,MOD_WARNING_LOW,line);
        Point_Store(setting,point);
    }
    else if (!strcmp(option,"name"))
    {
        if (!Point_RequireId(playerid,setting,"/ap name [pointid]"))
        {
            return 1;
        }

        Point_Get(setting,point);
        strcopy(point[E_POINT_NAME],extra,POINT_NAME_LEN);
        mysql_tquery_s(g_Mysql,str_format("UPDATE points SET point_name = '%e' WHERE point_id = %d",point[E_POINT_NAME],setting));
        format(line,sizeof(line),"has renamed point ID %d to %s.",setting,point[E_POINT_NAME]);
        Point_Warn(playerid,MOD_WARNING_LOW,line);
        Point_Store(setting,point);
    }
    else if (!strcmp(option,"type"))
    {
        if (!Point_RequireManager(playerid) || !Point_RequireId(playerid,setting,"/ap type [pointid] [type]"))
        {
            return 1;
        }

        new type = strval(extra);

        if (type < 0 || type > 2)
        {
            SendServerMessage(playerid,"Type can't be less than 0 or higher than 2. Use /point biztype for biz types.",MSG_TYPE_ERROR);
            return 1;
        }

        Point_Get(setting,point);
        point[E_POINT_TYPE] = type;
        Point_Update(setting,"point_type",type);
        format(line,sizeof(line),"has changed point ID %d's type to %d.",setting,type);
        Point_Warn(playerid,MOD_WARNING_LOW,line);
        Point_Store(setting,point);
    }
    else if (!strcmp(option,"sell"))
    {
        if (!Point_RequireManager(playerid) || !Point_RequireId(playerid,setting,"/ap sell [pointid]"))
        {
            return 1;
        }

        Point_Clear(setting);
        format(line,sizeof(line),"sold point ID %d.",setting);
        Point_Warn(playerid,MOD_WARNING_HIGH,line);
    }
    else if (!strcmp(option,"price"))
    {
        if (!Point_RequireManager(playerid) || !Point_RequireId(playerid,setting,"/ap price [pointid] [price]"))
        {
            return 1;
        }

        new price = strval(extra);

        if (price < 0)
        {
            SendServerMessage(playerid,"The price can't be negative.",MSG_TYPE_ERROR);
            return 1;
        }

        Point_Get(setting,point);
        point[E_POINT_PRICE] = price;
        Point_Update(setting,"point_price",price);
        format(line,sizeof(line),"set point ID %d's price to %d.",setting,price);
        Point_Warn(playerid,MOD_WARNING_MED,line);
        Point_Store(setting,point);
    }
    else if (!strcmp(option,"biz"))
    {
        if (!Point_RequireManager(playerid) || !Point_RequireId(playerid,setting,"/ap biz [pointid] [biz-type]"))
        {
            return 1;
        }

        new biztype = strval(extra);

        if (biztype < 0 || biztype > POINT_BIZ_STABLE)
        {
            SendServerMessage(playerid,"Business type can't be less than 0 or higher than 11.",MSG_TYPE_ERROR);
            return 1;
        }

        Point_Get(setting,point);
        point[E_POINT_BIZTYPE] = biztype;
        Point_Update(setting,"point_biztype",biztype);
        format(line,sizeof(line),"set point ID %d's business type %d.",setting,biztype);
        Point_Warn(playerid,MOD_WARNING_LOW,line);
        Point_Store(setting,point);
    }
    else if (!strcmp(option,"delete"))
    {
        if (!Point_RequireManager(playerid) || !Point_RequireId(playerid,setting,"/ap delete [pointid]"))
        {
            return 1;
        }

        Point_Remove(setting);
        format(line,sizeof(line),"has deleted point ID %d.",setting);
        Point_Warn(playerid,MOD_WARNING_HIGH,line);
    }
    else if (!strcmp(option,"lock"))
    {
        if (!Point_RequireId(playerid,setting,"/ap lock [pointid]"))
        {
            return 1;
        }

        Point_Get(setting,point);

        if (point[E_POINT_LOCKED] == 0)
        {
            point[E_POINT_LOCKED] = 1;
            SendServerMessage(playerid,"You've locked the door of your entrance.",MSG_TYPE_INFO);
            format(line,sizeof(line),"has locked point ID %d.",setting);
        }
        else
        {
            point[E_POINT_LOCKED] = 0;
            SendServerMessage(playerid,"You've unlocked the door of your entrance.",MSG_TYPE_INFO);
            format(line,sizeof(line),"has unlocked point ID %d.",setting);
        }

        Point_Warn(playerid,MOD_WARNING_MED,line);
        Point_Commit(setting,point);
        Point_Update(setting,"point_locked",point[E_POINT_LOCKED]);
    }
    else if (!strcmp(option,"goto"))
    {
        if (!Point_RequireId(playerid,setting,"/ap goto [pointid]"))
        {
            return 1;
        }

        Point_Get(setting,point);
        SetPlayerPos(playerid,point[E_POINT_EXT_X],point[E_POINT_EXT_Y],point[E_POINT_EXT_Z]);
        SetPlayerInterior(playerid,point[E_POINT_INT]);
        SetPlayerVirtualWorld(playerid,point[E_POINT_VW]);
        Point_SetPlayerPoint(playerid,0);
        format(line,sizeof(line),"has teleported to point ID %d.",setting);
        Point_Warn(playerid,MOD_WARNING_LOW,line);
    }
    else if (!strcmp(option,"inactive"))
    {
        Point_Defer(playerid,POINT_FLOW_INACTIVE,0);
    }
    else if (!strcmp(option,"clearinactive"))
    {
        Point_Defer(playerid,POINT_FLOW_CLEAR,0);
    }
    else if (!strcmp(option,"owner"))
    {
        if (!Point_RequireId(playerid,setting,"/ap owner [pointid]"))
        {
            return 1;
        }

        Point_Defer(playerid,POINT_FLOW_OWNER,setting);
    }
    else if (!strcmp(option,"fee"))
    {
        if (!Point_RequireManager(playerid) || !Point_RequireId(playerid,setting,"/ap fee [pointid] [fee]"))
        {
            return 1;
        }

        new fee = strval(extra);

        if (fee < 0 || fee > POINT_FEE_MAX)
        {
            SendServerMessage(playerid,"Entrance fee can't be less than 0 cents or more than 99 cents.",MSG_TYPE_ERROR);
            return 1;
        }

        Point_Get(setting,point);
        point[E_POINT_FEE] = fee;
        Point_Update(setting,"point_fee",fee);
        format(line,sizeof(line),"set point ID %d's fee to %d.",setting,fee);
        Point_Warn(playerid,MOD_WARNING_MED,line);
        Point_Store(setting,point);
    }
    else
    {
        SendServerMessage(playerid,"/apoint [param] [setting] [extra: optional]",MSG_TYPE_ERROR);
        SendServerMessage(playerid,"PARAMS: [info, create, delete, sell, int, move, name, type, price, biz, lock, goto, inactive, clearinactive, owner, fee]",MSG_TYPE_WARN);
        SendServerMessage(playerid,"To see what additional info, type /apoint info. It will show the biztypes and types.",MSG_TYPE_INFO);
    }

    return 1;
}

ALT:ap=CMD:apoint;

CMD:reloadpoints(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    Point_Defer(playerid,POINT_FLOW_RELOAD,0);
    return 1;
}
