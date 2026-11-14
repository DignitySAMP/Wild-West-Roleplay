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
#define SET_OPTION_LEN (20)
#define SET_HEALTH_MIN (15)
#define SET_HEALTH_MAX (100)
#define SET_NEED_MAX (100)
#define SET_SKIN_MAX (311)
#define SET_AGE_MIN (8)
#define SET_AGE_MAX (80)
#define SET_HOUR_MAX (23)
#define SET_INTERIOR_MAX (255)

forward bool:Inventory_SetBackpack(playerid,level);
forward bool:Weapons_GiveAmmoCrate(playerid,kind);
forward bool:Horse_IsSpawned(playerid);
forward bool:Horse_IsRiding(playerid);
forward bool:Horse_IsValidAssignment(type);
forward Horse_SetType(playerid,type);
forward Horse_SaveType(playerid);
forward Horse_SetStoredHealth(playerid,Float:health);
forward Horse_SaveHealth(playerid);
forward Horse_GetTypeName(type,dest[],size);

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
static Set_Report(playerid,target,const option[],const shown[],messageType,warningLevel)
{
    new line[200], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    format(line,sizeof(line),"Your %s has been set to %s by moderator (%d) %s",option,shown,playerid,name);
    SendServerMessage(target,line,messageType);
    format(line,sizeof(line),"[STAFF] %s (%d) has set %s (%d)'s %s to %s.",name,playerid,targetName,target,option,shown);
    SendModeratorWarning(line,warningLevel);
    Staff_Log("staff/set",line);
}

static Set_Refuse(playerid,const option[],minimum,maximum)
{
    new line[96];
    format(line,sizeof(line),"%s can't be lower than %d or higher than %d",option,minimum,maximum);
    SendServerMessage(playerid,line,MSG_TYPE_ERROR);
}

static Set_ApplySkin(target,skin)
{
    SetPlayerSkin(target,skin);
    Character_SetSkinCached(target,skin);
}

