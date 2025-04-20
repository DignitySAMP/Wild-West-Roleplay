// Place actors in salloons and other interior
// Every shopkeeper or NPC has to be an acotr

// NOTE: actor anism


#include <ww_arraynames>


/*
#if !defined isnull
	#define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif*/

#define MAX_ANIM_LENGTH		(32)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

enum actorData {
	actor_id,
	
	actor_holder, 		// stores actor id
	DynamicText3D: actor_text, // stores actor 3dtext
	
	actor_name [ MAX_RDR_NAME ] ,
	actor_type,
	actor_skinid,
	actor_vw,

	Float: actor_x_pos ,
	Float: actor_y_pos ,
	Float: actor_z_pos ,
	Float: actor_a_pos ,

	actor_animlib [ MAX_ANIM_LENGTH ],
	actor_animname [ MAX_ANIM_LENGTH ]

} ;
#define MAX_ACTORS_EX       ( 500 )
new Actor [ MAX_ACTORS_EX ] [ actorData ], ReturnActorCount;

enum {
	ACTOR_TYPE_CHARACTER, // A "prop" actor
	ACTOR_TYPE_SHOPKEEPER_GENERAL,
	ACTOR_TYPE_SHOPKEEPER_ARMS,
	ACTOR_TYPE_SHOPKEEPER_FARM,
	ACTOR_TYPE_SHOPKEEPER_TOYS
} ;


#include "data/actors/core/cmds.pwn"

