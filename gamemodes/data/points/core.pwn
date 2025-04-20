/*


	BLACKSMITH STORE:

	- Bucket
	- Hammer
	- Pickaxe

	HUNTING STORE:

	 - Hunting Knife

	LIQUOR STORE:

	 - Equipable bottles, supporting every model. (can be equipped and unequipped)

	GENERAL STORE:

	 - Pack of cigarettes (rolled, pre-rolled) and pack of cigars
	( Both of these should offer the appropiate object )

	GUN STORE: 
	(limit purchases for weapon permit ppl)

	- Desert Eagle
	- Shotgun
	- Sawed off Shotgun
	- Rifle
	- Scoped Rifle
*/
#define MAX_FURNITURE_NAME (36)
#define MAX_FURNITURE_LIMIT (100)

enum
{
	FURNI_BUY,
	FURNI_EDIT,
	FURNI_EDIT_TEXTURE,
	FURNI_DELETE
}

enum { // biz types
	POINT_TYPE_GEN_STORE = 0,
	POINT_TYPE_GUN_STORE = 1,
	POINT_TYPE_CLOTHING,
	POINT_TYPE_BARBER,
	POINT_TYPE_LIQUOR,
	POINT_TYPE_SALOON,
	POINT_TYPE_HUNTING,
	POINT_TYPE_BANK,
	POINT_TYPE_POSTAL,
	POINT_TYPE_SHERIFF,
	POINT_TYPE_BLACKSMITH,
	POINT_TYPE_STABLEMASTER
} ;

new CharacterPointID[MAX_PLAYERS];

#include "data/points/func/data.pwn"
#include "data/points/func/man.pwn"
#include "data/points/telegram/func/data.pwn"
#include "data/points/func/misc.pwn"

#include "data/points/furniture/data.pwn"
#include "data/points/furniture/func.pwn"
#include "data/points/furniture/utils.pwn"

#include "data/points/func/buy/skins.pwn"

