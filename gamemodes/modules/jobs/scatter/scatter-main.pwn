/**
 *           __             __
 *          |  \           |  |
 *      ____| $$  ______  _| $$_     ______
 *     /      $$ |      \|   $$ \   |      |
 *    |  $$$$$$$  \$$$$$$\\$$$$$$    \$$$$$$|
 *    | $$  | $$ /      $$ | $$ __  /      $$
 *    | $$__| $$|  $$$$$$$ | $$|  \|  $$$$$$$
 *     \$$    $$ \$$    $$  \$$  $$ \$$    $$
 *      \$$$$$$$  \$$$$$$$   \$$$$   \$$$$$$$
 *
 */
#define SCATTER_DESERT_FILE "desert.bmp"
#define SCATTER_ENTITY_FILE "entities.bmp"
#define SCATTER_COLOUR_DESERT (0xC2A97A)
#define SCATTER_COLOUR_ENTITY (0xC54FAB)
#define SCATTER_COLOUR_WHITE (0xFFFFFF)
#define SCATTER_CANVAS (3000.0)
#define SCATTER_LIMIT (2990.0)
#define SCATTER_ROW_CELLS (2048)
#define SCATTER_HEADER_CELLS (14)
#define SCATTER_PLANT_COUNT (19)
#define SCATTER_MAX_TILT (45.0)

new const g_ScatterPlants[SCATTER_PLANT_COUNT] =
{
    647,861,862,864,806,756,757,863,859,860,865,866,904,858,19837,19838,19839,747,650
};

new g_ScatterPlantsPlaced;
new g_ScatterTreesPlaced;
new g_ScatterRocksPlaced;

