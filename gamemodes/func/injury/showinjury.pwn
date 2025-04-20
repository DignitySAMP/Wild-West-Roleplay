enum WoundData {
	dmg_player,
	dmg_weapon,
	dmg_bodypart,
	Float: dmg_amount
} ;

#define MAX_WOUNDS	( MAX_PLAYERS * 10 )
new PlayerWounds [ MAX_WOUNDS ] [ WoundData ] ;

ClearWoundData ( ) {

	for ( new i; i < MAX_WOUNDS; i ++ ) {
		PlayerWounds [ i ] [ dmg_player ] = -1 ;
		PlayerWounds [ i ] [ dmg_bodypart ] = -1 ;
		PlayerWounds [ i ] [ dmg_weapon] = -1 ;
		PlayerWounds [ i ] [ dmg_amount ] = 0.0 ;
	}

	return true ;
}

GetFreeWoundID ( ) {

	for ( new i; i < MAX_WOUNDS; i ++ ) {

		if ( PlayerWounds [ i ] [ dmg_player ] == -1 ) {

			return i ;
		}

		else continue ;
	}

	return -1 ;
}

CMD:wounds ( playerid ) {


	SetPlayerWound ( playerid, 5 + random(34), 3 + random ( 6 ), random ( 25 ) ) ;

	return true ;
}

CMD:showinjuries ( playerid, params [] ) {

	new target ;

	if ( sscanf ( params, "k<u>", target ) ) {

		return SendServerMessage ( playerid, "/showinjuries [target]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected( target ) ) {

		return SendServerMessage ( playerid, "Target doesn't seem to be connected! Try again.", MSG_TYPE_ERROR ) ;
	}

	new string [ 512 ], count ;

	strcat(string, "Bodypart\tWound\tAmount\n" ) ;

	for ( new i; i < MAX_WOUNDS; i ++ ) {

		if ( PlayerWounds [ i ] [ dmg_player ] == target ) {

			strcat ( string, sprintf("%s \t %s \t (%0.1f)\n", GetBodyPartName (PlayerWounds [ i ] [ dmg_bodypart ] ),  GetWoundType ( PlayerWounds [ i ] [ dmg_weapon ] ), PlayerWounds [ i ] [ dmg_amount ] )) ;

			count ++ ;
		}

		else continue ;
	}

	if ( count == 0 ) {

		return SendServerMessage ( playerid, sprintf("%s (%d) has no visible injuries.", ReturnUserName ( target, false ), target ), MSG_TYPE_ERROR ) ;
		
	}

	ShowPlayerDialog(playerid, 546, DIALOG_STYLE_TABLIST_HEADERS, sprintf("%s (%d)'s injuries\n", ReturnUserName ( target, false ), target ), string, "Close", "" ) ;

	return true ;
}

HasPlayerBeenShotInBodyPart(playerid,bodypart) {

	for ( new i; i < MAX_WOUNDS; i ++ ) {

		if ( PlayerWounds [ i ] [ dmg_player ] == playerid ) {

			if(PlayerWounds [ i ] [ dmg_bodypart ] == bodypart) { return true; }
			else { continue; }
		}
		else { continue; }
	}
	return false;
}

SetPlayerWound ( playerid, weaponid, bodypart, Float: amount) {

	new woundid = GetFreeWoundID ( ) ;

	if ( woundid == -1 ) {

		return printf("Tried setting wound for player %s (%d) [DATA: wep %d amount %f] but GetFreeWoundID() returned -1.", MSG_TYPE_ERROR ) ;
	}

	PlayerWounds [ woundid ] [ dmg_player ] 	= playerid ;

	PlayerWounds [ woundid ] [ dmg_weapon ] 	= weaponid ;
	PlayerWounds [ woundid ] [ dmg_bodypart ] 	= bodypart ;

	PlayerWounds [ woundid ] [ dmg_amount ]		= amount ;

	return true ;
}

ResetPlayerWounds ( playerid ) {

	for ( new i; i < sizeof ( PlayerWounds ); i ++ ) {

		if ( PlayerWounds [ i ] [ dmg_player ] == playerid ) {

			PlayerWounds [ i ] [ dmg_player ] 	= -1 ;

			PlayerWounds [ i ] [ dmg_weapon ] 	= -1 ;
			PlayerWounds [ i ] [ dmg_bodypart ] = -1 ;

			PlayerWounds [ i ] [ dmg_amount ]	= 0.0 ;

		}

		else continue ;
	}

	return true ;
}

GetWoundType ( weaponid ) {

	new woundtype [ 25 ] ;

	switch ( weaponid ) {

		case 1 .. 3, 5 .. 7, 10 .. 15: woundtype = "Blunt Trauma" ;
		case 4, 8 .. 9: woundtype = "Stab Wound" ;
		case 22 .. 34: woundtype = "Gunshot Wound" ;
		case 18, 35 .. 37, 16, 39 .. 40: woundtype = "Burn Wound" ;
		default: woundtype = "Unknown";
	}

	return woundtype ;
}

GetBodyPartName ( bodypart ) {
	new bodypartname [ 25 ] ;

	switch ( bodypart ) {
		case BODY_PART_GROIN: 		bodypartname = "Groin" ;
		case BODY_PART_TORSO: 		bodypartname = "Torso" ;
		case BODY_PART_LEFT_ARM:	bodypartname = "Left Arm" ;
		case BODY_PART_RIGHT_ARM:	bodypartname = "Right Arm" ;
		case BODY_PART_LEFT_LEG: 	bodypartname = "Left Leg" ;
		case BODY_PART_RIGHT_LEG:	bodypartname = "Right Leg" ;
		case BODY_PART_HEAD:		bodypartname = "Head" ;
	}

	return bodypartname ;
}