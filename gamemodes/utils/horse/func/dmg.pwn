/*

public OnPlayerShootDynamicObject(playerid, weaponid, STREAMER_TAG_OBJECT objectid, Float:x, Float:y, Float:z) {



	new Float: amount, Float: player_dist ;
	new Float: obj_x, Float: obj_y, Float: obj_z ;

	foreach(new victimid: Player) {

		if ( IsPlayerConnected ( victimid ) && objectid == PlayerHorse [ victimid ] [ PlayerHorseObject ] ) {

			if ( victimid == playerid ) {

				return false ;
			}

			if ( Character [ victimid ] [ character_horsehealth ] <= 0 ) {

				return SendServerMessage ( playerid, "That horse is already dead.", MSG_TYPE_ERROR ) ;
			}

			if ( IsPlayerRidingHorse [ victimid ] ) {

				GetPlayerPos ( victimid, obj_x, obj_y, obj_z ) ;
			}

			else if ( ! IsPlayerRidingHorse [ victimid ] ) { 

				GetDynamicObjectPos(PlayerHorse [ victimid ] [ PlayerHorseObject ],  obj_x, obj_y, obj_z ) ;
			}
			player_dist = GetPlayerDistanceFromPoint ( playerid, obj_x, obj_y, obj_z ) ;

			switch ( weaponid ) {

				case 24: { // deagle

					if ( player_dist <= 5 ) amount = 25 ;
					else if ( player_dist > 5 && player_dist < 15 ) amount = 15 ;
					else if ( player_dist > 15 ) amount = 5 ;
				}

				case 25: { // shotgun

					if ( player_dist <= 5 ) amount = 45 ;
					else if ( player_dist > 5 && player_dist < 15 ) amount = 25 ;
					else if ( player_dist > 15 ) amount = 2.5 ;
				}

				default: amount = 0 ;
			}

			SetHorseHealth ( victimid, playerid, Character [ victimid ] [ character_horsehealth ] - amount ) ;

			SendServerMessage ( playerid, sprintf("You have shot (%d) %s's horse for %f damage.", victimid, ReturnUserName ( victimid, false ), amount ), MSG_TYPE_WARN )  ;
			SendServerMessage ( victimid, sprintf("Your horse has been shot by (%d) %s with a %s for %f damage.", playerid, ReturnUserName ( playerid, false ), ReturnWeaponName ( weaponid ), amount ), MSG_TYPE_WARN ) ;
		}

		else continue ;
	}

	return true ;
}
*/
SetHorseHealth ( playerid, issuerid, Float: horsehealth ) {

	new query [ 128 ] ;

	Character [ playerid ] [ character_horsehealth ] = horsehealth ;

	if ( Character [ playerid ] [ character_horsehealth ] <= 0 ) {
		Character [ playerid ] [ character_horsehealth ] = 0;
	}

	if ( IsPlayerRidingHorse [ playerid ] ) {
		SetPlayerProgressBarValue(playerid, PlayerHorse [ playerid ] [ HorseHealthBar  ], Character [ playerid ] [ character_horsehealth ] );
	}

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_horsehealth = '%f' WHERE character_id = '%d'", 
		Character [ playerid ] [ character_horsehealth ], Character [ playerid ] [ character_id ]) ;
	mysql_tquery ( mysql, query ) ;


	if ( Character [ playerid ] [ character_horsehealth ] == 0 ) {

		if ( IsValidDynamicCP (PlayerMountHorseCP [ playerid ] [ 0 ] ) ) {
			DestroyDynamicCP( PlayerMountHorseCP [ playerid ] [ 0 ] ) ;
		}
				
		if ( IsValidDynamicCP (PlayerMountHorseCP [ playerid ] [ 1 ] ) ) {
			DestroyDynamicCP( PlayerMountHorseCP [ playerid ] [ 1 ] ) ;
		}

		if ( IsPlayerConnected ( issuerid ) ) {
			SendServerMessage ( playerid, sprintf("Your horse has been killed by (%s) %s. It will respawn soon.", issuerid, ReturnUserName ( issuerid, true )), MSG_TYPE_ERROR ) ;
			//OldLog ( playerid, "horse/death", sprintf("(%d) %s's horse has been killed by (%d) %s.", playerid, ReturnUserName ( playerid, true ), issuerid, ReturnUserName ( issuerid, true ))) ;
		}

		else {

			SendServerMessage ( playerid, sprintf("Your horse has been killed. It will respawn soon.", issuerid, ReturnUserName ( issuerid, true )), MSG_TYPE_ERROR ) ;
			//OldLog ( playerid, "horse/death", sprintf("(%d) %s's horse has been killed by INVALID_PLAYER_ID. (usually self inflicted)", playerid, ReturnUserName ( playerid, true ))) ;
		}

		if ( IsPlayerRidingHorse [ playerid ] ) {

			DismountHorse ( playerid ) ;
			IsPlayerRidingHorse [ playerid ] = false ;

			new Float: obj_x, Float: obj_y, Float: obj_z ;

			if ( Character [ playerid ] [ character_horseid ] < DONATOR_MOUNT_SLOT ) {
				GetDynamicObjectPos(HorseObject [ playerid ], obj_x, obj_y, obj_z ) ;
				
				SetDynamicObjectRot ( HorseObject [ playerid ], 0, 90, 0 ) ;
				SetDynamicObjectPos ( HorseObject [ playerid ], obj_x, obj_y, obj_z ) ;
			}

			else {
				GetDynamicObjectPos(CowObject [ playerid ], obj_x, obj_y, obj_z ) ;

				SetDynamicObjectRot ( CowObject [ playerid ], 0, 90, 0 ) ;
				SetDynamicObjectPos ( CowObject [ playerid ], obj_x, obj_y, obj_z ) ;
			}

			ac_SetPlayerPos ( playerid,  obj_x, obj_y, obj_z + 1.25 ) ;

			return AnimationLoop(playerid,"PED","KO_SHOT_STOM", 4.1, 0, 1, 1, 1, 1, 1); 
		}

		else if ( ! IsPlayerRidingHorse [ playerid ] ) {

			new Float: obj_x, Float: obj_y, Float: obj_z ;

			if ( Character [ playerid ] [ character_horseid ] < DONATOR_MOUNT_SLOT ) {

				GetDynamicObjectPos(HorseObject [ playerid ], obj_x, obj_y, obj_z ) ;

				SetDynamicObjectRot ( HorseObject [ playerid ], 0, 90, 0 ) ;
				SetDynamicObjectPos ( HorseObject [ playerid ], obj_x, obj_y, obj_z ) ;
			}

			else {

				GetDynamicObjectPos(CowObject [ playerid ], obj_x, obj_y, obj_z ) ;
				
				SetDynamicObjectRot ( CowObject [ playerid ], 0, 90, 0 ) ;
				SetDynamicObjectPos ( CowObject [ playerid ], obj_x, obj_y, obj_z ) ;
			}
		}
	}

	return true ;
}