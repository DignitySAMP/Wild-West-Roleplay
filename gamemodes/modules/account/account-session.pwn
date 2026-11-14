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
#define SWITCH_SECONDS (15)
#define SWITCH_FOOTER "~n~~n~~n~~n~~b~Switch time left:~w~ %d"

static s_SwitchSeconds[MAX_PLAYERS];
static s_SwitchSlot[MAX_PLAYERS];
static s_LeaveReason[MAX_PLAYERS];

forward Switch_Deferred(playerid,token);
forward Age_Deferred(playerid,token);

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
stock Character_SavePosition(playerid,bool:crashed)
{
    if (g_AccountStage[playerid] != E_ACCOUNT_STAGE_PLAYING || !Player_IsSpawned(playerid) || !g_Character[playerid][E_CHARACTER_ID])
    {
        return false;
    }

    if (!crashed && g_Character[playerid][E_CHARACTER_SPAWNPOINT] != 6)
    {
        return false;
    }

    g_AccountHasOverride[playerid] = false;
    pawn_call_public("Character_OnSavePosition","d",playerid);

    new Float:x, Float:y, Float:z, interior, world;

    if (g_AccountHasOverride[playerid])
    {
        x = g_AccountOverrideX[playerid];
        y = g_AccountOverrideY[playerid];
        z = g_AccountOverrideZ[playerid];
        interior = 0;
        world = 0;
        g_AccountHasOverride[playerid] = false;
    }
    else
    {
        GetPlayerPos(playerid,x,y,z);
        interior = GetPlayerInterior(playerid);
        world = GetPlayerVirtualWorld(playerid);
    }

    g_Character[playerid][E_CHARACTER_POS_X] = x;
    g_Character[playerid][E_CHARACTER_POS_Y] = y;
    g_Character[playerid][E_CHARACTER_POS_Z] = z;
    g_Character[playerid][E_CHARACTER_POS_INTERIOR] = interior;
    g_Character[playerid][E_CHARACTER_POS_WORLD] = world;

    if (crashed)
    {
        g_Character[playerid][E_CHARACTER_CRASHED] = 1;
    }

    mysql_pquery_s(g_Mysql,str_format("UPDATE characters SET character_pos_x = %f, character_pos_y = %f, character_pos_z = %f, character_pos_interior = %d, character_pos_vw = %d, character_crashed = %d WHERE character_id = %d",x,y,z,interior,world,g_Character[playerid][E_CHARACTER_CRASHED],g_Character[playerid][E_CHARACTER_ID]));
    return true;
}

stock Character_SetSpawnChoice(playerid,choice)
{
    g_Character[playerid][E_CHARACTER_SPAWNPOINT] = choice;
    mysql_pquery_s(g_Mysql,str_format("UPDATE characters SET character_spawnpoint = %d WHERE character_id = %d",choice,g_Character[playerid][E_CHARACTER_ID]));
}

stock Character_ClearCrashed(playerid)
{
    g_Character[playerid][E_CHARACTER_CRASHED] = 0;
    mysql_pquery_s(g_Mysql,str_format("UPDATE characters SET character_crashed = 0 WHERE character_id = %d",g_Character[playerid][E_CHARACTER_ID]));
}

stock Character_SetAge(playerid,age)
{
    g_Character[playerid][E_CHARACTER_AGE] = age;
    mysql_pquery_s(g_Mysql,str_format("UPDATE characters SET character_age = %d WHERE character_id = %d",age,g_Character[playerid][E_CHARACTER_ID]));
}

stock Account_GetLeaveReason(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return -1;
    }

    return s_LeaveReason[playerid] - 1;
}

static Character_Unload(playerid)
{
    if (g_AccountStage[playerid] == E_ACCOUNT_STAGE_PLAYING && g_Character[playerid][E_CHARACTER_ID])
    {
        pawn_call_public("Character_OnLeaving","dd",playerid,g_Character[playerid][E_CHARACTER_ID]);
        pawn_call_public("Character_OnUnload","dd",playerid,g_Character[playerid][E_CHARACTER_ID]);
    }
}

