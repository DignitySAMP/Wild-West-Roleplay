//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

public OnPlayerText( playerid, text []) {

	if ( Character [ playerid ] [ character_dmgmode ] ) {

		SendServerMessage ( playerid, "You can't talk whilst in injury mode", MSG_TYPE_ERROR ) ;
		return false ;
	}

	else {

		if ( IsPlayerSleepingInPoint [ playerid ] ) {

			SendServerMessage ( playerid, "You can't talk while using /point sleep.", MSG_TYPE_ERROR ) ;
			return false ;
		}

		new string[256];
		
		if ( strlen ( Character [ playerid ] [ character_accent ] ) < 3 ) {

			format(string,sizeof(string),"%s says: %s",ReturnUserName(playerid,false),text);
			ProxDetector(playerid,15.0,COLOR_DEFAULT,string); //25
			SetPlayerChatBubble(playerid,string,COLOR_DEFAULT,15.0,10000);
		}

		else if ( strlen ( Character [ playerid ] [ character_accent ] ) > 3 ) {

			format(string,sizeof(string),"%s says [%s accent]: %s", ReturnUserName ( playerid, false ), Character [ playerid ] [ character_accent ], text );
			ProxDetector ( playerid, 15.0, COLOR_DEFAULT, string) ;
			SetPlayerChatBubble(playerid,string,COLOR_DEFAULT,15.0,10000);
		}

	 	//SetPlayerChatBubble(playerid, sprintf ( "%s says: %s", ReturnUserName ( playerid, false ), text ), COLOR_DEFAULT, 30.0, 10000);
 		//WriteLog ( playerid, "chat/local", sprintf("%s says: %s", ReturnUserName ( playerid, true ), text) ) ;

	 	if ( ! IsPlayerRidingHorse [ playerid ] && ! gPlayerUsingLoopingAnim[playerid] && ! IsPlayerTrapped[ playerid ] && !IsPlayerPlayingPoker(playerid)) {

			switch ( Character [ playerid ] [ character_chatstyle ] ) {
				case 0: return false ;
				case 1: ApplyAnimation(playerid, "PED", "IDLE_CHAT", 4.1, 0, 0, 0, 1, 1);
				case 2: ApplyAnimation(playerid, "GANGS", "prtial_gngtlkA", 4.1, 0, 0, 0, 1, 1);
				case 3: ApplyAnimation(playerid, "GANGS", "prtial_gngtlkB", 4.1, 0, 0, 0, 1, 1);
				case 4: ApplyAnimation(playerid, "GANGS", "prtial_gngtlkE", 4.1, 0, 0, 0, 1, 1);
				case 5: ApplyAnimation(playerid, "GANGS", "prtial_gngtlkF", 4.1, 0, 0, 0, 1, 1);
				case 6: ApplyAnimation(playerid, "GANGS", "prtial_gngtlkG", 4.1, 0, 0, 0, 1, 1);
				case 7: ApplyAnimation(playerid, "GANGS", "prtial_gngtlkH", 4.1, 0, 0, 0, 1, 1);
			}

			defer ClearChatAnim(playerid);
		}
	}

	#if defined chat_OnPlayerText
		return chat_OnPlayerText(playerid, text);
	#else
		return false;
	#endif
}
#if defined _ALS_OnPlayerText
	#undef OnPlayerText
#else
	#define _ALS_OnPlayerText
#endif

#define OnPlayerText chat_OnPlayerText
#if defined chat_OnPlayerText
	forward chat_OnPlayerText(playerid, text[]);
#endif

timer ClearChatAnim[1000](playerid) {

////	print("ClearChatAnim timer called (roleplay_chat.pwn)");

	return ClearAnimations(playerid, 0);
}

