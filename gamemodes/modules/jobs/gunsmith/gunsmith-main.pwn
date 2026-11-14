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
#define GUN_MIN_LEVEL (3)
#define GUN_STATION_RANGE (2.5)
#define GUN_FURNACE_MS (750)
#define GUN_COUNTDOWN_MS (1000)
#define GUN_ORE_COPPER (10)
#define GUN_ORE_TIN (5)
#define GUN_STATIONS (5)
#define GUN_RECIPES (8)
#define GUN_AREA_MIN_X (-1228.6282)
#define GUN_AREA_MAX_X (-1212.3748)
#define GUN_AREA_MIN_Y (1813.9226)
#define GUN_AREA_MAX_Y (1838.9640)
#define GUN_NONE (-1)

enum _:E_GUN_STATION
{
    E_GUN_STATION_COAL = 0,
    E_GUN_STATION_LUMBER,
    E_GUN_STATION_FURNACE,
    E_GUN_STATION_COOLING,
    E_GUN_STATION_BASEMENT,
}

enum e_GUN_RECIPE
{
    E_GUN_RECIPE_NAME[20],
    E_GUN_RECIPE_PARTS,
    E_GUN_RECIPE_LEVEL,
    E_GUN_RECIPE_WEAPON,
    E_GUN_RECIPE_CRATE,
    E_GUN_RECIPE_DONE[40],
}

static const s_GunStationNames[GUN_STATIONS][40] =
{
    "Coal Heap: Fuel",
    "Lumber Block: Ingot Reforming",
    "Furnace: Ore smelting",
    "Cooling: Ingot Creation",
    "Basement: Gun Finalization"
};

static const Float:s_GunStationPos[GUN_STATIONS][3] =
{
    {-1212.5631,1831.2927,42.3896},
    {-1218.0070,1825.6216,41.7440},
    {-1214.9054,1819.7556,40.3845},
    {-1223.6672,1821.7823,41.8300},
    {-1227.2146,1835.9607,41.6191}
};

static const s_GunRecipes[GUN_RECIPES][e_GUN_RECIPE] =
{
    {"Revolver",4,4,24,0,"You have crafted a Revolver."},
    {"Shotgun",6,4,25,0,"You have crafted a Shotgun."},
    {"Sawed off Shotgun",6,3,26,0,"You have crafted a Sawn Off Shotgun."},
    {"Rifle",8,6,33,0,"You have crafted a Rifle."},
    {"Sniper",8,8,34,0,"You have crafted a Sniper."},
    {"Pistol Ammo",3,0,0,E_ITEM_EXTRA_AMMO_CRATE_PISTOL,"You have crafted a Pistol Ammo Crate."},
    {"Shotgun Ammo",4,0,0,E_ITEM_EXTRA_AMMO_CRATE_SHOTGUN,"You have crafted a Shotgun Ammo Crate."},
    {"Rifle Ammo",5,0,0,E_ITEM_EXTRA_AMMO_CRATE_RIFLE,"You have crafted a Rifle Ammo Crate."}
};

static s_GunProgress[MAX_PLAYERS];
static s_GunCopper[MAX_PLAYERS];
static s_GunTin[MAX_PLAYERS];
static s_GunTicks[MAX_PLAYERS];
static s_GunJob[MAX_PLAYERS] = {GUN_NONE,...};
static s_GunJobEnd[MAX_PLAYERS];
static s_GunJobFroze[MAX_PLAYERS];
static bool:s_GunInside[MAX_PLAYERS];
static bool:s_GunMenu[MAX_PLAYERS];

forward Gunsmith_MenuDeferred(playerid,token);

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
stock Gunsmith_GetProgress(playerid)
{
    return s_GunProgress[playerid];
}

stock Gunsmith_GetCopper(playerid)
{
    return s_GunCopper[playerid];
}

stock Gunsmith_GetTin(playerid)
{
    return s_GunTin[playerid];
}

stock Gunsmith_GetTicks(playerid)
{
    return s_GunTicks[playerid];
}

stock Gunsmith_GetJob(playerid)
{
    return s_GunJob[playerid];
}

