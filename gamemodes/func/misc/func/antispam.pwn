#define 	MIN_CMD_GAP_INTERVAL    1750

new g_PlayerLastActionPerformed [ MAX_PLAYERS ] ; 

public OnPlayerConnect(playerid) {

	g_PlayerLastActionPerformed[playerid] = 0;
	
	#if defined antispam_OnPlayerConnect
		return antispam_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect antispam_OnPlayerConnect
#if defined antispam_OnPlayerConnect
	forward antispam_OnPlayerConnect(playerid);
#endif

public OnPlayerCommandReceived(playerid, cmdtext[]) {

	if ( ! IsPlayerLogged [ playerid ] || ! PassedSelectionScreen [ playerid ] ) {

		if(!strcmp(cmdtext,"/charactercreate")) {
			
			if(IsPlayerCreatingCharacter[playerid]) { return true; }
			else { 

				SendServerMessage(playerid,"You need to be in character creation to use this command.",MSG_TYPE_ERROR);
				return false;
			}
		}
		else {

			SendServerMessage ( playerid, "You need to spawn properly before you can use a command!", MSG_TYPE_ERROR ) ;
			return false ;
		}
	}

	if ( IsPlayerSleepingInPoint [ playerid ] ) {

			if ( strcmp ( cmdtext, "/point sleep" ) ) {
				
				SendServerMessage ( playerid, "You can't use any commands while using /point sleep.", MSG_TYPE_ERROR ) ;
				return false ;
			}
		}

	//Have exception towards administrators.
	if ( IsPlayerModerator ( playerid ) ) return true ;

	new temp_Tick = GetTickCount(), temp_tickDiff ;
	temp_tickDiff = temp_Tick - g_PlayerLastActionPerformed [playerid];
	
	if(temp_tickDiff < MIN_CMD_GAP_INTERVAL) {
	
	    SendServerMessage ( playerid, sprintf("You must wait %0.2f seconds to use any command.", float(MIN_CMD_GAP_INTERVAL - temp_tickDiff) / 1000.0), MSG_TYPE_WARN );

	    return false ;
	}

	foreach (new i: Player) {

		if ( IsPlayerSpectating [ i ] == playerid ) {

			SendClientMessage(i, 0xDEDEDEFF, sprintf("[SPEC]: (%d) %s tried command (received): %s", playerid, ReturnUserName ( playerid, true, false ), cmdtext ) ) ;
			continue ;
		}

		else continue ;
	}
	
	#if defined spam_OnPlayerCommandReceived
		return spam_OnPlayerCommandReceived(playerid, cmdtext);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerCommandReceived
	#undef OnPlayerCommandReceived
#else
	#define _ALS_OnPlayerCommandReceived
#endif

#define OnPlayerCommandReceived spam_OnPlayerCommandReceived
#if defined spam_OnPlayerCommandReceived
	forward spam_OnPlayerCommandReceived(playerid, cmdtext[]);
#endif

public OnPlayerCommandPerformed(playerid, cmdtext[], success) {

	if ( success ) {

	    g_PlayerLastActionPerformed[playerid] = GetTickCount();

		if ( ! IsPlayerLogged [ playerid ] || ! PassedSelectionScreen [ playerid ] ) {

			if(!strcmp(cmdtext,"/charactercreate")) {
				
				if(IsPlayerCreatingCharacter[playerid]) { return true; }
				else { 

					SendServerMessage(playerid,"You need to be in character creation to use this command.",MSG_TYPE_ERROR);
					return false;
				}
			}
			else {

				SendServerMessage ( playerid, "You need to spawn properly before you can use a command!", MSG_TYPE_ERROR ) ;
				return false ;
			}
		}

		if ( IsPlayerSleepingInPoint [ playerid ] ) {

			if ( strcmp ( cmdtext, "/point sleep" ) ) {

				SendServerMessage ( playerid, "You can't use any commands while using /point sleep.", MSG_TYPE_ERROR ) ;
				return false ;
			}
		}


		foreach (new i: Player) {

			if ( IsPlayerSpectating [ i ] == playerid ) {

				SendClientMessage(i, 0xDEDEDEFF, sprintf("[SPEC]: (%d) %s tried command (performed): %s", playerid, ReturnUserName ( playerid, true, false ), cmdtext ) ) ;
				continue ;
			}

			else continue ;
		}

	}
	    
	else if ( ! success ) {

		return SendServerMessage ( playerid, "This command doesn't exist. To view a list of all available commands, use /help", MSG_TYPE_INFO ) ;
	}

	
	#if defined spam_OnPlayerCommandPerformed
		return spam_OnPlayerCommandPerformed(playerid, cmdtext, success);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerCommandPerformed
	#undef OnPlayerCommandPerformed
#else
	#define _ALS_OnPlayerCommandPerformed
#endif

#define OnPlayerCommandPerformed spam_OnPlayerCommandPerformed
#if defined spam_OnPlayerCommandPerformed
	forward spam_OnPlayerCommandPerformed(playerid, cmdtext[], success);
#endif