#if defined _inc_core
	#undef _inc_core
#endif

enum {

	HAIR_NONE,

	BEARD_SLIGHT,
	BEARD_SMALL,
	BEARD_MEDIUM,
	BEARD_LONG,
	BEARD_EXTREME,

	MOUSTACHE_SMALL,
	MOUSTACHE_MEDIUM,
	MOUSTACHE_LONG,
}

GetHairType(playerid){
	return Character[playerid][character_beard];
}

SetHairType(playerid, hairtype){

	if(Character[playerid][character_gender] == 1)
		return true;

	Character[playerid][character_beard] = hairtype;

	return true;
}

RemoveHairStage(playerid){

	if(Character[playerid][character_gender] == 1)
		return true;

	switch(Character[playerid][character_beard]){

		case HAIR_NONE: 
			print("can't remove a non-existent hair.");

		case BEARD_SLIGHT: {
			Character[playerid][character_beard] = HAIR_NONE;
			printf("char %i new haircut: none", Character[playerid][character_id]);
		}

		case BEARD_SMALL: {
			Character[playerid][character_beard] = BEARD_SLIGHT;
			printf("char %i new haircut: beard slight", Character[playerid][character_id]);
		}

		case BEARD_SLIGHT: {
			Character[playerid][character_beard] = BEARD_MEDIUM;
			printf("char %i new haircut: beard medium", Character[playerid][character_id]);
		}

		case BEARD_MEDIUM: {
			Character[playerid][character_beard] = BEARD_LONG;
			printf("char %i new haircut: beard long", Character[playerid][character_id]);
		}

		case BEARD_LONG: {
			Character[playerid][character_beard] = BEARD_EXTREME;
			printf("char %i new haircut: beard extreme", Character[playerid][character_id]);
		}

		case BEARD_EXTREME: {
			printf("char %i new haircut: can't grow anymore", Character[playerid][character_id]);
		}

		case MOUSTACHE_SMALL: {
			Character[playerid][character_beard] = HAIR_NONE;
			printf("char %i new haircut: none", Character[playerid][character_id]);
		}

		case MOUSTACHE_MEDIUM: {
			Character[playerid][character_beard] = MOUSTACHE_SMALL;
			printf("char %i new haircut: moustache small", Character[playerid][character_id]);
		}

		case MOUSTACHE_LONG: {
			Character[playerid][character_beard] = MOUSTACHE_MEDIUM;
			printf("char %i new haircut: medium moustache", Character[playerid][character_id]);
		}
	}

	return true;
}


