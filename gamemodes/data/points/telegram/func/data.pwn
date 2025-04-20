enum telegramData {

	telegram_id,

	telegram_sender,
	telegram_reciever,

	telegram_message [ 100 ],

	telegram_date [ 64 ]

};

#define MAX_TELEGRAMS (100)

new Telegram [ MAX_PLAYERS ] [ MAX_TELEGRAMS ] [ telegramData ], TelegramCount [ MAX_PLAYERS ] ;

Init_LoadTelegrams ( playerid ) {

	new query [ 128 ] ;

	for ( new i; i < MAX_TELEGRAMS ; i ++ ) {

		Telegram [ playerid ] [ i ] [ telegram_id ] = -1 ;
	}

	mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM telegrams WHERE telegram_reciever = %d ORDER BY telegram_id DESC", Character [ playerid ] [ character_telegram_id ] ) ;
	return mysql_tquery ( mysql, query, "LoadTelegrams", "d", playerid ) ;
}

forward LoadTelegrams ( playerid ) ;
public LoadTelegrams ( playerid ) {

	new rows, fields; 

	cache_get_data ( rows, fields, mysql ) ;

	if ( rows ) {

		for ( new i, j = rows; i < j ; i ++ ) {

			/*
			new id = cache_get_field_int ( i, "telegram_id" ) ;

			if ( id == -1 ) {

				continue ;
			}
			*/

			Telegram [ playerid ] [ i ] [ telegram_id ] = cache_get_field_int ( i, "telegram_id" ) ;

			Telegram [ playerid ] [ i ] [ telegram_sender ] = cache_get_field_int ( i, "telegram_sender" ) ;
			Telegram [ playerid ] [ i ] [ telegram_reciever ] = cache_get_field_int ( i, "telegram_reciever" ) ;

			cache_get_field_content(i, "telegram_message", Telegram [ playerid ] [ i ] [ telegram_message ] , mysql, 100 ) ;

			cache_get_field_content(i, "telegram_date", Telegram [ playerid ] [ i ] [ telegram_date ] , mysql, 64 ) ;

			printf ("* Loaded telegram id %d for playerid %d.", Telegram [ playerid ] [ i ] [ telegram_id ], playerid ) ;

			TelegramCount [ playerid ] ++ ;
		}
	}

	return true ;
}

timer RecieveTelegramMessage[300000](playerid) {

	if ( IsPlayerConnected ( playerid ) ) {

		SendServerMessage ( playerid, "You have recieved a telegram!", MSG_TYPE_INFO ) ;
	}
}