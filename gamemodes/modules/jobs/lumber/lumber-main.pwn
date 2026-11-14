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
#define TREE_RANGE (2.5)
#define TREE_RESPAWN_MS (900000)
#define TREE_MODEL (669)
#define TREE_ICON_MODEL (19632)

enum e_TREE
{
    E_TREE_TYPE,
    Float:E_TREE_HEALTH,
    Float:E_TREE_X,
    Float:E_TREE_Y,
    Float:E_TREE_Z,
    E_TREE_OBJECT,
    E_TREE_LABEL,
    E_TREE_DUE
}

new Map:g_Trees;
new g_TreeNext;
new g_TreeFelled;

forward Lumber_OnChopped(playerid,treeid,type);

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
stock Tree_Count()
{
    return map_valid(g_Trees) ? map_size(g_Trees) : 0;
}

stock bool:Tree_Get(id,tree[e_TREE])
{
    if (!map_valid(g_Trees) || !map_has_key(g_Trees,id))
    {
        return false;
    }

    map_get_arr(g_Trees,id,tree);
    return true;
}

stock Tree_Put(id,const tree[e_TREE])
{
    map_set_arr(g_Trees,id,tree);
}

stock Tree_TypeName(type,bool:coloured,dest[],size = sizeof(dest))
{
    switch (type)
    {
        case 0:
        {
            strcopy(dest,coloured ? ("{C9C9C9}Birch Tree{FFFFFF}") : ("Birch Tree"),size);
        }
        case 1:
        {
            strcopy(dest,coloured ? ("{BA9F7B}Oak Tree{FFFFFF}") : ("Oak Tree"),size);
        }
        case 2:
        {
            strcopy(dest,coloured ? ("{96744D}Yew Tree{FFFFFF}") : ("Yew Tree"),size);
        }
        default:
        {
            strcopy(dest,"Error",size);
        }
    }
}

stock Tree_ItemExtra(type)
{
    switch (type)
    {
        case 0: return E_ITEM_EXTRA_LUMBER_BIRCH_LOG;
        case 1: return E_ITEM_EXTRA_LUMBER_OAK_LOG;
        case 2: return E_ITEM_EXTRA_LUMBER_YEW_LOG;
    }

    return -1;
}

static Tree_Cost(type)
{
    switch (type)
    {
        case 0: return 50;
        case 1: return 25;
    }

    return 20;
}

static Tree_Quality(type)
{
    switch (type)
    {
        case 0: return 25 + random(25);
        case 1: return 45 + random(45);
    }

    return 75 + random(75);
}

stock Tree_Colour(const tree[e_TREE])
{
    new STREAMER_TAG_OBJECT:object = STREAMER_TAG_OBJECT:tree[E_TREE_OBJECT];

    if (tree[E_TREE_HEALTH] > 0.0)
    {
        switch (tree[E_TREE_TYPE])
        {
            case 0:
            {
                SetDynamicObjectMaterial(object,0,708,"none","none",0x00FFFFFF);
                SetDynamicObjectMaterial(object,1,5847,"lawnbush","kbplanter_plants1",0xFFFFFFFF);
                SetDynamicObjectMaterial(object,2,5847,"lawnbush","kbplanter_plants1",0xFFFFFFFF);
                SetDynamicObjectMaterial(object,3,708,"gta_tree_boak","sm_bark_light",0xFFFFFFFF);
            }
            case 1:
            {
                SetDynamicObjectMaterial(object,0,708,"none","none",0x00FFFFFF);
                SetDynamicObjectMaterial(object,3,-1,"none","none",0xFFA0A0A0);
            }
            case 2:
            {
                SetDynamicObjectMaterial(object,0,708,"none","none",0x00FFFFFF);
                SetDynamicObjectMaterial(object,1,708,"gta_tree_boak","newtreeleavesb128",0xFFFFFFFF);
                SetDynamicObjectMaterial(object,2,708,"gta_tree_boak","newtreeleavesb128",0xFFFFFFFF);
                SetDynamicObjectMaterial(object,3,708,"gta_tree_boak","sm_redwood_bark",0xFF5F5F5F);
            }
        }

        return;
    }

    switch (tree[E_TREE_TYPE])
    {
        case 0: SetDynamicObjectMaterial(object,0,708,"gta_tree_boak","sm_bark_light",0xFFFFFFFF);
        case 1: SetDynamicObjectMaterial(object,0,-1,"none","none",0xFFA0A0A0);
        case 2: SetDynamicObjectMaterial(object,0,708,"gta_tree_boak","sm_redwood_bark",0xFF5F5F5F);
    }
}

