/*
new bool: IsIgnoringPlayerPause [ MAX_PLAYERS ] ;

timer IgnoreConstantPauseTick[3000](playerid) {

////	print("IgnoreConstantPauseTick timer called (pause.pwn)");

	IsIgnoringPlayerPause [playerid] = false ;
}*/

// YSF


new AFKVariable [ MAX_PLAYERS ], bool:HasPlayerUsedAFKCommand[MAX_PLAYERS] ;

IsPlayerUsingAFKCommand(playerid) { return HasPlayerUsedAFKCommand[playerid]; }

public OnPlayerPause(playerid) {
/*
	if ( ! IsIgnoringPlayerPause [ playerid ] ) {
		SendModeratorWarning ( sprintf ("[PAUSE] (%d) %s has paused.", playerid, ReturnUserName ( playerid, true ) ), MOD_WARNING_LOW ) ;

		IsIgnoringPlayerPause = true ;
		defer IgnoreConstantPauseTick(playerid) ;
	}*/


	if ( Character [ playerid ] [ character_dmgmode ] ) {

		if ( CharSwitchTick [ playerid ] ) {

        	return SetName ( playerid, sprintf("[\n[PAUSED (/afklist)]\nPLAYER IS INJURED]{007FFF}[SWITCHING CHARACTERS]{DEDEDE}\n(%d) %s", playerid, ReturnUserName ( playerid, false, true )), COLOR_RED ) ;
		}

		else return SetName ( playerid,  sprintf("[PAUSED (/afklist)]\n(%d) %s", playerid, ReturnUserName ( playerid, false, true ) ), COLOR_RED ) ;
	}

	if ( IsPlayerOOC [ playerid ] ) {

		return SetName ( playerid,  sprintf("[PAUSED (/afklist)]{AAC4E5}\n(( Out of Character ))\n{[ (%d) %s ]}", playerid, ReturnUserName ( playerid, false, true ) ), COLOR_RED ) ;
	}

	if ( IsPlayerOnAdminDuty [ playerid ] ) {

		if ( Account [ playerid ] [ account_id ] == 1 || Account [ playerid ] [ account_id ] == 2 ) {

			return SetName ( playerid, sprintf("[PAUSED (/afklist)]{855A83}\n(( OOC: Developer on Duty ))\n{[ (%d) %s ]}", playerid, ReturnUserName ( playerid, false, true ) ), COLOR_RED ) ;
		}

		else {

			switch ( Account [ playerid ] [ account_stafflevel ] ) {

				case STAFF_MANAGER: {
					return SetName ( playerid, sprintf("[PAUSED (/afklist)]{AD2D2D}\n(( OOC: Manager on Duty ))\n{[ (%d) %s ]}", playerid, ReturnUserName ( playerid, false, true ) ), COLOR_RED ) ;
				}

				default: return SetName ( playerid, sprintf("[PAUSED (/afklist)]{408040}\n(( OOC: Moderator on Duty ))\n{[ (%d) %s ]}", playerid, ReturnUserName ( playerid, false, true ) ), COLOR_RED ) ;
			}
		}
	}

	if ( CharSwitchTick [ playerid ] ) {

    	return SetName ( playerid, sprintf("[PAUSED (/afklist)]{007FFF}\n[SWITCHING CHARACTERS]{DEDEDE}\n(%d) %s", playerid, ReturnUserName ( playerid, false, true )), COLOR_RED ) ;
	}

	if(!HasPlayerUsedAFKCommand[playerid]) { SetName ( playerid, sprintf("[PAUSED (/afklist)]{DEDEDE}\n(%d) %s", playerid, ReturnUserName ( playerid, false, true )  ), COLOR_RED ) ; }
	//else { SetName ( playerid, sprintf("[PAUSED (/afklist)]{DEDEDE}\n(%d) %s", playerid, ReturnUserName ( playerid, false, true )  ), COLOR_RED ) ; }

	return true ;
}


public OnPlayerResume ( playerid ) {

/*
	if ( ! IsIgnoringPlayerPause [ playerid ] ) {
		SendModeratorWarning ( sprintf ("[PAUSE] (%d) %s has unpaused.", playerid, ReturnUserName ( playerid, true ) ), MOD_WARNING_LOW ) ;

		IsIgnoringPlayerPause = true ;
		defer IgnoreConstantPauseTick(playerid) ;
	}*/

	if ( Character [ playerid ] [ character_dmgmode ] ) {

		return SetName ( playerid,  sprintf("(%d) %s", playerid, ReturnUserName ( playerid, false, true ) ), COLOR_RED ) ;
	}

	if ( IsPlayerOOC [ playerid ] ) {

		return SetName ( playerid,  sprintf("(( Out of Character ))\n{[ (%d) %s ]}", playerid, ReturnUserName ( playerid, false, true ) ), COLOR_OOC ) ;
	}

	if ( IsPlayerOnAdminDuty [ playerid ] ) {

		if ( Account [ playerid ] [ account_id ] == 1 || Account [ playerid ] [ account_id ] == 2 ) {

    		return SetName ( playerid, sprintf("(( OOC: Developer on Duty ))\n{[ (%d) %s ]}", playerid, ReturnUserName ( playerid, false ) ), 0x855A83FF ) ;
		}

		else {

			switch ( Account [ playerid ] [ account_stafflevel ] ) {

				case STAFF_MANAGER: {
					
	        		return SetName ( playerid, sprintf("(( OOC: Manager on Duty ))\n{[ (%d) %s ]}", playerid, ReturnUserName ( playerid, false ) ), MANAGER_COLOR ) ;
				}

				default: return SetName ( playerid, sprintf("(( OOC: Moderator on Duty ))\n{[ (%d) %s ]}", playerid, ReturnUserName ( playerid, false ) ), 0x408040FF ) ;
			}
		}
	}

	if ( CharSwitchTick [ playerid ] ) {

    	return SetName ( playerid, sprintf("[SWITCHING CHARACTERS]{DEDEDE}\n(%d) %s", playerid, ReturnUserName ( playerid, false, true )), COLOR_BLUE ) ;
	}

	if(!HasPlayerUsedAFKCommand[playerid]) { SetName ( playerid, sprintf("{DEDEDE}\n(%d) %s", playerid, ReturnUserName ( playerid, false, true )  ), COLOR_RED ) ; }

	return true ;

}

