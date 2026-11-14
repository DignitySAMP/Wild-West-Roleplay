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
#define CAMPFIRE_NONE (-1)
#define CAMPFIRE_MODEL (19632)
#define CAMPFIRE_RANGE (3.0)
#define CAMPFIRE_COOK_RANGE (2.5)
#define CAMPFIRE_DISTANCE (2.5)
#define CAMPFIRE_MINUTE_MS (60000)
#define CAMPFIRE_STAGE_LEN (40)
#define CAMPFIRE_BIRCH_MINUTES (5)
#define CAMPFIRE_OAK_MINUTES (7)
#define CAMPFIRE_YEW_MINUTES (10)

enum e_CAMPFIRE
{
    E_CAMPFIRE_OBJECT,
    E_CAMPFIRE_MINUTES,
    E_CAMPFIRE_DUE,
    Float:E_CAMPFIRE_X,
    Float:E_CAMPFIRE_Y,
    Float:E_CAMPFIRE_Z
}

static Map:s_Campfires;

forward Campfire_OnOut(playerid);

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
public Campfire_OnOut(playerid)
{
    return 1;
}

stock Campfire_Init()
{
    s_Campfires = map_new();
}

stock Campfire_Count()
{
    return map_valid(s_Campfires) ? map_size(s_Campfires) : 0;
}

stock bool:Campfire_Has(playerid)
{
    return map_valid(s_Campfires) && map_has_key(s_Campfires,playerid);
}

stock bool:Campfire_Get(playerid,fire[e_CAMPFIRE])
{
    if (!Campfire_Has(playerid))
    {
        return false;
    }

    map_get_arr(s_Campfires,playerid,fire);
    return true;
}

stock Campfire_GetMinutes(playerid)
{
    new fire[e_CAMPFIRE];

    if (!Campfire_Get(playerid,fire))
    {
        return 0;
    }

    return fire[E_CAMPFIRE_MINUTES];
}

stock Campfire_GetObject(playerid)
{
    new fire[e_CAMPFIRE];

    if (!Campfire_Get(playerid,fire))
    {
        return INVALID_STREAMER_ID;
    }

    return fire[E_CAMPFIRE_OBJECT];
}

stock Campfire_GetDue(playerid)
{
    new fire[e_CAMPFIRE];

    if (!Campfire_Get(playerid,fire))
    {
        return 0;
    }

    return fire[E_CAMPFIRE_DUE];
}

stock bool:Campfire_InRange(playerid,owner,Float:range)
{
    new fire[e_CAMPFIRE];

    if (!Campfire_Get(owner,fire))
    {
        return false;
    }

    return IsPlayerInRangeOfPoint(playerid,range,fire[E_CAMPFIRE_X],fire[E_CAMPFIRE_Y],fire[E_CAMPFIRE_Z]);
}

stock Campfire_Nearest(playerid,Float:range = CAMPFIRE_RANGE)
{
    if (!map_valid(s_Campfires))
    {
        return CAMPFIRE_NONE;
    }

    if (Campfire_InRange(playerid,playerid,range))
    {
        return playerid;
    }

    for (new Iter:it = map_iter(s_Campfires);iter_inside(it);iter_move_next(it))
    {
        new owner = iter_get_key(it);

        if (Campfire_InRange(playerid,owner,range))
        {
            return owner;
        }
    }

    return CAMPFIRE_NONE;
}

stock Campfire_GetStage(minutes,dest[],size = sizeof(dest))
{
    if (minutes < 1)
    {
        strcopy(dest,"N/A",size);
    }
    else if (minutes <= 5)
    {
        strcopy(dest,"Close to going out.",size);
    }
    else if (minutes <= 10)
    {
        strcopy(dest,"Small but steady.",size);
    }
    else if (minutes <= 15)
    {
        strcopy(dest,"A stable campfire.",size);
    }
    else if (minutes <= 20)
    {
        strcopy(dest,"The campfire is roaring pretty loudly.",size);
    }
    else
    {
        strcopy(dest,"A massive campfire.",size);
    }
}

stock Campfire_Light(playerid,minutes)
{
    new fire[e_CAMPFIRE], Float:x, Float:y, Float:z, Float:angle;
    GetPlayerPos(playerid,x,y,z);
    GetPlayerFacingAngle(playerid,angle);
    x += CAMPFIRE_DISTANCE * floatsin(-angle,degrees);
    y += CAMPFIRE_DISTANCE * floatcos(-angle,degrees);
    CA_FindZ_For2DCoord(x,y,z);
    fire[E_CAMPFIRE_OBJECT] = _:CreateDynamicObject(CAMPFIRE_MODEL,x,y,z,0.0,0.0,0.0,GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid));
    Streamer_ToggleItemStatic(STREAMER_TYPE_OBJECT,fire[E_CAMPFIRE_OBJECT],true);
    fire[E_CAMPFIRE_MINUTES] = minutes;
    fire[E_CAMPFIRE_DUE] = GetTickCount() + CAMPFIRE_MINUTE_MS;
    fire[E_CAMPFIRE_X] = x;
    fire[E_CAMPFIRE_Y] = y;
    fire[E_CAMPFIRE_Z] = z;
    map_set_arr(s_Campfires,playerid,fire);
    Streamer_Update(playerid);
}

stock Campfire_AddMinutes(playerid,minutes)
{
    new fire[e_CAMPFIRE];

    if (!Campfire_Get(playerid,fire))
    {
        return;
    }

    fire[E_CAMPFIRE_MINUTES] += minutes;
    map_set_arr(s_Campfires,playerid,fire);
}

stock bool:Campfire_Remove(playerid)
{
    new fire[e_CAMPFIRE];

    if (!Campfire_Get(playerid,fire))
    {
        return false;
    }

    map_remove(s_Campfires,playerid);

    if (IsValidDynamicObject(STREAMER_TAG_OBJECT:fire[E_CAMPFIRE_OBJECT]))
    {
        Streamer_ToggleItemStatic(STREAMER_TYPE_OBJECT,fire[E_CAMPFIRE_OBJECT],false);
        DestroyDynamicObject(STREAMER_TAG_OBJECT:fire[E_CAMPFIRE_OBJECT]);
    }

    return true;
}

stock Campfire_Tick(now)
{
    if (!map_valid(s_Campfires))
    {
        return;
    }

    new owners[MAX_PLAYERS], count = 0;

    for (new Iter:it = map_iter(s_Campfires);iter_inside(it);iter_move_next(it))
    {
        new fire[e_CAMPFIRE];
        iter_get_arr(it,fire);

        if (now - fire[E_CAMPFIRE_DUE] >= 0 && count < MAX_PLAYERS)
        {
            owners[count++] = iter_get_key(it);
        }
    }

    for (new i = 0;i < count;i++)
    {
        new fire[e_CAMPFIRE];

        if (!Campfire_Get(owners[i],fire))
        {
            continue;
        }

        fire[E_CAMPFIRE_MINUTES]--;
        fire[E_CAMPFIRE_DUE] += CAMPFIRE_MINUTE_MS;

        if (fire[E_CAMPFIRE_MINUTES] <= 0)
        {
            Campfire_Remove(owners[i]);
            SendServerMessage(owners[i],"Your fire has gone out.",MSG_TYPE_WARN);
            pawn_call_public("Campfire_OnOut","d",owners[i]);
            continue;
        }

        map_set_arr(s_Campfires,owners[i],fire);
    }
}

