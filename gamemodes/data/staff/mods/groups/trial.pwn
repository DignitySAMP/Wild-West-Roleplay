
new Float: spec_pos_x 	[ MAX_PLAYERS ] ;
new Float: spec_pos_y 	[ MAX_PLAYERS ] ;
new Float: spec_pos_z 	[ MAX_PLAYERS ] ;
new spec_int 	[ MAX_PLAYERS ] ;
new spec_vw 	[ MAX_PLAYERS ] ;

timer DelayedGunAttachments[1000](playerid) {

////	print("DelayedGunAttachments timer called (basic.pwn)");

	return SetupPlayerGunAttachments ( playerid ) ;
}

CMD:trialban ( playerid, params [] ) {


	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new uid, reason [ 64 ], hours = 24 ;

	if ( sscanf ( params, "k<u>s[64]", uid, reason ) ) {

		SendServerMessage ( playerid, "This command will ban a player for 24 hours, contact a basic moderator for a permanant ban situation.", MSG_TYPE_WARN ) ;
		return SendServerMessage ( playerid, "/trialban [ playerid / name ] [ reason ]", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( reason ) > sizeof ( reason ) ) {

		return SendServerMessage ( playerid, "Reason can't be longer than 64 characters!", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( uid ) ) {

		return SendServerMessage ( playerid, "Selected player doesn't exist, they might be offline.", MSG_TYPE_INFO ) ;
	}
		

    new secs = hours * 3600, unbants ;
    unbants = gettime() + secs;
    
    new query[256], reason_temp [ 128 ] ;

    strins(reason_temp, sprintf("[TEMP] %s", reason), 0, sizeof ( reason_temp ) ) ;
    
    mysql_format(mysql, query, sizeof(query), "INSERT INTO bans (account_id, account_name, ip, ban_admin, ban_reason, ban_time, unban_time) VALUES (%d, '%e', '%e', '%e', '%e', %d, %d)",
	Account [ uid ] [ account_id ], Account [ uid ] [ account_name ], ReturnIP ( uid ), Account [ playerid ] [ account_name ], reason_temp, gettime(), unbants);

	mysql_tquery(mysql, query);

	SetAdminRecord ( Account [ uid ] [ account_id ], Account [ playerid ] [ account_id ], ARECORD_TYPE_BAN, reason, hours, ReturnDateTime () ) ;
	SendSplitMessageToAll ( COLOR_STAFF, sprintf("[STAFF] %s (%d) has temp-banned %s (%d) for \"%s\"", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid,  reason) ) ;

	WriteLog ( playerid, "mods/trialban", sprintf("[STAFF] %s (%d) has temp-banned %s (%d) for \"%s\"", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid,  reason) ) ;

	SendRconCommand(sprintf("banip %s", ReturnIP ( uid )));
	KickPlayer ( uid ) ;

	return true ;
}

new IsPlayerSpectating [ MAX_PLAYERS ] ;
CMD:spectate(playerid, params[])
{
	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	if (!isnull(params) && !strcmp(params, "off", true))
	{
	    if (GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
			return SendServerMessage(playerid, "You are not spectating any player.", MSG_TYPE_ERROR);

	    PlayerSpectatePlayer(playerid, INVALID_PLAYER_ID);

	    IsPlayerSpectating [ playerid ] = INVALID_PLAYER_ID ;

	 	TogglePlayerSpectating(playerid, false);

	    ac_SetPlayerPos ( playerid, spec_pos_x [ playerid ], spec_pos_y [ playerid ], spec_pos_z [ playerid ] ) ;
	    SetPlayerInterior ( playerid, spec_int [ playerid ] ) ;
	    SetPlayerVirtualWorld( playerid, spec_vw [ playerid ] ) ;

	    //defer DelayedGunAttachments(playerid);

		SendModeratorWarning ( sprintf("[SPEC] %s (%d) has stopped spectating.", ReturnUserName ( playerid, true ), playerid), MOD_WARNING_MED ) ;
		//OldLog ( playerid, "mod/spec", sprintf("%s (%d) has stopped spectating.", ReturnUserName ( playerid, true ), playerid)) ;

		//ReloadPlayerAttachments ( playerid ) ;
		defer DelayAttachmentPlacement(playerid);

	    return SendServerMessage(playerid, "You are no longer in spectator mode.", MSG_TYPE_WARN);
	}

	new userid;

	if (sscanf(params, "k<u>", userid))
		return SendServerMessage(playerid, "/spectate [playerid/name] - Type \"/spectate off\" to stop spectating.", MSG_TYPE_ERROR );

	if (!IsPlayerConnected(userid))
	    return SendServerMessage(playerid, "You have specified an invalid player.", MSG_TYPE_ERROR );

	if (GetPlayerState(playerid) != PLAYER_STATE_SPECTATING) {

		GetPlayerPos(playerid, spec_pos_x [ playerid ], spec_pos_y [ playerid ], spec_pos_z [ playerid ]);

		spec_int [ playerid ] = GetPlayerInterior(playerid);
		spec_vw [ playerid ] = GetPlayerVirtualWorld(playerid);
	}

	SetPlayerInterior(playerid, GetPlayerInterior(userid));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(userid));

	TogglePlayerSpectating(playerid, 1);
	PlayerSpectatePlayer(playerid, userid);

	IsPlayerSpectating [ playerid ] = userid ;

	new buffer[256];
	format ( buffer, sizeof ( buffer ), "(%d) %s's admin note: %s", userid, ReturnUserName(userid), Account [ userid ] [ account_anote] ) ;
	SendClientMessage(playerid, COLOR_YELLOW, buffer);

	//SendServerMessage(playerid, sprintf("You are now spectating %s (ID: %d).", ReturnUserName(userid, false), userid), MSG_TYPE_WARN );

	if ( ! IsPlayerManager ( playerid ) ) {
		SendModeratorWarning ( sprintf("[SPEC] %s (%d) is spectating %s (%d)", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( userid, true ), userid ), MOD_WARNING_MED ) ;
	}

	if(Account[userid][account_rulecheck]) {
		SendServerMessage(playerid,"This player's account is flagged as a \"Potential Rulebreaker\".",MSG_TYPE_WARN);
	}
	
	//OldLog ( playerid, "mod/spec", sprintf("%s (%d) is spectating %s (%d)", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( userid, true ), userid )) ;

	return 1;
}

CMD:spec ( playerid, params [] ) {

	return cmd_spectate ( playerid, params ) ;
}

CMD:lastonline ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new name [ MAX_PLAYER_NAME ] ;

	if ( sscanf ( params, "s[24]", name ) ) {

		return SendServerMessage ( playerid, "/lastonline [master_account]: use /getma to get master account from character", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( name ) > MAX_PLAYER_NAME ) {

		return SendServerMessage ( playerid, "Names can't be longer than 24 characters.", MSG_TYPE_ERROR ) ;
	}

	new query [ 128 ] ;

	inline ReturnAccountLastLogin() {

		new rows, fields, returned_date, date[6] ;
		cache_get_data ( rows, fields, mysql ) ;

		if ( ! rows ) {

			return SendServerMessage ( playerid, "Database didn't return any data. Did you type the name correctly?", MSG_TYPE_WARN ) ;
		}

		if ( rows ) {

			returned_date = cache_get_field_int ( 0, "account_lastlogin" ) ;

			if ( ! returned_date ) { 

				return SendServerMessage ( playerid, "Date cannot be calculated (timestamp is 0)", MSG_TYPE_ERROR ) ;
			}

			TimestampToDate ( returned_date, date[0], date[1], date[2], date[3], date[4], date[5], 1 ) ;

			return SendServerMessage ( playerid, sprintf("{D19932}%s{FFFFFF} was last online at %02d/%02d/%d - %02d:%02d:%02d.", name, date[2], date[1], date[0], date[3], date[4], date[5] ), MSG_TYPE_INFO ) ; 
		}
	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT account_lastlogin FROM master_accounts WHERE account_name = '%e'", name ) ;
	mysql_tquery_inline(mysql, query, using inline ReturnAccountLastLogin, "");

	return true ;
}

CMD:getstate ( playerid, params [] ) {

	new targetid;

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	if ( sscanf ( params, "k<u>", targetid ) ) {

		return SendServerMessage ( playerid, "/getstate [playerid/name]", MSG_TYPE_ERROR ) ;
	}

	SendServerMessage ( playerid, sprintf("%s State Information", ReturnUserName ( targetid, false ) ), MSG_TYPE_INFO ) ;

	SendServerMessage ( playerid, sprintf("{629C5C}Masked{FFFFFF}: %s", ( ReturnPlayerMasked ( targetid ) ) ? ("Yes") : ("No") ), MSG_TYPE_INFO ) ;
	SendServerMessage ( playerid, sprintf("{FF6347}Injured{FFFFFF}: %s", ( Character [ targetid ] [character_dmgmode ] == 1 ) ? ("Yes") : ("No") ), MSG_TYPE_INFO ) ;
	SendServerMessage ( playerid, sprintf("{629C5C}Dead{FFFFFF}: %s", ( Character [ targetid ] [character_dmgmode ] == 2 ) ? ("Yes") : ("No") ), MSG_TYPE_INFO ) ;
	SendServerMessage ( playerid, sprintf("{FF6347}Riding Horse{FFFFFF}: %s", ( IsPlayerRidingHorse [ targetid ] ) ? ("Yes") : ("No") ), MSG_TYPE_INFO ) ;
	SendServerMessage ( playerid, sprintf("{629C5C}Paused{FFFFFF}: %s", ( IsPlayerPaused ( targetid ) ) ? ("Yes") : ("No") ), MSG_TYPE_INFO ) ;

	return true ;
}


CMD:getmasteraccount ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}
	
	new name [ MAX_PLAYER_NAME ] ;

	if ( sscanf ( params, "s[24]", name ) ) {

		return SendServerMessage ( playerid, "/getma(steraccount) [character name]", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( name ) > MAX_PLAYER_NAME ) {

		return SendServerMessage ( playerid, "Names can't be longer than 24 characters.", MSG_TYPE_ERROR ) ;
	}

	new query [ 128 ] ;

	inline ReturnAccountID() {

		new rows, fields, returned_id, returned_name [ MAX_PLAYER_NAME ];
		cache_get_data ( rows, fields, mysql ) ;

		if ( ! rows ) {

			return SendServerMessage ( playerid, "Database didn't return any data. Did you type the name correctly?", MSG_TYPE_WARN ) ;
		}

		if ( rows ) {

			returned_id = cache_get_field_content_int(0, "account_id", mysql ) ;

			inline ReturnAccountName() {

				cache_get_data ( rows, fields, mysql ) ;

				if ( ! rows ) {

					return SendServerMessage ( playerid, "Database didn't return any data. This isn't supposed to happen. You should probably contact a dev.", MSG_TYPE_WARN ) ;
				}

				if ( rows ) {

					cache_get_field_content(0, "account_name", returned_name, mysql, sizeof ( returned_name ) ) ;

					return SendServerMessage ( playerid, sprintf("{D19932}%s's{FFFFFF} master account is {D19932}(%d) %s{FFFFFF}", name, returned_id, returned_name ), MSG_TYPE_INFO ) ; 
				}
			}

			mysql_format ( mysql, query, sizeof ( query ), "SELECT account_name FROM master_accounts WHERE account_id = %d", returned_id ) ;
			mysql_tquery_inline(mysql, query, using inline ReturnAccountName, "");
		}
	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT account_id FROM characters WHERE character_name = '%e'", name ) ;
	mysql_tquery_inline(mysql, query, using inline ReturnAccountID, "");

	return true ;
}

CMD:getma ( playerid, params [ ] ) {
	return cmd_getmasteraccount ( playerid, params ) ;
}

CMD:getcharacters ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new name [ MAX_PLAYER_NAME ] ;

	if ( sscanf ( params, "s[24]", name ) ) {

		return SendServerMessage ( playerid, "/getc(haracters) [master_name]", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( name ) > MAX_PLAYER_NAME ) {

		return SendServerMessage ( playerid, "Names can't be longer than 24 characters.", MSG_TYPE_ERROR ) ;
	}

	new query [ 128 ] ;

	inline ReturnMasterID() {

		new rows, fields, returned_id  ;
		cache_get_data ( rows, fields, mysql ) ;

		if ( ! rows ) {

			return SendServerMessage ( playerid, "Database didn't return any data. Did you type the name correctly?", MSG_TYPE_WARN ) ;
		}

		if ( rows ) {

			returned_id = cache_get_field_content_int(0, "account_id", mysql ) ;

			inline ReturnCharacters() {

				new returned_name [ MAX_PLAYER_NAME ], char_string [ 72 ]  ;
				cache_get_data ( rows, fields, mysql ) ;

				if ( ! rows ) {

					return SendServerMessage ( playerid, "Database didn't return any data. This isn't supposed to happen. You should probably contact a dev.", MSG_TYPE_WARN ) ;
				}

				if ( rows ) {

					for ( new i, p = rows; i < p; i ++ ) {

						cache_get_field_content(i, "character_name", returned_name, mysql, sizeof ( returned_name ) ) ;
						format ( char_string, sizeof ( char_string), "%s (%d) %s", char_string, i, returned_name  ) ;
					}

					SendServerMessage ( playerid, sprintf("Found characters for account {D19932}(%d) %s{FFFFFF}:", returned_id, name ), MSG_TYPE_INFO ) ;
					SendServerMessage ( playerid, sprintf("{D19932}%s{FFFFFF}", char_string ), MSG_TYPE_INFO ) ;

					
				}
			}

			mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM characters WHERE account_id = %d", returned_id ) ;
			mysql_tquery_inline(mysql, query, using inline ReturnCharacters, "");	
		}
	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT account_id FROM master_accounts WHERE account_name = '%e'", name ) ;
	mysql_tquery_inline(mysql, query, using inline ReturnMasterID, "");	

	return true ;
}

CMD:getc ( playerid, params [] ) {
	return cmd_getcharacters ( playerid, params ) ;
}


CMD:makeooc ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new uid ;

	if ( sscanf ( params, "k<u>", uid ) ) {

		return SendServerMessage ( playerid, "/makeooc [player / name]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( uid ) ) {

		return SendServerMessage ( playerid, "Selected player doesn't exist, they might be offline.", MSG_TYPE_INFO ) ;
	}

	if ( ! IsPlayerOOC [ uid ] ) {

		IsPlayerOOC [ uid ] = true ;

		if ( Character [ uid ] [ character_dmgmode ] || PlayerDamage [ uid ] [ DAMAGE_LEGS ] || PlayerDamage [ uid ] [ DAMAGE_ARMS ] ) { 
			
			cmd_stopinjuries ( playerid, Character [ uid ] [ character_name ] ) ; 
		}

		SendServerMessage ( uid, sprintf("You've been made OOC by %s", ReturnUserName ( playerid, true ) ), MSG_TYPE_INFO ) ;
		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has made %s (%d) OOC.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ), MOD_WARNING_LOW ) ;

       	SetName ( uid,  sprintf("(( Out of Character ))\n{[ (%d) %s ]}", uid, ReturnUserName ( uid, false ) ), COLOR_OOC ) ;
		//OldLog ( uid, "mod/oocstatus", sprintf("%s (%d) has made %s (%d) OOC.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ) ) ;
	}

	else if ( IsPlayerOOC [ uid ] ) {

		IsPlayerOOC [ uid ] = false ;

		SendServerMessage ( uid, sprintf("You've been made IC by %s", ReturnUserName ( playerid, true ) ), MSG_TYPE_INFO ) ;
		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has removed %s (%d)'s OOC status.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ), MOD_WARNING_LOW ) ;

		//OldLog ( uid, "mod/oocstatus", sprintf("%s (%d) has removed %s (%d)'s' OOC status.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ) ) ;
       	SetName ( uid,  sprintf("(%d) %s", uid, ReturnUserName ( uid, false ) ), 0xCFCFCFFF ) ;
	}

	return true ;
}

CMD:modduty ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerOnAdminDuty [ playerid ] ) {

		IsPlayerOnAdminDuty [ playerid ] = true ;
		PlayerModWarnings [ playerid ] = true ;

		if ( Character [ playerid ] [ character_dmgmode ] || PlayerDamage [ playerid ] [ DAMAGE_LEGS ] || PlayerDamage [ playerid ] [ DAMAGE_ARMS ] ) { 
			
			cmd_stopinjuries ( playerid, Character [ playerid ] [ character_name ] ) ; 
		}		

		SendServerMessage ( playerid, "You went on mod duty. Please go to /staffisland when you're out of work.", MSG_TYPE_INFO ) ;
		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has gone on mod duty.", ReturnUserName ( playerid, true ), playerid), MOD_WARNING_LOW ) ;

		if ( Account [ playerid ] [ account_id ] == 1 || Account [ playerid ] [ account_id ] == 2 ) {

    		SetName ( playerid, sprintf("(( OOC: Developer on Duty ))\n{[ (%d) %s ]}", playerid, ReturnUserName ( playerid, false ) ), 0x855A83FF ) ;
		}

		else {

			switch ( Account [ playerid ] [ account_stafflevel ] ) {

				case STAFF_MANAGER: {
					
	        		SetName ( playerid, sprintf("(( OOC: Manager on Duty ))\n{[ (%d) %s ]}", playerid, ReturnUserName ( playerid, false ) ), MANAGER_COLOR ) ;
				}

				default: SetName ( playerid, sprintf("(( OOC: Moderator on Duty ))\n{[ (%d) %s ]}", playerid, ReturnUserName ( playerid, false ) ), 0x408040FF ) ;
			}
		}

		//OldLog ( playerid, "mod/modduty", sprintf("%s (%d) has gone on mod duty", ReturnUserName ( playerid, true ), playerid ) ) ;
	}

	else if ( IsPlayerOnAdminDuty [ playerid ] ) {

		IsPlayerOnAdminDuty [ playerid ] = false ;

		SendServerMessage ( playerid, "You've gone off mod duty.", MSG_TYPE_INFO ) ;
		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has gone off mod duty.", ReturnUserName ( playerid, true ), playerid), MOD_WARNING_LOW ) ;

        SetName ( playerid, sprintf("(%d) %s", playerid, ReturnUserName ( playerid, false )), 0xCFCFCFFF ) ;
		//OldLog ( playerid, "mod/modduty", sprintf("%s (%d) has gone off mod duty", ReturnUserName ( playerid, true ), playerid ) ) ;
	}

	return true ;
}

