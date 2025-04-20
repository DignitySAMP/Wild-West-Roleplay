/*
		-- TO DO LIST

			- Create a injury for arms (maybe arm flick every 4-5 seconds, or anything)

*/

#define COLOR_INJURY    (0xBD1A1AFF)

new playerCorpse [ MAX_PLAYERS ] ;
new DynamicText3D: playerCorpseInfo [ MAX_PLAYERS ] ;

enum CorpseInfo {
	corpse_id,
	
	corpse_pid,
	corpse_skin,

	Float: corpse_x_pos,
	Float: corpse_y_pos,
	Float: corpse_z_pos

};

#define MAX_CORPSES 	( 75 )
new Corpse [ MAX_CORPSES ] [ CorpseInfo ] ;
new player_Death [ MAX_PLAYERS ] ; 

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


public OnPlayerDisconnect(playerid, reason) {

	if ( IsValidDynamic3DTextLabel ( playerCorpseInfo [ playerid ] ) ) {

		DestroyDynamic3DTextLabel( playerCorpseInfo [ playerid ] ) ;
	}

	if ( IsValidActor ( playerCorpse [ playerid ] ) ) {

		DestroyActor ( playerCorpse [ playerid ] ) ;
	}
	
	#if defined corpse_OnPlayerDisconnect 
		return corpse_OnPlayerDisconnect ( playerid, reason );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect 
	#undef OnPlayerDisconnect 
#else
	#define _ALS_OnPlayerDisconnect 
#endif

#define OnPlayerDisconnect  corpse_OnPlayerDisconnect 
#if defined corpse_OnPlayerDisconnect 
	forward corpse_OnPlayerDisconnect ( playerid, reason );
#endif

ProcessDeath ( playerid ) {
	new Float: p_death_X, Float: p_death_Y, Float: p_death_Z, Float: p_death_A ;

	GetPlayerPos ( playerid, p_death_X, p_death_Y, p_death_Z ) ;
	GetPlayerFacingAngle ( playerid, p_death_A ) ;
	
	CreateCorpse ( playerid, GetPlayerSkin ( playerid ), p_death_X, p_death_Y, p_death_Z, p_death_A ) ;
	ApplyActorAnimation( playerCorpse [ playerid ], "crack", "null", 4.1, 1, 0, 0, 1, 0);

	switch ( random ( 2 ) ) {
	    case 0: ApplyActorAnimation( playerCorpse [ playerid ], "crack", "crckidle2", 4.1, 1, 0, 0, 1, 0);
	    case 1: ApplyActorAnimation( playerCorpse [ playerid ], "crack", "crckidle4", 4.1, 0, 0, 0, 1, 0);
	}

	player_Death [ playerid ] = true ;

	return true;
}

CreateCorpse ( playerid, c_skinid, Float: c_pos_x, Float: c_pos_y, Float: c_pos_z, Float: c_pos_a ) {

	new corpseid = GetFreeCorpseID () ;

	if ( corpseid == -1 ) {

		return printf("Tried creating corpse for (%d) %s, but GetFreeCorpseID() returned -1.", playerid, ReturnUserName ( playerid, true ) ) ;
	}

	if ( IsValidDynamic3DTextLabel ( playerCorpseInfo [ playerid ] ) ) {

		DestroyDynamic3DTextLabel( playerCorpseInfo [ playerid ] ) ;
	}

	if ( IsValidActor ( playerCorpse [ playerid ] ) ) {
		
		DestroyActor ( playerCorpse [ playerid ] ) ;
	}

   	playerCorpseInfo [ playerid ] = CreateDynamic3DTextLabel(sprintf("[Corpse of %s]", ReturnUserName ( playerid, false )), COLOR_INJURY, c_pos_x, c_pos_y, c_pos_z - 0.25, 20.0 ) ;
	playerCorpse [ playerid ] = CreateActor ( c_skinid, c_pos_x, c_pos_y, c_pos_z, c_pos_a ) ;

	SetActorVirtualWorld(playerCorpse [ playerid ], GetPlayerVirtualWorld(playerid)) ;

	Corpse [ corpseid ] [ corpse_id ] = corpseid ;
	Corpse [ corpseid ] [ corpse_pid ] = playerid ;
	Corpse [ corpseid ] [ corpse_skin ] = c_skinid ;

	Corpse [ corpseid ] [ corpse_x_pos ] = c_pos_x ;
	Corpse [ corpseid ] [ corpse_y_pos ] = c_pos_y ;
	Corpse [ corpseid ] [ corpse_z_pos ] = c_pos_z ;

	defer ActorRemover(playerid, corpseid) ;

	return true;
}

GetFreeCorpseID () {

	for ( new i; i < MAX_CORPSES; i ++ ) {

		if ( Corpse [ i ] [ corpse_id ] == -1 ) {

			return i ;
		}

		else continue ;
	}

	return -1 ;
}

IsPlayerNearCorpse ( playerid ) {

	for ( new i; i < MAX_CORPSES; i ++ ) {

		if ( Corpse [ i ] [ corpse_id ] != -1 ) {

			if ( IsPlayerInRangeOfPoint ( playerid, 2.5, Corpse [ i ] [ corpse_x_pos ], Corpse [ i ] [ corpse_y_pos ], Corpse [ i ] [ corpse_z_pos ] ) ) {
			
				return i ;
			}

			else continue ;
		}

		else continue ;
	}

	return -1 ;
}

ResetCorpse ( playerid, corpseid ) {

	Corpse [ corpseid ] [ corpse_id ] = -1 ;
	Corpse [ corpseid ] [ corpse_pid ] = -1 ;
	Corpse [ corpseid ] [ corpse_skin ] = -1 ;

	Corpse [ corpseid ] [ corpse_x_pos ] = 0.0 ;
	Corpse [ corpseid ] [ corpse_y_pos ] = 0.0 ;
	Corpse [ corpseid ] [ corpse_z_pos ] = 0.0 ;

	DestroyActor ( playerCorpse [ playerid ] ) ;

	DestroyDynamic3DTextLabel( playerCorpseInfo [ playerid ] ) ;
}

timer ActorRemover[600000](playerid, corpseid ) {

////	print("ActorRemover timer called (corpse.pwn)");

	if ( IsValidActor ( playerCorpse [ playerid ] ) ) {

		//SendServerMessage ( playerid, "Your corpse has expired as ten minutes have passed.", MSG_TYPE_INFO ) ;

		ResetCorpse ( playerid, corpseid ) ;
	}
}
