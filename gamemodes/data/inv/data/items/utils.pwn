#if defined _inc_utils
	#undef _inc_utils
#endif

DiscardItem ( playerid, tileid ) {

	if ( tileid == -1 ) {

		return false ;
	}

	new query [ 128 ], viewing_inventory = IsPlayerViewingInventory [ playerid ] ; 

	mysql_format ( mysql,query, sizeof ( query ), "DELETE FROM items_player WHERE player_table_id = %d AND player_database_id = %d", 
	PlayerItem [ playerid ] [ tileid ] [ player_table_id ],  Character [ playerid ] [ character_id ]) ;

	mysql_tquery ( mysql, query ) ;

	PlayerItem [ playerid ] [ tileid ] [ player_item_id ] = INVALID_ITEM_ID ;
	PlayerItem [ playerid ] [ tileid ] [ player_item_amount ] = 0 ;

	PlayerItem [ playerid ] [ tileid ] [ player_item_param1 ] = 0;
	PlayerItem [ playerid ] [ tileid ] [ player_item_param2 ] = 0;

	if(EquippedItem [ playerid ] != -1 && EquippedItemTile[playerid] == tileid) {

		RemovePlayerAttachedObject(playerid,ATTACH_SLOT_EQUIP);
		EquippedItem[playerid] = -1;
		EquippedItemTile[playerid] = -1;
		UpdateWeaponGUI(playerid);
	}

	ToggleInventory ( playerid, INV_MAX_TILES, false ) ;
	HideInventoryExamineGUI ( playerid ) ;
	
	//// UpdateWeaponGUI ( playerid );
	//Init_LoadPlayerItems ( playerid ) ;
	HasPlayerInventoryUpdated[playerid] = true;

	CancelSelectTextDraw ( playerid ) ;

	if ( viewing_inventory ) {

		//Init_LoadPlayerItems ( playerid ) ;

		SendServerMessage ( playerid, "Refreshing inventory, hold on a moment.", MSG_TYPE_WARN ) ;
		defer DelayedInventory(playerid);
	}
	else {

		HasPlayerInventoryUpdated[playerid] = true;
		ReturnPlayerItemCount[playerid]--;
	}

	// New with new inv system

	return true ;
}

timer DelayedInventory[750](playerid){
 
	InitiateInventoryTiles ( playerid, PlayerInventoryPage [ playerid ]) ;
	return true ;
}

new PlayerEquipTick [ MAX_PLAYERS ] ;
new PlayerFoodCooldown [ MAX_PLAYERS ] ;

