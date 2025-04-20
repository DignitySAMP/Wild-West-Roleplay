new bool:DoesPlayerHaveCampfire[MAX_PLAYERS];
new PlayerCampfireObjectHandler[MAX_PLAYERS];
new PlayerCampfireTimeLeft[MAX_PLAYERS];

public OnPlayerConnect(playerid)
{
	DoesPlayerHaveCampfire[playerid] = false;
	PlayerCampfireTimeLeft[playerid] = 0;
	if(IsValidDynamicObject(PlayerCampfireObjectHandler[playerid])) {

		Streamer_ToggleItemStatic(STREAMER_TYPE_OBJECT,PlayerCampfireObjectHandler[playerid],false);
		DestroyDynamicObject(PlayerCampfireObjectHandler[playerid]);
	}
	#if defined campfire_OnPlayerConnect
		return campfire_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect campfire_OnPlayerConnect
#if defined campfire_OnPlayerConnect
	forward campfire_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason)
{
	DoesPlayerHaveCampfire[playerid] = false;
	PlayerCampfireTimeLeft[playerid] = 0;
	if(IsValidDynamicObject(PlayerCampfireObjectHandler[playerid])) {

		Streamer_ToggleItemStatic(STREAMER_TYPE_OBJECT,PlayerCampfireObjectHandler[playerid],false);
		DestroyDynamicObject(PlayerCampfireObjectHandler[playerid]);
	}
	#if defined campfire_OnPlayerDisconnect
		return campfire_OnPlayerDisconnect(playerid, reason);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif

#define OnPlayerDisconnect campfire_OnPlayerDisconnect
#if defined campfire_OnPlayerDisconnect
	forward campfire_OnPlayerDisconnect(playerid, reason);
#endif