CMD:afklist ( playerid, params [] ) {

	SendClientMessage(playerid, COLOR_BLUE, "List of all AFK players") ;

	foreach(new i: Player) {

		if ( IsPlayerPaused ( i ) && i != INVALID_PLAYER_ID ) {

			if ( ! IsPlayerSleepingInPoint [ playerid ] ) { 

				SendClientMessage(playerid, COLOR_DEFAULT, sprintf("(%d) %s: paused for %d seconds.", i, ReturnUserName ( i, true ), GetPlayerPausedTime(i) / 1000 ) ) ;
			}

			else if ( IsPlayerSleepingInPoint [ playerid ] ) {

				SendClientMessage(playerid, COLOR_DEFAULT, sprintf("(%d) %s: paused for %d seconds. [Sleeping]", i, ReturnUserName ( i, true ), GetPlayerPausedTime(i) / 1000 ) ) ;
			}
		}

		else continue;
	}

	return true ;
}

CMD:afk(playerid,params[]) {

	if(CharSwitchTick [ playerid ]) { return SendServerMessage(playerid,"You cannot use this while switching characters.",MSG_TYPE_ERROR); }
	if(!HasPlayerUsedAFKCommand[playerid]) {

		HasPlayerUsedAFKCommand[playerid] = true;
		TogglePlayerControllable(playerid,false);
		SendServerMessage(playerid,"You are now afk, you won't be kicked for 30 minutes.",MSG_TYPE_INFO);
		SetName ( playerid, sprintf("[AFK]{DEDEDE}\n(%d) %s", playerid, ReturnUserName ( playerid, false, true )  ), COLOR_RED ) ;
	}
	else {

		HasPlayerUsedAFKCommand[playerid] = false;
		TogglePlayerControllable(playerid,true);
		SendServerMessage(playerid,"You are no longer AFK.",MSG_TYPE_INFO);
		SetName ( playerid, sprintf("{DEDEDE}\n(%d) %s", playerid, ReturnUserName ( playerid, false, true )  ), COLOR_RED ) ;
	}
	return true;
}

task AFKCheck[60000]() {

	foreach(new playerid : Player) {

		if(IsPlayerModerator(playerid) || IsPlayerManager(playerid)) { return true; }
		if ( ! IsPlayerSleepingInPoint [ playerid ] ) {

			AFKVariable [ playerid ] ++ ;

			if(!HasPlayerUsedAFKCommand[playerid]) {

				if ( AFKVariable [ playerid ] == 9 ) {

					SendServerMessage ( playerid, "You will be kicked for inactivity in one minute.  Move around to avoid this.", MSG_TYPE_WARN ) ;
				}

				else if ( AFKVariable [ playerid ] >= 10 ) {

					SendServerMessage ( playerid, "You've been kicked for being AFK.", MSG_TYPE_WARN ) ;
					KickPlayer ( playerid ) ;
				}
			}
			else {

				TogglePlayerControllable(playerid,false);

				if ( AFKVariable [ playerid ] == 29 ) {

					SendServerMessage ( playerid, "You will be kicked for inactivity in one minute.  Use /afk to avoid this.", MSG_TYPE_WARN ) ;
				}

				else if ( AFKVariable [ playerid ] >= 30 ) {

					SendServerMessage ( playerid, "You've been kicked for being AFK.", MSG_TYPE_WARN ) ;
					KickPlayer ( playerid ) ;
				}
			}
		}
	}

	return true ;
}

public OnPlayerUpdate(playerid)
{
	if ( AFKVariable [ playerid ] ) {

		AFKVariable [ playerid ] = 0 ;
	}
	#if defined pause_OnPlayerUpdate
		return pause_OnPlayerUpdate(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerUpdate
	#undef OnPlayerUpdate
#else
	#define _ALS_OnPlayerUpdate
#endif

#define OnPlayerUpdate pause_OnPlayerUpdate
#if defined pause_OnPlayerUpdate
	forward pause_OnPlayerUpdate(playerid);
#endif
