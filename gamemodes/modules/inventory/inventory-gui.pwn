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
#define GUI_TILE_COLOUR (0xD17F5EFF)
#define GUI_TILE_BACK (0x111111FF)
#define GUI_BACKGROUND (0x111111AA)
#define GUI_JUMP (55.0)
#define GUI_SHIFT_Y (32.5)
#define GUI_EXAMINE_Y (215.0)
#define GUI_NAME_TILE (6)
#define GUI_NAME_EXAMINE (21)
#define GUI_OPEN_COOLDOWN (3)
#define GUI_TILES (9)

static Text:s_GuiStatic[5] = {Text:INVALID_TEXT_DRAW,...};
static Text:s_GuiExamine[8] = {Text:INVALID_TEXT_DRAW,...};
static PlayerText:s_GuiOutline[MAX_PLAYERS][GUI_TILES];
static PlayerText:s_GuiTile[MAX_PLAYERS][GUI_TILES];
static PlayerText:s_GuiModel[MAX_PLAYERS][GUI_TILES];
static PlayerText:s_GuiName[MAX_PLAYERS][GUI_TILES];
static PlayerText:s_GuiExamineModel[MAX_PLAYERS];
static PlayerText:s_GuiExamineName[MAX_PLAYERS];
static PlayerText:s_GuiExamineQty[MAX_PLAYERS];
static PlayerText:s_GuiUse[MAX_PLAYERS];
static PlayerText:s_GuiPageLabel[MAX_PLAYERS];
static bool:s_GuiBuilt[MAX_PLAYERS];
static bool:s_GuiOpen[MAX_PLAYERS];
static s_GuiPage[MAX_PLAYERS];
static s_GuiExamineUid[MAX_PLAYERS];
static s_GuiCooldown[MAX_PLAYERS];

forward Inventory_OptionsDeferred(playerid,token,uid);

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
static Text:Gui_StaticBox(Float:x,Float:y,Float:lines,Float:right,colour)
{
    new Text:textdraw = TextDrawCreate(x,y,"usebox");
    TextDrawLetterSize(textdraw,0.0,lines);
    TextDrawTextSize(textdraw,right,0.0);
    TextDrawUseBox(textdraw,true);
    TextDrawBoxColor(textdraw,colour);
    return textdraw;
}

static Text:Gui_StaticLabel(Float:x,Float:y,const text[],Float:letterX,Float:letterY,colour,bool:selectable = false,Float:sizeX = 0.0,Float:sizeY = 0.0)
{
    new Text:textdraw = TextDrawCreate(x,y,text);
    TextDrawLetterSize(textdraw,letterX,letterY);
    TextDrawColor(textdraw,colour);
    TextDrawFont(textdraw,TEXT_DRAW_FONT:2);
    TextDrawBackgroundColor(textdraw,51);

    if (selectable)
    {
        TextDrawTextSize(textdraw,sizeX,sizeY);
        TextDrawSetSelectable(textdraw,true);
    }

    return textdraw;
}

