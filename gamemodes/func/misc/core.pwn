#include "func/misc/func/antispam.pwn"
#include "func/misc/func/pause.pwn"
#include "func/misc/func/shakehands.pwn"
#include "func/misc/func/fader.pwn"
#include "func/misc/func/mask.pwn"
#include "func/misc/func/attributes.pwn"
#include "func/misc/func/gunshells.pwn"
#include "func/misc/func/motds.pwn"

new FriskingPlayer [ MAX_PLAYERS ] ;
CMD:frisk ( playerid, params [] ) {

	new target ;

	if ( sscanf ( params, "k<u>", target )) {

		return SendServerMessage ( playerid, "/frisk [id]", MSG_TYPE_ERROR ) ;
	}

	if ( target == INVALID_PLAYER_ID ) {

		return SendServerMessage ( playerid, "This player isn't connected.", MSG_TYPE_ERROR ) ;
	}

	FriskingPlayer [ target ] = playerid ;

	SendServerMessage ( target, sprintf("[FRISK] %s has attempted to frisk you. Type /accept frisk to accept.", ReturnUserName ( playerid, true )), MSG_TYPE_INFO ) ;
	SendServerMessage ( playerid, "The frisk request is pending, they have to accept the frisk first.", MSG_TYPE_INFO ) ;

	//OldLog ( playerid, "shakehands", sprintf("(%d) %s requested to frisk (%d) %s", playerid, ReturnUserName ( playerid, true ), target, ReturnUserName ( target, true ) )) ;


	return true ;
}

CMD:checktime ( playerid, params [] ) {

	if ( ! DoesPlayerHaveItemByExtraParam ( playerid, POCKET_WATCH ) ) {

		return SendServerMessage ( playerid, "You don't have a pocket watch!", MSG_TYPE_ERROR ) ;
	}

	SendServerMessage ( playerid, sprintf("The current time is %i:%i.",serverHour, serverMin), MSG_TYPE_INFO ) ;
	SetPlayerChatBubble ( playerid, sprintf("* %s checks the time.", ReturnUserName ( playerid, false , true ) ), COLOR_ACTION, 20.0, 7000 );
	cmd_time ( playerid, "" ) ;
	return true ;
}


CMD:coin ( playerid, params [] ) {

	new coinflip = random ( 2 ), coinresult [ ] [ ] = {

		"Heads", "Tails"
	} ;

	ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf ( "*** %s flips a coin and it lands on %s", ReturnUserName ( playerid, false ), coinresult [ coinflip ] ) ) ;

	return true ;
}

CMD:roll ( playerid, params [] ) {

	return ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf ( "*** %s rolls a dice and it rolls on %d.", ReturnUserName ( playerid, false ), 1 + random ( 5 )) ) ;
}


