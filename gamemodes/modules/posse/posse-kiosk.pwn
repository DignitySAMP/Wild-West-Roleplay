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
#define KIOSK_MODEL (18885)
#define KIOSK_RANGE (3.5)
#define KIOSK_OFFSET (2.5)
#define KIOSK_HANDCUFFS (4)
#define KIOSK_WEAPONS (3)

enum e_KIOSK
{
    Float:E_KIOSK_X,
    Float:E_KIOSK_Y,
    Float:E_KIOSK_Z,
    Float:E_KIOSK_RX,
    Float:E_KIOSK_RY,
    Float:E_KIOSK_RZ,
    E_KIOSK_LOCKED,
    E_KIOSK_OBJECT,
}

enum e_KIOSK_GUN
{
    E_KIOSK_GUN_NAME[24],
    E_KIOSK_GUN_PRICE,
    E_KIOSK_GUN_WEAPON,
    E_KIOSK_GUN_AMMO,
}

static const s_KioskGuns[KIOSK_WEAPONS][e_KIOSK_GUN] =
{
    {"Revolver",50,24,E_ITEM_EXTRA_FACTION_AMMO_PISTOL},
    {"Shotgun",120,25,E_ITEM_EXTRA_FACTION_AMMO_SHOTGUN},
    {"Repeater Rifle",100,33,E_ITEM_EXTRA_FACTION_AMMO_RIFLE}
};

static Map:s_Kiosks;
static bool:s_KioskCreating[MAX_PLAYERS];
static bool:s_KioskDuty[MAX_PLAYERS];

forward Kiosk_Load();
forward Kiosk_MenuDeferred(playerid,token);

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
stock bool:Kiosk_IsOnDuty(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_KioskDuty[playerid];
}

stock Kiosk_SetDuty(playerid,bool:duty)
{
    s_KioskDuty[playerid] = duty;
}

stock bool:Kiosk_Get(posseid,kiosk[e_KIOSK])
{
    if (!map_valid(s_Kiosks) || !map_has_key(s_Kiosks,posseid))
    {
        return false;
    }

    map_get_arr(s_Kiosks,posseid,kiosk);
    return true;
}

static Kiosk_Put(posseid,const kiosk[e_KIOSK])
{
    map_set_arr(s_Kiosks,posseid,kiosk);
}

stock bool:Kiosk_IsPlaced(posseid)
{
    new kiosk[e_KIOSK];
    return Kiosk_Get(posseid,kiosk) && kiosk[E_KIOSK_OBJECT] != 0;
}

stock bool:Kiosk_IsNear(playerid,posseid)
{
    new kiosk[e_KIOSK];
    return Kiosk_Get(posseid,kiosk) && kiosk[E_KIOSK_OBJECT] != 0 && IsPlayerInRangeOfPoint(playerid,KIOSK_RANGE,kiosk[E_KIOSK_X],kiosk[E_KIOSK_Y],kiosk[E_KIOSK_Z]);
}

stock Kiosk_GetPrice(index)
{
    return index >= 0 && index < KIOSK_WEAPONS ? s_KioskGuns[index][E_KIOSK_GUN_PRICE] : 0;
}

stock Kiosk_GetCreating(playerid)
{
    return s_KioskCreating[playerid];
}

static Kiosk_Save(posseid,const kiosk[e_KIOSK])
{
    mysql_tquery_s(g_Mysql,str_format("INSERT INTO possekiosk (kiosk_id, kiosk_x, kiosk_y, kiosk_z, kiosk_rx, kiosk_ry, kiosk_rz, kiosk_locked) VALUES (%d, %f, %f, %f, %f, %f, %f, 0) ON DUPLICATE KEY UPDATE kiosk_x = VALUES(kiosk_x), kiosk_y = VALUES(kiosk_y), kiosk_z = VALUES(kiosk_z), kiosk_rx = VALUES(kiosk_rx), kiosk_ry = VALUES(kiosk_ry), kiosk_rz = VALUES(kiosk_rz)",posseid,kiosk[E_KIOSK_X],kiosk[E_KIOSK_Y],kiosk[E_KIOSK_Z],kiosk[E_KIOSK_RX],kiosk[E_KIOSK_RY],kiosk[E_KIOSK_RZ]));
}

stock Kiosk_Remove(posseid)
{
    new kiosk[e_KIOSK];

    if (!Kiosk_Get(posseid,kiosk))
    {
        return;
    }

    if (kiosk[E_KIOSK_OBJECT] != 0)
    {
        DestroyDynamicObject(STREAMER_TAG_OBJECT:kiosk[E_KIOSK_OBJECT]);
    }

    map_remove(s_Kiosks,posseid);
}

