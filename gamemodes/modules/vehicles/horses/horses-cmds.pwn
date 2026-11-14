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
#define HORSE_FEED_RANGE (1.5)
#define HORSE_FEED_AMOUNT (25.0)

static bool:s_HorseEatChosen[MAX_PLAYERS];

forward Horse_FeedDeferred(playerid,token,uid,item,extra);
forward Horse_StableDeferred(playerid,token);
forward Horse_OnBought(playerid,type);

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
static Horse_NearOwn(playerid,Float:range)
{
    if (!Horse_IsSpawned(playerid) || Horse_GetObject(playerid) == INVALID_STREAMER_ID)
    {
        return false;
    }

    new Float:x, Float:y, Float:z, Float:rotation;
    Horse_GetPosition(playerid,x,y,z,rotation);
    return IsPlayerInRangeOfPoint(playerid,range,x,y,z);
}

static Horse_FindStable(playerid)
{
    new pointid = Point_FindInterior(playerid,HORSE_STABLE_RANGE);

    if (pointid == 0)
    {
        return 0;
    }

    new point[e_POINT];
    Point_Get(pointid,point);

    if (point[E_POINT_TYPE] != POINT_TYPE_BIZ || point[E_POINT_BIZTYPE] != POINT_BIZ_STABLE)
    {
        return 0;
    }

    return pointid;
}

stock bool:Horse_Buy(playerid,type)
{
    new row[e_HORSE_TYPE];

    if (!Horse_CatalogGet(type,row))
    {
        return false;
    }

    new line[128];

    if (row[E_HORSE_DONATOR] && Account_GetDonatorLevel(playerid) == 0)
    {
        SendServerMessage(playerid,"You need to be a donator in order to purchase this horse.",MSG_TYPE_ERROR);
        return false;
    }

    if (!row[E_HORSE_ENABLED])
    {
        SendServerMessage(playerid,"That horse isn't for sale.",MSG_TYPE_ERROR);
        return false;
    }

    if (row[E_HORSE_LEVEL] > Character_GetLevel(playerid))
    {
        format(line,sizeof(line),"You need to be level %d to buy a %s.",row[E_HORSE_LEVEL],row[E_HORSE_NAME]);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return false;
    }

    if (!Money_CanAfford(playerid,row[E_HORSE_PRICE]))
    {
        format(line,sizeof(line),"You don't have this much money. You need at least $%d.",row[E_HORSE_PRICE] / 100);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return false;
    }

    if (Horse_IsSpawned(playerid))
    {
        Horse_Despawn(playerid);
    }

    Money_Take(playerid,row[E_HORSE_PRICE]);
    Horse_SetType(playerid,type);
    Horse_SetStoredHealth(playerid,HORSE_MAX_HEALTH);
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_horseid = %d, character_horsehealth = 100 WHERE character_id = %d",type,Character_GetId(playerid)));
    format(line,sizeof(line),"You have purchased a {876C45}%s{DEDEDE} for {458754}$%d.",row[E_HORSE_NAME],row[E_HORSE_PRICE] / 100);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    pawn_call_public("Horse_OnBought","dd",playerid,type);
    return true;
}

static Horse_StableMenu(playerid,token)
{
    yield 1;

    new types[HORSE_CATALOG_SIZE], count = 0;
    Picker_Begin(playerid);

    for (new i = 0;i < HORSE_CATALOG_SIZE;i++)
    {
        new row[e_HORSE_TYPE];
        Horse_CatalogGet(i,row);

        if (!row[E_HORSE_ENABLED])
        {
            continue;
        }

        types[count++] = i;
        new caption[PICKER_CAPTION_LEN];
        format(caption,sizeof(caption),"~b~%s~w~~n~Price:~g~$%d~w~~n~Level Required: %d",row[E_HORSE_NAME],row[E_HORSE_PRICE] / 100,row[E_HORSE_LEVEL]);
        Picker_Add(playerid,11733,caption);
    }

    new response[DIALOG_RESPONSE];
    await_arr(response) Picker_Show(playerid,"General Store","Select","Cancel");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
    {
        return;
    }

    new item = response[DIALOG_RESPONSE_LISTITEM];

    if (item < 0 || item >= count || Horse_FindStable(playerid) == 0)
    {
        return;
    }

    Horse_Buy(playerid,types[item]);
}

