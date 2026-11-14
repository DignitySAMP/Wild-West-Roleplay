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
#define POSTER_MAX (25)
#define POSTER_MODEL (19617)
#define POSTER_RANGE (2.5)
#define POSTER_CLAIM_RANGE (5.0)
#define POSTER_MAX_JAIL (127)
#define POSTER_NAME_LEN (24)
#define POSTER_TXD_MODEL (2611)
#define POSTER_CORPSE_MODEL (2805)

enum e_POSTER
{
    E_POSTER_NAME[POSTER_NAME_LEN],
    E_POSTER_SKIN,
    E_POSTER_PRICE,
    E_POSTER_JAIL,
    Float:E_POSTER_X,
    Float:E_POSTER_Y,
    Float:E_POSTER_Z,
    Float:E_POSTER_RX,
    Float:E_POSTER_RY,
    Float:E_POSTER_RZ,
    E_POSTER_WORLD,
    E_POSTER_INTERIOR,
    E_POSTER_OBJECT,
    E_POSTER_LABEL,
    E_POSTER_TARGET,
}

static Map:s_Posters;
static s_BountyPoster[MAX_PLAYERS] = {-1,...};
static s_BountyKill[MAX_PLAYERS] = {-1,...};
static bool:s_BountyCarrying[MAX_PLAYERS];
static s_PosterObject[MAX_PLAYERS];
static s_PosterName[MAX_PLAYERS][POSTER_NAME_LEN];
static s_PosterSkin[MAX_PLAYERS];
static s_PosterPrice[MAX_PLAYERS];
static s_PosterJail[MAX_PLAYERS];

forward Poster_Load();
forward Poster_OnBountyLoaded(playerid,token);
forward Poster_Deferred(playerid,token,flow,arg,const name[]);
forward Bounty_OnPickRequest(playerid);
forward Poster_FinishDeferred(playerid,token,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz);

enum _:E_POSTER_FLOW
{
    POSTER_FLOW_CREATE = 0,
    POSTER_FLOW_CLAIM,
}

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
stock Poster_Count()
{
    return map_valid(s_Posters) ? map_size(s_Posters) : 0;
}

stock bool:Poster_Exists(posterid)
{
    return posterid > 0 && map_valid(s_Posters) && map_has_key(s_Posters,posterid);
}

stock bool:Poster_Get(posterid,poster[e_POSTER])
{
    if (!Poster_Exists(posterid))
    {
        return false;
    }

    map_get_arr(s_Posters,posterid,poster);
    return true;
}

stock Iter:Poster_Iterator()
{
    return map_iter(s_Posters);
}

stock Poster_GetEditObject(playerid)
{
    return s_PosterObject[playerid];
}

stock Bounty_GetPoster(playerid)
{
    return s_BountyPoster[playerid];
}

stock bool:Bounty_IsCarrying(playerid)
{
    return s_BountyCarrying[playerid];
}

stock Poster_FindNear(playerid)
{
    if (!map_valid(s_Posters))
    {
        return 0;
    }

    for (new Iter:it = map_iter(s_Posters);iter_inside(it);iter_move_next(it))
    {
        new poster[e_POSTER];
        iter_get_arr(it,poster);

        if (poster[E_POSTER_INTERIOR] == GetPlayerInterior(playerid) && poster[E_POSTER_WORLD] == GetPlayerVirtualWorld(playerid) && IsPlayerInRangeOfPoint(playerid,POSTER_RANGE,poster[E_POSTER_X],poster[E_POSTER_Y],poster[E_POSTER_Z]))
        {
            return iter_get_key(it);
        }
    }

    return 0;
}

static Poster_FindTarget(const name[])
{
    foreach (new i : Player)
    {
        new current[ACCOUNT_NAME_LEN];
        GetPlayerName(i,current,sizeof(current));

        if (!strcmp(current,name,true))
        {
            return i;
        }
    }

    return INVALID_PLAYER_ID;
}

