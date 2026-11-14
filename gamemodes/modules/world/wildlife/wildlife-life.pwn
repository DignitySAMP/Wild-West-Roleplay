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
static Wildlife_Front(id,Float:distance,&Float:x,&Float:y)
{
    new Float:z, Float:offset = g_WildlifeModel[id] == WILDLIFE_MODEL_DEER ? 90.0 : 180.0;
    GetDynamicObjectPos(g_WildlifeObject[id],x,y,z);
    x += distance * floatsin(-g_WildlifeRotation[id] + offset,degrees);
    y += distance * floatcos(-g_WildlifeRotation[id] + offset,degrees);
}

static Float:Wildlife_Ground(Float:x,Float:y,Float:fallback)
{
    new Float:z = 0.0;

    if (!CA_FindZ_For2DCoord(x,y,z))
    {
        return fallback;
    }

    return z;
}

static bool:Wildlife_NearWater(Float:x,Float:y,Float:z)
{
    if (z <= 0.0 || z >= 4.0)
    {
        return false;
    }

    new Float:angle = 0.0;

    for (new i = 0;i < 4;i++)
    {
        new Float:checkX = x + (5.0 * floatsin(-angle,degrees)), Float:checkY = y + (5.0 * floatcos(-angle,degrees)), Float:checkZ = 0.0;
        angle += 90.0;
        CA_FindZ_For2DCoord(checkX,checkY,checkZ);
        checkZ -= 2.5;

        if (checkZ <= 0.0)
        {
            return true;
        }
    }

    return false;
}

static bool:Wildlife_PlayerNear(Float:x,Float:y,Float:z,Float:range)
{
    for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
    {
        if (IsPlayerConnected(playerid) && IsPlayerInRangeOfPoint(playerid,range,x,y,z))
        {
            return true;
        }
    }

    return false;
}

static Float:Wildlife_Turn(Float:rotation)
{
    switch (floatround(rotation,floatround_round))
    {
        case 10: return 30.0;
        case 30: return 60.0;
        case 60: return 90.0;
        case 90: return 120.0;
        case 120: return 150.0;
        case 150: return 180.0;
        case 180: return 210.0;
        case 210: return 240.0;
        case 240: return 270.0;
        case 270: return 300.0;
        case 300: return 330.0;
        case 330: return 360.0;
        case 360: return 10.0;
    }

    return rotation;
}

stock Wildlife_NextLeg(id,bool:force = false)
{
    if (g_WildlifeState[id] != WILDLIFE_STATE_WALK && g_WildlifeState[id] != WILDLIFE_STATE_RUN)
    {
        return;
    }

    new Float:cx, Float:cy, Float:cz;
    GetDynamicObjectPos(g_WildlifeObject[id],cx,cy,cz);

    if (!force && !Wildlife_PlayerNear(cx,cy,cz,WILDLIFE_ACTIVE_RANGE))
    {
        g_WildlifeParked[id] = true;
        return;
    }

    g_WildlifeParked[id] = false;

    if (cz == 0.0)
    {
        if (++g_WildlifeWater[id] >= 3)
        {
            g_WildlifeWater[id] = 0;
            Wildlife_Respawn(id);
            return;
        }
    }

    new Float:nx, Float:ny, Float:nz, Float:hx, Float:hy, Float:hz;
    Wildlife_Front(id,10.0,nx,ny);
    nz = Wildlife_Ground(nx,ny,cz);

    if (Wildlife_NearWater(cx,cy,cz) || Zone_FromPosition(cx,cy) == ZONE_NONE || CA_RayCastLine(cx,cy,cz,nx,ny,nz,hx,hy,hz))
    {
        g_WildlifeRotation[id] = Wildlife_Turn(g_WildlifeRotation[id]);
        SetDynamicObjectRot(g_WildlifeObject[id],0.0,0.0,g_WildlifeRotation[id]);
    }

    new Float:distance = 2.0, Float:speed = WILDLIFE_WALK_SPEED;

    if (g_WildlifeState[id] == WILDLIFE_STATE_RUN)
    {
        distance = 5.0;
        speed = WILDLIFE_RUN_SPEED;
    }

    Wildlife_Front(id,distance,nx,ny);
    nz = Wildlife_Ground(nx,ny,cz - 0.5);
    MoveDynamicObject(g_WildlifeObject[id],nx,ny,nz + 0.5,speed);
    pawn_call_public("Wildlife_OnMove","d",id);
}

