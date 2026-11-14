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
#define TUTORIAL_TASKS (8)
#define TUTORIAL_TEXT_LEN (256)
#define TUTORIAL_REWARD (125)
#define TUTORIAL_SPLIT (100)
#define TUTORIAL_NONE (-1)

static const g_TutorialText[TUTORIAL_TASKS][TUTORIAL_TEXT_LEN] =
{
    "Catch your first fish by opening your inventory by pressing \"N\", clicking on the fishing rod tile, and clicking \"Equip\". Once it has been equipped, press \"LALT\" near a water source to fish.",
    "Sell your caught fish by opening your inventory and pressing \"N\", clicking on a fish tile, and clicking \"Sell\" whilst being in any hunting store.",
    "Cut down your first tree by equipping your hatchet from your inventory, walking up to any birch tree and pressing \"LALT\".",
    "Sell your logs by opening your inventory and pressing \"N\", clicking on any log tile, and clicking \"Sell\" whilst being in a blacksmith business.",
    "Mine your first ore by equipping your pickaxe from your inventory, walking up to a ore and pressing \"LALT\".",
    "Sell your ore by opening your inventory and pressing \"N\", clicking on any ore tile, and clicking \"Sell\" whilst being in a blacksmith business.",
    "Kill your first deer or cow by using /unholster with any firearm and shooting the animal.",
    "Sell your animal hide/animal meat/animal leg by opening your inventory and pressing \"N\", clicking on the appropriate tile, and clicking \"Sell\" whilst being in any hunting store."
};

static s_TutorialDoing[MAX_PLAYERS];
static s_TutorialKilled = -1;
static s_TutorialKilledTick;

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
stock Tutorial_GetDoing(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS ? s_TutorialDoing[playerid] : TUTORIAL_NONE;
}

static Tutorial_Say(playerid,const prefix[],colour,index)
{
    new line[TUTORIAL_TEXT_LEN + 48];

    if (strlen(g_TutorialText[index]) <= TUTORIAL_SPLIT)
    {
        format(line,sizeof(line),"%sTask %d: %s",prefix,index + 1,g_TutorialText[index]);
        SendClientMessage(playerid,colour,line);
        return;
    }

    format(line,sizeof(line),"%sTask %d: %.100s",prefix,index + 1,g_TutorialText[index]);
    SendClientMessage(playerid,colour,line);
    format(line,sizeof(line),"%s",g_TutorialText[index][TUTORIAL_SPLIT]);
    SendClientMessage(playerid,-1,line);
}

