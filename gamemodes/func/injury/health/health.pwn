new PlayerInjuredCooldown [ MAX_PLAYERS ], DidPlayerDieFromPlayer[MAX_PLAYERS] ;

SetCharacterHealth ( playerid, Float: amount, issuerid = INVALID_PLAYER_ID ) {

	if ( Character [ playerid ] [ character_dmgmode ] ) {

		return false ;
	}

	new query [ 128 ] ;

	SetPlayerHealth ( playerid, 1000.0 ) ;
	Character [ playerid ] [ character_health ]  = amount ;

	if ( Character [ playerid ] [ character_health ] > 100.0 ) {

		Character [ playerid ] [ character_health ] = 100.0 ;
	}

	mysql_format(mysql, query, sizeof ( query ), "UPDATE characters SET character_health = '%f' WHERE character_id = '%d'", Character [ playerid ] [ character_health ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	UpdateGUI ( playerid ) ;

	if ( Character [ playerid ] [ character_health ] <= 0 ) {
		ToggleDeathMode ( playerid, issuerid ) ;
		IsPlayerBandaging [ playerid ] = 0 ;
	}

	query [ 0 ] = EOS ;

	if ( issuerid != INVALID_PLAYER_ID ) {

		WriteLog ( playerid, "health", sprintf("%s has been damaged by %s.  Amount: %f", ReturnUserName ( playerid, true), ReturnUserName ( issuerid, true ), amount ) ) ;
	}

	return true ;
}

timer AntiKnifeKillRelease[1000](playerid) {

	return TogglePlayerControllable(playerid, true);
}

new AC_AntiKnifeTrigger[MAX_PLAYERS];
public OnPlayerUpdate(playerid)
{
	if( GetPlayerAnimationIndex( playerid ) )
    {
        new
            animlib[ 32 ],
            animname[ 32 ]
        ;
        GetAnimationName( GetPlayerAnimationIndex( playerid ), animlib, 32, animname, 32 );
        if( !strcmp( animlib, "KNIFE", true ) && !strcmp( animname, "KILL_PARTIAL", true ) )
        {
            ClearAnimations( playerid, 1 );
            AC_AntiKnifeTrigger[playerid]++;
            if(AC_AntiKnifeTrigger[playerid] >= 3) {

            	TogglePlayerControllable(playerid,false);
            	SendServerMessage(playerid,"You're not allowed to perform stealth kills.",MSG_TYPE_ERROR);
            	AC_AntiKnifeTrigger[playerid] = 0;
            	defer AntiKnifeKillRelease(playerid);
            }
        }
    }
	#if defined health_OnPlayerUpdate
		return health_OnPlayerUpdate(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerUpdate
	#undef OnPlayerUpdate
#else
	#define _ALS_OnPlayerUpdate
#endif

#define OnPlayerUpdate health_OnPlayerUpdate
#if defined health_OnPlayerUpdate
	forward health_OnPlayerUpdate(playerid);
#endif

new AC_LevelMitigation [ MAX_PLAYERS ] ;
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart) {

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////// Initiates falling leg damage: /////////////////////////////////////////////////////////////// 
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	if ( weaponid == 0 ) {

		SetPlayerHealth ( playerid, 1000.0 ) ;
		return false ;
	}

	SetPlayerHealth ( playerid, 1000.0 ) ;
	CheckPlayerHackedWeapons ( issuerid, weaponid ) ;

	if ( IsPlayerOnAdminDuty [ playerid ] || IsPlayerOOC [ playerid ] || Character [ playerid ] [ character_dmgmode ] == 2 || Character [ playerid ] [ character_dmgmode ] == 3 ) {

		SetPlayerHealth ( playerid, 1000.0 ) ;
		return true ;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////// New OnPlayerDeath - injury mode: ///////////////////////////////////////////////////////////// 
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	if ( IsPlayerRidingHorse [ playerid ] && issuerid != INVALID_PLAYER_ID  || issuerid == playerid ) {

		SetPlayerHealth ( playerid, 1000.0 ) ;
		PlayerDamage [ playerid ] [ DAMAGE_LEGS ] = false ;

		PlayerHorse [ playerid ] [ HorseReloadTick ] = 201 ;

		return false ;
	}

    if ( IsPlayerFalling ( playerid ) && amount > 5.0 && ! IsPlayerRidingHorse [ playerid ] ) {

    	SendServerMessage ( playerid, "You have hurt your leg from falling. You will have trouble walking.", MSG_TYPE_WARN ) ;
    	DamageLegs ( playerid ) ;
    }

	SetPlayerHealth ( playerid, 1000.0 ) ;

	if ( playerid == INVALID_PLAYER_ID ) {

		SetPlayerHealth ( playerid, 1000 ) ;
		return true ;
	}

    if(issuerid != INVALID_PLAYER_ID) {

    	/*
    	if ( weaponid == WEAPON_KNIFE && amount == 1833.33154296875) { //issuerid is performing stealth kill with knife

			new int = GetPlayerInterior(issuerid),vw = GetPlayerVirtualWorld(issuerid);
			SetPlayerInterior(issuerid, 99);
			SetPlayerVirtualWorld(issuerid, 99);
			ClearAnimations(issuerid,1);
			ApplyAnimation(issuerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
			SendServerMessage(issuerid,"You're not allowed to perform stealth kills.",MSG_TYPE_ERROR);
			SetPlayerInterior(issuerid,int);
			SetPlayerVirtualWorld(issuerid,vw);
			return false;
		}
		*/

		SetPlayerHealth ( playerid, 1000 ) ;

		if ( Character [ issuerid ] [ character_level ] < 3 && weaponid != 0 ) {

			SendModeratorWarning ( sprintf("[HACKER] (%d) %s has used a weapon whilst being below lvl 3. (server: %d, client: %d) if server = 0 & client not, theyre hacking", issuerid, ReturnUserName ( issuerid, true ), Character [ issuerid ] [ character_handweapon], weaponid ), MOD_WARNING_HIGH );

			SendClientMessage(issuerid, COLOR_RED, "You can't use a weapon whilst not being level 3. Your weapons been reset and damage mitigated. For a refund, post this on the forums:" ) ;
			SendClientMessage(issuerid, COLOR_YELLOW, sprintf("[REFUND DATA]: gunid: %d (client: %d), ammo: %d (client: %d)", Character [ issuerid ] [ character_handweapon], GetPlayerWeapon ( issuerid ), Character [ issuerid ] [ character_handammo], GetPlayerAmmo ( issuerid ) ) ) ;

			WriteLog (issuerid, "refunddata", sprintf ( "%s refund data: [REFUND DATA]: gunid: %d (client: %d), ammo: %d (client: %d)", ReturnUserName ( issuerid), Character [ issuerid ] [ character_handweapon], GetPlayerWeapon ( issuerid ), Character [ issuerid ] [ character_handammo], GetPlayerAmmo ( playerid ) ) );

			//ResetPlayerWeapons ( issuerid ) ;
			RemovePlayerWeapon ( issuerid ) ;

			SetCharacterHealth ( playerid, Character [ playerid ] [ character_health ] ) ;
			SetPlayerHealth ( playerid, 1000.0 ) ;
		

			if ( ++ AC_LevelMitigation [ issuerid ] >= 3 ) {

				AC_LevelMitigation [ issuerid ] = 0 ;

				SendModeratorWarning ( sprintf("[HACKER] (%d) %s has been kicked for using a weapon whilst being lower than level 3 three times.", issuerid, ReturnUserName ( issuerid, true )), MOD_WARNING_HIGH );

				SendClientMessage(issuerid, COLOR_RED, "You've been kicked for using a weapon whilst being below level three more than three times." ) ;
				SendClientMessage(issuerid, COLOR_RED, "Your information (IP, location, guns) has been logged and the moderators are made aware." ) ;

				WriteLog (issuerid, "anticheat", sprintf ( "%s has been kicked for using a weapon whilst being below level 3 three times.", ReturnUserName ( issuerid)) );

				return KickPlayer ( issuerid ) ;
			}
		
			return true ;
		}

		/*
		if(IsZoneSafeZone(GetPlayerZone(playerid)) && !IsZoneSafeZone(GetPlayerZone(issuerid))) {

			SendServerMessage(issuerid,"You cannot shoot someone while they're in a safezone and you're not, no damage has been done.",MSG_TYPE_WARN);
			SendModeratorWarning(sprintf("[SAFEZONE] (%d) %s shot (%d) %s while target is in safezone.",issuerid,ReturnUserName(playerid,false,false),playerid,ReturnUserName(playerid,false,false)),MOD_WARNING_MED);
			return true;
		}
		*/		

    	if ( weaponid != 0 && Character [ issuerid ] [ character_handweapon] != 0 ) {

    		if(weaponid != WEAPON_BAT) { TogglePlayerBleeding ( playerid ) ; }
    	}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////// WEAPON DAMAGES & CUSTOM ANIMS /////////////////////////////////////////////////////////////// 
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		new Float: modifier ;

		new Float: pos_x, Float: pos_y, Float: pos_z ;
		GetPlayerPos ( playerid, pos_x, pos_y, pos_z ) ;

		new Float: fDistance = GetPlayerDistanceFromPoint ( issuerid, pos_x, pos_y, pos_z ) ;

		switch ( weaponid ) {

			case WEAPON_BAT: {

				modifier = 10;
			}

			case WEAPON_KNIFE: {

				modifier = 15;
			}

			case WEAPON_DEAGLE : {

				switch ( bodypart ) {

					case BODY_PART_HEAD: { 

						if ( fDistance >= 12.5 ) {
							modifier += 75 ;
						}
						
						else modifier += 100 ;

						if ( IsPlayerBehindPlayer ( issuerid, playerid ) ) {

							AnimationLoop(playerid, "PED", "KO_shot_front", 4.1, 0, 1, 1, 1, 1, 1 ) ;
						} 

						else {
							AnimationLoop(playerid, "PED", "KO_shot_stom", 4.1, 0, 1, 1, 1, 1, 1 ) ;
						}

						//AnimationLoop(playerid, "PED", "KO_shot_face", 4.1, 0, 1, 1, 1, 1, 1 ) ;
					}

					case BODY_PART_TORSO: {

						if ( fDistance <= 3.0 ) modifier += 65 ;
						else if ( fDistance >= 3.0 && fDistance <= 7.5 ) modifier += 50 ;
						else if ( fDistance >= 7.5 ) modifier += 45 ;	

						if ( IsPlayerBehindPlayer ( issuerid, playerid, 0.0 ) ) {
							AnimationLoop(playerid, "PED", "DAM_stomach_frmBK", 4.1, 0, 1, 1, 1, 1, 1);
						}

						else AnimationLoop(playerid, "PED", "DAM_stomach_frmFT", 4.1, 0, 1, 1, 1, 1, 1);				
					}

					case BODY_PART_GROIN: {

						if ( fDistance <= 3.0 ) modifier += 70 ;
						else if ( fDistance >= 3.0 && fDistance <= 7.5 ) modifier += 45 ;
						else if ( fDistance >= 7.5 ) modifier += 25 ;	

						if ( IsPlayerBehindPlayer ( issuerid, playerid, 0.0 ) ) {
							AnimationLoop(playerid, "PED", "DAM_stomach_frmBK", 4.1, 0, 1, 1, 1, 1, 1);
						}

						else AnimationLoop(playerid, "PED", "DAM_stomach_frmFT", 4.1, 0, 1, 1, 1, 1, 1);	
					}

					case BODY_PART_LEFT_ARM, BODY_PART_RIGHT_ARM, BODY_PART_LEFT_LEG, BODY_PART_RIGHT_LEG: {

						if ( fDistance <= 3.0 ) modifier += 40 ;
						else if ( fDistance >= 3.0 && fDistance <= 7.5 ) modifier += 35 ;
						else if ( fDistance >= 7.5 ) modifier += 25 ;	
					}
				}
			}

			case WEAPON_SHOTGUN, WEAPON_SAWEDOFF: {

				switch ( bodypart ) {

					case BODY_PART_HEAD: { 

						if ( fDistance >= 12.5 ) modifier += 65 ;
							else modifier += 100 ;

						if ( IsPlayerBehindPlayer ( issuerid, playerid ) ) {

							SetPlayerToFacePlayer(playerid, issuerid);
							AnimationLoop(playerid, "PED", "KO_shot_front", 4.1, 0, 1, 1, 1, 1, 1 ) ;

						} 

						else {
							SetPlayerToFacePlayer(playerid, issuerid);
							AnimationLoop(playerid, "PED", "BIKE_fall_off", 4.1, 0, 1, 1, 1, 1, 1 ) ;
						}
					}

					case BODY_PART_TORSO: {

						if ( fDistance <= 3.0 ) { 
							modifier += 80 ;

							if ( IsPlayerBehindPlayer ( issuerid, playerid ) ) {

								SetPlayerToFacePlayer(playerid, issuerid);
								AnimationLoop(playerid, "PED", "KO_shot_front", 4.1, 0, 1, 1, 1, 1, 1 ) ;

							} 

							else {
								SetPlayerToFacePlayer(playerid, issuerid);
								AnimationLoop(playerid, "PED", "BIKE_fall_off", 4.1, 0, 1, 1, 1, 1, 1 ) ;
							}
						}

						else if ( fDistance >= 3.0 && fDistance <= 7.5 ) {
							modifier += 65 ;
							
							if ( IsPlayerBehindPlayer ( issuerid, playerid ) ) {

								SetPlayerToFacePlayer(playerid, issuerid);
								AnimationLoop(playerid, "PED", "KO_shot_front", 4.1, 0, 1, 1, 1, 1, 1 ) ;

							} 

							else {
								SetPlayerToFacePlayer(playerid, issuerid);
								AnimationLoop(playerid, "PED", "BIKE_fall_off", 4.1, 0, 1, 1, 1, 1, 1 ) ;
							}
						}

						else if ( fDistance >= 7.5 ) modifier += 25 ;	
					}

					case BODY_PART_GROIN:{

						if ( fDistance <= 3.0 ) {
							modifier += 60 ;

							if ( IsPlayerBehindPlayer ( issuerid, playerid ) ) {

								SetPlayerToFacePlayer(playerid, issuerid);
								AnimationLoop(playerid, "PED", "KO_shot_front", 4.1, 0, 1, 1, 1, 1, 1 ) ;

							} 

							else {
								SetPlayerToFacePlayer(playerid, issuerid);
								AnimationLoop(playerid, "PED", "BIKE_fall_off", 4.1, 0, 1, 1, 1, 1, 1 ) ;
							}	
						}

						else if ( fDistance >= 3.0 && fDistance <= 7.5 ) modifier += 35 ;
						else if ( fDistance >= 7.5 ) modifier += 15 ;

					}

					case BODY_PART_LEFT_ARM, BODY_PART_RIGHT_ARM, BODY_PART_LEFT_LEG, BODY_PART_RIGHT_LEG: {

						if ( fDistance <= 3.0 ) modifier += 40 ;
						else if ( fDistance >= 3.0 && fDistance <= 7.5 ) modifier += 35 ;
						else if ( fDistance >= 7.5 ) modifier += 25 ;	
					}
				}
			}

			case WEAPON_RIFLE: {

				switch ( bodypart ) {

					case BODY_PART_HEAD: { 

						if ( fDistance >= 12.5 ) modifier += 90 ;
						else modifier += 100 ;

						if ( IsPlayerBehindPlayer ( issuerid, playerid ) ) {

							AnimationLoop(playerid, "PED", "KO_shot_front", 4.1, 0, 1, 1, 1, 1, 1 ) ;
						} 

						else AnimationLoop(playerid, "PED","KO_SHOT_FACE", 4.1, 0, 1, 1, 1, 1, 1 ) ;

						//AnimationLoop(playerid, "PED", "KO_shot_face", 4.1, 0, 1, 1, 1, 1, 1 ) ;
					}

					case BODY_PART_TORSO: {

						if ( fDistance <= 3.0 ) modifier += 100 ;
						else if ( fDistance >= 3.0 && fDistance <= 7.5 ) modifier += 95 ;
						else if ( fDistance >= 7.5 ) modifier += 90 ;

						if ( IsPlayerBehindPlayer ( issuerid, playerid, 0.0 ) ) {

							AnimationLoop(playerid, "PED", "DAM_stomach_frmBK", 4.1, 0, 1, 1, 1, 1, 1);
						}

						else AnimationLoop(playerid, "PED", "DAM_stomach_frmFT", 4.1, 0, 1, 1, 1, 1, 1);		
					}

					case BODY_PART_GROIN:{

						if ( fDistance <= 3.0 ) modifier += 95 ;
						else if ( fDistance >= 3.0 && fDistance <= 7.5 ) modifier +=  90;
						else if ( fDistance >= 7.5 ) modifier += 85 ;	

						if ( IsPlayerBehindPlayer ( issuerid, playerid, 0.0 ) ) {
							AnimationLoop(playerid, "PED", "DAM_stomach_frmBK", 4.1, 0, 1, 1, 1, 1, 1);
						}

						else AnimationLoop(playerid, "PED", "DAM_stomach_frmFT", 4.1, 0, 1, 1, 1, 1, 1);	
					}

					case BODY_PART_LEFT_ARM, BODY_PART_RIGHT_ARM, BODY_PART_LEFT_LEG, BODY_PART_RIGHT_LEG: {

						if ( fDistance <= 3.0 ) modifier += 75 ;
						else if ( fDistance >= 3.0 && fDistance <= 7.5 ) modifier += 70 ;
						else if ( fDistance >= 7.5 ) modifier +=  65 ;	
					}
				}
			}

			case WEAPON_SNIPER : {

				switch ( bodypart ) {

					case BODY_PART_HEAD: { 

						if ( fDistance >= 12.5 ) modifier += 90 ;
							else modifier += 100 ;

						if ( IsPlayerBehindPlayer ( issuerid, playerid ) ) {
							AnimationLoop(playerid, "PED", "KO_shot_front", 4.1, 0, 1, 1, 1, 1, 1 ) ;
						} 

						else AnimationLoop(playerid, "PED","KO_SHOT_FACE", 4.1, 0, 1, 1, 1, 1, 1 ) ;

						//AnimationLoop(playerid, "PED", "KO_shot_face", 4.1, 0, 1, 1, 1, 1, 1 ) ;
					}

					case BODY_PART_TORSO: {

						if ( fDistance <= 3.0 ) modifier += 100 ;
						else if ( fDistance >= 3.0 && fDistance <= 7.5 ) modifier += 100 ;
						else if ( fDistance >= 7.5 ) modifier += 100 ;	

						if ( IsPlayerBehindPlayer ( issuerid, playerid, 0.0 ) ) {
							
							AnimationLoop(playerid, "PED", "DAM_stomach_frmBK", 4.1, 0, 1, 1, 1, 1, 1);
						}

						else AnimationLoop(playerid, "PED", "DAM_stomach_frmFT", 4.1, 0, 1, 1, 1, 1, 1);				
					}

					case BODY_PART_GROIN:{

						if ( fDistance <= 3.0 ) modifier += 100 ;
						else if ( fDistance >= 3.0 ) modifier += 95;

						if ( IsPlayerBehindPlayer ( issuerid, playerid, 0.0 ) ) {
							
							AnimationLoop(playerid, "PED", "DAM_stomach_frmBK", 4.1, 0, 1, 1, 1, 1, 1);
						}

						else AnimationLoop(playerid, "PED", "DAM_stomach_frmFT", 4.1, 0, 1, 1, 1, 1, 1);	
					}

					case BODY_PART_LEFT_ARM, BODY_PART_RIGHT_ARM, BODY_PART_LEFT_LEG, BODY_PART_RIGHT_LEG: {

						if ( fDistance <= 3.0 ) modifier += 80 ;
						else if ( fDistance >= 3.0 && fDistance <= 7.5 ) modifier += 75 ;
						else if ( fDistance >= 7.5 ) modifier +=  70 ;	
					}
				}
			}
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////// Animations for other bodyparts: ////////////////////////////////////////////////////////////// 
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		switch ( bodypart ) {
			case BODY_PART_LEFT_ARM: {

				if ( IsPlayerBehindPlayer ( issuerid, playerid,0.0  ) ) {
					
					AnimationLoop(playerid, "PED", "DAM_armL_frmBK", 4.1, 0, 1, 1, 1, 1, 1);
				}

				else AnimationLoop(playerid, "PED", "DAM_armL_frmFT", 4.1, 0, 1, 1, 1, 1, 1);
			}

			case BODY_PART_RIGHT_ARM: {

				if ( IsPlayerBehindPlayer ( issuerid, playerid, 0.0 ) ) {
					
					AnimationLoop(playerid, "PED", "DAM_armR_frmBK", 4.1, 0, 1, 1, 1, 1, 1);
				}

				else AnimationLoop(playerid, "PED", "DAM_armR_frmFT", 4.1, 0, 1, 1, 1, 1, 1);
			}

			case BODY_PART_LEFT_LEG: {

				if ( IsPlayerBehindPlayer ( issuerid, playerid, 0.0 ) ) {
					AnimationLoop(playerid, "PED", "DAM_LegL_frmBK", 4.1, 0, 1, 1, 1, 1, 1);
				}

				else AnimationLoop(playerid, "PED", "DAM_LegL_frmFT", 4.1, 0, 1, 1, 1, 1, 1);

				DamageLegs ( playerid ) ;
			}

			case BODY_PART_RIGHT_LEG: {
					
				if ( IsPlayerBehindPlayer ( issuerid, playerid, 0.0 ) ) {
					AnimationLoop(playerid, "PED", "DAM_LegR_frmBK", 4.1, 0, 1, 1, 1, 1, 1);
				}

				else AnimationLoop(playerid, "PED", "DAM_LegR_frmFT", 4.1, 0, 1, 1, 1, 1, 1);		

				DamageLegs ( playerid ) ;
			}
		}

		Character [ playerid ] [ character_health ] -= modifier ;
		SetCharacterHealth ( playerid, Character [ playerid ] [ character_health ], issuerid ) ;

		SetPlayerWound ( playerid, weaponid, bodypart, amount) ;

		if ( IsPlayerRidingHorse [ playerid ] ) {

			ApplyAnimation(playerid, "BIKED", "BIKEd_Ride", 4.0, 1, 1, 1, 1, 0, 1);
		}

		if ( Character [ playerid ] [ character_health ] <= 0 ) {

			ToggleDeathMode ( playerid, issuerid ) ;

			SendModeratorWarning ( sprintf("(%d) %s has injured (%d) %s with a (%d) %s (%d ammo)", issuerid, ReturnUserName ( issuerid, false ), playerid, ReturnUserName ( playerid, false ), weaponid, ReturnWeaponName ( weaponid ), Character [ issuerid ] [ character_handammo ] ), MOD_WARNING_MED ) ;
			WriteLog ( issuerid, "dmg/injury", sprintf("(%d) %s has injured (%d) %s with a (%d) %s (%d ammo)", issuerid, ReturnUserName ( issuerid, false ), playerid, ReturnUserName ( playerid, false ), weaponid, ReturnWeaponName ( weaponid ), Character [ issuerid ] [ character_handammo ] ) ) ;		
		}

    }

	#if defined hpac_OnPlayerTakeDamage
		return hpac_OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid, bodypart );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerTakeDamage
	#undef OnPlayerTakeDamage
#else
	#define _ALS_OnPlayerTakeDamage
#endif

#define OnPlayerTakeDamage hpac_OnPlayerTakeDamage
#if defined hpac_OnPlayerTakeDamage
	forward hpac_OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid, bodypart );
#endif

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart) {

	if ( playerid != INVALID_PLAYER_ID ) {

		if ( Character [ damagedid ] [ character_dmgmode ] == 1 ) {

    		if ( bodypart == BODY_PART_HEAD ) {

				PlayerInjuredCooldown [ damagedid ] = gettime()-1 ;

				SendServerMessage ( damagedid, "You got shot in the head whilst being critically injured and died.", MSG_TYPE_INFO ) ;
				
				SetPlayerHealth ( damagedid, 1000.0 ) ;
    		}
    	}
	}
	#if defined hpac_OnPlayerGiveDamage
		return hpac_OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerGiveDamage
	#undef OnPlayerGiveDamage
#else
	#define _ALS_OnPlayerGiveDamage
#endif

#define OnPlayerGiveDamage hpac_OnPlayerGiveDamage
#if defined hpac_OnPlayerGiveDamage
	forward hpac_OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart);
#endif

timer InjuredModeTimer[1000](playerid) {
	
////	print("InjuredModeTimer timer called (health.pwn)");

	new query [ 256 ] ;

	if ( Character [ playerid ] [ character_dmgmode ] == 1 ) {

		if ( PlayerRecentlyRevived [ playerid ] ) {

			PlayerRecentlyRevived [ playerid ] = false ;
			PlayerInjuredCooldown [ playerid ] = gettime () - 10 ;		
		}

		if ( PlayerInjuredCooldown [ playerid ] >= gettime ()) {

			new string [ 64 ] ; 

			format ( string, sizeof ( string ), "~n~~n~~n~~n~~r~Injury time left: %d", PlayerInjuredCooldown [ playerid ] - gettime() ) ;
			GameTextForPlayer(playerid, string , 1000, 3);

			ApplyAnimation(playerid, "CRACK", "crckidle2", 4.1, 1, 0, 0, 1, 0, 1);

			if ( Character [ playerid ] [ character_dmgmode ] == 1 ) {
				mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_dmgmode = 1 WHERE character_id = '%d' LIMIT 1", Character [ playerid ] [ character_id ] ) ;
				mysql_tquery ( mysql, query ) ;
			}

			TextDrawHideForPlayer(playerid, txtAnimHelper ) ;
			defer InjuredModeTimer(playerid) ;
		}

		else if ( PlayerInjuredCooldown [ playerid ] < gettime ()) {

			// create a corpse at their death location
			ProcessDeath ( playerid ) ; 

			Character [ playerid ] [ character_dmgmode ] = 2 ;
			TogglePlayerSpectating ( playerid, true ) ;

			SendServerMessage ( playerid, "Your injured mode has expired. Nobody has helped you in time. You died.", MSG_TYPE_INFO ) ;
			PlayerInjuredCooldown [ playerid ] = gettime () + 60 ;

			if ( Character [ playerid ] [ character_dmgmode ] == 2 ) {
				mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_dmgmode = 2 WHERE character_id = %d  LIMIT 1", Character [ playerid ] [ character_id ] ) ;
				mysql_tquery ( mysql, query ) ;
			}

			new string [ 256 ] ;

			format ( string, sizeof ( string ), "[%s (%d)] [%s (%d)] [%s (%d)]", 
				ReturnWeaponName ( Character [ playerid ] [ character_handweapon ] ), Character [ playerid ] [ character_handammo ],
				ReturnWeaponName ( Character [ playerid ] [ character_backweapon ] ), Character [ playerid ] [ character_backammo ],
				ReturnWeaponName ( Character [ playerid ] [ character_pantsweapon ] ), Character [ playerid ] [ character_pantsammo ]
			) ;

			WriteLog ( playerid, "death", sprintf("%s died and lost guns: %s.", ReturnUserName ( playerid ), string )) ;
			WriteLog ( playerid, "death_refund", sprintf("%s died and lost guns: %s.", ReturnUserName ( playerid ), string )) ;

			if(DidPlayerDieFromPlayer[playerid] != INVALID_PLAYER_ID) {
				
				RemovePlayerWeapon ( playerid );

				Character [ playerid ] [ character_backweapon ]  = 0 ;
				Character [ playerid ] [ character_backammo ] = 0 ;

				Character [ playerid ] [ character_pantsweapon ] = 0 ;
		 		Character [ playerid ] [ character_pantsammo ] = 0 ;

		 		SavePlayerWeapons ( playerid ) ;
		 	}

			InterpolateCameraPos ( playerid, -668.1268, 1392.3640, 76.4830, -1124.4877, 1365.9409, 74.9300, 60000, CAMERA_MOVE ) ;
			InterpolateCameraLookAt ( playerid, -668.5658, 1393.2677, 76.2180, -1123.9965, 1366.8170, 74.6600, 60000, CAMERA_MOVE ) ;

			defer DeadCooldown(playerid);
		}
	}

	return true ;
}

timer DeadCooldown[1000](playerid) {

////	print("DeadCooldown timer called (health.pwn)");

	if ( Character [ playerid ] [ character_dmgmode ] == 2 ) {

		PlayerInjuredCooldown [ playerid ] = gettime () + 60 ;
		TogglePlayerSpectating ( playerid, true ) ;

		Character [ playerid ] [ character_dmgmode ] = 3 ;

		InterpolateCameraPos ( playerid, -668.1268, 1392.3640, 76.4830, -1124.4877, 1365.9409, 74.9300, 60000, CAMERA_MOVE ) ;
		InterpolateCameraLookAt ( playerid, -668.5658, 1393.2677, 76.2180, -1123.9965, 1366.8170, 74.6600, 60000, CAMERA_MOVE ) ;

		defer DeadCooldown(playerid);
	}

	if ( PlayerInjuredCooldown [ playerid ] >= gettime ()) {

		GameTextForPlayer(playerid, sprintf("~n~~n~~n~~n~~r~Injury time left: %d", PlayerInjuredCooldown [ playerid ] - gettime()), 1000, 3);

		defer DeadCooldown(playerid) ;
	}

	else if ( PlayerInjuredCooldown [ playerid ] < gettime ()) {


		ResetPlayerWounds ( playerid ) ;
		Character [ playerid ] [ character_dmgmode ] = 0 ;


	    PlayerDamage [ playerid ] [ DAMAGE_LEGS ] = false ;
	    PlayerDamage [ playerid ] [ DAMAGE_ARMS ] = false ;

		TogglePlayerSpectating ( playerid, false ) ;		
		TogglePlayerControllable ( playerid, true ) ;

		ClearAnimations ( playerid ) ;
		CancelBloodPuddle ( playerid ) ;

		//SpawnPlayer_Character ( playerid ) ;

		new query [ 256 ] ;

		SetCharacterHealth ( playerid, 100 ) ;

		if ( ! IsPlayerPaused ( playerid ) ) {
			SetName ( playerid, sprintf("(%d) %s", playerid, ReturnUserName ( playerid, false ) ), 0xCFCFCFFF ) ;
		}

		else SetName ( playerid, sprintf("[PAUSED (/afklist)]{DEDEDE}\n(%d) %s", playerid, ReturnUserName ( playerid, false )  ), COLOR_RED ) ;

		ResetPlayerTemperature(playerid);
		ResetCharacterPointID(playerid);

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_dmgmode = 0 WHERE character_id = %d  LIMIT 1",Character [ playerid ] [ character_id ] ) ;
		mysql_tquery ( mysql, query ) ;

		return true ;
	}

	return true ;
}

ToggleDeathMode ( playerid, issuerid ) {

	if ( IsPlayerRidingHorse [ playerid ] ) {
		
		IsPlayerRidingHorse [ playerid ] = false ;
		
		SetDynamicObjectPos ( HorseObject [ playerid ], 0.0, 0.0, 0.0 ) ;
		SetDynamicObjectPos ( CowObject [ playerid ], 0.0, 0.0, 0.0 ) ;

		ClearAnimations(playerid,  true );
		TogglePlayerControllable(playerid, true);

		DestroyPlayerProgressBar(playerid, PlayerHorse [ playerid ] [ HorseSprintBar ] ) ;
		TextDrawHideForPlayer(playerid, TD_HorseSprint) ;

		DestroyPlayerProgressBar(playerid, PlayerHorse [ playerid ] [ HorseHealthBar ] ) ;
		TextDrawHideForPlayer(playerid, TD_HorseHealth) ;

		ClearAudioForZone ( playerid ) ;				
	}

	//Character [ playerid ] [ character_health ] = 100 ;
	//CancelBloodPuddle ( playerid ) ;

	TogglePlayerControllable(playerid, false ) ;

	ApplyAnimation(playerid, "CRACK", "crckidle2", 4.1, 1, 0, 0, 1, 0, 1);

	// NEED TESTING
	DidPlayerDieFromPlayer[playerid] = issuerid;
	PlayerInjuredCooldown [ playerid ] = gettime () + 300 ;
	Character [ playerid ] [ character_dmgmode ] = 1 ;

	if ( CharSwitchTick [ playerid ] ) {

    	return SetName ( playerid, sprintf("[PLAYER IS INJURED]{007FFF}[SWITCHING CHARACTERS]{DEDEDE}\n(%d) %s", playerid, ReturnUserName ( playerid, false )), COLOR_RED ) ;
	}

	else SetName ( playerid,  sprintf("(%d) %s", playerid, ReturnUserName ( playerid, false ) ), COLOR_RED ) ;

	KickPlayerFromTable(playerid);

	defer InjuredModeTimer(playerid) ;
	SendServerMessage ( playerid, "You've been critically injured. You will have to wait until someone helps you.", MSG_TYPE_ERROR ) ;
	ProxDetector ( playerid, 20.0, COLOR_ACTION, sprintf("* %s collapses after being critically injured.",ReturnUserName ( playerid, false ))) ;

	SendModeratorWarning ( sprintf("[DEATH] (%d) %s has been injured by (%d) %s.", playerid, ReturnUserName ( playerid ), issuerid, ReturnUserName ( issuerid ) ), MOD_WARNING_MED ) ;

	new id = GetPlayerZone ( playerid ) ;

	if ( id != -1 && Zones [ id ] [ zone_safezone ] ) {

		WriteLog ( playerid, "death", sprintf("[IN A SAFEZONE] (%d) %s has been injured by (%d) %s.", playerid, ReturnUserName ( playerid ), issuerid, ReturnUserName ( issuerid ) )) ;
	} 

	return true ;
}