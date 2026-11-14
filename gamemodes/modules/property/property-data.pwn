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
#define POINT_NAME_LEN (32)
#define POINT_ENTER_RANGE (1.5)
#define POINT_COMMAND_RANGE (2.5)
#define POINT_SLEEP_RANGE (20.5)
#define POINT_SERVICE_RANGE (15.0)
#define POINT_LABEL_RANGE (25.0)
#define POINT_PRICE_DEFAULT (500)
#define POINT_FEE_MAX (99)
#define POINT_INACTIVE_SECONDS (604800)
#define POINT_EXPERIENCE_BUY (3)
#define POINT_DEFAULT_NAME ("Unnamed point")
#define POINT_DEFAULT_INT_X (1142.8990)
#define POINT_DEFAULT_INT_Y (-1810.0664)
#define POINT_DEFAULT_INT_Z (33.2668)
#define POINT_ICON_BUSINESS (56)
#define POINT_PICKUP_HOUSE (1272)
#define POINT_PICKUP_BUSINESS (1274)
#define POINT_PICKUP_PASS (1239)
#define POINT_OWNER_NONE (-1)
#define POINT_STREAM_PRIORITY (1)
#define POINT_PASSPORT_PRICE (100)
#define POINT_TAX_HOUSE (100)
#define POINT_TAX_BUSINESS (250)

enum _:E_POINT_KIND
{
    POINT_TYPE_PASS = 0,
    POINT_TYPE_HOUSE,
    POINT_TYPE_BIZ,
}

enum _:E_POINT_BIZ
{
    POINT_BIZ_GENERAL = 0,
    POINT_BIZ_GUN,
    POINT_BIZ_CLOTHING,
    POINT_BIZ_BARBER,
    POINT_BIZ_LIQUOR,
    POINT_BIZ_SALOON,
    POINT_BIZ_HUNTING,
    POINT_BIZ_BANK,
    POINT_BIZ_POSTAL,
    POINT_BIZ_SHERIFF,
    POINT_BIZ_BLACKSMITH,
    POINT_BIZ_STABLE,
}

enum e_POINT
{
    E_POINT_NAME[POINT_NAME_LEN],
    E_POINT_OWNER,
    E_POINT_PRICE,
    E_POINT_BIZTYPE,
    E_POINT_TYPE,
    E_POINT_FEE,
    E_POINT_RENTABLE,
    E_POINT_RENT_PRICE,
    E_POINT_RENT_CHANGE,
    E_POINT_TILL,
    E_POINT_TILL_CHANGE,
    E_POINT_WEAPON1,
    E_POINT_WEAPON1_AMMO,
    E_POINT_WEAPON2,
    E_POINT_WEAPON2_AMMO,
    E_POINT_LOCKED,
    Float:E_POINT_EXT_X,
    Float:E_POINT_EXT_Y,
    Float:E_POINT_EXT_Z,
    E_POINT_VW,
    E_POINT_INT,
    Float:E_POINT_INT_X,
    Float:E_POINT_INT_Y,
    Float:E_POINT_INT_Z,
    E_POINT_INT_VW,
    E_POINT_INT_INT,
    E_POINT_PICKUP,
    E_POINT_ICON,
    E_POINT_LABEL,
}

static const s_PointAmbientFile[] = "ambient/ambient_interior.mp3";
static Map:s_Points;
static s_PointInside[MAX_PLAYERS];

forward Point_Load();
forward Task:Point_Create(playerid,type);
forward Task:Point_Reload();
forward Point_OnCreated(playerid,pointid);
forward Point_OnRemoved(pointid);
forward Point_OnChanged(pointid);
forward Point_OnCleared(pointid);
forward Point_OnFurniture(playerid,pointid);

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
stock Point_GetAmbientUrl(dest[],size = sizeof(dest))
{
    Audio_Build(s_PointAmbientFile,dest,size);
}

stock Iter:Point_Iterator()
{
    return map_iter(s_Points);
}

stock Point_GetCount()
{
    return map_valid(s_Points) ? map_size(s_Points) : 0;
}

stock bool:Point_Exists(pointid)
{
    return pointid > 0 && map_valid(s_Points) && map_has_key(s_Points,pointid);
}

