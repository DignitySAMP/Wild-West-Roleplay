
new const Float: ShorePoints [ ] [ ] = {

	{ -686.8016,		753.1329,		1.7368 },
	{ -703.9090,		716.8571,		4.5989 },
	{ -783.2010,		949.5403,		0.8289 },
	{ -645.6351,		1339.789,		2.3973 },
	{ -1358.520,		1690.508,		1.8135 },
	{ -1865.594,		2141.875,		1.1363 },
	{ -1398.375,		2132.951,		43.176 },
	{ -1181.057,		2676.636,		41.364 },
	{ -2310.521,		2517.633,		1.7807 }
} ;

new playerSwimmingTick 		[ MAX_PLAYERS ] ;
new playerWarningTick 		[ MAX_PLAYERS ] ;
new playerSprintWarningTick [ MAX_PLAYERS ] ;

ptask SwimChecker[1250](playerid) {

////	print("SwimChecker timer called (swimming.pwn)");

	if ( ! IsPlayerSwimming ( playerid ) ) {

		return false ;
	}

	new shoreid ;

	if ( IsPlayerSwimming ( playerid ) ) {

		new keys, ud, lr;
    	GetPlayerKeys(playerid, keys, ud, lr);
 
    	if ( keys == KEY_SPRINT ) {

			if ( PlayerSkill [ playerid ] [ MISC_swimming ] < 2 ) {

				if ( playerSprintWarningTick [ playerid ] == 0 ) {

					SendServerMessage(playerid, "You can't swim that quickly yet! You need swimming level two or higher. (/skills)", MSG_TYPE_ERROR ) ;
				}

				if ( ++ playerSprintWarningTick [ playerid ] > 5 ) {

					playerSprintWarningTick [ playerid ] = 0 ;
				}

				ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
			}
		}

		if ( ++ playerSwimmingTick [ playerid ] > 30 && PlayerSkill [ playerid ] [ MISC_swimming ] < 1) {

			playerSwimmingTick [ playerid ] = 0 ;

			switch ( random ( 3 ) ) {

				case 0: SendServerMessage ( playerid, "You lost your footing and slowly float to the bottom of the ocean..", MSG_TYPE_WARN ) ;
				case 1: SendServerMessage ( playerid, "You got a really bad cramp. You let yourself go deeper into the water as your eyes shut..", MSG_TYPE_WARN ) ;
				case 2: SendServerMessage ( playerid, "You puff in exhaustion. You aren't used to swimming like this. Everything slowly fades black..", MSG_TYPE_WARN ) ;
			}

			shoreid = IsPlayerNearShorePoint ( playerid, 200 ) ;

			if ( shoreid != -1) {

                ac_SetPlayerPos ( playerid, ShorePoints [ shoreid ] [ 0 ], ShorePoints [ shoreid ] [ 1 ], ShorePoints [ shoreid ] [ 2 ] ) ;
//            	FadeIn ( playerid ) ;

            	switch ( random ( 6 ) ) {
				    case 0: AnimationLoop(playerid, "CRACK", "crckdeth1", 4.1, 0, 0, 0, 1, 0, 1);
				    case 1: AnimationLoop(playerid, "CRACK", "crckdeth2", 4.1, 1, 0, 0, 0, 0, 1);
				    case 2: AnimationLoop(playerid, "CRACK", "crckdeth3", 4.1, 0, 0, 0, 1, 0, 1);
				    case 3: AnimationLoop(playerid, "CRACK", "crckidle1", 4.1, 0, 0, 0, 1, 0, 1);
				    case 4: AnimationLoop(playerid, "CRACK", "crckidle2", 4.1, 0, 0, 0, 1, 0, 1);
				    case 5: AnimationLoop(playerid, "CRACK", "crckidle3", 4.1, 0, 0, 0, 1, 0, 1);
				}

				new damage = 5 + random  ( 15 ) ;

				Character [ playerid ] [ character_health ] -= float ( damage ) ;
				SetCharacterHealth ( playerid, Character [ playerid ] [ character_health ] ) ;
			}

			else if ( shoreid == -1 ) {

				SendServerMessage ( playerid, "You're not near any shore. You're slowly starting to drown.", MSG_TYPE_ERROR ) ;
				SetCharacterHealth ( playerid, -1 ) ;
			}

			return true ;
		}

		if ( PlayerSkill [ playerid ] [ MISC_swimming ] < 1 ) {

			if ( playerWarningTick [ playerid ] == 1 ) {

				SendServerMessage ( playerid, "You can't swim properly! You should get to a shore before you drown. (/skills)", MSG_TYPE_ERROR ) ;
			}

			if ( ++ playerWarningTick [ playerid ] > 15 ) {

				playerWarningTick [ playerid ] = 0 ;
			}	
		}
	}

	else if ( ! IsPlayerSwimming ( playerid ) ) {

		if ( playerWarningTick [ playerid ] ) {

			playerWarningTick [ playerid ] = 0 ;
		}
	}




	return true ;
}

IsPlayerNearShorePoint(playerid, Float:range, point = -1)  { 

    if ( point == -1 ) { 

        for ( new i = 0; i < sizeof ( ShorePoints ); i++ ) { 

            if ( IsPlayerInRangeOfPoint ( playerid, range, ShorePoints [ i ] [ 0 ], ShorePoints [ i ] [ 1 ], ShorePoints [ i ] [ 2 ] ) ) {

            	return i ;
            }

            else continue ;
        } 
    } 

    else if ( 0 <= point <= sizeof ( ShorePoints ) ) { 

        return IsPlayerInRangeOfPoint(playerid, range, ShorePoints [ point ] [ 0 ], ShorePoints [ point ] [ 1 ], ShorePoints [ point ] [ 2 ] ) ; 
    } 

    return -1; 
}  