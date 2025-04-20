#define MAX_POSTERS		( 25 )

#include "data/posse/posse/poster/core.pwn"
#include "data/posse/posse/poster/gui.pwn"

new player_BountyKill [ MAX_PLAYERS ], bool: CarryingBountyCorpse [ MAX_PLAYERS ] ;

CMD:poster ( playerid, params [] ) {

	new name [ MAX_PLAYER_NAME ], skin, price, jailtime;

	if ( sscanf ( params, "iiis[24]", skin, price, jailtime, name )) {

		return SendClientMessage(playerid, -1, "/poster [skin] [price] [jailtime] [name]") ;
	}

	if ( strlen ( name ) > MAX_PLAYER_NAME) {

		return  SendClientMessage(playerid, -1, "Name can't be longer than 24 characters!") ;
	}

	if ( ! IsValidSkin ( skin ) ) {

		return  SendClientMessage(playerid, -1, "You must pick a valid skin!") ;
	}

	if ( Character [ playerid ] [ character_handmoney ] < price ) {

		return SendServerMessage ( playerid, "You don't have enough money to offer this bounty.", MSG_TYPE_ERROR ) ;
	}

	PosterName [ playerid ] = name;

	return CreateWantedPoster ( playerid, skin, price, jailtime ) ;
}

CMD:removeposter ( playerid, params [] ) {

	new posterid = -1;

	if ( sscanf ( params, "D(-1)", posterid ) ) {

		return SendServerMessage ( playerid, "/removeposter [optional:posterid", MSG_TYPE_ERROR ) ;
	}

	if ( IsPlayerNearWantedPoster ( playerid ) != -1 ) {

		new query [ 128 ] ;

		if ( posterid == -1 ) {

			posterid = IsPlayerNearWantedPoster ( playerid ) ;
		}

		mysql_format ( mysql, query, sizeof ( query ), "DELETE FROM wanted_posters WHERE poster_id = %d", posterid ) ;
		mysql_tquery ( mysql, query );

		WantedPoster [ posterid ] [ poster_id ] = -1;
		Init_LoadWantedPosters ( ) ; 

	}

	else return SendServerMessage(playerid, "You're not near a wanted poster.", MSG_TYPE_ERROR ) ;

	return true ;
}

