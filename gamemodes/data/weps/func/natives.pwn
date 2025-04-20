new HolsterTick [ MAX_PLAYERS ] ;

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

	if ( newkeys & KEY_YES ) {

		new temp_Tick = GetTickCount(), temp_tickDiff ;
		temp_tickDiff = GetTickDiff ( temp_Tick, HolsterTick[playerid] );
		
		new cooldown = GetHolsterSkill ( playerid ) ;

		if(temp_tickDiff < cooldown) {
		
			return SendServerMessage ( playerid, sprintf("You must wait %0.2f seconds before quickswitching again. To increase this, use /skills and /levelup your holster skill",float(cooldown - temp_tickDiff) / 1000.0), MSG_TYPE_ERROR ) ;
		}		

		HolsterTick[playerid] = GetTickCount();		

		if ( ! Character [ playerid ] [ character_handweapon ] ) {

			return cmd_unholster(playerid, "trousers");
		}

		else if ( Character [ playerid ] [ character_handweapon ] ) {

			return cmd_holster(playerid, "trousers");
		}
	}

	#if defined gun_OnPlayerKeyStateChange
		return gun_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif

#define OnPlayerKeyStateChange gun_OnPlayerKeyStateChange
#if defined gun_OnPlayerKeyStateChange
	forward gun_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

public OnPlayerStartAim ( playerid ) {

 	SetPlayerDrunkLevel ( playerid, GetPlayerGunSkill ( playerid ) );   	

 	if ( GetPlayerWeapon ( playerid ) == WEAPON_SNIPER ) {

	 	RemovePlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP );
	 	RemovePlayerAttachedObject(playerid, ATTACH_SLOT_PANTS);

	 	RemovePlayerAttachedObject(playerid, ATTACH_SLOT_BACK );
	 	RemovePlayerAttachedObject(playerid, ATTACH_SLOT_HANDS);
 	}
 	return true ;
}

public OnPlayerStopAim ( playerid ) {

 	SetPlayerDrunkLevel ( playerid, 0 );   	
	SetupPlayerGunAttachments ( playerid ) ;

 	return true ;
}

public OnPlayerUpdate ( playerid ) {

	if ( GetPlayerWeapon ( playerid ) != Character [ playerid ] [ character_handweapon ] ) {
		SetPlayerArmedWeapon ( playerid, Character [ playerid ] [ character_handweapon ]) ;
	}

    if ( IsPlayerAiming ( playerid ) ) {
 		SetPlayerDrunkLevel ( playerid, GetPlayerGunSkill ( playerid ) );   	
    }

    if ( ! IsPlayerAiming ( playerid ) && !IsPlayerPlayingPoker(playerid) ) {
		SetPlayerDrunkLevel ( playerid, 1 ) ;
    }
	
	#if defined gun_OnPlayerUpdate 
		return gun_OnPlayerUpdate ( playerid );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerUpdate 
	#undef OnPlayerUpdate 
#else
	#define _ALS_OnPlayerUpdate 
#endif

#define OnPlayerUpdate  gun_OnPlayerUpdate 
#if defined gun_OnPlayerUpdate 
	forward gun_OnPlayerUpdate ( playerid );
#endif

CMD:fixaim ( playerid, params [] ) {

	if ( IsPlayerAiming ( playerid ) ) {

		return SendServerMessage ( playerid, "You can't do this command whilst aiming a weapon.", MSG_TYPE_ERROR ) ;
	}

	SetPlayerDrunkLevel(playerid, 1);
	SendServerMessage ( playerid, "Reset your shake level. If there's still an issue, aim a weapon and it should be fixed.", MSG_TYPE_WARN) ;

	return true ;
}

CMD:fa ( playerid, params [] ) {

	return cmd_fixaim ( playerid, params ) ;
}

ResetPlayerWeaponsEx ( playerid ) {

	SetPlayerDrunkLevel ( playerid, 0 ) ;
	ResetPlayerWeapons ( playerid ) ;

	return true ;
}
