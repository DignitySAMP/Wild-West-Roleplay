#if defined _inc_data
	#undef _inc_data
#endif

enum player_itemData {
	player_table_id,
	player_item_id,
	player_item_amount,
	player_item_param1,
	player_item_param2
} ;

new PlayerItem [ MAX_PLAYERS ] [ MAX_ITEMS ] [ player_itemData ], ReturnPlayerItemCount [ MAX_PLAYERS ];

Init_LoadPlayerItems ( playerid ) {
	new query [ 256 ] ;

	for ( new i; i < MAX_ITEMS; i ++ ) {
		PlayerItem [ playerid ] [ i ] [ player_item_id ] = INVALID_ITEM_ID ;
	}

	PlayerItemsLoaded [ playerid ] = false ;

	mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM items_player WHERE player_database_id = %d", Character [ playerid ] [ character_id ] );
	return mysql_tquery ( mysql, query, "LoadPlayerItemData", "i", playerid ) ;
}

forward LoadPlayerItemData ( playerid ) ;
public LoadPlayerItemData ( playerid ) {
	new rows, fields ;

	cache_get_data ( rows, fields, mysql ) ;

    if ( rows ) {

		ReturnPlayerItemCount [ playerid ] = rows ;

		for ( new i, j = rows; i < j; i ++ ) {

			PlayerItem [ playerid ] [ i ] [ player_table_id ] 		= cache_get_field_int ( i, "player_table_id" ) ;
			PlayerItem [ playerid ] [ i ] [ player_item_id ] 		= cache_get_field_int ( i, "player_item_id" ) ;
			PlayerItem [ playerid ] [ i ] [ player_item_amount ] 	= cache_get_field_int ( i, "player_item_amount" ) ;

			PlayerItem [ playerid ] [ i ] [ player_item_param1 ] 	= cache_get_field_int ( i, "player_item_param1" ) ;
			PlayerItem [ playerid ] [ i ] [ player_item_param2 ] 	= cache_get_field_int ( i, "player_item_param2" ) ;

			//printf("Loaded item for playerid %d (%d); %d; %d",
			//	playerid, PlayerItem [ playerid ] [ i ] [ player_item_id ], ReturnPlayerItemCount [ playerid ], PlayerItem [ playerid ] [ i ] [ player_item_amount ] ) ;

   		 	PlayerItemsLoaded [ playerid ] = false ;
		}

		printf("Loaded items for player (%d) %s", playerid, ReturnUserName ( playerid, true ) ) ;

	    HideInventoryExamineGUI ( playerid ) ;
	    PlayerItemsLoaded [ playerid ] = true ;
	}

	else if ( ! rows ) {

		ReturnPlayerItemCount [ playerid ] = 0 ;
	}

	HasPlayerInventoryUpdated[playerid] = false;

	return true ;
}

