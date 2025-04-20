/*
	Use AVG from MySQL to get the average play time of a player using /playtime.
*/

enum SESSION_DATA {

	E_SESSION_ID,
	E_SESSION_ACC,
	E_SESSION_TIME,
	E_SESSION_IDLE

} ;

new Session [ MAX_PLAYERS ] [ SESSION_DATA ] ;

ptask SessionHandler[60000](playerid) {

	Session [ playerid ] [ E_SESSION_TIME ] ++ ;
	return SaveSessionData ( playerid ) ;
}

ptask SessionHandler_Paused[60000](playerid) {

	if ( IsPlayerPaused ( playerid )) {

		Session [ playerid ] [ E_SESSION_IDLE ] ++ ;
		return SaveSessionData ( playerid ) ;
	}

	else return true ;
}

SaveSessionData ( playerid ) {

	new query [ 512 ] ;

	if ( ! Session [ playerid ] [ E_SESSION_ID ] ) {

	    inline OnSessionDataReceived() {
	     
	    	Session [ playerid ] [ E_SESSION_ID ] = cache_insert_id() ;
	    	printf(" [SESSION] Created session table for (%d) %s with table ID %d.", playerid, ReturnUserName ( playerid, true ), Session [ playerid ] [ E_SESSION_ID ] ) ;
	    }

		mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO sessions (e_session_acc, e_session_time, e_session_idle) VALUES (%d, %d, %d)", 
		Account [ playerid ] [ account_id ], Session [ playerid ] [ E_SESSION_TIME ], Session [ playerid ] [ E_SESSION_IDLE ] ) ;

	    mysql_tquery_inline(mysql, query, using inline OnSessionDataReceived, "" );
	}

	else if ( Session [ playerid ] [ E_SESSION_ID ] ) {

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE sessions SET e_session_time = %d, e_session_idle = %d WHERE e_session_acc = %d AND e_session_id = %d", 
			Session [ playerid ] [ E_SESSION_TIME ], Session [ playerid ] [ E_SESSION_IDLE ], Account [ playerid ] [ account_id ], Session [ playerid ] [ E_SESSION_ID ] ) ;

		mysql_tquery ( mysql, query );
	}

	return false ;
}

public OnPlayerConnect(playerid) {

	new session_clear [ SESSION_DATA ] ;
	Session [ playerid ] = session_clear ;

	#if defined ss_OnPlayerConnect
		return ss_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect ss_OnPlayerConnect
#if defined ss_OnPlayerConnect
	forward ss_OnPlayerConnect(playerid);
#endif