static Poster_Build(posterid,poster[e_POSTER])
{
    new text[96];
    poster[E_POSTER_OBJECT] = _:CreateDynamicObject(POSTER_MODEL,poster[E_POSTER_X],poster[E_POSTER_Y],poster[E_POSTER_Z],poster[E_POSTER_RX],poster[E_POSTER_RY],poster[E_POSTER_RZ],poster[E_POSTER_WORLD],poster[E_POSTER_INTERIOR]);
    SetDynamicObjectMaterial(STREAMER_TAG_OBJECT:poster[E_POSTER_OBJECT],0,POSTER_TXD_MODEL,"POLICE_PROPS_un","newspaper1");
    format(text,sizeof(text),"Wanted Poster (%d)\n%s\nPress ~k~~SNEAK_ABOUT~ to view",posterid,poster[E_POSTER_NAME]);
    poster[E_POSTER_LABEL] = _:CreateDynamic3DTextLabel(text,COLOR_DEFAULT,poster[E_POSTER_X],poster[E_POSTER_Y],poster[E_POSTER_Z],POSTER_RANGE,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,poster[E_POSTER_WORLD],poster[E_POSTER_INTERIOR]);
    poster[E_POSTER_TARGET] = Poster_FindTarget(poster[E_POSTER_NAME]);
    map_set_arr(s_Posters,posterid,poster);
}

stock Poster_Delete(posterid)
{
    new poster[e_POSTER];

    if (!Poster_Get(posterid,poster))
    {
        return;
    }

    DestroyDynamicObject(STREAMER_TAG_OBJECT:poster[E_POSTER_OBJECT]);
    DestroyDynamic3DTextLabel(DynamicText3D:poster[E_POSTER_LABEL]);
    map_remove(s_Posters,posterid);
    mysql_tquery_s(g_Mysql,str_format("DELETE FROM wanted_posters WHERE poster_id = %d",posterid));
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_bounty_id = -1 WHERE character_bounty_id = %d",posterid));

    foreach (new i : Player)
    {
        if (s_BountyPoster[i] == posterid)
        {
            s_BountyPoster[i] = -1;
            s_BountyKill[i] = -1;
            s_BountyCarrying[i] = false;
        }
    }
}

