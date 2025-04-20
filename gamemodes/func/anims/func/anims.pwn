CMD:animlist(playerid, params[])
{
	SendClientMessage(playerid, COLOR_TAB0, "|________________________| Animation Help |________________________|") ;

	SendClientMessage(playerid, COLOR_TAB1, "/dance, /handsup, /bat, /slap, /bar, /wash, /lay, /workout, /blowjob, /bomb");
	SendClientMessage(playerid, COLOR_TAB2, "/carry, /crack, /sleep, /jump, /deal, /dancing, /eating, /puke, /gsign, /chat");
	SendClientMessage(playerid, COLOR_TAB1, "/goggles, /spray, /throw, /swipe, /office, /kiss, /knife, /cpr, /scratch, /aim");
	SendClientMessage(playerid, COLOR_TAB2, "/cheer, /wave, /strip, /smoke, /reload, /taichi, /wank, /cower, /drunk, /riflehold");
	SendClientMessage(playerid, COLOR_TAB1, "/cry, /tired, /sit, /crossarms, /fucku, /walk, /piss, /slapass, /camcrouch, /ko");
	SendClientMessage(playerid, COLOR_TAB2, "/fall, /carryidle, /time, /pointyonder, /stop, /getup, /lean, /drink, /stopanim");
	return 1;
}
CMD:animhelp ( playerid, params [] ) {
	return cmd_animlist ( playerid, params ) ;
}

CMD:anims ( playerid, params [] ) {
	return cmd_animlist ( playerid, params ) ;
}

CMD:stop ( playerid, params [] ) {

    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	AnimationLoop(playerid, "POLICE", "CopTraf_Stop", 4.0, 1, 0, 0, 0, 0, 1);

	return true ;
}


CMD:lean(playerid, params[])
{

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	AnimationLoop(playerid, "GANGS", "leanIDLE", 4.0, 1, 0, 0, 0, 0, 1);

	return 1;
}

CMD:getup ( playerid, params [] ) {

    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	ApplyAnimation(playerid, "PED", "getup", 4.1, 0, 0, 0, 0, 0, 1);

	return true ;
}

CMD:dance(playerid, params[])
{
	new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/dance [1-4]", MSG_TYPE_ERROR );

	if (type < 1 || type > 4)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
		case 1: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE1);
	    case 2: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE2);
	    case 3: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE3);
	    case 4: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE4);
	}
	return 1;
}

CMD:gkick ( playerid, params [] ) {
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	ApplyAnimation(playerid, "FIGHT_D", "FightD_1", 4.1, 0, 0, 0, 0, 0, 1);

	return true ;
}

CMD:pointyonder ( playerid, params [] ) {
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	AnimationLoop(playerid, "ON_LOOKERS","Pointup_loop", 4.1, 0, 1, 1, 1, 1, 1); 

	return true ;
}

CMD:handsup(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_HANDSUP);
	return 1;
}

CMD:shit ( playerid, params [] ) {
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	AnimationLoop(playerid, "PED", "cower", 4.1, 0, 0, 0, 1, 0, 1);
    SetPlayerAttachedObject ( playerid, 9, 18722,1, -1.773999, 0.234999,-0.091000, 2.300002, 88.499984, 0.0, 1.0, 1.0, 1.0 ) ;
    
    return true ;
}

CMD:piss(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	SetPlayerSpecialAction(playerid, 68);
	return 1;
}

CMD:camcrouch ( playerid, params [] ) {
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );


	AnimationLoop(playerid, "CAMERA", "camcrch_idleloop", 4.1, 1, 0, 0, 0, 0, 1);

	return true ;
}

CMD:riflehold ( playerid, params [] ) {

    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	AnimationLoop(playerid, "PED", "Gun_2_IDLE", 4.1, 0, 1, 1, 1, 1, 1); 

	return true ;
}

CMD:time ( playerid, params [] ) {
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	ApplyAnimation(playerid, "PLAYIDLES", "time", 4.1, 0, 0, 0, 0, 0, 1);

	return true ;
}

CMD:ko ( playerid, params [] ) {

    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	new animstate ;

	if ( sscanf ( params, "i", animstate )) {

		return SendServerMessage ( playerid, "/ko [0-1]", MSG_TYPE_ERROR ) ;
	}

	if ( animstate < 0 || animstate > 1 ) {

		return SendServerMessage ( playerid, "/ko [0-1]", MSG_TYPE_ERROR ) ;
	}

	if ( animstate == 0 ) {

		return AnimationLoop(playerid,"PED","KO_SHOT_STOM", 4.1, 0, 1, 1, 1, 1, 1); 
	}

	else if ( animstate == 1 ) {

		return AnimationLoop(playerid,"PED","KO_SHOT_FACE",4.1, 0, 1, 1, 1, 1, 1); 
	}

	return true ;
}

CMD:fall(playerid, params [] ) {
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	return AnimationLoop(playerid,"PED", "FLOOR_hit_f", 4.1, 0, 1, 1, 1, 1, 1); 
}

CMD:carryidle ( playerid, params [] ) {

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

 	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY ) ;

	return true ;
}

CMD:stopanim ( playerid, params [] ) {

	new int = GetPlayerInterior(playerid),vw = GetPlayerVirtualWorld(playerid);
	if (!AnimationCheck(playerid) || !IsPlayerFree ( playerid ) )
	    return SendServerMessage(playerid, "You don't need to use this command right now.", MSG_TYPE_ERROR );

	ClearAnimations(playerid, 1);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE ) ;

	ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);

	SetPlayerInterior(playerid,99); SetPlayerVirtualWorld(playerid,99);
	SetPlayerInterior(playerid,int); SetPlayerVirtualWorld(playerid,vw);

	gPlayerUsingLoopingAnim[playerid] = 0;

	return true ;
}

CMD:sa(playerid, params[]){
	return cmd_stopanim(playerid, params);
}

CMD:bat(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/bat [1-5]", MSG_TYPE_ERROR );

	if (type < 1 || type > 5)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: ApplyAnimation(playerid, "BASEBALL", "Bat_1", 4.1, 0, 1, 1, 0, 0, 1);
	    case 2: ApplyAnimation(playerid, "BASEBALL", "Bat_2", 4.1, 0, 1, 1, 0, 0, 1);
	    case 3: ApplyAnimation(playerid, "BASEBALL", "Bat_3", 4.1, 0, 1, 1, 0, 0, 1);
	    case 4: ApplyAnimation(playerid, "BASEBALL", "Bat_4", 4.1, 0, 0, 0, 0, 0, 1);
	    case 5: AnimationLoop(playerid, "BASEBALL", "Bat_IDLE", 4.1, 1, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:bar(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/bar [1-8]", MSG_TYPE_ERROR );

	if (type < 1 || type > 8)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: ApplyAnimation(playerid, "BAR", "Barserve_bottle", 4.1, 0, 0, 0, 0, 0, 1);
	    case 2: ApplyAnimation(playerid, "BAR", "Barserve_give", 4.1, 0, 0, 0, 0, 0, 1);
	    case 3: ApplyAnimation(playerid, "BAR", "Barserve_glass", 4.1, 0, 0, 0, 0, 0, 1);
	    case 4: ApplyAnimation(playerid, "BAR", "Barserve_in", 4.1, 0, 0, 0, 0, 0, 1);
	    case 5: ApplyAnimation(playerid, "BAR", "Barserve_order", 4.1, 0, 0, 0, 0, 0, 1);
	    case 6: AnimationLoop(playerid, "BAR", "BARman_idle", 4.1, 1, 0, 0, 0, 0, 1);
	    case 7: AnimationLoop(playerid, "BAR", "dnk_stndM_loop", 4.1, 0, 0, 0, 0, 0, 1);
	    case 8: AnimationLoop(playerid, "BAR", "dnk_stndF_loop", 4.1, 0, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:wash(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 0, 0, 0, 0, 1);
	return 1;
}

CMD:lay(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/lay [1-5]", MSG_TYPE_ERROR );

	if (type < 1 || type > 5)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: AnimationLoop(playerid, "BEACH", "bather", 4.1, 1, 0, 0, 0, 0, 1);
	    case 2: AnimationLoop(playerid, "BEACH", "Lay_Bac_Loop", 4.1, 1, 0, 0, 0, 0, 1);
	    case 3: AnimationLoop(playerid, "BEACH", "ParkSit_M_loop", 4.1, 1, 0, 0, 0, 0, 1);
	    case 4: AnimationLoop(playerid, "BEACH", "ParkSit_W_loop", 4.1, 1, 0, 0, 0, 0, 1);
	    case 5: AnimationLoop(playerid, "BEACH", "SitnWait_loop_W", 4.1, 1, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:workout(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/workout [1-7]", MSG_TYPE_ERROR );

	if (type < 1 || type > 7)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: ApplyAnimation(playerid, "benchpress", "gym_bp_celebrate", 4.1, 0, 0, 0, 0, 0, 1);
	    case 2: AnimationLoop(playerid, "benchpress", "gym_bp_down", 4.1, 0, 0, 0, 1, 0, 1);
	    case 3: ApplyAnimation(playerid, "benchpress", "gym_bp_getoff", 4.1, 0, 0, 0, 0, 0, 1);
	    case 4: AnimationLoop(playerid, "benchpress", "gym_bp_geton", 4.1, 0, 0, 0, 1, 0, 1);
	    case 5: AnimationLoop(playerid, "benchpress", "gym_bp_up_A", 4.1, 0, 0, 0, 1, 0, 1);
	    case 6: AnimationLoop(playerid, "benchpress", "gym_bp_up_B", 4.1, 0, 0, 0, 1, 0, 1);
	    case 7: AnimationLoop(playerid, "benchpress", "gym_bp_up_smooth", 4.1, 0, 0, 0, 1, 0, 1);
	}
	return 1;
}

CMD:blowjob(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/blowjob [1-4]", MSG_TYPE_ERROR );

	if (type < 1 || type > 4)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: AnimationLoop(playerid, "BLOWJOBZ", "BJ_COUCH_LOOP_W", 4.1, 1, 0, 0, 0, 0, 1);
	    case 2: AnimationLoop(playerid, "BLOWJOBZ", "BJ_COUCH_LOOP_P", 4.1, 1, 0, 0, 0, 0, 1);
	    case 3: AnimationLoop(playerid, "BLOWJOBZ", "BJ_STAND_LOOP_W", 4.1, 1, 0, 0, 0, 0, 1);
	    case 4: AnimationLoop(playerid, "BLOWJOBZ", "BJ_STAND_LOOP_P", 4.1, 1, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:bomb(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 0, 0, 0, 0, 0, 1);
	return 1;
}

CMD:carry(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/carry [1-6]", MSG_TYPE_ERROR );

	if (type < 1 || type > 6)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: ApplyAnimation(playerid, "CARRY", "liftup", 4.1, 0, 0, 0, 0, 0, 1);
	    case 2: ApplyAnimation(playerid, "CARRY", "liftup05", 4.1, 0, 0, 0, 0, 0, 1);
	    case 3: ApplyAnimation(playerid, "CARRY", "liftup105", 4.1, 0, 0, 0, 0, 0, 1);
	    case 4: ApplyAnimation(playerid, "CARRY", "putdwn", 4.1, 0, 0, 0, 0, 0, 1);
	    case 5: ApplyAnimation(playerid, "CARRY", "putdwn05", 4.1, 0, 0, 0, 0, 0, 1);
	    case 6: ApplyAnimation(playerid, "CARRY", "putdwn105", 4.1, 0, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:crack(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/crack [1-6]", MSG_TYPE_ERROR );

	if (type < 1 || type > 6)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: AnimationLoop(playerid, "CRACK", "crckdeth1", 4.1, 0, 0, 0, 1, 0, 1);
	    case 2: AnimationLoop(playerid, "CRACK", "crckdeth2", 4.1, 1, 0, 0, 0, 0, 1);
	    case 3: AnimationLoop(playerid, "CRACK", "crckdeth3", 4.1, 0, 0, 0, 1, 0, 1);
	    case 4: AnimationLoop(playerid, "CRACK", "crckidle1", 4.1, 0, 0, 0, 1, 0, 1);
	    case 5: AnimationLoop(playerid, "CRACK", "crckidle2", 4.1, 0, 0, 0, 1, 0, 1);
	    case 6: AnimationLoop(playerid, "CRACK", "crckidle3", 4.1, 0, 0, 0, 1, 0, 1);
	}
	return 1;
}

CMD:sleep(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/sleep [1-2]", MSG_TYPE_ERROR );

	if (type < 1 || type > 2)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: AnimationLoop(playerid, "CRACK", "crckdeth4", 4.1, 0, 0, 0, 1, 0, 1);
	    case 2: AnimationLoop(playerid, "CRACK", "crckidle4", 4.1, 0, 0, 0, 1, 0, 1);
	}
	return 1;
}

CMD:jump(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	ApplyAnimation(playerid, "DODGE", "Crush_Jump", 4.1, 0, 1, 1, 0, 0, 1);
	return 1;
}

CMD:deal(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/deal [1-6]", MSG_TYPE_ERROR );

	if (type < 1 || type > 6)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: ApplyAnimation(playerid, "DEALER", "DEALER_DEAL", 4.1, 0, 0, 0, 0, 0, 1);
	    case 2: ApplyAnimation(playerid, "DEALER", "DRUGS_BUY", 4.1, 0, 0, 0, 0, 0, 1);
	    case 3: ApplyAnimation(playerid, "DEALER", "shop_pay", 4.1, 0, 0, 0, 0, 0, 1);
	    case 4: AnimationLoop(playerid, "DEALER", "DEALER_IDLE_01", 4.1, 1, 0, 0, 0, 0, 1);
	    case 5: AnimationLoop(playerid, "DEALER", "DEALER_IDLE_02", 4.1, 1, 0, 0, 0, 0, 1);
	    case 6: AnimationLoop(playerid, "DEALER", "DEALER_IDLE_03", 4.1, 1, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:dancing(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/dancing [1-10]", MSG_TYPE_ERROR );

	if (type < 1 || type > 10)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: AnimationLoop(playerid, "DANCING", "dance_loop", 4.1, 1, 0, 0, 0, 0, 1);
	    case 2: AnimationLoop(playerid, "DANCING", "DAN_Left_A", 4.1, 1, 0, 0, 0, 0, 1);
	    case 3: AnimationLoop(playerid, "DANCING", "DAN_Right_A", 4.1, 1, 0, 0, 0, 0, 1);
	    case 4: AnimationLoop(playerid, "DANCING", "DAN_Loop_A", 4.1, 1, 0, 0, 0, 0, 1);
	    case 5: AnimationLoop(playerid, "DANCING", "DAN_Up_A", 4.1, 1, 0, 0, 0, 0, 1);
	    case 6: AnimationLoop(playerid, "DANCING", "DAN_Down_A", 4.1, 1, 0, 0, 0, 0, 1);
	    case 7: AnimationLoop(playerid, "DANCING", "dnce_M_a", 4.1, 1, 0, 0, 0, 0, 1);
	    case 8: AnimationLoop(playerid, "DANCING", "dnce_M_e", 4.1, 1, 0, 0, 0, 0, 1);
	    case 9: AnimationLoop(playerid, "DANCING", "dnce_M_b", 4.1, 1, 0, 0, 0, 0, 1);
	    case 10: AnimationLoop(playerid, "DANCING", "dnce_M_c", 4.1, 1, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:eating(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/eating [1-3]", MSG_TYPE_ERROR );

	if (type < 1 || type > 3)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
	    case 2: ApplyAnimation(playerid, "FOOD", "EAT_Chicken", 4.1, 0, 0, 0, 0, 0, 1);
	    case 3: ApplyAnimation(playerid, "FOOD", "EAT_Pizza", 4.1, 0, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:puke(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	ApplyAnimation(playerid, "FOOD", "EAT_Vomit_P", 4.1, 0, 0, 0, 0, 0, 1);
	return 1;
}

CMD:gsign(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/gsign [1-15]", MSG_TYPE_ERROR );

	if (type < 1 || type > 15)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
		case 1: ApplyAnimation(playerid, "GHANDS", "gsign1", 4.1, 0, 0, 0, 0, 0, 1);
		case 2: ApplyAnimation(playerid, "GHANDS", "gsign1LH", 4.1, 0, 0, 0, 0, 0, 1);
		case 3: ApplyAnimation(playerid, "GHANDS", "gsign2", 4.1, 0, 0, 0, 0, 0, 1);
		case 4: ApplyAnimation(playerid, "GHANDS", "gsign2LH", 4.1, 0, 0, 0, 0, 0, 1);
		case 5: ApplyAnimation(playerid, "GHANDS", "gsign3", 4.1, 0, 0, 0, 0, 0, 1);
		case 6: ApplyAnimation(playerid, "GHANDS", "gsign3LH", 4.1, 0, 0, 0, 0, 0, 1);
		case 7: ApplyAnimation(playerid, "GHANDS", "gsign4", 4.1, 0, 0, 0, 0, 0, 1);
		case 8: ApplyAnimation(playerid, "GHANDS", "gsign4LH", 4.1, 0, 0, 0, 0, 0, 1);
		case 9: ApplyAnimation(playerid, "GHANDS", "gsign5", 4.1, 0, 0, 0, 0, 0, 1);
		case 10: ApplyAnimation(playerid, "GHANDS", "gsign5", 4.1, 0, 0, 0, 0, 0, 1);
		case 11: ApplyAnimation(playerid, "GHANDS", "gsign5LH", 4.1, 0, 0, 0, 0, 0, 1);
		case 12: ApplyAnimation(playerid, "GANGS", "Invite_No", 4.1, 0, 0, 0, 0, 0, 1);
		case 13: ApplyAnimation(playerid, "GANGS", "Invite_Yes", 4.1, 0, 0, 0, 0, 0, 1);
		case 14: ApplyAnimation(playerid, "GANGS", "prtial_gngtlkD", 4.1, 0, 0, 0, 0, 0, 1);
		case 15: ApplyAnimation(playerid, "GANGS", "smkcig_prtl", 4.1, 0, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:chat(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/chat [1-6]", MSG_TYPE_ERROR );

	if (type < 1 || type > 6)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
		case 1: ApplyAnimation(playerid, "GANGS", "prtial_gngtlkA", 4.1, 0, 0, 0, 0, 0, 1);
		case 2: ApplyAnimation(playerid, "GANGS", "prtial_gngtlkB", 4.1, 0, 0, 0, 0, 0, 1);
		case 3: ApplyAnimation(playerid, "GANGS", "prtial_gngtlkE", 4.1, 0, 0, 0, 0, 0, 1);
		case 4: ApplyAnimation(playerid, "GANGS", "prtial_gngtlkF", 4.1, 0, 0, 0, 0, 0, 1);
		case 5: ApplyAnimation(playerid, "GANGS", "prtial_gngtlkG", 4.1, 0, 0, 0, 0, 0, 1);
		case 6: ApplyAnimation(playerid, "GANGS", "prtial_gngtlkH", 4.1, 0, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:goggles(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	ApplyAnimation(playerid, "goggles", "goggles_put_on", 4.1, 0, 0, 0, 0, 0, 1);
	return 1;
}

CMD:spray(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

 	AnimationLoop(playerid, "GRAFFITI", "spraycan_fire", 4.1, 1, 0, 0, 0, 0, 1);
	return 1;
}

CMD:throw(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	ApplyAnimation(playerid, "GRENADE", "WEAPON_throw", 4.1, 0, 0, 0, 0, 0, 1);
	return 1;
}

CMD:swipe(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	ApplyAnimation(playerid, "HEIST9", "Use_SwipeCard", 4.1, 0, 0, 0, 0, 0, 1);
	return 1;
}

CMD:office(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/office [1-6]", MSG_TYPE_ERROR );

	if (type < 1 || type > 6)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
		case 1: AnimationLoop(playerid, "INT_OFFICE", "OFF_Sit_Bored_Loop", 4.1, 1, 0, 0, 0, 0, 1);
		case 2: AnimationLoop(playerid, "INT_OFFICE", "OFF_Sit_Crash", 4.1, 1, 0, 0, 0, 0, 1);
		case 3: AnimationLoop(playerid, "INT_OFFICE", "OFF_Sit_Drink", 4.1, 1, 0, 0, 0, 0, 1);
		case 4: AnimationLoop(playerid, "INT_OFFICE", "OFF_Sit_Read", 4.1, 1, 0, 0, 0, 0, 1);
		case 5: AnimationLoop(playerid, "INT_OFFICE", "OFF_Sit_Type_Loop", 4.1, 1, 0, 0, 0, 0, 1);
		case 6: AnimationLoop(playerid, "INT_OFFICE", "OFF_Sit_Watch", 4.1, 1, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:kiss(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/kiss [1-6]", MSG_TYPE_ERROR );

	if (type < 1 || type > 6)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
		case 1: ApplyAnimation(playerid, "KISSING", "Grlfrd_Kiss_01", 4.1, 0, 0, 0, 0, 0, 1);
		case 2: ApplyAnimation(playerid, "KISSING", "Grlfrd_Kiss_02", 4.1, 0, 0, 0, 0, 0, 1);
		case 3: ApplyAnimation(playerid, "KISSING", "Grlfrd_Kiss_03", 4.1, 0, 0, 0, 0, 0, 1);
		case 4: ApplyAnimation(playerid, "KISSING", "Playa_Kiss_01", 4.1, 0, 0, 0, 0, 0, 1);
		case 5: ApplyAnimation(playerid, "KISSING", "Playa_Kiss_02", 4.1, 0, 0, 0, 0, 0, 1);
		case 6: ApplyAnimation(playerid, "KISSING", "Playa_Kiss_03", 4.1, 0, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:knife(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/knife [1-8]", MSG_TYPE_ERROR );

	if (type < 1 || type > 8)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
		case 1: ApplyAnimation(playerid, "KNIFE", "knife_1", 4.1, 0, 1, 1, 0, 0, 1);
		case 2: ApplyAnimation(playerid, "KNIFE", "knife_2", 4.1, 0, 1, 1, 0, 0, 1);
		case 3: ApplyAnimation(playerid, "KNIFE", "knife_3", 4.1, 0, 1, 1, 0, 0, 1);
		case 4: ApplyAnimation(playerid, "KNIFE", "knife_4", 4.1, 0, 1, 1, 0, 0, 1);
		case 5: AnimationLoop(playerid, "KNIFE", "WEAPON_knifeidle", 4.1, 1, 0, 0, 0, 0, 1);
		case 6: ApplyAnimation(playerid, "KNIFE", "KILL_Knife_Player", 4.1, 0, 0, 0, 0, 0, 1);
		case 7: ApplyAnimation(playerid, "KNIFE", "KILL_Knife_Ped_Damage", 4.1, 0, 0, 0, 0, 0, 1);
		case 8: ApplyAnimation(playerid, "KNIFE", "KILL_Knife_Ped_Die", 4.1, 0, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:cpr(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	ApplyAnimation(playerid, "MEDIC", "CPR", 4.1, 0, 0, 0, 0, 0, 1);
	return 1;
}

CMD:scratch(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/scratch [1-4]", MSG_TYPE_ERROR );

	if (type < 1 || type > 4)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
    	case 1: AnimationLoop(playerid, "SCRATCHING", "scdldlp", 4.1, 1, 0, 0, 0, 0, 1);
		case 2: AnimationLoop(playerid, "SCRATCHING", "scdlulp", 4.1, 1, 0, 0, 0, 0, 1);
		case 3: AnimationLoop(playerid, "SCRATCHING", "scdrdlp", 4.1, 1, 0, 0, 0, 0, 1);
		case 4: AnimationLoop(playerid, "SCRATCHING", "scdrulp", 4.1, 1, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:aim(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/aim [1-4]", MSG_TYPE_ERROR );

	if (type < 1 || type > 4)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: AnimationLoop(playerid, "PED", "ARRESTgun", 4.1, 0, 0, 0, 1, 0, 1);
	    case 2: AnimationLoop(playerid, "SHOP", "ROB_Loop_Threat", 4.1, 1, 0, 0, 0, 0, 1);
    	case 3: AnimationLoop(playerid, "ON_LOOKERS", "point_loop", 4.1, 1, 0, 0, 0, 0, 1);
		case 4: AnimationLoop(playerid, "ON_LOOKERS", "Pointup_loop", 4.1, 1, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:cheer(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/cheer [1-8]", MSG_TYPE_ERROR );

	if (type < 1 || type > 8)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
		case 1: ApplyAnimation(playerid, "ON_LOOKERS", "shout_01", 4.1, 0, 0, 0, 0, 0, 1);
		case 2: ApplyAnimation(playerid, "ON_LOOKERS", "shout_02", 4.1, 0, 0, 0, 0, 0, 1);
		case 3: ApplyAnimation(playerid, "ON_LOOKERS", "shout_in", 4.1, 0, 0, 0, 0, 0, 1);
		case 4: AnimationLoop(playerid, "RIOT", "RIOT_ANGRY_B", 4.1, 1, 0, 0, 0, 0, 1);
		case 5: ApplyAnimation(playerid, "RIOT", "RIOT_CHANT", 4.1, 0, 0, 0, 0, 0, 1);
		case 6: ApplyAnimation(playerid, "RIOT", "RIOT_shout", 4.1, 0, 0, 0, 0, 0, 1);
		case 7: ApplyAnimation(playerid, "STRIP", "PUN_HOLLER", 4.1, 0, 0, 0, 0, 0, 1);
		case 8: ApplyAnimation(playerid, "OTB", "wtchrace_win", 4.1, 0, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:strip(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/strip [1-7]", MSG_TYPE_ERROR );

	if (type < 1 || type > 7)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
		case 1: AnimationLoop(playerid, "STRIP", "strip_A", 4.1, 1, 0, 0, 0, 0, 1);
		case 2: AnimationLoop(playerid, "STRIP", "strip_B", 4.1, 1, 0, 0, 0, 0, 1);
		case 3: AnimationLoop(playerid, "STRIP", "strip_C", 4.1, 1, 0, 0, 0, 0, 1);
		case 4: AnimationLoop(playerid, "STRIP", "strip_D", 4.1, 1, 0, 0, 0, 0, 1);
		case 5: AnimationLoop(playerid, "STRIP", "strip_E", 4.1, 1, 0, 0, 0, 0, 1);
		case 6: AnimationLoop(playerid, "STRIP", "strip_F", 4.1, 1, 0, 0, 0, 0, 1);
		case 7: AnimationLoop(playerid, "STRIP", "strip_G", 4.1, 1, 0, 0, 0, 0, 1);
	}
	return 1;
}


CMD:slapass( playerid, params [] ) {

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

 	return AnimationLoop(playerid, "SWEET", "sweet_ass_slap", 4.1, 0, 0, 0, 0, 0, 1); // Ass Slapping
}

CMD:wave(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/wave [1-3]", MSG_TYPE_ERROR );

	if (type < 1 || type > 3)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: ApplyAnimation(playerid, "PED", "endchat_03", 4.1, 0, 0, 0, 0, 0, 1);
	    case 2: ApplyAnimation(playerid, "KISSING", "gfwave2", 4.1, 0, 0, 0, 0, 0, 1);
	    case 3: AnimationLoop(playerid, "ON_LOOKERS", "wave_loop", 4.1, 1, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:drink ( playerid ) {

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	ApplyAnimation(playerid, "SMOKING", "M_smk_drag", 4.1, 0, 0, 0, 0, 0, 1);

	return true ;
}

CMD:smoke(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/smoke [0-3]", MSG_TYPE_ERROR );

	if (type < 0 || type > 3)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
		case 0: ApplyAnimation(playerid, "SHOP", "Smoke_RYD", 4.1, 0, 0, 0, 0, 0, 1);
	    case 1: ApplyAnimation(playerid, "SMOKING", "M_smk_drag", 4.1, 0, 0, 0, 0, 0, 1);
	    case 2: AnimationLoop(playerid, "SMOKING", "M_smklean_loop", 4.1, 1, 0, 0, 0, 0, 1);
	    case 3: AnimationLoop(playerid, "SMOKING", "M_smkstnd_loop", 4.1, 1, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:reload(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/reload [1-4]", MSG_TYPE_ERROR );

	if (type < 1 || type > 4)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
		case 1: ApplyAnimation(playerid, "BUDDY", "buddy_reload", 4.1, 0, 0, 0, 0, 0, 1);
		case 2: ApplyAnimation(playerid, "UZI", "UZI_reload", 4.1, 0, 0, 0, 0, 0, 1);
		case 3: ApplyAnimation(playerid, "COLT45", "colt45_reload", 4.1, 0, 0, 0, 0, 0, 1);
		case 4: ApplyAnimation(playerid, "RIFLE", "rifle_load", 4.1, 0, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:taichi(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	AnimationLoop(playerid, "PARK", "Tai_Chi_Loop", 4.1, 1, 0, 0, 0, 0, 1);
	return 1;
}

CMD:wank(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/wank [1-3]", MSG_TYPE_ERROR );

	if (type < 1 || type > 3)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
		case 1: AnimationLoop(playerid, "PAULNMAC", "wank_loop", 4.1, 1, 0, 0, 0, 0, 1);
		case 2: ApplyAnimation(playerid, "PAULNMAC", "wank_in", 4.1, 0, 0, 0, 0, 0, 1);
		case 3: ApplyAnimation(playerid, "PAULNMAC", "wank_out", 4.1, 0, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:cower(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	AnimationLoop(playerid, "PED", "cower", 4.1, 0, 0, 0, 1, 0, 1);
	return 1;
}

CMD:drunk(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	AnimationLoop(playerid, "PED", "WALK_drunk", 4.1, 1, 1, 1, 1, 1, 1);
	return 1;
}

CMD:cry(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	AnimationLoop(playerid, "GRAVEYARD", "mrnF_loop", 4.1, 1, 0, 0, 0, 0, 1);
    return 1;
}

CMD:tired(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/tired [1-2]", MSG_TYPE_ERROR );

	if (type < 1 || type > 2)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: AnimationLoop(playerid, "PED", "IDLE_tired", 4.1, 1, 0, 0, 0, 0, 1);
	    case 2: AnimationLoop(playerid, "FAT", "IDLE_tired", 4.1, 1, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:sit(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/sit [1-6]", MSG_TYPE_ERROR );

	if (type < 1 || type > 6)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
		case 1: AnimationLoop(playerid, "CRIB", "PED_Console_Loop", 4.1, 1, 0, 0, 0, 0, 1);
		case 2: AnimationLoop(playerid, "INT_HOUSE", "LOU_In", 4.1, 0, 0, 0, 1, 0, 1);
		case 3: AnimationLoop(playerid, "MISC", "SEAT_LR", 4.1, 1, 0, 0, 0, 0, 1);
		case 4: AnimationLoop(playerid, "MISC", "Seat_talk_01", 4.1, 1, 0, 0, 0, 0, 1);
		case 5: AnimationLoop(playerid, "MISC", "Seat_talk_02", 4.1, 1, 0, 0, 0, 0, 1);
		case 6: AnimationLoop(playerid, "ped", "SEAT_down", 4.1, 0, 0, 0, 1, 0, 1);
	}
	return 1;
}

CMD:crossarms(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/crossarms [1-4]", MSG_TYPE_ERROR );

	if (type < 1 || type > 4)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: AnimationLoop(playerid, "COP_AMBIENT", "Coplook_loop", 4.1, 0, 1, 1, 1, 0, 1);
	    case 2: AnimationLoop(playerid, "GRAVEYARD", "prst_loopa", 4.1, 1, 0, 0, 0, 0, 1);
	    case 3: AnimationLoop(playerid, "GRAVEYARD", "mrnM_loop", 4.1, 1, 0, 0, 0, 0, 1);
	    case 4: AnimationLoop(playerid, "DEALER", "DEALER_IDLE", 4.1, 0, 1, 1, 1, 0, 1);
	}
	return 1;
}

CMD:fucku(playerid, params[])
{
    if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	ApplyAnimation(playerid, "PED", "fucku", 4.1, 0, 0, 0, 0, 0);
	return 1;
}

CMD:walk(playerid, params[])
{
    new type;

	if (!AnimationCheck(playerid))
	    return SendServerMessage(playerid, "You can't perform animations at the moment.", MSG_TYPE_ERROR );

	if (sscanf(params, "d", type))
	    return SendServerMessage(playerid, "/walk [1-16]", MSG_TYPE_ERROR );

	if (type < 1 || type > 17)
	    return SendServerMessage(playerid, "Invalid type specified.", MSG_TYPE_ERROR );

	switch (type) {
	    case 1: AnimationLoop(playerid, "FAT", "FatWalk", 4.1, 1, 1, 1, 1, 1, 1);
	    case 2: AnimationLoop(playerid, "MUSCULAR", "MuscleWalk", 4.1, 1, 1, 1, 1, 1, 1);
	    case 3: AnimationLoop(playerid, "PED", "WALK_armed", 4.1, 1, 1, 1, 1, 1, 1);
	    case 4: AnimationLoop(playerid, "PED", "WALK_civi", 4.1, 1, 1, 1, 1, 1, 1);
	    case 5: AnimationLoop(playerid, "PED", "WALK_fat", 4.1, 1, 1, 1, 1, 1, 1);
	    case 6: AnimationLoop(playerid, "PED", "WALK_fatold", 4.1, 1, 1, 1, 1, 1, 1);
	    case 7: AnimationLoop(playerid, "PED", "WALK_gang1", 4.1, 1, 1, 1, 1, 1, 1);
	    case 8: AnimationLoop(playerid, "PED", "WALK_gang2", 4.1, 1, 1, 1, 1, 1, 1);
	    case 9: AnimationLoop(playerid, "PED", "WALK_player", 4.1, 1, 1, 1, 1, 1, 1);
	    case 10: AnimationLoop(playerid, "PED", "WALK_old", 4.1, 1, 1, 1, 1, 1, 1);
	    case 11: AnimationLoop(playerid, "PED", "WALK_wuzi", 4.1, 1, 1, 1, 1, 1, 1);
	    case 12: AnimationLoop(playerid, "PED", "WOMAN_walkbusy", 4.1, 1, 1, 1, 1, 1, 1);
	    case 13: AnimationLoop(playerid, "PED", "WOMAN_walkfatold", 4.1, 1, 1, 1, 1, 1, 1);
	    case 14: AnimationLoop(playerid, "PED", "WOMAN_walknorm", 4.1, 1, 1, 1, 1, 1, 1);
	    case 15: AnimationLoop(playerid, "PED", "WOMAN_walksexy", 4.1, 1, 1, 1, 1, 1, 1);
	    case 16: AnimationLoop(playerid, "PED", "WOMAN_walkshop", 4.1, 1, 1, 1, 1, 1, 1);
	}
	return 1;
}