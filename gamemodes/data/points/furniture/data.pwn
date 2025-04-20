#if defined _inc_data
	#undef _inc_data
#endif

enum E_FURNI_INFO
{
	furniture_model_id,
	furniture_name[MAX_FURNITURE_NAME]
}

new ConstructionFurniture[][E_FURNI_INFO] = 
{
	//Doors
	{1495,"Screen Door"},{1501,"Old Screen Door"},{1535,"Pink Door"},{1497,"Farm Door"},{1492,"Moveable Green Door"},{1494,"Moveable Brown Door"},{1499,"Moveable Metal Door"},
	//Walls
	{19353,"Wall Piece"},{19426,"Small Wall Piece"},{19383,"Door Wall Piece"},{19399,"Window Wall Piece"},{19445,"Long Wall Piece"}
};

new FurnitureOverview[][E_FURNI_INFO] = 
{
	{18635,"Construction"},{19996,"House Furniture"},{18631,"Other"}
};

new HouseFurniture[][E_FURNI_INFO] = 
{
	//Beds
	{1771,"Single Bed 1"},{1812,"Single Bed 2"},{1801,"Double Bed"},
	//Chairs & Couches
	{1811,"Wooden Chair"},{19996,"Fold Out Chair"},{2121,"Red Chair"},{2096,"Rocking Chair"},{1280,"Wooden Bench"},
	//Tables
	{2370,"Wooden Coffee Table 1"},{1814,"Wooden Coffe Table 2"},{2115,"Wooden Table 1"},{2115,"Wooden Table 2"},{2111,"Round Wooden Table"},{1770,"Kitchen Table"}
};

new OtherFurniture[][E_FURNI_INFO] = 
{
	{1744,"Wooden Shelf"},{1421,"Boxes"},{19921,"Toolbox"},{19915,"Stove"},{1738,"Heater"},{1510,"Ashtray"},{1736,"Deer Head Trophy"},{19847,"Smoked Leg"},{2804,"Piece of Meat"},{19638,"Box of Oranges"},
	{19574,"Orange"},{19636,"Box of Red Apples"},{19575,"Red Apple"},{19637,"Box of Green Apples"},{19576,"Green Apple"},{19823,"\"Big Cock\" Whiskey"},{1544,"Yellow Beer Bottle"},{1486,"Green Beer Bottle"},
	{1512,"Green Whiskey Bottle"}
};

enum E_FURNI_TEXTURE_INFO
{
	furniture_texture_modelid,
	furniture_texture_name[36],
	furniture_texture_txd_name[36],
	furniture_texture_texture_name[36]
}

new FurnitureMaterialInfo[][E_FURNI_TEXTURE_INFO] = 
{
	//concrete
	{18202,"Concrete 1", "w_towncs_t", "concretebig4256128"},
	{5134,"Concrete 2", "wasteland_las2", "concretenewb256"},
	{9495,"Concrete 3", "vict_sfw", "concretebigb256128"},
	//metal
	{1676,"Shiny Metal 1", "wshxrefpump", "metalic128"},
	{8572,"Shiny Metal 2", "vgssstairs1", "metalic_64"},
	{18202,"Rusty Metal 1","w_towncs_t","pax256hi"},
	{8556,"Rusty Metal 2", "vgsehseing1", "Metalox64"},
	{10789,"Blue Metal 1", "xenon_sfse", "bluemetal02"},
	{8494,"Blue Metal 2", "vgslowbuild1", "bluemetal"},
	{9680,"Shed Metal 1", "tramstatsfw", "ws_corr_metal1"},
	{5775,"Shed Metal 2", "sunset01_lawn", "ws_corr_metal2"},
	//walls
	{19426,"Wall 1","all_walls","711_walltemp"},
	{19426,"Wall 2","all_walls","ab_clubloungewall"},
	{19426,"Wall 3","all_walls","ab_corwallupr"},
	{19426,"Wall 4","all_walls","carp11s"},
	{19426,"Wall 5","all_walls","gym_floor5"},
	{19426,"Wall 6","all_walls","motel_wall3"},
	{19426,"Wall 7","all_walls","mp_burn_ceiling"},
	{19426,"Wall 8","all_walls","mp_carter_bwall"},
	//wood
	{1219,"Wood 1","woodpanels","planks01"},
	{18229,"Wood 2", "woodycs_t", "fence1"},
	{8870,"Wood 3", "vgsecnstrct03", "Gen_Scaffold_Wood_Under"},
	{17009,"Wood 4", "truth_farm", "des_ghotwood1"},
	{12911,"Wood 5", "sw_farm1", "sw_barnwood4"},
	{12937,"Wood 6", "sw_oldshack", "sw_woodflloorsplat"},
	{12938,"Wood 7", "sw_apartments", "sw_woodflloor"},
	{11631,"Wood 8", "mp_ranchcut", "CJ_SLATEDWOOD"}
};