public OnPlayerConnect(playerid)
{
	CharacterPointID[playerid] = -1;
	#if defined points_OnPlayerConnect
		return points_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect points_OnPlayerConnect
#if defined points_OnPlayerConnect
	forward points_OnPlayerConnect(playerid);
#endif

GetPointExteriorPosition(pointid,&Float:x,&Float:y,&Float:z) {

	if(pointid != -1) {

		x = Point[pointid][point_ext_x];
		y = Point[pointid][point_ext_y];
		z = Point[pointid][point_ext_z];
		return true;
	}
	return false;
}

GetCharacterPointID(playerid) return CharacterPointID[playerid];
SetCharacterPointID(playerid,pointid) {

	CharacterPointID[playerid] = pointid;
	return true;
}
ResetCharacterPointID(playerid) {

	CharacterPointID[playerid] = -1;
	return true;
}

DoesPlayerOwnPoint(playerid,pointid) {

	return (Point[pointid][point_owner] == Character[playerid][character_id]) ? (true) : (false);
}

GetPointType(pointid) {

	return Point[pointid][point_type];
}

GetPlayerOwnedPoints ( playerid, type = -1 ) {
	new count = 0 ;

	switch ( type ) {

		case -1: {

			for ( new i; i < MAX_POINTS; i ++ ) {

				if ( Point [ i ] [ point_id ] != -1 ) {

					if ( Point [ i ] [ point_owner ] == Character [ playerid ] [ character_id ] ) {

						count ++ ;
					}

					else continue ;
				}

				else continue ;
			}
		}

		case POINT_TYPE_HOUSE: {

			for ( new i; i < MAX_POINTS; i ++ ) {

				if ( Point [ i ] [ point_id ] != -1 ) {

					if ( Point [ i ] [ point_type ] == POINT_TYPE_HOUSE ) {

						if ( Point [ i ] [ point_owner ] == Character [ playerid ] [ character_id ] ) {

							count ++ ;
						}

						else continue;
					}

					else continue ;
				}

				else continue ;
			}
		}

		case POINT_TYPE_BIZ: {

			for ( new i; i < MAX_POINTS; i ++ ) {

				if ( Point [ i ] [ point_id ] != -1 ) {

					if ( Point [ i ] [ point_type ] == POINT_TYPE_BIZ ) {

						if ( Point [ i ] [ point_owner ] == Character [ playerid ] [ character_id ] ) {

							count ++ ;
						}

						else continue;
					}

					else continue ;
				}

				else continue ;
			}
		}
	}

	return count ;
}


IsPlayerNearPoint(playerid,Float:distance) {

	for(new i; i < MAX_POINTS; i++) {

		if(Point[i][point_id] != -1) {

			if(IsPlayerInRangeOfPoint(playerid,distance,Point[i][point_ext_x],Point[i][point_ext_y],Point[i][point_ext_z])) {

				return true;
			}
			else if(IsPlayerInRangeOfPoint(playerid,distance,Point[i][point_int_x],Point[i][point_int_y],Point[i][point_int_z])) {

				return true;
			}
			else continue;
		}
		else continue;
	}
	return false;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

	if ( newkeys & KEY_CTRL_BACK ) {

		if ( IsPlayerRidingHorse [ playerid ] ) {

			return SendServerMessage ( playerid, "You can't enter a business whilst being on a horse.", MSG_TYPE_ERROR ) ;
		}

		if ( Character [ playerid ] [ character_prison ] ) {

			return SendServerMessage ( playerid, "You can't leave a building when you're in prison.", MSG_TYPE_ERROR ) ;
		}

		new query [ 256 ] ; 

		if ( GetPlayerInterior ( playerid == 0 ) || GetPlayerVirtualWorld(playerid) == 0 ) {

			ResetCharacterPointID(playerid);
		}

		if(GetCharacterPointID(playerid) == -1) {

			for ( new i; i < MAX_POINTS; i ++ ) {
				if ( Point [ i ] [ point_id ] != -1 ) {
					if ( IsPlayerInRangeOfPoint(playerid, 1.5, Point [ i ] [ point_ext_x ],  Point [ i ] [ point_ext_y ], Point [ i ] [ point_ext_z ] ) && GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int ] ) {

						if ( Point [ i ] [ point_owner ] == Character [ playerid ] [ character_id ] ) {

							SendServerMessage ( playerid, "You own this entrance. Use /point to manage it.", MSG_TYPE_INFO ) ;

							if ( Point [ i ] [ point_type ] == POINT_TYPE_BIZ ) {
								SendServerMessage ( playerid, sprintf("There's %s waiting for you in the business till.", IntegerWithDelimiter( Point [ i ] [ point_till ])), MSG_TYPE_INFO );
							}
						}

						if ( Point [ i ] [ point_locked ] ) {

							return SendServerMessage ( playerid, "You try the door to find out it's locked.", MSG_TYPE_ERROR ) ;
						}

						if ( Point [ i ] [ point_fee ] ) {
							//if ( Character [ playerid ] [ character_handmoney ] < Point [ i ] [ point_fee ] ) {
							if(Character[playerid][character_handmoney] == 0 && Character[playerid][character_handchange] < Point[i][point_fee]) {

								return SendServerMessage ( playerid, "You don't have enough money to enter this business.", MSG_TYPE_ERROR ) ;
							}

							TakeCharacterChange ( playerid, Point [ i ] [ point_fee ], MONEY_SLOT_HAND ) ;
							Point [ i ] [ point_till_change ] += Point [ i ] [ point_fee ] ;
							if(Point[i][point_till_change] >= 100) {

								Point[i][point_till]++;
								Point[i][point_till_change] = 0;
							}

							SendServerMessage ( playerid, sprintf("You've been charged $%s for the entrance fee.", IntegerWithDelimiter ( Point [ i ] [ point_fee ] ) ), MSG_TYPE_INFO ) ;

							mysql_format ( mysql, query, sizeof ( query ), "UPDATE points SET point_till = %d,point_till_change = %d WHERE point_id = %d", Point [ i ] [ point_till ], Point[i][point_till_change],Point [ i ] [ point_id ] ) ;
							mysql_tquery ( mysql, query ) ;
						}


						BlackScreen ( playerid ) ;

						ac_SetPlayerPos(playerid, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ],  Point [ i ] [ point_int_z ] ) ;

						if ( Point [ i ] [ point_type ] == POINT_TYPE_BIZ ) {
		 					switch ( Point [ i ] [ point_biztype ] ) {


								case POINT_TYPE_GEN_STORE: {
									SendServerMessage ( playerid, "Available commands: /buy", MSG_TYPE_INFO ) ;
								}

								case POINT_TYPE_GUN_STORE: {
									SendServerMessage ( playerid, "Available commands: /buy", MSG_TYPE_INFO ) ;
								}

								case POINT_TYPE_CLOTHING: {

									SendServerMessage ( playerid, "Available commands: /buy [optional: mask, attachments, misc]", MSG_TYPE_INFO ) ;
								}

								case POINT_TYPE_BARBER: {
									SendServerMessage ( playerid, "Available commands: None", MSG_TYPE_INFO ) ;
								}

								case POINT_TYPE_LIQUOR: {
									SendServerMessage ( playerid, "Available commands: /buy", MSG_TYPE_INFO ) ;
								}

								case POINT_TYPE_SALOON: {
									SendServerMessage ( playerid, "Available commands: /buy", MSG_TYPE_INFO ) ;
								}

								case POINT_TYPE_HUNTING: {
									SendServerMessage ( playerid, "Available commands: /buy - sell meat through your inventory.", MSG_TYPE_INFO ) ;
								}

								case POINT_TYPE_BANK: {
									SendServerMessage ( playerid, "Available commands: /bank", MSG_TYPE_INFO ) ;
								}

								case POINT_TYPE_POSTAL: {
									SendServerMessage ( playerid, "Available commands: /ad(vertise), /paycheck, /buytelegramnumber, /tele(gram)", MSG_TYPE_INFO ) ;
								}

								case POINT_TYPE_SHERIFF: {
									SendServerMessage ( playerid, "Available commands: None", MSG_TYPE_INFO ) ;
								}

								case POINT_TYPE_BLACKSMITH: {
									SendServerMessage ( playerid, "Available commands: /buy", MSG_TYPE_INFO ) ;
								}

								case POINT_TYPE_STABLEMASTER: {
									SendServerMessage ( playerid, "Available commands: /buy, /revivehorse", MSG_TYPE_INFO ) ;
								}
							}
						}

						SetPlayerVirtualWorld(playerid, Point [ i ] [ point_int_vw ]) ;
						SetPlayerInterior(playerid, Point [ i ] [ point_int_int ]) ;

						if ( Point [ i ] [ point_int_vw ] || Point [ i ] [ point_int_int ] ) {
							// FadeIn ( playerid ) ;
							SetPlayerWeather ( playerid, 0 ) ;
							SetPlayerTime(playerid, 14, 0) ;

							PlayerTextDrawSetString ( playerid, TD_ZoneName, "San Andreas" ) ;
							PlayerTextDrawShow(playerid, TD_ZoneName ) ;

							PlayAudioStreamForPlayer(playerid, "http://play.ww-rp.net/ambient/ambient_interior.mp3");
						}

						SetCharacterPointID(playerid,i);
						//SendClientMessage(playerid, -1, sprintf("id: %d",i));
						return true;
					}
					/*
					else if ( IsPlayerInRangeOfPoint(playerid, 1.5, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ],  Point [ i ] [ point_int_z ] ) &&
					GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ] ) {

						if ( Point [ i ] [ point_locked ] ) {

							return SendServerMessage ( playerid, "The door is locked. You can't leave now. If you are stuck, call an admin.", MSG_TYPE_ERROR ) ;
						}

						//BlackScreen ( playerid ) ;

						ac_SetPlayerPos(playerid, Point [ i ] [ point_ext_x ],  Point [ i ] [ point_ext_y ],  Point [ i ] [ point_ext_z ] ) ;
						SetPlayerTime(playerid, serverHour, serverMin) ;

						SetPlayerVirtualWorld(playerid, Point [ i ] [ point_vw ]) ;
						SetPlayerInterior(playerid, Point [ i ] [ point_int] ) ;

						Streamer_Update(playerid);

						//if ( Point [ i ] [ point_int_vw ] || Point [ i ] [ point_int_vw ] ) {

						//FadeIn ( playerid ) ;
						//}
					}

					else continue ;
					*/
				}

				else continue ;
			}
		}
		else {

			new id = GetCharacterPointID(playerid);

			//SendClientMessage(playerid, -1, sprintf("get id: %d",id));
			if ( IsPlayerInRangeOfPoint(playerid, 1.5, Point [ id ] [ point_int_x ],  Point [ id ] [ point_int_y ],  Point [ id ] [ point_int_z ] ) &&
				GetPlayerVirtualWorld ( playerid ) == Point [ id ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ id ] [ point_int_int ] ) {

				if ( Point [ id ] [ point_locked ] ) {

					return SendServerMessage ( playerid, "The door is locked. You can't leave now. If you are stuck, call an admin.", MSG_TYPE_ERROR ) ;
				}

				//BlackScreen ( playerid ) ;

				ac_SetPlayerPos(playerid, Point [ id ] [ point_ext_x ],  Point [ id ] [ point_ext_y ],  Point [ id ] [ point_ext_z ] ) ;
				SetPlayerTime(playerid, serverHour, serverMin) ;

				SetPlayerVirtualWorld(playerid, Point [ id ] [ point_vw ]) ;
				SetPlayerInterior(playerid, Point [ id ] [ point_int] ) ;

				ResetCharacterPointID(playerid);
				//SendClientMessage(playerid, -1, sprintf("id: %d",GetCharacterPointID(playerid)));

				//if ( Point [ id ] [ point_int_vw ] || Point [ id ] [ point_int_vw ] ) {

					//FadeIn ( playerid ) ;
				//}
			}	
		}

		return true ;
	}
	
	#if defined point_OnPlayerKeyStateChange
		return point_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif

#define OnPlayerKeyStateChange point_OnPlayerKeyStateChange
#if defined point_OnPlayerKeyStateChange
	forward point_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

