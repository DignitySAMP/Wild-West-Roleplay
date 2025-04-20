#include <a_samp>
#include <streamer>

stock Float:GetDistanceBetweenPoints3D(Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2){
    return VectorSize(x1-x2,y1-y2,z1-z2);
}  

public OnFilterScriptInit() {

	PreventMapIconStack();

	return true ;
}

PreventMapIconStack() {

	new MAX_MAP_ICONS = 1024 ;
	new Float: MAX_MAPICON_DIST = 25.0 ;

	new LIMIT_MODEL_ID = 31 ;
	new LAST_EXCEPTION = -1 ;

	new Float: x1, Float: y1, Float: z1 ;
	new Float: x2, Float: y2, Float: z2 ;

	for(new i; i < MAX_MAP_ICONS; i ++){

		if(Streamer_GetIntData(STREAMER_TYPE_MAP_ICON, i, E_STREAMER_TYPE) == LIMIT_MODEL_ID){

			if(LAST_EXCEPTION != -1){

				Streamer_GetFloatData(STREAMER_TYPE_MAP_ICON, i, E_STREAMER_X, x1);
				Streamer_GetFloatData(STREAMER_TYPE_MAP_ICON, i, E_STREAMER_Y, y1);
				Streamer_GetFloatData(STREAMER_TYPE_MAP_ICON, i, E_STREAMER_Z, z1);

				if(IsValidDynamicMapIcon(LAST_EXCEPTION)) {

					Streamer_GetFloatData(STREAMER_TYPE_MAP_ICON, LAST_EXCEPTION, E_STREAMER_X, x2);
					Streamer_GetFloatData(STREAMER_TYPE_MAP_ICON, LAST_EXCEPTION, E_STREAMER_Y, y2);
					Streamer_GetFloatData(STREAMER_TYPE_MAP_ICON, LAST_EXCEPTION, E_STREAMER_Z, z2);

					if(GetDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2) < MAX_MAPICON_DIST){

						Streamer_SetIntData(STREAMER_TYPE_MAP_ICON, i, E_STREAMER_PLAYER_ID, MAX_PLAYERS + 1);
					}

					else continue ;
				}

				else LAST_EXCEPTION = i ;
			}

			else LAST_EXCEPTION = i ;
		}

		else continue ;
	}

	return true ;
}
