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
#define INJURY_MAX_HEALTH (100.0)
#define INJURY_PUDDLE_MODEL (19836)
#define INJURY_PUDDLE_MAX (25)
#define INJURY_PUDDLE_REFRESH (50)
#define INJURY_SECONDS (300)
#define INJURY_DEAD_SECONDS (60)
#define INJURY_HELPUP_HEALTH (35.0)
#define INJURY_HELPUP_RANGE (3.0)
#define INJURY_HELPUP_COOLDOWN (300)
#define INJURY_CLIENT_HEALTH (1000.0)
#define INJURY_BANDAGE_SECONDS (15)
#define INJURY_BANDAGE_HEAL (20.0)
#define INJURY_BLEED_STEP (0.05)
#define INJURY_FLUSH_SECONDS (5)
#define INJURY_WOUNDS_MAX (50)
#define INJURY_MIN_LEVEL (3)
#define INJURY_DIALOG_ID (546)

enum _:E_INJURY_MODE
{
    INJURY_MODE_NORMAL = 0,
    INJURY_MODE_INJURED,
    INJURY_MODE_DYING,
    INJURY_MODE_DEAD,
}

enum _:E_INJURY_PART
{
    INJURY_PART_TORSO = 3,
    INJURY_PART_GROIN,
    INJURY_PART_RIGHT_ARM,
    INJURY_PART_LEFT_ARM,
    INJURY_PART_RIGHT_LEG,
    INJURY_PART_LEFT_LEG,
    INJURY_PART_HEAD,
}

enum e_WOUND
{
    E_WOUND_WEAPON,
    E_WOUND_PART,
    Float:E_WOUND_AMOUNT,
}

static Float:s_InjuryHealth[MAX_PLAYERS] = {100.0,...};
static s_InjuryMode[MAX_PLAYERS];
static s_InjuryUntil[MAX_PLAYERS];
static s_InjuryIssuer[MAX_PLAYERS] = {INVALID_PLAYER_ID,...};
static s_InjuryHelpAt[MAX_PLAYERS];
static bool:s_InjuryDirty[MAX_PLAYERS];
static bool:s_InjuryLoaded[MAX_PLAYERS];
static s_InjuryBandage[MAX_PLAYERS];
static bool:s_InjuryLegs[MAX_PLAYERS];
static bool:s_InjuryBleeding[MAX_PLAYERS];
static s_InjuryBleedAt[MAX_PLAYERS];
static s_InjuryBleedTicks[MAX_PLAYERS];
static bool:s_InjuryLegFlag[MAX_PLAYERS];
static bool:s_InjuryRefall[MAX_PLAYERS];
static s_InjuryLegTicks[MAX_PLAYERS];
static s_InjuryPuddles[MAX_PLAYERS][25];
static s_InjuryPuddleCount[MAX_PLAYERS];
static List:s_InjuryWounds[MAX_PLAYERS];

forward bool:Horse_ForceDismount(playerid);
forward Injury_Collapse(playerid,issuerid);
forward Injury_OnLoaded(playerid,token);
forward Injury_UseBandage(playerid,uid,item,extra);
forward Injury_OnHealthChanged(playerid,Float:health);
forward Injury_OnCollapsed(playerid,issuerid);
forward Injury_OnRevived(playerid,helperid);
forward Injury_OnDied(playerid,issuerid);
forward Injury_OnRespawned(playerid);

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
stock Float:Injury_GetHealth(playerid)
{
    return s_InjuryHealth[playerid];
}

stock Injury_GetMode(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return INJURY_MODE_NORMAL;
    }

    return s_InjuryMode[playerid];
}

stock bool:Injury_IsLoaded(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_InjuryLoaded[playerid];
}

stock Injury_GetSecondsLeft(playerid)
{
    new left = s_InjuryUntil[playerid] - gettime();
    return left > 0 ? left : 0;
}

stock Injury_GetIssuer(playerid)
{
    return s_InjuryIssuer[playerid];
}

stock bool:Injury_IsBleeding(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_InjuryBleeding[playerid];
}

stock bool:Injury_HasLegDamage(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_InjuryLegs[playerid];
}

stock bool:Injury_IsBandaging(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_InjuryBandage[playerid] > 0;
}

