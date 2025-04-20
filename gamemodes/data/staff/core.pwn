/*

	/iptrace
	/spec

*/

new PlayerModWarnings 	[ MAX_PLAYERS ] ; 
new HasPlayerMutedSupporterChat[MAX_PLAYERS];
new HasPlayerMutedModeratorChat[MAX_PLAYERS];

/*
new StaffRank [] [ ] = {

	{ "None" } ,
	{ "Supporter" } ,
	{ "Moderator" } ,
	{ "Management" }
} ;

new StaffGroup [ ] [ ] = {

	{ "None" },
	{ "Trial Moderator"},
	{ "Basic Moderator" },
	{ "General Moderator" },
	{ "Advanced Moderator" }

} ;
*/

//#include "data/staff/logs.pwn"
#include "data/staff/coc.pwn"

#include "data/staff/man/core.pwn"
#include "data/staff/supp/core.pwn"
#include "data/staff/mods/core.pwn"
#include "data/staff/arecord.pwn"


GetStaffRankName ( stafflevel ) {
	
	new staffrankname[36];
	switch(stafflevel) {

		case 0: { staffrankname = "None"; }
		case 1: { staffrankname = "Supporter"; }
		case 2: { staffrankname = "Moderator"; }
		case 3: { staffrankname = "Management"; }
		default: { staffrankname = "N/A"; }
	}
	return staffrankname;
}

GetStaffGroupName ( grouplevel ) {
	
	new staffgroupname[36];
	switch(grouplevel) {

		case 0: { staffgroupname = "None"; }
		case 1: { staffgroupname = "Trial Moderator"; }
		case 2: { staffgroupname = "Basic Moderator"; }
		case 3: { staffgroupname = "General Moderator"; }
		case 4: { staffgroupname = "Advanced Moderator"; }
		default: { staffgroupname = "N/A"; }
	}
	return staffgroupname;
}

/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

CMD:anote(playerid, params[]) {

	if ( ! IsPlayerStaff ( playerid ) ) {

		return SendServerMessage ( playerid, "You're not a staff member.", MSG_TYPE_ERROR ) ;
	}

	new option [ 32 ], target, note [ 256 ], buffer[256] ;

	if ( sscanf ( params, "s[32]uS(0)[256]", option, target, note )) {

		return SendServerMessage ( playerid, "/anote [add/check]", MSG_TYPE_ERROR ) ;
	}

	if ( ! strcmp ( option, "add", true ) ) {

		if ( ! IsPlayerConnected ( target ) ) {

			return SendServerMessage ( playerid, "Target isn't connected.", MSG_TYPE_ERROR ) ;
		}

		if ( ! strlen ( note ) || strlen ( note ) > 64 ) {

			return SendServerMessage ( playerid, "Notes can't be empty or be longer than 128 characters.", MSG_TYPE_ERROR ) ;
		}

		strcat(buffer, Account [ target ] [ account_anote ]);

		Account [ target ] [ account_anote ] [ 0 ] = EOS ;
		strcat ( Account [ target ] [ account_anote ], note );

		SendClientMessage(playerid, COLOR_YELLOW, sprintf("You've changed (%d) %s's admin note to:", target, ReturnUserName(target)));
		SendClientMessage(playerid, 0xDEDEDEFF, sprintf("%s", Account [ target ] [ account_anote ])) ;

		format ( buffer, sizeof ( buffer ), "Old admin note: %s", buffer ) ;
		SendClientMessage(playerid, COLOR_YELLOW, buffer);

		buffer [ 0 ] = EOS ;

		mysql_format (mysql, buffer, sizeof ( buffer ), "UPDATE master_accounts SET account_anote='%s' WHERE account_id=%d", Account [ target ] [ account_anote ], Account [ target ] [ account_id ]) ;
		mysql_tquery(mysql, buffer);
	}

	else if ( ! strcmp ( option, "check", true ) ) {

		if ( ! IsPlayerConnected ( target ) ) {

			return SendServerMessage ( playerid, "Target isn't connected.", MSG_TYPE_ERROR ) ;
		}

		strcat(buffer, Account [ target ] [ account_anote ]);

		format ( buffer, sizeof ( buffer ), "(%d) %s's admin note: %s", target, ReturnUserName(target), buffer ) ;
		SendClientMessage(playerid, COLOR_YELLOW, buffer);
	}

	return true ;
}