stock bool:Tutorial_Process(playerid,index)
{
    if (s_TutorialDoing[playerid] != index || index < 0 || index >= TUTORIAL_TASKS)
    {
        return false;
    }

    new value = Account_GetTutorial(playerid);
    s_TutorialDoing[playerid] = TUTORIAL_NONE;
    value = value == 0 ? 2 : value + 1;
    Account_SetTutorial(playerid,value);

    if (value >= TUTORIAL_TASKS + 1)
    {
        Money_Give(playerid,Money_Make(TUTORIAL_REWARD));
        SendClientMessage(playerid,0x649E66FF,"[TASKS]:{FFFFFF} You've completed all your tasks and recieved $125 as a reward.");
    }
    else
    {
        SendClientMessage(playerid,0xC4A754FF,"[TASKS]:{FFFFFF} To proceed to the next task, use /task.");
    }

    return true;
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
CMD:tasks(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    new value = Account_GetTutorial(playerid);
    SendClientMessage(playerid,-1," ");

    for (new i = 0;i < TUTORIAL_TASKS;i++)
    {
        if (value <= i + 1)
        {
            Tutorial_Say(playerid,"[PENDING]{FFFFFF} ",0xC4A754FF,i);
        }
        else
        {
            Tutorial_Say(playerid,"[DONE]{FFFFFF} ",0x649E66FF,i);
        }
    }

    SendClientMessage(playerid,-1," ");
    SendClientMessage(playerid,-1,"To do your next task, use /task to start the sequence. To cancel, use /notask.");
    return 1;
}

CMD:task(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (s_TutorialDoing[playerid] != TUTORIAL_NONE)
    {
        Tutorial_Say(playerid,"",-1,s_TutorialDoing[playerid]);
        SendServerMessage(playerid,"You're already doing a task.  Use /notask to cancel your current task.",MSG_TYPE_ERROR);
        return 1;
    }

    new taskid = Account_GetTutorial(playerid);

    if (taskid == 0)
    {
        taskid = 1;
    }

    if (taskid >= TUTORIAL_TASKS + 1)
    {
        SendServerMessage(playerid,"You've already completed all your tasks.",MSG_TYPE_ERROR);
        return 1;
    }

    Tutorial_Say(playerid,"",-1,taskid - 1);
    s_TutorialDoing[playerid] = taskid - 1;
    return 1;
}

CMD:notask(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (s_TutorialDoing[playerid] == TUTORIAL_NONE)
    {
        SendServerMessage(playerid,"You aren't doing a task!",MSG_TYPE_ERROR);
        return 1;
    }

    s_TutorialDoing[playerid] = TUTORIAL_NONE;
    SendServerMessage(playerid,"You've cancelled your current task.",MSG_TYPE_INFO);
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

hook OnGameModeInit()
{
    CreateDynamic3DTextLabel("[Server Tutorial]\n{DEDEDE}Empty Fishing Stall",0x77D472FF,-2229.0227,2353.0476,7.5480,15.0);
}

hook OnPlayerConnect(playerid)
{
    s_TutorialDoing[playerid] = TUTORIAL_NONE;
}

forward Tutorial_Remind(playerid,token);

public Tutorial_Remind(playerid,token)
{
    if (!Account_IsCurrent(playerid,token) || Account_GetTutorial(playerid) >= TUTORIAL_TASKS + 1)
    {
        return 1;
    }

    SendClientMessage(playerid,-1," ");
    SendClientMessage(playerid,0xDEDEDEFF,"It seems you haven't finished your tutorial tasks yet. If you are new to the server and want to learn the basics");
    SendClientMessage(playerid,0xDEDEDEFF,"it is adviced to use {D4AE72}/tasks{DEDEDE} to see your progress. You also get a reward for completing them.");
    SendClientMessage(playerid,-1," ");
    return 1;
}

hook Player_OnReady(playerid)
{
    SetTimerEx("Tutorial_Remind",5000,false,"dd",playerid,Account_GetToken(playerid));
}

hook Character_OnLoad(playerid,characterid)
{
    s_TutorialDoing[playerid] = TUTORIAL_NONE;
}

hook Jobs_OnAction(playerid,job)
{
    switch (job)
    {
        case E_JOB_FISHING:
        {
            Tutorial_Process(playerid,0);
        }
        case E_JOB_LUMBER:
        {
            Tutorial_Process(playerid,2);
        }
        case E_JOB_MINING:
        {
            Tutorial_Process(playerid,4);
        }
    }
}

hook Shop_OnSold(playerid,item,extra,cents)
{
    switch (extra)
    {
        case E_ITEM_EXTRA_FISHING_BLUE_1, E_ITEM_EXTRA_FISHING_BLUE_2, E_ITEM_EXTRA_FISHING_YELLOW, E_ITEM_EXTRA_FISHING_BIGFISH, E_ITEM_EXTRA_FISHING_SHARK:
        {
            Tutorial_Process(playerid,1);
        }
        case E_ITEM_EXTRA_LUMBER_OAK_LOG, E_ITEM_EXTRA_LUMBER_BIRCH_LOG, E_ITEM_EXTRA_LUMBER_YEW_LOG:
        {
            Tutorial_Process(playerid,3);
        }
        case E_ITEM_EXTRA_MINE_ROCK, E_ITEM_EXTRA_MINE_IRON_ORE, E_ITEM_EXTRA_MINE_COPPER_ORE, E_ITEM_EXTRA_MINE_GOLD_ORE, E_ITEM_EXTRA_MINE_COAL_ORE, E_ITEM_EXTRA_MINE_TIN_ORE:
        {
            Tutorial_Process(playerid,5);
        }
        case E_ITEM_EXTRA_WILDLIFE_HIDE, E_ITEM_EXTRA_WILDLIFE_MEAT, E_ITEM_EXTRA_WILDLIFE_MEAT_LEG:
        {
            Tutorial_Process(playerid,7);
        }
    }
}

hook Wildlife_OnKilled(id,weapon)
{
    s_TutorialKilled = id;
    s_TutorialKilledTick = GetTickCount();
}

hook Wildlife_OnShot(playerid,id)
{
    if (s_TutorialKilled == id && GetTickCount() - s_TutorialKilledTick < 200)
    {
        Tutorial_Process(playerid,6);
    }

    s_TutorialKilled = -1;
}