OnPlayerUseItem ( playerid, itemid, tileid ){

	if ( ! Item [ itemid ] [ item_toggle ] ) {
		return SendServerMessage ( playerid, "This item serves either no function, or it isn't enabled.", MSG_TYPE_ERROR ) ;
	}

	switch ( Item [ itemid ] [ item_type ] ){
		case ITEM_TYPE_UNDEFINED: {
			return SendServerMessage ( playerid, "This item has no use!", MSG_TYPE_ERROR ) ;
		}

		case ITEM_TYPE_MISC: {
			// Quest items, collectibles, etc

		}

		case ITEM_TYPE_FOOD: {
			// Add ConsumeFood here

			if ( Item [ itemid ] [ item_extra_param ] == FOOD_APPLE_RED || Item [ itemid ] [ item_extra_param ] == FOOD_APPLE_GREEN ) {

				new Float: x, Float: y, Float: z ;

				if ( Character [ playerid ] [ character_horseid ] < DONATOR_MOUNT_SLOT ) {
					GetDynamicObjectPos (HorseObject [ playerid ], x, y, z  ) ;
				}

				else GetDynamicObjectPos ( CowObject [ playerid ], x, y, z ) ;

				if ( IsPlayerInRangeOfPoint ( playerid, 1.5, x, y, z ) || IsPlayerRidingHorse [ playerid ] )  {

					inline Food_UsageDecision(pid, dialogid, response, listitem, string:inputtext[]) {

				        #pragma unused pid, dialogid, response, inputtext

						switch ( listitem ) {

							case 0: { // feed horse
							
								new Float: hp = Character [ playerid ] [ character_horsehealth ], Float: amount ;
								amount = hp + 25 ;

								if ( hp <= 0 ) {

									return SendServerMessage ( playerid, "Your horse is dead. You have to revive it first by going to a stablemaster.", MSG_TYPE_ERROR ) ;
								}

								if ( hp >= 100 ) {
									SetHorseHealth ( playerid, -1, 100 ) ;
									return SendServerMessage ( playerid, "Your horse already has full health. There's no point in feeding it.", MSG_TYPE_INFO ) ;
								}

								if ( hp >= 75 ) {
									amount = 100 ;
								}

								SetHorseHealth ( playerid, -1, amount ) ;

								if ( Character [ playerid ] [ character_horseid ] < DONATOR_MOUNT_SLOT ) {
									SendServerMessage ( playerid, sprintf("You've fed your horse. It now has %.0f health.", Character [ playerid ] [ character_horsehealth ] ), MSG_TYPE_INFO ) ;
									ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has fed their horse an apple.",ReturnUserName ( playerid, false ))) ;
								}

								else {

									SendServerMessage ( playerid, sprintf("You've fed your cow. It now has %.0f health.", Character [ playerid ] [ character_horsehealth ] ), MSG_TYPE_INFO ) ;
									ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has fed their cow an apple.",ReturnUserName ( playerid, false ))) ;
								}

								DecreaseItem ( playerid, tileid, 1 ) ;

								return true ;
							}

							case 1: { // feed player

								goto skipHorse;

								/*
								if ( IsPlayerBleeding [ playerid ] ) {

									return SendServerMessage ( playerid, "You can't use this wehn you're bleeding.", MSG_TYPE_ERROR ) ;
								}

								if ( Character [ playerid ] [ character_health ] >= 100 ) {

									return SendServerMessage ( playerid, "Your health is already full - there's no need to heal.", MSG_TYPE_ERROR ) ;
								}

								if ( PlayerFoodCooldown [ playerid ]  >= gettime ()) {

									return SendServerMessage ( playerid, sprintf("You need to wait %d seconds before eating something else.", PlayerFoodCooldown[playerid] - gettime ()), MSG_TYPE_WARN ) ;
								}

								PlayerFoodCooldown [ playerid ] = gettime () + 30 ;

								SetCharacterHealth ( playerid, Character [ playerid ] [ character_health ] + 25 ) ;

								return SendServerMessage ( playerid, "You have been healed 25 percent of your health.", MSG_TYPE_INFO ) ;
								*/
							}
						}
				    }
				    return Dialog_ShowCallback(playerid, using inline Food_UsageDecision, DIALOG_STYLE_LIST, "You're near your mount - choose your action", "Feed your horse\nEat the food yourself", "Cancel", "Select" ) ;
				}

			    else { // if not near horse, feed player...

			    	skipHorse:

					if ( IsPlayerBleeding [ playerid ] ) {

						return SendServerMessage ( playerid, "You cannot eat or drink whilst bleeding.", MSG_TYPE_ERROR ) ;
					}

					ConsumeFood ( playerid, itemid ) ;
					DecreaseItem ( playerid, tileid, 1 ) ;
					return true;
			    }
			}
			else {

				if ( IsPlayerBleeding [ playerid ] ) {

					return SendServerMessage ( playerid, "You cannot eat or drink whilst bleeding.", MSG_TYPE_ERROR ) ;
				}

				ConsumeFood ( playerid, itemid ) ;
				DecreaseItem ( playerid, tileid, 1 ) ;
				return true;
			}
		}

		case ITEM_TYPE_USE: {

			switch ( Item [ itemid ] [ item_extra_param ] ) {

				case BANDAGE: {

					SendServerMessage ( playerid, "Press ~k~~PED_FIREWEAPON~ to cancel bandaging yourself. The bandage will be used once it finished bandaging you.", MSG_TYPE_WARN ) ;

					IsPlayerBandaging [ playerid ] = 1 ;
					OnPlayerBandage ( playerid, itemid, tileid ) ;

					TogglePlayerControllable ( playerid, false ) ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("** %s has started bandaging themselves.", ReturnUserName ( playerid, false ))) ;

					return true ;
				}

				case FARMING_SOIL_BAG: {

					CreateSoil ( playerid ) ;

					SendServerMessage(playerid, "If the farming soil seems to be bugged (underground / labels disappearing) please use /fixsoil and /refreshsoil.", MSG_TYPE_INFO);
				}

				case AMMO_CRATE_PISTOL, FACTION_AMMO_PISTOL : {
					if ( Character [ playerid ] [ character_handweapon] != WEAPON_DEAGLE ) {

						return SendServerMessage ( playerid, "You need to have a pistol equipped in order to do this.", MSG_TYPE_ERROR ) ;
					}

					if ( Character [ playerid ] [ character_handammo ] ) {

						return SendServerMessage ( playerid, "Your equipped weapon still has ammo left. Only use this when you have none. ", MSG_TYPE_ERROR ) ;
					}

					new restoredata = Character [ playerid ] [ character_handweapon] ;

					RemovePlayerWeapon ( playerid ) ;
					wep_GivePlayerWeapon ( playerid, restoredata, 6 ) ;

					ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s used an ammo pack for their revolver.", ReturnUserName ( playerid, true, true ) ) ) ;
					SendServerMessage ( playerid, "You've used an ammopack on your revolver and refilled it with ammo.", MSG_TYPE_INFO ) ;

					SavePlayerWeapons ( playerid ) ;
				}

				case AMMO_CRATE_SHOTGUN, FACTION_AMMO_SHOTGUN : {

					if ( Character [ playerid ] [ character_handweapon] == WEAPON_SHOTGUN || Character [ playerid ] [ character_handweapon] == WEAPON_SAWEDOFF ) {

						if ( Character [ playerid ] [ character_handammo ] ) {

							return SendServerMessage ( playerid, "Your equipped weapon still has ammo left. Only use this when you have none. ", MSG_TYPE_ERROR ) ;
						}

						new restoredata = Character [ playerid ] [ character_handweapon] ;
						RemovePlayerWeapon ( playerid ) ;

						switch ( restoredata ) {

							case WEAPON_SHOTGUN: wep_GivePlayerWeapon ( playerid, restoredata, 8 ) ;
							case WEAPON_SAWEDOFF: wep_GivePlayerWeapon ( playerid, restoredata, 2 ) ;
						}

						ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s used an ammo pack for their shotgun.", ReturnUserName ( playerid, true, true ) ) ) ;
						SendServerMessage ( playerid, "You've used an ammopack on your shotgun and refilled it with ammo.", MSG_TYPE_INFO ) ;

						SavePlayerWeapons ( playerid ) ;
					}

					else return SendServerMessage ( playerid, "You need to have a shotgun equipped in order to do this.", MSG_TYPE_ERROR ) ;
				}

				case AMMO_CRATE_RIFLE, FACTION_AMMO_RIFLE : {

					if ( Character [ playerid ] [ character_handweapon] == WEAPON_RIFLE || Character [ playerid ] [ character_handweapon] == WEAPON_SNIPER ) {

						if ( Character [ playerid ] [ character_handammo ] ) {

							return SendServerMessage ( playerid, "Your equipped weapon still has ammo left. Only use this when you have none. ", MSG_TYPE_ERROR ) ;
						}

						new restoredata = Character [ playerid ] [ character_handweapon] ;

						RemovePlayerWeapon ( playerid ) ;
						wep_GivePlayerWeapon ( playerid, restoredata, 5 ) ;

						ProxDetector ( playerid, 20, COLOR_ACTION, sprintf( "* %s used an ammo pack for their rifle.", ReturnUserName ( playerid, true, true ) ) ) ;
						SendServerMessage ( playerid, "You've used an ammopack on your rifle and refilled it with ammo.", MSG_TYPE_INFO ) ;

						SavePlayerWeapons ( playerid ) ;
					}

					else return SendServerMessage ( playerid, "You need to have a rifle equipped in order to do this.", MSG_TYPE_ERROR ) ;
				}

				case HUNTING_TRAP : {
				    
				    new trapid = GetFreeTrapID();

				    if(!CreateTrap(playerid,trapid)) {
				    	return true;
				    }
				}

				case FARMING_SHOVEL: {

					new i = FindNearestSoil(playerid, 4.0);

					if(i == INVALID_SOIL_ID){
						return SendServerMessage(playerid, "You aren't near any plants.", MSG_TYPE_ERROR);
					} else {

						if(Soil[i][soil_state] == SOIL_STATE_EMPTY){

							Soil[i][soil_state] = SOIL_STATE_DIGGED;
							SendServerMessage(playerid, "You have dug a hole in the soil.", MSG_TYPE_INFO);
							SetupSoil(i);

						} 
						else if(Soil[i][soil_state] == SOIL_STATE_DIGGED){

							return SendServerMessage(playerid, "You can't use the shovel right now!", MSG_TYPE_ERROR);

						} 
						else if(Soil[i][soil_state] == SOIL_STATE_SEEDED){

							Soil[i][soil_state] = SOIL_STATE_GROWING;
							SendServerMessage(playerid, "You have covered the soil!", MSG_TYPE_INFO);
							SetupSoil(i);

							firstTick[i] = true;
							StartGrowingProcess(i);

						} else {
							return SendServerMessage(playerid, "You can't use this right now!", MSG_TYPE_ERROR);
						}
					}
					return true;
				}

				case FARMING_PAIL: {
						
					new i = FindNearestSoil(playerid, 4.0);

					if(i == INVALID_SOIL_ID){
						return SendServerMessage(playerid, "You aren't near any plants.", MSG_TYPE_ERROR);
					} else {

						switch(Soil[i][soil_water]){

							case SOIL_WATER_WATERED: {
								return SendServerMessage(playerid, "This plant doesn't need watering!", MSG_TYPE_ERROR);
							}

							case SOIL_WATER_MODERATE: {
								Soil[i][soil_water] = SOIL_WATER_WATERED;
								Soil[i][soil_health] = SOIL_HEALTH_HEALTHY;
								SetupSoil(i);

								SendServerMessage(playerid, "You have watered this plant.", MSG_TYPE_INFO);

								DecreaseItem(playerid, tileid, 1);
								GivePlayerItem ( playerid, FARMING_EMPTY_PAIL, 1, 0, 0, 0, 0, 0);
							}

							case SOIL_WATER_DEHYDRATED: {
								Soil[i][soil_water] = SOIL_WATER_WATERED;
								Soil[i][soil_health] = SOIL_HEALTH_HEALTHY;
								SetupSoil(i);

								SendServerMessage(playerid, "You have watered this plant.", MSG_TYPE_INFO);

								DecreaseItem(playerid, tileid, 1);
								GivePlayerItem ( playerid, FARMING_EMPTY_PAIL, 1, 0, 0, 0, 0, 0);
							}

							default: { return SendServerMessage(playerid, "You can't use this right now!", MSG_TYPE_ERROR); }
						}
					}
				}

				case FARMING_EMPTY_PAIL: {

					new i = FindNearestSoil(playerid, 4.0);

					if(i == INVALID_SOIL_ID){
						SendServerMessage(playerid, "You aren't near any plants.", MSG_TYPE_ERROR);
					} 
					else SendServerMessage(playerid, "You need to fill your pail with water first!", MSG_TYPE_ERROR);

					if(IsPlayerNearWater(playerid)){
						DecreaseItem(playerid, tileid, 1);
						GivePlayerItem ( playerid, FARMING_PAIL, 1, 0, 0, 0, 0, 0);

						SendServerMessage(playerid, "You have filled up your pail with water.", MSG_TYPE_INFO);
					} 
					else return SendServerMessage(playerid, "You aren't near any water!", MSG_TYPE_ERROR);

					return true;
				}

				case EMPTY_BASKET: {

					new i = FindNearestSoil(playerid, 4.0);

					if(i == INVALID_SOIL_ID){
						return SendServerMessage(playerid, "You aren't near any plants.", MSG_TYPE_ERROR);
					} else if(Soil[i][soil_state] == SOIL_STATE_GROWN){

						DecreaseItem ( playerid, tileid, 1 ) ;

						switch(Soil[i][soil_plant]){ 

							case SEED_ORANGE: {
								GivePlayerItem ( playerid, ORANGE_BASKET, 1, 0, 0, 0, 0, 0);
							}

							case SEED_APPLE_RED: {
								GivePlayerItem ( playerid, RAPPLE_BASKET, 1, 0, 0, 0, 0, 0);
							}

							case SEED_APPLE_GREEN: {
								GivePlayerItem ( playerid, GAPPLE_BASKET, 1, 0, 0, 0, 0, 0);
							}

							case SEED_TOMATO: {
								GivePlayerItem ( playerid, TOMATO_BASKET, 1, 0, 0, 0, 0, 0);
							}

							case SEED_CABBAGE: {
								GivePlayerItem ( playerid, CABBAGE_BASKET, 1, 0, 0, 0, 0, 0);
							}

							case SEED_WHEAT: {
								GivePlayerItem ( playerid, WHEAT_BASKET, 1, 0, 0, 0, 0, 0);
							}

							case SEED_PUMPKIN: {
								GivePlayerItem ( playerid, PUMPKIN_BASKET, 1, 0, 0, 0, 0, 0);
							}
						}
					}
					return true;
				}	
				


				case HUNTING_BAIT : {

					new trapid = FindNearestTrap(playerid,2.5);
					
					if(trapid == -1) { return SendServerMessage(playerid,"You're not near a trap.",MSG_TYPE_ERROR); }
					if(!DoesPlayerOwnTrap(playerid,trapid)) { return SendServerMessage(playerid,"You don't own this trap.",MSG_TYPE_ERROR); }
					if(IsTrapBaited(trapid)) { return SendServerMessage(playerid,"The trap already has bait on it.",MSG_TYPE_ERROR); }
					if(IsTrapArmed(trapid)) { return SendServerMessage(playerid,"You need to disarm this trap before applying bait.",MSG_TYPE_ERROR); }
					
					SetTrapBait(trapid);

					ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 0, 0, 0, 0, 0, 1);

			        ProxDetector(playerid, 20.0, COLOR_ACTION, sprintf("* %s applies bait to their trap.", ReturnUserName(playerid, false)));
				}
				case THERMOSTAT: {

					if(GetZoneTemperature(GetPlayerZone(playerid)) != INVALID_TEMPERATURE) { SendServerMessage(playerid,sprintf("The thermostat reads %d F°.",GetZoneTemperature(GetPlayerZone(playerid))),MSG_TYPE_INFO); }
					else { SendServerMessage(playerid,"You are in a zone that doesn't have a valid temperature.",MSG_TYPE_ERROR); }
					return true;
				}
				case GLOVES,LONG_JOHNS: {

					return SendServerMessage(playerid,"These items automatically help keep you warm in cold regions but heat you up in warmer regions.",MSG_TYPE_INFO);
				}
			}

		}

		case ITEM_TYPE_EQUIP: {
			/*
			////////////
			////// NOTE: Make sure to "return" the function, so it doesn't remove the quanity later on.
			//////////// 
			*/

			if ( EquippedItem [ playerid ] >= 0 ) {

				new equipitem = GetItemByParamID ( EquippedItem [ playerid ] ) ;

				RemovePlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP ) ;
				RemovePlayerWeapon ( playerid );

				EquippedItem [ playerid ] = -1 ;
				EquippedItemTile[playerid] = -1;
				UpdateWeaponGUI ( playerid );
				DisplayInventoryExamineGUI ( playerid, itemid, tileid ) ;

				ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has unequipped their %s.",ReturnUserName ( playerid, false, true ), Item [ equipitem ] [ item_name ] ) ) ;
				return SendServerMessage ( playerid, "The item you equipped before has been unequipped.", MSG_TYPE_ERROR ) ;
			}

			if ( Character [ playerid ] [ character_handweapon ] ) {

				return SendServerMessage ( playerid, "You have to holster your weapon before you can equip something.", MSG_TYPE_ERROR ) ;
			}

			if ( IsPlayerRidingHorse [ playerid ] ) {

				if(Item [ itemid ] [ item_extra_param ] == SHERIFF_LASSO){

					EquippedItem [ playerid ] = SHERIFF_LASSO ;
					EquippedItemTile [ playerid ] = tileid ;

					//SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, -0.018, 0.06, -0.025, 181.5, 17.5, 0.0, 1.0, 1.0, 1.0) ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has equipped a lasso.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "You've equipped a lasso. Use /lasso [targetid] to target someone then use LEFT-CLICK to try and catch them.", MSG_TYPE_INFO ) ;
					SendServerMessage(playerid, "Do not abuse the lasso for trolling. Ignoring this warning could lead you to an admin-jail or a ban.", MSG_TYPE_WARN);

				} else {
					return SendServerMessage ( playerid, "You cannot equip anything while riding a horse.", MSG_TYPE_ERROR ) ;
				}
			}

			new temp_Tick = GetTickCount(), temp_tickDiff ;
			temp_tickDiff = temp_Tick - PlayerEquipTick[playerid];
			
			if ( temp_tickDiff < 3000) {
			
				return SendServerMessage ( playerid, sprintf("You must wait %0.2f seconds before equipping something again.",float(3000 - temp_tickDiff) / 1000.0), MSG_TYPE_ERROR ) ;
			}		

			PlayerEquipTick [ playerid ]  = GetTickCount();		

			switch ( Item [ itemid ] [ item_extra_param ] ) {

				case CAMERA: {
					EquippedItem [ playerid ] = CAMERA ;
					EquippedItemTile [ playerid ] = tileid ;

					wep_GivePlayerWeapon ( playerid, WEAPON_CAMERA, 5 ) ;
					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, 0.08, 0.04, 0.1, 181.5, 0.0, 0.0, 1.0, 1.0, 1.0 ) ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has equipped a camera.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "You've equipped a camera. You can now use take pictures.", MSG_TYPE_INFO ) ;
				}

				case HUNTING_KNIFE: {
					EquippedItem [ playerid ] = HUNTING_KNIFE ;
					EquippedItemTile [ playerid ] = tileid ;

					//wep_GivePlayerWeapon ( playerid, WEAPON_KNIFE, 5 ) ;
					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, -0.018, 0.06, -0.025, 181.5, 17.5, 0.0, 1.0, 1.0, 1.0) ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has equipped a hunting knife.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "You've equipped a hunting knife. Press ~k~~SNEAK_ABOUT~ to skin a dead animal.", MSG_TYPE_INFO ) ;

				}

				case FISHING_ROD: {

					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, 0.08, 0.04, 0.1, 181.5, 0.0, 0.0, 1.0, 1.0, 1.0 ) ;

					EquippedItem [ playerid ] = FISHING_ROD ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has equipped a fishing rod.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "You've equipped a fishing rod. Press ~k~~SNEAK_ABOUT~ near water to fish.", MSG_TYPE_INFO ) ;	

					/*if ( TutorialProgress [ playerid ] > 2 && TutorialProgress [ playerid ] != 7) {

						TutorialProgress [ playerid ] ++ ;
						ProcessTutorialTask ( playerid ) ;
					}	*/				
				}

				case DYNAMITE: {
					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, 0.08, 0.04, 0.1, 181.5, 0.0, 0.0, 1.0, 1.0, 1.0 ) ;
					EquippedItem [ playerid ] = DYNAMITE ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has equipped a set of dynamite.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "You've equipped a dynamite set. You can now use /dynamite.", MSG_TYPE_INFO ) ;
				}

				case MINE_PICKAXE: {
					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, 0.0709,0.0519,0.1359,0.0000,0.0000,0.0000,1.0000,1.0000,1.0000 ) ;
					EquippedItem [ playerid ] = MINE_PICKAXE ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has equipped a pickaxe.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "You've equipped a pickaxe.  Press ~k~~SNEAK_ABOUT~ to mine a rock.", MSG_TYPE_INFO ) ;
				}

				case LUMBER_HATCHET: {
					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, 0.0709,0.0340,0.0000,0.0000,0.0000,-175.4997,1.0000,1.0000,1.0000 ) ;
					EquippedItem [ playerid ] = LUMBER_HATCHET ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has equipped a hatchet.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "You've equipped a hatchet. Press ~k~~SNEAK_ABOUT~ to chop a tree.", MSG_TYPE_INFO ) ;
				}

				case LIQUOR_PALELAGER: {

					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, 0.08, 0.04, -0.2, -0.2, 0.0, 3.8, 1, 1, 1 ) ;
					EquippedItem [ playerid ] = LIQUOR_PALELAGER ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has opened a bottle of Pale Lager Liquor.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "Use /drink to drink. You can unequip the bottle by using unequip.", MSG_TYPE_INFO ) ;	
				}

				case LIQUOR_MILDALE: {

					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, 0.08, 0.04, -0.2, -0.2, 0.0, 3.8, 1, 1, 1 ) ;
					EquippedItem [ playerid ] = LIQUOR_MILDALE ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has opened a bottle of Pale Lager Liquor.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "Use /drink to drink. You can unequip the bottle by using unequip.", MSG_TYPE_INFO ) ;	
				}

				case LIQUOR_MALTLIQUOR: {
					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, 0.08, 0.04, -0.2, -0.2, 0.0, 3.8, 1, 1, 1 ) ;
					EquippedItem [ playerid ] = LIQUOR_MALTLIQUOR ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has opened a bottle of Malt Liquor.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "Use /drink to drink. You can unequip the bottle by using unequip.", MSG_TYPE_INFO ) ;	
				}

				case LIQUOR_WHEATBEER: {
					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, 0.0, 0.0, -0.072, -0.2, 19.0, 3.8, 1.0, 1.0, 1.0 ) ;

					EquippedItem [ playerid ] = LIQUOR_WHEATBEER ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has opened a bottle of Wheat Beer.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "Use /drink to drink. You can unequip the bottle by using unequip.", MSG_TYPE_INFO ) ;	
				}

				case LIQUOR_WHITEWINE: {
					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, 0.08, 0.04, -0.292, -0.2, 0.0, 3.8, 0.81, 0.83, 0.703 ) ;
					EquippedItem [ playerid ] = LIQUOR_WHITEWINE ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has opened a bottle of White Wine.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "Use /drink to drink. You can unequip the bottle by using unequip.", MSG_TYPE_INFO ) ;	
				}

				case LIQUOR_REDWINE: {
					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, 0.08, 0.04, -0.292, -0.2, 0.0, 3.8, 0.81, 0.83, 0.703 ) ;
					EquippedItem [ playerid ] = LIQUOR_REDWINE ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has opened a bottle of Red Wine.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "Use /drink to drink. You can unequip the bottle by using unequip.", MSG_TYPE_INFO ) ;	
				}

				case LIQUOR_GRAINWHISKEY: {
					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, 0.08, 0.04, -0.22, -0.20, 0.0, 3.8, 0.81, 0.83, 0.70 );

					EquippedItem [ playerid ] = LIQUOR_GRAINWHISKEY ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has opened a bottle of Grain Whiskey.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "Use /drink to drink. You can unequip the bottle by using unequip.", MSG_TYPE_INFO ) ;	
				}

				case LIQUOR_MALTWHISKEY: {
					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, 0.08, 0.04, -0.292, -0.2, 0.0, 3.8, 0.81, 0.83, 0.703 ) ;
					EquippedItem [ playerid ] = LIQUOR_MALTWHISKEY ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has opened a bottle of Malt Whiskey.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "Use /drink to drink. You can unequip the bottle by using unequip.", MSG_TYPE_INFO ) ;	
				}

				case LIQUOR_VODKA: {
					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6,  0.08, 0.04, -0.292, -0.2, 0.0, 3.8, 0.81, 0.83, 0.703 ) ;
					EquippedItem [ playerid ] = LIQUOR_VODKA ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has opened a bottle of Moonshine Vodka.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "Use /smoke 1 to drink. You can unequip the bottle by using unequip.", MSG_TYPE_INFO ) ;	
				}

				case SMOKE_CIGARPACK: {
					DecreaseItem ( playerid, tileid, 1 ) ;
					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, 1485, 6, 0.015, -0.022, 0.019, -0.20, 0.0, 3.8, 0.81, 0.83, 0.70 ) ;

					EquippedItem [ playerid ] = SMOKE_CIGARPACK ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s pulled out a cigar from his pack and lit it up.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "Use /smoke 1 to smoke. Simply unequip to stop smoking.", MSG_TYPE_INFO ) ;	
				}

				case SMOKE_BLUNTPACK: {
					DecreaseItem ( playerid, tileid, 1 ) ;

					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, 3027, 6, 0.11, 0.00, 0.033, 63, 69.2, 3.8, 0.81, 0.83, 0.70 ) ;

					EquippedItem [ playerid ] = SMOKE_BLUNTPACK ;
					EquippedItemTile [ playerid ] = tileid ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s pulled out a rolled cigarette from his pack and lit it up.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "Use /smoke to smoke. Simply unequip to stop smoking.", MSG_TYPE_INFO ) ;				
				}

				case SHERIFF_LASSO: {

					EquippedItem [ playerid ] = SHERIFF_LASSO ;
					EquippedItemTile [ playerid ] = tileid ;

					SetPlayerAttachedObject(playerid, ATTACH_SLOT_EQUIP, Item [ itemid ] [ item_model ], 6, -0.018, 0.06, -0.025, 181.5, 17.5, 0.0, 1.0, 1.0, 1.0) ;

					ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s has equipped a lasso.",ReturnUserName ( playerid, false, true ) ) ) ;
					SendServerMessage ( playerid, "You've equipped a lasso. Use /lasso [targetid] to target someone then use LEFT-CLICK to try and catch them.", MSG_TYPE_INFO ) ;
					SendServerMessage(playerid, "Do not abuse the lasso for trolling. Ignoring this warning could lead you to an admin-jail or a ban.", MSG_TYPE_WARN);
				}
			}

			DisplayInventoryExamineGUI ( playerid, itemid, tileid ) ;
			UpdateWeaponGUI ( playerid ) ;

			return true ;

		}

		case ITEM_TYPE_SEED: {

			new i = FindNearestSoil(playerid, 4.0);

			if(i == INVALID_SOIL_ID){
				return SendServerMessage(playerid, "You aren't near any plants.", MSG_TYPE_ERROR);
			} else {

				if(Character[playerid][character_id] == Soil[i][soil_owner]){

					if(Soil[i][soil_state] == SOIL_STATE_DIGGED){

						DecreaseItem ( playerid, tileid, 1 );

						switch ( Item [ itemid ] [ item_extra_param ] ) {

							case SEED_ORANGE: {
								Soil[i][soil_state] = SOIL_STATE_SEEDED;
								Soil[i][soil_plant] = PLANT_ORANGE;

								SendServerMessage(playerid, "You have planted a orange seed!", MSG_TYPE_INFO);
								SetupSoil(i);
							}

							case SEED_APPLE_RED: {
								Soil[i][soil_state] = SOIL_STATE_SEEDED;
								Soil[i][soil_plant] = PLANT_APPLE_RED;

								SendServerMessage(playerid, "You have planted a red apple seed!", MSG_TYPE_INFO);
								SetupSoil(i);
							}

							case SEED_APPLE_GREEN: {
								Soil[i][soil_state] = SOIL_STATE_SEEDED;
								Soil[i][soil_plant] = PLANT_APPLE_GREEN;

								SendServerMessage(playerid, "You have planted a green apple seed!", MSG_TYPE_INFO);
								SetupSoil(i);
							}

							case SEED_TOMATO: {
								Soil[i][soil_state] = SOIL_STATE_SEEDED;
								Soil[i][soil_plant] = PLANT_TOMATO;

								SendServerMessage(playerid, "You have planted a tomato seed!", MSG_TYPE_INFO);
								SetupSoil(i);
							}

							case SEED_CABBAGE: {
								Soil[i][soil_state] = SOIL_STATE_SEEDED;
								Soil[i][soil_plant] = PLANT_CABBAGE;

								SendServerMessage(playerid, "You have planted a cabbage seed!", MSG_TYPE_INFO);
								SetupSoil(i);
							}

							case SEED_PUMPKIN: {
								Soil[i][soil_state] = SOIL_STATE_SEEDED;
								Soil[i][soil_plant] = PLANT_PUMPKIN;

								SendServerMessage(playerid, "You have planted a pumpkin seed!", MSG_TYPE_INFO);
								SetupSoil(i);
							}

							case SEED_WHEAT: {
								Soil[i][soil_state] = SOIL_STATE_SEEDED;
								Soil[i][soil_plant] = PLANT_WHEAT;

								SendServerMessage(playerid, "You have planted a wheat seed!", MSG_TYPE_INFO);
								SetupSoil(i);
							}
						}
					}
					else {
						return SendServerMessage(playerid, "You can't plant a seed on this soil right now!", MSG_TYPE_ERROR);
					}
				}
				else {
					return SendServerMessage(playerid, "You don't own this soil.", MSG_TYPE_ERROR);
				}
			}
			return true;
		}
	

		case ITEM_TYPE_JUNK: {
			// Check if player is near shopkeeper then sell it
		}

		case ITEM_TYPE_SELL: {
			
			/*if ( TutorialProgress [ playerid ] != MAX_TUTORIAL_PROGRESS) {
				if ( Item [ itemid ] [ item_extra_param ] == FISHING_BLUE_1 ||  Item [ itemid ] [ item_extra_param ] == FISHING_BLUE_2 ||
			 	Item [ itemid ] [ item_extra_param ] == FISHING_YELLOW ||  Item [ itemid ] [ item_extra_param ] == FISHING_BIGFISH ||
			  	Item [ itemid ] [ item_extra_param ] == FISHING_SHARK ) {

					DiscardItem ( playerid, tileid ) ;
					GiveCharacterMoney ( playerid, 50, MONEY_SLOT_HAND ) ;

					SendServerMessage ( playerid, sprintf("You have sold your %s for $%s.", Item [ itemid ] [ item_name ], IntegerWithDelimiter ( 50 ) ), MSG_TYPE_INFO ) ;

					TutorialProgress [ playerid ] ++ ;
					ProcessTutorialTask ( playerid ) ;

					return true ;
				}
			}*/

			if(Item[itemid][item_extra_param] == WILDLIFE_MEAT || Item[itemid][item_extra_param] == WILDLIFE_MEAT_LEG) {

				for(new i=0; i<sizeof(CookingLocations); i++) {

					if(IsPlayerInRangeOfPoint(playerid, 2.5, CookingLocations[i][0],CookingLocations[i][1],CookingLocations[i][2])) {

						inline CookMeatPrompt(pid, dialogid, response, listitem, string:inputtext[]) {

				        	#pragma unused pid, dialogid, listitem 

							if(response) {

								if(!IsNumeric(inputtext)) {

									return Dialog_ShowCallback(playerid, using inline CookMeatPrompt, DIALOG_STYLE_INPUT, "Cooking Location", sprintf("{CF4040}Amount needs to be a number.{FFFFFF}\n\nPlease enter amount you wish to cook. (Max: %d)",PlayerItem [ playerid ] [ tileid ] [ player_item_amount ]),"Cook","Exit");
								}
								if(strval(inputtext) <= 0) {

									return Dialog_ShowCallback(playerid, using inline CookMeatPrompt, DIALOG_STYLE_INPUT, "Cooking Location", sprintf("{CF4040}Amount needs to be a positive number or more than 0.{FFFFFF}\n\nPlease enter amount you wish to cook. (Max: %d)",PlayerItem [ playerid ] [ tileid ] [ player_item_amount ]),"Cook","Exit");
								}
								if(strval(inputtext) > PlayerItem[playerid][tileid][player_item_amount]) {

									return Dialog_ShowCallback(playerid, using inline CookMeatPrompt, DIALOG_STYLE_INPUT, "Cooking Location", sprintf("{CF4040}You do not have that much of this meat, refer to max amount.{FFFFFF}\n\nPlease enter amount you wish to cook. (Max: %d)",PlayerItem [ playerid ] [ tileid ] [ player_item_amount ]),"Cook","Exit");
								}

								if(Item[itemid][item_extra_param] == WILDLIFE_MEAT) {

									if(GivePlayerItemByParam(playerid, PARAM_HUNGER, FOOD_COOKED_MEAT, strval(inputtext), PARAM_HUNGER, FOOD_COOKED_MEAT, 0)) {
										
										DecreaseItem(playerid,tileid,strval(inputtext));
										return SendServerMessage(playerid,sprintf("You've cooked %d pieces of meat.",strval(inputtext)),MSG_TYPE_INFO);
									}
								}
								else {

									if(GivePlayerItemByParam(playerid, PARAM_HUNGER, FOOD_COOKED_MEAT_LEG, strval(inputtext), PARAM_HUNGER, FOOD_COOKED_MEAT_LEG, 0)) {
										
										DecreaseItem(playerid,tileid,strval(inputtext));
										return SendServerMessage(playerid,sprintf("You've cooked %d pieces of meat leg.",strval(inputtext)),MSG_TYPE_INFO);
									}
								}
							}
				        }
				        return Dialog_ShowCallback(playerid, using inline CookMeatPrompt, DIALOG_STYLE_INPUT, "Cooking Location", sprintf("{FFFFFF}Please enter amount you wish to cook. (Max: %d)",PlayerItem [ playerid ] [ tileid ] [ player_item_amount ]),"Cook","Exit");
					}
					else continue;
				}

				foreach(new i : Player) {

					if(DoesPlayerHaveCampfire[i]) {

						new Float:x,Float:y,Float:z;
						GetDynamicObjectPos(PlayerCampfireObjectHandler[i],x,y,z);
						if(IsPlayerInRangeOfPoint(playerid,2.5,x,y,z)) {

							inline CookMeatPrompt(pid, dialogid, response, listitem, string:inputtext[]) {

					        	#pragma unused pid, dialogid, listitem 

								if(response) {

									if(!IsNumeric(inputtext)) {

										return Dialog_ShowCallback(playerid, using inline CookMeatPrompt, DIALOG_STYLE_INPUT, "Cooking Location", sprintf("{CF4040}Amount needs to be a number.{FFFFFF}\n\nPlease enter amount you wish to cook. (Max: %d)",PlayerItem [ playerid ] [ tileid ] [ player_item_amount ]),"Cook","Exit");
									}
									if(strval(inputtext) <= 0) {

										return Dialog_ShowCallback(playerid, using inline CookMeatPrompt, DIALOG_STYLE_INPUT, "Cooking Location", sprintf("{CF4040}Amount needs to be a positive number or more than 0.{FFFFFF}\n\nPlease enter amount you wish to cook. (Max: %d)",PlayerItem [ playerid ] [ tileid ] [ player_item_amount ]),"Cook","Exit");
									}
									if(strval(inputtext) > PlayerItem[playerid][tileid][player_item_amount]) {

										return Dialog_ShowCallback(playerid, using inline CookMeatPrompt, DIALOG_STYLE_INPUT, "Cooking Location", sprintf("{CF4040}You do not have that much of this meat, refer to max amount.{FFFFFF}\n\nPlease enter amount you wish to cook. (Max: %d)",PlayerItem [ playerid ] [ tileid ] [ player_item_amount ]),"Cook","Exit");
									}

									if(Item[itemid][item_extra_param] == WILDLIFE_MEAT) {

										if(GivePlayerItemByParam(playerid, PARAM_HUNGER, FOOD_COOKED_MEAT, strval(inputtext), PARAM_HUNGER, FOOD_COOKED_MEAT, 0)) {
											
											DecreaseItem(playerid,tileid,strval(inputtext));
											return SendServerMessage(playerid,sprintf("You've cooked %d pieces of meat.",strval(inputtext)),MSG_TYPE_INFO);
										}
									}
									else {

										if(GivePlayerItemByParam(playerid, PARAM_HUNGER, FOOD_COOKED_MEAT_LEG, strval(inputtext), PARAM_HUNGER, FOOD_COOKED_MEAT_LEG, 0)) {
											
											DecreaseItem(playerid,tileid,strval(inputtext));
											return SendServerMessage(playerid,sprintf("You've cooked %d pieces of meat leg.",strval(inputtext)),MSG_TYPE_INFO);
										}
									}
								}
					        }
					        return Dialog_ShowCallback(playerid, using inline CookMeatPrompt, DIALOG_STYLE_INPUT, "Cooking Location", sprintf("{FFFFFF}Please enter amount you wish to cook. (Max: %d)",PlayerItem [ playerid ] [ tileid ] [ player_item_amount ]),"Cook","Exit");
						}
						else { continue; }
					}
					else { continue; }
				}

				goto skipCookMeat;
			}

			skipCookMeat:

			if ( ! OnPlayerSell ( playerid, itemid, tileid ) ) {

				return SendServerMessage ( playerid, "You can't sell these items at the location you're at.", MSG_TYPE_ERROR ) ;
			}

			return false ;
		}
	}

	DecreaseItem ( playerid, tileid, 1 ) ;

	return true ;
}

