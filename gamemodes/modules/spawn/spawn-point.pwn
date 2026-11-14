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
forward Spawn_Followup(playerid,token,stage);

static bool:s_SpawnClientDeath[MAX_PLAYERS];

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
stock Spawn_Begin(playerid)
{
    Spawn_ClearPoint(playerid);
    Spawn_SetApplied(playerid,false);
    Spawn_SetPending(playerid,true);
    SetSpawnInfo(playerid,NO_TEAM,Character_GetSkin(playerid),SERVER_SPAWN_X,SERVER_SPAWN_Y,SERVER_SPAWN_Z,SPAWN_DEFAULT_ANGLE);
    SpawnPlayer(playerid);
}

stock Spawn_Choose(playerid)
{
    Spawn_ClearPoint(playerid);
    pawn_call_public("Spawn_OnChoose","d",playerid);

    if (Character_GetCrashed(playerid) && Spawn_GetPointPriority(playerid) < E_SPAWN_PRIORITY_CRASH)
    {
        new Float:x, Float:y, Float:z, interior, world;
        Character_GetLastPosition(playerid,x,y,z,interior,world);
        Spawn_SetPoint(playerid,x,y,z,SPAWN_DEFAULT_ANGLE,interior,world,E_SPAWN_PRIORITY_CRASH,"You've spawned where you crashed.");
        Character_ClearCrashed(playerid);
        Character_ClearCrashedCached(playerid);
    }

    if (Spawn_HasPoint(playerid))
    {
        return;
    }

    new Float:x, Float:y, Float:z;

    switch (Character_GetSpawnChoice(playerid))
    {
        case E_SPAWN_CHOICE_GLOBAL:
        {
            Spawn_SetPoint(playerid,SERVER_SPAWN_X,SERVER_SPAWN_Y,SERVER_SPAWN_Z,SERVER_SPAWN_A,0,0,E_SPAWN_PRIORITY_CHOICE);
        }
        case E_SPAWN_CHOICE_TOWN:
        {
            Spawn_GetTownPosition(Character_GetTown(playerid),x,y,z);
            Spawn_SetPoint(playerid,x,y,z,SPAWN_DEFAULT_ANGLE,0,0,E_SPAWN_PRIORITY_CHOICE);
        }
        case E_SPAWN_CHOICE_LOCATION:
        {
            new interior, world;
            Character_GetLastPosition(playerid,x,y,z,interior,world);

            if (x == 0.0 && y == 0.0 && z == 0.0)
            {
                Spawn_GetTownPosition(Character_GetTown(playerid),x,y,z);
                Spawn_SetPoint(playerid,x,y,z,SPAWN_DEFAULT_ANGLE,0,0,E_SPAWN_PRIORITY_CHOICE);
                return;
            }

            Spawn_SetPoint(playerid,x,y,z,SPAWN_DEFAULT_ANGLE,interior,world,E_SPAWN_PRIORITY_CHOICE,"You've spawned where you last logged out at.");
        }
    }
}

stock Spawn_Apply(playerid)
{
    if (!Spawn_HasPoint(playerid))
    {
        Spawn_SetApplied(playerid,true);
        return;
    }

    new Float:x, Float:y, Float:z, Float:angle, interior, world, notice[SPAWN_NOTICE_LEN];
    Spawn_GetPoint(playerid,x,y,z,angle,interior,world);
    SetPlayerInterior(playerid,interior);
    SetPlayerVirtualWorld(playerid,world);
    SetPlayerPos(playerid,x,y,z);
    SetPlayerFacingAngle(playerid,angle);
    Spawn_GetNotice(playerid,notice);
    Spawn_SetApplied(playerid,true);

    if (notice[0] != EOS)
    {
        SendServerMessage(playerid,notice,MSG_TYPE_INFO);
    }
}

static Spawn_WakeLine(playerid)
{
    switch (random(4))
    {
        case 0:
        {
            SendClientMessage(playerid,COLOR_DEFAULT,"** You've woken up from a brief nap and feel somewhat refreshed..");
        }
        case 1:
        {
            SendClientMessage(playerid,COLOR_DEFAULT,"** You've woken up with your head pounding and the smell of alcohol emitting from your clothes..");
        }
        case 2:
        {
            SendClientMessage(playerid,COLOR_DEFAULT,"** You've woken up after a fight. Your face hurts and your knuckles seem to be bloodied..");
        }
        case 3:
        {
            SendClientMessage(playerid,COLOR_DEFAULT,"** You've woken up due to a horse hinnicking loudly. You push yourself off the floor..");
        }
    }
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
public Spawn_Followup(playerid,token,stage)
{
    if (!Account_IsCurrent(playerid,token) || !Player_IsReady(playerid))
    {
        return 1;
    }

    switch (stage)
    {
        case 0:
        {
            Spawn_Choose(playerid);

            if (!Spawn_IsQuiet(playerid))
            {
                Spawn_WakeLine(playerid);
            }

            SendServerMessage(playerid,"If your character selection/creation textdraws haven't gone away, please use /fixchartds",MSG_TYPE_INFO);

            if (Character_GetAge(playerid) == 0)
            {
                Character_PromptAge(playerid,token);
            }

            SetTimerEx("Spawn_Followup",SPAWN_FOLLOWUP_MS,false,"ddd",playerid,token,1);
        }
        case 1:
        {
            Spawn_Apply(playerid);
            pawn_call_public("Spawn_OnComplete","d",playerid);
            SetTimerEx("Spawn_Followup",SPAWN_NAMECHECK_MS,false,"ddd",playerid,token,2);
        }
        case 2:
        {
            new name[ACCOUNT_NAME_LEN];
            GetPlayerName(playerid,name,sizeof(name));

            if (!Account_IsRoleplayName(name))
            {
                SendServerMessage(playerid,"There was an error processing your name. Please try relogging or create a new character.",MSG_TYPE_WARN);
                SendServerMessage(playerid,"You might want to contact the management team on the forums if you wish to retrieve it.",MSG_TYPE_WARN);
                Account_QueueKick(playerid);
            }
        }
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

hook Player_OnReady(playerid)
{
    Spawn_Begin(playerid);
}

hook OnPlayerDeath(playerid,killerid,WEAPON:reason)
{
    if (Player_IsReady(playerid))
    {
        s_SpawnClientDeath[playerid] = true;
    }
}

hook OnPlayerRequestClass(playerid,classid)
{
    if (s_SpawnClientDeath[playerid] && Player_IsReady(playerid))
    {
        s_SpawnClientDeath[playerid] = false;
        Spawn_Begin(playerid);
    }
}

hook OnPlayerSpawn(playerid)
{
    if (s_SpawnClientDeath[playerid] && Player_IsReady(playerid))
    {
        s_SpawnClientDeath[playerid] = false;
        Spawn_Begin(playerid);
        return;
    }

    if (!Spawn_IsPending(playerid) || !Player_IsReady(playerid))
    {
        return;
    }

    Spawn_SetPending(playerid,false);
    SetTimerEx("Spawn_Followup",SPAWN_FOLLOWUP_MS,false,"ddd",playerid,Account_GetToken(playerid),0);
}

hook OnPlayerConnect(playerid)
{
    s_SpawnClientDeath[playerid] = false;
    Spawn_ClearPoint(playerid);
    Spawn_SetPending(playerid,false);
    Spawn_SetApplied(playerid,false);
}
