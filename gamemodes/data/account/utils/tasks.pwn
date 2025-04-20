/*

	Create predefined points and create a dynamic moving arrow.

	-2239.5579, 2357.5815, 4.9803 // task_fishsell
	-2229.0227, 2353.0476, 7.5480 // task_rodsell

	

*/

enum task_data {
	task_id,
	task_desc [ 256 ]

} ;

new TaskList [ ] [ task_data ] = {

	{ 1, "Catch your first fish by opening your inventory by pressing \"N\", clicking on the fishing rod tile, and clicking \"Equip\". Once it has been equipped, press \"LALT\" near a water source to fish." },
	{ 2, "Sell your caught fish by opening your inventory and pressing \"N\", clicking on a fish tile, and clicking \"Sell\" whilst being in any hunting store." },
	{ 3, "Cut down your first tree by equipping your hatchet from your inventory, walking up to any birch tree and pressing \"LALT\"." },
	{ 4, "Sell your logs by opening your inventory and pressing \"N\", clicking on any log tile, and clicking \"Sell\" whilst being in a blacksmith business." },
	{ 5, "Mine your first ore by equipping your pickaxe from your inventory, walking up to a ore and pressing \"LALT\"." },
	{ 6, "Sell your ore by opening your inventory and pressing \"N\", clicking on any ore tile, and clicking \"Sell\" whilst being in a blacksmith business." },
	{ 7, "Kill your first deer or cow by using /unholster with any firearm and shooting the animal." },
	{ 8, "Sell your animal hide/animal meat/animal leg by opening your inventory and pressing \"N\", clicking on the appropriate tile, and clicking \"Sell\" whilst being in any hunting store." }

} ;


enum task_label_data {

	t_label_id, // to be used in conjunction with task_id, for the moving arrow
	t_label_name [ 64 ],
	Float: t_label_x,
	Float: t_label_y,
	Float: t_label_z
} ;

new TaskLabels [ ] [ task_label_data ] = {
	
	{ 2, "[Server Tutorial]\n{DEDEDE}Empty Fishing Stall", 		-2229.0227, 2353.0476, 7.5480 }

}, DynamicText3D: task_label [ sizeof ( TaskLabels ) ] ;

enum task_checkpoint_data {

	t_checkpoint_id,
	Float: t_checkpoint_x,
	Float: t_checkpoint_y,
	Float: t_checkpoint_z,
	Float: t_checkpoint_size
} ;

new TaskCheckpoints [ ] [ task_checkpoint_data ] = {

	{ 2, -2229.0227, 2353.0476, 7.5480, 1.0 }
} ;

new DoingTask [ MAX_PLAYERS ], TaskCheckpoint [ MAX_PLAYERS ] ;

ReturnTaskListSize () { return sizeof ( TaskList ) ; }

Init_TaskLabels ( ) {

	for ( new i; i < sizeof ( TaskLabels ) ; i ++ ) {

		task_label [ i ] = CreateDynamic3DTextLabel(TaskLabels [ i ] [ t_label_name ], 0x77D472FF, TaskLabels [ i ] [ t_label_x ], TaskLabels [ i ] [ t_label_y ], TaskLabels [ i ] [ t_label_z ], 15.0 ) ;
	}

	return true ;
}

SetTaskCheckPoint ( playerid, taskid ) {

	if ( TaskCheckpoint [ playerid ] != -1 ) { return false ; }

	for ( new i; i < sizeof ( TaskCheckpoints ) ; i ++ ) {

		if ( TaskCheckpoints [ i ] [ t_checkpoint_id ] == taskid ) {

			TaskCheckpoint [ playerid ] = CreateDynamicCP ( TaskCheckpoints [ i ] [ t_checkpoint_x ], TaskCheckpoints [ i ] [ t_checkpoint_y ], TaskCheckpoints [ i ] [ t_checkpoint_z ], TaskCheckpoints [ i ] [ t_checkpoint_size ] ) ;
			break ;
		}

		else continue ;
	}

	return true ;
}

ProcessTask ( playerid, taskid ) {

	if ( DoingTask [ playerid ] == -1 ) { return false ; }

	for ( new i ; i < sizeof ( TaskList ) ; i ++ ) {

		if ( i == taskid ) {

			new query [ 128 ] ;

			DoingTask [ playerid ] = -1 ;
			
			if ( ! Account [ playerid ] [ account_tutorial ] ) {

				Account [ playerid ] [ account_tutorial ] = 2 ;
			}

			else {

				Account [ playerid ] [ account_tutorial ] ++ ;
			}

			if ( Account [ playerid ] [ account_tutorial ] >= sizeof ( TaskList ) + 1 ) {

				GiveCharacterMoney ( playerid, 125, MONEY_SLOT_HAND ) ;
				SendClientMessage ( playerid, 0x649E66FF, "[TASKS]:{FFFFFF} You've completed all your tasks and recieved $125 as a reward." ) ;
			}

			else {

				SendClientMessage ( playerid, 0xC4A754FF, "[TASKS]:{FFFFFF} To proceed to the next task, use /task." ) ;
			}

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_tutorial = %d WHERE account_id = %d", Account [ playerid ] [ account_tutorial ], Account [ playerid ] [ account_id ] ) ;
			mysql_tquery ( mysql, query ) ;

			break ; 
		}

		else continue ;
	}
	return true ;
}

