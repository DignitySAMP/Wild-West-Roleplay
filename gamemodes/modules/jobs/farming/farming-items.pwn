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
static Farming_Say(playerid,const text[])
{
    SendServerMessage(playerid,text,MSG_TYPE_INFO);
}

public Farming_UseSoilBag(playerid,uid,item,extra)
{
    new index = Inventory_IndexOfUid(playerid,uid);

    if (index == INV_ROW_NONE)
    {
        return 1;
    }

    if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
    {
        SendServerMessage(playerid,"You can only plant soil outside!",MSG_TYPE_ERROR);
        return 1;
    }

    if (Player_IsBusyWith(playerid,E_PLAYER_BUSY_HORSE))
    {
        SendServerMessage(playerid,"You cannot plant soil while riding a horse!",MSG_TYPE_INFO);
        return 1;
    }

    new Float:x, Float:y, Float:z, Float:hx, Float:hy, Float:hz, Float:rx = 0.0, Float:ry = 0.0, Float:rz = 0.0;
    GetPlayerPos(playerid,x,y,z);

    if (CA_RayCastLineAngle(x,y,z,x,y,z - 5.0,hx,hy,hz,rx,ry,rz))
    {
        x = hx;
        y = hy;
        z = hz;
    }
    else
    {
        z -= 1.0;
        rx = 0.0;
        ry = 0.0;
        rz = 0.0;
    }

    new soil[e_SOIL];
    soil[E_SOIL_OWNER] = Character_GetId(playerid);
    soil[E_SOIL_PLANT] = SOIL_PLANT_NONE;
    soil[E_SOIL_X] = x;
    soil[E_SOIL_Y] = y;
    soil[E_SOIL_Z] = z;
    soil[E_SOIL_RX] = rx;
    soil[E_SOIL_RY] = ry;
    soil[E_SOIL_RZ] = rz;
    soil[E_SOIL_STATE] = SOIL_STATE_EMPTY;
    soil[E_SOIL_WATER] = SOIL_WATER_DEHYDRATED;
    soil[E_SOIL_HEALTH] = SOIL_HEALTH_DEAD;
    g_SoilPending[playerid] = soil;
    Inventory_Decrease(playerid,index,1);
    mysql_tquery_s(g_Mysql,str_format("INSERT INTO soildata (soil_owner, soil_plant, soil_x, soil_y, soil_z, soil_rotx, soil_roty, soil_rotz, soil_state, soil_water, soil_health, s_ticks, finished_growing) VALUES (%d, -1, %f, %f, %f, %f, %f, %f, 0, 0, 0, 0, 0)",soil[E_SOIL_OWNER],x,y,z,rx,ry,rz),"Farming_OnInserted","dd",playerid,Account_GetToken(playerid));
    Farming_Say(playerid,"You have dug up some soil. You can now make a hole and plant seeds in it!");
    Farming_Say(playerid,"If the farming soil seems to be bugged (underground / labels disappearing) please use /fixsoil and /refreshsoil.");
    #pragma unused item,extra
    return 1;
}

public Farming_OnInserted(playerid,token)
{
    new id = cache_insert_id();

    if (id < 1)
    {
        return 1;
    }

    new soil[e_SOIL];
    soil = g_SoilPending[playerid];
    Soil_Register(id,soil);
    #pragma unused token
    return 1;
}

public Farming_UseShovel(playerid,uid,item,extra)
{
    new id = Soil_FindNear(playerid,SOIL_RANGE), soil[e_SOIL];

    if (id == SOIL_NONE || !Soil_Get(id,soil))
    {
        SendServerMessage(playerid,"You aren't near any plants.",MSG_TYPE_ERROR);
        return 1;
    }

    switch (soil[E_SOIL_STATE])
    {
        case SOIL_STATE_EMPTY:
        {
            soil[E_SOIL_STATE] = SOIL_STATE_DIGGED;
            Soil_Put(id,soil);
            Soil_Refresh(id);
            Farming_Say(playerid,"You have dug a hole in the soil.");
        }
        case SOIL_STATE_DIGGED:
        {
            SendServerMessage(playerid,"You can't use the shovel right now!",MSG_TYPE_ERROR);
        }
        case SOIL_STATE_SEEDED:
        {
            Farming_Say(playerid,"You have covered the soil!");
            Soil_StartGrowing(id);
        }
        default:
        {
            SendServerMessage(playerid,"You can't use this right now!",MSG_TYPE_ERROR);
        }
    }

    #pragma unused uid,item,extra
    return 1;
}

