#define MAX_CHARACTERS		(3)

enum CharacterData {
	account_id,
	character_id,

	character_ajailed,

	character_level,
	character_hours,
	character_expleft,
	character_skillpoints,

	character_name [ MAX_PLAYER_NAME],
	character_spawnpoint,
	character_spawnmotel,
	character_backpack,

	character_gender,
	character_origin,

	character_skin,
	character_town,
	character_age,

	character_mask,
	character_accent [32],

	///////////////

	character_chatstyle,
	character_dmgmode,

	character_posse,
	character_possetier,
	character_posserank [ 36 ],

	///////////////

	character_horseid,
	Float: character_horsehealth,

	character_hunger,
	character_thirst,
	Float: character_health,

	///////////////

	character_handweapon,
	character_handammo,

	character_pantsweapon,
	character_pantsammo,

	character_backweapon,
	character_backammo,

	character_ammopack_pistol,
	character_ammopack_shotgun,
	character_ammopack_rifle,

	///////////////

	character_handmoney,
	character_handchange,
	character_bankmoney,
	character_bankchange,
	character_paycheck,
	character_paychange,

	///////////////

	character_attributes [ 144 ],

	///////////////

	character_prison,
	Float: character_prison_pos_x,
	Float: character_prison_pos_y,
	Float: character_prison_pos_z,
	character_prison_interior,
	character_prison_vw,
	character_prison_bail,
	character_prison_bail_cents,

	///////////////

	character_bounty_id,
	character_telegram_id,

	///////////////

	character_jobactionsleft,

	character_woodactionsleft,
	character_fishactionsleft,
	character_mineactionsleft,

	character_woodcd,
	character_fishcd,
	character_minecd,

	////////////////

 	Float: character_mask_offsetx,
	Float: character_mask_offsety,
	Float: character_mask_offsetz,

	Float: character_mask_rotx,
	Float: character_mask_roty,
	Float: character_mask_rotz,

	Float: character_mask_scalex,
	Float: character_mask_scaley,
	Float: character_mask_scalez,

	////////////////

 	Float: character_trousergun_offsetx,
	Float: character_trousergun_offsety,
	Float: character_trousergun_offsetz,

	Float: character_trousergun_rotx,
	Float: character_trousergun_roty,
	Float: character_trousergun_rotz,

	Float: character_trousergun_scalex,
	Float: character_trousergun_scaley,
	Float: character_trousergun_scalez,

	////////////////

 	Float: character_backgun_offsetx,
	Float: character_backgun_offsety,
	Float: character_backgun_offsetz,

	Float: character_backgun_rotx,
	Float: character_backgun_roty,
	Float: character_backgun_rotz,

	Float: character_backgun_scalex,
	Float: character_backgun_scaley,
	Float: character_backgun_scalez,

	////////////////

	Float: character_pos_x,
	Float: character_pos_y,
	Float: character_pos_z,
	character_pos_interior,
	character_pos_vw,

	////////////////

	character_temperature,
	character_temperature_decimal,

	////////////////

	character_crashed
};

// Use char_Selected when accessing MAX_CHARACTERS
new Character [ MAX_PLAYERS ] [ CharacterData ] ;

new CharBuffer [ MAX_PLAYERS ] [ MAX_CHARACTERS ] [ CharacterData ] ; 

new bool: Login_SelectionPage [ MAX_PLAYERS ] ; 
new LogoutPermission [ MAX_PLAYERS ] ;
new NewlyRegistered [ MAX_PLAYERS ] ;

new bool: IsPlayerInAdminJail [ MAX_PLAYERS ] ; 
new PassedSelectionScreen [ MAX_PLAYERS ] ;

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

// move the following into the character array some time.. dont fuck up
// Dignity was lazy so he made normal vars
new PlayerSaddleBagWeapon [ MAX_PLAYERS ] [ 2 ];
new PlayerSaddleBagAmmo [ MAX_PLAYERS ] [ 2 ];

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

new CharSwitchTick [ MAX_PLAYERS ] ;

timer ChangeCharacterTick[1000](playerid, selectedid) {

////	print("ChangeCharacterTick timer called (character.pwn)");

	CharSwitchTick [ playerid ] -- ;
	GameTextForPlayer(playerid, sprintf("~n~~n~~n~~n~~b~Switch time left:~w~ %d", CharSwitchTick [ playerid ] ), 1000, 3);

	if ( CharSwitchTick [ playerid ] > 0 ) {

		defer ChangeCharacterTick(playerid, selectedid);
		return true ;
	}

	else if ( CharSwitchTick [ playerid ] <= 0 ) {

		HideGUITextDraws ( playerid ) ;

		SetCharacterLoggedPosition ( playerid ) ;

		CharSwitchTick [ playerid ] = 0 ;

    	SetPlayerVirtualWorld(playerid, 0);
    	SetPlayerInterior(playerid, 0);

		SendModeratorWarning ( sprintf("[SWITCH] %s has switched to their character %s.", ReturnUserName ( playerid, false ), CharBuffer [ playerid ] [ selectedid ] [ character_name ]), MOD_WARNING_LOW ) ;
		//OldLog ( playerid, "switchchar", sprintf("%s has switched to their character %s.", ReturnUserName ( playerid, false ), CharBuffer [ playerid ] [ selectedid ] [ character_name ])) ;

        TogglePlayerControllable(playerid, true ) ;
    	Account_LoadCharacterData ( playerid, selectedid) ;

    	return true ;
	}

	return true ;
}

