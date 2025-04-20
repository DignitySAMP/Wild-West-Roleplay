#if defined _inc_rev
	#undef _inc_rev
#endif


enum {

	REVISION_TYPE_ADDITION,
	REVISION_TYPE_REMOVAL,
	REVISION_TYPE_CHANGE,
	REVISION_TYPE_HOTFIX,

} ;

enum RevisionData {

	revision_desc [ 256 ],
	revision_type,
	revision_date // use unix
} ;

new RevisionList [ ] [ RevisionData ] = {

	{ "Farming system: you can buy the necessities at the general store and blacksmith", 					REVISION_TYPE_ADDITION, 1548331200 },
	{ "Trap system:  you can buy a trap at the blacksmith and use it to catch animals. (and humans)", 		REVISION_TYPE_ADDITION, 1548331202 },
	{ "Bayside has been changed! It's now a snowy mountain!", 												REVISION_TYPE_CHANGE, 	1548862920 },
	{ "Las Barrancas and EQ have been overhauled", 															REVISION_TYPE_CHANGE, 	1548862922 },
	{ "Fixed /levelup (no capitalised letters needed)", 													REVISION_TYPE_HOTFIX, 	1549022400 },
	{ "Fixed job GUI & overhauled textdraw backend", 														REVISION_TYPE_HOTFIX, 	1549022402 },
	{ "Fixed proximity message when a player disconnects (nearby players are alerted)", 					REVISION_TYPE_HOTFIX, 	1549023300 },
	{ "Merged M-RP's updated inventory module. The inventory should now be more smooth in general.", 		REVISION_TYPE_CHANGE, 	1549110600 }
} ;

CMD:updates ( playerid ) {

	new update_list [ sizeof ( RevisionList ) ], string [ 1024 ], revision_index, latest_update_unix ;

	for ( new i; i < sizeof ( RevisionList ) ; i ++ ) {

		if ( RevisionList [ i ] [ revision_date ] > latest_update_unix ) {

			latest_update_unix = RevisionList [ i ] [ revision_date ] ;
		}

		else continue ;
	}

	format ( string, sizeof ( string ), "{DEDEDE}Here are the latest changes for the most recent audit (# %d), rolled out on %s.\n", 
		sizeof ( RevisionList), GetDateForUnix ( latest_update_unix ) ) ;

	for ( new i; i < sizeof ( RevisionList ); i ++ ) {

		update_list [ i ] = RevisionList [ i ] [ revision_date ]  ;
	}

	for ( new i = ( sizeof ( RevisionList ) - 1 ), j, temp; i != 0; i --) {

		for ( j = 0; j < i; j ++ ) {

			if ( update_list [ i ] < update_list [ j ] ) {

				temp = update_list [ i ] ;

				update_list [ i ] = update_list [ j ] ;
				update_list [ j ] = temp;
			}
		}
	}

	for ( new i = sizeof ( update_list ) - 5; i < sizeof ( update_list ); i ++ ) {

		revision_index = GetRevisionIndexByUnix ( update_list [ i ] ) ;

		if ( revision_index == -1 ) {

			continue ;
		}

		format ( string, sizeof ( string ), "%s\n \t %s (%s) \n \t    {FFFFFF}%s{DEDEDE}\n", string,
			GetRevisionType ( update_list [ i ], revision_index ), GetDuration ( gettime() - update_list [ i ] ),
			RevisionList [ revision_index ] [ revision_desc ]
			
		) ;
	}

	ShowPlayerDialog(playerid, 1337, DIALOG_STYLE_MSGBOX, "Updates", string, "yes", "no");

	return true ;
}

GetRevisionIndexByUnix ( unix ) {

	for ( new i; i < sizeof ( RevisionList ); i ++ ) {

		if ( RevisionList [ i ] [ revision_date ] == unix ) {

			return i ;
		}

		else continue ;
	}

	return -1 ;
}

GetRevisionType ( unix, revision_id ) {

	new string [ 32 ] ;

	switch ( RevisionList [ revision_id ] [ revision_type ] ) {

		case REVISION_TYPE_ADDITION: {

			strins ( string, "added{DEDEDE} \t", 0, sizeof ( string ) ) ;
		}

		case REVISION_TYPE_REMOVAL: {

			strins ( string, "removed{DEDEDE}", 0, sizeof ( string ) ) ;
		}

		case REVISION_TYPE_CHANGE: { 

			strins ( string, "changed{DEDEDE}", 0, sizeof ( string ) ) ;
		}

		case REVISION_TYPE_HOTFIX: {

			strins ( string, "hotfixed{DEDEDE}", 0, sizeof ( string ) ) ;
		}

		default: {

			strins ( string, "updated{DEDEDE}", 0, sizeof ( string ) ) ;
		}
	}

	if ( gettime() - 3600 < unix ) {

		strins ( string, "{87c482}", 0, sizeof ( string ) ) ;
	}

	else {

		strins ( string, "{777777}", 0, sizeof ( string ) ) ;
	}

	return string ;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////

