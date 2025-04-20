#define LVL1COOLDOWN (300)
#define LVL2COOLDOWN (210)
#define LVL3COOLDOWN (150)

#include "func/jobs/fishing/core.pwn"
#include "func/jobs/mining/core.pwn"
#include "func/jobs/lumber/core.pwn"

enum DamWaterData {

	Float: dwf_minx,
	Float: dwf_miny,
	Float: dwf_maxx,
	Float: dwf_maxy
} ;

IsCoordBehindDam ( Float: x, Float: y ) {

	new DamWater [ ] [ DamWaterData ] = {
	// 	minx      miny      maxx    maxy
		{  -1242.33, 2689.00, -9900.33, 2832.0 },
		{  -1182.33, 2545.00, -7960.33, 2689.0 },
		{  -1102.33, 2208.00, -8150.33, 2545.0 },
		{  -1398.33, 2070.00, -1206.33, 2170.0 },
		{  -1206.33, 2109.00, -9540.33, 2209.0 },
		{  -9540.33, 2012.00, -8140.33, 2209.0 },
		{  -8150.33, 2010.00, -4560.33, 2252.0 },
		{  -7300.33, 2252.00, -4700.33, 2352.0 }
	} ;

	for ( new i, p = sizeof ( DamWater ); i < p; i ++ ) {

		if ( x >= DamWater [ i ] [ dwf_minx ] && x <= DamWater [ i ] [ dwf_miny ] && y >= DamWater [ i ] [ dwf_maxx ] && y <= DamWater [ i ] [ dwf_maxy ]) {

			return true;
		}

		else continue ;

	}

	return false ;
}

CMD:fixjob ( playerid ) {

	IsMining [ playerid ] = false ;
	IsFishing [ playerid ] = false ;
	IsPlayerFishing [ playerid ] = false ;
	IsCuttingTree[playerid]  = false ;

	FishingProgress [ playerid ] = 0 ;
	CuttingProgress [ playerid ] = 0;
	MiningProgress [ playerid ] = 0 ;
	Widllife_Harvest_Value [ playerid ] = false ;

	if ( IsValidDynamicArea ( player_TreeCircle [ playerid ] ) ) {

		DestroyDynamicArea( player_TreeCircle [ playerid ] ) ;
	}

	if ( IsValidDynamicArea ( player_FishCircle [ playerid ] ) ) {

		DestroyDynamicArea( player_FishCircle [ playerid ] ) ;
	}

	if ( IsValidDynamicArea ( player_MineCircle [ playerid ] ) ) {

		DestroyDynamicArea( player_MineCircle [ playerid ] ) ;
	}

	HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;
	HideActionGUI ( playerid ) ;

	if ( IsValidDynamicObject ( player_RopeLine [ playerid ] ) ) {

		DestroyDynamicObject( player_RopeLine [ playerid ] ) ;
	}

	ClearAnimations(playerid ) ;
	TogglePlayerControllable(playerid, true ) ;

//	SendServerMessage ( playerid, "Job vars reset.", MSG_TYPE_ERROR ) ;


	return true ;
}

