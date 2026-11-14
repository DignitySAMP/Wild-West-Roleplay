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
#define CORPSE_LIFETIME (600)
#define CORPSE_RANGE (2.5)
#define CORPSE_LABEL_COLOUR (0xBD1A1AFF)
#define CORPSE_LABEL_RANGE (20.0)

enum e_CORPSE
{
    E_CORPSE_OWNER,
    E_CORPSE_NAME[ACCOUNT_NAME_LEN],
    E_CORPSE_SKIN,
    Float:E_CORPSE_X,
    Float:E_CORPSE_Y,
    Float:E_CORPSE_Z,
    E_CORPSE_INTERIOR,
    E_CORPSE_WORLD,
    E_CORPSE_ACTOR,
    E_CORPSE_LABEL,
    E_CORPSE_EXPIRE,
}

static Map:s_Corpses;
static s_CorpseNext = 1;

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
stock Corpse_Count()
{
    return map_valid(s_Corpses) ? map_size(s_Corpses) : 0;
}

stock bool:Corpse_Get(corpseid,corpse[e_CORPSE])
{
    if (corpseid < 1 || !map_valid(s_Corpses) || !map_has_key(s_Corpses,corpseid))
    {
        return false;
    }

    map_get_arr(s_Corpses,corpseid,corpse);
    return true;
}

stock Corpse_Remove(corpseid)
{
    new corpse[e_CORPSE];

    if (!Corpse_Get(corpseid,corpse))
    {
        return;
    }

    if (corpse[E_CORPSE_ACTOR] != INVALID_ACTOR_ID)
    {
        DestroyActor(corpse[E_CORPSE_ACTOR]);
    }

    DestroyDynamic3DTextLabel(DynamicText3D:corpse[E_CORPSE_LABEL]);
    map_remove(s_Corpses,corpseid);
}

stock Corpse_RemoveOwned(owner)
{
    new ids[16], count = 0;

    if (!map_valid(s_Corpses))
    {
        return;
    }

    for (new Iter:it = map_iter(s_Corpses);iter_inside(it);iter_move_next(it))
    {
        new corpse[e_CORPSE];
        iter_get_arr(it,corpse);

        if (corpse[E_CORPSE_OWNER] == owner && count < sizeof(ids))
        {
            ids[count++] = iter_get_key(it);
        }
    }

    for (new i = 0;i < count;i++)
    {
        Corpse_Remove(ids[i]);
    }
}

stock Corpse_Create(playerid)
{
    new Float:x, Float:y, Float:z, Float:angle, corpse[e_CORPSE], name[ACCOUNT_NAME_LEN], text[64];
    GetPlayerPos(playerid,x,y,z);
    GetPlayerFacingAngle(playerid,angle);
    Corpse_RemoveOwned(Character_GetId(playerid));
    GetPlayerName(playerid,name,sizeof(name));
    corpse[E_CORPSE_OWNER] = Character_GetId(playerid);
    strcopy(corpse[E_CORPSE_NAME],name,ACCOUNT_NAME_LEN);
    corpse[E_CORPSE_SKIN] = GetPlayerSkin(playerid);
    corpse[E_CORPSE_X] = x;
    corpse[E_CORPSE_Y] = y;
    corpse[E_CORPSE_Z] = z;
    corpse[E_CORPSE_INTERIOR] = GetPlayerInterior(playerid);
    corpse[E_CORPSE_WORLD] = GetPlayerVirtualWorld(playerid);
    corpse[E_CORPSE_EXPIRE] = gettime() + CORPSE_LIFETIME;
    corpse[E_CORPSE_ACTOR] = CreateActor(corpse[E_CORPSE_SKIN],x,y,z,angle);

    if (corpse[E_CORPSE_ACTOR] != INVALID_ACTOR_ID)
    {
        SetActorVirtualWorld(corpse[E_CORPSE_ACTOR],corpse[E_CORPSE_WORLD]);
        ApplyActorAnimation(corpse[E_CORPSE_ACTOR],"crack","null",4.1,true,false,false,true,0);

        if (random(2) == 0)
        {
            ApplyActorAnimation(corpse[E_CORPSE_ACTOR],"crack","crckidle2",4.1,true,false,false,true,0);
        }
        else
        {
            ApplyActorAnimation(corpse[E_CORPSE_ACTOR],"crack","crckidle4",4.1,false,false,false,true,0);
        }
    }

    new rp[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,rp);
    format(text,sizeof(text),"[Corpse of %s]",rp);
    corpse[E_CORPSE_LABEL] = _:CreateDynamic3DTextLabel(text,CORPSE_LABEL_COLOUR,x,y,z - 0.25,CORPSE_LABEL_RANGE,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,corpse[E_CORPSE_WORLD],corpse[E_CORPSE_INTERIOR]);
    new corpseid = s_CorpseNext++;
    map_set_arr(s_Corpses,corpseid,corpse);
    return corpseid;
}

stock Corpse_FindNear(playerid)
{
    if (!map_valid(s_Corpses))
    {
        return 0;
    }

    for (new Iter:it = map_iter(s_Corpses);iter_inside(it);iter_move_next(it))
    {
        new corpse[e_CORPSE];
        iter_get_arr(it,corpse);

        if (corpse[E_CORPSE_INTERIOR] == GetPlayerInterior(playerid) && corpse[E_CORPSE_WORLD] == GetPlayerVirtualWorld(playerid) && IsPlayerInRangeOfPoint(playerid,CORPSE_RANGE,corpse[E_CORPSE_X],corpse[E_CORPSE_Y],corpse[E_CORPSE_Z]))
        {
            return iter_get_key(it);
        }
    }

    return 0;
}

stock Corpse_Sweep()
{
    new ids[32], count = 0, now = gettime();

    if (!map_valid(s_Corpses))
    {
        return;
    }

    for (new Iter:it = map_iter(s_Corpses);iter_inside(it);iter_move_next(it))
    {
        new corpse[e_CORPSE];
        iter_get_arr(it,corpse);

        if (corpse[E_CORPSE_EXPIRE] <= now && count < sizeof(ids))
        {
            ids[count++] = iter_get_key(it);
        }
    }

    for (new i = 0;i < count;i++)
    {
        Corpse_Remove(ids[i]);
    }
}

stock Corpse_InitPool()
{
    s_Corpses = map_new();
}