static Poster_Create(playerid)
{
    yield 1;

    new token = Account_GetToken(playerid);
    await mysql_aquery_s(g_Mysql,str_format("SELECT character_id FROM characters WHERE character_name = '%e'",s_PosterName[playerid]),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (cache_num_rows() < 1)
    {
        new line[128];
        format(line,sizeof(line),"The name %s wasn't found in the database. Try again or double check your input.",s_PosterName[playerid]);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    s_PosterObject[playerid] = _:CreateDynamicObject(POSTER_MODEL,x,y,z,0.0,0.0,0.0,GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid));
    SetDynamicObjectMaterial(STREAMER_TAG_OBJECT:s_PosterObject[playerid],0,POSTER_TXD_MODEL,"POLICE_PROPS_un","newspaper1");
    EditDynamicObject(playerid,STREAMER_TAG_OBJECT:s_PosterObject[playerid]);
}

static Poster_Finish(playerid,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
    yield 1;

    new token = Account_GetToken(playerid), world = GetPlayerVirtualWorld(playerid), interior = GetPlayerInterior(playerid);
    new name[POSTER_NAME_LEN], skin = s_PosterSkin[playerid], price = s_PosterPrice[playerid], jail = s_PosterJail[playerid];
    strcopy(name,s_PosterName[playerid],POSTER_NAME_LEN);

    if (!Money_Take(playerid,Money_Make(price)))
    {
        SendServerMessage(playerid,"You don't have enough money to offer this bounty.",MSG_TYPE_ERROR);
        return;
    }

    await mysql_aquery_s(g_Mysql,str_format("INSERT INTO wanted_posters (poster_name, poster_skin, poster_price, poster_jailtime, poster_vw, poster_int, poster_x, poster_y, poster_z, poster_rx, poster_ry, poster_rz) VALUES ('%e', %d, %d, %d, %d, %d, %f, %f, %f, %f, %f, %f)",name,skin,price,jail,world,interior,x,y,z,rx,ry,rz),false);
    new posterid = cache_insert_id();

    if (!Account_IsCurrent(playerid,token) || posterid <= 0)
    {
        return;
    }

    new poster[e_POSTER], line[160], whole[16];
    strcopy(poster[E_POSTER_NAME],name,POSTER_NAME_LEN);
    poster[E_POSTER_SKIN] = skin;
    poster[E_POSTER_PRICE] = price;
    poster[E_POSTER_JAIL] = jail;
    poster[E_POSTER_X] = x;
    poster[E_POSTER_Y] = y;
    poster[E_POSTER_Z] = z;
    poster[E_POSTER_RX] = rx;
    poster[E_POSTER_RY] = ry;
    poster[E_POSTER_RZ] = rz;
    poster[E_POSTER_WORLD] = world;
    poster[E_POSTER_INTERIOR] = interior;
    Poster_Build(posterid,poster);
    Money_Delimit(price,whole);
    format(line,sizeof(line),"You offered a bounty of $%s for the capture of %s.",whole,name);
    SendServerMessage(playerid,line,MSG_TYPE_WARN);
}

stock bool:Bounty_PickCorpse(playerid,const targetName[])
{
    new poster[e_POSTER];

    if (s_BountyPoster[playerid] < 1 || !Poster_Get(s_BountyPoster[playerid],poster) || strcmp(poster[E_POSTER_NAME],targetName,true))
    {
        return false;
    }

    SetPlayerAttachedObject(playerid,WEAPON_SLOT_BACK,POSTER_CORPSE_MODEL,1,-0.0369,-0.2309,0.000,89.30001,93.099937,-94.300071,0.885999,0.746999,1.055000);
    s_BountyKill[playerid] = 1;
    s_BountyCarrying[playerid] = true;
    return true;
}

static Bounty_Reset(playerid)
{
    s_BountyKill[playerid] = -1;

    if (s_BountyCarrying[playerid])
    {
        s_BountyCarrying[playerid] = false;
        RemovePlayerAttachedObject(playerid,WEAPON_SLOT_BACK);
        Weapons_Attachments(playerid);
    }
}

static Bounty_Claim(playerid)
{
    new posterid = s_BountyPoster[playerid], poster[e_POSTER], whole[16], line[160];

    if (posterid < 1 || !Poster_Get(posterid,poster))
    {
        SendServerMessage(playerid,"You haven't accepted a bounty!",MSG_TYPE_ERROR);
        return;
    }

    if (s_BountyKill[playerid] == -1)
    {
        new target = poster[E_POSTER_TARGET];

        if (target == INVALID_PLAYER_ID || !Staff_IsValidTarget(target))
        {
            SendServerMessage(playerid,"Your bounty doesn't seem to be online at the moment, or they are desynced.",MSG_TYPE_ERROR);
            return;
        }

        if (target == playerid)
        {
            SendServerMessage(playerid,"You can't claim the bounty on yourself.",MSG_TYPE_ERROR);
            return;
        }

        if (Point_FindService(playerid,POINT_BIZ_SHERIFF) == 0)
        {
            SendServerMessage(playerid,"You are not in a sheriff's office!",MSG_TYPE_ERROR);
            return;
        }

        new Float:x, Float:y, Float:z;
        GetPlayerPos(target,x,y,z);

        if (!IsPlayerInRangeOfPoint(playerid,POSTER_CLAIM_RANGE,x,y,z))
        {
            SendServerMessage(playerid,"You're not near your bounty.",MSG_TYPE_ERROR);
            return;
        }

        SendServerMessage(target,"You've been put in jail for your bounty.",MSG_TYPE_INFO);
        Prison_Start(target,poster[E_POSTER_JAIL],0);
    }
    else
    {
        if (!s_BountyCarrying[playerid])
        {
            SendServerMessage(playerid,"You need to be carrying the corpse.",MSG_TYPE_ERROR);
            return;
        }

        if (Point_FindService(playerid,POINT_BIZ_SHERIFF) == 0)
        {
            SendServerMessage(playerid,"You are not in a sheriff's office!",MSG_TYPE_ERROR);
            return;
        }
    }

    Money_Give(playerid,Money_Make(poster[E_POSTER_PRICE]));
    Money_Delimit(poster[E_POSTER_PRICE],whole);
    format(line,sizeof(line),"You've been paid $%s for the bounty.",whole);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Bounty_Reset(playerid);
    Poster_Delete(posterid);
}

public Poster_Deferred(playerid,token,flow,arg,const name[])
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    switch (flow)
    {
        case POSTER_FLOW_CREATE:
        {
            Poster_Create(playerid);
        }
    }

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
CMD:poster(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new name[POSTER_NAME_LEN], skin, price, jail;

    if (sscanf(params,"iiis[24]",skin,price,jail,name))
    {
        SendClientMessage(playerid,-1,"/poster [skin] [price] [jailtime] [name]");
        return 1;
    }

    if (skin < 0 || skin == 74 || skin > 20999)
    {
        SendClientMessage(playerid,-1,"You must pick a valid skin!");
        return 1;
    }

    if (price < 1)
    {
        SendServerMessage(playerid,"A bounty needs a reward of at least $1.",MSG_TYPE_ERROR);
        return 1;
    }

    if (jail < 1 || jail > POSTER_MAX_JAIL)
    {
        SendServerMessage(playerid,"The jail time has to be between 1 and 127 minutes.",MSG_TYPE_ERROR);
        return 1;
    }

    if (price > MONEY_MAX_DOLLARS || !Money_CanAfford(playerid,Money_Make(price)))
    {
        SendServerMessage(playerid,"You don't have enough money to offer this bounty.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Poster_Count() >= POSTER_MAX)
    {
        SendServerMessage(playerid,"There was an error creating the wanted poster (returned -1), contact a dev.",MSG_TYPE_ERROR);
        return 1;
    }

    strcopy(s_PosterName[playerid],name,POSTER_NAME_LEN);
    s_PosterSkin[playerid] = skin;
    s_PosterPrice[playerid] = price;
    s_PosterJail[playerid] = jail;
    SetTimerEx("Poster_Deferred",0,false,"dddds",playerid,Account_GetToken(playerid),POSTER_FLOW_CREATE,0,"");
    return 1;
}

CMD:removeposter(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new posterid;

    if (sscanf(params,"D(-1)",posterid))
    {
        SendServerMessage(playerid,"/removeposter [optional:posterid]",MSG_TYPE_ERROR);
        return 1;
    }

    new bool:staff = Staff_IsModerator(playerid);

    if (!staff && !Posse_IsLawMember(playerid))
    {
        SendServerMessage(playerid,"You have to be in a police posse in order to do this command.",MSG_TYPE_INFO);
        return 1;
    }

    new near = Poster_FindNear(playerid);

    if (posterid == -1)
    {
        posterid = near;
    }

    if (!Poster_Exists(posterid) || (!staff && posterid != near))
    {
        SendServerMessage(playerid,"You're not near a wanted poster.",MSG_TYPE_ERROR);
        return 1;
    }

    Poster_Delete(posterid);
    SendServerMessage(playerid,"You've removed the wanted poster.",MSG_TYPE_INFO);
    return 1;
}

CMD:takebounty(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (s_BountyPoster[playerid] != -1)
    {
        SendServerMessage(playerid,"You've already accepted a bounty!",MSG_TYPE_ERROR);
        return 1;
    }

    new posterid = Poster_FindNear(playerid), poster[e_POSTER], line[128];

    if (posterid == 0 || !Poster_Get(posterid,poster))
    {
        SendServerMessage(playerid,"You're not near a wanted poster.",MSG_TYPE_ERROR);
        return 1;
    }

    if (poster[E_POSTER_TARGET] == playerid)
    {
        SendServerMessage(playerid,"You can't take the bounty on yourself.",MSG_TYPE_ERROR);
        return 1;
    }

    s_BountyPoster[playerid] = posterid;
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_bounty_id = %d WHERE character_id = %d",posterid,Character_GetId(playerid)));
    format(line,sizeof(line),"You've accepted the bounty on %s.",poster[E_POSTER_NAME]);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
}

CMD:abandonbounty(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (s_BountyPoster[playerid] == -1)
    {
        SendServerMessage(playerid,"You haven't accepted a bounty!",MSG_TYPE_ERROR);
        return 1;
    }

    s_BountyPoster[playerid] = -1;
    Bounty_Reset(playerid);
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_bounty_id = -1 WHERE character_id = %d",Character_GetId(playerid)));
    SendServerMessage(playerid,"You've abandoned your current bounty.",MSG_TYPE_INFO);
    return 1;
}

CMD:claimbounty(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    Bounty_Claim(playerid);
    return 1;
}

CMD:pickbounty(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (s_BountyPoster[playerid] == -1)
    {
        SendServerMessage(playerid,"You haven't accepted a bounty!",MSG_TYPE_ERROR);
        return 1;
    }

    pawn_call_public("Bounty_OnPickRequest","d",playerid);
    return 1;
}

public Bounty_OnPickRequest(playerid)
{
    return 1;
}

#pragma warning push
#pragma warning disable 204
public Poster_Load()
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_new("SELECT poster_id, poster_name, poster_skin, poster_price, poster_jailtime, poster_vw, poster_int, poster_x, poster_y, poster_z, poster_rx, poster_ry, poster_rz FROM wanted_posters"),false);

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, poster[e_POSTER];
        cache_get_value_name_int(i,"poster_id",id);
        cache_get_value_name(i,"poster_name",poster[E_POSTER_NAME],POSTER_NAME_LEN);
        cache_get_value_name_int(i,"poster_skin",poster[E_POSTER_SKIN]);
        cache_get_value_name_int(i,"poster_price",poster[E_POSTER_PRICE]);
        cache_get_value_name_int(i,"poster_jailtime",poster[E_POSTER_JAIL]);
        cache_get_value_name_int(i,"poster_vw",poster[E_POSTER_WORLD]);
        cache_get_value_name_int(i,"poster_int",poster[E_POSTER_INTERIOR]);
        cache_get_value_name_float(i,"poster_x",poster[E_POSTER_X]);
        cache_get_value_name_float(i,"poster_y",poster[E_POSTER_Y]);
        cache_get_value_name_float(i,"poster_z",poster[E_POSTER_Z]);
        cache_get_value_name_float(i,"poster_rx",poster[E_POSTER_RX]);
        cache_get_value_name_float(i,"poster_ry",poster[E_POSTER_RY]);
        cache_get_value_name_float(i,"poster_rz",poster[E_POSTER_RZ]);

        if (id < 1 || Poster_Exists(id))
        {
            continue;
        }

        Poster_Build(id,poster);
    }

    Boot_LoaderDone();
    return 1;
}
#pragma warning pop

