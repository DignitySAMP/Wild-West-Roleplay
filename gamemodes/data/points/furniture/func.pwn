#if defined _inc_func
	#undef _inc_func
#endif

AddFurniture(playerid,pointid) {

	if(Character[playerid][character_handmoney] <= 0) {

		if(Character[playerid][character_handchange] < 25) {

			SendServerMessage(playerid,"You need at least $0.25 to buy furniture.",MSG_TYPE_ERROR);
			return false;
		}
	}
	if(GetCharacterPointID(playerid) == pointid) {

		if(GetPointFurnitureCount(pointid) >= MAX_FURNITURE_LIMIT) { 

			SendServerMessage(playerid,"You're at the furniture limit (100), you cannot add anymore furniture.",MSG_TYPE_ERROR);
			return false;
		}

		resetDialog:

		new output[512], string[128];
		output[0] = string[0] = EOS;
		for(new i=0; i<sizeof(FurnitureOverview); i++) {

			format(string,sizeof(string),"%d\t%s\n",FurnitureOverview[i][furniture_model_id],FurnitureOverview[i][furniture_name]);
			strcat(output,string);
		}

		inline FurnOverviewDialog(pid, dialogid, response, listitem, string:inputtext[] ) { 
			
			#pragma unused pid, dialogid, inputtext

			if(!response) { return false; }

			output[0] = string[0] = EOS;
			switch(listitem) {

				case 0: { //construction

					for(new i=0; i<sizeof(ConstructionFurniture); i++) {

						format(string,sizeof(string),"%d\t%s\n",ConstructionFurniture[i][furniture_model_id],ConstructionFurniture[i][furniture_name]);
						strcat(output,string);
					}

					inline ConsFurnSelect(pid1, dialogid1, response1, listitem1, string:inputtext1[] ) { 
			
						#pragma unused pid1, dialogid1, inputtext1

						if(!response1) { goto resetDialog; }

						new Float:x, Float:y, Float:dummy;

						GetPlayerPos(playerid,x,y,dummy);
						GetXYInFrontOfPlayer(playerid,x,y,2.5);

						FurnitureBuilder[playerid][furn_builder_mode] = FURNI_BUY;
						FurnitureBuilder[playerid][furn_builder_add_obj_handler] = CreateDynamicObject(ConstructionFurniture[listitem1][furniture_model_id],x,y,dummy,0.0,0.0,0.0,GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid));

						EditDynamicObject(playerid,FurnitureBuilder[playerid][furn_builder_add_obj_handler]);
						SendServerMessage(playerid,"Press \"ESC\" to cancel furniture placement.  Press the save icon to confirm placement and purchase of furniture.",MSG_TYPE_INFO);
					}
					Dialog_ShowCallback(playerid,using inline ConsFurnSelect,DIALOG_STYLE_PREVIEW_MODEL,"Construction Furniture (All furniture costs $0.25)",output,"Select","Exit");
				}
				case 1: { //house

					for(new i=0; i<sizeof(HouseFurniture); i++) {

						format(string,sizeof(string),"%d\t%s\n",HouseFurniture[i][furniture_model_id],HouseFurniture[i][furniture_name]);
						strcat(output,string);
					}

					inline HousFurnSelect(pid1, dialogid1, response1, listitem1, string:inputtext1[] ) { 
			
						#pragma unused pid1, dialogid1, inputtext1

						if(!response1) { goto resetDialog; }

						new Float:x, Float:y, Float:dummy;

						GetPlayerPos(playerid,x,y,dummy);
						GetXYInFrontOfPlayer(playerid,x,y,2.5);

						FurnitureBuilder[playerid][furn_builder_mode] = FURNI_BUY;
						FurnitureBuilder[playerid][furn_builder_add_obj_handler] = CreateDynamicObject(HouseFurniture[listitem1][furniture_model_id],x,y,dummy,0.0,0.0,0.0,GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid));

						EditDynamicObject(playerid,FurnitureBuilder[playerid][furn_builder_add_obj_handler]);
						SendServerMessage(playerid,"Press \"ESC\" to cancel furniture placement.  Press the save icon to confirm placement and purchase of furniture.",MSG_TYPE_INFO);
					}
					Dialog_ShowCallback(playerid,using inline HousFurnSelect,DIALOG_STYLE_PREVIEW_MODEL,"House Furniture (All furniture costs $0.25)",output,"Select","Exit");
				}
				case 2: { //other

					for(new i=0; i<sizeof(OtherFurniture); i++) {

						format(string,sizeof(string),"%d\t%s\n",OtherFurniture[i][furniture_model_id],OtherFurniture[i][furniture_name]);
						strcat(output,string);
					}

					inline OtheFurnSelect(pid1, dialogid1, response1, listitem1, string:inputtext1[] ) { 
			
						#pragma unused pid1, dialogid1, inputtext1

						if(!response1) { goto resetDialog; }

						new Float:x, Float:y, Float:dummy;

						GetPlayerPos(playerid,x,y,dummy);
						GetXYInFrontOfPlayer(playerid,x,y,2.5);

						FurnitureBuilder[playerid][furn_builder_mode] = FURNI_BUY;
						FurnitureBuilder[playerid][furn_builder_add_obj_handler] = CreateDynamicObject(OtherFurniture[listitem1][furniture_model_id],x,y,dummy,0.0,0.0,0.0,GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid));

						EditDynamicObject(playerid,FurnitureBuilder[playerid][furn_builder_add_obj_handler]);
						SendServerMessage(playerid,"Press \"ESC\" to cancel furniture placement.  Press the save icon to confirm placement and purchase of furniture.",MSG_TYPE_INFO);
					}
					Dialog_ShowCallback(playerid,using inline OtheFurnSelect,DIALOG_STYLE_PREVIEW_MODEL,"Other Furniture (All furniture costs $0.25)",output,"Select","Exit");
				}
			}
		}
		Dialog_ShowCallback(playerid, using inline FurnOverviewDialog, DIALOG_STYLE_PREVIEW_MODEL, "Furniture - Pick A Catagory (All furniture costs $0.25)", output, "Select", "Exit" ) ;
	}
	else {

		SendServerMessage(playerid,"Something went wrong, try again later.",MSG_TYPE_ERROR);
		return false;
	}
	return true;
}

