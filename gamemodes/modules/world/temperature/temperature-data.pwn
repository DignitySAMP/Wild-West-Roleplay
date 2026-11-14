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
#define INVALID_TEMPERATURE (-65535)
#define TEMPERATURE_BANDS (6)
#define TEMPERATURE_BAND_NAME_LEN (36)
#define TEMPERATURE_DRIFT_MS (3600000)
#define TEMPERATURE_PLAYER_MS (120000)
#define TEMPERATURE_DIVIDER (6)
#define TEMPERATURE_NORMAL (98)
#define TEMPERATURE_NORMAL_DECIMAL (6)

enum e_TEMPERATURE_BAND
{
    E_BAND_NAME[TEMPERATURE_BAND_NAME_LEN],
    Float:E_BAND_MIN_X,
    Float:E_BAND_MIN_Y,
    Float:E_BAND_MAX_X,
    Float:E_BAND_MAX_Y,
    E_BAND_LOW,
    E_BAND_HIGH
}

static const s_TemperatureBands[TEMPERATURE_BANDS][e_TEMPERATURE_BAND] =
{
    {"Freezing Zone",-2978.5,2076.5,-2148.5,2997.5,-40,0},
    {"Cold Zone 1",-2148.5,2075.5,-1860.5,2997.5,1,54},
    {"Cold Zone 2",-1860.5,2832.5,-1502.5,2997.5,1,54},
    {"Warm Zone 1",-1860.5,456.5,455.5,2832.5,55,84},
    {"Warm Zone 2",-1502.5,2830.5,457.5,2997.5,55,84},
    {"Hot Zone",455.5,550.5,2995.0,2997.5,85,120}
};

static s_ZoneTemperature[ZONE_COUNT];
static s_TemperatureDriftDue;

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
stock Temperature_BandAt(Float:x,Float:y)
{
    for (new band = 0;band < TEMPERATURE_BANDS;band++)
    {
        if (x >= s_TemperatureBands[band][E_BAND_MIN_X] && x <= s_TemperatureBands[band][E_BAND_MAX_X] && y >= s_TemperatureBands[band][E_BAND_MIN_Y] && y <= s_TemperatureBands[band][E_BAND_MAX_Y])
        {
            return band;
        }
    }

    return -1;
}

stock Temperature_BandOfPlayer(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    return Temperature_BandAt(x,y);
}

stock bool:Temperature_GetBandRange(band,&low,&high)
{
    if (band < 0 || band >= TEMPERATURE_BANDS)
    {
        return false;
    }

    low = s_TemperatureBands[band][E_BAND_LOW];
    high = s_TemperatureBands[band][E_BAND_HIGH];
    return true;
}

stock Temperature_GetBandName(band,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (band >= 0 && band < TEMPERATURE_BANDS)
    {
        strcopy(dest,s_TemperatureBands[band][E_BAND_NAME],size);
    }
}

stock Temperature_GetZone(zone)
{
    if (zone < 0 || zone >= ZONE_COUNT)
    {
        return INVALID_TEMPERATURE;
    }

    return s_ZoneTemperature[zone];
}

stock Temperature_SetZone(zone,value)
{
    if (zone >= 0 && zone < ZONE_COUNT)
    {
        s_ZoneTemperature[zone] = value;
    }
}

stock Temperature_GetDriftDue()
{
    return s_TemperatureDriftDue;
}

stock Temperature_SetDriftDue(due)
{
    s_TemperatureDriftDue = due;
}

static Temperature_Between(low,high)
{
    return low + random(high - low + 1);
}

static Temperature_ZoneBand(zone)
{
    new Float:minx, Float:miny, Float:maxx, Float:maxy;

    if (!Zone_GetBounds(zone,minx,miny,maxx,maxy))
    {
        return -1;
    }

    return Temperature_BandAt((minx + maxx) / 2.0,(miny + maxy) / 2.0);
}

stock Temperature_Roll()
{
    for (new zone = 0;zone < ZONE_COUNT;zone++)
    {
        new band = Temperature_ZoneBand(zone), low, high;

        if (!Temperature_GetBandRange(band,low,high))
        {
            s_ZoneTemperature[zone] = INVALID_TEMPERATURE;
            continue;
        }

        s_ZoneTemperature[zone] = Temperature_Between(low,high);
    }
}

stock Temperature_Step(band,current)
{
    new low, high, modifier;

    if (!Temperature_GetBandRange(band,low,high))
    {
        return INVALID_TEMPERATURE;
    }

    if (band == 0)
    {
        modifier = Temperature_Between(0,-low) / TEMPERATURE_DIVIDER;
    }
    else
    {
        modifier = Temperature_Between(low,high) / TEMPERATURE_DIVIDER;
    }

    if (current + modifier > high)
    {
        return current - modifier;
    }

    return current + modifier;
}

stock Temperature_Drift()
{
    for (new zone = 0;zone < ZONE_COUNT;zone++)
    {
        if (s_ZoneTemperature[zone] == INVALID_TEMPERATURE)
        {
            continue;
        }

        s_ZoneTemperature[zone] = Temperature_Step(Temperature_ZoneBand(zone),s_ZoneTemperature[zone]);
    }
}
