//#define OPEN_BETA_TEST
//#define UNLOCK_SERVER

#if defined OPEN_BETA_TEST
	#warning WARNING: SCRIPT IS IN OPEN BETA MODE
	#warning WARNING: SCRIPT IS IN OPEN BETA MODE
	#warning WARNING: SCRIPT IS IN OPEN BETA MODE
#endif

#if !defined LOG_NEEDED
	#define LOG_NEEDED:%9\32;%0\10;%1 { new LOG_NEEDED; print("LOG_NEEDED: \"%0\""); }
#endif

new PLAYER_MOTD [ 256 ] = "Welcome to Wild West Role Play - the reopening!";
new STAFF_MOTD [ 256 ] = "You can now use {D9AF79}/asoil{DEDEDE} and {D9AF79}/atrap{DEDEDE} to easily moderate the new farming and trap systems." ;

#include <a_samp>
#include <fixes>
//#include <profiler>
#pragma disablerecursion

#define IsValidSkin%1(%0)	(((%0)<=299)&&((%0)>=0)&&((%0)!=74))

#undef MAX_PLAYERS
#define MAX_PLAYERS 100
#define MAX_ATTACHMENTS (5)


#define HOLDING(%0) ((newkeys & (%0)) == (%0))
#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define PRESSING(%0, %1) (%0 & (%1))
#define RELEASED(%0) ((( newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == ( %0 )))

#define IsPlayerSpawned(%0)    Tryg3D::IsPlayerSpawned(%0)

// YSI stuff
#include <YSI\y_timers>
#include <foreach>
//#include <dialogs>
#include <PreviewModelDialog>
#include <YSI\y_dialog>
#include <YSI\y_inline>

// Primary includes
#include <safeDialogs>
//#include <YSF>
//#include <callbacks>
#include <zcmd>
#include <sscanf2>
#include <progress2>
#include <filemanager>

#include <TimeStampToDate>
#include <ww_timestamp>
#include <callbacks>
#define ENABLE_3D_TRYG_YSI_SUPPORT
#include <3DTryg>

// Object stuff
#define STREAMER_USE_DYNAMIC_TEXT3D_TAG
#include <streamer>

/*
#if defined STREAMER_OBJECT_SD
#undef STREAMER_OBJECT_SD
#define STREAMER_OBJECT_SD 900.0
#endif
*/
#define GetDynamicObjectModel(%0) Streamer_GetIntData(STREAMER_TYPE_OBJECT, %0, E_STREAMER_MODEL_ID)

#include <ColAndreas>
#include <easybmp>	
#include <virtualcanvas>
#include <zmessage>	

// Custom ww includes
#include <ww_mysql>
#include <strlib> // sprintf and strtrim
#include <ww_angles>
#include <iptrace> // ip lookup script (http://forum.sa-mp.com/showthread.php?t=607276 - author: Banana_Ghost)

//     #include <discord-connector>

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define SERVER_SPAWN_X      	(-1358.9551)
#define SERVER_SPAWN_Y      	(2612.5303)
#define SERVER_SPAWN_Z      	(53.5066)
#define SERVER_SPAWN_A      	(51.7536)

#if defined OPEN_BETA_TEST
	#define SERVER_HOSTNAME			"Wild West Roleplay - Open Beta [ENG]"
#else
	#define SERVER_HOSTNAME   		"[0.3.DL] Wild West Roleplay"
#endif

#define SERVER_MODE       		"WW-RP v0.2.9b"
#define SERVER_MAP		    	"Tumbleweed v1.1"
#define SERVER_WEBSITE	    	"forum.wildwest-roleplay.com"

#define COLOR_DEFAULT     		(0xDEDEDEFF)
#define COLOR_CLIENT      		(0xAAC4E5FF)
#define COLOR_ACTION      		(0xC2A2DAAA)
#define COLOR_OOC         		(0xAAC4E5FF)

#define COLOR_RED    			(0xFF6347FF)
#define COLOR_YELLOW      		(0xFFFF00FF)
#define COLOR_ORANGE      		(0xFFA500FF)
#define COLOR_BLUE				(0x007FFFFF)
#define COLOR_GREY		  		(0x999999FF)
#define COLOR_GREEN				(0x629C5CFF)

#define COLOR_TAB0				(0x6B5538FF)
#define COLOR_TAB1				(0xBA9E72FF)
#define COLOR_TAB2				(0xDEBD8AFF)

#define ADMIN_RED				(0xCF4040FF)
#define ADMIN_ORANGE    		(0xFFA600FF)
#define ADMIN_YELLOW    		(0xFFF000FF)
#define ADMIN_BLUE      		(0x00A4DBAA)
#define ADMIN_GRAY      		(0x9C9C9CFF)
#define ADMIN_LIGHTGREY     	(0xC4C4C4FF)

#define COLOR_DONATOR			(0xB59664FF)

// Staff-only colors:	
#define COLOR_STAFF				( 0x59BD93FF ) 
#define MODERATOR_COLOR			( 0x449C44FF ) // 408040
#define SUPPORTER_COLOR			( 0x44639CFF )
#define MANAGER_COLOR			( 0xAD2D2DFF )

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

enum { // attachments
	ATTACH_SLOT_MASK = 5,
	ATTACH_SLOT_HORSE = 6,
	ATTACH_SLOT_EQUIP = 6,
	ATTACH_SLOT_PANTS = 7,
	ATTACH_SLOT_BACK = 8,
	ATTACH_SLOT_HANDS = 9
}

enum {

	MOD_WARNING_LOW,
	MOD_WARNING_MED,
	MOD_WARNING_HIGH
}

enum {

	MONEY_SLOT_HAND,
	MONEY_SLOT_BANK,
	MONEY_SLOT_PAYC
}

enum {

	ARECORD_TYPE_KICK,
	ARECORD_TYPE_AJAIL,
	ARECORD_TYPE_BAN
}

enum {
	STAFF_NONE,
	STAFF_SUPPORTER,
	STAFF_MODERATOR,
	STAFF_MANAGER
} ;

enum {
	GROUP_NONE = 0,
	TRIAL_MOD = 1,
	BASIC_MOD = 2,
	GENERAL_MOD = 3,
	ADVANCED_MOD = 4
} ;


enum { // Donator levels
	DONATOR_NONE,
	DONATOR_BRONZE,
	DONATOR_SILVER,
	DONATOR_GOLD
} ;

new EquippedItem [ MAX_PLAYERS ] ;
new EquippedItemTile [ MAX_PLAYERS ] ;

new IsPlayerOnAdminDuty [ MAX_PLAYERS ] ;
new IsPlayerOOC 		[ MAX_PLAYERS ] ; 

new bool: IsPlayerInLassoMode [MAX_PLAYERS] = false;
new bool: IsPlayerOnLassoCooldown[MAX_PLAYERS] = false;
new bool: IsPlayerInLasso[MAX_PLAYERS];
new LassoModeTarget [ MAX_PLAYERS ];

new bool:ToggleOOCChat = false;
new IsPlayerHidingOOC [ MAX_PLAYERS ] ;
new PlayerModPMWarning [ MAX_PLAYERS ] = false ;

new ToggleHorseSound [ MAX_PLAYERS ] ;
new zone_Sawmill ;

new HudHidden[MAX_PLAYERS];

// Job vars
new bool: IsMining[MAX_PLAYERS] ;
new bool: IsFishing [ MAX_PLAYERS ] ; 
new bool: IsCuttingTree[MAX_PLAYERS] ;
new bool: IsPlayerFishing [ MAX_PLAYERS ] ;
new Widllife_Harvest_Value [ MAX_PLAYERS ] ;

new LastPaycheckGiven [ MAX_PLAYERS ] ;

// /helpup cmds
new PlayerHelpUpCooldown [ MAX_PLAYERS ] ;
new PlayerRecentlyRevived [ MAX_PLAYERS ] ;

// trap check
new IsPlayerTrapped [MAX_PLAYERS];

// Poker system
#define IsPlayerPlayingPoker(%0) (GetPVarInt(%0,"t_is_in_table"))

#include "assets/header.pwn"

#include "func/nametags/core.pwn"
#include "utils/msgs/core.pwn"
#include "func/misc/func/time.pwn"
#include "func/action_panel.pwn"

// Stores inventory items in an array
//#include "data/inv/func/store.pwn"
#include "data/inv/data/items/data.pwn"


#include "data/account/core.pwn" // account module 
#include "data/skills/core.pwn" // skills module

#include "utils/misc/core.pwn"
#include "utils/horse/base.pwn" // horse
#include "func/anims/core.pwn"
#include "utils/zones/core.pwn" // zones, ambient, weather
#include "func/campfires/header.pwn" //campfires
#include "func/labels/header.pwn" //dynamic labels

#include "data/weps/core.pwn"
#include "data/weps/illegal.pwn"
#include "func/injury/core.pwn" // dmg module
#include "data/staff/core.pwn" // staff module

#include "data/farm/core.pwn" // inv module 
#include "data/inv/core.pwn" // inv module 

