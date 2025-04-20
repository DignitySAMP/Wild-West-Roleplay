ResetZoneTemperatures() {

	for(new i; i < sizeof(Zones); i++) {

		ZoneTemperature[i] = INVALID_TEMPERATURE;
	}
	return true;
}

GetTemperatureZone(Float:x,Float:y) {

	for(new i; i < sizeof(TemperatureZones); i++) {

		if ( x >= TemperatureZones [ i ] [ temp_zone_minx ] && x <= TemperatureZones [ i ] [ temp_zone_maxx ] && y >= TemperatureZones [ i ] [ temp_zone_miny ] && y <= TemperatureZones [ i ] [ temp_zone_maxy ]) {

			return i;
		}

		else continue ;
	}

	return -1 ;
}

GetPlayerTemperatureZone ( playerid ) {

	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);

	for ( new i, p = sizeof ( TemperatureZones ); i < p; i ++ ) {

		if ( X >= TemperatureZones [ i ] [ temp_zone_minx ] && X <= TemperatureZones [ i ] [ temp_zone_maxx ] && Y >= TemperatureZones [ i ] [ temp_zone_miny ] && Y <= TemperatureZones [ i ] [ temp_zone_maxy ]) {

			return i;
		}

		else continue ;

	}

	return -1;
}

GetZoneTemperature(zoneid) {

	for(new i; i < sizeof(Zones); i++) {

		if(zoneid == i) { 

			return ZoneTemperature[zoneid];
		}
	}
	return -1;
}