enum TransportData {

	t_id,
	t_name [ 64 ],
	Float: t_pos_x,
	Float: t_pos_y,
	Float: t_pos_z,
	t_price

} ;

new TransportPoints [ ] [ TransportData ] = {

	{ 1, "Boat to Longcreek Docks", 	-2333.5571,	2294.5916, 4.98440, 25 }, // bayside_dock
	{ 2, "Train to Fremont", 		-2687.3406,	2203.1135, 56.7655, 30 }, // bayside_station
	{ 3, "Train to Bayside Station", 	-828.68710,	1083.9216, 34.6641, 40 }, // lb_station
	{ 4, "Bayside Tunnel Pass", 		-2269.7869, 2639.1511, 55.4490, 0  } , 
	{ 5, "Bayside Tunnel Pass", 		-2000.9537, 2562.3591, 55.2470, 0  }
} ;

Init_TransportPoints () {

	for ( new i; i < sizeof ( TransportPoints ) ; i ++ ) {

		CreateDynamic3DTextLabel(sprintf("[%s]\n{DEDEDE}$%s to pass (/transport)", TransportPoints [ i ] [ t_name ], IntegerWithDelimiter ( TransportPoints [ i ] [ t_price ] ) ),
		0xBA9D6AFF, TransportPoints [ i ] [ t_pos_x], TransportPoints [ i ] [ t_pos_y ], TransportPoints [ i ] [ t_pos_z ], 15.0 ) ;

		CreateDynamicMapIcon(TransportPoints [ i ] [ t_pos_x], TransportPoints [ i ] [ t_pos_y ], TransportPoints [ i ] [ t_pos_z ], 9, -1 ) ;
		CreateDynamicPickup(1210, 1, TransportPoints [ i ] [ t_pos_x], TransportPoints [ i ] [ t_pos_y ], TransportPoints [ i ] [ t_pos_z ] ) ;
	}


	return true ;
}

CMD:transport ( playerid, params [] ) {

	new Float: yds ;

	for ( new i; i < sizeof ( TransportPoints ); i ++ ) {

		yds = GetPlayerDistanceFromPoint(playerid, TransportPoints [ i ] [ t_pos_x], TransportPoints [ i ] [ t_pos_y ], TransportPoints [ i ] [ t_pos_z ] ) ;

		if ( yds >= 5 ) {

			continue ;
		}

		if ( Character [ playerid ] [ character_handmoney ] <= TransportPoints [ i ] [ t_price] ) {

			return SendServerMessage ( playerid, sprintf("You need at least $%s to afford this.", IntegerWithDelimiter ( TransportPoints [ i ] [ t_price] )), MSG_TYPE_ERROR ) ;
		}

		new targetpoint ;

		switch ( TransportPoints [ i ] [ t_id ] ) {

			case 0: targetpoint = 1 ;
			case 1: targetpoint = 0 ;
			case 2: targetpoint = 3 ;
			case 3: targetpoint = 2 ;
			case 4: targetpoint = 5 ;
			case 5: targetpoint = 4 ;
		}

		TakeCharacterMoney ( playerid, TransportPoints [ i ] [ t_price], MONEY_SLOT_HAND ) ;

		//BlackScreen ( playerid ) ;

		ac_SetPlayerPos ( playerid, TransportPoints [ targetpoint ] [ t_pos_x], TransportPoints [ targetpoint ] [ t_pos_y ], TransportPoints [ targetpoint ] [ t_pos_z ]) ;
	
//		FadeIn ( playerid ) ;
		
		return SendServerMessage ( playerid, sprintf("You've taken the %s. It cost you $%s", TransportPoints [ i ] [ t_name ], IntegerWithDelimiter ( TransportPoints [ i ] [ t_price] )), MSG_TYPE_INFO ) ;
	}

	return SendServerMessage ( playerid, "You're not near a transport point!", MSG_TYPE_ERROR );
}
