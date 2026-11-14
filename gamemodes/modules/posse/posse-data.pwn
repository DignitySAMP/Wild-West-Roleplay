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
#define POSSE_NAME_LEN (36)
#define POSSE_RANK_LEN (36)
#define POSSE_NONE (-1)
#define POSSE_DEFAULT_NAME ("Law Enforcement")
#define POSSE_DEFAULT_SLOTS (6)
#define POSSE_BANK_RANGE (3.5)
#define POSSE_TIER_MEMBER (1)
#define POSSE_TIER_COMMAND (2)
#define POSSE_TIER_LEADER (3)
#define POSSE_NAME_MIN (4)
#define LAW_INCOME (725)

enum _:E_POSSE_KIND
{
    POSSE_TYPE_OUTLAW = 0,
    POSSE_TYPE_LAW,
    POSSE_TYPE_GOVERNMENT,
    POSSE_TYPE_GANG,
}

enum e_POSSE
{
    E_POSSE_TYPE,
    E_POSSE_NAME[POSSE_NAME_LEN],
    E_POSSE_SLOTS,
    E_POSSE_COLOR,
    Float:E_POSSE_SPAWN_X,
    Float:E_POSSE_SPAWN_Y,
    Float:E_POSSE_SPAWN_Z,
    E_POSSE_SPAWN_INT,
    E_POSSE_SPAWN_VW,
    E_POSSE_BANK,
    bool:E_POSSE_CHAT,
}

static Map:s_Posses;
static s_PossePlayer[MAX_PLAYERS] = {POSSE_NONE,...};
static s_PosseTier[MAX_PLAYERS];
static s_PosseRank[MAX_PLAYERS][POSSE_RANK_LEN];
static bool:s_PosseLoaded[MAX_PLAYERS];

forward Posse_Load();
forward Posse_OnMemberLoaded(playerid,token);
forward Posse_OnMemberChanged(playerid);
forward Posse_OnDeleted(posseid);
forward Task:Posse_Create(const name[],type,slots);
forward Task:Posse_Reload();

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
stock Posse_Count()
{
    return map_valid(s_Posses) ? map_size(s_Posses) : 0;
}

stock bool:Posse_Exists(posseid)
{
    return posseid > 0 && map_valid(s_Posses) && map_has_key(s_Posses,posseid);
}

stock bool:Posse_Get(posseid,posse[e_POSSE])
{
    if (!Posse_Exists(posseid))
    {
        return false;
    }

    map_get_arr(s_Posses,posseid,posse);
    return true;
}

stock Posse_Commit(posseid,const posse[e_POSSE])
{
    map_set_arr(s_Posses,posseid,posse);
}

stock Iter:Posse_Iterator()
{
    return map_iter(s_Posses);
}

stock bool:Posse_IsLawPosse(posseid)
{
    new posse[e_POSSE];
    return Posse_Get(posseid,posse) && (posse[E_POSSE_TYPE] == POSSE_TYPE_LAW || posse[E_POSSE_TYPE] == POSSE_TYPE_GOVERNMENT);
}

stock Posse_GetPlayer(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return POSSE_NONE;
    }

    return Posse_Exists(s_PossePlayer[playerid]) ? s_PossePlayer[playerid] : POSSE_NONE;
}

stock bool:Posse_IsMember(playerid)
{
    return Posse_GetPlayer(playerid) != POSSE_NONE;
}

stock bool:Posse_IsLawMember(playerid)
{
    return Posse_IsLawPosse(Posse_GetPlayer(playerid));
}

stock Posse_GetTier(playerid)
{
    return Posse_IsMember(playerid) ? s_PosseTier[playerid] : 0;
}

stock Posse_GetRank(playerid,dest[],size = sizeof(dest))
{
    strcopy(dest,s_PosseRank[playerid],size);
}

stock bool:Posse_IsLoaded(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_PosseLoaded[playerid];
}

