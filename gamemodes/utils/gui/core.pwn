/*

	If valid gui weapon = false
	
	Make the box show the following
	    - Player Money (make it nice with .txd shit)
	    - Ingame Date (custom year system: day (name), day (nr), month, year, time
		  - 18:03 - Saturday, 23th of June, 1881
		- ... ?
*/


#define MAX_GUI_DRAWS       ( 50 )

#define GUI_MAX_BULLETS             ( 10 )
#define GUI_MAX_HUDBOX     			( 3 )

new Text: gui_td_hudbox 			[ GUI_MAX_HUDBOX ] ;
new Text: gui_td_hudbox_divider     ;
new Text: gui_td_hudbox_date ;

/*
#define GUI_MAX_INFOBOX     		( 3 )
new Text: gui_td_infobox 			[ GUI_MAX_INFOBOX ] ;
new Text: gui_td_infobox_text 		[ GUI_MAX_INFOBOX ] ;
new Text: gui_td_infobox_dividers 	[ GUI_MAX_INFOBOX ] ;
new Text: gui_td_infobox_icons 		[ GUI_MAX_INFOBOX ] ;

new PlayerText: gui_td_playerHealth ;
new PlayerText: gui_td_playerHunger;
new PlayerText: gui_td_playerThirst ;
*/

new Text: guiTD[17] = Text: INVALID_TEXT_DRAW ;
new PlayerText: guiPTD[4] = PlayerText: INVALID_TEXT_DRAW ;

new Text: horseguiTD[9] = Text: INVALID_TEXT_DRAW ;
new PlayerText: horseguiPTD[2] = PlayerText: INVALID_TEXT_DRAW ;

new PlayerText: gui_td_hudbox_cash ;
new PlayerText: gui_td_hudbox_gunmodel ;
new PlayerText: gui_td_hudbox_bulletinfo ;

new PlayerText: gui_td_hudbox_gunname 		[ GUI_MAX_HUDBOX ] ;
new PlayerText: gui_td_hudbox_gunbullet   	[ GUI_MAX_BULLETS ];

// enabled
new bool: player_gui_enabled [MAX_PLAYERS ] ;

#define GUI_VERTICAL_ADJUST ( 7.5 )
#define GUI_VERTICAL_JUMP   ( 55 )

#define BORDER_COLOUR       (0xD17F5EAA)
#define MONEY_COLOUR        (0x4D6345FF)
#define DATE_COLOUR        	(0xBFBFBFFF)

