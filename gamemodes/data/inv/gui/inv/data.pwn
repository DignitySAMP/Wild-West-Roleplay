#if defined _inc_data
	#undef _inc_data
#endif

new Text: inventory_static_gui [ 6 ] = Text: INVALID_TEXT_DRAW ;

new PlayerText: InventoryTileOutline  	[ INV_MAX_TILES ] = PlayerText: INVALID_TEXT_DRAW ;
new PlayerText: InventoryTile  			[ INV_MAX_TILES ] = PlayerText: INVALID_TEXT_DRAW ;
new PlayerText: InventoryTileName  		[ INV_MAX_TILES ] = PlayerText: INVALID_TEXT_DRAW ;
new PlayerText: InventoryTileModel  	[ INV_MAX_TILES ] = PlayerText: INVALID_TEXT_DRAW ;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define INV_LIST_JUMP_HORIZONTAL       	(55)
#define INV_LIST_JUMP_VERTICAL       	(55)

#define INV_ADJUST_HORIZONTAL      		( 105 + 2 )
#define INV_ADJUST_HORIZONTAL_TEXT  	( 5 + 2 )

#define INV_ADJUST_BOX     				( 103 + 2 )
#define INV_ADJUST_BOX_TEXT     		( 7 + 2)

#define INV_ADJUST_MODEL                ( 55 + 2)
#define INV_ADJUST_VERTICAL             ( 32.5 )

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

LoadStaticInventoryTextDraws ( ) {
	inventory_static_gui [ 0 ]= TextDrawCreate ( 408, 135 + INV_ADJUST_VERTICAL, "background" ) ;
	TextDrawLetterSize ( inventory_static_gui [ 0 ], 0.000000, 23 ) ;
	TextDrawTextSize ( inventory_static_gui [ 0 ], 571, 0.000000 ) ;
	TextDrawUseBox ( inventory_static_gui [ 0 ], true ) ;
	TextDrawBoxColor ( inventory_static_gui [ 0 ], INVENTORY_BACKG_COLOR) ;

	inventory_static_gui [ 1 ] = TextDrawCreate ( 409, 140.5 + INV_ADJUST_VERTICAL, "Provisions" ) ;
	TextDrawLetterSize ( inventory_static_gui [ 1 ], 0.333333, 1.4 ) ;
	TextDrawColor ( inventory_static_gui [ 1 ], INVENTORY_TILE_COLOR   ) ;
	TextDrawFont ( inventory_static_gui [ 1 ], 2 ) ;
	TextDrawBackgroundColor( inventory_static_gui [ 1 ], 51);

	inventory_static_gui [ 2 ] = TextDrawCreate ( 493, 140.5 + INV_ADJUST_VERTICAL, "Inventory" ) ;
	TextDrawLetterSize ( inventory_static_gui [ 2 ], 0.333666, 1.4 ) ;
	TextDrawColor ( inventory_static_gui [ 2 ], -1 ) ;
	TextDrawFont ( inventory_static_gui [ 2 ], 2 ) ;
	TextDrawBackgroundColor( inventory_static_gui [ 2 ], 51);

	inventory_static_gui [ 3 ]= TextDrawCreate ( 452, 325 + INV_ADJUST_VERTICAL, "Inventory" ) ;
	TextDrawLetterSize ( inventory_static_gui [ 3 ], 0.333666, 1.4 ) ;
	TextDrawColor ( inventory_static_gui [ 3 ], INVENTORY_TILE_COLOR ) ;
	TextDrawFont ( inventory_static_gui [ 3 ], 2 ) ;
	TextDrawBackgroundColor( inventory_static_gui [ 3 ], 51);

	inventory_static_gui [ 4 ] = TextDrawCreate ( 555, 325 + INV_ADJUST_VERTICAL, "LD_BEAT:right" ) ;
	TextDrawTextSize ( inventory_static_gui [ 4 ], 15, 15 ) ;
	TextDrawColor ( inventory_static_gui [ 4 ], INVENTORY_BACKG_COLOR ) ;
	TextDrawFont ( inventory_static_gui [ 4 ], 4 ) ;
	TextDrawBackgroundColor( inventory_static_gui [ 4 ], 51);
	TextDrawSetSelectable( inventory_static_gui [ 4 ], true);
	
	inventory_static_gui [ 5 ] = TextDrawCreate ( 408.5, 325 + INV_ADJUST_VERTICAL, "LD_BEAT:left" ) ;
	TextDrawTextSize ( inventory_static_gui [ 5 ], 15, 15 ) ;
	TextDrawColor ( inventory_static_gui [ 5 ], INVENTORY_BACKG_COLOR ) ;
	TextDrawFont ( inventory_static_gui [ 5 ], 4 ) ;
	TextDrawBackgroundColor( inventory_static_gui [ 5 ], 51);
	TextDrawSetSelectable( inventory_static_gui [ 5 ], true);

    // GivePlayerItems ( playerid ) ;
// 	InitiateInventoryTiles ( playerid, 0 ) ;

	return true;
}

