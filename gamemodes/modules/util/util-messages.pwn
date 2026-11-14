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
#define MESSAGE_TEXT_LEN (1024)
#define MESSAGE_COLOUR_INFO (0x92C742FF)

#if !defined COLOR_DEFAULT
    #define COLOR_DEFAULT (0xDEDEDEFF)
#endif

#if !defined COLOR_YELLOW
    #define COLOR_YELLOW (0xFFFF00FF)
#endif

#if !defined COLOR_RED
    #define COLOR_RED (0xFF6347FF)
#endif

#if !defined COLOR_BLUE
    #define COLOR_BLUE (0x007FFFFF)
#endif

#if !defined COLOR_STAFF
    #define COLOR_STAFF (0x59BD93FF)
#endif

#if !defined COLOR_ADMIN_BLUE
    #define COLOR_ADMIN_BLUE (0x00A4DBAA)
#endif

#if !defined COLOR_TAB0
    #define COLOR_TAB0 (0x6B5538FF)
#endif

#if !defined COLOR_TAB1
    #define COLOR_TAB1 (0xBA9E72FF)
#endif

#if !defined COLOR_TAB2
    #define COLOR_TAB2 (0xDEBD8AFF)
#endif

enum _:E_MSG_TYPE
{
    MSG_TYPE_INFO = 0,
    MSG_TYPE_WARN,
    MSG_TYPE_ERROR,
}

enum _:E_MOD_WARNING
{
    MOD_WARNING_LOW = 0,
    MOD_WARNING_MED,
    MOD_WARNING_HIGH,
}

forward bool:Account_IsLoggedIn(playerid);
forward bool:Staff_WantsWarnings(playerid);

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
stock SendServerMessage(playerid,const text[],type = MSG_TYPE_INFO)
{
    new line[MESSAGE_TEXT_LEN];

    switch (type)
    {
        case MSG_TYPE_INFO:
        {
            format(line,sizeof(line),"Info:{dedede} %s",text);
            return SendClientMessage(playerid,MESSAGE_COLOUR_INFO,line);
        }
        case MSG_TYPE_WARN:
        {
            format(line,sizeof(line),"Warning:{dedede} %s",text);
            return SendClientMessage(playerid,COLOR_YELLOW,line);
        }
        case MSG_TYPE_ERROR:
        {
            format(line,sizeof(line),"Error:{dedede} %s",text);
            return SendClientMessage(playerid,COLOR_RED,line);
        }
    }

    return true;
}

stock SendSplitMessage(playerid,colour,const text[])
{
    return SendClientMessage(playerid,colour,text);
}

stock SendSplitMessageEx(playerid,colour,const text[])
{
    return SendClientMessage(playerid,colour,text);
}

stock SendSplitMessageToAll(colour,const text[])
{
    foreach (new i : Player)
    {
        SendClientMessage(i,colour,text);
    }

    return true;
}

stock ProxDetector(playerid,Float:range,colour,const text[],Float:ratio = 1.6)
{
    new Float:x, Float:y, Float:z;

    if (!GetPlayerPos(playerid,x,y,z))
    {
        return false;
    }

    new Float:red = float(colour >>> 24 & 0xFF), Float:green = float(colour >>> 16 & 0xFF), Float:blue = float(colour >>> 8 & 0xFF);
    new Float:reach = range * ratio;
    new interior = GetPlayerInterior(playerid), world = GetPlayerVirtualWorld(playerid);

    foreach (new i : Player)
    {
        new Float:distance = GetPlayerDistanceFromPoint(i,x,y,z);

        if (distance > range || GetPlayerInterior(i) != interior || GetPlayerVirtualWorld(i) != world)
        {
            continue;
        }

        new Float:fade = (reach - distance) / reach;
        new shaded = (colour & 0xFF) | (floatround(fade * blue) << 8) | (floatround(fade * green) << 16) | (floatround(fade * red) << 24);
        SendClientMessage(i,shaded,text);
    }

    return true;
}

stock SendModeratorWarning(const text[],level = MOD_WARNING_LOW)
{
    new colour = COLOR_ADMIN_BLUE;

    switch (level)
    {
        case MOD_WARNING_MED:
        {
            colour = COLOR_YELLOW;
        }
        case MOD_WARNING_HIGH:
        {
            colour = COLOR_RED;
        }
    }

    foreach (new i : Player)
    {
        if (IsPlayerNPC(i) || !Account_IsLoggedIn(i) || Account_GetAdminLevel(i) < 2 || !Staff_WantsWarnings(i))
        {
            continue;
        }

        SendClientMessage(i,colour,text);
    }

    Log_Info("staff","%s",text);
    return true;
}
