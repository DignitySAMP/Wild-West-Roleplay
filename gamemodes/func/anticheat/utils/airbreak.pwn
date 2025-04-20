//----------------------------------------------
//--- Anti AirBreak por: dimmy_scarface/ForT ---
//-----------------09/11/2014-------------------
//----------------------------------------------



#if defined aB_Include
	#endinput
#endif
#define aB_Include



#include <a_samp>
#include <foreach>


#define AIRBREAK_DISTANCIA 	105.0
#define aB_Func:%0(%1)\
		forward %0(%1);public %0(%1)

enum A_B
{
    aB_Aguardo,
	Float:aB_Pos[3],
	Float:aB_SetPos[3],
};

new
	aB_Info[MAX_PLAYERS][A_B]
	;

aB_Func: aB_Timer(){

////	print("aB_Timer called (airbreak.pwn)");

	new
	    aB_SurfVehicle,
	    aB_SurfObject,
	    aB_State,
	    Float:aB_AtualPos[3],
		Float:aB_Range
	;

	foreach(Player, aB_Player){


	    GetPlayerPos(aB_Player, aB_AtualPos[0], aB_AtualPos[1], aB_AtualPos[2]);

	    aB_SurfVehicle 	= GetPlayerSurfingVehicleID(aB_Player);
	    aB_SurfObject 	= GetPlayerSurfingObjectID(aB_Player);
	    aB_State 		= GetPlayerState(aB_Player);
	    aB_Range        = AIRBREAK_DISTANCIA;

	    if(aB_State == PLAYER_STATE_DRIVER || GetPlayerPing(aB_Player) > 500){

	        aB_Range += 45.0;
	    }

	    if(aB_SurfVehicle == INVALID_VEHICLE_ID && aB_SurfObject == INVALID_OBJECT_ID && (aB_State == 1 || aB_State == 2)){

		    if(!IsPlayerInRangeOfPoint(aB_Player, aB_Range, aB_Info[aB_Player][aB_Pos][0], aB_Info[aB_Player][aB_Pos][1], aB_Info[aB_Player][aB_Pos][2])
			&& !IsPlayerInRangeOfPoint(aB_Player, 10.0, aB_Info[aB_Player][aB_SetPos][0], aB_Info[aB_Player][aB_SetPos][1], aB_Info[aB_Player][aB_SetPos][2])){

				if(gettime() > aB_Info[aB_Player][aB_Aguardo])CallLocalFunction("OnPlayerAirBreak", "i", aB_Player);
			}
		}

	    aB_SavePos(aB_Player, aB_AtualPos[0], aB_AtualPos[1], aB_AtualPos[2]);
	}
}

stock aB_SavePos(playerid, Float:x, Float:y, Float:z){

	aB_Info[playerid][aB_Pos][0] = x;
	aB_Info[playerid][aB_Pos][1] = y;
	aB_Info[playerid][aB_Pos][2] = z;

	aB_Info[playerid][aB_Aguardo] = gettime() + 2;
}

aB_Func: aB_SetPlayerPos(playerid, Float:x, Float:y, Float:z){

	aB_SavePos(playerid, x, y, z);

	aB_Info[playerid][aB_SetPos][0] = x;
	aB_Info[playerid][aB_SetPos][1] = y;
	aB_Info[playerid][aB_SetPos][2] = z;

	return SetPlayerPos(playerid, x, y, z);
}

aB_Func: aB_PutPlayerInVehicle(playerid, vehicleid, seatid){

	static
	    Float:aB_VehiclePos[3]
	;

	GetVehiclePos(vehicleid, aB_VehiclePos[0], aB_VehiclePos[1], aB_VehiclePos[2]);

	aB_SavePos(playerid, aB_VehiclePos[0], aB_VehiclePos[1], aB_VehiclePos[2]);

	aB_Info[playerid][aB_SetPos][0] = aB_VehiclePos[0];
	aB_Info[playerid][aB_SetPos][1] = aB_VehiclePos[1];
	aB_Info[playerid][aB_SetPos][2] = aB_VehiclePos[2];

	return PutPlayerInVehicle(playerid, vehicleid, seatid);
}



public OnGameModeInit(){

	SetTimer("aB_Timer", 1000, 1);

	return CallLocalFunction("aB_OnGameModeInit", #);
}
forward aB_OnGameModeInit();
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit aB_OnGameModeInit



public OnPlayerSpawn(playerid){

	aB_Info[playerid][aB_Aguardo] = gettime() + 4;

	return CallLocalFunction("aB_OnPlayerSpawn", "i", playerid);
}
forward aB_OnPlayerSpawn(playerid);
#if defined _ALS_OnPlayerSpawn
	#undef OnPlayerSpawn
#else
	#define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn aB_OnPlayerSpawn


#if defined _ALS_SetPlayerPos
	#undef SetPlayerPos
#else
	#define _ALS_SetPlayerPos
#endif

#if defined _ALS_PutPlayerInVehicle
	#undef PutPlayerInVehicle
#else
	#define _ALS_PutPlayerInVehicle
#endif

#define SetPlayerPos    		aB_SetPlayerPos
#define PutPlayerInVehicle    	aB_PutPlayerInVehicle

forward OnPlayerAirBreak(playerid);