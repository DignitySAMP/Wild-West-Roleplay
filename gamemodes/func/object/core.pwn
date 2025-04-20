#include "func/object/static/noprops.pwn"
#include "func/object/static/roads.pwn"

#include "func/object/dynamic/foilage.pwn"
#include "func/object/dynamic/gate.pwn"
#include "func/object/dynamic/maploader.pwn"

//#include "func/object/models.pwn"
//#include "func/object/models_data.pwn"

ObjectHandler () {

	RemoveBuildingsWithCol(); // removed buildings
	CA_Init(); // load removed buildings with CA 

	Foilage_Init () ; // initiate foilage system
	AdminJail_Init () ; // loads admin jail map

	Gates_Init () ;

	MapHandler () ; // loads all maps in scriptfiles/maps
	LoadRoadObjects () ; // loads converted roads

	Init_MapGangZones () ;

	new txt_map ;

	// Tree of hope
	txt_map = CreateDynamicObject(11420, -2090.83594, 2314.06250, 23.82556,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0, 726, "gtatreesh", "oakbark64", 0xFFFFFFFF);

	txt_map = CreateDynamicObject(737, -2092.5, 2314.66016, 24.85,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0, 726, "gtatreesh", "oakbark64", 0xFFFFFFFF);
	SetDynamicObjectMaterial(txt_map, 1, 1829, "kbmiscfrn2", "man_mny1", 0xFFFFFFFF);

	Init_SpawnInfo ( );
}

new map_gangZone [ 5 ] ;
new map_gangZonesLoaded [ MAX_PLAYERS ] ;

Init_MapGangZones () {

	map_gangZone [ 0 ] = GangZoneCreate( -3000, -3000.000045776367, -1892, 2016.4999542236328 ) ;
	map_gangZone [ 1 ] = GangZoneCreate( -1892, -3000, -1236, 1590.5 ) ;
	map_gangZone [ 2 ] = GangZoneCreate( -1236, -3000, 3000, 577.5 ) ;
	map_gangZone [ 3 ] = GangZoneCreate( -901.9998779296875, 2188, 3000.0001220703125, 3000 ) ;
	map_gangZone [ 4 ] = GangZoneCreate( -478, 576, 2998, 2188 ) ;
}

public OnPlayerSpawn ( playerid ) {


	//Streamer_SetVisibleItems ( STREAMER_TYPE_OBJECT, 1000, playerid ); 

	if ( ! map_gangZonesLoaded [ playerid ] ) {

		map_gangZonesLoaded [ playerid ] = true ;

		Load_MapGangZones ( playerid ) ;
	}
	
	#if defined gz_OnPlayerSpawn
		return gz_OnPlayerSpawn(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerSpawn
	#undef OnPlayerSpawn
#else
	#define _ALS_OnPlayerSpawn
#endif

#define OnPlayerSpawn gz_OnPlayerSpawn
#if defined gz_OnPlayerSpawn
	forward gz_OnPlayerSpawn(playerid);
#endif

Load_MapGangZones ( playerid ) {

	for ( new i; i < sizeof ( map_gangZone ); i ++ ) {
		GangZoneShowForPlayer(playerid, map_gangZone [ i ] , 0x000000FF ) ;
	}
}

AdminJail_Init () {

	CreateDynamicObject(18856, -869.82867, 2308.63770, 156.71696,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19087, -869.89563, 2308.86914, 160.67020,   0.00000, 0.00000, 0.00000);
}

Init_SpawnInfo () {
	new txt_map ;

	// OOC SPAWN INFO
	txt_map = CreateDynamicObject(19329, -829.87097, 1091.17126, 35.80889,   0.00000, 0.00000, -53.70000);
	SetDynamicObjectMaterial(txt_map, 0, 13694, "lahillstxd1a", "planks01", 0xFFFFFFFF);

	txt_map = CreateDynamicObject(19329, -829.87213, 1091.15125, 35.80889,   0.00000, 0.00000, -53.70000);
	SetDynamicObjectMaterialText(txt_map, 0, "(( Welcome to Wild West Roleplay.\n\nYou should probably head to a nearby settlement and\nequip yourself with a fishing rod and start catching\nfish for money. Then you can headto Bayside\nand buy yourself a horse and maybe better tools\nfor other jobs such as mining, woodcutting\nor hunting.\n\nFor help, use /help, /ask or /report when in trouble.))",
		OBJECT_MATERIAL_SIZE_512x256, "Arial", 24, 1, 0xFFAAC4E5 ) ;

	// IC SPAWN INFO
	txt_map = CreateDynamicObject(19327, -829.87097, 1091.17126, 34.69724,   0.00000, 0.00000, -53.70003);
	SetDynamicObjectMaterial(txt_map, 0, 13694, "lahillstxd1a", "planks01", 0xFFFFFFFF);

	txt_map = CreateDynamicObject(19327, -829.87097, 1091.17053, 34.69724,   0.00000, 0.00000, -53.70003);
	SetDynamicObjectMaterialText(txt_map, 0, "GREETINGS TRAVELER\n\nTHE TOWN OF FREMONT IS LOOKING FOR\nSOME FRESHLY ARRIVED MEN AND WOMEN TO\nREPORT THEIR ARRIVAL TO THE LOCAL TOWN-\nHOUSE. YOU'LL WANT TO START YOUR JOURNEY\nTHERE.\n\nSIGNED,\nTHE SAN ANDREAS JUDICIARY.",
		OBJECT_MATERIAL_SIZE_512x256 ) ;

}