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
static Text:s_PosterOutline[2];
static Text:s_PosterDivider[2];
static Text:s_PosterLine[3];
static PlayerText:s_PosterData[MAX_PLAYERS][3];
static bool:s_PosterShown[MAX_PLAYERS];

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
static Text:PosterGui_Box(Float:x,Float:y,Float:lines,Float:right,colour)
{
    new Text:textdraw = TextDrawCreate(x,y,"usebox");
    TextDrawLetterSize(textdraw,0.0,lines);
    TextDrawTextSize(textdraw,right,0.0);
    TextDrawUseBox(textdraw,true);
    TextDrawBoxColor(textdraw,colour);
    return textdraw;
}

static Text:PosterGui_Line(Float:x,Float:y,const text[],Float:letterX,Float:letterY,font)
{
    new Text:textdraw = TextDrawCreate(x,y,text);
    TextDrawLetterSize(textdraw,letterX,letterY);
    TextDrawAlignment(textdraw,TEXT_DRAW_ALIGN_CENTER);
    TextDrawColor(textdraw,572662527);
    TextDrawSetOutline(textdraw,0);
    TextDrawSetShadow(textdraw,0);
    TextDrawBackgroundColor(textdraw,51);
    TextDrawFont(textdraw,TEXT_DRAW_FONT:font);
    TextDrawSetProportional(textdraw,true);
    return textdraw;
}

static PlayerText:PosterGui_PlayerLine(playerid,Float:x,Float:y,const text[],Float:letterX,Float:letterY)
{
    new PlayerText:textdraw = CreatePlayerTextDraw(playerid,x,y,text);
    PlayerTextDrawLetterSize(playerid,textdraw,letterX,letterY);
    PlayerTextDrawAlignment(playerid,textdraw,TEXT_DRAW_ALIGN_CENTER);
    PlayerTextDrawColor(playerid,textdraw,572662527);
    PlayerTextDrawSetShadow(playerid,textdraw,0);
    PlayerTextDrawSetOutline(playerid,textdraw,0);
    PlayerTextDrawFont(playerid,textdraw,TEXT_DRAW_FONT:1);
    PlayerTextDrawSetProportional(playerid,textdraw,true);
    return textdraw;
}

stock PosterGui_Build()
{
    s_PosterOutline[0] = PosterGui_Box(403.333282,138.803665,23.085803,236.000030,572662527);
    s_PosterOutline[1] = PosterGui_Box(402.333343,140.048156,22.782508,237.000000,-1113289473);
    s_PosterDivider[0] = PosterGui_Box(390.0,182.4,-0.224484,247.0,572662527);
    s_PosterDivider[1] = PosterGui_Box(390.0,312.5,-0.224484,247.0,572662527);
    s_PosterLine[0] = PosterGui_Line(318.333465,138.548126,"WANTED",0.769000,3.217778,2);
    s_PosterLine[1] = PosterGui_Line(317.333343,163.851760,"DEAD or ALIVE",0.449999,1.600000,1);
    s_PosterLine[2] = PosterGui_Line(318.0,328.533477,"IF SIGHTED IMMEDIATELY CONTACT~n~LOCAL LAW ENFORCEMENT OFFICE",0.245333,0.820148,1);
}

static PosterGui_BuildPlayer(playerid)
{
    if (s_PosterData[playerid][0] != PlayerText:INVALID_TEXT_DRAW)
    {
        return;
    }

    new PlayerText:model = CreatePlayerTextDraw(playerid,265.0,198.0,"usebox");
    PlayerTextDrawTextSize(playerid,model,100.0,110.0);
    PlayerTextDrawUseBox(playerid,model,true);
    PlayerTextDrawFont(playerid,model,TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawBackgroundColor(playerid,model,0x00000000);
    PlayerTextDrawBoxColor(playerid,model,0x00000000);
    PlayerTextDrawColor(playerid,model,0xC29F82FF);
    PlayerTextDrawSetPreviewModel(playerid,model,28);
    s_PosterData[playerid][0] = model;
    s_PosterData[playerid][1] = PosterGui_PlayerLine(playerid,318.000122,313.600311,"$0",0.408999,1.409185);
    s_PosterData[playerid][2] = PosterGui_PlayerLine(playerid,318.000061,187.911087,"_",0.340333,1.226666);
}

stock PosterGui_Show(playerid,const name[],skin,price)
{
    PosterGui_BuildPlayer(playerid);

    new text[32], whole[16];
    Money_Delimit(price,whole);
    format(text,sizeof(text),"$%s",whole);
    PlayerTextDrawSetPreviewModel(playerid,s_PosterData[playerid][0],skin);
    PlayerTextDrawSetString(playerid,s_PosterData[playerid][1],text);
    PlayerTextDrawSetString(playerid,s_PosterData[playerid][2],name);

    for (new i = 0;i < 3;i++)
    {
        TextDrawShowForPlayer(playerid,s_PosterLine[i]);
        PlayerTextDrawShow(playerid,s_PosterData[playerid][i]);
    }

    for (new i = 0;i < 2;i++)
    {
        TextDrawShowForPlayer(playerid,s_PosterDivider[i]);
        TextDrawShowForPlayer(playerid,s_PosterOutline[i]);
    }

    s_PosterShown[playerid] = true;
    Streamer_ToggleAllItems(playerid,STREAMER_TYPE_3D_TEXT_LABEL,false);
    Streamer_Update(playerid,STREAMER_TYPE_3D_TEXT_LABEL);
    SelectTextDraw(playerid,0xFFFFFFFF);
}

stock PosterGui_Hide(playerid)
{
    if (!s_PosterShown[playerid])
    {
        return;
    }

    for (new i = 0;i < 3;i++)
    {
        TextDrawHideForPlayer(playerid,s_PosterLine[i]);

        if (s_PosterData[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawHide(playerid,s_PosterData[playerid][i]);
        }
    }

    for (new i = 0;i < 2;i++)
    {
        TextDrawHideForPlayer(playerid,s_PosterDivider[i]);
        TextDrawHideForPlayer(playerid,s_PosterOutline[i]);
    }

    s_PosterShown[playerid] = false;
    Streamer_ToggleAllItems(playerid,STREAMER_TYPE_3D_TEXT_LABEL,true);
    Streamer_Update(playerid,STREAMER_TYPE_3D_TEXT_LABEL);
}

stock bool:PosterGui_IsShown(playerid)
{
    return s_PosterShown[playerid];
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
    s_PosterShown[playerid] = false;

    for (new i = 0;i < 3;i++)
    {
        s_PosterData[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }
}

hook OnPlayerClickTextDraw(playerid,Text:clickedid)
{
    if (clickedid == Text:INVALID_TEXT_DRAW)
    {
        PosterGui_Hide(playerid);
    }
}
