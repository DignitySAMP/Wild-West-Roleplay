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
#define FURNITURE_LIMIT (100)
#define FURNITURE_PRICE (25)
#define FURNITURE_NAME_LEN (36)
#define FURNITURE_MAX_DISTANCE (80.0)
#define FURNITURE_FRONT_DISTANCE (2.5)
#define FURNITURE_LABEL_RANGE (50.0)
#define FURNITURE_MATERIAL_SLOTS (15)

enum _:E_FURNITURE_CATEGORY
{
    FURNITURE_CATEGORY_CONSTRUCTION = 0,
    FURNITURE_CATEGORY_HOUSE,
    FURNITURE_CATEGORY_OTHER,
}

enum e_FURNI_ITEM
{
    E_FURNI_ITEM_MODEL,
    E_FURNI_ITEM_NAME[FURNITURE_NAME_LEN],
}

enum e_FURNI_MATERIAL
{
    E_FURNI_MATERIAL_MODEL,
    E_FURNI_MATERIAL_NAME[FURNITURE_NAME_LEN],
    E_FURNI_MATERIAL_TXD[FURNITURE_NAME_LEN],
    E_FURNI_MATERIAL_TEXTURE[FURNITURE_NAME_LEN],
}

enum e_FURNITURE
{
    E_FURNITURE_POINT,
    E_FURNITURE_MODEL,
    Float:E_FURNITURE_X,
    Float:E_FURNITURE_Y,
    Float:E_FURNITURE_Z,
    Float:E_FURNITURE_RX,
    Float:E_FURNITURE_RY,
    Float:E_FURNITURE_RZ,
    E_FURNITURE_INTERIOR,
    E_FURNITURE_WORLD,
    E_FURNITURE_VANILLA,
    E_FURNITURE_OBJECT,
}

enum e_FURNITURE_EXTRA
{
    E_FURNITURE_EXTRA_MODEL,
    E_FURNITURE_EXTRA_TXD[FURNITURE_NAME_LEN],
    E_FURNITURE_EXTRA_TEXTURE[FURNITURE_NAME_LEN],
    E_FURNITURE_EXTRA_COLOR,
}

static const s_FurnitureConstruction[12][e_FURNI_ITEM] =
{
    {1495,"Screen Door"},
    {1501,"Old Screen Door"},
    {1535,"Pink Door"},
    {1497,"Farm Door"},
    {1492,"Moveable Green Door"},
    {1494,"Moveable Brown Door"},
    {1499,"Moveable Metal Door"},
    {19353,"Wall Piece"},
    {19426,"Small Wall Piece"},
    {19383,"Door Wall Piece"},
    {19399,"Window Wall Piece"},
    {19445,"Long Wall Piece"}
};

static const s_FurnitureHouse[13][e_FURNI_ITEM] =
{
    {1771,"Single Bed 1"},
    {1812,"Single Bed 2"},
    {1801,"Double Bed"},
    {1811,"Wooden Chair"},
    {19996,"Fold Out Chair"},
    {2121,"Red Chair"},
    {2096,"Rocking Chair"},
    {1280,"Wooden Bench"},
    {2370,"Wooden Coffee Table 1"},
    {1814,"Wooden Coffe Table 2"},
    {2115,"Wooden Table 1"},
    {2111,"Round Wooden Table"},
    {1770,"Kitchen Table"}
};

static const s_FurnitureOther[19][e_FURNI_ITEM] =
{
    {1744,"Wooden Shelf"},
    {1421,"Boxes"},
    {19921,"Toolbox"},
    {19915,"Stove"},
    {1738,"Heater"},
    {1510,"Ashtray"},
    {1736,"Deer Head Trophy"},
    {19847,"Smoked Leg"},
    {2804,"Piece of Meat"},
    {19638,"Box of Oranges"},
    {19574,"Orange"},
    {19636,"Box of Red Apples"},
    {19575,"Red Apple"},
    {19637,"Box of Green Apples"},
    {19576,"Green Apple"},
    {19823,"\"Big Cock\" Whiskey"},
    {1544,"Yellow Beer Bottle"},
    {1486,"Green Beer Bottle"},
    {1512,"Green Whiskey Bottle"}
};