stock bool:Horse_Revive(playerid)
{
    if (Horse_FindStable(playerid) == 0)
    {
        SendServerMessage(playerid,"You're not near a stablemaster. Make sure to enter the shop before doing this command.",MSG_TYPE_ERROR);
        return false;
    }

    if (!Horse_HasHorse(playerid))
    {
        SendServerMessage(playerid,"You don't have a horse, so you can't revive it.",MSG_TYPE_ERROR);
        return false;
    }

    if (Horse_GetHealth(playerid) > HORSE_REVIVE_LIMIT)
    {
        SendServerMessage(playerid,"Your horse seems to be healthy, there's no need to revive it.",MSG_TYPE_ERROR);
        return false;
    }

    if (!Money_CanAfford(playerid,HORSE_REVIVE_PRICE))
    {
        SendServerMessage(playerid,"You need $15 in order to revive your horse.",MSG_TYPE_ERROR);
        return false;
    }

    SendServerMessage(playerid,"Your horse has been revived for a small fee of $15. You can now /spawnhorse again!",MSG_TYPE_INFO);
    Horse_SetHealth(playerid,HORSE_MAX_HEALTH);
    Money_Take(playerid,HORSE_REVIVE_PRICE);
    return true;
}

stock bool:Horse_OfferApple(playerid,uid,item,extra)
{
    if (s_HorseEatChosen[playerid])
    {
        s_HorseEatChosen[playerid] = false;
        return false;
    }

    if (!Horse_HasHorse(playerid) || (!Horse_IsRiding(playerid) && !Horse_NearOwn(playerid,HORSE_FEED_RANGE)))
    {
        return false;
    }

    SetTimerEx("Horse_FeedDeferred",0,false,"ddddd",playerid,Account_GetToken(playerid),uid,item,extra);
    return true;
}

static Horse_Feed(playerid,uid)
{
    new index = Inventory_IndexOfUid(playerid,uid), Float:health = Horse_GetHealth(playerid), line[128], kind[8];
    strcopy(kind,Horse_IsCow(playerid) ? ("cow") : ("horse"));

    if (index == INV_ROW_NONE)
    {
        return;
    }

    if (health <= 0.0)
    {
        SendServerMessage(playerid,"Your horse is dead. You have to revive it first by going to a stablemaster.",MSG_TYPE_ERROR);
        return;
    }

    if (health >= HORSE_MAX_HEALTH)
    {
        Horse_SetHealth(playerid,HORSE_MAX_HEALTH);
        SendServerMessage(playerid,"Your horse already has full health. There's no point in feeding it.",MSG_TYPE_INFO);
        return;
    }

    new Float:amount = health + HORSE_FEED_AMOUNT;

    if (health >= 75.0)
    {
        amount = HORSE_MAX_HEALTH;
    }

    Horse_SetHealth(playerid,amount);
    format(line,sizeof(line),"You've fed your %s. It now has %.0f health.",kind,Horse_GetHealth(playerid));
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    new rp[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,rp);
    format(line,sizeof(line),"* %s has fed their %s an apple.",rp,kind);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
    Inventory_Decrease(playerid,index,1);
}

static Horse_FeedFlow(playerid,token,uid,item,extra)
{
    yield 1;
    new response[DIALOG_RESPONSE];
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"You're near your mount - choose your action","Feed your horse\nEat the food yourself","Select","Cancel");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
    {
        return;
    }

    if (response[DIALOG_RESPONSE_LISTITEM] == 0)
    {
        Horse_Feed(playerid,uid);
    }
    else
    {
        s_HorseEatChosen[playerid] = true;
        pawn_call_public("Inventory_UseFood","dddd",playerid,uid,item,extra);
        s_HorseEatChosen[playerid] = false;
    }
}

public Horse_FeedDeferred(playerid,token,uid,item,extra)
{
    Horse_FeedFlow(playerid,token,uid,item,extra);
    return 1;
}

public Horse_StableDeferred(playerid,token)
{
    Horse_StableMenu(playerid,token);
    return 1;
}

