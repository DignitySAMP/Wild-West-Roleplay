#include <pp-hooks>

hook OnMigrationRun()
{
    Migration_Add("posse-1-posses","CREATE TABLE IF NOT EXISTS posses (posse_id INT UNSIGNED NOT NULL AUTO_INCREMENT, posse_type INT NOT NULL DEFAULT 1, posse_name VARCHAR(36) NOT NULL DEFAULT '', posse_slots INT NOT NULL DEFAULT 6, posse_color INT NOT NULL DEFAULT -1, posse_spawn_x FLOAT NOT NULL DEFAULT 0, posse_spawn_y FLOAT NOT NULL DEFAULT 0, posse_spawn_z FLOAT NOT NULL DEFAULT 0, posse_spawn_int INT NOT NULL DEFAULT 0, posse_spawn_vw INT NOT NULL DEFAULT 0, posse_bank INT NOT NULL DEFAULT 0, posse_bank_decimal INT NOT NULL DEFAULT 0, PRIMARY KEY (posse_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("posse-2-kiosk","CREATE TABLE IF NOT EXISTS possekiosk (kiosk_id INT UNSIGNED NOT NULL, kiosk_x FLOAT NOT NULL DEFAULT 0, kiosk_y FLOAT NOT NULL DEFAULT 0, kiosk_z FLOAT NOT NULL DEFAULT 0, kiosk_rx FLOAT NOT NULL DEFAULT 0, kiosk_ry FLOAT NOT NULL DEFAULT 0, kiosk_rz FLOAT NOT NULL DEFAULT 0, kiosk_locked TINYINT NOT NULL DEFAULT 0, PRIMARY KEY (kiosk_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("posse-3-charges","CREATE TABLE IF NOT EXISTS charges (charge_id INT UNSIGNED NOT NULL AUTO_INCREMENT, charge_placer VARCHAR(24) NOT NULL DEFAULT '', charge_holder VARCHAR(24) NOT NULL DEFAULT '', charge_amount INT NOT NULL DEFAULT 0, charge_change INT NOT NULL DEFAULT 0, charge_info VARCHAR(32) NOT NULL DEFAULT '', charge_date VARCHAR(48) NOT NULL DEFAULT '', PRIMARY KEY (charge_id), KEY idx_charge_holder (charge_holder)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("posse-4-posters","CREATE TABLE IF NOT EXISTS wanted_posters (poster_id INT UNSIGNED NOT NULL AUTO_INCREMENT, poster_name VARCHAR(24) NOT NULL DEFAULT '', poster_skin INT NOT NULL DEFAULT 0, poster_price INT NOT NULL DEFAULT 0, poster_jailtime TINYINT NOT NULL DEFAULT 0, poster_vw INT NOT NULL DEFAULT 0, poster_int INT NOT NULL DEFAULT 0, poster_x FLOAT NOT NULL DEFAULT 0, poster_y FLOAT NOT NULL DEFAULT 0, poster_z FLOAT NOT NULL DEFAULT 0, poster_rx FLOAT NOT NULL DEFAULT 0, poster_ry FLOAT NOT NULL DEFAULT 0, poster_rz FLOAT NOT NULL DEFAULT 0, PRIMARY KEY (poster_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("posse-5-character-columns","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_posse INT NOT NULL DEFAULT -1, ADD COLUMN IF NOT EXISTS character_possetier INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_posserank VARCHAR(36) NOT NULL DEFAULT 'None', ADD COLUMN IF NOT EXISTS character_prison INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_prison_pos_x FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_prison_pos_y FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_prison_pos_z FLOAT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_prison_interior INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_prison_vw INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_prison_bail INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_prison_bail_cents INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_bounty_id INT NOT NULL DEFAULT -1");
}

hook OnGameModeInit()
{
    Posse_InitPool();
    Kiosk_InitPool();
    Poster_InitPool();
    PosterGui_Build();
    Boot_RegisterLoader("Posse_Load");
    Boot_RegisterLoader("Kiosk_Load","Posse_Load");
    Boot_RegisterLoader("Poster_Load");
    Spawn_RegisterChoice(E_SPAWN_CHOICE_FACTION);
}

hook OnPlayerConnect(playerid)
{
    Posse_ResetPlayer(playerid);
}

hook Character_OnLoad(playerid,characterid)
{
    mysql_tquery_s(g_Mysql,str_format("SELECT character_posse, character_possetier, character_posserank FROM characters WHERE character_id = %d",characterid),"Posse_OnMemberLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    Posse_ResetPlayer(playerid);
}

hook Spawn_OnChoiceRequest(playerid,choice)
{
    if (choice != E_SPAWN_CHOICE_FACTION)
    {
        return;
    }

    new posse[e_POSSE];

    if (!Posse_Get(Posse_GetPlayer(playerid),posse) || (posse[E_POSSE_SPAWN_X] == 0.0 && posse[E_POSSE_SPAWN_Y] == 0.0 && posse[E_POSSE_SPAWN_Z] == 0.0))
    {
        SendServerMessage(playerid,"There is no faction spawn set up for your faction.",MSG_TYPE_ERROR);
        return;
    }

    Spawn_SetChoice(playerid,E_SPAWN_CHOICE_FACTION);
    SendServerMessage(playerid,"You will now spawn at your faction's spawnpoint",MSG_TYPE_INFO);
}

hook Spawn_OnChoose(playerid)
{
    if (Character_GetSpawnChoice(playerid) != E_SPAWN_CHOICE_FACTION)
    {
        return;
    }

    new posse[e_POSSE];

    if (!Posse_Get(Posse_GetPlayer(playerid),posse))
    {
        return;
    }

    Spawn_SetPoint(playerid,posse[E_POSSE_SPAWN_X],posse[E_POSSE_SPAWN_Y],posse[E_POSSE_SPAWN_Z],SPAWN_DEFAULT_ANGLE,posse[E_POSSE_SPAWN_INT],posse[E_POSSE_SPAWN_VW],E_SPAWN_PRIORITY_CHOICE,"You have spawned at your faction's spawnpoint.");
}
