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
#define INJURY_CAMERA_MS (60000)
#define INJURY_LEG_TICKS (3)

forward Injury_OnLegsHurt(playerid);

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
static Injury_PlainName(playerid,dest[],size = sizeof(dest))
{
    GetPlayerName(playerid,dest,size);
}

stock Injury_Collapse(playerid,issuerid)
{
    if (Injury_GetMode(playerid) != INJURY_MODE_NORMAL)
    {
        return;
    }

    if (Player_IsBusyWith(playerid,E_PLAYER_BUSY_HORSE))
    {
        Horse_ForceDismount(playerid);
        Player_SetBusy(playerid,E_PLAYER_BUSY_HORSE,false);
    }

    TogglePlayerControllable(playerid,false);
    ApplyAnimation(playerid,"CRACK","crckidle2",4.1,true,false,false,true,0,SYNC_ALL);
    Injury_SetIssuer(playerid,issuerid);
    Injury_SetUntil(playerid,INJURY_SECONDS);
    Injury_SetMode(playerid,INJURY_MODE_INJURED);
    new rp[ACCOUNT_NAME_LEN], line[200], plain[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,rp);
    Injury_PlainName(playerid,plain);
    SendServerMessage(playerid,"You've been critically injured. You will have to wait until someone helps you.",MSG_TYPE_ERROR);
    format(line,sizeof(line),"* %s collapses after being critically injured.",rp);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);

    if (issuerid != INVALID_PLAYER_ID && IsPlayerConnected(issuerid))
    {
        new other[ACCOUNT_NAME_LEN];
        Injury_PlainName(issuerid,other);
        format(line,sizeof(line),"[DEATH] (%d) %s has been injured by (%d) %s.",playerid,plain,issuerid,other);
    }
    else
    {
        format(line,sizeof(line),"[DEATH] (%d) %s has been injured.",playerid,plain);
    }

    SendModeratorWarning(line,MOD_WARNING_MED);
    Log_Info("death","%s",line);
    pawn_call_public("Injury_OnCollapsed","dd",playerid,issuerid);
}

static Injury_Die(playerid)
{
    Corpse_Create(playerid);
    Injury_SetMode(playerid,INJURY_MODE_DYING);
    TogglePlayerSpectating(playerid,true);
    SendServerMessage(playerid,"Your injured mode has expired. Nobody has helped you in time. You died.",MSG_TYPE_INFO);
    Injury_SetUntil(playerid,INJURY_DEAD_SECONDS);
    new line[200], plain[ACCOUNT_NAME_LEN], hand[WEAPON_NAME_LEN], back[WEAPON_NAME_LEN], pants[WEAPON_NAME_LEN];
    Weapon_GetName(Weapons_Get(playerid,E_GUN_SLOT_HAND),hand);
    Weapon_GetName(Weapons_Get(playerid,E_GUN_SLOT_BACK),back);
    Weapon_GetName(Weapons_Get(playerid,E_GUN_SLOT_PANTS),pants);
    Injury_PlainName(playerid,plain);
    format(line,sizeof(line),"%s died and lost guns: [%s (%d)] [%s (%d)] [%s (%d)].",plain,hand,Weapons_GetAmmo(playerid,E_GUN_SLOT_HAND),back,Weapons_GetAmmo(playerid,E_GUN_SLOT_BACK),pants,Weapons_GetAmmo(playerid,E_GUN_SLOT_PANTS));
    Log_Info("death","%s",line);
    Log_Info("death_refund","%s",line);

    if (Injury_GetIssuer(playerid) != INVALID_PLAYER_ID)
    {
        Weapons_RemoveHand(playerid);
        Weapons_SetSlot(playerid,E_GUN_SLOT_BACK,0,0);
        Weapons_SetSlot(playerid,E_GUN_SLOT_PANTS,0,0);
        Weapons_Save(playerid);
    }

    InterpolateCameraPos(playerid,-668.1268,1392.3640,76.4830,-1124.4877,1365.9409,74.9300,INJURY_CAMERA_MS,CAMERA_MOVE);
    InterpolateCameraLookAt(playerid,-668.5658,1393.2677,76.2180,-1123.9965,1366.8170,74.6600,INJURY_CAMERA_MS,CAMERA_MOVE);
    pawn_call_public("Injury_OnDied","dd",playerid,Injury_GetIssuer(playerid));
}

