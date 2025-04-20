// Handshake script (CMD:accept and CMD:shakehands)
new PlayerShakeOffer [ MAX_PLAYERS ] ;
new PlayerShakeType [ MAX_PLAYERS ] ;

CMD:shakehand(playerid, params[]) {

	if ( ! IsPlayerFree ( playerid ) ) {

		return SendServerMessage ( playerid, "You can't do this right now", MSG_TYPE_ERROR ) ; 
	}

	new userid, type;

	if (sscanf(params, "k<u>d", userid, type)) {

		return SendServerMessage ( playerid, "/shakehand [playerid, name] [type]", MSG_TYPE_ERROR ) ;
	}

    if (!IsPlayerConnected(userid) || !IsPlayerNearPlayer(playerid, userid, 6.0)) {

		return SendServerMessage ( playerid, "The specified player is disconnected or not near you.", MSG_TYPE_ERROR ) ;
    }

    if (userid == playerid) {

		return SendServerMessage ( playerid, "You can't shake your own hand.", MSG_TYPE_ERROR ) ;
    }

	if (type < 1 || type > 6){
		return SendServerMessage ( playerid, "Type can't be lower than 1, or higher than 6.", MSG_TYPE_ERROR ) ;
	}

	PlayerShakeOffer [ userid ] = playerid;
	PlayerShakeType [ userid ] = type;

	SendServerMessage(userid, sprintf( "%s has offered to shake your hand (type \"/accept greet\").", ReturnUserName(playerid, false)), MSG_TYPE_INFO );
	SendServerMessage(playerid, sprintf( "You have offered to shake %s's hand.", ReturnUserName(userid, false)), MSG_TYPE_INFO );
	
	//OldLog ( playerid, "shakehands", sprintf("(%d) %s requested to shake hands with (%d) %s [type %d]", playerid, ReturnUserName ( playerid, true ), userid, ReturnUserName ( userid, true ), type )) ;

	return 1;
}