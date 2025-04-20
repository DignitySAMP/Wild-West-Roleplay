enum PosterData {
	poster_id ,

	poster_name [ MAX_PLAYER_NAME ] ,
	poster_skin ,

	poster_price ,
	poster_jailtime,
	DynamicText3D: poster_3did,

	Float: poster_x ,
	Float: poster_y ,
	Float: poster_z ,

	Float: poster_rx ,
	Float: poster_ry ,
	Float: poster_rz ,

	poster_vw,
	poster_int,

	poster_playerid
} ;

new WantedPoster [ MAX_POSTERS ] [ PosterData ] ;
new PosterName [ MAX_PLAYERS ] [ MAX_PLAYER_NAME ] ; 
new PosterObject [ MAX_POSTERS ] ;

Init_WantedPosterObjects () {

	for ( new i; i < MAX_POSTERS; i ++ ) {

		PosterObject [ i ] =  CreateDynamicObject ( 19617, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ) ;
	}

	return true ;
}

GetFreeWantedPoster ( ) {

	new id = -1 ;

	for ( new i; i < MAX_POSTERS; i ++ ) {

		if ( WantedPoster [ i ] [ poster_id ] == -1 ) {

			id = i ;
			break ;
		}

		else continue ;
	}

	return id ;
} 

#define POSTER_TXDOBJID		( 2611 )
#define POSTER_TXDNAME		"POLICE_PROPS_un"
#define POSTER_TXDTEXT		"newspaper1"

new editingPoster [ MAX_PLAYERS ] ; 

