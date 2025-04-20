#define MAX_PRISON_TIME		(130)

ptask PlayerPrisonTimer[60000](playerid) {

////	print("PlayerPrisonTimer timer called (prison.pwn)");

	if ( Character [ playerid ] [ character_prison ] != 0) {

		if ( Character [ playerid ] [ character_prison ] < gettime ( ) ) {

			new id = GetPointIDFromType ( playerid, POINT_TYPE_SHERIFF ), query [ 512 ] ;

			Character [ playerid ] [ character_prison ] = 0;

			Character [ playerid ] [ character_prison_pos_x ] = 0.0;
			Character [ playerid ] [ character_prison_pos_y ] = 0.0;
			Character [ playerid ] [ character_prison_pos_z ] = 0.0;

			Character [ playerid ] [ character_prison_interior ] = 0 ;
			Character [ playerid ] [ character_prison_vw ] = 0 ;
			Character [ playerid ] [ character_prison_bail] = 0 ;

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_prison = %d, character_prison_pos_x = '%f', character_prison_pos_y = '%f',character_prison_pos_z = '%f', character_prison_interior = %d, character_prison_vw = %d WHERE character_id = %d",
				Character [ playerid ] [ character_prison ], Character [ playerid ] [ character_prison_pos_x ], Character [ playerid ] [ character_prison_pos_y ], Character [ playerid ] [ character_prison_pos_z ], Character [ playerid ] [ character_prison_interior ], Character [ playerid ] [ character_prison_vw ], Character [ playerid ] [ character_id ] ) ;
			mysql_tquery ( mysql, query );

			if(id != -1) {
				
				ac_SetPlayerPos ( playerid, Point [ id ] [ point_ext_x ], Point [ id ] [ point_ext_y ], Point [ id ] [ point_ext_z ] ) ;

				SetPlayerInterior ( playerid, Point [ id ] [ point_int ] ) ;
				SetPlayerVirtualWorld ( playerid, Point [ id ] [ point_vw ] ) ;
			}

			else {

				ac_SetPlayerPos(playerid,SERVER_SPAWN_X,SERVER_SPAWN_Y,SERVER_SPAWN_Z);

				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}

			SendClientMessage ( playerid, COLOR_DEFAULT, "You've done your time and have been released." ) ;
		}
	}
}

CMD:prisontimeleft ( playerid, params [] ) {

	if ( Character [ playerid ] [ character_prison ] != 0 ) {

		if ( Character [ playerid ] [ character_prison ] > gettime() ) {

			return SendServerMessage ( playerid, sprintf("Prison/jail time left: %d minutes", (Character [ playerid ] [ character_prison ] - gettime()) / 60), MSG_TYPE_INFO ) ;
		}

		else if ( Character [ playerid ] [ character_prison ] < gettime() ) {

			return SendServerMessage ( playerid, "Prison/jail time left: Less than 1 minute remaining.", MSG_TYPE_INFO ) ;
		}
	}

	else SendServerMessage ( playerid, "You aren't in jail/prison!", MSG_TYPE_ERROR ) ;

	return true ;
}

