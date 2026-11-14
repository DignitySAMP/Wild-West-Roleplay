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
#define INJURY_FALL_THRESHOLD (5.0)
#define INJURY_STEALTH_AMOUNT (1000.0)

static s_InjuryHackCount[MAX_PLAYERS];
static s_InjuryKnifeCount[MAX_PLAYERS];

forward Injury_KnifeRelease(playerid,token);

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
static bool:Injury_Behind(attacker,target)
{
    new Float:ax, Float:ay, Float:az, Float:tx, Float:ty, Float:tz, Float:angle, Float:diff;
    GetPlayerPos(attacker,ax,ay,az);
    GetPlayerPos(target,tx,ty,tz);
    GetPlayerFacingAngle(target,angle);
    diff = atan2(ty - ay,tx - ax) - 90.0 - angle;

    while (diff > 180.0)
    {
        diff -= 360.0;
    }

    while (diff < -180.0)
    {
        diff += 360.0;
    }

    return floatabs(diff) < 90.0;
}

static Injury_React(playerid,issuerid,weapon,part)
{
    new bool:behind = Injury_Behind(issuerid,playerid);

    switch (part)
    {
        case INJURY_PART_HEAD:
        {
            if (weapon == 33 || weapon == 34)
            {
                ApplyAnimation(playerid,"PED",behind ? "KO_shot_front" : "KO_SHOT_FACE",4.1,false,true,true,true,1,SYNC_ALL);
            }
            else if (weapon == 24)
            {
                ApplyAnimation(playerid,"PED",behind ? "KO_shot_front" : "KO_shot_stom",4.1,false,true,true,true,1,SYNC_ALL);
            }
            else
            {
                ApplyAnimation(playerid,"PED",behind ? "KO_shot_front" : "BIKE_fall_off",4.1,false,true,true,true,1,SYNC_ALL);
            }
        }
        case INJURY_PART_TORSO, INJURY_PART_GROIN:
        {
            if (weapon == 25 || weapon == 26)
            {
                ApplyAnimation(playerid,"PED",behind ? "KO_shot_front" : "BIKE_fall_off",4.1,false,true,true,true,1,SYNC_ALL);
            }
            else
            {
                ApplyAnimation(playerid,"PED",behind ? "DAM_stomach_frmBK" : "DAM_stomach_frmFT",4.1,false,true,true,true,1,SYNC_ALL);
            }
        }
        case INJURY_PART_LEFT_ARM:
        {
            ApplyAnimation(playerid,"PED",behind ? "DAM_armL_frmBK" : "DAM_armL_frmFT",4.1,false,true,true,true,1,SYNC_ALL);
        }
        case INJURY_PART_RIGHT_ARM:
        {
            ApplyAnimation(playerid,"PED",behind ? "DAM_armR_frmBK" : "DAM_armR_frmFT",4.1,false,true,true,true,1,SYNC_ALL);
        }
        case INJURY_PART_LEFT_LEG:
        {
            ApplyAnimation(playerid,"PED",behind ? "DAM_LegL_frmBK" : "DAM_LegL_frmFT",4.1,false,true,true,true,1,SYNC_ALL);
        }
        case INJURY_PART_RIGHT_LEG:
        {
            ApplyAnimation(playerid,"PED",behind ? "DAM_LegR_frmBK" : "DAM_LegR_frmFT",4.1,false,true,true,true,1,SYNC_ALL);
        }
    }
}

stock bool:Injury_IsFalling(playerid)
{
    new index = GetPlayerAnimationIndex(playerid);
    return (index >= 958 && index <= 979) || index == 1130 || index == 1195 || index == 1132;
}

stock Injury_Hit(playerid,issuerid,weapon,part,Float:amount)
{
    new Float:x, Float:y, Float:z, Float:distance;
    GetPlayerPos(playerid,x,y,z);
    distance = GetPlayerDistanceFromPoint(issuerid,x,y,z);

    if (weapon != 5)
    {
        Injury_StartBleeding(playerid);
    }

    new Float:modifier = Injury_GetModifier(weapon,part,distance);

    if (modifier <= 0.0)
    {
        return;
    }

    Injury_React(playerid,issuerid,weapon,part);

    if (part == INJURY_PART_LEFT_LEG || part == INJURY_PART_RIGHT_LEG)
    {
        Injury_DamageLegs(playerid);
    }

    Injury_AddWound(playerid,weapon,part,amount);
    Injury_Damage(playerid,modifier,issuerid);

    if (Injury_GetMode(playerid) == INJURY_MODE_INJURED && Injury_GetIssuer(playerid) == issuerid)
    {
        new line[220], mine[ACCOUNT_NAME_LEN], other[ACCOUNT_NAME_LEN], gun[WEAPON_NAME_LEN];
        Account_GetRoleplayName(issuerid,mine);
        Account_GetRoleplayName(playerid,other);
        Weapon_GetName(weapon,gun);
        format(line,sizeof(line),"(%d) %s has injured (%d) %s with a (%d) %s (%d ammo)",issuerid,mine,playerid,other,weapon,gun,Weapons_GetAmmo(issuerid,E_GUN_SLOT_HAND));
        SendModeratorWarning(line,MOD_WARNING_MED);
        Log_Info("dmg/injury","%s",line);
    }
}

public Injury_KnifeRelease(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        TogglePlayerControllable(playerid,true);
    }

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

