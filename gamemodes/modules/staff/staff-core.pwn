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
static Staff_DisplayName(playerid,dest[],size,bool:underscore)
{
    new base[ACCOUNT_NAME_LEN], staffName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,base,sizeof(base));

    if (!underscore)
    {
        Account_GetRoleplayName(playerid,base);
    }

    Account_GetStaffName(playerid,staffName);

    if (staffName[0] == EOS)
    {
        strcopy(dest,base,size);
        return;
    }

    format(dest,size,"%s (%s)",base,staffName);
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
CMD:anote(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_IsStaff(playerid))
    {
        SendServerMessage(playerid,"You're not a staff member.",MSG_TYPE_ERROR);
        return 1;
    }

    new option[32], target, note[256];

    if (sscanf(params,"s[32]uS()[256]",option,target,note))
    {
        SendServerMessage(playerid,"/anote [add/check]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!strcmp(option,"add",true))
    {
        if (!Staff_RequireTarget(playerid,target,"Target isn't connected."))
        {
            return 1;
        }

        if (!strlen(note) || strlen(note) > STAFF_NOTE_MAX)
        {
            SendServerMessage(playerid,"Notes can't be empty or be longer than 64 characters.",MSG_TYPE_ERROR);
            return 1;
        }

        new old[ACCOUNT_NOTE_LEN], line[200], targetName[ACCOUNT_NAME_LEN];
        Account_GetNote(target,old);
        GetPlayerName(target,targetName,sizeof(targetName));
        Account_SetNote(target,note);

        format(line,sizeof(line),"You've changed (%d) %s's admin note to:",target,targetName);
        SendClientMessage(playerid,COLOR_YELLOW,line);
        SendClientMessage(playerid,COLOR_DEFAULT,note);
        format(line,sizeof(line),"Old admin note: %s",old);
        SendClientMessage(playerid,COLOR_YELLOW,line);

        mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_anote = '%e' WHERE account_id = %d",note,Account_GetId(target)));

        new adminName[ACCOUNT_NAME_LEN];
        GetPlayerName(playerid,adminName,sizeof(adminName));
        format(line,sizeof(line),"%s (%d) changed the admin note of %s (%d) to \"%s\"",adminName,playerid,targetName,target,note);
        Staff_Log("staff/anote",line);
        return 1;
    }

    if (!strcmp(option,"check",true))
    {
        if (!Staff_RequireTarget(playerid,target,"Target isn't connected."))
        {
            return 1;
        }

        new current[ACCOUNT_NOTE_LEN], line[320], targetName[ACCOUNT_NAME_LEN];
        Account_GetNote(target,current);
        GetPlayerName(target,targetName,sizeof(targetName));
        format(line,sizeof(line),"(%d) %s's admin note: %s",target,targetName,current);
        SendClientMessage(playerid,COLOR_YELLOW,line);
        return 1;
    }

    SendServerMessage(playerid,"/anote [add/check]",MSG_TYPE_ERROR);
    return 1;
}

CMD:answer(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_IsStaff(playerid))
    {
        SendServerMessage(playerid,"You're not a staff member.",MSG_TYPE_ERROR);
        return 1;
    }

    new userid, answer[144];

    if (sscanf(params,"us[144]",userid,answer))
    {
        SendServerMessage(playerid,"/answer [id] [answer]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!IsPlayerConnected(userid) || IsPlayerNPC(userid))
    {
        SendServerMessage(playerid,"Player is not connected.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[256], adminName[ACCOUNT_NAME_LEN], userName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,adminName,sizeof(adminName));
    GetPlayerName(userid,userName,sizeof(userName));

    format(line,sizeof(line),"{44639C}[ANSWER]{DEDEDE} (%d) %s replied: %s",playerid,adminName,answer);
    SendSplitMessage(userid,COLOR_DEFAULT,line);

    foreach (new i : Player)
    {
        if (!Staff_IsStaff(i))
        {
            continue;
        }

        format(line,sizeof(line),"{44639C}[ANSWER]{DEDEDE} (%d) %s replied to (%d) %s:",playerid,adminName,userid,userName);
        SendClientMessage(i,COLOR_DEFAULT,line);
        SendSplitMessage(i,COLOR_DEFAULT,answer);
    }

    format(line,sizeof(line),"(%d) %s replied to (%d) %s: %s",playerid,adminName,userid,userName,answer);
    Staff_Log("staff/answers",line);
    return 1;
}

CMD:staff(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    new line[128], name[ACCOUNT_NAME_LEN * 2 + 4], count = 0, group[36];
    SendClientMessage(playerid,MANAGER_COLOR,"Online Managers");

    foreach (new i : Player)
    {
        if (Staff_GetLevel(i) >= E_STAFF_LEVEL_MANAGER)
        {
            count++;
            Staff_DisplayName(i,name,sizeof(name),true);
            format(line,sizeof(line),"(%d) %s",i,name);
            SendClientMessage(playerid,COLOR_DEFAULT,line);
        }
    }

    if (count <= 0)
    {
        SendClientMessage(playerid,COLOR_DEFAULT,"None");
    }

    count = 0;
    SendClientMessage(playerid,MODERATOR_COLOR,"Online Moderators");

    foreach (new i : Player)
    {
        if (Staff_GetLevel(i) == E_STAFF_LEVEL_MODERATOR)
        {
            count++;
            Staff_DisplayName(i,name,sizeof(name),false);
            Staff_GetGroupName(Staff_GetGroup(i),group);

            if (Staff_IsOnDuty(i))
            {
                format(line,sizeof(line),"%s %s (%d): {007FFF}On Duty",group,name,i);
            }
            else
            {
                format(line,sizeof(line),"%s %s (%d): {FF6347}Roleplaying",group,name,i);
            }

            SendClientMessage(playerid,COLOR_DEFAULT,line);
        }
    }

    if (count <= 0)
    {
        SendClientMessage(playerid,COLOR_DEFAULT,"None");
    }

    count = 0;
    SendClientMessage(playerid,SUPPORTER_COLOR,"Online Supporters");

    foreach (new i : Player)
    {
        if (Staff_GetLevel(i) == E_STAFF_LEVEL_SUPPORTER)
        {
            count++;
            Staff_DisplayName(i,name,sizeof(name),false);
            format(line,sizeof(line),"(%d) %s",i,name);
            SendClientMessage(playerid,COLOR_DEFAULT,line);
        }
    }

    if (count <= 0)
    {
        SendClientMessage(playerid,COLOR_DEFAULT,"None");
    }

    return 1;
}

CMD:staffisland(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid))
    {
        return 1;
    }

    new line[128], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"[STAFF] %s (%d) has teleported to the staff island.",name,playerid);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    SetPlayerPos(playerid,STAFF_ISLAND_X,STAFF_ISLAND_Y,STAFF_ISLAND_Z);
    return 1;
}

CMD:staffhelp(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_IsStaff(playerid))
    {
        SendServerMessage(playerid,"You need to be part of the staff team in order to access this list.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Staff_GetLevel(playerid) >= E_STAFF_LEVEL_SUPPORTER)
    {
        SendClientMessage(playerid,0x4075A1FF,"[SUPPORTER] /support, /answer, /questions, /staffname");
    }

    if (Staff_GetLevel(playerid) >= E_STAFF_LEVEL_MODERATOR)
    {
        if (Staff_GetGroup(playerid) >= E_STAFF_GROUP_TRIAL)
        {
            SendClientMessage(playerid,0x86DB86FF,"[TRIAL MODERATOR] /trialban, /aooc, /makeooc, /getc(haracters), /givelogoutperm, /fw, /up, /dn, /kick, /ac(un)invite");
            SendClientMessage(playerid,0x86DB86FF,"[TRIAL MODERATOR] /modduty, /freeze, /unfreeze, /slap, /bring, /goto, /getma(steraccount), /coc, /spec , /atrap");
            SendClientMessage(playerid,0x86DB86FF,"[TRIAL MODERATOR] /togmodwarnings, /staffisland, /m(od), /acceptreport, /denyreport, /reports, /ajail, /unajail, /ojail, /gotodeer");
        }

        if (Staff_GetGroup(playerid) >= E_STAFF_GROUP_BASIC)
        {
            SendClientMessage(playerid,0x56B356FF,"[BASIC MODERATOR] /refreshweather, /ban, /o(ffline)ban, /unban, /getstate, /toggleooc, /geoip,  /stopinjuries");
            SendClientMessage(playerid,0x56B356FF,"[BASIC MODERATOR] /processn(ame)c(hange), /namechanges, /viewplayeritems, /supportercheck, /lastonline, /adisarm");
            SendClientMessage(playerid,0x56B356FF,"[BASIC MODERATOR] /afrisk, /unbanip, /clearshells");
        }

        if (Staff_GetGroup(playerid) >= E_STAFF_GROUP_GENERAL)
        {
            SendClientMessage(playerid,0x3B783BFF,"[GENERAL MODERATOR] /set, /setweather, /settime, /setinterior, /setvirtualworld, /forcerespawnore, /removecheckpoints");
            SendClientMessage(playerid,0x3B783BFF,"[GENERAL MODERATOR] /reloadpoints, /reloadposses, /gotomotel, /respawndeers, /gotoxyz, /destroydynamiclabel, /acceptlabelrequest");
            SendClientMessage(playerid,0x3B783BFF,"[GENERAL MODERATOR] /denylabelrequest, /refreshdynamiclabels");
        }

        if (Staff_GetGroup(playerid) >= E_STAFF_GROUP_ADVANCED)
        {
            SendClientMessage(playerid,0x2C572CFF,"[ADVANCED MODERATOR] /givemoney, /spawnweapon, /gotodroppedweapon, /removedroppedweapon");
            SendClientMessage(playerid,0x2C572CFF,"[ADVANCED MODERATOR] /ap(oint), /aposse, /forcepaycheck, /forcelottery, /toggleooc, /togglereports");
            SendClientMessage(playerid,0x2C572CFF,"[ADVANCED MODERATOR] /purgequestions, /clearplayerinventory, /ctable, /dtable");
        }
    }

    if (Staff_IsManager(playerid))
    {
        SendClientMessage(playerid,0xA13A3AFF,"[MANAGEMENT] /man, /makestaff, /setstaffgroup, /makedonator, /cleardroppeditems, /gmx");
    }

    return 1;
}

CMD:staffname(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_IsStaff(playerid))
    {
        SendServerMessage(playerid,"You need to be a staff member in order to do this!",MSG_TYPE_ERROR);
        return 1;
    }

    new name[ACCOUNT_NAME_LEN];

    if (sscanf(params,"s[25]",name))
    {
        SendServerMessage(playerid,"/staffname [name]",MSG_TYPE_ERROR);
        return 1;
    }

    new line[128], playerName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,playerName,sizeof(playerName));
    format(line,sizeof(line),"[STAFF] %s (%d) has changed their staff name to %s.",playerName,playerid,name);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_staffname = '%e' WHERE account_id = %d",name,Account_GetId(playerid)));
    Account_SetStaffName(playerid,name);
    return 1;
}

