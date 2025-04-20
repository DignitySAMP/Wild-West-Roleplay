/*
-> for character sheet:

Hunting aka skinning (increases loot, also rare skin)
Leatherworking (makes the skin craftable. Can create layers for holsters, bags, rare attachments?)

////////////////////////////////////
LEATHERWORKING/HUNTING:
lvl 1 bag: starter
lvl 2 bag: purchasable in general store (800-900 usd)
lvl 3 bag: 
-> need rope from general store
get 3x rare deer skin (need at least hunting lvl 7/10)
be able to craft rare deer skin (need at least leatherworking 3/5)
be able to mine some rare ore (at least mining 7/10)
and be able to craft and smelt the rare ore (at least lvl 3/5 blacksmithing)
[NOTE: make the rare items per-player, aka not sellable, not tradeable]
--> for this: add a new variable, aka (soulbound) for items
////////////////////////////////////

: If doing a job, put a money bag on players back, retextured with sack texture and money texture to job related 
(logs, rocks, plants, meat(. Save in a var incase crashes. Disallow new jobs when carrying bag (they need to deliver first).

Mining (diff ores, can get rare ore)
Blacksmithing (depending on lvl needs rare ore to be able to smelt into gun-metal and make guns)

////////////////////////////////////
MINING/BLACKSMITHING RARES:
> need rare ore (8/10 mining)
> need ability to smelt it (4/5 bs)
> need gunpowder from hunting store (250 usd)
-> ADD SCOPE TO RIFLE, TO MAKE NSIPER RIFLE

////////////////////////////////////

Woodcutting (add different log types depending on skill)
Woodworking (diff crafting methods based on skill)

////////////////////////////////////
WOODCUTTING/WOODWORKING RARES:
Cosmetic satan mask
-> need rope from general store
-> need rare wood (woodcutting 5/10)
-> need to be able to craft it (woodworking 2/5)
////////////////////////////////////

Farming: (depending on lvl, more crops harvested)
Cooking: (less chance to burn food)

Weapon level (reduces shake)
Movement level (hitman skill)

Melee level (diff fight style, more melee dmg/less dmg taken)
Blocking level (increased block chance, less dmg taken)

--> farmer (seed bag on front)
--> miner (coal bag on back)
--> lumberjack (wooden rack on back)




// To use skill sets, you must be at least level 2.
// The higher the level, the more skill points it costs.
enum { // SKILL TREE
	GUN_SKILL_MOVEMENT, // lvl 1: allows you to move (lvl 1: hitman gun level) --> REQUIRES AIM TO BE LVL 2.
	GUN_SKILL_AIM, // reduces weapon sway (1: 1: reduced sway (3500), 2: small sway, goes away after aiming for a sec: 2500, 3: no sway at all.)
	// [THIS IS THE QUICKSWITCH SKILL]: lvl 0: 3000ms (un)holster time
	GUN_SKILL_HOLSTER,  // reduces (un)holster time. (lvl 1: 2000 ms), lvl 2: 1000ms, lvl 3: 500ms

	// lvl 0 only allows oak. base log = 1 + random modifier (3).
	JOB_SKILL_WOODCUTTING, // lvl 1: birch, lvl2: 3 base logs lvl 3: yew, lvl 4: 5 base logs (logs have a random modifier of 3 + base logs)
	// (oak logs: 25 ea, birch: 50ea, yew: 60ea -- increased by quanity, random quanity on log loot.)

	JOB_SKILL_FISHING, // 1: increased weight on fish, (2: ability to fish trout), 3: ability to fish sharks
	JOB_SKILL_MINING, // 1: increased quanity of ore, (2: ability to mine copper & tin), 3: ability to mine coal & gold.
	JOB_SKILL_HUNTING, // 1: ability to see tracks, 2: ability to see tracks from a distance, 3: ability to loot deer head: (sells for 150 each (2 out of 10 chance))
	JOB_SKILL_FARMING, 

	// lvl 0 fishing lets you swim for max. 30 seconds before passing out. they get a warning msg.
	MISC_SKILL_SWIMMING, // 1: no swim limit, no sprint. 2: ability to use sprint
	MISC_SKILL_HEALTH, // 1: more resilient against melee attacks. 2: increased bleed-out time, 3: reduced death timer.

	// for melee, if they're not aiming at a player, disable punching completely.
	MELEE_SKILL_STYLE, // 1: boxing, 2: kungfu
	MELEE_SKILL_UNARMED, // 1: more punch dmg, 2: unlock kicking, 3: reduced melee dmg, 4: unlock tackling
	MELEE_SKILL_KNIFE, // 1: more dmg with knife, 2: ability to block most melee attacks
	MELEE_SKILL_KNIFE_THROW
} ;
*/

enum  {

	GUN_movement,
	GUN_aiming,
	GUN_holster,

