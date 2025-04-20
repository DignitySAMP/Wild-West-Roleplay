/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

// posse slots by type
#define MAX_POSSE_NAME  ( 36 )
enum PosseData {
	posse_id,
	posse_type,
	
	posse_name [ MAX_POSSE_NAME ],
	posse_slots,

	posse_color,

	Float: posse_spawn_x,
	Float: posse_spawn_y,
	Float: posse_spawn_z,

	posse_spawn_int,
	posse_spawn_vw,

	posse_bank,
	posse_bank_decimal

} ;

new Posse [ MAX_POSSES ] [ PosseData ] ;
new bool: Posse_Chat [ MAX_POSSES ] ;

//////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

#define COLOR_POSSE_DARK    	( 0xD69045FF )
#define COLOR_POSSE_LIGHT   	( 0xE3AD74FF )
	
#define COLOR_POSSE_LAW_DARK 		( 0x6B9665FF )
#define COLOR_POSSE_LAW_LIGHT 		( 0x6DB863FF )

#define COLOR_POSSE_GOV_DARK		( 0x27657aFF )
#define COLOR_POSSE_GOV_LIGHT		( 0x5391a6FF )

#define COLOR_POSSE_GANG_DARK 		( 0x8C5050FF )
#define COLOR_POSSE_GANG_LIGHT 		( 0xB86363FF )

enum { // posse types
	POSSE_TYPE_LAW,
	POSSE_TYPE_OUTLAW
} ;

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

CMD:posses(playerid) {

	return ViewPosses ( playerid ) ;
}

ViewPosses ( playerid ) {

	new string [ 128 ] ; 

	for ( new p; p < MAX_POSSES; p ++ ) {

		if ( Posse [ p ] [ posse_id ] > 0 ) {



			format ( string, sizeof ( string ), "%s, ID %d [members online: %d]", Posse [ p ] [ posse_name ], Posse [ p ] [ posse_id ], GetOnlinePosseMembers ( p ) ) ;
			SendServerMessage ( playerid, string, MSG_TYPE_INFO ) ;	
		}
	}

	return true ;
}

GetOnlinePosseMembers ( posseid ) {

	new count ;

	foreach(new i: Player) {

		if ( ! IsPlayerConnected ( i ) ) {

			continue ;
		}

		if ( Character [ i ] [ character_posse ] == posseid ) {

			count ++ ;
		}

		else continue ;
	}

	return count ;
}