EditFurniture(playerid,pointid) {

	if(GetCharacterPointID(playerid) == pointid) {

		inline FurnEditDialog(pid, dialogid, response, listitem, string:inputtext[] ) {

			#pragma unused pid,dialogid,inputtext

			if(!response) { return cmd_point(playerid,"furni"); }

			if(listitem == 0) { //placement

				FurnitureBuilder[playerid][furn_builder_mode] = FURNI_EDIT;
				SetFurnitureViewerInfo(playerid);
				SelectObject(playerid);
				SendServerMessage(playerid,"Select the furniture object you want to move.",MSG_TYPE_INFO);
			}
			else if(listitem == 1) { //texture

				FurnitureBuilder[playerid][furn_builder_mode] = FURNI_EDIT_TEXTURE;
				SetFurnitureViewerInfo(playerid);
				SelectObject(playerid);
				SendServerMessage(playerid,"Select the furniture object you want to edit.",MSG_TYPE_INFO);
			}
		}
		Dialog_ShowCallback(playerid,using inline FurnEditDialog,DIALOG_STYLE_LIST,"Edit Furniture - Select Edit Type","Furniture Placement\nFurniture Texture","Select","Exit"); 
	}
	return true;
}

RemoveFurniture(playerid,pointid) {

	if(GetCharacterPointID(playerid) == pointid) {
		
		FurnitureBuilder[playerid][furn_builder_mode] = FURNI_DELETE;
		SetFurnitureViewerInfo(playerid);
		SelectObject(playerid);
		SendServerMessage(playerid,"Click on the furniture object you wish to delete.",MSG_TYPE_INFO);
	}
	return true;
}

