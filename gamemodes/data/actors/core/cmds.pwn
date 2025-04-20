CMD:actorhelp ( playerid, params [] ) {

	SendClientMessage ( playerid, ADMIN_ORANGE, "Actor commands available to you" ) ;
	
	SendClientMessage ( playerid, ADMIN_LIGHTGREY, "/actorgoto, /actormove, /actorsetangle" ) ;
	SendClientMessage ( playerid, ADMIN_LIGHTGREY, "/actorsettype, /actorsetskin, /actorsetvw" ) ;

	return true ;
}

CMD:actorsetanim ( playerid, params [] ) {

	new actorid, animlib [ 32 ], animname [ 32] ;

	if ( sscanf ( params, "is[32]s[32]", actorid, animlib, animname )) {
	    return SendClientMessage ( playerid, ADMIN_RED, "[!]{B5B5B5} Syntax:{ffffff} /actorsetanim [id] [animlib] [animname]" ) ;
	}

	if ( ! IsValidActor ( actorid ) ) {
	    return SendClientMessage ( playerid, ADMIN_BLUE, "[i]{B5B5B5} Note:{ffffff} This actor isn't valid." ) ;
	}

	if ( ! IsValidActorAnim ( animlib ) ) {
	    return SendClientMessage ( playerid, ADMIN_BLUE, "[i]{B5B5B5} Note:{ffffff} The animation you entered isn't valid." ) ;
	}

	new query [ 256 ] ;

	ApplyActorAnimation ( actorid, animlib, animname, 4.1, 1, 0, 0, 0, 0 ) ;
	
	Actor [ actorid ] [ actor_animlib ] = animlib ;
	Actor [ actorid ] [ actor_animname ] = animname ;	

	ApplyActorAnimation ( actorid, Actor [ actorid ] [ actor_animlib ], Actor [ actorid ] [ actor_animname ], 4.1, 1, 0, 0, 0, 0 ) ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE actors SET actor_animlib = '%s', actor_animname = '%s' WHERE actor_id = '%d'",
		animlib, animname, actorid + 1);

	mysql_tquery ( mysql, query ) ;

	format ( query, sizeof ( query ), "[i]{B5B5B5} Note:{ffffff} Succesfully adjusted actor ID %d's animation to \"%s\", \"%s\"", actorid, animlib, animname);
	SendClientMessage ( playerid, ADMIN_BLUE, query ) ;

	return true ;
}

CMD:actorgoto ( playerid, params [] ) {
	new actorid ;

	if ( sscanf ( params, "i", actorid )) {
	    return SendClientMessage ( playerid, ADMIN_RED, "[!]{B5B5B5} Syntax:{ffffff} /actorgoto [id]" ) ;
	}

	if ( ! IsValidActor ( actorid ) ) {
	    return SendClientMessage ( playerid, ADMIN_BLUE, "[i]{B5B5B5} Note:{ffffff} This actor isn't valid." ) ;
	}

	new Float: actor_p_x, Float: actor_p_y, Float: actor_p_z ;
	GetActorPos ( actorid, actor_p_x, actor_p_y, actor_p_z ) ;
	
	ac_SetPlayerPos ( playerid, actor_p_x, actor_p_y, actor_p_z ) ;
	
	return true ;

}

CMD:actormove ( playerid, params [] ) {

	new actorid ;

	if ( sscanf ( params, "i", actorid )) {
	    return SendClientMessage ( playerid, ADMIN_RED, "[!]{B5B5B5} Syntax:{ffffff} /actormove [id]" ) ;
	}

	if ( ! IsValidActor ( actorid ) ) {
	    return SendClientMessage ( playerid, ADMIN_BLUE, "[i]{B5B5B5} Note:{ffffff} This actor isn't valid." ) ;
	}

	new Float: actor_p_x, Float: actor_p_y, Float: actor_p_z, playerVW, query [ 256 ] ;

	GetPlayerPos ( playerid, actor_p_x, actor_p_y, actor_p_z ) ;
	playerVW = GetPlayerVirtualWorld ( playerid ) ; 

	SetActorPos ( actorid, actor_p_x, actor_p_y, actor_p_z ) ;
	SetActorVirtualWorld ( actorid, playerVW ) ;

	Actor [ actorid ] [ actor_x_pos ] = actor_p_x ;
	Actor [ actorid ] [ actor_y_pos ] = actor_p_y ;
	Actor [ actorid ] [ actor_z_pos ] = actor_p_z ;


	Actor [ actorid ] [ actor_vw ] = playerVW ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE actors SET actor_x_pos = '%f', actor_y_pos = '%f', actor_z_pos = '%f', actor_vw = '%d' WHERE actor_id = '%d'",
		Actor [ actorid ] [ actor_x_pos ], Actor [ actorid ] [ actor_y_pos ], Actor [ actorid ] [ actor_z_pos ], playerVW, actorid + 1);

	mysql_tquery ( mysql, query ) ;

	format ( query, sizeof ( query ), "[i]{B5B5B5} Note:{ffffff} Succesfully moved actor ID %d to your location.", actorid);
	SendClientMessage ( playerid, ADMIN_BLUE, query ) ;

	SendClientMessage ( playerid, ADMIN_BLUE, "[i]{B5B5B5} Note:{ffffff} You can use /actorsetangle to adjust the actor's facing angle." ) ;

	UpdateActorInfoString ( actorid ) ;

	return true ;
}

