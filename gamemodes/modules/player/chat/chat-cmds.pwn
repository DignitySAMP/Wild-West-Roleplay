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
forward Chat_PmDeferred(playerid,token,target,const text[]);

static bool:s_OocEnabled;
static bool:s_OocHidden[MAX_PLAYERS];
static bool:s_PmBlocked[MAX_PLAYERS];
static bool:s_PmWarned[MAX_PLAYERS];

static const s_AccentNames[30][] =
{
    "Baysidian","Fremont","Longcreek","Whetstone","Minnesota","Nebraska","Californian","Wisconsin","Kansas","Texas",
    "Oklahoma","New Mexico","Arizona","Lousiana","Mississipi","Missouri","Arkansas","Louisiana","Illinois","Wyoming",
    "Nevada","California","Irish","Scottish","British","Native","Spanish","French","Dutch","Foreign"
};

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
stock bool:Chat_IsOocEnabled()
{
    return s_OocEnabled;
}

stock bool:Chat_IsOocHidden(playerid)
{
    return s_OocHidden[playerid];
}

stock bool:Chat_IsPmBlocked(playerid)
{
    return s_PmBlocked[playerid];
}

static Chat_StaffTint(playerid,dest[],size = sizeof(dest))
{
    if (Account_GetId(playerid) == 1 || Account_GetId(playerid) == 2)
    {
        strcopy(dest,"855A83",size);
    }
    else if (Staff_IsManager(playerid))
    {
        strcopy(dest,"AD2D2D",size);
    }
    else
    {
        strcopy(dest,"449C44",size);
    }
}

static Chat_Send(playerid,Float:range,colour,const text[],const tag[],const logText[])
{
    ProxDetector(playerid,range,colour,text);
    Log_Info(tag,"%s",logText);
}

static Chat_Action(playerid,Float:range,const mark[],const joiner[],const text[],const tag[])
{
    new line[256], logLine[256], name[ACCOUNT_NAME_LEN], real[MAX_PLAYER_NAME + 1];
    Name_Display(playerid,name);
    GetPlayerName(playerid,real,sizeof(real));
    format(line,sizeof(line),"* %s%s%s",name,joiner,text);
    format(logLine,sizeof(logLine),"[%s] %s%s%s",mark,real,joiner,text);
    Chat_Send(playerid,range,COLOR_ACTION,line,tag,logLine);
}

static Chat_Do(playerid,Float:range,const mark[],const text[])
{
    new line[256], logLine[256], name[ACCOUNT_NAME_LEN], real[MAX_PLAYER_NAME + 1];
    Name_Display(playerid,name);
    GetPlayerName(playerid,real,sizeof(real));
    format(line,sizeof(line),"* %s (( %s ))",text,name);
    format(logLine,sizeof(logLine),"[%s] %s (( %s ))",mark,text,real);
    Chat_Send(playerid,range,COLOR_ACTION,line,"chat/action",logLine);
}

static bool:Chat_Usage(playerid,const params[],text[],size,const usage[])
{
    if (sscanf(params,"s[144]",text))
    {
        SendServerMessage(playerid,usage,MSG_TYPE_ERROR);
        return false;
    }

    #pragma unused size
    return true;
}

static Chat_Spoken(playerid,const verb[],Float:range,colour,const text[])
{
    new line[256], logLine[256], name[ACCOUNT_NAME_LEN], real[MAX_PLAYER_NAME + 1], accent[CHAT_ACCENT_LEN];
    Name_Display(playerid,name);
    GetPlayerName(playerid,real,sizeof(real));
    Chat_GetAccent(playerid,accent);

    if (accent[0] == EOS)
    {
        format(line,sizeof(line),"%s %s: %s",name,verb,text);
    }
    else
    {
        format(line,sizeof(line),"%s %s [%s accent]: %s",name,verb,accent,text);
    }

    format(logLine,sizeof(logLine),"%s %s: %s",real,verb,text);
    Chat_Send(playerid,range,colour,line,"chat/local",logLine);
}

