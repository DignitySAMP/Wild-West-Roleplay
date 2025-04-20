#define MAX_PASSWORD_LENGTH		(65)
#define MAX_PASSSALT_LENGTH		(15)

enum PlayerData {

	account_id,
	account_name [ MAX_PLAYER_NAME ] ,

	account_pass [ MAX_PASSWORD_LENGTH ],
	account_salt [ MAX_PASSSALT_LENGTH ],

	account_registerquiz,
	account_tutorial,
	account_rulecheck,

	account_donatorlevel,
	account_donatorexpire,

	account_stafflevel,
	account_staffgroup,
	account_staffname [ MAX_PLAYER_NAME ],
	account_supportquestions,

	account_namechanges,

	account_creation [ 36 ],
	account_lastlogin,

	account_anote[128]
} ;

new Account [ MAX_PLAYERS ] [ PlayerData ] ;
new bool: IsPlayerLogged [ MAX_PLAYERS ] ; 
new login_state [ MAX_PLAYERS ] ; // 0 = normal, 1 = wrong password
new login_state_ext [ MAX_PLAYERS ] ; // additionals for passing states

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

new HasPlayerSeenLoginDialog [ MAX_PLAYERS ] ;

timer DelayAccountCheck[1000](playerid) {

////	print("DelayAccountCheck timer called (account.pwn)");

	if ( ! HasPlayerSeenLoginDialog [ playerid ] ) {

		new query [ 256 ];

		mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM master_accounts WHERE account_name = '%e'", ReturnUserName ( playerid, true ) ) ;
		mysql_tquery ( mysql, query, "Account_Check", "i", playerid ) ;

		defer DelayAccountCheck[5000](playerid);
	}

	return true ;
}

new bool: PlayerTimeoutTick [ MAX_PLAYERS ] ;

timer PlayerTimeOut[60000](playerid) {

////	print("PlayerTimeOut timer called (account.pwn)");

	if ( PlayerTimeoutTick [ playerid ] ) {
		PlayerTimeoutTick [ playerid ] = false ;

		if ( ! IsPlayerSpawned ( playerid ) && IsPlayerConnected ( playerid ) && ! IsPlayerLogged [ playerid ] ) {

			SendClientMessageToAll(COLOR_STAFF, sprintf("[TIMEOUT] %s (%d) has been kicked for failing to spawn within 60 seconds.", ReturnUserName ( playerid, true ), playerid ) ) ;
			KickPlayer ( playerid ) ;
		}

		else return false ;
	}

	return true ;
}

timer DelayIntroDialog[1000](playerid) {
	
////	print("DelayIntroDialog timer called (account.pwn)");

	new query [ 1024 ];

	InterpolateCameraPos ( playerid, -668.1268, 1392.3640, 76.4830, -1124.4877, 1365.9409, 74.9300, 60000, CAMERA_MOVE ) ;
	InterpolateCameraLookAt ( playerid, -668.5658, 1393.2677, 76.2180, -1123.9965, 1366.8170, 74.6600, 60000, CAMERA_MOVE ) ;

	SendClientMessage(playerid, 0xDEDEDEFF, "If for some reason the dialog doesn't show up or dissapears, use {007FFF}/relog{DEDEDE} to re-enable it.") ;

	inline ConnectionPrompt(pid, dialogid, response, listitem, string:inputtext[]) {
	    #pragma unused pid, response, dialogid, listitem, inputtext

        PlayerPlaySound ( playerid, 1085, 0.0, 0.0, 0.0 ) ;

        query [ 0 ] = EOS ;

		mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM master_accounts WHERE account_name = '%e'", ReturnUserName ( playerid, true ) ) ;
		mysql_tquery ( mysql, query, "Account_Check", "i", playerid ) ;

        //defer DelayAccountCheck[1500](playerid);
		return true ;
	}

	format ( query, sizeof ( query ), "{DEDEDE}Welcome!\n\n\
		\
		This server is a roleplaying server, however you're not obiliged to use a roleplaying name when connecting to the server.\n\n\
		\
		After registering your main account, you'll be able to create a character which requires a roleplaying name. You are able\n\
		to create up to three characters and are allowed to have one master account.\n\n\
		\
		Don't worry though, as you'll be able to configure any of your accounts easily without any fuss. That being said, you'll have\n\
		to do a little quiz before you're able to register and after passing them you'll be able to create an account.\n\n\
		\
		If any of the textdraws do not work, try {E87654}/logout{DEDEDE}. If this does not work after a second try, use {E87654}/createcharacter{DEDEDE} to register and\n\
		{E87654}/selectcharacter{DEDEDE} to spawn your character.\n\n\
		\
		Thanks and have fun!");

	return Dialog_ShowCallback ( playerid, using inline ConnectionPrompt, DIALOG_STYLE_MSGBOX, "Welcome!", query, "Continue", "" );

}

