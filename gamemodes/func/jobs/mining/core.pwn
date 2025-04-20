/*
	Add rock respawn
	give items on rock mine
	change model on GUI
	fix labels in mine
*/

#define MAX_ROCKS 1000
new Iterator:ValidRocks<MAX_ROCKS>;

//enums
enum E_MINING_DATA
{
	mineID, 
	mineObjectID, 
	mineType, 
	Float:mineHealth, 
	Float:minePos[3], 
	mineValid, 
	mineObject, 
	DynamicText3D:mineLabel
}
new Rock[MAX_ROCKS][E_MINING_DATA];

//player vars
new MiningProgress[MAX_PLAYERS];
new player_MineCircle [ MAX_PLAYERS ] ;

Init_MiningRocks () {

    Iter_Init( ValidRocks );
    
	for( new i; i < MAX_ROCKS; i++ ) {
        ResetRockVariables( i );
	}

	CreateStaticRock( );
}

ResetRockVariables( rockid )
{
	Rock[rockid][mineID] = -1;
	Rock[rockid][mineObjectID] = -1;
	Rock[rockid][mineType] = -1;
	Rock[rockid][mineHealth] = 100.0;
	Rock[rockid][minePos][0] = 0.0;
	Rock[rockid][minePos][1] = 0.0;
	Rock[rockid][minePos][2] = 0.0;
	Rock[rockid][mineValid] = 0;
	if( IsValidDynamicObject ( Rock[rockid][mineObject] ) ) { 
		DestroyDynamicObject( Rock[rockid][mineObject] ); 
	}
	Rock[rockid][mineObject] = -1;

	if ( IsValidDynamic3DTextLabel(Rock[rockid][mineLabel])) {
		DestroyDynamic3DTextLabel( Rock[rockid][mineLabel] );
	}
	
	if( Iter_Contains( ValidRocks, rockid ) ) { Iter_Remove( ValidRocks, rockid ); }
	return 1;
}

IsPlayerInRangeOfRock( playerid, Float:range )
{
	foreach(new i : ValidRocks)
	{
	    if( IsPlayerInRangeOfPoint( playerid, range, Rock[i][minePos][0], Rock[i][minePos][1], Rock[i][minePos][2] ) ) { 
	    	return i; 
	    }
	}

	return -1;
}

FindFreeRockID() {

	for( new i=0; i<MAX_ROCKS; i++ ) {

	    if( Rock[i][mineID] == -1 ) { 
	    	return i; 
	    }
	}

	return -1;
}

GetRockItemID ( rockid ) {

	switch( Rock[rockid][mineType] ) {
		case 0: return MINE_ROCK ;
		case 1: return MINE_IRON_ORE ;
		case 2: return MINE_COPPER_ORE ;
		case 3: return MINE_TIN_ORE ;
		case 4: return MINE_COAL_ORE ;		
		case 5: return MINE_GOLD_ORE ;
		default: return -1 ;
	}

	return -1 ;
}

GetRockType( rockid ) {

	new string[64];
	switch( Rock[rockid][mineType] ) {

	    case 0: string = "Normal Rock"; 
	    case 1: string = "{964B4B}Iron Mineral{FFFFFF}";
	    case 2: string = "{FFB66C}Copper Mineral{FFFFFF}";
	    case 3: string = "{C9C9C9}Tin Mineral{FFFFFF}";
	    case 4: string = "{373737}Coal{FFFFFF}"; 
	    case 5: string = "{E2B603}Gold Mineral{FFFFFF}";
	    default: string = "Error"; 
	}

	return string;
}
GetRockTypeEx( rockid ) {

	new string[64];
	switch( Rock[rockid][mineType] ) {

	    case 0: string = "Normal Rock"; 
	    case 1: string = "Iron Mineral";
	    case 2: string = "Copper Mineral";
	    case 3: string = "Tin Mineral";
	    case 4: string = "Coal"; 
	    case 5: string = "Gold Mineral";

	    default: string = "Error"; 
	}

	return string;
}

