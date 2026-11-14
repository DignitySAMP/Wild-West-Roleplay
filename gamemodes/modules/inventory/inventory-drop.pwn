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
#define DROP_RANGE (2.0)
#define DROP_LIFETIME (3600)
#define DROP_SWEEP_MS (60000)
#define DROP_PICKUP_COOLDOWN_MS (5000)
#define DROP_LABEL_RANGE (2.5)
#define DROP_LABEL_COLOUR (0xA3A3A3AA)

enum e_DROP
{
    E_DROP_ITEM,
    E_DROP_AMOUNT,
    E_DROP_PARAM1,
    E_DROP_PARAM2,
    E_DROP_PLAYER,
    Float:E_DROP_X,
    Float:E_DROP_Y,
    Float:E_DROP_Z,
    E_DROP_INTERIOR,
    E_DROP_WORLD,
    E_DROP_TIMESTAMP,
    E_DROP_OBJECT,
    E_DROP_LABEL,
}

static Map:s_DropMap;
static s_DropPickupTick[MAX_PLAYERS];

forward Dropped_Load();

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
stock Drop_GetCount()
{
    return map_valid(s_DropMap) ? map_size(s_DropMap) : 0;
}

stock bool:Drop_Exists(id)
{
    return map_valid(s_DropMap) && map_has_key(s_DropMap,id);
}

stock bool:Drop_Get(id,drop[e_DROP])
{
    if (!Drop_Exists(id))
    {
        return false;
    }

    map_get_arr(s_DropMap,id,drop);
    return true;
}

static Drop_Spawn(id)
{
    new drop[e_DROP];
    map_get_arr(s_DropMap,id,drop);

    new Float:hitX, Float:hitY, Float:hitZ, Float:rotX, Float:rotY, Float:rotZ, name[ITEM_NAME_LEN], hex[9], text[160];
    CA_RayCastLineAngle(drop[E_DROP_X],drop[E_DROP_Y],drop[E_DROP_Z] + 5.0,drop[E_DROP_X],drop[E_DROP_Y],drop[E_DROP_Z] - 5.0,hitX,hitY,hitZ,rotX,rotY,rotZ);
    drop[E_DROP_OBJECT] = _:CreateDynamicObject(Item_GetModel(drop[E_DROP_ITEM]),drop[E_DROP_X],drop[E_DROP_Y],drop[E_DROP_Z] + 0.5,rotX,rotY,rotZ,drop[E_DROP_WORLD],drop[E_DROP_INTERIOR]);
    Item_GetName(drop[E_DROP_ITEM],name);
    Item_GetRarityHex(drop[E_DROP_ITEM],hex);
    format(text,sizeof(text),"[%d] [%s%s{A3A3A3}]{DEDEDE}\nPress ~k~~SNEAK_ABOUT~ to pick up.",id,hex,name);
    drop[E_DROP_LABEL] = _:CreateDynamic3DTextLabel(text,DROP_LABEL_COLOUR,drop[E_DROP_X],drop[E_DROP_Y],drop[E_DROP_Z] + 0.5,DROP_LABEL_RANGE,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,drop[E_DROP_WORLD],drop[E_DROP_INTERIOR]);
    map_set_arr(s_DropMap,id,drop);
}

static Drop_Register(id,item,amount,param1,param2,player,Float:x,Float:y,Float:z,interior,world,timestamp)
{
    new drop[e_DROP];
    drop[E_DROP_ITEM] = item;
    drop[E_DROP_AMOUNT] = amount;
    drop[E_DROP_PARAM1] = param1;
    drop[E_DROP_PARAM2] = param2;
    drop[E_DROP_PLAYER] = player;
    drop[E_DROP_X] = x;
    drop[E_DROP_Y] = y;
    drop[E_DROP_Z] = z;
    drop[E_DROP_INTERIOR] = interior;
    drop[E_DROP_WORLD] = world;
    drop[E_DROP_TIMESTAMP] = timestamp;
    drop[E_DROP_OBJECT] = -1;
    drop[E_DROP_LABEL] = -1;
    map_set_arr(s_DropMap,id,drop);
    Drop_Spawn(id);
}

