#include <cuffs>

IsLawEnforcementPosse ( posseid ) {

	if ( posseid == -1 ) {

		return false ;
	}

	if ( Posse [ posseid ] [ posse_type ] == 1 || Posse [ posseid ] [ posse_type ] == 2 ) {

		return true ;
	}

	return false ;
}


new IsPlayerTackled [ MAX_PLAYERS ] ;
CMD:tackle ( playerid, params [] ) {

 	new posseid = Character [ playerid ] [ character_posse ] ;

	if ( ! IsPlayerInPosse ( playerid ) || !IsLawEnforcementPosse ( posseid ) ) {

		return SendServerMessage ( playerid, "You have to be in a police posse in order to do this command.", MSG_TYPE_INFO ) ;
	}

	new closest = INVALID_PLAYER_ID, Float: x, Float: y, Float: z ;

	foreach(new i: Player) {

		if ( i == playerid ) {

			continue ;
		}

		if ( IsPlayerTackled [ i ] ) {

			continue ;
		}

		if ( IsPlayerRidingHorse [ i ] ) {

			IsPlayerRidingHorse [ i ] = false ;
			SendServerMessage ( playerid, "You've been tackled off of your horse!", MSG_TYPE_INFO ) ;

			RemovePlayerAttachedObject(playerid, 6);
			ClearAudioForZone ( playerid ) ;
		}

		GetPlayerPos ( i, x, y, z ) ;

		if ( IsPlayerInRangeOfPoint ( playerid, 3.5, x, y, z ) ) {

			closest = i ;
			break ;
		}

		else continue ;
	}

	if ( closest == INVALID_PLAYER_ID || ! IsPlayerConnected (closest )) {

		return SendServerMessage ( playerid, "You're not close enough to someone!", MSG_TYPE_ERROR ) ;
	}

	TogglePlayerControllable ( closest, false ) ;

	new Float: angle ;

	GetPlayerFacingAngle(playerid, angle ) ;
	SetPlayerFacingAngle ( closest, angle ) ;

	AnimationLoop(playerid, "PED", "EV_dive", 4.1, 0, 1, 1, 1, 0, 1);
	AnimationLoop(closest, "PED", "EV_dive", 4.1, 0, 1, 1, 1, 0, 1);

	ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has tackled %s.", ReturnUserName ( playerid, false ), ReturnUserName ( closest, false ) )) ;
	SendServerMessage ( closest, sprintf("You've been tackled by (%d) %s. You will be unfrozen shortly. Please roleplay accordingly.", playerid, ReturnUserName ( playerid, true )), MSG_TYPE_ERROR );

	defer TackleUnfreeze(closest) ;
	defer TackleAnimFix(closest);

	IsPlayerTackled [ closest ] = true ;

	return true ;
}

timer TackleAnimFix[1000](playerid) {

	return AnimationLoop(playerid,"PED", "FLOOR_hit_f", 4.1, 0, 1, 1, 1, 1, 1); 
}

timer TackleUnfreeze[60000](playerid) {

	SendServerMessage ( playerid, "You've woken up from the tackle. You still feel a little dizzy, so take it easy.", MSG_TYPE_WARN ) ;

	TogglePlayerControllable ( playerid, true ) ;
	IsPlayerTackled [ playerid ] = false ;

	return AnimationLoop(playerid,"PED", "FLOOR_hit_f", 4.1, 0, 1, 1, 1, 1, 1); 
}


