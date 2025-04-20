#define MAX_CHARACTER_BOX		( 3 )

#define 	CHAR_HEADER_ADJUST		( 5 )
#define 	CHAR_INCR_HORIZONTAL	( 112.5 )
#define 	CHAR_INCR_FIX			( 22.5 )

new Text: CharacterSel_HeaderBox ;
new Text: CharacterSel_HeaderText ;

new Text: CharacterSel_BoxDraw			[ MAX_CHARACTER_BOX ] = Text: INVALID_TEXT_DRAW;
new Text: CharacterSel_BoxOutline 		[ MAX_CHARACTER_BOX ] = Text: INVALID_TEXT_DRAW;

new Text: CharacterSel_Box 				[ MAX_CHARACTER_BOX ] = Text: INVALID_TEXT_DRAW;
new Text: CharacterSelButton_Text 		[ MAX_CHARACTER_BOX ] = Text: INVALID_TEXT_DRAW;


new PlayerText: CharacterSel_Name 			[ MAX_CHARACTER_BOX ] = PlayerText: INVALID_TEXT_DRAW;
new PlayerText: CharacterSel_SkinBox 		[ MAX_CHARACTER_BOX ] = PlayerText: INVALID_TEXT_DRAW;

new PlayerText: CharacterSel_HoursText 		[ MAX_CHARACTER_BOX ] = PlayerText: INVALID_TEXT_DRAW;
new PlayerText: CharacterSel_PosseText 		[ MAX_CHARACTER_BOX ] = PlayerText: INVALID_TEXT_DRAW;
new PlayerText: CharacterSel_ExpText 		[ MAX_CHARACTER_BOX ] = PlayerText: INVALID_TEXT_DRAW;
new PlayerText: CharacterSel_ExpInfo		[ MAX_CHARACTER_BOX ] = PlayerText: INVALID_TEXT_DRAW;

new PlayerBar: CharacterExpBar 				[ MAX_CHARACTER_BOX ]  = PlayerBar: INVALID_PLAYER_BAR_ID;

new Text: CharacterEmpty_Header 		[ MAX_CHARACTER_BOX ] = Text: INVALID_TEXT_DRAW;
new Text: CharacterEmpty_Button 		[ MAX_CHARACTER_BOX ] = Text: INVALID_TEXT_DRAW;
new Text: CharacterEmpty_Text 			[ MAX_CHARACTER_BOX ] = Text: INVALID_TEXT_DRAW;

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

DestroyCharacterTextDraws ( playerid ) {
	for ( new i; i < MAX_CHARACTER_BOX; i ++ ) {
		PlayerTextDrawDestroy(playerid, CharacterSel_Name 		[ i ]  ) ;
		PlayerTextDrawDestroy(playerid, CharacterSel_SkinBox 	[ i ]  ) ;

		DestroyPlayerProgressBar ( playerid, CharacterExpBar 	[ i ] ) ;

		PlayerTextDrawDestroy(playerid, CharacterSel_HoursText [ i ]  ) ;
		PlayerTextDrawDestroy(playerid, CharacterSel_PosseText [ i ]  ) ;
		PlayerTextDrawDestroy(playerid, CharacterSel_ExpText 	[ i ]  ) ;
		PlayerTextDrawDestroy(playerid, CharacterSel_ExpInfo 	[ i ] ) ;
	}

	return true ;
}


timer Delayed_TextdrawLoad[1000](playerid) {

////	print("Delayed_TextdrawLoad timer called (select.pwn)");

	if ( ! Login_SelectionPage [ playerid ] ) {

		return DisplayCharacterTextDraws ( playerid ) ;
	}

	else if ( Login_SelectionPage [ playerid ] ) {

		HideCharacterTextDraws ( playerid ) ;
		Login_SelectionPage [ playerid ] = false ;
//		Account_CharacterCheck ( playerid ) ;

		SendServerMessage ( playerid, "There was an issue loading the character textdraws. Please wait one second while we refresh them.", MSG_TYPE_WARN ) ;
		defer Delayed_TextdrawLoad(playerid) ;
	}

	return true ;
}

