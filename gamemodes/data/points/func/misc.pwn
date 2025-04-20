new advertiseTick [ MAX_PLAYERS ], playerLastTelegramPage [ MAX_PLAYERS ], bool: playerTelegramUsingMySQL [ MAX_PLAYERS ] ;

CMD:doorshout ( playerid, params [] ) {

	new text [ 144 ] ;

	if ( sscanf ( params, "s[144]", text ) ) {

		return SendServerMessage ( playerid, "/doorshout [text]", MSG_TYPE_ERROR ) ;
	}

	if ( strlen ( text ) > 144 || ! strlen ( text ) ) {

		return SendServerMessage ( playerid, "No more than 144 characters please!", MSG_TYPE_ERROR ) ;
	}

	new pointid = -1 ;

	for ( new i; i < MAX_POINTS; i ++ ) {

		if ( Point [ i ] [ point_id ] != -1 ) {

			if ( IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_ext_x ],  Point [ i ] [ point_ext_y ], Point [ i ] [ point_ext_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int ] || 
				 IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ] ) {

				pointid = i ;
			}

			else continue ;
		}

		else continue ;
	}

	if ( pointid == -1 ) {

		return SendServerMessage ( playerid, "You're not near a door.", MSG_TYPE_ERROR ) ;
	}

	foreach (new i: Player) {

		if ( i == playerid ) {

			continue ;
		}

		if ( IsPlayerInRangeOfPoint(i, 2.5, Point [ pointid ] [ point_int_x ],  Point [ pointid ] [ point_int_y ], Point [ pointid ] [ point_int_z ] ) && GetPlayerVirtualWorld ( i ) == Point [ pointid ] [ point_int_vw ] && GetPlayerInterior ( i ) == Point [ pointid ] [ point_int_int ] ) {
	
			SendClientMessage(i, COLOR_BLUE, sprintf("%s shouts (door: outside): %s", ReturnUserName ( playerid, false ), text ) ) ;
		}
		
		else if ( IsPlayerInRangeOfPoint(i, 2.5, Point [ pointid ] [ point_ext_x ],  Point [ pointid ] [ point_ext_y ], Point [ pointid ] [ point_ext_z ] ) && GetPlayerVirtualWorld ( i ) == Point [ pointid ] [ point_vw ] && GetPlayerInterior ( i ) == Point [ pointid ] [ point_int ] ) {
	
			SendClientMessage(i, COLOR_BLUE, sprintf("%s shouts (door: inside): %s", ReturnUserName ( playerid, false ), text ) ) ;
		}

		else continue ;
	}

	ProxDetector ( playerid, 30, -1, sprintf("%s shouts (door): %s", ReturnUserName ( playerid, false ), text) ) ;

	return true ;
}

CMD:ds ( playerid, params [] ) {

	return cmd_doorshout ( playerid, params ) ;
}

CMD:buytelegramnumber ( playerid, params [] ) {

	return SendServerMessage(playerid,"This is currently disabled.",MSG_TYPE_ERROR);
	/*
	for ( new i; i < MAX_POINTS; i ++ ) {
		if ( Point [ i ] [ point_id ] != -1 ) {
			if ( IsPlayerInRangeOfPoint(playerid, 15.0, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && 
				GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ] ) {

				if ( Point [ i ] [ point_biztype ] == POINT_TYPE_POSTAL ) {

					if ( Character [ playerid ] [ character_telegram_id ] != -1 ) {

						return SendServerMessage ( playerid, "You already have a telegram number!", MSG_TYPE_ERROR ) ;
					}

					if ( Character [ playerid ] [ character_handmoney ] < 500 ) {

						return SendServerMessage ( playerid, "You need $500 to buy a telegram number.", MSG_TYPE_ERROR ) ;
					}

					new query [ 128 ] ;

					TakeCharacterMoney ( playerid, 500, MONEY_SLOT_HAND ) ;

					Character [ playerid ] [ character_telegram_id ] = 10000 + Character [ playerid ] [ character_id ] ;

					mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_telegram_id = %d WHERE character_id = %d", Character [ playerid ] [ character_telegram_id ], Character [ playerid ] [ character_id ] ) ;
					mysql_tquery ( mysql, query ) ;

					return SendServerMessage ( playerid, sprintf("You've bought a telegram number, your number is %i.", Character [ playerid ] [ character_telegram_id ] ), MSG_TYPE_INFO ) ;
				}

				else continue;
			}
			else continue;
		}
		else continue;
	}

	return SendServerMessage ( playerid, "You're not inside of a postal office!", MSG_TYPE_ERROR ) ;
	*/
}

