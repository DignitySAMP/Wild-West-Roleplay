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
#define GEOIP_URL "ip-api.com/json/"
#define GEOIP_FIELDS "?fields=status,message,country,regionName,city,zip,timezone,isp,query"
#define GEOIP_TIMEOUT_MS (10000)
#define GEOIP_FIELD_LEN (48)
#define GEOIP_SLOTS (1024)

static s_GeoUrl[64] = GEOIP_URL;
static bool:s_GeoPending[MAX_PLAYERS];
static s_GeoTarget[MAX_PLAYERS];
static s_GeoTicket[MAX_PLAYERS];
static s_GeoToken[MAX_PLAYERS];

forward Geo_OnResponse(index,responseCode,const data[]);
forward Geo_Timeout(playerid,token,ticket);

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
stock Geo_BuildUrl(const ip[],dest[],size = sizeof(dest))
{
    format(dest,size,"%s%s%s",s_GeoUrl,ip,GEOIP_FIELDS);
}

stock bool:Geo_ReadField(const body[],const key[],dest[],size = sizeof(dest))
{
    dest[0] = EOS;
    new needle[40];
    format(needle,sizeof(needle),"\"%s\":\"",key);
    new start = strfind(body,needle);

    if (start == -1)
    {
        return false;
    }

    start += strlen(needle);
    new length = 0;

    while (body[start + length] != EOS && body[start + length] != '"' && length < size - 1)
    {
        dest[length] = body[start + length];
        length++;
    }

    dest[length] = EOS;
    return true;
}

static Geo_Show(playerid,targetid,const body[])
{
    new country[GEOIP_FIELD_LEN], region[GEOIP_FIELD_LEN], city[GEOIP_FIELD_LEN], isp[GEOIP_FIELD_LEN], zip[GEOIP_FIELD_LEN], zone[GEOIP_FIELD_LEN], ip[GEOIP_FIELD_LEN];
    Geo_ReadField(body,"country",country);
    Geo_ReadField(body,"regionName",region);
    Geo_ReadField(body,"city",city);
    Geo_ReadField(body,"isp",isp);
    Geo_ReadField(body,"zip",zip);
    Geo_ReadField(body,"timezone",zone);
    Geo_ReadField(body,"query",ip);

    new line[256], name[ACCOUNT_NAME_LEN];
    GetPlayerName(targetid,name,sizeof(name));
    format(line,sizeof(line),"(%d) %s's GEODATA (IP: %s) [TIMEZONE: %s]",targetid,name,ip,zone);
    SendClientMessage(playerid,COLOR_YELLOW,line);
    format(line,sizeof(line),"Country: %s - Region: %s - City: %s - ISP: %s - Zipcode: %s",country,region,city,isp,zip);
    SendClientMessage(playerid,COLOR_YELLOW,line);
}

static Geo_Fail(playerid,const reason[])
{
    new line[128];
    format(line,sizeof(line),"The IP lookup failed: %s.",reason);
    SendServerMessage(playerid,line,MSG_TYPE_ERROR);
}

