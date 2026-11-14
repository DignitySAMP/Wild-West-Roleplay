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
Timer_Declare(Wildlife_Timer)
{

    Wildlife_Tick();
    return 1;
}

public Wildlife_OnMove(id)
{
    return 1;
}

public Wildlife_OnShot(playerid,id)
{
    return 1;
}

public Wildlife_OnKilled(id,weapon)
{
    return 1;
}

public Wildlife_OnSkinned(playerid,id)
{
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
    Wildlife_Init();
    Timer_Start(Wildlife_Timer,WILDLIFE_TICK_MS);
}

hook OnDynamicObjectMoved(STREAMER_TAG_OBJECT:objectid)
{
    new id = Wildlife_FindByObject(_:objectid);

    if (id != WILDLIFE_NONE)
    {
        Wildlife_NextLeg(id);
    }
}

hook OnPlayerShootDynamicObject(playerid,weaponid,STREAMER_TAG_OBJECT:objectid,Float:x,Float:y,Float:z)
{
    new id = Wildlife_FindByObject(_:objectid);

    if (id == WILDLIFE_NONE)
    {
        return;
    }

    Wildlife_Shot(id,weaponid);
    pawn_call_public("Wildlife_OnShot","dd",playerid,id);
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if ((newkeys & KEY_WALK) != KEY:0 && (oldkeys & KEY_WALK) == KEY:0 && Inventory_GetEquipped(playerid) == E_ITEM_EXTRA_HUNTING_KNIFE)
    {
        Wildlife_TrySkin(playerid);
    }
}

hook OnPlayerDisconnect(playerid,reason)
{
    Wildlife_PlayerLeft(playerid);
}

hook OnPlayerConnect(playerid)
{
    Wildlife_PlayerLeft(playerid);
}
