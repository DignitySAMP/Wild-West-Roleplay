///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:badge ( playerid, params [] ) {

	new posseid = Character [ playerid ] [ character_posse ] ;

	if ( ! IsPlayerInPosse ( playerid ) || !IsLawEnforcementPosse ( posseid ) ) {

		return SendServerMessage ( playerid, "You have to be in a police posse in order to do this command.", MSG_TYPE_INFO ) ;
	}

	new type ;

	if ( sscanf ( params, "i", type ) ) {

		return SendServerMessage ( playerid, "/badge [type: 0 - 3]", MSG_TYPE_ERROR ) ;
	}

	if ( type < 0 || type > 3 ) {

		return SendServerMessage ( playerid, "No lower than 0, or higher than 3!", MSG_TYPE_ERROR ) ;
	}

	switch ( type ) {

		case 0: {
			
			SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, 19347, 1 ) ;
		}
		case 1: {
			
			SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, 19774, 1 ) ;
		}
		case 2: {
			
			SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, 19775, 1 ) ;
		}
		case 3: {
			
			SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, 19776, 1 ) ;
		}
	}

	EditAttachedObject(playerid, ATTACH_SLOT_EQUIP ) ;
	SendServerMessage ( playerid, "You can now edit the badge. Reminder: equipping an item will remove it.", MSG_TYPE_ERROR ) ;

	return true ;
}