#include "data/points/core.pwn" // point
#include "data/points/func/motel.pwn" // point
#include "data/posse/core.pwn"
#include "data/actors/core.pwn"
#include "data/money.pwn"
#include "utils/inv/core.pwn" // handles support-code for inventory script


#include "utils/gui/core.pwn"
#include "func/jobs/core.pwn"
//#include "data/account/ext/tutorial.pwn"

#include "func/misc/core.pwn"
#include "func/object/core.pwn" // object module
#include "func/roleplay_chat.pwn" // ingame RP cmds

#include "func/anticheat/core.pwn"

#include "data/account/func/spawn.pwn"
#include "data/account/func/data.pwn"

#include "utils/transport.pwn"
#include "utils/sessions.pwn"
#include "func/lottery/core.pwn"

#include "func/attachments/core.pwn"

#include "aris/main.pwn"
#include "dignity/main.pwn"


#include "games/blackjack.pwn"
#include "games/poker.pwn"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


main () {

	//Profiler_Start() ;

	mysql_log(LOG_ALL);

	MySQL_Init ("wwrp") ;
	Init_Zones () ;

	// We load these before ObjectHandler because
	// it needs to clear data before ObjectHandler to work
	Init_MiningRocks () ;
	Init_WoodcutTrees () ;
	Init_GunCreationArea ( ) ;

	ObjectHandler () ; // handles object stuff (foilage, maploader, roads & removeobjects )
	LoadIntroMap ( ) ; // loads character selection map

	LoadAnimTextDraw ( ) ;
	LoadFaderTextdraw () ;
	//LoadStaticGUITextDraw ( ) ;

	LoadStaticCreationTextDraws () ;
	LoadStaticCharacterSelectDraws ( ) ;
	LoadStaticInventoryExamineGUI ( )  ;
	LoadStaticInventoryTextDraws () ;
	LoadActionGUITextDraws ( ) ;

	LoadHorseSprintTextDraw () ;
	LoadHorseHealthTextDraw () ;
	LoadFurnTextureTD();
	Blackjack_CreateStaticGUI(); 
	//LoadBloodSplatTextures () ;

	// Random stuff:
	ManualVehicleEngineAndLights(), EnableVehicleFriendlyFire();
    DisableInteriorEnterExits(), AllowInteriorWeapons(false);
	DisableNameTagLOS(), ShowNameTags(true);

	ShowNameTags(0); // handles custom name script

	// Anti object removal fix
	Nametags_Init () ;
	GunShells_Init () ;
	Init_Horses () ;
	Init_WantedPosterObjects () ;

    EnableStuntBonusForAll(false);
	SetGameModeText(SERVER_MODE);

	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);

	SendRconCommand("hostname   "SERVER_HOSTNAME"");
	SendRconCommand("mapname 	"SERVER_MAP"	");
	SendRconCommand("weburl 	"SERVER_WEBSITE"");
	#if defined UNLOCK_SERVER
		SendRconCommand("password 0");
	#endif

	// Clearing data for FindEmptyGunSlot
	for ( new i; i < MAX_DROPPED_WEAPONS; i ++ ) {
		
		DroppedWeapon [ i ] = -1 ;
	}

	// Clearing wanted poster data
	for ( new i; i < MAX_POSTERS; i ++ ) {

		WantedPoster [ i ] [ poster_id ] = -1 ;
	}

	// Clearing corpse data
	for ( new i; i < MAX_CORPSES; i ++ ) {

		Corpse [ i ] [ corpse_id ] = -1 ;
	}
	
	// Clearing wound data
	ClearWoundData ( ) ;

	Init_Deers () ;
	Init_Points () ; 
	Init_Furniture();
	Init_LoadActors () ; 
	Init_LoadPosses ( ) ;
	Init_LoadKiosks ( ) ;
	Init_LoadTransmittors ( ) ;
	Init_LoadWantedPosters () ;
	Init_LoadDropItems () ;
	Init_ServerTime () ;

	Init_Motels () ;
	Init_TransportPoints () ;
	Init_TaskLabels ( ) ;
	Init_Fires () ;
	Init_SoilData () ;

	Init_LoadLottery () ;
	Init_Traps();

	// Inv
	Init_LoadDropItems () ;

	Init_LoadPokerTables();

	//dynamic labels
	Init_DynamicLabels();

	// clear dynamite data
	SetupDynamiteData () ; 

	SendASCIILogo () ; // always be last

	// Tutorial label:
	CreateDynamic3DTextLabel("[0] [{DEDEDE}Fishing Rod{A3A3A3}]{DEDEDE}\nPress ~k~~SNEAK_ABOUT~ to pick up.", 0xA3A3A3FF, -1998.5022, -1483.7417, 84.1043, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0 ) ;
	//CreateDynamic3DTextLabel("[Prison Processing Area]\n{DEDEDE}Use /prison to arrest someone.", COLOR_BLUE, -777.8737,769.9468,21.0923, 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0 ) ;

	// Bayside fixes to prevent unsolid ground
	new txt_map = CreateDynamicObject(18765, -2374.22510, 2448.69238, 6.13586,   4.00000, 0.00000, -20.82000);
	SetDynamicObjectMaterial(txt_map, 0, 0, "INVALID", "INVALID", 0xFFFFFFFF);
	txt_map = CreateDynamicObject(18765, -2373.52515, 2450.62109, 6.26575,   4.00000, 0.00000, -20.82000);
	SetDynamicObjectMaterial(txt_map, 0, 0, "INVALID", "INVALID", 0xFFFFFFFF);
	txt_map = CreateDynamicObject(18765, -2381.47583, 2451.66675, 6.33982,   3.10000, 0.00000, -20.82000);
	SetDynamicObjectMaterial(txt_map, 0, 0, "INVALID", "INVALID", 0xFFFFFFFF);
	txt_map = CreateDynamicObject(18765, -2380.72876, 2453.36548, 6.33982,   3.10000, 0.00000, -20.82000);
	SetDynamicObjectMaterial(txt_map, 0, 0, "INVALID", "INVALID", 0xFFFFFFFF);
	txt_map = CreateDynamicObject(18765, -2387.30884, 2453.85156, 6.23220,   3.60000, -2.00000, -20.82000);
	SetDynamicObjectMaterial(txt_map, 0, 0, "INVALID", "INVALID", 0xFFFFFFFF);
	txt_map = CreateDynamicObject(18765, -2386.40771, 2455.90161, 6.45519,   3.60000, -2.00000, -20.82000);
	SetDynamicObjectMaterial(txt_map, 0, 0, "INVALID", "INVALID", 0xFFFFFFFF);
	txt_map = CreateDynamicObject(18765, -2422.45166, 2454.12012, 9.74985,   0.00000, 0.00000, 1.08000);
	SetDynamicObjectMaterial(txt_map, 0, 0, "INVALID", "INVALID", 0xFFFFFFFF);
	txt_map = CreateDynamicObject(18765, -2412.58911, 2454.33521, 9.74985,   0.00000, 0.00000, 1.08000);
	SetDynamicObjectMaterial(txt_map, 0, 0, "INVALID", "INVALID", 0xFFFFFFFF);
	txt_map = CreateDynamicObject(18765, -2415.81689, 2457.26074, 9.74985,   0.00000, 0.00000, 1.08000);
	SetDynamicObjectMaterial(txt_map, 0, 0, "INVALID", "INVALID", 0xFFFFFFFF);
	txt_map = CreateDynamicObject(18765, -2418.35571, 2455.53979, 9.74985,   0.00000, 0.00000, 1.08000);	
	SetDynamicObjectMaterial(txt_map, 0, 0, "INVALID", "INVALID", 0xFFFFFFFF);


	zone_Sawmill = CreateDynamicRectangle(-829, 919.5, -776, 964.5);

	Streamer_SetVisibleItems(STREAMER_TYPE_OBJECT,1999);
	//Streamer_SetRadiusMultiplier(STREAMER_TYPE_OBJECT,1.75);

	return true ;
}

ShowBETAMessage(playerid) { 

	ZMsg_SendClientMessage(playerid,-1,"--------------------{FF6347}OPEN BETA MESSAGE{FFFFFF}--------------------");
	ZMsg_SendClientMessage(playerid,-1,"You are currently participating in the open beta for Wild West Roleplay.  Please understand that there may be bugs that you experience during your time here and that we'd greatly appreciate it if you report any bugs you find during the beta.");
	ZMsg_SendClientMessage(playerid,-1,"This is not a final representation of the server and that any and all features/systems that make up the server are subject to change.  Rules still apply during this open beta and ignorance of that fact will result in punishment.");
	ZMsg_SendClientMessage(playerid,-1,"We hope that you have a wonderful experience during the open beta and hope to see you for when the server officially launches.");
	ZMsg_SendClientMessage(playerid,-1,"Sincerly:");
	ZMsg_SendClientMessage(playerid,-1,"Wild West Roleplay Staff Team");
	ZMsg_SendClientMessage(playerid,-1,"--------------------{FF6347}OPEN BETA MESSAGE{FFFFFF}--------------------");
}

