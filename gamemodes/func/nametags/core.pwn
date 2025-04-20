new DynamicText3D: nametag [ MAX_PLAYERS ] ;
Nametags_Init () {

	for ( new i; i < MAX_PLAYERS; i ++ ) {

		nametag [ i ] = CreateDynamic3DTextLabel("", 0xCFCFCFFF, 0.0, 0.0, 0.15, 15, i, INVALID_VEHICLE_ID, 1, -1, -1, -1, 15 ) ;
	}

}

SetName ( playerid, name[], color ) {

	UpdateDynamic3DTextLabelText(nametag[playerid], color, name ) ;
	//SendClientMessage(playerid, color, sprintf("Set name to \"%s\"", name )) ;
	return true ;
}