CMD:setchat(playerid, params[]) {

    new type;

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/setchat [0-6]", MSG_TYPE_ERROR );

	if (type < 0 || type > 7)
	    return SendServerMessage(playerid, "Type can't be less than 0 or higher than 6.", MSG_TYPE_ERROR );

	Character [ playerid ] [ character_chatstyle ] = type ;

	new query [ 128 ] ; 

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_chatstyle = %d WHERE character_id = %d", Character [ playerid ] [ character_chatstyle ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	
	if ( type == 0 ) {

		return SendServerMessage ( playerid, "You have removed your chat animation.", MSG_TYPE_ERROR ) ;
	}

	SendServerMessage ( playerid, sprintf("You changed your chat animation style to %d. Next time talk you will play the animation.", type ), MSG_TYPE_INFO ) ;

	return 1;
}

CMD:accent ( playerid, params [] ) {

	new accent ;

	if ( sscanf ( params, "i", accent ) ) {

		return SendServerMessage ( playerid, "/accent [accent] (/accentlist)", MSG_TYPE_ERROR ) ;
	}

	new accentlist [ ] [ ] = {
		{ "Baysidian"} , { "Fremont"} , { "Longcreek"} , 
		{ "Whetstone"} , { "Minnesota"} , { "Nebraska"} , 
		{ "Californian"}, { "Wisconsin"} , { "Kansas"} , 
		
		{ "Texas"} ,  { "Oklahoma" }, { "New Mexico"} , 
		{ "Arizona"} , { "Lousiana"} , { "Mississipi"} , 
		{ "Missouri"} , { "Arkansas"} , { "Louisiana" }, 
		{ "Illinois"} , { "Wyoming"} , { "Nevada"} , 
		{ "California" }, { "Irish"} , { "Scottish"} , 
		{ "British"} , { "Native" }, { "Spanish"} , 
		{ "French"} , { "Dutch"} , {"Foreign" }
	}, query [ 128 ] ;

	if ( accent < 0 || accent > sizeof ( accentlist ) ) {

		return SendServerMessage ( playerid, "Invalid accent. Use /accentlist to get the ID.", MSG_TYPE_ERROR ) ;
	}

	if ( accent == sizeof ( accentlist ) ) {
		Character [ playerid ] [ character_accent ] = EOS ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_accent = '%s' WHERE character_id = %d", 
			" ", Character [ playerid ] [ character_id ] ) ;

		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( playerid, "You have removed your accent.", MSG_TYPE_INFO ) ;
		return true ;
	}

	new pick [ 32 ] ;
	format ( pick, sizeof ( pick ), "%s",  accentlist [ accent ] ) ;

	pick [ 0 ] = toupper(pick[0]) ;
	Character [ playerid ] [ character_accent ] = pick ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_accent = '%s' WHERE character_id = %d", 
		pick, Character [ playerid ] [ character_id ] ) ;

	mysql_tquery ( mysql, query ) ;	

	return SendServerMessage ( playerid, sprintf("Your accent has been set to %s.", pick), MSG_TYPE_INFO ) ;	
}

CMD:accentlist ( playerid, params [] ) {

	SendClientMessage ( playerid, COLOR_TAB0, "|______________________| List of available accents |______________________|  " ) ;
	SendClientMessage ( playerid, COLOR_TAB1, "0) Baysidian, 1) Fremont, 2) Longcreek, 3) Whetstone, 4) Minnesota, 5) Nebraska, 6) California" ) ;
	SendClientMessage ( playerid, COLOR_TAB2, "7) Wisconsin, 8) Kansas, 9) Texas, 10) Oklahoma, 11) New Mexico, 12) Arizona, 13) Lousiana" ) ;
	SendClientMessage ( playerid, COLOR_TAB1, "14) Mississipi, 15) Missouri, 16) Arkansas, 17) Louisiana, 18) Illinois, 19) Wyoming, 20) Nevada, 21) California" ) ;
	SendClientMessage ( playerid, COLOR_TAB2, "22) Irish, 23) Scottish, 24) British, 25) Native, 26) Spanish, 27) French, 28) Dutch, 29) Foreign, 30) None" ) ;


	return true ;
}

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

