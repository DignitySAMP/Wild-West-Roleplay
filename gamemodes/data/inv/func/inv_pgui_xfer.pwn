new PlayerText: inventory_player_gui [ 36 ] = PlayerText: INVALID_TEXT_DRAW ;

LoadInventoryTextDraws ( playerid ) {

	////////////////////////////////////////////////////////////////////////////
	///////////////////////////// Tile Inside Start ////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	inventory_player_gui [ 0 ] = CreatePlayerTextDraw ( playerid, 517.666839 - INV_ADJUST_HORIZONTAL, 162.862945 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 0 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 0 ], 465.000122 - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 0 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 0 ], INVENTORY_TILE_COLOR  ) ;

	inventory_player_gui [ 1 ] = CreatePlayerTextDraw ( playerid, 517.666839 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_HORIZONTAL, 162.862945 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 1 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 1 ], 465.000122 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 1 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 1 ], INVENTORY_TILE_COLOR  ) ;

	inventory_player_gui [ 2 ] = CreatePlayerTextDraw ( playerid, 517.666839 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_HORIZONTAL , 162.862945 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 2 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 2 ], 465.000122 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 2 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 2 ], INVENTORY_TILE_COLOR  ) ;

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	inventory_player_gui [ 3 ] = CreatePlayerTextDraw ( playerid, 517.666839 - INV_ADJUST_HORIZONTAL, 162.862945 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 3 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 3 ], 465.000122 - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 3 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 3 ], INVENTORY_TILE_COLOR  ) ;

	inventory_player_gui [ 4 ] = CreatePlayerTextDraw ( playerid, 517.666839 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_HORIZONTAL, 162.862945 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 4 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 4 ], 465.000122 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 4 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 4 ], INVENTORY_TILE_COLOR  ) ;

	inventory_player_gui [ 5 ] = CreatePlayerTextDraw ( playerid, 517.666839 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_HORIZONTAL, 162.862945 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 5 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 5 ], 465.000122 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 5 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 5 ], INVENTORY_TILE_COLOR  ) ;

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	inventory_player_gui [ 6 ] = CreatePlayerTextDraw ( playerid, 517.666839 - INV_ADJUST_HORIZONTAL, 162.862945 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 6 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 6 ], 465.000122 - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 6 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 6 ], INVENTORY_TILE_COLOR  ) ;

	inventory_player_gui [ 7 ] = CreatePlayerTextDraw ( playerid, 517.666839 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_HORIZONTAL, 162.862945 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 7 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 7 ], 465.000122 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 7 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 7 ], INVENTORY_TILE_COLOR  ) ;

	inventory_player_gui [ 8 ] = CreatePlayerTextDraw ( playerid, 517.666839 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_HORIZONTAL, 162.862945 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 8 ], 0.000000, 5.257822 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 8 ], 465.000122 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_HORIZONTAL_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 8 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 8 ], INVENTORY_TILE_COLOR  ) ;

	////////////////////////////////////////////////////////////////////////////
	//////////////////////////// Tile Outline Start ////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	inventory_player_gui [ 9 ] = CreatePlayerTextDraw ( playerid, 516.666687 - INV_ADJUST_BOX, 164.107406 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 9 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 9 ], 465.666656 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 9 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 9 ], INVENTORY_TILE_BG_COLOR  ) ;

	inventory_player_gui [ 10 ] = CreatePlayerTextDraw ( playerid, 516.666687 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_BOX, 164.107406 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 10 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 10 ], 465.666656 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 10 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 10 ], INVENTORY_TILE_BG_COLOR  ) ;

	inventory_player_gui [ 11 ] = CreatePlayerTextDraw ( playerid, 516.666687 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_BOX, 164.107406 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 11 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 11 ], 465.666656 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 11 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 11 ], INVENTORY_TILE_BG_COLOR  ) ;

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	inventory_player_gui [ 12 ] = CreatePlayerTextDraw ( playerid, 516.666687 - INV_ADJUST_BOX, 164.107406 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 12 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 12 ], 465.666656 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 12 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 12 ], INVENTORY_TILE_BG_COLOR  ) ;

	inventory_player_gui [ 13 ] = CreatePlayerTextDraw ( playerid, 516.666687 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_BOX, 164.107406 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 13 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 13 ], 465.666656 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 13 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 13 ], INVENTORY_TILE_BG_COLOR  ) ;

	inventory_player_gui [ 14 ] = CreatePlayerTextDraw ( playerid, 516.666687 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_BOX, 164.107406 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 14 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 14 ], 465.666656 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 14 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 14 ], INVENTORY_TILE_BG_COLOR  ) ;

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	inventory_player_gui [ 15 ] = CreatePlayerTextDraw ( playerid, 516.666687 - INV_ADJUST_BOX, 164.107406 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 15 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 15 ], 465.666656 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 15 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 15 ], INVENTORY_TILE_BG_COLOR  ) ;

	inventory_player_gui [ 16 ] = CreatePlayerTextDraw ( playerid, 516.666687 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_BOX, 164.107406 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 16 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 16 ], 465.666656 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 16 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 16 ], INVENTORY_TILE_BG_COLOR  ) ;

	inventory_player_gui [ 17 ] = CreatePlayerTextDraw ( playerid, 516.666687 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_BOX, 164.107406 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 17 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 17 ], 465.666656 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_BOX_TEXT, 0.000000 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 17 ], true ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 17 ], INVENTORY_TILE_BG_COLOR  ) ;

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////// Tile Model Start ////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	inventory_player_gui [ 18 ] = CreatePlayerTextDraw ( playerid, 469 - INV_ADJUST_MODEL, 164 + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, inventory_player_gui [ 18 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 18 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 18 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 18 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, inventory_player_gui [ 18 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 18 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, inventory_player_gui [ 18 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, inventory_player_gui [ 18 ], true );

	inventory_player_gui [ 19 ] = CreatePlayerTextDraw ( playerid, 469 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_MODEL, 164 + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, inventory_player_gui [ 19 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 19 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 19 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 19 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, inventory_player_gui [ 19 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 19 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, inventory_player_gui [ 19 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, inventory_player_gui [ 19 ], true );

	inventory_player_gui [ 20 ] = CreatePlayerTextDraw ( playerid, 469 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_MODEL, 164 + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, inventory_player_gui [ 20 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 20 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 20 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 20 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, inventory_player_gui [ 20 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 20 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, inventory_player_gui [ 20 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, inventory_player_gui [ 20 ], true );

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	inventory_player_gui [ 21 ] = CreatePlayerTextDraw ( playerid, 469 - INV_ADJUST_MODEL, 164 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, inventory_player_gui [ 21 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 21 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 21 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 21 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, inventory_player_gui [ 21 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 21 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, inventory_player_gui [ 21 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, inventory_player_gui [ 21 ], true );

	inventory_player_gui [ 22 ] = CreatePlayerTextDraw ( playerid, 469 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_MODEL, 164 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, inventory_player_gui [ 22 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 22 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 22 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 22 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, inventory_player_gui [ 22 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 22 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, inventory_player_gui [ 22 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, inventory_player_gui [ 22 ], true );

	inventory_player_gui [ 23 ] = CreatePlayerTextDraw ( playerid, 469 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_MODEL, 164 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, inventory_player_gui [ 23 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 23 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 23 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 23 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, inventory_player_gui [ 23 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 23 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, inventory_player_gui [ 23 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, inventory_player_gui [ 23 ], true );

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	inventory_player_gui [ 24 ] = CreatePlayerTextDraw ( playerid, 469 - INV_ADJUST_MODEL, 164 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, inventory_player_gui [ 24 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 24 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 24 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 24 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, inventory_player_gui [ 24 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 24 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, inventory_player_gui [ 24 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, inventory_player_gui [ 24 ], true );

	inventory_player_gui [ 25 ] = CreatePlayerTextDraw ( playerid, 469 + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_MODEL, 164 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, inventory_player_gui [ 25 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 25 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 25 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 25 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, inventory_player_gui [ 25 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 25 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, inventory_player_gui [ 25 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, inventory_player_gui [ 25 ], true );

	inventory_player_gui [ 26 ] = CreatePlayerTextDraw ( playerid, 469 + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_MODEL, 164 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "usebox" ) ;
 	PlayerTextDrawFont(playerid, inventory_player_gui [ 26 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 26 ], 0.000000, 4.983745 ) ;
	PlayerTextDrawTextSize ( playerid, inventory_player_gui [ 26 ], 45.0, 45.0 ) ;
	PlayerTextDrawUseBox ( playerid, inventory_player_gui [ 26 ], true ) ;
	PlayerTextDrawBackgroundColor ( playerid, inventory_player_gui [ 26 ], 0x00000000  ) ;
	PlayerTextDrawBoxColor ( playerid, inventory_player_gui [ 26 ], 0x00000000  ) ;
	PlayerTextDrawSetPreviewModel(playerid, inventory_player_gui [ 26 ], 18631 );
	PlayerTextDrawSetSelectable(playerid, inventory_player_gui [ 26 ], true );

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////// Tile Name Start /////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	new NAME_VAR  = 475 ;
	inventory_player_gui [ 27 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR - INV_ADJUST_MODEL, 200 + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 27 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, inventory_player_gui [ 27 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, inventory_player_gui [ 27 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, inventory_player_gui [ 27 ], 51);

	inventory_player_gui [ 28 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_MODEL, 200 + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 28 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, inventory_player_gui [ 28 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, inventory_player_gui [ 28 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, inventory_player_gui [ 28 ], 51);

	inventory_player_gui [ 29 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_MODEL, 200 + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 29 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, inventory_player_gui [ 29 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, inventory_player_gui [ 29 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, inventory_player_gui [ 29 ], 51);

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	inventory_player_gui [ 30 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR - INV_ADJUST_MODEL, 200 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 30 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, inventory_player_gui [ 30 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, inventory_player_gui [ 30 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, inventory_player_gui [ 30 ], 51);

	inventory_player_gui [ 31 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_MODEL, 200 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 31 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, inventory_player_gui [ 31 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, inventory_player_gui [ 31 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, inventory_player_gui [ 31 ], 51);

	inventory_player_gui [ 32 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_MODEL, 200 + INV_LIST_JUMP_VERTICAL + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 32 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, inventory_player_gui [ 32 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, inventory_player_gui [ 32 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, inventory_player_gui [ 32 ], 51);

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	inventory_player_gui [ 33 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR - INV_ADJUST_MODEL, 200 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 33 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, inventory_player_gui [ 33 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, inventory_player_gui [ 33 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, inventory_player_gui [ 33 ], 51);

	inventory_player_gui [ 34 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR + INV_LIST_JUMP_HORIZONTAL - INV_ADJUST_MODEL, 200 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 34 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, inventory_player_gui [ 34 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, inventory_player_gui [ 34 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, inventory_player_gui [ 34 ], 51);

	inventory_player_gui [ 35 ] = CreatePlayerTextDraw ( playerid,  NAME_VAR + INV_LIST_JUMP_HORIZONTAL * 2 - INV_ADJUST_MODEL, 200 + INV_LIST_JUMP_VERTICAL * 2 + INV_ADJUST_VERTICAL, "Item Name" ) ;
	PlayerTextDrawLetterSize ( playerid, inventory_player_gui [ 35 ], 0.19, 0.6 ) ;
	PlayerTextDrawColor ( playerid, inventory_player_gui [ 35 ], INVENTORY_TILE_COLOR ) ;
	PlayerTextDrawFont ( playerid, inventory_player_gui [ 35 ], 2 ) ;
	PlayerTextDrawBackgroundColor( playerid, inventory_player_gui [ 35 ], 51);

	return true ;
}