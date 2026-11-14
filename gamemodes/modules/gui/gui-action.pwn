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
#define ACTION_LINE_COLOUR (0xD17F5EFF)
#define ACTION_DARK_COLOUR (0x111111FF)
#define ACTION_BOX_COLOUR (0x40404077)
#define ACTION_BAR_X (310.0)
#define ACTION_BAR_Y (350.0)
#define ACTION_BAR_WIDTH (120.0)
#define ACTION_BAR_HEIGHT (11.0)
#define ACTION_BAR_MAX (100.0)
#define ACTION_STATIC_COUNT (6)
#define ACTION_TEXT_LEN (160)
#define ACTION_NONE (-1)

enum _:E_ACTION_TYPE
{
    E_ACTION_TYPE_CATTLE = 0,
    E_ACTION_TYPE_DEER,
    E_ACTION_TYPE_FISH,
    E_ACTION_TYPE_MINING,
    E_ACTION_TYPE_LUMBER,
    E_ACTION_TYPE_GUN,
}

static const s_ActionTitles[6][32] =
{
    "Action Panel: Cattle Milking",
    "Action Panel: Hunting",
    "Action Panel: Fishing",
    "Action Panel: Mining",
    "Action Panel: Woodcutting",
    "Action Panel: Gun Creation"
};

static const s_ActionModels[6] = {19833,19315,1603,747,747,348};

static const s_ActionTexts[6][ACTION_TEXT_LEN] =
{
    "not initialised",
    "| Managed to skin 0 cow hide~n~| Managed to skin 0 cow meat~n~~n~~w~ + 0 exp for Hunting Level!",
    "@ Rapidly press ~k~~PED_LOCK_TARGET~ to reel in your catch.~n~Press ~k~~PED_FIREWEAPON~ to cancel action.",
    "@ Rapidly press  ~k~~PED_LOCK_TARGET~ to mine the rock.~n~Press ~k~~PED_FIREWEAPON~ to cancel action.",
    "@ Rapidly press  ~k~~PED_LOCK_TARGET~ to chop the tree.~n~Press ~k~~PED_FIREWEAPON~ to cancel action.",
    "@ Head to the point pickups and press LALT to do an activity.~n~Your goal is to keep the furnace burning."
};

static Text:s_ActionStatic[ACTION_STATIC_COUNT] = {Text:INVALID_TEXT_DRAW,...};
static PlayerText:s_ActionTitle[MAX_PLAYERS];
static PlayerText:s_ActionText[MAX_PLAYERS];
static PlayerText:s_ActionIcon[MAX_PLAYERS];
static PlayerText:s_ActionBar[MAX_PLAYERS][3];
static bool:s_ActionBuilt[MAX_PLAYERS];
static s_ActionMode[MAX_PLAYERS];
static Float:s_ActionProgress[MAX_PLAYERS];

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
static Text:Action_MakeBox(Float:x,Float:y,Float:lines,Float:right,colour)
{
    new Text:textdraw = TextDrawCreate(x,y,"box");
    TextDrawTextSize(textdraw,right,0.0);
    TextDrawLetterSize(textdraw,0.0,lines);
    TextDrawUseBox(textdraw,true);
    TextDrawBoxColor(textdraw,colour);
    return textdraw;
}

static Action_CreateGlobals()
{
    s_ActionStatic[0] = Action_MakeBox(247.5,319.0,10.25,432.0,ACTION_DARK_COLOUR);
    s_ActionStatic[1] = Action_MakeBox(249.0,321.25,9.8,430.25,ACTION_LINE_COLOUR);
    s_ActionStatic[2] = Action_MakeBox(250.0,322.5,9.5,429.0,ACTION_DARK_COLOUR);
    s_ActionStatic[3] = Action_MakeBox(310.0,366.5,4.0,425.0,ACTION_BOX_COLOUR);
    s_ActionStatic[4] = Action_MakeBox(253.0,340.0,7.0,305.0,ACTION_BOX_COLOUR);
    s_ActionStatic[5] = TextDrawCreate(309.0,337.5,"Action bar: shows current action progress");
    TextDrawLetterSize(s_ActionStatic[5],0.15,0.85);
    TextDrawColor(s_ActionStatic[5],ACTION_LINE_COLOUR);
    TextDrawBackgroundColor(s_ActionStatic[5],51);
    TextDrawFont(s_ActionStatic[5],TEXT_DRAW_FONT:1);
}

