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
#define GUNDROP_RANGE (1.5)
#define GUNDROP_DROP_HEIGHT (0.9)

enum e_GUNDROP
{
    E_GUNDROP_WEAPON,
    E_GUNDROP_AMMO,
    E_GUNDROP_OBJECT,
    Float:E_GUNDROP_X,
    Float:E_GUNDROP_Y,
    Float:E_GUNDROP_Z,
    E_GUNDROP_INTERIOR,
    E_GUNDROP_WORLD,
}

static Map:s_GunDrops;
static s_GunDropNext = 1;

forward Weapons_OnDropped(playerid,weapon,ammo);

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
stock Weapons_DropCount()
{
    return map_valid(s_GunDrops) ? map_size(s_GunDrops) : 0;
}

stock bool:Weapons_DropGet(id,drop[e_GUNDROP])
{
    if (!map_valid(s_GunDrops) || !map_has_key(s_GunDrops,id))
    {
        return false;
    }

    map_get_arr(s_GunDrops,id,drop);
    return true;
}

stock bool:Weapons_DropRemove(id)
{
    new drop[e_GUNDROP];

    if (!Weapons_DropGet(id,drop))
    {
        return false;
    }

    if (IsValidDynamicObject(STREAMER_TAG_OBJECT:drop[E_GUNDROP_OBJECT]))
    {
        DestroyDynamicObject(STREAMER_TAG_OBJECT:drop[E_GUNDROP_OBJECT]);
    }

    map_remove(s_GunDrops,id);
    return true;
}

stock Weapons_DropFindNear(playerid)
{
    new interior = GetPlayerInterior(playerid), world = GetPlayerVirtualWorld(playerid), found = 0;

    for (new Iter:it = map_iter(s_GunDrops);iter_inside(it);iter_move_next(it))
    {
        new drop[e_GUNDROP];
        iter_get_arr(it,drop);

        if (found == 0 && drop[E_GUNDROP_INTERIOR] == interior && drop[E_GUNDROP_WORLD] == world && IsPlayerInRangeOfPoint(playerid,GUNDROP_RANGE,drop[E_GUNDROP_X],drop[E_GUNDROP_Y],drop[E_GUNDROP_Z]))
        {
            found = iter_get_key(it);
        }
    }

    return found;
}

stock bool:Weapons_IsCrouching(playerid)
{

    return GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_DUCK;
}

stock Weapons_DropGun(playerid)
{
    new weapon = Weapons_Get(playerid,E_GUN_SLOT_HAND), ammo = Weapons_GetAmmo(playerid,E_GUN_SLOT_HAND), Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    new drop[e_GUNDROP], id = s_GunDropNext++;
    drop[E_GUNDROP_WEAPON] = weapon;
    drop[E_GUNDROP_AMMO] = ammo;
    drop[E_GUNDROP_X] = x;
    drop[E_GUNDROP_Y] = y;
    drop[E_GUNDROP_Z] = z - GUNDROP_DROP_HEIGHT;
    drop[E_GUNDROP_INTERIOR] = GetPlayerInterior(playerid);
    drop[E_GUNDROP_WORLD] = GetPlayerVirtualWorld(playerid);
    drop[E_GUNDROP_OBJECT] = _:CreateDynamicObject(Weapon_GetModel(weapon),x,y,z - GUNDROP_DROP_HEIGHT,90.0,0.0,45.0,drop[E_GUNDROP_WORLD],drop[E_GUNDROP_INTERIOR]);
    Streamer_ToggleItemStatic(STREAMER_TYPE_OBJECT,drop[E_GUNDROP_OBJECT],true);
    map_set_arr(s_GunDrops,id,drop);
    return id;
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
CMD:dropgun(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Player_IsReady(playerid) || !Weapons_IsLoaded(playerid))
    {
        return 1;
    }

    if (Weapons_Get(playerid,E_GUN_SLOT_HAND) == 0)
    {
        SendServerMessage(playerid,"You're not holding a weapon you can drop!",MSG_TYPE_ERROR);
        return 1;
    }

    if (Inventory_GetEquipped(playerid) != EQUIP_NONE)
    {
        SendServerMessage(playerid,"You can't do this with an inventory item. Unequip it to get rid of it.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Player_IsBusyWith(playerid,E_PLAYER_BUSY_HORSE))
    {
        SendServerMessage(playerid,"You're riding on a horse. Dismount first.",MSG_TYPE_ERROR);
        return 1;
    }

    new weapon = Weapons_Get(playerid,E_GUN_SLOT_HAND), ammo = Weapons_GetAmmo(playerid,E_GUN_SLOT_HAND), name[ACCOUNT_NAME_LEN], gun[WEAPON_NAME_LEN], line[200];
    Account_GetRoleplayName(playerid,name);
    Weapon_GetName(weapon,gun);
    format(line,sizeof(line),"* %s has dropped their %s on the floor.",name,gun);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
    new id = Weapons_DropGun(playerid);
    format(line,sizeof(line),"%s has dropped their %s with %d ammo. (ID: %d)",name,gun,ammo,id);
    Log_Info("guns/ammo","%s",line);
    SendServerMessage(playerid,"WARNING: Dropped guns do NOT save! Keep this in mind before leaving your gun alone.",MSG_TYPE_ERROR);
    Weapons_RemoveHand(playerid);
    pawn_call_public("Weapons_OnDropped","ddd",playerid,weapon,ammo);
    return 1;
}

ALT:dg=CMD:dropgun;

CMD:pickupgun(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Player_IsReady(playerid) || !Weapons_IsLoaded(playerid))
    {
        return 1;
    }

    if (Weapons_Get(playerid,E_GUN_SLOT_HAND) != 0)
    {
        SendServerMessage(playerid,"You're already holding a weapon!",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Weapons_IsCrouching(playerid))
    {
        SendServerMessage(playerid,"You need to crouch in order to pick up a weapon.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Player_IsBusyWith(playerid,E_PLAYER_BUSY_HORSE))
    {
        SendServerMessage(playerid,"You're riding on a horse. Dismount first.",MSG_TYPE_ERROR);
        return 1;
    }

    new id = Weapons_DropFindNear(playerid), drop[e_GUNDROP];

    if (id == 0 || !Weapons_DropGet(id,drop))
    {
        return 1;
    }

    if (!Weapons_Give(playerid,drop[E_GUNDROP_WEAPON],drop[E_GUNDROP_AMMO]))
    {
        return 1;
    }

    new name[ACCOUNT_NAME_LEN], gun[WEAPON_NAME_LEN], line[200];
    Account_GetRoleplayName(playerid,name);
    Weapon_GetName(drop[E_GUNDROP_WEAPON],gun);
    Weapons_DropRemove(id);
    format(line,sizeof(line),"* %s has picked up a %s from the floor.",name,gun);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
    format(line,sizeof(line),"%s has picked up a %s with %d ammo.",name,gun,drop[E_GUNDROP_AMMO]);
    Log_Info("guns/ammo","%s",line);
    return 1;
}

ALT:pg=CMD:pickupgun;

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
public Weapons_OnDropped(playerid,weapon,ammo)
{
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
    s_GunDrops = map_new();
}
