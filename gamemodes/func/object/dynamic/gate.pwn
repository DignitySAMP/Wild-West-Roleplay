enum {

	GATE_TYPE_PUBLIC,
	GATE_TYPE_PLAYER,
	GATE_TYPE_FACTION
}

enum GateData {

	gate_id ,

	gate_model,
	gate_obj,

	gate_type, // 0: public 1: player, 2: faction
	gate_owner, // id of above
	gate_move, // 0 = snap, 1 = smooth move
	bool: gate_moved,

	gate_int,
	gate_vw,

	// movement data
	bool: gate_state, // false = closed, true = open

	Float: gate_shut_x,
	Float: gate_shut_y,
	Float: gate_shut_z,

	Float: gate_shut_rx,
	Float: gate_shut_ry,
	Float: gate_shut_rz,
	
	Float: gate_open_x,
	Float: gate_open_y,
	Float: gate_open_z,

	Float: gate_open_rx,
	Float: gate_open_ry,
	Float: gate_open_rz,

	Float: gate_speed
} ;

#define MAX_GATES ( 1000 )
new Gate [ MAX_GATES ] [ GateData ] ;

Gates_Init () {

	for ( new i; i < sizeof ( Gate ); i ++ ) {

		Gate [ i ] [ gate_id ] = -1 ;
	}
/*
	CreateDynamicObject(19392, -1802.43884, 2055.42725, 9.67965,   0.00000, 0.00000, 90.00000);
	
	CreateGate(1532, 0, 0, 0, 0, 
		-1803.21497, 2055.41406, 7.97540,   0.00000, 0.00000, 0.00000,
		-1803.21497, 2055.41406, 7.97540,   0.00000, 0.00000, 90.00000 ) ;

	CreateDynamicObject(19392, -1810.20789, 2049.54541, 9.83314,   0.00000, 0.00000, 0.00000);

	CreateGate(1569, 0, 0, 0, 0,
		-1810.19043, 2048.81006, 8.13640,   0.00000, 0.00000, 90.00000,
		-1810.19043, 2048.81006, 8.13640,   0.00000, 0.00000, 180.00000 ) ;

*/
	return true ;
}

