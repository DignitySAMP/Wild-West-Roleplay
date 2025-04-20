#include "utils/msgs/files/client.pwn"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

ProxDetector(playerid, Float:max_range, color, string[], Float:max_ratio = 1.6) {

	new Float:pos_x, Float:pos_y, Float:pos_z, Float:range, Float:range_ratio, Float:range_with_ratio ;
	new clr_r, clr_g, clr_b, Float:color_r, Float:color_g, Float:color_b;

	if ( ! GetPlayerPos(playerid, pos_x, pos_y, pos_z ) ) {

		return 0;
	}

	color_r = float(color >> 24 & 0xFF);
	color_g = float(color >> 16 & 0xFF);
	color_b = float(color >> 8 & 0xFF);
	range_with_ratio = max_range * max_ratio;

	foreach (new i : Player) {

		// if (!IsPlayerStreamedIn(i, playerid)) continue;
		range = GetPlayerDistanceFromPoint(i, pos_x, pos_y, pos_z);

		if (range > max_range) continue;

		if ( GetPlayerInterior ( i ) != GetPlayerInterior ( playerid) ) {
			continue ;
		}

		if ( GetPlayerVirtualWorld( i ) != GetPlayerVirtualWorld ( playerid ) ) {
			continue ;
		}

		range_ratio = (range_with_ratio - range) / range_with_ratio;
		clr_r = floatround(range_ratio * color_r);
		clr_g = floatround(range_ratio * color_g);
		clr_b = floatround(range_ratio * color_b);

		SendSplitMessage(i, (color & 0xFF) | (clr_b << 8) | (clr_g << 16) | (clr_r << 24), string);
	}

	//SendSplitMessage(playerid, color, string);
// 	SetPlayerChatBubble(playerid, string, color, max_range, 10000);

	return 1;
}

SendSplitMessage ( playerid, color, text [] ) {

	/*
	if ( strlen ( text ) > 100 ) {

		SendClientMessageFormatted ( playerid, color, "%.100s ...", text ) ;
		SendClientMessageFormatted ( playerid, color, "... %s", text [ 100 ] ) ;
	}

	else return SendClientMessage(playerid, color, text ) ;
	*/

	return ZMsg_SendClientMessage(playerid, color, text) ;
}

SendSplitMessageEx ( playerid, color, text [] ) {

	/*
	if ( strlen ( text ) > 100 ) {

		SendClientMessageFormatted ( playerid, color, "%.100s ...", text ) ;
		SendClientMessageFormatted ( playerid, color, "{DEDEDE}... %s", text [ 100 ] ) ;
	}

	else return SendClientMessage(playerid, color, text ) ;
	*/

	return ZMsg_SendClientMessage(playerid, color, text) ;
}

SendSplitMessageToAll ( color, text []  ) {

	/*
	foreach (new i: Player) {

		SendSplitMessage ( i, color, text);
	}
	*/
	return ZMsg_SendClientMessageToAll(color, text);
}


SendOOCMessage ( color, text [] ) {

	foreach (new i: Player) {

		if ( IsPlayerHidingOOC [ i ] ) {

			continue ;
		}

		else SendSplitMessage ( i, color, text);
	}

	return true;
}

