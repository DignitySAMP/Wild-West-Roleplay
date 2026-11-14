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
#define SHELL_RING (150)
#define SHELL_RANGE (2.5)
#define SHELL_MODEL (1666)
#define SHELL_NONE (-1)

enum e_SHELL
{
    bool:E_SHELL_USED,
    E_SHELL_OBJECT,
    E_SHELL_LABEL,
    E_SHELL_WEAPON,
    E_SHELL_SHOOTER[ACCOUNT_NAME_LEN],
    Float:E_SHELL_X,
    Float:E_SHELL_Y,
    Float:E_SHELL_Z,
    E_SHELL_WORLD,
    E_SHELL_INTERIOR
}

static s_Shells[SHELL_RING][e_SHELL];
static s_ShellNext;

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
static Shell_Text(weaponid,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    switch (weaponid)
    {
        case 24: strcopy(dest,"{CFC097}.44-40 WCF shell",size);
        case 25: strcopy(dest,"{CFB497}16 gauge cartridge",size);
        case 26: strcopy(dest,"{CFA797}12 gauge cartridge",size);
        case 33: strcopy(dest,"{CF9C97}.56-56 Spencer",size);
        case 34: strcopy(dest,"{BDCF97}.58 Berdan",size);
    }
}

static Shell_Release(slot)
{
    if (s_Shells[slot][E_SHELL_OBJECT] != 0)
    {
        DestroyDynamicObject(STREAMER_TAG_OBJECT:s_Shells[slot][E_SHELL_OBJECT]);
        s_Shells[slot][E_SHELL_OBJECT] = 0;
    }

    if (s_Shells[slot][E_SHELL_LABEL] != 0)
    {
        DestroyDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:s_Shells[slot][E_SHELL_LABEL]);
        s_Shells[slot][E_SHELL_LABEL] = 0;
    }

    s_Shells[slot][E_SHELL_USED] = false;
}

stock Shell_Clear()
{
    for (new i = 0;i < SHELL_RING;i++)
    {
        Shell_Release(i);
    }

    s_ShellNext = 0;
}

stock Shell_Create(playerid,weaponid)
{
    new slot = s_ShellNext, Float:x, Float:y, Float:z, Float:nx, Float:ny, Float:nz, Float:rx, Float:ry, Float:rz, line[48], world = GetPlayerVirtualWorld(playerid), interior = GetPlayerInterior(playerid);
    s_ShellNext = (s_ShellNext + 1) % SHELL_RING;
    Shell_Release(slot);
    GetPlayerPos(playerid,x,y,z);
    CA_RayCastLineAngle(x,y,z + 5.0,x,y,z - 5.0,nx,ny,nz,rx,ry,rz);
    s_Shells[slot][E_SHELL_USED] = true;
    s_Shells[slot][E_SHELL_WEAPON] = weaponid;
    Name_Real(playerid,s_Shells[slot][E_SHELL_SHOOTER]);
    s_Shells[slot][E_SHELL_X] = x;
    s_Shells[slot][E_SHELL_Y] = y;
    s_Shells[slot][E_SHELL_Z] = z - 0.9;
    s_Shells[slot][E_SHELL_WORLD] = world;
    s_Shells[slot][E_SHELL_INTERIOR] = interior;
    format(line,sizeof(line),"[SHELL %d]\n(( /shell ))",slot);
    s_Shells[slot][E_SHELL_LABEL] = _:CreateDynamic3DTextLabel(line,0xDEDEDEAA,x,y,z - 0.8,SHELL_RANGE,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,world,interior);
    s_Shells[slot][E_SHELL_OBJECT] = _:CreateDynamicObject(SHELL_MODEL,x,y,z - 0.9,rx,ry + 90.0,rz,world,interior);
    SetDynamicObjectMaterial(STREAMER_TAG_OBJECT:s_Shells[slot][E_SHELL_OBJECT],0,2061,"CJ_AMMO","CJ_BULLETBRASS");
    return slot;
}

stock Shell_Count()
{
    new count;

    for (new i = 0;i < SHELL_RING;i++)
    {
        if (s_Shells[i][E_SHELL_USED])
        {
            count++;
        }
    }

    return count;
}

stock Shell_NextSlot()
{
    return s_ShellNext;
}

stock bool:Shell_IsUsed(slot)
{
    return slot >= 0 && slot < SHELL_RING && s_Shells[slot][E_SHELL_USED];
}

stock Shell_GetWeapon(slot)
{
    return slot >= 0 && slot < SHELL_RING ? s_Shells[slot][E_SHELL_WEAPON] : 0;
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
CMD:shell(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    for (new i = 0;i < SHELL_RING;i++)
    {
        if (!s_Shells[i][E_SHELL_USED] || s_Shells[i][E_SHELL_WORLD] != GetPlayerVirtualWorld(playerid) || s_Shells[i][E_SHELL_INTERIOR] != GetPlayerInterior(playerid))
        {
            continue;
        }

        if (!IsPlayerInRangeOfPoint(playerid,SHELL_RANGE,s_Shells[i][E_SHELL_X],s_Shells[i][E_SHELL_Y],s_Shells[i][E_SHELL_Z]))
        {
            continue;
        }

        new line[128], text[40];
        Shell_Text(s_Shells[i][E_SHELL_WEAPON],text);
        SendClientMessage(playerid,COLOR_TAB0,"Gunshell Information");
        format(line,sizeof(line),"[Gun shell: %d, %d, %s{BA9E72}]",i,i,text);
        SendClientMessage(playerid,COLOR_TAB1,line);

        if (Staff_IsModerator(playerid) && Staff_GetGroup(playerid) >= E_STAFF_GROUP_BASIC)
        {
            format(line,sizeof(line),"(( Fired by: %s ))",s_Shells[i][E_SHELL_SHOOTER]);
            SendClientMessage(playerid,COLOR_TAB2,line);
        }

        return 1;
    }

    SendServerMessage(playerid,"You're not near a gun shell.",MSG_TYPE_ERROR);
    return 1;
}

CMD:clearshells(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_BASIC))
    {
        return 1;
    }

    new line[128], name[ACCOUNT_NAME_LEN];
    Shell_Clear();
    Name_Real(playerid,name);
    format(line,sizeof(line),"[GUNSHELLS] %s (%d) has cleared the gunshells.",name,playerid);
    SendModeratorWarning(line,MOD_WARNING_MED);
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
    for (new i = 0;i < SHELL_RING;i++)
    {
        s_Shells[i][E_SHELL_USED] = false;
        s_Shells[i][E_SHELL_OBJECT] = 0;
        s_Shells[i][E_SHELL_LABEL] = 0;
    }
}

hook Weapon_OnShot(playerid,weaponid,ammo)
{
    Shell_Create(playerid,weaponid);
}