DisplayCharacterTextDraws ( playerid ) {

	new character [ MAX_CHARACTERS], characterName [ MAX_CHARACTERS] [ MAX_PLAYER_NAME ], string [ 64 ], expLeft ;

	Login_SelectionPage [ playerid ] = true ;

	SelectTextDraw(playerid, 0xA3A3A3FF ) ;

	for ( new i; i < MAX_CHARACTERS; i ++ ) {

		character [ i ] = CharBuffer [ playerid ] [ i ] [ character_id ] ;
		format ( characterName [ i ], MAX_PLAYER_NAME, "%s", CharBuffer [ playerid ] [ i ]  [ character_name ] ) ;

		TextDrawShowForPlayer(playerid, CharacterSel_HeaderBox ) ;
		TextDrawShowForPlayer(playerid, CharacterSel_HeaderText ) ;

		TextDrawShowForPlayer(playerid, CharacterSel_BoxDraw 		[ i ] ) ;
		TextDrawShowForPlayer(playerid, CharacterSel_BoxOutline 	[ i ] ) ;

		TextDrawShowForPlayer(playerid, CharacterSel_Box 			[ i ] ) ;

		if ( ! character [ i ] ) {

			TextDrawSetString( CharacterEmpty_Header [ i ], "No character found") ;
			TextDrawShowForPlayer ( playerid, CharacterEmpty_Header [ i ] ) ;	

			TextDrawShowForPlayer ( playerid, CharacterEmpty_Button [ i ] ) ;
			TextDrawShowForPlayer ( playerid, CharacterEmpty_Text [ i ] ) ;	
		}

		else if (character [ i ]) {
			
			TextDrawShowForPlayer(playerid, CharacterSelButton_Text 	[ i ] ) ;


			format ( string, sizeof ( string ), "Hours:~n~~w~%d", CharBuffer [ playerid ] [ i ] [ character_hours ] ) ;
			PlayerTextDrawSetString ( playerid,  CharacterSel_HoursText [ i ], string ) ;
			PlayerTextDrawShow(playerid, CharacterSel_HoursText [ i ]  ) ;

			PlayerTextDrawSetString ( playerid, CharacterSel_Name [ i ], characterName [ i ]) ;
			PlayerTextDrawShow(playerid, CharacterSel_Name 		[ i ]  ) ;

			PlayerTextDrawSetPreviewModel(playerid, CharacterSel_SkinBox [ i ], CharBuffer [ playerid ] [ i ] [ character_skin ]) ;
			PlayerTextDrawShow(playerid, CharacterSel_SkinBox 	[ i ]  ) ;

			switch ( CharBuffer [ playerid ] [ i ] [ character_posse ] ) {

				case 1: string = "Posse:~n~~w~Law Office";
				default: string = "Posse:~n~~w~Civilian";
			}

			PlayerTextDrawSetString(playerid, CharacterSel_PosseText [ i ], string );
			PlayerTextDrawShow(playerid, CharacterSel_PosseText [ i ]  ) ;

			expLeft = 16 * CharBuffer [ playerid ] [ i ] [ character_level ] ;
			format ( string, sizeof ( string ), "%d/%d", CharBuffer [ playerid ] [ i ] [ character_expleft ], expLeft ) ;

			PlayerTextDrawSetString(playerid, CharacterSel_ExpInfo [ i ], string ) ;
			PlayerTextDrawShow(playerid, CharacterSel_ExpInfo 	[ i ]  ) ;

			SetPlayerProgressBarMaxValue(playerid, CharacterExpBar [ i ], expLeft ) ;
			SetPlayerProgressBarValue(playerid, CharacterExpBar [ i ], CharBuffer [ playerid ] [ i ] [ character_expleft ] ) ;
			ShowPlayerProgressBar ( playerid, CharacterExpBar 	[ i ] ) ;

			PlayerTextDrawShow(playerid, CharacterSel_HoursText [ i ]  ) ;
			//PlayerTextDrawShow(playerid, CharacterSel_PosseText [ i ]  ) ;
			PlayerTextDrawShow(playerid, CharacterSel_ExpText 	[ i ]  ) ;
		}
	}

	return true ;
}