static Wildlife_ReleaseSkin(id)
{
    if (_:g_WildlifeSkin[id] != INVALID_STREAMER_ID)
    {
        DestroyDynamicObject(g_WildlifeSkin[id]);
        g_WildlifeSkin[id] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
    }

    if (g_WildlifeHarvester[id] != WILDLIFE_NONE)
    {
        g_WildlifeProgress[g_WildlifeHarvester[id]] = 0.0;
        g_WildlifeHarvester[id] = WILDLIFE_NONE;
    }
}

stock Wildlife_Respawn(id)
{
    Wildlife_ReleaseSkin(id);
    g_WildlifeDue[id] = 0;
    g_WildlifeWater[id] = 0;
    g_WildlifeRotation[id] = float(1 + random(4)) * 90.0;
    StopDynamicObject(g_WildlifeObject[id]);
    SetDynamicObjectPos(g_WildlifeObject[id],g_WildlifeSpawns[id][0],g_WildlifeSpawns[id][1],g_WildlifeSpawns[id][2]);
    SetDynamicObjectRot(g_WildlifeObject[id],0.0,0.0,g_WildlifeRotation[id]);
    g_WildlifeState[id] = WILDLIFE_STATE_WALK;
    g_WildlifeHealth[id] = 100.0;
    g_WildlifeParked[id] = false;
    Wildlife_NextLeg(id,true);
}

stock Wildlife_RespawnAll()
{
    for (new id = 0;id < WILDLIFE_COUNT;id++)
    {
        Wildlife_Respawn(id);
    }
}

stock Wildlife_Create(id)
{
    new model = random(2) == 0 ? WILDLIFE_MODEL_DEER : WILDLIFE_MODEL_COW;
    g_WildlifeModel[id] = model;
    g_WildlifeRotation[id] = float(1 + random(4)) * 90.0;
    g_WildlifeObject[id] = CreateDynamicObject(model,g_WildlifeSpawns[id][0],g_WildlifeSpawns[id][1],g_WildlifeSpawns[id][2],0.0,0.0,g_WildlifeRotation[id]);
    g_WildlifeSkin[id] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
    g_WildlifeHarvester[id] = WILDLIFE_NONE;
    g_WildlifeState[id] = WILDLIFE_STATE_WALK;
    g_WildlifeHealth[id] = 100.0;
    g_WildlifeDue[id] = 0;
    map_add(g_WildlifeByObject,_:g_WildlifeObject[id],id);
    Wildlife_NextLeg(id,true);
}

stock Wildlife_Init()
{
    g_WildlifeByObject = map_new();

    for (new id = 0;id < WILDLIFE_COUNT;id++)
    {
        Wildlife_Create(id);
    }

    for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
    {
        g_WildlifePrompt[playerid] = WILDLIFE_NONE;
    }
}

