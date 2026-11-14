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
#define PICKER_ROWS (2)
#define PICKER_COLUMNS (6)
#define PICKER_PAGE (12)
#define PICKER_CAPTION_LEN (64)
#define PICKER_GAP_X (56.5)
#define PICKER_GAP_Y (63.5)
#define PICKER_SELECT_COLOUR (0xFF0000FF)
#define PICKER_UNSELECT_COLOUR (0x464646FF)
#define PICKER_DOUBLE_MS (200)
#define PICKER_ROTATE_STEP (10.0)
#define PICKER_ZOOM_STEP (0.1)
#define PICKER_ZOOM_LIMIT (5.0)
#define PICKER_SCROLL_HEIGHT (108.0)
#define PICKER_DEFAULT_RZ (-45.0)
#define PICKER_NONE (-1)

enum e_PICKER_ITEM
{
    E_PICKER_MODEL,
    E_PICKER_CAPTION[PICKER_CAPTION_LEN],
    Float:E_PICKER_RX,
    Float:E_PICKER_RY,
    Float:E_PICKER_RZ,
    Float:E_PICKER_ZOOM
}

enum
{
    PICKER_TD_SCROLL_UP,
    PICKER_TD_SCROLL_DOWN,
    PICKER_TD_LEFT,
    PICKER_TD_RIGHT,
    PICKER_TD_CENTER,
    PICKER_TD_ROTATE_LEFT,
    PICKER_TD_ROTATE_RIGHT,
    PICKER_TD_ZOOM_IN,
    PICKER_TD_ZOOM_OUT,
    PICKER_TD_SLOT
}

forward Picker_EmptyDeferred(playerid);

static List:s_PickerItems[MAX_PLAYERS];
static List:s_PickerStage[MAX_PLAYERS];
static Task:s_PickerTask[MAX_PLAYERS];
static bool:s_PickerOpen[MAX_PLAYERS];
static bool:s_PickerDual[MAX_PLAYERS];
static bool:s_PickerSilent[MAX_PLAYERS];
static s_PickerPage[MAX_PLAYERS];
static s_PickerSelected[MAX_PLAYERS];
static s_PickerLastClick[MAX_PLAYERS];
static PlayerText:s_PickerFrame[MAX_PLAYERS][8];
static PlayerText:s_PickerButtons[MAX_PLAYERS][6];
static PlayerText:s_PickerHeader[MAX_PLAYERS];
static PlayerText:s_PickerButtonText[MAX_PLAYERS][2];
static PlayerText:s_PickerPageText[MAX_PLAYERS];
static PlayerText:s_PickerScroll[MAX_PLAYERS];
static PlayerText:s_PickerSlots[MAX_PLAYERS][PICKER_PAGE][3];
static PlayerText:s_PickerArrows[MAX_PLAYERS][4];
static PlayerText:s_PickerValues[MAX_PLAYERS][2];

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
stock bool:Picker_IsOpen(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_PickerOpen[playerid];
}

stock Picker_GetPage(playerid)
{
    return s_PickerPage[playerid];
}

stock Picker_GetSelected(playerid)
{
    return s_PickerSelected[playerid];
}

stock Picker_GetCount(playerid)
{
    return list_valid(s_PickerItems[playerid]) ? list_size(s_PickerItems[playerid]) : 0;
}

stock Picker_GetPages(playerid)
{
    new count = Picker_GetCount(playerid);
    return (count + PICKER_PAGE - 1) / PICKER_PAGE;
}

stock bool:Picker_GetItem(playerid,index,item[e_PICKER_ITEM])
{
    if (!list_valid(s_PickerItems[playerid]) || index < 0 || index >= list_size(s_PickerItems[playerid]))
    {
        return false;
    }

    list_get_arr(s_PickerItems[playerid],index,item);
    return true;
}

stock Picker_Begin(playerid)
{
    if (list_valid(s_PickerStage[playerid]))
    {
        list_delete(s_PickerStage[playerid]);
    }

    s_PickerStage[playerid] = list_new();
}

