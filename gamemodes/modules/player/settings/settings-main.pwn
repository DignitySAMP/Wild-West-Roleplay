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
#define STREAM_LOW (750)
#define STREAM_MEDIUM (1250)
#define STREAM_HIGH (2000)

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
static Streamdis_Usage(playerid,const first[])
{
    SendServerMessage(playerid,first,MSG_TYPE_INFO);
    SendServerMessage(playerid,"This command is used to change the amount of objects that show up for you.",MSG_TYPE_INFO);
    SendServerMessage(playerid,"High - 2000 visible objects",MSG_TYPE_INFO);
    SendServerMessage(playerid,"Medium - 1250 visible objects",MSG_TYPE_INFO);
    SendServerMessage(playerid,"Low - 750 visible objects",MSG_TYPE_INFO);
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
CMD:streamdis(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (isnull(params))
    {
        Streamdis_Usage(playerid,"/streamdis(tance) [low/medium/high]");
        return 1;
    }

    new limit = 0;

    if (!strcmp(params,"low",true))
    {
        limit = STREAM_LOW;
    }
    else if (!strcmp(params,"med",true) || !strcmp(params,"medium",true))
    {
        limit = STREAM_MEDIUM;
    }
    else if (!strcmp(params,"high",true))
    {
        limit = STREAM_HIGH;
    }
    else
    {
        Streamdis_Usage(playerid,"/streamdis [low/medium/high]");
        return 1;
    }

    new line[96];
    format(line,sizeof(line),"You've set your streaming distance to \"%s\". (Limit: %d)",params,limit);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Streamer_SetVisibleItems(STREAMER_TYPE_OBJECT,limit,playerid);
    Streamer_Update(playerid,STREAMER_TYPE_OBJECT);
    return 1;
}

ALT:streamdistance=CMD:streamdis;