public OnGameModeInit()
{
	GUI_LoadStaticHorseDraws() ; 
	GUI_LoadStaticPlayerDraws();
	#if defined mgui_OnGameModeInit
		return mgui_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif

#define OnGameModeInit mgui_OnGameModeInit
#if defined mgui_OnGameModeInit
	forward mgui_OnGameModeInit();
#endif

public OnPlayerConnect(playerid)
{
	GUI_LoadPlayerPlayerDraws(playerid);
	GUI_LoadPlayerHorseDraws ( playerid ) ;
	#if defined mgui_OnPlayerConnect
		return mgui_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect mgui_OnPlayerConnect
#if defined mgui_OnPlayerConnect
	forward mgui_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason)
{
	GUI_DestroyPlayerPlayerDraws(playerid);
	GUI_DestroyHorsePlayerDraws ( playerid ) ;
	#if defined mgui_OnPlayerDisconnect
		return mgui_OnPlayerDisconnect(playerid, reason);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif

#define OnPlayerDisconnect mgui_OnPlayerDisconnect
#if defined mgui_OnPlayerDisconnect
	forward mgui_OnPlayerDisconnect(playerid, reason);
#endif

UpdateHorseGUI(playerid) {

	new string[4];
	//format(string,sizeof(string),"%.0f",(horseType[horseid][h_td_stamina]/PlayerHorse [ playerid ] [ HorseSprintValue ])*100);
	format(string,sizeof(string),"%.0f",PlayerHorse [ playerid ] [ HorseSprintValue ]);
	PlayerTextDrawHide(playerid, horseguiPTD[0] ) ;
	PlayerTextDrawSetString(playerid, horseguiPTD[0], string ) ;
	PlayerTextDrawShow(playerid, horseguiPTD[0] ) ;
	//format(string,sizeof(string),"%.0f",(horseType[horseid][h_td_health]/Character [ playerid ] [ character_horsehealth ])*100 );
	format(string,sizeof(string),"%.0f",Character [ playerid ] [ character_horsehealth ]);
	PlayerTextDrawHide(playerid, horseguiPTD[1] ) ;
	PlayerTextDrawSetString(playerid, horseguiPTD[1], string ) ;
	PlayerTextDrawShow(playerid, horseguiPTD[1] ) ;
	return 1;
}

UpdateGUI ( playerid ) {
 
	if (HudHidden[playerid]){

		return true ;
	}

	for(new i=0; i<5; i++) {
		
		new string [ 64 ] ;

		//date set

		TextDrawHideForPlayer ( playerid, gui_td_hudbox_date  ) ;

		format ( string, sizeof ( string ), "%s the %d%s,~n~%s, %d", date_dayName ( serverDay, serverMonth, serverYear ),
			serverDay, date_dayOrdinal ( serverDay ), date_getMonth ( serverMonth ), serverYear );

		TextDrawSetString ( gui_td_hudbox_date, string ) ;
		TextDrawShowForPlayer ( playerid, gui_td_hudbox_date  ) ;

		//character cash set

		PlayerTextDrawHide(playerid, gui_td_hudbox_cash ) ;

		format ( string, sizeof ( string ), "$%s.%02d", IntegerWithDelimiter ( Character [ playerid ] [ character_handmoney ] ), Character[playerid][character_handchange] ) ;

		PlayerTextDrawSetString(playerid, gui_td_hudbox_cash, string ) ;
		PlayerTextDrawShow(playerid, gui_td_hudbox_cash ) ;

		//temperature set

		PlayerTextDrawHide(playerid, guiPTD[0] ) ;

		format(string,sizeof(string),"%d.%d",Character[playerid][character_temperature],Character[playerid][character_temperature_decimal]);

		PlayerTextDrawSetString(playerid, guiPTD[0], string ) ;
		PlayerTextDrawShow(playerid, guiPTD[0] ) ;

		//character health set
		PlayerTextDrawHide(playerid, guiPTD[1] ) ;

		switch ( floatround ( Character [ playerid ] [ character_health ] ) ) {

			case 0 .. 39: {

				format ( string, sizeof ( string ), "%.0f", Character [ playerid ] [ character_health ] ) ;
				PlayerTextDrawColor(playerid,guiPTD[1],0xF40000FF);
			}

			case 40 .. 69: {

				format ( string, sizeof ( string ), "%.0f", Character [ playerid ] [ character_health ] ) ;
				PlayerTextDrawColor(playerid,guiPTD[1],COLOR_YELLOW);
			}

			default: {
				
				format ( string, sizeof ( string ), "%.0f", Character [ playerid ] [ character_health ] ) ;
				PlayerTextDrawColor(playerid, guiPTD[1], -555819350);
			}
		}

		PlayerTextDrawSetString(playerid, guiPTD[1], string ) ;
		PlayerTextDrawShow(playerid, guiPTD[1] ) ;

		//character hunger set

		PlayerTextDrawHide(playerid, guiPTD[2] ) ;

		switch(Character[playerid][character_hunger]) {

			case 0..25: {

				format(string,sizeof(string),"%d",Character[playerid][character_hunger]);
				PlayerTextDrawColor(playerid,guiPTD[2],0xF40000FF);
			}

			case 26..50: {

				format(string,sizeof(string),"%d",Character[playerid][character_hunger]);
				PlayerTextDrawColor(playerid,guiPTD[2],COLOR_YELLOW);
			}

			default: {

				format(string,sizeof(string),"%d",Character[playerid][character_hunger]);
				PlayerTextDrawColor(playerid, guiPTD[2], -555819350);
			}
		}
		
		PlayerTextDrawSetString(playerid, guiPTD[2], string ) ;
		PlayerTextDrawShow(playerid, guiPTD[2] ) ;

		//character thirst set

		PlayerTextDrawHide(playerid, guiPTD[3] ) ;

		switch(Character[playerid][character_thirst]) {

			case 0..25: {

				format(string,sizeof(string),"%d",Character[playerid][character_thirst]);
				PlayerTextDrawColor(playerid,guiPTD[3],0xF40000FF);
			}

			case 26..50: {

				format(string,sizeof(string),"%d",Character[playerid][character_thirst]);
				PlayerTextDrawColor(playerid,guiPTD[3],COLOR_YELLOW);
			}

			default: {

				format(string,sizeof(string),"%d",Character[playerid][character_thirst]);
				PlayerTextDrawColor(playerid, guiPTD[3], -555819350);
			}
		}
		
		PlayerTextDrawSetString(playerid, guiPTD[3], string ) ;
		PlayerTextDrawShow(playerid, guiPTD[3] ) ;
	}

	return true ;
}

HideGUITextDraws ( playerid ) {

 	player_gui_enabled [ playerid ] = false ;

	//PlayerTextDrawHide ( playerid, guiPTD[1] ) ;
	//PlayerTextDrawHide ( playerid, guiPTD[2]   ) ;
	//PlayerTextDrawHide ( playerid, guiPTD[3]   ) ;

	GUI_HidePlayerPlayerDraws(playerid);

	for ( new i; i < GUI_MAX_BULLETS; i ++ ) {
		PlayerTextDrawHide ( playerid, gui_td_hudbox_gunbullet [ i ]  ) ;
	}

	for ( new i; i < sizeof(guiTD); i ++ ) {
		TextDrawHideForPlayer ( playerid, guiTD [ i ] ) ;
		//TextDrawHideForPlayer ( playerid, gui_td_infobox_text [ i ] ) ;
		//TextDrawHideForPlayer ( playerid, gui_td_infobox_icons [ i ] ) ;
		//TextDrawHideForPlayer ( playerid, gui_td_infobox_dividers [ i ] ) ;
	}

	for ( new i; i < GUI_MAX_HUDBOX; i ++ ) {
		TextDrawHideForPlayer ( playerid, gui_td_hudbox [ i ] ) ;
		PlayerTextDrawHide ( playerid, gui_td_hudbox_gunname [ i ]  ) ;
	}

	PlayerTextDrawHide ( playerid, gui_td_hudbox_gunmodel   ) ;
	PlayerTextDrawHide ( playerid, gui_td_hudbox_bulletinfo   ) ;
	PlayerTextDrawHide ( playerid, gui_td_hudbox_cash  ) ;

	TextDrawHideForPlayer ( playerid, gui_td_hudbox_divider ) ;
	TextDrawHideForPlayer ( playerid, gui_td_hudbox_date  ) ;
}

ShowGUITextDraws ( playerid ) {

 	player_gui_enabled [playerid] = true ;

	////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////

	//PlayerTextDrawShow ( playerid, guiPTD[1]   ) ;
	//PlayerTextDrawShow ( playerid, guiPTD[2]   ) ;
	//PlayerTextDrawShow ( playerid, guiPTD[3]   ) ;
	GUI_ShowPlayerPlayerDraws(playerid);

	for ( new i; i < GUI_MAX_BULLETS; i ++ ) {
		PlayerTextDrawShow ( playerid, gui_td_hudbox_gunbullet [ i ]  ) ;
	}

	PlayerTextDrawShow ( playerid, gui_td_hudbox_gunmodel  ) ;
	PlayerTextDrawShow ( playerid, gui_td_hudbox_bulletinfo  ) ;
	PlayerTextDrawShow ( playerid, gui_td_hudbox_cash  ) ;

	for ( new i; i < GUI_MAX_HUDBOX; i ++ ) {
		PlayerTextDrawShow ( playerid, gui_td_hudbox_gunname [ i ]  ) ;
	}

	for ( new i; i < sizeof(guiTD); i ++ ) {
		TextDrawShowForPlayer ( playerid, guiTD [ i ] ) ;
		//TextDrawShowForPlayer ( playerid, gui_td_infobox_text [ i ] ) ;
		//TextDrawShowForPlayer ( playerid, gui_td_infobox_icons [ i ] ) ;
		//TextDrawShowForPlayer ( playerid, gui_td_infobox_dividers [ i ] ) ;
	}

	for ( new i; i < GUI_MAX_HUDBOX; i ++ ) {
		TextDrawShowForPlayer ( playerid, gui_td_hudbox [ i ] ) ;
	}

	TextDrawShowForPlayer ( playerid, gui_td_hudbox_divider ) ;
	TextDrawShowForPlayer ( playerid, gui_td_hudbox_date  ) ;
}

ShowHUDTextDraws(playerid) {

	GUI_ShowPlayerPlayerDraws(playerid);
	for ( new i; i < sizeof(guiTD); i ++ ) {
		TextDrawShowForPlayer ( playerid, guiTD [ i ] ) ;
	}
}

HideHUDTextDraws(playerid) {

	GUI_HidePlayerPlayerDraws(playerid);
	for ( new i; i < sizeof(guiTD); i ++ ) {
		TextDrawHideForPlayer ( playerid, guiTD [ i ] ) ;
	}	
}

CMD:hud(playerid, params[]){

	if(!HudHidden[playerid]){
		HudHidden[playerid] = true;
		HideHUDTextDraws(playerid);
		SendServerMessage(playerid, "HUD has been turned off.", MSG_TYPE_INFO);
	} else {
		HudHidden[playerid] = false;
		ShowHUDTextDraws(playerid);
		SendServerMessage(playerid, "HUD has been turned on.", MSG_TYPE_INFO);
	}

	return true;
}

CMD:toghud(playerid, params[]) {

	return cmd_hud(playerid, params) ;
}

LoadWeaponGUI ( playerid ) {

	gui_td_hudbox_gunname [ 0 ]  = CreatePlayerTextDraw(playerid, 553.5, 29.5, "Nothing Equipped");
	PlayerTextDrawLetterSize(playerid, gui_td_hudbox_gunname [ 0 ] , 0.268333, 1.114666);
	PlayerTextDrawBackgroundColor(playerid, gui_td_hudbox_gunname [ 0 ] , 51);
	PlayerTextDrawColor (playerid,  gui_td_hudbox_gunname [ 0 ] , BORDER_COLOUR ) ;
	PlayerTextDrawFont(playerid, gui_td_hudbox_gunname [ 0 ] , 2);
	PlayerTextDrawAlignment(playerid, gui_td_hudbox_gunname [ 0 ] , 2);

	gui_td_hudbox_gunmodel = CreatePlayerTextDraw(playerid, 495.5, 37.5, "hp_gunmodel_box");
	PlayerTextDrawTextSize(playerid, gui_td_hudbox_gunmodel , 52.5, 52.5);
	PlayerTextDrawUseBox(playerid, gui_td_hudbox_gunmodel , true);
	PlayerTextDrawBackgroundColor (playerid, gui_td_hudbox_gunmodel , 0x00000000 ) ;
	PlayerTextDrawBoxColor (playerid, gui_td_hudbox_gunmodel , 0x00000000 ) ;
	PlayerTextDrawFont(playerid, gui_td_hudbox_gunmodel , TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel , 18631);
	PlayerTextDrawSetPreviewRot ( playerid, gui_td_hudbox_gunmodel , 0, 30, 0, 1.0 ) ;

	return true ;
}

UpdateWeaponGUI ( playerid ) {
	new formats [ 32 ] ;

	if ( ! IsPlayerAiming ( playerid ) ) {
		SetPlayerDrunkLevel(playerid, 0) ;
	}

	PlayerTextDrawHide(playerid, gui_td_hudbox_gunname [ 0 ]  ) ;
	PlayerTextDrawHide(playerid, gui_td_hudbox_gunmodel ) ;

	PlayerTextDrawDestroy(playerid, gui_td_hudbox_bulletinfo  ) ;

	if ( EquippedItem [ playerid ] == -1) {
		// Making sure the weapon model textdraw is adjusted accordingly ... //
		switch ( Character [ playerid ] [ character_handweapon ] ) {
		    case WEAPON_SHOTGUN, WEAPON_SAWEDOFF, WEAPON_RIFLE, WEAPON_SNIPER: {
				if ( Character [ playerid ] [ character_handweapon ]  == WEAPON_SHOTGUN ) {
					PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Shotgun" ) ;
				    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 349);
				}

				else if ( Character [ playerid ] [ character_handweapon ]  == WEAPON_SAWEDOFF ) {
					PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Sawn-off Shotgun" ) ;
				    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 350);
				}

				else if ( Character [ playerid ] [ character_handweapon ]  == WEAPON_RIFLE ) {
					PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Repeater Rifle" ) ;
				    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 357);
				}
				
				else if ( Character [ playerid ] [ character_handweapon ]  == WEAPON_SNIPER ) {
					PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Scoped Rifle" ) ;
				    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 358);
				}

				PlayerTextDrawSetPreviewRot (playerid, gui_td_hudbox_gunmodel  , 0, -30, 0, 2 ) ;
			}

		    case WEAPON_DEAGLE, WEAPON_KNIFE, WEAPON_BAT: {

				if ( Character [ playerid ] [ character_handweapon ]  == WEAPON_DEAGLE ) {
					PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Revolver" ) ;
				    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 348);
	  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
				}

				else if ( Character [ playerid ] [ character_handweapon ]  == WEAPON_KNIFE ) {
					PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Hunting Knife" ) ;
				    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 335);
	   				PlayerTextDrawSetPreviewRot ( playerid, gui_td_hudbox_gunmodel  , 0, 30, 0, 1.25 ) ;
				}

				else if ( Character [ playerid ] [ character_handweapon ]  == WEAPON_BAT ) {
					PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Baseball Bat" ) ;
				    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 336);
	   				PlayerTextDrawSetPreviewRot ( playerid, gui_td_hudbox_gunmodel  , 0, 30, 0, 1.25 ) ;
				}
			}
			
			default: {
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Nothing Equipped" ) ;
				PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel , 18631);
				PlayerTextDrawSetPreviewRot ( playerid, gui_td_hudbox_gunmodel , 0, 30, 0, 1.0 ) ;
		    }
		}

		///////////////////////////////////////////////////////////////////////

		for ( new i; i < GUI_MAX_BULLETS; i ++ ) {

			PlayerTextDrawDestroy(playerid, gui_td_hudbox_gunbullet [ i ]  ) ;
		}


		new BULLET_INCREMENT = 5 ;

		if(Character[playerid][character_handweapon] != WEAPON_BAT && Character[playerid][character_handweapon] != WEAPON_KNIFE) {
			
			if ( Character [ playerid ] [ character_handammo ] != 0) {
			
				format ( formats, sizeof ( formats ), "%d BULLETS", Character [ playerid ] [ character_handammo ] );
			}
		
			else format ( formats, sizeof ( formats ), "NO AMMO" );
		}

		new bulletLoop ;

		if ( Character [ playerid ] [ character_handammo ] > GUI_MAX_BULLETS ) {
			bulletLoop = 10 ;
		}

		else bulletLoop = Character [ playerid ] [ character_handammo ] ;

		for ( new i; i < bulletLoop; i ++ ) {
			gui_td_hudbox_gunbullet [ i ]   = CreatePlayerTextDraw(playerid, 540 + BULLET_INCREMENT * i, 40, "hp_gunbullet_box");
			PlayerTextDrawTextSize( playerid, gui_td_hudbox_gunbullet [ i ] , 25, 25);
			PlayerTextDrawUseBox( playerid, gui_td_hudbox_gunbullet [ i ] , true);
			PlayerTextDrawBackgroundColor ( playerid, gui_td_hudbox_gunbullet [ i ] , 0x00000000 ) ;
			PlayerTextDrawFont( playerid, gui_td_hudbox_gunbullet [ i ] , TEXT_DRAW_FONT_MODEL_PREVIEW);
			PlayerTextDrawBoxColor (playerid, gui_td_hudbox_gunbullet [ i ] , 0x00000000 ) ;
		    PlayerTextDrawSetPreviewModel( playerid, gui_td_hudbox_gunbullet [ i ] , 2061);
			PlayerTextDrawSetPreviewRot ( playerid, gui_td_hudbox_gunbullet [ i ] , 0, 0, 90, 1.25 ) ;

			PlayerTextDrawShow(playerid, gui_td_hudbox_gunbullet [ i ]  ) ;
		}

		PlayerTextDrawDestroy(playerid, gui_td_hudbox_bulletinfo  ) ;
		
		gui_td_hudbox_bulletinfo   = CreatePlayerTextDraw(playerid, 552.5, 62, formats);
		PlayerTextDrawLetterSize(playerid, gui_td_hudbox_bulletinfo  , 0.24, 1.114666);
		PlayerTextDrawBackgroundColor(playerid, gui_td_hudbox_bulletinfo  , 51);
		PlayerTextDrawColor (playerid, gui_td_hudbox_bulletinfo  , BORDER_COLOUR ) ;
		PlayerTextDrawFont(playerid, gui_td_hudbox_bulletinfo  , 2);	
	}

	else if ( EquippedItem [ playerid ] ) {

		gui_td_hudbox_bulletinfo   = CreatePlayerTextDraw(playerid, 552.5, 62, "No ammo" ) ;
		PlayerTextDrawLetterSize(playerid, gui_td_hudbox_bulletinfo  , 0.24, 1.114666);
		PlayerTextDrawBackgroundColor(playerid, gui_td_hudbox_bulletinfo  , 51);
		PlayerTextDrawColor (playerid, gui_td_hudbox_bulletinfo  , BORDER_COLOUR ) ;
		PlayerTextDrawFont(playerid, gui_td_hudbox_bulletinfo  , 2);	

		switch  ( EquippedItem [ playerid ] ) {

			case DYNAMITE: {
			
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Dynamite" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 1654);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
			}

			case CAMERA: {
				
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Flash Camera" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 19623);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
			}

			case HUNTING_KNIFE: {
				
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Hunting Knife" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 335);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
			}

			case FISHING_ROD: {
				
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Fishing Rod" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 18632);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
			}

			case MINE_PICKAXE: {
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Pickaxe" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , PICKAXE);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 4.5 ) ;
			}

			case LUMBER_HATCHET: {
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Hatchet" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , HATCHET);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 4.5 ) ;
			}

			case LIQUOR_PALELAGER: {
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Pale Lager" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 1544);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
			}

			case LIQUOR_MILDALE: {
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Mild Ale" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 1543);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
			}

			case LIQUOR_MALTLIQUOR: {
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Malt Liquor" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 1486);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
			}

			case LIQUOR_WHEATBEER: {
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Wheat Beer" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 1484);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
			}

			case LIQUOR_WHITEWINE: {
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "White Wine" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 19824);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
			}

			case LIQUOR_REDWINE: {
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Red Wine" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 19822);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
			}

			case LIQUOR_GRAINWHISKEY: {
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Grain Whiskey" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 19823);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
			}

			case LIQUOR_MALTWHISKEY: {
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Malt Whiskey" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 19820);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
			}

			case LIQUOR_VODKA: {
				PlayerTextDrawSetString ( playerid, gui_td_hudbox_gunname [ 0 ] , "Moonshine Vodka" ) ;
			    PlayerTextDrawSetPreviewModel(playerid, gui_td_hudbox_gunmodel  , 19821);
  				PlayerTextDrawSetPreviewRot (playerid,  gui_td_hudbox_gunmodel  , 0, -30, 0, 1 ) ;
			}
		}
	}

	PlayerTextDrawShow(playerid, gui_td_hudbox_bulletinfo  ) ;
	PlayerTextDrawShow(playerid, gui_td_hudbox_gunname [ 0 ]  ) ;
	PlayerTextDrawShow(playerid, gui_td_hudbox_gunmodel  ) ;

	return true ;
}

