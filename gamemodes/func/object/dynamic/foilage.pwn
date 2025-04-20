#define FILE_DESERT	 	"scriptfiles/desert.bmp"
#define FILE_ENTITIES 	"scriptfiles/entities.bmp"

enum {
	DESERT,
	TREES
}

static obj_arr_DESERT[] = {
	647, 	861,	862,	864,	806,	756,	757,	863,	859,	860,	865,	866,	904,
	858,	19837,	19838,	19839,	747, 650
} ;

static VirtualCanvas:vc, res_x, res_y;

Foilage_Init () {
	
	InitiateFileLoading ( FILE_DESERT ) ;
	InitiateFileLoading ( FILE_ENTITIES ) ;

	printf("* [ENTITIES]: Loaded %d rocks and %d trees\n", rockCount, treeCount ) ;

	return true ;
}

InitiateFileLoading ( filename[] ) {

	FImageOpen(filename);
	res_x = GetImageWidth(filename);
	res_y = GetImageHeight(filename);

	vc = CreateVirtualCanvas(-3000, 3000, 3000.0, -3000.0, res_x, res_y);

	printf("\n * [FOILAGE]: Processing pixel loop from bitmap image \"%s\".", filename);

	_ProcessBitmapLoop();
	printf(" * [FOILAGE]: Processed pixel loop from bitmap image \"%s\".\n", filename);

	return true ;
}

_ProcessBitmapLoop() {
	for ( new i; i < res_x; i++ ) {
		for ( new j; j < res_y; j++ ) {
			_ProcessPixel ( i, j ) ;
		}
	}
}

#define COLOUR_DESERT       (0xC2A97AFF)
#define COLOUR_ENTITIES		(0xc54fabFF)

_ProcessPixel(pix_x, pix_y) {
	new Float:pos_x, Float:pos_y, Float:pos_z,
		pix_r, pix_g, pix_b, rgba;

	pix_r = FGetImageRAtPos(pix_x, pix_y);
	pix_g = FGetImageGAtPos(pix_x, pix_y);
	pix_b = FGetImageBAtPos(pix_x, pix_y);
	rgba = (pix_r<<24 | pix_g<<16 | pix_b<<8 | 0xFF);

	// If the pixel is white, skip.
	if(rgba == 0xFFFFFFFF)
		return 0;

	GetVirtualCanvasPos(vc, pix_x, pix_y, pos_x, pos_y);

	// If out the world bounds, skip (causes a ColAndreas crash)
	if(!(-2990.0 < pos_x < 2990.0) || !(-2990.0 < pos_y < 2990.0))
		return 0;

	CA_FindZ_For2DCoord(pos_x, pos_y, pos_z);

	if(rgba == COLOUR_DESERT)  {
		if ( random ( 250 ) < 15 ) {

			_CreateFoliage(pos_x, pos_y, pos_z);
		}
	}

	if(rgba == COLOUR_ENTITIES)  {
		if ( random ( 180 ) < 4 ) {

			CreateTree ( pos_x, pos_y, pos_z ) ;
		}

		if ( random ( 200 ) < 3 ) {

			CreateRock ( pos_x , pos_y, pos_z ) ;
		}
	}

	return 1;
}

_CreateFoliage(Float:pos_x, Float:pos_y, Float:pos_z) {
	new model = obj_arr_DESERT[random(sizeof(obj_arr_DESERT))];

	new Float: new_x, Float: new_y, Float: new_z, Float: rot_x, Float: rot_y, Float: rot_z;

	//CA_FindZ_For2DCoord(pos_x, pos_y, pos_z); 
	CA_RayCastLineAngle(pos_x, pos_y, pos_z + 5.0, 	pos_x, pos_y, pos_x - 5.0, 		new_x, new_y, new_z, rot_x, rot_y, rot_z);
	CreateDynamicObject(model, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, -1, -1, -1, 75, 75); //1000
}