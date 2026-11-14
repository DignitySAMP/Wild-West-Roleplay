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
    Migration_Add("skills-1-table","CREATE TABLE IF NOT EXISTS character_skills (character_id INT UNSIGNED NOT NULL, GUN_movement INT NOT NULL DEFAULT 0, GUN_aiming INT NOT NULL DEFAULT 0, GUN_holster INT NOT NULL DEFAULT 0, JOB_fishing INT NOT NULL DEFAULT 0, JOB_lumber INT NOT NULL DEFAULT 0, JOB_mining INT NOT NULL DEFAULT 0, JOB_hunting INT NOT NULL DEFAULT 0, JOB_farming INT NOT NULL DEFAULT 0, JOB_blacksmith INT NOT NULL DEFAULT 0, MISC_swimming INT NOT NULL DEFAULT 0, MISC_health INT NOT NULL DEFAULT 0, MELEE_style INT NOT NULL DEFAULT 0, MELEE_unarmed INT NOT NULL DEFAULT 0, MELEE_knife INT NOT NULL DEFAULT 0, MELEE_knife_throw INT NOT NULL DEFAULT 0, PRIMARY KEY (character_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
}
