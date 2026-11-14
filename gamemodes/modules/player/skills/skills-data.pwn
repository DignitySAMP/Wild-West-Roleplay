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
#define SKILL_COUNT (15)
#define SKILL_NAME_LEN (32)
#define SKILL_COLUMN_LEN (20)

enum _:E_SKILL
{
    E_SKILL_GUN_MOVEMENT = 0,
    E_SKILL_GUN_AIMING,
    E_SKILL_GUN_HOLSTER,
    E_SKILL_JOB_FISHING,
    E_SKILL_JOB_LUMBER,
    E_SKILL_JOB_MINING,
    E_SKILL_JOB_HUNTING,
    E_SKILL_JOB_FARMING,
    E_SKILL_JOB_BLACKSMITH,
    E_SKILL_MISC_SWIMMING,
    E_SKILL_MISC_HEALTH,
    E_SKILL_MELEE_STYLE,
    E_SKILL_MELEE_UNARMED,
    E_SKILL_MELEE_KNIFE,
    E_SKILL_MELEE_KNIFE_THROW,
}

static const s_SkillNames[SKILL_COUNT][SKILL_NAME_LEN] =
{
    "Weapon Movement",
    "Weapon Aiming",
    "Weapon Holstering",
    "Fishing",
    "Woodcutting",
    "Mining",
    "Hunting",
    "Farming",
    "Blacksmith",
    "Swimming",
    "Health",
    "Fight Style",
    "Unarmed",
    "Knife",
    "Knife Throwing"
};

static const s_SkillMax[SKILL_COUNT] = {6,4,3,2,3,3,0,0,6,2,0,1,0,0,1};

static const s_SkillColumns[SKILL_COUNT][SKILL_COLUMN_LEN] =
{
    "GUN_movement",
    "GUN_aiming",
    "GUN_holster",
    "JOB_fishing",
    "JOB_lumber",
    "JOB_mining",
    "JOB_hunting",
    "JOB_farming",
    "JOB_blacksmith",
    "MISC_swimming",
    "MISC_health",
    "MELEE_style",
    "MELEE_unarmed",
    "MELEE_knife",
    "MELEE_knife_throw"
};

static s_SkillValue[MAX_PLAYERS][SKILL_COUNT];
static bool:s_SkillLoaded[MAX_PLAYERS];

forward Skills_OnLoaded(playerid,token);
forward Skills_OnChanged(playerid);

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
stock bool:Skills_IsLoaded(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_SkillLoaded[playerid];
}

stock Skills_Get(playerid,skill)
{
    if (!Skills_IsLoaded(playerid) || skill < 0 || skill >= SKILL_COUNT)
    {
        return 0;
    }

    return s_SkillValue[playerid][skill];
}

stock Skills_GetMax(skill)
{
    return skill >= 0 && skill < SKILL_COUNT ? s_SkillMax[skill] : 0;
}

stock Skills_GetName(skill,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (skill >= 0 && skill < SKILL_COUNT)
    {
        strcopy(dest,s_SkillNames[skill],size);
    }
}

stock Skills_FindByName(const name[])
{
    for (new i = 0;i < SKILL_COUNT;i++)
    {
        if (!strcmp(name,s_SkillNames[i],true))
        {
            return i;
        }
    }

    return -1;
}

stock Skills_CostFor(level)
{
    return level <= 0 ? 1 : level * 2;
}

stock Skills_SpentOn(level)
{
    new total = 0;

    for (new i = 0;i < level;i++)
    {
        total += Skills_CostFor(i);
    }

    return total;
}

stock Skills_SpentTotal(playerid)
{
    new total = 0;

    for (new i = 0;i < SKILL_COUNT;i++)
    {
        total += Skills_SpentOn(Skills_Get(playerid,i));
    }

    return total;
}

static Skills_SaveOne(playerid,skill)
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE character_skills SET %s = %d WHERE character_id = %d",s_SkillColumns[skill],s_SkillValue[playerid][skill],Character_GetId(playerid)));
}

stock bool:Skills_Set(playerid,skill,value)
{
    if (!Skills_IsLoaded(playerid) || skill < 0 || skill >= SKILL_COUNT || value < 0 || value > s_SkillMax[skill])
    {
        return false;
    }

    s_SkillValue[playerid][skill] = value;
    Skills_SaveOne(playerid,skill);
    pawn_call_public("Skills_OnChanged","d",playerid);
    return true;
}

