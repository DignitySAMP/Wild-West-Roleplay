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
#define SELECT_INCR_HORIZONTAL (112.5)
#define SELECT_INCR_FIX (22.5)
#define SELECT_HEADER_ADJUST (5.0)
#define SELECT_ACCENT (0xD17F5EFF)
#define SELECT_DARK (0x111111FF)
#define SELECT_EMPTY_MODEL (18631)
#define SELECT_SHOW_DELAY_MS (1000)
#define SELECT_PARTS (6)
#define SELECT_BAR_PARTS (3)
#define SELECT_BAR_WIDTH (55.5)
#define SELECT_BAR_HEIGHT (6.0)
#define SELECT_EXP_PER_LEVEL (8)

#define SELECT_PART_NAME (0)
#define SELECT_PART_SKIN (1)
#define SELECT_PART_HOURS (2)
#define SELECT_PART_EXP (3)
#define SELECT_PART_EXPINFO (4)
#define SELECT_PART_POSSE (5)

static Text:s_SelectHeaderBox = Text:INVALID_TEXT_DRAW;
static Text:s_SelectHeaderText = Text:INVALID_TEXT_DRAW;
static Text:s_SelectBoxDraw[CHARACTER_SLOTS] = {Text:INVALID_TEXT_DRAW,...};
static Text:s_SelectBoxOutline[CHARACTER_SLOTS] = {Text:INVALID_TEXT_DRAW,...};
static Text:s_SelectBox[CHARACTER_SLOTS] = {Text:INVALID_TEXT_DRAW,...};
static Text:s_SelectSpawnText[CHARACTER_SLOTS] = {Text:INVALID_TEXT_DRAW,...};
static Text:s_SelectEmptyHeader[CHARACTER_SLOTS] = {Text:INVALID_TEXT_DRAW,...};
static Text:s_SelectEmptyButton[CHARACTER_SLOTS] = {Text:INVALID_TEXT_DRAW,...};
static Text:s_SelectEmptyText[CHARACTER_SLOTS] = {Text:INVALID_TEXT_DRAW,...};
static PlayerText:s_SelectParts[MAX_PLAYERS][CHARACTER_SLOTS][SELECT_PARTS];
static PlayerText:s_SelectBars[MAX_PLAYERS][CHARACTER_SLOTS][SELECT_BAR_PARTS];
static bool:s_SelectOpen[MAX_PLAYERS];
static bool:s_SelectBuilt[MAX_PLAYERS];

forward Character_LoadDeferred(playerid,token,slot);
forward Account_CheckDeferred(playerid,token);
forward Create_Begin(playerid);

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
static Float:Select_Offset(card)
{
    switch (card)
    {
        case 0:
        {
            return -SELECT_INCR_FIX;
        }
        case 1:
        {
            return SELECT_INCR_HORIZONTAL;
        }
    }

    return SELECT_INCR_HORIZONTAL * 2.25;
}

static Text:Select_MakeBox(Float:x,Float:y,Float:lines,Float:right,colour)
{
    new Text:textdraw = TextDrawCreate(x,y,"usebox");
    TextDrawLetterSize(textdraw,0.0,lines);
    TextDrawTextSize(textdraw,right,0.0);
    TextDrawUseBox(textdraw,true);
    TextDrawBoxColor(textdraw,colour);
    TextDrawBackgroundColor(textdraw,0);
    return textdraw;
}

static Text:Select_MakeLabel(Float:x,Float:y,const text[],Float:letterX,Float:letterY,bool:centered)
{
    new Text:textdraw = TextDrawCreate(x,y,text);
    TextDrawLetterSize(textdraw,letterX,letterY);

    if (centered)
    {
        TextDrawAlignment(textdraw,TEXT_DRAW_ALIGN_CENTER);
    }

    TextDrawColor(textdraw,SELECT_ACCENT);
    TextDrawBackgroundColor(textdraw,51);
    return textdraw;
}

