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
#define GATE_NONE (-1)
#define GATE_RANGE (2.0)
#define GATE_NUDGE_SHORT (0.01)
#define GATE_NUDGE_LONG (0.02)

enum
{
    GATE_TYPE_PUBLIC,
    GATE_TYPE_PLAYER,
    GATE_TYPE_FACTION
}

enum e_GATE
{
    E_GATE_MODEL,
    E_GATE_OBJECT,
    E_GATE_TYPE,
    E_GATE_OWNER,
    E_GATE_SMOOTH,
    bool:E_GATE_NUDGED,
    E_GATE_INTERIOR,
    E_GATE_WORLD,
    bool:E_GATE_OPEN,
    Float:E_GATE_SHUT_X,
    Float:E_GATE_SHUT_Y,
    Float:E_GATE_SHUT_Z,
    Float:E_GATE_SHUT_RX,
    Float:E_GATE_SHUT_RY,
    Float:E_GATE_SHUT_RZ,
    Float:E_GATE_OPEN_X,
    Float:E_GATE_OPEN_Y,
    Float:E_GATE_OPEN_Z,
    Float:E_GATE_OPEN_RX,
    Float:E_GATE_OPEN_RY,
    Float:E_GATE_OPEN_RZ,
    Float:E_GATE_SPEED
}

static Pool:s_Gates;

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
stock Gate_Init()
{
    s_Gates = pool_new();
}

stock Gate_Count()
{
    return pool_valid(s_Gates) ? pool_size(s_Gates) : 0;
}

stock bool:Gate_Get(gateid,gate[e_GATE])
{
    if (!pool_valid(s_Gates) || !pool_has(s_Gates,gateid))
    {
        return false;
    }

    pool_get_arr(s_Gates,gateid,gate);
    return true;
}

stock Gate_Create(model,type,owner,interior,world,Float:speed,Float:shutX,Float:shutY,Float:shutZ,Float:shutRX,Float:shutRY,Float:shutRZ,Float:openX,Float:openY,Float:openZ,Float:openRX,Float:openRY,Float:openRZ,smooth)
{
    new gate[e_GATE];
    gate[E_GATE_MODEL] = model;
    gate[E_GATE_OBJECT] = _:CreateDynamicObject(model,shutX,shutY,shutZ,shutRX,shutRY,shutRZ,world,interior);
    gate[E_GATE_TYPE] = type;
    gate[E_GATE_OWNER] = owner;
    gate[E_GATE_SMOOTH] = smooth;
    gate[E_GATE_NUDGED] = false;
    gate[E_GATE_INTERIOR] = interior;
    gate[E_GATE_WORLD] = world;
    gate[E_GATE_OPEN] = false;
    gate[E_GATE_SHUT_X] = shutX;
    gate[E_GATE_SHUT_Y] = shutY;
    gate[E_GATE_SHUT_Z] = shutZ;
    gate[E_GATE_SHUT_RX] = shutRX;
    gate[E_GATE_SHUT_RY] = shutRY;
    gate[E_GATE_SHUT_RZ] = shutRZ;
    gate[E_GATE_OPEN_X] = openX;
    gate[E_GATE_OPEN_Y] = openY;
    gate[E_GATE_OPEN_Z] = openZ;
    gate[E_GATE_OPEN_RX] = openRX;
    gate[E_GATE_OPEN_RY] = openRY;
    gate[E_GATE_OPEN_RZ] = openRZ;
    gate[E_GATE_SPEED] = speed;

    if (!pool_valid(s_Gates))
    {
        Gate_Init();
    }

    pool_add_arr(s_Gates,gate);
    return gate[E_GATE_OBJECT];
}

stock Gate_NearPlayer(playerid)
{
    if (!pool_valid(s_Gates))
    {
        return GATE_NONE;
    }

    new interior = GetPlayerInterior(playerid), world = GetPlayerVirtualWorld(playerid);

    for (new Iter:it = pool_iter(s_Gates);iter_inside(it);iter_move_next(it))
    {
        new gate[e_GATE];
        iter_get_arr(it,gate);

        if (interior != gate[E_GATE_INTERIOR] || world != gate[E_GATE_WORLD])
        {
            continue;
        }

        if (IsPlayerInRangeOfPoint(playerid,GATE_RANGE,gate[E_GATE_SHUT_X],gate[E_GATE_SHUT_Y],gate[E_GATE_SHUT_Z]) || IsPlayerInRangeOfPoint(playerid,GATE_RANGE,gate[E_GATE_OPEN_X],gate[E_GATE_OPEN_Y],gate[E_GATE_OPEN_Z]))
        {
            return iter_get_key(it);
        }
    }

    return GATE_NONE;
}

stock bool:Gate_Toggle(gateid)
{
    new gate[e_GATE];

    if (!Gate_Get(gateid,gate))
    {
        return false;
    }

    new Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz;
    gate[E_GATE_OPEN] = !gate[E_GATE_OPEN];

    if (gate[E_GATE_OPEN])
    {
        x = gate[E_GATE_OPEN_X];
        y = gate[E_GATE_OPEN_Y];
        z = gate[E_GATE_OPEN_Z];
        rx = gate[E_GATE_OPEN_RX];
        ry = gate[E_GATE_OPEN_RY];
        rz = gate[E_GATE_OPEN_RZ];
    }
    else
    {
        x = gate[E_GATE_SHUT_X];
        y = gate[E_GATE_SHUT_Y];
        z = gate[E_GATE_SHUT_Z];
        rx = gate[E_GATE_SHUT_RX];
        ry = gate[E_GATE_SHUT_RY];
        rz = gate[E_GATE_SHUT_RZ];
    }

    if (gate[E_GATE_SMOOTH])
    {
        new Float:nudge = GATE_NUDGE_LONG;

        if (gate[E_GATE_NUDGED])
        {
            nudge = GATE_NUDGE_SHORT;
        }

        gate[E_GATE_NUDGED] = !gate[E_GATE_NUDGED];
        MoveDynamicObject(STREAMER_TAG_OBJECT:gate[E_GATE_OBJECT],x + nudge,y + nudge,z + nudge,gate[E_GATE_SPEED],rx,ry,rz);
    }
    else
    {
        SetDynamicObjectPos(STREAMER_TAG_OBJECT:gate[E_GATE_OBJECT],x,y,z);
        SetDynamicObjectRot(STREAMER_TAG_OBJECT:gate[E_GATE_OBJECT],rx,ry,rz);
    }

    pool_set_arr(s_Gates,gateid,gate);
    return true;
}