stock Kiosk_Place(posseid,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
    new kiosk[e_KIOSK];
    Kiosk_Get(posseid,kiosk);

    if (kiosk[E_KIOSK_OBJECT] != 0)
    {
        DestroyDynamicObject(STREAMER_TAG_OBJECT:kiosk[E_KIOSK_OBJECT]);
    }

    kiosk[E_KIOSK_X] = x;
    kiosk[E_KIOSK_Y] = y;
    kiosk[E_KIOSK_Z] = z;
    kiosk[E_KIOSK_RX] = rx;
    kiosk[E_KIOSK_RY] = ry;
    kiosk[E_KIOSK_RZ] = rz;
    kiosk[E_KIOSK_OBJECT] = _:CreateDynamicObject(KIOSK_MODEL,x,y,z,rx,ry,rz);
    Kiosk_Put(posseid,kiosk);
    Kiosk_Save(posseid,kiosk);
}

static Kiosk_Say(playerid,posseid,const what[])
{
    new rank[POSSE_RANK_LEN], name[ACCOUNT_NAME_LEN], line[160];
    Posse_GetRank(playerid,rank);
    Posse_DisplayName(playerid,false,name);
    format(line,sizeof(line),"{[ %s %s %s ]}",rank,name,what);
    Posse_Warning(posseid,line);
}

static Kiosk_StripLaw(playerid)
{
    new extras[5] = {E_ITEM_EXTRA_RADIO,E_ITEM_EXTRA_SHERIFF_HANDCUFFS,E_ITEM_EXTRA_SHERIFF_LASSO,E_ITEM_EXTRA_SHERIFF_BADGE,E_ITEM_EXTRA_FEDERAL_BADGE};

    for (new i = 0;i < sizeof(extras);i++)
    {
        new total = Inventory_GetExtraTotal(playerid,extras[i]);

        if (total > 0)
        {
            Inventory_DecreaseExtra(playerid,extras[i],total,false);
        }
    }
}

stock Kiosk_StripLawItems(playerid)
{
    new extras[4] = {E_ITEM_EXTRA_RADIO,E_ITEM_EXTRA_SHERIFF_HANDCUFFS,E_ITEM_EXTRA_SHERIFF_BADGE,E_ITEM_EXTRA_FEDERAL_BADGE};

    for (new i = 0;i < sizeof(extras);i++)
    {
        new total = Inventory_GetExtraTotal(playerid,extras[i]);

        if (total > 0)
        {
            Inventory_DecreaseExtra(playerid,extras[i],total,false);
        }
    }
}

static Kiosk_Duty(playerid,posseid)
{
    new posse[e_POSSE];
    Posse_Get(posseid,posse);

    if (!s_KioskDuty[playerid])
    {
        new female = Character_GetGender(playerid) != 0, leader = Posse_GetTier(playerid) == POSSE_TIER_LEADER, skin;

        if (posse[E_POSSE_TYPE] == POSSE_TYPE_LAW)
        {
            skin = female ? 309 : (leader ? 288 : 311);
        }
        else
        {
            skin = female ? (leader ? 150 : 194) : (leader ? 147 : 295);
        }

        SetPlayerSkin(playerid,skin);
        Inventory_GiveByParam(playerid,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_SHERIFF_HANDCUFFS,KIOSK_HANDCUFFS);
        Inventory_GiveByParam(playerid,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_RADIO,1);
        Inventory_GiveByParam(playerid,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_SHERIFF_LASSO,1);
        Inventory_GiveByParam(playerid,E_ITEM_PARAM_UNDEFINED,posse[E_POSSE_TYPE] == POSSE_TYPE_LAW ? E_ITEM_EXTRA_SHERIFF_BADGE : E_ITEM_EXTRA_FEDERAL_BADGE,1);
    }
    else
    {
        SetPlayerSkin(playerid,Character_GetSkin(playerid));
        Kiosk_StripLaw(playerid);
    }

    s_KioskDuty[playerid] = !s_KioskDuty[playerid];
    Kiosk_Say(playerid,posseid,s_KioskDuty[playerid] ? ("has went on duty.") : ("has went off duty."));
}

