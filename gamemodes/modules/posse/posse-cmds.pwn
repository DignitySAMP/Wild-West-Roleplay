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
#define POSSE_BADGE_MAX (3)
#define POSSE_RANK_ADMIN ("Admin")
#define POSSE_RANK_NEW ("Newcomer")

forward Posse_FlowDeferred(playerid,token,flow,arg,amount,cents);
forward Posse_CreateDeferred(playerid,token,slots,const name[]);

enum _:E_POSSE_FLOW
{
    POSSE_FLOW_MEMBERS = 0,
    POSSE_FLOW_DEPOSIT,
    POSSE_FLOW_WITHDRAW,
    POSSE_FLOW_DELETE,
    POSSE_FLOW_RELOAD,
}

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
static bool:Posse_Require(playerid,tier,const text[])
{
    if (!Posse_IsMember(playerid))
    {
        SendServerMessage(playerid,"You're not in a posse.",MSG_TYPE_INFO);
        return false;
    }

    if (Posse_GetTier(playerid) < tier)
    {
        SendServerMessage(playerid,text,MSG_TYPE_WARN);
        return false;
    }

    return true;
}

static bool:Posse_TargetOk(playerid,target,const text[])
{
    if (!Staff_IsValidTarget(target) || !Posse_IsLoaded(target))
    {
        SendServerMessage(playerid,text,MSG_TYPE_ERROR);
        return false;
    }

    return true;
}

static Posse_Defer(playerid,flow,arg = 0,amount = 0,cents = 0)
{
    SetTimerEx("Posse_FlowDeferred",0,false,"dddddd",playerid,Account_GetToken(playerid),flow,arg,amount,cents);
}

static Posse_Members(playerid)
{
    yield 1;

    new posseid = Posse_GetPlayer(playerid), token = Account_GetToken(playerid), body[1024], response[DIALOG_RESPONSE];

    if (posseid == POSSE_NONE)
    {
        return;
    }

    await mysql_aquery_s(g_Mysql,str_format("SELECT character_id, character_name, character_posserank FROM characters WHERE character_posse = %d",posseid),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    foreach (new i : Player)
    {
        if (Posse_GetPlayer(i) == posseid)
        {
            new rank[POSSE_RANK_LEN], name[ACCOUNT_NAME_LEN], line[128];
            Posse_GetRank(i,rank);
            GetPlayerName(i,name,sizeof(name));
            format(line,sizeof(line),"{629C5C}[ONLINE]:{DEDEDE} %s %s\n",rank,name);
            strcat(body,line,sizeof(body));
        }
    }

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, name[ACCOUNT_NAME_LEN], rank[POSSE_RANK_LEN], bool:online = false;
        cache_get_value_name_int(i,"character_id",id);
        cache_get_value_name(i,"character_name",name);
        cache_get_value_name(i,"character_posserank",rank);

        foreach (new j : Player)
        {
            if (Character_GetId(j) == id)
            {
                online = true;
            }
        }

        if (!online)
        {
            new line[128];
            format(line,sizeof(line),"{FF6347}[OFFLINE]:{DEDEDE} %s %s\n",rank,name);
            strcat(body,line,sizeof(body));
        }
    }

    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"Posse Members",body,"Exit","");
}

static Posse_BankFlow(playerid,bool:deposit,dollars,cents)
{
    yield 1;

    new token = Account_GetToken(playerid), posseid = Posse_GetPlayer(playerid), response[DIALOG_RESPONSE];

    if (posseid == POSSE_NONE)
    {
        return;
    }

    if (deposit)
    {
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"{C23030}WARNING","{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\nYou're about to deposit your money into the posse's bank.\nYou will be unable to obtain your money back without having tier 3.\n\nWith that in mind, go ahead.","{C23030}Proceed","Cancel");
    }
    else
    {
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"{C23030}ABUSE WARNING","{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\nYou're about to withdraw money from the posse's bank.\nAbuse of this will lead to you being caught, and you being /PERMANENTLY/ banned.\n\nWith that in mind, go ahead.","{C23030}Proceed","Cancel");
    }

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE] || Posse_GetPlayer(playerid) != posseid)
    {
        return;
    }

    new amount = Money_Make(dollars,cents), line[160], name[ACCOUNT_NAME_LEN], whole[16];
    GetPlayerName(playerid,name,sizeof(name));
    Money_Delimit(dollars,whole);

    if (deposit)
    {
        if (!Money_Take(playerid,amount))
        {
            SendServerMessage(playerid,"You don't have that much money to deposit.",MSG_TYPE_ERROR);
            return;
        }

        Posse_BankGive(posseid,amount);
        format(line,sizeof(line),"%s (%d) has deposited $%s.%02d into the posse's bank.",name,playerid,whole,cents);
    }
    else
    {
        if (Posse_GetTier(playerid) < POSSE_TIER_LEADER || !Posse_BankTake(posseid,amount))
        {
            SendServerMessage(playerid,"The posse's bank doesn't have that much money to withdraw.",MSG_TYPE_ERROR);
            return;
        }

        Money_Give(playerid,amount);
        format(line,sizeof(line),"%s (%d) has withdrawn $%s.%02d from the posse's bank.",name,playerid,whole,cents);
    }

    Posse_Message(posseid,line);
}

