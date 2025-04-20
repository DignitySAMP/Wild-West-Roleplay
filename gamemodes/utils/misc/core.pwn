#include "utils/misc/files/fire.pwn"

CMD:streamdis(playerid, params[]) {

	new limit;

	if ( isnull ( params ) ) {

		SendServerMessage(playerid,"/streamdis(tance) [low/medium/high]",MSG_TYPE_INFO);
		SendServerMessage(playerid,"This command is used to change the amount of objects that show up for you.",MSG_TYPE_INFO);
		SendServerMessage(playerid,"High - 2000 visible objects",MSG_TYPE_INFO);
		SendServerMessage(playerid,"Medium - 1250 visible objects",MSG_TYPE_INFO);
		SendServerMessage(playerid,"Low - 750 visible objects",MSG_TYPE_INFO);	
		return true ;
	}

	limit = 0;

	if ( ! strcmp ( params, "low", true ) ) {

		limit = 750;
	}

	else if ( ! strcmp ( params, "med", true )  || ! strcmp ( params, "medium", true ) ) {

		limit = 1250;
	}

	else if ( ! strcmp ( params, "high", true ) ) {

		limit = 2000;
	}

	else { 
		
		SendServerMessage(playerid,"/streamdis [low/medium/high]",MSG_TYPE_INFO);
		SendServerMessage(playerid,"This command is used to change the amount of objects that show up for you.",MSG_TYPE_INFO);
		SendServerMessage(playerid,"High - 2000 visible objects",MSG_TYPE_INFO);
		SendServerMessage(playerid,"Medium - 1250 visible objects",MSG_TYPE_INFO);
		SendServerMessage(playerid,"Low - 750 visible objects",MSG_TYPE_INFO);
		return true;
	}


	SendServerMessage(playerid,sprintf("You've set your streaming distance to \"%s\". (Limit: %d)", params, limit ),MSG_TYPE_INFO);

	Streamer_SetVisibleItems(STREAMER_TYPE_OBJECT,limit,playerid);
	//Streamer_RadiusMultiplier(STREAMER_TYPE_OBJECT,radius,playerid);

	Streamer_Update(playerid, STREAMER_TYPE_OBJECT ) ;

	return true ;
}

CMD:streamdistance(playerid, params[]) {

	return cmd_streamdis(playerid, params);
}