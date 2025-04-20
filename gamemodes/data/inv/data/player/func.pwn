#if defined _inc_func
	#undef _inc_func
#endif

new PlayerItemPassCooldown [ MAX_PLAYERS ] ;

PassItem ( playerid, tileid, error = 0 ) {

	if ( tileid == -1 ) {

		return false ;
	}

	inline PassItemProcess(pid, dialogid, response, listitem, string:inputtext[]) {

		#pragma unused pid, dialogid, listitem

		if ( ! response ) {

			return false ;
		}

		if ( response ) {

			new targetid ;

			new Float: tX, Float: tY, Float: tZ;
			GetPlayerPos(targetid, tX, tY, tZ);

			if ( sscanf ( inputtext, "k<u>", targetid ) ) {

				return PassItem ( playerid, tileid, 1 ) ;
			}

			if ( ! IsPlayerConnected ( targetid ) ) {

				return PassItem ( playerid, tileid, 2 ) ;
			}

			if ( targetid == playerid ) {

				return PassItem ( playerid, tileid, 3 ) ;
			}

			if ( PlayerItemPassCooldown [ playerid ]  >= gettime ()) {

				return PassItem ( playerid, tileid, 4 ) ;
			}

			if( ReturnPlayerItemCount [ playerid ] >= MAX_PLAYER_ITEMS ){

				return PassItem ( playerid, tileid, 5 ) ;
			}

			if(! IsPlayerInRangeOfPoint ( playerid, 3.0, tX, tY, tZ ) ){

				return PassItem ( playerid, tileid, 6 );
			}

			PlayerItemPassCooldown [ playerid ] = gettime () + 5 ;

			inline PassItemRequest(pidx, dialogidx, responsex, listitemx, string:inputtextx[]) {

				#pragma unused pidx, dialogidx, listitemx, inputtextx 

				if ( ! responsex ) {

					return SendServerMessage ( playerid, 
						sprintf("%s .", targetid, ReturnUserName ( targetid ), Item [ PlayerItem [ playerid ] [ tileid ] [ player_item_id ] ] [ item_name ] ), MSG_TYPE_ERROR ) ;
				}

				else if ( responsex ) {

					new itemid = PlayerItem [ playerid ] [ tileid ] [ player_item_id ], amount = PlayerItem [ playerid ] [ tileid ] [ player_item_amount ], param1 = PlayerItem [ playerid ] [ tileid ] [ player_item_param1 ], param2 = PlayerItem [ playerid ] [ tileid ] [ player_item_param2 ];
					if ( GivePlayerItem ( targetid, PlayerItem [ playerid ] [ tileid ] [ player_item_id ], PlayerItem [ playerid ] [ tileid ] [ player_item_amount ], 
						PlayerItem [ playerid ] [ tileid ] [ player_item_param1 ], PlayerItem [ playerid ] [ tileid ] [ player_item_param2 ], 0 ) ) {

						if(DiscardItem ( playerid, tileid )){

							WriteLog ( playerid, "inv/pass", sprintf("** %s passed %s their %s [amount: %d] [params: %d | %d ].", ReturnUserName ( playerid, false ), ReturnUserName ( targetid, false ), Item [ itemid ] [ item_name ], amount, param1, param2 )) ;
							ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("** %s has given %s their %s.", ReturnUserName ( playerid, false ), ReturnUserName ( targetid, false ), Item [ itemid ] [ item_name ])) ;

						}
					}

					else return SendServerMessage ( playerid, "Something went wrong. The target has been notified of the issue.", MSG_TYPE_ERROR ) ;
				}
			}

			WriteLog ( playerid, "inv/pass", sprintf("** %s offered %s their %s [amount: %d] [params: %d | %d ].", ReturnUserName ( playerid, false ), ReturnUserName ( targetid, false ), Item [ PlayerItem [ playerid ] [ tileid ] [ player_item_id ] ] [ item_name ], PlayerItem [ playerid ] [ tileid ] [ player_item_amount ], PlayerItem [ playerid ] [ tileid ] [ player_item_param1 ], PlayerItem [ playerid ] [ tileid ] [ player_item_param2 ] )) ;
			ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("** %s has offered %s their %s.", ReturnUserName ( playerid, false ), ReturnUserName ( targetid, false ), Item [ PlayerItem [ playerid ] [ tileid ] [ player_item_id ] ] [ item_name ])) ;	

			return Dialog_ShowCallback(targetid, using inline PassItemRequest, DIALOG_STYLE_MSGBOX, "Pass Item To Player: Transfer Request", 
				sprintf("(%d) %s wants to pass you %d of their %s.", playerid, ReturnUserName ( playerid ), PlayerItem [ playerid ] [ tileid ] [ player_item_amount ], Item [ PlayerItem [ playerid ] [ tileid ] [ player_item_id ] ] [ item_name ] ), 
			"Accept", "Deny" ) ;
		}

		return true ;
    }

    new info [ 256 ] ;

    switch ( error ) {

    	case 0: info = "Enter the ID/Name of the player you want to give the item to." ;
    	case 1: info = "Enter the ID/Name of the player you want to give the item to.\nYou need to actually enter a name or playerid.";
    	case 2: info = "Enter the ID/Name of the player you want to give the item to.\nPlayer doesn't seem to connected to the server.";
    	case 3: info = "Enter the ID/Name of the player you want to give the item to.\nYou can't give yourself an item.";
    	case 4: format ( info, sizeof ( info ), "Enter the ID/Name of the player you want to give the item to.\nYou need to wait %d seconds before passing another item.", PlayerItemPassCooldown[playerid] - gettime () ) ;
    	case 5: info = "Enter the ID/Name of the player you want to give the item to.\nThe player you're trying to give the item to doesn't have enough inventory space.";
    	case 6: info = "Enter the ID/Name of the player you want to give the item to.\nYou aren't close enough to the player you're trying to give the item to.";
    }

	return Dialog_ShowCallback(playerid, using inline PassItemProcess, DIALOG_STYLE_INPUT, "Pass Item To Player", info, "Proceed", "Cancel" ) ;
}