new bool: playerCuffed [ MAX_PLAYERS ] ;
CMD:prisoners ( playerid, params [] ) {

	new posseid = Character [ playerid ] [ character_posse ] ;

	if ( ! IsPlayerInPosse ( playerid ) || !IsLawEnforcementPosse ( posseid ) ) {

		return SendServerMessage ( playerid, "You have to be in a police posse in order to do this command.", MSG_TYPE_INFO ) ;
	}

	if ( GetPointIDFromType ( playerid, POINT_TYPE_SHERIFF ) == -1 ) {

		return SendServerMessage ( playerid, "You are not in a sheriff's office!", MSG_TYPE_ERROR );
	}

	new count ;

	SendServerMessage ( playerid, "List of prisoners:", MSG_TYPE_INFO ) ;

	foreach ( new i : Player ) {

		if ( Character [ i ] [ character_prison ] ) {

			SendClientMessage(playerid, -1, sprintf("(%d) %s: prisoned for %d minutes", i, ReturnUserName ( i ), (Character [ i ] [ character_prison] - gettime()) / 60 ) );
			count ++ ;
		}

		else continue;
	}


	if ( ! count ) {

		return SendClientMessage ( playerid, -1, "No prisoners at this time." ) ;
	}

/*
	inline cop_CheckPrisoners(pid, dialogid, response, listitem, string:inputtext[]) {

		#pragma unused inputtext, listitem, dialogid, pid, response

		new count = 0;

		foreach ( new i : Player ) {

			if ( Character [ i ] [ character_prison ] ) {

				strcat ( string, sprintf("%s\n", ReturnUserName ( i, true ) ) ) ;
				count ++ ;
			}
			else continue;
		}

		if ( ! count ) {

			return SendServerMessage ( playerid, "There are no prisoners online.", MSG_TYPE_ERROR ) ;
		}
	}

	Dialog_ShowCallback(playerid, using inline cop_CheckPrisoners, DIALOG_STYLE_MSGBOX, "Prisoners", string, "Exit", "" );
*/
	return true ;
}

CMD:cuff ( playerid, params [] ) {

	new targetid, Float: pos_x, Float: pos_y, Float: pos_z, posseid = Character [ playerid ] [ character_posse ] ;

	if ( ! IsPlayerInPosse ( playerid ) || !IsLawEnforcementPosse ( posseid ) ) {

		return SendServerMessage ( playerid, "You have to be in a police posse in order to do this command.", MSG_TYPE_INFO ) ;
	}

	if ( sscanf ( params, "k<u>", targetid ) ) {

		return SendServerMessage ( playerid, "Syntax: /cuff <player>", MSG_TYPE_ERROR ) ;
	}

	GetPlayerPos ( targetid, pos_x, pos_y, pos_z ) ;

	if ( IsPlayerInRangeOfPoint ( playerid, 2.5, pos_x, pos_y, pos_z ) && GetPlayerInterior ( playerid ) == GetPlayerInterior ( targetid ) && GetPlayerVirtualWorld ( playerid ) == GetPlayerVirtualWorld ( targetid ) ) {

		playerCuffed [ targetid ] = !playerCuffed [ targetid ] ; 

		if ( playerCuffed [ targetid ] ) { 
		
			if ( ReturnItemByParam ( playerid, SHERIFF_HANDCUFFS, true ) != -1 ) {
			
				SetPlayerCuffed ( targetid, true ) ; 
				DecreaseItem ( playerid, ReturnItemByParam ( playerid, SHERIFF_HANDCUFFS, true ), 1 ) ;
			}

			else {

				playerCuffed [ targetid ] = false;
				return SendServerMessage ( playerid, "You need handcuffs to handcuff a player!", MSG_TYPE_ERROR ) ;
			}

		}
		else { 

			SetPlayerCuffed ( targetid, false ) ; 

			if ( ! IsPlayerInvFull ( playerid ) ) {

				GivePlayerItemByParam ( playerid, PARAM_UNDEFINED, SHERIFF_HANDCUFFS, 1, 0, SHERIFF_HANDCUFFS, 0 ) ;
			}
		}

		SendServerMessage ( playerid, sprintf("You have successfully %s %s.", ( playerCuffed [ targetid ] ) ? ( "cuffed" ) : ( "uncuffed" ), ReturnUserName ( targetid, false, true ) ), MSG_TYPE_INFO ) ;
		SendServerMessage ( targetid, sprintf("You have been %s by %s.", ( playerCuffed [ targetid ] ) ? ( "cuffed" ) : ( "uncuffed" ), ReturnUserName ( playerid, false, true ) ), MSG_TYPE_INFO ) ;

		ProxDetector ( playerid, 30.0, COLOR_ACTION, sprintf("%s has %s %s.",ReturnUserName ( playerid, false ), ( playerCuffed [ targetid ] ) ? ( "cuffed" ) : ( "uncuffed" ), ReturnUserName ( targetid, false, true ) ) );

	}

	else return SendServerMessage ( playerid, "You are not near that player.", MSG_TYPE_ERROR ) ;

	return true ;
}

