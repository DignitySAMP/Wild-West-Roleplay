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
#define TRAP_LIMIT (50)
#define TRAP_RANGE (2.5)
#define TRAP_STAFF_RANGE (3.0)
#define TRAP_AREA_SIZE (1.6)
#define TRAP_ARM_MS (7500)
#define TRAP_DISARM_MS (2500)
#define TRAP_RELEASE_MS (300000)
#define TRAP_ANIMAL_BOX (3.0)
#define TRAP_POINT_RANGE (4.5)
#define TRAP_RELEASE_RANGE (10.0)
#define TRAP_NONE (-1)
#define TRAP_TICK_MS (500)

enum _:E_TRAP_PENDINGS
{
    TRAP_PENDING_NONE = 0,
    TRAP_PENDING_ARM,
    TRAP_PENDING_DISARM
}

enum e_TRAP
{
    E_TRAP_TYPE,
    E_TRAP_OWNER,
    bool:E_TRAP_DEPLOYED,
    E_TRAP_BAIT,
    Float:E_TRAP_X,
    Float:E_TRAP_Y,
    Float:E_TRAP_Z,
    Float:E_TRAP_RX,
    Float:E_TRAP_RY,
    Float:E_TRAP_RZ,
    E_TRAP_OBJECT,
    E_TRAP_AREA,
    E_TRAP_PENDING,
    E_TRAP_DUE,
    E_TRAP_OWNER_PLAYER
}

new Map:g_Traps;
new Map:g_TrapAreas;
new g_TrapCaught[MAX_PLAYERS] = {TRAP_NONE,...};
new g_TrapReleaseDue[MAX_PLAYERS];
new g_TrapPending[MAX_PLAYERS][e_TRAP];

forward Traps_OnInserted(playerid,token);
forward Traps_OnOwner(playerid,id);
forward Traps_OnAllOwners(playerid,id);
forward Traps_OnSprung(trapid,playerid);
forward Traps_OnReleased(playerid,helper);
forward Traps_OnAnimalCaught(trapid,animal);

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
stock Trap_Count()
{
    return map_valid(g_Traps) ? map_size(g_Traps) : 0;
}

stock bool:Trap_Get(id,trap[e_TRAP])
{
    if (!map_valid(g_Traps) || !map_has_key(g_Traps,id))
    {
        return false;
    }

    map_get_arr(g_Traps,id,trap);
    return true;
}

stock Trap_Put(id,const trap[e_TRAP])
{
    map_set_arr(g_Traps,id,trap);
}

stock Trap_Save(id)
{
    new trap[e_TRAP];

    if (Trap_Get(id,trap))
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE traps SET trap_deployed_state = %d, trap_bait = %d WHERE trap_id = %d",trap[E_TRAP_DEPLOYED] ? 1 : 0,trap[E_TRAP_BAIT],id));
    }
}

stock bool:Trap_IsArmed(const trap[e_TRAP])
{
    return !trap[E_TRAP_DEPLOYED];
}

stock Trap_Register(id,trap[e_TRAP])
{
    if (!map_valid(g_Traps))
    {
        g_Traps = map_new();
        g_TrapAreas = map_new();
    }

    trap[E_TRAP_OBJECT] = _:CreateDynamicObject(TRAP_FOOTLOCK,trap[E_TRAP_X],trap[E_TRAP_Y],trap[E_TRAP_Z] + 0.2,trap[E_TRAP_RX],trap[E_TRAP_RY],trap[E_TRAP_RZ]);
    trap[E_TRAP_AREA] = _:CreateDynamicCircle(trap[E_TRAP_X],trap[E_TRAP_Y],TRAP_AREA_SIZE);
    trap[E_TRAP_PENDING] = TRAP_PENDING_NONE;
    trap[E_TRAP_DUE] = 0;
    map_add_arr(g_Traps,id,trap);
    map_add(g_TrapAreas,trap[E_TRAP_AREA],id);
}

stock Trap_Remove(id)
{
    new trap[e_TRAP];

    if (!Trap_Get(id,trap))
    {
        return false;
    }

    mysql_tquery_s(g_Mysql,str_format("DELETE FROM traps WHERE trap_id = %d",id));
    map_remove(g_TrapAreas,trap[E_TRAP_AREA]);
    DestroyDynamicArea(STREAMER_TAG_AREA:trap[E_TRAP_AREA]);
    DestroyDynamicObject(STREAMER_TAG_OBJECT:trap[E_TRAP_OBJECT]);
    map_remove(g_Traps,id);

    for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
    {
        if (g_TrapCaught[playerid] == id)
        {
            g_TrapCaught[playerid] = TRAP_NONE;
        }
    }

    return true;
}

