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
#define MOTEL_COUNT (3)
#define MOTEL_RANGE (2.5)
#define MOTEL_NAME_LEN (32)
#define MOTEL_LABEL_COLOUR (0x5BA864FF)

static const s_MotelNames[MOTEL_COUNT][MOTEL_NAME_LEN] =
{
    "Longcreek Motel",
    "Fort Earp Motel",
    "Fremont Motel"
};

static const Float:s_MotelPos[MOTEL_COUNT][3] =
{
    {-1445.2828,2615.7722,56.3657},
    {-1082.9253,2107.4001,88.6035},
    {-901.2448,1527.5383,25.8723}
};

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
stock Motel_GetCount()
{
    return MOTEL_COUNT;
}

stock Motel_GetName(motel,dest[],size = sizeof(dest))
{
    if (motel < 0 || motel >= MOTEL_COUNT)
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_MotelNames[motel],size);
}

stock bool:Motel_GetPosition(motel,&Float:x,&Float:y,&Float:z)
{
    if (motel < 0 || motel >= MOTEL_COUNT)
    {
        return false;
    }

    x = s_MotelPos[motel][0];
    y = s_MotelPos[motel][1];
    z = s_MotelPos[motel][2];
    return true;
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
CMD:rentroom(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    for (new i = 0;i < MOTEL_COUNT;i++)
    {
        if (IsPlayerInRangeOfPoint(playerid,MOTEL_RANGE,s_MotelPos[i][0],s_MotelPos[i][1],s_MotelPos[i][2]))
        {
            new line[128];
            format(line,sizeof(line),"You're now spawning in the \"%s\" (%d), your /spawn has been automatically updated.",s_MotelNames[i],i);
            SendServerMessage(playerid,line,MSG_TYPE_WARN);
            Point_SetMotel(playerid,i);
            Character_SetSpawnChoice(playerid,E_SPAWN_CHOICE_MOTEL);
            mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_spawnmotel = %d WHERE character_id = %d",i,Character_GetId(playerid)));
            return 1;
        }
    }

    SendServerMessage(playerid,"You're not near a motel point!",MSG_TYPE_ERROR);
    return 1;
}

CMD:gotomotel(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_IsModerator(playerid))
    {
        SendServerMessage(playerid,"You have to be a moderator in order to use this command.",MSG_TYPE_ERROR);
        return 1;
    }

    new motel;

    if (sscanf(params,"i",motel))
    {
        SendServerMessage(playerid,"/gotomotel [id]",MSG_TYPE_ERROR);
        return 1;
    }

    if (motel < 0 || motel >= MOTEL_COUNT)
    {
        new line[96];
        format(line,sizeof(line),"Motel ID can't be less than 0 or more than %d",MOTEL_COUNT);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return 1;
    }

    SetPlayerPos(playerid,s_MotelPos[motel][0],s_MotelPos[motel][1],s_MotelPos[motel][2]);
    return 1;
}

#include <pp-hooks>

hook OnGameModeInit()
{
    Spawn_RegisterChoice(E_SPAWN_CHOICE_MOTEL);

    for (new i = 0;i < MOTEL_COUNT;i++)
    {
        new text[96];
        format(text,sizeof(text),"[%d] %s\n{DEDEDE}/rentroom to spawn here",i,s_MotelNames[i]);
        CreateDynamic3DTextLabel(text,MOTEL_LABEL_COLOUR,s_MotelPos[i][0],s_MotelPos[i][1],s_MotelPos[i][2],POINT_LABEL_RANGE);
    }
}

hook Spawn_OnChoose(playerid)
{
    if (Character_GetSpawnChoice(playerid) != E_SPAWN_CHOICE_MOTEL)
    {
        return;
    }

    new motel = Point_GetMotel(playerid), Float:x, Float:y, Float:z, notice[96];

    if (!Motel_GetPosition(motel,x,y,z))
    {
        return;
    }

    format(notice,sizeof(notice),"You've spawned at the \"%s\" (%d), to remove this use /spawn.",s_MotelNames[motel],motel);
    Spawn_SetPoint(playerid,x,y,z,SPAWN_DEFAULT_ANGLE,0,0,E_SPAWN_PRIORITY_CHOICE,notice);
}
