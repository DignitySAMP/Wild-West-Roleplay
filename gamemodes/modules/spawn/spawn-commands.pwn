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
CMD:spawn(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!strcmp(params,"newb"))
    {
        Spawn_SetChoice(playerid,E_SPAWN_CHOICE_GLOBAL);
        SendServerMessage(playerid,"You will now spawn at the global spawn.",MSG_TYPE_INFO);
    }
    else if (!strcmp(params,"town"))
    {
        Spawn_SetChoice(playerid,E_SPAWN_CHOICE_TOWN);
        SendServerMessage(playerid,"You will now spawn in your town of origin.",MSG_TYPE_INFO);
    }
    else if (!strcmp(params,"location"))
    {
        Spawn_SetChoice(playerid,E_SPAWN_CHOICE_LOCATION);
        SendServerMessage(playerid,"You will now spawn where you last logged out at.",MSG_TYPE_INFO);
    }
    else if (!strcmp(params,"house") || !strcmp(params,"biz") || !strcmp(params,"faction"))
    {
        new choice = E_SPAWN_CHOICE_HOUSE;

        if (!strcmp(params,"biz"))
        {
            choice = E_SPAWN_CHOICE_BUSINESS;
        }
        else if (!strcmp(params,"faction"))
        {
            choice = E_SPAWN_CHOICE_FACTION;
        }

        if (!Spawn_IsChoiceAvailable(choice))
        {
            SendServerMessage(playerid,"That spawn option is not available on the server yet.",MSG_TYPE_ERROR);
            return 1;
        }

        pawn_call_public("Spawn_OnChoiceRequest","dd",playerid,choice);
    }
    else
    {
        SendServerMessage(playerid,"/spawn [newb, town, house, biz, faction, location]",MSG_TYPE_ERROR);
    }

    return 1;
}