CMD:mute(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_IsSupporter(playerid))
    {
        SendServerMessage(playerid,"You need to be a supporter in order to be able to do this!",MSG_TYPE_ERROR);
        return 1;
    }

    new choice[16];

    if (sscanf(params,"s[16]",choice))
    {
        SendServerMessage(playerid,"/mute [supporter/moderator]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!strcmp(choice,"supporter",true))
    {
        new line[96], name[ACCOUNT_NAME_LEN];
        Account_GetRoleplayName(playerid,name);

        if (!Staff_IsSupporterChatMuted(playerid))
        {
            Staff_SetSupporterChatMuted(playerid,true);
            SendServerMessage(playerid,"You've muted supporter chat, use this command again to unmute.",MSG_TYPE_INFO);
            format(line,sizeof(line),"%s (%d) has muted supporter chat.",name,playerid);
            Staff_SendSupporterWarning(line);
            return 1;
        }

        Staff_SetSupporterChatMuted(playerid,false);
        format(line,sizeof(line),"%s (%d) has unmuted supporter chat.",name,playerid);
        Staff_SendSupporterWarning(line);
        return 1;
    }

    if (strcmp(choice,"moderator",true) != 0)
    {
        SendServerMessage(playerid,"/mute [supporter/moderator]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_IsModerator(playerid))
    {
        SendServerMessage(playerid,"You need to be a moderator in order to be able to do this!",MSG_TYPE_WARN);
        return 1;
    }

    new line[96], name[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,name);

    if (!Staff_IsModeratorChatMuted(playerid))
    {
        Staff_SetModeratorChatMuted(playerid,true);
        SendServerMessage(playerid,"You've muted moderator chat, use this command again to unmute.",MSG_TYPE_INFO);
        format(line,sizeof(line),"%s (%d) has muted moderator chat.",name,playerid);
        SendModeratorWarning(line,MOD_WARNING_LOW);
        return 1;
    }

    Staff_SetModeratorChatMuted(playerid,false);
    format(line,sizeof(line),"%s (%d) has unmuted moderator chat.",name,playerid);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    return 1;
}