//LoadStaticGUITextDraw ( ) {
GUI_LoadStaticPlayerDraws() {

	gui_td_hudbox [ 0 ] = TextDrawCreate(615.666870, 23.485183, "hp_outline_outer");
	TextDrawLetterSize(gui_td_hudbox [ 0 ], 0.000000, 8.740530);
	TextDrawTextSize(gui_td_hudbox [ 0 ], 490.333312, 0.000000);
	TextDrawBackgroundColor(gui_td_hudbox  [ 0 ], 0x00000000 ) ;
	TextDrawUseBox(gui_td_hudbox [ 0 ], true);
	TextDrawBoxColor(gui_td_hudbox [ 0 ], 286331391);

	gui_td_hudbox [ 1 ] = TextDrawCreate(614.000061, 25.559255, "hp_outline_inner");
	TextDrawLetterSize(gui_td_hudbox [ 1 ], 0.000000, 8.291562);
	TextDrawTextSize(gui_td_hudbox [ 1 ], 492.333343, 0.000000);
	TextDrawBackgroundColor(gui_td_hudbox  [ 1 ], 0x00000000 ) ;
	TextDrawUseBox(gui_td_hudbox [ 1 ], true);
	TextDrawBoxColor(gui_td_hudbox [ 1 ], BORDER_COLOUR);

	gui_td_hudbox [ 2 ] = TextDrawCreate(613.333374, 26.388889, "hp_innerbox");
	TextDrawLetterSize(gui_td_hudbox [ 2 ], 0.000000, 8.117897);
	TextDrawTextSize(gui_td_hudbox [ 2 ], 493.000000, 0.000000);
	TextDrawBackgroundColor(gui_td_hudbox  [ 2 ], 0x00000000 ) ;
	TextDrawUseBox(gui_td_hudbox [ 2 ], true);
	TextDrawBoxColor(gui_td_hudbox [ 2 ], 286331391);

	gui_td_hudbox_divider = TextDrawCreate(601, 78, "hp_outline_inner");
	TextDrawLetterSize(gui_td_hudbox_divider, 0.000000, -0.278394);
	TextDrawTextSize(gui_td_hudbox_divider, 550, 0.000000);
	TextDrawBackgroundColor(gui_td_hudbox_divider, 0x00000000 ) ;
	TextDrawUseBox(gui_td_hudbox_divider, true);
	TextDrawBoxColor(gui_td_hudbox_divider, BORDER_COLOUR);

	gui_td_hudbox_date = TextDrawCreate(552, 80.5, " ");
	TextDrawLetterSize( gui_td_hudbox_date, 0.12, 0.7);
	TextDrawBackgroundColor( gui_td_hudbox_date, 51);
	TextDrawColor ( gui_td_hudbox_date, BORDER_COLOUR ) ;
	TextDrawFont( gui_td_hudbox_date, 2);
	
	/*
	gui_td_infobox [ 0 ] = TextDrawCreate(636.333190, 280.255798 - GUI_VERTICAL_ADJUST, "cust_outeroutline");
	TextDrawLetterSize(gui_td_infobox [ 0 ], 0.000000, 17.963575 + 0.4);
	TextDrawTextSize(gui_td_infobox [ 0 ], 579.333129, 0.000000);
	TextDrawBackgroundColor(gui_td_infobox [ 0 ], 0x00000000 ) ;
	TextDrawUseBox(gui_td_infobox [ 0 ], true);
	TextDrawBoxColor(gui_td_infobox [ 0 ], 286331391);

	gui_td_infobox [ 1 ] = TextDrawCreate(634.333496, 282.744415 - GUI_VERTICAL_ADJUST, "cust_outlineinner");
	TextDrawLetterSize(gui_td_infobox [ 1 ], 0.000000, 17.364404 + 0.4);
	TextDrawTextSize(gui_td_infobox [ 1 ], 581.333374, 0.000000);
	TextDrawBackgroundColor(gui_td_infobox [ 1 ], 0x00000000 ) ;
	TextDrawUseBox(gui_td_infobox [ 1 ], true);
	TextDrawBoxColor(gui_td_infobox [ 1 ], BORDER_COLOUR);

	gui_td_infobox [ 2 ] = TextDrawCreate(633.666687, 283.574066 - GUI_VERTICAL_ADJUST, "cust_innerbox");
	TextDrawLetterSize(gui_td_infobox [ 2 ], 0.000000, 17.159463 + 0.4);
	TextDrawTextSize(gui_td_infobox [ 2 ], 582.000000, 0.000000);
	TextDrawBackgroundColor(gui_td_infobox [ 2 ], 0x00000000 ) ;
	TextDrawUseBox(gui_td_infobox [ 2 ], true);
	TextDrawBoxColor(gui_td_infobox [ 2 ], 286331391);

	gui_td_infobox_icons [ 0 ] = TextDrawCreate(599.5, 285.807250 - GUI_VERTICAL_ADJUST, "hud:radar_hostpital");
	TextDrawLetterSize(gui_td_infobox_icons [ 0 ], 0.473666, 1.828148);
	TextDrawTextSize(gui_td_infobox_icons [ 0 ], 17.999994, 18.251842);
	TextDrawFont(gui_td_infobox_icons [ 0 ], 4);
	
	gui_td_infobox_icons [ 1 ] = TextDrawCreate(599.5, 285.807250 - GUI_VERTICAL_ADJUST + GUI_VERTICAL_JUMP, "hud:radar_burgerShot");
	TextDrawLetterSize(gui_td_infobox_icons [ 1 ], 0.473666, 1.828148);
	TextDrawTextSize(gui_td_infobox_icons [ 1 ], 17.999994, 18.251842);
	TextDrawFont(gui_td_infobox_icons [ 1 ], 4);

	gui_td_infobox_icons [ 2 ] = TextDrawCreate(599.5, 285.807250 - GUI_VERTICAL_ADJUST + GUI_VERTICAL_JUMP * 2, "hud:radar_dateDrink");
	TextDrawLetterSize(gui_td_infobox_icons [ 2 ], 0.473666, 1.828148);
	TextDrawTextSize(gui_td_infobox_icons [ 2 ], 17.999994, 18.251842);
	TextDrawFont(gui_td_infobox_icons [ 2 ], 4);

	gui_td_infobox_text [ 0 ] = TextDrawCreate(585.999938, 306.963012 - GUI_VERTICAL_ADJUST, "HEALTH");
	TextDrawLetterSize(gui_td_infobox_text [ 0 ], 0.268333, 1.114666);
	TextDrawBackgroundColor(gui_td_infobox_text [ 0 ], 51);
	TextDrawColor ( gui_td_infobox_text [ 0 ], BORDER_COLOUR ) ;
	TextDrawFont(gui_td_infobox_text [ 0 ], 2);

	gui_td_infobox_text [ 1 ] = TextDrawCreate(585.999938, 306.963012 - GUI_VERTICAL_ADJUST + GUI_VERTICAL_JUMP, "HUNGER");
	TextDrawLetterSize(gui_td_infobox_text [ 1 ], 0.268333, 1.114666);
	TextDrawBackgroundColor(gui_td_infobox_text [ 1 ], 51);
	TextDrawColor ( gui_td_infobox_text [ 1 ], BORDER_COLOUR ) ;
	TextDrawFont(gui_td_infobox_text [ 1 ], 2);

	gui_td_infobox_text [ 2 ] = TextDrawCreate(589, 306.963012 - GUI_VERTICAL_ADJUST + GUI_VERTICAL_JUMP * 2, "THIRST");
	TextDrawLetterSize(gui_td_infobox_text [ 2 ], 0.268333, 1.114666);
	TextDrawBackgroundColor(gui_td_infobox_text [ 2 ], 51) ;
	TextDrawColor ( gui_td_infobox_text [ 2 ], BORDER_COLOUR ) ;
	TextDrawFont(gui_td_infobox_text [ 2 ], 2);

	gui_td_infobox_dividers [ 0 ] = TextDrawCreate(630.999816, 335.425903 - GUI_VERTICAL_ADJUST, "divider");
	TextDrawLetterSize(gui_td_infobox_dividers [ 0 ], 0.000000, -0.278394);
	TextDrawTextSize(gui_td_infobox_dividers [ 0 ], 584.000183, 0.000000);
	TextDrawUseBox(gui_td_infobox_dividers [ 0 ], true);
	TextDrawBoxColor(gui_td_infobox_dividers [ 0 ], BORDER_COLOUR);

	gui_td_infobox_dividers [ 1 ] = TextDrawCreate(630.999816, 335.425903 - GUI_VERTICAL_ADJUST + GUI_VERTICAL_JUMP, "divider");
	TextDrawLetterSize(gui_td_infobox_dividers [ 1 ], 0.000000, -0.278394);
	TextDrawTextSize(gui_td_infobox_dividers [ 1 ], 584.000183, 0.000000);
	TextDrawUseBox(gui_td_infobox_dividers [ 1 ], true);
	TextDrawBoxColor(gui_td_infobox_dividers [ 1 ], BORDER_COLOUR);
	*/

	guiTD[0] = TextDrawCreate(630.0000, 249.5000, "_");
	TextDrawFont(guiTD[0], 1);
	TextDrawLetterSize(guiTD[0], 0.0000, 18.3999);
	TextDrawColor(guiTD[0], -1);
	TextDrawSetShadow(guiTD[0], 0);
	TextDrawSetOutline(guiTD[0], 0);
	TextDrawBackgroundColor(guiTD[0], 255);
	TextDrawSetProportional(guiTD[0], 1);
	TextDrawUseBox(guiTD[0], 1);
	TextDrawBoxColor(guiTD[0], 286331391);
	TextDrawTextSize(guiTD[0], 590.0000, 0.0000);

	guiTD[1] = TextDrawCreate(629.0000, 251.0000, "_");
	TextDrawFont(guiTD[1], 1);
	TextDrawLetterSize(guiTD[1], 0.0000, 18.1000);
	TextDrawColor(guiTD[1], -1);
	TextDrawSetShadow(guiTD[1], 0);
	TextDrawSetOutline(guiTD[1], 0);
	TextDrawBackgroundColor(guiTD[1], 255);
	TextDrawSetProportional(guiTD[1], 1);
	TextDrawUseBox(guiTD[1], 1);
	TextDrawBoxColor(guiTD[1], -780181846);
	TextDrawTextSize(guiTD[1], 591.0000, 0.0000);

	guiTD[2] = TextDrawCreate(628.0000, 252.5000, "_");
	TextDrawFont(guiTD[2], 1);
	TextDrawLetterSize(guiTD[2], 0.0000, 17.7500);
	TextDrawColor(guiTD[2], -1);
	TextDrawSetShadow(guiTD[2], 0);
	TextDrawSetOutline(guiTD[2], 0);
	TextDrawBackgroundColor(guiTD[2], 255);
	TextDrawSetProportional(guiTD[2], 1);
	TextDrawUseBox(guiTD[2], 1);
	TextDrawBoxColor(guiTD[2], 286331391);
	TextDrawTextSize(guiTD[2], 592.0000, 0.0000);

	guiTD[3] = TextDrawCreate(625.0000, 291.5000, "_");
	TextDrawFont(guiTD[3], 1);
	TextDrawLetterSize(guiTD[3], 0.0000, -0.2500);
	TextDrawColor(guiTD[3], -1);
	TextDrawSetShadow(guiTD[3], 0);
	TextDrawSetOutline(guiTD[3], 0);
	TextDrawBackgroundColor(guiTD[3], 255);
	TextDrawSetProportional(guiTD[3], 1);
	TextDrawUseBox(guiTD[3], 1);
	TextDrawBoxColor(guiTD[3], -780181761);
	TextDrawTextSize(guiTD[3], 595.0000, 0.0000);

	guiTD[4] = TextDrawCreate(602.0000, 255.5000, "hud:radar_LocoSyndicate");
	TextDrawFont(guiTD[4], 4);
	TextDrawLetterSize(guiTD[4], 0.5000, 1.0000);
	TextDrawColor(guiTD[4], -1);
	TextDrawSetShadow(guiTD[4], 0);
	TextDrawSetOutline(guiTD[4], 0);
	TextDrawBackgroundColor(guiTD[4], 255);
	TextDrawSetProportional(guiTD[4], 1);
	TextDrawTextSize(guiTD[4], 15.0000, 15.0000);

	guiTD[5] = TextDrawCreate(619.5000, 271.0000, "TEMP");
	TextDrawFont(guiTD[5], 1);
	TextDrawLetterSize(guiTD[5], 0.2500, 1.0000);
	TextDrawAlignment(guiTD[5], 3);
	TextDrawColor(guiTD[5], -780181761);
	TextDrawSetShadow(guiTD[5], 0);
	TextDrawSetOutline(guiTD[5], 0);
	TextDrawBackgroundColor(guiTD[5], 255);
	TextDrawSetProportional(guiTD[5], 1);
	TextDrawTextSize(guiTD[5], 15.0000, 15.0000);

	guiTD[6] = TextDrawCreate(622.5000, 279.5000, "o");
	TextDrawFont(guiTD[6], 2);
	TextDrawLetterSize(guiTD[6], 0.1000, 0.6999);
	TextDrawAlignment(guiTD[6], 3);
	TextDrawColor(guiTD[6], -555819350);
	TextDrawSetShadow(guiTD[6], 0);
	TextDrawSetOutline(guiTD[6], 0);
	TextDrawBackgroundColor(guiTD[6], 255);
	TextDrawSetProportional(guiTD[6], 1);
	TextDrawTextSize(guiTD[6], 10.0000, 10.0000);

	guiTD[7] = TextDrawCreate(602.0000, 295.5000, "hud:radar_girlfriend");
	TextDrawFont(guiTD[7], 4);
	TextDrawLetterSize(guiTD[7], 0.5000, 1.0000);
	TextDrawColor(guiTD[7], -1);
	TextDrawSetShadow(guiTD[7], 0);
	TextDrawSetOutline(guiTD[7], 0);
	TextDrawBackgroundColor(guiTD[7], 255);
	TextDrawSetProportional(guiTD[7], 1);
	TextDrawTextSize(guiTD[7], 15.0000, 15.0000);

	guiTD[8] = TextDrawCreate(624.0000, 311.0000, "HEALTH");
	TextDrawFont(guiTD[8], 1);
	TextDrawLetterSize(guiTD[8], 0.2500, 1.0000);
	TextDrawAlignment(guiTD[8], 3);
	TextDrawColor(guiTD[8], -780181761);
	TextDrawSetShadow(guiTD[8], 0);
	TextDrawSetOutline(guiTD[8], 0);
	TextDrawBackgroundColor(guiTD[8], 255);
	TextDrawSetProportional(guiTD[8], 1);
	TextDrawTextSize(guiTD[8], 15.0000, 15.0000);

	guiTD[9] = TextDrawCreate(625.0000, 333.0000, "_");
	TextDrawFont(guiTD[9], 1);
	TextDrawLetterSize(guiTD[9], 0.0000, -0.2500);
	TextDrawColor(guiTD[9], -1);
	TextDrawSetShadow(guiTD[9], 0);
	TextDrawSetOutline(guiTD[9], 0);
	TextDrawBackgroundColor(guiTD[9], 255);
	TextDrawSetProportional(guiTD[9], 1);
	TextDrawUseBox(guiTD[9], 1);
	TextDrawBoxColor(guiTD[9], -780181761);
	TextDrawTextSize(guiTD[9], 595.0000, 0.0000);

	guiTD[10] = TextDrawCreate(602.0000, 337.0000, "hud:radar_burgerShot");
	TextDrawFont(guiTD[10], 4);
	TextDrawLetterSize(guiTD[10], 0.5000, 1.0000);
	TextDrawColor(guiTD[10], -1);
	TextDrawSetShadow(guiTD[10], 0);
	TextDrawSetOutline(guiTD[10], 0);
	TextDrawBackgroundColor(guiTD[10], 255);
	TextDrawSetProportional(guiTD[10], 1);
	TextDrawTextSize(guiTD[10], 15.0000, 15.0000);

	guiTD[11] = TextDrawCreate(624.0000, 352.5000, "HUNGER");
	TextDrawFont(guiTD[11], 1);
	TextDrawLetterSize(guiTD[11], 0.2249, 1.0000);
	TextDrawAlignment(guiTD[11], 3);
	TextDrawColor(guiTD[11], -780181761);
	TextDrawSetShadow(guiTD[11], 0);
	TextDrawSetOutline(guiTD[11], 0);
	TextDrawBackgroundColor(guiTD[11], 255);
	TextDrawSetProportional(guiTD[11], 1);
	TextDrawTextSize(guiTD[11], 15.0000, 15.0000);

	guiTD[12] = TextDrawCreate(625.0000, 374.0000, "_");
	TextDrawFont(guiTD[12], 1);
	TextDrawLetterSize(guiTD[12], 0.0000, -0.2500);
	TextDrawColor(guiTD[12], -1);
	TextDrawSetShadow(guiTD[12], 0);
	TextDrawSetOutline(guiTD[12], 0);
	TextDrawBackgroundColor(guiTD[12], 255);
	TextDrawSetProportional(guiTD[12], 1);
	TextDrawUseBox(guiTD[12], 1);
	TextDrawBoxColor(guiTD[12], -780181761);
	TextDrawTextSize(guiTD[12], 595.0000, 0.0000);

	guiTD[13] = TextDrawCreate(602.5000, 377.0000, "hud:radar_dateDrink");
	TextDrawFont(guiTD[13], 4);
	TextDrawLetterSize(guiTD[13], 0.5000, 1.0000);
	TextDrawColor(guiTD[13], -1);
	TextDrawSetShadow(guiTD[13], 0);
	TextDrawSetOutline(guiTD[13], 0);
	TextDrawBackgroundColor(guiTD[13], 255);
	TextDrawSetProportional(guiTD[13], 1);
	TextDrawTextSize(guiTD[13], 15.0000, 15.0000);

	guiTD[14] = TextDrawCreate(623.5000, 392.5000, "THIRST");
	TextDrawFont(guiTD[14], 1);
	TextDrawLetterSize(guiTD[14], 0.2500, 1.0000);
	TextDrawAlignment(guiTD[14], 3);
	TextDrawColor(guiTD[14], -780181761);
	TextDrawSetShadow(guiTD[14], 0);
	TextDrawSetOutline(guiTD[14], 0);
	TextDrawBackgroundColor(guiTD[14], 255);
	TextDrawSetProportional(guiTD[14], 1);
	TextDrawTextSize(guiTD[14], 15.0000, 15.0000);

	guiTD[15] = TextDrawCreate(623.5000, 238.0000, "PLAYER");
	TextDrawFont(guiTD[15], 1);
	TextDrawLetterSize(guiTD[15], 0.2500, 1.0000);
	TextDrawAlignment(guiTD[15], 3);
	TextDrawColor(guiTD[15], -780181761);
	TextDrawSetShadow(guiTD[15], 1);
	TextDrawSetOutline(guiTD[15], 0);
	TextDrawBackgroundColor(guiTD[15], 255);
	TextDrawSetProportional(guiTD[15], 1);
	TextDrawTextSize(guiTD[15], 0.0000, 0.0000);

	guiTD[16] = TextDrawCreate(634.5000, 434.5000, "You can use /hud to show/hide the player hud.");
	TextDrawFont(guiTD[16], 1);
	TextDrawLetterSize(guiTD[16], 0.2500, 1.0000);
	TextDrawAlignment(guiTD[16], 3);
	TextDrawColor(guiTD[16], -780181761);
	TextDrawSetShadow(guiTD[16], 1);
	TextDrawSetOutline(guiTD[16], 0);
	TextDrawBackgroundColor(guiTD[16], 255);
	TextDrawSetProportional(guiTD[16], 1);
	TextDrawTextSize(guiTD[16], 0.0000, 0.0000);

	return true ;
}