stock Injury_Clear(playerid,bool:respawn)
{
    Injury_ResetWounds(playerid);
    Injury_SetLegs(playerid,false);
    Injury_SetUntil(playerid,0);
    Injury_SetMode(playerid,INJURY_MODE_NORMAL);
    Injury_StopBleeding(playerid);
    Injury_CancelBandage(playerid);
    TogglePlayerSpectating(playerid,false);
    TogglePlayerControllable(playerid,true);
    ClearAnimations(playerid);
    Injury_SetHealth(playerid,INJURY_MAX_HEALTH,INVALID_PLAYER_ID,false);

    if (respawn)
    {
        Point_SetPlayerPoint(playerid,0);
        Spawn_Begin(playerid);
        pawn_call_public("Injury_OnRespawned","d",playerid);
    }
}

stock Injury_StopBleeding(playerid)
{
    Injury_SetBleeding(playerid,false);
    Injury_ClearPuddles(playerid);
}

stock Injury_StartBleeding(playerid)
{
    if (!Injury_IsBleeding(playerid))
    {
        Injury_SetBleeding(playerid,true);
        Injury_SetBleedAt(playerid,gettime() + 1 + random(2));
    }
}

stock Injury_DamageLegs(playerid)
{
    if (Injury_HasLegDamage(playerid))
    {
        return;
    }

    Injury_SetLegs(playerid,true);
    SendServerMessage(playerid,"Your legs have been injured. You may experience trouble walking.",MSG_TYPE_INFO);
    new plain[ACCOUNT_NAME_LEN], line[128];
    Injury_PlainName(playerid,plain);
    format(line,sizeof(line),"[DMG] (%d) %s's legs have been injured.",playerid,plain);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    pawn_call_public("Injury_OnLegsHurt","d",playerid);
}

stock Injury_Explosion(playerid,Float:x,Float:y,Float:z)
{
    if (Injury_GetMode(playerid) != INJURY_MODE_NORMAL)
    {
        return;
    }

    new Float:yards = GetPlayerDistanceFromPoint(playerid,x,y,z);

    if (yards < 5.0)
    {
        Injury_Damage(playerid,100.0);
    }
    else if (yards < 10.0)
    {
        Injury_Damage(playerid,75.0);
    }
    else if (yards < 15.0)
    {
        Injury_Damage(playerid,50.0);
    }
    else if (yards < 25.0)
    {
        Injury_Damage(playerid,25.0);
    }
}

stock bool:Injury_IsRunning(playerid)
{
    new KEY:keys, ud, lr;
    GetPlayerKeys(playerid,keys,ud,lr);

    if (keys & KEY_WALK)
    {
        return false;
    }

    return ud != 0 || lr != 0;
}

stock Injury_Tick()
{
    new now = gettime();

    foreach (new i : Player)
    {
        if (!Injury_IsLoaded(i))
        {
            continue;
        }

        switch (Injury_GetMode(i))
        {
            case INJURY_MODE_INJURED:
            {
                if (Injury_GetUntil(i) >= now)
                {
                    new text[64];
                    format(text,sizeof(text),"~n~~n~~n~~n~~r~Injury time left: %d",Injury_GetUntil(i) - now);
                    GameTextForPlayer(i,text,1000,3);
                    ApplyAnimation(i,"CRACK","crckidle2",4.1,true,false,false,true,0,SYNC_ALL);
                }
                else
                {
                    Injury_Die(i);
                }
            }
            case INJURY_MODE_DYING:
            {
                Injury_SetUntil(i,INJURY_DEAD_SECONDS);
                TogglePlayerSpectating(i,true);
                Injury_SetMode(i,INJURY_MODE_DEAD);
                InterpolateCameraPos(i,-668.1268,1392.3640,76.4830,-1124.4877,1365.9409,74.9300,INJURY_CAMERA_MS,CAMERA_MOVE);
                InterpolateCameraLookAt(i,-668.5658,1393.2677,76.2180,-1123.9965,1366.8170,74.6600,INJURY_CAMERA_MS,CAMERA_MOVE);
            }
            case INJURY_MODE_DEAD:
            {
                if (Injury_GetUntil(i) >= now)
                {
                    new text[64];
                    format(text,sizeof(text),"~n~~n~~n~~n~~r~Injury time left: %d",Injury_GetUntil(i) - now);
                    GameTextForPlayer(i,text,1000,3);
                }
                else
                {
                    Injury_Clear(i,true);
                }
            }
        }

        if (Injury_IsBandaging(i))
        {
            new left = Injury_GetBandageLeft(i) - 1;
            Injury_SetBandageLeft(i,left);

            if (left > 0)
            {
                new text[64];
                format(text,sizeof(text),"~w~Bandaging time left: ~b~%d",left);
                GameTextForPlayer(i,text,950,3);
            }
            else
            {
                Injury_FinishBandage(i);
            }
        }

        if (Injury_IsBleeding(i) && Injury_GetBleedAt(i) <= now)
        {
            Injury_BleedStep(i);
        }

        if (Injury_HasLegDamage(i) && !Player_IsBusyWith(i,E_PLAYER_BUSY_HORSE))
        {
            Injury_LegStep(i);
        }

        if (now % INJURY_FLUSH_SECONDS == 0)
        {
            Injury_FlushHealth(i);
        }
    }

    Corpse_Sweep();
}

