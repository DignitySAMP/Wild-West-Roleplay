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
#define DONATOR_SECONDS (2592000)
#define DONATOR_MAX_LEVEL (3)

forward Donator_Deferred(playerid,token,level,const account[]);

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
static bool:Manage_CanChange(playerid,targetid,newLevel = -1)
{
    if (Staff_IsDeveloper(playerid))
    {
        return true;
    }

    if (Staff_GetLevel(targetid) >= E_STAFF_LEVEL_MANAGER)
    {
        SendServerMessage(playerid,"Only a developer can change the level or group of a manager or developer.",MSG_TYPE_ERROR);
        return false;
    }

    if (newLevel >= E_STAFF_LEVEL_DEVELOPER)
    {
        SendServerMessage(playerid,"Only a developer can make someone a developer.",MSG_TYPE_ERROR);
        return false;
    }

    return true;
}

static Donator_Run(playerid,level,const account[])
{
    yield 1;

    new token = Account_GetToken(playerid);
    await mysql_aquery_s(g_Mysql,str_format("SELECT account_id, account_name FROM master_accounts WHERE account_name = '%e' LIMIT 1",account),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (cache_num_rows() == 0)
    {
        new line[96];
        format(line,sizeof(line),"The account '%s' does not exist in the database.",account);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return;
    }

    new accountId, accountName[ACCOUNT_NAME_LEN], expire = gettime() + DONATOR_SECONDS, changes = level + 1;
    cache_get_value_name_int(0,"account_id",accountId);
    cache_get_value_name(0,"account_name",accountName,ACCOUNT_NAME_LEN);

    mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_donatorlevel = %d, account_donatorexpire = %d, account_namechanges = GREATEST(account_namechanges, %d) WHERE account_id = %d",level,expire,changes,accountId));

    foreach (new i : Player)
    {
        if (!Account_IsLoggedIn(i) || Account_GetId(i) != accountId)
        {
            continue;
        }

        new line[96], rank[32], year, month, day, hour, minute, second;
        Account_SetDonator(i,level,expire);

        if (Account_GetNameChanges(i) < changes)
        {
            Account_SetNameChanges(i,changes);
        }

        Account_GetDonatorRankName(level,rank);
        format(line,sizeof(line),"You've been set to %s donator.",rank);
        SendServerMessage(i,line,MSG_TYPE_INFO);
        Stats_ToDate(expire,year,month,day,hour,minute,second);
        format(line,sizeof(line),"Your donator rank will expire at %d/%d/%d.",day,month,year);
        SendServerMessage(i,line,MSG_TYPE_INFO);
        return;
    }

    new line[96];
    format(line,sizeof(line),"[DONATOR] %s has been made a donator.",accountName);
    SendSplitMessageToAll(COLOR_DEFAULT,line);
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
CMD:distanceaid(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireManager(playerid))
    {
        return 1;
    }

    new Float:distance;

    if (sscanf(params,"f",distance))
    {
        SendServerMessage(playerid,"/distanceaid [distance] (-1 will remove checkpoint)",MSG_TYPE_ERROR);
        return 1;
    }

    if (distance == -1.0)
    {
        DisablePlayerCheckpoint(playerid);
        SendServerMessage(playerid,"Checkpoint distance aid removed.",MSG_TYPE_INFO);
        return 1;
    }

    new Float:x, Float:y, Float:z, Float:angle, line[64];
    GetPlayerPos(playerid,x,y,z);
    GetPlayerFacingAngle(playerid,angle);
    x += distance * floatsin(-angle,degrees);
    y += distance * floatcos(-angle,degrees);
    SetPlayerCheckpoint(playerid,x,y,z,1.0);
    format(line,sizeof(line),"Checkpoint is at distance %.02fm.",distance);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
}

CMD:makedonator(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireManager(playerid))
    {
        return 1;
    }

    new user[ACCOUNT_NAME_LEN], level;

    if (sscanf(params,"s[25]i",user,level))
    {
        SendServerMessage(playerid,"/makedonator [master_account] [level 1-3]",MSG_TYPE_ERROR);
        return 1;
    }

    if (level < 1 || level > DONATOR_MAX_LEVEL)
    {
        SendServerMessage(playerid,"Invalid donator level.",MSG_TYPE_ERROR);
        return 1;
    }

    SetTimerEx("Donator_Deferred",0,false,"ddds",playerid,Account_GetToken(playerid),level,user);
    return 1;
}