stock bool:Geo_Handle(playerid,targetid,responseCode,const body[])
{
    if (!Staff_IsModerator(playerid))
    {
        return false;
    }

    if (responseCode != 200)
    {
        if (responseCode == 429)
        {
            Geo_Fail(playerid,"the service is limiting requests, try again in a minute");
        }
        else
        {
            Geo_Fail(playerid,"the service did not answer");
        }

        return false;
    }

    new status[16];

    if (!Geo_ReadField(body,"status",status) || strcmp(status,"success") != 0)
    {
        new reason[GEOIP_FIELD_LEN];

        if (!Geo_ReadField(body,"message",reason) || reason[0] == EOS)
        {
            strcopy(reason,"the answer could not be read");
        }

        Geo_Fail(playerid,reason);
        return false;
    }

    Geo_Show(playerid,targetid,body);
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
CMD:geoip(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_BASIC))
    {
        return 1;
    }

    new target;

    if (sscanf(params,"u",target))
    {
        SendServerMessage(playerid,"/geoip [target]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,target,"This player needs to be connected."))
    {
        return 1;
    }

    new line[160], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(target,targetName,sizeof(targetName));
    format(line,sizeof(line),"[GEO] %s (%d) has checked %s (%d)'s geo data.",name,playerid,targetName,target);
    SendModeratorWarning(line,MOD_WARNING_MED);
    Staff_Log("mod/trace",line);

    if (s_GeoUrl[0] == EOS)
    {
        SendServerMessage(playerid,"The IP lookup service is not configured on this server.",MSG_TYPE_ERROR);
        return 1;
    }

    if (s_GeoPending[playerid])
    {
        SendServerMessage(playerid,"Wait for your last IP lookup to finish.",MSG_TYPE_ERROR);
        return 1;
    }

    new ip[16], url[160];
    GetPlayerIp(target,ip,sizeof(ip));
    Geo_BuildUrl(ip,url);
    s_GeoPending[playerid] = true;
    s_GeoTarget[playerid] = target;
    s_GeoToken[playerid] = Account_GetToken(playerid);
    s_GeoTicket[playerid] = (s_GeoTicket[playerid] + 1) % 1000;

    if (!HTTP(playerid + GEOIP_SLOTS * s_GeoTicket[playerid],HTTP_GET,url,"","Geo_OnResponse"))
    {
        s_GeoPending[playerid] = false;
        Geo_Fail(playerid,"the request could not be sent");
        return 1;
    }

    SetTimerEx("Geo_Timeout",GEOIP_TIMEOUT_MS,false,"ddd",playerid,s_GeoToken[playerid],s_GeoTicket[playerid]);
    return 1;
}

/**
 *                        __  __  __                            __
 *                       |  \|  \|  \                          |  |
 *      _______  ______  | $$| $$| $$____    ______    _______ | $$   __   _______
 *     /       \|      \ | $$| $$| $$    \  |      \  /       \| $$  /  \ /       |
 *    |  $$$$$$$ \$$$$$$\| $$| $$| $$$$$$$\  \$$$$$$\|  $$$$$$$| $$_/  $$|  $$$$$$$
 *    | $$      /      $$| $$| $$| $$  | $$ /      $$| $$      | $$   $$  \$$    |
 *    | $$_____|  $$$$$$$| $$| $$| $$__/ $$|  $$$$$$$| $$_____ | $$$$$$\  _\$$$$$$|
 *     \$$     \\$$    $$| $$| $$| $$    $$ \$$    $$ \$$     \| $$  \$$\|       $$
 *      \$$$$$$$ \$$$$$$$ \$$ \$$ \$$$$$$$   \$$$$$$$  \$$$$$$$ \$$   \$$ \$$$$$$$
 *
 */
public Geo_OnResponse(index,responseCode,const data[])
{
    new playerid = index % GEOIP_SLOTS, ticket = index / GEOIP_SLOTS;

    if (playerid >= MAX_PLAYERS || !s_GeoPending[playerid] || s_GeoTicket[playerid] != ticket)
    {
        return 1;
    }

    s_GeoPending[playerid] = false;

    if (!Account_IsCurrent(playerid,s_GeoToken[playerid]) || !Staff_IsValidTarget(s_GeoTarget[playerid]))
    {
        return 1;
    }

    Geo_Handle(playerid,s_GeoTarget[playerid],responseCode,data);
    return 1;
}

public Geo_Timeout(playerid,token,ticket)
{
    if (s_GeoPending[playerid] && s_GeoTicket[playerid] == ticket && Account_IsCurrent(playerid,token))
    {
        s_GeoPending[playerid] = false;
        Geo_Fail(playerid,"the service took too long to answer");
    }

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

hook OnPlayerConnect(playerid)
{
    s_GeoPending[playerid] = false;
}
