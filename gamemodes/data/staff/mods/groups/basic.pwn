CMD:clearbuggeditems(playerid,params[]) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < BASIC_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a basic moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}
	new targetid;
	if(sscanf(params,"k<u>",targetid)) { return SendServerMessage(playerid,"/clearbuggeditems [playerid]",MSG_TYPE_ERROR); }
	if(!IsPlayerConnected(targetid)) { return SendServerMessage(playerid,"That player is not online.",MSG_TYPE_ERROR); }
	ClearBuggedItems(targetid);
	SendServerMessage(playerid,sprintf("(%d) %s's bugged items should be cleared.",targetid,ReturnUserName(targetid,true)),MSG_TYPE_INFO);
	SendServerMessage(targetid,sprintf("(%d) %s has cleared your inventory of bugged items.",playerid,ReturnUserName(playerid,true)),MSG_TYPE_INFO);
	return true;
}

CMD:clearshells ( playerid, params [] ) {
	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < BASIC_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a basic moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	ClearGunShells () ;

	SendModeratorWarning ( sprintf("[GUNSHELLS] %s (%d) has cleared the gunshells.", ReturnUserName ( playerid, true ), playerid), MOD_WARNING_MED ) ;

	return true ;
}

CMD:geoip ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < BASIC_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a basic moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new targetid;

	if ( sscanf ( params, "k<u>", targetid ) ) {

		return SendServerMessage ( playerid, "/geoip [target]", MSG_TYPE_ERROR ) ;
	}

	if ( targetid == INVALID_PLAYER_ID ) {

		return SendServerMessage ( playerid, "This player doesn't need to be connected.", MSG_TYPE_ERROR ) ;
	}

	new country [ 32 ], region [ 32 ], city [ 32 ], isp [ 32 ], timez [ 32 ], zipcode [ 32 ] ;

	GetPlayerCountry(targetid, country ) ;
	GetPlayerRegion(targetid, region ) ;
	GetPlayerCity(targetid, city ) ;
	GetPlayerISP(targetid, isp ) ;
	GetPlayerZipcode(targetid, zipcode ) ;
	GetPlayerTimezone(targetid, timez ) ; 

	SendClientMessage(playerid, COLOR_YELLOW, sprintf("(%d) %s's GEODATA (IP: %s) [TIMEZONE: %s]", targetid, ReturnUserName ( targetid, true ), ReturnIP ( targetid ), timez ) ) ;
	SendClientMessage(playerid, COLOR_YELLOW, sprintf("Country: %s - Region: %s - City: %s - ISP: %s - Zipcode: %s", country, region, city, isp, zipcode ) ) ;

	SendModeratorWarning ( sprintf("[GEO] %s (%d) has checked %s (%d)'s geo data.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ), MOD_WARNING_MED ) ;
	//OldLog ( playerid, "mod/trace", sprintf("%s (%d) has checked %s (%d)'s geo data.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid )) ;

	return true ;
}

CMD:togmodwarnings ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( IsPlayerOnAdminDuty [ playerid ] ) {

		return SendServerMessage ( playerid, "You can't disable moderator warnings when you're on mod duty.", MSG_TYPE_WARN ) ;
	}

	if ( ! PlayerModWarnings [ playerid ] ) {

		PlayerModWarnings [ playerid ] = true ;

		return SendServerMessage ( playerid, "Moderator warnings have been enabled. Use /togmodwarnings to disable it.", MSG_TYPE_INFO ) ;
	}

	else if ( PlayerModWarnings [ playerid ] ) {
		PlayerModWarnings [ playerid ] = false ;

		return SendServerMessage ( playerid, "Moderator warnings have been disabled. Use /togmodwarnings to enable it.", MSG_TYPE_INFO ) ;
	}

	return true ;
}

