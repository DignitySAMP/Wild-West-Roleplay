new Text: td_fade;
new ScreenStatus [ MAX_PLAYERS ] ;
new IsPlayerFading [ MAX_PLAYERS ] ;
new IsPlayerUsingBF[MAX_PLAYERS];

CMD:blindfold(playerid,params[]) {

	if(!IsPlayerUsingBF[playerid]) {

		TextDrawBoxColor(td_fade,0x000000FF);
		TextDrawShowForPlayer(playerid,td_fade);
		IsPlayerUsingBF[playerid] = 1;
	}
	else {

		TextDrawHideForPlayer(playerid,td_fade);
		IsPlayerUsingBF[playerid] = 0;
	}
	return true;
}

LoadFaderTextdraw () {
	td_fade = TextDrawCreate( -20.000000, 0.000000, "_" ); 
 	TextDrawUseBox( td_fade, 1 );
 	TextDrawBoxColor( td_fade, 0x000000FF );
 	TextDrawAlignment( td_fade, 0 );
 	TextDrawBackgroundColor( td_fade, 0x000000FF );
 	TextDrawFont( td_fade, 3 );
 	TextDrawLetterSize( td_fade, 1.000000, 52.200000 );
 	TextDrawColor( td_fade, 0x000000FF );
}

FadeIn ( playerid ) {

	if ( ! IsPlayerFading [ playerid ] ) {
		ScreenStatus [ playerid ] = 1;

		TogglePlayerControllable(playerid, false ) ;
		defer FadeTimer[1000](playerid);

		IsPlayerFading [ playerid ] = true ;
	}
}

timer FadeTimer[250](playerid) {
		
////	print("FadeTimer timer called (fader.pwn)");

	TextDrawHideForPlayer( playerid, td_fade );

	switch( ++ ScreenStatus [ playerid ] ) {
	    case 1: TextDrawBoxColor( td_fade, 0x000000FF );
	    case 2: TextDrawBoxColor( td_fade, 0x000000DD );
	    case 3: TextDrawBoxColor( td_fade, 0x000000CC );
	    case 4: TextDrawBoxColor( td_fade, 0x000000BB );
	    case 5: TextDrawBoxColor( td_fade, 0x000000AA );
		case 6: TextDrawBoxColor( td_fade, 0x00000099 );
		case 7: TextDrawBoxColor( td_fade, 0x00000088 );
		case 8: TextDrawBoxColor( td_fade, 0x00000077 );
		case 9: TextDrawBoxColor( td_fade, 0x00000066 );
		case 10: TextDrawBoxColor( td_fade, 0x00000055 );
		case 11: TextDrawBoxColor( td_fade, 0x00000044 );
		case 12: TextDrawBoxColor( td_fade, 0x00000033 );
		case 13: TextDrawBoxColor( td_fade, 0x00000022 );
		case 14: TextDrawBoxColor( td_fade, 0x00000011 );

		case 15:
		{
		    TextDrawBoxColor( td_fade, 0x00000000 );
            TextDrawHideForPlayer( playerid, td_fade );

            TogglePlayerControllable(playerid, true ) ;

            ScreenStatus [ playerid ] = 0;
			IsPlayerFading [ playerid ] = false ;

            return true;
		}
	}
	
	TextDrawShowForPlayer( playerid, td_fade );

	defer FadeTimer(playerid);

	return true ;
}

BlackScreen ( playerid ) {
	
	TextDrawHideForPlayer( playerid, td_fade );
	TextDrawBoxColor( td_fade, 0x000000FF );
	TextDrawShowForPlayer( playerid, td_fade );

	return true ;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
