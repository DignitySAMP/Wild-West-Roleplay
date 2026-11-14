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
#define MAP_FILE_COUNT (14)
#define MAP_FILE_NAME_LEN (32)
#define MAP_PATH_FORMAT "maps/%s"
#define MAP_STREAM_DISTANCE (850.0)
#define MAP_LINE_LEN (1024)
#define MAP_TOKENS (20)
#define MAP_TOKEN_LEN (192)
#define MAP_PREFIX_LEN (64)

enum e_MAP_FILE
{
    E_MAP_FILE_OBJECTS,
    E_MAP_FILE_MATERIALS,
    E_MAP_FILE_GATES,
    E_MAP_FILE_SKIPPED,
    E_MAP_FILE_CHANGING,
    E_MAP_FILE_LOADED
}

static const s_MapChangingModels[] =
{
    1490,1524,1525,1526,1527,1528,1529,1530,1531,1657,1658,1659,
    1661,2873,2874,2875,2876,2877,2878,2879,3120,3121,3122,3123,
    3124,3125,3126,3127,3128,3129,3130,3131,3132,3133,3425,3426,
    3427,3428,3872,4212,4213,4214,4215,4216,4217,4218,4219,4220,
    4221,4222,4715,4716,4717,4723,4725,4739,4740,4741,4742,4743,
    4744,4745,4746,4747,4748,4749,4750,4751,4752,5057,5058,5059,
    5465,5661,5662,5665,5776,5786,5791,5872,5876,5990,5991,5992,
    6001,6010,6192,6193,6194,6195,6196,6257,6412,6518,6519,6520,
    6521,7071,7072,7097,7182,7183,7206,7207,7208,7220,7221,7222,
    7226,7230,7263,7264,7265,7266,7268,7274,7275,7278,7279,7280,
    7289,7290,7314,7331,7332,7333,7387,7388,7389,7390,7391,7392,
    7892,7942,7943,7944,7971,7972,7973,8370,8371,8372,8395,8621,
    8701,8874,8876,8878,8880,9088,9089,9094,9095,9096,9097,9100,
    9101,9104,9105,9121,9122,9123,9124,9125,9126,9127,9128,9129,
    9175,9192,9193,9885,9886,9898,9899,9932,9933,9934,10057,10058,
    10146,10147,10310,10744,10976,11394,11410,11411,11412,11417,11677,13461,
    13484,13485,13493,13562,14496,14541,14615,14631,14634,14642,14763,15044,
    15045,16776,16777,16778,16779,16780,16781,16782,17579,17954,17955,17956,
    17957,18076,18087,18093,18096,18097,18102
};

static const s_MapFiles[MAP_FILE_COUNT][MAP_FILE_NAME_LEN] =
{
    "el_quebrados.map",
    "HouseInteriors.pwn",
    "lg_addition.map",
    "LongcreekBank.pwn",
    "LongcreekBarber.pwn",
    "LongcreekCantina.pwn",
    "LongcreekChurch.pwn",
    "LongcreekDrug.pwn",
    "LongcreekGHotel.pwn",
    "LongcreekOffice.pwn",
    "LongcreekPost.pwn",
    "LongcreekRestaurant.pwn",
    "LongcreekSheriff.pwn",
    "wwrp_prison2.map"
};

static s_MapStats[MAP_FILE_COUNT + 1][e_MAP_FILE];

static Map:s_MapPrefixes;

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
stock bool:Map_IsChangingModel(model)
{
    new low = 0, high = sizeof(s_MapChangingModels) - 1;

    while (low <= high)
    {
        new mid = (low + high) / 2;

        if (s_MapChangingModels[mid] == model)
        {
            return true;
        }

        if (s_MapChangingModels[mid] < model)
        {
            low = mid + 1;
        }
        else
        {
            high = mid - 1;
        }
    }

    return false;
}

stock Map_GetFileCount()
{
    return MAP_FILE_COUNT;
}

stock Map_GetFileName(index,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (index >= 0 && index < MAP_FILE_COUNT)
    {
        strcopy(dest,s_MapFiles[index],size);
    }
}

stock Map_GetStat(index,e_MAP_FILE:field)
{
    if (index < 0 || index >= MAP_FILE_COUNT)
    {
        return 0;
    }

    return s_MapStats[index][field];
}

stock Map_GetObjectTotal()
{
    new total = 0;

    for (new i = 0;i < MAP_FILE_COUNT;i++)
    {
        total += s_MapStats[i][E_MAP_FILE_OBJECTS];
    }

    return total;
}

