#define MAX_GUNSHELLS	( 150 )

enum gs_Data {

	gs_UsedID,

	gs_Object,
	DynamicText3D: gs_Label,

	gs_Shooter [ MAX_PLAYER_NAME + 2 ],
	gs_WeaponID

}

new GunShell [ MAX_GUNSHELLS ] [ gs_Data ], gs_Count ;

ClearGunShells () {
	for ( new i; i < MAX_GUNSHELLS; i ++ ) {

		GunShell [ i ] [ gs_UsedID ] = 0 ;
		strcat ( GunShell [ i ] [ gs_Shooter ], "Unknown", MAX_PLAYER_NAME ) ;

		SetDynamicObjectPos ( GunShell [ i ] [ gs_Object ], 0.0, 0.0, 0.0 ) ;
		SetDynamicObjectMaterial(GunShell [ i ] [ gs_Object ], 0, 2061, "CJ_AMMO", "CJ_BULLETBRASS");

		if ( IsValidDynamic3DTextLabel ( GunShell [ i ] [ gs_Label ] ) ) {

			DestroyDynamic3DTextLabel ( GunShell [ i ] [ gs_Label ] ) ;
		}
	}

	return true ;
}

GunShells_Init () {

	for ( new i; i < MAX_GUNSHELLS; i ++ ) {

		GunShell [ i ] [ gs_UsedID ] = 0 ;
		strcat ( GunShell [ i ] [ gs_Shooter ], "Unknown", MAX_PLAYER_NAME ) ;

		GunShell [ i ] [ gs_Object ] = CreateDynamicObject(1666, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1 ) ;
		SetDynamicObjectMaterial(GunShell [ i ] [ gs_Object ], 0, 2061, "CJ_AMMO", "CJ_BULLETBRASS");
	}

	return true ;
}

CreatePlayerGunShell ( playerid ) {

	if ( gs_Count ++ >= MAX_GUNSHELLS ) {

		gs_Count = 0 ;
	}

	new string [ 128 ], Float: x, Float: y, Float: z ;
	GetPlayerPos ( playerid, x, y, z ) ;

	switch ( GetPlayerWeapon ( playerid ) ) {

		case WEAPON_DEAGLE: 	format ( string, sizeof ( string ), 	"{CFC097}.44-40 WCF shell" ) ;
		case WEAPON_SHOTGUN:	format ( string, sizeof ( string ), 	"{CFB497}16 gauge cartridge" ) ;
		case WEAPON_SAWEDOFF:	format ( string, sizeof ( string ), 	"{CFA797}12 gauge cartridge" ) ;
		case WEAPON_RIFLE:		format ( string, sizeof ( string ), 	"{CF9C97}.56-56 Spencer" ) ;
		case WEAPON_SNIPER: 	format ( string, sizeof ( string ), 	"{BDCF97}.58 Berdan" ) ;
	}

	GunShell [ gs_Count ] [ gs_UsedID ] = gs_Count ;
	GunShell [ gs_Count ] [ gs_Shooter ] [ 0 ] = EOS ;

	GunShell [ gs_Count ] [ gs_WeaponID ] = GetPlayerWeapon ( playerid ) ;

	strcat(GunShell [ gs_Count ] [ gs_Shooter ], ReturnUserName ( playerid ), MAX_PLAYER_NAME ) ;

	if ( IsValidDynamic3DTextLabel ( GunShell [ gs_Count ] [ gs_Label ] ) ) {

		DestroyDynamic3DTextLabel ( GunShell [ gs_Count ] [ gs_Label ] ) ;
	}

	GunShell [ gs_Count ] [ gs_Label ] = CreateDynamic3DTextLabel(sprintf("[SHELL %d]\n(( /shell ))", GunShell [ gs_Count ] [ gs_UsedID ]), 0xDEDEDEAA, x, y, z - 0.8, 2.5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, GetPlayerVirtualWorld ( playerid ), GetPlayerInterior ( playerid ) ) ;

	new Float: new_x, Float: new_y, Float: new_z, Float: rot_x, Float: rot_y, Float: rot_z;

	CA_RayCastLineAngle(x, y, z + 5.0, 	x, y, z - 5.0, 		new_x, new_y, new_z, rot_x, rot_y, rot_z);

	SetDynamicObjectPos(GunShell [ gs_Count ] [ gs_Object ], x, y, z - 0.9 ) ;
	SetDynamicObjectRot(GunShell [ gs_Count ] [ gs_Object ], rot_x, rot_y + 90, rot_z);

	//GunShells [ id ] = CreateDynamic3DTextLabel(sprintf("Bullet Shell\n%s", string), 0xDEDEDEAA, x, y, z - 0.7, 3, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, GetPlayerVirtualWorld ( playerid ), GetPlayerInterior ( playerid ) ) ;

	return true ;
}

CMD:shell ( playerid, params [] ) {

	new Float: x, Float: y, Float: z, string [ 32 ] ;

	for ( new i; i < MAX_GUNSHELLS; i ++ ) {

		GetDynamicObjectPos( GunShell [ i ] [ gs_Object ], x, y, z) ;

		if ( ! IsPlayerInRangeOfPoint(playerid, 2.5, x, y, z )) {

			continue ;
		}

		switch ( GunShell [ i ] [ gs_WeaponID ] ) {

			case WEAPON_DEAGLE: 	format ( string, sizeof ( string ), 	"{CFC097}.44-40 WCF shell" ) ;
			case WEAPON_SHOTGUN:	format ( string, sizeof ( string ), 	"{CFB497}16 gauge cartridge" ) ;
			case WEAPON_SAWEDOFF:	format ( string, sizeof ( string ), 	"{CFA797}12 gauge cartridge" ) ;
			case WEAPON_RIFLE:		format ( string, sizeof ( string ), 	"{CF9C97}.56-56 Spencer" ) ;
			case WEAPON_SNIPER: 	format ( string, sizeof ( string ), 	"{BDCF97}.58 Berdan" ) ;
		}

		SendClientMessage(playerid, COLOR_TAB0, "Gunshell Information" ) ;
		SendClientMessage(playerid, COLOR_TAB1, sprintf("[Gun shell: %d, %d, %s{BA9E72}]", i, GunShell [ i ] [ gs_UsedID ], string) ) ;
		if(IsPlayerModerator(playerid) && GetStaffGroup(playerid) >= BASIC_MOD) { SendClientMessage(playerid, COLOR_TAB2, sprintf("(( Fired by: %s ))", GunShell [ i ] [ gs_Shooter ] )) ; }

		return true ;
	}

	return SendServerMessage ( playerid, "You're not near a gun shell.", MSG_TYPE_ERROR ) ;
}