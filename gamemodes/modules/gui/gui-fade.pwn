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
#define FADE_DELAY_MS (1000)
#define FADE_STEP_MS (250)
#define FADE_STEPS (13)

static const s_FadeColours[FADE_STEPS] =
{
    0x000000DD,
    0x000000CC,
    0x000000BB,
    0x000000AA,
    0x00000099,
    0x00000088,
    0x00000077,
    0x00000066,
    0x00000055,
    0x00000044,
    0x00000033,
    0x00000022,
    0x00000011
};

static PlayerText:s_FadeBox[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW,...};
static PlayerText:s_BlindBox[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW,...};
static bool:s_FadeActive[MAX_PLAYERS];
static bool:s_FadeFroze[MAX_PLAYERS];
static s_FadeStep[MAX_PLAYERS];

forward Fade_StepDeferred(playerid,token,step);

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
static PlayerText:Fade_MakeBox(playerid,colour)
{
    new PlayerText:box = CreatePlayerTextDraw(playerid,-20.0,0.0,"_");
    PlayerTextDrawUseBox(playerid,box,true);
    PlayerTextDrawBoxColor(playerid,box,colour);
    PlayerTextDrawAlignment(playerid,box,TEXT_DRAW_ALIGN:0);
    PlayerTextDrawBackgroundColor(playerid,box,0x000000FF);
    PlayerTextDrawFont(playerid,box,TEXT_DRAW_FONT:3);
    PlayerTextDrawLetterSize(playerid,box,1.0,52.2);
    PlayerTextDrawColor(playerid,box,0x000000FF);
    return box;
}

static Fade_DestroyFade(playerid)
{
    if (s_FadeBox[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid,s_FadeBox[playerid]);
        s_FadeBox[playerid] = PlayerText:INVALID_TEXT_DRAW;
    }
}

static Fade_DestroyBlind(playerid)
{
    if (s_BlindBox[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid,s_BlindBox[playerid]);
        s_BlindBox[playerid] = PlayerText:INVALID_TEXT_DRAW;
    }
}

stock Fade_Reset(playerid)
{
    Fade_DestroyFade(playerid);
    Fade_DestroyBlind(playerid);
    s_FadeActive[playerid] = false;
    s_FadeFroze[playerid] = false;
    s_FadeStep[playerid] = 0;
}

stock bool:Fade_In(playerid)
{
    if (!IsPlayerConnected(playerid) || s_FadeActive[playerid])
    {
        return false;
    }

    s_FadeActive[playerid] = true;
    s_FadeStep[playerid] = 0;
    s_FadeFroze[playerid] = IsPlayerControllable(playerid);

    if (s_FadeFroze[playerid])
    {
        TogglePlayerControllable(playerid,false);
    }

    SetTimerEx("Fade_StepDeferred",FADE_DELAY_MS,false,"ddd",playerid,Account_GetToken(playerid),0);
    return true;
}

stock bool:Fade_IsBlind(playerid)
{
    return s_BlindBox[playerid] != PlayerText:INVALID_TEXT_DRAW;
}

stock bool:Fade_IsActive(playerid)
{
    return s_FadeActive[playerid];
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
CMD:blindfold(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Fade_IsBlind(playerid))
    {
        s_BlindBox[playerid] = Fade_MakeBox(playerid,0x000000FF);
        PlayerTextDrawShow(playerid,s_BlindBox[playerid]);
        return 1;
    }

    Fade_DestroyBlind(playerid);
    return 1;
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
public Fade_StepDeferred(playerid,token,step)
{
    if (!Account_IsCurrent(playerid,token) || !s_FadeActive[playerid])
    {
        return 1;
    }

    if (step >= FADE_STEPS)
    {
        Fade_DestroyFade(playerid);

        if (s_FadeFroze[playerid])
        {
            TogglePlayerControllable(playerid,true);
        }

        s_FadeActive[playerid] = false;
        s_FadeFroze[playerid] = false;
        s_FadeStep[playerid] = 0;
        return 1;
    }

    Fade_DestroyFade(playerid);
    s_FadeBox[playerid] = Fade_MakeBox(playerid,s_FadeColours[step]);
    PlayerTextDrawShow(playerid,s_FadeBox[playerid]);
    s_FadeStep[playerid] = step + 1;
    SetTimerEx("Fade_StepDeferred",FADE_STEP_MS,false,"ddd",playerid,token,step + 1);
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

hook OnPlayerConnect(playerid)
{
    s_FadeBox[playerid] = PlayerText:INVALID_TEXT_DRAW;
    s_BlindBox[playerid] = PlayerText:INVALID_TEXT_DRAW;
    s_FadeActive[playerid] = false;
    s_FadeFroze[playerid] = false;
    s_FadeStep[playerid] = 0;
}

hook OnPlayerDisconnect(playerid,reason)
{
    Fade_Reset(playerid);
}

hook Character_OnUnload(playerid,characterid)
{
    Fade_Reset(playerid);
}
