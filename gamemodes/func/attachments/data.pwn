enum attachmentplayerData {

	attach_character_id,
	attach_character_attach_id,

	attach_character_index,
	attach_character_array,
	attach_character_bone,

 	Float: attach_character_offsetx,
	Float: attach_character_offsety,
	Float: attach_character_offsetz,

	Float: attach_character_rotx,
	Float: attach_character_roty,
	Float: attach_character_rotz,

	Float: attach_character_scalex,
	Float: attach_character_scaley,
	Float: attach_character_scalez,

	attach_character_visible
} ;

new PlayerAttachments [ MAX_PLAYERS ] [ MAX_ATTACHMENTS ] [ attachmentplayerData ] ;

Init_LoadPlayerAttachments ( playerid ) {

	PlayerAddingAttachment [ playerid ] = -1 ;
	PlayerEditingObject [ playerid ] = -1 ;

	for ( new i = 1; i < MAX_ATTACHMENTS; i ++ ) {

		PlayerAttachments [ playerid ]  [ i ] [ attach_character_attach_id ] = -1 ;
	}

	new query [ 128 ] ;

	mysql_format ( mysql, query, sizeof ( query ), "SELECT * FROM attachments WHERE attach_character_id = %d", Character [ playerid ] [ character_id ] ) ;
	return mysql_tquery ( mysql, query, "LoadPlayerAttachments", "i", playerid );
}

forward LoadPlayerAttachments ( playerid ) ;
public LoadPlayerAttachments ( playerid ) {

	new rows, fields;

	cache_get_data(rows, fields, mysql ) ;

	if ( ! rows ) {

		new query [ 256 ] ;

		for ( new i; i < MAX_ATTACHMENTS; i ++ ) {

			mysql_format ( mysql, query, sizeof ( query ), "INSERT INTO attachments (attach_character_id, attach_character_index, attach_character_array, attach_character_attach_id) VALUES (%d, %d, -1, %d)", 
				Character [ playerid ] [ character_id], i, i ) ;

			mysql_tquery ( mysql, query ) ;
		}

		printf("[ATTACHMENTS] %s (%d) returned 0 rows. Stored attachment data.", ReturnUserName ( playerid, false ), playerid ) ;
	}

	if ( rows ) {

		for ( new i; i < rows; i ++ ) {

			new id;

			id = cache_get_field_int (i, "attach_character_attach_id" ) ;
			PlayerAttachments [ playerid ] [ id ] [ attach_character_id ]  = cache_get_field_content_int (i, "attach_character_id" ) ;
			PlayerAttachments [ playerid ] [ id ] [ attach_character_attach_id ]  = id ;
			PlayerAttachments [ playerid ] [ id ] [ attach_character_index ] = cache_get_field_content_int (i, "attach_character_index" ) ;
			PlayerAttachments [ playerid ] [ id ] [ attach_character_array ] = cache_get_field_content_int (i, "attach_character_array" ) ;
			PlayerAttachments [ playerid ] [ id ] [ attach_character_bone ] = cache_get_field_content_int (i, "attach_character_bone" ) ;

			PlayerAttachments [ playerid ] [ id ] [ attach_character_offsety ] = 0.0 ;

			PlayerAttachments [ playerid ] [ id ] [ attach_character_offsetx ] = cache_get_field_content_float (i, "attach_character_offsetx", mysql ) ;
			PlayerAttachments [ playerid ] [ id ] [ attach_character_offsety ] = cache_get_field_content_float (i, "attach_character_offsety", mysql ) ;
			PlayerAttachments [ playerid ] [ id ] [ attach_character_offsetz ] = cache_get_field_content_float (i, "attach_character_offsetz", mysql ) ;

			PlayerAttachments [ playerid ] [ id ] [ attach_character_rotx ] = cache_get_field_content_float (i, "attach_character_rotx", mysql ) ;
			PlayerAttachments [ playerid ] [ id ] [ attach_character_roty ] = cache_get_field_content_float (i, "attach_character_roty", mysql ) ;
			PlayerAttachments [ playerid ] [ id ] [ attach_character_rotz ] = cache_get_field_content_float (i, "attach_character_rotz", mysql ) ;

			PlayerAttachments [ playerid ] [ id ] [ attach_character_scalex ] = cache_get_field_content_float (i, "attach_character_scalex", mysql ) ;
			PlayerAttachments [ playerid ] [ id ] [ attach_character_scaley ] = cache_get_field_content_float (i, "attach_character_scaley", mysql ) ;
			PlayerAttachments [ playerid ] [ id ] [ attach_character_scalez ] = cache_get_field_content_float (i, "attach_character_scalez", mysql ) ;

			PlayerAttachments [ playerid ] [ id ] [ attach_character_visible ] = cache_get_field_content_int (i, "attach_character_visible" ) ;

			if ( PlayerAttachments [ playerid ] [ id ] [ attach_character_visible ] && PlayerAttachments [ playerid ] [ id ] [ attach_character_array ] != -1 ) {

				SetPlayerAttachedObject(playerid, PlayerAttachments [ playerid ] [ id ] [ attach_character_index ], Attachments [ PlayerAttachments [ playerid ] [ id ] [ attach_character_array ] ] [ attach_model ], PlayerAttachments [ playerid ] [ id ] [ attach_character_bone ],
					PlayerAttachments [ playerid ] [ id ] [ attach_character_offsetx ], PlayerAttachments [ playerid ] [ id ] [ attach_character_offsety ], PlayerAttachments [ playerid ] [ id ] [ attach_character_offsetz ],
					PlayerAttachments [ playerid ] [ id ] [ attach_character_rotx ], PlayerAttachments [ playerid ] [ id ] [ attach_character_roty ], PlayerAttachments [ playerid ] [ id ] [ attach_character_rotz ],
					PlayerAttachments [ playerid ] [ id ] [ attach_character_scalex ], PlayerAttachments [ playerid ] [ id ] [ attach_character_scaley ], PlayerAttachments [ playerid ] [ id ] [ attach_character_scalez ] ) ;
			}

			printf ("Loaded attachment for %s.  Attach ID: %i - Attach Index: %i - Attach Array: %i - Attach Bone: %i", 
				ReturnUserName ( playerid, true ), id, PlayerAttachments [ playerid ] [ id ] [ attach_character_index ], PlayerAttachments [ playerid ] [ id ] [ attach_character_array ], PlayerAttachments [ playerid ] [ id ] [ attach_character_bone ] ) ;
		}
	}

	else {

		printf("No Player Attachments loaded for %s.", ReturnUserName ( playerid, true ) ) ;
	}

	return true ;
}

IsPlayerAttachmentVisible(playerid,slotid) return PlayerAttachments [ playerid ] [ slotid ] [ attach_character_visible ];
GetPlayerAttachmentModel(playerid,slotid) {

	if(PlayerAttachments [ playerid ] [ slotid ] [ attach_character_array ] != -1) {

		return Attachments [ PlayerAttachments [ playerid ] [ slotid ] [ attach_character_array ] ] [ attach_model ];
	}
	return -1;
}

GetPlayerAttachThermInfo(playerid,slotid) {

	if(PlayerAttachments [ playerid ] [ slotid ] [ attach_character_array ] != -1) {

		return Attachments [ PlayerAttachments [ playerid ] [ slotid ] [ attach_character_array ] ] [ attach_thermal_info ];
	}
	return -1;	
}