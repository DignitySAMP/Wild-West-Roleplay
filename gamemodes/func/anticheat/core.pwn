//#include <BustAim>

#define MAX_ANTICHEAT_WARNINGS	( 3 )

new player_ACTick_Money 		[ MAX_PLAYERS ] ; 
new player_ACTick_Weapon 		[ MAX_PLAYERS ] ; 
new player_ACTick_Ammo 			[ MAX_PLAYERS ] ;
new player_ACTick_Fly 			[ MAX_PLAYERS ] ;
new player_ACTick_Speed 		[ MAX_PLAYERS ] ;
new player_ACTick_AimbotIncr 	[ MAX_PLAYERS ] ;
new player_ACTick_ShootRate 	[ MAX_PLAYERS ] ;

new disallowed_weapons [ ] = {

	WEAPON_BRASSKNUCKLE, 	WEAPON_GOLFCLUB, 			WEAPON_NITESTICK, 			WEAPON_CHAINSAW,
	WEAPON_DILDO,			WEAPON_DILDO2, 				WEAPON_VIBRATOR, 			WEAPON_VIBRATOR2,
	WEAPON_GRENADE,			WEAPON_TEARGAS,				WEAPON_COLT45,				WEAPON_SILENCED,
	WEAPON_SHOTGSPA,		WEAPON_UZI,					WEAPON_MP5,					WEAPON_AK47,			
	WEAPON_M4,				WEAPON_TEC9,				WEAPON_ROCKETLAUNCHER,		WEAPON_HEATSEEKER,		
	WEAPON_FLAMETHROWER,	WEAPON_MINIGUN,				WEAPON_SATCHEL,				WEAPON_BOMB,			
	WEAPON_SPRAYCAN,		WEAPON_FIREEXTINGUISHER,	44,							45,						
	WEAPON_PARACHUTE
} ;


static Float: GetPlayerSpeed(playerid)
{
	new Float:SpeedX, Float:SpeedY, Float:SpeedZ, Float:Speed;

	GetPlayerVelocity(playerid, SpeedX, SpeedY, SpeedZ);
	Speed = floatsqroot(floatadd(floatpower(SpeedX, 2.0), floatpower(SpeedY, 2.0)));

	return floatmul(Speed, 200.0);
}

CheckCBug ( playerid, weaponid, tickcount ) {

	new time;
	if ( weaponid == 24 ) {

		time = GetTickDiff ( GetTickCount(), tickcount ) ;
		if ( time < 650 ) {

			WriteLog (playerid, "cbug", sprintf("(%d) %s has tried to c-bug.", playerid, ReturnUserName ( playerid, true, false )));

			TogglePlayerControllable ( playerid, false ) ;
			defer CBugRelease(playerid);
		}
	}
}

GetShootRate ( playerid ) {

	return player_ACTick_ShootRate [ playerid ];
}

SetShootRate ( playerid ) {

	player_ACTick_ShootRate [ playerid ] = GetTickCount();
}

timer CBugRelease[750](playerid) {

	TogglePlayerControllable ( playerid, true ) ;
}

/*

ANTI TP HACK:

Hook SetPlayerPos to save positions in a variable
Update this variable every 2-3 seconds with new position & check if the player is in range of previous position (15)
If they aren't, send tp hack warning

*/

new Float: player_AC_Pos_X [ MAX_PLAYERS ] ;
new Float: player_AC_Pos_Y [ MAX_PLAYERS ] ;
new Float: player_AC_Pos_Z [ MAX_PLAYERS ] ;

Safe_SetPlayerPos(playerid, Float: x, Float: y, Float: z ) {

	player_AC_Pos_X [ playerid ] = x ;
	player_AC_Pos_Y [ playerid ] = y ;
	player_AC_Pos_Z [ playerid ] = z ;


	SetPlayerPos(playerid, Float: x, Float: y, Float: z);
	return true ;
}

ac_SetPlayerPos(playerid, Float: x, Float: y, Float: z, fadein = 1, streamin = 1) {
	
	player_AC_Pos_X [ playerid ] = x ;
	player_AC_Pos_Y [ playerid ] = y ;
	player_AC_Pos_Z [ playerid ] = z ;

	if ( fadein ) {
		BlackScreen ( playerid ) ;
		SetPlayerPos(playerid, Float: x, Float: y, Float: z);
		FadeIn ( playerid ) ;
	}

	else if ( ! fadein ) {
		
		SetPlayerPos(playerid, Float: x, Float: y, Float: z);
	}

	//Streamer_Update(playerid);
	if ( streamin ) {
		defer UpdateStreamer(playerid);
	}

	return true ;
}

