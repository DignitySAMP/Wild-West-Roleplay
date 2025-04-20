enum MountAnimations {

	mount_anim_type,
	mount_anim_txd[256]
} ;
enum {

	HORSE_MODEL_DONKEY,
	HORSE_MODEL_BROWN,
	HORSE_MODEL_WHITE_BROWN,
	HORSE_MODEL_GREY,
}




//#include "player/horse/func/data/horse.pwn" // horse model data
//#include "player/horse/func/data/donkey.pwn" // donkey model data

/*

new PlayerSpawnedHorse [ MAX_PLAYERS ] ;

#include "utils/horse/func/data/horse.pwn" // horse model data

CMD:horsemodel(playerid, params[]) {

	if ( ++ PlayerSpawnedHorse [ playerid ] > 3 ) {

		PlayerSpawnedHorse [ playerid ] = 0 ;
	}

	return true ;
}

*/


timer EnableHorseAnimation[100](playerid) {

	if ( IsPlayerRidingHorse [ playerid ] ) {

		if (PlayerSpawnedHorse [ playerid ] == INVALID_HORSE_ID ) {

			return SendServerMessage ( playerid, "Error fetching horse model. Animations cancelled. Try remounting.", MSG_TYPE_ERROR ) ;
		}

	 	new k, ud, lr ;

		GetPlayerKeys(playerid, k, ud, lr);

		if ( PlayerSpawnedHorse [ playerid ] > HORSE_MODEL_DONKEY ) {
			
			FetchHorseAnimations(playerid, k, ud, lr );
		}

		/*
		else if ( PlayerSpawnedHorse [ playerid ] == HORSE_MODEL_DONKEY ) {

			FetchDonkeyAnimations(playerid, k, ud, lr );
		}
		*/

	}

	return true ;
}