static const s_FurnitureMaterials[27][e_FURNI_MATERIAL] =
{
    {18202,"Concrete 1","w_towncs_t","concretebig4256128"},
    {5134,"Concrete 2","wasteland_las2","concretenewb256"},
    {9495,"Concrete 3","vict_sfw","concretebigb256128"},
    {1676,"Shiny Metal 1","wshxrefpump","metalic128"},
    {8572,"Shiny Metal 2","vgssstairs1","metalic_64"},
    {18202,"Rusty Metal 1","w_towncs_t","pax256hi"},
    {8556,"Rusty Metal 2","vgsehseing1","Metalox64"},
    {10789,"Blue Metal 1","xenon_sfse","bluemetal02"},
    {8494,"Blue Metal 2","vgslowbuild1","bluemetal"},
    {9680,"Shed Metal 1","tramstatsfw","ws_corr_metal1"},
    {5775,"Shed Metal 2","sunset01_lawn","ws_corr_metal2"},
    {19426,"Wall 1","all_walls","711_walltemp"},
    {19426,"Wall 2","all_walls","ab_clubloungewall"},
    {19426,"Wall 3","all_walls","ab_corwallupr"},
    {19426,"Wall 4","all_walls","carp11s"},
    {19426,"Wall 5","all_walls","gym_floor5"},
    {19426,"Wall 6","all_walls","motel_wall3"},
    {19426,"Wall 7","all_walls","mp_burn_ceiling"},
    {19426,"Wall 8","all_walls","mp_carter_bwall"},
    {1219,"Wood 1","woodpanels","planks01"},
    {18229,"Wood 2","woodycs_t","fence1"},
    {8870,"Wood 3","vgsecnstrct03","Gen_Scaffold_Wood_Under"},
    {17009,"Wood 4","truth_farm","des_ghotwood1"},
    {12911,"Wood 5","sw_farm1","sw_barnwood4"},
    {12937,"Wood 6","sw_oldshack","sw_woodflloorsplat"},
    {12938,"Wood 7","sw_apartments","sw_woodflloor"},
    {11631,"Wood 8","mp_ranchcut","CJ_SLATEDWOOD"}
};

static Map:s_Furniture;
static Map:s_FurnitureExtra;
static s_FurnitureNext = 1;

forward Furniture_Load();
forward Furniture_OnChanged(pointid);

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
stock Furniture_GetItemCount(category)
{
    switch (category)
    {
        case FURNITURE_CATEGORY_CONSTRUCTION:
        {
            return sizeof(s_FurnitureConstruction);
        }
        case FURNITURE_CATEGORY_HOUSE:
        {
            return sizeof(s_FurnitureHouse);
        }
        case FURNITURE_CATEGORY_OTHER:
        {
            return sizeof(s_FurnitureOther);
        }
    }

    return 0;
}

stock bool:Furniture_GetItem(category,index,item[e_FURNI_ITEM])
{
    if (index < 0 || index >= Furniture_GetItemCount(category))
    {
        return false;
    }

    switch (category)
    {
        case FURNITURE_CATEGORY_CONSTRUCTION:
        {
            item = s_FurnitureConstruction[index];
        }
        case FURNITURE_CATEGORY_HOUSE:
        {
            item = s_FurnitureHouse[index];
        }
        case FURNITURE_CATEGORY_OTHER:
        {
            item = s_FurnitureOther[index];
        }
    }

    return true;
}

stock Furniture_GetMaterialCount()
{
    return sizeof(s_FurnitureMaterials);
}

stock bool:Furniture_GetMaterial(index,material[e_FURNI_MATERIAL])
{
    if (index < 0 || index >= sizeof(s_FurnitureMaterials))
    {
        return false;
    }

    material = s_FurnitureMaterials[index];
    return true;
}