timer UpdateStreamer[750](playerid) {

	return Streamer_Update(playerid);
}

/*ptask PlayerPositionStorage[500](playerid) {

////	print("PlayerPositionStorage timer called (anticheat/core.pwn)");

	if ( IsPlayerSpawned ( playerid ) ) {

		new Float: x, Float: y, Float: z ;
		GetPlayerPos ( playerid, x, y, z ) ;

		player_AC_Pos_X [ playerid ] = x ;
		player_AC_Pos_Y [ playerid ] = y ;
		player_AC_Pos_Z [ playerid ] = z ;
	}

	return true ;
}*/

ptask PlayerAntiCheat[750](playerid){ //350

////	print("PlayerAntiCheat timer called (anticheat/core.pwn)");

	if ( IsPlayerSpawned ( playerid ) && ! IsPlayerPaused ( playerid ) ) {

		/*new Float: x, Float: y, Float: z ;
		GetPlayerPos ( playerid, x, y, z ) ;

		if ( ! IsPlayerInRangeOfPoint(playerid, 10.0, player_AC_Pos_X [ playerid ], player_AC_Pos_Y [ playerid ],  player_AC_Pos_Z [ playerid ] ) ) {

			new Float: ac_dist = GetPlayerDistanceFromPoint(playerid, player_AC_Pos_X [ playerid ], player_AC_Pos_Y [ playerid ],  player_AC_Pos_Z [ playerid ] ) ;
			SendModeratorWarning ( sprintf("[ANTICHEAT] (%d) %s may be TP hacking! They're %0.3f yards away from prev. pos.", playerid, ReturnUserName ( playerid, true ), ac_dist), MOD_WARNING_HIGH );
		}*/

		if ( Character [ playerid ] [ character_level ] < 1 && Character [ playerid ] [ character_level ] < 3 ) {
		
			if ( GetPlayerWeapon ( playerid ) && GetPlayerWeapon ( playerid ) != Character [ playerid ] [ character_handweapon ]) {

				SendModeratorWarning ( sprintf("[WEAPON] (%d) %s is below level 3 but has a weapon. (client gun doesnt match server gun)", playerid, ReturnUserName ( playerid ) ), MOD_WARNING_HIGH );

			}

		}

		new query[180] ;

		if ( ! IsPlayerLogged [ playerid ] && !LogoutPermission [ playerid ] ) {

			WriteLog ( playerid, "epp", sprintf("(%d) %s has spawned without being logged in", playerid, ReturnUserName ( playerid ) )) ;
			SendModeratorWarning ( sprintf("[EPP] (%d) %s has spawned without being logged in. They should be kicked. If not, kick them.", playerid, ReturnUserName ( playerid ) ), MOD_WARNING_HIGH );

			KickPlayer ( playerid ) ;
		}

		if ( GetPlayerSpeed ( playerid ) > 600 ) {

			if ( IsPlayerModerator ( playerid ) ) {

				return false ;
			}

			WriteLog ( playerid, "anticheat", sprintf("(%d) %s has been kicked for speedhacking - ban IP asap", playerid, ReturnUserName ( playerid ) )) ;
			SendClientMessageToAll ( COLOR_STAFF, sprintf("[ANTICHEAT] (%d) %s has been kicked for speedhacking.", playerid, ReturnUserName ( playerid ) )) ;

			KickPlayer ( playerid ) ;
		}

		if ( Character [ playerid ] [ character_handweapon ] == -1 ) {

			RemovePlayerWeapon ( playerid ) ;
			Character [ playerid ] [ character_handweapon ] = 0 ;
			Character [ playerid ] [ character_handammo ] = 0 ;

			SendServerMessage ( playerid, "There was an issue processing your weapon. It's been reset. If you lost it due to a bug, post a refund thread.", MSG_TYPE_ERROR ) ;
		}

		if ( GetPlayerMoney ( playerid ) != Character [ playerid ] [ character_handmoney ] ) {

			ResetPlayerMoney ( playerid ) ;
			GivePlayerMoney(playerid, Character [ playerid ] [ character_handmoney ] ) ;

			if ( ++ player_ACTick_Money [ playerid ] > MAX_ANTICHEAT_WARNINGS ) {

				if ( GetPlayerMoney ( playerid ) == Character [ playerid ] [ character_handmoney ] ) {

					return false ;
				}

				player_ACTick_Money [ playerid ] = 0 ;
	    		SendModeratorWarning ( sprintf("[ANTICHEAT] (%d) %s may be money hacking! Client money: %d, server money: %d", playerid, ReturnUserName ( playerid, true ), GetPlayerMoney(playerid), Character [ playerid ] [ character_handmoney ]), MOD_WARNING_HIGH );
			}
		}

		// If ammo is zero, it won't call this function. May give hackers a leak, maybe not.
		//if ( GetPlayerWeapon ( playerid ) != Character [ playerid ] [ character_handweapon ] && Character [ playerid ] [ character_handammo ] > 0 ) {

		if ( GetPlayerWeapon ( playerid ) != Character [ playerid ] [ character_handweapon ] && GetPlayerWeapon ( playerid ) != 0 ) {
			new pl_weapon = Character [ playerid ] [ character_handweapon ], pl_ammo = Character [ playerid ] [ character_handammo ] ;

			RemovePlayerWeapon ( playerid ) ;
			wep_GivePlayerWeapon ( playerid, pl_weapon, pl_ammo ) ;

			if ( ++ player_ACTick_Weapon [ playerid ] > MAX_ANTICHEAT_WARNINGS ) {

				player_ACTick_Weapon [ playerid ] = 0 ;
	    		SendModeratorWarning ( sprintf("[ANTICHEAT] (%d) %s may be weapon hacking! Client weapon: %d, server weapon %d", playerid, ReturnUserName ( playerid, true ), GetPlayerWeapon(playerid), Character [ playerid ] [ character_handweapon ]), MOD_WARNING_HIGH );
			}

			CheckPlayerHackedWeapons ( playerid, GetPlayerWeapon ( playerid ) ) ;
		}

		if ( GetPlayerAmmo ( playerid ) > Character [ playerid ] [ character_handammo ] ) {
			SetPlayerAmmo ( playerid, Character [ playerid ] [ character_handweapon ],Character [ playerid ] [ character_handammo ] );
			
			if ( GetPlayerAmmo ( playerid ) > 150 ) {

				SendSplitMessageToAll ( MANAGER_COLOR, sprintf("[ANTICHEAT] %s (%d) has been banned for ammo hacking", ReturnUserName ( playerid, true ), playerid )) ;
				//OldLog ( playerid, "mod/bans", sprintf("[ANTICHEAT] %s (%d) has been banned for ammo hacking", ReturnUserName ( playerid, true ), playerid )) ;

			    mysql_format(mysql, query, sizeof(query), "INSERT INTO bans (account_id, ip, ban_admin, ban_reason, ban_time, unban_time) VALUES ('%d', '%s', 'Anticheat', 'Ammo hacking', %d, %d)",
				Account [ playerid ] [ account_id ], ReturnIP ( playerid ), gettime(), 9000 * 999);

				mysql_tquery(mysql, query);

				BanEx(playerid, sprintf("Ammo hacking: anticheat detection, client: %d, server: %d", GetPlayerAmmo ( playerid ), Character [ playerid ] [ character_handammo ] ) ) ;
			}

			//if ( ++ player_ACTick_Ammo [ playerid ] > MAX_ANTICHEAT_WARNINGS ) {
				//SetPlayerAmmo ( playerid, Character [ playerid ] [ character_handweapon ],Character [ playerid ] [ character_handammo ] );

				//player_ACTick_Ammo [ playerid ] = 0 ;
	    		//SendModeratorWarning ( sprintf("[ANTICHEAT] (%d) %s may be ammo hacking! Client ammo: %d, server ammo %d", playerid, ReturnUserName ( playerid, true ), GetPlayerAmmo(playerid), Character [ playerid ] [ character_handammo ]), MOD_WARNING_HIGH );
			//}
		}


		new Float: armour ;
		GetPlayerArmour ( playerid, armour ) ;

		if ( armour > 1 ) {
		    
			SendSplitMessageToAll ( MANAGER_COLOR, sprintf("[ANTICHEAT] %s (%d) has been banned for armour hacking", ReturnUserName ( playerid, true ), playerid )) ;
			//OldLog ( playerid, "mod/bans", sprintf("[ANTICHEAT] %s (%d) has been banned for armour hacking", ReturnUserName ( playerid, true ), playerid )) ;

		    mysql_format(mysql, query, sizeof(query), "INSERT INTO bans (account_id, ip, ban_admin, ban_reason, ban_time, unban_time) VALUES ('%d', '%s', 'Anticheat', 'Armour hacking', %d, %d)",
			Account [ playerid ] [ account_id ], ReturnIP ( playerid ), gettime(), 9000 * 999);

			mysql_tquery(mysql, query);

			BanEx(playerid, "Armour hacking: anticheat detection" ) ;
		}

		if ( GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK ) {

			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE) ;

			SendSplitMessageToAll ( MANAGER_COLOR, sprintf("[ANTICHEAT] %s (%d) has been banned for armour hacking", ReturnUserName ( playerid, true ), playerid )) ;
			//OldLog ( playerid, "mod/bans", sprintf("[ANTICHEAT] %s (%d) has been banned for armour hacking", ReturnUserName ( playerid, true ), playerid )) ;	

		    mysql_format(mysql, query, sizeof(query), "INSERT INTO bans (account_id, ip, ban_admin, ban_reason, ban_time, unban_time) VALUES ('%d', '%s', 'Anticheat', 'Jetpack hacking', %d, %d)",
			Account [ playerid ] [ account_id ], ReturnIP ( playerid ), gettime(), 9000 * 999);

			mysql_tquery(mysql, query);

			BanEx(playerid, "Jetpack hacking: anticheat detection" ) ;
		}

		new Float: pos_x, Float: pos_y, Float: pos_z, Float: height ;
		GetPlayerPos ( playerid, pos_x, pos_y, pos_z ) ;
		CA_FindZ_For2DCoord ( pos_x, pos_y, height ) ;

		if ( pos_z > height + 5 ) {

			// Fixing bayside fly hack bug
			if ( GetPlayerZone ( playerid ) == 0 && pos_z <= 6 ) {

				return false ;
			}

			//SetPlayerPos ( playerid, pos_x, pos_y, height ) ;

			if ( ++ player_ACTick_Fly [ playerid ] > MAX_ANTICHEAT_WARNINGS && GetPlayerInterior ( playerid ) == 0 && GetPlayerVirtualWorld ( playerid ) == 0) {

				player_ACTick_Fly [ playerid ] = 0 ;
	   			SendModeratorWarning ( sprintf("[ANTICHEAT] (%d) %s may be fly hacking! GROUND: %.2f, PLAYER HEIGHT: %.2f", playerid, ReturnUserName ( playerid, true ), pos_x, height ), MOD_WARNING_HIGH);
	   		}
		}

		// Used to be max 325.
		if ( ! IsPlayerRidingHorse [ playerid ] ) {

			if ( GetPlayerSpeed ( playerid ) > 175 ) {

				if ( ++ player_ACTick_Speed [ playerid ] > MAX_ANTICHEAT_WARNINGS ) {

					player_ACTick_Speed [ playerid ] = 0 ;
		   			SendModeratorWarning ( sprintf("[ANTICHEAT] (%d) %s may be speed hacking! NORMAL SPEED: 175, HAS SPEED: %.2f", playerid, ReturnUserName ( playerid, true ), GetPlayerSpeed ( playerid ) ), MOD_WARNING_HIGH);
		   		}
			}
		}
		
		else {

			if ( Character [ playerid ] [ character_horseid ] == 3 ) {

				if ( GetPlayerSpeed ( playerid ) > 181 ) {

					if ( ++ player_ACTick_Speed [ playerid ] > MAX_ANTICHEAT_WARNINGS ) {

						player_ACTick_Speed [ playerid ] = 0 ;
			   			SendModeratorWarning ( sprintf("[ANTICHEAT] (%d) %s may be speed hacking! (On Horse) NORMAL SPEED: 181, HAS SPEED: %.2f", playerid, ReturnUserName ( playerid, true ), GetPlayerSpeed ( playerid ) ), MOD_WARNING_HIGH);
			   		}
		   		}
			}

			else if ( Character [ playerid ] [ character_horseid ] == 4 ) {

				if ( GetPlayerSpeed ( playerid ) > 203 ) {

					if ( ++ player_ACTick_Speed [ playerid ] > MAX_ANTICHEAT_WARNINGS ) {

						player_ACTick_Speed [ playerid ] = 0 ;
			   			SendModeratorWarning ( sprintf("[ANTICHEAT] (%d) %s may be speed hacking! (On Horse) NORMAL SPEED: 203, HAS SPEED: %.2f", playerid, ReturnUserName ( playerid, true ), GetPlayerSpeed ( playerid ) ), MOD_WARNING_HIGH);
			   		}
		   		}
			}

			else if ( Character [ playerid ] [ character_horseid ] == 5 ) {

				if ( GetPlayerSpeed ( playerid ) > 227 ) {

					if ( ++ player_ACTick_Speed [ playerid ] > MAX_ANTICHEAT_WARNINGS ) {

						player_ACTick_Speed [ playerid ] = 0 ;
			   			SendModeratorWarning ( sprintf("[ANTICHEAT] (%d) %s may be speed hacking! (On Horse) NORMAL SPEED: 203, HAS SPEED: %.2f", playerid, ReturnUserName ( playerid, true ), GetPlayerSpeed ( playerid ) ), MOD_WARNING_HIGH);
			   		}
		   		}
			}
		}
	}

	return true ;
}