static Select_CreateGlobals()
{
    s_SelectHeaderBox = Select_MakeBox(400.0 - SELECT_HEADER_ADJUST,175.0,1.5,270.0 - SELECT_HEADER_ADJUST,0x111111AA);
    s_SelectHeaderText = Select_MakeLabel(276.0 - SELECT_HEADER_ADJUST,175.0,"Select your character",0.339333,1.288888,false);

    for (new card = 0;card < CHARACTER_SLOTS;card++)
    {
        new Float:offset = Select_Offset(card);

        s_SelectBoxDraw[card] = Select_MakeBox(277.3 + offset,199.3,12.55,156.0 + offset,SELECT_DARK);
        s_SelectBoxOutline[card] = Select_MakeBox(276.333343 + offset,201.025955,12.143404,157.000015 + offset,SELECT_ACCENT);
        s_SelectBox[card] = Select_MakeBox(275.0 + offset,202.270385,11.900192,158.0 + offset,SELECT_DARK);

        s_SelectSpawnText[card] = Select_MakeLabel(215.0 + offset,291.5,"Spawn",0.339333,1.288888,false);
        TextDrawTextSize(s_SelectSpawnText[card],255.0 + offset,10.0);
        TextDrawSetSelectable(s_SelectSpawnText[card],true);

        s_SelectEmptyHeader[card] = Select_MakeLabel(215.0 + offset,200.35556,"No character found",0.297666,1.272297,true);

        s_SelectEmptyButton[card] = TextDrawCreate(192.5 + offset,210.0,"usebox");
        TextDrawTextSize(s_SelectEmptyButton[card],50.0,65.0);
        TextDrawUseBox(s_SelectEmptyButton[card],true);
        TextDrawFont(s_SelectEmptyButton[card],TEXT_DRAW_FONT_MODEL_PREVIEW);
        TextDrawBackgroundColor(s_SelectEmptyButton[card],0);
        TextDrawBoxColor(s_SelectEmptyButton[card],0);
        TextDrawSetPreviewModel(s_SelectEmptyButton[card],SELECT_EMPTY_MODEL);
        TextDrawSetSelectable(s_SelectEmptyButton[card],true);

        s_SelectEmptyText[card] = Select_MakeLabel(215.0 + offset,270.0,"Click the ? to~n~create a new~n~character.",0.339333,1.288888,true);
    }
}

static PlayerText:Select_MakePlayerLabel(playerid,Float:x,Float:y,const text[],Float:letterX,Float:letterY,bool:centered)
{
    new PlayerText:textdraw = CreatePlayerTextDraw(playerid,x,y,text);
    PlayerTextDrawLetterSize(playerid,textdraw,letterX,letterY);

    if (centered)
    {
        PlayerTextDrawAlignment(playerid,textdraw,TEXT_DRAW_ALIGN_CENTER);
    }

    PlayerTextDrawColor(playerid,textdraw,SELECT_ACCENT);
    PlayerTextDrawBackgroundColor(playerid,textdraw,51);
    return textdraw;
}

static Select_CreateBar(playerid,card,Float:x,Float:y,Float:ratio)
{
    new PlayerText:back = CreatePlayerTextDraw(playerid,x,y,"_");
    PlayerTextDrawUseBox(playerid,back,true);
    PlayerTextDrawTextSize(playerid,back,x + SELECT_BAR_WIDTH - 4.0,0.0);
    PlayerTextDrawLetterSize(playerid,back,1.0,SELECT_BAR_HEIGHT / 10.0);
    PlayerTextDrawBoxColor(playerid,back,SELECT_ACCENT & 0xFF);

    new PlayerText:fill = CreatePlayerTextDraw(playerid,x + 1.2,y + 2.15,"_");
    PlayerTextDrawUseBox(playerid,fill,true);
    PlayerTextDrawTextSize(playerid,fill,x + SELECT_BAR_WIDTH - 5.5,0.0);
    PlayerTextDrawLetterSize(playerid,fill,1.0,SELECT_BAR_HEIGHT / 10.0 - 0.35);
    PlayerTextDrawBoxColor(playerid,fill,(SELECT_ACCENT & 0xFFFFFF00) | (0x66 & ((SELECT_ACCENT & 0xFF) / 2)));

    new PlayerText:fillBar = CreatePlayerTextDraw(playerid,x + 1.2,y + 2.15,"_");
    PlayerTextDrawUseBox(playerid,fillBar,ratio > 0.0);
    PlayerTextDrawTextSize(playerid,fillBar,(x - 3.0) + ((SELECT_BAR_WIDTH - 2.0) * ratio),0.0);
    PlayerTextDrawLetterSize(playerid,fillBar,1.0,SELECT_BAR_HEIGHT / 10.0 - 0.35);
    PlayerTextDrawBoxColor(playerid,fillBar,SELECT_ACCENT);

    s_SelectBars[playerid][card][0] = back;
    s_SelectBars[playerid][card][1] = fill;
    s_SelectBars[playerid][card][2] = fillBar;
}