static Posse_DeleteFlow(playerid,posseid)
{
    yield 1;

    new token = Account_GetToken(playerid), response[DIALOG_RESPONSE];
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"{C23030}ABUSE WARNING","{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\nYou're about to delete a posse.\nIf you're abusing this option, you will be caught and PERMANENTLY banned.\n\nWith that in mind, go ahead.","{C23030}Proceed","Cancel");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE] || !Posse_Exists(posseid))
    {
        return;
    }

    new posse[e_POSSE], name[ACCOUNT_NAME_LEN], line[160];
    Posse_Get(posseid,posse);
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"[STAFF] %s (%d) deleted posse \"%s\" (%d).",name,playerid,posse[E_POSSE_NAME],posseid);
    SendModeratorWarning(line,MOD_WARNING_MED);
    Posse_Delete(posseid);
}

static Posse_CreateFlow(playerid,slots,const name[])
{
    yield 1;

    new token = Account_GetToken(playerid), posseid = await Posse_Create(name,POSSE_TYPE_LAW,slots);

    if (!Account_IsCurrent(playerid,token) || posseid <= 0)
    {
        return;
    }

    new staff[ACCOUNT_NAME_LEN], line[160];
    GetPlayerName(playerid,staff,sizeof(staff));
    format(line,sizeof(line),"[STAFF] %s (%d) created posse \"%s\" with %d slots.",staff,playerid,name,slots);
    SendModeratorWarning(line,MOD_WARNING_MED);
    SendServerMessage(playerid,"Assign a type and type using /aposse type and /aposse leader.",MSG_TYPE_WARN);
}

static Posse_ReloadFlow(playerid)
{
    yield 1;

    new token = Account_GetToken(playerid);
    await Posse_Reload();

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    new name[ACCOUNT_NAME_LEN], line[128];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"[STAFF] %s (%d) reloaded all posses.",name,playerid);
    SendModeratorWarning(line,MOD_WARNING_LOW);
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
CMD:badge(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Posse_IsLawMember(playerid))
    {
        SendServerMessage(playerid,"You have to be in a police posse in order to do this command.",MSG_TYPE_INFO);
        return 1;
    }

    new type;

    if (sscanf(params,"i",type))
    {
        SendServerMessage(playerid,"/badge [type: 0 - 3]",MSG_TYPE_ERROR);
        return 1;
    }

    if (type < 0 || type > POSSE_BADGE_MAX)
    {
        SendServerMessage(playerid,"No lower than 0, or higher than 3!",MSG_TYPE_ERROR);
        return 1;
    }

    new models[4] = {19347,19774,19775,19776};
    SetPlayerAttachedObject(playerid,EQUIP_SLOT,models[type],1);
    EditAttachedObject(playerid,EQUIP_SLOT);
    SendServerMessage(playerid,"You can now edit the badge. Reminder: equipping an item will remove it.",MSG_TYPE_ERROR);
    return 1;
}

CMD:posses(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    for (new Iter:it = Posse_Iterator();iter_inside(it);iter_move_next(it))
    {
        new posse[e_POSSE], line[128];
        iter_get_arr(it,posse);
        format(line,sizeof(line),"%s, ID %d [members online: %d]",posse[E_POSSE_NAME],iter_get_key(it),Posse_GetOnlineCount(iter_get_key(it)));
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
    }

    return 1;
}

