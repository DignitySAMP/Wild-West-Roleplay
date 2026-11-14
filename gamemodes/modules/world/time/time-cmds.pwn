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
CMD:servertime(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    new date[32], line[128];
    Staff_FormatDateTime(date);
    format(line,sizeof(line),"{DEDEDE}The current OOC [[VPS/SERVER HOST]] date/time is %s(GMT +1)",date);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
}
