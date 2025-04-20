/*
	
	-> Add deer tracks similar to vampires, werewolves & humans system
	(use 25+ so that deers can actually be tracked similar to blood trail system)
	(use different colors based on which wildlife made the tracks. Store them in array?)
	-> /togdeertracks

	-> add bleeding

	--> done: also add object for this


	-> show deer injuries (amount of dmg & shots, bleeding, weapon-used) in textdraw attached to deer

*/

enum Deer_SpawnData {
	Float: deer_spawn_x,
	Float: deer_spawn_y,
	Float: deer_spawn_z
} ;

new Deer_SpawnList [ ] [ Deer_SpawnData ] = {

	{ -919.2032, 1614.0992, 12.7277 } , 	{ -977.9567, 1656.8232, 15.6419 } , 	{ -1006.9849, 1652.6407, 22.7273 } , 	{ -996.0553, 1707.4092, 27.0138 } , 	
	{ -1051.9691, 1652.4462, 26.3456 } , 	{ -1061.0510, 1593.0238, 35.5073 } , 	{ -1026.3185, 1548.1587, 34.3054 } , 	{ -1112.4777, 1537.7101, 26.1427 } ,
	{ -1105.7349, 1455.1195, 25.8297 } ,	{ -1072.4818, 1437.4626, 29.3036 } ,	{ -1033.2134, 1446.2333, 39.0494 } ,	{ -990.2241, 1494.5709, 45.9134 } ,	
	{ -956.7953, 1526.0132, 42.3180 } ,		{ -941.5871, 1476.8201, 32.9249 } ,		{ -935.2746, 1388.2479, 32.5852 } ,		{ -984.0363, 1358.8380, 37.4357 } ,
	{ -1057.5123, 1287.7014, 32.6907 } ,	{ -1004.0740, 1252.4928, 33.3209 } ,	{ -1029.3131, 1224.3553, 32.4038 } ,	{ -973.2197, 1209.1934, 33.2567 } ,
	{ -919.5264, 1207.4702, 33.6654 } ,		{ -919.1109, 1246.2853, 34.7479 } ,		{ -849.8588, 1268.4469, 31.2431 } ,		{ -866.2372, 1335.5842, 20.0050 } ,		
	{ -776.8287, 1327.4769, 12.9309 } ,		{ -711.1303, 1294.9825, 10.2821 } ,		{ -663.8408, 1257.2960, 8.2926 } ,		{ -693.3831, 1240.1075, 12.7563 } ,
	{ -732.7059, 1207.1342, 10.2808 } ,		{ -787.6644, 1216.2006, 16.5942 } ,		{ -829.7838, 1272.2344, 27.2192 } ,		{ -858.8256, 1309.0059, 27.3504 } ,
	{ -949.0411, 1322.3590, 39.2853 } ,		{ -937.6998, 1254.9709, 34.2674 } ,		{ -919.6797, 1127.0050, 28.4178 } ,		{ -910.5640, 1055.3156, 21.1797 } ,
	{ -888.7569, 957.8390, 13.6787 } ,		{ -794.0222, 1029.6490, 22.2207 } ,		{ -699.5302, 997.3762, 11.8699 } ,		{ -642.3528, 1026.3683, 11.6532 } ,		
	{ -657.7260, 1077.1514, 13.8238 } ,		{ -717.8650, 1087.6232, 31.3571 } ,		{ -898.3414, 1408.8009, 21.1652 } ,		{ -837.7463, 1834.0088, 59.7711 } ,
	{ -763.3408, 916.1074, 11.3901 } ,		{ -771.0136, 848.0956, 11.9858 } ,		{ -690.2916, 818.1524, 14.2806 } ,		{ -698.8465, 873.3869, 12.1933 } ,
	{ -778.3033, 815.3515, 13.6673 } ,		{ -809.1827, 702.0848, 18.0663 } ,		{ -874.5880, 749.1049, 17.7968 } ,		{ -864.5374, 847.4538, 18.4521 } ,		
	{ -871.4172, 1005.7673, 21.9177 } ,		{ -1169.5529, 1654.3617, 21.6186 } ,	{ -1288.9794, 1753.6917, 19.8423 } ,	{ -1212.1682, 1744.0001, 34.6396 } ,		
	{ -1151.6160, 1717.7490, 43.8305 } ,	{ -1114.1161, 1728.9453, 34.3785 } ,	{ -1101.0321, 1772.4818, 39.6508 } ,	{ -1123.4879, 1835.6528, 45.9539 } ,		
	{ -1137.3958, 1896.2426, 78.3863 } ,	{ -1109.9220, 1944.9630, 108.937 } ,	{ -1026.8738, 1945.4152, 117.685 } ,	{ -990.2603, 1927.5653, 117.3066 } ,
	{ -899.0238, 1820.3066, 66.9890 } ,		{ -1205.2705, 1819.0782, 41.2457 } ,	{ -1277.1479, 1863.8092, 39.3521 } ,	{ -1335.6655, 1946.1282, 49.2501 } ,	
	{ -994.5099, 1836.1853, 62.2397 } ,		{ -1353.0020, 2012.0447, 53.1052 } ,	{ -1441.9004, 1970.2419, 47.9535 } ,	{ -1497.0249, 1919.3917, 45.1581 } ,
	{ -1552.2966, 2012.7644, 50.9354 } ,	{ -1559.7242, 2103.8687, 52.0694 } ,	{ -1585.2578, 2207.4207, 49.6133 } ,	{ -1605.9069, 2247.0193, 45.6793 } ,	
	{ -1554.6606, 2317.8198, 50.9749 } ,	{ -1501.1667, 2265.2251, 45.8457 } ,	{ -1444.6571, 2212.0623, 50.1752 } ,	{ -1365.6193, 2195.6638, 50.2137 } ,
	{ -1612.1865, 2320.3901, 45.5616 } ,	{ -1336.7853, 2207.6594, 66.8782 } ,	{ -1377.7821, 2290.4912, 63.0987 } ,	{ -1385.6731, 2319.5742, 62.8861 } ,	
	{ -1460.6494, 2377.3838, 53.0541 } ,	{ -1524.6799, 2428.8979, 51.2313 } ,	{ -1544.7205, 2494.9612, 55.5329 } ,	{ -1648.6594, 2653.5950, 63.9318 } ,
	{ -1690.0934, 2627.4563, 73.6806 } ,	{ -1654.8618, 2597.1748, 80.8388 } ,	{ -1678.9794, 2518.7712, 88.8437 } ,	{ -1723.5006, 2491.7144, 92.7571 } ,	
	{ -1747.4288, 2544.7083, 103.891 } ,	{ -1789.8344, 2591.6895, 90.5358 } ,	{ -1808.4083, 2713.9385, 57.2501 } ,	{ -1851.0405, 2714.1563, 68.4539 } ,
	{ -1897.8241, 2722.7710, 82.4816 } ,	{ -1948.9832, 2723.4302, 101.638 } ,	{ -1973.5819, 2710.7153, 115.310 } ,	{ -1985.8571, 2686.8213, 124.456 } ,
	{ -1992.0703, 2639.1094, 116.304 } ,	{ -1955.4613, 2545.1855, 52.5160 } ,	{ -1953.8287, 2417.5898, 51.3917 } ,	{ -2031.5077, 2442.9937, 40.3947 } ,
	{ -2039.2024, 2488.6626, 51.2433 } ,	{ -2081.0398, 2520.3967, 55.9947 } ,	{ -2104.9194, 2535.4438, 59.6540 } ,	{ -2126.0129, 2532.3723, 48.9609 } ,
	{ -2078.0210, 2491.0071, 52.1469 } ,	{ -2045.7417, 2409.3870, 35.9969 } ,	{ -2040.9607, 2366.5059, 4.9115 } ,		{ -2032.0103, 2274.8845, 17.9488 } ,
	{ -2048.6328, 2269.4417, 17.3537 } ,	{ -2076.8237, 2277.9072, 16.0253 } ,	{ -2080.6094, 2304.0105, 22.9987 } ,	{ -2006.1404, 2246.5464, 16.5097 } ,
	{ -1864.8777, 2246.6074, 22.9496 } ,	{ -1827.4565, 2244.4832, 16.6090 } ,	{ -1781.0536, 2221.8977, 4.0717 } ,		{ -1713.3726, 2227.2917, 5.6168 } ,
	{ -1936.2640, 2242.2925, 9.2133 } ,		{ -1640.1741, 2211.7815, 22.0343 } ,	{ -1582.7250, 2159.1953, 37.8567 } ,	{ -1571.6404, 2096.1765, 47.7451 } ,
	{ -1542.8096, 2029.8356, 55.0540 } ,	{ -1523.4285, 1947.7059, 47.2572 } ,	{ -1461.6262, 1901.5078, 45.3537 } ,	{ -1416.5715, 1928.9171, 50.9657 } ,
	{ -1384.9929, 1951.9711, 48.7503 } ,	{ -1310.9612, 2006.2684, 62.8208 } ,	{ -1283.1782, 2030.9860, 74.0848 } ,	{ -1088.3037, 2259.8865, 87.4153 } ,
	{ -1162.7185, 2301.1704, 109.852 } ,	{ -1178.6671, 2374.5835, 110.793 } ,	{ -1171.5781, 2445.3982, 107.355 } ,	{ -1168.3787, 2483.2334, 110.401 } ,
	{ -1212.0974, 2509.6204, 110.780 } ,	{ -1284.4702, 2544.6497, 85.6880 } ,	{ -1298.2166, 2567.4626, 85.3843 } ,	{ -1283.8579, 2592.5410, 87.3877 } ,
	{ -1285.3501, 2283.1929, 132.2055 },	{ -2106.8547, 2709.5488, 161.7418 } ,	{ -2154.7981, 2712.4285, 160.5036 },	{ -2468.9922, 2792.1875, 135.304 } 
};

