/*


_model variable should be changed to _array, as it should pull the modelid from the array.
Add a /buy command for toy purchasing, with gammix new dialog include
While we're at it, update this include as well and add a directory in Drive for david & me

*/

enum {

	ATTACH_TYPE_INVALID,
	ATTACH_TYPE_SPINE,
	ATTACH_TYPE_HEAD,
	ATTACH_TYPE_ARM_LEFT,
	ATTACH_TYPE_ARM_RIGHT,
	ATTACH_TYPE_HAND_LEFT,
	ATTACH_TYPE_HAND_RIGHT,
	ATTACH_TYPE_THIGH_LEFT,
	ATTACH_TYPE_THIGH_RIGHT,
	ATTACH_TYPE_FOOT_LEFT,
	ATTACH_TYPE_FOOT_RIGHT,
	ATTACH_TYPE_CALF_RIGHT,
	ATTACH_TYPE_CALF_LEFT,
	ATTACH_TYPE_FOREARM_LEFT,
	ATTACH_TYPE_FOREARM_RIGHT,
	ATTACH_TYPE_SHOULDER_LEFT,
	ATTACH_TYPE_SHOULDER_RIGHT,
	ATTACH_TYPE_NECK,
	ATTACH_TYPE_JAW
} ;


new PlayerAddingAttachment [ MAX_PLAYERS ] ;
new PlayerEditingObject [ MAX_PLAYERS ] ;

#include "func/attachments/store.pwn" // attachments
#include "func/attachments/data.pwn"
#include "func/attachments/func.pwn"

ShowToyMenu ( playerid ) {

   	new sQuery [ 2048*2 ], temp [ 36 ] ;

	for ( new i; i < sizeof ( Attachments ); i ++ ) {

		temp[0] = EOS ;
		strcat(temp, Attachments [ i ] [ attach_name ], 36 ) ;

		if ( strlen ( Attachments [ i ] [ attach_name ] ) > 12 ) {

			strins(temp, "~n~", 12, 3) ;
		}
		switch(Attachments[i][attach_model]) {
			
			case BANDANA_BROWN,BANDANA_GREEN,BANDANA_OLIVE,BANDANA_ORANGE,BANDANA_PURPLE,BANDANA_RED: { format ( sQuery, sizeof ( sQuery ), "%s%i(0.0, 0.0, -45.0, 2.2)\t%s\n", sQuery, Attachments [ i ] [ attach_model ], Attachments [ i ] [ attach_name ]) ; }
			case BELT_BLACK,BELT_BLACKB,BELT_BROWN,BELT_BROWNB,BELT_BULLETS,BELT_ORANGE: { format ( sQuery, sizeof ( sQuery ), "%s%i(0.0, 0.0, -45.0, 3.0)\t%s\n", sQuery, Attachments [ i ] [ attach_model ], Attachments [ i ] [ attach_name ]) ; }
		    case BANDOLIER: { format ( sQuery, sizeof ( sQuery ), "%s%i(0.0, 0.0, -45.0, 5.0)\t%s\n", sQuery, Attachments [ i ] [ attach_model ], Attachments [ i ] [ attach_name ]) ; }
		    case HOLSTER_1,HOLSTER_2,HOLSTER_3,HOLSTER_4,HOLSTER_5,HOLSTER_6,SHEATH_1,SHEATH_2: { format ( sQuery, sizeof ( sQuery ), "%s%i(90.0, 90.0, -45.0, 5.0)\t%s\n", sQuery, Attachments [ i ] [ attach_model ], Attachments [ i ] [ attach_name ]) ; }
		    case KERCHIEF_BLUE,KERCHIEF_GREY,KERCHIEF_OLIVE,KERCHIEF_ORANGE,KERCHIEF_PURPLE,KERCHIEF_RED: { format ( sQuery, sizeof ( sQuery ), "%s%i(90.0, 90.0, -45.0, 2.2)\t%s\n", sQuery, Attachments [ i ] [ attach_model ], Attachments [ i ] [ attach_name ]) ; }
		    case PONCHO_1,PONCHO_2,PONCHO_3,PONCHO_4,PONCHO_5,PONCHO_6,PONCHO_7,PONCHO_8: { format ( sQuery, sizeof ( sQuery ), "%s%i(0.0, -90.0, 5.0, 5.5)\t%s\n", sQuery, Attachments [ i ] [ attach_model ], Attachments [ i ] [ attach_name ]) ; }
		    case POUCH_1,POUCH_2,POUCH_3: { format ( sQuery, sizeof ( sQuery ), "%s%i(0.0, 0.0, -45.0, 1.6)\t%s\n", sQuery, Attachments [ i ] [ attach_model ], Attachments [ i ] [ attach_name ]) ; }
		    case VEST_BLACK,VEST_BLUE,VEST_BROWN,VEST_GREEN,VEST_GREY,VEST_REDA,VEST_REDB: { format ( sQuery, sizeof ( sQuery ), "%s%i(0.0, 0.0, -175.0, 5.0)\t%s\n", sQuery, Attachments [ i ] [ attach_model ], Attachments [ i ] [ attach_name ]) ; }
			default: { format ( sQuery, sizeof ( sQuery ), "%s%i\t%s\n", sQuery, Attachments [ i ] [ attach_model ], Attachments [ i ] [ attach_name ]) ; }
		}

	}

	inline ToyStoreList(pid, dialogid, response, listitem, string:inputtext[]) {

   		#pragma unused inputtext, dialogid, pid, listitem, response

   		if ( response ) {

   			if ( ! Character [ playerid ] [ character_handmoney ] ) {

   				if ( Character [ playerid ] [ character_handchange ] < 50 ) {

   					return SendServerMessage ( playerid, "You don't have enough money. All attachments cost $0.50!", MSG_TYPE_ERROR ) ;
   				}
   			}

   			if ( Attachments [ listitem ] [ attach_model ] == 19347 || Attachments [ listitem ] [ attach_model ] == 19774 || Attachments [ listitem ] [ attach_model ] == 19775 || Attachments [ listitem ] [ attach_model ] == 19776 ) {

   				if ( ! IsLawEnforcementPosse ( Character [ playerid ] [ character_posse ] ) ) {

   					SendServerMessage ( playerid, "You need to be in a law enforcement posse to buy this attachment.", MSG_TYPE_ERROR ) ;
   					ShowToyMenu ( playerid ) ;
   					return true ;
   				}
   			}

   			new objectid = Attachments [ listitem ] [ attach_model ] ;

   			PlayerAddingAttachment [ playerid ] = listitem ;

   			new string[1024];
   			new BoneNames [] [] = {
				
				"Invalid", "Spine", "Head", "Left Arm", "Right Arm", "Left Hand", "Right Hand", "Left Thigh", "Right Thigh",
				"Left Foot", "Right Foot", "Right Calf", "Left Calf", "Left Forearm", "Right Forearm", "Left Shoulder", "Right Shoulder",
				"Neck", "Jaw" 
			} ;

			string[0] = EOS;

			for ( new i = 1, j = sizeof ( BoneNames ); i < j ; i ++ ) {
	
				format ( string, sizeof ( string ), "%s\n%s", string, BoneNames [ i ] [ 0 ] ) ;
			}

   			inline ToyStoreBoneSel(pid1, dialogid1, response1, listitem1, string:inputtext1[]) {

   				#pragma unused inputtext1, dialogid1, pid1

   				if(response1) {

   					new bone = listitem1+1;

		   			SendServerMessage ( playerid, "Adjust the model to your needs. Once you click save, the money will be taken from you.", MSG_TYPE_INFO ) ;
		   			//SendServerMessage(playerid,"Please wait...",MSG_TYPE_INFO);

					new slot = GetFreeAttachmentSlot ( playerid ) ;

					if ( slot == -1) {

						return SendServerMessage ( playerid, "You don't seem to have a free attachment slot. Please unequip an item first.", MSG_TYPE_ERROR ) ;
					}

					PlayerEditingObject [ playerid ] = slot ;

					SetPlayerAttachedObject ( playerid, slot, objectid, bone ) ;
					EditAttachedObject ( playerid, PlayerEditingObject [ playerid ] ) ;
					//SetPVarInt(playerid,"editing_attachment",1);	
					//defer AllowAttachEdit(playerid);
   				}
   				else { Dialog_ShowCallback(playerid, using inline ToyStoreList, DIALOG_STYLE_PREVMODEL,  "Attachments Store", sQuery, "Select", "Cancel"); }
   			}
   			Dialog_ShowCallback(playerid,using inline ToyStoreBoneSel,DIALOG_STYLE_LIST,"Choose Attachment Bone",string,"Select","Cancel");
   		}
   	}

   	Dialog_ShowCallback(playerid, using inline ToyStoreList, DIALOG_STYLE_PREVMODEL,  "Attachments Store", sQuery, "Select", "Cancel");

	return true ;
}

GetFreeAttachmentSlot ( playerid ) {

	for ( new i; i < MAX_ATTACHMENTS; i ++ ) {

		if ( PlayerAttachments [ playerid ] [ i ] [ attach_character_array ] == -1 ) {

			return i ;
		}

		else continue ;
	}

	return -1 ;
}