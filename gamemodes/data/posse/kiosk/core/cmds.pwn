new IsCreatingKiosk [ MAX_PLAYERS ], bool: sheriffDuty [ MAX_PLAYERS ] ;

public OnPlayerEditDynamicObject ( playerid, objectid, response, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz )
{
	new posseid = Character [ playerid ] [ character_posse ], Float: oldX, Float: oldY, Float: oldZ, Float: oldRotX, Float: oldRotY, Float: oldRotZ ;
	if(posseid == -1) { return false; }
	GetDynamicObjectPos ( objectid, oldX, oldY, oldZ ) ;
	GetDynamicObjectRot ( objectid, oldRotX, oldRotY, oldRotZ ) ;
	if ( PosseKiosk [ posseid ] [ kiosk_object ] == objectid ) { 

		if ( response == EDIT_RESPONSE_FINAL ) {

			new query [ 256 ];

			if ( PosseKiosk [ posseid ] [ kiosk_id ] == -1 ) {

				mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO possekiosk (kiosk_id, kiosk_x, kiosk_y, kiosk_z, kiosk_rx, kiosk_ry, kiosk_rz) VALUES (%d,'%f','%f','%f','%f','%f','%f')", posseid, x, y, z, rx, ry, rz ) ;
				mysql_tquery ( mysql, query ) ; 
			}

			else {

				mysql_format ( mysql, query, sizeof ( query ), "UPDATE possekiosk SET kiosk_x = '%f', kiosk_y = '%f', kiosk_z = '%f', kiosk_rx = '%f', kiosk_ry = '%f', kiosk_rz = '%f' WHERE kiosk_id = %d", x, y, z, rx, ry, rz, PosseKiosk [ posseid ] [ kiosk_id ] ) ;
				mysql_tquery ( mysql, query ) ;
			}

			Init_LoadKiosks ( ) ;
		}

		else if ( response == EDIT_RESPONSE_CANCEL ) {

			if ( IsCreatingKiosk [ playerid ] && IsValidDynamicObject ( objectid ) )  {

			 	DestroyDynamicObject ( objectid ) ; 
			}

			else {

				SetDynamicObjectPos ( objectid, oldX, oldY, oldZ ) ;
				SetDynamicObjectRot ( objectid, oldRotX, oldRotY, oldRotZ ) ;
			}
		}

		if ( IsCreatingKiosk [ playerid ] ) { 
			
			IsCreatingKiosk [ playerid ] = 0; 
			SendPosseWarning ( posseid, sprintf("{[ %s %s has created the posse kiosk. ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, false ) ) ) ;
		}
	}
	#if defined kcmds_OnPlayerEditDynamicObject 
		return kcmds_OnPlayerEditDynamicObject ( playerid, objectid, response, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEditDynamicObject 
	#undef OnPlayerEditDynamicObject 
#else
	#define _ALS_OnPlayerEditDynamicObject 
#endif

#define OnPlayerEditDynamicObject  kcmds_OnPlayerEditDynamicObject 
#if defined kcmds_OnPlayerEditDynamicObject 
	forward kcmds_OnPlayerEditDynamicObject ( playerid, objectid, response, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz );
#endif

IsSheriffOnDuty(playerid) { return sheriffDuty[playerid]; }

CMD:possekiosk ( playerid, params [] ) {
	new option [ 16 ], query [ 256 ], posseid = Character [ playerid ] [ character_posse ] ;

	if ( ! IsPlayerInPosse ( playerid ) ) {

		return SendServerMessage ( playerid, "You're not in a posse.", MSG_TYPE_INFO ) ;
	}

	if ( sscanf ( params, "s[16]", option ) ) {

		if ( IsLawEnforcementPosse ( posseid ) ) {

			return SendServerMessage ( playerid, "/p(osse)kiosk [create, edit, delete, take, place, lock, duty]", MSG_TYPE_ERROR ) ;
		}

		else return SendServerMessage ( playerid, "/p(osse)kiosk [create, edit, delete, take, place, lock]", MSG_TYPE_ERROR ) ;
	}

	if ( !strcmp ( option, "create" ) ) { 

		if ( Character [ playerid ] [ character_possetier ] < 3 ) {

			return SendServerMessage ( playerid, "You lack the correct privileges to perform this action.", MSG_TYPE_WARN ) ;	
		}

		if ( IsValidDynamicObject ( PosseKiosk [ posseid ] [ kiosk_object ] ) ) {

			return SendServerMessage ( playerid, "You've already created a kiosk for your faction, use /p(osse)kiosk edit instead.", MSG_TYPE_ERROR ) ;
		}

		new Float: pos_x, Float: pos_y, Float: pos_z;

		GetPlayerPos ( playerid, pos_x, pos_y, pos_z ) ;

		PosseKiosk [ posseid ] [ kiosk_object ] = CreateDynamicObject ( 18885, pos_x+2.5, pos_y+2.5, pos_z, 0.0, 0.0, 0.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), -1 ) ;

		IsCreatingKiosk [ playerid ] = 1;

		EditDynamicObject ( playerid, PosseKiosk [ posseid ] [ kiosk_object ] ) ;
	}

	else if ( !strcmp ( option, "edit" ) ) { 

		if ( ! IsPlayerInRangeOfPoint ( playerid, 3.5, PosseKiosk [ posseid ] [ kiosk_x ], PosseKiosk [ posseid ] [ kiosk_y ], PosseKiosk [ posseid ] [ kiosk_z ] ) ) {

			return SendServerMessage ( playerid, "You're not at your posse's kiosk.", MSG_TYPE_INFO ) ;
		}

		if ( Character [ playerid ] [ character_possetier ] < 3 ) {

			return SendServerMessage ( playerid, "You lack the correct privileges to perform this action.", MSG_TYPE_WARN ) ;	
		}

		EditDynamicObject ( playerid, PosseKiosk [ posseid ] [ kiosk_object ] ) ;
	}

	else if ( !strcmp ( option, "delete" ) ) {

		if ( ! IsPlayerInRangeOfPoint ( playerid, 3.5, PosseKiosk [ posseid ] [ kiosk_x ], PosseKiosk [ posseid ] [ kiosk_y ], PosseKiosk [ posseid ] [ kiosk_z ] ) ) {

			return SendServerMessage ( playerid, "You're not at your posse's kiosk.", MSG_TYPE_INFO ) ;
		}

		if ( Character [ playerid ] [ character_possetier ] < 3 ) {

			return SendServerMessage ( playerid, "You lack the correct privileges to perform this action.", MSG_TYPE_WARN ) ;	
		}

		if ( ! IsValidDynamicObject ( PosseKiosk [ posseid ] [ kiosk_object ] ) ) {

			return SendServerMessage ( playerid, "You haven't created a kiosk yet, use /p(osse)kiosk create instead.", MSG_TYPE_WARN ) ;
		}

		DestroyDynamicObject ( PosseKiosk [ posseid ] [ kiosk_object ] ) ;

		PosseKiosk [ posseid ] [ kiosk_x ] = 0.0;
		PosseKiosk [ posseid ] [ kiosk_y ] = 0.0;
		PosseKiosk [ posseid ] [ kiosk_z ] = 0.0;
		PosseKiosk [ posseid ] [ kiosk_rx ] = 0.0;
		PosseKiosk [ posseid ] [ kiosk_ry ] = 0.0;
		PosseKiosk [ posseid ] [ kiosk_rz ] = 0.0;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE possekiosk SET kiosk_x = '%f', kiosk_y = '%f', kiosk_z = '%f', kiosk_rx = '%f', kiosk_ry = '%f', kiosk_rz = '%f' WHERE kiosk_id = %d", 
			PosseKiosk [ posseid ] [ kiosk_x ], PosseKiosk [ posseid ] [ kiosk_y ], PosseKiosk [ posseid ] [ kiosk_z ], PosseKiosk [ posseid ] [ kiosk_rx ], PosseKiosk [ posseid ] [ kiosk_ry ], PosseKiosk [ posseid ] [ kiosk_rz ], PosseKiosk [ posseid ] [ kiosk_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		Init_LoadKiosks ( ) ;

		SendPosseWarning ( posseid, sprintf("{[ %s %s has deleted the posse kiosk. ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, false ) ) ) ;
	}

	else if ( !strcmp ( option, "take" ) ) {

		if ( ! IsPlayerInRangeOfPoint ( playerid, 3.5, PosseKiosk [ posseid ] [ kiosk_x ], PosseKiosk [ posseid ] [ kiosk_y ], PosseKiosk [ posseid ] [ kiosk_z ] ) ) {

			return SendServerMessage ( playerid, "You're not at your posse's kiosk.", MSG_TYPE_INFO ) ;
		}

		new string[128] ;

		if ( PosseKiosk [ posseid ] [ kiosk_locked ] ) {

			return SendServerMessage ( playerid, "The posse's kiosk is locked.", MSG_TYPE_ERROR ) ;
		}

		for ( new i = 0; i < sizeof ( KioskData ) ; i ++) {

			strcat ( string, sprintf ( "%s - $%i\n", KioskData [ i ] [ kiosk_gunname], KioskData [ i ] [ kiosk_price ] ) ) ;
		}

		inline PosseKioskMenu(pid, dialogid, response, listitem, string:inputtext[]) {

			#pragma unused inputtext, dialogid, pid

			if ( ! response ) {

				return false ;
			}

			if ( Posse [ posseid ] [ posse_bank ] < KioskData [ listitem ] [ kiosk_price ] ) {

				return SendServerMessage ( playerid, sprintf ( "The posse's bank doesn't have enough money to buy a %s.", KioskData [ listitem ] [ kiosk_gunname ] ), MSG_TYPE_ERROR ) ;
			}

			Posse [ posseid ] [ posse_bank ] -= KioskData [ listitem ] [ kiosk_price ] ;
			wep_GivePlayerWeapon ( playerid, KioskData [ listitem ] [ kiosk_gunid ], 0 ) ;
			GivePlayerItemByParam ( playerid, PARAM_AMMO, KioskData [ listitem ] [ kiosk_ammo ], 2, 0, KioskData [ listitem ] [ kiosk_ammo ], 0 ) ;

			SendPosseWarning ( posseid, sprintf("{[ %s (%d) has bought a %s from the posse's kiosk for $%s. ]}", ReturnUserName ( playerid, true ), playerid, KioskData [ listitem ] [ kiosk_gunname ], IntegerWithDelimiter( KioskData [ listitem ] [ kiosk_price ] ) ) ) ;

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE posses SET posse_bank = '%d' WHERE posse_id = %d", Posse [ posseid ] [ posse_bank ], Posse [ posseid ] [ posse_id ] ) ;
			mysql_tquery ( mysql, query ) ; 

			WriteLog ( playerid, "guns/kiosk", sprintf("{[ %s (%d) has bought a %s from the posse's kiosk for $%s. ]}", ReturnUserName ( playerid, true ), playerid, KioskData [ listitem ] [ kiosk_gunname ], IntegerWithDelimiter( KioskData [ listitem ] [ kiosk_price ] ) ) ) ;
		}

		Dialog_ShowCallback(playerid, using inline PosseKioskMenu, DIALOG_STYLE_LIST, "Kiosk List", string, "Buy", "Cancel" ) ;
	}

	else if ( !strcmp ( option, "place" ) ) {

		if ( ! IsPlayerInRangeOfPoint ( playerid, 3.5, PosseKiosk [ posseid ] [ kiosk_x ], PosseKiosk [ posseid ] [ kiosk_y ], PosseKiosk [ posseid ] [ kiosk_z ] ) ) {

			return SendServerMessage ( playerid, "You're not at your posse's kiosk.", MSG_TYPE_INFO ) ;
		}

		new refund, gun;
		
		switch ( Character [ playerid ] [ character_handweapon ] ) {

			case 24: { gun = 0; }
			case 25: { gun = 1; }
			case 33: { gun = 2; }
			default: return SendServerMessage ( playerid, "You don't have a valid kiosk weapon in your hands.", MSG_TYPE_ERROR ) ;
		}

		refund = KioskData [ gun ] [ kiosk_price ] / 2;

		Posse [ posseid ] [ posse_bank ] += refund ;
		RemovePlayerWeapon ( playerid ); 
		SavePlayerWeapons ( playerid ) ;

		for ( new i; i < ReturnPlayerItemCount [ playerid ]; i ++ ) {

		    if ( ReturnItemParam ( playerid, PlayerItem [ playerid ] [ i ] [ player_item_id ], true ) ==  KioskData [ gun ] [ kiosk_ammo ] ) {

		        DiscardItem ( playerid, i ) ;
		   
		    }

		    else continue ;

		}

		SendPosseMessage ( posseid, sprintf("{[ %s (%d) has returned a %s to the posse's kiosk for $%s. ]}", ReturnUserName ( playerid, true ), playerid, KioskData [ gun ] [ kiosk_gunname ], IntegerWithDelimiter( refund ) ) ) ;
		WriteLog ( playerid, "guns/kiosk", sprintf("{[ %s (%d) has returned a %s to the posse's kiosk for $%s. ]}", ReturnUserName ( playerid, true ), playerid, KioskData [ gun ] [ kiosk_gunname ], IntegerWithDelimiter( refund ) ) ) ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE posses SET posse_bank = '%d' WHERE posse_id = %d", Posse [ posseid ] [ posse_bank ], Posse [ posseid ] [ posse_id ] ) ;
		mysql_tquery ( mysql, query ) ;

	}

	else if ( !strcmp ( option, "lock" ) ) {

		if ( Character [ playerid ] [ character_possetier ] < 3 ) {

			return SendServerMessage ( playerid, "You lack the correct privileges to perform this action.", MSG_TYPE_WARN ) ;	
		}

		if ( ! IsPlayerInRangeOfPoint ( playerid, 3.5, PosseKiosk [ posseid ] [ kiosk_x ], PosseKiosk [ posseid ] [ kiosk_y ], PosseKiosk [ posseid ] [ kiosk_z ] ) ) {

			return SendServerMessage ( playerid, "You're not at your posse's kiosk.", MSG_TYPE_INFO ) ;
		}

		switch ( PosseKiosk [ posseid ] [ kiosk_locked ] ) {

			case 0: {

				PosseKiosk [ posseid ] [ kiosk_locked ] = 1;
			}
			case 1: {

				PosseKiosk [ posseid ] [ kiosk_locked ] = 0;
			}
		}

		return SendServerMessage ( playerid, sprintf ( "You have %s the kiosk.", (PosseKiosk [ posseid ] [ kiosk_locked ] ) ? ( "locked" ) : ( "unlocked" ) ), MSG_TYPE_INFO ) ;
	}

	else if ( !strcmp ( option, "duty" ) ) {

		if ( ! IsLawEnforcementPosse ( posseid ) ) {

			return SendServerMessage ( playerid, "You have to be in a police posse in order to do this command.", MSG_TYPE_INFO ) ;
		}

		if ( ! IsPlayerInRangeOfPoint ( playerid, 3.5, PosseKiosk [ posseid ] [ kiosk_x ], PosseKiosk [ posseid ] [ kiosk_y ], PosseKiosk [ posseid ] [ kiosk_z ] ) ) {

			return SendServerMessage ( playerid, "You're not at your posse's kiosk.", MSG_TYPE_INFO ) ;
		}

		switch ( sheriffDuty [ playerid ] ) {

			case false: {


				if ( Posse [ posseid ] [ posse_type ] == 1 ) {
					if ( Character [ playerid ] [ character_possetier ] == 3 ) { 
						
						if ( ! Character [ playerid ] [ character_gender ] ) SetPlayerSkin ( playerid, 288 ) ; 
						else SetPlayerSkin ( playerid, 309 ) ;

					}

					else { 

						if ( ! Character [ playerid ] [ character_gender ] ) SetPlayerSkin ( playerid, 311 ) ;
						else SetPlayerSkin ( playerid, 309 ) ;
					}
				}

				else if ( Posse [ posseid ] [ posse_type ] == 2 ) {
					if ( Character [ playerid ] [ character_possetier ] == 3 ) { 
						
						if ( ! Character [ playerid ] [ character_gender ] ) SetPlayerSkin ( playerid, 147 ) ; 
						else SetPlayerSkin ( playerid, 150 ) ;

					}

					else { 

						if ( ! Character [ playerid ] [ character_gender ] ) SetPlayerSkin ( playerid, 295 ) ;
						else SetPlayerSkin ( playerid, 194 ) ;
					}
				}

				GivePlayerItemByParam ( playerid, PARAM_UNDEFINED, SHERIFF_HANDCUFFS, 4, 0, SHERIFF_HANDCUFFS, 0 ) ;
				GivePlayerItemByParam ( playerid, PARAM_UNDEFINED, RADIO, 1, PARAM_UNDEFINED, RADIO, 0 ) ;
				GivePlayerItemByParam(playerid, PARAM_UNDEFINED, SHERIFF_LASSO, 1, 0, 0, 0);

				switch ( Posse [ posseid ] [ posse_type ] ) {

					case 1: GivePlayerItemByParam ( playerid, PARAM_UNDEFINED, SHERIFF_BADGE, 1, 0, SHERIFF_BADGE, 0 ) ;
					case 2: GivePlayerItemByParam ( playerid, PARAM_UNDEFINED, FEDERAL_BADGE, 1, 0, FEDERAL_BADGE, 0 ) ;
				}

				//Init_LoadPlayerItems ( playerid ) ;

				HideInventoryExamineGUI ( playerid ) ;
    			ToggleInventory ( playerid, INV_MAX_TILES, false ) ;

			}

			case true: {

				SetPlayerSkin ( playerid, Character [ playerid ] [ character_skin ] ) ;

				if ( ReturnItemByParam ( playerid, RADIO, true ) != -1 ) {

					DiscardItem ( playerid, ReturnItemByParam ( playerid, RADIO, true ) ) ;
				}

				if ( ReturnItemByParam ( playerid, SHERIFF_HANDCUFFS, true ) != -1 ) {

					DiscardItem ( playerid, ReturnItemByParam ( playerid, SHERIFF_HANDCUFFS, true ) ) ;
				}

				if ( ReturnItemByParam ( playerid, SHERIFF_LASSO, true ) != -1 ) {

					DiscardItem ( playerid, ReturnItemByParam(playerid,SHERIFF_LASSO,true));
				}

				if ( ReturnItemByParam ( playerid, SHERIFF_BADGE, true ) != -1 ) {

					DiscardItem ( playerid, ReturnItemByParam ( playerid, SHERIFF_BADGE, true )) ;
				}

				if ( ReturnItemByParam ( playerid, FEDERAL_BADGE, true ) != -1 ) {

					DiscardItem ( playerid, ReturnItemByParam ( playerid, FEDERAL_BADGE, true )) ;
				}

				//Init_LoadPlayerItems ( playerid ) ;

				HideInventoryExamineGUI ( playerid ) ;
    			ToggleInventory ( playerid, INV_MAX_TILES, false ) ;

			}
		}

		sheriffDuty [ playerid ] = !sheriffDuty [ playerid ] ;

		SendPosseMessage ( posseid, sprintf("{[ %s %s has went %s duty. ]}", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, false ), ( sheriffDuty [ playerid ] ) ? ( "on" ) : ( "off" ) ) );

	}

	else {

		if (  IsLawEnforcementPosse ( posseid ) ) {

			return SendServerMessage ( playerid, "/p(osse)kiosk [create, edit, delete, take, place, lock, duty]", MSG_TYPE_ERROR ) ;
		}

		else return SendServerMessage ( playerid, "/p(osse)kiosk [create, edit, delete, take, place, lock]", MSG_TYPE_ERROR ) ;
	}

	return true ;
}

CMD:pkiosk ( playerid, params [] ) return cmd_possekiosk ( playerid, params ) ;