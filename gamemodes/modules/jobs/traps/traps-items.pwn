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
static Trap_Owns(playerid,const trap[e_TRAP])
{
    return trap[E_TRAP_OWNER] == Character_GetId(playerid);
}

static Trap_Act(playerid,const text[])
{
    new rp[ACCOUNT_NAME_LEN], line[128];
    Account_GetRoleplayName(playerid,rp);
    format(line,sizeof(line),text,rp);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
}

public Traps_UseTrap(playerid,uid,item,extra)
{
    new index = Inventory_IndexOfUid(playerid,uid);

    if (index == INV_ROW_NONE)
    {
        return 1;
    }

    if (Trap_Count() >= TRAP_LIMIT)
    {
        SendServerMessage(playerid,"Max traps reached.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Trap_IsCaught(playerid))
    {
        SendServerMessage(playerid,"You can't create a trap while you're trapped!",MSG_TYPE_ERROR);
        return 1;
    }

    if (Point_FindNear(playerid,TRAP_POINT_RANGE) != 0)
    {
        SendServerMessage(playerid,"You cannot place a trap here.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Zone_IsSafe(Zone_OfPlayer(playerid)))
    {
        SendServerMessage(playerid,"You cannot place a trap in a safezone.",MSG_TYPE_ERROR);
        return 1;
    }

    new Float:x, Float:y, Float:z, Float:hx, Float:hy, Float:hz, Float:rx = 0.0, Float:ry = 0.0, Float:rz = 0.0, trap[e_TRAP];
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
    }

    trap[E_TRAP_TYPE] = 0;
    trap[E_TRAP_OWNER] = Character_GetId(playerid);
    trap[E_TRAP_DEPLOYED] = true;
    trap[E_TRAP_BAIT] = 0;
    trap[E_TRAP_X] = x;
    trap[E_TRAP_Y] = y;
    trap[E_TRAP_Z] = z;
    trap[E_TRAP_RX] = rx;
    trap[E_TRAP_RY] = ry;
    trap[E_TRAP_RZ] = rz;
    trap[E_TRAP_OWNER_PLAYER] = playerid;
    g_TrapPending[playerid] = trap;
    Inventory_Decrease(playerid,index,1,false);
    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.1,false,false,false,false,0,SYNC_ALL);
    Trap_Act(playerid,"* %s has placed down a trap.");
    SendServerMessage(playerid,"You've placed down your trap, use /trap to arm it.",MSG_TYPE_INFO);
    mysql_tquery_s(g_Mysql,str_format("INSERT INTO traps (trap_constant, trap_owner, trap_deployed_state, trap_bait, trap_pos_x, trap_pos_y, trap_pos_z, trap_rot_x, trap_rot_y, trap_rot_z) VALUES (0, %d, 1, 0, %f, %f, %f, %f, %f, %f)",trap[E_TRAP_OWNER],x,y,z,rx,ry,rz),"Traps_OnInserted","dd",playerid,Account_GetToken(playerid));
    #pragma unused item,extra
    return 1;
}

public Traps_OnInserted(playerid,token)
{
    new id = cache_insert_id();

    if (id < 1)
    {
        return 1;
    }

    new trap[e_TRAP];
    trap = g_TrapPending[playerid];
    Trap_Register(id,trap);
    #pragma unused token
    return 1;
}

public Traps_UseBait(playerid,uid,item,extra)
{
    new index = Inventory_IndexOfUid(playerid,uid), id = Trap_FindNear(playerid,TRAP_RANGE), trap[e_TRAP];

    if (index == INV_ROW_NONE)
    {
        return 1;
    }

    if (id == TRAP_NONE || !Trap_Get(id,trap))
    {
        SendServerMessage(playerid,"You're not near a trap.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Trap_Owns(playerid,trap))
    {
        SendServerMessage(playerid,"You don't own this trap.",MSG_TYPE_ERROR);
        return 1;
    }

    if (trap[E_TRAP_BAIT] != 0)
    {
        SendServerMessage(playerid,"The trap already has bait on it.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Trap_IsArmed(trap) || trap[E_TRAP_PENDING] == TRAP_PENDING_ARM)
    {
        SendServerMessage(playerid,"You need to disarm this trap before applying bait.",MSG_TYPE_ERROR);
        return 1;
    }

    trap[E_TRAP_BAIT] = 1;
    Trap_Put(id,trap);
    Trap_Save(id);
    Inventory_Decrease(playerid,index,1,false);
    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.1,false,false,false,false,0,SYNC_ALL);
    Trap_Act(playerid,"* %s applies bait to their trap.");
    #pragma unused item,extra
    return 1;
}

static Trap_Arm(playerid,id,const trap[e_TRAP])
{
    new copy[e_TRAP];
    copy = trap;

    if (!Trap_Owns(playerid,copy))
    {
        SendServerMessage(playerid,"You cannot arm traps you don't own.",MSG_TYPE_ERROR);
        return;
    }

    if (!copy[E_TRAP_DEPLOYED] || copy[E_TRAP_PENDING] == TRAP_PENDING_ARM)
    {
        SendServerMessage(playerid,"Your trap is already armed.",MSG_TYPE_ERROR);
        return;
    }

    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.1,false,false,false,false,0,SYNC_ALL);
    Trap_Act(playerid,"* %s is arming their trap.");
    SendServerMessage(playerid,"Your trap will activate soon, please get away from it!",MSG_TYPE_INFO);
    copy[E_TRAP_PENDING] = TRAP_PENDING_ARM;
    copy[E_TRAP_DUE] = GetTickCount() + TRAP_ARM_MS;
    copy[E_TRAP_OWNER_PLAYER] = playerid;
    Trap_Put(id,copy);
}

static Trap_Disarm(playerid,id,const trap[e_TRAP])
{
    new copy[e_TRAP];
    copy = trap;

    if (!Trap_Owns(playerid,copy))
    {
        SendServerMessage(playerid,"You cannot disarm traps you don't own.",MSG_TYPE_ERROR);
        return;
    }

    if (copy[E_TRAP_DEPLOYED] || copy[E_TRAP_PENDING] == TRAP_PENDING_DISARM)
    {
        SendServerMessage(playerid,"This trap is already disarmed.",MSG_TYPE_ERROR);
        return;
    }

    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.1,false,false,false,false,0,SYNC_ALL);
    Trap_Act(playerid,"* %s is disarming their trap.");
    copy[E_TRAP_PENDING] = TRAP_PENDING_DISARM;
    copy[E_TRAP_DUE] = GetTickCount() + TRAP_DISARM_MS;
    copy[E_TRAP_OWNER_PLAYER] = playerid;
    Trap_Put(id,copy);
}

static Trap_Pickup(playerid,id,const trap[e_TRAP])
{
    if (!Trap_Owns(playerid,trap))
    {
        SendServerMessage(playerid,"You cannot pick up traps you don't own.",MSG_TYPE_ERROR);
        return;
    }

    if (!trap[E_TRAP_DEPLOYED] || trap[E_TRAP_PENDING] != TRAP_PENDING_NONE)
    {
        SendServerMessage(playerid,"You need to disarm the trap before picking it up.",MSG_TYPE_ERROR);
        return;
    }

    new needed = trap[E_TRAP_BAIT] != 0 ? 2 : 1;

    if (Inventory_GetCount(playerid) + needed > Inventory_GetCapacity(playerid))
    {
        SendServerMessage(playerid,"You don't have enough backpack size to pick this trap up.",MSG_TYPE_ERROR);
        return;
    }

    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.1,false,false,false,false,0,SYNC_ALL);
    Trap_Act(playerid,"* %s picks up their trap.");
    Inventory_GiveByParam(playerid,E_ITEM_PARAM_HUNTING,E_ITEM_EXTRA_HUNTING_TRAP,1);

    if (trap[E_TRAP_BAIT] != 0)
    {
        Inventory_GiveByParam(playerid,E_ITEM_PARAM_HUNTING,E_ITEM_EXTRA_HUNTING_BAIT,1);
    }

    Trap_Remove(id);
}

static Trap_Examine(playerid)
{
    new Float:px, Float:py, Float:pz, Float:angle, count = 0, seen[64], seenCount = 0;
    GetPlayerPos(playerid,px,py,pz);
    GetPlayerFacingAngle(playerid,angle);

    for (new step = 10;step >= 1;step--)
    {
        new Float:x = px + (float(step) * floatsin(-angle,degrees)), Float:y = py + (float(step) * floatcos(-angle,degrees));

        if (!map_valid(g_Traps))
        {
            break;
        }

        for (new Iter:it = map_iter(g_Traps);iter_inside(it);iter_move_next(it))
        {
            new trap[e_TRAP], id = iter_get_key(it), bool:known = false;
            iter_get_arr(it,trap);

            for (new i = 0;i < seenCount;i++)
            {
                if (seen[i] == id)
                {
                    known = true;
                }
            }

            if (known || floatabs(x - trap[E_TRAP_X]) > 5.0 || floatabs(y - trap[E_TRAP_Y]) > 5.0 || seenCount >= sizeof(seen))
            {
                continue;
            }

            new line[64], Float:dx = trap[E_TRAP_X] - px, Float:dy = trap[E_TRAP_Y] - py, Float:dz = trap[E_TRAP_Z] - pz;
            format(line,sizeof(line),"You can see a trap %.0fm away.",floatsqroot((dx * dx) + (dy * dy) + (dz * dz)));
            SendServerMessage(playerid,line,MSG_TYPE_INFO);
            seen[seenCount++] = id;
            count++;
        }
    }

    if (count == 0)
    {
        SendServerMessage(playerid,"You failed to spot any traps ahead.",MSG_TYPE_INFO);
    }
}

static Trap_NearestCaught(playerid,Float:range)
{
    new best = INVALID_PLAYER_ID, Float:bestDistance = range * range, Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid,px,py,pz);

    for (new other = 0;other < MAX_PLAYERS;other++)
    {
        if (other == playerid || !IsPlayerConnected(other) || !Trap_IsCaught(other))
        {
            continue;
        }

        new Float:x, Float:y, Float:z;
        GetPlayerPos(other,x,y,z);
        new Float:distance = ((x - px) * (x - px)) + ((y - py) * (y - py)) + ((z - pz) * (z - pz));

        if (distance <= bestDistance)
        {
            bestDistance = distance;
            best = other;
        }
    }

    return best;
}

static Trap_OwnerLine(playerid,id,bool:full)
{
    mysql_tquery_s(g_Mysql,str_format("SELECT characters.character_name, master_accounts.account_name FROM characters JOIN master_accounts ON master_accounts.account_id = characters.account_id JOIN traps ON traps.trap_owner = characters.character_id WHERE traps.trap_id = %d",id),full ? "Traps_OnAllOwners" : "Traps_OnOwner","dd",playerid,id);
}

public Traps_OnOwner(playerid,id)
{
    new trap[e_TRAP], owner[ACCOUNT_NAME_LEN], account[ACCOUNT_NAME_LEN], line[128];

    if (cache_num_rows() == 0 || !Trap_Get(id,trap))
    {
        return 1;
    }

    cache_get_value_name(0,"character_name",owner);
    cache_get_value_name(0,"account_name",account);
    format(line,sizeof(line),"Trap ID: %d",id);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"Trap Type: %d",trap[E_TRAP_TYPE]);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"Trap Owner: %s (%s)",owner,account);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"Trap Deployed: %s",trap[E_TRAP_DEPLOYED] ? ("True") : ("False"));
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"Trap Pos: %02f, %02f, %02f",trap[E_TRAP_X],trap[E_TRAP_Y],trap[E_TRAP_Z]);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
}