static Kiosk_Take(playerid,posseid)
{
    yield 1;

    new body[160], token = Account_GetToken(playerid), response[DIALOG_RESPONSE];

    for (new i = 0;i < KIOSK_WEAPONS;i++)
    {
        format(body,sizeof(body),"%s%s - $%d\n",body,s_KioskGuns[i][E_KIOSK_GUN_NAME],s_KioskGuns[i][E_KIOSK_GUN_PRICE]);
    }

    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"Kiosk List",body,"Buy","Cancel");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE] || Posse_GetPlayer(playerid) != posseid || !Kiosk_IsNear(playerid,posseid))
    {
        return;
    }

    new index = response[DIALOG_RESPONSE_LISTITEM];

    if (index < 0 || index >= KIOSK_WEAPONS)
    {
        return;
    }

    new line[200], name[ACCOUNT_NAME_LEN], price = Money_Make(s_KioskGuns[index][E_KIOSK_GUN_PRICE]), ammoItem = Item_FindByExtra(s_KioskGuns[index][E_KIOSK_GUN_AMMO]);
    new posse[e_POSSE];
    Posse_Get(posseid,posse);

    if (posse[E_POSSE_BANK] < price)
    {
        format(line,sizeof(line),"The posse's bank doesn't have enough money to buy a %s.",s_KioskGuns[index][E_KIOSK_GUN_NAME]);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return;
    }

    if (Weapons_Get(playerid,E_GUN_SLOT_HAND) != 0)
    {
        SendServerMessage(playerid,"You can't buy a weapon whilst you already have one equipped.",MSG_TYPE_ERROR);
        return;
    }

    if (Inventory_GetEquipped(playerid) != EQUIP_NONE || !Inventory_CanHold(playerid,ammoItem,2))
    {
        SendServerMessage(playerid,"You don't have enough backpack size to pick this item up. You have to get a bigger backpack.",MSG_TYPE_ERROR);
        return;
    }

    if (!Weapons_Give(playerid,s_KioskGuns[index][E_KIOSK_GUN_WEAPON],0))
    {
        return;
    }

    Posse_BankTake(posseid,price);
    Inventory_GiveByParam(playerid,E_ITEM_PARAM_AMMO,s_KioskGuns[index][E_KIOSK_GUN_AMMO],2);
    Posse_DisplayName(playerid,true,name);
    format(line,sizeof(line),"{[ %s (%d) has bought a %s from the posse's kiosk for $%d. ]}",name,playerid,s_KioskGuns[index][E_KIOSK_GUN_NAME],s_KioskGuns[index][E_KIOSK_GUN_PRICE]);
    Posse_Warning(posseid,line);
    Log_Info("guns/kiosk","%s",line);
}

