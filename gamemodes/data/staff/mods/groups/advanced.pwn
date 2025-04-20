CMD:purgereports(playerid,params[]) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < ADVANCED_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a advanced moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	PurgeReports();
	SendModeratorWarning ( sprintf("[STAFF] %s (%d) purged all server reports.", ReturnUserName ( playerid, true ), playerid ) , MOD_WARNING_HIGH) ;
	return true;
}

CMD:purgequestions(playerid,params[]) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < ADVANCED_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a advanced moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	PurgeQuestions();
	SendModeratorWarning ( sprintf("[STAFF] %s (%d) purged all server questions.", ReturnUserName ( playerid, true ), playerid ) , MOD_WARNING_HIGH) ;
	return true;
}

CMD:clearplayerinventory(playerid,params[]) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < ADVANCED_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a advanced moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new targetid,query[128];
	if(sscanf(params,"k<u>",targetid)) { return SendServerMessage(playerid,"/clearplayerinventory [playerid]",MSG_TYPE_ERROR); }
	if(!IsPlayerConnected(targetid)) { return SendServerMessage(playerid,"That player is not connected.",MSG_TYPE_ERROR); }

	mysql_format(mysql,query,sizeof(query),"DELETE FROM items_player WHERE player_database_id = %d",Character[targetid][character_id]);
	mysql_tquery(mysql,query);
	Init_LoadPlayerItems(targetid);

	SendServerMessage(targetid,sprintf("[STAFF] %s (%d) has reset your inventory.",ReturnUserName(playerid,false,false),playerid),MSG_TYPE_INFO);
	SendModeratorWarning(sprintf("[STAFF] %s (%d) has reset %s's (%d) inventory.",ReturnUserName(playerid,true,false),playerid,ReturnUserName(targetid,true,false),targetid),MOD_WARNING_MED);
	return true;
}

CMD:toggleooc ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < ADVANCED_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a advanced moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	ToggleOOCChat = !ToggleOOCChat ;

	SendServerMessage ( playerid, sprintf("You have %s OOC chat.", (ToggleOOCChat) ? ("enabled") : ("disabled") ), MSG_TYPE_WARN ) ;

	return true ;

}

CMD:forcepaycheck(playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < ADVANCED_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a advanced moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}


	foreach(new i: Player){

		if ( i != INVALID_PLAYER_ID ) {

			LastPaycheckGiven [ i ] = 0 ;
			Paycheck ( i ) ;
		}
	}

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) forced a global paycheck.", ReturnUserName ( playerid, true ), playerid ) , MOD_WARNING_HIGH) ;
	//OldLog ( playerid, "mod/money", sprintf( "%s (%d) forced a global paycheck.", ReturnUserName ( playerid, true ), playerid ) ) ;

	return true ;
}

CMD:forcelottery ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < ADVANCED_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a advanced moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	OnLotteryTick () ;

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) forced a global lottery.", ReturnUserName ( playerid, true ), playerid ) , MOD_WARNING_HIGH) ;

	return true ;
}

CMD:givemoney ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < ADVANCED_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a advanced moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new targetid, money ;

	if ( sscanf ( params, "k<u>i", targetid, money ) ) {

		return SendServerMessage ( playerid, "/givemoney [player] [money]", MSG_TYPE_ERROR ) ;
	}

	if ( money > 5000 ) {

		return SendServerMessage ( playerid, "That's not going to happen. Don't give more than 5000 money per turn.", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerConnected ( targetid ) ) {

		return SendServerMessage ( playerid, "Target doesn't seem to be a valid player.", MSG_TYPE_ERROR ) ;
	}

	inline AdminWarning(pid, dialogid, response, listitem, string:inputtext[]) {

		#pragma unused inputtext, listitem, dialogid, pid

		if ( ! response ) {

			return false ;
		}

		SendServerMessage ( targetid, sprintf("You've been given $%s by (%d) %s",IntegerWithDelimiter( money), playerid, ReturnUserName ( playerid, true ) ), MSG_TYPE_WARN) ;

		GiveCharacterMoney ( targetid, money, MONEY_SLOT_HAND ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) gave (%d) %s $%s.", ReturnUserName ( playerid, true ), playerid,  targetid, ReturnUserName ( targetid, true ), IntegerWithDelimiter( money) ), MOD_WARNING_HIGH ) ;
		WriteLog ( targetid, "mod/money", sprintf( "%s (%d) gave (%d) %s $%s.", ReturnUserName ( playerid, true ), playerid, targetid, ReturnUserName ( targetid, true ), IntegerWithDelimiter( money) )) ;
	}

    Dialog_ShowCallback(playerid, using inline AdminWarning, DIALOG_STYLE_MSGBOX, "{C23030}ABUSE WARNING", "{C23030}READ THIS BEFORE PRESSING CONTINUE.{DEDEDE}\n\nYou're about to give a valuable item to a player.\nAbuse of this will lead to you being caught, and you being /PERMANENTLY/ banned.\n\nWith that in mind, go ahead.", "{C23030}Proceed", "Cancel" ) ;
    return true ;
}