DecreaseItem ( playerid, tileid, amount = 1 ) {
	new string [ 256 ] ;

	PlayerItem [ playerid ] [ tileid ] [ player_item_amount ] -= amount ;

	if ( IsPlayerViewingInventory [ playerid ] == true ) {

		valstr ( string, PlayerItem [ playerid ] [ PlayerExaminingItemTile [ playerid ] ] [ player_item_amount ] ) ;

		PlayerTextDrawHide(playerid, inventory_examine_ptds [ 2 ] ) ;
		PlayerTextDrawSetString ( playerid, inventory_examine_ptds [ 2 ], string ) ; 
		PlayerTextDrawShow(playerid, inventory_examine_ptds [ 2 ] ) ;

		string [ 0 ] = EOS ;
	}

	mysql_format ( mysql, string, sizeof ( string ), "UPDATE items_player SET player_item_amount = '%d' WHERE player_table_id = %d AND player_database_id = '%d'", 
		PlayerItem [ playerid ] [ tileid ] [ player_item_amount ], PlayerItem [ playerid ] [ tileid ] [ player_table_id ], Character [ playerid ] [ character_id ] ) ; 
	mysql_tquery ( mysql, string ) ;

	HasPlayerInventoryUpdated[playerid] = true;

	if ( PlayerItem [ playerid ] [ tileid ] [ player_item_amount ] <= 0 ) {

		DiscardItem ( playerid, tileid ) ;

		return SendServerMessage ( playerid, "You've used the last quantity you had of this item.", MSG_TYPE_ERROR ) ;
	}

	return true ;
}

