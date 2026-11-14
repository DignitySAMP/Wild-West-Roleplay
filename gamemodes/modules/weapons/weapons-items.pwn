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
#define DYNAMITE_MIN (5)
#define DYNAMITE_MAX (30)
#define DYNAMITE_RANGE (25.0)
#define DYNAMITE_MODEL (1654)
#define DYNAMITE_COLOUR (0xDB3232FF)

enum e_DYNAMITE
{
    E_DYNAMITE_OBJECT,
    E_DYNAMITE_LABEL,
    E_DYNAMITE_SECONDS,
    Float:E_DYNAMITE_X,
    Float:E_DYNAMITE_Y,
    Float:E_DYNAMITE_Z,
    E_DYNAMITE_INTERIOR,
    E_DYNAMITE_WORLD,
}

static Map:s_Dynamites;
static s_DynamiteNext = 1;

forward Weapons_UseAmmo(playerid,uid,item,extra);
forward Dynamite_OnBlast(playerid,Float:x,Float:y,Float:z);
forward Dynamite_OnExploded(id,Float:x,Float:y,Float:z);

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
stock Dynamite_Count()
{
    return map_valid(s_Dynamites) ? map_size(s_Dynamites) : 0;
}

stock Dynamite_GetSeconds(id)
{
    if (!map_valid(s_Dynamites) || !map_has_key(s_Dynamites,id))
    {
        return -1;
    }

    return map_get(s_Dynamites,id,_:E_DYNAMITE_SECONDS);
}

stock bool:Weapons_GiveAmmoCrate(playerid,kind)
{
    new extra = kind == 0 ? E_ITEM_EXTRA_AMMO_CRATE_PISTOL : (kind == 1 ? E_ITEM_EXTRA_AMMO_CRATE_SHOTGUN : E_ITEM_EXTRA_AMMO_CRATE_RIFLE);
    return Inventory_GiveByParam(playerid,E_ITEM_PARAM_AMMO,extra,1);
}

static Dynamite_Label(id,seconds,dest[],size)
{
    format(dest,size,"[DYNAMITE: %d]\n{DEDEDE}%d seconds left\nuntil explosion.",id,seconds);
}

stock Dynamite_Plant(playerid,seconds)
{
    new Float:x, Float:y, Float:z, Float:angle;
    GetPlayerPos(playerid,x,y,z);
    GetPlayerFacingAngle(playerid,angle);
    x -= 2.0 * floatsin(angle,degrees);
    y += 2.0 * floatcos(angle,degrees);

    new item[e_DYNAMITE], id = s_DynamiteNext++, label[96];
    item[E_DYNAMITE_SECONDS] = seconds;
    item[E_DYNAMITE_X] = x;
    item[E_DYNAMITE_Y] = y;
    item[E_DYNAMITE_Z] = z - 0.8;
    item[E_DYNAMITE_INTERIOR] = GetPlayerInterior(playerid);
    item[E_DYNAMITE_WORLD] = GetPlayerVirtualWorld(playerid);
    item[E_DYNAMITE_OBJECT] = _:CreateDynamicObject(DYNAMITE_MODEL,x,y,z - 0.8,0.0,0.0,0.0,item[E_DYNAMITE_WORLD],item[E_DYNAMITE_INTERIOR]);
    Dynamite_Label(id,seconds,label,sizeof(label));
    item[E_DYNAMITE_LABEL] = _:CreateDynamic3DTextLabel(label,DYNAMITE_COLOUR,x,y,z - 0.8,20.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,item[E_DYNAMITE_WORLD],item[E_DYNAMITE_INTERIOR]);
    map_set_arr(s_Dynamites,id,item);
    return id;
}