SplitItem ( playerid, itemid, amount, itemparam1, itemparam2, tileid ) {

	new query [ 256 ], viewing_inventory = IsPlayerViewingInventory [ playerid ] ;

	if ( ReturnPlayerItemCount [ playerid ] >= MAX_PLAYER_ITEMS ) {

		return SendServerMessage ( playerid, "You don't have enough inventory slots!", MSG_TYPE_ERROR) ;
	}

	if ( PlayerItem [ playerid ] [ tileid ] [ player_item_amount ] <= 1 ) {

		return SendServerMessage ( playerid, "You need to actually have a stack of this item.", MSG_TYPE_ERROR ) ;
	}

	for(new i=0; i<MAX_PLAYER_ITEMS; i++) {
		
		if(PlayerItem[playerid][i][player_item_id] == INVALID_ITEM_ID) {

			PlayerItem[playerid][i][player_item_id] = itemid;
			PlayerItem[playerid][i][player_item_amount] = amount;
			PlayerItem[playerid][i][player_item_param1] = itemparam1;
			PlayerItem[playerid][i][player_item_param2] = itemparam2;

			inline SplitItemQuery() {

				PlayerItem[playerid][i][player_table_id] = cache_insert_id();

				query [ 0 ] = EOS ;
	
			 	SendServerMessage ( playerid, sprintf("You have split your (%d) %s into a stack of %d.", itemid,  Item [ itemid ] [ item_name ], amount ), MSG_TYPE_INFO ) ;

				ToggleInventory ( playerid, INV_MAX_TILES, false ) ;
				HideInventoryExamineGUI ( playerid ) ;

				//Init_LoadPlayerItems ( playerid ) ;


				WriteLog ( playerid, "inv/split", sprintf("** %s split their %s. [new amount: %d, amount to have: %d]", ReturnUserName ( playerid, false ), Item [ itemid ] [ item_name ], PlayerItem [ playerid ] [ tileid ] [ player_item_amount ], amount )) ;


				if ( viewing_inventory ) {

					//Init_LoadPlayerItems ( playerid ) ;

					SendServerMessage ( playerid, "Refreshing inventory, hold on a moment.", MSG_TYPE_WARN ) ;
					defer DelayedInventory(playerid);
				}
			}

			mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO `items_player`(player_database_id, player_item_id, player_item_amount, player_item_param1, player_item_param2) VALUES (%d, %d, %d, %d, %d)",
				Character [ playerid ] [ character_id ], itemid, amount, itemparam1, itemparam2);
			mysql_tquery_inline(mysql,query,using inline SplitItemQuery,"");
			return true;
		}
		else { continue; }
	}

	return SendServerMessage(playerid,"Something went wrong splitting the item, nothing's been changed.",MSG_TYPE_ERROR);
}

StackItem ( playerid, tileid ) {


	new item_id = PlayerItem [ playerid ] [ tileid ] [ player_item_id ],
		item_amount = PlayerItem [ playerid ] [ tileid ] [ player_item_amount ],
		item_param1 = PlayerItem [ playerid ] [ tileid ] [ player_item_param1 ],
		item_param2 = PlayerItem [ playerid ] [ tileid ] [ player_item_param2 ],

	viewing_inventory = IsPlayerViewingInventory [ playerid ] ;

	if ( GivePlayerItem ( playerid, item_id, item_amount, item_param1, item_param2, 0 ) ) {
		ToggleInventory ( playerid, INV_MAX_TILES, false ) ;
		HideInventoryExamineGUI ( playerid ) ;

		Init_LoadPlayerItems ( playerid ) ;

		if ( viewing_inventory ) {

			//Init_LoadPlayerItems ( playerid ) ;

			SendServerMessage ( playerid, "Refreshing inventory, hold on a moment.", MSG_TYPE_WARN ) ;
			defer DelayedInventory(playerid);
		}

		DiscardItem ( playerid, tileid ) ;
		SendServerMessage ( playerid, "Stacked this item with other entities that share it's values. If the item isn't stacked, there weren't any matching entities.", MSG_TYPE_ERROR ) ;
	}

	else return SendServerMessage ( playerid, "GivePlayerItem function returned false. This means the item didn't properly stack due to an issue. You should still have it.", MSG_TYPE_ERROR ) ;

	return true ;
}