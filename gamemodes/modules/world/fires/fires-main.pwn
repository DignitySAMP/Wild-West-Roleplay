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
CMD:fire(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));
    Log_Info("abuse","(%d) %s tried to abuse /fire. Perm ban them.",playerid,name);
    SendClientMessage(playerid,COLOR_YELLOW,"You're logged. Consider yourself banned.");
    return 1;
}
