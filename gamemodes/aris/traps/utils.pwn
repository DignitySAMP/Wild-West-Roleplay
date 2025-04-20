#if defined _inc_utils
	#undef _inc_utils
#endif	

CMD:trap(playerid,params[]) {

    new choice[16], trapid;

    if(sscanf(params,"s[16]",choice)) { return SendServerMessage(playerid,"/trap [arm/disarm/examine/releasetrapped/pickup]",MSG_TYPE_INFO); }

    if(!strcmp(choice,"arm",true)) {

        trapid = FindNearestTrap(playerid,2.5);
        if(trapid == INVALID_TRAP_ID) { return SendServerMessage(playerid,"You're not near a trap.",MSG_TYPE_ERROR); }

        if(!DoesPlayerOwnTrap(playerid,trapid)) { return SendServerMessage(playerid,"You cannot arm traps you don't own.",MSG_TYPE_ERROR); }

        if(!Trap[trapid][trap_deployed]) { return SendServerMessage(playerid,"Your trap is already armed.",MSG_TYPE_ERROR); }

        ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 0, 0, 0, 0, 0, 1);

        ProxDetector(playerid, 20.0, COLOR_ACTION, sprintf("* %s is arming their trap.", ReturnUserName(playerid, false)));

        SendServerMessage(playerid, "Your trap will activate soon, please get away from it!", MSG_TYPE_INFO);

        defer SetTrapStatus[7500](playerid, trapid, 0);
    }
    else if(!strcmp(choice,"disarm",true)) {

        trapid = FindNearestTrap(playerid,2.5);
        if(trapid == INVALID_TRAP_ID) { return SendServerMessage(playerid,"You're not near a trap.",MSG_TYPE_ERROR); }

        if(Trap[trapid][trap_deployed]) { return SendServerMessage(playerid,"This trap is already disarmed.",MSG_TYPE_ERROR); }

        ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 0, 0, 0, 0, 0, 1);

        ProxDetector(playerid, 20.0, COLOR_ACTION, sprintf("* %s is disarming %s trap.", ReturnUserName(playerid, false), (DoesPlayerOwnTrap(playerid,trapid)) ? ("their") : ("a")));

        defer SetTrapStatus[2500](playerid, trapid, 1);
    }
    else if(!strcmp(choice,"examine",true)) {

        new Float:x, Float:y, Float:z, count=0, TrapDetect[MAX_TRAPS];
        for(new j=10; j >= 1; j--) {

            GetXYInFrontOfPlayer(playerid, x, y, float(j));

            CA_FindZ_For2DCoord(x,y,z);
            for(new i; i < MAX_TRAPS; i++) {

                if(Trap[i][trap_id] != INVALID_TRAP_ID) {

                    if(TrapDetect[i]) { continue; }
                    if((5.0 >= (x-Trap[i][trap_pos_x]) >= -5.0) && (5.0 >= (y-Trap[i][trap_pos_y]) >= -5.0)) {

                        new Float:dist = GetPlayerDistanceFromPoint(playerid, Trap[i][trap_pos_x], Trap[i][trap_pos_y], Trap[i][trap_pos_z]);
                        SendServerMessage(playerid,sprintf("You can see a trap %.0fm away.",dist),MSG_TYPE_INFO);
                        TrapDetect[i] = 1;
                        count++;
                        continue;
                    }
                    else continue;
                }
                else continue;
            }
        }

        if(!count) { return SendServerMessage(playerid,"You failed to spot any traps ahead.",MSG_TYPE_INFO); }
    }
    else if(!strcmp(choice,"releasetrapped",true)) {

        new targetid = GetNearestTrappedPlayer(playerid, 10);

        if(targetid == INVALID_PLAYER_ID)
            return SendServerMessage(playerid, "There's no one to release around you.", MSG_TYPE_ERROR);


        TogglePlayerBleeding(targetid);
        DamageLegs(targetid);

        IsPlayerTrapped[targetid] = false;

        SendServerMessage(playerid, sprintf("You untrapped %s!", ReturnUserName(targetid,false)), MSG_TYPE_INFO);

        SendServerMessage(targetid, sprintf("You were untrapped by %s", ReturnUserName(playerid,false)), MSG_TYPE_INFO);

        ProxDetector(playerid, 20, COLOR_ACTION, sprintf("* %s releases the trap, letting %s free.", ReturnUserName(playerid), ReturnUserName(targetid)));
        TogglePlayerControllable(targetid, 1);
        ClearAnimations(targetid);
    }
    else if(!strcmp(choice,"pickup",true)) {

        trapid = FindNearestTrap(playerid,2.5);
        if(trapid == INVALID_TRAP_ID) { return SendServerMessage(playerid,"You're not near a trap.",MSG_TYPE_ERROR); }

        if(!Trap[trapid][trap_deployed]) { return SendServerMessage(playerid,"You need to disarm the trap before picking it up.",MSG_TYPE_ERROR); }

        ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 0, 0, 0, 0, 0, 1);

        ProxDetector(playerid, 20.0, COLOR_ACTION, sprintf("* %s picks up %s trap.", ReturnUserName(playerid, false), (DoesPlayerOwnTrap(playerid,trapid)) ? ("their") : ("a")));

        GivePlayerItemByParam ( playerid, PARAM_HUNTING, HUNTING_TRAP, 1, 0, 0, 0 ) ;
        if(IsTrapBaited(trapid)) { GivePlayerItemByParam ( playerid, PARAM_HUNTING, HUNTING_BAIT, 1, 0, 0, 0 ) ; }

        RemoveTrap(playerid,trapid);
    }
    else { SendServerMessage(playerid,"/trap [arm/disarm/examine/releasetrapped/pickup]",MSG_TYPE_INFO); }
    return true;
}

