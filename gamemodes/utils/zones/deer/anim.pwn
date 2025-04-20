enum WildlifeAnimations {

	wildlife_anim_type,
	wildlife_anim_txd[256]
} ;


#define DEER_SPRINT_INDEX 	( -28000 )

enum {

	DEER_ANIM_WALK,
	DEER_ANIM_SPRINT
} ;


new DeerSprintAnim [ ] [ WildlifeAnimations ] = {

	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/1.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/2.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/3.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/4.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/5.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/6.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/7.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/8.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/9.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/10.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/11.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/12.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/13.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/14.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/15.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/16.dff" }, 
	{ DEER_ANIM_SPRINT, "wwrp/wildlife/deer/sprint/17.dff" }
} ;

public OnGameModeInit() {
	
	for ( new i = 1; i < sizeof ( DeerSprintAnim ); i ++ ) {
		AddSimpleModel(-1, 1923, DEER_SPRINT_INDEX + i, DeerSprintAnim [ i ] [ wildlife_anim_txd ], "wwrp/wildlife/deer/deer.txd");
	}

	#if defined wildanim_OnGameModeInit
		return wildanim_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif

#define OnGameModeInit wildanim_OnGameModeInit
#if defined wildanim_OnGameModeInit
	forward wildanim_OnGameModeInit();
#endif

