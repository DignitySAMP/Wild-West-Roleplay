#include <a_samp>


new Text: poster_Outline [ 2 ] ; 

new Text: poster_infoLines [ 3 ] ; 
new Text: poster_divider [ 2 ] ; 

new PlayerText: poster_customData [ MAX_PLAYERS ] [ 3 ] ;

ShowWantedPoster ( playerid, posterid ) {
// criminal_data = enum id 

	PlayerTextDrawSetPreviewModel(playerid, poster_customData [ playerid ] [ 0 ], WantedPoster [ posterid ] [ poster_skin ] ) ;
	PlayerTextDrawSetString(playerid, poster_customData [ playerid ] [ 1 ], sprintf("$%s",IntegerWithDelimiter(WantedPoster [ posterid ] [ poster_price ]) ) ) ;
	
	new wantedName [ MAX_PLAYER_NAME ] ; 
	strcat( wantedName, WantedPoster [ posterid ] [ poster_name ], MAX_PLAYER_NAME ) ; 

	PlayerTextDrawSetString(playerid, poster_customData [ playerid ] [ 2 ], wantedName ) ;

	for ( new i; i < 3 ; i ++ ) {

		TextDrawShowForPlayer ( playerid, poster_infoLines [ i ] ) ;
		PlayerTextDrawShow ( playerid, poster_customData [ playerid ] [ i ] ) ;
	}

	for ( new i; i < 2 ; i ++ ) {
		
		TextDrawShowForPlayer ( playerid, poster_divider [ i ] ) ;
		TextDrawShowForPlayer ( playerid, poster_Outline [ i ] ) ;
	}

	SelectTextDraw(playerid, 0xFFFFFF) ;

	return true ;
}

HideWantedPoster ( playerid ) {

	for ( new i; i < 3 ; i ++ ) {

		TextDrawHideForPlayer ( playerid, poster_infoLines [ i ] ) ;
		PlayerTextDrawHide ( playerid, poster_customData [ playerid ] [ i ] ) ;
	}

	for ( new i; i < 2 ; i ++ ) {

		TextDrawHideForPlayer ( playerid, poster_divider [ i ] ) ;
		TextDrawHideForPlayer ( playerid, poster_Outline [ i ] ) ;
	}

	return true ;
}

DestoryWantedPosterTDs ( playerid ) {

	for ( new i; i < 3; i ++ ) {

		PlayerTextDrawDestroy ( playerid, poster_customData [ playerid ] [ i ] ) ;
	}

	return true ;
}