CMD:tasks ( playerid, params [] ) {

	SendClientMessage ( playerid, -1, "") ;
	for ( new i; i < sizeof ( TaskList ); i ++ ) {

		if ( Account [ playerid ] [ account_tutorial ] <= TaskList [ i ] [ task_id ] ) {

			if ( strlen ( TaskList [ i ] [ task_desc ] ) <= 100 ) {
				SendClientMessage(playerid, 0xC4A754FF, sprintf("[PENDING]{FFFFFF} Task %d: %s", TaskList [ i ] [ task_id ], TaskList [ i ] [ task_desc ] ) ) ;
			}

			else if ( strlen ( TaskList [ i ] [ task_desc ] ) > 100 ) {

				SendClientMessage(playerid, 0xC4A754FF, sprintf("[PENDING]{FFFFFF} Task %d: %.100s", TaskList [ i ] [ task_id ], TaskList [ i ] [ task_desc ]  ) ) ;
				SendClientMessage(playerid, -1, sprintf("%s", TaskList [ i ] [ task_desc ] [ 100 ]  ) ) ;
			}
		}

		else if ( Account [ playerid ] [ account_tutorial ] > TaskList [ i ] [ task_id ] ) {

			if ( strlen ( TaskList [ i ] [ task_desc ] ) <= 100 ) {
				SendClientMessage(playerid, 0x649E66FF, sprintf("[DONE]{FFFFFF} Task %d: %s", TaskList [ i ] [ task_id ], TaskList [ i ] [ task_desc ] ) ) ;
			}

			else if ( strlen ( TaskList [ i ] [ task_desc ] ) > 100 ) {
				
				SendClientMessage(playerid, 0x649E66FF, sprintf("[DONE]{FFFFFF} Task %d: %.100s", TaskList [ i ] [ task_id ], TaskList [ i ] [ task_desc ]  ) ) ;
				SendClientMessage(playerid, -1, sprintf("%s", TaskList [ i ] [ task_desc ] [ 100 ]  ) ) ;
			}

		}
	}

	SendClientMessage ( playerid, -1, "") ;

	SendClientMessage(playerid, -1, "To do your next task, use /task to start the sequence. To cancel, use /notask." ) ;

	return true ;
}

CMD:task ( playerid, params [] ) {

	if ( DoingTask [ playerid ] != -1 ) {

		new id = DoingTask [ playerid ] ;

		if ( strlen ( TaskList [ id ] [ task_desc ] ) <= 100 ) {

			SendClientMessage(playerid, -1, sprintf("Task %d: %s", TaskList [ id ] [ task_id ], TaskList [ id ] [ task_desc ] ) ) ;
		}

		else if ( strlen ( TaskList [ id ] [ task_desc ] ) > 100 ) {

			SendClientMessage(playerid, -1, sprintf("Task %d: %.100s", TaskList [ id ] [ task_id ], TaskList [ id ] [ task_desc ]  ) ) ;
			SendClientMessage(playerid, -1, sprintf("%s", TaskList [ id ] [ task_desc ] [ 100 ]  ) ) ;
		}

		return SendServerMessage ( playerid, "You're already doing a task.  Use /notask to cancel your current task.", MSG_TYPE_ERROR ) ;
	}

	new taskid = Account [ playerid ] [ account_tutorial ] ;

	if ( ! taskid ) { taskid = 1 ; }

	if ( taskid >= sizeof ( TaskList ) + 1 ) {

		return SendServerMessage ( playerid, "You've already completed all your tasks.", MSG_TYPE_ERROR ) ;
	}

	for ( new i ; i < sizeof ( TaskList ) ; i ++ ) {

		if ( TaskList [ i ] [ task_id ] == taskid ) {
		
			if ( strlen ( TaskList [ i ] [ task_desc ] ) <= 100 ) {

				SendClientMessage(playerid, -1, sprintf("Task %d: %s", TaskList [ i ] [ task_id ], TaskList [ i ] [ task_desc ] ) ) ;
			}

			else if ( strlen ( TaskList [ i ] [ task_desc ] ) > 100 ) {

				SendClientMessage(playerid, -1, sprintf("Task %d: %.100s", TaskList [ i ] [ task_id ], TaskList [ i ] [ task_desc ]  ) ) ;
				SendClientMessage(playerid, -1, sprintf("%s", TaskList [ i ] [ task_desc ] [ 100 ]  ) ) ;
			}

			//SetTaskCheckPoint ( playerid, taskid ) ;

			DoingTask [ playerid ] = i ;

			break ;
		}
	}

	return true ;
}

CMD:notask ( playerid, params [ ] ) {

	if ( DoingTask [ playerid ] != -1 ) {

		if ( TaskCheckpoint [ playerid ] != -1 ) {

			DestroyDynamicCP ( TaskCheckpoint [ playerid ] ) ;
			TaskCheckpoint [ playerid ] = -1 ;
		}

		DoingTask [ playerid ] = -1 ;

		SendServerMessage ( playerid, "You've cancelled your current task.", MSG_TYPE_INFO ) ;
	}

	else SendServerMessage ( playerid, "You aren't doing a task!", MSG_TYPE_ERROR ) ;
	return true ;
}