stock Picker_Add(playerid,model,const caption[] = "",Float:rx = 0.0,Float:ry = 0.0,Float:rz = PICKER_DEFAULT_RZ,Float:zoom = 1.0)
{
    if (!list_valid(s_PickerStage[playerid]))
    {
        Picker_Begin(playerid);
    }

    new item[e_PICKER_ITEM];
    item[E_PICKER_MODEL] = model;
    strcopy(item[E_PICKER_CAPTION],caption,PICKER_CAPTION_LEN);
    item[E_PICKER_RX] = rx;
    item[E_PICKER_RY] = ry;
    item[E_PICKER_RZ] = rz;
    item[E_PICKER_ZOOM] = zoom;
    list_add_arr(s_PickerStage[playerid],item);
}

static PlayerText:Picker_Td(playerid,Float:x,Float:y,const text[],font,Float:lx,Float:ly,colour,bool:box = false,boxColour = 0,Float:tx = 0.0,Float:ty = 0.0,bool:selectable = false,align = 1)
{
    new PlayerText:id = CreatePlayerTextDraw(playerid,x,y,text);
    PlayerTextDrawFont(playerid,id,TEXT_DRAW_FONT:font);
    PlayerTextDrawLetterSize(playerid,id,lx,ly);
    PlayerTextDrawColor(playerid,id,colour);
    PlayerTextDrawSetShadow(playerid,id,0);
    PlayerTextDrawSetOutline(playerid,id,0);
    PlayerTextDrawBackgroundColor(playerid,id,255);
    PlayerTextDrawSetProportional(playerid,id,true);

    if (align != 1)
    {
        PlayerTextDrawAlignment(playerid,id,TEXT_DRAW_ALIGN:align);
    }

    if (box)
    {
        PlayerTextDrawUseBox(playerid,id,true);
        PlayerTextDrawBoxColor(playerid,id,boxColour);
    }

    PlayerTextDrawTextSize(playerid,id,tx,ty);

    if (selectable)
    {
        PlayerTextDrawSetSelectable(playerid,id,true);
    }

    return id;
}

static Picker_Drop(playerid,&PlayerText:id)
{
    if (id != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid,id);
        id = PlayerText:INVALID_TEXT_DRAW;
    }
}

static Picker_DropSlots(playerid)
{
    for (new slot = 0;slot < PICKER_PAGE;slot++)
    {
        for (new part = 0;part < 3;part++)
        {
            Picker_Drop(playerid,s_PickerSlots[playerid][slot][part]);
        }
    }

    for (new i = 0;i < 4;i++)
    {
        Picker_Drop(playerid,s_PickerArrows[playerid][i]);
    }

    for (new i = 0;i < 2;i++)
    {
        Picker_Drop(playerid,s_PickerValues[playerid][i]);
    }
}

static Picker_DropAll(playerid)
{
    Picker_DropSlots(playerid);
    Picker_Drop(playerid,s_PickerHeader[playerid]);
    Picker_Drop(playerid,s_PickerPageText[playerid]);
    Picker_Drop(playerid,s_PickerScroll[playerid]);

    for (new i = 0;i < 8;i++)
    {
        Picker_Drop(playerid,s_PickerFrame[playerid][i]);
    }

    for (new i = 0;i < 6;i++)
    {
        Picker_Drop(playerid,s_PickerButtons[playerid][i]);
    }

    for (new i = 0;i < 2;i++)
    {
        Picker_Drop(playerid,s_PickerButtonText[playerid][i]);
    }
}

