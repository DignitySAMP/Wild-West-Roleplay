/*

	TO DO:
	-> finish cop system

	-> convert attack timer to global tasks
*/

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////


#define MAX_POSSES	( 15 )

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

#include "data/posse/kiosk/func/data.pwn"
#include "data/posse/func/data.pwn"
#include "data/posse/kiosk/core/cmds.pwn"
#include "data/posse/core/cmds.pwn"
//#include "data/posse/colors.pwn"
//
#include "data/posse/posse/cop/charges.pwn"
#include "data/posse/posse/cop/core.pwn"
#include "data/posse/posse/cop/prison.pwn"
#include "data/posse/posse/cop/transmittor.pwn"

#include "data/posse/posse/poster.pwn"
//#include "data/posse/zones.pwn"

/*

	-- Posse membership is checked by possetier, so set it to 0 when you uninvite them
*/

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

CMD:possehelp ( playerid, params[] ) {

	new  posseid = Character [ playerid ] [ character_posse ] ;

	if ( IsPlayerInPosse ( playerid ) && Posse [ posseid ] [ posse_type ] == 1 ) {

		SendClientMessage ( playerid, ADMIN_BLUE, "[POLICE] /cuff, /disarm, /charge, /clearcharge, /viewcharges, /prison, /unprison" ) ;
		SendClientMessage ( playerid, ADMIN_BLUE, "[POLICE] /pkiosk, /poster, /td (/r), /removeposter, /viewdebt, /prisoners, /tackle" ) ;
	}

	return cmd_posse ( playerid, params );
}

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////