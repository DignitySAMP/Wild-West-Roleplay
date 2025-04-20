CMD:ammocrate ( playerid, params [] ) {

	SendServerMessage ( playerid, "This feature is deprecated! You need to use ammo crates through your inventory!", MSG_TYPE_ERROR ) ;
	return true ;
}
/*
	new restoredata = Character [ playerid ] [ character_handweapon] ;

	if ( ! strcmp ( params, "pistol" ) ) {

		if ( Character [ playerid ] [ character_handweapon] != WEAPON_DEAGLE ) {

			return SendServerMessage ( playerid, "You need to have a pistol equipped in order to do this.", MSG_TYPE_ERROR ) ;
		}

		if ( ! Character [ playerid ] [ character_ammopack_pistol ] ) {

			return SendServerMessage ( playerid, "You need to have a pistol ammopack in order to do this.", MSG_TYPE_ERROR ) ;
		}

		Character [ playerid ] [ character_ammopack_pistol ] -- ;

		RemovePlayerWeapon ( playerid ) ;
		wep_GivePlayerWeapon ( playerid, restoredata, 15 ) ;

		ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s used an ammo pack for their pistol.", ReturnUserName ( playerid, true ) ) ) ;
		SendServerMessage ( playerid, "You've used an ammopack on your pistol and got 15 ammo.", MSG_TYPE_INFO ) ;
		SavePlayerWeapons ( playerid ) ;
	}	

	else if ( ! strcmp ( params, "shotgun" ) ) {

		if ( Character [ playerid ] [ character_handweapon] != WEAPON_SHOTGUN || Character [ playerid ] [ character_handweapon] != WEAPON_SAWEDOFF ) {

			return SendServerMessage ( playerid, "You need to have a shotgun equipped in order to do this.", MSG_TYPE_ERROR ) ;
		}
		
		if ( ! Character [ playerid ] [ character_ammopack_shotgun ] ) {

			return SendServerMessage ( playerid, "You need to have a shotgun ammopack in order to do this.", MSG_TYPE_ERROR ) ;
		}
		
		Character [ playerid ] [ character_ammopack_shotgun ] -- ;

		RemovePlayerWeapon ( playerid ) ;
		wep_GivePlayerWeapon ( playerid, restoredata, 10 ) ;

		ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s used an ammo pack for their shotgun.", ReturnUserName ( playerid, true ) ) ) ;
		SendServerMessage ( playerid, "You've used an ammopack on your shotgun and got 10 ammo.", MSG_TYPE_INFO ) ;
		SavePlayerWeapons ( playerid ) ;
	}

	else if ( ! strcmp ( params, "rifle" ) ) {

		if ( Character [ playerid ] [ character_handweapon] != WEAPON_RIFLE ) {

			return SendServerMessage ( playerid, "You need to have a rifle equipped in order to do this.", MSG_TYPE_ERROR ) ;
		}
	
		if ( ! Character [ playerid ] [ character_ammopack_rifle ] ) {

			return SendServerMessage ( playerid, "You need to have a rifle ammopack in order to do this.", MSG_TYPE_ERROR ) ;
		}	

		RemovePlayerWeapon ( playerid ) ;
		wep_GivePlayerWeapon ( playerid, restoredata, 5 ) ;

		Character [ playerid ] [ character_ammopack_rifle ] -- ;

		ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s used an ammo pack for their rifle.", ReturnUserName ( playerid, true ) ) ) ;
		SendServerMessage ( playerid, "You've used an ammopack on your rifle and got 5 ammo.", MSG_TYPE_INFO ) ;
		SavePlayerWeapons ( playerid ) ;
	}

	else return SendServerMessage ( playerid, "/ammocrate [pistol, shotgun, rifle]", MSG_TYPE_ERROR ) ;

	return true ;
}

SaveAmmoCrates ( playerid ) {

	new query [ 256 ] ;

	mysql_format(mysql, query, sizeof ( query ), "UPDATE characters SET character_ammopack_pistol = '%d',character_ammopack_shotgun = '%d',character_ammopack_rifle = '%d' WHERE character_id = '%d' ", 
		Character [ playerid ] [ character_ammopack_pistol], Character [ playerid ] [ character_ammopack_shotgun ], Character [ playerid ] [ character_ammopack_rifle ], Character [ playerid ] [ character_id ] ) ;

	mysql_tquery ( mysql, query ) ;

	return true ;
}*/