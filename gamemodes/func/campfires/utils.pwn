GetNearestCampfire(playerid) {

	foreach(new i : Player) {

		if(DoesPlayerHaveCampfire[i]) {

			new Float:x,Float:y,Float:z;
			GetDynamicObjectPos(PlayerCampfireObjectHandler[i], x, y, z);
			if(IsPlayerInRangeOfPoint(playerid, 3, x, y, z)) {

				return i;
			}
			else { continue; }
		}
		else { continue; }
	}
	return -1;
}

DoesPlayerOwnCampfire(playerid,campfireid) { return (campfireid == playerid) ? (true) : (false); }

GetCampfireStage(playerid) {

	new stage[64];
	stage = "N/A";
	if(!DoesPlayerHaveCampfire[playerid]) { return stage; }
	switch(PlayerCampfireTimeLeft[playerid]) {

		case 1..5: {

			stage = "Close to going out."; //stage 1
		}
		case 6..10: {

			stage = "Small but steady."; //stage 2
		}
		case 11..15: {

			stage = "A stable campfire."; //stage 3
		}
		case 16..20: {

			stage = "The campfire is roaring pretty loudly."; //stage 4
		}
		default: {

			stage = "A massive campfire."; //stage 5+
		}
	}
	return stage;
}