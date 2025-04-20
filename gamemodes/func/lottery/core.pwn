#include "func/lottery/func/data.pwn"

task OnLotteryTick[LOTTERY_TICK_TIMER]() {

////	print("OnLotteryTick timer called (lottery/core.pwn)");

	return true ; 
/*

	new query [ 128 ], generate = random ( 200 ), reward ;
	foreach ( new playerid : Player ) {

		if ( DoesPlayerHaveItemByExtraParam ( playerid, LOTTERY_TICKET ) ) {

			if ( ReturnItemByParam ( playerid, generate, false ) ) {

				LotteryWinner [ playerid ] = true;
			}

			DiscardItem ( playerid, ReturnItemByParam ( playerid, LOTTERY_TICKET, true ) ) ;
		}
		else continue;
	}

	if ( ReturnLotteryWinners () ) {

		reward = Lottery [ lottery_amount ] / ReturnLotteryWinners () ;

		GiveRewardToLotteryWinners ( reward ) ;

		Lottery [ lottery_amount ] = 100;

		mysql_tquery ( mysql, "UPDATE lottery SET lottery_amount = 100" ) ;

	}

	else SendSplitMessageToAll ( COLOR_OOC, "[Lottery] There are no winners to the lottery." ) ;

	mysql_format ( mysql, query, sizeof ( query ), "DELETE FROM items_player WHERE player_item_param2 = %d", LOTTERY_TICKET ) ;
	mysql_tquery ( mysql, query ) ;*/
}

ReturnLotteryWinners () {

	new count = 0;
	foreach ( new playerid : Player ) {

		if ( LotteryWinner [ playerid ] ) {

			count++;
		}

		else continue;
	}

	return count;
}

GiveRewardToLotteryWinners ( amount ) {
	
	new winners [ 128 ] ;

	foreach ( new playerid : Player ) {

		if ( LotteryWinner [ playerid ] ) {

			GiveCharacterMoney ( playerid, amount , MONEY_SLOT_BANK ) ;

			if ( ReturnLotteryWinners () == 1) { 
				
				SendSplitMessageToAll ( COLOR_OOC, sprintf("[Lottery] %s has won the lottery of $%d.", ReturnUserName ( playerid, false ), amount ) ) ; 

				return true ;

			}

			else { strcat ( winners, sprintf("%s, ", ReturnUserName ( playerid, false ) ) ) ; }
		}

		else continue;
	}

	SendSplitMessageToAll ( COLOR_OOC, sprintf("[Lottery] %s have won the lottery, each winning $%d.", winners, amount ) ) ; 

	return true ;
}