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
#define CREATE_TILE_ACCENT (0xD17F5EFF)
#define CREATE_TILE_INLINE (0x40404077)
#define CREATE_TILE_DARK (0x111111FF)
#define CREATE_STATIC_COUNT (7)
#define CREATE_PLAYER_COUNT (17)
#define CREATE_SHOW_DELAY_MS (1000)
#define CREATE_THUMB_INDEX (5)
#define CREATE_SKIN_PREVIEW (0)
#define CREATE_RACES (5)
#define CREATE_TOWNS (2)

enum _:E_CREATE_ROW
{
    E_CREATE_ROW_GENDER = 0,
    E_CREATE_ROW_RACE,
    E_CREATE_ROW_TOWN,
    E_CREATE_ROW_AGE,
}

static const s_CreateGenders[2][] = {"Male","Female"};
static const s_CreateRaces[CREATE_RACES][] = {"Caucasian","Hispanic","African","Asian","Native"};
static const s_CreateTowns[CREATE_TOWNS][] = {"Longcreek","Fremont"};
static const s_CreateRowLabels[4][] = {"Change your gender","Change your racial group","Change your place of birth","Change your starting age"};
static const s_CreateSkins[2][CREATE_RACES] =
{
    {95,58,183,210,128},
    {157,298,215,169,131}
};

static Text:s_CreateStatic[CREATE_STATIC_COUNT] = {Text:INVALID_TEXT_DRAW,...};
static PlayerText:s_CreatePlayer[MAX_PLAYERS][CREATE_PLAYER_COUNT];
static bool:s_CreateBuilt[MAX_PLAYERS];
static bool:s_CreateActive[MAX_PLAYERS];
static s_CreateGender[MAX_PLAYERS];
static s_CreateRace[MAX_PLAYERS];
static s_CreateTown[MAX_PLAYERS];
static s_CreateSkin[MAX_PLAYERS];
static s_CreateAge[MAX_PLAYERS];

forward Create_ShowDeferred(playerid,token);
forward Create_NameDeferred(playerid,token);
forward Create_DialogDeferred(playerid,token);

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
static Text:Create_MakeBox(Float:x,Float:y,Float:lines,Float:right,colour)
{
    new Text:textdraw = TextDrawCreate(x,y,"usebox");
    TextDrawLetterSize(textdraw,0.0,lines);
    TextDrawTextSize(textdraw,right,0.0);
    TextDrawUseBox(textdraw,true);
    TextDrawBoxColor(textdraw,colour);
    return textdraw;
}

static Create_MakeGlobals()
{
    s_CreateStatic[0] = Create_MakeBox(428.999969,181.225936,15.713763,235.000015,CREATE_TILE_DARK);
    s_CreateStatic[1] = Create_MakeBox(427.666748,182.885177,15.352868,236.333343,CREATE_TILE_ACCENT);
    s_CreateStatic[2] = Create_MakeBox(426.666839,184.129623,15.082916,237.666610,CREATE_TILE_DARK);

    s_CreateStatic[3] = TextDrawCreate(332.5,183.044403,"Create a character");
    TextDrawLetterSize(s_CreateStatic[3],0.363000,1.322074);
    TextDrawAlignment(s_CreateStatic[3],TEXT_DRAW_ALIGN_CENTER);
    TextDrawColor(s_CreateStatic[3],CREATE_TILE_ACCENT);
    TextDrawBackgroundColor(s_CreateStatic[3],51);

    s_CreateStatic[4] = TextDrawCreate(332.5,194.659301,"Below you can set up your new character");
    TextDrawLetterSize(s_CreateStatic[4],0.199666,0.994369);
    TextDrawAlignment(s_CreateStatic[4],TEXT_DRAW_ALIGN_CENTER);
    TextDrawColor(s_CreateStatic[4],CREATE_TILE_ACCENT);
    TextDrawBackgroundColor(s_CreateStatic[4],51);

    s_CreateStatic[5] = TextDrawCreate(405.0,301.85,"LD_CHAT:thumbup");
    TextDrawTextSize(s_CreateStatic[5],15.0,15.0);
    TextDrawColor(s_CreateStatic[5],CREATE_TILE_ACCENT);
    TextDrawUseBox(s_CreateStatic[5],true);
    TextDrawFont(s_CreateStatic[5],TEXT_DRAW_FONT_SPRITE_DRAW);
    TextDrawSetSelectable(s_CreateStatic[5],true);

    s_CreateStatic[6] = Create_MakeBox(375.666656,210.262893,-0.265638,289.666625,CREATE_TILE_ACCENT);
}

