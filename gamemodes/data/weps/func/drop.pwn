
#define MAX_DROPPED_WEAPONS 	( 150 )
new DroppedWeapon 		[ MAX_DROPPED_WEAPONS ] ;
new DroppedWeaponAmmo 	[ MAX_DROPPED_WEAPONS ] ;

FindEmptyDroppedGunSlot() {

	for(new i=0; i < MAX_DROPPED_WEAPONS; i++) {

		if(DroppedWeapon[i] == -1) { return i; }
	}
	return -1;
}

CMD:dropgun ( playerid, params [] ) {

	if ( ! Character [ playerid ] [ character_handweapon ] ) {

		return SendServerMessage ( playerid, "You're not holding a weapon you can drop!", MSG_TYPE_ERROR ) ;
	}

	if ( Character [ playerid ] [ character_handweapon ] == WEAPON_CAMERA ) {

		return SendServerMessage ( playerid, "You can't do this with an inventory item. Unequip it to get rid of it.", MSG_TYPE_ERROR ) ;
	}

	if ( IsPlayerRidingHorse [ playerid ] ) {

		return SendServerMessage ( playerid, "You're riding on a horse. Dismount first.", MSG_TYPE_ERROR ) ;
	}

	new emptyslot = FindEmptyDroppedGunSlot () ;

	new Float: pos_x, Float: pos_y, Float: pos_z ;
	GetPlayerPos ( playerid, pos_x, pos_y, pos_z ) ;
	//CA_FindZ_For2DCoord( pos_x, pos_y, pos_z ) ;

	ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s has dropped their %s on the floor.", ReturnUserName ( playerid, false ), ReturnWeaponName ( Character [ playerid ] [ character_handweapon ] ) ) ) ;

	if(IsPlayerInPosse ( playerid ) && IsLawEnforcementPosse ( Character [ playerid ] [ character_posse ] )) {

		if(IsSheriffOnDuty(playerid)) {

			SendModeratorWarning(sprintf("[Dropped Gun]: %s (%d) has dropped their %s with %d ammo while on duty, spectate them immediately!",ReturnUserName(playerid,false,false),playerid,ReturnWeaponName ( Character [ playerid ] [ character_handweapon ] ), Character [ playerid ] [ character_handammo ]),MOD_WARNING_MED);
			WriteLog(playerid,"guns/sheriff",sprintf("%s (%d) has dropped their %s with %d ammo while on duty.",ReturnUserName(playerid,false,false),playerid,ReturnWeaponName ( Character [ playerid ] [ character_handweapon ] ), Character [ playerid ] [ character_handammo ]));
		}
		else { WriteLog ( playerid, "guns/ammo", sprintf ( "%s has dropped their %s with %d ammo.", ReturnUserName ( playerid, false, false ), ReturnWeaponName ( Character [ playerid ] [ character_handweapon ] ), Character [ playerid ] [ character_handammo ] )) ; }
	}
	else { WriteLog ( playerid, "guns/ammo", sprintf ( "%s has dropped their %s with %d ammo.", ReturnUserName ( playerid, false, false ), ReturnWeaponName ( Character [ playerid ] [ character_handweapon ] ), Character [ playerid ] [ character_handammo ] )) ; }

	SendServerMessage(playerid, "WARNING: Dropped guns do NOT save! Keep this in mind before leaving your gun alone.", MSG_TYPE_ERROR ) ;

	DroppedWeapon 		[ emptyslot ] 		= CreateDynamicObject( ReturnWeaponObjectEx ( Character [ playerid ] [ character_handweapon ] ), pos_x, pos_y, pos_z - 0.9, 90, 0, 45, GetPlayerVirtualWorld ( playerid ), GetPlayerInterior ( playerid ) ) ;
	DroppedWeaponAmmo 	[ emptyslot ] 		= Character [ playerid ] [ character_handammo ] ;

	Streamer_ToggleItemStatic(STREAMER_TYPE_OBJECT,DroppedWeapon[emptyslot],1);

	RemovePlayerWeapon ( playerid ); 
	SavePlayerWeapons ( playerid ) ;

	return true ;
}

CMD:dg ( playerid, params [] ) {

	return cmd_dropgun ( playerid, params ) ;
}

CMD:pickupgun ( playerid, params [] ) {

	if ( Character [ playerid ] [ character_handweapon ] ) {

		return SendServerMessage ( playerid, "You're already holding a weapon!", MSG_TYPE_ERROR ) ;
	}

	if ( Character [ playerid ] [ character_handweapon ] == WEAPON_CAMERA ) {

		return SendServerMessage ( playerid, "You can't do this with an inventory item. Unequip it to get rid of it.", MSG_TYPE_ERROR ) ;
	}

	if ( GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK ) {

		return SendServerMessage ( playerid, "You need to crouch in order to pick up a weapon.", MSG_TYPE_ERROR ) ;
	}

	if ( IsPlayerRidingHorse [ playerid ] ) {

		return SendServerMessage ( playerid, "You're riding on a horse. Dismount first.", MSG_TYPE_ERROR ) ;
	}

	new Float: pos_x, Float: pos_y, Float: pos_z, modelid, weaponid, ammo ;

	for ( new i; i < MAX_DROPPED_WEAPONS; i ++ ) {

		if ( IsValidDynamicObject( DroppedWeapon [ i ] ) ) {
			GetDynamicObjectPos ( DroppedWeapon [ i ], pos_x, pos_y, pos_z ) ;

			if ( IsPlayerInRangeOfPoint(playerid, 1.5, pos_x, pos_y, pos_z ) ) {


				modelid = GetDynamicObjectModel ( DroppedWeapon [ i ] ) ;
				weaponid = ReturnWeaponIDFromModel ( modelid ) ;
				ammo = DroppedWeaponAmmo [ i ] ;

				if ( modelid == 65535 || DroppedWeapon [ i ] == 65535 ) {
					printf("Invalid model: %d, dropped gun: %d, %d", modelid, DroppedWeapon [ i ], i ) ;
				}

				wep_GivePlayerWeapon ( playerid, weaponid, ammo ) ;

				if ( IsValidDynamicObject(DroppedWeapon [ i ])) {
					DestroyDynamicObject(DroppedWeapon [ i ] ) ;
					DroppedWeapon [ i ] = -1 ;
					DroppedWeaponAmmo [ i ] = 0 ;
				}

				ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s has picked up a %s from the floor.", ReturnUserName ( playerid, true ), ReturnWeaponName ( weaponid ) ) ) ;
				// SendClientMessage(playerid, -1, sprintf("You picked up a (%d) %s with %d ammo. (drop id %d)", modelid, ReturnWeaponName ( weaponid), ammo, i ) ) ;
				
				WriteLog ( playerid, "guns/ammo", sprintf ( "%s has picked up a %s with %d ammo.", ReturnUserName ( playerid, false ), ReturnWeaponName ( weaponid ), Character [ playerid ] [ character_handammo ] )) ;
				SavePlayerWeapons ( playerid ) ;
				
				return true ;
			}

			else continue ;

			//else return SendServerMessage ( playerid, "You're not near any valid weapon.", MSG_TYPE_ERROR ) ;
		}

		else continue;
	}

	return true ;
}


CMD:pg ( playerid, params [] ) {

	return cmd_pickupgun ( playerid, params ) ;
}