stock Injury_GetPuddleCount(playerid)
{
    return s_InjuryPuddleCount[playerid];
}

stock Injury_WriteMode(playerid)
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_dmgmode = %d WHERE character_id = %d",s_InjuryMode[playerid],Character_GetId(playerid)));
}

stock Injury_SetMode(playerid,mode)
{
    if (s_InjuryMode[playerid] != mode)
    {
        s_InjuryMode[playerid] = mode;
        Injury_WriteMode(playerid);
    }
}

stock Injury_SetUntil(playerid,seconds)
{
    s_InjuryUntil[playerid] = gettime() + seconds;
}

stock Injury_SetIssuer(playerid,issuerid)
{
    s_InjuryIssuer[playerid] = issuerid;
}

stock Injury_GetUntil(playerid)
{
    return s_InjuryUntil[playerid];
}

stock Injury_CancelBandage(playerid)
{
    s_InjuryBandage[playerid] = 0;
}

stock Injury_StartBandage(playerid)
{
    s_InjuryBandage[playerid] = INJURY_BANDAGE_SECONDS;
}

stock Injury_GetBandageLeft(playerid)
{
    return s_InjuryBandage[playerid];
}

stock Injury_SetBandageLeft(playerid,left)
{
    s_InjuryBandage[playerid] = left;
}

stock Injury_FlushHealth(playerid)
{
    if (!s_InjuryDirty[playerid] || Character_GetId(playerid) <= 0)
    {
        return;
    }

    s_InjuryDirty[playerid] = false;
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_health = %f WHERE character_id = %d",s_InjuryHealth[playerid],Character_GetId(playerid)));
}

stock bool:Injury_SetHealth(playerid,Float:amount,issuerid = INVALID_PLAYER_ID,bool:damage = true)
{
    if (!s_InjuryLoaded[playerid] || s_InjuryMode[playerid] != INJURY_MODE_NORMAL)
    {
        return false;
    }

    SetPlayerHealth(playerid,INJURY_CLIENT_HEALTH);

    if (amount > INJURY_MAX_HEALTH)
    {
        amount = INJURY_MAX_HEALTH;
    }

    s_InjuryHealth[playerid] = amount;
    s_InjuryDirty[playerid] = true;
    Hud_SetHealth(playerid,amount < 0.0 ? 0.0 : amount);
    pawn_call_public("Injury_OnHealthChanged","df",playerid,amount);

    if (amount <= 0.0)
    {
        Injury_Collapse(playerid,issuerid);
    }

    if (damage)
    {
        s_InjuryBandage[playerid] = 0;
    }

    if (issuerid != INVALID_PLAYER_ID)
    {
        new name[ACCOUNT_NAME_LEN], other[ACCOUNT_NAME_LEN];
        GetPlayerName(playerid,name,sizeof(name));
        GetPlayerName(issuerid,other,sizeof(other));
        Log_Info("health","%s has been damaged by %s. Amount: %f",name,other,amount);
    }

    return true;
}

stock bool:Injury_Damage(playerid,Float:amount,issuerid = INVALID_PLAYER_ID)
{
    return Injury_SetHealth(playerid,s_InjuryHealth[playerid] - amount,issuerid);
}

stock Injury_LoadState(playerid,Float:health,mode)
{
    s_InjuryHealth[playerid] = health;
    s_InjuryMode[playerid] = mode != 0 ? INJURY_MODE_DYING : INJURY_MODE_NORMAL;
    s_InjuryUntil[playerid] = 0;
    s_InjuryLoaded[playerid] = true;
    SetPlayerHealth(playerid,INJURY_CLIENT_HEALTH);
    Hud_SetHealth(playerid,health);
}

stock Injury_RefreshClient(playerid)
{
    if (s_InjuryLoaded[playerid])
    {
        SetPlayerHealth(playerid,INJURY_CLIENT_HEALTH);
    }
}

stock Injury_ResetHealthState(playerid)
{
    s_InjuryHealth[playerid] = INJURY_MAX_HEALTH;
    s_InjuryMode[playerid] = INJURY_MODE_NORMAL;
    s_InjuryUntil[playerid] = 0;
    s_InjuryIssuer[playerid] = INVALID_PLAYER_ID;
    s_InjuryBandage[playerid] = 0;
    s_InjuryLegs[playerid] = false;
    s_InjuryDirty[playerid] = false;
    s_InjuryLoaded[playerid] = false;
}

