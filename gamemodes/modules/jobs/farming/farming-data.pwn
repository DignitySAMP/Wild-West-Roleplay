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
#define SOIL_RANGE (4.0)
#define SOIL_STAFF_RANGE (3.0)
#define SOIL_OWN_RANGE (6.0)
#define SOIL_TICK_MS (600000)
#define SOIL_TICKS_TO_GROW (5)
#define SOIL_DEAD_MS (180000)
#define SOIL_MODEL (854)
#define SOIL_NONE (-1)
#define SOIL_LABEL_COLOUR (0xA9C248FF)
#define SOIL_PLANT_NONE (-1)
#define SOIL_PLANT_COUNT (7)
#define SOIL_TICKER_MS (1000)

enum _:E_SOIL_STATES
{
    SOIL_STATE_EMPTY = 0,
    SOIL_STATE_DIGGED,
    SOIL_STATE_SEEDED,
    SOIL_STATE_GROWING,
    SOIL_STATE_GROWN
}

enum _:E_SOIL_HEALTHS
{
    SOIL_HEALTH_DEAD = 0,
    SOIL_HEALTH_DISEASED,
    SOIL_HEALTH_THIRSTY,
    SOIL_HEALTH_HEALTHY
}

enum _:E_SOIL_WATERS
{
    SOIL_WATER_DEHYDRATED = 0,
    SOIL_WATER_MODERATE,
    SOIL_WATER_WATERED
}

enum _:E_PLANT
{
    PLANT_ORANGE = 0,
    PLANT_APPLE_RED,
    PLANT_APPLE_GREEN,
    PLANT_PUMPKIN,
    PLANT_WHEAT,
    PLANT_TOMATO,
    PLANT_CABBAGE
}

enum e_SOIL
{
    E_SOIL_OWNER,
    E_SOIL_PLANT,
    Float:E_SOIL_X,
    Float:E_SOIL_Y,
    Float:E_SOIL_Z,
    Float:E_SOIL_RX,
    Float:E_SOIL_RY,
    Float:E_SOIL_RZ,
    E_SOIL_WATER,
    E_SOIL_HEALTH,
    E_SOIL_STATE,
    E_SOIL_OBJECT,
    E_SOIL_LABEL,
    E_SOIL_TICKS,
    bool:E_SOIL_FINISHED,
    E_SOIL_TICK_DUE,
    E_SOIL_DEAD_DUE,
    bool:E_SOIL_LIFTED
}

new Map:g_Soils;
new g_SoilPending[MAX_PLAYERS][e_SOIL];

forward Farming_OnInserted(playerid,token);
forward Farming_OnOwner(playerid,id);
forward Farming_OnAllOwners(playerid,id);
forward Farming_OnPlanted(playerid,id,plant);
forward Farming_OnHarvested(playerid,id,plant);
forward Farming_OnWatered(playerid,id);

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
stock Soil_Count()
{
    return map_valid(g_Soils) ? map_size(g_Soils) : 0;
}

stock bool:Soil_Get(id,soil[e_SOIL])
{
    if (!map_valid(g_Soils) || !map_has_key(g_Soils,id))
    {
        return false;
    }

    map_get_arr(g_Soils,id,soil);
    return true;
}

stock Soil_Put(id,const soil[e_SOIL])
{
    map_set_arr(g_Soils,id,soil);
}

stock Soil_PlantName(plant,bool:coloured,dest[],size = sizeof(dest))
{
    switch (plant)
    {
        case PLANT_ORANGE:
        {
            strcopy(dest,coloured ? ("{F2921B}Orange{DEDEDE}") : ("orange"),size);
        }
        case PLANT_APPLE_RED:
        {
            strcopy(dest,coloured ? ("{F6625A}Red Apple{DEDEDE}") : ("red apple"),size);
        }
        case PLANT_APPLE_GREEN:
        {
            strcopy(dest,coloured ? ("{3DF678}Green Apple{DEDEDE}") : ("green apple"),size);
        }
        case PLANT_PUMPKIN:
        {
            strcopy(dest,coloured ? ("{F2921B}Pumpkin{DEDEDE}") : ("pumpkin"),size);
        }
        case PLANT_TOMATO:
        {
            strcopy(dest,coloured ? ("{F6625A}Tomato{DEDEDE}") : ("tomato"),size);
        }
        case PLANT_CABBAGE:
        {
            strcopy(dest,coloured ? ("{3DF678}Cabbage{DEDEDE}") : ("cabbage"),size);
        }
        case PLANT_WHEAT:
        {
            strcopy(dest,coloured ? ("{968354}Wheat{DEDEDE}") : ("wheat"),size);
        }
        default:
        {
            dest[0] = EOS;
        }
    }
}

