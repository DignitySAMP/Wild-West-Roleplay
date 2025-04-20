#define LVL1GUNSMITHTIME 	(60000)
#define LVL2GUNSMITHTIME 	(40000)
#define LVL3GUNSMITHTIME 	(20000)

enum GunCreationData {

	gc_name [ 64 ],
	Float: gc_pos_x,
	Float: gc_pos_y,
	Float: gc_pos_z
} ;

new GunCreation [ ] [ GunCreationData ] = {


	{ "Coal Heap: Fuel", 			-1212.5631, 1831.2927, 42.3896 }, // should take more time to attain, but works faster
	{ "Lumber Block: Ingot Reforming", 	-1218.0070, 1825.6216, 41.7440 }, // should take less time to attain, but works slower
	{ "Furnace: Ore smelting", 		-1214.9054, 1819.7556, 40.3845 }, // to shape ore into ingots
	{ "Cooling: Ingot Creation", 	-1223.6672, 1821.7823, 41.8300 }, // to finalize an ingot
	{ "Basement: Gun Finalization", -1227.2146, 1835.9607, 41.6191 } // to create a gun part out of ingots

}, 	DynamicText3D: gc_Label [ sizeof ( GunCreation ) ] ;


new GunCreationArea ;
Init_GunCreationArea ( ) {

	GunCreationArea = CreateDynamicRectangle(-1212.3748, 1813.9226, -1228.6282, 1838.9640 ) ;

	new count ;

	for ( new i; i < sizeof ( GunCreation ) ; i ++ ) {

		gc_Label [ i ] = CreateDynamic3DTextLabel(sprintf("%s\n{DEDEDE}Press ~k~~SNEAK_ABOUT~ to use.", GunCreation [ i ] [ gc_name ]), 
			0x966C5DFF, GunCreation [ i ] [ gc_pos_x ], GunCreation [ i ] [ gc_pos_y ], GunCreation [ i ] [ gc_pos_z ], 15.0 ) ;
	
		count ++ ;
	}

	printf(" * [ILLEGAL GUNS] Set up %d gun labels", count ) ;

	return true ;
}

new PlayerGunProgress 				[ MAX_PLAYERS ] ;

new PlayerGunOre 					[ MAX_PLAYERS ] ;
new PlayerGunSecondaryOre 			[ MAX_PLAYERS ] ;

new PlayerCraftingGunComponant 		[ MAX_PLAYERS ] ;