LoadEmptyCharacterTextDraws ( ) {
	
	CharacterEmpty_Header[ 0 ] = TextDrawCreate(215 - CHAR_INCR_FIX, 200.355560, "No character found");
	TextDrawLetterSize(CharacterEmpty_Header[ 0 ], 0.297666, 1.272297);
	TextDrawAlignment(CharacterEmpty_Header[ 0 ], 2) ;
	TextDrawColor(CharacterEmpty_Header [ 0 ], -780181761);
	TextDrawBackgroundColor(CharacterEmpty_Header [ 0 ], 51);

	CharacterEmpty_Header[ 1 ] = TextDrawCreate(215 + CHAR_INCR_HORIZONTAL, 200.355560, "No character found");
	TextDrawLetterSize(CharacterEmpty_Header[ 1 ], 0.297666, 1.272297);
	TextDrawAlignment(CharacterEmpty_Header[ 1 ], 2) ;
	TextDrawColor(CharacterEmpty_Header [ 1 ], -780181761);
	TextDrawBackgroundColor(CharacterEmpty_Header [ 1 ], 51);

	CharacterEmpty_Header[ 2 ] = TextDrawCreate(215 + CHAR_INCR_HORIZONTAL * 2.25, 200.355560, "No character found");
	TextDrawLetterSize(CharacterEmpty_Header[ 2 ], 0.297666, 1.272297);
	TextDrawAlignment(CharacterEmpty_Header[ 2 ], 2) ;
	TextDrawColor(CharacterEmpty_Header [ 2 ], -780181761);
	TextDrawBackgroundColor(CharacterEmpty_Header [ 2 ], 51);

		////////////////////////////////////////////////////////////////////////////

	CharacterEmpty_Button[ 0 ] = TextDrawCreate(192.5 - CHAR_INCR_FIX, 210, "usebox");
	TextDrawTextSize(CharacterEmpty_Button[ 0 ], 50.0, 65.0);
	TextDrawUseBox(CharacterEmpty_Button[ 0 ], true);
	TextDrawFont( CharacterEmpty_Button[ 0 ], TEXT_DRAW_FONT_MODEL_PREVIEW ) ;
	TextDrawBackgroundColor(CharacterEmpty_Button[ 0 ], 0x00000000 ) ;
	TextDrawBoxColor ( CharacterEmpty_Button[ 0 ],  0x00000000 ) ;
	TextDrawSetPreviewModel( CharacterEmpty_Button[ 0 ] , 18631 ) ;
	TextDrawSetSelectable ( CharacterEmpty_Button[ 0 ], true ) ;

	CharacterEmpty_Button[ 1 ] = TextDrawCreate(192.5 + CHAR_INCR_HORIZONTAL, 210, "usebox");
	TextDrawTextSize(CharacterEmpty_Button[ 1 ], 50.0, 65.0);
	TextDrawUseBox(CharacterEmpty_Button[ 1 ], true);
	TextDrawFont( CharacterEmpty_Button[ 1 ], TEXT_DRAW_FONT_MODEL_PREVIEW ) ;
	TextDrawBoxColor ( CharacterEmpty_Button[ 1 ],  0x00000000 ) ;
	TextDrawBackgroundColor(CharacterEmpty_Button[ 1 ], 0x00000000 ) ;
	TextDrawSetPreviewModel( CharacterEmpty_Button[ 1 ] , 18631 ) ;
	TextDrawSetSelectable ( CharacterEmpty_Button[ 1 ], true ) ;

	CharacterEmpty_Button[ 2 ] = TextDrawCreate(192.5 + CHAR_INCR_HORIZONTAL * 2.25, 210, "usebox");
	TextDrawTextSize(CharacterEmpty_Button[ 2 ], 50.0, 65.0);
	TextDrawUseBox(CharacterEmpty_Button[ 2 ], true);
	TextDrawFont( CharacterEmpty_Button[ 2 ], TEXT_DRAW_FONT_MODEL_PREVIEW ) ;
	TextDrawBoxColor ( CharacterEmpty_Button[ 2 ], 0x00000000 ) ;
	TextDrawBackgroundColor(CharacterEmpty_Button[ 2 ], 0x00000000 ) ;
	TextDrawSetPreviewModel( CharacterEmpty_Button[ 2 ] , 18631 ) ;
	TextDrawSetSelectable ( CharacterEmpty_Button[ 2 ], true ) ;

		////////////////////////////////////////////////////////////////////////////

	CharacterEmpty_Text [ 0 ] = TextDrawCreate(215 - CHAR_INCR_FIX, 270, "Click the ? to~n~create a new~n~character.");
	TextDrawLetterSize(CharacterEmpty_Text [ 0 ], 0.339333, 1.288888);
	TextDrawAlignment(CharacterEmpty_Text[ 0 ], 2) ;
	TextDrawColor(CharacterEmpty_Text [ 0 ], -780181761);
	TextDrawBackgroundColor(CharacterEmpty_Text [ 0 ], 51);

	CharacterEmpty_Text [ 1 ] = TextDrawCreate(215 + CHAR_INCR_HORIZONTAL, 270, "Click the ? to~n~create a new~n~character.");
	TextDrawLetterSize(CharacterEmpty_Text [ 1 ], 0.339333, 1.288888);
	TextDrawAlignment(CharacterEmpty_Text[ 1 ], 2) ;
	TextDrawColor(CharacterEmpty_Text [ 1 ], -780181761);
	TextDrawBackgroundColor(CharacterEmpty_Text [ 1 ], 51);

	CharacterEmpty_Text [ 2 ] = TextDrawCreate(215 + CHAR_INCR_HORIZONTAL * 2.25, 270, "Click the ? to~n~create a new~n~character.");
	TextDrawLetterSize(CharacterEmpty_Text [ 2 ], 0.339333, 1.288888);
	TextDrawAlignment(CharacterEmpty_Text[ 2 ], 2) ;
	TextDrawColor(CharacterEmpty_Text [ 2 ], -780181761);
	TextDrawBackgroundColor(CharacterEmpty_Text [ 2 ], 51);

	return true ;
}

