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
#define RADIO_ZONES (3)
#define RADIO_TEXT_LEN (144)

enum e_RADIO_ZONE
{
    Float:E_RADIO_MIN_X,
    Float:E_RADIO_MIN_Y,
    Float:E_RADIO_MAX_X,
    Float:E_RADIO_MAX_Y,
    Float:E_RADIO_POLE_X,
    Float:E_RADIO_POLE_Y,
    Float:E_RADIO_POLE_Z,
}

static const s_RadioZones[RADIO_ZONES][e_RADIO_ZONE] =
{
    {-1269.046875,570.0,-505.046875,1630.0,-971.63556,1483.60852,44.97794},
    {-2130.0,1630.0,-646.0,3000.0,-1487.93323,2443.58228,48.63973},
    {-3000.0,2052.0,-2130.0,3000.0,-2636.31177,2253.28149,8.70918}
};

forward Radio_UseItem(playerid,uid,item,extra);

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
stock Float:Radio_GetDistance(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);

    for (new i = 0;i < RADIO_ZONES;i++)
    {
        if (x >= s_RadioZones[i][E_RADIO_MIN_X] && x <= s_RadioZones[i][E_RADIO_MAX_X] && y >= s_RadioZones[i][E_RADIO_MIN_Y] && y <= s_RadioZones[i][E_RADIO_MAX_Y])
        {
            return GetPlayerDistanceFromPoint(playerid,s_RadioZones[i][E_RADIO_POLE_X],s_RadioZones[i][E_RADIO_POLE_Y],s_RadioZones[i][E_RADIO_POLE_Z]);
        }
    }

    return -1.0;
}

stock Radio_ScrambleCount(Float:distance,length)
{
    new count = 0;

    if (distance >= 300.0)
    {
        count = 12;
    }
    else if (distance >= 250.0)
    {
        count = 10;
    }
    else if (distance >= 200.0)
    {
        count = 8;
    }
    else if (distance >= 150.0)
    {
        count = 6;
    }
    else if (distance >= 100.0)
    {
        count = 4;
    }
    else if (distance >= 50.0)
    {
        count = 2;
    }

    if (length < count)
    {
        count = count / 2;
    }

    return count;
}

stock Radio_Scramble(const text[],count,dest[],size = sizeof(dest))
{
    strcopy(dest,text,size);

    for (new i = 0;i < count;i++)
    {
        new length = strlen(dest);

        if (length == 0)
        {
            break;
        }

        new replace = random(length), bool:space = dest[replace] == ' ';
        strdel(dest,replace,replace + 1);
        strins(dest,space ? ("..") : ("."),replace,size);
    }
}

static bool:Radio_Has(playerid)
{
    return Inventory_FindExtra(playerid,E_ITEM_EXTRA_RADIO) != INV_ROW_NONE;
}

static Radio_Send(playerid,const text[])
{
    new Float:yards = Radio_GetDistance(playerid);

    if (yards < 0.0)
    {
        SendClientMessage(playerid,-1,"Your transmitted message was responded by a static noise. Seems like you're not in a transmission zone.");
        return;
    }

    new name[ACCOUNT_NAME_LEN], line[256];
    Posse_DisplayName(playerid,false,name);
    format(line,sizeof(line),"** {96713E}[Transmission]{CCAB7C} %s: %s **",name,text);
    SendSplitMessage(playerid,0xCCAB7CFF,line);

    foreach (new i : Player)
    {
        if (i == playerid || !Posse_IsLawMember(i) || !Radio_Has(i))
        {
            continue;
        }

        new Float:distance = Radio_GetDistance(i);

        if (distance < 0.0)
        {
            continue;
        }

        new rippled[RADIO_TEXT_LEN + 24];
        Radio_Scramble(text,Radio_ScrambleCount(distance,strlen(text)),rippled);
        format(line,sizeof(line),"** {96713E}[Transmission]{CCAB7C} %s: %s **",name,rippled);
        SendSplitMessage(i,0xCCAB7CFF,line);
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
CMD:td(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[RADIO_TEXT_LEN];

    if (!Posse_IsLawMember(playerid))
    {
        SendServerMessage(playerid,"You have to be in a police posse in order to do this command.",MSG_TYPE_INFO);
        return 1;
    }

    if (!Radio_Has(playerid))
    {
        SendServerMessage(playerid,"You need a transmission device to use this command.",MSG_TYPE_INFO);
        return 1;
    }

    if (sscanf(params,"s[144]",text))
    {
        SendServerMessage(playerid,"/t(ransmission)d(evice)(/r(adio)) [text]",MSG_TYPE_ERROR);
        return 1;
    }

    Radio_Send(playerid,text);
    return 1;
}

ALT:transmissiondevice=CMD:td;
ALT:radio=CMD:td;
ALT:r=CMD:td;

public Radio_UseItem(playerid,uid,item,extra)
{
    SendServerMessage(playerid,"/t(ransmission)d(evice)(/r(adio)) [text]",MSG_TYPE_INFO);
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
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_RADIO,"Radio_UseItem");

    for (new i = 0;i < RADIO_ZONES;i++)
    {
        new pole = _:CreateDynamicObject(3244,s_RadioZones[i][E_RADIO_POLE_X],s_RadioZones[i][E_RADIO_POLE_Y],s_RadioZones[i][E_RADIO_POLE_Z],0.0,0.0,0.0);
        SetDynamicObjectMaterial(STREAMER_TAG_OBJECT:pole,0,12937,"sw_oldshack","rustc256128",0xFFFFFFFF);
    }
}
