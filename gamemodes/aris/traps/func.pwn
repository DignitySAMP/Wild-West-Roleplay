#if defined _inc_func
	#undef _inc_func
#endif	

public OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid) {

    for ( new i; i < MAX_TRAPS; i ++ ) {

        if ( areaid == Trap[i][trap_area] && Trap[i][trap_deployed] == 0) {
            OnPlayerTriggerTrap ( playerid, i ) ;
            break ;    
       	}

        else continue ;
    	}

    return true ;
}

//onplayerenterdynamicarea
#if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif

#define OnPlayerEnterDynamicArea traps_OnPlayerEnterDynamicArea

#if defined traps_OnPlayerEnterDynamicArea
    forward traps_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid);
#endif

public OnPlayerConnect(playerid){

    for(new i; i < MAX_TRAPS; i++){
        if(IsValidDynamic3DTextLabel(Trap[i][trap_label])){
        
            if ( Character [ playerid ] [ character_id ] == Trap [ i ] [ trap_owner ] ) {
                Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, Trap [ i ] [ trap_label], E_STREAMER_PLAYER_ID, playerid);
            }
        }   
    }

    #if defined traps_OnPlayerConnect
        return traps_OnPlayerConnect(playerid);
    #else
        return true;
    #endif
}

#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect traps_OnPlayerConnect

#if defined traps_OnPlayerConnect
    forward traps_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason){

    for ( new i; i < MAX_TRAPS; i ++ ) {
        if(IsValidDynamic3DTextLabel(Trap[i][trap_label])){
            if( Streamer_GetIntData(STREAMER_TYPE_3D_TEXT_LABEL, Trap [ i ] [ trap_label ], E_STREAMER_PLAYER_ID) == playerid ) {
                Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, Trap [ i ] [ trap_label], E_STREAMER_PLAYER_ID, INVALID_PLAYER_ID );
                Streamer_Update(playerid);
            }
        }  
    }

    #if defined traps_OnPlayerDisconnect
        return traps_OnPlayerDisconnect(playerid, reason);
    #else
        return true;
    #endif
}

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif

#define OnPlayerDisconnect traps_OnPlayerDisconnect

#if defined traps_OnPlayerDisconnect
    forward traps_OnPlayerDisconnect(playerid, reason);
#endif

GetNearestAnimalBaitedTrap(wildlifeid,Float:distance) {

    new Float:x, Float:y, Float:z;
    GetDynamicObjectPos(Wildlife [ wildlifeid ] [ wildlife_object ], x, y, z);
    for(new i; i < MAX_TRAPS; i++) {

        if(Trap[i][trap_id] != INVALID_TRAP_ID) {

            if(!Trap[i][trap_bait]) { continue; }
            if(distance >= (x-Trap[i][trap_pos_x]) >= -distance) {

                if(distance >= (y-Trap[i][trap_pos_y]) >= -distance) {

                    return i; 
                }
                else continue;
            }
            else continue;
        }
        else continue;
    }
    return -1;
}

DidAnimalTriggerTrap(wildlifeid,en = 0) {

    new Float:x, Float:y, Float:z;
    GetDynamicObjectPos(Wildlife [ wildlifeid ] [ wildlife_object ], x, y, z);
    for(new i; i < MAX_TRAPS; i++) {

        if(Trap[i][trap_id] != INVALID_TRAP_ID) {

            if(3 >= (x-Trap[i][trap_pos_x]) >= -3) {

                if(3 >= (y-Trap[i][trap_pos_y]) >= -3) {

                    if(!Trap[i][trap_deployed]) {
                        
                        if(!en) { return true; }
                        else { return i; }
                    }
                }
                else continue;
            }
            else continue;
        }
        else continue;
    }
    if(!en) { return false; }
    else { return -1; }
}

IsValidTrap(trapid) {

    if(Trap[trapid][trap_id] != INVALID_TRAP_ID) { return true; }
    return false;
}

GetTrapPos(trapid, &Float:x, &Float:y, &Float:z) {

    x = Trap[trapid][trap_pos_x];
    y = Trap[trapid][trap_pos_y];
    z = Trap[trapid][trap_pos_z];
}