stock bool:Account_Logout(playerid)
{
    if (g_AccountStage[playerid] != E_ACCOUNT_STAGE_PLAYING)
    {
        return false;
    }

    Character_SavePosition(playerid,false);
    Character_Unload(playerid);
    pawn_call_public("Account_OnLogout","dd",playerid,g_Account[playerid][E_ACCOUNT_ID]);

    Select_Close(playerid);
    Create_Close(playerid);

    new name[ACCOUNT_NAME_LEN];
    strcopy(name,g_Account[playerid][E_ACCOUNT_NAME]);
    SetPlayerName(playerid,name);
    SetPlayerScore(playerid,0);
    SetPlayerColor(playerid,ACCOUNT_IDLE_COLOUR);
    s_SwitchSeconds[playerid] = 0;

    Account_ResetPlayer(playerid);
    Account_Restart(playerid);
    return true;
}

stock bool:Account_Relog(playerid)
{
    if (g_AccountLogged[playerid])
    {
        return false;
    }

    Select_Close(playerid);
    Create_Close(playerid);
    Account_ResetPlayer(playerid);
    Account_Restart(playerid);
    return true;
}

stock bool:Switch_IsRunning(playerid)
{
    return s_SwitchSeconds[playerid] > 0;
}

stock Switch_Start(playerid,slot)
{
    new line[192];
    s_SwitchSeconds[playerid] = SWITCH_SECONDS;
    s_SwitchSlot[playerid] = slot;
    Player_SetBusy(playerid,E_PLAYER_BUSY_SWITCH,true);

    format(line,sizeof(line),"You have selected character slot %d. [DB ID: (%d)] %s. You will switch momentarily.",slot,g_CharacterSlots[playerid][slot][E_CHARACTER_ID],g_CharacterSlots[playerid][slot][E_CHARACTER_NAME]);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    SendServerMessage(playerid,"You're gonna be frozen for fifteen seconds. These will serve as a cooldown and a deterrence to abuse.",MSG_TYPE_WARN);
    TogglePlayerControllable(playerid,false);

    new rpName[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,rpName);
    format(line,sizeof(line),SWITCH_FOOTER,s_SwitchSeconds[playerid]);
    GameTextForPlayer(playerid,line,1000,3);

    format(line,sizeof(line),"[SWITCH] %s is trying to switch to character %s.",rpName,g_CharacterSlots[playerid][slot][E_CHARACTER_NAME]);
    SendModeratorWarning(line,MOD_WARNING_LOW);
}

static Switch_Finish(playerid)
{
    new slot = s_SwitchSlot[playerid], line[160], rpName[ACCOUNT_NAME_LEN];
    s_SwitchSeconds[playerid] = 0;
    Player_SetBusy(playerid,E_PLAYER_BUSY_SWITCH,false);

    Character_SavePosition(playerid,false);
    Character_Unload(playerid);
    SetPlayerVirtualWorld(playerid,0);
    SetPlayerInterior(playerid,0);

    Account_GetRoleplayName(playerid,rpName);
    format(line,sizeof(line),"[SWITCH] %s has switched to their character %s.",rpName,g_CharacterSlots[playerid][slot][E_CHARACTER_NAME]);
    SendModeratorWarning(line,MOD_WARNING_LOW);

    TogglePlayerControllable(playerid,true);
    g_AccountStage[playerid] = E_ACCOUNT_STAGE_LOADING;
    Character_BeginLoad(playerid,slot);
}

static Switch_Menu(playerid)
{
    yield 1;

    new token = g_AccountToken[playerid], body[512], response[DIALOG_RESPONSE];
    format(body,sizeof(body),"{DEDEDE}ID \t Name\n");

    for (new i = 0;i < CHARACTER_SLOTS;i++)
    {
        if (g_CharacterSlots[playerid][i][E_CHARACTER_ID])
        {
            format(body,sizeof(body),"%s(%d)\t%s\n",body,g_CharacterSlots[playerid][i][E_CHARACTER_ID],g_CharacterSlots[playerid][i][E_CHARACTER_NAME]);
        }
        else
        {
            format(body,sizeof(body),"%s(%d)\tNone\n",body,i);
        }
    }

    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,"Character Switch",body,"Continue","Cancel");

    if (!Account_IsCurrent(playerid,token) || g_AccountStage[playerid] != E_ACCOUNT_STAGE_PLAYING || !response[DIALOG_RESPONSE_RESPONSE])
    {
        return;
    }

    PlayerPlaySound(playerid,ACCOUNT_CONFIRM_SOUND,0.0,0.0,0.0);
    new slot = response[DIALOG_RESPONSE_LISTITEM];

    if (slot < 0 || slot >= CHARACTER_SLOTS || !g_CharacterSlots[playerid][slot][E_CHARACTER_ID])
    {
        SendServerMessage(playerid,"You don't have a character in this slot.",MSG_TYPE_ERROR);
        return;
    }

    Switch_Start(playerid,slot);
}