CheckPlayerHackedWeapons ( playerid, weaponid ) {
	new query [ 512 ] ;

	if ( playerid == INVALID_PLAYER_ID ) {

		return false ;
	}

	for ( new i; i < sizeof ( disallowed_weapons); i ++ ) {
		if ( weaponid == disallowed_weapons [ i ] ) {

			SendSplitMessageToAll ( MANAGER_COLOR, sprintf("[ANTICHEAT] %s (%d) has been banned for weapon hacking", ReturnUserName ( playerid, true ), playerid )) ;
			//OldLog ( playerid, "mod/bans", sprintf("[ANTICHEAT] %s (%d) has been banned for weapon hacking", ReturnUserName ( playerid, true ), playerid )) ;

		    mysql_format(mysql, query, sizeof(query), "INSERT INTO bans (account_id, ip, ban_admin, ban_reason, ban_time, unban_time) VALUES ('%d', '%s', 'Anticheat', 'Weapon hacking', %d, %d)",
			Account [ playerid ] [ account_id ], ReturnIP ( playerid ), gettime(), 9000 * 999);

			mysql_tquery(mysql, query);

			BanEx(playerid, "Weapon hacking: anticheat detection" ) ;
		}
	}

	return true ;
}

/*
public OnPlayerSuspectedForAimbot ( playerid, hitid, weaponid, warnings ) {

	new Float: Wstats [ BUSTAIM_WSTATS_SHOTS ] ;
	
	player_ACTick_AimbotIncr [ playerid ] ++;

	if ( warnings & WARNING_OUT_OF_RANGE_SHOT ) {

		SendModeratorWarning ( sprintf("[ANTICHEAT] [Warning %d] %s (%d) fired shots from a distance greater than the %s's fire range (Normal Range: %f)", player_ACTick_AimbotIncr [ playerid ], ReturnUserName ( playerid, true ), playerid,ReturnWeaponName ( GetPlayerWeapon ( playerid ) ), BustAim::GetNormalWeaponRange(weaponid)));

		BustAim::GetRangeStats ( playerid, Wstats ) ;

		SendModeratorWarning ( sprintf("[ANTICHEAT] Shooter to Victim Distance(SA Units): 1) %.3f 2) %.3f 3) %.3f", Wstats[0], Wstats[1], Wstats[2] )) ;
	}

	if ( warnings & WARNING_PROAIM_TELEPORT ) {

	   	SendModeratorWarning ( sprintf("[ANTICHEAT] [Warning %d] %s (%d) is using proaim (Teleport Detected)", player_ACTick_AimbotIncr [ playerid ], ReturnUserName ( playerid, true ), playerid )) ;

		BustAim::GetTeleportStats ( playerid, Wstats ) ;

		SendModeratorWarning ( sprintf("Bullet to Victim Distance(SA Units): 1) %.3f 2) %.3f 3) %.3f", Wstats[0], Wstats[1], Wstats[2] )) ;
	}

	if ( warnings & WARNING_RANDOM_AIM ) {

	    SendModeratorWarning ( sprintf("[ANTICHEAT] [Warning %d] %s (%d) is suspected to be using aimbot(Hit with Random Aim with %s)", player_ACTick_AimbotIncr [ playerid ], ReturnUserName ( playerid, true ), playerid, ReturnWeaponName ( GetPlayerWeapon ( playerid ) ) )) ;

		BustAim::GetRandomAimStats(playerid,Wstats);

		SendModeratorWarning ( sprintf("[ANTICHEAT] Random Aim Offsets: 1) %.3f 2) %.3f 3) %.3f", Wstats[0], Wstats[1], Wstats[2] )) ;
	}

	if ( warnings & WARNING_CONTINOUS_SHOTS ) {

	   	SendModeratorWarning ( sprintf("[ANTICHEAT] [Warning %d] %s (%d) has fired 10 shots continously with %s (%d)", player_ACTick_AimbotIncr [ playerid ], ReturnUserName ( playerid, true ), playerid, ReturnWeaponName ( GetPlayerWeapon ( playerid ) ), weaponid ));
	}

	return 0;
}*/