ShowPlayerMOTD ( playerid ) {

	new string[300];
	SendClientMessage(playerid, -1, " ") ;
	format(string,sizeof(string),"[Player MOTD]:{DEDEDE} %s",PLAYER_MOTD);
	SendSplitMessage(playerid, COLOR_TAB0,string);

	if(IsPlayerModerator(playerid)) {

		format(string,sizeof(string),"[Staff MOTD]:{DEDEDE} %s",STAFF_MOTD);
		SendSplitMessage(playerid,COLOR_TAB1,string);
	}

	/*
	if ( strlen ( PLAYER_MOTD ) > 144 ) {

		SendClientMessage(playerid, COLOR_TAB0, sprintf("[Player MOTD]:{DEDEDE} %.144s...", PLAYER_MOTD )) ;
		SendClientMessage(playerid, COLOR_TAB0, sprintf("{DEDEDE}... %s", PLAYER_MOTD [ 144 ] )) ;
	}

	else SendClientMessage(playerid, COLOR_TAB0, sprintf("[Player MOTD]:{DEDEDE} %s", PLAYER_MOTD )) ;

	if ( IsPlayerModerator ( playerid ) ) {

		if ( strlen ( STAFF_MOTD ) > 144 ) {

			SendClientMessage(playerid, COLOR_TAB1, sprintf("[Staff MOTD]:{DEDEDE} %.144s...", STAFF_MOTD )) ;
			SendClientMessage(playerid, COLOR_TAB1, sprintf("{DEDEDE}... %s", STAFF_MOTD [ 144 ] )) ;
		}

		else SendClientMessage(playerid, COLOR_TAB1, sprintf("[Staff MOTD]:{DEDEDE} %s", STAFF_MOTD )) ;
	}
	*/

	SendClientMessage(playerid, -1, " ") ;

	return true ;
}