stock bool:Skills_LevelUp(playerid,skill)
{
    if (!Skills_IsLoaded(playerid) || skill < 0 || skill >= SKILL_COUNT)
    {
        return false;
    }

    new points = Levels_GetSkillPoints(playerid), line[160], name[SKILL_NAME_LEN];

    if (points <= 0)
    {
        SendServerMessage(playerid,"You have no skillpoints. You need at least one to level up a skill.",MSG_TYPE_ERROR);
        return false;
    }

    if (s_SkillValue[playerid][skill] >= s_SkillMax[skill])
    {
        SendServerMessage(playerid,"You are already at the max level of this skill. Level up a different skill.",MSG_TYPE_ERROR);
        return false;
    }

    new required = Skills_CostFor(s_SkillValue[playerid][skill]);
    Skills_GetName(skill,name);

    if (required > points)
    {
        format(line,sizeof(line),"You don't have enough skillpoints! You need %i more skill point%s to level up your %s skill.",required - points,required == 1 ? ("") : ("s"),name);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return false;
    }

    Levels_SetSkillPoints(playerid,points - required);
    s_SkillValue[playerid][skill]++;
    Skills_SaveOne(playerid,skill);
    format(line,sizeof(line),"Advanced your %s skill. It's now %d/%d. You have %d skillpoints left.",name,s_SkillValue[playerid][skill],s_SkillMax[skill],points - required);
    SendServerMessage(playerid,line,MSG_TYPE_ERROR);
    pawn_call_public("Skills_OnChanged","d",playerid);
    return true;
}

stock bool:Skills_Reset(playerid)
{
    if (!Skills_IsLoaded(playerid))
    {
        return false;
    }

    if (Levels_GetSkillPoints(playerid) != 0)
    {
        SendServerMessage(playerid,"You need to spend all your skillpoints before refunding them.",MSG_TYPE_ERROR);
        return false;
    }

    new refund = Skills_SpentTotal(playerid), line[128];

    for (new i = 0;i < SKILL_COUNT;i++)
    {
        s_SkillValue[playerid][i] = 0;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE character_skills SET GUN_movement = 0, GUN_aiming = 0, GUN_holster = 0, JOB_fishing = 0, JOB_lumber = 0, JOB_mining = 0, JOB_hunting = 0, JOB_farming = 0, JOB_blacksmith = 0, MISC_swimming = 0, MISC_health = 0, MELEE_style = 0, MELEE_unarmed = 0, MELEE_knife = 0, MELEE_knife_throw = 0 WHERE character_id = %d",Character_GetId(playerid)));
    Levels_SetSkillPoints(playerid,refund);
    format(line,sizeof(line),"You've been refunded %d skillpoints. All your skills have been reset.",refund);
    SendServerMessage(playerid,line,MSG_TYPE_WARN);
    pawn_call_public("Skills_OnChanged","d",playerid);
    return true;
}

static Skills_ResetState(playerid)
{
    for (new i = 0;i < SKILL_COUNT;i++)
    {
        s_SkillValue[playerid][i] = 0;
    }

    s_SkillLoaded[playerid] = false;
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
public Skills_OnChanged(playerid)
{
    return 1;
}

public Skills_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    if (cache_num_rows() > 0)
    {
        for (new i = 0;i < SKILL_COUNT;i++)
        {
            cache_get_value_name_int(0,s_SkillColumns[i],s_SkillValue[playerid][i]);

            if (s_SkillValue[playerid][i] > s_SkillMax[i])
            {
                s_SkillValue[playerid][i] = s_SkillMax[i];
            }
        }
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO character_skills (character_id) VALUES (%d)",Character_GetId(playerid)));
    }

    s_SkillLoaded[playerid] = true;
    pawn_call_public("Skills_OnChanged","d",playerid);
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
    Skills_ResetState(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Skills_ResetState(playerid);
}

hook Character_OnLoad(playerid,characterid)
{
    Skills_ResetState(playerid);
    mysql_tquery_s(g_Mysql,str_format("SELECT * FROM character_skills WHERE character_id = %d",characterid),"Skills_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    Skills_ResetState(playerid);
}
