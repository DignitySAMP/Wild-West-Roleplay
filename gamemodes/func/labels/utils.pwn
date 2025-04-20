GetFreeDynamicLabelID() {

	for(new i=0; i<MAX_DYNAMIC_LABELS; i++) {

		if(DynamicLabel[i][dynamic_label_id] == -1) { return i; }
		else { continue; }
	}
	return -1;
}

ResetDynLabelPlayerVariables(playerid) {

	new dummy[256];
	dummy[0] = EOS;
	PlayerLabelRequest[playerid] = 0;
	PlayerLabelRequestType[playerid] = DYN_LABEL_INVALID;
	PlayerLabelRequestMessage[playerid] = dummy;
	PlayerLabelPosition[playerid][0] = PlayerLabelPosition[playerid][1] = PlayerLabelPosition[playerid][2] = 0.0;
	return true;
}