OnAnimalTriggerTrap(wildlifeid,trapid) {

    Wildlife_Shot(Wildlife [ wildlifeid ] [ wildlife_object ], 1000);

    //RemoveTrap(INVALID_PLAYER_ID, trapid);

    Trap[trapid][trap_deployed] = 1;

    new query[128];

    mysql_format(mysql, query, sizeof(query), "UPDATE traps SET trap_deployed_state = '%i' WHERE trap_id = '%i'", Trap[trapid][trap_deployed], Trap[trapid][trap_id]);
    mysql_tquery(mysql, query);
    return true;
}

OnPlayerTriggerTrap (playerid, trapid) {

    IsPlayerTrapped[playerid] = true;

    Trap[trapid][trap_deployed] = 1;

    ProxDetector(playerid, 20, COLOR_ACTION, "* A trap has been sprung nearby!");

    new query[128];

    mysql_format(mysql, query, sizeof(query), "UPDATE traps SET trap_deployed_state = '%i' WHERE trap_id = '%i'", Trap[trapid][trap_deployed], Trap[trapid][trap_id]);
    mysql_tquery(mysql, query);

    SendServerMessage(playerid, "Your feet has been caught in a trap. Someone has to release you or you have to wait to free yourself.", MSG_TYPE_INFO);
    TogglePlayerControllable(playerid, 0);
    ApplyAnimation(playerid, "CRACK", "crckidle2", 4.0, 1, 0, 0, 0, 0);

    defer ToggleTrapSelfRelease(playerid, trapid);

    return true ;
}

CreateTrap(playerid, trapid) {

    if(trapid == INVALID_TRAP_ID) {

        SendServerMessage(playerid, "Max traps reached.", MSG_TYPE_ERROR);
        return false;
    }
    if(IsPlayerTrapped[playerid]) {

        SendServerMessage(playerid, "You can't create a trap while you're trapped!", MSG_TYPE_ERROR);
        return false;
    }
    if(IsPlayerNearPoint(playerid,4.5)) {

        SendServerMessage(playerid, "You cannot place a trap here.", MSG_TYPE_ERROR);
        return false;
    }
    if(IsZoneSafeZone(GetPlayerZone(playerid))) { 

        SendServerMessage(playerid,"You cannot place a trap in a safezone.",MSG_TYPE_ERROR); 
        return false; 
    }

    Trap[trapid][trap_id] = trapid;

    new Float: x, Float: y, Float: z;
    new Float: rayX, Float: rayY, Float: rayZ;
    new Float: rayRX, Float: rayRY, Float: rayRZ;

    GetPlayerPos(playerid, x, y, z);

    Trap[trapid][trap_owner] = Character[playerid][character_id];

    CA_RayCastLineAngle(x, y, z, x, y, z-5, rayX, rayY, rayZ, rayRX, rayRY, rayRZ);

    Trap[trapid][trap_object] = CreateDynamicObject(TRAP_FOOTLOCK, rayX, rayY, rayZ + 0.2, rayRX, rayRY, rayRZ);

    Trap[trapid][trap_pos_x] = rayX;
    Trap[trapid][trap_pos_y] = rayY;
    Trap[trapid][trap_pos_z] = rayZ;

    Trap[trapid][trap_rot_x] = rayRX;
    Trap[trapid][trap_rot_y] = rayRY;
    Trap[trapid][trap_rot_z] = rayRZ;

    Trap[trapid][trap_area] = CreateDynamicCircle(Trap[trapid][trap_pos_x], Trap[trapid][trap_pos_y], 1.6);

    //Trap[trapid][trap_label] = CreateDynamic3DTextLabel(sprintf("TRAP - [ID: %i (DB: %i)]", trapid, Trap[trapid][trap_id]), COLOR_BLUE, Trap[trapid][trap_pos_x], Trap[trapid][trap_pos_y], Trap[trapid][trap_pos_z], 15.0);

    Trap[trapid][trap_deployed] = 1;
    Trap[trapid][trap_constant] = TRAP_BEAR;

    ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 0, 0, 0, 0, 0, 1);

    ProxDetector(playerid, 20.0, COLOR_ACTION, sprintf("* %s has placed down a trap.", ReturnUserName(playerid, false)));

    SendServerMessage(playerid, "You've placed down your trap, use /trap to arm it.", MSG_TYPE_INFO);

    new query[256];

    mysql_format(mysql, query, sizeof(query), "INSERT INTO traps (trap_id, trap_constant, trap_owner, trap_deployed_state, trap_pos_x, trap_pos_y, trap_pos_z, trap_rot_x, trap_rot_y, trap_rot_z) VALUES ('%i', '%i', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f')", Trap[trapid][trap_id], Trap[trapid][trap_constant], Trap[trapid][trap_owner], Trap[trapid][trap_deployed], Trap[trapid][trap_pos_x], Trap[trapid][trap_pos_y], Trap[trapid][trap_pos_z], Trap[trapid][trap_rot_x], Trap[trapid][trap_rot_y], Trap[trapid][trap_rot_z]); 
    mysql_tquery(mysql, query);

    return true;
}

