new Text: BloodSplats [ 5 ] ;
new bool: PlayerSplatShown [ MAX_PLAYERS ] [ sizeof ( BloodSplats ) ] ;
new PlayerSplatValue [ MAX_PLAYERS ] [ sizeof ( BloodSplats ) ] ;

CMD:splat ( playerid ) {

	return ShowBloodSplat ( playerid ) ;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart) {

	if ( IsPlayerRidingHorse [ playerid ] ) {

		return false ;
	}

	if ( playerid != issuerid && issuerid != INVALID_PLAYER_ID ) {

		//return ShowBloodSplat ( playerid ) ;
	 }

	#if defined splat_OnPlayerTakeDamage
		return splat_OnPlayerTakeDamage ( playerid, issuerid, Float:amount, weaponid, bodypart );
	#else
		return ShowBloodSplat ( playerid ) ;
	#endif
}
#if defined _ALS_OnPlayerTakeDamage
	#undef OnPlayerTakeDamage
#else
	#define _ALS_OnPlayerTakeDamage
#endif

#define OnPlayerTakeDamage splat_OnPlayerTakeDamage
#if defined splat_OnPlayerTakeDamage
	forward splat_OnPlayerTakeDamage ( playerid, issuerid, Float:amount, weaponid, bodypart ) ;
#endif

ShowBloodSplat ( playerid ) {

	new splatid ;

	splatid = random ( sizeof ( BloodSplats ) ) ;
	PlayerSplatValue [ playerid ] [ splatid ] = 5 ;

	if ( ! PlayerSplatShown [ playerid ] [ splatid ] ) {

		PlayerSplatShown [ playerid ] [ splatid ] = true ;
	}

	else if ( PlayerSplatShown [ playerid ] [ splatid ] ) {


		if ( splatid < sizeof ( BloodSplats ) ) {

			splatid ++ ;
		}

		if ( splatid >= sizeof ( BloodSplats ) ) {

			splatid = 0 ;
		}

		PlayerSplatShown [ playerid ] [ splatid ] = true ;
	}

	TextDrawColor ( BloodSplats [ splatid ], 0xFFFFFF80 ) ;
	TextDrawShowForPlayer(playerid, BloodSplats [ splatid ] ) ;

	defer ClearBloodSplat(playerid, splatid);

	printf("Showing blood splat ID %d/%d to player %s", splatid, sizeof ( BloodSplats ), ReturnUserName ( playerid, true ) ) ;

	return true ;
}

timer ClearBloodSplat[150](playerid, splatid) {

////	print("ClearBloodSplat timer called (splats.pwn)");

	switch ( PlayerSplatValue [ playerid ] [ splatid ] ) {

		case 5: TextDrawColor ( BloodSplats [ splatid ], 0xFFFFFF60 ) ;
		case 4: TextDrawColor ( BloodSplats [ splatid ], 0xFFFFFF50 ) ;
		case 3: TextDrawColor ( BloodSplats [ splatid ], 0xFFFFFF30 ) ;
		case 2: TextDrawColor ( BloodSplats [ splatid ], 0xFFFFFF20 ) ;
		case 1: TextDrawColor ( BloodSplats [ splatid ], 0xFFFFFF10 ) ;

		default: {
			TextDrawHideForPlayer(playerid, BloodSplats [ splatid ] ) ;
			PlayerSplatShown [ playerid ] [ splatid ] = false ;

			return true ;	
		}
	}

	TextDrawShowForPlayer(playerid, BloodSplats [ splatid ] ) ;

 	PlayerSplatValue [ playerid ] [ splatid ] -- ;
	defer ClearBloodSplat(playerid, splatid);

 	return true ;
}

LoadBloodSplatTextures () {

	BloodSplats [ 0 ] = TextDrawCreate ( 50.0, 64.0, " " ) ;
	TextDrawColor ( BloodSplats [ 0 ], 0xFFFFFF70 ) ;
	TextDrawFont ( BloodSplats [ 0 ], TEXT_DRAW_FONT_MODEL_PREVIEW ) ;
	TextDrawTextSize ( BloodSplats [ 0 ], 500, 500  ) ;
	TextDrawBackgroundColor ( BloodSplats [ 0 ], 0x00000000 ) ;
	TextDrawSetPreviewModel ( BloodSplats [ 0 ], 19836 ) ;
	TextDrawSetPreviewRot( BloodSplats [ 0 ], 90.0, 0.0, 00.0, 1.0 ) ;

	BloodSplats [ 1 ] = TextDrawCreate ( -50.0, 64.0, " " ) ;
	TextDrawFont ( BloodSplats [ 1 ], TEXT_DRAW_FONT_MODEL_PREVIEW ) ;
	TextDrawColor ( BloodSplats [ 1 ], 0xFFFFFF70 ) ;
	TextDrawTextSize ( BloodSplats [ 1 ], 350, 500  ) ;
	TextDrawBackgroundColor ( BloodSplats [ 1 ], 0x00000000 ) ;
	TextDrawSetPreviewModel ( BloodSplats [ 1 ], 19836 ) ;
	TextDrawSetPreviewRot( BloodSplats [ 1 ], 90.0, 0.0, 280.0, 1.0 ) ;

	BloodSplats [ 2 ] = TextDrawCreate ( 280.0, 64.0, " " ) ;
	TextDrawFont ( BloodSplats [ 2 ], TEXT_DRAW_FONT_MODEL_PREVIEW ) ;
	TextDrawColor ( BloodSplats [ 2 ], 0xFFFFFF70 ) ;
	TextDrawTextSize ( BloodSplats [ 2 ], 450, 500  ) ;
	TextDrawBackgroundColor ( BloodSplats [ 2 ], 0x00000000 ) ;
	TextDrawSetPreviewModel ( BloodSplats [ 2 ], 19836 ) ;
	TextDrawSetPreviewRot( BloodSplats [ 2 ], 90.0, 0.0, 90.0, 1.0 ) ;

	BloodSplats [ 3 ] = TextDrawCreate ( 280.0, -150.0, " " ) ;
	TextDrawFont ( BloodSplats [ 3 ], TEXT_DRAW_FONT_MODEL_PREVIEW ) ;
	TextDrawColor ( BloodSplats [ 3 ], 0xFFFFFF70 ) ;
	TextDrawTextSize ( BloodSplats [ 3 ], 450, 500  ) ;
	TextDrawBackgroundColor ( BloodSplats [ 3 ], 0x00000000 ) ;
	TextDrawSetPreviewModel ( BloodSplats [ 3 ], 19836 ) ;
	TextDrawSetPreviewRot( BloodSplats [ 3 ], 90.0, 0.0, 20.0, 1.0 ) ;

	BloodSplats [ 4 ] = TextDrawCreate ( 50.0, -120.0, " " ) ;
	TextDrawFont ( BloodSplats [ 4 ], TEXT_DRAW_FONT_MODEL_PREVIEW ) ;
	TextDrawColor ( BloodSplats [ 4 ], 0xFFFFFF70 ) ;
	TextDrawTextSize ( BloodSplats [ 4 ], 450, 450  ) ;
	TextDrawBackgroundColor ( BloodSplats [ 4 ], 0x00000000 ) ;
	TextDrawSetPreviewModel ( BloodSplats [ 4 ], 19836 ) ;
	TextDrawSetPreviewRot( BloodSplats [ 4 ], 90.0, 0.0, 180.0, 1.0 ) ;

	return true ;
}