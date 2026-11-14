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
#define PASS_NEAR_RANGE (6.0)
#define PASS_HANDSHAKE_RANGE (2.0)
#define QUICK_SWITCH_ACTION_COLOUR (COLOR_ACTION)

static s_WepHolsterTick[MAX_PLAYERS];

forward Weapons_OnPassed(playerid,target,weapon,ammo);

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
stock bool:Weapons_Near(playerid,targetid,Float:range)
{
    if (!IsPlayerConnected(targetid) || GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid))
    {
        return false;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid,x,y,z);
    return IsPlayerInRangeOfPoint(playerid,range,x,y,z);
}

static Weapons_Say(playerid,const text[])
{
    new line[160], name[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,name);
    format(line,sizeof(line),"* %s %s.",name,text);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
}

static bool:Weapons_Blocked(playerid,bool:needHand)
{
    if (!Player_IsReady(playerid) || !Weapons_IsLoaded(playerid))
    {
        return true;
    }

    if (needHand && Weapons_Get(playerid,E_GUN_SLOT_HAND) == 0)
    {
        return true;
    }

    return false;
}

static bool:Weapons_Hindered(playerid)
{
    if (Player_IsBusyWith(playerid,E_PLAYER_BUSY_HORSE))
    {
        SendServerMessage(playerid,"You're riding on a horse. Dismount first.",MSG_TYPE_ERROR);
        return true;
    }

    if (Inventory_GetEquipped(playerid) != EQUIP_NONE)
    {
        SendServerMessage(playerid,"You can't do this with an inventory item. Unequip it to get rid of it.",MSG_TYPE_ERROR);
        return true;
    }

    return false;
}

stock bool:Weapons_Holster(playerid,slot)
{
    if (!Player_IsReady(playerid) || !Weapons_IsLoaded(playerid))
    {
        return false;
    }

    new weapon = Weapons_Get(playerid,E_GUN_SLOT_HAND), ammo = Weapons_GetAmmo(playerid,E_GUN_SLOT_HAND), name[WEAPON_NAME_LEN], line[128];

    if (weapon == 0)
    {
        SendServerMessage(playerid,"You don't have a weapon to store!",MSG_TYPE_ERROR);
        return false;
    }

    if (Weapons_Hindered(playerid))
    {
        return false;
    }

    Weapon_GetName(weapon,name);

    if (slot == E_GUN_SLOT_PANTS)
    {
        if (weapon != 24 && weapon != 4)
        {
            SendServerMessage(playerid,"You can only store pistols or knives in your trousers!",MSG_TYPE_ERROR);
            return false;
        }

        if (Weapons_Get(playerid,E_GUN_SLOT_PANTS) != 0)
        {
            SendServerMessage(playerid,"There's already a weapon stored in this slot! You can check it by using /holstered.",MSG_TYPE_WARN);
            return false;
        }

        format(line,sizeof(line),"holsters their %s into their trousers",name);
    }
    else
    {
        if (Weapons_Get(playerid,E_GUN_SLOT_BACK) != 0)
        {
            SendServerMessage(playerid,"There's already a weapon stored in this slot! You can check it by using /holstered.",MSG_TYPE_WARN);
            return false;
        }

        format(line,sizeof(line),"holsters their %s onto their back",name);
    }

    Weapons_Say(playerid,line);
    Weapons_SetSlot(playerid,slot,weapon,ammo);
    Weapons_RemoveHand(playerid);
    Weapons_Attachments(playerid);
    return true;
}