stock bool:Gunsmith_InArea(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    return x >= GUN_AREA_MIN_X && x <= GUN_AREA_MAX_X && y >= GUN_AREA_MIN_Y && y <= GUN_AREA_MAX_Y;
}

static Gunsmith_Station(playerid)
{
    for (new i = 0;i < GUN_STATIONS;i++)
    {
        if (IsPlayerInRangeOfPoint(playerid,GUN_STATION_RANGE,s_GunStationPos[i][0],s_GunStationPos[i][1],s_GunStationPos[i][2]))
        {
            return i;
        }
    }

    return -1;
}

static Gunsmith_Panel(playerid,const status[])
{
    if (ActionPanel_GetMode(playerid) != E_ACTION_TYPE_GUN)
    {
        return;
    }

    new text[160];
    format(text,sizeof(text),"@ Overall Progress: %d~n~Copper Ore: %d~n~Tin Ore: %d~n~Status: %s",s_GunProgress[playerid],s_GunCopper[playerid],s_GunTin[playerid],status);
    ActionPanel_SetText(playerid,text);
    ActionPanel_SetProgress(playerid,float(s_GunProgress[playerid]));
}

static Gunsmith_Fail(playerid,const what[])
{
    new line[160];
    format(line,sizeof(line),"Something went wrong. You were meant to get %s. Ask a dev for a refund and take a screenshot.",what);
    SendServerMessage(playerid,line,MSG_TYPE_ERROR);
}

static Gunsmith_Coal(playerid)
{
    if (Inventory_FindExtra(playerid,E_ITEM_EXTRA_FURNACE_COAL) != INV_ROW_NONE)
    {
        SendServerMessage(playerid,"You already have some coal. Add it to the furnace before getting some more.",MSG_TYPE_ERROR);
        return;
    }

    if (Inventory_GiveByParam(playerid,E_ITEM_PARAM_GUNCREATION,E_ITEM_EXTRA_FURNACE_COAL,1))
    {
        SendServerMessage(playerid,"You picked up some coal. Add it to the furnace to continue the smelting process.",MSG_TYPE_INFO);
    }
}

static Gunsmith_Lumber(playerid)
{
    new index = Inventory_FindExtra(playerid,E_ITEM_EXTRA_INGOT);

    if (index == INV_ROW_NONE)
    {
        SendServerMessage(playerid,"You don't have an ingot to reform.",MSG_TYPE_ERROR);
        return;
    }

    if (Inventory_GiveByParam(playerid,E_ITEM_PARAM_GUNCREATION,E_ITEM_EXTRA_GUNPART,1))
    {
        index = Inventory_FindExtra(playerid,E_ITEM_EXTRA_INGOT);

        if (index != INV_ROW_NONE)
        {
            Inventory_Decrease(playerid,index,1,false);
        }

        SendServerMessage(playerid,"You formed the ingot into a gunpart.",MSG_TYPE_INFO);
    }
}

static Gunsmith_Cooling(playerid)
{
    new index = Inventory_FindExtra(playerid,E_ITEM_EXTRA_FRACTURED_SUBSTANCE);

    if (index == INV_ROW_NONE)
    {
        SendServerMessage(playerid,"You don't have any Fractured Substance to reform.",MSG_TYPE_ERROR);
        return;
    }

    new skill = Skills_Get(playerid,E_SKILL_JOB_BLACKSMITH), ingots = skill >= 6 ? 3 : (skill >= 4 ? 2 : 1);

    if (Inventory_GiveByParam(playerid,E_ITEM_PARAM_GUNCREATION,E_ITEM_EXTRA_INGOT,ingots))
    {
        index = Inventory_FindExtra(playerid,E_ITEM_EXTRA_FRACTURED_SUBSTANCE);

        if (index != INV_ROW_NONE)
        {
            Inventory_Decrease(playerid,index,1);
        }

        SendServerMessage(playerid,"You reform the Fractured Substance into a strong ingot.",MSG_TYPE_INFO);
    }
}