public OnGameModeExit () {

	//Profiler_Dump () ;
	return true ;
}

public OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid) {

	if ( areaid == zone_Sawmill ) {
		PlayAudioStreamForPlayer(playerid, "http://play.wildwest-roleplay.com/jobs/sawmill.mp3") ;
	}
	
	#if defined main_OnPlayerEnterDynamicArea
		return main_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif

#define OnPlayerEnterDynamicArea main_OnPlayerEnterDynamicArea
#if defined main_OnPlayerEnterDynamicArea
	forward main_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid);
#endif

public OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid) {


	if ( areaid == zone_Sawmill ) {

		return cmd_resyncambient(playerid,"");
	}

	#if defined main_OnPlayerLeaveDynamicArea
		return main_OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLeaveDynamicArea
	#undef OnPlayerLeaveDynamicArea
#else
	#define _ALS_OnPlayerLeaveDynamicArea
#endif

#define OnPlayerLeaveDynamicArea main_OnPlayerLeaveDynamicArea
#if defined main_OnPlayerLeaveDynamicArea
	forward main_OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid);
#endif


ptask Auto_StreamerUpdate[15000](playerid) {

	if ( IsPlayerPlayingPoker(playerid)) {

		return false ;
	}

	return Streamer_Update ( playerid ) ;
}

IsPlayerFree ( playerid ) {

	if ( IsPlayerPlayingPoker(playerid) || IsPlayerInAdminJail [ playerid ] || Character [ playerid ] [ character_dmgmode ] || IsPlayerRidingHorse [ playerid ] || IsPlayerTackled [ playerid ] ) {

		return false ;
	}

	return true ;
}

new PingTicker [ MAX_PLAYERS ],
	PacketLossTicker [ MAX_PLAYERS ] ;


ptask PingWarningClear[120000](playerid) {

////	print("PingWarningClear timer called (main.pwn)");

	if (! PingTicker [ playerid ] ) {

		PingTicker [ playerid ] = 0 ;
	}

	if ( ! PacketLossTicker [ playerid ] ) {

		PacketLossTicker [ playerid ] = 0 ;
	}
 
	return true ;
}

ptask CheckPacketLoss[300000](playerid) {

////	print("CheckPacketLoss timer called (main.pwn)");

	if ( playerid != INVALID_PLAYER_ID && NetStats_PacketLossPercent(playerid) > 10.0 ) {

		SendClientMessage ( playerid, COLOR_RED, sprintf("You're desynced! Packets lost: %.2f percent.", NetStats_PacketLossPercent ( playerid ) ) ) ;

		SendModeratorWarning ( sprintf("[DESYNC] (%d) %s IS DESYNCED. Packets lost: %.2f percent. !!! MAKE THEM RELOG !!!", 
			playerid, ReturnUserName ( playerid, true ), NetStats_PacketLossPercent ( playerid ) ), MOD_WARNING_MED ) ;
	}

}