CMD:atrap(playerid, params[]) {

    if(IsPlayerModerator(playerid)) {

        new choice[12], trapid;
        if(sscanf(params, "s[12]D(-2)", choice, trapid)) {

            return SendServerMessage(playerid, "/atrap [info/remove/removeall/refreshall/alltraps] [trap_id (defaults to nearest trap within range)]", MSG_TYPE_ERROR);
        }
        if(trapid == -2) {

            trapid = FindNearestTrap(playerid,3.0);
        }

        if(!strcmp(choice,"info",true)) {

            if(Trap[trapid][trap_id] == INVALID_TRAP_ID) {

                return SendServerMessage(playerid, "Invalid trap id.", MSG_TYPE_ERROR);
            }

            new query[128], acc_name[MAX_PLAYER_NAME], char_name[MAX_PLAYER_NAME];

            inline FindCharName() {

                new rows[2], fields[2];

                cache_get_data(rows[0],fields[0],mysql);

                if(rows[0]) {

                    new acc_id;

                    acc_id = cache_get_field_int(0,"account_id");
                    cache_get_field_content(0,"character_name",char_name,mysql,MAX_PLAYER_NAME);

                    inline FindAccName() {

                        cache_get_data(rows[1],fields[1],mysql);

                        if(rows[1]) {

                            cache_get_field_content(0,"account_name",acc_name,mysql,MAX_PLAYER_NAME);

                            SendServerMessage(playerid, sprintf("Trap ID: %d", Trap[trapid][trap_id]), MSG_TYPE_INFO);
                            SendServerMessage(playerid, sprintf("Trap Type: %d", Trap[trapid][trap_constant]), MSG_TYPE_INFO);
                            SendServerMessage(playerid, sprintf("Trap Owner: %s (%s)", char_name,acc_name), MSG_TYPE_INFO);
                            SendServerMessage(playerid, sprintf("Trap Deployed: %s", (Trap[trapid][trap_deployed]) ? ("True") : ("False")), MSG_TYPE_INFO);
                            SendServerMessage(playerid, sprintf("Trap Pos: %02f, %02f, %02f", Trap[trapid][trap_pos_x], Trap[trapid][trap_pos_y], Trap[trapid][trap_pos_z]), MSG_TYPE_INFO);
                        }
                    }

                    mysql_format(mysql,query,sizeof(query),"SELECT account_name FROM master_accounts WHERE account_id = %d",acc_id);
                    mysql_tquery_inline(mysql,query,using inline FindAccName, "");
                }
            }
            mysql_format(mysql,query,sizeof(query),"SELECT account_id,character_name FROM characters WHERE character_id = %d",Trap[trapid][trap_owner]);
            mysql_tquery_inline(mysql, query, using inline FindCharName, "");
            return true;
        }
        else if(!strcmp(choice,"remove",true)) {
         
            if(Trap[trapid][trap_id] == INVALID_TRAP_ID) {
                
                return SendServerMessage(playerid, "Invalid trap id.", MSG_TYPE_ERROR);
            }

            SendServerMessage(playerid, sprintf("Trap ID %d deleted.",Trap[trapid][trap_id]), MSG_TYPE_INFO);
            RemoveTrap(playerid, trapid);
            return true;
        }
        else if(!strcmp(choice,"removeall",true)) {

            DeleteAllTraps(playerid);
            SendServerMessage(playerid, "All traps have been deleted.", MSG_TYPE_INFO);
            return true;   
        }
        else if(!strcmp(choice,"refreshall",true)) {

            RefreshTraps();
            SendServerMessage(playerid, "All traps refreshed.", MSG_TYPE_INFO);
            return true;
        }
        else if(!strcmp(choice,"alltraps",true)) {

            for(new i; i<MAX_TRAPS; i++) {

                if(Trap[i][trap_id] != INVALID_TRAP_ID) {

                    new query[128], acc_name[MAX_PLAYER_NAME], char_name[MAX_PLAYER_NAME];

                    inline FindCharName() {

                        new rows[2], fields[2];

                        cache_get_data(rows[0],fields[0],mysql);

                        if(rows[0]) {

                            new acc_id;

                            acc_id = cache_get_field_int(0,"account_id");
                            cache_get_field_content(0,"character_name",char_name,mysql,MAX_PLAYER_NAME);

                            inline FindAccName() {

                                cache_get_data(rows[1],fields[1],mysql);

                                if(rows[1]) {

                                    cache_get_field_content(0,"account_name",acc_name,mysql,MAX_PLAYER_NAME);

                                    SendServerMessage(playerid, sprintf("Trap ID: %d | Owner: %s (%s)",Trap[i][trap_id],char_name,acc_name), MSG_TYPE_INFO);
                                }
                            }

                            mysql_format(mysql,query,sizeof(query),"SELECT account_name FROM master_accounts WHERE account_id = %d",acc_id);
                            mysql_tquery_inline(mysql,query,using inline FindAccName, "");
                        }
                    }
                    mysql_format(mysql,query,sizeof(query),"SELECT account_id,character_name FROM characters WHERE character_id = %d",Trap[i][trap_owner]);
                    mysql_tquery_inline(mysql, query, using inline FindCharName, "");
                }
                else continue;
            }

            return true;
        }
        else return SendServerMessage(playerid, "/atrap [info/remove/removeall/refreshall/alltraps] [trap_id (defaults to nearest trap within range)]", MSG_TYPE_ERROR);
    } else {
      SendServerMessage(playerid, "You must be a moderator to use this command!", MSG_TYPE_ERROR);
    }
    return true;
}