/**
 *      ______                                   __      __
 *     /      \                                 |  \    |  |
 *    |  $$$$$$\ __    __  _______    _______  _| $$_    \$$  ______   _______    _______
 *    | $$_  \$$|  \  |  \|       \  /       \|   $$ \  |  \ /      \ |       \  /       |
 *    | $$ \    | $$  | $$| $$$$$$$\|  $$$$$$$ \$$$$$$  | $$|  $$$$$$\| $$$$$$$\|  $$$$$$$
 *    | $$$$    | $$  | $$| $$  | $$| $$        | $$ __ | $$| $$  | $$| $$  | $$ \$$    |
 *    | $$      | $$__/ $$| $$  | $$| $$_____   | $$|  \| $$| $$__/ $$| $$  | $$ _\$$$$$$|
 *    | $$       \$$    $$| $$  | $$ \$$     \   \$$  $$| $$ \$$    $$| $$  | $$|       $$
 *     \$$        \$$$$$$  \$$   \$$  \$$$$$$$    \$$$$  \$$  \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
static Scatter_Byte(const cells[],index)
{
    return (cells[index / 4] >>> ((index % 4) * 8)) & 0xFF;
}

stock Scatter_PixelToWorld(pixelX,pixelY,width,height,&Float:x,&Float:y)
{
    x = -SCATTER_CANVAS + ((SCATTER_CANVAS * 2.0) / float(width)) * float(pixelX);
    y = SCATTER_CANVAS - ((SCATTER_CANVAS * 2.0) / float(height)) * float(pixelY);
}

stock Scatter_WorldToPixel(Float:x,Float:y,width,height,&pixelX,&pixelY)
{
    pixelX = floatround(((x + SCATTER_CANVAS) * float(width)) / (SCATTER_CANVAS * 2.0),floatround_floor);
    pixelY = floatround(((SCATTER_CANVAS - y) * float(height)) / (SCATTER_CANVAS * 2.0),floatround_floor);
}

stock bool:Scatter_Header(File:handle,&width,&height,&offset)
{
    new cells[SCATTER_HEADER_CELLS];

    if (fblockread(handle,cells,SCATTER_HEADER_CELLS) != SCATTER_HEADER_CELLS)
    {
        return false;
    }

    if (Scatter_Byte(cells,0) != 'B' || Scatter_Byte(cells,1) != 'M' || Scatter_Byte(cells,28) != 24)
    {
        return false;
    }

    offset = Scatter_Byte(cells,10) | (Scatter_Byte(cells,11) << 8) | (Scatter_Byte(cells,12) << 16) | (Scatter_Byte(cells,13) << 24);
    width = Scatter_Byte(cells,18) | (Scatter_Byte(cells,19) << 8) | (Scatter_Byte(cells,20) << 16) | (Scatter_Byte(cells,21) << 24);
    height = Scatter_Byte(cells,22) | (Scatter_Byte(cells,23) << 8) | (Scatter_Byte(cells,24) << 16) | (Scatter_Byte(cells,25) << 24);
    return width > 0 && height > 0 && width * 3 <= SCATTER_ROW_CELLS * 4 && (width * 3) % 4 == 0;
}

stock Scatter_Pixel(const file[],pixelX,pixelY)
{
    new File:handle = fopen(file,io_read), width, height, offset, colour = -1;

    if (!handle)
    {
        return -1;
    }

    if (Scatter_Header(handle,width,height,offset) && pixelX >= 0 && pixelX < width && pixelY >= 0 && pixelY < height)
    {
        new row = height - 1 - pixelY;
        fseek(handle,offset + (row * width * 3) + (pixelX * 3),seek_start);
        new blue = fgetchar(handle,false), green = fgetchar(handle,false), red = fgetchar(handle,false);
        colour = (red << 16) | (green << 8) | blue;
    }

    fclose(handle);
    return colour;
}

static Scatter_Plant(Float:x,Float:y,Float:z)
{
    new model = g_ScatterPlants[random(SCATTER_PLANT_COUNT)], Float:nx, Float:ny, Float:nz, Float:rx, Float:ry, Float:rz;
    new hit = CA_RayCastLineAngle(x,y,z + 5.0,x,y,z - 5.0,nx,ny,nz,rx,ry,rz);

    if (!hit || rx != rx || ry != ry || rz != rz || floatabs(rx) > SCATTER_MAX_TILT || floatabs(ry) > SCATTER_MAX_TILT)
    {
        rx = 0.0;
        ry = 0.0;
        rz = 0.0;
    }

    CreateDynamicObject(model,x,y,z,rx,ry,rz,0,0,-1,75.0,75.0);
    g_ScatterPlantsPlaced++;
}

static Scatter_Cell(const file[])
{
    new File:handle = fopen(file,io_read), width, height, offset;

    if (!handle)
    {
        Log_Info("jobs","Scatter could not open %s.",file);
        return;
    }

    if (!Scatter_Header(handle,width,height,offset))
    {
        Log_Info("jobs","Scatter could not read the header of %s.",file);
        fclose(handle);
        return;
    }

    new cells[SCATTER_ROW_CELLS], stride = width * 3 / 4;
    fseek(handle,offset,seek_start);

    for (new row = 0;row < height;row++)
    {
        if (fblockread(handle,cells,stride) != stride)
        {
            break;
        }

        new pixelY = height - 1 - row;

        for (new group = 0;group < width / 4;group++)
        {
            new c0 = cells[group * 3], c1 = cells[(group * 3) + 1], c2 = cells[(group * 3) + 2];

            if ((c0 & c1 & c2) == -1)
            {
                continue;
            }

            for (new part = 0;part < 4;part++)
            {
                new pixelX = (group * 4) + part, index = pixelX * 3;
                new colour = (Scatter_Byte(cells,index + 2) << 16) | (Scatter_Byte(cells,index + 1) << 8) | Scatter_Byte(cells,index);

                if (colour == SCATTER_COLOUR_WHITE)
                {
                    continue;
                }

                new bool:desert = colour == SCATTER_COLOUR_DESERT, bool:entity = colour == SCATTER_COLOUR_ENTITY;

                if (!desert && !entity)
                {
                    continue;
                }

                new bool:plant = false, bool:tree = false, bool:rock = false;

                if (desert)
                {
                    plant = random(250) < 15;
                }

                if (entity)
                {
                    tree = random(180) < 4;
                    rock = random(200) < 3;
                }

                if (!plant && !tree && !rock)
                {
                    continue;
                }

                new Float:x, Float:y, Float:z = 0.0;
                Scatter_PixelToWorld(pixelX,pixelY,width,height,x,y);

                if (!(-SCATTER_LIMIT < x < SCATTER_LIMIT) || !(-SCATTER_LIMIT < y < SCATTER_LIMIT))
                {
                    continue;
                }

                CA_FindZ_For2DCoord(x,y,z);

                if (plant)
                {
                    Scatter_Plant(x,y,z);
                }

                if (tree)
                {
                    Tree_Create(x,y,z);
                    g_ScatterTreesPlaced++;
                }

                if (rock)
                {
                    Rock_Create(x,y,z,true);
                    g_ScatterRocksPlaced++;
                }
            }
        }
    }

    fclose(handle);
}

stock Scatter_Init()
{
    Scatter_Cell(SCATTER_DESERT_FILE);
    Scatter_Cell(SCATTER_ENTITY_FILE);
    Log_Info("jobs","Scatter placed %d plants, %d rocks and %d trees.",g_ScatterPlantsPlaced,g_ScatterRocksPlaced,g_ScatterTreesPlaced);
}

stock Scatter_GetPlants()
{
    return g_ScatterPlantsPlaced;
}

stock Scatter_GetTrees()
{
    return g_ScatterTreesPlaced;
}

stock Scatter_GetRocks()
{
    return g_ScatterRocksPlaced;
}