static Select_DestroyPlayer(playerid)
{
    for (new card = 0;card < CHARACTER_SLOTS;card++)
    {
        for (new part = 0;part < SELECT_PARTS;part++)
        {
            if (s_SelectParts[playerid][card][part] != PlayerText:INVALID_TEXT_DRAW)
            {
                PlayerTextDrawDestroy(playerid,s_SelectParts[playerid][card][part]);
                s_SelectParts[playerid][card][part] = PlayerText:INVALID_TEXT_DRAW;
            }
        }

        for (new part = 0;part < SELECT_BAR_PARTS;part++)
        {
            if (s_SelectBars[playerid][card][part] != PlayerText:INVALID_TEXT_DRAW)
            {
                PlayerTextDrawDestroy(playerid,s_SelectBars[playerid][card][part]);
                s_SelectBars[playerid][card][part] = PlayerText:INVALID_TEXT_DRAW;
            }
        }
    }

    s_SelectBuilt[playerid] = false;
}

static Select_ResetIds(playerid)
{
    for (new card = 0;card < CHARACTER_SLOTS;card++)
    {
        for (new part = 0;part < SELECT_PARTS;part++)
        {
            s_SelectParts[playerid][card][part] = PlayerText:INVALID_TEXT_DRAW;
        }

        for (new part = 0;part < SELECT_BAR_PARTS;part++)
        {
            s_SelectBars[playerid][card][part] = PlayerText:INVALID_TEXT_DRAW;
        }
    }

    s_SelectBuilt[playerid] = false;
}

static Select_BuildPlayer(playerid)
{
    Select_DestroyPlayer(playerid);

    for (new card = 0;card < CHARACTER_SLOTS;card++)
    {
        if (!g_CharacterSlots[playerid][card][E_CHARACTER_ID])
        {
            continue;
        }

        new Float:offset = Select_Offset(card), level = g_CharacterSlots[playerid][card][E_CHARACTER_LEVEL], maxExp = SELECT_EXP_PER_LEVEL * level, left = g_CharacterSlots[playerid][card][E_CHARACTER_EXPLEFT], text[48];

        new PlayerText:name = Select_MakePlayerLabel(playerid,216.333374 + offset,200.35556,g_CharacterSlots[playerid][card][E_CHARACTER_NAME],0.297666,1.272297,true);
        s_SelectParts[playerid][card][SELECT_PART_NAME] = name;

        new PlayerText:skin = CreatePlayerTextDraw(playerid,145.0 + offset,210.0,"skinbox");
        PlayerTextDrawUseBox(playerid,skin,true);
        PlayerTextDrawBoxColor(playerid,skin,0);
        PlayerTextDrawBackgroundColor(playerid,skin,0);
        PlayerTextDrawFont(playerid,skin,TEXT_DRAW_FONT_MODEL_PREVIEW);
        PlayerTextDrawTextSize(playerid,skin,card == 0 ? 80.0 : 82.5,100.0);
        PlayerTextDrawSetPreviewModel(playerid,skin,g_CharacterSlots[playerid][card][E_CHARACTER_SKIN]);
        s_SelectParts[playerid][card][SELECT_PART_SKIN] = skin;

        format(text,sizeof(text),"Hours:~n~~w~%d",g_CharacterSlots[playerid][card][E_CHARACTER_HOURS]);
        s_SelectParts[playerid][card][SELECT_PART_HOURS] = Select_MakePlayerLabel(playerid,211.5 + offset,215.0,text,0.256333,1.081481,false);

        strcopy(text,g_CharacterSlots[playerid][card][E_CHARACTER_POSSE] == 1 ? ("Posse:~n~~w~Law Office") : ("Posse:~n~~w~Civilian"));
        s_SelectParts[playerid][card][SELECT_PART_POSSE] = Select_MakePlayerLabel(playerid,211.5 + offset,240.0,text,0.256333,1.081481,false);

        s_SelectParts[playerid][card][SELECT_PART_EXP] = Select_MakePlayerLabel(playerid,211.5 + offset,265.0,"Experience:",0.256333,1.081481,false);

        format(text,sizeof(text),"%d/%d",left,maxExp);
        new PlayerText:info = CreatePlayerTextDraw(playerid,228.0 + offset,279.5,text);
        PlayerTextDrawLetterSize(playerid,info,0.2,0.75);
        PlayerTextDrawColor(playerid,info,-1);
        PlayerTextDrawBackgroundColor(playerid,info,51);
        PlayerTextDrawSetOutline(playerid,info,1);
        s_SelectParts[playerid][card][SELECT_PART_EXPINFO] = info;

        new Float:ratio = maxExp > 0 ? float(left) / float(maxExp) : 0.0;

        if (ratio > 1.0)
        {
            ratio = 1.0;
        }

        Select_CreateBar(playerid,card,211.5 + offset,280.0,ratio);
    }

    s_SelectBuilt[playerid] = true;
}