#define WILDLIFE_RUN_SPEED		6.5
#define WILDLIFE_WALK_SPEED		1.5

enum { // wildlife states

	WILDLIFE_STATE_INACTIVE,
	WILDLIFE_STATE_WALK,
	WILDLIFE_STATE_RUN,
	WILDLIFE_STATE_DEAD
}

enum WildlifeData {
	wildlife_id,

	wildlife_model,
	wildlife_object,

	wildlife_area,
	wildlife_state,
	wildlife_anim_tick,

	wildlife_health,
	wildlife_recentlyharvested,

	Float: wildlife_old_x,
	Float: wildlife_old_y,
	Float: wildlife_old_z
}

#define MAX_WILDLIFE      ( sizeof ( Deer_SpawnList ) )
new Wildlife [ MAX_WILDLIFE ] [ WildlifeData ] ;
/*
#define MAX_TRACKS_LABELS		( 25 )
new DynamicText3D: WildlifeTrackLabel 	[ MAX_WILDLIFE ] [ MAX_TRACKS_LABELS ] ;

new WildlifeTrackCount 			[ MAX_WILDLIFE ] ;
new WildlifeTrackTick 			[ MAX_WILDLIFE ] ;*/

#define WILDLIFE_OBJ_DEER		( 19315 )
#define WILDLIFE_OBJ_HORSE		( 11733 )
#define WILDLIFE_OBJ_COW		( 19833 )

#define COLOR_DEER		( 0xC4B3A5AA )
#define COLOR_COW		( 0xA5BBC4AA )

new deerCount ;

Init_Deers () {

	for ( new i; i < MAX_WILDLIFE; i ++ ) {
		
		Wildlife [ i ] [ wildlife_id ] = -1 ;
		CreateWildlife ( i ) ;
	}

	printf(" * [WILDLIFE] Created %d wildlife.", deerCount ) ;
	CreateMeatObjects ( ) ;
}

new Harvested_Deers [ MAX_WILDLIFE ] ;
new Harvested_Cows [ MAX_WILDLIFE ] ;