GivePlayerItem ( playerid, itemid, itemamount, itemparam1, itemparam2, price, cents = 0, showmsg = 1) {

	new query [ 512 ] ;

	if(itemid == -1) {

		SendServerMessage(playerid, sprintf("Itemid returned -1, send this to a developer and/or make a bug report.  [%d|%d]",itemparam1,itemparam2),MSG_TYPE_ERROR);
		return false;
	}

	if ( ReturnPlayerItemCount [ playerid ] >= GetPlayerBackpackSize ( playerid ) ) {

		SendServerMessage ( playerid, "You don't have enough backpack size to pick this item up. You have to get a bigger backpack.", MSG_TYPE_ERROR ) ;
		return false ;
	}
	
	if ( ReturnPlayerItemCount [ playerid ] >= MAX_PLAYER_ITEMS ) {

		if ( ! price ) {
			SendServerMessage ( playerid, "You don't have enough inventory slots! It's been dropped on the ground.", MSG_TYPE_ERROR) ;
			// DROP ITEM

			new Float: x, Float: y, Float: z ;

			GetPlayerPos ( playerid, x, y, z ) ;

			mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO dropped_items (dropped_player, dropped_item, dropped_amount, dropped_param1, dropped_param2, dropped_pos_x, dropped_pos_y, dropped_pos_z, dropped_int, dropped_vw) VALUES (%d, %d, %d, %d, %d, '%f', '%f', '%f', %d, %d)",
				Character[playerid][character_id], itemid, itemamount, itemparam1, itemparam2, x, y, z - 0.75, GetPlayerInterior ( playerid ), GetPlayerVirtualWorld ( playerid ) ) ;
			mysql_tquery (mysql, query ) ;


			Init_LoadDropItems () ;
		}

		else if ( price ) {
			
			SendServerMessage ( playerid, "You don't have enough inventory slots! The transaction was cancelled.", MSG_TYPE_ERROR) ;
		}

		return false ;
	}

	if ( Character [ playerid ] [ character_handmoney ] < price ) {

		if(cents != 0) { SendServerMessage ( playerid, sprintf("You don't have enough money to purchase a %s. You need at least $%d.%02d.", Item [ itemid ] [ item_name ], price,cents ), MSG_TYPE_ERROR) ; }
		else { SendServerMessage ( playerid, sprintf("You don't have enough money to purchase a %s. You need at least $%d.", Item [ itemid ] [ item_name ], price ), MSG_TYPE_ERROR) ; }
		return false ;
	}

	if(cents != 0) {
		
		if ( Character [ playerid ] [ character_handmoney ] == price && Character [ playerid ] [ character_handchange ] < cents) {

			SendServerMessage ( playerid, sprintf("You don't have enough money to purchase a %s. You need at least $%d.%02d.", Item [ itemid ] [ item_name ], price,cents ), MSG_TYPE_ERROR) ;
			return false ;
		}
 	}

 	if(itemamount > Item[itemid][item_stack]) { 

 		itemamount = Item[itemid][item_stack];
 	}

 	if(!ReturnPlayerItemCount[playerid]) { goto skipItemStack; }

	for ( new i=0; i < ReturnPlayerItemCount [ playerid ]; i ++ ) {
	
		if ( PlayerItem [ playerid ] [ i ] [ player_item_id ] == itemid && PlayerItem [ playerid ] [ i ] [ player_item_param1 ] == itemparam1 && PlayerItem [ playerid ] [ i ] [ player_item_param2 ] == itemparam2 ) {

			if ( PlayerItem [ playerid ] [ i ] [ player_item_amount ] < Item[itemid][item_stack] ) {

				PlayerItem [ playerid ] [ i ] [ player_item_amount ] += itemamount ;

				mysql_format ( mysql, query, sizeof ( query ), "UPDATE `items_player` SET player_item_amount = %d WHERE player_item_id = %d AND player_item_param1 = %d  AND player_item_param2 = %d AND player_database_id = %d",
					PlayerItem [ playerid ] [ i ] [ player_item_amount ], itemid, PlayerItem [ playerid ] [ i ] [ player_item_param1 ], PlayerItem [ playerid ] [ i ] [ player_item_param2 ], Character [ playerid ] [ character_id ] );

				mysql_tquery ( mysql, query, "" );			

				query [ 0 ] = EOS ;

				if ( price ) {

					TakeCharacterMoney ( playerid, price, MONEY_SLOT_HAND ) ;
				}

				if ( cents != 0 ) {

					TakeCharacterChange ( playerid, cents, MONEY_SLOT_HAND ) ;
				}

				if(showmsg) {
    
    				format ( query, sizeof ( query ), "You tried to loot item (%d) %s but already owned it. It's amount (%d) has been stacked onto the existing item.",
       				itemid,  Item [ itemid ] [ item_name ], itemamount);

    				//OldLog ( playerid, "inv/give", sprintf("%s has been given %d of item id %d (params: %d, %d )", ReturnUserName ( playerid, false ), itemamount, itemid, itemparam1, itemparam2) ) ;
    				SendServerMessage ( playerid, query, MSG_TYPE_INFO ) ;
				}

				//Init_LoadPlayerItems ( playerid ) ;
				HasPlayerInventoryUpdated[playerid] = true;

				return true;
			}

			else {
				//SendServerMessage ( playerid, "You can only have an item stacked five times.", MSG_TYPE_ERROR ) ;
				//return false ;
				goto skipItemStack;
			}
			//else continue ;
		}

		else continue ;
	}

	skipItemStack:

	inline AddItemQuery() {

		for(new i=0; i<MAX_PLAYER_ITEMS; i++) {

			if(PlayerItem[playerid][i][player_item_id] == INVALID_ITEM_ID) {

				PlayerItem[playerid][i][player_table_id] = cache_insert_id();
				PlayerItem[playerid][i][player_item_id] = itemid;
				PlayerItem[playerid][i][player_item_amount] = itemamount;
				PlayerItem[playerid][i][player_item_param1] = itemparam1;
				PlayerItem[playerid][i][player_item_param2] = itemparam2;
				
				query [ 0 ] = EOS ;
			
				if ( price ) {

					if(cents != 0) { SendServerMessage ( playerid, sprintf("You have purchased a %s for $%d.%02d.", Item [ itemid ] [ item_name ], price, cents ), MSG_TYPE_INFO ) ; }
					else { SendServerMessage ( playerid, sprintf("You have purchased a %s for $%d.", Item [ itemid ] [ item_name ], price ), MSG_TYPE_INFO ) ; }
					TakeCharacterMoney ( playerid, price, MONEY_SLOT_HAND ) ;
				}

				if(cents != 0) {

					if(!price) { SendServerMessage ( playerid, sprintf("You have purchased a %s for %d cents.", Item [ itemid ] [ item_name ], cents ), MSG_TYPE_INFO ) ; }
					TakeCharacterChange(playerid,cents,MONEY_SLOT_HAND);
				}

				else {

			    	if(showmsg) { 
			    		SendServerMessage ( playerid, sprintf("You have received %d of item id (%d) %s.", PlayerItem[playerid][i][player_item_amount], PlayerItem[playerid][i][player_item_id],  Item [ itemid ] [ item_name ] ), MSG_TYPE_INFO ) ; 
			    	}	
				}

				if(!ReturnPlayerItemCount[playerid]) { Init_LoadPlayerItems ( playerid ) ; }
				else { 

					ReturnPlayerItemCount[playerid]++;
					HasPlayerInventoryUpdated[playerid] = true; 
				}
				return true;
			}
			else { continue; }
		}
		return SendServerMessage(playerid,"All items are used.",MSG_TYPE_ERROR);
	}

	mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO `items_player`(player_database_id, player_item_id, player_item_amount, player_item_param1, player_item_param2) VALUES (%d, %d, %d, %d, %d)",
		Character [ playerid ] [ character_id ], itemid, itemamount, itemparam1, itemparam2);
	mysql_tquery_inline ( mysql, query,using inline AddItemQuery,"" );

	return true ;
}

