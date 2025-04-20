public OnPlayerClickTextDraw(playerid, Text:clickedid) {

	if ( Text:INVALID_TEXT_DRAW == clickedid && IsPlayerCreatingCharacter [ playerid ] ) {

		SelectTextDraw(playerid, 0xA3A3A3FF ) ;
	}

	if ( clickedid == creation_tds_static [ 5 ] ) {

		NameSelection ( playerid ) ;
	}

	#if defined create_OnPlayerClickTextDraw
		return create_OnPlayerClickTextDraw(playerid, Text: clickedid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerClickTextDraw
	#undef OnPlayerClickTextDraw
#else
	#define _ALS_OnPlayerClickTextDraw
#endif

#define OnPlayerClickTextDraw create_OnPlayerClickTextDraw
#if defined create_OnPlayerClickTextDraw
	forward create_OnPlayerClickTextDraw(playerid, Text: clickedid);
#endif

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {

	if ( PlayerText:INVALID_TEXT_DRAW == playertextid && IsPlayerCreatingCharacter [ playerid ] ) {

		SelectTextDraw(playerid, 0xA3A3A3FF ) ;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////// gender selectors ///////////////////////////////////////////

	if ( playertextid == creation_tds_player [ 3 ] || playertextid == creation_tds_player [ 4 ] ) { 

		new genders [ ] [ ] = { "Male", "Female" } ;

		player_GenderSelection [ playerid ] =! player_GenderSelection [ playerid ] ;
		PlayerTextDrawSetString(playerid, creation_tds_player [ 2 ], genders [ player_GenderSelection [ playerid ] ] [ 0 ] ) ;

		UpdateCreationSkin ( playerid ) ;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////// race selectors ////////////////////////////////////////////

	if ( playertextid == creation_tds_player [ 7 ] || playertextid == creation_tds_player [ 8 ] ) {

		if ( playertextid == creation_tds_player [ 7 ]  ) player_RaceSelection [ playerid ] -- ;
		else if ( playertextid == creation_tds_player [ 8 ] ) player_RaceSelection [ playerid ] ++ ;

		new races [ ] [ ] = { "Caucasian", "Hispanic", "African", "Asian", "Native" } ;

		if (  player_RaceSelection [ playerid ] < 0 ) player_RaceSelection [ playerid ] = sizeof ( races ) - 1 ;
		else if ( player_RaceSelection [ playerid ] >= sizeof ( races ) ) player_RaceSelection [ playerid ] = 0 ;

		PlayerTextDrawSetString(playerid, creation_tds_player [ 6 ], races [ player_RaceSelection [ playerid ] ] [ 0 ] ) ;
		UpdateCreationSkin ( playerid ) ;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////// town selectors ////////////////////////////////////////////

	if ( playertextid == creation_tds_player [ 11 ] || playertextid == creation_tds_player [ 12 ] ) {

		if ( playertextid == creation_tds_player [ 11 ]  ) player_TownSelection [ playerid ] -- ;
		else if ( playertextid == creation_tds_player [ 12 ] ) player_TownSelection [ playerid ] ++ ;

		new towns [ ] [ ] = {"Longcreek", "Fremont" } ;

		if (  player_TownSelection [ playerid ] < 0 ) player_TownSelection [ playerid ] = sizeof ( towns ) - 1 ;
		else if ( player_TownSelection [ playerid ] >= sizeof ( towns ) ) player_TownSelection [ playerid ] = 0 ;

		PlayerTextDrawSetString(playerid, creation_tds_player [ 10 ], towns [ player_TownSelection [ playerid ] ] [ 0 ] ) ;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////// age selectors ////////////////////////////////////////////

	if ( playertextid == creation_tds_player [ 15 ] || playertextid == creation_tds_player [ 16 ] ) {

		if ( playertextid == creation_tds_player [ 15 ]  ) player_AgeSelection [ playerid ] -- ;
		else if ( playertextid == creation_tds_player [ 16 ] ) player_AgeSelection [ playerid ] ++ ;


		if (  player_AgeSelection [ playerid ] < 8 ) player_AgeSelection [ playerid ] = 80  ;
		else if ( player_AgeSelection [ playerid ] > 80 ) player_AgeSelection [ playerid ] = 8 ;

		PlayerTextDrawSetString(playerid, creation_tds_player [ 14 ], sprintf("Age: %d", player_AgeSelection [ playerid ] ) ) ;
	}
	
	#if defined cr_OnPlayerClickPlayerTextDraw
		return cr_OnPlayerClickPlayerTextDraw(playerid, PlayerText: playertextid );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerClickPlayerTD
	#undef OnPlayerClickPlayerTextDraw
#else
	#define _ALS_OnPlayerClickPlayerTD
#endif

#define OnPlayerClickPlayerTextDraw cr_OnPlayerClickPlayerTextDraw
#if defined cr_OnPlayerClickPlayerTextDraw
	forward cr_OnPlayerClickPlayerTextDraw(playerid, PlayerText: playertextid );
#endif