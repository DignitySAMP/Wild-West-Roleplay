CMD:refreshdynamiclabels(playerid,params[]) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < GENERAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a general moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}
	Init_DynamicLabels();
	SendModeratorWarning(sprintf("%s (%d) has reloaded all dynamic labels.",ReturnUserName(playerid,false,false),playerid),MOD_WARNING_LOW);
	return true;
}

CMD:reloadposses ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < GENERAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a general moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) reloaded all posses.", ReturnUserName ( playerid, true ), playerid), MOD_WARNING_LOW ) ;

	return Init_LoadPosses () ;
}

CMD:reloadpoints ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < GENERAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a general moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) reloaded all points.", ReturnUserName ( playerid, true ), playerid), MOD_WARNING_LOW ) ;

	return Init_Points () ;
}

CMD:removecheckpoints ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < GENERAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a general moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	for ( new i; i < 1024; i ++ ) {

		DestroyDynamicCP( i ) ;

	}

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) deleted all unused checkpoints", ReturnUserName ( playerid, true ), playerid), MOD_WARNING_LOW ) ;

	return true ;
}

CMD:refreshweather ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < GENERAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a general moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	RefreshZoneWeather() ;

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has refreshed the weather.", ReturnUserName ( playerid, true, false ), playerid), MOD_WARNING_LOW ) ;
	//OldLog ( INVALID_PLAYER_ID, "mod/mod_set", sprintf("%s (%d) has refreshed the weather.", ReturnUserName ( playerid, true ), playerid ) ) ;

	return true ;
}

CMD:gotoxyz ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < GENERAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a general moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new Float: x, Float: y, Float: z, interior, virtualworld ;

	if ( sscanf ( params, "fffI(0)I(0)", x, y, z, interior, virtualworld ) ) {

		return SendServerMessage ( playerid, "/gotoxyz [x coord] [y coord] [z coord] [optional:interior] [optional:virtualworld]", MSG_TYPE_ERROR ) ;
	}

	ac_SetPlayerPos ( playerid, x, y, z ) ;

	SetPlayerInterior ( playerid, interior ) ;
	SetPlayerVirtualWorld ( playerid, virtualworld ) ;

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has teleported to %.02f, %.02f, %.02f in interior ID %i and virtual world ID %i.", ReturnUserName ( playerid, true, false ), playerid, x, y, z, interior, virtualworld), MOD_WARNING_LOW ) ;
	return true ;
}

CMD:setweather ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < GENERAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a general moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new zone, weather ;

	if ( sscanf ( params, "ii", zone, weather )) {

		return SendServerMessage ( playerid, "/setweather [zone] [weather]", MSG_TYPE_ERROR ) ;
	}

	if ( zone < 0 || zone > sizeof ( Zones ) ) {

		return SendServerMessage ( playerid, "Invalid zone ID. Make sure you're at the right zone first and then use the ID sent to you.", MSG_TYPE_ERROR ) ;
	}

	Zone_Weather [ zone ] = weather ;

	foreach (new i: Player) {

		if ( IsPlayerInDynamicArea(i, zone ) ) {

			SetPlayerWeather ( i, Zone_Weather [ zone ] ) ;	
		}

		else continue ;

	}

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set the weather for zone %d to %d", ReturnUserName ( playerid, true ), playerid, zone, weather), MOD_WARNING_LOW ) ;
	//OldLog ( playerid, "mod/mod_set", sprintf("%s (%d) has set the weather for zone %d to %d", ReturnUserName ( playerid, true ), playerid, zone, weather) ) ;

	SendServerMessage ( playerid, sprintf("You've changed the weather of zone %d, anyone who is in it needs to re-enter it in order for it to update.", zone), MSG_TYPE_INFO ) ;

	return true ;
}

CMD:settime ( playerid, params [] ) {
	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}


	if ( GetStaffGroup ( playerid ) < GENERAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a general moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new time ;

	if ( sscanf ( params, "i", time )) {

		return SendServerMessage ( playerid, "/settime [time]", MSG_TYPE_ERROR ) ;
	}

	if ( time < 0 || time > 23 ) {

		return SendServerMessage ( playerid, "Time can't be lower than 0 or higher than 23", MSG_TYPE_ERROR ) ;
	}

	serverHour = time ;
	SetWorldTime ( serverHour ) ;

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set the to time %d. Server variable has been updated.", ReturnUserName ( playerid, true ), playerid, time), MOD_WARNING_LOW ) ;
	//OldLog ( playerid, "mod/mod_set", sprintf("%s (%d)  %s (%d) has set the to time %d. Server variable has been updated.", ReturnUserName ( playerid, true ), playerid, time) ) ;

	return true ;
}