stock bool:Furniture_Exists(furnitureid)
{
    return furnitureid > 0 && map_valid(s_Furniture) && map_has_key(s_Furniture,furnitureid);
}

stock bool:Furniture_Get(furnitureid,furniture[e_FURNITURE])
{
    if (!Furniture_Exists(furnitureid))
    {
        return false;
    }

    map_get_arr(s_Furniture,furnitureid,furniture);
    return true;
}

stock Furniture_GetTotal()
{
    return map_valid(s_Furniture) ? map_size(s_Furniture) : 0;
}

stock Iter:Furniture_Iterator()
{
    return map_iter(s_Furniture);
}

stock Furniture_Count(pointid)
{
    new count = 0;

    if (!map_valid(s_Furniture))
    {
        return 0;
    }

    for (new Iter:it = map_iter(s_Furniture);iter_inside(it);iter_move_next(it))
    {
        new furniture[e_FURNITURE];
        iter_get_arr(it,furniture);

        if (furniture[E_FURNITURE_POINT] == pointid)
        {
            count++;
        }
    }

    return count;
}

stock Furniture_FindByObject(pointid,objectid)
{
    if (!map_valid(s_Furniture))
    {
        return 0;
    }

    for (new Iter:it = map_iter(s_Furniture);iter_inside(it);iter_move_next(it))
    {
        new furniture[e_FURNITURE];
        iter_get_arr(it,furniture);

        if (furniture[E_FURNITURE_POINT] == pointid && furniture[E_FURNITURE_OBJECT] == objectid)
        {
            return iter_get_key(it);
        }
    }

    return 0;
}

stock Furniture_GetExtraCount(furnitureid)
{
    new count = 0;

    if (!map_valid(s_FurnitureExtra))
    {
        return 0;
    }

    for (new slot = 0;slot < FURNITURE_MATERIAL_SLOTS;slot++)
    {
        if (map_has_key(s_FurnitureExtra,furnitureid * 100 + slot))
        {
            count++;
        }
    }

    return count;
}

static Furniture_ApplyMaterial(objectid,slot,const extra[e_FURNITURE_EXTRA])
{
    SetDynamicObjectMaterial(STREAMER_TAG_OBJECT:objectid,slot,extra[E_FURNITURE_EXTRA_MODEL],extra[E_FURNITURE_EXTRA_TXD],extra[E_FURNITURE_EXTRA_TEXTURE],extra[E_FURNITURE_EXTRA_COLOR]);
}

static Furniture_Spawn(furnitureid,furniture[e_FURNITURE])
{
    furniture[E_FURNITURE_OBJECT] = _:CreateDynamicObject(furniture[E_FURNITURE_MODEL],furniture[E_FURNITURE_X],furniture[E_FURNITURE_Y],furniture[E_FURNITURE_Z],furniture[E_FURNITURE_RX],furniture[E_FURNITURE_RY],furniture[E_FURNITURE_RZ],furniture[E_FURNITURE_WORLD],furniture[E_FURNITURE_INTERIOR]);

    for (new slot = 0;slot < FURNITURE_MATERIAL_SLOTS;slot++)
    {
        new extra[e_FURNITURE_EXTRA];

        if (map_valid(s_FurnitureExtra) && map_has_key(s_FurnitureExtra,furnitureid * 100 + slot))
        {
            map_get_arr(s_FurnitureExtra,furnitureid * 100 + slot,extra);
            Furniture_ApplyMaterial(furniture[E_FURNITURE_OBJECT],slot,extra);
        }
    }

    map_set_arr(s_Furniture,furnitureid,furniture);
}

