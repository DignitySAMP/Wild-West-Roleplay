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
#define STAFF_REASON_LEN (65)
#define STAFF_TEXT_LEN (145)
#define STAFF_NOTE_MAX (64)
#define STAFF_CONVO_NONE (-1)
#define STAFF_CONVO_COLOUR (0x955DD9FF)
#define STAFF_MOD_CHAT_COLOUR (0x46B346FF)
#define STAFF_REPORT_COOLDOWN (30)
#define STAFF_ISLAND_X (625.9899)
#define STAFF_ISLAND_Y (-2669.7793)
#define STAFF_ISLAND_Z (1.7300)
#define STAFF_RECORD_PAGE (20)
#define STAFF_RECORD_MAX (100)
#define STAFF_AOOC_COLOUR (0xFFA500FF)
#define STAFF_NAME_INPUT (65)

#if !defined MANAGER_COLOR
    #define MANAGER_COLOR (0xAD2D2DFF)
#endif

#if !defined MODERATOR_COLOR
    #define MODERATOR_COLOR (0x449C44FF)
#endif

#if !defined SUPPORTER_COLOR
    #define SUPPORTER_COLOR (0x44639CFF)
#endif

enum _:E_STAFF_LEVEL
{
    E_STAFF_LEVEL_NONE = 0,
    E_STAFF_LEVEL_SUPPORTER,
    E_STAFF_LEVEL_MODERATOR,
    E_STAFF_LEVEL_MANAGER,
    E_STAFF_LEVEL_DEVELOPER,
}

enum _:E_STAFF_GROUP
{
    E_STAFF_GROUP_NONE = 0,
    E_STAFF_GROUP_TRIAL,
    E_STAFF_GROUP_BASIC,
    E_STAFF_GROUP_GENERAL,
    E_STAFF_GROUP_ADVANCED,
}

enum _:E_RECORD_TYPE
{
    E_RECORD_TYPE_KICK = 0,
    E_RECORD_TYPE_AJAIL,
    E_RECORD_TYPE_BAN,
}

static bool:s_StaffWarnings[MAX_PLAYERS];
static bool:s_StaffMutedModerator[MAX_PLAYERS];
static bool:s_StaffMutedSupporter[MAX_PLAYERS];
static bool:s_StaffOnDuty[MAX_PLAYERS];
static s_StaffConvo[MAX_PLAYERS];
static bool:s_StaffReportPending[MAX_PLAYERS];
static s_StaffReportTarget[MAX_PLAYERS];
static s_StaffReportTargetName[MAX_PLAYERS][ACCOUNT_NAME_LEN];
static s_StaffReportReason[MAX_PLAYERS][STAFF_REASON_LEN];
static s_StaffReportCooldown[MAX_PLAYERS];
static s_StaffReportTime[MAX_PLAYERS];

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
stock Staff_GetLevel(playerid)
{
    if (!Account_IsLoggedIn(playerid))
    {
        return E_STAFF_LEVEL_NONE;
    }

    return Account_GetAdminLevel(playerid);
}

stock Staff_GetGroup(playerid)
{
    if (Staff_GetLevel(playerid) == E_STAFF_LEVEL_NONE)
    {
        return E_STAFF_GROUP_NONE;
    }

    return Account_GetStaffGroup(playerid);
}

stock bool:Staff_IsStaff(playerid)
{
    return Staff_GetLevel(playerid) != E_STAFF_LEVEL_NONE;
}

stock bool:Staff_IsSupporter(playerid)
{
    return Staff_GetLevel(playerid) >= E_STAFF_LEVEL_SUPPORTER;
}

stock bool:Staff_IsModerator(playerid)
{
    return Staff_GetLevel(playerid) >= E_STAFF_LEVEL_MODERATOR;
}

stock bool:Staff_IsManager(playerid)
{
    return Staff_GetLevel(playerid) >= E_STAFF_LEVEL_MANAGER;
}

stock bool:Staff_IsDeveloper(playerid)
{
    return Staff_GetLevel(playerid) >= E_STAFF_LEVEL_DEVELOPER;
}

stock Staff_GetRankName(level,dest[],size = sizeof(dest))
{
    Account_GetStaffRankName(level,dest,size);
}

stock Staff_GetGroupName(group,dest[],size = sizeof(dest))
{
    Account_GetStaffGroupName(group,dest,size);
}

stock bool:Staff_IsValidTarget(targetid)
{
    return targetid >= 0 && targetid < MAX_PLAYERS && IsPlayerConnected(targetid) && !IsPlayerNPC(targetid) && Account_IsLoggedIn(targetid);
}

stock bool:Staff_WantsWarnings(playerid)
{
    return s_StaffWarnings[playerid] && !s_StaffMutedModerator[playerid];
}

stock Staff_SetWarnings(playerid,bool:enabled)
{
    s_StaffWarnings[playerid] = enabled;
}

stock bool:Staff_HasWarnings(playerid)
{
    return s_StaffWarnings[playerid];
}

stock bool:Staff_IsModeratorChatMuted(playerid)
{
    return s_StaffMutedModerator[playerid];
}

stock Staff_SetModeratorChatMuted(playerid,bool:muted)
{
    s_StaffMutedModerator[playerid] = muted;
}

stock bool:Staff_IsSupporterChatMuted(playerid)
{
    return s_StaffMutedSupporter[playerid];
}

stock Staff_SetSupporterChatMuted(playerid,bool:muted)
{
    s_StaffMutedSupporter[playerid] = muted;
}