OnPlayerSell ( playerid, itemid, tileid ) {

	for ( new i; i < MAX_POINTS; i ++ ) {
		if ( Point [ i ] [ point_id ] != -1 ) {
			if ( IsPlayerInRangeOfPoint(playerid, 15.0, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && 
				GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ] ) {

				switch ( Point [ i ] [ point_biztype ] ) {

					case POINT_TYPE_HUNTING: {

						// Fishing items
						if ( Item [ itemid ] [ item_extra_param ] == FISHING_BLUE_1 ||  Item [ itemid ] [ item_extra_param ] == FISHING_BLUE_2 ||
					 	Item [ itemid ] [ item_extra_param ] == FISHING_YELLOW ||  Item [ itemid ] [ item_extra_param ] == FISHING_BIGFISH ||
					  	Item [ itemid ] [ item_extra_param ] == FISHING_SHARK || Item [ itemid ] [ item_extra_param ] == WILDLIFE_HIDE || 
					  	Item [ itemid ] [ item_extra_param ] == WILDLIFE_MEAT || Item [ itemid ] [ item_extra_param ] == WILDLIFE_MEAT_LEG) {

						
							//new amount = PlayerItem [ playerid ] [ tileid ] [ player_item_param1 ] ;
							//new money = amount / 10 ;
							new change ;
							switch(Item [ itemid ] [ item_extra_param ]) {

								case FISHING_BLUE_1: {

									change = randomEx(10,21);
								}
								case FISHING_BLUE_2: {

									change = randomEx(20,34);
								}
								case FISHING_YELLOW: {

									change = randomEx(8,20);
								}
								case FISHING_BIGFISH: {

									change = randomEx(13,28);
								}
								case FISHING_SHARK: {

									change = randomEx(50,99);
								}
								case WILDLIFE_HIDE: {

									change = randomEx(20,60);
								}
								case WILDLIFE_MEAT,WILDLIFE_MEAT_LEG: {

									change = randomEx(25,70);
								}
							}

							DecreaseItem ( playerid, tileid, 1 ) ;
							//GiveCharacterMoney ( playerid, money, MONEY_SLOT_HAND ) ;
							GiveCharacterChange(playerid,change,MONEY_SLOT_HAND);

							if ( DoingTask [ playerid ] == 1 || DoingTask [ playerid ] == 7 ) {

								ProcessTask ( playerid, DoingTask [ playerid ] ) ;
							}

							SendServerMessage ( playerid, sprintf("You have sold your %s for $0.%02d.", Item [ itemid ] [ item_name ], change ), MSG_TYPE_INFO ) ;

							return true ;
						}

						else return false ;
					}

					case POINT_TYPE_BLACKSMITH: {

						// Mining items
						if ( Item [ itemid ] [ item_extra_param ] == MINE_ROCK || Item [ itemid ] [ item_extra_param ] == MINE_IRON_ORE || Item [ itemid ] [ item_extra_param ] == MINE_COPPER_ORE ||
							Item [ itemid ] [ item_extra_param ] == MINE_GOLD_ORE || Item [ itemid ] [ item_extra_param ] == MINE_COAL_ORE || Item [ itemid ] [ item_extra_param ] == MINE_TIN_ORE  ) {

							
							//new amount = PlayerItem [ playerid ] [ tileid ] [ player_item_param1 ] ;
							//new money = amount / 7 ;
							new change ;

							switch(Item [ itemid ] [ item_extra_param ]) {

								case MINE_ROCK: {

									change = randomEx(1,5);
								}
								case MINE_IRON_ORE,MINE_COPPER_ORE: {

									change = randomEx(15,33);
								}
								case MINE_GOLD_ORE: {

									change = randomEx(45,85);
								}
								case MINE_COAL_ORE,MINE_TIN_ORE: {

									change = randomEx(13,31);
								}
							}
							DecreaseItem ( playerid, tileid, 1 ) ;
							//GiveCharacterMoney ( playerid, money, MONEY_SLOT_HAND ) ;
							GiveCharacterChange(playerid,change,MONEY_SLOT_HAND);

							if ( DoingTask [ playerid ] == 5 ) {

								ProcessTask ( playerid, DoingTask [ playerid ] ) ;
							}

							SendServerMessage ( playerid, sprintf("You have sold your %s for $0.%02d.", Item [ itemid ] [ item_name ], change ), MSG_TYPE_INFO ) ;

							return true ;
						}

						// Woodcut items
						else if ( Item [ itemid ] [ item_extra_param ] == LUMBER_OAK_LOG || Item [ itemid ] [ item_extra_param ] == LUMBER_BIRCH_LOG || Item [ itemid ] [ item_extra_param ] == LUMBER_YEW_LOG  ) {

							//new amount = PlayerItem [ playerid ] [ tileid ] [ player_item_param1 ] ;
							//new money = amount / 7 ;
							new change ;	

							switch(Item [ itemid ] [ item_extra_param ]) {

								case LUMBER_OAK_LOG: {

									change = randomEx(8,21);
								}
								case LUMBER_BIRCH_LOG: {

									change = randomEx(6,15);
								}
								case LUMBER_YEW_LOG: {

									change = randomEx(15,30);
								}
							}

							DecreaseItem ( playerid, tileid, 1 ) ;
							//GiveCharacterMoney ( playerid, money, MONEY_SLOT_HAND ) ;
							GiveCharacterChange(playerid,change,MONEY_SLOT_HAND);

							if ( DoingTask [ playerid ] == 3 ) {

								ProcessTask ( playerid, DoingTask [ playerid ] ) ;
							}

							SendServerMessage ( playerid, sprintf("You have sold your %s for $0.%02d.", Item [ itemid ] [ item_name ],change ), MSG_TYPE_INFO ) ;

							return true ;
						}

						else return false ;

					}

					case POINT_TYPE_GEN_STORE: {

						if ( Item[itemid][item_param] == PARAM_FARMING) {

							new money = randomEx(1,3),	change = randomEx(50,95);

							DecreaseItem ( playerid, tileid, 1 ) ;

							GiveCharacterMoney ( playerid, money, MONEY_SLOT_HAND );
							GiveCharacterChange(playerid,change,MONEY_SLOT_HAND);

							GivePlayerItemByParam ( playerid, PARAM_FARMING, EMPTY_BASKET, 1, 0, 0, 0,0);

							SendServerMessage ( playerid, sprintf("You have sold your %s for $%d.%02d.", Item [ itemid ] [ item_name ], money, change ), MSG_TYPE_INFO ) ;
						}
						else return false;

					}

					default: return SendServerMessage ( playerid, "Something went wrong. You can't sell your items at the location you're at.", MSG_TYPE_ERROR ) ; 
				}

				// else if ( Point ) --- for mining

				//else if ( Point [ i ] ... )
			}
		}
	}

	return SendServerMessage ( playerid, "Something went wrong. You can't sell your items at the location you're at.", MSG_TYPE_ERROR ) ;
}

CMD:givegunpermit ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid )  ) {

		return SendServerMessage ( playerid, "Nice try.", MSG_TYPE_INFO ) ;
	}

	new target ;

	if ( sscanf ( params, "k<u>", target )) {

		return SendServerMessage ( playerid, "/givegunpermit [target]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected(target)) {

		return SendServerMessage ( playerid, "Player isn't online!", MSG_TYPE_ERROR ) ;
	}

	if (  DoesPlayerHaveItem ( target, CARD_PASSPORT) == -1 ) {

		return SendServerMessage ( playerid, "Target doesn't have a passport.", MSG_TYPE_ERROR );
	}


	SendServerMessage ( playerid, "Mis use of this will result in a ban. ", MSG_TYPE_ERROR ) ;
	GivePlayerItemByParam ( target, PARAM_MISC, CARD_GUNPERMIT, 1, 0, 0, 0 ) ;
	SendServerMessage ( playerid, "You've have given the goods.", MSG_TYPE_WARN ) ;

	return true ;
}

CMD:givelicense ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid )  ) {

		return SendServerMessage ( playerid, "Nice try.", MSG_TYPE_INFO ) ;
	}

	new target ;

	if ( sscanf ( params, "k<u>", target )) {

		return SendServerMessage ( playerid, "/givelicense [target]", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected(target)) {

		return SendServerMessage ( playerid, "Player isn't online!", MSG_TYPE_ERROR ) ;
	}

	GivePlayerItemByParam ( target, PARAM_MISC, CARD_PASSPORT, 1, 0, 0, 0 ) ;
	SendServerMessage ( playerid, "You've have given the goods.", MSG_TYPE_WARN ) ;

	return true ;
}



