CanCharacterAffordPrice(playerid, dollars, cents = 0) {

	if(Character[playerid][character_handmoney] > dollars) { return true; }
	return (Character[playerid][character_handmoney] == dollars && Character[playerid][character_handchange] >= cents) ? (true) : (false);
}

SetCharacterMoney(playerid,amount,slot) {

	switch(slot) {

		case MONEY_SLOT_HAND: { Character[playerid][character_handmoney] = amount; }
		case MONEY_SLOT_BANK: { Character[playerid][character_bankmoney] = amount; }
		case MONEY_SLOT_PAYC: { Character[playerid][character_paycheck] = amount; }
	}

	new query[256];

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_handmoney = '%d', character_bankmoney = '%d', character_paycheck = '%d' WHERE character_id = '%d'", 
		Character [ playerid ] [ character_handmoney ], Character [ playerid ] [ character_bankmoney ], Character [ playerid ] [ character_paycheck ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	ResetPlayerMoney(playerid);
	GivePlayerMoney ( playerid, Character [ playerid ] [ character_handmoney ] ) ;

	UpdateGUI ( playerid ) ;
	return true;
}

SetCharacterChange(playerid,amount,slot) {

	if(amount > 99 || amount < 0) { return false; }
	switch(slot) {

		case MONEY_SLOT_HAND: { Character[playerid][character_handchange] = amount; }
		case MONEY_SLOT_BANK: { Character[playerid][character_bankchange] = amount; }
		case MONEY_SLOT_PAYC: { Character[playerid][character_paychange] = amount; }
	}

	new query[256];

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_handmoney = '%d', character_bankmoney = '%d', character_paycheck = '%d' WHERE character_id = '%d'", 
		Character [ playerid ] [ character_handmoney ], Character [ playerid ] [ character_bankmoney ], Character [ playerid ] [ character_paycheck ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	ResetPlayerMoney(playerid);
	GivePlayerMoney ( playerid, Character [ playerid ] [ character_handmoney ] ) ;

	UpdateGUI ( playerid ) ;
	return true;
}

GiveCharacterMoney ( playerid, amount, slot = MONEY_SLOT_HAND) {

	if(amount < 0) { return false; }

	switch ( slot ) {
		case MONEY_SLOT_HAND: Character [ playerid ] [ character_handmoney ] += amount ;
		case MONEY_SLOT_BANK: Character [ playerid ] [ character_bankmoney ] += amount ;
		case MONEY_SLOT_PAYC: Character [ playerid ] [ character_paycheck ] += amount ;
	}

	new query [ 256 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_handmoney = '%d', character_bankmoney = '%d', character_paycheck = '%d' WHERE character_id = '%d'", 
		Character [ playerid ] [ character_handmoney ], Character [ playerid ] [ character_bankmoney ], Character [ playerid ] [ character_paycheck ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	ResetPlayerMoney(playerid);
	GivePlayerMoney ( playerid, Character [ playerid ] [ character_handmoney ] ) ;

	UpdateGUI ( playerid ) ;

	//OldLog ( playerid, "money/script", sprintf ( "GIVECHARACTERMONEY CALLED: %s, ++ $%d, SLOT: %d (0=hand, 1=bank, 2=paycheck)", ReturnUserName ( playerid, false ), IntegerWithDelimiter ( amount ), slot  )) ;

	return true ;
}

GiveCharacterChange ( playerid, amount, slot ) {

	if(amount < 0) { return false; }

	switch ( slot ) {
		case MONEY_SLOT_HAND: { 
			
			Character [ playerid ] [ character_handchange ] += amount ;
			if(Character[playerid][character_handchange] >= 100) {

				new total = Character[playerid][character_handchange]-100;
				Character[playerid][character_handmoney]++;
				Character[playerid][character_handchange] = total;
			}
		}
		case MONEY_SLOT_BANK: {

			Character [ playerid ] [ character_bankchange ] += amount ;
			if(Character[playerid][character_bankchange] >= 100) {

				new total = Character[playerid][character_bankchange]-100;
				Character[playerid][character_bankmoney]++;
				Character[playerid][character_bankchange] = total;
			}
		}
		case MONEY_SLOT_PAYC: {

			Character [ playerid ] [ character_paychange ] += amount ;
			if(Character[playerid][character_paychange] >= 100) {

				new total = Character[playerid][character_paychange]-100;
				Character[playerid][character_paycheck]++;
				Character[playerid][character_paychange] = total;
			}
		}
	}

	new query [ 512 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_handmoney = '%d', character_handchange = '%d', character_bankmoney = '%d', character_bankchange = '%d', character_paycheck = '%d', character_paychange = '%d' WHERE character_id = '%d'", 
		Character [ playerid ] [ character_handmoney], Character [ playerid ] [ character_handchange ], Character [ playerid ] [ character_bankmoney ], Character[playerid][character_bankchange], Character [ playerid ] [ character_paycheck ], Character[playerid][character_paychange], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	ResetPlayerMoney(playerid);
	GivePlayerMoney ( playerid, Character [ playerid ] [ character_handmoney ] ) ;

	UpdateGUI ( playerid ) ;

	//OldLog ( playerid, "money/script", sprintf ( "GIVECHARACTERMONEY CALLED: %s, ++ $%d, SLOT: %d (0=hand, 1=bank, 2=paycheck)", ReturnUserName ( playerid, false ), IntegerWithDelimiter ( amount ), slot  )) ;

	return true ;
}

TakeCharacterMoney ( playerid, amount, slot = MONEY_SLOT_HAND) {

	if ( amount < 0 ) {

		return SendServerMessage ( playerid, "Nice try.", MSG_TYPE_ERROR ) ;
	}

	switch ( slot ) {
		case MONEY_SLOT_HAND: Character [ playerid ] [ character_handmoney ] -= amount ;
		case MONEY_SLOT_BANK: Character [ playerid ] [ character_bankmoney ] -= amount ;
		case MONEY_SLOT_PAYC: Character [ playerid ] [ character_paycheck ] -= amount ;
	}

	new query [ 256 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_handmoney = '%d', character_bankmoney = '%d', character_paycheck = '%d' WHERE character_id = '%d'", 
		Character [ playerid ] [ character_handmoney ], Character [ playerid ] [ character_bankmoney ], Character [ playerid ] [ character_paycheck ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	ResetPlayerMoney(playerid);
	GivePlayerMoney ( playerid, Character [ playerid ] [ character_handmoney ] ) ;

	UpdateGUI ( playerid ) ;

	//OldLog ( playerid, "money/script", sprintf ( "TAKECHARACTERMONEY CALLED: %s, -- $%d, SLOT: %d (0=hand, 1=bank, 2=paycheck)", ReturnUserName ( playerid, false ), IntegerWithDelimiter ( amount ), slot  )) ;

	return true ;
}

TakeCharacterChange(playerid,amount,slot) {

	if ( amount < 0 ) {

		return SendServerMessage ( playerid, "Nice try.", MSG_TYPE_ERROR ) ;
	}

	switch ( slot ) {
		case MONEY_SLOT_HAND: { 

			Character [ playerid ] [ character_handchange ] -= amount ;
			if(Character[playerid][character_handchange] < 0) {

				new total = 100+Character[playerid][character_handchange];
				Character[playerid][character_handmoney]--;
				Character[playerid][character_handchange] = total;
			}
		}
		case MONEY_SLOT_BANK: { 

			Character [ playerid ] [ character_bankchange ] -= amount ;
			if(Character[playerid][character_bankchange] < 0) {

				new total = 100+Character[playerid][character_bankchange];
				Character[playerid][character_bankmoney]--;
				Character[playerid][character_bankchange] = total;
			}

		}
		case MONEY_SLOT_PAYC: {

			Character [ playerid ] [ character_paycheck ] -= amount ;
			if(Character[playerid][character_paychange] < 0) {

				new total = 100+Character[playerid][character_paychange];
				Character[playerid][character_paycheck]--;
				Character[playerid][character_paychange] = total;
			}
		}
	}

	new query [ 512 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_handmoney = '%d', character_handchange = '%d', character_bankmoney = '%d', character_bankchange = '%d', character_paycheck = '%d', character_paychange = '%d' WHERE character_id = '%d'", 
		Character [ playerid ] [ character_handmoney], Character [ playerid ] [ character_handchange ], Character [ playerid ] [ character_bankmoney ], Character[playerid][character_bankchange], Character [ playerid ] [ character_paycheck ], Character[playerid][character_paychange], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	ResetPlayerMoney(playerid);
	GivePlayerMoney ( playerid, Character [ playerid ] [ character_handmoney ] ) ;

	UpdateGUI ( playerid ) ;

	//OldLog ( playerid, "money/script", sprintf ( "TAKECHARACTERMONEY CALLED: %s, -- $%d, SLOT: %d (0=hand, 1=bank, 2=paycheck)", ReturnUserName ( playerid, false ), IntegerWithDelimiter ( amount ), slot  )) ;

	return true ;
}

CMD:pay ( playerid, params [] ) {

	new targetid, amount, cents ;

	if ( Character [ playerid ] [ character_level ] < 3 ) {

		return SendServerMessage ( playerid, "You need to be level 3 to use this command.", MSG_TYPE_ERROR ) ;
	}

	if ( sscanf ( params, "k<u>iI(0)", targetid, amount, cents ) ) {

		return SendServerMessage ( playerid, "/pay [player] [dollars] [cents]", MSG_TYPE_ERROR ) ;
	}

	if ( targetid == INVALID_PLAYER_ID ) {

		return SendServerMessage ( playerid, "Your target player seems to not exist.", MSG_TYPE_ERROR ) ;
	}

 	if (!IsPlayerNearPlayer(playerid, targetid, 6.0)) {

	    return SendServerMessage(playerid, "You are not near that player.", MSG_TYPE_ERROR);
    }

    if(targetid == playerid) { return SendServerMessage(playerid,"You cannot pay yourself.",MSG_TYPE_ERROR); }

    if(amount < 0) { return SendServerMessage(playerid,"Yout cannot pay negative amounts of money.",MSG_TYPE_ERROR); }

	if(amount < 1) {

		if(cents < 1 || cents > 99) {

			return SendServerMessage(playerid,"You can only give between 0-99 cent(s).", MSG_TYPE_ERROR);
		}
		TakeCharacterChange(playerid,cents,MONEY_SLOT_HAND);
		GiveCharacterChange(targetid,cents,MONEY_SLOT_HAND);
	}
	else {

		if ( amount < 1 || amount > Character [ playerid ] [ character_handmoney ] ) {

			return SendServerMessage ( playerid, "You don't have that much money.", MSG_TYPE_ERROR ) ;
		}
		if(cents < 0 || cents > 99) {

			return SendServerMessage(playerid,"You can only give between 1-99 cent(s).", MSG_TYPE_ERROR);
		}
		TakeCharacterMoney ( playerid, amount, MONEY_SLOT_HAND ) ;
		GiveCharacterMoney ( targetid, amount, MONEY_SLOT_HAND ) ;

		if(cents) { 
			
			TakeCharacterChange(playerid,cents,MONEY_SLOT_HAND);
			GiveCharacterChange(targetid,cents,MONEY_SLOT_HAND);
		}
	}

	if(cents != 0) { ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s has paid $%s.%02d to %s.", ReturnUserName ( playerid, false, true ), IntegerWithDelimiter ( amount ), cents, ReturnUserName ( targetid, false, true )) ) ; }
	else { ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s has paid $%s to %s.", ReturnUserName ( playerid, false, true ), IntegerWithDelimiter ( amount ), ReturnUserName ( targetid, false, true )) ) ; }

	// Only do anim if they're close to the player to avoid abuse
    if ( IsPlayerNearPlayer ( playerid, targetid, 2.0 ) ) {
		SetPlayerToFacePlayer(targetid, playerid);
		SetPlayerToFacePlayer(playerid, targetid);

		ApplyAnimation(targetid, "GANGS", "prtial_hndshk_biz_01", 4.0, 0, 0, 0, 0, 0, 1);
		ApplyAnimation(playerid, "GANGS", "prtial_hndshk_biz_01", 4.0, 0, 0, 0, 0, 0, 1);
	}

	SendModeratorWarning ( sprintf("[PAY] %s has paid $%s.%02d to %s.", ReturnUserName ( playerid, true ), IntegerWithDelimiter ( amount ), cents, ReturnUserName ( targetid, true )), MOD_WARNING_MED ) ;
	//OldLog ( playerid, "mod/money", sprintf("%s has paid $%s to %s.", ReturnUserName ( playerid, true ), IntegerWithDelimiter ( amount ), ReturnUserName ( targetid, true )) ) ;
	WriteLog ( playerid, "money/pay", sprintf ( "%s paid %s $%s.%02d", ReturnUserName ( playerid, false ), ReturnUserName ( targetid, false ), IntegerWithDelimiter ( amount ), cents )) ;

	return true ;
}

CMD:charity ( playerid, params [] ) {

	new amount, cents, reason [ 64 ] ;

	if ( sscanf ( params, "iis[64]", amount, cents, reason ) ) {

		return SendServerMessage ( playerid, "/charity [dollars] [cents] [reason]", MSG_TYPE_ERROR ) ;
	}

	if ( amount < 0 || cents < 0) {

		return SendServerMessage ( playerid, "Nice try.", MSG_TYPE_ERROR  ) ;
	}

	if ( Character [ playerid ] [ character_handmoney ] < amount ) {

		return SendServerMessage ( playerid, "You don't have that much money in your hand!", MSG_TYPE_ERROR ) ;
	}

	if ( Character [ playerid ] [ character_handchange ] < cents ) { 

		return SendServerMessage(playerid, "You don't have that much cents in your hand!",MSG_TYPE_ERROR);
	}

	if ( ! strlen ( reason ) || strlen ( reason ) > 64 ) {

		return SendServerMessage ( playerid, "Your reason can't be longer than 64 characters, or empty.", MSG_TYPE_ERROR ) ;
	}

	inline CharityConfirm(pid, dialogid, response, listitem, string:inputtext[]) {
	    #pragma unused pid, dialogid, listitem, inputtext

		if ( ! response ) {

	    	return false ;
		}

		if ( response ) {

			SendClientMessage(playerid, COLOR_YELLOW, sprintf("[CHARITY] (%d) %s has just charitied $%s.%02d. Reason: %s", playerid, ReturnUserName ( playerid, true ), IntegerWithDelimiter ( amount ), cents, reason )) ;
			SendModeratorWarning ( sprintf("[CHARITY] (%d) %s has just charitied $%s.%02d. Reason: %s", playerid, ReturnUserName ( playerid, true ), IntegerWithDelimiter ( amount ), cents, reason ), MOD_WARNING_MED ) ;
			if(amount) { TakeCharacterMoney ( playerid, amount, MONEY_SLOT_HAND ) ; }
			if(cents) { TakeCharacterChange(playerid,cents,MONEY_SLOT_HAND); }


			//OldLog ( playerid, "mod/money", sprintf ( "%s has charitied $%s, reason: %s", ReturnUserName ( playerid, false ), IntegerWithDelimiter ( amount ), reason )) ;
			WriteLog ( playerid, "money/charity", sprintf ( "%s has charitied $%s, reason: %s", ReturnUserName ( playerid, false ), IntegerWithDelimiter ( amount ), reason )) ;

			return true ;
		}
	}

	new confirmstring [ 1024 ] ;

	format ( confirmstring, sizeof ( confirmstring ), 

		"{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\n\
		You're about to charity {C23030}%s{DEDEDE} to the server.\n\n\
		{C23030}THERE IS NO WAY TO GET THIS MONEY BACK.{DEDEDE}\n\n\
		Only press continue if you're certain."

	, IntegerWithDelimiter ( amount )  ) ;

	Dialog_ShowCallback ( playerid, using inline CharityConfirm, DIALOG_STYLE_MSGBOX, "{C23030}ANTI DUMBASS WARNING{DEDEDE}", confirmstring, "{C23030}Continue", "No way" );

	return true ;
}

/*

new tax = % of character_handmoney +bankmoney ;

new biztax = 50 to 100 per property, based on how many they own;

takecharmoney ( pid, tax+biztax);

if ( biztax ) {
// store in government bank
}

if ( faction == pd or gov ) {
money = xxx ;

if ( gov_bank > money ) {

   givepaycheck ( ) ;
}

else "ur faction doesnt have enough funds to pay u";
}(edited)
*/

timer Paycheck[2700000](playerid){

	new query[256];
	if ( LastPaycheckGiven [ playerid ]  >= gettime ()) {

		if ( ! IsPlayerSleepingInPoint [ playerid ]) { 

			defer Paycheck[270000](playerid);
		}

		else defer Paycheck[4050000](playerid);
		return true ;
	}

	LastPaycheckGiven [ playerid ] = gettime () + 1800 ;

	if(IsPlayerUsingAFKCommand(playerid)) { goto skipPaycheck; } //if they're using /afk

	new oldbal = Character [ playerid ] [ character_bankmoney ],
	paycheck, paychange, donator_money, property_tax, property_tax_change ;

	if(GetPlayerOwnedPoints(playerid,POINT_TYPE_HOUSE)) { property_tax++; }
	if(GetPlayerOwnedPoints(playerid,POINT_TYPE_BIZ)) { 
		
		property_tax += 2;
		property_tax_change += 50;
		if(property_tax_change >= 100) {

			property_tax++;
			property_tax_change = 0;
		}
	}
	
	new posseid = Character [ playerid ] [ character_posse ] ;

	paycheck = 2 ;
	paychange = 50 ;

	if ( IsLawEnforcementPosse ( posseid ) ) {

		paycheck = 7 ;
		paychange = 25 ;
	}


	//new interest = money_tax_int / 2, donator_money = 0 ;

	switch ( Account [ playerid ] [ account_donatorlevel ] ) {

		case 1: { 
		
			donator_money = 4 ; //50
		}

		case 2: { 

			//tax_total = floatround( float(tax_total)/1.5 ) ; 
			donator_money = 6 ; //75
		}

		case 3: { 

			//tax_total = tax_total/2 ; 
			donator_money = 8 ; //100
		}
	}

	if ( Account [ playerid ] [ account_donatorlevel ] ) { 
		GiveCharacterMoney ( playerid, donator_money, MONEY_SLOT_BANK );
 	}

 	if(paycheck > 0) { GiveCharacterMoney ( playerid, paycheck, MONEY_SLOT_PAYC ) ; }
 	if(paychange > 0) { GiveCharacterChange(playerid,paychange,MONEY_SLOT_PAYC); }

 	if(property_tax > 0) { TakeCharacterMoney(playerid,property_tax,MONEY_SLOT_BANK); }
 	if(property_tax_change > 0) { TakeCharacterChange(playerid,property_tax_change,MONEY_SLOT_BANK); }

 	if(Character[playerid][character_paycheck] < 0) {

 		new oldpay,oldchange;
 		oldpay = Character[playerid][character_paycheck];
 		oldchange = Character[playerid][character_paychange];
 		Character[playerid][character_paycheck] = 0;
 		Character[playerid][character_paychange] = 0;
 		mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_paycheck = %d,character_paychange = %d WHERE character_id = %d",Character[playerid][character_paycheck],Character[playerid][character_paychange],Character[playerid][character_id]);
 		mysql_tquery(mysql,query);

 		SendModeratorWarning(sprintf("[Paycheck] (%d) %s's paycheck was in the negative.  Paycheck: $%02d.%02d",playerid,ReturnUserName(playerid,true,false),oldpay,oldchange),MOD_WARNING_MED);
 	}

	//else paycheck = 0 ;

	SendClientMessage(playerid, COLOR_TAB0, "|_______| Paycheck |_______|" ) ;
	SendClientMessage(playerid, -1, "");

	//SendClientMessage(playerid, COLOR_TAB1, sprintf("[Old Balance:] $%s [New Balance:] $%s [Interest]: $%s", IntegerWithDelimiter (oldbal), IntegerWithDelimiter(Character [ playerid ] [ character_bankmoney ] ), IntegerWithDelimiter( interest ) ));
	//SendClientMessage(playerid, COLOR_TAB1, sprintf("[Old Balance:] $%s [New Balance:] $%s", IntegerWithDelimiter (oldbal), IntegerWithDelimiter(Character [ playerid ] [ character_bankmoney ] ) ));
	SendClientMessage(playerid, COLOR_TAB1, sprintf("[Taxes paid:] $%s [Property Tax]: $%s", IntegerWithDelimiter ( property_tax ), IntegerWithDelimiter ( property_tax ) )) ;

	if ( paycheck ) {
		SendClientMessage(playerid, COLOR_TAB1, sprintf("[Incoming]: $%s.%02d [Total Paycheck]: $%s.%02d", IntegerWithDelimiter ( paycheck ), paychange, IntegerWithDelimiter ( Character [ playerid ] [ character_paycheck ] ), Character[playerid][character_paychange] )) ;
	}

	else SendClientMessage(playerid, COLOR_TAB1, sprintf("[Incoming]: $0 [Total Paycheck]: $%s.%02d", IntegerWithDelimiter ( Character [ playerid ] [ character_paycheck ] ),Character[playerid][character_paychange]));

	if ( Account [ playerid ] [ account_donatorlevel ] ) { 
		SendClientMessage ( playerid, COLOR_TAB1, sprintf("[Donator]: $%s", IntegerWithDelimiter ( donator_money ) ) ) ;
	}

	SendClientMessage(playerid, COLOR_TAB1, sprintf("[Old Balance:] $%s.%02d [New Balance:] $%s.%02d", IntegerWithDelimiter (oldbal),Character[playerid][character_bankchange], IntegerWithDelimiter(Character [ playerid ] [ character_bankmoney ] ), Character[playerid][character_bankchange] ));

	SendClientMessage(playerid, -1, "");
	SendServerMessage ( playerid, "To collect your paycheck, type /paycheck in any postal office.", MSG_TYPE_INFO ) ;

	switch ( Account [ playerid ] [ account_donatorlevel ] ) {

		case 1: GivePlayerExperience ( playerid, 2 ) ;
		case 2: GivePlayerExperience ( playerid, 3 ) ;
		case 3: GivePlayerExperience ( playerid, 4 ) ;
		default: GivePlayerExperience ( playerid, 1 ) ;
	}

	Character [ playerid ] [ character_hours ] ++ ;

	mysql_tquery ( mysql, sprintf("UPDATE characters SET character_hours = '%d' WHERE character_id = '%d'", Character [ playerid ] [ character_hours ], Character [ playerid ] [ character_id ])) ;
	//WriteLog ( playerid, "paycheck", sprintf("'%s' processed paycheck [income: %d] [property tax: %d] [wealth tax: %d] [general tax: %d]", ReturnUserName ( playerid, true ), IntegerWithDelimiter ( paycheck ), IntegerWithDelimiter ( property_tax ), IntegerWithDelimiter ( money_tax_int ), IntegerWithDelimiter ( taxes ) ) ) ;
		
	/*					
	new query [ 256 ] ;

	for ( new i; i < MAX_POSSES; i ++ ) {

		if ( Posse [ i ] [ posse_id ] != -1 && Posse [ i ] [ posse_type ] == 2 ) {

			//Posse [ i ] [ posse_bank ] += interest ;
			//Posse [ i ] [ posse_bank ] += tax_total ;
			Posse [ i ] [ posse_bank ] -= paycheck ;
			Posse [ i ] [ posse_bank_decimal ] -= paychange;

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE posses SET posse_bank = '%d', posse_bank_decimal = '%d' WHERE posse_id = %d", Posse [ i ] [ posse_bank ], Posse [ i ] [ posse_bank_decimal ], Posse [ i ] [ posse_id ] ) ;
			mysql_tquery ( mysql, query ) ; 
		}
	}
	*/

	skipPaycheck:

	if ( ! IsPlayerSleepingInPoint [ playerid ] ) { 

		defer Paycheck[270000](playerid);
	}

	else defer Paycheck[4050000](playerid);

	return true ;
}

IntegerWithDelimiter(integer, delimiter[] = ",") {
    new string[16];

    format(string, sizeof string, "%i", integer);

    for (new i = strlen(string) - 3, j = ((integer < 0) ? 1 : 0); i > j; i -= 3) {

        strins(string, delimiter, i, sizeof string);
    }

    return string;
}