CMD:spawnweapon ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < ADVANCED_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a advanced moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new targetid, weaponid, ammo ;

	if ( sscanf ( params, "k<u>ii", targetid, weaponid, ammo ) ) {

		return SendServerMessage ( playerid, "/spawnweapon [player] [weapon id] [ammo]", MSG_TYPE_ERROR ) ;
	}

	if ( ammo > 15 ) {

		return SendServerMessage ( playerid, "You can't spawn more than 15 ammo in a clip!", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsValidWeapon ( weaponid ) ) {

		return SendServerMessage ( playerid, "This weapon isn't valid.", MSG_TYPE_ERROR ) ;
	}


	if ( ! IsPlayerConnected ( targetid ) ) {

		return SendServerMessage ( playerid, "Target doesn't seem to be a valid player.", MSG_TYPE_ERROR ) ;
	}

	SendModeratorWarning ( sprintf("[STAFF] %s (%d) spawned a %s with %d ammo for (%d) %s.", ReturnUserName ( playerid, true ), playerid, ReturnWeaponName ( weaponid ), ammo, targetid, ReturnUserName ( targetid, true ) ), MOD_WARNING_HIGH ) ;
	WriteLog ( targetid, "mods/gun", sprintf("%s (%d) spawned a %s with %d ammo for (%d) %s.", ReturnUserName ( playerid, true ), playerid, ReturnWeaponName ( weaponid ), ammo,  targetid, ReturnUserName ( targetid, true ))) ;

	return wep_GivePlayerWeapon ( targetid, weaponid, ammo ) ;
}

CMD:gotodroppedweapon ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < ADVANCED_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a advanced moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new id, Float: x, Float: y, Float: z ;

	if ( sscanf ( params, "i", id ) ) {

		return SendServerMessage ( playerid, "/gotodroppedweapon [id]", MSG_TYPE_ERROR ) ;
	}

	if ( IsValidDynamicObject( DroppedWeapon [ id ] )) {

		GetDynamicObjectPos(DroppedWeapon [ id ], x, y, z  ) ;
		ac_SetPlayerPos(playerid, x, y, z ) ;

		SetPlayerVirtualWorld ( playerid, 0 ) ;
		SetPlayerInterior ( playerid, 0 ) ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has teleported to dropped gun ID %d.", ReturnUserName ( playerid, true ), playerid, id ), MOD_WARNING_LOW) ;
		//OldLog ( playerid, "mod/gun", sprintf(" %s (%d) has teleported to dropped gun ID %d.", ReturnUserName ( playerid, true ), playerid, id ) ) ;
	}

	else return SendServerMessage ( playerid, "Invalid weapon ID. Doesn't seem to be a valid object.", MSG_TYPE_WARN ) ;

	return true ;
}

CMD:removedroppedweapon ( playerid, params [] ) {

	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}

	if ( GetStaffGroup ( playerid ) < ADVANCED_MOD ) {

		return SendServerMessage ( playerid, "You must be at least a advanced moderator in order to do this.", MSG_TYPE_ERROR ) ;
	}

	new id ;

	if ( sscanf ( params, "i", id ) ) {

		return SendServerMessage ( playerid, "/removedroppedweapon [id]", MSG_TYPE_ERROR ) ;
	}

	if ( IsValidDynamicObject( DroppedWeapon [ id ] )) {

		DestroyDynamicObject(DroppedWeapon [ id ] ) ;
		DroppedWeapon [ id ] = -1 ;
		DroppedWeaponAmmo [ id ] = 0 ;

		SendModeratorWarning ( sprintf("[STAFF] %s (%d) has deleted dropped gun ID %d.", ReturnUserName ( playerid, true ), playerid, id ), MOD_WARNING_MED ) ;
		//OldLog ( playerid, "mod/gun", sprintf(" %s (%d) has deleted dropped gun ID %d.", ReturnUserName ( playerid, true ), playerid, id ) ) ;
	}

	else return SendServerMessage ( playerid, "Invalid weapon ID. Doesn't seem to be a valid object.", MSG_TYPE_WARN ) ;

	return true ;
}

