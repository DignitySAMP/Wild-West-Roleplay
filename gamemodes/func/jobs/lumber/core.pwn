#define MAX_CUT_TREES 1000

new Iterator: ValidTrees < MAX_CUT_TREES > ;

enum E_WOODCUT_DATA {
	treeID, 
	treeObjectID, 
	treeType, 
	Float: treeHealth, 
	Float: treePos [ 3 ], 
	treeObject, 
	DynamicText3D: treeLabel
} ;

new Tree[MAX_CUT_TREES][E_WOODCUT_DATA];

new CuttingProgress[MAX_PLAYERS] ;
new player_TreeCircle [ MAX_PLAYERS ] ;

Init_WoodcutTrees () {

    Iter_Init(ValidTrees);

   	for ( new i; i < MAX_CUT_TREES; i ++ )  {

        ResetTreeVariables(i);
	}

	return 1;
}

ResetTreeVariables ( treeid ) {

	Tree [ treeid ] [ treeID ] 			= -1;
	Tree [ treeid ] [ treeObjectID ] 	= -1;
	Tree [ treeid ] [ treeType ]	 	= -1;

	Tree [ treeid ] [ treeHealth ] 		= 100.0;

	Tree [ treeid ] [ treePos ] [ 0 ] 	= 0.0;
	Tree [ treeid ] [ treePos ] [ 1 ] 	= 0.0;
	Tree [ treeid ] [ treePos ] [ 2 ] 	= 0.0;

	if ( Tree [ treeid ] [ treeObject ] != -1) { 

		DestroyDynamicObject ( Tree [ treeid ] [ treeObject ] ) ; 
	}

	Tree [ treeid ] [ treeObject ] = -1;

	if ( IsValidDynamic3DTextLabel ( Tree[  treeid ] [ treeLabel ] ) ) {
		DestroyDynamic3DTextLabel ( Tree[  treeid ] [ treeLabel ] ) ;
	}

	if ( Iter_Contains ( ValidTrees, treeid ) ) { 
		Iter_Remove ( ValidTrees, treeid ) ; 
	}

	return 1;
}

IsPlayerInRangeOfTree ( playerid, Float:range ) {

	foreach(new i: ValidTrees) {

	    if ( IsPlayerInRangeOfPoint ( playerid, range, Tree [ i ] [ treePos ] [ 0 ], Tree [ i ] [ treePos ] [ 1 ], Tree [ i ] [ treePos ] [ 2 ] ) ) { 
	    	return i; 
	    }
	}

	return -1;
}


FindFreeTreeID() {

	for ( new i; i < MAX_CUT_TREES; i++ ) {

	    if ( Tree [ i ] [ treeID ] == -1 ) { 

	    	return i; 
	    }
	}

	return -1;
}

GetTreeType ( treeid ) {

	new string [ 64 ] ;

	switch ( Tree [ treeid ] [ treeType ] ) {

	    case 0: string = "{C9C9C9}Birch Tree{FFFFFF}" ;
	    case 1: string = "{BA9F7B}Oak Tree{FFFFFF}" ;
	    case 2: string = "{96744D}Yew Tree{FFFFFF}" ;
	    default: string = "Error" ;
	}

	return string;
}

GetTreeTypeEx ( treeid ) {

	new string [ 64 ] ;

	switch ( Tree [ treeid ] [ treeType ] ) {

	    case 0: string = "Birch Tree" ;
	    case 1: string = "Oak Tree" ;
	    case 2: string = "Yew Tree" ;
	    default: string = "Error" ;
	}

	return string;
}

new treeCount ;
CreateTree ( Float: x, Float: y, Float: z ) {

	new id = FindFreeTreeID(), type = randomEx(0, 2) ;

	if ( id == -1 ) {

		return false ;
	}

	Tree [ id ] [ treeID ] 			= id;
	Tree [ id ] [ treeObjectID ] 	= 669;
	Tree [ id ] [ treeType ] 		= type;

	Tree [ id ] [ treeHealth ] 		= 100.0;

	Tree [ id ] [ treePos ] [ 0 ] 	= x;
	Tree [ id ] [ treePos ] [ 1 ] 	= y;
	Tree [ id ] [ treePos ] [ 2 ] 	= z;

	Tree[ id ] [ treeObject ] 	 	= CreateDynamicObject ( Tree[ id ] [ treeObjectID ] , 
		Tree[ id ] [ treePos ] [ 0 ], Tree[ id ] [ treePos ] [ 1 ], Tree[ id ] [ treePos ] [ 2 ],
		 0.0, 0.0, 0.0, -1, -1, -1, 150, 150) ; //1000

	Tree[ id ] [ treeLabel ]  		= CreateDynamic3DTextLabel ( sprintf ( "%s\nHealth: %i", GetTreeType ( id ), floatround ( Tree[ id ] [ treeHealth ] ) ), 
		-1, Tree[ id ] [ treePos ] [ 0 ] , Tree[ id ] [ treePos ] [ 1 ] , Tree[ id ] [ treePos ] [ 2 ] + 0.5, 7.0 ) ;

	SetTreeColor ( id ) ;
	Iter_Add ( ValidTrees, id ) ;

	treeCount ++ ;

	return true ;
}



SetTreeColor ( treeid ) {

	if ( Tree [ treeid ] [ treeHealth ] > 0) {

		switch ( Tree [ treeid ] [ treeType ]  ) {
	    	case 0: { //birch
	    		SetDynamicObjectMaterial ( Tree [ treeid ] [ treeObject ], 0, 708, "none", "none", 0x00FFFFFF ) ; 
	    		SetDynamicObjectMaterial ( Tree [ treeid ] [ treeObject ], 1, 5847, "lawnbush", "kbplanter_plants1", 0xFFFFFFFF ) ; 
	    		SetDynamicObjectMaterial ( Tree [ treeid ] [ treeObject ], 2, 5847, "lawnbush", "kbplanter_plants1", 0xFFFFFFFF ) ; 
	    		SetDynamicObjectMaterial ( Tree [ treeid ] [ treeObject ], 3, 708, "gta_tree_boak", "sm_bark_light", 0xFFFFFFFF ) ; 
	    	}

	    	case 1: {  //oak
	    		SetDynamicObjectMaterial ( Tree [ treeid ] [ treeObject ], 0, 708, "none", "none", 0x00FFFFFF ) ; 
	    		SetDynamicObjectMaterial ( Tree [ treeid ] [ treeObject ], 3, -1, "none", "none", 0xFFA0A0A0 ) ; 
	    	}

	    	case 2: { //yew
	    		SetDynamicObjectMaterial ( Tree [ treeid ] [ treeObject ], 0, 708, "none", "none", 0x00FFFFFF ) ; 
	    		SetDynamicObjectMaterial ( Tree [ treeid ] [ treeObject ], 1, 708, "gta_tree_boak", "newtreeleavesb128", 0xFFFFFFFF ) ; 
	    		SetDynamicObjectMaterial ( Tree [ treeid ] [ treeObject ], 2, 708, "gta_tree_boak", "newtreeleavesb128", 0xFFFFFFFF ) ; 
	    		SetDynamicObjectMaterial ( Tree [ treeid ] [ treeObject ], 3, 708, "gta_tree_boak", "sm_redwood_bark", 0xFF5F5F5F ) ; 
	    	} 
		}
	}

	else {

	    switch ( Tree [ treeid ] [ treeType ] ) {

	    	case 0: SetDynamicObjectMaterial ( Tree [ treeid ] [ treeObject ], 0, 708, "gta_tree_boak", "sm_bark_light", 0xFFFFFFFF ) ;  //birch
	    	case 1: SetDynamicObjectMaterial ( Tree [ treeid ] [ treeObject ], 0, -1, "none", "none", 0xFFA0A0A0 ) ; //oak
	    	case 2: SetDynamicObjectMaterial ( Tree [ treeid ] [ treeObject ], 0, 708, "gta_tree_boak", "sm_redwood_bark", 0xFF5F5F5F ) ; //yew
		}
	}

	return 1;
}

DecreaseTreeHealth(treeid) {
	switch ( Tree [ treeid ] [ treeType ] ) {

	    case 0: Tree [ treeid ] [ treeHealth ] -= 50.0 ; //birch
	    case 1: Tree [ treeid ] [ treeHealth ] -= 25.0 ; //oak
	    case 2: Tree [ treeid ] [ treeHealth ] -= 20.0 ; //yew
	}

	UpdateDynamic3DTextLabelText ( Tree [ treeid ] [ treeLabel ], -1, sprintf ( "%s\nHealth: %i", GetTreeType ( treeid ), floatround ( Tree [ treeid ] [ treeHealth ] ) ) ) ;

	return 1;
}

timer RespawnTree[900000](treeid) { // 15 min respawn time

////	print("RespawnTree timer called (lumber/core.pwn)");

	if ( Tree [ treeid ] [ treeHealth ] <= 0 ) {

		if ( IsValidDynamicObject(Tree [ treeid ] [ treeObject ])) {
			DestroyDynamicObject ( Tree [ treeid ] [ treeObject ] ) ;
		}

		if ( IsValidDynamic3DTextLabel( Tree [ treeid ] [ treeLabel ] ) ) {
			DestroyDynamic3DTextLabel ( Tree [ treeid ] [ treeLabel ] ) ;
		}

		Tree [ treeid ] [ treeObjectID]  	= 669 ;
		Tree [ treeid ] [ treeHealth ] 		= 100.0 ;


		CA_FindZ_For2DCoord ( Tree [ treeid]  [ treePos ] [ 0 ], Tree[treeid][treePos][1], Tree[treeid][treePos][2] ) ;

		Tree [ treeid ] [ treeObject ] = CreateDynamicObject ( Tree [ treeid ] [ treeObjectID ], 
		Tree [ treeid]  [ treePos ] [ 0 ], Tree[treeid][treePos][1], Tree[treeid][treePos][2], 0.0, 0.0, 0.0 ) ;
	
		Tree [ treeid ] [ treeLabel ] = CreateDynamic3DTextLabel ( sprintf ( "%s\nHealth: %i", GetTreeType ( treeid ), floatround ( Tree [ treeid ] [ treeHealth ] ) ), 
			-1, Tree [ treeid ] [ treePos ] [ 0 ], Tree [ treeid ] [ treePos ] [ 1 ], Tree [ treeid ] [ treePos ] [ 2 ] + 0.5, 7.0 ) ;
	
		SetTreeColor ( treeid ) ;
	}

	return 1;
}

CutTree ( playerid, treeid ) {

	SendClientMessage ( playerid, -1, sprintf("You have chopped down a %s (id %d)", GetTreeType ( treeid ), treeid ) ) ;
	UpdateDynamic3DTextLabelText ( Tree [ treeid ] [ treeLabel ], -1, sprintf ( "%s\nHealth: %i", GetTreeType ( treeid ), floatround ( Tree [ treeid ] [ treeHealth ] ) ) ) ;

	ApplyAnimation ( playerid, "RIOT", "RIOT_ANGRY_B", 4.1, 0, 1, 1, 1, 1, 1 ) ;
	DecreaseTreeHealth ( treeid ) ;

	// START ACTION BAR INTEGRATION CODE
	OnPlayerCutTree ( playerid, treeid ) ;
	//OldLog ( playerid, "job/tree", sprintf ( "%s has cut %s, weight: %0.2f.", ReturnUserName ( playerid, false ), GetTreeTypeEx ( treeid ) )) ;

	new xp = 1 + random ( 2 ) ;
	GivePlayerExperience ( playerid, xp ) ;

	/*
	PlayerTextDrawSetString(playerid, actionGUI_infoText, 
		sprintf("| You've mined a %s.~n~~n~~w~ + %d exp for Woodcut Level!", GetTreeTypeEx ( treeid ), xp ) ) ;		

	PlayerTextDrawSetPreviewModel ( playerid, actionGUI_PreviewBoxModel, 19632 ) ;

	PlayerTextDrawHide ( playerid, actionGUI_PreviewBoxModel ) ;
	PlayerTextDrawShow ( playerid, actionGUI_PreviewBoxModel ) ;
	HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;*/

	ActionPanel_ChangeGUI ( playerid, sprintf("| You've mined a %s.~n~~n~~w~ + %d exp for Woodcut Level!", GetTreeTypeEx ( treeid ), xp ), 19632, false ) ;


	// END CODE ACTION GUI

  	CuttingProgress [ playerid ] 	= 0 ;
   	IsCuttingTree [ playerid ] 		= false ;

	TogglePlayerControllable ( playerid, 1 ) ;

	if ( Tree [ treeid ] [ treeHealth ] <= 0.0 ) {

	    new rand = randomEx ( 831, 832 ) ;
	    Tree [ treeid ] [ treeHealth ] = 0;

		if ( IsValidDynamicObject(Tree [ treeid ] [ treeObject ])) {
			DestroyDynamicObject ( Tree [ treeid ] [ treeObject ] ) ;
		}

		if ( IsValidDynamic3DTextLabel( Tree [ treeid ] [ treeLabel ] ) ) {
			DestroyDynamic3DTextLabel ( Tree [ treeid ] [ treeLabel ] ) ;
		}

	    Tree [ treeid ] [ treeObjectID ] = rand;

		CA_FindZ_For2DCoord ( Tree [ treeid]  [ treePos ] [ 0 ], Tree[treeid][treePos][1], Tree[treeid][treePos][2] ) ;

	    Tree [ treeid ] [ treeObject]  = CreateDynamicObject( Tree [ treeid ] [ treeObjectID ], 
	    	Tree [ treeid ] [ treePos ] [ 0 ], Tree [ treeid ] [ treePos ] [ 1 ] , Tree[treeid][treePos][2], 0.0, 0.0, 0.0)  ;
	
		Tree [ treeid ] [ treeLabel ] = CreateDynamic3DTextLabel ( sprintf ( "%s Stump", GetTreeType ( treeid ) ), -1, Tree [ treeid ] [ treePos ] [ 0 ], Tree [ treeid ] [ treePos ] [ 1 ], Tree [ treeid ] [ treePos ] [ 2 ] + 0.5, 7.0 ) ;

	    SetTreeColor ( treeid ) ;
	    defer RespawnTree(treeid) ;
	}

	return 1;
}


OnPlayerCutTree ( playerid, treeid ) {

	// GivePlayerItemByParam ( playerid, item, param, amount, itemparam, param1, param2 ) 

	if ( GetTreeItemID ( treeid ) == -1 ) {

		return SendServerMessage ( playerid, sprintf("Error processing tree. Send this to a dev: [TYPE %d], [ID %d]",  Tree [ treeid ] [ treeType ], treeid ), MSG_TYPE_ERROR ) ;
	}

	new amount ;

	switch ( Tree [ treeid ] [ treeType ] ) {

		case 0: amount = 25 + random ( 25 ) ;
		case 1: amount = 45 + random ( 45 ) ;
		case 2:	amount = 75 + random ( 75 ) ;
	}

	if ( GivePlayerItemByParam ( playerid, PARAM_LUMBER, GetTreeItemID ( treeid ), 1, amount, 0, 0 ) ) {

		new query [ 128 ] ;

		Character [ playerid ] [ character_woodactionsleft ] ++;
		if ( Character [ playerid ] [ character_woodactionsleft] >= 10 ) {

			Character [ playerid ] [ character_woodactionsleft ] = 0 ;

			switch ( PlayerSkill [ playerid ] [ JOB_lumber ] ) {

				case 0,1: {

					Character [ playerid ] [ character_woodcd ] = gettime() + LVL1COOLDOWN;
				}
				case 2: {

					Character [ playerid ] [ character_woodcd ] = gettime() + LVL2COOLDOWN;
				}
				case 3: {

					Character [ playerid ] [ character_woodcd ] = gettime() + LVL3COOLDOWN;
				}
			}

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_woodactionsleft = %d, character_woodcd = %d WHERE character_id = %d", 
				Character [ playerid ] [ character_jobactionsleft ], Character [ playerid ] [ character_woodcd ], Character [ playerid ] [ character_id ] ) ;
			mysql_tquery ( mysql, query ) ;

			SendServerMessage ( playerid, "You feel tired of cutting trees, so you've decided to stop.", MSG_TYPE_WARN ) ;


			return cmd_fixjob ( playerid ) ;
		}
		
		else {

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_woodactionsleft = %d WHERE character_id = %d", 
					Character [ playerid ] [ character_jobactionsleft ], Character [ playerid ] [ character_id ] ) ;
			mysql_tquery ( mysql, query ) ;
		}

		if ( DoingTask [ playerid ] == 2 ) {

			ProcessTask ( playerid, DoingTask [ playerid ] ) ;
		}

		return printf("Player %d: %s looted tree %d", GetTreeItemID ( treeid ) ) ;
	}

	else return SendServerMessage ( playerid, "Error processing give_item for tree. Tell a dev to look at the drop for YOUR ID.", MSG_TYPE_ERROR ) ;
}

GetTreeItemID ( treeid ) {

	switch ( Tree [ treeid ] [ treeType ] ) {

		case 0: return LUMBER_BIRCH_LOG;
		case 1: return LUMBER_OAK_LOG ;
		case 2: return LUMBER_YEW_LOG ;
		default: return -1 ;
	}

	return -1 ;
}


timer CuttingTree[500] ( playerid, treeid ) {

////	print("CuttingTree timer called (lumber/core.pwn)");

	if ( IsCuttingTree [ playerid ] ) {

		if ( ! IsValidDynamicObject ( Tree [ treeid ] [ treeObject ] ) ) {

			IsCuttingTree [ playerid ]  = false ;
	  		CuttingProgress [ playerid ] = 0;

	  		if ( IsValidDynamicArea ( player_TreeCircle [ playerid ] ) ) {
				DestroyDynamicArea( player_TreeCircle [ playerid ] ) ;
	  		}

			HidePlayerProgressBar ( playerid, actionGUI_bar  ) ;
			HideActionGUI ( playerid ) ;

			return true ;
		}

	    if ( CuttingProgress [ playerid ] > 0) {

	        new remove = randomEx ( 5, 10 ) ;
	    	CuttingProgress [ playerid ] -= remove;
	    	if ( CuttingProgress [ playerid ] <= 0 ) { CuttingProgress [ playerid ] = 0 ; }
	    	SetPlayerProgressBarValue ( playerid, actionGUI_bar, CuttingProgress [ playerid ] );
		}
	    defer CuttingTree(playerid, treeid) ;
	}
	return 1;
}