stock bool:Drop_Remove(id,bool:database = true)
{
    new drop[e_DROP];

    if (!Drop_Get(id,drop))
    {
        return false;
    }

    if (IsValidDynamicObject(STREAMER_TAG_OBJECT:drop[E_DROP_OBJECT]))
    {
        DestroyDynamicObject(STREAMER_TAG_OBJECT:drop[E_DROP_OBJECT]);
    }

    if (IsValidDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:drop[E_DROP_LABEL]))
    {
        DestroyDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:drop[E_DROP_LABEL]);
    }

    map_remove(s_DropMap,id);

    if (database)
    {
        mysql_tquery_s(g_Mysql,str_format("DELETE FROM dropped_items WHERE dropped_id = %d",id));
    }

    return true;
}

stock Drop_FindNear(playerid)
{
    new interior = GetPlayerInterior(playerid), world = GetPlayerVirtualWorld(playerid), found = 0;

    for (new Iter:it = map_iter(s_DropMap);iter_inside(it);iter_move_next(it))
    {
        new drop[e_DROP];
        iter_get_arr(it,drop);

        if (drop[E_DROP_INTERIOR] != interior || drop[E_DROP_WORLD] != world || !IsPlayerInRangeOfPoint(playerid,DROP_RANGE,drop[E_DROP_X],drop[E_DROP_Y],drop[E_DROP_Z]))
        {
            continue;
        }

        if (found == 0)
        {
            found = iter_get_key(it);
        }
    }

    return found;
}

static stock Drop_Create(player,item,amount,param1,param2,Float:x,Float:y,Float:z,interior,world)
{
    yield 1;

    new timestamp = gettime() + DROP_LIFETIME;
    await mysql_aquery_s(g_Mysql,str_format("INSERT INTO dropped_items (dropped_player, dropped_item, dropped_amount, dropped_param1, dropped_param2, dropped_pos_x, dropped_pos_y, dropped_pos_z, dropped_int, dropped_vw, dropped_timestamp) VALUES (%d, %d, %d, %d, %d, %f, %f, %f, %d, %d, %d)",player,item,amount,param1,param2,x,y,z,interior,world,timestamp),false);
    new id = cache_insert_id();

    if (id > 0)
    {
        Drop_Register(id,item,amount,param1,param2,player,x,y,z,interior,world,timestamp);
    }
}

stock bool:Inventory_Drop(playerid,index)
{
    new row[e_INV_ROW];

    if (!Player_IsReady(playerid) || !Inventory_GetRow(playerid,index,row))
    {
        return false;
    }

    if (row[E_INV_ROW_PARAM2] == E_ITEM_EXTRA_FISHING_BOOT || Item_GetExtra(row[E_INV_ROW_ITEM]) == E_ITEM_EXTRA_FISHING_BOOT)
    {
        SendServerMessage(playerid,"You've tossed the dirty ol' boot away.",MSG_TYPE_INFO);
        Inventory_Remove(playerid,index);
        return true;
    }

    new Float:x, Float:y, Float:z, interior = GetPlayerInterior(playerid), world = GetPlayerVirtualWorld(playerid), name[ACCOUNT_NAME_LEN], itemName[ITEM_NAME_LEN], line[200];
    GetPlayerPos(playerid,x,y,z);
    z -= 0.75;
    Inventory_Remove(playerid,index);
    Drop_Create(Character_GetId(playerid),row[E_INV_ROW_ITEM],row[E_INV_ROW_AMOUNT],row[E_INV_ROW_PARAM1],row[E_INV_ROW_PARAM2],x,y,z,interior,world);
    Account_GetRoleplayName(playerid,name);
    Item_GetName(row[E_INV_ROW_ITEM],itemName);
    format(line,sizeof(line),"%s dropped %d (%d) %s.  (%d,%d,%d,%d,%d,%.02f,%.02f,%.02f,%d,%d)",name,row[E_INV_ROW_AMOUNT],row[E_INV_ROW_ITEM],itemName,Character_GetId(playerid),row[E_INV_ROW_ITEM],row[E_INV_ROW_AMOUNT],row[E_INV_ROW_PARAM1],row[E_INV_ROW_PARAM2],x,y,z,interior,world);
    Log_Info("item/drop","%s",line);
    return true;
}

stock bool:Drop_Pickup(playerid,id)
{
    new drop[e_DROP];

    if (!Drop_Get(id,drop))
    {
        return false;
    }

    if (!Inventory_Give(playerid,drop[E_DROP_ITEM],drop[E_DROP_AMOUNT],drop[E_DROP_PARAM1],drop[E_DROP_PARAM2]))
    {
        return false;
    }

    new name[ACCOUNT_NAME_LEN], line[160];
    Account_GetRoleplayName(playerid,name);
    format(line,sizeof(line),"%s picked up an item. (ID: %d) (%d,%d,%d,%d)",name,id,drop[E_DROP_ITEM],drop[E_DROP_AMOUNT],drop[E_DROP_PARAM1],drop[E_DROP_PARAM2]);
    Log_Info("item/pickup","%s",line);
    Drop_Remove(id);
    return true;
}