static stock Action_Label(playerid,Float:x,Float:y,const text[],Float:letterX,Float:letterY)
{
    new PlayerText:label = CreatePlayerTextDraw(playerid,x,y,text);
    PlayerTextDrawLetterSize(playerid,label,letterX,letterY);
    PlayerTextDrawColor(playerid,label,ACTION_LINE_COLOUR);
    PlayerTextDrawBackgroundColor(playerid,label,51);
    PlayerTextDrawFont(playerid,label,TEXT_DRAW_FONT:1);
    return _:label;
}

static stock Action_Build(playerid)
{
    s_ActionTitle[playerid] = PlayerText:Action_Label(playerid,251.0,320.0,"Action Panel",0.4,1.6);
    s_ActionText[playerid] = PlayerText:Action_Label(playerid,310.0,368.0,"| UNDEFINED",0.15,0.85);

    new PlayerText:icon = CreatePlayerTextDraw(playerid,252.5,340.0,"box");
    PlayerTextDrawTextSize(playerid,icon,52.5,62.5);
    PlayerTextDrawUseBox(playerid,icon,true);
    PlayerTextDrawBoxColor(playerid,icon,ACTION_BOX_COLOUR);
    PlayerTextDrawBackgroundColor(playerid,icon,0);
    PlayerTextDrawColor(playerid,icon,-1);
    PlayerTextDrawFont(playerid,icon,TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawSetPreviewModel(playerid,icon,18631);
    s_ActionIcon[playerid] = icon;

    new PlayerText:back = CreatePlayerTextDraw(playerid,ACTION_BAR_X,ACTION_BAR_Y,"_");
    PlayerTextDrawUseBox(playerid,back,true);
    PlayerTextDrawTextSize(playerid,back,ACTION_BAR_X + ACTION_BAR_WIDTH - 4.0,0.0);
    PlayerTextDrawLetterSize(playerid,back,1.0,ACTION_BAR_HEIGHT / 10.0);
    PlayerTextDrawBoxColor(playerid,back,ACTION_LINE_COLOUR & 0xFF);

    new PlayerText:fill = CreatePlayerTextDraw(playerid,ACTION_BAR_X + 1.2,ACTION_BAR_Y + 2.15,"_");
    PlayerTextDrawUseBox(playerid,fill,true);
    PlayerTextDrawTextSize(playerid,fill,ACTION_BAR_X + ACTION_BAR_WIDTH - 5.5,0.0);
    PlayerTextDrawLetterSize(playerid,fill,1.0,ACTION_BAR_HEIGHT / 10.0 - 0.35);
    PlayerTextDrawBoxColor(playerid,fill,(ACTION_LINE_COLOUR & 0xFFFFFF00) | (0x66 & ((ACTION_LINE_COLOUR & 0xFF) / 2)));

    new PlayerText:fillBar = CreatePlayerTextDraw(playerid,ACTION_BAR_X + 1.2,ACTION_BAR_Y + 2.15,"_");
    PlayerTextDrawTextSize(playerid,fillBar,ACTION_BAR_X - 3.0,0.0);
    PlayerTextDrawLetterSize(playerid,fillBar,1.0,ACTION_BAR_HEIGHT / 10.0 - 0.35);
    PlayerTextDrawBoxColor(playerid,fillBar,ACTION_LINE_COLOUR);

    s_ActionBar[playerid][0] = back;
    s_ActionBar[playerid][1] = fill;
    s_ActionBar[playerid][2] = fillBar;
    s_ActionBuilt[playerid] = true;
}

static Action_Destroy(playerid)
{
    if (!s_ActionBuilt[playerid])
    {
        return;
    }

    ActionPanel_Hide(playerid);
    PlayerTextDrawDestroy(playerid,s_ActionTitle[playerid]);
    PlayerTextDrawDestroy(playerid,s_ActionText[playerid]);
    PlayerTextDrawDestroy(playerid,s_ActionIcon[playerid]);

    for (new i = 0;i < 3;i++)
    {
        PlayerTextDrawDestroy(playerid,s_ActionBar[playerid][i]);
    }

    s_ActionBuilt[playerid] = false;
    s_ActionMode[playerid] = ACTION_NONE;
}

static Action_ShowBar(playerid,bool:show)
{
    for (new i = 0;i < 3;i++)
    {
        if (show)
        {
            PlayerTextDrawShow(playerid,s_ActionBar[playerid][i]);
        }
        else
        {
            PlayerTextDrawHide(playerid,s_ActionBar[playerid][i]);
        }
    }
}

stock ActionPanel_Hide(playerid)
{
    for (new i = 0;i < ACTION_STATIC_COUNT;i++)
    {
        TextDrawHideForPlayer(playerid,s_ActionStatic[i]);
    }

    if (s_ActionBuilt[playerid])
    {
        PlayerTextDrawHide(playerid,s_ActionTitle[playerid]);
        PlayerTextDrawHide(playerid,s_ActionText[playerid]);
        PlayerTextDrawHide(playerid,s_ActionIcon[playerid]);
        Action_ShowBar(playerid,false);
    }

    s_ActionMode[playerid] = ACTION_NONE;
}

stock bool:ActionPanel_Show(playerid,mode)
{
    if (mode < 0 || mode > E_ACTION_TYPE_GUN || !IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!s_ActionBuilt[playerid])
    {
        Action_Build(playerid);
    }

    ActionPanel_Hide(playerid);
    s_ActionMode[playerid] = mode;
    s_ActionProgress[playerid] = 0.0;
    PlayerTextDrawSetString(playerid,s_ActionTitle[playerid],s_ActionTitles[mode]);
    PlayerTextDrawSetPreviewModel(playerid,s_ActionIcon[playerid],s_ActionModels[mode]);
    PlayerTextDrawSetPreviewRot(playerid,s_ActionIcon[playerid],0.0,0.0,mode == E_ACTION_TYPE_CATTLE ? 140.0 : 40.0,1.0);
    PlayerTextDrawSetString(playerid,s_ActionText[playerid],s_ActionTexts[mode]);
    PlayerTextDrawTextSize(playerid,s_ActionBar[playerid][2],ACTION_BAR_X - 3.0,0.0);
    PlayerTextDrawUseBox(playerid,s_ActionBar[playerid][2],false);

    for (new i = 0;i < ACTION_STATIC_COUNT;i++)
    {
        TextDrawShowForPlayer(playerid,s_ActionStatic[i]);
    }

    PlayerTextDrawShow(playerid,s_ActionTitle[playerid]);
    PlayerTextDrawShow(playerid,s_ActionText[playerid]);
    PlayerTextDrawShow(playerid,s_ActionIcon[playerid]);
    Action_ShowBar(playerid,true);
    return true;
}

stock bool:ActionPanel_SetText(playerid,const text[],model = -1,bool:showBar = true)
{
    if (!s_ActionBuilt[playerid] || s_ActionMode[playerid] == ACTION_NONE)
    {
        return false;
    }

    PlayerTextDrawSetString(playerid,s_ActionText[playerid],text);

    if (model != -1)
    {
        PlayerTextDrawHide(playerid,s_ActionIcon[playerid]);
        PlayerTextDrawSetPreviewModel(playerid,s_ActionIcon[playerid],model);
        PlayerTextDrawShow(playerid,s_ActionIcon[playerid]);
    }

    Action_ShowBar(playerid,showBar);
    return true;
}

stock bool:ActionPanel_SetProgress(playerid,Float:value)
{
    if (!s_ActionBuilt[playerid] || s_ActionMode[playerid] == ACTION_NONE)
    {
        return false;
    }

    if (value < 0.0)
    {
        value = 0.0;
    }
    else if (value > ACTION_BAR_MAX)
    {
        value = ACTION_BAR_MAX;
    }

    s_ActionProgress[playerid] = value;
    PlayerTextDrawHide(playerid,s_ActionBar[playerid][2]);
    PlayerTextDrawUseBox(playerid,s_ActionBar[playerid][2],value > 0.0);
    PlayerTextDrawTextSize(playerid,s_ActionBar[playerid][2],(ACTION_BAR_X - 3.0) + ((ACTION_BAR_WIDTH - 2.0) / ACTION_BAR_MAX) * value,0.0);
    PlayerTextDrawShow(playerid,s_ActionBar[playerid][2]);
    return true;
}

stock ActionPanel_GetMode(playerid)
{
    return s_ActionMode[playerid];
}

stock Float:ActionPanel_GetProgress(playerid)
{
    return s_ActionProgress[playerid];
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
    Action_CreateGlobals();
}

hook OnPlayerConnect(playerid)
{
    s_ActionBuilt[playerid] = false;
    s_ActionMode[playerid] = ACTION_NONE;
    s_ActionProgress[playerid] = 0.0;
}

hook OnPlayerDisconnect(playerid,reason)
{
    Action_Destroy(playerid);
}

hook Character_OnUnload(playerid,characterid)
{
    Action_Destroy(playerid);
}