CMD:gate ( playerid, params [] ) {

	new g_id = IsPlayerNearGate ( playerid ) ;

	if ( g_id == -1 ) {

		return SendServerMessage ( playerid, "You're not near any door.", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsLawEnforcementPosse ( Character [ playerid ] [ character_posse ] )) {

		return SendServerMessage ( playerid, "You don't have the keys to this door.", MSG_TYPE_ERROR ) ;
	}

/*
	if ( Gate [ g_id ] [ gate_type ] == GATE_TYPE_PLAYER ) {

		if ( Gate [ g_id ] [ gate_owner ] != Character [ playerid ] [ character_id ] ) {

			return SendServerMessage ( playerid, "You don't have the keys to this door.", MSG_TYPE_ERROR ) ;
		}
	}

	else if ( Gate [ g_id ] [ gate_type ] == GATE_TYPE_FACTION ) {

		if ( Character [ playerid ] [ character_posse ] == -1 ) {

			return SendServerMessage ( playerid, "You don't have the keys to this door.", MSG_TYPE_ERROR ) ;
		}

	 	if ( Gate [ g_id ] [ gate_owner ] == 1 ) {

			if ( ! IsLawEnforcementPosse ( Character [ playerid ] [ character_posse ] ) ) {

				return SendServerMessage ( playerid, "You're not in a law enforcement faction.", MSG_TYPE_ERROR ) ;
			}
		}

		else if ( Gate [ g_id ] [ gate_owner ] != 1 ) {

			if ( Gate [ g_id ] [ gate_owner ] != Character [ playerid ] [ character_posse ] ) {

				return SendServerMessage ( playerid, "You don't have the keys to this door.", MSG_TYPE_ERROR ) ;
			}
		}
	}*/

	switch ( Gate [ g_id ] [ gate_state ] ) {
		case true: {

			Gate [ g_id ] [ gate_state ] = false ;

			switch ( Gate [ g_id ] [ gate_move ] ) {
				case false : {

					SetDynamicObjectPos ( Gate [ g_id ] [ gate_obj ], Gate [ g_id ] [ gate_shut_x ], Gate [ g_id ] [ gate_shut_y ],Gate [ g_id ] [ gate_shut_z ] ) ;
					SetDynamicObjectRot ( Gate [ g_id ] [ gate_obj ], Gate [ g_id ] [ gate_shut_rx ], Gate [ g_id ] [ gate_shut_ry ],Gate [ g_id ] [ gate_shut_rz ] ) ;
				}

				case true : {

					new Float: incr ;

					switch ( Gate [ g_id ] [ gate_moved ] ) {

						case true: {
							incr = 0.01 ;
							Gate [ g_id ] [ gate_moved ] = false ;
						}	

						case false:{
							incr = 0.02 ;
							Gate [ g_id ] [ gate_moved ] = true ;
						}
					}

					MoveDynamicObject(Gate [ g_id ] [ gate_obj ], 
						Gate [ g_id ] [ gate_shut_x ] + incr, Gate [ g_id ] [ gate_shut_y ] + incr, Gate [ g_id ] [ gate_shut_z ] + incr, 
						Gate [ g_id ] [ gate_speed ],  Gate [ g_id ] [ gate_shut_rx ], Gate [ g_id ] [ gate_shut_ry ],Gate [ g_id ] [ gate_shut_rz ] ) ;
				}
			}

		}

		case false: {

			Gate [ g_id ] [ gate_state ] = true ;

			switch ( Gate [ g_id ] [ gate_move ] ) {
				case false : {

					SetDynamicObjectPos ( Gate [ g_id ] [ gate_obj ], Gate [ g_id ] [ gate_open_x ], Gate [ g_id ] [ gate_open_y ],Gate [ g_id ] [ gate_open_z ] ) ;
					SetDynamicObjectRot ( Gate [ g_id ] [ gate_obj ], Gate [ g_id ] [ gate_open_rx ], Gate [ g_id ] [ gate_open_ry ],Gate [ g_id ] [ gate_open_rz ] ) ;
				}

				case true : {

					new Float: incr ;

					switch ( Gate [ g_id ] [ gate_moved ] ) {

						case true: {
							incr = 0.01 ;
							Gate [ g_id ] [ gate_moved ] = false ;
						}	

						case false:{
							incr = 0.02 ;
							Gate [ g_id ] [ gate_moved ] = true ;
						}
					}

					MoveDynamicObject(Gate [ g_id ] [ gate_obj ], 
						Gate [ g_id ] [ gate_open_x ] + incr, Gate [ g_id ] [ gate_open_y ] + incr, Gate [ g_id ] [ gate_open_z ] + incr, 
						Gate [ g_id ] [ gate_speed ],  Gate [ g_id ] [ gate_open_rx ], Gate [ g_id ] [ gate_open_ry ],Gate [ g_id ] [ gate_open_rz ] ) ;		
				}
			}
		}
	}

	return true ;
}


IsPlayerNearGate ( playerid ) {

	for ( new i; i < sizeof ( Gate ); i ++ ) {

		if ( Gate [ i ] [ gate_id ] != -1 ) {

			if ( IsPlayerInRangeOfPoint ( playerid, 2.0, Gate [ i ] [ gate_shut_x ], Gate [ i ] [ gate_shut_y ], Gate [ i ] [ gate_shut_z ] ) || 
				 IsPlayerInRangeOfPoint ( playerid, 2.0, Gate [ i ] [ gate_open_x ], Gate [ i ] [ gate_open_y ], Gate [ i ] [ gate_open_z ] ) && 
				 GetPlayerInterior ( playerid ) == Gate [ i ] [ gate_int ] && GetPlayerVirtualWorld ( playerid ) == Gate [ i ] [ gate_vw ] ) {

				return i ;
			}

			else continue ;
		}

		else continue ;
	}

	return -1 ;
}


CreateGate ( g_model, g_type, g_owner, g_int, g_vw, Float: g_speed, 
	Float: g_shut_x, Float: g_shut_y, Float: g_shut_z, Float: g_shut_rx, Float: g_shut_ry, Float: g_shut_rz,
	Float: g_open_x, Float: g_open_y, Float: g_open_z, Float: g_open_rx, Float: g_open_ry, Float: g_open_rz, g_move) {

	new g_id = GetFreeGateID ( )  ;

	if ( g_id == -1 ) {

		return print("Error creating gate.");
	}

	Gate [ g_id ] [ gate_id] 			= g_id ;

	Gate [ g_id ] [ gate_model ] 		= g_model ;
	Gate [ g_id ] [ gate_obj ] 			= CreateDynamicObject ( g_model, g_shut_x, g_shut_y, g_shut_z, g_shut_rx, g_shut_ry, g_shut_rz, g_vw, g_int ) ;

	Gate [ g_id ] [ gate_type ] 		= g_type ;
	Gate [ g_id ] [ gate_owner ] 		= g_owner ;
	Gate [ g_id ] [ gate_move ] 		= g_move ;
	Gate [ g_id ] [ gate_moved ] 		= false ;

	Gate [ g_id ] [ gate_int ] 			= g_int ;
	Gate [ g_id ] [ gate_vw ] 			= g_vw ;

	// movement data

	Gate [ g_id ] [ gate_state ] 		= false ;

	Gate [ g_id ] [ gate_shut_x ] 		= g_shut_x ;
	Gate [ g_id ] [ gate_shut_y ] 		= g_shut_y ;
	Gate [ g_id ] [ gate_shut_z ] 		= g_shut_z ;

	Gate [ g_id ] [ gate_shut_rx ] 		= g_shut_rx ;
	Gate [ g_id ] [ gate_shut_ry ] 		= g_shut_ry ;
	Gate [ g_id ] [ gate_shut_rz ] 		= g_shut_rz ;

	Gate [ g_id ] [ gate_open_x ] 		= g_open_x ;
	Gate [ g_id ] [ gate_open_y ] 		= g_open_y ;
	Gate [ g_id ] [ gate_open_z ] 		= g_open_z ;

	Gate [ g_id ] [ gate_open_rx ] 		= g_open_rx ;
	Gate [ g_id ] [ gate_open_ry ] 		= g_open_ry ;
	Gate [ g_id ] [ gate_open_rz ] 		= g_open_rz ;

	Gate [ g_id ] [ gate_speed ] 		= g_speed ;

	return Gate [ g_id ] [ gate_obj ] ;
}

GetFreeGateID ( ) {

	for ( new i; i < sizeof ( Gate ); i ++ ) {

		if ( Gate [ i ] [ gate_id ] == -1 ) {

			return i ;
		}

		else continue ;
	}

	return -1 ;
}