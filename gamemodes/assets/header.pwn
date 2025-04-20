#if defined _inc_header
	#undef _inc_header
#endif

/*

	Player skins use ranges: 20000 to 30000 (10000 slots)
	Objects use negative IDs: -1000 to -30000 (29000 slots)

	native AddCharModel(baseid, newid, dffname[], txdname[]);
	native AddSimpleModel(virtualworld, baseid, newid, dffname[], txdname[]);
*/


#define CUSTOM_OBJECT_BASEID    	(1923) // poker chip, no col
#define CUSTOM_SKIN_MALE_BASEID 	(292)
#define CUSTOM_SKIN_FEMALE_BASEID 	(191)

#include "assets/data.pwn"

/******************************************************************************/

new bool: IsPlayerFinishedDownloading [ MAX_PLAYERS ] ;
new baseurl[] = "http://files.wildwest-roleplay.com/models";

public OnPlayerRequestDownload ( playerid, type, crc ) {

    new dlfilename [ 64 + 1 ], foundfilename = 0;
    
    if ( !IsPlayerConnected ( playerid ) ) return 0;
    
    switch ( type ) {

    	case DOWNLOAD_REQUEST_TEXTURE_FILE: foundfilename = FindTextureFileNameFromCRC ( crc, dlfilename, sizeof ( dlfilename ) ) ;
    	case DOWNLOAD_REQUEST_MODEL_FILE: 	foundfilename = FindModelFileNameFromCRC ( crc, dlfilename, sizeof ( dlfilename ) ) ;
    }

    if ( foundfilename ) {

		RedirectDownload ( playerid, sprintf("%s/%s", baseurl, dlfilename) ) ;
    }
    
    return 0;
}

public OnPlayerFinishedDownloading(playerid, virtualworld) {

	if(!IsPlayerFinishedDownloading[playerid]) {
    	
    	IsPlayerFinishedDownloading [ playerid ] = true ;
    	SendClientMessage(playerid, COLOR_CLIENT, "Downloads finished.");
    	#if defined OPEN_BETA_TEST

    		for ( new i; i < 20; i ++ ) {

				SendClientMessage( playerid, -1, " " ) ;
			}
    		ShowBETAMessage(playerid);

    	#endif
    	//Account_ConnectionCheck ( playerid ) ;
	}
    return 1;
}

/******************************************************************************/

public OnGameModeInit() {
	
	LoadSkinModels();
	LoadObjectModels();

	#if defined models_OnGameModeInit
		return models_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif

#define OnGameModeInit models_OnGameModeInit
#if defined models_OnGameModeInit
	forward models_OnGameModeInit();
#endif