static bool:Chat_Reachable(playerid,target)
{
    if (!IsPlayerConnected(target))
    {
        SendServerMessage(playerid,"Player isn't connected.",MSG_TYPE_ERROR);
        return false;
    }

    if (!Player_IsReady(target) || !Player_IsSpawned(target))
    {
        SendServerMessage(playerid,"That player hasn't spawned yet.",MSG_TYPE_ERROR);
        return false;
    }

    return true;
}

static Chat_Ping(target)
{
    GameTextForPlayer(target,"~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~New message!",3000,3);
    PlayerPlaySound(target,1085,0.0,0.0,0.0);
}

static Chat_PmName(playerid,tint,dest[],size = sizeof(dest))
{
    new name[ACCOUNT_NAME_LEN];
    Name_Display(playerid,name);

    if (Staff_IsOnDuty(playerid))
    {
        new colour[8];
        Chat_StaffTint(playerid,colour);
        format(dest,size,"{%s}%s (%d){%06X}",colour,name,playerid,tint);
        return;
    }

    format(dest,size,"%s (%d)",name,playerid);
}

static Chat_PmSend(playerid,target,const text[])
{
    new line[300], from[ACCOUNT_NAME_LEN + 24], to[ACCOUNT_NAME_LEN + 24], names[2][MAX_PLAYER_NAME + 1];
    Chat_Ping(target);
    Chat_PmName(playerid,0xFFCC22,from);
    Chat_PmName(target,0xFFFF22,to);
    format(line,sizeof(line),"(( PM from %s: %s ))",from,text);
    SendSplitMessage(target,0xFFCC2299,line);
    format(line,sizeof(line),"(( PM to %s: %s ))",to,text);
    SendSplitMessage(playerid,0xFFFF22AA,line);
    GetPlayerName(playerid,names[0],MAX_PLAYER_NAME + 1);
    GetPlayerName(target,names[1],MAX_PLAYER_NAME + 1);
    Log_Info(Staff_IsModerator(target) ? "chat" : "chat/pm","[PM] %s sends to %s: %s",names[0],names[1],text);
}

static Chat_PmFlow(playerid,token,target,const text[])
{
    yield 1;
    new response[DIALOG_RESPONSE];
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"{D63C3C}PRIVATE MESSAGE WARNING:{DEDEDE}","{D63C3C}WARNING:{DEDEDE} You're sending a private message to a moderator.\n\nPlease make sure your query isn't related to their tasks, since there is /report for that.\n\nIf this moderator is helping you or you have something else to talk about, go ahead.\n\nThanks for understanding.","Proceed","Cancel");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE] || !Chat_Reachable(playerid,target))
    {
        return;
    }

    Chat_PmSend(playerid,target,text);
}

