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
CMD:spawnweapon(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    new target, weapon, ammo;

    if (sscanf(params,"uii",target,weapon,ammo))
    {
        SendServerMessage(playerid,"/spawnweapon [player] [weapon id] [ammo]",MSG_TYPE_ERROR);
        return 1;
    }

    if (ammo > 15)
    {
        SendServerMessage(playerid,"You can't spawn more than 15 ammo in a clip!",MSG_TYPE_ERROR);
        return 1;
    }

    if (ammo < 0)
    {
        SendServerMessage(playerid,"The ammo can't be negative.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Weapon_IsValid(weapon))
    {
        SendServerMessage(playerid,"This weapon isn't valid.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_IsValidTarget(target) || !Player_IsReady(target))
    {
        SendServerMessage(playerid,"Target doesn't seem to be a valid player.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[200], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN], gun[WEAPON_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    Weapon_GetName(weapon,gun);

    if (!Weapons_Give(target,weapon,ammo))
    {
        return 1;
    }

    format(line,sizeof(line),"[STAFF] %s (%d) spawned a %s with %d ammo for (%d) %s.",name,playerid,gun,ammo,target,targetName);
    SendModeratorWarning(line,MOD_WARNING_HIGH);
    Staff_Log("mods/gun",line);
    return 1;
}

CMD:gotodroppedweapon(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    new id, drop[e_GUNDROP];

    if (sscanf(params,"i",id))
    {
        SendServerMessage(playerid,"/gotodroppedweapon [id]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Weapons_DropGet(id,drop))
    {
        SendServerMessage(playerid,"Invalid weapon ID. Doesn't seem to be a valid object.",MSG_TYPE_WARN);
        return 1;
    }

    new line[128], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    SetPlayerPos(playerid,drop[E_GUNDROP_X],drop[E_GUNDROP_Y],drop[E_GUNDROP_Z]);
    SetPlayerInterior(playerid,drop[E_GUNDROP_INTERIOR]);
    SetPlayerVirtualWorld(playerid,drop[E_GUNDROP_WORLD]);
    format(line,sizeof(line),"[STAFF] %s (%d) has teleported to dropped gun ID %d.",name,playerid,id);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    return 1;
}

CMD:removedroppedweapon(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    new id;

    if (sscanf(params,"i",id))
    {
        SendServerMessage(playerid,"/removedroppedweapon [id]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Weapons_DropRemove(id))
    {
        SendServerMessage(playerid,"Invalid weapon ID. Doesn't seem to be a valid object.",MSG_TYPE_WARN);
        return 1;
    }

    new line[128], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"[STAFF] %s (%d) has deleted dropped gun ID %d.",name,playerid,id);
    SendModeratorWarning(line,MOD_WARNING_MED);
    return 1;
}

CMD:afrisk(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_BASIC))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/afrisk [target]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"Target isn't connected."))
    {
        return 1;
    }

    new line[200], name[ACCOUNT_NAME_LEN], gun[WEAPON_NAME_LEN], money[MONEY_TEXT_LEN];
    GetPlayerName(target,name,sizeof(name));
    format(line,sizeof(line),"|________________________| Frisk of (%d) %s |________________________|",target,name);
    SendClientMessage(playerid,COLOR_TAB0,line);
    Weapon_GetName(Weapons_Get(target,E_GUN_SLOT_HAND),gun);
    format(line,sizeof(line),"[HANDS]: %s with %d ammo.",gun,Weapons_GetAmmo(target,E_GUN_SLOT_HAND));
    SendClientMessage(playerid,COLOR_TAB1,line);
    Weapon_GetName(Weapons_Get(target,E_GUN_SLOT_PANTS),gun);
    format(line,sizeof(line),"[PANTS]: %s with %d ammo.",gun,Weapons_GetAmmo(target,E_GUN_SLOT_PANTS));
    SendClientMessage(playerid,COLOR_TAB2,line);
    Weapon_GetName(Weapons_Get(target,E_GUN_SLOT_BACK),gun);
    format(line,sizeof(line),"[BACK]: %s with %d ammo.",gun,Weapons_GetAmmo(target,E_GUN_SLOT_BACK));
    SendClientMessage(playerid,COLOR_TAB1,line);
    Money_Format(Money_Get(target),money);
    format(line,sizeof(line),"[MONEY]: %s",money);
    SendClientMessage(playerid,COLOR_TAB1,line);
    new self[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,self,sizeof(self));
    format(line,sizeof(line),"[STAFF] %s (%d) has frisked %s (%d).",self,playerid,name,target);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    return 1;
}

CMD:adisarm(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_BASIC))
    {
        return 1;
    }

    new target, permit;

    if (sscanf(params,"ui",target,permit))
    {
        SendServerMessage(playerid,"Syntax: /adisarm <player> <permit: 0: keep, 1: removed)",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"Target isn't connected."))
    {
        return 1;
    }

    new line[200], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN], roleplay[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    Account_GetRoleplayName(playerid,roleplay);
    Weapons_RemoveHand(target);
    Weapons_SetSlot(target,E_GUN_SLOT_PANTS,0,0);
    Weapons_SetSlot(target,E_GUN_SLOT_BACK,0,0);
    Weapons_Save(target);
    Weapons_Attachments(target);

    if (permit != 0)
    {
        new index = Inventory_FindExtra(target,E_ITEM_EXTRA_CARD_GUNPERMIT);

        if (index != INV_ROW_NONE)
        {
            Inventory_Remove(target,index);
        }

        format(line,sizeof(line),"Admin %s has disarmed you of your weapons, ammo and permit.",roleplay);
        SendServerMessage(target,line,MSG_TYPE_INFO);
        format(line,sizeof(line),"[STAFF] %s (%d) has disarmed %s (%d) of their weapons and permit.",name,playerid,targetName,target);
        SendModeratorWarning(line,MOD_WARNING_LOW);
        Staff_Log("mods/adisarm",line);
        return 1;
    }

    format(line,sizeof(line),"Admin %s has disarmed you of your weapons and ammo.",roleplay);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"[STAFF] %s (%d) has disarmed %s (%d) of their weapons.",name,playerid,targetName,target);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    Staff_Log("mods/adisarm",line);
    return 1;
}
