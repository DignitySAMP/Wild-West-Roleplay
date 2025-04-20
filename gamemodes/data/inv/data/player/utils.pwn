#if defined _inc_utils
	#undef _inc_utils
#endif

//ReturnPlayerItems(playerid) { return ReturnPlayerItemCount[playerid]; }

//GetPlayerItemID(playerid,tileid) { return PlayerItem[playerid][tileid][player_item_id]; }

ClearBuggedItems(playerid) {

	new query[128];
	inline BuggedItemCheck() {

		new rows,fields;
		cache_get_data(rows,fields,mysql);

		if(rows) {

			for(new i=0; i<rows; i++) {

				new tableid,itemid;
				tableid = cache_get_field_content_int(i,"player_table_id",mysql);
				itemid = cache_get_field_content_int(i,"player_item_id",mysql);

				if(itemid == -1) {

					mysql_format(mysql,query,sizeof(query),"DELETE FROM player_items WHERE player_table_id = %d AND player_database_id = %d",tableid,Character[playerid][character_id]);
					mysql_tquery(mysql,query);
				}
			}
			Init_LoadPlayerItems(playerid);
		}
	}
	mysql_format(mysql,query,sizeof(query),"SELECT player_item_id FROM items_player WHERE player_database_id = %d",Character[playerid][character_id]);
	mysql_tquery_inline(mysql,query,using inline BuggedItemCheck,"");
}

DoesPlayerHaveItemByExtraParam ( playerid, param ) {

	for ( new i; i < ReturnPlayerItemCount [ playerid ]; i ++ ) {

		if ( PlayerItem [ playerid ] [ i ] [ player_item_param2 ] == param ) { 

			return i ;
		}
		
		else continue;
	}

	return -1 ;
}


GetItemAmountByExtraParam ( playerid, param ) {

	for ( new i; i < ReturnPlayerItemCount [ playerid ]; i ++ ) {

		if ( PlayerItem [ playerid ] [ i ] [ player_item_param2 ] == param ) { 

			return PlayerItem [ playerid ] [ i ] [ player_item_amount ] ;
		}
		
		else continue;
	}

	return -1 ;
}

GetTotalItemAmountByExtraParam ( playerid, param ) {

	new amount ;

	for ( new i; i < ReturnPlayerItemCount [ playerid ]; i ++ ) {

		if ( PlayerItem [ playerid ] [ i ] [ player_item_param2 ] == param ) { 

			amount += PlayerItem [ playerid ] [ i ] [ player_item_amount ] ;
		}
		
		else continue;
	}

	if ( amount ) { return amount ; }
	else return -1 ;
}

ReturnItemByParam ( playerid, paramid, bool: param ) {

	switch ( param ) {

		case false: {

			for ( new i; i < ReturnPlayerItemCount [ playerid ]; i ++ ) {
	
				if ( PlayerItem [ playerid ] [ i ] [ player_item_param1 ] == paramid ) {

					return i;
				}

				else continue ;
			}

		}

		case true: {

			for ( new i; i < ReturnPlayerItemCount [ playerid ]; i ++ ) {
	
				if ( PlayerItem [ playerid ] [ i ] [ player_item_param2 ] == paramid ) {

					return i;
				}

				else continue ;
			}

		}
	}

	return -1 ;
}

ReturnItemParam ( playerid, itemid, bool: param ) {

	switch ( param ) {

		case false: {

			for ( new i; i < ReturnPlayerItemCount [ playerid ]; i ++ ) {
	
				if ( PlayerItem [ playerid ] [ i ] [ player_item_id ] == itemid ) {

					return PlayerItem [ playerid ] [ i ] [ player_item_param1 ] ;
				}

				else continue ;
			}
		}

		case true: {

			for ( new i; i < ReturnPlayerItemCount [ playerid ]; i ++ ) {
	
				if ( PlayerItem [ playerid ] [ i ] [ player_item_id ] == itemid ) {

					return PlayerItem [ playerid ] [ i ] [ player_item_param2 ] ;
				}

				else continue ;
			}		
		}
	}

	return -1 ;
}

GetItemAmount ( playerid, itemid, itemparam1, itemparam2 ) {

	for ( new i; i < ReturnPlayerItemCount [ playerid ]; i ++ ) {
	
		if ( PlayerItem [ playerid ] [ i ] [ player_item_id ] == itemid && PlayerItem [ playerid ] [ i ] [ player_item_param1 ] == itemparam1 && PlayerItem [ playerid ] [ i ] [ player_item_param2 ] == itemparam2 ) {

			return PlayerItem [ playerid ] [ i ] [ player_item_amount ] ;
		}

		else continue ;
	}

	return -1 ;
}