static Create_DestroyPlayer(playerid)
{
    for (new i = 0;i < CREATE_PLAYER_COUNT;i++)
    {
        if (s_CreatePlayer[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid,s_CreatePlayer[playerid][i]);
            s_CreatePlayer[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
    }

    s_CreateBuilt[playerid] = false;
}

static Create_ResetIds(playerid)
{
    for (new i = 0;i < CREATE_PLAYER_COUNT;i++)
    {
        s_CreatePlayer[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }

    s_CreateBuilt[playerid] = false;
}

static Create_ResetChoices(playerid)
{
    s_CreateGender[playerid] = 0;
    s_CreateRace[playerid] = 0;
    s_CreateTown[playerid] = 0;
    s_CreateSkin[playerid] = 0;
    s_CreateAge[playerid] = CHARACTER_AGE_MIN;
}

static Create_BuildPlayer(playerid)
{
    Create_DestroyPlayer(playerid);

    new PlayerText:skin = CreatePlayerTextDraw(playerid,220.0,205.0,"skin");
    PlayerTextDrawTextSize(playerid,skin,85.0,115.0);
    PlayerTextDrawUseBox(playerid,skin,true);
    PlayerTextDrawBackgroundColor(playerid,skin,0);
    PlayerTextDrawBoxColor(playerid,skin,0);
    PlayerTextDrawFont(playerid,skin,TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawSetPreviewModel(playerid,skin,128);
    PlayerTextDrawSetPreviewRot(playerid,skin,0.0,0.0,0.0,1.0);
    s_CreatePlayer[playerid][CREATE_SKIN_PREVIEW] = skin;

    for (new row = 0;row < 4;row++)
    {
        new Float:y = 220.0 + 20.0 * row, base = 1 + row * 4;

        new PlayerText:bar = CreatePlayerTextDraw(playerid,290.0,y,"usebox");
        PlayerTextDrawLetterSize(playerid,bar,0.0,1.25);
        PlayerTextDrawTextSize(playerid,bar,400.0,0.0);
        PlayerTextDrawUseBox(playerid,bar,true);
        PlayerTextDrawBoxColor(playerid,bar,CREATE_TILE_INLINE);
        s_CreatePlayer[playerid][base] = bar;

        new PlayerText:label = CreatePlayerTextDraw(playerid,345.0,y,s_CreateRowLabels[row]);
        PlayerTextDrawLetterSize(playerid,label,0.199666,0.994369);
        PlayerTextDrawColor(playerid,label,CREATE_TILE_ACCENT);
        PlayerTextDrawBackgroundColor(playerid,label,51);
        PlayerTextDrawAlignment(playerid,label,TEXT_DRAW_ALIGN_CENTER);
        s_CreatePlayer[playerid][base + 1] = label;

        new PlayerText:left = CreatePlayerTextDraw(playerid,285.0,y,"LD_BEAT:left");
        PlayerTextDrawTextSize(playerid,left,12.5,12.5);
        PlayerTextDrawColor(playerid,left,CREATE_TILE_ACCENT);
        PlayerTextDrawUseBox(playerid,left,true);
        PlayerTextDrawFont(playerid,left,TEXT_DRAW_FONT_SPRITE_DRAW);
        PlayerTextDrawSetSelectable(playerid,left,true);
        s_CreatePlayer[playerid][base + 2] = left;

        new PlayerText:right = CreatePlayerTextDraw(playerid,395.0,y,"LD_BEAT:right");
        PlayerTextDrawTextSize(playerid,right,12.5,12.5);
        PlayerTextDrawColor(playerid,right,CREATE_TILE_ACCENT);
        PlayerTextDrawUseBox(playerid,right,true);
        PlayerTextDrawFont(playerid,right,TEXT_DRAW_FONT_SPRITE_DRAW);
        PlayerTextDrawSetSelectable(playerid,right,true);
        s_CreatePlayer[playerid][base + 3] = right;
    }

    s_CreateBuilt[playerid] = true;
}

static Create_HidePanel(playerid)
{
    for (new i = 0;i < CREATE_STATIC_COUNT;i++)
    {
        TextDrawHideForPlayer(playerid,s_CreateStatic[i]);
    }

    for (new i = 0;i < CREATE_PLAYER_COUNT;i++)
    {
        if (s_CreatePlayer[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawHide(playerid,s_CreatePlayer[playerid][i]);
        }
    }
}

stock Create_Hide(playerid)
{
    Create_HidePanel(playerid);
}

stock Create_Close(playerid)
{
    Create_HidePanel(playerid);
    Create_DestroyPlayer(playerid);

    if (s_CreateActive[playerid])
    {
        s_CreateActive[playerid] = false;
        CancelSelectTextDraw(playerid);
    }
}

stock Character_GetOriginName(origin,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (origin >= 0 && origin < CREATE_RACES)
    {
        strcopy(dest,s_CreateRaces[origin],size);
    }
}

stock Character_GetTownName(town,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (town >= 0 && town < CREATE_TOWNS)
    {
        strcopy(dest,s_CreateTowns[town],size);
    }
}

stock Character_GetGenderName(gender,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (gender >= 0 && gender < 2)
    {
        strcopy(dest,s_CreateGenders[gender],size);
    }
}

stock Character_GetBaseSkin(gender,origin)
{
    if (gender < 0 || gender > 1 || origin < 0 || origin >= CREATE_RACES)
    {
        return 0;
    }

    return s_CreateSkins[gender][origin];
}

stock Create_UpdateSkin(playerid,bool:refresh = true)
{
    s_CreateSkin[playerid] = s_CreateSkins[s_CreateGender[playerid]][s_CreateRace[playerid]];

    if (refresh && s_CreateActive[playerid] && s_CreateBuilt[playerid])
    {
        new PlayerText:skin = s_CreatePlayer[playerid][CREATE_SKIN_PREVIEW];
        PlayerTextDrawHide(playerid,skin);
        PlayerTextDrawSetPreviewModel(playerid,skin,s_CreateSkin[playerid]);
        PlayerTextDrawShow(playerid,skin);
    }
}

static Create_SetLabel(playerid,row,const text[])
{
    if (s_CreateBuilt[playerid])
    {
        PlayerTextDrawSetString(playerid,s_CreatePlayer[playerid][2 + row * 4],text);
    }
}

stock Create_Arrow(playerid,row,step)
{
    switch (row)
    {
        case E_CREATE_ROW_GENDER:
        {
            s_CreateGender[playerid] = s_CreateGender[playerid] == 0 ? 1 : 0;
            Create_SetLabel(playerid,row,s_CreateGenders[s_CreateGender[playerid]]);
            Create_UpdateSkin(playerid);
        }
        case E_CREATE_ROW_RACE:
        {
            s_CreateRace[playerid] += step;

            if (s_CreateRace[playerid] < 0)
            {
                s_CreateRace[playerid] = CREATE_RACES - 1;
            }
            else if (s_CreateRace[playerid] >= CREATE_RACES)
            {
                s_CreateRace[playerid] = 0;
            }

            Create_SetLabel(playerid,row,s_CreateRaces[s_CreateRace[playerid]]);
            Create_UpdateSkin(playerid);
        }
        case E_CREATE_ROW_TOWN:
        {
            s_CreateTown[playerid] += step;

            if (s_CreateTown[playerid] < 0)
            {
                s_CreateTown[playerid] = CREATE_TOWNS - 1;
            }
            else if (s_CreateTown[playerid] >= CREATE_TOWNS)
            {
                s_CreateTown[playerid] = 0;
            }

            Create_SetLabel(playerid,row,s_CreateTowns[s_CreateTown[playerid]]);
        }
        case E_CREATE_ROW_AGE:
        {
            s_CreateAge[playerid] += step;

            if (s_CreateAge[playerid] < CHARACTER_AGE_MIN)
            {
                s_CreateAge[playerid] = CHARACTER_AGE_MAX;
            }
            else if (s_CreateAge[playerid] > CHARACTER_AGE_MAX)
            {
                s_CreateAge[playerid] = CHARACTER_AGE_MIN;
            }

            new line[16];
            format(line,sizeof(line),"Age: %d",s_CreateAge[playerid]);
            Create_SetLabel(playerid,row,line);
        }
    }
}

static Create_Show(playerid)
{
    Create_HidePanel(playerid);
    CancelSelectTextDraw(playerid);
    SelectTextDraw(playerid,ACCOUNT_CURSOR_COLOUR);

    for (new i = 0;i < CREATE_STATIC_COUNT;i++)
    {
        TextDrawShowForPlayer(playerid,s_CreateStatic[i]);
    }

    for (new i = 0;i < CREATE_PLAYER_COUNT;i++)
    {
        PlayerTextDrawShow(playerid,s_CreatePlayer[playerid][i]);
    }

    s_CreateActive[playerid] = true;
    s_CreateAge[playerid] = CHARACTER_AGE_MIN;
    SendServerMessage(playerid,"If you're unable to select the arrows or otherwise cannot complete the character creation, please use /charactercreate.",MSG_TYPE_INFO);
    SendServerMessage(playerid,"Sorry for the inconvenience!",MSG_TYPE_INFO);
    Create_UpdateSkin(playerid);
}

stock Create_Begin(playerid)
{
    g_AccountStage[playerid] = E_ACCOUNT_STAGE_CREATE;
    Create_ResetChoices(playerid);
    Create_BuildPlayer(playerid);
    SendServerMessage(playerid,"Loading creation panel, one moment ...",MSG_TYPE_WARN);
    SetTimerEx("Create_ShowDeferred",CREATE_SHOW_DELAY_MS,false,"dd",playerid,g_AccountToken[playerid]);
}

static Create_Abort(playerid)
{
    s_CreateActive[playerid] = false;
    Create_ResetChoices(playerid);
    Create_Close(playerid);
    Account_CharacterCheck(playerid);
}

forward Task:Character_Insert(playerid,const name[]);

#pragma warning push
#pragma warning disable 204
async Task:Character_Insert(playerid,const name[])
{
    new token = g_AccountToken[playerid];
    await mysql_aquery_s(g_Mysql,str_format("INSERT IGNORE INTO characters (account_id, character_name, character_gender, character_origin, character_town, character_skin, character_age, character_level, character_expleft) VALUES (%d, '%e', %d, %d, %d, %d, %d, 1, %d)",g_Account[playerid][E_ACCOUNT_ID],name,s_CreateGender[playerid],s_CreateRace[playerid],s_CreateTown[playerid],s_CreateSkin[playerid],s_CreateAge[playerid],SELECT_EXP_PER_LEVEL),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return async -1;
    }

    new errorid = mysql_errno(g_Mysql);

    if (errorid != 0)
    {
        Log_Error("account","character insert failed for player %d (errno %d)",playerid,errorid);
        return async -1;
    }

    if (cache_affected_rows() == 0)
    {
        return async 0;
    }

    return async cache_insert_id();
}
#pragma warning pop

static Create_NameFlow(playerid)
{
    yield 1;

    new token = g_AccountToken[playerid], response[DIALOG_RESPONSE], error = 0;

    for (;;)
    {
        switch (error)
        {
            case 0:
            {
                await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_INPUT,"Character: Name Selection","Enter your character's name.","Continue","Cancel");
            }
            case 1:
            {
                await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_INPUT,"{DEDEDE}Character: Name Selection","{DEDEDE}Enter your character's name.\n{C23838}ERROR:{DEDEDE} This name already exists.","Continue","Cancel");
            }
            default:
            {
                await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_INPUT,"{DEDEDE}Character: Name Selection","{DEDEDE}Enter your character's name.\n{C23838}ERROR:{DEDEDE} This name is not a roleplaying name.\n\nExample: \"Firstname_Lastname\".","Continue","Cancel");
            }
        }

        if (!Account_IsCurrent(playerid,token) || g_AccountStage[playerid] != E_ACCOUNT_STAGE_CREATE || !s_CreateActive[playerid])
        {
            return;
        }

        if (!response[DIALOG_RESPONSE_RESPONSE])
        {
            error = 2;
            continue;
        }

        PlayerPlaySound(playerid,ACCOUNT_CONFIRM_SOUND,0.0,0.0,0.0);

        if (!Account_IsRoleplayName(response[DIALOG_RESPONSE_INPUTTEXT]))
        {
            error = 2;
            continue;
        }

        new characterid = await Character_Insert(playerid,response[DIALOG_RESPONSE_INPUTTEXT]);

        if (!Account_IsCurrent(playerid,token) || g_AccountStage[playerid] != E_ACCOUNT_STAGE_CREATE)
        {
            return;
        }

        if (characterid == 0)
        {
            error = 1;
            continue;
        }

        if (characterid < 0)
        {
            error = 2;
            continue;
        }

        new line[160];
        format(line,sizeof(line),"[CREATE] (%d) %s (%d: %s) has registered a new character.",playerid,response[DIALOG_RESPONSE_INPUTTEXT],g_Account[playerid][E_ACCOUNT_ID],g_Account[playerid][E_ACCOUNT_NAME]);
        s_CreateActive[playerid] = false;
        Create_ResetChoices(playerid);
        Create_Close(playerid);
        g_AccountNewCharacter[playerid] = true;
        pawn_call_public("Character_OnCreated","dd",playerid,characterid);
        SendModeratorWarning(line,MOD_WARNING_LOW);
        Account_CharacterCheck(playerid);
        return;
    }
}

static Create_DialogFlow(playerid)
{
    yield 1;

    new token = g_AccountToken[playerid], response[DIALOG_RESPONSE];
    Create_HidePanel(playerid);
    CancelSelectTextDraw(playerid);

    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"Character Creation - Gender","Male\nFemale","Select","Exit");

    if (!Account_IsCurrent(playerid,token) || !s_CreateActive[playerid])
    {
        return;
    }

    if (!response[DIALOG_RESPONSE_RESPONSE])
    {
        Create_Abort(playerid);
        return;
    }

    s_CreateGender[playerid] = response[DIALOG_RESPONSE_LISTITEM];

    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"Character Creation - Race","Caucasian\nHispanic\nAfrican\nAsian\nNative","Select","Exit");

    if (!Account_IsCurrent(playerid,token) || !s_CreateActive[playerid])
    {
        return;
    }

    if (!response[DIALOG_RESPONSE_RESPONSE])
    {
        Create_Abort(playerid);
        return;
    }

    s_CreateRace[playerid] = response[DIALOG_RESPONSE_LISTITEM];
    Create_UpdateSkin(playerid,false);

    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"Character Creation - Starting Town","Longcreek\nFremont","Select","Exit");

    if (!Account_IsCurrent(playerid,token) || !s_CreateActive[playerid])
    {
        return;
    }

    if (!response[DIALOG_RESPONSE_RESPONSE])
    {
        Create_Abort(playerid);
        return;
    }

    s_CreateTown[playerid] = response[DIALOG_RESPONSE_LISTITEM];

    new prompt[160] = "Input your character's age below (8-80).";

    for (;;)
    {
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_INPUT,"Character Creation - Age",prompt,"Select","Exit");

        if (!Account_IsCurrent(playerid,token) || !s_CreateActive[playerid])
        {
            return;
        }

        if (!response[DIALOG_RESPONSE_RESPONSE])
        {
            Create_Abort(playerid);
            return;
        }

        new text[129];
        strcopy(text,response[DIALOG_RESPONSE_INPUTTEXT]);

        if (!strlen(text))
        {
            strcopy(prompt,"You need to put an age in for your character.\n\nInput your character's age below (8-80).");
            continue;
        }

        if (!Account_IsNumeric(text))
        {
            strcopy(prompt,"Your character's age needs to be a numeric value.\n\nInput your character's age below (8-80).");
            continue;
        }

        if (strval(text) < CHARACTER_AGE_MIN || strval(text) > CHARACTER_AGE_MAX)
        {
            strcopy(prompt,"Your character can not be younger than 8 or older than 80.\n\nInput your character's age below (8-80).");
            continue;
        }

        s_CreateAge[playerid] = strval(text);
        break;
    }

    new overview[256];
    format(overview,sizeof(overview),"Current Creation Stats:\n\nGender: %s\nRace: %s\nStarting Town: %s\nAge: %d\n\nIf you want to finish character creation and name your character, click \"Continue\" or if you want to start over, click \"Cancel\".",s_CreateGenders[s_CreateGender[playerid]],s_CreateRaces[s_CreateRace[playerid]],s_CreateTowns[s_CreateTown[playerid]],s_CreateAge[playerid]);
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"Character Creation - Overview",overview,"Continue","Cancel");

    if (!Account_IsCurrent(playerid,token) || !s_CreateActive[playerid])
    {
        return;
    }

    if (!response[DIALOG_RESPONSE_RESPONSE])
    {
        Create_Abort(playerid);
        return;
    }

    Create_NameFlow(playerid);
}

