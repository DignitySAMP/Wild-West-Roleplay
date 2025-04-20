/*


--> ammo crates
--> dropgun

*/


#include "data/weps/func/cmds.pwn"
#include "data/weps/func/natives.pwn"
#include "data/weps/func/drop.pwn"
#include "data/weps/func/attach.pwn"
#include "data/weps/func/ammo.pwn"

SavePlayerWeapons ( playerid ) {
	new query [ 256 ] ; 

	mysql_format ( mysql, query, sizeof ( query ), 
		"UPDATE characters SET character_handweapon = %d, character_handammo = %d WHERE character_id = %d", 
		Character [ playerid ] [ character_handweapon ], Character [ playerid ] [ character_handammo ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	mysql_format ( mysql, query, sizeof ( query ), 
		"UPDATE characters SET character_backweapon = %d, character_backammo = %d WHERE character_id = %d", 
		Character [ playerid ] [ character_backweapon ], Character [ playerid ] [ character_backammo ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	mysql_format ( mysql, query, sizeof ( query ), 
		"UPDATE characters SET character_pantsweapon = %d, character_pantsammo = %d WHERE character_id = %d", 
		Character [ playerid ] [ character_pantsweapon ], Character [ playerid ] [ character_pantsammo ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	SetupPlayerGunAttachments ( playerid ) ;

	return true ;
}

RemovePlayerWeapon(playerid) {

	new query [ 256 ] ;
  
	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_handweapon = 0, character_handammo = 0 WHERE character_id = %d", Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query);

    Character [ playerid ] [ character_handweapon ] = 0 ;
 	Character [ playerid ] [ character_handammo ] = 0 ;

	if(IsPlayerAttachedObjectSlotUsed(playerid,ATTACH_SLOT_HANDS)) { RemovePlayerAttachedObject ( playerid, ATTACH_SLOT_HANDS ) ; }
	ResetPlayerWeaponsEx ( playerid ) ;

	//LoadWeaponPanel ( playerid ) ;

	UpdateWeaponGUI ( playerid ) ;
	//OldLog ( playerid, "guns/script", sprintf ( "[REMOVEPLAYERWEAPON CALLED] %s's guns have been reset.", ReturnUserName ( playerid, false ) )) ;

	return true ;
}

wep_GivePlayerWeapon ( playerid, weaponid, ammo) {

	if ( Character [ playerid ] [ character_handweapon] ) {

		return SendServerMessage ( playerid, "You already have a weapon equipped. Holster it first.", MSG_TYPE_ERROR ) ;
	}

	if ( EquippedItem [playerid] != -1) {

		return SendServerMessage(playerid,"You need to unequip your current item before buying a weapon.",MSG_TYPE_ERROR);
	}

	if(IsPlayerAttachedObjectSlotUsed(playerid,ATTACH_SLOT_HANDS)) { RemovePlayerAttachedObject ( playerid, ATTACH_SLOT_HANDS ) ; }
	ResetPlayerWeaponsEx ( playerid ) ;

	Character [ playerid ] [ character_handweapon] 		= weaponid ;
	Character [ playerid ] [ character_handammo] 		= ammo ;

	new query [ 256 ] ;

	mysql_format ( mysql, query, sizeof ( query ), 
		"UPDATE characters SET character_handweapon = %d, character_handammo = %d WHERE character_id = %d", 
		Character [ playerid ] [ character_handweapon ], Character [ playerid ] [ character_handammo ], Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;

	printf("wep_giveplayerweapon called:%d, %d", Character [ playerid ] [ character_handweapon], Character [ playerid ] [ character_handammo] ) ;

	PlayReloadAnimation ( playerid, weaponid ) ;

    if ( ammo > 0 ) {
 		GivePlayerWeapon ( playerid, weaponid, ammo );
 	}

 	else {
 		
 		if(weaponid != WEAPON_BAT && weaponid != WEAPON_KNIFE) { if(!IsPlayerAttachedObjectSlotUsed(playerid,ATTACH_SLOT_HANDS)) { SetPlayerAttachedObject(playerid, ATTACH_SLOT_HANDS, ReturnWeaponObjectEx ( weaponid ), 6, 0.004, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0 ); } }
 	}

	UpdateWeaponGUI ( playerid ) ;

	return true ;
}

ReturnWeaponObject ( playerid )  {
	new object = 0;

	switch ( GetPlayerWeapon ( playerid ) ) {
		case WEAPON_KNIFE: 		object = 335 ;
		case WEAPON_BAT:		object = 336 ;
		case WEAPON_DEAGLE: 	object = 348 ;
		case WEAPON_SHOTGUN: 	object = 349 ;
		case WEAPON_SAWEDOFF: 	object = 350 ;
		case WEAPON_CAMERA:		object = 367 ;
		case WEAPON_RIFLE: 		object = 357 ;
		case WEAPON_SNIPER: 	object = 358 ;
		default: 				return 0 ;
	}

	return object;
}

ReturnWeaponObjectEx ( weaponid )  {
	new object = 0;

	switch ( weaponid ) {
		case WEAPON_KNIFE: 		object = 335 ;
		case WEAPON_BAT:		object = 336 ;
		case WEAPON_DEAGLE: 	object = 348 ;
		case WEAPON_SHOTGUN: 	object = 349 ;
		case WEAPON_SAWEDOFF: 	object = 350 ;
		case WEAPON_CAMERA:		object = 367 ;
		case WEAPON_RIFLE: 		object = 357 ;
		case WEAPON_SNIPER: 	object = 358 ;
		default: 				return 0 ;
	}

	return object;
}

ReturnWeaponIDFromModel ( modelid ) {

	switch ( modelid ) {
		case 335:	return WEAPON_KNIFE ;
		case 336:	return WEAPON_BAT ;
		case 348: 	return WEAPON_DEAGLE ;
		case 349: 	return WEAPON_SHOTGUN ;
		case 350: 	return WEAPON_SAWEDOFF ;
		case 367: return WEAPON_CAMERA ;
		case 357: 	return WEAPON_RIFLE ;
		case 358: 	return WEAPON_SNIPER ;	
		default: 	return -1 ;
	}

	return -1 ;
}

IsValidWeapon ( weaponid ) {

	switch ( weaponid ) {

		case WEAPON_DEAGLE, WEAPON_SHOTGUN, WEAPON_RIFLE, 
		WEAPON_SNIPER, WEAPON_SAWEDOFF, WEAPON_CAMERA: {
			return true ;
		}

		default: return false ;
	}

	return false;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////