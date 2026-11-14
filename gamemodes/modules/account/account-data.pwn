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
#define ACCOUNT_PASSWORD_MIN (4)
#define ACCOUNT_PASSWORD_MAX (65)
#define ACCOUNT_BCRYPT_COST (12)
#define ACCOUNT_MAX_TRIES (3)
#define ACCOUNT_TRIES_WINDOW (600)
#define ACCOUNT_KICK_DELAY_MS (600)
#define ACCOUNT_NAME_LEN (MAX_PLAYER_NAME + 1)
#define ACCOUNT_NOTE_LEN (256)
#define ACCOUNT_KEY_LEN (48)
#define CHARACTER_SLOTS (3)
#define CHARACTER_AGE_MIN (8)
#define CHARACTER_AGE_MAX (80)
#define ACCOUNT_TITLE "{6B5538}Welcome to Wild West Roleplay{DEDEDE}"
#define ACCOUNT_CURSOR_COLOUR (0xA3A3A3FF)
#define ACCOUNT_CHARACTER_COLOUR (0xCFCFCFFF)
#define ACCOUNT_IDLE_COLOUR (0x000000FF)
#define ACCOUNT_CONFIRM_SOUND (1085)

enum _:E_ACCOUNT_STAGE
{
    E_ACCOUNT_STAGE_CONNECTING = 0,
    E_ACCOUNT_STAGE_LOGIN,
    E_ACCOUNT_STAGE_QUIZ,
    E_ACCOUNT_STAGE_SELECT,
    E_ACCOUNT_STAGE_CREATE,
    E_ACCOUNT_STAGE_LOADING,
    E_ACCOUNT_STAGE_PLAYING,
}

enum e_ACCOUNT_DATA
{
    E_ACCOUNT_ID,
    E_ACCOUNT_NAME[ACCOUNT_NAME_LEN],
    E_ACCOUNT_REGISTERQUIZ,
    E_ACCOUNT_TUTORIAL,
    E_ACCOUNT_RULECHECK,
    E_ACCOUNT_DONATOR_LEVEL,
    E_ACCOUNT_DONATOR_EXPIRE,
    E_ACCOUNT_STAFF_LEVEL,
    E_ACCOUNT_STAFF_GROUP,
    E_ACCOUNT_STAFF_NAME[ACCOUNT_NAME_LEN],
    E_ACCOUNT_SUPPORT_QUESTIONS,
    E_ACCOUNT_NAME_CHANGES,
    E_ACCOUNT_CREATION[36],
    E_ACCOUNT_LAST_LOGIN,
    E_ACCOUNT_NOTE[ACCOUNT_NOTE_LEN],
}

enum e_CHARACTER_DATA
{
    E_CHARACTER_ID,
    E_CHARACTER_ACCOUNT,
    E_CHARACTER_NAME[ACCOUNT_NAME_LEN],
    E_CHARACTER_GENDER,
    E_CHARACTER_ORIGIN,
    E_CHARACTER_TOWN,
    E_CHARACTER_SKIN,
    E_CHARACTER_AGE,
    E_CHARACTER_LEVEL,
    E_CHARACTER_HOURS,
    E_CHARACTER_EXPLEFT,
    E_CHARACTER_SPAWNPOINT,
    Float:E_CHARACTER_POS_X,
    Float:E_CHARACTER_POS_Y,
    Float:E_CHARACTER_POS_Z,
    E_CHARACTER_POS_INTERIOR,
    E_CHARACTER_POS_WORLD,
    E_CHARACTER_CRASHED,
    E_CHARACTER_POSSE,
}

enum _:E_PLAYER_BUSY
{
    E_PLAYER_BUSY_JAIL = 1,
    E_PLAYER_BUSY_DEAD = 2,
    E_PLAYER_BUSY_HORSE = 4,
    E_PLAYER_BUSY_TACKLED = 8,
    E_PLAYER_BUSY_POKER = 16,
    E_PLAYER_BUSY_SWITCH = 32,
    E_PLAYER_BUSY_PRISON = 64,
    E_PLAYER_BUSY_TRAPPED = 128,
    E_PLAYER_BUSY_LASSOED = 256,
}