static Dynamite_Detonate(id)
{
    new item[e_DYNAMITE];
    map_get_arr(s_Dynamites,id,item);
    CreateExplosion(item[E_DYNAMITE_X],item[E_DYNAMITE_Y],item[E_DYNAMITE_Z],2,DYNAMITE_RANGE);

    foreach (new playerid : Player)
    {
        if (GetPlayerInterior(playerid) != item[E_DYNAMITE_INTERIOR] || GetPlayerVirtualWorld(playerid) != item[E_DYNAMITE_WORLD] || !IsPlayerInRangeOfPoint(playerid,DYNAMITE_RANGE,item[E_DYNAMITE_X],item[E_DYNAMITE_Y],item[E_DYNAMITE_Z]))
        {
            continue;
        }

        pawn_call_public("Dynamite_OnBlast","dfff",playerid,item[E_DYNAMITE_X],item[E_DYNAMITE_Y],item[E_DYNAMITE_Z]);
    }

    pawn_call_public("Dynamite_OnExploded","dfff",id,item[E_DYNAMITE_X],item[E_DYNAMITE_Y],item[E_DYNAMITE_Z]);

    if (IsValidDynamicObject(STREAMER_TAG_OBJECT:item[E_DYNAMITE_OBJECT]))
    {
        DestroyDynamicObject(STREAMER_TAG_OBJECT:item[E_DYNAMITE_OBJECT]);
    }

    if (IsValidDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:item[E_DYNAMITE_LABEL]))
    {
        DestroyDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:item[E_DYNAMITE_LABEL]);
    }

    map_remove(s_Dynamites,id);
}

