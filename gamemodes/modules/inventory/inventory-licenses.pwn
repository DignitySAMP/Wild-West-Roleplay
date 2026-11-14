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
#define LICENSE_RANGE (10.0)

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
CMD:licenses(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/licenses [player]",MSG_TYPE_ERROR);
        return 1;
    }

    if (target == INVALID_PLAYER_ID || !Player_IsReady(target))
    {
        SendServerMessage(playerid,"Target doesn't seem to be connected.",MSG_TYPE_ERROR);
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(target,x,y,z);

    if (!IsPlayerInRangeOfPoint(playerid,LICENSE_RANGE,x,y,z))
    {
        SendServerMessage(playerid,"You're not close enough to your target.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[144], mine[ACCOUNT_NAME_LEN], theirs[ACCOUNT_NAME_LEN];
    Account_GetRoleplayName(playerid,mine);
    Account_GetRoleplayName(target,theirs);
    format(line,sizeof(line),"Licenses of (%d) %s",playerid,mine);
    SendClientMessage(target,COLOR_TAB0,line);
    format(line,sizeof(line),"[Passport]: %s",Inventory_FindExtra(playerid,E_ITEM_EXTRA_CARD_PASSPORT) != INV_ROW_NONE ? ("{406E3B}yes") : ("{A12F2F}no"));
    SendClientMessage(target,COLOR_TAB1,line);
    format(line,sizeof(line),"[Gun Permit]: %s",Inventory_FindExtra(playerid,E_ITEM_EXTRA_CARD_GUNPERMIT) != INV_ROW_NONE ? ("{406E3B}yes") : ("{A12F2F}no"));
    SendClientMessage(target,COLOR_TAB2,line);
    format(line,sizeof(line),"You've shown your licenses to (%d) %s.",target,theirs);
    SendServerMessage(playerid,line,MSG_TYPE_ERROR);
    format(line,sizeof(line),"* %s shows his licenses to %s",mine,theirs);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
    return 1;
}