new g_Account[MAX_PLAYERS][e_ACCOUNT_DATA];
new g_Character[MAX_PLAYERS][e_CHARACTER_DATA];
new g_CharacterSlots[MAX_PLAYERS][CHARACTER_SLOTS][e_CHARACTER_DATA];
new g_AccountStage[MAX_PLAYERS];
new g_AccountToken[MAX_PLAYERS];
new g_AccountNextToken;
new bool:g_AccountLogged[MAX_PLAYERS];
new bool:g_AccountExists[MAX_PLAYERS];
new bool:g_AccountLogoutPermission[MAX_PLAYERS];
new bool:g_AccountLoading[MAX_PLAYERS];
new bool:g_AccountNewCharacter[MAX_PLAYERS];
new g_AccountHash[MAX_PLAYERS][BCRYPT_HASH_LENGTH];
new g_AccountPendingPassword[MAX_PLAYERS][ACCOUNT_PASSWORD_MAX + 1];
new g_AccountNameChangeKind[MAX_PLAYERS];
new g_AccountNameChangeName[MAX_PLAYERS][ACCOUNT_NAME_LEN];
new g_AccountBusy[MAX_PLAYERS];
new bool:g_AccountHasOverride[MAX_PLAYERS];
new Float:g_AccountOverrideX[MAX_PLAYERS];
new Float:g_AccountOverrideY[MAX_PLAYERS];
new Float:g_AccountOverrideZ[MAX_PLAYERS];

static Map:s_AttemptCount;
static Map:s_AttemptTime;

forward bool:Player_IsReady(playerid);
forward Account_GetAdminLevel(playerid);
forward Account_OnLogout(playerid,accountid);
forward Character_OnLoad(playerid,characterid);
forward Character_OnLeaving(playerid,characterid);
forward Character_OnUnload(playerid,characterid);
forward Character_OnCreated(playerid,characterid);
forward Character_OnSavePosition(playerid);
forward Player_OnReady(playerid);
forward Account_OnStatistics(playerid,targetid);
forward Account_OnCharactersLoaded(playerid);

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
stock bool:Player_IsReady(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && IsPlayerConnected(playerid) && g_AccountStage[playerid] == E_ACCOUNT_STAGE_PLAYING;
}

stock bool:Account_IsLoggedIn(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && IsPlayerConnected(playerid) && g_AccountLogged[playerid];
}

stock Account_GetId(playerid)
{
    return g_Account[playerid][E_ACCOUNT_ID];
}

stock Account_GetName(playerid,dest[],size = sizeof(dest))
{
    strcopy(dest,g_Account[playerid][E_ACCOUNT_NAME],size);
}

stock Account_GetAdminLevel(playerid)
{
    return IsPlayerConnected(playerid) ? g_Account[playerid][E_ACCOUNT_STAFF_LEVEL] : 0;
}

stock Account_GetStaffGroup(playerid)
{
    return g_Account[playerid][E_ACCOUNT_STAFF_GROUP];
}

stock Account_GetDonatorLevel(playerid)
{
    return g_Account[playerid][E_ACCOUNT_DONATOR_LEVEL];
}

stock Account_SetStaffLevel(playerid,level)
{
    g_Account[playerid][E_ACCOUNT_STAFF_LEVEL] = level;
}

stock Account_SetStaffGroup(playerid,group)
{
    g_Account[playerid][E_ACCOUNT_STAFF_GROUP] = group;
}

stock Account_GetStaffName(playerid,dest[],size = sizeof(dest))
{
    strcopy(dest,g_Account[playerid][E_ACCOUNT_STAFF_NAME],size);
}

stock Account_SetStaffName(playerid,const name[])
{
    strcopy(g_Account[playerid][E_ACCOUNT_STAFF_NAME],name,ACCOUNT_NAME_LEN);
}

stock Account_SetNote(playerid,const note[])
{
    strcopy(g_Account[playerid][E_ACCOUNT_NOTE],note,ACCOUNT_NOTE_LEN);
}

stock Account_GetRuleCheck(playerid)
{
    return g_Account[playerid][E_ACCOUNT_RULECHECK];
}

stock Account_SetNameChanges(playerid,count)
{
    g_Account[playerid][E_ACCOUNT_NAME_CHANGES] = count;
}

stock Account_SetName(playerid,const name[])
{
    strcopy(g_Account[playerid][E_ACCOUNT_NAME],name,ACCOUNT_NAME_LEN);
}

stock Account_SetDonator(playerid,level,expire)
{
    g_Account[playerid][E_ACCOUNT_DONATOR_LEVEL] = level;
    g_Account[playerid][E_ACCOUNT_DONATOR_EXPIRE] = expire;
}