GivePlayerItemByParam ( playerid, param, itemparam, amount, param1, param2, price, cents = 0) {

	for ( new i; i < sizeof ( Item ); i ++ ) {

		if ( Item [ i ] [ item_param ] == param && Item [ i ] [ item_extra_param ] == itemparam ) {

			// Hopefully fix for persistant purchasing - sometimes this will be skipped in the GivePlayerItem function and charge anyway.
			if ( ReturnPlayerItemCount [ playerid ] >= MAX_PLAYER_ITEMS ) {
				
	
				if ( ! price ) {
					SendServerMessage ( playerid, "You don't have enough inventory slots! It's been dropped on the ground.", MSG_TYPE_ERROR) ;
					// DROP ITEM

					new Float: x, Float: y, Float: z, query [ 512 ] ;

					GetPlayerPos ( playerid, x, y, z ) ;

					mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO dropped_items (dropped_player, dropped_item, dropped_amount, dropped_param1, dropped_param2, dropped_pos_x, dropped_pos_y, dropped_pos_z, dropped_int, dropped_vw, dropped_timestamp) VALUES (%d, %d, %d, %d, %d, '%f', '%f', '%f', %d, %d, %d)",
						Character[playerid][character_id], i, amount, param1, param2, x, y, z - 0.75, GetPlayerInterior ( playerid ), GetPlayerVirtualWorld ( playerid ), gettime() + 3600 ) ;
					mysql_tquery (mysql, query ) ;

					format(query,sizeof(query),"%s tried to receive item %s (%d) but inventory is full - dropping item (%d,%d,%d,%d,%d,%.02f,%.02f,%.02f,%d,%d)",ReturnUserName(playerid,true,false),Item[i][item_name],i,Character[playerid][character_id], i, amount, param1, param2, x, y, z - 0.75, GetPlayerInterior ( playerid ), GetPlayerVirtualWorld ( playerid ));
					WriteLog(playerid,"item/full_inv",query);

					Init_LoadDropItems () ;
				}

				else if ( price ) {
					
					SendServerMessage ( playerid, "You don't have enough inventory slots! The transaction was cancelled.", MSG_TYPE_ERROR) ;
				}

				return false ;
			}

			if ( ReturnPlayerItemCount [ playerid ] >= GetPlayerBackpackSize ( playerid ) ) {

				SendServerMessage ( playerid, "You don't have enough backpack size to pick this item up. You have to get a bigger backpack.", MSG_TYPE_ERROR ) ;
				return false ;
			}

			param1 = param;
			param2 = itemparam;

			GivePlayerItem ( playerid, i, amount, param, itemparam, price, cents ) ;
			return true ;
		}

		else continue ;
	}

	SendServerMessage ( playerid, sprintf("Error processing GivePlayerItemByParam request. [PLAYER: %d] [ERROR CODE: %d, %d]", playerid, param, itemparam ), MSG_TYPE_ERROR );
	return false ;
}

GetPlayerItemCount ( playerid ) {

	return ReturnPlayerItemCount [ playerid ] ;
}

GetMaxPlayerItems ( ) { 

	return MAX_PLAYER_ITEMS ;
}