static Gui_CreateStatics()
{
    s_GuiStatic[0] = TextDrawCreate(408.0,135.0 + GUI_SHIFT_Y,"background");
    TextDrawLetterSize(s_GuiStatic[0],0.0,23.0);
    TextDrawTextSize(s_GuiStatic[0],571.0,0.0);
    TextDrawUseBox(s_GuiStatic[0],true);
    TextDrawBoxColor(s_GuiStatic[0],GUI_BACKGROUND);
    s_GuiStatic[1] = Gui_StaticLabel(409.0,140.5 + GUI_SHIFT_Y,"Provisions",0.333333,1.4,GUI_TILE_COLOUR);
    s_GuiStatic[2] = Gui_StaticLabel(493.0,140.5 + GUI_SHIFT_Y,"Inventory",0.333666,1.4,-1);
    s_GuiStatic[3] = TextDrawCreate(555.0,325.0 + GUI_SHIFT_Y,"LD_BEAT:right");
    TextDrawTextSize(s_GuiStatic[3],15.0,15.0);
    TextDrawColor(s_GuiStatic[3],GUI_BACKGROUND);
    TextDrawFont(s_GuiStatic[3],TEXT_DRAW_FONT:4);
    TextDrawBackgroundColor(s_GuiStatic[3],51);
    TextDrawSetSelectable(s_GuiStatic[3],true);
    s_GuiStatic[4] = TextDrawCreate(408.5,325.0 + GUI_SHIFT_Y,"LD_BEAT:left");
    TextDrawTextSize(s_GuiStatic[4],15.0,15.0);
    TextDrawColor(s_GuiStatic[4],GUI_BACKGROUND);
    TextDrawFont(s_GuiStatic[4],TEXT_DRAW_FONT:4);
    TextDrawBackgroundColor(s_GuiStatic[4],51);
    TextDrawSetSelectable(s_GuiStatic[4],true);

    s_GuiExamine[0] = Gui_StaticBox(516.666687 - 105.0,164.107406 + GUI_EXAMINE_Y,7.3,575.5 - 9.0,GUI_BACKGROUND);
    s_GuiExamine[1] = Gui_StaticLabel(522.5 - 57.0,167.0 + GUI_EXAMINE_Y,"Item Name:",0.2,0.8,GUI_TILE_COLOUR);
    s_GuiExamine[2] = Gui_StaticLabel(522.5 - 57.0,195.0 + GUI_EXAMINE_Y,"Item Quantity:",0.2,0.8,GUI_TILE_COLOUR);
    s_GuiExamine[3] = Gui_StaticBox(518.0 - 105.0,217.0 + GUI_EXAMINE_Y,1.25,470.0 - 9.0,0x40404077);
    s_GuiExamine[4] = Gui_StaticBox(570.0 - 105.0,217.0 + GUI_EXAMINE_Y,1.25,522.0 - 9.0,0x40404077);
    s_GuiExamine[5] = Gui_StaticBox(621.7 - 105.0,217.0 + GUI_EXAMINE_Y,1.25,573.7 - 9.0,0x40404077);
    s_GuiExamine[6] = Gui_StaticLabel(524.0 - 57.0,218.0 + GUI_EXAMINE_Y,"Options",0.2,0.8,GUI_TILE_COLOUR,true,510.0,10.0);
    s_GuiExamine[7] = Gui_StaticLabel(577.0 - 57.0,218.0 + GUI_EXAMINE_Y,"Drop",0.2,0.8,GUI_TILE_COLOUR,true,560.0,10.0);
}

static PlayerText:Gui_Label(playerid,Float:x,Float:y,const text[],Float:letterX,Float:letterY,colour)
{
    new PlayerText:label = CreatePlayerTextDraw(playerid,x,y,text);
    PlayerTextDrawLetterSize(playerid,label,letterX,letterY);
    PlayerTextDrawColor(playerid,label,colour);
    PlayerTextDrawFont(playerid,label,TEXT_DRAW_FONT:2);
    PlayerTextDrawBackgroundColor(playerid,label,51);
    return label;
}