stock Character_SetLevelCached(playerid,level)
{
    g_Character[playerid][E_CHARACTER_LEVEL] = level;
}

stock Character_SetExperienceLeftCached(playerid,left)
{
    g_Character[playerid][E_CHARACTER_EXPLEFT] = left;
}

stock Character_SetHoursCached(playerid,hours)
{
    g_Character[playerid][E_CHARACTER_HOURS] = hours;
}

stock Account_SetRuleCheck(playerid,value)
{
    g_Account[playerid][E_ACCOUNT_RULECHECK] = value;
}

stock Character_SetNameCached(playerid,const name[])
{
    strcopy(g_Character[playerid][E_CHARACTER_NAME],name,ACCOUNT_NAME_LEN);
}

stock Account_GetNote(playerid,dest[],size = sizeof(dest))
{
    strcopy(dest,g_Account[playerid][E_ACCOUNT_NOTE],size);
}

stock Account_GetSupportQuestions(playerid)
{
    return g_Account[playerid][E_ACCOUNT_SUPPORT_QUESTIONS];
}

stock Account_SetSupportQuestions(playerid,count)
{
    g_Account[playerid][E_ACCOUNT_SUPPORT_QUESTIONS] = count;
}

stock Character_SetSkinCached(playerid,skin)
{
    g_Character[playerid][E_CHARACTER_SKIN] = skin;
}

stock Character_SetOriginCached(playerid,origin)
{
    g_Character[playerid][E_CHARACTER_ORIGIN] = origin;
}

stock Character_SetGenderCached(playerid,gender)
{
    g_Character[playerid][E_CHARACTER_GENDER] = gender;
}

stock Character_SetTownCached(playerid,town)
{
    g_Character[playerid][E_CHARACTER_TOWN] = town;
}

stock Account_GetDonatorExpire(playerid)
{
    return g_Account[playerid][E_ACCOUNT_DONATOR_EXPIRE];
}

stock Account_GetTutorial(playerid)
{
    return g_Account[playerid][E_ACCOUNT_TUTORIAL];
}

stock Account_SetTutorial(playerid,value)
{
    g_Account[playerid][E_ACCOUNT_TUTORIAL] = value;
    mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_tutorial = %d WHERE account_id = %d",value,g_Account[playerid][E_ACCOUNT_ID]));
}

stock Account_GetNameChanges(playerid)
{
    return g_Account[playerid][E_ACCOUNT_NAME_CHANGES];
}

stock Account_GetNameChangeRequest(playerid)
{
    return g_AccountNameChangeKind[playerid];
}

stock Account_GetNameChangeName(playerid,dest[],size = sizeof(dest))
{
    strcopy(dest,g_AccountNameChangeName[playerid],size);
}

stock Account_ClearNameChangeRequest(playerid)
{
    g_AccountNameChangeKind[playerid] = 0;
    g_AccountNameChangeName[playerid][0] = EOS;
}

stock Account_SetLogoutPermission(playerid,bool:allowed)
{
    g_AccountLogoutPermission[playerid] = allowed;
}

stock bool:Account_HasLogoutPermission(playerid)
{
    return g_AccountLogoutPermission[playerid];
}

stock Character_GetId(playerid)
{
    return g_Character[playerid][E_CHARACTER_ID];
}

stock Character_GetName(playerid,dest[],size = sizeof(dest))
{
    strcopy(dest,g_Character[playerid][E_CHARACTER_NAME],size);
}

stock Character_GetGender(playerid)
{
    return g_Character[playerid][E_CHARACTER_GENDER];
}

stock Character_GetOrigin(playerid)
{
    return g_Character[playerid][E_CHARACTER_ORIGIN];
}

stock Character_GetTown(playerid)
{
    return g_Character[playerid][E_CHARACTER_TOWN];
}

stock Character_GetSkin(playerid)
{
    return g_Character[playerid][E_CHARACTER_SKIN];
}

stock Character_GetAge(playerid)
{
    return g_Character[playerid][E_CHARACTER_AGE];
}

stock Character_GetLevel(playerid)
{
    return g_Character[playerid][E_CHARACTER_LEVEL];
}

stock Character_GetHours(playerid)
{
    return g_Character[playerid][E_CHARACTER_HOURS];
}