stock bool:Weapons_Unholster(playerid,slot)
{
    if (!Player_IsReady(playerid) || !Weapons_IsLoaded(playerid))
    {
        return false;
    }

    if (Weapons_Get(playerid,E_GUN_SLOT_HAND) != 0)
    {
        SendServerMessage(playerid,"You're already holding a weapon. Holster it first by using /holster!",MSG_TYPE_ERROR);
        return false;
    }

    if (Weapons_Hindered(playerid))
    {
        return false;
    }

    new weapon = Weapons_Get(playerid,slot), ammo = Weapons_GetAmmo(playerid,slot);

    if (weapon == 0)
    {
        SendServerMessage(playerid,slot == E_GUN_SLOT_PANTS ? ("There isn't a weapon stored in your trouser slot!") : ("There isn't a weapon stored in your back slot!"),MSG_TYPE_WARN);
        return false;
    }

    if (!Weapons_Give(playerid,weapon,ammo))
    {
        return false;
    }

    new name[WEAPON_NAME_LEN], line[128];
    Weapon_GetName(weapon,name);
    format(line,sizeof(line),"unholsters their %s from their %s",name,slot == E_GUN_SLOT_PANTS ? ("trousers") : ("back"));
    Weapons_Say(playerid,line);
    Weapons_SetSlot(playerid,slot,0,0);
    Weapons_Save(playerid);
    Weapons_Attachments(playerid);
    return true;
}

stock bool:Weapons_Switch(playerid,slot)
{
    if (!Player_IsReady(playerid) || !Weapons_IsLoaded(playerid))
    {
        return false;
    }

    new hand = Weapons_Get(playerid,E_GUN_SLOT_HAND), handAmmo = Weapons_GetAmmo(playerid,E_GUN_SLOT_HAND);

    if (hand == 0)
    {
        SendServerMessage(playerid,"You're not holding a weapon you can switch!",MSG_TYPE_ERROR);
        return false;
    }

    if (Weapons_Hindered(playerid))
    {
        return false;
    }

    new stored = Weapons_Get(playerid,slot), storedAmmo = Weapons_GetAmmo(playerid,slot);

    if (stored == 0)
    {
        SendServerMessage(playerid,slot == E_GUN_SLOT_PANTS ? ("There isn't a weapon stored in your trouser slot!") : ("There isn't a weapon stored in your back slot!"),MSG_TYPE_WARN);
        return false;
    }

    if (slot == E_GUN_SLOT_PANTS && hand != 24 && hand != 4)
    {
        SendServerMessage(playerid,"You can only store pistols or knives in your trousers!",MSG_TYPE_ERROR);
        return false;
    }

    new handName[WEAPON_NAME_LEN], storedName[WEAPON_NAME_LEN], line[160];
    Weapon_GetName(hand,handName);
    Weapon_GetName(stored,storedName);
    format(line,sizeof(line),"switched their %s with a %s from their %s",handName,storedName,slot == E_GUN_SLOT_PANTS ? ("trousers") : ("back"));
    Weapons_Say(playerid,line);
    Weapons_RemoveHand(playerid);
    Weapons_Give(playerid,stored,storedAmmo);
    Weapons_SetSlot(playerid,slot,hand,handAmmo);
    Weapons_Save(playerid);
    Weapons_Attachments(playerid);
    return true;
}

stock bool:Weapons_Quick(playerid)
{
    if (!Player_IsReady(playerid) || !Weapons_IsLoaded(playerid))
    {
        return false;
    }

    new elapsed = GetTickCount() - s_WepHolsterTick[playerid], limit = Skills_GetHolsterDelay(playerid);

    if (elapsed < limit)
    {
        new line[160];
        format(line,sizeof(line),"You must wait %0.2f seconds before quickswitching again. To increase this, use /skills and /levelup your holster skill",float(limit - elapsed) / 1000.0);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return false;
    }

    s_WepHolsterTick[playerid] = GetTickCount();

    if (Weapons_Get(playerid,E_GUN_SLOT_HAND) != 0)
    {
        return Weapons_Holster(playerid,E_GUN_SLOT_PANTS);
    }

    if (Weapons_Get(playerid,E_GUN_SLOT_PANTS) == 0 && Weapons_Get(playerid,E_GUN_SLOT_BACK) != 0)
    {
        return Weapons_Unholster(playerid,E_GUN_SLOT_BACK);
    }

    return Weapons_Unholster(playerid,E_GUN_SLOT_PANTS);
}

