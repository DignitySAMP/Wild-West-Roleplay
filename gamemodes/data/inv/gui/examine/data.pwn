#if defined _inc_data
	#undef _inc_data
#endif

#define INV_ADJUST_VERTICAL_EXAMINE     ( 215 )

new PlayerText: inventory_examine_ptds [ 3 ] = PlayerText: INVALID_TEXT_DRAW ;
new Text: inventory_examine_tds [ 9 ] = Text: INVALID_TEXT_DRAW ;

new PlayerExaminingItem [ MAX_PLAYERS ] ;
new PlayerExaminingItemTile [ MAX_PLAYERS ] ;

HideInventoryExamineGUI ( playerid ) {
    for ( new i; i < sizeof ( inventory_examine_tds ); i ++ ) {

    	TextDrawHideForPlayer(playerid, inventory_examine_tds [ i ] ) ;
    }

	for ( new i; i < sizeof ( inventory_examine_ptds ); i ++ ) {

		PlayerTextDrawHide ( playerid, inventory_examine_ptds [ i ] ) ;
	}

	PlayerExaminingItem [ playerid ] = INVALID_ITEM_ID ;

	return true ;
}
LoadStaticInventoryExamineGUI ( ) {

	////////////////////////////////////////////////////////////////////////////
	///////////////////////////// Tile Inside Start ////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	inventory_examine_tds [ 0 ]= TextDrawCreate ( 516.666687 - INV_ADJUST_BOX, 164.107406 + INV_ADJUST_VERTICAL_EXAMINE, "usebox" ) ;
	TextDrawLetterSize ( inventory_examine_tds [ 0 ], 0.000000, 7.3 ) ;
	TextDrawTextSize ( inventory_examine_tds [ 0 ], 575.5 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	TextDrawUseBox ( inventory_examine_tds [ 0 ], true ) ;
	TextDrawBoxColor ( inventory_examine_tds [ 0 ], INVENTORY_BACKG_COLOR  ) ;

	inventory_examine_tds [ 1 ]= TextDrawCreate ( 522.5 - INV_ADJUST_MODEL, 167 + INV_ADJUST_VERTICAL_EXAMINE, "Item Name:" ) ;
	TextDrawLetterSize ( inventory_examine_tds [ 1 ], 0.20, 0.8 ) ;
	TextDrawColor ( inventory_examine_tds [ 1 ], INVENTORY_TILE_COLOR ) ;
	TextDrawFont ( inventory_examine_tds [ 1 ], 2 ) ;
	TextDrawBackgroundColor( inventory_examine_tds [ 1 ], 51);

	inventory_examine_tds [ 2 ]= TextDrawCreate ( 522.5 - INV_ADJUST_MODEL, 195 + INV_ADJUST_VERTICAL_EXAMINE, "Item Quantity:" ) ;
	TextDrawLetterSize ( inventory_examine_tds [ 2 ], 0.20, 0.8 ) ;
	TextDrawColor ( inventory_examine_tds [ 2 ], INVENTORY_TILE_COLOR ) ;
	TextDrawFont ( inventory_examine_tds [ 2 ], 2 ) ;
	TextDrawBackgroundColor( inventory_examine_tds [ 2 ], 51);

	inventory_examine_tds [ 3 ]= TextDrawCreate ( 518 - INV_ADJUST_BOX, 217 + INV_ADJUST_VERTICAL_EXAMINE, "usebox" ) ;
	TextDrawLetterSize ( inventory_examine_tds [ 3 ], 0.000000, 1.25 ) ;
	TextDrawTextSize ( inventory_examine_tds [ 3 ], 470 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	TextDrawUseBox ( inventory_examine_tds [ 3 ], true ) ;
	TextDrawBoxColor ( inventory_examine_tds [ 3 ], 0x40404077  ) ;

	inventory_examine_tds [ 4 ]= TextDrawCreate ( 570 - INV_ADJUST_BOX, 217 + INV_ADJUST_VERTICAL_EXAMINE, "usebox" ) ;
	TextDrawLetterSize ( inventory_examine_tds [ 4 ], 0.000000, 1.25 ) ;
	TextDrawTextSize ( inventory_examine_tds [ 4 ], 522 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	TextDrawUseBox ( inventory_examine_tds [ 4 ], true ) ;
	TextDrawBoxColor ( inventory_examine_tds [ 4 ], 0x40404077  ) ;

	inventory_examine_tds [ 5 ]= TextDrawCreate ( 621.7 - INV_ADJUST_BOX, 217 + INV_ADJUST_VERTICAL_EXAMINE, "usebox" ) ;
	TextDrawLetterSize ( inventory_examine_tds [ 5 ], 0.000000, 1.25 ) ;
	TextDrawTextSize ( inventory_examine_tds [ 5 ], 573.7 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	TextDrawUseBox ( inventory_examine_tds [ 5 ], true ) ;
	TextDrawBoxColor ( inventory_examine_tds [ 5 ], 0x40404077 ) ;

	inventory_examine_tds [ 6 ] = TextDrawCreate ( 475 - INV_ADJUST_MODEL, 218 + INV_ADJUST_VERTICAL_EXAMINE, "Use" ) ;
	TextDrawTextSize ( inventory_examine_tds [ 6 ], 460, 10 ) ;
	TextDrawLetterSize ( inventory_examine_tds [ 6 ], 0.20, 0.8 ) ;
	TextDrawColor ( inventory_examine_tds [ 6 ], INVENTORY_TILE_COLOR ) ;
	TextDrawFont ( inventory_examine_tds [ 6 ], 2 ) ;
	TextDrawBackgroundColor( inventory_examine_tds [ 6 ], 51);
	TextDrawSetSelectable ( inventory_examine_tds [ 6 ], true ) ;

	inventory_examine_tds [ 7 ] = TextDrawCreate ( 524 - INV_ADJUST_MODEL, 218 + INV_ADJUST_VERTICAL_EXAMINE, "Options" ) ;
	TextDrawTextSize ( inventory_examine_tds [ 7 ], 510, 10 ) ;
	TextDrawLetterSize ( inventory_examine_tds [ 7 ], 0.20, 0.8 ) ;
	TextDrawColor ( inventory_examine_tds [ 7 ], INVENTORY_TILE_COLOR ) ;
	TextDrawFont ( inventory_examine_tds [ 7 ], 2 ) ;
	TextDrawBackgroundColor( inventory_examine_tds [ 7 ], 51);
	TextDrawSetSelectable ( inventory_examine_tds [ 7 ], true ) ;

	inventory_examine_tds [ 8 ] = TextDrawCreate ( 577 - INV_ADJUST_MODEL, 218 + INV_ADJUST_VERTICAL_EXAMINE, "Drop" ) ;
	TextDrawTextSize ( inventory_examine_tds [ 8 ], 560, 10 ) ;
	TextDrawLetterSize ( inventory_examine_tds [ 8 ], 0.20, 0.8 ) ;
	TextDrawColor ( inventory_examine_tds [ 8 ], INVENTORY_TILE_COLOR ) ;
	TextDrawFont ( inventory_examine_tds [ 8 ], 2 ) ;
	TextDrawBackgroundColor( inventory_examine_tds [ 8 ], 51);
	TextDrawSetSelectable ( inventory_examine_tds [ 8 ], true ) ;

	return true ;
}

LoadPlayerInventoryExamineGUI ( playerid ) {

	inventory_examine_ptds [ 0 ] = CreatePlayerTextDraw ( playerid, 469 - INV_ADJUST_MODEL, 164 + INV_ADJUST_VERTICAL_EXAMINE, "usebox" ) ;
 	PlayerTextDrawFont(playerid, inventory_examine_ptds [ 0 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, inventory_examine_ptds [ 0 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_examine_ptds [ 0 ], 50.0, 50.0 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_examine_ptds [ 0 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, inventory_examine_ptds [ 0 ], 0xD17F5E55  ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_examine_ptds [ 0 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, inventory_examine_ptds [ 0 ], 18631 );

	inventory_examine_ptds [ 1 ] = CreatePlayerTextDraw ( playerid,  522.5 - INV_ADJUST_MODEL, 175 + INV_ADJUST_VERTICAL_EXAMINE, "insert item name here~n~insert item two" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_examine_ptds [ 1 ], 0.19, 1 ) ;
	PlayerTextDrawColor ( playerid, inventory_examine_ptds [ 1 ], 0xDEDEDEFF ) ;
	PlayerTextDrawFont ( playerid, inventory_examine_ptds [ 1 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, inventory_examine_ptds [ 1 ], 51);

	inventory_examine_ptds [ 2 ]  = CreatePlayerTextDraw ( playerid,  522.5 - INV_ADJUST_MODEL, 202 + INV_ADJUST_VERTICAL_EXAMINE, "1000" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_examine_ptds [ 2 ] , 0.19, 1 ) ;
	PlayerTextDrawColor ( playerid, inventory_examine_ptds [ 2 ] , 0xDEDEDEFF ) ;
	PlayerTextDrawFont ( playerid, inventory_examine_ptds [ 2 ] , 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, inventory_examine_ptds [ 2 ] , 51);

	return true ;
}