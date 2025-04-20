/*

	RAIN ZONE SCRIPT:

It will start at id 0 
Id 0 = cloudy, id 1 = rainy 
id 2 = cloudy too 
And it increments 
id 0 = fine, id 1 = cloudy, id 2 = rainy, id 3 = cloudy
And so on
It counts up
then down again
other than ^ we will only have 2-3 sunny ints

*/


enum ZoneData { 
	zone_name [ 36 ], 
	bool: zone_safezone,
	Float: zone_minx, 
	Float: zone_miny, 
	Float: zone_maxx, 
	Float: zone_maxy,
	zone_audio [ 128 ],
	zone_color
} ;

new Zones [ ] [ ZoneData ] = {
	{ "Bayside", 					true, -3000.0000, 2084.0000, -2159.0000, 3000.0000, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_blackwater.mp3" , 				0xDEDEDE22}, 
	{ "Fremont", 				true, -920.75341, 1359.0208, -566.75341, 1656.0208, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_las_hermanas.mp3" , 				0xDEDEDE22}, 
	{ "Longcreek", 				true, -1736.0100, 2432.0000, -1246.0103, 3000.0000, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_armadillo.mp3" , 				0xDEDEDE22},
	{ "Butter Bridge", 				false, -2159.0000, 2434.0000, -1736.0000, 3000.0000, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_butter_bridge.mp3" , 			0xDEDEDE22},// very light green
	{ "Hamlins Passing", 			false, -2159.0000, 2084.0000, -1631.0000, 2434.0000, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_hamlins_passing.mp3" , 			0xDEDEDE22}, // very light yellow
	{ "El Quebrados Docks", 		false, -1246.0346, 2571.0000, -1116.0346, 3000.0000, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_pacific_railroad_union.mp3" , 	0xDEDEDE22}, // very light orange
	{ "Cueva Seca", 				false, -1631.0103, 2166.0104, -1245.0103, 2434.0104, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_cueva_seca.mp3" , 				0xDEDEDE22}, // very light red/orange
	{ "El Matadero", 				false, -1246.0242, 2225.0000, -946.02423, 2571.0000, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_el_matadero.mp3" , 				0xDEDEDE22}, // pink
	{ "Fort Earp", 					false, -1245.0242, 2083.0070, -958.02423, 2225.0069, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_benedict_point.mp3" , 			0xDEDEDE22}, // pink/purple
	{ "Escalera", 					false, -1631.0103, 2084.0103, -1245.0103, 2167.0103, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_escalera.mp3" , 				0xDEDEDE22}, // light purple
	{ "Casa Madrugada", 			false, -1864.7290, 1602.0103, -1533.7290, 2084.0103, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_casa_madraguda.mp3" , 			0xDEDEDE22}, // light blue
	{ "Nekoti Rock North", 			false, -1231.7395, 1656.0173, -662.73950, 2083.0173, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_nekoti_rock_2.mp3" , 			0xDEDEDE22}, // cyan
	{ "Nekoti Rock South", 			false, -1231.7395, 1202.0208, -920.73950, 1656.0208, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_nekoti_rock_1.mp3" , 			0xDEDEDE22}, // baby green (mix of light blue & green)
	{ "New El Matadero", 			false, -1169.7290, 921.02429, -791.72900, 1203.0242, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_el_matadero.mp3" , 				0xDEDEDE22}, // light green
	{ "Rattlesnake Hollow", 		false, -920.75341, 1202.0242, -573.75341, 1360.0242, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_rattlesnake_hollow.mp3" , 		0xDEDEDE22}, // heavy green
	{ "Rio Bravado", 				false, -791.73950, 921.03811, -526.73950, 1203.0381, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_rio_bravado.mp3" , 				0xDEDEDE22}, // heavy orange
	{ "Thieves Landing", 			false, -963.72900, 624.03807, -562.72900, 921.03807, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_thieves_landing.mp3" , 			0xDEDEDE22}, // heavy blue
	{ "Torquenada", 				false, -1532.7291, 1601.0208, -1232.7291, 2084.0208, "http://play.wildwest-roleplay.com/files/sounds/ambient/ambient_torquenada.mp3" ,				0xDEDEDE22}, // heavy red
	{ "Refugee Camp", 				true, -2137.0156, -1583.9531, -1852.0156, -1358.953, "",																	0xFF0000FF },
	{ "Staff Island", 				true, 483.0675,-2747.5730, 694.5912,-2620.3042, 	 "",																	0xFF0000FF }
}, PlayerText: TD_ZoneName ;

new Zone_ID 		[ sizeof ( Zones ) ] ;
new Zone_Weather 	[ sizeof ( Zones ) ] ;

#include "utils/zones/deer/anim.pwn"
#include "utils/zones/deer/deers.pwn"

#include "utils/zones/temperature/data.pwn"
#include "utils/zones/temperature/func.pwn"
#include "utils/zones/temperature/utils.pwn"

CMD:resyncambient ( playerid, params [] ) {

	ClearAudioForZone ( playerid ) ;

	return true ;
}

IsZoneSafeZone ( zoneid ) {

	if ( zoneid < 0 || zoneid > sizeof ( Zones ) ) {

		return false ;
	}

	if ( Zones [ zoneid ] [ zone_safezone ] ) {

		return true ;
	}

	else return false ;
}

GetPlayerZone ( playerid ) {

	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);

	for ( new i, p = sizeof ( Zones ); i < p; i ++ ) {

		if ( X >= Zones [ i ] [ zone_minx ] && X <= Zones [ i ] [ zone_maxx ] && Y >= Zones [ i ] [ zone_miny ] && Y <= Zones [ i ] [ zone_maxy ]) {

			return i;
		}

		else continue ;

	}

	return -1;
}

GetZone ( Float: x, Float: y ) {

	for ( new i, p = sizeof ( Zones ); i < p; i ++ ) {

		if ( x >= Zones [ i ] [ zone_minx ] && x <= Zones [ i ] [ zone_maxx ] && y >= Zones [ i ] [ zone_miny ] && y <= Zones [ i ] [ zone_maxy ]) {

			return i;
		}

		else continue ;

	}

	return -1 ;
}

// 8 * 18 = 144
Init_Zones () {


	for ( new zoneid, p = sizeof ( Zones ); zoneid < p; zoneid ++ ) {

		Zone_ID [ zoneid ] = CreateDynamicRectangle(Zones [ zoneid ] [ zone_minx ], Zones [ zoneid ] [ zone_miny ], Zones [ zoneid ] [ zone_maxx ], Zones [ zoneid ] [ zone_maxy ] ) ;
		Zone_Weather [ zoneid ] = random ( 7 ) ;
	}

	Init_Temperature();
}

LoadZoneTextDraws ( playerid ) {

	TD_ZoneName = CreatePlayerTextDraw(playerid, 70.0, 315.0, "Bayside"); //88,320
	PlayerTextDrawSetShadow (playerid, TD_ZoneName, 1 ) ;
	PlayerTextDrawAlignment(playerid, TD_ZoneName, 2) ;
	PlayerTextDrawColor(playerid, TD_ZoneName, 0xD17F5EFF ) ;
    PlayerTextDrawLetterSize(playerid, TD_ZoneName, 0.500, 1.500);
}


timer RefreshZoneWeather[1500000]() {

////	print("RefreshZoneWeather timer called (zones/core.pwn)");

	defer RefreshZoneWeather() ;

	for ( new i ; i < sizeof ( Zones ); i ++ ) {

		Zone_Weather [ i ] = random ( 7 ) ;

		foreach (new playerid: Player) {

			if ( IsPlayerInDynamicArea(playerid, Zone_ID [ i ] )) {
				
				SetPlayerWeather ( playerid, Zone_Weather [ i ] ) ;
			}
		}
	}

	SendClientMessageToAll(COLOR_STAFF, "[WEATHER]:{DEDEDE} The clouds have shifted and the weather has changed." ) ;

	return true ;
}

public OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid) {

	if ( IsPlayerLogged [ playerid ] || IsPlayerSpawned ( playerid ) ) {

		for ( new i, p = sizeof ( Zones); i < p; i ++ ) {
			if ( areaid == Zone_ID [ i ] && !IsPlayerInDynamicArea(playerid, zone_Sawmill) ) {

				if (  IsPlayerSpawned ( playerid ) ) {
					if ( IsPlayerRidingHorse [ playerid ] && ! ToggleHorseSound [ playerid ] ) {

						return false ;
					}

					PlayAudioStreamForPlayer(playerid, Zones [ i ] [ zone_audio ] ) ;
				}
				
				SetPlayerWeather(playerid, Zone_Weather [ i ] ) ;

				PlayerTextDrawSetString ( playerid, TD_ZoneName, Zones [ i ] [ zone_name ] ) ;
				PlayerTextDrawShow(playerid, TD_ZoneName ) ;

				if ( IsZoneSafeZone ( i ) ) {

					SendServerMessage ( playerid, "You have entered a safezone. Use /safezone to see whether you are in a safezone or not. For big crimes (shootouts, gangwars), you need admin permission.", MSG_TYPE_WARN ) ;
					SendServerMessage ( playerid, "In order to commit a small crime, three law enforcement officers have to be online (before 12 PM), after 12 PM only two will be necessary. (/servertime).", MSG_TYPE_WARN ) ;
				}

				if ( IsPlayerModerator ( playerid ) ) {

					SendServerMessage ( playerid, sprintf("Entered zone %s (%d), setting weather to ID %d, current temperature is %d F°", Zones [ i ] [ zone_name ], Zone_ID [ i ], Zone_Weather [ i ], GetZoneTemperature( i ) ), MSG_TYPE_INFO ) ;
				}

				return true ;
			}
		}
	}

	#if defined xf_OnPlayerEnterDynamicArea
		return xf_OnPlayerEnterDynamicArea(playerid, areaid );
	#else
		return true;
	#endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif

#define OnPlayerEnterDynamicArea xf_OnPlayerEnterDynamicArea
#if defined xf_OnPlayerEnterDynamicArea
	forward xf_OnPlayerEnterDynamicArea(playerid, areaid );
#endif