CMD:editfurnitureobject(playerid,params[]) {

	if(FurnitureBuilder[playerid][furn_builder_mode] == FURNI_EDIT || FurnitureBuilder[playerid][furn_builder_mode] == FURNI_EDIT_TEXTURE) {

		new furn_id;
		if(sscanf(params,"d",furn_id)) { return SendServerMessage(playerid,"Syntax: /editfurni(ture)object [id]",MSG_TYPE_ERROR); }

		if(furn_id < 0) { return SendServerMessage(playerid,"Furniture IDs cannot be negative.",MSG_TYPE_ERROR); }

		for(new i=0; i<MAX_FURNITURE_LIMIT; i++) {

			if(FurnitureObject[GetCharacterPointID(playerid)][furn_object_db_id][i] == furn_id) {

				if(FurnitureObject[GetCharacterPointID(playerid)][furn_object_point_id][i] == Point[GetCharacterPointID(playerid)][point_id]) {

					if(FurnitureBuilder[playerid][furn_builder_mode] == FURNI_EDIT) {

						FurnitureBuilder[playerid][furn_builder_edit_obj_handler] = FurnitureObject[GetCharacterPointID(playerid)][furn_object_handler][i];
						FurnitureBuilder[playerid][furn_builder_edit_obj_db_id] = FurnitureObject[GetCharacterPointID(playerid)][furn_object_db_id][i];
						ResetFurnitureViewerInfo(playerid);
						EditDynamicObject(playerid, FurnitureBuilder[playerid][furn_builder_edit_obj_handler]);
						return SendServerMessage(playerid,"Move the furniture object and click the \"Save\" icon to save its placement.",MSG_TYPE_INFO);
					}

					else if(FurnitureBuilder[playerid][furn_builder_mode] == FURNI_EDIT_TEXTURE) {

						new string[512];
						ResetFurnitureViewerInfo(playerid);
						CancelEdit(playerid);

						for(new j=0; j<15; j++) {

							format(string,sizeof(string),"%sMaterial Index %d\n",string,j);
						}

						inline FurnTexEdit(pid, dialogid, response, listitem, string:inputtext[] ) { 

							#pragma unused pid,dialogid,inputtext

							if(!response) {

								FurnitureBuilder[playerid][furn_builder_mode] = -1;
								return cmd_point(playerid,"furni");
							}

							FurnitureBuilder[playerid][furn_builder_edit_mat_index] = listitem;
							FurnitureBuilder[playerid][furn_builder_edit_td_count] = 0;
							FurnitureBuilder[playerid][furn_builder_edit_obj_handler] = FurnitureObject[GetCharacterPointID(playerid)][furn_object_handler][i];
							FurnitureBuilder[playerid][furn_builder_edit_obj_db_id] = FurnitureObject[GetCharacterPointID(playerid)][furn_object_db_id][i];
							SetDynamicObjectMaterial(FurnitureBuilder[playerid][furn_builder_edit_obj_handler],FurnitureBuilder[playerid][furn_builder_edit_mat_index],FurnitureMaterialInfo[0][furniture_texture_modelid],FurnitureMaterialInfo[0][furniture_texture_txd_name],FurnitureMaterialInfo[0][furniture_texture_texture_name]);
							ShowTextureEditTD(playerid);
							SelectTextDraw(playerid,0xFFFFFF55);
							return true;
						}
						return Dialog_ShowCallback(playerid,using inline FurnTexEdit,DIALOG_STYLE_LIST,"Furniture Edit - Material Indexes",string,"Select","Exit");
					}
				}
			}
		}
		return SendServerMessage(playerid,"You've either entered a invalid furniture ID or you entered a furniture ID that has a different point ID.",MSG_TYPE_ERROR);
	}
	else { SendServerMessage(playerid,"You can only use this command when editing a furniture object's placement or texture.",MSG_TYPE_ERROR); }
	return true;
}
CMD:editfurniobject(playerid,params[]) { return cmd_editfurnitureobject(playerid,params); }

