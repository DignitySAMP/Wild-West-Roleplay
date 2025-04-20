#if defined _inc_func
	#undef _inc_func
#endif

timer DelayInitInvTiles[500](playerid, page) {

	InitiateInventoryTiles ( playerid, page );
	return true;
}

InitiateInventoryTiles ( playerid, page ) {

   	new tiles, itemid ;

	ToggleInventory ( playerid, INV_MAX_TILES, false ) ;

	//if ( IsPlayerNearWantedPoster ( playerid ) != -1 ) {
		//return false ;
	//}

	if(HasPlayerInventoryUpdated[playerid]) {

		Init_LoadPlayerItems(playerid);
		defer DelayInitInvTiles(playerid,page);
		return true;
	}

	if ( ! PlayerItemsLoaded [ playerid ] ) {
	
		Init_LoadPlayerItems ( playerid ) ;

		return SendServerMessage ( playerid, "You don't seem to have any items to display. Try again in a moment to reload them.", MSG_TYPE_ERROR ) ;
	}

	switch ( page ) {
		case false : {

			for ( new i; i < INV_MAX_TILES; i ++ ) {
				
				if ( PlayerItem [ playerid ] [ i ] [ player_item_id ] != INVALID_ITEM_ID && PlayerItem [ playerid ] [ i ] [ player_item_id ] < sizeof ( Item ) ) {

				    tiles ++ ;
				}

				else continue ;
			}
			
			for ( new i, j = tiles; i < j; i ++ ) {

				itemid = PlayerItem [ playerid ] [ i ] [ player_item_id ] ;

                if ( itemid == -1 ) {
                	continue ;
                }

            	HandleInventoryTilesPerPage ( playerid, itemid, i ) ;
			}
		}

	    case true : { // Second Page

			for ( new i = INV_MAX_TILES; i < MAX_PLAYER_ITEMS; i ++ ) {

				if ( PlayerItem [ playerid ] [ i ] [ player_item_id ] != INVALID_ITEM_ID && PlayerItem [ playerid ] [ i ] [ player_item_id ] < sizeof ( Item ) ) {

				    if ( ++ tiles  == 9 ) {
						break ;
					}
				}
			}

			for ( new i, j = tiles; i < j; i ++ ) {

				//if ( ( i + INV_MAX_TILES ) > MAX_ITEMS ) {

				//	continue ;
				//}

				itemid = PlayerItem [ playerid ] [ i + INV_MAX_TILES ] [ player_item_id ] ;

                if ( itemid == -1 ) {
                	continue ;
                }
               
               	HandleInventoryTilesPerPage ( playerid, itemid, i ) ;
			}
		}
	}

	ToggleInventory ( playerid, tiles, true ) ;

	return true ;
}

HandleInventoryTilesPerPage ( playerid, itemid, tileid ) {
	new model = Item [ itemid ] [ item_model ], name [ MAX_ITEM_NAME ] ;

	PlayerTextDrawHide ( playerid, InventoryTileModel [ tileid ] ) ;

	PlayerTextDrawSetPreviewModel ( playerid, InventoryTileModel [ tileid ], model ) ;
	//PlayerTextDrawSetPreviewRot(playerid, InventoryTileModel [ tileid ], Item [ itemid ] [ item_tile_rot_x ], 
	//	Item [ itemid ] [ item_tile_rot_y ], Item [ itemid ] [ item_tile_rot_z ], Item [ itemid ] [ item_tile_zoom ]);

	//PlayerTextDrawSetPreviewRot(playerid, InventoryTileModel [ tileid ], -20.0, 0.0, -40.0, 1.0);

	PlayerTextDrawShow ( playerid, InventoryTileModel [ tileid ] ) ;
	PlayerTextDrawHide ( playerid, InventoryTileName [ tileid ] ) ;

	// Setting item name
	switch ( Item [ itemid ] [ item_rarity ] ) {

		case ITEM_RARITY_NORMAL: 		PlayerTextDrawColor(playerid, InventoryTileName [ tileid ], 0xDEDEDEFF ) ;
		case ITEM_RARITY_COMMON: 		PlayerTextDrawColor(playerid, InventoryTileName [ tileid ], 0x72B56BFF ) ;
		case ITEM_RARITY_RARE: 			PlayerTextDrawColor(playerid, InventoryTileName [ tileid ], 0x6092CCFF ) ;
		case ITEM_RARITY_EPIC: 			PlayerTextDrawColor(playerid, InventoryTileName [ tileid ], 0x7B5991FF ) ;
		case ITEM_RARITY_LEGENDARY:  	PlayerTextDrawColor(playerid, InventoryTileName [ tileid ], 0xD6872DFF ) ;
	}

	// Setting item name
	strcat( name, Item [ itemid ] [ item_name ], MAX_ITEM_NAME ) ;

	if ( strlen ( name ) > 6 ) {
		strdel ( name, 6, sizeof ( name ) ) ;
		strins ( name, "..", 6 ) ;
	}

	PlayerTextDrawSetString ( playerid, InventoryTileName [ tileid ], name ) ;
	PlayerTextDrawShow ( playerid, InventoryTileName [ tileid ] ) ;

	name [ 0 ] = EOS ;
}