stock Character_GetExperienceLeft(playerid)
{
    return g_Character[playerid][E_CHARACTER_EXPLEFT];
}

stock Character_GetSpawnChoice(playerid)
{
    return g_Character[playerid][E_CHARACTER_SPAWNPOINT];
}

stock Character_GetCrashed(playerid)
{
    return g_Character[playerid][E_CHARACTER_CRASHED];
}

stock Character_GetLastPosition(playerid,&Float:x,&Float:y,&Float:z,&interior,&world)
{
    x = g_Character[playerid][E_CHARACTER_POS_X];
    y = g_Character[playerid][E_CHARACTER_POS_Y];
    z = g_Character[playerid][E_CHARACTER_POS_Z];
    interior = g_Character[playerid][E_CHARACTER_POS_INTERIOR];
    world = g_Character[playerid][E_CHARACTER_POS_WORLD];
}

stock Character_SetSpawnChoiceCached(playerid,choice)
{
    g_Character[playerid][E_CHARACTER_SPAWNPOINT] = choice;
}

stock Character_ClearCrashedCached(playerid)
{
    g_Character[playerid][E_CHARACTER_CRASHED] = 0;
}

stock Character_SetAgeCached(playerid,age)
{
    g_Character[playerid][E_CHARACTER_AGE] = age;
}

stock Character_SetSaveOverride(playerid,Float:x,Float:y,Float:z)
{
    g_AccountHasOverride[playerid] = true;
    g_AccountOverrideX[playerid] = x;
    g_AccountOverrideY[playerid] = y;
    g_AccountOverrideZ[playerid] = z;
}

stock Player_SetBusy(playerid,flag,bool:set)
{
    if (set)
    {
        g_AccountBusy[playerid] |= flag;
        return;
    }

    g_AccountBusy[playerid] &= ~flag;
}

stock bool:Player_IsBusyWith(playerid,flag)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && (g_AccountBusy[playerid] & flag) != 0;
}

stock bool:Player_IsFree(playerid)
{
    return g_AccountBusy[playerid] == 0;
}

stock bool:Player_IsSpawned(playerid)
{
    new PLAYER_STATE:playerState = GetPlayerState(playerid);
    return playerState != PLAYER_STATE_NONE && playerState != PLAYER_STATE_WASTED && playerState != PLAYER_STATE_SPECTATING;
}

stock Account_GetRoleplayName(playerid,dest[],size = sizeof(dest))
{
    GetPlayerName(playerid,dest,size);

    for (new i = 0;dest[i] != EOS;i++)
    {
        if (dest[i] == '_')
        {
            dest[i] = ' ';
        }
    }
}

stock bool:Account_IsRoleplayName(const name[])
{
    new length = strlen(name), underscores = 0;

    if (length < 5 || length > MAX_PLAYER_NAME || name[0] < 'A' || name[0] > 'Z')
    {
        return false;
    }

    for (new i = 1;i < length;i++)
    {
        new letter = name[i];
        new bool:isUpper = letter >= 'A' && letter <= 'Z';
        new bool:isLower = letter >= 'a' && letter <= 'z';

        if (letter != '_' && !isUpper && !isLower)
        {
            return false;
        }

        if (isUpper && name[i - 1] != '_')
        {
            return false;
        }

        if (letter == '_')
        {
            underscores++;

            if (underscores > 1 || name[i + 1] < 'A' || name[i + 1] > 'Z')
            {
                return false;
            }
        }
    }

    return underscores == 1;
}

stock bool:Account_IsNumeric(const text[])
{
    if (text[0] == EOS)
    {
        return false;
    }

    for (new i = 0;text[i] != EOS;i++)
    {
        if (text[i] < '0' || text[i] > '9')
        {
            return false;
        }
    }

    return true;
}

stock Account_GetStaffRankName(level,dest[],size = sizeof(dest))
{
    switch (level)
    {
        case 0:
        {
            strcopy(dest,"None",size);
        }
        case 1:
        {
            strcopy(dest,"Supporter",size);
        }
        case 2:
        {
            strcopy(dest,"Moderator",size);
        }
        case 3:
        {
            strcopy(dest,"Management",size);
        }
        case 4:
        {
            strcopy(dest,"Developer",size);
        }
        default:
        {
            strcopy(dest,"N/A",size);
        }
    }
}