ptask CheckDonatorStatus[1800000](playerid) {

	if ( Account [ playerid ] [ account_donatorlevel ] ) {

		if ( Account [ playerid ] [ account_donatorexpire ] < gettime() ) {

			new query [ 128 ] ;

			Account [ playerid ] [ account_donatorlevel ] = 0 ;
			Account [ playerid ] [ account_donatorexpire ] = 0 ;

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_donatorlevel = 0, account_donatorexpire = 0 WHERE account_id = %d", Account [ playerid ] [ account_id ] ) ;
			mysql_tquery ( mysql, query ) ;

			SendServerMessage ( playerid, "Your donator level has expired.", MSG_TYPE_WARN ) ;
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Deprecated: see dignity/update.pwn

CMD:updates ( playerid, params [] ) {

	new string [ 2048 ] ;

	inline ServerUpdateInformation(pid, dialogid, response, listitem, string:inputtext[] ) { 
		#pragma unused pid, dialogid, response, listitem, inputtext

	}

	strcat ( string, "Last Updated: [x/02/2019]\n\nAdditions:\n\n" ) ;

	strcat ( string, "Farming system has been added, you can buy the necessities at the general store and blacksmith.\n" ) ;

	strcat ( string, "Trap system has been added, you can buy a trap at the blacksmith and place baits on it to catch animals. (and humans, sometimes).\n" ) ;
	
	strcat ( string, "\nChanges:\n\n" ) ;

	strcat ( string, "Bayside has been removed and replaced with some new mountain mapping.\nHorse system has been improved with animations.\n" ) ;

	strcat ( string, "El Quebrados is now Longcreek with some new fresh mapping.\n" ) ;

	strcat ( string, "\nRemoved:\n\n" ) ;

	strcat ( string, "None\n" ) ;

	Dialog_ShowCallback ( playerid, using inline ServerUpdateInformation, DIALOG_STYLE_MSGBOX, "Wild West Roleplay - Current Updates", string, "Exit" ) ;
	return true ;
}*/

CMD:logout( playerid, params [] ) {

	if ( ! LogoutPermission [ playerid ] ) {

		return SendServerMessage ( playerid, "You don't have permission to use this command.", MSG_TYPE_ERROR ) ;
	}

	SetCharacterLoggedPosition ( playerid ) ;

	LogoutPermission [ playerid ] = false ;
	PassedSelectionScreen [ playerid ] = false ;

	HideGUITextDraws ( playerid ) ;
	HideCharacterTextDraws ( playerid ) ;
	HideCreationTextDraws ( playerid ) ;

	DestroyCreationTextDraws ( playerid ) ;
	DestroyCharacterTextDraws ( playerid ) ;

	SetDynamicObjectPos ( HorseObject [ playerid ], 0.0, 0.0, 0.0 ) ;
	SetDynamicObjectPos ( CowObject [ playerid ], 0.0, 0.0, 0.0 ) ;

	SetPlayerName(playerid, Account [ playerid ] [ account_name ] ) ;
	SetPlayerScore(playerid,0);
	SetPlayerColor ( playerid, 0x000000FF) ;

	ClearData ( playerid ) ;

	Account_ConnectionCheck ( playerid ) ;

	//OldLog ( playerid, "acc/logout", sprintf("(%d) %s used /logout", playerid, ReturnUserName ( playerid, true ) ) ) ;

	return true ;
}

CMD:clearchat(playerid, params [] ) {

	for ( new i; i < 20; i ++ ) {

		SendClientMessage( playerid, -1, " " ) ;
	}

	return true ;
}

CMD:safezone ( playerid, params [] ) {

	if ( IsPlayerInRangeOfPoint(playerid, 50, -828.4460, 1087.0280, 38.9719) ) {

		SendServerMessage ( playerid, "You're in a safezone near the spawn, but only until you leave this area.", MSG_TYPE_WARN ) ;
		return SendServerMessage ( playerid, "If you return after, you won't be safe anymore for the safezone rule.", MSG_TYPE_WARN ) ;
	}

	if ( GetPlayerVirtualWorld(playerid) == 0 ) {
		if ( IsZoneSafeZone ( GetPlayerZone ( playerid ) ) ) {

			return SendServerMessage ( playerid, "You're in a safezone.", MSG_TYPE_INFO ) ;
		}
	}

	else if ( GetPlayerVirtualWorld(playerid) != 0 ) {

		for ( new i; i < MAX_POINTS; i ++ ) {

			if ( Point [ i ] [ point_id ] != -1 ) {

				if ( IsPlayerInRangeOfPoint(playerid, 25.0, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ] ) {

					if ( IsZoneSafeZone ( GetZone ( Point [ i ] [ point_ext_x ], Point [ i ] [ point_ext_y ] ))) {

						return SendServerMessage ( playerid, "You're in a safezone.", MSG_TYPE_INFO ) ;
					}

					else continue ;
				}

				else continue ;
			}

			else continue ;
		}
	}

	return SendServerMessage ( playerid, "You're not in a safezone.", MSG_TYPE_ERROR ) ;
}

CMD:servertime ( playerid, params [] ) {

	SendServerMessage ( playerid, sprintf("{DEDEDE}The current OOC [[VPS/SERVER HOST]] date/time is %s(GMT +1)", ReturnDateTime () ), MSG_TYPE_INFO) ;

	return true ;
}

CMD:help ( playerid, params [] ) { 

	inline HelpMenuDialog(pid, dialogid, response, listitem, string:inputtext[]) {

		#pragma unused pid, dialogid, inputtext

		if(response) {

			if(listitem == 0) {

				SendClientMessage(playerid, COLOR_TAB0, "|________________________| List of commands available to you |________________________|" ) ;
				SendClientMessage(playerid, COLOR_TAB1, "[GENERAL]:{DEDEDE} /spawn, /report, /ask, /id, /staff, /afklist, /animlist, /resyncambient, /safezone, /badge, /editmask" ) ;
				SendClientMessage(playerid, COLOR_TAB2, "[GENERAL]:{DEDEDE} /accept, /shakehand, /clearchat, /accent, /coin, /checktime, /roll, /frisk, /pay, /bank, /paycheck" ) ;
				SendClientMessage(playerid, COLOR_TAB1, "[GENERAL]:{DEDEDE} /ad(vertise), /setchat, /attributes, /examine, /charity, /servertime, /showinjuries, /namechange, /blockpm" ) ;
				SendClientMessage(playerid, COLOR_TAB2, "[GENERAL]:{DEDEDE} /checkjobcooldown (/cooldown), /resyncmask, /resynchorse, /nohorsesound, /gunpos, /licenses, /drink" ) ;
				SendClientMessage(playerid, COLOR_TAB2, "[GENERAL]:{DEDEDE} /prisontimeleft, /bail, /fixjob, /helpup, /transport, /reloadattachments" ) ;
				SendClientMessage(playerid, COLOR_TAB2, "[GENERAL]:{DEDEDE} /mypoints, /rentroom, /adminrecord, /streamdis, /attachments, /createdynamiclabel" ) ;
				SendClientMessage(playerid, COLOR_TAB1, "[MISC]:{DEDEDE} /ac, /accentlist, /acchelp, /bountyhelp, /chathelp, /gunhelp, /horsehelp, /point, /samphelp, /possehelp, /possechat" ) ;

				if ( IsPlayerStaff ( playerid ) ) {

					SendClientMessage(playerid, COLOR_STAFF, "[STAFF]:{DEDEDE} /staffhelp") ;
				}
			}
			else if(listitem == 1) {

				SendSplitMessage(playerid, COLOR_TAB0, "|________________________| Frequently Asked Questions (FAQ) |________________________|" ) ;
				SendSplitMessage(playerid, COLOR_TAB1, "1.{DEDEDE} Where do I start?" ) ;
				SendSplitMessage(playerid, COLOR_TAB2, "- We recommend starting by buying a fishing pole from a hunting store and finding any body of water to fish.  Once you decide to sell your fish, go to a hunting store to sell what you've caught." ) ;
				SendSplitMessage(playerid, COLOR_TAB1, "2.{DEDEDE} How do I get a horse?");
				SendSplitMessage(playerid, COLOR_TAB2, "- Go to a stablemaster either in Longcreek or Fremont, then type /buy.");
				SendSplitMessage(playerid, COLOR_TAB1, "3.{DEDEDE} How do I level up a skill?");
				SendSplitMessage(playerid, COLOR_TAB2, "- /levelup [skill name]");
				SendSplitMessage(playerid, COLOR_TAB1, "4.{DEDEDE} How do I enter a building?");
				SendSplitMessage(playerid, COLOR_TAB2, "- Press H (or to whichever key you've bound to \"Group Control Backwards\").");
				SendSplitMessage(playerid, COLOR_TAB0, "");
				SendSplitMessage(playerid, 0xDEDEDEFF, "If you have any questions that aren't here, feel free to use /ask or check on the forums for guides to refer to!");
			}
		}
	}

	Dialog_ShowCallback(playerid,using inline HelpMenuDialog,DIALOG_STYLE_LIST,"Help - Select a Catagory","Commands\nFrequently Asked Questions","Select","Exit");
	return true ;
}

CMD:rules(playerid) {

	new rules[2048];
	strcat(rules,"1. You must roleplay at all times unless given an OOC tag.\n");
	strcat(rules,"2. No advertisment of other SA-MP communties.\n");
	strcat(rules,"3. No 3rd party mods that could give you or a group an advantage over others.\n");
	strcat(rules,"4. No metagaming, powergaming, deathmatching and revenge killing.\n");
	strcat(rules,"5. Do not abuse any server bugs or client exploits.\n");
	strcat(rules,"6. You cannot commit crimes in safezones unless certain conditions are met. (see forums)\n");
	strcat(rules,"7. Sexual or otherwise explicit roleplay shouldn't be done in public and requires permission from both parties.\n");
	strcat(rules,"8. You cannot rob more than $60 off of someone or scam $1,500 out of someone.  Both parties involved must be level 5+.\n");
	strcat(rules,"9. When roleplaying your character, you must roleplay in line with the time period (see forums).\n\n");
	strcat(rules,"For more detail and understanding of the rules, please view them on the forums.");

	inline rulePrompt(pid,dialogid,response,listitem,string:inputtext[]) {

		#pragma unused pid,dialogid,response,listitem,inputtext
	}
	Dialog_ShowCallback(playerid,using inline rulePrompt,DIALOG_STYLE_MSGBOX,"Wild West Roleplay - Rules",rules,"Exit");
	return true;
}

CMD:horsehelp ( playerid, params [] ) {

	SendClientMessage(playerid, COLOR_TAB0, "|________________________| Horse Help |________________________|") ;

	SendClientMessage(playerid, COLOR_TAB1, "/respawnhorse:{DEDEDE} Erases your horse data so you can use /spawnhorse again.") ;
	SendClientMessage(playerid, COLOR_TAB2, "/spawnhorse:{DEDEDE} Spawns your horse near you, given it's not dead or disabled.") ;
	SendClientMessage(playerid, COLOR_TAB1, "/revivehorse:{DEDEDE} Revives your killed horse for a small fee at the stablemaster.") ;
	SendClientMessage(playerid, COLOR_TAB2, "/toghorsetds:{DEDEDE} Toggles the horse textdraws, useful for screenshots.") ;
	SendClientMessage(playerid, COLOR_TAB2, "/resynchorse{DEDEDE} Resyncs horse animation." ) ;
	SendClientMessage(playerid, COLOR_TAB2, "/nohorsesound{DEDEDE} Toggles the horse sounds on/off" ) ;

	return true ;
}

CMD:gunhelp ( playerid, params [] ) {

	SendClientMessage(playerid, COLOR_TAB0, "|________________________| Weapon Help |________________________|") ;

	SendClientMessage(playerid, COLOR_TAB1, "(/guns): /holstered:{DEDEDE} Displays all your weapons, their slot, and their ammo.") ;
	SendClientMessage(playerid, COLOR_TAB2, "(/gh, /guh): /holster, /unholster:{DEDEDE} (Un)Holsters your weapon in the specified slot") ; 
	SendClientMessage(playerid, COLOR_TAB1, "(/sgun): /switchgun:{DEDEDE} Switches your equipped weapon with a holstered one.") ; 
	SendClientMessage(playerid, COLOR_TAB2, "(/dgun, /pgun): /dropgun, /pickupgun:{DEDEDE} Drops or picks up a dropped weapon") ; 
	SendClientMessage(playerid, COLOR_TAB2, "/ammocrate:{DEDEDE} Use a ammo crate to refill your equipped weapon with ammo.") ; 
	SendClientMessage(playerid, COLOR_TAB2, "/passgun:{DEDEDE} Passes your gun to someone else.") ; 
	SendClientMessage(playerid, COLOR_TAB2, "/gunpos:{DEDEDE} Alter your holster positions [doesn't save].") ; 

	return true ;
}

CMD:samphelp ( playerid, params [] ) {
	SendClientMessage(playerid, COLOR_TAB0, "|________________________| SA-MP Command Help |________________________|") ;

	SendClientMessage(playerid, COLOR_TAB1, "Note: there are more commands, this list just shows commands useful to you. For a full list go to {DEDEDE}http://wiki.sa-mp.com/wiki/Client_Commands") ;
	SendClientMessage(playerid, COLOR_TAB2,"/timestamp:{DEDEDE} Shows a HH/MM/SS timestamp infront of every client message" ) ;
	SendClientMessage(playerid, COLOR_TAB1,"/headmove:{DEDEDE} Disables head movement for every player (useful for screenshots)" ) ;
	SendClientMessage(playerid, COLOR_TAB2,"/pagesize:{DEDEDE} Increases the displayed server messages (useful for high resolutions) " ) ;
	SendClientMessage(playerid, COLOR_TAB1,"/fpslimit:{DEDEDE} Limits your FPS. Should be kept at 60 for best stability and performance." ) ;
	SendClientMessage(playerid, COLOR_TAB2,"/audiomsg:{DEDEDE} Disables the green audio messages whenever the server plays a sound file." ) ;
	SendClientMessage(playerid, COLOR_TAB1,"/fontsize:{DEDEDE} Increases the font size of server messages (useful for high resolutions)" ) ;

	return true ;
}

CMD:acchelp ( playerid, params [] ) {

	SendClientMessage(playerid, COLOR_TAB0, "|________________________| Account Help |________________________|") ;

	SendClientMessage(playerid, COLOR_TAB1, "/selectcharacter:{DEDEDE} allows you to select a character in the selection menu.") ;
	SendClientMessage(playerid, COLOR_TAB1, "/logout:{DEDEDE} allows you to go to the login screen, after permission is given.");
	SendClientMessage(playerid, COLOR_TAB2, "/relog:{DEDEDE} usable at the login screen or character selection to fix issues.");
	SendClientMessage(playerid, COLOR_TAB1, "/statistics, /stats:{DEDEDE} displays your spawned character's statistics.");

	return true ;
}

CMD:chathelp ( playerid, params [] ) {

	SendClientMessage(playerid, COLOR_TAB0, "|________________________| Chat Help |________________________|") ;

	SendClientMessage(playerid, COLOR_TAB1, "/me(low), /my(low), /do(low):{DEDEDE} allows your character to perform a roleplaying action") ;
	SendClientMessage(playerid, COLOR_TAB2, "/s(hout), /low:{DEDEDE} allows your character to say something specifically") ;
	SendClientMessage(playerid, COLOR_TAB2, "/w(hisper):{DEDEDE} allows you to communicate privately to someone ICly") ;
	SendClientMessage(playerid, COLOR_TAB2, "/b, /o(oc), /pm:{DEDEDE} allows you to communicate Out of Characterly") ;
	SendClientMessage(playerid, COLOR_TAB1, "/ame, /ado:{DEDEDE} allows your character to perform a roleplaying action, but doesn't send a local message.") ;
	SendClientMessage(playerid, COLOR_TAB2, "** /ame or /ado does not send a local message, but instead show the action above your character's head.") ;
	
	return true ;
}

CMD:bountyhelp ( playerid, params [] ) {

	SendClientMessage(playerid, COLOR_TAB0, "|________________________| Bounty Help |________________________|") ;

	SendClientMessage(playerid, COLOR_TAB1, "/takebounty:{DEDEDE} allows you to take a bounty if you're near a poster.  Use optional parameter to specify the poster id.") ;
	SendClientMessage(playerid, COLOR_TAB2, "/abandonbounty:{DEDEDE} allows you to abandon your current bounty.") ;
	SendClientMessage(playerid, COLOR_TAB1, "/pickbounty:{DEDEDE} allows you to pick up a bounty you killed.") ;
	SendClientMessage(playerid, COLOR_TAB2, "/claimbounty:{DEDEDE} allows you to claim your reward for the bounty.") ;
	return true ;
}

CMD:licenses ( playerid, params [] ) {

	new target ;

	if ( sscanf ( params, "u", target ) ) {

		return SendServerMessage ( playerid, "/licenses [player]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected(target )) {

		return SendServerMessage ( playerid, "Target doesn't seem to be connected.", MSG_TYPE_ERROR ) ;
	}

	new Float: x, Float: y, Float: z;
	GetPlayerPos ( target, x, y, z ) ;

	new Float: yds = GetPlayerDistanceFromPoint(playerid, x, y, z ) ;

	if ( yds > 10.0 ) {

		return SendServerMessage ( playerid, "You're not close enough to your target.", MSG_TYPE_ERROR ) ;
	}

	SendClientMessage(target, COLOR_TAB0, sprintf("Licenses of (%d) %s", playerid, ReturnUserName ( playerid, true, true ) ) ) ;

	new hasitem [ 16 ] ;

	if ( DoesPlayerHaveItem ( playerid, CARD_PASSPORT) != -1 ) {

		hasitem = "{406E3B}yes" ;
	}

	else hasitem = "{A12F2F}no" ;

	SendClientMessage(target, COLOR_TAB1, sprintf("[Passport]: %s", hasitem ) ) ;


	if ( DoesPlayerHaveItem ( playerid, CARD_GUNPERMIT) != -1 ) {

		hasitem = "{406E3B}yes" ;
	}

	else hasitem = "{A12F2F}no" ;

	SendClientMessage(target, COLOR_TAB2, sprintf("[Gun Permit]: %s", hasitem ) ) ;

	SendServerMessage ( playerid, sprintf("You've shown your licenses to (%d) %s.", target, ReturnUserName ( target, true, true )), MSG_TYPE_ERROR ) ;
	ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s shows his licenses to %s", ReturnUserName ( playerid, true, true ), ReturnUserName ( target, true, true ) ) )   ;

	return true ;
}

CMD:id ( playerid, params [] ) {

    if ( IsNumeric ( params ) ) {

    	if ( ! IsPlayerConnected ( strval ( params ) ) ) {

    		return SendClientMessage(playerid, COLOR_TAB2, "Player doesn't seem to exist.");
    	}

	    SendClientMessage(playerid, COLOR_TAB0, sprintf("[Search results for '%s']", params ));
		SendClientMessage(playerid, COLOR_TAB1, sprintf("%s (ID:%i)",  ReturnUserName ( strval ( params ), false, false), strval ( params )  ) );
    }

    else if (! IsNumeric ( params ) ) {

		if ( strlen( params ) < 3 ) {

	       	return SendServerMessage ( playerid, "/id [name] - enter at least 3 characters", MSG_TYPE_ERROR ) ;
	    }

	    new count ;

	    SendClientMessage(playerid, COLOR_TAB0, sprintf("[Search results for '%s']", params));

	    foreach(new i: Player ) {
	        new rname [ MAX_PLAYER_NAME ];
	        GetPlayerName(i, rname, sizeof ( rname ) ) ;

	    	if ( strfind ( rname, params, true ) != -1 ) {

				count ++;
				SendClientMessage(playerid, COLOR_TAB1, sprintf("%i. %s (ID:%i)", count, rname, i));
			}
	    }

	    if ( count == 0 ) {

	    	return SendClientMessage(playerid, COLOR_TAB2, "Player doesn't seem to exist.");
	    }
	}

	return true ;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


public OnPlayerConnect( playerid ) {
	RemoveBuildings ( playerid ) ;

	LoadZoneTextDraws ( playerid ) ;
	//LoadGUITextDraws ( playerid ) ;
	LoadPlayerInventoryExamineGUI ( playerid ) ;
	LoadInventoryTextDraws ( playerid )  ;
	LoadPlayerActionTextDraws ( playerid ) ;
	LoadWantedPosterTextDraws ( playerid ) ;
	Blackjack_CreatePlayerGUI(playerid) ;
	BJ_ResetVariables(playerid) ;

	TogglePlayerSpectating ( playerid, true ) ;

//	SendModeratorWarning ( sprintf("[CONNECT] (%d) %s has connected to the server {FFFF00}[%s]", playerid, ReturnUserName ( playerid, true ), ReturnIP ( playerid )), MOD_WARNING_LOW);
	//OldLog ( playerid, "acc/connect", sprintf("(%d) %s has connected to the server [%s]", playerid, ReturnUserName ( playerid, true ), ReturnIP ( playerid ) ) ) ;

	SetPlayerColor ( playerid, 0x000000FF) ;
 	Account_ConnectionCheck ( playerid ) ;

 	return true ;
}

public OnPlayerDisconnect(playerid, reason) {

    ResetPlayerWounds ( playerid ) ;

	TextDrawHideForPlayer(playerid, TD_HorseSprint) ;
	PlayerTextDrawDestroy(playerid, TD_ZoneName ) ;

	DestoryWantedPosterTDs ( playerid ) ;
	DestroyCreationTextDraws ( playerid ) ;
	DestroyCharacterTextDraws ( playerid ) ;
	DestroyPlayerInventoryGUI ( playerid ) ;
	DestroyGUITextDraws ( playerid ) ;
	DestroyPlayerActionGUI ( playerid ) ;
	BJ_DestroyTDs(playerid);

	SetDynamicObjectPos ( HorseObject [ playerid ], 0.0, 0.0, 0.0 ) ;
	SetDynamicObjectPos ( CowObject [ playerid ], 0.0, 0.0, 0.0 ) ;

/*
	new Float: x, Float: y, Float: z ;
	GetPlayerPos ( playerid, x, y, z ) ;

	foreach(new i: Player) {

		if ( IsPlayerInRangeOfPoint(i, 2.5, x, y, z)){

			SendClientMessage(i, 0xDEDEDEFF, sprintf("[DISCONNECT] (%d) %s has just left the server, reason: %s", playerid, ReturnUserName ( playerid, true ), dc_reasons [ reason ])) ;
			continue ;
		}

		else continue ;
	}*/

	new dc_reason[3][] = {
        "Timeout/Crash",
        "Quit",
        "Kick/Ban"
    };

    ProxDetector(playerid, 15.0 , COLOR_CLIENT, sprintf("[DISCONNECT] (%d) %s has disconnected from the server. Reason: %s", 
        playerid, ReturnUserName ( playerid ), dc_reason [ reason ] ));

	//SendModeratorWarning ( sprintf("[DISCONNECT] (%d) %s has just left the server, reason: %s", playerid, ReturnUserName ( playerid, true ), dc_reasons [ reason ] ), MOD_WARNING_LOW);

	return true ;
}

public OnPlayerRequestClass(playerid, classid) {

	return OnPlayerSpawn ( playerid );
}

public OnPlayerRequestSpawn(playerid) {
	
	return OnPlayerSpawn ( playerid ) ;
}

public OnPlayerSpawn(playerid) {

	IsPlayerSpectating [ playerid ] = INVALID_PLAYER_ID ;

	if ( IsPlayerModerator ( playerid ) ) {

		PlayerModWarnings [ playerid ] = true ; 
	}

	return true ;
}

CMD:reloadattachments ( playerid, params [] ) {

	Init_LoadPlayerAttachments ( playerid ) ;
	SetupPlayerGunAttachments ( playerid ) ;

	return SendServerMessage ( playerid, "Reloaded gun and player attachments.", MSG_TYPE_WARN ) ;
}

ReloadPlayerAttachments ( playerid ) {

	Init_LoadPlayerAttachments ( playerid ) ;
	SetupPlayerGunAttachments ( playerid ) ;
	return true ;
}

public OnPlayerDeath ( playerid, killerid, reason ) {

	Player_ClientDeath [ playerid ] = true ;

	return true ;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source){

	if ( IsPlayerModerator ( playerid ) ) {
	    new stats[ 512 ];

	    GetPlayerNetworkStats ( clickedplayerid, stats, sizeof ( stats ) ) ; // get your own networkstats
	    ShowPlayerDialog ( playerid, 0, DIALOG_STYLE_MSGBOX, "Player Network Information", stats, "Okay", "" ) ;

 		ShowPlayerStatistics ( playerid, clickedplayerid ) ;
	}

    return true ;
}


public OnPlayerShootDynamicObject ( playerid, weaponid, objectid, Float:x, Float:y, Float:z ) {

	for ( new i; i < MAX_WILDLIFE; i ++ ) {

		if ( Wildlife [ i ] [ wildlife_object ] == objectid ) {

			Wildlife_Shot(objectid, weaponid);
			if ( DoingTask [ playerid ] == 6 ) {

				ProcessTask ( playerid, DoingTask [ playerid ] ) ;
			}
		}
	}

	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ) {

	CheckPlayerHackedWeapons ( playerid, weaponid ) ;

	if ( Character [ playerid ] [ character_handweapon ] != GetPlayerWeapon ( playerid) ) {

		SendModeratorWarning (sprintf("(%d) %s might be using a concealed weapon cheat. Spectate them immediately!", playerid, ReturnUserName ( playerid )), MOD_WARNING_HIGH ) ;
		ResetPlayerWeapons ( playerid ) ;
		return false ;
	}

	Character [ playerid ] [ character_handammo ] -- ;
	if ( Character [ playerid ] [ character_handammo ] < 1 ) {

 		SetPlayerAttachedObject(playerid, ATTACH_SLOT_HANDS, ReturnWeaponObject ( playerid ), 6, 0.004, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0 );
		ResetPlayerWeaponsEx ( playerid ) ;

		SendServerMessage ( playerid, "Your weapon has ran out of ammo. If your screen is still shaking, use /fa (/fixaim).", MSG_TYPE_ERROR ) ;

		SetPlayerDrunkLevel(playerid, 1) ;
		//OldLog ( playerid, "guns/ammo", sprintf ( "%s has ran out of ammo.", ReturnUserName ( playerid, false ) )) ;
	}

	else {

		if ( GetShootRate ( playerid ) ) { 
		
			CheckCBug ( playerid, weaponid, GetShootRate ( playerid ) ) ;
		}

		SetShootRate ( playerid ) ;
	}

	CreatePlayerGunShell ( playerid ) ;

	UpdateWeaponGUI ( playerid ) ;
	SavePlayerWeapons ( playerid ) ;

	return true ;
}

public OnPlayerStreamIn(playerid) {
	Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL );
	return true ;
}

public OnPlayerSelectDynamicObject(playerid, STREAMER_TAG_OBJECT objectid, modelid, Float:x, Float:y, Float:z) {

	if(FurnitureBuilder[playerid][furn_builder_mode] != -1) {

		if(FurnitureBuilder[playerid][furn_builder_mode] == FURNI_EDIT) {

			for(new i=0; i<MAX_FURNITURE_LIMIT; i++) {
				
				if(FurnitureObject[GetCharacterPointID(playerid)][furn_object_handler][i] == objectid) {
				
					FurnitureBuilder[playerid][furn_builder_edit_obj_handler] = objectid;
					FurnitureBuilder[playerid][furn_builder_edit_obj_db_id] = FurnitureObject[GetCharacterPointID(playerid)][furn_object_db_id][i];
					ResetFurnitureViewerInfo(playerid);
					EditDynamicObject(playerid, FurnitureBuilder[playerid][furn_builder_edit_obj_handler]);
					return SendServerMessage(playerid,"Move the furniture object and click the \"Save\" icon to save its placement.",MSG_TYPE_INFO);
				}
				continue;
			}
			//ResetFurnitureViewerInfo(playerid);
			//FurnitureBuilder[playerid][furn_builder_mode] = -1;
			SendServerMessage(playerid,"Something went wrong, try to click on the object you wish to move again.",MSG_TYPE_ERROR);
			SendServerMessage(playerid,"If this doesn't work, use /editfurni(ture)object.",MSG_TYPE_ERROR);
		}

		else if(FurnitureBuilder[playerid][furn_builder_mode] == FURNI_EDIT_TEXTURE) {

			for(new i=0; i<MAX_FURNITURE_LIMIT; i++) {
				
				if(FurnitureObject[GetCharacterPointID(playerid)][furn_object_handler][i] == objectid) {

					new string[512];
					ResetFurnitureViewerInfo(playerid);
					CancelEdit(playerid);

					for(new j=0; j<15; j++) {

						format(string,sizeof(string),"%sMaterial Index %d\n",string,j);
					}

					inline FurnTexEdit(pid, dialogid, response, listitem, string:inputtext[] ) { 

						#pragma unused pid,dialogid,inputtext

						if(!response) {

							FurnitureBuilder[playerid][furn_builder_mode] = -1;
							return cmd_point(playerid,"furni");
						}

						FurnitureBuilder[playerid][furn_builder_edit_mat_index] = listitem;
						FurnitureBuilder[playerid][furn_builder_edit_td_count] = 0;
						FurnitureBuilder[playerid][furn_builder_edit_obj_handler] = objectid;
						FurnitureBuilder[playerid][furn_builder_edit_obj_db_id] = FurnitureObject[GetCharacterPointID(playerid)][furn_object_db_id][i];
						SetDynamicObjectMaterial(FurnitureBuilder[playerid][furn_builder_edit_obj_handler],FurnitureBuilder[playerid][furn_builder_edit_mat_index],FurnitureMaterialInfo[0][furniture_texture_modelid],FurnitureMaterialInfo[0][furniture_texture_txd_name],FurnitureMaterialInfo[0][furniture_texture_texture_name]);
						ShowTextureEditTD(playerid);
						SelectTextDraw(playerid,0xFFFFFF55);
						return true;
					}
					return Dialog_ShowCallback(playerid,using inline FurnTexEdit,DIALOG_STYLE_LIST,"Furniture Edit - Material Indexes",string,"Select","Exit");
				}
			}
			SendServerMessage(playerid,"Something went wrong, try to click on the object you wish to remove again.",MSG_TYPE_ERROR);
			SendServerMessage(playerid,"If this doesn't work, use /removefurni(ture)object.",MSG_TYPE_ERROR);
		}
		else if(FurnitureBuilder[playerid][furn_builder_mode] == FURNI_DELETE) {

			for(new i=0; i<MAX_FURNITURE_LIMIT; i++) {
				
				if(FurnitureObject[GetCharacterPointID(playerid)][furn_object_handler][i] == objectid) {
					
					ResetFurnitureViewerInfo(playerid);
					CancelEdit(playerid);
					inline DeleteFurnWarn(pid, dialogid, response, listitem, string:inputtext[] ) { 

						#pragma unused pid,dialogid,listitem,inputtext

						if(!response) {

							FurnitureBuilder[playerid][furn_builder_mode] = -1;
							SendServerMessage(playerid,"You've cancelled removing a furniture object.",MSG_TYPE_WARN);
							return cmd_point(playerid,"furni");
						}

						new query[128];

						mysql_format(mysql,query,sizeof(query),"DELETE FROM furniture WHERE furniture_id = %d",FurnitureObject[GetCharacterPointID(playerid)][furn_object_db_id][i]);
						mysql_tquery(mysql,query);
						mysql_format(mysql,query,sizeof(query),"DELETE FROM furniture_extra WHERE furniture_ex_id = %d",FurnitureObject[GetCharacterPointID(playerid)][furn_object_db_id][i]);
						mysql_tquery(mysql,query);

						FurnitureBuilder[playerid][furn_builder_mode] = -1;
						DestroyDynamicObject(objectid);
						Init_Furniture(Point[GetCharacterPointID(playerid)][point_id]);
						SendServerMessage(playerid,"You've successfully deleted a furniture object.",MSG_TYPE_INFO);
					}
					return Dialog_ShowCallback(playerid,using inline DeleteFurnWarn,DIALOG_STYLE_MSGBOX,"Furniture Deletion","WARNING: You've selected a furniture object to delete.\nThis dialog is to prevent accidental deletion of a furniture object.\nIf you're sure about your decision, click \"Confirm\".", "Confirm", "Cancel");
				}
			}
			SendServerMessage(playerid,"Something went wrong, try to click on the object you wish to remove again.",MSG_TYPE_ERROR);
			SendServerMessage(playerid,"If this doesn't work, use /removefurni(ture)object.",MSG_TYPE_ERROR);
		}
	}
	return true;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

WriteLog ( playerid, dir[], text[]) {

	new query [ 512 ], Float: x, Float: y, Float: z ;
	GetPlayerPos ( playerid, x, y, z ) ;

	format ( query, sizeof ( query ), "X: %f, Y: %f, Z: %f, vw: %d, int: %d", x, y, z, GetPlayerVirtualWorld ( playerid ), GetPlayerInterior ( playerid ) ) ;

	mysql_format(mysql, query, sizeof ( query ), "INSERT INTO logs (dir, text, date, ip, info) VALUES ('%e', '%e', '%e', '%e', '%e')",
	dir, text, ReturnDateTime ( ), ReturnIP ( playerid ), query );

	mysql_tquery ( mysql, query ) ;

	return true ;
}

ReturnUserName ( playerid, bool: underscore = true , bool: mask = true ) {
	new name [ MAX_PLAYER_NAME + 1 ] ;
	GetPlayerName(playerid, name, sizeof(name));

	if ( playerid == INVALID_PLAYER_ID ) {

		name="Nobody";
		return name ;
	}

	if ( ! underscore ) {
	    for (new i = 0, len = strlen(name); i < len; i ++) {

	        if (name[i] == '_') name[i] = ' ';
		}
	}

	if ( mask == true && IsPlayerMasked [ playerid ] ) {

		format ( name, sizeof ( name ), "Stranger %d_%d",   Account [ playerid ] [ account_id ] * 20, Character [ playerid ] [ character_id ] ) ;
	}

	return name;
}

KickPlayer ( playerid ) {

	defer DisconnectUser(playerid);
	
	return true;
}

timer DisconnectUser[1000](playerid) {

	//print("DisconnectUser timer called (main.pwn)");

	return Kick ( playerid ) ;
}

timer DelayAttachmentPlacement[2000](playerid) {

	return ReloadPlayerAttachments ( playerid ) ;
}

ReturnDateTime ( ) {
	new date[36];

	getdate(date[2], date[1], date[0]);
	gettime(date[3], date[4], date[5]);

	format(date, sizeof(date), "%02d/%02d/%d, %02d:%02d",
	date[0], date[1], date[2], date[3], date[4]);

	return date;
}

ReturnIP ( playerid ) {
	new ip[16];
	GetPlayerIp(playerid, ip, sizeof(ip));

	return ip;
}

ReturnWeaponName ( weaponid ) {
	new gunname[32];

	switch ( weaponid ) {
		case 1 .. 17,  22 .. 43,  46 : GetWeaponName ( weaponid, gunname, sizeof ( gunname ) ) ;
		case 0:		format ( gunname, sizeof ( gunname ),"%s", "None");
		case 18:	format ( gunname, sizeof ( gunname ),"%s", "Molotov Cocktail");
		case 44:	format ( gunname, sizeof ( gunname ),"%s", "Night Vis Goggles");
		case 45:	format ( gunname, sizeof ( gunname ),"%s", "Thermal Goggles");
		default:	format ( gunname, sizeof ( gunname ),"%s", "Invalid Weapon Id");
	}

	return gunname;
}

GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance) {

	new Float:a;

	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	if (GetPlayerVehicleID(playerid)) {

	  GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

// These two only calculate the southern angle

GetXYLeftOfPlayer(playerid, &Float:X, &Float:Y, Float:distance) {
    new Float:Angle;
    GetPlayerFacingAngle(playerid, Angle); Angle += 90.0;
    X += floatmul(floatsin(-Angle, degrees), distance);
    Y += floatmul(floatcos(-Angle, degrees), distance);
}

GetXYRightOfPlayer(playerid, &Float:X, &Float:Y, Float:distance) {
    new Float:Angle;
    GetPlayerFacingAngle(playerid, Angle); Angle -= 90.0;
    X += floatmul(floatsin(-Angle, degrees), distance);
    Y += floatmul(floatcos(-Angle, degrees), distance);
}

epoch_to_datetime(unix_timestamp, &year, &month, &day, &hour, &minute, &second, utc_hour = 0, utc_minute = 0)  { 

    static days_of_month[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}, next_year, ut_of_next_year; 

    static const unix_timestamp_by_year[] =  { 
        -315619200, -283996800, -252460800, -220924800, -189388800, -157766400, -126230400, -94694400, -63158400, -31536000, 
        0, 31536000, 63072000, 94694400, 126230400, 157766400, 189302400, 220924800, 252460800, 283996800, 
        315532800, 347155200, 378691200, 410227200, 441763200, 473385600, 504921600, 536457600, 567993600, 599616000, 
        631152000, 662688000, 694224000, 725846400, 757382400, 788918400, 820454400, 852076800, 883612800, 915148800, 
        946684800, 978307200, 1009843200, 1041379200, 1072915200, 1104537600, 1136073600, 1167609600, 1199145600, 1230768000, 
        1262304000, 1293840000, 1325376000, 1356998400, 1388534400, 1420070400, 1451606400, 1483228800, 1514764800, 1546300800, 
        1577836800, 1609459200, 1640995200, 1672531200, 1704067200, 1735689600, 1767225600, 1798761600, 1830297600, 1861920000, 
        1893456000, 1924992000, 1956528000, 1988150400, 2019686400, 2051222400, 2082758400, 2114380800, 2145916800, -2117514496 
    }; 
     
    if (!(-315619200 <= (unix_timestamp += (utc_hour * 3600) + (utc_minute * 60)) <= cellmax)) return; 

    next_year = floatround(1970 + (unix_timestamp / 86400) * 0.00273790926, floatround_floor) + 1; 
    ut_of_next_year = unix_timestamp_by_year[next_year - 1960]; 
    year = (!(next_year & 3) && ((next_year % 25) || !(next_year & 15))) && ut_of_next_year <= unix_timestamp <= ut_of_next_year + 86400 ? next_year : next_year - 1; 
    days_of_month[1] = (!(year & 3) && ((year % 25) || !(year & 15))) ? 29 : 28; 
    unix_timestamp -= unix_timestamp_by_year[year - 1960] + ((hour = (unix_timestamp / 3600) % 24) * 3600) + ((minute = (unix_timestamp / 60) % 60) * 60) + (second = unix_timestamp % 60); 
    day = (unix_timestamp / 86400) + 1; 

    for (new i; i != sizeof days_of_month; i++)  { 
    	
        if ((day -= days_of_month[i]) > 0) continue; 

        day = !day ? days_of_month[i] : day + days_of_month[i]; 
        month = i + 1; 

        break; 
    } 
}  

GetDuration(time) { 
    new  str[32]; 

    if (time < 0 || time == gettime()) { 

        format(str, sizeof(str), "Never"); 
        return str; 
    } 

    else if (time < 60) format(str, sizeof(str), "%d seconds", time); 
    else if (time >= 0 && time < 60) format(str, sizeof(str), "%d seconds", time); 
    else if (time >= 60 && time < 3600) format(str, sizeof(str), (time >= 120) ? ("%d minutes") : ("%d minute"), time / 60); 
    else if (time >= 3600 && time < 86400) format(str, sizeof(str), (time >= 7200) ? ("%d hours") : ("%d hour"), time / 3600); 
    else if (time >= 86400 && time < 2592000) format(str, sizeof(str), (time >= 172800) ? ("%d days") : ("%d day"), time / 86400); 
    else if (time >= 2592000 && time < 31536000) format(str, sizeof(str), (time >= 5184000) ? ("%d months") : ("%d month"), time / 2592000); 
    else if (time >= 31536000) format(str, sizeof(str), (time >= 63072000) ? ("%d years") : ("%d year"), time / 31536000); 

    strcat(str, " ago"); 

    return str; 
} 

GetDateForUnix ( unix ) {

    new string [ 128 ], year, month, day, hour, minute, second ;

    stamp2datetime(unix, year, month, day, hour, minute, second, 1 ) ;
    format ( string, sizeof ( string ), "%02d/%02d/%d, %02d:%02d:%02d", day, month, year, hour, minute, second ) ;
    
    return string ;
}

IsPlayerNearPlayer(playerid, targetid, Float:radius) {
	static
		Float:fX,
		Float:fY,
		Float:fZ;

	GetPlayerPos(targetid, fX, fY, fZ);

	return (GetPlayerInterior(playerid) == GetPlayerInterior(targetid) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid)) && IsPlayerInRangeOfPoint(playerid, radius, fX, fY, fZ);
}

ClearAudioForZone ( playerid ) {

	StopAudioStreamForPlayer ( playerid ) ;

	for ( new i = 0; i < sizeof ( Zones ) ; i++ ) {

		if ( IsPlayerInDynamicArea(playerid, Zone_ID [ i ] )) {

			PlayAudioStreamForPlayer(playerid, Zones [ i ] [ zone_audio ] ) ;

			return true ;		
		}
	}

	return true ;
}

PlayerPlaySoundEx(playerid, sound)
{
	new
	    Float:x,
	    Float:y,
	    Float:z;

	GetPlayerPos(playerid, x, y, z);

	foreach (new i : Player) if (IsPlayerInRangeOfPoint(i, 20.0, x, y, z)) {
	    PlayerPlaySound(i, sound, x, y, z);
	}
	return 1;
}

PlayReloadAnimation(playerid, weaponid)
{
	switch (weaponid)
	{
	    case 22: ApplyAnimation(playerid, "COLT45", "colt45_reload", 4.0, 0, 0, 0, 0, 0);
		case 23: ApplyAnimation(playerid, "SILENCED", "Silence_reload", 4.0, 0, 0, 0, 0, 0);
		case 24: ApplyAnimation(playerid, "PYTHON", "python_reload", 4.0, 0, 0, 0, 0, 0);
		case 25, 27: ApplyAnimation(playerid, "BUDDY", "buddy_reload", 4.0, 0, 0, 0, 0, 0);
		case 26: ApplyAnimation(playerid, "COLT45", "sawnoff_reload", 4.0, 0, 0, 0, 0, 0);
		case 29..31, 33, 34: ApplyAnimation(playerid, "RIFLE", "rifle_load", 4.0, 0, 0, 0, 0, 0);
		case 28, 32: ApplyAnimation(playerid, "TEC", "tec_reload", 4.0, 0, 0, 0, 0, 0);
	}
	return 1;
}

GetTickDiff(newtick, oldtick) {

	if (oldtick < 0 && newtick >= 0) {
		return newtick - oldtick;
	} else if (oldtick >= 0 && newtick < 0 || oldtick > newtick) {
		return (cellmax - oldtick + 1) - (cellmin - newtick);
	}
	return newtick - oldtick;
}

IsPlayerAiming(playerid)
{
	new anim = GetPlayerAnimationIndex(playerid);
	if (((anim >= 1160) && (anim <= 1163)) || (anim == 1167) || (anim == 1449) || (anim == 1365) || (anim == 1643) || (anim == 1453) || (anim == 220) ||
	(anim == 1331) || (anim == 363 ) || (anim == 1365) || (anim==361)) return 1;
 	return 0;
}

stock IsPointInRangeOfPoint(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2, Float:range)
{
    x2 -= x;
    y2 -= y;
    z2 -= z;
    return ((x2 * x2) + (y2 * y2) + (z2 * z2)) < (range * range);
}

GetXYInAtOffsetOfPlayer(playerid, &Float:x, &Float:y, Float:distance, Float:angle_offset)
{
	// Created by Y_Less
	new Float:a;

	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	a += angle_offset;

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

GetXYInAtOffsetOfObject(objectid, &Float:x, &Float:y, Float:distance, Float:angle_offset)
{
	// Created by Y_Less
	new Float: temp, Float:a;

	GetDynamicObjectPos(objectid, x, y, a);
	GetDynamicObjectRot(objectid, temp, temp, a);

	a += angle_offset;

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

SendASCIILogo () {
	
	print ( "\n\nWW      WW IIIII LL      DDDDD      WW      WW EEEEEEE  SSSSS  TTTTTTT" ) ;
	print ( "WW      WW  III  LL      DD  DD     WW      WW EE      SS        TTT" ) ; 
	print ( "WW   W  WW  III  LL      DD   DD    WW   W  WW EEEEE    SSSSS    TTT" ) ; 
	print ( " WW WWW WW  III  LL      DD   DD     WW WWW WW EE           SS   TTT" ) ;
	print ( "  WW   WW  IIIII LLLLLLL DDDDDD       WW   WW  EEEEEEE  SSSSS    TTT\n" ) ;
	print ( "RRRRRR   OOOOO  LL      EEEEEEE    PPPPPP  LL        AAA   YY   YY" ) ;
	print ( "RR   RR OO   OO LL      EE         PP   PP LL       AAAAA  YY   YY" ) ;
	print ( "RR   RR OO   OO LL      EE         PP   PP LL       AAAAA  YY   YY" ) ;
	print ( "RRRRRR  OO   OO LL      EEEEE      PPPPPP  LL      AA   AA  YYYYY" ) ;
	print ( "RR  RR  OO   OO LL      EE         PP      LL      AAAAAAA   YYY" ) ;
	print ( "RR   RR  OOOO0  LLLLLLL EEEEEEE    PP      LLLLLLL AA   AA   YYY\n\n" ) ;
	print ( "  Wild West Roleplay since September 2016. Made by Dignity and David.") ;

	return true ;
}

IsNumeric(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}

GetGangZoneCenter(Float:minx,Float:miny,Float:maxx,Float:maxy,&Float:centerx,&Float:centery) {

	centerx = ((minx+maxx)/2);
	centery = ((miny+maxy)/2);
}

/*
ptask PingChecker[5000](playerid) {

////	print("PingChecker timer called (main.pwn)");

	if ( NetStats_PacketLossPercent ( playerid ) > 10.0 && IsPlayerSpawned ( playerid ) ) {

		if ( ++ PacketLossTicker [ playerid ] > 4 ) {

			SendClientMessageToAll ( COLOR_GREEN, sprintf("[PING] (%d) %s has been kicked for having a packet loss of %d% after three consecutive ticks.", playerid, ReturnUserName ( playerid, true ), NetStats_PacketLossPercent ( playerid ) ) ) ;
		}
	}

	else return true ;

	if ( GetPlayerPing ( playerid ) > 800 ) {

		if ( ++ PingTicker [ playerid ] > 4) {

			SendClientMessageToAll ( COLOR_GREEN, sprintf("[PING] (%d) %s has been kicked for having a ping of %d after three consecutive ticks.", playerid, ReturnUserName ( playerid, true ), GetPlayerPing ( playerid ) ) ) ;
		}

		else return true ;
	}

	new string [ 1024 ] ;

	format ( string, sizeof ( string ), 

		"{DEDEDE}Oops! There's been a {EDD72F}network error{DEDEDE}!\n\
		\n\
		Your ping: \t {EDD72F}%d [MAX: 700]{DEDEDE}\n\
		Packet loss: \t {EDD72F}%.2f percent{DEDEDE}\n\
		\n\
		Please reconnect. Contact an admin if the issue persists.\n\
		\n\
		Sorry for the inconvenience\n", 

	 	GetPlayerPing ( playerid ), NetStats_PacketLossPercent ( playerid )
	 ) ;

	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "{EDD72F}Network Error: too high ping/packet loss", string, "Close", "" ) ;

	PacketLossTicker [ playerid ] = 0 ;
	PingTicker [ playerid ] = 0 ;
	KickPlayer(playerid);

	return true ;
}
*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
--- this is causing the vw bug

// Doesn't seem to work all the time
new PlayerOldInterior [ MAX_PLAYERS ] ;
new PlayerOldWorld [ MAX_PLAYERS ] ;
ptask OnPlayerChangeEntity [1000](playerid) {

////	print("OnPlayerChangeEntity timer called (main.pwn)");

	if ( PlayerOldInterior [ playerid ] != GetPlayerInterior ( playerid ) || PlayerOldWorld [ playerid ] != GetPlayerVirtualWorld ( playerid ) ) {

		foreach(new i: Player) {

			if ( IsPlayerSpectating [ i ] == playerid) {

				if ( IsPlayerSpectating [ i ] != INVALID_PLAYER_ID ) {

					SetPlayerInterior(i, GetPlayerInterior ( playerid ) ) ;
					SetPlayerVirtualWorld(i, GetPlayerVirtualWorld ( playerid ) ) ;

					PlayerSpectatePlayer ( i, playerid ) ;
				}

				else return SendServerMessage ( playerid, "Couldn't pull entity of spectated player. Please re-spec!", MSG_TYPE_ERROR ) ;
			}
		}
	 	
	 	PlayerOldInterior [ playerid ] = GetPlayerInterior ( playerid ) ;
	 	PlayerOldWorld [ playerid ] = GetPlayerVirtualWorld ( playerid ) ;

	}

	return true ;
}*/
// Search for players name
SSCANF:u(name[]) {
	if(isnull(name)) return INVALID_PLAYER_ID;

	new id;

	if ( sscanf(name, "i", id ) ) {
        new matches, rname [ MAX_PLAYER_NAME ];
        
		foreach(new i : Player) {

	        GetPlayerName(i, rname, sizeof ( rname ) ) ;

		    if(strfind(rname, name, true) != -1) {
				matches++;
				id = i;

				if(matches > 1) return INVALID_PLAYER_ID;
			}
		}

		if(matches) return id;
		return INVALID_PLAYER_ID;
	}

	if(id < 0) return INVALID_PLAYER_ID;
	if(!IsPlayerConnected(id)) return INVALID_PLAYER_ID;

	return id;
}
