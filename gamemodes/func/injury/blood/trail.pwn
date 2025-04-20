#define OBJECT_BLOOD_PUDDLE     ( 19836 )
#define TIMER_BLOODPUDDLE       ( 500)

#define MAX_BLOOD_OBJECTS       ( 25 )
#define PLAYER_BLEEDING_RANGE   ( 1.5 )

new plyr_BloodPuddle_obj 	[ MAX_PLAYERS ] [ MAX_BLOOD_OBJECTS ];
new plyr_BloodPuddle_count [ MAX_PLAYERS ] ;

new playerBloodTick [ MAX_PLAYERS ] ; 
new puddle_refreshCount [ MAX_PLAYERS ] ;
new bool: refreshBloodPuddleObjects [ MAX_PLAYERS ] ;
new bool: IsPlayerBleeding [ MAX_PLAYERS ] ;

TogglePlayerBleeding ( playerid ) {

	if ( ! IsPlayerBleeding [ playerid ] ) {

		IsPlayerBleeding [ playerid ] = true ;

		defer BloodHandler[1000 + random ( 1500 )](playerid) ;
		return true ;
	}

	return true ;
}

timer BloodHandler[1000](playerid) {

////	print("BloodHandler timer called (trail.pwn)");

	if ( ! IsPlayerBleeding [ playerid ] ) {

		return false ;
	}

	else if ( IsPlayerBleeding [ playerid ] ) {

		if ( ! Character [ playerid ] [ character_dmgmode ] ) {
			SetCharacterHealth ( playerid, Character [ playerid ] [ character_health ] - 0.05 ) ;
		}

		new Float: blood_pos_X, Float: blood_pos_Y, Float: blood_pos_Z;
		GetPlayerPos ( playerid, blood_pos_X, blood_pos_Y, blood_pos_Z ) ;

		if ( ++ playerBloodTick [ playerid ] >= 50 ) {
			playerBloodTick [ playerid ] = 0 ;

			for ( new i; i < MAX_BLOOD_OBJECTS; i ++ ) {

				if ( IsValidDynamicObject(plyr_BloodPuddle_obj [ playerid ] [ i ] ) ) {
					
					DestroyDynamicObject ( plyr_BloodPuddle_obj [ playerid ] [ i ] ) ;
				}
			}

			refreshBloodPuddleObjects [ playerid ] = false ;
			plyr_BloodPuddle_count [ playerid ] = 0 ;
		}

		if ( plyr_BloodPuddle_count [ playerid ] == MAX_BLOOD_OBJECTS ) {

			refreshBloodPuddleObjects [ playerid ] = true ;
			playerBloodTick [ playerid ] = 51 ;
		}
    
		/*if ( refreshBloodPuddleObjects [ playerid ] ) {
		    if ( puddle_refreshCount [ playerid ] == MAX_BLOOD_OBJECTS ) {

				puddle_refreshCount [ playerid ] = 0 ;
		    }
		
		    new objid = plyr_BloodPuddle_obj [ playerid ] [ puddle_refreshCount [ playerid ] ++ ] ;

			if ( IsValidDynamicObject(objid) ) {
				SetDynamicObjectPos(objid, blood_pos_X, blood_pos_Y, blood_pos_Z - 0.99 );
			}
		}*/
		
		if ( ! refreshBloodPuddleObjects [ playerid ] ) {

			plyr_BloodPuddle_obj [ playerid ] [ plyr_BloodPuddle_count [ playerid ] ++ ] = CreateDynamicObject ( OBJECT_BLOOD_PUDDLE, blood_pos_X, blood_pos_Y, blood_pos_Z - 0.99, 0.0, 0.0, 0.0 ) ;
		}

		defer BloodHandler[1000 + random ( 1500 )](playerid) ;
	}

	return true ;
}

CancelBloodPuddle ( playerid ) {

	IsPlayerBleeding [ playerid ] = false ; 
	playerBloodTick [ playerid ] = 0 ;

	refreshBloodPuddleObjects [ playerid ] = false ;
	
	puddle_refreshCount [ playerid ] = 0 ;
	plyr_BloodPuddle_count [ playerid ] = 0 ;

	for ( new i; i < MAX_BLOOD_OBJECTS; i ++ ) {
	    if ( IsValidDynamicObject ( plyr_BloodPuddle_obj [ playerid ] [ i ] ) ) {
	        DestroyDynamicObject ( plyr_BloodPuddle_obj [ playerid ] [ i ] ) ;
		}
	}
	
	return true ;
}
