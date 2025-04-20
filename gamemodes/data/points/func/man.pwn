new bool: IsPlayerSleepingInPoint [ MAX_PLAYERS ] ;

CMD:point ( playerid, params [] ) {

	new buyprice, query [ 256 ], option [ 16 ], soption [ 32 ], amount ;


	if ( sscanf ( params, "s[16]S()[16]I(0)", option, soption, amount ) ) {

		return SendServerMessage ( playerid, "/point [buy, sell, lock, furni(ture), fee, collect, store, take, storage, sleep]", MSG_TYPE_INFO ) ;
	}

	if ( ! strcmp ( option, "buy" ) ) {

		for ( new i; i < MAX_POINTS; i ++ ) {
			if ( Point [ i ] [ point_id ] != -1 ) {
				if ( IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_ext_x ],  Point [ i ] [ point_ext_y ], Point [ i ] [ point_ext_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int ] ) {

					if ( Point [ i ] [ point_owner ] > 0) {

						return SendServerMessage ( playerid, "This entrance has already been purchased.", MSG_TYPE_ERROR ) ;
					}

					new total ;

					switch ( Point [ i ] [ point_type ] ) {
					
						case POINT_TYPE_PASS: {

							return SendServerMessage ( playerid, "You can't purchase this point.", MSG_TYPE_ERROR ) ;
						}

						case POINT_TYPE_HOUSE: {

							total = GetPlayerOwnedPoints ( playerid, POINT_TYPE_HOUSE ) ;

							if ( total == 1 ) { total = 2; }

							if ( Character [ playerid ] [ character_level ] < total*10 ) {

								return SendServerMessage ( playerid, sprintf("You can't purchase another house until level %i0.", total ), MSG_TYPE_ERROR ) ;
							}
						}

						case POINT_TYPE_BIZ: {

							total = GetPlayerOwnedPoints ( playerid, POINT_TYPE_BIZ ) ;

							if ( total == 1 ) { total = 2; }

							if ( Character [ playerid ] [ character_level ] < total*10 ) {

								return SendServerMessage ( playerid, sprintf("You can't purchase another business until level %i0.", total ), MSG_TYPE_ERROR ) ;
							}
						}

					}

					buyprice = Point [ i ] [ point_price ] ;

					if ( buyprice > Character [ playerid ] [ character_handmoney ] ) {

						return SendServerMessage ( playerid, "You don't have enough money to purchase this point.", MSG_TYPE_ERROR );
					}

					TakeCharacterMoney ( playerid, buyprice, MONEY_SLOT_HAND ) ;
					SendServerMessage ( playerid, sprintf("You've bought point (%d) %s for $%s",Point [ i ] [ point_id], Point [ i ] [ point_name ] , IntegerWithDelimiter ( Point [ i ] [ point_price ] )), MSG_TYPE_INFO ) ;

					GivePlayerExperience ( playerid, 3 ) ;

					mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_owner = '%d' WHERE point_id = '%d'", Character [ playerid ] [ character_id ], Point [ i ] [ point_id ] ) ;
					mysql_tquery ( mysql, query ) ;

					Init_Points ( Point [ i ] [ point_id ] ) ;
				}

				else continue ;
			}
		}
	}

	else if ( ! strcmp ( option, "sell" ) ) {
		for ( new i; i < MAX_POINTS; i ++ ) {
			if ( Point [ i ] [ point_id ] != -1 ) {
				if ( IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_ext_x ],  Point [ i ] [ point_ext_y ], Point [ i ] [ point_ext_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int ] ) {

					if ( Point [ i ] [ point_owner ] != Character [ playerid ] [ character_id ] ) {

						return SendServerMessage ( playerid, "You don't own this property.", MSG_TYPE_ERROR ) ;
					}

					buyprice = Point [ i ] [ point_price ] / 2 ;

					SendServerMessage ( playerid, sprintf("You've been given back $%s for selling the property.", IntegerWithDelimiter ( buyprice ) ), MSG_TYPE_INFO ) ;
					GiveCharacterMoney ( playerid, buyprice, MONEY_SLOT_HAND ) ;

					mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_owner = '-1', point_till = '0', point_till_change = '0', point_weapon1 = '0', point_weapon1ammo = '0', point_weapon2 = '0', point_weapon2ammo = '0' WHERE point_id = '%d'", Point [ i ] [ point_id ] ) ;
					mysql_tquery ( mysql, query ) ;

					Init_Points ( Point [ i ] [ point_id ] ) ;
				}

				else continue ;
			}
		}
	}

	else if ( ! strcmp ( option, "lock" ) ) {
		for ( new i; i < MAX_POINTS; i ++ ) {
			if ( Point [ i ] [ point_id ] != -1 ) {
				
				if ( 
					IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_ext_x ],  Point [ i ] [ point_ext_y ], Point [ i ] [ point_ext_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int ] ||
					IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ]) {

					if ( Point [ i ] [ point_owner ] != Character [ playerid ] [ character_id ] ) {

						return SendServerMessage ( playerid, "You don't own this property.", MSG_TYPE_ERROR ) ;
					}

					if ( ! Point [ i ] [ point_locked ] ) {

						Point [ i ] [ point_locked ] = true ;

						SendServerMessage ( playerid, "You've locked the door of your entrance.", MSG_TYPE_INFO ) ;
					}

					else if ( Point [ i ] [ point_locked ] ) { 

						Point [ i ] [ point_locked ] = false ;

						SendServerMessage ( playerid, "You've unlocked the door of your entrance.", MSG_TYPE_INFO ) ;
					}

					mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_locked = '%d' WHERE point_id = '%d'", Point [ i ] [ point_locked ], Point [ i ] [ point_id ] ) ;
					mysql_tquery ( mysql, query ) ;
				}

				else continue ;
			}
		}
	}

	else if ( ! strcmp ( option, "furniture", true) || ! strcmp ( option, "furni", true) ) {

		if(GetCharacterPointID(playerid) != -1) {

			if(DoesPlayerOwnPoint(playerid,GetCharacterPointID(playerid))) {

				if ( GetPointType ( GetCharacterPointID ( playerid ) ) != 1 ) { return SendServerMessage(playerid,"You can only add furniture to houses.",MSG_TYPE_ERROR); }
				if(GetFurnitureBuilderMode(playerid) != -1) { ResetFurnitureBuilderData(playerid); }
				inline cmds_FurnitureMain(pid,dialogid,response,listitem,string:inputtext[])
				{
					#pragma unused pid,dialogid,inputtext

					if(!response) { return 1; }

					switch(listitem)
					{
						case 0: //add
						{
							AddFurniture(playerid,GetCharacterPointID(playerid));
						}
						case 1: //edit
						{
							EditFurniture(playerid,GetCharacterPointID(playerid));
						}
						case 2: //remove
						{
							RemoveFurniture(playerid,GetCharacterPointID(playerid));
						}
					}
				}
				Dialog_ShowCallback(playerid,using inline cmds_FurnitureMain,DIALOG_STYLE_LIST,"Furniture Menu","Add Furniture\nEdit Furniture\nRemove Furniture","Select","Exit");
			}
			else return SendServerMessage(playerid,"You don't own this property.",MSG_TYPE_ERROR);
		}
		else return SendServerMessage(playerid,"You need to be inside a point.",MSG_TYPE_ERROR);
	}

	else if ( ! strcmp ( option, "fee" ) ) {
		for ( new i; i < MAX_POINTS; i ++ ) {
			if ( Point [ i ] [ point_id ] != -1 ) {
				
				if ( 
					IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_ext_x ],  Point [ i ] [ point_ext_y ], Point [ i ] [ point_ext_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int ] ||
					IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ]) {

					if ( Point [ i ] [ point_owner ] != Character [ playerid ] [ character_id ] ) {

						return SendServerMessage ( playerid, "You don't own this property.", MSG_TYPE_ERROR ) ;
					}

					if ( Point [ i ] [ point_type ] != POINT_TYPE_BIZ ) {

						return SendServerMessage ( playerid, "This point isn't a business.", MSG_TYPE_ERROR ) ;
					}

					inline SetupFeeDialog(pid, dialogid, response, listitem, string:inputtext[]) {
					    #pragma unused pid, dialogid, listitem, inputtext

						if(response) {

							if ( strval ( inputtext ) < 0 || strval ( inputtext ) > 99 ) {

								return SendServerMessage ( playerid, "Entrance fee can't be less than 0 cents or more than 99 cents.", MSG_TYPE_ERROR ) ;
							}

							mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_fee = '%d' WHERE point_id = '%d'", strval ( inputtext ), Point [ i ] [ point_id ] ) ;
							mysql_tquery ( mysql, query ) ;

							if(strval(inputtext) >= 1) { SendServerMessage(playerid,sprintf("You've set this point's entrance fee to %d %s.",strval(inputtext), (strval(inputtext) == 1) ? ("cent") : ("cents")),MSG_TYPE_INFO); }
							else if(!strval(inputtext)) { SendServerMessage(playerid,"You've removed this point's entrance fee.",MSG_TYPE_INFO); }

							Init_Points ( Point [ i ] [ point_id ] ) ;
						}

						return true ;
					}

					return Dialog_ShowCallback ( playerid, using inline SetupFeeDialog, DIALOG_STYLE_INPUT, "Fee setup", "Enter the amount you want to charge. (0-99 cents)", "Continue", "Exit" );
				}

				else continue ;
			}
		}
	}
	/*
	else if(!strcmp(option,"rentable",true)) {

		if(GetCharacterPointID(playerid) == -1) { return SendServerMessage(playerid,"You're not inside a point.",MSG_TYPE_ERROR); }

		new id = GetCharacterPointID(playerid);
		if(Point[id][point_type] == POINT_TYPE_HOUSE) {

			if(Point[id][point_owner] != Character[playerid][character_id]) { return SendServerMessage(playerid,"You don't own this property.",MSG_TYPE_ERROR); }
			if(!Point[id][point_rentable]) {

				Point[id][point_rentable] = 1;
				mysql_format(mysql,query,sizeof(query),"UPDATE points SET point_rentable = %d WHERE point_id = %d",Point[id][point_rentable],Point[id][point_id]);
				mysql_tquery(mysql,query);
				SendServerMessage(playerid,"Your house is now rentable.  Use /point [rent] to change the price.",MSG_TYPE_INFO);
			}
			else {

				Point[id][point_rentable] = 0;
				mysql_format(mysql,query,sizeof(query),"UPDATE points SET point_rentable = %d WHERE point_id = %d",Point[id][point_rentable],Point[id][point_id]);
				mysql_tquery(mysql,query);
				SendServerMessage(playerid,"Your house is no longer rentable.",MSG_TYPE_INFO);
			}
		}
		else { return SendServerMessage(playerid,"This is only for houses.",MSG_TYPE_ERROR); }
	}
	else if(!strcmp(option,"rent",true)) {

		if(GetCharacterPointID(playerid) == -1) { return SendServerMessage(playerid,"You're not inside a point.",MSG_TYPE_ERROR); }

		new id = GetCharacterPointID(playerid);
		if(Point[id][point_type] == POINT_TYPE_HOUSE) {

			if(Point[id][point_owner] != Character[playerid][character_id]) { return SendServerMessage(playerid,"You don't own this property.",MSG_TYPE_ERROR); }

			new dollars,cents;
			if(sscanf(params,"dD(0)",dollars,cents)) { return SendServerMessage(playerid,"/point rent [dollars] [optional:cents]",MSG_TYPE_ERROR); }
			if(dollars < 0) { return SendServerMessage(playerid,"You cannot set dollars to a negative amount.",MSG_TYPE_ERROR); }
			if(dollars > 5) { return SendServerMessage(playerid,"You cannot set rent higher than $5.00.",MSG_TYPE_ERROR); }
			if(dollars == 5 && cents > 0) { return SendServerMessage(playerid,"You cannot set rent higher than $5.00.",MSG_TYPE_ERROR); }
			if(cents < 0) { return SendServerMessage(playerid,"You cannot set cents to a negative amount.",MSG_TYPE_ERROR); }
			if(cents > 99) { return SendServerMessage(playerid,"You can't set cents over 99 cents.",MSG_TYPE_ERROR); }

			Point[id][point_rent_price] = dollars;
			Point[id][point_rent_change] = cents;

			mysql_format(mysql,query,sizeof(query),"UPDATE points SET point_rent_price = %d,point_rent_change = %d WHERE point_id = %d",Point[id][point_rent_price],Point[id][point_rent_change],Point[id][point_id]);
			mysql_tquery(mysql,query);

			SendServerMessage(playerid,sprintf("You've set your rent price to $%02d.%02d.",Point[id][point_rent_price],Point[id][point_rent_change]),MSG_TYPE_INFO);
		}
	}
	else if(!strcmp(option,"tenants",true)) {

		new list[256];

		inline TenantLookup() {

			new rows,fields;

			cache_get_data(rows,fields,mysql);

			if(rows) {


			}
		}
		//mysql_format(mysql,query,sizeof(query),"SELECT ")

		inline TenantList(pid,dialogid,response,listitem,string:inputtext[]) {

			#pragma unused pid,dialogid,response,listitem,inputtext
		}
		Dialog_ShowCallback(playerid,using inline TenantList,DIALOG_STYLE_MSGBOX,"Tenants List",list,"Exit","");
	}
	else if(!strcmp(option,"evict",true)) {

	}
	*/
	else if ( ! strcmp ( option, "collect" ) ) {
		for ( new i; i < MAX_POINTS; i ++ ) {
			if ( Point [ i ] [ point_id ] != -1 ) {

				if ( Point [ i ] [ point_type ] != POINT_TYPE_BIZ ) {

					return SendServerMessage ( playerid, "This point isn't a business.", MSG_TYPE_ERROR ) ;
				}

				
				if ( IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ]) {

					if ( Point [ i ] [ point_owner ] != Character [ playerid ] [ character_id ] ) {

						return SendServerMessage ( playerid, "You don't own this property.", MSG_TYPE_ERROR ) ;
					}

					SendServerMessage ( playerid, sprintf("You've recieved %s.%02d from your business till. It's been deposited in your bank.",IntegerWithDelimiter( Point [ i ] [ point_till ]),Point[i][point_till_change]), MSG_TYPE_INFO ) ;
					GiveCharacterMoney ( playerid, Point [ i ] [ point_till  ], MONEY_SLOT_BANK ) ;
					GiveCharacterChange(playerid,Point[i][point_till_change],MONEY_SLOT_BANK);

					mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_till = '0',point_till_change = '0' WHERE point_id = '%d'", Point [ i ] [ point_id ] ) ;
					mysql_tquery ( mysql, query ) ;

					Init_Points ( Point [ i ] [ point_id ] ) ;
				}

				else continue ;
			}
		}
	}

	else if ( ! strcmp ( option, "store" ) ) {

		if ( isnull ( soption ) ) {

			return SendServerMessage ( playerid, "/point store [money/weapon]", MSG_TYPE_ERROR ) ;
		}

		if ( ! strcmp ( soption, "money" ) ) { 

			if ( amount < 1 ) {

				return SendServerMessage ( playerid, "/point store money [amount] - amount can't be less than 1.", MSG_TYPE_ERROR ) ;
			}

			for ( new i; i < MAX_POINTS; i ++ ) {

				if ( Point [ i ] [ point_id ] != -1 ) {

					if ( IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ]) {

						if ( Point [ i ] [ point_owner ] != Character [ playerid ] [ character_id ] ) {

							return SendServerMessage ( playerid, "You don't own this property.", MSG_TYPE_ERROR ) ;
						}

						if ( Point [ i ] [ point_type ] != POINT_TYPE_HOUSE ) {

							return SendServerMessage ( playerid, "This point isn't a house.", MSG_TYPE_ERROR ) ;
						}

						if ( Character [ playerid ] [ character_handmoney ] < amount ) {

							return SendServerMessage ( playerid, sprintf("You don't have $%i to store in your house.", amount ), MSG_TYPE_ERROR ) ;
						}

						Point [ i ] [ point_till ] += amount ;
						TakeCharacterMoney ( playerid, amount, MONEY_SLOT_HAND ) ;

						WriteLog ( playerid, "point/store", sprintf ( "%s has stored $%s (%d) in their house. (point: %d, enumid: %d)", ReturnUserName ( playerid, false ), IntegerWithDelimiter ( amount ), amount, Point [ i ] [ point_id ], i )) ;

						mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_till = %d WHERE point_id = %d", Point [ i ] [ point_till ], Point [ i ] [ point_id ] ) ;
						mysql_tquery ( mysql, query ) ;

						Init_Points ( Point [ i ] [ point_id ] ) ;

						return SendServerMessage ( playerid, sprintf("You've stored $%s in your house storage.", IntegerWithDelimiter ( amount )), MSG_TYPE_ERROR ) ;
					}

					else continue ;
				}

				else continue ;
			}

			return SendServerMessage ( playerid, "You're not near a point you own.", MSG_TYPE_ERROR ) ;
		}

		else if ( ! strcmp ( soption, "weapon" ) ) {

			for ( new i; i < MAX_POINTS; i ++ ) {

				if ( Point [ i ] [ point_id ] != -1 ) {

					if ( IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ]) {

						if ( Point [ i ] [ point_owner ] != Character [ playerid ] [ character_id ] ) {

							return SendServerMessage ( playerid, "You don't own this property.", MSG_TYPE_ERROR ) ;
						}

						if ( Point [ i ] [ point_type ] != POINT_TYPE_HOUSE ) {

							return SendServerMessage ( playerid, "This point isn't a house.", MSG_TYPE_ERROR ) ;
						}

						if ( amount < 1 || amount > 2) {

							return SendServerMessage ( playerid, "/point store weapon [slot] - slot can't be less than 1 or more than 2.", MSG_TYPE_ERROR ) ;
						}

						if ( amount == 1 ) {

							if ( Point [ i ] [ point_weapon1] ) {

								return SendServerMessage ( playerid, "This slot already has a weapon stored.", MSG_TYPE_ERROR ) ;
							}

							if ( ! Character [ playerid ] [ character_handweapon ] ) {

								return SendServerMessage ( playerid, "You're not wearing a weapon which can be stored.", MSG_TYPE_ERROR ) ;
							}

							mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_weapon1 = %d, point_weapon1ammo = %d WHERE point_id = %d", 
								Character [ playerid ] [ character_handweapon ], Character [ playerid ] [ character_handammo ], Point [ i ] [ point_id ] ) ;

							mysql_tquery ( mysql, query ) ;

							Point [ i ] [ point_weapon1 ] 		= Character [ playerid ] [ character_handweapon ] ;
							Point [ i ] [ point_weapon1ammo ] 	= Character [ playerid ] [ character_handammo ] ;

							RemovePlayerWeapon ( playerid ) ;

							Init_Points ( Point [ i ] [ point_id ] ) ;

							return true ;
						}

						else if ( amount == 2 ) {
							if ( Point [ i ] [ point_weapon2] ) {

								return SendServerMessage ( playerid, "This slot already has a weapon stored.", MSG_TYPE_ERROR ) ;
							}

							if ( ! Character [ playerid ] [ character_handweapon ] ) {

								return SendServerMessage ( playerid, "You're not wearing a weapon which can be stored.", MSG_TYPE_ERROR ) ;
							}

							mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_weapon2 = %d, point_weapon2ammo = %d WHERE point_id = %d", 
								Character [ playerid ] [ character_handweapon ], Character [ playerid ] [ character_handammo ], Point [ i ] [ point_id ] ) ;

							mysql_tquery ( mysql, query ) ;

							Point [ i ] [ point_weapon2 ] 		= Character [ playerid ] [ character_handweapon ] ;
							Point [ i ] [ point_weapon2ammo ] 	= Character [ playerid ] [ character_handammo ] ;

							RemovePlayerWeapon ( playerid ) ;

							Init_Points ( Point [ i ] [ point_id ] ) ;

							return true ;
						}
			
						continue ;
					}

					else continue ;
				}

				else continue ;
			}

			return SendServerMessage ( playerid, "You're not near a point you own.", MSG_TYPE_ERROR ) ;
		}

		else return SendServerMessage ( playerid, "/point store [money/weapons] [amount]", MSG_TYPE_ERROR ) ;
	}	

	else if ( ! strcmp ( option, "take" ) ) {

		if ( isnull ( soption ) ) {

			return SendServerMessage ( playerid, "/point take [money/weapon]", MSG_TYPE_ERROR ) ;
		}

		if ( ! strcmp ( soption, "money" ) ) { 

			if ( amount < 1 ) {

				return SendServerMessage ( playerid, "/point take money [amount] - amount can't be less than 1.", MSG_TYPE_ERROR ) ;
			}

			for ( new i; i < MAX_POINTS; i ++ ) {

				if ( Point [ i ] [ point_id ] != -1 ) {

					if ( IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ]) {

						if ( Point [ i ] [ point_owner ] != Character [ playerid ] [ character_id ] ) {

							return SendServerMessage ( playerid, "You don't own this property.", MSG_TYPE_ERROR ) ;
						}

						if ( Point [ i ] [ point_type ] != POINT_TYPE_HOUSE ) {

							return SendServerMessage ( playerid, "This point isn't a house.", MSG_TYPE_ERROR ) ;
						}

						if ( Point [ i ] [ point_till ] < amount ) {

							return SendServerMessage ( playerid, sprintf("You don't have $%i stored in your house.", amount ), MSG_TYPE_ERROR ) ;
						}

						Point [ i ] [ point_till ] -= amount ;
						GiveCharacterMoney ( playerid, amount, MONEY_SLOT_HAND ) ;

						WriteLog ( playerid, "point/store", sprintf ( "%s has taken $%s (%d) from their house. (point: %d, enumid: %d)", ReturnUserName ( playerid, false ), IntegerWithDelimiter ( amount ), amount, Point [ i ] [ point_id ], i )) ;

						mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_till = %d WHERE point_id = %d", Point [ i ] [ point_till ], Point [ i ] [ point_id ] ) ;
						mysql_tquery ( mysql, query ) ;

						Init_Points ( Point [ i ] [ point_id ] ) ;

						return SendServerMessage ( playerid, sprintf("You've withdrew $%s from your house storage.", IntegerWithDelimiter ( amount )), MSG_TYPE_ERROR ) ;
					}

					else continue ;
				}

				else continue ;
			}

			return SendServerMessage ( playerid, "You're not near a point you own.", MSG_TYPE_ERROR ) ;
		}

		else if ( ! strcmp ( soption, "weapon" ) ) {

			for ( new i; i < MAX_POINTS; i ++ ) {

				if ( Point [ i ] [ point_id ] != -1 ) {

					if ( IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ]) {

						if ( Point [ i ] [ point_owner ] != Character [ playerid ] [ character_id ] ) {

							return SendServerMessage ( playerid, "You don't own this property.", MSG_TYPE_ERROR ) ;
						}

						if ( Point [ i ] [ point_type ] != POINT_TYPE_HOUSE ) {

							return SendServerMessage ( playerid, "This point isn't a house.", MSG_TYPE_ERROR ) ;
						}

						if ( amount < 1 || amount > 2) {

							return SendServerMessage ( playerid, "/point store weapon [slot] - slot can't be less than 1 or more than 2.", MSG_TYPE_ERROR ) ;
						}

						if ( amount == 1 ) {

							if ( ! Point [ i ] [ point_weapon1] ) {

								return SendServerMessage ( playerid, "This slot does not have a weapon stored..", MSG_TYPE_ERROR ) ;
							}

							if ( Character [ playerid ] [ character_handweapon ] ) {

								return SendServerMessage ( playerid, "You're already holding a weapon. Holster it first.", MSG_TYPE_ERROR ) ;
							}

							mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_weapon1 = 0, point_weapon1ammo = 0 WHERE point_id = %d", Point [ i ] [ point_id ] ) ;
							mysql_tquery ( mysql, query ) ;

							wep_GivePlayerWeapon ( playerid, Point [ i ] [ point_weapon1 ], Point [ i ] [ point_weapon1ammo ] ) ;

							Point [ i ] [ point_weapon1 ] 		= 0 ;
							Point [ i ] [ point_weapon1ammo ] 	= 0 ;

							Init_Points ( Point [ i ] [ point_id ] ) ;

							return true ;
						}

						else if ( amount == 2 ) {
							if ( ! Point [ i ] [ point_weapon2] ) {

								return SendServerMessage ( playerid, "This slot does not have a weapon stored.", MSG_TYPE_ERROR ) ;
							}

							if ( Character [ playerid ] [ character_handweapon ] ) {

								return SendServerMessage ( playerid, "You're not wearing a weapon which can be stored.", MSG_TYPE_ERROR ) ;
							}

							mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_weapon2 = 0, point_weapon2ammo = 0 WHERE point_id = %d",  Point [ i ] [ point_id ] ) ;
							mysql_tquery ( mysql, query ) ;

							wep_GivePlayerWeapon ( playerid, Point [ i ] [ point_weapon2 ], Point [ i ] [ point_weapon2ammo ] ) ;

							Point [ i ] [ point_weapon2 ] 		= 0 ;
							Point [ i ] [ point_weapon2ammo ] 	= 0 ;

							Init_Points ( Point [ i ] [ point_id ] ) ;

							return true ;
						}
			
						continue ;
					}

					else continue ;
				}

				else continue ;
			}

			return SendServerMessage ( playerid, "You're not near a point you own.", MSG_TYPE_ERROR ) ;
		}

		else return SendServerMessage ( playerid, "/point take [money/weapon] [amount]", MSG_TYPE_ERROR ) ;
	}	

	else if ( ! strcmp ( option, "storage" ) ) {

		if ( isnull ( soption ) ) {

			return SendServerMessage ( playerid, "/point storage [money/weapon]", MSG_TYPE_ERROR ) ;
		}

		if ( ! strcmp ( soption, "money" ) ) { 

			for ( new i; i < MAX_POINTS; i ++ ) {

				if ( Point [ i ] [ point_id ] != -1 ) {

					if ( IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ]) {

						if ( Point [ i ] [ point_owner ] != Character [ playerid ] [ character_id ] ) {

							return SendServerMessage ( playerid, "You don't own this property.", MSG_TYPE_ERROR ) ;
						}

						if ( Point [ i ] [ point_type ] != POINT_TYPE_HOUSE ) {

							return SendServerMessage ( playerid, "This point isn't a house.", MSG_TYPE_ERROR ) ;
						}

						return SendServerMessage ( playerid, sprintf("You have $%s stored in your house.", IntegerWithDelimiter ( Point [ i ] [ point_till ])), MSG_TYPE_WARN ) ;
					}

					else continue ;
				}

				else continue ;
			}

			return SendServerMessage ( playerid, "You're not near a point you own.", MSG_TYPE_ERROR ) ;
		}

		else if ( ! strcmp ( soption, "weapon" ) ) { 

			for ( new i; i < MAX_POINTS; i ++ ) {

				if ( Point [ i ] [ point_id ] != -1 ) {

					if ( IsPlayerInRangeOfPoint(playerid, 2.5, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ]) {

						if ( Point [ i ] [ point_owner ] != Character [ playerid ] [ character_id ] ) {

							return SendServerMessage ( playerid, "You don't own this property.", MSG_TYPE_ERROR ) ;
						}

						if ( Point [ i ] [ point_type ] != POINT_TYPE_HOUSE ) {

							return SendServerMessage ( playerid, "This point isn't a house.", MSG_TYPE_ERROR ) ;
						}

						SendClientMessage(playerid, COLOR_TAB0, sprintf("Point %d's weapons storage:", Point [ i ] [ point_id ] ) ) ;
						SendClientMessage(playerid, COLOR_TAB1, sprintf("[SLOT 1]: %s (%d ammo)", ReturnWeaponName (Point [ i ] [ point_weapon1 ]), Point [ i ] [ point_weapon1ammo ] ) ) ;
						return SendClientMessage(playerid, COLOR_TAB1, sprintf("[SLOT 2]: %s (%d ammo)", ReturnWeaponName (Point [ i ] [ point_weapon2 ]), Point [ i ] [ point_weapon2ammo ] ) ) ;
					}

					else continue ;
				}

				else continue ;
			}

			return SendServerMessage ( playerid, "You're not near a point you own.", MSG_TYPE_ERROR ) ;
		}

		return SendServerMessage ( playerid, "/point storage [money/weapon]", MSG_TYPE_ERROR ) ;
	}

	else if ( ! strcmp ( option, "sleep" ) ) {

		for ( new i; i < MAX_POINTS; i ++ ) {

			if ( Point [ i ] [ point_id ] != -1 ) {

				if ( IsPlayerInRangeOfPoint(playerid, 20.5, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ]) {

					if ( Point [ i ] [ point_owner ] != Character [ playerid ] [ character_id ] ) {

						return SendServerMessage ( playerid, "You don't own this property.", MSG_TYPE_ERROR ) ;
					}

					if ( Point [ i ] [ point_type ] != POINT_TYPE_HOUSE ) {

						return SendServerMessage ( playerid, "This point isn't a house.", MSG_TYPE_ERROR ) ;
					}

					switch ( IsPlayerSleepingInPoint [ playerid ] ) {

						case false: {

							TogglePlayerControllable ( playerid, 0 ) ;

							inline PointSleepMessage(pid, dialogid, response, listitem, string:inputtext[] ) { 
 								#pragma unused pid, dialogid, response, listitem, inputtext

 							}

 							Dialog_ShowCallback(playerid, using inline PointSleepMessage, DIALOG_STYLE_MSGBOX, "Point Sleep", "You are now sleeping ICly.\n\nYou will recieve half of your paycheck while sleeping along with recieving paychecks 25 percent slower.", "Exit" ) ;

							IsPlayerSleepingInPoint [ playerid ] = true ;
						}

						case true : {

							TogglePlayerControllable ( playerid, 1 ) ;

							IsPlayerSleepingInPoint [ playerid ] = false ;
						}
					}

					return true;

				}

				else continue; 
			}

			else continue ;
		}

		return SendServerMessage ( playerid, "You are not inside a house you own.", MSG_TYPE_ERROR ) ;

	}

	else return SendServerMessage ( playerid, "/point [buy, sell, lock, fee, collect, store, take, storage, sleep]", MSG_TYPE_INFO ) ;

	return true ;
}