//LoadGUITextDraws ( playerid ) {
GUI_LoadPlayerPlayerDraws(playerid) {

	gui_td_hudbox_cash  = CreatePlayerTextDraw(playerid, 500, 85, " ");
	PlayerTextDrawLetterSize(playerid, gui_td_hudbox_cash  , 0.2, 0.9);
	PlayerTextDrawBackgroundColor(playerid, gui_td_hudbox_cash  , 51);
	PlayerTextDrawColor (playerid, gui_td_hudbox_cash  , MONEY_COLOUR ) ;
	PlayerTextDrawFont (playerid, gui_td_hudbox_cash  , 2);

	/*
	gui_td_playerHealth   = CreatePlayerTextDraw(playerid, 585.999938, 315.259185 - GUI_VERTICAL_ADJUST, "100%");
	PlayerTextDrawLetterSize(playerid, gui_td_playerHealth , 0.445666, 1.587555);
	PlayerTextDrawBackgroundColor(playerid, gui_td_playerHealth , 51);
	PlayerTextDrawColor ( playerid, gui_td_playerHealth , BORDER_COLOUR ) ;
	PlayerTextDrawFont(playerid, gui_td_playerHealth , 1);

	gui_td_playerHunger  = CreatePlayerTextDraw(playerid, 585.999938, 315.259185 - GUI_VERTICAL_ADJUST + GUI_VERTICAL_JUMP, "100%");
	PlayerTextDrawLetterSize(playerid, gui_td_playerHunger , 0.445666, 1.587555);
	PlayerTextDrawBackgroundColor(playerid, gui_td_playerHunger , 51);
	PlayerTextDrawColor ( playerid, gui_td_playerHunger , BORDER_COLOUR ) ;
	PlayerTextDrawFont(playerid, gui_td_playerHunger , 1);

	gui_td_playerThirst  = CreatePlayerTextDraw(playerid, 586.5, 315.259185 - GUI_VERTICAL_ADJUST + GUI_VERTICAL_JUMP * 2, "100%");
	PlayerTextDrawLetterSize(playerid, gui_td_playerThirst , 0.445666, 1.587555);
	PlayerTextDrawBackgroundColor(playerid, gui_td_playerThirst , 51);
	PlayerTextDrawColor ( playerid, gui_td_playerThirst , BORDER_COLOUR ) ;
	PlayerTextDrawFont(playerid, gui_td_playerThirst , 1);
	*/

	guiPTD[0] = CreatePlayerTextDraw(playerid, 619.5000, 279.0000, "150F"); //temp
	PlayerTextDrawFont(playerid, guiPTD[0], 2);
	PlayerTextDrawLetterSize(playerid, guiPTD[0], 0.2500, 1.0000);
	PlayerTextDrawAlignment(playerid, guiPTD[0], 3);
	PlayerTextDrawColor(playerid, guiPTD[0], -555819350);
	PlayerTextDrawSetShadow(playerid, guiPTD[0], 0);
	PlayerTextDrawSetOutline(playerid, guiPTD[0], 0);
	PlayerTextDrawBackgroundColor(playerid, guiPTD[0], 255);
	PlayerTextDrawSetProportional(playerid, guiPTD[0], 1);
	PlayerTextDrawTextSize(playerid, guiPTD[0], 10.0000, 10.0000);

	guiPTD[1] = CreatePlayerTextDraw(playerid, 618.5000, 320.5000, "100"); //hp
	PlayerTextDrawFont(playerid, guiPTD[1], 2);
	PlayerTextDrawLetterSize(playerid, guiPTD[1], 0.2500, 1.0000);
	PlayerTextDrawAlignment(playerid, guiPTD[1], 3);
	PlayerTextDrawColor(playerid, guiPTD[1], -555819350);
	PlayerTextDrawSetShadow(playerid, guiPTD[1], 0);
	PlayerTextDrawSetOutline(playerid, guiPTD[1], 0);
	PlayerTextDrawBackgroundColor(playerid, guiPTD[1], 255);
	PlayerTextDrawSetProportional(playerid, guiPTD[1], 1);
	PlayerTextDrawTextSize(playerid, guiPTD[1], 10.0000, 10.0000);

	guiPTD[2] = CreatePlayerTextDraw(playerid, 618.5000, 361.5000, "100"); //hunger
	PlayerTextDrawFont(playerid, guiPTD[2], 2);
	PlayerTextDrawLetterSize(playerid, guiPTD[2], 0.2500, 1.0000);
	PlayerTextDrawAlignment(playerid, guiPTD[2], 3);
	PlayerTextDrawColor(playerid, guiPTD[2], -555819350);
	PlayerTextDrawSetShadow(playerid, guiPTD[2], 0);
	PlayerTextDrawSetOutline(playerid, guiPTD[2], 0);
	PlayerTextDrawBackgroundColor(playerid, guiPTD[2], 255);
	PlayerTextDrawSetProportional(playerid, guiPTD[2], 1);
	PlayerTextDrawTextSize(playerid, guiPTD[2], 10.0000, 10.0000);

	guiPTD[3] = CreatePlayerTextDraw(playerid, 618.5000, 401.0000, "100"); //thirst
	PlayerTextDrawFont(playerid, guiPTD[3], 2);
	PlayerTextDrawLetterSize(playerid, guiPTD[3], 0.2500, 1.0000);
	PlayerTextDrawAlignment(playerid, guiPTD[3], 3);
	PlayerTextDrawColor(playerid, guiPTD[3], -555819350);
	PlayerTextDrawSetShadow(playerid, guiPTD[3], 0);
	PlayerTextDrawSetOutline(playerid, guiPTD[3], 0);
	PlayerTextDrawBackgroundColor(playerid, guiPTD[3], 255);
	PlayerTextDrawSetProportional(playerid, guiPTD[3], 1);
	PlayerTextDrawTextSize(playerid, guiPTD[3], 10.0000, 10.0000);	

	LoadWeaponGUI ( playerid ) ;
}

