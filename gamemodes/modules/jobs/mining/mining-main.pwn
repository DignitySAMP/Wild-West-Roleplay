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
#define ROCK_STATIC_COUNT (31)
#define ROCK_RANGE (1.5)
#define ROCK_RESPAWN_MS (900000)
#define ROCK_FORCE_RANGE (2.5)
#define ROCK_MODEL_NORMAL (3929)
#define ROCK_TYPES (6)
#define ROCK_DEPLETED_COLOUR (0xFF244E69)

enum e_ROCK
{
    E_ROCK_TYPE,
    Float:E_ROCK_HEALTH,
    Float:E_ROCK_X,
    Float:E_ROCK_Y,
    Float:E_ROCK_Z,
    E_ROCK_OBJECT,
    E_ROCK_LABEL,
    E_ROCK_DUE
}

new const Float:g_RockSpawns[ROCK_STATIC_COUNT][3] =
{
    {-1919.0676,2385.0813,37.9879},{-1921.4727,2390.2363,37.1292},
    {-1916.7816,2393.3623,37.5175},{-1923.3645,2398.4558,35.9735},
    {-1929.4668,2397.5891,34.5919},{-1931.9189,2390.7925,34.1004},
    {-1939.7615,2383.4299,33.4398},{-1939.6741,2375.3723,34.3163},
    {-1949.2689,2368.3499,35.1137},{-1953.0679,2374.0417,32.7691},
    {-1957.7441,2378.3176,29.8235},{-1957.7368,2382.8867,28.8019},
    {-1957.5074,2384.4944,28.4992},{-1956.9109,2383.7874,28.7518},
    {-1952.9615,2387.9285,28.5476},{-1949.9006,2397.6772,26.7426},
    {-1951.3562,2403.3091,26.7562},{-1948.4630,2406.5098,28.5602},
    {-1945.2501,2417.0088,29.4427},{-1940.0181,2423.4866,28.3450},
    {-1945.5753,2422.5134,28.0852},{-1943.0470,2430.4124,25.6596},
    {-1938.7642,2436.7166,24.4727},{-1943.8549,2440.7754,22.5172},
    {-1940.9633,2442.3499,22.9697},{-1942.7677,2442.0625,22.5864},
    {-1942.1423,2443.8933,22.3692},{-1945.5811,2443.8418,21.7797},
    {-1943.0664,2445.5781,21.7927},{-1943.9061,2443.1482,22.2151},
    {-1922.1138,2377.2327,38.2955}
};

new Map:g_Rocks;
new g_RockNext;
new g_RockDepleted;
new g_RockScattered;

forward Mining_OnMined(playerid,rockid,type);

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
stock Rock_Count()
{
    return map_valid(g_Rocks) ? map_size(g_Rocks) : 0;
}

stock bool:Rock_Get(id,rock[e_ROCK])
{
    if (!map_valid(g_Rocks) || !map_has_key(g_Rocks,id))
    {
        return false;
    }

    map_get_arr(g_Rocks,id,rock);
    return true;
}

stock Rock_Put(id,const rock[e_ROCK])
{
    map_set_arr(g_Rocks,id,rock);
}

stock Rock_TypeName(type,bool:coloured,dest[],size = sizeof(dest))
{
    switch (type)
    {
        case 0:
        {
            strcopy(dest,"Normal Rock",size);
        }
        case 1:
        {
            strcopy(dest,coloured ? ("{964B4B}Iron Mineral{FFFFFF}") : ("Iron Mineral"),size);
        }
        case 2:
        {
            strcopy(dest,coloured ? ("{FFB66C}Copper Mineral{FFFFFF}") : ("Copper Mineral"),size);
        }
        case 3:
        {
            strcopy(dest,coloured ? ("{C9C9C9}Tin Mineral{FFFFFF}") : ("Tin Mineral"),size);
        }
        case 4:
        {
            strcopy(dest,coloured ? ("{373737}Coal{FFFFFF}") : ("Coal"),size);
        }
        case 5:
        {
            strcopy(dest,coloured ? ("{E2B603}Gold Mineral{FFFFFF}") : ("Gold Mineral"),size);
        }
        default:
        {
            strcopy(dest,"Error",size);
        }
    }
}

stock Rock_ItemExtra(type)
{
    switch (type)
    {
        case 0: return E_ITEM_EXTRA_MINE_ROCK;
        case 1: return E_ITEM_EXTRA_MINE_IRON_ORE;
        case 2: return E_ITEM_EXTRA_MINE_COPPER_ORE;
        case 3: return E_ITEM_EXTRA_MINE_TIN_ORE;
        case 4: return E_ITEM_EXTRA_MINE_COAL_ORE;
        case 5: return E_ITEM_EXTRA_MINE_GOLD_ORE;
    }

    return -1;
}

