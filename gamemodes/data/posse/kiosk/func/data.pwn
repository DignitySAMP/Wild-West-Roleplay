enum kioskData {

	kiosk_id,

	Float: kiosk_x,
	Float: kiosk_y,
	Float: kiosk_z,
	Float: kiosk_rx,
	Float: kiosk_ry,
	Float: kiosk_rz,

	kiosk_locked,

	kiosk_object
} ;

enum KioskInfo {
	kiosk_gunname[24],

	kiosk_price,

	kiosk_gunid,
	kiosk_ammo
} ;

new PosseKiosk [ MAX_POSSES ] [ kioskData ] ;
new KioskData [ ] [ KioskInfo ] = {
	//name,price,weaponid,ammo,price per bullet
	{"Revolver",		50,	24,	FACTION_AMMO_PISTOL },
	{"Shotgun",			120,	25,	FACTION_AMMO_SHOTGUN },
	{"Repeater Rifle",	100,	33,	FACTION_AMMO_RIFLE }
} ;

Init_LoadKiosks ( ) {

	for ( new i; i < MAX_POSSES; i ++ ) {

		PosseKiosk [ i ] [ kiosk_id ] = -1 ;
		if ( IsValidDynamicObject ( PosseKiosk [ i ] [ kiosk_object ] ) ) { 
			DestroyDynamicObject ( PosseKiosk [ i ] [ kiosk_object ] ) ; 
		}
	}

	return mysql_tquery(mysql, "SELECT * FROM possekiosk", "LoadKiosks", "" ) ;
}

forward LoadKiosks ( ) ;
public LoadKiosks ( ) {

	new rows, fields ;

	cache_get_data ( rows, fields, mysql ) ;

    if ( rows ) {

		for ( new i, j = rows; i < j; i ++ ) {

			new id = cache_get_field_int ( i, "kiosk_id" ) ;

			if ( id == -1 ) {

				continue ;
			}

			PosseKiosk [ id ] [ kiosk_id ] = id;
			PosseKiosk [ id ] [ kiosk_x ] = cache_get_field_float ( i, "kiosk_x" ) ;
			PosseKiosk [ id ] [ kiosk_y ] = cache_get_field_float ( i, "kiosk_y" ) ;
			PosseKiosk [ id ] [ kiosk_z ] = cache_get_field_float ( i, "kiosk_z" ) ;
			PosseKiosk [ id ] [ kiosk_rx ] = cache_get_field_float ( i, "kiosk_rx" ) ;
			PosseKiosk [ id ] [ kiosk_ry ] = cache_get_field_float ( i, "kiosk_ry" ) ;
			PosseKiosk [ id ] [ kiosk_rz ] = cache_get_field_float ( i, "kiosk_rz" ) ;

			PosseKiosk [ id ] [ kiosk_locked ] = cache_get_field_int ( i, "kiosk_locked" ) ;

			if ( PosseKiosk [ id ] [ kiosk_x ] != 0.0 && PosseKiosk [ id ] [ kiosk_y ] != 0.0 && PosseKiosk [ id ] [ kiosk_z ] != 0.0) { 

				PosseKiosk [ id ] [ kiosk_object ] = CreateDynamicObject ( 18885,
					PosseKiosk [ id ] [ kiosk_x ], PosseKiosk [ id ] [ kiosk_y ], PosseKiosk [ id ] [ kiosk_z ],
					PosseKiosk [ id ] [ kiosk_rx ], PosseKiosk [ id ] [ kiosk_ry ], PosseKiosk [ id ] [ kiosk_rz ] ) ;
			}

			printf(" * [POSSEKIOSK]: Loaded posse kiosk %i\n", 
				PosseKiosk [ id ] [ kiosk_id ] ) ;
		}
	}

	return true ;
}