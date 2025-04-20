/*
	To do list:


	-> add stamina bar when sprinting (walking increases sprint faster when its depleted)
	-> add health (on health = 0, cant spawn horse for 30 min depending on horse)
	-> add cart system and add a function to store objects on 

*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define INVALID_HORSE_ID 			(-1)

#define HORSE_OBJECT        		( HORSE_IDLE_INDEX )
//#define HORSE_OBJECT        		( 11733 )
#define COW_OBJECT        			( 19833 )

#define HORSE_SOUND_GALLOP		"http://play.wildwest-roleplay.com/files/sounds/horse/horse_running.mp3"
#define HORSE_SOUND_SNORT		"http://play.wildwest-roleplay.com/files/sounds/horse/horse_snort.wav"
#define HORSE_SOUND_WHINE		"http://play.wildwest-roleplay.com/files/sounds/horse/horse_whine.mp3"
#define HORSE_SOUND_SPAWN		"http://play.wildwest-roleplay.com/files/sounds/horse/horse_spawn.wav"
#define HORSE_SOUND_WHISTLE		"http://play.wildwest-roleplay.com/files/sounds/horse/horse_whistle.wav"

enum HorseData {

	HorseRandomNoiseTick,
	Float: HorseSprintValue,
	PlayerBar: HorseSprintBar,
	PlayerBar: HorseHealthBar,
	bool: PlayingHorseSound,
	bool: HorseRandomNoise,
	bool: HorseAbleToSprint,
	HorseReloadTick,
	bool: IsHorseSpawned
} ;


new Text: TD_HorseSprint ;
new Text: TD_HorseHealth ;

new PlayerHorse [ MAX_PLAYERS ] [ HorseData ] ;
new bool: IsPlayerRidingHorse [ MAX_PLAYERS ] ;
// horse model
new PlayerSpawnedHorse [ MAX_PLAYERS ] ;

new PlayerMountHorseCP [ MAX_PLAYERS ] [ 2 ] ;
new HorseObject [ MAX_PLAYERS ] ;
new CowObject [ MAX_PLAYERS ] ;

#include "utils/horse/header.pwn"
#include "utils/horse/func/anims.pwn"
#include "utils/horse/func/data.pwn"
#include "utils/horse/func/moving.pwn"
#include "utils/horse/func/mount.pwn"
#include "utils/horse/func/dmg.pwn" // -- This caused all horses to be damaged apparently. Disabled until further notice

LoadHorseSprintTextDraw () {

	TD_HorseSprint = TextDrawCreate(265.0, 320.0, "Horse Sprint");
	TextDrawColor(TD_HorseSprint, 0xD17F5EFF ) ;
    TextDrawLetterSize(TD_HorseSprint, 0.500, 1.500);
	TextDrawBackgroundColor(TD_HorseSprint, 51);
}


LoadHorseHealthTextDraw () {

	TD_HorseHealth = TextDrawCreate(265.0, 360.0, "Horse Health");
	TextDrawColor(TD_HorseHealth, 0xD17F5EFF ) ;
    TextDrawLetterSize(TD_HorseHealth, 0.500, 1.500);
	TextDrawBackgroundColor(TD_HorseHealth, 51);
}

Init_Horses () {

	for ( new i; i < MAX_PLAYERS; i ++ ) {

		HorseObject [ i ] = CreateDynamicObject(HORSE_OBJECT, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ) ;
		CowObject [ i ] = CreateDynamicObject(COW_OBJECT, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ) ;
	}

	printf(" [MOUNTS] Loaded %d horse and cow objects for mounting.", MAX_PLAYERS ) ;

	return true ;
}

public OnPlayerConnect(playerid) {

	PlayerSpawnedHorse [ playerid ] = INVALID_HORSE_ID ;

	#if defined horse_OnPlayerConnect
		return horse_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect horse_OnPlayerConnect
#if defined horse_OnPlayerConnect
	forward horse_OnPlayerConnect(playerid);
#endif

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:toghorsetds ( playerid, params [] ) {

	if ( ! strcmp ( params, "enable" ) ) {

		if ( ! IsPlayerRidingHorse [ playerid ] ) {

			return SendServerMessage ( playerid, "You're not riding a horse", MSG_TYPE_ERROR ) ; 
		}

		DestroyPlayerProgressBar(playerid, PlayerHorse [ playerid ] [ HorseHealthBar ] ) ;
		DestroyPlayerProgressBar(playerid, PlayerHorse [ playerid ] [ HorseSprintBar ] ) ;

		TextDrawHideForPlayer(playerid, TD_HorseHealth ) ;
		TextDrawHideForPlayer(playerid, TD_HorseSprint ) ;

		PlayerHorse [ playerid ] [ HorseSprintBar ] = CreatePlayerProgressBar(playerid, 265.0, 345.0, 105.0, 10.0, 0xD17F5EFF );
		SetPlayerProgressBarMaxValue(playerid, PlayerHorse [ playerid ] [ HorseSprintBar ], 100);
		SetPlayerProgressBarValue(playerid, PlayerHorse [ playerid ] [ HorseSprintBar  ], PlayerHorse [ playerid ] [ HorseSprintValue ]);
		ShowPlayerProgressBar(playerid, PlayerHorse [ playerid ] [ HorseSprintBar ] ) ;

		PlayerHorse [ playerid ] [ HorseHealthBar ] = CreatePlayerProgressBar(playerid, 265.0, 385.0, 105.0, 10.0, 0xD17F5EFF );
		SetPlayerProgressBarMaxValue(playerid, PlayerHorse [ playerid ] [ HorseHealthBar ], 100);
		SetPlayerProgressBarValue(playerid, PlayerHorse [ playerid ] [ HorseHealthBar  ], Character [ playerid ] [ character_horsehealth ] );
		ShowPlayerProgressBar(playerid, PlayerHorse [ playerid ] [ HorseHealthBar ] ) ;

		TextDrawShowForPlayer(playerid, TD_HorseHealth ) ;
		TextDrawShowForPlayer(playerid, TD_HorseSprint ) ;

		SendServerMessage ( playerid, "You have enabled your horse textdraws.", MSG_TYPE_INFO ) ;
	}

	else if ( ! strcmp ( params, "disable" ) ) {

		TextDrawHideForPlayer(playerid, TD_HorseHealth ) ;
		TextDrawHideForPlayer(playerid, TD_HorseSprint ) ;

		DestroyPlayerProgressBar(playerid, PlayerHorse [ playerid ] [ HorseHealthBar ] ) ;
		DestroyPlayerProgressBar(playerid, PlayerHorse [ playerid ] [ HorseSprintBar ] ) ;

		SendServerMessage ( playerid, "You have disabled your horse textdraws.", MSG_TYPE_INFO ) ;
	}

	else return SendServerMessage ( playerid, "/toghorsetds [enable / disable]", MSG_TYPE_ERROR ) ;


	return true ;
}

CMD:respawnhorse ( playerid, params [] ) {

	if ( Character [ playerid ] [ character_horseid ] == -1 ) {

		return SendServerMessage ( playerid, "You don't have a horse, so you can't revive it.", MSG_TYPE_ERROR ) ;
	}

	if ( IsPlayerRidingHorse [ playerid ] ) {

		return SendServerMessage ( playerid, "You can't do /respawnhorse while you're already on a horse", MSG_TYPE_ERROR ) ;
	}
	
	if ( IsValidDynamicCP (PlayerMountHorseCP [ playerid ] [ 0 ] ) ) {
		DestroyDynamicCP( PlayerMountHorseCP [ playerid ] [ 0 ] ) ;
	}
			
	if ( IsValidDynamicCP (PlayerMountHorseCP [ playerid ] [ 1 ] ) ) {
		DestroyDynamicCP( PlayerMountHorseCP [ playerid ] [ 1 ] ) ;
	}

	ClearAudioForZone ( playerid ) ;

	PlayerHorse [ playerid ] [ IsHorseSpawned ] = false ;
	IsPlayerRidingHorse [ playerid ] = false ;


	if ( Character [ playerid ] [ character_horseid ] < DONATOR_MOUNT_SLOT ) {
		SetDynamicObjectPos ( HorseObject [ playerid ], 0.0, 0.0, 0.0 ) ;
	}

	else SetDynamicObjectPos ( CowObject [ playerid ], 0.0, 0.0, 0.0 ) ;


	SendServerMessage ( playerid, "Your horse has been despawned. You can now use /spawnhorse again", MSG_TYPE_INFO ) ;
	//OldLog ( playerid, "horse/respawn", sprintf("(%d) %s has respawned their horse.", playerid, ReturnUserName ( playerid, true ))) ;

	return true ;
}

CMD:rsh(playerid, params[]){
	return cmd_respawnhorse(playerid, params);
}

CMD:nohorsesound ( playerid, params [] ) {

	if ( ! ToggleHorseSound [ playerid ] ) {

		ToggleHorseSound [ playerid ] = true ;

		SendServerMessage ( playerid, "Turned horse sound on. It can now replace ambient sound.", MSG_TYPE_INFO ) ;
	}

	else if ( ToggleHorseSound [ playerid ] ) {

		ToggleHorseSound [ playerid ] = false ;

		SendServerMessage ( playerid, "Turned horse sound off. Your ambient should now play over it.", MSG_TYPE_INFO ) ;
	}

	return true ;
}

CMD:spawnhorse ( playerid, params [] ) {

	//if ( ! Character [ playerid ] [ SelectedCharacter [ playerid ] ] [ character_horseid ] ) {
	if ( Character [ playerid ] [ character_horseid ] == -1 ) {

		return SendServerMessage ( playerid, "You don't have a horse.", MSG_TYPE_ERROR ) ;
	}

	if ( Character [ playerid ] [ character_horsehealth ] <= 0 ) {

		return SendServerMessage ( playerid, "Your horse is dead. Go to a stablemaster and /revive it.", MSG_TYPE_ERROR ) ;
	}

	if ( PlayerHorse [ playerid ] [ IsHorseSpawned ] ) {

		return SendServerMessage ( playerid, "You already have a horse spawned. Use /respawnhorse to despawn it.", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerFree ( playerid ) ) {

		return SendServerMessage ( playerid, "You can't spawn your horse right now.", MSG_TYPE_ERROR ) ;
	}

	if ( GetPlayerInterior ( playerid ) || GetPlayerVirtualWorld ( playerid ) ) {

		return SendServerMessage ( playerid, "You can only spawn a horse outside.", MSG_TYPE_ERROR ) ;
	}

	new type = Character [ playerid ] [ character_horseid ] ;
	if ( type == 0 || type == 4 || type == 5 ) {

		SendServerMessage ( playerid, "Your horse ID has been temporarily disabled due to a bug. You've been given a free (expensive) replacement!", MSG_TYPE_WARN);
		Character [ playerid ] [ character_horseid ] = 3 ;
	} 

	SendServerMessage ( playerid, "You've called your horse. It should be here soon.", MSG_TYPE_INFO ) ;
	PlayAudioStreamForPlayer ( playerid, HORSE_SOUND_WHISTLE, 0, 0, 0, 5.0, false ) ;

	//OldLog ( playerid, "horse/spawn", sprintf("(%d) %s has tried to spawn their horse.", playerid, ReturnUserName ( playerid, true ))) ;

	PlayerHorse [ playerid ] [ IsHorseSpawned ] = true ;
	defer HorseSpawnInit(playerid);

	return true ;
}

CMD:sh(playerid, params[]){
	return cmd_spawnhorse(playerid, params);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

timer HorseSpawnInit[2000](playerid ) {
	
////	print("HorseSpawnInit timer called (horse/base.pwn)");

	PlayAudioStreamForPlayer ( playerid, HORSE_SOUND_SPAWN, 0, 0, 0, 5.0, false ) ;

	defer HorseSpawnTick(playerid);
}

timer HorseSpawnTick[3000](playerid) {
	
	new Float: x, Float: y, Float: z, Float:angle, type = Character [ playerid ] [ character_horseid ] ;

	PlayerSpawnedHorse [ playerid ] = type;
	GetPlayerPos ( playerid, x, y, z ) ;
	GetPlayerFacingAngle ( playerid, angle ) ;
	GetXYRightOfPlayer ( playerid, x, y, 1.0 ) ;

	if ( Character [ playerid ] [ character_horseid ] < DONATOR_MOUNT_SLOT ) {
		if (! IsValidDynamicObject ( HorseObject [ playerid ] ) ) {

			return SendServerMessage ( playerid, "Failed to create horse", MSG_TYPE_ERROR );
		}

		//SetDynamicObjectPos(HorseObject [ playerid ], x, y, z - 0.2 ) ;
		//SetDynamicObjectRot(HorseObject [ playerid ],0.0,-90.0,angle-90);
		//SetDynamicObjectMaterial(HorseObject [ playerid ], 0, HORSE_OBJECT, "whore_rms", "WH_horse" ) ;

		new Float: a ;
		GetPlayerFacingAngle(playerid, a);

		SetupHorseObject(playerid, x, y, z, a );

		SendServerMessage ( playerid, "Your horse has spawned near your location. Press ~k~~VEHICLE_ENTER_EXIT~ to mount it. To toggle hud, use /toghorsetds.", MSG_TYPE_INFO ) ;
	}

	else {
		if (! IsValidDynamicObject ( CowObject [ playerid ] ) ) {

			return SendServerMessage ( playerid, "Failed to create horse", MSG_TYPE_ERROR );
		}

		SetDynamicObjectPos(CowObject [ playerid ], x, y, z - 1.2 ) ;
		SendServerMessage ( playerid, "Your cow has spawned near your location. Press ~k~~VEHICLE_ENTER_EXIT~ to mount it. To toggle hud, use /toghorsetds.", MSG_TYPE_INFO ) ;
	}

	SetupHorseCheckpoints ( playerid ) ;
	Streamer_Update(playerid,STREAMER_TYPE_OBJECT);

	return true ;
}

SetupHorseCheckpoints ( playerid ) {

	new Float: left_x, Float: left_y,
		Float: right_x, Float: right_y,
		Float: pos_z ;

	GetPlayerPos ( playerid, pos_z, pos_z, pos_z ) ;

	if ( Character [ playerid ] [ character_horseid ] < DONATOR_MOUNT_SLOT ) {
	
		GetXYInAtOffsetOfObject ( HorseObject [ playerid ], left_x, left_y, 1.0, 180 ) ;	
		GetXYInAtOffsetOfObject ( HorseObject [ playerid ], right_x, right_y, 1.0, 0 ) ;
	}

	else {

		GetXYInAtOffsetOfObject ( CowObject [ playerid ], left_x, left_y, 1.0, 90 ) ;	
		GetXYInAtOffsetOfObject ( CowObject [ playerid ], right_x, right_y, 1.0, 270 ) ;
	}

	PlayerMountHorseCP [ playerid ] [ 0 ] = CreateDynamicCP( left_x, left_y, pos_z, 1.0, -1, -1, playerid, 2.5 ) ;
	PlayerMountHorseCP [ playerid ] [ 1 ] = CreateDynamicCP( right_x, right_y, pos_z, 1.0, -1, -1, playerid, 2.5 ) ;

	return true ;
}