static Gunsmith_Furnace(playerid)
{
    if (s_GunCopper[playerid] < GUN_ORE_COPPER)
    {
        new index = Inventory_FindExtra(playerid,E_ITEM_EXTRA_MINE_COPPER_ORE), line[96];

        if (index == INV_ROW_NONE)
        {
            SendServerMessage(playerid,"You need to have some copper ore to add to the furnace.",MSG_TYPE_ERROR);
            return;
        }

        s_GunCopper[playerid]++;
        Inventory_Decrease(playerid,index,1);
        format(line,sizeof(line),"Added some copper ore to the furnace. You need to add %d more.",GUN_ORE_COPPER - s_GunCopper[playerid]);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        Gunsmith_Panel(playerid,"Idle");
        return;
    }

    if (s_GunTin[playerid] < GUN_ORE_TIN)
    {
        new index = Inventory_FindExtra(playerid,E_ITEM_EXTRA_MINE_TIN_ORE), line[96];

        if (index == INV_ROW_NONE)
        {
            SendServerMessage(playerid,"You need to have some tin ore to add to the furnace.",MSG_TYPE_ERROR);
            return;
        }

        s_GunTin[playerid]++;
        Inventory_Decrease(playerid,index,1);
        format(line,sizeof(line),"Added some tin ore to the furnace. You need to add %d more.",GUN_ORE_TIN - s_GunTin[playerid]);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        Gunsmith_Panel(playerid,"Idle");
        return;
    }

    if (Inventory_FindExtra(playerid,E_ITEM_EXTRA_FRACTURED_SUBSTANCE) != INV_ROW_NONE)
    {
        SendServerMessage(playerid,"You have a fractured substance. You need to cool it down in order to make an ingot out of it.",MSG_TYPE_ERROR);
        return;
    }

    new coal = Inventory_FindExtra(playerid,E_ITEM_EXTRA_FURNACE_COAL);

    if (coal == INV_ROW_NONE)
    {
        SendServerMessage(playerid,"You don't have any raw material to fuel the furnace with.",MSG_TYPE_ERROR);
        return;
    }

    SendServerMessage(playerid,"You've added some coal to the furnace.",MSG_TYPE_INFO);
    Inventory_Decrease(playerid,coal,1,false);
    s_GunProgress[playerid] += 5;
    s_GunTicks[playerid] = 11;
    Gunsmith_Panel(playerid,"Refuelling");
}

static Gunsmith_JobTime(playerid)
{
    new skill = Skills_Get(playerid,E_SKILL_JOB_BLACKSMITH);

    if (skill >= 6)
    {
        return 20;
    }

    return skill >= 2 ? 40 : 60;
}

static Gunsmith_Take(playerid,amount)
{
    Inventory_DecreaseExtra(playerid,E_ITEM_EXTRA_GUNPART,amount,false);
}

static Gunsmith_Refund(playerid,amount)
{
    for (new left = amount;left > 0;)
    {
        new put = left > 3 ? 3 : left;
        Inventory_GiveByParam(playerid,E_ITEM_PARAM_GUNCREATION,E_ITEM_EXTRA_GUNPART,put);
        left -= put;
    }
}

static Gunsmith_RefundOffline(characterid,amount)
{
    for (new left = amount;left > 0;)
    {
        new put = left > 3 ? 3 : left;
        mysql_tquery_s(g_Mysql,str_format("INSERT INTO items_player (player_database_id, player_item_id, player_item_amount, player_item_param1, player_item_param2) VALUES (%d, %d, %d, %d, %d)",characterid,Item_FindByExtra(E_ITEM_EXTRA_GUNPART),put,E_ITEM_PARAM_GUNCREATION,E_ITEM_EXTRA_GUNPART));
        left -= put;
    }
}

static Gunsmith_JobReset(playerid)
{
    s_GunJob[playerid] = GUN_NONE;
    s_GunJobEnd[playerid] = 0;
    s_GunJobFroze[playerid] = 0;
}

