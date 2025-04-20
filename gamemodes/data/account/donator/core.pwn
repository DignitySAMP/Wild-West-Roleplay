enum DonatorArray {
	donatorid,
	donatorName [ 32 ]
};

new DonatorRank [] [ DonatorArray ] = {

	{ 0, "None" } ,
	{ 1, "Bronze" } ,
	{ 2, "Silver" },
	{ 3, "Gold" }
} ;

GetDonatorRank ( donorlevel ) {
	new dataform [ 32 ] ;

	strcat(dataform, DonatorRank [ donorlevel ] [ donatorName ], sizeof ( dataform ) ) ;
	
	return dataform ;
}

ReturnDonatorHex ( donorlevel ) {

	new hex [ 16 ] ;

	switch ( donorlevel ) {

		case DONATOR_BRONZE : hex = "{917656}" ;
		case DONATOR_SILVER : hex = "{AEBABD}" ;
		case DONATOR_GOLD : hex = "{DBB053}" ;
	}

	return hex ;
}

CMD:donatorchat ( playerid, params [] ) {

	if ( ! Account [ playerid ] [ account_donatorlevel ] || Account [ playerid ] [ account_stafflevel ] <= STAFF_MODERATOR ) {

		return SendServerMessage ( playerid, "You are not a donator!", MSG_TYPE_ERROR ) ;
	}

	new msg [ 144 ];

	if ( sscanf ( params, "s[144]", msg ) ) {

		return SendServerMessage ( playerid, "/d(onator)c(hat) [message]", MSG_TYPE_ERROR ) ;
	}

	/*

	if ( Account [ playerid ] [ account_stafflevel ] <= STAFF_MODERATOR ) {

		SendSplitMessage ( playerid, COLOR_DONATOR, sprintf("(( [%s%s{B59664} Donator] (%d) %s: %s ))", ReturnDonatorHex ( Account [ playerid ] [ account_donatorlevel ] ), GetDonatorRank ( Account [ playerid ] [ account_donatorlevel ] ), playerid, ReturnUserName ( playerid, false ), msg ) ) ;
	}

	else SendSplitMessage ( playerid, COLOR_DONATOR, sprintf("(( [Moderator] (%d) %s: %s ))", playerid, ReturnUserName ( playerid, false ), msg ) ) ;

	*/

	SendDonationMessage ( msg ) ;

	return true ;
}

SendDonationMessage ( text [] ) {

	foreach ( new playerid: Player ) {

		if ( Account [ playerid ] [ account_donatorlevel ] >= DONATOR_BRONZE || Account [ playerid ] [ account_stafflevel ] <= STAFF_MODERATOR ) {

			if ( Account [ playerid ] [ account_stafflevel ] <= STAFF_MODERATOR ) {

				SendSplitMessage ( playerid, COLOR_DONATOR, sprintf("(( [%s%s{B59664} Donator] (%d) %s: %s ))", ReturnDonatorHex ( Account [ playerid ] [ account_donatorlevel ] ), GetDonatorRank ( Account [ playerid ] [ account_donatorlevel ] ), playerid, ReturnUserName ( playerid, false ), text ) ) ;
				continue ;
			}

			else {
				SendSplitMessage ( playerid, COLOR_DONATOR, sprintf("(( [Moderator] (%d) %s: %s ))", playerid, ReturnUserName ( playerid, false ), text ) ) ;
				continue ;
			}
		}

		else continue ;
	}

}

CMD:customskin ( playerid, params [] ) {



	return true ;
}