public Chat_PmDeferred(playerid,token,target,const text[])
{
    Chat_PmFlow(playerid,token,target,text);
    return 1;
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
CMD:setchat(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new type;

    if (sscanf(params,"d",type))
    {
        SendServerMessage(playerid,"/setchat [0-6]",MSG_TYPE_ERROR);
        return 1;
    }

    if (type < 0 || type > CHAT_STYLE_MAX)
    {
        SendServerMessage(playerid,"Type can't be less than 0 or higher than 6.",MSG_TYPE_ERROR);
        return 1;
    }

    Chat_SetStyleCached(playerid,type);
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_chatstyle = %d WHERE character_id = %d",type,Character_GetId(playerid)));

    if (type == 0)
    {
        SendServerMessage(playerid,"You have removed your chat animation.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[128];
    format(line,sizeof(line),"You changed your chat animation style to %d. Next time talk you will play the animation.",type);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
}

CMD:accent(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new accent;

    if (sscanf(params,"i",accent))
    {
        SendServerMessage(playerid,"/accent [accent] (/accentlist)",MSG_TYPE_ERROR);
        return 1;
    }

    if (accent < 0 || accent > sizeof(s_AccentNames))
    {
        SendServerMessage(playerid,"Invalid accent. Use /accentlist to get the ID.",MSG_TYPE_ERROR);
        return 1;
    }

    if (accent == sizeof(s_AccentNames))
    {
        Chat_SetAccentCached(playerid,"");
        mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_accent = '' WHERE character_id = %d",Character_GetId(playerid)));
        SendServerMessage(playerid,"You have removed your accent.",MSG_TYPE_INFO);
        return 1;
    }

    new pick[CHAT_ACCENT_LEN], line[96];
    strcopy(pick,s_AccentNames[accent]);
    pick[0] = toupper(pick[0]);
    Chat_SetAccentCached(playerid,pick);
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_accent = '%e' WHERE character_id = %d",pick,Character_GetId(playerid)));
    format(line,sizeof(line),"Your accent has been set to %s.",pick);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
}

CMD:accentlist(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_TAB0,"|______________________| List of available accents |______________________| ");
    SendClientMessage(playerid,COLOR_TAB1,"0) Baysidian, 1) Fremont, 2) Longcreek, 3) Whetstone, 4) Minnesota, 5) Nebraska, 6) Californian");
    SendClientMessage(playerid,COLOR_TAB2,"7) Wisconsin, 8) Kansas, 9) Texas, 10) Oklahoma, 11) New Mexico, 12) Arizona, 13) Lousiana");
    SendClientMessage(playerid,COLOR_TAB1,"14) Mississipi, 15) Missouri, 16) Arkansas, 17) Louisiana, 18) Illinois, 19) Wyoming, 20) Nevada, 21) California");
    SendClientMessage(playerid,COLOR_TAB2,"22) Irish, 23) Scottish, 24) British, 25) Native, 26) Spanish, 27) French, 28) Dutch, 29) Foreign, 30) None");
    return 1;
}

CMD:o(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!s_OocEnabled)
    {
        SendServerMessage(playerid,"OOC Chat is disabled!",MSG_TYPE_ERROR);
        return 1;
    }

    new string[128];

    if (sscanf(params,"s[128]",string))
    {
        SendServerMessage(playerid,"/o(oc) [text]",MSG_TYPE_ERROR);
        return 1;
    }

    new text[300], name[ACCOUNT_NAME_LEN], staffName[ACCOUNT_NAME_LEN], suffix[ACCOUNT_NAME_LEN + 4], real[MAX_PLAYER_NAME + 1];
    Account_GetStaffName(playerid,staffName);
    GetPlayerName(playerid,real,sizeof(real));

    if (staffName[0] != EOS)
    {
        format(suffix,sizeof(suffix)," (%s)",staffName);
    }

    if (Staff_IsOnDuty(playerid))
    {
        new tint[8];
        Chat_StaffTint(playerid,tint);
        Name_Real(playerid,name);
        format(text,sizeof(text),"(( [OOC] {%s}(%d) %s%s{AAC4E5}: %s ))",tint,playerid,name,suffix,string);
    }
    else
    {
        Name_Display(playerid,name);
        format(text,sizeof(text),"(( [OOC] (%d) %s%s: %s ))",playerid,name,suffix,string);
    }

    foreach (new i : Player)
    {
        if (!s_OocHidden[i])
        {
            SendClientMessage(i,CHAT_OOC_COLOUR,text);
        }
    }

    Log_Info("chat/ooc","[GLOBAL OOC] (( (%d) %s: %s ))",playerid,real,string);
    return 1;
}

ALT:ooc=CMD:o;

CMD:noooc(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    s_OocHidden[playerid] = !s_OocHidden[playerid];
    SendServerMessage(playerid,s_OocHidden[playerid] ? ("You're disabled the OOC chat.") : ("You're enabled the OOC chat."),MSG_TYPE_INFO);
    return 1;
}

CMD:toggleooc(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    s_OocEnabled = !s_OocEnabled;
    SendServerMessage(playerid,s_OocEnabled ? ("You have enabled OOC chat.") : ("You have disabled OOC chat."),MSG_TYPE_WARN);
    return 1;
}

CMD:b(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[144], line[256], name[ACCOUNT_NAME_LEN], real[MAX_PLAYER_NAME + 1];

    if (sscanf(params,"s[144]",text))
    {
        SendServerMessage(playerid,"/b [text]",MSG_TYPE_ERROR);
        return 1;
    }

    GetPlayerName(playerid,real,sizeof(real));
    Name_Real(playerid,name);

    if (Staff_IsOnDuty(playerid))
    {
        new tint[8];
        Chat_StaffTint(playerid,tint);
        format(line,sizeof(line),"(( {%s}(%d) %s{999999}: %s ))",tint,playerid,name,text);
        ProxDetector(playerid,CHAT_OOC_DUTY_RANGE,CHAT_GREY,line);
    }
    else
    {
        format(line,sizeof(line),"(( (%d) %s: %s ))",playerid,name,text);
        ProxDetector(playerid,CHAT_OOC_RANGE,CHAT_GREY,line);
    }

    Log_Info("chat/ooc","%s",line);
    return 1;
}

CMD:melow(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[144];

    if (Chat_Usage(playerid,params,text,sizeof(text),"/melow [text]"))
    {
        Chat_Action(playerid,CHAT_LOW_RANGE,"MELOW"," ",text,"chat/action");
    }

    return 1;
}

CMD:me(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[144];

    if (Chat_Usage(playerid,params,text,sizeof(text),"/me(low) [text]"))
    {
        Chat_Action(playerid,CHAT_RANGE,"ME"," ",text,"chat/action");
    }

    return 1;
}

ALT:e=CMD:me;

CMD:mylow(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[144];

    if (Chat_Usage(playerid,params,text,sizeof(text),"/mylow [text]"))
    {
        Chat_Action(playerid,CHAT_LOW_RANGE,"MYLOW","'s ",text,"chat/action");
    }

    return 1;
}

CMD:my(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[144];

    if (Chat_Usage(playerid,params,text,sizeof(text),"/my(low) [text]"))
    {
        Chat_Action(playerid,CHAT_RANGE,"MY","'s ",text,"chat/action");
    }

    return 1;
}

CMD:dolow(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[144];

    if (Chat_Usage(playerid,params,text,sizeof(text),"/dolow [text]"))
    {
        Chat_Do(playerid,CHAT_LOW_RANGE,"DOLOW",text);
    }

    return 1;
}

CMD:do(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[144];

    if (Chat_Usage(playerid,params,text,sizeof(text),"/do(low) [text]"))
    {
        Chat_Do(playerid,CHAT_RANGE,"DO",text);
    }

    return 1;
}

CMD:ame(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[144], line[256], name[ACCOUNT_NAME_LEN], real[MAX_PLAYER_NAME + 1];

    if (!Chat_Usage(playerid,params,text,sizeof(text),"/ame [text]"))
    {
        return 1;
    }

    Name_Display(playerid,name);
    GetPlayerName(playerid,real,sizeof(real));
    format(line,sizeof(line),"> %s %s",name,text);
    SendClientMessage(playerid,COLOR_ACTION,line);
    format(line,sizeof(line),"* %s %s",name,text);
    SetPlayerChatBubble(playerid,line,COLOR_ACTION,CHAT_SHOUT_RANGE,CHAT_BUBBLE_MS);
    Log_Info("chat/action","[AME] %s %s",real,text);
    return 1;
}

CMD:ado(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[144], line[256], name[ACCOUNT_NAME_LEN], real[MAX_PLAYER_NAME + 1];

    if (!Chat_Usage(playerid,params,text,sizeof(text),"/ado [text]"))
    {
        return 1;
    }

    Name_Display(playerid,name);
    GetPlayerName(playerid,real,sizeof(real));
    format(line,sizeof(line),"%s (( %s ))",text,name);
    SetPlayerChatBubble(playerid,line,COLOR_ACTION,CHAT_SHOUT_RANGE,CHAT_BUBBLE_MS);
    format(line,sizeof(line),"> %s (( %s ))",text,name);
    SendClientMessage(playerid,COLOR_ACTION,line);
    Log_Info("chat/action","[ADO] %s %s",real,text);
    return 1;
}

CMD:low(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[144];

    if (Injury_GetMode(playerid) != INJURY_MODE_NORMAL)
    {
        SendServerMessage(playerid,"You can't talk whilst in injury mode",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Chat_Usage(playerid,params,text,sizeof(text),"/low [text]"))
    {
        return 1;
    }

    Chat_Spoken(playerid,"says [low]",CHAT_LOW_RANGE,COLOR_DEFAULT,text);
    return 1;
}

CMD:shout(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[144];

    if (Injury_GetMode(playerid) != INJURY_MODE_NORMAL)
    {
        SendServerMessage(playerid,"You can't talk whilst in injury mode",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Chat_Usage(playerid,params,text,sizeof(text),"/s(hout) [text]"))
    {
        return 1;
    }

    Chat_Spoken(playerid,"shouts",CHAT_SHOUT_RANGE,-1,text);
    return 1;
}

ALT:s=CMD:shout;

CMD:blockpm(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    s_PmBlocked[playerid] = !s_PmBlocked[playerid];
    SendServerMessage(playerid,s_PmBlocked[playerid] ? ("You are now blocking your private messages!") : ("You have unblocked your private messages!"),MSG_TYPE_WARN);
    return 1;
}

CMD:pm(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new target, text[144];

    if (sscanf(params,"us[144]",target,text))
    {
        SendServerMessage(playerid,"/pm [id] [text]",MSG_TYPE_ERROR);
        return 1;
    }

    if (target == playerid)
    {
        SendServerMessage(playerid,"You can't PM yourself.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Chat_Reachable(playerid,target))
    {
        return 1;
    }

    if (Player_IsPaused(target))
    {
        SendServerMessage(playerid,"The player you are messaging is AFK. Use /afklist.",MSG_TYPE_WARN);
    }

    if (s_PmBlocked[target] && !Staff_IsModerator(playerid))
    {
        SendServerMessage(playerid,"The person you are trying to message is blocking their private messages.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Staff_IsModerator(target) && !s_PmWarned[playerid])
    {
        s_PmWarned[playerid] = true;
        SetTimerEx("Chat_PmDeferred",0,false,"ddds",playerid,Account_GetToken(playerid),target,text);
        return 1;
    }

    Chat_PmSend(playerid,target,text);
    return 1;
}

CMD:whisper(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new target, text[144];

    if (sscanf(params,"us[128]",target,text))
    {
        SendServerMessage(playerid,"/whisper [id] [text]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Chat_Reachable(playerid,target))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(target,x,y,z);

    if (!IsPlayerInRangeOfPoint(playerid,CHAT_WHISPER_RANGE,x,y,z))
    {
        SendServerMessage(playerid,"You're not near the player you're trying to whisper!",MSG_TYPE_ERROR);
        return 1;
    }

    new line[300], from[ACCOUNT_NAME_LEN], to[ACCOUNT_NAME_LEN], names[2][MAX_PLAYER_NAME + 1];
    Name_Display(playerid,from);
    Name_Display(target,to);
    Chat_Ping(target);
    format(line,sizeof(line),"Whisper to %s: %s",to,text);
    SendSplitMessage(playerid,0xBF8A6399,line);
    format(line,sizeof(line),"%s whispers: %s",from,text);
    SendSplitMessage(target,0x805637AA,line);
    format(line,sizeof(line),"* %s mutters something to %s.",from,to);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
    GetPlayerName(playerid,names[0],MAX_PLAYER_NAME + 1);
    GetPlayerName(target,names[1],MAX_PLAYER_NAME + 1);
    Log_Info("chat/whisper","[WHISPER] %s sends to %s: %s",names[0],names[1],text);
    return 1;
}

ALT:w=CMD:whisper;

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
    s_OocHidden[playerid] = false;
    s_PmBlocked[playerid] = false;
    s_PmWarned[playerid] = false;
}