IsPlayerDoingJob ( playerid ) {

	if ( IsMining[playerid] || IsFishing [ playerid ] || IsCuttingTree [ playerid ] ) {

		return true ;
	}

	return false ;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

	if ( EquippedItem [ playerid ] != -1 && newkeys & KEY_FIRE ) {

		if ( IsMining [ playerid ] || IsFishing [ playerid ] || IsCuttingTree [ playerid ] ) {
/*
			IsMining [ playerid ] = false ;
			IsFishing [ playerid ] = false ;
			IsPlayerFishing [ playerid ] = false ;
			IsCuttingTree[playerid]  = false ;

			FishingProgress [ playerid ] = 0 ;
	  		CuttingProgress [ playerid ] = 0;
			MiningProgress [ playerid ] = 0 ;

			if ( IsValidDynamicArea ( player_TreeCircle [ playerid ] ) ) {

				DestroyDynamicArea( player_TreeCircle [ playerid ] ) ;
			}

			if ( IsValidDynamicArea ( player_FishCircle [ playerid ] ) ) {

				DestroyDynamicArea( player_FishCircle [ playerid ] ) ;
			}

			if ( IsValidDynamicArea ( player_MineCircle [ playerid ] ) ) {

				DestroyDynamicArea( player_MineCircle [ playerid ] ) ;
			}

			HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;
			HideActionGUI ( playerid ) ;

			if ( IsValidDynamicObject ( player_RopeLine [ playerid ] ) ) {

				DestroyDynamicObject( player_RopeLine [ playerid ] ) ;
			}

   			ClearAnimations(playerid ) ;
   			TogglePlayerControllable(playerid, true ) ;
*/
			return cmd_fixjob ( playerid ) ;
		}
	}

//	if ( EquippedItem [ playerid ] != -1 && newkeys & KEY_WALK && TutorialProgress [ playerid ] > 6 ) {
	if ( EquippedItem [ playerid ] != -1 && newkeys & KEY_WALK ) {

		switch ( EquippedItem [ playerid ] ) {

			case FISHING_ROD : {

				if ( ! IsPlayerFishing [ playerid ] ) {

					if ( ReturnPlayerItemCount [ playerid ] >= GetPlayerBackpackSize ( playerid ) ) {

						return SendServerMessage ( playerid, "You don't have enough backpack size to fish more. Go sell your fish or get a bigger backpack.", MSG_TYPE_ERROR ) ;
					}

					if ( IsPlayerDoingJob ( playerid ) ) {

						return false ;
					}

					if(CA_IsPlayerNearWater(playerid)) {

						if ( Character [ playerid ] [ character_fishcd ] ) {

							cmd_fixjob ( playerid ) ;
							return SendServerMessage ( playerid, "You cannot fish right now - you are on a cooldown.", MSG_TYPE_ERROR ) ;
						}

						new Float: x, Float: y, Float: z, Float:xy_x, Float: xy_y, Float: xy_z, distance = 1 + random ( 12 ) ;
					
						GetPlayerPos ( playerid, x, y, z ) ;

						GetXYInFrontOfPlayer ( playerid, xy_x, xy_y, distance ) ;
						CA_FindZ_For2DCoord(xy_x, xy_y, xy_z ) ;

						SendServerMessage ( playerid,"You've thrown your bobber into the water.", MSG_TYPE_INFO ) ;

						player_DobberPoint [ playerid ] = distance ;
						ApplyAnimation(playerid,"SWORD","sword_block",50.0,0,1,0,1,1);

						HideActionGUI ( playerid ) ;

						TogglePlayerControllable ( playerid, false ) ;

						if ( IsValidDynamicObject ( player_RopeLine [ playerid ] )) {

							DestroyDynamicObject(player_RopeLine [ playerid ] ) ;
						}

						player_RopeLine [ playerid ] = CreateDynamicObject(19089, x, y, z, 0, 60, 90);
						player_FishCircle [ playerid ] = CreateDynamicCircle(x, y, 2.0, 0, 0, playerid ) ;

						OnPlayerFish ( playerid ) ;
						IsPlayerFishing [ playerid ] = true ;

					 	//OldLog ( playerid, "job/fishing", sprintf ( "%s has triggered fishing. Timer has to tick.", ReturnUserName ( playerid, false ) )) ;
					 	return true ;
					}

					else return false ;
				}
			}

			case MINE_PICKAXE : {

				if ( ReturnPlayerItemCount [ playerid ] >= GetPlayerBackpackSize ( playerid ) ) {

					return SendServerMessage ( playerid, "You don't have enough backpack size to mine more. Go sell your rocks or get a bigger backpack.", MSG_TYPE_ERROR ) ;
				}

		 		if( IsPlayerDoingJob ( playerid ) ) {
			    	return false ;
			    }

			    if ( Character [ playerid ] [ character_minecd ] ) {

			    	cmd_fixjob ( playerid ) ;
					return SendServerMessage ( playerid, "You cannot mine right now - you are on a cooldown.", MSG_TYPE_ERROR ) ;
				}

			    new id = IsPlayerInRangeOfRock( playerid, 1.5 );

			    if( id == -1 ) {
			    	return false ;
			    }

			    if ( Rock[id ][mineHealth ] < 1 ) {

			    	return SendServerMessage ( playerid, "This rock has no ore left! Come back later.", MSG_TYPE_ERROR ) ;
			    }

			    switch ( GetRockItemID ( id ) ) {

			    	case MINE_IRON_ORE, MINE_COPPER_ORE: {

			    		if ( PlayerSkill [ playerid ] [ JOB_mining ] < 2 ) {
			    			
			    			return SendServerMessage ( playerid, "You need to have your Mining skill at level 2 to mine this ore.", MSG_TYPE_ERROR ) ;
			    		}
			    	}

			    	case MINE_GOLD_ORE: {

			    		if ( PlayerSkill [ playerid ] [ JOB_mining ] < 3 ) {

			    			return SendServerMessage ( playerid, "You need to have your Mining skill at level 3 to mine this ore.", MSG_TYPE_ERROR ) ;
			    		}
			    	}
			    }

			    TogglePlayerControllable( playerid, 0 );
		        ApplyAnimation( playerid, "CHAINSAW", "WEAPON_csawlo", 4.1, 1, 1, 1, 1, 0, 1 );

		       	IsMining[playerid] = true;
		 		MiningRock( playerid, id );

		 		new Float: x, Float: y, Float: z ;
		 		GetPlayerPos ( playerid, x, y, z ) ;

				player_MineCircle [ playerid ] = CreateDynamicCircle(x, y, 2.0, 0, 0, playerid ) ;
				SetupActionGUI ( playerid, ACTION_TYPE_MINING ) ;	

			 	//OldLog ( playerid, "job/mining", sprintf ( "%s has triggered mining. Timer has to tick.", ReturnUserName ( playerid, false ) )) ;

			 	return true ;
			}

			case LUMBER_HATCHET : {

				//PlayerSkill [ playerid ] [ JOB_lumber ] 

				if ( ReturnPlayerItemCount [ playerid ] >= GetPlayerBackpackSize ( playerid ) ) {

					return SendServerMessage ( playerid, "You don't have enough backpack size to cut more wood. Go sell your logs or get a bigger backpack.", MSG_TYPE_ERROR ) ;
				}

		    	if ( IsPlayerDoingJob ( playerid ) ) {

			    	return false ;
			    }

			    if ( Character [ playerid ] [ character_woodcd ] ) {

					cmd_fixjob ( playerid ) ;
					return SendServerMessage ( playerid, "You cannot cut trees right now - you are on a cooldown.", MSG_TYPE_ERROR ) ;
				}

			    new id = IsPlayerInRangeOfTree(playerid, 2.5);

			    if(id == -1) {
			    	return false ;
			    }

			    if(Tree[id][treeHealth] <= 0) {
			    	return SendServerMessage ( playerid, "The tree you're trying to cut has already been chopped down.", MSG_TYPE_ERROR ) ;
			    }

			    switch ( Tree [ id ] [ treeType ] ) {

			    	case 1: {

			    		if ( PlayerSkill [ playerid ] [ JOB_lumber ] < 2 ) {

			    			return SendServerMessage ( playerid, "You need to have your Woodcutting skill at level 2 to cut down this tree.", MSG_TYPE_ERROR ) ;
			    		}
			    	}

			    	case 2: {

			    		if ( PlayerSkill [ playerid ] [ JOB_lumber ] < 3 ) {

			    			return SendServerMessage ( playerid, "You need to have your Woodcutting skill at level 3 to cut down this tree.", MSG_TYPE_ERROR ) ;
			    		}
			    	}
			    }

			    TogglePlayerControllable(playerid, 0);
		        ApplyAnimation(playerid, "RIOT", "RIOT_ANGRY_B", 4.1, 1, 1, 1, 1, 0, 1);

		        IsCuttingTree[playerid] = true;
		 		CuttingTree(playerid, id);

		 		new Float: x, Float: y, Float: z ;
		 		GetPlayerPos ( playerid, x, y, z ) ;

				player_TreeCircle [ playerid ] = CreateDynamicCircle(x, y, 2.0, 0, 0, playerid ) ;
				SetupActionGUI ( playerid, ACTION_TYPE_LUMBER ) ;	

			 	//OldLog ( playerid, "job/tree", sprintf ( "%s has triggered woodcutting. Timer has to tick.", ReturnUserName ( playerid, false ) )) ;

			 	return true ;
			}

			case HUNTING_KNIFE: {

				if ( GetPlayerAnimationIndex ( playerid ) == 163 ) {

					return true ;
				}

				new pos_check ;

				for(new wildlife = 0; wildlife < MAX_WILDLIFE; wildlife++) {

					if( IsPlayerInDynamicArea(playerid, Wildlife [ wildlife ] [ wildlife_area ] )) {

						if ( Wildlife [ wildlife ] [ wildlife_state ] == WILDLIFE_STATE_INACTIVE ) {

							return SendServerMessage ( playerid, "You can't harvest this animal. It might have already been harvested.", MSG_TYPE_ERROR ) ;
						}

						else if ( Wildlife [ wildlife ] [ wildlife_state ] == WILDLIFE_STATE_DEAD ) {

							pos_check = 1 ;

							Wildlife_Harvest(playerid, wildlife);

							SetupActionGUI ( playerid, ACTION_TYPE_DEER ) ;

							/*
							PlayerTextDrawSetString(playerid, actionGUI_infoText , "Press ~k~~SNEAK_ABOUT~ to start skinning this deer.") ;		

							if ( Wildlife [ wildlife ] [ wildlife_model ] == WILDLIFE_OBJ_DEER ) {
								
								PlayerTextDrawSetPreviewModel ( playerid, actionGUI_PreviewBoxModel , WILDLIFE_OBJ_DEER ) ;
							}

							else if ( Wildlife [ wildlife ] [ wildlife_model ] == WILDLIFE_OBJ_COW ) {

								PlayerTextDrawSetPreviewModel ( playerid, actionGUI_PreviewBoxModel , WILDLIFE_OBJ_COW ) ;
							}*/

							new model, string[64] ;

							if ( Wildlife [ wildlife ] [ wildlife_model ] == WILDLIFE_OBJ_DEER ) {
								
								model =  WILDLIFE_OBJ_DEER ;
							}

							else if ( Wildlife [ wildlife ] [ wildlife_model ] == WILDLIFE_OBJ_COW ) {

								model = WILDLIFE_OBJ_COW ;
							}

							format(string,sizeof(string),"Press ~k~~SNEAK_ABOUT~ to start skinning this %s.",(model == WILDLIFE_OBJ_DEER) ? ("deer") : ("cow"));

							ActionPanel_ChangeGUI ( playerid, string, model );


							break ;
						}
					}

					else continue ;
				}

				if ( ! pos_check ) {
					return SendServerMessage ( playerid, "You don't seem to be near a dead animal.", MSG_TYPE_ERROR ) ;
				}
			}
		}
	}

	if ( EquippedItem [ playerid ] != -1 && newkeys & KEY_HANDBRAKE  ) {

		if ( IsFishing [ playerid ] ) {

			FishingProgress [ playerid ] += 15 + random ( 20 ) ;

			if ( FishingProgress [ playerid ] >= 100 ) {

				IsFishing [ playerid ] = false ;
				new caught_fish = CalculateCatch ( playerid ), modelid = Fish [ caught_fish ] [ fish_model ] ; 

				OnPlayerCatchFish ( playerid, caught_fish, floatround ( ReturnFishWeight ( caught_fish ) ) ) ;

				new exp = 1 + random ( 2 ) ;
				GivePlayerExperience ( playerid, exp ) ;

				ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("** %s has caught a %s, which weighs %0.2f.", ReturnUserName ( playerid, false ), Fish [ caught_fish ] [ fish_name ], ReturnFishWeight ( caught_fish ) )) ;

/*
				PlayerTextDrawSetString(playerid, actionGUI_infoText, 
					sprintf("| Managed to catch a %s~n~| Weight: %0.2f~n~~n~~w~ + %d exp for Hunting Level!", Fish [ caught_fish ] [ fish_name ], ReturnFishWeight ( caught_fish ), exp  )) ;		

				PlayerTextDrawSetPreviewModel ( playerid, actionGUI_PreviewBoxModel, modelid ) ;

				PlayerTextDrawHide ( playerid, actionGUI_PreviewBoxModel ) ;
				PlayerTextDrawShow ( playerid, actionGUI_PreviewBoxModel ) ;

				HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;
*/
				ActionPanel_ChangeGUI ( playerid, sprintf("| Managed to catch a %s~n~| Weight: %0.2f~n~~n~~w~ + %d exp for Hunting Level!", Fish [ caught_fish ] [ fish_name ], ReturnFishWeight ( caught_fish ), exp  ), modelid, false ) ;



				if ( IsValidDynamicObject(player_RopeLine [ playerid ])) {
					DestroyDynamicObject(player_RopeLine [ playerid ] ) ;
				}
				

				FishingProgress [ playerid ] = 0 ;
				IsPlayerFishing [ playerid ] = false ;

			 	//OldLog ( playerid, "job/fishing", sprintf ( "%s has reeled in a %s, weight: %0.2f.", ReturnUserName ( playerid, false ), Fish [ caught_fish ] [ fish_name ], ReturnFishWeight ( caught_fish ) )) ;
			}

			defer HandleFishingBar(playerid);
			SetPlayerProgressBarValue(playerid, actionGUI_bar, FishingProgress [ playerid ] ) ;

			return true ;
		}

		else if ( IsMining [ playerid ] ) {

	        new id = IsPlayerInRangeOfRock( playerid, 1.5 ), prog;

	        if ( id == -1 ) {

	        	return true ;
	        }

	        switch( Rock[id][mineType] ) {

	            case 0: {

	            	if ( PlayerSkill [ playerid ] [ JOB_mining ] < 2 ) { prog = randomEx( 5, 15 ); } //normal 
	            	else { prog = randomEx ( 10, 25 ) ; }
	            }
	            case 1: {

	            	if ( PlayerSkill [ playerid ] [ JOB_mining ] < 3 ) { prog = randomEx( 3, 10 ); } //iron 
	            	else { prog = randomEx ( 6, 18 ); }
	            }
	            case 2: {

	            	if ( PlayerSkill [ playerid ] [ JOB_mining ] < 3 ) { prog = randomEx( 5, 10 ); } //copper
	            	else { prog = randomEx ( 10, 20 ) ; }
	            }
	            case 4: {

	            	if ( PlayerSkill [ playerid ] [ JOB_mining ] < 2 ) { prog = randomEx( 8, 20 ); } //tin
	            	else { prog = randomEx ( 15, 25 ) ; }
	           	}
	            case 3: {

	      			if ( PlayerSkill [ playerid ] [ JOB_mining ] < 2 ) { prog = randomEx( 5, 10 ); } //coal
	      			else { prog = randomEx ( 10, 20 ) ; }
	        	}
	            case 5: { prog = randomEx( 5, 10 ); } //gold
	        }

			MiningProgress[playerid] += prog;

			SetPlayerProgressBarValue( playerid, actionGUI_bar, MiningProgress[playerid] );

			if( MiningProgress[playerid] >= 100 ) { 

				MineRock( playerid, id ); 
			}

			return true ;
		}

		else if (  IsCuttingTree[playerid] ) {

	      	new id = IsPlayerInRangeOfTree(playerid, 2.5), prog;

	      	if ( id == -1 ) {

	      		return true ;
	      	}

	        switch ( Tree [ id ] [ treeType ] ) {

	            case 0: {

	            	if ( PlayerSkill [ playerid ] [ JOB_lumber ] < 2 ) { prog = randomEx ( 5, 25 ) ; } //birch
	            	else { prog = randomEx ( 15, 30 ) ; }
	        	}
	            case 1: {

	            	if ( PlayerSkill [ playerid ] [ JOB_lumber ] < 3 ) { prog = randomEx ( 5, 20 ) ; } //oak
	            	else { prog = randomEx ( 10, 20 ) ; }
	        	}
	            case 2: { prog = randomEx ( 5, 15 ) ; } //yew
	        }

			CuttingProgress[playerid] += prog;

			SetPlayerProgressBarValue( playerid, actionGUI_bar, CuttingProgress[playerid] );

			if(CuttingProgress[playerid] >= 100) { 

				CutTree(playerid, id);
			}

			return true ;
		}
	}
	
	#if defined job_OnPlayerKeyStateChange
		return job_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif

#define OnPlayerKeyStateChange job_OnPlayerKeyStateChange
#if defined job_OnPlayerKeyStateChange
	forward job_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

public OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid) {

	if ( areaid == player_TreeCircle [ playerid ] ) {

		IsMining[playerid]  = false ;
  		MiningProgress[playerid] = 0;

  		if ( IsValidDynamicArea ( player_TreeCircle [ playerid ] ) ) {
			DestroyDynamicArea( player_TreeCircle [ playerid ] ) ;
		}

		HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;
		HideActionGUI ( playerid ) ;
   		ClearAnimations(playerid ) ;

	 	//OldLog ( playerid, "job/tree", sprintf ( "%s has cancelled woodchop action by leaving circle", ReturnUserName ( playerid, false ) )) ;

		return true ;
	}

	else if ( areaid == player_MineCircle [ playerid ] ) {

		IsMining[playerid]  = false ;
  		MiningProgress[playerid] = 0;


  		if ( IsValidDynamicArea ( player_TreeCircle [ playerid ] ) ) {
			DestroyDynamicArea( player_MineCircle [ playerid ] ) ;
		}

		HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;
		HideActionGUI ( playerid ) ;
   		ClearAnimations(playerid ) ;

	 	//OldLog ( playerid, "job/mining", sprintf ( "%s has cancelled mining action by leaving circle", ReturnUserName ( playerid, false ) )) ;
	}

	else if ( areaid == player_FishCircle [ playerid ] ) {

		IsFishing [ playerid ] = false ;
		IsPlayerFishing [ playerid ] = false ;


  		if ( IsValidDynamicObject(player_RopeLine [ playerid ] ) ) {
			DestroyDynamicObject(player_RopeLine [ playerid ] ) ;
		}

		if ( IsValidDynamicArea ( player_FishCircle [ playerid ] ) ) { 
			DestroyDynamicArea( player_FishCircle [ playerid ] ) ; 
		} //error line (added the fix with isvaliddyanmicareaw)

		HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;
		HideActionGUI ( playerid ) ;

	 	//OldLog ( playerid, "job/fishing", sprintf ( "%s has cancelled fishing action by leaving circle", ReturnUserName ( playerid, false ) )) ;

		return true ;
	}
	
	#if defined job_OnPlayerLeaveDynamicArea
		return job_OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLeaveDynamicArea
	#undef OnPlayerLeaveDynamicArea
#else
	#define _ALS_OnPlayerLeaveDynamicArea
#endif

#define OnPlayerLeaveDynamicArea job_OnPlayerLeaveDynamicArea
#if defined job_OnPlayerLeaveDynamicArea
	forward job_OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid);