FindNearestTrap(playerid, Float: range = 5.0) {

    for(new i; i < MAX_TRAPS; i++) {

        if(Trap[i][trap_id] != INVALID_TRAP_ID) {

            if(IsPlayerInRangeOfPoint(playerid, range, Trap[i][trap_pos_x], Trap[i][trap_pos_y], Trap[i][trap_pos_z])) {

                return i;
            }
            else continue;
        }
        else continue;
    }
    return INVALID_TRAP_ID;
}

DoesPlayerOwnTrap(playerid, trapid) {

    if(Character[playerid][character_id] == Trap[trapid][trap_owner]) { return true; }
    return false;
}

IsTrapArmed(trapid) { 
    
    if(!Trap[trapid][trap_deployed]) { return true; }
    return false;
}

IsTrapBaited(trapid) { return Trap[trapid][trap_bait]; }

SetTrapBait(trapid) {

    new query[128];
    Trap[trapid][trap_bait] = 1;
    mysql_format(mysql,query,sizeof(query),"UPDATE traps SET trap_bait = %d WHERE trap_id = %d",Trap[trapid][trap_bait],Trap[trapid][trap_id]);
    mysql_tquery(mysql,query);
    return true;
}

RemoveTrapBait(trapid) {

    new query[128];
    Trap[trapid][trap_bait] = 0;
    mysql_format(mysql,query,sizeof(query),"UPDATE traps SET trap_bait = %d WHERE trap_id = %d",Trap[trapid][trap_bait],Trap[trapid][trap_id]);
    mysql_tquery(mysql,query);
    return true;
}

DeleteAllTraps(playerid) {

    for(new i; i < MAX_TRAPS; i++) {

        if(Trap[i][trap_id] != INVALID_TRAP_ID) {

            RemoveTrap(playerid, i);
        }
        else continue;
    }
    return true;
}

timer SetTrapStatus[7500](playerid, trapid, deploy) {

    Trap[trapid][trap_deployed] = deploy;

    new query[256];
    mysql_format(mysql, query, sizeof(query), "UPDATE traps SET trap_deployed_state = '%i' WHERE trap_id = '%i'", Trap[trapid][trap_deployed], Trap[trapid][trap_id]);
    mysql_tquery(mysql, query);

    SendServerMessage(playerid, sprintf("Your trap is now %s.",(Trap[trapid][trap_deployed]) ? ("deactivated") : ("activated")), MSG_TYPE_INFO);

}