/*
	2 sec = 1 min
	12 min = 1 hour
	1 day = 288 min
	

*/
new serverMin,
	serverHour,
	serverDay,
	serverMonth,
	serverYear ;

#define MAX_MONTH_NAME          ( 10 )
enum monthData {
	month_name [ MAX_MONTH_NAME ],
	month_days
} ;

new monthArray [] [monthData] = {
	{ "January", 31 } ,
	{ "February", 28 } ,
	{ "March", 31 } ,
	{ "April", 30 } ,
	{ "May", 31 } ,
	{ "June", 30 } ,
	{ "July", 31 } ,
	{ "August", 31 } ,
	{ "September", 30 } ,
	{ "October", 31 } ,
	{ "November", 30 } ,
	{ "December", 31 }
} ;

enum {
	MONTH_JANUARY, MONTH_FEBRUARY, MONTH_MARCH,
	MONTH_APRIL, MONTH_MAY, MONTH_JUNE, MONTH_JULY,
	MONTH_AUGUST, MONTH_SEPTEMBER, MONTH_OCTOBER,
	MONTH_NOVEMBER, MONTH_DECEMBER
} ;

date_getMonth ( monthid ) {

	new monthName [ MAX_MONTH_NAME ] ;

	format ( monthName, MAX_MONTH_NAME, "%s",
	monthArray [ monthid ] [ month_name ] );

	return monthName ;
}

#define SEASON_SPRING   ( 0 )
#define SEASON_SUMMER   ( 1 )
#define SEASON_AUTUMN   ( 2 )
#define SEASON_WINTER   ( 3 )

date_getSeasonID ( monthid ) {
	switch ( monthid ) {
	    case MONTH_MARCH, MONTH_APRIL, MONTH_MAY: {
	        return SEASON_SPRING ;
	    }
	
	    case MONTH_JUNE, MONTH_JULY, MONTH_AUGUST: {
	        return SEASON_SUMMER ;
	    }
	
	    case MONTH_SEPTEMBER, MONTH_OCTOBER, MONTH_NOVEMBER: {
	        return SEASON_AUTUMN ;
	    }
	
	    case MONTH_DECEMBER, MONTH_JANUARY, MONTH_FEBRUARY : {
	        return SEASON_WINTER ;
	    }
	}

	return SEASON_SPRING ;
}

#define MAX_SEASON_NAME     ( 7 )
date_getSeason ( monthid ) {

	new seasonid = date_getSeasonID ( monthid ) ,
	seasonName [ MAX_SEASON_NAME ];

	switch ( seasonid ) {
	    case SEASON_SPRING: {
			format ( seasonName, MAX_SEASON_NAME, "Spring" ) ;
	    }
	    
	    case SEASON_SUMMER: {
			format ( seasonName, MAX_SEASON_NAME, "Summer" ) ;
	    }
	    
	    case SEASON_AUTUMN: {
			format ( seasonName, MAX_SEASON_NAME, "Autumn" ) ;
	    }
	    
	    case SEASON_WINTER: {
			format ( seasonName, MAX_SEASON_NAME, "Winter" ) ;
	    }
	}

	return seasonName ;
}

date_dayName ( day, month, year ) {
	new weekday_str[10], j, e;

	j = year % 100;
	e = year / 100;

	switch ((day + (month+1)*26/10 + j + j/4 + e/4 - 2*e) % 7) {
		case 0: weekday_str = "Saturday";
		case 1: weekday_str = "Sunday";
		case 2: weekday_str = "Monday";
		case 3: weekday_str = "Tuesday";
		case 4: weekday_str = "Wednesday";
		case 5: weekday_str = "Thursday";
		case 6: weekday_str = "Friday";
	}
	
	return weekday_str;
}

date_dayOrdinal ( number ) {
	number = number < 0 ? -number : number;
	new _ordinal[][] = { "th", "st", "nd", "rd" };
	return _ordinal[(3 < number % 100 < 21)?(0):((number % 10 > 3)?(0):(number % 10))];
}

ReturnServerTime () {

	new string [ 64 ] ;
	format ( string, sizeof ( string ), "%02i/%02i/%i - %02i:%02i", serverDay, serverMonth+1, serverYear, serverHour, serverMin ) ;
	return string ;
}

#define SERVER_HOUR_TICK        	( 60 )
#define SERVER_DAY_TICK        		( 24 )
#define SERVER_YEAR_TICK           	( 12 ) // Month Tick = monthArray

#define SERVER_TIME_INCREMENT       ( 30000 )

task AdvanceTime[SERVER_TIME_INCREMENT]() {
	
	Init_ServerTime () ;

	new query [ 256 ] ;

	printf("%s, %d%s of %s, %d, %d:%d [%s]",
	date_dayName ( serverDay, serverMonth, serverYear ), serverDay, date_dayOrdinal ( serverDay ),
	date_getMonth ( serverMonth ), serverYear, serverHour, serverMin, date_getSeason ( serverMonth ) ) ;
	
	if ( ++ serverMin == SERVER_HOUR_TICK ) {
		if ( ++ serverHour == SERVER_DAY_TICK ) {
			if ( ++ serverDay == monthArray [ serverMonth ] [ month_days ] + 1 ) {
			    serverDay = 1 ;

				// -1 on server year tick to accomodate for array ids
				if ( serverMonth ++ >= SERVER_YEAR_TICK - 1) {
				    serverMonth = 0 ;
				    serverYear ++ ;
				}
			}
			
			foreach (new playerid: Player) {
				UpdateGUI ( playerid ) ;
			}

			serverHour = 0 ;
		}

	    serverMin = 0 ;
	}

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE servertime SET serverMin = %d, serverHour = %d, serverDay = %d, serverMonth = %d, serverYear = %d", serverMin, serverHour, serverDay, serverMonth, serverYear ) ;
	mysql_tquery ( mysql, query ) ;

	SetWorldTime(serverHour);

	return true ;
}

Init_ServerTime () {

	return mysql_tquery ( mysql, "SELECT * FROM servertime", "LoadServerTime" ) ;
}

forward LoadServerTime () ;
public LoadServerTime () {

	new rows, fields;

	cache_get_data ( rows, fields, mysql ) ;

	if ( ! rows ) {
	
		mysql_tquery ( mysql, "INSERT INTO servertime (serverMin, serverHour, serverDay, serverMonth, serverYear) VALUES (30, 9, 1, 1, 1850)" ) ;
		return Init_ServerTime ( ) ;
	}

	else if ( rows ) {

		serverMin = cache_get_field_content_int ( 0, "serverMin" ) ;
		serverHour = cache_get_field_content_int ( 0, "serverHour" ) ;
		serverDay = cache_get_field_content_int ( 0, "serverDay" ) ;
		serverMonth = cache_get_field_content_int ( 0, "serverMonth" ) ;
		serverYear = cache_get_field_content_int ( 0, "serverYear" ) ;
	}

	return true ;
}