CMD:makestaff(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireManager(playerid))
    {
        return 1;
    }

    new target, level;

    if (sscanf(params,"ui",target,level))
    {
        SendServerMessage(playerid,"/makestaff [player] [level]",MSG_TYPE_ERROR);
        SendClientMessage(playerid,-1,"[LEVELS] NONE: Level 0 | SUPPORTER: Level 1 | MODERATOR: Level 2 | MANAGEMENT: Level 3 | DEVELOPER: Level 4");
        return 1;
    }

    if (level < E_STAFF_LEVEL_NONE || level > E_STAFF_LEVEL_DEVELOPER)
    {
        SendServerMessage(playerid,"Can't be less than level 0, or higher than level 4.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"Selected player doesn't exist, they might be offline.") || !Manage_CanChange(playerid,target,level))
    {
        return 1;
    }

    mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_stafflevel = %d WHERE account_id = %d",level,Account_GetId(target)));
    Account_SetStaffLevel(target,level);

    new line[192], adminName[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN], rank[36];
    GetPlayerName(playerid,adminName,sizeof(adminName));
    GetPlayerName(target,targetName,sizeof(targetName));
    Staff_GetRankName(level,rank);
    format(line,sizeof(line),"[STAFF] %s (%d) has promoted %s (%d) to (%d) %s.",adminName,playerid,targetName,target,level,rank);
    SendModeratorWarning(line,MOD_WARNING_HIGH);
    Staff_Log("staff/promote",line);
    return 1;
}

CMD:setstaffgroup(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireManager(playerid))
    {
        return 1;
    }

    new target, group;

    if (sscanf(params,"ui",target,group))
    {
        SendServerMessage(playerid,"/setstaffgroup [player] [group]",MSG_TYPE_ERROR);
        SendClientMessage(playerid,-1,"Use the forum to check which groups to pick. Select ID based on hierachy order.");
        return 1;
    }

    if (group < E_STAFF_GROUP_NONE)
    {
        SendServerMessage(playerid,"Can't be less than group 0.",MSG_TYPE_ERROR);
        return 1;
    }

    if (group > E_STAFF_GROUP_ADVANCED)
    {
        SendServerMessage(playerid,"Can't be higher than group 4.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"Selected player doesn't exist, they might be offline.") || !Manage_CanChange(playerid,target))
    {
        return 1;
    }

    mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_staffgroup = %d WHERE account_id = %d",group,Account_GetId(target)));
    Account_SetStaffGroup(target,group);

    new line[192], adminName[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,adminName,sizeof(adminName));
    GetPlayerName(target,targetName,sizeof(targetName));
    format(line,sizeof(line),"[STAFF] %s (%d) has set %s (%d)'s staff-group to %d",adminName,playerid,targetName,target,group);
    SendModeratorWarning(line,MOD_WARNING_HIGH);
    Staff_Log("staff/promote",line);
    return 1;
}

CMD:man(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireManager(playerid))
    {
        return 1;
    }

    new text[144];

    if (sscanf(params,"s[144]",text))
    {
        SendServerMessage(playerid,"/man [text]",MSG_TYPE_ERROR);
        return 1;
    }

    new line[256], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"[MAN] %s (%d){DEDEDE}: %s",name,playerid,text);

    foreach (new i : Player)
    {
        if (Staff_IsManager(i))
        {
            SendSplitMessage(i,MANAGER_COLOR,line);
        }
    }

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
public Donator_Deferred(playerid,token,level,const account[])
{
    if (Account_IsCurrent(playerid,token))
    {
        Donator_Run(playerid,level,account);
    }

    return 1;
}