static Map_ParseInt(const token[])
{
    if (token[0] == '0' && (token[1] == 'x' || token[1] == 'X'))
    {
        new value = 0;

        for (new i = 2;token[i] != EOS;i++)
        {
            new digit = token[i];

            if (digit >= '0' && digit <= '9')
            {
                digit -= '0';
            }
            else if (digit >= 'a' && digit <= 'f')
            {
                digit = digit - 'a' + 10;
            }
            else if (digit >= 'A' && digit <= 'F')
            {
                digit = digit - 'A' + 10;
            }
            else
            {
                break;
            }

            value = (value << 4) | digit;
        }

        return value;
    }

    return strval(token);
}

static Float:Map_ParseFloat(const token[])
{
    return floatstr(token);
}

static Map_Unquote(const token[],dest[],size = sizeof(dest))
{
    new first = 0, last = strlen(token) - 1;

    while (first <= last && token[first] == '"')
    {
        first++;
    }

    while (last >= first && token[last] == '"')
    {
        last--;
    }

    new length = last - first + 1;

    if (length < 0)
    {
        length = 0;
    }

    if (length >= size)
    {
        length = size - 1;
    }

    for (new i = 0;i < length;i++)
    {
        dest[i] = token[first + i];
    }

    dest[length] = EOS;
}

static Map_Trim(text[])
{
    new first = 0, length = strlen(text);

    while (text[first] == ' ' || text[first] == '\t')
    {
        first++;
    }

    while (length > first && (text[length - 1] == ' ' || text[length - 1] == '\t' || text[length - 1] == '\r' || text[length - 1] == '\n'))
    {
        length--;
    }

    new count = length - first;

    for (new i = 0;i < count;i++)
    {
        text[i] = text[first + i];
    }

    text[count] = EOS;
}

static Map_Tokenise(const line[],start,tokens[][MAP_TOKEN_LEN],max)
{
    new open = -1;

    for (new i = start;line[i] != EOS;i++)
    {
        if (line[i] == '(')
        {
            open = i;
            break;
        }
    }

    if (open == -1)
    {
        return 0;
    }

    new count = 0, depth = 0, length = 0;
    new bool:quoted = false;
    tokens[0][0] = EOS;

    for (new i = open;line[i] != EOS;i++)
    {
        new c = line[i];

        if (c == '"')
        {
            quoted = !quoted;
        }

        if (!quoted)
        {
            if (c == '(')
            {
                depth++;

                if (depth == 1)
                {
                    continue;
                }
            }
            else if (c == ')')
            {
                depth--;

                if (depth == 0)
                {
                    tokens[count][length] = EOS;
                    Map_Trim(tokens[count]);
                    return count + 1;
                }
            }
            else if (c == ',' && depth == 1)
            {
                tokens[count][length] = EOS;
                Map_Trim(tokens[count]);

                if (++count >= max)
                {
                    return count;
                }

                length = 0;
                tokens[count][0] = EOS;
                continue;
            }
        }

        if (length == 0 && (c == ' ' || c == '\t'))
        {
            continue;
        }

        if (length < MAP_TOKEN_LEN - 1)
        {
            tokens[count][length++] = c;
        }
    }

    return 0;
}

static Map_Prefix(const line[],start,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (start <= 0)
    {
        return false;
    }

    new equals = -1;

    for (new i = 0;i < start;i++)
    {
        if (line[i] == '=')
        {
            equals = i;
            break;
        }
    }

    if (equals <= 0)
    {
        return false;
    }

    new length = equals;

    if (length >= size)
    {
        length = size - 1;
    }

    for (new i = 0;i < length;i++)
    {
        dest[i] = line[i];
    }

    dest[length] = EOS;
    Map_Trim(dest);
    return dest[0] != EOS;
}

static Map_Find(prefix[])
{
    Map_Trim(prefix);

    if (!map_valid(s_MapPrefixes) || !map_has_str_key(s_MapPrefixes,prefix))
    {
        return INVALID_STREAMER_ID;
    }

    return map_str_get(s_MapPrefixes,prefix);
}

static Map_Track(objectid)
{
#pragma unused objectid
}

static Map_Remember(const prefix[],objectid)
{
    if (prefix[0] != EOS && objectid != INVALID_STREAMER_ID)
    {
        map_str_set(s_MapPrefixes,prefix,objectid);
    }
}