CreateStaticRock ( ) {

	new Float: RockSpawns [ ] [ ] = {
		{ -1919.0676,		2385.0813,		37.9879 },	{ -1921.4727,		2390.2363,		37.1292 },
		{ -1916.7816,		2393.3623,		37.5175 },	{ -1923.3645,		2398.4558,		35.9735 },
		{ -1929.4668,		2397.5891,		34.5919 },	{ -1931.9189,		2390.7925,		34.1004 },
		{ -1939.7615,		2383.4299,		33.4398 },	{ -1939.6741,		2375.3723,		34.3163 },
		{ -1949.2689,		2368.3499,		35.1137 },	{ -1953.0679,		2374.0417,		32.7691 },
		{ -1957.7441,		2378.3176,		29.8235 },	{ -1957.7368,		2382.8867,		28.8019 },
		{ -1957.5074,		2384.4944,		28.4992 },	{ -1956.9109,		2383.7874,		28.7518 },
		{ -1952.9615,		2387.9285,		28.5476 },	{ -1949.9006,		2397.6772,		26.7426 },
		{ -1951.3562,		2403.3091,		26.7562 },	{ -1948.4630,		2406.5098,		28.5602 },
		{ -1945.2501,		2417.0088,		29.4427 },	{ -1940.0181,		2423.4866,		28.3450 },
		{ -1945.5753,		2422.5134,		28.0852 },	{ -1943.0470,		2430.4124,		25.6596 },
		{ -1938.7642,		2436.7166,		24.4727 },	{ -1943.8549,		2440.7754,		22.5172 },
		{ -1940.9633,		2442.3499,		22.9697 },	{ -1942.7677,		2442.0625,		22.5864 },
		{ -1942.1423,		2443.8933,		22.3692 },	{ -1945.5811,		2443.8418,		21.7797 },
		{ -1943.0664,		2445.5781,		21.7927 },	{ -1943.9061,		2443.1482,		22.2151 },
		{ -1922.1138,		2377.2327,		38.2955 }
	} ;

	new id, string [ 64 ], type, rarespawn ;

	for ( new i; i < sizeof ( RockSpawns ); i ++ ) {

		id = FindFreeRockID( ) ;
		type = randomEx( 0, 5 ) ;
		rarespawn = randomEx( 1, 10 ) ;

		Rock[id][mineID] = id;
		//Rock[id][mineObjectID] = 3929;

		if( type == 1 || type == 3 ) {

		    if( rarespawn >= 7 ) { 

		    	Rock[id][mineType] = type;
		    }

		    else { Rock[id][mineType] = 5; }
		}

		else Rock[id][mineType] = type; 

		Rock[id][mineHealth] = 100.0;
		Rock[id][minePos][0] = RockSpawns [ i ] [ 0 ];
		Rock[id][minePos][1] = RockSpawns [ i ] [ 1 ];
		Rock[id][minePos][2] = RockSpawns [ i ] [ 2 ];
		Rock[id][mineValid] = 1;

    	switch(Rock[id][mineType]) {

    		case 1: { Rock[id][mineObjectID] = ORE_IRON; }
    		case 2: { Rock[id][mineObjectID] = ORE_COPPER; }
    		case 3: { Rock[id][mineObjectID] = ORE_TIN; }
    		case 4: { Rock[id][mineObjectID] = ORE_COAL; }
    		case 5: { Rock[id][mineObjectID] = ORE_GOLD; }
    		default: { Rock[id][mineObjectID] = 3929; }
    	}
		Rock[id][mineObject] = CreateDynamicObject( Rock[id][mineObjectID], Rock[id][minePos][0], Rock[id][minePos][1], Rock[id][minePos][2] - 0.25, 0.0, 0.0, 0.0 ); //mapandreasfindz is with 3dtryg, colandreas find z function wouldn't work, mapandreas isn't being used
		format( string, sizeof( string ), "%s\nHealth: %i", GetRockType( id ), floatround( Rock[id][mineHealth] ) );
		Rock[id][mineLabel] = CreateDynamic3DTextLabel( string, -1, Rock[id][minePos][0], Rock[id][minePos][1], Rock[id][minePos][2] + 0.5, 7.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1 );

		//SetRockColor( id );
		Iter_Add( ValidRocks, id );
	}

	return true ;
}

IsPointNearWater(Float: x, Float: y) {
	new Float:checkx, Float:checky, Float:checkz, Float:angle;

	// Check North/East/South/West for water
	for(new i = 0; i < 4; i++)
	{
        checkx = x + (WATER_CHECK_RADIUS * floatsin(-angle, degrees));
	    checky = y + (WATER_CHECK_RADIUS * floatcos(-angle, degrees));
		angle += 90.0;

		// Find the Z
		CA_FindZ_For2DCoord(checkx, checky, checkz);

		// Doesn't work under bridges
		if(checkz <= 0.0) return 1;
	}

	return 0;
}