CMD:reloadgui ( playerid, params [] ) {

	HideGUITextDraws ( playerid ) ;
	ShowGUITextDraws ( playerid ) ;

	SendServerMessage ( playerid, "GUI has been reloaded.", MSG_TYPE_INFO ) ;
	return true ;
}

CMD:fixchartds(playerid, params[]){
    return HideCharacterTextDraws ( playerid );
}

CMD:switchcharacter ( playerid, params [] ) {

	if ( ! IsPlayerFree ( playerid ) ) {

		return SendServerMessage ( playerid, "You can't do this right now.", MSG_TYPE_ERROR ) ;
	}

	inline SwitchCharacter(pid, dialogid, response, listitem, string:inputtext[]) {
	    #pragma unused pid, response, dialogid, listitem, inputtext

		if ( ! response ) {

			return false ;
		}

        PlayerPlaySound ( playerid, 1085, 0.0, 0.0, 0.0 ) ;

        if ( CharBuffer [ playerid ] [ listitem ] [ character_id ] ) {

        	SendServerMessage ( playerid, sprintf("You have selected character slot %d. [DB ID: (%d)] %s. You will switch momentarily.", listitem, CharBuffer [ playerid ] [ listitem ] [ character_id ], CharBuffer [ playerid ] [ listitem ] [ character_name ] ), MSG_TYPE_INFO ) ;
        	SendServerMessage ( playerid, "You're gonna be frozen for fifteen seconds. These will serve as a cooldown and a deterrence to abuse.", MSG_TYPE_WARN) ;

        	CharSwitchTick [ playerid ] = 15 ;
        	defer ChangeCharacterTick( playerid, listitem) ;

        	TogglePlayerControllable(playerid, false ) ;

        	SetName ( playerid, sprintf("[SWITCHING CHARACTERS]{DEDEDE}\n(%d) %s", playerid, ReturnUserName ( playerid, false )), COLOR_BLUE ) ;
			GameTextForPlayer(playerid, sprintf("~n~~n~~n~~n~~b~Switch time left:~w~ %d", CharSwitchTick [ playerid ] ), 1000, 3);

			SendModeratorWarning ( sprintf("[SWITCH] %s is trying to switch to character %s.", ReturnUserName ( playerid, false ), CharBuffer [ playerid ] [ listitem ] [ character_name ]), MOD_WARNING_LOW ) ;
			//OldLog ( playerid, "switchchar", sprintf("%s is trying to switch to character %s.", ReturnUserName ( playerid, false ), CharBuffer [ playerid ] [ listitem ] [ character_name ])) ;

			return true ;
        }

        else SendServerMessage ( playerid, "You don't have a character in this slot.", MSG_TYPE_ERROR ) ;

		return true ;
	}

	new query [ 512 ] = "{DEDEDE}ID \t Name\n" ;

	for ( new i; i < MAX_CHARACTERS; i ++ ) {

		if ( CharBuffer [ playerid ] [ i ] [ character_id ] ) {

			format ( query, sizeof ( query ), "%s(%d)\t%s\n", query,  CharBuffer [ playerid ] [ i ] [ character_id ],  CharBuffer [ playerid ] [ i ] [ character_name ] ) ;
		}

		else if ( ! CharBuffer [ playerid ] [ i ] [ character_id ] ) {

			format ( query, sizeof ( query ), "%s(%d)\tNone\n", query, i ) ;
		}
	}

	Dialog_ShowCallback ( playerid, using inline SwitchCharacter, DIALOG_STYLE_TABLIST_HEADERS, "Character Switch", query, "Continue", "Cancel" );

	return true ;
}

CMD:switchc ( playerid, params [] ) {

	return cmd_switchcharacter ( playerid, params ) ;
}


CMD:selectcharacter ( playerid, params [] ) {

	new selectid ;

	if ( sscanf ( params, "i", selectid ) ) {

		return SendServerMessage ( playerid, "/selectcharacter [slot 1-3]", MSG_TYPE_ERROR ) ;
	}

	if ( selectid > MAX_CHARACTERS ) {

		return SendServerMessage ( playerid, "You can only have three characters.", MSG_TYPE_ERROR ) ;
	}

	if ( ! Login_SelectionPage [ playerid ] ) {
		return SendServerMessage ( playerid, "You're not in the character selection screen. If you are but it says you're not, use /logout to fix it.", MSG_TYPE_ERROR ) ;
	}

	new characters ;

	for ( new i; i < MAX_CHARACTERS; i ++ ) {

		if ( CharBuffer [ playerid ] [ i ] [ character_id ] ) {

			characters ++ ;
		}
	}

	if ( selectid >= characters ) {

		SendServerMessage ( playerid, "There isn't a character in the slot you selected.", MSG_TYPE_ERROR ) ;
		return SendServerMessage ( playerid, "You can use {E87654}/createcharacter{DEDEDE} to create one.", MSG_TYPE_ERROR ) ;
	}

	SpawnPlayer_Character ( playerid ) ;

	return true ;
}