LoadWantedPosterTextDraws ( playerid ) {

	poster_Outline [ 0 ] = TextDrawCreate ( 403.333282, 138.803665, "usebox" ) ;
	TextDrawLetterSize ( poster_Outline [ 0 ], 0.000000, 23.085803 ) ;
	TextDrawTextSize ( poster_Outline [ 0 ], 236.000030, 0.000000 ) ;
	TextDrawUseBox ( poster_Outline [ 0 ], true ) ;
	TextDrawBoxColor ( poster_Outline [ 0 ], 572662527 ) ;

	poster_Outline [ 1 ] = TextDrawCreate ( 402.333343, 140.048156, "usebox" ) ;
	TextDrawLetterSize ( poster_Outline [ 1 ], 0.000000, 22.782508 ) ;
	TextDrawTextSize ( poster_Outline [ 1 ], 237.000000, 0.000000 ) ;
	TextDrawUseBox ( poster_Outline [ 1 ], true ) ;
	TextDrawBoxColor ( poster_Outline [ 1 ], -1113289473 ) ;

	/////////////////////////////////////////

	poster_divider [ 0 ] = TextDrawCreate(390.000000, 182.4, "usebox");
	TextDrawLetterSize(poster_divider [ 0 ], 0.000000, -0.224484);
	TextDrawTextSize(poster_divider [ 0 ], 247.000000, 0.000000);
	TextDrawUseBox(poster_divider [ 0 ], true);
	TextDrawBoxColor(poster_divider [ 0 ], 572662527);

	poster_divider [ 1 ] = TextDrawCreate(390.000000, 312.5, "usebox");
	TextDrawLetterSize(poster_divider [ 1 ], 0.000000, -0.224484);
	TextDrawTextSize(poster_divider [ 1 ], 247.000000, 0.000000);
	TextDrawUseBox(poster_divider [ 1 ], true);
	TextDrawBoxColor(poster_divider [ 1 ], 572662527);

	/////////////////////////////////////////

	poster_infoLines [ 0 ] = TextDrawCreate(318.333465, 138.548126, "WANTED") ;
	TextDrawLetterSize(poster_infoLines [ 0 ], 0.769000, 3.217778) ;
	TextDrawAlignment(poster_infoLines [ 0 ], 2) ;
	TextDrawColor(poster_infoLines [ 0 ], 572662527) ;
	TextDrawSetOutline(poster_infoLines [ 0 ], 0) ;
	TextDrawSetShadow(poster_infoLines [ 0 ] , 0) ;
	TextDrawBackgroundColor(poster_infoLines [ 0 ], 51) ;
	TextDrawFont(poster_infoLines [ 0 ], 2) ;
	TextDrawSetProportional(poster_infoLines [ 0 ], 1) ;

	poster_infoLines [ 1 ] = TextDrawCreate(317.333343, 163.851760, "DEAD or ALIVE") ;
	TextDrawLetterSize(poster_infoLines [ 1 ], 0.449999, 1.600000) ;
	TextDrawAlignment(poster_infoLines [ 1 ], 2) ;
	TextDrawColor(poster_infoLines [ 1 ], 572662527) ;
	TextDrawSetShadow(poster_infoLines [ 1 ], 0) ;
	TextDrawSetOutline(poster_infoLines [ 1 ], 0) ;
	TextDrawBackgroundColor(poster_infoLines [ 0 ], 51) ;
	TextDrawFont(poster_infoLines [ 1 ], 1) ;
	TextDrawSetProportional(poster_infoLines [ 1 ], 1) ;

	poster_infoLines [ 2 ] = TextDrawCreate(318.000000, 328.533477, "IF SIGHTED IMMEDIATELY CONTACT~n~LOCAL LAW ENFORCEMENT OFFICE") ;
	TextDrawLetterSize(poster_infoLines [ 2 ], 0.245333, 0.820148) ;
	TextDrawAlignment(poster_infoLines [ 2 ], 2) ;
	TextDrawColor(poster_infoLines [ 2 ], 572662527) ;
	TextDrawSetOutline(poster_infoLines [ 2 ], 0) ;
	TextDrawSetShadow(poster_infoLines [ 2 ], 0) ;
	TextDrawBackgroundColor(poster_infoLines [ 2 ], 51) ;
	TextDrawFont(poster_infoLines [ 2 ], 1) ;
	TextDrawSetProportional(poster_infoLines [ 2 ], 1) ;

	/////////////////////////////////////////

	poster_customData [ playerid ] [ 0 ] = CreatePlayerTextDraw(playerid, 265, 198, "usebox") ;
	PlayerTextDrawTextSize( playerid, poster_customData [ playerid ] [ 0 ], 100, 110) ;
	PlayerTextDrawUseBox( playerid, poster_customData [ playerid ] [ 0 ], true) ;
   	PlayerTextDrawFont(playerid, poster_customData [ playerid ] [ 0 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawBackgroundColor(playerid, poster_customData [ playerid ] [ 0 ], 0x00000000);
    PlayerTextDrawBoxColor(playerid, poster_customData [ playerid ] [ 0 ], 0x00000000);
    PlayerTextDrawColor(playerid, poster_customData [ playerid ] [ 0 ], 0xC29F82ff);
    PlayerTextDrawSetPreviewModel(playerid, poster_customData [ playerid ] [ 0 ], 28);

	poster_customData [ playerid ] [ 1 ] = CreatePlayerTextDraw(playerid, 318.000122, 313.600311, "$1,000,000 REWARD") ;
	PlayerTextDrawLetterSize( playerid, poster_customData [ playerid ] [ 1 ], 0.408999, 1.409185) ;
	PlayerTextDrawAlignment( playerid, poster_customData [ playerid ] [ 1 ], 2) ;
	PlayerTextDrawColor( playerid, poster_customData [ playerid ] [ 1 ], 572662527) ;
	PlayerTextDrawSetShadow( playerid, poster_customData [ playerid ] [ 1 ], 0) ;
	PlayerTextDrawSetOutline( playerid, poster_customData [ playerid ] [ 1 ], 0) ;
	PlayerTextDrawFont( playerid, poster_customData [ playerid ] [ 1 ], 1) ;
	PlayerTextDrawSetProportional( playerid, poster_customData [ playerid ] [ 1 ], 1) ;

	poster_customData [ playerid ] [ 2 ] = CreatePlayerTextDraw ( playerid, 318.000061, 187.911087, "FIRSTNAME_LASTNAME" ) ;
	PlayerTextDrawLetterSize  ( playerid, poster_customData [ playerid ] [ 2 ], 0.340333, 1.226666 ) ;
	PlayerTextDrawAlignment ( playerid, poster_customData [ playerid ] [ 2 ], 2 ) ;
	PlayerTextDrawColor ( playerid, poster_customData [ playerid ] [ 2 ], 572662527 ) ;
	PlayerTextDrawSetOutline ( playerid, poster_customData [ playerid ] [ 2 ], 0 ) ;
	PlayerTextDrawSetShadow( playerid, poster_customData [ playerid ] [ 2 ], 0) ;
	PlayerTextDrawFont ( playerid, poster_customData [ playerid ] [ 2 ], 1 ) ;
	PlayerTextDrawSetProportional ( playerid, poster_customData [ playerid ] [ 2 ], 1 ) ;

	return true ;
}