CreateMeatObjects ( ) {

	new count ;

	for ( new i; i < MAX_WILDLIFE; i ++ ) {

		Harvested_Deers [ i ] = CreateDynamicObject(WILDLIFE_OBJ_DEER, 0, 0, 0, 0, 0, 0);
		SetDynamicObjectMaterial( Harvested_Deers [ i ], 0, 2804, "CJ_MEATY", "CJ_FLESH_2") ; // skinned


		Harvested_Cows [ i ] = CreateDynamicObject(WILDLIFE_OBJ_COW, 0, 0, 0, 0, 0, 0);
		SetDynamicObjectMaterial( Harvested_Cows [ i ], 0, 2804, "CJ_MEATY", "CJ_FLESH_1") ; // skinned	

		count ++ ;
	}

	printf("* [WILDLIFE] Created %d skinned entities.", count * 2) ;

	return true ;
}

CMD:respawndeers ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be at least a moderator in order to be able to do this.", MSG_TYPE_ERROR ) ;
	}


	if ( GetStaffGroup ( playerid ) < GENERAL_MOD ) {

		return SendServerMessage ( playerid, "You need to be a general moderator in order to be able to perform this command.", MSG_TYPE_ERROR ) ;
	}


	new Float: wildlife_x, Float: wildlife_y, Float: wildlife_z, Float: rotation ;

	switch ( random ( 4 ) ) {
		case 0: rotation = 90 ;
		case 1: rotation = 180 ;
		case 2: rotation = 270 ;
		case 3: rotation = 360 ;
	}

	for ( new i; i < MAX_WILDLIFE; i ++ ) {

		SetDynamicObjectPos(Wildlife [ i ] [ wildlife_object ], Deer_SpawnList [ i ] [ deer_spawn_x ], Deer_SpawnList [ i ] [ deer_spawn_y ], Deer_SpawnList [ i ] [ deer_spawn_z ] ) ;
		SetDynamicObjectRot ( Wildlife [ i ] [ wildlife_object ], 0, 0, rotation ) ;

		Wildlife [ i ] [ wildlife_state ] = WILDLIFE_STATE_WALK ;
		Wildlife [ i ] [ wildlife_health ] = 100 ;

		Wildlife [ i ] [ wildlife_id ] = i ;
		//Wildlife [ i ] [ wildlife_area ] = CreateDynamicCircle(Deer_SpawnList [ i ] [ deer_spawn_x ], Deer_SpawnList [ i ] [ deer_spawn_y ], 5.0);

		if ( Wildlife [ i ] [ wildlife_model ] == WILDLIFE_OBJ_DEER ) {

			SetDynamicObjectPos ( Harvested_Deers [ i ], 0.0, 0.0, 0.0 ) ;
		}

		else if ( Wildlife [ i ] [ wildlife_model ] == WILDLIFE_OBJ_COW ) {

			SetDynamicObjectPos ( Harvested_Cows [ i ], 0.0, 0.0, 0.0 ) ;
		}

	//	AttachDynamicAreaToObject(Wildlife [ i ] [ wildlife_area ], Wildlife [ i ] [ wildlife_object ]);
		GetXYInFrontOfWildlife(Wildlife [ i ] [ wildlife_object ], wildlife_x, wildlife_y, 2.0) ;

		// Dynamic Circle has to be xow spawn point
		CA_FindZ_For2DCoord( wildlife_x, wildlife_y, wildlife_z );
		MoveDynamicObject (Wildlife [ i ] [ wildlife_object ], wildlife_x, wildlife_y, wildlife_z, 1.5 ) ;
	}

	SendModeratorWarning ( sprintf("[DEERS] (%d) %s has respawned all the wildlife.", playerid, ReturnUserName ( playerid )), MOD_WARNING_MED ) ;

	return true ;
}

CMD:respawndeer(playerid, params[]) {

	if ( playerid != INVALID_PLAYER_ID ) {
		if ( ! IsPlayerModerator ( playerid ) ) {

			return SendServerMessage ( playerid, "You need to be at least a moderator in order to be able to do this.", MSG_TYPE_ERROR ) ;
		}
	}

	new i ;

	if ( sscanf ( params, "i", i ) ) {

		return SendServerMessage ( playerid, "/respawndeer [id]", MSG_TYPE_ERROR ) ;
	}

	new Float: wildlife_x, Float: wildlife_y, Float: wildlife_z, Float: rotation ;

	switch ( random ( 4 ) ) {
		case 0: rotation = 90 ;
		case 1: rotation = 180 ;
		case 2: rotation = 270 ;
		case 3: rotation = 360 ;
	}

	SetDynamicObjectPos(Wildlife [ i ] [ wildlife_object ], Deer_SpawnList [ i ] [ deer_spawn_x ], Deer_SpawnList [ i ] [ deer_spawn_y ], Deer_SpawnList [ i ] [ deer_spawn_z ] ) ;
	SetDynamicObjectRot ( Wildlife [ i ] [ wildlife_object ], 0, 0, rotation ) ;

	Wildlife [ i ] [ wildlife_state ] = WILDLIFE_STATE_WALK ;
	Wildlife [ i ] [ wildlife_health ] = 100 ;

	Wildlife [ i ] [ wildlife_id ] = i ;
	//Wildlife [ i ] [ wildlife_area ] = CreateDynamicCircle(Deer_SpawnList [ i ] [ deer_spawn_x ], Deer_SpawnList [ i ] [ deer_spawn_y ], 5.0);

	if ( Wildlife [ i ] [ wildlife_model ] == WILDLIFE_OBJ_DEER ) {

		SetDynamicObjectPos ( Harvested_Deers [ i ], 0.0, 0.0, 0.0 ) ;
	}

	else if ( Wildlife [ i ] [ wildlife_model ] == WILDLIFE_OBJ_COW ) {

		SetDynamicObjectPos ( Harvested_Cows [ i ], 0.0, 0.0, 0.0 ) ;
	}

	GetXYInFrontOfWildlife(Wildlife [ i ] [ wildlife_object ], wildlife_x, wildlife_y, 2.0) ;

	// Dynamic Circle has to be xow spawn point
	CA_FindZ_For2DCoord( wildlife_x, wildlife_y, wildlife_z );
	MoveDynamicObject (Wildlife [ i ] [ wildlife_object ], wildlife_x, wildlife_y, wildlife_z, 1.5 ) ;

	SendModeratorWarning ( sprintf("[DEERS] (%d) %s has respawned wildlife ID %d.", playerid, ReturnUserName ( playerid ), i), MOD_WARNING_MED ) ;

	return true ;
}