stock bool:Gunsmith_Start(playerid,recipe)
{
    if (recipe < 0 || recipe >= GUN_RECIPES)
    {
        SendServerMessage(playerid,"Something went wrong, please send a screenshot to a dev.",MSG_TYPE_ERROR);
        return false;
    }

    if (s_GunJob[playerid] != GUN_NONE)
    {
        SendServerMessage(playerid,"You are already crafting a weapon or ammo.",MSG_TYPE_ERROR);
        return false;
    }

    new level = s_GunRecipes[recipe][E_GUN_RECIPE_LEVEL], parts = s_GunRecipes[recipe][E_GUN_RECIPE_PARTS], line[128];

    if (level > 0 && Character_GetLevel(playerid) < level)
    {
        switch (recipe)
        {
            case 0:
            {
                SendServerMessage(playerid,"You need to be level 4 to craft a revolver.",MSG_TYPE_ERROR);
            }
            case 1:
            {
                SendServerMessage(playerid,"You need to be level 4 to craft a shotgun.",MSG_TYPE_ERROR);
            }
            case 2:
            {
                SendServerMessage(playerid,"You need to be level 3 to craft a sawn off shotgun.",MSG_TYPE_ERROR);
            }
            case 3:
            {
                SendServerMessage(playerid,"You need to be level 6 to craft a rifle.",MSG_TYPE_ERROR);
            }
            default:
            {
                SendServerMessage(playerid,"You need to be level 8 to craft a scoped rifle.",MSG_TYPE_ERROR);
            }
        }

        return false;
    }

    if (Inventory_GetExtraTotal(playerid,E_ITEM_EXTRA_GUNPART) < parts)
    {
        format(line,sizeof(line),"You don't have enough gunparts. You need at least %d.",parts);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return false;
    }

    if (s_GunRecipes[recipe][E_GUN_RECIPE_CRATE] != 0)
    {
        new crate = Item_FindByExtra(s_GunRecipes[recipe][E_GUN_RECIPE_CRATE]);

        if (!Inventory_CanHold(playerid,crate,1))
        {
            SendServerMessage(playerid,"You don't have enough backpack size to pick this item up. You have to get a bigger backpack.",MSG_TYPE_ERROR);
            return false;
        }
    }
    else if (Weapons_Get(playerid,E_GUN_SLOT_HAND) != 0)
    {
        SendServerMessage(playerid,"You can't create a weapon whilst you already have one equipped.",MSG_TYPE_ERROR);
        return false;
    }

    Gunsmith_Take(playerid,parts);
    s_GunJob[playerid] = recipe;
    s_GunJobEnd[playerid] = gettime() + Gunsmith_JobTime(playerid);
    s_GunJobFroze[playerid] = IsPlayerControllable(playerid) ? 1 : 0;

    if (s_GunJobFroze[playerid] != 0)
    {
        TogglePlayerControllable(playerid,false);
    }

    return true;
}

static Gunsmith_Finish(playerid)
{
    new recipe = s_GunJob[playerid], parts = s_GunRecipes[recipe][E_GUN_RECIPE_PARTS], bool:done = false;

    if (s_GunRecipes[recipe][E_GUN_RECIPE_WEAPON] != 0)
    {
        done = Weapons_Give(playerid,s_GunRecipes[recipe][E_GUN_RECIPE_WEAPON],0);
    }
    else
    {
        done = Inventory_GiveByParam(playerid,E_ITEM_PARAM_AMMO,s_GunRecipes[recipe][E_GUN_RECIPE_CRATE],1);
    }

    if (done)
    {
        SendServerMessage(playerid,s_GunRecipes[recipe][E_GUN_RECIPE_DONE],MSG_TYPE_INFO);
    }
    else
    {
        Gunsmith_Refund(playerid,parts);
        SendServerMessage(playerid,"The crafting failed and your gunparts were returned to you.",MSG_TYPE_ERROR);
    }

    if (s_GunJobFroze[playerid] != 0)
    {
        TogglePlayerControllable(playerid,true);
    }

    Gunsmith_JobReset(playerid);
}

