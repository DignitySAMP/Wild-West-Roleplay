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
#define INTERACT_RANGE (6.0)
#define INTERACT_TALK_RANGE (20.0)
#define SHAKE_TYPES (6)

static s_ShakeOffer[MAX_PLAYERS] = {INVALID_PLAYER_ID,...};
static s_ShakeType[MAX_PLAYERS];
static s_FriskOffer[MAX_PLAYERS] = {INVALID_PLAYER_ID,...};

static const s_ShakeAnims[SHAKE_TYPES][24] =
{
    "hndshkaa","hndshkba","hndshkda","hndshkea","hndshkfa","prtial_hndshk_biz_01"
};

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
stock Interaction_GetShakeOffer(playerid)
{
    return s_ShakeOffer[playerid];
}

stock Interaction_GetFriskOffer(playerid)
{
    return s_FriskOffer[playerid];
}

static bool:Interaction_Near(playerid,target)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(target,x,y,z);
    return IsPlayerInRangeOfPoint(playerid,INTERACT_RANGE,x,y,z) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(target) && GetPlayerInterior(playerid) == GetPlayerInterior(target);
}

static Interaction_Face(playerid,target)
{
    new Float:x, Float:y, Float:z, Float:tx, Float:ty, Float:tz;
    GetPlayerPos(playerid,x,y,z);
    GetPlayerPos(target,tx,ty,tz);
    SetPlayerFacingAngle(playerid,atan2(ty - y,tx - x) - 90.0);
}

static bool:Interaction_Ready(playerid)
{
    return Player_IsReady(playerid) && Player_IsSpawned(playerid);
}