public OnPlayerEditDynamicObject ( playerid, objectid, response, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz ) {

	new posterID = editingPoster [ playerid ], Float: oldX, Float: oldY, Float: oldZ, Float: oldRotX, Float: oldRotY, Float: oldRotZ ;

	if ( PosterObject [ posterID ] == objectid ) {

		GetObjectPos ( objectid, oldX, oldY, oldZ ) ;
		GetObjectRot ( objectid, oldRotX, oldRotY, oldRotZ ) ;

		if ( response == EDIT_RESPONSE_FINAL ) {

			new query [ 312 ] ;

			mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO wanted_posters ( poster_id, poster_name, poster_skin, poster_price, poster_jailtime, poster_vw, poster_int, poster_x, poster_y, poster_z, poster_rx, poster_ry, poster_rz ) VALUES (%d, '%s', %d, %d, %d, %d, %d, %f, %f, %f, %f, %f, %f)", 
				WantedPoster [ posterID ] [ poster_id ], WantedPoster [ posterID ] [ poster_name ], WantedPoster [ posterID ] [ poster_skin ], WantedPoster [ posterID ] [ poster_price ], WantedPoster [ posterID ] [ poster_jailtime ], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid),
				x, y, z, rx, ry, rz ) ; 

			mysql_tquery ( mysql, query ); 

			Init_LoadWantedPosters ( ) ;

			TakeCharacterMoney ( playerid, WantedPoster [ posterID ] [ poster_price ], MONEY_SLOT_HAND ) ;
			SendServerMessage ( playerid, sprintf("You offered a bounty of $%s for the capture of %s.", IntegerWithDelimiter(WantedPoster [ posterID ] [ poster_price ]), WantedPoster [ posterID ] [ poster_name ] ), MSG_TYPE_WARN ) ;

			LoadWantedPosterPlayerID ( posterID ) ;
		}
	 
		if ( response == EDIT_RESPONSE_CANCEL ) {

			DestroyDynamicObject ( objectid ) ;
			WantedPoster [ posterID ] [ poster_id ] = -1 ;
		}
	}
	
	#if defined postr_OnPlayerEditDynamicObject 
		return postr_OnPlayerEditDynamicObject ( playerid, objectid, response, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEditDynamicObject 
	#undef OnPlayerEditDynamicObject 
#else
	#define _ALS_OnPlayerEditDynamicObject 
#endif

#define OnPlayerEditDynamicObject  postr_OnPlayerEditDynamicObject 
#if defined postr_OnPlayerEditDynamicObject 
	forward postr_OnPlayerEditDynamicObject ( playerid, objectid, response, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz );
#endif

public OnPlayerDisconnect ( playerid, reason ) {
	
	if ( GetBountyIDByName ( playerid ) != -1 ) {

		WantedPoster [ GetBountyIDByName ( playerid ) ] [ poster_playerid ] = -1 ;

	}
	#if defined postr_OnPlayerDisconnect
		return postr_OnPlayerDisconnect(playerid, reason);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif

#define OnPlayerDisconnect postr_OnPlayerDisconnect
#if defined postr_OnPlayerDisconnect
	forward postr_OnPlayerDisconnect(playerid, reason);
#endif

CreateWantedPoster ( playerid, p_skin, p_price, p_jail ) {

	new posterid = GetFreeWantedPoster ( ) ;

	if ( posterid == -1 ) {

		return SendServerMessage ( playerid, "There was an error creating the wanted poster (returned -1), contact a dev.", MSG_TYPE_ERROR ) ;
	}

	new query [ 128 ], rows, fields ;

	inline ReturnAccountName() {

		cache_get_data ( rows, fields, mysql ) ;

		if ( rows ) {

			WantedPoster [ posterid ] [ poster_id ] 		= posterid ;

			WantedPoster [ posterid ] [ poster_name ] 		= PosterName [ playerid ] ;

			WantedPoster [ posterid ] [ poster_skin ] 		= p_skin ; 
			WantedPoster [ posterid ] [ poster_price ] 		= p_price ;
			WantedPoster [ posterid ] [ poster_jailtime ] 	= p_jail ;

			new Float: p_x, Float: p_y, Float: p_z ;
			GetPlayerPos ( playerid, p_x, p_y, p_z ) ;

			SetDynamicObjectPos(PosterObject [ posterid ], p_x, p_y, p_z ) ;
			SetDynamicObjectMaterial ( PosterObject [ posterid ], 0, POSTER_TXDOBJID, POSTER_TXDNAME, POSTER_TXDTEXT ) ;

			editingPoster [ playerid ] = posterid ;
			EditDynamicObject ( playerid, PosterObject [ posterid ] ) ;

			new name [ MAX_PLAYER_NAME ] = EOS;
			PosterName [ playerid ] = name;
		}

		else if ( ! rows ) {

			return SendServerMessage ( playerid, sprintf("The name %s wasn't found in the database. Try again or double check your input.", PosterName [ playerid ]), MSG_TYPE_ERROR ) ;
		}
	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT character_id FROM characters WHERE character_name = '%e'", PosterName [ playerid ] ) ;
	mysql_tquery_inline(mysql, query, using inline ReturnAccountName, "");

	return true ;
}

forward LoadWantedPosters ( ) ;
public LoadWantedPosters ( ) {

	new rows, fields ;

	cache_get_data ( rows, fields, mysql ) ;

	if ( ! rows ) {
		print(" * [POSTER]: No wanted posters loaded.\n") ;
	}

    if ( rows ) {

		for ( new i, j = rows; i < j; i ++ ) {

			new id;
			id  = cache_get_field_int ( i, "poster_id" ) ;

			WantedPoster [ id ] [ poster_id ] = id ;

			cache_get_field_content ( i, "poster_name", WantedPoster [ id ] [ poster_name ], mysql, MAX_PLAYER_NAME ) ;

			WantedPoster [ id ] [ poster_skin ] 		= cache_get_field_int ( i, "poster_skin" ) ;
			WantedPoster [ id ] [ poster_price ] 	= cache_get_field_int ( i, "poster_price" ) ;
			WantedPoster [ id ] [ poster_jailtime ] 	= cache_get_field_int ( i, "poster_jailtime" ) ;

			WantedPoster [ id ] [ poster_x ] 		= cache_get_field_float ( i, "poster_x" ) ;
			WantedPoster [ id ] [ poster_y ] 		= cache_get_field_float ( i, "poster_y" ) ;
			WantedPoster [ id ] [ poster_z ] 		= cache_get_field_float ( i, "poster_z" ) ;

			WantedPoster [ id ] [ poster_rx ] 		= cache_get_field_float ( i, "poster_rx" ) ;
			WantedPoster [ id ] [ poster_ry ] 		= cache_get_field_float ( i, "poster_ry" ) ;
			WantedPoster [ id ] [ poster_rz ] 		= cache_get_field_float ( i, "poster_rz" ) ;

			WantedPoster [ id ] [ poster_vw ] 		= cache_get_field_int ( i, "poster_vw" ) ;
			WantedPoster [ id ] [ poster_int ]	 	= cache_get_field_int ( i, "poster_int" ) ;

			SetDynamicObjectPos ( PosterObject [ id ], WantedPoster [ id ] [ poster_x ], WantedPoster [ id ] [ poster_y ], WantedPoster [ id ] [ poster_z ] ) ;
			SetDynamicObjectRot ( PosterObject [ id ], WantedPoster [ id ] [ poster_rx ], WantedPoster [ id ] [ poster_ry ], WantedPoster [ id ] [ poster_rz ] ) ;

			/*CreateDynamicObject ( 19617, 	WantedPoster [ id ] [ poster_x ], WantedPoster [ id ] [ poster_y ], WantedPoster [ id ] [ poster_z ], 
				WantedPoster [ id ] [ poster_rx ], WantedPoster [ id ] [ poster_ry ], WantedPoster [ id ] [ poster_rz ], 
				WantedPoster [ id ] [ poster_vw ], WantedPoster [ id ] [ poster_int ] ) ;*/
			
			SetDynamicObjectMaterial ( PosterObject [ id ], 0, POSTER_TXDOBJID, POSTER_TXDNAME, POSTER_TXDTEXT ) ;

			WantedPoster [ id ] [ poster_3did ] 		= CreateDynamic3DTextLabel ( sprintf("Wanted Poster (%d)\n\nPress ~k~~SNEAK_ABOUT~ to view", WantedPoster [ id ] [ poster_id ] ), 0xBAAD8FFF, 
				WantedPoster [ id ] [ poster_x ], WantedPoster [ id ] [ poster_y ], WantedPoster [ id ] [ poster_z ], 2.5 ) ;

			printf(" * [POSTER]: Loaded wanted poster ID %d (db %d), for %s", i, WantedPoster [ id ] [ poster_id ], WantedPoster [ id ] [ poster_name ] ) ;
		}


		printf("\n * [POSTER]: Total posters loaded: %d\n", rows) ;
	}
}

Init_LoadWantedPosters ( ) {

	for ( new i; i < MAX_POSTERS; i ++ ) {

		SetDynamicObjectPos ( PosterObject [ i ], 0.0, 0.0, 0.0 ) ;

		if ( IsValidDynamic3DTextLabel(WantedPoster [ i ] [ poster_3did ])) {
			DestroyDynamic3DTextLabel( WantedPoster [ i ] [ poster_3did ] ) ;
		}
	}

	print("\n * [POSTER]: Loading wanted posters...\n") ;

	return mysql_tquery(mysql, "SELECT * FROM wanted_posters", "LoadWantedPosters", "" ) ;
}


LoadWantedPosterPlayerID ( posterid ) {

	new id = GetPlayerIDFromPoster ( posterid ) ;
	if ( id == INVALID_PLAYER_ID ) { WantedPoster [ posterid ] [ poster_playerid ] = -1 ; return true ; }

	WantedPoster [ posterid ] [ poster_playerid ] = id;
	return true;
}