DecreaseItemByExtraParam ( playerid, param, amount ) {

	new string [ 256 ], totalamount = amount ;

	for ( new i; i < ReturnPlayerItemCount [ playerid ] ; i ++ ) {

		if ( totalamount <= 0 ) { break ; }

		if ( PlayerItem [ playerid ] [ i ] [ player_item_param2 ] == param ) {

			if ( totalamount >= PlayerItem [ playerid ] [ i ] [ player_item_amount ] ) { 

				totalamount -= PlayerItem [ playerid ] [ i ] [ player_item_amount ] ; 
				PlayerItem [ playerid ] [ i ] [ player_item_amount ] = 0 ; 
			}
			
			else if ( totalamount < PlayerItem [ playerid ] [ i ] [ player_item_amount ] ) { 

				PlayerItem [ playerid ] [ i ] [ player_item_amount ] -= totalamount ; 
				totalamount = 0 ; 
			}

			if ( IsPlayerViewingInventory [ playerid ] == true ) {
			
				valstr ( string, PlayerItem [ playerid ] [ PlayerExaminingItemTile [ playerid ] ] [ player_item_amount ] ) ;

				PlayerTextDrawHide(playerid, inventory_examine_ptds [ 2 ] ) ;
				PlayerTextDrawSetString ( playerid, inventory_examine_ptds [ 2 ], string ) ; 
				PlayerTextDrawShow(playerid, inventory_examine_ptds [ 2 ] ) ;

				string [ 0 ] = EOS ;
			}

			mysql_format ( mysql, string, sizeof ( string ), "UPDATE items_player SET player_item_amount = '%d' WHERE player_table_id = %d AND player_database_id = '%d'", 
				PlayerItem [ playerid ] [ i ] [ player_item_amount ], PlayerItem [ playerid ] [ i ] [ player_table_id ], Character [ playerid ] [ character_id ] ) ; 
			mysql_tquery ( mysql, string ) ;

			if ( PlayerItem [ playerid ] [ i ] [ player_item_amount ] <= 0 ) {

				DiscardItem ( playerid, i ) ;

				SendServerMessage ( playerid, "You've used the last quantity you had of this item.", MSG_TYPE_ERROR ) ;
			}
		}

		else continue ;
	}

	return true ;
}

