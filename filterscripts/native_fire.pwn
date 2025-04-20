#include <a_samp>
#include <sscanf2>
#include <streamer>
#include <zcmd>

public OnFilterScriptInit() {

	// Native tent
	CreateDynamicObject(18689, -1530.7919, 2768.8210, 87.6167 - 1, 0, 0, 0); // fire_1
	CreateDynamicObject(18689, -1533.1217, 2773.1992, 85.5706 - 1, 0, 0, 0); // fire_1
	CreateDynamicObject(18689, -1534.6846, 2777.6665, 88.6542 - 1, 0, 0, 0); // fire_1
	CreateDynamicObject(18689, -1532.7855, 2781.2007, 86.4752 - 1, 0, 0, 0); // fire_1
	CreateDynamicObject(18689, -1531.6437, 2783.8721, 85.8458 - 1, 0, 0, 0); // fire_1
	CreateDynamicObject(18689, -1527.1379, 2779.5859, 87.5522 - 1, 0, 0, 0); // fire_1
	CreateDynamicObject(18689, -1523.9976, 2778.2141, 88.4363 - 1, 0, 0, 0); // fire_1
	CreateDynamicObject(18689, -1520.2545, 2770.5205, 83.6339 - 1, 0, 0, 0); // fire_1
	CreateDynamicObject(18689, -1525.7302, 2764.9529, 84.2483 - 1, 0, 0, 0); // fire_1

	CreateDynamic3DTextLabel("(( This camp has been ravaged. The tents display bulletholes, blood splatters and burnt corpses. ))", 0xD0AEEBFF, -1522.5647,2769.5273,83.4802, 10.0,  INVALID_PLAYER_ID,  INVALID_VEHICLE_ID, 0 );

	// Smoke after attack 13/04/19

	CreateDynamicObject(18726, -1438.6127, 2635.2998, 61.9968 - 1, 0, 0, 0); // smoke_1
	CreateDynamicObject(18726, -1457.1202, 2635.8174, 62.2765 - 1, 0, 0, 0); // smoke_1
	CreateDynamicObject(18726, -1470.8802, 2634.9214, 64.6898 - 1, 0, 0, 0); // smoke_1
	CreateDynamicObject(18726, -1462.4788, 2616.1873, 60.3669 - 1, 0, 0, 0); // smoke_1
	CreateDynamicObject(18726, -1439.9329, 2612.1116, 65.4386 - 1, 0, 0, 0); // smoke_1
	CreateDynamicObject(18726, -1412.3149, 2607.8564, 59.5893 - 1, 0, 0, 0); // smoke_1
	CreateDynamicObject(18726, -1390.4155, 2603.3967, 62.1727 - 1, 0, 0, 0); // smoke_1
	CreateDynamicObject(18726, -1487.2545, 2616.0034, 58.8953 - 1, 0, 0, 0); // smoke_1
	CreateDynamicObject(18726, -1521.0763, 2637.8123, 61.1695 - 1, 0, 0, 0); // smoke_1
	CreateDynamicObject(18726, -1490.5321, 2663.1709, 61.1954 - 1, 0, 0, 0); // smoke_1
	CreateDynamicObject(18726, -1514.4717, 2671.7478, 61.6611 - 1, 0, 0, 0); // smoke_1
	CreateDynamicObject(18726, -1519.1272, 2655.0427, 59.0897 - 1, 0, 0, 0); // smoke_1



	return true ;
}