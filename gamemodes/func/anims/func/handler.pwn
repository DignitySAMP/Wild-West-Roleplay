public OnPlayerConnect(playerid)
{
    gPlayerUsingLoopingAnim[playerid] = 0;
	gPlayerAnimLibsPreloaded[playerid] = 0;
	
	#if defined anim_OnPlayerConnect
		return anim_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect anim_OnPlayerConnect
#if defined anim_OnPlayerConnect
	forward anim_OnPlayerConnect(playerid);
#endif

public OnPlayerDeath(playerid, killerid, reason)
{
	// if they die whilst performing a looping anim, we should reset the state
	if(gPlayerUsingLoopingAnim[playerid]) {
        gPlayerUsingLoopingAnim[playerid] = 0;
        TextDrawHideForPlayer(playerid,txtAnimHelper);
	}
	
	#if defined anim_OnPlayerDeath
		return anim_OnPlayerDeath(playerid, killerid, reason);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDeath
	#undef OnPlayerDeath
#else
	#define _ALS_OnPlayerDeath
#endif

#define OnPlayerDeath anim_OnPlayerDeath
#if defined anim_OnPlayerDeath
	forward anim_OnPlayerDeath(playerid, killerid, reason);
#endif

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(IsKeyJustDown(KEY_SPRINT,newkeys,oldkeys)) {
		if(!gPlayerUsingLoopingAnim[playerid]) return true;
		if(!IsPlayerFree ( playerid ) ) return true ;
			
	    ClearAnimLoop(playerid);
        TextDrawHideForPlayer(playerid,txtAnimHelper);
    }

	#if defined anim_OnPlayerKeyStateChange
		return anim_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif

#define OnPlayerKeyStateChange anim_OnPlayerKeyStateChange
#if defined anim_OnPlayerKeyStateChange
	forward anim_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

IsKeyJustDown(key, newkeys, oldkeys) {

	if((newkeys & key) && !(oldkeys & key)) return 1;

	return 0;
}