ConsumeFood(playerid, itemid) {

	new query[128];
	switch(Item[itemid][item_extra_param]) {

		case FOOD_WATER_FULL: {

			Character[playerid][character_thirst] += 20;
			if(Character[playerid][character_thirst] > 100) { Character[playerid][character_thirst] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d WHERE character_id = %d",Character[playerid][character_thirst],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "SMOKING", "M_smk_drag", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s drinks a bottle of water.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_MILK_FULL: {

			Character[playerid][character_thirst] += 15;
			Character[playerid][character_hunger] += 5;
			if(Character[playerid][character_thirst] > 100) { Character[playerid][character_thirst] = 100; }
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d,character_hunger = %d WHERE character_id = %d",Character[playerid][character_thirst],Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "SMOKING", "M_smk_drag", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s drinks some milk.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_ORANGE: {

			Character[playerid][character_thirst] += 5;
			Character[playerid][character_hunger] += 5;
			if(Character[playerid][character_thirst] > 100) { Character[playerid][character_thirst] = 100; }
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d,character_hunger = %d WHERE character_id = %d",Character[playerid][character_thirst],Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats a orange.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_APPLE_GREEN,FOOD_APPLE_RED: {

			Character[playerid][character_thirst] += 5;
			Character[playerid][character_hunger] += 5;
			if(Character[playerid][character_thirst] > 100) { Character[playerid][character_thirst] = 100; }
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d,character_hunger = %d WHERE character_id = %d",Character[playerid][character_thirst],Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			if(Item[itemid][item_extra_param] == FOOD_APPLE_GREEN) { ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats a green apple.",ReturnUserName(playerid,false,true))); }
			else { ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats a red apple.",ReturnUserName(playerid,false,true))); }
		}
		case FOOD_TOMATO: {

			Character[playerid][character_hunger] += 5;
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_hunger = %d WHERE character_id = %d",Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats a tomato.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_CABBAGE: {

			Character[playerid][character_hunger] += 7;
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_hunger = %d WHERE character_id = %d",Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some cabbage.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_BANANA: {

			Character[playerid][character_hunger] += 5;
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_hunger = %d WHERE character_id = %d",Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats a banana.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_BREAD: {

			Character[playerid][character_thirst] -= 5;
			Character[playerid][character_hunger] += 20;
			if(Character[playerid][character_thirst] < 0) { Character[playerid][character_thirst] = 0; }
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d,character_hunger = %d WHERE character_id = %d",Character[playerid][character_thirst],Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some bread.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_PUMPKIN: {

			Character[playerid][character_thirst] += 5;
			Character[playerid][character_hunger] += 20;
			if(Character[playerid][character_thirst] > 100) { Character[playerid][character_thirst] = 100; }
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d,character_hunger = %d WHERE character_id = %d",Character[playerid][character_thirst],Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats a piece of pumpkin.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_COOKED_MEAT,FOOD_COOKED_MEAT_LEG: {

			Character[playerid][character_hunger] += 25;
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_hunger = %d WHERE character_id = %d",Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			if(Item[itemid][item_extra_param] == FOOD_APPLE_GREEN) { ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some cooked meat.",ReturnUserName(playerid,false,true))); }
			else { ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some cooked meat leg.",ReturnUserName(playerid,false,true))); }
		}
		case FOOD_CANNED_SALMON: {

			Character[playerid][character_thirst] += 5;
			Character[playerid][character_hunger] += 15;
			if(Character[playerid][character_thirst] > 100) { Character[playerid][character_thirst] = 100; }
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d,character_hunger = %d WHERE character_id = %d",Character[playerid][character_thirst],Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some canned salmon.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_CANNED_CORNED_BEEF: {

			Character[playerid][character_hunger] += 15;
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_hunger = %d WHERE character_id = %d",Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some canned corned beef.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_CANNED_PINEAPPLES: {

			Character[playerid][character_thirst] += 5;
			Character[playerid][character_hunger] += 10;
			if(Character[playerid][character_thirst] > 100) { Character[playerid][character_thirst] = 100; }
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d,character_hunger = %d WHERE character_id = %d",Character[playerid][character_thirst],Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some canned pineapples.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_CANNED_STRAWBERRIES: {

			Character[playerid][character_thirst] += 5;
			Character[playerid][character_hunger] += 10;
			if(Character[playerid][character_thirst] > 100) { Character[playerid][character_thirst] = 100; }
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d,character_hunger = %d WHERE character_id = %d",Character[playerid][character_thirst],Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some canned strawberries.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_CANNED_KIDNEY_BEANS: {

			Character[playerid][character_hunger] += 15;
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_hunger = %d WHERE character_id = %d",Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some canned kidney beans.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_CANNED_PEACHES: {

			Character[playerid][character_thirst] += 5;
			Character[playerid][character_hunger] += 15;
			if(Character[playerid][character_thirst] > 100) { Character[playerid][character_thirst] = 100; }
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d,character_hunger = %d WHERE character_id = %d",Character[playerid][character_thirst],Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some canned peaches.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_CANNED_SWEETCORN: {

			Character[playerid][character_thirst] += 5;
			Character[playerid][character_hunger] += 10;
			if(Character[playerid][character_thirst] > 100) { Character[playerid][character_thirst] = 100; }
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d,character_hunger = %d WHERE character_id = %d",Character[playerid][character_thirst],Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some canned sweetcorn.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_CANNED_BAKED_BEANS: {

			Character[playerid][character_hunger] += 15;
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_hunger = %d WHERE character_id = %d",Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some baked beans.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_CANNED_APRICOTS: {

			Character[playerid][character_thirst] += 5;
			Character[playerid][character_hunger] += 10;
			if(Character[playerid][character_thirst] > 100) { Character[playerid][character_thirst] = 100; }
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d,character_hunger = %d WHERE character_id = %d",Character[playerid][character_thirst],Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some canned apricots.",ReturnUserName(playerid,false,true)));
		}
		case FOOD_CANNED_PEAS: {

			Character[playerid][character_thirst] += 5;
			Character[playerid][character_hunger] += 10;
			if(Character[playerid][character_thirst] > 100) { Character[playerid][character_thirst] = 100; }
			if(Character[playerid][character_hunger] > 100) { Character[playerid][character_hunger] = 100; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_thirst = %d,character_hunger = %d WHERE character_id = %d",Character[playerid][character_thirst],Character[playerid][character_hunger],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
			ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
			ProxDetector(playerid,20.0,COLOR_ACTION,sprintf("* %s eats some canned peas.",ReturnUserName(playerid,false,true)));
		}
		default: {

			return SendServerMessage(playerid,sprintf("Something went wrong, please send this to a developer. [Error: ID %d array]",itemid),MSG_TYPE_ERROR);
		}
	}
	UpdateGUI(playerid);
	return true;
}