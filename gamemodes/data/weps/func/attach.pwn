SetupPlayerGunAttachments ( playerid ) {

	new model ;

	RemovePlayerAttachedObject(playerid, 7 ) ;
	RemovePlayerAttachedObject(playerid, 8 ) ;
	if ( ! IsCarryingCorpse ( playerid ) ) { RemovePlayerAttachedObject(playerid, 9 ) ; }

	if ( Character [ playerid ] [ character_pantsweapon ] ){

		model = ReturnWeaponObjectEx ( Character [ playerid ] [ character_pantsweapon ] ) ;

		if ( Character [ playerid ] [ character_trousergun_scalex ] == 0 || Character [ playerid ] [ character_trousergun_scaley ] == 0 || Character [ playerid ] [ character_trousergun_scalez ] == 0 ) {
			if(model != 335) { SetPlayerAttachedObject(playerid, ATTACH_SLOT_PANTS, model, 8, 0.03, 0.0, 0.124, -103.4, 0.0, 1.8, 1.0, 1.0, 1.0 ) ; }
			else { SetPlayerAttachedObject(playerid, ATTACH_SLOT_PANTS, model, 8, 0.14,0.10,0.12,-103.40,90.40,1.79 , 1.0, 1.0, 1.0 ) ; }
		}

		else {

			SetPlayerAttachedObject(playerid, ATTACH_SLOT_PANTS, model, 8, Character [ playerid ] [ character_trousergun_offsetx ], Character [ playerid ] [ character_trousergun_offsety ], Character [ playerid ] [ character_trousergun_offsetz ],
				Character [ playerid ] [ character_trousergun_rotx ], Character [ playerid ] [ character_trousergun_roty ], Character [ playerid ] [ character_trousergun_rotz ], Character [ playerid ] [ character_trousergun_scalex ], Character [ playerid ] [ character_trousergun_scaley ], Character [ playerid ] [ character_trousergun_scalez ] ) ;
		}
	}

	if ( ! IsCarryingCorpse ( playerid ) ) {

		if ( Character [ playerid ] [ character_backweapon ] ) {

			model = ReturnWeaponObjectEx ( Character [ playerid ] [ character_backweapon ] ) ;

			if ( Character [ playerid ] [ character_backgun_scalex ] == 0 || Character [ playerid ] [ character_backgun_scaley ] == 0 || Character [ playerid ] [ character_backgun_scalez ] == 0 ) {

				if(model != 335 && model != 336) { SetPlayerAttachedObject(playerid, ATTACH_SLOT_BACK, model, 1, -0.20, -0.13, 0.000, 0.0, 0.00, 4.0, 1.0, 1.0, 1.0 ) ; }
				else {

					if(model == 336) { SetPlayerAttachedObject(playerid, ATTACH_SLOT_BACK, model, 1, 0.19,-0.16,0.00, 0.00,-97.29,4.00, 1.0, 1.0, 1.0 ) ; }
					else if(model == 335) { SetPlayerAttachedObject(playerid, ATTACH_SLOT_BACK, model, 1, -0.29,-0.13,-0.20, 0.00,-89.49,4.00, 1.0, 1.0, 1.0 ) ; }
				}
			}

			else {

			SetPlayerAttachedObject(playerid, ATTACH_SLOT_BACK, model, 1, Character [ playerid ] [ character_backgun_offsetx ], Character [ playerid ] [ character_backgun_offsety ], Character [ playerid ] [ character_backgun_offsetz ],
					Character [ playerid ] [ character_backgun_rotx ], Character [ playerid ] [ character_backgun_roty ], Character [ playerid ] [ character_backgun_rotz ],  Character [ playerid ] [ character_backgun_scalex ],
					Character [ playerid ] [ character_backgun_scaley ], Character [ playerid ] [ character_backgun_scalez ] ) ;
			}
		}	
	}

	//_SetPlayerAttachedObject(playerid, ATTACH_S}LOT_HANDS, Re_turnWeaponObjectEx ( Character [ playerid ] [ character__handweapon] ), 6, 0.004, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0 );

	if ( Character [ playerid ] [ character_handweapon ] ) {

	    if ( Character [ playerid ] [ character_handammo] > 0 ) {
	 		GivePlayerWeapon ( playerid, Character [ playerid ] [ character_handweapon], Character [ playerid ] [ character_handammo] );
	 	}

	 	else SetPlayerAttachedObject(playerid, ATTACH_SLOT_HANDS, ReturnWeaponObjectEx ( Character [ playerid ] [ character_handweapon] ), 6, 0.004, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0 );
	}


	return true ;
}