#endif

ptask PlayerJobCooldownTimer[30000](playerid) {

////	print("PlayerJobCooldownTimer timer called (jobs/core.pwn)");

	new query [ 128 ] ;
	if ( Character [ playerid ] [ character_jobactionsleft] >= 10 ) { 

		Character [ playerid ] [ character_jobactionsleft ] = 0; 

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_jobactionsleft = %d WHERE character_id = %d", Character [ playerid ] [ character_jobactionsleft ], Character [ playerid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;
	}

	if ( Character [ playerid ] [ character_woodcd ] ) {

		if ( Character [ playerid ] [ character_woodcd ] < gettime() ) { 

			Character [ playerid ] [ character_woodcd ] = 0;

			SendServerMessage ( playerid, "You can now cut trees again.", MSG_TYPE_INFO ) ;

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_woodcd = %d WHERE character_id = %d", Character [ playerid ] [ character_woodcd ], Character [ playerid ] [ character_id ] ) ;
			mysql_tquery ( mysql, query ) ;
		}
	}

	if ( Character [ playerid ] [ character_fishcd ] ) {

		if ( Character [ playerid ] [ character_fishcd ] < gettime() ) { 

			Character [ playerid ] [ character_fishcd ] = 0;

			SendServerMessage ( playerid, "You can now fish again.", MSG_TYPE_INFO ) ;

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_fishcd = %d WHERE character_id = %d", Character [ playerid ] [ character_fishcd ], Character [ playerid ] [ character_id ] ) ;
			mysql_tquery ( mysql, query ) ;
		}
	}

	if ( Character [ playerid ] [ character_minecd ] ) {

		if ( Character [ playerid ] [ character_minecd ] < gettime() ) { 

			Character [ playerid ] [ character_minecd ] = 0;

			SendServerMessage ( playerid, "You can now mine again.", MSG_TYPE_INFO ) ;

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_minecd = %d WHERE character_id = %d", Character [ playerid ] [ character_minecd ], Character [ playerid ] [ character_id ] ) ;
			mysql_tquery ( mysql, query ) ;
		}
	}

	return true ;
}