stock Furniture_Delete(furnitureid)
{
    new furniture[e_FURNITURE];

    if (!Furniture_Get(furnitureid,furniture))
    {
        return;
    }

    if (furniture[E_FURNITURE_OBJECT] != 0)
    {
        DestroyDynamicObject(STREAMER_TAG_OBJECT:furniture[E_FURNITURE_OBJECT]);
    }

    for (new slot = 0;slot < FURNITURE_MATERIAL_SLOTS;slot++)
    {
        if (map_has_key(s_FurnitureExtra,furnitureid * 100 + slot))
        {
            map_remove(s_FurnitureExtra,furnitureid * 100 + slot);
        }
    }

    map_remove(s_Furniture,furnitureid);
    mysql_tquery_s(g_Mysql,str_format("DELETE FROM furniture_extra WHERE furniture_ex_id = %d",furnitureid));
    mysql_tquery_s(g_Mysql,str_format("DELETE FROM furniture WHERE furniture_id = %d",furnitureid));
    pawn_call_public("Furniture_OnChanged","d",furniture[E_FURNITURE_POINT]);
}

stock Furniture_DeleteAll(pointid)
{
    new ids[FURNITURE_LIMIT * 2], count = 0;

    if (!map_valid(s_Furniture))
    {
        return;
    }

    for (new Iter:it = map_iter(s_Furniture);iter_inside(it);iter_move_next(it))
    {
        new furniture[e_FURNITURE];
        iter_get_arr(it,furniture);

        if (furniture[E_FURNITURE_POINT] == pointid && count < sizeof(ids))
        {
            ids[count++] = iter_get_key(it);
        }
    }

    for (new i = 0;i < count;i++)
    {
        Furniture_Delete(ids[i]);
    }
}

enum _:E_FURNITURE_RESULT
{
    FURNITURE_OK = 0,
    FURNITURE_LIMIT_REACHED,
    FURNITURE_TOO_POOR,
    FURNITURE_NOT_INSIDE,
    FURNITURE_NOT_OWNER,
    FURNITURE_FAILED,
}

stock Furniture_CheckInside(playerid,pointid,Float:x,Float:y,Float:z)
{
    new point[e_POINT];

    if (!Point_Get(pointid,point) || Point_GetPlayerPoint(playerid) != pointid)
    {
        return false;
    }

    if (GetPlayerVirtualWorld(playerid) != point[E_POINT_INT_VW] || GetPlayerInterior(playerid) != point[E_POINT_INT_INT])
    {
        return false;
    }

    return floatabs(x - point[E_POINT_INT_X]) <= FURNITURE_MAX_DISTANCE && floatabs(y - point[E_POINT_INT_Y]) <= FURNITURE_MAX_DISTANCE && floatabs(z - point[E_POINT_INT_Z]) <= FURNITURE_MAX_DISTANCE;
}

stock Furniture_Place(playerid,pointid,model,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
    if (!Point_IsOwner(playerid,pointid))
    {
        return FURNITURE_NOT_OWNER;
    }

    if (Furniture_Count(pointid) >= FURNITURE_LIMIT)
    {
        return FURNITURE_LIMIT_REACHED;
    }

    if (!Money_CanAfford(playerid,FURNITURE_PRICE))
    {
        return FURNITURE_TOO_POOR;
    }

    if (!Furniture_CheckInside(playerid,pointid,x,y,z))
    {
        return FURNITURE_NOT_INSIDE;
    }

    new furniture[e_FURNITURE], furnitureid = s_FurnitureNext++;
    Money_Take(playerid,FURNITURE_PRICE);
    furniture[E_FURNITURE_POINT] = pointid;
    furniture[E_FURNITURE_MODEL] = model;
    furniture[E_FURNITURE_X] = x;
    furniture[E_FURNITURE_Y] = y;
    furniture[E_FURNITURE_Z] = z;
    furniture[E_FURNITURE_RX] = rx;
    furniture[E_FURNITURE_RY] = ry;
    furniture[E_FURNITURE_RZ] = rz;
    furniture[E_FURNITURE_INTERIOR] = GetPlayerInterior(playerid);
    furniture[E_FURNITURE_WORLD] = GetPlayerVirtualWorld(playerid);
    furniture[E_FURNITURE_VANILLA] = 1;
    mysql_tquery_s(g_Mysql,str_format("INSERT INTO furniture (furniture_id, furniture_point_id, furniture_model_id, furniture_x_pos, furniture_y_pos, furniture_z_pos, furniture_rx_pos, furniture_ry_pos, furniture_rz_pos, furniture_interior_id, furniture_vw_id, furniture_vanilla) VALUES (%d, %d, %d, %f, %f, %f, %f, %f, %f, %d, %d, 1)",furnitureid,pointid,model,x,y,z,rx,ry,rz,furniture[E_FURNITURE_INTERIOR],furniture[E_FURNITURE_WORLD]));
    Furniture_Spawn(furnitureid,furniture);
    pawn_call_public("Furniture_OnChanged","d",pointid);
    return furnitureid;
}