Account_ConnectionCheck ( playerid ) {

	//defer DelayIntroDialog(playerid);

    new query [ 256 ] ; 

	mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM master_accounts WHERE account_name = '%e'", ReturnUserName ( playerid, true ) ) ;
	mysql_tquery ( mysql, query, "Account_Check", "i", playerid ) ;

	PlayerTimeoutTick [ playerid ] = true ;
	//defer PlayerTimeOut(playerid);
}

ReturnPasswordSalt ( ) {
	new salt [ MAX_PASSSALT_LENGTH ] ; 

	for ( new i, j = sizeof ( salt ); i < j; i ++ ) {
		salt [ i ] = random ( 79 ) + 47 ;
	}

	return salt ;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

forward Account_Check ( playerid ) ;
public Account_Check ( playerid ) {

	ConnectCamera ( playerid ) ;

	new rows, fields ;
	cache_get_data ( rows, fields, mysql ) ;

	if ( rows ) {

		Account [ playerid ] [ account_id ] 			= cache_get_field_int ( 0, "account_id" ) ;

		cache_get_field_content ( 0, "account_name", Account [ playerid ] [ account_name ], mysql, MAX_PLAYER_NAME ) ;

		cache_get_field_content ( 0, "account_pass", Account [ playerid ] [ account_pass ], mysql, MAX_PASSWORD_LENGTH ) ;
		cache_get_field_content ( 0, "account_salt", Account [ playerid ] [ account_salt ], mysql, MAX_PASSSALT_LENGTH ) ;


		Account [ playerid ] [ account_registerquiz ] 	= cache_get_field_int ( 0, "account_registerquiz" ) ;
		Account [ playerid ] [ account_tutorial ] 	= cache_get_field_int ( 0, "account_tutorial" ) ;
		Account [ playerid ] [ account_rulecheck ] = cache_get_field_int ( 0, "account_rulecheck" ) ;

		Account [ playerid ] [ account_donatorlevel ] 	= cache_get_field_int ( 0, "account_donatorlevel" ) ;
		Account [ playerid ] [ account_donatorexpire ]  = cache_get_field_int ( 0, "account_donatorexpire" ) ;

		Account [ playerid ] [ account_namechanges ] 	= cache_get_field_int ( 0, "account_namechanges" ) ;

		Account [ playerid ] [ account_stafflevel ] 	= cache_get_field_int ( 0, "account_stafflevel" ) ;
		Account [ playerid ] [ account_staffgroup ] 	= cache_get_field_int ( 0, "account_staffgroup" ) ;
		Account [ playerid ] [ account_supportquestions ] 	= cache_get_field_int ( 0, "account_supportquestions" ) ;
		
		cache_get_field_content ( 0, "account_anote", Account [ playerid ] [ account_anote ], mysql, 256 ) ;
		
		cache_get_field_content ( 0, "account_staffname", Account [ playerid ] [ account_staffname ], mysql, MAX_PLAYER_NAME ) ;

		cache_get_field_content ( 0, "account_creation", Account [ playerid ] [ account_creation ], mysql, 36 ) ;
		Account [ playerid ] [ account_lastlogin] = cache_get_field_int ( 0, "account_lastlogin" ) ;

		return Account_Authenticate ( playerid ) ;
	}

	else if ( ! rows ) {
		return Account_Register ( playerid ) ;
	}

	return true ;
}

Account_Register ( playerid ) {

 	inline RegisterPrompt(pid, dialogid, response, listitem, string:inputtext[]) {
	    #pragma unused pid, dialogid, listitem

		if ( ! response ) {

	    	return KickPlayer ( playerid ) ;
		}

		if ( response ) {

            PlayerPlaySound ( playerid, 1085, 0.0, 0.0, 0.0 ) ;

			if ( strlen ( inputtext ) > MAX_PASSWORD_LENGTH ) {

				IsPlayerLogged [ playerid ] = false ;
				defer ReInit_AuthPanel[1000](playerid);

				return SendServerMessage ( playerid, "Your password can't have more than 65 characters.", MSG_TYPE_ERROR ) ;
			} 

			if ( strlen ( inputtext ) < 4 ) {
				IsPlayerLogged [ playerid ] = false ;
				defer ReInit_AuthPanel[1000](playerid);

				return SendServerMessage ( playerid, "Your password can't have less than 4 characters.", MSG_TYPE_ERROR ) ;				
			}

			new query [ 256 ], password [ MAX_PASSWORD_LENGTH ], passSalt [ MAX_PASSSALT_LENGTH ] ;

			format ( passSalt, sizeof ( passSalt ), "%s", ReturnPasswordSalt () ); 
			SHA256_PassHash(inputtext, passSalt, password, sizeof ( password ) ) ;

			mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO master_accounts (account_name, account_pass, account_salt, account_creation) VALUES ('%e', '%e', '%e', '%e')", 
			ReturnUserName ( playerid, true ), password, passSalt, ReturnDateTime ( ) ) ; 

			//OldLog ( playerid, "acc/register", sprintf("(%d) %s has just registered an account.", playerid, ReturnUserName ( playerid, true )) ) ;
			//SendModeratorWarning ( sprintf("[ACCOUNT] (%d) %s has just registered their account.", playerid, ReturnUserName ( playerid, true )), MOD_WARNING_LOW ) ;

			mysql_tquery ( mysql, query ) ;

			IsPlayerLogged [ playerid ] = false ;
			defer ReInit_AuthPanel[1000](playerid);
		}
	}
	
	new registerstring [ 256 ] ;

	format ( registerstring, sizeof ( registerstring ), 

		"{DEDEDE}Welcome to {6B5538}Wild West Roleplay{DEDEDE}!\n\
		\n\
		The name {6B5538}%s{DEDEDE} is currently not registered.\n\
		\n\
		Please enter your desired password below.", 

	ReturnUserName ( playerid, true )) ;

	Dialog_ShowCallback ( playerid, using inline RegisterPrompt, DIALOG_STYLE_PASSWORD, "{6B5538}Welcome to Wild West Roleplay{DEDEDE}", registerstring, "Register", "Exit" );
	return true ;
}

