/* 
---> add fire health (randomised between 150 & 250 )
---> buckets near water / well, use action system to fill it up (4/4)



*/


#define MAX_FIRES	( 75 )

new Fire 		[ MAX_FIRES ] ;
new FireObject 	[ MAX_FIRES ] ;	
new FireArea 	[ MAX_FIRES ] ;

Init_Fires () {
	for ( new i; i < MAX_FIRES; i ++ ) {

		Fire 		[ i ] = -1 ;
	}

	return true ;
}

ReturnFreeFireID ( ) {

	for ( new i; i < MAX_FIRES; i ++ ) {
		if ( Fire [ i ] == -1 ) {

			return i ;
		}

		else continue ;

	}

	return -1 ;
}

CMD:fire ( playerid, params [] ) {

	WriteLog ( playerid, "abuse", sprintf("(%d) %s tried to abuse /fire. Perm ban them.", playerid, ReturnUserName ( playerid, true ) ) ) ;

	SendClientMessage(playerid, COLOR_YELLOW, "You're logged. Consider yourself banned." ) ;
/*
	new Float: x, Float: y, Float: z ;
	GetPlayerPos ( playerid, x, y, z ) ;

	CreateFire ( x, y, z, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid) ) ;*/
}

CreateFire ( Float: fire_pos_x,  Float: fire_pos_y, Float: fire_pos_z, fire_pos_int, fire_pos_vw ) {

	new id = ReturnFreeFireID ( ) ;

	if ( id == -1 ) {

		return false ;
	}

	SendClientMessageToAll(-1, sprintf("Created fire ID %d at %f %f %f", id, fire_pos_x, fire_pos_y, fire_pos_z ) ) ;

	Fire 		[ id ] = id  ;
	FireObject 	[ id ] = CreateDynamicObject(18690, fire_pos_x, fire_pos_y, fire_pos_z - 1.5, 0.0, 0.0, 0.0, fire_pos_vw, fire_pos_int ) ;
	FireArea   	[ id ] = CreateDynamicCircle(fire_pos_x, fire_pos_y, 1.5, fire_pos_vw, fire_pos_int ) ;

	return true ;
}

public OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid) {

	if ( IsFireArea ( areaid ) ) {

		SendClientMessage(playerid, -1, "You're now on fire!" ) ;
	}

	#if defined fire_OnPlayerEnterDynamicArea
		return fire_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif

#define OnPlayerEnterDynamicArea fire_OnPlayerEnterDynamicArea
#if defined fire_OnPlayerEnterDynamicArea
	forward fire_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid );
#endif

public OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid) {

	if ( IsFireArea ( areaid ) ) {

		SendClientMessage(playerid, -1, "You're no longer on fire!" ) ;
	}

	#if defined fire_OnPlayerLeaveDynamicArea
		return fire_OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid ); //error line?
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLeaveDynamicArea
	#undef OnPlayerLeaveDynamicArea
#else
	#define _ALS_OnPlayerLeaveDynamicArea
#endif

#define OnPlayerLeaveDynamicArea fire_OnPlayerLeaveDynamicArea
#if defined fire_OnPlayerLeaveDynamicArea
	forward fire_OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid );
#endif

IsFireArea ( areaid ) {

	for ( new i; i < MAX_FIRES; i ++ ) {

		if ( Fire [ i ] != -1 ) {
			if ( areaid == FireArea [ i ] ) {
				return true ;
			}

			else continue ;
		}

		else continue ;
	}

	return false ;
}