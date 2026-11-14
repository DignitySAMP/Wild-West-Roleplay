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
#define LAW_CUFF_RANGE (2.5)
#define LAW_TACKLE_RANGE (3.5)
#define LAW_TACKLE_SECONDS (60)
#define LAW_TACKLE_ANIM_MS (1000)

static bool:s_LawCuffed[MAX_PLAYERS];
static s_LawTackleEnd[MAX_PLAYERS];

forward bool:Horse_ForceDismount(playerid);
forward Law_DisarmDeferred(playerid,token,target,targetToken);
forward Law_TackleAnim(playerid,token);
forward Law_OnTackled(playerid,target);
forward Law_OnCuffed(playerid,target,bool:cuffed);

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
stock bool:Law_IsCuffed(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_LawCuffed[playerid];
}

stock bool:Law_IsTackled(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_LawTackleEnd[playerid] != 0;
}

stock Law_SetCuffed(playerid,bool:cuffed)
{
    s_LawCuffed[playerid] = cuffed;
    SetPlayerSpecialAction(playerid,cuffed ? SPECIAL_ACTION_CUFFED : SPECIAL_ACTION_NONE);
}

static bool:Law_Require(playerid)
{
    if (!Posse_IsLawMember(playerid))
    {
        SendServerMessage(playerid,"You have to be in a police posse in order to do this command.",MSG_TYPE_INFO);
        return false;
    }

    return true;
}

static bool:Law_Near(playerid,target)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(target,x,y,z);
    return IsPlayerInRangeOfPoint(playerid,LAW_CUFF_RANGE,x,y,z) && GetPlayerInterior(playerid) == GetPlayerInterior(target) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(target);
}

static Law_Disarm(playerid,token,target,targetToken)
{
    yield 1;

    new response[DIALOG_RESPONSE], rank[POSSE_RANK_LEN], name[ACCOUNT_NAME_LEN], body[512];
    Posse_GetRank(playerid,rank);
    Posse_DisplayName(playerid,false,name);
    format(body,sizeof(body),"{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\n%s %s is about to disarm you of your weapons.\nThis dialog is meant to prevent abuse of the command but does not mean you can decline if everything's roleplayed properly.\n\nIf %s %s is attempting to abuse this command, file a complaint on the forum and use /report.  If not, click Proceed",rank,name,rank,name);
    await_arr(response) ShowAsyncDialog(target,DIALOG_STYLE_MSGBOX,"{C23030}WARNING",body,"{C23030}Proceed","Cancel");

    if (!Account_IsCurrent(target,targetToken) || !Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
    {
        return;
    }

    Weapons_RemoveHand(target);
    Weapons_SetSlot(target,E_GUN_SLOT_PANTS,0,0);
    Weapons_SetSlot(target,E_GUN_SLOT_BACK,0,0);
    Weapons_Save(target);
    new permit = Inventory_GetExtraTotal(target,E_ITEM_EXTRA_CARD_GUNPERMIT);

    if (permit > 0)
    {
        Inventory_DecreaseExtra(target,E_ITEM_EXTRA_CARD_GUNPERMIT,permit,false);
    }

    new targetName[ACCOUNT_NAME_LEN], line[160];
    Posse_DisplayName(target,false,targetName);
    format(line,sizeof(line),"You have successfully disarmed %s.",targetName);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"%s has disarmed you of your weapons and ammo.",name);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"%s has disarmed %s.",name,targetName);
    ProxDetector(playerid,30.0,COLOR_ACTION,line);
}

stock Law_Tick()
{
    new now = gettime();

    foreach (new i : Player)
    {
        if (s_LawTackleEnd[i] != 0 && now >= s_LawTackleEnd[i])
        {
            s_LawTackleEnd[i] = 0;
            SendServerMessage(i,"You've woken up from the tackle. You still feel a little dizzy, so take it easy.",MSG_TYPE_WARN);
            TogglePlayerControllable(i,true);
            ApplyAnimation(i,"PED","FLOOR_hit_f",4.1,false,true,true,true,1,SYNC_ALL);
        }
    }
}