DestroyGUITextDraws ( playerid ) {

	HideGUITextDraws ( playerid ) ;
	DestroyWeaponPanel ( playerid ) ;

	PlayerTextDrawDestroy(playerid, gui_td_hudbox_cash  ) ;
	//PlayerTextDrawDestroy(playerid, guiPTD[1]  ) ;
	//PlayerTextDrawDestroy(playerid, guiPTD[2]  ) ;
	//PlayerTextDrawDestroy(playerid, guiPTD[3]  ) ;

	return true ;
}

DestroyWeaponPanel ( playerid ) {

	for ( new i; i < GUI_MAX_BULLETS; i ++ ) {
		PlayerTextDrawDestroy ( playerid, gui_td_hudbox_gunbullet [ i ]  ) ;
	}

	for ( new i; i < GUI_MAX_HUDBOX; i ++ ) {
		PlayerTextDrawDestroy ( playerid, gui_td_hudbox_gunname [ i ]  ) ;
	}

	PlayerTextDrawDestroy ( playerid, gui_td_hudbox_gunmodel  ) ;
	PlayerTextDrawDestroy ( playerid, gui_td_hudbox_bulletinfo  ) ;

	return true ;
}

GUI_DestroyPlayerPlayerDraws(playerid) {

	for ( new i, j = sizeof ( guiPTD ); i < j ; i ++ ) {

		PlayerTextDrawDestroy ( playerid, guiPTD [ i ] ) ;
	}

	DestroyGUITextDraws ( playerid );

	return true ;
}

