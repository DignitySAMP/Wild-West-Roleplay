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
stock bool:Util_IsValidPlayer(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    return IsPlayerConnected(playerid);
}

stock bool:Util_IsNear(playerid,targetid,Float:radius)
{
    if (!Util_IsValidPlayer(playerid) || !Util_IsValidPlayer(targetid))
    {
        return false;
    }

    new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2;
    GetPlayerPos(playerid,x1,y1,z1);
    GetPlayerPos(targetid,x2,y2,z2);

    new Float:deltaX = x1 - x2, Float:deltaY = y1 - y2, Float:deltaZ = z1 - z2;
    return deltaX < radius && deltaX > -radius && deltaY < radius && deltaY > -radius && deltaZ < radius && deltaZ > -radius;
}

stock bool:Util_IsValidVehicle(vehicleid)
{
    if (vehicleid < 1 || vehicleid > MAX_VEHICLES)
    {
        return false;
    }

    return IsValidVehicle(vehicleid);
}

stock bool:Util_StartsWithVowel(const text[])
{
    switch (tolower(text[0]))
    {
        case 'a', 'e', 'i', 'o', 'u': return true;
    }

    return false;
}

stock bool:Util_ReadToken(const text[],&at,dest[],size = sizeof(dest))
{
    while (text[at] != EOS && text[at] <= ' ')
    {
        at++;
    }

    new length = 0;

    while (text[at] != EOS && text[at] > ' ')
    {
        if (length < size - 1)
        {
            dest[length++] = text[at];
        }

        at++;
    }

    dest[length] = EOS;
    return length > 0;
}

stock Util_ReadRest(const text[],at,dest[],size = sizeof(dest))
{
    while (text[at] != EOS && text[at] <= ' ')
    {
        at++;
    }

    new length = 0;

    while (text[at] != EOS && length < size - 1)
    {
        dest[length++] = text[at++];
    }

    dest[length] = EOS;
    return length;
}

stock Util_FirstWord(const text[],dest[],size = sizeof(dest))
{
    new at = 0;

    Util_ReadToken(text,at,dest,size);
    return strlen(dest);
}

stock Util_SkipToken(const text[],at = 0)
{
    while (text[at] != EOS && text[at] <= ' ')
    {
        at++;
    }

    while (text[at] > ' ')
    {
        at++;
    }

    return at;
}

stock Float:Util_GetDistance3D(Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2)
{
    return VectorSize(x2 - x1,y2 - y1,z2 - z1);
}

stock Util_GetPlayerName(playerid)
{
    static name[MAX_PLAYER_NAME + 1];

    name[0] = EOS;
    GetPlayerName(playerid,name,sizeof(name));
    return name;
}

stock Util_GetPlayerIp(playerid)
{
    static ip[16 + 1];

    ip[0] = EOS;
    GetPlayerIp(playerid,ip,sizeof(ip));
    return ip;
}
