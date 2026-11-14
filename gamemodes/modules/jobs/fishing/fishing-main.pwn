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
#define FISH_COUNT (6)
#define FISH_ROPE_MODEL (19089)
#define FISH_WAIT_MIN (1250)
#define FISH_WAIT_RANGE (5750)
#define FISH_THROW_MAX (12)

enum e_FISH
{
    E_FISH_NAME[16],
    E_FISH_MODEL,
    Float:E_FISH_INCREMENT,
    E_FISH_MAX_WEIGHT,
    E_FISH_MAX_LENGTH,
    E_FISH_EXTRA
}

new const g_Fish[FISH_COUNT][e_FISH] =
{
    {"Brown Trout",19630,0.5,10,30,E_ITEM_EXTRA_FISHING_BIGFISH},
    {"Shark",1608,5.2,610,4300,E_ITEM_EXTRA_FISHING_SHARK},
    {"Salmon",1599,3.3,47,150,E_ITEM_EXTRA_FISHING_YELLOW},
    {"Yellowfin Tuna",1600,1.2,200,240,E_ITEM_EXTRA_FISHING_BLUE_1},
    {"Pacific Cod",1604,4.6,23,120,E_ITEM_EXTRA_FISHING_BLUE_2},
    {"Smelly boot",11735,0.2,5,10,E_ITEM_EXTRA_FISHING_BOOT}
};

forward Fishing_BiteDeferred(playerid,ticket,wait);
forward Fishing_OnCaught(playerid,species,weight);

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
stock Fishing_Species(distance)
{
    if (distance < 1)
    {
        return 0;
    }

    return distance > FISH_THROW_MAX ? FISH_COUNT - 1 : (distance - 1) / 2;
}

stock Float:Fishing_RollWeight(species)
{
    new length = 1 + random(g_Fish[species][E_FISH_MAX_LENGTH]);
    new Float:weight = float(length) * g_Fish[species][E_FISH_INCREMENT];

    if (weight > float(g_Fish[species][E_FISH_MAX_WEIGHT]))
    {
        weight = float(g_Fish[species][E_FISH_MAX_WEIGHT]);
    }

    return weight;
}

stock bool:Fishing_NearWater(playerid)
{

    return bool:CA_IsPlayerNearWater(playerid);
}

stock bool:Jobs_BackpackFull(playerid)
{
    return Inventory_GetCount(playerid) >= Inventory_GetCapacity(playerid);
}

stock bool:Fishing_Start(playerid)
{
    if (g_JobWaiting[playerid] || g_JobReeling[playerid])
    {
        return false;
    }

    if (Jobs_BackpackFull(playerid))
    {
        SendServerMessage(playerid,"You don't have enough backpack size to fish more. Go sell your fish or get a bigger backpack.",MSG_TYPE_ERROR);
        return false;
    }

    if (Jobs_IsDoing(playerid))
    {
        return false;
    }

    if (!Fishing_NearWater(playerid))
    {
        return false;
    }

    if (Jobs_OnCooldown(playerid,E_JOB_FISHING))
    {
        SendServerMessage(playerid,"You cannot fish right now - you are on a cooldown.",MSG_TYPE_ERROR);
        return false;
    }

    new Float:x, Float:y, Float:z, distance = 1 + random(FISH_THROW_MAX);
    GetPlayerPos(playerid,x,y,z);
    SendServerMessage(playerid,"You've thrown your bobber into the water.",MSG_TYPE_INFO);
    g_JobKind[playerid] = E_JOB_FISHING;
    g_JobDistance[playerid] = distance;
    ApplyAnimation(playerid,"SWORD","sword_block",50.0,false,true,false,true,1,SYNC_ALL);
    Jobs_HidePanel(playerid);
    TogglePlayerControllable(playerid,false);
    Jobs_ClearRope(playerid);
    g_JobRope[playerid] = CreateDynamicObject(FISH_ROPE_MODEL,x,y,z,0.0,60.0,90.0,0,0);
    Jobs_ClearCircle(playerid);
    g_JobCircle[playerid] = CreateDynamicCircle(x,y,JOB_CIRCLE_SIZE,0,0,playerid);
    g_JobWaiting[playerid] = true;
    g_JobTicket[playerid]++;
    new wait = FISH_WAIT_MIN + random(FISH_WAIT_RANGE);

    new text[24];
    format(text,sizeof(text),"~w~Fishing..");
    GameTextForPlayer(playerid,text,wait - 250,4);
    SetTimerEx("Fishing_BiteDeferred",0,false,"ddd",playerid,g_JobTicket[playerid],wait);
    pawn_call_public("Jobs_OnStarted","dd",playerid,E_JOB_FISHING);
    return true;
}

