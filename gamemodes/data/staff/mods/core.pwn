#include "data/staff/mods/groups/trial.pwn"
#include "data/staff/mods/groups/basic.pwn"
#include "data/staff/mods/groups/general.pwn"
#include "data/staff/mods/groups/advanced.pwn"
#include "data/staff/mods/func/banevading.pwn"

new bool: PlayerHasPendingReport [ MAX_PLAYERS ] ;
new PlayerReportedID[MAX_PLAYERS];
new PlayerReportReason [MAX_PLAYERS][64 ] ;
new PlayerReportCooldown [ MAX_PLAYERS ] ;
new PlayerReportTime [ MAX_PLAYERS ] ;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

new PlayerAdminconvo [ MAX_PLAYERS ] ;

CMD:acinvite ( playerid, params [] ) {

	if ( GetStaffLevel ( playerid ) < STAFF_MODERATOR ) {

		return SendServerMessage ( playerid, "You're not a moderator.", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new target ;

	if ( sscanf ( params, "k<u>", target ) ) {

		return SendServerMessage ( playerid, "/acinvite [target]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( target ) ) {

		return SendServerMessage ( playerid, "The target you selected doesn't seem to be connected. Try again.", MSG_TYPE_ERROR ) ;
	}

	if ( PlayerAdminconvo [ target ] != -1 ) {

		return SendServerMessage ( playerid, "The target seems to already be in a admin conversation. Ask for an admin to remove them.", MSG_TYPE_ERROR ) ;
	}

	PlayerAdminconvo [ playerid ] = playerid ;
	PlayerAdminconvo [ target ] = playerid ;

	foreach(new i: Player) {
		if ( PlayerAdminconvo [ i ] == PlayerAdminconvo [ playerid ] ) {

			SendSplitMessageEx ( i, 0x955DD9FF, sprintf("[AC] (%d) %s has been added to the admin conversation.", target, ReturnUserName ( target, false )) ) ;
		}
	}

	SendServerMessage ( target, sprintf("Moderator (%d) %s has invited you to their admin conversation. Use /ac to speak.", playerid, ReturnUserName ( playerid, true )), MSG_TYPE_ERROR ) ;
	SendServerMessage ( playerid, sprintf("You have invited (%d) %s to your admin convo. Use /ac to speak or /acuninvite to remove them.", target, ReturnUserName ( target, true )), MSG_TYPE_ERROR ) ;

	return true ;
}


CMD:acuninvite ( playerid, params [] ) {

	if ( GetStaffLevel ( playerid ) < STAFF_MODERATOR ) {

		return SendServerMessage ( playerid, "You're not a moderator.", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new target ;

	if ( sscanf ( params, "k<u>", target ) ) {

		return SendServerMessage ( playerid, "/acuninvite [target]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( target ) ) {

		return SendServerMessage ( playerid, "The target you selected doesn't seem to be connected. Try again.", MSG_TYPE_ERROR ) ;
	}

	if ( PlayerAdminconvo [ target ] == -1 ) {

		return SendServerMessage ( playerid, "The target doesn't seem to be in any admin conversation.", MSG_TYPE_ERROR ) ;
	}


	foreach(new i: Player) {
		if ( PlayerAdminconvo [ i ] == PlayerAdminconvo [ target ] ) {

			SendSplitMessageEx ( i, 0x955DD9FF, sprintf("[AC] (%d) %s has been removed from the admin conversation by moderator (%d) %s.", target, ReturnUserName ( target, false ), playerid, ReturnUserName ( playerid, false )) ) ;
		}
	}

	PlayerAdminconvo [ target ] = -1 ;

	SendServerMessage ( target, sprintf("Moderator (%d) %s has removed you from your current admin conversation.", playerid, ReturnUserName ( playerid, true )), MSG_TYPE_ERROR ) ;
	SendServerMessage ( playerid, sprintf("You have removed (%d) %s from their current admin conversation.", target, ReturnUserName ( target, true )), MSG_TYPE_ERROR ) ;

	return true ;
}

CMD:ac(playerid, params [] ) {

	if ( PlayerAdminconvo [ playerid ] == -1 ) {

		return SendServerMessage ( playerid, "You're not in an admin conversation.", MSG_TYPE_ERROR ) ;
	}

	new text [ 144 ] ; 

	if ( sscanf ( params, "s[144]", text ) ) {

		return SendServerMessage ( playerid, "/ac [text]", MSG_TYPE_ERROR ) ;
	}

	foreach(new i: Player) {

		if ( PlayerAdminconvo [ i ] == PlayerAdminconvo [ playerid ] ) {

			SendSplitMessageEx ( i, 0x955DD9FF, sprintf("[AC] (%d) %s: %s", playerid, ReturnUserName ( playerid, false ), text ) ) ;
		}

		else continue ;
	}

	return true ;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:processnamechange ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < BASIC_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a basic moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new targetid, option[7], reason[64], name[MAX_PLAYER_NAME] = EOS ;

	if ( sscanf ( params, "k<u>s[7]S(None specified.)[64]", targetid, option, reason ) ) {

		return SendServerMessage ( playerid, "/processn(ame)c(hange) [playerid] [accept/deny] [reason (if denied)]", MSG_TYPE_ERROR ) ;
	}

	if ( ! PlayerNameChangeRequest [ targetid ]  ) {

		return SendServerMessage ( playerid, "This player hasn't requested a namechange.", MSG_TYPE_ERROR ) ;
	}

	if ( ! strcmp ( option, "accept", true ) ) {

		new query [ 128 ], type = PlayerNameChangeRequest [ targetid ] ;

		SendServerMessage ( playerid, sprintf("You've accepted %s (%d)'s namechange.", ReturnUserName ( targetid, true), targetid ), MSG_TYPE_INFO ) ;

		switch ( type ) {

			case 1: {

				SendClientMessageToAll(COLOR_STAFF, sprintf("[NAMECHANGE] %s (%d) has namechanged to %s.", ReturnUserName ( targetid, true ), targetid, PlayerNameChangeName [ targetid ] ) ) ;

				WriteLog ( playerid, "mods/namechange", sprintf("[NAMECHANGE] %s (%d) has namechanged to %s.", ReturnUserName ( targetid, true ), targetid, PlayerNameChangeName [ targetid ] ) ) ;

				Character [ targetid ] [ character_name ] = PlayerNameChangeName [ targetid ] ;
				SetPlayerName ( targetid, Character [ targetid ] [ character_name ] ) ;
				SetName ( targetid, sprintf("(%d) %s", targetid, ReturnUserName ( targetid, false, true )), 0xCFCFCFFF ) ;
				Account [ targetid ] [ account_namechanges ] --;

				if ( DoesPlayerHaveItem ( targetid, CARD_GUNPERMIT ) != -1 ) {

					DiscardItem ( targetid, DoesPlayerHaveItem ( targetid, CARD_GUNPERMIT ) ) ;
				}

				if ( DoesPlayerHaveItem ( targetid, CARD_PASSPORT ) != -1 ) {

					DiscardItem ( targetid, DoesPlayerHaveItem ( targetid, CARD_PASSPORT ) ) ;
				}

				mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_name = '%e' WHERE character_id = %d", 
					PlayerNameChangeName [ targetid ], Character [ targetid ] [ character_id ] ) ;
				mysql_tquery ( mysql, query ) ;
			}

			case 2: {

				Account [ targetid ] [ account_name ] = PlayerNameChangeName [ targetid ] ;
				Account [ targetid ] [ account_namechanges ] -= 2;

				SendServerMessage ( targetid, sprintf("Your Master Account name has been changed to %s.", Account [ targetid ] [ account_name ] ), MSG_TYPE_INFO ) ;

				WriteLog ( playerid, "mods/namechange", sprintf("%s (%d) has changed %s (%d) master account name to %s.", ReturnUserName ( playerid, false, false ), playerid, ReturnUserName ( targetid, false, false ), targetid, Account [ targetid ] [ account_name ] ) ) ;

				mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_name = '%e' WHERE account_id = %d", 
					PlayerNameChangeName [ targetid ], Account [ targetid ] [ account_id ] ) ;
				mysql_tquery ( mysql, query ) ;
			}
		}

		PlayerNameChangeRequest [ targetid ] = 0;
		PlayerNameChangeName [ targetid ] = name;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_namechanges = %d WHERE account_id = %d", 
			Account [ targetid ] [ account_namechanges ], Account [ targetid ] [ account_id ] ) ;
		mysql_tquery ( mysql, query ) ;
	}

	else if ( ! strcmp ( option, "deny" ) ) {

		if ( ! strlen ( reason ) ) {

			SendServerMessage ( targetid, sprintf("%s has denied your namechange request.  Reason: None specified.", ReturnUserName ( playerid, false ) ), MSG_TYPE_INFO ) ;
			SendServerMessage ( playerid, sprintf("You've denied %s's namechange request.  Reason: None specified.", ReturnUserName ( targetid, false ) ), MSG_TYPE_INFO ) ;
		}
		else {

			SendServerMessage ( targetid, sprintf("%s has denied your namechange request.  Reason: %s", ReturnUserName ( playerid, false ), reason ), MSG_TYPE_INFO ) ;
			SendServerMessage ( playerid, sprintf("You've denied %s's namechange request.  Reason: %s", ReturnUserName ( targetid, false ), reason ), MSG_TYPE_INFO ) ;
		}

		PlayerNameChangeRequest [ targetid ] = 0;
		PlayerNameChangeName [ targetid ] = name;
	}

	return true ;
}

CMD:processnc ( playerid, params [] ) return cmd_processnamechange ( playerid, params ) ;

CMD:namechanges ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < BASIC_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a basic moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new string [ 512 ], count = 0 ;

	strcat ( string, "Name\tType\tNew Name\n" );

	inline DisplayNamechangeRequests(pid, dialogid, response, listitem, string:inputtext[]) {
	    #pragma unused pid, response, dialogid, listitem, inputtext

	}

	foreach ( new i : Player ) {

		if ( PlayerNameChangeRequest [ i ] ) {

			strcat ( string, sprintf("%s \t %s \t %s\n", ReturnUserName(i, true), (PlayerNameChangeRequest [ i ] == 1) ? ("Character") : ("Master Account"), PlayerNameChangeName [ i ] ) ) ;
			count ++;
		}
		else continue;
	}

	if ( ! count ) {

		return SendServerMessage ( playerid, "There are no current namechange requests.", MSG_TYPE_ERROR ) ;
	}

	Dialog_ShowCallback ( playerid, using inline DisplayNamechangeRequests, DIALOG_STYLE_TABLIST_HEADERS, "Namechange Requests", string, "Continue");

	return true ;
}

CMD:acceptreport ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new targetid ;

	if ( sscanf ( params, "k<u>", targetid ) ) {

		return SendServerMessage ( playerid, "/acceptreport [targetid]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( targetid ) ) {

		return SendServerMessage ( playerid, "That player doesn't seem to be connected anymore.", MSG_TYPE_ERROR ) ;
	}

	if ( ! PlayerHasPendingReport [ targetid ] ) {

		return SendServerMessage ( playerid, "That player doesn't seem to have a pending report.", MSG_TYPE_ERROR ) ;
	}

	PlayerHasPendingReport [ targetid ] = false ;

	SendServerMessage ( targetid, sprintf("Your report has been accepted by moderator (%d) %s. They will contact you shortly.", playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_INFO ) ;
	SendModeratorWarning ( sprintf("[REPORT] (%d) %s accepted the report of (%d) %s: %s", playerid, ReturnUserName ( playerid, true ), targetid, ReturnUserName ( targetid, true ), PlayerReportReason [ targetid ] ), MOD_WARNING_LOW ) ;
	//OldLog ( INVALID_PLAYER_ID, "mod/ar", sprintf("(%d) %s accepted the report of (%d) %s: %s", playerid, ReturnUserName ( playerid, true ), targetid, ReturnUserName ( targetid, true ), PlayerReportReason [ targetid ] ) ) ;

	return true ;
}

CMD:ar ( playerid, params [] ) {

	return cmd_acceptreport ( playerid, params ) ;
}

CMD:denyreport ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new targetid, reason[ 64 ] ;

	if ( sscanf ( params, "k<u>s[64]", targetid, reason ) ) {

		return SendServerMessage ( playerid, "/denyreport [targetid] [reason]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( targetid ) ) {

		return SendServerMessage ( playerid, "That player doesn't seem to be connected anymore.", MSG_TYPE_ERROR ) ;
	}

	if ( ! PlayerHasPendingReport [ targetid ] ) {

		return SendServerMessage ( playerid, "That player doesn't seem to have a pending report.", MSG_TYPE_ERROR ) ;
	}

	if ( ! strlen ( reason ) ) {

		return SendServerMessage ( playerid, "You need to give a reason to deny the report.", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( reason ) > 64 ) {

		return SendServerMessage ( playerid, "Reason cannot be longer than 64 characters.", MSG_TYPE_ERROR ) ;
	}

	PlayerHasPendingReport [ targetid ] = false ;

	SendServerMessage ( targetid, sprintf("Your report has been denied by moderator (%d) %s. Reason: %s.", playerid, ReturnUserName ( playerid, true, false ), reason ), MSG_TYPE_INFO ) ;
	SendModeratorWarning ( sprintf("[REPORT] (%d) %s denied the report of (%d) %s: %s", playerid, ReturnUserName ( playerid, true, false ), targetid, ReturnUserName ( targetid, true, false ), PlayerReportReason [ targetid ] ), MOD_WARNING_LOW ) ;
	SendModeratorWarning ( sprintf("Reason: %s", reason ), MOD_WARNING_LOW ) ;

	return true ;
}

CMD:dr ( playerid, params [] ) {

	return cmd_denyreport ( playerid, params ) ;
}

CMD:reports ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < TRIAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a trial moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new string [ 1024 ], count ;

	inline DisplayReports(pid, dialogid, response, listitem, string:inputtext[]) {
	    #pragma unused pid, response, dialogid, listitem, inputtext

	}

	string[0] = EOS;

	strcat(string,"Reporter\tReported\tReason\tTime\n");

	foreach(new i: Player) {

		if ( PlayerHasPendingReport [ i ] ) {

			count ++ ;
			format ( string, sizeof ( string ), "%s(%d) %s\t(%d) %s\t%s\t%s\n",string,i,ReturnUserName(i,false),PlayerReportedID[i],ReturnUserName(PlayerReportedID[i],false),PlayerReportReason [ i ], GetDuration(gettime() - PlayerReportTime[i]) ) ;
		}
	}

	if ( count == 0 ) {

		string = "No reports to display." ;
	}

	Dialog_ShowCallback ( playerid, using inline DisplayReports, DIALOG_STYLE_TABLIST_HEADERS, "Reports", string, "Continue");

	return true ;
}

CMD:report ( playerid, params [] ) {

	if ( PlayerReportCooldown [ playerid ]  >= gettime ()) {

		return SendServerMessage ( playerid, sprintf("You need to wait %d seconds before sending another report", PlayerReportCooldown[playerid] - gettime ()), MSG_TYPE_WARN ) ;
	}

	new targetid, reason [ 64 ] ;

	if ( sscanf ( params, "k<u>s[64]", targetid, reason ) ) {

		return SendServerMessage ( playerid, "/report [playerid] [reason]", MSG_TYPE_ERROR ) ;
	}

	if(!IsPlayerConnected(targetid)) {

		return SendServerMessage(playerid,"That playerid is not connected.",MSG_TYPE_ERROR);
	}

	if ( strlen ( reason ) > 64 ) {

		return SendServerMessage ( playerid, "Reports should be brief! You can't have more than 64 characters.", MSG_TYPE_ERROR ) ;
	}

	format ( PlayerReportReason [ playerid ], sizeof ( reason ), "%s", reason ) ;
	//printf("%s, %s", reason, PlayerReportReason [ playerid ]) ;

	PlayerReportedID[playerid] = targetid;
	PlayerHasPendingReport [ playerid ] = true ;
	PlayerReportCooldown [ playerid ] = gettime () + 30 ;
	PlayerReportTime[ playerid ] = gettime (); 

	new string [ 256 ] ;

	SendServerMessage ( playerid, "Report successfully sent. Please wait a few minutes before reporting again.", MSG_TYPE_WARN ) ;

	foreach(new i: Player) {
		if ( IsPlayerModerator ( i ) ) {

			format ( string, sizeof ( string ), "{59BD93}[REPORT]{DEDEDE} (%d) %s is reporting (%d) %s:{DEDEDE} %s", playerid, ReturnUserName ( playerid, true ), targetid, ReturnUserName(targetid),reason ) ;
			SendSplitMessage(i, 0xDEDEDEFF, string ) ;
			
			if(Account[targetid][account_rulecheck]) { SendClientMessage(i, 0xDEDEDEFF, sprintf( "{CF4040}[WARNING]{DEDEDE} (%d) %s is flagged as a \"Potential Rulebreaker\".",targetid,ReturnUserName(targetid))); }
			SendClientMessage(i, 0xDEDEDEFF, sprintf("To accept this report, type {59BD93}/acceptreport %d (/ar)", playerid ) ) ;
		}

		else continue ;
	}

	//OldLog ( playerid, "reports", sprintf("(%d) %s reports: %s", playerid, ReturnUserName ( playerid, true ), reason ) ) ;

	return true ;
}

CMD:re(playerid, params[]){

	return cmd_reports(playerid,params);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:mod(playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	new text [ 144 ] ;

	if ( sscanf ( params, "s[144]", text ) ) {

		return SendServerMessage ( playerid, "/mod [text]", MSG_TYPE_ERROR ) ;
	}

	if(HasPlayerMutedModeratorChat[playerid]) {

		return SendServerMessage(playerid,"You can't talk in moderator chat unless you unmute moderator chat.",MSG_TYPE_ERROR);
	}

	SendModeratorMessage ( playerid, text ) ;

	return true ;
}

CMD:m(playerid, params [] ) {

	return cmd_mod ( playerid, params ) ;
}

SendModeratorWarning ( text [], type ) {

	foreach (new i: Player) {

		if ( ! IsPlayerConnected ( i ) ) continue ;

		if ( IsPlayerModerator ( i ) && PlayerModWarnings [ i ] && !HasPlayerMutedModeratorChat[i]) {

			switch ( type ) {

				case MOD_WARNING_LOW: {
					SendSplitMessage(i, ADMIN_BLUE, text ) ;
				}

				case MOD_WARNING_MED: {
					SendSplitMessage(i, COLOR_YELLOW, text ) ;
				}

				case MOD_WARNING_HIGH: {
					SendSplitMessage(i, COLOR_RED, text ) ;
				}
			}
		}

		else continue ;
	}


	print(text ) ;

	return true ;
}

SendModeratorMessage ( playerid, text [] ) {
	
	new string[256],staff_rank [ 64 ] ;

	if ( IsPlayerManager ( playerid ) ) {

		format ( staff_rank, sizeof ( staff_rank), "%s",  GetStaffRankName ( Account [ playerid ] [ account_stafflevel ] ) ) ;
	}

	else format ( staff_rank, sizeof ( staff_rank), "%s",  GetStaffGroupName ( Account [ playerid ] [ account_staffgroup ] ) ) ;

	foreach (new i: Player) {

		if ( IsPlayerModerator ( i ) ) {

			if ( strlen ( Account [ playerid ] [ account_staffname ] ) == 0 ) {

				format(string,sizeof(string),"[MOD] %s %s (%d){DEDEDE}: %s", staff_rank, ReturnUserName ( playerid, true ), playerid, text );
				SendSplitMessage(i,0x46B346FF,string);
			}

			else {
				
				format(string,sizeof(string),"[MOD] %s %s (%s) (%d){DEDEDE}: %s", staff_rank, ReturnUserName ( playerid, true ), Account [ playerid ] [ account_staffname ], playerid, text ) ;
				SendSplitMessage(i,0x46B346FF,string);
			}
		}
	}

	//OldLog ( playerid, "mod/chats", sprintf("[MOD] %s %s (%d) said \"%s\"", staff_rank, ReturnUserName ( playerid, true ), playerid, text ) ) ;

	return true ;
}

PurgeReports() {

	new dummystring[64];
	dummystring[0] = EOS;
	foreach(new i : Player) {

		PlayerReportReason[i] = dummystring;
		PlayerReportedID[i] = INVALID_PLAYER_ID;
		PlayerHasPendingReport[i] = false;
		PlayerReportCooldown[i] = 0;
	}
	return true;
}