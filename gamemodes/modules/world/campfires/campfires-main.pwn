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
    Campfire_Init();

    for (new i = 0;i < Cooking_Locations();i++)
    {
        new Float:x, Float:y, Float:z;
        Cooking_GetLocation(i,x,y,z);
        CreateDynamic3DTextLabel("Cooking Location{FFFFFF}\nUse uncooked meat items to cook them here.",0xFFA500FF,x,y,z,10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1);
    }
}

hook World_OnTick(now)
{
    Campfire_Tick(now);
}

hook OnPlayerConnect(playerid)
{
    Campfire_Remove(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Campfire_Remove(playerid);
}

hook Shop_OnSellAttempt(playerid,uid,item)
{
    new extra = Item_GetExtra(item);

    if (extra != E_ITEM_EXTRA_WILDLIFE_MEAT && extra != E_ITEM_EXTRA_WILDLIFE_MEAT_LEG)
    {
        return;
    }

    if (!Cooking_IsNear(playerid))
    {
        return;
    }

    Shop_SetSellHandled(playerid);
    SetTimerEx("Cooking_PromptDeferred",0,false,"ddd",playerid,Account_GetToken(playerid),uid);
}