CMD:posse(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Posse_IsMember(playerid))
    {
        SendServerMessage(playerid,"You're not in a posse.",MSG_TYPE_INFO);
        return 1;
    }

    new option[32], value, extra[64], posseid = Posse_GetPlayer(playerid), rank[POSSE_RANK_LEN], mine[ACCOUNT_NAME_LEN];

    if (sscanf(params,"s[32]I(-1)S(-1)[64]",option,value,extra))
    {
        SendServerMessage(playerid,"/posse [chat, invite, uninvite, tier, rank, spawn, members] [player: optional] [extra: optional]",MSG_TYPE_ERROR);
        return 1;
    }

    Posse_GetRank(playerid,rank);
    GetPlayerName(playerid,mine,sizeof(mine));
    new line[200];

    if (!strcmp(option,"chat"))
    {
        if (!Posse_Require(playerid,POSSE_TIER_COMMAND,"You lack the correct privileges to perform this action."))
        {
            return 1;
        }

        new bool:on = Posse_ToggleChat(posseid);
        format(line,sizeof(line),"{[ %s %s (%d) has turned the posse chat %s. ]}",rank,mine,playerid,on ? ("on") : ("off"));
        Posse_Warning(posseid,line);
    }
    else if (!strcmp(option,"invite"))
    {
        if (!Posse_Require(playerid,POSSE_TIER_COMMAND,"You lack the correct privileges to perform this action."))
        {
            return 1;
        }

        if (!Posse_TargetOk(playerid,value,"/posse invite [player] - entered player doesn't exist."))
        {
            return 1;
        }

        if (Posse_IsMember(value))
        {
            SendServerMessage(playerid,"Player is already in a posse.",MSG_TYPE_WARN);
            return 1;
        }

        new target[ACCOUNT_NAME_LEN];
        GetPlayerName(value,target,sizeof(target));
        Posse_SetMember(value,posseid,POSSE_TIER_MEMBER,POSSE_RANK_NEW);
        format(line,sizeof(line),"{[ %s %s (%d) has invited %s (%d) to join the posse. ]}",rank,mine,playerid,target,value);
        Posse_Warning(posseid,line);
    }
    else if (!strcmp(option,"uninvite"))
    {
        if (!Posse_Require(playerid,POSSE_TIER_LEADER,"Only the posse leader can perform this action."))
        {
            return 1;
        }

        if (!Posse_TargetOk(playerid,value,"/posse uninvite [player] - entered player doesn't exist."))
        {
            return 1;
        }

        if (Posse_GetPlayer(value) != posseid)
        {
            SendServerMessage(playerid,"That player isn't in your posse.",MSG_TYPE_ERROR);
            return 1;
        }

        new target[ACCOUNT_NAME_LEN];
        GetPlayerName(value,target,sizeof(target));
        format(line,sizeof(line),"{[ %s %s (%d) has removed %s (%d) from the posse. ]}",rank,mine,playerid,target,value);
        Posse_Warning(posseid,line);
        Posse_SetMember(value,POSSE_NONE,0,"None");
    }
    else if (!strcmp(option,"tier"))
    {
        new tier = strval(extra);

        if (!Posse_Require(playerid,POSSE_TIER_LEADER,"You lack the correct privileges to perform this action."))
        {
            return 1;
        }

        if (!Posse_TargetOk(playerid,value,"/posse tier [player] [tier] - entered player doesn't exist."))
        {
            return 1;
        }

        if (tier < 1 || tier > 3)
        {
            SendServerMessage(playerid,"Tier can't be less than 1 or more than 3.",MSG_TYPE_WARN);
            return 1;
        }

        if (Posse_GetPlayer(value) != posseid)
        {
            SendServerMessage(playerid,"That player isn't in your posse.",MSG_TYPE_ERROR);
            return 1;
        }

        new target[ACCOUNT_NAME_LEN];
        GetPlayerName(value,target,sizeof(target));
        Posse_SetTier(value,tier);
        format(line,sizeof(line),"{[ %s %s (%d) has set %s (%d)'s tier to %d. ]}",rank,mine,playerid,target,value,tier);
        Posse_Warning(posseid,line);
    }
    else if (!strcmp(option,"rank"))
    {
        if (!Posse_TargetOk(playerid,value,"/posse rank [player] [rank] - entered player doesn't exist."))
        {
            return 1;
        }

        if (!Posse_Require(playerid,POSSE_TIER_COMMAND,"You lack the correct privileges to perform this action."))
        {
            return 1;
        }

        if (strlen(extra) >= POSSE_RANK_LEN)
        {
            SendServerMessage(playerid,"Rank can't be longer than 36 characters.",MSG_TYPE_WARN);
            return 1;
        }

        if (Posse_GetPlayer(value) != posseid)
        {
            SendServerMessage(playerid,"That player isn't in your posse.",MSG_TYPE_ERROR);
            return 1;
        }

        new target[ACCOUNT_NAME_LEN];
        GetPlayerName(value,target,sizeof(target));
        Posse_SetRank(value,extra);
        format(line,sizeof(line),"{[ %s %s (%d) has set %s (%d)'s rank to %s. ]}",rank,mine,playerid,target,value,extra);
        Posse_Warning(posseid,line);
    }
    else if (!strcmp(option,"spawn"))
    {
        if (!Posse_Require(playerid,POSSE_TIER_LEADER,"You lack the correct privileges to perform this action."))
        {
            return 1;
        }

        new posse[e_POSSE], Float:x, Float:y, Float:z;
        Posse_Get(posseid,posse);
        GetPlayerPos(playerid,x,y,z);
        posse[E_POSSE_SPAWN_X] = x;
        posse[E_POSSE_SPAWN_Y] = y;
        posse[E_POSSE_SPAWN_Z] = z;
        posse[E_POSSE_SPAWN_INT] = GetPlayerInterior(playerid);
        posse[E_POSSE_SPAWN_VW] = GetPlayerVirtualWorld(playerid);
        Posse_Commit(posseid,posse);
        mysql_tquery_s(g_Mysql,str_format("UPDATE posses SET posse_spawn_x = %f, posse_spawn_y = %f, posse_spawn_z = %f, posse_spawn_int = %d, posse_spawn_vw = %d WHERE posse_id = %d",x,y,z,posse[E_POSSE_SPAWN_INT],posse[E_POSSE_SPAWN_VW],posseid));
        format(line,sizeof(line),"{[ %s %s (%d) has changed the faction spawnpoint. ]}",rank,mine,playerid);
        Posse_Warning(posseid,line);
    }
    else if (!strcmp(option,"kiosk"))
    {
        SendServerMessage(playerid,"Use /possekiosk instead.",MSG_TYPE_ERROR);
    }
    else if (!strcmp(option,"members"))
    {
        Posse_Defer(playerid,POSSE_FLOW_MEMBERS);
    }
    else
    {
        SendServerMessage(playerid,"/posse [invite, uninvite, tier, rank, spawn, members] [player: optional] [extra: optional]",MSG_TYPE_ERROR);
    }

    return 1;
}