	JOB_fishing,
	JOB_lumber,
	JOB_mining,
	JOB_hunting,
	JOB_farming,
	JOB_blacksmith,

	MISC_swimming,
	MISC_health,

	MELEE_style,
	MELEE_unarmed,
	MELEE_knife,
	MELEE_knife_throw

} ;

enum SkillDataInfo {
	skill_name [ 32 ],
	skill_maxpts,
	skill_constant,
	skill_row [ 32 ]
} ;

new SkillData [ ] [ SkillDataInfo ] = {

	{ "Weapon Movement", 		6,		GUN_movement,		"GUN_movement" 	}, 
	{ "Weapon Aiming", 			4,		GUN_aiming,			"GUN_aiming" 	}, 
	{ "Weapon Holstering", 		3,		GUN_holster,		"GUN_holster" 	}, 
	
	{ "Fishing", 				2,		JOB_fishing,		"JOB_fishing" 	}, 	
	{ "Woodcutting", 			3,		JOB_lumber,			"JOB_lumber" 	}, 	
	{ "Mining", 				3,		JOB_mining,			"JOB_mining" 	}, 	
	{ "Hunting", 				0,		JOB_hunting,		"JOB_hunting" 	}, 
	{ "Farming", 				0,		JOB_farming,		"JOB_farming" 	},
	{ "Blacksmith",				6,		JOB_blacksmith,		"JOB_blacksmith" }, 
	
	{ "Swimming", 				2,		MISC_swimming,		"MISC_swimming" }, 
	{ "Health", 				0,		MISC_health,		"MISC_health" 	}, 
	
	{ "Fight Style", 			1,		MELEE_style,		"MELEE_style" 	}, 
	{ "Unarmed", 				0,		MELEE_unarmed,		"MELEE_unarmed" }, 
	{ "Knife",		 			0,		MELEE_knife,		"MELEE_knife" 	}, 
	{ "Knife Throwing", 		1,		MELEE_knife_throw,	"MELEE_knife_throw" }
} ;

new PlayerSkill [ MAX_PLAYERS ] [ sizeof ( SkillData ) ] ;

#include "data/skills/func/data.pwn"
#include "data/skills/func/swimming.pwn"
#include "data/skills/func/weapon.pwn"

CMD:skills(playerid, params [] ){

	if ( ! strcmp ( params, "show" ) ) {

		return ShowPlayerSkills ( playerid ) ;
	}

	else if ( ! strcmp(params, "reset" ) ) {

		ResetPlayerSkillPoints ( playerid ) ;
	}	

	else SendServerMessage ( playerid, "/skills [show/reset]", MSG_TYPE_ERROR ) ;

	return true ;
}

ShowPlayerSkills ( playerid ) {

	SendClientMessage(playerid, COLOR_YELLOW, sprintf("Here you can see your current skills. [Skillpoints left for use: %d]", Character [ playerid ] [ character_skillpoints ] ));

	SendClientMessage(playerid, -1, 
		sprintf("{917E5E}[WEAPON]{dedede} Weapon Movement: %d/%d - Weapon Aiming: %d/%d - Weapon Holstering: %d/%d", PlayerSkill [ playerid ] [ GUN_movement ], SkillData [ GUN_movement ] [ skill_maxpts ], PlayerSkill [ playerid ] [ GUN_aiming ], SkillData [ GUN_aiming ] [ skill_maxpts ], PlayerSkill [ playerid ] [ GUN_holster ], SkillData [ GUN_holster ] [ skill_maxpts ] )) ;
	SendClientMessage(playerid, -1, 
		sprintf("{77915E}[JOBS]{dedede} Fishing: %d/%d - Woodcutting: %d/%d - Mining: %d/%d - Hunting: %d/%d -  Farming: %d/%d\n", PlayerSkill [ playerid ] [ JOB_fishing ], 	SkillData [ JOB_fishing ] [ skill_maxpts ],PlayerSkill [ playerid ] [ JOB_lumber ], SkillData [ JOB_lumber ] [ skill_maxpts ], PlayerSkill [ playerid ] [ JOB_mining ], SkillData [ JOB_mining ] [ skill_maxpts ], PlayerSkill [ playerid ] [ JOB_hunting ], SkillData [ JOB_hunting ] [ skill_maxpts ], PlayerSkill [ playerid ] [ JOB_farming], SkillData [ JOB_farming ] [ skill_maxpts ] )) ;
	SendClientMessage(playerid, -1, 
		sprintf("{77915E}[JOBS]{dedede} Blacksmith %d/%d", PlayerSkill [ playerid ] [ JOB_blacksmith ], SkillData [ JOB_blacksmith ] [ skill_maxpts ] ) ) ;
	SendClientMessage(playerid, -1, 
		sprintf("{5E93A8}[MELEE]{dedede} Fight Style: %d/%d - Unarmed: %d/%d - Knife: %d/%d - Knife Throwing: %d/%d\n", PlayerSkill [ playerid ] [ MELEE_style ], SkillData [ MELEE_style ] [ skill_maxpts ],PlayerSkill [ playerid ] [ MELEE_unarmed ], SkillData [ MELEE_unarmed ] [ skill_maxpts ], PlayerSkill [ playerid ] [ MELEE_knife ], SkillData [ MELEE_knife ] [ skill_maxpts ], PlayerSkill [ playerid ] [ MELEE_knife_throw ], SkillData [ MELEE_knife_throw ] [ skill_maxpts ] )) ;
	SendClientMessage(playerid, -1, 
		sprintf("{B0B0B0}[MISC]{dedede} Swimming: %d/%d - Health: %d/%d", PlayerSkill [ playerid ] [ MISC_swimming ], SkillData [ MISC_swimming ] [ skill_maxpts ],  PlayerSkill [ playerid ] [ MISC_health ], SkillData [ MISC_health ] [ skill_maxpts ] )) ;

	return true ;
}