stock Gunsmith_FurnaceTick()
{
    foreach (new playerid : Player)
    {
        if (s_GunTicks[playerid] <= 0)
        {
            continue;
        }

        s_GunProgress[playerid] += 2;

        if (s_GunProgress[playerid] >= 100)
        {
            if (Inventory_GiveByParam(playerid,E_ITEM_PARAM_GUNCREATION,E_ITEM_EXTRA_FRACTURED_SUBSTANCE,1))
            {
                s_GunProgress[playerid] = 0;
                s_GunCopper[playerid] = 0;
                s_GunTin[playerid] = 0;
                s_GunTicks[playerid] = 0;
                SendServerMessage(playerid,"You have received a fractured substance. Cool it down to form it into an ingot.",MSG_TYPE_INFO);
                Gunsmith_Panel(playerid,"Idle");
            }
            else
            {
                s_GunTicks[playerid] = 0;
                Gunsmith_Fail(playerid,"a Fractured Substance");
            }

            continue;
        }

        s_GunTicks[playerid]--;
        Gunsmith_Panel(playerid,s_GunTicks[playerid] > 0 ? ("Refuelling") : ("Idle"));

        if (s_GunTicks[playerid] <= 0)
        {
            s_GunTicks[playerid] = 0;
            SendServerMessage(playerid,"The furnace seems to have died down - you should refill it.",MSG_TYPE_ERROR);
        }
    }
}

stock Gunsmith_JobTick()
{
    foreach (new playerid : Player)
    {
        if (s_GunJob[playerid] == GUN_NONE)
        {
            continue;
        }

        new left = s_GunJobEnd[playerid] - gettime();

        if (left <= 0)
        {
            Gunsmith_Finish(playerid);
            continue;
        }

        new text[48];
        format(text,sizeof(text),"~r~%d~w~ seconds left.",left);
        GameTextForPlayer(playerid,text,974,3);
    }
}

stock Gunsmith_Interact(playerid)
{
    if (!Player_IsReady(playerid) || !Inventory_IsLoaded(playerid) || !Gunsmith_InArea(playerid))
    {
        return;
    }

    if (Character_GetLevel(playerid) < GUN_MIN_LEVEL)
    {
        SendServerMessage(playerid,"Your level must at least be 3.",MSG_TYPE_ERROR);
        return;
    }

    switch (Gunsmith_Station(playerid))
    {
        case E_GUN_STATION_COAL:
        {
            Gunsmith_Coal(playerid);
        }
        case E_GUN_STATION_LUMBER:
        {
            Gunsmith_Lumber(playerid);
        }
        case E_GUN_STATION_FURNACE:
        {
            Gunsmith_Furnace(playerid);
        }
        case E_GUN_STATION_COOLING:
        {
            Gunsmith_Cooling(playerid);
        }
        case E_GUN_STATION_BASEMENT:
        {
            Gunsmith_Basement(playerid);
        }
    }
}

stock Gunsmith_Basement(playerid)
{
    if (Inventory_FindExtra(playerid,E_ITEM_EXTRA_GUNPART) == INV_ROW_NONE)
    {
        SendServerMessage(playerid,"You don't have a gunpart.",MSG_TYPE_ERROR);
        return;
    }

    if (Weapons_Get(playerid,E_GUN_SLOT_HAND) != 0)
    {
        SendServerMessage(playerid,"You can't create a weapon whilst you already have one equipped.",MSG_TYPE_ERROR);
        return;
    }

    if (s_GunJob[playerid] != GUN_NONE)
    {
        SendServerMessage(playerid,"You are already crafting a weapon or ammo.",MSG_TYPE_ERROR);
        return;
    }

    SetTimerEx("Gunsmith_MenuDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
}

static Gunsmith_Menu(playerid)
{
    yield 1;

    if (s_GunMenu[playerid])
    {
        return;
    }

    s_GunMenu[playerid] = true;
    new token = Account_GetToken(playerid), title[96], response[DIALOG_RESPONSE];
    format(title,sizeof(title),"Select the weapon you want to produce. - Weapon Parts: %d",Inventory_GetExtraTotal(playerid,E_ITEM_EXTRA_GUNPART) > 0 ? Inventory_GetExtraTotal(playerid,E_ITEM_EXTRA_GUNPART) : 0);
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,title,"Weapon\tAmount\nRevolver\t4 Gunparts\nShotgun\t6 Gunparts\nSawed off Shotgun\t6 Gunparts\nRifle\t8 Gunparts\nSniper\t8 Gunparts\nPistol Ammo\t3 Gunparts\nShotgun Ammo\t4 Gunparts\nRifle Ammo\t5 Gunparts\n","Select","Cancel");
    s_GunMenu[playerid] = false;

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
    {
        return;
    }

    Gunsmith_Start(playerid,response[DIALOG_RESPONSE_LISTITEM]);
}