LoadStaticCharacterSelectDraws ( ) {

	CharacterSel_HeaderBox = TextDrawCreate(400 - CHAR_HEADER_ADJUST, 175, "usebox");
	TextDrawLetterSize(CharacterSel_HeaderBox, 0.000000, 1.5);
	TextDrawTextSize(CharacterSel_HeaderBox, 270 - CHAR_HEADER_ADJUST, 0.000000);
	TextDrawUseBox(CharacterSel_HeaderBox, true);
	TextDrawBoxColor(CharacterSel_HeaderBox, 0x111111AA);
	TextDrawBackgroundColor(CharacterSel_HeaderBox, 0x00000000 ) ;

	CharacterSel_HeaderText = TextDrawCreate(276 - CHAR_HEADER_ADJUST, 175, "Select your character");
	TextDrawLetterSize(CharacterSel_HeaderText, 0.339333, 1.288888);
	TextDrawColor(CharacterSel_HeaderText, -780181761);
	TextDrawBackgroundColor(CharacterSel_HeaderText, 51);

		////////////////////////////////////////////////////////////////////////////

	CharacterSel_BoxDraw [ 0 ] = TextDrawCreate(277.3 - CHAR_INCR_FIX, 199.3, "usebox");
	TextDrawLetterSize(CharacterSel_BoxDraw [ 0 ], 0.000000, 12.55);
	TextDrawTextSize(CharacterSel_BoxDraw [ 0 ], 156.0 - CHAR_INCR_FIX, 0.000000);
	TextDrawUseBox(CharacterSel_BoxDraw [ 0 ], true);
	TextDrawBoxColor(CharacterSel_BoxDraw [ 0 ], 286331391);
	TextDrawBackgroundColor(CharacterSel_BoxDraw [ 0 ], 0x00000000 ) ;

	CharacterSel_BoxDraw [ 1 ] = TextDrawCreate(277.3 + CHAR_INCR_HORIZONTAL, 199.3, "usebox");
	TextDrawLetterSize(CharacterSel_BoxDraw [ 1 ], 0.000000, 12.55);
	TextDrawTextSize(CharacterSel_BoxDraw [ 1 ], 156.0 + CHAR_INCR_HORIZONTAL, 0.000000);
	TextDrawUseBox(CharacterSel_BoxDraw [ 1 ], true);
	TextDrawBoxColor(CharacterSel_BoxDraw [ 1 ], 286331391);
	TextDrawBackgroundColor(CharacterSel_BoxDraw [ 1 ], 0x00000000 ) ;

	CharacterSel_BoxDraw [ 2 ] = TextDrawCreate(277.3 + CHAR_INCR_HORIZONTAL * 2.25, 199.3, "usebox");
	TextDrawLetterSize(CharacterSel_BoxDraw [ 2 ], 0.000000, 12.55);
	TextDrawTextSize(CharacterSel_BoxDraw [ 2 ], 156.0 + CHAR_INCR_HORIZONTAL * 2.25, 0.000000);
	TextDrawUseBox(CharacterSel_BoxDraw [ 2 ], true);
	TextDrawBoxColor(CharacterSel_BoxDraw [ 2 ], 286331391);
	TextDrawBackgroundColor(CharacterSel_BoxDraw [ 2 ], 0x00000000 ) ;

		////////////////////////////////////////////////////////////////////////////

	CharacterSel_BoxOutline [ 0 ] = TextDrawCreate(276.333343 - CHAR_INCR_FIX, 201.025955, "usebox");
	TextDrawLetterSize(CharacterSel_BoxOutline [ 0 ], 0.000000, 12.143404);
	TextDrawTextSize(CharacterSel_BoxOutline [ 0 ], 157.000015 - CHAR_INCR_FIX, 0.000000);
	TextDrawUseBox(CharacterSel_BoxOutline [ 0 ], true);
	TextDrawBoxColor(CharacterSel_BoxOutline [ 0 ], -780181761);
	TextDrawBackgroundColor(CharacterSel_BoxOutline [ 0 ], 0x00000000 ) ;

	CharacterSel_BoxOutline [ 1 ] = TextDrawCreate(276.333343 + CHAR_INCR_HORIZONTAL, 201.025955, "usebox");
	TextDrawLetterSize(CharacterSel_BoxOutline [ 1 ], 0.000000, 12.143404);
	TextDrawTextSize(CharacterSel_BoxOutline [ 1 ], 157.000015 + CHAR_INCR_HORIZONTAL, 0.000000);
	TextDrawUseBox(CharacterSel_BoxOutline [ 1 ], true);
	TextDrawBoxColor(CharacterSel_BoxOutline [ 1 ], -780181761);
	TextDrawBackgroundColor(CharacterSel_BoxOutline [ 1 ], 0x00000000 ) ;

	CharacterSel_BoxOutline [ 2 ] = TextDrawCreate(276.333343 + CHAR_INCR_HORIZONTAL * 2.25, 201.025955, "usebox");
	TextDrawLetterSize(CharacterSel_BoxOutline [ 2 ], 0.000000, 12.143404);
	TextDrawTextSize(CharacterSel_BoxOutline [ 2 ], 157.000015 + CHAR_INCR_HORIZONTAL * 2.25, 0.000000);
	TextDrawUseBox(CharacterSel_BoxOutline [ 2 ], true);
	TextDrawBoxColor(CharacterSel_BoxOutline [ 2 ], -780181761);
	TextDrawBackgroundColor(CharacterSel_BoxOutline [ 2 ], 0x00000000 ) ;

		////////////////////////////////////////////////////////////////////////////

	CharacterSel_Box [ 0 ] = TextDrawCreate(275.000000 - CHAR_INCR_FIX, 202.270385, "usebox");
	TextDrawLetterSize(CharacterSel_Box [ 0 ], 0.000000, 11.900192);
	TextDrawTextSize(CharacterSel_Box [ 0 ], 158.000000 - CHAR_INCR_FIX, 0.000000);
	TextDrawUseBox(CharacterSel_Box [ 0 ], true);
	TextDrawBoxColor(CharacterSel_Box [ 0 ], 286331391);
	TextDrawBackgroundColor(CharacterSel_Box [ 0 ], 0x00000000 ) ;

	CharacterSel_Box [ 1 ] = TextDrawCreate(275.000000 + CHAR_INCR_HORIZONTAL, 202.270385, "usebox");
	TextDrawLetterSize(CharacterSel_Box [ 1 ], 0.000000, 11.900192);
	TextDrawTextSize(CharacterSel_Box [ 1 ], 158.000000 + CHAR_INCR_HORIZONTAL, 0.000000);
	TextDrawUseBox(CharacterSel_Box [ 1 ], true);
	TextDrawBoxColor(CharacterSel_Box [ 1 ], 286331391);
	TextDrawBackgroundColor(CharacterSel_Box [ 1 ], 0x00000000 ) ;

	CharacterSel_Box [ 2 ] = TextDrawCreate(275.000000 + CHAR_INCR_HORIZONTAL * 2.25, 202.270385, "usebox");
	TextDrawLetterSize(CharacterSel_Box [ 2 ], 0.000000, 11.900192);
	TextDrawTextSize(CharacterSel_Box [ 2 ], 158.000000 + CHAR_INCR_HORIZONTAL * 2.25, 0.000000);
	TextDrawUseBox(CharacterSel_Box [ 2 ], true);
	TextDrawBoxColor(CharacterSel_Box [ 2 ], 286331391);
	TextDrawBackgroundColor(CharacterSel_Box [ 2 ], 0x00000000 ) ;

		////////////////////////////////////////////////////////////////////////////

	CharacterSelButton_Text [ 0 ] = TextDrawCreate(215 - CHAR_INCR_FIX, 291.5, "Spawn");
	TextDrawLetterSize(CharacterSelButton_Text [ 0 ], 0.339333, 1.288888);
	TextDrawTextSize(CharacterSelButton_Text [ 0 ], 255 - CHAR_INCR_FIX, 10 ) ;
	TextDrawColor(CharacterSelButton_Text [ 0 ], -780181761);
	TextDrawBackgroundColor(CharacterSelButton_Text [ 0 ], 51);
	TextDrawSetSelectable(CharacterSelButton_Text [ 0 ], true ) ;

	CharacterSelButton_Text [ 1 ] = TextDrawCreate(215 + CHAR_INCR_HORIZONTAL, 291.5, "Spawn");
	TextDrawLetterSize(CharacterSelButton_Text [ 1 ], 0.339333, 1.288888);
	TextDrawTextSize(CharacterSelButton_Text [ 1 ], 255 + CHAR_INCR_HORIZONTAL, 10 ) ;
	TextDrawColor(CharacterSelButton_Text [ 1 ], -780181761);
	TextDrawBackgroundColor(CharacterSelButton_Text [ 1 ], 51);
	TextDrawSetSelectable(CharacterSelButton_Text [ 1 ], true ) ;


	CharacterSelButton_Text [ 2 ] = TextDrawCreate(215 + CHAR_INCR_HORIZONTAL * 2.25, 291.5, "Spawn");
	TextDrawLetterSize(CharacterSelButton_Text [ 2 ], 0.339333, 1.288888);
	TextDrawTextSize(CharacterSelButton_Text [ 2 ], 255 + CHAR_INCR_HORIZONTAL * 2.25, 10 ) ;
	TextDrawColor(CharacterSelButton_Text [ 2 ], -780181761);
	TextDrawBackgroundColor(CharacterSelButton_Text [ 2 ], 51);
	TextDrawSetSelectable(CharacterSelButton_Text [ 2 ], true ) ;

	LoadEmptyCharacterTextDraws ( ) ;
}

