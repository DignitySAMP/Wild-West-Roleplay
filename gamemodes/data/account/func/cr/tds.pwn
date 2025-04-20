#define INVENTORY_TILE_COLOR    		( 0xD17F5EFF )
#define INVENTORY_TILE_INLINE_COLOR		( 0x40404077 )
#define INVENTORY_TILE_BG_COLOR     	( 0x111111FF )


new PlayerText: creation_tds_player [ 17 ] 	= PlayerText: INVALID_TEXT_DRAW ;
new Text: 		creation_tds_static [ 9 ]	= Text: INVALID_TEXT_DRAW ;

LoadStaticCreationTextDraws ( ) {

	creation_tds_static [ 0 ] = TextDrawCreate(428.999969, 181.225936, "usebox");
	TextDrawLetterSize(creation_tds_static [ 0 ], 0.000000, 15.713763);
	TextDrawTextSize(creation_tds_static [ 0 ], 235.000015, 0.000000);
	TextDrawUseBox(creation_tds_static [ 0 ], true);
	TextDrawBoxColor(creation_tds_static [ 0 ], INVENTORY_TILE_BG_COLOR);

	creation_tds_static [ 1 ] = TextDrawCreate(427.666748, 182.885177, "usebox");
	TextDrawLetterSize(creation_tds_static [ 1 ], 0.000000, 15.352868);
	TextDrawTextSize(creation_tds_static [ 1 ], 236.333343, 0.000000);
	TextDrawUseBox(creation_tds_static [ 1 ], true);
	TextDrawBoxColor(creation_tds_static [ 1 ], INVENTORY_TILE_COLOR);

	creation_tds_static [ 2 ] = TextDrawCreate(426.666839, 184.129623, "usebox");
	TextDrawLetterSize(creation_tds_static [ 2 ], 0.000000, 15.082916);
	TextDrawTextSize(creation_tds_static [ 2 ], 237.666610, 0.000000);
	TextDrawUseBox(creation_tds_static [ 2 ], true);
	TextDrawBoxColor(creation_tds_static [ 2 ], INVENTORY_TILE_BG_COLOR);

	creation_tds_static [ 3 ] = TextDrawCreate(332.5, 183.044403 , "Create a character");
	TextDrawLetterSize(creation_tds_static [ 3 ], 0.363000, 1.322074);
	TextDrawAlignment(creation_tds_static [ 3 ], 2);
	TextDrawColor(creation_tds_static [ 3 ], INVENTORY_TILE_COLOR);
	TextDrawBackgroundColor(creation_tds_static [ 3 ], 51);
	TextDrawAlignment(creation_tds_static [ 3 ], 2);

	creation_tds_static [ 4 ] = TextDrawCreate(332.5, 194.659301 , "Below you can set up your new character");
	TextDrawLetterSize(creation_tds_static [ 4 ], 0.199666, 0.994369);
	TextDrawAlignment(creation_tds_static [ 4 ], 2);
	TextDrawColor(creation_tds_static [ 4 ], INVENTORY_TILE_COLOR);
	TextDrawBackgroundColor(creation_tds_static [ 4 ], 51);
	TextDrawAlignment(creation_tds_static [ 4 ], 2);

	////////////////////////////////////////////////////////////////////////////

	creation_tds_static [ 5 ] = TextDrawCreate(405, 301.85 , "LD_CHAT:thumbup");
	TextDrawTextSize(creation_tds_static [ 5 ],  15, 15 ) ;
	TextDrawColor(creation_tds_static [ 5 ], INVENTORY_TILE_COLOR);
	TextDrawUseBox(creation_tds_static [ 5 ], true);
	TextDrawFont(creation_tds_static [ 5 ], 4);
	TextDrawSetSelectable(creation_tds_static [ 5 ], true ) ;

	creation_tds_static [ 6 ] = TextDrawCreate(375.666656, 210.262893, "usebox");
	TextDrawLetterSize(creation_tds_static [ 6 ], 0.000000, -0.265638);
	TextDrawTextSize(creation_tds_static [ 6 ], 289.666625, 0.000000);
	TextDrawUseBox(creation_tds_static [ 6 ], true);
	TextDrawBoxColor(creation_tds_static [ 6 ], INVENTORY_TILE_COLOR);

	////////////////////////////////////////////////////////////////////////////

	return true ;
}

DestroyCreationTextDraws ( playerid ) {

	for ( new i; i < sizeof ( creation_tds_player ); i ++ ) {

		PlayerTextDrawDestroy (playerid,  creation_tds_player [ i ] ) ;
	}
}

