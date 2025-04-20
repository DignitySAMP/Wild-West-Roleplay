enum horseTypeData {
	h_td_id,

	h_td_name [ 32 ], 

	Float: h_td_speed,
	Float: h_td_stamina, 
	Float: h_td_health,

	h_color,

	h_level_requirement,
	h_donator,
	horse_enabled,
	h_price
};

new horseType [] [ horseTypeData ] = {
	{0, "Cleveland Bay", 			50.0, 	70.0, 	90.0,  0xFFFFFFFF, 1, 0, false, 999} ,
	{1, "Dutch Warmblood", 			65.0, 	80.0, 	100.0, 0xFF917959, 1, 0, true, 45} ,
	{2, "Highland Chestnut", 		65.0, 	80.0, 	90.0, 0xFFC9725F, 3, 0, true, 90} ,
	{3, "American Standardbred", 	75.0, 	90.0, 	100.0, 0xFF423625, 5, 0, true, 125} ,
	{4, "Kentucky Saddler", 		90.0, 	115.0, 	115.0, 0xFF696969, 6, 0, false, 999} ,
	{5, "Hungarian Half-bred", 		125.0, 	150.0, 	150.0, 0xFF111111, 1, 1, false, 999}
};

#define DONATOR_MOUNT_SLOT	99

#define HORSE_IDLE_INDEX 	( -25000 )
#define HORSE_GALLOP_INDEX 	( -25150 )
#define HORSE_SPRINT_INDEX 	( -25250 )
#define HORSE_WALK_INDEX 	( -25450 )
#define DONKEY_IDLE_INDEX 	( -25998 )
#define DONKEY_WALK_INDEX 	( -26000 )
#define DONKEY_SPRINT_INDEX ( -26050 )

enum {

	HORSE_ANIM_IDLE,
	HORSE_ANIM_WALK,
	HORSE_ANIM_GALLOP,
	HORSE_ANIM_SPRINT
} ;

new HorseIdleAnim [ ] [ MountAnimations ] = {
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/0.dff" }, 
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/1.dff" }, 	{ HORSE_ANIM_IDLE, "mounts/horses/idle/2.dff" }, 	{ HORSE_ANIM_IDLE, "mounts/horses/idle/3.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/4.dff" }, 	{ HORSE_ANIM_IDLE, "mounts/horses/idle/5.dff" }, 	{ HORSE_ANIM_IDLE, "mounts/horses/idle/6.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/7.dff" }, 	{ HORSE_ANIM_IDLE, "mounts/horses/idle/8.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/9.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/10.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/11.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/12.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/13.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/14.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/15.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/16.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/17.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/18.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/19.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/20.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/21.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/22.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/23.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/24.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/25.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/26.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/26.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/26.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/26.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/26.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/26.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/27.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/28.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/29.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/30.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/31.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/32.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/33.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/34.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/35.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/36.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/37.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/38.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/39.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/40.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/40.dff" },  { HORSE_ANIM_IDLE, "mounts/horses/idle/40.dff" },  { HORSE_ANIM_IDLE, "mounts/horses/idle/40.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/40.dff" },  { HORSE_ANIM_IDLE, "mounts/horses/idle/40.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/41.dff" },	
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/42.dff" }, 	{ HORSE_ANIM_IDLE, "mounts/horses/idle/43.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/44.dff" }, 
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/45.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/46.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/47.dff" }, 
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/48.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/49.dff" }, 	{ HORSE_ANIM_IDLE, "mounts/horses/idle/50.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/51.dff" }, 	{ HORSE_ANIM_IDLE, "mounts/horses/idle/52.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/53.dff" },
	{ HORSE_ANIM_IDLE, "mounts/horses/idle/54.dff" },	{ HORSE_ANIM_IDLE, "mounts/horses/idle/55.dff" }
} ;

new HorseWalkAnim [ ] [ MountAnimations ] = {

	{ HORSE_ANIM_WALK, "mounts/horses/walk/1.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/2.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/3.dff" }, 
	{ HORSE_ANIM_WALK, "mounts/horses/walk/4.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/5.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/7.dff" },
	{ HORSE_ANIM_WALK, "mounts/horses/walk/8.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/9.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/10.dff" },
	{ HORSE_ANIM_WALK, "mounts/horses/walk/11.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/12.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/13.dff" },
	{ HORSE_ANIM_WALK, "mounts/horses/walk/14.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/15.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/16.dff" },
	{ HORSE_ANIM_WALK, "mounts/horses/walk/17.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/18.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/19.dff" },
	{ HORSE_ANIM_WALK, "mounts/horses/walk/20.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/21.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/22.dff" },
	{ HORSE_ANIM_WALK, "mounts/horses/walk/23.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/24.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/25.dff" },
	{ HORSE_ANIM_WALK, "mounts/horses/walk/26.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/27.dff" }, { HORSE_ANIM_WALK, "mounts/horses/walk/28.dff" }, 
	{ HORSE_ANIM_WALK, "mounts/horses/walk/29.dff" }
} ;