static Set_Option(playerid,target,const option[],value)
{
    new shown[48];

    if (!strcmp(option,"level",true))
    {
        if (value <= 0)
        {
            SendServerMessage(playerid,"Level cannot be at or below 0.",MSG_TYPE_ERROR);
            return;
        }

        Levels_SetLevel(target,value);
        format(shown,sizeof(shown),"%d",value);
        Set_Report(playerid,target,"level",shown,MSG_TYPE_INFO,MOD_WARNING_MED);
    }
    else if (!strcmp(option,"health",true))
    {
        if (value < SET_HEALTH_MIN || value > SET_HEALTH_MAX)
        {
            Set_Refuse(playerid,"Health",SET_HEALTH_MIN,SET_HEALTH_MAX);
            return;
        }

        pawn_call_public("Staff_OnSetHealth","df",target,float(value));
        format(shown,sizeof(shown),"%d",value);
        Set_Report(playerid,target,"health",shown,MSG_TYPE_WARN,MOD_WARNING_MED);
    }
    else if (!strcmp(option,"hunger",true) || !strcmp(option,"thirst",true))
    {
        if (value < 0 || value > SET_NEED_MAX)
        {
            Set_Refuse(playerid,option[0] == 'h' || option[0] == 'H' ? ("Hunger") : ("Thirst"),0,SET_NEED_MAX);
            return;
        }

        if (!Needs_IsLoaded(target))
        {
            SendServerMessage(playerid,"That player's needs are not loaded yet.",MSG_TYPE_ERROR);
            return;
        }

        format(shown,sizeof(shown),"%d",value);

        if (option[0] == 'h' || option[0] == 'H')
        {
            Needs_Set(target,value,Needs_GetThirst(target));
            Set_Report(playerid,target,"hunger",shown,MSG_TYPE_INFO,MOD_WARNING_HIGH);
        }
        else
        {
            Needs_Set(target,Needs_GetHunger(target),value);
            Set_Report(playerid,target,"thirst",shown,MSG_TYPE_INFO,MOD_WARNING_HIGH);
        }
    }
    else if (!strcmp(option,"skin",true))
    {
        if (value < 1 || value > SET_SKIN_MAX)
        {
            Set_Refuse(playerid,"Skin",1,SET_SKIN_MAX);
            return;
        }

        Set_ApplySkin(target,value);
        mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_skin = %d WHERE character_id = %d",value,Character_GetId(target)));
        format(shown,sizeof(shown),"%d",value);
        Set_Report(playerid,target,"skin",shown,MSG_TYPE_WARN,MOD_WARNING_LOW);
    }
    else if (!strcmp(option,"origin",true))
    {
        if (value < 0 || value >= CREATE_RACES)
        {
            new list[128];
            format(list,sizeof(list),"[ORIGINS]: 0: Caucasian, 1: Hispanic, 2: African, 3: Asian, 4: Native");
            SendServerMessage(playerid,list,MSG_TYPE_INFO);
            Set_Refuse(playerid,"Origin value",0,CREATE_RACES - 1);
            return;
        }

        new skin = Character_GetBaseSkin(Character_GetGender(target),value), name[16];
        Character_GetOriginName(value,name);
        Character_SetOriginCached(target,value);
        Set_ApplySkin(target,skin);
        mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_skin = %d, character_origin = %d WHERE character_id = %d",skin,value,Character_GetId(target)));
        format(shown,sizeof(shown),"(%d) %s",value,name);
        Set_Report(playerid,target,"origin",shown,MSG_TYPE_WARN,MOD_WARNING_LOW);
    }
    else if (!strcmp(option,"gender",true))
    {
        if (value < 0 || value > 1)
        {
            SendServerMessage(playerid,"[GENDERS]: 0: Male, 1: Female",MSG_TYPE_INFO);
            Set_Refuse(playerid,"Gender value",0,1);
            return;
        }

        new skin = Character_GetBaseSkin(value,Character_GetOrigin(target)), name[16];
        Character_GetGenderName(value,name);
        Character_SetGenderCached(target,value);
        Set_ApplySkin(target,skin);
        mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_skin = %d, character_gender = %d WHERE character_id = %d",skin,value,Character_GetId(target)));
        format(shown,sizeof(shown),"(%d) %s",value,name);
        Set_Report(playerid,target,"gender",shown,MSG_TYPE_WARN,MOD_WARNING_LOW);
    }
    else if (!strcmp(option,"town",true))
    {
        if (value < 0 || value >= CREATE_TOWNS)
        {
            SendServerMessage(playerid,"[TOWNS] 0: Longcreek, 1: Fremont",MSG_TYPE_INFO);
            Set_Refuse(playerid,"Town value",0,CREATE_TOWNS - 1);
            return;
        }

        new name[16];
        Character_GetTownName(value,name);
        Character_SetTownCached(target,value);
        mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_town = %d WHERE character_id = %d",value,Character_GetId(target)));
        format(shown,sizeof(shown),"(%d) %s",value,name);
        Set_Report(playerid,target,"town",shown,MSG_TYPE_WARN,MOD_WARNING_LOW);
    }
    else if (!strcmp(option,"namechanges",true))
    {
        if (value < 0 || value > 1)
        {
            SendServerMessage(playerid,"You can only add one of these per command. (it increments)",MSG_TYPE_ERROR);
            return;
        }

        new count = Account_GetNameChanges(target) + value, line[128], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
        Account_SetNameChanges(target,count);
        mysql_tquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_namechanges = %d WHERE account_id = %d",count,Account_GetId(target)));
        GetPlayerName(playerid,name,sizeof(name));
        GetPlayerName(target,targetName,sizeof(targetName));
        format(line,sizeof(line),"You have been given a namechange by moderator (%d) %s",playerid,name);
        SendServerMessage(target,line,MSG_TYPE_WARN);
        format(line,sizeof(line),"[STAFF] %s (%d) has given %s (%d) a namechange.",name,playerid,targetName,target);
        SendModeratorWarning(line,MOD_WARNING_MED);
    }
    else if (!strcmp(option,"rulecheck",true))
    {
        if (value < 0 || value > 1)
        {
            SendServerMessage(playerid,"Value can't be more than 1 or less than 0.",MSG_TYPE_ERROR);
            return;
        }

        new line[128], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
        Account_SetRuleCheck(target,value);
        mysql_tquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_rulecheck = %d WHERE account_id = %d",value,Account_GetId(target)));
        GetPlayerName(playerid,name,sizeof(name));
        GetPlayerName(target,targetName,sizeof(targetName));
        format(line,sizeof(line),"[STAFF] %s (%d) has set %s (%d)'s rulebreaker stat to %d.",name,playerid,targetName,target,value);
        SendModeratorWarning(line,MOD_WARNING_HIGH);
    }
    else if (!strcmp(option,"age",true))
    {
        if (value < SET_AGE_MIN || value > SET_AGE_MAX)
        {
            SendServerMessage(playerid,"Value can't be more than 80 or less than 8.",MSG_TYPE_ERROR);
            return;
        }

        Character_SetAgeCached(target,value);
        mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_age = %d WHERE character_id = %d",value,Character_GetId(target)));
        format(shown,sizeof(shown),"%d",value);
        Set_Report(playerid,target,"age",shown,MSG_TYPE_INFO,MOD_WARNING_LOW);
    }
    else if (!strcmp(option,"pistol_ammo",true) || !strcmp(option,"shotgun_ammo",true) || !strcmp(option,"rifle_ammo",true))
    {
        if (value < 0 || value > 1)
        {
            SendServerMessage(playerid,"You can only add one of these per command. (it increments)",MSG_TYPE_ERROR);
            return;
        }

        new kind = option[0] == 'p' || option[0] == 'P' ? 0 : (option[0] == 's' || option[0] == 'S' ? 1 : 2), line[128], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN], label[12];
        strcopy(label,kind == 0 ? ("pistol") : (kind == 1 ? ("shotgun") : ("rifle")));

        if (value == 1 && !Weapons_GiveAmmoCrate(target,kind))
        {
            return;
        }

        GetPlayerName(playerid,name,sizeof(name));
        GetPlayerName(target,targetName,sizeof(targetName));
        format(line,sizeof(line),"You have been given a %s ammopack by moderator (%d) %s",label,playerid,name);
        SendServerMessage(target,line,MSG_TYPE_WARN);
        format(line,sizeof(line),"[STAFF] %s (%d) has given %s (%d) a %s ammopack.",name,playerid,targetName,target,label);
        SendModeratorWarning(line,MOD_WARNING_HIGH);
    }
    else if (!strcmp(option,"backpack",true))
    {
        if (value < 0 || value > 2)
        {
            SendServerMessage(playerid,"Value can't be more than 2 or less than 0.",MSG_TYPE_ERROR);
            return;
        }

        Inventory_SetBackpack(target,value);
        format(shown,sizeof(shown),"%d",value);
        Set_Report(playerid,target,"backpack",shown,MSG_TYPE_WARN,MOD_WARNING_HIGH);
    }
    else if (!strcmp(option,"horse",true))
    {
        if (!Horse_IsValidAssignment(value))
        {
            SendServerMessage(playerid,"[HORSES] -1: Remove Horse, 1: Dutch Warmblood, 2: Highland Chestnut, 3: American Standardbred",MSG_TYPE_INFO);
            SendServerMessage(playerid,"The only valid horse values are -1, 1, 2, and 3.",MSG_TYPE_ERROR);
            return;
        }

        if (Horse_IsRiding(target) || Horse_IsSpawned(target))
        {
            SendServerMessage(playerid,"Your target player has to use /respawnhorse before you can set their horse",MSG_TYPE_ERROR);
            return;
        }

        Horse_SetType(target,value);
        Horse_SaveType(target);

        if (value == -1)
        {
            new line[200], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
            GetPlayerName(playerid,name,sizeof(name));
            GetPlayerName(target,targetName,sizeof(targetName));
            format(line,sizeof(line),"Your horse has been removed by moderator (%d) %s",playerid,name);
            SendServerMessage(target,line,MSG_TYPE_WARN);
            format(line,sizeof(line),"[STAFF] %s (%d) has removed %s (%d)'s horse.",name,playerid,targetName,target);
            SendModeratorWarning(line,MOD_WARNING_LOW);
            Staff_Log("staff/set",line);
        }
        else if (value == 99)
        {
            Set_Report(playerid,target,"mount","a cow",MSG_TYPE_WARN,MOD_WARNING_LOW);
        }
        else
        {
            Horse_GetTypeName(value,shown,sizeof(shown));
            Set_Report(playerid,target,"horse",shown,MSG_TYPE_WARN,MOD_WARNING_LOW);
        }
    }
    else if (!strcmp(option,"horsehealth",true))
    {
        if (value < 5 || value > 100)
        {
            SendServerMessage(playerid,"Horse value can't be lower than 5 or higher than 100.",MSG_TYPE_ERROR);
            return;
        }

        if (Horse_IsRiding(target) || Horse_IsSpawned(target))
        {
            SendServerMessage(playerid,"Your target player has to use /respawnhorse before you can set their horse.",MSG_TYPE_ERROR);
            return;
        }

        Horse_SetStoredHealth(target,float(value));
        Horse_SaveHealth(target);
        format(shown,sizeof(shown),"%d",value);
        Set_Report(playerid,target,"horse health",shown,MSG_TYPE_WARN,MOD_WARNING_LOW);
    }
    else
    {
        SendServerMessage(playerid,"/set [option] [player] [value]",MSG_TYPE_ERROR);
        SendServerMessage(playerid,"[OPTIONS]: level, health, thirst, hunger, skin, horse, horsehealth, origin, gender, town",MSG_TYPE_ERROR);
        SendServerMessage(playerid,"[OPTIONS]: namechanges, pistol_ammo, shotgun_ammo, rifle_ammo, backpack",MSG_TYPE_ERROR);
        SendServerMessage(playerid,"[OPTIONS]: rulecheck, age",MSG_TYPE_ERROR);
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
CMD:gotoxyz(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z, interior, world;

    if (sscanf(params,"fffI(0)I(0)",x,y,z,interior,world))
    {
        SendServerMessage(playerid,"/gotoxyz [x coord] [y coord] [z coord] [optional:interior] [optional:virtualworld]",MSG_TYPE_ERROR);
        return 1;
    }

    if (interior < 0 || interior > SET_INTERIOR_MAX || world < 0)
    {
        SendServerMessage(playerid,"The interior has to be between 0 and 255 and the virtual world can't be negative.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[200], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    SetPlayerPos(playerid,x,y,z);
    SetPlayerInterior(playerid,interior);
    SetPlayerVirtualWorld(playerid,world);
    format(line,sizeof(line),"[STAFF] %s (%d) has teleported to %.02f, %.02f, %.02f in interior ID %i and virtual world ID %i.",name,playerid,x,y,z,interior,world);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    return 1;
}

CMD:removecheckpoints(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new line[128], name[ACCOUNT_NAME_LEN];

    for (new i = 0;i < 1024;i++)
    {
        if (IsValidDynamicCP(STREAMER_TAG_CP:i))
        {
            DestroyDynamicCP(STREAMER_TAG_CP:i);
        }
    }

    Name_Real(playerid,name);
    format(line,sizeof(line),"[STAFF] %s (%d) deleted all unused checkpoints",name,playerid);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    return 1;
}

CMD:settime(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new hour;

    if (sscanf(params,"i",hour))
    {
        SendServerMessage(playerid,"/settime [time]",MSG_TYPE_ERROR);
        return 1;
    }

    if (hour < 0 || hour > SET_HOUR_MAX)
    {
        SendServerMessage(playerid,"Time can't be lower than 0 or higher than 23",MSG_TYPE_ERROR);
        return 1;
    }

    new line[128], name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    Time_SetHour(hour);
    format(line,sizeof(line),"[STAFF] %s (%d) has set the time to %d. Server variable has been updated.",name,playerid,hour);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    return 1;
}

CMD:setinterior(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new target, interior;

    if (sscanf(params,"ui",target,interior))
    {
        SendServerMessage(playerid,"/setint(erior) [user] [int]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"Player isn't connected."))
    {
        return 1;
    }

    if (interior < 0 || interior > SET_INTERIOR_MAX)
    {
        SendServerMessage(playerid,"The interior has to be between 0 and 255.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[128], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    SetPlayerInterior(target,interior);
    format(line,sizeof(line),"Your interior has been set to %d by moderator (%d) %s",interior,playerid,name);
    SendServerMessage(target,line,MSG_TYPE_WARN);
    format(line,sizeof(line),"[STAFF] %s (%d) has set %s (%d)'s interior to %d.",name,playerid,targetName,target,interior);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    return 1;
}

ALT:setint=CMD:setinterior;

CMD:setvirtualworld(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new target, world;

    if (sscanf(params,"ui",target,world))
    {
        SendServerMessage(playerid,"/setv(irtual)w(orld) [user] [vw]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"Player isn't connected."))
    {
        return 1;
    }

    if (world < 0)
    {
        SendServerMessage(playerid,"The virtual world can't be negative.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[128], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    SetPlayerVirtualWorld(target,world);
    format(line,sizeof(line),"Your virtual world has been set to %d by moderator (%d) %s",world,playerid,name);
    SendServerMessage(target,line,MSG_TYPE_WARN);
    format(line,sizeof(line),"[STAFF] %s (%d) has set %s (%d)'s virtual world to %d.",name,playerid,targetName,target,world);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    return 1;
}

ALT:setvw=CMD:setvirtualworld;

forward Staff_OnSetHealth(playerid,Float:health);

public Staff_OnSetHealth(playerid,Float:health)
{
    return 1;
}

CMD:set(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new option[SET_OPTION_LEN], target, value;

    if (sscanf(params,"s[20]ui",option,target,value))
    {
        SendServerMessage(playerid,"/set [option] [player] [value]",MSG_TYPE_ERROR);
        SendServerMessage(playerid,"[OPTIONS]: level, health, thirst, hunger, skin, horse, horsehealth, origin, gender, town",MSG_TYPE_ERROR);
        SendServerMessage(playerid,"[OPTIONS]: namechanges, pistol_ammo, shotgun_ammo, rifle_ammo, backpack",MSG_TYPE_ERROR);
        SendServerMessage(playerid,"[OPTIONS]: rulecheck, age",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireReadyTarget(playerid,target,"Player isn't connected anymore."))
    {
        return 1;
    }

    Set_Option(playerid,target,option,value);
    return 1;
}

forward Staff_ClickNetwork(playerid,target,token);

public Staff_ClickNetwork(playerid,target,token)
{
    if (!Account_IsCurrent(playerid,token) || !IsPlayerConnected(target))
    {
        return 1;
    }

    new stats[512], response[DIALOG_RESPONSE];
    GetPlayerNetworkStats(target,stats,sizeof(stats));
    Stats_Show(playerid,target);
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"Player Network Information",stats,"Okay","");
    return 1;
}

#include <pp-hooks>

hook OnPlayerClickPlayer(playerid,clickedplayerid,CLICK_SOURCE:source)
{
    if (!Staff_IsModerator(playerid) || !IsPlayerConnected(clickedplayerid))
    {
        return;
    }

    SetTimerEx("Staff_ClickNetwork",0,false,"ddd",playerid,clickedplayerid,Account_GetToken(playerid));
}