CMD:possehelp(cmdid,playerid,params[])
{
    if (Posse_IsMember(playerid) && Posse_GetPlayer(playerid) != POSSE_NONE && Posse_IsLawPosse(Posse_GetPlayer(playerid)))
    {
        SendClientMessage(playerid,0x2C572CFF,"[POLICE] /cuff, /disarm, /charge, /clearcharge, /viewcharges, /prison, /unprison");
        SendClientMessage(playerid,0x2C572CFF,"[POLICE] /pkiosk, /poster, /td (/r), /removeposter, /viewdebt, /prisoners, /tackle");
    }

    return cmd_posse(cmdid,playerid,params);
}

CMD:possechat(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[144], posseid = Posse_GetPlayer(playerid), line[256], rank[POSSE_RANK_LEN], name[ACCOUNT_NAME_LEN];

    if (posseid == POSSE_NONE)
    {
        SendServerMessage(playerid,"You're not in a posse.",MSG_TYPE_INFO);
        return 1;
    }

    if (sscanf(params,"s[144]",text))
    {
        SendServerMessage(playerid,"/possechat <text>",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Posse_ChatEnabled(posseid) && Posse_GetTier(playerid) < POSSE_TIER_COMMAND)
    {
        SendServerMessage(playerid,"Posse chat is off.",MSG_TYPE_ERROR);
        return 1;
    }

    Posse_GetRank(playerid,rank);
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"{[ %s %s (%d): %s ]}",rank,name,playerid,text);
    Posse_Message(posseid,line);
    return 1;
}

ALT:pc=CMD:possechat;

