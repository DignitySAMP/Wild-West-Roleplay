#define MAX_DYNAMIC_LABELS	(250)

enum {

	DYN_LABEL_INVALID = -1,
	DYN_LABEL_CREATE = 0,
	DYN_LABEL_EDIT,
	DYN_LABEL_DELETE
}

enum E_DYN_LABEL_DATA {

	dynamic_label_id,
	dynamic_label_creator,
	dynamic_label_message[256],
	Float:dynamic_label_x_pos,
	Float:dynamic_label_y_pos,
	Float:dynamic_label_z_pos,
	dynamic_label_interior,
	dynamic_label_vw,
	DynamicText3D:dynamic_label_handler
}
new DynamicLabel[MAX_DYNAMIC_LABELS][E_DYN_LABEL_DATA];
new PlayerLabelRequest[MAX_PLAYERS],PlayerLabelRequestType[MAX_PLAYERS],PlayerLabelRequestMessage[MAX_PLAYERS][256],Float:PlayerLabelPosition[MAX_PLAYERS][3];

public OnPlayerConnect(playerid)
{
	new dummy[256];
	dummy[0] = EOS;
	PlayerLabelRequest[playerid] = 0;
	PlayerLabelRequestType[playerid] = DYN_LABEL_INVALID;
	PlayerLabelRequestMessage[playerid] = dummy;
	PlayerLabelPosition[playerid][0] = PlayerLabelPosition[playerid][1] = PlayerLabelPosition[playerid][2] = 0.0;
	#if defined dynlabels_OnPlayerConnect
		return dynlabels_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect dynlabels_OnPlayerConnect
#if defined dynlabels_OnPlayerConnect
	forward dynlabels_OnPlayerConnect(playerid);
#endif

Init_DynamicLabels() {

	for(new i=0; i<MAX_DYNAMIC_LABELS; i++) {

		DynamicLabel[i][dynamic_label_id] = -1;
		if(IsValidDynamic3DTextLabel(DynamicLabel[i][dynamic_label_handler])) { DestroyDynamic3DTextLabel(DynamicLabel[i][dynamic_label_handler]); }
	}
	LoadDynamicLabels();
	return true;
}

LoadDynamicLabels() {

	inline data_LoadDynLabels() {

		new rows,fields;
		cache_get_data(rows,fields,mysql);

		if(rows) {

			for(new i=0; i<rows; i++) {

				DynamicLabel[i][dynamic_label_id] = cache_get_field_content_int(i,"dynamic_label_id");
				DynamicLabel[i][dynamic_label_creator] = cache_get_field_content_int(i,"dynamic_label_creator");
				cache_get_field_content(i,"dynamic_label_message",DynamicLabel[i][dynamic_label_message],mysql,256);
				DynamicLabel[i][dynamic_label_x_pos] = cache_get_field_content_float(i,"dynamic_label_x_pos");
				DynamicLabel[i][dynamic_label_y_pos] = cache_get_field_content_float(i,"dynamic_label_y_pos");
				DynamicLabel[i][dynamic_label_z_pos] = cache_get_field_content_float(i,"dynamic_label_z_pos");
				DynamicLabel[i][dynamic_label_interior] = cache_get_field_content_int(i,"dynamic_label_interior");
				DynamicLabel[i][dynamic_label_vw] = cache_get_field_content_int(i,"dynamic_label_vw");
				DynamicLabel[i][dynamic_label_handler] = CreateDynamic3DTextLabel(sprintf("{c6c6c6}/inspectlabel{5b3a99}\n(* %d) %s",DynamicLabel[i][dynamic_label_id],DynamicLabel[i][dynamic_label_message]),0x5b3a99FF,DynamicLabel[i][dynamic_label_x_pos],DynamicLabel[i][dynamic_label_y_pos],DynamicLabel[i][dynamic_label_z_pos],15.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,DynamicLabel[i][dynamic_label_vw],DynamicLabel[i][dynamic_label_interior]);
			}
			printf("[DYNAMIC LABELS]: %d %s loaded.",rows,(rows > 1) ? ("labels") : ("label"));
		}
		else { print("[DYNAMIC LABELS]: No labels loaded."); }
	}
	mysql_tquery_inline(mysql,"SELECT * FROM dynamic_labels",using inline data_LoadDynLabels,"");
	return true;
}