CMD:givelogoutperm ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new uid;

	if ( sscanf ( params, "k<u>", uid ) ) {

		return SendServerMessage ( playerid, "/givelogoutperm [ playerid / name ]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( uid ) ) {

		return SendServerMessage ( playerid, "Selected player doesn't exist, they might be offline.", MSG_TYPE_INFO ) ;
	}

	LogoutPermission [ uid ] = true ;

	SendServerMessage ( uid, "You've been given /logout permission. You can now use /logout.", MSG_TYPE_INFO ) ;
	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has given %s (%d) logout permission.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ), MOD_WARNING_LOW ) ;

	//OldLog ( uid, "mod/logoutperms", sprintf("%s (%d) has given %s (%d) logout permission.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ) ) ;


	return true ;
}


CMD:aooc ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new string[256],text [ 144 ] ;

	if ( sscanf ( params, "s[144]", text ) ) {

		return SendServerMessage ( playerid, "/aooc [ text ]", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( Account [ playerid ] [ account_staffname ] ) == 0 ) {

		format(string,sizeof(string),"(( [AOOC] (%d) %s: %s ))",playerid,ReturnUserName(playerid,false),text);
		SendSplitMessageToAll ( COLOR_ORANGE, string ) ;
	}

	else {

		format(string,sizeof(string),"(( [AOOC] (%d) %s (%s): %s ))", playerid, ReturnUserName ( playerid, false ), Account [ playerid ] [ account_staffname ], text );
		SendSplitMessageToAll ( COLOR_ORANGE, string ) ;
	}

	return true ;
}