CMD:o ( playerid, params [] ) {
	new text [ 256 ], string[128] ;

	if ( ! ToggleOOCChat ) {

		return SendServerMessage ( playerid, "OOC Chat is disabled!", MSG_TYPE_ERROR ) ;
	}

	if ( sscanf ( params, "s[128]", string ) ) {

		return SendServerMessage ( playerid, "/o(oc) [text]", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( Account [ playerid ] [ account_staffname ] ) == 0 ) {

		if ( IsPlayerOnAdminDuty [ playerid ] ) {

			if ( Account [ playerid ] [ account_id ] == 1 || Account [ playerid ] [ account_id ] == 2 ) {

				format(text,sizeof(text),"(( [OOC] {855A83}(%d) %s{AAC4E5}: %s ))", playerid, ReturnUserName ( playerid, false, false ), string);
				SendOOCMessage ( COLOR_OOC, text) ;
			}

			else {

				switch ( Account [ playerid ] [ account_stafflevel ] ) {

					case STAFF_MANAGER: {

						format(text,sizeof(text),"(( [OOC] {AD2D2D}(%d) %s{AAC4E5}: %s ))", playerid, ReturnUserName ( playerid, false, false ), string) ;
					}

					default: format(text,sizeof(text),"(( [OOC] {449C44}(%d) %s{AAC4E5}: %s ))", playerid, ReturnUserName ( playerid, false, false ), string) ;
				}
			}
			SendOOCMessage ( COLOR_OOC, text);
		}

		else {

			format(text,sizeof(text),"(( [OOC] (%d) %s: %s ))", playerid, ReturnUserName ( playerid, false ), string) ;
			SendOOCMessage ( COLOR_OOC, text);
		}
	}

	else {

		if ( IsPlayerOnAdminDuty [ playerid ] ) {

			if ( Account [ playerid ] [ account_id ] == 1 || Account [ playerid ] [ account_id ] == 2 ) {

				format(text,sizeof(text),"(( [OOC] {855A83}(%d) %s (%s){AAC4E5}: %s ))", playerid, ReturnUserName ( playerid, false, false ), Account [ playerid ] [ account_staffname ], string) ;
				SendOOCMessage(COLOR_OOC,text);
			}

			else {

				switch ( Account [ playerid ] [ account_stafflevel ] ) {

					case STAFF_MANAGER: {

						format(text,sizeof(text),"(( [OOC] {AD2D2D}(%d) %s (%s){AAC4E5}: %s ))", playerid, ReturnUserName ( playerid, false, false ), Account [ playerid ] [ account_staffname ],string ) ;
					}

					default: format(text,sizeof(text),"(( [OOC] {449C44}(%d) %s (%s){AAC4E5}: %s ))", playerid, ReturnUserName ( playerid, false, false ), Account [ playerid ] [ account_staffname ],string ) ;
				}
				SendOOCMessage(COLOR_OOC,text);
			}
		}

		else {

			format(text,sizeof(text),"(( [OOC] (%d) %s (%s): %s ))", playerid, ReturnUserName ( playerid, false, false ), Account [ playerid ] [ account_staffname ], string) ;
			SendOOCMessage(COLOR_OOC,text);
		}
	}

 	WriteLog ( playerid, "chat/ooc", sprintf ( "[GLOBAL OOC] (( (%d) %s: %s ))", playerid, ReturnUserName ( playerid, false, false ), text) ) ;

	return true ;
}

CMD:ooc ( playerid, params[] ) 
	return cmd_o ( playerid, params);

CMD:noooc ( playerid, params [] ) {

	if ( ! IsPlayerHidingOOC [ playerid ] ) {

		IsPlayerHidingOOC [ playerid ] = true ;

		SendServerMessage ( playerid, "You're disabled the OOC chat.", MSG_TYPE_INFO ) ;
	}

	else if ( IsPlayerHidingOOC [ playerid ] ) {

		IsPlayerHidingOOC [ playerid ] = false ;
		SendServerMessage ( playerid, "You're enabled the OOC chat.", MSG_TYPE_INFO ) ;
	}

	return true ;
}

CMD:b ( playerid, params [] ) {

	new text [ 144 ], string[256] ;

	if ( sscanf ( params, "s[144]", text ) ) {

		return SendServerMessage ( playerid, "/b [text]", MSG_TYPE_ERROR ) ;
	}

	if ( IsPlayerOnAdminDuty [ playerid ] ) {

		if ( IsPlayerOnAdminDuty [ playerid ] ) {

			if ( Account [ playerid ] [ account_id ] == 1 || Account [ playerid ] [ account_id ] == 2 ) {

				format ( string, sizeof ( string ), "(( {855A83}(%d) %s{999999}: %s ))", playerid, ReturnUserName ( playerid, true, false ), text ) ; 
				ProxDetector ( playerid, 15, COLOR_GREY, string ) ; //20
			}

			else {

				switch ( Account [ playerid ] [ account_stafflevel ] ) {

					case STAFF_MANAGER: {
						format ( string, sizeof ( string ), "(( {AD2D2D}(%d) %s{999999}: %s ))", playerid, ReturnUserName ( playerid, true, false ), text ) ;
						ProxDetector ( playerid, 15, COLOR_GREY,string ) ;
					}

					default: {
						format ( string, sizeof ( string ), "(( {449C44}(%d) %s{999999}: %s ))", playerid, ReturnUserName ( playerid, true, false ), text )  ;
						ProxDetector ( playerid, 15, COLOR_GREY, string ) ;
					}
				}
			}
		}
	}

	else {
		format ( string, sizeof ( string ), "(( (%d) %s: %s ))", playerid, ReturnUserName ( playerid, true, false ), text ) ;
		ProxDetector ( playerid, 20, COLOR_GREY, string ) ;
	}

	WriteLog ( playerid, "chat/ooc", string ) ;

	return true;
}

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

CMD:melow ( playerid, params [] ) {

	new string[256],text[128];

	if(sscanf(params,"s[128]",text)) { return SendServerMessage(playerid,"/melow [text]",MSG_TYPE_ERROR); }

	format(string,sizeof(string),"* %s %s",ReturnUserName(playerid,false),text);
	ProxDetector(playerid,4.5,COLOR_ACTION,string); //10

	format(string,sizeof(string),"[MELOW] %s %s",ReturnUserName(playerid,true,false),text);
	WriteLog(playerid,"chat/action",string);

	return true;
}

CMD:me ( playerid, params [] ) {

	new string[256],text[128];

	if(sscanf(params,"s[128]",text)) { return SendServerMessage(playerid,"/me(low) [text]",MSG_TYPE_ERROR); }

	format(string,sizeof(string),"* %s %s",ReturnUserName(playerid,false),text);
	ProxDetector(playerid,15.0,COLOR_ACTION,string); //30

	format(string,sizeof(string),"[ME] %s %s",ReturnUserName(playerid,true,false),text);
	WriteLog(playerid,"chat/action",string);

	return true;
}

CMD:e(playerid, params[]){
	return cmd_me(playerid, params);
}

CMD:mylow ( playerid, params [] ) {

	new string[256],text[128];

	if(sscanf(params,"s[128]",text)) { return SendServerMessage(playerid,"/mylow [text]",MSG_TYPE_ERROR); }

	format(string,sizeof(string),"* %s's %s",ReturnUserName(playerid,false),text);
	ProxDetector(playerid,4.5,COLOR_ACTION,string);

	format(string,sizeof(string),"[MYLOW] %s's %s",ReturnUserName(playerid,true,false),text);
	WriteLog(playerid,"chat/action",string);

	return true ;
}

CMD:my ( playerid, params [] ) {

	new string[256],text[128];

	if(sscanf(params,"s[128]",text)) { return SendServerMessage(playerid,"/my(low) [text]",MSG_TYPE_ERROR); }

	format(string,sizeof(string),"* %s's %s",ReturnUserName(playerid,false),text);
	ProxDetector(playerid,15.0,COLOR_ACTION,string);

	format(string,sizeof(string),"[MY] %s's %s",ReturnUserName(playerid,true,false),text);
	WriteLog(playerid,"chat/action",string);

	return true ;
}

CMD:ame ( playerid, params [] ) {

	new text [ 144 ] ;

	if ( sscanf ( params, "s[144]", text ) ) {

		return SendServerMessage ( playerid, "/ame [text]", MSG_TYPE_ERROR ) ;
	}

 	SendClientMessage(playerid, COLOR_ACTION, sprintf("> %s %s",ReturnUserName ( playerid, false, true ), text) ) ;
 	SetPlayerChatBubble(playerid, sprintf("* %s %s",ReturnUserName ( playerid, false, true ), text) , COLOR_ACTION, 30.0, 10000);

	WriteLog ( playerid, "chat/action", sprintf("[AME] %s %s", ReturnUserName ( playerid, true ), text) ) ;

	return true;
}

CMD:ado ( playerid, params [] ) {

	new text [ 144 ] ;

	if ( sscanf ( params, "s[144]", text ) ) {
		return SendServerMessage ( playerid, "/ado [text]", MSG_TYPE_ERROR ) ;
	}

 	SetPlayerChatBubble(playerid, sprintf("%s (( %s ))", text, ReturnUserName ( playerid, false, true )), COLOR_ACTION, 30.0, 10000);
 	SendClientMessage(playerid, COLOR_ACTION, sprintf("> %s (( %s ))", text, ReturnUserName ( playerid, false, true )) ) ;

	WriteLog ( playerid, "chat/action", sprintf("[ADO] %s %s", ReturnUserName ( playerid, true ), text) ) ;
	
	return true;
}

CMD:dolow ( playerid, params [] ) {

	new string[144],text[128];

	if(sscanf(params,"s[128]",text)) { return SendServerMessage(playerid,"/dolow [text]",MSG_TYPE_ERROR); }

	format(string,sizeof(string),"* %s (( %s ))",text,ReturnUserName(playerid,false));
	ProxDetector(playerid,4.5,COLOR_ACTION,string);

	format(string,sizeof(string),"[DOLOW] %s (( %s ))",text,ReturnUserName(playerid,true,false));
	WriteLog(playerid,"chat/action",string);
	
	return true;
}

CMD:do ( playerid, params [] ) {

	new string[144],text[128];

	if(sscanf(params,"s[128]",text)) { return SendServerMessage(playerid,"/do(low) [text]",MSG_TYPE_ERROR); }

	format(string,sizeof(string),"* %s (( %s ))",text,ReturnUserName(playerid,false));
	ProxDetector(playerid,15.0,COLOR_ACTION,string);

	format(string,sizeof(string),"[DO] %s (( %s ))",text,ReturnUserName(playerid,true,false));
	WriteLog(playerid,"chat/action",string);
	
	return true;
}

CMD:low ( playerid, params [] ) {

	new string[256],text[128];

	if(sscanf(params,"s[128]",text)) { return SendServerMessage ( playerid, "/low [text]", MSG_TYPE_ERROR ) ; }
		
	if ( strlen ( Character [ playerid ] [ character_accent ] ) < 3 ) {

		format(string,sizeof(string),"%s says [low]: %s",ReturnUserName(playerid,false,true),text);
		ProxDetector(playerid,4.5,COLOR_DEFAULT,string);
	}

	else if ( strlen ( Character [ playerid ] [ character_accent ] ) > 3 ) {

		format(string,sizeof(string),"%s says [low] [%s accent]: %s",ReturnUserName(playerid,false,true),Character[playerid][character_accent],text);
		ProxDetector(playerid,4.5,COLOR_DEFAULT,string);
	}

	format(string,sizeof(string),"%s says [low]: %s", ReturnUserName ( playerid, true, false ), text);
	WriteLog ( playerid, "chat/local", string ) ;

	return true;
}

CMD:shout ( playerid, params [] ) {

	if ( Character [ playerid ] [ character_dmgmode ] ) {

		SendServerMessage ( playerid, "You can't talk whilst in injury mode", MSG_TYPE_ERROR ) ;
		return false ;
	}

	new string[256],text [ 128 ] ;

	if ( sscanf ( params, "s[128]", text ) ) {

		return SendServerMessage ( playerid, "/s(hout) [text]", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( Character [ playerid ] [ character_accent ] ) < 3) {

		format(string,sizeof(string),"%s shouts: %s",ReturnUserName(playerid,false,true),text);
		ProxDetector ( playerid, 30, -1, string ) ;
	}

	else if ( strlen ( Character [ playerid ] [ character_accent ] ) > 3 ) {

		format(string,sizeof(string),"%s shouts [%s accent]: %s", ReturnUserName ( playerid, false, true ), Character [ playerid ] [ character_accent ], text);
		ProxDetector ( playerid, 30, -1, string ) ;

	}

	format(string,sizeof(string),"%s shouts: %s", ReturnUserName ( playerid, true, false ), text);

	WriteLog ( playerid, "chat/local", string) ;

	return true;
}

CMD:s ( playerid, params [ ] )
	return cmd_shout ( playerid, params );


new IsPlayerBlockingPM [ MAX_PLAYERS ] ;

CMD:blockpm ( playerid, params [] ) {

	if ( ! IsPlayerBlockingPM [ playerid ] ) {

		IsPlayerBlockingPM [ playerid ]  = true ;

		return SendServerMessage ( playerid, "You are now blocking your private messages!", MSG_TYPE_WARN ) ;
	}

	else if ( IsPlayerBlockingPM [ playerid ] ) {

		IsPlayerBlockingPM [ playerid ]  = false ;

		return SendServerMessage ( playerid, "You have unblocked your private messages!", MSG_TYPE_WARN ) ;
	}

	return true ;
}

CMD:pm(playerid, params[]) {

	new userid, text[144], string[256];

	if (sscanf(params, "k<u>s[144]", userid, text))
		return SendServerMessage ( playerid, "/pm [id] [text]", MSG_TYPE_ERROR ) ;

	if (!IsPlayerConnected(userid))
		return SendServerMessage ( playerid, "Player isn't connected.", MSG_TYPE_ERROR ) ;

	if (userid == playerid)
		return SendServerMessage ( playerid, "You can't PM yourself.", MSG_TYPE_ERROR ) ;

	if ( IsPlayerPaused ( userid ) ) {
		SendServerMessage ( playerid, "The player you are messaging is AFK. Use /afklist.", MSG_TYPE_WARN ) ;
	}

	if ( IsPlayerBlockingPM [ userid ] && ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "The person you are trying to message is blocking their private messages.", MSG_TYPE_ERROR ) ;
	}


	if ( Account [ userid ] [ account_stafflevel ] >= STAFF_MODERATOR && ! PlayerModPMWarning [ playerid ] ) {

	 	inline PMingAdminResponse(pid, dialogid, response, listitem, string:inputtext[]) {

	        #pragma unused pid, dialogid, listitem, inputtext

	 		if ( response ) {

				GameTextForPlayer(userid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~New message!", 3000, 3);
				PlayerPlaySound(userid, 1085, 0.0, 0.0, 0.0);

				if ( IsPlayerOnAdminDuty [ playerid ] ) {

					if ( IsPlayerOnAdminDuty [ playerid ] ) {

						if ( Account [ playerid ] [ account_id ] == 1 || Account [ playerid ] [ account_id ] == 2 ) {

							format(string,sizeof(string),"(( PM from {855A83}%s (%d){FFCC22}: %s ))", ReturnUserName(playerid, false), playerid, text);
							SendSplitMessage(userid, 0xFFCC2299,string);
						}

						else {

							switch ( Account [ playerid ] [ account_stafflevel ] ) {

								case STAFF_MANAGER: {

									format(string,sizeof(string),"(( PM from {AD2D2D}%s (%d){FFCC22}: %s ))", ReturnUserName(playerid, false), playerid, text);
									SendSplitMessage(userid, 0xFFCC2299, string);
								}

								default: {

									format(string,sizeof(string),"(( PM from {449C44}%s (%d){FFCC22}: %s ))", ReturnUserName(playerid, false), playerid, text);
									SendSplitMessage(userid, 0xFFCC2299, string);
								}
							}
						}
					}
				}

				else {

					format(string,sizeof(string),"(( PM from %s (%d): %s ))", ReturnUserName(playerid, false), playerid, text);
					SendSplitMessage(userid, 0xFFCC2299, string);
				}

				
				if ( IsPlayerOnAdminDuty [ userid ] ) {

					if ( Account [ userid ] [ account_id ] == 1 || Account [ userid ] [ account_id ] == 2 ) {

						format(string,sizeof(string),"(( PM to {855A83}%s (%d){FFFF22}: %s ))", ReturnUserName(userid, false), userid, text);
						SendSplitMessage(playerid, 0xFFFF22AA,string); 
					}

					else {

						switch ( Account [ userid ] [ account_stafflevel ] ) {

							case STAFF_MANAGER: {

								format(string,sizeof(string),"(( PM to {AD2D2D}%s (%d){FFFF22}: %s ))", ReturnUserName(userid, false), userid, text);
								SendSplitMessage(playerid, 0xFFFF22AA, string); 
							}

							default: {

								format(string,sizeof(string),"(( PM to {449C44}%s (%d){FFFF22}: %s ))", ReturnUserName(userid, false), userid, text);
								SendSplitMessage(playerid, 0xFFFF22AA, string);
							}
						}
					}
				}

				else {

					format(string,sizeof(string),"(( PM to %s (%d): %s ))", ReturnUserName(userid, false), userid, text);
					SendSplitMessage(playerid, 0xFFFF22AA, string); 
				}

			 	//OldLog ( playerid, "pms", sprintf ( "%s sends to %s: %s", ReturnUserName ( playerid, false ), ReturnUserName ( userid, false ), text) ) ;
			 	WriteLog ( playerid, "chat", sprintf ( "[PM] %s sends to %s: %s", ReturnUserName ( playerid, false ), ReturnUserName ( userid, false ), text) ) ;

	 		}

	 		else if ( ! response ) {

	 			return false ;
	 		}
    	}

  
		new msg [ 280 ] = "{D63C3C}WARNING:{DEDEDE} You're sending a private message to a moderator.\n\n\
			Please make sure your query isn't related to their tasks, since there is /report for that.\n\n\
			If this moderator is helping you or you have something else to talk about, go ahead.\n\n\
			Thanks for understanding." ;

		Dialog_ShowCallback(playerid, using inline PMingAdminResponse, DIALOG_STYLE_MSGBOX, "{D63C3C}PRIVATE MESSAGE WARNING:{DEDEDE}", msg, "Proceed", "Cancel");

		PlayerModPMWarning [ playerid ] = true ;

    	return true ;
	}

	else {

		GameTextForPlayer(userid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~New message!", 3000, 3);
		PlayerPlaySound(userid, 1085, 0.0, 0.0, 0.0);

		if ( IsPlayerOnAdminDuty [ playerid ] ) {

			if ( IsPlayerOnAdminDuty [ playerid ] ) {

				if ( Account [ playerid ] [ account_id ] == 1 || Account [ playerid ] [ account_id ] == 2 ) {

					SendSplitMessage(userid, 0xFFCC2299, sprintf("(( PM from {855A83}%s (%d){FFCC22}: %s ))", ReturnUserName(playerid, false), playerid, text));
				}

				else {

					switch ( Account [ playerid ] [ account_stafflevel ] ) {

						case STAFF_MANAGER: {

							SendSplitMessage(userid, 0xFFCC2299, sprintf("(( PM from {AD2D2D}%s (%d){FFCC22}: %s ))", ReturnUserName(playerid, false), playerid, text));
						}

						default: SendSplitMessage(userid, 0xFFCC2299, sprintf("(( PM from {449C44}%s (%d){FFCC22}: %s ))", ReturnUserName(playerid, false), playerid, text));
					}
				}
			}
		}

		else SendSplitMessage(userid, 0xFFCC2299, sprintf("(( PM from %s (%d): %s ))", ReturnUserName(playerid, false), playerid, text));

		
		if ( IsPlayerOnAdminDuty [ userid ] ) {

			if ( Account [ userid ] [ account_id ] == 1 || Account [ userid ] [ account_id ] == 2 ) {

				SendSplitMessage(playerid, 0xFFFF22AA, sprintf("(( PM to {855A83}%s (%d){FFFF22}: %s ))", ReturnUserName(userid, false), userid, text)); 
			}

			else {

				switch ( Account [ userid ] [ account_stafflevel ] ) {

					case STAFF_MANAGER: {

						SendSplitMessage(playerid, 0xFFFF22AA, sprintf("(( PM to {AD2D2D}%s (%d){FFFF22}: %s ))", ReturnUserName(userid, false), userid, text)); 
					}

					default: SendSplitMessage(playerid, 0xFFFF22AA, sprintf("(( PM to {449C44}%s (%d){FFFF22}: %s ))", ReturnUserName(userid, false), userid, text)); 
				}
			}
		}

		else SendSplitMessage(playerid, 0xFFFF22AA, sprintf("(( PM to %s (%d): %s ))", ReturnUserName(userid, false), userid, text)); 
				

	 	WriteLog ( playerid, "chat/pm", sprintf ( "[PM] %s sends to %s: %s", ReturnUserName ( playerid, false ), ReturnUserName ( userid, false ), text) ) ;
	}

	return 1;
}

CMD:whisper(playerid, params[]) {

	new userid, text[144];

	if (sscanf(params, "k<u>s[128]", userid, text))
		return SendServerMessage ( playerid, "/whisper [id] [text]", MSG_TYPE_ERROR ) ;

	if (!IsPlayerConnected(userid))
		return SendServerMessage ( playerid, "Player isn't connected.", MSG_TYPE_ERROR ) ;

	new Float: x, Float: y, Float: z ;
	GetPlayerPos ( userid, x, y, z ) ;

	if ( ! IsPlayerInRangeOfPoint ( playerid, 2.5, x, y, z ) ) {

		return SendServerMessage ( playerid, "You're not near the player you're trying to whisper!", MSG_TYPE_ERROR ) ;
	}

	GameTextForPlayer(userid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~New message!", 3000, 3);
	PlayerPlaySound(userid, 1085, 0.0, 0.0, 0.0);
 
	SendSplitMessage(playerid, 0xbf8a6399, sprintf("Whisper to %s: %s", ReturnUserName(userid, false, true), text)); 
	SendSplitMessage(userid, 0x805637AA, sprintf("%s whispers: %s", ReturnUserName(playerid, false, true), text));
	
	ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s mutters something to %s.",ReturnUserName ( playerid, false, true ), ReturnUserName(userid, false, true)) ) ;
 
 	//OldLog ( playerid, "whisper", sprintf ( "%s sends to %s: %s", ReturnUserName ( playerid, false ), ReturnUserName ( userid, false ), text) ) ;
 	WriteLog ( playerid, "chat", sprintf ( "[WHISPER] %s sends to %s: %s", ReturnUserName ( playerid, false, false ), ReturnUserName ( userid, false, false ), text) ) ;

 	WriteLog ( playerid, "chat/whisper", sprintf ( "[WHISPER] %s sends to %s: %s", ReturnUserName ( playerid, false ), ReturnUserName ( userid, false ), text) ) ;


	return 1;
}

CMD:w(playerid, params[]){
	return cmd_whisper ( playerid, params ) ;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