CreateWildlife ( spawnid ) {

	new wildlifecount = FindEmptyWildlifeSlot () ;

	if ( wildlifecount == -1 ) {

		return printf("[Wildlife ERROR]: No slots left. Returned %d", wildlifecount ) ;
	}

	if ( spawnid >= sizeof ( Deer_SpawnList ) ) {

		return printf("Spawn ID %d exceeded %d", spawnid, sizeof ( Deer_SpawnList ) ) ;
	}

	new Float: wildlife_x, Float: wildlife_y, Float: wildlife_z, Float: rotation ;


	switch ( random ( 4 ) ) {
		case 0: rotation = 90 ;
		case 1: rotation = 180 ;
		case 2: rotation = 270 ;
		case 3: rotation = 360 ;
	}

	switch ( random ( 2 ) ) {
		case 0: {
			Wildlife [ wildlifecount ] [ wildlife_object ] = CreateDynamicObject (WILDLIFE_OBJ_DEER, 
				Deer_SpawnList [ spawnid ] [ deer_spawn_x ], Deer_SpawnList [ spawnid ] [ deer_spawn_y ], Deer_SpawnList [ spawnid ] [ deer_spawn_z ], 0, 0, rotation ) ;

			Wildlife [ wildlifecount ] [ wildlife_model ] = WILDLIFE_OBJ_DEER ;
		}

		case 1: {
			Wildlife [ wildlifecount ] [ wildlife_object ] = CreateDynamicObject (WILDLIFE_OBJ_COW, 
				Deer_SpawnList [ spawnid ] [ deer_spawn_x ], Deer_SpawnList [ spawnid ] [ deer_spawn_y ], Deer_SpawnList [ spawnid ] [ deer_spawn_z ], 0, 0, rotation ) ;	

			Wildlife [ wildlifecount ] [ wildlife_model ] = WILDLIFE_OBJ_COW ;
		}
	}	

	Wildlife [ wildlifecount ] [ wildlife_state ] = WILDLIFE_STATE_WALK ;
	Wildlife [ wildlifecount ] [ wildlife_health ] = 100 ;

	Wildlife [ wildlifecount ] [ wildlife_id ] = wildlifecount ;
	Wildlife [ wildlifecount ] [ wildlife_area ] = CreateDynamicCircle(Deer_SpawnList [ spawnid ] [ deer_spawn_x ], Deer_SpawnList [ spawnid ] [ deer_spawn_y ], 5.0);
	
	AttachDynamicAreaToObject(Wildlife [ wildlifecount ] [ wildlife_area ], Wildlife [ wildlifecount ] [ wildlife_object ]);
	GetXYInFrontOfWildlife(Wildlife [ wildlifecount ] [ wildlife_object ], wildlife_x, wildlife_y, 2.0) ;

	// Dynamic Circle has to be xow spawn point
	CA_FindZ_For2DCoord( wildlife_x, wildlife_y, wildlife_z );
	MoveDynamicObject (Wildlife [ wildlifecount ] [ wildlife_object ], wildlife_x, wildlife_y, wildlife_z, 1.5 ) ;
	
	//defer WildlifeTrailHandler[1500+random(4500)](wildlifecount);

	printf(" * [DEER] Creating deer id %d (oid %d) at %f %f %f", wildlifecount, Wildlife [ wildlifecount ] [ wildlife_object ], 
		Deer_SpawnList [ spawnid ] [ deer_spawn_x ], Deer_SpawnList [ spawnid ] [ deer_spawn_y ], Deer_SpawnList [ spawnid ] [ deer_spawn_z ] ) ;

	deerCount ++ ;

	return true ;
}