CMD:apoint ( playerid, params [] ) {

	new option [ 32 ], setting, extra [ 32 ] ;

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < ADVANCED_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a advanced moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	if ( sscanf ( params, "s[32]I(-1)S()[32]", option, setting, extra)) {

		SendServerMessage ( playerid, "/apoint [param] [setting] [extra: optional]", MSG_TYPE_ERROR ) ;
		SendServerMessage ( playerid, "PARAMS: [info, create, delete, sell, int, move, name, type, price, biz, lock, goto, inactive, clearinactive, owner, fee]", MSG_TYPE_WARN) ;
		return SendServerMessage ( playerid, "To see what additional info, type /apoint info. It will show the biztypes and types.", MSG_TYPE_INFO ) ;
	}

	new Float: x, Float: y, Float: z, query [ 256 ] ;
	GetPlayerPos ( playerid, x, y, z ) ;

	if ( ! strcmp ( option, "info" ) ) {
		SendServerMessage ( playerid, "[Point Types]: 0: Passpoint, 1: House, 2: Business", MSG_TYPE_INFO ) ;
		SendServerMessage ( playerid, "[Biz Types]: 0: General store, 1: Gun store, 2: Clothing store, 3: Barber, 4: Liquor store, 5: Saloon 6: Hunting store", MSG_TYPE_INFO ) ;
		SendServerMessage ( playerid, "[Biz Types]: 7: Bank, 8: Postal Office, 9: Sheriff's Office, 10: Blacksmith, 11: Stablemaster", MSG_TYPE_INFO ) ;

		return true ;
	}

	if ( ! strcmp ( option, "create" )) {

		if ( ! IsPlayerManager ( playerid ) ) {

			return SendServerMessage ( playerid, "Nope.", MSG_TYPE_ERROR ) ;
		}

		if ( setting < 0 || setting > 2 ) {

			return SendServerMessage ( playerid, "Setting can't be lower than 0 or higher than 2.", MSG_TYPE_ERROR ) ;
		}

		CreatePoint ( playerid, setting, x, y, z ) ;

		return true ;
	}

	else if ( ! strcmp ( option, "int" )) {

		if ( ! IsPlayerManager ( playerid ) ) {

			return SendServerMessage ( playerid, "Nope.", MSG_TYPE_ERROR ) ;
		}

		if ( setting == -1 ) {

			return SendServerMessage ( playerid, "/ap int [pointid]", MSG_TYPE_ERROR ) ;
		}

		if ( Point [ setting ] [ point_id ] == -1 ) {

			return SendServerMessage ( playerid, "Invalid point ID. Please select a proper ID.", MSG_TYPE_ERROR ) ;
		}

		Point [ setting ] [ point_int_x ] = x ;
		Point [ setting ] [ point_int_y ] = y ;
		Point [ setting ] [ point_int_z ] = z ;

		mysql_format(mysql, query, sizeof ( query ), "UPDATE points SET point_int_x = '%f', point_int_y = '%f', point_int_z = '%f' WHERE point_id = '%d'",
			Point [ setting ] [ point_int_x ], Point [ setting ] [ point_int_y ], Point [ setting ] [ point_int_z ], Point [ setting ] [ point_id ]  ) ;

		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( playerid, sprintf("You've set point ID %d's interior position to yours.", setting), MSG_TYPE_INFO ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has updated point %d's interior to their location.", ReturnUserName ( playerid, true ), playerid, setting ), MOD_WARNING_LOW ) ;
		////OldLog ( playerid, "mod/points", sprintf("%s (%d) has updated point %d's interior to their location.", ReturnUserName ( playerid, true ), playerid, setting )) ;

		if ( Point [ setting ] [ point_type ] == POINT_TYPE_HOUSE || Point [ setting ] [ point_type ] == POINT_TYPE_BIZ ) {

			new intvalues = 1 ;
			
			intvalues += setting ;

			Point [ setting ] [ point_int_vw ] = GetPlayerVirtualWorld ( playerid ) + intvalues ;
			Point [ setting ] [ point_int_int ] = GetPlayerInterior ( playerid ) ;

			mysql_format(mysql, query, sizeof ( query ), "UPDATE points SET point_int_vw = %d, point_int_int = %d WHERE point_id = '%d'",
				Point [ setting ] [ point_int_vw ], Point [ setting ] [ point_int_int ], Point [ setting ] [ point_id ]  ) ;

			mysql_tquery ( mysql, query ) ;

			SendServerMessage ( playerid, 
				sprintf("Based on the point's type, the interior and virtual world has been updated accordingly. (%d:%d)", Point [ setting ] [ point_int_vw ], Point [ setting ] [ point_int_int ]), 
					MSG_TYPE_INFO ) ;

			return true ;
		}
 	}

	else if ( ! strcmp (option, "move" ) ) {


		if ( ! IsPlayerManager ( playerid ) ) {

			return SendServerMessage ( playerid, "Nope.", MSG_TYPE_ERROR ) ;
		}

		if ( setting == -1 ) {

			return SendServerMessage ( playerid, "/ap move [pointid]", MSG_TYPE_ERROR ) ;
		}


		if ( Point [ setting ] [ point_id ] == -1 ) {

			return SendServerMessage ( playerid, "Invalid point ID. Please select a proper ID.", MSG_TYPE_ERROR ) ;
		}

		Point [ setting ] [ point_ext_x ] = x ;
		Point [ setting ] [ point_ext_y ] = y ;
		Point [ setting ] [ point_ext_z ] = z ;

		mysql_format(mysql, query, sizeof ( query ), "UPDATE points SET point_ext_x = '%f', point_ext_y = '%f', point_ext_z = '%f' WHERE point_id = '%d'",
			Point [ setting ] [ point_ext_x ], Point [ setting ] [ point_ext_y ], Point [ setting ] [ point_ext_z ], Point [ setting ] [ point_id ]  ) ;

		mysql_tquery ( mysql, query ) ;

		Point [ setting ] [ point_vw ] = GetPlayerVirtualWorld(playerid) ;
		Point [ setting ] [ point_int ] = GetPlayerInterior( playerid ) ;

		mysql_format(mysql, query, sizeof ( query ), "UPDATE points SET point_vw = %d, point_int = %d WHERE point_id = '%d'",
			Point [ setting ] [ point_vw ], Point [ setting ] [ point_int ], Point [ setting ] [ point_id ]  ) ;

		mysql_tquery ( mysql, query ) ;

		SendServerMessage ( playerid, sprintf("You've moved point ID %d to your location.", setting), MSG_TYPE_INFO ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has moved point %d to their location.", ReturnUserName ( playerid, true ), playerid, setting ), MOD_WARNING_LOW ) ;
		////OldLog ( playerid, "mod/points", sprintf("%s (%d) has moved point %d to their location.", ReturnUserName ( playerid, true ), playerid, setting )) ;

		Init_Points ( Point [ setting ] [ point_id ] ) ;
	}

	else if ( ! strcmp (option, "name" ) ) {


		if ( setting == -1 ) {

			return SendServerMessage ( playerid, "/ap name [pointid]", MSG_TYPE_ERROR ) ;
		}

		if ( Point [ setting ] [ point_id ] == -1 ) {

			return SendServerMessage ( playerid, "Invalid point ID. Please select a proper ID.", MSG_TYPE_ERROR ) ;
		}

		Point [ setting ] [ point_name ] = extra ;

		mysql_format(mysql, query, sizeof ( query ), "UPDATE points SET point_name = '%e' WHERE point_id = %d",
			Point [ setting ] [ point_name ], Point [ setting ] [ point_id ]  ) ;

		mysql_tquery ( mysql, query ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has renamed point ID %d to %s.", ReturnUserName ( playerid, true ), playerid,  setting, Point [ setting ] [ point_name ]  ), MOD_WARNING_LOW ) ;
		//OldLog ( playerid, "mod/points", sprintf(" %s (%d) has renamed point ID %d to %s.", ReturnUserName ( playerid, true ), playerid, setting, Point [ setting ] [ point_id ] )) ;

		Init_Points ( Point [ setting ] [ point_id ] ) ;
	}

	else if ( ! strcmp (option, "type" ) ) {

		if ( ! IsPlayerManager ( playerid ) ) {

			return SendServerMessage ( playerid, "Nope.", MSG_TYPE_ERROR ) ;
		}

		if ( setting == -1 ) {


			return SendServerMessage ( playerid, "/ap type [pointid] [type]", MSG_TYPE_ERROR ) ;
		}

		if ( Point [ setting ] [ point_id ] == -1 ) {

			return SendServerMessage ( playerid, "Invalid point ID. Please select a proper ID.", MSG_TYPE_ERROR ) ;
		}

		new type = strval ( extra ) ;

		if ( type < 0 || type > 2 ) {

			return SendServerMessage ( playerid, "Type can't be less than 0 or higher than 2. Use /point biztype for biz types.", MSG_TYPE_ERROR ) ;
		}

		Point [ setting ] [ point_type ] = type ;

		mysql_format(mysql, query, sizeof ( query ), "UPDATE points SET point_type = '%d' WHERE point_id = %d",
			type, Point [ setting ] [ point_id ]  ) ;

		mysql_tquery ( mysql, query ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has changed point ID %d's type to %d.", ReturnUserName ( playerid, true ), playerid, setting, Point [ setting ] [ point_type ] ), MOD_WARNING_LOW ) ;
		//OldLog ( playerid, "mod/points", sprintf(" %s (%d) has changed point ID %d's type to %d.", ReturnUserName ( playerid, true ), playerid, setting, Point [ setting ] [ point_type ] )) ;

		Init_Points ( Point [ setting ] [ point_id ] ) ;
	}

	else if ( ! strcmp (option, "sell" ) ) {


		if ( ! IsPlayerManager ( playerid ) ) {

			return SendServerMessage ( playerid, "Nope.", MSG_TYPE_ERROR ) ;
		}

		if ( setting == -1 ) {

			return SendServerMessage ( playerid, "/ap sell [pointid]", MSG_TYPE_ERROR ) ;
		}

		if ( Point [ setting ] [ point_id ] == -1 ) {

			return SendServerMessage ( playerid, "Invalid point ID. Please select a proper ID.", MSG_TYPE_ERROR ) ;
		}

		Point [ setting ] [ point_owner ] = 0 ;

		mysql_format(mysql, query, sizeof ( query ), "UPDATE points SET point_owner = '-1', point_till = '0', point_till_change = '0', point_weapon1 = '0', point_weapon1ammo = '0', point_weapon2 = '0', point_weapon2ammo = '0' WHERE point_id = '%d'",
			Point [ setting ] [ point_id ]  ) ;

		mysql_tquery ( mysql, query ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) sold point ID %d.", ReturnUserName ( playerid, true ), playerid, setting ), MOD_WARNING_HIGH ) ;
		//OldLog ( playerid, "mod/points", sprintf("%s (%d) sold point ID %d.", ReturnUserName ( playerid, true ), playerid, setting )) ;

		Init_Points ( Point [ setting ] [ point_id ] ) ;
	}

	else if ( ! strcmp (option, "price" ) ) {


		if ( ! IsPlayerManager ( playerid ) ) {

			return SendServerMessage ( playerid, "Nope.", MSG_TYPE_ERROR ) ;
		}

		if ( setting == -1 ) {

			return SendServerMessage ( playerid, "/ap price [pointid] [price]", MSG_TYPE_ERROR ) ;
		}

		if ( Point [ setting ] [ point_id ] == -1 ) {

			return SendServerMessage ( playerid, "Invalid point ID. Please select a proper ID.", MSG_TYPE_ERROR ) ;
		}

		new price = strval ( extra ) ;

		Point [ setting ] [ point_price ] = price ;

		mysql_format(mysql, query, sizeof ( query ), "UPDATE points SET point_price = '%d' WHERE point_id = %d",
			price, Point [ setting ] [ point_id ]  ) ;

		mysql_tquery ( mysql, query ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) set point ID %d's price to %d.", ReturnUserName ( playerid, true ), playerid, setting, price ), MOD_WARNING_MED ) ;
		//OldLog (playerid,  "mod/points", sprintf(" %s (%d) set point ID %d's price to %d.", ReturnUserName ( playerid, true ), playerid, setting, price )) ;

		Init_Points ( Point [ setting ] [ point_id ] ) ;
	}

	else if ( ! strcmp (option, "biz" ) ) {


		if ( ! IsPlayerManager ( playerid ) ) {

			return SendServerMessage ( playerid, "Nope.", MSG_TYPE_ERROR ) ;
		}

		if ( setting == -1 ) {

			return SendServerMessage ( playerid, "/ap biz [pointid] [biz-type]", MSG_TYPE_ERROR ) ;
		}

		if ( Point [ setting ] [ point_id ] == -1 ) {

			return SendServerMessage ( playerid, "Invalid point ID. Please select a proper ID.", MSG_TYPE_ERROR ) ;
		}

		new biztype = strval ( extra ) ;

		Point [ setting ] [ point_biztype ] = biztype ;

		mysql_format(mysql, query, sizeof ( query ), "UPDATE points SET point_biztype = '%d' WHERE point_id = %d",
			biztype, Point [ setting ] [ point_id ]  ) ;

		mysql_tquery ( mysql, query ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) set point ID %d's business type %d.", ReturnUserName ( playerid, true ), playerid, setting, biztype ), MOD_WARNING_LOW ) ;
		//OldLog ( playerid, "mod/points", sprintf(" %s (%d) set point ID %d's business type %d.", ReturnUserName ( playerid, true ), playerid, setting, biztype )) ;

		Init_Points ( Point [ setting ] [ point_id ] ) ;
	}

	else if ( ! strcmp (option, "delete" ) ) {


		if ( ! IsPlayerManager ( playerid ) ) {

			return SendServerMessage ( playerid, "Nope.", MSG_TYPE_ERROR ) ;
		}

		if ( setting == -1 ) {

			return SendServerMessage ( playerid, "/ap delete [pointid]", MSG_TYPE_ERROR ) ;
		}

		if ( Point [ setting ] [ point_id ] == -1 ) {

			return SendServerMessage ( playerid, "Invalid point ID. Please select a proper ID.", MSG_TYPE_ERROR ) ;
		}

		mysql_format(mysql, query, sizeof ( query ), "DELETE FROM `points`  WHERE point_id = %d", Point [ setting ] [ point_id ]  ) ;

		mysql_tquery ( mysql, query ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has deleted point ID %d.", ReturnUserName ( playerid, true ), playerid, setting ), MOD_WARNING_HIGH ) ;
		//OldLog ( playerid, "mod/points", sprintf("%s (%d) has deleted point ID %d.", ReturnUserName ( playerid, true ), playerid, setting )) ;

		Init_Points ( Point [ setting ] [ point_id ] ) ;
	}

	else if ( ! strcmp ( option, "lock" ) ) {

		if ( setting == -1 ) {

			return SendServerMessage ( playerid, "/ap lock [pointid]", MSG_TYPE_ERROR ) ;
		}

		if ( Point [ setting ] [ point_id ] == -1 ) {

			return SendServerMessage ( playerid, "Invalid point ID. Please select a proper ID.", MSG_TYPE_ERROR ) ;
		}

		if ( ! Point [ setting ] [ point_locked ] ) {

			Point [ setting ] [ point_locked ] = true ;

			SendServerMessage ( playerid, "You've locked the door of your entrance.", MSG_TYPE_INFO ) ;
			SendModeratorWarning ( sprintf("[STAFF] %s (%d) has locked point ID %d.", ReturnUserName ( playerid, true ), playerid, setting ), MOD_WARNING_MED ) ;
			//OldLog ( playerid, "mod/points", sprintf("%s (%d) has locked point ID %d.", ReturnUserName ( playerid, true ), playerid, setting )) ;
		}

		else if ( Point [ setting ] [ point_locked ] ) { 

			Point [ setting ] [ point_locked ] = false ;

			SendServerMessage ( playerid, "You've unlocked the door of your entrance.", MSG_TYPE_INFO ) ;
			SendModeratorWarning ( sprintf("[STAFF] %s (%d) has unlocked point ID %d.", ReturnUserName ( playerid, true ), playerid, setting ), MOD_WARNING_MED ) ;
			//OldLog ( playerid, "mod/points", sprintf("%s (%d) has unlocked point ID %d.", ReturnUserName ( playerid, true ), playerid, setting )) ;
		}

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_locked = '%d' WHERE point_id = '%d'", Point [ setting ] [ point_locked ], Point [ setting ] [ point_id ] ) ;
		mysql_tquery ( mysql, query ) ;
	}

	else if ( ! strcmp ( option, "goto" ) ) {
		
		if ( setting == -1 ) {

			return SendServerMessage ( playerid, "/ap goto [pointid]", MSG_TYPE_ERROR ) ;
		}

		if ( Point [ setting ] [ point_id ] == -1 ) {

			return SendServerMessage ( playerid, "Invalid point ID. Please select a proper ID.", MSG_TYPE_ERROR ) ;
		}

		ac_SetPlayerPos ( playerid, Point [ setting ] [ point_ext_x ], Point [ setting ] [ point_ext_y ], Point [ setting ] [ point_ext_z ]) ;
		SetPlayerInterior ( playerid, Point [ setting ] [ point_int ] ) ;
		SetPlayerVirtualWorld(playerid, Point [ setting ] [ point_vw]) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has teleported to point ID %d.", ReturnUserName ( playerid, true ), playerid, setting ), MOD_WARNING_LOW ) ;
		//OldLog ( playerid, "mod/points", sprintf("%s (%d) has teleported to point ID %d.", ReturnUserName ( playerid, true ), playerid, setting )) ;

	}

	else if ( ! strcmp ( option, "inactive" ) ) {

		SendClientMessage(playerid, COLOR_YELLOW, "Inactive points:" ) ;

		new rows [ 3 ], fields [ 3 ] ;
		inline CheckPointOwners() {

			cache_get_data ( rows [ 0 ], fields [ 0 ], mysql ) ;

			if ( rows [ 0 ] ) {

				for ( new i, j = rows [ 0 ] ; i < j; i++ ) {

					new pointid, pointname[32], pointowner;

					pointid = cache_get_field_int ( i, "point_id" ) ;
					cache_get_field_content ( i, "point_name", pointname, mysql, 32 ) ;
					pointowner = cache_get_field_int ( i, "point_owner" ) ;

					inline PlayerCharacterCheck() {

						cache_get_data ( rows [ 1 ], fields [ 1 ], mysql ) ;

						if ( rows [ 1 ] ) {

							new id, name[MAX_PLAYER_NAME];

							id = cache_get_field_int (0, "account_id" ) ;
							cache_get_field_content(0, "character_name", name, mysql, MAX_PLAYER_NAME ) ; 

							inline PlayerInactiveCheck() {

								cache_get_data ( rows [ 2 ], fields [ 2 ], mysql ) ;

								if ( rows [ 2 ] ) {

									new accname[MAX_PLAYER_NAME],timestamp;

									cache_get_field_content(0,"account_name", accname, mysql, MAX_PLAYER_NAME ) ;
									timestamp = cache_get_field_int (0, "account_lastlogin");

									if ( gettime() - 604800 > timestamp ) {

										SendServerMessage ( playerid, sprintf("[%d] %s - Owner: %s (%s)", pointid, pointname, name, accname), MSG_TYPE_INFO ) ;
									}

									else continue;
								}
							}
							mysql_format ( mysql, query, sizeof ( query ), "SELECT account_name,account_lastlogin FROM master_accounts WHERE account_id = %d", id) ;
							mysql_tquery_inline ( mysql, query, using inline PlayerInactiveCheck, "");
						}
					}
					mysql_format ( mysql, query, sizeof ( query ), "SELECT account_id, character_name FROM characters WHERE character_id = %d", pointowner ) ;
					mysql_tquery_inline ( mysql, query, using inline PlayerCharacterCheck, "");
				}

				defer DelayInactiveCheck(playerid, rows [ 0 ], 0) ;
			}
		}

		mysql_tquery_inline(mysql, "SELECT point_id, point_name, point_owner FROM points WHERE point_owner != -1", using inline CheckPointOwners, "");

		return true ;
	}

	else if ( ! strcmp ( option, "clearinactive" ) ) {

		inline ClearInactivePointsWarning(pid, dialogid, response, listitem, string:inputtext[]) {
			#pragma unused pid, dialogid, listitem, inputtext

			if ( response ) {

				new rows [ 3 ], fields [ 3 ] ;

				inline clear_CheckPointOwners() {

					cache_get_data ( rows [ 0 ], fields [ 0 ], mysql ) ;

					if ( rows [ 0 ] ) {

						for ( new i, j = rows [ 0 ] ; i < j; i++ ) {

							new pointid, pointowner ;

							pointid = cache_get_field_int ( i, "point_id" ) ;
							pointowner = cache_get_field_int ( i, "point_owner" ) ;

							inline clear_PlayerCharacterCheck() {

								cache_get_data ( rows [ 1 ], fields [ 1 ], mysql ) ;

								if ( rows [ 1 ] ) {

									new id ;

									id = cache_get_field_int (0, "account_id" ) ;

									inline clear_PlayerInactiveCheck() {

										cache_get_data ( rows [ 2 ], fields [ 2 ], mysql ) ;

										if ( rows [ 2 ] ) {

											new timestamp;

											timestamp = cache_get_field_int (0, "account_lastlogin");

											if ( gettime() - 604800 > timestamp ) {

												mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_owner = '-1', point_till = '0', point_till_change = '0', point_weapon1 = '0', point_weapon1ammo = '0', point_weapon2 = '0', point_weapon2ammo = '0' WHERE point_id = '%d'", pointid ) ;
												//mysql_tquery ( mysql, query ) ;
												//SendServerMessage(playerid,sprintf("[%i]: %i removed.",pointid,pointowner),MSG_TYPE_INFO);
											}
											else continue;
										}
									}
									mysql_format ( mysql, query, sizeof ( query ), "SELECT account_lastlogin FROM master_accounts WHERE account_id = %d", id) ;
									mysql_tquery_inline ( mysql, query, using inline clear_PlayerInactiveCheck, "");
								}
							}
							mysql_format ( mysql, query, sizeof ( query ), "SELECT account_id FROM characters WHERE character_id = %d", pointowner ) ;
							mysql_tquery_inline ( mysql, query, using inline clear_PlayerCharacterCheck, "");
						}

						defer DelayInactiveCheck(playerid, rows [ 0 ], 1) ;
					}

					else {

						return SendServerMessage ( playerid, "There are no inactive points to clear.", MSG_TYPE_ERROR ) ;
					}
				}

				mysql_tquery_inline ( mysql, "SELECT point_id, point_owner FROM points WHERE point_owner != -1", using inline clear_CheckPointOwners, "");
			}

			else return true ;
		}

		Dialog_ShowCallback ( playerid, using inline ClearInactivePointsWarning, DIALOG_STYLE_MSGBOX, "{C23030}WARNING", "{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\nYou're about to clear all inactive points.\nIf you completely sure to clear all inactive points, press \"Proceed\".", "{C23030}Proceed", "Cancel" ) ;

		return true ;
	}

	else if ( ! strcmp ( option, "owner" ) ) {

		if ( setting == -1 ) {

			return SendServerMessage ( playerid, "/ap owner [pointid]", MSG_TYPE_ERROR ) ;
		}

		if ( Point [ setting ] [ point_id ] == -1 ) {

			return SendServerMessage ( playerid, "Invalid point ID. Please select a proper ID.", MSG_TYPE_ERROR ) ;
		}

		new rows, fields;
		inline CheckPointOwner() {

			cache_get_data ( rows, fields, mysql ) ;

			if ( rows ) {

				for ( new i; i<rows; i++ ) {

					new pointowner = cache_get_field_int ( i, "point_owner" ) ;

					inline OwnerNamePull() {

						cache_get_data ( rows, fields, mysql ) ;

						if ( rows ) {

							new accid, charid, name[MAX_PLAYER_NAME];

							accid = cache_get_field_int (0, "account_id" ) ;
							charid = cache_get_field_int (0, "character_id" ) ;

							cache_get_field_content(0, "character_name", name, mysql, MAX_PLAYER_NAME ) ; 

							SendServerMessage ( playerid, sprintf("Point %d is owned by %s [char %d, ma %d ]", setting, name, charid, accid), MSG_TYPE_WARN ) ;
						}

						else continue;
					}

					mysql_format ( mysql, query, sizeof ( query ), "SELECT account_id, character_id, character_name FROM characters WHERE character_id = %d", pointowner ) ;
					mysql_tquery_inline ( mysql, query, using inline OwnerNamePull, "");

					return true ;
				}
			}

			else if ( ! rows ) {

				return SendServerMessage ( playerid, "No players own a business.", MSG_TYPE_ERROR ) ;
			}

			return SendClientMessage(playerid, -1, "No inactive points!" ) ;
		}

		mysql_format(mysql, query, sizeof(query), "SELECT point_owner FROM points WHERE point_id = %d", Point [ setting ] [ point_id ]  ) ;
		mysql_tquery_inline(mysql, query, using inline CheckPointOwner, "");
	}


	else if ( ! strcmp ( option, "fee" ) ) {

		if ( ! IsPlayerManager ( playerid ) ) {

			return SendServerMessage ( playerid, "Nope.", MSG_TYPE_ERROR ) ;
		}

		if ( setting == -1 ) {

			return SendServerMessage ( playerid, "/ap fee [pointid] [fee]", MSG_TYPE_ERROR ) ;
		}

		if ( Point [ setting ] [ point_id ] == -1 ) {

			return SendServerMessage ( playerid, "Invalid point ID. Please select a proper ID.", MSG_TYPE_ERROR ) ;
		}

		new fee = strval ( extra ) ;

		Point [ setting ] [ point_fee ] = fee ;

		mysql_format(mysql, query, sizeof ( query ), "UPDATE points SET point_fee = '%d' WHERE point_id = %d",
			fee, Point [ setting ] [ point_id ]  ) ;

		mysql_tquery ( mysql, query ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) set point ID %d's fee to %d.", ReturnUserName ( playerid, true ), playerid, setting, fee ), MOD_WARNING_MED ) ;

		Init_Points ( Point [ setting ] [ point_id ] ) ;
	}

	else {

		SendServerMessage ( playerid, "/apoint [param] [setting] [extra: optional]", MSG_TYPE_ERROR ) ;
		SendServerMessage ( playerid, "PARAMS: [info, create, delete, sell, int, move, name, type, price, biz, lock, goto, inactive, clearinactive, owner, fee]", MSG_TYPE_WARN) ;
		return SendServerMessage ( playerid, "To see what additional info, type /apoint info. It will show the biztypes and types.", MSG_TYPE_INFO ) ;
	}

	return true ;
}

CMD:mypoints ( playerid, params [] ) {

	SendServerMessage ( playerid, "Your owned points:", MSG_TYPE_WARN ) ;

	new count ;

	for ( new i; i < MAX_POINTS; i ++ ) {

		if ( Point [ i ] [ point_id ] == -1 ) {

			continue ;
		}

		if ( Point [ i ] [ point_owner ] == Character [ playerid ] [ character_id ] ) {

			count ++ ;

			SendClientMessage(playerid, 0xDEDEDEFF, sprintf("(%d) %s [DB: %d]", i, Point [ i ] [ point_name ], Point [ i ] [ point_id ] ) ) ;

			continue ;
		}

		else continue ;
	}


	if ( ! count ) {

		return SendServerMessage ( playerid, "You have no points.", MSG_TYPE_ERROR ) ;
	}

	return true ;
}

timer DelayInactiveCheck[1000](playerid, total, clear) {

	if ( ! clear ) {

		SendServerMessage ( playerid, sprintf("%i total inactive points.", total ), MSG_TYPE_INFO ) ;
	}

	else {

		SendServerMessage ( playerid, sprintf("%i inactive points cleared.", total ), MSG_TYPE_INFO ) ;
		Init_Points ( ) ;
	}

	return true ;
}