new rockCount ;
CreateRock (Float: pos_x, Float: pos_y, Float: pos_z ) {

//	if ( !IsPointNearWater ( pos_x, pos_y ) && !IsCoordBehindDam ( pos_x, pos_y ) ) {

	new id = FindFreeRockID( ), type = randomEx( 0, 5 ), rarespawn = randomEx( 1, 10 ) ;
	
	if ( id == -1 ) {

		return true ;
	}

	Rock[id][mineID] = id;
	//Rock[id][mineObjectID] = 3929;

	if( type == 1 || type == 3 ) {
	    if( rarespawn >= 7 ) { 

	    	Rock[id][mineType] = type;
	    }

	    else { 
	    	Rock[id][mineType] = 5; 
	    }
	}

	else Rock[id][mineType] = type; 


	Rock[id][mineValid] = 1;
	Rock[id][mineHealth] = 100.0;

	Rock[id][minePos][0] = pos_x;
	Rock[id][minePos][1] = pos_y;
	Rock[id][minePos][2] = pos_z;

	switch(Rock[id][mineType]) {

    	case 1: { Rock[id][mineObjectID] = ORE_IRON; }
    	case 2: { Rock[id][mineObjectID] = ORE_COPPER; }
    	case 3: { Rock[id][mineObjectID] = ORE_TIN; }
    	case 4: { Rock[id][mineObjectID] = ORE_COAL; }
    	case 5: { Rock[id][mineObjectID] = ORE_GOLD; }
    	default: { Rock[id][mineObjectID] = 3929; }
    }

	//CA_FindZ_For2DCoord(Rock[id][minePos][0], Rock[id][minePos][1], Rock[id][minePos][2]) ;
	Rock[id][mineObject] = CreateDynamicObject( Rock[id][mineObjectID], Rock[id][minePos][0], Rock[id][minePos][1], Rock[id][minePos][2], 0.0, 0.0, 0.0, -1, -1, -1, 150, 150) ; //mapandreasfindz is with 3dtryg, colandreas find z function wouldn't work, mapandreas isn't being used

	Rock[id][mineLabel] = CreateDynamic3DTextLabel( sprintf("%s\nHealth: %i", GetRockType( id ), floatround( Rock[id][mineHealth] )), -1, Rock[id][minePos][0], Rock[id][minePos][1], Rock[id][minePos][2]+0.5, 7.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1 );

	//SetRockColor( id );
	Iter_Add( ValidRocks, id );
//	}

	rockCount ++ ;

	return true ;
}

SetRockColor( rockid )
{
	switch( Rock[rockid][mineType] )
	{
    	case 1: { SetDynamicObjectMaterial( Rock[rockid][mineObject], 0, -1, "none", "none", 0xFF964B4B ); } //iron
    	case 2: { SetDynamicObjectMaterial( Rock[rockid][mineObject], 0, -1, "none", "none", 0xFFFFB66C ); } //copper
    	case 3: { SetDynamicObjectMaterial( Rock[rockid][mineObject], 0, -1, "none", "none", 0xFFC9C9C9 ); } //tin
    	case 4: { SetDynamicObjectMaterial( Rock[rockid][mineObject], 0, -1, "none", "none", 0xFF373737 ); } //coal
    	case 5: { SetDynamicObjectMaterial( Rock[rockid][mineObject], 0, -1, "none", "none", 0xFFE2B603 ); } //gold
	}

	if ( Rock [ rockid ] [ mineHealth ] <= 0 ) {
		SetDynamicObjectMaterial( Rock[rockid][mineObject], 0, -1, "none", "none", 0xFF244E69 );
	}

	return 1;
}

DecreaseRockHealth( rockid )
{
	switch( Rock[rockid][mineType] )
	{
	    case 0: { Rock[rockid][mineHealth] -= 50.0; } //normal
	    case 1: { Rock[rockid][mineHealth] -= 25.0; } //iron
	    case 2: { Rock[rockid][mineHealth] -= 40.0; } //copper
	    case 3: { Rock[rockid][mineHealth] -= 10.0; } //tin	   
	    case 4: { Rock[rockid][mineHealth] -= 20.0; } //coal 
	    case 5: { Rock[rockid][mineHealth] -= 100.0; } //gold
	}

	if(Rock[rockid][mineHealth] <= 0) { Rock[rockid][mineHealth] = 0 ; }

	UpdateDynamic3DTextLabelText( Rock[rockid][mineLabel], -1, sprintf("%s\nHealth: %i", GetRockType( rockid ), floatround( Rock[rockid][mineHealth] )) );

	return 1;
}

