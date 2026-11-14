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
#define PASS_RANGE (3.0)
#define PASS_COOLDOWN (5)
#define PASS_INFO "Enter the ID/Name of the player you want to give the item to."

static s_PassCooldown[MAX_PLAYERS];

forward Inventory_PassDeferred(playerid,token,uid);
forward Inventory_DiscardDeferred(playerid,token,uid);

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
stock bool:Inventory_InPassRange(playerid,targetid)
{
    if (GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid))
    {
        return false;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid,x,y,z);
    return IsPlayerInRangeOfPoint(playerid,PASS_RANGE,x,y,z);
}

static stock Pass_Info(error,playerid,dest[],size)
{
    switch (error)
    {
        case 1:
        {
            format(dest,size,"%s\nYou need to actually enter a name or playerid.",PASS_INFO);
        }
        case 2:
        {
            format(dest,size,"%s\nPlayer doesn't seem to connected to the server.",PASS_INFO);
        }
        case 3:
        {
            format(dest,size,"%s\nYou can't give yourself an item.",PASS_INFO);
        }
        case 4:
        {
            format(dest,size,"%s\nYou need to wait %d seconds before passing another item.",PASS_INFO,s_PassCooldown[playerid] - gettime());
        }
        case 5:
        {
            format(dest,size,"%s\nThe player you're trying to give the item to doesn't have enough inventory space.",PASS_INFO);
        }
        case 6:
        {
            format(dest,size,"%s\nYou aren't close enough to the player you're trying to give the item to.",PASS_INFO);
        }
        default:
        {
            strcopy(dest,PASS_INFO,size);
        }
    }
}

static stock Pass_Run(playerid,uid)
{
    yield 1;

    new token = Account_GetToken(playerid), error = 0, target = INVALID_PLAYER_ID, row[e_INV_ROW];

    for (;;)
    {
        new info[256], response[DIALOG_RESPONSE];
        Pass_Info(error,playerid,info,sizeof(info));
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_INPUT,"Pass Item To Player",info,"Proceed","Cancel");

        if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
        {
            return;
        }

        new index = Inventory_IndexOfUid(playerid,uid);

        if (index == INV_ROW_NONE)
        {
            return;
        }

        Inventory_GetRow(playerid,index,row);
        error = 0;

        if (sscanf(response[DIALOG_RESPONSE_INPUTTEXT],"u",target))
        {
            error = 1;
        }
        else if (!Staff_IsValidTarget(target) || !Player_IsReady(target))
        {
            error = 2;
        }
        else if (target == playerid)
        {
            error = 3;
        }
        else if (s_PassCooldown[playerid] >= gettime())
        {
            error = 4;
        }
        else if (!Inventory_CanHold(target,row[E_INV_ROW_ITEM],row[E_INV_ROW_AMOUNT],row[E_INV_ROW_PARAM1],row[E_INV_ROW_PARAM2]))
        {
            error = 5;
        }
        else if (!Inventory_InPassRange(playerid,target))
        {
            error = 6;
        }

        if (error == 0)
        {
            break;
        }
    }

    new targetToken = Account_GetToken(target), line[200], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN], itemName[ITEM_NAME_LEN];
    Account_GetRoleplayName(playerid,name);
    Account_GetRoleplayName(target,targetName);
    Item_GetName(row[E_INV_ROW_ITEM],itemName);
    s_PassCooldown[playerid] = gettime() + PASS_COOLDOWN;

    format(line,sizeof(line),"** %s offered %s their %s [amount: %d] [params: %d | %d ].",name,targetName,itemName,row[E_INV_ROW_AMOUNT],row[E_INV_ROW_PARAM1],row[E_INV_ROW_PARAM2]);
    Log_Info("inv/pass","%s",line);
    format(line,sizeof(line),"** %s has offered %s their %s.",name,targetName,itemName);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);

    new offer[256], answer[DIALOG_RESPONSE];
    format(offer,sizeof(offer),"(%d) %s wants to pass you %d of their %s.",playerid,name,row[E_INV_ROW_AMOUNT],itemName);
    await_arr(answer) ShowAsyncDialog(target,DIALOG_STYLE_MSGBOX,"Pass Item To Player: Transfer Request",offer,"Accept","Deny");

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    if (!Account_IsCurrent(target,targetToken))
    {
        return;
    }

    if (!answer[DIALOG_RESPONSE_RESPONSE])
    {
        format(line,sizeof(line),"%s has denied your offer to give them your %s.",targetName,itemName);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return;
    }

    new index = Inventory_IndexOfUid(playerid,uid), current[e_INV_ROW];

    if (index == INV_ROW_NONE || !Inventory_GetRow(playerid,index,current) || current[E_INV_ROW_AMOUNT] != row[E_INV_ROW_AMOUNT] || current[E_INV_ROW_ITEM] != row[E_INV_ROW_ITEM])
    {
        SendServerMessage(playerid,"Something went wrong. The target has been notified of the issue.",MSG_TYPE_ERROR);
        SendServerMessage(target,"The item is not available anymore, nothing was transferred.",MSG_TYPE_ERROR);
        return;
    }

    if (!Inventory_InPassRange(playerid,target) || !Inventory_Give(target,current[E_INV_ROW_ITEM],current[E_INV_ROW_AMOUNT],current[E_INV_ROW_PARAM1],current[E_INV_ROW_PARAM2]))
    {
        SendServerMessage(playerid,"Something went wrong. The target has been notified of the issue.",MSG_TYPE_ERROR);
        SendServerMessage(target,"The item could not be transferred, nothing was moved.",MSG_TYPE_ERROR);
        return;
    }

    Inventory_Remove(playerid,index);
    format(line,sizeof(line),"** %s passed %s their %s [amount: %d] [params: %d | %d ].",name,targetName,itemName,current[E_INV_ROW_AMOUNT],current[E_INV_ROW_PARAM1],current[E_INV_ROW_PARAM2]);
    Log_Info("inv/pass","%s",line);
    format(line,sizeof(line),"** %s has given %s their %s.",name,targetName,itemName);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
}