static bool:Map_Line(index,const line[],tokens[][MAP_TOKEN_LEN])
{
    new start, prefix[MAP_PREFIX_LEN], text[MAP_TOKEN_LEN], face[MAP_TOKEN_LEN];

    if ((start = strfind(line,"SetObjectMaterialText")) != -1)
    {
        if (Map_Tokenise(line,start,tokens,MAP_TOKENS) < 10)
        {
            return false;
        }

        new objectid = Map_Find(tokens[0]);

        if (objectid == INVALID_STREAMER_ID)
        {
            return false;
        }

        Map_Unquote(tokens[1],text);
        Map_Unquote(tokens[4],face);
        SetDynamicObjectMaterialText(STREAMER_TAG_OBJECT:objectid,Map_ParseInt(tokens[2]),text,Map_ParseInt(tokens[3]),face,Map_ParseInt(tokens[5]),Map_ParseInt(tokens[6]),Map_ParseInt(tokens[7]),Map_ParseInt(tokens[8]),Map_ParseInt(tokens[9]));
        s_MapStats[index][E_MAP_FILE_MATERIALS]++;
        return true;
    }

    if ((start = strfind(line,"SetDynamicObjectMaterialText")) != -1)
    {
        if (Map_Tokenise(line,start,tokens,MAP_TOKENS) < 10)
        {
            return false;
        }

        new objectid = Map_Find(tokens[0]);

        if (objectid == INVALID_STREAMER_ID)
        {
            return false;
        }

        Map_Unquote(tokens[2],text);
        Map_Unquote(tokens[4],face);
        SetDynamicObjectMaterialText(STREAMER_TAG_OBJECT:objectid,Map_ParseInt(tokens[1]),text,Map_ParseInt(tokens[3]),face,Map_ParseInt(tokens[5]),Map_ParseInt(tokens[6]),Map_ParseInt(tokens[7]),Map_ParseInt(tokens[8]),Map_ParseInt(tokens[9]));
        s_MapStats[index][E_MAP_FILE_MATERIALS]++;
        return true;
    }

    start = strfind(line,"SetObjectMaterial");

    if (start == -1)
    {
        start = strfind(line,"SetDynamicObjectMaterial");
    }

    if (start != -1)
    {
        if (Map_Tokenise(line,start,tokens,MAP_TOKENS) < 6)
        {
            return false;
        }

        new objectid = Map_Find(tokens[0]);

        if (objectid == INVALID_STREAMER_ID)
        {
            return false;
        }

        new txd[MAP_TOKEN_LEN], texture[MAP_TOKEN_LEN];
        Map_Unquote(tokens[3],txd);
        Map_Unquote(tokens[4],texture);
        SetDynamicObjectMaterial(STREAMER_TAG_OBJECT:objectid,Map_ParseInt(tokens[1]),Map_ParseInt(tokens[2]),txd,texture,Map_ParseInt(tokens[5]));
        s_MapStats[index][E_MAP_FILE_MATERIALS]++;
        return true;
    }

    if ((start = strfind(line,"CreateObject")) != -1)
    {
        if (Map_Tokenise(line,start,tokens,MAP_TOKENS) < 7)
        {
            return false;
        }

        if (Map_IsChangingModel(Map_ParseInt(tokens[0])))
        {
            s_MapStats[index][E_MAP_FILE_CHANGING]++;
            return true;
        }

        new objectid = _:CA_CreateDynamicObject_SC(Map_ParseInt(tokens[0]),Map_ParseFloat(tokens[1]),Map_ParseFloat(tokens[2]),Map_ParseFloat(tokens[3]),Map_ParseFloat(tokens[4]),Map_ParseFloat(tokens[5]),Map_ParseFloat(tokens[6]),-1,-1,-1,MAP_STREAM_DISTANCE,MAP_STREAM_DISTANCE);

        if (objectid == INVALID_STREAMER_ID)
        {
            return false;
        }

        s_MapStats[index][E_MAP_FILE_OBJECTS]++;
        Map_Track(objectid);

        if (Map_Prefix(line,start,prefix))
        {
            Map_Remember(prefix,objectid);
        }

        return true;
    }

    if ((start = strfind(line,"CreateDynamicObject")) != -1)
    {
        if (Map_Tokenise(line,start,tokens,MAP_TOKENS) < 7)
        {
            return false;
        }

        if (Map_IsChangingModel(Map_ParseInt(tokens[0])))
        {
            s_MapStats[index][E_MAP_FILE_CHANGING]++;
            return true;
        }

        new objectid = _:CreateDynamicObject(Map_ParseInt(tokens[0]),Map_ParseFloat(tokens[1]),Map_ParseFloat(tokens[2]),Map_ParseFloat(tokens[3]),Map_ParseFloat(tokens[4]),Map_ParseFloat(tokens[5]),Map_ParseFloat(tokens[6]));

        if (objectid == INVALID_STREAMER_ID)
        {
            return false;
        }

        s_MapStats[index][E_MAP_FILE_OBJECTS]++;
        Map_Track(objectid);

        if (Map_Prefix(line,start,prefix))
        {
            Map_Remember(prefix,objectid);
        }

        return true;
    }

    if ((start = strfind(line,"CreateGate")) != -1)
    {
        if (Map_Tokenise(line,start,tokens,MAP_TOKENS) < 19)
        {
            return false;
        }

        new objectid = Gate_Create(Map_ParseInt(tokens[0]),Map_ParseInt(tokens[1]),Map_ParseInt(tokens[2]),Map_ParseInt(tokens[3]),Map_ParseInt(tokens[4]),Map_ParseFloat(tokens[5]),Map_ParseFloat(tokens[6]),Map_ParseFloat(tokens[7]),Map_ParseFloat(tokens[8]),Map_ParseFloat(tokens[9]),Map_ParseFloat(tokens[10]),Map_ParseFloat(tokens[11]),Map_ParseFloat(tokens[12]),Map_ParseFloat(tokens[13]),Map_ParseFloat(tokens[14]),Map_ParseFloat(tokens[15]),Map_ParseFloat(tokens[16]),Map_ParseFloat(tokens[17]),Map_ParseInt(tokens[18]));
        s_MapStats[index][E_MAP_FILE_GATES]++;
        Map_Track(objectid);

        if (Map_Prefix(line,start,prefix))
        {
            Map_Remember(prefix,objectid);
        }

        return true;
    }

    return true;
}

