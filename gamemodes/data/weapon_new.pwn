/*

	/gunstore ledger
	-> DIALOG_TABLIST, page support


*/

enum PlayerWeaponData {

	table_id,
	character_id,

	weapon_id,
	weapon_serial // if serial = -1, theyre illegal
} ;

new PlayerWeapons [ MAX_PLAYERS ] [ PlayerWeaponData ] ;

enum WeaponsData {

	gun_name [ 32 ],

	gun_model,
	gun_ammo,

	Float: gun_basedmg // dmg without any bodypart/radius changes
} ;

new Weapons [ ] [ WeaponsData ] = {

	{ "Revolver", 24, 6, 15.0 },
	{ "Revolver", 24, 6, 15.0 },
	{ "Revolver", 24, 6, 15.0 },
	{ "Revolver", 24, 6, 15.0 }
} ;
