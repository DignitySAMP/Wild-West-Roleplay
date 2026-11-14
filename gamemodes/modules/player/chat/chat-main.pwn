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
#define CHAT_STYLE_MAX (7)
#define CHAT_RANGE (15.0)
#define CHAT_LOW_RANGE (4.5)
#define CHAT_SHOUT_RANGE (30.0)
#define CHAT_OOC_RANGE (20.0)
#define CHAT_OOC_DUTY_RANGE (15.0)
#define CHAT_WHISPER_RANGE (2.5)
#define CHAT_BUBBLE_MS (10000)
#define CHAT_ANIM_MS (1000)
#define CHAT_ACCENT_LEN (32)
#define CHAT_GREY (0xAFAFAFFF)
#define CHAT_OOC_COLOUR (0xAAC4E5FF)

forward Chat_OnText(playerid,const text[]);
forward Chat_OnLoaded(playerid,token);

static s_ChatStyle[MAX_PLAYERS];
static s_ChatAccent[MAX_PLAYERS][CHAT_ACCENT_LEN];
static s_ChatAnimDue[MAX_PLAYERS];
static s_ChatClears[MAX_PLAYERS];

static const s_ChatAnims[CHAT_STYLE_MAX + 1][2][16] =
{
    {"",""},
    {"PED","IDLE_CHAT"},
    {"GANGS","prtial_gngtlkA"},
    {"GANGS","prtial_gngtlkB"},
    {"GANGS","prtial_gngtlkE"},
    {"GANGS","prtial_gngtlkF"},
    {"GANGS","prtial_gngtlkG"},
    {"GANGS","prtial_gngtlkH"}
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
stock Chat_GetStyle(playerid)
{
    return s_ChatStyle[playerid];
}

stock Chat_SetStyleCached(playerid,style)
{
    s_ChatStyle[playerid] = style;
}

stock Chat_GetAccent(playerid,dest[],size = sizeof(dest))
{
    strcopy(dest,s_ChatAccent[playerid],size);
}

stock Chat_SetAccentCached(playerid,const accent[])
{
    strcopy(s_ChatAccent[playerid],accent,CHAT_ACCENT_LEN);
}

stock Chat_GetClears(playerid)
{
    return s_ChatClears[playerid];
}

stock Chat_GetAnimDue(playerid)
{
    return s_ChatAnimDue[playerid];
}

stock Chat_IsFree(playerid)
{
    return Injury_GetMode(playerid) == INJURY_MODE_NORMAL && !Horse_IsRiding(playerid) && !Trap_IsCaught(playerid);
}

static bool:Chat_PlayingChatAnimation(playerid)
{
    new library[16], name[24];
    {
        GetAnimationName(GetPlayerAnimationIndex(playerid),library,sizeof(library),name,sizeof(name));
    }

    for (new style = 1;style <= CHAT_STYLE_MAX;style++)
    {
        if (!strcmp(library,s_ChatAnims[style][0],true) && !strcmp(name,s_ChatAnims[style][1],true))
        {
            return true;
        }
    }

    return false;
}

static Chat_Speak(playerid,const text[])
{
    new line[256], name[ACCOUNT_NAME_LEN], accent[CHAT_ACCENT_LEN], real[MAX_PLAYER_NAME + 1];
    Name_Display(playerid,name);
    strcopy(accent,s_ChatAccent[playerid]);

    if (accent[0] == EOS)
    {
        format(line,sizeof(line),"%s says: %s",name,text);
    }
    else
    {
        format(line,sizeof(line),"%s says [%s accent]: %s",name,accent,text);
    }

    ProxDetector(playerid,CHAT_RANGE,COLOR_DEFAULT,line);
    SetPlayerChatBubble(playerid,line,COLOR_DEFAULT,CHAT_RANGE,CHAT_BUBBLE_MS);
    GetPlayerName(playerid,real,sizeof(real));
    Log_Info("chat/local","%s says: %s",real,text);

    if (s_ChatStyle[playerid] == 0 || !Chat_IsFree(playerid) || Anim_IsLooping(playerid) || Player_IsBusyWith(playerid,E_PLAYER_BUSY_POKER))
    {
        return;
    }

    ApplyAnimation(playerid,s_ChatAnims[s_ChatStyle[playerid]][0],s_ChatAnims[s_ChatStyle[playerid]][1],4.1,false,false,false,true,1,SYNC_ALL);
    s_ChatAnimDue[playerid] = GetTickCount() + CHAT_ANIM_MS;
}

public Chat_OnText(playerid,const text[])
{
    if (!Player_IsReady(playerid) || !Player_IsSpawned(playerid))
    {
        SendServerMessage(playerid,COMMAND_REPLY_NOT_LOGGED_IN,MSG_TYPE_ERROR);
        return 0;
    }

    if (Injury_GetMode(playerid) != INJURY_MODE_NORMAL)
    {
        SendServerMessage(playerid,"You can't talk whilst in injury mode",MSG_TYPE_ERROR);
        return 0;
    }

    if (Point_IsSleeping(playerid))
    {
        SendServerMessage(playerid,"You can't talk while using /point sleep.",MSG_TYPE_ERROR);
        return 0;
    }

    Chat_Speak(playerid,text);
    return 0;
}

public Chat_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    s_ChatStyle[playerid] = 0;
    s_ChatAccent[playerid][0] = EOS;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_chatstyle",s_ChatStyle[playerid]);
        cache_get_value_name(0,"character_accent",s_ChatAccent[playerid],CHAT_ACCENT_LEN);
        strtrim(s_ChatAccent[playerid]);
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

hook OnMigrationRun()
{
    Migration_Add("people-2-chat-columns","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_chatstyle INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_accent VARCHAR(32) NOT NULL DEFAULT ''");
}

hook OnPlayerConnect(playerid)
{
    s_ChatStyle[playerid] = 0;
    s_ChatAccent[playerid][0] = EOS;
    s_ChatAnimDue[playerid] = 0;
}

hook Character_OnLoad(playerid,characterid)
{
    mysql_tquery_s(g_Mysql,str_format("SELECT character_chatstyle, character_accent FROM characters WHERE character_id = %d",characterid),"Chat_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Tick_OnPlayerSecond(playerid)
{
    if (s_ChatAnimDue[playerid] == 0 || GetTickCount() - s_ChatAnimDue[playerid] < 0)
    {
        return;
    }

    s_ChatAnimDue[playerid] = 0;

    if (Chat_PlayingChatAnimation(playerid))
    {
        s_ChatClears[playerid]++;
        ClearAnimations(playerid,SYNC_ALL);
    }
}