stock Posse_GetTierName(tier,dest[],size = sizeof(dest))
{
    switch (tier)
    {
        case 0:
        {
            strcopy(dest,"None",size);
        }
        case 1:
        {
            strcopy(dest,"Member",size);
        }
        case 2:
        {
            strcopy(dest,"Command",size);
        }
        case 3:
        {
            strcopy(dest,"Leader",size);
        }
        default:
        {
            strcopy(dest,"N/A",size);
        }
    }
}

stock Posse_GetName(posseid,dest[],size = sizeof(dest))
{
    new posse[e_POSSE];

    if (!Posse_Get(posseid,posse))
    {
        strcopy(dest,"None",size);
        return;
    }

    strcopy(dest,posse[E_POSSE_NAME],size);
}

stock Posse_GetOnlineCount(posseid)
{
    new count = 0;

    foreach (new i : Player)
    {
        if (Posse_GetPlayer(i) == posseid)
        {
            count++;
        }
    }

    return count;
}

stock Posse_DisplayName(playerid,bool:plain,dest[],size = sizeof(dest))
{
    if (plain)
    {
        GetPlayerName(playerid,dest,size);
    }
    else
    {
        Account_GetRoleplayName(playerid,dest,size);
    }
}

static Posse_Colour(type,bool:dark)
{
    switch (type)
    {
        case POSSE_TYPE_LAW:
        {
            return dark ? 0x6B9665FF : 0x6DB863FF;
        }
        case POSSE_TYPE_GOVERNMENT:
        {
            return dark ? 0x27657AFF : 0x5391A6FF;
        }
        case POSSE_TYPE_GANG:
        {
            return dark ? 0x8C5050FF : 0xB86363FF;
        }
    }

    return dark ? 0xD69045FF : 0xE3AD74FF;
}

stock Posse_Warning(posseid,const text[])
{
    new posse[e_POSSE];

    if (!Posse_Get(posseid,posse))
    {
        return;
    }

    foreach (new i : Player)
    {
        if (Posse_GetPlayer(i) == posseid)
        {
            SendClientMessage(i,Posse_Colour(posse[E_POSSE_TYPE],true),text);
        }
    }
}

stock Posse_Message(posseid,const text[])
{
    new posse[e_POSSE];

    if (!Posse_Get(posseid,posse))
    {
        return;
    }

    foreach (new i : Player)
    {
        if (Posse_GetPlayer(i) == posseid)
        {
            SendSplitMessage(i,Posse_Colour(posse[E_POSSE_TYPE],false),text);
        }
    }
}

stock Posse_SaveBank(posseid)
{
    new posse[e_POSSE];

    if (!Posse_Get(posseid,posse))
    {
        return;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE posses SET posse_bank = %d, posse_bank_decimal = %d WHERE posse_id = %d",Money_Dollars(posse[E_POSSE_BANK]),Money_Cents(posse[E_POSSE_BANK]),posseid));
}

stock bool:Posse_BankGive(posseid,cents)
{
    new posse[e_POSSE];

    if (cents <= 0 || !Posse_Get(posseid,posse))
    {
        return false;
    }

    posse[E_POSSE_BANK] += cents;
    Posse_Commit(posseid,posse);
    Posse_SaveBank(posseid);
    return true;
}

stock bool:Posse_BankTake(posseid,cents)
{
    new posse[e_POSSE];

    if (cents <= 0 || !Posse_Get(posseid,posse) || posse[E_POSSE_BANK] < cents)
    {
        return false;
    }

    posse[E_POSSE_BANK] -= cents;
    Posse_Commit(posseid,posse);
    Posse_SaveBank(posseid);
    return true;
}

stock Posse_SaveMember(playerid)
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_posse = %d, character_possetier = %d, character_posserank = '%e' WHERE character_id = %d",s_PossePlayer[playerid],s_PosseTier[playerid],s_PosseRank[playerid],Character_GetId(playerid)));
}

