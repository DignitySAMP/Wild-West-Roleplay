public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ ) {

	if ( ! response ) {

		if ( index > 5 ) {

			SetupPlayerGunAttachments ( playerid ) ;

			return false ;
		}

		SendServerMessage ( playerid, "You cancelled editing the object.", MSG_TYPE_INFO ) ;

		RemovePlayerAttachedObject(playerid, index) ;
		Init_LoadPlayerAttachments ( playerid ) ;

		return true ;
	}

	else if(response) {

		if ( index > 5 ) {

			new query [ 512 ] ;

			if ( index == ATTACH_SLOT_PANTS ) {

				if(fScaleX != 1.0 || fScaleY != 1.0 || fScaleZ != 1.0) {

					SendServerMessage(playerid,"You cannot adjust the scale of the gun.",MSG_TYPE_ERROR);

					fScaleX = 1.0, fScaleY = 1.0, fScaleZ = 1.0;
				}

				Character [ playerid ] [ character_trousergun_offsetx ]  	 	= fOffsetX ;
				Character [ playerid ] [ character_trousergun_offsety ]  	 	= fOffsetY ; 
				Character [ playerid ] [ character_trousergun_offsetz ]  	 	= fOffsetZ ;

				Character [ playerid ] [ character_trousergun_rotx ]  		 	= fRotX ;
				Character [ playerid ] [ character_trousergun_roty ]  		 	= fRotY ;
				Character [ playerid ] [ character_trousergun_rotz ]  		 	= fRotZ ;

				Character [ playerid ] [ character_trousergun_scalex ]  		= fScaleX ;
				Character [ playerid ] [ character_trousergun_scaley ]  		= fScaleY ;
				Character [ playerid ] [ character_trousergun_scalez ]  		= fScaleZ ;

				mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_trousergun_offsetx = '%f', character_trousergun_offsety = '%f', character_trousergun_offsetz = '%f', character_trousergun_rotx='%f', character_trousergun_roty='%f', character_trousergun_rotz='%f', character_trousergun_scalex = '%f',character_trousergun_scaley = '%f',character_trousergun_scalez = '%f' WHERE character_id='%d'",
					Character [ playerid ] [ character_trousergun_offsetx ], Character [ playerid ] [ character_trousergun_offsety ], Character [ playerid ] [ character_trousergun_offsetz ],
					Character [ playerid ] [ character_trousergun_rotx ], Character [ playerid ] [ character_trousergun_roty ], Character [ playerid ] [ character_trousergun_rotz ], 
					Character [ playerid ] [ character_trousergun_scalex ], Character [ playerid ] [ character_trousergun_scaley ], Character [ playerid ] [ character_trousergun_scalez ],
					Character [ playerid ] [ character_id ] ) ;

				mysql_tquery ( mysql, query ) ;

				SendServerMessage ( playerid, "Adjusted weapon position on your trousers slot. It should save when you relog.", MSG_TYPE_INFO ) ;
			}

			else if ( index == ATTACH_SLOT_BACK ) {

				if(fScaleX != 1.0 || fScaleY != 1.0 || fScaleZ != 1.0) {

					SendServerMessage(playerid,"You cannot adjust the scale of the gun.",MSG_TYPE_ERROR);

					fScaleX = 1.0, fScaleY = 1.0, fScaleZ = 1.0;
				}
				
				Character [ playerid ] [ character_backgun_offsetx ]  	 	= fOffsetX ;
				Character [ playerid ] [ character_backgun_offsety ]  	 	= fOffsetY ; 
				Character [ playerid ] [ character_backgun_offsetz ]  	 	= fOffsetZ ;

				Character [ playerid ] [ character_backgun_rotx ]  		 	= fRotX ;
				Character [ playerid ] [ character_backgun_roty ]  		 	= fRotY ;
				Character [ playerid ] [ character_backgun_rotz ]  		 	= fRotZ ;

				Character [ playerid ] [ character_backgun_scalex ]  		= fScaleX ;
				Character [ playerid ] [ character_backgun_scaley ]  		= fScaleY ;
				Character [ playerid ] [ character_backgun_scalez ]  		= fScaleZ ;

				mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_backgun_offsetx = '%f', character_backgun_offsety = '%f', character_backgun_offsetz = '%f', character_backgun_rotx='%f', character_backgun_roty='%f', character_backgun_rotz='%f', character_backgun_scalex = '%f',character_backgun_scaley = '%f',character_backgun_scalez = '%f' WHERE character_id='%d'",
					Character [ playerid ] [ character_backgun_offsetx ], 	Character [ playerid ] [ character_backgun_offsety ], 	Character [ playerid ] [ character_backgun_offsetz ],
					Character [ playerid ] [ character_backgun_rotx ], 		Character [ playerid ] [ character_backgun_roty ], 		Character [ playerid ] [ character_backgun_rotz ], 
					Character [ playerid ] [ character_backgun_scalex ], 	Character [ playerid ] [ character_backgun_scaley ], 	Character [ playerid ] [ character_backgun_scalez ],
					Character [ playerid ] [ character_id ] ) ;

				mysql_tquery ( mysql, query ) ;

				SendServerMessage ( playerid, "Adjusted weapon position on your back slot. It should save when you relog.", MSG_TYPE_INFO ) ;
			}

			else if ( index == ATTACH_SLOT_MASK ) {


				Character [ playerid ] [ character_mask_offsetx ]  	 	= fOffsetX ;
				Character [ playerid ] [ character_mask_offsety ]  	 	= fOffsetY ; 
				Character [ playerid ] [ character_mask_offsetz ]  	 	= fOffsetZ ;

				Character [ playerid ] [ character_mask_rotx ]  		= fRotX ;
				Character [ playerid ] [ character_mask_roty ]  		= fRotY ;
				Character [ playerid ] [ character_mask_rotz ]  		= fRotZ ;

				Character [ playerid ] [ character_mask_scalex ]  		= fScaleX ;
				Character [ playerid ] [ character_mask_scaley ]  		= fScaleY ;
				Character [ playerid ] [ character_mask_scalez ]  		= fScaleZ ;

				mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_mask_offsetx = '%f', character_mask_offsety = '%f', character_mask_offsetz = '%f', character_mask_rotx='%f', character_mask_roty='%f', character_mask_rotz='%f', character_mask_scalex = '%f',character_mask_scaley = '%f',character_mask_scalez = '%f' WHERE character_id='%d'",
					Character [ playerid ] [ character_mask_offsetx ], 	Character [ playerid ] [ character_mask_offsety ], 	Character [ playerid ] [ character_mask_offsetz ],
					Character [ playerid ] [ character_mask_rotx ], 		Character [ playerid ] [ character_mask_roty ], 		Character [ playerid ] [ character_mask_rotz ], 
					Character [ playerid ] [ character_mask_scalex ], 	Character [ playerid ] [ character_mask_scaley ], 	Character [ playerid ] [ character_mask_scalez ],
					Character [ playerid ] [ character_id ] ) ;

				mysql_tquery ( mysql, query ) ;

				SendServerMessage ( playerid, "Adjusted mask position. It should save when you relog.", MSG_TYPE_INFO ) ;
			}

			SetupPlayerGunAttachments ( playerid ) ;
		}

		if ( index < 5 ) {

			new query [ 1024 ], arrayid = PlayerAddingAttachment [ playerid ], editingid = PlayerEditingObject [ playerid ] ;

			if ( arrayid == -1 ) {

				arrayid = PlayerAttachments [ playerid ] [ editingid ] [ attach_character_array] ;
			}

			if ( PlayerAddingAttachment [ playerid ] != -1 ) {

	   			TakeCharacterChange ( playerid, 50, MONEY_SLOT_HAND ) ;
	   			SendServerMessage ( playerid, "You've paid $0.50 for the attachment. You can access it by using /attachments.", MSG_TYPE_INFO ) ;
			}

			else SendServerMessage ( playerid, "You have adjusted your attachment.", MSG_TYPE_INFO ) ;

			mysql_format ( mysql, query, sizeof ( query ), "UPDATE attachments SET attach_character_index = %d, attach_character_array = %d, attach_character_bone = %d, \
				attach_character_offsetx = %f, attach_character_offsety = '%f', attach_character_offsetz = '%f', attach_character_rotx = '%f', attach_character_roty = '%f', attach_character_rotz = '%f',\
				attach_character_scalex = '%f', attach_character_scaley = '%f', attach_character_scalez = '%f', attach_character_visible = 1 WHERE attach_character_id = %d AND attach_character_attach_id = %d", 

			 	index, arrayid, boneid, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ,
				Character [ playerid ] [ character_id ], PlayerAttachments [ playerid ] [ editingid ] [ attach_character_attach_id ]
			) ;

			mysql_tquery ( mysql, query ) ;

			Init_LoadPlayerAttachments ( playerid ) ;
		}

		SetPlayerAttachedObject(playerid, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX , Float:fScaleY, Float:fScaleZ);
	}
	
	#if defined toy_OnPlayerEditAttachedObject
		return toy_OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEditAttachedObject
	#undef OnPlayerEditAttachedObject