CMD:disarm ( playerid, params [] ) {
	// removes weapons from player
	new targetid, Float: pos_x, Float: pos_y, Float: pos_z, posseid = Character [ playerid ] [ character_posse ] ;

	if ( ! IsPlayerInPosse ( playerid ) || !IsLawEnforcementPosse ( posseid )) {

		return SendServerMessage ( playerid, "You have to be in a police posse in order to do this command.", MSG_TYPE_INFO ) ;
	}

	if ( sscanf ( params, "k<u>", targetid ) ) {

		return SendServerMessage ( playerid, "Syntax: /disarm <player>", MSG_TYPE_ERROR ) ;
	}

	GetPlayerPos ( targetid, pos_x, pos_y, pos_z ) ;

	if ( IsPlayerInRangeOfPoint ( playerid, 2.5, pos_x, pos_y, pos_z ) && GetPlayerInterior ( playerid ) == GetPlayerInterior ( targetid ) && GetPlayerVirtualWorld ( playerid ) == GetPlayerVirtualWorld ( targetid ) ) {

		SendServerMessage ( playerid, sprintf ( "You've sent a disarm request to %s.", ReturnUserName ( targetid, false ) ), MSG_TYPE_INFO ) ;

		inline DisarmPlayerRequest(pid, dialogid, response, listitem, string:inputtext[]) {

			#pragma unused inputtext, listitem, dialogid, pid

			if ( ! response ) {

				return false ;
			}			

			RemovePlayerWeapon ( targetid ) ;

			Character [ targetid ] [ character_pantsweapon ] = 0;
			Character [ targetid ] [ character_pantsammo ] = 0;

			Character [ targetid ] [ character_backweapon ] = 0;
			Character [ targetid ] [ character_backammo ] = 0;

			SavePlayerWeapons ( targetid ) ;

			if ( DoesPlayerHaveItem ( playerid, CARD_GUNPERMIT ) != -1 ) {

				DiscardItem ( playerid, DoesPlayerHaveItem ( playerid, CARD_GUNPERMIT ) ) ;
			}

			SendServerMessage ( playerid, sprintf("You have successfully disarmed %s.", ReturnUserName ( targetid, false, true ) ), MSG_TYPE_INFO ) ;
			SendServerMessage ( targetid, sprintf("%s has disarmed you of your weapons and ammo.", ReturnUserName ( playerid, false, true ) ), MSG_TYPE_INFO ) ;

			ProxDetector ( playerid, 30.0, COLOR_ACTION, sprintf("%s has disarmed %s.",ReturnUserName ( playerid, false, true ), ReturnUserName ( targetid, false, true ) ) );

		}

    	Dialog_ShowCallback(targetid, using inline DisarmPlayerRequest, DIALOG_STYLE_MSGBOX, "{C23030}WARNING", sprintf ( "{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\n%s %s is about to disarm you of your weapons.\nThis dialog is meant to prevent abuse of the command but does not mean you can decline if everything's roleplayed properly.\n\nIf %s %s is attempting to abuse this command, file a complaint on the forum and use /report.  If not, click Proceed", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, false ), Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, false ) ), "{C23030}Proceed", "Cancel" ) ; 
	
	}

	else return SendServerMessage ( playerid, "You are not near that player.", MSG_TYPE_ERROR ) ;

	return true ;
}

