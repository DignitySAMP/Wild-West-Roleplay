new IsPlayerMasked [ MAX_PLAYERS ] ;

CMD:resyncmask ( playerid, params [] ) {

    if ( ! Character [ playerid ] [ character_mask ] ) {

        return SendServerMessage ( playerid, "You don't have a mask. Buy one in a clothing store.", MSG_TYPE_ERROR ) ;
    }

    if ( IsPlayerMasked [ playerid ] ) {

        switch ( Character [ playerid ] [ character_mask ] ) {
            case 1: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18919, 2, 0.078534, 0.041857, -0.001727, 268.970458, 1.533374, 269.223754); 
            case 2: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18912, 2, 0.078534, 0.041857, -0.001727, 268.970458, 1.533374, 269.223754); 
            case 3: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18913, 2, 0.078534, 0.041857, -0.001727, 268.970458, 1.533374, 269.223754); 
            case 4: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18918, 2, 0.078534, 0.041857, -0.001727, 268.970458, 1.533374, 269.223754); 
            case 5: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18911, 2, 0.078534, 0.041857, -0.001727, 268.970458, 1.533374, 269.223754); 
            case 6: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 11704, 2, 0.086534, 0.095857, 0.003273, -90.629531, 101.533355, 269.223754,0.254000,0.369999,0.360000);

        }
    }

    else return SendServerMessage ( playerid, "You're not masked - use /mask.", MSG_TYPE_ERROR ) ;

    return true ;
}

CMD:editmask ( playerid, params [] ) {
 
    if ( ! Character [ playerid ] [ character_mask ] ) {

        return SendServerMessage ( playerid, "You don't have a mask. Buy one in a clothing store.", MSG_TYPE_ERROR ) ;
    }

    if ( IsPlayerMasked [ playerid ] ) {



        switch ( Character [ playerid ] [ character_mask ] ) {
            case 1: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18919, 2, 0.078534, 0.041857, -0.001727, 268.970458, 1.533374, 269.223754); 
            case 2: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18912, 2, 0.078534, 0.041857, -0.001727, 268.970458, 1.533374, 269.223754); 
            case 3: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18913, 2, 0.078534, 0.041857, -0.001727, 268.970458, 1.533374, 269.223754); 
            case 4: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18918, 2, 0.078534, 0.041857, -0.001727, 268.970458, 1.533374, 269.223754); 
            case 5: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18911, 2, 0.078534, 0.041857, -0.001727, 268.970458, 1.533374, 269.223754); 
            case 6: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 11704, 2, 0.086534, 0.095857, 0.003273, -90.629531, 101.533355, 269.223754, 0.254000, 0.369999,0.360000);

        }

        EditAttachedObject(playerid, ATTACH_SLOT_MASK) ;
        SendServerMessage ( playerid, "You can now edit the mask. Reminder: equipping an item will remove it.", MSG_TYPE_ERROR ) ;
    }

    else return SendServerMessage ( playerid, "You're not masked - use /mask.", MSG_TYPE_ERROR ) ;

    return true ;
}

CMD:mask ( playerid, params [] ) {

	if ( Character [ playerid ] [ character_level ] < 10 ) {

        return SendServerMessage ( playerid, "You need to be level 10 to use a mask.", MSG_TYPE_ERROR ) ;
    }

    if ( ! Character [ playerid ] [ character_mask ] ) {

		return SendServerMessage ( playerid, "You don't have a mask. Buy one in a clothing store.", MSG_TYPE_ERROR ) ;
	}

	if ( ! IsPlayerMasked [ playerid ] ) {

        switch ( Character [ playerid ] [ character_mask ] ) {
            case 1: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18919, 2, Character [ playerid ] [ character_mask_offsetx ], Character [ playerid ] [ character_mask_offsety ], Character [ playerid ] [ character_mask_offsetz ], Character [ playerid ] [ character_mask_rotx ], Character [ playerid ] [ character_mask_roty ], Character [ playerid ] [ character_mask_rotz ], Character [ playerid ] [ character_mask_scalex ], Character [ playerid ] [ character_mask_scaley ], Character [ playerid ] [ character_mask_scalez ] ); 
            case 2: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18912, 2, Character [ playerid ] [ character_mask_offsetx ], Character [ playerid ] [ character_mask_offsety ], Character [ playerid ] [ character_mask_offsetz ], Character [ playerid ] [ character_mask_rotx ], Character [ playerid ] [ character_mask_roty ], Character [ playerid ] [ character_mask_rotz ], Character [ playerid ] [ character_mask_scalex ], Character [ playerid ] [ character_mask_scaley ], Character [ playerid ] [ character_mask_scalez ] );
            case 3: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18913, 2, Character [ playerid ] [ character_mask_offsetx ], Character [ playerid ] [ character_mask_offsety ], Character [ playerid ] [ character_mask_offsetz ], Character [ playerid ] [ character_mask_rotx ], Character [ playerid ] [ character_mask_roty ], Character [ playerid ] [ character_mask_rotz ], Character [ playerid ] [ character_mask_scalex ], Character [ playerid ] [ character_mask_scaley ], Character [ playerid ] [ character_mask_scalez ] );
            case 4: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18918, 2, Character [ playerid ] [ character_mask_offsetx ], Character [ playerid ] [ character_mask_offsety ], Character [ playerid ] [ character_mask_offsetz ], Character [ playerid ] [ character_mask_rotx ], Character [ playerid ] [ character_mask_roty ], Character [ playerid ] [ character_mask_rotz ], Character [ playerid ] [ character_mask_scalex ], Character [ playerid ] [ character_mask_scaley ], Character [ playerid ] [ character_mask_scalez ] );
            case 5: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 18911, 2, Character [ playerid ] [ character_mask_offsetx ], Character [ playerid ] [ character_mask_offsety ], Character [ playerid ] [ character_mask_offsetz ], Character [ playerid ] [ character_mask_rotx ], Character [ playerid ] [ character_mask_roty ], Character [ playerid ] [ character_mask_rotz ], Character [ playerid ] [ character_mask_scalex ], Character [ playerid ] [ character_mask_scaley ], Character [ playerid ] [ character_mask_scalez ] ); 
            case 6: SetPlayerAttachedObject(playerid, ATTACH_SLOT_MASK, 11704, 2, Character [ playerid ] [ character_mask_offsetx ], Character [ playerid ] [ character_mask_offsety ], Character [ playerid ] [ character_mask_offsetz ], Character [ playerid ] [ character_mask_rotx ], Character [ playerid ] [ character_mask_roty ], Character [ playerid ] [ character_mask_rotz ], Character [ playerid ] [ character_mask_scalex ], Character [ playerid ] [ character_mask_scaley ], Character [ playerid ] [ character_mask_scalez ] );
        }
		
		IsPlayerMasked [ playerid ] = true ;
        SendServerMessage ( playerid, "You have masked yourself. If you don't see your mask, use /editmask because it might not be set up properly (yet)!", MSG_TYPE_WARN ) ;
	}

	else if ( IsPlayerMasked [ playerid ] ) {

		IsPlayerMasked [ playerid ] = false ;
		RemovePlayerAttachedObject(playerid, ATTACH_SLOT_MASK ) ;
        SendServerMessage ( playerid, "You have unmasked yourself.", MSG_TYPE_INFO) ; 
	}

	SetName ( playerid, sprintf("(%d) %s", playerid, ReturnUserName ( playerid, false, true ) ), 0xCFCFCFFF ) ;
	//OldLog ( playerid, "masks", sprintf("(%d) %s mask_equip variable changed: %d (0: off, 1: on) [MASK ID: %d]", playerid, ReturnUserName ( playerid, true ), IsPlayerMasked [ playerid ], Character [ playerid ] [ character_mask ]  )) ;


	return true ;
}

ReturnPlayerMasked ( playerid ) {

    return IsPlayerMasked [ playerid ] ;
}

ShowMaskSelection ( playerid ) {

	inline Buy_Mask(pid, dialogid, response, listitem, string:inputtext[]) {
	    #pragma unused pid, response, dialogid, listitem, inputtext

        PlayerPlaySound ( playerid, 1085, 0.0, 0.0, 0.0 ) ;

        if ( ! response ) {

        	return false ;
        }

        switch ( listitem ) {

        	case 0: {

        		if ( Character [ playerid ] [ character_handmoney ] < 5 ) {

        			return SendServerMessage ( playerid, "You need at least $5 in order to purchase this.", MSG_TYPE_ERROR ) ;
        		}

        		TakeCharacterMoney ( playerid, 5, MONEY_SLOT_HAND ) ;

	     	 	Character [ playerid ] [ character_mask ] = 1 ;
        		SendServerMessage ( playerid, "You've bought a white bandana for $5. You can now use /mask.", MSG_TYPE_INFO ) ;
        	}

        	case 1: {
        		if ( Character [ playerid ] [ character_handmoney ] < 7 ) {

        			return SendServerMessage ( playerid, "You need at least $7 in order to purchase this.", MSG_TYPE_ERROR ) ;
        		}

        		TakeCharacterMoney ( playerid, 7, MONEY_SLOT_HAND ) ;

        		Character [ playerid ] [ character_mask ] = 2 ;
        		SendServerMessage ( playerid, "You've bought a black bandana for $7. You can now use /mask.", MSG_TYPE_INFO ) ;
        	}

        	case 2: {
        		if ( Character [ playerid ] [ character_handmoney ] < 7 ) {

        			return SendServerMessage ( playerid, "You need at least $7 in order to purchase this.", MSG_TYPE_ERROR ) ;
        		}

        		TakeCharacterMoney ( playerid, 7, MONEY_SLOT_HAND ) ;

        		Character [ playerid ] [ character_mask ] = 3 ;
        		SendServerMessage ( playerid, "You've bought a green bandana for $7. You can now use /mask.", MSG_TYPE_INFO ) ;
        	}

        	case 3: {
        		if ( Character [ playerid ] [ character_handmoney ] < 10 ) {

        			return SendServerMessage ( playerid, "You need at least $10 in order to purchase this.", MSG_TYPE_ERROR ) ;
        		}

        		TakeCharacterMoney ( playerid, 10, MONEY_SLOT_HAND ) ;

        		Character [ playerid ] [ character_mask ] = 4 ;
        		SendServerMessage ( playerid, "You've bought a olive bandana for $10. You can now use /mask.", MSG_TYPE_INFO ) ;
        	}

        	case 4: {
        		if ( Character [ playerid ] [ character_handmoney ] < 10 ) {

        			return SendServerMessage ( playerid, "You need at least $10 in order to purchase this.", MSG_TYPE_ERROR ) ;
        		}

        		TakeCharacterMoney ( playerid, 10, MONEY_SLOT_HAND ) ;

        		Character [ playerid ] [ character_mask ] = 5 ;
        		SendServerMessage ( playerid, "You've bought a skull bandana for $10. You can now use /mask.", MSG_TYPE_INFO ) ;
        	}
        }

		new query [ 256 ] ; 

		mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_mask = %d WHERE character_id = '%d'", 
			Character [ playerid ] [ character_mask ],  Character [ playerid ] [ character_id ]) ;

		mysql_tquery ( mysql, query ) ;

		return true ;
	}

  	Dialog_ShowCallback(playerid, using inline Buy_Mask, DIALOG_STYLE_PREVMODEL,  "Mask Selection", "18919\tWhite Bandana ($5.00)\n18912\tBlack Bandana ($7.00)\n18913\tGreen Bandana ($7.00)\n18918\tOlive Bandana ($10.00)\n18911\tSkull Bandana ($10.00)", "Select", "Cancel");

	return true ;
}