CreateCharacter ( playerid, master_account, char_name [], char_gender, char_origin, char_town, char_skin, char_age ) {

	if ( ! IsPlayerCreatingCharacter [ playerid ] ) {

		return SendClientMessage(playerid, -1, "Something went wrong. Please relog and /report for assistance (invalid CreateCharacter variable)." ) ;
	}

	IsPlayerCreatingCharacter [ playerid ] = false ;
	HideCreationTextDraws ( playerid ) ;

	if ( ! player_SkinSelection [ playerid ] ) {

		SendClientMessage(playerid, -1, "Something went wrong. Your skin hasn't been found, so we have manually set it for you based on your selections." ) ;
		UpdateCreationSkin ( playerid ) ;
	}

	new query [ 256 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO characters (account_id, character_name, character_gender, character_origin, character_town, character_skin, character_age, character_horseid) VALUES (%d, '%e', %d, %d, %d, %d, %d, '-1')", 
		master_account, char_name, char_gender, char_origin, char_town, char_skin, char_age ) ;
	mysql_tquery ( mysql, query ) ;

	NewlyRegistered [ playerid ] = true ;

	inline GiveReward() {

		new rows,fields;
		cache_get_data(rows,fields,mysql);

		if(rows) {

			new charid;
			charid = cache_get_field_content_int(0,"character_id",mysql);
			GiveRegisterReward ( playerid, charid ) ;
		}		
	}
	mysql_format(mysql,query,sizeof(query),"SELECT character_id FROM characters WHERE character_name = '%e' LIMIT 1",char_name);
	mysql_tquery_inline(mysql,query,using inline GiveReward,"");

	query [ 0 ] = EOS ;

	HideCreationTextDraws ( playerid ) ;
	HideCharacterTextDraws ( playerid ) ;

	Account_CharacterCheck ( playerid ) ;

	SendModeratorWarning ( sprintf("[CREATE] (%d) %s (%d: %s) has registered a new character.", playerid, char_name, master_account, Account [ playerid ] [ account_name] ), MOD_WARNING_LOW ) ;
	//OldLog ( playerid, "char/create", sprintf("(%d) %s (%d: %s) has registered a new character.", playerid, char_name, master_account, Account [ playerid ] [ account_name] )) ;

	return true ;
}

SpawnPlayer_Character ( playerid ) {

	LogoutPermission [ playerid ] = false ;
	HideGUITextDraws ( playerid ) ;

 	StopAudioStreamForPlayer ( playerid ) ;
	TogglePlayerSpectating ( playerid, false ) ;

	SetPlayerName(playerid, Character [ playerid ]  [ character_name ] ) ;
	SetPlayerColor(playerid, 0xCFCFCFFF ) ;

	Login_SelectionPage [ playerid ] = false ;
	PassedSelectionScreen [ playerid ] = true ;

	SetSpawnInfo ( playerid, -1, Character [ playerid ]  [ character_skin ], SERVER_SPAWN_X, SERVER_SPAWN_Y, SERVER_SPAWN_Z, 90.0, -1, -1, -1, -1, -1, -1 ) ;
	SpawnPlayer ( playerid ) ;

	HideCharacterTextDraws ( playerid ) ;
	HideCreationTextDraws ( playerid ) ;

	CancelSelectTextDraw ( playerid ) ;

	SetPlayerScore ( playerid, Character [ playerid ]  [ character_level ]) ;

//	SendModeratorWarning ( sprintf("[SPAWN] (%d) %s has just spawned.", playerid, ReturnUserName ( playerid, true ) ), MOD_WARNING_LOW ) ;
	//OldLog ( playerid, "char/spawn", sprintf("(%d) %s (%d: %s) has just spawned.", playerid, Character [ playerid ] [ character_name ], Account [ playerid ] [ account_id ], Account [ playerid ] [ account_name] )) ;

    BanEvaderCheck ( playerid ) ;

    if ( Character [ playerid ] [ character_dmgmode ] != 0 ) {

    	Character [ playerid ] [ character_dmgmode ] = 2 ;

    	defer DeadCooldown(playerid);
    }

	if ( IsPlayerModerator ( playerid ) ) {

		// The mod warnings are set to true in main.pwn OnPlayerSpawn
		SendServerMessage ( playerid, "Moderator warnings have been automatically enabled. Use /togmodwarnings to disable it.", MSG_TYPE_WARN ) ;
	}

	SendServerMessage ( playerid, "Your animations will be preloaded shortly. This may mean that you experience a small lag spike.", MSG_TYPE_ERROR ) ;
	defer LoadAnimations(playerid) ;

	ResetPlayerWounds ( playerid ) ;

	if ( GetBountyIDByName ( playerid ) != -1 ) {

		LoadWantedPosterPlayerID ( GetBountyIDByName ( playerid ) ) ;
	}

	SendClientMessage(playerid, -1, " " ) ;

	defer LoadDelayedData(playerid );
	defer Paycheck(playerid);

	return true ;
}

CMD:resyncattachments(playerid, params[]) {

	return Init_LoadPlayerAttachments ( playerid );
}

