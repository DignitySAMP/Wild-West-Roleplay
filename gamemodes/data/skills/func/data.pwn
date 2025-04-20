LoadPlayerSkills ( playerid ) {

	new query [ 128 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM character_skills WHERE character_id = '%d'", Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query, "ProcessPlayerSkills", "i", playerid ) ;

	return true ;
}

forward ProcessPlayerSkills ( playerid ) ;
public ProcessPlayerSkills ( playerid ) {

	new rows, fields, query [ 256 ] ;
	cache_get_data ( rows, fields, mysql ) ;

	if ( rows ) {

		PlayerSkill [ playerid ] [ GUN_movement ] 		= cache_get_field_int ( 0, "GUN_movement" ) ;
		PlayerSkill [ playerid ] [ GUN_aiming ] 		= cache_get_field_int ( 0, "GUN_aiming" ) ;
		PlayerSkill [ playerid ] [ GUN_holster ] 		= cache_get_field_int ( 0, "GUN_holster" ) ;
	
		PlayerSkill [ playerid ] [ JOB_fishing ] 		= cache_get_field_int ( 0, "JOB_fishing" ) ;
		PlayerSkill [ playerid ] [ JOB_lumber ] 		= cache_get_field_int ( 0, "JOB_lumber" ) ;
		PlayerSkill [ playerid ] [ JOB_mining ] 		= cache_get_field_int ( 0, "JOB_mining" ) ;
		PlayerSkill [ playerid ] [ JOB_hunting ] 		= cache_get_field_int ( 0, "JOB_hunting" ) ;
		PlayerSkill [ playerid ] [ JOB_farming ] 		= cache_get_field_int ( 0, "JOB_farming" ) ;
		PlayerSkill [ playerid ] [ JOB_blacksmith ]		= cache_get_field_int ( 0, "JOB_blacksmith" ) ;
	
		PlayerSkill [ playerid ] [ MISC_swimming ]		= cache_get_field_int ( 0, "MISC_swimming" ) ;
		PlayerSkill [ playerid ] [ MISC_health ] 		= cache_get_field_int ( 0, "MISC_health" ) ;
	
		PlayerSkill [ playerid ] [ MELEE_style ] 		= cache_get_field_int ( 0, "MELEE_style" ) ;

		if ( PlayerSkill [ playerid ] [ MELEE_style ] ) {
			SetPlayerFightingStyle ( playerid, FIGHT_STYLE_BOXING ) ;
		}

		PlayerSkill [ playerid ] [ MELEE_unarmed ] 		= cache_get_field_int ( 0, "MELEE_unarmed" ) ;
		PlayerSkill [ playerid ] [ MELEE_knife ] 		= cache_get_field_int ( 0, "MELEE_knife" ) ;
		PlayerSkill [ playerid ] [ MELEE_knife_throw ] 	= cache_get_field_int ( 0, "MELEE_knife_throw" ) ;

		printf(" * [SKILLS] Loaded %s (%d)'s skill table.", ReturnUserName ( playerid, true ), playerid ) ;
	}

	else if ( ! rows ) {

		mysql_format ( mysql, query, sizeof ( query ), 
			"INSERT INTO character_skills (character_id) VALUES (%d)", Character [ playerid ] [ character_id ]  ) ;
		mysql_tquery ( mysql, query ) ;

		printf(" * [SKILLS] Player %s (%d) had no skill table. It has been created.", ReturnUserName ( playerid, true ), playerid ) ;
	}

	return true ;
}

