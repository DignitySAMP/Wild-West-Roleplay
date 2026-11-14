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
stock Skills_Show(playerid)
{
    new line[256];
    format(line,sizeof(line),"Here you can see your current skills. [Skillpoints left for use: %d]",Levels_GetSkillPoints(playerid));
    SendClientMessage(playerid,COLOR_YELLOW,line);
    format(line,sizeof(line),"{917E5E}[WEAPON]{dedede} Weapon Movement: %d/%d - Weapon Aiming: %d/%d - Weapon Holstering: %d/%d",Skills_Get(playerid,E_SKILL_GUN_MOVEMENT),Skills_GetMax(E_SKILL_GUN_MOVEMENT),Skills_Get(playerid,E_SKILL_GUN_AIMING),Skills_GetMax(E_SKILL_GUN_AIMING),Skills_Get(playerid,E_SKILL_GUN_HOLSTER),Skills_GetMax(E_SKILL_GUN_HOLSTER));
    SendClientMessage(playerid,-1,line);
    format(line,sizeof(line),"{77915E}[JOBS]{dedede} Fishing: %d/%d - Woodcutting: %d/%d - Mining: %d/%d - Hunting: %d/%d -  Farming: %d/%d\n",Skills_Get(playerid,E_SKILL_JOB_FISHING),Skills_GetMax(E_SKILL_JOB_FISHING),Skills_Get(playerid,E_SKILL_JOB_LUMBER),Skills_GetMax(E_SKILL_JOB_LUMBER),Skills_Get(playerid,E_SKILL_JOB_MINING),Skills_GetMax(E_SKILL_JOB_MINING),Skills_Get(playerid,E_SKILL_JOB_HUNTING),Skills_GetMax(E_SKILL_JOB_HUNTING),Skills_Get(playerid,E_SKILL_JOB_FARMING),Skills_GetMax(E_SKILL_JOB_FARMING));
    SendClientMessage(playerid,-1,line);
    format(line,sizeof(line),"{77915E}[JOBS]{dedede} Blacksmith %d/%d",Skills_Get(playerid,E_SKILL_JOB_BLACKSMITH),Skills_GetMax(E_SKILL_JOB_BLACKSMITH));
    SendClientMessage(playerid,-1,line);
    format(line,sizeof(line),"{5E93A8}[MELEE]{dedede} Fight Style: %d/%d - Unarmed: %d/%d - Knife: %d/%d - Knife Throwing: %d/%d\n",Skills_Get(playerid,E_SKILL_MELEE_STYLE),Skills_GetMax(E_SKILL_MELEE_STYLE),Skills_Get(playerid,E_SKILL_MELEE_UNARMED),Skills_GetMax(E_SKILL_MELEE_UNARMED),Skills_Get(playerid,E_SKILL_MELEE_KNIFE),Skills_GetMax(E_SKILL_MELEE_KNIFE),Skills_Get(playerid,E_SKILL_MELEE_KNIFE_THROW),Skills_GetMax(E_SKILL_MELEE_KNIFE_THROW));
    SendClientMessage(playerid,-1,line);
    format(line,sizeof(line),"{B0B0B0}[MISC]{dedede} Swimming: %d/%d - Health: %d/%d",Skills_Get(playerid,E_SKILL_MISC_SWIMMING),Skills_GetMax(E_SKILL_MISC_SWIMMING),Skills_Get(playerid,E_SKILL_MISC_HEALTH),Skills_GetMax(E_SKILL_MISC_HEALTH));
    SendClientMessage(playerid,-1,line);
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
CMD:skills(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!strcmp(params,"show"))
    {
        Skills_Show(playerid);
        return 1;
    }

    if (!strcmp(params,"reset"))
    {
        Skills_Reset(playerid);
        return 1;
    }

    SendServerMessage(playerid,"/skills [show/reset]",MSG_TYPE_ERROR);
    return 1;
}

CMD:levelup(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new option[SKILL_NAME_LEN];

    if (sscanf(params,"s[32]",option))
    {
        SendServerMessage(playerid,"/levelup [option]",MSG_TYPE_ERROR);
        return 1;
    }

    new skill = Skills_FindByName(option);

    if (skill != -1)
    {
        Skills_LevelUp(playerid,skill);
    }

    return 1;
}
