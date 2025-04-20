#define MAX_LOTTERY_AMOUNT (50000)
#define LOTTERY_TICK_TIMER (3600000)

enum LotteryData {

	lottery_amount
};

new Lottery[LotteryData];

new bool: LotteryWinner [ MAX_PLAYERS ];

////////////////////////////////////////////

Init_LoadLottery ( ) {

	Lottery [ lottery_amount ] = 0;

	return mysql_tquery ( mysql, "SELECT * FROM lottery", "LoadLotteryData" ) ;
}

forward LoadLotteryData (  ) ;
public LoadLotteryData (  ) {
	new rows, fields ;

	cache_get_data ( rows, fields, mysql ) ;

	if ( ! rows ) {

		mysql_tquery ( mysql, "INSERT INTO lottery (lottery_amount) VALUES (100)" ) ;
		return Init_LoadLottery ( ) ;
	}

    if ( rows ) {

		Lottery [ lottery_amount ] = cache_get_field_int ( 0, "lottery_amount" ) ;

		printf ( "* Loaded Lottery (%d)", Lottery [ lottery_amount ] ) ;
	}

	return true ;
}

////////////////////////////////////////////

ReturnPotAmount () {

	return Lottery [ lottery_amount ];
}

AddToLotteryPot ( amount ) {

	new query [ 128 ];

	if ( Lottery [ lottery_amount ] + amount >= MAX_LOTTERY_AMOUNT ) { return false ; }

	Lottery [ lottery_amount ] += amount;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE lottery SET lottery_amount = %d", Lottery [ lottery_amount ] ) ;
	return mysql_tquery ( mysql, query ) ;
}

SetLotteryWinner ( playerid, bool: option ) {

	LotteryWinner [ playerid ] = option;
}