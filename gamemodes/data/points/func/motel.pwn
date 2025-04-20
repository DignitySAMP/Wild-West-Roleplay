enum MotelData {

	motel_name [ 64 ],

	Float: motel_pos_x,
	Float: motel_pos_y,
	Float: motel_pos_z
} ;

new MotelPoints [ ] [ MotelData ] = {
	{ "Longcreek Motel", 		-1445.2828,2615.7722,56.3657 },
	{ "Fort Earp Motel", 		-1082.9253, 2107.4001, 88.6035 },
	{ "Fremont Motel",			-0901.2448, 1527.5383, 25.8723 }
	//{ "Bayside Motel", 			-2318.7632, 2372.3345, 5.82240 }
} ;


new DynamicText3D: MotelLabel [ sizeof ( MotelPoints ) ] ;

Init_Motels () {

	for ( new i; i < sizeof ( MotelPoints ); i ++ ) {

		MotelLabel [ i ] = CreateDynamic3DTextLabel( sprintf("[%d] %s\n{DEDEDE}/rentroom to spawn here", i, MotelPoints [ i ] [ motel_name ]), 0x5BA864FF, MotelPoints [ i ] [ motel_pos_x ], MotelPoints [ i ] [ motel_pos_y ], MotelPoints [ i ] [ motel_pos_z ], 15.0 ) ;
	}

	return true ;
}

CMD:rentroom ( playerid, params [] ) {

	new query [ 256 ] ;

	for ( new i; i < sizeof ( MotelPoints ); i ++ ) {

		if ( IsPlayerInRangeOfPoint(playerid, 2.5, MotelPoints [ i ] [ motel_pos_x ], MotelPoints [ i ] [ motel_pos_y ], MotelPoints [ i ] [ motel_pos_z ] ) ) {

			SendServerMessage ( playerid, sprintf("You're now spawning in the \"%s\" (%d), your /spawn has been automatically updated.", MotelPoints [ i ] [ motel_name ], i), MSG_TYPE_WARN ) ;

			Character [ playerid ] [ character_spawnmotel ] = i ;
			Character [ playerid ] [ character_spawnpoint ] = 5 ;

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_spawnmotel = %d, character_spawnpoint=5 WHERE character_id = %d", Character [ playerid ] [ character_spawnmotel ], Character [ playerid ] [ character_id ]  ) ;
			mysql_tquery( mysql, query );

			return true ;
		}

		else continue ;
	}

	return SendServerMessage ( playerid, "You're not near a motel point!", MSG_TYPE_ERROR ) ;
}

CMD:gotomotel ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You have to be a moderator in order to use this command.", MSG_TYPE_ERROR ) ;
	}

	new motel ;

	if ( sscanf ( params, "i", motel )) {

		return SendServerMessage ( playerid, "/gotomotel [id]", MSG_TYPE_ERROR ) ;
	}

	if ( motel < 0 || motel >= sizeof ( MotelPoints )) {

		return SendServerMessage ( playerid, sprintf("Motel ID can't be less than 0 or more than %d", sizeof ( MotelPoints )), MSG_TYPE_ERROR ) ;
	}

	ac_SetPlayerPos ( playerid, MotelPoints [ motel ] [ motel_pos_x ], MotelPoints [ motel ] [ motel_pos_y ], MotelPoints [ motel ] [ motel_pos_z ] ) ;
				
	return true ;
}