CMD:license ( playerid, params [] ) {

	for ( new i; i < MAX_POINTS; i ++ ) {
		if ( Point [ i ] [ point_id ] != -1 ) {
			if ( IsPlayerInRangeOfPoint(playerid, 15.0, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && 
				GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ] ) {

				if ( Point [ i ] [ point_biztype ] == POINT_TYPE_POSTAL ) {

   					GivePlayerItemByParam ( playerid, PARAM_MISC, CARD_PASSPORT, 1, 0, 0, 750 ) ;
   					return true ;
				}

				else continue ;
			}

			else continue ;
		}

		else continue ;
	}

	return true ;
}

CMD:buy ( playerid, params [] ) {

	new option [ 32 ] ;

	if ( sscanf ( params, "S()[32]", option ) ) {
		// Nothing should happen since it's optional...
	}

	for ( new i; i < MAX_POINTS; i ++ ) {
		if ( Point [ i ] [ point_id ] != -1 ) {
			if ( IsPlayerInRangeOfPoint(playerid, 15.0, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && 
				GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ] ) {

				if ( Point [ i ] [ point_type ] != POINT_TYPE_BIZ ) {

					return SendServerMessage ( playerid, "You're not in a business. If you are and you get this message, it's not set up correctly. Get an admin.", MSG_TYPE_ERROR ) ;
				}

				switch ( Point [ i ] [ point_biztype ] ) {

					case POINT_TYPE_GEN_STORE: {
						return ShowGeneralStoreSelection ( playerid ) ;
					}

					case POINT_TYPE_GUN_STORE: {
						return ShowGunStoreSelection ( playerid ) ;
					}

					case POINT_TYPE_CLOTHING: {

						if ( ! strlen ( option ) ) {

							ShowSkinSelection ( playerid ) ;
							return true ;
						}

						else if ( ! strcmp ( option, "mask" ) ) {

							if ( Character [ playerid ] [ character_level ] < 10 ) {

								return SendServerMessage ( playerid, "You need to be level 10 to buy masks.", MSG_TYPE_ERROR ) ;
							}

							ShowMaskSelection ( playerid ) ;
							return true ;
						}

						else if ( ! strcmp ( option, "attachments" ) ) {

							ShowToyMenu ( playerid ) ;
							return true ;
						}

						else if(!strcmp(option,"misc")) {

							ShowMiscClothingSelection(playerid);
							return true;
						}

						else return SendServerMessage ( playerid, "You can't do this in a clothing score. Correct param for a clothing store is: /buy [optional: mask, attachments, misc]", MSG_TYPE_ERROR ) ;

					}

					case POINT_TYPE_BARBER: {
						return SendServerMessage ( playerid, "This entrance has no /buy scripted to it yet!", MSG_TYPE_ERROR ) ;
					}

					case POINT_TYPE_LIQUOR: {
						return ShowLiquorMenu ( playerid ) ;
					}

					case POINT_TYPE_SALOON: {
						return ShowLiquorMenu ( playerid ) ;
					}

					case POINT_TYPE_HUNTING: {
						ShowHuntingStoreSelection ( playerid ) ;
						return SendServerMessage ( playerid, "You can sell meat through your inventory.", MSG_TYPE_ERROR ) ;
					}

					case POINT_TYPE_BANK: {
						return SendServerMessage ( playerid, "You cannot buy anything here.", MSG_TYPE_ERROR ) ;
					}

					case POINT_TYPE_POSTAL: {
						return SendServerMessage ( playerid, "/buy does not work here, /ad does though.", MSG_TYPE_ERROR ) ;
					}

					case POINT_TYPE_SHERIFF: {
						return SendServerMessage ( playerid, "You can't buy anything here.", MSG_TYPE_ERROR ) ;
					}

					case POINT_TYPE_BLACKSMITH: {
						return ShowBlacksmithMenu ( playerid ) ;
					}
					case POINT_TYPE_STABLEMASTER: {
						return ShowHorseSelection ( playerid ) ;
					}
				}
			}

			else continue ;
		}

		else continue ;
	}

	return true ;
}

ShowMiscClothingSelection(playerid) {

	inline MiscClothingStockList(pid, dialogid, response, listitem, string:inputtext[]) {

   		#pragma unused inputtext, dialogid, pid, listitem, response

   		if ( response ) {

   			switch ( listitem ) {

   				case 0: {

   					GivePlayerItemByParam ( playerid, PARAM_MISC, GLOVES, 1, PARAM_MISC, GLOVES, 3, 50 ) ;
   				}

   				case 1: {

   					GivePlayerItemByParam ( playerid, PARAM_MISC, LONG_JOHNS, 1, PARAM_MISC, LONG_JOHNS, 6, 25 ) ;
   				}
   			}
   		}
   	}

   	new sQuery [ 256 ];

   	format(sQuery,sizeof(sQuery),"%d\tGloves ($3.50)\n%d\tLong Johns ($6.25)\n",GLOVES_BROWN,LONGJOHNS_OBJ);

   	Dialog_ShowCallback(playerid, using inline MiscClothingStockList, DIALOG_STYLE_PREVMODEL,  "Blacksmith Store", sQuery, "Select", "Cancel");
	return true;
}

ShowBlacksmithMenu ( playerid ) {

	inline BlacksmithStockList(pid, dialogid, response, listitem, string:inputtext[]) {

   		#pragma unused inputtext, dialogid, pid, listitem, response

   		if ( response ) {

   			switch ( listitem ) {

   				case 0: {

   					if ( Character [ playerid ] [ character_level ] < 2 ) {

		 				return SendServerMessage ( playerid, "You need to be level 2 to buy a pickaxe.", MSG_TYPE_ERROR ) ;
		 			}

   					GivePlayerItemByParam ( playerid, PARAM_MINING, MINE_PICKAXE, 1, 0, 0, 8,4 ) ;
   				}

   				case 1: {
   					GivePlayerItemByParam ( playerid, PARAM_FARMING, FARMING_PAIL, 1, 0, 0, 2,45 ) ;
   					
   				}
	
   				case 2: {

   					GivePlayerItemByParam ( playerid, PARAM_FARMING, FARMING_SHOVEL, 1, 0, 0, 4,2 ) ;
   				}
   			}
   			cmd_buy(playerid,"");
   		}
   	}

   	//change crop cutter num.
   	new sQuery [ 256 ];
   	format(sQuery,sizeof(sQuery),"%d\tPickaxe ($8.04)\n19468\tPail ($2.45)\n19626\tShovel ($4.02)\n",PICKAXE);
   	Dialog_ShowCallback(playerid, using inline BlacksmithStockList, DIALOG_STYLE_PREVMODEL,  "Blacksmith Store", sQuery, "Select", "Cancel");

	return true ;
}