stock bool:Furniture_Move(furnitureid,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
    new furniture[e_FURNITURE];

    if (!Furniture_Get(furnitureid,furniture))
    {
        return false;
    }

    furniture[E_FURNITURE_X] = x;
    furniture[E_FURNITURE_Y] = y;
    furniture[E_FURNITURE_Z] = z;
    furniture[E_FURNITURE_RX] = rx;
    furniture[E_FURNITURE_RY] = ry;
    furniture[E_FURNITURE_RZ] = rz;
    SetDynamicObjectPos(STREAMER_TAG_OBJECT:furniture[E_FURNITURE_OBJECT],x,y,z);
    SetDynamicObjectRot(STREAMER_TAG_OBJECT:furniture[E_FURNITURE_OBJECT],rx,ry,rz);
    map_set_arr(s_Furniture,furnitureid,furniture);
    mysql_tquery_s(g_Mysql,str_format("UPDATE furniture SET furniture_x_pos = %f, furniture_y_pos = %f, furniture_z_pos = %f, furniture_rx_pos = %f, furniture_ry_pos = %f, furniture_rz_pos = %f WHERE furniture_id = %d",x,y,z,rx,ry,rz,furnitureid));
    return true;
}

stock bool:Furniture_SetTexture(furnitureid,slot,materialindex)
{
    new furniture[e_FURNITURE], material[e_FURNI_MATERIAL], extra[e_FURNITURE_EXTRA];

    if (!Furniture_Get(furnitureid,furniture) || slot < 0 || slot >= FURNITURE_MATERIAL_SLOTS || !Furniture_GetMaterial(materialindex,material))
    {
        return false;
    }

    extra[E_FURNITURE_EXTRA_MODEL] = material[E_FURNI_MATERIAL_MODEL];
    strcopy(extra[E_FURNITURE_EXTRA_TXD],material[E_FURNI_MATERIAL_TXD],FURNITURE_NAME_LEN);
    strcopy(extra[E_FURNITURE_EXTRA_TEXTURE],material[E_FURNI_MATERIAL_TEXTURE],FURNITURE_NAME_LEN);
    extra[E_FURNITURE_EXTRA_COLOR] = 0;
    map_set_arr(s_FurnitureExtra,furnitureid * 100 + slot,extra);
    Furniture_ApplyMaterial(furniture[E_FURNITURE_OBJECT],slot,extra);
    mysql_tquery_s(g_Mysql,str_format("DELETE FROM furniture_extra WHERE furniture_ex_id = %d AND furniture_ex_material_index = %d",furnitureid,slot));
    mysql_tquery_s(g_Mysql,str_format("INSERT INTO furniture_extra (furniture_ex_id, furniture_ex_material_index, furniture_ex_model_id, furniture_ex_txd_name, furniture_ex_texture_name, furniture_ex_color) VALUES (%d, %d, %d, '%e', '%e', 0)",furnitureid,slot,extra[E_FURNITURE_EXTRA_MODEL],extra[E_FURNITURE_EXTRA_TXD],extra[E_FURNITURE_EXTRA_TEXTURE]));
    return true;
}

