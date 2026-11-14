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
#define LEVELS_EXP_PER_LEVEL (8)
#define LEVELS_RULECHECK_LEVEL (5)

static s_LevelsSkillPoints[MAX_PLAYERS];
static bool:s_LevelsLoaded[MAX_PLAYERS];

forward Levels_OnChange(playerid,level,expLeft,skillPoints);
forward Levels_OnLoaded(playerid,token);

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
stock Levels_GetSkillPoints(playerid)
{
    return s_LevelsSkillPoints[playerid];
}

stock bool:Levels_SetSkillPoints(playerid,points)
{
    if (points < 0 || !Player_IsReady(playerid))
    {
        return false;
    }

    s_LevelsSkillPoints[playerid] = points;
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_skillpoints = %d WHERE character_id = %d",points,Character_GetId(playerid)));
    pawn_call_public("Levels_OnChange","dddd",playerid,Character_GetLevel(playerid),Character_GetExperienceLeft(playerid),points);
    return true;
}

stock bool:Levels_SetLevel(playerid,level)
{
    if (level <= 0 || !Player_IsReady(playerid))
    {
        return false;
    }

    Character_SetLevelCached(playerid,level);
    SetPlayerScore(playerid,level);
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_level = %d WHERE character_id = %d",level,Character_GetId(playerid)));
    pawn_call_public("Levels_OnChange","dddd",playerid,level,Character_GetExperienceLeft(playerid),s_LevelsSkillPoints[playerid]);
    return true;
}

stock bool:Levels_GiveExperience(playerid,amount)
{
    if (amount <= 0 || !Player_IsReady(playerid))
    {
        return false;
    }

    new level = Character_GetLevel(playerid), left = Character_GetExperienceLeft(playerid) - amount, line[160];
    format(line,sizeof(line),"You've been given %d experience. You now need %d left to level up.",amount,left);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);

    if (left <= 0)
    {
        level++;
        left = LEVELS_EXP_PER_LEVEL * level;
        s_LevelsSkillPoints[playerid]++;
        Character_SetLevelCached(playerid,level);
        format(line,sizeof(line),"You've gained a new level! You're now level %d. You will now need %d experience to level up again.",level,left);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        format(line,sizeof(line),"You've been given a skillpoint. You now have %d. Use /skills to use them.",s_LevelsSkillPoints[playerid]);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        SetPlayerScore(playerid,level);

        if (level >= LEVELS_RULECHECK_LEVEL && Account_GetRuleCheck(playerid) == 1)
        {
            Account_SetRuleCheck(playerid,0);
            mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_rulecheck = 0 WHERE account_id = %d",Account_GetId(playerid)));
        }
    }

    Character_SetExperienceLeftCached(playerid,left);
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_level = %d, character_expleft = %d, character_skillpoints = %d WHERE character_id = %d",level,left,s_LevelsSkillPoints[playerid],Character_GetId(playerid)));
    pawn_call_public("Levels_OnChange","dddd",playerid,level,left,s_LevelsSkillPoints[playerid]);
    return true;
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
public Levels_OnChange(playerid,level,expLeft,skillPoints)
{
    return 1;
}

public Levels_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    s_LevelsSkillPoints[playerid] = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_skillpoints",s_LevelsSkillPoints[playerid]);
    }

    s_LevelsLoaded[playerid] = true;
    pawn_call_public("Levels_OnChange","dddd",playerid,Character_GetLevel(playerid),Character_GetExperienceLeft(playerid),s_LevelsSkillPoints[playerid]);
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

hook OnMigrationRun()
{
    Migration_Add("levels-1-skillpoints","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_skillpoints INT NOT NULL DEFAULT 0");
}

hook OnPlayerConnect(playerid)
{
    s_LevelsSkillPoints[playerid] = 0;
    s_LevelsLoaded[playerid] = false;
}

hook Character_OnLoad(playerid,characterid)
{
    s_LevelsSkillPoints[playerid] = 0;
    s_LevelsLoaded[playerid] = false;
    mysql_tquery_s(g_Mysql,str_format("SELECT character_skillpoints FROM characters WHERE character_id = %d",characterid),"Levels_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    s_LevelsSkillPoints[playerid] = 0;
    s_LevelsLoaded[playerid] = false;
}

hook Account_OnStatistics(playerid,targetid)
{
    new line[96];
    format(line,sizeof(line),"[LEVEL]{A3A3A3} [Skill Points]: %d",s_LevelsSkillPoints[targetid]);
    SendClientMessage(playerid,COLOR_TAB1,line);
}
