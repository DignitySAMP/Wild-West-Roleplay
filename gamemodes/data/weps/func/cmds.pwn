#define MAX_STORED_WEAPONS	( 3 )

CMD:passgun ( playerid, params [] ) {
	if ( ! Character [ playerid ] [ character_handweapon ] ) {

		return SendServerMessage ( playerid, "You're not holding a weapon you can switch!", MSG_TYPE_ERROR ) ;
	}

	if ( EquippedItem [ playerid ] != -1 ) {

		return SendServerMessage ( playerid, "You can't do this with an inventory item. Unequip it to get rid of it.", MSG_TYPE_ERROR ) ;
	}

	new target ;

	if ( sscanf ( params, "k<u>", target ) ) {

		return SendServerMessage ( playerid, "/passgun [target]", MSG_TYPE_ERROR ) ;
	}

	if ( target == INVALID_PLAYER_ID ) {

		return SendServerMessage ( playerid, "This player doesn't exist.", MSG_TYPE_ERROR ) ;
	}

	if ( Character [ target ] [ character_level ] < 3) {

		return SendServerMessage ( playerid, "Target's level is too low. It should be at least 3", MSG_TYPE_ERROR ) ;
	}

	if (  Character [ target ] [ character_handweapon ] ) {

		return SendServerMessage ( playerid, "Your target is already holding a weapon!", MSG_TYPE_ERROR ) ;
	}

	if (EquippedItem [ target ] != -1 ) {

		return SendServerMessage ( playerid, "Your target already has something equipped. Tell them to unequip it.", MSG_TYPE_ERROR ) ;
	}

	if ( IsPlayerRidingHorse [ target ] ) {

		return SendServerMessage ( playerid, "Your target is riding on a horse. Tell them to dismount first.", MSG_TYPE_ERROR ) ;
	}

 	if (!IsPlayerNearPlayer(playerid, target, 6.0)) {

	    return SendServerMessage(playerid, "You are not near that player.", MSG_TYPE_ERROR);
    }

    // Only do anim if they're close to the player to avoid abuse
    if ( IsPlayerNearPlayer ( playerid, target, 2.0 ) ) {
		SetPlayerToFacePlayer(target, playerid);
		SetPlayerToFacePlayer(playerid, target);

		ApplyAnimation(target, "GANGS", "prtial_hndshk_biz_01", 4.0, 0, 0, 0, 0, 0, 1);
		ApplyAnimation(playerid, "GANGS", "prtial_hndshk_biz_01", 4.0, 0, 0, 0, 0, 0, 1);
	}

	new passedgun, passedammo ;

	passedgun = Character [ playerid ] [ character_handweapon ] ;
	passedammo = Character [ playerid ] [ character_handammo ] ;

	RemovePlayerWeapon ( playerid ) ;
	wep_GivePlayerWeapon ( target, passedgun, passedammo ) ;

	ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s has given their %s to %s.", ReturnUserName ( playerid, false, true ), ReturnWeaponName ( passedgun ), ReturnUserName ( target, false, true )) ) ;

	new deter [ 64 ] ;

	if ( GetPosseType ( Character [ playerid ] [ character_posse ] ) == 1 || GetPosseType ( Character [ playerid ] [ character_posse ] ) == 2 ) {

		SendModeratorWarning ( sprintf ( "[SHERIFF] %s has passed their %s with %d ammo to %s", ReturnUserName ( playerid, false ), ReturnWeaponName (passedgun ), passedammo, ReturnUserName ( target, true ) ), MOD_WARNING_HIGH ) ;

		strins(deter, "[SHERIFF]", 0 ) ;
	}

	if ( DoesPlayerHaveItem ( playerid, CARD_GUNPERMIT ) != -1 ) {

		strins(deter, "[PERMIT] ", 0 ) ;
	}

	WriteLog ( playerid, "guns/pass", sprintf ( "%s %s has passed their %s with %d ammo to %s", deter, ReturnUserName ( playerid, false ), ReturnWeaponName (passedgun ), passedammo, ReturnUserName ( target, true ) )) ;

	new query [ 256 ] ; 

	mysql_format ( mysql, query, sizeof ( query ), 
		"UPDATE characters SET character_handweapon = %d, character_handammo = %d WHERE character_id = %d", 
		Character [ playerid ] [ character_handweapon ], Character [ playerid ] [ character_handammo ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	mysql_format ( mysql, query, sizeof ( query ), 
		"UPDATE characters SET character_handweapon = %d, character_handammo = %d WHERE character_id = %d", 
		Character [ target ] [ character_handweapon ], Character [ target ] [ character_handammo ], Character [ target ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	SavePlayerWeapons ( playerid ) ;
	SavePlayerWeapons ( target ) ;

	return true ;
}

CMD:switchgun ( playerid, params [] ) {

	if ( ! Character [ playerid ] [ character_handweapon ] ) {

		return SendServerMessage ( playerid, "You're not holding a weapon you can switch!", MSG_TYPE_ERROR ) ;
	}

	if ( EquippedItem [ playerid ] != -1 ) {

		return SendServerMessage ( playerid, "You can't do this with an inventory item. Unequip it to get rid of it.", MSG_TYPE_ERROR ) ;
	}

	if (EquippedItem [ playerid ] != -1 ) {

		return SendServerMessage ( playerid, "You already have something equipped. Unequip it first.", MSG_TYPE_ERROR ) ;
	}

	if ( IsPlayerRidingHorse [ playerid ] ) {

		return SendServerMessage ( playerid, "You're riding on a horse. Dismount first.", MSG_TYPE_ERROR ) ;
	}

	new storedGun, storedAmmo;

	if ( ! strcmp(params, "trousers", true ) ) { // slot 0

		if ( ! Character [ playerid ] [ character_pantsweapon ]) {

			return SendServerMessage ( playerid, "There isn't a weapon stored in your trouser slot!", MSG_TYPE_WARN ) ;
		}

		storedGun = Character [ playerid ] [ character_handweapon ] ;
		storedAmmo = Character [ playerid ] [ character_handammo ] ;

		RemovePlayerWeapon ( playerid ) ;

//		SendClientMessage(playerid, 0xA39F60AA, sprintf("[WEAPON]{ffffff} You've unholstered a {A39F60}%s{ffffff} with %d ammo.", ReturnWeaponName ( Character [ playerid ] [ character_pantsweapon ] ), Character [ playerid ] [ character_pantsammo ] ) ) ;
		ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s switched their %s with a %s from their trousers.", ReturnUserName ( playerid, false, true ), ReturnWeaponName ( storedGun ), ReturnWeaponName ( Character [ playerid ] [ character_pantsweapon ] ) ) ) ;
		//OldLog ( playerid, "guns/switch", sprintf ( "%s has switched their %s(%d) with a %s(%d)", ReturnUserName ( playerid, false ), ReturnWeaponName ( storedGun ), storedAmmo, ReturnWeaponName ( Character [ playerid ] [ character_pantsweapon ]), Character [ playerid ] [ character_pantsammo ]  )) ;

		wep_GivePlayerWeapon ( playerid, Character [ playerid ] [ character_pantsweapon ] , Character [ playerid ] [ character_pantsammo ]  ) ;

		Character [ playerid ] [ character_pantsweapon ] = storedGun ;
		Character [ playerid ] [ character_pantsammo ] = storedAmmo ;
	}

	else if ( ! strcmp(params, "back", true ) ) { // slot 1

		if ( ! Character [ playerid ] [ character_backweapon ] ) {

			return SendServerMessage ( playerid, "There isn't a weapon stored in your back slot!", MSG_TYPE_WARN ) ;
		}

		storedGun = Character [ playerid ] [ character_handweapon ] ;
		storedAmmo = Character [ playerid ] [ character_handammo ] ;

		RemovePlayerWeapon ( playerid ) ;

//		SendClientMessage(playerid, 0xA39F60AA, sprintf("[WEAPON]{ffffff} You've unholstered a {A39F60}%s{ffffff} with %d ammo.", ReturnWeaponName ( Character [ playerid ] [ character_backweapon ] ),Character [ playerid ] [ character_backammo ] ) ) ;
		ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s switched their %s with a %s from their back.", ReturnUserName ( playerid, false, true ), ReturnWeaponName ( storedGun ), ReturnWeaponName ( Character [ playerid ] [ character_backweapon ] ) ) ) ;
		//OldLog ( playerid, "guns/switch", sprintf ( "%s has switched their %s(%d) with a %s(%d)", ReturnUserName ( playerid, false ), ReturnWeaponName ( storedGun ), storedAmmo, ReturnWeaponName ( Character [ playerid ] [ character_backweapon ]), Character [ playerid ] [ character_backammo ]  )) ;

		wep_GivePlayerWeapon ( playerid, Character [ playerid ] [ character_backweapon ], Character [ playerid ] [ character_backammo ]  ) ;	

		Character [ playerid ] [ character_backweapon ] = storedGun ;
		Character [ playerid ] [ character_backammo ] = storedAmmo ;	
	}

	else return SendServerMessage ( playerid, "/switchgun [trousers | back | chest]", MSG_TYPE_ERROR ) ;

	SavePlayerWeapons ( playerid ) ;

	return true ;
}

CMD:sgun ( playerid, params [] ) {

	return cmd_switchgun ( playerid, params ) ;
}

CMD:holstered ( playerid ) {

	SendClientMessage (playerid, COLOR_TAB0, "|_____________________| List of your holstered weapons |_____________________| " ) ;


	if ( Character [ playerid ] [ character_handweapon ] ) {
		SendClientMessage(playerid, COLOR_TAB1, sprintf("[EQUIPPED]{DEDEDE} %s (%d)", ReturnWeaponName ( Character [ playerid ] [ character_handweapon ] ), Character [ playerid ] [ character_handammo ] ));
	}

	else SendClientMessage(playerid, COLOR_TAB1, "[EQUIPPED]{DEDEDE} Empty" ) ;



	if ( Character [ playerid ] [ character_pantsweapon ] ) {
		SendClientMessage(playerid, COLOR_TAB1, sprintf("[TROUSERS]{DEDEDE} %s (%d)", ReturnWeaponName ( Character [ playerid ] [ character_pantsweapon ] ), Character [ playerid ] [ character_pantsammo ] ));
	}

	else SendClientMessage(playerid, COLOR_TAB1, "[TROUSERS]{DEDEDE} Empty" ) ;



	if ( Character [ playerid ] [ character_backweapon ] ) {
		SendClientMessage(playerid, COLOR_TAB2, sprintf("[BACK]{DEDEDE} %s (%d)", ReturnWeaponName ( Character [ playerid ] [ character_backweapon ] ), Character [ playerid ] [ character_backammo ] ));
	}

	else SendClientMessage(playerid, COLOR_TAB2, "[BACK]{DEDEDE} Empty" ) ;

	return true ;
}

CMD:gunpos ( playerid, params [] ) {

	if ( ! strcmp(params, "trousers", true ) ) { // slot 0

		if ( ! Character [ playerid ] [ character_pantsweapon ]) {

			return SendServerMessage ( playerid, "There isn't a weapon stored in your trouser slot!", MSG_TYPE_WARN ) ;
		}

		EditAttachedObject(playerid, ATTACH_SLOT_PANTS   ) ;
	}

	else if ( ! strcmp(params, "back", true ) ) { // slot 1

		if ( ! Character [ playerid ] [ character_backweapon ] ) {

			return SendServerMessage ( playerid, "There isn't a weapon stored in your back slot!", MSG_TYPE_WARN ) ;
		}

		EditAttachedObject(playerid, ATTACH_SLOT_BACK  ) ;
	}

	else return SendServerMessage ( playerid, "/gunpos [trousers, back]", MSG_TYPE_ERROR ) ;


	return true ;
}

CMD:guns ( playerid, params [] ) {

	return cmd_holstered ( playerid ) ;
}

CMD:unholster ( playerid, params [] ) {

	if ( Character [ playerid ] [ character_handweapon ] ) {

		return SendServerMessage ( playerid, "You're already holding a weapon. Holster it first by using /holster!", MSG_TYPE_ERROR ) ;
	}

	if ( EquippedItem [ playerid ] != -1 ) {

		return SendServerMessage ( playerid, "You can't do this with an inventory item. Unequip it to get rid of it.", MSG_TYPE_ERROR ) ;
	}

	if (EquippedItem [ playerid ] != -1 ) {

		return SendServerMessage ( playerid, "You already have something equipped. Unequip it first.", MSG_TYPE_ERROR ) ;
	}

	if ( IsPlayerRidingHorse [ playerid ] ) {

		return SendServerMessage ( playerid, "You're riding on a horse. Dismount first.", MSG_TYPE_ERROR ) ;
	}


	printf("unholster called: %d, %d", Character [ playerid ] [ character_handweapon], Character [ playerid ] [ character_handammo] ) ;

	if ( ! strcmp(params, "trousers", true ) ) { // slot 0

		if ( ! Character [ playerid ] [ character_pantsweapon ]) {

			return SendServerMessage ( playerid, "There isn't a weapon stored in your trouser slot!", MSG_TYPE_WARN ) ;
		}

		wep_GivePlayerWeapon ( playerid, Character [ playerid ] [ character_pantsweapon ] , Character [ playerid ] [ character_pantsammo ]  ) ;
		ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s unholsters their %s from their trousers.", ReturnUserName ( playerid, false, true ), ReturnWeaponName ( Character [ playerid ] [ character_handweapon ] ) ) ) ;

		Character [ playerid ] [ character_pantsweapon ] = 0 ;
		Character [ playerid ] [ character_pantsammo ] = 0 ;

		//OldLog ( playerid, "guns/holster", sprintf ( "%s has unholstered %s(%d) from their trousers slot", ReturnUserName ( playerid, false ), ReturnWeaponName ( Character [ playerid ] [ character_handweapon ]  ), Character [ playerid ] [ character_handammo ]  )) ;
	}

	else if ( ! strcmp(params, "back", true ) ) { // slot 1

		if ( ! Character [ playerid ] [ character_backweapon ] ) {

			return SendServerMessage ( playerid, "There isn't a weapon stored in your back slot!", MSG_TYPE_WARN ) ;
		}

		wep_GivePlayerWeapon ( playerid, Character [ playerid ] [ character_backweapon ], Character [ playerid ] [ character_backammo ]  ) ;
		ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s unholsters their %s from their back.", ReturnUserName ( playerid, false, true ), ReturnWeaponName ( Character [ playerid ] [ character_handweapon ] ) ) ) ;

		Character [ playerid ] [ character_backweapon ] = 0 ;
		Character [ playerid ] [ character_backammo ] = 0 ;

		//OldLog ( playerid, "guns/holster", sprintf ( "%s has unholstered %s(%d) from their back slot", ReturnUserName ( playerid, false ), ReturnWeaponName ( Character [ playerid ] [ character_handweapon ]  ), Character [ playerid ] [ character_handammo ]  )) ;
	}

	else return SendServerMessage ( playerid, "/unholster [trousers | back]", MSG_TYPE_ERROR ) ;

	SavePlayerWeapons ( playerid ) ;

	return true ;
}

CMD:guh(playerid, params [] ) {

	return cmd_unholster ( playerid, params ) ;
}

CMD:holster ( playerid, params [] ) {

	if ( ! Character [ playerid ] [ character_handweapon ]) {

		return SendServerMessage ( playerid, "You don't have a weapon to store!", MSG_TYPE_ERROR ) ;
	}

	if ( IsPlayerRidingHorse [ playerid ] ) {

		return SendServerMessage ( playerid, "You're riding on a horse. Dismount first.", MSG_TYPE_ERROR ) ;
	}

	if ( EquippedItem [ playerid ] != -1 ) {

		return SendServerMessage ( playerid, "You can't do this with an inventory item. Unequip it to get rid of it.", MSG_TYPE_ERROR ) ;
	}
	
	if ( ! strcmp(params, "trousers", true ) ) { // slot 0

		if ( Character [ playerid ] [ character_handweapon ] != WEAPON_DEAGLE && Character [ playerid ] [ character_handweapon ] != WEAPON_KNIFE) {

			return SendServerMessage ( playerid, "You can only store pistols or knives in your trousers!", MSG_TYPE_ERROR ) ;
		}

		if ( Character [ playerid ] [ character_pantsweapon ] ) {

			return SendServerMessage ( playerid, "There's already a weapon stored in this slot! You can check it by using /holstered.", MSG_TYPE_WARN ) ;
		}

		Character [ playerid ] [ character_pantsweapon ] 		= Character [ playerid ] [ character_handweapon ] ;
		Character [ playerid ] [ character_pantsammo ] 			= Character [ playerid ] [ character_handammo] ;

		ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s holsters their %s into their trousers.", ReturnUserName ( playerid, false, true ), ReturnWeaponName ( Character [ playerid ] [ character_handweapon ] ) ) ) ;
//		SendClientMessage(playerid, 0xA39F60AA, sprintf("[WEAPON]{ffffff} You've holstered a {A39F60}%s{ffffff} with %d ammo.", ReturnWeaponName ( Character [ playerid ] [ character_pantsweapon ] ), Character [ playerid ] [ character_pantsammo ] ) ) ;
		//OldLog ( playerid, "guns/holster", sprintf ( "%s has holstered %s(%d) into their trousers slot", ReturnUserName ( playerid, false ), ReturnWeaponName ( Character [ playerid ] [ character_handweapon ]  ), Character [ playerid ] [ character_handammo ]  )) ;

		RemovePlayerWeapon ( playerid ) ;
		//RemovePlayerAttachedObject ( playerid, ATTACH_SLOT_HANDS ) ;

		Character [ playerid ] [ character_handammo ] = 0 ;
	}

	else if ( ! strcmp(params, "back", true ) ) { // slot 1

		if ( Character [ playerid ] [ character_backweapon ] ) {

			return SendServerMessage ( playerid, "There's already a weapon stored in this slot! You can check it by using /holstered.", MSG_TYPE_WARN ) ;
		}

		Character [ playerid ] [ character_backweapon ] 	= Character [ playerid ] [ character_handweapon ] ;
		Character [ playerid ] [ character_backammo ] 		= Character [ playerid ] [ character_handammo ] ; 

		ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s holsters their %s onto their back.", ReturnUserName ( playerid, false, true ), ReturnWeaponName ( Character [ playerid ] [ character_handweapon ] ) ) ) ;
//		SendClientMessage(playerid, 0xA39F60AA, sprintf("[WEAPON]{ffffff} You've holstered a {A39F60}%s{ffffff} with %d ammo.", ReturnWeaponName ( Character [ playerid ] [ character_backweapon ] ),Character [ playerid ] [ character_backammo ] ) ) ;
		//OldLog ( playerid, "guns/holster", sprintf ( "%s has holstered %s(%d) into their back slot", ReturnUserName ( playerid, false ), ReturnWeaponName ( Character [ playerid ] [ character_handweapon ]  ), Character [ playerid ] [ character_handammo ]  )) ;

		RemovePlayerWeapon ( playerid ) ;
		//RemovePlayerAttachedObject ( playerid, ATTACH_SLOT_HANDS ) ;

		Character [ playerid ] [ character_handammo ] = 0 ;
	}

	else return SendServerMessage ( playerid, "/holster [trousers | back]", MSG_TYPE_ERROR ) ;

	SavePlayerWeapons ( playerid ) ;

	return true ;
}

CMD:gh(playerid, params [] ) {

	return cmd_holster ( playerid, params ) ;
}
