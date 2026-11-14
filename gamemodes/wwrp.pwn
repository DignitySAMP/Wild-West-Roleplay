/*
    Wild West Roleplay, the SA-MP 0.3.DL roleplay server that ran in 2016 and 2018.
    By DignitySAMP (project lead), DTVSamp and Rusu (main developers).
    Rewritten for open.mp (PawnPlus, pawn-plus-mysql, MySQL R41-4, pp-hooks, streamer, sscanf, SmartCMD, samp-bcrypt, strlib, ColAndreas, crashdetect).
*/

#pragma dynamic 2100000

#include "modules/core/includes.pwn"
#include "modules/core/definitions.pwn"
#include "modules/core/mysql.pwn"
#include "modules/util/util-header.pwn"
#include "modules/core/database.pwn"
#include "modules/core/callbacks.pwn"
#include "modules/world/audio/audio-header.pwn"
#include "modules/world/intro/intro-header.pwn"
#include "modules/account/account-header.pwn"
#include "modules/spawn/spawn-header.pwn"
#include "modules/staff/staff-header.pwn"
#include "modules/player/levels/levels-header.pwn"
#include "modules/donator/donator-header.pwn"
#include "modules/economy/economy-header.pwn"
#include "modules/gui/gui-header.pwn"
#include "modules/world/time/time-header.pwn"
#include "modules/player/needs/needs-header.pwn"
#include "modules/staff/staff-tools-header.pwn"
#include "modules/world/world-header.pwn"
#include "modules/inventory/inventory-header.pwn"
#include "modules/player/skills/skills-header.pwn"
#include "modules/weapons/weapons-header.pwn"
#include "modules/jobs/gunsmith/gunsmith-header.pwn"
#include "modules/property/property-header.pwn"
#include "modules/economy/bank/bank-header.pwn"
#include "modules/economy/shops/shops-header.pwn"
#include "modules/posse/posse-header.pwn"
#include "modules/player/injury/injury-header.pwn"
#include "modules/vehicles/horses/horses-header.pwn"
#include "modules/world/wildlife/wildlife-header.pwn"
#include "modules/jobs/core/jobs-header.pwn"
#include "modules/jobs/farming/farming-header.pwn"
#include "modules/jobs/traps/traps-header.pwn"
#include "modules/player/lasso/lasso-header.pwn"
#include "modules/world/temperature/temperature-header.pwn"
#include "modules/world/zones/zones-header.pwn"
#include "modules/world/campfires/campfires-header.pwn"
#include "modules/world/gates/gates-header.pwn"
#include "modules/world/transport/transport-header.pwn"
#include "modules/world/fires/fires-header.pwn"
#include "modules/player/mask/mask-header.pwn"
#include "modules/player/afk/afk-data.pwn"
#include "modules/player/nametags/nametags-header.pwn"
#include "modules/player/afk/afk-header.pwn"
#include "modules/player/anims/anims-header.pwn"
#include "modules/player/chat/chat-header.pwn"
#include "modules/player/interaction/interaction-header.pwn"
#include "modules/player/attachments/attachments-header.pwn"
#include "modules/world/labels/labels-header.pwn"
#include "modules/games/games-header.pwn"
#include "modules/staff/anticheat/anticheat-header.pwn"
#include "modules/world/actors/actors-header.pwn"
#include "modules/player/tutorial/tutorial-header.pwn"
#include "modules/weapons/shells/shells-header.pwn"
#include "modules/property/telegram/telegram-header.pwn"
#include "modules/economy/lottery/lottery-header.pwn"
#include "modules/core/motd/motd-header.pwn"
#include "modules/core/help/help-header.pwn"
#include "modules/core/updates/updates-header.pwn"
#include "modules/player/settings/settings-header.pwn"

main()
{
    print(" ");
    print(" Wild West Roleplay");
    print(" ");
}

public OnGameModeInit()
{
    SetGameModeText("Wild West Roleplay");
    Boot_Run();
    return 1;
}

forward OnServerFinishLoading();
public OnServerFinishLoading()
{
    Log_Info("boot", "Wild West Roleplay %s ready - %d slots", WWRP_VERSION, MAX_PLAYERS);
    return 1;
}
