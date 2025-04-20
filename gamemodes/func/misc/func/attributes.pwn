CMD:attributes ( playerid, params [] ){

	new attributes [ 144 ] ;

	if ( sscanf ( params, "s[144]", attributes ) ) {

		return SendServerMessage ( playerid, "/attributes [text]", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( attributes ) > 144 || strlen ( attributes ) < 1 ) {

		return SendServerMessage ( playerid, "Your attribute can't be longer than 144 characters or less than 1 character!", MSG_TYPE_ERROR ) ;
	}

	Character [ playerid ] [ character_attributes] [ 0 ] = EOS ;
	strcat ( Character [ playerid ] [ character_attributes], attributes, 144 ) ;

	new query [ 256 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_attributes= '%e' WHERE character_id = '%d'",
	attributes, Character [ playerid ] [ character_id ]  ) ;

	mysql_tquery ( mysql, query ) ;

	SendClientMessage(playerid, COLOR_ACTION, sprintf("** Attribution message: %s's attributes: %s", ReturnUserName ( playerid, true ), attributes ) ) ;
	//OldLog ( playerid, "attributes", sprintf("%s (%s) changed their attributes to %s",  Character [ playerid ] [ character_name ], Account [ playerid ] [ account_name ], attributes )) ;

	return true ;
}

CMD:att(playerid, params[]){
	return cmd_attributes(playerid, params);
}


CMD:examine ( playerid, params [] ) {

	new targetid ;

	if ( sscanf ( params, "k<u>", targetid ) ) {

		return SendServerMessage ( playerid, "/examine [target]", MSG_TYPE_ERROR ) ;
	}

	if ( targetid == INVALID_PLAYER_ID ) {

		return SendServerMessage ( playerid, "Player doesn't seem to be connected.", MSG_TYPE_ERROR ) ;
	}

	if ( targetid == playerid ) {

		SendClientMessage(targetid, COLOR_ACTION, sprintf("** Attribution message: %s's attributes: %s", ReturnUserName ( targetid, true ), Character [ targetid ] [ character_attributes ] ) ) ;
	}

	SetPlayerChatBubble(targetid, sprintf("%s's attributes: %s", ReturnUserName ( targetid, true ), Character [ targetid ] [ character_attributes ]), COLOR_ACTION, 20.0, 10000 ) ;
 
	return true ;
}