stock Rock_ObjectModel(type)
{
    switch (type)
    {
        case 1: return ORE_IRON;
        case 2: return ORE_COPPER;
        case 3: return ORE_TIN;
        case 4: return ORE_COAL;
        case 5: return ORE_GOLD;
    }

    return ROCK_MODEL_NORMAL;
}

stock Rock_RollType()
{
    new type = Jobs_RandomEx(0,4), rare = Jobs_RandomEx(1,10);

    if (type == 1 || type == 3)
    {
        return rare >= 7 ? 5 : type;
    }

    return type;
}

static Rock_Label(const rock[e_ROCK])
{
    new text[64], name[40];
    Rock_TypeName(rock[E_ROCK_TYPE],true,name);
    format(text,sizeof(text),"%s\nHealth: %i",name,floatround(rock[E_ROCK_HEALTH]));
    UpdateDynamic3DTextLabelText(STREAMER_TAG_3D_TEXT_LABEL:rock[E_ROCK_LABEL],-1,text);
}

stock Rock_Colour(const rock[e_ROCK])
{
    new STREAMER_TAG_OBJECT:object = STREAMER_TAG_OBJECT:rock[E_ROCK_OBJECT];

    if (rock[E_ROCK_HEALTH] <= 0.0)
    {
        SetDynamicObjectMaterial(object,0,-1,"none","none",ROCK_DEPLETED_COLOUR);
        return;
    }

    switch (rock[E_ROCK_TYPE])
    {
        case 1: SetDynamicObjectMaterial(object,0,-1,"none","none",0xFF964B4B);
        case 2: SetDynamicObjectMaterial(object,0,-1,"none","none",0xFFFFB66C);
        case 3: SetDynamicObjectMaterial(object,0,-1,"none","none",0xFFC9C9C9);
        case 4: SetDynamicObjectMaterial(object,0,-1,"none","none",0xFF373737);
        case 5: SetDynamicObjectMaterial(object,0,-1,"none","none",0xFFE2B603);
        default: RemoveDynamicObjectMaterial(object,0);
    }
}

stock Rock_Create(Float:x,Float:y,Float:z,bool:scattered)
{
    if (!map_valid(g_Rocks))
    {
        g_Rocks = map_new();
    }

    new id = g_RockNext++, rock[e_ROCK], name[40], text[64];
    rock[E_ROCK_TYPE] = Rock_RollType();
    rock[E_ROCK_HEALTH] = 100.0;
    rock[E_ROCK_X] = x;
    rock[E_ROCK_Y] = y;
    rock[E_ROCK_Z] = z;
    rock[E_ROCK_DUE] = 0;

    if (scattered)
    {
        rock[E_ROCK_OBJECT] = _:CreateDynamicObject(Rock_ObjectModel(rock[E_ROCK_TYPE]),x,y,z,0.0,0.0,0.0,0,0,-1,150.0,150.0);
        g_RockScattered++;
    }
    else
    {
        rock[E_ROCK_OBJECT] = _:CreateDynamicObject(Rock_ObjectModel(rock[E_ROCK_TYPE]),x,y,z - 0.25,0.0,0.0,0.0,0,0);
    }

    Rock_TypeName(rock[E_ROCK_TYPE],true,name);
    format(text,sizeof(text),"%s\nHealth: %i",name,floatround(rock[E_ROCK_HEALTH]));
    rock[E_ROCK_LABEL] = _:CreateDynamic3DTextLabel(text,-1,x,y,z + 0.5,7.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1);
    map_add_arr(g_Rocks,id,rock);
    return id;
}

stock Rock_FindInRange(playerid,Float:range)
{
    if (!map_valid(g_Rocks))
    {
        return -1;
    }

    for (new Iter:it = map_iter(g_Rocks);iter_inside(it);iter_move_next(it))
    {
        new rock[e_ROCK];
        iter_get_arr(it,rock);

        if (IsPlayerInRangeOfPoint(playerid,range,rock[E_ROCK_X],rock[E_ROCK_Y],rock[E_ROCK_Z]))
        {
            return iter_get_key(it);
        }
    }

    return -1;
}

stock Rock_Respawn(id)
{
    new rock[e_ROCK];

    if (!Rock_Get(id,rock) || rock[E_ROCK_HEALTH] > 0.0)
    {
        return false;
    }

    rock[E_ROCK_HEALTH] = 100.0;
    rock[E_ROCK_DUE] = 0;
    Rock_Put(id,rock);
    Rock_Colour(rock);
    Rock_Label(rock);

    if (g_RockDepleted > 0)
    {
        g_RockDepleted--;
    }

    return true;
}

static Float:Rock_Cost(type)
{
    switch (type)
    {
        case 0: return 50.0;
        case 1: return 25.0;
        case 2: return 40.0;
        case 3: return 10.0;
        case 4: return 20.0;
    }

    return 100.0;
}