CMD:afrisk ( playerid, params [] ) {


	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < BASIC_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a basic moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new targetid ;

	if ( sscanf ( params, "k<u>", targetid )) {

		return SendServerMessage ( playerid, "/afrisk [target]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected(targetid)){

		return SendServerMessage ( playerid, "Target isn't connected.", MSG_TYPE_ERROR ) ;
	}

	SendClientMessage(playerid, COLOR_TAB0, sprintf("|________________________| Frisk of (%d) %s |________________________|", targetid, ReturnUserName ( targetid, true ) ) ) ;
	SendClientMessage( playerid, COLOR_TAB1,  sprintf("[HANDS]: %s with %d ammo.", ReturnWeaponName ( Character [ targetid ] [ character_handweapon] ), Character [ targetid ] [ character_handammo ] )) ;
	SendClientMessage( playerid, COLOR_TAB2,  sprintf("[PANTS]: %s with %d ammo.", ReturnWeaponName ( Character [ targetid ] [ character_pantsweapon] ), Character [ targetid ] [ character_pantsammo ] )) ;
	SendClientMessage( playerid, COLOR_TAB1,  sprintf("[BACK]: %s with %d ammo.", ReturnWeaponName ( Character [ targetid ] [ character_backweapon] ), Character [ targetid ] [ character_backammo ] )) ;
	SendClientMessage( playerid, COLOR_TAB1,  sprintf("[MONEY]: $%s", IntegerWithDelimiter ( Character [ targetid ] [ character_handmoney ] )) )  ;

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has frisked %s (%d).", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ), MOD_WARNING_LOW ) ;
	
	return true ;
}
CMD:adisarm ( playerid, params [] ) {
	// removes weapons from player
	new targetid, permit ;

	if ( sscanf ( params, "k<u>i", targetid, permit ) ) {

		return SendServerMessage ( playerid, "Syntax: /adisarm <player> <permit: 0: keep, 1: removed)", MSG_TYPE_ERROR ) ;
	}

	RemovePlayerWeapon ( targetid ) ;

	Character [ targetid ] [ character_pantsweapon ] = 0;
	Character [ targetid ] [ character_pantsammo ] = 0;

	Character [ targetid ] [ character_backweapon ] = 0;
	Character [ targetid ] [ character_backammo ] = 0;

	SavePlayerWeapons ( targetid ) ;

	if ( permit ) {
		if ( DoesPlayerHaveItem ( playerid, CARD_GUNPERMIT ) != -1) {

			DiscardItem ( playerid, DoesPlayerHaveItem ( playerid, CARD_GUNPERMIT ) ) ;
		}

		SendServerMessage ( targetid, sprintf("Admin %s has disarmed you of your weapons, ammo and permit.", ReturnUserName ( playerid, false, true ) ), MSG_TYPE_INFO ) ;
		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has disarmed %s (%d) of their weapons and permit.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ), MOD_WARNING_LOW ) ;
		WriteLog ( playerid, "mods/adisarm", sprintf("Admin %s disarmed %s of weapons AND license", ReturnUserName ( playerid, true ), ReturnUserName ( targetid, true ) ) ) ;
			
	}

	else if ( ! permit ) {

		SendServerMessage ( targetid, sprintf("Admin %s has disarmed you of your weapons and ammo.", ReturnUserName ( playerid, false, true ) ), MSG_TYPE_INFO ) ;
		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has disarmed %s (%d) of their weapons.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ), MOD_WARNING_LOW ) ;
		WriteLog ( playerid, "mods/adisarm", sprintf("Admin %s disarmed %s of weapons", ReturnUserName ( playerid, true ), ReturnUserName ( targetid, true ) ) ) ;
	}			

	return true ;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:stopinjuries ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < BASIC_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a basic moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new targetid ;

	if ( sscanf ( params, "k<u>", targetid )) {

		return SendServerMessage ( playerid, "/stopinjuries [player]", MSG_TYPE_ERROR ) ;
	}


	if ( targetid == INVALID_PLAYER_ID ) {

		return SendServerMessage ( playerid, "This player doesn't need to be connected.", MSG_TYPE_ERROR ) ;
	}

	TogglePlayerSpectating ( targetid, false ) ;

    PlayerDamage [ targetid ] [ DAMAGE_LEGS ] = false ;
    PlayerDamage [ targetid ] [ DAMAGE_ARMS ] = false ;
	
	TogglePlayerControllable ( targetid, true ) ;
	ResetPlayerWounds ( targetid ) ;

	Character [ targetid ] [ character_dmgmode ] = 0 ;
	PlayerInjuredCooldown [ targetid ] = 0 ;

	ClearAnimations ( targetid ) ;
	CancelBloodPuddle ( targetid ) ;

	SetCharacterHealth ( targetid, 100 ) ;

	if ( ! IsPlayerPaused ( targetid ) ) {
		SetName ( targetid, sprintf("(%d) %s", targetid, ReturnUserName ( targetid, false, true ) ), 0xCFCFCFFF ) ;
	}

	else SetName ( targetid, sprintf("[PAUSED (/afklist)]{DEDEDE}\n(%d) %s", targetid, ReturnUserName ( targetid, false )  ), COLOR_RED ) ;

	new query [ 128 ] ;

	mysql_format(mysql, query, sizeof ( query ), "UPDATE characters SET character_dmgmode = '0' WHERE character_id = '%d'", Character [ targetid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	SendServerMessage ( targetid, sprintf("Your injuries have been removed by moderator (%d) %s", playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_INFO ) ;
	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has removed %s (%d)'s injuries.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ), MOD_WARNING_LOW ) ;
	SendServerMessage ( playerid, "Please do this command once or twice on said target, to make sure the query passed to the database.", MSG_TYPE_ERROR ) ;

	//OldLog (playerid, "mod/set", sprintf("%s (%d) has removed %s (%d)'s injuries.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( targetid, true ), targetid ) ) ;

	return true ;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:ban ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < BASIC_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a basic moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new uid, reason [ 64 ], hours ;

	if ( sscanf ( params, "k<u>is[64]", uid, hours, reason ) ) {

		return SendServerMessage ( playerid, "/ban [ playerid / name ] [ hours ] [ reason ]", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( reason ) > sizeof ( reason ) ) {

		return SendServerMessage ( playerid, "Reason can't be longer than 64 characters!", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( uid ) ) {

		return SendServerMessage ( playerid, "Selected player doesn't exist, they might be offline.", MSG_TYPE_INFO ) ;
	}
		
	if ( hours < 12 || hours > 720 ) {

		return SendServerMessage ( playerid, "Ban hours must be between 12 and 720 hours", MSG_TYPE_ERROR ) ;
	}
    
	if ( hours == 0 ) {

		hours = 9999 ;
	}

    new secs = hours * 3600, unbants ;
    unbants = gettime() + secs;
    
    new query[256] ;
    
    mysql_format(mysql, query, sizeof(query), "INSERT INTO bans (account_id, account_name, ip, ban_admin, ban_reason, ban_time, unban_time) VALUES (%d, '%e', '%e', '%e', '%e', %d, %d)",
	Account [ uid ] [ account_id ], Account [ uid ] [ account_name ], ReturnIP ( uid ), Account [ playerid ] [ account_name ], reason, gettime(), unbants);

	mysql_tquery(mysql, query);

	SetAdminRecord ( Account [ uid ] [ account_id ], Account [ playerid ] [ account_id ], ARECORD_TYPE_BAN, reason, hours, ReturnDateTime () ) ;
	
	SendSplitMessageToAll ( COLOR_STAFF, sprintf("[STAFF] %s (%d) has banned %s (%d) for \"%s\"", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid,  reason) ) ;
	WriteLog ( uid, "mod/bans", sprintf("%s (%d) has banned %s (%d) for \"%s\"", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid, reason ) ) ;

	SendRconCommand(sprintf("banip %s", ReturnIP ( uid )));
	KickPlayer ( uid ) ;

	return true ;
}

CMD:offlineban ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < BASIC_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a basic moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new masteracc [  MAX_PLAYER_NAME ], hours, reason [ 64 ] ;

	if ( sscanf ( params, "s[24]is[64]", masteracc, hours, reason ) ) {

		return SendServerMessage ( playerid, "/offlineban [master_account] [hours] [reason] ( use /getma or /getc to get acc name )", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( masteracc ) > MAX_PLAYER_NAME ) {

		return SendServerMessage ( playerid, "Names can't be longer than 24 characters ", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( reason ) > sizeof ( reason ) ) {

		return SendServerMessage ( playerid, "Reason can't be longer than 64 characters!", MSG_TYPE_ERROR ) ;
	}
		
	if ( hours < 12 || hours > 720 ) {

		return SendServerMessage ( playerid, "Ban hours must be between 12 and 720 hours", MSG_TYPE_ERROR ) ;
	}

	foreach (new i: Player) {

		if ( ! strcmp(masteracc, Account [ playerid ] [ account_name ] ) ) {
			return SendServerMessage ( playerid, sprintf("Player seems to be connected as ID %d. Use /ban instead.", i ), MSG_TYPE_WARN ) ;

		}
	}

    new query[256], rows, fields ;

	inline ReturnAccountName() {

		cache_get_data ( rows, fields, mysql ) ;

		if ( ! rows ) {

			return SendServerMessage ( playerid, "Database didn't return any account data. Maybe your mistyped the name.", MSG_TYPE_WARN ) ;
		}

		if ( rows ) {

		   	new secs = hours * 3600, unbants, acc_id ;
		    unbants = gettime() + secs;

			acc_id = cache_get_field_content_int ( 0, "account_id", mysql ) ;

			SetAdminRecord ( acc_id, Account [ playerid ] [ account_id ], ARECORD_TYPE_BAN, reason, hours, ReturnDateTime () ) ;

		    mysql_format(mysql, query, sizeof(query), "INSERT INTO bans (account_id, account_name, ip, ban_admin, ban_reason, ban_time, unban_time) VALUES (%d, '%e', 'OFFLINE BAN', '%e', '%e', %d, %d)",
			acc_id, masteracc, Account [ playerid ] [ account_name ], reason, gettime(), unbants);

			mysql_tquery(mysql, query);

			SendSplitMessageToAll ( COLOR_STAFF, sprintf("[STAFF] %s (%d) has offline banned %s for \"%s\"", ReturnUserName ( playerid, true ), playerid, masteracc,  reason) ) ;
			WriteLog ( INVALID_PLAYER_ID, "mod/bans", sprintf("%s (%d) has offline banned %s for \"%s\"", ReturnUserName ( playerid, true ), playerid, masteracc,  reason) ) ;
		}
	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT account_id FROM master_accounts WHERE account_name = '%s'", masteracc ) ;
	mysql_tquery_inline(mysql, query, using inline ReturnAccountName, "");

	return true ;
}

CMD:oban ( playerid, params [] ) {

	return cmd_offlineban ( playerid, params ) ;
}

CMD:unban ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < BASIC_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a basic moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new masteracc [  MAX_PLAYER_NAME ];

	if ( sscanf ( params, "s[24]", masteracc ) ) {

		return SendServerMessage ( playerid, "/unban [master_account] ( use /getma or /getc to get acc name )", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( masteracc ) > MAX_PLAYER_NAME ) {

		return SendServerMessage ( playerid, "Names can't be longer than 24 characters ", MSG_TYPE_ERROR ) ;
	}

    new query[180], rows, fields ;

	inline ReturnAccountName() {

		cache_get_data ( rows, fields, mysql ) ;

		if ( ! rows ) {

			return SendServerMessage ( playerid, "Database didn't return any account data. Maybe your mistyped the name.", MSG_TYPE_WARN ) ;
		}

		if ( rows ) {

			new acc_id ;
			acc_id = cache_get_field_content_int ( 0, "account_id", mysql ) ;

			inline CheckUnban() {

				cache_get_data ( rows, fields, mysql ) ;

				if ( ! rows ) {

					return SendServerMessage ( playerid, sprintf("(%d) %s doesn't seem to be banned. Did you type the name correctly?", acc_id, masteracc ), MSG_TYPE_WARN ) ;
				}

				if ( rows ) {

				    mysql_format ( mysql, query, sizeof ( query), "DELETE FROM bans WHERE account_id = %d", acc_id ) ;
					mysql_tquery(mysql, query);

					SendModeratorWarning ( sprintf("[STAFF] %s (%d) unbanned %s (%d)", ReturnUserName ( playerid, true ), playerid, masteracc, acc_id ), MOD_WARNING_LOW ) ;
					WriteLog ( INVALID_PLAYER_ID, "mod/unbans", sprintf("%s (%d) has unbanned (%d) %s ", ReturnUserName ( playerid, true ), playerid, acc_id, masteracc ) ) ;
				}
			}

			mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM bans WHERE account_id = %d", acc_id ) ;
			mysql_tquery_inline(mysql, query, using inline CheckUnban, "");
		}
	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT account_id FROM master_accounts WHERE account_name = '%s'", masteracc ) ;
	mysql_tquery_inline(mysql, query, using inline ReturnAccountName, "");

	return true ;
}

CMD:unbanip ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < BASIC_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a basic moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new ip [  16 ];

	if ( sscanf ( params, "s[16]", ip ) ) {

		return SendServerMessage ( playerid, "/unbanip [ip] ( use /getma or /getc to get acc name )", MSG_TYPE_ERROR ) ;
	}

	SendRconCommand(sprintf("unbanip %s", ip ) ) ;

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) unbanned IP %s", ReturnUserName ( playerid, true ), playerid, ip ), MOD_WARNING_LOW ) ;
	WriteLog ( playerid, "mods/unban", sprintf("Admin %s unbanned IP %s", ReturnUserName ( playerid, true ), ip ) ) ;
	
	return true ;
}

BanChecker ( playerid ) {

	new query [ 512 ] ;

	inline BanHandler() {
		new rows, fields ;

		cache_get_data ( rows, fields, mysql ) ;

		if ( ! rows ) {

			//SendModeratorWarning ( sprintf("[CONNECT] (%d) %s has just logged in {FFFF00}[%s]", playerid, ReturnUserName ( playerid, true ), ReturnIP ( playerid ) ), MOD_WARNING_LOW ) ;

			//return Account_CharacterCheck ( playerid ) ;
			return true ;
		}

	    if ( rows ) {

			new unbantimestamp, admin [ MAX_PLAYER_NAME ], reason [ 64 ], date [ 6 ]  ;

			for ( new i, p = rows; i < p; i ++ ) {

				cache_get_field_content ( i, "ban_admin", admin, mysql, 24 ) ;
				cache_get_field_content ( i, "ban_reason", reason, mysql, 36 ) ;

				unbantimestamp = cache_get_field_int ( i, "unban_time" ) ;
			}

			if ( unbantimestamp > gettime () )  {

				HideCharacterTextDraws ( playerid ) ;

				query [ 0 ] = EOS ;

				TimestampToDate ( unbantimestamp, date[0], date[1], date[2], date[3], date[4], date[5], 1) ;

				SendClientMessage(playerid, COLOR_RED, "" ) ;
				SendClientMessage(playerid, COLOR_RED, "This account has been temporarily suspended due to a breach of our rules." ) ;
				SendClientMessage(playerid, COLOR_RED, "" ) ;
				SendClientMessage(playerid, COLOR_RED, sprintf("You got banned by moderator %s for %s.", admin, reason));
				SendClientMessage(playerid, COLOR_RED, sprintf("You will be unbanned at {DEDEDE}%02d/%02d/%02d %02d:%02d:%02d", date[2], date[1], date[0], date[3], date[4], date[5]));
				SendClientMessage(playerid, COLOR_RED, "" ) ;
				SendClientMessage(playerid, COLOR_RED, "Please do not try to evade this ban, as it is only temporary and ban evading results in a permanent ban." ) ;
				SendClientMessage(playerid, COLOR_RED, "If you do not agree with this ban, please appeal the ban on our forums. {DEDEDE}(www.ww-rp.net)" ) ;
				SendClientMessage(playerid, COLOR_RED, "" ) ;

				SendRconCommand(sprintf("banip %s", ReturnIP ( playerid )));

		    	return KickPlayer ( playerid ) ;
			}
		}
	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT unban_time, ban_admin, ban_reason FROM bans WHERE account_id = '%d'", Account [ playerid ] [ account_id ] ) ;
	mysql_tquery_inline ( mysql, query, using inline BanHandler, "" ) ;

	return true ;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