static Wildlife_Kill(id,weapon)
{
    new Float:x, Float:y, Float:z;
    StopDynamicObject(g_WildlifeObject[id]);
    GetDynamicObjectPos(g_WildlifeObject[id],x,y,z);
    SetDynamicObjectPos(g_WildlifeObject[id],x,y,z - 0.4);

    if (g_WildlifeModel[id] == WILDLIFE_MODEL_DEER)
    {
        SetDynamicObjectRot(g_WildlifeObject[id],90.0,0.0,g_WildlifeRotation[id]);
    }
    else
    {
        SetDynamicObjectRot(g_WildlifeObject[id],0.0,90.0,g_WildlifeRotation[id]);
    }

    g_WildlifeState[id] = WILDLIFE_STATE_DEAD;
    g_WildlifeHealth[id] = 0.0;
    g_WildlifeDue[id] = GetTickCount() + WILDLIFE_RESPAWN_MS;

    if (g_WildlifeDue[id] == 0)
    {
        g_WildlifeDue[id] = 1;
    }

    pawn_call_public("Wildlife_OnKilled","dd",id,weapon);
}

stock Float:Wildlife_Shot(id,weapon)
{
    if (!Wildlife_IsValid(id) || g_WildlifeState[id] == WILDLIFE_STATE_DEAD || g_WildlifeState[id] == WILDLIFE_STATE_INACTIVE)
    {
        return -1.0;
    }

    new Float:damage;

    switch (weapon)
    {
        case 33: damage = 100.0;
        case 24: damage = 50.0;
        case 25: damage = 50.0;
        case 26: damage = 50.0;
        case 34: damage = 100.0;
        case 1000: damage = 100.0;
        default: damage = 20.0;
    }

    g_WildlifeHealth[id] -= damage;

    if (g_WildlifeHealth[id] <= 0.0)
    {
        Wildlife_Kill(id,weapon);
    }

    return g_WildlifeHealth[id];
}

static Wildlife_Loot(playerid)
{
    new text[144], amount = 1 + random(1);

    if (Inventory_GiveByParam(playerid,E_ITEM_PARAM_HUNTING,E_ITEM_EXTRA_WILDLIFE_HIDE,amount,750 + random(250),-1,0))
    {
        format(text,sizeof(text),"| Looted %d skins of hide~n~",amount);
    }

    amount = 1 + random(2);

    if (Inventory_GiveByParam(playerid,E_ITEM_PARAM_HUNTING,E_ITEM_EXTRA_WILDLIFE_MEAT,amount,500 + random(250),-1,0))
    {
        format(text,sizeof(text),"%s| Looted %d slabs of meat~n~",text,amount);
    }

    if (random(2) != 0)
    {
        amount = 1 + random(2);

        if (Inventory_GiveByParam(playerid,E_ITEM_PARAM_HUNTING,E_ITEM_EXTRA_WILDLIFE_MEAT_LEG,amount,1000 + random(250),-1,0))
        {
            format(text,sizeof(text),"%s| Looted %d meaty legs~n~",text,amount);
        }
    }

    ActionPanel_SetText(playerid,text);
}

static Wildlife_Finish(playerid,id)
{
    new Float:ox, Float:oy, Float:oz, Float:nx, Float:ny, Float:nz, Float:rx, Float:ry, Float:rz;
    g_WildlifeState[id] = WILDLIFE_STATE_INACTIVE;
    GetDynamicObjectPos(g_WildlifeObject[id],ox,oy,oz);
    g_WildlifeCarcass[id][0] = ox;
    g_WildlifeCarcass[id][1] = oy;
    g_WildlifeCarcass[id][2] = oz;
    CA_RayCastLineAngle(ox,oy,oz + 5.0,ox,oy,oz - 5.0,nx,ny,nz,rx,ry,rz);

    if (g_WildlifeModel[id] == WILDLIFE_MODEL_DEER)
    {
        g_WildlifeSkin[id] = CreateDynamicObject(WILDLIFE_MODEL_DEER,ox,oy,oz,rx + 90.0,ry,rz);
        SetDynamicObjectMaterial(g_WildlifeSkin[id],0,2804,"CJ_MEATY","CJ_FLESH_2");
    }
    else
    {
        g_WildlifeSkin[id] = CreateDynamicObject(WILDLIFE_MODEL_COW,ox,oy,oz,rx,ry + 90.0,rz);
        SetDynamicObjectMaterial(g_WildlifeSkin[id],0,2804,"CJ_MEATY","CJ_FLESH_1");
    }

    SetDynamicObjectPos(g_WildlifeObject[id],0.0,0.0,0.0);
    Streamer_Update(playerid);
    Wildlife_Loot(playerid);
    Levels_GiveExperience(playerid,2);
    g_WildlifeProgress[playerid] = 0.0;
    g_WildlifeHarvester[id] = WILDLIFE_NONE;
    pawn_call_public("Wildlife_OnSkinned","dd",playerid,id);
}