static Tree_Spawn(tree[e_TREE],model,bool:stump)
{
    new text[64], name[40];

    if (_:tree[E_TREE_OBJECT] != 0)
    {
        DestroyDynamicObject(STREAMER_TAG_OBJECT:tree[E_TREE_OBJECT]);
    }

    if (_:tree[E_TREE_LABEL] != 0)
    {
        DestroyDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:tree[E_TREE_LABEL]);
    }

    new Float:x = tree[E_TREE_X], Float:y = tree[E_TREE_Y], Float:z = tree[E_TREE_Z];

    if (CA_FindZ_For2DCoord(x,y,z))
    {
        tree[E_TREE_Z] = z;
    }

    tree[E_TREE_OBJECT] = _:CreateDynamicObject(model,tree[E_TREE_X],tree[E_TREE_Y],tree[E_TREE_Z],0.0,0.0,0.0,0,0,-1,150.0,150.0);
    Tree_TypeName(tree[E_TREE_TYPE],true,name);

    if (stump)
    {
        format(text,sizeof(text),"%s Stump",name);
    }
    else
    {
        format(text,sizeof(text),"%s\nHealth: %i",name,floatround(tree[E_TREE_HEALTH]));
    }

    tree[E_TREE_LABEL] = _:CreateDynamic3DTextLabel(text,-1,tree[E_TREE_X],tree[E_TREE_Y],tree[E_TREE_Z] + 0.5,7.0);
    Tree_Colour(tree);
}

stock Tree_Create(Float:x,Float:y,Float:z)
{
    if (!map_valid(g_Trees))
    {
        g_Trees = map_new();
    }

    new id = g_TreeNext++, tree[e_TREE];
    tree[E_TREE_TYPE] = Jobs_RandomEx(0,2);
    tree[E_TREE_HEALTH] = 100.0;
    tree[E_TREE_X] = x;
    tree[E_TREE_Y] = y;
    tree[E_TREE_Z] = z;
    tree[E_TREE_OBJECT] = 0;
    tree[E_TREE_LABEL] = 0;
    tree[E_TREE_DUE] = 0;
    new Float:keep = tree[E_TREE_Z];
    tree[E_TREE_OBJECT] = _:CreateDynamicObject(TREE_MODEL,x,y,keep,0.0,0.0,0.0,0,0,-1,150.0,150.0);
    new name[40], text[64];
    Tree_TypeName(tree[E_TREE_TYPE],true,name);
    format(text,sizeof(text),"%s\nHealth: %i",name,floatround(tree[E_TREE_HEALTH]));
    tree[E_TREE_LABEL] = _:CreateDynamic3DTextLabel(text,-1,x,y,keep + 0.5,7.0);
    Tree_Colour(tree);
    map_add_arr(g_Trees,id,tree);
    return id;
}

stock Tree_FindInRange(playerid,Float:range)
{
    if (!map_valid(g_Trees))
    {
        return -1;
    }

    for (new Iter:it = map_iter(g_Trees);iter_inside(it);iter_move_next(it))
    {
        new tree[e_TREE];
        iter_get_arr(it,tree);

        if (IsPlayerInRangeOfPoint(playerid,range,tree[E_TREE_X],tree[E_TREE_Y],tree[E_TREE_Z]))
        {
            return iter_get_key(it);
        }
    }

    return -1;
}