CreatePosse ( p_name[], p_type, p_slots ) {

	new query [ 128 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO posses (posse_name, posse_type, posse_slots, posse_color) VALUES ('%s', %d, %d, -1)", p_name, p_type, p_slots ) ;
	mysql_tquery ( mysql, query ) ;  

	//OldLog ( INVALID_PLAYER_ID, "posse/main", sprintf ( "%s (type: %d, slots: %d) posse has been created.", p_name, p_type, p_slots )) ;

	Init_LoadPosses ( ) ;

	mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO possekiosk (kiosk_id) VALUES ('%d')", FindEmptyPosseSlot ( ) - 1 ) ;
	mysql_tquery ( mysql, query ) ;  

	Init_LoadKiosks ( ) ;
}

DeletePosse ( p_id ) {

	new query [ 128 ] ;
	mysql_format ( mysql, query, sizeof ( query ), "DELETE FROM posses WHERE posse_id = '%d'", p_id ) ;
	mysql_tquery ( mysql, query );

	mysql_format ( mysql, query, sizeof ( query ), "DELETE FROM kioskposse WHERE kiosk_id = '%d'", p_id ) ;
	mysql_tquery ( mysql, query );

	Init_LoadPosses ( ) ;
	Init_LoadKiosks ( ) ;
}

IsValidPosse ( posseid ) {

	for ( new i; i < MAX_POSSES; i ++ ) {

		if ( Posse [ i ] [ posse_id ] == posseid ) {

			return true ;
		}
	}

	return false ;
}

GetPosseType ( posseid ) {

	if ( posseid == -1 ) {

		return 0 ;
	}

	return Posse [ posseid ] [ posse_type ] ;
}

IsPlayerInPosse ( playerid ) {

	if ( Character [ playerid ] [ character_posse ] < 0 ) {

		return false ;
	}

	return true ;
}
SendPosseWarning ( posseid, text [] ) {
	foreach (new i: Player) {
		if ( Character [ i ] [ character_posse ] == posseid ) {

			if ( Posse [ posseid ] [ posse_type ] == 0 ) {

				SendClientMessage( i, COLOR_POSSE_DARK, text ) ;
			}

			if ( Posse [ posseid ] [ posse_type ] == 1 ) {

				SendClientMessage( i, COLOR_POSSE_LAW_DARK, text ) ;
			}
			if ( Posse [ posseid ] [ posse_type ] == 2 ) {

				SendClientMessage( i, COLOR_POSSE_GOV_DARK, text ) ;
			}

			if ( Posse [ posseid ] [ posse_type ] == 3 ) {

				SendClientMessage( i, COLOR_POSSE_GANG_DARK, text ) ;
			}
	    }

	    else continue ;
	}

	return true ;
}

SendPosseMessage( posseid, text [] ) {
	foreach (new i: Player) {
		if ( Character [ i ] [ character_posse ] == posseid ) {

			if ( Posse [ posseid ] [ posse_type ] == 0 ) {
				SendSplitMessage ( i, COLOR_POSSE_LIGHT, text ) ;
			}

			if ( Posse [ posseid ] [ posse_type ] == 1 ) {
				SendSplitMessage ( i, COLOR_POSSE_LAW_LIGHT, text ) ;
			}

			if ( Posse [ posseid ] [ posse_type ] == 2 ) {
				SendSplitMessage ( i, COLOR_POSSE_GOV_LIGHT, text ) ;
			}

			if ( Posse [ posseid ] [ posse_type ] == 3 ) {
				SendSplitMessage ( i, COLOR_POSSE_GANG_LIGHT, text ) ;
			}
	    }

	    else continue ;
	}

	return true ;
}

GetPosseName( posseid ) {

	new name[MAX_POSSE_NAME];
	switch(posseid) {

		case -1: { name = "None"; }
		default: { format(name,sizeof(name),"%s",Posse[posseid][posse_name]); }
	}
	return name;
}

GetPosseTierName(possetier) {

	new name[8];
	name = "N/A";
	switch(possetier) {

		case 0: { name = "None"; }
		case 1: { name = "Member"; }
		case 2: { name = "Command"; }
		case 3: { name = "Leader"; }
		default: { name = "N/A"; }
	}
	return name;
}

Init_LoadPosses ( ) {
//Init_LoadPosses () {

//	if ( id == -1 ) {

		for ( new i; i < MAX_POSSES; i ++ ) {

			Posse [ i ] [ posse_id ] = -1 ;
		}

		return mysql_tquery(mysql, "SELECT * FROM posses", "LoadPosses", "" ) ;
//	}
/*
	else {

		new query [ 128 ], pid = -1;

		for ( new i; i < MAX_POSSES; i ++ ) {

			if ( Posse [ i ] [ posse_id ] == id ) {

				pid = i ;
				break ;
			}
		}

		mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM posses WHERE posse_id = %d", id ) ;
		return mysql_tquery ( mysql, query, "LoadSinglePosse", "dd", id, pid ) ;
	}*/
}


FindEmptyPosseSlot() {

	new i = 0;

	while ( i < sizeof ( Posse ) && Posse [ i ] [ posse_id ] != -1 ) {
		i++;
	}

	if ( i == sizeof (Posse ) ) return -1;

	return i;
}


forward LoadPosses ( ) ;
public LoadPosses ( ) {
	new rows, fields ;

	cache_get_data ( rows, fields, mysql ) ;

	if ( ! rows ) {
		CreatePosse ( "Law Enforcement", 1, 6 ) ;
	}

    if ( rows ) {

		for ( new i, j = rows; i < j; i ++ ) {

			new id ;
			id = cache_get_field_int ( i, "posse_id" ) ;
			Posse [ id ] [ posse_id ] = id ;

			cache_get_field_content ( i, "posse_name", Posse [ id ] [ posse_name ], mysql, MAX_POSSE_NAME ) ;

			Posse [ id ] [ posse_type ] = cache_get_field_int ( i, "posse_type" ) ;
			Posse [ id ] [ posse_slots ] = cache_get_field_int ( i, "posse_slots" ) ;

			Posse [ id ] [ posse_color ] = cache_get_field_int ( i, "posse_color" ) ;

			Posse [ id ] [ posse_spawn_x ] = cache_get_field_float ( i, "posse_spawn_x" ) ;
			Posse [ id ] [ posse_spawn_y ] = cache_get_field_float ( i, "posse_spawn_y" ) ;
			Posse [ id ] [ posse_spawn_z ] = cache_get_field_float ( i, "posse_spawn_z" ) ;

			Posse [ id ] [ posse_spawn_int ] = cache_get_field_int ( i, "posse_spawn_int" ) ;
			Posse [ id ] [ posse_spawn_vw ] = cache_get_field_int ( i, "posse_spawn_vw" ) ;

			Posse [ id ] [ posse_bank ] = cache_get_field_int ( i, "posse_bank" ) ;
			Posse [ id ] [ posse_bank_decimal ] = cache_get_field_int ( i, "posse_bank_decimal" ) ;

			printf(" * [POSSE]: Loaded posse %s, type %d with %d slots and color %d\n", 
				Posse [ id ] [ posse_name ], Posse [ id ] [ posse_type ], Posse [ id ] [ posse_slots ], Posse [ id ] [ posse_color ] ) ;
		}
	}

	return true ;
}

forward LoadSinglePosse ( id, enumid ) ;
public LoadSinglePosse ( id, enumid ) {
	new rows, fields ;

	cache_get_data ( rows, fields, mysql ) ;

    if ( rows ) {

		Posse [ enumid ] [ posse_id ] = id ;

		cache_get_field_content ( 0, "posse_name", Posse [ enumid ] [ posse_name ], mysql, MAX_POSSE_NAME ) ;

		Posse [ enumid ] [ posse_type ] = cache_get_field_int ( 0, "posse_type" ) ;
		Posse [ enumid ] [ posse_slots ] = cache_get_field_int ( 0, "posse_slots" ) ;

		Posse [ enumid ] [ posse_color ] = cache_get_field_int ( 0, "posse_color" ) ;

		Posse [ enumid ] [ posse_spawn_x ] = cache_get_field_float ( 0, "posse_spawn_x" ) ;
		Posse [ enumid ] [ posse_spawn_y ] = cache_get_field_float ( 0, "posse_spawn_y" ) ;
		Posse [ enumid ] [ posse_spawn_z ] = cache_get_field_float ( 0, "posse_spawn_z" ) ;

		Posse [ enumid ] [ posse_spawn_int ] = cache_get_field_int ( 0, "posse_spawn_int" ) ;
		Posse [ enumid ] [ posse_spawn_vw ] = cache_get_field_int ( 0, "posse_spawn_vw" ) ;

		Posse [ enumid ] [ posse_bank ] = cache_get_field_int ( 0, "posse_bank" ) ;
		Posse [ enumid ] [ posse_bank_decimal ] = cache_get_field_int ( 0, "posse_bank_decimal" ) ;

		printf(" * [POSSE]: Loaded posse %s, type %d with %d slots and color %d\n", 
			Posse [ enumid ] [ posse_name ], Posse [ enumid ] [ posse_type ], Posse [ enumid ] [ posse_slots ], Posse [ enumid ] [ posse_color ] ) ;
	}

	return true ;
}
