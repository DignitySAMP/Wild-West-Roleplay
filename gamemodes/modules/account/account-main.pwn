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
public Account_OnLogout(playerid,accountid)
{
    return 1;
}

public Character_OnLoad(playerid,characterid)
{
    return 1;
}

public Character_OnLeaving(playerid,characterid)
{
    return 1;
}

public Character_OnUnload(playerid,characterid)
{
    return 1;
}

public Character_OnCreated(playerid,characterid)
{
    return 1;
}

public Character_OnSavePosition(playerid)
{
    return 1;
}

public Player_OnReady(playerid)
{
    return 1;
}

public Account_OnCharactersLoaded(playerid)
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
    bcrypt_set_thread_limit(1);
}

hook OnMigrationRun()
{
    Migration_Add("account-1-master-accounts","CREATE TABLE IF NOT EXISTS master_accounts (account_id INT UNSIGNED NOT NULL AUTO_INCREMENT, account_name VARCHAR(24) NOT NULL, account_pass CHAR(60) NOT NULL, account_registerquiz TINYINT NOT NULL DEFAULT 0, account_tutorial INT NOT NULL DEFAULT 0, account_rulecheck TINYINT NOT NULL DEFAULT 0, account_donatorlevel INT NOT NULL DEFAULT 0, account_donatorexpire INT NOT NULL DEFAULT 0, account_stafflevel INT NOT NULL DEFAULT 0, account_staffgroup INT NOT NULL DEFAULT 0, account_staffname VARCHAR(24) NOT NULL DEFAULT '', account_supportquestions INT NOT NULL DEFAULT 0, account_namechanges INT NOT NULL DEFAULT 0, account_creation VARCHAR(36) NOT NULL DEFAULT '', account_lastlogin INT NOT NULL DEFAULT 0, account_anote VARCHAR(256) NOT NULL DEFAULT '', PRIMARY KEY (account_id), UNIQUE KEY idx_account_name (account_name)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("account-2-characters","CREATE TABLE IF NOT EXISTS characters (character_id INT UNSIGNED NOT NULL AUTO_INCREMENT, account_id INT UNSIGNED NOT NULL, character_name VARCHAR(24) NOT NULL, character_gender TINYINT NOT NULL DEFAULT 0, character_origin TINYINT NOT NULL DEFAULT 0, character_town TINYINT NOT NULL DEFAULT 0, character_skin INT NOT NULL DEFAULT 0, character_age INT NOT NULL DEFAULT 0, character_level INT NOT NULL DEFAULT 1, character_hours INT NOT NULL DEFAULT 0, character_expleft INT NOT NULL DEFAULT 8, character_spawnpoint TINYINT NOT NULL DEFAULT 0, character_pos_x FLOAT NOT NULL DEFAULT 0, character_pos_y FLOAT NOT NULL DEFAULT 0, character_pos_z FLOAT NOT NULL DEFAULT 0, character_pos_interior INT NOT NULL DEFAULT 0, character_pos_vw INT NOT NULL DEFAULT 0, character_crashed TINYINT NOT NULL DEFAULT 0, character_created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (character_id), UNIQUE KEY idx_character_name (character_name), KEY idx_character_account (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}