stock bool:Select_IsOpen(playerid)
{
    return s_SelectOpen[playerid];
}

stock Select_Hide(playerid)
{
    TextDrawHideForPlayer(playerid,s_SelectHeaderBox);
    TextDrawHideForPlayer(playerid,s_SelectHeaderText);

    for (new card = 0;card < CHARACTER_SLOTS;card++)
    {
        TextDrawHideForPlayer(playerid,s_SelectBoxDraw[card]);
        TextDrawHideForPlayer(playerid,s_SelectBoxOutline[card]);
        TextDrawHideForPlayer(playerid,s_SelectBox[card]);
        TextDrawHideForPlayer(playerid,s_SelectSpawnText[card]);
        TextDrawHideForPlayer(playerid,s_SelectEmptyHeader[card]);
        TextDrawHideForPlayer(playerid,s_SelectEmptyButton[card]);
        TextDrawHideForPlayer(playerid,s_SelectEmptyText[card]);

        for (new part = 0;part < SELECT_PARTS;part++)
        {
            if (s_SelectParts[playerid][card][part] != PlayerText:INVALID_TEXT_DRAW)
            {
                PlayerTextDrawHide(playerid,s_SelectParts[playerid][card][part]);
            }
        }

        for (new part = 0;part < SELECT_BAR_PARTS;part++)
        {
            if (s_SelectBars[playerid][card][part] != PlayerText:INVALID_TEXT_DRAW)
            {
                PlayerTextDrawHide(playerid,s_SelectBars[playerid][card][part]);
            }
        }
    }
}

stock Select_Close(playerid)
{
    Select_Hide(playerid);
    Select_DestroyPlayer(playerid);

    if (s_SelectOpen[playerid])
    {
        s_SelectOpen[playerid] = false;
        CancelSelectTextDraw(playerid);
    }
}