stock bool:Switch_Open(playerid)
{
    if (!Player_IsFree(playerid) || g_AccountStage[playerid] != E_ACCOUNT_STAGE_PLAYING)
    {
        return false;
    }

    SetTimerEx("Switch_Deferred",0,false,"dd",playerid,g_AccountToken[playerid]);
    return true;
}

static Age_Prompt(playerid,token)
{
    yield 1;

    new response[DIALOG_RESPONSE], prompt[200] = "The server detected that your age is zero.\n\nIf this isn't correct, take a screenshot of this dialog and send it to a developer.\n\nEnter your character's age below: (8-80)";

    for (;;)
    {
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_INPUT,"Character Age",prompt,"Finish");

        if (!Account_IsCurrent(playerid,token) || g_AccountStage[playerid] != E_ACCOUNT_STAGE_PLAYING)
        {
            return;
        }

        if (!response[DIALOG_RESPONSE_RESPONSE])
        {
            strcopy(prompt,"The server detected that your age is 0.\n\nIf this isn't correct, take a screenshot of this dialog and send it to a developer.\n\nEnter your character's age below: (8-80)");
            continue;
        }

        new text[129];
        strcopy(text,response[DIALOG_RESPONSE_INPUTTEXT]);

        if (!strlen(text))
        {
            strcopy(prompt,"No characters were detected.\n\nEnter your character's age below: (8-80)");
            continue;
        }

        if (!Account_IsNumeric(text))
        {
            strcopy(prompt,"That is not a numeric character.\n\nEnter your character's age below: (8-80)");
            continue;
        }

        if (strval(text) > CHARACTER_AGE_MAX || strval(text) < CHARACTER_AGE_MIN)
        {
            strcopy(prompt,"You character cannot be younger than 8 or older than 80.\n\nEnter your character's age below: (8-80)");
            continue;
        }

        Character_SetAge(playerid,strval(text));
        new line[64];
        format(line,sizeof(line),"You've set your character's age to %d.",strval(text));
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        return;
    }
}

stock Character_PromptAge(playerid,token)
{
    SetTimerEx("Age_Deferred",0,false,"dd",playerid,token);
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
public Switch_Deferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token) && g_AccountStage[playerid] == E_ACCOUNT_STAGE_PLAYING)
    {
        Switch_Menu(playerid);
    }

    return 1;
}

public Age_Deferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token) && g_AccountStage[playerid] == E_ACCOUNT_STAGE_PLAYING)
    {
        Age_Prompt(playerid,token);
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

hook OnPlayerConnect(playerid)
{
    s_SwitchSeconds[playerid] = 0;
}

hook OnPlayerDisconnect(playerid,reason)
{
    s_LeaveReason[playerid] = reason + 1;
    Character_SavePosition(playerid,reason == 0);
    Character_Unload(playerid);
    s_LeaveReason[playerid] = 0;
    s_SwitchSeconds[playerid] = 0;
}

hook Tick_OnPlayerSecond(playerid)
{
    if (s_SwitchSeconds[playerid] <= 0 || g_AccountStage[playerid] != E_ACCOUNT_STAGE_PLAYING)
    {
        return;
    }

    s_SwitchSeconds[playerid]--;

    new line[64];
    format(line,sizeof(line),SWITCH_FOOTER,s_SwitchSeconds[playerid]);
    GameTextForPlayer(playerid,line,1000,3);

    if (s_SwitchSeconds[playerid] <= 0)
    {
        Switch_Finish(playerid);
    }
}