stock bool:Staff_IsOnDuty(playerid)
{
    return s_StaffOnDuty[playerid];
}

stock Staff_SetOnDuty(playerid,bool:onDuty)
{
    s_StaffOnDuty[playerid] = onDuty;
}

stock Staff_GetConvo(playerid)
{
    return s_StaffConvo[playerid];
}

stock Staff_SetConvo(playerid,host)
{
    s_StaffConvo[playerid] = host;
}

stock bool:Staff_HasReport(playerid)
{
    return s_StaffReportPending[playerid];
}

stock Staff_SetReport(playerid,targetid,const reason[])
{
    s_StaffReportPending[playerid] = true;
    s_StaffReportTarget[playerid] = targetid;
    GetPlayerName(targetid,s_StaffReportTargetName[playerid],ACCOUNT_NAME_LEN);
    strcopy(s_StaffReportReason[playerid],reason,STAFF_REASON_LEN);
    s_StaffReportCooldown[playerid] = gettime() + STAFF_REPORT_COOLDOWN;
    s_StaffReportTime[playerid] = gettime();
}

stock Staff_ClearReport(playerid)
{
    s_StaffReportPending[playerid] = false;
    s_StaffReportTarget[playerid] = INVALID_PLAYER_ID;
    s_StaffReportTargetName[playerid][0] = EOS;
    s_StaffReportReason[playerid][0] = EOS;
}

stock Staff_GetReportReason(playerid,dest[],size = sizeof(dest))
{
    strcopy(dest,s_StaffReportReason[playerid],size);
}

stock Staff_GetReportTargetName(playerid,dest[],size = sizeof(dest))
{
    strcopy(dest,s_StaffReportTargetName[playerid],size);
}

stock Staff_GetReportTarget(playerid)
{
    return s_StaffReportTarget[playerid];
}

stock Staff_GetReportAge(playerid)
{
    return gettime() - s_StaffReportTime[playerid];
}

stock Staff_GetReportCooldown(playerid)
{
    return s_StaffReportCooldown[playerid];
}

stock Staff_ResetPlayer(playerid)
{
    s_StaffWarnings[playerid] = false;
    s_StaffMutedModerator[playerid] = false;
    s_StaffMutedSupporter[playerid] = false;
    s_StaffOnDuty[playerid] = false;
    s_StaffConvo[playerid] = STAFF_CONVO_NONE;
    s_StaffReportCooldown[playerid] = 0;
    s_StaffReportTime[playerid] = 0;
    Staff_ClearReport(playerid);
}

stock Staff_FormatDuration(seconds,dest[],size = sizeof(dest))
{
    if (seconds < 0)
    {
        strcopy(dest,"Never ago",size);
        return;
    }

    if (seconds < 60)
    {
        format(dest,size,"%d seconds ago",seconds);
    }
    else if (seconds < 3600)
    {
        format(dest,size,seconds >= 120 ? ("%d minutes ago") : ("%d minute ago"),seconds / 60);
    }
    else if (seconds < 86400)
    {
        format(dest,size,seconds >= 7200 ? ("%d hours ago") : ("%d hour ago"),seconds / 3600);
    }
    else
    {
        format(dest,size,seconds >= 172800 ? ("%d days ago") : ("%d day ago"),seconds / 86400);
    }
}

stock Staff_FormatDateTime(dest[],size = sizeof(dest))
{
    new year, month, day, hour, minute, second;
    getdate(year,month,day);
    gettime(hour,minute,second);
    format(dest,size,"%02d/%02d/%d - %02d:%02d:%02d",day,month,year,hour,minute,second);
}

static bool:Staff_Refuse(playerid,const text[])
{
    SendServerMessage(playerid,text,MSG_TYPE_ERROR);
    return false;
}

stock bool:Staff_RequireModerator(playerid,group = E_STAFF_GROUP_NONE)
{
    if (!Staff_IsModerator(playerid))
    {
        return Staff_Refuse(playerid,"You need to be a moderator in order to be able to do this!");
    }

    if (group <= E_STAFF_GROUP_NONE || Staff_GetGroup(playerid) >= group)
    {
        return true;
    }

    switch (group)
    {
        case E_STAFF_GROUP_TRIAL:
        {
            return Staff_Refuse(playerid,"You must be at least a trial moderator in order to do this.");
        }
        case E_STAFF_GROUP_BASIC:
        {
            return Staff_Refuse(playerid,"You must be at least a basic moderator in order to do this.");
        }
        case E_STAFF_GROUP_GENERAL:
        {
            return Staff_Refuse(playerid,"You must be at least a general moderator in order to do this.");
        }
    }

    return Staff_Refuse(playerid,"You must be at least an advanced moderator in order to do this.");
}

stock bool:Staff_RequireManager(playerid)
{
    if (!Staff_IsManager(playerid))
    {
        return Staff_Refuse(playerid,"You need to be a manager in order to be able to do this!");
    }

    return true;
}

stock bool:Staff_RequireTarget(playerid,targetid,const text[])
{
    if (!Staff_IsValidTarget(targetid))
    {
        return Staff_Refuse(playerid,text);
    }

    return true;
}

stock Staff_Log(const tag[],const text[])
{
    Log_Info(tag,"%s",text);
}

stock Staff_SendSupporterWarning(const text[])
{
    foreach (new i : Player)
    {
        if (Staff_IsSupporter(i) && !s_StaffMutedSupporter[i])
        {
            SendClientMessage(i,SUPPORTER_COLOR,text);
        }
    }
}
