/* steps on how to use the lasso: 

- get one from the police hq (?)
- equip it in the inventory,
- use /lasso [targetid] to target a specific player. (/l [targetid] too);
- if in range, you press click, depending on the distance, you have more chances of missing.
- if sucessful, target gets taken off the horse (if on any), get dropped to the ground and is essentially frozen

*/

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

CMD:lasso(playerid, params[]){

	if(IsPlayerInLassoMode[playerid]){

		IsPlayerInLassoMode[playerid] = false;
		SendServerMessage(playerid, "You exited lasso mode.", MSG_TYPE_INFO);
	}

	if(EquippedItem[playerid] != SHERIFF_LASSO)
		return SendServerMessage(playerid, "You must have a lasso equipped to use this command.", MSG_TYPE_ERROR);

	if(!IsLawEnforcementPosse(Character[playerid][character_posse]))
		return SendServerMessage(playerid, "You are not in a law enforcement posse.", MSG_TYPE_ERROR);

	new targetid;

	if(sscanf(params, "u", targetid))
    	return SendServerMessage ( playerid, "/lasso [target] - (/l [target])", MSG_TYPE_ERROR ) ;

    if(!IsPlayerConnected(targetid))
    	return SendServerMessage(playerid, "Player specified is not connected!", MSG_TYPE_ERROR);

    if(playerid == targetid)
    	return SendServerMessage(playerid, "You can't target yourself.", MSG_TYPE_INFO);

    if(IsLawEnforcementPosse ( Character [ targetid ] [ character_posse ]))
    	return SendServerMessage(playerid, "You can't target a player in the same posse as yours!", MSG_TYPE_ERROR);

   	IsPlayerInLassoMode[playerid] = true;
   	LassoModeTarget[playerid] = targetid;

   	SendServerMessage(playerid, sprintf("You have sucessfully entered lasso mode on %s (%i). Use LEFT-CLICK to try catching the target.", ReturnUserName(targetid), targetid), MSG_TYPE_INFO);
   	SendServerMessage(playerid, "You can exit lasso mode by doing /lasso again.", MSG_TYPE_INFO);

   	return true;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys){

	if(PRESSED(KEY_FIRE) && IsPlayerInLassoMode[playerid] && IsPlayerOnLassoCooldown[playerid]){
		SendServerMessage(playerid, "You are currently on a lasso cooldown to prevent abuse! Try again in a few seconds.", MSG_TYPE_ERROR);
	} else if(PRESSED(KEY_FIRE) && IsPlayerInLassoMode[playerid] && !IsPlayerOnLassoCooldown[playerid]){
		CheckLassoReq(playerid, LassoModeTarget[playerid]);
	} 

	#if defined lasso_OnPlayerKeyStateChange
		return lasso_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	#else
		return true;
	#endif
}


#if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif

#define OnPlayerKeyStateChange lasso_OnPlayerKeyStateChange

#if defined lasso_OnPlayerKeyStateChange
    forward lasso_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif



CheckLassoReq(playerid, targetid){

	new Float: targetX, Float: targetY, Float: targetZ;
	GetPlayerPos(targetid, targetX, targetY, targetZ);

	if(IsPlayerInRangeOfPoint(playerid, 10.0, targetX, targetY, targetZ)){
		
		TryLasso(playerid, targetid);

	} else {
		return SendServerMessage(playerid, "You are too far from your target. A attempt from here will surely miss!", MSG_TYPE_ERROR);
	}

	return true;
}


TryLasso(playerid, targetid){

	new randomChance = random(11);

	if(randomChance < 5){ // sucessful attempt.

		if ( IsPlayerRidingHorse [ targetid ] ) {

			IsPlayerRidingHorse [ targetid ] = false ;
			IsPlayerInLasso[targetid] = true;

			IsPlayerInLassoMode[playerid] = false;

			SendServerMessage ( targetid, "You've been caught by a lasso and pulled off your horse!", MSG_TYPE_INFO ) ;
			SendServerMessage(playerid, sprintf("You've caught %s with your lasso and pulled them off their horse", ReturnUserName(targetid)), MSG_TYPE_INFO);

			RemovePlayerAttachedObject(targetid, ATTACH_SLOT_HORSE ) ;

			TogglePlayerControllable(targetid, 0);

			ApplyAnimation(targetid, "CRACK", "crckidle2", 4.0, 1, 0, 0, 0, 0);

			IsPlayerOnLassoCooldown[playerid] = true;
			defer ApplyLassoCooldown(playerid);
			defer LassoAutoRemove(targetid);

		} else {

			IsPlayerInLasso[targetid] = true;
			IsPlayerInLassoMode[playerid] = false;

			SendServerMessage ( targetid, "You've been caught by a lasso and pulled to the ground!", MSG_TYPE_INFO ) ;
			SendServerMessage(playerid, sprintf("You've caught %s with your lasso and pulled them to the ground.", ReturnUserName(targetid)), MSG_TYPE_INFO);

			TogglePlayerControllable(targetid, 0);

			ApplyAnimation(targetid, "CRACK", "crckidle2", 4.0, 1, 0, 0, 0, 0);		

			IsPlayerOnLassoCooldown[playerid] = true;
			defer ApplyLassoCooldown(playerid);
			defer LassoAutoRemove(targetid);

		}

	} else if(randomChance > 5){ // failed attempt.

		SendServerMessage(playerid, "You missed your target!", MSG_TYPE_INFO);

		IsPlayerOnLassoCooldown[playerid] = true;
		defer ApplyLassoCooldown(playerid);
	}

	return true;

}

timer ApplyLassoCooldown[10000](playerid){

	IsPlayerOnLassoCooldown[playerid] = false;
	SendServerMessage(playerid, "Your lasso cooldown has expired, you can now use it again.", MSG_TYPE_INFO);

	return true;
}

timer LassoAutoRemove[300000](playerid){

	IsPlayerInLasso[playerid] = false;
	TogglePlayerControllable(playerid, 1);

	SendServerMessage(playerid, "You have automatically been untied from the lasso.", MSG_TYPE_INFO);

	return true;
}


CMD:untielasso(playerid, params[]){

	new Float: x, Float: y, Float: z;

	foreach(new i : Player){
		if(IsPlayerInLasso[i]){

			GetPlayerPos(i, x, y, z);

			if(IsPlayerInRangeOfPoint(playerid, 5.0, x, y, z)){

				IsPlayerInLasso[i] = false;
				TogglePlayerControllable(i, 1);

				SendServerMessage(playerid, sprintf("You untied %s from the lasso.", ReturnUserName(i)), MSG_TYPE_INFO);
				SendServerMessage(i, "You have been freed from the lasso. Please roleplay properly!", MSG_TYPE_INFO);

				break;
 
			}

			continue;
		}

		SendServerMessage(playerid, "You aren't near any players caught in a lasso!", MSG_TYPE_ERROR);
	}

	return true;
}