stock Soil_PlantFromSeed(extra)
{
    switch (extra)
    {
        case E_ITEM_EXTRA_SEED_ORANGE: return PLANT_ORANGE;
        case E_ITEM_EXTRA_SEED_APPLE_RED: return PLANT_APPLE_RED;
        case E_ITEM_EXTRA_SEED_APPLE_GREEN: return PLANT_APPLE_GREEN;
        case E_ITEM_EXTRA_SEED_TOMATO: return PLANT_TOMATO;
        case E_ITEM_EXTRA_SEED_CABBAGE: return PLANT_CABBAGE;
        case E_ITEM_EXTRA_SEED_PUMPKIN: return PLANT_PUMPKIN;
        case E_ITEM_EXTRA_SEED_WHEAT: return PLANT_WHEAT;
    }

    return SOIL_PLANT_NONE;
}

stock Soil_BasketFor(plant)
{
    switch (plant)
    {
        case PLANT_ORANGE: return E_ITEM_EXTRA_ORANGE_BASKET;
        case PLANT_APPLE_RED: return E_ITEM_EXTRA_RAPPLE_BASKET;
        case PLANT_APPLE_GREEN: return E_ITEM_EXTRA_GAPPLE_BASKET;
        case PLANT_TOMATO: return E_ITEM_EXTRA_TOMATO_BASKET;
        case PLANT_CABBAGE: return E_ITEM_EXTRA_CABBAGE_BASKET;
        case PLANT_WHEAT: return E_ITEM_EXTRA_WHEAT_BASKET;
        case PLANT_PUMPKIN: return E_ITEM_EXTRA_PUMPKIN_BASKET;
    }

    return -1;
}

static Soil_Text(const soil[e_SOIL],dest[],size = sizeof(dest))
{
    new water[32], health[64], status[32], plant[32];

    switch (soil[E_SOIL_WATER])
    {
        case SOIL_WATER_DEHYDRATED: strcopy(water,"{968354}Dehydrated{DEDEDE}");
        case SOIL_WATER_MODERATE: strcopy(water,"{8ED1CE}Moderate{DEDEDE}");
        default: strcopy(water,"{5EABCC}Watered{DEDEDE}");
    }

    switch (soil[E_SOIL_HEALTH])
    {
        case SOIL_HEALTH_DEAD: strcopy(health,"{363636}This plant is dead!{DEDEDE}");
        case SOIL_HEALTH_DISEASED: strcopy(health,"{807455}Diseased{DEDEDE}");
        case SOIL_HEALTH_THIRSTY: strcopy(health,"{968354}Thirsty{DEDEDE}");
        default: strcopy(health,"{45963B}Healthy{DEDEDE}");
    }

    Soil_PlantName(soil[E_SOIL_PLANT],true,plant);

    switch (soil[E_SOIL_STATE])
    {
        case SOIL_STATE_EMPTY:
        {
            strcopy(status,"{C95353}Empty{DEDEDE}");
            format(dest,size,"[Farming Soil]{DEDEDE}\n\nSoil State: %s\n\nUse your spade to make a hole.",status);
        }
        case SOIL_STATE_DIGGED:
        {
            strcopy(status,"{59C953}Digged{DEDEDE}");
            format(dest,size,"[Farming Soil]{DEDEDE}\n\nSoil State: %s\n\nPlant a seed!",status);
        }
        case SOIL_STATE_SEEDED:
        {
            strcopy(status,"{59C953}Seeded{DEDEDE}");
            format(dest,size,"[Farming Soil]{DEDEDE}\n\nSoil State: %s\n\nPlant: %s\n\nFill the hole up to start growing!",status,plant);
        }
        case SOIL_STATE_GROWING:
        {
            strcopy(status,"{59C953}Growing{DEDEDE}");

            if (soil[E_SOIL_HEALTH] == SOIL_HEALTH_DEAD)
            {
                format(dest,size,"[Farming Soil]{DEDEDE}\n\nHealth: %s",health);
            }
            else
            {
                format(dest,size,"[Farming Soil]{DEDEDE}\n\nSoil State: %s\n\nPlant: %s\n\nHealth: %s\n\nWater: %s",status,plant,health,water);
            }
        }
        default:
        {
            strcopy(status,"{59C953}Grown{DEDEDE}");
            format(dest,size,"[Farming Soil]{DEDEDE}\n\nSoil State: %s\n\nThis plant is ready to be collected.",status);
        }
    }
}