static Fishing_BiteFlow(playerid,ticket,wait)
{
    yield 1;
    await task_ms(wait);

    if (!IsPlayerConnected(playerid) || ticket != g_JobTicket[playerid] || !g_JobWaiting[playerid] || g_JobKind[playerid] != E_JOB_FISHING)
    {
        return;
    }

    g_JobReeling[playerid] = true;
    g_JobProgress[playerid] = 0;
    TogglePlayerControllable(playerid,true);
    ActionPanel_Show(playerid,E_ACTION_TYPE_FISH);
}

public Fishing_BiteDeferred(playerid,ticket,wait)
{
    Fishing_BiteFlow(playerid,ticket,wait);
    return 1;
}

stock Fishing_Reel(playerid)
{
    if (!g_JobReeling[playerid])
    {
        return;
    }

    g_JobProgress[playerid] += 15 + random(20);

    if (g_JobProgress[playerid] >= 100)
    {
        Fishing_Catch(playerid);
        return;
    }

    ActionPanel_SetProgress(playerid,float(g_JobProgress[playerid]));
}

stock Fishing_Catch(playerid)
{
    new species = Fishing_Species(g_JobDistance[playerid]), Float:weight = Fishing_RollWeight(species), exp = 1 + random(2), rp[ACCOUNT_NAME_LEN], line[160];
    g_JobReeling[playerid] = false;
    g_JobWaiting[playerid] = false;
    g_JobProgress[playerid] = 0;
    g_JobKind[playerid] = E_JOB_NONE;
    g_JobTicket[playerid]++;
    Jobs_ClearRope(playerid);
    Jobs_ClearCircle(playerid);

    if (!Inventory_GiveByParam(playerid,E_ITEM_PARAM_FISHING,g_Fish[species][E_FISH_EXTRA],1,floatround(weight),-1,0))
    {
        SendServerMessage(playerid,"Error processing catch.",MSG_TYPE_ERROR);
        Jobs_Fix(playerid);
        return;
    }

    Levels_GiveExperience(playerid,exp);
    Account_GetRoleplayName(playerid,rp);
    format(line,sizeof(line),"** %s has caught a %s, which weighs %0.2f.",rp,g_Fish[species][E_FISH_NAME],weight);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
    format(line,sizeof(line),"| Managed to catch a %s~n~| Weight: %0.2f~n~~n~~w~ + %d exp for Hunting Level!",g_Fish[species][E_FISH_NAME],weight,exp);
    ActionPanel_SetText(playerid,line,g_Fish[species][E_FISH_MODEL],false);
    pawn_call_public("Fishing_OnCaught","ddd",playerid,species,floatround(weight));
    Jobs_CountAction(playerid,E_JOB_FISHING);
}

stock Fishing_Decay(playerid)
{
    if (!g_JobReeling[playerid] || g_JobProgress[playerid] <= 0)
    {
        return;
    }

    g_JobProgress[playerid] -= Jobs_RandomEx(5,15);

    if (g_JobProgress[playerid] < 0)
    {
        g_JobProgress[playerid] = 0;
    }

    ActionPanel_SetProgress(playerid,float(g_JobProgress[playerid]));
}

public Fishing_OnCaught(playerid,species,weight)
{
    return 1;
}