public Poster_OnBountyLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    s_BountyPoster[playerid] = -1;

    if (cache_num_rows() > 0)
    {
        new id = -1;
        cache_get_value_name_int(0,"character_bounty_id",id);

        if (Poster_Exists(id))
        {
            s_BountyPoster[playerid] = id;
        }
    }

    new name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));

    for (new Iter:it = map_iter(s_Posters);iter_inside(it);iter_move_next(it))
    {
        new poster[e_POSTER];
        iter_get_arr(it,poster);

        if (!strcmp(poster[E_POSTER_NAME],name,true))
        {
            poster[E_POSTER_TARGET] = playerid;
            map_set_arr(s_Posters,iter_get_key(it),poster);
        }
    }

    return 1;
}

stock Poster_InitPool()
{
    s_Posters = map_new();
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

hook OnPlayerConnect(playerid)
{
    s_BountyPoster[playerid] = -1;
    s_BountyKill[playerid] = -1;
    s_BountyCarrying[playerid] = false;
    s_PosterObject[playerid] = 0;
}

hook OnPlayerDisconnect(playerid,reason)
{
    if (s_PosterObject[playerid] != 0)
    {
        DestroyDynamicObject(STREAMER_TAG_OBJECT:s_PosterObject[playerid]);
        s_PosterObject[playerid] = 0;
    }

    for (new Iter:it = map_iter(s_Posters);iter_inside(it);iter_move_next(it))
    {
        new poster[e_POSTER];
        iter_get_arr(it,poster);

        if (poster[E_POSTER_TARGET] == playerid)
        {
            poster[E_POSTER_TARGET] = INVALID_PLAYER_ID;
            map_set_arr(s_Posters,iter_get_key(it),poster);
        }
    }
}

hook Character_OnLoad(playerid,characterid)
{
    mysql_tquery_s(g_Mysql,str_format("SELECT character_bounty_id FROM characters WHERE character_id = %d",characterid),"Poster_OnBountyLoaded","dd",playerid,Account_GetToken(playerid));
}

hook OnPlayerEditDynamicObject(playerid,STREAMER_TAG_OBJECT:objectid,response,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
    if (s_PosterObject[playerid] == 0 || s_PosterObject[playerid] != _:objectid || response == 2)
    {
        return;
    }

    DestroyDynamicObject(objectid);
    s_PosterObject[playerid] = 0;

    if (response == 1)
    {
        SetTimerEx("Poster_FinishDeferred",0,false,"ddffffff",playerid,Account_GetToken(playerid),x,y,z,rx,ry,rz);
    }
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (!(newkeys & KEY_WALK))
    {
        return;
    }

    new posterid = Poster_FindNear(playerid), poster[e_POSTER];

    if (posterid == 0 || !Poster_Get(posterid,poster))
    {
        return;
    }

    if (Inventory_GuiIsOpen(playerid))
    {
        SendServerMessage(playerid,"You can't view a wanted poster when your inventory is enabled!",MSG_TYPE_ERROR);
        return;
    }

    PosterGui_Show(playerid,poster[E_POSTER_NAME],poster[E_POSTER_SKIN],poster[E_POSTER_PRICE]);
}

public Poster_FinishDeferred(playerid,token,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
    if (Account_IsCurrent(playerid,token))
    {
        Poster_Finish(playerid,x,y,z,rx,ry,rz);
    }

    return 1;
}