stock Posse_SetMember(playerid,posseid,tier,const rank[])
{
    s_PossePlayer[playerid] = posseid;
    s_PosseTier[playerid] = tier;
    strcopy(s_PosseRank[playerid],rank,POSSE_RANK_LEN);
    Posse_SaveMember(playerid);
    pawn_call_public("Posse_OnMemberChanged","d",playerid);
}

stock Posse_SetTier(playerid,tier)
{
    s_PosseTier[playerid] = tier;
    Posse_SaveMember(playerid);
    pawn_call_public("Posse_OnMemberChanged","d",playerid);
}

stock Posse_SetRank(playerid,const rank[])
{
    strcopy(s_PosseRank[playerid],rank,POSSE_RANK_LEN);
    Posse_SaveMember(playerid);
}

stock bool:Posse_ChatEnabled(posseid)
{
    new posse[e_POSSE];
    return Posse_Get(posseid,posse) && posse[E_POSSE_CHAT];
}

stock bool:Posse_ToggleChat(posseid)
{
    new posse[e_POSSE];

    if (!Posse_Get(posseid,posse))
    {
        return false;
    }

    posse[E_POSSE_CHAT] = !posse[E_POSSE_CHAT];
    Posse_Commit(posseid,posse);
    return posse[E_POSSE_CHAT];
}

static Posse_Read(row,posse[e_POSSE])
{
    cache_get_value_name_int(row,"posse_type",posse[E_POSSE_TYPE]);
    cache_get_value_name(row,"posse_name",posse[E_POSSE_NAME],POSSE_NAME_LEN);
    cache_get_value_name_int(row,"posse_slots",posse[E_POSSE_SLOTS]);
    cache_get_value_name_int(row,"posse_color",posse[E_POSSE_COLOR]);
    cache_get_value_name_float(row,"posse_spawn_x",posse[E_POSSE_SPAWN_X]);
    cache_get_value_name_float(row,"posse_spawn_y",posse[E_POSSE_SPAWN_Y]);
    cache_get_value_name_float(row,"posse_spawn_z",posse[E_POSSE_SPAWN_Z]);
    cache_get_value_name_int(row,"posse_spawn_int",posse[E_POSSE_SPAWN_INT]);
    cache_get_value_name_int(row,"posse_spawn_vw",posse[E_POSSE_SPAWN_VW]);
    new dollars, cents;
    cache_get_value_name_int(row,"posse_bank",dollars);
    cache_get_value_name_int(row,"posse_bank_decimal",cents);
    posse[E_POSSE_BANK] = Money_Make(dollars,cents);
}

#pragma warning push
#pragma warning disable 204
async Task:Posse_Create(const name[],type,slots)
{
    await mysql_aquery_s(g_Mysql,str_format("INSERT INTO posses (posse_name, posse_type, posse_slots, posse_color) VALUES ('%e', %d, %d, -1)",name,type,slots),false);
    new posseid = cache_insert_id();

    if (posseid <= 0)
    {
        return async 0;
    }

    await mysql_aquery_s(g_Mysql,str_format("SELECT posse_type, posse_name, posse_slots, posse_color, posse_spawn_x, posse_spawn_y, posse_spawn_z, posse_spawn_int, posse_spawn_vw, posse_bank, posse_bank_decimal FROM posses WHERE posse_id = %d",posseid),false);

    if (cache_num_rows() > 0)
    {
        new posse[e_POSSE];
        Posse_Read(0,posse);
        Posse_Commit(posseid,posse);
    }

    return async posseid;
}

