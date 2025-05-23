// a_angles.inc
// Angle functions
// Created by:
// Tannz0rz

#if defined _a_angles_included
  #endinput
#endif
#define _a_angles_included

#include <a_samp>

stock IsPlayerBehindPlayer(playerid, targetid, Float:dOffset = 0.0)
{

	new
	    Float:pa,
	    Float:ta;

	if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid)) return 0;
	
	GetPlayerFacingAngle(playerid, pa);
	GetPlayerFacingAngle(targetid, ta);
	
	if(AngleInRangeOfAngle(pa, ta, dOffset) && IsPlayerFacingPlayer(playerid, targetid, dOffset)) return true;

	return false;

}


stock SetPlayerToFacePlayer(playerid, targetid)
{
	new
	    Float:x[2],
	    Float:y[2],
	    Float:z[2],
	    Float:angle;

	GetPlayerPos(targetid, x[0], y[0], z[0]);
	GetPlayerPos(playerid, x[1], y[1], z[1]);

	angle = (180.0 - atan2(x[1] - x[0], y[1] - y[0]));
	SetPlayerFacingAngle(playerid, angle + (5.0 * -1));
}

stock IsPlayerFacingPlayer(playerid, targetid, Float:dOffset)
{

	new
		Float:pX,
		Float:pY,
		Float:pZ,
		Float:pA,
		Float:X,
		Float:Y,
		Float:Z,
		Float:ang;

	if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid)) return 0;

	GetPlayerPos(targetid, pX, pY, pZ);
	GetPlayerPos(playerid, X, Y, Z);
	GetPlayerFacingAngle(playerid, pA);

	if( Y > pY ) ang = (-acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 90.0);
	else if( Y < pY && X < pX ) ang = (acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 450.0);
	else if( Y < pY ) ang = (acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 90.0);

	if(AngleInRangeOfAngle(-ang, pA, dOffset)) return true;

	return false;

}

stock AngleInRangeOfAngle(Float:a1, Float:a2, Float:range)
{

	a1 -= a2;
	if((a1 < range) && (a1 > -range)) return true;

	return false;

}