static Wildlife_NearestCarcass(playerid)
{
    new Float:px, Float:py, Float:pz, best = WILDLIFE_NONE, Float:bestDistance = WILDLIFE_DEAD_RANGE * WILDLIFE_DEAD_RANGE;
    GetPlayerPos(playerid,px,py,pz);

    for (new id = 0;id < WILDLIFE_COUNT;id++)
    {
        if (g_WildlifeState[id] != WILDLIFE_STATE_DEAD && g_WildlifeState[id] != WILDLIFE_STATE_INACTIVE)
        {
            continue;
        }

        new Float:x, Float:y, Float:z;
        Wildlife_GetPosition(id,x,y,z);
        new Float:distance = ((x - px) * (x - px)) + ((y - py) * (y - py));

        if (distance < bestDistance)
        {
            bestDistance = distance;
            best = id;
        }
    }

    return best;
}

stock bool:Wildlife_TrySkin(playerid)
{
    if (GetPlayerAnimationIndex(playerid) == 163)
    {
        return true;
    }

    new id = Wildlife_NearestCarcass(playerid);

    if (id == WILDLIFE_NONE)
    {
        SendServerMessage(playerid,"You don't seem to be near a dead animal.",MSG_TYPE_ERROR);
        return false;
    }

    if (g_WildlifeState[id] == WILDLIFE_STATE_INACTIVE)
    {
        SendServerMessage(playerid,"You can't harvest this animal. It might have already been harvested.",MSG_TYPE_ERROR);
        return false;
    }

    new other = g_WildlifeHarvester[id];

    if (other != WILDLIFE_NONE && other != playerid && IsPlayerConnected(other))
    {
        SendServerMessage(playerid,"Someone else is already skinning this animal.",MSG_TYPE_ERROR);
        return false;
    }

    g_WildlifeHarvester[id] = playerid;
    g_WildlifePrompt[playerid] = id;
    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,false,false,false,false,0,SYNC_ALL);
    g_WildlifeProgress[playerid] += WILDLIFE_SKIN_STEP;
    new text[72];
    format(text,sizeof(text),"Press ~k~~SNEAK_ABOUT~ to start skinning this %s.",g_WildlifeModel[id] == WILDLIFE_MODEL_DEER ? ("deer") : ("cow"));

    if (ActionPanel_GetMode(playerid) != E_ACTION_TYPE_DEER)
    {
        ActionPanel_Show(playerid,E_ACTION_TYPE_DEER);
    }

    ActionPanel_SetText(playerid,text,g_WildlifeModel[id]);
    ActionPanel_SetProgress(playerid,g_WildlifeProgress[playerid]);

    if (g_WildlifeProgress[playerid] >= 100.0)
    {
        Wildlife_Finish(playerid,id);
    }

    return true;
}

stock Wildlife_PlayerLeft(playerid)
{
    for (new id = 0;id < WILDLIFE_COUNT;id++)
    {
        if (g_WildlifeHarvester[id] == playerid)
        {
            g_WildlifeHarvester[id] = WILDLIFE_NONE;
        }
    }

    g_WildlifeProgress[playerid] = 0.0;
    g_WildlifePrompt[playerid] = WILDLIFE_NONE;
}