stock bool:Tree_Respawn(id)
{
    new tree[e_TREE];

    if (!Tree_Get(id,tree) || tree[E_TREE_HEALTH] > 0.0)
    {
        return false;
    }

    tree[E_TREE_HEALTH] = 100.0;
    tree[E_TREE_DUE] = 0;
    Tree_Spawn(tree,TREE_MODEL,false);
    Tree_Put(id,tree);

    if (g_TreeFelled > 0)
    {
        g_TreeFelled--;
    }

    return true;
}

stock bool:Lumber_Start(playerid)
{
    if (Jobs_BackpackFull(playerid))
    {
        SendServerMessage(playerid,"You don't have enough backpack size to cut more wood. Go sell your logs or get a bigger backpack.",MSG_TYPE_ERROR);
        return false;
    }

    if (Jobs_IsDoing(playerid))
    {
        return false;
    }

    if (Jobs_OnCooldown(playerid,E_JOB_LUMBER))
    {
        SendServerMessage(playerid,"You cannot cut trees right now - you are on a cooldown.",MSG_TYPE_ERROR);
        return false;
    }

    new id = Tree_FindInRange(playerid,TREE_RANGE), tree[e_TREE];

    if (id == -1 || !Tree_Get(id,tree))
    {
        return false;
    }

    if (tree[E_TREE_HEALTH] <= 0.0)
    {
        SendServerMessage(playerid,"The tree you're trying to cut has already been chopped down.",MSG_TYPE_ERROR);
        return false;
    }

    new skill = Jobs_Skill(playerid,E_JOB_LUMBER);

    if (tree[E_TREE_TYPE] == 1 && skill < 2)
    {
        SendServerMessage(playerid,"You need to have your Woodcutting skill at level 2 to cut down this tree.",MSG_TYPE_ERROR);
        return false;
    }

    if (tree[E_TREE_TYPE] == 2 && skill < 3)
    {
        SendServerMessage(playerid,"You need to have your Woodcutting skill at level 3 to cut down this tree.",MSG_TYPE_ERROR);
        return false;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    TogglePlayerControllable(playerid,false);
    ApplyAnimation(playerid,"RIOT","RIOT_ANGRY_B",4.1,true,true,true,true,0,SYNC_ALL);
    g_JobKind[playerid] = E_JOB_LUMBER;
    g_JobTarget[playerid] = id;
    g_JobProgress[playerid] = 0;
    Jobs_ClearCircle(playerid);
    g_JobCircle[playerid] = CreateDynamicCircle(x,y,JOB_CIRCLE_SIZE,0,0,playerid);
    ActionPanel_Show(playerid,E_ACTION_TYPE_LUMBER);
    pawn_call_public("Jobs_OnStarted","dd",playerid,E_JOB_LUMBER);
    return true;
}

stock Lumber_Progress(playerid)
{
    new id = Tree_FindInRange(playerid,TREE_RANGE), tree[e_TREE];

    if (id == -1 || !Tree_Get(id,tree))
    {
        return;
    }

    new skill = Jobs_Skill(playerid,E_JOB_LUMBER), gain;

    switch (tree[E_TREE_TYPE])
    {
        case 0: gain = skill < 2 ? Jobs_RandomEx(5,25) : Jobs_RandomEx(15,30);
        case 1: gain = skill < 3 ? Jobs_RandomEx(5,20) : Jobs_RandomEx(10,20);
        default: gain = Jobs_RandomEx(5,15);
    }

    g_JobProgress[playerid] += gain;
    ActionPanel_SetProgress(playerid,float(g_JobProgress[playerid]));

    if (g_JobProgress[playerid] >= 100)
    {
        Lumber_Chop(playerid,id);
    }
}

stock Lumber_Chop(playerid,id)
{
    new tree[e_TREE], name[40], line[160], exp = 1 + random(2);

    if (!Tree_Get(id,tree))
    {
        return;
    }

    Tree_TypeName(tree[E_TREE_TYPE],true,name);
    format(line,sizeof(line),"You have chopped down a %s (id %d)",name,id);
    SendClientMessage(playerid,-1,line);
    ApplyAnimation(playerid,"RIOT","RIOT_ANGRY_B",4.1,false,true,true,true,1,SYNC_ALL);
    g_JobProgress[playerid] = 0;
    g_JobKind[playerid] = E_JOB_NONE;
    TogglePlayerControllable(playerid,true);
    Jobs_ClearCircle(playerid);
    tree[E_TREE_HEALTH] -= float(Tree_Cost(tree[E_TREE_TYPE]));

    if (tree[E_TREE_HEALTH] < 0.0)
    {
        tree[E_TREE_HEALTH] = 0.0;
    }

    if (!Inventory_GiveByParam(playerid,E_ITEM_PARAM_LUMBER,Tree_ItemExtra(tree[E_TREE_TYPE]),1,Tree_Quality(tree[E_TREE_TYPE]),-1,0))
    {
        SendServerMessage(playerid,"Error processing give_item for tree. Tell a dev to look at the drop for YOUR ID.",MSG_TYPE_ERROR);
    }

    if (tree[E_TREE_HEALTH] <= 0.0)
    {
        tree[E_TREE_DUE] = GetTickCount() + TREE_RESPAWN_MS;

        if (tree[E_TREE_DUE] == 0)
        {
            tree[E_TREE_DUE] = 1;
        }

        Tree_Spawn(tree,Jobs_RandomEx(831,832),true);
        g_TreeFelled++;
    }
    else
    {
        new text[64];
        format(text,sizeof(text),"%s\nHealth: %i",name,floatround(tree[E_TREE_HEALTH]));
        UpdateDynamic3DTextLabelText(STREAMER_TAG_3D_TEXT_LABEL:tree[E_TREE_LABEL],-1,text);
    }

    Tree_Put(id,tree);
    Levels_GiveExperience(playerid,exp);
    Tree_TypeName(tree[E_TREE_TYPE],false,name);
    format(line,sizeof(line),"| You've chopped a %s.~n~~n~~w~ + %d exp for Woodcut Level!",name,exp);
    ActionPanel_SetText(playerid,line,TREE_ICON_MODEL,false);
    pawn_call_public("Lumber_OnChopped","ddd",playerid,id,tree[E_TREE_TYPE]);
    Jobs_CountAction(playerid,E_JOB_LUMBER);
}

stock Lumber_Decay(playerid)
{
    if (g_JobKind[playerid] != E_JOB_LUMBER)
    {
        return;
    }

    new tree[e_TREE];

    if (!Tree_Get(g_JobTarget[playerid],tree) || tree[E_TREE_HEALTH] <= 0.0)
    {
        Jobs_Fix(playerid);
        return;
    }

    if (g_JobProgress[playerid] > 0)
    {
        g_JobProgress[playerid] -= Jobs_RandomEx(5,10);

        if (g_JobProgress[playerid] < 0)
        {
            g_JobProgress[playerid] = 0;
        }

        ActionPanel_SetProgress(playerid,float(g_JobProgress[playerid]));
    }
}

stock Lumber_Tick()
{
    if (g_TreeFelled <= 0 || !map_valid(g_Trees))
    {
        return;
    }

    new now = GetTickCount(), due[64], count = 0;

    for (new Iter:it = map_iter(g_Trees);iter_inside(it) && count < sizeof(due);iter_move_next(it))
    {
        new tree[e_TREE];
        iter_get_arr(it,tree);

        if (tree[E_TREE_HEALTH] <= 0.0 && tree[E_TREE_DUE] != 0 && now - tree[E_TREE_DUE] >= 0)
        {
            due[count++] = iter_get_key(it);
        }
    }

    for (new i = 0;i < count;i++)
    {
        Tree_Respawn(due[i]);
    }
}

stock Lumber_Init()
{
    g_Trees = map_new();
}

public Lumber_OnChopped(playerid,treeid,type)
{
    return 1;
}