CMD:telegram ( playerid, params [] ) {

	for ( new i; i < MAX_POINTS; i ++ ) {
		if ( Point [ i ] [ point_id ] != -1 ) {
			if ( IsPlayerInRangeOfPoint(playerid, 15.0, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && 
				GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ] ) {

				if ( Point [ i ] [ point_biztype ] == POINT_TYPE_POSTAL ) {

					if ( Character [ playerid ] [ character_telegram_id ] == -1 ) {

						return SendServerMessage ( playerid, "You don't have a telegram number!", MSG_TYPE_ERROR ) ;
					}

					new telenumber, message [ 100 ] ;

					if ( sscanf ( params, "ds[100]", telenumber, message ) ) {

						return SendServerMessage ( playerid, "/tele(gram) [number] [message]", MSG_TYPE_ERROR ) ;
					}

					if ( telenumber == Character [ playerid ] [ character_telegram_id ] ) {

						return SendServerMessage ( playerid, "You cannot send a telegram to yourself!", MSG_TYPE_ERROR ) ;
					}

					//return SendServerMessage ( playerid, "Still in development.", MSG_TYPE_WARN ) ;
					new query [ 256 ] ;

					inline CheckIfTeleNumberExists() {

						new rows, fields;

						cache_get_data ( rows, fields, mysql ) ;

						if ( rows ) {

							new charid ;

							charid = cache_get_field_int ( 0, "character_id" ) ;

							mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO telegrams (telegram_sender, telegram_reciever, telegram_message, telegram_date) VALUES (%d, %d, '%e', '%e')",
								Character [ playerid ] [ character_telegram_id ], telenumber, message, ReturnServerTime() ) ;
							mysql_tquery ( mysql, query ) ;

							SendServerMessage ( playerid, sprintf("You have sent a telegram to %i.", telenumber ), MSG_TYPE_INFO ) ;

							foreach ( new j : Player ) {

								if ( Character [ j ] [ character_id ] == charid ) {

									Init_LoadTelegrams ( j ) ;
									defer RecieveTelegramMessage(j);
								}
								else continue;
							}

							return true ;
						}

						else {

							return SendServerMessage ( playerid, "That telegram number does not exist.", MSG_TYPE_ERROR ) ;
						}
					}

					mysql_format ( mysql, query, sizeof ( query ), "SELECT character_id FROM characters WHERE character_telegram_id = %d", telenumber ) ;
					mysql_tquery_inline ( mysql, query, using inline CheckIfTeleNumberExists, "" ) ;

				}
				else continue;
			}
			else continue;
		}
		else continue;
	}

	return SendServerMessage ( playerid, "You're not inside of a postal office!", MSG_TYPE_ERROR ) ;
}

CMD:tele ( playerid, params [] ) return cmd_telegram ( playerid, params ) ;

CMD:viewtelegrams ( playerid, params [] ) {

	return SendClientMessage(playerid, -1, "Currently under development." ) ;

	/*
	for ( new i; i < MAX_POINTS; i ++ ) {
		if ( Point [ i ] [ point_id ] != -1 ) {
			if ( IsPlayerInRangeOfPoint(playerid, 15.0, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && 
				GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ] ) {

				if ( Point [ i ] [ point_biztype ] == POINT_TYPE_POSTAL ) {

					new option [ 16 ] ;

					if ( sscanf ( params, "s[16]", option ) ) {

						return SendServerMessage ( playerid, "/viewtelegrams [sent/recieved]", MSG_TYPE_ERROR ) ;
					}

					if ( !strcmp ( option, "recieved" ) ) {

						if ( TelegramCount [ playerid ] ) {

							playerLastTelegramPage [ playerid ] = 1 ;
							playerTelegramUsingMySQL [ playerid ] = false ;
							return ViewTelegrams ( playerid ) ;
						}

						else { return SendServerMessage ( playerid, "You have no telegrams!", MSG_TYPE_ERROR ) ; }
					}

					else if ( ! strcmp ( option, "sent" ) ) {

						playerLastTelegramPage [ playerid ] = 1 ;
						playerTelegramUsingMySQL [ playerid ] = true ;
						return ViewTelegrams ( playerid, 1 ) ;
					}
				}
				else continue;
			}
			else continue;
		}
		else continue;
	}

	return true ;
	*/
}