ShowLiquorMenu ( playerid ) {


   	inline LiquorStockList(pid, dialogid, response, listitem, string:inputtext[]) {

   		#pragma unused inputtext, dialogid, pid, listitem, response

   		if ( response ) {

   			switch ( listitem ) {

   				case 0: {

					GivePlayerItemByParam ( playerid, PARAM_LIQUOR, LIQUOR_PALELAGER, 1, 0, 0, 1,23 ) ;
   				}

   				case 1: {
					GivePlayerItemByParam ( playerid, PARAM_LIQUOR, LIQUOR_MILDALE, 1, 0, 0, 1,20 ) ;
   				}

   				case 2: {
					GivePlayerItemByParam ( playerid, PARAM_LIQUOR, LIQUOR_MALTLIQUOR, 1, 0, 0, 2 ) ;
   				}

   				case 3: {
					GivePlayerItemByParam ( playerid, PARAM_LIQUOR, LIQUOR_WHEATBEER, 1, 0, 0, 1,89 ) ;
   				}

   				case 4: {

					GivePlayerItemByParam ( playerid, PARAM_LIQUOR, LIQUOR_WHITEWINE, 1, 0, 0, 2,5 ) ;
   				}

   				case 5: {

					GivePlayerItemByParam ( playerid, PARAM_LIQUOR, LIQUOR_REDWINE, 1, 0, 0, 2,11 ) ;
   				}

   				case 6: {

					GivePlayerItemByParam ( playerid, PARAM_LIQUOR, LIQUOR_GRAINWHISKEY, 1, 0, 0, 2,33 ) ;
   				}

   				case 7: {

					GivePlayerItemByParam ( playerid, PARAM_LIQUOR, LIQUOR_MALTWHISKEY, 1, 0, 0, 2,64 ) ;
   				}

   				case 8: {

					GivePlayerItemByParam ( playerid, PARAM_LIQUOR, LIQUOR_VODKA, 1, 0, 0, 3,5 ) ;
   				}
   			}
   			cmd_buy(playerid,"");
   		}
  	}

   	new sQuery [ 256 ] = "\
   	1544\tPale Lager ($1.23)\n\
   	1543\tMild Ale ($1.20)\n\
   	1486\tMalt Liquor ($2.00)\n\
   	1484\tWheat Beer ($1.89)\n\
   	19824\tWhite Wine ($2.05)\n\
   	19822\tRed Wine ($2.11)\n\
   	19823\tGrain Whiskey~n~($2.33)\n\
   	19820\tMalt Whiskey~n~($2.64)\n\
   	19821\tMoonshine~n~Vodka ($3.05)\n\
	   	" ;

   	Dialog_ShowCallback(playerid, using inline LiquorStockList, DIALOG_STYLE_PREVMODEL,  "Liquor Store", sQuery, "Select", "Cancel");

	return true ;
}

CMD:revivehorse ( playerid, params [] ) {

	for ( new i; i < MAX_POINTS; i ++ ) {
		if ( Point [ i ] [ point_id ] != -1 ) {
			if ( IsPlayerInRangeOfPoint(playerid, 15.0, Point [ i ] [ point_int_x ],  Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) && 
				GetPlayerVirtualWorld ( playerid ) == Point [ i ] [ point_int_vw ] && GetPlayerInterior ( playerid ) == Point [ i ] [ point_int_int ] ) {

				if ( Point [ i ] [ point_biztype ] == POINT_TYPE_STABLEMASTER ) {

					if ( Character [ playerid ] [ character_horseid ] == -1 ) {

						return SendServerMessage ( playerid, "You don't have a horse, so you can't revive it.", MSG_TYPE_ERROR ) ;
					}

					if ( Character [ playerid ] [ character_horsehealth ] <= 5 ) {

						if ( Character [ playerid ] [ character_handmoney ] < 15 ) {

							return SendServerMessage ( playerid, "You need $15 in order to revive your horse.", MSG_TYPE_ERROR ) ;
						}

						SendServerMessage ( playerid, "Your horse has been revived for a small fee of $15. You can now /spawnhorse again!", MSG_TYPE_INFO ) ;

						SetHorseHealth ( playerid, -1, 100 ) ;
						TakeCharacterMoney ( playerid, 15, MONEY_SLOT_HAND ) ;
					}

					else return SendServerMessage ( playerid, "Your horse seems to be healthy, there's no need to revive it.", MSG_TYPE_ERROR ) ;
				}

				else continue ;
			}

			else continue ;
		}

		else continue ;
	}

	SendServerMessage ( playerid, "You're not near a stablemaster. Make sure to enter the shop before doing this command.", MSG_TYPE_ERROR ) ;

	return true ;
}

ShowHuntingStoreSelection ( playerid ) {

   	inline HuntingStoreSelection(pid, dialogid, response, listitem, string:inputtext[]) {

   		#pragma unused inputtext, dialogid, pid, listitem

   		if ( response ) {

   			switch ( listitem ) {
	      		case 0: { // Fishing Rod

					GivePlayerItemByParam ( playerid, PARAM_FISHING, FISHING_ROD, 1, 0, 0, 1,4 ) ;
	      		}
	      		case 1: { // hunting knife

					GivePlayerItemByParam ( playerid, PARAM_HUNTING, HUNTING_KNIFE, 1, 0, 0, 17,50 ) ;
	      		}

	      		case 2: { //animal trap
	      			GivePlayerItemByParam ( playerid, PARAM_HUNTING, HUNTING_TRAP, 1, 0, 0, 11,32 ) ;
	      		}
	      	}
	      	cmd_buy(playerid,"");
   		}
   	}

   	new string [ 256 ] ;
	format(string,sizeof(string),"18632\tFishing Rod ($1.04)\n335\tHunting Knife ($17.50)\n%d\tAnimal Trap ($11.32)\n",TRAP_FOOTLOCK);


   	Dialog_ShowCallback(playerid, using inline HuntingStoreSelection, DIALOG_STYLE_PREVMODEL,  "Hunting Store", string, "Select", "Cancel");


}

ShowHorseSelection ( playerid ) {

  	new string [ 1024 ], price ;

   	inline HorseDisplayList(pid, dialogid, response, listitem, string:inputtext[]) {

   		#pragma unused inputtext, dialogid, pid, listitem

   		if ( response ) {

   			// Id 0 is unused
   			listitem += 1 ;

   			if ( horseType [ listitem ] [ h_donator ] && ! Account [ playerid ] [ account_donatorlevel ] ) {

   				return SendServerMessage ( playerid, "You need to be a donator in order to purchase this horse.", MSG_TYPE_ERROR ) ;
   			}

   			if ( horseType [ listitem ] [ h_level_requirement ] > Character [ playerid ] [ character_level ] ) {

   				return SendServerMessage ( playerid, sprintf("You need to be level %d to buy a %s.", horseType [ listitem ] [ h_level_requirement ], horseType [ listitem ] [ h_td_name ] ) , MSG_TYPE_ERROR ) ;
   			}

  			price = horseType [ listitem ] [ h_price ] ;

	  		if ( Character [ playerid ] [ character_handmoney ] < price ) {

	  			return SendServerMessage ( playerid, sprintf("You don't have this much money. You need at least $%d.", price ), MSG_TYPE_ERROR ) ;
	  		}

	  		TakeCharacterMoney ( playerid, price, MONEY_SLOT_HAND ) ;

			Character [ playerid ] [ character_horseid ] = horseType[listitem][h_td_id] ;
			Character [ playerid ] [ character_horsehealth ] = 100 ;

			mysql_format ( mysql, string, sizeof ( string ), "UPDATE characters SET character_horseid = %d, character_horsehealth = 100 WHERE character_id = %d", Character [ playerid ] [ character_horseid ], Character [ playerid ] [ character_id ] ) ;
			mysql_tquery ( mysql, string ) ;

			SendServerMessage ( playerid, sprintf("You have purchased a {876C45}%s{DEDEDE} for {458754}$%d.", horseType [ listitem ] [ h_td_name ], price ), MSG_TYPE_INFO ) ;
   		}
  	}

  	for ( new i; i < sizeof (  horseType  ); i ++ ) {

  		if (horseType [ i ] [ horse_enabled ] ) {

	  		price = horseType [ i ] [ h_price ] ;

	  		strcat(string, sprintf("11733\t~b~%s~w~~n~Price:~g~$%d~w~~n~Level Required: %d\n", horseType [ i ] [ h_td_name ], price, horseType [ i ] [ h_level_requirement ] ) ) ;
	 	}

	 	else continue ;
  	}

   	Dialog_ShowCallback(playerid, using inline HorseDisplayList, DIALOG_STYLE_PREVMODEL,  "General Store", string, "Select", "Cancel");

	return true ; 
}