Account_Authenticate ( playerid ) {

	if ( login_state_ext [ playerid ] >= 3 ) {

		KickPlayer ( playerid ) ;

		return SendServerMessage ( playerid, "You've been kicked for entering the incorrect password too often.", MSG_TYPE_ERROR ) ;
	}

 	inline LoginPrompt(pid, dialogid, response, listitem, string:inputtext[]) {
	    #pragma unused pid, dialogid, listitem

 		HasPlayerSeenLoginDialog [ playerid ] = true ;

		if ( ! response ) {

	    	return KickPlayer ( playerid ) ;
		}

		if ( response ) {

            PlayerPlaySound ( playerid, 1085, 0.0, 0.0, 0.0 ) ;

			if ( strlen ( inputtext ) > MAX_PASSWORD_LENGTH ) {

				IsPlayerLogged [ playerid ] = false ;
				defer ReInit_AuthPanel[1000](playerid);

				login_state [ playerid ] = true ;
				login_state_ext [ playerid ] ++ ;

				return SendServerMessage ( playerid, "Your password can't have more than 65 characters.", MSG_TYPE_ERROR ) ;
			} 

			if ( strlen ( inputtext ) < 4 ) {
				IsPlayerLogged [ playerid ] = false ;
				defer ReInit_AuthPanel[1000](playerid);

				login_state [ playerid ] = true ;
				login_state_ext [ playerid ] ++ ;

				return SendServerMessage ( playerid, "Your password can't have less than 4 characters.", MSG_TYPE_ERROR ) ;			
			}

			new password [ MAX_PASSWORD_LENGTH ], query [ 128 ] ;

			SHA256_PassHash ( inputtext, Account [ playerid ] [ account_salt ], password, sizeof ( password ) ) ;

			if ( ! strcmp ( password, Account [ playerid ] [ account_pass ] ) ) {

				IsPlayerLogged [ playerid ] = true ;

				mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_lastlogin = '%d' WHERE account_id = '%d'",  gettime(), Account [ playerid ] [ account_id ] ) ; 
				mysql_tquery ( mysql, query ) ;

				//SendModeratorWarning ( sprintf("[ACCOUNT] (%d) %s has just logged into their account.", playerid, ReturnUserName ( playerid, true )), MOD_WARNING_LOW ) ;
				//OldLog ( playerid, "acc/login", sprintf("(%d) %s has just logged into their account.", playerid, ReturnUserName ( playerid, true )) ) ;

				if ( ! Account [ playerid ] [ account_registerquiz ] ) return StartRPQuiz ( playerid ) ;

				login_state [ playerid ] = false ;
				login_state_ext [ playerid ] = 0;

				if ( Account [ playerid ] [ account_donatorlevel ] ) {

					if ( Account [ playerid ] [ account_donatorexpire ] < gettime() ) {

						Account [ playerid ] [ account_donatorlevel ] = 0 ;
						Account [ playerid ] [ account_donatorexpire ] = 0 ;

						mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_donatorlevel = 0, account_donatorexpire = 0 WHERE account_id = %d", Account [ playerid ] [ account_id ] ) ;
						mysql_tquery ( mysql, query ) ;

						SendServerMessage ( playerid, "Your donator level has expired.", MSG_TYPE_WARN ) ;
					}
				}

				return Account_CharacterCheck ( playerid ) ;
				//return BanChecker ( playerid ) ;
			}

			if ( strcmp ( password, Account [ playerid ] [ account_pass ] ) ) {

				IsPlayerLogged [ playerid ] = false ;
				defer ReInit_AuthPanel[1000](playerid);

				login_state [ playerid ] = true ;
				login_state_ext [ playerid ] ++ ;

				return true ;
			}
		}
	}
	
	new loginstring [ 512 ] ;

	switch ( login_state [ playerid ] ) {

		case false: {
			format ( loginstring, sizeof ( loginstring ), 

				"{DEDEDE}Welcome to {6B5538}Wild West Roleplay{DEDEDE}!\n\
				\n\
				Account Name: \t {6B5538}%s{DEDEDE}\n\
				\n\
				Please enter your password below.", 

			ReturnUserName ( playerid, true ) ) ;
		}

		case true: {
			format ( loginstring, sizeof ( loginstring ), 

				"{DEDEDE}Welcome to {6B5538}Wild West Roleplay{DEDEDE}!\n\
				\n\
				Account Name: \t {6B5538}%s{DEDEDE}\n\
				\n\
				Please enter your password below.\n\
				\n\
				Incorrect password! Login attempts: {6B5538}%d/3{DEDEDE}\n", 

			ReturnUserName ( playerid, true ), login_state_ext [ playerid ] ) ;
		}
	}

	Dialog_ShowCallback ( playerid, using inline LoginPrompt, DIALOG_STYLE_PASSWORD, "{6B5538}Welcome to Wild West Roleplay{DEDEDE}", loginstring, "Login", "Exit" );
	
	return true ;
}

timer ReInit_AuthPanel[1000](playerid) {

////	print("ReInit_AuthPanel timer called (account.pwn)");

	new query [ 128 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM master_accounts WHERE account_name = '%e'", ReturnUserName ( playerid, true ) ) ;
	mysql_tquery ( mysql, query, "Account_Check", "i", playerid ) ;

	return true ;
}