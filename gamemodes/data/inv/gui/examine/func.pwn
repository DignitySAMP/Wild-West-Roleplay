#if defined _inc_func
	#undef _inc_func
#endif

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
	new calc ;

	for ( new i; i < INV_MAX_TILES; i ++ ) {
		if ( playertextid == InventoryTileModel [ i ] ) {

			if ( PlayerItem [ playerid ] [ i ] [ player_item_id ] == INVALID_ITEM_ID ) {
				Init_LoadPlayerItems ( playerid ) ;

				HideInventoryExamineGUI ( playerid ) ;
				break ;
			}

			if ( ! PlayerInventoryPage [ playerid ] ) {
				calc = PlayerItem [ playerid ] [ i ] [ player_item_id ] ;
			}
			else if ( PlayerInventoryPage [ playerid ] ) {
				calc = PlayerItem [ playerid ] [ i + INV_MAX_TILES ] [ player_item_id ] ;
			}

			DisplayInventoryExamineGUI ( playerid, calc, i ) ;
			break ;
		}
	}
	
	#if defined invg_OnPlayerClickPlayerTD
		return invg_OnPlayerClickPlayerTD(playerid, PlayerText:playertextid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerClickPlayerTD
	#undef OnPlayerClickPlayerTextDraw
#else
	#define _ALS_OnPlayerClickPlayerTD
#endif

#define OnPlayerClickPlayerTextDraw invg_OnPlayerClickPlayerTD
#if defined invg_OnPlayerClickPlayerTD
	forward invg_OnPlayerClickPlayerTD(playerid, PlayerText:playertextid);
#endif

public OnPlayerClickTextDraw(playerid, Text:clickedid) {

	if ( clickedid == inventory_examine_tds [ 6 ] && PlayerExaminingItem [ playerid ] != INVALID_ITEM_ID  ) { // use

		new itemid = PlayerExaminingItem [ playerid ] ;
		new tileid = PlayerExaminingItemTile [ playerid ] ;

		OnPlayerUseItem ( playerid, itemid, tileid ) ;
		return true ;
	}

	if ( clickedid == inventory_examine_tds [ 7 ] && PlayerExaminingItem [ playerid ] != INVALID_ITEM_ID ) { // options

		new tileid = PlayerExaminingItemTile [ playerid ] ;

		inline ItemOptionList(pid, dialogid, response, listitem, string:inputtext[]) {

        	#pragma unused pid, dialogid, response, inputtext, listitem

			if ( ! response ) {

				return false ;
			}

			if ( response ) {

				switch ( listitem ) {

					case 0: { // Give
						PassItem ( playerid, tileid ) ;
					}


					case 1: { // Split
					
						if(SplitItem ( playerid, PlayerItem [ playerid ] [ tileid ] [ player_item_id ],  PlayerItem [ playerid ] [ tileid ] [ player_item_amount ] / 2,
							PlayerItem [ playerid ] [ tileid ] [ player_item_param1 ], PlayerItem [ playerid ] [ tileid ] [ player_item_param2 ], tileid)) {

							DecreaseItem ( playerid, tileid,  PlayerItem [ playerid ] [ tileid ] [ player_item_amount ] / 2 ) ;
						}

						return true ;
					}

					case 2: { // stack

						//StackItem ( playerid, tileid ) ;
						SendServerMessage ( playerid, "Disabled for bug fixing.", MSG_TYPE_ERROR ) ;
						return true ;
					}

					case 3: { // Discard
						
						inline DiscardWarning(pidx, dialogidx, responsex, listitemx, string:inputtextx[]) {

					    	#pragma unused pidx, dialogidx, inputtextx, listitemx

							if ( ! responsex ) {

								return false ;
							}

							DiscardItem ( playerid, tileid  ) ;
							//return SendClientMessage(playerid, -1, "This feature is disabled in this alpha test." ) ;
							//return SendServerMessage ( playerid, "You've discarded the item. Your equipped item has been reset for security reasons.", MSG_TYPE_WARN ) ;
							return SendServerMessage ( playerid, "You've discarded the item.", MSG_TYPE_WARN ) ;
						}

					    return Dialog_ShowCallback(playerid, using inline DiscardWarning, DIALOG_STYLE_MSGBOX, "{CC4343}Deletion Warning", 
					    	"{CC4343}Deletion Warning!!!{DEDEDE}\n\nYou're about to discard an item.\nThis means it will get deleted from your inventory, with no way to get it back.\n\nPress \"DELETE\" to continue, or cancel to back out.", 
					    	"{CC4343}Delete", "Cancel" ) ;
					}
				}

				return true ;
			}
			
			return true ;
		}

	    return Dialog_ShowCallback(playerid, using inline ItemOptionList, DIALOG_STYLE_LIST, sprintf("Options for item (%d) %s", PlayerItem [ playerid ] [ tileid ] [ player_item_id ], Item [ PlayerItem [ playerid ] [ tileid ] [ player_item_id ] ] [ item_name ] ), 
	    	"Give Item\nSplit Item\nStack Item\nDiscard Item", "Select", "Cancel" ) ;
	}

	if ( clickedid == inventory_examine_tds [ 8 ]  && PlayerExaminingItem [ playerid ] != INVALID_ITEM_ID  ) { // drop
		//return SendClientMessage(playerid, -1, "This feature is disabled in this alpha test." ) ;

		new tileid = PlayerExaminingItemTile [ playerid ] ;

		OnPlayerDropItem ( playerid, tileid ) ;
		return true ;
	}


	#if defined use_OnPlayerClickTextDraw
		return use_OnPlayerClickTextDraw(playerid, Text: clickedid );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerClickTextDraw
	#undef OnPlayerClickTextDraw
#else
	#define _ALS_OnPlayerClickTextDraw
#endif

#define OnPlayerClickTextDraw use_OnPlayerClickTextDraw
#if defined use_OnPlayerClickTextDraw
	forward use_OnPlayerClickTextDraw(playerid, Text: clickedid );
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DisplayInventoryExamineGUI ( playerid, itemid, tileid ) {

    HideInventoryExamineGUI ( playerid ) ;

	new itemobject = Item [ itemid ] [ item_model ], string [ 64 ] ;

	PlayerExaminingItem [ playerid ] = itemid ;
	PlayerExaminingItemTile [ playerid ] = tileid ;

	if ( PlayerInventoryPage [ playerid ]) {
		PlayerExaminingItemTile [ playerid ] = tileid + INV_MAX_TILES ;
	}

	// Setting item name
	/*
	switch ( Item [ itemid ] [ item_rarity ] ) {

		case ITEM_RARITY_NORMAL: 		PlayerTextDrawColor(playerid, inventory_examine_ptds [ 1 ], 0xDEDEDEFF ) ;
		case ITEM_RARITY_COMMON: 		PlayerTextDrawColor(playerid, inventory_examine_ptds [ 1 ], 0x72B56BFF ) ;
		case ITEM_RARITY_RARE: 			PlayerTextDrawColor(playerid, inventory_examine_ptds [ 1 ], 0x6092CCFF ) ;
		case ITEM_RARITY_EPIC: 			PlayerTextDrawColor(playerid, inventory_examine_ptds [ 1 ], 0x7B5991FF ) ;
		case ITEM_RARITY_LEGENDARY:  	PlayerTextDrawColor(playerid, inventory_examine_ptds [ 1 ], 0xD6872DFF ) ;
	}
	*/

	if ( Item [ itemid ] [ item_rarity ] == ITEM_RARITY_NORMAL ) 	{ PlayerTextDrawColor(playerid, inventory_examine_ptds [ 1 ], 0xDEDEDEFF ) ; }
	if ( Item [ itemid ] [ item_rarity ] == ITEM_RARITY_COMMON ) 	{ PlayerTextDrawColor(playerid, inventory_examine_ptds [ 1 ], 0x72B56BFF ) ; }
	if ( Item [ itemid ] [ item_rarity ] == ITEM_RARITY_RARE ) 		{ PlayerTextDrawColor(playerid, inventory_examine_ptds [ 1 ], 0x6092CCFF ) ; }
	if ( Item [ itemid ] [ item_rarity ] == ITEM_RARITY_EPIC ) 		{ PlayerTextDrawColor(playerid, inventory_examine_ptds [ 1 ], 0x7B5991FF ) ; }
	if ( Item [ itemid ] [ item_rarity ] == ITEM_RARITY_LEGENDARY ) { PlayerTextDrawColor(playerid, inventory_examine_ptds [ 1 ], 0xD6872DFF ) ; }

	strcat(string, Item [ itemid ] [ item_name ] ) ;

	if ( strlen ( string ) > 21 ) {
		strins ( string, " ...~n~...", 21) ;
	}

	PlayerTextDrawSetString ( playerid, inventory_examine_ptds [ 1 ], string ) ;


	switch ( Item [ itemid ] [ item_type ] ) {
		case ITEM_TYPE_UNDEFINED: 	TextDrawSetString(inventory_examine_tds [ 6 ], 	"Invalid" ) ;

		case ITEM_TYPE_EQUIP: {

			if ( EquippedItem [ playerid ] == -1 ) {
				TextDrawSetString(inventory_examine_tds [ 6 ], 	"Equip" ) ;
			}

			else TextDrawSetString(inventory_examine_tds [ 6 ], 	"Unequip" ) ;
		}

		case ITEM_TYPE_MISC: 	TextDrawSetString(inventory_examine_tds [ 6 ], 	"Use" ) ;
		case ITEM_TYPE_FOOD: 	TextDrawSetString(inventory_examine_tds [ 6 ], 	"Consume" ) ;
		case ITEM_TYPE_USE: 	TextDrawSetString(inventory_examine_tds [ 6 ], 	"Use" ) ;
		case ITEM_TYPE_SEED: 	TextDrawSetString(inventory_examine_tds [ 6 ], 	"Plant" ) ;
		case ITEM_TYPE_JUNK: 	TextDrawSetString(inventory_examine_tds [ 6 ], 	"Sell" ) ;
		case ITEM_TYPE_CRAFT: 	TextDrawSetString(inventory_examine_tds [ 6 ], 	"Craft" ) ;
		case ITEM_TYPE_SELL: 	TextDrawSetString(inventory_examine_tds [ 6 ], 	"Sell" ) ;
	}

/*
	if ( Item [ itemid ] [ item_type ] == ITEM_TYPE_UNDEFINED ) { TextDrawSetString(inventory_examine_tds [ 6 ], "Invalid" ) ; }
	if ( Item [ itemid ] [ item_type ] == ITEM_TYPE_EQUIP ) {

		if ( EquippedItem [ playerid ] == -1 ) { TextDrawSetString(inventory_examine_tds [ 6 ], "Equip" ) ; }
		else { TextDrawSetString(inventory_examine_tds [ 6 ], "Unequip" ) ; }
 	}
 	if ( Item [ itemid ] [ item_type ] == ITEM_TYPE_MISC ) 		{ TextDrawSetString(inventory_examine_tds [ 6 ], "Use" ) ; }
 	if ( Item [ itemid ] [ item_type ] == ITEM_TYPE_FOOD ) 		{ TextDrawSetString(inventory_examine_tds [ 6 ], "Consume" ) ; }
 	if ( Item [ itemid ] [ item_type ] == ITEM_TYPE_USE ) 		{ TextDrawSetString(inventory_examine_tds [ 6 ], "Use" ) ; }
 	if ( Item [ itemid ] [ item_type ] == ITEM_TYPE_SEED ) 		{ TextDrawSetString(inventory_examine_tds [ 6 ], "Plant" ) ; }
 	if ( Item [ itemid ] [ item_type ] == ITEM_TYPE_JUNK ) 		{ TextDrawSetString(inventory_examine_tds [ 6 ], "Sell" ) ; }
 	if ( Item [ itemid ] [ item_type ] == ITEM_TYPE_CRAFT ) 	{ TextDrawSetString(inventory_examine_tds [ 6 ], "Craft" ) ; }
 	if ( Item [ itemid ] [ item_type ] == ITEM_TYPE_SELL ) 		{ TextDrawSetString(inventory_examine_tds [ 6 ], "Sell" ) ; }
*/
	string [ 0 ] = EOS ;

	// Setting player item quanity
	valstr ( string, PlayerItem [ playerid ] [ PlayerExaminingItemTile [ playerid ] ] [ player_item_amount ] ) ;
	PlayerTextDrawSetString ( playerid, inventory_examine_ptds [ 2 ], string ) ; 

	// Setting item model
	PlayerTextDrawSetPreviewModel(playerid, inventory_examine_ptds [ 0 ], itemobject );
	//PlayerTextDrawSetPreviewRot(playerid, inventory_examine_ptds [ 0 ], Item [ itemid ] [ item_tile_rot_x ], 
	//	Item [ itemid ] [ item_tile_rot_y ], Item [ itemid ] [ item_tile_rot_z ], Item [ itemid ] [ item_tile_zoom ]);

    // Showing item textdraws

    for ( new i; i < sizeof ( inventory_examine_tds ); i ++ ) {

    	TextDrawShowForPlayer(playerid, inventory_examine_tds [ i ] ) ;
    }


	for ( new i; i < sizeof ( inventory_examine_ptds ); i ++ ) {

		PlayerTextDrawShow ( playerid, inventory_examine_ptds [ i ] ) ;
	}

//	CancelSelectTextDraw ( playerid ) ;
	SelectTextDraw ( playerid, -1 ) ;

	return true ;
}