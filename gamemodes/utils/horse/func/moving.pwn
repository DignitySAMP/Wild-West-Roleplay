#define VELOCITY_GALLOP		(2.0)
#define VELOCITY_WALK       (0.75)
#define VELOCITY_NORM		(0.15)



CMD:resynchorse ( playerid, params [] ) {

	PlayerHorse [ playerid ] [ HorseReloadTick ] = 201 ;

	return true ;
}

Float:SetHorseGallopSpeed ( playerid ) {

	new Float:velocity_total, horseid = Character [ playerid ] [ character_horseid ] ;

	if ( horseid == 99 ) {

		horseid = 5 ;
	}

	velocity_total = VELOCITY_GALLOP + ( float(horseid) * 0.015 ) ;

	return velocity_total ;
}

// timer HorseRide[50](playerid) { // this was 50 before
public OnPlayerUpdate(playerid) {

	if ( IsPlayerRidingHorse [ playerid ] ) {

    	//defer HorseRide(playerid) ;

    	if ( ++ PlayerHorse [ playerid ] [ HorseReloadTick ] > 100 ) {

    		SetPlayerHealth ( playerid, 1000.0 ) ;
			ApplyAnimation(playerid, "BIKED", "BIKEd_Ride", 4.0, 1, 1, 1, 1, 0, 1);

    		PlayerHorse [ playerid ] [ HorseReloadTick ] = 0 ;
    	}

	    new k, ud, lr ;
	    new Float:angle, Float:forwd;

		GetPlayerKeys(playerid, k, ud, lr);
		GetPlayerFacingAngle(playerid, angle);

		// Forwards & backwards
		if(ud == KEY_UP) {

			forwd	= VELOCITY_NORM ;
		}

		else if ( ud == KEY_DOWN ) {

			forwd = -0.05;
		}

		// Left & Right
		if ( lr == KEY_LEFT )  {

			angle	+= 6.0;			
		}

		else if ( lr == KEY_RIGHT ) {

			angle	-= 6.0;
		} 

		SetPlayerFacingAngle(playerid, angle);

		// Gallop & Walk modifiers
		if(k & KEY_JUMP) {

			forwd *= SetHorseGallopSpeed ( playerid ) ;
		}

		if ( k & KEY_WALK ) {

			forwd *= VELOCITY_WALK ;
		}

		SetPlayerVelocity ( playerid, forwd * floatsin( -angle, degrees ), forwd * floatcos ( -angle, degrees), 0.01 );
		SetPlayerHealth ( playerid, 1000.0 ) ; // Set player health so they don't die.

		new Float: x, Float: y, Float: z, Float: fz ;

		GetPlayerPos ( playerid, x, y, z ) ;
		CA_FindZ_For2DCoord(x, y, z) ;
		GetPlayerPos ( playerid, x, y, fz) ;

		z += 1.25 ; // was 1.25 before

		if ( ud ) {
			if ( ++ PlayerHorse [ playerid ] [ HorseRandomNoiseTick ] >= 200 && ToggleHorseSound [ playerid ] ) {

				switch ( PlayerHorse [ playerid ] [ HorseRandomNoise ] ) {

					case false: {
						PlayerHorse [ playerid ] [ HorseRandomNoise ] = true ;
						PlayAudioStreamForPlayer ( playerid, HORSE_SOUND_SNORT, 0, 0, 0, 5.0, false ) ;
					}

					case true : {
						PlayerHorse [ playerid ] [ HorseRandomNoise ] = false ;
						PlayAudioStreamForPlayer ( playerid, HORSE_SOUND_WHINE, 0, 0, 0, 5.0, false ) ;
					}
				}

				PlayerHorse [ playerid ] [ HorseRandomNoiseTick ] = 0 ;
			}	

			if ( PlayerHorse [ playerid ] [ HorseSprintValue ] >= 65 ) {

				PlayerHorse [ playerid ] [ HorseAbleToSprint ] = true ;
			}


			if ( k & KEY_JUMP && PlayerHorse [ playerid ] [ HorseSprintValue ] > 5 && PlayerHorse [ playerid ] [ HorseAbleToSprint ] ) {


				if ( ! PlayerHorse [ playerid ] [ PlayingHorseSound ] ) {
					PlayerHorse [ playerid ] [ PlayingHorseSound ] = true ;

					if ( ToggleHorseSound [ playerid ]  ) {
						PlayAudioStreamForPlayer ( playerid, HORSE_SOUND_GALLOP, 0, 0, 0, 5.0, false ) ;
					}
				}

				if ( PlayerHorse [ playerid ] [ HorseSprintValue ] < 15 ) {

					StopAudioStreamForPlayer(playerid) ;
					PlayerHorse [ playerid ] [ PlayingHorseSound ] = false ;
					PlayerHorse [ playerid ] [ HorseAbleToSprint ] = false ;

					return false ;
				}
				
				// This fixed people holding down SHIFT & ALT
				// at the same time. It used to make you sprint
				// unlimitedly. This should fix that issue.
				if ( k & KEY_WALK ) {

					forwd *= VELOCITY_WALK ;
				}

				else forwd *= SetHorseGallopSpeed ( playerid ) ;

				PlayerHorse [ playerid ] [ HorseSprintValue ] -- ;
			}

			else {
				if ( PlayerHorse [ playerid ] [ HorseSprintValue ] < 100 ) {

					PlayerHorse [ playerid ] [ HorseSprintValue ] ++ ;
				} 
			}

			if ( k & KEY_WALK ) {

				if ( k & KEY_JUMP ) {

					goto skipTask ;
				}

				forwd *= VELOCITY_WALK ;

				if ( PlayerHorse [ playerid ] [ HorseSprintValue ] < 100 ) {
					PlayerHorse [ playerid ] [ HorseSprintValue  ] += 2 ;
				}
			}

			skipTask:

			if ( z - fz >= 3 )  {

					SetPlayerVelocity ( playerid, forwd * floatsin( -angle, degrees ), forwd * floatcos ( -angle, degrees), 0.01 );
			}

			else {

				if ( fz <= z) {

					SetPlayerVelocity ( playerid, forwd * floatsin( -angle, degrees ), forwd * floatcos ( -angle, degrees), 0.05 );
				}

				if ( fz > z + 0.35 ) {//if ( fz > z  ) {

					SetPlayerVelocity ( playerid, forwd * floatsin( -angle, degrees ), forwd * floatcos ( -angle, degrees), -0.75 ); // was -0.75 before		
				}
			}
		}

		else if ( ! ud ) {
			StopAudioStreamForPlayer(playerid) ;
			PlayerHorse [ playerid ] [ PlayingHorseSound ] = false ;

			if ( PlayerHorse [ playerid ] [ HorseSprintValue ] < 100 ) {

				PlayerHorse [ playerid ] [ HorseSprintValue ] ++ ;
			} 
		}

		//SetPlayerProgressBarValue(playerid, PlayerHorse [ playerid ] [ HorseSprintBar ], PlayerHorse [ playerid ] [ HorseSprintValue ]);

		UpdateHorseGUI(playerid);

		//defer HorseRide(playerid);
	}


	#if defined horse_OnPlayerUpdate 
		return horse_OnPlayerUpdate ( playerid );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerUpdate 
	#undef OnPlayerUpdate 
#else
	#define _ALS_OnPlayerUpdate 
#endif

#define OnPlayerUpdate  horse_OnPlayerUpdate 
#if defined horse_OnPlayerUpdate 
	forward horse_OnPlayerUpdate ( playerid );
#endif