CMD:removefurnitureobject(playerid,params[]) {

	if(FurnitureBuilder[playerid][furn_builder_mode] == FURNI_DELETE) {

		new furn_id;
		if(sscanf(params,"d",furn_id)) { return SendServerMessage(playerid,"Syntax: /removefurni(ture)object [id]",MSG_TYPE_ERROR); }

		if(furn_id < 0) { return SendServerMessage(playerid,"Furniture IDs cannot be negative.",MSG_TYPE_ERROR); }

		for(new i=0; i<MAX_FURNITURE_LIMIT; i++) {

			if(FurnitureObject[GetCharacterPointID(playerid)][furn_object_db_id][i] == furn_id) {

				if(FurnitureObject[GetCharacterPointID(playerid)][furn_object_point_id][i] == Point[GetCharacterPointID(playerid)][point_id]) {

					ResetFurnitureViewerInfo(playerid);
					CancelEdit(playerid);
					inline DeleteFurnWarn(pid, dialogid, response, listitem, string:inputtext[] ) { 

						#pragma unused pid,dialogid,listitem,inputtext

						if(!response) {

							FurnitureBuilder[playerid][furn_builder_mode] = -1;
							SendServerMessage(playerid,"You've cancelled removing a furniture object.",MSG_TYPE_WARN);
							return cmd_point(playerid,"furni");
						}

						new query[128];

						mysql_format(mysql,query,sizeof(query),"DELETE FROM furniture WHERE furniture_id = %d",FurnitureObject[GetCharacterPointID(playerid)][furn_object_db_id][i]);
						mysql_tquery(mysql,query);
						mysql_format(mysql,query,sizeof(query),"DELETE FROM furniture_extra WHERE furniture_ex_id = %d",FurnitureObject[GetCharacterPointID(playerid)][furn_object_db_id][i]);
						mysql_tquery(mysql,query);

						FurnitureBuilder[playerid][furn_builder_mode] = -1;
						DestroyDynamicObject(FurnitureObject[GetCharacterPointID(playerid)][furn_object_handler][i]);
						Init_Furniture(Point[GetCharacterPointID(playerid)][point_id]);
						SendServerMessage(playerid,"You've successfully deleted a furniture object.",MSG_TYPE_INFO);
					}
					return Dialog_ShowCallback(playerid,using inline DeleteFurnWarn,DIALOG_STYLE_MSGBOX,"Furniture Deletion","WARNING: You've selected a furniture object to delete.\nThis dialog is to prevent accidental deletion of a furniture object.\nIf you're sure about your decision, click \"Confirm\".", "Confirm", "Cancel");
				}
			}
		}
		return SendServerMessage(playerid,"You've either entered a invalid furniture ID or you entered a furniture ID that has a different point ID.",MSG_TYPE_ERROR);
	}
	else { SendServerMessage(playerid,"You can only use this command when removing a furniture object.",MSG_TYPE_ERROR); }
	return true;
}

