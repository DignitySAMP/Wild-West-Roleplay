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
CMD:gate(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    new gateid = Gate_NearPlayer(playerid);

    if (gateid == GATE_NONE)
    {
        SendServerMessage(playerid,"You're not near any door.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Posse_IsLawMember(playerid))
    {
        SendServerMessage(playerid,"You don't have the keys to this door.",MSG_TYPE_ERROR);
        return 1;
    }

    Gate_Toggle(gateid);
    return 1;
}