stock Injury_SetBleeding(playerid,bool:bleeding)
{
    s_InjuryBleeding[playerid] = bleeding;
    s_InjuryBleedTicks[playerid] = 0;
}

stock Injury_SetBleedAt(playerid,seconds)
{
    s_InjuryBleedAt[playerid] = seconds;
}

stock Injury_GetBleedAt(playerid)
{
    return s_InjuryBleedAt[playerid];
}

stock bool:Injury_GetLegFlag(playerid)
{
    return s_InjuryLegFlag[playerid];
}

stock Injury_SetLegFlag(playerid,bool:flag)
{
    s_InjuryLegFlag[playerid] = flag;
}

stock Injury_AddLegTick(playerid)
{
    return ++s_InjuryLegTicks[playerid];
}

stock Injury_ResetLegTick(playerid)
{
    s_InjuryLegTicks[playerid] = 0;
}

stock bool:Injury_GetRefall(playerid)
{
    return s_InjuryRefall[playerid];
}

stock Injury_SetRefall(playerid,bool:value)
{
    s_InjuryRefall[playerid] = value;
}

stock Injury_ClearPuddles(playerid)
{
    for (new i = 0;i < s_InjuryPuddleCount[playerid];i++)
    {
        DestroyDynamicObject(STREAMER_TAG_OBJECT:s_InjuryPuddles[playerid][i]);
    }

    s_InjuryPuddleCount[playerid] = 0;
}

stock Injury_AddPuddle(playerid)
{
    if (++s_InjuryBleedTicks[playerid] >= INJURY_PUDDLE_REFRESH)
    {
        s_InjuryBleedTicks[playerid] = 0;
        Injury_ClearPuddles(playerid);
    }

    if (s_InjuryPuddleCount[playerid] >= INJURY_PUDDLE_MAX)
    {
        return;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    s_InjuryPuddles[playerid][s_InjuryPuddleCount[playerid]++] = _:CreateDynamicObject(INJURY_PUDDLE_MODEL,x,y,z - 0.99,0.0,0.0,0.0,GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid));
}

stock Injury_SetLegs(playerid,bool:damaged)
{
    s_InjuryLegs[playerid] = damaged;
}

stock Injury_SetHelpAt(playerid,seconds)
{
    s_InjuryHelpAt[playerid] = gettime() + seconds;
}

stock Injury_GetHelpAt(playerid)
{
    return s_InjuryHelpAt[playerid];
}

stock Injury_WoundCount(playerid)
{
    return list_valid(s_InjuryWounds[playerid]) ? list_size(s_InjuryWounds[playerid]) : 0;
}

stock bool:Injury_AddWound(playerid,weapon,part,Float:amount)
{
    if (!list_valid(s_InjuryWounds[playerid]))
    {
        s_InjuryWounds[playerid] = list_new();
    }

    if (list_size(s_InjuryWounds[playerid]) >= INJURY_WOUNDS_MAX)
    {
        return false;
    }

    new wound[e_WOUND];
    wound[E_WOUND_WEAPON] = weapon;
    wound[E_WOUND_PART] = part;
    wound[E_WOUND_AMOUNT] = amount;
    list_add_arr(s_InjuryWounds[playerid],wound);
    return true;
}

stock bool:Injury_GetWound(playerid,index,wound[e_WOUND])
{
    if (index < 0 || index >= Injury_WoundCount(playerid))
    {
        return false;
    }

    list_get_arr(s_InjuryWounds[playerid],index,wound);
    return true;
}

stock bool:Injury_HasBeenShot(playerid,part)
{
    for (new i = 0,count = Injury_WoundCount(playerid);i < count;i++)
    {
        new wound[e_WOUND];
        list_get_arr(s_InjuryWounds[playerid],i,wound);

        if (wound[E_WOUND_PART] == part)
        {
            return true;
        }
    }

    return false;
}

stock Injury_InitWounds(playerid)
{
    s_InjuryWounds[playerid] = INVALID_LIST;
}