public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(FurnitureBuilder[playerid][furn_builder_mode] != -1) {

		new query[512],Float:oldX, Float:oldY, Float:oldZ, Float:oldRotX, Float:oldRotY, Float:oldRotZ;
		query[0] = EOS;
		GetDynamicObjectPos(objectid, oldX, oldY, oldZ);
		GetDynamicObjectRot(objectid, oldRotX, oldRotY, oldRotZ);
		if(response == EDIT_RESPONSE_CANCEL) {

			switch(FurnitureBuilder[playerid][furn_builder_mode]) {

				case FURNI_BUY: {

					if(objectid == FurnitureBuilder[playerid][furn_builder_add_obj_handler]) {
						
						FurnitureBuilder[playerid][furn_builder_mode] = -1;
						DestroyDynamicObject(FurnitureBuilder[playerid][furn_builder_add_obj_handler]);
						return AddFurniture(playerid,GetCharacterPointID(playerid));
					}
				}
				case FURNI_EDIT: {

					if(objectid == FurnitureBuilder[playerid][furn_builder_edit_obj_handler]) {
						
						FurnitureBuilder[playerid][furn_builder_mode] = -1;
						SetDynamicObjectPos(FurnitureBuilder[playerid][furn_builder_edit_obj_handler],oldX,oldY,oldZ);
						SetDynamicObjectRot(FurnitureBuilder[playerid][furn_builder_edit_obj_handler],oldRotX,oldRotY,oldRotZ);
						FurnitureBuilder[playerid][furn_builder_edit_obj_handler] = -1;
						return SendServerMessage(playerid,"You cancelled editting your furniture placement.",MSG_TYPE_WARN);
					}
				}
			}
		}
		else if(response == EDIT_RESPONSE_FINAL) {

			switch(FurnitureBuilder[playerid][furn_builder_mode]) {

				case FURNI_BUY: {

					if(objectid == FurnitureBuilder[playerid][furn_builder_add_obj_handler]) {
						
						mysql_format(mysql,query,sizeof(query),"INSERT INTO furniture (furniture_point_id,furniture_model_id,furniture_x_pos,furniture_y_pos,furniture_z_pos,furniture_rx_pos,furniture_ry_pos,furniture_rz_pos,furniture_interior_id,furniture_vw_id,furniture_vanilla) VALUES (%d,%d,'%f','%f','%f','%f','%f','%f',%d,%d,1)", \
							Point[GetCharacterPointID(playerid)][point_id],GetDynamicObjectModel(objectid),x,y,z,rx,ry,rz,GetPlayerInterior(playerid),GetPlayerVirtualWorld(playerid));
						mysql_tquery(mysql,query);

						TakeCharacterChange(playerid,25,MONEY_SLOT_HAND);
						FurnitureBuilder[playerid][furn_builder_mode] = -1;
						DestroyDynamicObject(FurnitureBuilder[playerid][furn_builder_add_obj_handler]);
						Init_Furniture(Point[GetCharacterPointID(playerid)][point_id]);
						Streamer_Update(playerid,STREAMER_TYPE_OBJECT);
						SendServerMessage(playerid,"You've bought a piece of furniture for $0.25.",MSG_TYPE_INFO);
					}
				}
				case FURNI_EDIT: {

					if(objectid == FurnitureBuilder[playerid][furn_builder_edit_obj_handler]) {
						
						mysql_format(mysql,query,sizeof(query),"UPDATE furniture SET furniture_x_pos = '%f',furniture_y_pos = '%f',furniture_z_pos = '%f',furniture_rx_pos = '%f',furniture_ry_pos = '%f',furniture_rz_pos = '%f' WHERE furniture_id = %d",x,y,z,rx,ry,rz,FurnitureBuilder[playerid][furn_builder_edit_obj_db_id]);
						mysql_tquery(mysql,query);

						FurnitureBuilder[playerid][furn_builder_mode] = -1;
						FurnitureBuilder[playerid][furn_builder_edit_obj_db_id] = -1;						
						DestroyDynamicObject(FurnitureBuilder[playerid][furn_builder_edit_obj_handler]);
						Init_Furniture(Point[GetCharacterPointID(playerid)][point_id]);
						Streamer_Update(playerid,STREAMER_TYPE_OBJECT);
						SendServerMessage(playerid,"You've edited a furniture's placement.",MSG_TYPE_INFO);
					}
				}			
			}
		}
		/*
		else if(response == EDIT_RESPONSE_UPDATE) {

			if(objectid == FurnitureBuilder[playerid][furn_builder_add_obj_handler]) {
				
				SetDynamicObjectPos(objectid,oldX,oldY,oldZ);
				SetDynamicObjectRot(objectid,oldRotX,oldRotY,oldRotZ);
			}
		}
		*/
	}
	#if defined furn_OnPlayerEditDynamicObject
		return furn_OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEditDynamicObject
	#undef OnPlayerEditDynamicObject