GUI_ShowPlayerPlayerDraws(playerid) {

	for ( new i, j = sizeof ( guiPTD ); i < j ; i ++ ) {

		PlayerTextDrawShow ( playerid, guiPTD [ i ] ) ;
	}

	return true ;
}

GUI_HidePlayerPlayerDraws(playerid) {

	for ( new i, j = sizeof ( guiPTD ); i < j ; i ++ ) {

		PlayerTextDrawHide ( playerid, guiPTD [ i ] ) ;
	}

	return true ;
}

GUI_ShowHorsePlayerDraws(playerid) {

	for ( new i, j = sizeof ( horseguiTD ); i < j ; i ++ ) {

		TextDrawShowForPlayer(playerid,horseguiTD[i]);
	}
	for ( new i, j = sizeof ( horseguiPTD ); i < j ; i ++ ) {

		PlayerTextDrawShow ( playerid, horseguiPTD [ i ] ) ;
	}

	return true ;
}

GUI_HideHorsePlayerDraws(playerid) {

	for ( new i, j = sizeof ( horseguiTD ); i < j ; i ++ ) {

		TextDrawHideForPlayer(playerid,horseguiTD[i]);
	}
	for ( new i, j = sizeof ( horseguiPTD ); i < j ; i ++ ) {

		PlayerTextDrawHide ( playerid, horseguiPTD [ i ] ) ;
	}

	return true ;
}