static Gui_Build(playerid)
{
    if (s_GuiBuilt[playerid])
    {
        return;
    }

    for (new i = 0;i < GUI_TILES;i++)
    {
        new Float:column = float(i % 3) * GUI_JUMP, Float:row = float(i / 3) * GUI_JUMP;

        new PlayerText:outline = CreatePlayerTextDraw(playerid,517.666839 + column - 107.0,162.862945 + GUI_SHIFT_Y + row,"usebox");
        PlayerTextDrawLetterSize(playerid,outline,0.0,5.257822);
        PlayerTextDrawTextSize(playerid,outline,465.000122 + column - 7.0,0.0);
        PlayerTextDrawUseBox(playerid,outline,true);
        PlayerTextDrawBoxColor(playerid,outline,GUI_TILE_COLOUR);
        s_GuiOutline[playerid][i] = outline;

        new PlayerText:tile = CreatePlayerTextDraw(playerid,516.666687 + column - 105.0,164.107406 + GUI_SHIFT_Y + row,"usebox");
        PlayerTextDrawLetterSize(playerid,tile,0.0,4.983745);
        PlayerTextDrawTextSize(playerid,tile,465.666656 + column - 9.0,0.0);
        PlayerTextDrawUseBox(playerid,tile,true);
        PlayerTextDrawBoxColor(playerid,tile,GUI_TILE_BACK);
        s_GuiTile[playerid][i] = tile;

        new PlayerText:model = CreatePlayerTextDraw(playerid,469.0 + column - 57.0,164.0 + GUI_SHIFT_Y + row,"usebox");
        PlayerTextDrawFont(playerid,model,TEXT_DRAW_FONT_MODEL_PREVIEW);
        PlayerTextDrawLetterSize(playerid,model,0.0,4.983745);
        PlayerTextDrawTextSize(playerid,model,45.0,45.0);
        PlayerTextDrawUseBox(playerid,model,true);
        PlayerTextDrawBackgroundColor(playerid,model,0);
        PlayerTextDrawBoxColor(playerid,model,0);
        PlayerTextDrawSetPreviewModel(playerid,model,18631);
        PlayerTextDrawSetSelectable(playerid,model,true);
        s_GuiModel[playerid][i] = model;

        s_GuiName[playerid][i] = Gui_Label(playerid,475.0 + column - 57.0,200.0 + GUI_SHIFT_Y + row,"Item Name",0.19,0.6,GUI_TILE_COLOUR);
    }

    new PlayerText:preview = CreatePlayerTextDraw(playerid,469.0 - 57.0,164.0 + GUI_EXAMINE_Y,"usebox");
    PlayerTextDrawFont(playerid,preview,TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawLetterSize(playerid,preview,0.0,4.983745);
    PlayerTextDrawTextSize(playerid,preview,50.0,50.0);
    PlayerTextDrawUseBox(playerid,preview,true);
    PlayerTextDrawBackgroundColor(playerid,preview,0xD17F5E55);
    PlayerTextDrawBoxColor(playerid,preview,0);
    PlayerTextDrawSetPreviewModel(playerid,preview,18631);
    s_GuiExamineModel[playerid] = preview;
    s_GuiExamineName[playerid] = Gui_Label(playerid,522.5 - 57.0,175.0 + GUI_EXAMINE_Y,"item",0.19,1.0,0xDEDEDEFF);
    s_GuiExamineQty[playerid] = Gui_Label(playerid,522.5 - 57.0,202.0 + GUI_EXAMINE_Y,"1",0.19,1.0,0xDEDEDEFF);
    s_GuiUse[playerid] = Gui_Label(playerid,475.0 - 57.0,218.0 + GUI_EXAMINE_Y,"Use",0.2,0.8,GUI_TILE_COLOUR);
    PlayerTextDrawTextSize(playerid,s_GuiUse[playerid],460.0,10.0);
    PlayerTextDrawSetSelectable(playerid,s_GuiUse[playerid],true);
    s_GuiPageLabel[playerid] = Gui_Label(playerid,452.0,325.0 + GUI_SHIFT_Y,"PAGE 1 OF 1",0.333666,1.4,GUI_TILE_COLOUR);
    s_GuiBuilt[playerid] = true;
}

static Gui_Destroy(playerid)
{
    if (!s_GuiBuilt[playerid])
    {
        return;
    }

    for (new i = 0;i < GUI_TILES;i++)
    {
        PlayerTextDrawDestroy(playerid,s_GuiOutline[playerid][i]);
        PlayerTextDrawDestroy(playerid,s_GuiTile[playerid][i]);
        PlayerTextDrawDestroy(playerid,s_GuiModel[playerid][i]);
        PlayerTextDrawDestroy(playerid,s_GuiName[playerid][i]);
        s_GuiOutline[playerid][i] = s_GuiTile[playerid][i] = s_GuiModel[playerid][i] = s_GuiName[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }

    PlayerTextDrawDestroy(playerid,s_GuiExamineModel[playerid]);
    PlayerTextDrawDestroy(playerid,s_GuiExamineName[playerid]);
    PlayerTextDrawDestroy(playerid,s_GuiExamineQty[playerid]);
    PlayerTextDrawDestroy(playerid,s_GuiUse[playerid]);
    PlayerTextDrawDestroy(playerid,s_GuiPageLabel[playerid]);
    s_GuiExamineModel[playerid] = s_GuiExamineName[playerid] = s_GuiExamineQty[playerid] = s_GuiUse[playerid] = s_GuiPageLabel[playerid] = PlayerText:INVALID_TEXT_DRAW;
    s_GuiBuilt[playerid] = false;
}

static Gui_HideExamine(playerid)
{
    for (new i = 0;i < sizeof(s_GuiExamine);i++)
    {
        TextDrawHideForPlayer(playerid,s_GuiExamine[i]);
    }

    if (s_GuiBuilt[playerid])
    {
        PlayerTextDrawHide(playerid,s_GuiExamineModel[playerid]);
        PlayerTextDrawHide(playerid,s_GuiExamineName[playerid]);
        PlayerTextDrawHide(playerid,s_GuiExamineQty[playerid]);
        PlayerTextDrawHide(playerid,s_GuiUse[playerid]);
    }

    s_GuiExamineUid[playerid] = 0;
}

static Gui_UseLabel(playerid,item,dest[],size)
{
    switch (Item_GetType(item))
    {
        case E_ITEM_TYPE_UNDEFINED:
        {
            strcopy(dest,"Invalid",size);
        }
        case E_ITEM_TYPE_EQUIP:
        {
            strcopy(dest,Inventory_GetEquipped(playerid) == EQUIP_NONE ? ("Equip") : ("Unequip"),size);
        }
        case E_ITEM_TYPE_FOOD:
        {
            strcopy(dest,"Consume",size);
        }
        case E_ITEM_TYPE_SEED:
        {
            strcopy(dest,"Plant",size);
        }
        case E_ITEM_TYPE_JUNK, E_ITEM_TYPE_SELL:
        {
            strcopy(dest,"Sell",size);
        }
        case E_ITEM_TYPE_CRAFT:
        {
            strcopy(dest,"Craft",size);
        }
        default:
        {
            strcopy(dest,"Use",size);
        }
    }
}

static Gui_ShowExamine(playerid,index)
{
    new row[e_INV_ROW];

    if (!s_GuiBuilt[playerid] || !Inventory_GetRow(playerid,index,row))
    {
        Gui_HideExamine(playerid);
        return;
    }

    new name[ITEM_NAME_LEN + 12], label[12], text[16];
    s_GuiExamineUid[playerid] = row[E_INV_ROW_UID];
    PlayerTextDrawColor(playerid,s_GuiExamineName[playerid],Item_GetRarityColour(row[E_INV_ROW_ITEM]));
    Item_GetName(row[E_INV_ROW_ITEM],name);

    if (strlen(name) > GUI_NAME_EXAMINE)
    {
        strins(name," ...~n~...",GUI_NAME_EXAMINE,sizeof(name));
    }

    PlayerTextDrawSetString(playerid,s_GuiExamineName[playerid],name);
    valstr(text,row[E_INV_ROW_AMOUNT]);
    PlayerTextDrawSetString(playerid,s_GuiExamineQty[playerid],text);
    Gui_UseLabel(playerid,row[E_INV_ROW_ITEM],label,sizeof(label));
    PlayerTextDrawSetString(playerid,s_GuiUse[playerid],label);
    PlayerTextDrawSetPreviewModel(playerid,s_GuiExamineModel[playerid],Item_GetModel(row[E_INV_ROW_ITEM]));

    for (new i = 0;i < sizeof(s_GuiExamine);i++)
    {
        TextDrawShowForPlayer(playerid,s_GuiExamine[i]);
    }

    PlayerTextDrawShow(playerid,s_GuiExamineModel[playerid]);
    PlayerTextDrawShow(playerid,s_GuiExamineName[playerid]);
    PlayerTextDrawShow(playerid,s_GuiExamineQty[playerid]);
    PlayerTextDrawShow(playerid,s_GuiUse[playerid]);
    SelectTextDraw(playerid,-1);
}

static Gui_Render(playerid)
{
    new count = Inventory_GetCount(playerid), pages = count > GUI_TILES ? 2 : 1;

    if (s_GuiPage[playerid] >= pages)
    {
        s_GuiPage[playerid] = pages - 1;
    }

    for (new i = 0;i < GUI_TILES;i++)
    {
        new row[e_INV_ROW];

        if (!Inventory_GetRow(playerid,s_GuiPage[playerid] * GUI_TILES + i,row))
        {
            PlayerTextDrawHide(playerid,s_GuiOutline[playerid][i]);
            PlayerTextDrawHide(playerid,s_GuiTile[playerid][i]);
            PlayerTextDrawHide(playerid,s_GuiModel[playerid][i]);
            PlayerTextDrawHide(playerid,s_GuiName[playerid][i]);
            continue;
        }

        new name[ITEM_NAME_LEN];
        Item_GetName(row[E_INV_ROW_ITEM],name);

        if (strlen(name) > GUI_NAME_TILE)
        {
            strdel(name,GUI_NAME_TILE,sizeof(name));
            strins(name,"..",GUI_NAME_TILE,sizeof(name));
        }

        PlayerTextDrawHide(playerid,s_GuiModel[playerid][i]);
        PlayerTextDrawSetPreviewModel(playerid,s_GuiModel[playerid][i],Item_GetModel(row[E_INV_ROW_ITEM]));
        PlayerTextDrawHide(playerid,s_GuiName[playerid][i]);
        PlayerTextDrawColor(playerid,s_GuiName[playerid][i],Item_GetRarityColour(row[E_INV_ROW_ITEM]));
        PlayerTextDrawSetString(playerid,s_GuiName[playerid][i],name);
        PlayerTextDrawShow(playerid,s_GuiOutline[playerid][i]);
        PlayerTextDrawShow(playerid,s_GuiTile[playerid][i]);
        PlayerTextDrawShow(playerid,s_GuiModel[playerid][i]);
        PlayerTextDrawShow(playerid,s_GuiName[playerid][i]);
    }

    new label[16];
    format(label,sizeof(label),"PAGE %d OF %d",s_GuiPage[playerid] + 1,pages);
    PlayerTextDrawSetString(playerid,s_GuiPageLabel[playerid],label);
    PlayerTextDrawShow(playerid,s_GuiPageLabel[playerid]);

    if (pages == 2 && s_GuiPage[playerid] == 0)
    {
        TextDrawShowForPlayer(playerid,s_GuiStatic[3]);
    }
    else
    {
        TextDrawHideForPlayer(playerid,s_GuiStatic[3]);
    }

    if (s_GuiPage[playerid] == 1)
    {
        TextDrawShowForPlayer(playerid,s_GuiStatic[4]);
    }
    else
    {
        TextDrawHideForPlayer(playerid,s_GuiStatic[4]);
    }

    if (s_GuiExamineUid[playerid] != 0)
    {
        new index = Inventory_IndexOfUid(playerid,s_GuiExamineUid[playerid]);

        if (index == INV_ROW_NONE)
        {
            Gui_HideExamine(playerid);
        }
        else
        {
            Gui_ShowExamine(playerid,index);
        }
    }
}

stock Inventory_GuiClose(playerid)
{
    if (!s_GuiBuilt[playerid])
    {
        s_GuiOpen[playerid] = false;
        return;
    }

    for (new i = 0;i < GUI_TILES;i++)
    {
        PlayerTextDrawHide(playerid,s_GuiOutline[playerid][i]);
        PlayerTextDrawHide(playerid,s_GuiTile[playerid][i]);
        PlayerTextDrawHide(playerid,s_GuiModel[playerid][i]);
        PlayerTextDrawHide(playerid,s_GuiName[playerid][i]);
    }

    PlayerTextDrawHide(playerid,s_GuiPageLabel[playerid]);
    Gui_HideExamine(playerid);

    for (new i = 0;i < sizeof(s_GuiStatic);i++)
    {
        TextDrawHideForPlayer(playerid,s_GuiStatic[i]);
    }

    if (s_GuiOpen[playerid])
    {
        CancelSelectTextDraw(playerid);
    }

    s_GuiOpen[playerid] = false;
    Gui_Destroy(playerid);
}

stock bool:Inventory_GuiOpen(playerid,page = 0)
{
    if (!Player_IsReady(playerid))
    {
        return false;
    }

    if (!Inventory_IsLoaded(playerid))
    {
        SendServerMessage(playerid,"You don't seem to have any items to display. Try again in a moment to reload them.",MSG_TYPE_ERROR);
        return false;
    }

    Gui_Build(playerid);
    s_GuiPage[playerid] = page > 0 ? 1 : 0;
    s_GuiExamineUid[playerid] = 0;

    for (new i = 0;i < 3;i++)
    {
        TextDrawShowForPlayer(playerid,s_GuiStatic[i]);
    }

    s_GuiOpen[playerid] = true;
    Gui_Render(playerid);
    SelectTextDraw(playerid,GUI_TILE_COLOUR);
    return true;
}

stock bool:Inventory_GuiIsOpen(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_GuiOpen[playerid];
}

stock Inventory_GuiSelect(playerid,tile)
{
    if (!s_GuiOpen[playerid] || tile < 0 || tile >= GUI_TILES)
    {
        return;
    }

    new index = s_GuiPage[playerid] * GUI_TILES + tile;

    if (index >= Inventory_GetCount(playerid))
    {
        Gui_HideExamine(playerid);
        return;
    }

    Gui_ShowExamine(playerid,index);
}

stock Inventory_GuiSetPage(playerid,page)
{
    if (!s_GuiOpen[playerid])
    {
        return;
    }

    s_GuiPage[playerid] = page > 0 ? 1 : 0;
    Gui_HideExamine(playerid);
    Gui_Render(playerid);
}

static Options_Run(playerid,uid)
{
    yield 1;

    new token = Account_GetToken(playerid), index = Inventory_IndexOfUid(playerid,uid), row[e_INV_ROW];

    if (index == INV_ROW_NONE || !Inventory_GetRow(playerid,index,row))
    {
        return;
    }

    new title[96], name[ITEM_NAME_LEN], response[DIALOG_RESPONSE];
    Item_GetName(row[E_INV_ROW_ITEM],name);
    format(title,sizeof(title),"Options for item (%d) %s",row[E_INV_ROW_ITEM],name);
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,title,"Give Item\nSplit Item\nStack Item\nDiscard Item","Select","Cancel");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
    {
        return;
    }

    index = Inventory_IndexOfUid(playerid,uid);

    if (index == INV_ROW_NONE)
    {
        return;
    }

    switch (response[DIALOG_RESPONSE_LISTITEM])
    {
        case 0:
        {
            Inventory_Pass(playerid,index);
        }
        case 1:
        {
            Inventory_Split(playerid,index);
        }
        case 2:
        {
            SendServerMessage(playerid,"Disabled for bug fixing.",MSG_TYPE_ERROR);
        }
        case 3:
        {
            Inventory_ConfirmDiscard(playerid,index);
        }
    }
}

stock Inventory_GuiUse(playerid)
{
    new index = Inventory_IndexOfUid(playerid,s_GuiExamineUid[playerid]);

    if (index != INV_ROW_NONE)
    {
        Inventory_Use(playerid,index);
    }
}

stock Inventory_GuiOptions(playerid)
{
    if (s_GuiExamineUid[playerid] != 0)
    {
        SetTimerEx("Inventory_OptionsDeferred",0,false,"ddd",playerid,Account_GetToken(playerid),s_GuiExamineUid[playerid]);
    }
}

stock Inventory_GuiDrop(playerid)
{
    new index = Inventory_IndexOfUid(playerid,s_GuiExamineUid[playerid]);

    if (index != INV_ROW_NONE)
    {
        Inventory_Drop(playerid,index);
    }
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
public Inventory_OptionsDeferred(playerid,token,uid)
{
    if (Account_IsCurrent(playerid,token))
    {
        Options_Run(playerid,uid);
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

hook Inventory_OnChanged(playerid)
{
    if (playerid >= 0 && playerid < MAX_PLAYERS && s_GuiOpen[playerid] && s_GuiBuilt[playerid])
    {
        Gui_Render(playerid);
    }
}

hook OnGameModeInit()
{
    Gui_CreateStatics();
}

hook OnPlayerConnect(playerid)
{
    s_GuiBuilt[playerid] = false;
    s_GuiOpen[playerid] = false;
    s_GuiPage[playerid] = 0;
    s_GuiExamineUid[playerid] = 0;
    s_GuiCooldown[playerid] = 0;
}

hook OnPlayerDisconnect(playerid,reason)
{
    Gui_Destroy(playerid);
    s_GuiOpen[playerid] = false;
}

hook Character_OnUnload(playerid,characterid)
{
    Inventory_GuiClose(playerid);
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (!(newkeys & KEY_NO) || !Player_IsReady(playerid))
    {
        return;
    }

    if (s_GuiCooldown[playerid] >= gettime())
    {
        new line[96];
        format(line,sizeof(line),"You need to wait %d seconds before opening your inventory again.",s_GuiCooldown[playerid] - gettime());
        SendServerMessage(playerid,line,MSG_TYPE_WARN);
        return;
    }

    s_GuiCooldown[playerid] = gettime() + GUI_OPEN_COOLDOWN;
    new page = s_GuiPage[playerid];
    Inventory_GuiClose(playerid);
    Inventory_GuiOpen(playerid,page);
}

hook OnPlayerClickTextDraw(playerid,Text:clickedid)
{
    if (!s_GuiOpen[playerid])
    {
        return;
    }

    if (clickedid == Text:INVALID_TEXT_DRAW)
    {
        Inventory_GuiClose(playerid);
        return;
    }

    if (clickedid == s_GuiStatic[3])
    {
        Inventory_GuiSetPage(playerid,1);
    }
    else if (clickedid == s_GuiStatic[4])
    {
        Inventory_GuiSetPage(playerid,0);
    }
    else if (clickedid == s_GuiExamine[6])
    {
        Inventory_GuiOptions(playerid);
    }
    else if (clickedid == s_GuiExamine[7])
    {
        Inventory_GuiDrop(playerid);
    }
}

hook OnPlayerClickPlayerTextDraw(playerid,PlayerText:playertextid)
{
    if (!s_GuiOpen[playerid] || !s_GuiBuilt[playerid])
    {
        return;
    }

    if (playertextid == s_GuiUse[playerid])
    {
        Inventory_GuiUse(playerid);
        return;
    }

    for (new i = 0;i < GUI_TILES;i++)
    {
        if (playertextid == s_GuiModel[playerid][i])
        {
            Inventory_GuiSelect(playerid,i);
            return;
        }
    }
}