timer FurnaceRefillTime[750](playerid, ticks, Float: amount ) {

	PlayerGunProgress [ playerid ] += 2 ;

	SetPlayerProgressBarValue(playerid, actionGUI_bar, PlayerGunProgress [ playerid ] ) ;
	//PlayerTextDrawSetString(playerid, actionGUI_infoText, sprintf("@ Overall Progress: %d~n~Copper Ore: %d~n~Tin Ore: %d~n~Status: Refuelling", PlayerGunProgress [ playerid ], PlayerGunOre [ playerid ], PlayerGunSecondaryOre [ playerid ] ) ) ;

	ActionPanel_ChangeGUI ( playerid, sprintf("@ Overall Progress: %d~n~Copper Ore: %d~n~Tin Ore: %d~n~Status: Refuelling", PlayerGunProgress [ playerid ], PlayerGunOre [ playerid ], PlayerGunSecondaryOre [ playerid ] )) ;


	if ( PlayerGunProgress [ playerid ] >= 100 ) {

		if ( GivePlayerItemByParam ( playerid, PARAM_GUNCREATION, FRACTURED_SUBSTANCE, 1, 0, FRACTURED_SUBSTANCE, 0 ) ) { 

			PlayerGunProgress [ playerid ] = 0 ;
			PlayerGunOre [ playerid ] = 0 ;
			PlayerGunSecondaryOre [ playerid ] = 0 ;
			return SendServerMessage ( playerid, "You have received a fractured substance. Cool it down to form it into an ingot.", MSG_TYPE_INFO ) ;
		}

		else return SendServerMessage ( playerid, "Something went wrong. You were meant to get a Fractured Substance. Ask a dev for a refund and take a screenshot.", MSG_TYPE_ERROR ) ;
	}

	if ( ticks > 0 ) {

		ticks -- ;

		defer FurnaceRefillTime(playerid, ticks, amount ) ;
	}

	else if ( ticks <= 0 ) {

		SendServerMessage ( playerid, "The furnace seems to have died down - you should refill it.", MSG_TYPE_ERROR ) ;
		//PlayerTextDrawSetString(playerid, actionGUI_infoText, sprintf("@ Overall Progress: %d~n~Copper Ore: %d~n~Tin Ore: %d~n~Status: Idle", PlayerGunProgress [ playerid ], PlayerGunOre [ playerid ], PlayerGunSecondaryOre [ playerid ] ) ) ;

		ActionPanel_ChangeGUI ( playerid, sprintf("@ Overall Progress: %d~n~Copper Ore: %d~n~Tin Ore: %d~n~Status: Idle", PlayerGunProgress [ playerid ], PlayerGunOre [ playerid ], PlayerGunSecondaryOre [ playerid ] ) ) ;
	}

	return true ;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

	if ( newkeys & KEY_WALK && IsPlayerInGunCreationArea ( playerid ) ) {

		if(!IsPlayerManager(playerid)) { return SendServerMessage(playerid,"Gun creation has been disabled while we fix the current issues with it, sorry for the inconvenience.",MSG_TYPE_ERROR); }
	
		if ( Character [ playerid ] [ character_level ] < 3 ) {

			return SendServerMessage ( playerid, "Your level must at least be 3.", MSG_TYPE_ERROR ) ;
		}

		if ( IsPlayerInRangeOfPoint ( playerid, 2.5, -1212.5631, 1831.2927, 42.3896 ) ) { // coal pickup

			if ( DoesPlayerHaveItemByExtraParam ( playerid, FURNACE_COAL ) != -1 ) {

				return SendServerMessage ( playerid, "You already have some coal. Add it to the furnace before getting some more.", MSG_TYPE_ERROR );
			}

			if ( GivePlayerItemByParam ( playerid, PARAM_GUNCREATION, FURNACE_COAL, 1, 0, 0, 0 ) ) { 

				SendServerMessage ( playerid, "You picked up some coal. Add it to the furnace to continue the smelting process.", MSG_TYPE_INFO ) ;
			}

			else return SendServerMessage ( playerid, "Something went wrong. You were meant to get Furnace Coal. Ask a dev for a refund and take a screenshot.", MSG_TYPE_ERROR ) ;
		}

		else if ( IsPlayerInRangeOfPoint ( playerid, 2.5, -1218.0070, 1825.6216, 41.7440 ) ) { // gunpart creation

			if ( DoesPlayerHaveItemByExtraParam ( playerid, INGOT  ) == -1 ) {

				return SendServerMessage ( playerid, "You don't have an ingot to reform.", MSG_TYPE_ERROR );
			}

			if ( GivePlayerItemByParam ( playerid, PARAM_GUNCREATION, GUNPART, 1, 0, 0, 0 ) ) { 

				DiscardItem ( playerid, DoesPlayerHaveItemByExtraParam ( playerid, INGOT) ) ;
				SendServerMessage ( playerid, "You formed the ingot into a gunpart.", MSG_TYPE_INFO ) ;
			}

			else return SendServerMessage ( playerid, "Something went wrong. You were meant to get a Gunpart. Ask a dev for a refund and take a screenshot.", MSG_TYPE_ERROR ) ;
		}

		else if ( IsPlayerInRangeOfPoint ( playerid, 2.5, -1223.6672, 1821.7823, 41.8300 )) { // ingot creation

			// Make sure they get an object for this - also add the ingot.

			if ( DoesPlayerHaveItemByExtraParam ( playerid, FRACTURED_SUBSTANCE ) != -1 ) {

				if ( PlayerSkill [ playerid ] [ JOB_blacksmith ] == 6 ) {

					if ( GivePlayerItemByParam ( playerid, PARAM_GUNCREATION, INGOT, 3, 0, 0, 0 ) ) {

						DecreaseItem ( playerid, DoesPlayerHaveItemByExtraParam ( playerid, FRACTURED_SUBSTANCE) ) ;
						SendServerMessage ( playerid, "You reform the Fractured Substance into a strong ingot.", MSG_TYPE_INFO ) ;
					}

					else return SendServerMessage ( playerid, "Something went wrong. You were meant to get an ingot. Ask a dev for a refund and take a screenshot.", MSG_TYPE_ERROR ) ;
				}

				else if ( PlayerSkill [ playerid ] [ JOB_blacksmith ] >= 4 && PlayerSkill [ playerid ] [ JOB_blacksmith ] < 6 ) {

					if ( GivePlayerItemByParam ( playerid, PARAM_GUNCREATION, INGOT, 2, 0, 0, 0 ) ) {

						DecreaseItem ( playerid, DoesPlayerHaveItemByExtraParam ( playerid, FRACTURED_SUBSTANCE) ) ;
						SendServerMessage ( playerid, "You reform the Fractured Substance into a strong ingot.", MSG_TYPE_INFO ) ;
					}

					else return SendServerMessage ( playerid, "Something went wrong. You were meant to get an ingot. Ask a dev for a refund and take a screenshot.", MSG_TYPE_ERROR ) ;
				}

				else if ( PlayerSkill [ playerid ] [ JOB_blacksmith ] <= 3 ) {

					if ( GivePlayerItemByParam ( playerid, PARAM_GUNCREATION, INGOT, 1, 0, 0, 0 ) ) {

						DecreaseItem ( playerid, DoesPlayerHaveItemByExtraParam ( playerid, FRACTURED_SUBSTANCE) ) ;
						SendServerMessage ( playerid, "You reform the Fractured Substance into a strong ingot.", MSG_TYPE_INFO ) ;
					}

					else return SendServerMessage ( playerid, "Something went wrong. You were meant to get an ingot. Ask a dev for a refund and take a screenshot.", MSG_TYPE_ERROR ) ;
				}

				else return SendServerMessage ( playerid, "Something went wrong. You were meant to get an ingot. Ask a dev for a refund and take a screenshot.", MSG_TYPE_ERROR ) ;
			}

			else return SendServerMessage ( playerid, "You don't have any Fractured Substance to reform.", MSG_TYPE_ERROR ) ;
		}

		else if ( IsPlayerInRangeOfPoint ( playerid, 2.5, -1214.9054, 1819.7556, 40.3845 )) { // furnace

			if ( PlayerGunOre [ playerid ] < 10 || PlayerGunSecondaryOre [ playerid ] < 5 ) {

				if ( PlayerGunOre [ playerid ] < 10 ) {

					if ( DoesPlayerHaveItemByExtraParam ( playerid, MINE_COPPER_ORE ) == -1 ) {

						return SendServerMessage ( playerid, "You need to have some copper ore to add to the furnace.", MSG_TYPE_ERROR ) ;
					}

					PlayerGunOre [ playerid ] ++ ;
					DecreaseItem ( playerid, DoesPlayerHaveItemByExtraParam ( playerid, MINE_COPPER_ORE ), 1 ) ;

					SendServerMessage ( playerid, sprintf("Added some copper ore to the furnace. You need to add %d more.", 10 - PlayerGunOre [ playerid ] ), MSG_TYPE_INFO ) ;
				}

				else if ( PlayerGunOre [ playerid ] >= 10 &&  PlayerGunSecondaryOre [ playerid ] < 5 ) {

					if ( DoesPlayerHaveItemByExtraParam ( playerid, MINE_TIN_ORE ) == -1 ) {

						return SendServerMessage ( playerid, "You need to have some tin ore to add to the furnace.", MSG_TYPE_ERROR ) ;
					}

					PlayerGunSecondaryOre [ playerid ] ++ ;
					DecreaseItem ( playerid, DoesPlayerHaveItemByExtraParam ( playerid, MINE_TIN_ORE ), 1 ) ;

					SendServerMessage ( playerid, sprintf("Added some tin ore to the furnace. You need to add %d more.", 5 - PlayerGunSecondaryOre [ playerid ] ), MSG_TYPE_INFO ) ;
				}


			}

			else if ( PlayerGunOre [ playerid ] >= 10 && PlayerGunSecondaryOre [ playerid ] >= 5 ) {

				if ( DoesPlayerHaveItemByExtraParam ( playerid, FRACTURED_SUBSTANCE ) != -1 ) {

					return SendServerMessage ( playerid, "You have a fractured substance. You need to cool it down in order to make an ingot out of it.", MSG_TYPE_ERROR );
				}

				if ( DoesPlayerHaveItemByExtraParam ( playerid, FURNACE_COAL ) == -1 ) {

					return SendServerMessage ( playerid, "You don't have any raw material to fuel the furnace with.", MSG_TYPE_ERROR ) ;
				}

				else if ( DoesPlayerHaveItemByExtraParam ( playerid, FURNACE_COAL) != -1 ) {

					SendServerMessage ( playerid, "You've added some coal to the furnace.", MSG_TYPE_INFO ) ;
					DiscardItem ( playerid, DoesPlayerHaveItemByExtraParam ( playerid, FURNACE_COAL ) ) ;

					defer FurnaceRefillTime(playerid, 10, 0.75 ) ;
				}

				PlayerGunProgress [ playerid ] += 5 ;
			}
		}

		else if ( IsPlayerInRangeOfPoint ( playerid, 2.5, -1227.2146, 1835.9607, 41.6191 ) ) { //gun creation

			if ( DoesPlayerHaveItemByExtraParam ( playerid, GUNPART ) == -1 ) {

				return SendServerMessage ( playerid, "You don't have a gunpart.", MSG_TYPE_ERROR ) ;
			}

			if ( Character [ playerid ] [ character_handweapon ] ) {

	      		return SendServerMessage ( playerid, "You can't create a weapon whilst you already have one equipped.", MSG_TYPE_ERROR ) ;
	      	}

	      	if ( PlayerCraftingGunComponant [ playerid ] ) {

	      		return SendServerMessage ( playerid, "You are already crafting a weapon or ammo.", MSG_TYPE_ERROR ) ;
	      	}

		 	inline GunCreationSelection(pid, dialogid, response, listitem, string: inputtext[]) {
	   			#pragma unused pid, dialogid, inputtext

		 		if ( ! response ) {

		 			return false ;
		 		}

		 		else if ( response ) {

		 			new amount = -1 ;
		 			switch ( listitem ) {

		 				case 0: { // deagle - 4

		 					if ( Character [ playerid ] [ character_level ] < 4 ) {

		 						return SendServerMessage ( playerid, "You need to be level 4 to craft a revolver.", MSG_TYPE_ERROR ) ;
		 					}
		 					
		 					if ( GetTotalItemAmountByExtraParam ( playerid, GUNPART ) >= 4 ) {

		 						amount = 4 ;
		 					}

		 					else return SendServerMessage ( playerid, "You don't have enough gunparts. You need at least 4.", MSG_TYPE_ERROR ) ;
		 				}

		 				case 1: { // shotgun - 6

		 					if ( Character [ playerid ] [ character_level ] < 4 ) {

		 						return SendServerMessage ( playerid, "You need to be level 4 to craft a shotgun.", MSG_TYPE_ERROR ) ;
		 					}
		 						
		 					if ( GetTotalItemAmountByExtraParam ( playerid, GUNPART ) >= 6 ) {

		 						amount = 6 ;
		 					}

		 					else return SendServerMessage ( playerid, "You don't have enough gunparts. You need at least 6.", MSG_TYPE_ERROR ) ;
		 				}

		 				case 2: { // Sawn off - 6

		 					if ( Character [ playerid ] [ character_level ] < 3 ) {

		 						return SendServerMessage ( playerid, "You need to be level 3 to craft a sawn off shotgun.", MSG_TYPE_ERROR ) ;
		 					}

		 					if ( GetTotalItemAmountByExtraParam ( playerid, GUNPART ) >= 6 ) {

		 						amount = 6 ;
		 					}

		 					else return SendServerMessage ( playerid, "You don't have enough gunparts. You need at least 6.", MSG_TYPE_ERROR ) ;		 					
		 				}

		 				case 3: { // rifle - 8

		 					if ( Character [ playerid ] [ character_level ] < 6 ) {

		 						return SendServerMessage ( playerid, "You need to be level 6 to craft a rifle.", MSG_TYPE_ERROR ) ;
		 					}

		 					if ( GetTotalItemAmountByExtraParam ( playerid, GUNPART ) >= 8 ) {

		 						amount = 8 ;
		 					}

		 					else return SendServerMessage ( playerid, "You don't have enough gunparts. You need at least 8.", MSG_TYPE_ERROR ) ;		 					
		 				}

		 				case 4: { // sniper - 8

		 					if ( Character [ playerid ] [ character_level ] < 8 ) {

		 						return SendServerMessage ( playerid, "You need to be level 8 to craft a scoped rifle.", MSG_TYPE_ERROR ) ;
		 					}
		 					
		 					if ( GetTotalItemAmountByExtraParam ( playerid, GUNPART ) >= 8 ) {

		 						amount = 8 ;
		 					}

		 					else return SendServerMessage ( playerid, "You don't have enough gunparts. You need at least 8.", MSG_TYPE_ERROR ) ;
		 				}
		 				case 5: { // pistol ammo - 3
		 					
		 					if ( GetTotalItemAmountByExtraParam ( playerid, GUNPART ) >= 3 ) {

		 						if ( GetPlayerItemCount ( playerid ) >= GetMaxPlayerItems ( ) ) {

									return SendServerMessage ( playerid, "You don't have enough inventory slots!", MSG_TYPE_ERROR) ;
								}

								if ( GetPlayerItemCount ( playerid ) >= GetPlayerBackpackSize ( playerid ) ) {

									return SendServerMessage ( playerid, "You don't have enough backpack size to pick this item up. You have to get a bigger backpack.", MSG_TYPE_ERROR ) ;
								}

		 						amount = 3 ;
		 					}

		 					else return SendServerMessage ( playerid, "You don't have enough gunparts. You need at least 3.", MSG_TYPE_ERROR ) ;
		 				}
		 				case 6: { // shotgun ammo - 4
		 					
		 					if ( GetTotalItemAmountByExtraParam ( playerid, GUNPART ) >= 4 ) {

		 						if ( GetPlayerItemCount ( playerid ) >= GetMaxPlayerItems ( ) ) {

									return SendServerMessage ( playerid, "You don't have enough inventory slots!", MSG_TYPE_ERROR) ;
								}

								if ( GetPlayerItemCount ( playerid ) >= GetPlayerBackpackSize ( playerid ) ) {

									return SendServerMessage ( playerid, "You don't have enough backpack size to pick this item up. You have to get a bigger backpack.", MSG_TYPE_ERROR ) ;
								}

		 						amount = 4 ;
		 					}

		 					else return SendServerMessage ( playerid, "You don't have enough gunparts. You need at least 4.", MSG_TYPE_ERROR ) ;
		 				}
		 				case 7: { // rifle ammo - 5
		 					
		 					if ( GetTotalItemAmountByExtraParam ( playerid, GUNPART ) >= 5 ) {

		 						if ( GetPlayerItemCount ( playerid ) >= GetMaxPlayerItems ( ) ) {

									return SendServerMessage ( playerid, "You don't have enough inventory slots!", MSG_TYPE_ERROR) ;
								}

								if ( GetPlayerItemCount ( playerid ) >= GetPlayerBackpackSize ( playerid ) ) {

									return SendServerMessage ( playerid, "You don't have enough backpack size to pick this item up. You have to get a bigger backpack.", MSG_TYPE_ERROR ) ;
								}

		 						amount = 5 ;
		 					}

		 					else return SendServerMessage ( playerid, "You don't have enough gunparts. You need at least 5.", MSG_TYPE_ERROR ) ;
		 				}
		 			}

		 			if ( amount != -1 ) { 

		 				if ( PlayerSkill [ playerid ] [ JOB_blacksmith ] == 6 ) { defer GunCreationTimer[LVL3GUNSMITHTIME](playerid, listitem, amount); defer GunCreationCountdownTimer(playerid, 20); }
		 				else if ( PlayerSkill [ playerid ] [ JOB_blacksmith ] >= 4 && PlayerSkill [ playerid ] [ JOB_blacksmith ] < 6 ) { defer GunCreationTimer[LVL2GUNSMITHTIME](playerid, listitem, amount); defer GunCreationCountdownTimer(playerid, 40); }
		 				else if ( PlayerSkill [ playerid ] [ JOB_blacksmith ] < 2 ) { defer GunCreationTimer[LVL1GUNSMITHTIME](playerid, listitem, amount); defer GunCreationCountdownTimer(playerid, 60); }
		 				TogglePlayerControllable ( playerid, 0 ) ;

		 				PlayerCraftingGunComponant [ playerid ] = 1 ;

		 			}

		 			else return SendServerMessage ( playerid, "Something went wrong, please send a screenshot to a dev.", MSG_TYPE_ERROR ) ;
		 		}
		 	}

			return Dialog_ShowCallback ( playerid, using inline GunCreationSelection, DIALOG_STYLE_TABLIST_HEADERS, sprintf("Select the weapon you want to produce. - Weapon Parts: %d",GetTotalItemAmountByExtraParam ( playerid, GUNPART )), 
				"Weapon\tAmount\n\
				Revolver\t4 Gunparts\n\
				Shotgun\t6 Gunparts\n\
				Sawed off Shotgun\t6 Gunparts\n\
				Rifle\t8 Gunparts\n\
				Sniper\t8 Gunparts\n\
				Pistol Ammo\t3 Gunparts\n\
				Shotgun Ammo\t4 Gunparts\n\
				Rifle Ammo\t5 Gunparts\n", 

				"Select", "Cancel" 
			);
		}
	}
	
	#if defined gun2_OnPlayerKeyStateChange
		return gun2_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif

#define OnPlayerKeyStateChange gun2_OnPlayerKeyStateChange
#if defined gun2_OnPlayerKeyStateChange
	forward gun2_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

public OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid) {

	if ( areaid == GunCreationArea ) {

		if(IsPlayerManager(playerid)) { SetupActionGUI ( playerid, ACTION_TYPE_GUN ) ; }
	}
	
	#if defined gun2_OnPlayerEnterDynamicArea
		return gun2_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif

#define OnPlayerEnterDynamicArea gun2_OnPlayerEnterDynamicArea
#if defined gun2_OnPlayerEnterDynamicArea
	forward gun2_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid);
