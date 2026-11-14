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
#define TOOLS_MOVE_STEP (2.0)
#define TOOLS_SLAP_HEIGHT (4.0)
#define TOOLS_SLAP_SOUND (1190)
#define TOOLS_LOOKUP_LEN (25)
#define TOOLS_CHARACTER_LIST (256)

static bool:s_ToolsOoc[MAX_PLAYERS];

forward Staff_OnDutyChanged(playerid,bool:onDuty);
forward Staff_OnOocChanged(playerid,bool:ooc);
forward Staff_OnTeleported(playerid,anchorid);
forward Tools_MasterDeferred(playerid,token,const name[]);
forward Tools_CharactersDeferred(playerid,token,const name[]);
forward Tools_LastOnlineDeferred(playerid,token,const name[]);

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
stock bool:Staff_IsOoc(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_ToolsOoc[playerid];
}

stock Staff_GetDutyLabel(playerid,dest[],size = sizeof(dest))
{
    switch (Staff_GetLevel(playerid))
    {
        case E_STAFF_LEVEL_DEVELOPER:
        {
            strcopy(dest,"Developer on Duty",size);
        }
        case E_STAFF_LEVEL_MANAGER:
        {
            strcopy(dest,"Manager on Duty",size);
        }
        default:
        {
            strcopy(dest,"Moderator on Duty",size);
        }
    }
}

stock bool:Staff_RequireReadyTarget(playerid,targetid,const text[])
{
    if (!Staff_RequireTarget(playerid,targetid,text))
    {
        return false;
    }

    if (!Player_IsReady(targetid))
    {
        SendServerMessage(playerid,"That player has not entered the world with a character yet.",MSG_TYPE_ERROR);
        return false;
    }

    return true;
}

static Tools_Announce(playerid,targetid,const action[],level = MOD_WARNING_LOW)
{
    new line[160], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"[STAFF] %s (%d) has %s %s (%d).",name,playerid,action,targetName,targetid);
    SendModeratorWarning(line,level);
}

static Tools_Move(playerid,Float:ahead,Float:height)
{
    new Float:x, Float:y, Float:z, Float:angle;
    GetPlayerPos(playerid,x,y,z);
    GetPlayerFacingAngle(playerid,angle);
    x -= ahead * floatsin(angle,degrees);
    y += ahead * floatcos(angle,degrees);
    SetPlayerPos(playerid,x,y,z + height);
}