stock Select_Open(playerid)
{
    Select_Close(playerid);
    Select_BuildPlayer(playerid);

    s_SelectOpen[playerid] = true;
    SelectTextDraw(playerid,ACCOUNT_CURSOR_COLOUR);
    TextDrawShowForPlayer(playerid,s_SelectHeaderBox);
    TextDrawShowForPlayer(playerid,s_SelectHeaderText);

    for (new card = 0;card < CHARACTER_SLOTS;card++)
    {
        TextDrawShowForPlayer(playerid,s_SelectBoxDraw[card]);
        TextDrawShowForPlayer(playerid,s_SelectBoxOutline[card]);
        TextDrawShowForPlayer(playerid,s_SelectBox[card]);

        if (!g_CharacterSlots[playerid][card][E_CHARACTER_ID])
        {
            TextDrawShowForPlayer(playerid,s_SelectEmptyHeader[card]);
            TextDrawShowForPlayer(playerid,s_SelectEmptyButton[card]);
            TextDrawShowForPlayer(playerid,s_SelectEmptyText[card]);
            continue;
        }

        TextDrawShowForPlayer(playerid,s_SelectSpawnText[card]);

        for (new part = 0;part < SELECT_PARTS;part++)
        {
            PlayerTextDrawShow(playerid,s_SelectParts[playerid][card][part]);
        }

        for (new part = 0;part < SELECT_BAR_PARTS;part++)
        {
            PlayerTextDrawShow(playerid,s_SelectBars[playerid][card][part]);
        }
    }
}

static Character_ReadSlot(index,target[e_CHARACTER_DATA])
{
    new empty[e_CHARACTER_DATA];
    target = empty;
    cache_get_value_name_int(index,"character_id",target[E_CHARACTER_ID]);
    cache_get_value_name_int(index,"account_id",target[E_CHARACTER_ACCOUNT]);
    cache_get_value_name(index,"character_name",target[E_CHARACTER_NAME],ACCOUNT_NAME_LEN);
    cache_get_value_name_int(index,"character_gender",target[E_CHARACTER_GENDER]);
    cache_get_value_name_int(index,"character_origin",target[E_CHARACTER_ORIGIN]);
    cache_get_value_name_int(index,"character_town",target[E_CHARACTER_TOWN]);
    cache_get_value_name_int(index,"character_skin",target[E_CHARACTER_SKIN]);
    cache_get_value_name_int(index,"character_age",target[E_CHARACTER_AGE]);
    cache_get_value_name_int(index,"character_level",target[E_CHARACTER_LEVEL]);
    cache_get_value_name_int(index,"character_hours",target[E_CHARACTER_HOURS]);
    cache_get_value_name_int(index,"character_expleft",target[E_CHARACTER_EXPLEFT]);
    cache_get_value_name_int(index,"character_spawnpoint",target[E_CHARACTER_SPAWNPOINT]);
    cache_get_value_name_float(index,"character_pos_x",target[E_CHARACTER_POS_X]);
    cache_get_value_name_float(index,"character_pos_y",target[E_CHARACTER_POS_Y]);
    cache_get_value_name_float(index,"character_pos_z",target[E_CHARACTER_POS_Z]);
    cache_get_value_name_int(index,"character_pos_interior",target[E_CHARACTER_POS_INTERIOR]);
    cache_get_value_name_int(index,"character_pos_vw",target[E_CHARACTER_POS_WORLD]);
    cache_get_value_name_int(index,"character_crashed",target[E_CHARACTER_CRASHED]);
    cache_get_value_name_int(index,"character_posse",target[E_CHARACTER_POSSE]);
}

stock Account_CharacterCheck(playerid)
{
    yield 1;

    new token = g_AccountToken[playerid];
    g_AccountStage[playerid] = E_ACCOUNT_STAGE_SELECT;
    g_AccountLoading[playerid] = false;
    Select_Close(playerid);

    await mysql_aquery_s(g_Mysql,str_format("SELECT * FROM characters WHERE account_id = %d ORDER BY character_id LIMIT %d",g_Account[playerid][E_ACCOUNT_ID],CHARACTER_SLOTS),false);

    if (!Account_IsCurrent(playerid,token) || g_AccountStage[playerid] != E_ACCOUNT_STAGE_SELECT)
    {
        return;
    }

    Account_ResetSlots(playerid);

    for (new i = 0,rows = cache_num_rows();i < rows && i < CHARACTER_SLOTS;i++)
    {
        Character_ReadSlot(i,g_CharacterSlots[playerid][i]);
    }

    SendClientMessage(playerid,COLOR_DEFAULT,"Please wait a moment while we load the character textdraws, they should appear shortly.");
    SendClientMessage(playerid,COLOR_DEFAULT," ");
    pawn_call_public("Account_OnCharactersLoaded","d",playerid);

    await task_ms(SELECT_SHOW_DELAY_MS);

    if (!Account_IsCurrent(playerid,token) || g_AccountStage[playerid] != E_ACCOUNT_STAGE_SELECT)
    {
        return;
    }

    Select_Open(playerid);
}