stock Soil_Save(id)
{
    new soil[e_SOIL];

    if (!Soil_Get(id,soil))
    {
        return;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE soildata SET soil_state = %d, soil_plant = %d, soil_water = %d, soil_health = %d, soil_z = %f, s_ticks = %d, finished_growing = %d WHERE soil_id = %d",soil[E_SOIL_STATE],soil[E_SOIL_PLANT],soil[E_SOIL_WATER],soil[E_SOIL_HEALTH],soil[E_SOIL_Z],soil[E_SOIL_TICKS],soil[E_SOIL_FINISHED] ? 1 : 0,id));
}

stock Soil_Refresh(id)
{
    new soil[e_SOIL], text[256];

    if (!Soil_Get(id,soil))
    {
        return;
    }

    Soil_Text(soil,text);
    UpdateDynamic3DTextLabelText(STREAMER_TAG_3D_TEXT_LABEL:soil[E_SOIL_LABEL],SOIL_LABEL_COLOUR,text);
    Soil_Save(id);
}

static Soil_Build(soil[e_SOIL])
{
    new text[256];
    soil[E_SOIL_OBJECT] = _:CreateDynamicObject(SOIL_MODEL,soil[E_SOIL_X],soil[E_SOIL_Y],soil[E_SOIL_Z],0.0,0.0,float(random(90)),0,0);
    SetDynamicObjectMaterial(STREAMER_TAG_OBJECT:soil[E_SOIL_OBJECT],0,16093,"a51_ext","des_dirt1",0xFFFFFFFF);
    Soil_Text(soil,text);
    soil[E_SOIL_LABEL] = _:CreateDynamic3DTextLabel(text,SOIL_LABEL_COLOUR,soil[E_SOIL_X],soil[E_SOIL_Y],soil[E_SOIL_Z],7.0);
}

stock Soil_Register(id,soil[e_SOIL])
{
    if (!map_valid(g_Soils))
    {
        g_Soils = map_new();
    }

    Soil_Build(soil);
    map_set_arr(g_Soils,id,soil);
}

stock Soil_Rebuild(id)
{
    new soil[e_SOIL];

    if (!Soil_Get(id,soil))
    {
        return;
    }

    DestroyDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:soil[E_SOIL_LABEL]);
    DestroyDynamicObject(STREAMER_TAG_OBJECT:soil[E_SOIL_OBJECT]);
    Soil_Build(soil);
    Soil_Put(id,soil);
    Soil_Save(id);
}

stock Soil_ResetToHole(id)
{
    new soil[e_SOIL];

    if (!Soil_Get(id,soil))
    {
        return false;
    }

    soil[E_SOIL_STATE] = SOIL_STATE_DIGGED;
    soil[E_SOIL_PLANT] = SOIL_PLANT_NONE;
    soil[E_SOIL_WATER] = SOIL_WATER_DEHYDRATED;
    soil[E_SOIL_HEALTH] = SOIL_HEALTH_DEAD;
    soil[E_SOIL_TICKS] = 0;
    soil[E_SOIL_FINISHED] = false;
    soil[E_SOIL_TICK_DUE] = 0;
    soil[E_SOIL_DEAD_DUE] = 0;
    Soil_Put(id,soil);
    Soil_Refresh(id);
    return true;
}

stock Soil_Remove(id)
{
    new soil[e_SOIL];

    if (!Soil_Get(id,soil))
    {
        return false;
    }

    mysql_tquery_s(g_Mysql,str_format("DELETE FROM soildata WHERE soil_id = %d",id));
    DestroyDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:soil[E_SOIL_LABEL]);
    DestroyDynamicObject(STREAMER_TAG_OBJECT:soil[E_SOIL_OBJECT]);
    map_remove(g_Soils,id);
    return true;
}

stock Soil_RemoveAll()
{
    new ids[512], count = 0;

    if (!map_valid(g_Soils))
    {
        return 0;
    }

    for (new Iter:it = map_iter(g_Soils);iter_inside(it) && count < sizeof(ids);iter_move_next(it))
    {
        ids[count++] = iter_get_key(it);
    }

    for (new i = 0;i < count;i++)
    {
        Soil_Remove(ids[i]);
    }

    return count;
}