LoadCreationTextDraws ( playerid ) {

	creation_tds_player [ 0 ] = CreatePlayerTextDraw(playerid, 220, 205, "skin");
	PlayerTextDrawTextSize(playerid, creation_tds_player [ 0 ], 85, 115);
	PlayerTextDrawUseBox(playerid, creation_tds_player [ 0 ], true);
	PlayerTextDrawBackgroundColor ( playerid, creation_tds_player [ 0 ], 0 ) ;
	PlayerTextDrawBoxColor ( playerid, creation_tds_player [ 0 ], 0 ) ;
	PlayerTextDrawFont(playerid, creation_tds_player [ 0 ], TEXT_DRAW_FONT_MODEL_PREVIEW ) ;
	PlayerTextDrawSetPreviewModel(playerid, creation_tds_player [ 0 ], 128 ) ;
	PlayerTextDrawSetPreviewRot(playerid, creation_tds_player [ 0 ], 0, 0, 0,  1) ;

	//////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////

	creation_tds_player [ 1 ] = CreatePlayerTextDraw(playerid, 290, 220, "usebox");
	PlayerTextDrawLetterSize(playerid, creation_tds_player [ 1 ], 0.000000, 1.25);
	PlayerTextDrawTextSize(playerid, creation_tds_player [ 1 ], 400, 0.000000);
	PlayerTextDrawUseBox(playerid, creation_tds_player [ 1 ], true);
	PlayerTextDrawBoxColor(playerid, creation_tds_player [ 1 ], INVENTORY_TILE_INLINE_COLOR);

	creation_tds_player [ 2 ] = CreatePlayerTextDraw(playerid, 345, 220, "Change your gender");
	PlayerTextDrawLetterSize(playerid, creation_tds_player [ 2 ], 0.199666, 0.994369);
	PlayerTextDrawColor(playerid, creation_tds_player [ 2 ], INVENTORY_TILE_COLOR);
	PlayerTextDrawBackgroundColor(playerid, creation_tds_player [ 2 ], 51);
	PlayerTextDrawAlignment(playerid, creation_tds_player [ 2 ], 2 ) ;

	creation_tds_player [ 3 ] = CreatePlayerTextDraw(playerid, 285, 220, "LD_BEAT:left");
	PlayerTextDrawTextSize(playerid, creation_tds_player [ 3 ], 12.5, 12.5);
	PlayerTextDrawColor(playerid, creation_tds_player [ 3 ], INVENTORY_TILE_COLOR);
	PlayerTextDrawUseBox(playerid, creation_tds_player [ 3 ], true);
	PlayerTextDrawFont(playerid, creation_tds_player [ 3 ], 4 ) ;
	PlayerTextDrawSetSelectable(playerid, creation_tds_player [ 3 ], true ) ;

	creation_tds_player [ 4 ] = CreatePlayerTextDraw(playerid, 395, 220, "LD_BEAT:right");
	PlayerTextDrawTextSize(playerid, creation_tds_player [ 4 ], 12.5, 12.5);
	PlayerTextDrawColor(playerid, creation_tds_player [ 4 ], INVENTORY_TILE_COLOR);
	PlayerTextDrawUseBox(playerid, creation_tds_player [ 4 ], true);
	PlayerTextDrawFont(playerid, creation_tds_player [ 4 ], 4 ) ;
	PlayerTextDrawSetSelectable(playerid, creation_tds_player [ 4 ], true ) ;

	//////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////

	creation_tds_player [ 5 ] = CreatePlayerTextDraw(playerid, 290, 240, "usebox");
	PlayerTextDrawLetterSize(playerid, creation_tds_player [ 5 ], 0.000000, 1.25);
	PlayerTextDrawTextSize(playerid, creation_tds_player [ 5 ], 400, 0.000000);
	PlayerTextDrawUseBox(playerid, creation_tds_player [ 5 ], true);
	PlayerTextDrawBoxColor(playerid, creation_tds_player [ 5 ], INVENTORY_TILE_INLINE_COLOR);

	creation_tds_player [ 6 ] = CreatePlayerTextDraw(playerid, 345, 240, "Change your racial group");
	PlayerTextDrawLetterSize(playerid, creation_tds_player [ 6 ], 0.199666, 0.994369);
	PlayerTextDrawColor(playerid, creation_tds_player [ 6 ], INVENTORY_TILE_COLOR);
	PlayerTextDrawBackgroundColor(playerid, creation_tds_player [ 6 ], 51);
	PlayerTextDrawAlignment(playerid, creation_tds_player [ 6 ], 2 ) ;

	creation_tds_player [ 7 ] = CreatePlayerTextDraw(playerid, 285, 240, "LD_BEAT:left");
	PlayerTextDrawTextSize(playerid, creation_tds_player [ 7 ], 12.5, 12.5);
	PlayerTextDrawColor(playerid, creation_tds_player [ 7 ], INVENTORY_TILE_COLOR);
	PlayerTextDrawUseBox(playerid, creation_tds_player [ 7 ], true);
	PlayerTextDrawFont(playerid, creation_tds_player [ 7 ], 4 ) ;
	PlayerTextDrawSetSelectable(playerid, creation_tds_player [ 7 ], true ) ;

	creation_tds_player [ 8 ] = CreatePlayerTextDraw(playerid, 395, 240, "LD_BEAT:right");
	PlayerTextDrawTextSize(playerid, creation_tds_player [ 8 ], 12.5, 12.5);
	PlayerTextDrawColor(playerid, creation_tds_player [ 8 ], INVENTORY_TILE_COLOR);
	PlayerTextDrawUseBox(playerid, creation_tds_player [ 8 ], true);
	PlayerTextDrawFont(playerid, creation_tds_player [ 8 ], 4 ) ;
	PlayerTextDrawSetSelectable(playerid, creation_tds_player [ 8 ], true ) ;

	//////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////

	creation_tds_player [ 9 ] = CreatePlayerTextDraw(playerid, 290, 260, "usebox");
	PlayerTextDrawLetterSize(playerid, creation_tds_player [ 9 ], 0.000000, 1.25);
	PlayerTextDrawTextSize(playerid, creation_tds_player [ 9 ], 400, 0.000000);
	PlayerTextDrawUseBox(playerid, creation_tds_player [ 9 ], true);
	PlayerTextDrawBoxColor(playerid, creation_tds_player [ 9 ], INVENTORY_TILE_INLINE_COLOR);

	creation_tds_player [ 10 ] = CreatePlayerTextDraw(playerid, 345, 260, "Change your place of birth");
	PlayerTextDrawLetterSize(playerid, creation_tds_player [ 10 ], 0.199666, 0.994369);
	PlayerTextDrawColor(playerid, creation_tds_player [ 10 ], INVENTORY_TILE_COLOR);
	PlayerTextDrawBackgroundColor(playerid, creation_tds_player [ 10 ], 51);
	PlayerTextDrawAlignment(playerid, creation_tds_player [ 10 ], 2 ) ;

	creation_tds_player [ 11 ] = CreatePlayerTextDraw(playerid, 285, 260, "LD_BEAT:left");
	PlayerTextDrawTextSize(playerid, creation_tds_player [ 11 ], 12.5, 12.5);
	PlayerTextDrawColor(playerid, creation_tds_player [ 11 ], INVENTORY_TILE_COLOR);
	PlayerTextDrawUseBox(playerid, creation_tds_player [ 11 ], true);
	PlayerTextDrawFont(playerid, creation_tds_player [ 11 ], 4 ) ;
	PlayerTextDrawSetSelectable(playerid, creation_tds_player [ 11 ], true ) ;

	creation_tds_player [ 12 ] = CreatePlayerTextDraw(playerid, 395, 260, "LD_BEAT:right");
	PlayerTextDrawTextSize(playerid, creation_tds_player [ 12 ], 12.5, 12.5);
	PlayerTextDrawColor(playerid, creation_tds_player [ 12 ], INVENTORY_TILE_COLOR);
	PlayerTextDrawUseBox(playerid, creation_tds_player [ 12 ], true);
	PlayerTextDrawFont(playerid, creation_tds_player [ 12 ], 4 ) ;
	PlayerTextDrawSetSelectable(playerid, creation_tds_player [ 12 ], true ) ;

	//////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////

	creation_tds_player [ 13 ] = CreatePlayerTextDraw(playerid, 290, 280, "usebox");
	PlayerTextDrawLetterSize(playerid, creation_tds_player [ 13 ], 0.000000, 1.25);
	PlayerTextDrawTextSize(playerid, creation_tds_player [ 13 ], 400, 0.000000);
	PlayerTextDrawUseBox(playerid, creation_tds_player [ 13 ], true);
	PlayerTextDrawBoxColor(playerid, creation_tds_player [ 13 ], INVENTORY_TILE_INLINE_COLOR);

	creation_tds_player [ 14 ] = CreatePlayerTextDraw(playerid, 345, 280, "Change your starting age");
	PlayerTextDrawLetterSize(playerid, creation_tds_player [ 14 ], 0.199666, 0.994369);
	PlayerTextDrawColor(playerid, creation_tds_player [ 14 ], INVENTORY_TILE_COLOR);
	PlayerTextDrawBackgroundColor(playerid, creation_tds_player [ 14 ], 51);
	PlayerTextDrawAlignment(playerid, creation_tds_player [ 14 ], 2 ) ;

	creation_tds_player [ 15 ] = CreatePlayerTextDraw(playerid, 285, 280, "LD_BEAT:left");
	PlayerTextDrawTextSize(playerid, creation_tds_player [ 15 ], 12.5, 12.5);
	PlayerTextDrawColor(playerid, creation_tds_player [ 15 ], INVENTORY_TILE_COLOR);
	PlayerTextDrawUseBox(playerid, creation_tds_player [ 15 ], true);
	PlayerTextDrawFont(playerid, creation_tds_player [ 15 ], 4 ) ;
	PlayerTextDrawSetSelectable(playerid, creation_tds_player [ 15 ], true ) ;

	creation_tds_player [ 16 ] = CreatePlayerTextDraw(playerid, 395, 280, "LD_BEAT:right");
	PlayerTextDrawTextSize(playerid, creation_tds_player [ 16 ], 12.5, 12.5);
	PlayerTextDrawColor(playerid, creation_tds_player [ 16 ], INVENTORY_TILE_COLOR);
	PlayerTextDrawUseBox(playerid, creation_tds_player [ 16 ], true);
	PlayerTextDrawFont(playerid, creation_tds_player [ 16 ], 4 ) ;
	PlayerTextDrawSetSelectable(playerid, creation_tds_player [ 16 ], true ) ;

	return true ;
}