static Weapons_ParseSlot(const params[])
{
    if (!strcmp(params,"trousers",true))
    {
        return E_GUN_SLOT_PANTS;
    }

    if (!strcmp(params,"back",true))
    {
        return E_GUN_SLOT_BACK;
    }

    return -1;
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
CMD:holster(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new slot = Weapons_ParseSlot(params);

    if (slot == -1)
    {
        if (Weapons_Blocked(playerid,false))
        {
            return 1;
        }

        if (Weapons_Get(playerid,E_GUN_SLOT_HAND) == 0)
        {
            SendServerMessage(playerid,"You don't have a weapon to store!",MSG_TYPE_ERROR);
            return 1;
        }

        SendServerMessage(playerid,"/holster [trousers | back]",MSG_TYPE_ERROR);
        return 1;
    }

    Weapons_Holster(playerid,slot);
    return 1;
}

ALT:gh=CMD:holster;

CMD:unholster(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new slot = Weapons_ParseSlot(params);

    if (slot == -1)
    {
        if (!Weapons_Blocked(playerid,false) && Weapons_Get(playerid,E_GUN_SLOT_HAND) != 0)
        {
            SendServerMessage(playerid,"You're already holding a weapon. Holster it first by using /holster!",MSG_TYPE_ERROR);
            return 1;
        }

        SendServerMessage(playerid,"/unholster [trousers | back]",MSG_TYPE_ERROR);
        return 1;
    }

    Weapons_Unholster(playerid,slot);
    return 1;
}

ALT:guh=CMD:unholster;

CMD:switchgun(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new slot = Weapons_ParseSlot(params);

    if (slot == -1)
    {
        if (!Weapons_Blocked(playerid,false) && Weapons_Get(playerid,E_GUN_SLOT_HAND) == 0)
        {
            SendServerMessage(playerid,"You're not holding a weapon you can switch!",MSG_TYPE_ERROR);
            return 1;
        }

        SendServerMessage(playerid,"/switchgun [trousers | back]",MSG_TYPE_ERROR);
        return 1;
    }

    Weapons_Switch(playerid,slot);
    return 1;
}

ALT:sgun=CMD:switchgun;

CMD:holstered(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    new line[128], name[WEAPON_NAME_LEN];
    SendClientMessage(playerid,COLOR_TAB0,"|_____________________| List of your holstered weapons |_____________________| ");

    for (new slot = 0;slot < 3;slot++)
    {
        new tag[16], colour = COLOR_TAB1;

        switch (slot)
        {
            case 0:
            {
                strcopy(tag,"[EQUIPPED]");
            }
            case 1:
            {
                strcopy(tag,"[TROUSERS]");
            }
            default:
            {
                strcopy(tag,"[BACK]");
                colour = COLOR_TAB2;
            }
        }

        if (Weapons_Get(playerid,slot) != 0)
        {
            Weapon_GetName(Weapons_Get(playerid,slot),name);
            format(line,sizeof(line),"%s{DEDEDE} %s (%d)",tag,name,Weapons_GetAmmo(playerid,slot));
        }
        else
        {
            format(line,sizeof(line),"%s{DEDEDE} Empty",tag);
        }

        SendClientMessage(playerid,colour,line);
    }

    return 1;
}

ALT:guns=CMD:holstered;

CMD:gunpos(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new slot = Weapons_ParseSlot(params);

    if (slot == -1)
    {
        SendServerMessage(playerid,"/gunpos [trousers, back]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Weapons_IsLoaded(playerid) || Weapons_Get(playerid,slot) == 0)
    {
        SendServerMessage(playerid,slot == E_GUN_SLOT_PANTS ? ("There isn't a weapon stored in your trouser slot!") : ("There isn't a weapon stored in your back slot!"),MSG_TYPE_WARN);
        return 1;
    }

    EditAttachedObject(playerid,slot == E_GUN_SLOT_PANTS ? WEAPON_SLOT_PANTS : WEAPON_SLOT_BACK);
    return 1;
}

CMD:passgun(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (Weapons_Get(playerid,E_GUN_SLOT_HAND) == 0)
    {
        SendServerMessage(playerid,"You're not holding a weapon you can switch!",MSG_TYPE_ERROR);
        return 1;
    }

    if (Inventory_GetEquipped(playerid) != EQUIP_NONE)
    {
        SendServerMessage(playerid,"You can't do this with an inventory item. Unequip it to get rid of it.",MSG_TYPE_ERROR);
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/passgun [target]",MSG_TYPE_ERROR);
        return 1;
    }

    if (target == playerid || !Staff_IsValidTarget(target) || !Player_IsReady(target) || !Weapons_IsLoaded(target))
    {
        SendServerMessage(playerid,"This player doesn't exist.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Character_GetLevel(target) < 3)
    {
        SendServerMessage(playerid,"Target's level is too low. It should be at least 3",MSG_TYPE_ERROR);
        return 1;
    }

    if (Weapons_Get(target,E_GUN_SLOT_HAND) != 0)
    {
        SendServerMessage(playerid,"Your target is already holding a weapon!",MSG_TYPE_ERROR);
        return 1;
    }

    if (Inventory_GetEquipped(target) != EQUIP_NONE)
    {
        SendServerMessage(playerid,"Your target already has something equipped. Tell them to unequip it.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Player_IsBusyWith(target,E_PLAYER_BUSY_HORSE))
    {
        SendServerMessage(playerid,"Your target is riding on a horse. Tell them to dismount first.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Weapons_Near(playerid,target,PASS_NEAR_RANGE))
    {
        SendServerMessage(playerid,"You are not near that player.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Weapons_Near(playerid,target,PASS_HANDSHAKE_RANGE))
    {
        ApplyAnimation(target,"GANGS","prtial_hndshk_biz_01",4.0,false,false,false,false,0,SYNC_ALL);
        ApplyAnimation(playerid,"GANGS","prtial_hndshk_biz_01",4.0,false,false,false,false,0,SYNC_ALL);
    }

    new weapon = Weapons_Get(playerid,E_GUN_SLOT_HAND), ammo = Weapons_GetAmmo(playerid,E_GUN_SLOT_HAND);
    Weapons_RemoveHand(playerid);

    if (!Weapons_Give(target,weapon,ammo))
    {
        Weapons_Give(playerid,weapon,ammo);
        return 1;
    }

    new line[200], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN], gun[WEAPON_NAME_LEN], tag[16];
    Account_GetRoleplayName(playerid,name);
    Account_GetRoleplayName(target,targetName);
    Weapon_GetName(weapon,gun);
    format(line,sizeof(line),"* %s has given their %s to %s.",name,gun,targetName);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);

    if (Inventory_FindExtra(playerid,E_ITEM_EXTRA_CARD_GUNPERMIT) != INV_ROW_NONE)
    {
        strcopy(tag,"[PERMIT] ");
    }

    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    format(line,sizeof(line),"%s %s has passed their %s with %d ammo to %s",tag,name,gun,ammo,targetName);
    Log_Info("guns/pass","%s",line);
    pawn_call_public("Weapons_OnPassed","dddd",playerid,target,weapon,ammo);
    Weapons_Attachments(playerid);
    Weapons_Attachments(target);
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
public Weapons_OnPassed(playerid,target,weapon,ammo)
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

hook OnPlayerConnect(playerid)
{
    s_WepHolsterTick[playerid] = 0;
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (newkeys & KEY_YES)
    {
        Weapons_Quick(playerid);
    }
}
