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

#define OBJECTS_VISIBLE_ITEMS (1999)

hook OnGameModeInit()
{
    Removal_ApplyCollision();
    CA_Init();
    Gate_Init();
    Map_LoadAll();
    Roads_Load();
    Cover_Init();
    Hand_Load();
    Streamer_SetVisibleItems(STREAMER_TYPE_OBJECT,OBJECTS_VISIBLE_ITEMS);
}

hook OnPlayerConnect(playerid)
{
    Cover_Reset(playerid);
    Removal_SendToPlayer(playerid);
}

hook OnPlayerSpawn(playerid)
{
    Cover_Show(playerid);
}
