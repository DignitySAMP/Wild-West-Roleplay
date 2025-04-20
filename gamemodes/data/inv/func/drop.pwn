#if defined _inc_drop
	#undef _inc_drop
#endif

enum DroppedItemData {

	dropped_id,

	dropped_item,
	dropped_amount,

	dropped_param1,
	dropped_param2,


	// char id of dropper
	dropped_player, 

	Float: dropped_pos_x,
	Float: dropped_pos_y,
	Float: dropped_pos_z,

	dropped_int,
	dropped_vw,

	dropped_timestamp,

	// streamer
	dropped_object,
	DynamicText3D: dropped_label
}

new DroppedItem [ MAX_DROPPED_ITEMS ] [ DroppedItemData ] ; 
/*
public OnGameModeInit() {
	
	Init_LoadDropItems () ;

	#if defined drop_OnGameModeInit
		return drop_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif

#define OnGameModeInit drop_OnGameModeInit
#if defined drop_OnGameModeInit
	forward drop_OnGameModeInit();
#endif*/

GetFreeDropID ( ) {

	for ( new i; i < MAX_DROPPED_ITEMS; i ++ ) {

		if ( DroppedItem [ i ] [ dropped_id ] == INVALID_ITEM_ID ) {

			return i ;
		}

		else continue ;
	}

	return -1 ;
}

new PlayerDropTick [ MAX_PLAYERS ] ;
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

	if ( newkeys & KEY_WALK && IsPlayerNearDroppedItem ( playerid ) != INVALID_ITEM_ID ) {

		new temp_Tick = GetTickCount(), temp_tickDiff ;
		temp_tickDiff = temp_Tick - PlayerDropTick[playerid];

		if(temp_tickDiff < 5000) {
		
			return SendServerMessage ( playerid, sprintf("You must wait %0.2f seconds before picking something up again.", float(5000 - temp_tickDiff) / 1000.0), MSG_TYPE_ERROR ) ;
		}		

		PlayerDropTick[playerid] = GetTickCount();		

		new dropid = IsPlayerNearDroppedItem ( playerid ) ;

		WriteLog(playerid,"item/pickup",sprintf("%s picked up an item. (ID: %d) (%d,%d,%d,%d,%d)",ReturnUserName(playerid,true,false),DroppedItem [ dropid ] [ dropped_id ],DroppedItem [ dropid ] [ dropped_item ], DroppedItem [ dropid ] [ dropped_amount ], DroppedItem [ dropid ] [ dropped_param1 ], DroppedItem [ dropid ] [ dropped_param2 ]));

		GivePlayerItem ( playerid, DroppedItem [ dropid ] [ dropped_item ], DroppedItem [ dropid ] [ dropped_amount ], DroppedItem [ dropid ] [ dropped_param1 ], DroppedItem [ dropid ] [ dropped_param2 ], 0 ) ;

		new query [ 64 ] ;

		mysql_format ( mysql, query, sizeof ( query ), "DELETE FROM dropped_items WHERE dropped_id = %d", DroppedItem [ dropid ] [ dropped_id ] ) ;
		mysql_tquery ( mysql, query );

		Init_LoadDropItems () ;
	}
	
	#if defined drop_OnPlayerKeyStateChange
		return drop_OnPlayerKeyStateChange(playerid, newkeys, oldkeys );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif

#define OnPlayerKeyStateChange drop_OnPlayerKeyStateChange
#if defined drop_OnPlayerKeyStateChange
	forward drop_OnPlayerKeyStateChange(playerid, newkeys, oldkeys );
#endif

IsPlayerNearDroppedItem ( playerid ) {

	for ( new i; i < MAX_DROPPED_ITEMS; i ++ ) {

		if ( DroppedItem [ i ] [ dropped_id ] != INVALID_ITEM_ID ) {

			if ( IsPlayerInRangeOfPoint(playerid, 2,  DroppedItem [ i ] [ dropped_pos_x ], DroppedItem [ i ] [ dropped_pos_y ], DroppedItem [ i ] [ dropped_pos_z ] ) ) {

				return i ;
			}

			else continue ;
		}

		else continue ;
	}

	return INVALID_ITEM_ID ;
}