static Gunsmith_Reset(playerid)
{
    s_GunProgress[playerid] = 0;
    s_GunCopper[playerid] = 0;
    s_GunTin[playerid] = 0;
    s_GunTicks[playerid] = 0;
    s_GunInside[playerid] = false;
    s_GunMenu[playerid] = false;
    Gunsmith_JobReset(playerid);
}

static Gunsmith_Cancel(playerid)
{
    if (s_GunJob[playerid] != GUN_NONE)
    {
        Gunsmith_RefundOffline(Character_GetId(playerid),s_GunRecipes[s_GunJob[playerid]][E_GUN_RECIPE_PARTS]);
    }

    Gunsmith_Reset(playerid);
}

/**
 *                        __  __  __                            __
 *                       |  \|  \|  \                          |  |
 *      _______  ______  | $$| $$| $$____    ______    _______ | $$   __   _______
 *     /       \|      \ | $$| $$| $$    \  |      \  /       \| $$  /  \ /       |
 *    |  $$$$$$$ \$$$$$$\| $$| $$| $$$$$$$\  \$$$$$$\|  $$$$$$$| $$_/  $$|  $$$$$$$
 *    | $$      /      $$| $$| $$| $$  | $$ /      $$| $$      | $$   $$  \$$    |
 *    | $$_____|  $$$$$$$| $$| $$| $$__/ $$|  $$$$$$$| $$_____ | $$$$$$\  _\$$$$$$|
 *     \$$     \\$$    $$| $$| $$| $$    $$ \$$    $$ \$$     \| $$  \$$\|       $$
 *      \$$$$$$$ \$$$$$$$ \$$ \$$ \$$$$$$$   \$$$$$$$  \$$$$$$$ \$$   \$$ \$$$$$$$
 *
 */
public Gunsmith_MenuDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Gunsmith_Menu(playerid);
    }

    return 1;
}

Timer_Declare(Gunsmith_FurnaceTimer)
{

    Gunsmith_FurnaceTick();
    return 1;
}

Timer_Declare(Gunsmith_JobTimer)
{

    Gunsmith_JobTick();
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
    for (new i = 0;i < GUN_STATIONS;i++)
    {
        new text[96];
        format(text,sizeof(text),"%s\n{DEDEDE}Press ~k~~SNEAK_ABOUT~ to use.",s_GunStationNames[i]);
        CreateDynamic3DTextLabel(text,0x966C5DFF,s_GunStationPos[i][0],s_GunStationPos[i][1],s_GunStationPos[i][2],15.0);
    }

    Timer_Start(Gunsmith_FurnaceTimer,GUN_FURNACE_MS);
    Timer_Start(Gunsmith_JobTimer,GUN_COUNTDOWN_MS);
}

hook OnPlayerConnect(playerid)
{
    Gunsmith_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Gunsmith_Cancel(playerid);
}

hook Character_OnUnload(playerid,characterid)
{
    Gunsmith_Cancel(playerid);
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (newkeys & KEY_WALK)
    {
        Gunsmith_Interact(playerid);
    }
}

hook Tick_OnPlayerSecond(playerid)
{
    if (!Player_IsReady(playerid))
    {
        return;
    }

    new bool:inside = Gunsmith_InArea(playerid);

    if (inside && !s_GunInside[playerid])
    {
        s_GunInside[playerid] = true;
        ActionPanel_Show(playerid,E_ACTION_TYPE_GUN);
        ActionPanel_SetProgress(playerid,float(s_GunProgress[playerid]));
    }
    else if (!inside && s_GunInside[playerid])
    {
        s_GunInside[playerid] = false;
        ActionPanel_Hide(playerid);
    }
}
