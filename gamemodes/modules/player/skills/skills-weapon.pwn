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
#define SKILL_HOLSTER_BASE (3000)

static const s_SkillHolsterDelay[4] = {3000,2000,1000,500};

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
stock Skills_GetHolsterDelay(playerid)
{
    new level = Skills_Get(playerid,E_SKILL_GUN_HOLSTER);

    if (level < 0 || level >= sizeof(s_SkillHolsterDelay))
    {
        return SKILL_HOLSTER_BASE;
    }

    return s_SkillHolsterDelay[level];
}

stock Skills_GetSway(playerid,weapon)
{
    switch (Skills_Get(playerid,E_SKILL_GUN_AIMING))
    {
        case 0:
        {
            return 3000;
        }
        case 1:
        {
            if (weapon == 24 || weapon == 26)
            {
                return 1500;
            }

            return weapon == 25 ? 2000 : 2500;
        }
        case 2:
        {
            if (weapon == 24 || weapon == 26)
            {
                return 0;
            }

            return weapon == 25 ? 1000 : 2000;
        }
        case 3:
        {
            if (weapon == 24 || weapon == 26 || weapon == 25)
            {
                return 0;
            }

            return 1000;
        }
    }

    return 0;
}

stock Skills_ApplyWeaponSkills(playerid)
{
    new eagle = 1, shotgun = 1, sawnoff = 1, sniper = 1;

    switch (Skills_Get(playerid,E_SKILL_GUN_MOVEMENT))
    {
        case 1:
        {
            eagle = 200;
        }
        case 2:
        {
            eagle = 400;
            shotgun = 200;
        }
        case 3:
        {
            eagle = 600;
            shotgun = 400;
            sawnoff = 200;
        }
        case 4:
        {
            eagle = 800;
            shotgun = 600;
            sawnoff = 400;
            sniper = 200;
        }
        case 5:
        {
            eagle = 800;
            shotgun = 800;
            sawnoff = 600;
            sniper = 400;
        }
        case 6:
        {
            eagle = 1000;
            shotgun = 1000;
            sawnoff = 800;
            sniper = 600;
        }
    }

    SetPlayerSkillLevel(playerid,WEAPONSKILL_DESERT_EAGLE,eagle);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_SHOTGUN,shotgun);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_SAWNOFF_SHOTGUN,sawnoff);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_SNIPERRIFLE,sniper);

    if (Skills_Get(playerid,E_SKILL_MELEE_STYLE) >= 1)
    {
        SetPlayerFightingStyle(playerid,FIGHT_STYLE_BOXING);
    }
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

hook Skills_OnChanged(playerid)
{
    if (IsPlayerConnected(playerid))
    {
        Skills_ApplyWeaponSkills(playerid);
    }
}

hook Spawn_OnComplete(playerid)
{
    Skills_ApplyWeaponSkills(playerid);
}