CMD:posse ( playerid, params [] ) {
	if ( ! IsPlayerInPosse ( playerid ) ) {

		return SendServerMessage ( playerid, "You're not in a posse.", MSG_TYPE_INFO ) ;	
	}

	new option [ 32 ], value, extra [ 36 ], posseid = Character [ playerid ] [ character_posse ] ;

	if ( sscanf ( params, "s[32]I(-1)S(-1)[36]", option, value, extra) ) {

		return SendServerMessage ( playerid, "/posse [chat, invite, uninvite, tier, rank, spawn, members] [player: optional] [extra: optional]", MSG_TYPE_ERROR ) ;
	} 

	if ( ! strcmp ( option, "chat" ) ) {

		if ( ! Character [ playerid ] [ character_posse ] ) {
			return SendServerMessage ( playerid, "You're not in a posse.", MSG_TYPE_INFO ) ;
		}
		
		if ( Character [ playerid ] [ character_possetier ] < 2 ) {
			return SendServerMessage ( playerid, "You lack the correct privileges to perform this action.", MSG_TYPE_WARN ) ;
		}

		if ( Posse_Chat [ posseid ] ) {
			Posse_Chat [ posseid ] = false ;
			
			return SendPosseWarning ( posseid, sprintf("{[ %s %s (%d) has turned the posse chat off. ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, true ), playerid ) ) ;
		}

		else if ( ! Posse_Chat [ posseid ] ) {
			Posse_Chat [ posseid ] = true ;

			return SendPosseWarning ( posseid, sprintf("{[ %s %s (%d) has turned the posse chat on. ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, true ), playerid ) ) ;
		}


		//OldLog ( playerid, "posse/chat", sprintf ( "%s has toggled the faction chat of ID %d (status: %d) - 0: off, 1: on.", ReturnUserName ( playerid, true ), posseid, Posse_Chat [posseid ] )) ;
	}

	else if ( ! strcmp ( option, "invite" ) ) {

		if ( Character [ playerid ] [ character_possetier ] < 2 ) {

			return SendServerMessage ( playerid, "You lack the correct privileges to perform this action.", MSG_TYPE_WARN ) ;	
		}

		if ( ! IsPlayerConnected ( value ) ) {

			return SendServerMessage ( playerid, "/posse invite [player] - entered player doesn't exist.", MSG_TYPE_ERROR ) ;
		}

		if ( Character [ value ] [ character_posse ] > 0 ) {

			return SendServerMessage ( playerid, "Player is already in a posse.", MSG_TYPE_WARN ) ;	
		}

		Character [ value ] [ character_posse ] 		=  posseid ;
		Character [ value ] [ character_possetier ] 	= 1 ;

		Character [ value ] [ character_posserank ][0] = EOS ;
		strcat(Character [ value ] [ character_posserank ], "Newcomer", 36 ) ;

		SendPosseWarning ( posseid, sprintf("{[ %s %s (%d) has invited %s (%d) to join the posse. ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, true ), playerid, ReturnUserName ( value, true ), value ));
		SavePlayerFactionData ( value ) ;

		//OldLog ( playerid, "posse/invite", sprintf ( "%s has invited %s to join posse ID %d", ReturnUserName ( playerid, true ), ReturnUserName ( value, true ), posseid)) ;

		return true ;
	}

	else if ( ! strcmp ( option, "uninvite" ) ) {

		if ( Character [ playerid ] [ character_possetier ] < 3 ) {
			return SendServerMessage ( playerid, "Only the posse leader can perform this action.", MSG_TYPE_ERROR ) ;
		}

		if ( ! IsPlayerConnected ( value ) ) {

			return SendServerMessage ( playerid, "/posse uninvite [player] - entered player doesn't exist.", MSG_TYPE_ERROR ) ;
		}

		SendPosseWarning ( posseid, sprintf("{[ %s %s (%d) has removed %s (%d) from the posse. ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, true ), playerid, ReturnUserName ( value, true ), value ));
		//OldLog ( playerid, "posse/uninvite", sprintf ( "%s has kicked %s from posse ID %d", ReturnUserName ( playerid, true ), ReturnUserName ( value, true ), posseid)) ;

		Character [ value ] [ character_posse ] 		= -1 ;
		Character [ value ] [ character_possetier ] 	= 0 ;

		Character [ value ] [ character_posserank ][0] = EOS ;
		strcat(Character [ value ] [ character_posserank ], "None", 36 ) ;

		SavePlayerFactionData ( value ) ;

		return true ;
	}

	else if ( ! strcmp ( option, "tier" ) ) {

		new tier = strval ( extra ) ;

		if ( Character [ playerid ] [ character_possetier ] < 3 ) {

			return SendServerMessage ( playerid, "You lack the correct privileges to perform this action.", MSG_TYPE_WARN ) ;
		}

		if ( ! IsPlayerConnected ( value ) ) {

			return SendServerMessage ( playerid, "/posse tier [player] [tier] - entered player doesn't exist.", MSG_TYPE_ERROR ) ;
		}
		
		if ( tier < 1 || tier > 3 ) {
			return SendServerMessage ( playerid, "Tier can't be less than 1 or more than 3.", MSG_TYPE_WARN ) ;
		}
		
		Character [ value ] [ character_possetier ] = tier ;

		SendPosseWarning ( posseid, sprintf("{[ %s %s (%d) has set %s (%d)'s tier to %d. ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, true ), playerid, ReturnUserName ( value, true ), value, tier ));
		//OldLog ( playerid, "posse/tier", sprintf ( "%s has set %s's tier to %d (posseid: %d)", ReturnUserName ( playerid, true ), ReturnUserName ( value, true ), tier, posseid)) ;

		SavePlayerFactionData ( value ) ;

		return true ;
	}

	else if ( ! strcmp ( option, "rank" ) ) {

		if ( ! IsPlayerConnected ( value ) ) {

			return SendServerMessage ( playerid, "/posse rank [player] [rank] - entered player doesn't exist.", MSG_TYPE_ERROR ) ;
		}

		if ( Character [ playerid ] [ character_possetier ] < 2 ) {

			return SendServerMessage ( playerid, "You lack the correct privileges to perform this action.", MSG_TYPE_WARN ) ;
		}

		if ( strlen ( extra ) > MAX_POSSE_NAME ) {

			return SendServerMessage ( playerid, "Rank can't be longer than 36 characters.", MSG_TYPE_WARN ) ;
		}

		Character [ value ] [ character_posserank ][0] = EOS ;
		strcat(Character [ value ] [ character_posserank ], extra, 36 ) ;

		SendPosseWarning ( posseid, sprintf("{[ %s %s (%d) has set %s (%d)'s rank to %s. ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, true ), playerid, ReturnUserName ( value, true ), value, extra ));
		//OldLog ( playerid, "posse/rank", sprintf ( "%s has set %s's rank to %s (posseid: %d)", ReturnUserName ( playerid, true ), ReturnUserName ( value, true ), extra, posseid)) ;

		SavePlayerFactionData ( value ) ;

		return true ;
	}

	else if ( ! strcmp ( option, "spawn" ) ) {

		if ( ! Character [ playerid ] [ character_posse ] ) {
			return SendServerMessage ( playerid, "You're not in a posse.", MSG_TYPE_INFO ) ;
		}
		
		if ( Character [ playerid ] [ character_possetier ] < 3 ) {
			return SendServerMessage ( playerid, "You lack the correct privileges to perform this action.", MSG_TYPE_WARN ) ;
		}

		new Float: pos_x, Float: pos_y, Float: pos_z, p_int = GetPlayerInterior ( playerid ), p_vw = GetPlayerVirtualWorld ( playerid ), query [ 256 ] ;
		GetPlayerPos ( playerid, pos_x, pos_y, pos_z ) ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE posses SET posse_spawn_x = '%f', posse_spawn_y = '%f', posse_spawn_z = '%f', posse_spawn_int = '%d', posse_spawn_vw = '%d' WHERE posse_id = %d", 
			pos_x, pos_y, pos_z, p_int, p_vw, posseid ) ;

		mysql_tquery ( mysql, query ) ;  

		Init_LoadPosses () ;

		//OldLog ( playerid, "posse/spawn", sprintf ( "%s has set posseid: %d's spawnpoint to %0.2f, %0.2f, %0.2f", ReturnUserName ( playerid, true ), posseid, pos_x, pos_y, pos_z )) ;

		return SendPosseWarning ( posseid, sprintf("{[ %s %s (%d) has changed the faction spawnpoint. ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, true ), playerid ) ) ;
	}

	else if ( ! strcmp ( option, "kiosk" ) ) {

		if ( ! Character [ playerid ] [ character_posse ] ) {
			return SendServerMessage ( playerid, "You're not in a posse.", MSG_TYPE_INFO ) ;
		}

		return SendServerMessage(playerid,"Use /possekiosk instead.",MSG_TYPE_ERROR);
		/*
		
		if ( Character [ playerid ] [ character_possetier ] < 3 ) {
			return SendServerMessage ( playerid, "You lack the correct privileges to perform this action.", MSG_TYPE_WARN ) ;
		}

		new Float: pos_x, Float: pos_y, Float: pos_z, Float: rot_z, query[256];
		GetPlayerPos ( playerid, pos_x, pos_y, pos_z ) ;
		GetPlayerFacingAngle ( playerid, rot_z ) ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE posses SET kiosk_x = '%f', posse_kiosk_y = '%f', posse_kiosk_z = '%f', posse_kiosk_rx = '%f', posse_kiosk_ry = '%f', posse_kiosk_rz = '%f' WHERE posse_id = %d", 
			pos_x, pos_y, pos_z, 0.0, 0.0, rot_z, posseid ) ;

		mysql_tquery ( mysql, query ) ;  

		Init_LoadPosses () ;

		//OldLog ( playerid, "posse/spawn", sprintf ( "%s has set posseid: %d's spawnpoint to %0.2f, %0.2f, %0.2f", ReturnUserName ( playerid, true ), posseid, pos_x, pos_y, pos_z )) ;

		return SendPosseWarning ( posseid, sprintf("{[ %s %s (%d) has changed the faction kiosk spawnpoint. ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, true ), playerid ) ) ;
		*/
	}

	else if ( ! strcmp ( option, "members" ) ) {

		new string [ 1024 ], query [ 128 ] ;
		if ( ! Character [ playerid ] [ character_posse ] ) {
			
			return SendServerMessage ( playerid, "You're not in a posse.", MSG_TYPE_INFO ) ;
		}

		inline posse_ShowMembers(pid, dialogid, response, listitem, string:inputtext[]) { 
			
			#pragma unused pid, dialogid, response, listitem, inputtext		
		}


		foreach ( new i : Player ) {

			if ( Character [ i ] [ character_posse ] == posseid ) {

				strcat ( string, sprintf("{629C5C}[ONLINE]:{DEDEDE} %s %s\n", Character [ i ] [ character_posserank ], ReturnUserName ( i, true ) ) ) ;
			}
			else continue;
		}

		inline posse_OfflineMembers() {

			new rows, fields, pname[MAX_PLAYER_NAME], prank[36], bool: skipresult;

			cache_get_data ( rows, fields, mysql ) ;

			if ( rows ) {

				query [ 0 ] = EOS ;

				for ( new i, j = rows; i < j; i ++ ) {

					new char_id = cache_get_field_content_int(i, "character_id", mysql ) ;

					cache_get_field_content ( i, "character_name", pname, mysql, MAX_PLAYER_NAME ) ;
					cache_get_field_content ( i, "character_posserank", prank, mysql, 36 ) ;

					foreach ( new ix: Player ) {

						if ( char_id == Character [ ix ] [ character_id ] ) {

							skipresult = true ;
						}

						else continue ;
					}

					if ( ! skipresult ) {
						strcat ( string, sprintf("{FF6347}[OFFLINE]:{DEDEDE} %s %s\n", prank, pname ) ) ;

					}

					else if ( skipresult ) {
						skipresult = false ;
						continue ;
					}
				}
			}

			return Dialog_ShowCallback ( playerid, using inline posse_ShowMembers, DIALOG_STYLE_LIST, "Posse Members", string, "Exit", "" ) ;

		}

		mysql_format ( mysql, query, sizeof ( query ), "SELECT character_id, character_name, character_posserank FROM characters WHERE character_posse = %d", posseid ) ;
		return mysql_tquery_inline ( mysql, query, using inline posse_OfflineMembers, "" ) ;

	}

	return SendServerMessage ( playerid, "/posse [invite, uninvite, tier, rank, spawn, members] [player: optional] [extra: optional]", MSG_TYPE_ERROR) ;
}

SavePlayerFactionData ( playerid ) {

	new query [ 256 ] ;

	mysql_format(mysql, query, sizeof ( query ), "UPDATE characters SET character_posse = '%d', character_possetier = '%d', character_posserank = '%s' WHERE character_id = '%d'", 
		Character [ playerid ] [ character_posse ],	Character [ playerid ] [ character_possetier ], Character [ playerid ] [ character_posserank ], Character [ playerid ] [ character_id] ) ;

	mysql_tquery ( mysql, query ) ;

	return true ;
}

CMD:possechat ( playerid, params [] ) {
	new text [ 144 ], string [ 256 ], posseid = Character [ playerid ] [ character_posse ] ;

	if ( ! IsPlayerInPosse ( playerid ) ) {

		return SendServerMessage ( playerid, "You're not in a posse.", MSG_TYPE_INFO ) ;
	}

	if ( sscanf ( params, "s[144]", text ) ) {

		return SendServerMessage ( playerid, "/possechat <text>", MSG_TYPE_ERROR ) ;
	}

	if ( ! Posse_Chat [ posseid ] && Character [ playerid ] [ character_possetier ] < 2 ) {
		return SendServerMessage ( playerid, "Posse chat is off.", MSG_TYPE_ERROR) ;
	}

	format ( string, sizeof ( string ), "{[ %s %s (%d): %s ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, true ), playerid, text);

	//OldLog ( playerid, "posse/chat", sprintf ( "%s in posseid: %d: %s", ReturnUserName ( playerid, true ), posseid, text)) ;

	SendPosseMessage ( posseid, string ) ;

	return true ;
}

CMD:pc ( playerid, params [] ) return cmd_possechat ( playerid, params ) ; 

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:aposse ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < ADVANCED_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a advanced moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	// add sots
	new option [ 32 ], value, extra [ 36 ] ;

	if ( sscanf ( params, "s[32]I(0)S(-1)[36]", option, value, extra) ) {

		return SendServerMessage ( playerid, "/aposse [create, delete, leader, name, type] [extra: optional]", MSG_TYPE_ERROR ) ;
	} 

	new query [ 256 ] ;

	if ( ! strcmp ( option, "create" ) ) {

		if ( ! value || strlen ( extra ) < 0 ) {

			return SendServerMessage ( playerid, "/aposse create [slots] [name]", MSG_TYPE_ERROR ) ;
		}

		CreatePosse ( extra, 1, value ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) created posse \"%s\" with %d slots.", ReturnUserName ( playerid, true ), playerid,  extra, value ), MOD_WARNING_MED ) ;
		//OldLog ( playerid, "mod/faction", sprintf( "%s (%d) created posse \"%s\" with %d slots.", ReturnUserName ( playerid, true ), playerid,  extra, value )) ;

		SendServerMessage ( INVALID_PLAYER_ID, "Assign a type and type using /aposse type and /aposse leader.", MSG_TYPE_WARN ) ;
		//OldLog ( playerid, "aposse/create", sprintf ( "%s created posse with name %s, slot %d", ReturnUserName ( playerid, true ), extra, value)) ;


		return true ;
	}

	else if ( ! strcmp ( option, "delete" ) ) {

		if ( ! IsValidPosse ( value ) ) {
			
			return SendServerMessage ( playerid, "Selected posse doesn't exist.", MSG_TYPE_INFO ) ;
		}

		inline PosseDeletionWarning(pid, dialogid, response, listitem, string:inputtext[]) {

			#pragma unused inputtext, listitem, dialogid, pid

			if ( ! response ) {

				return false ;
			}

			new string [ 36 ] ;

			SendModeratorWarning ( sprintf("[STAFF] %s (%d) deleted posse \"%s\" (%d).", ReturnUserName ( playerid, true ), playerid,  Posse [ value ] [ posse_name ], value ), MOD_WARNING_MED ) ;
			DeletePosse ( value );

			foreach ( new i : Player ) {

				if ( Character [ i ] [ character_posse ] == value ) {

					format ( string, sizeof ( string ), "None" );

					Character [ i ] [ character_posse ] = 0;
					Character [ i ] [ character_possetier ] = 0;
					Character [ i ] [ character_posserank ] = string;
				}

				else continue ;
			}
		}

    	Dialog_ShowCallback(playerid, using inline PosseDeletionWarning, DIALOG_STYLE_MSGBOX, "{C23030}ABUSE WARNING", "{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\nYou're about to delete a posse.\nIf you're abusing this option, you will be caught and PERMANENTLY banned.\n\nWith that in mind, go ahead.", "{C23030}Proceed", "Cancel" ) ;
	}

	else if ( ! strcmp ( option, "name" ) ) {

		if ( ! IsValidPosse ( value ) ) {
			
			return SendServerMessage ( playerid, "Selected posse doesn't exist.", MSG_TYPE_INFO ) ;
		}

		if ( strlen ( extra ) >= MAX_POSSE_NAME || strlen ( extra ) < 4 ) {
			
			return SendServerMessage ( playerid, "Name can't be longer than 36 or less than 4 characters.", MSG_TYPE_INFO ) ;
		}

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE posses SET posse_name = '%s' WHERE posse_id = %d", extra, value) ;
		mysql_tquery ( mysql, query ) ;  

		SendPosseWarning ( value, sprintf("{[ Admin %s (%d) has changed the posse's name to %s. ]}", ReturnUserName ( playerid, true ), playerid, extra )) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) renamed posse ID %d to %s.", ReturnUserName ( playerid, true ), playerid, value, extra ), MOD_WARNING_LOW ) ;
		//OldLog ( INVALID_PLAYER_ID, "mod/faction", sprintf( "%s (%d) renamed posse ID %d to %s.", ReturnUserName ( playerid, true ), playerid, value, extra )) ;

		//OldLog ( playerid, "aposse/name", sprintf ( "%s set posseid %d's name to %s", ReturnUserName ( playerid, true ), value, extra )) ;

		Init_LoadPosses();
		return true ;
	}

	else if ( ! strcmp ( option, "leader" ) ) {

		if ( ! IsValidPosse ( value ) ) {
			
			return SendServerMessage ( playerid, "Selected posse doesn't exist.", MSG_TYPE_INFO ) ;
		}

		Character [ playerid ] [ character_posse ] 		= value ;
		Character [ playerid ] [ character_possetier ] 	= 3 ;

		Character [ playerid] [ character_posserank ] [ 0 ] = EOS ;
		strcat(Character [ playerid ] [ character_posserank ], "Admin", 36 ) ;

		SendPosseWarning ( value, sprintf("{[ Admin %s (%d) has made themselves the leader of the posse. ]}", ReturnUserName ( playerid, true ), playerid )) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has made themselves leader of posse ID %d.", ReturnUserName ( playerid, true ), playerid, value ), MOD_WARNING_MED ) ;
		//OldLog ( playerid, "mod/faction", sprintf( "%s (%d)has made themselves leader of posse ID %d.", ReturnUserName ( playerid, true ), playerid, value )) ;

		//OldLog ( playerid, "aposse/name", sprintf ( "%s made themselves leader of posseid %d", ReturnUserName ( playerid, true ), value )) ;

		SavePlayerFactionData ( playerid ) ;

		return true ;
	}

	else if ( ! strcmp ( option, "type" ) ) {

		if ( ! IsValidPosse ( value ) ) {
			
			return SendServerMessage ( playerid, "Selected posse doesn't exist.", MSG_TYPE_INFO ) ;
		}

		new type = strval ( extra ) ;
		Posse [ value ] [ posse_type ] = type ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE posses SET posse_type = '%d' WHERE posse_id = %d", type, Posse [ value ] [ posse_id ] ) ;
		mysql_tquery ( mysql, query ) ;  

		SendPosseWarning ( value, sprintf("{[ Admin %s (%d) has changed the posse's type to %d. ]}", ReturnUserName ( playerid, true ), playerid, type ) ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set posse ID %d's type to %d.", ReturnUserName ( playerid, true ), playerid, value, type ), MOD_WARNING_LOW ) ;
		//OldLog ( INVALID_PLAYER_ID, "mod/faction", sprintf( "%s (%d) has set posse ID %d's type to %d.", ReturnUserName ( playerid, true ), playerid, value, type )) ;

		//OldLog ( playerid, "aposse/name", sprintf ( "%s changed posseid %d's type to %d", ReturnUserName ( playerid, true ), value, type )) ;
		Init_LoadPosses();

		return true ;
	}


	return true ;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//David

CMD:possebank( playerid, params [] ) {
	new option [ 16 ], amount, cents, query [ 256 ], posseid = Character [ playerid ] [ character_posse ] ;

	if ( ! IsPlayerInPosse ( playerid ) ) {

		return SendServerMessage ( playerid, "You're not in a posse.", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerInRangeOfPoint ( playerid, 3.5, Posse [ posseid ] [ posse_spawn_x ], Posse [ posseid ] [ posse_spawn_y ], Posse [ posseid ] [ posse_spawn_z ] ) ) {

		return SendServerMessage ( playerid, "You're not at your posse's spawn point.", MSG_TYPE_ERROR ) ;
	}

	if ( sscanf ( params, "s[16]I(-1)I(0)", option, amount, cents ) ) {

		return SendServerMessage ( playerid, "/p(osse)bank [balance, deposit, withdraw] [optional:dollars] [optional:cents]", MSG_TYPE_ERROR ) ;
	}

	if ( !strcmp ( option, "balance", true) ) {

		return SendServerMessage ( playerid, sprintf( "%s's Bank Balance: $%s.%02d", Posse [ posseid ] [ posse_name ], IntegerWithDelimiter ( Posse [ posseid ] [ posse_bank ] ),Posse[posseid][posse_bank_decimal] ), MSG_TYPE_INFO ) ;
	}

	else if ( !strcmp ( option, "deposit", true) ) {

		if ( amount == -1 ) {

			return SendServerMessage ( playerid, "You need to input a value.", MSG_TYPE_ERROR ) ;
		}

		if ( Character [ playerid ] [ character_handmoney ] < amount ) {

			return SendServerMessage ( playerid, "You don't have that much money to deposit.", MSG_TYPE_ERROR ) ;
		}

		if(cents < 1 || cents > 99) {

			return SendServerMessage(playerid,"You can only give between 1-99 cent(s).", MSG_TYPE_ERROR);
		}

		inline PosseBankDepositWarning(pid, dialogid, response, listitem, string:inputtext[]) {

			#pragma unused inputtext, listitem, dialogid, pid

			if ( ! response ) {

				return false ;
			}

			Posse [ posseid ] [ posse_bank ] += amount ;
			if(cents) { Posse [ posseid ] [ posse_bank_decimal ] += cents; }
			TakeCharacterMoney ( playerid, amount, MONEY_SLOT_HAND ) ;
			if(cents) { TakeCharacterChange(playerid,cents,MONEY_SLOT_HAND); }

			SendPosseMessage ( posseid, sprintf("%s (%d) has deposited $%s.%02d into the posse's bank.", ReturnUserName ( playerid, true ), playerid, IntegerWithDelimiter( amount ),cents ) ) ;

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE posses SET posse_bank = '%d', posse_bank_decimal = '%d' WHERE posse_id = %d", Posse [ posseid ] [ posse_bank ], Posse [ posseid ] [posse_bank_decimal], Posse [ posseid ] [ posse_id ] ) ;
			mysql_tquery ( mysql, query ) ;

			//LOG_NEEDED: /possebank deposit 

		}

    	Dialog_ShowCallback(playerid, using inline PosseBankDepositWarning, DIALOG_STYLE_MSGBOX, "{C23030}WARNING", "{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\nYou're about to deposit your money into the posse's bank.\nYou will be unable to obtain your money back without having tier 3.\n\nWith that in mind, go ahead.", "{C23030}Proceed", "Cancel" ) ;
	}

	else if ( !strcmp ( option, "withdraw", true) ) {

		if ( Character [ playerid ] [ character_possetier ] < 3 ) {

			return SendServerMessage ( playerid, "You lack the correct privileges to perform this action.", MSG_TYPE_WARN ) ;	
		}

		if ( amount == -1 ) {

			return SendServerMessage ( playerid, "You need to input a value.", MSG_TYPE_ERROR ) ;
		}

		if ( Posse [ posseid ] [ posse_bank ] < amount ) {

			return SendServerMessage ( playerid, "The posse's bank doesn't have that much money to withdraw.", MSG_TYPE_ERROR ) ;
		}

		if(cents < 1 || cents > 99) {

			return SendServerMessage(playerid,"You can only take between 1-99 cent(s).", MSG_TYPE_ERROR);
		}

		inline PosseBankWithdrawWarning(pid, dialogid, response, listitem, string:inputtext[]) {

			#pragma unused inputtext, listitem, dialogid, pid

			if ( ! response ) {

				return false ;
			}

			Posse [ posseid ] [ posse_bank ] -= amount ;
			if(cents) { Posse[posseid][posse_bank_decimal] -= cents; }
			GiveCharacterMoney ( playerid, amount, MONEY_SLOT_HAND ) ;
			if(cents) { GiveCharacterChange(playerid,cents,MONEY_SLOT_HAND); }

			SendPosseMessage ( posseid, sprintf("%s (%d) has withdrawn $%s.%02d from the posse's bank.", ReturnUserName ( playerid, true ), playerid, IntegerWithDelimiter( amount ),cents ) ) ;

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE posses SET posse_bank = '%d', posse_bank_decimal = '%d' WHERE posse_id = %d", Posse [ posseid ] [ posse_bank ], Posse [ posseid ] [ posse_bank_decimal], Posse [ posseid ] [ posse_id ] ) ;
			mysql_tquery ( mysql, query ) ; 

			//LOG_NEEDED: /possebank withdraw

		}

    	Dialog_ShowCallback(playerid, using inline PosseBankWithdrawWarning, DIALOG_STYLE_MSGBOX, "{C23030}ABUSE WARNING", "{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\nYou're about to withdraw money from the posse's bank.\nAbuse of this will lead to you being caught, and you being /PERMANENTLY/ banned.\n\nWith that in mind, go ahead.", "{C23030}Proceed", "Cancel" ) ;
	}

	return true ;
}

CMD:pbank ( playerid, params [] ) return cmd_possebank ( playerid, params ) ; 