stock bool:Create_StartDialogs(playerid)
{
    if (!s_CreateActive[playerid] || g_AccountStage[playerid] != E_ACCOUNT_STAGE_CREATE)
    {
        return false;
    }

    SetTimerEx("Create_DialogDeferred",0,false,"dd",playerid,g_AccountToken[playerid]);
    return true;
}

stock Create_AskName(playerid)
{
    SetTimerEx("Create_NameDeferred",0,false,"dd",playerid,g_AccountToken[playerid]);
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
public Create_ShowDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token) && g_AccountStage[playerid] == E_ACCOUNT_STAGE_CREATE && s_CreateBuilt[playerid])
    {
        Create_Show(playerid);
    }

    return 1;
}

public Create_NameDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token) && g_AccountStage[playerid] == E_ACCOUNT_STAGE_CREATE && s_CreateActive[playerid])
    {
        Create_NameFlow(playerid);
    }

    return 1;
}

public Create_DialogDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token) && g_AccountStage[playerid] == E_ACCOUNT_STAGE_CREATE && s_CreateActive[playerid])
    {
        Create_DialogFlow(playerid);
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

hook OnGameModeInit()
{
    Create_MakeGlobals();
}

hook OnPlayerConnect(playerid)
{
    s_CreateActive[playerid] = false;
    Create_ResetIds(playerid);
    Create_ResetChoices(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    s_CreateActive[playerid] = false;
    Create_DestroyPlayer(playerid);
}

hook OnPlayerClickTextDraw(playerid,Text:clickedid)
{
    if (!s_CreateActive[playerid])
    {
        return;
    }

    if (clickedid == Text:INVALID_TEXT_DRAW)
    {
        SelectTextDraw(playerid,ACCOUNT_CURSOR_COLOUR);
        return;
    }

    if (clickedid == s_CreateStatic[CREATE_THUMB_INDEX])
    {
        Create_AskName(playerid);
    }
}

hook OnPlayerClickPlayerTextDraw(playerid,PlayerText:playertextid)
{
    if (!s_CreateActive[playerid] || !s_CreateBuilt[playerid])
    {
        return;
    }

    if (playertextid == PlayerText:INVALID_TEXT_DRAW)
    {
        SelectTextDraw(playerid,ACCOUNT_CURSOR_COLOUR);
        return;
    }

    for (new row = 0;row < 4;row++)
    {
        if (playertextid == s_CreatePlayer[playerid][3 + row * 4])
        {
            Create_Arrow(playerid,row,-1);
            return;
        }

        if (playertextid == s_CreatePlayer[playerid][4 + row * 4])
        {
            Create_Arrow(playerid,row,1);
            return;
        }
    }
}