ShowGunStoreSelection ( playerid ) {

	/*
	if (DoesPlayerHaveItem ( playerid, CARD_PASSPORT) == -1 ) {

		return SendServerMessage ( playerid, "You lack the necessary documents in order to purchase items here.", MSG_TYPE_ERROR );
	}
	*/

	if ( Character [ playerid ] [ character_level ] < 3) {

		return SendServerMessage ( playerid, "Your level must at least be 3.", MSG_TYPE_ERROR ) ;
	}

   	inline GunStoreList(pid, dialogid, response, listitem, string:inputtext[]) {

   		#pragma unused inputtext, dialogid, pid
  	
      	if ( ! response ) {

      		return false ;
      	}

      	if ( response ) {

      		if ( EquippedItem [ playerid ] >= 0 ) {

      			return SendServerMessage ( playerid, "Please unequip the item you have equipped before buying a weapon.", MSG_TYPE_ERROR);
      		}

	      	if ( Character [ playerid ] [ character_handweapon ] ) {

	      		return SendServerMessage ( playerid, "You can't buy a weapon whilst you already have one equipped.", MSG_TYPE_ERROR ) ;
	      	}

	      	switch ( listitem ) {

	      		case 0: { //bat

	      			if ( Character [ playerid ] [ character_level ] < 3 ) {

	      				return SendServerMessage ( playerid, "You need to be level 3 to buy a baseball bat.", MSG_TYPE_ERROR ) ;
	      			}

	      			if ( Character [ playerid ] [ character_handmoney ] < 5 ) {

			      		return SendServerMessage ( playerid, " You don't have enough money. You need to pay $5 for a baseball bat.", MSG_TYPE_ERROR ) ;
			      	}

			      	TakeCharacterMoney ( playerid, 5, MONEY_SLOT_HAND ) ;
			      	wep_GivePlayerWeapon ( playerid, WEAPON_BAT, 1 ) ;

			      	WriteLog ( playerid, "guns/points", sprintf("%s (%d) has bought a baseball bat.", ReturnUserName ( playerid, false, false ), playerid ) ) ;

			      	SendServerMessage ( playerid, "You've purchased a baseball bat.", MSG_TYPE_INFO ) ;
	      		}

	      		case 1: { //knife

	      			if ( Character [ playerid ] [ character_level ] < 4 ) {

	      				return SendServerMessage ( playerid, "You need to be level 4 to buy a knife.", MSG_TYPE_ERROR ) ;
	      			}

	      			if(Character[playerid][character_handmoney] < 7) { return SendServerMessage ( playerid, " You don't have enough money. You need to pay $7.50 for a knife.", MSG_TYPE_ERROR ) ; }

	      			if ( Character [ playerid ] [ character_handmoney ] == 7 && Character[playerid][character_handchange] < 50) {

			      		return SendServerMessage ( playerid, " You don't have enough money. You need to pay $7.50 for a knife.", MSG_TYPE_ERROR ) ;
			      	}

			      	TakeCharacterMoney ( playerid, 7, MONEY_SLOT_HAND ) ;
			      	TakeCharacterChange(playerid,50,MONEY_SLOT_HAND);
			      	wep_GivePlayerWeapon ( playerid, WEAPON_KNIFE, 1 ) ;

			      	WriteLog ( playerid, "guns/points", sprintf("%s (%d) has bought a knife.", ReturnUserName ( playerid, false, false ), playerid ) ) ;

			      	SendServerMessage ( playerid, "You've purchased a knife.", MSG_TYPE_INFO ) ;
	      		}

	      		case 2: { // Desert Eagle

	      			if ( Character [ playerid ] [ character_level ] < 6 ) {

	      				return SendServerMessage ( playerid, "You need to be level 6 to buy a revolver.", MSG_TYPE_ERROR ) ;
	      			}

			      	if ( Character [ playerid ] [ character_handmoney ] < 40 ) {

			      		return SendServerMessage ( playerid, " You don't have enough money. You need to pay $40 for a revolver.", MSG_TYPE_ERROR ) ;
			      	}

			      	TakeCharacterMoney ( playerid, 40, MONEY_SLOT_HAND ) ;
			      	wep_GivePlayerWeapon ( playerid, WEAPON_DEAGLE, 0 ) ;

			      	WriteLog ( playerid, "guns/points", sprintf("%s (%d) has bought a revolver.", ReturnUserName ( playerid, false, false ), playerid ) ) ;

			      	SendServerMessage ( playerid, "You've purchased a revolver. You need to buy the appropiate ammo pack to add bullets to your magazine!", MSG_TYPE_INFO ) ;
	      		}

	      		case 3: { // Shotgun

	      			if ( Character [ playerid ] [ character_level ] < 8 ) {

	      				return SendServerMessage ( playerid, "You need to be level 8 to buy a shotgun.", MSG_TYPE_ERROR ) ;
	      			}

			      	if ( Character [ playerid ] [ character_handmoney ] < 66 ) {

			      		return SendServerMessage ( playerid, " You don't have enough money. You need to pay $66 for a shotgun.", MSG_TYPE_ERROR ) ;
			      	}

			      	TakeCharacterMoney ( playerid, 66, MONEY_SLOT_HAND ) ;
			      	wep_GivePlayerWeapon ( playerid, WEAPON_SHOTGUN, 0 ) ;

			      	WriteLog ( playerid, "guns/points", sprintf("%s (%d) has bought a shotgun.", ReturnUserName ( playerid, false, false ), playerid ) ) ;

			      	SendServerMessage ( playerid, "You've purchased a shotgun. You need to buy the appropiate ammo pack to add bullets to your magazine!", MSG_TYPE_INFO ) ;
	      		}

	      		case 4: { // Sawn Shotgun

	      			if ( Character [ playerid ] [ character_level ] < 8 ) {

	      				return SendServerMessage ( playerid, "You need to be level 8 to buy a sawn off shotgun.", MSG_TYPE_ERROR ) ;
	      			}

			      	if ( Character [ playerid ] [ character_handmoney ] < 51 ) {

			      		return SendServerMessage ( playerid, " You don't have enough money. You need to pay $51 for a sawn off shotgun.", MSG_TYPE_ERROR ) ;
			      	}

			      	TakeCharacterMoney ( playerid, 51, MONEY_SLOT_HAND ) ;
			      	wep_GivePlayerWeapon ( playerid, WEAPON_SAWEDOFF, 0 ) ;

			      	WriteLog ( playerid, "guns/points", sprintf("%s (%d) has bought a sawn off shotgun.", ReturnUserName ( playerid, false, false ), playerid ) ) ;

			      	SendServerMessage ( playerid, "You've purchased a sawn-off shotgun. You need to buy the appropiate ammo pack to add bullets to your magazine!", MSG_TYPE_INFO ) ;
	      		}

	      		case 5: { // Rifle

	      			if ( Character [ playerid ] [ character_level ] < 12 ) {

	      				return SendServerMessage ( playerid, "You need to be level 12 to buy a rifle.", MSG_TYPE_ERROR ) ;
	      			}

			      	if ( Character [ playerid ] [ character_handmoney ] < 82 ) {

			      		return SendServerMessage ( playerid, " You don't have enough money. You need to pay $82 for a rifle.", MSG_TYPE_ERROR ) ;
			      	}

			      	TakeCharacterMoney ( playerid, 82, MONEY_SLOT_HAND ) ;
			      	wep_GivePlayerWeapon ( playerid, WEAPON_RIFLE, 0 ) ;

			      	WriteLog ( playerid, "guns/points", sprintf("%s (%d) has bought a rifle.", ReturnUserName ( playerid, false, false ), playerid ) ) ;

			      	SendServerMessage ( playerid, "You've purchased a rifle. You need to buy the appropiate ammo pack to add bullets to your magazine!", MSG_TYPE_INFO ) ;
	      		}      

	      		case 6: { // Sniper

	      			if ( Character [ playerid ] [ character_level ] < 16 ) {

	      				return SendServerMessage ( playerid, "You need to be level 16 to buy a scoped rifle.", MSG_TYPE_ERROR ) ;
	      			}

			      	if ( Character [ playerid ] [ character_handmoney ] < 104 ) {

			      		return SendServerMessage ( playerid, " You don't have enough money. You need to pay $104 for a scoped rifle.", MSG_TYPE_ERROR ) ;
			      	}

			      	TakeCharacterMoney ( playerid, 104, MONEY_SLOT_HAND ) ;
			      	wep_GivePlayerWeapon ( playerid, WEAPON_SNIPER, 0 ) ;

			      	WriteLog ( playerid, "guns/points", sprintf("%s (%d) has bought a scoped rifle.", ReturnUserName ( playerid, false, false ), playerid ) ) ;

			      	SendServerMessage ( playerid, "You've purchased a scoped rifle. You need to buy the appropiate ammo pack to add bullets to your weapon!", MSG_TYPE_INFO ) ;
	      		}   

	      		case 7: { // Pistol Ammo

			      	GivePlayerItemByParam ( playerid, PARAM_AMMO, AMMO_CRATE_PISTOL, 1, 0, 0, 2,50 ) ;

			      	WriteLog ( playerid, "guns/points", sprintf("%s (%d) has bought a pistol ammo crate.", ReturnUserName ( playerid, false, false ), playerid ) ) ;
	      		}      

	      		case 8: { // Shotty Ammo
					GivePlayerItemByParam ( playerid, PARAM_AMMO, AMMO_CRATE_SHOTGUN, 1, 0, 0, 1,50 ) ;

					WriteLog ( playerid, "guns/points", sprintf("%s (%d) has bought a shotgun ammo crate.", ReturnUserName ( playerid, false, false ), playerid ) ) ;
	      		}    

	      		case 9: { // Rifle Ammo

					GivePlayerItemByParam ( playerid, PARAM_AMMO, AMMO_CRATE_RIFLE, 1, 0, 0, 3,50 ) ;

					WriteLog ( playerid, "guns/points", sprintf("%s (%d) has bought a rifle ammo crate.", ReturnUserName ( playerid, false, false ), playerid ) ) ;
	      		}         		   
	      	}
	      	cmd_buy(playerid,"");
	    }
   	}

   	new sQuery [ 256 ] = "\
   	336\tBaseball Bat ($5.00)\n\
   	335\tKnife ($7.50)\n\
   	348\tPistol ($40.00)\n\
   	349\tShotgun ($66.00)\n\
   	350\tSawn-off ($51.00)\n\
   	357\tRifle ($82.00)\n\
   	358\tScope Rifle~n~($104.00)\n\
   	2037\tPistol Ammo~n~($2.50)\n\
   	2041\tShotgun Ammo~n~($1.50)\n\
   	2043\tRifle Ammo~n~($3.50)\n\
	   	" ;

   	Dialog_ShowCallback(playerid, using inline GunStoreList, DIALOG_STYLE_PREVMODEL,  "Weapon Store", sQuery, "Select", "Cancel");

	return true ;
}