OnPlayerDropItem ( playerid, tileid ) {

	new dropid = GetFreeDropID ( ) ;

	if ( dropid == -1 ) {

		return SendServerMessage ( playerid, "There was an error returned by the drop handler (-1), contact a developer.", MSG_TYPE_ERROR ) ;
	}

	new param = GetItemByParamID ( FISHING_BOOT ) ;

	if ( PlayerItem [ playerid ] [ tileid ] [ player_item_id ] == param ) {

		SendServerMessage ( playerid, "You've tossed the dirty ol' boot away.", MSG_TYPE_INFO ) ;
		DiscardItem ( playerid, tileid ) ;

		return true ;
	}

	new Float: x, Float: y, Float: z, query [ 512 ] ;

	GetPlayerPos ( playerid, x, y, z ) ;
	//CA_FindZ_For2DCoord ( x, y, z ) ;

	mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO dropped_items (dropped_player, dropped_item, dropped_amount, dropped_param1, dropped_param2, dropped_pos_x, dropped_pos_y, dropped_pos_z, dropped_int, dropped_vw, dropped_timestamp) VALUES (%d, %d, %d, %d, %d, '%f', '%f', '%f', %d, %d, %d)",
	Character [ playerid ] [ character_id ], PlayerItem [ playerid ] [ tileid ] [ player_item_id ], PlayerItem [ playerid ] [ tileid ] [ player_item_amount ], PlayerItem [ playerid ] [ tileid ] [ player_item_param1 ], PlayerItem [ playerid ] [ tileid ] [ player_item_param2 ], x, y, z - 0.75, GetPlayerInterior ( playerid ), GetPlayerVirtualWorld ( playerid ), gettime() + 3600 ) ;

	mysql_tquery (mysql, query ) ;

	if(EquippedItem[playerid] != -1 && EquippedItemTile[playerid] == tileid) { //checking if item dropped was equipped

		RemovePlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP);
		EquippedItem[playerid] = -1;
		EquippedItemTile[playerid] = -1;
		UpdateWeaponGUI(playerid);
	}

	WriteLog(playerid,"item/drop",sprintf("%s dropped %d (%d) %s.  (%d,%d,%d,%d,%d,%.02f,%.02f,%.02f,%d,%d)",PlayerItem[playerid][tileid][player_item_amount],PlayerItem [ playerid ] [ tileid ] [ player_item_id ],Item[PlayerItem [ playerid ] [ tileid ] [ player_item_id ]][item_name],ReturnUserName(playerid,true,false),Character [ playerid ] [ character_id ], PlayerItem [ playerid ] [ tileid ] [ player_item_id ], PlayerItem [ playerid ] [ tileid ] [ player_item_amount ], PlayerItem [ playerid ] [ tileid ] [ player_item_param1 ], PlayerItem [ playerid ] [ tileid ] [ player_item_param2 ], x, y, z - 0.75, GetPlayerInterior ( playerid ), GetPlayerVirtualWorld ( playerid )));

	DiscardItem ( playerid, tileid ) ;
	Init_LoadDropItems () ;

	return true ;
}


