GetHolsterSkill ( playerid ) {

	new delay = 3000;

	switch ( PlayerSkill [ playerid ] [ GUN_holster ] ) {

		case 0: delay = 3000 ;
		case 1: delay = 2000 ;
		case 2: delay = 1000 ;
	}

	return delay ;
}

GetPlayerGunSkill ( playerid ) {
	
	new drunklevel ;

	SetPlayerSkillLevel ( playerid, 	WEAPONSKILL_DESERT_EAGLE, 		1 ) ;
	SetPlayerSkillLevel ( playerid, 	WEAPONSKILL_SHOTGUN, 			1 ) ;
	SetPlayerSkillLevel ( playerid, 	WEAPONSKILL_SNIPERRIFLE, 		1 ) ;
	SetPlayerSkillLevel ( playerid,		WEAPONSKILL_SAWNOFF_SHOTGUN, 	1 ) ;

	switch ( PlayerSkill [ playerid ] [ GUN_movement ] ) {
		
		case 1: { SetPlayerSkillLevel(playerid,WEAPONSKILL_DESERT_EAGLE,200); }
		case 2: {

			SetPlayerSkillLevel(playerid,WEAPONSKILL_DESERT_EAGLE,400);
			SetPlayerSkillLevel(playerid,WEAPONSKILL_SHOTGUN,200);
		}
		case 3: {

			SetPlayerSkillLevel(playerid,WEAPONSKILL_DESERT_EAGLE,600);
			SetPlayerSkillLevel(playerid,WEAPONSKILL_SHOTGUN,400);
			SetPlayerSkillLevel(playerid,WEAPONSKILL_SAWNOFF_SHOTGUN,200);
		}
		case 4: {

			SetPlayerSkillLevel(playerid,WEAPONSKILL_DESERT_EAGLE,800);
			SetPlayerSkillLevel(playerid,WEAPONSKILL_SHOTGUN,600);
			SetPlayerSkillLevel(playerid,WEAPONSKILL_SAWNOFF_SHOTGUN,400);
			SetPlayerSkillLevel(playerid,WEAPONSKILL_SNIPERRIFLE,200);
		}
		case 5: {

			SetPlayerSkillLevel(playerid,WEAPONSKILL_DESERT_EAGLE,800);
			SetPlayerSkillLevel(playerid,WEAPONSKILL_SHOTGUN,800);
			SetPlayerSkillLevel(playerid,WEAPONSKILL_SAWNOFF_SHOTGUN,600);
			SetPlayerSkillLevel(playerid,WEAPONSKILL_SNIPERRIFLE,400);
		}
		case 6: {

			SetPlayerSkillLevel(playerid,WEAPONSKILL_DESERT_EAGLE,1000);
			SetPlayerSkillLevel(playerid,WEAPONSKILL_SHOTGUN,1000);
			SetPlayerSkillLevel(playerid,WEAPONSKILL_SAWNOFF_SHOTGUN,800);
			SetPlayerSkillLevel(playerid,WEAPONSKILL_SNIPERRIFLE,600);
		}
	}

	switch ( PlayerSkill [ playerid ] [ GUN_aiming ] ) {
		
		case 0: { 

			drunklevel = 3000 ; //4500
		}
		case 1: { 

			if(GetPlayerWeapon(playerid) == WEAPON_DEAGLE || GetPlayerWeapon(playerid) == WEAPON_SAWEDOFF) { drunklevel = 1500; }
			else if(GetPlayerWeapon(playerid) == WEAPON_SHOTGUN) { drunklevel = 2000; }
			else { drunklevel = 2500 ; } //4000
		}
		case 2: { 

			if(GetPlayerWeapon(playerid) == WEAPON_DEAGLE || GetPlayerWeapon(playerid) == WEAPON_SAWEDOFF) { drunklevel = 0; }
			else if(GetPlayerWeapon(playerid) == WEAPON_SHOTGUN) { drunklevel = 1000; }
			else { drunklevel = 2000 ; } //3500
		}
		case 3:	{ 

			if(GetPlayerWeapon(playerid) == WEAPON_DEAGLE || GetPlayerWeapon(playerid) == WEAPON_SAWEDOFF) { drunklevel = 0; }
			else if(GetPlayerWeapon(playerid) == WEAPON_SHOTGUN) { drunklevel = 0; }
			else { drunklevel = 1000 ; } //3000
		}
		case 4: { 

			drunklevel = 0 ; //2500
		}
		case 5: { 

			drunklevel = 0 ; //2100
		}
		case 6: { 

			drunklevel = 0 ; 
		}
	}
	
	return drunklevel ;
}