ShowGeneralStoreSelection ( playerid ) {
 
	new query [ 256 ] ;

   	inline GenStoreList(pid, dialogid, response, listitem, string:inputtext[]) {

   		#pragma unused inputtext, dialogid, pid
  	
      	if ( ! response ) {

      		return false ;
      	}

      	switch ( listitem ) {

      		case 0: { // Pocket Watch

      			GivePlayerItemByParam ( playerid, PARAM_MISC, POCKET_WATCH, 1, 0, POCKET_WATCH, 5,50 ) ;
      		}

      		case 1: { // Camera

				GivePlayerItemByParam ( playerid, PARAM_WEAPON, CAMERA, 1, 0, 0, 45 ) ;
      		}

      		case 2: { // Hatchet

      			if ( Character [ playerid ] [ character_level ] < 2 ) {

		 			return SendServerMessage ( playerid, "You need to be level 2 to buy a hatchet.", MSG_TYPE_ERROR ) ;
		 		}

				GivePlayerItemByParam ( playerid, PARAM_LUMBER, LUMBER_HATCHET, 1, 0, 0, 12 ) ;
      		}

			case 3: { // Bandage


				GivePlayerItemByParam ( playerid, PARAM_HEAL, BANDAGE, 1, 0, 0, 3,46 ) ;
      		}

      		case 4: { // Red Apple

				GivePlayerItemByParam ( playerid, PARAM_HUNGER, FOOD_APPLE_RED, 1, 0, 0, 0,20 ) ;
      		}

      		case 5: { // Green Apple

				GivePlayerItemByParam ( playerid, PARAM_HUNGER, FOOD_APPLE_GREEN, 1, 0, 0, 0,20 ) ;

      		} 

      		case 6: { // water bottle

      			GivePlayerItemByParam ( playerid, PARAM_THIRST, FOOD_WATER_FULL, 1, 0, 0, 0,75);
      		}

      		case 7: { // canned salmon

      			GivePlayerItemByParam ( playerid, PARAM_HUNGER, FOOD_CANNED_SALMON, 1, 0, 0, 2);
      		}

      		case 8: { // canned corned beef

      			GivePlayerItemByParam ( playerid, PARAM_HUNGER, FOOD_CANNED_CORNED_BEEF, 1, 0, 0, 1,75);
      		}

      		case 9: { // canned pineapples

      			GivePlayerItemByParam ( playerid, PARAM_HUNGER, FOOD_CANNED_PINEAPPLES, 1, 0, 0, 1,50);
      		}

      		case 10: { // canned strawberries

      			GivePlayerItemByParam ( playerid, PARAM_HUNGER, FOOD_CANNED_STRAWBERRIES, 1, 0, 0, 1,20);
      		}

      		case 11: { // canned kidney beans

      			GivePlayerItemByParam ( playerid, PARAM_HUNGER, FOOD_CANNED_KIDNEY_BEANS, 1, 0, 0, 1,50);
      		}

      		case 12: { // canned peaches

      			GivePlayerItemByParam ( playerid, PARAM_HUNGER, FOOD_CANNED_PEACHES, 1, 0, 0, 1);
      		}

      		case 13: { // canned sweetcorn

      			GivePlayerItemByParam ( playerid, PARAM_HUNGER, FOOD_CANNED_SWEETCORN, 1, 0, 0, 1);
      		}

      		case 14: { // baked beans

      			GivePlayerItemByParam ( playerid, PARAM_HUNGER, FOOD_CANNED_BAKED_BEANS, 1, 0, 0, 1,20);
      		}

      		case 15: { // canned apricots

      			GivePlayerItemByParam ( playerid, PARAM_HUNGER, FOOD_CANNED_APRICOTS, 1, 0, 0, 0,75);
      		}

      		case 16: { // canned peas

      			GivePlayerItemByParam ( playerid, PARAM_HUNGER, FOOD_CANNED_PEAS, 1, 0, 0, 0,75);
      		}	

      		case 17: { // Cigars

				GivePlayerItemByParam ( playerid, PARAM_SMOKES, SMOKE_CIGARPACK, 20, 0, 0, 2,12) ;
      		} 	

      		case 18: { // Blunt

				GivePlayerItemByParam ( playerid, PARAM_SMOKES, SMOKE_BLUNTPACK, 20, 0, 0, 2,50) ;
      		} 	

      		case 19: { // Backpack lvl 1: 12 slots

      			if ( Character [ playerid ] [ character_handmoney ] < 20 ) {

      				return SendServerMessage ( playerid, "You don't have enough money.", MSG_TYPE_ERROR ) ;
      			}

      			TakeCharacterMoney ( playerid, 20, MONEY_SLOT_HAND ) ;

				Character [ playerid ] [ character_backpack ] = 1 ;

				mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_backpack = %d WHERE character_id = %d", Character [ playerid ] [ character_backpack ], Character [ playerid ] [ character_id ] ) ;
				mysql_tquery ( mysql, query ) ;

				SendServerMessage ( playerid, "You bought a small backpack for $20.", MSG_TYPE_INFO ) ;

				return true ;

      		}

      		case 20: { // Backpack lvl 2: 18 slots

      			if ( Character [ playerid ] [ character_handmoney ] < 45 ) {

      				return SendServerMessage ( playerid, "You don't have enough money.", MSG_TYPE_ERROR ) ;
      			}

      			TakeCharacterMoney ( playerid, 45, MONEY_SLOT_HAND ) ;

				Character [ playerid ] [ character_backpack ] = 2 ;

				mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_backpack = %d WHERE character_id = %d", Character [ playerid ] [ character_backpack ], Character [ playerid ] [ character_id ] ) ;
				mysql_tquery ( mysql, query ) ;

				SendServerMessage ( playerid, "You bought a large backpack for $45.", MSG_TYPE_INFO ) ;

				return true ;
      		}

      		case 21: { // soil bag
      			GivePlayerItemByParam ( playerid, PARAM_FARMING, FARMING_SOIL_BAG, 1, 0, 0, 0,85) ;
      		}

      		case 22: { // orange seed.
      			GivePlayerItemByParam ( playerid, PARAM_UNDEFINED, SEED_ORANGE, 1, 0, 0, 0,10) ;
      		}

      		case 23: { // red apple seed.
      			GivePlayerItemByParam ( playerid, PARAM_UNDEFINED, SEED_APPLE_RED, 1, 0, 0, 0,13) ;
      		}

      		case 24: { // green apple seed.
      			GivePlayerItemByParam ( playerid, PARAM_UNDEFINED, SEED_APPLE_GREEN, 1, 0, 0, 0,13) ;
      		}

      		case 25: { // tomato seed.
      			GivePlayerItemByParam ( playerid, PARAM_UNDEFINED, SEED_TOMATO, 1, 0, 0, 0,15) ;
      		}

      		case 26: { // pumpkin seed.
      			GivePlayerItemByParam ( playerid, PARAM_UNDEFINED, SEED_PUMPKIN, 1, 0, 0, 0,11) ;
      		}

      		case 27: { // cabbage seed.
      			GivePlayerItemByParam ( playerid, PARAM_UNDEFINED, SEED_CABBAGE, 1, 0, 0, 0,14) ;
      		}

      		case 28: { // orange seed.
      			GivePlayerItemByParam ( playerid, PARAM_UNDEFINED, SEED_WHEAT, 1, 0, 0, 0,15) ;
      		}

      		case 29:{
      			GivePlayerItemByParam(playerid, PARAM_FARMING, EMPTY_BASKET, 1, 0, 0, 2, 78);
      		}
      	}
      	cmd_buy(playerid,"");
   	}

   	new sQuery [ 2048 ];
   	format(sQuery,sizeof(sQuery),"19043\tPocket Watch ($5.50)\n19623\tCamera ($45.00)\n%d\tHatchet ($12.00)\n11747\tBandage ($3.46)\n19575\tRed Apple ($0.20)\n19576\tGreen Apple ($0.20)\n19570\tWater Bottle ($0.75)\n\
   		19567\tCanned Salmon ($2.00)\n19567\tCanned Corned Beef ($1.75)\n19564\tCanned Pineapples ($1.50)\n19564\tCanned Strawberries ($1.20)\n19567\tCanned Kidney Beans ($1.50)\n19564\tCanned Peaches ($1.00)\n\
   		19567\tCanned Sweetcorn ($1.00)\n19567\tBaked Beans ($1.20)\n19564\tCanned Apricots ($0.75)\n19567\tCanned Peas ($0.75)\n19897\tCigar Pack ($2.12)~n~20 in a pack\n19896\tBlunt Pack($2.50)~n~20 in a pack\n\
   		363\tSmall Backpack($20.00)\n363\tLarge Backpack($45.00)\n2060\tFarming Soil Bag($0.85)\n2663\tOrange Seed ($0.10)\n2663\tRed Apple Seed ($0.12)\n2663\tGreen Apple Seed ($0.12)\n2663\tTomato Seed ($0.15)\n\
   		2663\tPumpkin Seed ($0.11)\n2663\tCabbage Seed ($0.14)\n2663\tWheat Seed ($0.15)\n19592\tBasket ($2.78)\n",HATCHET);
   	Dialog_ShowCallback(playerid, using inline GenStoreList, DIALOG_STYLE_PREVMODEL,  "General Store", sQuery, "Select", "Cancel");
 
	return true ;
}