Init_LoadDropItems () {

	new query [ 256 ] ;

	for ( new i; i < MAX_DROPPED_ITEMS; i ++ ) {
		if ( DroppedItem [ i ] [ dropped_id ] != INVALID_ITEM_ID ) {

			DroppedItem [ i ] [ dropped_id ] = INVALID_ITEM_ID ;


			if ( IsValidDynamicObject ( DroppedItem [ i ] [ dropped_object ] ) ) {
				DestroyDynamicObject( DroppedItem [ i ] [ dropped_object ]) ;
			}

			if ( IsValidDynamic3DTextLabel ( DroppedItem [ i ] [ dropped_label ] ) ) {
				DestroyDynamic3DTextLabel ( DroppedItem [ i ] [ dropped_label ] ) ;
			}
		}
	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM dropped_items" );
	mysql_tquery ( mysql, query, "LoadDroppedItemData", "") ;

	return true ;
}

forward LoadDroppedItemData ( ) ;
public LoadDroppedItemData ( ) {

	new rows, fields ;
	cache_get_data ( rows, fields, mysql ) ;

    if ( rows ) {
		print(" * [DROPPED ITEMS] Loading dropped items..." ) ; 

		for ( new i, j = rows; i < j; i ++ ) {
			if ( cache_get_field_int ( i, "dropped_id" ) == -1 || cache_get_field_int ( i, "dropped_item" ) == -1 ) {

				continue ;
			}

			DroppedItem [ i ] [ dropped_id ] 				= cache_get_field_int ( i, "dropped_id" ) ;

			DroppedItem [ i ] [ dropped_item ] 				= cache_get_field_int ( i, "dropped_item" ) ;
			DroppedItem [ i ] [ dropped_amount ] 			= cache_get_field_int ( i, "dropped_amount" ) ;

			DroppedItem [ i ] [ dropped_player ] 			= cache_get_field_int ( i, "dropped_player" ) ;

			DroppedItem [ i ] [ dropped_param1 ] 			= cache_get_field_int ( i, "dropped_param1" ) ;
			DroppedItem [ i ] [ dropped_param2 ] 			= cache_get_field_int ( i, "dropped_param2" ) ;

			DroppedItem [ i ] [ dropped_pos_x ] 			= cache_get_field_float ( i, "dropped_pos_x" ) ;
			DroppedItem [ i ] [ dropped_pos_y ] 			= cache_get_field_float ( i, "dropped_pos_y" ) ;
			DroppedItem [ i ] [ dropped_pos_z ] 			= cache_get_field_float ( i, "dropped_pos_z" ) ;

			DroppedItem [ i ] [ dropped_int ] 				= cache_get_field_int ( i, "dropped_int" ) ;
			DroppedItem [ i ] [ dropped_vw ] 				= cache_get_field_int ( i, "dropped_vw" ) ;

			DroppedItem [ i ] [ dropped_timestamp ]			= cache_get_field_int ( i, "dropped_timestamp" ) ;

			new Float: new_x, Float: new_y, Float: new_z, Float: rot_x, Float: rot_y, Float: rot_z;
			CA_RayCastLineAngle(DroppedItem [ i ] [ dropped_pos_x ], DroppedItem [ i ] [ dropped_pos_y ], DroppedItem [ i ] [ dropped_pos_z ] + 5.0, DroppedItem [ i ] [ dropped_pos_x ], DroppedItem [ i ] [ dropped_pos_y ], DroppedItem [ i ] [ dropped_pos_z ] - 5.0, 		new_x, new_y, new_z, rot_x, rot_y, rot_z);

			DroppedItem [ i ] [ dropped_object ] = CreateDynamicObject(
				Item [ DroppedItem [ i ] [ dropped_item ] ] [ item_model ], 
				DroppedItem [ i ] [ dropped_pos_x ], DroppedItem [ i ] [ dropped_pos_y ], DroppedItem [ i ] [ dropped_pos_z ] + 0.5,
				rot_x, rot_y, rot_z,
				DroppedItem [ i ] [ dropped_vw ], DroppedItem [ i ] [ dropped_int ] ) ;

			DroppedItem [ i ] [ dropped_label ] = CreateDynamic3DTextLabel(sprintf("[%d] [%s%s{A3A3A3}]{DEDEDE}\nPress ~k~~SNEAK_ABOUT~ to pick up.", DroppedItem [ i ] [ dropped_id ], GetRarityHex ( DroppedItem [ i ] [ dropped_item ] ), Item [ DroppedItem [ i ] [ dropped_item ] ] [ item_name ]), 0xA3A3A3AA, 
				DroppedItem [ i ] [ dropped_pos_x ], DroppedItem [ i ] [ dropped_pos_y ], DroppedItem [ i ] [ dropped_pos_z ] + 0.5,

				2.5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0,DroppedItem [ i ] [ dropped_vw ], DroppedItem [ i ] [ dropped_int ] ) ;


		}

		printf(" * [DROPPED ITEMS] Loaded %d dropped items", rows ) ; 

		//AutoClearDroppedItems();
    }

	return true ;
}

CMD:cleardroppeditems(playerid) {

	if ( ! IsPlayerManager ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a manager in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	for(new i=0; i<MAX_DROPPED_ITEMS; i++) {

		DroppedItem[i][dropped_timestamp] = 0;
	}
	SendServerMessage(playerid,"All dropped items will be cleared in a minute or less.",MSG_TYPE_INFO);
	return true;
}

task AutoClearDroppedItems[60000]() { //1 min

	new count = 0;
	for(new i=0; i<MAX_DROPPED_ITEMS; i++)  {

		if(DroppedItem [ i ] [ dropped_id ] == INVALID_ITEM_ID) { continue; }
		if(gettime() >= DroppedItem [ i ] [ dropped_timestamp ]) {

			new query [ 128 ] ;

			mysql_format ( mysql, query, sizeof ( query ), "DELETE FROM dropped_items WHERE dropped_id = %d", DroppedItem [ i ] [ dropped_id ] ) ;
			mysql_tquery ( mysql, query );

			count++;
			continue;
		}
		else { continue; }
	}

	if(count) { 

		printf(" * [DROPPED ITEMS] Removed %d items",count); 
		Init_LoadDropItems () ;
	}
	return true;
}