CMD:kick ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new uid, reason [ 64 ] ;

	if ( sscanf ( params, "k<u>s[64]", uid, reason ) ) {

		return SendServerMessage ( playerid, "/kick [ playerid / name ] [ reason ]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( uid ) ) {

		return SendServerMessage ( playerid, "Selected player doesn't exist, they might be offline.", MSG_TYPE_INFO ) ;
	}

	if ( strlen ( reason ) > sizeof ( reason ) ) {

		return SendServerMessage ( playerid, "Can't be longer than 64 characters!", MSG_TYPE_ERROR ) ;
	}

	SetDynamicObjectPos ( HorseObject [ uid ], 0.0, 0.0, 0.0 ) ;
	SetDynamicObjectPos ( CowObject [ uid ], 0.0, 0.0, 0.0 ) ;

	SetAdminRecord ( Account [ uid ] [ account_id ], Account [ playerid ] [ account_id ], ARECORD_TYPE_KICK, reason, 0, ReturnDateTime () ) ;
	SendSplitMessageToAll ( COLOR_STAFF, sprintf("[STAFF] %s (%d) has kicked %s (%d) for \"%s\"", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid,  reason) ) ;
	WriteLog ( uid, "mod/kicks", sprintf("%s (%d) has kicked %s (%d) for \"%s\"", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid, reason ) ) ;

	KickPlayer ( uid ) ;

	return true ;
}