static Injury_FinishBandage(playerid)
{
    if (Inventory_FindExtra(playerid,E_ITEM_EXTRA_BANDAGE) == INV_ROW_NONE)
    {
        TogglePlayerControllable(playerid,true);
        SendServerMessage(playerid,"You no longer have the bandage you were using.",MSG_TYPE_ERROR);
        return;
    }

    Inventory_DecreaseExtra(playerid,E_ITEM_EXTRA_BANDAGE,1,false);
    Injury_SetLegs(playerid,false);
    Injury_SetHealth(playerid,Injury_GetHealth(playerid) + INJURY_BANDAGE_HEAL,INVALID_PLAYER_ID,false);
    TogglePlayerControllable(playerid,true);
    Injury_StopBleeding(playerid);
    new rp[ACCOUNT_NAME_LEN], line[128];
    Account_GetRoleplayName(playerid,rp);
    format(line,sizeof(line),"** %s has just bandaged their wounds.",rp);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
    SendServerMessage(playerid,"You've bandaged your wounds. You are no longer bleeding and your legs feel much better.",MSG_TYPE_INFO);
}

static Injury_BleedStep(playerid)
{
    Injury_SetBleedAt(playerid,gettime() + 1 + random(2));

    if (Injury_GetMode(playerid) == INJURY_MODE_NORMAL)
    {
        Injury_SetHealth(playerid,Injury_GetHealth(playerid) - INJURY_BLEED_STEP,INVALID_PLAYER_ID,false);
    }

    Injury_AddPuddle(playerid);
}