RemoveTrap(playerid, trapid){

    if(Trap[trapid][trap_id] == INVALID_TRAP_ID)
        return SendServerMessage(playerid, sprintf("Unknown trap %i.", Trap[trapid][trap_id]), MSG_TYPE_INFO);

    new query[128];
    mysql_format(mysql, query, sizeof(query), "DELETE FROM traps WHERE trap_id = '%i'", Trap[trapid][trap_id]);
    mysql_tquery(mysql, query);

    DestroyDynamic3DTextLabel(Trap[trapid][trap_label]);
    DestroyDynamicArea(Trap[trapid][trap_area]);

    DestroyDynamicObject(Trap[trapid][trap_object]);

    Trap[trapid][trap_id] = INVALID_TRAP_ID;

    return true;
}

RefreshTraps() {

    print("refresh traps called.");

    for(new i; i < MAX_TRAPS; i++) {

        DestroyDynamic3DTextLabel(Trap[i][trap_label]);
        DestroyDynamicArea(Trap[i][trap_area]);
        DestroyDynamicObject(Trap[i][trap_object]);

        Trap[i][trap_id] = INVALID_TRAP_ID;
    }

    Init_Traps();
}

GetNearestTrappedPlayer(playerid,Float:distance) {

    new Float:x, Float:y, Float:z;
    foreach(new i : Player) {

        if(playerid == i) continue;
        if(!IsPlayerTrapped[i]) continue;

        GetPlayerPos(i,x,y,z);
        if(IsPlayerInRangeOfPoint(playerid,distance,x,y,z)) {

            return i;
        }
        else continue;
    }
    return INVALID_PLAYER_ID;
}

timer ToggleTrap[5000](playerid, trapid) {

    Trap[trapid][trap_deployed] = 0;

    new query[256];
    mysql_format(mysql, query, sizeof(query), "UPDATE traps SET trap_deployed_state = '%i' WHERE trap_id = '%i'", Trap[trapid][trap_deployed], Trap[trapid][trap_id]);
    mysql_tquery(mysql, query);

    SendServerMessage(playerid, "Your trap is now activated and will catch any animals / humans that step on it.", MSG_TYPE_INFO);

}

timer ToggleTrapSelfRelease[300000](playerid, trapid) {

    if(IsPlayerTrapped[playerid]) {

        TogglePlayerBleeding(playerid);
        DamageLegs(playerid);

        IsPlayerTrapped[playerid] = false;

        SendServerMessage(playerid, "You've managed to release the trap.", MSG_TYPE_INFO);

        ProxDetector(playerid, 20, COLOR_ACTION, sprintf("* %s releases the trap.", ReturnUserName(playerid,false)));
        TogglePlayerControllable(playerid, 1);
        ClearAnimations(playerid);
    }

    if(Trap[trapid][trap_id] != INVALID_TRAP_ID) {

        RemoveTrap(playerid, trapid);
    }
}