CMD:actorsetangle ( playerid, params [] ) {

	new actorid, Float: faceangle ;

	if ( sscanf ( params, "if", actorid, faceangle )) {
	    return SendClientMessage ( playerid, ADMIN_RED, "[!]{B5B5B5} Syntax:{ffffff} /actorsetangle [id] [angle]" ) ;
	}

	if ( faceangle < 0 || faceangle > 360 ) {
	    return SendClientMessage ( playerid, ADMIN_BLUE, "[i]{B5B5B5} Note:{ffffff} Angle can't be less than 0 or more than 360." ) ;
	}

	if ( ! IsValidActor ( actorid ) ) {
	    return SendClientMessage ( playerid, ADMIN_BLUE, "[i]{B5B5B5} Note:{ffffff} This actor isn't valid." ) ;
	}

	new query [ 256 ] ;

	SetActorFacingAngle ( actorid, faceangle ) ;
	Actor [ actorid ] [ actor_a_pos ] = faceangle ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE actors SET actor_a_pos = '%f' WHERE actor_id = '%d'",
		Actor [ actorid ] [ actor_a_pos ], actorid + 1);

	mysql_tquery ( mysql, query ) ;

	format ( query, sizeof ( query ), "[i]{B5B5B5} Note:{ffffff} Succesfully adjusted actor ID %d's facing angle to %f", actorid, faceangle);
	SendClientMessage ( playerid, ADMIN_BLUE, query ) ;

	UpdateActor ( actorid ) ;

	return true ;
}

CMD:actorsettype ( playerid, params [] ) {

	new actorid, type ;

	if ( sscanf ( params, "ii", actorid, type )) {
	    return SendClientMessage ( playerid, ADMIN_RED, "[!]{B5B5B5} Syntax:{ffffff} /actorsettype [id] [type]" ) ;
	}

	if ( type < 0 || type > 5 ) {
	    return SendClientMessage ( playerid, ADMIN_BLUE, "[i]{B5B5B5} Note:{ffffff} Type can't be less than 0 or more than 5." ) ;
	}

	if ( ! IsValidActor ( actorid ) ) {
	    return SendClientMessage ( playerid, ADMIN_BLUE, "[i]{B5B5B5} Note:{ffffff} This actor isn't valid." ) ;
	}

	new query [ 256 ] ;

	Actor [ actorid ] [ actor_type ] = type ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE actors SET actor_type = '%d' WHERE actor_id = '%d'",
		Actor [ actorid ] [ actor_type ], actorid + 1);

	mysql_tquery ( mysql, query ) ;

	format ( query, sizeof ( query ), "[i]{B5B5B5} Note:{ffffff} Succesfully adjusted actor ID %d's type to %d", actorid, type);
	SendClientMessage ( playerid, ADMIN_BLUE, query ) ;

	UpdateActorInfoString ( actorid ) ;

	return true ;
}

CMD:actorsetskin ( playerid, params [] ) {

	new actorid, skin ;

	if ( sscanf ( params, "ii", actorid, skin )) {
	    return SendClientMessage ( playerid, ADMIN_RED, "[!]{B5B5B5} Syntax:{ffffff} /actorsetskin [id] [skin]" ) ;
	}

	if ( ! IsValidSkin ( skin ) ) {
	    return SendClientMessage ( playerid, ADMIN_BLUE, "[i]{B5B5B5} Note:{ffffff} The skin ID you entered isn't valid." ) ;
	}

	if ( ! IsValidActor ( actorid ) ) {
	    return SendClientMessage ( playerid, ADMIN_BLUE, "[i]{B5B5B5} Note:{ffffff} This actor isn't valid." ) ;
	}

	new query [ 256 ] ;

	Actor [ actorid ] [ actor_skinid ] = skin ;
	UpdateActor ( actorid ) ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE actors SET actor_skinid = '%d' WHERE actor_id = '%d'",
		Actor [ actorid ] [ actor_skinid ], actorid + 1);

	mysql_tquery ( mysql, query ) ;

	format ( query, sizeof ( query ), "[i]{B5B5B5} Note:{ffffff} Succesfully adjusted actor ID %d's skin to %d", actorid, skin);
	SendClientMessage ( playerid, ADMIN_BLUE, query ) ;

	return true ;
}

CMD:actorsetvw ( playerid, params [] ) {

	new actorid, vw ;

	if ( sscanf ( params, "ii", actorid, vw )) {
	    return SendClientMessage ( playerid, ADMIN_RED, "[!]{B5B5B5} Syntax:{ffffff} /actorsetvw [id] [vw]" ) ;
	}

	if ( vw < 0 ) {
	    return SendClientMessage ( playerid, ADMIN_BLUE, "[i]{B5B5B5} Note:{ffffff} The virtual world has to be higher than 0." ) ;
	}

	if ( ! IsValidActor ( actorid ) ) {
	    return SendClientMessage ( playerid, ADMIN_BLUE, "[i]{B5B5B5} Note:{ffffff} This actor isn't valid." ) ;
	}

	new query [ 256 ] ;

	Actor [ actorid ] [ actor_vw ] = vw ;
	SetActorVirtualWorld ( actorid, vw ) ;

	mysql_format ( mysql, query, sizeof ( query ), "UPDATE actors SET actor_vw = '%d' WHERE actor_id = '%d'",
		Actor [ actorid ] [ actor_vw ], actorid + 1);

	mysql_tquery ( mysql, query ) ;

	format ( query, sizeof ( query ), "[i]{B5B5B5} Note:{ffffff} Succesfully adjusted actor ID %d's virtual world to %d", actorid, vw);
	SendClientMessage ( playerid, ADMIN_BLUE, query ) ;

	return true ;
}