new HorseGallopAnim [ ] [ MountAnimations ] = {

	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/1.dff" }, 	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/2.dff" }, 	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/3.dff" }, 
	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/4.dff" }, 	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/5.dff" }, 	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/6.dff" }, 
	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/7.dff" }, 	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/8.dff" }, 	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/9.dff" }, 
	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/10.dff" }, 	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/11.dff" }, 	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/12.dff" }, 
	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/13.dff" }, 	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/14.dff" }, 	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/15.dff" }, 
	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/16.dff" },	{ HORSE_ANIM_GALLOP, "mounts/horses/gallop/17.dff" }
} ;

new HorseSprintAnim [ ] [ MountAnimations ] = {

	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/1.dff" }, 	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/2.dff" }, 	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/3.dff" },
	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/4.dff" }, 	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/5.dff" }, 	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/6.dff" },
	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/7.dff" }, 	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/8.dff" }, 	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/9.dff" },
	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/10.dff" }, 	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/11.dff" }, 	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/12.dff" },
	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/13.dff" }, 	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/14.dff" }, 	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/15.dff" },
	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/16.dff" }, 	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/17.dff" }, 	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/18.dff" },
	{ HORSE_ANIM_SPRINT, "mounts/horses/sprint/19.dff" }
} ;

public OnGameModeInit()	{

	print(" * [HORSE ANIMS] Loading horse animations...");

	for ( new i = 0; i < sizeof ( HorseIdleAnim ); i ++ ) {

		AddSimpleModel(-1, 1923, HORSE_IDLE_INDEX + i, HorseIdleAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_a.txd");
		AddSimpleModel(-1, 1923, HORSE_IDLE_INDEX + ( sizeof(HorseIdleAnim) * 1 ) + i, HorseIdleAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_b.txd");
		AddSimpleModel(-1, 1923, HORSE_IDLE_INDEX + ( sizeof(HorseIdleAnim) * 2 ) + i, HorseIdleAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_c.txd");
		AddSimpleModel(-1, 1923, HORSE_IDLE_INDEX + ( sizeof(HorseIdleAnim) * 3 ) + i, HorseIdleAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_d.txd");
	}
	
	for ( new i = 1; i < sizeof ( HorseGallopAnim ); i ++ ) {
		AddSimpleModel(-1, 1923, HORSE_GALLOP_INDEX + i, HorseGallopAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_a.txd");
		AddSimpleModel(-1, 1923, HORSE_GALLOP_INDEX + ( sizeof(HorseGallopAnim) * 1 ) + i, HorseGallopAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_b.txd");
		AddSimpleModel(-1, 1923, HORSE_GALLOP_INDEX + ( sizeof(HorseGallopAnim) * 2 ) + i, HorseGallopAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_c.txd");
		AddSimpleModel(-1, 1923, HORSE_GALLOP_INDEX + ( sizeof(HorseGallopAnim) * 3 ) + i, HorseGallopAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_d.txd");
	}
	
	for ( new i = 1; i < sizeof ( HorseSprintAnim ); i ++ ) {
		AddSimpleModel(-1, 1923, HORSE_SPRINT_INDEX + i, HorseSprintAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_a.txd");
		AddSimpleModel(-1, 1923, HORSE_SPRINT_INDEX + ( sizeof(HorseSprintAnim) * 1 ) + i, HorseSprintAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_b.txd");
		AddSimpleModel(-1, 1923, HORSE_SPRINT_INDEX + ( sizeof(HorseSprintAnim) * 2 ) + i, HorseSprintAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_c.txd");
		AddSimpleModel(-1, 1923, HORSE_SPRINT_INDEX + ( sizeof(HorseSprintAnim) * 3 ) + i, HorseSprintAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_d.txd");
	}
	
	for ( new i = 1; i < sizeof ( HorseWalkAnim ); i ++ ) {
		AddSimpleModel(-1, 1923, HORSE_WALK_INDEX + i, HorseWalkAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_a.txd");
		AddSimpleModel(-1, 1923, HORSE_WALK_INDEX + ( sizeof(HorseWalkAnim) * 1 ) + i, HorseWalkAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_b.txd");
		AddSimpleModel(-1, 1923, HORSE_WALK_INDEX + ( sizeof(HorseWalkAnim) * 2 ) + i, HorseWalkAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_c.txd");
		AddSimpleModel(-1, 1923, HORSE_WALK_INDEX + ( sizeof(HorseWalkAnim) * 3 ) + i, HorseWalkAnim [ i ] [ mount_anim_txd ], "mounts/horses/horse_txd_d.txd");
	}

	print(" * [HORSE ANIMS] Loaded horse animations!");

	#if defined hanim_OnGameModeInit
		return hanim_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif

#define OnGameModeInit hanim_OnGameModeInit
#if defined hanim_OnGameModeInit
	forward hanim_OnGameModeInit();
#endif

new PlayerHorseAnimationIncrement [ MAX_PLAYERS ] ;
FetchHorseAnimations ( playerid, k, ud, lr ) {
	if ( ud != KEY_UP && ud != KEY_DOWN && lr != KEY_LEFT && lr != KEY_RIGHT) { // Idle

		if ( PlayerHorseAnimationIncrement [ playerid ] >= sizeof ( HorseIdleAnim ) || PlayerHorseAnimationIncrement [ playerid ] <= 0  ) {

			PlayerHorseAnimationIncrement [ playerid ] = 0 ;
		}

		new modelid = HORSE_IDLE_INDEX + ( sizeof(HorseIdleAnim) * PlayerSpawnedHorse [ playerid ] ) + PlayerHorseAnimationIncrement [ playerid ] ++ ;
		SetPlayerAttachedObject(playerid, ATTACH_SLOT_HORSE, modelid, 1, -0.480000,0.447999,-0.017999,-92.400009,13.200000,1.000000,1,1.000000,1.0);

		defer EnableHorseAnimation[75](playerid);
		
		return true ;
	}

	if ( k & KEY_JUMP ) {

		if ( ud == KEY_UP || ud == KEY_DOWN || lr == KEY_LEFT || lr == KEY_RIGHT) { // Gallop

			if ( PlayerHorseAnimationIncrement [ playerid ] >= sizeof ( HorseGallopAnim ) || PlayerHorseAnimationIncrement [ playerid ] <= 0  ) {

				PlayerHorseAnimationIncrement [ playerid ] = 1 ;
			}
			
			new modelid = HORSE_GALLOP_INDEX + ( sizeof(HorseGallopAnim) * PlayerSpawnedHorse [ playerid ] ) + PlayerHorseAnimationIncrement [ playerid ] ++ ;
			SetPlayerAttachedObject(playerid, ATTACH_SLOT_HORSE, modelid, 1, -0.441000,0.323999,0.000000,-91.499946,16.799995,0.000000,1.000000,1.000000,1.000000);

			defer EnableHorseAnimation[50](playerid);
			return true ;
		}
	}

	if ( k & KEY_WALK ) {

		if ( ud == KEY_UP || ud == KEY_DOWN || lr == KEY_LEFT || lr == KEY_RIGHT) { // Walk

			if ( PlayerHorseAnimationIncrement [ playerid ] >= sizeof ( HorseWalkAnim ) || PlayerHorseAnimationIncrement [ playerid ] <= 0  ) {

				PlayerHorseAnimationIncrement [ playerid ] = 1 ;
			}
			
			new modelid = HORSE_WALK_INDEX + ( sizeof(HorseWalkAnim) * PlayerSpawnedHorse [ playerid ] ) + PlayerHorseAnimationIncrement [ playerid ] ++ ;
			SetPlayerAttachedObject(playerid, ATTACH_SLOT_HORSE, modelid, 1, -0.441000,0.323999,0.000000,-91.499946,16.799995,0.000000,1.000000,1.000000,1.000000);
	
			defer EnableHorseAnimation[50](playerid);
			return true ;
		}
	}
	
	else {

		if ( ud == KEY_UP || ud == KEY_DOWN || lr == KEY_LEFT || lr == KEY_RIGHT) { // Sprint
			if ( PlayerHorseAnimationIncrement [ playerid ] >= sizeof ( HorseSprintAnim ) || PlayerHorseAnimationIncrement [ playerid ] <= 0  ) {

				PlayerHorseAnimationIncrement [ playerid ] = 1 ;
			}

			new modelid = HORSE_SPRINT_INDEX + ( sizeof(HorseSprintAnim) * PlayerSpawnedHorse [ playerid ] ) + PlayerHorseAnimationIncrement [ playerid ] ++ ;
			SetPlayerAttachedObject(playerid, ATTACH_SLOT_HORSE, modelid, 1, -0.479000,0.273000,0.000000,-179.600082,-2.499999,19.500005,1.000000,1.000000,1.000000);
		}

		defer EnableHorseAnimation[50](playerid);
		return true ;
	}

	return true ;
}