stock Injury_ResetWounds(playerid)
{
    if (list_valid(s_InjuryWounds[playerid]))
    {
        list_delete(s_InjuryWounds[playerid]);
        s_InjuryWounds[playerid] = INVALID_LIST;
    }
}

stock Injury_GetBodyPartName(part,dest[],size = sizeof(dest))
{
    switch (part)
    {
        case INJURY_PART_GROIN:
        {
            strcopy(dest,"Groin",size);
        }
        case INJURY_PART_TORSO:
        {
            strcopy(dest,"Torso",size);
        }
        case INJURY_PART_LEFT_ARM:
        {
            strcopy(dest,"Left Arm",size);
        }
        case INJURY_PART_RIGHT_ARM:
        {
            strcopy(dest,"Right Arm",size);
        }
        case INJURY_PART_LEFT_LEG:
        {
            strcopy(dest,"Left Leg",size);
        }
        case INJURY_PART_RIGHT_LEG:
        {
            strcopy(dest,"Right Leg",size);
        }
        case INJURY_PART_HEAD:
        {
            strcopy(dest,"Head",size);
        }
        default:
        {
            strcopy(dest,"Unknown",size);
        }
    }
}

stock Injury_GetWoundType(weapon,dest[],size = sizeof(dest))
{
    switch (weapon)
    {
        case 1 .. 3, 5 .. 7, 10 .. 15:
        {
            strcopy(dest,"Blunt Trauma",size);
        }
        case 4, 8, 9:
        {
            strcopy(dest,"Stab Wound",size);
        }
        case 22 .. 34:
        {
            strcopy(dest,"Gunshot Wound",size);
        }
        case 16, 18, 35 .. 37, 39, 40:
        {
            strcopy(dest,"Burn Wound",size);
        }
        default:
        {
            strcopy(dest,"Unknown",size);
        }
    }
}

stock Float:Injury_GetModifier(weapon,part,Float:distance)
{
    switch (weapon)
    {
        case 5:
        {
            return 10.0;
        }
        case 4:
        {
            return 15.0;
        }
    }

    new bool:head = part == INJURY_PART_HEAD, bool:torso = part == INJURY_PART_TORSO, bool:groin = part == INJURY_PART_GROIN;
    new tier = distance <= 3.0 ? 0 : (distance <= 7.5 ? 1 : 2), limbs = !head && !torso && !groin;

    switch (weapon)
    {
        case 24:
        {
            if (head)
            {
                return distance >= 12.5 ? 75.0 : 100.0;
            }

            if (torso)
            {
                return tier == 0 ? 65.0 : (tier == 1 ? 50.0 : 45.0);
            }

            if (groin)
            {
                return tier == 0 ? 70.0 : (tier == 1 ? 45.0 : 25.0);
            }

            return limbs ? (tier == 0 ? 40.0 : (tier == 1 ? 35.0 : 25.0)) : 0.0;
        }
        case 25, 26:
        {
            if (head)
            {
                return distance >= 12.5 ? 65.0 : 100.0;
            }

            if (torso)
            {
                return tier == 0 ? 80.0 : (tier == 1 ? 65.0 : 25.0);
            }

            if (groin)
            {
                return tier == 0 ? 60.0 : (tier == 1 ? 35.0 : 15.0);
            }

            return tier == 0 ? 40.0 : (tier == 1 ? 35.0 : 25.0);
        }
        case 33:
        {
            if (head)
            {
                return distance >= 12.5 ? 90.0 : 100.0;
            }

            if (torso)
            {
                return tier == 0 ? 100.0 : (tier == 1 ? 95.0 : 90.0);
            }

            if (groin)
            {
                return tier == 0 ? 95.0 : (tier == 1 ? 90.0 : 85.0);
            }

            return tier == 0 ? 75.0 : (tier == 1 ? 70.0 : 65.0);
        }
        case 34:
        {
            if (head)
            {
                return distance >= 12.5 ? 90.0 : 100.0;
            }

            if (torso)
            {
                return 100.0;
            }

            if (groin)
            {
                return distance <= 3.0 ? 100.0 : 95.0;
            }

            return tier == 0 ? 80.0 : (tier == 1 ? 75.0 : 70.0);
        }
    }

    return 0.0;
}

