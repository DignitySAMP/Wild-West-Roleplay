/*
new TutorialProgress [ MAX_PLAYERS ] ; // Tracks tut progress
#define MAX_TUTORIAL_PROGRESS	( 7 ) // highest tut value
#define TUTORIAL_WORLD 			(666)

enum TaskData {
	task_id,
	task_desc [ 128 ]
} ;

new TutorialTasks [ ] [ TaskData ] = {
	{0, "Read the dialogue to initiate the tutorial sequence." },
	{1, "Make your way to the plotting table's checkpoint. It should be near the creek."},
	{2, "Fetch a fishing rod from the rack of items by pressing ~k~~SNEAK_ABOUT~ near the rack."},
	{3, "Open your inventory using ~k~~CONVERSATION_NO~, click on the fishing rod and click EQUIP."},
	{4, "You can close your inventory with ESC. Catch a fish in the lake for the elderly."},
	// Spawn a checkpoint, if they enter the checkpoint tell them to press ALT

	{5, "You caught a fish! Head to the market not too far from here and sell the fish."},
	// Once again, add a checkpoint. Once they enter it tell them to open inventory, click on fish and click sell


	{6, "You sold the fish. You hear a crowd rallying at the southern gate. It seems the caravan is going to move!"}


} ;

CMD:tasks(playerid, params [] ) {

	if ( TutorialProgress [ playerid ] >= 7 ) { return SendServerMessage ( playerid, "You're already done with the tutorial!", MSG_TYPE_ERROR ) ; }
	ProcessTutorialTask ( playerid ) ;
	return ShowTutorialTasks ( playerid ) ;
}

new TutorialCheckpoint [ MAX_PLAYERS ] ;
ShowTutorialTasks ( playerid ) {

	for ( new i; i < sizeof ( TutorialTasks ); i ++ ) {

		if ( TutorialProgress [ playerid ] == TutorialTasks [ i ] [ task_id ] ) {

			SendClientMessage(playerid, 0xC4A754FF, sprintf("[PENDING] Task %d: %s", TutorialTasks [ i ] [ task_id ], TutorialTasks [ i ] [ task_desc ] ) ) ;
		}

		else if ( TutorialProgress [ playerid ] > TutorialTasks [ i ] [ task_id ] ) {

			SendClientMessage(playerid, 0x649E66FF, sprintf("[DONE] Task %d: %s", TutorialTasks [ i ] [ task_id ], TutorialTasks [ i ] [ task_desc ] ) ) ;
		}

		//else if ( TutorialProgress [ playerid ] < TutorialTasks [ i ] [ task_id ] ) {

		//	SendClientMessage(playerid, 0xA34545FF, sprintf("[NOT DONE] Task %d: %s", TutorialTasks [ i ] [ task_id ], TutorialTasks [ i ] [ task_desc ] ) ) ;
		//}
	}

	return true ;
}

ProcessTutorialTask ( playerid ) {

	switch ( TutorialProgress [ playerid ] ) {

		case 0: {

			TogglePlayerControllable(playerid, false ) ;
			BlackScreen ( playerid ) ;

			ac_SetPlayerPos ( playerid, -1975.3352, -1517.4036, 89.0242 ) ;
			SetPlayerVirtualWorld(playerid, TUTORIAL_WORLD + playerid ) ;

		 	inline creationNameSel(pid, dialogid, response, listitem, string: inputtext[]) {
			    #pragma unused pid, dialogid, listitem, inputtext

		 		if ( response ) {

 					defer DelayTutorialStart(playerid) ;
 					return true ;
		 		}
			}

			new string [ 1024 ];

			strcat(string,"Whether your character was born here or traveled with the for opportunity, wealth or a new life, you find yourself in a refugee camp east of the island of Tierra Robada, an independant republic.\n");
			strcat(string,"It's no secret the land of Tierra Robada is eagerly accepting new souls to help progress the newly found, not-so fertile lands of the West, and many see it as a new life.\n");
			strcat(string,"An upcoming struggle between the diplomats of the United States about the negro-slavery culture has found not just you, but a lot of other refugees in the camp. Many of the refugees are ex militants who fought in the Texas - Indian war, hopelessly looking for new opportunities.\n");			
			strcat(string,"The camp has prospered since it was first set up. It should be time to move soon.\n\nYou wake up as the camp's foreman calls you...");

			return Dialog_ShowCallback ( playerid, using inline creationNameSel, DIALOG_STYLE_MSGBOX, "Introduction", string, "Continue", "" );
		}

		case 1: {

			if ( IsValidDynamicCP ( TutorialCheckpoint [ playerid ] ) ) {
				DestroyDynamicCP ( TutorialCheckpoint [ playerid ] );
			}

			TutorialCheckpoint [ playerid ] = CreateDynamicCP ( -1992.1974, -1486.3811, 84.2162, 2.0, TUTORIAL_WORLD + playerid, 0, playerid ) ;
		}

		case 2: {

			if ( IsValidDynamicCP ( TutorialCheckpoint [ playerid ] ) ) {
				DestroyDynamicCP ( TutorialCheckpoint [ playerid ] );
			}

			TutorialCheckpoint [ playerid ] = CreateDynamicCP ( -1998.6089, -1483.9510, 83.6516, 2.0, TUTORIAL_WORLD + playerid, 0, playerid ) ;
		}

		case 3: {
			
			if ( IsValidDynamicCP ( TutorialCheckpoint [ playerid ] ) ) {
				DestroyDynamicCP ( TutorialCheckpoint [ playerid ] );
			}

			TutorialCheckpoint [ playerid ] = CreateDynamicCP ( -1999.2411, -1480.0071, 83.6516, 2.0, TUTORIAL_WORLD + playerid, 0, playerid ) ;	
		}

		case 5: {
			
			if ( IsValidDynamicCP ( TutorialCheckpoint [ playerid ] ) ) {
				DestroyDynamicCP ( TutorialCheckpoint [ playerid ] );
			}

			TutorialCheckpoint [ playerid ] = CreateDynamicCP ( -1984.2886, -1497.4163, 85.5575, 2.0, TUTORIAL_WORLD + playerid, 0, playerid ) ;	
		}

		case 6: {
			
			if ( IsValidDynamicCP ( TutorialCheckpoint [ playerid ] ) ) {
				DestroyDynamicCP ( TutorialCheckpoint [ playerid ] );
			}

			TutorialCheckpoint [ playerid ] = CreateDynamicCP ( -1996.1095, -1570.5737, 85.8992, 2.0, TUTORIAL_WORLD + playerid, 0, playerid ) ;	
		}
	}

	new query [ 256 ] ;

	Account [ playerid ] [ account_tutorial ] = TutorialProgress [ playerid ] ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_tutorial = %d WHERE account_id = %d", Account [ playerid ] [ account_tutorial ], Account [ playerid ] [ account_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	if ( TutorialProgress [ playerid ] == 7 ) {

		SendClientMessage(playerid, COLOR_TAB0, "[TASK] You have finished the first tutorial sequence. You will now be taken to the next area." ) ; //error line?
		SpawnPlayer_Character ( playerid ) ;

		return true ;
	}


	if ( TutorialProgress [ playerid ] > sizeof ( TutorialTasks ) ) {

		SendClientMessage(playerid, -1, " " ) ;
		SendClientMessage(playerid, 0xC4A754FF, sprintf("There's an error processing your task message. Contact a developer with this info: [TASK: %d; ARRAY SIZEOF: %d]", TutorialProgress [ playerid ], sizeof ( TutorialTasks ) ) ) ;
		return SendClientMessage(playerid, -1, "To continue, type /tasks. If this error persists, contact a advanced administrator." ) ;
	}


	SendClientMessage(playerid, -1, " ") ;
	SendClientMessage(playerid, COLOR_TAB0, sprintf("[TASK %d] %s", TutorialTasks [ TutorialProgress [ playerid ] ] [ task_id ], TutorialTasks [ TutorialProgress [ playerid ] ] [ task_desc] ) ) ;


	return true ;
}

FinishTutorialSequence ( playerid ) {

	TutorialProgress [ playerid ] = 7 ;

	ProcessTutorialTask ( playerid ) ;

	return true ;
}

// When they sell the fish: GiveCharacterMoney ( playerid, 50, MONEY_SLOT_HAND ) ;
public OnPlayerEnterDynamicCP(playerid, STREAMER_TAG_CP checkpointid) {

	if ( TutorialProgress [ playerid ] < MAX_TUTORIAL_PROGRESS) {

		if ( checkpointid == TutorialCheckpoint [ playerid ] ) {

			if ( IsValidDynamicCP ( TutorialCheckpoint [ playerid ] ) ) {
				DestroyDynamicCP ( TutorialCheckpoint [ playerid ] );
			}

			switch ( TutorialProgress [ playerid ] ) {

				case 1: {

					TutorialProgress [ playerid ] ++ ;
					ProcessTutorialTask ( playerid ) ;

				}

				case 2: {

					SendClientMessage(playerid, COLOR_TAB2, "To pick up a fishing rod, press {37A7CC}~k~~SNEAK_ABOUT~{DEBD8A} near the rack of nets and rods .." ) ;
					SendClientMessage(playerid, COLOR_TAB2, ".. {37A7CC}~k~~SNEAK_ABOUT~{DEBD8A} is our main action key for performing general actions such .." ) ;
					SendClientMessage(playerid, COLOR_TAB2, "as picking up items, performing jobs, and so on." ) ;

					//ProcessTutorialTask ( playerid ) ;
				}

				case 3 .. 4: {

					SendClientMessage(playerid, COLOR_TAB2, "To catch a fish, simply use the {37A7CC}~k~~SNEAK_ABOUT~{DEBD8A} key to start the progress. This will open the action dialog ..." ) ;
					SendClientMessage(playerid, COLOR_TAB2, "... which is used for nearly every interactive system. To cancel, click {37A7CC}~k~~PED_FIREWEAPON~{DEBD8A}. To fish, fill up the progress  ..." ) ;
					SendClientMessage(playerid, COLOR_TAB2, "... bar by rapidly tapping {37A7CC}~k~~PED_LOCK_TARGET~{DEBD8A}. Once the progress bar is full, you will be given a fish of random value." ) ;
					
				}

				case 5: {

					SendClientMessage(playerid, COLOR_TAB2, "Open your inventory by using {37A7CC}~k~~CONVERSATION_NO~{DEBD8A} and click on the fish. Once the usage menu is open, click ..." ) ;
					SendClientMessage(playerid, COLOR_TAB2, "on {D17F5E}\"SELL\"{DEBD8A} in order to sell it to the stall. You'll get some money for it which you'll get to keep." ) ;
				}

				case 6: {

					FinishTutorialSequence ( playerid ) ;
				}
			}

			return true ;
		}
	}
	
	#if defined tut_OnPlayerEnterDynamicCP
		return tut_OnPlayerEnterDynamicCP(playerid STREAMER_TAG_CP checkpointid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEnterDynamicCP
	#undef OnPlayerEnterDynamicCP
#else
	#define _ALS_OnPlayerEnterDynamicCP
#endif

#define OnPlayerEnterDynamicCP tut_OnPlayerEnterDynamicCP
#if defined tut_OnPlayerEnterDynamicCP
	forward tut_OnPlayerEnterDynamicCP(playerid STREAMER_TAG_CP checkpointid);
#endif

timer DelayTutorialStart[200](playerid) {

////	print("DelayTutorialStart timer called (tutorial.pwn)");

	TutorialProgress [ playerid ]  = 1 ;
	ProcessTutorialTask ( playerid ) ;

	FadeIn ( playerid ) ;

	TogglePlayerControllable(playerid, true ) ;
	ac_SetPlayerPos ( playerid, -1975.3352, -1517.4036, 89.0242 ) ;
	
	return true ;
}

CMD:progress ( playerid, params [] ) {

	return SendClientMessage(playerid, -1, sprintf("%d", TutorialProgress [ playerid ] ) ) ;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

	if ( newkeys & KEY_WALK && TutorialProgress [ playerid ] != MAX_TUTORIAL_PROGRESS ) {

		switch ( TutorialProgress [ playerid ] ) {

	 		case 2: {

			 	if ( IsPlayerInRangeOfPoint(playerid, 2.5, -1998.6089, -1483.9510, 83.6516 ) ) {

					GivePlayerItemByParam ( playerid, PARAM_FISHING, FISHING_ROD, 1, 0, 0, 0 ) ;
					TutorialProgress [ playerid ] ++ ;

					if ( IsValidDynamicCP ( TutorialCheckpoint [ playerid ] ) ) {
						DestroyDynamicCP ( TutorialCheckpoint [ playerid ] );
					}

					ProcessTutorialTask ( playerid ) ;

					return true ;
				}

				else {

					if ( IsValidDynamicCP ( TutorialCheckpoint [ playerid ] ) ) {
						DestroyDynamicCP ( TutorialCheckpoint [ playerid ] );
					}

					TutorialCheckpoint [ playerid ] = CreateDynamicCP ( -1998.6089, -1483.9510, 83.6516, 2.0, TUTORIAL_WORLD + playerid, 0, playerid ) ;

					return SendServerMessage ( playerid, "You're not near the rod and net rack. Head to the checkpoint.", MSG_TYPE_ERROR ) ;
				}
			}
	
			case 4: {

				if ( EquippedItem [ playerid ] != FISHING_ROD ) {

					return SendServerMessage ( playerid, "How are you going to fish without a fishing rod? Make sure you have it equipped.", MSG_TYPE_ERROR ) ;
				}

				if ( IsPlayerFishing [ playerid ] ) {

					return SendServerMessage ( playerid, "Seems like you're already fishing. Press {37A7CC}~k~~PED_FIREWEAPON~{DEBD8A} to cancel and try again.", MSG_TYPE_ERROR ) ;
				}

				if ( ! IsPlayerInRangeOfPoint(playerid, 2.5, -1999.2411, -1480.0071, 83.6516 ) ) {

					if ( IsValidDynamicCP ( TutorialCheckpoint [ playerid ] ) ) {
						
						DestroyDynamicCP ( TutorialCheckpoint [ playerid ] );
					}

					TutorialCheckpoint [ playerid ] = CreateDynamicCP ( -1999.2411, -1480.0071, 83.6516, 2.0, TUTORIAL_WORLD + playerid, 0, playerid ) ;	

					return SendServerMessage ( playerid, "You're not near the creek. Head to the checkpoint and try again.", MSG_TYPE_ERROR ) ;
				}

				SetPlayerFacingAngle ( playerid, 91.3205 ) ;

				new Float: x, Float: y, Float: z, Float:xy_x, Float: xy_y, Float: xy_z, distance = 1 + random ( 12 ) ;		
				GetPlayerPos ( playerid, x, y, z ) ;

				GetXYInFrontOfPlayer ( playerid, xy_x, xy_y, distance ) ;
				CA_FindZ_For2DCoord(xy_x, xy_y, xy_z ) ;

				SendServerMessage ( playerid, sprintf("You've thrown your bobber {C74646}%d{dedede} yards into the water.", distance ), MSG_TYPE_ERROR ) ;

				player_DobberPoint [ playerid ] = distance ;
				ApplyAnimation(playerid,"SWORD","sword_block",50.0,0,1,0,1,1);

				HideActionGUI ( playerid ) ;

				TogglePlayerControllable ( playerid, false ) ;

				if ( IsValidDynamicObject(player_RopeLine [ playerid ])) {
					
					DestroyDynamicObject(player_RopeLine [ playerid ] ) ;
				}

				player_RopeLine [ playerid ] = CreateDynamicObject(19089, x, y, z, 0, 60, 90);
				player_FishCircle [ playerid ] = CreateDynamicCircle(x, y, 2.0, GetPlayerVirtualWorld(playerid), 0, playerid ) ;

				OnPlayerFish ( playerid ) ;
				IsPlayerFishing [ playerid ] = true ;
			}
		}

	}

	#if defined tut_OnPlayerKeyStateChange
		return tut_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif

#define OnPlayerKeyStateChange tut_OnPlayerKeyStateChange
#if defined tut_OnPlayerKeyStateChange
	forward tut_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

HandleTutorial ( playerid ) {
	
	//TutorialProgress [ playerid ] = Account [ playerid ] [ account_tutorial ] ;

	if ( Account [ playerid ] [ account_tutorial ] < MAX_TUTORIAL_PROGRESS ) {
		
		TogglePlayerControllable(playerid, false ) ;
		FadeIn ( playerid ) ;

		ac_SetPlayerPos ( playerid, -1975.3352, -1517.4036, 89.0242 ) ;
		SetPlayerVirtualWorld(playerid, TUTORIAL_WORLD + playerid ) ;

		return ProcessTutorialTask ( playerid ) ;	


		TutorialProgress [ playerid ] = MAX_TUTORIAL_PROGRESS ;
		GiveCharacterMoney ( playerid, 100, MONEY_SLOT_HAND ) ;

		Account [ playerid ] [ account_tutorial ] = 7 ;
		TutorialProgress [ playerid ] = 7 ;

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_tutorial = %d WHERE account_id = %d", Account [ playerid ] [ account_tutorial ], Account [ playerid ] [ account_id ] ) ;
		mysql_tquery ( mysql, query ) ;
	}

	return true ;
}

*/