static Tools_Master(playerid,const name[])
{
    yield 1;

    new token = Account_GetToken(playerid);
    await mysql_aquery_s(g_Mysql,str_format("SELECT m.account_id AS account_id, m.account_name AS account_name FROM characters c JOIN master_accounts m ON m.account_id = c.account_id WHERE c.character_name = '%e' LIMIT 1",name),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (cache_num_rows() == 0)
    {
        SendServerMessage(playerid,"Database didn't return any data. Did you type the name correctly?",MSG_TYPE_WARN);
        return;
    }

    new accountId, account[ACCOUNT_NAME_LEN], line[160];
    cache_get_value_name_int(0,"account_id",accountId);
    cache_get_value_name(0,"account_name",account,ACCOUNT_NAME_LEN);
    format(line,sizeof(line),"{D19932}%s's{FFFFFF} master account is {D19932}(%d) %s{FFFFFF}",name,accountId,account);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
}

forward Tools_Master_Deferred(playerid,token,const name[]);

public Tools_Master_Deferred(playerid,token,const name[])
{
    if (Account_IsCurrent(playerid,token))
    {
        Tools_Master(playerid,name);
    }

    return 1;
}

static Tools_Master_Defer(playerid,const name[])
{
    SetTimerEx("Tools_Master_Deferred",0,false,"dds",playerid,Account_GetToken(playerid),name);
}

static Tools_Characters(playerid,const name[])
{
    yield 1;

    new token = Account_GetToken(playerid);
    await mysql_aquery_s(g_Mysql,str_format("SELECT m.account_id AS account_id, c.character_name AS character_name FROM master_accounts m LEFT JOIN characters c ON c.account_id = m.account_id WHERE m.account_name = '%e' ORDER BY c.character_id",name),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    new rows = cache_num_rows();

    if (rows == 0)
    {
        SendServerMessage(playerid,"Database didn't return any data. Did you type the name correctly?",MSG_TYPE_WARN);
        return;
    }

    new accountId, list[TOOLS_CHARACTER_LIST], line[160], count = 0;
    cache_get_value_name_int(0,"account_id",accountId);

    for (new i = 0;i < rows;i++)
    {
        new character[ACCOUNT_NAME_LEN], bool:isNull;
        cache_is_value_name_null(i,"character_name",isNull);

        if (isNull)
        {
            continue;
        }

        cache_get_value_name(i,"character_name",character,ACCOUNT_NAME_LEN);
        format(line,sizeof(line)," (%d) %s",count,character);
        strcat(list,line,sizeof(list));
        count++;
    }

    if (count == 0)
    {
        SendServerMessage(playerid,"That account doesn't have any characters.",MSG_TYPE_INFO);
        return;
    }

    format(line,sizeof(line),"Found characters for account {D19932}(%d) %s{FFFFFF}:",accountId,name);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"{D19932}%s{FFFFFF}",list);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
}

forward Tools_Characters_Deferred(playerid,token,const name[]);

public Tools_Characters_Deferred(playerid,token,const name[])
{
    if (Account_IsCurrent(playerid,token))
    {
        Tools_Characters(playerid,name);
    }

    return 1;
}

static Tools_Characters_Defer(playerid,const name[])
{
    SetTimerEx("Tools_Characters_Deferred",0,false,"dds",playerid,Account_GetToken(playerid),name);
}

static Tools_LastOnline(playerid,const name[])
{
    yield 1;

    new token = Account_GetToken(playerid);
    await mysql_aquery_s(g_Mysql,str_format("SELECT account_lastlogin FROM master_accounts WHERE account_name = '%e' LIMIT 1",name),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (cache_num_rows() == 0)
    {
        SendServerMessage(playerid,"Database didn't return any data. Did you type the name correctly?",MSG_TYPE_WARN);
        return;
    }

    new stamp = 0;
    cache_get_value_name_int(0,"account_lastlogin",stamp);

    if (stamp == 0)
    {
        SendServerMessage(playerid,"Date cannot be calculated (timestamp is 0)",MSG_TYPE_ERROR);
        return;
    }

    new year, month, day, hour, minute, second, line[160];
    Stats_ToDate(stamp,year,month,day,hour,minute,second);
    format(line,sizeof(line),"{D19932}%s{FFFFFF} was last online at %02d/%02d/%d - %02d:%02d:%02d.",name,day,month,year,hour,minute,second);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
}

forward Tools_LastOnline_Deferred(playerid,token,const name[]);

public Tools_LastOnline_Deferred(playerid,token,const name[])
{
    if (Account_IsCurrent(playerid,token))
    {
        Tools_LastOnline(playerid,name);
    }

    return 1;
}

static Tools_LastOnline_Defer(playerid,const name[])
{
    SetTimerEx("Tools_LastOnline_Deferred",0,false,"dds",playerid,Account_GetToken(playerid),name);
}

static bool:Tools_ReadName(playerid,const params[],const usage[],dest[])
{
    new text[64];

    if (sscanf(params,"s[64]",text))
    {
        SendServerMessage(playerid,usage,MSG_TYPE_ERROR);
        return false;
    }

    if (strlen(text) > MAX_PLAYER_NAME)
    {
        SendServerMessage(playerid,"Names can't be longer than 24 characters.",MSG_TYPE_ERROR);
        return false;
    }

    strcopy(dest,text,TOOLS_LOOKUP_LEN);
    return true;
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
CMD:fw(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        Tools_Move(playerid,TOOLS_MOVE_STEP,0.0);
    }

    return 1;
}

CMD:up(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        Tools_Move(playerid,0.0,TOOLS_MOVE_STEP);
    }

    return 1;
}

CMD:dn(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        Tools_Move(playerid,0.0,-TOOLS_MOVE_STEP);
    }

    return 1;
}

CMD:freeze(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/freeze [ playerid / name ]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    new line[96], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    TogglePlayerControllable(target,false);
    format(line,sizeof(line),"You've been frozen by moderator %s (%d)",name,playerid);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    Tools_Announce(playerid,target,"frozen");
    return 1;
}