OnPlayerMineOre ( playerid, oreid ) {

	// GivePlayerItemByParam ( playerid, item, param, amount, itemparam, param1, param2 ) 

	if ( GetRockItemID ( oreid ) == -1 ) {

		return SendServerMessage ( playerid, sprintf("Error processing ore. Send this to a dev: [TYPE %d], [ID %d]", Rock [ oreid ] [ mineType ], oreid ), MSG_TYPE_ERROR ) ;
	}

	new amount ;

	switch ( Rock [ oreid ] [ mineType ] ) {

		case 0: amount = 50 + random ( 40 ) ;
		case 1: amount = 100 + random ( 45 ) ;
		case 2:	amount = 150 + random ( 50 ) ;
		case 3:	amount = 200 + random ( 55 ) ;
		case 4:	amount = 250 + random ( 60 ) ;
		case 5:	amount = 300 + random ( 65 ) ;
	}

	if ( GivePlayerItemByParam ( playerid, PARAM_MINING, GetRockItemID ( oreid ), 1, amount, GetRockItemID ( oreid ), 0 ) ) {

		return printf("Player %d: %s looted rock %d", GetRockItemID ( oreid ) ) ;
	}

	else return SendServerMessage ( playerid, "Error processing GivePlayerItemByParam for ore. Tell a dev to look at the drop for YOUR ID.", MSG_TYPE_ERROR ) ;
}

CMD:gotorock ( playerid, params [] ) {
	new id ;

	if ( sscanf ( params, "i", id ) ) {

		return SendClientMessage(playerid, -1, "/gotorock [rockid]" ) ;
	}

	if ( Rock [ id ] [ mineID] == -1 ) {

		return SendClientMessage(playerid, -1, "Invalid rock ID." ) ;
	}

	new Float: x, Float: y, Float: z;
	GetDynamicObjectPos(Rock [ id ] [ mineObject ], x, y, z) ;
	ac_SetPlayerPos ( playerid, x, y, z ) ;

	return true ;
}