public OnPlayerKeyStateChange (playerid, newkeys, oldkeys) {

	if ( newkeys & KEY_CTRL_BACK && IsPlayerNearActor ( playerid ) != INVALID_ACTOR_ID  ) {
		// GetPlayerTargetActor:

	    new actorid = IsPlayerNearActor ( playerid ) ;
	    OnPlayerInteractWithActor ( playerid, actorid ) ;
	}

	#if defined actor_OnPlayerKeyStateChange
		return actor_OnPlayerKeyStateChange ( playerid, newkeys, oldkeys ) ;
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif

#define OnPlayerKeyStateChange actor_OnPlayerKeyStateChange
#if defined actor_OnPlayerKeyStateChange
	forward actor_OnPlayerKeyStateChange ( playerid, newkeys, oldkeys ) ;
#endif	

/*
public OnActorStreamIn ( actorid, forplayerid ) {

	//ApplyAnimation(forplayerid, Actor [ actorid ] [ actor_animlib ], "null", 0.0, 0, 0, 0, 0, 0);
	if ( IsValidActorAnim ( Actor [ actorid ] [ actor_animlib ] ) ) {
		ApplyActorAnimation ( actorid, Actor [ actorid ] [ actor_animlib ], Actor [ actorid ] [ actor_animname ], 4.1, 1, 0, 0, 0, 0 ) ;
	}

	return true ;
}
*/
Init_LoadActors () {
	new query [ 256 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM actors" );
	mysql_tquery ( mysql, query, "LoadActorData", "" ) ;

	for ( new i, j = ReturnActorCount; i < j; i ++ ) {
		if ( IsValidActor ( i ) ) {
			UpdateActor ( i ) ;
		}
	}

	return true ;
}

UpdateActor ( actorid ) {
	DestroyActor (  Actor [ actorid ] [ actor_holder ] ) ;

	Actor [ actorid ] [ actor_holder ] = CreateActor ( Actor [ actorid ] [ actor_skinid ], Actor [ actorid ] [ actor_x_pos ], Actor [ actorid ] [ actor_y_pos ], Actor [ actorid ] [ actor_z_pos ], Actor [ actorid ] [ actor_a_pos ] ) ;
	SetActorVirtualWorld ( actorid, Actor [ actorid ] [ actor_vw ] ) ;

	UpdateActorInfoString ( actorid ) ;

	// 
	if ( IsValidActorAnim ( Actor [ actorid ] [ actor_animlib ] ) ) {
		ApplyActorAnimation ( actorid, Actor [ actorid ] [ actor_animlib ], Actor [ actorid ] [ actor_animname ], 4.1, 1, 0, 0, 0, 0 ) ;

	}
}

UpdateActorInfoString ( actorid ) {
	new string [ 128 ] ;

    switch ( Actor [ actorid ] [ actor_type ] ) {

		case ACTOR_TYPE_CHARACTER: {
    		format ( string, sizeof ( string ), "[NPC] (%d) %s", actorid, Actor [ actorid ] [ actor_name ] ) ;
        }
        
		case ACTOR_TYPE_SHOPKEEPER_GENERAL: {
    		format ( string, sizeof ( string ), "[NPC] (%d) %s\n\n\n\n\n\n{BA8957}General Shopkeeper{FFFFFF}\nType /shop to interact", actorid, Actor [ actorid ] [ actor_name ] ) ;
        }
        
		case ACTOR_TYPE_SHOPKEEPER_ARMS: {
    		format ( string, sizeof ( string ), "[NPC] (%d) %s\n\n\n\n\n\n{5E5E5E}Weaponry Shopkeeper{FFFFFF}\nType /shop to interact", actorid, Actor [ actorid ] [ actor_name ] ) ;
        }
        
		case ACTOR_TYPE_SHOPKEEPER_FARM: {
    		format ( string, sizeof ( string ), "[NPC] (%d) %s\n\n\n\n\n\n{9BBA57}Farming Shopkeeper{FFFFFF}\nType /shop to interact", actorid, Actor [ actorid ] [ actor_name ] ) ;
        }
        
		case ACTOR_TYPE_SHOPKEEPER_TOYS: {
    		format ( string, sizeof ( string ), "[NPC] (%d) %s\n\n\n\n\n\n{5798BA}Clothing Shopkeeper{FFFFFF}\nType /shop to interact", actorid, Actor [ actorid ] [ actor_name ] ) ;
        }
    }

	if ( IsValidDynamic3DTextLabel( Actor [actorid] [actor_text] ) ) {
        DestroyDynamic3DTextLabel ( Actor [ actorid ] [ actor_text ] ) ;
	}

	Actor [ actorid ] [ actor_text ] = CreateDynamic3DTextLabel( string, 0xE6E6E6FF,  Actor [ actorid ] [ actor_x_pos ], Actor [ actorid ] [ actor_y_pos ], Actor [ actorid ] [ actor_z_pos ] + 1, 7.5 ) ;

	return true ;
}

forward LoadActorData () ;
public LoadActorData () {
	new rows, fields ;

	cache_get_data ( rows, fields, mysql ) ;

	if ( ! rows ) {

		StoreActorData () ;
		Init_LoadActors () ;
	}

    if ( rows ) {

		printf(" * [ACTORS]: Loading actors...", ReturnActorCount) ;

		for ( new i, j = rows; i < j; i ++ ) {

			Actor [ i ] [ actor_id ] 		= cache_get_field_int ( i, "actor_id" ) ;

			Actor [ i ] [ actor_type ] 		= cache_get_field_int ( i, "actor_type" ) ;
			Actor [ i ] [ actor_skinid ] 	= cache_get_field_int ( i, "actor_skinid" ) ;
			Actor [ i ] [ actor_vw ] 		= cache_get_field_int ( i, "actor_vw" ) ;

			cache_get_field_content ( i, "actor_name", Actor [ i ] [ actor_name ], mysql, MAX_RDR_NAME ) ;

			Actor [ i ] [ actor_x_pos ] 		= cache_get_field_float ( i, "actor_x_pos" ) ;
			Actor [ i ] [ actor_y_pos ] 		= cache_get_field_float ( i, "actor_y_pos" ) ;
			Actor [ i ] [ actor_z_pos ] 		= cache_get_field_float ( i, "actor_z_pos" ) ;
			Actor [ i ] [ actor_a_pos ] 		= cache_get_field_float ( i, "actor_a_pos" ) ;

			cache_get_field_content ( i, "actor_animlib",  Actor [ i ] [ actor_animlib ], mysql, MAX_ANIM_LENGTH ) ;
			cache_get_field_content ( i, "actor_animname", Actor [ i ] [ actor_animname ], mysql, MAX_ANIM_LENGTH ) ;

			Actor [ i ] [ actor_holder ] = CreateActor ( Actor [ i ] [ actor_skinid ], Actor [ i ] [ actor_x_pos ], Actor [ i ] [ actor_y_pos ], Actor [ i ] [ actor_z_pos ], Actor [ i ] [ actor_a_pos ] ) ;
			SetActorFacingAngle ( Actor [ i ] [ actor_holder ], Actor [ i ] [ actor_a_pos ] ) ;

			SetActorVirtualWorld ( Actor [ i ] [ actor_holder ], Actor [ i ] [ actor_vw ] ) ;
            SetActorInvulnerable ( Actor [ i ] [ actor_holder ], true ) ;

            PreloadActorAnimations ( i ) ;

	      	if ( IsValidActorAnim ( Actor [ i ] [ actor_animlib ] ) ) {
				ApplyActorAnimation ( i, Actor [ i ] [ actor_animlib ], Actor [ i ] [ actor_animname ], 4.1, 1, 0, 0, 0, 0 ) ;
			}

		    UpdateActorInfoString ( i ) ;
		}

		ReturnActorCount = rows ;
	}

	printf(" * [ACTORS]: Loaded %d actors\n", ReturnActorCount) ;

	return true ;
}

IsPlayerNearActor ( playerid ) {
	for ( new i; i < MAX_ACTORS; i ++ ) {
	    if ( IsValidActor ( i ) ) {
			if ( IsPlayerInRangeOfPoint ( playerid, 5.0, Actor [ i ] [ actor_x_pos ], Actor [ i ] [ actor_y_pos ], Actor [ i ] [ actor_z_pos ] ) ) {
				return i ;
			}
		}
	}

	return INVALID_ACTOR_ID ;
}

/*public OnPlayerKeyStateChange ( playerid, newkeys, oldkeys ) {
	if ( newkeys & KEY_CTRL_BACK && IsPlayerNearActor ( playerid ) != INVALID_ACTOR_ID  ) {
		// GetPlayerTargetActor:

	    new actorid = IsPlayerNearActor ( playerid ) ;
	    OnPlayerInteractWithActor ( playerid, actorid ) ;
	}

	return true ;
}*/

OnPlayerInteractWithActor ( playerid, actorid ) {

	if ( actorid != INVALID_ACTOR_ID ) {

	    switch ( Actor [ actorid ] [ actor_type ] ) {

			case ACTOR_TYPE_CHARACTER: {
	    		
	        }

	        case ACTOR_TYPE_SHOPKEEPER_GENERAL: {

	        }

			case ACTOR_TYPE_SHOPKEEPER_ARMS: {

	        }

			case ACTOR_TYPE_SHOPKEEPER_FARM: {

	        }

			case ACTOR_TYPE_SHOPKEEPER_TOYS: {

	        }
	    }
	}

	return true;
}


StoreActorData () {

	new query [ 512 ] ;

	new i_actor_name [ MAX_RDR_NAME ], i_actor_skinid, pos_incr ;

	new Float: f_actor_x, Float: f_actor_y, Float: f_actor_z, Float: f_actor_a ;

	for ( new i; i < sizeof ( rdr_Names ) ; i ++ ) {
		if ( i_actor_skinid <= 311 ) {
		    if ( i_actor_skinid == 74 ) {
				i_actor_skinid = 75 ;
		    }
		    
			i_actor_skinid ++ ;
		}
		
		else if ( i_actor_skinid == 311 ) {
		    i_actor_skinid = 1 ;
		}

        pos_incr = random ( 10 ) ;

		f_actor_x = -1019.6578 + pos_incr;
		f_actor_y = -643.4897 + pos_incr ;
		f_actor_z = 32.0078 ;
		f_actor_a = 244.4535 + pos_incr ;

		i_actor_skinid = random ( 300 ) ;

		format ( i_actor_name, sizeof ( i_actor_name ) , "%s", rdr_Names [ i ] [ rdr_Name ] ) ;

		mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO actors (actor_name, actor_skinid, actor_x_pos, actor_y_pos, actor_z_pos, actor_a_pos) VALUES ('%s', '%d', '%f', '%f', '%f', '%f' )",
		i_actor_name, i_actor_skinid, f_actor_x, f_actor_y, f_actor_z, f_actor_a );

		mysql_tquery ( mysql, query, "" ) ;
	}
	
	printf("Created all actors.");

	return true ;
}

enum animLibData {
	aLib_name [ 24 ]

} ;

static s_AnimationLibraries[][ animLibData ] = {
        { "AIRPORT" },     		{ "ATTRACTORS" },    	{ "BAR" },              { "BASEBALL" }, 
        { "BD_FIRE" },     		{ "BEACH" },         	{ "BENCHPRESS" },   	{ "BF_INJECTION" }, 
        { "BIKED" },       		{ "BIKEH" },         	{ "BIKELEAP" },         { "BIKES" }, 
        { "BIKEV" },       		{ "BIKE_DBZ" },      	{ "BMX" },              { "BOMBER" }, 
        { "BOX" },         		{ "BSKTBALL" },      	{ "BUDDY" },            { "BUS" }, 
        { "CAMERA" },      		{ "CAR" },           	{ "CARRY" },            { "CAR_CHAT" }, 
        { "CASINO" },      		{ "CHAINSAW" },      	{ "CHOPPA" },           { "CLOTHES" }, 
        { "COACH" },       		{ "COLT45" },        	{ "COP_AMBIENT" },  	{ "COP_DVBYZ" }, 
        { "CRACK" },       		{ "CRIB" },          	{ "DAM_JUMP" },         { "DANCING" }, 
        { "DEALER" },      		{ "DILDO" },         	{ "DODGE" },            { "DOZER" }, 
        { "DRIVEBYS" },    		{ "FAT" },           	{ "FIGHT_B" },       	{ "FIGHT_C" }, 
        { "FIGHT_D" },     		{ "FIGHT_E" },       	{ "FINALE" },           { "FINALE2" }, 
        { "FLAME" },       		{ "FLOWERS" },       	{ "FOOD" },             { "FREEWEIGHTS" }, 
        { "GANGS" },       		{ "GHANDS" },        	{ "GHETTO_DB" },     	{ "GOGGLES" }, 
        { "GRAFFITI" },    		{ "GRAVEYARD" },     	{ "GRENADE" },       	{ "GYMNASIUM" }, 
        { "HAIRCUTS" },    		{ "HEIST9" },        	{ "INT_HOUSE" },     	{ "INT_OFFICE" }, 
        { "INT_SHOP" },    		{ "JST_BUISNESS" },  	{ "KART" },             { "KISSING" }, 
        { "KNIFE" },       		{ "LAPDAN1" },       	{ "LAPDAN2" },       	{ "LAPDAN3" }, 
        { "LOWRIDER" },    		{ "MD_CHASE" },      	{ "MD_END" },           { "MEDIC" }, 
        { "MISC" },        		{ "MTB" },          	{ "MUSCULAR" },      	{ "NEVADA" }, 
        { "ON_LOOKERS" },  		{ "OTB" },          	{ "PARACHUTE" },     	{ "PARK" }, 
        { "PAULNMAC" },    		{ "PED" },           	{ "PLAYER_DVBYS" },  	{ "PLAYIDLES" }, 
        { "POLICE" },      		{ "POOL" },          	{ "POOR" },             { "PYTHON" }, 
        { "QUAD" },        		{ "QUAD_DBZ" },      	{ "RAPPING" },       	{ "RIFLE" }, 
        { "RIOT" },        		{ "ROB_BANK" },      	{ "ROCKET" },           { "RUSTLER" }, 
        { "RYDER" },       		{ "SCRATCHING" },    	{ "SHAMAL" },           { "SHOP" }, 
        { "SHOTGUN" },     		{ "SILENCED" },      	{ "SKATE" },            { "SMOKING" }, 
        { "SNIPER" },      		{ "SPRAYCAN" },      	{ "STRIP" },            { "SUNBATHE" }, 
        { "SWAT" },        		{ "SWEET" },         	{ "SWIM" },            	{ "SWORD" }, 
        { "TANK" },        		{ "TATTOOS" },       	{ "TEC" },              { "TRAIN" }, 
        { "TRUCK" },       		{ "UZI" },           	{ "VAN" },              { "VENDING" }, 
        { "VORTEX" },      		{ "WAYFARER" },      	{ "WEAPONS" },       	{ "WUZI" }, 
        { "WOP" },         		{ "GFUNK" },         	{ "RUNNINGMAN" }
};

IsValidActorAnim ( animlib[] ) {

	for ( new i; i < sizeof ( s_AnimationLibraries ); i ++ ) {

		if ( !strcmp ( animlib, s_AnimationLibraries [ i ] [ aLib_name ], .ignorecase = true ) ) {

			return true ;
		}
	}

	return false ;
}

stock static PreloadActorAnimations(actorid)
{
        for(new i = 0; i < sizeof(s_AnimationLibraries); i ++)
        {
            ApplyActorAnimation(actorid, s_AnimationLibraries[i][aLib_name], "null", 0.0, 0, 0, 0, 0, 0);
        }
}