stock Account_GetStaffGroupName(group,dest[],size = sizeof(dest))
{
    switch (group)
    {
        case 0:
        {
            strcopy(dest,"None",size);
        }
        case 1:
        {
            strcopy(dest,"Trial Moderator",size);
        }
        case 2:
        {
            strcopy(dest,"Basic Moderator",size);
        }
        case 3:
        {
            strcopy(dest,"General Moderator",size);
        }
        case 4:
        {
            strcopy(dest,"Advanced Moderator",size);
        }
        default:
        {
            strcopy(dest,"N/A",size);
        }
    }
}

stock Account_GetDonatorRankName(level,dest[],size = sizeof(dest))
{
    switch (level)
    {
        case 1:
        {
            strcopy(dest,"Bronze",size);
        }
        case 2:
        {
            strcopy(dest,"Silver",size);
        }
        case 3:
        {
            strcopy(dest,"Gold",size);
        }
        default:
        {
            strcopy(dest,"None",size);
        }
    }
}

stock Account_ResetSlots(playerid)
{
    new empty[e_CHARACTER_DATA];

    for (new i = 0;i < CHARACTER_SLOTS;i++)
    {
        g_CharacterSlots[playerid][i] = empty;
    }
}

stock Account_ResetPlayer(playerid)
{
    new emptyAccount[e_ACCOUNT_DATA], emptyCharacter[e_CHARACTER_DATA];
    g_Account[playerid] = emptyAccount;
    g_Character[playerid] = emptyCharacter;
    Account_ResetSlots(playerid);
    g_AccountStage[playerid] = E_ACCOUNT_STAGE_CONNECTING;
    g_AccountLogged[playerid] = false;
    g_AccountExists[playerid] = false;
    g_AccountLogoutPermission[playerid] = false;
    g_AccountLoading[playerid] = false;
    g_AccountNewCharacter[playerid] = false;
    g_AccountHash[playerid][0] = EOS;
    g_AccountPendingPassword[playerid][0] = EOS;
    g_AccountNameChangeKind[playerid] = 0;
    g_AccountNameChangeName[playerid][0] = EOS;
    g_AccountBusy[playerid] = 0;
    g_AccountHasOverride[playerid] = false;
}

stock Account_NewToken(playerid)
{
    g_AccountToken[playerid] = ++g_AccountNextToken;
    return g_AccountToken[playerid];
}

stock bool:Account_IsCurrent(playerid,token)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && IsPlayerConnected(playerid) && token == g_AccountToken[playerid];
}

static Attempts_Key(playerid,key[ACCOUNT_KEY_LEN])
{
    new name[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));

    for (new i = 0;name[i] != EOS;i++)
    {
        name[i] = tolower(name[i]);
    }

    format(key,ACCOUNT_KEY_LEN,"%s@%s",name,Util_GetPlayerIp(playerid));
}

stock Attempts_Count(playerid)
{
    if (!map_valid(s_AttemptCount))
    {
        return 0;
    }

    new key[ACCOUNT_KEY_LEN];
    Attempts_Key(playerid,key);

    if (!map_has_str_key(s_AttemptCount,key))
    {
        return 0;
    }

    if (gettime() - map_str_get(s_AttemptTime,key) >= ACCOUNT_TRIES_WINDOW)
    {
        map_str_remove(s_AttemptCount,key);
        map_str_remove(s_AttemptTime,key);
        return 0;
    }

    return map_str_get(s_AttemptCount,key);
}

stock Attempts_Add(playerid)
{
    if (!map_valid(s_AttemptCount))
    {
        s_AttemptCount = map_new();
        s_AttemptTime = map_new();
    }

    new key[ACCOUNT_KEY_LEN], count = Attempts_Count(playerid) + 1;
    Attempts_Key(playerid,key);

    if (map_has_str_key(s_AttemptCount,key))
    {
        map_str_set(s_AttemptCount,key,count);
        map_str_set(s_AttemptTime,key,gettime());
    }
    else
    {
        map_str_add(s_AttemptCount,key,count);
        map_str_add(s_AttemptTime,key,gettime());
    }

    return count;
}

stock Attempts_Clear(playerid)
{
    if (!map_valid(s_AttemptCount))
    {
        return;
    }

    new key[ACCOUNT_KEY_LEN];
    Attempts_Key(playerid,key);
    map_str_remove(s_AttemptCount,key);
    map_str_remove(s_AttemptTime,key);
}

stock Account_GetToken(playerid)
{
    return g_AccountToken[playerid];
}