public Farming_UsePail(playerid,uid,item,extra)
{
    new index = Inventory_IndexOfUid(playerid,uid), id = Soil_FindNear(playerid,SOIL_RANGE), soil[e_SOIL];

    if (index == INV_ROW_NONE)
    {
        return 1;
    }

    if (id == SOIL_NONE || !Soil_Get(id,soil))
    {
        SendServerMessage(playerid,"You aren't near any plants.",MSG_TYPE_ERROR);
        return 1;
    }

    if (soil[E_SOIL_WATER] == SOIL_WATER_WATERED)
    {
        SendServerMessage(playerid,"This plant doesn't need watering!",MSG_TYPE_ERROR);
        return 1;
    }

    if (soil[E_SOIL_HEALTH] == SOIL_HEALTH_DEAD && soil[E_SOIL_STATE] == SOIL_STATE_GROWING)
    {
        SendServerMessage(playerid,"You can't use this right now!",MSG_TYPE_ERROR);
        return 1;
    }

    soil[E_SOIL_WATER] = SOIL_WATER_WATERED;
    soil[E_SOIL_HEALTH] = SOIL_HEALTH_HEALTHY;
    Soil_Put(id,soil);
    Soil_Refresh(id);
    Farming_Say(playerid,"You have watered this plant.");
    Inventory_Decrease(playerid,index,1,false);
    Inventory_GiveByParam(playerid,E_ITEM_PARAM_FARMING,E_ITEM_EXTRA_FARMING_EMPTY_PAIL,1);
    pawn_call_public("Farming_OnWatered","dd",playerid,id);
    #pragma unused item,extra
    return 1;
}

public Farming_UseEmptyPail(playerid,uid,item,extra)
{
    new index = Inventory_IndexOfUid(playerid,uid);

    if (index == INV_ROW_NONE)
    {
        return 1;
    }

    if (!Fishing_NearWater(playerid))
    {
        SendServerMessage(playerid,"You aren't near any water!",MSG_TYPE_ERROR);
        return 1;
    }

    Inventory_Decrease(playerid,index,1,false);
    Inventory_GiveByParam(playerid,E_ITEM_PARAM_FARMING,E_ITEM_EXTRA_FARMING_PAIL,1);
    Farming_Say(playerid,"You have filled up your pail with water.");
    #pragma unused item,extra
    return 1;
}

public Farming_UseBasket(playerid,uid,item,extra)
{
    new index = Inventory_IndexOfUid(playerid,uid), id = Soil_FindNear(playerid,SOIL_RANGE), soil[e_SOIL];

    if (index == INV_ROW_NONE)
    {
        return 1;
    }

    if (id == SOIL_NONE || !Soil_Get(id,soil))
    {
        SendServerMessage(playerid,"You aren't near any plants.",MSG_TYPE_ERROR);
        return 1;
    }

    if (soil[E_SOIL_STATE] != SOIL_STATE_GROWN)
    {
        return 1;
    }

    if (soil[E_SOIL_OWNER] != Character_GetId(playerid))
    {
        SendServerMessage(playerid,"You don't own this soil.",MSG_TYPE_ERROR);
        return 1;
    }

    new basket = Soil_BasketFor(soil[E_SOIL_PLANT]);

    if (basket == -1)
    {
        return 1;
    }

    Inventory_Decrease(playerid,index,1,false);
    Inventory_GiveByParam(playerid,E_ITEM_PARAM_FARMING,basket,1);
    pawn_call_public("Farming_OnHarvested","ddd",playerid,id,soil[E_SOIL_PLANT]);
    Soil_ResetToHole(id);
    #pragma unused item,extra
    return 1;
}

public Farming_UseSeed(playerid,uid,item,extra)
{
    new index = Inventory_IndexOfUid(playerid,uid), id = Soil_FindNear(playerid,SOIL_RANGE), soil[e_SOIL], name[32], line[64];

    if (index == INV_ROW_NONE)
    {
        return 1;
    }

    if (id == SOIL_NONE || !Soil_Get(id,soil))
    {
        SendServerMessage(playerid,"You aren't near any plants.",MSG_TYPE_ERROR);
        return 1;
    }

    if (soil[E_SOIL_OWNER] != Character_GetId(playerid))
    {
        SendServerMessage(playerid,"You don't own this soil.",MSG_TYPE_ERROR);
        return 1;
    }

    if (soil[E_SOIL_STATE] != SOIL_STATE_DIGGED)
    {
        SendServerMessage(playerid,"You can't plant a seed on this soil right now!",MSG_TYPE_ERROR);
        return 1;
    }

    new plant = Soil_PlantFromSeed(extra);

    if (plant == SOIL_PLANT_NONE)
    {
        return 1;
    }

    Inventory_Decrease(playerid,index,1,false);
    soil[E_SOIL_STATE] = SOIL_STATE_SEEDED;
    soil[E_SOIL_PLANT] = plant;
    Soil_Put(id,soil);
    Soil_Refresh(id);
    Soil_PlantName(plant,false,name);
    format(line,sizeof(line),"You have planted a %s seed!",name);
    Farming_Say(playerid,line);
    pawn_call_public("Farming_OnPlanted","ddd",playerid,id,plant);
    #pragma unused item
    return 1;
}