ToggleInventory ( playerid, tiles, bool: toggle ) {

	switch ( toggle ) {
	
		case false : {
			for ( new i, j = tiles; i < j; i ++ ) {
				PlayerTextDrawHide ( playerid, InventoryTileOutline  [ i ] ) ;
				PlayerTextDrawHide ( playerid, InventoryTile  [ i ] ) ;
				PlayerTextDrawHide ( playerid, InventoryTileName  [ i ] ) ;
				PlayerTextDrawHide ( playerid, InventoryTileModel  [ i ] ) ;
			}

			for ( new i; i < sizeof ( inventory_static_gui ); i ++ ) {

				TextDrawHideForPlayer ( playerid, inventory_static_gui [ i ] ) ;
			}


			IsPlayerViewingInventory [ playerid ] = false ;
			//OldLog ( playerid, "inv/toggle", sprintf("%s has closed their inventory", ReturnUserName ( playerid, false ) ) );
			
		}

		case true: {

			//if ( IsPlayerNearWantedPoster ( playerid ) != -1 ) {
			//	return false ;
			//}

			if(HasPlayerInventoryUpdated[playerid]) { Init_LoadPlayerItems ( playerid ) ; }

			for ( new i, j = tiles; i < j; i ++ ) {
				PlayerTextDrawShow ( playerid, InventoryTileOutline  [ i ] ) ;
				PlayerTextDrawShow ( playerid, InventoryTile  [ i ] ) ;
				PlayerTextDrawShow ( playerid, InventoryTileName  [ i ] ) ;
				PlayerTextDrawShow ( playerid, InventoryTileModel  [ i ] ) ;
			}

			
			for ( new i; i < sizeof ( inventory_static_gui ); i ++ ) {

				TextDrawShowForPlayer ( playerid, inventory_static_gui [ i ] ) ;
			}
			
			TextDrawSetString ( inventory_static_gui [ 3 ], "PAGE 1 OF 1" ) ;
			
			if ( !PlayerInventoryPage [ playerid ] && ReturnPlayerItemCount [ playerid ] > INV_MAX_TILES ) {
				TextDrawShowForPlayer ( playerid, inventory_static_gui [ 4 ] ) ;
				TextDrawSetString ( inventory_static_gui [ 3 ], "PAGE 1 OF 2" ) ;
			}

			else if ( PlayerInventoryPage [ playerid ] ) {
				TextDrawShowForPlayer ( playerid, inventory_static_gui [ 5 ] ) ;
   				TextDrawSetString ( inventory_static_gui [ 3 ], "PAGE 2 OF 2" ) ;
			}

			IsPlayerViewingInventory [ playerid ] = true ;
			SelectTextDraw ( playerid, INVENTORY_TILE_COLOR ) ;
			//OldLog ( playerid, "inv/toggle", sprintf("%s has opened their inventory", ReturnUserName ( playerid, false ) ) );

		}
	}

	return true ;
}