CMD:paycheck ( playerid, params [] ) {

	/*
	for ( new i; i < MAX_POINTS; i ++ ) {
		if ( Point [ i ] [ point_id ] != -1 ) {
			if ( IsPlayerInRangeOfPoint(playerid, 15.0, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && 
				GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ] ) {

				if ( Point [ i ] [ point_biztype ] == POINT_TYPE_POSTAL ) {

					if ( Character [ playerid ] [ character_paycheck ] <= 0 ) {

						if(Character[playerid][character_paychange] <= 0) { return SendServerMessage ( playerid, "You can't withdraw money that you don't have.", MSG_TYPE_ERROR ) ; }
					}

					new paycheck = Character [ playerid ] [ character_paycheck ], paychange = Character[playerid][character_paychange] ;

					if(paycheck) {

						TakeCharacterMoney ( playerid, Character [ playerid ] [ character_paycheck ], MONEY_SLOT_PAYC ) ;
						GiveCharacterMoney ( playerid, paycheck, MONEY_SLOT_BANK ) ;
					}
					if(paychange) {

						TakeCharacterChange(playerid,Character[playerid][character_paychange],MONEY_SLOT_PAYC);
						GiveCharacterChange(playerid,paychange,MONEY_SLOT_BANK);
					}

					SendServerMessage ( playerid, sprintf("You've collected your paycheck of $%s.%02d.", IntegerWithDelimiter ( paycheck ), paychange), MSG_TYPE_INFO ) ;


					return true ;
				}
			}

			else continue ;
		}

		else continue ;
	}
	*/
	if(GetCharacterPointID(playerid) == -1) { return SendServerMessage ( playerid, "You're not inside of a postal office!", MSG_TYPE_ERROR ) ; }
	else {

		new id = GetCharacterPointID(playerid);
		if(Point[id][point_biztype] == POINT_TYPE_POSTAL) {

			if(Character[playerid][character_paycheck] < 0) { return SendServerMessage(playerid,"You don't have any money to receive through a paycheck.",MSG_TYPE_ERROR); }
			else if(Character[playerid][character_paycheck] == 0) {

				if(Character[playerid][character_paychange] <= 0) { return SendServerMessage(playerid,"You don't have any money to receive through a paycheck.",MSG_TYPE_ERROR); }
				else { goto receivePaycheck; }
			}

			receivePaycheck:

			SendServerMessage(playerid,sprintf("You've received $%s.%02d from your paycheck.",IntegerWithDelimiter(Character[playerid][character_paycheck]),Character[playerid][character_paychange]),MSG_TYPE_INFO);
			if(Character[playerid][character_paycheck] > 0) {

				GiveCharacterMoney(playerid,Character[playerid][character_paycheck],MONEY_SLOT_BANK);
				SetCharacterMoney(playerid,0,MONEY_SLOT_PAYC);
			}
			if(Character[playerid][character_paychange] > 0) {

				GiveCharacterChange(playerid,Character[playerid][character_paychange],MONEY_SLOT_BANK);
				SetCharacterChange(playerid,0,MONEY_SLOT_PAYC);
			}
		}
		else { return SendServerMessage ( playerid, "You're not inside of a postal office!", MSG_TYPE_ERROR ) ; }
	}
	return true;
}