stock bool:Point_Get(pointid,point[e_POINT])
{
    if (!Point_Exists(pointid))
    {
        return false;
    }

    map_get_arr(s_Points,pointid,point);
    return true;
}

stock Point_Commit(pointid,const point[e_POINT])
{
    map_set_arr(s_Points,pointid,point);
}

stock Point_GetPlayerPoint(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return 0;
    }

    return s_PointInside[playerid];
}

stock Point_SetPlayerPoint(playerid,pointid)
{
    if (playerid >= 0 && playerid < MAX_PLAYERS)
    {
        s_PointInside[playerid] = pointid;
    }
}

stock Point_GetOwned(playerid,type = -1)
{
    new count = 0, character = Character_GetId(playerid);

    if (!map_valid(s_Points) || character <= 0)
    {
        return 0;
    }

    for (new Iter:it = map_iter(s_Points);iter_inside(it);iter_move_next(it))
    {
        new point[e_POINT];
        iter_get_arr(it,point);

        if (point[E_POINT_OWNER] == character && (type == -1 || point[E_POINT_TYPE] == type))
        {
            count++;
        }
    }

    return count;
}

stock bool:Point_IsOwner(playerid,pointid)
{
    new point[e_POINT];
    return Point_Get(pointid,point) && point[E_POINT_OWNER] > 0 && point[E_POINT_OWNER] == Character_GetId(playerid);
}

stock Point_FindExterior(playerid,Float:range)
{
    new interior = GetPlayerInterior(playerid), world = GetPlayerVirtualWorld(playerid), found = 0;

    if (!map_valid(s_Points))
    {
        return 0;
    }

    for (new Iter:it = map_iter(s_Points);iter_inside(it);iter_move_next(it))
    {
        new point[e_POINT];
        iter_get_arr(it,point);

        if (found == 0 && point[E_POINT_INT] == interior && point[E_POINT_VW] == world && IsPlayerInRangeOfPoint(playerid,range,point[E_POINT_EXT_X],point[E_POINT_EXT_Y],point[E_POINT_EXT_Z]))
        {
            found = iter_get_key(it);
        }
    }

    return found;
}

stock Point_FindInterior(playerid,Float:range)
{
    new interior = GetPlayerInterior(playerid), world = GetPlayerVirtualWorld(playerid), found = 0;

    if (!map_valid(s_Points))
    {
        return 0;
    }

    for (new Iter:it = map_iter(s_Points);iter_inside(it);iter_move_next(it))
    {
        new point[e_POINT];
        iter_get_arr(it,point);

        if (found == 0 && point[E_POINT_INT_INT] == interior && point[E_POINT_INT_VW] == world && IsPlayerInRangeOfPoint(playerid,range,point[E_POINT_INT_X],point[E_POINT_INT_Y],point[E_POINT_INT_Z]))
        {
            found = iter_get_key(it);
        }
    }

    return found;
}

stock Point_FindOwned(playerid,type)
{
    new character = Character_GetId(playerid);

    if (!map_valid(s_Points) || character <= 0)
    {
        return 0;
    }

    for (new Iter:it = map_iter(s_Points);iter_inside(it);iter_move_next(it))
    {
        new point[e_POINT];
        iter_get_arr(it,point);

        if (point[E_POINT_OWNER] == character && point[E_POINT_TYPE] == type)
        {
            return iter_get_key(it);
        }
    }

    return 0;
}

stock Point_FindNear(playerid,Float:range)
{
    new found = Point_FindExterior(playerid,range);

    if (found == 0)
    {
        found = Point_FindInterior(playerid,range);
    }

    return found;
}

stock Point_FindService(playerid,biztype)
{
    new pointid = Point_FindInterior(playerid,POINT_SERVICE_RANGE);

    if (pointid == 0)
    {
        return 0;
    }

    new point[e_POINT];
    Point_Get(pointid,point);
    return point[E_POINT_BIZTYPE] == biztype ? pointid : 0;
}

static Point_DestroyWorld(point[e_POINT])
{
    if (point[E_POINT_LABEL] != 0)
    {
        DestroyDynamic3DTextLabel(DynamicText3D:point[E_POINT_LABEL]);
        point[E_POINT_LABEL] = 0;
    }

    if (point[E_POINT_PICKUP] != 0)
    {
        DestroyDynamicPickup(DynamicPickup:point[E_POINT_PICKUP]);
        point[E_POINT_PICKUP] = 0;
    }

    if (point[E_POINT_ICON] != 0)
    {
        DestroyDynamicMapIcon(DynamicMapIcon:point[E_POINT_ICON]);
        point[E_POINT_ICON] = 0;
    }
}

