#include "data/staff/supp/groups/devs.pwn"
#include "data/staff/supp/groups/event.pwn"
#include "data/staff/supp/groups/faction.pwn"
#include "data/staff/supp/groups/mappers.pwn"

new bool: PlayerHasPendingQuestion [ MAX_PLAYERS ] ;
new PlayerQuestionCooldown [ MAX_PLAYERS ] ;
new PlayerQuestionAsked [MAX_PLAYERS][75] ;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:mute(playerid,params[]) {

	if ( ! IsPlayerSupporter ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a supporter in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	new choice[16];
	if(sscanf(params,"s[16]",choice)) { return SendServerMessage(playerid,"/mute [supporter/moderator]",MSG_TYPE_ERROR); }
	if(!strcmp(choice,"supporter",true)) {

		if(!HasPlayerMutedSupporterChat[playerid]) {

			HasPlayerMutedSupporterChat[playerid] = 1;
			SendServerMessage(playerid,"You've muted supporter chat, use this command again to unmute.",MSG_TYPE_INFO);
			SendSupporterWarning(sprintf("%s (%d) has muted supporter chat.",ReturnUserName(playerid,true,false)));
		}
		else {

			HasPlayerMutedSupporterChat[playerid] = 0;
			SendSupporterWarning(sprintf("%s (%d) has unmuted supporter chat.",ReturnUserName(playerid,true,false)));
		}
	}
	else if(!strcmp(choice,"moderator",true)) {

		if(!IsPlayerModerator(playerid)) {

			return SendServerMessage(playerid,"You need to be a moderator in order to be able to do this!",MSG_TYPE_WARN);
		}
		if(!HasPlayerMutedModeratorChat[playerid]) {

			HasPlayerMutedModeratorChat[playerid] = 1;
			SendServerMessage(playerid,"You've muted moderator chat, use this command again to unmute.",MSG_TYPE_INFO);
			SendModeratorWarning(sprintf("%s (%d) has muted moderator chat.",ReturnUserName(playerid,true,false)),MOD_WARNING_LOW);
		}
		else {

			HasPlayerMutedModeratorChat[playerid] = 0;
			SendModeratorWarning(sprintf("%s (%d) has unmuted moderator chat.",ReturnUserName(playerid,true,false)),MOD_WARNING_LOW);
		}
	}
	else { return SendServerMessage(playerid,"/mute [supporter/moderator]",MSG_TYPE_ERROR); }
	return true;
}

CMD:supportercheck ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	inline HandleSupporterData() {


		new rows, fields;
		cache_get_data ( rows, fields, mysql ) ;

		if ( rows ) {

			new acc_id, acc_name [ 24 ], acc_questions, string[1028] ;

			format ( string, sizeof ( string ), "Account Data \t Questions\n" ) ;

			for ( new i, j = cache_get_row_count(); i < j; i ++ ) {

				acc_id	= cache_get_field_int ( i, "account_id" ) ;

				cache_get_field_content ( i, "account_name", acc_name, mysql, MAX_PLAYER_NAME ) ;
				acc_questions	= cache_get_field_int ( i, "account_supportquestions" ) ;
				
				format ( string, sizeof ( string ), "%s[MA: %s:%d]: \t %d questions accepted\n", string, acc_name, acc_id, acc_questions ) ;
				//SendClientMessage(playerid, -1, sprintf("[%d] %s - %d of questions", acc_id, acc_name, acc_questions ) ) ;
			}

			ShowPlayerDialog(playerid, 0, DIALOG_STYLE_TABLIST_HEADERS, "Supporter Activity", string, "Close", "");


			return true ;
		}

		return true ;
	}

	mysql_tquery_inline(mysql, "SELECT account_id, account_name, account_supportquestions FROM master_accounts WHERE account_stafflevel=1",  using inline HandleSupporterData, "");

	return true ;
}