static Kiosk_Place_Back(playerid,posseid)
{
    new gun = -1;

    switch (Weapons_Get(playerid,E_GUN_SLOT_HAND))
    {
        case 24:
        {
            gun = 0;
        }
        case 25:
        {
            gun = 1;
        }
        case 33:
        {
            gun = 2;
        }
        default:
        {
            SendServerMessage(playerid,"You don't have a valid kiosk weapon in your hands.",MSG_TYPE_ERROR);
            return;
        }
    }

    new refund = Money_Make(s_KioskGuns[gun][E_KIOSK_GUN_PRICE] / 2), line[200], name[ACCOUNT_NAME_LEN];
    Posse_BankGive(posseid,refund);
    Weapons_RemoveHand(playerid);
    new total = Inventory_GetExtraTotal(playerid,s_KioskGuns[gun][E_KIOSK_GUN_AMMO]);

    if (total > 0)
    {
        Inventory_DecreaseExtra(playerid,s_KioskGuns[gun][E_KIOSK_GUN_AMMO],total,false);
    }

    Posse_DisplayName(playerid,true,name);
    format(line,sizeof(line),"{[ %s (%d) has returned a %s to the posse's kiosk for $%d. ]}",name,playerid,s_KioskGuns[gun][E_KIOSK_GUN_NAME],s_KioskGuns[gun][E_KIOSK_GUN_PRICE] / 2);
    Posse_Message(posseid,line);
    Log_Info("guns/kiosk","%s",line);
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
CMD:possekiosk(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new option[16], posseid = Posse_GetPlayer(playerid), tier = Posse_GetTier(playerid);

    if (posseid == POSSE_NONE)
    {
        SendServerMessage(playerid,"You're not in a posse.",MSG_TYPE_INFO);
        return 1;
    }

    new bool:law = Posse_IsLawPosse(posseid);

    if (sscanf(params,"s[16]",option))
    {
        SendServerMessage(playerid,law ? ("/p(osse)kiosk [create, edit, delete, take, place, lock, duty]") : ("/p(osse)kiosk [create, edit, delete, take, place, lock]"),MSG_TYPE_ERROR);
        return 1;
    }

    new kiosk[e_KIOSK];
    Kiosk_Get(posseid,kiosk);
    new bool:near = Kiosk_IsNear(playerid,posseid);

    if (!strcmp(option,"create"))
    {
        if (tier < POSSE_TIER_LEADER)
        {
            SendServerMessage(playerid,"You lack the correct privileges to perform this action.",MSG_TYPE_WARN);
            return 1;
        }

        if (kiosk[E_KIOSK_OBJECT] != 0)
        {
            SendServerMessage(playerid,"You've already created a kiosk for your faction, use /p(osse)kiosk edit instead.",MSG_TYPE_ERROR);
            return 1;
        }

        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid,x,y,z);
        kiosk[E_KIOSK_X] = x;
        kiosk[E_KIOSK_Y] = y;
        kiosk[E_KIOSK_Z] = z;
        kiosk[E_KIOSK_OBJECT] = _:CreateDynamicObject(KIOSK_MODEL,x + KIOSK_OFFSET,y + KIOSK_OFFSET,z,0.0,0.0,0.0,GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid));
        Kiosk_Put(posseid,kiosk);
        s_KioskCreating[playerid] = true;
        EditDynamicObject(playerid,STREAMER_TAG_OBJECT:kiosk[E_KIOSK_OBJECT]);
    }
    else if (!strcmp(option,"edit"))
    {
        if (!near)
        {
            SendServerMessage(playerid,"You're not at your posse's kiosk.",MSG_TYPE_INFO);
            return 1;
        }

        if (tier < POSSE_TIER_LEADER)
        {
            SendServerMessage(playerid,"You lack the correct privileges to perform this action.",MSG_TYPE_WARN);
            return 1;
        }

        EditDynamicObject(playerid,STREAMER_TAG_OBJECT:kiosk[E_KIOSK_OBJECT]);
    }
    else if (!strcmp(option,"delete"))
    {
        if (!near)
        {
            SendServerMessage(playerid,"You're not at your posse's kiosk.",MSG_TYPE_INFO);
            return 1;
        }

        if (tier < POSSE_TIER_LEADER)
        {
            SendServerMessage(playerid,"You lack the correct privileges to perform this action.",MSG_TYPE_WARN);
            return 1;
        }

        Kiosk_Remove(posseid);
        mysql_tquery_s(g_Mysql,str_format("DELETE FROM possekiosk WHERE kiosk_id = %d",posseid));
        Kiosk_Say(playerid,posseid,"has deleted the posse kiosk.");
    }
    else if (!strcmp(option,"take"))
    {
        if (tier < POSSE_TIER_COMMAND)
        {
            SendServerMessage(playerid,"You lack the correct privileges to perform this action.",MSG_TYPE_WARN);
            return 1;
        }

        if (!near)
        {
            SendServerMessage(playerid,"You're not at your posse's kiosk.",MSG_TYPE_INFO);
            return 1;
        }

        if (kiosk[E_KIOSK_LOCKED] != 0)
        {
            SendServerMessage(playerid,"The posse's kiosk is locked.",MSG_TYPE_ERROR);
            return 1;
        }

        SetTimerEx("Kiosk_MenuDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
    }
    else if (!strcmp(option,"place"))
    {
        if (!near)
        {
            SendServerMessage(playerid,"You're not at your posse's kiosk.",MSG_TYPE_INFO);
            return 1;
        }

        Kiosk_Place_Back(playerid,posseid);
    }
    else if (!strcmp(option,"lock"))
    {
        if (tier < POSSE_TIER_LEADER)
        {
            SendServerMessage(playerid,"You lack the correct privileges to perform this action.",MSG_TYPE_WARN);
            return 1;
        }

        if (!near)
        {
            SendServerMessage(playerid,"You're not at your posse's kiosk.",MSG_TYPE_INFO);
            return 1;
        }

        kiosk[E_KIOSK_LOCKED] = kiosk[E_KIOSK_LOCKED] == 0 ? 1 : 0;
        Kiosk_Put(posseid,kiosk);
        SendServerMessage(playerid,kiosk[E_KIOSK_LOCKED] != 0 ? ("You have locked the kiosk.") : ("You have unlocked the kiosk."),MSG_TYPE_INFO);
    }
    else if (!strcmp(option,"duty"))
    {
        if (!law)
        {
            SendServerMessage(playerid,"You have to be in a police posse in order to do this command.",MSG_TYPE_INFO);
            return 1;
        }

        if (!near)
        {
            SendServerMessage(playerid,"You're not at your posse's kiosk.",MSG_TYPE_INFO);
            return 1;
        }

        Kiosk_Duty(playerid,posseid);
    }
    else
    {
        SendServerMessage(playerid,law ? ("/p(osse)kiosk [create, edit, delete, take, place, lock, duty]") : ("/p(osse)kiosk [create, edit, delete, take, place, lock]"),MSG_TYPE_ERROR);
    }

    return 1;
}