MineRock ( playerid, rockid ) {

	ApplyAnimation( playerid, "CHAINSAW", "WEAPON_csawlo", 4.1, 0, 1, 1, 1, 1, 1 );
	TogglePlayerControllable( playerid, 1 );	

	SendServerMessage( playerid, sprintf("You have mined some %s (id %d).", GetRockType( rockid ), rockid ), MSG_TYPE_INFO );
	UpdateDynamic3DTextLabelText( Rock[rockid][mineLabel], -1, sprintf("%s\nHealth: %i", GetRockType( rockid ), floatround( Rock[rockid][mineHealth] )) );

  	MiningProgress[playerid] = 0;
   	IsMining[playerid] = false;
   	ClearAnimations(playerid ) ;

	DecreaseRockHealth( rockid );

	// START CODE ACTION GUI
	OnPlayerMineOre ( playerid, rockid ) ;
	//OldLog ( playerid, "job/mining", sprintf ( "%s has mined %s, weight: %0.2f.", ReturnUserName ( playerid, false ), GetRockTypeEx ( rockid ) )) ;

	new xp = 1 + random ( 2 ) ;
	GivePlayerExperience ( playerid, xp ) ;



	ActionPanel_ChangeGUI ( playerid, sprintf("| You've mined a %s.~n~~n~~w~ + %d exp for Mining Level!", GetRockTypeEx ( rockid ), xp ), 3929, false) ;

	/*
	PlayerTextDrawHide ( playerid, actionGUI_PreviewBoxModel ) ;
	PlayerTextDrawSetString(playerid, actionGUI_infoText, 
		sprintf("| You've mined a %s.~n~~n~~w~ + %d exp for Mining Level!", GetRockTypeEx ( rockid ), xp ) ) ;		

	PlayerTextDrawSetPreviewModel ( playerid, actionGUI_PreviewBoxModel, 3929 ) ;
	PlayerTextDrawShow ( playerid, actionGUI_PreviewBoxModel ) ;
	HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;
	*/

	new query [ 128 ] ;

	Character [ playerid ] [ character_mineactionsleft ] ++;
	if ( Character [ playerid ] [ character_mineactionsleft] >= 10 ) {

		Character [ playerid ] [ character_mineactionsleft ] = 0 ;
		
		switch ( PlayerSkill [ playerid ] [ JOB_mining ] ) {

				case 0,1: {

					Character [ playerid ] [ character_minecd ] = gettime() + LVL1COOLDOWN;
				}
				case 2: {

					Character [ playerid ] [ character_minecd ] = gettime() + LVL2COOLDOWN;
				}
				case 3: {

					Character [ playerid ] [ character_minecd ] = gettime() + LVL3COOLDOWN;
				}
			}

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_mineactionsleft = %d, character_minecd = %d WHERE character_id = %d", 
			Character [ playerid ] [ character_jobactionsleft ], Character [ playerid ] [ character_minecd ], Character [ playerid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( playerid, "You feel tired of mining, so you've decided to stop.", MSG_TYPE_WARN ) ;

		return cmd_fixjob ( playerid ) ;
	}
	
	else {

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_mineactionsleft = %d WHERE character_id = %d", 
				Character [ playerid ] [ character_jobactionsleft ], Character [ playerid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;
	}

	if ( DoingTask [ playerid ] == 4 ) {

		ProcessTask ( playerid, DoingTask [ playerid ] ) ;
	}
	// END CODE ACTION GUI

	if( Rock[rockid][mineHealth] <= 0.0 ) { 
	
		Rock[rockid][mineHealth] = 0 ;
		SetRockColor( rockid );

/*
		if( IsValidDynamicObject ( Rock[rockid][mineObject] ) ) { 
			DestroyDynamicObject( Rock[rockid][mineObject] ); 
		}
		
		if ( IsValidDynamic3DTextLabel(Rock[rockid][mineLabel])) {
			DestroyDynamic3DTextLabel( Rock[rockid][mineLabel] );
		}

		//Iter_Remove( ValidRocks, rockid ) ;*/



		defer RespawnRock(rockid) ;
	}

	return 1;
}
		
task RespawnRocks[1800000]() {

	for ( new i; i < MAX_ROCKS; i ++ ) {

		if ( Rock[i][mineHealth] != -1 && Rock[i][mineHealth] <= 0 ) {

			defer RespawnRock[1000](i);
			continue ;
		}

		else continue ;
	}

	return true ;
}

timer RespawnRock[900000](oreid) { // 15 min respawn time

////	print("RespawnRock timer called (mining/core.pwn)");

	if ( Rock[oreid][mineHealth] <= 0 ) {

		Rock[oreid][mineHealth] = 100.0 ;
		Rock[oreid][mineValid] = 1;

		SetRockColor( oreid );
		UpdateDynamic3DTextLabelText( Rock[oreid][mineLabel], -1, sprintf("%s\nHealth: %i", GetRockType( oreid ), floatround( Rock[oreid][mineHealth] )) ) ;
	}

	return 1;
}

CMD:forcerespawnore ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < GENERAL_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a general moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new oreid;

	if ( sscanf ( params, "D(-1)", oreid ) ) {

		return SendServerMessage ( playerid, "/forcerespawnore [oreid]", MSG_TYPE_ERROR ) ;
	}

	oreid = IsPlayerInRangeOfRock(playerid,2.5);

	RespawnRock ( oreid ) ;

	SendServerMessage ( playerid, sprintf("You've respawned oreid %i.", oreid ), MSG_TYPE_INFO ) ;

	return true ;
}


timer MiningRock[500]( playerid, rockid ) {

////	print("MiningRock timer called (minig/core.pwn)");
	if( IsMining[playerid] ) {

		//if ( ! IsValidDynamicObject ( Rock[rockid][mineObjectID ] ) ) {
		if ( Rock[rockid][mineHealth] <= 0) {

			IsMining[playerid]  = false ;
	  		MiningProgress[playerid] = 0;

	  		if ( IsValidDynamicArea ( player_MineCircle [ playerid ] ) ) {
				DestroyDynamicArea( player_MineCircle [ playerid ] ) ;
			}
			
			TogglePlayerControllable ( playerid, true ) ;

			HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;
			HideActionGUI ( playerid ) ;
			return cmd_fixjob (playerid);
		}

	    if( MiningProgress[playerid] > 0 )
	    {
	        new remove = randomEx( 5, 15 );
	    	MiningProgress[playerid] -= remove;
	    	if ( MiningProgress [ playerid ] <= 0 ) { MiningProgress [ playerid ] = 0 ; }
	    	SetPlayerProgressBarValue( playerid, actionGUI_bar, MiningProgress[playerid] );
		}

	    defer MiningRock( playerid, rockid );
	}
	return 1;
}