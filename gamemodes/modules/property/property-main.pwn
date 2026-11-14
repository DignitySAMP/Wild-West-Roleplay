#include <pp-hooks>

hook OnMigrationRun()
{
    Migration_Add("property-1-points","CREATE TABLE IF NOT EXISTS points (point_id INT UNSIGNED NOT NULL AUTO_INCREMENT, point_name VARCHAR(32) NOT NULL DEFAULT 'Unnamed point', point_owner INT NOT NULL DEFAULT -1, point_price INT NOT NULL DEFAULT 500, point_biztype INT NOT NULL DEFAULT 0, point_type INT NOT NULL DEFAULT 0, point_fee INT NOT NULL DEFAULT 0, point_rentable INT NOT NULL DEFAULT 0, point_rent_price INT NOT NULL DEFAULT 0, point_rent_change INT NOT NULL DEFAULT 0, point_till INT NOT NULL DEFAULT 0, point_till_change INT NOT NULL DEFAULT 0, point_weapon1 INT NOT NULL DEFAULT 0, point_weapon1ammo INT NOT NULL DEFAULT 0, point_weapon2 INT NOT NULL DEFAULT 0, point_weapon2ammo INT NOT NULL DEFAULT 0, point_locked INT NOT NULL DEFAULT 0, point_ext_x FLOAT NOT NULL DEFAULT 0, point_ext_y FLOAT NOT NULL DEFAULT 0, point_ext_z FLOAT NOT NULL DEFAULT 0, point_vw INT NOT NULL DEFAULT 0, point_int INT NOT NULL DEFAULT 0, point_int_x FLOAT NOT NULL DEFAULT 0, point_int_y FLOAT NOT NULL DEFAULT 0, point_int_z FLOAT NOT NULL DEFAULT 0, point_int_vw INT NOT NULL DEFAULT 0, point_int_int INT NOT NULL DEFAULT 0, PRIMARY KEY (point_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("property-2-spawnmotel","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_spawnmotel INT NOT NULL DEFAULT 0");
}

hook OnGameModeInit()
{
    Point_InitPool();
    Boot_RegisterLoader("Point_Load");
    Spawn_RegisterChoice(E_SPAWN_CHOICE_HOUSE);
    Spawn_RegisterChoice(E_SPAWN_CHOICE_BUSINESS);
}