CMD:unfreeze(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/unfreeze [ playerid / name ]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    new line[96], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    TogglePlayerControllable(target,true);
    format(line,sizeof(line),"You've been unfrozen by moderator %s (%d)",name,playerid);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    Tools_Announce(playerid,target,"unfrozen");
    return 1;
}

CMD:slap(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/slap [ playerid / name ]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z, line[96], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerPos(target,x,y,z);
    SetPlayerPos(target,x,y,z + TOOLS_SLAP_HEIGHT);
    PlayerPlaySound(target,TOOLS_SLAP_SOUND,x,y,z);
    format(line,sizeof(line),"You've been slapped by moderator %s (%d)",name,playerid);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    Tools_Announce(playerid,target,"slapped");
    return 1;
}

CMD:bring(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/bring [ playerid / name ]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z, line[96], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    format(line,sizeof(line),"You've been teleported to moderator %s (%d).",name,playerid);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"[STAFF] %s (%d) has teleported %s (%d) to them.",name,playerid,targetName,target);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    GetPlayerPos(playerid,x,y,z);
    SetPlayerPos(target,x,y,z);
    SetPlayerInterior(target,GetPlayerInterior(playerid));
    SetPlayerVirtualWorld(target,GetPlayerVirtualWorld(playerid));
    Fade_In(target);
    pawn_call_public("Staff_OnTeleported","dd",target,playerid);
    return 1;
}

CMD:goto(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/goto [ playerid / name ]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z, line[96], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    format(line,sizeof(line),"Moderator %s (%d) has teleported to you.",name,playerid);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"[STAFF] %s (%d) has teleported to %s (%d).",name,playerid,targetName,target);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    GetPlayerPos(target,x,y,z);
    SetPlayerPos(playerid,x,y,z);
    SetPlayerInterior(playerid,GetPlayerInterior(target));
    SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(target));
    pawn_call_public("Staff_OnTeleported","dd",playerid,target);
    return 1;
}

forward Injury_GetMode(playerid);
forward bool:Horse_IsRiding(playerid);

CMD:getstate(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/getstate [playerid/name]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    new line[96], name[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(target,name);
    format(line,sizeof(line),"%s State Information",name);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"{FF6347}Injured{FFFFFF}: %s",Injury_GetMode(target) == 1 ? ("Yes") : ("No"));
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"{629C5C}Dead{FFFFFF}: %s",Injury_GetMode(target) == 2 ? ("Yes") : ("No"));
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"{FF6347}Riding Horse{FFFFFF}: %s",Horse_IsRiding(target) ? ("Yes") : ("No"));
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"{629C5C}Paused{FFFFFF}: %s",Player_IsPaused(target) ? ("Yes") : ("No"));
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
}

CMD:getmasteraccount(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new name[TOOLS_LOOKUP_LEN];

    if (!Tools_ReadName(playerid,params,"/getma(steraccount) [character name]",name))
    {
        return 1;
    }

    SetTimerEx("Tools_MasterDeferred",0,false,"dds",playerid,Account_GetToken(playerid),name);
    return 1;
}

ALT:getma=CMD:getmasteraccount;

CMD:getcharacters(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new name[TOOLS_LOOKUP_LEN];

    if (!Tools_ReadName(playerid,params,"/getc(haracters) [master_name]",name))
    {
        return 1;
    }

    SetTimerEx("Tools_CharactersDeferred",0,false,"dds",playerid,Account_GetToken(playerid),name);
    return 1;
}

ALT:getc=CMD:getcharacters;

CMD:lastonline(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new name[TOOLS_LOOKUP_LEN];

    if (!Tools_ReadName(playerid,params,"/lastonline [master_account]: use /getma to get master account from character",name))
    {
        return 1;
    }

    SetTimerEx("Tools_LastOnlineDeferred",0,false,"dds",playerid,Account_GetToken(playerid),name);
    return 1;
}