LoadCharacterSelectDraws ( playerid ) { 

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////

	CharacterSel_Name [ 0 ] = CreatePlayerTextDraw(playerid, 216.333374 - CHAR_INCR_FIX, 200.355560, "Undefined");
	PlayerTextDrawLetterSize(playerid, CharacterSel_Name [ 0 ], 0.297666, 1.272297);
	PlayerTextDrawAlignment(playerid, CharacterSel_Name [ 0 ], 2);
	PlayerTextDrawColor(playerid, CharacterSel_Name [ 0 ], -780181761);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_Name [ 0 ], 51);

	CharacterSel_Name [ 1 ] = CreatePlayerTextDraw(playerid, 216.333374 + CHAR_INCR_HORIZONTAL, 200.355560, "Undefined");
	PlayerTextDrawLetterSize(playerid, CharacterSel_Name [ 1 ], 0.297666, 1.272297);
	PlayerTextDrawAlignment(playerid, CharacterSel_Name [ 1 ], 2);
	PlayerTextDrawColor(playerid, CharacterSel_Name [ 1 ], -780181761);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_Name [ 1 ], 51);

	CharacterSel_Name [ 2 ] = CreatePlayerTextDraw(playerid, 216.333374 + CHAR_INCR_HORIZONTAL * 2.25, 200.355560, "Undefined");
	PlayerTextDrawLetterSize(playerid, CharacterSel_Name [ 2 ], 0.297666, 1.272297);
	PlayerTextDrawAlignment(playerid, CharacterSel_Name [ 2 ], 2);
	PlayerTextDrawColor(playerid, CharacterSel_Name [ 2 ], -780181761);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_Name [ 2 ], 51);

	////////////////////////////////////////////////////////////////////////////

	CharacterSel_SkinBox [ 0 ] = CreatePlayerTextDraw(playerid, 145 - CHAR_INCR_FIX, 210, "skinbox");
	PlayerTextDrawUseBox(playerid, CharacterSel_SkinBox [ 0 ], true);
	PlayerTextDrawBoxColor(playerid, CharacterSel_SkinBox [ 0 ], 0);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_SkinBox [ 0 ], 0x00000000);
	PlayerTextDrawFont(playerid, CharacterSel_SkinBox [ 0 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawTextSize(playerid, CharacterSel_SkinBox [ 0 ], 80.0, 100.0);
    PlayerTextDrawSetPreviewModel(playerid, CharacterSel_SkinBox [ 0 ], 18631);

	CharacterSel_SkinBox [ 1 ] = CreatePlayerTextDraw(playerid, 145 + CHAR_INCR_HORIZONTAL, 210, "skinbox");
	PlayerTextDrawUseBox(playerid, CharacterSel_SkinBox [ 1 ], true);
	PlayerTextDrawBoxColor(playerid, CharacterSel_SkinBox [ 1 ], 0);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_SkinBox [ 1 ], 0x00000000);
	PlayerTextDrawFont(playerid, CharacterSel_SkinBox [ 1 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawTextSize(playerid, CharacterSel_SkinBox [ 1 ], 80.0 + 2.5, 100.0);
    PlayerTextDrawSetPreviewModel(playerid, CharacterSel_SkinBox [ 1 ], 18631);

	CharacterSel_SkinBox [ 2 ] = CreatePlayerTextDraw(playerid, 145  + CHAR_INCR_HORIZONTAL * 2.25, 210, "skinbox");
	PlayerTextDrawUseBox(playerid, CharacterSel_SkinBox [ 2 ], true);
	PlayerTextDrawBoxColor(playerid, CharacterSel_SkinBox [ 2 ], 0);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_SkinBox [ 2 ], 0x00000000);
	PlayerTextDrawFont(playerid, CharacterSel_SkinBox [ 2 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawTextSize(playerid, CharacterSel_SkinBox [ 2 ], 80.0 + 2.5, 100.0);
    PlayerTextDrawSetPreviewModel(playerid, CharacterSel_SkinBox [ 2 ], 18631);

	////////////////////////////////////////////////////////////////////////////

	CharacterSel_HoursText [ 0 ] = CreatePlayerTextDraw(playerid, 211.5 - CHAR_INCR_FIX, 215, "Hours:~n~~w~0");
	PlayerTextDrawLetterSize(playerid, CharacterSel_HoursText [ 0 ], 0.256333, 1.081481);
	PlayerTextDrawColor(playerid, CharacterSel_HoursText [ 0 ], -780181761);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_HoursText [ 0 ], 51);

	CharacterSel_HoursText [ 1 ] = CreatePlayerTextDraw(playerid, 211.5 + CHAR_INCR_HORIZONTAL, 215, "Hours:~n~~w~0");
	PlayerTextDrawLetterSize(playerid, CharacterSel_HoursText [ 1 ], 0.256333, 1.081481);
	PlayerTextDrawColor(playerid, CharacterSel_HoursText [ 1 ], -780181761);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_HoursText [ 1 ], 51);

	CharacterSel_HoursText [ 2 ] = CreatePlayerTextDraw(playerid, 211.5 + CHAR_INCR_HORIZONTAL * 2.25, 215, "Hours:~n~~w~0");
	PlayerTextDrawLetterSize(playerid, CharacterSel_HoursText [ 2 ], 0.256333, 1.081481);
	PlayerTextDrawColor(playerid, CharacterSel_HoursText [ 2 ], -780181761);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_HoursText [ 2 ], 51);

	////////////////////////////////////////////////////////////////////////////

	CharacterSel_PosseText [ 0 ] = CreatePlayerTextDraw(playerid, 211.5 - CHAR_INCR_FIX, 240, "Posse:~n~~w~Civilian");
	PlayerTextDrawLetterSize(playerid, CharacterSel_PosseText [ 0 ], 0.256333, 1.081481);
	PlayerTextDrawColor(playerid, CharacterSel_PosseText [ 0 ], -780181761);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_PosseText [ 0 ], 51);

	CharacterSel_PosseText [ 1 ] = CreatePlayerTextDraw(playerid, 211.5 + CHAR_INCR_HORIZONTAL, 240, "Posse:~n~~w~Civilian");
	PlayerTextDrawLetterSize(playerid, CharacterSel_PosseText [ 1 ], 0.256333, 1.081481);
	PlayerTextDrawColor(playerid, CharacterSel_PosseText [ 1 ], -780181761);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_PosseText [ 1 ], 51);

	CharacterSel_PosseText [ 2 ] = CreatePlayerTextDraw(playerid, 211.5 + CHAR_INCR_HORIZONTAL * 2.25, 240, "Posse:~n~~w~Civilian");
	PlayerTextDrawLetterSize(playerid, CharacterSel_PosseText [ 2 ], 0.256333, 1.081481);
	PlayerTextDrawColor(playerid, CharacterSel_PosseText [ 2 ], -780181761);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_PosseText [ 2 ], 51);

	////////////////////////////////////////////////////////////////////////////

	CharacterSel_ExpText [ 0 ] = CreatePlayerTextDraw(playerid, 211.5 - CHAR_INCR_FIX, 265, "Experience:");
	PlayerTextDrawLetterSize(playerid, CharacterSel_ExpText [ 0 ], 0.256333, 1.081481);
	PlayerTextDrawColor(playerid, CharacterSel_ExpText [ 0 ], -780181761);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_ExpText [ 0 ], 51);

	CharacterSel_ExpText [ 1 ] = CreatePlayerTextDraw(playerid, 211.5 + CHAR_INCR_HORIZONTAL, 265, "Experience:");
	PlayerTextDrawLetterSize(playerid, CharacterSel_ExpText [ 1 ], 0.256333, 1.081481);
	PlayerTextDrawColor(playerid, CharacterSel_ExpText [ 1 ], -780181761);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_ExpText [ 1 ], 51);

	CharacterSel_ExpText [ 2 ] = CreatePlayerTextDraw(playerid, 211.5 + CHAR_INCR_HORIZONTAL * 2.25, 265, "Experience:");
	PlayerTextDrawLetterSize(playerid, CharacterSel_ExpText [ 2 ], 0.256333, 1.081481);
	PlayerTextDrawColor(playerid, CharacterSel_ExpText [ 2 ], -780181761);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_ExpText [ 2 ], 51);

	///////////////////////////////////////////////////////////////////////////

	CharacterExpBar [ 0 ] = CreatePlayerProgressBar(playerid, 211.5 - CHAR_INCR_FIX, 280, 55.5, 6, 0xD17F5EFF ) ;
	SetPlayerProgressBarMaxValue(playerid, CharacterExpBar [ 0 ], 100 ) ;
	SetPlayerProgressBarValue(playerid, CharacterExpBar [ 0 ], 0) ;
	HidePlayerProgressBar ( playerid, CharacterExpBar [ 0 ]  ) ;

	CharacterExpBar [ 1 ] = CreatePlayerProgressBar(playerid, 211.5 + CHAR_INCR_HORIZONTAL, 280, 55.5, 6, 0xD17F5EFF ) ;
	SetPlayerProgressBarMaxValue(playerid, CharacterExpBar [ 1 ], 100 ) ;
	SetPlayerProgressBarValue(playerid, CharacterExpBar [ 1 ], 0 ) ;
	HidePlayerProgressBar ( playerid, CharacterExpBar [ 1 ]  ) ;

	CharacterExpBar [ 2 ] = CreatePlayerProgressBar(playerid, 211.5 + CHAR_INCR_HORIZONTAL * 2.25, 280, 55.5, 6, 0xD17F5EFF ) ;
	SetPlayerProgressBarMaxValue(playerid, CharacterExpBar [ 2 ], 100 ) ;
	SetPlayerProgressBarValue(playerid, CharacterExpBar [ 2 ], 0 ) ;
	HidePlayerProgressBar ( playerid, CharacterExpBar [ 2 ] ) ;

	////////////////////////////////////////////////////////////////////////////

	CharacterSel_ExpInfo [ 0 ] = CreatePlayerTextDraw(playerid, 228 - CHAR_INCR_FIX, 279.5,  "0/0");
	PlayerTextDrawLetterSize(playerid, CharacterSel_ExpInfo [ 0 ], 0.2, 0.75);
	PlayerTextDrawColor(playerid, CharacterSel_ExpInfo [ 0 ], -1);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_ExpInfo [ 0 ], 51);
	PlayerTextDrawSetOutline(playerid, CharacterSel_ExpInfo [ 0 ], 1);

	CharacterSel_ExpInfo [ 1 ] = CreatePlayerTextDraw(playerid, 228 + CHAR_INCR_HORIZONTAL, 279.5, "0/0");
	PlayerTextDrawLetterSize(playerid, CharacterSel_ExpInfo [ 1 ], 0.2, 0.75);
	PlayerTextDrawColor(playerid, CharacterSel_ExpInfo [ 1 ], -1);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_ExpInfo [ 1 ], 51);
	PlayerTextDrawSetOutline(playerid, CharacterSel_ExpInfo [ 1 ], 1);

	CharacterSel_ExpInfo [ 2 ] = CreatePlayerTextDraw(playerid, 228 + CHAR_INCR_HORIZONTAL * 2.25, 279.5,  "0/0");
	PlayerTextDrawLetterSize(playerid, CharacterSel_ExpInfo [ 2 ], 0.2, 0.75);
	PlayerTextDrawColor(playerid, CharacterSel_ExpInfo [ 2 ], -1);
	PlayerTextDrawBackgroundColor(playerid, CharacterSel_ExpInfo [ 2 ], 51);
	PlayerTextDrawSetOutline(playerid, CharacterSel_ExpInfo [ 2 ], 1);

	return true ;
}