Timer_Declare(Law_Timer)
{

    Law_Tick();
    return 1;
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
CMD:tackle(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (!Law_Require(playerid))
    {
        return 1;
    }

    new closest = INVALID_PLAYER_ID, Float:x, Float:y, Float:z;

    foreach (new i : Player)
    {
        if (i == playerid || s_LawTackleEnd[i] != 0 || !Player_IsReady(i))
        {
            continue;
        }

        GetPlayerPos(i,x,y,z);

        if (IsPlayerInRangeOfPoint(playerid,LAW_TACKLE_RANGE,x,y,z))
        {
            closest = i;
            break;
        }
    }

    if (closest == INVALID_PLAYER_ID)
    {
        SendServerMessage(playerid,"You're not close enough to someone!",MSG_TYPE_ERROR);
        return 1;
    }

    if (Player_IsBusyWith(closest,E_PLAYER_BUSY_HORSE))
    {
        Horse_ForceDismount(closest);
        Player_SetBusy(closest,E_PLAYER_BUSY_HORSE,false);
        SendServerMessage(closest,"You've been tackled off of your horse!",MSG_TYPE_INFO);
        pawn_call_public("Law_OnTackled","dd",playerid,closest);
    }

    new Float:angle, name[ACCOUNT_NAME_LEN], other[ACCOUNT_NAME_LEN], line[200], plain[ACCOUNT_NAME_LEN];
    TogglePlayerControllable(closest,false);
    GetPlayerFacingAngle(playerid,angle);
    SetPlayerFacingAngle(closest,angle);
    ApplyAnimation(playerid,"PED","EV_dive",4.1,false,true,true,true,0,SYNC_ALL);
    ApplyAnimation(closest,"PED","EV_dive",4.1,false,true,true,true,0,SYNC_ALL);
    Posse_DisplayName(playerid,false,name);
    Posse_DisplayName(closest,false,other);
    Posse_DisplayName(playerid,true,plain);
    format(line,sizeof(line),"* %s has tackled %s.",name,other);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
    format(line,sizeof(line),"You've been tackled by (%d) %s. You will be unfrozen shortly. Please roleplay accordingly.",playerid,plain);
    SendServerMessage(closest,line,MSG_TYPE_ERROR);
    s_LawTackleEnd[closest] = gettime() + LAW_TACKLE_SECONDS;
    SetTimerEx("Law_TackleAnim",LAW_TACKLE_ANIM_MS,false,"dd",closest,Account_GetToken(closest));
    return 1;
}

CMD:prisoners(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (!Law_Require(playerid))
    {
        return 1;
    }

    if (Point_FindService(playerid,POINT_BIZ_SHERIFF) == 0)
    {
        SendServerMessage(playerid,"You are not in a sheriff's office!",MSG_TYPE_ERROR);
        return 1;
    }

    new count = 0;
    SendServerMessage(playerid,"List of prisoners:",MSG_TYPE_INFO);

    foreach (new i : Player)
    {
        if (Prison_IsPrisoned(i))
        {
            new name[ACCOUNT_NAME_LEN], line[128];
            Posse_DisplayName(i,false,name);
            format(line,sizeof(line),"(%d) %s: prisoned for %d minutes",i,name,Prison_GetSecondsLeft(i) / 60);
            SendClientMessage(playerid,-1,line);
            count++;
        }
    }

    if (count == 0)
    {
        SendClientMessage(playerid,-1,"No prisoners at this time.");
    }

    return 1;
}

CMD:cuff(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Law_Require(playerid))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"Syntax: /cuff <player>",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_IsValidTarget(target))
    {
        SendServerMessage(playerid,"Player isn't online.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Law_Near(playerid,target))
    {
        SendServerMessage(playerid,"You are not near that player.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!s_LawCuffed[target])
    {
        if (Inventory_FindExtra(playerid,E_ITEM_EXTRA_SHERIFF_HANDCUFFS) == INV_ROW_NONE)
        {
            SendServerMessage(playerid,"You need handcuffs to handcuff a player!",MSG_TYPE_ERROR);
            return 1;
        }

        Inventory_DecreaseExtra(playerid,E_ITEM_EXTRA_SHERIFF_HANDCUFFS,1,false);
        Law_SetCuffed(target,true);
    }
    else
    {
        Law_SetCuffed(target,false);

        if (Inventory_CanHold(playerid,Item_FindByExtra(E_ITEM_EXTRA_SHERIFF_HANDCUFFS),1))
        {
            Inventory_GiveByParam(playerid,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_SHERIFF_HANDCUFFS,1);
        }
    }

    new verb[8], name[ACCOUNT_NAME_LEN], other[ACCOUNT_NAME_LEN], line[160];
    strcopy(verb,s_LawCuffed[target] ? "cuffed" : "uncuffed");
    Posse_DisplayName(playerid,false,name);
    Posse_DisplayName(target,false,other);
    format(line,sizeof(line),"You have successfully %s %s.",verb,other);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"You have been %s by %s.",verb,name);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"%s has %s %s.",name,verb,other);
    ProxDetector(playerid,30.0,COLOR_ACTION,line);
    pawn_call_public("Law_OnCuffed","ddd",playerid,target,s_LawCuffed[target]);
    return 1;
}

CMD:disarm(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Law_Require(playerid))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"Syntax: /disarm <player>",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_IsValidTarget(target))
    {
        SendServerMessage(playerid,"Player isn't online.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Law_Near(playerid,target))
    {
        SendServerMessage(playerid,"You are not near that player.",MSG_TYPE_ERROR);
        return 1;
    }

    new name[ACCOUNT_NAME_LEN], line[128];
    Posse_DisplayName(target,false,name);
    format(line,sizeof(line),"You've sent a disarm request to %s.",name);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    SetTimerEx("Law_DisarmDeferred",0,false,"dddd",playerid,Account_GetToken(playerid),target,Account_GetToken(target));
    return 1;
}

CMD:viewdebt(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Law_Require(playerid))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/viewdebt [target]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_IsValidTarget(target))
    {
        SendServerMessage(playerid,"Player isn't online.",MSG_TYPE_ERROR);
        return 1;
    }

    new bank = Money_Get(target,E_MONEY_SLOT_BANK), name[ACCOUNT_NAME_LEN], line[160], whole[16];
    Posse_DisplayName(target,false,name);

    if (bank < 0)
    {
        SendServerMessage(playerid,"Make sure you know their IC name before taking action, or you might get jailed for metagaming.",MSG_TYPE_WARN);
        Money_Delimit(Money_Dollars(-bank),whole);
        format(line,sizeof(line),"(%d) %s owes the government $%s.",target,name,whole);
    }
    else
    {
        format(line,sizeof(line),"(%d) %s owes the government nothing.",target,name);
    }

    SendServerMessage(playerid,line,MSG_TYPE_WARN);
    return 1;
}

