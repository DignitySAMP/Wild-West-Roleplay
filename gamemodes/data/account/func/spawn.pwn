SelectSpawn ( playerid ) {

	defer NameTagProofCheck(playerid);

	if ( Character [ playerid ]  [ character_ajailed ] ) {

		SendServerMessage ( playerid, sprintf("You have %d minutes left in admin jail.", Character [ playerid ]  [ character_ajailed ] ), MSG_TYPE_INFO ) ;

		IsPlayerInAdminJail [ playerid ] = true ;
		
		//SetSpawnInfo ( playerid, -1, Character [ playerid ]  [ character_skin ], -869.9045, 2308.7915, 155.8610 , 90.0, -1, -1, -1, -1, -1, -1 ) ;
		ac_SetPlayerPos ( playerid, 154.1281, -1951.9653, 47.4766 ) ;
		TogglePlayerControllable ( playerid, false ) ;
		
		SetPlayerVirtualWorld(playerid, 0 );

		SendServerMessage ( playerid, "You've been returned to admin jail.", MSG_TYPE_WARN ) ;
		return true ;
	}

	else if ( Character [ playerid ] [ character_prison ] != 0 ) {

		if ( Character [ playerid ] [ character_prison ] > gettime () ) {

			ac_SetPlayerPos ( playerid, Character [ playerid ] [ character_prison_pos_x], Character [ playerid ] [ character_prison_pos_y], Character [ playerid ] [ character_prison_pos_z] ) ;
			SetPlayerInterior ( playerid, Character [ playerid ] [ character_prison_interior ] );
			SetPlayerVirtualWorld ( playerid, Character [ playerid ] [ character_prison_vw ] );
			switch ( random ( 2 ) ) {

				case 0: SendClientMessage(playerid, COLOR_DEFAULT, "** You've woken up from fighting inside the cell block.." ) ;
				case 1: SendClientMessage(playerid, COLOR_DEFAULT, "** You've woken up from a guard arguing with another inmate.." ) ;
			}
			return true ;
		}

		else {

			new query [ 256 ] ;

			Character [ playerid ] [ character_prison ] = 0;
			Character [ playerid ] [ character_prison_pos_x] = 0.0;
			Character [ playerid ] [ character_prison_pos_y] = 0.0;
			Character [ playerid ] [ character_prison_pos_z] = 0.0;
			Character [ playerid ] [ character_prison_interior] = 0;
			Character [ playerid ] [ character_prison_vw] = 0;

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_prison = %d, character_prison_pos_x = '%f', character_prison_pos_y = '%f',character_prison_pos_z = '%f', character_prison_interior = %d, character_prison_vw = %d WHERE character_id = %d",
				Character [ playerid ] [ character_prison ], Character [ playerid ] [ character_prison_pos_x ], Character [ playerid ] [ character_prison_pos_y ], Character [ playerid ] [ character_prison_pos_z ], Character [ playerid ] [ character_prison_interior ], Character [ playerid ] [ character_prison_vw ], Character [ playerid ] [ character_id ] ) ;
			mysql_tquery ( mysql, query );
		}
	}

	else {

		if(Character [ playerid ] [ character_crashed ]) {

			new query[128];
			Character[playerid][character_crashed] = 0;
			ac_SetPlayerPos ( playerid, Character [ playerid ] [ character_pos_x ], Character [ playerid ] [ character_pos_y ], Character [ playerid ] [ character_pos_z ] ) ;

			SetPlayerInterior ( playerid, Character [ playerid ] [ character_pos_interior ] ) ;
			SetPlayerVirtualWorld ( playerid, Character [ playerid ] [ character_pos_vw ] ) ;

			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_crashed = 0 WHERE character_id = %d",Character[playerid][character_id]);
			mysql_tquery(mysql,query);

			SendServerMessage ( playerid, "You've spawned where you crashed.", MSG_TYPE_INFO ) ;
			return true;
		}

		switch ( Character [ playerid ] [ character_spawnpoint ] ) {
			case 0: {

				ac_SetPlayerPos( playerid, SERVER_SPAWN_X, SERVER_SPAWN_Y, SERVER_SPAWN_Z ) ;
				SetPlayerFacingAngle(playerid, SERVER_SPAWN_A ) ;
				SetPlayerVirtualWorld(playerid, 0 );
			}

			case 1 : {

				switch ( Character [ playerid ]  [ character_town ] ) {

					case 0: { // longcreek
							
						ac_SetPlayerPos ( playerid, -1418.1863, 2641.7834, 55.3046 ) ;	
						return true ;
					}

					case 1: { // fremont
							
						ac_SetPlayerPos ( playerid, -797.6470, 1436.1898, 13.4218 ) ;
						return true ;	
					}

					default: { // longcreek
							
						ac_SetPlayerPos ( playerid, -1418.1863, 2641.7834, 55.3046 ) ;	
						return true ;
					}
				}

				SetPlayerVirtualWorld(playerid, 0 );
				return true ;
			}

			case 2 .. 3 : {
				for ( new i; i < MAX_POINTS; i ++ ) {

					if ( Point [ i ] [ point_id]  != -1 ) {

						if ( Character [ playerid ] [ character_spawnpoint ] == 2 ) {
							if ( Point [ i ] [ point_owner ] == Character [ playerid ] [ character_id ] ) {

								if ( Point [ i ] [ point_type ] == POINT_TYPE_HOUSE ) {

									//SetSpawnInfo ( playerid, -1, Character [ playerid ]  [ character_skin ], Point [ i ] [ point_int_x ], Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ], 90.0, -1, -1, -1, -1, -1, -1 ) ;
									ac_SetPlayerPos ( playerid, Point [ i ] [ point_int_x ], Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) ;

									SetPlayerVirtualWorld(playerid, Point [ i ] [ point_int_vw ] ) ;
									SetPlayerInterior(playerid, Point [ i ] [ point_int_int ] ) ;

									SetPlayerWeather ( playerid, 0 ) ;
									SetPlayerTime(playerid, 14, 0) ;

									PlayerTextDrawSetString ( playerid, TD_ZoneName, "San Andreas" ) ;
									PlayerTextDrawShow(playerid, TD_ZoneName ) ;

									PlayAudioStreamForPlayer(playerid, "http://play.ww-rp.net/ambient/ambient_interior.mp3");

									SetCharacterPointID(playerid,i);

									SendServerMessage ( playerid, "You have spawned inside your house.", MSG_TYPE_INFO ) ;

									return true ;
								}

								else continue ;
							}

							else continue ;
						}

						else if ( Character [ playerid ] [ character_spawnpoint ] == 3 ) {

							if ( Point [ i ] [ point_owner ] == Character [ playerid ] [ character_id ] ) {

								if ( Point [ i ] [ point_type ] == POINT_TYPE_BIZ ) {
									//SetSpawnInfo ( playerid, -1, Character [ playerid ]  [ character_skin ], Point [ i ] [ point_int_x ], Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ], 90.0, -1, -1, -1, -1, -1, -1 ) ;
									ac_SetPlayerPos ( playerid, Point [ i ] [ point_int_x ], Point [ i ] [ point_int_y ], Point [ i ] [ point_int_z ] ) ;

									SetPlayerVirtualWorld(playerid, Point [ i ] [ point_int_vw ] ) ;
									SetPlayerInterior(playerid, Point [ i ] [ point_int_int ] ) ;

									SetPlayerWeather ( playerid, 0 ) ;
									SetPlayerTime(playerid, 14, 0) ;

									PlayerTextDrawSetString ( playerid, TD_ZoneName, "San Andreas" ) ;
									PlayerTextDrawShow(playerid, TD_ZoneName ) ;

									PlayAudioStreamForPlayer(playerid, "http://play.ww-rp.net/ambient/ambient_interior.mp3");

									SetCharacterPointID(playerid,i);

									SendServerMessage ( playerid, "You have spawned inside your business.", MSG_TYPE_INFO ) ;

									return true ;
								}

								else continue ;
							}

							else continue ;
						}
					}

					else continue ;
				}

				return true ;
			}

			case 4 : {
				new posseid = Character [ playerid ] [ character_posse ] ;

				for ( new i; i < MAX_POSSES; i ++ ) {
					if ( Posse [ i ] [ posse_id ] > 0 && Posse [ i ] [ posse_id ] == posseid ) {

						//SetSpawnInfo ( playerid, -1, Character [ playerid ]  [ character_skin ], Posse [ i ] [ posse_spawn_x ], Posse [ i ] [ posse_spawn_y ], Posse [ i ] [ posse_spawn_z ], 90.0, -1, -1, -1, -1, -1, -1 ) ;			
						ac_SetPlayerPos(playerid, Posse [ i ] [ posse_spawn_x ], Posse [ i ] [ posse_spawn_y ], Posse [ i ] [ posse_spawn_z ] ) ;

						SetPlayerInterior(playerid, Posse [ i ] [ posse_spawn_int ] ) ;
						SetPlayerVirtualWorld(playerid, Posse [ i ] [ posse_spawn_vw ] ) ;

						if ( Posse [ i ] [ posse_spawn_int ] || Posse [ i ] [ posse_spawn_vw ] ) {
							// FadeIn ( playerid ) ;
							SetPlayerWeather ( playerid, 0 ) ;
							SetPlayerTime(playerid, 14, 0) ;

							PlayerTextDrawSetString ( playerid, TD_ZoneName, "San Andreas" ) ;
							PlayerTextDrawShow(playerid, TD_ZoneName ) ;

							PlayAudioStreamForPlayer(playerid, "http://play.ww-rp.net/ambient/ambient_interior.mp3");
						}

						SetCharacterPointID(playerid,i);

						return SendServerMessage ( playerid, "You have spawned at your faction's spawnpoint.", MSG_TYPE_INFO ) ;
					}

					else continue ;
				}

				return true ;
			}

			case 5: {
				new motelspawn = Character [ playerid ] [ character_spawnmotel ] ; 

				ac_SetPlayerPos ( playerid, MotelPoints [ motelspawn ] [ motel_pos_x ], MotelPoints [ motelspawn ] [ motel_pos_y ], MotelPoints [ motelspawn ] [ motel_pos_z ] ) ;
				SendServerMessage ( playerid, sprintf("You've spawned at the \"%s\" (%d), to remove this use /spawn.", MotelPoints [ motelspawn ] [ motel_name ], motelspawn), MSG_TYPE_INFO ) ;

				return true ;
			}

			case 6: {

				if ( Character [ playerid ] [ character_pos_x ] == 0 && Character [ playerid ] [ character_pos_y ] == 0 && Character [ playerid ] [ character_pos_z ] == 0 ) {

					switch ( Character [ playerid ]  [ character_town ] ) {

						case 0: { // longcreek
							
							ac_SetPlayerPos ( playerid, -1418.1863, 2641.7834, 55.3046 ) ;	
							return true ;
						}

						case 1: { // fremont
							
							ac_SetPlayerPos ( playerid, -797.6470, 1436.1898, 13.4218 ) ;
							return true ;	
						}

						default: { // longcreek
							
							ac_SetPlayerPos ( playerid, -1418.1863, 2641.7834, 55.3046 ) ;	
							return true ;
						}
					}

					SetPlayerVirtualWorld(playerid, 0 );
					SendServerMessage ( playerid, "Something went wrong, you've been spawned at your spawn town.", MSG_TYPE_WARN ) ;

					return true ;
				}

				ac_SetPlayerPos ( playerid, Character [ playerid ] [ character_pos_x ], Character [ playerid ] [ character_pos_y ], Character [ playerid ] [ character_pos_z ] ) ;

				SetPlayerInterior ( playerid, Character [ playerid ] [ character_pos_interior ] ) ;
				SetPlayerVirtualWorld ( playerid, Character [ playerid ] [ character_pos_vw ] ) ;

				SendServerMessage ( playerid, "You've spawned where you last logged out at.", MSG_TYPE_INFO ) ;

				return true ;
			}
		}

	}

	return true ;
}


