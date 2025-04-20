#define MAX_DYNAMITE	( 100)
new Dynamite [ MAX_DYNAMITE ] ;
new DynamicText3D: DynamiteInfo [ MAX_DYNAMITE ] ;
new DynamiteTimer [ MAX_DYNAMITE ] ;

GetFreeDynamiteSlot ( ) {

	new i = 0;

	while ( i < sizeof ( Dynamite ) && Dynamite [ i ] != -1 ) {
		i++;
	}

	if ( i == sizeof (Dynamite ) ) return -1;

	return i;
}


SetupDynamiteData () {

	for ( new i; i < MAX_DYNAMITE; i ++ ) {

		Dynamite [ i ] = -1 ;
	}
}

CMD:dynamite ( playerid, params [] ) {

	if ( EquippedItem [ playerid ] != DYNAMITE ) {

		return SendServerMessage ( playerid, "You need to have your dynamite equipped before you can do this.", MSG_TYPE_ERROR ) ;
	}

	new value ;

	if ( sscanf ( params, "i", value ) ) {

		return SendServerMessage ( playerid, "/dynamite [time]", MSG_TYPE_ERROR ) ;
	}

	if ( value < 5 || value > 30 ) {

		return SendServerMessage ( playerid, "Dynamite timer can't be lower than 5 seconds or higher than 30.", MSG_TYPE_ERROR ) ;
	}

	new Float: player_x,  Float: player_y,  Float: player_z ;

	GetPlayerPos ( playerid, player_x, player_y, player_z  ) ;
	GetXYInFrontOfPlayer ( playerid, player_x, player_y, 2.0 ) ;

	new d_id = GetFreeDynamiteSlot ( ) ;

	if ( d_id == -1 ) {

		return SendServerMessage ( playerid, "Failed to plant dynamite. Tell an admin to do /refreshdynamite.", MSG_TYPE_ERROR ) ;
	} 

	DynamiteTimer [ d_id ] = value ;

	ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 0, 0, 0, 0, 0, 1);
	Dynamite [ d_id ] = CreateDynamicObject(1654, player_x, player_y, player_z - 0.80, 0.0, 0.0, 0.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid) ) ;
	DynamiteInfo [ d_id ] = CreateDynamic3DTextLabel(sprintf("[DYNAMITE: %d]\n{DEDEDE}%d seconds left\nuntil explosion.", d_id, DynamiteTimer [d_id ] ), 0xDB3232FF, player_x, player_y, player_z - 0.80, 20.0, 
		INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid) ) ;

	SendServerMessage ( playerid, sprintf("Your dynamite has been set. It will explode in %d seconds.", value ), MSG_TYPE_INFO) ;
	SendClientMessage(playerid, COLOR_ACTION, sprintf("* %s has planted a set of dynamite.", ReturnUserName ( playerid, false )) ) ;
 
	defer Dynamite_Explode(d_id ) ;

	////////////////////////////////////////
	///// Cleaning up for inventory script:
	////////////////////////////////////////

	RemovePlayerAttachedObject(playerid, 6 ) ;
	EquippedItem [ playerid ] = -1 ;
	
	new tileid = EquippedItemTile [ playerid ] ;

	if ( tileid != -1 && -- PlayerItem [ playerid ] [ tileid ] [ player_item_amount ] <= 0 ) {

		DiscardItem ( playerid, tileid ) ;

		SendServerMessage ( playerid, "You've used your last set of dynamite.", MSG_TYPE_WARN ) ;
	}

	new query [ 256 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE items_player SET player_item_amount = '%d' WHERE player_table_id = %d AND player_database_id = '%d'", 
		PlayerItem [ playerid ] [ tileid ] [ player_item_amount ], PlayerItem [ playerid ] [ tileid ] [ player_table_id ], Character [ playerid ] [ character_id ] ) ; 
	mysql_tquery ( mysql, query ) ;

	HideInventoryExamineGUI ( playerid ) ;
	ToggleInventory ( playerid, INV_MAX_TILES, false ) ;
	UpdateWeaponGUI ( playerid ) ;

	EquippedItemTile [ playerid ] = -1 ;

	return true ;
}

timer Dynamite_Explode[1000](d_id) {

////	print("Dynamite_Explode timer called (dynamite.pwn)");

	if ( DynamiteTimer [d_id ] <= 0 ) {

		return false ;
	}

	if ( -- DynamiteTimer [d_id ] == 0 ) {

		new Float: dyn_x, Float: dyn_y, Float: dyn_z ;
		GetDynamicObjectPos(Dynamite [ d_id ], dyn_x, dyn_y, dyn_z ) ;

		CreateExplosion(dyn_x, dyn_y, dyn_z, 2, 25.0 ) ;

		foreach ( new playerid : Player ) {

			if ( ! IsPlayerInRangeOfPoint ( playerid, 25.0, dyn_x, dyn_y, dyn_z ) ) continue;

			HandleExplosion ( playerid, dyn_x, dyn_y, dyn_z ) ;
		}

		if ( IsValidDynamicObject ( Dynamite [ d_id ] ) ) {
			DestroyDynamicObject(Dynamite [ d_id ]) ;
		}

		if ( IsValidDynamic3DTextLabel(DynamiteInfo [d_id])) {
			DestroyDynamic3DTextLabel(DynamiteInfo [d_id]) ;
		}

		Dynamite [ d_id ] = -1 ;

	}

	UpdateDynamic3DTextLabelText(DynamiteInfo [d_id], 0xDB3232FF, sprintf("[DYNAMITE: %d]\n{DEDEDE}%d seconds left\nuntil explosion.", d_id, DynamiteTimer [d_id ] ) ) ;

	defer Dynamite_Explode(d_id) ;
	return true ;
}