CMD:takebounty ( playerid, params [] ) {

	new poster;

	if ( sscanf ( params, "D(-1)", poster ) ) {

		return SendServerMessage ( playerid, "/takebounty [optional:posterid]", MSG_TYPE_ERROR ) ;
	}

	if ( Character [ playerid ] [ character_bounty_id ] != -1 ) {

		return SendServerMessage ( playerid, "You've already accepted a bounty!", MSG_TYPE_ERROR ) ;
	}

	if ( IsPlayerNearWantedPoster ( playerid ) != -1 ) {

		new query [ 128 ];

		poster = IsPlayerNearWantedPoster ( playerid ) ;

		Character [ playerid ] [ character_bounty_id ] = poster;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_bounty_id = %d WHERE character_id = %d", 
			Character [ playerid ] [ character_bounty_id ], Character [ playerid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( playerid, sprintf("You've accepted the bounty on %s.", WantedPoster [ poster ] [ poster_name ] ), MSG_TYPE_INFO ) ;
	}

	else return SendServerMessage(playerid, "You're not near a wanted poster.", MSG_TYPE_ERROR ) ;

	return true ;
}

CMD:abandonbounty ( playerid, params [] ) {

	if ( ! Character [ playerid ] [ character_bounty_id ] ) {

		return SendServerMessage ( playerid, "You haven't accepted a bounty!", MSG_TYPE_ERROR ) ;
	}

	new query [ 128 ];

	Character [ playerid ] [ character_bounty_id ] = -1;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_bounty_id = %d WHERE character_id = %d", 
		Character [ playerid ] [ character_bounty_id ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	SendServerMessage ( playerid, "You've abandoned your current bounty.", MSG_TYPE_INFO ) ;

	return true ;
}

CMD:claimbounty ( playerid, params [] ) {

	new query [ 256 ] ;

	if ( Character [ playerid ] [ character_bounty_id ] == -1 ) {

		return SendServerMessage ( playerid, "You haven't accepted a bounty!", MSG_TYPE_ERROR ) ;
	}

	if ( player_BountyKill [ playerid ] == -1 ) { 

		new bountyid = WantedPoster [ Character [ playerid ] [ character_bounty_id ] ] [ poster_playerid ], Float: x_pos, Float: y_pos, Float: z_pos, Float: yds, posterid ;

		if ( bountyid == INVALID_PLAYER_ID ) {

			return SendServerMessage ( playerid, "Your bounty doesn't seem to be online at the moment, or they are desynced.", MSG_TYPE_ERROR ) ;
		}

		if ( GetPointIDFromType ( playerid, POINT_TYPE_SHERIFF ) == -1 ) {

			return SendServerMessage ( playerid, "You are not in a sheriff's office!", MSG_TYPE_ERROR );
		}

		GetPlayerPos ( bountyid, Float: x_pos, Float: y_pos, Float: z_pos ) ;

		yds = GetPlayerDistanceFromPoint(playerid, x_pos, y_pos, z_pos ) ;

		if ( yds > 5.0 ) {

			return SendServerMessage ( playerid, "You're not near your bounty.", MSG_TYPE_ERROR ) ;
		}

		SendServerMessage ( bountyid, "You've been put in jail for your bounty.", MSG_TYPE_INFO ) ;

		Character [ bountyid ] [ character_prison ] = gettime() + ( WantedPoster [ posterid ] [ poster_jailtime ] * 60 ) ;

		Character [ bountyid ] [ character_prison_pos_x ] = x_pos;
		Character [ bountyid ] [ character_prison_pos_y ] = y_pos;
		Character [ bountyid ] [ character_prison_pos_z ] = z_pos;

		Character [ bountyid ] [ character_prison_interior ] = GetPlayerInterior ( bountyid ) ;
		Character [ bountyid ] [ character_prison_vw ] = GetPlayerVirtualWorld ( bountyid ) ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_prison = %d, character_prison_pos_x = '%f', character_prison_pos_y = '%f',character_prison_pos_z = '%f', character_prison_interior = %d, character_prison_vw = %d WHERE character_id = %d",
				Character [ bountyid ] [ character_prison ], Character [ bountyid ] [ character_prison_pos_x ], Character [ bountyid ] [ character_prison_pos_y ], Character [ bountyid ] [ character_prison_pos_z ], Character [ bountyid ] [ character_prison_interior ], Character [ bountyid ] [ character_prison_vw ], Character [ bountyid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query );

		posterid = Character [ playerid ] [ character_bounty_id ] ;

		GiveCharacterMoney ( playerid, WantedPoster [ posterid ] [ poster_price ], MONEY_SLOT_HAND ) ;
		SendServerMessage ( playerid, sprintf("You've been paid $%s for the bounty.", IntegerWithDelimiter ( WantedPoster [ posterid ] [ poster_price ] ) ), MSG_TYPE_INFO ) ;

		mysql_format ( mysql, query, sizeof ( query ), "DELETE FROM wanted_posters WHERE poster_id = %d", posterid ) ;
		mysql_tquery ( mysql, query );

		WantedPoster [ posterid ] [ poster_id ] = -1;
		Init_LoadWantedPosters ( ) ; 

	}

	else if ( player_BountyKill [ playerid ] ) {

		if ( CarryingBountyCorpse [ playerid ] == false ) {

			return SendServerMessage ( playerid, "You need to be carrying the corpse.", MSG_TYPE_ERROR ) ;
		}

		if ( GetPointIDFromType ( playerid, POINT_TYPE_SHERIFF ) == -1 ) {

			return SendServerMessage ( playerid, "You are not in a sheriff's office!", MSG_TYPE_ERROR );
		}

		new posterid = Character [ playerid ] [ character_bounty_id ] ;

		GiveCharacterMoney ( playerid, WantedPoster [ posterid ] [ poster_price ], MONEY_SLOT_HAND ) ;
		SetupPlayerGunAttachments ( playerid ) ;
		SendServerMessage ( playerid, sprintf("You've been paid $%s for the bounty.", IntegerWithDelimiter ( WantedPoster [ posterid ] [ poster_price ] ) ), MSG_TYPE_INFO ) ;

		mysql_format ( mysql, query, sizeof ( query ), "DELETE FROM wanted_posters WHERE poster_id = %d", Character [ playerid ] [ character_bounty_id ] ) ;
		mysql_tquery ( mysql, query );

		WantedPoster [ posterid ] [ poster_id ] = -1;
		Init_LoadWantedPosters ( ) ; 
	}

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_bounty_id = -1 WHERE character_bounty_id = %d", Character [ playerid ] [ character_bounty_id ] ) ;
	mysql_tquery ( mysql, query );

	Character [ playerid ] [ character_bounty_id ] = -1;

	return true ;
}


CMD:pickbounty ( playerid, params [] ) {

	new bountyid = IsPlayerNearCorpse ( playerid ) ;

	if ( Character [ playerid ] [ character_bounty_id ] == -1 ) {

		return SendServerMessage ( playerid, "You haven't accepted a bounty!", MSG_TYPE_ERROR ) ;
	}

	if ( bountyid == -1 ) {

		return SendServerMessage ( playerid, "You have not killed your bounty.", MSG_TYPE_ERROR ) ;
	}

	SendClientMessage(playerid, -1, sprintf("bountyid - %i : bounty_id - %i : character_bounty_id - %i", Corpse [ bountyid ] [ corpse_pid ], GetBountyIDByName ( Corpse [ bountyid ] [ corpse_pid ] ), Character [ playerid ] [ character_bounty_id]));

	if ( IsValidBounty ( playerid, Corpse [ bountyid ] [ corpse_pid ] ) ) {

		SetPlayerAttachedObject(playerid, ATTACH_SLOT_BACK, 2805, 1, -0.0369, -0.2309, 0.000, 89.30001, 93.099937, -94.300071, 0.885999, 0.746999, 1.055000 ) ;

		player_BountyKill [ playerid ] = Corpse [ bountyid ] [ corpse_pid ];

		CarryingBountyCorpse [ playerid ] = true;

		ResetCorpse ( Corpse [ bountyid ] [ corpse_pid ], bountyid );

		SendServerMessage ( playerid, sprintf("You've picked up the corpse of %s.", ReturnUserName ( Corpse [ bountyid ] [ corpse_pid ], false ) ), MSG_TYPE_INFO ) ;
	}

	else return SendServerMessage ( playerid, "You are not near the right corpse!", MSG_TYPE_ERROR ) ;

	return true ;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid) {

	if ( clickedid == Text: INVALID_TEXT_DRAW ) {

		Streamer_ToggleAllItems ( playerid, STREAMER_TYPE_3D_TEXT_LABEL, true ) ;
		HideWantedPoster ( playerid ) ;
	}
	
	#if defined pst_OnPlayerClickTextDraw 
		return pst_OnPlayerClickTextDraw ( playerid, Text: clickedid );
	#else
		return true ;
	#endif
}
#if defined _ALS_OnPlayerClickTextDraw 
	#undef OnPlayerClickTextDraw 
#else
	#define _ALS_OnPlayerClickTextDraw 
#endif

#define OnPlayerClickTextDraw  pst_OnPlayerClickTextDraw 
#if defined pst_OnPlayerClickTextDraw 
	forward pst_OnPlayerClickTextDraw ( playerid, Text: clickedid );
#endif

public OnPlayerKeyStateChange ( playerid, newkeys, oldkeys ) {
	
	if ( newkeys & KEY_WALK && IsPlayerNearWantedPoster ( playerid ) != -1 ) {


		if ( IsPlayerViewingInventory [ playerid ] ) {

			return SendServerMessage ( playerid, "You can't view a wanted poster when your inventory is enabled!", MSG_TYPE_ERROR ) ;
		}

		new posterid = IsPlayerNearWantedPoster ( playerid ) ;

		Streamer_ToggleAllItems ( playerid, STREAMER_TYPE_3D_TEXT_LABEL, false ) ;
		ShowWantedPoster ( playerid, posterid ) ;
	}
	
	#if defined post_OnPlayerKeyStateChange
		return post_OnPlayerKeyStateChange( playerid, newkeys, oldkeys );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif

#define OnPlayerKeyStateChange post_OnPlayerKeyStateChange
#if defined post_OnPlayerKeyStateChange
	forward post_OnPlayerKeyStateChange( playerid, newkeys, oldkeys );
#endif

GetPlayerIDFromPoster ( posterid ) {

	if ( WantedPoster [ posterid ] [ poster_id ] == -1 ) {

		return INVALID_PLAYER_ID ;
	}

	foreach (new playerid: Player ) {

		if ( ! strcmp( Character [ playerid ] [ character_name ], WantedPoster [ posterid ] [ poster_name ], true ) ) {

			return playerid ;
		}

		else continue ;
	}

	return true ;
}

IsPlayerNearWantedPoster ( playerid ) {

	for ( new i; i < MAX_POSTERS; i ++ ) {

		if ( WantedPoster [ i ] [ poster_id ] != -1 ) {

			if ( IsPlayerInRangeOfPoint ( playerid, 2.5, WantedPoster [ i ] [ poster_x ], WantedPoster [ i ] [ poster_y ], WantedPoster [ i ] [ poster_z ] ) && 
				GetPlayerInterior ( playerid ) == WantedPoster [ i ] [ poster_int ] && GetPlayerVirtualWorld ( playerid ) == WantedPoster [ i ] [ poster_vw ] ) {
				
				return i ;
			}

			else continue ;
		}

		else continue ;
	}

	return -1 ;
}

GetBountyIDByName ( playerid ) {

	for ( new i; i < MAX_POSTERS; i ++ ) {

		if ( WantedPoster [ i ] [ poster_id ] != -1 ) {

			if ( ! strcmp ( WantedPoster [ i ] [ poster_name ], Character [ playerid ] [ character_name ] ) ) {

				return i ;
			}
			else continue ;
		}
		else continue ;
	}

	return -1 ;
}

IsValidBounty ( playerid, targetid ) {

	new bountyid = GetBountyIDByName ( targetid ) ;
	if ( bountyid == Character [ playerid ] [ character_bounty_id ] ) {

		return true ;
	}
	return false ;
}

SetKilledBountyID ( playerid, targetid ) {

	player_BountyKill [ playerid ] = targetid;
}

IsCarryingCorpse ( playerid ) {

	return CarryingBountyCorpse [ playerid ] ;
}