LoadInventoryTextDraws ( playerid ) {

	////////////////////////////////////////////////////////////////////////////
	///////////////////////////// Tile Inside Start ////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	InventoryTileOutline  [ 0 ] = CreatePlayerTextDraw ( playerid, 517.666839 - INV_ADJUST_HORIZONTAL, 162.862945 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileOutline  [ 0 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileOutline  [ 0 ], 465.000122 - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileOutline  [ 0 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileOutline  [ 0 ], INVENTORY_TILE_COLOR  ) ;

	InventoryTileOutline  [ 1 ] = CreatePlayerTextDraw ( playerid, 517.666839 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_HORIZONTAL, 162.862945 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileOutline  [ 1 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileOutline  [ 1 ], 465.000122 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileOutline  [ 1 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileOutline  [ 1 ], INVENTORY_TILE_COLOR  ) ;

	InventoryTileOutline  [ 2 ] = CreatePlayerTextDraw ( playerid, 517.666839 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_HORIZONTAL , 162.862945 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileOutline  [ 2 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileOutline  [ 2 ], 465.000122 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileOutline  [ 2 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileOutline  [ 2 ], INVENTORY_TILE_COLOR  ) ;

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	InventoryTileOutline  [ 3 ] = CreatePlayerTextDraw ( playerid, 517.666839 - INV_ADJUST_HORIZONTAL, 162.862945 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileOutline  [ 3 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileOutline  [ 3 ], 465.000122 - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileOutline  [ 3 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileOutline  [ 3 ], INVENTORY_TILE_COLOR  ) ;

	InventoryTileOutline  [ 4 ] = CreatePlayerTextDraw ( playerid, 517.666839 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_HORIZONTAL, 162.862945 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileOutline  [ 4 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileOutline  [ 4 ], 465.000122 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileOutline  [ 4 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileOutline  [ 4 ], INVENTORY_TILE_COLOR  ) ;

	InventoryTileOutline  [ 5 ] = CreatePlayerTextDraw ( playerid, 517.666839 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_HORIZONTAL, 162.862945 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileOutline  [ 5 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileOutline  [ 5 ], 465.000122 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileOutline  [ 5 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileOutline  [ 5 ], INVENTORY_TILE_COLOR  ) ;

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	InventoryTileOutline  [ 6 ] = CreatePlayerTextDraw ( playerid, 517.666839 - INV_ADJUST_HORIZONTAL, 162.862945 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileOutline  [ 6 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileOutline  [ 6 ], 465.000122 - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileOutline  [ 6 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileOutline  [ 6 ], INVENTORY_TILE_COLOR  ) ;

	InventoryTileOutline  [ 7 ] = CreatePlayerTextDraw ( playerid, 517.666839 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_HORIZONTAL, 162.862945 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileOutline  [ 7 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileOutline  [ 7 ], 465.000122 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileOutline  [ 7 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileOutline  [ 7 ], INVENTORY_TILE_COLOR  ) ;

	InventoryTileOutline  [ 8 ] = CreatePlayerTextDraw ( playerid, 517.666839 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_HORIZONTAL, 162.862945 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileOutline  [ 8 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileOutline  [ 8 ], 465.000122 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileOutline  [ 8 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileOutline  [ 8 ], INVENTORY_TILE_COLOR  ) ;

	////////////////////////////////////////////////////////////////////////////
	//////////////////////////// Tile Outline Start ////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	InventoryTile  [ 0 ] = CreatePlayerTextDraw ( playerid, 516.666687 - INV_ADJUST_BOX, 164.107406 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTile  [ 0 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTile  [ 0 ], 465.666656 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTile  [ 0 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTile  [ 0 ], INVENTORY_TILE_BG_COLOR  ) ;

	InventoryTile  [ 1 ] = CreatePlayerTextDraw ( playerid, 516.666687 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_BOX, 164.107406 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTile  [ 1 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTile  [ 1 ], 465.666656 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTile  [ 1 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTile  [ 1 ], INVENTORY_TILE_BG_COLOR  ) ;

	InventoryTile  [ 2 ] = CreatePlayerTextDraw ( playerid, 516.666687 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_BOX, 164.107406 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTile  [ 2 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTile  [ 2 ], 465.666656 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTile  [ 2 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTile  [ 2 ], INVENTORY_TILE_BG_COLOR  ) ;

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	InventoryTile  [ 3 ] = CreatePlayerTextDraw ( playerid, 516.666687 - INV_ADJUST_BOX, 164.107406 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTile  [ 3 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTile  [ 3 ], 465.666656 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTile  [ 3 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTile  [ 3 ], INVENTORY_TILE_BG_COLOR  ) ;

	InventoryTile  [ 4 ] = CreatePlayerTextDraw ( playerid, 516.666687 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_BOX, 164.107406 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTile  [ 4 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTile  [ 4 ], 465.666656 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTile  [ 4 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTile  [ 4 ], INVENTORY_TILE_BG_COLOR  ) ;

	InventoryTile  [ 5 ] = CreatePlayerTextDraw ( playerid, 516.666687 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_BOX, 164.107406 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTile  [ 5 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTile  [ 5 ], 465.666656 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTile  [ 5 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTile  [ 5 ], INVENTORY_TILE_BG_COLOR  ) ;

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	InventoryTile  [ 6 ] = CreatePlayerTextDraw ( playerid, 516.666687 - INV_ADJUST_BOX, 164.107406 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTile  [ 6 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTile  [ 6 ], 465.666656 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTile  [ 6 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTile  [ 6 ], INVENTORY_TILE_BG_COLOR  ) ;

	InventoryTile  [ 7 ] = CreatePlayerTextDraw ( playerid, 516.666687 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_BOX, 164.107406 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTile  [ 7 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTile  [ 7 ], 465.666656 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTile  [ 7 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTile  [ 7 ], INVENTORY_TILE_BG_COLOR  ) ;

	InventoryTile  [ 8 ] = CreatePlayerTextDraw ( playerid, 516.666687 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_BOX, 164.107406 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTile  [ 8 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTile  [ 8 ], 465.666656 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTile  [ 8 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTile  [ 8 ], INVENTORY_TILE_BG_COLOR  ) ;

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////// Tile Model Start ////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	InventoryTileModel  [ 0 ] = CreatePlayerTextDraw ( playerid, 469 - INV_ADJUST_MODEL, 164 + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, InventoryTileModel  [ 0 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, InventoryTileModel  [ 0 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileModel  [ 0 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileModel  [ 0 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, InventoryTileModel  [ 0 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileModel  [ 0 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, InventoryTileModel  [ 0 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, InventoryTileModel  [ 0 ], true );

	InventoryTileModel  [ 1 ] = CreatePlayerTextDraw ( playerid, 469 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_MODEL, 164 + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, InventoryTileModel  [ 1 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, InventoryTileModel  [ 1 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileModel  [ 1 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileModel  [ 1 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, InventoryTileModel  [ 1 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileModel  [ 1 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, InventoryTileModel  [ 1 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, InventoryTileModel  [ 1 ], true );

	InventoryTileModel  [ 2 ] = CreatePlayerTextDraw ( playerid, 469 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_MODEL, 164 + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, InventoryTileModel  [ 2 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, InventoryTileModel  [ 2 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileModel  [ 2 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileModel  [ 2 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, InventoryTileModel  [ 2 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileModel  [ 2 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, InventoryTileModel  [ 2 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, InventoryTileModel  [ 2 ], true );

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	InventoryTileModel  [ 3 ] = CreatePlayerTextDraw ( playerid, 469 - INV_ADJUST_MODEL, 164 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, InventoryTileModel  [ 3 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, InventoryTileModel  [ 3 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileModel  [ 3 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileModel  [ 3 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, InventoryTileModel  [ 3 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileModel  [ 3 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, InventoryTileModel  [ 3 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, InventoryTileModel  [ 3 ], true );

	InventoryTileModel  [ 4 ] = CreatePlayerTextDraw ( playerid, 469 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_MODEL, 164 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, InventoryTileModel  [ 4 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, InventoryTileModel  [ 4 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileModel  [ 4 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileModel  [ 4 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, InventoryTileModel  [ 4 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileModel  [ 4 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, InventoryTileModel  [ 4 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, InventoryTileModel  [ 4 ], true );

	InventoryTileModel  [ 5 ] = CreatePlayerTextDraw ( playerid, 469 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_MODEL, 164 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, InventoryTileModel  [ 5 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, InventoryTileModel  [ 5 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileModel  [ 5 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileModel  [ 5 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, InventoryTileModel  [ 5 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileModel  [ 5 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, InventoryTileModel  [ 5 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, InventoryTileModel  [ 5 ], true );

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	InventoryTileModel  [ 6 ] = CreatePlayerTextDraw ( playerid, 469 - INV_ADJUST_MODEL, 164 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, InventoryTileModel  [ 6 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, InventoryTileModel  [ 6 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileModel  [ 6 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileModel  [ 6 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, InventoryTileModel  [ 6 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileModel  [ 6 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, InventoryTileModel  [ 6 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, InventoryTileModel  [ 6 ], true );

	InventoryTileModel  [ 7 ] = CreatePlayerTextDraw ( playerid, 469 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_MODEL, 164 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, InventoryTileModel  [ 7 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, InventoryTileModel  [ 7 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileModel  [ 7 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileModel  [ 7 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, InventoryTileModel  [ 7 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileModel  [ 7 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, InventoryTileModel  [ 7 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, InventoryTileModel  [ 7 ], true );

	InventoryTileModel  [ 8 ] = CreatePlayerTextDraw ( playerid, 469 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_MODEL, 164 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, InventoryTileModel  [ 8 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, InventoryTileModel  [ 8 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, InventoryTileModel  [ 8 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, InventoryTileModel  [ 8 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, InventoryTileModel  [ 8 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, InventoryTileModel  [ 8 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, InventoryTileModel  [ 8 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, InventoryTileModel  [ 8 ], true );

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////// Tile Name Start /////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	new NAME_VAR  = 475 ;
	InventoryTileName  [ 0 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR - INV_ADJUST_MODEL, 200 + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileName  [ 0 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, InventoryTileName  [ 0 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, InventoryTileName  [ 0 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, InventoryTileName  [ 0 ], 51);

	InventoryTileName  [ 1 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_MODEL, 200 + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileName  [ 1 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, InventoryTileName  [ 1 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, InventoryTileName  [ 1 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, InventoryTileName  [ 1 ], 51);

	InventoryTileName  [ 2 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_MODEL, 200 + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileName  [ 2 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, InventoryTileName  [ 2 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, InventoryTileName  [ 2 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, InventoryTileName  [ 2 ], 51);

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	InventoryTileName  [ 3 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR - INV_ADJUST_MODEL, 200 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileName  [ 3 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, InventoryTileName  [ 3 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, InventoryTileName  [ 3 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, InventoryTileName  [ 3 ], 51);

	InventoryTileName  [ 4 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_MODEL, 200 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileName  [ 4 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, InventoryTileName  [ 4 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, InventoryTileName  [ 4 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, InventoryTileName  [ 4 ], 51);

	InventoryTileName  [ 5 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_MODEL, 200 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileName  [ 5 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, InventoryTileName  [ 5 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, InventoryTileName  [ 5 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, InventoryTileName  [ 5 ], 51);

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	InventoryTileName  [ 6 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR - INV_ADJUST_MODEL, 200 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileName  [ 6 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, InventoryTileName  [ 6 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, InventoryTileName  [ 6 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, InventoryTileName  [ 6 ], 51);

	InventoryTileName  [ 7 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_MODEL, 200 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileName  [ 7 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, InventoryTileName  [ 7 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, InventoryTileName  [ 7 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, InventoryTileName  [ 7 ], 51);

	InventoryTileName  [ 8 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_MODEL, 200 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, InventoryTileName  [ 8 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, InventoryTileName  [ 8 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, InventoryTileName  [ 8 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, InventoryTileName  [ 8 ], 51);

	return true ;
}