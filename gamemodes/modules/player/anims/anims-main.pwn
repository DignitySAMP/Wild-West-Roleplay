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
#define ANIM_SHIT_SLOT (9)
#define ANIM_SHIT_MODEL (18722)
#define ANIM_PRELOAD_STEP (8)
#define ANIM_STOP_LIB "CARRY"
#define ANIM_STOP_NAME "crry_prtial"

static bool:s_AnimLooping[MAX_PLAYERS];
static s_AnimPreload[MAX_PLAYERS];

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
stock bool:Anim_IsLooping(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_AnimLooping[playerid];
}

stock bool:Anim_Allowed(playerid)
{
    if (Horse_IsRiding(playerid) || Jail_IsJailed(playerid) || Injury_GetMode(playerid) != INJURY_MODE_NORMAL || Trap_IsCaught(playerid))
    {
        return false;
    }

    return !Lasso_IsCaught(playerid) && !Law_IsCuffed(playerid) && !Point_IsSleeping(playerid) && !Picker_IsOpen(playerid) && !Player_IsBusyWith(playerid,E_PLAYER_BUSY_POKER);
}

static Anim_DropExtras(playerid)
{
    new model;

    if (IsPlayerAttachedObjectSlotUsed(playerid,ANIM_SHIT_SLOT) && GetPlayerAttachedObject(playerid,ANIM_SHIT_SLOT,model) && model == ANIM_SHIT_MODEL)
    {
        RemovePlayerAttachedObject(playerid,ANIM_SHIT_SLOT);
    }
}

static Anim_Reset(playerid)
{
    s_AnimLooping[playerid] = false;
    Anim_DropExtras(playerid);
}

static Anim_Release(playerid)
{
    ApplyAnimation(playerid,ANIM_STOP_LIB,ANIM_STOP_NAME,4.0,false,false,false,false,0);
}

static Anim_PlayRow(playerid,row)
{
    Anim_DropExtras(playerid);
    s_AnimLooping[playerid] = false;
    new special = g_AnimData[row][8];

    if (special >= 0)
    {
        SetPlayerSpecialAction(playerid,SPECIAL_ACTION:special);
    }
    else
    {
        ApplyAnimation(playerid,g_AnimLib[row],g_AnimName[row],float(g_AnimData[row][0]) / 10.0,bool:g_AnimData[row][1],bool:g_AnimData[row][2],bool:g_AnimData[row][3],bool:g_AnimData[row][4],g_AnimData[row][5],FORCE_SYNC:g_AnimData[row][6]);
        s_AnimLooping[playerid] = g_AnimData[row][7] != 0;
    }

}

stock Anim_Command(playerid,cmd,const params[])
{
    if (!Anim_Allowed(playerid))
    {
        SendServerMessage(playerid,"You can't perform animations at the moment.",MSG_TYPE_ERROR);
        return;
    }

    new row = g_AnimCmdFirst[cmd];

    if (g_AnimCmdMin[cmd] >= 0)
    {
        new type;

        if (sscanf(params,"d",type))
        {
            SendServerMessage(playerid,g_AnimCmdUsage[cmd],MSG_TYPE_ERROR);
            return;
        }

        if (type < g_AnimCmdMin[cmd] || type > g_AnimCmdMax[cmd])
        {
            SendServerMessage(playerid,g_AnimCmdRangeUsage[cmd] ? g_AnimCmdUsage[cmd] : "Invalid type specified.",MSG_TYPE_ERROR);
            return;
        }

        row += type - g_AnimCmdMin[cmd];
    }

    Anim_PlayRow(playerid,row);

    if (cmd == ANIM_CMD_SHIT)
    {
        SetPlayerAttachedObject(playerid,ANIM_SHIT_SLOT,ANIM_SHIT_MODEL,1,-1.773999,0.234999,-0.091000,2.300002,88.499984,0.0,1.0,1.0,1.0);
    }
}

stock Anim_Time(playerid)
{
    Anim_Command(playerid,ANIM_CMD_TIME,"");
}

stock bool:Anim_Stop(playerid)
{
    if (!Anim_Allowed(playerid))
    {
        return false;
    }

    Anim_Reset(playerid);
    ClearAnimations(playerid,SYNC_ALL);
    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);
    Anim_Release(playerid);
    return true;
}

stock Anim_List(playerid)
{
    SendClientMessage(playerid,COLOR_TAB0,"|________________________| Animation Help |________________________|");
    SendClientMessage(playerid,COLOR_TAB1,"/dance, /handsup, /bat, /bar, /wash, /lay, /workout, /blowjob, /bomb");
    SendClientMessage(playerid,COLOR_TAB2,"/carry, /crack, /sleep, /jump, /deal, /dancing, /eating, /puke, /gsign, /chat");
    SendClientMessage(playerid,COLOR_TAB1,"/goggles, /spray, /throw, /swipe, /office, /kiss, /knife, /cpr, /scratch, /aim");
    SendClientMessage(playerid,COLOR_TAB2,"/cheer, /wave, /strip, /smoke, /reload, /taichi, /wank, /cower, /drunk, /riflehold");
    SendClientMessage(playerid,COLOR_TAB1,"/cry, /tired, /sit, /crossarms, /fucku, /walk, /piss, /slapass, /camcrouch, /ko");
    SendClientMessage(playerid,COLOR_TAB2,"/fall, /carryidle, /time, /pointyonder, /stop, /getup, /lean, /drink, /stopanim");
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
    s_AnimLooping[playerid] = false;
    s_AnimPreload[playerid] = -1;
}

hook Player_OnReady(playerid)
{
    if (s_AnimPreload[playerid] < 0)
    {
        s_AnimPreload[playerid] = 0;
    }
}

hook Tick_OnPlayerSecond(playerid)
{
    if (s_AnimPreload[playerid] < 0 || s_AnimPreload[playerid] >= ANIM_LIBS || s_AnimLooping[playerid])
    {
        return;
    }

    new stop = s_AnimPreload[playerid] + ANIM_PRELOAD_STEP;

    if (stop > ANIM_LIBS)
    {
        stop = ANIM_LIBS;
    }

    for (new i = s_AnimPreload[playerid];i < stop;i++)
    {
        ApplyAnimation(playerid,g_AnimLibraries[i],"null",0.0,false,false,false,false,0);
    }

    s_AnimPreload[playerid] = stop;
}

hook OnPlayerDeath(playerid,killerid,WEAPON:reason)
{
    Anim_Reset(playerid);
}

hook Character_OnUnload(playerid,characterid)
{
    Anim_Reset(playerid);
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (!(newkeys & KEY_SPRINT) || (oldkeys & KEY_SPRINT) || !s_AnimLooping[playerid] || !Anim_Allowed(playerid))
    {
        return;
    }

    Anim_Reset(playerid);
    Anim_Release(playerid);
}