CMD:spawn(playerid, params [] ) {

	new query [ 256 ] ;

	if ( ! strcmp ( params, "newb" ) ) {

		Character [ playerid ] [ character_spawnpoint ] = 0 ;

		SendServerMessage ( playerid, "You will now spawn at the global spawn.", MSG_TYPE_INFO ) ;

	}

	else if ( ! strcmp ( params, "town" ) ) {

		Character [ playerid ] [ character_spawnpoint ] = 1 ;

		SendServerMessage ( playerid, "You will now spawn in your town of origin.", MSG_TYPE_INFO ) ;
	}

	else if ( ! strcmp ( params, "house" ) ) {

		new count = 0;

		for ( new i; i < MAX_POINTS; i ++ ) {

			if ( Point [ i ] [ point_id ] != -1 ) {

				if ( Point [ i ] [ point_owner ] == Character [ playerid ] [ character_id ] ) {

					if ( Point [ i ] [ point_type ] == POINT_TYPE_HOUSE ) {

						Character [ playerid ] [ character_spawnpoint ] = 2 ;
						SendServerMessage ( playerid, "You will now spawn in one of your houses.", MSG_TYPE_INFO ) ;
						count ++ ;
					}

					else continue ;
				}

				else continue ;
			}

			else continue ;
		}

		if ( ! count ) {

			return SendServerMessage ( playerid, "You don't have any house to spawn in.", MSG_TYPE_ERROR ) ;
		}
	}

	else if ( ! strcmp ( params, "biz" ) ) {

		new count = 0;

		for ( new i; i < MAX_POINTS; i ++ ) {

			if ( Point [ i ] [ point_id ] != -1 ) {

				if ( Point [ i ] [ point_owner ] == Character [ playerid ] [ character_id ] ) {
					
					if ( Point [ i ] [ point_type ] == POINT_TYPE_BIZ ) {
						
						Character [ playerid ] [ character_spawnpoint ] = 3 ;
						SendServerMessage ( playerid, "You will now spawn in one of your businesses.", MSG_TYPE_INFO ) ;
						count ++ ;
					}

					else continue ;
				}

				else continue ;
			}

			else continue ;
		}

		if ( ! count ) {

			return SendServerMessage ( playerid, "You don't have any business to spawn in.", MSG_TYPE_ERROR ) ;
		}
	}

	else if ( ! strcmp ( params, "faction" ) ) {

		for ( new i; i < MAX_POSSES; i ++ ) {

			if ( Posse [ i ] [ posse_id] != -1 ) {

				if ( Posse [ i ] [ posse_spawn_x ] == 0 || Posse [ i ] [ posse_spawn_z ] == 0 || Posse [ i ] [ posse_spawn_z ] == 0 ) {

					return SendServerMessage ( playerid, "There is no faction spawn set up for your faction.", MSG_TYPE_ERROR ) ;
				}

				else {
					
					Character [ playerid ] [ character_spawnpoint ] = 4 ;
					SendServerMessage ( playerid, "You will now spawn at your faction's spawnpoint", MSG_TYPE_INFO ) ;
					break;
				}
			}
		}
	}

	else if ( ! strcmp ( params, "location" ) ) {

		Character [ playerid ] [ character_spawnpoint ] = 6 ;
		SendServerMessage ( playerid, "You will now spawn where you last logged out at.", MSG_TYPE_INFO ) ;
	}

	else return SendServerMessage ( playerid, "/spawn [newb, town, house, biz, faction, location]", MSG_TYPE_ERROR ) ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_spawnpoint = %d WHERE character_id = %d", Character [ playerid ] [ character_spawnpoint ], Character [ playerid ] [ character_id ] ) ;
 	mysql_tquery ( mysql, query ) ;

 	return true ;
}
