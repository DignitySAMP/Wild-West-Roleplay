CMD:distanceaid(playerid,params[]) {

	if ( ! IsPlayerManager ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a manager in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	new Float:distance;
	if(sscanf(params,"f",distance)) { return SendServerMessage(playerid,"/distanceaid [distance] (-1 will remove checkpoint)",MSG_TYPE_ERROR); }	

	if(distance == -1) {

		DisablePlayerCheckpoint(playerid);
		SendServerMessage(playerid,"Checkpoint distance aid removed.",MSG_TYPE_INFO);
	}
	else {

		new Float:x,Float:y,Float:z;
		GetPlayerPos(playerid,x,y,z);
		GetXYInFrontOfPlayer(playerid,x,y,distance);
		SetPlayerCheckpoint(playerid,x,y,z,1);
		SendServerMessage(playerid,sprintf("Checkpoint is at distance %.02fm.",distance),MSG_TYPE_INFO);
	}
	return true;
}

CMD:makedonator ( playerid, params [] ) {

	if ( ! IsPlayerManager ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a manager in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	new user[MAX_PLAYER_NAME], donlevel;

	if ( sscanf ( params, "s["#MAX_PLAYER_NAME"]i", user, donlevel ) ) {

		return SendServerMessage ( playerid, "/makedonator [master_account] [level 1-3]", MSG_TYPE_ERROR ) ;
	}

	if ( donlevel < 1 || donlevel > 3 ) {

		return SendServerMessage ( playerid, "Invalid donator level.", MSG_TYPE_ERROR ) ;
	}

	new query [ 128 ] ;

	inline manager_SetDonatorRank () {

		new rows, fields;

		cache_get_data ( rows, fields, mysql ) ;

		if ( rows ) {

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_donatorlevel = %d, account_donatorexpire = %d WHERE account_name = '%e'", donlevel, gettime()+2592000, user ) ;
			mysql_tquery ( mysql, query ) ;

			foreach ( new i : Player ) {

				if ( !strcmp ( user, Account [ i ] [ account_name ] ) ) {

					new date [ 6 ] ;

					Account [ i ] [ account_donatorlevel ] = cache_get_field_content_int ( 0, "account_donatorlevel" ) ;
					Account [ i ] [ account_donatorexpire ] = cache_get_field_content_int ( 0, "account_donatorexpire" ) ;

					switch ( Account [ i ] [ account_donatorlevel ] ) {

						case 1: {

							Account [ i ] [ account_namechanges ] = 2 ;
							mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_namechanges = %d WHERE account_name = '%e'", Account [ i ] [ account_namechanges ], user ) ; 

						}

						case 2: {

							Account [ i ] [ account_namechanges ] = 3 ;
							mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_namechanges = %d WHERE account_name = '%e'", Account [ i ] [ account_namechanges ], user ) ; 

						}

						case 3: {

							Account [ i ] [ account_namechanges ] = 4 ;
							mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_namechanges = %d WHERE account_name = '%e'", Account [ i ] [ account_namechanges ], user ) ; 

						}

					}

					mysql_tquery ( mysql, query ) ;

					TimestampToDate ( Account [ i ] [ account_donatorexpire ], date [ 0 ], date [ 1 ], date [ 2 ], date [ 3 ], date [ 4 ], date [ 5 ], 1 ) ;

					SendServerMessage ( i, sprintf("You've been set to %s donator.", GetDonatorRank ( i ) ), MSG_TYPE_INFO ) ;
					SendServerMessage ( i, sprintf("Your donator rank will expire at %d/%d/%d.", date [ 2 ], date [ 1 ], date [ 0 ] ), MSG_TYPE_INFO ) ;

					return true ;
				}

				else continue;
			}

			return SendClientMessageToAll ( COLOR_DEFAULT, sprintf("[DONATOR] %s has been made a donator.", user ) ) ;
		}

		else return SendServerMessage ( playerid, sprintf("The account '%s' does not exist in the database.", user ), MSG_TYPE_ERROR ) ;

	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT account_namechanges, account_donatorlevel, account_donatorexpire FROM master_accounts WHERE account_name = '%e'", user ) ;
	mysql_tquery_inline ( mysql, query, using inline manager_SetDonatorRank, "" ) ;

	return true ;
}

CMD:makestaff ( playerid, params [] ) {

	if ( ! IsPlayerManager ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a manager in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	new uid, lvl ;

	if ( sscanf ( params, "k<u>i", uid, lvl ) ) {

		SendServerMessage ( playerid, "/makestaff [player] [level]", MSG_TYPE_ERROR ) ;
		return SendClientMessage(playerid, -1, "[LEVELS] NONE: Level 0 | SUPPORTER: Level 1 | MODERATOR: Level 2 | MANAGEMENT: Level 3 | DEVELOPER: Level 4" ) ;
	}

	if ( lvl < 0 ||  lvl > 4 ) {

		return SendServerMessage ( playerid, "Can't be less than level 0, or higher than level 4.", MSG_TYPE_ERROR ) ;
	}

	new query [ 128 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_stafflevel = '%d' WHERE account_id = '%d'", lvl, Account [ uid ] [ account_id ] ) ;
	mysql_tquery ( mysql, query ) ;


	Account [ uid ] [ account_stafflevel ] = lvl ;

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has promoted %s (%d) to (%d) %s.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid, lvl, GetStaffRankName ( lvl ) ), MOD_WARNING_HIGH ) ;
	//OldLog ( INVALID_PLAYER_ID, "mod/promote", sprintf("[STAFF] %s (%d) has promoted %s (%d) to (%d) %s.", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid, lvl, GetStaffRankName ( lvl ) ) ) ;

	return true ;
}

CMD:setstaffgroup ( playerid, params [] ) {

	if ( ! IsPlayerManager ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a manager in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	new uid, grp ;

	if ( sscanf ( params, "k<u>i", uid, grp ) ) {

		SendServerMessage ( playerid, "/setstaffgroup [player] [group]", MSG_TYPE_ERROR ) ;
		return SendClientMessage(playerid, -1, "Use the forum to check which groups to pick. Select ID based on hierachy order." ) ;
	}

	if ( grp < 0 ) {

		return SendServerMessage ( playerid, "Can't be less than group 0.", MSG_TYPE_ERROR ) ;
	}

	if ( grp > 4 ) {

		return SendServerMessage ( playerid, "Can't be less than group 4.", MSG_TYPE_ERROR ) ;
	}

	new query [ 128 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_staffgroup = %d WHERE account_id = '%d'", grp, Account [ uid ] [ account_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	Account [ uid ] [ account_staffgroup ] = grp ;

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has set %s (%d)'s staff-group to %d", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid, grp ), MOD_WARNING_HIGH ) ;
	//OldLog ( INVALID_PLAYER_ID, "mod/promote", sprintf("[STAFF] %s (%d) has set %s (%d)'s staff-group to %d", ReturnUserName ( playerid, true ), playerid, ReturnUserName ( uid, true ), uid, grp  )) ;

	return true ;
}


CMD:man(playerid, params [] ) {

	if ( ! IsPlayerManager ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a manager in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	new text [ 144 ] ;

	if ( sscanf ( params, "s[144]", text ) ) {

		return SendServerMessage ( playerid, "/man [text]", MSG_TYPE_ERROR ) ;
	}

	SendManagerMessage ( playerid, text ) ;

	return true ;
}


SendManagerMessage ( playerid, text [] ) {

	new string[256];
	foreach (new i: Player) {

		if ( IsPlayerManager ( i ) ) {

			format(string,sizeof(string),"[MAN] %s (%d){DEDEDE}: %s", ReturnUserName ( playerid, true ), playerid, text ) ;
			SendSplitMessage(i,MANAGER_COLOR,string);
		}
	}

	//OldLog ( playerid, "mod/chats", sprintf("[MAN] %s (%d) said \"%s\"", ReturnDateTime ( ), ReturnUserName ( playerid, true ), playerid, text ) ) ;

	return true ;
}