stock Trap_RemoveAllMemory()
{
    if (!map_valid(g_Traps))
    {
        return;
    }

    for (new Iter:it = map_iter(g_Traps);iter_inside(it);iter_move_next(it))
    {
        new trap[e_TRAP];
        iter_get_arr(it,trap);
        DestroyDynamicArea(STREAMER_TAG_AREA:trap[E_TRAP_AREA]);
        DestroyDynamicObject(STREAMER_TAG_OBJECT:trap[E_TRAP_OBJECT]);
    }

    map_clear(g_Traps);
    map_clear(g_TrapAreas);
}

stock Trap_RemoveAll()
{
    new ids[64], count = 0;

    if (!map_valid(g_Traps))
    {
        return 0;
    }

    for (new Iter:it = map_iter(g_Traps);iter_inside(it) && count < sizeof(ids);iter_move_next(it))
    {
        ids[count++] = iter_get_key(it);
    }

    for (new i = 0;i < count;i++)
    {
        Trap_Remove(ids[i]);
    }

    return count;
}

stock Trap_FindNear(playerid,Float:range)
{
    new best = TRAP_NONE, Float:bestDistance = range * range, Float:px, Float:py, Float:pz;

    if (!map_valid(g_Traps))
    {
        return TRAP_NONE;
    }

    GetPlayerPos(playerid,px,py,pz);

    for (new Iter:it = map_iter(g_Traps);iter_inside(it);iter_move_next(it))
    {
        new trap[e_TRAP];
        iter_get_arr(it,trap);
        new Float:dx = trap[E_TRAP_X] - px, Float:dy = trap[E_TRAP_Y] - py, Float:dz = trap[E_TRAP_Z] - pz, Float:distance = (dx * dx) + (dy * dy) + (dz * dz);

        if (distance <= bestDistance)
        {
            bestDistance = distance;
            best = iter_get_key(it);
        }
    }

    return best;
}

stock bool:Trap_IsCaught(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && g_TrapCaught[playerid] != TRAP_NONE;
}

stock Trap_GetCaught(playerid)
{
    return g_TrapCaught[playerid];
}

stock Trap_GetReleaseDue(playerid)
{
    return g_TrapReleaseDue[playerid];
}

static Trap_Name(playerid,dest[],size = sizeof(dest))
{
    Account_GetRoleplayName(playerid,dest,size);
}

stock Trap_Release(playerid,helper = INVALID_PLAYER_ID,bool:removeTrap = false)
{
    new id = g_TrapCaught[playerid], name[ACCOUNT_NAME_LEN], line[128];

    if (id == TRAP_NONE)
    {
        return false;
    }

    g_TrapCaught[playerid] = TRAP_NONE;
    g_TrapReleaseDue[playerid] = 0;
    Player_SetBusy(playerid,E_PLAYER_BUSY_TRAPPED,false);
    Injury_StartBleeding(playerid);
    Injury_DamageLegs(playerid);

    if (Injury_GetMode(playerid) == INJURY_MODE_NORMAL)
    {
        TogglePlayerControllable(playerid,true);
        ClearAnimations(playerid,SYNC_ALL);
    }

    if (helper == INVALID_PLAYER_ID)
    {
        SendServerMessage(playerid,"You've managed to release the trap.",MSG_TYPE_INFO);
        Trap_Name(playerid,name);
        format(line,sizeof(line),"* %s releases the trap.",name);
        ProxDetector(playerid,20.0,COLOR_ACTION,line);
    }
    else
    {
        Trap_Name(helper,name);
        format(line,sizeof(line),"You were untrapped by %s",name);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        new target[ACCOUNT_NAME_LEN];
        Trap_Name(playerid,target);
        format(line,sizeof(line),"You untrapped %s!",target);
        SendServerMessage(helper,line,MSG_TYPE_INFO);
        format(line,sizeof(line),"* %s releases the trap, letting %s free.",name,target);
        ProxDetector(helper,20.0,COLOR_ACTION,line);
    }

    if (removeTrap)
    {
        Trap_Remove(id);
    }

    pawn_call_public("Traps_OnReleased","dd",playerid,helper);
    return true;
}