public OnPlayerEnterDynamicArea(playerid, areaid){

	for(new wildlife = 0; wildlife < MAX_WILDLIFE; wildlife++) {

		if(Wildlife [ wildlife ] [ wildlife_area ] == areaid) {

			if ( Wildlife [ wildlife ] [ wildlife_state ] == WILDLIFE_STATE_DEAD && ViewingActionGUI [ playerid ] != ACTION_TYPE_GUN ) {

				SendServerMessage ( playerid, "You can skin this animal by equipping a hunting knife and pressing ~k~~SNEAK_ABOUT~.", MSG_TYPE_INFO ) ;

				SetupActionGUI ( playerid, ACTION_TYPE_DEER ) ;

				ActionPanel_ChangeGUI(playerid, "Press ~k~~SNEAK_ABOUT~ to start skinning this animal.") ;
				//PlayerTextDrawSetString(playerid, actionGUI_infoText , "Press ~k~~SNEAK_ABOUT~ to start skinning this deer.") ;

				return true ;
			}

			else if ( Wildlife [ wildlife ] [ wildlife_state ] == WILDLIFE_STATE_WALK ) {

				//switch ( GetDynamicObjectModel ( Wildlife [ wildlife ] [ wildlife_object ] ) ) {

					//case WILDLIFE_OBJ_DEER: {
						Wildlife [ wildlife ] [ wildlife_state ] = WILDLIFE_STATE_RUN;
						OnDynamicObjectMoved ( Wildlife [ wildlife ] [ wildlife_object ] ) ;
					//}
/*
					case WILDLIFE_OBJ_COW: {

						//PlayerTextDrawSetString(playerid, animalGUI_infoText { playerid }, "Keep pressing Y to milk cattle");
						//SetupAnimalGUI ( playerid, ANIMAL_TYPE_CATTLE ) ;

						Wildlife [ wildlife ] [ wildlife_state ] = WILDLIFE_STATE_INACTIVE;
						StopDynamicObject ( Wildlife [ wildlife ] [ wildlife_object ] ) ;
					}	*/	
				//}
			}

			return true ;
		}

		else continue ;
	}

	#if defined deer_OnPlayerEnterDynamicArea
		return deer_OnPlayerEnterDynamicArea(playerid, areaid );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif

#define OnPlayerEnterDynamicArea deer_OnPlayerEnterDynamicArea
#if defined deer_OnPlayerEnterDynamicArea
	forward deer_OnPlayerEnterDynamicArea(playerid, areaid );
#endif

public OnPlayerLeaveDynamicArea(playerid, areaid) {

	for(new wildlife = 0; wildlife < MAX_WILDLIFE; wildlife++) {

		if(Wildlife [ wildlife ] [ wildlife_area ] == areaid) {

			if ( ! IsMining [ playerid ] || ! IsFishing [ playerid ] || ! IsPlayerFishing [ playerid ] || ! IsCuttingTree[playerid] && ViewingActionGUI [ playerid ] != ACTION_TYPE_GUN ) {

				HideActionGUI ( playerid ) ;
			}

			if ( Wildlife [ wildlife ] [ wildlife_state ] == WILDLIFE_STATE_DEAD || Wildlife [ wildlife ] [ wildlife_state ]  == WILDLIFE_STATE_INACTIVE ) {

				return false ;
			}

/*

			NOTE: this didn't work properly, they didn't walk again so this njeeds to be checked before being reenabled
			if ( Wildlife [ wildlife ] [ wildlife_model ] == WILDLIFE_OBJ_COW && Wildlife [ wildlife ] [ wildlife_state ] != WILDLIFE_STATE_DEAD ) {

				Wildlife [ wildlife ] [ wildlife_state ] = WILDLIFE_STATE_WALK;
				OnDynamicObjectMoved ( Wildlife [ wildlife ] [ wildlife_object ] ) ;
			}

			if ( Wildlife [ wildlife ] [ wildlife_state ] == WILDLIFE_STATE_RUN ) {

				Wildlife [ wildlife ] [ wildlife_state ] = WILDLIFE_STATE_WALK;
				OnDynamicObjectMoved ( Wildlife [ wildlife ] [ wildlife_object ] ) ;
			}*/

			Wildlife [ wildlife ] [ wildlife_state ] = WILDLIFE_STATE_WALK;
			OnDynamicObjectMoved ( Wildlife [ wildlife ] [ wildlife_object ] ) ;

			Widllife_Harvest_Value [ playerid ] = 0 ;
		}
	}
	
	#if defined deer_OnPlayerLeaveDynamicArea
		return deer_OnPlayerLeaveDynamicArea(playerid, areaid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLeaveDynamicArea
	#undef OnPlayerLeaveDynamicArea
#else
	#define _ALS_OnPlayerLeaveDynamicArea
#endif

#define OnPlayerLeaveDynamicArea deer_OnPlayerLeaveDynamicArea
#if defined deer_OnPlayerLeaveDynamicArea
	forward deer_OnPlayerLeaveDynamicArea(playerid, areaid);
#endif

FindEmptyWildlifeSlot() {

	new i = 0;

	while ( i < sizeof ( Wildlife ) && Wildlife [ i ] [ wildlife_id ] != -1 ) {
		i++;
	}

	if ( i == sizeof (Wildlife ) ) return -1;

	return i;
}

CMD:gotodeer ( playerid, params [] ) {

	new id;

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You're not a moderator.", MSG_TYPE_ERROR ) ;
	}

	if ( sscanf ( params, "i", id ) ) {

		return SendServerMessage(playerid, "/gotodeer [id]", MSG_TYPE_ERROR) ;
	}

	new Float: x, Float: y, Float: z ;
	GetDynamicObjectPos(Wildlife [ id ] [ wildlife_object ], x, y, z ) ;
	ac_SetPlayerPos ( playerid, x, y, z ) ;

	SendClientMessage(playerid, -1, sprintf("deer id %d", id ) ) ;

	return true ;
}

/*
task Wildlife_ApplyAnimation[150]() {

	for ( new i, j = sizeof ( Wildlife ); i < j ; i ++ ) {

		switch ( Wildlife [ i ] [ wildlife_model ] ) {

			case WILDLIFE_OBJ_DEER: {
				switch ( Wildlife [ i ] [ wildlife_state ] ) {

					case WILDLIFE_STATE_WALK: {

					}

					case WILDLIFE_STATE_RUN: {
						if ( Wildlife [ i ] [ wildlife_anim_tick ] >= sizeof ( DeerSprintAnim ) || Wildlife [ i ] [ wildlife_anim_tick ] <= 0 ) {

							Wildlife [ i ] [ wildlife_anim_tick ] = 1 ;
						}

						new Float: rx, Float: ry, Float: rz ;
						GetDynamicObjectRot ( Wildlife [ i ] [ wildlife_object ], rx, ry, rz ) ;
						SetDynamicObjectRot ( Wildlife [ i ] [ wildlife_object ], rx, -90, rz );

						Streamer_SetIntData ( STREAMER_TYPE_OBJECT, Wildlife [ i ] [ wildlife_object ], E_STREAMER_MODEL_ID, DEER_SPRINT_INDEX + Wildlife [ i ] [ wildlife_anim_tick ] ) ;
						
						//printf("Setting object ID %d model to %d (%d - %d)", 
							//Wildlife [ i ] [ wildlife_object ], ( DEER_SPRINT_INDEX + Wildlife [ i ] [ wildlife_anim_tick ] ), DEER_SPRINT_INDEX, Wildlife [ i ] [ wildlife_anim_tick ]) ;
						

						Wildlife [ i ] [ wildlife_anim_tick ] ++ ;

						OnDynamicObjectMoved(Wildlife [ i ] [ wildlife_object ]) ;
					}
				}
			}
		}
	}

	return true ;
}
*/

new WildLifeWaterTick [ MAX_OBJECTS ] ;
public OnDynamicObjectMoved(objectid) {


	for ( new i, j = MAX_WILDLIFE; i < j; i ++ ) {

		if ( objectid == Wildlife [ i ] [ wildlife_object ] ) {

			if ( Wildlife [ i ] [ wildlife_state ] == WILDLIFE_STATE_DEAD || Wildlife [ i ] [ wildlife_state ] == WILDLIFE_STATE_INACTIVE ) {

				return true ;
			}

		 	new Float: next_x, Float: next_y, Float: next_z, Float: temp, Float: rot, Float: speed; //, anim_increment ;

		 	/*
		    if ( Wildlife [ i ] [ wildlife_state ] == WILDLIFE_STATE_RUN  ) {

		    	anim_increment = 90 ;
		    }
		    */

			Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_Z, rot);

			new Float: cur_x, Float: cur_y, Float: cur_z ;
			GetDynamicObjectPos(objectid, cur_x, cur_y, cur_z ) ;

			if ( cur_z == 0 ) {

				if ( ++ WildLifeWaterTick [ i ] >= 3 ) {

					cmd_respawndeer(INVALID_PLAYER_ID, sprintf("%d", i) ) ;
					WildLifeWaterTick [ i ] = 0 ;
				}
			}

			GetXYInFrontOfWildlife(objectid, next_x, next_y, 10.0 );
			CA_FindZ_For2DCoord(next_x, next_y, next_z);

			if ( IsWildlifeNearWater ( objectid ) || IsWildlifeInProperArea ( objectid ) < 0 || 
				CA_RayCastLine(cur_x, cur_y, cur_z, next_x, next_y, next_z, temp, temp, temp ) ) {

				new rotation = floatround ( rot, floatround_round ) ;

			    switch ( rotation ) {
			    	/*
		            case 10: 	SetDynamicObjectRot(objectid, 0, 0, 30 + anim_increment );
		            case 30: 	SetDynamicObjectRot(objectid, 0, 0, 60 + anim_increment );
		            case 60: 	SetDynamicObjectRot(objectid, 0, 0, 90 + anim_increment );
		            case 90:  	SetDynamicObjectRot(objectid, 0, 0, 120 + anim_increment );
		            case 120: 	SetDynamicObjectRot(objectid, 0, 0, 150 + anim_increment );
		            case 150:  	SetDynamicObjectRot(objectid, 0, 0, 180 + anim_increment );
		            case 180:  	SetDynamicObjectRot(objectid, 0, 0, 210 + anim_increment );
		            case 210:  	SetDynamicObjectRot(objectid, 0, 0, 240 + anim_increment );
		            case 240:  	SetDynamicObjectRot(objectid, 0, 0, 270 + anim_increment );
		            case 270:  	SetDynamicObjectRot(objectid, 0, 0, 300 + anim_increment );
		            case 300:  	SetDynamicObjectRot(objectid, 0, 0, 330 + anim_increment );
		            case 330:  	SetDynamicObjectRot(objectid, 0, 0, 360 + anim_increment );
		            case 360:  	SetDynamicObjectRot(objectid, 0, 0, 10 + anim_increment );
		            */
		            case 10: 	SetDynamicObjectRot(objectid, 0, 0, 30);
		            case 30: 	SetDynamicObjectRot(objectid, 0, 0, 60);
		            case 60: 	SetDynamicObjectRot(objectid, 0, 0, 90);
		            case 90:  	SetDynamicObjectRot(objectid, 0, 0, 120);
		            case 120: 	SetDynamicObjectRot(objectid, 0, 0, 150);
		            case 150:  	SetDynamicObjectRot(objectid, 0, 0, 180);
		            case 180:  	SetDynamicObjectRot(objectid, 0, 0, 210);
		            case 210:  	SetDynamicObjectRot(objectid, 0, 0, 240);
		            case 240:  	SetDynamicObjectRot(objectid, 0, 0, 270);
		            case 270:  	SetDynamicObjectRot(objectid, 0, 0, 300);
		            case 300:  	SetDynamicObjectRot(objectid, 0, 0, 330);
		            case 330:  	SetDynamicObjectRot(objectid, 0, 0, 360);
		            case 360:  	SetDynamicObjectRot(objectid, 0, 0, 10);
		            default:	StopDynamicObject(objectid);
			    }

			    GetDynamicObjectRot(objectid, temp, temp, rot ) ;
			}

			GetXYInFrontOfWildlife(objectid, next_x, next_y, 2.0 );
			CA_FindZ_For2DCoord(next_x, next_y, next_z);

			switch ( Wildlife [ i ] [ wildlife_state ] ) {

				case WILDLIFE_STATE_WALK: {
					speed = WILDLIFE_WALK_SPEED;
					GetXYInFrontOfWildlife(objectid, next_x, next_y, 2.0);
				}
				case WILDLIFE_STATE_RUN: {
					speed = WILDLIFE_RUN_SPEED;
					GetXYInFrontOfWildlife(objectid, next_x, next_y, 5.0);	
				}
			}

			MoveDynamicObject(objectid, next_x, next_y, next_z + 0.5, speed );


			if(DidAnimalTriggerTrap(i,1) != -1) {

				OnAnimalTriggerTrap(i,DidAnimalTriggerTrap(i,1));
			}

			continue ;
		}

		continue ;
	}

	#if defined deer_OnDynamicObjectMoved
		return deer_OnDynamicObjectMoved(objectid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnDynamicObjectMoved
	#undef OnDynamicObjectMoved
#else
	#define _ALS_OnDynamicObjectMoved
#endif

#define OnDynamicObjectMoved deer_OnDynamicObjectMoved
#if defined deer_OnDynamicObjectMoved
	forward deer_OnDynamicObjectMoved(objectid);
#endif

IsWildlifeInProperArea( objectid ) {

	new Float:X, Float:Y, Float:Z;
	GetDynamicObjectPos(objectid, X, Y, Z );

	for ( new i, p = sizeof ( Zones ); i < p; i ++ ) {

		if ( X >= Zones [ i ] [ zone_minx ] && X <= Zones [ i ] [ zone_maxx ] && Y >= Zones [ i ] [ zone_miny ] && Y <= Zones [ i ] [ zone_maxy ]) {

			return i;
		}

		else continue ;
	}

	return -1;
}

IsWildlifeNearWater ( objectid ) {
	new Float:x, Float:y, Float:z, Float:checkx, Float:checky, Float:checkz, Float:angle;
	
	#define         MAX_Z_FISH_THRESHOLD            4.0
	#define         WATER_CHECK_RADIUS              5.0

	GetDynamicObjectPos(objectid, x, y, z);
	
	// Make sure player is at correct Z-Height (Will not work near the dam)
	if(z > 0.0 && z < MAX_Z_FISH_THRESHOLD) {
		
		// Check North/East/South/West for water
		for(new i = 0; i < 4; i++) {
	        checkx = x + (WATER_CHECK_RADIUS * floatsin(-angle, degrees));
		    checky = y + (WATER_CHECK_RADIUS * floatcos(-angle, degrees));
			angle += 90.0;

			// Find the Z
			CA_FindZ_For2DCoord(checkx, checky, checkz);

			checkz -= 2.5 ;

			// Doesn't work under bridges
			if(checkz <= 0.0) return 1;
		}
	}

	#undef MAX_Z_FISH_THRESHOLD
	#undef WATER_CHECK_RADIUS

	return 0;
}

GetXYInFrontOfWildlife(objectid, &Float:x, &Float:y, Float:distance) {
	new Float:temp, Float:rot_z, modelid ;

	GetDynamicObjectPos(objectid, x, y, temp);
	GetDynamicObjectRot(objectid, temp, temp, rot_z);

	modelid = GetDynamicObjectModel ( objectid ) ;

	if ( modelid == WILDLIFE_OBJ_DEER ) {
		x += (distance * floatsin(-rot_z + 90, degrees));
		y += (distance * floatcos(-rot_z + 90 , degrees));
	}

	else if ( modelid == WILDLIFE_OBJ_COW ) {

		x += (distance * floatsin(-rot_z + 180, degrees));
		y += (distance * floatcos(-rot_z + 180 , degrees));
	}

	else if ( modelid == WILDLIFE_OBJ_HORSE ) {
		x += (distance * floatsin(-rot_z + 180, degrees));
		y += (distance * floatcos(-rot_z + 180 , degrees));
	}

	return true ;
}

Wildlife_Shot ( objectid, weaponid) {

	new deer_id ;

	for ( new i, j = MAX_WILDLIFE; i < j; i ++ ) {

		if ( objectid == Wildlife [ i ] [ wildlife_object ] ) {

			deer_id = i ;
			break ;
		}

		else continue ;
	}

	if ( Wildlife [ deer_id ] [ wildlife_state ] == WILDLIFE_STATE_DEAD ) return 1;

	new damage;
	switch(weaponid) {
		case 33: damage = 100;
		case 24: damage = 50;
		case 25: damage = 50;
		case 26: damage = 50;
		case 34: damage = 100;
		case 1000: damage = 100;
		default: damage = 20;
	}

	Wildlife [ deer_id ] [ wildlife_health ] -= damage;

	if(Wildlife [ deer_id ] [ wildlife_health ] <= 0)  {

		Wildlife [ deer_id ] [ wildlife_health ] = 0;

		new Float:rot, Float:ox, Float:oy, Float:oz;

		GetDynamicObjectPos(objectid, ox, oy, oz);
		Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_Z, rot);

		StopDynamicObject(objectid);
		SetDynamicObjectPos(objectid, ox, oy, oz-0.4);

		switch ( GetDynamicObjectModel ( Wildlife [ deer_id ] [ wildlife_object ] ) ) {

			case WILDLIFE_OBJ_DEER: SetDynamicObjectRot(objectid, 90, 0, rot);
			case WILDLIFE_OBJ_COW: SetDynamicObjectRot(objectid, 0, 90, rot);
		}

		Wildlife [ deer_id ] [ wildlife_state ] = WILDLIFE_STATE_DEAD;
		Streamer_SetFloatData(STREAMER_TYPE_AREA, Wildlife [ deer_id ] [ wildlife_area ], E_STREAMER_SIZE, 1.5);

		defer Wildlife_Respawn[300000](deer_id, objectid);
	}

	return 1;
}

timer Wildlife_Respawn[300000](deer_id, objectid) {

	#pragma unused objectid

	new Float: wildlife_x, Float: wildlife_y, Float: wildlife_z, Float: rotation ;

	Wildlife [ deer_id ] [ wildlife_state ] = WILDLIFE_STATE_WALK;

	switch ( random ( 4 ) ) {

		case 0: rotation = 90 ;
		case 1: rotation = 180 ;
		case 2: rotation = 270 ;
		case 3: rotation = 360 ;
	}
	
	if ( Wildlife [ deer_id ] [ wildlife_model ] == WILDLIFE_OBJ_DEER ) {

		SetDynamicObjectPos ( Harvested_Deers [ deer_id ], 0.0, 0.0, 0.0 ) ;
	}

	else if ( Wildlife [ deer_id ] [ wildlife_model ] == WILDLIFE_OBJ_COW ) {

		SetDynamicObjectPos ( Harvested_Cows [ deer_id ], 0.0, 0.0, 0.0 ) ;
	}

	SetDynamicObjectPos(Wildlife [ deer_id ] [ wildlife_object ], Wildlife [ deer_id ] [ wildlife_old_x ], Wildlife [ deer_id ] [ wildlife_old_y ], Wildlife [ deer_id ] [ wildlife_old_z ] ) ;
	SetDynamicObjectRot(Wildlife [ deer_id ] [ wildlife_object ], 0, 0, rotation);

	Streamer_SetFloatData(STREAMER_TYPE_AREA, Wildlife [ deer_id ] [ wildlife_area ], E_STREAMER_SIZE, 5.0 );	
	GetXYInFrontOfWildlife(Wildlife [ deer_id ] [ wildlife_object ], wildlife_x, wildlife_y, 2.0) ;

	CA_FindZ_For2DCoord( wildlife_x, wildlife_y, wildlife_z );
	MoveDynamicObject (Wildlife [ deer_id ] [ wildlife_object ], wildlife_x, wildlife_y, wildlife_z, 1.5 ) ;

	return true ;
}

Wildlife_Harvest ( playerid, deer_id ) {

	if ( Wildlife [ deer_id ] [ wildlife_state ] != WILDLIFE_STATE_DEAD || Wildlife [ deer_id ] [ wildlife_state ] == WILDLIFE_STATE_INACTIVE ) {

		return true;
	}

	if ( ! IsValidDynamicObject ( Wildlife [ deer_id ] [ wildlife_object ] ) ) {
		
		return true;
	}

	ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0, 1);
	Widllife_Harvest_Value[playerid] += 25;
	
	SetPlayerProgressBarValue(playerid, actionGUI_bar, Widllife_Harvest_Value [ playerid ] );

	if ( Widllife_Harvest_Value [ playerid ] >= 100) {

		Wildlife [ deer_id ] [ wildlife_state ] = WILDLIFE_STATE_INACTIVE;

		//SetDynamicObjectMaterial( Wildlife [ deer_id ] [ wildlife_object ], 0, 2804, "CJ_MEATY", "CJ_FLESH_2") ; // skinned

		new Float:ox, Float:oy, Float:oz, Float: new_x, Float: new_y, Float: new_z, Float: rot_x, Float: rot_y, Float: rot_z;
		GetDynamicObjectPos(Wildlife [ deer_id ] [ wildlife_object ], ox, oy, oz);

		Wildlife [ deer_id ] [ wildlife_old_x ] = ox ;
		Wildlife [ deer_id ] [ wildlife_old_y ] = oy ;
		Wildlife [ deer_id ] [ wildlife_old_z ] = oz ;

		CA_RayCastLineAngle(ox, oy, oz + 5.0, 	ox, oy, oz - 5.0, 		new_x, new_y, new_z, rot_x, rot_y, rot_z);

		if ( Wildlife [ deer_id ] [ wildlife_model ] == WILDLIFE_OBJ_DEER ) {

			SetDynamicObjectPos( Harvested_Deers [ deer_id ], ox, oy, oz ) ;
			SetDynamicObjectRot( Harvested_Deers [ deer_id ], rot_x + 90, rot_y, rot_z ) ;
		}

		else if ( Wildlife [ deer_id ] [ wildlife_model ] == WILDLIFE_OBJ_COW ) {

			SetDynamicObjectPos( Harvested_Cows [ deer_id ], ox, oy, oz ) ;
			SetDynamicObjectRot( Harvested_Cows [ deer_id ], rot_x, rot_y + 90, rot_z ) ;
		} 

		SetDynamicObjectPos ( Wildlife [ deer_id ] [ wildlife_object ], 0.0, 0.0, 0.0 ) ;

		Streamer_Update(playerid);

		new string [ 144 ], amount ;

		amount = 1 + random ( 1 ) ;
		if ( GivePlayerItemByParam ( playerid, PARAM_HUNTING, WILDLIFE_HIDE, amount, 750 + random ( 250 ), 0, 0 ) ) { 

			strcat ( string, sprintf("| Looted %d skins of hide~n~",  amount), sizeof ( string )) ;
		}

		amount = 1 + random ( 2 ) ;
		if ( GivePlayerItemByParam ( playerid, PARAM_HUNTING, WILDLIFE_MEAT, 1 + random ( 2 ), 500 + random ( 250 ), 0, 0 ) ) { 

			strcat ( string, sprintf("| Looted %d slabs of meat~n~",  amount), sizeof ( string )) ;
		}

		amount = random ( 2 ) ;
		if ( amount != 0 ) {
			if ( GivePlayerItemByParam ( playerid, PARAM_HUNTING, WILDLIFE_MEAT_LEG, 1 + random ( 2 ), 1000 + random ( 250 ), 0, 0 ) ) { 

				strcat ( string, sprintf("| Looted %d meaty legs~n~",  amount), sizeof ( string )) ;
			}
		}

		ActionPanel_ChangeGUI ( playerid, string ) ;

		GivePlayerExperience ( playerid, 2);

		//PlayerTextDrawSetString(playerid, actionGUI_infoText, string ) ;
		string [ 0 ] = EOS ;

		Widllife_Harvest_Value [ playerid ] = 0;
	}

	return 1;
}

/*
timer WildlifeTrailHandler[1500](wildlifeid) {

////	print("WildlifeTrailHandler timer called (deers.pwn)");

	new Float: track_pos_X, Float: track_pos_Y, Float: track_pos_Z;
	GetPlayerPos ( wildlifeid, track_pos_X, track_pos_Y, track_pos_Z ) ;

	GetDynamicObjectPos( Wildlife [ wildlifeid ] [ wildlife_object ], track_pos_X, track_pos_Y, track_pos_Z ) ;

	if ( ++ WildlifeTrackTick [ wildlifeid ] >= 50 ) {
		WildlifeTrackTick [ wildlifeid ] = 0 ;

		for ( new i; i < MAX_TRACKS_LABELS; i ++ ) {

			if ( IsValidDynamic3DTextLabel(WildlifeTrackLabel [ wildlifeid ] [ i ]) ) {
				DestroyDynamic3DTextLabel ( WildlifeTrackLabel [ wildlifeid ] [ i ] ) ;
			}
		}

		WildlifeTrackCount [ wildlifeid ] = 0 ;
	}

    if ( WildlifeTrackCount [ wildlifeid ] == MAX_TRACKS_LABELS ) {

		for ( new i; i < MAX_TRACKS_LABELS; i ++ ) {

			if ( IsValidDynamic3DTextLabel(WildlifeTrackLabel [ wildlifeid ] [ i ]) ) {
				DestroyDynamic3DTextLabel ( WildlifeTrackLabel [ wildlifeid ] [ i ] ) ;
			}
		}

		WildlifeTrackCount [ wildlifeid ] = 0 ;
	}

	switch ( Wildlife [ wildlifeid ] [ wildlife_model ] ) {

		case WILDLIFE_OBJ_DEER: WildlifeTrackLabel [ wildlifeid ] [ WildlifeTrackCount [ wildlifeid ] ++ ] = CreateDynamic3DTextLabel("[ANIMAL TRACKS]", COLOR_DEER, track_pos_X, track_pos_Y, track_pos_Z - 0.99, 7.5 ) ;
		case WILDLIFE_OBJ_COW: WildlifeTrackLabel [ wildlifeid ] [ WildlifeTrackCount [ wildlifeid ] ++ ] = CreateDynamic3DTextLabel("[ANIMAL TRACKS]", COLOR_COW, track_pos_X, track_pos_Y, track_pos_Z - 0.99, 7.5 ) ;
		
	}

	defer WildlifeTrailHandler[1500+random(4500)](wildlifeid);
}
*/