CMD:checkjobcooldown ( playerid, params [] ) {

	new query[128],timeremain[3], count;

	timeremain[0] = Character [ playerid ] [ character_fishcd ] ;
	timeremain[1] = Character [ playerid ] [ character_woodcd ] ;
	timeremain[2] = Character [ playerid ] [ character_minecd ] ;

	count = 0;

	SendServerMessage ( playerid, "..:: Job Cooldowns ::..", MSG_TYPE_WARN ) ;

	if ( timeremain[0] ) {

		if(timeremain[0] <= gettime()) {

			Character [ playerid ] [ character_fishcd ] = 0;
			SendServerMessage ( playerid, "You can now fish again.", MSG_TYPE_INFO ) ;
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_fishcd = %d WHERE character_id = %d",Character[playerid][character_fishcd],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
		}

		else if ( timeremain[0] > gettime() ) {

			SendClientMessage ( playerid, COLOR_DEFAULT, sprintf("Fishing Cooldown Time Remaining: {FFFFFF} %.02f minutes", float ( ( timeremain[0] - gettime() ) / 60 ) ) ) ;
			count++;
		}	
	}

	if ( timeremain[1] ) {

		if(timeremain[1] <= gettime()) {

			Character [ playerid ] [ character_woodcd ] = 0;
			SendServerMessage ( playerid, "You can now cut trees again.", MSG_TYPE_INFO ) ;
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_woodcd = %d WHERE character_id = %d",Character[playerid][character_woodcd],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
		}

		else if ( timeremain[1] > gettime() ) {

			SendClientMessage ( playerid, COLOR_DEFAULT, sprintf("Wood Cutting Cooldown Time Remaining: {FFFFFF} %.02f minutes", float ( ( timeremain[1] - gettime() ) / 60 ) ) ) ;
			count++;
		}
	}

	if ( timeremain[2] ) {

		if(timeremain[1] <= gettime()) {

			Character [ playerid ] [ character_minecd ] = 0;
			SendServerMessage ( playerid, "You can now mine again.", MSG_TYPE_INFO ) ;
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_minecd = %d WHERE character_id = %d",Character[playerid][character_minecd],Character[playerid][character_id]);
			mysql_tquery(mysql,query);
		}
		else if ( timeremain[2] > gettime() ) {

			SendClientMessage ( playerid, COLOR_DEFAULT, sprintf("Mining Chopping Cooldown Time Remaining: {FFFFFF} %.02f minutes", float ( ( timeremain[2] - gettime() ) / 60 ) ) ) ;
			count++;
		}
	}
	
	if ( ! count ) {

		SendClientMessage ( playerid, COLOR_DEFAULT, "You have no job cooldown timers." ) ;
	}

	return true ;
}


CMD:cooldowns ( playerid, params [] ) {

	return cmd_checkjobcooldown ( playerid, params ) ;
}

CMD:cooldown ( playerid, params [] ) {

	return cmd_checkjobcooldown ( playerid, params ) ;
}
