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
#define NAMETAG_RANGE (15.0)
#define NAMETAG_HEIGHT (0.15)
#define NAMETAG_TEXT_LEN (144)
#define NAMETAG_NORMAL_COLOUR (0xCFCFCFFF)
#define NAMETAG_PAUSE "[PAUSED (/afklist)]"

static STREAMER_TAG_3D_TEXT_LABEL:s_NametagLabel[MAX_PLAYERS] = {STREAMER_TAG_3D_TEXT_LABEL:INVALID_STREAMER_ID,...};
static s_NametagText[MAX_PLAYERS][NAMETAG_TEXT_LEN];
static s_NametagColour[MAX_PLAYERS];

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
stock bool:Nametag_Exists(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && _:s_NametagLabel[playerid] != INVALID_STREAMER_ID && bool:IsValidDynamic3DTextLabel(s_NametagLabel[playerid]);
}

stock Nametag_GetLabel(playerid)
{
    return _:s_NametagLabel[playerid];
}

stock Nametag_GetText(playerid,dest[],size = sizeof(dest))
{
    strcopy(dest,s_NametagText[playerid],size);
}

stock Nametag_GetColour(playerid)
{
    return s_NametagColour[playerid];
}

stock bool:Nametag_Set(playerid,const text[],colour)
{
    if (!Nametag_Exists(playerid))
    {
        return false;
    }

    if (colour == s_NametagColour[playerid] && !strcmp(text,s_NametagText[playerid]))
    {
        return true;
    }

    strcopy(s_NametagText[playerid],text,NAMETAG_TEXT_LEN);
    s_NametagColour[playerid] = colour;
    UpdateDynamic3DTextLabelText(s_NametagLabel[playerid],colour,text);
    return true;
}

static Nametag_Compose(playerid,text[],size,&colour)
{
    new name[ACCOUNT_NAME_LEN], bool:paused = Player_IsPaused(playerid), prefix[32], line[64];
    Name_Display(playerid,name);
    colour = NAMETAG_NORMAL_COLOUR;
    prefix[0] = EOS;

    if (Afk_IsAfk(playerid))
    {
        strcopy(prefix,"[AFK]");
        colour = COLOR_RED;
    }
    else if (paused)
    {
        strcopy(prefix,NAMETAG_PAUSE);
        colour = COLOR_RED;
    }

    if (Injury_GetMode(playerid) != INJURY_MODE_NORMAL)
    {
        format(text,size,"%s\n(%d) %s",prefix,playerid,name);

        if (prefix[0] == EOS)
        {
            format(text,size,"(%d) %s",playerid,name);
        }

        colour = COLOR_RED;
        return;
    }

    if (Staff_IsOnDuty(playerid))
    {
        new tint[8];

        if (Account_GetId(playerid) == 1 || Account_GetId(playerid) == 2)
        {
            strcopy(tint,"855A83");
            strcopy(line,"(( OOC: Developer on Duty ))");

            if (!paused && !Afk_IsAfk(playerid))
            {
                colour = 0x855A83FF;
            }
        }
        else if (Staff_IsManager(playerid))
        {
            strcopy(tint,"AD2D2D");
            strcopy(line,"(( OOC: Manager on Duty ))");

            if (!paused && !Afk_IsAfk(playerid))
            {
                colour = 0xAD2D2DFF;
            }
        }
        else
        {
            strcopy(tint,"408040");
            strcopy(line,"(( OOC: Moderator on Duty ))");

            if (!paused && !Afk_IsAfk(playerid))
            {
                colour = 0x408040FF;
            }
        }

        if (prefix[0] != EOS)
        {
            format(text,size,"%s{%s}\n%s\n{[ (%d) %s ]}",prefix,tint,line,playerid,name);
        }
        else
        {
            format(text,size,"%s\n{[ (%d) %s ]}",line,playerid,name);
        }

        return;
    }

    if (prefix[0] != EOS)
    {
        format(text,size,"%s{DEDEDE}\n(%d) %s",prefix,playerid,name);
        return;
    }

    format(text,size,"(%d) %s",playerid,name);
}

public Nametag_Refresh(playerid)
{
    if (!Nametag_Exists(playerid) || !Player_IsReady(playerid))
    {
        return 0;
    }

    new text[NAMETAG_TEXT_LEN], colour;
    Nametag_Compose(playerid,text,sizeof(text),colour);
    return Nametag_Set(playerid,text,colour);
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
    ShowNameTags(false);
}

hook OnPlayerConnect(playerid)
{
    new name[MAX_PLAYER_NAME + 1], text[NAMETAG_TEXT_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(text,sizeof(text),"(%d) %s",playerid,name);
    s_NametagLabel[playerid] = CreateDynamic3DTextLabel(text,NAMETAG_NORMAL_COLOUR,0.0,0.0,NAMETAG_HEIGHT,NAMETAG_RANGE,playerid,INVALID_VEHICLE_ID,true);
    strcopy(s_NametagText[playerid],text,NAMETAG_TEXT_LEN);
    s_NametagColour[playerid] = NAMETAG_NORMAL_COLOUR;
}

hook OnPlayerDisconnect(playerid,reason)
{
    if (_:s_NametagLabel[playerid] != INVALID_STREAMER_ID)
    {
        DestroyDynamic3DTextLabel(s_NametagLabel[playerid]);
    }

    s_NametagLabel[playerid] = STREAMER_TAG_3D_TEXT_LABEL:INVALID_STREAMER_ID;
}

hook Player_OnReady(playerid)
{
    Nametag_Refresh(playerid);
}