stock Dynamite_Tick()
{
    new ids[64], count = 0;

    for (new Iter:it = map_iter(s_Dynamites);iter_inside(it);iter_move_next(it))
    {
        if (count < sizeof(ids))
        {
            ids[count++] = iter_get_key(it);
        }
    }

    for (new i = 0;i < count;i++)
    {
        new item[e_DYNAMITE];
        map_get_arr(s_Dynamites,ids[i],item);
        item[E_DYNAMITE_SECONDS]--;

        if (item[E_DYNAMITE_SECONDS] <= 0)
        {
            Dynamite_Detonate(ids[i]);
            continue;
        }

        new label[96];
        Dynamite_Label(ids[i],item[E_DYNAMITE_SECONDS],label,sizeof(label));
        UpdateDynamic3DTextLabelText(STREAMER_TAG_3D_TEXT_LABEL:item[E_DYNAMITE_LABEL],DYNAMITE_COLOUR,label);
        map_set_arr(s_Dynamites,ids[i],item);
    }
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
CMD:ammocrate(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    SendServerMessage(playerid,"This feature is deprecated! You need to use ammo crates through your inventory!",MSG_TYPE_ERROR);
    return 1;
}

CMD:dynamite(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (Inventory_GetEquipped(playerid) != E_ITEM_EXTRA_DYNAMITE)
    {
        SendServerMessage(playerid,"You need to have your dynamite equipped before you can do this.",MSG_TYPE_ERROR);
        return 1;
    }

    new seconds;

    if (sscanf(params,"i",seconds))
    {
        SendServerMessage(playerid,"/dynamite [time]",MSG_TYPE_ERROR);
        return 1;
    }

    if (seconds < DYNAMITE_MIN || seconds > DYNAMITE_MAX)
    {
        SendServerMessage(playerid,"Dynamite timer can't be lower than 5 seconds or higher than 30.",MSG_TYPE_ERROR);
        return 1;
    }

    new uid = Inventory_GetEquippedUid(playerid), index = Inventory_IndexOfUid(playerid,uid), line[128], name[ACCOUNT_NAME_LEN];
    Dynamite_Plant(playerid,seconds);
    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.1,false,false,false,false,0,SYNC_ALL);
    format(line,sizeof(line),"Your dynamite has been set. It will explode in %d seconds.",seconds);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Account_GetRoleplayName(playerid,name);
    format(line,sizeof(line),"* %s has planted a set of dynamite.",name);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
    Inventory_Unequip(playerid,false);

    if (index != INV_ROW_NONE)
    {
        new row[e_INV_ROW];
        Inventory_GetRow(playerid,index,row);

        if (row[E_INV_ROW_AMOUNT] <= 1)
        {
            Inventory_Remove(playerid,index);
            SendServerMessage(playerid,"You've used your last set of dynamite.",MSG_TYPE_WARN);
        }
        else
        {
            Inventory_Decrease(playerid,index,1);
        }
    }

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
public Weapons_UseAmmo(playerid,uid,item,extra)
{
    new index = Inventory_IndexOfUid(playerid,uid), hand = Weapons_Get(playerid,E_GUN_SLOT_HAND), refill = 0, kind[16];

    if (index == INV_ROW_NONE)
    {
        return 1;
    }

    switch (extra)
    {
        case E_ITEM_EXTRA_AMMO_CRATE_PISTOL, E_ITEM_EXTRA_FACTION_AMMO_PISTOL:
        {
            if (hand != 24)
            {
                SendServerMessage(playerid,"You need to have a pistol equipped in order to do this.",MSG_TYPE_ERROR);
                return 1;
            }

            refill = 6;
            strcopy(kind,"revolver");
        }
        case E_ITEM_EXTRA_AMMO_CRATE_SHOTGUN, E_ITEM_EXTRA_FACTION_AMMO_SHOTGUN:
        {
            if (hand != 25 && hand != 26)
            {
                SendServerMessage(playerid,"You need to have a shotgun equipped in order to do this.",MSG_TYPE_ERROR);
                return 1;
            }

            refill = hand == 25 ? 8 : 2;
            strcopy(kind,"shotgun");
        }
        default:
        {
            if (hand != 33 && hand != 34)
            {
                SendServerMessage(playerid,"You need to have a rifle equipped in order to do this.",MSG_TYPE_ERROR);
                return 1;
            }

            refill = 5;
            strcopy(kind,"rifle");
        }
    }

    if (Weapons_GetAmmo(playerid,E_GUN_SLOT_HAND) > 0)
    {
        SendServerMessage(playerid,"Your equipped weapon still has ammo left. Only use this when you have none. ",MSG_TYPE_ERROR);
        return 1;
    }

    new line[160], name[ACCOUNT_NAME_LEN];
    Weapons_RemoveHand(playerid);
    Weapons_Give(playerid,hand,refill);
    Account_GetRoleplayName(playerid,name);
    format(line,sizeof(line),"* %s used an ammo pack for their %s.",name,kind);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
    format(line,sizeof(line),"You've used an ammopack on your %s and refilled it with ammo.",kind);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Weapons_Attachments(playerid);
    index = Inventory_IndexOfUid(playerid,uid);

    if (index != INV_ROW_NONE)
    {
        Inventory_Decrease(playerid,index,1);
    }

    return 1;
}

public Dynamite_OnBlast(playerid,Float:x,Float:y,Float:z)
{
    return 1;
}

public Dynamite_OnExploded(id,Float:x,Float:y,Float:z)
{
    return 1;
}

Timer_Declare(Dynamite_TickTimer)
{

    Dynamite_Tick();
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
    s_Dynamites = map_new();
    Timer_Start(Dynamite_TickTimer,1000);
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_AMMO_CRATE_PISTOL,"Weapons_UseAmmo");
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_AMMO_CRATE_SHOTGUN,"Weapons_UseAmmo");
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_AMMO_CRATE_RIFLE,"Weapons_UseAmmo");
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_FACTION_AMMO_PISTOL,"Weapons_UseAmmo");
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_FACTION_AMMO_SHOTGUN,"Weapons_UseAmmo");
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_FACTION_AMMO_RIFLE,"Weapons_UseAmmo");
}

hook Inventory_OnEquip(playerid,extra,bool:equipped)
{
    if (extra != E_ITEM_EXTRA_CAMERA)
    {
        return;
    }

    ResetPlayerWeapons(playerid);

    if (equipped)
    {
        GivePlayerWeapon(playerid,WEAPON_CAMERA,5);
    }
}
