#define DESERT_ROAD_MODEL 	 		(16202)
#define DESERT_ROAD_TXD 			"des_cen"
#define DESERT_ROAD_TXDNAME 		"des_dirttrack1"

#define DESERT_ROADSIZE_MODEL      (8538)
#define DESERT_ROADSIDE_TXD         "vgsrailroad"
#define DESERT_ROADSIDE_TXDNAME     "des_dirt1"

LoadRoadObjects () {
	new txt_map;

	txt_map = CreateDynamicObject(11430, -801.14838, 698.93750, 9.13177,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 8,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;


	txt_map = CreateDynamicObject(11537, -847.16412, 852.28912, 12.18120,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 2,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 3,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11557, -802.53131, 1070.78125, 25.37006,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 2,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11536, -1023.64838, 1088.18750, 19.46683,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 2,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 3,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 10,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11560, -614.15631, 1083.82813, 6.37180,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11559, -648.76563, 1299.39063, -2.93290,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 2,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11535, -806.50781, 1310.53125, 7.22370,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 2,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 3,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6, DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11534, -1009.28131, 1255.65625, 20.10340,   0.00000, 0.00000, 0.0000);
	SetDynamicObjectMaterial(txt_map, 1, DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 2,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 3,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME   ) ;
	SetDynamicObjectMaterial(txt_map, 8,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 9,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 10,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11542, -1016.78912, 1372.00781, 21.16580,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 3,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME   ) ;
	SetDynamicObjectMaterial(txt_map, 8,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 10,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11555, -981.32031, 1473.06250, 29.66460,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11553, -1211.30469, 1545.18750, 3.69650,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 4,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11532, -779.90631, 1535.17188, 28.40361,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 2, DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 3, DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6, DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 7, DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 8, DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 9, DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 10, DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 15, DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11554, -974.47662, 1596.50000, 3.91840,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 9,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 10,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11531, -947.52344, 1750.87500, 25.67,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 3,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 0,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11552, -1175.67969, 1740.92969, 36.69624,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 9,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 10, DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 13,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11526, -1248.97656, 1934.34375, 81.40842,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 9,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME   ) ;
	SetDynamicObjectMaterial(txt_map, 8,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME   ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11522, -1283.52344, 2173.95313, 77.01682,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 8,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11517, -1303.70, 2382.11,  102.92,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 2,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11516, -1543.91406, 2386.89844, 54.71580,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11511, -1489.72656, 2617.60156, 69.08891,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 4,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 13,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 14,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11512, -1251.07813, 2622.30469, 73.83083,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 9,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME   ) ;
	SetDynamicObjectMaterial(txt_map, 13,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME   ) ;
	SetDynamicObjectMaterial(txt_map, 14,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME   ) ;
	SetDynamicObjectMaterial(txt_map, 15,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME   ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11510, -1720.34375, 2615.95313, 82.02,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 8,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 11,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11515, -1757.03125, 2385.03125, 52.30608,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 4,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 8,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11530, -1408.73438, 1726.65625, 8.88186,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 4,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11525, -1489.46875, 1930.00781, 34.83909,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 3,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 4,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 14,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 15,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11529, -1648.618, 1748.61719, 1.44,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 4,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11524, -1731.61719, 1916.03906, 8.02569,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 2,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 4,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11520, -1724.67969, 2147.22656, 21.18647,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 8,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11519, -1946.6500, 2153.9500, 3.8293,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 4,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 2,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 3,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11509, -1938.18750, 2600.16063, 93.08325,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  11509, "des_nw2", "des_grass2dirt1"  ) ;
	SetDynamicObjectMaterial(txt_map, 2,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 8,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 9,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11514, -1979.61719, 2361.43750, 36.76798,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 0,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 1,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 9,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11528, -866.399, 1929.03125, 50.30,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 8,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME   ) ;
	SetDynamicObjectMaterial(txt_map, 7,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 4,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME   ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11539, -794.81813, 2025.43750, 31.34355,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0,  8839, "vgsecarshow", "sw_wallbrick_06"  ) ;
	SetDynamicObjectMaterial(txt_map, 1,  8839, "vgsecarshow", "sw_wallbrick_06"  ) ;
	SetDynamicObjectMaterial(txt_map, 2,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 3,  8839, "vgsecarshow", "sw_wallbrick_06"  ) ;
	SetDynamicObjectMaterial(txt_map, 4,  8839, "vgsecarshow", "sw_wallbrick_06"  ) ;
	SetDynamicObjectMaterial(txt_map, 5,  8839, "vgsecarshow", "sw_wallbrick_06"  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  8839, "vgsecarshow", "sw_wallbrick_06"  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11540, -615.36060, 2028.43237, 31.37373,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0,  8839, "vgsecarshow", "sw_wallbrick_06"  ) ;
	SetDynamicObjectMaterial(txt_map, 1,  8839, "vgsecarshow", "sw_wallbrick_06"  ) ;
	SetDynamicObjectMaterial(txt_map, 2,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 3,  8839, "vgsecarshow", "sw_wallbrick_06"  ) ;
	SetDynamicObjectMaterial(txt_map, 4,  8839, "vgsecarshow", "sw_wallbrick_06"  ) ;
	SetDynamicObjectMaterial(txt_map, 5,  8839, "vgsecarshow", "sw_wallbrick_06"  ) ;
	SetDynamicObjectMaterial(txt_map, 6,  8839, "vgsecarshow", "sw_wallbrick_06"  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11527, -1021.02344, 1958.82813, 65.74234,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 3,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 4,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME ) ;
	SetDynamicObjectMaterial(txt_map, 5,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(11628, -2142.07031, 2593.13281, 82.80799,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1,  DESERT_ROADSIZE_MODEL, DESERT_ROADSIDE_TXD, DESERT_ROADSIDE_TXDNAME  ) ;
	SetDynamicObjectMaterial(txt_map, 3,  DESERT_ROAD_MODEL, DESERT_ROAD_TXD, DESERT_ROAD_TXDNAME ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9267, -2329.75000, 2654.57031, 55.64497,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1,   11509, "des_nw2", "rocktbrn128blndlit"  ) ;
	SetDynamicObjectMaterial(txt_map, 0,  8868, "vgsecnstrct02", "desmudtrail" ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9266, -2479.17969, 2641.55469, 61.77779,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1,   11509, "des_nw2", "rocktbrn128blndlit"  ) ;
	SetDynamicObjectMaterial(txt_map, 0,  8868, "vgsecnstrct02", "desmudtrail" ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9264, -2657.78906, 2535.45313, 69.01968,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1,   11509, "des_nw2", "rocktbrn128blndlit"  ) ;
	SetDynamicObjectMaterial(txt_map, 0,  8868, "vgsecnstrct02", "desmudtrail" ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9265, -2674.17969, 2576.99219, 83.08440,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1,   11509, "des_nw2", "rocktbrn128blndlit"  ) ;
	SetDynamicObjectMaterial(txt_map, 0,  8868, "vgsecnstrct02", "desmudtrail" ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9476, -2750.64063, 2393.84375, 79.97660,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1,   11509, "des_nw2", "rocktbrn128blndlit"  ) ;
	SetDynamicObjectMaterial(txt_map, 0,  8868, "vgsecnstrct02", "desmudtrail" ) ;
	SetDynamicObjectMaterial(txt_map, 2,  8868, "vgsecnstrct02", "desmudtrail" ) ;
	SetDynamicObjectMaterial(txt_map, 3,  8868, "vgsecnstrct02", "desmudtrail" ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9262, -2717.78125, 2249.25781, 61.51371,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1,   11509, "des_nw2", "rocktbrn128blndlit"  ) ;
	SetDynamicObjectMaterial(txt_map, 0,  8868, "vgsecnstrct02", "desmudtrail" ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9231, -2688.62500, 2421.92188, 51.27766,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1,   11509, "des_nw2", "rocktbrn128blndlit"  ) ;
	SetDynamicObjectMaterial(txt_map, 0,  8868, "vgsecnstrct02", "desmudtrail" ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9250, -2580.87500, 2471.77344, 23.64446,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1,   11509, "des_nw2", "rocktbrn128blndlit"  ) ;
	SetDynamicObjectMaterial(txt_map, 0,  8868, "vgsecnstrct02", "desmudtrail" ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9251, -2524.92969, 2342.88281, 9.79671,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1,  8868, "vgsecnstrct02", "desmudtrail" ) ;
	SetDynamicObjectMaterial(txt_map, 2,   11509, "des_nw2", "rocktbrn128blndlit"  ) ;
	SetDynamicObjectMaterial(txt_map, 3, 8868, "vgsecnstrct02", "desmudtrail"  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9232, -2391.11719, 2354.72656, 4.38696,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1,  11509, "des_nw2", "rocktbrn128blndlit") ;
	SetDynamicObjectMaterial(txt_map, 0,  8868, "vgsecnstrct02", "desmudtrail"  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9233, -2584.56250, 2359.71875, 8.86685,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0,  8868, "vgsecnstrct02", "desmudtrail" ) ;
	SetDynamicObjectMaterial(txt_map, 1,   11509, "des_nw2", "rocktbrn128blndlit"  ) ;
	SetDynamicObjectMaterial(txt_map, 3, 8868, "vgsecnstrct02", "desmudtrail"  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9205, -2482.16333, 2334.22974, 9.76450,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0,	8868, "vgsecnstrct02", "desmudtrail" ) ;
	SetDynamicObjectMaterial(txt_map, 1,  11509, "des_nw2", "rocktbrn128blndlit"  ) ;
	SetDynamicObjectMaterial(txt_map, 3, 8868, "vgsecnstrct02", "desmudtrail"  ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9252, -2399.46875, 2404.75000, 10.12806,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0,	8868, "vgsecnstrct02", "desmudtrail" ) ;
	SetDynamicObjectMaterial(txt_map, 1, 	11509, "des_nw2", "rocktbrn128blndlit" ) ;
	SetDynamicObjectMaterial(txt_map, 2, 	11509, "des_nw2", "rocktbrn128blndlit" ) ;
	SetDynamicObjectMaterial(txt_map, 3, 	8868, "vgsecnstrct02", "desmudtrail" ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9222, -2276.53906, 2330.14844, 4.23177,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0,	8868, "vgsecnstrct02", "desmudtrail" ) ;
	SetDynamicObjectMaterial(txt_map, 1,	 11509, "des_nw2", "rocktbrn128blndlit" ) ;
	SetDynamicObjectMaterial(txt_map, 2,	8868, "vgsecnstrct02", "desmudtrail" ) ;
	SetDynamicObjectMaterial(txt_map, 3,	8868, "vgsecnstrct02", "desmudtrail" ) ;
	SetDynamicObjectMaterial(txt_map, 4,	8868, "vgsecnstrct02", "desmudtrail" ) ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9254, -2463.66406, 2234.03906, 4.38688,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0,	11509, "des_nw2", "rocktbrn128blndlit" ) ;
	SetDynamicObjectMaterial(txt_map, 2,	8868, "vgsecnstrct02", "desmudtrail" ) ;
	SetDynamicObjectMaterial(txt_map, 3,	8868, "vgsecnstrct02", "desmudtrail" ) ;
	SetDynamicObjectMaterial(txt_map, 4,	8868, "vgsecnstrct02", "desmudtrail" ) ;

	// Bayside dock fix
	txt_map = CreateDynamicObject(9230, -2413.23438, 2249.65625, -19.07030,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0, 916, "crates_n_stuffext", "CJ_SLATEDWOOD") ;
	SetDynamicObjectMaterial(txt_map, 1, 13731, "mulveg2lahills", "des_woodfence1", 0xFFFFFFFF);
	SetDynamicObjectMaterial(txt_map, 3, 1463, "BREAK_FARM", "CJ_DarkWood") ;
	SetDynamicObjectMaterial(txt_map, 4, 916, "crates_n_stuffext", "CJ_SLATEDWOOD") ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9257, -2545.82031, 2225.85156, -19.11720,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0, 13731, "mulveg2lahills", "des_woodfence1", 0xFFFFFFFF);
	SetDynamicObjectMaterial(txt_map, 2, 1463, "BREAK_FARM", "CJ_DarkWood") ;
	SetDynamicObjectMaterial(txt_map, 3, 916, "crates_n_stuffext", "CJ_SLATEDWOOD") ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9255, -2614.08594, 2259.29688, 6.14060,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 1, 11509, "des_nw2", "rocktbrn128blndlit"  ) ;
	SetDynamicObjectMaterial(txt_map, 2, 8868, "vgsecnstrct02", "desmudtrail") ;
	SetDynamicObjectMaterial(txt_map, 3, 916, "crates_n_stuffext", "CJ_SLATEDWOOD") ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9351, -2592.34375, 2246.07031, 3.98440,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0, 916, "crates_n_stuffext", "CJ_SLATEDWOOD") ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9329, -2329.55469, 2284.57813, -19.07030,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0, 916, "crates_n_stuffext", "CJ_SLATEDWOOD") ; // entrance
	SetDynamicObjectMaterial(txt_map, 1, 916, "crates_n_stuffext", "CJ_SLATEDWOOD") ;
	SetDynamicObjectMaterial(txt_map, 2, 13731, "mulveg2lahills", "des_woodfence1", 0xFFFFFFFF);
	SetDynamicObjectMaterial(txt_map, 3, 916, "crates_n_stuffext", "CJ_SLATEDWOOD") ;
	SetDynamicObjectMaterial(txt_map, 4, 1463, "BREAK_FARM", "CJ_DarkWood") ;
	SetDynamicObjectMaterial(txt_map, 5, 916, "crates_n_stuffext", "CJ_SLATEDWOOD") ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9253, -2218.27344, 2359.90625, -19.09380,   0.00000, 0.00000, 44.30000);
	SetDynamicObjectMaterial(txt_map, 0, 916, "crates_n_stuffext", "CJ_SLATEDWOOD") ;
	SetDynamicObjectMaterial(txt_map, 1, 13731, "mulveg2lahills", "des_woodfence1", 0xFFFFFFFF);
	SetDynamicObjectMaterial(txt_map, 3, 1463, "BREAK_FARM", "CJ_DarkWood") ;
	SetDynamicObjectMaterial(txt_map, 4, 916, "crates_n_stuffext", "CJ_SLATEDWOOD") ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	txt_map = CreateDynamicObject(9229, -2284.35156, 2460.60156, -19.09380,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(txt_map, 0, 916, "crates_n_stuffext", "CJ_SLATEDWOOD") ;
	SetDynamicObjectMaterial(txt_map, 1, 13731, "mulveg2lahills", "des_woodfence1", 0xFFFFFFFF);
	SetDynamicObjectMaterial(txt_map, 3, 1463, "BREAK_FARM", "CJ_DarkWood") ;
	SetDynamicObjectMaterial(txt_map, 4, 916, "crates_n_stuffext", "CJ_SLATEDWOOD") ;
	Streamer_ToggleItemStatic ( STREAMER_TYPE_OBJECT, txt_map, 1 ) ;

	return true;
}