CMD:makeooc(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/makeooc [player / name]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    new line[128], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));

    if (!s_ToolsOoc[target])
    {
        s_ToolsOoc[target] = true;
        format(line,sizeof(line),"You've been made OOC by %s",name);
        SendServerMessage(target,line,MSG_TYPE_INFO);
        format(line,sizeof(line),"[STAFF] %s (%d) has made %s (%d) OOC.",name,playerid,targetName,target);
        SendModeratorWarning(line,MOD_WARNING_LOW);
    }
    else
    {
        s_ToolsOoc[target] = false;
        format(line,sizeof(line),"You've been made IC by %s",name);
        SendServerMessage(target,line,MSG_TYPE_INFO);
        format(line,sizeof(line),"[STAFF] %s (%d) has removed %s (%d)'s OOC status.",name,playerid,targetName,target);
        SendModeratorWarning(line,MOD_WARNING_LOW);
    }

    pawn_call_public("Staff_OnOocChanged","dd",target,s_ToolsOoc[target]);
    return 1;
}

CMD:modduty(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new line[96], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));

    if (!Staff_IsOnDuty(playerid))
    {
        Staff_SetOnDuty(playerid,true);
        Staff_SetWarnings(playerid,true);
        SendServerMessage(playerid,"You went on mod duty. Please go to /staffisland when you're out of work.",MSG_TYPE_INFO);
        format(line,sizeof(line),"[STAFF] %s (%d) has gone on mod duty.",name,playerid);
        SendModeratorWarning(line,MOD_WARNING_LOW);
    }
    else
    {
        Staff_SetOnDuty(playerid,false);
        SendServerMessage(playerid,"You've gone off mod duty.",MSG_TYPE_INFO);
        format(line,sizeof(line),"[STAFF] %s (%d) has gone off mod duty.",name,playerid);
        SendModeratorWarning(line,MOD_WARNING_LOW);
    }

    pawn_call_public("Staff_OnDutyChanged","dd",playerid,Staff_IsOnDuty(playerid));
    return 1;
}

CMD:givelogoutperm(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/givelogoutperm [ playerid / name ]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    Account_SetLogoutPermission(target,true);
    SendServerMessage(target,"You've been given /logout permission. You can now use /logout.",MSG_TYPE_INFO);
    Tools_Announce(playerid,target,"given logout permission to");
    return 1;
}

CMD:aooc(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_TRIAL))
    {
        return 1;
    }

    new text[STAFF_TEXT_LEN];

    if (sscanf(params,"s[145]",text))
    {
        SendServerMessage(playerid,"/aooc [ text ]",MSG_TYPE_ERROR);
        return 1;
    }

    if (strlen(text) > 144)
    {
        SendServerMessage(playerid,"Text can't be longer than 144 characters.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[256], name[ACCOUNT_NAME_LEN], staffName[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,name);
    Account_GetStaffName(playerid,staffName);

    if (staffName[0] == EOS)
    {
        format(line,sizeof(line),"(( [AOOC] (%d) %s: %s ))",playerid,name,text);
    }
    else
    {
        format(line,sizeof(line),"(( [AOOC] (%d) %s (%s): %s ))",playerid,name,staffName,text);
    }

    SendSplitMessageToAll(STAFF_AOOC_COLOUR,line);
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
public Staff_OnDutyChanged(playerid,bool:onDuty)
{
    return 1;
}

public Staff_OnOocChanged(playerid,bool:ooc)
{
    return 1;
}

public Staff_OnTeleported(playerid,anchorid)
{
    return 1;
}

public Tools_MasterDeferred(playerid,token,const name[])
{
    if (Account_IsCurrent(playerid,token) && Staff_IsModerator(playerid))
    {
        Tools_Master_Defer(playerid,name);
    }

    return 1;
}

public Tools_CharactersDeferred(playerid,token,const name[])
{
    if (Account_IsCurrent(playerid,token) && Staff_IsModerator(playerid))
    {
        Tools_Characters_Defer(playerid,name);
    }

    return 1;
}

public Tools_LastOnlineDeferred(playerid,token,const name[])
{
    if (Account_IsCurrent(playerid,token) && Staff_IsModerator(playerid))
    {
        Tools_LastOnline_Defer(playerid,name);
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

hook OnPlayerConnect(playerid)
{
    s_ToolsOoc[playerid] = false;
}

hook Character_OnUnload(playerid,characterid)
{
    s_ToolsOoc[playerid] = false;
}