public Farming_OnPlanted(playerid,id,plant)
{
    return 1;
}

public Farming_OnHarvested(playerid,id,plant)
{
    return 1;
}

public Farming_OnWatered(playerid,id)
{
    return 1;
}

static Farming_OwnerLine(playerid,id,bool:full)
{
    mysql_tquery_s(g_Mysql,str_format("SELECT characters.character_name, master_accounts.account_name FROM characters JOIN master_accounts ON master_accounts.account_id = characters.account_id JOIN soildata ON soildata.soil_owner = characters.character_id WHERE soildata.soil_id = %d",id),full ? "Farming_OnAllOwners" : "Farming_OnOwner","dd",playerid,id);
}

public Farming_OnOwner(playerid,id)
{
    new soil[e_SOIL], owner[ACCOUNT_NAME_LEN], account[ACCOUNT_NAME_LEN], line[128];

    if (cache_num_rows() == 0 || !Soil_Get(id,soil))
    {
        return 1;
    }

    cache_get_value_name(0,"character_name",owner);
    cache_get_value_name(0,"account_name",account);
    format(line,sizeof(line),"Soil ID: %d",id);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"Soil Plant: %d",soil[E_SOIL_PLANT]);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"Soil Owner: %s (%s)",owner,account);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"Soil Pos: %02f, %02f, %02f",soil[E_SOIL_X],soil[E_SOIL_Y],soil[E_SOIL_Z]);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
}

public Farming_OnAllOwners(playerid,id)
{
    new owner[ACCOUNT_NAME_LEN], account[ACCOUNT_NAME_LEN], line[128];

    if (cache_num_rows() == 0)
    {
        return 1;
    }

    cache_get_value_name(0,"character_name",owner);
    cache_get_value_name(0,"account_name",account);
    format(line,sizeof(line),"Soil ID: %d | Owner: %s (%s)",id,owner,account);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
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
CMD:refreshsoil(cmdid,playerid,params[])
{
    #pragma unused cmdid,params
    new id = Soil_FindNear(playerid,SOIL_OWN_RANGE,Character_GetId(playerid));

    if (id != SOIL_NONE)
    {
        Soil_Refresh(id);
        Farming_Say(playerid,"You have refreshed one of your soils nearby.");
    }

    return 1;
}

CMD:fixsoil(cmdid,playerid,params[])
{
    #pragma unused cmdid,params
    new id = Soil_FindNear(playerid,SOIL_OWN_RANGE,Character_GetId(playerid)), soil[e_SOIL];

    if (id == SOIL_NONE || !Soil_Get(id,soil))
    {
        return 1;
    }

    if (soil[E_SOIL_LIFTED])
    {
        SendServerMessage(playerid,"This soil has already been fixed.",MSG_TYPE_ERROR);
        return 1;
    }

    soil[E_SOIL_LIFTED] = true;
    soil[E_SOIL_Z] += 1.0;
    Soil_Put(id,soil);
    Soil_Rebuild(id);
    Farming_Say(playerid,"Applied fix.");
    return 1;
}

CMD:asoil(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid))
    {
        return 1;
    }

    new choice[12], id;

    if (sscanf(params,"s[12]D(-2)",choice,id))
    {
        SendServerMessage(playerid,"/asoil [info/remove/removeall/allsoils] [soil_id (defaults to nearest trap within range)]",MSG_TYPE_ERROR);
        return 1;
    }

    if (id == -2)
    {
        id = Soil_FindNear(playerid,SOIL_STAFF_RANGE);
    }

    if (!strcmp(choice,"info",true))
    {
        new soil[e_SOIL];

        if (id < 1 || !Soil_Get(id,soil))
        {
            SendServerMessage(playerid,"Invalid soil id.",MSG_TYPE_ERROR);
            return 1;
        }

        Farming_OwnerLine(playerid,id,false);
    }
    else if (!strcmp(choice,"remove",true))
    {
        new line[48];

        if (id < 1 || !Soil_Remove(id))
        {
            SendServerMessage(playerid,"Invalid soil id.",MSG_TYPE_ERROR);
            return 1;
        }

        format(line,sizeof(line),"Soil ID %d deleted.",id);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
    }
    else if (!strcmp(choice,"removeall",true))
    {
        Soil_RemoveAll();
        SendServerMessage(playerid,"All soils have been deleted.",MSG_TYPE_INFO);
    }
    else if (!strcmp(choice,"allsoils",true))
    {
        if (map_valid(g_Soils))
        {
            for (new Iter:it = map_iter(g_Soils);iter_inside(it);iter_move_next(it))
            {
                Farming_OwnerLine(playerid,iter_get_key(it),true);
            }
        }
    }
    else
    {
        SendServerMessage(playerid,"/asoil [info/remove/removeall/allsoils] [soil_id (defaults to nearest trap within range)]",MSG_TYPE_ERROR);
    }

    return 1;
}