static Point_BuildWorld(pointid,point[e_POINT])
{
    new text[128], money[MONEY_TEXT_LEN];
    Point_DestroyWorld(point);

    switch (point[E_POINT_TYPE])
    {
        case POINT_TYPE_HOUSE:
        {
            if (point[E_POINT_OWNER] != POINT_OWNER_NONE)
            {
                if (point[E_POINT_RENTABLE] != 0)
                {
                    format(text,sizeof(text),"(%d) %s\nRent Price: $%02d.%02d",pointid,point[E_POINT_NAME],point[E_POINT_RENT_PRICE],point[E_POINT_RENT_CHANGE]);
                }
                else
                {
                    format(text,sizeof(text),"(%d) %s",pointid,point[E_POINT_NAME]);
                }
            }
            else
            {
                Money_Delimit(point[E_POINT_PRICE],money);
                format(text,sizeof(text),"(%d) %s\nFor sale: $%s",pointid,point[E_POINT_NAME],money);
            }

            point[E_POINT_PICKUP] = _:CreateDynamicPickup(POINT_PICKUP_HOUSE,1,point[E_POINT_EXT_X],point[E_POINT_EXT_Y],point[E_POINT_EXT_Z],point[E_POINT_VW],point[E_POINT_INT],-1);
        }
        case POINT_TYPE_BIZ:
        {
            if (point[E_POINT_OWNER] != POINT_OWNER_NONE)
            {
                format(text,sizeof(text),"(%d) %s\nEntrance fee: $0.%02d",pointid,point[E_POINT_NAME],point[E_POINT_FEE]);
            }
            else
            {
                Money_Delimit(point[E_POINT_PRICE],money);
                format(text,sizeof(text),"(%d) %s\nFor sale: $%s",pointid,point[E_POINT_NAME],money);
            }

            point[E_POINT_PICKUP] = _:CreateDynamicPickup(POINT_PICKUP_BUSINESS,1,point[E_POINT_EXT_X],point[E_POINT_EXT_Y],point[E_POINT_EXT_Z],point[E_POINT_VW],point[E_POINT_INT],-1);
            point[E_POINT_ICON] = _:CreateDynamicMapIcon(point[E_POINT_EXT_X],point[E_POINT_EXT_Y],point[E_POINT_EXT_Z],POINT_ICON_BUSINESS,-1);
        }
        default:
        {
            format(text,sizeof(text),"(%d) %s\nPress ~k~~GROUP_CONTROL_BWD~ to pass",pointid,point[E_POINT_NAME]);
            point[E_POINT_PICKUP] = _:CreateDynamicPickup(POINT_PICKUP_PASS,1,point[E_POINT_EXT_X],point[E_POINT_EXT_Y],point[E_POINT_EXT_Z],point[E_POINT_VW],point[E_POINT_INT],0x0997DEFF);
        }
    }

    point[E_POINT_LABEL] = _:CreateDynamic3DTextLabel(text,COLOR_DEFAULT,point[E_POINT_EXT_X],point[E_POINT_EXT_Y],point[E_POINT_EXT_Z],POINT_LABEL_RANGE,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,POINT_STREAM_PRIORITY,point[E_POINT_VW],point[E_POINT_INT],-1);
}