public Traps_OnAllOwners(playerid,id)
{
    new owner[ACCOUNT_NAME_LEN], account[ACCOUNT_NAME_LEN], line[128];

    if (cache_num_rows() == 0)
    {
        return 1;
    }

    cache_get_value_name(0,"character_name",owner);
    cache_get_value_name(0,"account_name",account);
    format(line,sizeof(line),"Trap ID: %d | Owner: %s (%s)",id,owner,account);
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
CMD:trap(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new choice[16];

    if (sscanf(params,"s[16]",choice))
    {
        SendServerMessage(playerid,"/trap [arm/disarm/examine/releasetrapped/pickup]",MSG_TYPE_INFO);
        return 1;
    }

    new id = TRAP_NONE, trap[e_TRAP];

    if (!strcmp(choice,"arm",true) || !strcmp(choice,"disarm",true) || !strcmp(choice,"pickup",true))
    {
        id = Trap_FindNear(playerid,TRAP_RANGE);

        if (id == TRAP_NONE || !Trap_Get(id,trap))
        {
            SendServerMessage(playerid,"You're not near a trap.",MSG_TYPE_ERROR);
            return 1;
        }
    }

    if (!strcmp(choice,"arm",true))
    {
        Trap_Arm(playerid,id,trap);
    }
    else if (!strcmp(choice,"disarm",true))
    {
        Trap_Disarm(playerid,id,trap);
    }
    else if (!strcmp(choice,"examine",true))
    {
        Trap_Examine(playerid);
    }
    else if (!strcmp(choice,"releasetrapped",true))
    {
        new target = Trap_NearestCaught(playerid,TRAP_RELEASE_RANGE);

        if (target == INVALID_PLAYER_ID)
        {
            SendServerMessage(playerid,"There's no one to release around you.",MSG_TYPE_ERROR);
            return 1;
        }

        Trap_Release(target,playerid,false);
    }
    else if (!strcmp(choice,"pickup",true))
    {
        Trap_Pickup(playerid,id,trap);
    }
    else
    {
        SendServerMessage(playerid,"/trap [arm/disarm/examine/releasetrapped/pickup]",MSG_TYPE_INFO);
    }

    return 1;
}

CMD:atrap(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid))
    {
        return 1;
    }

    new choice[12], id;

    if (sscanf(params,"s[12]D(-2)",choice,id))
    {
        SendServerMessage(playerid,"/atrap [info/remove/removeall/refreshall/alltraps] [trap_id (defaults to nearest trap within range)]",MSG_TYPE_ERROR);
        return 1;
    }

    if (id == -2)
    {
        id = Trap_FindNear(playerid,TRAP_STAFF_RANGE);
    }

    new trap[e_TRAP];

    if (!strcmp(choice,"info",true))
    {
        if (id < 1 || !Trap_Get(id,trap))
        {
            SendServerMessage(playerid,"Invalid trap id.",MSG_TYPE_ERROR);
            return 1;
        }

        Trap_OwnerLine(playerid,id,false);
    }
    else if (!strcmp(choice,"remove",true))
    {
        new line[48];

        if (id < 1 || !Trap_Remove(id))
        {
            SendServerMessage(playerid,"Invalid trap id.",MSG_TYPE_ERROR);
            return 1;
        }

        format(line,sizeof(line),"Trap ID %d deleted.",id);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
    }
    else if (!strcmp(choice,"removeall",true))
    {
        Trap_RemoveAll();
        SendServerMessage(playerid,"All traps have been deleted.",MSG_TYPE_INFO);
    }
    else if (!strcmp(choice,"refreshall",true))
    {
        Trap_RemoveAllMemory();
        SetTimerEx("Traps_ReloadDeferred",0,false,"d",playerid);
        SendServerMessage(playerid,"All traps refreshed.",MSG_TYPE_INFO);
    }
    else if (!strcmp(choice,"alltraps",true))
    {
        if (map_valid(g_Traps))
        {
            for (new Iter:it = map_iter(g_Traps);iter_inside(it);iter_move_next(it))
            {
                Trap_OwnerLine(playerid,iter_get_key(it),true);
            }
        }
    }
    else
    {
        SendServerMessage(playerid,"/atrap [info/remove/removeall/refreshall/alltraps] [trap_id (defaults to nearest trap within range)]",MSG_TYPE_ERROR);
    }

    return 1;
}