#endif

public OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid) {

	if ( areaid == GunCreationArea ) {

		HideActionGUI ( playerid ) ;
	}
	
	#if defined gun2_OnPlayerLeaveDynamicArea
		return gun2_OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLeaveDynamicArea
	#undef OnPlayerLeaveDynamicArea
#else
	#define _ALS_OnPlayerLeaveDynamicArea
#endif

#define OnPlayerLeaveDynamicArea gun2_OnPlayerLeaveDynamicArea
#if defined gun2_OnPlayerLeaveDynamicArea
	forward gun2_OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid );
#endif

IsPlayerInGunCreationArea ( playerid ) {

	if ( IsPlayerInDynamicArea(playerid, GunCreationArea ) ) {

		return true ;
	}

	else return false ;
}

timer GunCreationTimer[60000](playerid, id, amount) {

	switch ( id ) {

		case 0: {

			wep_GivePlayerWeapon ( playerid, WEAPON_DEAGLE, 0 ) ;
			SendServerMessage ( playerid, "You have crafted a Revolver.", MSG_TYPE_INFO ) ;
		}

		case 1: {

			wep_GivePlayerWeapon ( playerid, WEAPON_SHOTGUN, 0 ) ;
			SendServerMessage ( playerid, "You have crafted a Shotgun.", MSG_TYPE_INFO ) ;
		}

		case 2: {

			wep_GivePlayerWeapon ( playerid, WEAPON_SAWEDOFF, 0 ) ;
			SendServerMessage ( playerid, "You have crafted a Sawn Off Shotgun.", MSG_TYPE_INFO ) ;
		}

		case 3: {

			wep_GivePlayerWeapon ( playerid, WEAPON_RIFLE, 0 ) ;
			SendServerMessage ( playerid, "You have crafted a Rifle.", MSG_TYPE_INFO ) ;
		}

		case 4: {

			wep_GivePlayerWeapon ( playerid, WEAPON_SNIPER, 0 ) ;
			SendServerMessage ( playerid, "You have crafted a Sniper.", MSG_TYPE_INFO ) ;
		}

		case 5: {

			GivePlayerItemByParam ( playerid, PARAM_AMMO, AMMO_CRATE_PISTOL, 1, 0, 0, 0 ) ;
			SendServerMessage ( playerid, "You have crafted a Pistol Ammo Crate.", MSG_TYPE_INFO ) ;
		}

		case 6: {

			GivePlayerItemByParam ( playerid, PARAM_AMMO, AMMO_CRATE_SHOTGUN, 1, 0, 0, 0 ) ;
			SendServerMessage ( playerid, "You have crafted a Shotgun Ammo Crate.", MSG_TYPE_INFO ) ;
		}

		case 7: {

			GivePlayerItemByParam ( playerid, PARAM_AMMO, AMMO_CRATE_RIFLE, 1, 0, 0, 0 ) ;
			SendServerMessage ( playerid, "You have crafted a Rifle Ammo Crate.", MSG_TYPE_INFO ) ;
		}

		default: { return SendServerMessage ( playerid, sprintf("Something went wrong, take a screenshot and send it to a dev.  ID: %i", id ), MSG_TYPE_ERROR ) ; }
	}

	TogglePlayerControllable ( playerid, 1 ) ;

	PlayerCraftingGunComponant [ playerid ] = 0 ;

	return DecreaseItemByExtraParam ( playerid, GUNPART, amount ) ;
}

timer GunCreationCountdownTimer[975](playerid, time) {

	if ( time <= 0 ) { return true ; }

	GameTextForPlayer(playerid, sprintf("~r~%d~w~ seconds left.", time)	, 974, 3 ) ;

	defer GunCreationCountdownTimer(playerid, time-1);
	return true ;
}