CMD:bank ( playerid, params [] ) {

	for ( new i; i < MAX_POINTS; i ++ ) {
		if ( Point [ i ] [ point_id ] != -1 ) {
			if ( IsPlayerInRangeOfPoint(playerid, 15.0, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && 
				GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ] ) {

				if ( Point [ i ] [ point_biztype ] == POINT_TYPE_BANK ) {

					new option [ 24 ], value, cents ;

					if ( sscanf ( params, "s[24]I(0)I(0)", option, value, cents )) {

						return SendServerMessage ( playerid, "/bank [deposit, withdraw, balance] [optional:dollars] [optional:cents]", MSG_TYPE_ERROR ) ;
					}

					if ( ! strcmp ( option, "deposit" ) ) {

						if ( value > Character [ playerid ] [ character_handmoney ] ) {

							return SendServerMessage ( playerid, "You don't have that much money.", MSG_TYPE_ERROR ) ;
						}

						if( value < 0 ) {

							return SendServerMessage(playerid,"You cannot deposit a negative amount of money.",MSG_TYPE_ERROR);
						}

						if ( value == 0 ) {

							if(cents <= 0) { return SendServerMessage ( playerid, "You can't store less than 0 dollars or cents.", MSG_TYPE_ERROR ) ; }
						}

						if(cents < 0 || cents > 99) {

							return SendServerMessage(playerid,"You must deposit between 1-99 cent(s).",MSG_TYPE_ERROR);
						}

						new oldbalance = Character [ playerid ] [ character_bankmoney ], oldchange = Character[playerid][character_bankchange] ;

						if(value) {
							
							TakeCharacterMoney ( playerid, value, MONEY_SLOT_HAND ) ;
							GiveCharacterMoney ( playerid, value, MONEY_SLOT_BANK ) ;
						}
						if(cents) {

							TakeCharacterChange(playerid,cents,MONEY_SLOT_HAND);
							GiveCharacterChange(playerid,cents,MONEY_SLOT_BANK);
						}

						if(cents) { SendServerMessage ( playerid, sprintf("You've deposited $%s.%02d into your bank account.", IntegerWithDelimiter ( value ), cents ), MSG_TYPE_INFO ) ; }
						else { SendServerMessage ( playerid, sprintf("You've deposited $%s into your bank account.", IntegerWithDelimiter ( value ) ), MSG_TYPE_INFO ) ; }
						SendServerMessage ( playerid, sprintf("New balance: $%s.%02d. Old balance: $%s.%02d.", IntegerWithDelimiter ( Character [ playerid ] [ character_bankmoney ] ), Character[playerid][character_bankchange], IntegerWithDelimiter ( oldbalance ), oldchange), MSG_TYPE_INFO ) ;

						WriteLog ( playerid, "bank", sprintf("%s deposited %s.%02d [bank: %s.%02d]", ReturnUserName ( playerid, true ), IntegerWithDelimiter ( value ), cents, IntegerWithDelimiter ( Character [ playerid ] [ character_bankmoney ] ), Character[playerid][character_bankchange] ) ) ;
						return true ;
					}

					else if ( ! strcmp ( option, "withdraw" ) ) {
						if ( value > Character [ playerid ] [ character_bankmoney ] ) {

							return SendServerMessage ( playerid, "You don't have that much money.", MSG_TYPE_ERROR ) ;
						}

						if( value < 0 ) {

							return SendServerMessage(playerid,"You cannot withdraw a negative amount of money.",MSG_TYPE_ERROR);
						}
					
						if ( value == 0) {

							if(cents <= 0) { return SendServerMessage ( playerid, "You can't withdraw less than 0 dollars or cents.", MSG_TYPE_ERROR ) ; }
						}

						if(cents < 0 || cents > 99) {

							return SendServerMessage(playerid,"You must deposit between 1-99 cent(s).",MSG_TYPE_ERROR);
						}

						new oldbalance = Character [ playerid ] [ character_bankmoney ], oldchange = Character[playerid][character_bankchange] ;

						if(value) {
							
							TakeCharacterMoney ( playerid, value, MONEY_SLOT_BANK ) ;
							GiveCharacterMoney ( playerid, value, MONEY_SLOT_HAND ) ;
						}
						if(cents) {

							TakeCharacterChange(playerid,cents,MONEY_SLOT_BANK);
							GiveCharacterChange(playerid,cents,MONEY_SLOT_HAND);
						}

						if(cents) { SendServerMessage ( playerid, sprintf("You've withdrawn $%s.%02d from your bank account.", IntegerWithDelimiter ( value ), cents ), MSG_TYPE_INFO ) ; }
						else { SendServerMessage ( playerid, sprintf("You've withdrawn $%s from your bank account.", IntegerWithDelimiter ( value ) ), MSG_TYPE_INFO ) ; }
						SendServerMessage ( playerid, sprintf("New balance: $%s.%02d. Old balance: $%s.%02d.", IntegerWithDelimiter ( Character [ playerid ] [ character_bankmoney ] ), Character[playerid][character_bankchange], IntegerWithDelimiter ( oldbalance ), oldchange), MSG_TYPE_INFO ) ;

						WriteLog ( playerid, "bank", sprintf("%s withdrew %s.%02d [bank: %s.%02d]", ReturnUserName ( playerid, true ), IntegerWithDelimiter ( value ), cents, IntegerWithDelimiter ( Character [ playerid ] [ character_bankmoney ] ), Character[playerid][character_bankchange] ) ) ;
						return true ;
					}

					else if ( ! strcmp ( option, "balance" ) ) {

						SendServerMessage ( playerid, sprintf("Bank balance: $%s.%02d", IntegerWithDelimiter ( Character [ playerid ] [ character_bankmoney ] ),Character[playerid][character_bankchange]), MSG_TYPE_INFO ) ;

						return true ;
					}

					return SendServerMessage ( playerid, "/bank [deposit, withdraw, balance] [optional:dollars] [optional:cents]", MSG_TYPE_ERROR ) ;
				}

				else continue ;
			}
		}

		else continue ;
	}

	return SendServerMessage ( playerid, "You're not inside of a bank!", MSG_TYPE_ERROR ) ;
}