CMD:clearsupporterdata ( playerid, params [] ) {

	if ( ! IsPlayerManager ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	mysql_tquery(mysql, "SELECT account_id, account_name, account_stafflevel, account_supportquestions FROM master_accounts WHERE account_stafflevel=1");
	SendModeratorWarning ( sprintf("[SUPPORTER] (%d) %s has removed all supporter data: questions answered.", playerid, ReturnUserName ( playerid, true )), MOD_WARNING_MED ) ;

	return true ;
}

CMD:accepthelp ( playerid, params [] ) {

	if ( ! IsPlayerSupporter ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a supporter in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	new targetid ;

	if ( sscanf ( params, "k<u>", targetid ) ) {

		return SendServerMessage ( playerid, "/a(ccept)h(elp) [targetid]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( targetid ) ) {

		return SendServerMessage ( playerid, "That player doesn't seem to be connected anymore.", MSG_TYPE_ERROR ) ;
	}

	if ( ! PlayerHasPendingQuestion [ targetid ] ) {

		return SendServerMessage ( playerid, "That player doesn't seem to have a pending report.", MSG_TYPE_ERROR ) ;
	}

	PlayerHasPendingQuestion [ targetid ] = false ;

	Account [ playerid ] [ account_supportquestions ] ++ ;

	new query [ 256 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_supportquestions = %d WHERE account_id = %d", Account [ playerid ] [ account_supportquestions ], Account [ playerid ] [ account_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	SendServerMessage ( targetid, sprintf("Your question has been selected by supporter (%d) %s. They will contact you shortly.", playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_INFO ) ;

	SendSupporterWarning ( sprintf("[QUESTION] (%d) %s selected question of (%d) %s", playerid, ReturnUserName ( playerid, true ), targetid, ReturnUserName ( targetid, true ) ) ) ;
	SendSupporterWarning ( sprintf("\"%s\"",PlayerQuestionAsked [ targetid ] )) ;

	WriteLog ( playerid, "supporter/ah", sprintf("(%d) %s selected question of (%d) %s: %s", playerid, ReturnUserName ( playerid, true ), targetid, ReturnUserName ( targetid, true ), PlayerQuestionAsked [ targetid ] ) ) ;

	return true ;
}

CMD:ah ( playerid, params [] ) {

	return cmd_accepthelp ( playerid, params ) ;
}

CMD:questions ( playerid, params [] ) {
	if ( ! IsPlayerSupporter ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a supporter in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	new string [ 1024 ], count ;

	inline DisplayQuestions(pid, dialogid, response, listitem, string:inputtext[]) {
	    #pragma unused pid, response, dialogid, listitem, inputtext

	}

	foreach(new i: Player) {

		if ( PlayerHasPendingQuestion [ i ] ) {

			count ++ ;
			format ( string, sizeof ( string ), "%s\n(%d) %s: %s", string, i, ReturnUserName ( i, false ), PlayerQuestionAsked [ i ] ) ;
		}

		else continue ;
	}

	if ( count == 0 ) {

		string = "No questions to display." ;
	}

	Dialog_ShowCallback ( playerid, using inline DisplayQuestions, DIALOG_STYLE_LIST, "Welcome!", string, "Continue");

	return true ;
}

CMD:ask ( playerid, params [] ) {

	if ( PlayerQuestionCooldown [ playerid ]  >= gettime ()) {

		return SendServerMessage ( playerid, sprintf("You need to wait %d seconds before asking another question.", PlayerQuestionCooldown[playerid] - gettime ()), MSG_TYPE_WARN ) ;
	}

	new question [ 75 ] ;

	if ( sscanf ( params, "s[75]", question ) ) {

		return SendServerMessage ( playerid, "/ask [question]", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( question ) > 75 ) {

		return SendServerMessage ( playerid, "Keep questions to the point. No more than 100 characters.", MSG_TYPE_WARN);
	}

	format ( PlayerQuestionAsked [ playerid ], sizeof ( question ), "%s", question ) ;
	//printf("%s, %s", question, PlayerQuestionAsked [ playerid ]) ;

	PlayerHasPendingQuestion [ playerid ] = true ;
	PlayerQuestionCooldown [ playerid ] = gettime () + 30 ;

	new string [ 256 ] ;

	format(string, sizeof ( string ), "You asked \"%s\", a supporter will contact you soon!", PlayerQuestionAsked [ playerid ] ) ;
	SendSplitMessage ( playerid, SUPPORTER_COLOR, string  ) ;

	foreach(new i: Player) {

		if ( IsPlayerSupporter ( i ) ) {

			format(string, sizeof(string), "{44639C}[QUESTION] (%d) %s asks:{DEDEDE} %s", playerid, ReturnUserName ( playerid, true ), question )  ;
			SendSplitMessage(i, 0xDEDEDEFF, string ) ;
			
			SendClientMessage(i, 0xDEDEDEFF, sprintf("To answer this question, type {59BD93}/accepthelp %d (/ah)", playerid ) ) ;
		}

		else continue ;
	}

	return true ;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:support ( playerid, params [] ) {

	if ( ! IsPlayerSupporter ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a supporter in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	new text [ 144 ] ;

	if ( sscanf ( params, "s[144]", text ) ) {

		return SendServerMessage ( playerid, "/support or /sc [text]", MSG_TYPE_ERROR ) ;
	}

	if(HasPlayerMutedSupporterChat[playerid]) {

		return SendServerMessage(playerid,"You can't talk in supporter chat unless you unmute supporter chat.",MSG_TYPE_ERROR);
	}

	SendSupporterMessage ( playerid, text ) ;

	return true ;
}

CMD:sc ( playerid, params [] ) {

	return cmd_support ( playerid, params ) ;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

SendSupporterWarning ( text [] ) {

	foreach (new i: Player) {

		if ( ! IsPlayerConnected ( i ) ) continue ;

		if ( IsPlayerSupporter ( i ) && !HasPlayerMutedSupporterChat[i] ) {

			SendClientMessage(i, SUPPORTER_COLOR, text ) ;
		}

		else continue ;
	}

	return true ;
}

SendSupporterMessage ( playerid, text [] ) {

	new string[256],staff_rank [ 64 ] ; 

	format ( staff_rank, sizeof ( staff_rank), "%s",  GetStaffRankName ( Account [ playerid ] [ account_stafflevel ] ) ) ;

	if ( IsPlayerModerator ( playerid ) && ! IsPlayerManager ( playerid ) ) {

		format ( staff_rank, sizeof ( staff_rank), "%s",  GetStaffGroupName ( Account [ playerid ] [ account_staffgroup ] ) ) ;
	}

	foreach (new i: Player) {

		if ( IsPlayerSupporter ( i ) ) {

			if ( strlen ( Account [ i ] [ account_staffname ] ) == 0 ) {

				format(string,sizeof(string),"[SUP] %s %s (%d){DEDEDE}: %s", staff_rank, ReturnUserName ( playerid, true, false ), playerid, text );
				SendSplitMessage(i,0x467CB3FF,string);
			}

			else {
				
				format(string,sizeof(string),"[SUP] %s %s (%s) (%d){DEDEDE}: %s", staff_rank, ReturnUserName ( playerid, true, false ), Account [ playerid ] [ account_staffname ], playerid, text ) ;
				SendSplitMessage(i,0x467CB3FF,string);
			}
		}
	}

	//OldLog ( playerid, "mod/chats", sprintf("[SUP] %s %s (%d) said \"%s\"", staff_rank, ReturnDateTime ( ), ReturnUserName ( playerid, true ), playerid, text ) ) ;

	return true ;
}

PurgeQuestions() {

	new dummystring[75];
	dummystring[0] = EOS;
	foreach(new i : Player) {

		PlayerQuestionAsked[i] = dummystring;
		PlayerHasPendingQuestion[i] = false;
		PlayerQuestionCooldown[i] = 0;
	}
	return true;
}