#include <pp-hooks>

hook OnMigrationRun()
{
    Migration_Add("furniture-1-tables","CREATE TABLE IF NOT EXISTS furniture (furniture_id INT UNSIGNED NOT NULL AUTO_INCREMENT, furniture_point_id INT NOT NULL DEFAULT 0, furniture_model_id INT NOT NULL DEFAULT 0, furniture_x_pos FLOAT NOT NULL DEFAULT 0, furniture_y_pos FLOAT NOT NULL DEFAULT 0, furniture_z_pos FLOAT NOT NULL DEFAULT 0, furniture_rx_pos FLOAT NOT NULL DEFAULT 0, furniture_ry_pos FLOAT NOT NULL DEFAULT 0, furniture_rz_pos FLOAT NOT NULL DEFAULT 0, furniture_interior_id INT NOT NULL DEFAULT 0, furniture_vw_id INT NOT NULL DEFAULT 0, furniture_vanilla INT NOT NULL DEFAULT 1, PRIMARY KEY (furniture_id), KEY idx_furniture_point (furniture_point_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    Migration_Add("furniture-2-extra","CREATE TABLE IF NOT EXISTS furniture_extra (furniture_extra_id INT UNSIGNED NOT NULL AUTO_INCREMENT, furniture_ex_id INT NOT NULL DEFAULT 0, furniture_ex_material_index INT NOT NULL DEFAULT 0, furniture_ex_model_id INT NOT NULL DEFAULT 0, furniture_ex_txd_name VARCHAR(36) NOT NULL DEFAULT '', furniture_ex_texture_name VARCHAR(36) NOT NULL DEFAULT '', furniture_ex_color INT NOT NULL DEFAULT 0, PRIMARY KEY (furniture_extra_id), KEY idx_furniture_extra (furniture_ex_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

hook OnGameModeInit()
{
    Furniture_InitPool();
    Boot_RegisterLoader("Furniture_Load","Point_Load");
}