CMD:possebank(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new posseid = Posse_GetPlayer(playerid), posse[e_POSSE], option[16], amount, cents;

    if (posseid == POSSE_NONE)
    {
        SendServerMessage(playerid,"You're not in a posse.",MSG_TYPE_ERROR);
        return 1;
    }

    Posse_Get(posseid,posse);

    if (!IsPlayerInRangeOfPoint(playerid,POSSE_BANK_RANGE,posse[E_POSSE_SPAWN_X],posse[E_POSSE_SPAWN_Y],posse[E_POSSE_SPAWN_Z]))
    {
        SendServerMessage(playerid,"You're not at your posse's spawn point.",MSG_TYPE_ERROR);
        return 1;
    }

    if (sscanf(params,"s[16]I(-1)I(0)",option,amount,cents))
    {
        SendServerMessage(playerid,"/p(osse)bank [balance, deposit, withdraw] [optional:dollars] [optional:cents]",MSG_TYPE_ERROR);
        return 1;
    }

    new line[160], whole[16];

    if (!strcmp(option,"balance",true))
    {
        Money_Delimit(Money_Dollars(posse[E_POSSE_BANK]),whole);
        format(line,sizeof(line),"%s's Bank Balance: $%s.%02d",posse[E_POSSE_NAME],whole,Money_Cents(posse[E_POSSE_BANK]));
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        return 1;
    }

    new bool:deposit = !strcmp(option,"deposit",true), bool:withdraw = !strcmp(option,"withdraw",true);

    if (!deposit && !withdraw)
    {
        SendServerMessage(playerid,"/p(osse)bank [balance, deposit, withdraw] [optional:dollars] [optional:cents]",MSG_TYPE_ERROR);
        return 1;
    }

    if (withdraw && Posse_GetTier(playerid) < POSSE_TIER_LEADER)
    {
        SendServerMessage(playerid,"You lack the correct privileges to perform this action.",MSG_TYPE_WARN);
        return 1;
    }

    if (amount == -1)
    {
        SendServerMessage(playerid,"You need to input a value.",MSG_TYPE_ERROR);
        return 1;
    }

    if (amount < 0)
    {
        SendServerMessage(playerid,deposit ? ("You cannot deposit a negative amount of money.") : ("You cannot withdraw a negative amount of money."),MSG_TYPE_ERROR);
        return 1;
    }

    if (cents < 0 || cents > 99)
    {
        SendServerMessage(playerid,deposit ? ("You can only give between 0-99 cent(s).") : ("You can only take between 0-99 cent(s)."),MSG_TYPE_ERROR);
        return 1;
    }

    if (amount > MONEY_MAX_DOLLARS || (amount == 0 && cents == 0))
    {
        SendServerMessage(playerid,deposit ? ("You don't have that much money to deposit.") : ("The posse's bank doesn't have that much money to withdraw."),MSG_TYPE_ERROR);
        return 1;
    }

    new total = Money_Make(amount,cents);

    if (deposit && !Money_CanAfford(playerid,total))
    {
        SendServerMessage(playerid,"You don't have that much money to deposit.",MSG_TYPE_ERROR);
        return 1;
    }

    if (withdraw && posse[E_POSSE_BANK] < total)
    {
        SendServerMessage(playerid,"The posse's bank doesn't have that much money to withdraw.",MSG_TYPE_ERROR);
        return 1;
    }

    Posse_Defer(playerid,deposit ? POSSE_FLOW_DEPOSIT : POSSE_FLOW_WITHDRAW,0,amount,cents);
    return 1;
}

ALT:pbank=CMD:possebank;