static Picker_Frame(playerid)
{
    s_PickerFrame[playerid][0] = Picker_Td(playerid,144.0,143.0,"CONTENT_BOX",2,0.0,19.5,-1,true,175,501.0,0.0);
    s_PickerFrame[playerid][1] = Picker_Td(playerid,146.5,155.5,"LD_SPAC:WHITE",4,0.0,18.2,-1,true,150,351.5,130.0);
    s_PickerFrame[playerid][2] = Picker_Td(playerid,147.0,156.0,"LD_SPAC:BLACK",4,0.0,18.2,-1,true,150,340.5,129.0);
    s_PickerFrame[playerid][3] = Picker_Td(playerid,488.0,156.0,"LD_SPAC:BLACK",4,0.0,18.2,-1,true,150,9.5,129.0);
    s_PickerFrame[playerid][4] = Picker_Td(playerid,488.0,156.0,"LD_POOL:BALL",4,0.0,18.2,-1,true,150,9.5,9.5,true);
    s_PickerFrame[playerid][5] = Picker_Td(playerid,489.0,156.5,"LD_BEAT:UP",4,0.0,18.2,255,true,150,7.5,7.5);
    s_PickerFrame[playerid][6] = Picker_Td(playerid,488.0,275.5,"LD_POOL:BALL",4,0.0,18.2,-1,true,150,9.5,9.5,true);
    s_PickerFrame[playerid][7] = Picker_Td(playerid,489.0,277.0,"LD_BEAT:DOWN",4,0.0,18.2,255,true,150,7.5,7.5);

    for (new i = 0;i < 8;i++)
    {
        PlayerTextDrawShow(playerid,s_PickerFrame[playerid][i]);
    }
}