hook OnPlayerTakeDamage(playerid,issuerid,Float:amount,WEAPON:weaponid,bodypart)
{
    if (!Injury_IsLoaded(playerid))
    {
        return;
    }

    new weapon = _:weaponid;
    SetPlayerHealth(playerid,INJURY_CLIENT_HEALTH);

    if (weapon == 0)
    {
        return;
    }

    new mode = Injury_GetMode(playerid);

    if (Staff_IsOnDuty(playerid) || mode == INJURY_MODE_DYING || mode == INJURY_MODE_DEAD)
    {
        return;
    }

    if ((Player_IsBusyWith(playerid,E_PLAYER_BUSY_HORSE) && issuerid != INVALID_PLAYER_ID) || issuerid == playerid)
    {
        Injury_SetLegs(playerid,false);
        return;
    }

    if (Injury_IsFalling(playerid) && amount > INJURY_FALL_THRESHOLD && !Player_IsBusyWith(playerid,E_PLAYER_BUSY_HORSE))
    {
        SendServerMessage(playerid,"You have hurt your leg from falling. You will have trouble walking.",MSG_TYPE_WARN);
        Injury_DamageLegs(playerid);
        return;
    }

    if (issuerid == INVALID_PLAYER_ID || !IsPlayerConnected(issuerid))
    {
        return;
    }

    if (weapon == 4 && amount > INJURY_STEALTH_AMOUNT)
    {
        ClearAnimations(issuerid,SYNC_ALL);

        if (++s_InjuryKnifeCount[issuerid] >= 3)
        {
            s_InjuryKnifeCount[issuerid] = 0;
            TogglePlayerControllable(issuerid,false);
            SendServerMessage(issuerid,"You're not allowed to perform stealth kills.",MSG_TYPE_ERROR);
            SetTimerEx("Injury_KnifeRelease",1000,false,"dd",issuerid,Account_GetToken(issuerid));
        }

        return;
    }

    if (Character_GetLevel(issuerid) < INJURY_MIN_LEVEL)
    {
        new line[220], name[ACCOUNT_NAME_LEN];
        GetPlayerName(issuerid,name,sizeof(name));
        format(line,sizeof(line),"[HACKER] (%d) %s has used a weapon whilst being below lvl 3. (server: %d, client: %d) if server = 0 & client not, theyre hacking",issuerid,name,Weapons_Get(issuerid,E_GUN_SLOT_HAND),_:GetPlayerWeapon(issuerid));
        SendModeratorWarning(line,MOD_WARNING_MED);
        SendClientMessage(issuerid,COLOR_RED,"You can't use a weapon whilst not being level 3. Your weapons been reset and damage mitigated. For a refund, post this on the forums:");
        format(line,sizeof(line),"[REFUND DATA]: gunid: %d (client: %d), ammo: %d (client: %d)",Weapons_Get(issuerid,E_GUN_SLOT_HAND),_:GetPlayerWeapon(issuerid),Weapons_GetAmmo(issuerid,E_GUN_SLOT_HAND),GetPlayerAmmo(issuerid));
        SendClientMessage(issuerid,COLOR_YELLOW,line);
        Log_Info("refunddata","%s refund data: %s",name,line);
        Weapons_RemoveHand(issuerid);

        if (++s_InjuryHackCount[issuerid] >= 3)
        {
            s_InjuryHackCount[issuerid] = 0;
            format(line,sizeof(line),"[HACKER] (%d) %s has been kicked for using a weapon whilst being lower than level 3 three times.",issuerid,name);
            SendModeratorWarning(line,MOD_WARNING_HIGH);
            SendClientMessage(issuerid,COLOR_RED,"You've been kicked for using a weapon whilst being below level three more than three times.");
            SendClientMessage(issuerid,COLOR_RED,"Your information (IP, location, guns) has been logged and the moderators are made aware.");
            Log_Info("anticheat","%s has been kicked for using a weapon whilst being below level 3 three times.",name);
            Account_QueueKick(issuerid);
        }

        return;
    }

    if (Weapons_Get(issuerid,E_GUN_SLOT_HAND) == 0)
    {
        return;
    }

    Injury_Hit(playerid,issuerid,weapon,bodypart,amount);
}

hook OnPlayerGiveDamage(playerid,damagedid,Float:amount,WEAPON:weaponid,bodypart)
{
    if (damagedid == INVALID_PLAYER_ID || !IsPlayerConnected(damagedid) || !Injury_IsLoaded(damagedid))
    {
        return;
    }

    if (Injury_GetMode(damagedid) == INJURY_MODE_INJURED && bodypart == INJURY_PART_HEAD)
    {
        Injury_SetUntil(damagedid,-1);
        SendServerMessage(damagedid,"You got shot in the head whilst being critically injured and died.",MSG_TYPE_INFO);
        SetPlayerHealth(damagedid,INJURY_CLIENT_HEALTH);
    }
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (Injury_HasLegDamage(playerid) && !Player_IsBusyWith(playerid,E_PLAYER_BUSY_HORSE))
    {
        if ((newkeys & KEY_SPRINT) && Injury_IsRunning(playerid))
        {
            Injury_SetLegFlag(playerid,true);
        }

        if (newkeys & KEY_JUMP)
        {
            ApplyAnimation(playerid,"GYMNASIUM","gym_jog_falloff",4.1,false,true,true,false,0,SYNC_ALL);
        }
    }

    if ((newkeys & KEY_FIRE) && Injury_IsBandaging(playerid))
    {
        Injury_CancelBandage(playerid);
        TogglePlayerControllable(playerid,true);
        SendServerMessage(playerid,"You've cancelled bandaging yourself.",MSG_TYPE_WARN);
    }
}

hook Dynamite_OnBlast(playerid,Float:x,Float:y,Float:z)
{
    Injury_Explosion(playerid,x,y,z);
}