CMD:aposse(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    new option[32], value, extra[64];

    if (sscanf(params,"s[32]I(0)S(-1)[64]",option,value,extra))
    {
        SendServerMessage(playerid,"/aposse [create, delete, leader, name, type] [extra: optional]",MSG_TYPE_ERROR);
        return 1;
    }

    new line[200], mine[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,mine,sizeof(mine));

    if (!strcmp(option,"create"))
    {
        if (value < 1 || isnull(extra) || !strcmp(extra,"-1"))
        {
            SendServerMessage(playerid,"/aposse create [slots] [name]",MSG_TYPE_ERROR);
            return 1;
        }

        if (strlen(extra) >= POSSE_NAME_LEN)
        {
            SendServerMessage(playerid,"Name can't be longer than 36 or less than 4 characters.",MSG_TYPE_INFO);
            return 1;
        }

        SetTimerEx("Posse_CreateDeferred",0,false,"ddds",playerid,Account_GetToken(playerid),value,extra);
        return 1;
    }

    if (!Posse_Exists(value) && strcmp(option,"create"))
    {
        SendServerMessage(playerid,"Selected posse doesn't exist.",MSG_TYPE_INFO);
        return 1;
    }

    if (!strcmp(option,"delete"))
    {
        Posse_Defer(playerid,POSSE_FLOW_DELETE,value);
    }
    else if (!strcmp(option,"name"))
    {
        if (strlen(extra) >= POSSE_NAME_LEN || strlen(extra) < POSSE_NAME_MIN)
        {
            SendServerMessage(playerid,"Name can't be longer than 36 or less than 4 characters.",MSG_TYPE_INFO);
            return 1;
        }

        new posse[e_POSSE];
        Posse_Get(value,posse);
        strcopy(posse[E_POSSE_NAME],extra,POSSE_NAME_LEN);
        Posse_Commit(value,posse);
        mysql_tquery_s(g_Mysql,str_format("UPDATE posses SET posse_name = '%e' WHERE posse_id = %d",extra,value));
        format(line,sizeof(line),"{[ Admin %s (%d) has changed the posse's name to %s. ]}",mine,playerid,extra);
        Posse_Warning(value,line);
        format(line,sizeof(line),"[STAFF] %s (%d) renamed posse ID %d to %s.",mine,playerid,value,extra);
        SendModeratorWarning(line,MOD_WARNING_LOW);
    }
    else if (!strcmp(option,"leader"))
    {
        Posse_SetMember(playerid,value,POSSE_TIER_LEADER,POSSE_RANK_ADMIN);
        format(line,sizeof(line),"{[ Admin %s (%d) has made themselves the leader of the posse. ]}",mine,playerid);
        Posse_Warning(value,line);
        format(line,sizeof(line),"[STAFF] %s (%d) has made themselves leader of posse ID %d.",mine,playerid,value);
        SendModeratorWarning(line,MOD_WARNING_MED);
    }
    else if (!strcmp(option,"type"))
    {
        new type = strval(extra);

        if (type < POSSE_TYPE_OUTLAW || type > POSSE_TYPE_GANG)
        {
            SendServerMessage(playerid,"Type can't be less than 0 or more than 3.",MSG_TYPE_INFO);
            return 1;
        }

        new posse[e_POSSE];
        Posse_Get(value,posse);
        posse[E_POSSE_TYPE] = type;
        Posse_Commit(value,posse);
        mysql_tquery_s(g_Mysql,str_format("UPDATE posses SET posse_type = %d WHERE posse_id = %d",type,value));
        format(line,sizeof(line),"{[ Admin %s (%d) has changed the posse's type to %d. ]}",mine,playerid,type);
        Posse_Warning(value,line);
        format(line,sizeof(line),"[STAFF] %s (%d) has set posse ID %d's type to %d.",mine,playerid,value,type);
        SendModeratorWarning(line,MOD_WARNING_LOW);
    }
    else
    {
        SendServerMessage(playerid,"/aposse [create, delete, leader, name, type] [extra: optional]",MSG_TYPE_ERROR);
    }

    return 1;
}

CMD:reloadposses(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    Posse_Defer(playerid,POSSE_FLOW_RELOAD);
    return 1;
}

public Posse_CreateDeferred(playerid,token,slots,const name[])
{
    if (Account_IsCurrent(playerid,token))
    {
        Posse_CreateFlow(playerid,slots,name);
    }

    return 1;
}

public Posse_FlowDeferred(playerid,token,flow,arg,amount,cents)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    switch (flow)
    {
        case POSSE_FLOW_MEMBERS:
        {
            Posse_Members(playerid);
        }
        case POSSE_FLOW_DEPOSIT:
        {
            Posse_BankFlow(playerid,true,amount,cents);
        }
        case POSSE_FLOW_WITHDRAW:
        {
            Posse_BankFlow(playerid,false,amount,cents);
        }
        case POSSE_FLOW_DELETE:
        {
            Posse_DeleteFlow(playerid,arg);
        }
        case POSSE_FLOW_RELOAD:
        {
            Posse_ReloadFlow(playerid);
        }
    }

    return 1;
}