stock Wildlife_Tick()
{
    new now = GetTickCount(), Float:px[MAX_PLAYERS], Float:py[MAX_PLAYERS], Float:pz, bool:online[MAX_PLAYERS];

    for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
    {
        online[playerid] = bool:IsPlayerConnected(playerid);

        if (online[playerid])
        {
            GetPlayerPos(playerid,px[playerid],py[playerid],pz);
        }
    }

    new Float:ax[WILDLIFE_COUNT], Float:ay[WILDLIFE_COUNT], Float:az;

    for (new id = 0;id < WILDLIFE_COUNT;id++)
    {
        new current = g_WildlifeState[id];

        if (current == WILDLIFE_STATE_INACTIVE)
        {
            ax[id] = g_WildlifeCarcass[id][0];
            ay[id] = g_WildlifeCarcass[id][1];
        }
        else
        {
            GetDynamicObjectPos(g_WildlifeObject[id],ax[id],ay[id],az);
        }

        if (current == WILDLIFE_STATE_DEAD || current == WILDLIFE_STATE_INACTIVE)
        {
            if (g_WildlifeDue[id] != 0 && now - g_WildlifeDue[id] >= 0)
            {
                Wildlife_Respawn(id);
            }

            continue;
        }

        new bool:near = false;

        for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
        {
            if (online[playerid] && ((px[playerid] - ax[id]) * (px[playerid] - ax[id])) + ((py[playerid] - ay[id]) * (py[playerid] - ay[id])) < WILDLIFE_SCARE_RANGE * WILDLIFE_SCARE_RANGE)
            {
                near = true;
                break;
            }
        }

        if (current == WILDLIFE_STATE_WALK && near)
        {
            g_WildlifeState[id] = WILDLIFE_STATE_RUN;
            Wildlife_NextLeg(id,true);
        }
        else if (current == WILDLIFE_STATE_RUN && !near)
        {
            g_WildlifeState[id] = WILDLIFE_STATE_WALK;
            Wildlife_NextLeg(id,true);
        }
        else if (g_WildlifeParked[id] || !IsDynamicObjectMoving(g_WildlifeObject[id]))
        {
            Wildlife_NextLeg(id);
        }
    }

    for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
    {
        if (!online[playerid])
        {
            continue;
        }

        new target = WILDLIFE_NONE;

        for (new id = 0;id < WILDLIFE_COUNT;id++)
        {
            if (g_WildlifeState[id] == WILDLIFE_STATE_DEAD && ((px[playerid] - ax[id]) * (px[playerid] - ax[id])) + ((py[playerid] - ay[id]) * (py[playerid] - ay[id])) < WILDLIFE_DEAD_RANGE * WILDLIFE_DEAD_RANGE)
            {
                target = id;
                break;
            }
        }

        if (target != WILDLIFE_NONE && g_WildlifePrompt[playerid] != target)
        {
            g_WildlifePrompt[playerid] = target;

            if (ActionPanel_GetMode(playerid) != E_ACTION_TYPE_GUN)
            {
                SendServerMessage(playerid,"You can skin this animal by equipping a hunting knife and pressing ~k~~SNEAK_ABOUT~.",MSG_TYPE_INFO);
                ActionPanel_Show(playerid,E_ACTION_TYPE_DEER);
                ActionPanel_SetText(playerid,"Press ~k~~SNEAK_ABOUT~ to start skinning this animal.");
            }
        }
        else if (target == WILDLIFE_NONE && g_WildlifePrompt[playerid] != WILDLIFE_NONE)
        {
            new previous = g_WildlifePrompt[playerid];
            g_WildlifePrompt[playerid] = WILDLIFE_NONE;
            g_WildlifeProgress[playerid] = 0.0;

            if (g_WildlifeHarvester[previous] == playerid)
            {
                g_WildlifeHarvester[previous] = WILDLIFE_NONE;
            }

            if (ActionPanel_GetMode(playerid) == E_ACTION_TYPE_DEER)
            {
                ActionPanel_Hide(playerid);
            }
        }
    }
}