static Point_Read(row,point[e_POINT])
{
    cache_get_value_name(row,"point_name",point[E_POINT_NAME],POINT_NAME_LEN);
    cache_get_value_name_int(row,"point_owner",point[E_POINT_OWNER]);
    cache_get_value_name_int(row,"point_price",point[E_POINT_PRICE]);
    cache_get_value_name_int(row,"point_biztype",point[E_POINT_BIZTYPE]);
    cache_get_value_name_int(row,"point_type",point[E_POINT_TYPE]);
    cache_get_value_name_int(row,"point_fee",point[E_POINT_FEE]);
    cache_get_value_name_int(row,"point_rentable",point[E_POINT_RENTABLE]);
    cache_get_value_name_int(row,"point_rent_price",point[E_POINT_RENT_PRICE]);
    cache_get_value_name_int(row,"point_rent_change",point[E_POINT_RENT_CHANGE]);
    cache_get_value_name_int(row,"point_till",point[E_POINT_TILL]);
    cache_get_value_name_int(row,"point_till_change",point[E_POINT_TILL_CHANGE]);
    cache_get_value_name_int(row,"point_weapon1",point[E_POINT_WEAPON1]);
    cache_get_value_name_int(row,"point_weapon1ammo",point[E_POINT_WEAPON1_AMMO]);
    cache_get_value_name_int(row,"point_weapon2",point[E_POINT_WEAPON2]);
    cache_get_value_name_int(row,"point_weapon2ammo",point[E_POINT_WEAPON2_AMMO]);
    cache_get_value_name_int(row,"point_locked",point[E_POINT_LOCKED]);
    cache_get_value_name_float(row,"point_ext_x",point[E_POINT_EXT_X]);
    cache_get_value_name_float(row,"point_ext_y",point[E_POINT_EXT_Y]);
    cache_get_value_name_float(row,"point_ext_z",point[E_POINT_EXT_Z]);
    cache_get_value_name_int(row,"point_vw",point[E_POINT_VW]);
    cache_get_value_name_int(row,"point_int",point[E_POINT_INT]);
    cache_get_value_name_float(row,"point_int_x",point[E_POINT_INT_X]);
    cache_get_value_name_float(row,"point_int_y",point[E_POINT_INT_Y]);
    cache_get_value_name_float(row,"point_int_z",point[E_POINT_INT_Z]);
    cache_get_value_name_int(row,"point_int_vw",point[E_POINT_INT_VW]);
    cache_get_value_name_int(row,"point_int_int",point[E_POINT_INT_INT]);
}

static const s_PointColumns[] = "point_id, point_name, point_owner, point_price, point_biztype, point_type, point_fee, point_rentable, point_rent_price, point_rent_change, point_till, point_till_change, point_weapon1, point_weapon1ammo, point_weapon2, point_weapon2ammo, point_locked, point_ext_x, point_ext_y, point_ext_z, point_vw, point_int, point_int_x, point_int_y, point_int_z, point_int_vw, point_int_int";

stock Point_Refresh(pointid)
{
    new point[e_POINT];

    if (!Point_Get(pointid,point))
    {
        return;
    }

    Point_BuildWorld(pointid,point);
    Point_Commit(pointid,point);
}

stock Point_Store(pointid,point[e_POINT])
{
    if (!Point_Exists(pointid))
    {
        return;
    }

    Point_BuildWorld(pointid,point);
    Point_Commit(pointid,point);
    pawn_call_public("Point_OnChanged","d",pointid);
}

stock Point_Update(pointid,const column[],value)
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE points SET %s = %d WHERE point_id = %d",column,value,pointid));
}

