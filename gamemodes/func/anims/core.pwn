new gPlayerUsingLoopingAnim[MAX_PLAYERS];
new gPlayerAnimLibsPreloaded[MAX_PLAYERS];

new Text: txtAnimHelper ;

#include "func/anims/func/preload.pwn"
#include "func/anims/func/handler.pwn"
#include "func/anims/func/anims.pwn"

LoadAnimTextDraw ( ) {

	txtAnimHelper = TextDrawCreate(610.0, 400.0,
	"~r~~k~~PED_SPRINT~ ~w~to stop the animation");

	TextDrawUseBox(txtAnimHelper, 0);
	TextDrawFont(txtAnimHelper, 2);
	TextDrawSetShadow(txtAnimHelper,0); // no shadow
    TextDrawSetOutline(txtAnimHelper,1); // thickness 1
    TextDrawBackgroundColor(txtAnimHelper,0x000000FF);
    TextDrawColor(txtAnimHelper,0xFFFFFFFF);
    TextDrawAlignment(txtAnimHelper,3); // align right
}

AnimationLoop(playerid, animlib[], animname[], Float: speed, loop, lockx, locky, freeze, time, forcesync ) {

	ApplyAnimation(playerid, animlib, animname, speed, loop, lockx, locky, freeze, time, forcesync );

    gPlayerUsingLoopingAnim[playerid] = 1;

    /*if ( ! Character [ playerid ] [ character_dmgmode ] ) {
		TextDrawShowForPlayer(playerid, txtAnimHelper);	
    }
    
    else TextDrawHideForPlayer(playerid, txtAnimHelper);*/	

	return true ;
}

AnimationCheck ( playerid ) {

	if ( IsPlayerRidingHorse [ playerid ] || IsPlayerInAdminJail [ playerid ] || Character [ playerid ] [ character_dmgmode ] || IsPlayerTrapped[playerid]) {

		return false ;
	}

	return true ;
}

ClearAnimLoop ( playerid ) {

	gPlayerUsingLoopingAnim[playerid] = 0;
    ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
}
