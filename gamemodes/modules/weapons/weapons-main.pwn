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

hook OnMigrationRun()
{
    Migration_Add("weapons-1-slots","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_handweapon INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_handammo INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_pantsweapon INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_pantsammo INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_backweapon INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_backammo INT NOT NULL DEFAULT 0");
    Migration_Add("weapons-2-trouser-offsets","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_trousergun_offsetx FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_trousergun_offsety FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_trousergun_offsetz FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_trousergun_rotx FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_trousergun_roty FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_trousergun_rotz FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_trousergun_scalex FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_trousergun_scaley FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_trousergun_scalez FLOAT NOT NULL DEFAULT 0");
    Migration_Add("weapons-3-back-offsets","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_backgun_offsetx FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_backgun_offsety FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_backgun_offsetz FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_backgun_rotx FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_backgun_roty FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_backgun_rotz FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_backgun_scalex FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_backgun_scaley FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_backgun_scalez FLOAT NOT NULL DEFAULT 0");
}

hook OnPlayerEditAttachedObject(playerid,EDIT_RESPONSE:response,index,modelid,boneid,Float:fOffsetX,Float:fOffsetY,Float:fOffsetZ,Float:fRotX,Float:fRotY,Float:fRotZ,Float:fScaleX,Float:fScaleY,Float:fScaleZ)
{
    if (index != WEAPON_SLOT_PANTS && index != WEAPON_SLOT_BACK)
    {
        return;
    }

    if (response != EDIT_RESPONSE_FINAL)
    {
        Weapons_Attachments(playerid);
        return;
    }

    if (fScaleX != 1.0 || fScaleY != 1.0 || fScaleZ != 1.0)
    {
        SendServerMessage(playerid,"You cannot adjust the scale of the gun.",MSG_TYPE_ERROR);
        fScaleX = 1.0;
        fScaleY = 1.0;
        fScaleZ = 1.0;
    }

    new Float:values[WEAPON_OFFSETS];
    values[0] = fOffsetX;
    values[1] = fOffsetY;
    values[2] = fOffsetZ;
    values[3] = fRotX;
    values[4] = fRotY;
    values[5] = fRotZ;
    values[6] = fScaleX;
    values[7] = fScaleY;
    values[8] = fScaleZ;
    Weapons_SetOffsets(playerid,index == WEAPON_SLOT_PANTS ? E_GUN_SLOT_PANTS : E_GUN_SLOT_BACK,values);
    SendServerMessage(playerid,index == WEAPON_SLOT_PANTS ? ("Adjusted weapon position on your trousers slot. It should save when you relog.") : ("Adjusted weapon position on your back slot. It should save when you relog."),MSG_TYPE_INFO);
    Weapons_Attachments(playerid);
}