stock Drop_Sweep()
{
    new ids[256], count = 0, now = gettime();

    for (new Iter:it = map_iter(s_DropMap);iter_inside(it);iter_move_next(it))
    {
        new drop[e_DROP];
        iter_get_arr(it,drop);

        if (now >= drop[E_DROP_TIMESTAMP] && count < sizeof(ids))
        {
            ids[count++] = iter_get_key(it);
        }
    }

    for (new i = 0;i < count;i++)
    {
        Drop_Remove(ids[i]);
    }

    if (count > 0)
    {
        Log_Info("item/drop","Removed %d items",count);
    }

    return count;
}

stock Drop_ExpireAll()
{
    for (new Iter:it = map_iter(s_DropMap);iter_inside(it);iter_move_next(it))
    {
        new id = iter_get_key(it), drop[e_DROP];
        iter_get_arr(it,drop);
        drop[E_DROP_TIMESTAMP] = 0;
        map_set_arr(s_DropMap,id,drop);
    }

    mysql_tquery_s(g_Mysql,str_new("UPDATE dropped_items SET dropped_timestamp = 0"));
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
CMD:cleardroppeditems(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireManager(playerid))
    {
        return 1;
    }

    Drop_ExpireAll();
    SendServerMessage(playerid,"All dropped items will be cleared in a minute or less.",MSG_TYPE_INFO);
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
#pragma warning push
#pragma warning disable 204
public Dropped_Load()
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_new("SELECT dropped_id, dropped_player, dropped_item, dropped_amount, dropped_param1, dropped_param2, dropped_pos_x, dropped_pos_y, dropped_pos_z, dropped_int, dropped_vw, dropped_timestamp FROM dropped_items"),false);

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, player, item, amount, param1, param2, Float:x, Float:y, Float:z, interior, world, timestamp;
        cache_get_value_name_int(i,"dropped_id",id);
        cache_get_value_name_int(i,"dropped_player",player);
        cache_get_value_name_int(i,"dropped_item",item);
        cache_get_value_name_int(i,"dropped_amount",amount);
        cache_get_value_name_int(i,"dropped_param1",param1);
        cache_get_value_name_int(i,"dropped_param2",param2);
        cache_get_value_name_float(i,"dropped_pos_x",x);
        cache_get_value_name_float(i,"dropped_pos_y",y);
        cache_get_value_name_float(i,"dropped_pos_z",z);
        cache_get_value_name_int(i,"dropped_int",interior);
        cache_get_value_name_int(i,"dropped_vw",world);
        cache_get_value_name_int(i,"dropped_timestamp",timestamp);

        if (id < 1 || !Item_IsValid(item) || Drop_Exists(id))
        {
            continue;
        }

        Drop_Register(id,item,amount,param1,param2,player,x,y,z,interior,world,timestamp);
    }

    Log_Info("item/drop","Loaded %d dropped items",Drop_GetCount());
    Boot_LoaderDone();
    return 1;
}
#pragma warning pop

Timer_Declare(Drop_SweepTimer)
{

    Drop_Sweep();
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
    s_DropMap = map_new();
    Boot_RegisterLoader("Dropped_Load");
    Timer_Start(Drop_SweepTimer,DROP_SWEEP_MS);
}

hook OnPlayerConnect(playerid)
{
    s_DropPickupTick[playerid] = 0;
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (!(newkeys & KEY_WALK) || !Player_IsReady(playerid) || !Inventory_IsLoaded(playerid))
    {
        return;
    }

    new id = Drop_FindNear(playerid);

    if (id == 0)
    {
        return;
    }

    new elapsed = GetTickCount() - s_DropPickupTick[playerid];

    if (elapsed < DROP_PICKUP_COOLDOWN_MS)
    {
        new line[96];
        format(line,sizeof(line),"You must wait %0.2f seconds before picking something up again.",float(DROP_PICKUP_COOLDOWN_MS - elapsed) / 1000.0);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return;
    }

    s_DropPickupTick[playerid] = GetTickCount();
    Drop_Pickup(playerid,id);
}