static Interaction_Clear(playerid)
{
    s_ShakeOffer[playerid] = INVALID_PLAYER_ID;
    s_ShakeType[playerid] = 0;
    s_FriskOffer[playerid] = INVALID_PLAYER_ID;

    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (s_ShakeOffer[i] == playerid)
        {
            s_ShakeOffer[i] = INVALID_PLAYER_ID;
        }

        if (s_FriskOffer[i] == playerid)
        {
            s_FriskOffer[i] = INVALID_PLAYER_ID;
        }
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
CMD:shakehand(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Chat_IsFree(playerid))
    {
        SendServerMessage(playerid,"You can't do this right now",MSG_TYPE_ERROR);
        return 1;
    }

    new userid, type;

    if (sscanf(params,"ud",userid,type))
    {
        SendServerMessage(playerid,"/shakehand [playerid, name] [type]",MSG_TYPE_ERROR);
        return 1;
    }

    if (userid == INVALID_PLAYER_ID || !Interaction_Ready(userid) || !Interaction_Near(playerid,userid))
    {
        SendServerMessage(playerid,"The specified player is disconnected or not near you.",MSG_TYPE_ERROR);
        return 1;
    }

    if (userid == playerid)
    {
        SendServerMessage(playerid,"You can't shake your own hand.",MSG_TYPE_ERROR);
        return 1;
    }

    if (type < 1 || type > SHAKE_TYPES)
    {
        SendServerMessage(playerid,"Type can't be lower than 1, or higher than 6.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[144], name[ACCOUNT_NAME_LEN];
    s_ShakeOffer[userid] = playerid;
    s_ShakeType[userid] = type;
    Name_Display(playerid,name);
    format(line,sizeof(line),"%s has offered to shake your hand (type \"/accept greet\").",name);
    SendServerMessage(userid,line,MSG_TYPE_INFO);
    Name_Display(userid,name);
    format(line,sizeof(line),"You have offered to shake %s's hand.",name);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
}

CMD:frisk(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/frisk [id]",MSG_TYPE_ERROR);
        return 1;
    }

    if (target == INVALID_PLAYER_ID || !Interaction_Ready(target))
    {
        SendServerMessage(playerid,"This player isn't connected.",MSG_TYPE_ERROR);
        return 1;
    }

    if (target == playerid || !Interaction_Near(playerid,target))
    {
        SendServerMessage(playerid,"You are not near that player.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Chat_IsFree(target))
    {
        SendServerMessage(playerid,"You can't do this right now",MSG_TYPE_ERROR);
        return 1;
    }

    new line[144], name[MAX_PLAYER_NAME + 1];
    s_FriskOffer[target] = playerid;
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"[FRISK] %s has attempted to frisk you. Type /accept frisk to accept.",name);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    SendServerMessage(playerid,"The frisk request is pending, they have to accept the frisk first.",MSG_TYPE_INFO);
    return 1;
}

CMD:accept(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Chat_IsFree(playerid))
    {
        SendServerMessage(playerid,"You can't do this right now",MSG_TYPE_ERROR);
        return 1;
    }

    if (isnull(params))
    {
        SendServerMessage(playerid,"/accept [param]",MSG_TYPE_ERROR);
        SendClientMessage(playerid,COLOR_BLUE,"[PARAMS]:{DEDEDE} greet, frisk");
        return 1;
    }

    if (!strcmp(params,"greet",true) && s_ShakeOffer[playerid] != INVALID_PLAYER_ID)
    {
        new target = s_ShakeOffer[playerid], type = s_ShakeType[playerid];

        if (!IsPlayerConnected(target) || !Interaction_Near(playerid,target))
        {
            SendServerMessage(playerid,"You are not near that player.",MSG_TYPE_ERROR);
            return 1;
        }

        Interaction_Face(target,playerid);
        Interaction_Face(playerid,target);
        s_ShakeOffer[playerid] = INVALID_PLAYER_ID;
        s_ShakeType[playerid] = 0;
        ApplyAnimation(playerid,"GANGS",s_ShakeAnims[type - 1],4.0,false,false,false,false,0,SYNC_ALL);
        ApplyAnimation(target,"GANGS",s_ShakeAnims[type - 1],4.0,false,false,false,false,0,SYNC_ALL);
        new line[144], name[ACCOUNT_NAME_LEN];
        Name_Display(target,name);
        format(line,sizeof(line),"You have accepted %s's handshake.",name);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        Name_Display(playerid,name);
        format(line,sizeof(line),"%s has accepted your handshake.",name);
        SendServerMessage(target,line,MSG_TYPE_INFO);
    }
    else if (!strcmp(params,"frisk",true) && s_FriskOffer[playerid] != INVALID_PLAYER_ID)
    {
        new target = s_FriskOffer[playerid];

        if (!IsPlayerConnected(target) || !Interaction_Near(playerid,target))
        {
            SendServerMessage(playerid,"You are not near that player.",MSG_TYPE_ERROR);
            return 1;
        }

        new line[160], name[MAX_PLAYER_NAME + 1], weapon[WEAPON_NAME_LEN], money[24];
        GetPlayerName(playerid,name,sizeof(name));
        format(line,sizeof(line),"|________________________| Frisk of (%d) %s |________________________|",playerid,name);
        SendClientMessage(target,COLOR_TAB0,line);
        Weapon_GetName(Weapons_Get(playerid,E_GUN_SLOT_HAND),weapon);
        format(line,sizeof(line),"[HANDS]: %s with %d ammo.",weapon,Weapons_GetAmmo(playerid,E_GUN_SLOT_HAND));
        SendClientMessage(target,COLOR_TAB1,line);
        Weapon_GetName(Weapons_Get(playerid,E_GUN_SLOT_PANTS),weapon);
        format(line,sizeof(line),"[PANTS]: %s with %d ammo.",weapon,Weapons_GetAmmo(playerid,E_GUN_SLOT_PANTS));
        SendClientMessage(target,COLOR_TAB2,line);
        Weapon_GetName(Weapons_Get(playerid,E_GUN_SLOT_BACK),weapon);
        format(line,sizeof(line),"[BACK]: %s with %d ammo.",weapon,Weapons_GetAmmo(playerid,E_GUN_SLOT_BACK));
        SendClientMessage(target,COLOR_TAB1,line);
        Money_FormatShort(Money_Get(playerid),money);
        format(line,sizeof(line),"[MONEY]: %s",money);
        SendClientMessage(target,COLOR_TAB1,line);
        s_FriskOffer[playerid] = INVALID_PLAYER_ID;
        new first[ACCOUNT_NAME_LEN], second[ACCOUNT_NAME_LEN];
        Name_Display(target,first);
        Name_Display(playerid,second);
        format(line,sizeof(line),"* %s has just frisked %s",first,second);
        ProxDetector(playerid,INTERACT_TALK_RANGE,COLOR_ACTION,line);
    }

    return 1;
}

CMD:coin(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    new line[128], name[ACCOUNT_NAME_LEN];
    Name_Display(playerid,name);
    format(line,sizeof(line),"*** %s flips a coin and it lands on %s",name,random(2) == 0 ? ("Heads") : ("Tails"));
    ProxDetector(playerid,INTERACT_TALK_RANGE,COLOR_ACTION,line);
    return 1;
}

CMD:roll(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    new line[128], name[ACCOUNT_NAME_LEN];
    Name_Display(playerid,name);
    format(line,sizeof(line),"*** %s rolls a dice and it rolls on %d.",name,1 + random(6));
    ProxDetector(playerid,INTERACT_TALK_RANGE,COLOR_ACTION,line);
    return 1;
}

CMD:checktime(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (Inventory_FindExtra(playerid,E_ITEM_EXTRA_POCKET_WATCH) == INV_ROW_NONE)
    {
        SendServerMessage(playerid,"You don't have a pocket watch!",MSG_TYPE_ERROR);
        return 1;
    }

    new line[96], name[ACCOUNT_NAME_LEN];
    format(line,sizeof(line),"The current time is %d:%02d.",Time_GetHour(),Time_GetMinute());
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Name_Display(playerid,name);
    format(line,sizeof(line),"* %s checks the time.",name);
    SetPlayerChatBubble(playerid,line,COLOR_ACTION,INTERACT_TALK_RANGE,7000);
    Anim_Time(playerid);
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

hook OnPlayerConnect(playerid)
{
    Interaction_Clear(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Interaction_Clear(playerid);
}