timer LoadDelayedData[1000](playerid) {

////	print("LoadDelayedData timer called (character.pwn)");

	SetupPlayerGunAttachments ( playerid ) ;

	// Money
	GivePlayerMoney ( playerid, Character [ playerid ] [ character_handmoney ] ) ;

	// GUI
	HideCharacterTextDraws ( playerid ) ;
	HideCreationTextDraws ( playerid ) ;
	
	ShowGUITextDraws ( playerid ) ;
	UpdateWeaponGUI ( playerid ) ;
	UpdateGUI ( playerid ) ;

	// Inventory
	Init_LoadPlayerItems ( playerid ) ;
	Init_LoadPlayerAttachments ( playerid ) ;

	if ( IsLawEnforcementPosse ( Character [ playerid ] [ character_posse ] ) ) {

		if ( ReturnItemByParam ( playerid, RADIO, true ) != -1 ) {

			DiscardItem ( playerid, ReturnItemByParam ( playerid, RADIO, true ) ) ;
		}

		if ( ReturnItemByParam ( playerid, SHERIFF_HANDCUFFS, true ) != -1 ) {

			DiscardItem ( playerid, ReturnItemByParam ( playerid, SHERIFF_HANDCUFFS, true ) ) ;
		}

		if ( ReturnItemByParam ( playerid, SHERIFF_BADGE, true ) != -1 ) {

			DiscardItem ( playerid, ReturnItemByParam ( playerid, SHERIFF_BADGE, true )) ;
		}

		if ( ReturnItemByParam ( playerid, FEDERAL_BADGE, true ) != -1 ) {

			DiscardItem ( playerid, ReturnItemByParam ( playerid, FEDERAL_BADGE, true )) ;
		}
	}

	//Crimes, if any
	Init_LoadCharges ( playerid ) ;

	//Telegram
	Init_LoadTelegrams ( playerid ) ;

	SetName ( playerid, sprintf("(%d) %s", playerid, ReturnUserName ( playerid, false )), 0xCFCFCFFF ) ;
	ShowPlayerMOTD ( playerid ) ;

	LoadPlayerSkills ( playerid ) ;

	// HandleTutorial ( playerid ) ;

	if ( ! Character [ playerid ] [ character_prison ] ) {

		switch ( random ( 4 ) ) {
			case 0: SendClientMessage(playerid, COLOR_DEFAULT, "** You've woken up from a brief nap and feel somewhat refreshed.." ) ;
			case 1: SendClientMessage(playerid, COLOR_DEFAULT, "** You've woken up with your head pounding and the smell of alcohol emitting from your clothes.." ) ;
			case 2: SendClientMessage(playerid, COLOR_DEFAULT, "** You've woken up after a fight. Your face hurts and your knuckles seem to be bloodied.." ) ;
			case 3: {

				if ( Character [ playerid ] [ character_horseid ] != -1 ) {

					SendClientMessage(playerid, COLOR_DEFAULT, "** You've woken up on the ground. It seems your horse has ran off, it shouldn't be too far away.." ) ;
				}

				else SendClientMessage(playerid, COLOR_DEFAULT, "** You've woken up due to a horse hinnicking loudly. You push yourself off the floor..") ;
			}
		}
	}

	SendServerMessage(playerid, "If your character selection/creation textdraws haven't gone away, please use /fixchartds", MSG_TYPE_INFO);

	if(Character [ playerid ] [ character_age ] == 0) {

		inline CharacterAgeOverride(pid, dialogid, response, listitem, string:inputtext[] ) { 
 			#pragma unused pid, dialogid, listitem

			if(!response) {

				return Dialog_ShowCallback(playerid, using inline CharacterAgeOverride, DIALOG_STYLE_INPUT, "Character Age", "The server detected that your age is 0.\n\nIf this isn't correct, take a screenshot of this dialog and send it to a developer.\n\nEnter your character's age below: (8-80)", "Finish") ;
			}

			if(!strlen(inputtext)) {

				return Dialog_ShowCallback(playerid, using inline CharacterAgeOverride, DIALOG_STYLE_INPUT, "Character Age", "No characters were detected.\n\nEnter your character's age below: (8-80)", "Finish") ;
			}

			if(!IsNumeric(inputtext)) {

				return Dialog_ShowCallback(playerid, using inline CharacterAgeOverride, DIALOG_STYLE_INPUT, "Character Age", "That is not a numeric character.\n\nEnter your character's age below: (8-80)", "Finish") ;
			}

			if(strval(inputtext) > 80 || strval(inputtext) < 8) {

				return Dialog_ShowCallback(playerid, using inline CharacterAgeOverride, DIALOG_STYLE_INPUT, "Character Age", "You character cannot be younger than 8 or older than 80.\n\nEnter your character's age below: (8-80)", "Finish") ;
			}

			new query[128];

			Character[playerid][character_age] = strval(inputtext);

			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_age = %d WHERE character_id = %d",Character[playerid][character_age],Character[playerid][character_id]);
			mysql_tquery(mysql,query);

			SendServerMessage(playerid,sprintf("You've set your character's age to %d.",Character[playerid][character_age]),MSG_TYPE_INFO);
 		}

 		Dialog_ShowCallback(playerid, using inline CharacterAgeOverride, DIALOG_STYLE_INPUT, "Character Age", "The server detected that your age is zero.\n\nIf this isn't correct, take a screenshot of this dialog and send it to a developer.\n\nEnter your character's age below: (8-80)", "Finish") ;
	}

	defer SpawnPlayerDeter(playerid);

 	return true ;
}

timer SpawnPlayerDeter[1000](playerid) {

//	BlackScreen ( playerid ) ;
//	FadeIn ( playerid ) ;

	SelectSpawn ( playerid ) ;

	for(new i=0; i<5; i++) {

		HideCharacterTextDraws(playerid);
	}
	return true ;
}

