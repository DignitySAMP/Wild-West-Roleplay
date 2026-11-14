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
    Migration_Add("inventory-1-items","CREATE TABLE IF NOT EXISTS items_player (player_table_id INT UNSIGNED NOT NULL AUTO_INCREMENT, player_database_id INT UNSIGNED NOT NULL, player_item_id INT NOT NULL DEFAULT 0, player_item_amount INT NOT NULL DEFAULT 0, player_item_param1 INT NOT NULL DEFAULT 0, player_item_param2 INT NOT NULL DEFAULT 0, PRIMARY KEY (player_table_id), KEY idx_items_character (player_database_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    Migration_Add("inventory-2-dropped","CREATE TABLE IF NOT EXISTS dropped_items (dropped_id INT UNSIGNED NOT NULL AUTO_INCREMENT, dropped_player INT NOT NULL DEFAULT 0, dropped_item INT NOT NULL DEFAULT 0, dropped_amount INT NOT NULL DEFAULT 0, dropped_param1 INT NOT NULL DEFAULT 0, dropped_param2 INT NOT NULL DEFAULT 0, dropped_pos_x FLOAT NOT NULL DEFAULT 0, dropped_pos_y FLOAT NOT NULL DEFAULT 0, dropped_pos_z FLOAT NOT NULL DEFAULT 0, dropped_int INT NOT NULL DEFAULT 0, dropped_vw INT NOT NULL DEFAULT 0, dropped_timestamp INT NOT NULL DEFAULT 0, PRIMARY KEY (dropped_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    Migration_Add("inventory-3-backpack","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_backpack INT NOT NULL DEFAULT 0");
}