CMD:clearcharge ( playerid, params [] ) {

	new posseid = Character [ playerid ] [ character_posse ] ;

	if ( ! IsPlayerInPosse ( playerid ) ||  !IsLawEnforcementPosse ( posseid ) ) {

		return SendServerMessage ( playerid, "You have to be in a police posse in order to do this command.", MSG_TYPE_INFO ) ;
	}

	if ( GetPointIDFromType ( playerid, POINT_TYPE_SHERIFF ) == -1 ) {

		return SendServerMessage ( playerid, "You are not in a sheriff's office!", MSG_TYPE_ERROR );
	}

	new targetid, chargeid;

	if ( sscanf ( params, "k<u>i", targetid, chargeid ) ) {

		return SendServerMessage ( playerid, "/clearcharge [playerid] [chargeid]", MSG_TYPE_ERROR ) ;
	}

	new query [ 256 ] ;

	inline CheckPlayerCharge () {

		new rows, fields;
		cache_get_data ( rows, fields, mysql ) ;

		if ( rows ) {

			for ( new i; i < ReturnChargeCount ( targetid ); i++ ) {

				if ( Charge [ targetid ] [ i ] [ charge_id ] == chargeid ) {

					SendServerMessage ( playerid, sprintf("You have successfully cleared %s's charge of $%i.", ReturnUserName ( targetid, false ), Charge [ targetid ] [ i ] [ charge_amount ] ), MSG_TYPE_INFO ) ;

					SendPosseWarning ( posseid, sprintf("%s %s has cleared %s's charge of $%i.", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, false ), ReturnUserName ( targetid, false ), Charge [ targetid ] [ i ] [ charge_amount ] ) ) ;

					TakeCharacterMoney ( targetid, Charge [ targetid ] [ i ] [ charge_amount ], MONEY_SLOT_HAND ) ;

					Posse [ posseid ] [ posse_bank ] += Charge [ targetid ] [ i ] [ charge_amount ] ;
					Posse [ posseid ] [ posse_bank_decimal ] += Charge [ targetid ] [ i ] [ charge_change ] ;

					Charge [ targetid ] [ i ] [ charge_amount ] = 0;
					Charge [ targetid ] [ i ] [ charge_change ] = 0;

					Init_LoadCharges ( targetid ) ;

					mysql_format ( mysql, query, sizeof ( query ), "UPDATE charges SET charge_amount = %d, charge_change = %d WHERE charge_id = %d", Charge [ targetid ] [ i ] [ charge_amount ], Charge [ targetid ] [ i ] [ charge_change], chargeid ) ;
					mysql_tquery ( mysql, query ) ; 

					mysql_format ( mysql, query, sizeof ( query ), "UPDATE posses SET posse_bank = %d, posse_bank_decimal = %d WHERE posse_id = %d", Posse [ posseid ] [ posse_bank ], Posse[posseid][posse_bank_decimal], posseid ) ;
					return mysql_tquery ( mysql, query ) ;
				}

				else continue;
			}

			return SendServerMessage ( playerid, "Something went wrong, take a screenshot and send this to a dev.", MSG_TYPE_ERROR ) ;
		}
		
		else {

			return SendServerMessage ( playerid, "There is no charge present with that charge ID.", MSG_TYPE_ERROR ) ;
		}
	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT charge_amount FROM charges WHERE charge_id = %d AND charge_holder = '%e'", chargeid, ReturnUserName ( targetid, true ) ) ;
	mysql_tquery_inline(mysql, query, using inline CheckPlayerCharge, "");

	return true ;
}