CMD:accept(playerid, params[]){

	if ( ! IsPlayerFree ( playerid ) ) {

		return SendServerMessage ( playerid, "You can't do this right now", MSG_TYPE_ERROR ) ; 
	}

	if ( isnull (params) ) {
	 	SendServerMessage ( playerid, "/accept [param]", MSG_TYPE_ERROR ) ;
		SendClientMessage(playerid, COLOR_BLUE, "[PARAMS]:{DEDEDE} greet, frisk");
		return 1;
	}


	//OldLog ( playerid, "accept", sprintf("(%d) %s used /accept with PREFIX %s", playerid, ReturnUserName ( playerid, true ), params )) ;

	if (!strcmp(params, "greet", true) && PlayerShakeOffer [ playerid ] != INVALID_PLAYER_ID)
	{
	    new targetid = PlayerShakeOffer [ playerid ], type = PlayerShakeType [ playerid ];

        if (!IsPlayerNearPlayer(playerid, targetid, 6.0)) {

		    return SendServerMessage(playerid, "You are not near that player.", MSG_TYPE_ERROR);
        }

		SetPlayerToFacePlayer(targetid, playerid);
		SetPlayerToFacePlayer(playerid, targetid);

		PlayerShakeOffer [ playerid ] = INVALID_PLAYER_ID;
		PlayerShakeType [ playerid ] = 0;

		switch (type)
		{
		    case 1:
			{
				ApplyAnimation(playerid, "GANGS", "hndshkaa", 4.0, 0, 0, 0, 0, 0, 1);
				ApplyAnimation(targetid, "GANGS", "hndshkaa", 4.0, 0, 0, 0, 0, 0, 1);
			}
			case 2:
			{
				ApplyAnimation(playerid, "GANGS", "hndshkba", 4.0, 0, 0, 0, 0, 0, 1);
				ApplyAnimation(targetid, "GANGS", "hndshkba", 4.0, 0, 0, 0, 0, 0, 1);
			}
			case 3:
			{
				ApplyAnimation(playerid, "GANGS", "hndshkda", 4.0, 0, 0, 0, 0, 0, 1);
				ApplyAnimation(targetid, "GANGS", "hndshkda", 4.0, 0, 0, 0, 0, 0, 1);
			}
			case 4:
			{
				ApplyAnimation(playerid, "GANGS", "hndshkea", 4.0, 0, 0, 0, 0, 0, 1);
				ApplyAnimation(targetid, "GANGS", "hndshkea", 4.0, 0, 0, 0, 0, 0, 1);
			}
			case 5:
			{
				ApplyAnimation(playerid, "GANGS", "hndshkfa", 4.0, 0, 0, 0, 0, 0, 1);
				ApplyAnimation(targetid, "GANGS", "hndshkfa", 4.0, 0, 0, 0, 0, 0, 1);
			}
			case 6:
			{
			    ApplyAnimation(playerid, "GANGS", "prtial_hndshk_biz_01", 4.0, 0, 0, 0, 0, 0, 1);
			    ApplyAnimation(targetid, "GANGS", "prtial_hndshk_biz_01", 4.0, 0, 0, 0, 0, 0, 1);
			}
	    }


		//OldLog ( playerid, "shakehands", sprintf("(%d) %s has greeted %d %s", playerid, ReturnUserName ( playerid, true ), targetid, ReturnUserName ( targetid, true ) )) ;

	    SendServerMessage(playerid, sprintf( "You have accepted %s's handshake.", ReturnUserName(targetid, false)), MSG_TYPE_INFO );
	    SendServerMessage(targetid, sprintf( "%s has accepted your handshake.", ReturnUserName(playerid, false)), MSG_TYPE_INFO );
	}

	else if (!strcmp(params, "frisk", true) && FriskingPlayer [ playerid ] != INVALID_PLAYER_ID) {

		new target = FriskingPlayer [ playerid ] ;


 		if (!IsPlayerNearPlayer(playerid, target, 6.0)) {

		    return SendServerMessage(playerid, "You are not near that player.", MSG_TYPE_ERROR);
        }

		SendClientMessage(target, COLOR_TAB0, sprintf("|________________________| Frisk of (%d) %s |________________________|", playerid, ReturnUserName ( playerid, true ) ) ) ;
		SendClientMessage( target, COLOR_TAB1,  sprintf("[HANDS]: %s with %d ammo.", ReturnWeaponName ( Character [ playerid ] [ character_handweapon] ), Character [ playerid ] [ character_handammo ] )) ;
		SendClientMessage( target, COLOR_TAB2,  sprintf("[PANTS]: %s with %d ammo.", ReturnWeaponName ( Character [ playerid ] [ character_pantsweapon] ), Character [ playerid ] [ character_pantsammo ] )) ;
		SendClientMessage( target, COLOR_TAB1,  sprintf("[BACK]: %s with %d ammo.", ReturnWeaponName ( Character [ playerid ] [ character_backweapon] ), Character [ playerid ] [ character_backammo ] )) ;
		SendClientMessage( target, COLOR_TAB1,  sprintf("[MONEY]: $%s", IntegerWithDelimiter ( Character [ playerid ] [ character_handmoney ] )) )  ;

		FriskingPlayer [ playerid ] = INVALID_PLAYER_ID ;

		ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf ( "* %s has just frisked %s", ReturnUserName ( target, false ), ReturnUserName ( playerid, false ) ) ) ;

		//OldLog ( playerid, "frisk", sprintf("(%d) %s has frisked %d %s", playerid, ReturnUserName ( playerid, true ), target,ReturnUserName ( target, true ) )) ;

	}
 

	return true ;
}