HideCharacterSelectDraws(playerid) {

	for(new i = 0; i<3; i++) {

		PlayerTextDrawHide(playerid,CharacterSel_Name[i]);
		PlayerTextDrawHide(playerid,CharacterSel_SkinBox[i]);
		PlayerTextDrawHide(playerid,CharacterSel_HoursText[i]);
		PlayerTextDrawHide(playerid,CharacterSel_PosseText[i]);
		PlayerTextDrawHide(playerid,CharacterSel_ExpText[i]);
		PlayerTextDrawHide(playerid,CharacterSel_ExpInfo[i]);

		HidePlayerProgressBar(playerid,CharacterExpBar[i]) ;
	}
	return true;
}

public OnPlayerClickTextDraw ( playerid, Text:clickedid ) {

	if ( Login_SelectionPage [ playerid ] ) {
		if ( Text:INVALID_TEXT_DRAW == clickedid  ) {

			SelectTextDraw(playerid, 0xA3A3A3FF ) ;
		}

	    if ( clickedid == CharacterEmpty_Button [ 0 ] ||  clickedid == CharacterEmpty_Button [ 1 ] ||  clickedid == CharacterEmpty_Button [ 2 ] ) {

			//SendClientMessage(playerid, -1, "clicked");

	    	HideCharacterTextDraws ( playerid ) ;
	    	PromptCharacterCreation ( playerid ) ;
		}

		else {

			for ( new i; i < MAX_CHARACTER_BOX; i ++ ) {

				if ( clickedid == CharacterSelButton_Text [ i ] ) {

					if ( i <= MAX_CHARACTER_BOX ) {
						Account_LoadCharacterData ( playerid, i ) ;
					}

					else Account_LoadCharacterData ( playerid, 2 ) ;

					for(new j=0; j<5; j++) { HideCharacterTextDraws(playerid); }
					break;
				}

				else continue ;
			}

			return true ;
		}
	}

	#if defined sel_OnPlayerClickTextDraw
		return sel_OnPlayerClickTextDraw( playerid, Text:clickedid );
	#else
		return 1;
	#endif
}

#if defined _ALS_OnPlayerClickTextDraw
	#undef OnPlayerClickTextDraw
#else
	#define _ALS_OnPlayerClickTextDraw
#endif

#define OnPlayerClickTextDraw sel_OnPlayerClickTextDraw
#if defined sel_OnPlayerClickTextDraw
	forward sel_OnPlayerClickTextDraw( playerid, Text:clickedid ) ;
#endif