CMD:prison ( playerid, params [] ) { // time, reason

	new user, time, posseid = Character [ playerid ] [ character_posse ], bail, cents ;

	if ( ! IsPlayerInPosse ( playerid ) || !IsLawEnforcementPosse ( posseid ) ) {

		return SendServerMessage ( playerid, "You have to be in a police posse in order to do this command.", MSG_TYPE_INFO ) ;
	}

	if ( sscanf ( params, "k<u>iI(0)", user, time, bail, cents)) {

		return SendServerMessage ( playerid, "Syntax: /prison <user> <time: minutes> <bail (dollars): total of all fines, if none add 25. To disable, add 0.> <optional:cents>", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( user ) ) {

		return SendServerMessage ( playerid, "This player isn't connected!", MSG_TYPE_INFO ) ;	
	}

	if ( time > MAX_PRISON_TIME ) {

		return SendServerMessage ( playerid, "You can't arrest someone longer than 130 minutes.", MSG_TYPE_WARN ) ;
	}

	if ( Character [ user ] [ character_prison ] ) {

		return SendServerMessage ( playerid, "This player is already in prison!", MSG_TYPE_WARN ) ;
	}

	if ( bail < 0 ) {

		return SendServerMessage(playerid, "You cannot set someone's bail to a negative amount.", MSG_TYPE_WARN);
	}

	if ( cents < 0 || cents > 99 ) {

		return SendServerMessage(playerid, "You can only set cents between 1-99 cent(s).",MSG_TYPE_WARN);
	}

	//if ( GetPointIDFromType ( playerid, POINT_TYPE_SHERIFF ) == -1 ) {
//
	//	return SendServerMessage ( playerid, "You're not in a sheriff office or prison!", MSG_TYPE_WARN ) ;
	//}

	inline PrisonPlayerWarning(pid, dialogid, response, listitem, string:inputtext[]) {

		#pragma unused inputtext, listitem, dialogid, pid

		if ( ! response ) {

			return false ;
		}

		new Float: pos_x, Float: pos_y, Float: pos_z, query [ 512 ] ;			

		GetPlayerPos ( user, pos_x, pos_y, pos_z ) ;

		Character [ user ] [ character_prison ] = gettime() + ( time * 60 ) ;

		Character [ user ] [ character_prison_pos_x ] = pos_x;
		Character [ user ] [ character_prison_pos_y ] = pos_y;
		Character [ user ] [ character_prison_pos_z ] = pos_z;

		Character [ user ] [ character_prison_interior ] = GetPlayerInterior ( user ) ;
		Character [ user ] [ character_prison_vw ] = GetPlayerVirtualWorld ( user ) ;

		Character [ user ] [ character_prison_bail] = bail ;
		Character [ user ] [ character_prison_bail_cents ] = cents ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_prison = %d, character_prison_pos_x = '%f', character_prison_pos_y = '%f',character_prison_pos_z = '%f', character_prison_interior = %d, character_prison_vw = %d, character_prison_bail = %d, character_prison_bail_cents = %d WHERE character_id = %d",
				Character [ user ] [ character_prison ], Character [ user ] [ character_prison_pos_x ], Character [ user ] [ character_prison_pos_y ], Character [ user ] [ character_prison_pos_z ], Character [ user ] [ character_prison_interior ], Character [ user ] [ character_prison_vw ], Character [ user ] [ character_prison_bail], Character [ user ] [ character_prison_bail_cents], Character [ user ] [ character_id ] ) ;
		mysql_tquery ( mysql, query );

		SendServerMessage ( user, sprintf("You've been put into prison for %i %s.", time, (time == 1) ? ( "minute" ) : ( "minutes" ) ), MSG_TYPE_INFO ) ;

		SendPosseWarning ( posseid, sprintf("{[ %s %s has prisoned %s for %i %s. ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, false, false ), ReturnUserName ( user, false, false ), time, (time == 1) ? ( "minute" ) : ( "minutes" ) ) ) ;

		WriteLog ( playerid, "prison", sprintf("%s (%d) has prisoned %s for %i %s.", ReturnUserName ( playerid, false, false ), ReturnUserName ( user, false, false ), time, (time == 1) ? ( "minute" ) : ( "minutes" ) ) ) ;

	}

    Dialog_ShowCallback(playerid, using inline PrisonPlayerWarning, DIALOG_STYLE_MSGBOX, "{C23030}WARNING", sprintf("{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\nYou're about to prison %s for %i %s.\nMake sure the time is correct and that %s is in a cell.\n\nWith that in mind, go ahead.", ReturnUserName ( user, false ), time, (time == 1) ? ( "minute" ) : ( "minutes" ), ReturnUserName ( user, false ) ), "{C23030}Proceed", "Cancel" ) ;		

	return true ;
}

CMD:unprison ( playerid, params [] ) { 

	new targetid, Float: pos_x, Float: pos_y, Float: pos_z, posseid = Character [ playerid ] [ character_posse ] ;

	if ( ! IsPlayerInPosse ( playerid ) || !IsLawEnforcementPosse ( posseid ) ) {

		return SendServerMessage ( playerid, "You have to be in a police posse in order to do this command.", MSG_TYPE_INFO ) ;
	}


	if ( sscanf ( params, "k<u>", targetid )) {

		return SendServerMessage ( playerid, "Syntax: /unprison <user>", MSG_TYPE_ERROR ) ;
	}

	if ( !Character [ targetid ] [ character_prison ] ) {

		return SendServerMessage ( playerid, "This player isn't in prison!", MSG_TYPE_WARN ) ;
	}

	GetPlayerPos ( targetid, pos_x, pos_y, pos_z ) ;

	if ( IsPlayerInRangeOfPoint ( playerid, 2.5, pos_x, pos_y, pos_z ) && GetPlayerInterior ( playerid ) == GetPlayerInterior ( targetid ) && GetPlayerVirtualWorld ( playerid ) == GetPlayerVirtualWorld ( targetid ) ) {

		new id = GetPointIDFromType ( targetid, POINT_TYPE_SHERIFF ), query [ 512 ] ;

		Character [ targetid ] [ character_prison ] = 0 ;

		Character [ targetid ] [ character_prison_pos_x ] = 0.0;
		Character [ targetid ] [ character_prison_pos_y ] = 0.0;
		Character [ targetid ] [ character_prison_pos_z ] = 0.0;

		Character [ targetid ] [ character_prison_interior ] = 0 ;
		Character [ targetid ] [ character_prison_vw ] = 0 ;
		Character [ targetid ] [ character_prison_bail] = 0 ;
		Character [ targetid ] [ character_prison_bail_cents ] = 0 ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_prison = %d, character_prison_pos_x = '%f', character_prison_pos_y = '%f',character_prison_pos_z = '%f', character_prison_interior = %d, character_prison_vw = %d, character_prison_bail = %d, character_prison_bail_cents = %d WHERE character_id = %d",
				Character [ targetid ] [ character_prison ], Character [ targetid ] [ character_prison_pos_x ], Character [ targetid ] [ character_prison_pos_y ], Character [ targetid ] [ character_prison_pos_z ], Character [ targetid ] [ character_prison_interior ], Character [ targetid ] [ character_prison_vw ], Character [ targetid ] [ character_prison_bail ], Character [ targetid ] [ character_prison_bail_cents], Character [ targetid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query );

		if(id != -1) {
			
			ac_SetPlayerPos ( targetid, Point [ id ] [ point_ext_x ], Point [ id ] [ point_ext_y ], Point [ id ] [ point_ext_z ] ) ;

			SetPlayerInterior ( targetid, Point [ id ] [ point_int ] ) ;
			SetPlayerVirtualWorld ( targetid, Point [ id ] [ point_vw ] ) ;
		}
		else {

			ac_SetPlayerPos(targetid,SERVER_SPAWN_X,SERVER_SPAWN_Y,SERVER_SPAWN_Z);

			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
		}

		SendServerMessage ( targetid, sprintf("You have been released from prison by %s %s.", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, false ) ), MSG_TYPE_INFO ) ;

		SendPosseWarning ( posseid, sprintf("{[ %s %s has unprisoned %s. ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, false ), ReturnUserName ( targetid, false ) ) ) ;
	}

	else return SendServerMessage ( playerid, "You are not near that player.", MSG_TYPE_ERROR ) ;

	return true ;
}


CMD:bail ( playerid, params [ ] ) {

	//SendClientMessage(playerid, -1, "This isn't in use yet." ) ;
	if ( ! Character [ playerid ] [ character_prison ] ) {

		return SendServerMessage ( playerid, "You don't seem to be prisoned. Contact an admin if you are.", MSG_TYPE_ERROR ) ;
	}

	if ( ! Character [ playerid ] [ character_prison_bail ] ) {

		if ( ! Character [ playerid ] [ character_prison_bail_cents] ) { return SendServerMessage ( playerid, "You're not eligible for bail.", MSG_TYPE_ERROR ) ; }
	}

	if ( Character [ playerid ] [ character_prison_bail ] > Character [ playerid ] [ character_handmoney ] || (Character[playerid][character_handmoney] > Character[playerid][character_prison_bail] && Character[playerid][character_handchange] < Character[playerid][character_prison_bail_cents])) {

		return SendServerMessage ( playerid, sprintf("You don't have enough money for your bail!  Total: $%s.%02d",IntegerWithDelimiter(Character[playerid][character_prison_bail]),Character[playerid][character_prison_bail_cents]), MSG_TYPE_ERROR ) ;
	}


	for ( new i; i < MAX_POSSES; i ++ ) {

		if ( Posse [ i ] [ posse_id ] != -1 ) {

			if ( Posse [ i ] [ posse_type ] == 2 ) {

				Posse [ i ] [ posse_bank ] += Character [ playerid ] [ character_prison_bail ] ;
				Posse [ i ] [ posse_bank_decimal ] += Character[playerid][character_prison_bail_cents];
				SendPosseMessage ( i, sprintf("{[ %s (%d) has paid for their bail. ]}", ReturnUserName ( playerid, false, false ), playerid ) ) ;
				break;
			}
		}

		//return true ;
	}

	SendServerMessage ( playerid, "You've paid for your crimes.", MSG_TYPE_INFO ) ;
	new id = GetPointIDFromType ( playerid, POINT_TYPE_SHERIFF ), query [ 512 ] ;

	Character [ playerid ] [ character_prison ] = 0 ;

	Character [ playerid ] [ character_prison_pos_x ] = 0.0;
	Character [ playerid ] [ character_prison_pos_y ] = 0.0;
	Character [ playerid ] [ character_prison_pos_z ] = 0.0;

	Character [ playerid ] [ character_prison_interior ] = 0 ;
	Character [ playerid ] [ character_prison_vw ] = 0 ;
	Character [ playerid ] [ character_prison_bail] = 0 ;
	Character [ playerid ] [ character_prison_bail_cents ] = 0 ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_prison = %d, character_prison_pos_x = '%f', character_prison_pos_y = '%f',character_prison_pos_z = '%f', character_prison_interior = %d, character_prison_vw = %d, character_prison_bail = %d, character_prison_bail_cents = %d WHERE character_id = %d",
			Character [ playerid ] [ character_prison ], Character [ playerid ] [ character_prison_pos_x ], Character [ playerid ] [ character_prison_pos_y ], Character [ playerid ] [ character_prison_pos_z ], Character [ playerid ] [ character_prison_interior ], Character [ playerid ] [ character_prison_vw ], Character [ playerid ] [ character_prison_bail ], Character [ playerid ] [ character_prison_bail_cents], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query );

	if(id != -1) {
			
		ac_SetPlayerPos ( playerid, Point [ id ] [ point_ext_x ], Point [ id ] [ point_ext_y ], Point [ id ] [ point_ext_z ] ) ;

		SetPlayerInterior ( playerid, Point [ id ] [ point_int ] ) ;
		SetPlayerVirtualWorld ( playerid, Point [ id ] [ point_vw ] ) ;
	}
	else {

		ac_SetPlayerPos(playerid,SERVER_SPAWN_X,SERVER_SPAWN_Y,SERVER_SPAWN_Z);

		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
	}

	return true; 
}