CMD:advertise ( playerid, params [] ) {

	new tickDiff;
	for ( new i; i < MAX_POINTS; i ++ ) {
		if ( Point [ i ] [ point_id ] != -1 ) {
			if ( IsPlayerInRangeOfPoint(playerid, 15.0, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && 
				GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ] ) {

				if ( Point [ i ] [ point_biztype ] == POINT_TYPE_POSTAL ) {

					tickDiff = GetTickDiff ( GetTickCount(), advertiseTick [ playerid ] ) ;

					if ( tickDiff < 30000 ) {

						return SendServerMessage ( playerid, sprintf("You must wait %0.2f seconds before posting another advertisement.",float(30000 - tickDiff) / 1000.0), MSG_TYPE_ERROR ) ;
					}

					if ( Account [ playerid ] [ account_donatorlevel ] < 3 ) { //donor check

						if ( Character [ playerid ] [ character_handmoney ] < 15 ) {

							return SendServerMessage ( playerid, "You need at least $15 to post an advertisement.", MSG_TYPE_ERROR ) ;
						}
					}

					new adv [ 144 ] ;

					if ( sscanf ( params, "s[144]", adv ) ) {
						SendServerMessage ( playerid, "You will have to pay per character. If you have 50 characters, you'll pay $25.", MSG_TYPE_ERROR ) ;
						return SendServerMessage ( playerid, "/ad(vertise) [text]", MSG_TYPE_ERROR ) ;
					}

					new price = strlen ( adv ) / 2 ;

					if ( Account [ playerid ] [ account_donatorlevel ] < 3 ) { //donor check

						if ( price > Character [ playerid ] [ character_handmoney ] ) {

							return SendServerMessage ( playerid, sprintf("You need at least $%d for this advertisement.", price), MSG_TYPE_ERROR ) ;
						}

						TakeCharacterMoney ( playerid, price, MONEY_SLOT_HAND ) ;
					}

					SendSplitMessageToAll ( COLOR_TAB1, sprintf("[TOWN CRIER]: %s", adv ) ) ;
					WriteLog ( playerid, "advertisements", sprintf("%s made ad: %s", ReturnUserName ( playerid, true ), adv ) ) ;

					if ( Account [ playerid ] [ account_donatorlevel ] < 3 ) { SendServerMessage ( playerid, sprintf("You've paid $%s for your advertisement.", IntegerWithDelimiter ( price )), MSG_TYPE_WARN) ; }
					SendModeratorWarning ( sprintf("[ADVERT] (%d) %s made the last advertisement.", playerid, ReturnUserName ( playerid, true )), MOD_WARNING_MED ) ;
					//OldLog ( playerid, "advs", sprintf ( "%s posted ad \"%s\" for %d", ReturnUserName ( playerid, false ), adv, price )) ;

					advertiseTick [ playerid ] = GetTickCount();

					return true ;
				}
			}

			else continue ;
		}

		else continue ;
	}

	return SendServerMessage ( playerid, "You're not inside of a postal office!", MSG_TYPE_ERROR ) ;
}

CMD:ad(playerid, params [] ) {

	return cmd_advertise ( playerid, params ) ;
}