/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

CMD:answer ( playerid, params [] ) {

	if ( ! IsPlayerStaff ( playerid ) ) {

		return SendServerMessage ( playerid, "You're not a staff member.", MSG_TYPE_ERROR ) ;
	}

	new userid, answer [ 144 ] ;

	if ( sscanf ( params, "k<u>s[144]", userid, answer ) ) {

		return SendServerMessage ( playerid, "/answer [id] [answer]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( userid ) ) {

		return SendServerMessage ( playerid, "Player is not connected.", MSG_TYPE_ERROR ) ;
	}

	SendSplitMessage(userid, 0xDEDEDEFF, sprintf("{44639C}[ANSWER]{DEDEDE} (%d) %s replied: %s", playerid, ReturnUserName ( playerid, true ), answer ) ) ;

	foreach(new i: Player) {

		if ( IsPlayerConnected ( i ) && IsPlayerStaff ( i ) ) {

			SendClientMessage(i, 0xDEDEDEFF, sprintf("{44639C}[ANSWER]{DEDEDE} (%d) %s replied to (%d) %s:", playerid, ReturnUserName ( playerid, true ), userid, ReturnUserName ( userid, true ) ) ) ;
			SendSplitMessage(i, 0xDEDEDEFF, sprintf("%s", answer));
		}

		else continue ;
	}

	WriteLog ( playerid, "mod/answers", sprintf("(%d) %s replied to (%d) %s: %s", playerid, ReturnUserName ( playerid, true ), userid, ReturnUserName ( userid, true ), answer ) ) ;

	return true ;
}

CMD:staff ( playerid, params [] ) {

	new string [ 256 ], count, name [ MAX_PLAYER_NAME * 2 ] ;


	SendClientMessage(playerid, MANAGER_COLOR, "Online Managers");

	foreach (new i: Player) {

		if ( GetStaffLevel ( i ) >= STAFF_MANAGER ) {

			count ++ ;

			if ( strlen ( Account [ i ] [ account_staffname ] ) == 0 ) {
				format ( name, sizeof ( name ), "%s", ReturnUserName ( i, true ) ) ;
			}

			else format ( name, sizeof ( name ), "%s (%s)", ReturnUserName ( i, true ), Account [ i ] [ account_staffname ] ) ;

			format ( string, sizeof ( string ), "(%d) %s", i, name ) ;
			SendClientMessage(playerid, 0xDEDEDEFF, string ) ;
		}
	}

	if ( count <= 0 ) {
		SendClientMessage(playerid, COLOR_DEFAULT, "None" ) ;
	}

	count = 0 ;

	SendClientMessage(playerid, MODERATOR_COLOR, "Online Moderators");

	foreach (new i: Player) {

		if ( GetStaffLevel ( i ) == STAFF_MODERATOR ) {
			count ++ ;

			if ( strlen ( Account [ i ] [ account_staffname ] ) == 0 ) {
				format ( name, sizeof ( name ), "%s", ReturnUserName ( i, true, false ) ) ;
			}

			else format ( name, sizeof ( name ), "%s (%s)", ReturnUserName ( i, true, false ), Account [ i ] [ account_staffname ] ) ;

			if ( IsPlayerOnAdminDuty [ i ] ) {

				format ( string, sizeof ( string ), "%s %s (%d): {007FFF}On Duty", GetStaffGroupName ( Account [ i ] [ account_staffgroup ] ) , name, i ) ;
				SendClientMessage(playerid, 0xDEDEDEFF, string ) ;
			}

			else {

				format ( string, sizeof ( string ), "%s %s (%d): {FF6347}Roleplaying", GetStaffGroupName ( Account [ i ] [ account_staffgroup ] ), name, i ) ;
				SendClientMessage(playerid, 0xDEDEDEFF, string ) ;
			}
		}
	}

	if ( count <= 0 ) {
		SendClientMessage(playerid, COLOR_DEFAULT, "None" ) ;
	}

	count = 0 ;

	SendClientMessage(playerid, SUPPORTER_COLOR, "Online Supporters");

	foreach (new i: Player) {

		if ( GetStaffLevel ( i ) == STAFF_SUPPORTER ) {


			if ( strlen ( Account [ i ] [ account_staffname ] ) == 0 ) {
				format ( name, sizeof ( name ), "%s", ReturnUserName ( i, true, false ) ) ;
			}

			else format ( name, sizeof ( name ), "%s (%s)", ReturnUserName ( i, true, false ), Account [ i ] [ account_staffname ] ) ;


			count ++ ;

			format ( string, sizeof ( string ), "(%d) %s", i, name ) ;
			SendClientMessage(playerid, 0xDEDEDEFF, string ) ;
		}
	}

	if ( count <= 0 ) {

		SendClientMessage(playerid, COLOR_DEFAULT, "None" ) ;
	}

	return true ;
}

CMD:staffisland ( playerid, params [] ) {
	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has teleported to the staff island.", ReturnUserName ( playerid, true ), playerid), MOD_WARNING_LOW ) ;
	//OldLog ( playerid, "mod/tp", sprintf("%s (%d) has teleported to the staff island.", ReturnUserName ( playerid, true ), playerid ) ) ;

	ac_SetPlayerPos ( playerid, 625.9899, -2669.7793, 1.7300 ) ;

	return true ;
}

CMD:staffhelp ( playerid, params [] ) {

	if ( ! IsPlayerStaff ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be part of the staff team in order to access this list.", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffLevel ( playerid ) >= STAFF_SUPPORTER ) {

		SendClientMessage(playerid, 0x4075A1FF, "[SUPPORTER] /support, /answer, /questions, /staffname" ) ;
	}

	if ( GetStaffLevel ( playerid ) >= STAFF_MODERATOR ) {

		if ( GetStaffGroup ( playerid ) >= TRIAL_MOD ) {


			SendClientMessage(playerid, 0x86DB86FF, "[TRIAL MODERATOR] /trialban, /aooc, /makeooc, /getc(haracters), /givelogoutperm, /fw, /up, /dn, /kick, /ac(un)invite" ) ;
			SendClientMessage(playerid, 0x86DB86FF, "[TRIAL MODERATOR] /modduty, /freeze, /unfreeze, /slap, /bring, /goto, /getma(steraccount), /coc, /spec , /atrap" ) ;
			SendClientMessage(playerid, 0x86DB86FF, "[TRIAL MODERATOR] /togmodwarnings, /staffisland, /m(od), /acceptreport, /denyreport, /reports, /ajail, /unajail, /ojail, /gotodeer" ) ;
		}

		if ( GetStaffGroup ( playerid ) >= BASIC_MOD ) {

			SendClientMessage(playerid, 0x56B356FF, "[BASIC MODERATOR] /refreshweather, /ban, /o(ffline)ban, /unban, /getstate, /toggleooc, /geoip,  /stopinjuries" ) ;
			SendClientMessage(playerid, 0x56B356FF, "[BASIC MODERATOR] /processn(ame)c(hange), /namechanges, /viewplayeritems, /supportercheck, /lastonline, /adisarm" ) ;
			SendClientMessage(playerid, 0x56B356FF, "[BASIC MODERATOR] /afrisk, /unbanip, /clearshells" ) ;
		}
		
		if ( GetStaffGroup ( playerid ) >= GENERAL_MOD ) {

			SendClientMessage(playerid, 0x3B783BFF, "[GENERAL MODERATOR] /set, /setweather, /settime, /setinterior, /setvirtualworld, /forcerespawnore, /removecheckpoints" ) ;
			SendClientMessage(playerid, 0x3B783BFF, "[GENERAL MODERATOR] /reloadpoints, /reloadposses, /gotomotel, /respawndeers, /gotoxyz, /destroydynamiclabel, /acceptlabelrequest" ) ;
			SendClientMessage(playerid, 0x3B783BFF, "[GENERAL MODERATOR] /denylabelrequest, /refreshdynamiclabels" ) ;
		}

		if ( GetStaffGroup ( playerid ) >= ADVANCED_MOD ) {

			SendClientMessage(playerid, 0x2C572CFF, "[ADVANCED MODERATOR] /givemoney, /spawnweapon, /gotodroppedweapon, /removedroppedweapon" ) ;
			SendClientMessage(playerid, 0x2C572CFF, "[ADVANCED MODERATOR] /ap(oint), /aposse, /forcepaycheck, /forcelottery, /toggleooc, /togglereports" ) ;
			SendClientMessage(playerid, 0x2C572CFF, "[ADVANCED MODERATOR] /purgequestions, /clearplayerinventory, /ctable, /dtable");
		}
	}

	if ( IsPlayerManager ( playerid ) ) {

		SendClientMessage(playerid, 0xA13A3AFF, "[MANAGEMENT] /man, /makestaff, /setstaffgroup, /makedonator, /cleardroppeditems" ) ;
	}

	return true ;
}



CMD:staffname ( playerid, params [] ) {
	if ( ! IsPlayerStaff ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a staff member in order to do this!", MSG_TYPE_ERROR ) ;
	}

	new name [ MAX_PLAYER_NAME ] ;

	if ( sscanf ( params, "s[24]", name ) ) {

		return SendServerMessage ( playerid, "/staffname [name]", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( name ) > MAX_PLAYER_NAME ) {

		return SendServerMessage ( playerid, "Name can't be longer than 24 characters.", MSG_TYPE_ERROR ) ;
	}

	new query [ 128 ] ;

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) has changed their staff name to %s.", ReturnUserName ( playerid, true ), playerid, name), MOD_WARNING_LOW ) ;
	//OldLog ( playerid, "mod/set", sprintf("%s (%d) has changed their staff name to %s.", ReturnUserName ( playerid, true ), playerid, name) ) ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_staffname = '%e' WHERE account_id = '%d'", 
	name, Account [ playerid ] [ account_id ] ) ;

	mysql_tquery ( mysql, query ) ;

	Account [ playerid ] [ account_staffname ] [ 0 ] = EOS ;
	strcat(Account [ playerid ] [ account_staffname ], name, MAX_PLAYER_NAME ) ;

	return true ;
}

