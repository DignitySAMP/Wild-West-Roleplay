#include "data/account/utils/account.pwn"
#include "data/account/func/register.pwn"

#include "data/account/utils/character.pwn"
#include "data/account/utils/levels.pwn"
#include "data/account/utils/tasks.pwn"

#include "data/account/gui/select.pwn"
#include "data/account/ext/intro.pwn"
#include "data/account/donator/core.pwn"
#include "data/account/ext/quiz.pwn"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

new PlayerNameChangeRequest [ MAX_PLAYERS ], PlayerNameChangeName [ MAX_PLAYERS ] [ MAX_PLAYER_NAME ] ;

public OnPlayerConnect ( playerid ) {
	TogglePlayerSpectating ( playerid, true ) ;

	foreach(new i: Player) {

		if ( ! strcmp ( ReturnPlayerName ( playerid ), Account [ i ] [ account_name ], true) && IsPlayerLogged [ i ] ) {

			SendModeratorWarning ( sprintf("%s tried to connect onto (%d) %s's master account (%s).", ReturnIP ( playerid ), i, ReturnUserName ( i), Account [ i ] [ account_name ]), MOD_WARNING_HIGH ) ;
			SendClientMessage ( playerid, COLOR_YELLOW, "Someone is already connected on this master account. Try again later or contact a moderator on Discord." ) ;
			KickPlayer ( playerid ) ;
		}

		if ( ! strcmp (ReturnIP ( playerid ), ReturnIP ( i ), true ) && IsPlayerLogged [ i ] ) {
			SendModeratorWarning ( sprintf("(%d) %s is connecting with IP %s. It is already in use by (%d) %s (%s).", playerid, ReturnUserName ( playerid ), ReturnIP ( playerid ), i, ReturnUserName ( i ), ReturnIP ( i )), MOD_WARNING_HIGH ) ;

			continue ;
		}

		else continue ;
	}

	ClearData ( playerid ) ;
	PassedSelectionScreen [ playerid ] = false ;

	LoadCharacterSelectDraws ( playerid ) ;
	LoadCreationTextDraws ( playerid ) ;

	#if defined acc_OnPlayerConnect 
		return acc_OnPlayerConnect ( playerid );
	#else
		return Account_ConnectionCheck ( playerid ) ;
	#endif
}
#if defined _ALS_OnPlayerConnect 
	#undef OnPlayerConnect 
#else
	#define _ALS_OnPlayerConnect 
#endif

#define OnPlayerConnect  acc_OnPlayerConnect 
#if defined acc_OnPlayerConnect 
	forward acc_OnPlayerConnect ( playerid );
#endif