CMD:viewcharges ( playerid, params [] ) {

	new posseid = Character [ playerid ] [ character_posse ] ;

	if ( ! IsPlayerInPosse ( playerid ) ||  !IsLawEnforcementPosse ( posseid )) {

		return SendServerMessage ( playerid, "You have to be in a police posse in order to do this command.", MSG_TYPE_INFO ) ;
	}

	new user[MAX_PLAYER_NAME];

	if ( sscanf ( params, "s["#MAX_PLAYER_NAME"]", user ) ) {

		return SendServerMessage ( playerid, "/viewcharges [player_name]", MSG_TYPE_ERROR ) ;
	}

	if ( GetPointIDFromType ( playerid, POINT_TYPE_SHERIFF ) == -1 ) {

		return SendServerMessage ( playerid, "You are not in a sheriff's office!", MSG_TYPE_ERROR );
	}

	new query [ 128 ], string [ 512 ] ;

	inline charge_PlayerCharges () {

		new rows, fields;

		cache_get_data ( rows, fields, mysql ) ;

		if ( rows ) {

			new cid, cplacer[MAX_PLAYER_NAME], camount, ccents, camounttotal,ccenttotal,cinfo[32];

			for ( new i, j = rows; i < j; i++ ) {
				
				cid = cache_get_field_content_int ( i, "charge_id" ) ;
				cache_get_field_content ( i, "charge_placer", cplacer, mysql, MAX_PLAYER_NAME ) ;
				camount = cache_get_field_content_int ( i, "charge_amount" ) ;
				ccents = cache_get_field_content_int ( i, "charge_change" ) ;
				cache_get_field_content ( i, "charge_info", cinfo, mysql, 32 ) ;

				camounttotal += camount;
				ccenttotal += ccents;
				if(ccenttotal >= 100) {

					camounttotal++;
					ccenttotal = 0;
				}

				strcat ( string, sprintf("Charge ID: %i - Charge Placer: %s - Charge Amount: $%i.%02d - Charge Info: %s\n", cid, cplacer, camount, ccents, cinfo ) ) ;
			}

			strcat ( string, sprintf("\nCombined Charges Total: $%d.%02d",camounttotal,ccenttotal));

			inline PlayerChargeList(pid, dialogid, response, listitem, string:inputtext[]) {

				#pragma unused inputtext, listitem, dialogid, pid, response
			}

			Dialog_ShowCallback(playerid, using inline PlayerChargeList, DIALOG_STYLE_MSGBOX, sprintf("%s's Charges", user ), string, "Exit", "" );
		}

		else {

			return SendServerMessage ( playerid, "There are no current charges for this player or this player doesn't exist.", MSG_TYPE_ERROR ) ;
		}

	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT charge_id, charge_placer, charge_amount, charge_info FROM charges WHERE charge_holder = '%e'", user ) ;
	mysql_tquery_inline ( mysql, query, using inline charge_PlayerCharges, "" ) ;

	return true ;
}

CMD:viewdebt(playerid, params [] ) {
	new posseid = Character [ playerid ] [ character_posse ] ;

	if ( ! IsPlayerInPosse ( playerid ) ||  !IsLawEnforcementPosse ( posseid ) ) {

		return SendServerMessage ( playerid, "You have to be in a police posse in order to do this command.", MSG_TYPE_INFO ) ;
	}

	new targetid ;

	if ( sscanf ( params, "k<u>", targetid ) ) {

		return SendServerMessage ( playerid, "/viewdebt [target]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( targetid ) ) {

		return SendServerMessage ( playerid, "Player isn't online.", MSG_TYPE_ERROR ) ;
	}	

	if ( Character [ targetid ] [ character_bankmoney ] < 0 ) {

		SendServerMessage ( playerid, "Make sure you know their IC name before taking action, or you might get jailed for metagaming.", MSG_TYPE_WARN ) ;
		return SendServerMessage ( playerid, sprintf("(%d) %s owes the government $%s.", targetid, ReturnUserName ( targetid ), IntegerWithDelimiter (Character [ targetid ] [ character_bankmoney ])), MSG_TYPE_WARN ) ;
	}

	else return SendServerMessage ( playerid, sprintf("(%d) %s owes the government nothing.", targetid, ReturnUserName ( targetid )), MSG_TYPE_WARN ) ;
}