enum E_FURN_OBJ_HANDLE {

	furn_object_db_id[MAX_FURNITURE_LIMIT],
	furn_object_handler[MAX_FURNITURE_LIMIT],
	furn_object_point_id[MAX_FURNITURE_LIMIT],
	furn_object_vanilla[MAX_FURNITURE_LIMIT]
}

new FurnitureObject[MAX_POINTS][E_FURN_OBJ_HANDLE];

enum E_FURN_BUILD_INFO {

	furn_builder_mode,
	furn_builder_add_obj_handler,
	furn_builder_edit_obj_handler,
	furn_builder_edit_obj_db_id,
	furn_builder_edit_mat_index,
	furn_builder_edit_td_count
}

new FurnitureBuilder[MAX_PLAYERS][E_FURN_BUILD_INFO];

enum E_FURN_SELECT_INFO {

	furn_view_id[MAX_FURNITURE_LIMIT],
	DynamicText3D:furn_view_3d_text_label[MAX_FURNITURE_LIMIT]
}

new FurnitureViewer[MAX_PLAYERS][E_FURN_SELECT_INFO];

#include "data/points/furniture/gui.pwn"

public OnPlayerConnect(playerid)
{
	for(new i=0; i<MAX_FURNITURE_LIMIT; i++) {

		FurnitureViewer[playerid][furn_view_id][i] = -1;
		if(IsValidDynamic3DTextLabel(FurnitureViewer[playerid][furn_view_3d_text_label][i])) { DestroyDynamic3DTextLabel(FurnitureViewer[playerid][furn_view_3d_text_label][i]); }
	}
	FurnitureBuilder[playerid][furn_builder_mode] = -1;
	if(IsValidDynamicObject(FurnitureBuilder[playerid][furn_builder_add_obj_handler])) { DestroyDynamicObject(FurnitureBuilder[playerid][furn_builder_add_obj_handler]); }
	if(IsValidDynamicObject(FurnitureBuilder[playerid][furn_builder_edit_obj_handler])) { DestroyDynamicObject(FurnitureBuilder[playerid][furn_builder_edit_obj_handler]); }
	FurnitureBuilder[playerid][furn_builder_edit_obj_db_id] = -1;
	FurnitureBuilder[playerid][furn_builder_edit_mat_index] = -1;
	FurnitureBuilder[playerid][furn_builder_edit_td_count] = -1;

	LoadPlayerFurnTextureTD(playerid);
	#if defined furni_OnPlayerConnect
		return furni_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect furni_OnPlayerConnect
#if defined furni_OnPlayerConnect
	forward furni_OnPlayerConnect(playerid);
#endif

Init_Furniture(pointid = -1) {

	new enumid;
	if(pointid == -1) {

		ResetFurnitureObjectHandlers();
		inline func_LoadFurni() {

			new rows, fields;
			cache_get_data(rows,fields,mysql);

			if(rows) {

				for(new i=0; i<rows; i++) {

					new tmp_id,tmp_point_id,tmp_model_id,Float:tmp_x_pos,Float:tmp_y_pos,Float:tmp_z_pos,Float:tmp_rx_pos,Float:tmp_ry_pos,Float:tmp_rz_pos,tmp_interior_id,tmp_vw_id,tmp_vanilla;

					tmp_id = cache_get_field_content_int(i,"furniture_id");
					tmp_point_id = cache_get_field_content_int(i,"furniture_point_id");
					tmp_model_id = cache_get_field_content_int(i,"furniture_model_id");
					tmp_x_pos = cache_get_field_content_float(i,"furniture_x_pos");
					tmp_y_pos = cache_get_field_content_float(i,"furniture_y_pos");
					tmp_z_pos = cache_get_field_content_float(i,"furniture_z_pos");
					tmp_rx_pos = cache_get_field_content_float(i,"furniture_rx_pos");
					tmp_ry_pos = cache_get_field_content_float(i,"furniture_ry_pos");
					tmp_rz_pos = cache_get_field_content_float(i,"furniture_rz_pos");
					tmp_interior_id = cache_get_field_content_int(i,"furniture_interior_id");
					tmp_vw_id = cache_get_field_content_int(i,"furniture_vw_id");
					tmp_vanilla = cache_get_field_content_int(i,"furniture_vanilla");

					for(new j=0; j<MAX_POINTS; j++) {

						if(Point[j][point_id] == tmp_point_id) {

							enumid = j;
							break;
						}
					}

					FurnitureObject[enumid][furn_object_db_id][i] = tmp_id;
					FurnitureObject[enumid][furn_object_handler][i] = CreateDynamicObject(tmp_model_id,tmp_x_pos,tmp_y_pos,tmp_z_pos,tmp_rx_pos,tmp_ry_pos,tmp_rz_pos,tmp_vw_id,tmp_interior_id);
					Streamer_ToggleItemStatic(STREAMER_TYPE_OBJECT,FurnitureObject[enumid][furn_object_handler][i],true);
					FurnitureObject[enumid][furn_object_point_id][i] = tmp_point_id;
					FurnitureObject[enumid][furn_object_vanilla][i] = tmp_vanilla;

					if(!tmp_vanilla) {

						new query[128];
						inline func_LoadFurniEx() {

							new rows1,fields1;
							cache_get_data(rows1,fields1,mysql);

							if(rows1) {

								for(new j=0; j<rows1; j++) {

									new material_index,model_id,txd_name[MAX_FURNITURE_NAME],texture_name[MAX_FURNITURE_NAME],material_color;
									material_index = cache_get_field_content_int(j,"furniture_ex_material_index");
									model_id = cache_get_field_content_int(j,"furniture_ex_model_id");
									cache_get_field_content(j,"furniture_ex_txd_name",txd_name,MAX_FURNITURE_NAME);
									cache_get_field_content(j,"furniture_ex_texture_name",texture_name,MAX_FURNITURE_NAME);
									material_color = cache_get_field_content_int(j,"furniture_ex_color");

									if(!material_color) { SetDynamicObjectMaterial(FurnitureObject[enumid][furn_object_handler][i], material_index, model_id, txd_name, texture_name); }
									else { SetDynamicObjectMaterial(FurnitureObject[enumid][furn_object_handler][i], material_index, model_id, txd_name, texture_name, material_color); }
								}
							}
							else {

								mysql_format(mysql,query,sizeof(query),"UPDATE furniture SET furniture_vanilla = 1 WHERE furniture_id = %d",tmp_id);
								mysql_tquery(mysql,query);
								continue;
							}
						}
						mysql_format(mysql,query,sizeof(query),"SELECT * FROM furniture_extra WHERE furniture_ex_id = %d",tmp_id);
						mysql_tquery_inline(mysql,query,using inline func_LoadFurniEx,"");
					}
				}
			}
		}
		mysql_tquery_inline(mysql,"SELECT * FROM furniture",using inline func_LoadFurni,"");
	}
	else {

		new query[128];
		for(new i=0; i<MAX_POINTS; i++) {

			if(Point[i][point_id] == pointid) {

				ResetFurnitureObjectHandlers(i);
				enumid = i;
				break;
			}
		}
		inline func_LoadSFurn() {

			new rows, fields;
			cache_get_data(rows,fields,mysql);

			if(rows) {

				for(new i=0; i<rows; i++) {

					new tmp_id,tmp_model_id,Float:tmp_x_pos,Float:tmp_y_pos,Float:tmp_z_pos,Float:tmp_rx_pos,Float:tmp_ry_pos,Float:tmp_rz_pos,tmp_interior_id,tmp_vw_id,tmp_vanilla;

					tmp_id = cache_get_field_content_int(i,"furniture_id");
					tmp_model_id = cache_get_field_content_int(i,"furniture_model_id");
					tmp_x_pos = cache_get_field_content_float(i,"furniture_x_pos");
					tmp_y_pos = cache_get_field_content_float(i,"furniture_y_pos");
					tmp_z_pos = cache_get_field_content_float(i,"furniture_z_pos");
					tmp_rx_pos = cache_get_field_content_float(i,"furniture_rx_pos");
					tmp_ry_pos = cache_get_field_content_float(i,"furniture_ry_pos");
					tmp_rz_pos = cache_get_field_content_float(i,"furniture_rz_pos");
					tmp_interior_id = cache_get_field_content_int(i,"furniture_interior_id");
					tmp_vw_id = cache_get_field_content_int(i,"furniture_vw_id");
					tmp_vanilla = cache_get_field_content_int(i,"furniture_vanilla");

					FurnitureObject[enumid][furn_object_db_id][i] = tmp_id;
					FurnitureObject[enumid][furn_object_handler][i] = CreateDynamicObject(tmp_model_id,tmp_x_pos,tmp_y_pos,tmp_z_pos,tmp_rx_pos,tmp_ry_pos,tmp_rz_pos,tmp_vw_id,tmp_interior_id);
					Streamer_ToggleItemStatic(STREAMER_TYPE_OBJECT,FurnitureObject[enumid][furn_object_handler][i],true);
					FurnitureObject[enumid][furn_object_point_id][i] = pointid;
					FurnitureObject[enumid][furn_object_vanilla][i] = tmp_vanilla;

					if(!tmp_vanilla) {

						inline func_LoadFurniEx() {

							new rows1,fields1;
							cache_get_data(rows1,fields1,mysql);

							if(rows1) {

								for(new j=0; j<rows1; j++) {

									new material_index,model_id,txd_name[MAX_FURNITURE_NAME],texture_name[MAX_FURNITURE_NAME],material_color;
									material_index = cache_get_field_content_int(j,"furniture_ex_material_index");
									model_id = cache_get_field_content_int(j,"furniture_ex_model_id");
									cache_get_field_content(j,"furniture_ex_txd_name",txd_name,MAX_FURNITURE_NAME);
									cache_get_field_content(j,"furniture_ex_texture_name",texture_name,MAX_FURNITURE_NAME);
									material_color = cache_get_field_content_int(j,"furniture_ex_color");

									if(!material_color) { SetDynamicObjectMaterial(FurnitureObject[enumid][furn_object_handler][i], material_index, model_id, txd_name, texture_name); }
									else { SetDynamicObjectMaterial(FurnitureObject[enumid][furn_object_handler][i], material_index, model_id, txd_name, texture_name, material_color); }
								}
							}
							else {

								mysql_format(mysql,query,sizeof(query),"UPDATE furniture SET furniture_vanilla = 1 WHERE furniture_id = %d",tmp_id);
								mysql_tquery(mysql,query);
								continue;
							}
						}
						mysql_format(mysql,query,sizeof(query),"SELECT * FROM furniture_extra WHERE furniture_ex_id = %d",tmp_id);
						mysql_tquery_inline(mysql,query,using inline func_LoadFurniEx,"");
					}
				}
			}
		}
		mysql_format(mysql,query,sizeof(query),"SELECT * FROM furniture WHERE furniture_point_id = %d",pointid);
		mysql_tquery_inline(mysql,query,using inline func_LoadSFurn,"");
	}
}

ResetFurnitureObjectHandlers(pointid = -1) {

	if(pointid == -1) {

		for(new i=0; i<MAX_POINTS; i++) {

			for(new j=0; j<MAX_FURNITURE_LIMIT; j++) {
				
				FurnitureObject[i][furn_object_db_id][j] = -1;
				if(IsValidDynamicObject(FurnitureObject[i][furn_object_handler][j])) { DestroyDynamicObject(FurnitureObject[i][furn_object_handler][j]); }
				FurnitureObject[i][furn_object_handler][j] = -1;
				FurnitureObject[i][furn_object_vanilla][j] = -1;
			}
		}
	}
	else {

		if(Point[pointid][point_id] != -1) {
			
			for(new i=0; i<MAX_FURNITURE_LIMIT; i++) {
					
				FurnitureObject[pointid][furn_object_db_id][i] = -1;
				if(IsValidDynamicObject(FurnitureObject[pointid][furn_object_handler][i])) { DestroyDynamicObject(FurnitureObject[pointid][furn_object_handler][i]); }
				FurnitureObject[pointid][furn_object_handler][i] = -1;
				FurnitureObject[pointid][furn_object_vanilla][i] = -1;
			}
		}
	}
	return true;
}