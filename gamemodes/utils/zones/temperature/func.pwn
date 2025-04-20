ResetPlayerTemperature(playerid) {

	new query[128];
	Character[playerid][character_temperature] = 98;
	Character[playerid][character_temperature_decimal] = 6;
	mysql_format ( mysql, query, sizeof ( query ), "UPDATE characters SET character_temperature = %d, character_temperature_decimal = %d WHERE character_id = %d LIMIT 1", Character[playerid][character_temperature],Character[playerid][character_temperature_decimal],Character [ playerid ] [ character_id ] ) ;
	mysql_tquery ( mysql, query ) ;
	return true;
}

task CharacterTemperatureCalc[120000]() {

	foreach(new i : Player) {

		new query[128];
		if(Character[i][character_temperature] != 98) { 

			Character[i][character_temperature] = 98; 
			if(Character[i][character_temperature_decimal] != 6) { Character[i][character_temperature_decimal] = 6; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_temperature = %d,character_temperature_decimal WHERE character_id = %d",Character[i][character_temperature],Character[i][character_temperature_decimal],Character[i][character_id]);
			mysql_tquery(mysql,query);
		}
		/*
		if(!IsPlayerSpawned(i) || !IsPlayerLogged[i] || IsPlayerOnAdminDuty[i]) { continue; }
		switch(GetZoneTemperature(GetPlayerZone(i))) {

			case -40..0: {

				new total = 0,remove = 0,found_item[MAX_ATTACHMENTS];
				for(new j; j < MAX_ATTACHMENTS; j++) {

					switch(GetPlayerAttachThermInfo(i,j)) {

						case 0: { continue; } //THERMAL_UNDEFINED 
						case 1,2,3: { continue; } //THERMAL_MIN/MOD/MAX_HEAT_PROTECT
						case 4: { //THERMAL_MIN_COLD_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								total++;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						} 
						case 5: { //THERMAL_MOD_COLD_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								total += 2;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						} 
						case 6: { //THERMAL_MAX_COLD_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								total += 3;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						}
						default: { 
							
							skipItem:
							continue; 
						} 
					}
				}

				found_item[0] = found_item[1] = found_item[2] = found_item[3] = found_item[4] = -1;

				if(DoesPlayerHaveItemByExtraParam(i,GLOVES)) { 

					total++;
					//SendClientMessage(i, -1, sprintf("gloves found - total: %d",total));
				}

				if(DoesPlayerHaveItemByExtraParam(i,LONG_JOHNS))  { 

					total++;
					//SendClientMessage(i, -1, sprintf("long johns found - total: %d",total));
				}

				remove = total/2;
				//SendClientMessage(i,-1,sprintf("total: %d, remove: %d, current temp: %d.%d",total,remove,Character[i][character_temperature],Character[i][character_temperature_decimal]));

				if(remove) { 

					if(2 > remove) { Character[i][character_temperature_decimal] -= 6-remove; }
					else {

						if(Character[i][character_temperature] != 98) {
					
							if(Character[i][character_temperature] < 98) { Character[i][character_temperature]++; }
							if(Character[i][character_temperature_decimal] < 6) { Character[i][character_temperature_decimal]++; }
						}
					}
				}
				else { Character[i][character_temperature_decimal] -= 6; }

				if(Character[i][character_temperature_decimal] < 0) {

					Character[i][character_temperature]--;
					Character[i][character_temperature_decimal] = 9;
				}
			}
			case 1..54: {

				new total = 0,remove = 0,found_item[MAX_ATTACHMENTS];
				for(new j; j < MAX_ATTACHMENTS; j++) {

					switch(GetPlayerAttachThermInfo(i,j)) {

						case 0: { continue; } //THERMAL_UNDEFINED 
						case 1,2,3: { continue; } //THERMAL_MIN/MOD/MAX_HEAT_PROTECT
						case 4: { //THERMAL_MIN_COLD_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								total++;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						} 
						case 5: { //THERMAL_MOD_COLD_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								total += 2;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						} 
						case 6: { //THERMAL_MAX_COLD_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								total += 3;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						}
						default: { 
							
							skipItem:
							continue; 
						} 
					}
				}

				found_item[0] = found_item[1] = found_item[2] = found_item[3] = found_item[4] = -1;

				if(DoesPlayerHaveItemByExtraParam(i,GLOVES) != -1) { 

					total++;
					//SendClientMessage(i, -1, sprintf("gloves found - total: %d",total));
				}

				if(DoesPlayerHaveItemByExtraParam(i,LONG_JOHNS) != -1)  { 

					total++;
					//SendClientMessage(i, -1, sprintf("long johns found - total: %d",total));
				}

				remove = total/2;
				//SendClientMessage(i,-1,sprintf("total: %d, remove: %d, current temp: %d.%d",total,remove,Character[i][character_temperature],Character[i][character_temperature_decimal]));

				if(remove) { 

					if(1 > remove) { Character[i][character_temperature_decimal] -= 1-remove; }
					else {

						if(Character[i][character_temperature] != 98) {
					
							if(Character[i][character_temperature] < 98) { Character[i][character_temperature]++; }
							if(Character[i][character_temperature_decimal] < 6) { Character[i][character_temperature_decimal]++; }
						}
					}
				}
				else { Character[i][character_temperature_decimal]--; }

				if(Character[i][character_temperature_decimal] < 0) {

					Character[i][character_temperature]--;
					Character[i][character_temperature_decimal] = 9;
				}
			}
			case 55..84: {

				new remove = 0,heat = 0,cold = 0,found_item[MAX_ATTACHMENTS];
				for(new j; j < MAX_ATTACHMENTS; j++) {

					switch(GetPlayerAttachThermInfo(i,j)) {

						case 0: { continue; } //THERMAL_UNDEFINED 
						case 1: { //THERMAL_MIN_HEAT_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								heat++;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						}
						case 2: { //THERMAL_MOD_HEAT_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								heat += 2;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						}
						case 3: { //THERMAL_MAX_HEAT_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								heat += 3;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						}
						case 4: { //THERMAL_MIN_COLD_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								cold++;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						} 
						case 5: { //THERMAL_MOD_COLD_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								cold += 2;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						} 
						case 6: { //THERMAL_MAX_COLD_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								cold += 3;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						}
						default: { 
							
							skipItem:
							continue; 
						} 
					}
				}

				found_item[0] = found_item[1] = found_item[2] = found_item[3] = found_item[4] = -1;

				if(DoesPlayerHaveItemByExtraParam(i,GLOVES) != -1) { 

					cold++;
					//SendClientMessage(i, -1, "gloves found");
				}

				if(DoesPlayerHaveItemByExtraParam(i,LONG_JOHNS) != -1)  { 

					cold++;
					//SendClientMessage(i, -1, "long johns found");
				}

				if(cold > heat) {

					if(cold >= 2) {

						remove = cold/2;
						Character[i][character_temperature_decimal] += remove;
						if(Character[i][character_temperature_decimal] >= 10) {

							Character[i][character_temperature]++;
							Character[i][character_temperature_decimal] = 0;
						}
						continue;
					}
					else { goto skipTempCalc; }
				}
				else {

					if(Character[i][character_temperature] > 98) {

						if(heat >= 2) {

							remove = heat/2;
							Character[i][character_temperature_decimal] -= remove;
							if(Character[i][character_temperature_decimal] < 0) {

								Character[i][character_temperature]--;
								Character[i][character_temperature_decimal] = 9;
							}
							continue;
						}
						else { goto skipTempCalc; }
					}
				}

				skipTempCalc:

				if(Character[i][character_temperature] != 98) {
					
					if(Character[i][character_temperature] < 98) { 

						Character[i][character_temperature_decimal]++;
						if(Character[i][character_temperature_decimal] >= 10) {

							Character[i][character_temperature]++;
							Character[i][character_temperature_decimal] = 0;
						}
					}
					else if(Character[i][character_temperature] > 98) { 

						Character[i][character_temperature_decimal]--;
						if(Character[i][character_temperature_decimal] < 0) {

							Character[i][character_temperature]--;
							Character[i][character_temperature_decimal] = 9;
						}
					}
					else if(Character[i][character_temperature] == 98) {

						if(Character[i][character_temperature_decimal] < 8) {

							Character[i][character_temperature_decimal]++;
						}
						else if(Character[i][character_temperature_decimal] > 8) {

							Character[i][character_temperature_decimal]--;
						}
					}
				}
			}
			case 85..120: {

				new remove = 0,heat = 0,cold = 0,found_item[MAX_ATTACHMENTS];
				for(new j; j < MAX_ATTACHMENTS; j++) {

					switch(GetPlayerAttachThermInfo(i,j)) {

						case 0: { continue; } //THERMAL_UNDEFINED 
						case 1: { //THERMAL_MIN_HEAT_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								heat++;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						}
						case 2: { //THERMAL_MOD_HEAT_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								heat += 2;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						}
						case 3: { //THERMAL_MAX_HEAT_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								heat += 3;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						}
						case 4: { //THERMAL_MIN_COLD_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								cold++;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						} 
						case 5: { //THERMAL_MOD_COLD_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								cold += 2;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						} 
						case 6: { //THERMAL_MAX_COLD_PROTECT

							for(new k; k < MAX_ATTACHMENTS; k++) {

								if(found_item[k] == GetPlayerAttachmentModel(i,j)) {

									goto skipItem;
									break;
								}
								continue;
							}
							if(IsPlayerAttachmentVisible(i,j)) {

								cold += 3;
								found_item[j] = GetPlayerAttachmentModel(i,j);
							}
							else continue;
						}
						default: { 
							
							skipItem:
							continue; 
						} 
					}
				}

				found_item[0] = found_item[1] = found_item[2] = found_item[3] = found_item[4] = -1;

				if(DoesPlayerHaveItemByExtraParam(i,GLOVES) != -1) { 

					cold++;
					//SendClientMessage(i, -1, "gloves found");
				}

				if(DoesPlayerHaveItemByExtraParam(i,LONG_JOHNS) != -1)  { 

					cold++;
					//SendClientMessage(i, -1, "long johns found");
				}

				if(cold > heat) {

					if(cold >= 2) {

						remove = cold/2;
						Character[i][character_temperature_decimal] += 2+remove;
						if(Character[i][character_temperature_decimal] >= 10) {

							Character[i][character_temperature]++;
							Character[i][character_temperature_decimal] = 0;
						}
						continue;
					}
					else { goto skipTempCalc; }
				}
				else {

					if(Character[i][character_temperature] >= 99) {

						if(heat >= 2) {

							remove = heat/2;
							if(2 > remove) { Character[i][character_temperature] -= 2-remove; }
							if(Character[i][character_temperature_decimal] < 0) {

								Character[i][character_temperature]--;
								Character[i][character_temperature_decimal] = 9;
							}
							continue;
						}
						else { goto skipTempCalc; }
					}
				}

				skipTempCalc:

				if(Character[i][character_temperature] != 98) {
					
					if(Character[i][character_temperature] < 98) { 

						Character[i][character_temperature_decimal]++;
						if(Character[i][character_temperature_decimal] >= 10) {

							Character[i][character_temperature]++;
							Character[i][character_temperature_decimal] = 0;
						}
					}
					else if(Character[i][character_temperature] > 98) { 

						Character[i][character_temperature_decimal]--;
						if(Character[i][character_temperature_decimal] < 0) {

							Character[i][character_temperature]--;
							Character[i][character_temperature_decimal] = 9;
						}
					}
					else if(Character[i][character_temperature] == 98) {

						if(Character[i][character_temperature_decimal] < 8) {

							Character[i][character_temperature_decimal]++;
						}
						else if(Character[i][character_temperature_decimal] > 8) {

							Character[i][character_temperature_decimal]--;
						}
					}
				}
			}
			case INVALID_TEMPERATURE: { continue; }
			default: { continue; }
		}
		
		new query[128];
		mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_temperature = %d, character_temperature_decimal = %d WHERE character_id = %d",Character[i][character_temperature],Character[i][character_temperature_decimal],Character[i][character_id]);
		mysql_tquery(mysql,query);

		UpdateGUI(i);
		*/
	}

	return true;
}

task CharacterTemperatureHandler[60000]() {

	foreach(new i : Player) {

		new query[128];
		if(Character[i][character_temperature] != 98) { 

			Character[i][character_temperature] = 98; 
			if(Character[i][character_temperature_decimal] != 6) { Character[i][character_temperature_decimal] = 6; }
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_temperature = %d,character_temperature_decimal WHERE character_id = %d",Character[i][character_temperature],Character[i][character_temperature_decimal],Character[i][character_id]);
			mysql_tquery(mysql,query);
		}
		/*
		if(!IsPlayerSpawned(i) || !IsPlayerLogged[i] || GetPlayerVirtualWorld(i) != 0 || IsPlayerOnAdminDuty[i]) { continue; }
		if(Character[i][character_temperature] > 120) {

			new query[128];
			Character[i][character_temperature] = 120;
			mysql_format(mysql,query,sizeof(query),"UPDATE characters SET character_temperature = %d WHERE character_id = %d",Character[i][character_temperature],Character[i][character_id]);
			mysql_tquery(mysql,query);
			UpdateGUI(i);
			continue;
		}
		switch(Character[i][character_temperature]) {

			case 0..95: {

				if(Character[i][character_temperature_decimal] == 0) {

					if(!GetPVarInt(i,"temperature_warning")) {

						SetPVarInt(i,"temperature_warning",1);
						SendServerMessage(i,"You're starting to suffer from hypothermia, find a way to warm up immediately.",MSG_TYPE_WARN);
					}
					else if(GetPVarInt(i,"temperature_warning") == 2 || GetPVarInt(i,"temperature_warning") == 3) {

						SetPVarInt(i,"temperature_warning",1);
						SendServerMessage(i,"You're starting to suffer from hypothermia, find a way to warm up immediately.",MSG_TYPE_WARN);
					}
					new dmg = 95-Character[i][character_temperature];
					if(!dmg) { dmg = 1; }
					SetCharacterHealth(i,Character[i][character_health]-dmg);
				}
			}
			case 96..99: { return true; }
			case 100..103: {

				if(!GetPVarInt(i,"temperature_warning")) {

					SetPVarInt(i,"temperature_warning",2);
					SendServerMessage(i,"You're starting to feel too warm, you should think about cooling down.",MSG_TYPE_WARN);
				}
				else if(GetPVarInt(i,"temperature_warning") == 1 || GetPVarInt(i,"temperature_warning") == 3) {

					SetPVarInt(i,"temperature_warning",2);
					SendServerMessage(i,"You're starting to feel too warm, you should think about cooling down.",MSG_TYPE_WARN);
				}
				SetCharacterHealth(i,Character[i][character_health]-1.0);
			}
			case 104..120: {

				if(!GetPVarInt(i,"temperature_warning")) {

					SetPVarInt(i,"temperature_warning",3);
					SendServerMessage(i,"You're starting to suffer from heat stroke, find a way to cool off immediately.",MSG_TYPE_WARN);
				}
				else if(GetPVarInt(i,"temperature_warning") == 1 || GetPVarInt(i,"temperature_warning") == 2) {

					SetPVarInt(i,"temperature_warning",3);
					SendServerMessage(i,"You're starting to suffer from heat stroke, find a way to cool off immediately.",MSG_TYPE_WARN);
				}
				new dmg = Character[i][character_temperature]-104;
				if(!dmg) { dmg = 1; }
				SetCharacterHealth(i,Character[i][character_health]-dmg);
			}
		}
		*/
	}
	return true;
}