GUI_DestroyHorsePlayerDraws(playerid) {

	for ( new i, j = sizeof ( horseguiPTD ); i < j ; i ++ ) {

		PlayerTextDrawDestroy ( playerid, horseguiPTD [ i ] ) ;
	}

	return true ;
}

GUI_LoadPlayerHorseDraws(playerid) {

	horseguiPTD[0] = CreatePlayerTextDraw(playerid, 566.0000, 403.0000, "100");
	PlayerTextDrawFont(playerid, horseguiPTD[0], 2);
	PlayerTextDrawLetterSize(playerid, horseguiPTD[0], 0.2500, 1.0000);
	PlayerTextDrawAlignment(playerid, horseguiPTD[0], 2);
	PlayerTextDrawColor(playerid, horseguiPTD[0], -555819350);
	PlayerTextDrawSetShadow(playerid, horseguiPTD[0], 0);
	PlayerTextDrawSetOutline(playerid, horseguiPTD[0], 0);
	PlayerTextDrawBackgroundColor(playerid, horseguiPTD[0], 255);
	PlayerTextDrawSetProportional(playerid, horseguiPTD[0], 1);
	PlayerTextDrawTextSize(playerid, horseguiPTD[0], 0.0000, 0.0000);

	horseguiPTD[1] = CreatePlayerTextDraw(playerid, 525.0000, 403.0000, "100");
	PlayerTextDrawFont(playerid, horseguiPTD[1], 2);
	PlayerTextDrawLetterSize(playerid, horseguiPTD[1], 0.2500, 1.0000);
	PlayerTextDrawAlignment(playerid, horseguiPTD[1], 2);
	PlayerTextDrawColor(playerid, horseguiPTD[1], -555819350);
	PlayerTextDrawSetShadow(playerid, horseguiPTD[1], 0);
	PlayerTextDrawSetOutline(playerid, horseguiPTD[1], 0);
	PlayerTextDrawBackgroundColor(playerid, horseguiPTD[1], 255);
	PlayerTextDrawSetProportional(playerid, horseguiPTD[1], 1);
	PlayerTextDrawTextSize(playerid, horseguiPTD[1], 0.0000, 0.0000);

	return true ;
}

