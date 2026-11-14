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
public Character_OnRenamed(playerid,characterid)
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
    Timer_Start(Restart_Timer,RESTART_TICK_MS);
}

hook OnMigrationRun()
{
    Migration_Add("staff-1-bans","CREATE TABLE IF NOT EXISTS bans (ban_id INT UNSIGNED NOT NULL AUTO_INCREMENT, account_id INT UNSIGNED NOT NULL, account_name VARCHAR(24) NOT NULL DEFAULT '', ip VARCHAR(45) NOT NULL DEFAULT '', ban_admin VARCHAR(24) NOT NULL DEFAULT '', ban_reason VARCHAR(96) NOT NULL DEFAULT '', ban_time INT NOT NULL DEFAULT 0, unban_time INT NOT NULL DEFAULT 0, PRIMARY KEY (ban_id), KEY idx_ban_account (account_id), KEY idx_ban_ip (ip)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("staff-2-admin-record","CREATE TABLE IF NOT EXISTS admin_record (record_id INT UNSIGNED NOT NULL AUTO_INCREMENT, account_id INT UNSIGNED NOT NULL, record_type TINYINT NOT NULL DEFAULT 0, record_reason VARCHAR(64) NOT NULL DEFAULT '', record_time INT NOT NULL DEFAULT 0, record_admin INT NOT NULL DEFAULT 0, record_date VARCHAR(36) NOT NULL DEFAULT '', PRIMARY KEY (record_id), KEY idx_record_account (account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("staff-3-character-ajail","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_ajailed INT NOT NULL DEFAULT 0");
}