ViewTelegrams ( playerid, usingmysql = 0 ) {

	new MAX_TELEGRAMS_PER_PAGE = 5, string [ 1024 ], pages, resultcount, telecount ;

	static index ;

	inline dialog_ViewTelegrams(pid, dialogid, response, listitem, string:inputtext[] ) { 
	    #pragma unused pid, dialogid, listitem, inputtext		

	    if ( ! response ) return true ;
	    else {

	    	if ( playerLastTelegramPage [ playerid ] >= pages ) { index = 0 ; playerTelegramUsingMySQL [ playerid ] = false ; return true ; }

	    	else {

	    		playerLastTelegramPage [ playerid ] ++ ;
	    		if ( ! playerTelegramUsingMySQL [ playerid ] ) { return ViewTelegrams ( playerid ) ; }
	    		else { return ViewTelegrams ( playerid, 1 ) ; }
	    	}
	    }
	}

	if ( ! usingmysql ) {

		telecount = TelegramCount [ playerid ] ;
		pages = floatround ( telecount / MAX_TELEGRAMS_PER_PAGE, floatround_floor ) + 1 ;
    	resultcount = ( ( MAX_TELEGRAMS_PER_PAGE * playerLastTelegramPage [ playerid ] ) - MAX_TELEGRAMS_PER_PAGE ) ;

    	for ( new i = resultcount; i < sizeof ( telecount ); i ++ ) {

	        if ( resultcount <= MAX_TELEGRAMS_PER_PAGE * playerLastTelegramPage [ playerid ] ) {

	           format ( string, sizeof ( string ), "%s%d. [%s] %d: %s\n", string, Telegram [ playerid ] [ index ] [ telegram_id ], Telegram [ playerid ] [ index ] [ telegram_date ], Telegram [ playerid ] [ index ] [ telegram_sender ], Telegram [ playerid ] [ index ] [ telegram_message ] ) ;
	        }

	        index ++ ; 
	    }

	    return Dialog_ShowCallback(playerid, using inline dialog_ViewTelegrams, DIALOG_STYLE_MSGBOX, sprintf("Telegrams - %d - %d", playerLastTelegramPage [ playerid ], pages ), string, "Next", "Exit" ) ;
	}

	else {

		new query [ 144 ] ;

		inline CheckSentTelegrams() {

			new rows, fields ;

			cache_get_data ( rows, fields, mysql ) ;

			if ( rows ) {

				telecount = rows ;
				pages = floatround ( telecount / MAX_TELEGRAMS_PER_PAGE, floatround_floor ) + 1 ;
    			resultcount = ( ( MAX_TELEGRAMS_PER_PAGE * playerLastTelegramPage [ playerid ] ) - MAX_TELEGRAMS_PER_PAGE ) ;
				new teleid [ sizeof ( rows ) ], telenum [ sizeof ( rows ) ], telemessage [ sizeof ( rows ) ] [ 100 ], teledate [ sizeof ( rows ) ] [ 64 ], dummymsg [ 100 ], dummydate [ 64 ] ;

				for ( new i; i < rows; i ++ ) {

					teleid [ i ] = cache_get_field_int ( i, "telegram_id" ) ;
			        telenum [ i ] = cache_get_field_int ( i, "telegram_reciever" ) ;
					cache_get_field_content( i, "telegram_message", dummymsg, mysql, 100 ) ;
					telemessage [ i ] = dummymsg ;
					cache_get_field_content ( i, "telegram_date", dummydate, mysql, 64 ) ;
					teledate [ i ] = dummydate ;
				}

				for ( new i = resultcount; i < sizeof ( telecount ); i ++ ) {

			        if ( resultcount <= MAX_TELEGRAMS_PER_PAGE * playerLastTelegramPage [ playerid ] ) {

						format ( string, sizeof ( string ), "%s%d. [%s] %d: %s\n", string, teleid [ i ], teledate [ i ], telenum [ i ], telemessage [ i ] ) ;
			        }
			    }

			    return Dialog_ShowCallback(playerid, using inline dialog_ViewTelegrams, DIALOG_STYLE_MSGBOX, sprintf("Telegrams - %d - %d", playerLastTelegramPage [ playerid ], pages ), string, "Next", "Exit" ) ;
			}

			else { return SendServerMessage ( playerid, "You haven't sent any telegrams!", MSG_TYPE_ERROR ) ; }

		}

		mysql_format ( mysql, query, sizeof ( query ), "SELECT telegram_id, telegram_reciever, telegram_message, telegram_date FROM telegrams WHERE telegram_sender = %d ORDER BY telegram_id DESC", Character [ playerid ] [ character_telegram_id ] ) ;
		mysql_tquery_inline ( mysql, query, using inline CheckSentTelegrams, "" ) ;

	}

	return true ;
}