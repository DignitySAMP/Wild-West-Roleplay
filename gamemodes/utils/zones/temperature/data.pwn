//todo: season, time & weather based temp generation
//serverHour
//date_getSeasonID ( serverMonth )

/*
character temperature info
	-normal temp: 97.7-99.4 F
	-hypothermia: 95.0 F or lower
	-hyperthermia: 99.5-103.9 F
	-hyperpyrexia: 104.0-106.7 F

items
	-thermostat
	-vest (attachment)
	-jacket (attachment)
	-gloves
	-long johns
	-face mask (attachment) - 19801
*/

#define INVALID_TEMPERATURE		(-65535)

enum E_TEMPERATURE_ZONE_DATA {

	temp_zone_name[36],
	Float:temp_zone_minx,
	Float:temp_zone_miny,
	Float:temp_zone_maxx,
	Float:temp_zone_maxy
}

new TemperatureZones[][E_TEMPERATURE_ZONE_DATA] = {

	{ "Freezing Zone", -2978.5, 2076.5, -2148.5, 2997.5 }, 
	{ "Cold Zone 1", -2148.5, 2075.5, -1860.5, 2997.5 }, 
	{ "Cold Zone 2", -1860.5, 2832.5, -1502.5, 2997.5 }, 
	{ "Warm Zone 1", -1860.5, 456.5, 455.5, 2832.5 }, 
	{ "Warm Zone 2", -1502.5, 2830.5, 457.5, 2997.5 }, 
	{ "Hot Zone", 455.5, 550.5, 2995.0, 2997.5 }
};

new ZoneTemperature[sizeof(Zones)];

Init_Temperature() {

	ResetZoneTemperatures();
	for(new i; i < sizeof(Zones); i++) {

		if(!strcmp(Zones[i][zone_name],"Refugee Camp") || !strcmp(Zones[i][zone_name],"Staff Island")) { continue; }
		new Float:center_x,Float:center_y,tempamount;
		GetGangZoneCenter(Zones[i][zone_minx],Zones[i][zone_miny],Zones[i][zone_maxx],Zones[i][zone_maxy],center_x,center_y);
		switch(GetTemperatureZone(center_x,center_y)) {

			case 0: { tempamount = randomEx(-40,0); }
			case 1,2: { tempamount = randomEx(1,54); }
			case 3,4: { tempamount = randomEx(55,84); }
			case 5: { tempamount = randomEx(85,120); }
			default: { tempamount = INVALID_TEMPERATURE; }
		}
		ZoneTemperature[i] = tempamount;
		printf("[TEMPERATURE]: Zone ID %d temperature is %d F°",i,ZoneTemperature[i]);
	}
	return true;
}

task AutoTempCalculation[3600000]() {

	new oldtemp[sizeof(Zones)];
	for(new i; i < sizeof(Zones); i++) {

		if(!strcmp(Zones[i][zone_name],"Refugee Camp") || !strcmp(Zones[i][zone_name],"Staff Island")) { continue; }
		oldtemp[i] = ZoneTemperature[i];
		new Float:center_x,Float:center_y,tempchange,tempmodifier;
		new divider = 6;
		GetGangZoneCenter(Zones[i][zone_minx],Zones[i][zone_miny],Zones[i][zone_maxx],Zones[i][zone_maxy],center_x,center_y);
		switch(GetTemperatureZone(center_x,center_y)) {

			case 0: { 
				
				tempmodifier = randomEx(-40,0)/divider;
				if(ZoneTemperature[i]-tempmodifier > 0) { tempchange = ZoneTemperature[i]+tempmodifier; }
				else { tempchange = ZoneTemperature[i]-tempmodifier; }
			}
			case 1,2: { 
				
				tempmodifier = randomEx(1,54)/divider;
				if(ZoneTemperature[i]+tempmodifier > 54) { tempchange = ZoneTemperature[i]-tempmodifier; }
				else { tempchange = ZoneTemperature[i]+tempmodifier; } 
			}
			case 3,4: { 
				
				tempmodifier = randomEx(55,84)/divider; 
				if(ZoneTemperature[i]+tempmodifier > 84) { tempchange = ZoneTemperature[i]-tempmodifier; }
				else { tempchange = ZoneTemperature[i]+tempmodifier; }
			}
			case 5: { 

				tempmodifier = randomEx(85,120)/divider; 
				if(ZoneTemperature[i]+tempmodifier > 120) { tempchange = ZoneTemperature[i]-tempmodifier; }
				else { tempchange = ZoneTemperature[i]+tempmodifier; }
			}
			default: { tempchange = INVALID_TEMPERATURE; }
		}

		ZoneTemperature[i] = tempchange;
		printf("[TEMPERATURE]: Zone ID %d temperature change from %d F° to %d F°",i,oldtemp[i],ZoneTemperature[i]);
	}
	return true;
}