stock Trap_Catch(id,playerid)
{
    new trap[e_TRAP];

    if (!Trap_Get(id,trap) || !Trap_IsArmed(trap) || Trap_IsCaught(playerid))
    {
        return false;
    }

    if (trap[E_TRAP_OWNER] == Character_GetId(playerid) || Staff_IsOnDuty(playerid))
    {
        return false;
    }

    trap[E_TRAP_DEPLOYED] = true;
    Trap_Put(id,trap);
    Trap_Save(id);
    Horse_ForceDismount(playerid);
    g_TrapCaught[playerid] = id;
    g_TrapReleaseDue[playerid] = GetTickCount() + TRAP_RELEASE_MS;
    Player_SetBusy(playerid,E_PLAYER_BUSY_TRAPPED,true);
    ProxDetector(playerid,20.0,COLOR_ACTION,"* A trap has been sprung nearby!");
    SendServerMessage(playerid,"Your feet has been caught in a trap. Someone has to release you or you have to wait to free yourself.",MSG_TYPE_INFO);
    TogglePlayerControllable(playerid,false);
    ApplyAnimation(playerid,"CRACK","crckidle2",4.0,true,false,false,false,0,SYNC_ALL);
    pawn_call_public("Traps_OnSprung","dd",id,playerid);
    return true;
}

stock Trap_Tick()
{
    new now = GetTickCount();

    for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
    {
        if (g_TrapCaught[playerid] != TRAP_NONE && g_TrapReleaseDue[playerid] != 0 && now - g_TrapReleaseDue[playerid] >= 0)
        {
            Trap_Release(playerid,INVALID_PLAYER_ID,true);
        }
    }

    if (!map_valid(g_Traps))
    {
        return;
    }

    new ids[32], count = 0;

    for (new Iter:it = map_iter(g_Traps);iter_inside(it) && count < sizeof(ids);iter_move_next(it))
    {
        new trap[e_TRAP];
        iter_get_arr(it,trap);

        if (trap[E_TRAP_PENDING] != TRAP_PENDING_NONE && now - trap[E_TRAP_DUE] >= 0)
        {
            ids[count++] = iter_get_key(it);
        }
    }

    for (new i = 0;i < count;i++)
    {
        new trap[e_TRAP], text[48];

        if (!Trap_Get(ids[i],trap))
        {
            continue;
        }

        trap[E_TRAP_DEPLOYED] = trap[E_TRAP_PENDING] == TRAP_PENDING_DISARM;
        trap[E_TRAP_PENDING] = TRAP_PENDING_NONE;
        Trap_Put(ids[i],trap);
        Trap_Save(ids[i]);
        format(text,sizeof(text),"Your trap is now %s.",trap[E_TRAP_DEPLOYED] ? ("deactivated") : ("activated"));

        if (IsPlayerConnected(trap[E_TRAP_OWNER_PLAYER]) && Character_GetId(trap[E_TRAP_OWNER_PLAYER]) == trap[E_TRAP_OWNER])
        {
            SendServerMessage(trap[E_TRAP_OWNER_PLAYER],text,MSG_TYPE_INFO);
        }
    }
}

stock bool:Trap_AnimalCheck(animal)
{
    if (!map_valid(g_Traps))
    {
        return false;
    }

    new Float:x, Float:y, Float:z;
    Wildlife_GetPosition(animal,x,y,z);

    for (new Iter:it = map_iter(g_Traps);iter_inside(it);iter_move_next(it))
    {
        new trap[e_TRAP];
        iter_get_arr(it,trap);

        if (!Trap_IsArmed(trap) || trap[E_TRAP_PENDING] != TRAP_PENDING_NONE)
        {
            continue;
        }

        if (floatabs(x - trap[E_TRAP_X]) <= TRAP_ANIMAL_BOX && floatabs(y - trap[E_TRAP_Y]) <= TRAP_ANIMAL_BOX)
        {
            new id = iter_get_key(it);
            trap[E_TRAP_DEPLOYED] = true;
            Trap_Put(id,trap);
            Trap_Save(id);
            Wildlife_Shot(animal,1000);
            pawn_call_public("Traps_OnAnimalCaught","dd",id,animal);
            return true;
        }
    }

    return false;
}

public Traps_OnSprung(trapid,playerid)
{
    return 1;
}

public Traps_OnReleased(playerid,helper)
{
    return 1;
}

public Traps_OnAnimalCaught(trapid,animal)
{
    return 1;
}