#else
	#define _ALS_OnPlayerEditAttachedObject
#endif

#define OnPlayerEditAttachedObject toy_OnPlayerEditAttachedObject
#if defined toy_OnPlayerEditAttachedObject
	forward toy_OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ );
#endif

CMD:attachments ( playerid, params [] ) {

	new string [ 1024 ], attach_id  ;

	format ( string, sizeof ( string ), "ID \t Name" ) ;

	inline ToysDisplay(pid, dialogid, response, listitem, string:inputtext[]) {
	    #pragma unused pid, dialogid, inputtext

		if ( ! response ) {

			return false ;
		}

		else if ( response ) {

			if ( PlayerAttachments [ playerid ] [ listitem ] [ attach_character_array ] == -1 ) {

				SendServerMessage ( playerid, "You don't have an attachment in this slot.", MSG_TYPE_ERROR ) ;
				return cmd_attachments ( playerid, params) ;
			}

			inline ToysMenu(pidx, dialogidx, responsex, listitemx, string:inputtextx[]) {
	   			#pragma unused pidx, dialogidx, inputtextx

				if ( ! responsex ) {

					return cmd_attachments ( playerid, params ) ;
				}

				else if ( responsex ) {

					switch ( listitemx ) {

						case 0: {

							if ( PlayerAttachments [ playerid ] [ listitem ] [ attach_character_visible ] ) {

								PlayerAttachments [ playerid ] [ listitem ] [ attach_character_visible ] = false ;
								RemovePlayerAttachedObject(playerid, PlayerAttachments [ playerid ] [ listitem ] [ attach_character_index ]) ;
							}

							else {
								PlayerAttachments [ playerid ] [ listitem ] [ attach_character_visible ] = true ;

								SetPlayerAttachedObject(playerid, PlayerAttachments [ playerid ] [ listitem ] [ attach_character_index ], Attachments [ PlayerAttachments [ playerid ] [ listitem ] [ attach_character_array ] ] [ attach_model ], PlayerAttachments [ playerid ] [ listitem ] [ attach_character_bone ],
									PlayerAttachments [ playerid ] [ listitem ] [ attach_character_offsetx ], 	PlayerAttachments [ playerid ] [ listitem ] [ attach_character_offsety ], 	PlayerAttachments [ playerid ] [ listitem ] [ attach_character_offsetz ],
									PlayerAttachments [ playerid ] [ listitem ] [ attach_character_rotx ], 		PlayerAttachments [ playerid ] [ listitem ] [ attach_character_roty ], 		PlayerAttachments [ playerid ] [ listitem ] [ attach_character_rotz ],
									PlayerAttachments [ playerid ] [ listitem ] [ attach_character_scalex ], 	PlayerAttachments [ playerid ] [ listitem ] [ attach_character_scaley ], 	PlayerAttachments [ playerid ] [ listitem ] [ attach_character_scalez ] ) ;
							}

							string [ 0 ] = EOS ;

							mysql_format ( mysql, string, sizeof ( string ), "UPDATE attachments SET attach_character_visible = %d WHERE attach_character_id = %d AND attach_character_attach_id = %d", 
								PlayerAttachments [ playerid ] [ listitem ] [ attach_character_visible ], Character [ playerid ] [ character_id ], PlayerAttachments [ playerid ] [ listitem ] [ attach_character_attach_id ] ) ;
							mysql_tquery ( mysql, string ) ;

							SendServerMessage ( playerid, sprintf("You have %s your \"%s\".", ( PlayerAttachments [ playerid ] [ listitem ] [ attach_character_visible ] ) ? ("equipped") : ("unequipped"), Attachments [ PlayerAttachments [ playerid ] [ listitem ] [ attach_character_array ] ] [ attach_name ]), MSG_TYPE_INFO ) ;
							return cmd_attachments ( playerid, params ) ;
						}

						case 1: {

							inline ToysEdit(pidex, dialogidex, responseex, listitemex, string:inputtextex[]) {
	   						#pragma unused pidex, dialogidex, inputtextex

								if ( ! responseex ) {

									return cmd_attachments ( playerid, params ) ;
								}
	
								else if ( responseex ) {

									switch ( listitemex ) {

										case 0: {
											
											PlayerAddingAttachment [ playerid ] = -1 ;
											PlayerEditingObject [ playerid ] = listitem ;

											SetPlayerAttachedObject(playerid, PlayerAttachments [ playerid ] [ listitem ] [ attach_character_index ], Attachments [ PlayerAttachments [ playerid ] [ listitem ] [ attach_character_array ] ] [ attach_model ], PlayerAttachments [ playerid ] [ listitem ] [ attach_character_bone ],
												PlayerAttachments [ playerid ] [ listitem ] [ attach_character_offsetx ], 	PlayerAttachments [ playerid ] [ listitem ] [ attach_character_offsety ], 	PlayerAttachments [ playerid ] [ listitem ] [ attach_character_offsetz ],
												PlayerAttachments [ playerid ] [ listitem ] [ attach_character_rotx ], 		PlayerAttachments [ playerid ] [ listitem ] [ attach_character_roty ], 		PlayerAttachments [ playerid ] [ listitem ] [ attach_character_rotz ],
												PlayerAttachments [ playerid ] [ listitem ] [ attach_character_scalex ], 	PlayerAttachments [ playerid ] [ listitem ] [ attach_character_scaley ], 	PlayerAttachments [ playerid ] [ listitem ] [ attach_character_scalez ] ) ;

											EditAttachedObject(playerid, PlayerAttachments [ playerid ] [ listitem ] [ attach_character_index ]) ;

											return true ;
										}

										case 1: {
											
											new BoneNames [] [] = {
												"Invalid", "Spine", "Head", "Left Arm", "Right Arm", "Left Hand", "Right Hand", "Left Thigh", "Right Thigh",
												"Left Foot", "Right Foot", "Right Calf", "Left Calf", "Left Forearm", "Right Forearm", "Left Shoulder", "Right Shoulder",
												"Neck", "Jaw" 
											} ;

											string [ 0 ] = EOS ;

											format ( string, sizeof ( string ), "Select a bone") ;

											for ( new i = 1, j = sizeof ( BoneNames ); i < j ; i ++ ) {
	
												format ( string, sizeof ( string ), "%s\n%s", string, BoneNames [ i ] [ 0 ] ) ;
											}

											inline ToysBones(pidexe, dialogidexe, responseexe, listitemexe, string:inputtextexe[]) {
										
	   											#pragma unused pidexe, dialogidexe, inputtextexe

												if ( ! responseexe ) {

													return cmd_attachments ( playerid, params ) ;
												}

												else if ( responseexe ) {

													new selection = listitemexe + 1 ;

													string [ 0 ] = EOS ;

													mysql_format ( mysql, string, sizeof ( string ), "UPDATE attachments SET attach_character_bone = %d WHERE attach_character_id = %d AND attach_character_attach_id = %d", 
														selection, Character [ playerid ] [ character_id ], PlayerAttachments [ playerid ] [ listitem ] [ attach_character_attach_id ] ) ;
													mysql_tquery ( mysql, string ) ;

													SendServerMessage ( playerid, sprintf("You have changed the bone of your \"%s\" to %s", Attachments [ PlayerAttachments [ playerid ] [ listitem ] [ attach_character_array ] ] [ attach_name ], BoneNames [ selection ] [ 0 ] ), MSG_TYPE_INFO ) ;
													Init_LoadPlayerAttachments ( playerid ) ;

													return true ;
												}
											}

											Dialog_ShowCallback ( playerid, using inline ToysBones, DIALOG_STYLE_TABLIST_HEADERS, "Display Attachments: Editing Bones", string, "Continue", "Back" );

											return true ;
										}
									}
								}

								return true ;
							}

							Dialog_ShowCallback ( playerid, using inline ToysEdit, DIALOG_STYLE_TABLIST_HEADERS, "Display Attachments", "Choose an action\nEdit placement\nChange bone", "Continue", "Back" );
							return true ;
						}

						case 2: {

							string [ 0 ] = EOS ;

							mysql_format ( mysql, string, sizeof ( string ), "UPDATE attachments SET attach_character_array = -1 WHERE attach_character_id = %d AND attach_character_attach_id = %d", 
								Character [ playerid ] [ character_id ], PlayerAttachments [ playerid ] [ listitem ] [ attach_character_attach_id ] ) ;

							mysql_tquery ( mysql, string ) ;

							SendServerMessage ( playerid, sprintf("You have removed your \"%s\".", Attachments [ PlayerAttachments [ playerid ] [ listitem ] [ attach_character_array ] ] [ attach_name ]), MSG_TYPE_INFO ) ;

							//GiveCharacterMoney ( playerid, 15, MONEY_SLOT_HAND ) ;
							WriteLog ( playerid, "money/clothing_abuse", sprintf ( "%s has sold their attachment. If continued use, they are trying to do the money bug (+15$)", ReturnUserName ( playerid, false ))) ;


							RemovePlayerAttachedObject(playerid, PlayerAttachments [ playerid ] [ listitem ] [ attach_character_index ] ) ;
							Init_LoadPlayerAttachments ( playerid ) ;
							
							return true ;
						}
					}

					return true ;
				}

				return true ;
			}

			Dialog_ShowCallback ( playerid, using inline ToysMenu, DIALOG_STYLE_TABLIST_HEADERS, "Display Attachments: Edit Menu", "Choose an action\n(Un)equip Attachment\nModify Attachment\nDiscard Attachment", "Continue", "Back" );

			return true ;
		}

		return true ;
	}

	for ( new i; i < MAX_ATTACHMENTS ; i ++ ) {

		if ( PlayerAttachments [ playerid ] [ i ] [ attach_character_array ] != -1 ) {
			attach_id = PlayerAttachments [ playerid ] [ i ] [ attach_character_array ] ;

			if ( PlayerAttachments [ playerid ] [ i ] [ attach_character_visible] != 0 ) format ( string, sizeof ( string ), "%s\n%d \t %s [WEARING]", string, i, Attachments [ attach_id ] [ attach_name ] ) ;
			else format ( string, sizeof ( string ), "%s\n%d \t %s", string, i, Attachments [ attach_id ] [ attach_name ] ) ;
		}

		else if ( PlayerAttachments [ playerid ] [ i ] [ attach_character_array ] == -1 ) {

			format ( string, sizeof ( string ), "%s\nNone", string ) ;
		}
	}

	Dialog_ShowCallback ( playerid, using inline ToysDisplay, DIALOG_STYLE_TABLIST_HEADERS, "Display Attachments", string, "Continue", "Cancel" );

	return true ;
}

CMD:atch(playerid, params[]){
	return cmd_attachments(playerid, params);
}