public Horse_OnBought(playerid,type)
{
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
CMD:spawnhorse(cmdid,playerid,params[])
{
    #pragma unused cmdid,params
    Horse_Spawn(playerid);
    return 1;
}

ALT:sh=CMD:spawnhorse;

CMD:respawnhorse(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (!Horse_HasHorse(playerid))
    {
        SendServerMessage(playerid,"You don't have a horse, so you can't revive it.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Horse_IsRiding(playerid))
    {
        SendServerMessage(playerid,"You can't do /respawnhorse while you're already on a horse",MSG_TYPE_ERROR);
        return 1;
    }

    Horse_Despawn(playerid);
    SendServerMessage(playerid,"Your horse has been despawned. You can now use /spawnhorse again",MSG_TYPE_INFO);
    return 1;
}

ALT:rsh=CMD:respawnhorse;

CMD:toghorsetds(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!strcmp(params,"enable"))
    {
        if (!Horse_IsRiding(playerid))
        {
            SendServerMessage(playerid,"You're not riding a horse",MSG_TYPE_ERROR);
            return 1;
        }

        Horse_SetHudHidden(playerid,false);
        Horse_ShowHud(playerid);
        SendServerMessage(playerid,"You have enabled your horse textdraws.",MSG_TYPE_INFO);
    }
    else if (!strcmp(params,"disable"))
    {
        Horse_SetHudHidden(playerid,true);
        Horse_HideHud(playerid);
        SendServerMessage(playerid,"You have disabled your horse textdraws.",MSG_TYPE_INFO);
    }
    else
    {
        SendServerMessage(playerid,"/toghorsetds [enable / disable]",MSG_TYPE_ERROR);
    }

    return 1;
}

CMD:nohorsesound(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (!Horse_IsSoundOn(playerid))
    {
        Horse_SetSoundOn(playerid,true);
        SendServerMessage(playerid,"Turned horse sound on. It can now replace ambient sound.",MSG_TYPE_INFO);
    }
    else
    {
        Horse_SetSoundOn(playerid,false);
        SendServerMessage(playerid,"Turned horse sound off. Your ambient should now play over it.",MSG_TYPE_INFO);
    }

    return 1;
}

CMD:resynchorse(cmdid,playerid,params[])
{
    #pragma unused cmdid,params
    Horse_SetReloadTick(playerid,HORSE_RELOAD_TICKS + 101);
    return 1;
}

CMD:horsehelp(cmdid,playerid,params[])
{
    #pragma unused cmdid,params
    SendClientMessage(playerid,COLOR_TAB0,"|________________________| Horse Help |________________________|");
    SendClientMessage(playerid,COLOR_TAB1,"/respawnhorse:{DEDEDE} Erases your horse data so you can use /spawnhorse again.");
    SendClientMessage(playerid,COLOR_TAB2,"/spawnhorse:{DEDEDE} Spawns your horse near you, given it's not dead or disabled.");
    SendClientMessage(playerid,COLOR_TAB1,"/revivehorse:{DEDEDE} Revives your killed horse for a small fee at the stablemaster.");
    SendClientMessage(playerid,COLOR_TAB2,"/toghorsetds:{DEDEDE} Toggles the horse textdraws, useful for screenshots.");
    SendClientMessage(playerid,COLOR_TAB2,"/resynchorse{DEDEDE} Resyncs horse animation.");
    SendClientMessage(playerid,COLOR_TAB2,"/nohorsesound{DEDEDE} Toggles the horse sounds on/off");
    return 1;
}

CMD:revivehorse(cmdid,playerid,params[])
{
    #pragma unused cmdid,params
    Horse_Revive(playerid);
    return 1;
}

CMD:saddlebag(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (Horse_IsRiding(playerid))
    {
        SendServerMessage(playerid,"You're not near your horse!",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Horse_NearOwn(playerid,HORSE_MOUNT_RANGE))
    {
        SendServerMessage(playerid,"You're not near your horse.",MSG_TYPE_ERROR);
        return 1;
    }

    new option[32], slot;

    if (sscanf(params,"s[32]I(0)",option,slot))
    {
        SendServerMessage(playerid,"/s(addle)b(ags) [info/store/take]",MSG_TYPE_ERROR);
        return 1;
    }

    new line[160], name[32], rp[ACCOUNT_NAME_LEN], plain[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,rp);
    GetPlayerName(playerid,plain,sizeof(plain));

    if (!strcmp(option,"info",true))
    {
        SendClientMessage(playerid,COLOR_TAB0,"|_______________| Saddlebag Items |_______________|");

        for (new i = 0;i < HORSE_SADDLE_SLOTS;i++)
        {
            if (Horse_GetSaddleWeapon(playerid,i) != 0)
            {
                Weapon_GetName(Horse_GetSaddleWeapon(playerid,i),name);
                format(line,sizeof(line),"[SLOT %d]: %s, with %d ammo",i + 1,name,Horse_GetSaddleAmmo(playerid,i));
            }
            else
            {
                format(line,sizeof(line),"[SLOT %d]: Empty",i + 1);
            }

            SendClientMessage(playerid,i == 0 ? COLOR_TAB1 : COLOR_TAB2,line);
        }

        return 1;
    }

    if (!strcmp(option,"store",true))
    {
        new weapon = Weapons_Get(playerid,E_GUN_SLOT_HAND), ammo = Weapons_GetAmmo(playerid,E_GUN_SLOT_HAND);

        if (weapon == 0)
        {
            SendServerMessage(playerid,"You need to have a weapon equipped for this.",MSG_TYPE_ERROR);
            return 1;
        }

        if (slot < 1 || slot > HORSE_SADDLE_SLOTS)
        {
            SendServerMessage(playerid,"/s(addle)b(ags) store [slot: 1 or 2]",MSG_TYPE_ERROR);
            return 1;
        }

        if (Horse_GetSaddleWeapon(playerid,slot - 1) != 0)
        {
            SendServerMessage(playerid,"That saddlebag slot is already occupied.",MSG_TYPE_ERROR);
            return 1;
        }

        Weapon_GetName(weapon,name);
        Horse_SetSaddle(playerid,slot - 1,weapon,ammo);
        format(line,sizeof(line),"* %s stashes their %s on their horse.",rp,name);
        ProxDetector(playerid,20.0,COLOR_ACTION,line);
        Log_Info("saddlebag","[STORE] %s has stored a (%d) %s with %d ammo in their saddlebag, slot %d",plain,weapon,name,ammo,slot);
        Horse_SaveSaddle(playerid);
        Weapons_RemoveHand(playerid);
        return 1;
    }

    if (!strcmp(option,"take",true))
    {
        if (Weapons_Get(playerid,E_GUN_SLOT_HAND) != 0)
        {
            SendServerMessage(playerid,"You already have a weapon equipped.",MSG_TYPE_ERROR);
            return 1;
        }

        if (Inventory_GetEquipped(playerid) != EQUIP_NONE)
        {
            SendServerMessage(playerid,"You must unequip your item first.",MSG_TYPE_ERROR);
            return 1;
        }

        if (slot < 1 || slot > HORSE_SADDLE_SLOTS)
        {
            SendServerMessage(playerid,"/s(addle)b(ags) take [slot: 1 or 2]",MSG_TYPE_ERROR);
            return 1;
        }

        new weapon = Horse_GetSaddleWeapon(playerid,slot - 1), ammo = Horse_GetSaddleAmmo(playerid,slot - 1);

        if (weapon == 0)
        {
            SendServerMessage(playerid,"You don't have a weapon stored in this slot!",MSG_TYPE_ERROR);
            return 1;
        }

        if (!Weapons_Give(playerid,weapon,ammo))
        {
            return 1;
        }

        Weapon_GetName(weapon,name);
        format(line,sizeof(line),"* %s retrieves a %s from their horse.",rp,name);
        ProxDetector(playerid,20.0,COLOR_ACTION,line);
        Horse_SetSaddle(playerid,slot - 1,0,0);
        Log_Info("saddlebag","[TAKE] %s has taken a (%d) %s with %d ammo from their saddlebag, slot %d",plain,weapon,name,ammo,slot);
        Horse_SaveSaddle(playerid);
    }

    return 1;
}

ALT:sb=CMD:saddlebag;
