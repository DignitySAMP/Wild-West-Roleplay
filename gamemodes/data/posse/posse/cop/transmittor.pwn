#define TRANSM_COLOR	( 0x96713EFF )

#define MAX_TRANSMITTORS	( 3 )

new TransmittorPole [ MAX_TRANSMITTORS ] ;
new TransmittorZone [ MAX_TRANSMITTORS ] ;

Init_LoadTransmittors ( ) {

	TransmittorPole [ 0 ] = CreateDynamicObject(3244, -971.63556, 1483.60852, 44.97794,   4.08000, 5.82001, 0.00000); // LB
	SetDynamicObjectMaterial ( TransmittorPole [ 0 ], 0, 12937, "sw_oldshack", "rustc256128", 0xFFFFFFFF ) ;

	TransmittorPole [ 1 ] = CreateDynamicObject(3244, -1487.93323, 2443.58228, 48.63973,   -0.66000, 2.22000, 0.00000); // EQ
	SetDynamicObjectMaterial ( TransmittorPole [ 1 ], 0, 12937, "sw_oldshack", "rustc256128", 0xFFFFFFFF ) ;

	TransmittorPole [ 2 ] = CreateDynamicObject(3244, -2636.31177, 2253.28149, 8.70918,   0.00000, 0.00000, 12.54000); // BS
	SetDynamicObjectMaterial ( TransmittorPole [ 2 ], 0, 12937, "sw_oldshack", "rustc256128", 0xFFFFFFFF ) ;

	TransmittorZone [ 2 ] = CreateDynamicRectangle( -3000, 2052, -2130, 3000 ) ; // BS
	TransmittorZone [ 1 ] = CreateDynamicRectangle( -2130, 1630, -646, 3000 ) ; // EQ
	TransmittorZone [ 0 ] = CreateDynamicRectangle( -1269.046875, 570, -505.046875, 1630 ) ; // LB
}

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

CMD:td(playerid, params [] ) {

	new text [ 144 ], posseid = Character [ playerid ] [ character_posse ] ;

	if ( ! IsPlayerInPosse ( playerid ) || !IsLawEnforcementPosse ( posseid ) ) {

		return SendServerMessage ( playerid, "You have to be in a police posse in order to do this command.", MSG_TYPE_INFO ) ;
	}

	if ( DoesPlayerHaveItemByExtraParam ( playerid, RADIO ) == -1 ) {

		return SendServerMessage ( playerid, "You need a transmission device to use this command.", MSG_TYPE_INFO ) ;
	}

	if ( sscanf ( params, "s[144]", text ) ) {

		return SendServerMessage(playerid, "/t(ransmission)d(evice)(/r(adio)) [text]", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( text ) > 144 ) {

		return SendServerMessage(playerid, "Your input can't be longer than 144 characters.", MSG_TYPE_ERROR ) ;
	}

	SendTransmittorMessage ( playerid, text) ;

	return true ;
}

CMD:transmissiondevice ( playerid, params [] ) {

	return cmd_td ( playerid, params ) ;
}

CMD:radio ( playerid, params [] ) {

	return cmd_td ( playerid, params ) ;
}

CMD:r ( playerid, params [] ) {

	return cmd_td ( playerid, params ) ;
}

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

Float: GetDistanceFromTransmittors ( playerid ) {

	new area = -1 ;

	for ( new i; i < MAX_TRANSMITTORS; i ++ ) {

		if ( IsPlayerInDynamicArea(playerid, TransmittorZone [ i ] )) {

			area = i ;
			break ;
		}

		else continue ;
	}

	if ( area == -1 ) {

		return -1.0 ;
	}

	new Float: pos_x, Float: pos_y, Float: pos_z ;

	GetDynamicObjectPos ( TransmittorPole [ area ], pos_x, pos_y, pos_z ) ;
	new Float: yds = GetPlayerDistanceFromPoint(playerid, pos_x, pos_y, pos_z ) ;

	return yds ;
}

SendTransmittorMessage ( playerid, text [] ) {

	new Float: yds = GetDistanceFromTransmittors ( playerid ) ;

	if ( yds == - 1.0 ) {

		return SendClientMessage(playerid, -1, "Your transmitted message was responded by a static noise. Seems like you're not in a transmission zone." ) ;
	}

	SendSplitMessage(playerid, 0xCCAB7CFF, sprintf("** {96713E}[Transmission]{CCAB7C} %s: %s **", ReturnUserName ( playerid, false ), text ) );

	new rippled_text [ 256 ], scramble_count ;
	strcat ( rippled_text, text ) ;

	/*
	//if ( yds < 50.0 ) { scramble_count = 2; }
	if ( yds > 50.0 && yds < 100.0 ) { scramble_count = 2; } 
	else if ( yds > 100.0 && yds < 150.0 ) { scramble_count = 4; } 
	else if ( yds > 150.0 && yds < 200.0 ) { scramble_count = 6; } 
	else if ( yds > 200.0 && yds < 250.0 ) { scramble_count = 8; } 
	else if ( yds > 250.0 && yds < 300.0 ) { scramble_count = 10; } 
	else if ( yds > 300.0 ) { scramble_count = 12; } 

	if ( strlen ( rippled_text ) < scramble_count ) { scramble_count = scramble_count / 2 ; }

	for ( new i = 0; i < scramble_count ; i++ )
	{
		new replace = random ( strlen ( rippled_text ) ), character = replace ;
		strdel ( rippled_text, replace, replace+1 ) ;
		if ( rippled_text [ character ] != ' ' ) { strins ( rippled_text, ".", replace ) ; }
		else { strins ( rippled_text, "..", replace ) ; }
	}
	*/

	foreach ( new i : Player ) {

		if ( i == playerid ) continue;

		if ( IsLawEnforcementPosse ( Character [ i ] [ character_posse ] ) ) {

			if ( DoesPlayerHaveItemByExtraParam ( i, RADIO ) ) {

				new Float: dist = GetDistanceFromTransmittors ( i ) ;

				if ( dist != -1.0 ) {

					if ( yds > 50.0 && yds < 100.0 ) { scramble_count = 2; } 
					else if ( yds > 100.0 && yds < 150.0 ) { scramble_count = 4; } 
					else if ( yds > 150.0 && yds < 200.0 ) { scramble_count = 6; } 
					else if ( yds > 200.0 && yds < 250.0 ) { scramble_count = 8; } 
					else if ( yds > 250.0 && yds < 300.0 ) { scramble_count = 10; } 
					else if ( yds > 300.0 ) { scramble_count = 12; } 

					if ( strlen ( rippled_text ) < scramble_count ) { scramble_count = scramble_count / 2 ; }

					for ( new j = 0; j < scramble_count ; j++ )
					{
						new replace = random ( strlen ( rippled_text ) ), character = replace ;
						strdel ( rippled_text, replace, replace+1 ) ;
						if ( rippled_text [ character ] != ' ' ) { strins ( rippled_text, ".", replace ) ; }
						else { strins ( rippled_text, "..", replace ) ; }
					}

					SendSplitMessage(i, 0xCCAB7CFF, sprintf("** {96713E}[Transmission]{CCAB7C} %s: %s **", ReturnUserName ( playerid, false ), rippled_text ) );
				}
				else continue;
			}
			else continue;
		}
		else continue;
	}

	return true ;
}