public OnPlayerDisconnect ( playerid, reason ) {

	if(!reason) { SetCharacterLoggedPosition ( playerid, 1 ) ; }
	else { SetCharacterLoggedPosition(playerid); }

	ClearData ( playerid ) ;

	#if defined acc_OnPlayerDisconnect
		return acc_OnPlayerDisconnect ( playerid, reason );
	#else
		return true ;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif

#define OnPlayerDisconnect acc_OnPlayerDisconnect
#if defined acc_OnPlayerDisconnect
	forward acc_OnPlayerDisconnect ( playerid, reason );
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:relog ( playerid, params [] ) {

	if ( ! IsPlayerLogged [ playerid ] ) {

		HideCharacterTextDraws ( playerid ) ;
		HideCreationTextDraws ( playerid ) ;

		ClearData ( playerid ) ;

		defer ReInit_AuthPanel[1000](playerid);
	}

	else return SendServerMessage ( playerid, "You can't do this when you're already logged in. Use /logout", MSG_TYPE_ERROR ) ;

	return true ;
}

CMD:statistics ( playerid, params [] ) {

	if ( ! IsPlayerSpawned ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be spawned and logged in to use this command!", MSG_TYPE_ERROR ) ;
	}

	ShowPlayerStatistics ( playerid ) ;

	SendServerMessage ( playerid, "You can use /guns to view your holstered weapons.", MSG_TYPE_INFO ) ;
	SendServerMessage ( playerid, "You can press ~k~~CONVERSATION_NO~ to open your inventory.", MSG_TYPE_INFO ) ;

	return true ;
}

CMD:stats ( playerid, params [] ) return cmd_statistics ( playerid, params ) ;

ShowPlayerStatistics ( playerid, forplayerid = INVALID_PLAYER_ID ) {

	if ( forplayerid == INVALID_PLAYER_ID ) {

		forplayerid = playerid ;
	}

	SendClientMessage(playerid, COLOR_TAB0, sprintf("|________________________| Statistics of (%d) %s [accid: %d, charid: %d] |________________________|", forplayerid, ReturnUserName ( forplayerid, true ), Account [ forplayerid][account_id], Character [ forplayerid ] [ character_id ] ) ) ;

	new string [ 512 ], date [ 6 ];

	TimestampToDate ( Account [ forplayerid ] [ account_lastlogin ], date[0], date[1], date[2], date[3], date[4], date[5], 1 ) ;

	format ( string, sizeof ( string ), "[ACCOUNT]{A3A3A3} [Master Account]: %s{FFFFFF} [Creation Date]: %s{A3A3A3} [Last Login Date]: %02d/%02d/%d - %02d:%02d:%02d", 
		Account [ forplayerid ] [ account_name ] , Account [ forplayerid ] [ account_creation ], date[2], date[1], date[0], date[3], date[4], date[5] ) ;

	SendClientMessage(playerid, COLOR_TAB1, string ) ;


	format ( string, sizeof ( string ), "[DATA]{A3A3A3} [Staff Level]: %s (%d){FFFFFF} [Staff Group]: %s (%d){A3A3A3} [Donator Level]: %s (%d){FFFFFF}",
		GetStaffRankName ( Account [ forplayerid ] [ account_stafflevel ] ), 		Account [ forplayerid ] [ account_stafflevel ], 
		GetStaffGroupName ( Account [ forplayerid ] [ account_staffgroup ] ), 		Account [ forplayerid ] [ account_staffgroup ], 
		GetDonatorRank ( Account [ forplayerid ] [ account_donatorlevel ] ), 	Account [ forplayerid ] [ account_donatorlevel ]) ;

	SendClientMessage(playerid, COLOR_TAB2, string ) ;

	format ( string, sizeof ( string ), "[LEVEL]{A3A3A3} [Level]: %d (%d exp left){FFFFFF} [Skill Points: %d]{A3A3A3} [Hours: %d]",
		Character [ forplayerid ] [ character_level ], 
		Character [ forplayerid ] [ character_expleft ], 
		Character [ forplayerid ] [ character_skillpoints ], 
		Character [ forplayerid ] [ character_hours ] ) ;

	SendClientMessage(playerid, COLOR_TAB1, string ) ;

	format ( string, sizeof ( string ), "[MONEY]{A3A3A3}[Money]: $%s.%02d{FFFFFF} [Bank Money]: $%s.%02d {A3A3A3}[Paycheck]: $%s.%02d", 
				IntegerWithDelimiter ( Character [ forplayerid ] [ character_handmoney ] ),
				Character[forplayerid][character_handchange], 
				IntegerWithDelimiter ( Character [ forplayerid ] [ character_bankmoney ] ) , 
				Character[forplayerid][character_bankchange],
				IntegerWithDelimiter ( Character [ forplayerid ] [ character_paycheck ] ),
				Character[forplayerid][character_paychange]) ;

	SendClientMessage(playerid, COLOR_TAB2, string ) ;

	new posserankname[36];
	format(posserankname,sizeof(posserankname),"%s",Character [ forplayerid ] [ character_posserank ]);
	format ( string, sizeof ( string ), "[GROUP]{A3A3A3} [Posse]: %s (%d){FFFFFF}, [Posse Tier]: %s{A3A3A3} [Posse Rank]: %s",
		GetPosseName(Character [ forplayerid ] [ character_posse ]),
		Character [ forplayerid ] [ character_posse ], 
		GetPosseTierName(Character [ forplayerid ] [ character_possetier ]), 
		(Character [ forplayerid ] [ character_posse ] != -1) ? (posserankname) : ("N/A")) ;

	SendClientMessage(playerid, COLOR_TAB1, string ) ;

	new const genderSel [ ] [0] = { "Male" , "Female" } ;
	new const originSel [ ] [0]= { "Caucasian", "Hispanic", "African", "Asian", "Native" } ;
	new const townSel 	[ ] [0]= { "Longcreek", "Fremont" } ;

	format ( string, sizeof ( string ), "[CHAR]{A3A3A3} [Gender]: %s{FFFFFF} [Age]: %d{A3A3A3} [Skin ID]: %d",
		genderSel [ Character [ forplayerid ] [ character_gender ] ][0], 
		Character [ forplayerid ] [ character_age ], 
		Character [ forplayerid ] [ character_skin ]);

	SendClientMessage(playerid, COLOR_TAB2, string ) ;

	format(string,sizeof(string),"[CHAR]{A3A3A3} [Race]: %s{FFFFFF} [Spawn Town]: %s",
		originSel [ Character [ forplayerid ] [ character_origin ] ][0],
		townSel [ Character [ forplayerid ] [ character_town ] ][0]);

	SendClientMessage(playerid, COLOR_TAB1, string);

	return true ;
}

CMD:namechange ( playerid, params [] ) {

	if ( Account [ playerid ] [ account_namechanges ] == 0 ) {

		return SendServerMessage ( playerid, "You don't have any namechanges to use!", MSG_TYPE_ERROR ) ;
	}

	if ( PlayerNameChangeRequest [ playerid ] != 0 ) {

		return SendServerMessage ( playerid, "You've already requested a namechange!", MSG_TYPE_ERROR ) ;
	}

	new query [ 128 ], option [ 16 ], name [ MAX_PLAYER_NAME ] ;

	if ( sscanf ( params, "s[16]s["#MAX_PLAYER_NAME"]", option, name ) ) {

		SendServerMessage ( playerid, "/n(ame)c(hange) [character/account] [new name]", MSG_TYPE_INFO ) ;
		return SendServerMessage ( playerid, sprintf("You currently have %i %s.", Account [ playerid ] [ account_namechanges ], (Account [ playerid ] [ account_namechanges ] == 1) ? ("namechange") : ("namechanges") ), MSG_TYPE_INFO ) ;
	}

	if ( ! strcmp ( option, "character", true ) ) {

		if ( Account [ playerid ] [ account_namechanges ] < 1 ) { 

			return SendServerMessage ( playerid, "You need at least 1 namechanges to change your character name!", MSG_TYPE_ERROR ) ;
		}

		inline CheckIfCharacterExists() {

			new rows, fields;
			cache_get_data ( rows, fields, mysql ) ;

			if ( rows ) {

				return SendServerMessage ( playerid, "This character name already exists.", MSG_TYPE_ERROR ) ;
			}

			else {

				PlayerNameChangeRequest [ playerid ] = 1;
				PlayerNameChangeName [ playerid ] = name;

				foreach(new i: Player) {
					
					if ( IsPlayerModerator ( i ) ) {

						SendClientMessage(i, COLOR_STAFF, sprintf( "[NAMECHANGE] (%d) %s requests a {DEDEDE}%s{59BD93} namechange to :{DEDEDE} %s", playerid, ReturnUserName ( playerid, true, false ), (PlayerNameChangeRequest [ playerid ] == 1) ? ("Character") : ("Master Account"), PlayerNameChangeName [ playerid ] ) ) ;
						SendClientMessage(i, 0xDEDEDEFF, sprintf("To accept or deny the namechange, type {59BD93}/processnamechange %d [accept/deny] (/processnc)", playerid ) ) ;
					}

					else continue ;
				}
			}

		}

		mysql_format ( mysql, query, sizeof ( query ), "SELECT character_name FROM characters WHERE character_name = '%e'", name ) ;
		mysql_tquery_inline(mysql, query, using inline CheckIfCharacterExists, "");

	}

	else if ( ! strcmp ( option, "account", true ) ) {

		if ( Account [ playerid ] [ account_namechanges ] < 2 ) { 

			return SendServerMessage ( playerid, "You need at least 2 namechanges to change your master account name!", MSG_TYPE_ERROR ) ;
		}

		inline CheckIfMasterAccountExists() {

			new rows, fields;
			cache_get_data ( rows, fields, mysql ) ;

			if ( rows ) {

				return SendServerMessage ( playerid, "This master account name already exists.", MSG_TYPE_ERROR ) ;
			}

			else {

				PlayerNameChangeRequest [ playerid ] = 2;
				PlayerNameChangeName [ playerid ] = name;

				foreach(new i: Player) {

					if ( IsPlayerModerator ( i ) ) {

						SendClientMessage(i, COLOR_STAFF, sprintf( "[NAMECHANGE] (%d) %s requests a {DEDEDE}%s{59BD93} namechange to :{DEDEDE} %s", playerid, ReturnUserName ( playerid, true ), (PlayerNameChangeRequest [ playerid ] == 1) ? ("Character") : ("Master Account"), PlayerNameChangeName [ playerid ] ) ) ;
						SendClientMessage(i, 0xDEDEDEFF, sprintf("To accept or deny the namechange, type {59BD93}/processnamechange %d [accept/deny] (/processnc)", playerid ) ) ;
					}

					else continue ;
				}
			}

		}

		mysql_format ( mysql, query, sizeof ( query ), "SELECT account_name FROM master_accounts WHERE account_name = '%e'", name ) ;
		mysql_tquery_inline(mysql, query, using inline CheckIfMasterAccountExists, "");
	}

	else return SendServerMessage(playerid,"[character/account] are options, you don't put a name for this parameter.",MSG_TYPE_ERROR);

	return true ;
}
task CharacterPrimaryNeeds[600000]() {

	new query[128];
	foreach(new i : Player) {

		if ( IsPlayerPaused(i)) {

			continue ;
		}

		if(IsPlayerSpawned(i)) {

			if(IsPlayerOnAdminDuty[i]) { continue; }
			Character[i][character_hunger]--;
			Character[i][character_thirst] -= 2;
			if(Character[i][character_hunger] < 0) { Character[i][character_hunger] = 0; }
			if(Character[i][character_thirst] < 0) { Character[i][character_thirst] = 0; }
			if(Character[i][character_hunger] < 50) {

				if(Character[i][character_hunger] < 25) { 
					
					FadeIn ( i ) ;
					SendClientMessage(i, -1, " ");
					SendServerMessage ( i, "You're starting to get REALLY hungry! You should eat soon!", MSG_TYPE_WARN);
					SendClientMessage(i, -1, " ");
					SetCharacterHealth(i,Character[i][character_health]-3.0); 
				}
				else { SetCharacterHealth(i,Character[i][character_health]-1.0); }
			}
			if(Character[i][character_thirst] < 50) {

				if(Character[i][character_thirst] < 25) { 

					FadeIn ( i ) ;
					SendClientMessage(i, -1, " ");
					SendServerMessage ( i, "You're starting to get REALLY thirsty! You should drink soon!", MSG_TYPE_WARN);
					SendClientMessage(i, -1, " ");
					SetCharacterHealth(i,Character[i][character_health]-3.0); 
				}
				else { SetCharacterHealth(i,Character[i][character_health]-1.0); }
			}
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_hunger = %d,character_thirst = %d WHERE character_id = %d",Character[i][character_hunger],Character[i][character_thirst],Character[i][character_id]);
			mysql_tquery(mysql,query);
			UpdateGUI(i);
		}
		else continue;
	}
	return true;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

ConnectCamera ( playerid ) {
	TogglePlayerSpectating ( playerid, true ) ;

	StartIntro ( playerid ) ;

	return true;
}

IsRPName(const name[]) {
    new underscores = 0, max_underscores = 1;
    if (name[0] < 'A' || name[0] > 'Z') return false;
    if ( strlen ( name ) < 5 ) return false ;
    if ( strlen ( name ) > MAX_PLAYER_NAME ) return false ;

    for(new i = 1; i < strlen(name); i++) {

        if(name[i] != '_' && (name[i] < 'A' || name[i] > 'Z') && (name[i] < 'a' || name[i] > 'z')) return false;
        if( (name[i] >= 'A' && name[i] <= 'Z') && (name[i - 1] != '_') ) return false;

        if(name[i] == '_') {
            underscores++;
            if(underscores > max_underscores || i == strlen(name)) return false;
            if(name[i + 1] < 'A' || name[i + 1] > 'Z') return false;
        }
    }

    if (underscores == 0) return false;

    return true;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


HideCharacterTextDraws ( playerid ) {

	for ( new i; i < MAX_CHARACTER_BOX; i ++ ) {
		TextDrawHideForPlayer(playerid, CharacterSel_HeaderBox ) ;
		TextDrawHideForPlayer(playerid, CharacterSel_HeaderText ) ;

		TextDrawHideForPlayer(playerid, CharacterSel_BoxDraw 		[ i ] ) ;
		TextDrawHideForPlayer(playerid, CharacterSel_BoxOutline 	[ i ] ) ;

		TextDrawHideForPlayer(playerid, CharacterSel_Box 			[ i ] ) ;
		TextDrawHideForPlayer(playerid, CharacterSelButton_Text 	[ i ] ) ;

		PlayerTextDrawHide(playerid, CharacterSel_Name 		[ i ] ) ;
		PlayerTextDrawHide(playerid, CharacterSel_SkinBox 	[ i ] ) ;

		HidePlayerProgressBar ( playerid, CharacterExpBar 	[ i ]  ) ;

		PlayerTextDrawHide(playerid, CharacterSel_HoursText [ i ]  ) ;
		PlayerTextDrawHide(playerid, CharacterSel_PosseText [ i ]  ) ;
		PlayerTextDrawHide(playerid, CharacterSel_ExpText 	[ i ]  ) ;
		PlayerTextDrawHide(playerid, CharacterSel_ExpInfo 	[ i ]  ) ;

		///////

		TextDrawHideForPlayer(playerid, CharacterEmpty_Header[ i ] ) ;
		TextDrawHideForPlayer(playerid, CharacterEmpty_Button[ i ] ) ;
		TextDrawHideForPlayer(playerid, CharacterEmpty_Text[ i ] ) ;
	}

	return true ;
}