static Rock_Quality(type)
{
    switch (type)
    {
        case 0: return 50 + random(40);
        case 1: return 100 + random(45);
        case 2: return 150 + random(50);
        case 3: return 200 + random(55);
        case 4: return 250 + random(60);
    }

    return 300 + random(65);
}

stock bool:Mining_Start(playerid)
{
    if (Jobs_BackpackFull(playerid))
    {
        SendServerMessage(playerid,"You don't have enough backpack size to mine more. Go sell your rocks or get a bigger backpack.",MSG_TYPE_ERROR);
        return false;
    }

    if (Jobs_IsDoing(playerid))
    {
        return false;
    }

    if (Jobs_OnCooldown(playerid,E_JOB_MINING))
    {
        SendServerMessage(playerid,"You cannot mine right now - you are on a cooldown.",MSG_TYPE_ERROR);
        return false;
    }

    new id = Rock_FindInRange(playerid,ROCK_RANGE), rock[e_ROCK];

    if (id == -1 || !Rock_Get(id,rock))
    {
        return false;
    }

    if (rock[E_ROCK_HEALTH] < 1.0)
    {
        SendServerMessage(playerid,"This rock has no ore left! Come back later.",MSG_TYPE_ERROR);
        return false;
    }

    new skill = Jobs_Skill(playerid,E_JOB_MINING);

    if ((rock[E_ROCK_TYPE] == 1 || rock[E_ROCK_TYPE] == 2) && skill < 2)
    {
        SendServerMessage(playerid,"You need to have your Mining skill at level 2 to mine this ore.",MSG_TYPE_ERROR);
        return false;
    }

    if (rock[E_ROCK_TYPE] == 5 && skill < 3)
    {
        SendServerMessage(playerid,"You need to have your Mining skill at level 3 to mine this ore.",MSG_TYPE_ERROR);
        return false;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    TogglePlayerControllable(playerid,false);
    ApplyAnimation(playerid,"CHAINSAW","WEAPON_csawlo",4.1,true,true,true,true,0,SYNC_ALL);
    g_JobKind[playerid] = E_JOB_MINING;
    g_JobTarget[playerid] = id;
    g_JobProgress[playerid] = 0;
    Jobs_ClearCircle(playerid);
    g_JobCircle[playerid] = CreateDynamicCircle(x,y,JOB_CIRCLE_SIZE,0,0,playerid);
    ActionPanel_Show(playerid,E_ACTION_TYPE_MINING);
    pawn_call_public("Jobs_OnStarted","dd",playerid,E_JOB_MINING);
    return true;
}

stock Mining_Progress(playerid)
{
    new id = Rock_FindInRange(playerid,ROCK_RANGE), rock[e_ROCK];

    if (id == -1 || !Rock_Get(id,rock))
    {
        return;
    }

    new skill = Jobs_Skill(playerid,E_JOB_MINING), gain;

    switch (rock[E_ROCK_TYPE])
    {
        case 0: gain = skill < 2 ? Jobs_RandomEx(5,15) : Jobs_RandomEx(10,25);
        case 1: gain = skill < 3 ? Jobs_RandomEx(3,10) : Jobs_RandomEx(6,18);
        case 2: gain = skill < 3 ? Jobs_RandomEx(5,10) : Jobs_RandomEx(10,20);
        case 3: gain = skill < 2 ? Jobs_RandomEx(5,10) : Jobs_RandomEx(10,20);
        case 4: gain = skill < 2 ? Jobs_RandomEx(8,20) : Jobs_RandomEx(15,25);
        default: gain = Jobs_RandomEx(5,10);
    }

    g_JobProgress[playerid] += gain;
    ActionPanel_SetProgress(playerid,float(g_JobProgress[playerid]));

    if (g_JobProgress[playerid] >= 100)
    {
        Mining_Mine(playerid,id);
    }
}

stock Mining_Mine(playerid,id)
{
    new rock[e_ROCK], name[40], line[160], extra, exp = 1 + random(2);

    if (!Rock_Get(id,rock))
    {
        return;
    }

    Rock_TypeName(rock[E_ROCK_TYPE],true,name);
    ApplyAnimation(playerid,"CHAINSAW","WEAPON_csawlo",4.1,false,true,true,true,1,SYNC_ALL);
    TogglePlayerControllable(playerid,true);
    format(line,sizeof(line),"You have mined some %s (id %d).",name,id);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    g_JobProgress[playerid] = 0;
    g_JobKind[playerid] = E_JOB_NONE;
    ClearAnimations(playerid,SYNC_ALL);
    Jobs_ClearCircle(playerid);
    rock[E_ROCK_HEALTH] -= Rock_Cost(rock[E_ROCK_TYPE]);

    if (rock[E_ROCK_HEALTH] < 0.0)
    {
        rock[E_ROCK_HEALTH] = 0.0;
    }

    extra = Rock_ItemExtra(rock[E_ROCK_TYPE]);

    if (rock[E_ROCK_HEALTH] <= 0.0)
    {
        rock[E_ROCK_DUE] = GetTickCount() + ROCK_RESPAWN_MS;

        if (rock[E_ROCK_DUE] == 0)
        {
            rock[E_ROCK_DUE] = 1;
        }

        g_RockDepleted++;
    }

    Rock_Put(id,rock);
    Rock_Label(rock);

    if (rock[E_ROCK_HEALTH] <= 0.0)
    {
        Rock_Colour(rock);
    }

    if (!Inventory_GiveByParam(playerid,E_ITEM_PARAM_MINING,extra,1,Rock_Quality(rock[E_ROCK_TYPE]),-1,0))
    {
        SendServerMessage(playerid,"Error processing GivePlayerItemByParam for ore. Tell a dev to look at the drop for YOUR ID.",MSG_TYPE_ERROR);
    }

    Levels_GiveExperience(playerid,exp);
    Rock_TypeName(rock[E_ROCK_TYPE],false,name);
    format(line,sizeof(line),"| You've mined a %s.~n~~n~~w~ + %d exp for Mining Level!",name,exp);
    ActionPanel_SetText(playerid,line,ROCK_MODEL_NORMAL,false);
    pawn_call_public("Mining_OnMined","ddd",playerid,id,rock[E_ROCK_TYPE]);
    Jobs_CountAction(playerid,E_JOB_MINING);
}

stock Mining_Decay(playerid)
{
    if (g_JobKind[playerid] != E_JOB_MINING)
    {
        return;
    }

    new rock[e_ROCK];

    if (!Rock_Get(g_JobTarget[playerid],rock) || rock[E_ROCK_HEALTH] <= 0.0)
    {
        Jobs_Fix(playerid);
        return;
    }

    if (g_JobProgress[playerid] > 0)
    {
        g_JobProgress[playerid] -= Jobs_RandomEx(5,15);

        if (g_JobProgress[playerid] < 0)
        {
            g_JobProgress[playerid] = 0;
        }

        ActionPanel_SetProgress(playerid,float(g_JobProgress[playerid]));
    }
}

stock Mining_Tick()
{
    if (g_RockDepleted <= 0 || !map_valid(g_Rocks))
    {
        return;
    }

    new now = GetTickCount(), due[64], count = 0;

    for (new Iter:it = map_iter(g_Rocks);iter_inside(it) && count < sizeof(due);iter_move_next(it))
    {
        new rock[e_ROCK];
        iter_get_arr(it,rock);

        if (rock[E_ROCK_HEALTH] <= 0.0 && rock[E_ROCK_DUE] != 0 && now - rock[E_ROCK_DUE] >= 0)
        {
            due[count++] = iter_get_key(it);
        }
    }

    for (new i = 0;i < count;i++)
    {
        Rock_Respawn(due[i]);
    }
}

stock Mining_Init()
{
    g_Rocks = map_new();

    for (new i = 0;i < ROCK_STATIC_COUNT;i++)
    {
        Rock_Create(g_RockSpawns[i][0],g_RockSpawns[i][1],g_RockSpawns[i][2],false);
    }
}

public Mining_OnMined(playerid,rockid,type)
{
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
CMD:forcerespawnore(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new id;

    if (sscanf(params,"D(-1)",id))
    {
        SendServerMessage(playerid,"/forcerespawnore [oreid]",MSG_TYPE_ERROR);
        return 1;
    }

    new rock[e_ROCK], line[64];

    if (id == -1)
    {
        id = Rock_FindInRange(playerid,ROCK_FORCE_RANGE);

        if (id == -1)
        {
            SendServerMessage(playerid,"There is no rock near you. Use /forcerespawnore [oreid].",MSG_TYPE_ERROR);
            return 1;
        }
    }

    if (!Rock_Get(id,rock))
    {
        SendServerMessage(playerid,"That rock id doesn't exist.",MSG_TYPE_ERROR);
        return 1;
    }

    Rock_Respawn(id);
    format(line,sizeof(line),"You've respawned oreid %i.",id);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
}

CMD:gotorock(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid))
    {
        return 1;
    }

    new id;

    if (sscanf(params,"i",id))
    {
        SendClientMessage(playerid,-1,"/gotorock [rockid]");
        return 1;
    }

    new rock[e_ROCK];

    if (!Rock_Get(id,rock))
    {
        SendClientMessage(playerid,-1,"Invalid rock ID.");
        return 1;
    }

    SetPlayerPos(playerid,rock[E_ROCK_X],rock[E_ROCK_Y],rock[E_ROCK_Z]);
    return 1;
}
