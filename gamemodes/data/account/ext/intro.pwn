new dyn_Obj_Chair, dyn_Obj_Chair_Val ;
public OnDynamicObjectMoved( objectid) {

	if ( objectid == dyn_Obj_Chair ) {

		dyn_Obj_Chair_Val = ! dyn_Obj_Chair_Val ;

		if ( dyn_Obj_Chair_Val ) {
			MoveDynamicObject(dyn_Obj_Chair, -30.17, 2113.68408, 16.99290, 0.025, -5.00000, 0.00000, 338.00024);
		}

		else if ( ! dyn_Obj_Chair_Val) {
			MoveDynamicObject(dyn_Obj_Chair, -30.15, 2113.68408, 16.99290, 0.025, 20, 0, 338 ) ;
		}

		//printf("Moved %d | %d",objectid , dyn_Obj_Chair_Val) ;
	}

	#if defined intro_OnDynamicObjectMoved
		return intro_OnDynamicObjectMoved( objectid );
	#else
		return 1;
	#endif
}

#if defined _ALS_OnDynamicObjectMoved
	#undef OnDynamicObjectMoved
#else
	#define _ALS_OnDynamicObjectMoved
#endif

#define OnDynamicObjectMoved intro_OnDynamicObjectMoved
#if defined intro_OnDynamicObjectMoved
	forward intro_OnDynamicObjectMoved(objectid ) ;
#endif

StartIntro ( playerid ) {

	switch ( random ( 3 ) ) {

		case 0: {

			InterpolateCameraPos 	( playerid, -31.927661, 2110.429199, 18.589181,  -29.0172, 2115.6719, 18.4520, 10000);
			InterpolateCameraLookAt ( playerid, -29.8427, 2115.1118, 18.3270, -32.759414, 2113.078369, 18.204807, 10000);
			PlayAudioStreamForPlayer(playerid, "http://play.wildwest-roleplay.com/files/sounds/intro/ennio_morricone_fistful_of_dollars.mp3");
		}

		case 1: {

			InterpolateCameraPos(playerid, -879.5424, -2187.2505, 30.7152, -872.4539, -2178.1621, 27.4038, 10000);
			InterpolateCameraLookAt(playerid, -878.6913, -2186.7302, 30.4202, -871.9009, -2178.9954, 27.0538, 10000);
			PlayAudioStreamForPlayer(playerid, "http://play.wildwest-roleplay.com/files/sounds/intro/ennio_morricone_ecstacy_of_gold.mp3");
		}

		case 2: {

			InterpolateCameraPos(playerid, 550.2329, 2331.3120, 35.6223,  546.3969, 2354.9231, 32.6356, 10000);
			InterpolateCameraLookAt(playerid, 551.1557, 2331.6941, 35.3323,  547.3342, 2354.5786, 32.6056, 10000);
			PlayAudioStreamForPlayer(playerid, "http://play.wildwest-roleplay.com/files/sounds/intro/ennio_morricone_the_trio.mp3");
		}
	}

	return true ;
}