GUI_LoadStaticHorseDraws() {

	horseguiTD[0] = TextDrawCreate(591.5000, 376.0000, "_");
	TextDrawFont(horseguiTD[0], 1);
	TextDrawLetterSize(horseguiTD[0], 0.5000, 4.4000);
	TextDrawColor(horseguiTD[0], -1);
	TextDrawSetShadow(horseguiTD[0], 0);
	TextDrawSetOutline(horseguiTD[0], 0);
	TextDrawBackgroundColor(horseguiTD[0], 255);
	TextDrawSetProportional(horseguiTD[0], 1);
	TextDrawUseBox(horseguiTD[0], 1);
	TextDrawBoxColor(horseguiTD[0], 286331391);
	TextDrawTextSize(horseguiTD[0], 503.0000, 0.0000);

	horseguiTD[1] = TextDrawCreate(590.0000, 377.5000, "_");
	TextDrawFont(horseguiTD[1], 1);
	TextDrawLetterSize(horseguiTD[1], 0.5000, 4.0999);
	TextDrawColor(horseguiTD[1], -1);
	TextDrawSetShadow(horseguiTD[1], 0);
	TextDrawSetOutline(horseguiTD[1], 0);
	TextDrawBackgroundColor(horseguiTD[1], 255);
	TextDrawSetProportional(horseguiTD[1], 1);
	TextDrawUseBox(horseguiTD[1], 1);
	TextDrawBoxColor(horseguiTD[1], -780181846);
	TextDrawTextSize(horseguiTD[1], 504.0000, 0.0000);

	horseguiTD[2] = TextDrawCreate(589.5000, 379.0000, "_");
	TextDrawFont(horseguiTD[2], 1);
	TextDrawLetterSize(horseguiTD[2], 0.5000, 3.7999);
	TextDrawColor(horseguiTD[2], -1);
	TextDrawSetShadow(horseguiTD[2], 0);
	TextDrawSetOutline(horseguiTD[2], 0);
	TextDrawBackgroundColor(horseguiTD[2], 255);
	TextDrawSetProportional(horseguiTD[2], 1);
	TextDrawUseBox(horseguiTD[2], 1);
	TextDrawBoxColor(horseguiTD[2], 286331391);
	TextDrawTextSize(horseguiTD[2], 505.5000, 0.0000);

	horseguiTD[3] = TextDrawCreate(545.0000, 381.0000, "_");
	TextDrawFont(horseguiTD[3], 1);
	TextDrawLetterSize(horseguiTD[3], 0.5000, 3.2500);
	TextDrawColor(horseguiTD[3], -1);
	TextDrawSetShadow(horseguiTD[3], 0);
	TextDrawSetOutline(horseguiTD[3], 0);
	TextDrawBackgroundColor(horseguiTD[3], 255);
	TextDrawSetProportional(horseguiTD[3], 1);
	TextDrawUseBox(horseguiTD[3], 1);
	TextDrawBoxColor(horseguiTD[3], -780181761);
	TextDrawTextSize(horseguiTD[3], 543.0000, 0.0000);

	horseguiTD[4] = TextDrawCreate(556.5000, 379.5000, "hud:radar_airYard");
	TextDrawFont(horseguiTD[4], 4);
	TextDrawLetterSize(horseguiTD[4], 0.5000, 1.0000);
	TextDrawColor(horseguiTD[4], -1);
	TextDrawSetShadow(horseguiTD[4], 0);
	TextDrawSetOutline(horseguiTD[4], 0);
	TextDrawBackgroundColor(horseguiTD[4], 255);
	TextDrawSetProportional(horseguiTD[4], 1);
	TextDrawUseBox(horseguiTD[4], 1);
	TextDrawBoxColor(horseguiTD[4], -780181761);
	TextDrawTextSize(horseguiTD[4], 15.0000, 15.0000);

	horseguiTD[5] = TextDrawCreate(548.0000, 394.5000, "STAMINA");
	TextDrawFont(horseguiTD[5], 1);
	TextDrawLetterSize(horseguiTD[5], 0.2500, 1.0000);
	TextDrawColor(horseguiTD[5], -780181761);
	TextDrawSetShadow(horseguiTD[5], 0);
	TextDrawSetOutline(horseguiTD[5], 0);
	TextDrawBackgroundColor(horseguiTD[5], 255);
	TextDrawSetProportional(horseguiTD[5], 1);
	TextDrawTextSize(horseguiTD[5], 0.0000, 0.0000);

	horseguiTD[6] = TextDrawCreate(517.0000, 379.5000, "hud:radar_hostpital");
	TextDrawFont(horseguiTD[6], 4);
	TextDrawLetterSize(horseguiTD[6], 0.5000, 1.0000);
	TextDrawColor(horseguiTD[6], -1);
	TextDrawSetShadow(horseguiTD[6], 0);
	TextDrawSetOutline(horseguiTD[6], 0);
	TextDrawBackgroundColor(horseguiTD[6], 255);
	TextDrawSetProportional(horseguiTD[6], 1);
	TextDrawUseBox(horseguiTD[6], 1);
	TextDrawBoxColor(horseguiTD[6], -780181761);
	TextDrawTextSize(horseguiTD[6], 15.0000, 15.0000);

	horseguiTD[7] = TextDrawCreate(510.5000, 394.5000, "HEALTH");
	TextDrawFont(horseguiTD[7], 1);
	TextDrawLetterSize(horseguiTD[7], 0.2500, 1.0000);
	TextDrawColor(horseguiTD[7], -780181761);
	TextDrawSetShadow(horseguiTD[7], 0);
	TextDrawSetOutline(horseguiTD[7], 0);
	TextDrawBackgroundColor(horseguiTD[7], 255);
	TextDrawSetProportional(horseguiTD[7], 1);
	TextDrawTextSize(horseguiTD[7], 0.0000, 0.0000);

	horseguiTD[8] = TextDrawCreate(506.5000, 365.0000, "HORSE INFORMATION");
	TextDrawFont(horseguiTD[8], 1);
	TextDrawLetterSize(horseguiTD[8], 0.2300, 1.0000);
	TextDrawColor(horseguiTD[8], -780181761);
	TextDrawSetShadow(horseguiTD[8], 1);
	TextDrawSetOutline(horseguiTD[8], 0);
	TextDrawBackgroundColor(horseguiTD[8], 255);
	TextDrawSetProportional(horseguiTD[8], 1);
	TextDrawTextSize(horseguiTD[8], 750.0000, 0.0000);

	return true ;
}