ShowSkinSelection ( playerid ) {

	new sex = Character [ playerid ] [ character_gender ] ;
	new race = Character [ playerid ] [ character_origin ] ;

	new skins [ sizeof ( SkinArray ) ], skincount, basecount = 0;

	new sQuery [ 1024 ] ;

	for ( new i; i < sizeof ( SkinArray ); i ++ ) {

		if ( SkinArray [ i ] [ gender ] == sex ) {

			if ( SkinArray [ i ] [ ethnicity ] == race ) {

				skins [ i ] = SkinArray [ i ] [ skinid ] ;
				format ( sQuery, sizeof ( sQuery ), "%s%d\t%d\n", sQuery, skins [ i ], i ) ;

				skincount ++ ;
				if ( ( race || sex ) && ! basecount  ) { basecount = i; }
			}
		}
	}

	if ( skincount == 0 ) {

		return SendServerMessage ( playerid, "Error processing skin data. Please try again or call a developer.", MSG_TYPE_ERROR ) ;
	}

   	inline SkinList(pid, dialogid, response, listitem, string:inputtext[]) {

      	#pragma unused pid, dialogid, response, inputtext
      	
      	if ( ! response ) {

      		return false ;
      	}

      	if ( Character [ playerid ] [ character_handmoney ] < 1 || (Character[playerid][character_handmoney] == 1 && Character[playerid][character_handchange] < 25) ) {

      		return SendServerMessage ( playerid, " You don't have enough money. You need to pay $1.25 for a new skin.", MSG_TYPE_ERROR ) ;
      	}

      	TakeCharacterMoney ( playerid, 1, MONEY_SLOT_HAND ) ;
      	TakeCharacterChange(playerid,25,MONEY_SLOT_HAND);

      	SendServerMessage(playerid, sprintf("You've purchased skin ID %d for $1.25.", skins [ basecount+listitem ] ), MSG_TYPE_INFO ) ; 

  		Character [ playerid ] [ character_skin ] = skins [ basecount+listitem ] ;
		SetPlayerSkin ( playerid, Character [ playerid ] [ character_skin ] ) ;

		TogglePlayerControllable(playerid, true ) ;

		new query [ 256 ] ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_skin = %d WHERE character_id = %d", Character [ playerid ] [ character_skin ], Character [ playerid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;
   	}

   	Dialog_ShowCallback(playerid, using inline SkinList, DIALOG_STYLE_PREVMODEL,  "Skin selection", sQuery, "Select", "Cancel");
 
	return true ;
}