stock Soil_FindNear(playerid,Float:range,owner = -1)
{
    new best = SOIL_NONE, Float:bestDistance = range * range, Float:px, Float:py, Float:pz;

    if (!map_valid(g_Soils))
    {
        return SOIL_NONE;
    }

    GetPlayerPos(playerid,px,py,pz);

    for (new Iter:it = map_iter(g_Soils);iter_inside(it);iter_move_next(it))
    {
        new soil[e_SOIL];
        iter_get_arr(it,soil);

        if (owner != -1 && soil[E_SOIL_OWNER] != owner)
        {
            continue;
        }

        new Float:dx = soil[E_SOIL_X] - px, Float:dy = soil[E_SOIL_Y] - py, Float:dz = soil[E_SOIL_Z] - pz, Float:distance = (dx * dx) + (dy * dy) + (dz * dz);

        if (distance <= bestDistance)
        {
            bestDistance = distance;
            best = iter_get_key(it);
        }
    }

    return best;
}

stock Soil_StartGrowing(id)
{
    new soil[e_SOIL];

    if (!Soil_Get(id,soil) || soil[E_SOIL_FINISHED])
    {
        return;
    }

    soil[E_SOIL_STATE] = SOIL_STATE_GROWING;
    soil[E_SOIL_WATER] = SOIL_WATER_MODERATE;
    soil[E_SOIL_HEALTH] = SOIL_HEALTH_THIRSTY;
    soil[E_SOIL_TICK_DUE] = GetTickCount() + SOIL_TICK_MS;

    if (soil[E_SOIL_TICK_DUE] == 0)
    {
        soil[E_SOIL_TICK_DUE] = 1;
    }

    Soil_Put(id,soil);
    Soil_Refresh(id);
}

stock Farming_Tick()
{
    if (!map_valid(g_Soils))
    {
        return;
    }

    new now = GetTickCount(), ids[128], count = 0;

    for (new Iter:it = map_iter(g_Soils);iter_inside(it) && count < sizeof(ids);iter_move_next(it))
    {
        new soil[e_SOIL];
        iter_get_arr(it,soil);

        if ((soil[E_SOIL_DEAD_DUE] != 0 && now - soil[E_SOIL_DEAD_DUE] >= 0) || (soil[E_SOIL_TICK_DUE] != 0 && now - soil[E_SOIL_TICK_DUE] >= 0))
        {
            ids[count++] = iter_get_key(it);
        }
    }

    for (new i = 0;i < count;i++)
    {
        new soil[e_SOIL];

        if (!Soil_Get(ids[i],soil))
        {
            continue;
        }

        if (soil[E_SOIL_DEAD_DUE] != 0 && now - soil[E_SOIL_DEAD_DUE] >= 0)
        {
            Soil_Remove(ids[i]);
            continue;
        }

        soil[E_SOIL_TICK_DUE] = 0;

        if (soil[E_SOIL_HEALTH] == SOIL_HEALTH_DEAD || soil[E_SOIL_FINISHED] || soil[E_SOIL_STATE] != SOIL_STATE_GROWING)
        {
            Soil_Put(ids[i],soil);
            continue;
        }

        soil[E_SOIL_TICKS]++;

        if (soil[E_SOIL_TICKS] >= SOIL_TICKS_TO_GROW)
        {
            soil[E_SOIL_STATE] = SOIL_STATE_GROWN;
            soil[E_SOIL_FINISHED] = true;
            Soil_Put(ids[i],soil);
            Soil_Refresh(ids[i]);
            continue;
        }

        switch (soil[E_SOIL_WATER])
        {
            case SOIL_WATER_DEHYDRATED:
            {
                soil[E_SOIL_HEALTH] = SOIL_HEALTH_DEAD;
                soil[E_SOIL_DEAD_DUE] = now + SOIL_DEAD_MS;

                if (soil[E_SOIL_DEAD_DUE] == 0)
                {
                    soil[E_SOIL_DEAD_DUE] = 1;
                }
            }
            case SOIL_WATER_MODERATE:
            {
                soil[E_SOIL_WATER] = SOIL_WATER_DEHYDRATED;
                soil[E_SOIL_HEALTH] = SOIL_HEALTH_THIRSTY;
            }
            default:
            {
                soil[E_SOIL_WATER] = SOIL_WATER_MODERATE;
                soil[E_SOIL_HEALTH] = SOIL_HEALTH_HEALTHY;
            }
        }

        if (soil[E_SOIL_HEALTH] != SOIL_HEALTH_DEAD)
        {
            soil[E_SOIL_TICK_DUE] = now + SOIL_TICK_MS;

            if (soil[E_SOIL_TICK_DUE] == 0)
            {
                soil[E_SOIL_TICK_DUE] = 1;
            }
        }

        Soil_Put(ids[i],soil);
        Soil_Refresh(ids[i]);
    }
}