#pragma warning push
#pragma warning disable 204
public Furniture_Load()
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_new("SELECT furniture_ex_id, furniture_ex_material_index, furniture_ex_model_id, furniture_ex_txd_name, furniture_ex_texture_name, furniture_ex_color FROM furniture_extra ORDER BY furniture_extra_id"),false);

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, slot, extra[e_FURNITURE_EXTRA];
        cache_get_value_name_int(i,"furniture_ex_id",id);
        cache_get_value_name_int(i,"furniture_ex_material_index",slot);
        cache_get_value_name_int(i,"furniture_ex_model_id",extra[E_FURNITURE_EXTRA_MODEL]);
        cache_get_value_name(i,"furniture_ex_txd_name",extra[E_FURNITURE_EXTRA_TXD],FURNITURE_NAME_LEN);
        cache_get_value_name(i,"furniture_ex_texture_name",extra[E_FURNITURE_EXTRA_TEXTURE],FURNITURE_NAME_LEN);
        cache_get_value_name_int(i,"furniture_ex_color",extra[E_FURNITURE_EXTRA_COLOR]);

        if (slot >= 0 && slot < FURNITURE_MATERIAL_SLOTS)
        {
            map_set_arr(s_FurnitureExtra,id * 100 + slot,extra);
        }
    }

    await mysql_aquery_s(g_Mysql,str_new("SELECT furniture_id, furniture_point_id, furniture_model_id, furniture_x_pos, furniture_y_pos, furniture_z_pos, furniture_rx_pos, furniture_ry_pos, furniture_rz_pos, furniture_interior_id, furniture_vw_id, furniture_vanilla FROM furniture"),false);

    new orphans[64], orphanCount = 0;

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, furniture[e_FURNITURE];
        cache_get_value_name_int(i,"furniture_id",id);
        cache_get_value_name_int(i,"furniture_point_id",furniture[E_FURNITURE_POINT]);
        cache_get_value_name_int(i,"furniture_model_id",furniture[E_FURNITURE_MODEL]);
        cache_get_value_name_float(i,"furniture_x_pos",furniture[E_FURNITURE_X]);
        cache_get_value_name_float(i,"furniture_y_pos",furniture[E_FURNITURE_Y]);
        cache_get_value_name_float(i,"furniture_z_pos",furniture[E_FURNITURE_Z]);
        cache_get_value_name_float(i,"furniture_rx_pos",furniture[E_FURNITURE_RX]);
        cache_get_value_name_float(i,"furniture_ry_pos",furniture[E_FURNITURE_RY]);
        cache_get_value_name_float(i,"furniture_rz_pos",furniture[E_FURNITURE_RZ]);
        cache_get_value_name_int(i,"furniture_interior_id",furniture[E_FURNITURE_INTERIOR]);
        cache_get_value_name_int(i,"furniture_vw_id",furniture[E_FURNITURE_WORLD]);
        cache_get_value_name_int(i,"furniture_vanilla",furniture[E_FURNITURE_VANILLA]);

        if (id >= s_FurnitureNext)
        {
            s_FurnitureNext = id + 1;
        }

        if (!Point_Exists(furniture[E_FURNITURE_POINT]))
        {
            if (orphanCount < sizeof(orphans))
            {
                orphans[orphanCount++] = id;
            }

            continue;
        }

        Furniture_Spawn(id,furniture);
    }

    for (new i = 0;i < orphanCount;i++)
    {
        mysql_tquery_s(g_Mysql,str_format("DELETE FROM furniture_extra WHERE furniture_ex_id = %d",orphans[i]));
        mysql_tquery_s(g_Mysql,str_format("DELETE FROM furniture WHERE furniture_id = %d",orphans[i]));
    }

    Log_Info("property/furniture","Loaded %d furniture pieces",Furniture_GetTotal());
    Boot_LoaderDone();
    return 1;
}
#pragma warning pop

public Furniture_OnChanged(pointid)
{
    return 1;
}

stock Furniture_InitPool()
{
    s_Furniture = map_new();
    s_FurnitureExtra = map_new();
}