CMD:setinterior ( playerid, params [] ) {
	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < GENERAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a general moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new targetid, int ;

	if ( sscanf ( params, "k<u>i", targetid, int )) {

		return SendServerMessage ( playerid, "/setint(erior) [user] [int]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( targetid ) ) {

		return SendServerMessage ( playerid, "Player isn't connected.", MSG_TYPE_ERROR ) ;
	}

	SetPlayerInterior(targetid, int ) ;
	SendServerMessage ( targetid, sprintf("Your interior has been set to %d by moderator (%d) %s", int, playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s interior to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, int), MOD_WARNING_LOW ) ;
	//OldLog ( targetid, "mod/mod_set", sprintf("%s (%d) has set %s (%d)'s interior to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, int) ) ;

	return true ;
}

CMD:setint ( playerid, params [] ) {

	return cmd_setinterior ( playerid, params ) ;
}

CMD:setvirtualworld ( playerid, params [] ) {
	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}


	if ( GetStaffGroup ( playerid ) < GENERAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a general moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new targetid, vw ;

	if ( sscanf ( params, "k<u>i", targetid, vw )) {

		return SendServerMessage ( playerid, "/setv(irtual)w(orld) [user] [vw]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( targetid ) ) {

		return SendServerMessage ( playerid, "Player isn't connected.", MSG_TYPE_ERROR ) ;
	}

	SetPlayerVirtualWorld(targetid, vw ) ;
	SendServerMessage ( targetid, sprintf("Your virtual world has been set to %d by moderator (%d) %s", vw, playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s virtual world to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, vw), MOD_WARNING_LOW ) ;
	//OldLog ( targetid, "mod/mod_set", sprintf("%s (%d) has set %s (%d)'s virtual world to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, vw) ) ;

	return true ;
}

CMD:setvw ( playerid, params [] ) {

	return cmd_setvirtualworld ( playerid, params ) ;
}

CMD:set(playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < GENERAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a general moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new option [ 20 ], targetid, value ;

	if ( sscanf ( params, "s[20]k<u>i", option, targetid, value ) ) {

		SendServerMessage ( playerid, "/set [option] [player] [value]", MSG_TYPE_ERROR ) ;
		SendServerMessage ( playerid, "[OPTIONS]: level, health, thirst, hunger, skin, horse, horsehealth, origin, gender, town", MSG_TYPE_ERROR ) ;
		SendServerMessage ( playerid, "[OPTIONS]: namechanges, pistol_ammo, shotgun_ammo, rifle_ammo, backpack", MSG_TYPE_ERROR ) ;
		return SendServerMessage ( playerid, "[OPTIONS]: hunger, thirst, rulecheck, age", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( targetid ) ) {

		return SendServerMessage ( playerid, "Player isn't connected anymore.", MSG_TYPE_ERROR ) ;
	}

	new query [ 256 ] ;

	if ( ! strcmp (option, "level", true ) ) {

		if(value <= 0) {

			return SendServerMessage(playerid,"Level cannot be at or below 0.",MSG_TYPE_ERROR);
		}

		Character [ targetid ] [ character_level ] = value;
		SetPlayerScore(targetid,Character[targetid][character_level]);

		mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_level = %d WHERE character_id = %d",Character[targetid][character_level],Character[targetid][character_id]);
		mysql_tquery(mysql,query);

		SendServerMessage ( targetid, sprintf("Your level has been set to %d by moderator (%d) %s", value, playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_INFO ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s level to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value), MOD_WARNING_MED ) ;
		WriteLog ( targetid, "mod/mod_set", sprintf("%s (%d) has set %s (%d)'s level to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value ) ) ;
	} 
	if ( ! strcmp (option, "health", true ) ) {

		if ( value < 15 || value > 100 ) {

			return SendServerMessage ( playerid, "Health can't be lower than 15 or higher than 100", MSG_TYPE_ERROR ) ;
		}

		new Float: health = value ;

		SetCharacterHealth ( targetid, health ) ;
/*
		Character [ targetid ] [ character_health ] = health ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_health = %f WHERE character_id = %d", Character [ targetid ] [ character_health ], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;
*/
		SendServerMessage ( targetid, sprintf("Your health has been set to %d by moderator (%d) %s", value, playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s health to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value), MOD_WARNING_MED ) ;
		WriteLog ( targetid, "mod/mod_set", sprintf("%s (%d) has set %s (%d)'s health to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value ) ) ;
		
		return true ;
	}

	if ( ! strcmp (option, "thirst", true ) ) {

		if ( value < 15 || value > 100 ) {

			return SendServerMessage ( playerid, "Thirst can't be lower than 15 or higher than 100", MSG_TYPE_ERROR ) ;
		}

		new thirst = value ;

		Character [ targetid ] [ character_thirst ] = thirst ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_thirst = %d WHERE character_id = %d", Character [ targetid ] [ character_thirst ], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( targetid, sprintf("Your thirst has been set to %d by moderator (%d) %s", value, playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s thirst to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value ), MOD_WARNING_LOW ) ;
		WriteLog ( targetid, "mod/mod_set", sprintf("%s (%d) has set %s (%d)'s thirst to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value ) ) ;
	}

	if ( ! strcmp (option, "hunger", true ) ) {

		if ( value < 15 || value > 100 ) {

			return SendServerMessage ( playerid, "Hunger can't be lower than 15 or higher than 100", MSG_TYPE_ERROR ) ;
		}

		new hunger = value ;

		Character [ targetid ] [ character_hunger ] = hunger ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_hunger = %d WHERE character_id = %d", Character [ targetid ] [ character_hunger ], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( targetid, sprintf("Your hunger has been set to %d by moderator (%d) %s", value, playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s hunger to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value ), MOD_WARNING_LOW ) ;
		WriteLog ( targetid, "mod/mod_set", sprintf("%s (%d) has set %s (%d)'s hunger to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value ) ) ;
	}

	if ( ! strcmp (option, "skin", true ) ) {

		if ( value < 1 || value > 311 ) {

			return SendServerMessage ( playerid, "Skin can't be lower than 1 or higher than 311", MSG_TYPE_ERROR ) ;
		}

		Character [ targetid ] [ character_skin ] = value ;
		SetPlayerSkin ( targetid,	Character [ targetid ] [ character_skin ] ) ;
		TogglePlayerControllable(targetid, true ) ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_skin = %d WHERE character_id = %d", Character [ targetid ] [ character_skin ], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( targetid, sprintf("Your skin has been set to %d by moderator (%d) %s", value, playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s skin to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value ), MOD_WARNING_LOW ) ;
		WriteLog ( targetid, "mod/mod_set", sprintf("%s (%d) has set %s (%d)'s skin to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value ) ) ;
	}

	if ( ! strcmp (option, "horse", true ) ) {

		/*if ( value != 99 ) {
			if ( value < -1 || value > 5 || value == 0 || value == 1 || value == 4) {

				SendServerMessage ( playerid, "[HORSES] -1: Remove Horse, 2: Highland Chestnut, 3: American Standardbred, 5: Hungarian Half-bred", MSG_TYPE_INFO ) ;
				return SendServerMessage ( playerid, "The only valid horse values are -1, 2, 3, and 5.", MSG_TYPE_ERROR ) ;
			}
		}*/

		if ( value == 0 || value == 4 || value == 5 ) {

			SendServerMessage ( playerid, "[HORSES] -1: Remove Horse, 1: Dutch Warmblood, 2: Highland Chestnut, 3: American Standardbred", MSG_TYPE_INFO ) ;
			return SendServerMessage ( playerid, "The only valid horse values are -1, 1, 2, and 3.", MSG_TYPE_ERROR ) ;
		}
	

		if ( IsPlayerRidingHorse [ targetid ] || PlayerHorse [ targetid ] [ IsHorseSpawned ] ) {

			return SendServerMessage ( playerid, "Your target player has to use /respawnhorse before you can set their horse", MSG_TYPE_ERROR ) ;
		}

		Character [ targetid ] [ character_horseid ] = value ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_horseid = %d WHERE character_id = %d", Character [ targetid ] [ character_horseid ], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		for(new i=0; i<sizeof(horseType); i++) {

			if(horseType[i][h_td_id] == value) {

				value = i;
				break;
			}
		}

		if ( value != 99 ) {
			SendServerMessage ( targetid, sprintf("Your horse has been set to %s by moderator (%d) %s", horseType [ value ] [ h_td_name ], playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;
			SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s horse to %s.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, horseType [ value ] [ h_td_name ] ), MOD_WARNING_LOW ) ;
			WriteLog ( targetid, "mods/mod_set", sprintf("[STAFF] %s (%d) has set %s (%d)'s horse to %s.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, horseType [ value ] [ h_td_name ] ) ) ;
		}

		else if ( value == 99 ) {
			SendServerMessage ( targetid, sprintf("Your mount has been set to a cow by moderator (%d) %s", playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;
			SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s mount to a cow.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ), MOD_WARNING_LOW ) ;
			WriteLog ( targetid, "mods/mod_set", sprintf("[STAFF] %s (%d) has set %s (%d)'s mount to a cow.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ) ) ;
		}
	}

	if ( ! strcmp (option, "horsehealth", true ) ) {

		if ( value < 5 || value > 100 ) {

			return SendServerMessage ( playerid, "Horse value can't be lower than 5 or higher than 100.", MSG_TYPE_ERROR ) ;
		}

		if ( IsPlayerRidingHorse [ targetid ] || PlayerHorse [ targetid ] [ IsHorseSpawned ] ) {

			return SendServerMessage ( playerid, "Your target player has to use /respawnhorse before you can set their horse.", MSG_TYPE_ERROR ) ;
		}

		Character [ targetid ] [ character_horsehealth ] = float(value) ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_horsehealth = %f WHERE character_id = %d", Character [ targetid ] [ character_horsehealth ], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( targetid, sprintf("Your horse health has been set to %f by moderator (%d) %s", Character [ targetid ] [ character_horsehealth ], playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s horse health to %f", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, Character [ targetid ] [ character_horsehealth ] ), MOD_WARNING_LOW ) ;
		//OldLog ( targetid, "mod/mod_set", sprintf("%s (%d) has set %s (%d)'s horse's health to %f", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, Character [ targetid ] [ character_horsehealth ] ) ) ;
	}

	if ( ! strcmp (option, "origin", true ) ) {

		if ( value < 0 || value > 5 ) {

			SendServerMessage ( playerid, "[ORIGINS]: 0: Caucasian, 1: Hispanic, 2: African, 3: Asian, 4: Indian", MSG_TYPE_INFO ) ;
			return SendServerMessage ( playerid, "Origin value can't be lower than 0 or higher than 5.", MSG_TYPE_ERROR ) ;
		}

		new maleSkin_array [] [] = {
			{95}, {58}, {183}, {210}, {128}
		},  femaleSkin_array [] [] = {
			{157}, {298}, {215}, {169}, {131}
		}, origin_array [] [] = {
			{"Caucasian"}, {"Hispanic"}, {"African"}, {"Asian"}, {"Indian"}
		}, gender = Character [ targetid ] [ character_gender ], genderSkin ;

		if ( ! gender ) {
			genderSkin = maleSkin_array [ value ] [ 0 ] ;
		}

		else if ( gender ) {
			genderSkin = femaleSkin_array [ value ] [ 0 ] ;
		}

		SetPlayerSkin ( targetid, genderSkin ) ;

		Character [ targetid ] [ character_skin ] = genderSkin ;
		Character [ targetid ] [ character_origin ] = value ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_skin = %d, character_origin = %d WHERE character_id = %d", Character [ targetid ] [ character_skin ], Character [ targetid ] [ character_origin ], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( targetid, sprintf("Your origin has been set to (%d) %s by moderator (%d) %s", value, origin_array [ value ], playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s origin to (%d) %s.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value, origin_array [ value ] ), MOD_WARNING_LOW ) ;
		//OldLog ( targetid, "mod/mod_set", sprintf("%s (%d) has set %s (%d)'s origin to (%d) %s.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value, origin_array [ value ] ) ) ;
	}

	if ( ! strcmp (option, "gender", true ) ) {

		if ( value < 0 || value > 1 ) {

			SendServerMessage ( playerid, "[GENDERS]: 0: Gender, 1: Female", MSG_TYPE_INFO ) ;
			return SendServerMessage ( playerid, "Gender value can't be lower than 0 or higher than 1.", MSG_TYPE_ERROR ) ;	
		}

		new maleSkin_array [] [] = {
			{95}, {58}, {183}, {210}, {128}
		},  femaleSkin_array [] [] = {
			{157}, {298}, {215}, {169}, {131}
		}, gender_array [] [] = {
			{"Male"}, {"Female"}
		}, race = Character [targetid] [ character_origin ], genderSkin ;

		Character [ targetid ] [ character_gender ] = value ;

		if ( ! value ) {
			genderSkin = maleSkin_array [ race ] [ 0 ] ;
		}

		else if ( value ) {
			genderSkin = femaleSkin_array [ race ] [ 0 ] ;
		}

		SetPlayerSkin ( targetid, genderSkin ) ;
		Character [ targetid ] [ character_skin ] = genderSkin ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_skin = %d, character_gender = %d WHERE character_id = %d", Character [ targetid ] [ character_skin ], Character [ targetid ] [ character_gender ], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( targetid, sprintf("Your gender has been set to (%d) %s by moderator (%d) %s", value, gender_array [ value ], playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s gender to (%d) %s.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value, gender_array [ value ] ), MOD_WARNING_LOW ) ;
		//OldLog ( targetid, "mod/mod_set", sprintf("%s (%d) has set %s (%d)'s gender to (%d) %s.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value, gender_array [ value ] ) ) ;
	}

	if ( ! strcmp (option, "town", true ) ) {

		if ( value < 0 || value > 2 ) {

			SendServerMessage ( playerid, "[TOWNS] 0: Bayside, 1: Longcreek, 2: Fremont", MSG_TYPE_INFO ) ;
			return SendServerMessage ( playerid, "Town value can't be lower than 0, or higher than 3.", MSG_TYPE_ERROR ) ;
		}

		new location_array [] [] = {
			{"Bayside"}, {"Longcreek"}, {"Fremont"}
		} ;

		Character [ targetid ] [ character_town ] = value ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_town = %d WHERE character_id = %d", Character [ targetid ] [ character_town ], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( targetid, sprintf("Your town has been set to (%d) %s by moderator (%d) %s", value, location_array [ value ], playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s town to (%d) %s.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value, location_array [ value ] ), MOD_WARNING_LOW ) ;
		//OldLog ( targetid, "mod/mod_set", sprintf("%s (%d) has set %s (%d)'s town to (%d) %s.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid, value, location_array [ value ] ) ) ;

	}

	if ( ! strcmp (option, "namechanges", true ) ) {

		if ( value < 0 || value > 1 ) {

			return SendServerMessage ( playerid, "You can only add one of these per command. (it increments)", MSG_TYPE_ERROR ) ;
		}

		Account [ targetid ] [ account_namechanges ] += value ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_namechanges = %d WHERE account_id = %d", Account [ targetid ] [ account_namechanges ], Account [ targetid ] [ account_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( targetid, sprintf("You have been given a namechange by moderator (%d) %s", playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has given %s (%d) a namechange.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ), MOD_WARNING_MED ) ;
		//OldLog ( targetid, "mod/mod_set", sprintf("%s (%d) has given %s (%d) a namechange.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ) ) ;

	}

	if ( ! strcmp (option, "pistol_ammo", true ) ) {

		if ( value < 0 || value > 1 ) {

			return SendServerMessage ( playerid, "You can only add one of these per command. (it increments)", MSG_TYPE_ERROR ) ;
		}

		Character [ targetid ] [ character_ammopack_pistol ] += value ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_ammopack_pistol = %d WHERE character_id = %d", Character [ targetid ] [ character_ammopack_pistol ], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( targetid, sprintf("You have been given a pistol ammopack by moderator (%d) %s", playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has given %s (%d) a pistol ammopack.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ), MOD_WARNING_HIGH ) ;
		//OldLog ( targetid, "mod/mod_set", sprintf("%s (%d) has given %s (%d) a pistol ammopack.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ) ) ;

	}

	if ( ! strcmp (option, "shotgun_ammo", true ) ) {

		if ( value < 0 || value > 1 ) {

			return SendServerMessage ( playerid, "You can only add one of these per command. (it increments)", MSG_TYPE_ERROR ) ;
		}

		Character [ targetid ] [ character_ammopack_shotgun ] += value ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_ammopack_shotgun = %d WHERE character_id = %d", Character [ targetid ] [ character_ammopack_shotgun ], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( targetid, sprintf("You have been given a shotgun ammopack by moderator (%d) %s", playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has given %s (%d) a shotgun ammopack.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ), MOD_WARNING_HIGH ) ;
		//OldLog ( targetid, "mod/mod_set", sprintf("%s (%d) has given %s (%d) a shotgun ammopack.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ) ) ;

	}

	if ( ! strcmp (option, "rifle_ammo", true ) ) {

		if ( value < 0 || value > 1 ) {

			return SendServerMessage ( playerid, "You can only add one of these per command. (it increments)", MSG_TYPE_ERROR ) ;
		}

		Character [ targetid ] [ character_ammopack_rifle ] += value ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_ammopack_rifle = %d WHERE character_id = %d", Character [ targetid ] [ character_ammopack_rifle ], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( targetid, sprintf("You have been given a rifle ammopack by moderator (%d) %s", playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has given %s (%d) a rifle ammopack.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ), MOD_WARNING_HIGH ) ;
		//OldLog ( targetid, "mod/mod_set", sprintf("%s (%d) has given %s (%d) a rifle ammopack.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ) ) ;

	}

	if ( ! strcmp (option, "backpack", true ) ) {

		if ( value < 0 || value > 2 ) {

			return SendServerMessage ( playerid, "Value can't be more than 2 or less than 0.", MSG_TYPE_ERROR ) ;
		}

		Character [ targetid ] [ character_backpack ] = value ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_backpack = %d WHERE character_id = %d", Character [ targetid ] [ character_backpack ], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( targetid, sprintf("Your backpack has been set to %d by moderator (%d) %s", value, playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s backpack to %d.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid , value ), MOD_WARNING_HIGH ) ;
		//OldLog ( targetid, "mod/mod_set", sprintf("%s (%d) has set %s (%d)'s backpack to %d'.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid , value )) ;

	}

	if(!strcmp(option,"hunger",true)) {

		if(value < 0 || value > 100) {

			return SendServerMessage(playerid,"Value can't be more than 100 or less than 0.",MSG_TYPE_ERROR);
		}

		Character[targetid][character_hunger] = value;

		mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_hunger = %d WHERE character_id = %d",Character[targetid][character_hunger],Character[targetid][character_id]);
		mysql_tquery(mysql,query);

		UpdateGUI(targetid);

		SendServerMessage(targetid,sprintf("Your hunger has been set to %d by moderator (%d) %s.",value,playerid,ReturnUserName(playerid,true)),MSG_TYPE_INFO);

		SendModeratorWarning(sprintf("[STAFF] %s (%d) has set %s (%d)'s hunger to %d.",ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid , value ), MOD_WARNING_HIGH ) ;
	}

	if(!strcmp(option,"thirst",true)) {

		if(value < 0 || value > 100) {

			return SendServerMessage(playerid,"Value can't be more than 100 or less than 0.",MSG_TYPE_ERROR);
		}

		Character[targetid][character_thirst] = value;

		mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d WHERE character_id = %d",Character[targetid][character_thirst],Character[targetid][character_id]);
		mysql_tquery(mysql,query);

		UpdateGUI(targetid);

		SendServerMessage(targetid,sprintf("Your thirst has been set to %d by moderator (%d) %s.",value,playerid,ReturnUserName(playerid,true)),MSG_TYPE_INFO);

		SendModeratorWarning(sprintf("[STAFF] %s (%d) has set %s (%d)'s thirst to %d.",ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid , value ), MOD_WARNING_HIGH ) ;
	}

	if(!strcmp(option,"rulecheck",true)) {

		if(value < 0 || value > 1) {

			return SendServerMessage(playerid,"Value can't be more than 1 or less than 0.",MSG_TYPE_ERROR);
		}

		Account[targetid][account_rulecheck] = value;

		mysql_format(mysql,query,sizeof(query),"UPDATE master_accounts SET account_rulecheck = %d WHERE account_id = %d",Account[targetid][account_rulecheck],Account[targetid][account_id]);
		mysql_tquery(mysql,query);

		SendModeratorWarning(sprintf("[STAFF] %s (%d) has set %s (%d)'s rulebreaker stat to %d.",ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid , value ), MOD_WARNING_HIGH ) ;
	}

	if(!strcmp(option,"age",true)) {

		if(value < 8 || value > 80) {

			return SendServerMessage(playerid,"Value can't be more than 80 or less than 8.",MSG_TYPE_ERROR);
		}

		Character[targetid][character_age] = value;

		mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_age = %d WHERE character_id = %d",Character[targetid][character_age],Character[targetid][character_id]);
		mysql_tquery(mysql,query);

		SendServerMessage(targetid,sprintf("Your age has been set to %d by moderator (%d) %s.",value,playerid,ReturnUserName(playerid,true)),MSG_TYPE_INFO);

		SendModeratorWarning(sprintf("[STAFF] %s (%d) has set %s (%d)'s age to %d.",ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid , value ), MOD_WARNING_LOW ) ;
	}

	return true ;
}