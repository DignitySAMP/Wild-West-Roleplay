new Text: actionGUI_static [ 6 ] = Text: INVALID_TEXT_DRAW ;
new PlayerText: actionGUI_player [ 4 ] = PlayerText: INVALID_TEXT_DRAW ;
new PlayerBar: actionGUI_bar = PlayerBar: INVALID_PLAYER_BAR_ID ;

#define GUI_AVG_COLOR		(0x111111FF)
#define GUI_LINE_COLOR		(0xD17F5EFF)
#define GUI_BOX_COLOR		(0x40404077)

#define BOX_HORIZ_INCR			( 25 )
#define BOX_SIZE_HORIZ_INCR		( 40 )

enum {

	ACTION_TYPE_CATTLE,
	ACTION_TYPE_DEER,
	ACTION_TYPE_FISH,
	ACTION_TYPE_MINING,
	ACTION_TYPE_LUMBER,
	ACTION_TYPE_GUN
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

randomEx(minnum = cellmin, maxnum = cellmax) {

	return random(maxnum - minnum + 1) + minnum;
} 

ActionPanel_ChangeGUI(playerid, text[], previewmodel = -1, bool:show_bar = true ) {


	PlayerTextDrawHide ( playerid, actionGUI_player [ 1 ] ) ;
	PlayerTextDrawSetString(playerid, actionGUI_player [ 1 ], text ) ;		
	PlayerTextDrawShow ( playerid, actionGUI_player [ 1 ] ) ;

	if ( previewmodel != -1 ) {
		PlayerTextDrawHide ( playerid, actionGUI_player [ 3 ] ) ;
		PlayerTextDrawSetPreviewModel ( playerid, actionGUI_player [ 3 ], previewmodel ) ;
		PlayerTextDrawShow ( playerid, actionGUI_player [ 3 ] ) ;
	}

	switch ( show_bar ) {

		case false : HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;
		case true: {

			HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;
			ShowPlayerProgressBar ( playerid, actionGUI_bar  ) ;
		}
	}

}

new ViewingActionGUI [ MAX_PLAYERS ] ;
SetupActionGUI ( playerid, actiontype ) {

	HideActionGUI ( playerid ) ;
	HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;

	ViewingActionGUI [ playerid ] = actiontype ;

	switch ( actiontype ) {

		case ACTION_TYPE_CATTLE: {
			PlayerTextDrawSetString ( playerid, actionGUI_player [ 0 ] , "Action Panel: Cattle Milking") ;

			PlayerTextDrawSetPreviewModel ( playerid, actionGUI_player [ 3 ]  , 19833 ) ;
			PlayerTextDrawSetPreviewRot(playerid, actionGUI_player [ 3 ]  , 0.0, 0.0, 140.0, 1.0);

			PlayerTextDrawSetString(playerid, actionGUI_player [ 1 ] , "not initialised") ;

		}

		case ACTION_TYPE_DEER: {
			PlayerTextDrawSetString ( playerid, actionGUI_player [ 0 ] , "Action Panel: Hunting") ;

			PlayerTextDrawSetPreviewModel ( playerid, actionGUI_player [ 3 ]  , 19315 ) ;
			PlayerTextDrawSetPreviewRot(playerid, actionGUI_player [ 3 ]  , 0.0, 0.0, 40.0, 1.0);

			PlayerTextDrawSetString(playerid, actionGUI_player [ 1 ] , "| Managed to skin 0 cow hide~n~| Managed to skin 0 cow meat~n~~n~~w~ + 0 exp for Hunting Level!") ;		
		}

		case ACTION_TYPE_FISH: {
			PlayerTextDrawSetString ( playerid, actionGUI_player [ 0 ] , "Action Panel: Fishing") ;

			PlayerTextDrawSetPreviewModel ( playerid, actionGUI_player [ 3 ]  , 1603 ) ;
			PlayerTextDrawSetPreviewRot(playerid, actionGUI_player [ 3 ]  , 0.0, 0.0, 40.0, 1.0);

			PlayerTextDrawSetString(playerid, actionGUI_player [ 1 ] , "@ Rapidly press ~k~~PED_LOCK_TARGET~ to reel in your catch.~n~Press ~k~~PED_FIREWEAPON~ to cancel action.") ;
		}

		case ACTION_TYPE_MINING: {
			PlayerTextDrawSetString ( playerid, actionGUI_player [ 0 ] , "Action Panel: Mining") ;

			PlayerTextDrawSetPreviewModel ( playerid, actionGUI_player [ 3 ]  , 747 ) ;
			PlayerTextDrawSetPreviewRot(playerid, actionGUI_player [ 3 ]  , 0.0, 0.0, 40.0, 1.0);

			PlayerTextDrawSetString(playerid, actionGUI_player [ 1 ] , "@ Rapidly press  ~k~~PED_LOCK_TARGET~ to mine the rock.~n~Press ~k~~PED_FIREWEAPON~ to cancel action.") ;
		}
		case ACTION_TYPE_LUMBER: {
			PlayerTextDrawSetString ( playerid, actionGUI_player [ 0 ] , "Action Panel: Woodcutting") ;

			PlayerTextDrawSetPreviewModel ( playerid, actionGUI_player [ 3 ]  , 747 ) ;
			PlayerTextDrawSetPreviewRot(playerid, actionGUI_player [ 3 ]  , 0.0, 0.0, 40.0, 1.0);

			PlayerTextDrawSetString(playerid, actionGUI_player [ 1 ] , "@ Rapidly press  ~k~~PED_LOCK_TARGET~ to chop the tree.~n~Press ~k~~PED_FIREWEAPON~ to cancel action.") ;
		}

		case ACTION_TYPE_GUN: {

			PlayerTextDrawSetString ( playerid, actionGUI_player [ 0 ] , "Action Panel: Gun Creation") ;

			PlayerTextDrawSetPreviewModel ( playerid, actionGUI_player [ 3 ]  , 348 ) ;
			PlayerTextDrawSetPreviewRot(playerid, actionGUI_player [ 3 ]  , 0.0, 0.0, 40.0, 1.0);

			PlayerTextDrawSetString(playerid, actionGUI_player [ 1 ] , "@ Head to the point pickups and press LALT to do an activity.~n~Your goal is to keep the furnace burning.") ;

		}
	}

	ShowPlayerProgressBar ( playerid, actionGUI_bar  ) ;
	ShowActionGUI ( playerid ) ;

	return true ;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

ShowActionGUI ( playerid ) {	

	for ( new i, j = sizeof ( actionGUI_static ); i < j ; i ++ ) {

		TextDrawShowForPlayer ( playerid, actionGUI_static [ i ] ) ;
	}

	
	for ( new i, j = sizeof ( actionGUI_player ); i < j ; i ++ ) {

		PlayerTextDrawShow(playerid, actionGUI_player [ i ] ) ;
	}

	ShowPlayerProgressBar ( playerid, actionGUI_bar  ) ;

	return true ;
}

HideActionGUI ( playerid ) {


	for ( new i, j = sizeof ( actionGUI_static ); i < j ; i ++ ) {

		TextDrawHideForPlayer ( playerid, actionGUI_static [ i ] ) ;
	}

	
	for ( new i, j = sizeof ( actionGUI_player ); i < j ; i ++ ) {

		PlayerTextDrawHide(playerid, actionGUI_player [ i ] ) ;
	}

	HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;

	return true ;
}

DestroyPlayerActionGUI ( playerid ) {

	DestroyPlayerProgressBar ( playerid, actionGUI_bar  ) ;

	PlayerTextDrawDestroy ( playerid, actionGUI_player [ 0 ]  ) ;
	PlayerTextDrawDestroy ( playerid, actionGUI_player [ 1 ]  ) ;
	PlayerTextDrawDestroy ( playerid, actionGUI_player [ 3 ]   ) ;

	return true ;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

LoadActionGUITextDraws () {

	actionGUI_static [ 0 ] = TextDrawCreate ( 222.5 + BOX_HORIZ_INCR, 319, "box" ) ;
	TextDrawTextSize ( actionGUI_static [ 0 ], 472 - BOX_SIZE_HORIZ_INCR, 0 ) ;
	TextDrawLetterSize ( actionGUI_static [ 0 ], 0, 10.25 ) ;
	TextDrawUseBox ( actionGUI_static [ 0 ], true ) ;
	TextDrawBoxColor ( actionGUI_static [ 0 ],  GUI_AVG_COLOR ) ;

	actionGUI_static [ 1 ] = TextDrawCreate ( 224 + BOX_HORIZ_INCR, 321.25, "box" ) ;
	TextDrawTextSize ( actionGUI_static [ 1 ], 470.25 - BOX_SIZE_HORIZ_INCR, 0 ) ;
	TextDrawLetterSize ( actionGUI_static [ 1 ], 0, 9.80 ) ;
	TextDrawUseBox ( actionGUI_static [ 1 ], true ) ;
	TextDrawBoxColor ( actionGUI_static [ 1 ],  GUI_LINE_COLOR ) ;	

	actionGUI_static [ 2 ] = TextDrawCreate ( 225 + BOX_HORIZ_INCR, 322.5, "box" ) ;
	TextDrawTextSize ( actionGUI_static [ 2 ], 469.000000 - BOX_SIZE_HORIZ_INCR, 0 ) ;
	TextDrawLetterSize ( actionGUI_static [ 2 ], 0, 9.5 ) ;
	TextDrawUseBox ( actionGUI_static [ 2 ], true ) ;
	TextDrawBoxColor ( actionGUI_static [ 2 ],  GUI_AVG_COLOR ) ;

	/////////////////////////////////////////////////////////////////////////////////////

	actionGUI_static [ 3 ] = TextDrawCreate ( 285 + BOX_HORIZ_INCR, 366.5, "box" ) ;
	TextDrawTextSize ( actionGUI_static [ 3 ], 400 +  BOX_HORIZ_INCR, 0 ) ;
	TextDrawLetterSize ( actionGUI_static [ 3 ], 0, 4 ) ;
	TextDrawUseBox ( actionGUI_static [ 3 ], true ) ;
	TextDrawBoxColor ( actionGUI_static [ 3 ],  GUI_BOX_COLOR ) ;


	actionGUI_static [ 4 ] = TextDrawCreate ( 228 + BOX_HORIZ_INCR, 340, "box" ) ;
	TextDrawTextSize ( actionGUI_static [ 4 ], 280 + BOX_HORIZ_INCR, 0 ) ;
	TextDrawLetterSize ( actionGUI_static [ 4 ], 0, 7 ) ;
	TextDrawUseBox ( actionGUI_static [ 4 ], true ) ;
	TextDrawBoxColor ( actionGUI_static [ 4 ],  GUI_BOX_COLOR ) ;

	/////////////////////////////////////////////////////////////////////////////////////

	actionGUI_static [ 5 ] = TextDrawCreate ( 284 + BOX_HORIZ_INCR, 337.5, "Action bar: shows current action progress" ) ;
	TextDrawLetterSize ( actionGUI_static [ 5 ], 0.150000, 0.850000 ) ;
	TextDrawColor ( actionGUI_static [ 5 ], GUI_LINE_COLOR ) ;
	TextDrawBackgroundColor ( actionGUI_static [ 5 ], 51 ) ;
	TextDrawFont ( actionGUI_static [ 5 ], 1 ) ;

	return true ;
}

LoadPlayerActionTextDraws ( playerid ) {

	actionGUI_player [ 0 ]  = CreatePlayerTextDraw ( playerid, 226 + BOX_HORIZ_INCR, 320, "Action Panel" ) ;
	PlayerTextDrawLetterSize ( playerid, actionGUI_player [ 0 ] , 0.400000, 1.600000 ) ;
	PlayerTextDrawColor ( playerid, actionGUI_player [ 0 ] , GUI_LINE_COLOR ) ;
	PlayerTextDrawBackgroundColor ( playerid, actionGUI_player [ 0 ] , 51 ) ;
	PlayerTextDrawFont ( playerid, actionGUI_player [ 0 ] , 1 ) ;	

	actionGUI_player [ 1 ]  = CreatePlayerTextDraw ( playerid, 285 + BOX_HORIZ_INCR, 368, "| UNDEFINED" ) ;
	PlayerTextDrawLetterSize ( playerid, actionGUI_player [ 1 ] , 0.150000, 0.850000 ) ;
	PlayerTextDrawColor ( playerid, actionGUI_player [ 1 ] , GUI_LINE_COLOR ) ;
	PlayerTextDrawBackgroundColor ( playerid, actionGUI_player [ 1 ] , 51 ) ;
	PlayerTextDrawFont ( playerid, actionGUI_player [ 1 ] , 1 ) ;

	/////////////////////////////////////////////////////////////////////////////////////

	actionGUI_player [ 3 ]  = CreatePlayerTextDraw ( playerid, 227.5 + BOX_HORIZ_INCR, 340, "box" ) ;
	PlayerTextDrawTextSize ( playerid, actionGUI_player [ 3 ]  , 52.5, 62.5 ) ;
	PlayerTextDrawUseBox ( playerid, actionGUI_player [ 3 ]  , true ) ;
	PlayerTextDrawBoxColor ( playerid, actionGUI_player [ 3 ]  ,  GUI_BOX_COLOR ) ;
	PlayerTextDrawBackgroundColor(playerid,  actionGUI_player [ 3 ]  , 0x000000 ) ;
	PlayerTextDrawColor(playerid,  actionGUI_player [ 3 ]  , -1 ) ;
 	PlayerTextDrawFont(playerid, actionGUI_player [ 3 ] , TEXT_DRAW_FONT_MODEL_PREVIEW ) ;
	PlayerTextDrawSetPreviewModel(playerid, actionGUI_player [ 3 ] , 18631);

	/////////////////////////////////////////////////////////////////////////////////////

	actionGUI_bar  = CreatePlayerProgressBar ( playerid, 285.0 + BOX_HORIZ_INCR, 350.0, 120, 11, GUI_LINE_COLOR, 100.0 ) ;
	HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;

	return true ;
}