LoadIntroMap () {

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////

	CreateDynamicObject(3356, -25.76490, 2118.18652, 20.78080,   0.00000, 0.00000, 0.00000);
	new thedoors = CreateDynamicObject(1536, -29.44960, 2115.79590, 16.97260,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(thedoors, 0, 1495, "ext_doors2", "CJ_SCOR_DOOR", 0xFFFFFFFF);
	dyn_Obj_Chair = CreateDynamicObject(2096, -30.17570, 2113.68408, 16.99290,   -5.00000, 0.00000, 338.00024);
	SetDynamicObjectMaterial(dyn_Obj_Chair, 0, 1637, "od_beachstuff", "wood02", 0xFFFFFFFF);
	MoveDynamicObject(dyn_Obj_Chair, -30.15, 2113.68408, 16.99290, 15.0, 20, 0, 338 ) ;
	new tree = CreateDynamicObject(769, -62.37600, 2090.10425, 15.61920,   0.00000, 0.00000, 91.00000);
 	SetDynamicObjectMaterial(tree, 0, 12954, "sw_furniture", "CJ_WOOD5", 0xFFFFFFFF);
	CreateDynamicObject(357, -32.44160, 2115.63184, 17.23370,   0.00000, -84.00000, -91.00000);
	CreateDynamicObject(19553, -32.40580, 2112.94434, 18.56900,   -11.00000, -25.00000, -18.00000);
	new table = CreateDynamicObject(1516, -31.20679, 2113.81445, 17.13200,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(table, 0, 11631, "mp_ranchcut", "mpCJ_DarkWood", 0xFFFFFFFF);
	CreateDynamicObject(19823, -31.22760, 2114.18726, 17.65890,   0.00000, 0.00000, 113.00000);
	CreateDynamicObject(19818, -31.18149, 2114.01587, 17.73850,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1665, -30.88300, 2114.06055, 17.67860,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3044, -30.70564, 2114.22583, 17.69920,   0.00000, 0.00000, -69.00000);
	CreateDynamicObject(11733, -43.15464, 2115.12427, 16.02000,   2.00000, 0.00000, 200.13220);
	CreateDynamicObject(1451, -38.49920, 2112.50000, 17.09380,   0.00000, 0.00000, 113.00000);
	CreateDynamicObject(1463, -37.60686, 2114.07349, 16.59850,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19637, -26.81200, 2114.44141, 16.95350,   0.00000, 0.00000, 350.32770);
	CreateDynamicObject(19637, -26.32480, 2115.14819, 16.95350,   0.00000, 0.00000, 222.00000);
	CreateDynamicObject(19638, -25.88392, 2114.24512, 16.95350,   0.00000, 0.00000, 350.32770);
	CreateDynamicObject(1458, -42.76374, 2113.59814, 16.27660,   22.00000, 0.00000, 199.00000);
	CreateDynamicObject(14875, -40.84340, 2109.92163, 17.21030,   0.00000, 0.00000, 141.79480);
	CreateDynamicObject(759, -57.01506, 2108.29443, 16.18786,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(759, -46.86946, 2100.06128, 15.36245,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(759, -55.20940, 2096.64844, 16.47390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(759, -51.63698, 2112.71021, 16.59390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(759, -46.86840, 2116.49097, 15.31676,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(759, -57.96045, 2102.76880, 16.59390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(650, -48.48260, 2105.16455, 16.38775,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(650, -62.42783, 2106.63867, 16.69071,   0.00000, 0.00000, 156.00000);
	CreateDynamicObject(651, -47.99610, 2096.15747, 16.38770,   0.00000, 0.00000, -11.00000);
	CreateDynamicObject(653, -68.83859, 2101.01538, 17.10993,   0.00000, 0.00000, -11.00000);
	CreateDynamicObject(759, -50.70755, 2107.51099, 15.67776,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11498, -78.25273, 2090.89722, 0.39227,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(337, -38.94688, 2110.28638, 17.05750,   -178.00000, 0.00000, 142.00000);
	CreateDynamicObject(692, -42.29800, 2105.21436, 16.54030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(692, -53.37349, 2100.93188, 16.54030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(692, -59.76593, 2097.70068, 17.34509,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(650, -71.99767, 2092.74097, 17.20081,   0.00000, 0.00000, 156.00000);
	CreateDynamicObject(692, -29.82761, 2108.29785, 16.40030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(692, -34.23590, 2106.16284, 16.40030,   0.00000, 0.00000, 40.00000);
	CreateDynamicObject(650, -34.80800, 2103.15698, 16.32780,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(692, -36.64080, 2105.90283, 16.40030,   0.00000, 0.00000, 91.00000);
	CreateDynamicObject(692, -39.42949, 2102.61499, 16.40030,   0.00000, 0.00000, 91.00000);
	CreateDynamicObject(692, -31.65921, 2104.86304, 16.40030,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(692, -36.39770, 2108.58130, 16.32030,   0.00000, 0.00000, 142.00000);
	CreateDynamicObject(769, -62.37600, 2090.10425, 15.61920,   0.00000, 0.00000, 91.00000);
	CreateDynamicObject(692, -37.14127, 2125.17480, 16.03020,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(692, -44.93501, 2124.41577, 16.03020,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(759, -33.52166, 2126.87866, 15.51776,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(692, -38.99440, 2119.85571, 16.07020,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(759, -39.37101, 2132.22144, 17.03991,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(692, -42.26844, 2134.87427, 17.88201,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1463, -33.84680, 2119.05127, 16.49850,   0.00000, 0.00000, 84.00000);
	CreateDynamicObject(650, -43.40957, 2128.38330, 16.18061,   0.00000, 0.00000, 42.03252);
	CreateDynamicObject(759, -40.31393, 2124.26465, 15.91286,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(692, -43.17040, 2119.89404, 16.07020,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11498, -43.01765, 2130.78711, 0.08926,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(759, -36.66336, 2137.95703, 18.05197,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(650, -33.91891, 2132.19360, 16.73081,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(692, -31.66951, 2124.45874, 16.07020,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(759, -30.28819, 2138.30640, 17.85302,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(11498, -30.18822, 2102.81226, 0.08926,   0.00000, 0.00000, 145.97995);
	CreateDynamicObject(3250, -27.23487, 2089.37988, 16.27973,   0.00000, 0.00000, 200.46004);
	CreateDynamicObject(3253, -51.47117, 2088.38208, 17.24091,   0.00000, 0.00000, 140.82002);
	CreateDynamicObject(769, -21.47690, 2103.00488, 15.61920,   0.00000, 0.00000, 91.00000);
	CreateDynamicObject(3356, -58.41419, 2094.97192, 20.99732,   -0.42000, -1.74000, 132.96002);
	CreateDynamicObject(759, -46.24768, 2090.13501, 16.59390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(653, -36.41179, 2122.73389, 17.10993,   0.00000, 0.00000, -11.00000);
	CreateDynamicObject(653, -24.23349, 2099.76489, 17.10993,   0.00000, 0.00000, -11.00000);

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////

	CreateDynamicObject(3243, -865.19879, -2179.18994, 25.60192,   -2.70000, -4.92000, 97.20000);
	CreateDynamicObject(824, -857.39996, -2184.92651, 24.57802,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14468, -869.62842, -2177.13184, 26.09367,   5.93999, 3.96000, -38.58000);
	CreateDynamicObject(825, -868.67828, -2191.29077, 28.82434,   -21.77999, 13.14001, 0.00000);
	CreateDynamicObject(832, -866.24701, -2183.44312, 27.01596,   0.00000, 0.00000, 199.25990);
	CreateDynamicObject(671, -863.64215, -2187.36401, 25.69446,   -16.32001, 3.06000, 0.00000);
	CreateDynamicObject(703, -856.34216, -2181.78613, 24.92250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19632, -871.73224, -2179.91553, 26.06465,   1.38000, 3.72000, 31.08000);
	CreateDynamicObject(847, -870.38928, -2179.60474, 24.21286,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(703, -869.15057, -2191.35010, 27.66917,   -18.36000, 8.75998, 0.00000);
	CreateDynamicObject(845, -873.75354, -2177.29126, 27.31009,   369.04379, 13.12354, -170.83815);
	CreateDynamicObject(19585, -871.86682, -2179.70825, 26.47380,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14872, -870.23798, -2182.26489, 26.06850,   0.00000, 0.00000, 97.79999);
	CreateDynamicObject(19793, -872.12579, -2179.85596, 26.11001,   0.00000, 0.00000, 72.30000);
	CreateDynamicObject(19793, -871.98608, -2180.20825, 26.08759,   0.00000, 0.00000, -22.38002);
	CreateDynamicObject(19793, -871.53583, -2180.11279, 26.08026,   0.00000, 0.00000, 39.05999);
	CreateDynamicObject(19793, -871.44293, -2179.73120, 26.09363,   0.00000, 0.00000, 131.45999);
	CreateDynamicObject(19793, -871.79584, -2179.75415, 26.20500,   0.00000, 0.00000, 32.33997);
	CreateDynamicObject(19793, -871.90936, -2180.11670, 26.20500,   0.00000, 0.00000, -19.44002);
	CreateDynamicObject(3929, -871.94995, -2179.61084, 25.74509,   0.00000, 0.00000, -66.60000);
	CreateDynamicObject(3929, -871.65771, -2180.24658, 25.70627,   0.00000, 0.00000, -66.60000);
	CreateDynamicObject(357, -869.78955, -2182.05420, 25.97040,   0.00000, -50.00000, -52.92000);
	CreateDynamicObject(19098, -871.18073, -2182.66602, 26.08484,   0.00000, 270.00000, -128.52005);

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////

	new txt_map;
	txt_map = CreateDynamicObject(3276, 549.0518, 2354.5424, 31.3616, 0.0000, 0.0000, -120.1000); //cxreffencesld
	txt_map = CreateDynamicObject(1517, 549.7424, 2355.5812, 32.1934, 0.0000, 0.0000, -36.8000); //DYN_WINE_BREAK
	txt_map = CreateDynamicObject(1517, 549.4848, 2355.2370, 32.1934, 0.0000, 0.0000, -28.6999); //DYN_WINE_BREAK
	txt_map = CreateDynamicObject(745, 558.7937, 2353.2270, 30.9359, 0.0000, 0.0000, 58.3999); //sm_scrub_rock5
	txt_map = CreateDynamicObject(1517, 549.0045, 2354.3220, 32.1934, 0.0000, 0.0000, -121.4999); //DYN_WINE_BREAK
	txt_map = CreateDynamicObject(1517, 549.2794, 2354.7250, 32.1934, 0.0000, 0.0000, 110.1999); //DYN_WINE_BREAK
	SetDynamicObjectMaterial(txt_map, 0, 1488, "dyn_objects", "CJ_bottle3", 0xFFFFFFFF);
	txt_map = CreateDynamicObject(1517, 548.6650, 2353.7675, 32.1934, 0.0000, 0.0000, -61.6999); //DYN_WINE_BREAK
	SetDynamicObjectMaterial(txt_map, 0, 1486, "break_bar", "CJ_bottle", 0xFFFFFFFF);
	txt_map = CreateDynamicObject(745, 553.7683, 2344.1804, 30.6659, 0.0000, 0.0000, 1.0999); //sm_scrub_rock5
	txt_map = CreateDynamicObject(822, 561.7046, 2344.9350, 32.5051, 0.0000, 0.0000, 0.0000); //genVEG_tallgrass06
	txt_map = CreateDynamicObject(653, 557.1284, 2347.2802, 30.0939, 0.0000, 0.0000, 126.2999); //sjmcacti03
	txt_map = CreateDynamicObject(19314, 554.3752, 2351.2631, 31.1761, 96.6999, 36.7999, -106.3000); //bullhorns01
	txt_map = CreateDynamicObject(19553, 548.2630, 2353.1269, 32.2685, 0.0000, -53.4000, 51.2999); //StrawHat1
	txt_map = CreateDynamicObject(1946, 554.4038, 2351.5000, 31.1052, -21.3000, 161.0000, -159.6999); //baskt_ball_hi
	SetDynamicObjectMaterial(txt_map, 0, 11469, "des_steakhouse", "des_bull", 0xFFFFFFFF);
	txt_map = CreateDynamicObject(3246, 578.3640, 2351.5241, 34.7815, 0.0000, 0.0000, -59.0000); //des_westrn7_
	txt_map = CreateDynamicObject(3246, 579.0006, 2318.6469, 32.9015, 0.0000, 0.0000, -148.0000); //des_westrn7_
	txt_map = CreateDynamicObject(618, 567.4046, 2357.2497, 33.2042, 0.0000, 0.0000, 0.0000); //veg_treea3
	txt_map = CreateDynamicObject(618, 577.3348, 2341.8791, 34.2042, 0.0000, 0.0000, 0.0000); //veg_treea3
	txt_map = CreateDynamicObject(618, 581.2750, 2333.0480, 32.4342, 0.0000, 0.0000, 0.0000); //veg_treea3
	txt_map = CreateDynamicObject(618, 567.0850, 2321.9680, 30.1142, 0.0000, 0.0000, 0.0000); //veg_treea3
	txt_map = CreateDynamicObject(3276, 578.4130, 2342.0290, 35.9816, 0.0000, 1.2000, -81.7000); //cxreffencesld
	txt_map = CreateDynamicObject(3276, 580.1639, 2329.7575, 35.6280, 0.0000, 3.5999, -84.5000); //cxreffencesld

	return true ;
}