CMD:ajail ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new uid, time, reason [ 64 ] ;

	if ( sscanf ( params, "k<u>is[64]", uid, time, reason ) ) {

		return SendServerMessage ( playerid, "/ajail [player] [time in minutes] [reason]", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( reason ) > 64 ) {

		return SendServerMessage ( playerid, "Reason can't be longer than 64 characters!", MSG_TYPE_ERROR ) ;
	}
/*
	if ( time < 10 || time > 120 ) {

		return SendServerMessage ( playerid, "You can't admin jail someone for more than 2 hours or less than 10 minutes.", MSG_TYPE_ERROR ) ;
	}
*/
	//time * 60 ; // 60 seconds

	new query [ 128 ] ;

	//mysql_format(mysql, query, sizeof ( query ), "UPDATE characters SET character_ajailed = '%d' WHERE character_id = '%d'", time, Character [ playerid ] [ SelectedCharacter [ playerid ] ] [ character_id ] ) ;
	mysql_format(mysql, query, sizeof ( query ), "UPDATE characters SET character_ajailed = '%d' WHERE character_id = '%d'", time, Character [ uid ]  [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	// Character [ uid ] [ SelectedCharacter [ uid ] ] [ character_ajailed ] = time ;
	Character [ uid ] [ character_ajailed ] = time ;
	IsPlayerInAdminJail [ uid ] = true ;

	SetAdminRecord ( Account [ uid ] [ account_id ], Account [ playerid ] [ account_id ], ARECORD_TYPE_AJAIL, reason, time, ReturnDateTime () ) ;

	SendSplitMessageToAll ( COLOR_STAFF, sprintf("[STAFF] %s (%d) has ajailed %s (%d) for %d minutes", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid, time) ) ;
	SendSplitMessageToAll ( COLOR_STAFF, sprintf("[STAFF] Reason: \"%s\"", reason ) ) ;

	WriteLog ( uid, "mod/ajail", sprintf("%s (%d) has ajailed %s (%d) for %d minutes. Reason: \"%s\"", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid, time, reason ) ) ;

	AdminJail_Handler () ;

	return true ;
}

CMD:unajail ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new uid ;

	if ( sscanf ( params, "k<u>", uid ) ) {

		return SendServerMessage ( playerid, "/unajail [playerid]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerInAdminJail [ uid ] ) {

		new query [ 128 ] ;

		//mysql_format(mysql, query, sizeof ( query ), "UPDATE characters SET character_ajailed = 0 WHERE character_id = '%d'", Character [ uid ] [ SelectedCharacter [ uid ] ] [ character_id ] ) ;
		mysql_format(mysql, query, sizeof ( query ), "UPDATE characters SET character_ajailed = 0 WHERE character_id = '%d'", Character [ uid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		//Character [ uid ] [ SelectedCharacter [ uid ] ] [ character_ajailed ] = 0 ;
		Character [ uid ] [ character_ajailed ] = 0 ;
		IsPlayerInAdminJail [ uid ] = false ;

		return SendServerMessage ( playerid, "Player doesn't seem to be in admin jail, but their data has been reset nonetheless.", MSG_TYPE_WARN ) ;
	}

	new query [ 256 ] ;

	//mysql_format(mysql, query, sizeof ( query ), "UPDATE characters SET character_ajailed = 0 WHERE character_id = '%d'", Character [ uid ] [ SelectedCharacter [ uid ] ] [ character_id ] ) ;
	mysql_format(mysql, query, sizeof ( query ), "UPDATE characters SET character_ajailed = 0 WHERE character_id = '%d'", Character [ uid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	//Character [ uid ] [ SelectedCharacter [ uid ] ] [ character_ajailed ] = 0 ;
	Character [ uid ]  [ character_ajailed ] = 0 ;
	IsPlayerInAdminJail [ uid ] = false ;

	SendServerMessage ( uid, "You've been released from admin jail. Try to behave this time.", MSG_TYPE_INFO ) ;
	SpawnPlayer_Character ( uid ) ;

	SendSplitMessageToAll ( COLOR_STAFF, sprintf("[STAFF] %s (%d) has unjailed %s (%d)", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid) ) ;
	WriteLog ( uid, "mod/unjail", sprintf("%s (%d) has unjailed %s (%d) ", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ) ) ;

	return true ;
}


CMD:offlinejail ( playerid, params [] ) {


	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new charname [  MAX_PLAYER_NAME ], time, reason [ 64 ] ;

	if ( sscanf ( params, "s[24]is[64]", charname, time, reason ) ) {

		return SendServerMessage ( playerid, "/offlinejail [character] [time in minutes] [reason] ( use /getma or /getc to get acc name )", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( charname ) > MAX_PLAYER_NAME ) {

		return SendServerMessage ( playerid, "Names can't be longer than 24 characters ", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( reason ) > 64 ) {

		return SendServerMessage ( playerid, "Reason can't be longer than 64 characters!", MSG_TYPE_ERROR ) ;
	}

	if ( time < 10 || time > 120 ) {

		return SendServerMessage ( playerid, "You can't admin jail someone for more than 2 hours or less than 10 minutes.", MSG_TYPE_ERROR ) ;
	}

	foreach(new i: Player) {

		if ( ! strcmp(charname, ReturnUserName ( i, true ) ) ) {

			return SendServerMessage ( playerid, sprintf("Player seems to be connected as ID %d. Use /ajail instead.", i ), MSG_TYPE_WARN ) ;
		}
	}

    new query[180], rows, fields, char_id, acc_id ;

	inline ReturnAccountName() {

		cache_get_data ( rows, fields, mysql ) ;

		if ( ! rows ) {

			return SendServerMessage ( playerid, "Database didn't return any account data. Maybe your mistyped the name.", MSG_TYPE_WARN ) ;
		}

		if ( rows ) {

			char_id = cache_get_field_content_int ( 0, "character_id", mysql ) ;
			acc_id = cache_get_field_content_int ( 0, "account_id", mysql ) ;

			mysql_format(mysql, query, sizeof ( query ), "UPDATE characters SET character_ajailed = '%d' WHERE character_id = '%d'", time, char_id ) ;
			mysql_tquery ( mysql, query ) ;

			SetAdminRecord ( acc_id, Account [ playerid ] [ account_id ], ARECORD_TYPE_AJAIL, reason, time, ReturnDateTime () ) ;
			SendSplitMessageToAll ( COLOR_STAFF, sprintf("[STAFF] %s (%d) has offline jailed %s for \"%s\"", ReturnUserName ( playerid, true ), playerid, charname,  reason) ) ;
			WriteLog ( INVALID_PLAYER_ID, "mod/ajail", sprintf("%s (%d) has offline jailed %s for \"%s\"", ReturnUserName ( playerid, true ), playerid, charname,  reason) ) ;
		}
	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT character_id, account_id FROM characters WHERE character_name = '%s'", charname ) ;
	mysql_tquery_inline(mysql, query, using inline ReturnAccountName, "");

	return true ;
}

CMD:ojail ( playerid, params [] ) {

	return cmd_offlinejail ( playerid, params ) ;
}

task AdminJail_Handler[60000]() {

////	print("AdminJail_Handler timer called (basic.pwn)");

	foreach (new playerid: Player) {

		if ( IsPlayerInAdminJail [ playerid ] ) {

			//if ( Character [ playerid ] [ SelectedCharacter [ playerid ] ] [ character_ajailed ] <= 0 ) {
			if ( Character [ playerid ] [ character_ajailed ] <= 0 ) {

				SendServerMessage ( playerid, "You've been released from admin jail. Try to behave this time.", MSG_TYPE_INFO ) ;

				IsPlayerInAdminJail [ playerid ] = false ;

				return SpawnPlayer_Character ( playerid ) ;
			}

			GameTextForPlayer(playerid, 
			//	sprintf("~w~~n~~n~~n~~n~~n~Time left in admin jail:~n~~r~%d~w~ minutes", Character [ playerid ] [ SelectedCharacter [ playerid ] ] [ character_ajailed ] ) , 59500, 3);
				sprintf("~w~~n~~n~~n~~n~~n~Time left in admin jail:~n~~r~%d~w~ minutes", Character [ playerid ] [ character_ajailed ] ) , 59500, 3);

			new query [ 128 ] ;

			//Character [ playerid ] [ SelectedCharacter [ playerid ] ] [ character_ajailed ] -- ;
			Character [ playerid ] [ character_ajailed ] -- ;
			ac_SetPlayerPos ( playerid, 154.1281, -1951.9653, 47.4766 ) ;
			TogglePlayerControllable ( playerid, true ) ;

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_ajailed = '%d' WHERE character_id = '%d'", 
				//Character [ playerid ] [ SelectedCharacter [ playerid ] ] [ character_ajailed ], Character [ playerid ] [ SelectedCharacter [ playerid ] ] [ character_id ] ) ;
				Character [ playerid ] [ character_ajailed ], Character [ playerid ] [ character_id ] ) ;
			mysql_tquery ( mysql, query, "" ) ;
		}
	}

	return true ;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:fw ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new Float: xpos, Float: ypos, Float: zpos ;

	GetPlayerPos ( playerid, xpos, ypos, zpos ) ;
	GetXYInFrontOfPlayer ( playerid, xpos, ypos, 2 ) ;

	ac_SetPlayerPos ( playerid, xpos, ypos, zpos, 0 ) ;

	return true ;
}

CMD:dn ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new Float: xpos, Float: ypos, Float: zpos ;
	GetPlayerPos ( playerid, xpos, ypos, zpos ) ;

	ac_SetPlayerPos ( playerid, xpos, ypos, zpos - 2, 0 ) ;

	return true ;
}

CMD:up ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new Float: xpos, Float: ypos, Float: zpos ;
	GetPlayerPos ( playerid, xpos, ypos, zpos ) ;

	ac_SetPlayerPos ( playerid, xpos, ypos, zpos + 2 , 0 ) ;

	return true ;
}

CMD:freeze ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new uid;

	if ( sscanf ( params, "k<u>", uid ) ) {

		return SendServerMessage ( playerid, "/freeze [ playerid / name ]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( uid ) ) {

		return SendServerMessage ( playerid, "Selected player doesn't exist, they might be offline.", MSG_TYPE_INFO ) ;
	}

	TogglePlayerControllable(uid, false ) ;

	SendServerMessage ( uid, sprintf("You've been frozen by moderator %s (%d)", ReturnUserName ( playerid, true ), playerid ), MSG_TYPE_INFO ) ;
	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has frozen %s (%d).", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ), MOD_WARNING_LOW ) ;

	//OldLog ( uid, "mod/freezes", sprintf("%s (%d) has frozen %s (%d)", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ) ) ;

	return true ;
}

CMD:unfreeze ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new uid;

	if ( sscanf ( params, "k<u>", uid ) ) {

		return SendServerMessage ( playerid, "/unfreeze [ playerid / name ]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( uid ) ) {

		return SendServerMessage ( playerid, "Selected player doesn't exist, they might be offline.", MSG_TYPE_INFO ) ;
	}

	TogglePlayerControllable(uid, true ) ;

	SendServerMessage ( uid, sprintf("You've been unfrozen by moderator %s (%d)", ReturnUserName ( playerid, true ), playerid ), MSG_TYPE_INFO ) ;
	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has unfrozen %s (%d).", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ), MOD_WARNING_LOW ) ;

	//OldLog ( uid, "mod/freezes", sprintf("%s (%d) has unfrozen %s (%d)", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ) ) ;


	return true ;
}

CMD:slap ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new uid;

	if ( sscanf ( params, "k<u>", uid ) ) {

		return SendServerMessage ( playerid, "/slap [ playerid / name ]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( uid ) ) {

		return SendServerMessage ( playerid, "Selected player doesn't exist, they might be offline.", MSG_TYPE_INFO ) ;
	}

    new Float:x, Float:y, Float:z;

	GetPlayerPos ( uid, x, y, z ) ;
	ac_SetPlayerPos ( uid, x, y, z + 4 ) ;

	PlayerPlaySound ( uid, 1190, x, y, z ) ;

	SendServerMessage ( uid, sprintf("You've been slapped by moderator %s (%d)", ReturnUserName ( playerid, true ), playerid ), MSG_TYPE_INFO ) ;
	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has slapped %s (%d).", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ), MOD_WARNING_LOW ) ;

	//OldLog ( uid, "mod/slaps", sprintf("%s (%d) has slapped %s (%d)", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ) ) ;


	return true ;
}

CMD:bring ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new uid, Float: x, Float: y, Float: z ;

	if ( sscanf ( params, "u", uid ) ) {

		return SendServerMessage ( playerid, "/bring [ playerid / name ]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( uid ) ) {

		return SendServerMessage ( playerid, "Selected player doesn't exist, they might be offline.", MSG_TYPE_INFO ) ;
	}

	SendServerMessage ( uid, sprintf("You've been teleported to moderator %s (%d).", ReturnUserName ( playerid, true ), playerid ), MSG_TYPE_INFO ) ;

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has teleported %s (%d) to them.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ), MOD_WARNING_LOW ) ;
	//OldLog ( uid, "mod/teleport", sprintf("%s (%d) has teleported %s (%d) to them", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ) ) ;

	BlackScreen ( uid ) ;

	GetPlayerPos ( playerid, x, y, z ) ;
	ac_SetPlayerPos ( uid, x, y, z ) ;

	SetPlayerInterior ( uid, GetPlayerInterior ( playerid ) ) ;
	SetPlayerVirtualWorld ( uid, GetPlayerVirtualWorld ( playerid ) ) ;

	if(GetCharacterPointID(uid) != -1) {

		if(GetCharacterPointID(playerid) != -1) { SetCharacterPointID(uid,GetCharacterPointID(playerid)); }
		else { ResetCharacterPointID(uid); }
	}
	else {

		if(GetCharacterPointID(playerid) != -1) { SetCharacterPointID(uid,GetCharacterPointID(playerid)); }
	}

//	FadeIn ( uid ) ;

	return true ;
}

CMD:goto ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new uid, Float: x, Float: y, Float: z ;

	if ( sscanf ( params, "k<u>", uid ) ) {

		return SendServerMessage ( playerid, "/goto [ playerid / name ]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( uid ) ) {

		return SendServerMessage ( playerid, "Selected player doesn't exist, they might be offline.", MSG_TYPE_INFO ) ;
	}

	SendServerMessage ( uid, sprintf("Moderator %s (%d) has teleported to you.", ReturnUserName ( playerid, true ), playerid ), MSG_TYPE_INFO ) ;

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has teleported to %s (%d).", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ), MOD_WARNING_LOW ) ;
	//OldLog ( uid, "mod/teleport", sprintf("%s (%d) has teleported to %s (%d).", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid ) ) ;

	GetPlayerPos ( uid, x, y, z ) ;
	ac_SetPlayerPos ( playerid, x, y, z, 0 ) ;

	SetPlayerInterior ( playerid, GetPlayerInterior ( uid ) ) ;
	SetPlayerVirtualWorld ( playerid, GetPlayerVirtualWorld ( uid ) ) ;

	if(GetCharacterPointID(uid) != -1) { SetCharacterPointID(playerid,GetCharacterPointID(uid)); }

	return true ;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if ( newkeys & KEY_FIRE && IsPlayerSpectating [ playerid ] != INVALID_PLAYER_ID ) {

		for ( new i = IsPlayerSpectating [ playerid ] + 1 ; i < GetPlayerPoolSize(); i ++ ) {

			if ( IsPlayerConnected ( i ) && i != playerid ) {

				SetPlayerInterior(playerid, GetPlayerInterior(i));
				SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(i));

				PlayerSpectatePlayer(playerid, i);

				IsPlayerSpectating [ playerid ] = i ;

				SendServerMessage(playerid, sprintf("You are now spectating %s (ID: %d).", ReturnUserName(i, false), i), MSG_TYPE_WARN );

				//SendModeratorWarning ( sprintf("[SPEC] %s (%d) is spectating %s (%d)", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( i, true ), i ), MOD_WARNING_MED ) ;

				return true ;
			}
		}

		for ( new i; i < GetPlayerPoolSize(); i ++ ) {

			if ( IsPlayerConnected ( i ) && i != playerid ) {

				SetPlayerInterior(playerid, GetPlayerInterior(i));
				SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(i));

				PlayerSpectatePlayer(playerid, i);

				IsPlayerSpectating [ playerid ] = i ;

				SendServerMessage(playerid, sprintf("You are now spectating %s (ID: %d).", ReturnUserName(i, false), i), MSG_TYPE_WARN );

				//SendModeratorWarning ( sprintf("[SPEC] %s (%d) is spectating %s (%d)", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( i, true ), i ), MOD_WARNING_MED ) ;

				return true ;
			}
		}
	}

	else if ( newkeys & KEY_AIM && IsPlayerSpectating [ playerid ] != INVALID_PLAYER_ID ) {

		for ( new i = IsPlayerSpectating [ playerid ] - 1 ; i >= 0 ; i -- ) {

			if ( IsPlayerConnected ( i ) && i != playerid ) {

				SetPlayerInterior(playerid, GetPlayerInterior(i));
				SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(i));

				PlayerSpectatePlayer(playerid, i);

				IsPlayerSpectating [ playerid ] = i ;

				SendServerMessage(playerid, sprintf("You are now spectating %s (ID: %d).", ReturnUserName(i, false), i), MSG_TYPE_WARN );

				//SendModeratorWarning ( sprintf("[SPEC] %s (%d) is spectating %s (%d)", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( i, true ), i ), MOD_WARNING_MED ) ;

				return true ;
			}
		}

		for ( new i = MAX_PLAYERS - 1; i >= 0; i -- ) {

			if ( IsPlayerConnected ( i ) && i != playerid ) {

				SetPlayerInterior(playerid, GetPlayerInterior(i));
				SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(i));

				PlayerSpectatePlayer(playerid, i);

				IsPlayerSpectating [ playerid ] = i ;

				SendServerMessage(playerid, sprintf("You are now spectating %s (ID: %d).", ReturnUserName(i, false), i), MSG_TYPE_WARN );

				//SendModeratorWarning ( sprintf("[SPEC] %s (%d) is spectating %s (%d)", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( i, true ), i ), MOD_WARNING_MED ) ;

				return true ;
			}
		}

	}
	#if defined spec_OnPlayerKeyStateChange
		return spec_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif

#define OnPlayerKeyStateChange spec_OnPlayerKeyStateChange
#if defined spec_OnPlayerKeyStateChange
	forward spec_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif