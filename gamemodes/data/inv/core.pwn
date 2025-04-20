#define MAX_DROPPED_ITEMS	( 1000 )
#define MAX_ITEMS   		( 100 )
#define MAX_PLAYER_ITEMS    ( 18 )
#define INVALID_ITEM_ID     ( -1 )

#define INV_MAX_TILES        ( 9 )

#define INVENTORY_TILE_COLOR    		( 0xD17F5EFF )
#define INVENTORY_TILE_BG_COLOR     	( 0x111111FF )
#define INVENTORY_BACKG_COLOR     		( 0x111111AA )

new Float:CookingLocations[][] = {

	{-835.8579,1624.4568,27.0458},
	{-814.7105,1514.9229,20.5856}
};

new bool: PlayerInventoryPage 	[ MAX_PLAYERS ] ; // what page player is in
new bool: IsPlayerViewingInventory [ MAX_PLAYERS ] ;
new bool: PlayerItemsLoaded [ MAX_PLAYERS ] ;
new bool: HasPlayerInventoryUpdated [ MAX_PLAYERS ] ;

#define ERROR_TOO_MANY_ITEMS	(-2 )

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// For dev purposes, you can use this, it creates basic items

#include "data/inv/gui/inv/data.pwn"
#include "data/inv/gui/examine/data.pwn"

#include "data/inv/data/header.pwn"

#include "data/inv/gui/inv/func.pwn"
#include "data/inv/gui/examine/func.pwn"

#include "data/inv/func/drop.pwn"			// drop data

public OnGameModeInit()
{
	for(new i=0; i<sizeof(CookingLocations); i++) {

		CreateDynamic3DTextLabel("Cooking Location{FFFFFF}\nUse uncooked meat items to cook them here.",COLOR_ORANGE,CookingLocations[i][0],CookingLocations[i][1],CookingLocations[i][2],10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1);
	}
	#if defined invcore_OnGameModeInit
		return invcore_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif

#define OnGameModeInit invcore_OnGameModeInit
#if defined invcore_OnGameModeInit
	forward invcore_OnGameModeInit();
#endif

GetPlayerBackpackSize ( playerid ) {

	switch ( Character [ playerid ] [ character_backpack ] ) {
		case 0: {
			return 6 ;
		}

		case 1: {
			return 12 ;
		}
		case 2: {
			return 18 ;
		}
		default: return 6 ;
	}

	return true ;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

GetRarityHex ( itemid ) {

	new hex [ 10 ] ;

	switch ( Item [ itemid ] [ item_rarity ] ) {

		case ITEM_RARITY_NORMAL: 		hex = "{DEDEDE}" ;
		case ITEM_RARITY_COMMON: 		hex = "{72B56B}" ;
		case ITEM_RARITY_RARE: 			hex = "{6092CC}" ;
		case ITEM_RARITY_EPIC: 			hex = "{7B5991}" ;
		case ITEM_RARITY_LEGENDARY:  	hex = "{D6872D}" ;
		default: hex = "{DEDEDE}" ;
	}

	return hex ;
}

IsPlayerInvFull ( playerid ) {

	if ( ReturnPlayerItemCount [ playerid ] >= MAX_PLAYER_ITEMS ) {
	
		return true ;
	}

	else return false ;
}


DestroyPlayerInventoryGUI ( playerid ) {

	for ( new i, j = INV_MAX_TILES; i < j; i ++ ) {
		PlayerTextDrawDestroy ( playerid, InventoryTileOutline  [ i ] ) ;
		PlayerTextDrawDestroy ( playerid, InventoryTile  [ i ] ) ;
		PlayerTextDrawDestroy ( playerid, InventoryTileName  [ i ] ) ;
		PlayerTextDrawDestroy ( playerid, InventoryTileModel  [ i ] ) ;
	}


	for ( new i; i < sizeof ( inventory_examine_ptds ); i ++ ) {

		PlayerTextDrawDestroy ( playerid, inventory_examine_ptds [ i ] ) ;
	}

	return true ;
}

new PlayerInventoryCooldown [ MAX_PLAYERS ] ;

public OnPlayerKeyStateChange (playerid, newkeys, oldkeys) {

	/*
	if ( newkeys & KEY_FIRE && IsPlayerBandaging [ playerid ] ) {

		IsPlayerBandaging [ playerid ] = false ;
		TogglePlayerControllable(playerid, true );

		return SendServerMessage ( playerid, "You've cancelled bandaging yourself.", MSG_TYPE_WARN ) ;
	}*/

	if ( newkeys & KEY_NO ) {
		//Init_LoadPlayerItems ( playerid ) ;

		if ( PlayerInventoryCooldown [ playerid ]  >= gettime ()) {

			return SendServerMessage ( playerid, sprintf("You need to wait %d seconds before opening your inventory again.", PlayerInventoryCooldown[playerid] - gettime ()), MSG_TYPE_WARN ) ;
		}

		PlayerInventoryCooldown [ playerid ] = gettime () + 3 ;

		HideInventoryExamineGUI ( playerid ) ;
		InitiateInventoryTiles ( playerid, PlayerInventoryPage [ playerid ]) ;
	}
		
	#if defined inv_OnPlayerKeyStateChange
		return inv_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif

#define OnPlayerKeyStateChange inv_OnPlayerKeyStateChange
#if defined inv_OnPlayerKeyStateChange
	forward inv_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

public OnPlayerClickTextDraw(playerid, Text:clickedid) {
	
	if ( clickedid == Text: INVALID_TEXT_DRAW ) {
		ToggleInventory ( playerid, INV_MAX_TILES, false ) ;
		HideInventoryExamineGUI ( playerid ) ;
	}

	if ( clickedid == inventory_static_gui [ 4 ] ) {
		ToggleInventory ( playerid, INV_MAX_TILES, false ) ;
		
		PlayerInventoryPage [ playerid ] = true ;
		InitiateInventoryTiles ( playerid, 1 ) ;
    }

    if ( clickedid == inventory_static_gui [ 5 ] ) {
		ToggleInventory ( playerid, INV_MAX_TILES, false ) ;
		PlayerInventoryPage [ playerid ] = false ;
		
		InitiateInventoryTiles ( playerid, 0 ) ;
    }

	#if defined inv_OnPlayerClickTextDraw 
		return inv_OnPlayerClickTextDraw ( playerid, Text: clickedid );
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerClickTextDraw 
	#undef OnPlayerClickTextDraw 
#else
	#define _ALS_OnPlayerClickTextDraw 
#endif

#define OnPlayerClickTextDraw  inv_OnPlayerClickTextDraw 
#if defined inv_OnPlayerClickTextDraw 
	forward inv_OnPlayerClickTextDraw ( playerid, Text: clickedid );
#endif

public OnGameModeInit() {

	LoadStaticInventoryTextDraws ( ) ;
	LoadStaticInventoryExamineGUI ( ) ;
	
	#if defined inv_OnGameModeInit
		return inv_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif

#define OnGameModeInit inv_OnGameModeInit
#if defined inv_OnGameModeInit
	forward inv_OnGameModeInit();
#endif

public OnPlayerConnect(playerid) {
	
	EquippedItem [ playerid ] = -1 ;
	IsPlayerViewingInventory [ playerid ] = false ;
	PlayerItemsLoaded [ playerid ] = false ;
	HasPlayerInventoryUpdated [ playerid ] = false ;

	PlayerExaminingItem [ playerid ] = INVALID_ITEM_ID ;

	LoadInventoryTextDraws ( playerid );
	LoadPlayerInventoryExamineGUI ( playerid )  ;

	#if defined inv_OnPlayerConnect
		return inv_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect inv_OnPlayerConnect
#if defined inv_OnPlayerConnect
	forward inv_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason) {
	
	DestroyPlayerInventoryGUI ( playerid ) ;

	#if defined inv_OnPlayerDisconnect
		return inv_OnPlayerDisconnect(playerid, reason);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif

#define OnPlayerDisconnect inv_OnPlayerDisconnect
#if defined inv_OnPlayerDisconnect
	forward inv_OnPlayerDisconnect(playerid, reason);
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DoesPlayerHaveItem ( playerid, itemid ) {

	for ( new i; i < ReturnPlayerItemCount [ playerid ]; i ++ ) {

		if (  PlayerItem [ playerid ] [ i ] [ player_item_id ] == itemid ) {

			return i ;
		}

		else continue ;
	}

	return -1 ;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:viewplayeritems ( playerid, params [] ) {

	new targetid ;
/*
	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You need to be a moderator in order to be able to do this!", MSG_TYPE_ERROR ) ;
	}*/

	if ( sscanf ( params, "k<u>", targetid ) ) {

		return SendServerMessage ( playerid, "/viewplayeritems [playerid/name]", MSG_TYPE_ERROR ) ;
	}

	new string [ 256 ] ;

	new item_id_name [ MAX_ITEM_NAME ], itemidx, player_items = ReturnPlayerItemCount [ targetid ];

	for ( new i; i < player_items; i ++ ) {
	    itemidx = PlayerItem [ targetid ] [ i ] [ player_item_id ] ;

	    format ( item_id_name, MAX_ITEM_NAME, "%s", Item [ itemidx ] [ item_name ] ) ;

		format ( string, sizeof ( string ), "id: %d | i_id: %d\t i_name: %s\t i_amount: %d\t i_val1: %d\t i_val2: %d\n",
		i, PlayerItem [ targetid ] [ i ] [ player_item_id ], item_id_name, PlayerItem [ targetid ] [ i ] [ player_item_amount ], PlayerItem [ targetid ] [ i ] [ player_item_param1 ], PlayerItem [ targetid ] [ i ] [ player_item_param2 ] );

		SendClientMessage ( playerid, -1, string ) ;
	}

	string [ 0 ] = EOS ;

	return true ;
}

CMD:playeritems ( playerid ) {

	new string [ 1000 ] ; //

	new item_id_name [ MAX_ITEM_NAME ], itemidx, player_items =  ReturnPlayerItemCount [ playerid ];

	for ( new i; i < player_items; i ++ ) {
	    itemidx = PlayerItem [playerid ] [ i ] [ player_item_id ] ;

	    format ( item_id_name, MAX_ITEM_NAME, "%s", Item [ itemidx ] [ item_name ] ) ;

		format ( string, sizeof ( string ), "id: %d | i_id: %d\t i_name: %s\t i_amount: %d\t i_val1: %d\t i_val2: %d\n",
		i, PlayerItem [ playerid ] [ i ] [ player_item_id ], item_id_name, PlayerItem [ playerid ] [ i ] [ player_item_amount ], PlayerItem [ playerid ] [ i ] [ player_item_param1 ], PlayerItem [ playerid ] [ i ] [ player_item_param2 ] );

		SendClientMessage ( playerid, -1, string ) ;
	}

	string [ 0 ] = EOS ;

	return true ;
}

CMD:reloaddata(playerid) return Init_LoadPlayerItems ( playerid ) ;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:giveitem ( playerid, params [] ) {
/*
	if ( ! IsPlayerModerator ( playerid ) ) {

		return false ;
	}
*/

	if ( !IsPlayerAdmin ( playerid ) ) {

		return SendClientMessage(playerid, COLOR_RED, "Fuck off.");
	}

	new id, amount, param1, param2 ;

	if ( sscanf ( params, "iiii", id, amount, param1, param2 ) ) {
	    return SendClientMessage ( playerid, -1, "/giveitem [item id] [amount] [extra param] [extra param] (leave extra params empty if unknown" ) ;
	}

	if ( id < 1 || id >= sizeof ( Item ) ) {

		return SendServerMessage ( playerid, sprintf("You can't go lower than ID 0. You also can't go higher than the maximum number of items (%d).", sizeof ( Item )), MSG_TYPE_ERROR );
	}

	if ( amount > 5 ) {

		return SendServerMessage ( playerid, "A player can only have an item stacked five times.", MSG_TYPE_ERROR ) ;
	}

	GivePlayerItem ( playerid, id, amount, param1, param2, 0 ) ;

	return true ;
}
/*
CMD:createitem ( playerid, params [] ) {

	new itemname [ MAX_ITEM_NAME], itemmodel, itemtype, itemparam1, itemparam2 ;

	if ( sscanf ( params, "s[36]iiii", itemname, itemmodel, itemtype, itemparam1, itemparam2 ) ) {
	    return SendClientMessage ( playerid, -1, "/createitem [name] [model] [type] [param1] [param2]" ) ;
	}

	CreateItem ( itemname, itemmodel, itemtype, itemparam1, itemparam2 ) ;

	return true ;
}
*/
CMD:invhelp ( playerid ) {
	SendClientMessage ( playerid, 0x669CADFF, "Inventory Commands" ) ;
	SendClientMessage ( playerid, -1, "/playeritems - Parses ALL of your items in text" ) ;
	SendClientMessage ( playerid, -1, "/showitems - Displays a complete list of all items" ) ;
	SendClientMessage ( playerid, -1, "Press \"N\" to display / hide your inventory." ) ;

	return true ;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

new playerLastShowItemPage [ MAX_PLAYERS ] ;
CMD:showitems ( playerid, params [] ) {
/*
	if ( ! IsPlayerModerator ( playerid ) ) {

		return SendServerMessage ( playerid, "You're not a moderator.", MSG_TYPE_ERROR ) ;
	}*/

	if ( !IsPlayerAdmin ( playerid ) ) {

		return SendClientMessage(playerid, COLOR_RED, "Fuck off.");
	}

	playerLastShowItemPage [ playerid ] = 1 ;
	SendServerMessage ( playerid, "Use /giveitem to give an item to a player.", MSG_TYPE_ERROR ) ;

	return ShowItemDialog ( playerid )  ;
}

ShowItemDialog(playerid) {

	new MAX_ITEMS_ON_PAGE = 20, string [ 1024 + 1 ], bool: nextpage = false ;

    new pages = floatround ( sizeof ( Item ) / MAX_ITEMS_ON_PAGE, floatround_floor ) + 1, 
    	resultcount = ( ( MAX_ITEMS_ON_PAGE * playerLastShowItemPage [ playerid ] ) - MAX_ITEMS_ON_PAGE ) ;

    strcat(string, "Item ID\tItem Name\tItem Model\tItem Type\n");

    for ( new i = resultcount; i < sizeof ( Item ); i ++ ) {

        resultcount ++;

        if ( resultcount <= MAX_ITEMS_ON_PAGE * playerLastShowItemPage [ playerid ] ) {

           format ( string, sizeof ( string ), "%s%d\t%s\t%d\t%d\n", string, i, Item [ i ] [ item_name ], Item [ i ] [ item_model ], Item [ i ] [ item_type ]);
        }

        if ( resultcount > MAX_ITEMS_ON_PAGE * playerLastShowItemPage [ playerid ] ) {

            nextpage = true ;
            break ;
        }
    }

	inline showItemsResponse(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused pid, dialogid, response, listitem, inputtext

		if ( ! response ) {

			return true ;
		}

		if ( response && nextpage ) {

			playerLastShowItemPage [ playerid ] ++;
			ShowItemDialog ( playerid ) ;
		}

		else return true ;
	}

    if ( nextpage ) {

    	Dialog_ShowCallback ( playerid, using inline showItemsResponse, DIALOG_STYLE_TABLIST_HEADERS, sprintf("Item List: Page %d of %d", playerLastShowItemPage [ playerid ], pages), string, "Next", "Close" );

    	return true ;
    }

   	Dialog_ShowCallback ( playerid, using inline showItemsResponse, DIALOG_STYLE_TABLIST_HEADERS, sprintf("Item List: Page %d of %d", playerLastShowItemPage [ playerid ], pages), string, "Close" );

    return true ;
}