ResetPlayerSkillPoints ( playerid ) {

	if ( Character [ playerid ] [ character_skillpoints ] != 0 ) {

		return SendServerMessage ( playerid, "You need to spend all your skillpoints before refunding them.", MSG_TYPE_ERROR ) ;
	}

	new query [ 256 ] ;

	for ( new i; i < sizeof ( SkillData ); i ++ ) {

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE character_skills SET %s = 0 WHERE character_id = '%d'", SkillData [ i ] [ skill_row ], Character [ playerid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ); 

		PlayerSkill [ playerid ] [ i ] = 0 ;
	}

	Character [ playerid ] [ character_skillpoints ] = Character [ playerid ] [ character_level ] ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_skillpoints = %d WHERE character_id = '%d'",  Character [ playerid ] [ character_skillpoints ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query );

	SendServerMessage ( playerid, sprintf("You've been refunded %d skillpoints. All your skills have been reset.", Character [ playerid ] [ character_level ] ), MSG_TYPE_WARN ) ;

	return true ;
}

CMD:levelup ( playerid, params [] ) {

	new option [ 32 ] ;

	if ( sscanf ( params, "s[32]", option ) ) {

		return SendServerMessage ( playerid, "/levelup [option]", MSG_TYPE_ERROR ) ;
	}

	for ( new i; i < sizeof ( SkillData ); i ++ ) {

		if ( ! strcmp ( option, SkillData [ i ] [ skill_name ], true ) ) {

			LevelUpSkill ( playerid, i ) ;

			return true ;
		}

		else continue ;
	}

	return true ;
}

LevelUpSkill ( playerid, skillid ) {

	if ( Character [ playerid ] [ character_skillpoints ] <= 0 ) {

		return SendServerMessage ( playerid, "You have no skillpoints. You need at least one to level up a skill.", MSG_TYPE_ERROR ) ;
	}

	if ( PlayerSkill [ playerid ] [ skillid ] >= SkillData [ skillid ] [ skill_maxpts ] ) {

		return SendServerMessage ( playerid, "You are already at the max level of this skill. Level up a different skill.", MSG_TYPE_ERROR ) ;
	}

	new required;

	if ( ! PlayerSkill [ playerid ] [ skillid ] ) {

		required = 1;
	}

	else {

		required = PlayerSkill [ playerid ] [ skillid ] * 2 ;
	}

	if ( required > Character [ playerid ] [ character_skillpoints ] ) {

		return SendServerMessage ( playerid, sprintf("You don't have enough skillpoints! You need %i more skill point%s to level up your %s skill.", ( required - Character [ playerid ] [ character_skillpoints ] ), ( required == 1 ) ? ("") : ("s"), SkillData [ skillid ] [ skill_name ] ), MSG_TYPE_ERROR ) ;
	}

	new query [ 256 ] ;

	Character [ playerid ] [ character_skillpoints ] -= required ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_skillpoints = '%d' WHERE character_id = '%d'", Character [ playerid ] [ character_skillpoints ], Character [ playerid ] [ character_id ] ) ; 
	mysql_tquery ( mysql, query );

	PlayerSkill [ playerid ] [ skillid ] ++ ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE character_skills SET %s = '%d' WHERE character_id = '%d'", SkillData [ skillid ] [ skill_row ], PlayerSkill [ playerid ] [ skillid ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query );

	SendServerMessage ( playerid, sprintf("Advanced your %s skill. It's now %d/%d. You have %d skillpoints left.", SkillData [ skillid ] [ skill_name ], PlayerSkill [ playerid ] [ skillid ], SkillData [ skillid ] [ skill_maxpts ], Character [ playerid ] [ character_skillpoints ] ), MSG_TYPE_ERROR ) ;

	return true ;
}