/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////


IsPlayerStaff ( playerid ) {
	if ( ! IsPlayerLogged [ playerid ] ) {

		return false ;
	}

	if ( Account [ playerid ] [ account_stafflevel ] != 0 ) {

		return true ;
	}

	return false ;
}

IsPlayerSupporter ( playerid ) {

	if ( ! IsPlayerLogged [ playerid ] ) {

		return false ;
	}

	new pointer = ( GetStaffLevel ( playerid ) >= STAFF_SUPPORTER ) ? true : false ;

	return pointer ;
}

IsPlayerModerator ( playerid ) {

	if ( ! IsPlayerLogged [ playerid ] ) {

		return false ;
	}

	new pointer = ( GetStaffLevel ( playerid ) >= STAFF_MODERATOR ) ? true : false ;
	return pointer ;
}

IsPlayerManager ( playerid ) {

	if ( ! IsPlayerLogged [ playerid ] ) {

		return false ;
	}

	new pointer = ( GetStaffLevel ( playerid ) >= STAFF_MANAGER ) ? true : false ;
	return pointer ;
}

GetStaffLevel ( playerid ) {

	if ( ! IsPlayerStaff ( playerid ) ) {

		return false ;
	}

	return Account [ playerid ] [ account_stafflevel ] ;
}

GetStaffGroup ( playerid ) {

	if ( ! IsPlayerStaff ( playerid ) ) {

		return false ;
	}


	return Account [ playerid ] [ account_staffgroup ] ;
}