stock bool:Character_Select(playerid,slot)
{
    if (g_AccountStage[playerid] != E_ACCOUNT_STAGE_SELECT || g_AccountLoading[playerid])
    {
        return false;
    }

    if (slot < 0 || slot >= CHARACTER_SLOTS || !g_CharacterSlots[playerid][slot][E_CHARACTER_ID])
    {
        return false;
    }

    g_AccountLoading[playerid] = true;
    Select_Close(playerid);
    SetTimerEx("Character_LoadDeferred",0,false,"ddd",playerid,g_AccountToken[playerid],slot);
    return true;
}

static Character_Activate(playerid)
{
    g_AccountLoading[playerid] = false;
    g_AccountStage[playerid] = E_ACCOUNT_STAGE_PLAYING;
    g_AccountLogoutPermission[playerid] = false;
    Account_NewToken(playerid);

    Intro_Stop(playerid);
    TogglePlayerSpectating(playerid,false);
    SetPlayerName(playerid,g_Character[playerid][E_CHARACTER_NAME]);
    SetPlayerColor(playerid,ACCOUNT_CHARACTER_COLOUR);
    SetPlayerScore(playerid,g_Character[playerid][E_CHARACTER_LEVEL]);

    pawn_call_public("Character_OnLoad","dd",playerid,g_Character[playerid][E_CHARACTER_ID]);
    pawn_call_public("Player_OnReady","d",playerid);
}

static Character_Load(playerid,slot)
{
    yield 1;

    new token = g_AccountToken[playerid], characterid = g_CharacterSlots[playerid][slot][E_CHARACTER_ID];
    await mysql_aquery_s(g_Mysql,str_format("SELECT * FROM characters WHERE character_id = %d AND account_id = %d LIMIT 1",characterid,g_Account[playerid][E_ACCOUNT_ID]),false);

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (cache_num_rows() == 0)
    {
        g_AccountLoading[playerid] = false;
        SendServerMessage(playerid,"There isn't a character in the slot you selected.",MSG_TYPE_ERROR);
        Account_CharacterCheck(playerid);
        return;
    }

    Character_ReadSlot(0,g_Character[playerid]);
    Character_Activate(playerid);
}

stock Character_BeginLoad(playerid,slot)
{
    g_AccountLoading[playerid] = true;
    SetTimerEx("Character_LoadDeferred",0,false,"ddd",playerid,g_AccountToken[playerid],slot);
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
public Character_LoadDeferred(playerid,token,slot)
{
    if (Account_IsCurrent(playerid,token) && slot >= 0 && slot < CHARACTER_SLOTS && g_CharacterSlots[playerid][slot][E_CHARACTER_ID])
    {
        Character_Load(playerid,slot);
    }

    return 1;
}

public Account_CheckDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Account_CharacterCheck(playerid);
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
    Select_CreateGlobals();
}

hook OnPlayerConnect(playerid)
{
    s_SelectOpen[playerid] = false;
    Select_ResetIds(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    s_SelectOpen[playerid] = false;
    Select_DestroyPlayer(playerid);
}

hook OnPlayerClickTextDraw(playerid,Text:clickedid)
{
    if (!s_SelectOpen[playerid])
    {
        return;
    }

    if (clickedid == Text:INVALID_TEXT_DRAW)
    {
        SelectTextDraw(playerid,ACCOUNT_CURSOR_COLOUR);
        return;
    }

    for (new card = 0;card < CHARACTER_SLOTS;card++)
    {
        if (clickedid == s_SelectEmptyButton[card])
        {
            Select_Close(playerid);
            Create_Begin(playerid);
            return;
        }

        if (clickedid == s_SelectSpawnText[card])
        {
            Character_Select(playerid,card);
            return;
        }
    }
}