timer NameTagProofCheck[5000](playerid) {

	new namelabel [ MAX_PLAYER_NAME ] ;
 	GetDynamic3DTextLabelText ( nametag[playerid], namelabel ) ;

 	if ( Account [ playerid ] [ account_tutorial ] < ReturnTaskListSize ( ) + 1 ) {
		
		SendClientMessage(playerid, -1, " " ) ;
		SendClientMessage(playerid, 0xDEDEDEFF, "It seems you haven't finished your tutorial tasks yet. If you are new to the server and want to learn the basics" ) ;
		SendClientMessage(playerid, 0xDEDEDEFF, "it is adviced to use {D4AE72}/tasks{DEDEDE} to see your progress. You also get a reward for completing them." ) ;
		SendClientMessage(playerid, -1, " " ) ;

	}

	if ( ! IsRPName ( ReturnUserName ( playerid ) ) ) {

		KickPlayer ( playerid );
		SendServerMessage ( playerid, "There was an error processing your name. Please try relogging or create a new character.", MSG_TYPE_WARN);
		return SendServerMessage ( playerid, "You might want to contact the management team on the forums if you wish to retrieve it.", MSG_TYPE_WARN );
	}

	return true ;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Account_CharacterCheck ( playerid ) {

	new query [ 128 ] ; 

	mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM characters WHERE account_id = '%d'", Account [ playerid ] [ account_id ] ) ;
	mysql_tquery ( mysql, query, "Account_RetrieveCharacters", "i", playerid ) ;

	return true ;
} 

forward Account_RetrieveCharacters ( playerid ) ;
public Account_RetrieveCharacters ( playerid ) {

	new rows, fields ;
	cache_get_data ( rows, fields, mysql ) ;

	if ( rows ) {

		for ( new i; i < rows; i ++ ) {

			CharBuffer [ playerid ] [ i ] [ account_id ] 			= cache_get_field_content_int(i, "account_id", mysql ) ;
			CharBuffer [ playerid ] [ i ] [ character_id ] 			= cache_get_field_content_int(i, "character_id", mysql ) ;

			cache_get_field_content ( i, "character_name", CharBuffer [ playerid ] [ i ]  [ character_name ], mysql, MAX_PLAYER_NAME ) ;

			CharBuffer [ playerid ] [ i ] [ character_skin ] 		= cache_get_field_content_int(i, "character_skin", mysql ) ;
			CharBuffer [ playerid ] [ i ] [ character_gender ] 		= cache_get_field_content_int(i, "character_gender", mysql ) ;

			CharBuffer [ playerid ] [ i ] [ character_origin ] 		= cache_get_field_content_int(i, "character_origin", mysql ) ;
			CharBuffer [ playerid ] [ i ] [ character_town ] 		= cache_get_field_content_int(i, "character_town", mysql ) ;

			CharBuffer [ playerid ] [ i ] [ character_hours ] 		= cache_get_field_content_int(i, "character_hours", mysql ) ;
			CharBuffer [ playerid ] [ i ] [ character_level ] 		= cache_get_field_content_int(i, "character_level", mysql ) ;
			CharBuffer [ playerid ] [ i ] [ character_expleft ] 	= cache_get_field_content_int(i, "character_expleft", mysql ) ;
		}
	}

	SendClientMessage(playerid, 0xDEDEDEFF, "Please wait a moment while we load the character textdraws, they should appear shortly.") ;
	SendClientMessage(playerid, 0xDEDEDEFF, " ") ;

	BanChecker ( playerid ) ;
	defer Delayed_TextdrawLoad(playerid) ;
}

Account_LoadCharacterData ( playerid, selected ) {

	new query [ 128 ] ; 

	mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM characters WHERE character_id = %d", CharBuffer [ playerid ] [ selected ] [ character_id ] ) ;
	mysql_tquery ( mysql, query, "Account_LoadCharacters", "i", playerid ) ;

	return true ;
} 

forward Account_LoadCharacters ( playerid ) ;
public Account_LoadCharacters ( playerid ) {

	new rows, fields ;
	cache_get_data ( rows, fields, mysql ) ;

	if ( rows ) {

		for ( new i; i < rows; i ++ ) {

			Character [ playerid ] [ account_id ] 						= cache_get_field_content_int(i, "account_id", mysql ) ;
			Character [ playerid ] [ character_id ] 					= cache_get_field_content_int(i, "character_id", mysql ) ;
			Character [ playerid ] [ character_spawnpoint ] 			= cache_get_field_content_int(i, "character_spawnpoint", mysql ) ;
			Character [ playerid ] [ character_spawnmotel ] 			= cache_get_field_content_int(i, "character_spawnmotel", mysql ) ;

			Character [ playerid ] [ character_backpack ] 				= cache_get_field_content_int(i, "character_backpack", mysql ) ;
			Character [ playerid ] [ character_ajailed ] 				= cache_get_field_content_int(i, "character_ajailed", mysql ) ;

			Character [ playerid ] [ character_hours ] 					= cache_get_field_content_int(i, "character_hours", mysql ) ;
			Character [ playerid ] [ character_level ] 					= cache_get_field_content_int(i, "character_level", mysql ) ;
			Character [ playerid ] [ character_expleft ] 				= cache_get_field_content_int(i, "character_expleft", mysql ) ;
			Character [ playerid ] [ character_skillpoints ] 			= cache_get_field_content_int(i, "character_skillpoints", mysql ) ;

			cache_get_field_content ( i, "character_name", 		Character [ playerid ] [ character_name ], mysql, MAX_PLAYER_NAME ) ;
			cache_get_field_content ( i, "character_accent", 	Character [ playerid ] [ character_accent ], mysql, 32 ) ;

			Character [ playerid ] [ character_skin ] 					= cache_get_field_content_int(i, "character_skin", mysql ) ;
			Character [ playerid ] [ character_gender ] 				= cache_get_field_content_int(i, "character_gender", mysql ) ;

			Character [ playerid ] [ character_origin ] 				= cache_get_field_content_int(i, "character_origin", mysql ) ;
			Character [ playerid ] [ character_town ] 					= cache_get_field_content_int(i, "character_town", mysql ) ;
			Character [ playerid ] [ character_age ] 					= cache_get_field_content_int(i, "character_age", mysql ) ;
			
			Character [ playerid ] [ character_mask ] 					= cache_get_field_content_int(i, "character_mask", mysql ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			Character [ playerid ] [ character_chatstyle ] 				= cache_get_field_content_int(i, "character_chatstyle", mysql ) ;
			Character [ playerid ] [ character_dmgmode ] 				= cache_get_field_content_int(i, "character_dmgmode", mysql ) ;

			Character [ playerid ] [ character_posse ] 					= cache_get_field_content_int(i, "character_posse", mysql ) ;
			Character [ playerid ] [ character_possetier ] 				= cache_get_field_content_int(i, "character_possetier", mysql ) ;

			cache_get_field_content ( i, "character_posserank", Character [ playerid ]  [ character_posserank ], mysql, 36 ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			Character [ playerid ] [ character_horseid ] 				= cache_get_field_content_int(i, "character_horseid", mysql ) ;
			Character [ playerid ] [ character_horsehealth ] 			= cache_get_field_content_float(i, "character_horsehealth", mysql ) ;

			Character [ playerid ] [ character_hunger ] 				= cache_get_field_content_int(i, "character_hunger", mysql ) ;
			Character [ playerid ] [ character_thirst ] 				= cache_get_field_content_int(i, "character_thirst", mysql ) ;
			Character [ playerid ] [ character_health ] 				= cache_get_field_content_float(i, "character_health", mysql ) ;


			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			Character [ playerid ] [ character_handweapon ] 			= cache_get_field_content_int(i, "character_handweapon", mysql ) ;
			Character [ playerid ] [ character_handammo ] 				= cache_get_field_content_int(i, "character_handammo", mysql ) ;

			Character [ playerid ] [ character_pantsweapon ] 			= cache_get_field_content_int(i, "character_pantsweapon", mysql ) ;
			Character [ playerid ] [ character_pantsammo ] 				= cache_get_field_content_int(i, "character_pantsammo", mysql ) ;

			Character [ playerid ] [ character_backweapon ] 			= cache_get_field_content_int(i, "character_backweapon", mysql ) ;
			Character [ playerid ] [ character_backammo ] 				= cache_get_field_content_int(i, "character_backammo", mysql ) ;

			Character [ playerid ] [ character_ammopack_pistol ] 		= cache_get_field_content_int(i, "character_ammopack_pistol", mysql ) ;
			Character [ playerid ] [ character_ammopack_shotgun ] 		= cache_get_field_content_int(i, "character_ammopack_shotgun", mysql ) ;
			Character [ playerid ] [ character_ammopack_rifle ] 		= cache_get_field_content_int(i, "character_ammopack_rifle", mysql ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


			PlayerSaddleBagWeapon [ playerid ] [ 0 ] 		= cache_get_field_content_int(i, "character_sb_gun0", mysql ) ;
			PlayerSaddleBagWeapon [ playerid ] [ 1 ] 		= cache_get_field_content_int(i, "character_sb_gun1", mysql ) ;

			PlayerSaddleBagAmmo [ playerid ] [ 0 ] 			= cache_get_field_content_int(i, "character_sb_ammo0", mysql ) ;
			PlayerSaddleBagAmmo [ playerid ] [ 1 ] 			= cache_get_field_content_int(i, "character_sb_ammo1", mysql ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


			Character [ playerid ] [ character_handmoney ] 				= cache_get_field_content_int(i, "character_handmoney", mysql ) ;
			Character [ playerid ] [ character_handchange ]				= cache_get_field_content_int(i, "character_handchange", mysql ) ;
			Character [ playerid ] [ character_bankmoney ] 				= cache_get_field_content_int(i, "character_bankmoney", mysql ) ;
			Character [ playerid ] [ character_bankchange ] 			= cache_get_field_content_int(i, "character_bankchange", mysql) ;
			Character [ playerid ] [ character_paycheck ] 				= cache_get_field_content_int(i, "character_paycheck", mysql ) ;
			Character [ playerid ] [ character_paychange ]				= cache_get_field_content_int(i, "character_paychange", mysql ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			Character [ playerid ] [ character_prison ] 				= cache_get_field_content_int(i, "character_prison", mysql ) ;
			Character [ playerid ] [ character_prison_pos_x] 			= cache_get_field_content_float(i, "character_prison_pos_x", mysql ) ;
			Character [ playerid ] [ character_prison_pos_y] 			= cache_get_field_content_float(i, "character_prison_pos_y", mysql ) ;
			Character [ playerid ] [ character_prison_pos_z] 			= cache_get_field_content_float(i, "character_prison_pos_z", mysql ) ;
			Character [ playerid ] [ character_prison_interior ] 		= cache_get_field_content_int(i, "character_prison_interior", mysql ) ;
			Character [ playerid ] [ character_prison_vw ]			 	= cache_get_field_content_int(i, "character_prison_vw", mysql ) ;
			Character [ playerid ] [ character_prison_bail ] 			= cache_get_field_content_int(i, "character_prison_bail", mysql ) ;
			Character [ playerid ] [ character_prison_bail_cents ]		= cache_get_field_content_int(i, "character_prison_bail_cents", mysql ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			cache_get_field_content ( i, "character_attributes", 	Character [ playerid ] [ character_attributes ], mysql, 144 ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			Character [ playerid ] [ character_bounty_id ] 				= cache_get_field_content_int(i, "character_bounty_id", mysql ) ;
			Character [ playerid ] [ character_telegram_id ] 			= cache_get_field_content_int(i, "character_telegram_id", mysql ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			Character [ playerid ] [ character_jobactionsleft ] 		= cache_get_field_content_int(i, "character_jobactionsleft", mysql ) ;

			Character [ playerid ] [ character_woodactionsleft ] 		= cache_get_field_content_int(i, "character_woodactionsleft", mysql ) ;
			Character [ playerid ] [ character_fishactionsleft ] 		= cache_get_field_content_int(i, "character_fishactionsleft", mysql ) ;
			Character [ playerid ] [ character_mineactionsleft ] 		= cache_get_field_content_int(i, "character_mineactionsleft", mysql ) ;
			
			Character [ playerid ] [ character_woodcd ] 				= cache_get_field_content_int(i, "character_woodcd", mysql ) ;
			Character [ playerid ] [ character_fishcd ] 				= cache_get_field_content_int(i, "character_fishcd", mysql ) ;
			Character [ playerid ] [ character_minecd ] 				= cache_get_field_content_int(i, "character_minecd", mysql ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			Character [ playerid ] [character_mask_offsetx ]  			= cache_get_field_content_float(i, "character_mask_offsetx", mysql ) ;
			Character [ playerid ] [character_mask_offsety ]  			= cache_get_field_content_float(i, "character_mask_offsety", mysql ) ;
			Character [ playerid ] [character_mask_offsetz ]  			= cache_get_field_content_float(i, "character_mask_offsetz", mysql ) ;

			Character [ playerid ] [character_mask_rotx ]  				= cache_get_field_content_float(i, "character_mask_rotx", mysql ) ;
			Character [ playerid ] [character_mask_roty ]  				= cache_get_field_content_float(i, "character_mask_roty", mysql ) ;
			Character [ playerid ] [character_mask_rotz ]  				= cache_get_field_content_float(i, "character_mask_rotz", mysql ) ;

			Character [ playerid ] [character_mask_scalex ]  			= cache_get_field_content_float(i, "character_mask_scalex", mysql ) ;
			Character [ playerid ] [character_mask_scaley ]  			= cache_get_field_content_float(i, "character_mask_scaley", mysql ) ;
			Character [ playerid ] [character_mask_scalez ]  			= cache_get_field_content_float(i, "character_mask_scalez", mysql ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			Character [ playerid ] [character_trousergun_offsetx ]  	= cache_get_field_content_float(i, "character_trousergun_offsetx", mysql ) ;
			Character [ playerid ] [character_trousergun_offsety ]  	= cache_get_field_content_float(i, "character_trousergun_offsety", mysql ) ;
			Character [ playerid ] [character_trousergun_offsetz ]  	= cache_get_field_content_float(i, "character_trousergun_offsetz", mysql ) ;

			Character [ playerid ] [character_trousergun_rotx ]  		= cache_get_field_content_float(i, "character_trousergun_rotx", mysql ) ;
			Character [ playerid ] [character_trousergun_roty ]  		= cache_get_field_content_float(i, "character_trousergun_roty", mysql ) ;
			Character [ playerid ] [character_trousergun_rotz ]  		= cache_get_field_content_float(i, "character_trousergun_rotz", mysql ) ;

			Character [ playerid ] [character_trousergun_scalex ]  		= cache_get_field_content_float(i, "character_trousergun_scalex", mysql ) ;
			Character [ playerid ] [character_trousergun_scaley ]  		= cache_get_field_content_float(i, "character_trousergun_scaley", mysql ) ;
			Character [ playerid ] [character_trousergun_scalez ]  		= cache_get_field_content_float(i, "character_trousergun_scalez", mysql ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			Character [ playerid ] [character_backgun_offsetx ]  		= cache_get_field_content_float(i, "character_backgun_offsetx", mysql ) ;
			Character [ playerid ] [character_backgun_offsety ]  		= cache_get_field_content_float(i, "character_backgun_offsety", mysql ) ;
			Character [ playerid ] [character_backgun_offsetz ]  		= cache_get_field_content_float(i, "character_backgun_offsetz", mysql ) ;

			Character [ playerid ] [character_backgun_rotx ]  			= cache_get_field_content_float(i, "character_backgun_rotx", mysql ) ;
			Character [ playerid ] [character_backgun_roty ]  			= cache_get_field_content_float(i, "character_backgun_roty", mysql ) ;
			Character [ playerid ] [character_backgun_rotz ]  			= cache_get_field_content_float(i, "character_backgun_rotz", mysql ) ;

			Character [ playerid ] [character_backgun_scalex ]  		= cache_get_field_content_float(i, "character_backgun_scalex", mysql ) ;
			Character [ playerid ] [character_backgun_scaley ]  		= cache_get_field_content_float(i, "character_backgun_scaley", mysql ) ;
			Character [ playerid ] [character_backgun_scalez ]  		= cache_get_field_content_float(i, "character_backgun_scalez", mysql ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			Character [ playerid ] [ character_pos_x ] 					= cache_get_field_content_float(i, "character_pos_x", mysql ) ;
			Character [ playerid ] [ character_pos_y ] 					= cache_get_field_content_float(i, "character_pos_y", mysql ) ;
			Character [ playerid ] [ character_pos_z ] 					= cache_get_field_content_float(i, "character_pos_z", mysql ) ;

			Character [ playerid ] [ character_pos_interior ] 			= cache_get_field_content_int(i, "character_pos_interior", mysql ) ;
			Character [ playerid ] [ character_pos_vw ] 				= cache_get_field_content_int(i, "character_pos_vw", mysql ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			Character [ playerid ] [ character_temperature ] 			= cache_get_field_content_int(i, "character_temperature", mysql ) ;
			Character [ playerid ] [ character_temperature_decimal ]    = cache_get_field_content_int(i, "character_temperature_decimal", mysql ) ;

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			Character [ playerid ] [ character_crashed ]				= cache_get_field_content_int(i, "character_crashed", mysql);

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			Init_LoadPlayerAttachments ( playerid ) ;
		}
	}

	return SpawnPlayer_Character ( playerid ) ;
}

SetCharacterLoggedPosition ( playerid, crashed = 0 ) {

	if(!crashed) {

		if ( Character [ playerid ] [ character_spawnpoint ] == 6 ) {

			if ( IsPlayerSpawned ( playerid ) ) {

				new Float: x, Float: y, Float: z, query [ 256 ] ;

				if(GetCharacterPointID(playerid) == -1) {
					
					GetPlayerPos ( playerid, x, y, z ) ;

					mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_pos_x = %f, character_pos_y = %f, character_pos_z = %f, character_pos_interior = %d, character_pos_vw = %d WHERE character_id = %d", x, y, z, GetPlayerInterior ( playerid ), GetPlayerVirtualWorld ( playerid ), Character [ playerid ] [ character_id ] ) ;
					mysql_tquery ( mysql, query ) ;
				}
				else {

					new id = GetCharacterPointID(playerid);
					GetPointExteriorPosition(id,x,y,z);

					mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_pos_x = %f, character_pos_y = %f, character_pos_z = %f, character_pos_interior = 0, character_pos_vw = 0 WHERE character_id = %d", x, y, z, Character [ playerid ] [ character_id ] ) ;
					mysql_tquery ( mysql, query ) ;
				}
			}
		}
	}

	else {

		if ( IsPlayerSpawned ( playerid ) ) {

			Character [ playerid ] [ character_crashed ] = 1;
			new Float: x, Float: y, Float: z, query [ 256 ] ;

			if(GetCharacterPointID(playerid) == -1) {
					
				GetPlayerPos ( playerid, x, y, z ) ;

				mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_pos_x = %f, character_pos_y = %f, character_pos_z = %f, character_pos_interior = %d, character_pos_vw = %d, character_crashed = 1 WHERE character_id = %d", x, y, z, GetPlayerInterior ( playerid ), GetPlayerVirtualWorld ( playerid ), Character [ playerid ] [ character_id ] ) ;
				mysql_tquery ( mysql, query ) ;
			}
			else {

				new id = GetCharacterPointID(playerid);
				GetPointExteriorPosition(id,x,y,z);

				mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_pos_x = %f, character_pos_y = %f, character_pos_z = %f, character_pos_interior = 0, character_pos_vw = 0, character_crashed = 1 WHERE character_id = %d", x, y, z, Character [ playerid ] [ character_id ] ) ;
				mysql_tquery ( mysql, query ) ;
			}
		}
	}

	return true ;
}

GiveRegisterReward ( playerid, charid ) {

	if(NewlyRegistered[playerid]) {

		new query [ 256 ] ; 

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_health = 100, character_thirst = 100, character_hunger = 100 WHERE character_id = '%d'", charid ) ;
		mysql_tquery ( mysql, query ) ;

		mysql_format(mysql, query, sizeof ( query ),"UPDATE characters SET character_level = 1, character_expleft = 8 WHERE character_id = '%d'", charid ) ;
		mysql_tquery ( mysql, query ) ;

		mysql_format(mysql, query, sizeof ( query ),"UPDATE characters SET character_posse = -1, character_posserank = 'None' WHERE character_id = '%d'", charid ) ;
		mysql_tquery ( mysql, query ) ;

		mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_handmoney = %d,character_handchange = %d,character_bankmoney = %d,character_bankchange = %d WHERE character_id = '%d'",10,randomEx(1,25),25,randomEx(1,25),charid);
		mysql_tquery(mysql,query);

		/*
		GiveCharacterMoney ( playerid, 10, MONEY_SLOT_HAND ) ;
		GiveCharacterChange ( playerid, randomEx(1,25), MONEY_SLOT_HAND ) ;
		GiveCharacterMoney ( playerid, 25, MONEY_SLOT_BANK ) ;
		GiveCharacterChange ( playerid, randomEx(1,25), MONEY_SLOT_BANK ) ;
		SetCharacterHealth ( playerid, 100 ) ;

		Character [ playerid ] [ character_hunger ] = 100 ;
		Character [ playerid ] [ character_thirst ] = 100 ;

		Character [ playerid ] [ character_level ] = 1 ;
		Character [ playerid ] [ character_expleft ] = 8 ;

		Character [ playerid ] [ character_posse ] = -1 ;
		format ( Character [ playerid ] [ character_posserank ], Character [ playerid ] [ character_posserank ], "None" ) ;

		GivePlayerItemByParam ( playerid, PARAM_FISHING, FISHING_ROD, 1, 0, 0, 0 ) ;
		*/

		NewlyRegistered [ playerid ] = false ;
	}
}