ALT:pkiosk=CMD:possekiosk;

public Kiosk_MenuDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Kiosk_Take(playerid,Posse_GetPlayer(playerid));
    }

    return 1;
}

#pragma warning push
#pragma warning disable 204
public Kiosk_Load()
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_new("SELECT kiosk_id, kiosk_x, kiosk_y, kiosk_z, kiosk_rx, kiosk_ry, kiosk_rz, kiosk_locked FROM possekiosk"),false);

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, kiosk[e_KIOSK];
        cache_get_value_name_int(i,"kiosk_id",id);
        cache_get_value_name_float(i,"kiosk_x",kiosk[E_KIOSK_X]);
        cache_get_value_name_float(i,"kiosk_y",kiosk[E_KIOSK_Y]);
        cache_get_value_name_float(i,"kiosk_z",kiosk[E_KIOSK_Z]);
        cache_get_value_name_float(i,"kiosk_rx",kiosk[E_KIOSK_RX]);
        cache_get_value_name_float(i,"kiosk_ry",kiosk[E_KIOSK_RY]);
        cache_get_value_name_float(i,"kiosk_rz",kiosk[E_KIOSK_RZ]);

        if (!Posse_Exists(id) || (kiosk[E_KIOSK_X] == 0.0 && kiosk[E_KIOSK_Y] == 0.0 && kiosk[E_KIOSK_Z] == 0.0))
        {
            continue;
        }

        kiosk[E_KIOSK_OBJECT] = _:CreateDynamicObject(KIOSK_MODEL,kiosk[E_KIOSK_X],kiosk[E_KIOSK_Y],kiosk[E_KIOSK_Z],kiosk[E_KIOSK_RX],kiosk[E_KIOSK_RY],kiosk[E_KIOSK_RZ]);
        Kiosk_Put(id,kiosk);
    }

    Boot_LoaderDone();
    return 1;
}
#pragma warning pop

stock Kiosk_InitPool()
{
    s_Kiosks = map_new();
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
    s_KioskCreating[playerid] = false;
    s_KioskDuty[playerid] = false;
}

hook OnPlayerDisconnect(playerid,reason)
{
    s_KioskCreating[playerid] = false;
    s_KioskDuty[playerid] = false;
}

hook Posse_OnDeleted(posseid)
{
    Kiosk_Remove(posseid);
}

hook OnPlayerEditDynamicObject(playerid,STREAMER_TAG_OBJECT:objectid,response,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
    new posseid = Posse_GetPlayer(playerid), kiosk[e_KIOSK];

    if (posseid == POSSE_NONE || !Kiosk_Get(posseid,kiosk) || kiosk[E_KIOSK_OBJECT] != _:objectid)
    {
        return;
    }

    if (response == 2)
    {
        return;
    }

    if (response == 1)
    {
        kiosk[E_KIOSK_X] = x;
        kiosk[E_KIOSK_Y] = y;
        kiosk[E_KIOSK_Z] = z;
        kiosk[E_KIOSK_RX] = rx;
        kiosk[E_KIOSK_RY] = ry;
        kiosk[E_KIOSK_RZ] = rz;
        Kiosk_Put(posseid,kiosk);
        Kiosk_Save(posseid,kiosk);

        if (s_KioskCreating[playerid])
        {
            s_KioskCreating[playerid] = false;
            Kiosk_Say(playerid,posseid,"has created the posse kiosk.");
        }

        return;
    }

    if (s_KioskCreating[playerid])
    {
        s_KioskCreating[playerid] = false;
        DestroyDynamicObject(objectid);
        map_remove(s_Kiosks,posseid);
        return;
    }

    SetDynamicObjectPos(objectid,kiosk[E_KIOSK_X],kiosk[E_KIOSK_Y],kiosk[E_KIOSK_Z]);
    SetDynamicObjectRot(objectid,kiosk[E_KIOSK_RX],kiosk[E_KIOSK_RY],kiosk[E_KIOSK_RZ]);
}