#else
	#define _ALS_OnPlayerEditDynamicObject
#endif

#define OnPlayerEditDynamicObject furn_OnPlayerEditDynamicObject
#if defined furn_OnPlayerEditDynamicObject
	forward furn_OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
#endif

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(FurnitureBuilder[playerid][furn_builder_mode] == FURNI_EDIT_TEXTURE) {

		if(_:clickedid == INVALID_TEXT_DRAW) {

			HideTextureEditTD(playerid);
			FurnitureBuilder[playerid][furn_builder_edit_obj_db_id] = -1;
			FurnitureBuilder[playerid][furn_builder_mode] = -1;
			FurnitureBuilder[playerid][furn_builder_edit_mat_index] = -1;
			FurnitureBuilder[playerid][furn_builder_edit_td_count] = -1;
			if(IsValidDynamicObject(FurnitureBuilder[playerid][furn_builder_edit_obj_handler])) { DestroyDynamicObject(FurnitureBuilder[playerid][furn_builder_edit_obj_handler]); }
			FurnitureBuilder[playerid][furn_builder_edit_obj_handler] = -1;

			Init_Furniture(Point[GetCharacterPointID(playerid)][point_id]);
			Streamer_Update(playerid,STREAMER_TYPE_OBJECT);
			CancelSelectTextDraw(playerid);
			cmd_point(playerid,"furni");
			return true;
		}
		else {

			if(clickedid == FurnitureTexturePreview[0]) { //confirm

				new query[512],td_id = FurnitureBuilder[playerid][furn_builder_edit_td_count];

				mysql_format(mysql,query,sizeof(query),"INSERT INTO furniture_extra (furniture_ex_id,furniture_ex_material_index,furniture_ex_model_id,furniture_ex_txd_name,furniture_ex_texture_name) VALUES (%d,%d,%d,'%e','%e')",FurnitureBuilder[playerid][furn_builder_edit_obj_db_id],FurnitureBuilder[playerid][furn_builder_edit_mat_index],FurnitureMaterialInfo[td_id][furniture_texture_modelid],FurnitureMaterialInfo[td_id][furniture_texture_txd_name],FurnitureMaterialInfo[td_id][furniture_texture_texture_name]);
				mysql_tquery(mysql,query);
				mysql_format(mysql,query,sizeof(query),"UPDATE furniture SET furniture_vanilla = 0 WHERE furniture_id = %d",FurnitureBuilder[playerid][furn_builder_edit_obj_db_id]);
				mysql_tquery(mysql,query);

				if(IsValidDynamicObject(FurnitureBuilder[playerid][furn_builder_edit_obj_handler])) { DestroyDynamicObject(FurnitureBuilder[playerid][furn_builder_edit_obj_handler]); }
				FurnitureBuilder[playerid][furn_builder_edit_obj_handler] = -1;
				Init_Furniture(Point[GetCharacterPointID(playerid)][point_id]);
				Streamer_Update(playerid,STREAMER_TYPE_OBJECT);
				HideTextureEditTD(playerid);
				FurnitureBuilder[playerid][furn_builder_edit_obj_db_id] = -1;
				FurnitureBuilder[playerid][furn_builder_mode] = -1;
				FurnitureBuilder[playerid][furn_builder_edit_mat_index] = -1;
				FurnitureBuilder[playerid][furn_builder_edit_td_count] = -1;
				CancelSelectTextDraw(playerid);
				SendServerMessage(playerid,"You've successfully retextured a furniture object.",MSG_TYPE_INFO);
				return true;
			}

			else if(clickedid == FurnitureTexturePreview[1]) { //left

				if(FurnitureBuilder[playerid][furn_builder_edit_td_count] <= 0) { FurnitureBuilder[playerid][furn_builder_edit_td_count] = sizeof(FurnitureMaterialInfo)-1; }
				else { FurnitureBuilder[playerid][furn_builder_edit_td_count]--; }
				PlayerTextDrawSetString(playerid,FurnitureTextureName,FurnitureMaterialInfo[FurnitureBuilder[playerid][furn_builder_edit_td_count]][furniture_texture_name]);
				SetDynamicObjectMaterial(FurnitureBuilder[playerid][furn_builder_edit_obj_handler],FurnitureBuilder[playerid][furn_builder_edit_mat_index],FurnitureMaterialInfo[FurnitureBuilder[playerid][furn_builder_edit_td_count]][furniture_texture_modelid],FurnitureMaterialInfo[FurnitureBuilder[playerid][furn_builder_edit_td_count]][furniture_texture_txd_name],FurnitureMaterialInfo[FurnitureBuilder[playerid][furn_builder_edit_td_count]][furniture_texture_texture_name]);
			}

			else if(clickedid == FurnitureTexturePreview[2]) { //right

				if(FurnitureBuilder[playerid][furn_builder_edit_td_count] >= sizeof(FurnitureMaterialInfo)-1) { FurnitureBuilder[playerid][furn_builder_edit_td_count] = 0; }
				else { FurnitureBuilder[playerid][furn_builder_edit_td_count]++; }
				PlayerTextDrawSetString(playerid,FurnitureTextureName,FurnitureMaterialInfo[FurnitureBuilder[playerid][furn_builder_edit_td_count]][furniture_texture_name]);
				SetDynamicObjectMaterial(FurnitureBuilder[playerid][furn_builder_edit_obj_handler],FurnitureBuilder[playerid][furn_builder_edit_mat_index],FurnitureMaterialInfo[FurnitureBuilder[playerid][furn_builder_edit_td_count]][furniture_texture_modelid],FurnitureMaterialInfo[FurnitureBuilder[playerid][furn_builder_edit_td_count]][furniture_texture_txd_name],FurnitureMaterialInfo[FurnitureBuilder[playerid][furn_builder_edit_td_count]][furniture_texture_texture_name]);
			}

			else if(clickedid == FurnitureTexturePreview[3]) { //cancel

				HideTextureEditTD(playerid);
				FurnitureBuilder[playerid][furn_builder_edit_obj_db_id] = -1;
				FurnitureBuilder[playerid][furn_builder_mode] = -1;
				FurnitureBuilder[playerid][furn_builder_edit_mat_index] = -1;
				FurnitureBuilder[playerid][furn_builder_edit_td_count] = -1;
				if(IsValidDynamicObject(FurnitureBuilder[playerid][furn_builder_edit_obj_handler])) { DestroyDynamicObject(FurnitureBuilder[playerid][furn_builder_edit_obj_handler]); }
				FurnitureBuilder[playerid][furn_builder_edit_obj_handler] = -1;

				Init_Furniture(Point[GetCharacterPointID(playerid)][point_id]);
				Streamer_Update(playerid,STREAMER_TYPE_OBJECT);
				CancelSelectTextDraw(playerid);
				cmd_point(playerid,"furni");
				return true;
			}
		}
	}
	#if defined furn_OnPlayerClickTextDraw
		return furn_OnPlayerClickTextDraw(playerid, Text:clickedid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerClickTextDraw
	#undef OnPlayerClickTextDraw
#else
	#define _ALS_OnPlayerClickTextDraw
#endif

#define OnPlayerClickTextDraw furn_OnPlayerClickTextDraw
#if defined furn_OnPlayerClickTextDraw
	forward furn_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif