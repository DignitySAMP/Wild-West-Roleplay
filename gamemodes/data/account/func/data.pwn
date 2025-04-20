ClearData ( playerid ) {

	printf("Cleared account data for player %d: %s", playerid, ReturnUserName ( playerid, false ) ) ;

 	//Streamer_VisibleItems(STREAMER_TYPE_OBJECT, 1250, playerid);
 	//Streamer_SetRadiusMultiplier(STREAMER_TYPE_OBJECT, 1.75, playerid);

	LoadCharacterSelectDraws ( playerid ) ;
	LoadCreationTextDraws ( playerid ) ;

	CancelBloodPuddle ( playerid ) ;

	new acc_clear[PlayerData] ;
	Account [ playerid ] = acc_clear ;

	new char_clear[CharacterData] ;
	Character [ playerid ] = char_clear ;

	for ( new i; i < MAX_CHARACTERS; i ++ ) {
		CharBuffer [ playerid ] [ i ] = char_clear ;
	}

	new skill_clear[ sizeof ( SkillData ) ] ;
	PlayerSkill [ playerid ] = skill_clear ;

	new wounds_clear [ WoundData ] ;
	PlayerWounds [ playerid ] = wounds_clear ;

	SetDynamicObjectPos ( HorseObject [ playerid ], 0.0, 0.0, 0.0 ) ;
	SetDynamicObjectPos ( CowObject [ playerid ], 0.0, 0.0, 0.0 ) ;

	new horse_clear [ HorseData ] ;
	PlayerHorse [ playerid ] = horse_clear ;

	PlayerTimeoutTick [ playerid ] = false ;
	IsPlayerLogged [ playerid ] = false  ; 
	IsPlayerInAdminJail [ playerid ] = false ;
	IsPlayerRidingHorse [ playerid ] = false ;
	IsPlayerInAdminJail [ playerid ] = false ;
	IsPlayerMasked [ playerid ] = false ;
	IsPlayerFading [ playerid ] = false ;
	IsPlayerSpectating [ playerid ] = INVALID_PLAYER_ID ;

	login_state [ playerid ] = false ;
	login_state_ext [ playerid ] = 0 ;
	
	//LogoutPermission [ playerid ] = false ; 
	NewlyRegistered [ playerid ] = false ; 
	Login_SelectionPage [ playerid ] = false ; 


	IsPlayerCreatingCharacter [ playerid ] = 0 ;

	player_GenderSelection [ playerid ] = 0 ;
	player_RaceSelection [ playerid ] = 0 ;
	player_TownSelection [ playerid ] = 0 ;
	player_SkinSelection [ playerid ] = 0 ;
	player_AgeSelection [ playerid ] = 0 ;

	player_ACTick_Money 		[ playerid ] = 0 ; 
	player_ACTick_Weapon 		[ playerid ] = 0 ; 
	player_ACTick_Ammo 			[ playerid ] = 0 ;
	player_ACTick_Fly 			[ playerid ] = 0 ;
	player_ACTick_Speed 		[ playerid ] = 0 ;
	player_ACTick_AimbotIncr 	[ playerid ] = 0 ;

	player_AC_Pos_X 			[ playerid ] = 0 ;
	player_AC_Pos_Y 			[ playerid ] = 0 ;
	player_AC_Pos_Z 			[ playerid ] = 0 ;

	PlayerReportCooldown [ playerid ] = false ;
	PlayerHasPendingReport [ playerid ] = false ;
	PlayerHasPendingQuestion [ playerid ] = false ;
	PlayerQuestionCooldown [ playerid ]= false ;

	HasPlayerMutedSupporterChat[playerid] = 0;
	HasPlayerMutedModeratorChat[playerid] = 0;

	IsPlayerOnAdminDuty [ playerid ] = false ;

	map_gangZonesLoaded [ playerid ] = false ;
	gPlayerUsingLoopingAnim [ playerid ] = false ;
	gPlayerAnimLibsPreloaded [ playerid ] = false ;

	PlayerInjuredCooldown [ playerid ] = 0 ;
	Player_ClientDeath [ playerid ] = false ;
	PlayerDamage [ playerid ] [ 0 ] = false ;
	PlayerDamage [ playerid ] [ 1 ] = false ;
	player_damaged_leg[ playerid ] = false ;
	antiReFall [ playerid ] = false ;

	FriskingPlayer [ playerid ] = INVALID_PLAYER_ID ;
	ScreenStatus [ playerid ] = 0 ;

	PlayerShakeOffer [ playerid ] = INVALID_PLAYER_ID ;
	PlayerShakeType [ playerid ] = 0 ;

	// Inv equipped
	EquippedItem [ playerid ] = -1 ;
	EquippedItemTile [ playerid ] = -1;

	// Quiz
	quiz_SelectionList [ playerid ] = -1 ;
	quiz_CurrentQuestion [ playerid ] = -1 ;
	quiz_WrongAnswers [ playerid ] = 0 ;

	// Jobs:
	IsMining[playerid] = false;
	MiningProgress[playerid] = 0;
	if ( IsValidDynamicArea(  player_MineCircle [ playerid ] )) {
		DestroyDynamicArea ( player_MineCircle [ playerid ] ) ;
	}

	player_DobberPoint [ playerid ] = 0 ;
	FishingProgress [ playerid ] = 0 ;
	IsFishing [ playerid ] = false ; 

	if ( IsValidDynamicArea(player_FishCircle [ playerid ])) {
		DestroyDynamicArea ( player_FishCircle [ playerid ] ) ;
	}

	if ( IsValidDynamicObject (  player_RopeLine [ playerid ] )) {
		DestroyDynamicObject ( player_RopeLine [ playerid ] ) ;
	}

	IsCuttingTree[playerid] = false; 
	CuttingProgress[playerid] = 0;

	if ( IsValidDynamicArea(player_TreeCircle [ playerid ])) {
		DestroyDynamicArea ( player_TreeCircle [ playerid ] ) ;
	}

	playerSwimmingTick 		[ playerid ] = 0;
 	playerWarningTick 		[ playerid ] = 0;
	playerSprintWarningTick [ playerid ] = 0;

	PlayerAdminconvo [ playerid ]		= -1 ;
	IsPlayerBandaging [ playerid ] 		= 0 ;

	//TutorialProgress [ playerid ] = 0 ;
	DoingTask [ playerid ] = -1 ;
	TaskCheckpoint [ playerid ] = -1 ;

	//Sheriff Duty
	sheriffDuty [ playerid ] = false;

	//Bounty
	new name [ MAX_PLAYER_NAME ] = EOS ;
	player_BountyKill [ playerid ] = -1, CarryingBountyCorpse [ playerid ] = false , PosterName [ playerid ] = name ;

	//Lottery
	SetLotteryWinner ( playerid, false ) ;

	//Namechange
	PlayerNameChangeRequest [ playerid ] = 0;
	PlayerNameChangeName [ playerid ] = name ;

	//Charges
	ChargeCount [ playerid ] = 0;

	//Telegrams
	TelegramCount [ playerid ] = 0;

	//point sleep
	IsPlayerSleepingInPoint [ playerid ] = false ;

	//afk
	AFKVariable [ playerid ] = 0 ;
	HasPlayerUsedAFKCommand[playerid] = false;

	foreach(new i: Player)  {

		if ( PlayerAdminconvo [ i ] == playerid ) {

			PlayerAdminconvo [ i ] = -1 ;
			SendServerMessage ( i, "The host of your admin conversation has disconnected. You have been removed from the conversation.", MSG_TYPE_WARN ) ;
		}

		else continue ;
	}

	IsPlayerHidingOOC [ playerid ] = false ;
	IsPlayerOnAdminDuty [ playerid ] = false ;
	IsPlayerOOC [ playerid ] = false ;
	PlayerModPMWarning [ playerid ] = false ;
	ToggleHorseSound [ playerid ] = true ;

	if ( IsValidDynamicCP(PlayerMountHorseCP [ playerid ] [ 0 ])) {

		DestroyDynamicCP(PlayerMountHorseCP [ playerid ] [ 0 ]);
	}	

	if ( IsValidDynamicCP(PlayerMountHorseCP [ playerid ] [ 1 ])) {

		DestroyDynamicCP(PlayerMountHorseCP [ playerid ] [ 1 ]);
	}

	LastPaycheckGiven [ playerid ] = gettime () + 900 ;
	ReturnPlayerItemCount [ playerid ] = 0 ;

	PlayerHelpUpCooldown [ playerid ] = 0;
	PlayerRecentlyRevived [ playerid ] = 0;

	AC_LevelMitigation [ playerid ] = 0 ;
	AC_AntiKnifeTrigger[playerid] = 0;
	IsPlayerTackled [ playerid ] = false ;


	PlayerGunProgress [ playerid ] = 0 ;
	PlayerGunOre [ playerid ] = 0 ;
	PlayerGunSecondaryOre [ playerid ] = 0 ;

	PlayerCraftingGunComponant [ playerid ] = 0 ;
	
	CharacterPointID[playerid] = -1 ;

	PlayerSaddleBagWeapon [ playerid ] [ 0 ] = 0 ;
	PlayerSaddleBagAmmo [ playerid ] [ 0 ] = 0 ;
	PlayerSaddleBagWeapon [ playerid ] [ 1 ] = 0 ;
	PlayerSaddleBagAmmo [ playerid ] [ 1 ] = 0 ;

	DidPlayerDieFromPlayer[playerid] = INVALID_PLAYER_ID;

	return cmd_fixjob ( playerid ) ;
}