public Law_DisarmDeferred(playerid,token,target,targetToken)
{
    if (Account_IsCurrent(playerid,token) && Account_IsCurrent(target,targetToken))
    {
        Law_Disarm(playerid,token,target,targetToken);
    }

    return 1;
}

public Law_TackleAnim(playerid,token)
{
    if (Account_IsCurrent(playerid,token) && s_LawTackleEnd[playerid] != 0)
    {
        ApplyAnimation(playerid,"PED","FLOOR_hit_f",4.1,false,true,true,true,1,SYNC_ALL);
    }

    return 1;
}

public Law_OnTackled(playerid,target)
{
    return 1;
}

public Law_OnCuffed(playerid,target,bool:cuffed)
{
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
    Timer_Start(Law_Timer,1000);
}

hook OnPlayerConnect(playerid)
{
    s_LawCuffed[playerid] = false;
    s_LawTackleEnd[playerid] = 0;
}

hook OnPlayerDisconnect(playerid,reason)
{
    s_LawCuffed[playerid] = false;
    s_LawTackleEnd[playerid] = 0;
}

hook Spawn_OnComplete(playerid)
{
    if (!Posse_IsLawMember(playerid))
    {
        return;
    }

    Kiosk_StripLawItems(playerid);
}

hook Paycheck_OnIncome(playerid)
{
    if (Posse_IsLawMember(playerid))
    {
        Paycheck_SetIncome(playerid,LAW_INCOME);
    }
}