static Injury_LegStep(playerid)
{
    if (Injury_GetLegFlag(playerid) && Injury_IsRunning(playerid))
    {
        if (Injury_AddLegTick(playerid) >= INJURY_LEG_TICKS)
        {
            Injury_ResetLegTick(playerid);

            if (!Injury_GetRefall(playerid))
            {
                Injury_SetRefall(playerid,true);
                ApplyAnimation(playerid,"ped","fall_collapse",4.1,false,true,true,false,0,SYNC_ALL);
            }
            else
            {
                Injury_SetRefall(playerid,false);
            }
        }
    }
    else if (!Injury_IsRunning(playerid))
    {
        Injury_SetLegFlag(playerid,false);
        Injury_ResetLegTick(playerid);
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
CMD:helpup(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (Injury_GetMode(playerid) != INJURY_MODE_NORMAL || Player_IsBusyWith(playerid,E_PLAYER_BUSY_JAIL) || Player_IsBusyWith(playerid,E_PLAYER_BUSY_PRISON) || Player_IsBusyWith(playerid,E_PLAYER_BUSY_HORSE) || Law_IsCuffed(playerid))
    {
        SendServerMessage(playerid,"You can't help anyone up right now.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Injury_GetHelpAt(playerid) >= gettime())
    {
        new line[96];
        format(line,sizeof(line),"You need to wait %d seconds before helping someone else up.",Injury_GetHelpAt(playerid) - gettime());
        SendServerMessage(playerid,line,MSG_TYPE_WARN);
        return 1;
    }

    new Float:x, Float:y, Float:z;

    foreach (new i : Player)
    {
        if (i == playerid || Injury_GetMode(i) != INJURY_MODE_INJURED)
        {
            continue;
        }

        GetPlayerPos(i,x,y,z);

        if (!IsPlayerInRangeOfPoint(playerid,INJURY_HELPUP_RANGE,x,y,z))
        {
            continue;
        }

        if (Injury_HasBeenShot(i,INJURY_PART_HEAD))
        {
            SendServerMessage(playerid,"You cannot help up someone who's been shot in the head.",MSG_TYPE_ERROR);
            return 1;
        }

        Injury_SetMode(i,INJURY_MODE_NORMAL);
        Injury_SetUntil(i,0);
        TogglePlayerControllable(i,true);
        ClearAnimations(i);
        Injury_SetHealth(i,INJURY_HELPUP_HEALTH,INVALID_PLAYER_ID,false);
        Injury_SetHelpAt(playerid,INJURY_HELPUP_COOLDOWN);
        new line[200], mine[ACCOUNT_NAME_LEN], other[ACCOUNT_NAME_LEN], plain[ACCOUNT_NAME_LEN];
        Account_GetRoleplayName(playerid,mine);
        Account_GetRoleplayName(i,other);
        Injury_PlainName(playerid,plain);
        format(line,sizeof(line),"** %s has helped up %s.",mine,other);
        ProxDetector(playerid,20.0,COLOR_ACTION,line);
        format(line,sizeof(line),"You have been helped up by (%d) %s. ",playerid,plain);
        SendServerMessage(i,line,MSG_TYPE_INFO);
        pawn_call_public("Injury_OnRevived","dd",i,playerid);
        return 1;
    }

    SendServerMessage(playerid,"You're not near anyone who's injured.",MSG_TYPE_ERROR);
    return 1;
}

CMD:wounds(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (!Staff_RequireModerator(playerid))
    {
        return 1;
    }

    Injury_AddWound(playerid,5 + random(34),3 + random(6),float(random(25)));
    return 1;
}

CMD:showinjuries(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/showinjuries [target]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_IsValidTarget(target))
    {
        SendServerMessage(playerid,"Target doesn't seem to be connected! Try again.",MSG_TYPE_ERROR);
        return 1;
    }

    new count = Injury_WoundCount(target), rp[ACCOUNT_NAME_LEN], line[128];
    Account_GetRoleplayName(target,rp);

    if (count == 0)
    {
        format(line,sizeof(line),"%s (%d) has no visible injuries.",rp,target);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return 1;
    }

    new body[1536], title[64];
    strcat(body,"Bodypart\tWound\tAmount\n",sizeof(body));

    for (new i = 0;i < count;i++)
    {
        new wound[e_WOUND], part[24], type[25];
        Injury_GetWound(target,i,wound);
        Injury_GetBodyPartName(wound[E_WOUND_PART],part);
        Injury_GetWoundType(wound[E_WOUND_WEAPON],type);
        format(line,sizeof(line),"%s \t %s \t (%0.1f)\n",part,type,wound[E_WOUND_AMOUNT]);
        strcat(body,line,sizeof(body));
    }

    format(title,sizeof(title),"%s (%d)'s injuries",rp,target);
    ShowPlayerDialog(playerid,INJURY_DIALOG_ID,DIALOG_STYLE_TABLIST_HEADERS,title,body,"Close","");
    return 1;
}

CMD:stopinjuries(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_BASIC))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/stopinjuries [player]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_IsValidTarget(target))
    {
        SendServerMessage(playerid,"Selected player doesn't exist, they might be offline.",MSG_TYPE_ERROR);
        return 1;
    }

    Injury_Clear(target,false);
    new line[200], mine[ACCOUNT_NAME_LEN], other[ACCOUNT_NAME_LEN];
    Injury_PlainName(playerid,mine);
    Injury_PlainName(target,other);
    format(line,sizeof(line),"Your injuries have been removed by moderator (%d) %s",playerid,mine);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"[STAFF] %s (%d) has removed %s (%d)'s injuries.",mine,playerid,other,target);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    SendServerMessage(playerid,"Please do this command once or twice on said target, to make sure the query passed to the database.",MSG_TYPE_ERROR);
    return 1;
}
