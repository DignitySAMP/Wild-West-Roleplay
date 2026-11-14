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
    Migration_Add("economy-1-money","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_money_hand INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_money_bank INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_money_paycheck INT NOT NULL DEFAULT 0");
    Migration_Add("economy-2-play-minutes","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_minutes INT NOT NULL DEFAULT 0");
}