stock bool:Map_IsMapLine(const line[])
{
    return strfind(line,"CreateObject") != -1 || strfind(line,"CreateDynamicObject") != -1 || strfind(line,"CreateGate") != -1 || strfind(line,"SetObjectMaterial") != -1 || strfind(line,"SetDynamicObjectMaterial") != -1;
}

static bool:Map_Read(index,const path[])
{
    new line[MAP_LINE_LEN], tokens[MAP_TOKENS][MAP_TOKEN_LEN];

    if (!fexist(path))
    {
        return false;
    }

    new File:handle = fopen(path,io_read);

    if (!handle)
    {
        return false;
    }

    s_MapStats[index][E_MAP_FILE_OBJECTS] = 0;
    s_MapStats[index][E_MAP_FILE_MATERIALS] = 0;
    s_MapStats[index][E_MAP_FILE_GATES] = 0;
    s_MapStats[index][E_MAP_FILE_SKIPPED] = 0;
    s_MapStats[index][E_MAP_FILE_CHANGING] = 0;
    s_MapStats[index][E_MAP_FILE_LOADED] = 0;

    if (map_valid(s_MapPrefixes))
    {
        map_delete(s_MapPrefixes);
    }

    s_MapPrefixes = map_new();

    while (fread(handle,line))
    {
        if (!Map_IsMapLine(line))
        {
            continue;
        }

        if (!Map_Line(index,line,tokens))
        {
            s_MapStats[index][E_MAP_FILE_SKIPPED]++;
        }
    }

    fclose(handle);
    map_delete(s_MapPrefixes);
    s_MapStats[index][E_MAP_FILE_LOADED] = 1;
    Log_Info("map","Loaded map %s: %d objects, %d materials, %d gates, %d lines skipped, %d animated or timed models left out",path,s_MapStats[index][E_MAP_FILE_OBJECTS],s_MapStats[index][E_MAP_FILE_MATERIALS],s_MapStats[index][E_MAP_FILE_GATES],s_MapStats[index][E_MAP_FILE_SKIPPED],s_MapStats[index][E_MAP_FILE_CHANGING]);
    return true;
}

stock Map_LoadFile(index)
{
    new path[64];
    format(path,sizeof(path),MAP_PATH_FORMAT,s_MapFiles[index]);
    return Map_Read(index,path);
}

stock Map_LoadAll()
{
    new loaded = 0;

    for (new i = 0;i < MAP_FILE_COUNT;i++)
    {
        if (Map_LoadFile(i))
        {
            loaded++;
        }
    }

    Log_Info("map","Finished map import: loaded %d maps, %d objects",loaded,Map_GetObjectTotal());
}