static Picker_Buttons(playerid,const left[],const right[])
{
    s_PickerDual[playerid] = right[0] != EOS;

    if (s_PickerDual[playerid])
    {
        s_PickerButtons[playerid][0] = Picker_Td(playerid,260.0,293.0,"LD_SPAC:WHITE",4,0.5,1.0,-1,false,0,55.0,18.0,true);
        s_PickerButtons[playerid][1] = Picker_Td(playerid,260.5,293.5,"LD_SPAC:BLACK",4,0.5,1.0,-1,false,0,54.0,17.0);
        s_PickerButtons[playerid][2] = Picker_Td(playerid,325.0,293.0,"LD_SPAC:WHITE",4,0.5,1.0,-1,false,0,55.0,18.0,true);
        s_PickerButtons[playerid][3] = Picker_Td(playerid,325.5,293.5,"LD_SPAC:BLACK",4,0.5,1.0,-1,false,0,54.0,17.0);
        s_PickerButtonText[playerid][0] = Picker_Td(playerid,287.5,297.0,left,2,0.1399,0.8999,-1,false,0,0.0,480.0,false,2);
        s_PickerButtonText[playerid][1] = Picker_Td(playerid,352.5,297.0,right,2,0.1399,0.8999,-1,false,0,0.0,480.0,false,2);
    }
    else
    {
        s_PickerButtons[playerid][4] = Picker_Td(playerid,290.5,293.0,"LD_SPAC:WHITE",4,0.5,1.0,-1,false,0,55.0,18.0,true);
        s_PickerButtons[playerid][5] = Picker_Td(playerid,291.0,293.5,"LD_SPAC:BLACK",4,0.5,1.0,-1,false,0,54.0,17.0);
        s_PickerButtonText[playerid][0] = Picker_Td(playerid,318.0,297.0,left,2,0.1399,0.8999,-1,false,0,0.0,480.0,false,2);
    }

    for (new i = 0;i < 6;i++)
    {
        if (s_PickerButtons[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawShow(playerid,s_PickerButtons[playerid][i]);
        }
    }

    for (new i = 0;i < 2;i++)
    {
        if (s_PickerButtonText[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawShow(playerid,s_PickerButtonText[playerid][i]);
        }
    }
}

static Picker_Scroll(playerid)
{
    Picker_Drop(playerid,s_PickerScroll[playerid]);
    new pages = Picker_GetPages(playerid);

    if (pages <= 1)
    {
        return;
    }

    new Float:height = PICKER_SCROLL_HEIGHT / float(pages), Float:y = 166.5 + height * float(s_PickerPage[playerid]);
    s_PickerScroll[playerid] = Picker_Td(playerid,489.0,y,"LD_SPAC:WHITE",4,0.0,18.2,-16776961,true,150,7.5,height);
    PlayerTextDrawShow(playerid,s_PickerScroll[playerid]);
}

static Picker_Value(playerid,which,Float:value)
{
    new text[16];
    format(text,sizeof(text),"%0.1f",value);
    PlayerTextDrawSetString(playerid,s_PickerValues[playerid][which],text);
    PlayerTextDrawShow(playerid,s_PickerValues[playerid][which]);
}

static Picker_Arrows(playerid,slot)
{
    new row = slot / PICKER_COLUMNS, column = slot % PICKER_COLUMNS, Float:ox = float(column) * PICKER_GAP_X, Float:oy = float(row) * PICKER_GAP_Y;

    for (new i = 0;i < 4;i++)
    {
        Picker_Drop(playerid,s_PickerArrows[playerid][i]);
    }

    for (new i = 0;i < 2;i++)
    {
        Picker_Drop(playerid,s_PickerValues[playerid][i]);
    }

    s_PickerArrows[playerid][0] = Picker_Td(playerid,157.5 + ox,204.0 + oy,"LD_BEAT:LEFT",4,0.5,1.0,-156,false,0,10.0,10.0,true);
    s_PickerArrows[playerid][1] = Picker_Td(playerid,185.0 + ox,204.0 + oy,"LD_BEAT:RIGHT",4,0.5,1.0,-156,false,0,10.0,10.0,true);
    s_PickerArrows[playerid][2] = Picker_Td(playerid,191.5 + ox,171.0 + oy,"LD_BEAT:UP",4,0.5,1.0,-156,false,0,10.0,10.0,true);
    s_PickerArrows[playerid][3] = Picker_Td(playerid,191.5 + ox,193.0 + oy,"LD_BEAT:DOWN",4,0.5,1.0,-156,false,0,10.0,10.0,true);
    s_PickerValues[playerid][0] = Picker_Td(playerid,176.5 + ox,204.5 + oy,"0.0",2,0.1399,0.8999,-156,false,0,640.0,480.0,false,2);
    s_PickerValues[playerid][1] = Picker_Td(playerid,196.5 + ox,182.0 + oy,"0.0",2,0.1399,0.8999,-156,false,0,640.0,480.0,false,2);

    for (new i = 0;i < 4;i++)
    {
        PlayerTextDrawShow(playerid,s_PickerArrows[playerid][i]);
    }

    new item[e_PICKER_ITEM];
    Picker_GetItem(playerid,s_PickerPage[playerid] * PICKER_PAGE + slot,item);
    Picker_Value(playerid,0,item[E_PICKER_RZ]);
    Picker_Value(playerid,1,item[E_PICKER_ZOOM]);
}

static Picker_Slots(playerid)
{
    Picker_DropSlots(playerid);
    new count = Picker_GetCount(playerid), first = s_PickerPage[playerid] * PICKER_PAGE;

    for (new slot = 0;slot < PICKER_PAGE && first + slot < count;slot++)
    {
        new item[e_PICKER_ITEM], row = slot / PICKER_COLUMNS, column = slot % PICKER_COLUMNS, Float:ox = float(column) * PICKER_GAP_X, Float:oy = float(row) * PICKER_GAP_Y;
        Picker_GetItem(playerid,first + slot,item);
        s_PickerSlots[playerid][slot][0] = Picker_Td(playerid,148.5 + ox,157.5 + oy,"LD_SPAC:WHITE",4,0.5,1.0,slot == s_PickerSelected[playerid] ? PICKER_SELECT_COLOUR : PICKER_UNSELECT_COLOUR,false,0,55.0,62.0,true);
        s_PickerSlots[playerid][slot][1] = Picker_Td(playerid,149.0 + ox,158.0 + oy,"MODEL",5,0.5,1.0,-1,false,0,54.0,61.0);
        PlayerTextDrawBackgroundColor(playerid,s_PickerSlots[playerid][slot][1],842150655);
        PlayerTextDrawSetPreviewModel(playerid,s_PickerSlots[playerid][slot][1],item[E_PICKER_MODEL]);
        PlayerTextDrawSetPreviewRot(playerid,s_PickerSlots[playerid][slot][1],item[E_PICKER_RX],item[E_PICKER_RY],item[E_PICKER_RZ],item[E_PICKER_ZOOM]);
        PlayerTextDrawShow(playerid,s_PickerSlots[playerid][slot][0]);
        PlayerTextDrawShow(playerid,s_PickerSlots[playerid][slot][1]);

        if (item[E_PICKER_CAPTION][0] != EOS)
        {
            s_PickerSlots[playerid][slot][2] = Picker_Td(playerid,153.5 + ox,161.5 + oy,item[E_PICKER_CAPTION],2,0.1399,0.8999,-1,true,0,201.5 + ox,0.0);
            PlayerTextDrawShow(playerid,s_PickerSlots[playerid][slot][2]);
        }
    }

    Picker_Arrows(playerid,s_PickerSelected[playerid]);
    new text[24];
    format(text,sizeof(text),"PAGE: %d/%d",s_PickerPage[playerid] + 1,Picker_GetPages(playerid));

    if (s_PickerPageText[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawSetString(playerid,s_PickerPageText[playerid],text);
    }
}

static Picker_Finish(playerid,bool:confirmed)
{
    new response[DIALOG_RESPONSE], index = s_PickerPage[playerid] * PICKER_PAGE + s_PickerSelected[playerid], item[e_PICKER_ITEM];
    response[DIALOG_RESPONSE_RESPONSE] = confirmed;
    response[DIALOG_RESPONSE_LISTITEM] = index;

    if (Picker_GetItem(playerid,index,item))
    {
        format(response[DIALOG_RESPONSE_INPUTTEXT],16,"%d",item[E_PICKER_MODEL]);
    }

    new Task:task = s_PickerTask[playerid];
    Picker_Close(playerid);

    if (task_valid(task))
    {
        task_set_result_arr(task,response);
    }
}

stock Picker_Close(playerid)
{
    if (!s_PickerOpen[playerid])
    {
        return;
    }

    s_PickerOpen[playerid] = false;
    s_PickerTask[playerid] = INVALID_TASK;
    Picker_DropAll(playerid);

    if (list_valid(s_PickerItems[playerid]))
    {
        list_delete(s_PickerItems[playerid]);
        s_PickerItems[playerid] = INVALID_LIST;
    }

    s_PickerSilent[playerid] = true;
    CancelSelectTextDraw(playerid);
}

public Picker_EmptyDeferred(playerid)
{
    new Task:task = s_PickerTask[playerid];

    if (!s_PickerOpen[playerid] && task_valid(task))
    {
        new response[DIALOG_RESPONSE];
        s_PickerTask[playerid] = INVALID_TASK;
        task_set_result_arr(task,response);
    }

    return 1;
}

stock Task:Picker_Show(playerid,const title[],const left[] = "Select",const right[] = "Cancel")
{
    if (s_PickerOpen[playerid])
    {
        Picker_Finish(playerid,false);
    }

    new Task:task = task_new();
    s_PickerItems[playerid] = s_PickerStage[playerid];
    s_PickerStage[playerid] = INVALID_LIST;

    if (Picker_GetCount(playerid) == 0)
    {
        if (list_valid(s_PickerItems[playerid]))
        {
            list_delete(s_PickerItems[playerid]);
            s_PickerItems[playerid] = INVALID_LIST;
        }

        s_PickerTask[playerid] = task;
        SetTimerEx("Picker_EmptyDeferred",0,false,"d",playerid);
        return task;
    }

    s_PickerTask[playerid] = task;
    s_PickerSilent[playerid] = false;
    s_PickerOpen[playerid] = true;
    s_PickerPage[playerid] = 0;
    s_PickerSelected[playerid] = 0;
    s_PickerLastClick[playerid] = 0;
    Picker_Frame(playerid);
    Picker_Buttons(playerid,left,right);
    s_PickerHeader[playerid] = Picker_Td(playerid,144.0,143.0,title,2,0.1399,0.8999,-1,true,255,501.0,0.0);
    PlayerTextDrawShow(playerid,s_PickerHeader[playerid]);

    if (Picker_GetCount(playerid) > PICKER_PAGE)
    {
        s_PickerPageText[playerid] = Picker_Td(playerid,501.5,143.0,"Page: 1",2,0.1399,0.8999,-1,true,255,501.0,0.0,false,3);
        PlayerTextDrawShow(playerid,s_PickerPageText[playerid]);
    }

    Picker_Scroll(playerid);
    Picker_Slots(playerid);
    SelectTextDraw(playerid,PICKER_SELECT_COLOUR);
    return task;
}

static Picker_Turn(playerid,Float:rz,Float:zoom)
{
    new index = s_PickerPage[playerid] * PICKER_PAGE + s_PickerSelected[playerid], item[e_PICKER_ITEM], slot = s_PickerSelected[playerid];
    Picker_GetItem(playerid,index,item);

    if (rz != 0.0)
    {
        item[E_PICKER_RZ] += rz;

        if (item[E_PICKER_RZ] < -360.0 || item[E_PICKER_RZ] > 360.0)
        {
            item[E_PICKER_RZ] = 0.0;
        }
    }

    if (zoom != 0.0)
    {
        if ((zoom < 0.0 && item[E_PICKER_ZOOM] <= -PICKER_ZOOM_LIMIT) || (zoom > 0.0 && item[E_PICKER_ZOOM] >= PICKER_ZOOM_LIMIT))
        {
            return;
        }

        item[E_PICKER_ZOOM] += zoom;
    }

    list_set_arr(s_PickerItems[playerid],index,item);
    PlayerTextDrawSetPreviewRot(playerid,s_PickerSlots[playerid][slot][1],item[E_PICKER_RX],item[E_PICKER_RY],item[E_PICKER_RZ],item[E_PICKER_ZOOM]);
    PlayerTextDrawShow(playerid,s_PickerSlots[playerid][slot][1]);
    Picker_Value(playerid,0,item[E_PICKER_RZ]);
    Picker_Value(playerid,1,item[E_PICKER_ZOOM]);
}

static Picker_Select(playerid,slot)
{
    new previous = s_PickerSelected[playerid];
    PlayerTextDrawColor(playerid,s_PickerSlots[playerid][previous][0],PICKER_UNSELECT_COLOUR);
    PlayerTextDrawShow(playerid,s_PickerSlots[playerid][previous][0]);
    s_PickerSelected[playerid] = slot;
    PlayerTextDrawColor(playerid,s_PickerSlots[playerid][slot][0],PICKER_SELECT_COLOUR);
    PlayerTextDrawShow(playerid,s_PickerSlots[playerid][slot][0]);
    Picker_Arrows(playerid,slot);
}

static Picker_Move(playerid,direction)
{
    new page = s_PickerPage[playerid] + direction;

    if (page < 0 || page >= Picker_GetPages(playerid))
    {
        return;
    }

    s_PickerPage[playerid] = page;
    s_PickerSelected[playerid] = 0;
    Picker_Scroll(playerid);
    Picker_Slots(playerid);
}

stock Picker_Click(playerid,PlayerText:clicked)
{
    if (!s_PickerOpen[playerid])
    {
        return false;
    }

    if (clicked == s_PickerFrame[playerid][4])
    {
        Picker_Move(playerid,-1);
    }
    else if (clicked == s_PickerFrame[playerid][6])
    {
        Picker_Move(playerid,1);
    }
    else if (clicked == s_PickerButtons[playerid][0] || clicked == s_PickerButtons[playerid][4])
    {
        Picker_Finish(playerid,true);
    }
    else if (clicked == s_PickerButtons[playerid][2])
    {
        Picker_Finish(playerid,false);
    }
    else if (clicked == s_PickerArrows[playerid][0])
    {
        Picker_Turn(playerid,-PICKER_ROTATE_STEP,0.0);
    }
    else if (clicked == s_PickerArrows[playerid][1])
    {
        Picker_Turn(playerid,PICKER_ROTATE_STEP,0.0);
    }
    else if (clicked == s_PickerArrows[playerid][2])
    {
        Picker_Turn(playerid,0.0,-PICKER_ZOOM_STEP);
    }
    else if (clicked == s_PickerArrows[playerid][3])
    {
        Picker_Turn(playerid,0.0,PICKER_ZOOM_STEP);
    }
    else
    {
        for (new slot = 0;slot < PICKER_PAGE;slot++)
        {
            if (s_PickerSlots[playerid][slot][0] != PlayerText:INVALID_TEXT_DRAW && clicked == s_PickerSlots[playerid][slot][0])
            {
                new now = GetTickCount();

                if (slot == s_PickerSelected[playerid] && now - s_PickerLastClick[playerid] <= PICKER_DOUBLE_MS)
                {
                    Picker_Finish(playerid,true);
                }
                else
                {
                    Picker_Select(playerid,slot);
                    s_PickerLastClick[playerid] = now;
                }

                break;
            }
        }
    }

    return true;
}

stock Picker_Escape(playerid)
{
    if (s_PickerSilent[playerid])
    {
        s_PickerSilent[playerid] = false;
        return;
    }

    if (s_PickerOpen[playerid])
    {
        Picker_Finish(playerid,false);
    }
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

hook OnPlayerConnect(playerid)
{
    s_PickerOpen[playerid] = false;
    s_PickerSilent[playerid] = false;
    s_PickerTask[playerid] = INVALID_TASK;
    s_PickerItems[playerid] = INVALID_LIST;
    s_PickerStage[playerid] = INVALID_LIST;

    for (new i = 0;i < 6;i++)
    {
        s_PickerButtons[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }

    for (new i = 0;i < 8;i++)
    {
        s_PickerFrame[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }

    for (new i = 0;i < 2;i++)
    {
        s_PickerButtonText[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        s_PickerValues[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }

    for (new i = 0;i < 4;i++)
    {
        s_PickerArrows[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }

    for (new slot = 0;slot < PICKER_PAGE;slot++)
    {
        for (new part = 0;part < 3;part++)
        {
            s_PickerSlots[playerid][slot][part] = PlayerText:INVALID_TEXT_DRAW;
        }
    }

    s_PickerHeader[playerid] = PlayerText:INVALID_TEXT_DRAW;
    s_PickerPageText[playerid] = PlayerText:INVALID_TEXT_DRAW;
    s_PickerScroll[playerid] = PlayerText:INVALID_TEXT_DRAW;
}

hook OnPlayerDisconnect(playerid,reason)
{
    if (list_valid(s_PickerStage[playerid]))
    {
        list_delete(s_PickerStage[playerid]);
        s_PickerStage[playerid] = INVALID_LIST;
    }

    if (s_PickerOpen[playerid])
    {
        new response[DIALOG_RESPONSE], Task:task = s_PickerTask[playerid];
        s_PickerOpen[playerid] = false;
        s_PickerTask[playerid] = INVALID_TASK;

        if (list_valid(s_PickerItems[playerid]))
        {
            list_delete(s_PickerItems[playerid]);
            s_PickerItems[playerid] = INVALID_LIST;
        }

        if (task_valid(task))
        {
            task_set_result_arr(task,response);
        }
    }
}

hook OnPlayerDeath(playerid,killerid,WEAPON:reason)
{
    if (s_PickerOpen[playerid])
    {
        Picker_Finish(playerid,false);
    }
}

hook OnPlayerClickPlayerTextDraw(playerid,PlayerText:playertextid)
{
    Picker_Click(playerid,playertextid);
}

hook OnPlayerClickTextDraw(playerid,Text:clickedid)
{
    if (clickedid == Text:INVALID_TEXT_DRAW)
    {
        Picker_Escape(playerid);
    }
}