stock bool:Inventory_Pass(playerid,index)
{
    new uid = Inventory_GetUid(playerid,index);

    if (uid == 0)
    {
        return false;
    }

    SetTimerEx("Inventory_PassDeferred",0,false,"ddd",playerid,Account_GetToken(playerid),uid);
    return true;
}

static stock Discard_Run(playerid,uid)
{
    yield 1;

    new token = Account_GetToken(playerid), response[DIALOG_RESPONSE];
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"{CC4343}Deletion Warning","{CC4343}Deletion Warning!!!{DEDEDE}\n\nYou're about to discard an item.\nThis means it will get deleted from your inventory, with no way to get it back.\n\nPress \"DELETE\" to continue, or cancel to back out.","{CC4343}Delete","Cancel");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
    {
        return;
    }

    new index = Inventory_IndexOfUid(playerid,uid);

    if (index != INV_ROW_NONE)
    {
        Inventory_Remove(playerid,index);
        SendServerMessage(playerid,"You've discarded the item.",MSG_TYPE_WARN);
    }
}

stock bool:Inventory_ConfirmDiscard(playerid,index)
{
    new uid = Inventory_GetUid(playerid,index);

    if (uid == 0)
    {
        return false;
    }

    SetTimerEx("Inventory_DiscardDeferred",0,false,"ddd",playerid,Account_GetToken(playerid),uid);
    return true;
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
public Inventory_PassDeferred(playerid,token,uid)
{
    if (Account_IsCurrent(playerid,token))
    {
        Pass_Run(playerid,uid);
    }

    return 1;
}

public Inventory_DiscardDeferred(playerid,token,uid)
{
    if (Account_IsCurrent(playerid,token))
    {
        Discard_Run(playerid,uid);
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
    s_PassCooldown[playerid] = 0;
}
