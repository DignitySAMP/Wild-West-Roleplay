#define MAX_CHARGES			( 100 )
#define MAX_CHARGES_SHOWN	( 15 )

enum ChargeData {
	charge_id,

	charge_placer [ MAX_PLAYER_NAME ],
	charge_holder [ MAX_PLAYER_NAME ],

	charge_amount,
	charge_change,

	charge_info [ 32 ],
	charge_date [ 32 ]
}

new Charge [ MAX_PLAYERS ] [ MAX_CHARGES ] [ ChargeData ], ChargeCount [ MAX_PLAYERS ] ;

CMD:charge ( playerid, params [] ) { // player, charge
// -- Should be saved in a single db
	new user[MAX_PLAYER_NAME], charge [ 32 ], amount, cents, query [ 256 ], posseid = Character [ playerid ] [ character_posse ] ; 

	if ( ! IsPlayerInPosse ( playerid ) || !IsLawEnforcementPosse ( posseid ) ) {

		return SendServerMessage ( playerid, "You have to be in a police posse in order to do this command.", MSG_TYPE_INFO ) ;
	}

	if ( sscanf ( params, "s["#MAX_PLAYER_NAME"]iis[32]", user, amount, cents, charge ) ) {

		return SendServerMessage ( playerid, "/charge [criminal_name] [dollars] [cents] [charge text]", MSG_TYPE_ERROR ) ;	

	}

	if ( strlen ( charge ) > 32 ) {

		return SendServerMessage ( playerid, "A charge can't have more than 32 characters!", MSG_TYPE_WARN ) ;	
	}

	if ( amount < 0 ) { 

		return SendServerMessage ( playerid, "A charge cannot have negative dollars!", MSG_TYPE_WARN ) ;
	}

	if ( amount > 5000 ) {

		return SendServerMessage ( playerid, "A charge can't be more than $5,000!", MSG_TYPE_WARN ) ;
	}

	inline charge_DoesCharacterExist () {

		new rows, fields;

		cache_get_data ( rows, fields, mysql ) ;

		if ( rows ) {

			mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO charges (charge_placer, charge_holder, charge_amount, charge_change, charge_info, charge_date) VALUES ('%s', '%s', %d, %d, '%s', '%s')",
				ReturnUserName ( playerid, true ), user, amount, cents, charge, ReturnDateTime () ); 
			mysql_tquery ( mysql, query ) ;

			SendPosseWarning ( posseid, sprintf("{[ %s %s has charged %s with '%s' for $%s.%02d.", Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, true ), user, charge, IntegerWithDelimiter ( amount ),cents ) ) ;

			foreach ( new i : Player ) {

				if ( ! strcmp ( Character [ i ] [ character_name ], user ) ) {

					Init_LoadCharges ( i ) ;

					SendServerMessage ( i, sprintf("You've been charged with '%s' for $%s.%02d by %s %s.", charge, IntegerWithDelimiter ( amount ), cents, Character [ playerid ] [ character_posserank ], ReturnUserName ( playerid, false ) ), MSG_TYPE_INFO ) ;
				}

				else continue;
			}

		}

		else {

			return SendServerMessage ( playerid, sprintf("The character '%s' does not exist.", user), MSG_TYPE_ERROR ) ;
		}

	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT character_name FROM characters WHERE character_name = '%e'", user ) ;
	mysql_tquery_inline(mysql, query, using inline charge_DoesCharacterExist, "");	

	return true ;
}

Init_LoadCharges ( playerid ) {
	
	new query [ 256 ] ;

	for ( new i; i < MAX_CHARGES; i++ ) {

		Charge [ playerid ] [ i ] [ charge_id ] = -1;
	}

	ChargeCount [ playerid ] = 0;

	mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM charges WHERE charge_holder = '%e'", ReturnUserName ( playerid, true ) ); 
	return mysql_tquery(mysql, query, "LoadCharges", "i", playerid ) ;
}

forward LoadCharges ( playerid ) ;
public LoadCharges ( playerid ) {
	new rows, fields ;

	cache_get_data ( rows, fields, mysql ) ;

	if ( ! rows ) {
		return true ;
	}

    if ( rows ) {

		new content_parse [ 40 ] ;

		for ( new i, j = rows; i < j; i ++ ) {

			Charge [ playerid] [ i ] [ charge_id ] = cache_get_field_int ( i, "charge_id" ) ;

			cache_get_field_content ( i, "charge_placer", Charge [ playerid ] [ i ] [ charge_placer ], MAX_PLAYER_NAME ) ;
			cache_get_field_content ( i, "charge_holder", Charge [ playerid ] [ i ] [ charge_holder ], MAX_PLAYER_NAME ) ;

			Charge [ playerid ] [ i ] [ charge_amount ] = cache_get_field_content_int ( i, "charge_amount") ;
			Charge [ playerid ] [ i ] [ charge_change ] = cache_get_field_content_int ( i, "charge_change");
			
			cache_get_field_content ( i, "charge_info", Charge [ playerid ] [ i ] [ charge_info ], 32 ) ;
			cache_get_field_content ( i, "charge_date", Charge [ playerid ] [ i ] [ charge_date ], 32 ) ;

			ChargeCount [ playerid ] ++ ;

			content_parse [ 0 ] = EOS ;
		}

		printf("%d charges loaded for (%d) %s", ChargeCount [ playerid ], playerid, ReturnUserName ( playerid, true ) ) ;
	}

	return true ;
}

ReturnChargeCount ( playerid ) {

	return ChargeCount [ playerid ] ;
}