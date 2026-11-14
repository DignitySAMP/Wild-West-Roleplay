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
#define COMBAT_FLUSH_MS (1000)
#define COMBAT_NONE (0)

static bool:s_CombatAiming[MAX_PLAYERS];

forward Weapon_OnShot(playerid,weaponid,ammo);

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
stock bool:Weapons_IsAiming(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_CombatAiming[playerid];
}

stock Weapons_StartAim(playerid)
{
    new weapon = Weapons_Get(playerid,E_GUN_SLOT_HAND);

    if (weapon == 0 || s_CombatAiming[playerid])
    {
        return;
    }

    s_CombatAiming[playerid] = true;
    SetPlayerDrunkLevel(playerid,Skills_GetSway(playerid,weapon));

    if (weapon == 34)
    {
        RemovePlayerAttachedObject(playerid,EQUIP_SLOT);
        RemovePlayerAttachedObject(playerid,WEAPON_SLOT_PANTS);
        RemovePlayerAttachedObject(playerid,WEAPON_SLOT_BACK);
        RemovePlayerAttachedObject(playerid,WEAPON_SLOT_HANDS);
    }
}

stock Weapons_StopAim(playerid)
{
    if (!s_CombatAiming[playerid])
    {
        return;
    }

    s_CombatAiming[playerid] = false;
    SetPlayerDrunkLevel(playerid,0);
    Weapons_Attachments(playerid);
}

stock Weapons_Shot(playerid,weaponid)
{
    if (!Player_IsReady(playerid) || !Weapons_IsLoaded(playerid))
    {
        return;
    }

    if (weaponid == 43 && Inventory_GetEquipped(playerid) == E_ITEM_EXTRA_CAMERA)
    {
        return;
    }

    new hand = Weapons_Get(playerid,E_GUN_SLOT_HAND);

    if (hand == 0 || hand != weaponid)
    {
        new line[160], name[ACCOUNT_NAME_LEN];
        GetPlayerName(playerid,name,sizeof(name));
        format(line,sizeof(line),"(%d) %s might be using a concealed weapon cheat. Spectate them immediately!",playerid,name);
        SendModeratorWarning(line,MOD_WARNING_HIGH);
        ResetPlayerWeapons(playerid);
        return;
    }

    new ammo = Weapons_GetAmmo(playerid,E_GUN_SLOT_HAND) - 1;

    if (ammo < 0)
    {
        ammo = 0;
    }

    Weapons_SetSlot(playerid,E_GUN_SLOT_HAND,hand,ammo);

    if (ammo < 1)
    {
        s_CombatAiming[playerid] = false;
        SetPlayerAttachedObject(playerid,WEAPON_SLOT_HANDS,Weapon_GetModel(hand),6,0.004,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0);
        ResetPlayerWeapons(playerid);
        SetPlayerDrunkLevel(playerid,0);
        SendServerMessage(playerid,"Your weapon has ran out of ammo. If your screen is still shaking, use /fa (/fixaim).",MSG_TYPE_ERROR);
        Weapons_Save(playerid);
    }
    else
    {
        Weapons_MarkDirty(playerid);
    }

    Weapons_SyncHud(playerid);
    pawn_call_public("Weapon_OnShot","ddd",playerid,weaponid,ammo);
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
CMD:fixaim(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (Weapons_IsAiming(playerid))
    {
        SendServerMessage(playerid,"You can't do this command whilst aiming a weapon.",MSG_TYPE_ERROR);
        return 1;
    }

    SetPlayerDrunkLevel(playerid,0);
    SendServerMessage(playerid,"Reset your shake level. If there's still an issue, aim a weapon and it should be fixed.",MSG_TYPE_WARN);
    return 1;
}

ALT:fa=CMD:fixaim;

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
public Weapon_OnShot(playerid,weaponid,ammo)
{
    return 1;
}

Timer_Declare(Weapons_FlushTimer)
{
    Weapons_FlushDirty();
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
    Timer_Start(Weapons_FlushTimer,COMBAT_FLUSH_MS);
}

hook OnPlayerConnect(playerid)
{
    s_CombatAiming[playerid] = false;
}

hook Character_OnUnload(playerid,characterid)
{
    s_CombatAiming[playerid] = false;
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (!Player_IsReady(playerid))
    {
        return;
    }

    if ((newkeys & KEY_HANDBRAKE) && !(oldkeys & KEY_HANDBRAKE))
    {
        Weapons_StartAim(playerid);
    }
    else if (!(newkeys & KEY_HANDBRAKE) && (oldkeys & KEY_HANDBRAKE))
    {
        Weapons_StopAim(playerid);
    }
}

hook OnPlayerWeaponShot(playerid,WEAPON:weaponid,BULLET_HIT_TYPE:hittype,hitid,Float:fX,Float:fY,Float:fZ)
{
    Weapons_Shot(playerid,_:weaponid);
}

hook Tick_OnPlayerSecond(playerid)
{
    if (!Player_IsReady(playerid) || !Weapons_IsLoaded(playerid))
    {
        return;
    }

    new hand = Weapons_Get(playerid,E_GUN_SLOT_HAND), armed = _:GetPlayerWeapon(playerid), equipped = Inventory_GetEquipped(playerid);

    if (equipped == E_ITEM_EXTRA_CAMERA)
    {
        hand = 43;
    }

    if (armed != hand && (hand != 0 || armed != 0))
    {
        SetPlayerArmedWeapon(playerid,WEAPON:hand);
    }

    if (s_CombatAiming[playerid] && hand != 0)
    {
        SetPlayerDrunkLevel(playerid,Skills_GetSway(playerid,hand));
    }
}
