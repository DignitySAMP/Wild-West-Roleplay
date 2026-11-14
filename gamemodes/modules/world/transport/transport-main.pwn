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
#define TRANSPORT_COUNT (5)
#define TRANSPORT_NAME_LEN (64)
#define TRANSPORT_RANGE (5.0)
#define TRANSPORT_NONE (-1)
#define TRANSPORT_ICON (9)
#define TRANSPORT_PICKUP (1210)
#define TRANSPORT_LABEL_RANGE (15.0)
#define TRANSPORT_LABEL_COLOUR (0xBA9D6AFF)

enum e_TRANSPORT
{
    E_TRANSPORT_NAME[TRANSPORT_NAME_LEN],
    Float:E_TRANSPORT_X,
    Float:E_TRANSPORT_Y,
    Float:E_TRANSPORT_Z,
    E_TRANSPORT_PRICE,
    E_TRANSPORT_TARGET,
    Float:E_TRANSPORT_LAND_X,
    Float:E_TRANSPORT_LAND_Y,
    Float:E_TRANSPORT_LAND_Z,
    Float:E_TRANSPORT_LAND_ANGLE
}

static const s_Transport[TRANSPORT_COUNT][e_TRANSPORT] =
{
    {"Boat to Longcreek Docks",-2333.5571,2294.5916,4.98440,25,TRANSPORT_NONE,-1168.3000,2689.3000,42.8000,90.0},
    {"Train to Fremont",-2687.3406,2203.1135,56.7655,30,2,0.0,0.0,0.0,-1.0},
    {"Train to Bayside Station",-828.68710,1083.9216,34.6641,40,1,0.0,0.0,0.0,-1.0},
    {"Bayside Tunnel Pass",-2269.7869,2639.1511,55.4490,0,4,0.0,0.0,0.0,-1.0},
    {"Bayside Tunnel Pass",-2000.9537,2562.3591,55.2470,0,3,0.0,0.0,0.0,-1.0}
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
stock Transport_Count()
{
    return TRANSPORT_COUNT;
}

stock bool:Transport_Get(index,name[],size,&Float:x,&Float:y,&Float:z,&price,&target)
{
    if (index < 0 || index >= TRANSPORT_COUNT)
    {
        return false;
    }

    strcopy(name,s_Transport[index][E_TRANSPORT_NAME],size);
    x = s_Transport[index][E_TRANSPORT_X];
    y = s_Transport[index][E_TRANSPORT_Y];
    z = s_Transport[index][E_TRANSPORT_Z];
    price = s_Transport[index][E_TRANSPORT_PRICE];
    target = s_Transport[index][E_TRANSPORT_TARGET];
    return true;
}

stock bool:Transport_GetLanding(index,&Float:x,&Float:y,&Float:z,&Float:angle)
{
    if (index < 0 || index >= TRANSPORT_COUNT)
    {
        return false;
    }

    new target = s_Transport[index][E_TRANSPORT_TARGET];

    if (target == TRANSPORT_NONE)
    {
        x = s_Transport[index][E_TRANSPORT_LAND_X];
        y = s_Transport[index][E_TRANSPORT_LAND_Y];
        z = s_Transport[index][E_TRANSPORT_LAND_Z];
        angle = s_Transport[index][E_TRANSPORT_LAND_ANGLE];
        return true;
    }

    x = s_Transport[target][E_TRANSPORT_X];
    y = s_Transport[target][E_TRANSPORT_Y];
    z = s_Transport[target][E_TRANSPORT_Z];
    angle = -1.0;
    return true;
}

stock Transport_Near(playerid)
{
    for (new i = 0;i < TRANSPORT_COUNT;i++)
    {
        if (GetPlayerDistanceFromPoint(playerid,s_Transport[i][E_TRANSPORT_X],s_Transport[i][E_TRANSPORT_Y],s_Transport[i][E_TRANSPORT_Z]) < TRANSPORT_RANGE)
        {
            return i;
        }
    }

    return TRANSPORT_NONE;
}

stock Transport_Init()
{
    for (new i = 0;i < TRANSPORT_COUNT;i++)
    {
        new label[128], price[16];
        Money_Delimit(s_Transport[i][E_TRANSPORT_PRICE],price);
        format(label,sizeof(label),"[%s]\n{DEDEDE}$%s to pass (/transport)",s_Transport[i][E_TRANSPORT_NAME],price);
        CreateDynamic3DTextLabel(label,TRANSPORT_LABEL_COLOUR,s_Transport[i][E_TRANSPORT_X],s_Transport[i][E_TRANSPORT_Y],s_Transport[i][E_TRANSPORT_Z],TRANSPORT_LABEL_RANGE);
        CreateDynamicMapIcon(s_Transport[i][E_TRANSPORT_X],s_Transport[i][E_TRANSPORT_Y],s_Transport[i][E_TRANSPORT_Z],TRANSPORT_ICON,-1);
        CreateDynamicPickup(TRANSPORT_PICKUP,1,s_Transport[i][E_TRANSPORT_X],s_Transport[i][E_TRANSPORT_Y],s_Transport[i][E_TRANSPORT_Z]);
    }
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
CMD:transport(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    new index = Transport_Near(playerid);

    if (index == TRANSPORT_NONE)
    {
        SendServerMessage(playerid,"You're not near a transport point!",MSG_TYPE_ERROR);
        return 1;
    }

    new price[16], line[128], fare = s_Transport[index][E_TRANSPORT_PRICE], Float:x, Float:y, Float:z, Float:angle;
    Money_Delimit(fare,price);

    if (!Money_CanAfford(playerid,Money_Make(fare)))
    {
        format(line,sizeof(line),"You need at least $%s to afford this.",price);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return 1;
    }

    Money_Take(playerid,Money_Make(fare));
    Transport_GetLanding(index,x,y,z,angle);
    SetPlayerPos(playerid,x,y,z);

    if (angle >= 0.0)
    {
        SetPlayerFacingAngle(playerid,angle);
    }

    format(line,sizeof(line),"You've taken the %s. It cost you $%s",s_Transport[index][E_TRANSPORT_NAME],price);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
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
    Transport_Init();
}