stock Point_UpdateOwnership(pointid)
{
    new point[e_POINT];

    if (!Point_Get(pointid,point))
    {
        return;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE points SET point_owner = %d, point_till = %d, point_till_change = %d, point_weapon1 = %d, point_weapon1ammo = %d, point_weapon2 = %d, point_weapon2ammo = %d WHERE point_id = %d",point[E_POINT_OWNER],point[E_POINT_TILL],point[E_POINT_TILL_CHANGE],point[E_POINT_WEAPON1],point[E_POINT_WEAPON1_AMMO],point[E_POINT_WEAPON2],point[E_POINT_WEAPON2_AMMO],pointid));
}

stock Point_Clear(pointid)
{
    new point[e_POINT];

    if (!Point_Get(pointid,point))
    {
        return;
    }

    point[E_POINT_OWNER] = POINT_OWNER_NONE;
    point[E_POINT_TILL] = 0;
    point[E_POINT_TILL_CHANGE] = 0;
    point[E_POINT_WEAPON1] = 0;
    point[E_POINT_WEAPON1_AMMO] = 0;
    point[E_POINT_WEAPON2] = 0;
    point[E_POINT_WEAPON2_AMMO] = 0;
    Point_Store(pointid,point);
    Point_UpdateOwnership(pointid);
    pawn_call_public("Point_OnCleared","d",pointid);
}

stock Point_Eject(pointid)
{
    new point[e_POINT];

    if (!Point_Get(pointid,point))
    {
        return;
    }

    foreach (new i : Player)
    {
        if (s_PointInside[i] == pointid)
        {
            s_PointInside[i] = 0;
            SetPlayerInterior(i,point[E_POINT_INT]);
            SetPlayerVirtualWorld(i,point[E_POINT_VW]);
            SetPlayerPos(i,point[E_POINT_EXT_X],point[E_POINT_EXT_Y],point[E_POINT_EXT_Z]);
        }
    }
}

stock Point_Remove(pointid)
{
    new point[e_POINT];

    if (!Point_Get(pointid,point))
    {
        return;
    }

    Point_Eject(pointid);
    Point_DestroyWorld(point);
    map_remove(s_Points,pointid);
    mysql_tquery_s(g_Mysql,str_format("DELETE FROM points WHERE point_id = %d",pointid));
    pawn_call_public("Point_OnRemoved","d",pointid);
}

#pragma warning push
#pragma warning disable 204
async Task:Point_Create(playerid,type)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    new world = GetPlayerVirtualWorld(playerid), interior = GetPlayerInterior(playerid);
    await mysql_aquery_s(g_Mysql,str_format("INSERT INTO points (point_name, point_type, point_ext_x, point_ext_y, point_ext_z, point_vw, point_int, point_price, point_int_x, point_int_y, point_int_z, point_int_vw, point_int_int) VALUES ('%e', %d, %f, %f, %f, %d, %d, %d, %f, %f, %f, 0, 0)",POINT_DEFAULT_NAME,type,x,y,z,world,interior,POINT_PRICE_DEFAULT,POINT_DEFAULT_INT_X,POINT_DEFAULT_INT_Y,POINT_DEFAULT_INT_Z),false);
    new pointid = cache_insert_id();

    if (pointid <= 0)
    {
        return async 0;
    }

    await mysql_aquery_s(g_Mysql,str_format("UPDATE points SET point_int_vw = %d WHERE point_id = %d",pointid,pointid),false);
    await mysql_aquery_s(g_Mysql,str_format("SELECT %s FROM points WHERE point_id = %d",s_PointColumns,pointid),false);

    if (cache_num_rows() > 0)
    {
        new point[e_POINT];
        Point_Read(0,point);
        Point_BuildWorld(pointid,point);
        Point_Commit(pointid,point);
        pawn_call_public("Point_OnCreated","dd",playerid,pointid);
    }

    return async pointid;
}

public Point_Load()
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT %s FROM points",s_PointColumns),false);

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, point[e_POINT];
        cache_get_value_name_int(i,"point_id",id);

        if (id < 1 || Point_Exists(id))
        {
            continue;
        }

        Point_Read(i,point);
        Point_BuildWorld(id,point);
        Point_Commit(id,point);
    }

    Log_Info("property/points","Loaded %d points",Point_GetCount());
    Boot_LoaderDone();
    return 1;
}

async Task:Point_Reload()
{
    await mysql_aquery_s(g_Mysql,str_format("SELECT %s FROM points",s_PointColumns),false);
    new Map:fresh = map_new();

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, point[e_POINT], old[e_POINT];
        cache_get_value_name_int(i,"point_id",id);

        if (id < 1)
        {
            continue;
        }

        if (Point_Get(id,old))
        {
            Point_DestroyWorld(old);
        }

        Point_Read(i,point);
        Point_BuildWorld(id,point);
        Point_Commit(id,point);
        map_set(fresh,id,1);
    }

    new stale[256], count = 0;

    for (new Iter:it = map_iter(s_Points);iter_inside(it);iter_move_next(it))
    {
        new id = iter_get_key(it);

        if (!map_has_key(fresh,id) && count < sizeof(stale))
        {
            stale[count++] = id;
        }
    }

    map_delete(fresh);

    for (new i = 0;i < count;i++)
    {
        Point_Remove(stale[i]);
    }

    return async Point_GetCount();
}
#pragma warning pop

public Point_OnCreated(playerid,pointid)
{
    return 1;
}

public Point_OnRemoved(pointid)
{
    return 1;
}

public Point_OnChanged(pointid)
{
    return 1;
}

public Point_OnCleared(pointid)
{
    return 1;
}

public Point_OnFurniture(playerid,pointid)
{
    return 1;
}

stock Point_InitPool()
{
    s_Points = map_new();
}