async Task:Posse_Reload()
{
    await mysql_aquery_s(g_Mysql,str_new("SELECT posse_id, posse_type, posse_name, posse_slots, posse_color, posse_spawn_x, posse_spawn_y, posse_spawn_z, posse_spawn_int, posse_spawn_vw, posse_bank, posse_bank_decimal FROM posses"),false);

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, posse[e_POSSE], old[e_POSSE];
        cache_get_value_name_int(i,"posse_id",id);

        if (id < 1)
        {
            continue;
        }

        new bool:chat = Posse_Get(id,old) && old[E_POSSE_CHAT];
        Posse_Read(i,posse);
        posse[E_POSSE_CHAT] = chat;
        Posse_Commit(id,posse);
    }

    return async Posse_Count();
}
#pragma warning pop

stock Posse_Delete(posseid)
{
    if (!Posse_Exists(posseid))
    {
        return;
    }

    foreach (new i : Player)
    {
        if (s_PossePlayer[i] == posseid)
        {
            s_PossePlayer[i] = POSSE_NONE;
            s_PosseTier[i] = 0;
            strcopy(s_PosseRank[i],"None",POSSE_RANK_LEN);
            pawn_call_public("Posse_OnMemberChanged","d",i);
        }
    }

    map_remove(s_Posses,posseid);
    mysql_tquery_s(g_Mysql,str_format("DELETE FROM posses WHERE posse_id = %d",posseid));
    mysql_tquery_s(g_Mysql,str_format("DELETE FROM possekiosk WHERE kiosk_id = %d",posseid));
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_posse = -1, character_possetier = 0, character_posserank = 'None' WHERE character_posse = %d",posseid));
    pawn_call_public("Posse_OnDeleted","d",posseid);
}

stock Posse_FirstOfType(type)
{
    if (!map_valid(s_Posses))
    {
        return 0;
    }

    for (new Iter:it = map_iter(s_Posses);iter_inside(it);iter_move_next(it))
    {
        new posse[e_POSSE];
        iter_get_arr(it,posse);

        if (posse[E_POSSE_TYPE] == type)
        {
            return iter_get_key(it);
        }
    }

    return 0;
}

public Posse_Load()
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_new("SELECT posse_id, posse_type, posse_name, posse_slots, posse_color, posse_spawn_x, posse_spawn_y, posse_spawn_z, posse_spawn_int, posse_spawn_vw, posse_bank, posse_bank_decimal FROM posses"),false);

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, posse[e_POSSE];
        cache_get_value_name_int(i,"posse_id",id);

        if (id < 1 || Posse_Exists(id))
        {
            continue;
        }

        Posse_Read(i,posse);
        Posse_Commit(id,posse);
    }

    if (Posse_Count() == 0)
    {
        await Posse_Create(POSSE_DEFAULT_NAME,POSSE_TYPE_LAW,POSSE_DEFAULT_SLOTS);
    }

    Log_Info("posse","Loaded %d posses",Posse_Count());
    Boot_LoaderDone();
    return 1;
}

public Posse_OnMemberLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    s_PossePlayer[playerid] = POSSE_NONE;
    s_PosseTier[playerid] = 0;
    strcopy(s_PosseRank[playerid],"None",POSSE_RANK_LEN);

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_posse",s_PossePlayer[playerid]);
        cache_get_value_name_int(0,"character_possetier",s_PosseTier[playerid]);
        cache_get_value_name(0,"character_posserank",s_PosseRank[playerid],POSSE_RANK_LEN);
    }

    s_PosseLoaded[playerid] = true;
    pawn_call_public("Posse_OnMemberChanged","d",playerid);
    return 1;
}

public Posse_OnMemberChanged(playerid)
{
    return 1;
}

public Posse_OnDeleted(posseid)
{
    return 1;
}

stock Posse_InitPool()
{
    s_Posses = map_new();
}

stock Posse_ResetPlayer(playerid)
{
    s_PossePlayer[playerid] = POSSE_NONE;
    s_PosseTier[playerid] = 0;
    strcopy(s_PosseRank[playerid],"None",POSSE_RANK_LEN);
    s_PosseLoaded[playerid] = false;
}
